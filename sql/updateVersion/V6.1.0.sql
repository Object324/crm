select deleted into @tax2_delete from ld_inventorytaxinfo where taxname='tax2';
update ld_inventorytaxinfo set deleted=0 where taxname='tax2';
delimiter;

DROP PROCEDURE IF EXISTS `addblocklableintotrantable`;
delimiter ||
CREATE  PROCEDURE `addblocklableintotrantable`(
)
BEGIN
	declare done  int  default 0;

	declare ffieldid int ;
	declare ttabid int;
	DECLARE ffieldlabel varchar(200);
	declare cur1 CURSOR FOR SELECT blockid,tabid ,blocklabel  FROM  ld_blocks  ;
	declare continue handler  for not   found  SET done =1;
	OPEN cur1;
	Fetch cur1 into ffieldid,ttabid,ffieldlabel;

 	loop1: while  done<>1 DO
		set @sql=CONCAT('insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel) select ''en'',''ld_blocks'' ',',',ttabid,',',ffieldid,',','''',ffieldlabel,'''  from dual where not exists(select 1 from ld_tranlabel where relateid=',ffieldid,' and languagetype=''en'' and tabid=',ttabid,' and trantable=''ld_blocks''',')');

		prepare stmt from @sql;
	      execute stmt;
	      deallocate  prepare  stmt;
set @sql=CONCAT('insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel) select ''zh'',''ld_blocks'' ',',',ttabid,',',ffieldid,',','''',ffieldlabel,'''  from dual where not exists(select 1 from ld_tranlabel where relateid=',ffieldid,' and languagetype=''zh'' and tabid=',ttabid,' and trantable=''ld_blocks''',')');

		prepare stmt from @sql;
	      execute stmt;
	      deallocate  prepare  stmt;
		Fetch cur1 into ffieldid,ttabid,ffieldlabel;
	end while loop1;
	close cur1;
end ||
delimiter;

-- ----------------------------
-- Procedure structure for `AddColumn`
-- ----------------------------
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
		ELSEIF isdefault=0 THEN
			SET @alterColumn=CONCAT(' alter table ',tablename, ' add column ',columnname, ' ',columntype, ' default 0 ');
		ELSE
			 SET @alterColumn=CONCAT(' alter table ',tablename, ' add column ',columnname, ' ',columntype,'(',columnlen,')');
		END IF;
	PREPARE stalter FROM @altercolumn;
		EXECUTE stalter;
	END IF;
end ||
delimiter;

-- ----------------------------
-- Procedure structure for `addfieldlabelintotrantable`
-- ----------------------------
DROP PROCEDURE IF EXISTS `addfieldlabelintotrantable`;
delimiter ||
CREATE  PROCEDURE `addfieldlabelintotrantable`(
)
BEGIN
	declare done  int  default 0;

	declare ffieldid int ;
	declare ttabid int;
	DECLARE ffieldlabel varchar(200);
	declare cur1 CURSOR FOR SELECT fieldid,tabid ,fieldlabel  FROM  ld_field;
	declare continue handler  for not   found  SET done =1;
	OPEN cur1;
	Fetch cur1 into ffieldid,ttabid,ffieldlabel;

 	loop1: while  done<>1 DO
		set @sql=CONCAT('insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel) select ''zh'',''ld_field'' ',',',ttabid,',',ffieldid,',','''',ffieldlabel,'''  from dual where not exists(select 1 from ld_tranlabel where relateid=',ffieldid,' and languagetype=''zh'' and tabid=',ttabid,' and trantable=''ld_field''',')');

		prepare stmt from @sql;
	      execute stmt;
	      deallocate  prepare  stmt;

		Fetch cur1 into ffieldid,ttabid,ffieldlabel;
	end while loop1;
	close cur1;
end ||
delimiter;

-- ----------------------------
-- Procedure structure for `addfldcrmentityinfo`
-- ----------------------------
DROP PROCEDURE IF EXISTS `addfldcrmentityinfo`;
delimiter ||
CREATE  PROCEDURE `addfldcrmentityinfo`(
	IN pmodule VARCHAR(100)
)
BEGIN
	DECLARE done int default 0;

	SET @sql = CONCAT('SELECT ld_tab.tabid,ld_entityname.tablename,ld_entityname.entityidfield INTO @ptabid,@ptablename,@ptableindex
		FROM ld_entityname
			INNER JOIN ld_tab
				ON ld_tab.`tabid` = ld_entityname.`tabid`
		WHERE ld_entityname.`tabid` > 0 AND ld_tab.name = "',pmodule,'" limit 1;');

	PREPARE stmt FROM @sql;
		EXECUTE stmt;
	DEALLOCATE PREPARE stmt;

	if (@ptabid > 0) AND (@ptablename != '') THEN
		-- 获取当前数据库名，要判断的字段
		SELECT DATABASE() INTO @tableschema;
		SET @columnname = 'smownerid,smcreatorid,modifiedby,createdtime,modifiedtime,description,deleted';


		loop1: WHILE done < 1 DO
			-- 判断字段是否加入成功
			SET @tsql = CONCAT('select COUNT(column_name) INTO @colcount from information_schema.columns where  TABLE_SCHEMA ="',@tableschema,'"  and
		lower(table_name)= lower("',@ptablename,'") and FIND_IN_SET(column_name,"',@columnname,'")');
			prepare stmt from @tsql;
				execute stmt;
			DEALLOCATE PREPARE stmt;

			IF @colcount = 7 THEN
				SET done = 1;
			ELSE
				-- 加字段
				CALL AddColumn(@ptablename,'smownerid','int',19,0);
				CALL AddColumn(@ptablename,'smcreatorid','int',19,0);
				CALL AddColumn(@ptablename,'modifiedby','int',19,0);
				CALL AddColumn(@ptablename,'createdtime','datetime','','');
				CALL AddColumn(@ptablename,'modifiedtime','datetime','','');
				CALL AddColumn(@ptablename,'description','text','','');
				CALL AddColumn(@ptablename,'deleted','int',19,0);
			END IF;
		END WHILE loop1;

		SET @tsql=CONCAT('select COUNT(column_name) INTO @crmfldcount from information_schema.columns where  TABLE_SCHEMA = "',@tableschema,'"  and table_name= "ld_crmentity";');
		PREPARE stmt FROM @tsql;
			EXECUTE stmt;
		DEALLOCATE PREPARE stmt;

		IF @crmfldcount = 13 THEN
			-- 同步 crmentity表 数据
			SET @sql = CONCAT('UPDATE ',@ptablename,' INNER JOIN ld_crmentity ON ',@ptablename,'.',@ptableindex,' = ld_crmentity.crmid
			SET ',@ptablename,'.smownerid = ld_crmentity.smownerid,',@ptablename,'.smcreatorid = ld_crmentity.smcreatorid,
			',@ptablename,'.modifiedby = ld_crmentity.modifiedby,',@ptablename,'.createdtime = ld_crmentity.createdtime,
			',@ptablename,'.modifiedtime = ld_crmentity.modifiedtime,',@ptablename,'.description = ld_crmentity.description,
			',@ptablename,'.deleted = ld_crmentity.deleted where ',@ptablename,'.modifiedby = 0;');
			PREPARE stmt FROM @sql;
				EXECUTE stmt;
			DEALLOCATE PREPARE stmt;

			-- tablename表名，必须LD为大写，其余均为小写
			SELECT CONCAT('LD',LOWER(SUBSTRING(@ptablename,3,LENGTH(@ptablename)))) INTO @tablename;

			-- Calendar日程安排，tabid修改为16
			IF @ptabid = 9 THEN
				set @ptabid = 16;
			END IF;

			-- 修改 ld_field 表 数据
			set @sql = CONCAT('UPDATE ld_field set tablename = "',@tablename,'" where tabid = ',@ptabid,' and columnname in ("smownerid","smcreatorid","modifiedby","createdtime","modifiedtime","description","deleted") ');
			PREPARE stmt FROM @sql;
				EXECUTE stmt;
			DEALLOCATE PREPARE stmt;
		END if;

	end if;
end ||
delimiter;

-- ----------------------------
-- Procedure structure for `addforginkey`
-- ----------------------------
DROP PROCEDURE IF EXISTS `addforginkey`;
delimiter ||
CREATE  PROCEDURE `addforginkey`(
 
tablename varchar(50),
forginkeyname varchar(100),
columnname varchar(50),
referencetable varchar(50),
referenceid varchar(50)
 
)
begin
 
select database() into @tableschema;
 
set tablename=lower(tablename);
 

set @colName='';
SET @tsql=CONCAT('select  IFNULL(referenced_column_name, '''') into @colName  from information_schema.key_column_usage  where  
TABLE_SCHEMA =','''',@tableschema,'''','  and  table_name= ','''',tablename,'''',' and referenced_column_name=''',referenceid,'''');
 
prepare stmt from @tsql;
execute stmt;
set @coladd=IFNULL(@colName,'-1');
 
IF @coladd = '-1'  or @coladd<>referenceid THEN
 set @alterColumn=CONCAT(' alter table ',tablename, ' add foreign key(  ',columnname, ' ) references  ',referencetable, '( ',referenceid,' )  ON  DELETE CASCADE');
 prepare stalter from @altercolumn;
 execute stalter;
 
END IF;
end ||
delimiter;

-- ----------------------------
-- Procedure structure for `addModuleActivity`
-- ----------------------------
DROP PROCEDURE IF EXISTS `addModuleActivity`;
delimiter ||
CREATE  PROCEDURE `addModuleActivity`(IN pmodule VARCHAR(100),IN pactivityid int)
BEGIN
 DECLARE done int DEFAULT 0;
 DECLARE pprofileid int(11);
 DECLARE profileobj CURSOR FOR SELECT profileid from ld_profile;
 DECLARE CONTINUE HANDLER for not found set done = 1;
 select tabid into @tabid from ld_tab where name = pmodule;
 OPEN profileobj;
 fetch profileobj into pprofileid;
 LOOP1: WHILE done <> 1 DO
  set @sql = CONCAT('insert into ld_profile2utility(profileid,tabid,activityid,permission) select ',pprofileid,',',@tabid,',',pactivityid,',1 from dual where not exists (select 1 from ld_profile2utility where profileid=',pprofileid,' and tabid=',@tabid,' and activityid = ',pactivityid,')');
  prepare stmt from @sql;
   execute stmt;
  deallocate prepare stmt;
  fetch profileobj into pprofileid;
 END WHILE LOOP1;
 close profileobj;
end ||
delimiter;

-- ----------------------------
-- Procedure structure for `addparenttablabelintotrantable`
-- ----------------------------
DROP PROCEDURE IF EXISTS `addparenttablabelintotrantable`;
delimiter ||
CREATE  PROCEDURE `addparenttablabelintotrantable`(
)
BEGIN
	declare done  int  default 0;

	declare ffieldid int ;
	declare ttabid int;
	DECLARE ffieldlabel varchar(200);
	declare cur1 CURSOR FOR SELECT parentid,parentid ,chinesename  FROM  ld_parentlanguagepackage ;
	declare continue handler  for not   found  SET done =1;
	OPEN cur1;
	Fetch cur1 into ffieldid,ttabid,ffieldlabel;

 	loop1: while  done<>1 DO
		set @sql=CONCAT('insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel) select ''zh'',''ld_parenttab'' ',',',ttabid,',',ffieldid,',','''',ffieldlabel,'''  from dual where not exists(select 1 from ld_tranlabel where relateid=',ffieldid,' and languagetype=''zh'' and tabid=',ttabid,' and trantable=''ld_parenttab''',')');
		

		prepare stmt from @sql;
	      execute stmt;
	      deallocate  prepare  stmt;

		Fetch cur1 into ffieldid,ttabid,ffieldlabel;
	end while loop1;
	close cur1;
end ||
delimiter;

-- ----------------------------
-- Procedure structure for `AddProductColumn`
-- ----------------------------
DROP PROCEDURE IF EXISTS `AddProductColumn`;
delimiter ||
CREATE  PROCEDURE `AddProductColumn`(
	module varchar(100)
)
BEGIN
	declare str varchar(100);
	declare cnt int(11) DEFAULT 0;
	declare i int(11) DEFAULT 0;
	declare limit_end int;
	select count(*) into cnt from ld_customview where entitytype = module;
	while i < cnt
	do
		set @stmt = concat('select cvid into @cvid from ld_customview where entitytype = ','''',module,'''',' limit ?,?');
		prepare s1 from @stmt;
		set @s1 = i;
		set @s2 = 1;
		execute s1 using @s1,@s2;
		delete from ld_cvcolumnlist where cvid = @cvid;
		if(module = 'SalesOrder')
		then
			insert into ld_cvcolumnlist(cvid,columnindex,columnname) values (@cvid,0,'ld_salesorder:subject:subject:SalesOrder_主题:V');
			insert into ld_cvcolumnlist(cvid,columnindex,columnname) values (@cvid,1,'ld_crmentity:smownerid:assigned_user_id:SalesOrder_销售负责人:V');
			insert into ld_cvcolumnlist(cvid,columnindex,columnname) values (@cvid,2,'ld_salesorder:accountid:account_id:SalesOrder_Account_Name:V');
			insert into ld_cvcolumnlist(cvid,columnindex,columnname) values (@cvid,3,'ld_salesorder:contactid:contact_id:SalesOrder_联系人姓名:V');
			insert into ld_cvcolumnlist(cvid,columnindex,columnname) values (@cvid,4,'ld_salesorder:potentialid:potential_id:SalesOrder_销售机会名称:V');
			insert into ld_cvcolumnlist(cvid,columnindex,columnname) values (@cvid,5,'ld_salesorder:total:hdnGrandTotal:SalesOrder_Total:N');
		elseif(module = 'PurchaseOrder')
		then
			insert into ld_cvcolumnlist(cvid,columnindex,columnname) values (@cvid,0,'ld_purchaseorder:subject:subject:PurchaseOrder_Subject:V');
			insert into ld_cvcolumnlist(cvid,columnindex,columnname) values (@cvid,1,'ld_purchaseorder:vendorid:vendor_id:PurchaseOrder_Vendor_Name:V');
			insert into ld_cvcolumnlist(cvid,columnindex,columnname) values (@cvid,2,'ld_purchaseorder:contactid:contact_id:PurchaseOrder_联系人姓名:V');
			insert into ld_cvcolumnlist(cvid,columnindex,columnname) values (@cvid,3,'ld_purchaseorder:total:hdnGrandTotal:PurchaseOrder_Total:N');
			insert into ld_cvcolumnlist(cvid,columnindex,columnname) values (@cvid,4,'ld_crmentity:smownerid:assigned_user_id:PurchaseOrder_Total:采购负责人');
		end if;
		set i = i + 1;
	end while;
end ||
delimiter;

-- ----------------------------
-- Procedure structure for `addproducttoolfieldintotrantable`
-- ----------------------------
DROP PROCEDURE IF EXISTS `addproducttoolfieldintotrantable`;
delimiter ||
CREATE  PROCEDURE `addproducttoolfieldintotrantable`(
)
BEGIN
	declare done  int  default 0;

	declare ffieldid int ;
	DECLARE ffieldlabel varchar(200);
	declare cur1 CURSOR FOR SELECT producttoolfieldid ,fieldlabel  FROM  ld_producttoolfield;
	declare continue handler  for not   found  SET done =1;
	OPEN cur1;
	Fetch cur1 into ffieldid,ffieldlabel;

 	loop1: while  done<>1 DO
		set @sql=CONCAT('insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel) select ''zh'',''ld_producttoolfield'' ',',',ffieldid,',',ffieldid,',','''',ffieldlabel,'''  from dual where not exists(select 1 from ld_tranlabel where relateid=',ffieldid,' and languagetype=''zh'' and tabid=',ffieldid,' and trantable=''ld_producttoolfield''',')');

		prepare stmt from @sql;
	      execute stmt;
	      deallocate  prepare  stmt;
set @sql=CONCAT('insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel) select ''en'',''ld_producttoolfield'' ',',',ffieldid,',',ffieldid,',','''',ffieldlabel,'''  from dual where not exists(select 1 from ld_tranlabel where relateid=',ffieldid,' and languagetype=''en'' and tabid=',ffieldid,' and trantable=''ld_producttoolfield''',')');
		prepare stmt from @sql;
	      execute stmt;
	      deallocate  prepare  stmt;
		Fetch cur1 into ffieldid,ffieldlabel;
	end while loop1;
	close cur1;
end ||
delimiter;

-- ----------------------------
-- Procedure structure for `AddRole2Picklist`
-- ----------------------------
DROP PROCEDURE IF EXISTS `AddRole2Picklist`;
delimiter ||
CREATE  PROCEDURE `AddRole2Picklist`(
 PickName varchar(200)
)
begin
declare picklistValueid int;
declare done  int  default 0;
declare sSortID int default 0;
declare rroleid varchar(50) default '';
declare cur1 CURSOR FOR SELECT picklist_valueid FROM  test_view;
declare continue handler  for not   found  SET done =1;
set @sql=CONCAT('select picklistid into @picklistid  from ld_picklist where name=','''',PickName,'''');
prepare stmt from @sql;
execute stmt;
deallocate  prepare stmt;

set @testview=ConCAT(' drop view if exists test_view');

prepare stmt from @testview;
execute stmt;
deallocate prepare stmt;
set @sqlstr=' create view test_view as ';
set @sqlstr=CONCAT(@sqlstr,'  select  picklist_valueid from ld_',PickName);
prepare stmtt from @sqlstr;
execute stmtt;
deallocate  prepare stmtt;
OPEN cur1;
Fetch cur1 into picklistValueid;
 loop1: while  done<>1 DO
	set @sql =CONCAT('select max(sortid) into  @SortID from ld_role2picklist where roleid=''h1''',' and picklistid=',@picklistid);
	prepare stmt from @sql;
	execute stmt;
	deallocate prepare stmt;
	set sSortID=IFNULL(@SortID,0); 
	set sSortID=sSortID+1;

	set @strsql =CONCAT('select max( sortid) into @eroleid from  ld_role2picklist where roleid=''h1''','  and picklistvalueid=',picklistValueid);

	prepare stmtt from @strsql;
	execute stmtt;
	deallocate  prepare stmtt;
	set rroleid=IFNULL(@eroleid,'-1');
	if(rroleid='-1') then

		set @insertRole =CONCAT(' insert into ld_role2PickList(roleid,picklistvalueid,picklistid,sortid)values(''h1''',',',picklistValueid,',',@picklistid ,',',sSortID,')');
		prepare stmt from @insertRole;
		execute stmt;
		deallocate  prepare stmt;
	end if;

	Fetch cur1 into picklistValueid;
end while loop1;
close cur1;
end ||
delimiter;

-- ----------------------------
-- Procedure structure for `addseativityrelintoactivity`
-- ----------------------------
DROP PROCEDURE IF EXISTS `addseativityrelintoactivity`;
delimiter ||
CREATE  PROCEDURE `addseativityrelintoactivity`(
)
BEGIN
	declare done  int  default 0;

	declare ccrmid int ;
	declare aactivityid int;

	declare cur1 CURSOR FOR SELECT crmid,activityid FROM  ld_seactivityrel  ;
	declare continue handler  for not   found  SET done =1;
	OPEN cur1;
	Fetch cur1 into ccrmid,aactivityid;

 	loop1: while  done<>1 DO

		set @sql=CONCAT('select IFNULL(setype,'''') into @setype from ld_crmentity where crmid=',ccrmid);

		prepare stmt from @sql;
	  execute stmt;
	  deallocate  prepare  stmt;
	   if  @setype='Accounts' THEN
					set @sql=CONCAT('update ld_activity set accountid=',ccrmid,' where activityid=',aactivityid);

					prepare stmt from @sql;
					execute stmt;
					deallocate  prepare  stmt;
			end if;
    if  @setype='Potentials' THEN
					set @sql=CONCAT('update ld_activity set potentialid=',ccrmid,' where activityid=',aactivityid);
					prepare stmt from @sql;
					execute stmt;
					deallocate  prepare  stmt;
			end if;
		  if  @setype='Contacts' THEN
					set @sql=CONCAT('update ld_activity set contactid=',ccrmid,' where activityid=',aactivityid);
					prepare stmt from @sql;
					execute stmt;
					deallocate  prepare  stmt;
			end if;
		Fetch cur1 into ccrmid,aactivityid;
	end while loop1;
	close cur1;
end ||
delimiter;

-- ----------------------------
-- Procedure structure for `addtabintoprofile`
-- ----------------------------
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

-- ----------------------------
-- Procedure structure for `addtablabelintotrantable`
-- ----------------------------
DROP PROCEDURE IF EXISTS `addtablabelintotrantable`;
delimiter ||
CREATE  PROCEDURE `addtablabelintotrantable`(
)
BEGIN
	declare done  int  default 0;

	declare ffieldid int ;
	declare ttabid int;
	DECLARE ffieldlabel varchar(200);
	declare cur1 CURSOR FOR SELECT tabid,tabid ,newchinesename  FROM  ld_languagepackage ;
	declare continue handler  for not   found  SET done =1;
	OPEN cur1;
	Fetch cur1 into ffieldid,ttabid,ffieldlabel;

 	loop1: while  done<>1 DO
		set @sql=CONCAT('insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel) select ''zh'',''ld_tab'' ',',',ttabid,',',ffieldid,',','''',ffieldlabel,'''  from dual where not exists(select 1 from ld_tranlabel where relateid=',ffieldid,' and languagetype=''zh'' and tabid=',ttabid,' and trantable=''ld_tab''',')');
		

		prepare stmt from @sql;
	      execute stmt;
	      deallocate  prepare  stmt;

		Fetch cur1 into ffieldid,ttabid,ffieldlabel;
	end while loop1;
	close cur1;
end ||
delimiter;

-- ----------------------------
-- Procedure structure for `addtableIndex`
-- ----------------------------
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

-- ----------------------------
-- Procedure structure for `addtaxinfointotrantable`
-- ----------------------------
DROP PROCEDURE IF EXISTS `addtaxinfointotrantable`;
delimiter ||
CREATE  PROCEDURE `addtaxinfointotrantable`(
)
BEGIN
	declare done  int  default 0;

	declare ffieldid int ;
	declare ttabid int;
	DECLARE ffieldlabel varchar(200);
	declare cur1 CURSOR FOR SELECT taxid ,taxlabel  FROM  ld_inventorytaxinfo  ;
	declare continue handler  for not   found  SET done =1;
	OPEN cur1;
	Fetch cur1 into ffieldid,ffieldlabel;

 	loop1: while  done<>1 DO
		set @sql=CONCAT('insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel) select ''zh'',''ld_inventorytaxinfo'' ',',',ffieldid,',',ffieldid,',','''',ffieldlabel,'''  from dual where not exists(select 1 from ld_tranlabel where relateid=',ffieldid,' and languagetype=''zh'' and tabid=',ffieldid,' and trantable=''ld_inventorytaxinfo''',')');

		prepare stmt from @sql;
	      execute stmt;
	      deallocate  prepare  stmt;
	set @sql=CONCAT('insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel) select ''en'',''ld_inventorytaxinfo'' ',',',ffieldid,',',ffieldid,',','''',ffieldlabel,'''  from dual where not exists(select 1 from ld_tranlabel where relateid=',ffieldid,' and languagetype=''en'' and tabid=',ffieldid,' and trantable=''ld_inventorytaxinfo''',')');

		prepare stmt from @sql;
	      execute stmt;
	      deallocate  prepare  stmt;
		Fetch cur1 into ffieldid,ffieldlabel;
	end while loop1;
	close cur1;
end ||
delimiter;

-- ----------------------------
-- Procedure structure for `calendarprofile`
-- ----------------------------
DROP PROCEDURE IF EXISTS `calendarprofile`;
delimiter ||
CREATE  PROCEDURE `calendarprofile`(
)
begin

	declare done  int  default 0;
		declare pprofileid  int ;
	declare permissions int ;
	

	declare cur1 CURSOR FOR SELECT profileid  FROM  ld_profile;
	declare continue handler  for not   found  SET done =1;
	set @tabid=16;
	set permissions=0;
	
if(@tabid>0) then 
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
end if;
end ||
delimiter;

-- ----------------------------
-- Procedure structure for `ChangeColumn`
-- ----------------------------
DROP PROCEDURE IF EXISTS `ChangeColumn`;
delimiter ||
CREATE  PROCEDURE `ChangeColumn`(
-- tableschema varchar(50),
tablename varchar(50),
columnname varchar(50),
newname varchar(50),
columntype varchar(50),
columnlen int(5)
)
begin
select database() into @tableschema;
set tablename=lower(tablename);

SET @tsql=CONCAT('select count(*) into @colchange from information_schema.columns where  TABLE_SCHEMA =','''',@tableschema,'''','  and 

table_name= ','''',tablename,'''',' and column_name=','''',columnname,'''');

prepare stmt from @tsql;
execute stmt;
-- set @colchange=IFNULL(@column_name,'-1');

IF @colchange=1  THEN
 	if columntype='date'  or columntype='datetime' then 
		set @alterColumn=CONCAT('alter table ',tablename, ' change ',columnname, ' ', newname, ' ', columntype, ' ');
	else 
		set @alterColumn=CONCAT('alter table ',tablename, ' change ',columnname, ' ', newname, ' ', columntype, '(',columnlen,')');
	end if;
prepare stalter from @altercolumn;
execute stalter;

END IF;
end ||
delimiter;

-- ----------------------------
-- Procedure structure for `changeColumnTittle`
-- ----------------------------
DROP PROCEDURE IF EXISTS `changeColumnTittle`;
delimiter ||
CREATE  PROCEDURE `changeColumnTittle`(IN ptablename VARCHAR(50),IN pcolun1 VARCHAR(50),IN pcolun2 VARCHAR(50))
BEGIN 
select database() into @tableschema;
SELECT count(1) INTO @colName 
FROM information_schema.columns
WHERE TABLE_NAME = ptablename
AND COLUMN_NAME = pcolun1 
AND TABLE_SCHEMA=@tableschema;

IF @colName>0 THEN 
   set @sql = CONCAT('ALTER TABLE ld_troubletickets change ',pcolun1,' ',pcolun2,' varchar(200)');

prepare stmt from @sql; 
execute stmt; 
deallocate prepare stmt;
END IF;
end ||
delimiter;

-- ----------------------------
-- Procedure structure for `CopyModuleBlocks`
-- ----------------------------
DROP PROCEDURE IF EXISTS `CopyModuleBlocks`;
delimiter ||
CREATE  PROCEDURE `CopyModuleBlocks`(
	IN copymodule VARCHAR(100),
	IN tomodule VARCHAR(100)
)
BEGIN
	#Routine body goes here...
declare done  int  default 0;
DECLARE bl_blocklabel varchar (100);
DECLARE bl_sequence int;
DECLARE bl_visible int; 
DECLARE bl_create_view int;
DECLARE bl_edit_view int;
DECLARE bl_detail_view int;
DECLARE bl_display_status int;
DECLARE bl_iscustom int;

declare cur1 CURSOR FOR SELECT  blocklabel,sequence,visible,create_view,edit_view,detail_view,display_status,iscustom from ld_blocks where tabid = (select tabid from ld_tab where name = copymodule);
declare continue handler  for not   found  SET done =1;

select tabid into @tabid from ld_tab where `name` = tomodule;
select tabid into @accountid from ld_tab where `name` = copymodule;
select max(blockid) into @blockid from ld_blocks;

OPEN cur1;
Fetch cur1 into bl_blocklabel,bl_sequence,bl_visible,bl_create_view,bl_edit_view,bl_detail_view,bl_display_status,bl_iscustom;
 loop1: while  done<>1 DO
	set @blockid = @blockid +1;
	-- 插入ld_field
	insert into ld_blocks(blockid,tabid,blocklabel,sequence,visible,create_view,edit_view,detail_view,display_status,iscustom)
	select @blockid,@tabid,bl_blocklabel,bl_sequence,bl_visible,bl_create_view,bl_edit_view,bl_detail_view,bl_display_status,bl_iscustom 
	from dual  where not exists(select 1 from ld_blocks where tabid=@tabid and blocklabel = bl_blocklabel);

	-- 获取blockid
	select blockid into @isblockid from ld_blocks where tabid = @accountid and blocklabel = bl_blocklabel;
	
	-- 中文插入
	select ld_tranlabel.fieldlabel into @fieldlabel from ld_tranlabel where tabid = @accountid and Relateid = @isblockid and trantable = 'ld_blocks' and languagetype = 'zh';
	insert into ld_tranlabel(languagetype,trantable,tabid,Relateid,fieldlabel)
	select 'zh','ld_blocks',@tabid,@blockid,@fieldlabel from dual where not exists(select 1 from ld_tranlabel where tabid = @tabid and Relateid = @blockid and languagetype = 'zh');

	-- 英文插入
	select ld_tranlabel.fieldlabel into @fieldlabel from ld_tranlabel where tabid = @accountid and Relateid = @isblockid and trantable = 'ld_blocks' and languagetype = 'en';
	insert into ld_tranlabel(languagetype,trantable,tabid,Relateid,fieldlabel)
	select 'en','ld_blocks',@tabid,@blockid,@fieldlabel from dual where not exists(select 1 from ld_tranlabel where tabid = @tabid and Relateid = @blockid and languagetype = 'en');
	
Fetch cur1 into bl_blocklabel,bl_sequence,bl_visible,bl_create_view,bl_edit_view,bl_detail_view,bl_display_status,bl_iscustom;
end while loop1;
close cur1;

update ld_blocks_seq set id = (select max(blockid) from ld_blocks);

end ||
delimiter;

-- ----------------------------
-- Procedure structure for `CopyModuleField`
-- ----------------------------
DROP PROCEDURE IF EXISTS `CopyModuleField`;
delimiter ||
CREATE  PROCEDURE `CopyModuleField`(
	IN copymodule VARCHAR(100),
	IN tomodule VARCHAR(100)
)
BEGIN
	#Routine body goes here...
declare done  int  default 0;
declare is_columnname  varchar (30);
declare is_tablename varchar (50) ;
declare is_generatedtype int ;
declare is_uitype varchar (19);
declare is_fieldname varchar (50);
declare is_fieldlabel varchar (50) ;
declare is_readonly int;
declare is_presence int ;
declare is_defaultvalue text ;
declare is_maximumlength int;
declare is_sequence int;
declare is_block int;
declare is_displaytype int;
declare is_typeofdata varchar(100);
declare is_quickcreate int;
declare is_quickcreatesequence int;
declare is_info_type varchar (20);
declare is_masseditable int;
declare is_fieldonly int;
declare is_issmownerid int;
declare cur1 CURSOR FOR SELECT  columnname,tablename,generatedtype,uitype,fieldname,fieldlabel,readonly,presence,defaultvalue,maximumlength,sequence,block,
displaytype,typeofdata,quickcreate,quickcreatesequence,info_type,masseditable,fieldonly,issmownerid from ld_field where tabid = (select tabid from ld_tab where name = copymodule) and presence in (0,2);
declare continue handler  for not   found  SET done =1;

select tabid into @tabid from ld_tab where `name` = tomodule;
select tabid into @accountid from ld_tab where `name` = copymodule;
select max(fieldid) into @fieldid from ld_field;

OPEN cur1;
Fetch cur1 into is_columnname,is_tablename,is_generatedtype,is_uitype,is_fieldname,is_fieldlabel,is_readonly,is_presence,is_defaultvalue,is_maximumlength,is_sequence,is_block,
is_displaytype,is_typeofdata,is_quickcreate,is_quickcreatesequence,is_info_type,is_masseditable,is_fieldonly,is_issmownerid;
 loop1: while  done<>1 DO
	set @fieldid = @fieldid +1;
	-- 插入ld_field
	select blockid into @newblockid from ld_blocks where blocklabel = (select blocklabel from ld_blocks where blockid = is_block) and tabid = @tabid;
	insert into ld_field(tabid,fieldid,columnname,tablename,generatedtype,uitype,fieldname,fieldlabel,readonly,presence,defaultvalue,maximumlength,sequence,block,
	displaytype,typeofdata,quickcreate,quickcreatesequence,info_type,masseditable,fieldonly,issmownerid)
	select @tabid,@fieldid,is_columnname,is_tablename,is_generatedtype,is_uitype,is_fieldname,is_fieldlabel,is_readonly,is_presence,is_defaultvalue,is_maximumlength,is_sequence,@newblockid,
	is_displaytype,is_typeofdata,is_quickcreate,is_quickcreatesequence,is_info_type,is_masseditable,is_fieldonly,is_issmownerid from dual  where not exists(select 1 from ld_field where tabid=@tabid and columnname = is_columnname);
	-- 获取field
	select fieldid into @isfieldid from ld_field where tabid = @accountid and columnname = is_columnname;
	
	-- 中文插入
	select ld_tranlabel.fieldlabel into @fieldlabel from ld_tranlabel where tabid = @accountid and Relateid = @isfieldid and trantable = 'ld_field' and languagetype = 'zh';
	insert into ld_tranlabel(languagetype,trantable,tabid,Relateid,fieldlabel)
	select 'zh','ld_field',@tabid,@fieldid,@fieldlabel from dual where not exists(select 1 from ld_tranlabel where tabid = @tabid and fieldlabel = @fieldlabel and languagetype = 'zh');

	-- 英文插入
	select ld_tranlabel.fieldlabel into @fieldlabel from ld_tranlabel where tabid = @accountid and Relateid = @isfieldid and ld_tranlabel.trantable = 'ld_field' and languagetype = 'en';
	insert into ld_tranlabel(languagetype,trantable,tabid,Relateid,fieldlabel)
	select 'en','ld_field',@tabid,@fieldid,@fieldlabel from dual where not exists(select 1 from ld_tranlabel where tabid = @tabid and fieldlabel = @fieldlabel and languagetype = 'en');
 
Fetch cur1 into is_columnname,is_tablename,is_generatedtype,is_uitype,is_fieldname,is_fieldlabel,is_readonly,is_presence,is_defaultvalue,is_maximumlength,is_sequence,is_block,
is_displaytype,is_typeofdata,is_quickcreate,is_quickcreatesequence,is_info_type,is_masseditable,is_fieldonly,is_issmownerid;
end while loop1;
close cur1;

update ld_field_seq set id = (select max(fieldid) from ld_field);

end ||
delimiter;

-- ----------------------------
-- Procedure structure for `CopyModuleQuickActions`
-- ----------------------------
DROP PROCEDURE IF EXISTS `CopyModuleQuickActions`;
delimiter ||
CREATE  PROCEDURE `CopyModuleQuickActions`(
	IN copymodule VARCHAR(100),
	IN tomodule VARCHAR(100)
)
BEGIN
	#Routine body goes here...
declare done  int  default 0;
DECLARE qa_related_tabid int;
DECLARE qa_sequence int;
DECLARE qa_presence int; 
DECLARE qa_label varchar(100);
declare cur1 CURSOR FOR SELECT  related_tabid,sequence,presence,label from ld_quickactions where tabid = (select tabid from ld_tab where name = copymodule);
declare continue handler  for not   found  SET done =1;

select tabid into @tabid from ld_tab where `name` = tomodule;

OPEN cur1;
Fetch cur1 into qa_related_tabid,qa_sequence,qa_presence,qa_label;
 loop1: while  done<>1 DO
	-- 操作信息插入
	insert into ld_quickactions(tabid,related_tabid,sequence,presence,label)
	select @tabid,qa_related_tabid,qa_sequence,qa_presence,qa_label 
	from dual  where not exists(select 1 from ld_quickactions where tabid=@tabid and related_tabid = qa_related_tabid);

Fetch cur1 into qa_related_tabid,qa_sequence,qa_presence,qa_label;
end while loop1;
close cur1;

end ||
delimiter;

-- ----------------------------
-- Procedure structure for `CopyModuleRelatedLists`
-- ----------------------------
DROP PROCEDURE IF EXISTS `CopyModuleRelatedLists`;
delimiter ||
CREATE  PROCEDURE `CopyModuleRelatedLists`(
	IN copymodule VARCHAR(100),
	IN tomodule VARCHAR(100)
)
BEGIN
	#Routine body goes here...
declare done  int  default 0;
DECLARE rl_related_tabid int;
DECLARE rl_name varchar(100);
DECLARE rl_sequence int; 
DECLARE rl_label varchar(100);
DECLARE rl_presence int; 
DECLARE rl_actions varchar(100); 
declare cur1 CURSOR FOR SELECT  related_tabid,name,sequence,label,presence,actions from ld_relatedlists where tabid = (select tabid from ld_tab where name = copymodule);
declare continue handler  for not   found  SET done =1;

select tabid into @tabid from ld_tab where `name` = tomodule;
select max(relation_id) into @relation_id from ld_relatedlists;
OPEN cur1;
Fetch cur1 into rl_related_tabid,rl_name,rl_sequence,rl_label,rl_presence,rl_actions;
 loop1: while  done<>1 DO
	-- 相关信息插入
	set @relation_id = @relation_id +1;

	insert into ld_relatedlists(relation_id,tabid,related_tabid,name,sequence,label,presence,actions)
	select @relation_id+1,@tabid,rl_related_tabid,rl_name,rl_sequence,rl_label,rl_presence,rl_actions 
	from dual  where not exists(select 1 from ld_relatedlists where tabid=@tabid and related_tabid = rl_related_tabid);

Fetch cur1 into rl_related_tabid,rl_name,rl_sequence,rl_label,rl_presence,rl_actions;
end while loop1;
close cur1;

update ld_relatedlists_seq set id = (select max(relation_id) from ld_relatedlists);

end ||
delimiter;

-- ----------------------------
-- Procedure structure for `CopyPicklistDependency`
-- ----------------------------
DROP PROCEDURE IF EXISTS `CopyPicklistDependency`;
delimiter ||
CREATE  PROCEDURE `CopyPicklistDependency`(
	copymodule VARCHAR(100),
	tomodule VARCHAR(100)
)
BEGIN

	declare tmp_sourcefield  varchar(100) default '';
	declare tmp_targetfield  varchar(100) default '';
	declare tmp_sourcevalue  varchar(100) default '';
	declare tmp_targetvalues text;
		
	declare mycursor cursor for select sourcefield,targetfield,sourcevalue,targetvalues from ld_picklist_dependency where tabid=(select tabid from ld_tab where `name`=copymodule); 
	DECLARE CONTINUE HANDLER FOR SQLSTATE '02000' set tmp_sourcefield = NULL;
	
	select tabid into @tabid from ld_tab where `name`=tomodule;

	open mycursor;
	fetch mycursor into tmp_sourcefield,tmp_targetfield,tmp_sourcevalue,tmp_targetvalues;
	while(tmp_sourcefield is not null) DO
			select max(id) into @id from ld_picklist_dependency;
			delete from ld_picklist_dependency where tabid=@tabid and sourcefield=tmp_sourcefield and targetfield=tmp_targetfield and sourcevalue=tmp_sourcevalue;

			insert into ld_picklist_dependency(id,tabid,sourcefield,targetfield,sourcevalue,targetvalues)
			select @id+1,@tabid,tmp_sourcefield,tmp_targetfield,tmp_sourcevalue,tmp_targetvalues;

			fetch mycursor into tmp_sourcefield,tmp_targetfield,tmp_sourcevalue,tmp_targetvalues;
	end while;
	close mycursor;

	update ld_picklist_dependency_seq set id=(select max(id) from ld_picklist_dependency);

end ||
delimiter;

-- ----------------------------
-- Procedure structure for `DelColumn`
-- ----------------------------
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

-- ----------------------------
-- Procedure structure for `delcrmentityfld`
-- ----------------------------
DROP PROCEDURE IF EXISTS `delcrmentityfld`;
delimiter ||
CREATE  PROCEDURE `delcrmentityfld`( 

)
BEGIN 
SELECT DATABASE() INTO @tableschema; 
set @ptablename = 'ld_crmentity'; 
SET @tsql=CONCAT('select COUNT(column_name) INTO @colcount from information_schema.columns where TABLE_SCHEMA = "',@tableschema,'" and table_name= "',@ptablename,'";'); 
PREPARE stmt FROM @tsql; 
EXECUTE stmt; 
DEALLOCATE PREPARE stmt; 
IF @colcount = 13 THEN 

set @psql = CONCAT('ALTER TABLE ',@ptablename,' DROP COLUMN smownerid;'); 
PREPARE stmt FROM @psql; 
EXECUTE stmt; 
DEALLOCATE PREPARE stmt; 

set @psql = CONCAT('ALTER TABLE ',@ptablename,' DROP COLUMN smcreatorid;'); 
PREPARE stmt FROM @psql; 
EXECUTE stmt; 
DEALLOCATE PREPARE stmt; 

set @psql = CONCAT('ALTER TABLE ',@ptablename,' DROP COLUMN modifiedby;'); 
PREPARE stmt FROM @psql; 
EXECUTE stmt; 
DEALLOCATE PREPARE stmt; 

set @psql = CONCAT('ALTER TABLE ',@ptablename,' DROP COLUMN createdtime;'); 
PREPARE stmt FROM @psql; 
EXECUTE stmt; 
DEALLOCATE PREPARE stmt; 

set @psql = CONCAT('ALTER TABLE ',@ptablename,' DROP COLUMN modifiedtime;'); 
PREPARE stmt FROM @psql; 
EXECUTE stmt; 
DEALLOCATE PREPARE stmt; 

set @psql = CONCAT('ALTER TABLE ',@ptablename,' DROP COLUMN viewedtime;'); 
PREPARE stmt FROM @psql; 
EXECUTE stmt; 
DEALLOCATE PREPARE stmt; 

set @psql = CONCAT('ALTER TABLE ',@ptablename,' DROP COLUMN description;'); 
PREPARE stmt FROM @psql; 
EXECUTE stmt; 
DEALLOCATE PREPARE stmt; 

set @psql = CONCAT('ALTER TABLE ',@ptablename,' DROP COLUMN status;'); 
PREPARE stmt FROM @psql; 
EXECUTE stmt; 
DEALLOCATE PREPARE stmt; 

set @psql = CONCAT('ALTER TABLE ',@ptablename,' DROP COLUMN version;'); 
PREPARE stmt FROM @psql; 
EXECUTE stmt; 
DEALLOCATE PREPARE stmt; 

set @psql = CONCAT('ALTER TABLE ',@ptablename,' DROP COLUMN presence;'); 
PREPARE stmt FROM @psql; 
EXECUTE stmt; 
DEALLOCATE PREPARE stmt; 

set @psql = CONCAT('ALTER TABLE ',@ptablename,' DROP COLUMN deleted;'); 
PREPARE stmt FROM @psql; 
EXECUTE stmt; 
DEALLOCATE PREPARE stmt; 

END IF; 

end ||
delimiter;

-- ----------------------------
-- Procedure structure for `DelPrikey`
-- ----------------------------
DROP PROCEDURE IF EXISTS `DelPrikey`;
delimiter ||
CREATE  PROCEDURE `DelPrikey`(
tablename varchar(50)
)
begin

select database() into @tableschema;  -- 获取数据库实体
SET @sql1=CONCAT("select count(column_key) into @del from information_schema.columns where table_schema='",@tableschema,"' and table_name='",tablename,"' and column_key='PRI'");
SET @sql2=CONCAT('alter table ',tablename,' drop primary key');

PREPARE statement_name FROM @sql1; 
EXECUTE statement_name;
DEALLOCATE PREPARE statement_name;

IF @del>0 THEN 
	PREPARE statement_name FROM @sql2; 
	EXECUTE statement_name;
	DEALLOCATE PREPARE statement_name;
END IF;

end ||
delimiter;

-- ----------------------------
-- Procedure structure for `deltepotstagehistory`
-- ----------------------------
DROP PROCEDURE IF EXISTS `deltepotstagehistory`;
delimiter ||
CREATE  PROCEDURE `deltepotstagehistory`(

)
begin
   
		declare tmp_historyid int default 0;
		declare tmp_potentialid int default 0;
		declare tmp_stage varchar(200) default null;	
		declare mycursor cursor for select historyid,potentialid,stage from ld_potstagehistory;
		DECLARE CONTINUE HANDLER FOR SQLSTATE '02000' set tmp_historyid = NULL;
		
		CREATE TABLE IF NOT EXISTS `ld_potstagehistory_back` (
			`historyid` int(19) NOT NULL,
			`potentialid` int(19) NOT NULL,
			`amount` decimal(10,0) DEFAULT NULL,
			`stage` varchar(100) DEFAULT NULL,
			`probability` decimal(7,3) DEFAULT NULL,
			`expectedrevenue` decimal(10,0) DEFAULT NULL,
			`closedate` date DEFAULT NULL,
			`lastmodified` datetime DEFAULT NULL,
			`sales_stage` varchar(100) DEFAULT NULL,
			`smownerid` int(11) DEFAULT NULL
		)	ENGINE=InnoDB DEFAULT CHARSET=utf8;

		DROP TABLE IF EXISTS `ld_test01`;
		CREATE TABLE `ld_test01` (
			`id` int(19) NOT NULL
		)	ENGINE=InnoDB DEFAULT CHARSET=utf8;

		select ifnull(max(historyid),0) into @maxhistoryid from ld_potstagehistory_back;
		insert into ld_potstagehistory_back
		select historyid,potentialid,amount,stage,probability,expectedrevenue,closedate,lastmodified,
					 sales_stage,smownerid from ld_potstagehistory where historyid>@maxhistoryid;

		delete from ld_potstagehistory where stage=sales_stage;

		open mycursor;
		fetch mycursor into tmp_historyid,tmp_potentialid,tmp_stage;
		while(tmp_historyid is not null) DO	
				select ifnull(min(historyid),0) into @historyid from ld_potstagehistory where potentialid=tmp_potentialid and historyid>tmp_historyid order by historyid;
				select ifnull(max(historyid),0) into @cn from ld_potstagehistory where historyid=@historyid and stage=tmp_stage;
				if @cn>0 then 
					insert into ld_test01 select @cn;
				end if;
				fetch mycursor into tmp_historyid,tmp_potentialid,tmp_stage;
		end while;
		close mycursor;
		delete from ld_potstagehistory where historyid in (select id from ld_test01);
		drop table ld_test01;

end ||
delimiter;

-- ----------------------------
-- Procedure structure for `DEL_FK`
-- ----------------------------
DROP PROCEDURE IF EXISTS `DEL_FK`;
delimiter ||
CREATE  PROCEDURE `DEL_FK`(
	tablename varchar(200), 
	fkname varchar(200)
)
BEGIN
  SELECT DATABASE() INTO @tableschema;
	SET tablename=LOWER(tablename);
	
	set@cnt=0;
  SET @tsql=CONCAT(' alter table ', tablename, ' drop foreign key ', fkname);
  select count(*) INTO @cnt FROM information_schema.key_column_usage WHERE TABLE_NAME=tablename and CONSTRAINT_NAME=fkname and TABLE_SCHEMA=@tableschema;
  IF @cnt >0 THEN
    PREPARE stmt FROM @tsql;
    EXECUTE stmt;
  END IF;
end ||
delimiter;

-- ----------------------------
-- Procedure structure for `del_idx`
-- ----------------------------
DROP PROCEDURE IF EXISTS `del_idx`;
delimiter ||
CREATE  PROCEDURE `del_idx`(
 p_idxname varchar(100),
 p_tablename varchar(50)
)
begin  
DECLARE str VARCHAR(250);  
  set @str=concat(' drop index ',p_idxname,' on ',p_tablename);   
    select database() into @tableschema;

 set @strcount=concat('select count(*) into @cnt from information_schema.statistics where table_name=''',p_tablename,''' and index_name=''',p_idxname,'''  and table_schema=''',@tableschema,'''');  

  PREPARE stmtt FROM @strcount;  
    EXECUTE stmtt ;    
if @cnt >0 then   
    PREPARE stmt FROM @str;  
    EXECUTE stmt ;  
  end if;  
end ||
delimiter;

-- ----------------------------
-- Procedure structure for `enaddfieldlabelintotrantable`
-- ----------------------------
DROP PROCEDURE IF EXISTS `enaddfieldlabelintotrantable`;
delimiter ||
CREATE  PROCEDURE `enaddfieldlabelintotrantable`(
)
BEGIN
	declare done  int  default 0;
	declare ffieldid int ;
	declare ttabid int;
	DECLARE ffieldlabel varchar(200);
	declare cur1 CURSOR FOR SELECT fieldid,tabid ,columnname  FROM  ld_field;
	declare continue handler  for not   found  SET done =1;
	OPEN cur1;
	Fetch cur1 into ffieldid,ttabid,ffieldlabel;

 	loop1: while  done<>1 DO
		set @sql=CONCAT('insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel) select ''en'',''ld_field'' ',',',ttabid,',',ffieldid,',','''',ffieldlabel,'''  from dual where not exists(select 1 from ld_tranlabel where relateid=',ffieldid,' and languagetype=''en'' and tabid=',ttabid,' and trantable=''ld_field''',')');

		prepare stmt from @sql;
	      execute stmt;
	      deallocate  prepare  stmt;

		Fetch cur1 into ffieldid,ttabid,ffieldlabel;
	end while loop1;
	close cur1;
end ||
delimiter;

-- ----------------------------
-- Procedure structure for `fieldintoprofile`
-- ----------------------------
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

-- ----------------------------
-- Procedure structure for `fieldprofile`
-- ----------------------------
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

-- ----------------------------
-- Procedure structure for `f_addTableKeyIndex`
-- ----------------------------
DROP PROCEDURE IF EXISTS `f_addTableKeyIndex`;
delimiter ||
CREATE  PROCEDURE `f_addTableKeyIndex`(
	tablename 	VARCHAR(50),
	columnlist 	VARCHAR(50)
)
BEGIN
	SELECT DATABASE() INTO @datebase;
	SET @sql1 = CONCAT('select count(*) into @cnt from information_schema.statistics where table_name=''',tablename,''' and index_name=''PRIMARY''  and table_schema=''',@datebase,'''');
	PREPARE statement_name FROM @sql1;
		EXECUTE statement_name;
	DEALLOCATE PREPARE statement_name;
	IF @cnt = 0 THEN
		SET @sql = CONCAT('alter  table ',tablename,' add  PRIMARY KEY(',columnlist,')' );
		PREPARE statement_name FROM @sql;
			EXECUTE statement_name;
		DEALLOCATE PREPARE statement_name;
	END IF;
end ||
delimiter;

-- ----------------------------
-- Procedure structure for `getallprofile`
-- ----------------------------
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

-- ----------------------------
-- Procedure structure for `GetAllRoleIntoPicklist`
-- ----------------------------
DROP PROCEDURE IF EXISTS `GetAllRoleIntoPicklist`;
delimiter ||
CREATE  PROCEDURE `GetAllRoleIntoPicklist`(
PickName varchar(50)
)
begin
declare done  int  default 0;
declare rroleid varchar(50);
declare curw CURSOR FOR SELECT roleid FROM  ld_Role;

declare continue handler  for not   found  SET done =1;
OPEN curw;
Fetch curw into rroleid;
 loop1: while  done<>1 DO

   call InsertRole2picklist(PickName,rroleid);

	Fetch curw into rroleid;
end while loop1;
close curw;
end ||
delimiter;

-- ----------------------------
-- Procedure structure for `insertReader`
-- ----------------------------
DROP PROCEDURE IF EXISTS `insertReader`;
delimiter ||
CREATE  PROCEDURE `insertReader`()
BEGIN
	SELECT DATABASE() INTO @tableschema;
	SET @tablename='ld_workreport';
	SET @colName=NULL;
  SET @columnname='reader';
	SET @tsql=CONCAT('select  IFNULL(column_name, '''') into @colName  from information_schema.columns where  TABLE_SCHEMA =','''',@tableschema,'''','  and
	table_name= ','''',@tablename,'''',' and COLUMN_NAME=','''',@columnname,'''');
	PREPARE stmt FROM @tsql;
	EXECUTE stmt;
    DEALLOCATE PREPARE stmt;
	SET @colinsert=IFNULL(@colName,'-1');
	IF @colinsert = 'reader' THEN

	insert into ld_workreport2user(workreportid,userid,user_type) select workreportid,reader,5 from ld_workreport;


	END IF;
end ||
delimiter;

-- ----------------------------
-- Procedure structure for `InsertRole2picklist`
-- ----------------------------
DROP PROCEDURE IF EXISTS `InsertRole2picklist`;
delimiter ||
CREATE  PROCEDURE `InsertRole2picklist`(
PickName varchar(50),
RoleID varchar(50)
)
begin
declare picklistValueid int;
declare done  int  default 0;
declare sSortID int default 0;
declare rroleid varchar(50);

declare cur1 CURSOR FOR SELECT picklist_valueid FROM  test_view;

declare continue handler  for not   found  SET done =1;
set @sql=CONCAT('select picklistid into @picklistid  from ld_picklist where name=','''',PickName,'''');
prepare stmt from @sql;
execute stmt;
deallocate  prepare stmt;

set @testview=ConCAT(' drop view if exists test_view');

prepare stmt from @testview;
execute stmt;
deallocate prepare stmt;
set @sqlstr=' create view test_view as ';
set @sqlstr=CONCAT(@sqlstr,'  select  picklist_valueid from ld_',PickName);
prepare stmtt from @sqlstr;
execute stmtt;
deallocate  prepare stmtt;
OPEN cur1;
Fetch cur1 into picklistValueid;
 loop1: while  done<>1 DO
	set @sql =CONCAT('select max(sortid) into  @SortID from ld_role2picklist where roleid=' ,'''',RoleID,'''',' and picklistid=',@picklistid);
	prepare stmt from @sql;
	execute stmt;
	deallocate prepare stmt;
	set sSortID=IFNULL(@SortID,0); 
	set sSortID=sSortID+1;

	set @strsql =CONCAT('select max( sortid) into @eroleid from  ld_role2picklist where roleid=','''',RoleID,'''','  and picklistvalueid=',picklistValueid);

	prepare stmtt from @strsql;
	execute stmtt;
	deallocate  prepare stmtt;
	set rroleid=IFNULL(@eroleid,'-1');
	if(rroleid='-1') then

		set @insertRole =CONCAT(' insert into ld_role2PickList(roleid,picklistvalueid,picklistid,sortid)values(','''',RoleID,'''',',',picklistValueid,',',@picklistid ,',',sSortID,')');
select @insertRole;
		prepare stmt from @insertRole;
		execute stmt;
		deallocate  prepare stmt;
	end if;

	Fetch cur1 into picklistValueid;
end while loop1;
close cur1;
end ||
delimiter;

-- ----------------------------
-- Procedure structure for `insertWorkreply`
-- ----------------------------
DROP PROCEDURE IF EXISTS `insertWorkreply`;
delimiter ||
CREATE  PROCEDURE `insertWorkreply`()
BEGIN
	SELECT DATABASE() INTO @tableschema;
	IF EXISTS (select 1 from information_schema.`TABLES` where TABLE_SCHEMA = @tableschema and TABLE_NAME = 'ld_workreportreader') then
		insert into ld_workreply(workreportid,text,replyuserid,createdtime,type)
		select workreportid,  content,userid,createdtime,1 from ld_workreportreader;

  END IF;
end ||
delimiter;

-- ----------------------------
-- Procedure structure for `insertWorkreply2user`
-- ----------------------------
DROP PROCEDURE IF EXISTS `insertWorkreply2user`;
delimiter ||
CREATE  PROCEDURE `insertWorkreply2user`()
BEGIN
	SELECT DATABASE() INTO @tableschema;
	IF EXISTS (select 1 from information_schema.`TABLES` where TABLE_SCHEMA = @tableschema and TABLE_NAME = 'ld_workreportreader2user') then
		insert into ld_workreply2user(workreplyid,userid,user_type)
		select workreportreaderid,userid,1 from ld_workreportreader2user;

	END IF;
end ||
delimiter;

-- ----------------------------
-- Procedure structure for `insert_templatesstuff`
-- ----------------------------
DROP PROCEDURE IF EXISTS `insert_templatesstuff`;
delimiter ||
CREATE  PROCEDURE `insert_templatesstuff`(IN pstuffid int,IN pstufftype VARCHAR(100),IN pseq int,IN pstufftitle VARCHAR(100))
BEGIN 
DECLARE done int DEFAULT 0; 
DECLARE ptemplateid int(11); 
DECLARE profileobj CURSOR FOR SELECT templateid from ld_templates; 

DECLARE CONTINUE HANDLER for not found set done = 1; 
OPEN profileobj; 
	fetch profileobj into ptemplateid; 
	LOOP1: WHILE done <> 1 DO 
		set @sql = CONCAT('insert into ld_templatesstuff(stuffId,templateid,Stufftype,stuffsequence,stufftitle) select ',pstuffid,',',ptemplateid,',"',pstufftype,'",',pseq,',"',pstufftitle,'" from dual where not EXISTS (select 1 from ld_templatesstuff where templateid = ',ptemplateid,' and stufftitle = "',pstufftitle,'")');
		prepare stmt from @sql;
			execute stmt; 
		deallocate prepare stmt; 
		fetch profileobj into ptemplateid; 
	END WHILE LOOP1;
close profileobj; 

end ||
delimiter;

-- ----------------------------
-- Procedure structure for `modifyproducttoolfield`
-- ----------------------------
DROP PROCEDURE IF EXISTS `modifyproducttoolfield`;
delimiter ||
CREATE  PROCEDURE `modifyproducttoolfield`(
)
BEGIN
	
select columnname into @columnname from  ld_producttoolfield where fieldlabel='描述' and presence=0;
set @sql=CONCAT('alter table ld_inventoryproductrelscf modify column ',@columnname,' text');


if @columnname is not null then
		update ld_producttoolfield set uitype=19,typeofdata='V~O' where fieldlabel='描述' and presence=0;
		prepare stmt from @sql;
	  execute stmt;
	  deallocate  prepare  stmt;
end if;

end ||
delimiter;

-- ----------------------------
-- Procedure structure for `Select_Customview_Insertinto_tabwithproductview`
-- ----------------------------
DROP PROCEDURE IF EXISTS `Select_Customview_Insertinto_tabwithproductview`;
delimiter ||
CREATE  PROCEDURE `Select_Customview_Insertinto_tabwithproductview`()
BEGIN  
declare done int default 0; 
declare p_tabid int default 0; 
declare p_cvid int default 0; 
declare p_name varchar(100);
declare p_cnt int default 0; 
declare p_columnindex int DEFAULT 0; 
declare p_columnname varchar(100); 
declare isCount int default 0; 
declare cvcolumnCount int default 0; 

declare cur1 CURSOR FOR select tabid,cvid,`name` from ld_tab inner join ld_customview on ld_tab.`name` = ld_customview.entitytype where ld_tab.`name` in ('Checks','PurchaseCashBack','PurchaseBack','SalesBack','CashBack','Quotes'); 
declare continue handler for not found SET done =1; 

open cur1; 
fetch cur1 into p_tabid,p_cvid,p_name;
loop2: while done<>1 do 
	select count(1) into p_cnt from ld_tabwithproductview where tabid = p_tabid and cvid = p_cvid; 
	if p_cnt = 0 then 
		set isCount=0; 
		set cvcolumnCount = (select count(1) from ld_cvcolumnlist where cvid = p_cvid); 
		while isCount < cvcolumnCount 
		do 
			set @psql = CONCAT('select columnindex,columnname into @p_columnindex,@p_columnname from ld_cvcolumnlist where cvid = ',p_cvid,' order by columnindex asc limit ',isCount,',1;'); 
			prepare stmt from @psql; 
			execute stmt; 
			deallocate prepare stmt;
			set @psql = CONCAT('insert into ld_tabwithproductview(tabid,columns,sequence,cvid) values (',p_tabid,',"',@p_columnname,'",',@p_columnindex,',',p_cvid,');'); 
			prepare stmt from @psql; 
			execute stmt; 
			deallocate prepare stmt;
			set isCount = isCount + 1; 
		end while; 
	end if;
	if(p_name = 'SalesBack')
	then
		update ld_tabwithproductview set `columns` = REPLACE(`columns`,'ld_crmentity','ld_sashback') where cvid = p_cvid;
	elseif(p_name = 'CashBack')
	THEN
		update ld_tabwithproductview set `columns` = REPLACE(`columns`,'ld_crmentity','ld_cashback') where cvid = p_cvid;
	elseif(p_name = 'Checks')
	THEN
		update ld_tabwithproductview set `columns` = REPLACE(`columns`,'ld_crmentity','ld_checks') where cvid = p_cvid;
	elseif(p_name = 'PurchaseBack')
	THEN
		update ld_tabwithproductview set `columns` = REPLACE(`columns`,'ld_crmentity','ld_purchaseback') where cvid = p_cvid;
	elseif(p_name = 'PurchaseCashBack')
	THEN
		update ld_tabwithproductview set `columns` = REPLACE(`columns`,'ld_crmentity','ld_purchasecashback') where cvid = p_cvid;
	end if;

fetch cur1 into p_tabid,p_cvid,p_name;
end while loop2; 
close cur1; 
end ||
delimiter;

-- ----------------------------
-- Procedure structure for `setServiceGroupSequence`
-- ----------------------------
DROP PROCEDURE IF EXISTS `setServiceGroupSequence`;
delimiter ||
CREATE  PROCEDURE `setServiceGroupSequence`(

)
begin

	declare done  int  default 0;
	declare sequence  int default 1;
	declare pservicegroupid int ;


	declare cur2 CURSOR FOR SELECT servicegroupid FROM ld_servicegroup order by sequence;
	declare continue handler  for not   found  SET done =1;
	open cur2;
	fetch cur2 into pservicegroupid;
	loop2: while  done<>1 DO

		update ld_servicegroup set sequence = sequence where servicegroupid = pservicegroupid;
	  set sequence = sequence + 1;
		
	fetch cur2 into pservicegroupid;
	end while loop2;
	close cur2;
end ||
delimiter;

-- ----------------------------
-- Procedure structure for `update9permissionto16`
-- ----------------------------
DROP PROCEDURE IF EXISTS `update9permissionto16`;
delimiter ||
CREATE  PROCEDURE `update9permissionto16`(
)
begin
declare done  int  default 0;
	DECLARE permission int;
	declare pprofileid int ;
	declare cur2 CURSOR FOR SELECT profileid from ld_profile;
	declare continue handler  for not   found  SET done =1;

	OPEN cur2;
	Fetch cur2 into pprofileid;

 	loop1: while  done<>1 DO
		set @sql= CONCAT('select IFNULL(permissions,-1) into @permissions from ld_profile2standardpermissions where profileid=',pprofileid,' and operation=0  and  tabid=16');
		prepare stmt from @sql;
	  execute stmt;
	 deallocate  prepare  stmt;	
		if(@permissions='-1') THEN	
				set @sql1= CONCAT('update  ld_profile2standardpermissions set tabid=16  where profileid=',pprofileid,'  and tabid=9');
					prepare stmt from @sql1;
					execute stmt;
				 deallocate  prepare  stmt;	
		 end if;
	set @sql= CONCAT('select IFNULL(tabid ,-1) into @tabid from ld_profile2tab where profileid=',pprofileid,' and  tabid=16');
		prepare stmt from @sql;
	  execute stmt;
	 deallocate  prepare  stmt;	
		if(@tabid='-1') THEN	
				set @sql1= CONCAT('update  ld_profile2tab set tabid=16  where profileid=',pprofileid,' and  tabid=9');
					prepare stmt from @sql1;
					execute stmt;
				 deallocate  prepare  stmt;	
		 end if;
		set @sql= CONCAT('select IFNULL(permissions,-1) into @permissions from ld_profile2standardpermissions where profileid=',pprofileid,' and operation=0 and tabid=9');
		prepare stmt from @sql;
	  execute stmt;
	 deallocate  prepare  stmt;	
 if(@permissions<>'-1') THEN	
	  
			
					set @sql1= CONCAT('update  ld_profile2standardpermissions set permissions=',@permissions,' where profileid=',pprofileid,' and operation=0 and tabid=16');
					prepare stmt from @sql1;
					execute stmt;
				 deallocate  prepare  stmt;	

					set @sql= CONCAT('select permissions into @permissions from ld_profile2standardpermissions where profileid=',pprofileid,' and operation=1 and tabid=16');
					prepare stmt from @sql;
					execute stmt;
				 deallocate  prepare  stmt;	
					set @sql1= CONCAT('update  ld_profile2standardpermissions set permissions=',@permissions,' where profileid=',pprofileid,' and operation=1 and tabid=16');
					prepare stmt from @sql1;
					execute stmt;
				 deallocate  prepare  stmt;	

					set @sql= CONCAT('select permissions into @permissions from ld_profile2standardpermissions where profileid=',pprofileid,' and operation=2 and tabid=16');
					prepare stmt from @sql;
					execute stmt;
				 deallocate  prepare  stmt;	
					set @sql1= CONCAT('update  ld_profile2standardpermissions set permissions=',@permissions,' where profileid=',pprofileid,' and operation=2 and tabid=16');
					prepare stmt from @sql1;
					execute stmt;
				 deallocate  prepare  stmt;	

					set @sql= CONCAT('select permissions into @permissions from ld_profile2standardpermissions where profileid=',pprofileid,' and operation=3 and tabid=9');
					prepare stmt from @sql;
					execute stmt;
				 deallocate  prepare  stmt;	
					set @sql1= CONCAT('update  ld_profile2standardpermissions set permissions=',@permissions,' where profileid=',pprofileid,' and operation=3 and tabid=16');
					prepare stmt from @sql1;
					execute stmt;
				 deallocate  prepare  stmt;	



					set @sql= CONCAT('select IFNULL(permissions,-1) into @permissions from ld_profile2standardpermissions where profileid=',pprofileid,' and operation=4 and tabid=9');
					prepare stmt from @sql;
					execute stmt;
				 deallocate  prepare  stmt;	
					set @sql1= CONCAT('update  ld_profile2standardpermissions set permissions=',@permissions,' where profileid=',pprofileid,' and operation=4 and tabid=16');
					prepare stmt from @sql1;
					execute stmt;
				 deallocate  prepare  stmt;	

					 
					set @sql= CONCAT('select permissions into @permissions from ld_profile2standardpermissions where profileid=',pprofileid,' and operation=11 and tabid=9');
					prepare stmt from @sql;
					execute stmt;
				 deallocate  prepare  stmt;	
					set @sql1= CONCAT('update  ld_profile2standardpermissions set permissions=',@permissions,' where profileid=',pprofileid,' and operation=11 and tabid=16');
					prepare stmt from @sql1;
					execute stmt;
				 deallocate  prepare  stmt;	
	
			   
		end if;
			
	Fetch cur2 into pprofileid;
	end while loop1;
	close cur2;
end ||
delimiter;

-- ----------------------------
-- Procedure structure for `updatecaidandingzhi`
-- ----------------------------
DROP PROCEDURE IF EXISTS `updatecaidandingzhi`;
delimiter ||
CREATE  PROCEDURE `updatecaidandingzhi`(

)
begin

CREATE TABLE if not EXISTS digits (digit INT(1));
INSERT INTO digits
VALUES
(0),
(1),
(2),
(3),
(4),
(5),
(6),
(7),
(8),
(9);
CREATE TABLE if not EXISTS sequence (seq INT(3));
INSERT INTO sequence (
SELECT
D1.digit + D2.digit * 10
FROM
digits D1
CROSS JOIN digits D2
);

CREATE TABLE if not exists `parenttab` (
`parenttabid` int(19) NOT NULL,
`menu_profieldid` varchar(255) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

insert into parenttab
select parenttabid,
SUBSTRING_INDEX(SUBSTRING_INDEX(menu_profieldid, ',', seq),',' ,- 1) as menu_profieldid
from sequence cross join ld_parenttab
where
seq BETWEEN 1
AND (
SELECT
1 + LENGTH(menu_profieldid) - LENGTH(REPLACE(menu_profieldid, ',', ''))
)
ORDER BY
parenttabid,
menu_profieldid;

update parenttab inner join ld_role2profile ON parenttab.menu_profieldid=ld_role2profile.roleid set parenttab.menu_profieldid=ld_role2profile.profileid;

update ld_parenttab inner join
(select parenttabid,group_concat(menu_profieldid) as menu_profieldid1 from (select DISTINCT parenttabid,menu_profieldid from parenttab group by parenttabid,menu_profieldid) as parenttab group by parenttabid) as t1
on t1.parenttabid=ld_parenttab.parenttabid set ld_parenttab.menu_profieldid=t1.menu_profieldid1;

drop table digits;
drop table sequence;
drop table parenttab;
end ||
delimiter;

-- ----------------------------
-- Procedure structure for `updatecolumnindex`
-- ----------------------------
DROP PROCEDURE IF EXISTS `updatecolumnindex`;
delimiter ||
CREATE  PROCEDURE `updatecolumnindex`(

)
begin


	declare tmp_cvid  int default 0;
	declare tmp_columnindex  int default 0;
	declare tmp_columnname  varchar(200) default '';
	
	declare cvindex 	int  default 0;
	declare mycursor cursor for select cvid, columnindex,columnname from ld_cvcolumnlist order by cvid,columnindex; 
	DECLARE CONTINUE HANDLER FOR SQLSTATE '02000' set tmp_cvid = NULL;

	update ld_cvcolumnlist set columnindex=columnindex+20;
	
	open mycursor;
	fetch mycursor into tmp_cvid,tmp_columnindex,tmp_columnname;
	while(tmp_cvid is not null) DO
			update ld_cvcolumnlist set columnindex=cvindex where cvid=tmp_cvid and columnindex=tmp_columnindex;

			if exists (select 1 from ld_cvcolumnlist where cvid=tmp_cvid and columnindex>=tmp_columnindex+1) then
					set cvindex=cvindex+1;
			else
					set cvindex=0;
			end if;

			fetch mycursor into tmp_cvid,tmp_columnindex,tmp_columnname;
	end while;
	close mycursor;
end ||
delimiter;

-- ----------------------------
-- Procedure structure for `updatecontactscolumnindex`
-- ----------------------------
DROP PROCEDURE IF EXISTS `updatecontactscolumnindex`;
delimiter ||
CREATE  PROCEDURE `updatecontactscolumnindex`(

)
begin

	declare tmp_cvid  int default 0;
	
	declare mycursor cursor for select cvid from ld_customview where entitytype='Contacts'; 
	DECLARE CONTINUE HANDLER FOR SQLSTATE '02000' set tmp_cvid = NULL;
	
	open mycursor;
	fetch mycursor into tmp_cvid;
	while(tmp_cvid is not null) DO
			
			update ld_cvcolumnlist set columnindex=columnindex+100 where cvid=tmp_cvid;
			update ld_cvcolumnlist set columnindex=0 where cvid=tmp_cvid and columnname like 'ld_contactdetails:lastname:lastname:%';
			
			set @i=0;
			update ld_cvcolumnlist set columnindex=(@i:=@i+1) where cvid=tmp_cvid order by columnindex;

			fetch mycursor into tmp_cvid;
	end while;
	close mycursor;
end ||
delimiter;

-- ----------------------------
-- Procedure structure for `UpdateInvoiceIntoCashBill`
-- ----------------------------
DROP PROCEDURE IF EXISTS `UpdateInvoiceIntoCashBill`;
delimiter ||
CREATE  PROCEDURE `UpdateInvoiceIntoCashBill`(

)
begin
declare done  int  default 0;
declare iinvoiceid int ;
declare iaccountid int ;
declare isalesorderid int;
declare iinvoicedate date;
declare ismownerid int ;
declare itotal int;
declare isubtotal int ;
declare ismcreatorid int ;
declare cur1 CURSOR FOR SELECT  ld_invoice.invoiceid,ld_invoice.accountid ,ld_invoice.salesorderid,ld_invoice.invoicedate,ld_invoice.total,ld_invoice.subtotal,
 ld_crmentity.smownerid ,ld_crmentity.smcreatorid  FROM  ld_Invoice inner join ld_crmentity on ld_crmentity.crmid=ld_Invoice.invoiceid
 where ld_crmentity.deleted=0 and ld_invoice.invoicestatus='已付款' and exists(select 1 from ld_version where current_version ='v2.0' or current_version='v2.01');
declare continue handler  for not   found  SET done =1;

select cur_id into @curid  from ld_modentity_num where semodule='CashBill';

select prefix into @prefix from ld_modentity_num where semodule='CashBill';

select id into @crmid from ld_crmentity_seq;

OPEN cur1;
Fetch cur1 into iinvoiceid,iaccountid,isalesorderid,iinvoicedate,itotal,isubtotal,ismownerid,ismcreatorid;
 loop1: while  done<>1 DO
 	set @curid=@curid+1;
	update ld_Crmentity_seq set id=@crmid+1 where not exists(select 1 from ld_CashBill where invoiceId=iinvoiceid);
	set @crmid=@crmid+1;
insert into ld_crmentity(crmid,smownerid,smcreatorid,modifiedby,setype,createdtime,viewedtime,modifiedtime)
select @crmid,ismownerid,ismcreatorid,ismownerid,'CashBill',now(),now(),now() from dual  where not exists(select 1 from ld_CashBill where invoiceId=iinvoiceid);
update ld_modentity_num set cur_id=@curid where not exists(select 1 from ld_CashBill where invoiceId=iinvoiceid);

 	insert into ld_CashBill(cashbillid,accountid,salesorderid,cashbill_no,cashbilldate,paymentmethod,iscashbill,total ,nopaymentplan)
  	select @crmid,iaccountid,isalesorderid, concat(@prefix,@curid),iinvoicedate,'现金','已开',itotal,isubtotal from dual where not exists(select 1 from ld_CashBill where invoiceId=iinvoiceid); 
	
	Fetch cur1 into iinvoiceid,iaccountid,isalesorderid,iinvoicedate,itotal,isubtotal,ismownerid,ismcreatorid;
end while loop1;
close cur1;

end ||
delimiter;

-- ----------------------------
-- Procedure structure for `updateParent_lineitem_id`
-- ----------------------------
DROP PROCEDURE IF EXISTS `updateParent_lineitem_id`;
delimiter ||
CREATE  PROCEDURE `updateParent_lineitem_id`()
BEGIN

declare done int default 0;
declare second_done int default 0;
declare p_crmid int default 1;
declare p_entitytypeid int default 0;
declare p_lineitem_id int default 0;
declare p_id int default 0;
DECLARE p_productid int default 0;
declare p_cnt int default 0;
declare p_salesorderid int default 0;
declare p_salesbackid int default 0;
declare p_purchasebackid int default 0;
declare p_purchaseorder_id int default 0;

declare cur2 CURSOR FOR select crmid,lineitem_id,productid from ld_inventoryproductrel inner join ld_crmentity on ld_inventoryproductrel.id = ld_crmentity.crmid where ld_crmentity.setype in('SalesOrder','PurchaseOrder');
declare cur4 CURSOR FOR select salesbackid,salesorderid from ld_salesback where salesorderid > 0;
declare cur5 CURSOR FOR select purchasebackid,purchaseorder_id from ld_purchaseback where purchaseorder_id > 0;
declare continue handler for not found SET done =1;
-- 销售退货单产品明细表中加上对应的退货单-原单ID
open cur4;
fetch cur4 into p_salesbackid,p_salesorderid;
while done <>1 DO
update ld_inventoryproductrel set entitytypeid = p_salesorderid where id = p_salesbackid;
fetch cur4 into p_salesbackid,p_salesorderid;
end while;
close cur4;

-- 采购退货单产品明细表中加上对应的退货单-原单ID
set done = 0;
open cur5;
fetch cur5 into p_purchasebackid,p_purchaseorder_id;
while done <>1 DO
update ld_inventoryproductrel set entitytypeid = p_purchaseorder_id where id = p_purchasebackid;
fetch cur5 into p_purchasebackid,p_purchaseorder_id;
end while;
close cur5;

set done = 0;
open cur2;
fetch cur2 into p_crmid,p_lineitem_id,p_productid;
loop2: while done<>1 do
update ld_inventoryproductrel set parent_lineitem_id = p_lineitem_id where entitytypeid = p_crmid and productid = p_productid;
fetch cur2 into p_crmid,p_lineitem_id,p_productid;
end while loop2;
close cur2;

end ||
delimiter;

-- ----------------------------
-- Procedure structure for `updatequicactionsseq`
-- ----------------------------
DROP PROCEDURE IF EXISTS `updatequicactionsseq`;
delimiter ||
CREATE  PROCEDURE `updatequicactionsseq`(

)
begin
   
		declare tmp_tabid int default 0;
		declare mycursor cursor for select tabid from ld_quickactions where tabid>0 group by tabid;		
		DECLARE CONTINUE HANDLER FOR SQLSTATE '02000' set tmp_tabid = NULL;
		
		update ld_quickactions set sequence=1000;
		update ld_quickactions set sequence=1 where related_tabid=(select tabid from ld_tab where name='SalesBack');
		update ld_quickactions set sequence=2 where related_tabid=(select tabid from ld_tab where name='Contacts');
		update ld_quickactions set sequence=3 where related_tabid=(select tabid from ld_tab where name='VendorContact');
		update ld_quickactions set sequence=4 where related_tabid=(select tabid from ld_tab where name='ContactRecords');
		update ld_quickactions set sequence=5 where related_tabid=(select tabid from ld_tab where name='VendorContactRecords');
		update ld_quickactions set sequence=6 where related_tabid in (select tabid from ld_tab where name in('Events','Calendar'));
		update ld_quickactions set sequence=7 where related_tabid=(select tabid from ld_tab where name='Quotes');
		update ld_quickactions set sequence=8 where related_tabid=(select tabid from ld_tab where name='Potentials');
		update ld_quickactions set sequence=9 where related_tabid=(select tabid from ld_tab where name='SalesOrder');
		update ld_quickactions set sequence=10 where related_tabid=(select tabid from ld_tab where name='PurchaseOrder');
		update ld_quickactions set sequence=11 where related_tabid=(select tabid from ld_tab where name='ServiceContracts');
		update ld_quickactions set sequence=12 where related_tabid=(select tabid from ld_tab where name='Invoice');
		update ld_quickactions set sequence=13 where related_tabid=(select tabid from ld_tab where name='PaymentPlan');
		update ld_quickactions set sequence=14 where related_tabid=(select tabid from ld_tab where name='SendPayment');
		update ld_quickactions set sequence=15 where related_tabid=(select tabid from ld_tab where name='CashBill');
		update ld_quickactions set sequence=16 where related_tabid=(select tabid from ld_tab where name='SendCashBill');
		update ld_quickactions set sequence=17 where related_tabid=(select tabid from ld_tab where name='Expense');
		update ld_quickactions set sequence=18 where related_tabid=(select tabid from ld_tab where name='Commission');
		update ld_quickactions set sequence=19 where related_tabid=(select tabid from ld_tab where name='PutCash');
		update ld_quickactions set sequence=20 where related_tabid=(select tabid from ld_tab where name='CashDeposit');
		update ld_quickactions set sequence=21 where related_tabid=(select tabid from ld_tab where name='HelpDesk');
		update ld_quickactions set sequence=22 where related_tabid=(select tabid from ld_tab where name='Project');
		update ld_quickactions set sequence=23 where related_tabid=(select tabid from ld_tab where name='ProjectTask');
		update ld_quickactions set sequence=24 where related_tabid=(select tabid from ld_tab where name='ProjectMilestone');
		update ld_quickactions set sequence=25 where related_tabid=(select tabid from ld_tab where name='OutboundOrder');
		update ld_quickactions set sequence=26 where related_tabid=(select tabid from ld_tab where name='Stock');
		update ld_quickactions set sequence=27 where related_tabid=(select tabid from ld_tab where name='Checks');
		update ld_quickactions set sequence=28 where related_tabid=(select tabid from ld_tab where name='Reminds');
		update ld_quickactions set sequence=29 where related_tabid=(select tabid from ld_tab where name='Attachment');
		update ld_quickactions set sequence=30 where related_tabid=(select tabid from ld_tab where name='Quotes');
		update ld_quickactions set sequence=31 where related_tabid=(select tabid from ld_tab where name='MassSMS');
		update ld_quickactions set sequence=32 where related_tabid=(select tabid from ld_tab where name='Emails');
  					
		open mycursor;
		fetch mycursor into tmp_tabid;
		while(tmp_tabid is not null) DO
				
				insert into ld_quickactions(tabid,related_tabid,sequence,presence)
				select tmp_tabid,-5,0,1 from dual 
				where not exists (select 1 from ld_quickactions where tabid=tmp_tabid and related_tabid=-5);
				
				select 1000 into @seq;
				update ld_quickactions set sequence=@seq+1,label='查看上下级客户' where tabid=tmp_tabid and related_tabid=-4;
				update ld_quickactions set sequence=@seq+2,label='创建下级联系人' where tabid=tmp_tabid and related_tabid=-2;
				update ld_quickactions set sequence=@seq+3,label='查看上下级联系人' where tabid=tmp_tabid and related_tabid=-3;
				update ld_quickactions set sequence=@seq+4,label='修改日志' where tabid=tmp_tabid and related_tabid=-1;
				update ld_quickactions set sequence=@seq+5,label='检查附件完整性' where tabid=tmp_tabid and related_tabid=-7;
				update ld_quickactions set sequence=@seq+6,label='下载附件' where tabid=tmp_tabid and related_tabid=-6;
				update ld_quickactions set sequence=@seq+7,label='打印工具' where tabid=tmp_tabid and related_tabid=-5;
				update ld_quickactions set sequence=@seq+8,label='发送邮件添加附件' where tabid=tmp_tabid and related_tabid=-8;
			
				SELECT @i:=0;
				update ld_quickactions set sequence=(@i:=@i+1) where tabid=tmp_tabid order by sequence; 
				
				fetch mycursor into tmp_tabid;
		end while;
		close mycursor;

end ||
delimiter;

-- ----------------------------
-- Procedure structure for `update_account_columnindex`
-- ----------------------------
DROP PROCEDURE IF EXISTS `update_account_columnindex`;
delimiter ||
CREATE  PROCEDURE `update_account_columnindex`(

)
begin

	declare tmp_cvid  int default 0;

	declare mycursor cursor for select cvid from ld_customview where entitytype='Accounts' order by cvid; 
	DECLARE CONTINUE HANDLER FOR SQLSTATE '02000' set tmp_cvid = -1;

	open mycursor;
	fetch mycursor into tmp_cvid;

	while(tmp_cvid >1) DO
			
			update ld_cvcolumnlist set columnindex=columnindex+100 where cvid=tmp_cvid and columnname like 'ld_contactdetails%';
			
			select -1 into @i;
			update ld_cvcolumnlist set columnindex=(@i:=@i+1) where cvid=tmp_cvid order by columnindex;
			
			fetch mycursor into tmp_cvid;
	end while;
	close mycursor;
end ||
delimiter;

-- ----------------------------
-- Procedure structure for `update_products_columnindex`
-- ----------------------------
DROP PROCEDURE IF EXISTS `update_products_columnindex`;
delimiter ||
CREATE  PROCEDURE `update_products_columnindex`(

)
begin

	declare tmp_cvid  int default 0;

	declare mycursor cursor for select cvid from ld_customview where entitytype='Products' order by cvid; 
	DECLARE CONTINUE HANDLER FOR SQLSTATE '02000' set tmp_cvid = -1;

	open mycursor;
	fetch mycursor into tmp_cvid;

	while(tmp_cvid >1) DO
			
			update ld_cvcolumnlist set columnindex=columnindex+100 where cvid=tmp_cvid;
			update ld_cvcolumnlist set columnindex=99 where cvid=tmp_cvid and columnname like 'ld_products:productname:productname%';
			set @i=-1;
			update ld_cvcolumnlist set columnindex=(@i:=@i+1) where cvid=tmp_cvid order by columnindex;
			
			fetch mycursor into tmp_cvid;
	end while;
	close mycursor;
end ||
delimiter;

-- ----------------------------
-- Procedure structure for `update_stuffsequence`
-- ----------------------------
DROP PROCEDURE IF EXISTS `update_stuffsequence`;
delimiter ||
CREATE  PROCEDURE `update_stuffsequence`(
)
BEGIN 

		DECLARE done int DEFAULT 0; 
		DECLARE tmp_templateid int(11); 

		DECLARE mycursor CURSOR FOR SELECT templateid from ld_templates; 
		DECLARE CONTINUE HANDLER FOR SQLSTATE '02000' set tmp_templateid = NULL;

		update ld_templatesstuff set stuffsequence=stuffsequence+2 ;
		update ld_templatesstuff set stuffsequence=1 where stuffId=32;

		OPEN mycursor; 
		fetch mycursor into tmp_templateid; 
		while(tmp_templateid is not null) DO	
				select 0 into @i;
				update ld_templatesstuff set stuffsequence=(@i:=@i+1) where templateid=tmp_templateid order by stuffsequence; 
				fetch mycursor into tmp_templateid;
		end while;
		close mycursor;
end ||
delimiter;

INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype) SELECT 'zh','LBL_WORK_TEMPLATE','工作协同模板','fixedstr' FROM DUAL
WHERE NOT EXISTS(SELECT 1 FROM ld_desk  WHERE languagetype='zh' AND labelbol='LBL_WORK_TEMPLATE' AND Labeltype='fixedstr');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype) SELECT 'en','LBL_WORK_TEMPLATE','The work schemes template','fixedstr' FROM DUAL
WHERE NOT EXISTS(SELECT 1 FROM ld_desk  WHERE languagetype='en' AND labelbol='LBL_WORK_TEMPLATE' AND Labeltype='fixedstr');
delimiter;

INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype) SELECT 'zh','LBL_WORKSCHEMES_TEMPLATES','定制工作协同日志模板','fixedstr' FROM DUAL
WHERE NOT EXISTS(SELECT 1 FROM ld_desk  WHERE languagetype='zh' AND labelbol='LBL_WORKSCHEMES_TEMPLATES' AND Labeltype='fixedstr');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype) SELECT 'en','LBL_WORKSCHEMES_TEMPLATES','Customise the work schemes templates','fixedstr' FROM DUAL
WHERE NOT EXISTS(SELECT 1 FROM ld_desk  WHERE languagetype='en' AND labelbol='LBL_WORKSCHEMES_TEMPLATES' AND Labeltype='fixedstr');
delimiter;

SELECT blockid,sequence INTO @blockid,@seq FROM ld_settings_field WHERE NAME = 'THEDOCUMENTTEMPLATE';
set @seq1 = @seq + 1;
update ld_settings_field set sequence = (@seq1:=@seq1+1) where blockid = @blockid and sequence >= @seq and NAME not in ('THEDOCUMENTTEMPLATE','LBL_WORK_TEMPLATE');
SELECT MAX(fieldid) INTO @fieldid FROM ld_settings_field;
INSERT INTO ld_settings_field(fieldid,blockid,NAME,iconpath,description,linkto,sequence,active)
SELECT @fieldid+1,@blockid,'LBL_WORK_TEMPLATE','work_template.png','LBL_WORKSCHEMES_TEMPLATES','index.php?module=Settings&action=WorkTemplate&parenttab=Settings',@seq+1,0 FROM DUAL
WHERE NOT EXISTS(SELECT 1 FROM ld_settings_field WHERE NAME='LBL_WORK_TEMPLATE');
delimiter;

CREATE TABLE if not EXISTS `ld_workreport_field` (
  `id` int(19) NOT NULL,
  `name` varchar(100) DEFAULT NULL,
  `label` varchar(240) DEFAULT NULL,
  `entitytype` varchar(50) DEFAULT NULL,
  `type` int(4) DEFAULT NULL,
  `defaultvalue` varchar(240) DEFAULT NULL,
  `defaultheight` varchar(240) DEFAULT NULL,
  `is_mandatory` tinyint(1) DEFAULT 0,
  `is_activate` tinyint(1) DEFAULT 0,
  `deleted` tinyint(1) DEFAULT 0,
  `sequence` int(11) DEFAULT 0,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
delimiter;

CREATE TABLE IF NOT EXISTS `ld_workreport_field_seq` (
	`id` int(11) NOT NULL default '0',
	PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
delimiter;

INSERT INTO ld_workreport_field_seq(id) SELECT 0 FROM DUAL
WHERE NOT EXISTS(SELECT 1 FROM ld_workreport_field_seq  WHERE id>=0);
delimiter;

CREATE TABLE IF NOT EXISTS `ld_workreportcf` (
	`workreportid` int(11) NOT NULL default '0',
	PRIMARY KEY (`workreportid`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
delimiter;

select id into @id from ld_workreport_field_seq limit 1;
set @id = @id + 1;
INSERT INTO `ld_workreport_field`(id,name,label,entitytype,type,defaultheight,is_mandatory)
	SELECT @id,'worksummary','请填写今日工作总结','workreport',1,50,0 FROM DUAL
WHERE NOT EXISTS(SELECT 1 FROM `ld_workreport_field` WHERE entitytype = 'workreport'
	and type = 1 and name = 'worksummary');
set @id = @id + 1;
INSERT INTO `ld_workreport_field`(id,name,label,entitytype,type,defaultheight,is_mandatory)
	SELECT @id,'workplan','请填写明日工作计划','workreport',1,50,1 FROM DUAL
WHERE NOT EXISTS(SELECT 1 FROM `ld_workreport_field` WHERE entitytype = 'workreport'
	and type = 1 and name = 'workplan');
set @id = @id + 1;
INSERT INTO `ld_workreport_field`(id,name,label,entitytype,type,defaultheight,is_mandatory)
	SELECT @id,'workexperience','请填写工作心得体会','workreport',1,50,1 FROM DUAL
WHERE NOT EXISTS(SELECT 1 FROM `ld_workreport_field` WHERE entitytype = 'workreport'
	and type = 1 and name = 'workexperience');
update ld_workreport_field_seq set id = (select max(id) from `ld_workreport_field`);
delimiter;
select id into @id from ld_workreport_field_seq limit 1;
set @id = @id + 1;
INSERT INTO `ld_workreport_field`(id,name,label,entitytype,type,defaultheight,is_mandatory)
	SELECT @id,'worksummary','请填写本周工作总结','workreport',2,50,0 FROM DUAL
WHERE NOT EXISTS(SELECT 1 FROM `ld_workreport_field` WHERE entitytype = 'workreport'
	and type = 2 and name = 'worksummary');
set @id = @id + 1;
INSERT INTO `ld_workreport_field`(id,name,label,entitytype,type,defaultheight,is_mandatory)
	SELECT @id,'workplan','请填写下周工作计划','workreport',2,50,1 FROM DUAL
WHERE NOT EXISTS(SELECT 1 FROM `ld_workreport_field` WHERE entitytype = 'workreport'
	and type = 2 and name = 'workplan');
set @id = @id + 1;
INSERT INTO `ld_workreport_field`(id,name,label,entitytype,type,defaultheight,is_mandatory)
	SELECT @id,'workexperience','请填写工作心得体会','workreport',2,50,1 FROM DUAL
WHERE NOT EXISTS(SELECT 1 FROM `ld_workreport_field` WHERE entitytype = 'workreport'
	and type = 2 and name = 'workexperience');
update ld_workreport_field_seq set id = (select max(id) from `ld_workreport_field`);
delimiter;

select id into @id from ld_workreport_field_seq limit 1;
set @id = @id + 1;
INSERT INTO `ld_workreport_field`(id,name,label,entitytype,type,defaultheight,is_mandatory)
	SELECT @id,'worksummary','请填写本月工作总结','workreport',3,50,0 FROM DUAL
WHERE NOT EXISTS(SELECT 1 FROM `ld_workreport_field` WHERE entitytype = 'workreport'
	and type = 3 and name = 'worksummary');
set @id = @id + 1;
INSERT INTO `ld_workreport_field`(id,name,label,entitytype,type,defaultheight,is_mandatory)
	SELECT @id,'workplan','请填写下月工作计划','workreport',3,50,1 FROM DUAL
WHERE NOT EXISTS(SELECT 1 FROM `ld_workreport_field` WHERE entitytype = 'workreport'
	and type = 3 and name = 'workplan');
set @id = @id + 1;
INSERT INTO `ld_workreport_field`(id,name,label,entitytype,type,defaultheight,is_mandatory)
	SELECT @id,'workexperience','请填写工作心得体会','workreport',3,50,1 FROM DUAL
WHERE NOT EXISTS(SELECT 1 FROM `ld_workreport_field` WHERE entitytype = 'workreport'
	and type = 3 and name = 'workexperience');
update ld_workreport_field_seq set id = (select max(id) from `ld_workreport_field`);
delimiter;

update ld_workreport_field set sequence = id where entitytype = 'workreport' and sequence = 0;
delimiter;

INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype) SELECT 'zh','LBL_FIELDNAME','字段名称','fixedstr' FROM DUAL
WHERE NOT EXISTS(SELECT 1 FROM ld_desk  WHERE languagetype='zh' AND labelbol='LBL_FIELDNAME' AND Labeltype='fixedstr');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype) SELECT 'en','LBL_FIELDNAME','Field Name','fixedstr' FROM DUAL
WHERE NOT EXISTS(SELECT 1 FROM ld_desk  WHERE languagetype='en' AND labelbol='LBL_FIELDNAME' AND Labeltype='fixedstr');
delimiter;

INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype) SELECT 'zh','LBL_MANDATORYFIELDS','是否必填','fixedstr' FROM DUAL
WHERE NOT EXISTS(SELECT 1 FROM ld_desk  WHERE languagetype='zh' AND labelbol='LBL_MANDATORYFIELDS' AND Labeltype='fixedstr');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype) SELECT 'en','LBL_MANDATORYFIELDS','Mandatory Fields','fixedstr' FROM DUAL
WHERE NOT EXISTS(SELECT 1 FROM ld_desk  WHERE languagetype='en' AND labelbol='LBL_MANDATORYFIELDS' AND Labeltype='fixedstr');
delimiter;

INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype) SELECT 'zh','LBL_DEFAULTHEIGHT','默认高度(px)','fixedstr' FROM DUAL
WHERE NOT EXISTS(SELECT 1 FROM ld_desk  WHERE languagetype='zh' AND labelbol='LBL_DEFAULTHEIGHT' AND Labeltype='fixedstr');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype) SELECT 'en','LBL_DEFAULTHEIGHT','Default height(px)','fixedstr' FROM DUAL
WHERE NOT EXISTS(SELECT 1 FROM ld_desk  WHERE languagetype='en' AND labelbol='LBL_DEFAULTHEIGHT' AND Labeltype='fixedstr');
delimiter;

INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype) SELECT 'zh','LBL_DEFAULTVALUE','默认值','fixedstr' FROM DUAL
WHERE NOT EXISTS(SELECT 1 FROM ld_desk  WHERE languagetype='zh' AND labelbol='LBL_DEFAULTVALUE' AND Labeltype='fixedstr');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype) SELECT 'en','LBL_DEFAULTVALUE','Default','fixedstr' FROM DUAL
WHERE NOT EXISTS(SELECT 1 FROM ld_desk  WHERE languagetype='en' AND labelbol='LBL_DEFAULTVALUE' AND Labeltype='fixedstr');
delimiter;

INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype) SELECT 'zh','LBL_ACTIVATE','状态','fixedstr' FROM DUAL
WHERE NOT EXISTS(SELECT 1 FROM ld_desk  WHERE languagetype='zh' AND labelbol='LBL_ACTIVATE' AND Labeltype='fixedstr');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype) SELECT 'en','LBL_ACTIVATE','Activate','fixedstr' FROM DUAL
WHERE NOT EXISTS(SELECT 1 FROM ld_desk  WHERE languagetype='en' AND labelbol='LBL_ACTIVATE' AND Labeltype='fixedstr');
delimiter;

INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype) SELECT 'zh','LBL_WORKSCHEMESTYPE','日志类型','fixedstr' FROM DUAL
WHERE NOT EXISTS(SELECT 1 FROM ld_desk  WHERE languagetype='zh' AND labelbol='LBL_WORKSCHEMESTYPE' AND Labeltype='fixedstr');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype) SELECT 'en','LBL_WORKSCHEMESTYPE','Work schemes type','fixedstr' FROM DUAL
WHERE NOT EXISTS(SELECT 1 FROM ld_desk  WHERE languagetype='en' AND labelbol='LBL_WORKSCHEMESTYPE' AND Labeltype='fixedstr');
delimiter;

INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype) SELECT 'zh','LBL_USERDEFINEDFIELDS','用户自定义字段','fixedstr' FROM DUAL
WHERE NOT EXISTS(SELECT 1 FROM ld_desk  WHERE languagetype='zh' AND labelbol='LBL_USERDEFINEDFIELDS' AND Labeltype='fixedstr');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype) SELECT 'en','LBL_USERDEFINEDFIELDS','User defined fields','fixedstr' FROM DUAL
WHERE NOT EXISTS(SELECT 1 FROM ld_desk  WHERE languagetype='en' AND labelbol='LBL_USERDEFINEDFIELDS' AND Labeltype='fixedstr');
delimiter;
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype) SELECT 'zh','LBL_DAILYRECORD','日志','fixedstr' FROM DUAL
WHERE NOT EXISTS(SELECT 1 FROM ld_desk  WHERE languagetype='zh' AND labelbol='LBL_DAILYRECORD' AND Labeltype='fixedstr');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype) SELECT 'en','LBL_DAILYRECORD','Daily record','fixedstr' FROM DUAL
WHERE NOT EXISTS(SELECT 1 FROM ld_desk  WHERE languagetype='en' AND labelbol='LBL_DAILYRECORD' AND Labeltype='fixedstr');
delimiter;

INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype) SELECT 'zh','LBL_WEEKLYSCHEMES','周计划','fixedstr' FROM DUAL
WHERE NOT EXISTS(SELECT 1 FROM ld_desk  WHERE languagetype='zh' AND labelbol='LBL_WEEKLYSCHEMES' AND Labeltype='fixedstr');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype) SELECT 'en','LBL_WEEKLYSCHEMES','Weekly schemes','fixedstr' FROM DUAL
WHERE NOT EXISTS(SELECT 1 FROM ld_desk  WHERE languagetype='en' AND labelbol='LBL_WEEKLYSCHEMES' AND Labeltype='fixedstr');
delimiter;

INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype) SELECT 'zh','LBL_MONTHLYSCHEMES','月计划','fixedstr' FROM DUAL
WHERE NOT EXISTS(SELECT 1 FROM ld_desk  WHERE languagetype='zh' AND labelbol='LBL_MONTHLYSCHEMES' AND Labeltype='fixedstr');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype) SELECT 'en','LBL_MONTHLYSCHEMES','Monthly schemes','fixedstr' FROM DUAL
WHERE NOT EXISTS(SELECT 1 FROM ld_desk  WHERE languagetype='en' AND labelbol='LBL_MONTHLYSCHEMES' AND Labeltype='fixedstr');
delimiter;

UPDATE ld_desk SET fieldlabel = '( 查看单据明细界面 )'WHERE labelbol='VIEWTHEDETAILS' and languagetype='zh';
UPDATE ld_desk SET fieldlabel = '( View the details )'WHERE labelbol='VIEWTHEDETAILS' and languagetype='en';
UPDATE ld_desk SET fieldlabel = '( 需购买并设置通讯账户 )'WHERE labelbol='NEEDBUYACCOUNT' and languagetype='zh';
UPDATE ld_desk SET fieldlabel = '( Need to buy communication account first )'WHERE labelbol='NEEDBUYACCOUNT' and languagetype='en';
UPDATE ld_desk SET fieldlabel = '( {$Accounts.Accounts}和{$HelpDesk.HelpDesk}明细界面 )' WHERE labelbol='SERVICEINFOREMIND' and languagetype='zh';
UPDATE ld_desk SET fieldlabel = '( {$Accounts.Accounts} and {$HelpDesk.HelpDesk}detail interface )' WHERE labelbol='SERVICEINFOREMIND' and languagetype='en';
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,Labeltype)
select 'zh','TOTHEHIGNSEASCUSTOMERSUCCESS','单据[%s]转为公海客户成功！','fixedstr' 
from dual where not exists(select 1 from ld_desk where languagetype = 'zh' and labelbol = 'TOTHEHIGNSEASCUSTOMERSUCCESS' and Labeltype = 'fixedstr');

insert into ld_desk(languagetype,labelbol,fieldlabel,Labeltype)
select 'en','TOTHEHIGNSEASCUSTOMERSUCCESS','Document[%s] To the high seas customer success','fixedstr' 
from dual where not exists(select 1 from ld_desk where languagetype = 'en' and labelbol = 'TOTHEHIGNSEASCUSTOMERSUCCESS' and Labeltype = 'fixedstr');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,Labeltype)
select 'zh','TOTHEHIGNSEASCUSTOMERERROR','单据[%s]转为公海客户失败，原因：当前单据已经时公海客户了！','fixedstr' 
from dual where not exists(select 1 from ld_desk where languagetype = 'zh' and labelbol = 'TOTHEHIGNSEASCUSTOMERERROR' and Labeltype = 'fixedstr');

insert into ld_desk(languagetype,labelbol,fieldlabel,Labeltype)
select 'en','TOTHEHIGNSEASCUSTOMERERROR','Document[%s] To the high seas customer success，The reason: when the customer documents have been on the high seas!','fixedstr' 
from dual where not exists(select 1 from ld_desk where languagetype = 'en' and labelbol = 'TOTHEHIGNSEASCUSTOMERERROR' and Labeltype = 'fixedstr');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,Labeltype)
select 'zh','TOANORDINARYCUSTOMERSUCCESS','单据[%s]转为普通客户成功！','fixedstr' 
from dual where not exists(select 1 from ld_desk where languagetype = 'zh' and labelbol = 'TOANORDINARYCUSTOMERSUCCESS' and Labeltype = 'fixedstr');

insert into ld_desk(languagetype,labelbol,fieldlabel,Labeltype)
select 'en','TOANORDINARYCUSTOMERSUCCESS','Document[%s] To an ordinary customer success','fixedstr' 
from dual where not exists(select 1 from ld_desk where languagetype = 'en' and labelbol = 'TOANORDINARYCUSTOMERSUCCESS' and Labeltype = 'fixedstr');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,Labeltype)
select 'zh','TOANORDINARYCUSTOMERERROR','单据[%s]转为普通客户失败，原因：当前单据已经时普通客户了！','fixedstr' 
from dual where not exists(select 1 from ld_desk where languagetype = 'zh' and labelbol = 'TOANORDINARYCUSTOMERERROR' and Labeltype = 'fixedstr');

insert into ld_desk(languagetype,labelbol,fieldlabel,Labeltype)
select 'en','TOANORDINARYCUSTOMERERROR','Document[%s] To an ordinary customer success，The reason: when the customer documents have been on an ordinary!','fixedstr' 
from dual where not exists(select 1 from ld_desk where languagetype = 'en' and labelbol = 'TOANORDINARYCUSTOMERERROR' and Labeltype = 'fixedstr');
delimiter;


insert into ld_desk(languagetype,labelbol,fieldlabel,Labeltype)
select 'zh','SETREADSUCCESS','单据[%s]设为已读成功！','fixedstr' 
from dual where not exists(select 1 from ld_desk where languagetype = 'zh' and labelbol = 'SETREADSUCCESS' and Labeltype = 'fixedstr');

insert into ld_desk(languagetype,labelbol,fieldlabel,Labeltype)
select 'en','SETREADSUCCESS','Document[%s] set read success','fixedstr' 
from dual where not exists(select 1 from ld_desk where languagetype = 'en' and labelbol = 'SETREADSUCCESS' and Labeltype = 'fixedstr');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,Labeltype)
select 'zh','SETREADERROR','单据[%s]设为已读失败！原因：当前单据已经是已读！','fixedstr' 
from dual where not exists(select 1 from ld_desk where languagetype = 'zh' and labelbol = 'SETREADERROR' and Labeltype = 'fixedstr');

insert into ld_desk(languagetype,labelbol,fieldlabel,Labeltype)
select 'en','SETREADERROR','Document[%s] set read lose!','fixedstr' 
from dual where not exists(select 1 from ld_desk where languagetype = 'en' and labelbol = 'SETREADERROR' and Labeltype = 'fixedstr');
delimiter;


insert into ld_desk(languagetype,labelbol,fieldlabel,Labeltype)
select 'zh','SETUNREADSUCCESS','单据[%s]设为未读成功！','fixedstr' 
from dual where not exists(select 1 from ld_desk where languagetype = 'zh' and labelbol = 'SETUNREADSUCCESS' and Labeltype = 'fixedstr');

insert into ld_desk(languagetype,labelbol,fieldlabel,Labeltype)
select 'en','SETUNREADSUCCESS','Document[%s] set unread success','fixedstr' 
from dual where not exists(select 1 from ld_desk where languagetype = 'en' and labelbol = 'SETUNREADSUCCESS' and Labeltype = 'fixedstr');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,Labeltype)
select 'zh','SETUNREADERROR','单据[%s]设为未读失败！原因：当前单据已经是未读！','fixedstr' 
from dual where not exists(select 1 from ld_desk where languagetype = 'zh' and labelbol = 'SETUNREADERROR' and Labeltype = 'fixedstr');

insert into ld_desk(languagetype,labelbol,fieldlabel,Labeltype)
select 'en','SETUNREADERROR','Document[%s] set unread lose!','fixedstr' 
from dual where not exists(select 1 from ld_desk where languagetype = 'en' and labelbol = 'SETUNREADERROR' and Labeltype = 'fixedstr');
delimiter;

update ld_desk set fieldlabel = 'Each user can set their own template' where labelbol ='EACHUSERCANSETTHEIROWNTEMPLATES' and languagetype ='en';
update ld_desk set fieldlabel = 'Define a template' where labelbol='DEFINEATEMPLATE' and languagetype ='en';
delimiter;

SELECT tabid INTO @tabid FROM ld_tab WHERE NAME = 'Attachment';
SELECT fieldid INTO @fieldid FROM ld_field WHERE tabid = @tabid AND fieldname = 'assigned_user_id';
INSERT INTO ld_def_org_field (tabid,fieldid,visible,readonly)
SELECT @tabid,@fieldid,0,0
FROM DUAL WHERE  NOT EXISTS (SELECT 1 FROM ld_def_org_field WHERE tabid=@tabid AND fieldid=@fieldid);
delimiter;

CALL addColumn('ld_workreport_field','tablename','varchar','100',1);
delimiter;

UPDATE ld_workreport_field SET tablename = (CASE SUBSTR(NAME,8,1) WHEN '_' THEN 'ld_workreportcf' ELSE 'ld_wordreport' END)
WHERE tablename IS NULL;
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,Labeltype)
select 'zh','RELEASESUCCESS','单据[%s]释放成功！','fixedstr' 
from dual where not exists(select 1 from ld_desk where languagetype = 'zh' and labelbol = 'RELEASESUCCESS' and Labeltype = 'fixedstr');

insert into ld_desk(languagetype,labelbol,fieldlabel,Labeltype)
select 'en','RELEASESUCCESS','Document[%s] release success!','fixedstr' 
from dual where not exists(select 1 from ld_desk where languagetype = 'en' and labelbol = 'RELEASESUCCESS' and Labeltype = 'fixedstr');
delimiter;

UPDATE ld_field SET issmownerid=1 WHERE tabid =(SELECT tabid FROM ld_tab WHERE name='Products') AND columnname='smownerid';
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,Labeltype)
select 'zh','TOPROMOTETHESUCCESS','单据[%s]推进成功！','fixedstr' 
from dual where not exists(select 1 from ld_desk where languagetype = 'zh' and labelbol = 'TOPROMOTETHESUCCESS' and Labeltype = 'fixedstr');

insert into ld_desk(languagetype,labelbol,fieldlabel,Labeltype)
select 'en','TOPROMOTETHESUCCESS','Document[%s] To promote the success！','fixedstr' 
from dual where not exists(select 1 from ld_desk where languagetype = 'en' and labelbol = 'TOPROMOTETHESUCCESS' and Labeltype = 'fixedstr');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,Labeltype)
select 'zh','TOPROMOTEFAILURE','单据[%s]推进失败！','fixedstr' 
from dual where not exists(select 1 from ld_desk where languagetype = 'zh' and labelbol = 'TOPROMOTEFAILURE' and Labeltype = 'fixedstr');

insert into ld_desk(languagetype,labelbol,fieldlabel,Labeltype)
select 'en','TOPROMOTEFAILURE','Document[%s] Promote failure!','fixedstr' 
from dual where not exists(select 1 from ld_desk where languagetype = 'en' and labelbol = 'TOPROMOTEFAILURE' and Labeltype = 'fixedstr');
delimiter;

update ld_desk set fieldlabel='Define and set permissions for the roles' where labelbol = 'LBL_ROLE_DESCRIPTION' and languagetype ='en';
delimiter;

select tabid into @tabid from ld_tab where `name` = 'LessionPlan';
insert into ld_profileallpermission(tabid,operation)
select @tabid,3 from dual where not exists
(select 1 from ld_profileallpermission where tabid = @tabid and operation=3) and (select 1 from ld_version where trade='edu');
insert into ld_profileallpermission(tabid,operation)
select @tabid,4 from dual where not exists
(select 1 from ld_profileallpermission where tabid = @tabid and operation=4) and (select 1 from ld_version where trade='edu');
insert into ld_profileallpermission(tabid,operation)
select @tabid,11 from dual where not exists
(select 1 from ld_profileallpermission where tabid = @tabid and operation=11) and (select 1 from ld_version where trade='edu');
insert into ld_profileallpermission(tabid,operation)
select @tabid,1 from dual where not exists
(select 1 from ld_profileallpermission where tabid = @tabid and operation=1) and (select 1 from ld_version where trade='edu');
insert into ld_profileallpermission(tabid,operation)
select @tabid,2 from dual where not exists
(select 1 from ld_profileallpermission where tabid = @tabid and operation=2) and (select 1 from ld_version where trade='edu');
insert into ld_profileallpermission(tabid,operation)
select @tabid,12 from dual where not exists
(select 1 from ld_profileallpermission where tabid = @tabid and operation=12) and (select 1 from ld_version where trade='edu');
insert into ld_profileallpermission(tabid,operation)
select @tabid,13 from dual where not exists
(select 1 from ld_profileallpermission where tabid = @tabid and operation=13) and (select 1 from ld_version where trade='edu');
insert into ld_profileallpermission(tabid,operation)
select @tabid,14 from dual where not exists
(select 1 from ld_profileallpermission where tabid = @tabid and operation=14) and (select 1 from ld_version where trade='edu');
insert into ld_profileallpermission(tabid,operation)
select @tabid,6 from dual where not exists
(select 1 from ld_profileallpermission where tabid = @tabid and operation=6) and (select 1 from ld_version where trade='edu');
delimiter;

CREATE TABLE if not exists `ld_maxservicedate` (
  `inventoryid` int(19) default NULL,
  `productid` int(19) default NULL,
  `accountid` int(19) default NULL,
  `service_enddate` date default NULL,
  KEY `maxservicedate_accountid_idx` USING BTREE (`accountid`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
delimiter;

insert ld_maxservicedate (inventoryid, productid,accountid,service_enddate)select temp2.id,temp2.productid,temp1.accountid,temp1.service_enddate  from (
		SELECT
			ld_account.accountid,
			ld_inventoryproductrel.productid,
			max(
				ld_inventoryproductrel.servicecontracts_end_date
			) AS service_enddate
		FROM
			ld_account
		LEFT JOIN ld_servicecontracts ON ld_servicecontracts.accountid = ld_account.accountid
		LEFT JOIN ld_inventoryproductrel ON ld_inventoryproductrel.id = ld_servicecontracts.servicecontractsid
		GROUP BY
			ld_account.accountid,
			ld_inventoryproductrel.productid
	) AS temp1
LEFT JOIN (
	SELECT
		ld_account.accountid,
		ld_inventoryproductrel.productid,
		ld_inventoryproductrel.servicecontracts_end_date,
		max(ld_inventoryproductrel.id) AS id
	FROM
		ld_account
	LEFT JOIN ld_servicecontracts ON ld_servicecontracts.accountid = ld_account.accountid
	LEFT JOIN ld_inventoryproductrel ON ld_inventoryproductrel.id = ld_servicecontracts.servicecontractsid
	WHERE
		ld_servicecontracts.accountid > 0
	GROUP BY
		ld_account.accountid,
		ld_inventoryproductrel.productid,
		ld_inventoryproductrel.servicecontracts_end_date
) AS temp2 ON temp1.productid = temp2.productid
 and temp1.accountid = temp2.accountid
AND temp1.service_enddate = temp2.servicecontracts_end_date
 where temp2.productid>0 and temp1.accountid not in(select accountid from ld_maxservicedate);
 delimiter;
 
UPDATE ld_desk SET fieldlabel = '新增字段公式' WHERE labelbol = 'LBL_NEW_FIEld_EXPRESSION_BUTTON' AND languagetype = 'zh';
UPDATE ld_desk SET fieldlabel = 'Add field formula' WHERE labelbol = 'LBL_NEW_FIEld_EXPRESSION_BUTTON' AND languagetype = 'en';
delimiter;

INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype) SELECT 'zh','LBL_CUSTOMLOGTEMPLATE','定制日志模板','fixedstr' FROM DUAL
WHERE NOT EXISTS(SELECT 1 FROM ld_desk  WHERE languagetype='zh' AND labelbol='LBL_CUSTOMLOGTEMPLATE' AND Labeltype='fixedstr');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype) SELECT 'en','LBL_CUSTOMLOGTEMPLATE','Custom log template','fixedstr' FROM DUAL
WHERE NOT EXISTS(SELECT 1 FROM ld_desk  WHERE languagetype='en' AND labelbol='LBL_CUSTOMLOGTEMPLATE' AND Labeltype='fixedstr');
delimiter;

UPDATE ld_tranlabel SET fieldlabel='Data query of related information' WHERE tabid=(SELECT tabid FROM ld_tab WHERE name='Users') 
AND trantable='ld_blocks' AND languagetype='en' AND fieldlabel='相关信息的数据查询';
delimiter;

UPDATE ld_tranlabel SET fieldlabel='Data query range' WHERE tabid=(SELECT tabid FROM ld_tab WHERE name='Users') 
AND trantable='ld_blocks' AND languagetype='en' AND fieldlabel='Data Access';
delimiter;
UPDATE ld_desk SET fieldlabel='Customize' WHERE labelbol='LBL_SENIOR' AND languagetype='en' AND Labeltype='fixedstr';
delimiter;

UPDATE ld_tranlabel SET  fieldlabel="Allow to view other users' data" WHERE tabid=(SELECT tabid FROM ld_tab WHERE name='Users') 
AND fieldlabel="Allow to view other users data" AND languagetype='en';
delimiter;

UPDATE ld_tranlabel SET  fieldlabel="Allow to edit other users' data" WHERE tabid=(SELECT tabid FROM ld_tab WHERE name='Users') 
AND fieldlabel="Allow to edit other users data" AND languagetype='en';
delimiter;

UPDATE ld_tranlabel SET  fieldlabel="Allow to delete other users' data" WHERE tabid=(SELECT tabid FROM ld_tab WHERE name='Users') 
AND fieldlabel="Allow to delete other users data" AND languagetype='en';
delimiter;
 
UPDATE ld_workreport_field SET tablename = (CASE SUBSTR(NAME,8,1) WHEN '_' THEN 'ld_workreportcf' ELSE 'ld_wordreport' END)
WHERE tablename IS NULL;
delimiter;

call getallprofile('Faq');
call fieldprofile('Faq');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','AccountsReceivableSummary','应收账款汇总表','fixedstr' 
from dual where not exists(select 1 from ld_desk where labelbol = 'AccountsReceivableSummary' and labeltype='fixedstr' and languagetype ='zh');

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','AccountsReceivableSummary','Accounts Receivable Summary','fixedstr' 
from dual where not exists(select 1 from ld_desk where labelbol = 'AccountsReceivableSummary' and labeltype='fixedstr' and languagetype ='en');
delimiter;
select usereportid into @usereportid from ld_usereport where `name` = 'SalesReport';
select max(sequence) into @sequence from ld_usereport where Parent_id = @usereportid;

insert into ld_usereport(name,reportlabel,tabids,basicfilter,advfilter,setcolumns,parent_id,sequence,reporttype,pagewidthpercent)
select 'AccountsReceivableSummary','应收账款汇总表',0,2,1,1,@usereportid,@sequence+1,21,'100' 
from dual where not exists(select 1 from ld_usereport where name = 'AccountsReceivableSummary');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','ACCOUNTINGPROJECTNAME','核算项目名称','fixedstr' 
from dual where not exists(select 1 from ld_desk where labelbol = 'ACCOUNTINGPROJECTNAME' and labeltype='fixedstr' and languagetype ='zh');

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','ACCOUNTINGPROJECTNAME','Accounting project name','fixedstr' 
from dual where not exists(select 1 from ld_desk where labelbol = 'ACCOUNTINGPROJECTNAME' and labeltype='fixedstr' and languagetype ='en');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','THERECEIVABLE','本期应收','fixedstr' 
from dual where not exists(select 1 from ld_desk where labelbol = 'THERECEIVABLE' and labeltype='fixedstr' and languagetype ='zh');

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','THERECEIVABLE','The receivable','fixedstr' 
from dual where not exists(select 1 from ld_desk where labelbol = 'THERECEIVABLE' and labeltype='fixedstr' and languagetype ='en');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','THISPERIODOFPAID','本期实收','fixedstr' 
from dual where not exists(select 1 from ld_desk where labelbol = 'THISPERIODOFPAID' and labeltype='fixedstr' and languagetype ='zh');

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','THISPERIODOFPAID','This period of paid','fixedstr' 
from dual where not exists(select 1 from ld_desk where labelbol = 'THISPERIODOFPAID' and labeltype='fixedstr' and languagetype ='en');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','THEFINALBALANCE','期末余额','fixedstr' 
from dual where not exists(select 1 from ld_desk where labelbol = 'THEFINALBALANCE' and labeltype='fixedstr' and languagetype ='zh');

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','THEFINALBALANCE','The final balance','fixedstr' 
from dual where not exists(select 1 from ld_desk where labelbol = 'THEFINALBALANCE' and labeltype='fixedstr' and languagetype ='en');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','THISYEARTHETOTALRECEIVABLES','本年累计应收','fixedstr' 
from dual where not exists(select 1 from ld_desk where labelbol = 'THISYEARTHETOTALRECEIVABLES' and labeltype='fixedstr' and languagetype ='zh');

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','THISYEARTHETOTALRECEIVABLES','This year the total receivables','fixedstr' 
from dual where not exists(select 1 from ld_desk where labelbol = 'THISYEARTHETOTALRECEIVABLES' and labeltype='fixedstr' and languagetype ='en');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','THEACCUMNLATEDPAID','本年累计实收','fixedstr' 
from dual where not exists(select 1 from ld_desk where labelbol = 'THEACCUMNLATEDPAID' and labeltype='fixedstr' and languagetype ='zh');

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','THEACCUMNLATEDPAID','The accumulated paid','fixedstr' 
from dual where not exists(select 1 from ld_desk where labelbol = 'THEACCUMNLATEDPAID' and labeltype='fixedstr' and languagetype ='en');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','BUSINESSPERSONNEL','业务人员','fixedstr' 
from dual where not exists(select 1 from ld_desk where labelbol = 'BUSINESSPERSONNEL' and labeltype='fixedstr' and languagetype ='zh');

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','BUSINESSPERSONNEL','Business personnel','fixedstr' 
from dual where not exists(select 1 from ld_desk where labelbol = 'BUSINESSPERSONNEL' and labeltype='fixedstr' and languagetype ='en');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','PERIODTIME','期间','fixedstr' 
from dual where not exists(select 1 from ld_desk where labelbol = 'PERIODTIME' and labeltype='fixedstr' and languagetype ='zh');

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','PERIODTIME','Period Time','fixedstr' 
from dual where not exists(select 1 from ld_desk where labelbol = 'PERIODTIME' and labeltype='fixedstr' and languagetype ='en');
delimiter;

UPDATE ld_field SET presence=0 where tabid =(SELECT tabid FROM ld_tab WHERE name='users') AND columnname IN ('hour_format','start_hour');
delimiter;

select usereportid into @id from ld_usereport where name='Eachprojectcontractincomestatisticsreport';

DELETE FROM ld_usereportcolumns WHERE Usereportid=@id AND columns LIKE 'ld_potentialscf:cf_1556:cf_1556:Potentials_%';

insert into ld_usereportcolumns(id,Usereportid,columns,Sequence,columnshow,realcolumns,realencolumns) 
select '', @id, 'ld_salesordercf:cf_1616:cf_1616:SalesOrder_cf_1616:N', 11, 1, 'ld_salesordercf:cf_1616:cf_1616:SalesOrder_工程进度:V','ld_salesordercf:cf_1616:cf_1616:SalesOrder_Progress:V'   
from dual where not exists(select 1 from ld_usereportcolumns where Usereportid=@id and realcolumns like 'ld_salesordercf:cf_1616:cf_1616:SalesOrder_%');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) 
select 'zh','ISNULL','为空值','jspop' 
from dual where not EXISTS(select 1 from ld_desk where languagetype='zh' and labelbol='ISNULL' and Labeltype='jspop');

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) 
select 'en','ISNULL','IS NULL','jspop' 
from dual where not EXISTS(select 1 from ld_desk  where languagetype='en' and labelbol='ISNULL' and Labeltype='jspop');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) 
select 'zh','ISNOTNULL','不为空值','jspop' 
from dual where not EXISTS(select 1 from ld_desk where languagetype='zh' and labelbol='ISNOTNULL' and Labeltype='jspop');

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) 
select 'en','ISNOTNULL','IS NOT NULL','jspop' 
from dual where not EXISTS(select 1 from ld_desk  where languagetype='en' and labelbol='ISNOTNULL' and Labeltype='jspop');
delimiter;

SELECT tabid INTO @tabid FROM ld_tab WHERE NAME = 'CashBill';
SELECT COUNT(fieldid) INTO @count FROM ld_field WHERE columnname = 'smownerid' AND tabid = @tabid ORDER BY fieldid DESC;
SELECT MAX(fieldid) INTO @fieldid FROM ld_field WHERE columnname = 'smownerid' AND tabid = @tabid ORDER BY fieldid DESC;
DELETE FROM ld_field WHERE fieldid = @fieldid AND 1 < @count;
delimiter;

call getallprofile('LessionPlan');
delimiter;

select tabid into @tabid from ld_tab where name = 'Events';
insert into ld_quickactions(tabid,related_tabid,sequence,presence)
select @tabid,-1,1,0 from dual 
where not EXISTS(select 1 from ld_quickactions  where tabid=@tabid and related_tabid=-1);
UPDATE ld_quickactions SET sequence=2 where tabid=@tabid AND related_tabid=-5; 
delimiter;

UPDATE ld_field SET presence=1 WHERE columnname='purchaseorder_id' AND tabid=(SELECT tabid FROM ld_tab WHERE name='PurchaseInvoice');
UPDATE ld_field SET displaytype=1 WHERE columnname='terms_conditions' AND tabid=(SELECT tabid FROM ld_tab WHERE name='PurchaseInvoice');

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'zh','DTPGTTPDCFS','日期，时间请去-产品明细自定义字段设置','fixedstr' from dual where not EXISTS(select 1 from ld_desk where languagetype='zh' and labelbol='DTPGTTPDCFS' and Labeltype='fixedstr');

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'en','DTPGTTPDCFS','Date, Time, please go to the product details custom field settings','fixedstr' from dual where not EXISTS(select 1 from ld_desk  where languagetype='en' and labelbol='DTPGTTPDCFS' and Labeltype='fixedstr');
delimiter;

UPDATE ld_field SET displaytype=3 WHERE columnname='purchaseorder_id' AND tabid=(SELECT tabid FROM ld_tab WHERE name='PurchaseInvoice');

UPDATE ld_field SET displaytype=3 WHERE columnname='purchaseorder_id' AND tabid=(SELECT tabid FROM ld_tab WHERE name='SendCashBill');
delimiter;

select tabid into @tabid from ld_tab where `name` = 'LessionPlan';
select actionid into @actionid from ld_actionmapping where actionname = 'Share';
DELETE from ld_profileallpermission where tabid = @tabid and operation = @actionid;
delete from ld_profile2standardpermissions where tabid = @tabid and operation = @actionid;
delimiter;

select tabid into @tabid from ld_tab where `name` = 'InventoryLedger';
select actionid into @actionid from ld_actionmapping where actionname = 'Export';
insert into ld_profileallpermission(tabid,operation)
select @tabid,@actionid from dual where not exists(select 1 from ld_profileallpermission where tabid = @tabid and operation = @actionid);
delimiter;

UPDATE ld_desk SET fieldlabel='Date, Time, please go to the product details custom field settings' where  languagetype='en' and labelbol='DTPGTTPDCFS' and Labeltype='fixedstr';
delimiter;

SELECT tabid INTO @tabid FROM ld_tab WHERE NAME = 'BankAccountSet';
SELECT fieldid INTO @fieldid FROM ld_field WHERE tabid = @tabid AND fieldname = 'currency_id';
DELETE FROM ld_def_org_field WHERE fieldid = @fieldid AND tabid != @tabid;
INSERT INTO ld_def_org_field (tabid,fieldid,visible,readonly)
SELECT @tabid,@fieldid,0,0
FROM DUAL WHERE  NOT EXISTS (SELECT 1 FROM ld_def_org_field WHERE tabid=@tabid AND fieldid=@fieldid);
UPDATE ld_profile2field SET tabid = @tabid WHERE fieldid = @fieldid AND tabid != @tabid;
delimiter;

call getallprofile('bankaccountset');
delimiter;
call fieldprofile('bankaccountset');
delimiter;

select tabid into @tabid from ld_tab where name='documents';
select actionid into @actionid from ld_actionmapping  where actionname='copy';
insert into ld_profileallpermission(tabid,operation)select @tabid,@actionid  from DUAL 
where not exists(select 1 from ld_profileallpermission where tabid=@tabid and operation=@actionid);
delimiter;

UPDATE ld_desk SET fieldlabel = '更改审批状态' WHERE labelbol = 'UPDATESTATE' AND Labeltype = 'fixedstr' AND languagetype = 'zh';
UPDATE ld_desk SET fieldlabel = 'Update approval state' WHERE labelbol = 'UPDATESTATE' AND Labeltype = 'fixedstr' AND languagetype = 'en';
delimiter;

call AddColumn('ld_workachments','size','varchar',100,NULL);
delimiter;

SELECT tabid INTO @tabid FROM ld_tab WHERE NAME = 'Accounts';
UPDATE ld_field set uitype=86 where columnname = 'nextcontactdate' and tablename = 'ld_account' and tabid = @tabid;
UPDATE ld_field set typeofdata='DT~O' where columnname = 'nextcontactdate' and tablename = 'ld_account' and tabid = @tabid;
alter table ld_account modify column nextcontactdate datetime;
delimiter;

select tabid into @tabid from ld_tab where name = 'HelpDesk';
update ld_field set uitype = 2 where tabid = @tabid and columnname = 'ticket_title' and tablename = 'ld_troubletickets';
delimiter;

call AddColumn('ld_workachments','size','varchar',100,NULL);
delimiter;

select tabid into @tabid from ld_tab where `name` = 'Accounts';
select tabid into @related_tabid from ld_tab where `name` = 'Home';
select id into @relation_id from ld_relatedlists_seq;
insert into ld_relatedlists(relation_id,tabid,related_tabid,name,sequence,label,presence,actions)
select @relation_id+1,@tabid,@related_tabid,'get_WorkReport',1,'Home',0,'' from dual 
where not EXISTS(select 1 from ld_relatedlists  where related_tabid = @related_tabid and tabid = @tabid); 
update ld_relatedlists_seq set id = (select max(relation_id) from ld_relatedlists);
delimiter;

select tabid into @tabid from ld_tab where `name` = 'Contacts';
select tabid into @related_tabid from ld_tab where `name` = 'Home';
select id into @relation_id from ld_relatedlists_seq;
insert into ld_relatedlists(relation_id,tabid,related_tabid,name,sequence,label,presence,actions)
select @relation_id+1,@tabid,@related_tabid,'get_WorkReport',1,'Home',0,'' from dual 
where not EXISTS(select 1 from ld_relatedlists  where related_tabid = @related_tabid and tabid = @tabid); 

UPDATE ld_tranlabel SET fieldlabel='短信记录' 
WHERE trantable='ld_tab' and tabid=(SELECT tabid FROM ld_tab WHERE name='CommunicationLog') AND languagetype='zh';
delimiter;
UPDATE ld_field SET masseditable=0 WHERE tabid=(SELECT tabid FROM ld_tab WHERE name='PutCash') AND columnname in ('outaccount','inaccount');
delimiter;
UPDATE ld_field SET masseditable=1 WHERE tabid=(SELECT tabid FROM ld_tab WHERE name='PaymentPlan') AND columnname in ('description');
delimiter;

SELECT MAX(relation_id) INTO @relationid FROM ld_relatedlists;
SELECT tabid INTO @tabid FROM ld_tab WHERE NAME='SalesBack';
SELECT tabid INTO @relatedtabid FROM ld_tab WHERE NAME='CashBack';
INSERT INTO ld_relatedlists(relation_id,tabid,related_tabid,NAME,sequence,label,presence,actions)
SELECT @relationid+1,@tabid,@relatedtabid,'get_cashback',9,'CashBack',0,'add' FROM DUAL
WHERE NOT EXISTS(SELECT 1 FROM ld_relatedlists WHERE NAME='get_cashback' AND tabid=@tabid);
UPDATE ld_relatedlists_seq SET id = (SELECT MAX(relation_id) FROM ld_relatedlists);
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'zh','Afinstpasdne3M','（附件格式不支持，建议附件大小不超过3M）','jspop' 
from dual where not EXISTS(select 1 from ld_desk where languagetype='zh' and labelbol='Afinstpasdne3M' and Labeltype='jspop');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'en','Afinstpasdne3M','(Attachment format is not supported, the proposed attachment size does not exceed 3M)','jspop' 
from dual where not EXISTS(select 1 from ld_desk  where languagetype='en' and labelbol='Afinstpasdne3M' and Labeltype='jspop');
delimiter;

select tabid into @tabid from ld_tab where name = 'Users';
select fieldid into @fieldid from ld_field where tablename = 'ld_users' and fieldname = 'viewothers';
UPDATE ld_tranlabel SET fieldlabel = '允许查看其他用户的单据(优先于角色)' where languagetype='zh' and tabid=@tabid and Relateid=@fieldid;
select fieldid into @fieldid from ld_field where tablename = 'ld_users' and fieldname = 'editothers';
UPDATE ld_tranlabel SET fieldlabel = '允许编辑其他用户的单据(优先于角色)' where languagetype='zh' and tabid=@tabid and Relateid=@fieldid;
select fieldid into @fieldid from ld_field where tablename = 'ld_users' and fieldname = 'delothers';
UPDATE ld_tranlabel SET fieldlabel = '允许删除其他用户的单据(优先于角色)' where languagetype='zh' and tabid=@tabid and Relateid=@fieldid;
delimiter;

CREATE TABLE IF NOT EXISTS `ld_appmoduleset` (
  `userid` int(11) NOT NULL DEFAULT '0',
  `modulename` varchar(100) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
delimiter;
-- 2015-06-03

UPDATE ld_desk SET fieldlabel='权限管理 - 权限列表' WHERE languagetype='zh' AND labelbol='ROLESHIERARCHY' AND Labeltype='fixedstr';
UPDATE ld_desk SET fieldlabel='权限名称' WHERE languagetype='zh' AND labelbol='ROLENAME' AND Labeltype='fixedstr';
UPDATE ld_desk SET fieldlabel='新增权限' WHERE languagetype='zh' AND labelbol='NEWROLE' AND Labeltype='fixedstr';
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'zh','ROCOSDOFA','关联单据只能选择已审批单据','fixedstr' from dual where not EXISTS(select 1 from ld_desk where languagetype='zh' and labelbol='ROCOSDOFA' and Labeltype='fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'en','ROCOSDOFA','Related Order can only select Order for approval','fixedstr' from dual where not EXISTS(select 1 from ld_desk  where languagetype='en' and labelbol='ROCOSDOFA' and Labeltype='fixedstr');
delimiter;

insert into ld_systems_deploy(deploy_value,deploy_type,description,setype)
select 0,68,'关联单据只能选择已审批单据 0：否，1：是','' from dual where not exists
(select 1 from ld_systems_deploy where deploy_type=68);
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) 
select 'zh','MODIFYEXPENSETO','修改报销人为','fixedstr' 
from dual where not EXISTS(select 1 from ld_desk where languagetype='zh' and labelbol='MODIFYEXPENSETO' and Labeltype='fixedstr');

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) 
select 'en','MODIFYEXPENSETO','Modify the person in expense','fixedstr' 
from dual where not EXISTS(select 1 from ld_desk  where languagetype='en' and labelbol='MODIFYEXPENSETO' and Labeltype='fixedstr');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) 
select 'zh','MODIFYOPERATORTO','修改经办人为','fixedstr' 
from dual where not EXISTS(select 1 from ld_desk where languagetype='zh' and labelbol='MODIFYOPERATORTO' and Labeltype='fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) 
select 'en','MODIFYOPERATORTO','Modify the person in operator','fixedstr' 
from dual where not EXISTS(select 1 from ld_desk  where languagetype='en' and labelbol='MODIFYOPERATORTO' and Labeltype='fixedstr');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'zh','KEYWORD','查找内容','fixedstr' 
from dual where not EXISTS(select 1 from ld_desk where languagetype='zh' and labelbol='KEYWORD' and Labeltype='fixedstr');

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'en','KEYWORD','keyword','fixedstr' 
from dual where not EXISTS(select 1 from ld_desk  where languagetype='en' and labelbol='KEYWORD' and Labeltype='fixedstr');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'zh','SETFIELD','设置字段','fixedstr' 
from dual where not EXISTS(select 1 from ld_desk where languagetype='zh' and labelbol='SETFIELD' and Labeltype='fixedstr');

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'en','SETFIELD','Set field','fixedstr' 
from dual where not EXISTS(select 1 from ld_desk  where languagetype='en' and labelbol='SETFIELD' and Labeltype='fixedstr');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'zh','ISACAILABLE','是否可用','fixedstr' 
from dual where not EXISTS(select 1 from ld_desk where languagetype='zh' and labelbol='ISACAILABLE' and Labeltype='fixedstr');

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'en','ISACAILABLE','Is available','fixedstr' 
from dual where not EXISTS(select 1 from ld_desk  where languagetype='en' and labelbol='ISACAILABLE' and Labeltype='fixedstr');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'zh','O5SFAA','最多仅允许设置5个查找字段','jspop' 
from dual where not EXISTS(select 1 from ld_desk where languagetype='zh' and labelbol='O5SFAA' and Labeltype='jspop');

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'en','O5SFAA','Only 5 search fields are allowed','jspop' 
from dual where not EXISTS(select 1 from ld_desk  where languagetype='en' and labelbol='O5SFAA' and Labeltype='jspop');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'zh','DSFMFFQOTSTT5OTQR','说明：支持多字段模糊查询，仅显示符合条件的前5条数据。','fixedstr' 
from dual where not EXISTS(select 1 from ld_desk where languagetype='zh' and labelbol='DSFMFFQOTSTT5OTQR' and Labeltype='fixedstr');

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'en','DSFMFFQOTSTT5OTQR','Description: Support for multi field fuzzy query, only to show the top 5 of the query result.','fixedstr' 
from dual where not EXISTS(select 1 from ld_desk  where languagetype='en' and labelbol='DSFMFFQOTSTT5OTQR' and Labeltype='fixedstr');
delimiter;

SELECT tabid INTO @tabid FROM ld_tab WHERE name='Accounts';
SELECT fieldname INTO @fieldname FROM ld_entityname WHERE modulename='Accounts';
UPDATE ld_field SET searchfieldtype=0 WHERE tabid=@tabid AND columnname IN (@fieldname,'accountname','account_no');
delimiter;

SELECT tabid INTO @tabid FROM ld_tab WHERE name='Contacts';
SELECT fieldname INTO @fieldname FROM ld_entityname WHERE modulename='Contacts';
UPDATE ld_field SET searchfieldtype=0 WHERE tabid=@tabid AND columnname IN (@fieldname,'lastname','contact_no','accountid');
delimiter;

SELECT tabid INTO @tabid FROM ld_tab WHERE name='Potentials';
SELECT fieldname INTO @fieldname FROM ld_entityname WHERE modulename='Potentials';
UPDATE ld_field SET searchfieldtype=0 WHERE tabid=@tabid AND columnname IN (@fieldname,'potentialname','potential_no','accountid');
delimiter;

SELECT tabid INTO @tabid FROM ld_tab WHERE name='Project';
SELECT fieldname INTO @fieldname FROM ld_entityname WHERE modulename='Project';
UPDATE ld_field SET searchfieldtype=0 WHERE tabid=@tabid AND columnname IN (@fieldname,'projectname','project_no','accountid');
delimiter;

SELECT tabid INTO @tabid FROM ld_tab WHERE name='PurchaseOrder';
SELECT fieldname INTO @fieldname FROM ld_entityname WHERE modulename='PurchaseOrder';
UPDATE ld_field SET searchfieldtype=0 WHERE tabid=@tabid AND columnname IN ('@fieldname','purchaseorder_no','subject');
delimiter;

SELECT tabid INTO @tabid FROM ld_tab WHERE name='Vendors';
SELECT fieldname INTO @fieldname FROM ld_entityname WHERE modulename='Vendors';
UPDATE ld_field SET searchfieldtype=0 WHERE tabid=@tabid AND columnname IN (@fieldname,'vendorname','vendor_no');
delimiter;

SELECT tabid INTO @tabid FROM ld_tab WHERE name='VendorContact';
SELECT fieldname INTO @fieldname FROM ld_entityname WHERE modulename='VendorContact';
UPDATE ld_field SET searchfieldtype=0 WHERE tabid=@tabid AND columnname IN (@fieldname,'lastname','vendorcontact_no');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'zh','DSNCOCOTSTP5TQR','说明：由于未选择客户，仅显示符合条件的前5条数据。','fixedstr' 
from dual where not EXISTS(select 1 from ld_desk where languagetype='zh' and labelbol='DSNCOCOTSTP5TQR' and Labeltype='fixedstr');

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'en','DSNCOCOTSTP5TQR','Description: Since no choice of customers, only to show the top 5 of the query result.','fixedstr' 
from dual where not EXISTS(select 1 from ld_desk  where languagetype='en' and labelbol='DSNCOCOTSTP5TQR' and Labeltype='fixedstr');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'zh','ISNOTALLOWEDTODELETETOACCOUNTS','有关联单据时不允许删除{$Accounts.Accounts}','fixedstr' from dual 
where not EXISTS(select 1 from ld_desk  where languagetype='zh' and labelbol='ISNOTALLOWEDTODELETETOACCOUNTS' and Labeltype='fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'en','ISNOTALLOWEDTODELETETOACCOUNTS','Do not allowed to delete {$Accounts.Accounts} when exists associated data','fixedstr' from dual 
where not EXISTS(select 1 from ld_desk  where languagetype='en' and labelbol='ISNOTALLOWEDTODELETETOACCOUNTS' and Labeltype='fixedstr');
delimiter;

select tabid into @tabid from ld_tab where name = 'Users';
select fieldid into @fieldid from ld_field where tabid = @tabid and columnname = 'phone_home' and tablename = 'ld_users';
update ld_tranlabel set fieldlabel = '电话' where tabid = @tabid and Relateid = @fieldid and languagetype = 'zh';
update ld_tranlabel set fieldlabel = 'Phone' where tabid = @tabid and Relateid = @fieldid and languagetype = 'en';
delimiter;

INSERT INTO ld_systems_deploy(deploy_value,deploy_type,description,setype)
SELECT '0',69,'有关联单据时不允许删除客户。1:否，0:是','' FROM DUAL WHERE NOT EXISTS
(SELECT 1 FROM ld_systems_deploy WHERE deploy_type=69);
delimiter;

UPDATE ld_field SET tablename = LOWER(tablename) WHERE tablename != '';
UPDATE ld_entityname SET tablename = LOWER(tablename) WHERE tablename != '';
UPDATE ld_relatedlists_rb SET rel_table = LOWER(rel_table) WHERE rel_table != '';
UPDATE ld_tranlabel SET trantable = LOWER(trantable) WHERE trantable != '';
UPDATE ld_ws_entity_fieldtype SET table_name = LOWER(table_name) WHERE table_name != '';
UPDATE ld_ws_entity_name SET table_name = LOWER(table_name) WHERE table_name != '';
UPDATE ld_ws_entity_tables SET table_name = LOWER(table_name) WHERE table_name != '';
delimiter;

UPDATE ld_cvcolumnlist SET columnname = CONCAT('ld',SUBSTR(columnname,3,LENGTH(columnname))) WHERE SUBSTR(columnname,1,2) = 'LD';
UPDATE ld_tabwithproductview SET COLUMNS = CONCAT('ld',SUBSTR(COLUMNS,3,LENGTH(COLUMNS))) WHERE SUBSTR(COLUMNS,1,2) = 'LD';
UPDATE ld_cvcolumnlistsort SET columnname = CONCAT('ld',SUBSTR(columnname,3,LENGTH(columnname))) WHERE SUBSTR(columnname,1,2) = 'LD';
UPDATE ld_automaticreminds SET columnname = CONCAT('ld',SUBSTR(columnname,3,LENGTH(columnname))) WHERE SUBSTR(columnname,1,2) = 'LD';
UPDATE ld_autoadvfilter SET columnname = CONCAT('ld',SUBSTR(columnname,3,LENGTH(columnname))) WHERE SUBSTR(columnname,1,2) = 'LD';
UPDATE ld_autostdfilter SET columnname = CONCAT('ld',SUBSTR(columnname,3,LENGTH(columnname))) WHERE SUBSTR(columnname,1,2) = 'LD';
UPDATE ld_autotaskfilter SET columnname = CONCAT('ld',SUBSTR(columnname,3,LENGTH(columnname))) WHERE SUBSTR(columnname,1,2) = 'LD';
UPDATE ld_cvadvfilter SET columnname = CONCAT('ld',SUBSTR(columnname,3,LENGTH(columnname))) WHERE SUBSTR(columnname,1,2) = 'LD';
UPDATE ld_cvstdfilter SET columnname = CONCAT('ld',SUBSTR(columnname,3,LENGTH(columnname))) WHERE SUBSTR(columnname,1,2) = 'LD';
UPDATE ld_relcriteria SET columnname = CONCAT('ld',SUBSTR(columnname,3,LENGTH(columnname))) WHERE SUBSTR(columnname,1,2) = 'LD';
delimiter;

UPDATE ld_remindcvadvfilter SET columnname = CONCAT('ld',SUBSTR(columnname,3,LENGTH(columnname))) WHERE SUBSTR(columnname,1,2) = 'LD';
UPDATE ld_remindcvstdfilter SET columnname = CONCAT('ld',SUBSTR(columnname,3,LENGTH(columnname))) WHERE SUBSTR(columnname,1,2) = 'LD';
UPDATE ld_reportdatefilter SET datecolumnname = CONCAT('ld',SUBSTR(datecolumnname,3,LENGTH(datecolumnname))) WHERE SUBSTR(datecolumnname,1,2) = 'LD';
UPDATE ld_reportsortcol SET columnname = CONCAT('ld',SUBSTR(columnname,3,LENGTH(columnname))) WHERE SUBSTR(columnname,1,2) = 'LD';
UPDATE ld_reportsummary SET columnname = CONCAT(SUBSTR(columnname,1,3),'ld',SUBSTR(columnname,6,LENGTH(columnname))) WHERE SUBSTR(columnname,4,2) = 'LD';
UPDATE ld_selectcolumn SET columnname = CONCAT('ld',SUBSTR(columnname,3,LENGTH(columnname))) WHERE SUBSTR(columnname,1,2) = 'LD';
UPDATE ld_usereportadv SET columnname = CONCAT('ld',SUBSTR(columnname,3,LENGTH(columnname))) WHERE SUBSTR(columnname,1,2) = 'LD';
UPDATE ld_usereportbasic SET COLUMNS = CONCAT('ld',SUBSTR(COLUMNS,3,LENGTH(COLUMNS))) WHERE SUBSTR(COLUMNS,1,2) = 'LD';
UPDATE ld_usereportcolumns SET COLUMNS = CONCAT('ld',SUBSTR(COLUMNS,3,LENGTH(COLUMNS))) WHERE SUBSTR(COLUMNS,1,2) = 'LD';
UPDATE ld_usereportcolumns SET realcolumns = CONCAT('ld',SUBSTR(realcolumns,3,LENGTH(realcolumns))) WHERE SUBSTR(realcolumns,1,2) = 'LD';
UPDATE ld_usereportcolumns SET realencolumns = CONCAT('ld',SUBSTR(realencolumns,3,LENGTH(realencolumns))) WHERE SUBSTR(realencolumns,1,2) = 'LD';
delimiter;

SELECT tabid INTO @tabid FROM ld_tab WHERE name='PurchaseOrder';
SELECT fieldname INTO @fieldname FROM ld_entityname WHERE modulename='PurchaseOrder';
UPDATE ld_field SET searchfieldtype=0 WHERE tabid=@tabid AND columnname IN ('@fieldname','purchaseorder_no','subject','vendorname');
delimiter;

SELECT tabid INTO @tabid FROM ld_tab WHERE name='VendorContact';
SELECT fieldname INTO @fieldname FROM ld_entityname WHERE modulename='VendorContact';
UPDATE ld_field SET searchfieldtype=0 WHERE tabid=@tabid AND columnname IN (@fieldname,'lastname','vendorcontact_no','vendorname');
delimiter;

UPDATE ld_desk SET fieldlabel = '首页组件视图布局样式' WHERE languagetype = 'zh' AND labelbol = 'LBL_HOMECONTROLLAYOUT' AND Labeltype = 'fixedstr';
delimiter;
-- 2015-06-11

SELECT MAX(fieldtypeid) INTO @fieldtypeid FROM ld_ws_fieldtype;
INSERT INTO ld_ws_fieldtype(fieldtypeid,uitype,fieldtype) SELECT @fieldtypeid+1,240,'reference' FROM DUAL 
WHERE NOT EXISTS(SELECT 1 FROM ld_ws_fieldtype WHERE uitype = 240);
delimiter;

SELECT fieldtypeid into @fieldtypeid FROM ld_ws_fieldtype where uitype = 240;
INSERT INTO ld_ws_referencetype(fieldtypeid,TYPE) SELECT @fieldtypeid,'HelpDesk' FROM DUAL 
WHERE NOT EXISTS(SELECT 1 FROM ld_ws_referencetype WHERE fieldtypeid = @fieldtypeid);
delimiter;

SELECT MAX(fieldtypeid) INTO @fieldtypeid FROM ld_ws_fieldtype;
INSERT INTO ld_ws_fieldtype(fieldtypeid,uitype,fieldtype) SELECT @fieldtypeid+1,241,'reference' FROM DUAL 
WHERE NOT EXISTS(SELECT 1 FROM ld_ws_fieldtype WHERE uitype = 241);
delimiter;

SELECT fieldtypeid into @fieldtypeid FROM ld_ws_fieldtype where uitype = 241;
INSERT INTO ld_ws_referencetype(fieldtypeid,TYPE) SELECT @fieldtypeid,'ProjectTask' FROM DUAL 
WHERE NOT EXISTS(SELECT 1 FROM ld_ws_referencetype WHERE fieldtypeid = @fieldtypeid);
delimiter;

SELECT MAX(fieldtypeid) INTO @fieldtypeid FROM ld_ws_fieldtype;
INSERT INTO ld_ws_fieldtype(fieldtypeid,uitype,fieldtype) SELECT @fieldtypeid+1,243,'reference' FROM DUAL 
WHERE NOT EXISTS(SELECT 1 FROM ld_ws_fieldtype WHERE uitype = 243);
delimiter;

SELECT fieldtypeid into @fieldtypeid FROM ld_ws_fieldtype where uitype = 243;
INSERT INTO ld_ws_referencetype(fieldtypeid,TYPE) SELECT @fieldtypeid,'ServiceContracts' FROM DUAL 
WHERE NOT EXISTS(SELECT 1 FROM ld_ws_referencetype WHERE fieldtypeid = @fieldtypeid);
delimiter;

SELECT MAX(fieldtypeid) INTO @fieldtypeid FROM ld_ws_fieldtype;
INSERT INTO ld_ws_fieldtype(fieldtypeid,uitype,fieldtype) SELECT @fieldtypeid+1,244,'reference' FROM DUAL 
WHERE NOT EXISTS(SELECT 1 FROM ld_ws_fieldtype WHERE uitype = 244);
delimiter;

SELECT fieldtypeid into @fieldtypeid FROM ld_ws_fieldtype where uitype = 244;
INSERT INTO ld_ws_referencetype(fieldtypeid,TYPE) SELECT @fieldtypeid,'Accounts' FROM DUAL 
WHERE NOT EXISTS(SELECT 1 FROM ld_ws_referencetype WHERE fieldtypeid = @fieldtypeid);
delimiter;

SELECT MAX(fieldtypeid) INTO @fieldtypeid FROM ld_ws_fieldtype;
INSERT INTO ld_ws_fieldtype(fieldtypeid,uitype,fieldtype) SELECT @fieldtypeid+1,245,'reference' FROM DUAL 
WHERE NOT EXISTS(SELECT 1 FROM ld_ws_fieldtype WHERE uitype = 245);
delimiter;

SELECT fieldtypeid into @fieldtypeid FROM ld_ws_fieldtype where uitype = 245;
INSERT INTO ld_ws_referencetype(fieldtypeid,TYPE) SELECT @fieldtypeid,'Contacts' FROM DUAL 
WHERE NOT EXISTS(SELECT 1 FROM ld_ws_referencetype WHERE fieldtypeid = @fieldtypeid);
delimiter;

SELECT MAX(fieldtypeid) INTO @fieldtypeid FROM ld_ws_fieldtype;
INSERT INTO ld_ws_fieldtype(fieldtypeid,uitype,fieldtype) SELECT @fieldtypeid+1,800,'reference' FROM DUAL 
WHERE NOT EXISTS(SELECT 1 FROM ld_ws_fieldtype WHERE uitype = 800);
delimiter;

SELECT fieldtypeid into @fieldtypeid FROM ld_ws_fieldtype where uitype = 800;
INSERT INTO ld_ws_referencetype(fieldtypeid,TYPE) SELECT @fieldtypeid,'SalesBack' FROM DUAL 
WHERE NOT EXISTS(SELECT 1 FROM ld_ws_referencetype WHERE fieldtypeid = @fieldtypeid);
delimiter;

SELECT MAX(fieldtypeid) INTO @fieldtypeid FROM ld_ws_fieldtype;
INSERT INTO ld_ws_fieldtype(fieldtypeid,uitype,fieldtype) SELECT @fieldtypeid+1,801,'reference' FROM DUAL 
WHERE NOT EXISTS(SELECT 1 FROM ld_ws_fieldtype WHERE uitype = 801);
delimiter;

SELECT fieldtypeid into @fieldtypeid FROM ld_ws_fieldtype where uitype = 801;
INSERT INTO ld_ws_referencetype(fieldtypeid,TYPE) SELECT @fieldtypeid,'PurchaseBack' FROM DUAL 
WHERE NOT EXISTS(SELECT 1 FROM ld_ws_referencetype WHERE fieldtypeid = @fieldtypeid);
delimiter;

SELECT MAX(fieldtypeid) INTO @fieldtypeid FROM ld_ws_fieldtype;
INSERT INTO ld_ws_fieldtype(fieldtypeid,uitype,fieldtype) SELECT @fieldtypeid+1,79,'reference' FROM DUAL 
WHERE NOT EXISTS(SELECT 1 FROM ld_ws_fieldtype WHERE uitype = 79);
delimiter;

SELECT fieldtypeid into @fieldtypeid FROM ld_ws_fieldtype where uitype = 79;
INSERT INTO ld_ws_referencetype(fieldtypeid,TYPE) SELECT @fieldtypeid,'PurchaseOrder' FROM DUAL 
WHERE NOT EXISTS(SELECT 1 FROM ld_ws_referencetype WHERE fieldtypeid = @fieldtypeid);
delimiter;

UPDATE ld_settings_field SET active = 1 WHERE blockid = '3' AND name = 'EMAILTEMPLATES' ;
UPDATE ld_settings_field SET active = 1 WHERE blockid = '3' AND name = 'SMS_templates' ;
UPDATE ld_settings_field SET active = 1 WHERE blockid = '5' AND name = 'LBL_SECURITYCODE_SET' ;
delimiter;
UPDATE ld_desk SET fieldlabel = '已批准' WHERE labelbol = 'Approved' AND languagetype = 'zh';
delimiter;
-- 2015-06-12

select tabid into @tabid from ld_tab where name='Users';
update ld_field set presence=1 where tabid=@tabid and columnname='currency_id';
delimiter;
UPDATE ld_desk SET fieldlabel='定义权限并设置操作权限及字段权限' WHERE languagetype='zh' AND labelbol='LBL_ROLE_DESCRIPTION' AND Labeltype='fixedstr';
UPDATE ld_desk SET fieldlabel='导出选定记录' WHERE languagetype='zh' AND labelbol='ExportSelectedRecords' AND Labeltype='fixedstr';
delimiter;
-- 2015-06-16

insert into ld_usereport(usereportid,name,reportlabel,tabids,basicfilter,advfilter,Setcolumns,Parent_id,sequence,reporttype,pagewidthpercent) 
select '','ZHONGYUANREPORTS','中源报表',0,0,0,0,0,6,0,100 
from dual where not exists(select usereportid from ld_usereport where name='ZHONGYUANREPORTS');
SELECT usereportid into @id from ld_usereport where name='ZHONGYUANREPORTS';
SELECT tabid into @tid from ld_tab where name='Project';
insert into ld_usereport(usereportid,name,reportlabel,tabids,basicfilter,advfilter,Setcolumns,Parent_id,sequence,reporttype,pagewidthpercent) 
select '','HighAndNewTechnologyEnterpriseSchedule','高企进度表',@tid,1,0,1,@id,1,5,100 
from dual where not exists(select usereportid from ld_usereport where name='HighAndNewTechnologyEnterpriseSchedule');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'zh','ZHONGYUANREPORTS','中源报表','fixedstr' from dual where not EXISTS(select 1 from ld_desk where languagetype='zh' and labelbol='ZHONGYUANREPORTS' and Labeltype='fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'en','ZHONGYUANREPORTS','ZhongYuan Report','fixedstr' from dual where not EXISTS(select 1 from ld_desk  where languagetype='en' and labelbol='ZHONGYUANREPORTS' and Labeltype='fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'zh','HighAndNewTechnologyEnterpriseSchedule','高企进度表','fixedstr' from dual where not EXISTS(select 1 from ld_desk where languagetype='zh' and labelbol='HighAndNewTechnologyEnterpriseSchedule' and Labeltype='fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'en','HighAndNewTechnologyEnterpriseSchedule','High And New Technology Enterprise Schedule','fixedstr' from dual where not EXISTS(select 1 from ld_desk  where languagetype='en' and labelbol='HighAndNewTechnologyEnterpriseSchedule' and Labeltype='fixedstr');
delimiter;

select usereportid into @id from ld_usereport where name='HighAndNewTechnologyEnterpriseSchedule';
insert into ld_usereportbasic(id,Usereportid,columns,Defaultvalue,Sequence) 
select '',@id,'ld_projectcf:cf_977:cf_977:Project_cf_977:D','thisstartmonth~thisendmonth',3  
from dual where not exists(select usereportid from ld_usereportbasic where Usereportid=@id and Sequence=3);
insert into ld_usereportbasic(id,Usereportid,columns,Defaultvalue,Sequence) 
select '',@id,'ld_projectcf:cf_1479:cf_1479:Project_cf_1479:I','',4 
from dual where not exists(select usereportid from ld_usereportbasic where Usereportid=@id and Sequence=4);
insert into ld_usereportbasic(id,Usereportid,columns,Defaultvalue,Sequence) 
select '',@id,'ld_project:cf_1478:cf_1478:Project_cf_1478:I','',5 
from dual where not exists(select usereportid from ld_usereportbasic where Usereportid=@id and Sequence=5);
insert into ld_usereportbasic(id,Usereportid,columns,Defaultvalue,Sequence) 
select '',@id,'ld_account:accountname:accountname:Accounts_accountname:I','',6  
from dual where not exists(select usereportid from ld_usereportbasic where Usereportid=@id and Sequence=6);
delimiter;

select usereportid into @id from ld_usereport where name='HighAndNewTechnologyEnterpriseSchedule';

insert into ld_usereportcolumns(id,Usereportid,columns,Sequence,columnshow,realcolumns,realencolumns) 
select '', @id, 'ld_users:last_name:last_name:Users_last_name:V', 1, 1, 'ld_users:last_name:last_name:Users_项目经理:V','ld_users:last_name:last_name:Users_last_name:V'
from dual where not exists(select 1 from ld_usereportcolumns where Usereportid=@id and realcolumns like 'ld_users:last_name:last_name:Users_%');

insert into ld_usereportcolumns(id,Usereportid,columns,Sequence,columnshow,realcolumns,realencolumns) 
select '', @id, 'ld_account:accountname:accountname:Accounts_accountname:V', 1, 1, 'ld_account:accountname:accountname:Accounts_客户名称:V','ld_account:accountname:accountname:Accounts_accountname:V'
from dual where not exists(select 1 from ld_usereportcolumns where Usereportid=@id and realcolumns like 'ld_account:accountname:accountname:Accounts_%');
insert into ld_usereportcolumns(id,Usereportid,columns,Sequence,columnshow,realcolumns,realencolumns) 

select '', @id, 'ld_projectcf:cf_1473:cf_1473:Project_cf_1473:V', 1, 1, 'ld_projectcf:cf_1473:cf_1473:Project_技术领域(一级):V','ld_projectcf:cf_1473:cf_1473:Project_cf_1473:V'
from dual where not exists(select 1 from ld_usereportcolumns where Usereportid=@id and realcolumns like 'ld_projectcf:cf_1473:cf_1473:Project_%');

insert into ld_usereportcolumns(id,Usereportid,columns,Sequence,columnshow,realcolumns,realencolumns) 
select '', @id, 'ld_projectcf:cf_1474:cf_1474:Project_cf_1474:V', 1, 1, 'ld_projectcf:cf_1474:cf_1474:Project_技术领域(二级):V','ld_projectcf:cf_1474:cf_1474:Project_cf_1474:V'
from dual where not exists(select 1 from ld_usereportcolumns where Usereportid=@id and realcolumns like 'ld_projectcf:cf_1474:cf_1474:Project_%');

insert into ld_usereportcolumns(id,Usereportid,columns,Sequence,columnshow,realcolumns,realencolumns) 
select '', @id, 'ld_projectcf:cf_1475:cf_1475:Project_cf_1475:V', 1, 1, 'ld_projectcf:cf_1475:cf_1475:Project_技术领域(三级):V','ld_projectcf:cf_1475:cf_1475:Project_cf_1475:V'
from dual where not exists(select 1 from ld_usereportcolumns where Usereportid=@id and realcolumns like 'ld_projectcf:cf_1475:cf_1475:Project_%');

insert into ld_usereportcolumns(id,Usereportid,columns,Sequence,columnshow,realcolumns,realencolumns) 
select '', @id, 'ld_projectcf:cf_1479:cf_1479:Project_cf_1479:V', 1, 1, 'ld_projectcf:cf_1479:cf_1479:Project_申报年度:V','ld_projectcf:cf_1479:cf_1479:Project_cf_1479:V'
from dual where not exists(select 1 from ld_usereportcolumns where Usereportid=@id and realcolumns like 'ld_projectcf:cf_1479:cf_1479:Project_%');

insert into ld_usereportcolumns(id,Usereportid,columns,Sequence,columnshow,realcolumns,realencolumns) 
select '', @id, 'ld_projectcf:cf_977:cf_977:Project_cf_977:V', 1, 1, 'ld_projectcf:cf_977:cf_977:Project_申报月份:V','ld_projectcf:cf_977:cf_977:Project_cf_977:V'
from dual where not exists(select 1 from ld_usereportcolumns where Usereportid=@id and realcolumns like 'ld_projectcf:cf_977:cf_977:Project_%');

insert into ld_usereportcolumns(id,Usereportid,columns,Sequence,columnshow,realcolumns,realencolumns) 
select '', @id, 'ld_projectcf:cf_1285:cf_1285:Project_cf_1285:V', 1, 1, 'ld_projectcf:cf_1285:cf_1285:Project_所属城市:V','ld_projectcf:cf_1285:cf_1285:Project_cf_1285:V'
from dual where not exists(select 1 from ld_usereportcolumns where Usereportid=@id and realcolumns like 'ld_projectcf:cf_1285:cf_1285:Project_%');

insert into ld_usereportcolumns(id,Usereportid,columns,Sequence,columnshow,realcolumns,realencolumns) 
select '', @id, 'ld_projectcf:cf_1286:cf_1286:Project_cf_1286:V', 1, 1, 'ld_projectcf:cf_1286:cf_1286:Project_所属地区:V','ld_projectcf:cf_1286:cf_1286:Project_cf_1286:V'
from dual where not exists(select 1 from ld_usereportcolumns where Usereportid=@id and realcolumns like 'ld_projectcf:cf_1286:cf_1286:Project_%');

insert into ld_usereportcolumns(id,Usereportid,columns,Sequence,columnshow,realcolumns,realencolumns) 
select '', @id, 'ld_projectcf:cf_1287:cf_1287:Project_cf_1287:V', 1, 1, 'ld_projectcf:cf_1287:cf_1287:Project_所属区域:V','ld_projectcf:cf_1287:cf_1287:Project_cf_1287:V'
from dual where not exists(select 1 from ld_usereportcolumns where Usereportid=@id and realcolumns like 'ld_projectcf:cf_1287:cf_1287:Project_%');

insert into ld_usereportcolumns(id,Usereportid,columns,Sequence,columnshow,realcolumns,realencolumns) 
select '', @id, 'ld_projectcf:cf_1289:cf_1289:Project_cf_1289:V', 1, 1, 'ld_projectcf:cf_1289:cf_1289:Project_业务经理:V','ld_projectcf:cf_1289:cf_1289:Project_cf_1289:V'
from dual where not exists(select 1 from ld_usereportcolumns where Usereportid=@id and realcolumns like 'ld_projectcf:cf_1289:cf_1289:Project_%');

insert into ld_usereportcolumns(id,Usereportid,columns,Sequence,columnshow,realcolumns,realencolumns) 
select '', @id, 'ld_project:cf_1478:cf_1478:Project_cf_1478:V', 1, 1, 'ld_project:cf_1478:cf_1478:Project_项目类别:V','ld_project:cf_1478:cf_1478:Project_cf_1478:V'
from dual where not exists(select 1 from ld_usereportcolumns where Usereportid=@id and realcolumns like 'ld_project:cf_1478:cf_1478:Project_%');

insert into ld_usereportcolumns(id,Usereportid,columns,Sequence,columnshow,realcolumns,realencolumns) 
select '', @id, 'u2:last_name:last_name:u2_last_name:V', 1, 1, 'u2:last_name:last_name:u2_进度经理:V','u2:last_name:last_name:u2_last_name:V' 
from dual where not exists(select 1 from ld_usereportcolumns where Usereportid=@id and realcolumns like 'u2:last_name:last_name:Project_%');

insert into ld_usereportcolumns(id,Usereportid,columns,Sequence,columnshow,realcolumns,realencolumns) 
select '', @id, 'ld_projecttaskcf:cf_1067:cf_1067:ProjectTask_cf_1067:V', 1, 1, 'ld_projecttaskcf:cf_1067:cf_1067:ProjectTask_启动时间:V','ld_projecttaskcf:cf_1067:cf_1067:ProjectTask_cf_1067:V'
from dual where not exists(select 1 from ld_usereportcolumns where Usereportid=@id and realcolumns like 'ld_projecttaskcf:cf_1067:cf_1067:ProjectTask_%');

insert into ld_usereportcolumns(id,Usereportid,columns,Sequence,columnshow,realcolumns,realencolumns) 
select '', @id, 'ld_projecttaskcf:cf_1068:cf_1068:ProjectTask_cf_1068:V', 1, 1, 'ld_projecttaskcf:cf_1068:cf_1068:ProjectTask_专利:V','ld_projecttaskcf:cf_1068:cf_1068:ProjectTask_cf_1068:V'
from dual where not exists(select 1 from ld_usereportcolumns where Usereportid=@id and realcolumns like 'ld_projecttaskcf:cf_1068:cf_1068:ProjectTask_%');

insert into ld_usereportcolumns(id,Usereportid,columns,Sequence,columnshow,realcolumns,realencolumns) 
select '', @id, 'ld_projecttaskcf:cf_1069:cf_1069:ProjectTask_cf_1069:V', 1, 1, 'ld_projecttaskcf:cf_1069:cf_1069:ProjectTask_RD/PS:V','ld_projecttaskcf:cf_1069:cf_1069:ProjectTask_cf_1069:V'
from dual where not exists(select 1 from ld_usereportcolumns where Usereportid=@id and realcolumns like 'ld_projecttaskcf:cf_1069:cf_1069:ProjectTask_%');

insert into ld_usereportcolumns(id,Usereportid,columns,Sequence,columnshow,realcolumns,realencolumns) 
select '', @id, 'ld_projecttaskcf:cf_1070:cf_1070:ProjectTask_cf_1070:V', 1, 1, 'ld_projecttaskcf:cf_1070:cf_1070:ProjectTask_成果转化:V','ld_projecttaskcf:cf_1070:cf_1070:ProjectTask_cf_1070:V'
from dual where not exists(select 1 from ld_usereportcolumns where Usereportid=@id and realcolumns like 'ld_projecttaskcf:cf_1070:cf_1070:ProjectTask_%');

insert into ld_usereportcolumns(id,Usereportid,columns,Sequence,columnshow,realcolumns,realencolumns) 
select '', @id, 'ld_projecttaskcf:cf_1071:cf_1071:ProjectTask_cf_1071:V', 1, 1, 'lld_projecttaskcf:cf_1071:cf_1071:ProjectTask_研发组织管理水平:V','ld_projecttaskcf:cf_1071:cf_1071:ProjectTask_cf_1071:V'
from dual where not exists(select 1 from ld_usereportcolumns where Usereportid=@id and realcolumns like 'ld_projecttaskcf:cf_1071:cf_1071:ProjectTask_%');

insert into ld_usereportcolumns(id,Usereportid,columns,Sequence,columnshow,realcolumns,realencolumns) 
select '', @id, 'ld_projecttaskcf:cf_1072:cf_1072:ProjectTask_cf_1072:V', 1, 1, 'ld_projecttaskcf:cf_1072:cf_1072:ProjectTask_人员:V','ld_projecttaskcf:cf_1072:cf_1072:ProjectTask_cf_1072:V'
from dual where not exists(select 1 from ld_usereportcolumns where Usereportid=@id and realcolumns like 'ld_projecttaskcf:cf_1072:cf_1072:ProjectTask_%');

insert into ld_usereportcolumns(id,Usereportid,columns,Sequence,columnshow,realcolumns,realencolumns) 
select '', @id, 'ld_projecttaskcf:cf_1073:cf_1073:ProjectTask_cf_1073:V', 1, 1, 'ld_projecttaskcf:cf_1073:cf_1073:ProjectTask_财务专审:V','ld_projecttaskcf:cf_1073:cf_1073:ProjectTask_cf_1073:V'
from dual where not exists(select 1 from ld_usereportcolumns where Usereportid=@id and realcolumns like 'ld_projecttaskcf:cf_1073:cf_1073:ProjectTask_%');

insert into ld_usereportcolumns(id,Usereportid,columns,Sequence,columnshow,realcolumns,realencolumns) 
select '', @id, 'ld_projecttaskcf:cf_1074:cf_1074:ProjectTask_cf_1074:V', 1, 1, 'ld_projecttaskcf:cf_1074:cf_1074:ProjectTask_定稿:V','ld_projecttaskcf:cf_1074:cf_1074:ProjectTask_cf_1074:V'
from dual where not exists(select 1 from ld_usereportcolumns where Usereportid=@id and realcolumns like 'ld_projecttaskcf:cf_1074:cf_1074:ProjectTask_%');

insert into ld_usereportcolumns(id,Usereportid,columns,Sequence,columnshow,realcolumns,realencolumns) 
select '', @id, 'ld_projecttask:projecttaskname:projecttaskname:ProjectTask_projecttaskname:V', 1, 1, 'ld_projecttask:projecttaskname:projecttaskname:ProjectTask_递交:V','ld_projecttask:projecttaskname:projecttaskname:ProjectTask_projecttaskname:V'
from dual where not exists(select 1 from ld_usereportcolumns where Usereportid=@id and realcolumns like 'ld_projecttask:projecttaskname:projecttaskname:ProjectTask_%');

insert into ld_usereportcolumns(id,Usereportid,columns,Sequence,columnshow,realcolumns,realencolumns) 
select '', @id, 'ld_projecttask:description:description:ProjectTask_description:V', 1, 1, 'ld_projecttask:description:description:ProjectTask_备注:V','ld_projecttask:description:description:ProjectTask_description:V'
from dual where not exists(select 1 from ld_usereportcolumns where Usereportid=@id and realcolumns like 'ld_projecttask:description:description:ProjectTask_%');
delimiter;
-- 2015-06-19

CREATE TABLE IF NOT EXISTS `ld_applabelset` (
  `labelname` varchar(100) NOT NULL default '',
  `htmlname` varchar(100) NOT NULL default '',
  `display` int(11) NOT NULL default '0',
  `sequence` int(11) NOT NULL default '0',
  `defaultshow` int(11) NOT NULL default '0'
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
delimiter;

insert into ld_applabelset(labelname,htmlname,display,sequence,defaultshow) 
select '消息','news',0,0,1 from dual where not EXISTS(select 1 from ld_applabelset where htmlname='news');
insert into ld_applabelset(labelname,htmlname,display,sequence,defaultshow) 
select '工作','work',0,1,0 from dual where not EXISTS(select 1 from ld_applabelset where htmlname='work');
insert into ld_applabelset(labelname,htmlname,display,sequence,defaultshow) 
select 'CRM','crm',0,2,0 from dual where not EXISTS(select 1 from ld_applabelset where htmlname='crm');
insert into ld_applabelset(labelname,htmlname,display,sequence,defaultshow) 
select '我','me',0,3,0 from dual where not EXISTS(select 1 from ld_applabelset where htmlname='me');
delimiter;
-- 2015-06-23

select tabid into @tabid from ld_tab where name='Users';
update ld_field set presence=1 where tabid=@tabid and columnname='currency_id';
delimiter;
UPDATE ld_desk SET fieldlabel='定义权限并设置操作权限及字段权限' WHERE languagetype='zh' AND labelbol='LBL_ROLE_DESCRIPTION' AND Labeltype='fixedstr';
UPDATE ld_desk SET fieldlabel='导出选定记录' WHERE languagetype='zh' AND labelbol='ExportSelectedRecords' AND Labeltype='fixedstr';
delimiter;

insert into ld_usereport(usereportid,name,reportlabel,tabids,basicfilter,advfilter,Setcolumns,Parent_id,sequence,reporttype,pagewidthpercent) 
select '','ZHONGYUANREPORTS','中源报表',0,0,0,0,0,6,0,100 
from dual where not exists(select usereportid from ld_usereport where name='ZHONGYUANREPORTS');

SELECT usereportid into @id from ld_usereport where name='ZHONGYUANREPORTS';
SELECT tabid into @tid from ld_tab where name='Project';
insert into ld_usereport(usereportid,name,reportlabel,tabids,basicfilter,advfilter,Setcolumns,Parent_id,sequence,reporttype,pagewidthpercent) 
select '','HighAndNewTechnologyEnterpriseSchedule','高企进度表',@tid,1,0,1,@id,1,5,100 
from dual where not exists(select usereportid from ld_usereport where name='HighAndNewTechnologyEnterpriseSchedule');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'zh','ZHONGYUANREPORTS','中源报表','fixedstr' from dual where not EXISTS(select 1 from ld_desk where languagetype='zh' and labelbol='ZHONGYUANREPORTS' and Labeltype='fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'en','ZHONGYUANREPORTS','ZhongYuan Report','fixedstr' from dual where not EXISTS(select 1 from ld_desk  where languagetype='en' and labelbol='ZHONGYUANREPORTS' and Labeltype='fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'zh','HighAndNewTechnologyEnterpriseSchedule','高企进度表','fixedstr' from dual where not EXISTS(select 1 from ld_desk where languagetype='zh' and labelbol='HighAndNewTechnologyEnterpriseSchedule' and Labeltype='fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'en','HighAndNewTechnologyEnterpriseSchedule','High And New Technology Enterprise Schedule','fixedstr' from dual where not EXISTS(select 1 from ld_desk  where languagetype='en' and labelbol='HighAndNewTechnologyEnterpriseSchedule' and Labeltype='fixedstr');
delimiter;

select usereportid into @id from ld_usereport where name='HighAndNewTechnologyEnterpriseSchedule';
insert into ld_usereportbasic(id,Usereportid,columns,Defaultvalue,Sequence) 
select '',@id,'ld_projectcf:cf_977:cf_977:Project_cf_977:D','thisstartmonth~thisendmonth',3  
from dual where not exists(select usereportid from ld_usereportbasic where Usereportid=@id and Sequence=3);

insert into ld_usereportbasic(id,Usereportid,columns,Defaultvalue,Sequence) 
select '',@id,'ld_projectcf:cf_1479:cf_1479:Project_cf_1479:I','',4 
from dual where not exists(select usereportid from ld_usereportbasic where Usereportid=@id and Sequence=4);

insert into ld_usereportbasic(id,Usereportid,columns,Defaultvalue,Sequence) 
select '',@id,'ld_project:cf_1478:cf_1478:Project_cf_1478:I','',5 
from dual where not exists(select usereportid from ld_usereportbasic where Usereportid=@id and Sequence=5);

insert into ld_usereportbasic(id,Usereportid,columns,Defaultvalue,Sequence) 
select '',@id,'ld_account:accountname:accountname:Accounts_accountname:I','',6  
from dual where not exists(select usereportid from ld_usereportbasic where Usereportid=@id and Sequence=6);
delimiter;

select usereportid into @id from ld_usereport where name='HighAndNewTechnologyEnterpriseSchedule';
insert into ld_usereportcolumns(id,Usereportid,columns,Sequence,columnshow,realcolumns,realencolumns) 
select '', @id, 'ld_users:last_name:last_name:Users_last_name:V', 1, 1, 'ld_users:last_name:last_name:Users_项目经理:V','ld_users:last_name:last_name:Users_last_name:V'
from dual where not exists(select 1 from ld_usereportcolumns where Usereportid=@id and realcolumns like 'ld_users:last_name:last_name:Users_%');

insert into ld_usereportcolumns(id,Usereportid,columns,Sequence,columnshow,realcolumns,realencolumns) 
select '', @id, 'ld_account:accountname:accountname:Accounts_accountname:V', 1, 1, 'ld_account:accountname:accountname:Accounts_客户名称:V','ld_account:accountname:accountname:Accounts_accountname:V'
from dual where not exists(select 1 from ld_usereportcolumns where Usereportid=@id and realcolumns like 'ld_account:accountname:accountname:Accounts_%');
insert into ld_usereportcolumns(id,Usereportid,columns,Sequence,columnshow,realcolumns,realencolumns) 

select '', @id, 'ld_projectcf:cf_1473:cf_1473:Project_cf_1473:V', 1, 1, 'ld_projectcf:cf_1473:cf_1473:Project_技术领域(一级):V','ld_projectcf:cf_1473:cf_1473:Project_cf_1473:V'
from dual where not exists(select 1 from ld_usereportcolumns where Usereportid=@id and realcolumns like 'ld_projectcf:cf_1473:cf_1473:Project_%');

insert into ld_usereportcolumns(id,Usereportid,columns,Sequence,columnshow,realcolumns,realencolumns) 
select '', @id, 'ld_projectcf:cf_1474:cf_1474:Project_cf_1474:V', 1, 1, 'ld_projectcf:cf_1474:cf_1474:Project_技术领域(二级):V','ld_projectcf:cf_1474:cf_1474:Project_cf_1474:V'
from dual where not exists(select 1 from ld_usereportcolumns where Usereportid=@id and realcolumns like 'ld_projectcf:cf_1474:cf_1474:Project_%');

insert into ld_usereportcolumns(id,Usereportid,columns,Sequence,columnshow,realcolumns,realencolumns) 
select '', @id, 'ld_projectcf:cf_1475:cf_1475:Project_cf_1475:V', 1, 1, 'ld_projectcf:cf_1475:cf_1475:Project_技术领域(三级):V','ld_projectcf:cf_1475:cf_1475:Project_cf_1475:V'
from dual where not exists(select 1 from ld_usereportcolumns where Usereportid=@id and realcolumns like 'ld_projectcf:cf_1475:cf_1475:Project_%');

insert into ld_usereportcolumns(id,Usereportid,columns,Sequence,columnshow,realcolumns,realencolumns) 
select '', @id, 'ld_projectcf:cf_1479:cf_1479:Project_cf_1479:V', 1, 1, 'ld_projectcf:cf_1479:cf_1479:Project_申报年度:V','ld_projectcf:cf_1479:cf_1479:Project_cf_1479:V'
from dual where not exists(select 1 from ld_usereportcolumns where Usereportid=@id and realcolumns like 'ld_projectcf:cf_1479:cf_1479:Project_%');

insert into ld_usereportcolumns(id,Usereportid,columns,Sequence,columnshow,realcolumns,realencolumns) 
select '', @id, 'ld_projectcf:cf_977:cf_977:Project_cf_977:V', 1, 1, 'ld_projectcf:cf_977:cf_977:Project_申报月份:V','ld_projectcf:cf_977:cf_977:Project_cf_977:V'
from dual where not exists(select 1 from ld_usereportcolumns where Usereportid=@id and realcolumns like 'ld_projectcf:cf_977:cf_977:Project_%');

insert into ld_usereportcolumns(id,Usereportid,columns,Sequence,columnshow,realcolumns,realencolumns) 
select '', @id, 'ld_projectcf:cf_1285:cf_1285:Project_cf_1285:V', 1, 1, 'ld_projectcf:cf_1285:cf_1285:Project_所属城市:V','ld_projectcf:cf_1285:cf_1285:Project_cf_1285:V'
from dual where not exists(select 1 from ld_usereportcolumns where Usereportid=@id and realcolumns like 'ld_projectcf:cf_1285:cf_1285:Project_%');

insert into ld_usereportcolumns(id,Usereportid,columns,Sequence,columnshow,realcolumns,realencolumns) 
select '', @id, 'ld_projectcf:cf_1286:cf_1286:Project_cf_1286:V', 1, 1, 'ld_projectcf:cf_1286:cf_1286:Project_所属地区:V','ld_projectcf:cf_1286:cf_1286:Project_cf_1286:V'
from dual where not exists(select 1 from ld_usereportcolumns where Usereportid=@id and realcolumns like 'ld_projectcf:cf_1286:cf_1286:Project_%');

insert into ld_usereportcolumns(id,Usereportid,columns,Sequence,columnshow,realcolumns,realencolumns) 
select '', @id, 'ld_projectcf:cf_1287:cf_1287:Project_cf_1287:V', 1, 1, 'ld_projectcf:cf_1287:cf_1287:Project_所属区域:V','ld_projectcf:cf_1287:cf_1287:Project_cf_1287:V'
from dual where not exists(select 1 from ld_usereportcolumns where Usereportid=@id and realcolumns like 'ld_projectcf:cf_1287:cf_1287:Project_%');

insert into ld_usereportcolumns(id,Usereportid,columns,Sequence,columnshow,realcolumns,realencolumns) 
select '', @id, 'ld_projectcf:cf_1289:cf_1289:Project_cf_1289:V', 1, 1, 'ld_projectcf:cf_1289:cf_1289:Project_业务经理:V','ld_projectcf:cf_1289:cf_1289:Project_cf_1289:V'
from dual where not exists(select 1 from ld_usereportcolumns where Usereportid=@id and realcolumns like 'ld_projectcf:cf_1289:cf_1289:Project_%');

insert into ld_usereportcolumns(id,Usereportid,columns,Sequence,columnshow,realcolumns,realencolumns) 
select '', @id, 'ld_project:cf_1478:cf_1478:Project_cf_1478:V', 1, 1, 'ld_project:cf_1478:cf_1478:Project_项目类别:V','ld_project:cf_1478:cf_1478:Project_cf_1478:V'
from dual where not exists(select 1 from ld_usereportcolumns where Usereportid=@id and realcolumns like 'ld_project:cf_1478:cf_1478:Project_%');

insert into ld_usereportcolumns(id,Usereportid,columns,Sequence,columnshow,realcolumns,realencolumns) 
select '', @id, 'u2:last_name:last_name:u2_last_name:V', 1, 1, 'u2:last_name:last_name:u2_进度经理:V','u2:last_name:last_name:u2_last_name:V' 
from dual where not exists(select 1 from ld_usereportcolumns where Usereportid=@id and realcolumns like 'u2:last_name:last_name:Project_%');

insert into ld_usereportcolumns(id,Usereportid,columns,Sequence,columnshow,realcolumns,realencolumns) 
select '', @id, 'ld_projecttaskcf:cf_1067:cf_1067:ProjectTask_cf_1067:V', 1, 1, 'ld_projecttaskcf:cf_1067:cf_1067:ProjectTask_启动时间:V','ld_projecttaskcf:cf_1067:cf_1067:ProjectTask_cf_1067:V'
from dual where not exists(select 1 from ld_usereportcolumns where Usereportid=@id and realcolumns like 'ld_projecttaskcf:cf_1067:cf_1067:ProjectTask_%');

insert into ld_usereportcolumns(id,Usereportid,columns,Sequence,columnshow,realcolumns,realencolumns) 
select '', @id, 'ld_projecttaskcf:cf_1068:cf_1068:ProjectTask_cf_1068:V', 1, 1, 'ld_projecttaskcf:cf_1068:cf_1068:ProjectTask_专利:V','ld_projecttaskcf:cf_1068:cf_1068:ProjectTask_cf_1068:V'
from dual where not exists(select 1 from ld_usereportcolumns where Usereportid=@id and realcolumns like 'ld_projecttaskcf:cf_1068:cf_1068:ProjectTask_%');

insert into ld_usereportcolumns(id,Usereportid,columns,Sequence,columnshow,realcolumns,realencolumns) 
select '', @id, 'ld_projecttaskcf:cf_1069:cf_1069:ProjectTask_cf_1069:V', 1, 1, 'ld_projecttaskcf:cf_1069:cf_1069:ProjectTask_RD/PS:V','ld_projecttaskcf:cf_1069:cf_1069:ProjectTask_cf_1069:V'
from dual where not exists(select 1 from ld_usereportcolumns where Usereportid=@id and realcolumns like 'ld_projecttaskcf:cf_1069:cf_1069:ProjectTask_%');

insert into ld_usereportcolumns(id,Usereportid,columns,Sequence,columnshow,realcolumns,realencolumns) 
select '', @id, 'ld_projecttaskcf:cf_1070:cf_1070:ProjectTask_cf_1070:V', 1, 1, 'ld_projecttaskcf:cf_1070:cf_1070:ProjectTask_成果转化:V','ld_projecttaskcf:cf_1070:cf_1070:ProjectTask_cf_1070:V'
from dual where not exists(select 1 from ld_usereportcolumns where Usereportid=@id and realcolumns like 'ld_projecttaskcf:cf_1070:cf_1070:ProjectTask_%');

insert into ld_usereportcolumns(id,Usereportid,columns,Sequence,columnshow,realcolumns,realencolumns) 
select '', @id, 'ld_projecttaskcf:cf_1071:cf_1071:ProjectTask_cf_1071:V', 1, 1, 'lld_projecttaskcf:cf_1071:cf_1071:ProjectTask_研发组织管理水平:V','ld_projecttaskcf:cf_1071:cf_1071:ProjectTask_cf_1071:V'
from dual where not exists(select 1 from ld_usereportcolumns where Usereportid=@id and realcolumns like 'ld_projecttaskcf:cf_1071:cf_1071:ProjectTask_%');

insert into ld_usereportcolumns(id,Usereportid,columns,Sequence,columnshow,realcolumns,realencolumns) 
select '', @id, 'ld_projecttaskcf:cf_1072:cf_1072:ProjectTask_cf_1072:V', 1, 1, 'ld_projecttaskcf:cf_1072:cf_1072:ProjectTask_人员:V','ld_projecttaskcf:cf_1072:cf_1072:ProjectTask_cf_1072:V'
from dual where not exists(select 1 from ld_usereportcolumns where Usereportid=@id and realcolumns like 'ld_projecttaskcf:cf_1072:cf_1072:ProjectTask_%');

insert into ld_usereportcolumns(id,Usereportid,columns,Sequence,columnshow,realcolumns,realencolumns) 
select '', @id, 'ld_projecttaskcf:cf_1073:cf_1073:ProjectTask_cf_1073:V', 1, 1, 'ld_projecttaskcf:cf_1073:cf_1073:ProjectTask_财务专审:V','ld_projecttaskcf:cf_1073:cf_1073:ProjectTask_cf_1073:V'
from dual where not exists(select 1 from ld_usereportcolumns where Usereportid=@id and realcolumns like 'ld_projecttaskcf:cf_1073:cf_1073:ProjectTask_%');

insert into ld_usereportcolumns(id,Usereportid,columns,Sequence,columnshow,realcolumns,realencolumns) 
select '', @id, 'ld_projecttaskcf:cf_1074:cf_1074:ProjectTask_cf_1074:V', 1, 1, 'ld_projecttaskcf:cf_1074:cf_1074:ProjectTask_定稿:V','ld_projecttaskcf:cf_1074:cf_1074:ProjectTask_cf_1074:V'
from dual where not exists(select 1 from ld_usereportcolumns where Usereportid=@id and realcolumns like 'ld_projecttaskcf:cf_1074:cf_1074:ProjectTask_%');

insert into ld_usereportcolumns(id,Usereportid,columns,Sequence,columnshow,realcolumns,realencolumns) 
select '', @id, 'ld_projecttask:projecttaskname:projecttaskname:ProjectTask_projecttaskname:V', 1, 1, 'ld_projecttask:projecttaskname:projecttaskname:ProjectTask_递交:V','ld_projecttask:projecttaskname:projecttaskname:ProjectTask_projecttaskname:V'
from dual where not exists(select 1 from ld_usereportcolumns where Usereportid=@id and realcolumns like 'ld_projecttask:projecttaskname:projecttaskname:ProjectTask_%');

insert into ld_usereportcolumns(id,Usereportid,columns,Sequence,columnshow,realcolumns,realencolumns) 
select '', @id, 'ld_projecttask:description:description:ProjectTask_description:V', 1, 1, 'ld_projecttask:description:description:ProjectTask_备注:V','ld_projecttask:description:description:ProjectTask_description:V'
from dual where not exists(select 1 from ld_usereportcolumns where Usereportid=@id and realcolumns like 'ld_projecttask:description:description:ProjectTask_%');
delimiter;

SELECT usereportid into @id from ld_usereport where name='ZHONGYUANREPORTS';
SELECT tabid into @tid from ld_tab where name='Project';
insert into ld_usereport(usereportid,name,reportlabel,tabids,basicfilter,advfilter,Setcolumns,Parent_id,sequence,reporttype,pagewidthpercent) 
select '','ProjectCompletionStatisticsReport','项目完成统计表',@tid,1,0,1,@id,1,6,100 
from dual where not exists(select usereportid from ld_usereport where name='ProjectCompletionStatisticsReport');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'zh','ProjectCompletionStatisticsReport','项目完成统计表','fixedstr' from dual where not EXISTS(select 1 from ld_desk where languagetype='zh' and labelbol='ProjectCompletionStatisticsReport' and Labeltype='fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'en','ProjectCompletionStatisticsReport','Project Completion Statistics Report','fixedstr' from dual where not EXISTS(select 1 from ld_desk  where languagetype='en' and labelbol='ProjectCompletionStatisticsReport' and Labeltype='fixedstr');
delimiter;

select usereportid into @id from ld_usereport where name='ProjectCompletionStatisticsReport';
insert into ld_usereportbasic(id,Usereportid,columns,Defaultvalue,Sequence) 
select '',@id,'ld_projectcf:cf_977:cf_977:Project_cf_977:D','thisstartmonth~thisendmonth',3  
from dual where not exists(select usereportid from ld_usereportbasic where Usereportid=@id and Sequence=3);

insert into ld_usereportbasic(id,Usereportid,columns,Defaultvalue,Sequence) 
select '',@id,'ld_project:cf_1478:cf_1478:Project_cf_1478:I','',4 
from dual where not exists(select usereportid from ld_usereportbasic where Usereportid=@id and Sequence=4);

select usereportid into @id from ld_usereport where name='ProjectCompletionStatisticsReport';

insert into ld_usereportcolumns(id,Usereportid,columns,Sequence,columnshow,realcolumns,realencolumns) 
select '', @id, 'ld_projectcf:cf_977:cf_977:Project_cf_977:V', 1, 1, 'ld_projectcf:cf_977:cf_977:Project_月份:V','ld_projectcf:cf_977:cf_977:Project_cf_977:V'
from dual where not exists(select 1 from ld_usereportcolumns where Usereportid=@id and realcolumns like 'ld_projectcf:cf_977:cf_977:Project_%');

insert into ld_usereportcolumns(id,Usereportid,columns,Sequence,columnshow,realcolumns,realencolumns) 
select '', @id, 'ld_users:last_name:last_name:Users_last_name:V', 2, 1, 'ld_users:last_name:last_name:Users_项目经理:V','ld_users:last_name:last_name:Users_last_name:V'
from dual where not exists(select 1 from ld_usereportcolumns where Usereportid=@id and realcolumns like 'ld_users:last_name:last_name:Users_%');

insert into ld_usereportcolumns(id,Usereportid,columns,Sequence,columnshow,realcolumns,realencolumns) 
select '', @id, 'ld_account:accountname:accountname:Accounts_accountname:V', 3, 1, 'ld_account:accountname:accountname:Accounts_客户名称:V','ld_account:accountname:accountname:Accounts_accountname:V'
from dual where not exists(select 1 from ld_usereportcolumns where Usereportid=@id and realcolumns like 'ld_account:accountname:accountname:Accounts_%');

insert into ld_usereportcolumns(id,Usereportid,columns,Sequence,columnshow,realcolumns,realencolumns) 
select '', @id, 'ld_projectcf:cf_13631:cf_13631:Project_cf_13631:V', 4, 1, 'ld_projectcf:cf_13631:cf_13631:Project_高品一:V','ld_projectcf:cf_13631:cf_13631:Project_cf_13631:V'
from dual where not exists(select 1 from ld_usereportcolumns where Usereportid=@id and realcolumns = 'ld_projectcf:cf_13631:cf_13631:Project_高品一:V');

insert into ld_usereportcolumns(id,Usereportid,columns,Sequence,columnshow,realcolumns,realencolumns) 
select '', @id, 'ld_projectcf:cf_13632:cf_13632:Project_cf_13632:V', 5, 1, 'ld_projectcf:cf_13632:cf_13632:Project_高品二:V','ld_projectcf:cf_13632:cf_13632:Project_cf_13632:V'
from dual where not exists(select 1 from ld_usereportcolumns where Usereportid=@id and realcolumns = 'ld_projectcf:cf_13632:cf_13632:Project_高品二:V');

insert into ld_usereportcolumns(id,Usereportid,columns,Sequence,columnshow,realcolumns,realencolumns) 
select '', @id, 'ld_projectcf:cf_13633:cf_13633:Project_cf_13633:V', 6, 1, 'ld_projectcf:cf_13633:cf_13633:Project_高品三:V','ld_projectcf:cf_13633:cf_13633:Project_cf_13633:V'
from dual where not exists(select 1 from ld_usereportcolumns where Usereportid=@id and realcolumns = 'ld_projectcf:cf_13633:cf_13633:Project_高品三:V');

insert into ld_usereportcolumns(id,Usereportid,columns,Sequence,columnshow,realcolumns,realencolumns) 
select '', @id, 'ld_projectcf:cf_13634:cf_13634:Project_cf_13634:V', 7, 1, 'ld_projectcf:cf_13634:cf_13634:Project_高品四:V','ld_projectcf:cf_13634:cf_13634:Project_cf_13634:V'
from dual where not exists(select 1 from ld_usereportcolumns where Usereportid=@id and realcolumns = 'ld_projectcf:cf_13634:cf_13634:Project_高品四:V');

insert into ld_usereportcolumns(id,Usereportid,columns,Sequence,columnshow,realcolumns,realencolumns) 
select '', @id, 'ld_projectcf:cf_1363:cf_1363:Project_cf_1363:V', 8, 1, 'ld_projectcf:cf_1363:cf_1363:Project_高品汇总:V','ld_projectcf:cf_1363:cf_1363:Project_cf_1363:V'
from dual where not exists(select 1 from ld_usereportcolumns where Usereportid=@id and realcolumns = 'ld_projectcf:cf_1363:cf_1363:Project_高品汇总:V');

insert into ld_usereportcolumns(id,Usereportid,columns,Sequence,columnshow,realcolumns,realencolumns) 
select '', @id, 'ld_projectcf:cf_9891:cf_9891:Project_cf_9891:V', 9, 1, 'ld_projectcf:cf_9891:cf_9891:Project_高企一:V','ld_projectcf:cf_9891:cf_9891:Project_cf_9891:V'
from dual where not exists(select 1 from ld_usereportcolumns where Usereportid=@id and realcolumns = 'ld_projectcf:cf_9891:cf_9891:Project_高企一:V');

insert into ld_usereportcolumns(id,Usereportid,columns,Sequence,columnshow,realcolumns,realencolumns) 
select '', @id, 'ld_projectcf:cf_9892:cf_9891:Project_cf_9892:V', 10, 1, 'ld_projectcf:cf_9892:cf_9892:Project_高企二:V','ld_projectcf:cf_9892:cf_9892:Project_cf_9892:V'
from dual where not exists(select 1 from ld_usereportcolumns where Usereportid=@id and realcolumns = 'ld_projectcf:cf_9892:cf_9892:Project_高企二:V');

insert into ld_usereportcolumns(id,Usereportid,columns,Sequence,columnshow,realcolumns,realencolumns) 
select '', @id, 'ld_projectcf:cf_9893:cf_9893:Project_cf_9893:V', 11, 1, 'ld_projectcf:cf_9893:cf_9893:Project_高企三:V','ld_projectcf:cf_9893:cf_9893:Project_cf_9893:V'
from dual where not exists(select 1 from ld_usereportcolumns where Usereportid=@id and realcolumns = 'ld_projectcf:cf_9893:cf_9893:Project_高企三:V');

insert into ld_usereportcolumns(id,Usereportid,columns,Sequence,columnshow,realcolumns,realencolumns) 
select '', @id, 'ld_projectcf:cf_9894:cf_9894:Project_cf_9894:V', 12, 1, 'ld_projectcf:cf_9894:cf_9894:Project_高企复审一:V','ld_projectcf:cf_9894:cf_9894:Project_cf_9894:V'
from dual where not exists(select 1 from ld_usereportcolumns where Usereportid=@id and realcolumns = 'ld_projectcf:cf_9894:cf_9894:Project_高企复审一:V');

insert into ld_usereportcolumns(id,Usereportid,columns,Sequence,columnshow,realcolumns,realencolumns) 
select '', @id, 'ld_projectcf:cf_9895:cf_9895:Project_cf_9895:V', 13, 1, 'ld_projectcf:cf_9895:cf_9895:Project_高企复审二:V','ld_projectcf:cf_9895:cf_9895:Project_cf_9895:V'
from dual where not exists(select 1 from ld_usereportcolumns where Usereportid=@id and realcolumns = 'ld_projectcf:cf_9895:cf_9895:Project_高企复审二:V');

insert into ld_usereportcolumns(id,Usereportid,columns,Sequence,columnshow,realcolumns,realencolumns) 
select '', @id, 'ld_projectcf:cf_989:cf_989:Project_cf_989:V', 14, 1, 'ld_projectcf:cf_989:cf_989:Project_高企汇总:V','ld_projectcf:cf_989:cf_989:Project_cf_989:V'
from dual where not exists(select 1 from ld_usereportcolumns where Usereportid=@id and realcolumns = 'ld_projectcf:cf_989:cf_989:Project_高企汇总:V');

insert into ld_usereportcolumns(id,Usereportid,columns,Sequence,columnshow,realcolumns,realencolumns) 
select '', @id, 'ld_projectcf:cf_1029g:cf_1029g:Project_cf_1029g:V', 15, 1, 'ld_projectcf:cf_1029g:cf_1029g:Project_国家级汇总:V','ld_projectcf:cf_1029g:cf_1029g:Project_cf_1029g:V'
from dual where not exists(select 1 from ld_usereportcolumns where Usereportid=@id and realcolumns = 'ld_projectcf:cf_1029g:cf_1029g:Project_国家级汇总:V');

insert into ld_usereportcolumns(id,Usereportid,columns,Sequence,columnshow,realcolumns,realencolumns) 
select '', @id, 'ld_salesorder:subject:subject:SalesOrder_subject:V', 16, 1, 'ld_salesorder:subject:subject:SalesOrder_加计扣除汇总:V','ld_salesorder:subject:subject:SalesOrder_subject:V'
from dual where not exists(select 1 from ld_usereportcolumns where Usereportid=@id and realcolumns = 'ld_salesorder:subject:subject:SalesOrder_加计扣除汇总:V');

insert into ld_usereportcolumns(id,Usereportid,columns,Sequence,columnshow,realcolumns,realencolumns) 
select '', @id, 'ld_projectcf:cf_1029s:cf_1029s:Project_cf_1029s:V', 17, 1, 'ld_projectcf:cf_1029s:cf_1029s:Project_省级汇总:V','ld_projectcf:cf_1029s:cf_1029s:Project_cf_1029s:V'
from dual where not exists(select 1 from ld_usereportcolumns where Usereportid=@id and realcolumns = 'ld_projectcf:cf_1029s:cf_1029s:Project_省级汇总:V');

insert into ld_usereportcolumns(id,Usereportid,columns,Sequence,columnshow,realcolumns,realencolumns) 
select '', @id, 'ld_projectcf:cf_1029c:cf_1029c:Project_cf_1029c:V', 18, 1, 'ld_projectcf:cf_1029c:cf_1029c:Project_市级汇总:V','ld_projectcf:cf_1029c:cf_1029c:Project_cf_1029c:V'
from dual where not exists(select 1 from ld_usereportcolumns where Usereportid=@id and realcolumns = 'ld_projectcf:cf_1029c:cf_1029c:Project_市级汇总:V');

insert into ld_usereportcolumns(id,Usereportid,columns,Sequence,columnshow,realcolumns,realencolumns) 
select '', @id, 'ld_projectcf:cf_1029d:cf_1029d:Project_cf_1029d:V', 19, 1, 'ld_projectcf:cf_1029d:cf_1029d:Project_总计:V','ld_projectcf:cf_1029d:cf_1029d:Project_cf_1029d:V'
from dual where not exists(select 1 from ld_usereportcolumns where Usereportid=@id and realcolumns = 'ld_projectcf:cf_1029d:cf_1029d:Project_总计:V');
delimiter;

CREATE TABLE IF NOT EXISTS `ld_userlogincheck` (
  `id` int(11) NOT NULL auto_increment,
  `phone` varchar(25) default NULL,
  `cversion` varchar(25) default NULL,
  `security_code` varchar(25) default NULL,
  `endtime` datetime default NULL,
  PRIMARY KEY  (`id`)
) ENGINE=InnoDB  DEFAULT CHARSET=utf8 AUTO_INCREMENT=0 ;
delimiter;

CREATE TABLE IF NOT EXISTS `ld_userloginhistroy` (
  `id` int(11) NOT NULL auto_increment,
  `login_time` datetime default NULL,
  `user_login_ip` varchar(25) default NULL,
  `user_login_ip_city` varchar(25) default NULL,
  `login_count` int(11) default NULL,
	`code_id` int(11) default NULL,
  PRIMARY KEY  (`id`)
) ENGINE=InnoDB  DEFAULT CHARSET=utf8 AUTO_INCREMENT=0 ;
delimiter;
-- 2015-06-24

CREATE TABLE IF NOT EXISTS `ld_appsystem` (
  `id` int(11) unsigned NOT NULL auto_increment,
  `userid` int(11) default '0',
  `deploy_value` varchar(25) default '0',
  `deploy_type` tinyint(3) default '1',
  `description` varchar(255) default NULL,
  PRIMARY KEY  (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=utf8;
delimiter;

CREATE TABLE if not EXISTS `ld_scoperhigher` (
`userid`  int(11) NOT NULL DEFAULT '0' ,
`viewid`  int(11) NOT NULL DEFAULT '0' ,
`scopeauthority`  int(4) NOT NULL DEFAULT '0' ,
`modulename`  varchar(255) NULL 
)
ENGINE=InnoDB
DEFAULT CHARACTER SET=utf8 COLLATE=utf8_general_ci;
delimiter;

CREATE TABLE if not EXISTS `ld_setscoperhigher` (
`userid`  int(11) NOT NULL DEFAULT '0' ,
`scopeauthority`  int(4) NOT NULL DEFAULT '0' ,
`modulename`  varchar(255) NULL 
)
ENGINE=InnoDB
DEFAULT CHARACTER SET=utf8 COLLATE=utf8_general_ci;
delimiter;

DROP PROCEDURE IF EXISTS addsetscoperhigher;
delimiter ||
CREATE PROCEDURE addsetscoperhigher(
)
BEGIN
		DECLARE done int DEFAULT 0;

		DECLARE puserid int(11) default 0;
		DECLARE pscopeauthority int(4) default 0;
		DECLARE pcnt int(4) default 0;

		DECLARE psetuserscoperresult CURSOR FOR select id,IFNULL(scopeauthority,0) FROM ld_users;
		DECLARE CONTINUE HANDLER for not found set done = 1;

		select count(1) into pcnt from ld_setscoperhigher;
		IF pcnt=0 THEN
				OPEN psetuserscoperresult;
				FETCH psetuserscoperresult INTO puserid,pscopeauthority;
				LOOP1: WHILE done <> 1 DO

						insert into ld_setscoperhigher(userid,scopeauthority,modulename)
						select puserid,pscopeauthority,`name` from ld_tab WHERE `name` NOT IN (
									'Emails',
									'MassEmails',
									'MassSMS',
									'SmsPhrases',
									'EmailListtmp',
									'CommunicationLog',
									'Navigation',
									'InventoryLedger',
									'InventoryAccount',
									'InventoryQuery',
									'Prdtnums',
									'BankCash',
									'Reports',
									'SalesGoal',
									'Cache',
									'Users',
									'Tooltip',
									'ModTracker',
									'lingdangBackup',
									'FieldFormulas',
									'Events',
									'Dashboard',
									'Leads',
									'Events',
									'Rss',
									'Portal',
									'ConfigEditor',
									'Import',
									'Integration',
									'Mobile',
									'PBXManager',
									'Services',
									'lingdangBackup',
									'WSAPP',
									'Assets',
									'CronTasks',
									'SMSNotifier',
									'Webforms',
									'Announcements',
									'MassFaxs',
									'MassVoices',
									'mobileAccounts',
									'mobileContacts',
									'mobileContactRecords',
									'mobileSalesOrder',
									'GraphicalReports',
									'mobileProducts',
									'mobilePublicAnnouncement',
									'mobileHelpDesk',
									'CustomerPortal'
								);
						
						IF pscopeauthority=2 THEN
								insert into ld_scoperhigher(userid,viewid,scopeauthority,modulename)
								select puserid,ld_userscoperhigher.viewuserid,pscopeauthority,ld_tab.`name` from ld_tab
								CROSS JOIN ld_userscoperhigher
								WHERE ld_userscoperhigher.userid=puserid and ld_tab.`name` NOT IN (
									'Emails',
									'MassEmails',
									'MassSMS',
									'SmsPhrases',
									'EmailListtmp',
									'CommunicationLog',
									'Navigation',
									'InventoryLedger',
									'InventoryAccount',
									'InventoryQuery',
									'Prdtnums',
									'BankCash',
									'Reports',
									'SalesGoal',
									'Cache',
									'Users',
									'Tooltip',
									'ModTracker',
									'lingdangBackup',
									'FieldFormulas',
									'Events',
									'Dashboard',
									'Leads',
									'Events',
									'Rss',
									'Portal',
									'ConfigEditor',
									'Import',
									'Integration',
									'Mobile',
									'PBXManager',
									'Services',
									'lingdangBackup',
									'WSAPP',
									'Assets',
									'CronTasks',
									'SMSNotifier',
									'Webforms',
									'Announcements',
									'MassFaxs',
									'MassVoices',
									'mobileAccounts',
									'mobileContacts',
									'mobileContactRecords',
									'mobileSalesOrder',
									'GraphicalReports',
									'mobileProducts',
									'mobilePublicAnnouncement',
									'mobileHelpDesk',
									'CustomerPortal'
								);
					end if;
					FETCH psetuserscoperresult INTO puserid,pscopeauthority;
				END WHILE LOOP1;
			CLOSE psetuserscoperresult;
	END IF;
END ||
delimiter;

call addsetscoperhigher();
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) 
select 'zh','Configure','设置','fixedstr' from dual 
where not EXISTS(select 1 from ld_desk where languagetype='zh' and labelbol='Configure' and Labeltype='fixedstr');

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) 
select 'en','Configure','Configure','fixedstr' from dual 
where not EXISTS(select 1 from ld_desk  where languagetype='en' and labelbol='Configure' and Labeltype='fixedstr');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) 
select 'zh','Thequeryscope','业务单据授权范围','fixedstr' from dual 
where not EXISTS(select 1 from ld_desk where languagetype='zh' and labelbol='Thequeryscope' and Labeltype='fixedstr');

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) 
select 'en','Thequeryscope','The query scope','fixedstr' from dual 
where not EXISTS(select 1 from ld_desk  where languagetype='en' and labelbol='Thequeryscope' and Labeltype='fixedstr');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) 
select 'zh','CUSTOMIZETOUSERSETTING','高级(按用户设置)','fixedstr' from dual 
where not EXISTS(select 1 from ld_desk where languagetype='zh' and labelbol='CUSTOMIZETOUSERSETTING' and Labeltype='fixedstr');

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) 
select 'en','CUSTOMIZETOUSERSETTING','Customize(to user settings)','fixedstr' from dual 
where not EXISTS(select 1 from ld_desk  where languagetype='en' and labelbol='CUSTOMIZETOUSERSETTING' and Labeltype='fixedstr');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) 
select 'zh','CUSTOMIZEBYSECTOR','高级(按部门设置)','fixedstr' from dual 
where not EXISTS(select 1 from ld_desk where languagetype='zh' and labelbol='CUSTOMIZEBYSECTOR' and Labeltype='fixedstr');

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) 
select 'en','CUSTOMIZEBYSECTOR','Customize(by sector)','fixedstr' from dual 
where not EXISTS(select 1 from ld_desk  where languagetype='en' and labelbol='CUSTOMIZEBYSECTOR' and Labeltype='fixedstr');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) 
select 'zh','Pleaseselectatleastonedepartment','请至少选择一个部门！','jspop' from dual 
where not EXISTS(select 1 from ld_desk where languagetype='zh' and labelbol='Pleaseselectatleastonedepartment' and Labeltype='jspop');

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) 
select 'en','Pleaseselectatleastonedepartment','Please select at least one department!','jspop' from dual 
where not EXISTS(select 1 from ld_desk  where languagetype='en' and labelbol='Pleaseselectatleastonedepartment' and Labeltype='jspop');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) 
select 'zh','WUATSOTMCTC','将更新所有模块的设置，是否继续？','jspop' from dual 
where not EXISTS(select 1 from ld_desk where languagetype='zh' and labelbol='WUATSOTMCTC' and Labeltype='jspop');

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) 
select 'en','WUATSOTMCTC','Will update all the settings of the modules, confirmed to continue?','jspop' from dual 
where not EXISTS(select 1 from ld_desk  where languagetype='en' and labelbol='WUATSOTMCTC' and Labeltype='jspop');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) 
select 'zh','SHOWNOGROUPUSER','根节点下显示无部门用户','jspop' from dual 
where not EXISTS(select 1 from ld_desk where languagetype='zh' and labelbol='SHOWNOGROUPUSER' and Labeltype='jspop');

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) 
select 'en','SHOWNOGROUPUSER','Showed no group users','jspop' from dual 
where not EXISTS(select 1 from ld_desk  where languagetype='en' and labelbol='SHOWNOGROUPUSER' and Labeltype='jspop');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) 
select 'zh','VIEWTHEDETAILS','( 查看单据明细界面 )','jspop' from dual 
where not EXISTS(select 1 from ld_desk where languagetype='zh' and labelbol='VIEWTHEDETAILS' and Labeltype='jspop');

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) 
select 'en','VIEWTHEDETAILS','( View the details )','jspop' from dual 
where not EXISTS(select 1 from ld_desk  where languagetype='en' and labelbol='VIEWTHEDETAILS' and Labeltype='jspop');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) 
select 'zh','Allowtoviewotherusers','允许查看其他用户的单据(优先于角色)','jspop' from dual 
where not EXISTS(select 1 from ld_desk where languagetype='zh' and labelbol='Allowtoviewotherusers' and Labeltype='jspop');

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) 
select 'en','Allowtoviewotherusers',"Allow to view other users' data",'jspop' from dual 
where not EXISTS(select 1 from ld_desk  where languagetype='en' and labelbol='Allowtoviewotherusers' and Labeltype='jspop');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) 
select 'zh','Allowtoeditotherusers','允许编辑其他用户的单据(优先于角色)','jspop' from dual 
where not EXISTS(select 1 from ld_desk where languagetype='zh' and labelbol='Allowtoeditotherusers' and Labeltype='jspop');

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) 
select 'en','Allowtoeditotherusers',"Allow to edit other users' data",'jspop' from dual 
where not EXISTS(select 1 from ld_desk  where languagetype='en' and labelbol='Allowtoeditotherusers' and Labeltype='jspop');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) 
select 'zh','Allowtodeleteotherusers','允许删除其他用户的单据(优先于角色)','jspop' from dual 
where not EXISTS(select 1 from ld_desk where languagetype='zh' and labelbol='Allowtodeleteotherusers' and Labeltype='jspop');

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) 
select 'en','Allowtodeleteotherusers',"Allow to delete other users' data",'jspop' from dual 
where not EXISTS(select 1 from ld_desk  where languagetype='en' and labelbol='Allowtodeleteotherusers' and Labeltype='jspop');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) 
select 'zh','Allowtoqueryotherusers','允许查询自己创建的单据','jspop' from dual 
where not EXISTS(select 1 from ld_desk where languagetype='zh' and labelbol='Allowtoqueryotherusers' and Labeltype='jspop');

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) 
select 'en','Allowtoqueryotherusers',"Allows to query the data which created by myself",'jspop' from dual 
where not EXISTS(select 1 from ld_desk  where languagetype='en' and labelbol='Allowtoqueryotherusers' and Labeltype='jspop');
delimiter;

UPDATE ld_desk SET fieldlabel='Department' WHERE labelbol='USERGROUPLIST' AND Labeltype='jspop' AND languagetype='en';

UPDATE ld_desk SET fieldlabel='角色权限' WHERE labelbol='SETTHEPERMISSIONS' AND languagetype='zh';
-- 2015-06-25

select usereportid into @id from ld_usereport where name='HighAndNewTechnologyEnterpriseSchedule';

DELETE FROM ld_usereportcolumns WHERE Usereportid=@id;

insert into ld_usereportcolumns(id,Usereportid,columns,Sequence,columnshow,realcolumns,realencolumns) 
select '', @id, 'ld_users:last_name:last_name:Users_last_name:V', 1, 1, 'ld_users:last_name:last_name:Users_项目经理:V','ld_users:last_name:last_name:Users_last_name:V'
from dual where not exists(select 1 from ld_usereportcolumns where Usereportid=@id and realcolumns like 'ld_users:last_name:last_name:Users_%');

insert into ld_usereportcolumns(id,Usereportid,columns,Sequence,columnshow,realcolumns,realencolumns) 
select '', @id, 'ld_account:accountname:accountname:Accounts_accountname:V', 2, 1, 'ld_account:accountname:accountname:Accounts_客户名称:V','ld_account:accountname:accountname:Accounts_accountname:V'
from dual where not exists(select 1 from ld_usereportcolumns where Usereportid=@id and realcolumns like 'ld_account:accountname:accountname:Accounts_%');
insert into ld_usereportcolumns(id,Usereportid,columns,Sequence,columnshow,realcolumns,realencolumns) 

select '', @id, 'ld_projectcf:cf_1473:cf_1473:Project_cf_1473:V', 3, 1, 'ld_projectcf:cf_1473:cf_1473:Project_技术领域(一级):V','ld_projectcf:cf_1473:cf_1473:Project_cf_1473:V'
from dual where not exists(select 1 from ld_usereportcolumns where Usereportid=@id and realcolumns like 'ld_projectcf:cf_1473:cf_1473:Project_%');

insert into ld_usereportcolumns(id,Usereportid,columns,Sequence,columnshow,realcolumns,realencolumns) 
select '', @id, 'ld_projectcf:cf_1474:cf_1474:Project_cf_1474:V', 4, 1, 'ld_projectcf:cf_1474:cf_1474:Project_技术领域(二级):V','ld_projectcf:cf_1474:cf_1474:Project_cf_1474:V'
from dual where not exists(select 1 from ld_usereportcolumns where Usereportid=@id and realcolumns like 'ld_projectcf:cf_1474:cf_1474:Project_%');

insert into ld_usereportcolumns(id,Usereportid,columns,Sequence,columnshow,realcolumns,realencolumns) 
select '', @id, 'ld_projectcf:cf_1475:cf_1475:Project_cf_1475:V', 5, 1, 'ld_projectcf:cf_1475:cf_1475:Project_技术领域(三级):V','ld_projectcf:cf_1475:cf_1475:Project_cf_1475:V'
from dual where not exists(select 1 from ld_usereportcolumns where Usereportid=@id and realcolumns like 'ld_projectcf:cf_1475:cf_1475:Project_%');

insert into ld_usereportcolumns(id,Usereportid,columns,Sequence,columnshow,realcolumns,realencolumns) 
select '', @id, 'ld_projectcf:cf_1479:cf_1479:Project_cf_1479:V', 6, 1, 'ld_projectcf:cf_1479:cf_1479:Project_申报年度:V','ld_projectcf:cf_1479:cf_1479:Project_cf_1479:V'
from dual where not exists(select 1 from ld_usereportcolumns where Usereportid=@id and realcolumns like 'ld_projectcf:cf_1479:cf_1479:Project_%');

insert into ld_usereportcolumns(id,Usereportid,columns,Sequence,columnshow,realcolumns,realencolumns) 
select '', @id, 'ld_projectcf:cf_977:cf_977:Project_cf_977:V', 7, 1, 'ld_projectcf:cf_977:cf_977:Project_申报月份:V','ld_projectcf:cf_977:cf_977:Project_cf_977:V'
from dual where not exists(select 1 from ld_usereportcolumns where Usereportid=@id and realcolumns like 'ld_projectcf:cf_977:cf_977:Project_%');

insert into ld_usereportcolumns(id,Usereportid,columns,Sequence,columnshow,realcolumns,realencolumns) 
select '', @id, 'ld_projectcf:cf_1285:cf_1285:Project_cf_1285:V', 8, 1, 'ld_projectcf:cf_1285:cf_1285:Project_所属城市:V','ld_projectcf:cf_1285:cf_1285:Project_cf_1285:V'
from dual where not exists(select 1 from ld_usereportcolumns where Usereportid=@id and realcolumns like 'ld_projectcf:cf_1285:cf_1285:Project_%');

insert into ld_usereportcolumns(id,Usereportid,columns,Sequence,columnshow,realcolumns,realencolumns) 
select '', @id, 'ld_projectcf:cf_1286:cf_1286:Project_cf_1286:V', 9, 1, 'ld_projectcf:cf_1286:cf_1286:Project_所属区域:V','ld_projectcf:cf_1286:cf_1286:Project_cf_1286:V'
from dual where not exists(select 1 from ld_usereportcolumns where Usereportid=@id and realcolumns like 'ld_projectcf:cf_1286:cf_1286:Project_%');

insert into ld_usereportcolumns(id,Usereportid,columns,Sequence,columnshow,realcolumns,realencolumns) 
select '', @id, 'ld_projectcf:cf_1287:cf_1287:Project_cf_1287:V', 10, 1, 'ld_projectcf:cf_1287:cf_1287:Project_所属地区:V','ld_projectcf:cf_1287:cf_1287:Project_cf_1287:V'
from dual where not exists(select 1 from ld_usereportcolumns where Usereportid=@id and realcolumns like 'ld_projectcf:cf_1287:cf_1287:Project_%');

insert into ld_usereportcolumns(id,Usereportid,columns,Sequence,columnshow,realcolumns,realencolumns) 
select '', @id, 'ld_projectcf:cf_1289:cf_1289:Project_cf_1289:V', 11, 1, 'ld_projectcf:cf_1289:cf_1289:Project_业务经理:V','ld_projectcf:cf_1289:cf_1289:Project_cf_1289:V'
from dual where not exists(select 1 from ld_usereportcolumns where Usereportid=@id and realcolumns like 'ld_projectcf:cf_1289:cf_1289:Project_%');

insert into ld_usereportcolumns(id,Usereportid,columns,Sequence,columnshow,realcolumns,realencolumns) 
select '', @id, 'ld_project:cf_1478:cf_1478:Project_cf_1478:V', 12, 1, 'ld_project:cf_1478:cf_1478:Project_项目类别:V','ld_project:cf_1478:cf_1478:Project_cf_1478:V'
from dual where not exists(select 1 from ld_usereportcolumns where Usereportid=@id and realcolumns like 'ld_project:cf_1478:cf_1478:Project_%');

insert into ld_usereportcolumns(id,Usereportid,columns,Sequence,columnshow,realcolumns,realencolumns) 
select '', @id, 'u2:last_name:last_name:u2_last_name:V', 13, 1, 'u2:last_name:last_name:u2_进度经理:V','u2:last_name:last_name:u2_last_name:V' 
from dual where not exists(select 1 from ld_usereportcolumns where Usereportid=@id and realcolumns like 'u2:last_name:last_name:u2_%');

insert into ld_usereportcolumns(id,Usereportid,columns,Sequence,columnshow,realcolumns,realencolumns) 
select '', @id, 'ld_projecttaskcf:cf_1067:cf_1067:ProjectTask_cf_1067:V', 14, 1, 'ld_projecttaskcf:cf_1067:cf_1067:ProjectTask_启动时间:V','ld_projecttaskcf:cf_1067:cf_1067:ProjectTask_cf_1067:V'
from dual where not exists(select 1 from ld_usereportcolumns where Usereportid=@id and realcolumns like 'ld_projecttaskcf:cf_1067:cf_1067:ProjectTask_%');

insert into ld_usereportcolumns(id,Usereportid,columns,Sequence,columnshow,realcolumns,realencolumns) 
select '', @id, 'ld_projecttaskcf:cf_1068:cf_1068:ProjectTask_cf_1068:V', 15, 1, 'ld_projecttaskcf:cf_1068:cf_1068:ProjectTask_专利:V','ld_projecttaskcf:cf_1068:cf_1068:ProjectTask_cf_1068:V'
from dual where not exists(select 1 from ld_usereportcolumns where Usereportid=@id and realcolumns like 'ld_projecttaskcf:cf_1068:cf_1068:ProjectTask_%');

insert into ld_usereportcolumns(id,Usereportid,columns,Sequence,columnshow,realcolumns,realencolumns) 
select '', @id, 'ld_projecttaskcf:cf_1069:cf_1069:ProjectTask_cf_1069:V', 16, 1, 'ld_projecttaskcf:cf_1069:cf_1069:ProjectTask_RD/PS:V','ld_projecttaskcf:cf_1069:cf_1069:ProjectTask_cf_1069:V'
from dual where not exists(select 1 from ld_usereportcolumns where Usereportid=@id and realcolumns like 'ld_projecttaskcf:cf_1069:cf_1069:ProjectTask_%');

insert into ld_usereportcolumns(id,Usereportid,columns,Sequence,columnshow,realcolumns,realencolumns) 
select '', @id, 'ld_projecttaskcf:cf_1070:cf_1070:ProjectTask_cf_1070:V', 17, 1, 'ld_projecttaskcf:cf_1070:cf_1070:ProjectTask_成果转化:V','ld_projecttaskcf:cf_1070:cf_1070:ProjectTask_cf_1070:V'
from dual where not exists(select 1 from ld_usereportcolumns where Usereportid=@id and realcolumns like 'ld_projecttaskcf:cf_1070:cf_1070:ProjectTask_%');

insert into ld_usereportcolumns(id,Usereportid,columns,Sequence,columnshow,realcolumns,realencolumns) 
select '', @id, 'ld_projecttaskcf:cf_1071:cf_1071:ProjectTask_cf_1071:V', 18, 1, 'ld_projecttaskcf:cf_1071:cf_1071:ProjectTask_研发组织管理水平:V','ld_projecttaskcf:cf_1071:cf_1071:ProjectTask_cf_1071:V'
from dual where not exists(select 1 from ld_usereportcolumns where Usereportid=@id and realcolumns like 'ld_projecttaskcf:cf_1071:cf_1071:ProjectTask_%');


insert into ld_usereportcolumns(id,Usereportid,columns,Sequence,columnshow,realcolumns,realencolumns) 
select '', @id, 'ld_projecttaskcf:cf_1072:cf_1072:ProjectTask_cf_1072:V', 19, 1, 'ld_projecttaskcf:cf_1072:cf_1072:ProjectTask_人员:V','ld_projecttaskcf:cf_1072:cf_1072:ProjectTask_cf_1072:V'
from dual where not exists(select 1 from ld_usereportcolumns where Usereportid=@id and realcolumns like 'ld_projecttaskcf:cf_1072:cf_1072:ProjectTask_%');

insert into ld_usereportcolumns(id,Usereportid,columns,Sequence,columnshow,realcolumns,realencolumns) 
select '', @id, 'ld_projecttaskcf:cf_1073:cf_1073:ProjectTask_cf_1073:V', 20, 1, 'ld_projecttaskcf:cf_1073:cf_1073:ProjectTask_财务专审:V','ld_projecttaskcf:cf_1073:cf_1073:ProjectTask_cf_1073:V'
from dual where not exists(select 1 from ld_usereportcolumns where Usereportid=@id and realcolumns like 'ld_projecttaskcf:cf_1073:cf_1073:ProjectTask_%');

insert into ld_usereportcolumns(id,Usereportid,columns,Sequence,columnshow,realcolumns,realencolumns) 
select '', @id, 'ld_projecttaskcf:cf_1074:cf_1074:ProjectTask_cf_1074:V', 21, 1, 'ld_projecttaskcf:cf_1074:cf_1074:ProjectTask_定稿:V','ld_projecttaskcf:cf_1074:cf_1074:ProjectTask_cf_1074:V'
from dual where not exists(select 1 from ld_usereportcolumns where Usereportid=@id and realcolumns like 'ld_projecttaskcf:cf_1074:cf_1074:ProjectTask_%');

insert into ld_usereportcolumns(id,Usereportid,columns,Sequence,columnshow,realcolumns,realencolumns) 
select '', @id, 'ld_projecttask:projecttaskname:projecttaskname:ProjectTask_projecttaskname:V', 22, 1, 'ld_projecttask:projecttaskname:projecttaskname:ProjectTask_递交:V','ld_projecttask:projecttaskname:projecttaskname:ProjectTask_projecttaskname:V'
from dual where not exists(select 1 from ld_usereportcolumns where Usereportid=@id and realcolumns like 'ld_projecttask:projecttaskname:projecttaskname:ProjectTask_%');

insert into ld_usereportcolumns(id,Usereportid,columns,Sequence,columnshow,realcolumns,realencolumns) 
select '', @id, 'ld_projecttask:description:description:ProjectTask_description:V', 23, 1, 'ld_projecttask:description:description:ProjectTask_备注:V','ld_projecttask:description:description:ProjectTask_description:V'
from dual where not exists(select 1 from ld_usereportcolumns where Usereportid=@id and realcolumns like 'ld_projecttask:description:description:ProjectTask_%');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'zh','Pending','待处理','fixedstr' from dual where not EXISTS(select 1 from ld_desk where languagetype='zh' and labelbol='Pending' and Labeltype='fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'en','Pending','Pending','fixedstr' from dual where not EXISTS(select 1 from ld_desk  where languagetype='en' and labelbol='Pending' and Labeltype='fixedstr');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'zh','Processed','已处理','fixedstr' from dual where not EXISTS(select 1 from ld_desk where languagetype='zh' and labelbol='Processed' and Labeltype='fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'en','Processed','Processed','fixedstr' from dual where not EXISTS(select 1 from ld_desk  where languagetype='en' and labelbol='Processed' and Labeltype='fixedstr');
delimiter;

call AddColumn('ld_producttoolfield','tabid','int','10',0);
delimiter;

call AddColumn('ld_producttoolfield','tablename','varchar','50',NULL);
delimiter;

call AddColumn('ld_producttoolfield','width','int','10',0);
delimiter;

ALTER TABLE ld_producttoolfield MODIFY COLUMN width decimal(25,6) default 0.00;
delimiter;

call AddColumn('ld_producttoolfield','edit_permission','int','4',0);
delimiter;

call AddColumn('ld_producttoolfield','input_type','int','4',0);
delimiter;
call AddColumn('ld_producttoolfield','fieldid','int','4',0);
delimiter;

call AddColumn('ld_producttoolfield','newline','int','1',0);
delimiter;

call AddColumn('ld_inventoryproductrel','discount_total','int','10',0);
delimiter;

call AddColumn('ld_producttoolfield','defaultcolumn','int','4',0);
delimiter;

ALTER TABLE ld_inventoryproductrel MODIFY COLUMN discount_total decimal(25,6) default 0.00;
delimiter;

call AddColumn('ld_inventoryproductrel','tax_total','int','10',0); -- 税额
delimiter;

ALTER TABLE ld_inventoryproductrel MODIFY COLUMN tax_total decimal(25,6) default 0.00;
delimiter;

call AddColumn('ld_inventoryproductrel','list_amount','int','10',0); -- 不含税金额
delimiter;

ALTER TABLE ld_inventoryproductrel MODIFY COLUMN list_amount decimal(25,6) default 0.00;	
delimiter;

call AddColumn('ld_inventoryproductrel','tax_amount','int','10',0); -- 含税金额
delimiter;

ALTER TABLE ld_inventoryproductrel MODIFY COLUMN tax_amount decimal(25,6) default 0.00;
delimiter;

call AddColumn('ld_inventoryproductrel','eur_price','int','10',0); -- 欧元单价
delimiter;

ALTER TABLE ld_inventoryproductrel MODIFY COLUMN eur_price decimal(25,6) default 0.00;
delimiter;
call AddColumn('ld_inventoryproductrel','tax_profit','int','10',0); -- 利润率
delimiter;

ALTER TABLE ld_inventoryproductrel MODIFY COLUMN tax_profit decimal(25,6) default 0.00;
delimiter;

call AddColumn('ld_inventoryproductrel','rmb_taxprice','int','10',0); -- 含税单价
delimiter;

ALTER TABLE ld_inventoryproductrel MODIFY COLUMN rmb_taxprice decimal(25,6) default 0.00;
delimiter;

call AddColumn('ld_inventoryproductrel','rmb_taxamount','int','10',0); -- 含税总价
delimiter;

ALTER TABLE ld_inventoryproductrel MODIFY COLUMN rmb_taxamount decimal(25,6) default 0.00;
delimiter;

update ld_producttoolfield set defaultcolumn = 1 where tabid = 0;

CREATE TABLE IF NOT EXISTS `ld_producttoolprofile` (
  `producttoolfieldid` int(10) NOT NULL DEFAULT '0',
  `tabid` int(10) NOT NULL DEFAULT '0',
  `userid` int(10) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
delimiter;

CREATE TABLE IF NOT EXISTS `ld_producttoolfield_formula` (
  `formulaid` int(19) NOT NULL AUTO_INCREMENT,
  `producttoolfieldid` int(19) DEFAULT NULL,
  `formulastring` varchar(2000) DEFAULT NULL,
  `columnstring` varchar(2000) DEFAULT NULL,
  PRIMARY KEY (`formulaid`)
) ENGINE=InnoDB AUTO_INCREMENT=21 DEFAULT CHARSET=utf8;
delimiter;

update ld_desk set fieldlabel = '单据分录自定义' where labelbol = 'LBL_ProductTool_field' and languagetype = 'zh' and Labeltype = 'fixedstr';
update ld_desk set fieldlabel = 'Customise bills entry' where labelbol = 'LBL_ProductTool_field' and languagetype = 'en' and Labeltype = 'fixedstr';
delimiter;

update ld_desk set fieldlabel = '自定义字段' where labelbol = 'Add_custom_fields' and languagetype = 'zh' and Labeltype = 'fixedstr';
update ld_desk set fieldlabel = 'defined fields' where labelbol = 'Add_custom_fields' and languagetype = 'en' and Labeltype = 'fixedstr';
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','ADVANCEDPROPERTIES','高级属性','fixedstr' from dual 
where not exists(select 1 from ld_desk where labelbol = 'ADVANCEDPROPERTIES' and languagetype = 'zh' and labeltype = 'fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','ADVANCEDPROPERTIES','Advanced properties','fixedstr' from dual 
where not exists(select 1 from ld_desk where labelbol = 'ADVANCEDPROPERTIES' and languagetype = 'en' and labeltype = 'fixedstr');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','BASICPROPERTIES','基本属性','fixedstr' from dual 
where not exists(select 1 from ld_desk where labelbol = 'BASICPROPERTIES' and languagetype = 'zh' and labeltype = 'fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','BASICPROPERTIES','Basic properties','fixedstr' from dual 
where not exists(select 1 from ld_desk where labelbol = 'BASICPROPERTIES' and languagetype = 'en' and labeltype = 'fixedstr');	
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','TAXAMOUNT','税额','fixedstr' from dual 
where not exists(select 1 from ld_desk where labelbol = 'TAXAMOUNT' and languagetype = 'zh' and labeltype = 'fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','TAXAMOUNT','Tax Amount','fixedstr' from dual 
where not exists(select 1 from ld_desk where labelbol = 'TAXAMOUNT' and languagetype = 'en' and labeltype = 'fixedstr');	
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','WIDTHMM','列宽(毫米)','fixedstr' from dual 
where not exists(select 1 from ld_desk where labelbol = 'WIDTHMM' and languagetype = 'zh' and labeltype = 'fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','WIDTHMM','Width(mm)','fixedstr' from dual 
where not exists(select 1 from ld_desk where labelbol = 'WIDTHMM' and languagetype = 'en' and labeltype = 'fixedstr');	
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','DOYOUNEEDTOEDIT','是否需要编辑','fixedstr' from dual 
where not exists(select 1 from ld_desk where labelbol = 'DOYOUNEEDTOEDIT' and languagetype = 'zh' and labeltype = 'fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','DOYOUNEEDTOEDIT','Do Need To Edit','fixedstr' from dual 
where not exists(select 1 from ld_desk where labelbol = 'DOYOUNEEDTOEDIT' and languagetype = 'en' and labeltype = 'fixedstr');	
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','ALLOWEDITING','允许编辑','fixedstr' from dual 
where not exists(select 1 from ld_desk where labelbol = 'ALLOWEDITING' and languagetype = 'zh' and labeltype = 'fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','ALLOWEDITING','Allows to edit','fixedstr' from dual 
where not exists(select 1 from ld_desk where labelbol = 'ALLOWEDITING' and languagetype = 'en' and labeltype = 'fixedstr');	
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','NEEDTOSAVE','需要保存','fixedstr' from dual 
where not exists(select 1 from ld_desk where labelbol = 'NEEDTOSAVE' and languagetype = 'zh' and labeltype = 'fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','NEEDTOSAVE','Need To Save','fixedstr' from dual 
where not exists(select 1 from ld_desk where labelbol = 'NEEDTOSAVE' and languagetype = 'en' and labeltype = 'fixedstr');	
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','FIELDLENGTH','字段长度','fixedstr' from dual 
where not exists(select 1 from ld_desk where labelbol = 'FIELDLENGTH' and languagetype = 'zh' and labeltype = 'fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','FIELDLENGTH','Field Length','fixedstr' from dual 
where not exists(select 1 from ld_desk where labelbol = 'FIELDLENGTH' and languagetype = 'en' and labeltype = 'fixedstr');	
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','INTERGER','整数','fixedstr' from dual 
where not exists(select 1 from ld_desk where labelbol = 'INTERGER' and languagetype = 'zh' and labeltype = 'fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','INTERGER','Integer','fixedstr' from dual 
where not exists(select 1 from ld_desk where labelbol = 'INTERGER' and languagetype = 'en' and labeltype = 'fixedstr');	
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','PRECISION','精度','fixedstr' from dual 
where not exists(select 1 from ld_desk where labelbol = 'PRECISION' and languagetype = 'zh' and labeltype = 'fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','PRECISION','Precision','fixedstr' from dual 
where not exists(select 1 from ld_desk where labelbol = 'PRECISION' and languagetype = 'en' and labeltype = 'fixedstr');	
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','STYLE','格式','fixedstr' from dual 
where not exists(select 1 from ld_desk where labelbol = 'STYLE' and languagetype = 'zh' and labeltype = 'fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','STYLE','Style','fixedstr' from dual 
where not exists(select 1 from ld_desk where labelbol = 'STYLE' and languagetype = 'en' and labeltype = 'fixedstr');	
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','NEXTMONTHTODAY','下月今天','fixedstr' from dual 
where not exists(select 1 from ld_desk where labelbol = 'NEXTMONTHTODAY' and languagetype = 'zh' and labeltype = 'fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','NEXTMONTHTODAY','Next month today','fixedstr' from dual 
where not exists(select 1 from ld_desk where labelbol = 'NEXTMONTHTODAY' and languagetype = 'en' and labeltype = 'fixedstr');	
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','INPUTMODE','录入方式','fixedstr' from dual 
where not exists(select 1 from ld_desk where labelbol = 'INPUTMODE' and languagetype = 'zh' and labeltype = 'fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','INPUTMODE','Input mode','fixedstr' from dual 
where not exists(select 1 from ld_desk where labelbol = 'INPUTMODE' and languagetype = 'en' and labeltype = 'fixedstr');	
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','MANUALINPUT','手动录入','fixedstr' from dual 
where not exists(select 1 from ld_desk where labelbol = 'MANUALINPUT' and languagetype = 'zh' and labeltype = 'fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','MANUALINPUT','Manual input','fixedstr' from dual 
where not exists(select 1 from ld_desk where labelbol = 'MANUALINPUT' and languagetype = 'en' and labeltype = 'fixedstr');	
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','THEFIELDBASEDONTHEBASICENTRY','分录已有基础资料属性','fixedstr' from dual 
where not exists(select 1 from ld_desk where labelbol = 'THEFIELDBASEDONTHEBASICENTRY' and languagetype = 'zh' and labeltype = 'fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','THEFIELDBASEDONTHEBASICENTRY','The field based on the basic entry','fixedstr' from dual 
where not exists(select 1 from ld_desk where labelbol = 'THEFIELDBASEDONTHEBASICENTRY' and languagetype = 'en' and labeltype = 'fixedstr');	
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','USINGTHEFORMULA','通过公式计算','fixedstr' from dual 
where not exists(select 1 from ld_desk where labelbol = 'USINGTHEFORMULA' and languagetype = 'zh' and labeltype = 'fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','USINGTHEFORMULA','Using the formula','fixedstr' from dual 
where not exists(select 1 from ld_desk where labelbol = 'USINGTHEFORMULA' and languagetype = 'en' and labeltype = 'fixedstr');	
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','ATTRIBUTEFIELD','属性字段','fixedstr' from dual 
where not exists(select 1 from ld_desk where labelbol = 'ATTRIBUTEFIELD' and languagetype = 'zh' and labeltype = 'fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','ATTRIBUTEFIELD','Attribute field','fixedstr' from dual 
where not exists(select 1 from ld_desk where labelbol = 'ATTRIBUTEFIELD' and languagetype = 'en' and labeltype = 'fixedstr');	
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','DEFININGVARUABLE','定义变量','fixedstr' from dual 
where not exists(select 1 from ld_desk where labelbol = 'DEFININGVARUABLE' and languagetype = 'zh' and labeltype = 'fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','DEFININGVARUABLE','Defining variable','fixedstr' from dual 
where not exists(select 1 from ld_desk where labelbol = 'DEFININGVARUABLE' and languagetype = 'en' and labeltype = 'fixedstr');	
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','DEFINITIONFORMULA','定义公式','fixedstr' from dual 
where not exists(select 1 from ld_desk where labelbol = 'DEFINITIONFORMULA' and languagetype = 'zh' and labeltype = 'fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','DEFINITIONFORMULA','Definition formula','fixedstr' from dual 
where not exists(select 1 from ld_desk where labelbol = 'DEFINITIONFORMULA' and languagetype = 'en' and labeltype = 'fixedstr');	
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','ALLTHENUMBERORDATEOFFIELDTYPESCANCALCULATE','单据头、分录中的所有数字类型的字段可参与运算。','fixedstr' from dual 
where not exists(select 1 from ld_desk where labelbol = 'ALLTHENUMBERORDATEOFFIELDTYPESCANCALCULATE' and languagetype = 'zh' and labeltype = 'fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','ALLTHENUMBERORDATEOFFIELDTYPESCANCALCULATE','All the number or date of field types can calculate。','fixedstr' from dual 
where not exists(select 1 from ld_desk where labelbol = 'ALLTHENUMBERORDATEOFFIELDTYPESCANCALCULATE' and languagetype = 'en' and labeltype = 'fixedstr');	
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','CANHAVEATMOST10VARIABLES','最多只能定义10个变量。','fixedstr' from dual 
where not exists(select 1 from ld_desk where labelbol = 'CANHAVEATMOST10VARIABLES' and languagetype = 'zh' and labeltype = 'fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','CANHAVEATMOST10VARIABLES','Can have at most 10 variables。','fixedstr' from dual 
where not exists(select 1 from ld_desk where labelbol = 'CANHAVEATMOST10VARIABLES' and languagetype = 'en' and labeltype = 'fixedstr');	
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','INVALIDADJUSTMENTAMOUNT','无效的调整金额','jspop' from dual 
where not exists(select 1 from ld_desk where labelbol = 'INVALIDADJUSTMENTAMOUNT' and languagetype = 'zh' and labeltype = 'jspop');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','INVALIDADJUSTMENTAMOUNT','Invalid adjustment amount','jspop' from dual 
where not exists(select 1 from ld_desk where labelbol = 'INVALIDADJUSTMENTAMOUNT' and languagetype = 'en' and labeltype = 'jspop');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','UPDATETTHEAPPROVESTATUS','更改审批状态','fixedstr' from dual 
where not exists(select 1 from ld_desk where labelbol = 'UPDATETTHEAPPROVESTATUS' and languagetype = 'zh' and labeltype = 'fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','UPDATETTHEAPPROVESTATUS','Update the approve status','fixedstr' from dual 
where not exists(select 1 from ld_desk where labelbol = 'UPDATETTHEAPPROVESTATUS' and languagetype = 'en' and labeltype = 'fixedstr');	
delimiter;
DROP PROCEDURE IF EXISTS addTranLabel; 
delimiter || 
CREATE PROCEDURE addTranLabel(IN tab_id int,IN fieldid int,IN tablename VARCHAR(100),IN var_labelbol VARCHAR(100),IN producttoofield int) 
begin
	if(var_labelbol != '')
	THEN
		if(var_labelbol = 'DISCOUNT')
		THEN	
			set @fieldlabel = '折扣(%)';
		else
			select fieldlabel into @fieldlabel from ld_desk where labelbol = var_labelbol and languagetype = 'zh' and Labeltype = 'fixedstr';
		end if;
		insert into ld_tranlabel(languagetype,trantable,tabid,Relateid,fieldlabel) values ('zh',tablename, tab_id, producttoofield,@fieldlabel);
		select fieldlabel into @fieldlabel from ld_desk where labelbol = var_labelbol and languagetype = 'en' and Labeltype = 'fixedstr';
		insert into ld_tranlabel(languagetype,trantable,tabid,Relateid,fieldlabel) values ('en',tablename, tab_id, producttoofield,@fieldlabel);
	ELSE
		select fieldlabel into @fieldlabel from ld_tranlabel where tabid = tab_id and Relateid = fieldid and trantable = 'ld_field' and languagetype = 'zh';
		insert into ld_tranlabel(languagetype,trantable,tabid,Relateid,fieldlabel) values ('zh',tablename, tab_id, producttoofield,@fieldlabel);
		select fieldlabel into @fieldlabel from ld_tranlabel where tabid = tab_id and Relateid = fieldid and trantable = 'ld_field' and languagetype = 'en';
		insert into ld_tranlabel(languagetype,trantable,tabid,Relateid,fieldlabel) values ('en',tablename, tab_id, producttoofield,@fieldlabel);
	END IF;
end ||
delimiter;

DROP PROCEDURE IF EXISTS setProductToolFields; 
delimiter || 
CREATE PROCEDURE setProductToolFields(IN tabname VARCHAR(50)) 
BEGIN
	declare done int default 0;
	declare p_fieldid  int  default 0;
	declare p_fieldwidth  int;
	declare p_columnname varchar(100);
	declare p_fieldname varchar(100);
	declare p_fieldorder int;
  declare p_uitype int;
	declare p_typeofdata varchar(100);
	declare p_productfieldlist_cnt int default 0;
	declare p_producttoofield_seq_id int default 0;
	declare p_int int default 0;
	declare p_tablename varchar(100);
	declare p_inputtype int default 0;
	declare i int(11) DEFAULT 1;
	declare p_sequence int default 0;
	declare p_count int default 0;
	declare p_wm int default 1;
	declare p_entityUitype int default 0;
	
	declare cur1 CURSOR FOR select ld_productfieldlist.fieldid,ld_productfieldlist.fieldname,ld_field.columnname,fieldwidth,fieldorder,ld_field.uitype,
	ld_field.typeofdata,ld_field.tablename 
	from ld_productfieldlist LEFT JOIN ld_field on ld_productfieldlist.fieldid = ld_field.fieldid ORDER BY fieldorder asc; 
	declare continue handler for not found SET done =1;
	select tabid into @tabid from ld_tab where `name` = tabname;
	select count(1) into @count from ld_producttoolfield where tabid = @tabid;
	update ld_producttoolfield_seq set id = (select max(producttoolfieldid) from ld_producttoolfield);

	select id into p_producttoofield_seq_id from ld_producttoolfield_seq;
	if(@count <= 0)
	then
		select count(1) into p_productfieldlist_cnt from ld_productfieldlist;
		select tabid into @product_tabid from ld_tab where `name` = 'Products';
		open cur1;
		fetch cur1 into p_fieldid,p_fieldname,p_columnname,p_fieldwidth,p_fieldorder,p_uitype,p_typeofdata,p_tablename;
		loop2: while done<>1 do
				set @edit_permission = 2;
				set @presence = 0;
				set p_producttoofield_seq_id = p_producttoofield_seq_id + 1;
				if(p_fieldname = 'productname')
				THEN
					set @edit_permission = 0;
					set p_uitype = 70;
					set @presence  = 2;
					set p_typeofdata = CONCAT(p_typeofdata,'~100');
				ELSE
					set p_inputtype = 1;
				end if;
				if(p_fieldwidth = 0 or p_fieldwidth = '')
				THEN
					IF(p_fieldname = 'productname')
					THEN
						set p_fieldwidth = 15;
					ELSE
						set p_fieldwidth = 10;
					END IF;
				end if;
                select fieldlabel into @zh_fieldlabel from ld_tranlabel where trantable = 'ld_field' and tabid = 14 and languagetype = 'zh' and relateid = p_fieldid limit 1;
				set @psql = CONCAT('insert into ld_producttoolfield(producttoolfieldid,tabid,tablename,columnname,fieldlabel,presence,uitype,typeofdata,sequence,defaultvalue,width,edit_permission,input_type,fieldid) 
				values (',p_producttoofield_seq_id,',',@tabid,',"',p_tablename,'","',p_columnname,'","',@zh_fieldlabel,'",',@presence,',',p_uitype,',"',p_typeofdata,'",',p_fieldorder,',"",',p_fieldwidth,',',@edit_permission,',',p_inputtype,',',p_fieldid,');'); 
				prepare stmt from @psql; 
				execute stmt; 
				deallocate prepare stmt;
				
				insert into ld_tranlabel(languagetype,trantable,tabid,Relateid,fieldlabel) values ('zh','ld_producttoolfield',@tabid,p_producttoofield_seq_id,@zh_fieldlabel);
				select fieldlabel into @fieldlabel from ld_tranlabel where trantable = 'ld_field' and tabid = 14 and languagetype = 'en' and relateid = p_fieldid limit 1;
				insert into ld_tranlabel(languagetype,trantable,tabid,Relateid,fieldlabel) values ('en','ld_producttoolfield',@tabid,p_producttoofield_seq_id,@fieldlabel);
				-- call addTranLabel(@product_tabid,p_fieldid,'ld_producttoolfield','',p_producttoofield_seq_id);

		fetch cur1 into p_fieldid,p_fieldname,p_columnname,p_fieldwidth,p_fieldorder,p_uitype,p_typeofdata,p_tablename;
		end while loop2; 
		close cur1;

		if(tabname != 'ServiceContracts')
		then
			insert into ld_producttoolfield(producttoolfieldid,tabid,tablename,columnname,fieldlabel,presence,uitype,typeofdata,sequence,defaultvalue,width,edit_permission,input_type,fieldid)
			select p_producttoofield_seq_id + producttoolfieldid,@tabid,'ld_inventoryproductrelscf',columnname,fieldlabel,presence,case when uitype = 5 then 51 when uitype = 14 then 54 when uitype = 86 then 52 else uitype end as uitype,typeofdata,sequence,defaultvalue,10,0,0,0 from ld_producttoolfield where tabid = 0;
			set @i = 0;
			select count(1) into @tab_num from ld_producttoolfield where tabid = 0;
			WHILE @i < @tab_num
			DO
				set @stmt = concat('select producttoolfieldid,columnname into @producttoolfieldid,@columnname from ld_producttoolfield where tablename = "ld_inventoryproductrelscf" and tabid = ','''',@tabid,'''',' limit ?,?');
				prepare s1 from @stmt;
				set @s1 = @i;
				set @s2 = 1;
				execute s1 using @s1,@s2;
					set @sql= CONCAT('select ld_tranlabel.fieldlabel into @fieldlabel from ld_producttoolfield 
					INNER JOIN ld_tranlabel on ld_producttoolfield.producttoolfieldid = ld_tranlabel.Relateid 
					where ld_producttoolfield.tabid = 0 and columnname = ' ,'''',@columnname,'''',' and languagetype = "zh" and ld_tranlabel.trantable = "ld_producttoolfield"');
					prepare stmt from @sql;
					execute stmt;
					deallocate  prepare  stmt;	
					insert into ld_tranlabel(languagetype,trantable,tabid,Relateid,fieldlabel) values ('zh','ld_producttoolfield',@tabid,@producttoolfieldid,@fieldlabel);
					set @sql= CONCAT('select ld_tranlabel.fieldlabel into @fieldlabel from ld_producttoolfield 
					INNER JOIN ld_tranlabel on ld_producttoolfield.producttoolfieldid = ld_tranlabel.Relateid 
					where ld_producttoolfield.tabid = 0 and columnname = ' ,'''',@columnname,'''',' and languagetype = "en" and ld_tranlabel.trantable = "ld_producttoolfield"');
					prepare stmt from @sql;
					execute stmt;
					deallocate  prepare  stmt;	
					insert into ld_tranlabel(languagetype,trantable,tabid,Relateid,fieldlabel) values ('en','ld_producttoolfield',@tabid,@producttoolfieldid,@fieldlabel);

				set @i = @i + 1;
			END WHILE;
		END IF;
		update ld_producttoolfield_seq set id = (select max(producttoolfieldid) from ld_producttoolfield);
		select max(producttoolfieldid),max(sequence) into p_producttoofield_seq_id,p_sequence from ld_producttoolfield;
		if(tabname = 'ServiceContracts')
		then
			select deskid,fieldlabel into @deskid,@fieldlabel from ld_desk where labelbol ='Servicestartdate' and languagetype = 'zh' and Labeltype = 'fixedstr';
			insert into ld_producttoolfield(producttoolfieldid,tabid,tablename,columnname,fieldlabel,presence,uitype,typeofdata,sequence,defaultvalue,width,edit_permission,input_type,fieldid)
			select p_producttoofield_seq_id + 1,@tabid,'ld_inventoryproductrel','servicecontracts_start_date',@fieldlabel,0,51,'D~M',p_sequence+1,'thistoday',10,0,0,0;
			call addTranLabel(@tabid,0,'ld_producttoolfield','Servicestartdate',p_producttoofield_seq_id+1);
			select deskid,fieldlabel into @deskid,@fieldlabel from ld_desk where labelbol ='PERIODOFSERVICEEND' and languagetype = 'zh' and Labeltype = 'fixedstr';
			insert into ld_producttoolfield(producttoolfieldid,tabid,tablename,columnname,fieldlabel,presence,uitype,typeofdata,sequence,defaultvalue,width,edit_permission,input_type,fieldid)
			select p_producttoofield_seq_id + 2,@tabid,'ld_inventoryproductrel','servicecontracts_end_date',@fieldlabel,0,51,'D~M',p_sequence+2,'',10,0,2,0;
			call addTranLabel(@tabid,0,'ld_producttoolfield','PERIODOFSERVICEEND',p_producttoofield_seq_id+2);
			update ld_producttoolfield_seq set id = (select max(producttoolfieldid) from ld_producttoolfield);
			select max(producttoolfieldid),max(sequence) into p_producttoofield_seq_id,p_sequence from ld_producttoolfield;
		ELSEIF(tabname = 'PurchaseOrder' or tabname = 'OutboundOrder' or tabname = 'Stock' or tabname = 'invoice' or tabname = 'PurchaseInvoice')-- 插入源单列
		then
			if(tabname = 'PurchaseOrder' or tabname = 'OutboundOrder')THEN
				set p_entityUitype = 200;
			elseif(tabname = 'Stock')THEN
				set p_entityUitype = 201;
			else
				set p_entityUitype = 202;
			end if;
			select deskid,fieldlabel into @deskid,@fieldlabel from ld_desk where labelbol ='ORIGNALBILL' and languagetype = 'zh' and Labeltype = 'fixedstr';
			insert into ld_producttoolfield(producttoolfieldid,tabid,tablename,columnname,fieldlabel,presence,uitype,typeofdata,sequence,defaultvalue,width,edit_permission,input_type,fieldid)
			select p_producttoofield_seq_id + 1,@tabid,'ld_inventoryproductrel','entitytype',@fieldlabel,0,p_entityUitype,'V~O',p_sequence+1,1,10,1,0,0;
			call addTranLabel(@tabid,0,'ld_producttoolfield','ORIGNALBILL',p_producttoofield_seq_id+1);
			update ld_producttoolfield_seq set id = (select max(producttoolfieldid) from ld_producttoolfield);
			select max(producttoolfieldid),max(sequence) into p_producttoofield_seq_id,p_sequence from ld_producttoolfield;
		end if;
		if(tabname = 'Checks')
		THEN
			select deskid,fieldlabel into @deskid,@fieldlabel from ld_desk where labelbol ='BOOKQUANTITY' and languagetype = 'zh' and Labeltype = 'fixedstr';
			select fieldid into @fieldid from ld_field where tabid = (select tabid from ld_tab where `name` = 'products') and columnname = 'qtyinstock';
			insert into ld_producttoolfield(producttoolfieldid,tabid,tablename,columnname,fieldlabel,presence,uitype,typeofdata,sequence,defaultvalue,width,edit_permission,input_type,fieldid)
			select p_producttoofield_seq_id + 1,@tabid,'ld_inventoryproductrel','paperquantity',@fieldlabel,0,11,'N~O',p_sequence+1,0,10,1,1,@fieldid;
			call addTranLabel(@tabid,0,'ld_producttoolfield','BOOKQUANTITY',p_producttoofield_seq_id+1);

			select deskid,fieldlabel into @deskid,@fieldlabel from ld_desk where labelbol ='ANUMBEROF' and languagetype = 'zh' and Labeltype = 'fixedstr';
			insert into ld_producttoolfield(producttoolfieldid,tabid,tablename,columnname,fieldlabel,presence,uitype,typeofdata,sequence,defaultvalue,width,edit_permission,input_type,fieldid)
			select p_producttoofield_seq_id + 2,@tabid,'ld_inventoryproductrel','firmoffer',@fieldlabel,0,11,'N~O',p_sequence+2,0,10,0,0,0;
			call addTranLabel(@tabid,0,'ld_producttoolfield','ANUMBEROF',p_producttoofield_seq_id+2);

			select deskid,fieldlabel into @deskid,@fieldlabel from ld_desk where labelbol ='PROFITLOSSQUANTITY' and languagetype = 'zh' and Labeltype = 'fixedstr';
			insert into ld_producttoolfield(producttoolfieldid,tabid,tablename,columnname,fieldlabel,presence,uitype,typeofdata,sequence,defaultvalue,width,edit_permission,input_type,fieldid)
			select p_producttoofield_seq_id + 3,@tabid,'ld_inventoryproductrel','profitloss',@fieldlabel,0,11,'N~O',p_sequence+3,0,10,1,2,0;
			call addTranLabel(@tabid,0,'ld_producttoolfield','PROFITLOSSQUANTITY',p_producttoofield_seq_id+3);

			select deskid,fieldlabel into @deskid,@fieldlabel from ld_desk where labelbol ='REMARK' and languagetype = 'zh' and Labeltype = 'fixedstr';
			insert into ld_producttoolfield(producttoolfieldid,tabid,tablename,columnname,fieldlabel,presence,uitype,typeofdata,sequence,defaultvalue,width,edit_permission,input_type,fieldid)
			select p_producttoofield_seq_id + 4,@tabid,'ld_inventoryproductrel','remark',@fieldlabel,0,2,'V~O',p_sequence+4,0,10,0,0,0;
			call addTranLabel(@tabid,0,'ld_producttoolfield','REMARK',p_producttoofield_seq_id+4);
		elseif(tabname = 'Productbom')
		THEN
			select deploy_value into @type from ld_systems_deploy where deploy_type = 52;
			select deploy_value into @deploy_value from ld_systems_deploy where deploy_type = '49';
			select deskid,fieldlabel into @deskid,@fieldlabel from ld_desk where labelbol ='QTY' and languagetype = 'zh' and Labeltype = 'fixedstr';
			insert into ld_producttoolfield(producttoolfieldid,tabid,tablename,columnname,fieldlabel,presence,uitype,typeofdata,sequence,defaultvalue,width,edit_permission,input_type,fieldid)
			select p_producttoofield_seq_id + 1,@tabid,'ld_inventoryproductrel','quantity',@fieldlabel,0,10,concat('N~M~',@deploy_value),p_sequence+1,'',10,0,0,0;
			call addTranLabel(@tabid,0,'ld_producttoolfield','QTY',p_producttoofield_seq_id+1);

			select deskid,fieldlabel into @deskid,@fieldlabel from ld_desk where labelbol ='PRODUCTLIST_TAXPRICE' and languagetype = 'zh' and Labeltype = 'fixedstr';
			insert into ld_producttoolfield(producttoolfieldid,tabid,tablename,columnname,fieldlabel,presence,uitype,typeofdata,sequence,defaultvalue,width,edit_permission,input_type,fieldid)
			select p_producttoofield_seq_id + 2,@tabid,'ld_inventoryproductrel','taxprice',@fieldlabel,@type,27,'N~M',p_sequence+2,'',10,0,1,@fieldid;
			call addTranLabel(@tabid,0,'ld_producttoolfield','PRODUCTLIST_TAXPRICE',p_producttoofield_seq_id+2);

			if(@type = 1)THEN	
				set p_wm = 0;
			end if;
			select deskid,fieldlabel into @deskid,@fieldlabel from ld_desk where labelbol ='RMB_EUR_PRICE' and languagetype = 'zh' and Labeltype = 'fixedstr';
			insert into ld_producttoolfield(producttoolfieldid,tabid,tablename,columnname,fieldlabel,presence,uitype,typeofdata,sequence,defaultvalue,width,edit_permission,input_type,fieldid)
			select p_producttoofield_seq_id + 3,@tabid,'','',@fieldlabel,p_wm,20,'N~O',p_sequence+3,0,10,1,2,0;
			call addTranLabel(@tabid,0,'ld_producttoolfield','RMB_EUR_PRICE',p_producttoofield_seq_id+3);

			select deskid,fieldlabel into @deskid,@fieldlabel from ld_desk where labelbol ='PRODUCTLIST_NETPRICE' and languagetype = 'zh' and Labeltype = 'fixedstr';
			insert into ld_producttoolfield(producttoolfieldid,tabid,tablename,columnname,fieldlabel,presence,uitype,typeofdata,sequence,defaultvalue,width,edit_permission,input_type,fieldid)
			select p_producttoofield_seq_id + 4,@tabid,'ld_inventoryproductrel','tax_amount',@fieldlabel,@type,28,'N~O',p_sequence+4,'',10,2,2,0;
			call addTranLabel(@tabid,0,'ld_producttoolfield','PRODUCTLIST_NETPRICE',p_producttoofield_seq_id+4);
			
		else
			select deploy_value into @deploy_value from ld_systems_deploy where deploy_type = '49';
			select deskid,fieldlabel into @deskid,@fieldlabel from ld_desk where labelbol ='QTY' and languagetype = 'zh' and Labeltype = 'fixedstr';
			insert into ld_producttoolfield(producttoolfieldid,tabid,tablename,columnname,fieldlabel,presence,uitype,typeofdata,sequence,defaultvalue,width,edit_permission,input_type,fieldid)
			select p_producttoofield_seq_id + 1,@tabid,'ld_inventoryproductrel','quantity',@fieldlabel,0,10,concat('N~M~',@deploy_value),p_sequence+1,'',10,0,0,0;
			call addTranLabel(@tabid,0,'ld_producttoolfield','QTY',p_producttoofield_seq_id+1);

			select deploy_value into @type from ld_systems_deploy where deploy_type = 52;
			select deploy_value into @deploy_value from ld_systems_deploy where deploy_type = 34;
			if(@deploy_value = 0 && @type = 0)THEN
				set @presence = 0;
			ELSE
				set @presence = 1;
			end if;
			select deskid,fieldlabel into @deskid,@fieldlabel from ld_desk where labelbol ='COSTPRICE' and languagetype = 'zh' and Labeltype = 'fixedstr';-- 成本
			select fieldid into @fieldid from ld_field where tabid = (select tabid from ld_tab where `name` = 'products') and columnname = 'costprice';-- 获取产品模块成本fieldid
			insert into ld_producttoolfield(producttoolfieldid,tabid,tablename,columnname,fieldlabel,presence,uitype,typeofdata,sequence,defaultvalue,width,edit_permission,input_type,fieldid)
			select p_producttoofield_seq_id + 2,@tabid,'ld_inventoryproductrel','productcost',@fieldlabel,@presence,25,'N~O',p_sequence+2,'',10,0,1,@fieldid;
			call addTranLabel(@tabid,0,'ld_producttoolfield','COSTPRICE',p_producttoofield_seq_id+2);

			select deskid,fieldlabel into @deskid,@fieldlabel from ld_desk where labelbol ='EXPECTGP' and languagetype = 'zh' and Labeltype = 'fixedstr';
			insert into ld_producttoolfield(producttoolfieldid,tabid,tablename,columnname,fieldlabel,presence,uitype,typeofdata,sequence,defaultvalue,width,edit_permission,input_type,fieldid)
			select p_producttoofield_seq_id + 3,@tabid,'ld_inventoryproductrel','grossprofit',@fieldlabel,@presence,16,'N~O',p_sequence+3,'',10,0,1,0;
			call addTranLabel(@tabid,0,'ld_producttoolfield','EXPECTGP',p_producttoofield_seq_id+3);

			select deskid,fieldlabel into @deskid,@fieldlabel from ld_desk where labelbol ='PRODUCTLIST_LISTPRICE' and languagetype = 'zh' and Labeltype = 'fixedstr';
			select fieldid into @fieldid from ld_field where tabid = (select tabid from ld_tab where `name` = 'products') and columnname = 'unit_price';
			insert into ld_producttoolfield(producttoolfieldid,tabid,tablename,columnname,fieldlabel,presence,uitype,typeofdata,sequence,defaultvalue,width,edit_permission,input_type,fieldid)
			select p_producttoofield_seq_id + 4,@tabid,'ld_inventoryproductrel','listprice',@fieldlabel,@type,26,'N~M',p_sequence+4,'',10,0,1,@fieldid;
			call addTranLabel(@tabid,0,'ld_producttoolfield','PRODUCTLIST_LISTPRICE',p_producttoofield_seq_id+4);

			select deskid,fieldlabel into @deskid,@fieldlabel from ld_desk where labelbol ='PRODUCTLIST_TAXPRICE' and languagetype = 'zh' and Labeltype = 'fixedstr';
			insert into ld_producttoolfield(producttoolfieldid,tabid,tablename,columnname,fieldlabel,presence,uitype,typeofdata,sequence,defaultvalue,width,edit_permission,input_type,fieldid)
			select p_producttoofield_seq_id + 5,@tabid,'ld_inventoryproductrel','taxprice',@fieldlabel,@type,27,'N~M',p_sequence+5,'',10,0,1,@fieldid;
			call addTranLabel(@tabid,0,'ld_producttoolfield','PRODUCTLIST_TAXPRICE',p_producttoofield_seq_id+5);

			select deskid,fieldlabel into @deskid,@fieldlabel from ld_desk where labelbol ='PRODUCTLIST_AMOUNT' and languagetype = 'zh' and Labeltype = 'fixedstr';
			insert into ld_producttoolfield(producttoolfieldid,tabid,tablename,columnname,fieldlabel,presence,uitype,typeofdata,sequence,defaultvalue,width,edit_permission,input_type,fieldid)
			select p_producttoofield_seq_id + 6,@tabid,'ld_inventoryproductrel','list_amount',@fieldlabel,@type,29,'N~O',p_sequence+6,'',10,2,2,0;
			call addTranLabel(@tabid,0,'ld_producttoolfield','PRODUCTLIST_AMOUNT',p_producttoofield_seq_id+6);

			select deskid,fieldlabel into @deskid,@fieldlabel from ld_desk where labelbol ='PRODUCTLIST_NETPRICE' and languagetype = 'zh' and Labeltype = 'fixedstr';
			insert into ld_producttoolfield(producttoolfieldid,tabid,tablename,columnname,fieldlabel,presence,uitype,typeofdata,sequence,defaultvalue,width,edit_permission,input_type,fieldid)
			select p_producttoofield_seq_id + 7,@tabid,'ld_inventoryproductrel','tax_amount',@fieldlabel,@type,28,'N~O',p_sequence+7,'',10,2,2,0;
			call addTranLabel(@tabid,0,'ld_producttoolfield','PRODUCTLIST_NETPRICE',p_producttoofield_seq_id+7);
			update ld_producttoolfield_seq set id = (select max(producttoolfieldid) from ld_producttoolfield);
			select max(producttoolfieldid),max(sequence) into p_producttoofield_seq_id,p_sequence from ld_producttoolfield;

			select deploy_value into @discount_value from ld_systems_deploy where deploy_type = 43;
			if(@type = 0 && @discount_value = 0)
			THEN
				set @discount_value = 0;
			ELSE	
				set @discount_value = 1;
			end if;
			set @i = 0;
			set @j = 0;
			set @k = 0;
            insert into ld_producttoolfield(producttoolfieldid,tabid,tablename,columnname,fieldlabel,presence,uitype,typeofdata,sequence,defaultvalue,width,edit_permission,input_type,fieldid)
            select (p_producttoofield_seq_id+(@i:=@i+1)) as i,@tabid,'ld_inventoryproductrel',ld_inventorytaxinfo.taxname,ld_tranlabel.fieldlabel,@discount_value,17,'NN~O',(p_sequence+(@j:=@j+1)) as i,percentage,10,0,0,taxid from ld_inventorytaxinfo 
            LEFT JOIN ld_tranlabel on ld_tranlabel.Relateid = ld_inventorytaxinfo.taxid where ld_tranlabel.languagetype = 'zh' 
            and ld_tranlabel.trantable = 'ld_inventorytaxinfo' and ld_inventorytaxinfo.deleted = 0;

			set @n = 0;
			select count(1) into @tab_num from ld_producttoolfield where tabid = @tabid and uitype = 17;
			WHILE @n < @tab_num
			DO
				set @stmt = concat('select producttoolfieldid,fieldid into @producttoolfieldid,@fieldid from ld_producttoolfield where uitype = 17 and tabid = ','''',@tabid,'''',' limit ?,?');
				prepare s1 from @stmt;
				set @s1 = @n;
				set @s2 = 1;
				execute s1 using @s1,@s2;
					set @sql= CONCAT('select ld_tranlabel.fieldlabel into @fieldlabel from ld_producttoolfield 
					INNER JOIN ld_tranlabel on ld_producttoolfield.fieldid = ld_tranlabel.Relateid and ld_producttoolfield.fieldid = ld_tranlabel.tabid
					where ld_tranlabel.tabid = @fieldid and ld_tranlabel.Relateid = @fieldid and languagetype = "zh" and ld_tranlabel.trantable = "ld_inventorytaxinfo" limit 1');
					prepare stmt from @sql;
					execute stmt;
					deallocate  prepare  stmt; 
					insert into ld_tranlabel(languagetype,trantable,tabid,Relateid,fieldlabel) values ('zh','ld_producttoolfield',@tabid,@producttoolfieldid,@fieldlabel);

					set @sql= CONCAT('select ld_tranlabel.fieldlabel into @fieldlabel from ld_producttoolfield 
					INNER JOIN ld_tranlabel on ld_producttoolfield.fieldid = ld_tranlabel.Relateid and ld_producttoolfield.fieldid = ld_tranlabel.tabid
					where ld_tranlabel.tabid = @fieldid and ld_tranlabel.Relateid = @fieldid and languagetype = "en" and ld_tranlabel.trantable = "ld_inventorytaxinfo" limit 1');
					prepare stmt from @sql;
					execute stmt;
					deallocate  prepare  stmt;	
					insert into ld_tranlabel(languagetype,trantable,tabid,Relateid,fieldlabel) values ('en','ld_producttoolfield',@tabid,@producttoolfieldid,@fieldlabel);
				set @n = @n + 1;
			END WHILE;

			select count(1) into @tax_count from ld_inventorytaxinfo where deleted = 0;
			set p_producttoofield_seq_id = p_producttoofield_seq_id + @tax_count;
			set p_sequence = p_sequence + @tax_count;

			select deskid,fieldlabel into @deskid,@fieldlabel from ld_desk where labelbol ='DISCOUNT' and languagetype = 'zh' and Labeltype = 'fixedstr';
			insert into ld_producttoolfield(producttoolfieldid,tabid,tablename,columnname,fieldlabel,presence,uitype,typeofdata,sequence,defaultvalue,width,edit_permission,input_type,fieldid)
			select p_producttoofield_seq_id + 8,@tabid,'ld_inventoryproductrel','discount_percent',@fieldlabel,@discount_value,15,'N~O',p_sequence+8,0,10,0,0,0;
			call addTranLabel(@tabid,0,'ld_producttoolfield','DISCOUNT',p_producttoofield_seq_id+8);
			
			select deskid,fieldlabel into @deskid,@fieldlabel from ld_desk where labelbol ='DIRECTPRICE' and languagetype = 'zh' and Labeltype = 'fixedstr';
			insert into ld_producttoolfield(producttoolfieldid,tabid,tablename,columnname,fieldlabel,presence,uitype,typeofdata,sequence,defaultvalue,width,edit_permission,input_type,fieldid)
			select p_producttoofield_seq_id + 9,@tabid,'ld_inventoryproductrel','discount_amount',@fieldlabel,@discount_value,37,'N~O',p_sequence+9,0,10,1,2,0;
			call addTranLabel(@tabid,0,'ld_producttoolfield','DIRECTPRICE',p_producttoofield_seq_id+9);
			
			select deskid,fieldlabel into @deskid,@fieldlabel from ld_desk where labelbol ='DISCOUNTAMOUNT' and languagetype = 'zh' and Labeltype = 'fixedstr';
			insert into ld_producttoolfield(producttoolfieldid,tabid,tablename,columnname,fieldlabel,presence,uitype,typeofdata,sequence,defaultvalue,width,edit_permission,input_type,fieldid)
			select p_producttoofield_seq_id + 10,@tabid,'ld_inventoryproductrel','discount_total',@fieldlabel,@discount_value,31,'N~O',p_sequence+10,0,10,2,2,0;
			call addTranLabel(@tabid,0,'ld_producttoolfield','DISCOUNTAMOUNT',p_producttoofield_seq_id+10);

			select deskid,fieldlabel into @deskid,@fieldlabel from ld_desk where labelbol ='TAXAMOUNT' and languagetype = 'zh' and Labeltype = 'fixedstr';
			insert into ld_producttoolfield(producttoolfieldid,tabid,tablename,columnname,fieldlabel,presence,uitype,typeofdata,sequence,defaultvalue,width,edit_permission,input_type,fieldid)
			select p_producttoofield_seq_id + 11,@tabid,'ld_inventoryproductrel','tax_total',@fieldlabel,@discount_value,32,'N~O',p_sequence+11,0,10,2,2,0;
			call addTranLabel(@tabid,0,'ld_producttoolfield','TAXAMOUNT',p_producttoofield_seq_id+11);

			if(@type = 1)
			then
				set p_wm = 0;
			end if;

			select deskid,fieldlabel into @deskid,@fieldlabel from ld_desk where labelbol ='RMB_TAXPRICE_LABEL' and languagetype = 'zh' and Labeltype = 'fixedstr';
			insert into ld_producttoolfield(producttoolfieldid,tabid,tablename,columnname,fieldlabel,presence,uitype,typeofdata,sequence,defaultvalue,width,edit_permission,input_type,fieldid)
			select p_producttoofield_seq_id + 12,@tabid,'ld_inventoryproductrel','rmb_taxprice',@fieldlabel,p_wm,38,'N~O',p_sequence+12,0,10,1,2,0;
			call addTranLabel(@tabid,0,'ld_producttoolfield','RMB_TAXPRICE_LABEL',p_producttoofield_seq_id+12);

			select deskid,fieldlabel into @deskid,@fieldlabel from ld_desk where labelbol ='RMB_AMOUNT_LABEL' and languagetype = 'zh' and Labeltype = 'fixedstr';
			insert into ld_producttoolfield(producttoolfieldid,tabid,tablename,columnname,fieldlabel,presence,uitype,typeofdata,sequence,defaultvalue,width,edit_permission,input_type,fieldid)
			select p_producttoofield_seq_id + 13,@tabid,'ld_inventoryproductrel','rmb_taxamount',@fieldlabel,p_wm,50,'N~O',p_sequence+13,0,10,1,2,0;
			call addTranLabel(@tabid,0,'ld_producttoolfield','RMB_AMOUNT_LABEL',p_producttoofield_seq_id+13);

			select deskid,fieldlabel into @deskid,@fieldlabel from ld_desk where labelbol ='DESCRIPTION' and languagetype = 'zh' and Labeltype = 'fixedstr';
			insert into ld_producttoolfield(producttoolfieldid,tabid,tablename,columnname,fieldlabel,presence,uitype,typeofdata,sequence,defaultvalue,width,edit_permission,input_type,fieldid)
			select p_producttoofield_seq_id + 14,@tabid,'ld_inventoryproductrel','comment',@fieldlabel,0,3,'V~O',p_sequence+14,0,20,0,0,0;
			call addTranLabel(@tabid,0,'ld_producttoolfield','DESCRIPTION',p_producttoofield_seq_id+14);

			select deskid,fieldlabel into @deskid,@fieldlabel from ld_desk where labelbol ='RMB_EUR_STANDARDPRICE' and languagetype = 'zh' and Labeltype = 'fixedstr';
			insert into ld_producttoolfield(producttoolfieldid,tabid,tablename,columnname,fieldlabel,presence,uitype,typeofdata,sequence,defaultvalue,width,edit_permission,input_type,fieldid)
			select p_producttoofield_seq_id + 15,@tabid,'ld_inventoryproductrel','rmbprice',@fieldlabel,p_wm,32,'N~O',p_sequence+15,0,10,0,0,0;
			call addTranLabel(@tabid,0,'ld_producttoolfield','RMB_EUR_STANDARDPRICE',p_producttoofield_seq_id+15);

			select deskid,fieldlabel into @deskid,@fieldlabel from ld_desk where labelbol ='RMB_DISCOUNT_RATE' and languagetype = 'zh' and Labeltype = 'fixedstr';
			insert into ld_producttoolfield(producttoolfieldid,tabid,tablename,columnname,fieldlabel,presence,uitype,typeofdata,sequence,defaultvalue,width,edit_permission,input_type,fieldid)
			select p_producttoofield_seq_id + 16,@tabid,'ld_inventoryproductrel','discount_percent',@fieldlabel,p_wm,20,'N~O',p_sequence+16,100,10,0,0,0;
			call addTranLabel(@tabid,0,'ld_producttoolfield','RMB_DISCOUNT_RATE',p_producttoofield_seq_id+16);

			select deskid,fieldlabel into @deskid,@fieldlabel from ld_desk where labelbol ='RMB_EUR_PRICE' and languagetype = 'zh' and Labeltype = 'fixedstr';
			insert into ld_producttoolfield(producttoolfieldid,tabid,tablename,columnname,fieldlabel,presence,uitype,typeofdata,sequence,defaultvalue,width,edit_permission,input_type,fieldid)
			select p_producttoofield_seq_id + 17,@tabid,'ld_inventoryproductrel','eur_price',@fieldlabel,p_wm,20,'N~O',p_sequence+17,0,10,1,2,0;
			call addTranLabel(@tabid,0,'ld_producttoolfield','RMB_EUR_PRICE',p_producttoofield_seq_id+17);

			select deskid,fieldlabel into @deskid,@fieldlabel from ld_desk where labelbol ='RMB_DISCOUNT_AMOUNT' and languagetype = 'zh' and Labeltype = 'fixedstr';
			insert into ld_producttoolfield(producttoolfieldid,tabid,tablename,columnname,fieldlabel,presence,uitype,typeofdata,sequence,defaultvalue,width,edit_permission,input_type,fieldid)
			select p_producttoofield_seq_id + 18,@tabid,'ld_inventoryproductrel','discount_amount',@fieldlabel,p_wm,20,'N~O',p_sequence+18,0,10,0,0,0;
			call addTranLabel(@tabid,0,'ld_producttoolfield','RMB_DISCOUNT_AMOUNT',p_producttoofield_seq_id+18);

			select deskid,fieldlabel into @deskid,@fieldlabel from ld_desk where labelbol ='Exchange Rate' and languagetype = 'zh' and Labeltype = 'fixedstr';
			insert into ld_producttoolfield(producttoolfieldid,tabid,tablename,columnname,fieldlabel,presence,uitype,typeofdata,sequence,defaultvalue,width,edit_permission,input_type,fieldid)
			select p_producttoofield_seq_id + 19,@tabid,'ld_inventoryproductrel','tax_rate',@fieldlabel,p_wm,21,'N~O',p_sequence+19,0,10,0,0,0;
			call addTranLabel(@tabid,0,'ld_producttoolfield','Exchange Rate',p_producttoofield_seq_id+19);

			select deskid,fieldlabel into @deskid,@fieldlabel from ld_desk where labelbol ='RMB_TARIFF_RATE' and languagetype = 'zh' and Labeltype = 'fixedstr';
			select percentage/100 into @percentage from ld_inventorytaxinfo where taxname = 'tax_customs'; 
			insert into ld_producttoolfield(producttoolfieldid,tabid,tablename,columnname,fieldlabel,presence,uitype,typeofdata,sequence,defaultvalue,width,edit_permission,input_type,fieldid)
			select p_producttoofield_seq_id + 20,@tabid,'ld_inventoryproductrel','tax_customs',@fieldlabel,p_wm,21,'N~O',p_sequence+20,@percentage,10,0,0,0;
			call addTranLabel(@tabid,0,'ld_producttoolfield','RMB_TARIFF_RATE',p_producttoofield_seq_id+20);

			select deskid,fieldlabel into @deskid,@fieldlabel from ld_desk where labelbol ='RMB_VAT_RATE' and languagetype = 'zh' and Labeltype = 'fixedstr';
			select percentage/100 into @percentage from ld_inventorytaxinfo where taxname = 'tax_added'; 
			insert into ld_producttoolfield(producttoolfieldid,tabid,tablename,columnname,fieldlabel,presence,uitype,typeofdata,sequence,defaultvalue,width,edit_permission,input_type,fieldid)
			select p_producttoofield_seq_id + 21,@tabid,'ld_inventoryproductrel','tax_added',@fieldlabel,p_wm,21,'N~O',p_sequence+21,@percentage,10,0,0,0;
			call addTranLabel(@tabid,0,'ld_producttoolfield','RMB_VAT_RATE',p_producttoofield_seq_id+21);

			select deskid,fieldlabel into @deskid,@fieldlabel from ld_desk where labelbol ='RMB_FREIGHT_COEFFICIENT' and languagetype = 'zh' and Labeltype = 'fixedstr';
			select percentage/100 into @percentage from ld_inventorytaxinfo where taxname = 'tax_profit'; 
			insert into ld_producttoolfield(producttoolfieldid,tabid,tablename,columnname,fieldlabel,presence,uitype,typeofdata,sequence,defaultvalue,width,edit_permission,input_type,fieldid)
			select p_producttoofield_seq_id + 22,@tabid,'ld_inventoryproductrel','tax_freight',@fieldlabel,p_wm,21,'N~O',p_sequence+22,@percentage,10,0,0,0;
			call addTranLabel(@tabid,0,'ld_producttoolfield','RMB_FREIGHT_COEFFICIENT',p_producttoofield_seq_id+22);

			select deskid,fieldlabel into @deskid,@fieldlabel from ld_desk where labelbol ='RMB_PROFIT_RATE' and languagetype = 'zh' and Labeltype = 'fixedstr';
			select percentage/100 into @percentage from ld_inventorytaxinfo where taxname = 'tax_freight'; 
			insert into ld_producttoolfield(producttoolfieldid,tabid,tablename,columnname,fieldlabel,presence,uitype,typeofdata,sequence,defaultvalue,width,edit_permission,input_type,fieldid)
			select p_producttoofield_seq_id + 23,@tabid,'ld_inventoryproductrel','tax_profit',@fieldlabel,p_wm,21,'N~O',p_sequence+23,@percentage,10,0,0,0;
			call addTranLabel(@tabid,0,'ld_producttoolfield','RMB_PROFIT_RATE',p_producttoofield_seq_id+23);

			select deploy_value into @subtype_value from ld_systems_deploy where deploy_type = 42;

			if(@type = 0)
			then
				select tablename,fieldid,columnname into @tablename,@fieldid,@columnname from ld_field where tabid = @tabid and fieldname = 'hdnSubTotal';
				insert into ld_producttoolfield(producttoolfieldid,tabid,tablename,columnname,fieldlabel,presence,uitype,typeofdata,sequence,defaultvalue,width,edit_permission,input_type,fieldid,newline)
				select p_producttoofield_seq_id + 30,@tabid,@tablename,@columnname,'小计',@subtype_value,33,'N~O',p_sequence+30,0,10,1,1,@fieldid,2;
				call addTranLabel(@tabid,@fieldid,'ld_producttoolfield','',p_producttoofield_seq_id+30);
			ELSE
				select tablename,fieldid,columnname into @tablename,@fieldid,@columnname from ld_field where tabid = @tabid and fieldname = 'hdnSubTotal';
				insert into ld_producttoolfield(producttoolfieldid,tabid,tablename,columnname,fieldlabel,presence,uitype,typeofdata,sequence,defaultvalue,width,edit_permission,input_type,fieldid,newline)
				select p_producttoofield_seq_id + 30,@tabid,@tablename,@columnname,'共计含税含运费RMB总价',@subtype_value,33,'N~O',p_sequence+30,0,10,1,1,@fieldid,1;
				call addTranLabel(@tabid,0,'ld_producttoolfield','RMB_SUBTOTAL',p_producttoofield_seq_id+30);
			end if;
			select tablename,fieldid,columnname into @table_name,@fieldid,@columnname from ld_field where tabid = @tabid and fieldname = 'hdnDiscountAmount';
			insert into ld_producttoolfield(producttoolfieldid,tabid,tablename,columnname,fieldlabel,presence,uitype,typeofdata,sequence,defaultvalue,width,edit_permission,input_type,fieldid,newline)
			select p_producttoofield_seq_id + 31,@tabid,@table_name,'discount_amount','整单折扣',@subtype_value,37,'N~O',p_sequence+31,0,10,0,0,@fieldid,1;
			call addTranLabel(@tabid,@fieldid,'ld_producttoolfield','ALLSINGLEDISCOUNT',p_producttoofield_seq_id+31);

			select tablename,fieldid,columnname into @table_name,@fieldid,@columnname from ld_field where tabid = @tabid and fieldname = 'txtAdjustment';
			insert into ld_producttoolfield(producttoolfieldid,tabid,tablename,columnname,fieldlabel,presence,uitype,typeofdata,sequence,defaultvalue,width,edit_permission,input_type,fieldid,newline)
			select p_producttoofield_seq_id + 32,@tabid,@table_name,@columnname,'调整',@subtype_value,35,'N~O',p_sequence+32,0,10,0,0,@fieldid,1;
			call addTranLabel(@tabid,@fieldid,'ld_producttoolfield','',p_producttoofield_seq_id+32);

			select tablename,fieldid,columnname into @table_name,@fieldid,@columnname from ld_field where tabid = @tabid and fieldname = 'hdnGrandTotal';
			insert into ld_producttoolfield(producttoolfieldid,tabid,tablename,columnname,fieldlabel,presence,uitype,typeofdata,sequence,defaultvalue,width,edit_permission,input_type,fieldid,newline)
			select p_producttoofield_seq_id + 33,@tabid,@table_name,@columnname,'合计',0,36,'N~O',p_sequence+33,0,10,0,1,@fieldid,1;
			call addTranLabel(@tabid,@fieldid,'ld_producttoolfield','',p_producttoofield_seq_id+33);
		end if;
		update ld_producttoolfield_seq set id = (select max(producttoolfieldid) from ld_producttoolfield);
	end if;
end ||
delimiter;

call setProductToolFields('SalesOrder');
delimiter;
call setProductToolFields('ServiceContracts');
delimiter;
call setProductToolFields('Quotes');
delimiter;
call setProductToolFields('SalesBack');
delimiter;
call setProductToolFields('PurchaseOrder');
delimiter;
call setProductToolFields('PurchaseBack');
delimiter;
call setProductToolFields('OutboundOrder');
delimiter;
call setProductToolFields('Stock');
delimiter;
call setProductToolFields('WareHouseTransfer');
delimiter;
call setProductToolFields('PurchaseInvoice');
delimiter;
call setProductToolFields('Invoice');
delimiter;
call setProductToolFields('CashBack');
delimiter;
call setProductToolFields('PurchaseCashBack');
delimiter;
call setProductToolFields('Invoice');
delimiter;
call setProductToolFields('Checks');
delimiter;
call setProductToolFields('Productbom');
delimiter;

delete from ld_settings_field where name = 'LBL_RELATED_PARAMETERS';
DROP TABLE IF EXISTS ld_productbasevalues;
DROP TABLE IF EXISTS ld_productfieldlist;
DROP TABLE IF EXISTS ld_inventoryshippingrel;
delimiter;

update ld_inventoryproductrel set discount_total = listprice*(1-discount_percent/100) where discount_percent >0 and discount_amount = 0;
delimiter;
update ld_inventoryproductrel set discount_total = listprice - discount_amount where discount_percent = 0 and discount_amount > 0;
delimiter;
update ld_inventoryproductrel set discount_total = listprice where discount_percent = 0 and discount_amount =0;
delimiter;
update ld_inventoryproductrel set tax_total = discount_total*((tax1+tax2+tax3)/100) where tax_total = 0;
delimiter;
update ld_inventoryproductrel set list_amount = quantity*listprice where list_amount = 0;
delimiter;
update ld_inventoryproductrel set tax_amount = discount_total + tax_total where tax_amount = 0;
delimiter;
update ld_inventoryproductrel set eur_price = discount_amount*discount_percent/100 where eur_price = 0;
delimiter;
update ld_inventoryproductrel set tax_profit = grossprofit where tax_profit = 0;
delimiter;

update ld_inventoryproductrel set rmb_taxprice = rmbprice * (CASE WHEN IFNULL(tax_rate,0) > 0 THEN IFNULL(tax_rate,0) ELSE 1 END)
* (CASE WHEN IFNULL(tax_customs,0) > 0 THEN IFNULL(tax_customs,0) ELSE 1 END)
* (CASE WHEN IFNULL(tax_added,0) > 0 THEN IFNULL(tax_added,0) ELSE 1 END)
* (CASE WHEN IFNULL(tax_freight,0) > 0 THEN IFNULL(tax_freight,0) ELSE 1 END)
* (CASE WHEN IFNULL(tax_profit,0) > 0 THEN IFNULL(tax_profit,0) ELSE 1 END) - discount_amount where rmb_taxprice is NULL or rmb_taxprice = 0;
delimiter;

update ld_inventoryproductrel set rmb_taxamount = quantity*rmb_taxprice where rmb_taxamount = 0;
delimiter;

UPDATE ld_desk SET fieldlabel = '更改状态' WHERE labelbol = 'UPDATESTATE' AND Labeltype = 'fixedstr' AND languagetype = 'zh';
UPDATE ld_desk SET fieldlabel = 'Update state' WHERE labelbol = 'UPDATESTATE' AND Labeltype = 'fixedstr' AND languagetype = 'en';
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'zh','Statelistisempty','单据状态列表为空','jspop' from dual where not EXISTS(select 1 from ld_desk where languagetype='zh' and labelbol='Statelistisempty' and Labeltype='jspop');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'en','Statelistisempty','State list is empty','jspop' from dual where not EXISTS(select 1 from ld_desk  where languagetype='en' and labelbol='Statelistisempty' and Labeltype='jspop');
delimiter;

CALL AddColumn('ld_users','dingjie_permit','int','1',0);
delimiter;

alter table ld_tranlabel change Tranlabelid tranlabelid int(11);
delete from ld_tranlabel where tranlabelid=0;
delete from ld_templateprint where templateprintid=0;
alter table ld_tranlabel change Tranlabelid tranlabelid int(11) auto_increment;
alter table ld_templateprint change TemplateprintID templateprintid int(19) auto_increment;
alter table ld_templateprint change Tabid tabid int(19);
alter table ld_templateprint change isDefault isdefault int(1);
alter table ld_templateprint change TemplatePrintName templateprintname varchar(50);
alter table ld_templateprint change SystemDefault systemdefault int(1);
alter table ld_templatesstuff change stuffId stuffid int(19);
alter table ld_templatesstuff change Stufftype stufftype varchar(50);
delimiter;
-- 2015-06-29

call AddColumn('ld_singin','distince','int',10,0);
delimiter;

update ld_inventorytaxinfo set deleted=0 where taxid=2 and not exists (select 1 from ld_inventoryproductrel);
update ld_inventorytaxinfo set deleted=1 where taxid<>2 and not exists (select 1 from ld_inventoryproductrel);
update ld_producttoolfield set presence=0 where columnname in (select taxname from ld_inventorytaxinfo where taxid=2) and not exists (select 1 from ld_inventoryproductrel);
update ld_producttoolfield set presence=1 where columnname in (select taxname from ld_inventorytaxinfo where taxid<>2) and not exists (select 1 from ld_inventoryproductrel);
update ld_tranlabel set fieldlabel='折扣额' where fieldlabel='直接降价' and languagetype='zh' and trantable='ld_producttoolfield';
update ld_tranlabel set fieldlabel='折后金额' where fieldlabel='折扣金额' and languagetype='zh' and trantable='ld_producttoolfield';
update ld_producttoolfield set presence=1 where columnname='discount_total';
update ld_tranlabel set fieldlabel='价税合计' where fieldlabel='含税金额' and languagetype='zh' and trantable='ld_producttoolfield';
update ld_producttoolfield set fieldlabel='价税合计' where columnname='tax_amount';
update ld_producttoolfield set fieldlabel='折后金额' where columnname='discount_total';
delete from ld_producttoolfield where columnname='discount_total';
delete from ld_tranlabel where fieldlabel='折后金额' and languagetype='zh' and trantable='ld_producttoolfield';
delimiter;

DROP PROCEDURE IF EXISTS `updateprofieldseq`;
delimiter ||
CREATE  PROCEDURE `updateprofieldseq`(

)
begin

	declare tmp_tabid  int default 0;
	declare tmp_columnname  varchar(200) default NULL;
	declare mycursor cursor for select columnname,tabid from ld_producttoolfield where columnname='tax_amount' order by tabid; 
	DECLARE CONTINUE HANDLER FOR SQLSTATE '02000' set tmp_tabid = NULL;

	open mycursor;
	fetch mycursor into tmp_columnname,tmp_tabid;
	while(tmp_tabid is not null) DO
			set @seq=0;
			set @i=0;
			select sequence into @seq from ld_producttoolfield where tabid=tmp_tabid and columnname='subtotal';
			update ld_producttoolfield set sequence=sequence+5 where tabid=tmp_tabid and sequence>=@seq;
			update ld_producttoolfield set sequence=@seq where tabid=tmp_tabid and columnname='tax_amount';
			update ld_producttoolfield set sequence=@seq+1 where tabid=tmp_tabid and columnname='productcost';
			update ld_producttoolfield set sequence=@seq+2 where tabid=tmp_tabid and columnname='grossprofit';
			update ld_producttoolfield set sequence=@seq+3 where tabid=tmp_tabid and columnname='comment';
			update ld_producttoolfield set sequence=(@i:=@i+1) where tabid=tmp_tabid order by sequence;
			
			fetch mycursor into tmp_columnname,tmp_tabid;
	end while;
	close mycursor;
end ||
delimiter;

call updateprofieldseq();
delimiter;

call AddColumn('ld_users','dingjie_permit','int','1',0);
delimiter;

update ld_profile2field set visible = 0 where tabid = (select tabid from ld_tab where `name` = 'Reminds');
call AddColumn('ld_producttoolfield_formula','sequence','int','1',0);
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','WHOLESALERS','价税','fixedstr' from dual 
where not exists(select 1 from ld_desk where labelbol = 'WHOLESALERS' and languagetype = 'zh' and labeltype = 'fixedstr');

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','WHOLESALERS','Price Tax','fixedstr' from dual 
where not exists(select 1 from ld_desk where labelbol = 'WHOLESALERS' and languagetype = 'en' and labeltype = 'fixedstr');
delimiter;
-- 2015-06-30

SELECT usereportid INTO @uid FROM ld_usereport WHERE name='SendCashBillSum_PurchaseOrder';
UPDATE ld_usereportbasic SET columns='ld_purchaseorder:duedate:duedate:PurchaseOrder_duedate:D' 
WHERE Usereportid=@uid AND Sequence=3;
delimiter;
SELECT usereportid INTO @uid FROM ld_usereport WHERE name='SendCashBillSum_SendPayment';
UPDATE ld_usereportbasic SET columns='ld_sendpayment:Plandate:Plandate:SendPayment_Plandate:D' 
WHERE Usereportid=@uid AND Sequence=3;
delimiter;
SELECT usereportid INTO @uid FROM ld_usereport WHERE name='SendCashBillSum_PurchaseOrder';
UPDATE ld_usereportbasic SET columns='ld_purchaseorder:duedate:duedate:PurchaseOrder_duedate:D' 
WHERE Usereportid=@uid AND Sequence=3;
delimiter;
SELECT usereportid INTO @uid FROM ld_usereport WHERE name='SendCashBillSum_SendPayment';
UPDATE ld_usereportbasic SET columns='ld_sendpayment:Plandate:Plandate:SendPayment_Plandate:D' 
WHERE Usereportid=@uid AND Sequence=3;
delimiter;

select tabid into @tabid from ld_tab where name='servicecontracts';
select producttoolfieldid into @producttoolfieldid from ld_producttoolfield where tabid=@tabid and columnname='servicecontracts_end_date';
insert into ld_producttoolfield_formula (producttoolfieldid,formulastring,columnstring)
select @producttoolfieldid,'a+365','{formulavar:[{''lettervar'':''a'',''column'':''servicecontracts_start_date''}]}' from dual
where not EXISTS(select 1 from ld_producttoolfield_formula where producttoolfieldid=@producttoolfieldid);

select tabid into @tabid from ld_tab where name='checks';
select producttoolfieldid into @producttoolfieldid from ld_producttoolfield where tabid=@tabid and columnname='profitloss';
insert into ld_producttoolfield_formula (producttoolfieldid,formulastring,columnstring)
select @producttoolfieldid,'a-b','{formulavar:[{''lettervar'':''a'',''column'':''firmoffer''},{''lettervar'':''b'',''column'':''paperquantity''}]}' from dual
where not EXISTS(select 1 from ld_producttoolfield_formula where producttoolfieldid=@producttoolfieldid);
delimiter;

drop table  if EXISTS tmp_letter;
create   table  tmp_letter( letter varchar(50));
	insert into tmp_letter(letter)value('a');
	insert into tmp_letter(letter)value('b');
	insert into tmp_letter(letter)value('c');
	insert into tmp_letter(letter)value('d');
	insert into tmp_letter(letter)value('e');
	insert into tmp_letter(letter)value('f');
	insert into tmp_letter(letter)value('g');
	insert into tmp_letter(letter)value('h');
	insert into tmp_letter(letter)value('i');
	insert into tmp_letter(letter)value('j');
	insert into tmp_letter(letter)value('k');
	insert into tmp_letter(letter)value('l');
	insert into tmp_letter(letter)value('m');
	insert into tmp_letter(letter)value('n');
	insert into tmp_letter(letter)value('o');
	insert into tmp_letter(letter)value('p');
	insert into tmp_letter(letter)value('q');
	insert into tmp_letter(letter)value('r');
	insert into tmp_letter(letter)value('s');
	insert into tmp_letter(letter)value('t');
	insert into tmp_letter(letter)value('u');
	insert into tmp_letter(letter)value('v');
	insert into tmp_letter(letter)value('w');
	insert into tmp_letter(letter)value('x');
	insert into tmp_letter(letter)value('y');

drop table  if EXISTS tmp_taxformula;
create   table  tmp_taxformula( column_string varchar(500),letter_string varchar(200),nextletterstart int(10));
delimiter;

drop PROCEDURE if EXISTS getTaxInfoForFormula;
delimiter ||
create PROCEDURE getTaxInfoForFormula(
	letter_start int(11)
)
begin
	declare  done int default 0;
  declare tax_column varchar(50);
  declare column_string varchar(500);
  declare letter_string varchar(500);
	declare cur_tax CURSOR FOR select  taxname  from ld_inventorytaxinfo where deleted=0;
	declare continue handler  for not   found  SET done =1;
  select count(1) into @cnt_row   from ld_inventorytaxinfo where deleted=0;
	OPEN cur_tax;
	
	delete  from  tmp_taxformula;
	Fetch cur_tax into tax_column;
  set column_string='';
	set letter_string='';
  set @i=0;
	set @cnt_row=@cnt_row-1;

	loop1: while  done<>1 DO
     set @letterstart=letter_start+@i;
		 SET @sql = CONCAT('SELECT letter  into @letter  from tmp_letter LIMIT ', @letterstart,',1');
     PREPARE stmt FROM @sql;
     EXECUTE stmt;

	   if @i<@cnt_row  then 
				set letter_string=concat(letter_string,@letter,'+');
        set column_string=concat(column_string,'{\'''''''','lettervar','\'''''''',':\'''''''',@letter,'\'''''''',',\'''''''','column','\'''''''',':\'''''''',tax_column,'\'''''''},');
	   else
				set letter_string=concat(letter_string,@letter);
				set column_string=concat(column_string,'{\'''''''','lettervar','\'''''''',':\'''''''',@letter,'\'''''''',',\'''''''','column','\'''''''',':\'''''''',tax_column,'\'''''''}');
		 end if;
	     set @i=@i+1;
		 fetch cur_tax into tax_column;
	end while loop1;
	close cur_tax;
	
	set @letterstart=@cnt_row+letter_start+1;
	SET @sqll = CONCAT('insert into tmp_taxformula(letter_string,column_string,nextletterstart)value(''', letter_string,''',''',column_string,''',',@letterstart,')') ;
	PREPARE stmt FROM @sqll;
  EXECUTE stmt;
	deallocate prepare stmt;
end ||
delimiter;

call getTaxInfoForFormula(1); 
delimiter;

select tabid into @tabid from ld_tab where name='salesorder';
select producttoolfieldid into @producttoolfieldid from ld_producttoolfield where tabid=@tabid and columnname='taxprice';
select column_string into @column_string from tmp_taxformula;
select letter_string into @letter_string  from tmp_taxformula;
set @formula_column_string=concat('{formulavar:[{''''lettervar'''':''''a'''',''''column'''':''''listprice''''},',@column_string,']}');
set @formula_letter_string=concat('a*(1+(',@letter_string,')/100)');
set @formulsql=concat('insert into ld_producttoolfield_formula (producttoolfieldid,formulastring,columnstring,sequence)  select ', @producttoolfieldid,' ,''',@formula_letter_string,''',''',@formula_column_string,''',',' 1 from dual where not EXISTS(select 1 from ld_producttoolfield_formula where producttoolfieldid=',@producttoolfieldid,')');

PREPARE stmt FROM @formulsql;
EXECUTE stmt;
DEALLOCATE prepare stmt;
delimiter;

select tabid into @tabid from ld_tab where name='salesorder';
select producttoolfieldid into @producttoolfieldid from ld_producttoolfield where tabid=@tabid and columnname='listprice';
select column_string into @column_string from tmp_taxformula;
select letter_string into @letter_string  from tmp_taxformula;
set @formula_column_string=concat('{formulavar:[{''''lettervar'''':''''a'''',''''column'''':''''taxprice''''},',@column_string,']}');
set @formula_letter_string=concat('a/(1+(',@letter_string,')/100)');
set @formulsql=concat('insert into ld_producttoolfield_formula (producttoolfieldid,formulastring,columnstring,sequence)  select ', @producttoolfieldid,' ,''',@formula_letter_string,''',''',@formula_column_string,''',',2,' from dual where not EXISTS(select 1 from ld_producttoolfield_formula where producttoolfieldid=',@producttoolfieldid,')');
PREPARE stmt FROM @formulsql;
EXECUTE stmt;
DEALLOCATE prepare stmt;
delimiter;


call getTaxInfoForFormula(1); 
select column_string into @column_string from tmp_taxformula;
select letter_string into @letter_string  from tmp_taxformula;
select nextletterstart into @nextletterstart from tmp_taxformula;

select tabid into @tabid from ld_tab where name='salesorder';
SET @sqlletter = CONCAT('select letter into @quantity_letter from tmp_letter limit ',@nextletterstart,',1') ;
PREPARE stmt FROM @sqlletter;
EXECUTE stmt;
DEALLOCATE prepare stmt;

set @nextletterstart=@nextletterstart+1;
SET @sqlletter = CONCAT('select letter into @discount_percent from tmp_letter limit ',@nextletterstart,',1') ;
PREPARE stmt FROM @sqlletter;
EXECUTE stmt;
DEALLOCATE prepare stmt;

set @formula_column_string=concat('{formulavar:[{''''lettervar'''':''''a'''',''''column'''':''''taxprice''''},',@column_string,',{''''lettervar'''':''''',@quantity_letter,'''''',',''''column''''',':','''''quantity''''}',',{''''lettervar'''':''''',@discount_percent,'''''',',''''column''''',':','''''discount_percent''''}]}');
set @formula_letter_string=concat('(a/(1+(',@letter_string,')/100))*',@quantity_letter,'*(1-',@discount_percent,'/100)');

select producttoolfieldid into @producttoolfieldid from ld_producttoolfield where tabid=@tabid and columnname='list_amount';
 set @formulsql=concat('insert into ld_producttoolfield_formula (producttoolfieldid,formulastring,columnstring,sequence)  select ', @producttoolfieldid,' ,''',@formula_letter_string,''',''',@formula_column_string,''',',' 3 from dual where not EXISTS(select 1 from ld_producttoolfield_formula where producttoolfieldid=',@producttoolfieldid,')');
PREPARE stmt FROM @formulsql;
EXECUTE stmt;
DEALLOCATE prepare stmt;
delimiter;


select tabid into @tabid from ld_tab where name='salesorder';
select producttoolfieldid into @producttoolfieldid from ld_producttoolfield where tabid=@tabid and columnname='tax_amount';
select column_string into @column_string from tmp_taxformula;
select letter_string into @letter_string  from tmp_taxformula;
insert into ld_producttoolfield_formula (producttoolfieldid,formulastring,columnstring,sequence)
select @producttoolfieldid,'a*b*(1-c/100)','{formulavar:[{''lettervar'':''a'',''column'':''quantity''},{''lettervar'':''b'',''column'':''taxprice''},{''lettervar'':''c'',''column'':''discount_percent''}]}',4 from dual
where not EXISTS(select 1 from ld_producttoolfield_formula where producttoolfieldid=@producttoolfieldid);
delimiter;


call getTaxInfoForFormula(1);
select tabid into @tabid from ld_tab where name='salesorder';
select producttoolfieldid into @producttoolfieldid from ld_producttoolfield where tabid=@tabid and columnname='tax_total';
select column_string into @column_string from tmp_taxformula;
select letter_string into @letter_string  from tmp_taxformula;

set @formula_column_string=concat('{formulavar:[{''''lettervar'''':''''a'''',''''column'''':''''list_amount''''},',@column_string,']}');
set @formula_letter_string=concat('a*((',@letter_string,')/100)');

set @formulsql=concat('insert into ld_producttoolfield_formula (producttoolfieldid,formulastring,columnstring,sequence)  select ', @producttoolfieldid,' ,''',@formula_letter_string,''',''',@formula_column_string,''',',' 5 from dual where not EXISTS(select 1 from ld_producttoolfield_formula where producttoolfieldid=',@producttoolfieldid,')');
PREPARE stmt FROM @formulsql;
EXECUTE stmt;
DEALLOCATE prepare stmt;
delimiter;
select tabid into @tabid from ld_tab where name='salesorder';
select producttoolfieldid into @producttoolfieldid from ld_producttoolfield where tabid=@tabid and presence in(0,2) and  columnname='discount_amount' and tablename='ld_inventoryproductrel';
select column_string into @column_string from tmp_taxformula;
select letter_string into @letter_string  from tmp_taxformula;
insert into ld_producttoolfield_formula (producttoolfieldid,formulastring,columnstring,sequence)
select @producttoolfieldid,'a*b*(c/100)','{formulavar:[{''lettervar'':''a'',''column'':''quantity''},{''lettervar'':''b'',''column'':''taxprice''},{''lettervar'':''c'',''column'':''discount_percent''}]}',8 from dual
where not EXISTS(select 1 from ld_producttoolfield_formula where producttoolfieldid=@producttoolfieldid);
delimiter;



call getTaxInfoForFormula(1); 
select tabid into @tabid from ld_tab where name='quotes';
select producttoolfieldid into @producttoolfieldid from ld_producttoolfield where tabid=@tabid and columnname='taxprice';
select column_string into @column_string from tmp_taxformula;
select letter_string into @letter_string  from tmp_taxformula;
set @formula_column_string=concat('{formulavar:[{''''lettervar'''':''''a'''',''''column'''':''''listprice''''},',@column_string,']}');
set @formula_letter_string=concat('a*(1+(',@letter_string,')/100)');
set @formulsql=concat('insert into ld_producttoolfield_formula (producttoolfieldid,formulastring,columnstring,sequence)  select ', @producttoolfieldid,' ,''',@formula_letter_string,''',''',@formula_column_string,''',',' 1 from dual where not EXISTS(select 1 from ld_producttoolfield_formula where producttoolfieldid=',@producttoolfieldid,')');

PREPARE stmt FROM @formulsql;
EXECUTE stmt;
DEALLOCATE prepare stmt;
delimiter;
select tabid into @tabid from ld_tab where name='quotes';
select producttoolfieldid into @producttoolfieldid from ld_producttoolfield where tabid=@tabid and columnname='listprice';
select column_string into @column_string from tmp_taxformula;
select letter_string into @letter_string  from tmp_taxformula;
set @formula_column_string=concat('{formulavar:[{''''lettervar'''':''''a'''',''''column'''':''''taxprice''''},',@column_string,']}');
set @formula_letter_string=concat('a/(1+(',@letter_string,')/100)');
set @formulsql=concat('insert into ld_producttoolfield_formula (producttoolfieldid,formulastring,columnstring,sequence)  select ', @producttoolfieldid,' ,''',@formula_letter_string,''',''',@formula_column_string,''',',2,' from dual where not EXISTS(select 1 from ld_producttoolfield_formula where producttoolfieldid=',@producttoolfieldid,')');
PREPARE stmt FROM @formulsql;
EXECUTE stmt;
DEALLOCATE prepare stmt;
delimiter;


call getTaxInfoForFormula(1); 
select column_string into @column_string from tmp_taxformula;
select letter_string into @letter_string  from tmp_taxformula;
select nextletterstart into @nextletterstart from tmp_taxformula;
select tabid into @tabid from ld_tab where name='quotes';
SET @sqlletter = CONCAT('select letter into @quantity_letter from tmp_letter limit ',@nextletterstart,',1') ;
PREPARE stmt FROM @sqlletter;
EXECUTE stmt;
DEALLOCATE prepare stmt;

set @nextletterstart=@nextletterstart+1;
SET @sqlletter = CONCAT('select letter into @discount_percent from tmp_letter limit ',@nextletterstart,',1') ;
PREPARE stmt FROM @sqlletter;
EXECUTE stmt;
DEALLOCATE prepare stmt;

set @formula_column_string=concat('{formulavar:[{''''lettervar'''':''''a'''',''''column'''':''''taxprice''''},',@column_string,',{''''lettervar'''':''''',@quantity_letter,'''''',',''''column''''',':','''''quantity''''}',',{''''lettervar'''':''''',@discount_percent,'''''',',''''column''''',':','''''discount_percent''''}]}');
set @formula_letter_string=concat('(a/(1+(',@letter_string,')/100))*',@quantity_letter,'*(1-',@discount_percent,'/100)');

select producttoolfieldid into @producttoolfieldid from ld_producttoolfield where tabid=@tabid and columnname='list_amount';
set @formulsql=concat('insert into ld_producttoolfield_formula (producttoolfieldid,formulastring,columnstring,sequence)  select ', @producttoolfieldid,' ,''',@formula_letter_string,''',''',@formula_column_string,''',',' 3 from dual where not EXISTS(select 1 from ld_producttoolfield_formula where producttoolfieldid=',@producttoolfieldid,')');
PREPARE stmt FROM @formulsql;
EXECUTE stmt;
DEALLOCATE prepare stmt;
delimiter;


select tabid into @tabid from ld_tab where name='quotes';
select producttoolfieldid into @producttoolfieldid from ld_producttoolfield where tabid=@tabid and columnname='tax_amount';
select column_string into @column_string from tmp_taxformula;
select letter_string into @letter_string  from tmp_taxformula;
insert into ld_producttoolfield_formula (producttoolfieldid,formulastring,columnstring,sequence)
select @producttoolfieldid,'a*b*(1-c/100)','{formulavar:[{''lettervar'':''a'',''column'':''quantity''},{''lettervar'':''b'',''column'':''taxprice''},{''lettervar'':''c'',''column'':''discount_percent''}]}',4 from dual
where not EXISTS(select 1 from ld_producttoolfield_formula where producttoolfieldid=@producttoolfieldid);
delimiter;


call getTaxInfoForFormula(1);
select tabid into @tabid from ld_tab where name='quotes';
select producttoolfieldid into @producttoolfieldid from ld_producttoolfield where tabid=@tabid and columnname='tax_total';
select column_string into @column_string from tmp_taxformula;
select letter_string into @letter_string  from tmp_taxformula;

set @formula_column_string=concat('{formulavar:[{''''lettervar'''':''''a'''',''''column'''':''''list_amount''''},',@column_string,']}');
set @formula_letter_string=concat('a*((',@letter_string,')/100)');

set @formulsql=concat('insert into ld_producttoolfield_formula (producttoolfieldid,formulastring,columnstring,sequence)  select ', @producttoolfieldid,' ,''',@formula_letter_string,''',''',@formula_column_string,''',',' 5 from dual where not EXISTS(select 1 from ld_producttoolfield_formula where producttoolfieldid=',@producttoolfieldid,')');
PREPARE stmt FROM @formulsql;
EXECUTE stmt;
DEALLOCATE prepare stmt;
delimiter;
select tabid into @tabid from ld_tab where name='quotes';
select producttoolfieldid into @producttoolfieldid from ld_producttoolfield where tabid=@tabid and presence in(0,2) and  columnname='discount_amount' and tablename='ld_inventoryproductrel';
select column_string into @column_string from tmp_taxformula;
select letter_string into @letter_string  from tmp_taxformula;
insert into ld_producttoolfield_formula (producttoolfieldid,formulastring,columnstring,sequence)
select @producttoolfieldid,'a*b*(c/100)','{formulavar:[{''lettervar'':''a'',''column'':''quantity''},{''lettervar'':''b'',''column'':''taxprice''},{''lettervar'':''c'',''column'':''discount_percent''}]}',8 from dual
where not EXISTS(select 1 from ld_producttoolfield_formula where producttoolfieldid=@producttoolfieldid);
delimiter;



call getTaxInfoForFormula(1); 
delimiter;
select tabid into @tabid from ld_tab where name='invoice';
select producttoolfieldid into @producttoolfieldid from ld_producttoolfield where tabid=@tabid and columnname='taxprice';
select column_string into @column_string from tmp_taxformula;
select letter_string into @letter_string  from tmp_taxformula;
set @formula_column_string=concat('{formulavar:[{''''lettervar'''':''''a'''',''''column'''':''''listprice''''},',@column_string,']}');
set @formula_letter_string=concat('a*(1+(',@letter_string,')/100)');
set @formulsql=concat('insert into ld_producttoolfield_formula (producttoolfieldid,formulastring,columnstring,sequence)  select ', @producttoolfieldid,' ,''',@formula_letter_string,''',''',@formula_column_string,''',',' 1 from dual where not EXISTS(select 1 from ld_producttoolfield_formula where producttoolfieldid=',@producttoolfieldid,')');

PREPARE stmt FROM @formulsql;
EXECUTE stmt;
DEALLOCATE prepare stmt;
delimiter;
select tabid into @tabid from ld_tab where name='invoice';
select producttoolfieldid into @producttoolfieldid from ld_producttoolfield where tabid=@tabid and columnname='listprice';
select column_string into @column_string from tmp_taxformula;
select letter_string into @letter_string  from tmp_taxformula;
set @formula_column_string=concat('{formulavar:[{''''lettervar'''':''''a'''',''''column'''':''''taxprice''''},',@column_string,']}');
set @formula_letter_string=concat('a/(1+(',@letter_string,')/100)');
set @formulsql=concat('insert into ld_producttoolfield_formula (producttoolfieldid,formulastring,columnstring,sequence)  select ', @producttoolfieldid,' ,''',@formula_letter_string,''',''',@formula_column_string,''',',2,' from dual where not EXISTS(select 1 from ld_producttoolfield_formula where producttoolfieldid=',@producttoolfieldid,')');
PREPARE stmt FROM @formulsql;
EXECUTE stmt;
DEALLOCATE prepare stmt;
delimiter;


call getTaxInfoForFormula(1); 
select column_string into @column_string from tmp_taxformula;
select letter_string into @letter_string  from tmp_taxformula;
select nextletterstart into @nextletterstart from tmp_taxformula;
select tabid into @tabid from ld_tab where name='invoice';
SET @sqlletter = CONCAT('select letter into @quantity_letter from tmp_letter limit ',@nextletterstart,',1') ;
PREPARE stmt FROM @sqlletter;
EXECUTE stmt;
DEALLOCATE prepare stmt;

set @nextletterstart=@nextletterstart+1;
SET @sqlletter = CONCAT('select letter into @discount_percent from tmp_letter limit ',@nextletterstart,',1') ;
PREPARE stmt FROM @sqlletter;
EXECUTE stmt;
DEALLOCATE prepare stmt;

set @formula_column_string=concat('{formulavar:[{''''lettervar'''':''''a'''',''''column'''':''''taxprice''''},',@column_string,',{''''lettervar'''':''''',@quantity_letter,'''''',',''''column''''',':','''''quantity''''}',',{''''lettervar'''':''''',@discount_percent,'''''',',''''column''''',':','''''discount_percent''''}]}');
set @formula_letter_string=concat('(a/(1+(',@letter_string,')/100))*',@quantity_letter,'*(1-',@discount_percent,'/100)');

select producttoolfieldid into @producttoolfieldid from ld_producttoolfield where tabid=@tabid and columnname='list_amount';
set @formulsql=concat('insert into ld_producttoolfield_formula (producttoolfieldid,formulastring,columnstring,sequence)  select ', @producttoolfieldid,' ,''',@formula_letter_string,''',''',@formula_column_string,''',',' 3 from dual where not EXISTS(select 1 from ld_producttoolfield_formula where producttoolfieldid=',@producttoolfieldid,')');
PREPARE stmt FROM @formulsql;
EXECUTE stmt;
DEALLOCATE prepare stmt;
delimiter;


select tabid into @tabid from ld_tab where name='invoice';
select producttoolfieldid into @producttoolfieldid from ld_producttoolfield where tabid=@tabid and columnname='tax_amount';
select column_string into @column_string from tmp_taxformula;
select letter_string into @letter_string  from tmp_taxformula;
insert into ld_producttoolfield_formula (producttoolfieldid,formulastring,columnstring,sequence)
select @producttoolfieldid,'a*b*(1-c/100)','{formulavar:[{''lettervar'':''a'',''column'':''quantity''},{''lettervar'':''b'',''column'':''taxprice''},{''lettervar'':''c'',''column'':''discount_percent''}]}',4 from dual
where not EXISTS(select 1 from ld_producttoolfield_formula where producttoolfieldid=@producttoolfieldid);
delimiter;


call getTaxInfoForFormula(1);
select tabid into @tabid from ld_tab where name='invoice';
select producttoolfieldid into @producttoolfieldid from ld_producttoolfield where tabid=@tabid and columnname='tax_total';
select column_string into @column_string from tmp_taxformula;
select letter_string into @letter_string  from tmp_taxformula;

set @formula_column_string=concat('{formulavar:[{''''lettervar'''':''''a'''',''''column'''':''''list_amount''''},',@column_string,']}');
set @formula_letter_string=concat('a*((',@letter_string,')/100)');

set @formulsql=concat('insert into ld_producttoolfield_formula (producttoolfieldid,formulastring,columnstring,sequence)  select ', @producttoolfieldid,' ,''',@formula_letter_string,''',''',@formula_column_string,''',',' 5 from dual where not EXISTS(select 1 from ld_producttoolfield_formula where producttoolfieldid=',@producttoolfieldid,')');
PREPARE stmt FROM @formulsql;
EXECUTE stmt;
DEALLOCATE prepare stmt;
delimiter;

select tabid into @tabid from ld_tab where name='invoice';
select producttoolfieldid into @producttoolfieldid from ld_producttoolfield where tabid=@tabid and presence in(0,2) and  columnname='discount_amount' and tablename='ld_inventoryproductrel';
select column_string into @column_string from tmp_taxformula;
select letter_string into @letter_string  from tmp_taxformula;
insert into ld_producttoolfield_formula (producttoolfieldid,formulastring,columnstring,sequence)
select @producttoolfieldid,'a*b*(c/100)','{formulavar:[{''lettervar'':''a'',''column'':''quantity''},{''lettervar'':''b'',''column'':''taxprice''},{''lettervar'':''c'',''column'':''discount_percent''}]}',8 from dual
where not EXISTS(select 1 from ld_producttoolfield_formula where producttoolfieldid=@producttoolfieldid);
delimiter;


call getTaxInfoForFormula(1); 
delimiter;
select tabid into @tabid from ld_tab where name='purchaseorder';
select producttoolfieldid into @producttoolfieldid from ld_producttoolfield where tabid=@tabid and columnname='taxprice';
select column_string into @column_string from tmp_taxformula;
select letter_string into @letter_string  from tmp_taxformula;
set @formula_column_string=concat('{formulavar:[{''''lettervar'''':''''a'''',''''column'''':''''listprice''''},',@column_string,']}');
set @formula_letter_string=concat('a*(1+(',@letter_string,')/100)');
set @formulsql=concat('insert into ld_producttoolfield_formula (producttoolfieldid,formulastring,columnstring,sequence)  select ', @producttoolfieldid,' ,''',@formula_letter_string,''',''',@formula_column_string,''',',' 1 from dual where not EXISTS(select 1 from ld_producttoolfield_formula where producttoolfieldid=',@producttoolfieldid,')');

PREPARE stmt FROM @formulsql;
EXECUTE stmt;
DEALLOCATE prepare stmt;
delimiter;
select tabid into @tabid from ld_tab where name='purchaseorder';
select producttoolfieldid into @producttoolfieldid from ld_producttoolfield where tabid=@tabid and columnname='listprice';
select column_string into @column_string from tmp_taxformula;
select letter_string into @letter_string  from tmp_taxformula;
set @formula_column_string=concat('{formulavar:[{''''lettervar'''':''''a'''',''''column'''':''''taxprice''''},',@column_string,']}');
set @formula_letter_string=concat('a/(1+(',@letter_string,')/100)');
set @formulsql=concat('insert into ld_producttoolfield_formula (producttoolfieldid,formulastring,columnstring,sequence)  select ', @producttoolfieldid,' ,''',@formula_letter_string,''',''',@formula_column_string,''',',2,' from dual where not EXISTS(select 1 from ld_producttoolfield_formula where producttoolfieldid=',@producttoolfieldid,')');
PREPARE stmt FROM @formulsql;
EXECUTE stmt;
DEALLOCATE prepare stmt;
delimiter;


call getTaxInfoForFormula(1); 
select column_string into @column_string from tmp_taxformula;
select letter_string into @letter_string  from tmp_taxformula;
select nextletterstart into @nextletterstart from tmp_taxformula;
select tabid into @tabid from ld_tab where name='purchaseorder';
SET @sqlletter = CONCAT('select letter into @quantity_letter from tmp_letter limit ',@nextletterstart,',1') ;
PREPARE stmt FROM @sqlletter;
EXECUTE stmt;
DEALLOCATE prepare stmt;

set @nextletterstart=@nextletterstart+1;
SET @sqlletter = CONCAT('select letter into @discount_percent from tmp_letter limit ',@nextletterstart,',1') ;
PREPARE stmt FROM @sqlletter;
EXECUTE stmt;
DEALLOCATE prepare stmt;

set @formula_column_string=concat('{formulavar:[{''''lettervar'''':''''a'''',''''column'''':''''taxprice''''},',@column_string,',{''''lettervar'''':''''',@quantity_letter,'''''',',''''column''''',':','''''quantity''''}',',{''''lettervar'''':''''',@discount_percent,'''''',',''''column''''',':','''''discount_percent''''}]}');
set @formula_letter_string=concat('(a/(1+(',@letter_string,')/100))*',@quantity_letter,'*(1-',@discount_percent,'/100)');

select producttoolfieldid into @producttoolfieldid from ld_producttoolfield where tabid=@tabid and columnname='list_amount';
set @formulsql=concat('insert into ld_producttoolfield_formula (producttoolfieldid,formulastring,columnstring,sequence)  select ', @producttoolfieldid,' ,''',@formula_letter_string,''',''',@formula_column_string,''',',' 3 from dual where not EXISTS(select 1 from ld_producttoolfield_formula where producttoolfieldid=',@producttoolfieldid,')');
PREPARE stmt FROM @formulsql;
EXECUTE stmt;
DEALLOCATE prepare stmt;
delimiter;


select tabid into @tabid from ld_tab where name='purchaseorder';
select producttoolfieldid into @producttoolfieldid from ld_producttoolfield where tabid=@tabid and columnname='tax_amount';
select column_string into @column_string from tmp_taxformula;
select letter_string into @letter_string  from tmp_taxformula;
insert into ld_producttoolfield_formula (producttoolfieldid,formulastring,columnstring,sequence)
select @producttoolfieldid,'a*b*(1-c/100)','{formulavar:[{''lettervar'':''a'',''column'':''quantity''},{''lettervar'':''b'',''column'':''taxprice''},{''lettervar'':''c'',''column'':''discount_percent''}]}',4 from dual
where not EXISTS(select 1 from ld_producttoolfield_formula where producttoolfieldid=@producttoolfieldid);
delimiter;

call getTaxInfoForFormula(1);
select tabid into @tabid from ld_tab where name='purchaseorder';
select producttoolfieldid into @producttoolfieldid from ld_producttoolfield where tabid=@tabid and columnname='tax_total';
select column_string into @column_string from tmp_taxformula;
select letter_string into @letter_string  from tmp_taxformula;
set @formula_column_string=concat('{formulavar:[{''''lettervar'''':''''a'''',''''column'''':''''list_amount''''},',@column_string,']}');
set @formula_letter_string=concat('a*((',@letter_string,')/100)');
set @formulsql=concat('insert into ld_producttoolfield_formula (producttoolfieldid,formulastring,columnstring,sequence)  select ', @producttoolfieldid,' ,''',@formula_letter_string,''',''',@formula_column_string,''',',' 5 from dual where not EXISTS(select 1 from ld_producttoolfield_formula where producttoolfieldid=',@producttoolfieldid,')');
PREPARE stmt FROM @formulsql;
EXECUTE stmt;
DEALLOCATE prepare stmt;
delimiter;
select tabid into @tabid from ld_tab where name='purchaseorder';
select producttoolfieldid into @producttoolfieldid from ld_producttoolfield where tabid=@tabid and presence in(0,2) and  columnname='discount_amount' and tablename='ld_inventoryproductrel';
select column_string into @column_string from tmp_taxformula;
select letter_string into @letter_string  from tmp_taxformula;
insert into ld_producttoolfield_formula (producttoolfieldid,formulastring,columnstring,sequence)
select @producttoolfieldid,'a*b*(c/100)','{formulavar:[{''lettervar'':''a'',''column'':''quantity''},{''lettervar'':''b'',''column'':''taxprice''},{''lettervar'':''c'',''column'':''discount_percent''}]}',8 from dual
where not EXISTS(select 1 from ld_producttoolfield_formula where producttoolfieldid=@producttoolfieldid);
delimiter;

call getTaxInfoForFormula(1); 
select tabid into @tabid from ld_tab where name='purchaseback';
select producttoolfieldid into @producttoolfieldid from ld_producttoolfield where tabid=@tabid and columnname='taxprice';
select column_string into @column_string from tmp_taxformula;
select letter_string into @letter_string  from tmp_taxformula;
set @formula_column_string=concat('{formulavar:[{''''lettervar'''':''''a'''',''''column'''':''''listprice''''},',@column_string,']}');
set @formula_letter_string=concat('a*(1+(',@letter_string,')/100)');
set @formulsql=concat('insert into ld_producttoolfield_formula (producttoolfieldid,formulastring,columnstring,sequence)  select ', @producttoolfieldid,' ,''',@formula_letter_string,''',''',@formula_column_string,''',',' 1 from dual where not EXISTS(select 1 from ld_producttoolfield_formula where producttoolfieldid=',@producttoolfieldid,')');

PREPARE stmt FROM @formulsql;
EXECUTE stmt;
DEALLOCATE prepare stmt;
delimiter;
select tabid into @tabid from ld_tab where name='purchaseback';
select producttoolfieldid into @producttoolfieldid from ld_producttoolfield where tabid=@tabid and columnname='listprice';
select column_string into @column_string from tmp_taxformula;
select letter_string into @letter_string  from tmp_taxformula;
set @formula_column_string=concat('{formulavar:[{''''lettervar'''':''''a'''',''''column'''':''''taxprice''''},',@column_string,']}');
set @formula_letter_string=concat('a/(1+(',@letter_string,')/100)');
set @formulsql=concat('insert into ld_producttoolfield_formula (producttoolfieldid,formulastring,columnstring,sequence)  select ', @producttoolfieldid,' ,''',@formula_letter_string,''',''',@formula_column_string,''',',2,' from dual where not EXISTS(select 1 from ld_producttoolfield_formula where producttoolfieldid=',@producttoolfieldid,')');
PREPARE stmt FROM @formulsql;
EXECUTE stmt;
DEALLOCATE prepare stmt;
delimiter;


call getTaxInfoForFormula(1); 
select column_string into @column_string from tmp_taxformula;
select letter_string into @letter_string  from tmp_taxformula;
select nextletterstart into @nextletterstart from tmp_taxformula;
select tabid into @tabid from ld_tab where name='purchaseback';
SET @sqlletter = CONCAT('select letter into @quantity_letter from tmp_letter limit ',@nextletterstart,',1') ;
PREPARE stmt FROM @sqlletter;
EXECUTE stmt;
DEALLOCATE prepare stmt;

set @nextletterstart=@nextletterstart+1;
SET @sqlletter = CONCAT('select letter into @discount_percent from tmp_letter limit ',@nextletterstart,',1') ;
PREPARE stmt FROM @sqlletter;
EXECUTE stmt;
DEALLOCATE prepare stmt;
set @formula_column_string=concat('{formulavar:[{''''lettervar'''':''''a'''',''''column'''':''''taxprice''''},',@column_string,',{''''lettervar'''':''''',@quantity_letter,'''''',',''''column''''',':','''''quantity''''}',',{''''lettervar'''':''''',@discount_percent,'''''',',''''column''''',':','''''discount_percent''''}]}');
set @formula_letter_string=concat('(a/(1+(',@letter_string,')/100))*',@quantity_letter,'*(1-',@discount_percent,'/100)');
select producttoolfieldid into @producttoolfieldid from ld_producttoolfield where tabid=@tabid and columnname='list_amount';
set @formulsql=concat('insert into ld_producttoolfield_formula (producttoolfieldid,formulastring,columnstring,sequence)  select ', @producttoolfieldid,' ,''',@formula_letter_string,''',''',@formula_column_string,''',',' 3 from dual where not EXISTS(select 1 from ld_producttoolfield_formula where producttoolfieldid=',@producttoolfieldid,')');
PREPARE stmt FROM @formulsql;
EXECUTE stmt;
DEALLOCATE prepare stmt;
delimiter;


select tabid into @tabid from ld_tab where name='purchaseback';
select producttoolfieldid into @producttoolfieldid from ld_producttoolfield where tabid=@tabid and columnname='tax_amount';
select column_string into @column_string from tmp_taxformula;
select letter_string into @letter_string  from tmp_taxformula;
insert into ld_producttoolfield_formula (producttoolfieldid,formulastring,columnstring,sequence)
select @producttoolfieldid,'a*b*(1-c/100)','{formulavar:[{''lettervar'':''a'',''column'':''quantity''},{''lettervar'':''b'',''column'':''taxprice''},{''lettervar'':''c'',''column'':''discount_percent''}]}',4 from dual
where not EXISTS(select 1 from ld_producttoolfield_formula where producttoolfieldid=@producttoolfieldid);
delimiter;

call getTaxInfoForFormula(1);
select tabid into @tabid from ld_tab where name='purchaseback';
select producttoolfieldid into @producttoolfieldid from ld_producttoolfield where tabid=@tabid and columnname='tax_total';
select column_string into @column_string from tmp_taxformula;
select letter_string into @letter_string  from tmp_taxformula;
set @formula_column_string=concat('{formulavar:[{''''lettervar'''':''''a'''',''''column'''':''''list_amount''''},',@column_string,']}');
set @formula_letter_string=concat('a*((',@letter_string,')/100)');
set @formulsql=concat('insert into ld_producttoolfield_formula (producttoolfieldid,formulastring,columnstring,sequence)  select ', @producttoolfieldid,' ,''',@formula_letter_string,''',''',@formula_column_string,''',',' 5 from dual where not EXISTS(select 1 from ld_producttoolfield_formula where producttoolfieldid=',@producttoolfieldid,')');
PREPARE stmt FROM @formulsql;
EXECUTE stmt;
DEALLOCATE prepare stmt;
delimiter;
select tabid into @tabid from ld_tab where name='purchaseback';
select producttoolfieldid into @producttoolfieldid from ld_producttoolfield where tabid=@tabid and presence in(0,2) and  columnname='discount_amount' and tablename='ld_inventoryproductrel';
select column_string into @column_string from tmp_taxformula;
select letter_string into @letter_string  from tmp_taxformula;
insert into ld_producttoolfield_formula (producttoolfieldid,formulastring,columnstring,sequence)
select @producttoolfieldid,'a*b*(c/100)','{formulavar:[{''lettervar'':''a'',''column'':''quantity''},{''lettervar'':''b'',''column'':''taxprice''},{''lettervar'':''c'',''column'':''discount_percent''}]}',8 from dual
where not EXISTS(select 1 from ld_producttoolfield_formula where producttoolfieldid=@producttoolfieldid);
delimiter;

call getTaxInfoForFormula(1); 
select tabid into @tabid from ld_tab where name='salesback';
select producttoolfieldid into @producttoolfieldid from ld_producttoolfield where tabid=@tabid and columnname='taxprice';
select column_string into @column_string from tmp_taxformula;
select letter_string into @letter_string  from tmp_taxformula;
set @formula_column_string=concat('{formulavar:[{''''lettervar'''':''''a'''',''''column'''':''''listprice''''},',@column_string,']}');
set @formula_letter_string=concat('a*(1+(',@letter_string,')/100)');
set @formulsql=concat('insert into ld_producttoolfield_formula (producttoolfieldid,formulastring,columnstring,sequence)  select ', @producttoolfieldid,' ,''',@formula_letter_string,''',''',@formula_column_string,''',',' 1 from dual where not EXISTS(select 1 from ld_producttoolfield_formula where producttoolfieldid=',@producttoolfieldid,')');

PREPARE stmt FROM @formulsql;
EXECUTE stmt;
DEALLOCATE prepare stmt;
delimiter;
select tabid into @tabid from ld_tab where name='salesback';
select producttoolfieldid into @producttoolfieldid from ld_producttoolfield where tabid=@tabid and columnname='listprice';
select column_string into @column_string from tmp_taxformula;
select letter_string into @letter_string  from tmp_taxformula;
set @formula_column_string=concat('{formulavar:[{''''lettervar'''':''''a'''',''''column'''':''''taxprice''''},',@column_string,']}');
set @formula_letter_string=concat('a/(1+(',@letter_string,')/100)');
set @formulsql=concat('insert into ld_producttoolfield_formula (producttoolfieldid,formulastring,columnstring,sequence)  select ', @producttoolfieldid,' ,''',@formula_letter_string,''',''',@formula_column_string,''',',2,' from dual where not EXISTS(select 1 from ld_producttoolfield_formula where producttoolfieldid=',@producttoolfieldid,')');
PREPARE stmt FROM @formulsql;
EXECUTE stmt;
DEALLOCATE prepare stmt;
delimiter;


call getTaxInfoForFormula(1); 
select column_string into @column_string from tmp_taxformula;
select letter_string into @letter_string  from tmp_taxformula;
select nextletterstart into @nextletterstart from tmp_taxformula;
select tabid into @tabid from ld_tab where name='salesback';
SET @sqlletter = CONCAT('select letter into @quantity_letter from tmp_letter limit ',@nextletterstart,',1') ;
PREPARE stmt FROM @sqlletter;
EXECUTE stmt;
DEALLOCATE prepare stmt;

set @nextletterstart=@nextletterstart+1;
SET @sqlletter = CONCAT('select letter into @discount_percent from tmp_letter limit ',@nextletterstart,',1') ;
PREPARE stmt FROM @sqlletter;
EXECUTE stmt;
DEALLOCATE prepare stmt;
set @formula_column_string=concat('{formulavar:[{''''lettervar'''':''''a'''',''''column'''':''''taxprice''''},',@column_string,',{''''lettervar'''':''''',@quantity_letter,'''''',',''''column''''',':','''''quantity''''}',',{''''lettervar'''':''''',@discount_percent,'''''',',''''column''''',':','''''discount_percent''''}]}');
set @formula_letter_string=concat('(a/(1+(',@letter_string,')/100))*',@quantity_letter,'*(1-',@discount_percent,'/100)');
select producttoolfieldid into @producttoolfieldid from ld_producttoolfield where tabid=@tabid and columnname='list_amount';
set @formulsql=concat('insert into ld_producttoolfield_formula (producttoolfieldid,formulastring,columnstring,sequence)  select ', @producttoolfieldid,' ,''',@formula_letter_string,''',''',@formula_column_string,''',',' 3 from dual where not EXISTS(select 1 from ld_producttoolfield_formula where producttoolfieldid=',@producttoolfieldid,')');
PREPARE stmt FROM @formulsql;
EXECUTE stmt;
DEALLOCATE prepare stmt;
delimiter;


select tabid into @tabid from ld_tab where name='salesback';
select producttoolfieldid into @producttoolfieldid from ld_producttoolfield where tabid=@tabid and columnname='tax_amount';
select column_string into @column_string from tmp_taxformula;
select letter_string into @letter_string  from tmp_taxformula;
insert into ld_producttoolfield_formula (producttoolfieldid,formulastring,columnstring,sequence)
select @producttoolfieldid,'a*b*(1-c/100)','{formulavar:[{''lettervar'':''a'',''column'':''quantity''},{''lettervar'':''b'',''column'':''taxprice''},{''lettervar'':''c'',''column'':''discount_percent''}]}',4 from dual where not EXISTS(select 1 from ld_producttoolfield_formula where producttoolfieldid=@producttoolfieldid);
delimiter;

call getTaxInfoForFormula(1);
select tabid into @tabid from ld_tab where name='salesback';
select producttoolfieldid into @producttoolfieldid from ld_producttoolfield where tabid=@tabid and columnname='tax_total';
select column_string into @column_string from tmp_taxformula;
select letter_string into @letter_string  from tmp_taxformula;
set @formula_column_string=concat('{formulavar:[{''''lettervar'''':''''a'''',''''column'''':''''list_amount''''},',@column_string,']}');
set @formula_letter_string=concat('a*((',@letter_string,')/100)');
set @formulsql=concat('insert into ld_producttoolfield_formula (producttoolfieldid,formulastring,columnstring,sequence)  select ', @producttoolfieldid,' ,''',@formula_letter_string,''',''',@formula_column_string,''',',' 5 from dual where not EXISTS(select 1 from ld_producttoolfield_formula where producttoolfieldid=',@producttoolfieldid,')');
PREPARE stmt FROM @formulsql;
EXECUTE stmt;
DEALLOCATE prepare stmt;
delimiter;

select tabid into @tabid from ld_tab where name='salesback';
select producttoolfieldid into @producttoolfieldid from ld_producttoolfield where tabid=@tabid and presence in(0,2) and  columnname='discount_amount' and tablename='ld_inventoryproductrel';
select column_string into @column_string from tmp_taxformula;
select letter_string into @letter_string  from tmp_taxformula;
insert into ld_producttoolfield_formula (producttoolfieldid,formulastring,columnstring,sequence)
select @producttoolfieldid,'a*b*(c/100)','{formulavar:[{''lettervar'':''a'',''column'':''quantity''},{''lettervar'':''b'',''column'':''taxprice''},{''lettervar'':''c'',''column'':''discount_percent''}]}',8 from dual
where not EXISTS(select 1 from ld_producttoolfield_formula where producttoolfieldid=@producttoolfieldid);
delimiter;

call getTaxInfoForFormula(1); 
select tabid into @tabid from ld_tab where name='outboundorder';
select producttoolfieldid into @producttoolfieldid from ld_producttoolfield where tabid=@tabid and columnname='taxprice';
select column_string into @column_string from tmp_taxformula;
select letter_string into @letter_string  from tmp_taxformula;
set @formula_column_string=concat('{formulavar:[{''''lettervar'''':''''a'''',''''column'''':''''listprice''''},',@column_string,']}');
set @formula_letter_string=concat('a*(1+(',@letter_string,')/100)');
set @formulsql=concat('insert into ld_producttoolfield_formula (producttoolfieldid,formulastring,columnstring,sequence)  select ', @producttoolfieldid,' ,''',@formula_letter_string,''',''',@formula_column_string,''',',' 1 from dual where not EXISTS(select 1 from ld_producttoolfield_formula where producttoolfieldid=',@producttoolfieldid,')');

PREPARE stmt FROM @formulsql;
EXECUTE stmt;
DEALLOCATE prepare stmt;
delimiter;
select tabid into @tabid from ld_tab where name='outboundorder';
select producttoolfieldid into @producttoolfieldid from ld_producttoolfield where tabid=@tabid and columnname='listprice';
select column_string into @column_string from tmp_taxformula;
select letter_string into @letter_string  from tmp_taxformula;
set @formula_column_string=concat('{formulavar:[{''''lettervar'''':''''a'''',''''column'''':''''taxprice''''},',@column_string,']}');
set @formula_letter_string=concat('a/(1+(',@letter_string,')/100)');
set @formulsql=concat('insert into ld_producttoolfield_formula (producttoolfieldid,formulastring,columnstring,sequence)  select ', @producttoolfieldid,' ,''',@formula_letter_string,''',''',@formula_column_string,''',',2,' from dual where not EXISTS(select 1 from ld_producttoolfield_formula where producttoolfieldid=',@producttoolfieldid,')');
PREPARE stmt FROM @formulsql;
EXECUTE stmt;
DEALLOCATE prepare stmt;
delimiter;


call getTaxInfoForFormula(1); 
select column_string into @column_string from tmp_taxformula;
select letter_string into @letter_string  from tmp_taxformula;
select nextletterstart into @nextletterstart from tmp_taxformula;
select tabid into @tabid from ld_tab where name='outboundorder';
SET @sqlletter = CONCAT('select letter into @quantity_letter from tmp_letter limit ',@nextletterstart,',1') ;
PREPARE stmt FROM @sqlletter;
EXECUTE stmt;
DEALLOCATE prepare stmt;

set @nextletterstart=@nextletterstart+1;
SET @sqlletter = CONCAT('select letter into @discount_percent from tmp_letter limit ',@nextletterstart,',1') ;
PREPARE stmt FROM @sqlletter;
EXECUTE stmt;
DEALLOCATE prepare stmt;
set @formula_column_string=concat('{formulavar:[{''''lettervar'''':''''a'''',''''column'''':''''taxprice''''},',@column_string,',{''''lettervar'''':''''',@quantity_letter,'''''',',''''column''''',':','''''quantity''''}',',{''''lettervar'''':''''',@discount_percent,'''''',',''''column''''',':','''''discount_percent''''}]}');
set @formula_letter_string=concat('(a/(1+(',@letter_string,')/100))*',@quantity_letter,'*(1-',@discount_percent,'/100)');
select producttoolfieldid into @producttoolfieldid from ld_producttoolfield where tabid=@tabid and columnname='list_amount';
set @formulsql=concat('insert into ld_producttoolfield_formula (producttoolfieldid,formulastring,columnstring,sequence)  select ', @producttoolfieldid,' ,''',@formula_letter_string,''',''',@formula_column_string,''',',' 3 from dual where not EXISTS(select 1 from ld_producttoolfield_formula where producttoolfieldid=',@producttoolfieldid,')');
PREPARE stmt FROM @formulsql;
EXECUTE stmt;
DEALLOCATE prepare stmt;
delimiter;


select tabid into @tabid from ld_tab where name='outboundorder';
select producttoolfieldid into @producttoolfieldid from ld_producttoolfield where tabid=@tabid and columnname='tax_amount';
select column_string into @column_string from tmp_taxformula;
select letter_string into @letter_string  from tmp_taxformula;
insert into ld_producttoolfield_formula (producttoolfieldid,formulastring,columnstring,sequence)
select @producttoolfieldid,'a*b*(1-c/100)','{formulavar:[{''lettervar'':''a'',''column'':''quantity''},{''lettervar'':''b'',''column'':''taxprice''},{''lettervar'':''c'',''column'':''discount_percent''}]}',4 from dual
where not EXISTS(select 1 from ld_producttoolfield_formula where producttoolfieldid=@producttoolfieldid);
delimiter;

call getTaxInfoForFormula(1);
select tabid into @tabid from ld_tab where name='outboundorder';
select producttoolfieldid into @producttoolfieldid from ld_producttoolfield where tabid=@tabid and columnname='tax_total';
select column_string into @column_string from tmp_taxformula;
select letter_string into @letter_string  from tmp_taxformula;
set @formula_column_string=concat('{formulavar:[{''''lettervar'''':''''a'''',''''column'''':''''list_amount''''},',@column_string,']}');
set @formula_letter_string=concat('a*((',@letter_string,')/100)');
set @formulsql=concat('insert into ld_producttoolfield_formula (producttoolfieldid,formulastring,columnstring,sequence)  select ', @producttoolfieldid,' ,''',@formula_letter_string,''',''',@formula_column_string,''',',' 5 from dual where not EXISTS(select 1 from ld_producttoolfield_formula where producttoolfieldid=',@producttoolfieldid,')');
PREPARE stmt FROM @formulsql;
EXECUTE stmt;
DEALLOCATE prepare stmt;
delimiter;

select tabid into @tabid from ld_tab where name='outboundorder';
select producttoolfieldid into @producttoolfieldid from ld_producttoolfield where tabid=@tabid and presence in(0,2) and  columnname='discount_amount' and tablename='ld_inventoryproductrel';
select column_string into @column_string from tmp_taxformula;
select letter_string into @letter_string  from tmp_taxformula;
insert into ld_producttoolfield_formula (producttoolfieldid,formulastring,columnstring,sequence)
select @producttoolfieldid,'a*b*(c/100)','{formulavar:[{''lettervar'':''a'',''column'':''quantity''},{''lettervar'':''b'',''column'':''taxprice''},{''lettervar'':''c'',''column'':''discount_percent''}]}',8 from dual
where not EXISTS(select 1 from ld_producttoolfield_formula where producttoolfieldid=@producttoolfieldid);
delimiter;

call getTaxInfoForFormula(1); 
select tabid into @tabid from ld_tab where name='stock';
select producttoolfieldid into @producttoolfieldid from ld_producttoolfield where tabid=@tabid and columnname='taxprice';
select column_string into @column_string from tmp_taxformula;
select letter_string into @letter_string  from tmp_taxformula;
set @formula_column_string=concat('{formulavar:[{''''lettervar'''':''''a'''',''''column'''':''''listprice''''},',@column_string,']}');
set @formula_letter_string=concat('a*(1+(',@letter_string,')/100)');
set @formulsql=concat('insert into ld_producttoolfield_formula (producttoolfieldid,formulastring,columnstring,sequence)  select ', @producttoolfieldid,' ,''',@formula_letter_string,''',''',@formula_column_string,''',',' 1 from dual where not EXISTS(select 1 from ld_producttoolfield_formula where producttoolfieldid=',@producttoolfieldid,')');

PREPARE stmt FROM @formulsql;
EXECUTE stmt;
DEALLOCATE prepare stmt;
delimiter;
select tabid into @tabid from ld_tab where name='stock';
select producttoolfieldid into @producttoolfieldid from ld_producttoolfield where tabid=@tabid and columnname='listprice';
select column_string into @column_string from tmp_taxformula;
select letter_string into @letter_string  from tmp_taxformula;
set @formula_column_string=concat('{formulavar:[{''''lettervar'''':''''a'''',''''column'''':''''taxprice''''},',@column_string,']}');
set @formula_letter_string=concat('a/(1+(',@letter_string,')/100)');
set @formulsql=concat('insert into ld_producttoolfield_formula (producttoolfieldid,formulastring,columnstring,sequence)  select ', @producttoolfieldid,' ,''',@formula_letter_string,''',''',@formula_column_string,''',',2,' from dual where not EXISTS(select 1 from ld_producttoolfield_formula where producttoolfieldid=',@producttoolfieldid,')');
PREPARE stmt FROM @formulsql;
EXECUTE stmt;
DEALLOCATE prepare stmt;
delimiter;


call getTaxInfoForFormula(1); 
select column_string into @column_string from tmp_taxformula;
select letter_string into @letter_string  from tmp_taxformula;
select nextletterstart into @nextletterstart from tmp_taxformula;
select tabid into @tabid from ld_tab where name='stock';
SET @sqlletter = CONCAT('select letter into @quantity_letter from tmp_letter limit ',@nextletterstart,',1') ;
PREPARE stmt FROM @sqlletter;
EXECUTE stmt;
DEALLOCATE prepare stmt;

set @nextletterstart=@nextletterstart+1;
SET @sqlletter = CONCAT('select letter into @discount_percent from tmp_letter limit ',@nextletterstart,',1') ;
PREPARE stmt FROM @sqlletter;
EXECUTE stmt;
DEALLOCATE prepare stmt;
set @formula_column_string=concat('{formulavar:[{''''lettervar'''':''''a'''',''''column'''':''''taxprice''''},',@column_string,',{''''lettervar'''':''''',@quantity_letter,'''''',',''''column''''',':','''''quantity''''}',',{''''lettervar'''':''''',@discount_percent,'''''',',''''column''''',':','''''discount_percent''''}]}');
set @formula_letter_string=concat('(a/(1+(',@letter_string,')/100))*',@quantity_letter,'*(1-',@discount_percent,'/100)');
select producttoolfieldid into @producttoolfieldid from ld_producttoolfield where tabid=@tabid and columnname='list_amount';
set @formulsql=concat('insert into ld_producttoolfield_formula (producttoolfieldid,formulastring,columnstring,sequence)  select ', @producttoolfieldid,' ,''',@formula_letter_string,''',''',@formula_column_string,''',',' 3 from dual where not EXISTS(select 1 from ld_producttoolfield_formula where producttoolfieldid=',@producttoolfieldid,')');
PREPARE stmt FROM @formulsql;
EXECUTE stmt;
DEALLOCATE prepare stmt;
delimiter;


select tabid into @tabid from ld_tab where name='stock';
select producttoolfieldid into @producttoolfieldid from ld_producttoolfield where tabid=@tabid and columnname='tax_amount';
select column_string into @column_string from tmp_taxformula;
select letter_string into @letter_string  from tmp_taxformula;
insert into ld_producttoolfield_formula (producttoolfieldid,formulastring,columnstring,sequence)
 select @producttoolfieldid,'a*b*(1-c/100)','{formulavar:[{''lettervar'':''a'',''column'':''quantity''},{''lettervar'':''b'',''column'':''taxprice''},{''lettervar'':''c'',''column'':''discount_percent''}]}',4 from dual
 where not EXISTS(select 1 from ld_producttoolfield_formula where producttoolfieldid=@producttoolfieldid);
delimiter;

call getTaxInfoForFormula(1);
select tabid into @tabid from ld_tab where name='stock';
select producttoolfieldid into @producttoolfieldid from ld_producttoolfield where tabid=@tabid and columnname='tax_total';
select column_string into @column_string from tmp_taxformula;
select letter_string into @letter_string  from tmp_taxformula;
set @formula_column_string=concat('{formulavar:[{''''lettervar'''':''''a'''',''''column'''':''''list_amount''''},',@column_string,']}');
set @formula_letter_string=concat('a*((',@letter_string,')/100)');
set @formulsql=concat('insert into ld_producttoolfield_formula (producttoolfieldid,formulastring,columnstring,sequence)  select ', @producttoolfieldid,' ,''',@formula_letter_string,''',''',@formula_column_string,''',',' 5 from dual where not EXISTS(select 1 from ld_producttoolfield_formula where producttoolfieldid=',@producttoolfieldid,')');
PREPARE stmt FROM @formulsql;
EXECUTE stmt;
DEALLOCATE prepare stmt;
delimiter;
select tabid into @tabid from ld_tab where name='stock';
select producttoolfieldid into @producttoolfieldid from ld_producttoolfield where tabid=@tabid and presence in(0,2) and  columnname='discount_amount' and tablename='ld_inventoryproductrel';
select column_string into @column_string from tmp_taxformula;
select letter_string into @letter_string  from tmp_taxformula;
insert into ld_producttoolfield_formula (producttoolfieldid,formulastring,columnstring,sequence)
select @producttoolfieldid,'a*b*(c/100)','{formulavar:[{''lettervar'':''a'',''column'':''quantity''},{''lettervar'':''b'',''column'':''taxprice''},{''lettervar'':''c'',''column'':''discount_percent''}]}',8 from dual
where not EXISTS(select 1 from ld_producttoolfield_formula where producttoolfieldid=@producttoolfieldid);
delimiter;


call getTaxInfoForFormula(1); 
select tabid into @tabid from ld_tab where name='servicecontracts';
select producttoolfieldid into @producttoolfieldid from ld_producttoolfield where tabid=@tabid and columnname='taxprice';
select column_string into @column_string from tmp_taxformula;
select letter_string into @letter_string  from tmp_taxformula;
set @formula_column_string=concat('{formulavar:[{''''lettervar'''':''''a'''',''''column'''':''''listprice''''},',@column_string,']}');
set @formula_letter_string=concat('a*(1+(',@letter_string,')/100)');
set @formulsql=concat('insert into ld_producttoolfield_formula (producttoolfieldid,formulastring,columnstring,sequence)  select ', @producttoolfieldid,' ,''',@formula_letter_string,''',''',@formula_column_string,''',',' 1 from dual where not EXISTS(select 1 from ld_producttoolfield_formula where producttoolfieldid=',@producttoolfieldid,')');

PREPARE stmt FROM @formulsql;
EXECUTE stmt;
DEALLOCATE prepare stmt;
delimiter;
select tabid into @tabid from ld_tab where name='servicecontracts';
select producttoolfieldid into @producttoolfieldid from ld_producttoolfield where tabid=@tabid and columnname='listprice';
select column_string into @column_string from tmp_taxformula;
select letter_string into @letter_string  from tmp_taxformula;
set @formula_column_string=concat('{formulavar:[{''''lettervar'''':''''a'''',''''column'''':''''taxprice''''},',@column_string,']}');
set @formula_letter_string=concat('a/(1+(',@letter_string,')/100)');
set @formulsql=concat('insert into ld_producttoolfield_formula (producttoolfieldid,formulastring,columnstring,sequence)  select ', @producttoolfieldid,' ,''',@formula_letter_string,''',''',@formula_column_string,''',',2,' from dual where not EXISTS(select 1 from ld_producttoolfield_formula where producttoolfieldid=',@producttoolfieldid,')');
PREPARE stmt FROM @formulsql;
EXECUTE stmt;
DEALLOCATE prepare stmt;
delimiter;


call getTaxInfoForFormula(1); 
select column_string into @column_string from tmp_taxformula;
select letter_string into @letter_string  from tmp_taxformula;
select nextletterstart into @nextletterstart from tmp_taxformula;
select tabid into @tabid from ld_tab where name='servicecontracts';
SET @sqlletter = CONCAT('select letter into @quantity_letter from tmp_letter limit ',@nextletterstart,',1') ;
PREPARE stmt FROM @sqlletter;
EXECUTE stmt;
DEALLOCATE prepare stmt;

set @nextletterstart=@nextletterstart+1;
SET @sqlletter = CONCAT('select letter into @discount_percent from tmp_letter limit ',@nextletterstart,',1') ;
PREPARE stmt FROM @sqlletter;
EXECUTE stmt;
DEALLOCATE prepare stmt;
set @formula_column_string=concat('{formulavar:[{''''lettervar'''':''''a'''',''''column'''':''''taxprice''''},',@column_string,',{''''lettervar'''':''''',@quantity_letter,'''''',',''''column''''',':','''''quantity''''}',',{''''lettervar'''':''''',@discount_percent,'''''',',''''column''''',':','''''discount_percent''''}]}');
set @formula_letter_string=concat('(a/(1+(',@letter_string,')/100))*',@quantity_letter,'*(1-',@discount_percent,'/100)');
select producttoolfieldid into @producttoolfieldid from ld_producttoolfield where tabid=@tabid and columnname='list_amount';
set @formulsql=concat('insert into ld_producttoolfield_formula (producttoolfieldid,formulastring,columnstring,sequence)  select ', @producttoolfieldid,' ,''',@formula_letter_string,''',''',@formula_column_string,''',',' 3 from dual where not EXISTS(select 1 from ld_producttoolfield_formula where producttoolfieldid=',@producttoolfieldid,')');
PREPARE stmt FROM @formulsql;
EXECUTE stmt;
DEALLOCATE prepare stmt;
delimiter;


select tabid into @tabid from ld_tab where name='servicecontracts';
select producttoolfieldid into @producttoolfieldid from ld_producttoolfield where tabid=@tabid and columnname='tax_amount';
select column_string into @column_string from tmp_taxformula;
select letter_string into @letter_string  from tmp_taxformula;
insert into ld_producttoolfield_formula (producttoolfieldid,formulastring,columnstring,sequence)
select @producttoolfieldid,'a*b*(1-c/100)','{formulavar:[{''lettervar'':''a'',''column'':''quantity''},{''lettervar'':''b'',''column'':''taxprice''},{''lettervar'':''c'',''column'':''discount_percent''}]}',4 from dual
where not EXISTS(select 1 from ld_producttoolfield_formula where producttoolfieldid=@producttoolfieldid);
delimiter;

call getTaxInfoForFormula(1);
select tabid into @tabid from ld_tab where name='servicecontracts';
select producttoolfieldid into @producttoolfieldid from ld_producttoolfield where tabid=@tabid and columnname='tax_total';
select column_string into @column_string from tmp_taxformula;
select letter_string into @letter_string  from tmp_taxformula;
set @formula_column_string=concat('{formulavar:[{''''lettervar'''':''''a'''',''''column'''':''''list_amount''''},',@column_string,']}');
set @formula_letter_string=concat('a*((',@letter_string,')/100)');
set @formulsql=concat('insert into ld_producttoolfield_formula (producttoolfieldid,formulastring,columnstring,sequence)  select ', @producttoolfieldid,' ,''',@formula_letter_string,''',''',@formula_column_string,''',',' 5 from dual where not EXISTS(select 1 from ld_producttoolfield_formula where producttoolfieldid=',@producttoolfieldid,')');
PREPARE stmt FROM @formulsql;
EXECUTE stmt;
DEALLOCATE prepare stmt;
delimiter;
select tabid into @tabid from ld_tab where name='servicecontracts';
select producttoolfieldid into @producttoolfieldid from ld_producttoolfield where tabid=@tabid and presence in(0,2) and  columnname='discount_amount' and tablename='ld_inventoryproductrel';
select column_string into @column_string from tmp_taxformula;
select letter_string into @letter_string  from tmp_taxformula;
insert into ld_producttoolfield_formula (producttoolfieldid,formulastring,columnstring,sequence)
select @producttoolfieldid,'a*b*(c/100)','{formulavar:[{''lettervar'':''a'',''column'':''quantity''},{''lettervar'':''b'',''column'':''taxprice''},{''lettervar'':''c'',''column'':''discount_percent''}]}',8 from dual
where not EXISTS(select 1 from ld_producttoolfield_formula where producttoolfieldid=@producttoolfieldid);
delimiter;

call AddColumn('ld_singin','distince','int',10,0);
delimiter;

update ld_desk set fieldlabel='是否可编辑' where labelbol='DOYOUNEEDTOEDIT' and languagetype='zh' and Labeltype='fixedstr';
update ld_producttoolfield set defaultcolumn=2 where columnname in ('productname','quantity','taxprice','tax_amount','total');
update ld_producttoolfield set defaultcolumn=3 where columnname in ('listprice','list_amount','taxprice','tax_amount','total','productcost','grossprofit');
update ld_producttoolfield set defaultcolumn=3 where columnname in ('servicecontracts_start_date','servicecontracts_end_date','rmb_taxprice','rmb_taxamount');
update ld_producttoolfield set defaultcolumn=3 where columnname in ('rmbprice','discount_percent','eur_price','discount_amount','tax_total');
update ld_producttoolfield set defaultcolumn=3 where columnname in ('discount_percent','discount_amount','tax_rate','subtotal','adjustment');
update ld_producttoolfield set defaultcolumn=3 where columnname in ('entitytype','paperquantity','firmoffer','profitloss');
update ld_producttoolfield set defaultcolumn=3 where columnname in (select taxname from ld_inventorytaxinfo);
update ld_producttoolfield set defaultcolumn=4 where columnname in ('usageunit','productsheet','product_no');

select tabid into @tabid from ld_tab where name='Productbom';
delete from ld_producttoolfield where tabid=@tabid and columnname ='';

select tabid into @tabid from ld_tab where name='Productbom';
select producttoolfieldid into @producttoolfieldid from ld_producttoolfield where tabid=@tabid and columnname='tax_amount';

insert into ld_producttoolfield_formula (producttoolfieldid,formulastring,columnstring,sequence)
select @producttoolfieldid,'a*b','{formulavar:[{''lettervar'':''a'',''column'':''quantity''},{''lettervar'':''b'',''column'':''taxprice''}]}',0 from dual
where not EXISTS(select 1 from ld_producttoolfield_formula where producttoolfieldid=@producttoolfieldid);
delimiter;

select max(tabid) into @tabid from ld_tab;
insert into ld_tab(tabid,name,presence,tabsequence,tablabel,customized,ownedby,isentitytype,parent,printtab)
select @tabid+1,'mobileQuotes',1,50,'mobileQuotes',0,0,1,'Finacial',1 from dual where not exists(select 1 from ld_tab where name='mobileQuotes');
select MAX(cvid) into @maxid  from ld_customview;
update ld_customview_seq set id=@maxid+1 where not EXISTS(select 1 from ld_customview where viewname='mobileQuotes' and entitytype='mobileQuotes');
insert into ld_customview(cvid,viewname,setdefault,setmetrics,entitytype,status,userid,sequence,pagewidthpercent)select @maxid+1,'mobileQuotes',0,0,'mobileQuotes',0,1,1,100 
from dual where not EXISTS(select 1 from ld_customview where viewname='mobileQuotes' and entitytype='mobileQuotes');

select cvid into @cvid from ld_customview where viewname='mobileQuotes' and entitytype='mobileQuotes';
delete from ld_cvcolumnlist where cvid=@cvid;
insert into ld_cvcolumnlist (cvid,columnindex,columnname) values(@cvid,0,'ld_quotes:quote_no:quote_no:Quotes_编号:V' );
insert into ld_cvcolumnlist (cvid,columnindex,columnname) values(@cvid,1,'ld_quotes:accountid:account_id:Quotes_客户:I' );
insert into ld_cvcolumnlist (cvid,columnindex,columnname) values(@cvid,2,'ld_quotes:subtotal:hdnSubTotal:Quotes_合计:N' );
insert into ld_cvcolumnlist (cvid,columnindex,columnname) values(@cvid,3,'ld_quotes:createdtime:createdtime:Quotes_创建日期:D' );
delimiter;

update ld_field set presence=0 where tabid = (select tabid from ld_tab where name = 'Quotes') and fieldname = 'hdnSubTotal';
delimiter;

select cvid into @cvid  from ld_customview where viewname='mobileServiceContracts' and entitytype='mobileServiceContracts';
delete from ld_cvcolumnlist where cvid=@cvid;
insert into ld_cvcolumnlist (cvid,columnindex,columnname) values(@cvid,0,'ld_servicecontracts:contract_no:contract_no:ServiceContracts_编号:V' );
insert into ld_cvcolumnlist (cvid,columnindex,columnname) values(@cvid,1,'ld_servicecontracts:accountid:account_id:ServiceContracts_客户:I' );
insert into ld_cvcolumnlist (cvid,columnindex,columnname) values(@cvid,2,'ld_servicecontracts:total:hdnGrandTotal:ServiceContracts_合计:N' );
insert into ld_cvcolumnlist (cvid,columnindex,columnname) values(@cvid,3,'ld_servicecontracts:due_date:due_date:ServiceContracts_签约日期:D' );
delimiter;

ALTER TABLE ld_producttoolfield MODIFY COLUMN width int(4) default 0;
delimiter;
-- 2015--07-01

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'zh','Dividend','派息表','fixedstr' from dual where not EXISTS(select 1 from ld_desk where languagetype='zh' and labelbol='Dividend' and Labeltype='fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'en','Dividend','Dividend','fixedstr' from dual where not EXISTS(select 1 from ld_desk  where languagetype='en' and labelbol='Dividend' and Labeltype='fixedstr');
delimiter;

select cvid into @cvid from ld_customview where viewname='mobileQuotes' and entitytype='mobileQuotes';
delete from ld_cvcolumnlist where cvid=@cvid;
insert into ld_cvcolumnlist (cvid,columnindex,columnname) values(@cvid,0,'ld_quotes:quote_no:quote_no:Quotes_编号:V' );
insert into ld_cvcolumnlist (cvid,columnindex,columnname) values(@cvid,1,'ld_quotes:subject:subject:Quotes_主题:V' );
insert into ld_cvcolumnlist (cvid,columnindex,columnname) values(@cvid,2,'ld_quotes:accountid:account_id:Quotes_客户:I' );
insert into ld_cvcolumnlist (cvid,columnindex,columnname) values(@cvid,3,'ld_quotes:subtotal:hdnSubTotal:Quotes_合计:N' );
insert into ld_cvcolumnlist (cvid,columnindex,columnname) values(@cvid,4,'ld_quotes:createdtime:createdtime:Quotes_创建日期:D' );
delimiter;

select cvid into @cvid  from ld_customview where viewname='mobileSalesOrder' and entitytype='mobileSalesOrder';
delete from ld_cvcolumnlist where cvid=@cvid;
insert into ld_cvcolumnlist (cvid,columnindex,columnname) values(@cvid,0,'ld_salesorder:salesorder_no:salesorder_no:SalesOrder_编号:V' );
insert into ld_cvcolumnlist (cvid,columnindex,columnname) values(@cvid,1,'ld_salesorder:subject:subject:Quotes_主题:V' );
insert into ld_cvcolumnlist (cvid,columnindex,columnname) values(@cvid,2,'ld_salesorder:accountid:account_id:SalesOrder_客户:I' );
insert into ld_cvcolumnlist (cvid,columnindex,columnname) values(@cvid,3,'ld_salesorder:total:hdnGrandTotal:SalesOrder_合计:N' );
insert into ld_cvcolumnlist (cvid,columnindex,columnname) values(@cvid,4,'ld_salesorder:signed_data:signed_data:SalesOrder_签约日期:D' );
delimiter;

select max(tabid) into @tabid from ld_tab;
insert into ld_tab(tabid,name,presence,tabsequence,tablabel,customized,ownedby,isentitytype,parent,printtab)
select @tabid+1,'mobileServiceContracts',1,50,'mobileServiceContracts',0,0,1,'Finacial',1 from dual where not exists(select 1 from ld_tab where name='mobileServiceContracts');
select MAX(cvid) into @maxid  from ld_customview;
update ld_customview_seq set id=@maxid+1 where not EXISTS(select 1 from ld_customview where viewname='mobileServiceContracts' and entitytype='mobileServiceContracts');
insert into ld_customview(cvid,viewname,setdefault,setmetrics,entitytype,status,userid,sequence,pagewidthpercent)select @maxid+1,'mobileServiceContracts',0,0,'mobileServiceContracts',0,1,1,100 
from dual where not EXISTS(select 1 from ld_customview where viewname='mobileServiceContracts' and entitytype='mobileServiceContracts');
select cvid into @cvid   from ld_customview where viewname='mobileServiceContracts' and entitytype='mobileServiceContracts';
delete from ld_cvcolumnlist where cvid=(select cvid from ld_customview where viewname='mobileServiceContracts' and entitytype='mobileServiceContracts' );
insert into ld_cvcolumnlist (cvid,columnindex,columnname) values(@cvid,0,'ld_servicecontracts:contract_no:contract_no:ServiceContracts_编号:V' );
insert into ld_cvcolumnlist (cvid,columnindex,columnname) values(@cvid,1,'ld_servicecontracts:accountid:account_id:ServiceContracts_客户:I' );
insert into ld_cvcolumnlist (cvid,columnindex,columnname) values(@cvid,2,'ld_servicecontracts:total:hdnGrandTotal:ServiceContracts_合计:N' );
insert into ld_cvcolumnlist (cvid,columnindex,columnname) values(@cvid,3,'ld_servicecontracts:due_date:due_date:ServiceContracts_签约日期:D' );
delimiter;

update ld_field set displaytype = 2 where tabid =(select tabid from ld_tab where name = 'ContactRecords') and fieldname = 'approvestatus';
delimiter;

select max(tabid) into @tabid from ld_tab;
insert into ld_tab(tabid,name,presence,tabsequence,tablabel,customized,ownedby,isentitytype,parent,printtab)
select @tabid+1,'mobileCampaigns',1,50,'mobileCampaigns',0,0,1,'Finacial',1 from dual where not exists(select 1 from ld_tab where name='mobileCampaigns');
select MAX(cvid) into @maxid  from ld_customview;
update ld_customview_seq set id=@maxid+1 where not EXISTS(select 1 from ld_customview where viewname='mobileCampaigns' and entitytype='mobileCampaigns');
insert into ld_customview(cvid,viewname,setdefault,setmetrics,entitytype,status,userid,sequence,pagewidthpercent)select @maxid+1,'mobileCampaigns',0,0,'mobileCampaigns',0,1,1,100 
from dual where not EXISTS(select 1 from ld_customview where viewname='mobileCampaigns' and entitytype='mobileCampaigns');
select cvid into @cvid   from ld_customview where viewname='mobileCampaigns' and entitytype='mobileCampaigns';
delete from ld_cvcolumnlist where cvid=(select cvid from ld_customview where viewname='mobileCampaigns' and entitytype='mobileCampaigns' );
insert into ld_cvcolumnlist (cvid,columnindex,columnname) values(@cvid,0,'ld_campaign:campaignname:campaignname:Campaigns_市场活动:V' );
delimiter;
-- 2015-07-02

update ld_desk set fieldlabel='Only then approved basic data can be choosed' where labelbol='ROCOSDOFA' and languagetype='en';
update ld_desk set fieldlabel='要删除的权限' where labelbol='TDAC' and languagetype='zh';
update ld_desk set fieldlabel='为相关用户分配新权限' where labelbol='LBL_TRANSFER_USER_ROLE' and languagetype='zh';
update ld_desk set fieldlabel='请为相关用户分配新权限！' where labelbol='PLEASEASSIGNASSOCIATEDUSER' and languagetype='zh';

INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype) SELECT 'zh','LBL_NOTDELETE_CUSTOMVIEW','您不能删除全部数据分类！','jspop' FROM DUAL WHERE NOT EXISTS(SELECT 1 FROM ld_desk WHERE languagetype='zh' AND labelbol='LBL_NOTDELETE_CUSTOMVIEW' AND Labeltype='jspop');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype) SELECT 'en','LBL_NOTDELETE_CUSTOMVIEW','You can`t delete all data categories!','jspop' FROM DUAL WHERE NOT EXISTS(SELECT 1 FROM ld_desk  WHERE languagetype='en' AND labelbol='LBL_NOTDELETE_CUSTOMVIEW' AND Labeltype='jspop');
delimiter;

select max(tabid) into @tabid from ld_tab;
insert into ld_tab(tabid,name,presence,tabsequence,tablabel,customized,ownedby,isentitytype,parent,printtab)
select @tabid+1,'mobilePotentials',1,50,'mobilePotentials',0,0,1,'Finacial',1 from dual where not exists(select 1 from ld_tab where name='mobilePotentials');
select MAX(cvid) into @maxid  from ld_customview;
update ld_customview_seq set id=@maxid+1 where not EXISTS(select 1 from ld_customview where viewname='mobilePotentials' and entitytype='mobilePotentials');
insert into ld_customview(cvid,viewname,setdefault,setmetrics,entitytype,status,userid,sequence,pagewidthpercent)select @maxid+1,'mobilePotentials',0,0,'mobilePotentials',0,1,1,100 
from dual where not EXISTS(select 1 from ld_customview where viewname='mobilePotentials' and entitytype='mobilePotentials');
select cvid into @cvid   from ld_customview where viewname='mobilePotentials' and entitytype='mobilePotentials';
delete from ld_cvcolumnlist where cvid=(select cvid from ld_customview where viewname='mobilePotentials' and entitytype='mobilePotentials' );
insert into ld_cvcolumnlist (cvid,columnindex,columnname) values(@cvid,0,'ld_potential:potentialname:potentialname:Potentials_机会名称:V' );
delimiter;

select tabid into @tabid from ld_tab where `name` = 'Potentials';
select fieldid into @fieldid from ld_field where tabid = @tabid and columnname = 'sales_stage';
update ld_field set quickcreate = 1 where tabid = @tabid and fieldid = @fieldid;
select fieldid into @fieldid from ld_field where tabid = @tabid and columnname = 'potential_no';
update ld_field set quickcreate = 1,typeofdata='V~M' where tabid = @tabid and fieldid = @fieldid;
delimiter;
-- 2015-07-03

UPDATE ld_desk SET fieldlabel = '小组本月销售数据' WHERE labelbol = 'SUBORDINATEMOTHSALESDATA' AND languagetype = 'zh';
delimiter;
UPDATE ld_desk SET fieldlabel = '有关联单据时是否允许删除{$Accounts.Accounts}' WHERE labelbol = 'ISNOTALLOWEDTODELETETOACCOUNTS' AND languagetype = 'zh';
delimiter;

ALTER TABLE ld_outboundorder MODIFY COLUMN presence VARCHAR(50);
ALTER TABLE ld_stock MODIFY COLUMN presence VARCHAR(50);
update ld_outboundorder set presence='未出库' where presence=0;
update ld_outboundorder set presence='已出库' where presence=1;
update ld_stock set presence='未入库' where presence=0;
update ld_stock set presence='已入库' where presence=1;

call getallprofile('Products');
delimiter;

update ld_producttoolfield set input_type = 0 where uitype in (33,36,16);
delimiter;

update ld_producttoolfield set input_type = 2 where producttoolfieldid in (select producttoolfieldid from ld_producttoolfield_formula);
delimiter;

update ld_producttoolfield LEFT JOIN ld_field on ld_field.fieldid = ld_producttoolfield.fieldid set ld_producttoolfield.tablename = 'ld_products' 
where ld_field.tabid = 14 and  ld_producttoolfield.input_type = 1 and ld_producttoolfield.tablename != 'ld_products';
delimiter;

select tabid into @tabid from ld_tab where `name` = 'Potentials';
select fieldid into @fieldid from ld_field where tabid = @tabid and columnname = 'sales_stage';
update ld_field set masseditable = 0 where tabid = @tabid and fieldid = @fieldid;
select fieldid into @fieldid from ld_field where tabid = @tabid and columnname = 'potentialname';
update ld_field set masseditable = 0,typeofdata='V~M' where tabid = @tabid and fieldid = @fieldid;
delimiter;

update ld_producttoolfield set edit_permission = 0 where columnname = 'procostprice';
delimiter;

update ld_producttoolfield set uitype = 16 where columnname = 'grossprofit';
delimiter;
-- 2015-07-06 

alter table ld_inventoryproductrelscf change sendarea sendarea decimal(25,2);
delimiter;

delete from  ld_producttoolfield where columnname='discount_percent' and presence=1 and tablename='ld_inventoryproductrel';
delete from  ld_producttoolfield where columnname='discount_amount' and presence=1 and tablename='ld_inventoryproductrel';
delimiter;

update ld_producttoolfield set typeofdata='V~M~100' where columnname='productname';
update ld_producttoolfield set typeofdata='N~O~25,2' where columnname='sendarea';
update ld_producttoolfield set typeofdata='V~O~100' where typeofdata like 'V~O%' and uitype not in (2,3);
update ld_producttoolfield set typeofdata='N~M~2' where columnname='quantity';
update ld_producttoolfield set typeofdata='N~M~25,8' where typeofdata like 'N~M%'  and uitype=10;
update ld_producttoolfield set typeofdata='N~M~25,6' where columnname in ('listprice','taxprice');
update ld_producttoolfield set typeofdata='N~O~25,6' where columnname in ('list_amount','discount_amount','tax_total');
update ld_producttoolfield set typeofdata='N~O~25,6' where columnname in ('rmb_taxprice','rmb_taxamount','rmbprice','eur_price');
update ld_producttoolfield set typeofdata='N~O~7,3' where columnname in ('discount_percent','discount_percent','grossprofit','','');
update ld_producttoolfield set typeofdata='N~O~7,3' where columnname in (select taxname from ld_inventorytaxinfo);
update ld_producttoolfield set typeofdata='N~O~25,6' where columnname in ('tax_amount');
update ld_producttoolfield set typeofdata='N~O~25,6' where columnname in ('subtotal','adjustment','discount_amount','total');
update ld_producttoolfield set tablename='ld_inventoryproductrel',typeofdata='N~O~25,6' where columnname='productcost';
delimiter;

alter table ld_salesorder change subtotal subtotal decimal(25,6);
alter table ld_salesorder change adjustment adjustment decimal(25,6);
alter table ld_salesorder change discount_amount discount_amount decimal(25,6);
alter table ld_salesorder change total total decimal(25,6);

alter table ld_quotes change subtotal subtotal decimal(25,6);
alter table ld_quotes change adjustment adjustment decimal(25,6);
alter table ld_quotes change discount_amount discount_amount decimal(25,6);
alter table ld_quotes change total total decimal(25,6);

alter table ld_purchaseorder change subtotal subtotal decimal(25,6);
alter table ld_purchaseorder change adjustment adjustment decimal(25,6);
alter table ld_purchaseorder change discount_amount discount_amount decimal(25,6);
alter table ld_purchaseorder change total total decimal(25,6);

alter table ld_invoice change subtotal subtotal decimal(25,6);
alter table ld_invoice change adjustment adjustment decimal(25,6);
alter table ld_invoice change discount_amount discount_amount decimal(25,6);
alter table ld_invoice change total total decimal(25,6);

alter table ld_servicecontracts change subtotal subtotal decimal(25,6);
alter table ld_servicecontracts change adjustment adjustment decimal(25,6);
alter table ld_servicecontracts change discount_amount discount_amount decimal(25,6);
alter table ld_servicecontracts change total total decimal(25,6);

alter table ld_outboundorder change subtotal subtotal decimal(25,6);
alter table ld_outboundorder change adjustment adjustment decimal(25,6);
alter table ld_outboundorder change discount_amount discount_amount decimal(25,6);
alter table ld_outboundorder change total total decimal(25,6);

alter table ld_stock change subtotal subtotal decimal(25,6);
alter table ld_stock change adjustment adjustment decimal(25,6);
alter table ld_stock change discount_amount discount_amount decimal(25,6);
alter table ld_stock change total total decimal(25,6);

alter table ld_salesback change subtotal subtotal decimal(25,6);
alter table ld_salesback change adjustment adjustment decimal(25,6);
alter table ld_salesback change discount_amount discount_amount decimal(25,6);
alter table ld_salesback change total total decimal(25,6);

alter table ld_cashback change subtotal subtotal decimal(25,6);
alter table ld_cashback change adjustment adjustment decimal(25,6);
alter table ld_cashback change discount_amount discount_amount decimal(25,6);
alter table ld_cashback change total total decimal(25,6);

alter table ld_purchaseback change subtotal subtotal decimal(25,6);
alter table ld_purchaseback change adjustment adjustment decimal(25,6);
alter table ld_purchaseback change discount_amount discount_amount decimal(25,6);
alter table ld_purchaseback change total total decimal(25,6);

alter table ld_purchasecashback change subtotal subtotal decimal(25,6);
alter table ld_purchasecashback change adjustment adjustment decimal(25,6);
alter table ld_purchasecashback change discount_amount discount_amount decimal(25,6);
alter table ld_purchasecashback change total total decimal(25,6);

alter table ld_purchaseinvoice change subtotal subtotal decimal(25,6);
alter table ld_purchaseinvoice change adjustment adjustment decimal(25,6);
alter table ld_purchaseinvoice change discount_amount discount_amount decimal(25,6);
alter table ld_purchaseinvoice change total total decimal(25,6);

alter table ld_warehousetransfer change subtotal subtotal decimal(25,6);
alter table ld_warehousetransfer change adjustment adjustment decimal(25,6);
alter table ld_warehousetransfer change discount_amount discount_amount decimal(25,6);
alter table ld_warehousetransfer change total total decimal(25,6);

alter table ld_productbom change subtotal subtotal decimal(25,6);
alter table ld_productbom change adjustment adjustment decimal(25,6);
alter table ld_productbom change total total decimal(25,6);

alter table ld_inventoryproductrel change rmbprice rmbprice decimal(25,6);
alter table ld_inventoryproductrel change discount_amount discount_amount decimal(25,6);
alter table ld_inventoryproductrel change listprice listprice decimal(25,6);
alter table ld_inventoryproductrel change taxprice taxprice decimal(25,6);
alter table ld_inventoryproductrel change profitloss profitloss decimal(25,8);
alter table ld_inventoryproductrel change paperquantity paperquantity decimal(25,8);
alter table ld_inventoryproductrel change firmoffer firmoffer decimal(25,8);
alter table ld_inventoryproductrel change productcost productcost decimal(25,6);
alter table ld_inventoryproductrel change grossprofit grossprofit decimal(7,3);

select max(tabid) into @tabid from ld_tab;
insert into ld_tab(tabid,name,presence,tabsequence,tablabel,customized,ownedby,isentitytype,parent,printtab)
select @tabid+1,'mobileServiceContracts',1,50,'mobileServiceContracts',0,0,1,'Finacial',1 from dual 
where not exists(select 1 from ld_tab where name='mobileServiceContracts');

select MAX(cvid) into @maxid  from ld_customview;
update ld_customview_seq set id=@maxid+1 where not EXISTS(select 1 from ld_customview where viewname='mobileServiceContracts' and entitytype='mobileServiceContracts');
insert into ld_customview(cvid,viewname,setdefault,setmetrics,entitytype,status,userid,sequence,pagewidthpercent)select @maxid+1,'mobileServiceContracts',0,0,'mobileServiceContracts',0,1,1,100 from dual 
where not EXISTS(select 1 from ld_customview where viewname='mobileServiceContracts' and entitytype='mobileServiceContracts');

select cvid into @cvid from ld_customview where viewname='mobileServiceContracts' and entitytype='mobileServiceContracts';
delete from ld_cvcolumnlist where cvid=@cvid;
insert into ld_cvcolumnlist (cvid,columnindex,columnname) values(@cvid,0,'ld_servicecontracts:contract_no:contract_no:ServiceContracts_编号:V' );
insert into ld_cvcolumnlist (cvid,columnindex,columnname) values(@cvid,1,'ld_servicecontracts:accountid:account_id:ServiceContracts_客户:I' );
insert into ld_cvcolumnlist (cvid,columnindex,columnname) values(@cvid,2,'ld_servicecontracts:total:hdnGrandTotal:ServiceContracts_合计:N' );
insert into ld_cvcolumnlist (cvid,columnindex,columnname) values(@cvid,3,'ld_servicecontracts:due_date:due_date:ServiceContracts_签约日期:D' );
delimiter;

update ld_producttoolfield set edit_permission = 0,defaultcolumn = 0 where columnname in ('productcost','grossprofit');
delimiter;

INSERT INTO ld_systems_deploy(deploy_value,deploy_type,description,setype)
SELECT '0',69,'有关联单据时不允许删除客户。1:否，0:是','' FROM DUAL WHERE NOT EXISTS
(SELECT 1 FROM ld_systems_deploy WHERE deploy_type=69);
delimiter;

update ld_tranlabel LEFT JOIN ld_producttoolfield on ld_producttoolfield.producttoolfieldid = ld_tranlabel.Relateid set ld_tranlabel.fieldlabel = '价税合计'  
where ld_tranlabel.languagetype = 'zh' and ld_tranlabel.trantable = 'ld_producttoolfield' and ld_producttoolfield.uitype = 36 and ld_producttoolfield.columnname = 'total' 
and ld_tranlabel.fieldlabel = '合计';
delimiter;
update ld_tranlabel LEFT JOIN ld_producttoolfield on ld_producttoolfield.producttoolfieldid = ld_tranlabel.Relateid set ld_tranlabel.fieldlabel = 'Price Tax Total'  
where ld_tranlabel.languagetype = 'en' and ld_tranlabel.trantable = 'ld_producttoolfield' and ld_producttoolfield.uitype = 36 and ld_producttoolfield.columnname = 'total' 
and ld_tranlabel.fieldlabel = 'Total';
delimiter;

delete from ld_field where columnname='lastserviceenddate' and tablename='ld_accountscf';
delimiter;

insert into ld_systems_deploy(deploy_value,deploy_type,description,setype)
select 1,70,'产品是否启用审批流程 1：否，0：是','' from dual where not exists
(select 1 from ld_systems_deploy where deploy_type=70);
delimiter;

insert into ld_systems_deploy(deploy_value,deploy_type,description,setype)
select 0,71,'调用产品时只能选择已审批的产品 1：否，0：是','Products' from dual where not exists
(select 1 from ld_systems_deploy where deploy_type=71);
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'zh','OTAPCBC','调用产品时只能选择已审批的产品','fixedstr' from dual where not EXISTS(select 1 from ld_desk where languagetype='zh' and labelbol='OTAPCBC' and Labeltype='fixedstr');

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'en','OTAPCBC','Only then approved products can be choosed','fixedstr' from dual where not EXISTS(select 1 from ld_desk  where languagetype='en' and labelbol='OTAPCBC' and Labeltype='fixedstr');
delimiter;

call AddColumn('ld_products','approvestatus','varchar','200',null);
delimiter;

Alter table ld_products alter column approvestatus set default '未提交';
delimiter;

call AddColumn('ld_products','approveby','int',1,null);
delimiter;

call fieldprofile('Products');
delimiter;

call getallprofile('Products');
delimiter;

SELECT blockid INTO @blockid FROM ld_blocks WHERE blocklabel='LBL_PRODUCT_INFORMATION';
SELECT tabid INTO @tabid FROM ld_tab WHERE name='Products';
update ld_field_seq set id =(select max(fieldid) from ld_field);
select id into @id from ld_field_seq;
update ld_field_seq set id=@id+1  where not exists(select 1 from ld_field where tablename='ld_notes' and fieldname='approvestatus');
insert into ld_field(tabid,fieldid,columnname,tablename,generatedtype,uitype,fieldname,fieldlabel,readonly,presence,defaultvalue,maximumlength,sequence,block,displaytype,typeofdata,quickcreate,quickcreatesequence,info_type,masseditable,helpinfo,fieldonly)
select @tabid,@id+1,'approvestatus','ld_products',1,130,'approvestatus','审批状态',1,0,'',100,19,@blockid,3,'V~O',3,'','BAS',1,'',0 from dual 
where not exists (select 1 from ld_field where tablename='ld_products' and fieldname='approvestatus');
delimiter;

SELECT blockid INTO @blockid FROM ld_blocks WHERE blocklabel='LBL_PRODUCT_INFORMATION';
SELECT tabid INTO @tabid FROM ld_tab WHERE name='Products';
update ld_field_seq set id =(select max(fieldid) from ld_field);
select id into @id from ld_field_seq;
update ld_field_seq set id=@id+1  where not exists(select 1 from ld_field where tablename='ld_notes' and fieldname='approveby');
insert into ld_field(tabid,fieldid,columnname,tablename,generatedtype,uitype,fieldname,fieldlabel,readonly,presence,defaultvalue,maximumlength,sequence,block,displaytype,typeofdata,quickcreate,quickcreatesequence,info_type,masseditable,helpinfo,fieldonly)
select @tabid,@id+1,'approveby','ld_products',1,130,'approveby','审批人',1,0,'',100,19,@blockid,3,'V~O',3,'','BAS',1,'',0 from dual 
where not exists (select 1 from ld_field where tablename='ld_products' and fieldname='approveby');
delimiter;

SELECT tabid INTO @tabid FROM ld_tab WHERE name='Products';
select fieldid into @fieldid from ld_field where tabid = @tabid and columnname = 'approvestatus';
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'zh','ld_field',@tabid,@fieldid,'审批状态'
from dual where not EXISTS(select 1 from ld_tranlabel  where languagetype = 'zh'
and trantable ='ld_field' and tabid = @tabid and relateid=@fieldid);
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'en','ld_field',@tabid,@fieldid,'approve status'
from dual where not EXISTS(select 1 from ld_tranlabel  where languagetype = 'en'
and trantable ='ld_field' and tabid = @tabid and relateid=@fieldid);
delimiter;

SELECT tabid INTO @tabid FROM ld_tab WHERE name='Products';
select fieldid into @fieldid from ld_field where tabid = @tabid and columnname = 'approveby';
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'zh','ld_field',@tabid,@fieldid,'审批人'
from dual where not EXISTS(select 1 from ld_tranlabel  where languagetype = 'zh'
and trantable ='ld_field' and tabid = @tabid and relateid=@fieldid);
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'en','ld_field',@tabid,@fieldid,'approver'
from dual where not EXISTS(select 1 from ld_tranlabel  where languagetype = 'en'
and trantable ='ld_field' and tabid = @tabid and relateid=@fieldid);
delimiter;

SELECT id INTO @roleid FROM ld_users WHERE user_name = 'admin' limit 1;

SELECT max(id) into @id from ld_approve;
SELECT tabid into @tabid FROM ld_tab where name='Products';
insert into ld_approve(id,tabid,name,description,status,smcreatorid,modifiedby,createdtime,modifiedtime)
SELECT @id+1,@tabid,'产品二级审批流程','产品预置二级审批流程',0,1,1,NOW(),NOW() from dual where not exists
(select 1 from ld_approve where name='产品二级审批流程');
delimiter;
SELECT tabid into @tabid FROM ld_tab where name='Products';
SELECT id into @id from ld_approve WHERE name='产品二级审批流程' and tabid =@tabid;
insert into ld_approve2user(approveid,userid) SELECT @id,@roleid from dual where not exists (select 1 from ld_approve2user where approveid=@id);
delimiter;

SELECT max(id) into @id from ld_approvestep;
SELECT tabid into @tabid FROM ld_tab where name='Products';
SELECT id into @approveid from ld_approve WHERE name='产品二级审批流程' and tabid =@tabid ;
insert into ld_approvestep(id,approveid,name,description,ended,step,sequence,createdtime,modifiedtime,approvetype,approvevalue,specifyapproverid)
SELECT @id+1,@approveid,'产品第一步审批','产品第一步审批步骤',1,0,1,NOW(),NOW(),0,1,1 from dual where not exists
(select 1 from ld_approvestep where approveid=@approveid and sequence=1);
delimiter;

SELECT max(id) into @id from ld_approvestep;
SELECT tabid into @tabid FROM ld_tab where name='Products';
SELECT id into @approveid from ld_approve WHERE name='产品二级审批流程' and tabid =@tabid ;
insert into ld_approvestep(id,approveid,name,description,ended,step,sequence,createdtime,modifiedtime,approvetype,approvevalue,specifyapproverid)
SELECT @id+1,@approveid,'产品第二步审批','产品第二步审批步骤',1,0,2,NOW(),NOW(),0,1,1 from dual where not exists
(select 1 from ld_approvestep where approveid=@approveid and sequence=2);
delimiter;
update ld_approve_seq set id = (select max(id) from ld_approve);
delimiter;
update ld_approvestep_seq set id = (select max(id) from ld_approvestep);
delimiter;

update ld_groups set groupname='某某公司',description='某某公司' where groupid=1 and groupname='组织结构';

DROP PROCEDURE IF EXISTS `updateprofieldseq2`;
delimiter ||
CREATE  PROCEDURE `updateprofieldseq2`(

)
begin

	declare tmp_tabid  int default 0;
	declare tmp_columnname  varchar(200) default NULL;
	declare mycursor cursor for select columnname,tabid from ld_producttoolfield where columnname='tax_amount' order by tabid; 
	DECLARE CONTINUE HANDLER FOR SQLSTATE '02000' set tmp_tabid = NULL;

	open mycursor;
	fetch mycursor into tmp_columnname,tmp_tabid;
	while(tmp_tabid is not null) DO
			set @seq=0;
			set @i=0;
			set @j=0;
			select sequence into @seq from ld_producttoolfield where tabid=tmp_tabid and columnname='productname';
			update ld_producttoolfield set sequence=sequence+500 where tabid=tmp_tabid;
			update ld_producttoolfield set sequence=(@i:=@i+1) where tabid=tmp_tabid and tablename='ld_products' order by sequence;
			update ld_producttoolfield set sequence=sequence+500 where tabid=tmp_tabid and columnname='productname';
			update ld_producttoolfield set sequence=0 where tabid=tmp_tabid and columnname='productname';
			update ld_producttoolfield set sequence=1 where tabid=tmp_tabid and columnname='product_no';
			update ld_producttoolfield set sequence=(@j:=@j+1) where tabid=tmp_tabid order by sequence;
			
			fetch mycursor into tmp_columnname,tmp_tabid;
	end while;
	close mycursor;
end ||
delimiter;

call updateprofieldseq2();
delimiter;
-- 2015-07-07

update ld_tranlabel set fieldlabel='sendarea' where fieldlabel='已租面积' and trantable='ld_producttoolfield' and languagetype='en';

update ld_field set quickcreate=0 where tabid=2 and columnname='currency_id';
set @cseq=0;
set @i=0;
select quickcreatesequence into @cseq from ld_field where tabid=2 and columnname='leadsource';
update ld_field set quickcreatesequence=quickcreatesequence+10 where tabid=2 and quickcreate=0 and quickcreatesequence>@cseq;
update ld_field set quickcreatesequence=@cseq+1 where tabid=2 and columnname='currency_id';
update ld_field set quickcreatesequence=(@i:=@i+1) where tabid=2 and quickcreate=0 order by quickcreatesequence;
delimiter;

update ld_field set masseditable=0 where columnname='smownerid';
update ld_field set typeofdata='V~M' where uitype=4;


update ld_field set defaultvalue=NULL where defaultvalue='--无--';
update ld_field set defaultvalue=NULL where defaultvalue='';

delete from ld_rating where rating='--无--';
update ld_account set rating='' where rating='--无--';

delete from ld_industry where industry='--无--';
update ld_account set industry='' where industry='--无--';

delete from ld_accounttype where accounttype='--无--';
update ld_account set account_type='' where account_type='--无--';

delete from ld_leadsource where leadsource='--无--';
update ld_accountscf set leadsource='' where leadsource='--无--';

delete from ld_accountsize where accountsize='--无--';
update ld_accountscf set accountsize='' where accountsize='--无--';

delete from ld_accountproperty where accountproperty='--无--';
update ld_accountscf set accountproperty='' where accountproperty='--无--';

delete from ld_important_level where important_level='--无--';
update ld_accountscf set important_level='' where important_level='--无--';

delete from ld_accountrelationship where accountrelationship='--无--';
update ld_accountscf set accountrelationship='' where accountrelationship='--无--';

delete from ld_registeredcapital where registeredcapital='--无--';
update ld_accountscf set registeredcapital='' where registeredcapital='--无--';

delete from ld_annualincome where annualincome='--无--';
update ld_accountscf set annualincome='' where annualincome='--无--';

delete from ld_salutationtype where salutationtype='--无--';
update ld_contactdetails set salutation='' where salutation='--无--';

delete from ld_contactrecordtype where contactrecordtype='--无--';
update ld_contactrecords set contactrecordtype='' where contactrecordtype='--无--';

update ld_potential set leadsource='' where leadsource='--无--';

delete from ld_opportunity_type where opportunity_type='--无--';
update ld_potential set potentialtype='' where potentialtype='--无--';

delete from ld_productcategory where productcategory='--无--';
update ld_potential set productcategory='' where productcategory='--无--';
update ld_products set productcategory='' where productcategory='--无--';

delete from ld_sales_stage where sales_stage='--无--';
update ld_potential set sales_stage='' where sales_stage='--无--';

delete from ld_quotestage where quotestage='--无--';
update ld_quotes set quotestage='' where quotestage='--无--';
update ld_field set defaultvalue=(select quotestage from ld_quotestage order by picklist_valueid LIMIT 1) where tabid=20 and columnname='quotestage' and defaultvalue is NULL;

delete from ld_sostatus where sostatus='--无--';
update ld_salesorder set sostatus='' where sostatus='--无--';
update ld_field set defaultvalue=(select sostatus from ld_sostatus order by picklist_valueid LIMIT 1) where tabid=22 and columnname='sostatus' and defaultvalue is NULL;


delete from ld_consumetime where consumetime='--无--';
update ld_troubletickets set consumetime='' where consumetime='--无--';

update ld_field set defaultvalue=(select ticketstatus from ld_ticketstatus where ticketstatus='未处理' ) where tabid=13 and columnname='status' and defaultvalue is NULL;
update ld_field set defaultvalue=(select ticketpriorities from ld_ticketpriorities where ticketpriorities='一般' ) where tabid=13 and columnname='priority' and defaultvalue is NULL;
update ld_field set defaultvalue=(select ticketseverities from ld_ticketseverities order by picklist_valueid LIMIT 1 ) where tabid=13 and columnname='severity' and defaultvalue is NULL;

delete from ld_projectstatus where projectstatus='--无--';
update ld_project set projectstatus='' where projectstatus='--无--';
update ld_field set defaultvalue=(select projectstatus from ld_projectstatus where projectstatus='开始') where tabid=48 and columnname='projectstatus' and defaultvalue is NULL;

delete from ld_projecttype where projecttype='--无--';
update ld_project set projecttype='' where projecttype='--无--';

update ld_projecttask set productcategory='' where productcategory='--无--';

delete from ld_projecttasktype where projecttasktype='--无--';
update ld_projecttask set projecttasktype='' where projecttasktype='--无--';

delete from ld_projecttaskpriority where projecttaskpriority='--无--';
update ld_projecttask set projecttaskpriority='' where projecttaskpriority='--无--';
update ld_field set defaultvalue=(select projecttaskpriority from ld_projecttaskpriority where projecttaskpriority='一般' ) where tabid=47 and columnname='projecttaskpriority' and defaultvalue is NULL;

delete from ld_projecttaskprogress where projecttaskprogress='--无--';
update ld_projecttask set projecttaskprogress='' where projecttaskprogress='--无--';

delete from ld_projectmilestonetype where projectmilestonetype='--无--';
update ld_projectmilestone set projectmilestonetype='' where projectmilestonetype='--无--';

delete from ld_invoicetype where invoicetype='--无--';
update ld_invoicetype set invoicetype='增票' where invoicetype='赠票';
update ld_invoicecf set invoicetype='' where invoicetype='--无--';
update ld_invoicecf set invoicetype='增票' where invoicetype='赠票';

select tabid into @tabid from ld_tab where `name`='PurchaseInvoice';
delete from ld_purchaseinvoicetype where purchaseinvoicetype='--无--';
update ld_purchaseinvoicetype set purchaseinvoicetype='增票' where purchaseinvoicetype='赠票';
update ld_purchaseinvoice set purchaseinvoicetype='' where purchaseinvoicetype='--无--';
update ld_purchaseinvoice set purchaseinvoicetype='增票' where purchaseinvoicetype='赠票';
update ld_field set defaultvalue=(select purchaseinvoicetype from ld_purchaseinvoicetype where purchaseinvoicetype='普票' ) where tabid=@tabid and columnname='purchaseinvoicetype' and defaultvalue is NULL;
update ld_field set defaultvalue=(select purchaseinvoicestatus from ld_purchaseinvoicestatus order by picklist_valueid LIMIT 1 ) where tabid=@tabid and columnname='purchaseinvoicestatus' and defaultvalue is NULL;

select tabid into @tabid from ld_tab where `name`='CashBill';
update ld_field set defaultvalue=(select paymentmethod from ld_paymentmethod where paymentmethod='现金' ) where tabid=@tabid and columnname='paymentmethod' and defaultvalue is NULL;

select tabid into @tabid from ld_tab where `name`='Vendors';
delete from ld_glacct where glacct='--无--';
update ld_vendor set glacct='' where glacct='--无--';
update ld_field set defaultvalue=NULL where tabid=@tabid and columnname='glacct' and defaultvalue='电子';

select tabid into @tabid from ld_tab where `name`='VendorContact';
update ld_vendorcontacts set salutation='' where salutation='--无--';

select tabid into @tabid from ld_tab where `name`='PurchaseOrder';
update ld_field set defaultvalue=(select postatus from ld_postatus order by picklist_valueid LIMIT 1) where tabid=@tabid and columnname='postatus' and defaultvalue is NULL;

delete from ld_campaigntype where campaigntype='--无--';
update ld_campaign set campaigntype='' where campaigntype='--无--';

delete from ld_campaignstatus where campaignstatus='--无--';
update ld_campaign set campaignstatus='' where campaignstatus='--无--';

delete from ld_usageunit where usageunit='--无--';
update ld_products set usageunit='' where usageunit='--无--';

update ld_field set defaultvalue=(select faqcategories from ld_faqcategories order by picklist_valueid LIMIT 1) where tabid=15 and columnname='category' and defaultvalue is NULL;
update ld_field set defaultvalue=(select faqstatus from ld_faqstatus order by picklist_valueid LIMIT 1) where tabid=15 and columnname='status' and defaultvalue is NULL;

update ld_field set sequence=sequence+100 where tabid=15 and block=37;
update ld_field set sequence=0 where tabid=15 and block=37 and columnname='product_id';
update ld_field set sequence=1 where tabid=15 and block=37 and columnname='faq_no';
update ld_field set sequence=3 where tabid=15 and block=37 and columnname='category';
update ld_field set sequence=4 where tabid=15 and block=37 and columnname='status';
update ld_field set sequence=5 where tabid=15 and block=37 and columnname='question';
update ld_field set sequence=6 where tabid=15 and block=37 and columnname='answer';
update ld_field set sequence=7 where tabid=15 and block=37 and columnname='smownerid';
set @i=0;
update ld_field set sequence=(@i:=@i+1) where tabid=15 and block=37 order by sequence;
delimiter;

update ld_field set masseditable=0 where columnname='currency_id';
update ld_field set masseditable=0 where columnname='bankaccountsetid';

select tabid into @tabid from ld_tab where name = 'Productbom';
update ld_producttoolfield set tablename='ld_inventoryproductrel' where tabid=@tabid and columnname='taxprice';
delimiter;

select tabid into @tabid from ld_tab where name = 'Productbom';
delete from ld_producttoolfield where tabid=@tabid and columnname='unit_price' and defaultcolumn=1;
select max(producttoolfieldid)+1 into @producttoolfieldid from ld_producttoolfield;
insert into ld_producttoolfield(producttoolfieldid,columnname,fieldlabel,presence,uitype,typeofdata,sequence,tabid,tablename,width,edit_permission,input_type,fieldid,newline,defaultcolumn)
select @producttoolfieldid,'unit_price','参考价',2,50,'N~O~25,6',100,@tabid,'ld_products',10,2,1,194,0,2 from dual
where not exists(select 1 from ld_producttoolfield where tabid=@tabid and columnname='unit_price');
update ld_producttoolfield_seq set id=(select max(producttoolfieldid) from ld_producttoolfield);

set @i=0;
select sequence into @seq1 from ld_producttoolfield where tabid=@tabid and columnname='taxprice';
update ld_producttoolfield set sequence=sequence+10 where tabid=@tabida and sequence>=@seq1;
update ld_producttoolfield set sequence=@seq1 where tabid=@tabid and columnname='unit_price';
update ld_producttoolfield set sequence=(@i:=@i+1) where tabid=@tabid order by sequence;

select producttoolfieldid into @fieldid from ld_producttoolfield where tabid=@tabid and columnname='unit_price';
insert into ld_tranlabel(languagetype,trantable,tabid,Relateid,fieldlabel)
select 'zh','ld_producttoolfield',@tabid,@fieldid,'参考价' from dual 
where not exists(select 1 from ld_tranlabel where tabid=@tabid and languagetype='zh' and Relateid=@fieldid and trantable='ld_producttoolfield');

insert into ld_tranlabel(languagetype,trantable,tabid,Relateid,fieldlabel)
select 'en','ld_producttoolfield',@tabid,@fieldid,'Unit Price' from dual 
where not exists(select 1 from ld_tranlabel where tabid=@tabid and languagetype='en' and Relateid=@fieldid and trantable='ld_producttoolfield');


select producttoolfieldid into @fieldid1 from ld_producttoolfield where tabid=@tabid and columnname='taxprice';
select producttoolfieldid into @fieldid2 from ld_producttoolfield where tabid=@tabid and columnname='tax_amount';
insert into ld_producttoolfield_formula (producttoolfieldid,formulastring,columnstring,sequence)
select @fieldid1,'a*1','{formulavar:[{''lettervar'':''a'',''column'':''unit_price''}]}',0 from dual
where not EXISTS(select 1 from ld_producttoolfield_formula where producttoolfieldid=@fieldid1);

update ld_producttoolfield_formula set sequence=0 where producttoolfieldid =@fieldid1;
update ld_producttoolfield_formula set sequence=1 where producttoolfieldid =@fieldid2;
delimiter;

select tabid into @tabid from ld_tab where `name` = 'BankAccountSet';
update ld_field set masseditable=0 where tabid=@tabid and columnname='initmoney';
delimiter;

update ld_users set userlevel=NULL where userlevel='';
update ld_users set userlevel=(select userlevel from ld_userlevel order by picklist_valueid limit 1) where id=1 and userlevel is NULL;

update ld_producttoolfield set typeofdata = 'V~O' where uitype = 56 and (typeofdata is null or typeofdata = '');
delimiter;
update ld_producttoolfield set defaultcolumn = 5,edit_permission=0 where columnname in ('productcost','grossprofit');
delimiter;
update ld_producttoolfield set columnname = 'productcost' where columnname = 'procostprice';
delimiter;
update ld_producttoolfield set tablename = 'ld_inventoryproductrel' where columnname = 'productcost' and tablename='ld_products';
delimiter;
update ld_desk set fieldlabel='所选用户可以对该库进行库存初始化、出库、入库、盘点、库间调拨等操作，系统管理员用户自动拥有此权限。'  where labelbol='SELECTUSERWAREHOUSE' and languagetype='zh';
update ld_desk set fieldlabel='The selected user can initialize the library inventory,warehousing,storage,inventory,allocation between libraries and other operations,the system administrator users automatically have this permission'
where labelbol='SELECTUSERWAREHOUSE' and languagetype='en';
delimiter;

UPDATE ld_systems_deploy SET setype='' WHERE deploy_type=71;
UPDATE ld_systems_deploy SET setype='Products' WHERE deploy_type=70;
delimiter;
-- 2015-07-08

call getTaxInfoForFormula(1); 
select tabid into @tabid from ld_tab where name='WareHouseTransfer';
select producttoolfieldid into @producttoolfieldid from ld_producttoolfield where tabid=@tabid and columnname='taxprice';
select column_string into @column_string from tmp_taxformula;
select letter_string into @letter_string  from tmp_taxformula;
set @formula_column_string=concat('{formulavar:[{''''lettervar'''':''''a'''',''''column'''':''''listprice''''},',@column_string,']}');
set @formula_letter_string=concat('a*(1+(',@letter_string,')/100)');
set @formulsql=concat('insert into ld_producttoolfield_formula (producttoolfieldid,formulastring,columnstring,sequence)  select ', @producttoolfieldid,' ,''',@formula_letter_string,''',''',@formula_column_string,''',',' 1 from dual where not EXISTS(select 1 from ld_producttoolfield_formula where producttoolfieldid=',@producttoolfieldid,')');

PREPARE stmt FROM @formulsql;
EXECUTE stmt;
DEALLOCATE prepare stmt;
delimiter;
select tabid into @tabid from ld_tab where name='WareHouseTransfer';
select producttoolfieldid into @producttoolfieldid from ld_producttoolfield where tabid=@tabid and columnname='listprice';
select column_string into @column_string from tmp_taxformula;
select letter_string into @letter_string  from tmp_taxformula;
set @formula_column_string=concat('{formulavar:[{''''lettervar'''':''''a'''',''''column'''':''''taxprice''''},',@column_string,']}');
set @formula_letter_string=concat('a/(1+(',@letter_string,')/100)');
set @formulsql=concat('insert into ld_producttoolfield_formula (producttoolfieldid,formulastring,columnstring,sequence)  select ', @producttoolfieldid,' ,''',@formula_letter_string,''',''',@formula_column_string,''',',2,' from dual where not EXISTS(select 1 from ld_producttoolfield_formula where producttoolfieldid=',@producttoolfieldid,')');
PREPARE stmt FROM @formulsql;
EXECUTE stmt;
DEALLOCATE prepare stmt;
delimiter;


call getTaxInfoForFormula(1); 
select column_string into @column_string from tmp_taxformula;
select letter_string into @letter_string  from tmp_taxformula;
select nextletterstart into @nextletterstart from tmp_taxformula;
select tabid into @tabid from ld_tab where name='WareHouseTransfer';
SET @sqlletter = CONCAT('select letter into @quantity_letter from tmp_letter limit ',@nextletterstart,',1') ;
PREPARE stmt FROM @sqlletter;
EXECUTE stmt;
DEALLOCATE prepare stmt;

set @nextletterstart=@nextletterstart+1;
SET @sqlletter = CONCAT('select letter into @discount_percent from tmp_letter limit ',@nextletterstart,',1') ;
PREPARE stmt FROM @sqlletter;
EXECUTE stmt;
DEALLOCATE prepare stmt;

set @formula_column_string=concat('{formulavar:[{''''lettervar'''':''''a'''',''''column'''':''''taxprice''''},',@column_string,',{''''lettervar'''':''''',@quantity_letter,'''''',',''''column''''',':','''''quantity''''}',',{''''lettervar'''':''''',@discount_percent,'''''',',''''column''''',':','''''discount_percent''''}]}');
set @formula_letter_string=concat('(a/(1+(',@letter_string,')/100))*',@quantity_letter,'*(1-',@discount_percent,'/100)');

select producttoolfieldid into @producttoolfieldid from ld_producttoolfield where tabid=@tabid and columnname='list_amount';
set @formulsql=concat('insert into ld_producttoolfield_formula (producttoolfieldid,formulastring,columnstring,sequence)  select ', @producttoolfieldid,' ,''',@formula_letter_string,''',''',@formula_column_string,''',',' 3 from dual where not EXISTS(select 1 from ld_producttoolfield_formula where producttoolfieldid=',@producttoolfieldid,')');
PREPARE stmt FROM @formulsql;
EXECUTE stmt;
DEALLOCATE prepare stmt;
delimiter;


select tabid into @tabid from ld_tab where name='WareHouseTransfer';
select producttoolfieldid into @producttoolfieldid from ld_producttoolfield where tabid=@tabid and columnname='tax_amount';
select column_string into @column_string from tmp_taxformula;
select letter_string into @letter_string  from tmp_taxformula;
insert into ld_producttoolfield_formula (producttoolfieldid,formulastring,columnstring,sequence)
select @producttoolfieldid,'a*b*(1-c/100)','{formulavar:[{''lettervar'':''a'',''column'':''quantity''},{''lettervar'':''b'',''column'':''taxprice''},{''lettervar'':''c'',''column'':''discount_percent''}]}',4 from dual
where not EXISTS(select 1 from ld_producttoolfield_formula where producttoolfieldid=@producttoolfieldid);
delimiter;


call getTaxInfoForFormula(1);
select tabid into @tabid from ld_tab where name='WareHouseTransfer';
select producttoolfieldid into @producttoolfieldid from ld_producttoolfield where tabid=@tabid and columnname='tax_total';
select column_string into @column_string from tmp_taxformula;
select letter_string into @letter_string  from tmp_taxformula;

set @formula_column_string=concat('{formulavar:[{''''lettervar'''':''''a'''',''''column'''':''''list_amount''''},',@column_string,']}');
set @formula_letter_string=concat('a*((',@letter_string,')/100)');

set @formulsql=concat('insert into ld_producttoolfield_formula (producttoolfieldid,formulastring,columnstring,sequence)  select ', @producttoolfieldid,' ,''',@formula_letter_string,''',''',@formula_column_string,''',',' 5 from dual where not EXISTS(select 1 from ld_producttoolfield_formula where producttoolfieldid=',@producttoolfieldid,')');
PREPARE stmt FROM @formulsql;
EXECUTE stmt;
DEALLOCATE prepare stmt;
delimiter;
select tabid into @tabid from ld_tab where name='WareHouseTransfer';
select producttoolfieldid into @producttoolfieldid from ld_producttoolfield where tabid=@tabid and presence in(0,2) and  columnname='discount_amount' and tablename='ld_inventoryproductrel';
select column_string into @column_string from tmp_taxformula;
select letter_string into @letter_string  from tmp_taxformula;
insert into ld_producttoolfield_formula (producttoolfieldid,formulastring,columnstring,sequence)
select @producttoolfieldid,'a*b*(c/100)','{formulavar:[{''lettervar'':''a'',''column'':''quantity''},{''lettervar'':''b'',''column'':''taxprice''},{''lettervar'':''c'',''column'':''discount_percent''}]}',8 from dual
where not EXISTS(select 1 from ld_producttoolfield_formula where producttoolfieldid=@producttoolfieldid);
delimiter;

update ld_field set defaultvalue=(select sales_stage from ld_sales_stage order by picklist_valueid LIMIT 1) where tabid=2 and columnname='sales_stage' and defaultvalue is NULL;

call AddColumn('ld_systems_deploy','sequence','int',4,null);
delimiter;

insert into ld_systems_deploy(deploy_value,deploy_type,description,setype,sequence)
select 1,72,'客户首要联系人显示设置 只用来排序','','' from dual where not exists
(select 1 from ld_systems_deploy where deploy_type=72);
delimiter;

insert into ld_systems_deploy(deploy_value,deploy_type,description,setype,sequence)
select 1,73,'设置登录时是否启用验证码 只用来排序','','' from dual where not exists
(select 1 from ld_systems_deploy where deploy_type=73);
delimiter;

update ld_systems_deploy set description='合同订单编辑保存后是否自动生成出库单。仓库为空:否，不为空:是' where deploy_type=63;
update ld_desk set fieldlabel='设置关联单据只能选择已审批单据' where languagetype='zh' and labelbol='ROCOSDOFA';
update ld_desk set fieldlabel='设置首页默认显示的视图页签' where languagetype='zh' and labelbol='LBL_HOMECONTROLSTYLE';
update ld_desk set fieldlabel='设置首页组件视图的布局样式' where languagetype='zh' and labelbol='LBL_HOMECONTROLLAYOUT';
update ld_desk set fieldlabel='设置序时簿列表每页显示记录的条数' where languagetype='zh' and labelbol='LISTBOOKNUM';
update ld_desk set fieldlabel='设置相关信息列表每页显示记录的条数' where languagetype='zh' and labelbol='PAGEMORELISTNUM';
update ld_desk set fieldlabel='设置单据分录明细中数量字段小数位数' where languagetype='zh' and labelbol='LENGTHDECIMALDIGITS';
update ld_desk set fieldlabel='设置序时簿中批量操作记录条数的上限' where languagetype='zh' and labelbol='MAXIMUMRECORDSNUMBEROFMASSOPERATION';
update ld_desk set fieldlabel='设置是否仅允许系统管理员用户取消共享' where languagetype='zh' and labelbol='SHARINGSETTINGS';
update ld_desk set fieldlabel='{$Accounts.Accounts}资料分配时是否同时分配相关信息' where languagetype='zh' and labelbol='ACCOUNTALSDISWHETHERDIS';
update ld_desk set fieldlabel='{$Potentials.Potentials}资料分配时是否同时分配相关信息' where languagetype='zh' and labelbol='POTENTIALSDISWHETHERDIS';
update ld_desk set fieldlabel='{$SalesOrder.SalesOrder}新增或编辑后是否立即打印' where languagetype='zh' and labelbol='AFTERCREATESALESORDERPRINT';
update ld_desk set fieldlabel='当{$OutboundOrder.OutboundOrder}审核时是否发送短信通知客户' where languagetype='zh' and labelbol='CONFIRMINFORMOUTBOUND';


insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'zh','cannotempty','{$Potentials.sales_stage}不能为空','jspop' 
from dual where not EXISTS(select 1 from ld_desk where languagetype='zh' and labelbol='cannotempty' and Labeltype='jspop');

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'en','cannotempty','{$Potentials.sales_stage} can not empty','jspop' 
from dual where not EXISTS(select 1 from ld_desk  where languagetype='en' and labelbol='cannotempty' and Labeltype='jspop');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'zh','UWASIBMNU',
'{$SalesOrder.SalesOrder}新增保存时更新{$Accounts.Accounts}的{$Accounts.rating}为（为空表示不更新）','fixedstr' 
from dual where not EXISTS(select 1 from ld_desk where languagetype='zh' and labelbol='UWASIBMNU' and Labeltype='fixedstr');

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'en','UWASIBMNU',
'{$Accounts.Accounts} updated when {$SalesOrder.SalesOrder} Added save {$Accounts.rating} is (blank means no update)','fixedstr' 
from dual where not EXISTS(select 1 from ld_desk  where languagetype='en' and labelbol='UWASIBMNU' and Labeltype='fixedstr');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'zh','UWASIBMNU2',
'{$SalesOrder.SalesOrder}新增保存时更新{$SalesOrder.SalesOrder}的{$SalesOrder.sostatus}为（为空表示不更新）','fixedstr' 
from dual where not EXISTS(select 1 from ld_desk where languagetype='zh' and labelbol='UWASIBMNU2' and Labeltype='fixedstr');

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'en','UWASIBMNU2',
'{$Accounts.Accounts} updated when {$SalesOrder.SalesOrder} Added save {$SalesOrder.sostatus} is (blank means no update)','fixedstr' 
from dual where not EXISTS(select 1 from ld_desk  where languagetype='en' and labelbol='UWASIBMNU2' and Labeltype='fixedstr');
delimiter;

UPDATE ld_field SET uitype=131,presence=2,displaytype=2 WHERE columnname='approveby' AND tabid=(SELECT tabid FROM ld_tab WHERE name='Products');
delimiter;
UPDATE ld_field SET readonly=1,presence=2,displaytype=2 WHERE columnname='approvestatus' AND tabid=(SELECT tabid FROM ld_tab WHERE name='Products');
delimiter;

alter table ld_outboundorder alter column presence set default '未出库';
alter table ld_stock alter column presence set default '未入库';
delimiter;
-- 2015-07-09

select tabid into @tabid from ld_tab where `name`='PurchaseInvoice';
delete from ld_producttoolfield_formula where producttoolfieldid in (select producttoolfieldid from ld_producttoolfield where tabid=@tabid);

call getTaxInfoForFormula(1); 
select tabid into @tabid from ld_tab where name='PurchaseInvoice';
select producttoolfieldid into @producttoolfieldid from ld_producttoolfield where tabid=@tabid and columnname='taxprice';
select column_string into @column_string from tmp_taxformula;
select letter_string into @letter_string  from tmp_taxformula;
set @formula_column_string=concat('{formulavar:[{''''lettervar'''':''''a'''',''''column'''':''''listprice''''},',@column_string,']}');
set @formula_letter_string=concat('a*(1+(',@letter_string,')/100)');
set @formulsql=concat('insert into ld_producttoolfield_formula (producttoolfieldid,formulastring,columnstring,sequence)  select ', @producttoolfieldid,' ,''',@formula_letter_string,''',''',@formula_column_string,''',',' 1 from dual where not EXISTS(select 1 from ld_producttoolfield_formula where producttoolfieldid=',@producttoolfieldid,')');

PREPARE stmt FROM @formulsql;
EXECUTE stmt;
DEALLOCATE prepare stmt;
delimiter;
select tabid into @tabid from ld_tab where name='PurchaseInvoice';
select producttoolfieldid into @producttoolfieldid from ld_producttoolfield where tabid=@tabid and columnname='listprice';
select column_string into @column_string from tmp_taxformula;
select letter_string into @letter_string  from tmp_taxformula;
set @formula_column_string=concat('{formulavar:[{''''lettervar'''':''''a'''',''''column'''':''''taxprice''''},',@column_string,']}');
set @formula_letter_string=concat('a/(1+(',@letter_string,')/100)');
set @formulsql=concat('insert into ld_producttoolfield_formula (producttoolfieldid,formulastring,columnstring,sequence)  select ', @producttoolfieldid,' ,''',@formula_letter_string,''',''',@formula_column_string,''',',2,' from dual where not EXISTS(select 1 from ld_producttoolfield_formula where producttoolfieldid=',@producttoolfieldid,')');
PREPARE stmt FROM @formulsql;
EXECUTE stmt;
DEALLOCATE prepare stmt;
delimiter;


call getTaxInfoForFormula(1); 
select column_string into @column_string from tmp_taxformula;
select letter_string into @letter_string  from tmp_taxformula;
select nextletterstart into @nextletterstart from tmp_taxformula;
select tabid into @tabid from ld_tab where name='PurchaseInvoice';
SET @sqlletter = CONCAT('select letter into @quantity_letter from tmp_letter limit ',@nextletterstart,',1') ;
PREPARE stmt FROM @sqlletter;
EXECUTE stmt;
DEALLOCATE prepare stmt;

set @nextletterstart=@nextletterstart+1;
SET @sqlletter = CONCAT('select letter into @discount_percent from tmp_letter limit ',@nextletterstart,',1') ;
PREPARE stmt FROM @sqlletter;
EXECUTE stmt;
DEALLOCATE prepare stmt;

set @formula_column_string=concat('{formulavar:[{''''lettervar'''':''''a'''',''''column'''':''''taxprice''''},',@column_string,',{''''lettervar'''':''''',@quantity_letter,'''''',',''''column''''',':','''''quantity''''}',',{''''lettervar'''':''''',@discount_percent,'''''',',''''column''''',':','''''discount_percent''''}]}');
set @formula_letter_string=concat('(a/(1+(',@letter_string,')/100))*',@quantity_letter,'*(1-',@discount_percent,'/100)');

select producttoolfieldid into @producttoolfieldid from ld_producttoolfield where tabid=@tabid and columnname='list_amount';
set @formulsql=concat('insert into ld_producttoolfield_formula (producttoolfieldid,formulastring,columnstring,sequence)  select ', @producttoolfieldid,' ,''',@formula_letter_string,''',''',@formula_column_string,''',',' 3 from dual where not EXISTS(select 1 from ld_producttoolfield_formula where producttoolfieldid=',@producttoolfieldid,')');
PREPARE stmt FROM @formulsql;
EXECUTE stmt;
DEALLOCATE prepare stmt;
delimiter;


select tabid into @tabid from ld_tab where name='PurchaseInvoice';
select producttoolfieldid into @producttoolfieldid from ld_producttoolfield where tabid=@tabid and columnname='tax_amount';
select column_string into @column_string from tmp_taxformula;
select letter_string into @letter_string  from tmp_taxformula;
insert into ld_producttoolfield_formula (producttoolfieldid,formulastring,columnstring,sequence)
select @producttoolfieldid,'a*b*(1-c/100)','{formulavar:[{''lettervar'':''a'',''column'':''quantity''},{''lettervar'':''b'',''column'':''taxprice''},{''lettervar'':''c'',''column'':''discount_percent''}]}',4 from dual
where not EXISTS(select 1 from ld_producttoolfield_formula where producttoolfieldid=@producttoolfieldid);
delimiter;


call getTaxInfoForFormula(1);
select tabid into @tabid from ld_tab where name='PurchaseInvoice';
select producttoolfieldid into @producttoolfieldid from ld_producttoolfield where tabid=@tabid and columnname='tax_total';
select column_string into @column_string from tmp_taxformula;
select letter_string into @letter_string  from tmp_taxformula;

set @formula_column_string=concat('{formulavar:[{''''lettervar'''':''''a'''',''''column'''':''''list_amount''''},',@column_string,']}');
set @formula_letter_string=concat('a*((',@letter_string,')/100)');

set @formulsql=concat('insert into ld_producttoolfield_formula (producttoolfieldid,formulastring,columnstring,sequence)  select ', @producttoolfieldid,' ,''',@formula_letter_string,''',''',@formula_column_string,''',',' 5 from dual where not EXISTS(select 1 from ld_producttoolfield_formula where producttoolfieldid=',@producttoolfieldid,')');
PREPARE stmt FROM @formulsql;
EXECUTE stmt;
DEALLOCATE prepare stmt;
delimiter;
select tabid into @tabid from ld_tab where name='PurchaseInvoice';
select producttoolfieldid into @producttoolfieldid from ld_producttoolfield where tabid=@tabid and presence in(0,2) and  columnname='discount_amount' and tablename='ld_inventoryproductrel';
select column_string into @column_string from tmp_taxformula;
select letter_string into @letter_string  from tmp_taxformula;
insert into ld_producttoolfield_formula (producttoolfieldid,formulastring,columnstring,sequence)
select @producttoolfieldid,'a*b*(c/100)','{formulavar:[{''lettervar'':''a'',''column'':''quantity''},{''lettervar'':''b'',''column'':''taxprice''},{''lettervar'':''c'',''column'':''discount_percent''}]}',8 from dual
where not EXISTS(select 1 from ld_producttoolfield_formula where producttoolfieldid=@producttoolfieldid);
delimiter;

update ld_producttoolfield set columnname = 'qtyinstock' where columnname = 'paperquantity' and defaultcolumn = 3;
delimiter;

select tabid into @tabid from ld_tab where name='checks';
select producttoolfieldid into @producttoolfieldid from ld_producttoolfield where tabid=@tabid and columnname='profitloss';
delete from ld_producttoolfield_formula  where producttoolfieldid=@producttoolfieldid;
insert into ld_producttoolfield_formula (producttoolfieldid,formulastring,columnstring)
select @producttoolfieldid,'a-b','{formulavar:[{''lettervar'':''a'',''column'':''firmoffer''},{''lettervar'':''b'',''column'':''qtyinstock''}]}' from dual
where not EXISTS(select 1 from ld_producttoolfield_formula where producttoolfieldid=@producttoolfieldid);
delimiter;

update ld_field set displaytype = 2 where columnname = 'approvestatus';
delimiter;
-- 2015-07-10

UPDATE ld_field SET displaytype=3 WHERE columnname='approvestatus' AND tabid=(SELECT tabid FROM ld_tab WHERE name='products');
delimiter;
UPDATE ld_field SET displaytype=3 WHERE columnname='approvestatus' AND tabid=(SELECT tabid FROM ld_tab WHERE name='ServiceCharge');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'zh','AFMWWAOTDCTSB','控制选择基础资料时是否在全部数据中模糊匹配','fixedstr' from dual where not EXISTS(select 1 from ld_desk where languagetype='zh' and labelbol='AFMWWAOTDCTSB' and Labeltype='fixedstr');

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'en','AFMWWAOTDCTSB','Are fuzzy match when all of the data control to select biography','fixedstr' from dual where not EXISTS(select 1 from ld_desk  where languagetype='en' and labelbol='AFMWWAOTDCTSB' and Labeltype='fixedstr');
delimiter;

insert into ld_systems_deploy(deploy_value,deploy_type,description,setype)
select 0,74,'控制选择基础资料时是否在全部数据中模糊匹配 0：否，1：是','' from dual where not exists
(select 1 from ld_systems_deploy where deploy_type=74);
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) 
select 'zh','ADVANCE','推进','jspop' 
from dual where not EXISTS(select 1 from ld_desk where languagetype='zh' and labelbol='ADVANCE' and Labeltype='jspop');

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) 
select 'en','ADVANCE','Advance','jspop' 
from dual where not EXISTS(select 1 from ld_desk  where languagetype='en' and labelbol='ADVANCE' and Labeltype='jspop');
delimiter;

ALTER TABLE ld_checks MODIFY COLUMN presence VARCHAR(50);
update ld_checks set presence='盘点中' where presence=0;
update ld_checks set presence='盘点结束' where presence=1;
alter table ld_checks alter column presence set default '未出库';
delimiter;
update ld_cvadvfilter set comparator='c' where cvid=(select cvid from ld_customview where cvid='出库' and entitytype='InventoryAccount');
update ld_cvadvfilter set comparator='c' where cvid=(select cvid from ld_customview where cvid='调拨' and entitytype='InventoryAccount');
update ld_cvadvfilter set comparator='c' where cvid=(select cvid from ld_customview where cvid='盘点' and entitytype='InventoryAccount');
delimiter;
update ld_producttoolfield set columnname='adjustment' where tabid in(select tabid from ld_tab where name='stock') and uitype=35;
delimiter;

call AddColumn('ld_singin','accounts_lng','varchar','50',null);
delimiter;
call AddColumn('ld_singin','accounts_lat','varchar','50',null);
delimiter;

update ld_field set quickcreate = 1 where tabid = 14 and fieldname = 'taxclass';
delimiter;
-- 2015-07-13

select tabid into @tabid from ld_tab where `name`='ServiceCharge';
update ld_field set uitype=86,typeofdata='DT~O' where columnname='nextcontactdate' and tabid=@tabid;
delimiter;

update ld_field set quickcreate = 1 where tabid = 14 and fieldname = 'taxclass';
delimiter;

DELETE FROM ld_desk WHERE labelbol='UWASIBMNU2';
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'zh','UWASIBMNU2',
'{$SalesOrder.SalesOrder}新增保存时更新{$Potentials.Potentials}的{$Potentials.sales_stage}为（为空表示不更新）','fixedstr' 
from dual where not EXISTS(select 1 from ld_desk where languagetype='zh' and labelbol='UWASIBMNU2' and Labeltype='fixedstr');

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'en','UWASIBMNU2',
'{$Potentials.Potentials} updated when {$SalesOrder.SalesOrder} Added save {$Potentials.sales_stage} is (blank means no update)','fixedstr' 
from dual where not EXISTS(select 1 from ld_desk  where languagetype='en' and labelbol='UWASIBMNU2' and Labeltype='fixedstr');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'zh','DSNCOVOTSTP5TQR','说明：由于未选择{$Vendors.Vendors}，仅显示符合条件的前5条数据。','fixedstr' from dual where not EXISTS(select 1 from ld_desk where languagetype='zh' and labelbol='DSNCOVOTSTP5TQR' and Labeltype='fixedstr');

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'en','DSNCOVOTSTP5TQR','Description: Since no choice of {$Vendors.Vendors}, only to show the top 5 of the query result.','fixedstr' from dual where not EXISTS(select 1 from ld_desk  where languagetype='en' and labelbol='DSNCOVOTSTP5TQR' and Labeltype='fixedstr');
delimiter;

update ld_cvadvfilter set comparator='c' where cvid=(select cvid from ld_customview where viewname='出库' and entitytype='InventoryAccount');
update ld_cvadvfilter set comparator='c' where cvid=(select cvid from ld_customview where viewname='盘点' and entitytype='InventoryAccount');

select cvid into @cvid from ld_customview where viewname='调拨' and entitytype='InventoryAccount';
update ld_cvadvfilter set comparator='c', value='调入仓库',column_condition='or' 
 where cvid=@cvid  and columnindex=0;
insert into ld_cvadvfilter (cvid,columnindex,columnname,comparator,value,groupid,column_condition)
select @cvid,1,'ld_warehousecondtions:type:type:InventoryAccount_fieldlabel:V','c','调出仓库',1,'' from DUAL
where not EXISTS(select 1 from ld_cvadvfilter where cvid=@cvid and  columnindex=1 and columnname like '%ld_warehousecondtions:type:type:InventoryAccount%');
update ld_cvadvfilter_grouping set condition_expression='0 or 1' where cvid=@cvid;
delimiter;

select cvid into @cvid from ld_customview where viewname='mobileAccounts' and entitytype='mobileAccounts';
delete from ld_cvcolumnlist where cvid=@cvid;
insert into ld_cvcolumnlist (cvid,columnindex,columnname) values(@cvid,0,'ld_account:accountname:accountname:Accounts_客户名称:V' );
insert into ld_cvcolumnlist (cvid,columnindex,columnname) values(@cvid,1,'ld_account:createdtime:createdtime:Accounts_创建时间:D' );
insert into ld_cvcolumnlist (cvid,columnindex,columnname) values(@cvid,2,'ld_account:bill_street:bill_street:Accounts_地址:V' );
delimiter;

update ld_producttoolfield set typeofdata = 'N~O~100' where tabid =  @tabid and tablename = 'ld_inventoryproductrel' and input_type = 2 and columnname = 'profitloss';
delimiter;

select tabid into @tabid from ld_tab where `name` = 'Checks';
update ld_producttoolfield set tablename = 'ld_inventoryproductrel' where tabid =  @tabid and input_type = 1 and edit_permission = 1 and columnname = 'paperquantity';
delimiter;
-- 2015-07-14

select usereportid INTO @uid FROM ld_usereport WHERE name='HighAndNewTechnologyEnterpriseSchedule';
DELETE FROM ld_usereportcolumns WHERE columns LIKE 'u2:last_name:last_name:u2_%' AND Usereportid=@uid;
delimiter;

DROP PROCEDURE IF EXISTS `update_producttoolfield_width`;
delimiter ||
CREATE  PROCEDURE `update_producttoolfield_width`(
)
BEGIN 
		
		set @width=0; 
		select min(width) into @width from ld_producttoolfield where columnname='productname';
		if @width<50 then 
				update ld_producttoolfield set width=22 where defaultcolumn<>1;
				update ld_producttoolfield set width=50 where columnname='productname';
				update ld_producttoolfield set width=35 where columnname='comment';
				update ld_producttoolfield set width=30 where columnname='rmbprice';
		end if;

end ||
delimiter; 

call update_producttoolfield_width();
delimiter; 

update ld_field set masseditable= 1 where uitype=27;

call getTaxInfoForFormula(1); 
select tabid into @tabid from ld_tab where name='PurchaseCashBack';
select producttoolfieldid into @producttoolfieldid from ld_producttoolfield where tabid=@tabid and columnname='taxprice';
select column_string into @column_string from tmp_taxformula;
select letter_string into @letter_string  from tmp_taxformula;
set @formula_column_string=concat('{formulavar:[{''''lettervar'''':''''a'''',''''column'''':''''listprice''''},',@column_string,']}');
set @formula_letter_string=concat('a*(1+(',@letter_string,')/100)');
set @formulsql=concat('insert into ld_producttoolfield_formula (producttoolfieldid,formulastring,columnstring,sequence)  select ', @producttoolfieldid,' ,''',@formula_letter_string,''',''',@formula_column_string,''',',' 1 from dual where not EXISTS(select 1 from ld_producttoolfield_formula where producttoolfieldid=',@producttoolfieldid,')');

PREPARE stmt FROM @formulsql;
EXECUTE stmt;
DEALLOCATE prepare stmt;
delimiter;

select tabid into @tabid from ld_tab where name='PurchaseCashBack';
select producttoolfieldid into @producttoolfieldid from ld_producttoolfield where tabid=@tabid and columnname='listprice';
select column_string into @column_string from tmp_taxformula;
select letter_string into @letter_string  from tmp_taxformula;
set @formula_column_string=concat('{formulavar:[{''''lettervar'''':''''a'''',''''column'''':''''taxprice''''},',@column_string,']}');
set @formula_letter_string=concat('a/(1+(',@letter_string,')/100)');
set @formulsql=concat('insert into ld_producttoolfield_formula (producttoolfieldid,formulastring,columnstring,sequence)  select ', @producttoolfieldid,' ,''',@formula_letter_string,''',''',@formula_column_string,''',',2,' from dual where not EXISTS(select 1 from ld_producttoolfield_formula where producttoolfieldid=',@producttoolfieldid,')');
PREPARE stmt FROM @formulsql;
EXECUTE stmt;
DEALLOCATE prepare stmt;
delimiter;


call getTaxInfoForFormula(1); 
select column_string into @column_string from tmp_taxformula;
select letter_string into @letter_string  from tmp_taxformula;
select nextletterstart into @nextletterstart from tmp_taxformula;

select tabid into @tabid from ld_tab where name='PurchaseCashBack';
SET @sqlletter = CONCAT('select letter into @quantity_letter from tmp_letter limit ',@nextletterstart,',1') ;
PREPARE stmt FROM @sqlletter;
EXECUTE stmt;
DEALLOCATE prepare stmt;

set @nextletterstart=@nextletterstart+1;
SET @sqlletter = CONCAT('select letter into @discount_percent from tmp_letter limit ',@nextletterstart,',1') ;
PREPARE stmt FROM @sqlletter;
EXECUTE stmt;
DEALLOCATE prepare stmt;

set @formula_column_string=concat('{formulavar:[{''''lettervar'''':''''a'''',''''column'''':''''taxprice''''},',@column_string,',{''''lettervar'''':''''',@quantity_letter,'''''',',''''column''''',':','''''quantity''''}',',{''''lettervar'''':''''',@discount_percent,'''''',',''''column''''',':','''''discount_percent''''}]}');
set @formula_letter_string=concat('(a/(1+(',@letter_string,')/100))*',@quantity_letter,'*(1-',@discount_percent,'/100)');

select producttoolfieldid into @producttoolfieldid from ld_producttoolfield where tabid=@tabid and columnname='list_amount';
 set @formulsql=concat('insert into ld_producttoolfield_formula (producttoolfieldid,formulastring,columnstring,sequence)  select ', @producttoolfieldid,' ,''',@formula_letter_string,''',''',@formula_column_string,''',',' 3 from dual where not EXISTS(select 1 from ld_producttoolfield_formula where producttoolfieldid=',@producttoolfieldid,')');
PREPARE stmt FROM @formulsql;
EXECUTE stmt;
DEALLOCATE prepare stmt;
delimiter;


select tabid into @tabid from ld_tab where name='PurchaseCashBack';
select producttoolfieldid into @producttoolfieldid from ld_producttoolfield where tabid=@tabid and columnname='tax_amount';
select column_string into @column_string from tmp_taxformula;
select letter_string into @letter_string  from tmp_taxformula;
insert into ld_producttoolfield_formula (producttoolfieldid,formulastring,columnstring,sequence)
 select @producttoolfieldid,'a*b*(1-c/100)','{formulavar:[{''lettervar'':''a'',''column'':''quantity''},{''lettervar'':''b'',''column'':''taxprice''},{''lettervar'':''c'',''column'':''discount_percent''}]}',4 from dual
 where not EXISTS(select 1 from ld_producttoolfield_formula where producttoolfieldid=@producttoolfieldid);
delimiter;


call getTaxInfoForFormula(1);
select tabid into @tabid from ld_tab where name='PurchaseCashBack';
select producttoolfieldid into @producttoolfieldid from ld_producttoolfield where tabid=@tabid and columnname='tax_total';
select column_string into @column_string from tmp_taxformula;
select letter_string into @letter_string  from tmp_taxformula;

set @formula_column_string=concat('{formulavar:[{''''lettervar'''':''''a'''',''''column'''':''''list_amount''''},',@column_string,']}');
set @formula_letter_string=concat('a*((',@letter_string,')/100)');

set @formulsql=concat('insert into ld_producttoolfield_formula (producttoolfieldid,formulastring,columnstring,sequence)  select ', @producttoolfieldid,' ,''',@formula_letter_string,''',''',@formula_column_string,''',',' 5 from dual where not EXISTS(select 1 from ld_producttoolfield_formula where producttoolfieldid=',@producttoolfieldid,')');
PREPARE stmt FROM @formulsql;
EXECUTE stmt;
DEALLOCATE prepare stmt;
delimiter;
select tabid into @tabid from ld_tab where name='PurchaseCashBack';
select producttoolfieldid into @producttoolfieldid from ld_producttoolfield where tabid=@tabid and presence in(0,2) and  columnname='discount_amount' and tablename='ld_inventoryproductrel';
select column_string into @column_string from tmp_taxformula;
select letter_string into @letter_string  from tmp_taxformula;
insert into ld_producttoolfield_formula (producttoolfieldid,formulastring,columnstring,sequence)
select @producttoolfieldid,'a*b*(c/100)','{formulavar:[{''lettervar'':''a'',''column'':''quantity''},{''lettervar'':''b'',''column'':''taxprice''},{''lettervar'':''c'',''column'':''discount_percent''}]}',8 from dual
where not EXISTS(select 1 from ld_producttoolfield_formula where producttoolfieldid=@producttoolfieldid);
delimiter;
-- 2015-07-15

update ld_field set typeofdata='V~O' where tabid in(select tabid from ld_tab where name='InventoryAccount') and columnname='module';
delimiter;

alter table ld_checks alter column presence set default '盘点中';
delimiter;

SELECT usereportid INTO @uid FROM ld_usereport WHERE name='CashBillSum_SalesOrder';

insert into ld_usereportbasic(id,Usereportid,columns,Defaultvalue,Sequence) 
select '',@uid,'ld_cashbill:cashbilldate:cashbilldate:CashBill_cashbilldate:I','',9  
from dual where not exists(select usereportid from ld_usereportbasic where Usereportid=@uid and Sequence=9);

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 
'zh','OSDRBISGT0','只统计应收款余额大于0的数据','fixedstr' 
from dual where not EXISTS(select 1 from ld_desk where languagetype='zh' and labelbol='OSDRBISGT0' 
and Labeltype='fixedstr');

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 
'en','OSDRBISGT0','Only statistical data receivable balance is greater than 0','fixedstr' 
from dual where not EXISTS(select 1 from ld_desk  where languagetype='en' and labelbol='OSDRBISGT0' 
and Labeltype='fixedstr');
delimiter;

UPDATE ld_desk SET fieldlabel='该{$SalesOrder.SalesOrder}无{$PaymentPlan.PaymentPlan}或已收款！' 
WHERE labelbol='SALESORDERWITHOUTPAYMENTPLAN' AND languagetype='zh' AND Labeltype='jspop';
delimiter;
-- 2015-07-16

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) 
select 'zh','Held','已执行','jspop' 
from dual where not EXISTS(select 1 from ld_desk where languagetype='zh' and labelbol='Held' 
and Labeltype='jspop');

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) 
select 'en','Held','Held','jspop' 
from dual where not EXISTS(select 1 from ld_desk  where languagetype='en' and labelbol='Held' 
and Labeltype='jspop');

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) 
select 'zh','NOHeld','未执行','jspop' 
from dual where not EXISTS(select 1 from ld_desk where languagetype='zh' and labelbol='NOHeld' 
and Labeltype='jspop');

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) 
select 'en','NOHeld','No Held','jspop' 
from dual where not EXISTS(select 1 from ld_desk  where languagetype='en' and labelbol='NOHeld' 
and Labeltype='jspop');

UPDATE ld_field SET quickcreate=1 WHERE tabid=(SELECT tabid FROM ld_tab WHERE name='Accounts') AND columnname='smcreatorid';
delimiter;

select tabid into @tabid from ld_tab where name='cashback';
select producttoolfieldid into @producttoolfieldid from ld_producttoolfield where tabid=@tabid and columnname='taxprice';
select column_string into @column_string from tmp_taxformula;
select letter_string into @letter_string  from tmp_taxformula;
set @formula_column_string=concat('{formulavar:[{''''lettervar'''':''''a'''',''''column'''':''''listprice''''},',@column_string,']}');
set @formula_letter_string=concat('a*(1+(',@letter_string,')/100)');
set @formulsql=concat('insert into ld_producttoolfield_formula (producttoolfieldid,formulastring,columnstring,sequence)  select ', @producttoolfieldid,' ,''',@formula_letter_string,''',''',@formula_column_string,''',',' 1 from dual where not EXISTS(select 1 from ld_producttoolfield_formula where producttoolfieldid=',@producttoolfieldid,')');

PREPARE stmt FROM @formulsql;
EXECUTE stmt;
DEALLOCATE prepare stmt;
delimiter;

select tabid into @tabid from ld_tab where name='cashback';
select producttoolfieldid into @producttoolfieldid from ld_producttoolfield where tabid=@tabid and columnname='listprice';
select column_string into @column_string from tmp_taxformula;
select letter_string into @letter_string  from tmp_taxformula;
set @formula_column_string=concat('{formulavar:[{''''lettervar'''':''''a'''',''''column'''':''''taxprice''''},',@column_string,']}');
set @formula_letter_string=concat('a/(1+(',@letter_string,')/100)');
set @formulsql=concat('insert into ld_producttoolfield_formula (producttoolfieldid,formulastring,columnstring,sequence)  select ', @producttoolfieldid,' ,''',@formula_letter_string,''',''',@formula_column_string,''',',2,' from dual where not EXISTS(select 1 from ld_producttoolfield_formula where producttoolfieldid=',@producttoolfieldid,')');
PREPARE stmt FROM @formulsql;
EXECUTE stmt;
DEALLOCATE prepare stmt;
delimiter;


call getTaxInfoForFormula(1); 
select column_string into @column_string from tmp_taxformula;
select letter_string into @letter_string  from tmp_taxformula;
select nextletterstart into @nextletterstart from tmp_taxformula;

select tabid into @tabid from ld_tab where name='cashback';
SET @sqlletter = CONCAT('select letter into @quantity_letter from tmp_letter limit ',@nextletterstart,',1') ;
PREPARE stmt FROM @sqlletter;
EXECUTE stmt;
DEALLOCATE prepare stmt;

set @nextletterstart=@nextletterstart+1;
SET @sqlletter = CONCAT('select letter into @discount_percent from tmp_letter limit ',@nextletterstart,',1') ;
PREPARE stmt FROM @sqlletter;
EXECUTE stmt;
DEALLOCATE prepare stmt;

set @formula_column_string=concat('{formulavar:[{''''lettervar'''':''''a'''',''''column'''':''''taxprice''''},',@column_string,',{''''lettervar'''':''''',@quantity_letter,'''''',',''''column''''',':','''''quantity''''}',',{''''lettervar'''':''''',@discount_percent,'''''',',''''column''''',':','''''discount_percent''''}]}');
set @formula_letter_string=concat('(a/(1+(',@letter_string,')/100))*',@quantity_letter,'*(1-',@discount_percent,'/100)');

select producttoolfieldid into @producttoolfieldid from ld_producttoolfield where tabid=@tabid and columnname='list_amount';
 set @formulsql=concat('insert into ld_producttoolfield_formula (producttoolfieldid,formulastring,columnstring,sequence)  select ', @producttoolfieldid,' ,''',@formula_letter_string,''',''',@formula_column_string,''',',' 3 from dual where not EXISTS(select 1 from ld_producttoolfield_formula where producttoolfieldid=',@producttoolfieldid,')');
PREPARE stmt FROM @formulsql;
EXECUTE stmt;
DEALLOCATE prepare stmt;
delimiter;


select tabid into @tabid from ld_tab where name='cashback';
select producttoolfieldid into @producttoolfieldid from ld_producttoolfield where tabid=@tabid and columnname='tax_amount';
select column_string into @column_string from tmp_taxformula;
select letter_string into @letter_string  from tmp_taxformula;
insert into ld_producttoolfield_formula (producttoolfieldid,formulastring,columnstring,sequence)
select @producttoolfieldid,'a*b*(1-c/100)','{formulavar:[{''lettervar'':''a'',''column'':''quantity''},{''lettervar'':''b'',''column'':''taxprice''},{''lettervar'':''c'',''column'':''discount_percent''}]}',4 from dual
where not EXISTS(select 1 from ld_producttoolfield_formula where producttoolfieldid=@producttoolfieldid);
delimiter;


call getTaxInfoForFormula(1);
select tabid into @tabid from ld_tab where name='cashback';
select producttoolfieldid into @producttoolfieldid from ld_producttoolfield where tabid=@tabid and columnname='tax_total';
select column_string into @column_string from tmp_taxformula;
select letter_string into @letter_string  from tmp_taxformula;

set @formula_column_string=concat('{formulavar:[{''''lettervar'''':''''a'''',''''column'''':''''list_amount''''},',@column_string,']}');
set @formula_letter_string=concat('a*((',@letter_string,')/100)');

set @formulsql=concat('insert into ld_producttoolfield_formula (producttoolfieldid,formulastring,columnstring,sequence)  select ', @producttoolfieldid,' ,''',@formula_letter_string,''',''',@formula_column_string,''',',' 5 from dual where not EXISTS(select 1 from ld_producttoolfield_formula where producttoolfieldid=',@producttoolfieldid,')');
PREPARE stmt FROM @formulsql;
EXECUTE stmt;
DEALLOCATE prepare stmt;
delimiter;
select tabid into @tabid from ld_tab where name='cashback';
select producttoolfieldid into @producttoolfieldid from ld_producttoolfield where tabid=@tabid and presence in(0,2) and  columnname='discount_amount' and tablename='ld_inventoryproductrel';
select column_string into @column_string from tmp_taxformula;
select letter_string into @letter_string  from tmp_taxformula;
insert into ld_producttoolfield_formula (producttoolfieldid,formulastring,columnstring,sequence)
select @producttoolfieldid,'a*b*(c/100)','{formulavar:[{''lettervar'':''a'',''column'':''quantity''},{''lettervar'':''b'',''column'':''taxprice''},{''lettervar'':''c'',''column'':''discount_percent''}]}',8 from dual
where not EXISTS(select 1 from ld_producttoolfield_formula where producttoolfieldid=@producttoolfieldid);
delimiter;
-- 2015-07-17

update ld_field set masseditable=0 where columnname in ('approvestatus','approveby');

DROP PROCEDURE IF EXISTS `update_producttoolfield_width`;
delimiter ||
CREATE  PROCEDURE `update_producttoolfield_width`(
)
BEGIN 
		
		set @width=0; 
		select min(width) into @width from ld_producttoolfield where columnname='productname';
		if @width<50 then 
				update ld_producttoolfield set width=22 where defaultcolumn<>1;
				update ld_producttoolfield set width=50 where columnname='productname';
				update ld_producttoolfield set width=35 where columnname='comment';
				update ld_producttoolfield set width=30 where columnname='rmbprice';
		end if;

end ||
delimiter; 

call update_producttoolfield_width();
delimiter; 

INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype) SELECT 'zh','BANKNOTTODELETE',
'银行账户已经初始化，不允许删除!','fixedstr' 
FROM DUAL WHERE NOT EXISTS(SELECT 1 FROM ld_desk WHERE languagetype='zh' AND labelbol='BANKNOTTODELETE' AND Labeltype='fixedstr');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype) SELECT 'en','BANKNOTTODELETE',
'Bank account has been initialized, not allowed to delete.','fixedstr' 
FROM DUAL WHERE NOT EXISTS(SELECT 1 FROM ld_desk  WHERE languagetype='en' AND labelbol='BANKNOTTODELETE' AND Labeltype='fixedstr');
delimiter;

INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype) SELECT 'zh','MASSDELBANKNOTTODELETE',
'单据[%s]%s不成功！原因：银行账户已经初始化!','fixedstr' 
FROM DUAL WHERE NOT EXISTS(SELECT 1 FROM ld_desk WHERE languagetype='zh' AND labelbol='MASSDELBANKNOTTODELETE' AND Labeltype='fixedstr');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype) SELECT 'en','MASSDELBANKNOTTODELETE',
'Document[%s] %s no success! The reason: Bank account has been initialized!','fixedstr' 
FROM DUAL WHERE NOT EXISTS(SELECT 1 FROM ld_desk  WHERE languagetype='en' AND labelbol='MASSDELBANKNOTTODELETE' AND Labeltype='fixedstr');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) 
select 'zh','bnoempty','{$SendCashBill.bankaccountsetid}不能为空','jspop' 
from dual where not EXISTS(select 1 from ld_desk where languagetype='zh' and labelbol='bnoempty' 
and Labeltype='jspop');

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) 
select 'en','bnoempty','{$SendCashBill.bankaccountsetid} no empty','jspop' 
from dual where not EXISTS(select 1 from ld_desk  where languagetype='en' and labelbol='bnoempty' 
and Labeltype='jspop');
delimiter;

select cvid into @cvid from ld_customview where viewname='mobileServiceContracts' and entitytype='mobileServiceContracts';
delete from ld_cvcolumnlist where cvid=@cvid;
insert into ld_cvcolumnlist (cvid,columnindex,columnname) values(@cvid,0,'ld_servicecontracts:contract_no:contract_no:ServiceContracts_编号:V' );
insert into ld_cvcolumnlist (cvid,columnindex,columnname) values(@cvid,1,'ld_servicecontracts:subject:subject:ServiceContracts_主题:V' );
insert into ld_cvcolumnlist (cvid,columnindex,columnname) values(@cvid,2,'ld_servicecontracts:accountid:account_id:ServiceContracts_客户:I' );
insert into ld_cvcolumnlist (cvid,columnindex,columnname) values(@cvid,3,'ld_servicecontracts:total:hdnGrandTotal:ServiceContracts_合计:N' );
insert into ld_cvcolumnlist (cvid,columnindex,columnname) values(@cvid,4,'ld_servicecontracts:due_date:due_date:ServiceContracts_签约日期:D' );
delimiter;
-- 2015-07-20

update ld_systems_deploy set sequence=101 where deploy_type=73;
update ld_systems_deploy set sequence=102 where deploy_type=68;
update ld_systems_deploy set sequence=103 where deploy_type=66;
update ld_systems_deploy set sequence=104 where deploy_type=65;
update ld_systems_deploy set sequence=105 where deploy_type=13;
update ld_systems_deploy set sequence=106 where deploy_type=14;
update ld_systems_deploy set sequence=107 where deploy_type=67;
update ld_systems_deploy set sequence=108 where deploy_type=49;
update ld_systems_deploy set sequence=109 where deploy_type=33;
update ld_systems_deploy set sequence=110 where deploy_type=72;

update ld_systems_deploy set sequence=111 where deploy_type=61;
update ld_systems_deploy set sequence=112 where deploy_type=69;
update ld_systems_deploy set sequence=113 where deploy_type=57;
update ld_systems_deploy set sequence=114 where deploy_type=37;
update ld_systems_deploy set sequence=115 where deploy_type=38;
update ld_systems_deploy set sequence=116 where deploy_type=56;
update ld_systems_deploy set sequence=117 where deploy_type=63;
update ld_systems_deploy set sequence=118 where deploy_type=12;
update ld_systems_deploy set sequence=119 where deploy_type=1;
update ld_systems_deploy set sequence=120 where deploy_type=58;

update ld_systems_deploy set sequence=121 where deploy_type=59;
update ld_systems_deploy set sequence=122 where deploy_type=15;
update ld_systems_deploy set sequence=123 where deploy_type=20;

update ld_systems_deploy set sequence=124 where deploy_type=10;
update ld_systems_deploy set sequence=125 where deploy_type=48;
update ld_systems_deploy set sequence=126 where deploy_type=52;
update ld_systems_deploy set sequence=127 where deploy_type=42;
update ld_systems_deploy set sequence=128 where deploy_type=43;
update ld_systems_deploy set sequence=129 where deploy_type=34;
update ld_systems_deploy set sequence=130 where deploy_type=54;

update ld_systems_deploy set sequence=131 where deploy_type=25;
update ld_systems_deploy set sequence=132 where deploy_type=26;
update ld_systems_deploy set sequence=133 where deploy_type=25;
update ld_systems_deploy set sequence=134 where deploy_type=32;
update ld_systems_deploy set sequence=135 where deploy_type=35;
update ld_systems_deploy set sequence=136 where deploy_type=55;
update ld_systems_deploy set sequence=137 where deploy_type=60;


update ld_systems_deploy set sequence=201 where deploy_type=70;
update ld_systems_deploy set sequence=202 where deploy_type=71;
update ld_systems_deploy set sequence=203 where deploy_type=11;
update ld_systems_deploy set sequence=204 where deploy_type=16;
update ld_systems_deploy set sequence=205 where deploy_type=29;
update ld_systems_deploy set sequence=206 where deploy_type=3;
update ld_systems_deploy set sequence=207 where deploy_type=47;
update ld_systems_deploy set sequence=208 where deploy_type=8;
update ld_systems_deploy set sequence=209 where deploy_type=4;
update ld_systems_deploy set sequence=210 where deploy_type=50;
update ld_systems_deploy set sequence=211 where deploy_type=5;
update ld_systems_deploy set sequence=212 where deploy_type=30;
update ld_systems_deploy set sequence=213 where deploy_type=31;
update ld_systems_deploy set sequence=214 where deploy_type=9;
update ld_systems_deploy set sequence=215 where deploy_type=36;
update ld_systems_deploy set sequence=216 where deploy_type=27;
update ld_systems_deploy set sequence=217 where deploy_type=28;
update ld_systems_deploy set sequence=218 where deploy_type=6;
update ld_systems_deploy set sequence=219 where deploy_type=22;
update ld_systems_deploy set sequence=220 where deploy_type=23;
update ld_systems_deploy set sequence=221 where deploy_type=17;

update ld_systems_deploy set sequence=301 where deploy_type=51;
update ld_systems_deploy set sequence=302 where deploy_type=18;
update ld_systems_deploy set sequence=303 where deploy_type=24;
update ld_systems_deploy set sequence=304 where deploy_type=53;
update ld_systems_deploy set sequence=305 where deploy_type=40;
update ld_systems_deploy set sequence=306 where deploy_type=41;
update ld_systems_deploy set sequence=307 where deploy_type=7;
update ld_systems_deploy set sequence=308 where deploy_type=62;
update ld_systems_deploy set sequence=309 where deploy_type=21;

update ld_systems_deploy set sequence=150 where deploy_type=74;
select sequence into @seq from ld_systems_deploy where deploy_type=68;
update ld_systems_deploy set sequence=sequence+1 where sequence>@seq and sequence<200 ;
update ld_systems_deploy set sequence=@seq+1 where deploy_type=74;
set @i=100;
update ld_systems_deploy set sequence=(@i:=@i+1) where sequence<200 order by sequence;
delimiter;

UPDATE ld_systems_deploy SET deploy_value=1 WHERE deploy_type=74;
update ld_desk set fieldlabel='设置关联基础资料时是否在所有用户的数据中进行查询' where languagetype='zh' and labelbol='AFMWWAOTDCTSB';
delimiter;

update ld_customview set sequence=ifnull(sequence,0)+10 where entitytype='PurchaseInvoice';
update ld_customview set sequence=0 where entitytype='PurchaseInvoice' and viewname='All';
set @i=0;
update ld_customview set sequence=(@i:=@i+1) where entitytype='PurchaseInvoice' order by sequence;
delimiter;

update ld_inventorytaxinfo set deleted=@tax2_delete where  taxname='tax2';

select tabid into @tabid from ld_tab where `name`='PurchaseOrder';
select tabid into @tabid1 from ld_tab where `name`='VendorContactRecords';
delete from ld_relatedlists where tabid=@tabid and `name`='get_VendorContactRecords';
delete from ld_quickactions where tabid=@tabid and related_tabid=@tabid1;
delimiter;

update ld_desk set fieldlabel='确定要删除选定的' where labelbol='REMOVEWILLDELETEOTHER' and languagetype='zh' and Labeltype='jspop';

select actionid into @actionid from ld_actionmapping where actionname = 'Import';
insert into ld_profileallpermission(tabid,operation)
select 16,@actionid from dual where not EXISTS
(select 1 from ld_profileallpermission where tabid = 16 and operation = @actionid);
delimiter;

select tabid into @tabid from ld_tab where name='ServiceContracts';
select producttoolfieldid into @producttoolfieldid from ld_producttoolfield where tabid=@tabid and columnname='servicecontracts_end_date';
update ld_producttoolfield_formula set formulastring='date_add(a,365,day)' where producttoolfieldid=@producttoolfieldid;

update ld_inventoryproductrel set discount_total = listprice where (discount_percent = 0 or discount_percent is NULL) and (discount_amount =0 or discount_amount is NULL);
delimiter;
update ld_inventoryproductrel set tax_total = discount_total*((tax1+tax2+tax3)/100) where tax_total = 0;
delimiter;
update ld_inventoryproductrel set tax_amount = discount_total + ifnull(tax_total,0) where (tax_amount = 0 or tax_amount is NULL);
delimiter;
update ld_desk set fieldlabel = '请在控制面板>单据分录自定义中设置日期、时间字段' where labelbol = 'DTPGTTPDCFS' and languagetype = 'zh' and Labeltype = 'fixedstr';
delimiter;
update ld_desk set fieldlabel = 'please in the control panel > document entry in the definition of the set date, time field' where labelbol = 'DTPGTTPDCFS' and languagetype = 'en' and Labeltype = 'fixedstr';
delimiter;

select usereportid into @id from ld_usereport where name='SendCashBillSum_PurchaseOrder';
DELETE FROM ld_usereportbasic where Usereportid=@id AND columns like '%ld_vendorpurchaseorder:vendorname:vendor_id:PurchaseOrder_vendorname%';
insert into ld_usereportbasic(Usereportid,columns,Defaultvalue,Sequence) 
select @id,'ld_vendorpurchaseorder:vendorname:vendor_id:PurchaseOrder_vendorname:I','',6;
delimiter;
-- 2015-07-21

select tabid into @tabid from ld_tab where `name`='CashBack';
select max(sequence) into @seq from  ld_blocks where tabid=@tabid;
update ld_blocks set sequence=@seq+1 where tabid=@tabid and blocklabel='LBL_DESCRIPTION_INFORMATION';
set @i=0;
update ld_blocks set sequence=(@i:=@i+1) where tabid=@tabid order by sequence;
update ld_field set masseditable=0 where tabid=@tabid;
update ld_field set masseditable=0 where columnname='smownerid';
delimiter;

select tabid into @tabid from ld_tab where `name`='PurchaseCashBack';
update ld_field set masseditable=0 where tabid=@tabid;
delimiter;

update ld_desk set fieldlabel='确定要删除选定的' where labelbol='DELETESUPPLIERSWILLDELETEPURCHASEORDERS' and languagetype='zh';
update ld_desk set fieldlabel='Are you sure you want to delete the selected' where labelbol='DELETESUPPLIERSWILLDELETEPURCHASEORDERS' and languagetype='en';
update ld_desk set fieldlabel='Are you sure you want to delete the selected ' where labelbol='REMOVEWILLDELETEOTHER' and languagetype='en' and Labeltype='jspop';

update ld_settings_field set active=1 where `name`='LBL_AUDIT_TRAIL';

select tabid into @tabid from ld_tab where `name`='ContactRecords';
update ld_field set quickcreatesequence=quickcreatesequence+30 where tabid=@tabid and presence<>1 and quickcreate=0;
update ld_field set quickcreatesequence=1 where tabid=@tabid and columnname='subject';
update ld_field set quickcreatesequence=2 where tabid=@tabid and columnname='contactrecordtype';
update ld_field set quickcreatesequence=3 where tabid=@tabid and columnname='contactdate';
update ld_field set quickcreatesequence=4 where tabid=@tabid and columnname='nextcontactdate';
update ld_field set quickcreatesequence=5 where tabid=@tabid and columnname='accountid';
update ld_field set quickcreatesequence=6 where tabid=@tabid and columnname='contactid';
update ld_field set quickcreatesequence=7 where tabid=@tabid and columnname='potentialid';
update ld_field set quickcreatesequence=8 where tabid=@tabid and columnname='smownerid';
update ld_field set quickcreatesequence=9 where tabid=@tabid and columnname='content';
set @i=0;
update ld_field set quickcreatesequence=(@i:=@i+1) where tabid=@tabid and presence<>1 and quickcreate=0 order by quickcreatesequence;
delimiter;

update ld_templatesrole set roleid=profileid where roleid like 'H%';
update ld_systems_deploy set deploy_value=1,description='有关联单据时是否允许删除客户。1:不允许，0:允许' where deploy_type=69;
update ld_systems_deploy set deploy_value=1 where deploy_type=57 and not exists (select 1 from ld_salesorder);

select tabid into @tabid from ld_tab where `name`='ServiceContracts';
select block into @blockid from ld_field where tabid=@tabid and columnname='contactid';
set @tablename='ld_servicecontracts';
set @columnname='potentialid';
set @fieldname='potential_id';
set @zh='销售机会';
set @en='销售机会';
set @uitype=76;

select sequence into @seq from ld_field where tabid=@tabid and columnname='contactid';
update ld_field set sequence=sequence+2 where tabid=@tabid and block=@blockid and sequence>@seq; 

select max(fieldid) into @fieldid from ld_field;
insert into ld_field(tabid,fieldid,columnname,tablename,generatedtype,uitype,fieldname,fieldlabel,readonly,presence,defaultvalue,maximumlength,sequence,block,displaytype,typeofdata,quickcreate,quickcreatesequence,info_type,masseditable,helpinfo,fieldonly)
select @tabid,@fieldid+1,@columnname,@tablename,1,@uitype,@fieldname,@zh,1,2,NULL,100,@seq+1,@blockid,1,'I~O',3,NULL,'BAS',1,NULL,0 from dual 
where not exists (select 1 from ld_field where tabid=@tabid and tablename=@tablename and columnname=@columnname);

update ld_field_seq set id=(select max(fieldid) from ld_field); 
set @i=0;
update ld_field set sequence=(@i:=@i+1) where tabid=@tabid and block=@blockid order by sequence;

select fieldid into @fieldid from ld_field where tabid=@tabid and columnname=@columnname;
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'zh','ld_field',@tabid,@fieldid,@zh from dual 
where not exists (select 1 from ld_tranlabel  where languagetype = 'zh' and trantable ='ld_field' and tabid = @tabid and relateid=@fieldid);

insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'en','ld_field',@tabid,@fieldid,@en from dual 
where not exists (select 1 from ld_tranlabel  where languagetype = 'en' and trantable ='ld_field' and tabid = @tabid and relateid=@fieldid);


call AddColumn(@tablename,@columnname,'int','19',null);
delimiter;

select tabid into @tabid from ld_tab where `name`='HelpDesk';
select block into @blockid from ld_field where tabid=@tabid and columnname='contactid';
set @tablename='ld_troubletickets';
set @columnname='potentialid';
set @fieldname='potential_id';
set @zh='销售机会';
set @en='销售机会';
set @uitype=76;

select sequence into @seq from ld_field where tabid=@tabid and columnname='contactid';
update ld_field set sequence=sequence+2 where tabid=@tabid and block=@blockid and sequence>@seq; 

select max(fieldid) into @fieldid from ld_field;
insert into ld_field(tabid,fieldid,columnname,tablename,generatedtype,uitype,fieldname,fieldlabel,readonly,presence,defaultvalue,maximumlength,sequence,block,displaytype,typeofdata,quickcreate,quickcreatesequence,info_type,masseditable,helpinfo,fieldonly)
select @tabid,@fieldid+1,@columnname,@tablename,1,@uitype,@fieldname,@zh,1,2,NULL,100,@seq+1,@blockid,1,'I~O',3,NULL,'BAS',1,NULL,0 from dual 
where not exists (select 1 from ld_field where tabid=@tabid and tablename=@tablename and columnname=@columnname);

update ld_field_seq set id=(select max(fieldid) from ld_field); 

set @i=0;
update ld_field set sequence=1000 where tabid=@tabid and columnname='ticket_no';
update ld_field set sequence=(@i:=@i+1) where tabid=@tabid and block=@blockid order by sequence;

select fieldid into @fieldid from ld_field where tabid=@tabid and columnname=@columnname;
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'zh','ld_field',@tabid,@fieldid,@zh from dual 
where not exists (select 1 from ld_tranlabel  where languagetype = 'zh' and trantable ='ld_field' and tabid = @tabid and relateid=@fieldid);

insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'en','ld_field',@tabid,@fieldid,@en from dual 
where not exists (select 1 from ld_tranlabel  where languagetype = 'en' and trantable ='ld_field' and tabid = @tabid and relateid=@fieldid);


call AddColumn(@tablename,@columnname,'int','19',null);
delimiter;

select usereportid into @id from ld_usereport where name='Performancestatisticscollection';
SELECT max(Sequence)+1 into @Sequence FROM ld_usereportcolumns WHERE usereportid=@id;
insert into ld_usereportcolumns(id,Usereportid,columns,Sequence,columnshow,realcolumns,realencolumns) 
select '', @id, 'ld_cashbill:description:description:CashBill_description:V', 
@Sequence, 1, 'ld_cashbill:description:description:CashBill_备注:V','ld_cashbill:description:description:CashBill_description:V'   
from dual where not exists(select 1 from ld_usereportcolumns 
where Usereportid=@id and realcolumns like 'ld_cashbill:description:description:CashBill_%');
delimiter;

insert into ld_profileallpermission(tabid,operation)
select @tabid,3 from dual where not exists(select 1 from ld_profileallpermission where tabid = @tabid and operation = 3);
delimiter;
insert into ld_profileallpermission(tabid,operation)
select @tabid,11 from dual where not exists(select 1 from ld_profileallpermission where tabid = @tabid and operation = 11);
delimiter;
insert into ld_profileallpermission(tabid,operation)
select @tabid,1 from dual where not exists(select 1 from ld_profileallpermission where tabid = @tabid and operation = 1);
delimiter;
insert into ld_profileallpermission(tabid,operation)
select @tabid,13 from dual where not exists(select 1 from ld_profileallpermission where tabid = @tabid and operation = 13);
delimiter;
insert into ld_profileallpermission(tabid,operation)
select @tabid,12 from dual where not exists(select 1 from ld_profileallpermission where tabid = @tabid and operation = 12);
delimiter;
insert into ld_profileallpermission(tabid,operation)
select @tabid,2 from dual where not exists(select 1 from ld_profileallpermission where tabid = @tabid and operation = 2);
delimiter;
insert into ld_profileallpermission(tabid,operation)
select @tabid,6 from dual where not exists(select 1 from ld_profileallpermission where tabid = @tabid and operation = 6);
delimiter;

update ld_field  set displaytype=1 where tabid=29   and columnname='approvestatus';
delimiter;

SELECT id INTO @id FROM ld_relatedlists_seq;
SELECT tabid INTO @tabid FROM ld_tab WHERE NAME = 'Accounts';
SELECT MAX(sequence) INTO @sequence FROM ld_relatedlists WHERE tabid = @tabid;
INSERT INTO ld_relatedlists(relation_id,tabid,related_tabid,NAME,sequence,label,actions)
SELECT @id+1,@tabid,0,'get_singin',@sequence+1,'Singin',''
FROM DUAL WHERE NOT EXISTS(SELECT 1 FROM ld_relatedlists  WHERE tabid = @tabid AND NAME = 'get_singin');
UPDATE ld_relatedlists_seq SET id = (SELECT MAX(relation_id) FROM ld_relatedlists);
delimiter;

INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype) SELECT 'zh','Singin','签到记录','fixedstr' FROM DUAL
WHERE NOT EXISTS(SELECT 1 FROM ld_desk  WHERE languagetype='zh' AND labelbol='Singin' AND Labeltype='fixedstr');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype) SELECT 'en','Singin','Singin record','fixedstr' FROM DUAL
WHERE NOT EXISTS(SELECT 1 FROM ld_desk  WHERE languagetype='en' AND labelbol='Singin' AND Labeltype='fixedstr');
delimiter;

INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype) SELECT 'zh','SINGINADDRESS','签到地点','fixedstr' FROM DUAL
WHERE NOT EXISTS(SELECT 1 FROM ld_desk  WHERE languagetype='zh' AND labelbol='SINGINADDRESS' AND Labeltype='fixedstr');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype) SELECT 'en','SINGINADDRESS','Sign in place','fixedstr' FROM DUAL
WHERE NOT EXISTS(SELECT 1 FROM ld_desk  WHERE languagetype='en' AND labelbol='SINGINADDRESS' AND Labeltype='fixedstr');
delimiter;

INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype) SELECT 'zh','SINGINREMARKS','签到说明','fixedstr' FROM DUAL
WHERE NOT EXISTS(SELECT 1 FROM ld_desk  WHERE languagetype='zh' AND labelbol='SINGINREMARKS' AND Labeltype='fixedstr');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype) SELECT 'en','SINGINREMARKS','Sign Remarks','fixedstr' FROM DUAL
WHERE NOT EXISTS(SELECT 1 FROM ld_desk  WHERE languagetype='en' AND labelbol='SINGINREMARKS' AND Labeltype='fixedstr');
delimiter;

INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype) SELECT 'zh','SIGNINACCOUNT','签到人','fixedstr' FROM DUAL
WHERE NOT EXISTS(SELECT 1 FROM ld_desk  WHERE languagetype='zh' AND labelbol='SIGNINACCOUNT' AND Labeltype='fixedstr');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype) SELECT 'en','SIGNINACCOUNT','Sign Account','fixedstr' FROM DUAL
WHERE NOT EXISTS(SELECT 1 FROM ld_desk  WHERE languagetype='en' AND labelbol='SIGNINACCOUNT' AND Labeltype='fixedstr');
delimiter;

INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype) SELECT 'zh','SIGNTIME','签到时间','fixedstr' FROM DUAL
WHERE NOT EXISTS(SELECT 1 FROM ld_desk  WHERE languagetype='zh' AND labelbol='SIGNTIME' AND Labeltype='fixedstr');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype) SELECT 'en','SIGNTIME','Sign Time','fixedstr' FROM DUAL
WHERE NOT EXISTS(SELECT 1 FROM ld_desk  WHERE languagetype='en' AND labelbol='SIGNTIME' AND Labeltype='fixedstr');
delimiter;

INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype) SELECT 'zh','ERRORDISTANCE','误差距离(米)','fixedstr' FROM DUAL
WHERE NOT EXISTS(SELECT 1 FROM ld_desk  WHERE languagetype='zh' AND labelbol='ERRORDISTANCE' AND Labeltype='fixedstr');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype) SELECT 'en','ERRORDISTANCE','Error distance (meter)','fixedstr' FROM DUAL
WHERE NOT EXISTS(SELECT 1 FROM ld_desk  WHERE languagetype='en' AND labelbol='ERRORDISTANCE' AND Labeltype='fixedstr');
delimiter;
-- 2015-07-22

update ld_relatedlists set sequence=sequence+50 where tabid=6;
update ld_relatedlists set sequence=1 where tabid=6 and `name`='get_WorkReport';
update ld_relatedlists set sequence=2 where tabid=6 and `name`='get_singin';
update ld_relatedlists set sequence=3 where tabid=6 and `name`='get_balanceofaccount';
set @i=0;
update ld_relatedlists set sequence=(@i:=@i+1) where tabid=6 order by sequence;
delimiter;

update ld_tab set printtab=1 where `name` in ('ServiceContracts','Campaigns','Potentials','ProjectMilestone','Accounts');
update ld_tab set printtab=1 where `name` in ('CashBill','SendCashBill','Vendors','VendorContact','=VendorContactRecords');
update ld_tab set printtab=1 where `name` in ('ContactRecords','PublicAnnouncement','Contacts','ContactRecords');
update ld_quickactions set presence=0 where related_tabid='-5';

select tabid into @tabid from ld_tab where `name`='Accounts';
select max(sequence) into @seq from ld_quickactions where tabid=@tabid;
insert into ld_quickactions(tabid,related_tabid,sequence,presence,label)
select @tabid,'-5',@seq+1,0,'打印工具' from dual 
where not exists (select 1 from ld_quickactions where tabid=@tabid and related_tabid='-5');
delimiter;

select tabid into @tabid from ld_tab where `name`='Contacts';
select max(sequence) into @seq from ld_quickactions where tabid=@tabid;
insert into ld_quickactions(tabid,related_tabid,sequence,presence,label)
select @tabid,'-5',@seq+1,0,'打印工具' from dual 
where not exists (select 1 from ld_quickactions where tabid=@tabid and related_tabid='-5');
delimiter;


select tabid into @tabid from ld_tab where `name`='ContactRecords';
select max(sequence) into @seq from ld_quickactions where tabid=@tabid;
insert into ld_quickactions(tabid,related_tabid,sequence,presence,label)
select @tabid,'-5',@seq+1,0,'打印工具' from dual 
where not exists (select 1 from ld_quickactions where tabid=@tabid and related_tabid='-5');
delimiter;


select tabid into @tabid from ld_tab where `name`='Vendors';
select max(sequence) into @seq from ld_quickactions where tabid=@tabid;
insert into ld_quickactions(tabid,related_tabid,sequence,presence,label)
select @tabid,'-5',@seq+1,0,'打印工具' from dual 
where not exists (select 1 from ld_quickactions where tabid=@tabid and related_tabid='-5');
delimiter;

select tabid into @tabid from ld_tab where `name`='VendorContact';
select max(sequence) into @seq from ld_quickactions where tabid=@tabid;
insert into ld_quickactions(tabid,related_tabid,sequence,presence,label)
select @tabid,'-5',@seq+1,0,'打印工具' from dual 
where not exists (select 1 from ld_quickactions where tabid=@tabid and related_tabid='-5');
delimiter;

select tabid into @tabid from ld_tab where `name`='VendorContactRecords';
select max(sequence) into @seq from ld_quickactions where tabid=@tabid;
insert into ld_quickactions(tabid,related_tabid,sequence,presence,label)
select @tabid,'-5',@seq+1,0,'打印工具' from dual 
where not exists (select 1 from ld_quickactions where tabid=@tabid and related_tabid='-5');

select tabid into @tabid from ld_tab where `name`='PublicAnnouncement';
select max(sequence) into @seq from ld_quickactions where tabid=@tabid;
insert into ld_quickactions(tabid,related_tabid,sequence,presence,label)
select @tabid,'-5',@seq+1,0,'打印工具' from dual 
where not exists (select 1 from ld_quickactions where tabid=@tabid and related_tabid='-5');

select tabid into @tabid from ld_tab where `name`='PublicAnnouncement';
select max(sequence) into @seq from ld_quickactions where tabid=@tabid;
insert into ld_quickactions(tabid,related_tabid,sequence,presence,label)
select @tabid,'-5',@seq+1,0,'打印工具' from dual 
where not exists (select 1 from ld_quickactions where tabid=@tabid and related_tabid='-5');

DELETE FROM ld_desk WHERE labelbol='DELETESUPPLIERSWILLDELETEPURCHASEORDERS' AND labeltype='jspop';
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) 
select 'zh','DELETESUPPLIERSWILLDELETEPURCHASEORDERS','确定要删除选定的','jspop' 
from dual where not EXISTS(select 1 from ld_desk where languagetype='zh' and labelbol='DELETESUPPLIERSWILLDELETEPURCHASEORDERS' 
and Labeltype='jspop');

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) 
select 'en','DELETESUPPLIERSWILLDELETEPURCHASEORDERS','You sure you want to delete the selected','jspop' 
from dual where not EXISTS(select 1 from ld_desk  where languagetype='en' and labelbol='DELETESUPPLIERSWILLDELETEPURCHASEORDERS' 
and Labeltype='jspop');

select usereportid into @id from ld_usereport where name='Salesforecastandanalysistable';
insert into ld_usereportcolumns(id,Usereportid,columns,Sequence,columnshow,realcolumns,realencolumns) 
select '', @id, 'ld_potential:potential_no:potential_no:potentials_potential_no:V', 
6, 1, 'ld_potential:potential_no:potential_no:Potentials_销售编号:V',
'ld_potential:potential_no:potential_no:Potentials_potential no:V'   
from dual where not exists(select 1 from ld_usereportcolumns 
where Usereportid=@id and realcolumns like 'ld_potential:potential_no:potential_no:Potentials_%');
delimiter;
UPDATE ld_tab SET printtab=0 WHERE name in ('PublicAnnouncement','LessionPlan');
delimiter;
select tabid into @tabid from ld_tab where `name`='PurchaseCashBack';
select max(sequence) into @seq from ld_quickactions where tabid=@tabid;
insert into ld_quickactions(tabid,related_tabid,sequence,presence,label)
select @tabid,'-5',@seq+1,0,'打印工具' from dual
where not exists (select 1 from ld_quickactions where tabid=@tabid and related_tabid='-5'); 
update ld_tab set printtab=1 where `name` in ('PurchaseCashBack');
delimiter;

update ld_producttoolfield set defaultcolumn = 2 where input_type=0 and columnname='total' and newline = 1;
delimiter;
update ld_producttoolfield set defaultcolumn = 3 where input_type=1 and columnname='productcost' and defaultcolumn > 0;
delimiter;
update ld_producttoolfield set defaultcolumn = 3 where input_type=0 and columnname='grossprofit' and defaultcolumn > 0;
delimiter;
update ld_producttoolfield set defaultcolumn = 3 where input_type=0 and columnname='servicecontracts_start_date' and defaultcolumn > 0;
delimiter;
update ld_producttoolfield set defaultcolumn = 3 where input_type=2 and columnname='servicecontracts_end_date' and defaultcolumn > 0;
delimiter;

select max(tabid) into @tabid from ld_tab;
insert into ld_tab(tabid,name,presence,tabsequence,tablabel,customized,ownedby,isentitytype,parent,printtab)
select @tabid+1,'mobileExpense',1,50,'mobileExpense',0,0,1,'Finacial',1 from dual where not exists(select 1 from ld_tab where name='mobileExpense');
select MAX(cvid) into @maxid  from ld_customview;
update ld_customview_seq set id=@maxid+1 where not EXISTS(select 1 from ld_customview where viewname='mobileExpense' and entitytype='mobileExpense');
insert into ld_customview(cvid,viewname,setdefault,setmetrics,entitytype,status,userid,sequence,pagewidthpercent)select @maxid+1,'mobileExpense',0,0,'mobileExpense',0,1,1,100 
from dual where not EXISTS(select 1 from ld_customview where viewname='mobileExpense' and entitytype='mobileExpense');
select cvid into @cvid   from ld_customview where viewname='mobileExpense' and entitytype='mobileExpense';
delete from ld_cvcolumnlist where cvid=(select cvid from ld_customview where viewname='mobileExpense' and entitytype='mobileExpense' );
insert into ld_cvcolumnlist (cvid,columnindex,columnname) values(@cvid,0,'ld_expense:expense_no:expense_no:Expense_编号:V' );
insert into ld_cvcolumnlist (cvid,columnindex,columnname) values(@cvid,2,'ld_expense:expensedate:expensedate:Expense_报销日期:D' );
insert into ld_cvcolumnlist (cvid,columnindex,columnname) values(@cvid,1,'ld_expense:smownerid:assigned_user_id:Expense_负责人:V' );
insert into ld_cvcolumnlist (cvid,columnindex,columnname) values(@cvid,3,'ld_expense:approvestatus:approvestatus:Expense_状态:V' );
delimiter;
-- 2015-07-23


select actionid INTO @actionid from ld_actionmapping WHERE actionname='Updatestate';
select tabid INTO @tabid from ld_tab where `name` in ('Invoice');
insert into ld_profileallpermission(tabid,operation)
select @tabid,@actionid from dual 
where not EXISTS(select 1 from ld_profileallpermission  where tabid = @tabid and operation = @actionid);
delimiter;

select actionid INTO @actionid from ld_actionmapping WHERE actionname='Updatestate';
select tabid INTO @tabid from ld_tab where `name` in ('PurchaseInvoice');
insert into ld_profileallpermission(tabid,operation)
select @tabid,@actionid from dual 
where not EXISTS(select 1 from ld_profileallpermission  where tabid = @tabid and operation = @actionid);
delimiter;

select tabid into @tabid from ld_tab where `name` = 'LessionPlan';
insert into ld_profileallpermission(tabid,operation)
select @tabid,3 from dual where not exists(select 1 from ld_profileallpermission where tabid = @tabid and operation = 3);
insert into ld_profileallpermission(tabid,operation)
select @tabid,4 from dual where not exists(select 1 from ld_profileallpermission where tabid = @tabid and operation = 4);
delimiter;
insert into ld_profileallpermission(tabid,operation)
select @tabid,11 from dual where not exists(select 1 from ld_profileallpermission where tabid = @tabid and operation = 11);
delimiter;

insert into ld_profileallpermission(tabid,operation)
select @tabid,14 from dual where not exists(select 1 from ld_profileallpermission where tabid = @tabid and operation = 14);
delimiter;

insert into ld_profileallpermission(tabid,operation)
select @tabid,2 from dual where not exists(select 1 from ld_profileallpermission where tabid = @tabid and operation = 2);
delimiter;

insert into ld_profileallpermission(tabid,operation)
select @tabid,6 from dual where not exists(select 1 from ld_profileallpermission where tabid = @tabid and operation = 6);
delimiter;
-- 2015-07-24

update ld_producttoolfield set fieldlabel='合计' where columnname='total' and fieldlabel='价税合计';
update ld_tranlabel set fieldlabel='合计' where  trantable='ld_producttoolfield' and languagetype='zh' and fieldlabel='价税合计'
and Relateid in (select producttoolfieldid from ld_producttoolfield where columnname='total');
update ld_tranlabel set fieldlabel='Total' where  trantable='ld_producttoolfield' and languagetype='en' and fieldlabel='Price Tax Total'
and Relateid in (select producttoolfieldid from ld_producttoolfield where columnname='total');

DROP PROCEDURE IF EXISTS `update_producttoolfield_taxname`;
delimiter ||
CREATE  PROCEDURE `update_producttoolfield_taxname`(
)
BEGIN 
		
		declare tmp_taxname varchar(200) default NULL;
		declare tmp_taxlabel varchar(200) default NULL;
		
		declare mycursor cursor for select taxname,taxlabel from ld_inventorytaxinfo; 
		DECLARE CONTINUE HANDLER FOR SQLSTATE '02000' set tmp_taxname = NULL;

		open mycursor;
		fetch mycursor into tmp_taxname,tmp_taxlabel;
		while(tmp_taxname is not null) DO
			
			update ld_producttoolfield set fieldlabel=CONCAT('税(',tmp_taxlabel,')') where columnname=tmp_taxname and fieldlabel=tmp_taxlabel;
			update ld_tranlabel set fieldlabel=CONCAT('税(',tmp_taxlabel,')') where trantable='ld_producttoolfield' and languagetype='zh' and fieldlabel=tmp_taxlabel
			and Relateid in (select producttoolfieldid from ld_producttoolfield where columnname=tmp_taxname);
		
			fetch mycursor into tmp_taxname,tmp_taxlabel;
	end while;
	close mycursor;

end ||
delimiter; 

call update_producttoolfield_taxname();
delimiter; 

set @tabid=16;
select block into @blockid from ld_field where tabid=@tabid and columnname='smownerid';
set @tablename='ld_activity';
set @columnname='smcreatorid';
set @fieldname='creator';
set @zh='创建人';
set @en='Creator';
set @uitype=52;

select max(sequence) into @seq from ld_field where tabid=@tabid and block=@blockid;

select max(fieldid) into @fieldid from ld_field;
insert into ld_field(tabid,fieldid,columnname,tablename,generatedtype,uitype,fieldname,fieldlabel,readonly,presence,defaultvalue,maximumlength,sequence,block,displaytype,typeofdata,quickcreate,quickcreatesequence,info_type,masseditable,helpinfo,fieldonly)
select @tabid,@fieldid+1,@columnname,@tablename,1,@uitype,@fieldname,@zh,1,2,NULL,100,@seq+1,@blockid,2,'V~O',1,NULL,'BAS',1,NULL,0 from dual 
where not exists (select 1 from ld_field where tabid=@tabid and tablename=@tablename and columnname=@columnname);

select fieldid into @fieldid from ld_field where tabid=@tabid and columnname=@columnname;
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'zh','ld_field',@tabid,@fieldid,@zh from dual 
where not exists (select 1 from ld_tranlabel  where languagetype = 'zh' and trantable ='ld_field' and tabid = @tabid and relateid=@fieldid);

insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'en','ld_field',@tabid,@fieldid,@en from dual 
where not exists (select 1 from ld_tranlabel  where languagetype = 'en' and trantable ='ld_field' and tabid = @tabid and relateid=@fieldid);

call AddColumn(@tablename,@columnname,'int','11',0);
delimiter;

set @tabid=16;
select block into @blockid from ld_field where tabid=@tabid and columnname='smownerid';
set @tablename='ld_activity';
set @columnname='modifiedby';
set @fieldname='modifiedby';
set @zh='最新更新人';
set @en='Modified By';
set @uitype=52;

select max(sequence) into @seq from ld_field where tabid=@tabid and block=@blockid;

select max(fieldid) into @fieldid from ld_field;
insert into ld_field(tabid,fieldid,columnname,tablename,generatedtype,uitype,fieldname,fieldlabel,readonly,presence,defaultvalue,maximumlength,sequence,block,displaytype,typeofdata,quickcreate,quickcreatesequence,info_type,masseditable,helpinfo,fieldonly)
select @tabid,@fieldid+1,@columnname,@tablename,1,@uitype,@fieldname,@zh,1,2,NULL,100,@seq+1,@blockid,2,'V~O',1,NULL,'BAS',1,NULL,0 from dual 
where not exists (select 1 from ld_field where tabid=@tabid and tablename=@tablename and columnname=@columnname);

select fieldid into @fieldid from ld_field where tabid=@tabid and columnname=@columnname;
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'zh','ld_field',@tabid,@fieldid,@zh from dual 
where not exists (select 1 from ld_tranlabel  where languagetype = 'zh' and trantable ='ld_field' and tabid = @tabid and relateid=@fieldid);

insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'en','ld_field',@tabid,@fieldid,@en from dual 
where not exists (select 1 from ld_tranlabel  where languagetype = 'en' and trantable ='ld_field' and tabid = @tabid and relateid=@fieldid);

call AddColumn(@tablename,@columnname,'int','11',0);
delimiter;

set @tabid=16;
select block into @blockid from ld_field where tabid=@tabid and columnname='smownerid';
select max(sequence) into @seq from ld_field where tabid=@tabid and block=@blockid;
update ld_field set sequence=@seq+1 where tabid=@tabid and columnname='smcreatorid';
update ld_field set sequence=@seq+2 where tabid=@tabid and columnname='createdtime';
update ld_field set sequence=@seq+3 where tabid=@tabid and columnname='modifiedby';
update ld_field set sequence=@seq+4 where tabid=@tabid and columnname='modifiedtime';
set @i=0;
update ld_field set sequence=(@i:=@i+1) where tabid=@tabid and block=@blockid order by sequence;
delimiter;

update ld_field set masseditable=0 where tabid=6 and columnname='lastorderdate';
update ld_desk set fieldlabel='步骤' where labelbol='Stage' and languagetype='zh' and Labeltype='fixedstr';
update ld_producttoolfield set defaultcolumn=2 where columnname='taxprice';
update ld_producttoolfield set defaultcolumn=2 where columnname='total';
-- 2015-07-27

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) 
select 'zh','My','我的','fixedstr' 
from dual where not EXISTS(select 1 from ld_desk where languagetype='zh' and labelbol='My' 
and Labeltype='fixedstr');

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) 
select 'en','My','My ','fixedstr' 
from dual where not EXISTS(select 1 from ld_desk  where languagetype='en' and labelbol='My' 
and Labeltype='fixedstr');

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) 
select 'zh','exporttemplate','导出模板','fixedstr' 
from dual where not EXISTS(select 1 from ld_desk where languagetype='zh' and labelbol='exporttemplate' 
and Labeltype='fixedstr');

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) 
select 'en','exporttemplate',' export template','fixedstr' 
from dual where not EXISTS(select 1 from ld_desk  where languagetype='en' and labelbol='exporttemplate' 
and Labeltype='fixedstr');
delimiter;

insert into ld_systems_deploy(deploy_value,deploy_type,description,sequence)
select '100,100',75,'设置系统打印图片的尺寸,格式为(宽，高)',114 from DUAL where not EXISTS(select * from ld_systems_deploy where deploy_type=75);

update ld_field set displaytype = 2 where fieldname in ('servicecasher','servicegroup','modifiedby');
delimiter;

select tabid into @tabid from ld_tab where `name` = 'Accounts';
update ld_field set masseditable = 0 where tabid = @tabid and fieldname = 'lastorderdate';
update ld_field set masseditable = 0 where tabid = @tabid and fieldname = 'lastcontactdate';
update ld_field set masseditable = 0 where tabid = @tabid and fieldname = 'lastcontent';
update ld_field set masseditable = 0 where tabid = @tabid and fieldname = 'publicaccount';
delimiter;

select tabid into @tabid from ld_tab where `name` = 'Contacts';
update ld_field set masseditable = 0 where tabid = @tabid and fieldname = 'creator';
delimiter;

select tabid into @tabid from ld_tab where `name` = 'ServiceContracts';
update ld_field set masseditable = 0 where tabid = @tabid and fieldname = 'ServiceContractscreator';
update ld_field set masseditable = 0 where tabid = @tabid and fieldname = 'total_units';
delimiter;

select tabid into @tabid from ld_tab where `name` = 'HelpDesk';
update ld_field set masseditable = 0 where tabid = @tabid and fieldname = 'creator';
delimiter;

select tabid into @tabid from ld_tab where `name` = 'ServiceCharge';
update ld_field set masseditable = 0 where tabid = @tabid and fieldname = 'creator';
update ld_field set masseditable = 0 where tabid = @tabid and fieldname = 'lastorderdate';
update ld_field set masseditable = 0 where tabid = @tabid and fieldname = 'lastcontactdate';
update ld_field set masseditable = 0 where tabid = @tabid and fieldname = 'lastcontent';
update ld_field set masseditable = 0 where tabid = @tabid and fieldname = 'servicegroup';
delimiter;

select tabid into @tabid from ld_tab where `name` = 'Potentials';
update ld_field set masseditable = 0 where tabid = @tabid and fieldname = 'creator';
delimiter;

select tabid into @tabid from ld_tab where `name` = 'Quotes';
update ld_field set masseditable = 0 where tabid = @tabid and fieldname = 'creator';
delimiter;

select tabid into @tabid from ld_tab where `name` = 'SalesOrder';
update ld_field set masseditable = 0 where tabid = @tabid and fieldname = 'creator';
update ld_field set masseditable = 0 where tabid = @tabid and fieldname = 'stockpresence';
update ld_field set masseditable = 0 where tabid = @tabid and fieldname = 'purchasestatus';
update ld_field set masseditable = 0 where tabid = @tabid and fieldname = 'cashbilldate';
delimiter;

select tabid into @tabid from ld_tab where `name` = 'Vendors';
update ld_field set masseditable = 0 where tabid = @tabid and fieldname = 'creator';
delimiter;

select tabid into @tabid from ld_tab where `name` = 'PurchaseOrder';
update ld_field set masseditable = 0 where tabid = @tabid and fieldname = 'creator';
update ld_field set masseditable = 0 where tabid = @tabid and fieldname = 'stockpresence';
delimiter;

select tabid into @tabid from ld_tab where `name` = 'VendorContact';
update ld_field set masseditable = 0 where tabid = @tabid and fieldname = 'smcreatorid';
delimiter;

select tabid into @tabid from ld_tab where `name` = 'VendorContactRecords';
update ld_field set masseditable = 0 where tabid = @tabid and fieldname = 'smcreatorid';
delimiter;

select tabid into @tabid from ld_tab where `name` = 'Project';
update ld_field set masseditable = 0 where tabid = @tabid and fieldname = 'smcreatorid';
update ld_field set masseditable = 0 where tabid = @tabid and fieldname = 'createdtime';
update ld_field set masseditable = 0 where tabid = @tabid and fieldname = 'modifiedtime';
delimiter;

select tabid into @tabid from ld_tab where `name` = 'ProjectTask';
update ld_field set masseditable = 0 where tabid = @tabid and fieldname = 'smcreatorid';
update ld_field set masseditable = 0 where tabid = @tabid and fieldname = 'createdtime';
update ld_field set masseditable = 0 where tabid = @tabid and fieldname = 'modifiedtime';
delimiter;

select tabid into @tabid from ld_tab where `name` = 'ProjectMilestone';
update ld_field set masseditable = 0 where tabid = @tabid and fieldname = 'smcreatorid';
update ld_field set masseditable = 0 where tabid = @tabid and fieldname = 'createdtime';
update ld_field set masseditable = 0 where tabid = @tabid and fieldname = 'modifiedtime';
delimiter;

select tabid into @tabid from ld_tab where `name` = 'Checks';
update ld_field set masseditable = 0 where tabid = @tabid and fieldname = 'presence';
update ld_field set masseditable = 0 where tabid = @tabid and fieldname = 'createdtime';
update ld_field set masseditable = 0 where tabid = @tabid and fieldname = 'subsmownerid';
delimiter;

select tabid into @tabid from ld_tab where `name` = 'Invoice';
update ld_field set masseditable = 0 where tabid = @tabid and fieldname = 'creator';
delimiter;

select tabid into @tabid from ld_tab where `name` = 'PurchaseInvoice';
update ld_field set masseditable = 0 where tabid = @tabid and fieldname = 'presence';
update ld_field set masseditable = 0 where tabid = @tabid and fieldname = 'createdtime';
update ld_field set masseditable = 0 where tabid = @tabid and fieldname = 'subsmownerid';
delimiter;

select tabid into @tabid from ld_tab where `name` = 'CashBill';
update ld_field set masseditable = 0 where tabid = @tabid and fieldname = 'smcreatorid';
delimiter;

select tabid into @tabid from ld_tab where `name` = 'SendCashBill';
update ld_field set masseditable = 0 where tabid = @tabid and fieldname = 'smcreatorid';
delimiter;

select tabid into @tabid from ld_tab where `name` = 'SendPayment';
update ld_field set masseditable = 0 where tabid = @tabid and fieldname = 'smcreatorid';
delimiter;

select tabid into @tabid from ld_tab where `name` = 'PutCash';
update ld_field set masseditable = 0 where tabid = @tabid and fieldname = 'smcreatorid';
delimiter;

select tabid into @tabid from ld_tab where `name` = 'CashDeposit';
update ld_field set masseditable = 0 where tabid = @tabid and fieldname = 'smcreatorid';
delimiter;

select tabid into @tabid from ld_tab where `name` = 'Expense';
update ld_field set masseditable = 0 where tabid = @tabid and fieldname = 'creator';
delimiter;

select tabid into @tabid from ld_tab where `name` = 'Commission';
update ld_field set masseditable = 0 where tabid = @tabid and fieldname = 'modifiedtime';
update ld_field set masseditable = 0 where tabid = @tabid and fieldname = 'createdtime';
update ld_field set masseditable = 0 where tabid = @tabid and fieldname = 'smcreatorid';
delimiter;

select tabid into @tabid from ld_tab where `name` = 'ModComments';
update ld_field set masseditable = 0 where tabid = @tabid and fieldname = 'creator';
delimiter;

select tabid into @tabid from ld_tab where `name` = 'Products';
update ld_field set masseditable = 0 where tabid = @tabid and fieldname = 'qtyinstock';
update ld_field set masseditable = 0 where tabid = @tabid and fieldname = 'procreator';
delimiter;

select tabid into @tabid from ld_tab where `name` = 'PriceBooks';
update ld_field set masseditable = 0 where tabid = @tabid and fieldname = 'creator';
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','LBL_DEFAULTVALUE','默认值','jspop' from dual 
where not exists(select 1 from ld_desk where languagetype = 'zh' and labelbol = 'LBL_DEFAULTVALUE' and labeltype='jspop');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','LBL_DEFAULTVALUE','Default','jspop' from dual 
where not exists(select 1 from ld_desk where languagetype = 'en' and labelbol = 'LBL_DEFAULTVALUE' and labeltype='jspop');
delimiter;
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','PRECISIONVALUE','精度','jspop' from dual 
where not exists(select 1 from ld_desk where languagetype = 'zh' and labelbol = 'PRECISIONVALUE' and labeltype='jspop');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','PRECISIONVALUE','PrecisionValue','jspop' from dual 
where not exists(select 1 from ld_desk where languagetype = 'en' and labelbol = 'PRECISIONVALUE' and labeltype='jspop');
delimiter;

select tabid into @tabid from ld_tab where `name` = 'Productbom';
update ld_producttoolfield set edit_permission = 0 
where tabid = @tabid and defaultcolumn = 2 and columnname = 'quantity';
delimiter;

select tabid into @tabid from ld_field where tabid = 96 and issmownerid = 1;
update ld_field set issmownerid = 1 where fieldname = 'smcreatorid' and tabid = @tabid;
delimiter;

select tabid into @tabid from ld_tab where `name` = 'ModComments';
update ld_field set displaytype = 2 where tabid = @tabid and fieldname = 'reltab';
delimiter;
select tabid into @tabid from ld_tab where `name` = 'Productbom';
update ld_field set displaytype = 2 where tabid = @tabid and fieldname = 'hdnGrandTotal';
delimiter;
-- 2015-07-29

update ld_desk set fieldlabel = 'SQL脚本任务' 
where labelbol = 'LBL_AUTOMATICTASK_SQL' and languagetype='zh' and labeltype='fixedstr';
delimiter;
update ld_desk set fieldlabel = '普通任务' 
where labelbol = 'LBL_AUTOMATICTASK_CUSTOMIZED' and languagetype='zh' and labeltype='fixedstr';
delimiter;

update ld_desk set fieldlabel="本次收款金额" 
where labelbol = 'THEAMOUNTCOLLECTED' and labeltype = 'fixedstr' and languagetype = 'zh';
delimiter;

update ld_producttoolfield set typeofdata = 'V~O~100' where columnname = 'product_no' and defaultcolumn = 4;
delimiter;
-- 2015-07-30

set @tabid=16;
select block into @blockid from ld_field where tabid=@tabid and columnname='smownerid';
set @tablename='ld_activity';
set @columnname='approvestatus';
set @fieldname='approvestatus';
set @zh='审批状态';
set @en='Approve Status';
set @uitype=130;
set @readonly=1;
set @presence=2;
set @defaultvalue=NULL;
set @displaytype=2;
set @typeofdata='V~O';
set @quickcreate=1;
set @quickcreatesequence=NULL;
set @info_type='BAS';
set @masseditable=0;
  
select max(sequence) into @seq from ld_field where tabid=@tabid and block=@blockid;

select max(fieldid) into @fieldid from ld_field;
insert into ld_field(tabid,fieldid,columnname,tablename,generatedtype,uitype,fieldname,fieldlabel,readonly,presence,defaultvalue,maximumlength,sequence,block,displaytype,typeofdata,quickcreate,quickcreatesequence,info_type,masseditable,helpinfo,fieldonly)
select @tabid,@fieldid+1,@columnname,@tablename,1,@uitype,@fieldname,@zh,@readonly,@presence,@defaultvalue,100,@seq+1,@blockid,@displaytype,@typeofdata,@quickcreate,@quickcreatesequence,@info_type,@masseditable,NULL,0 from dual 
where not exists (select 1 from ld_field where tabid=@tabid and tablename=@tablename and columnname=@columnname);

select fieldid into @fieldid from ld_field where tabid=@tabid and columnname=@columnname;
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'zh','ld_field',@tabid,@fieldid,@zh from dual 
where not exists (select 1 from ld_tranlabel  where languagetype = 'zh' and trantable ='ld_field' and tabid = @tabid and relateid=@fieldid);

insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'en','ld_field',@tabid,@fieldid,@en from dual 
where not exists (select 1 from ld_tranlabel  where languagetype = 'en' and trantable ='ld_field' and tabid = @tabid and relateid=@fieldid);

call AddColumn(@tablename,@columnname,'varchar','100','未提交');
delimiter;

set @tabid=16;
select block into @blockid from ld_field where tabid=@tabid and columnname='smownerid';
set @tablename='ld_activity';
set @columnname='approveby';
set @fieldname='approveby';
set @zh='审批人';
set @en='Approve By';
set @uitype=131;
set @readonly=1;
set @presence=2;
set @defaultvalue=NULL;
set @displaytype=2;
set @typeofdata='V~O';
set @quickcreate=1;
set @quickcreatesequence=NULL;
set @info_type='BAS';
set @masseditable=0;
  
select max(sequence) into @seq from ld_field where tabid=@tabid and block=@blockid;

select max(fieldid) into @fieldid from ld_field;
insert into ld_field(tabid,fieldid,columnname,tablename,generatedtype,uitype,fieldname,fieldlabel,readonly,presence,defaultvalue,maximumlength,sequence,block,displaytype,typeofdata,quickcreate,quickcreatesequence,info_type,masseditable,helpinfo,fieldonly)
select @tabid,@fieldid+1,@columnname,@tablename,1,@uitype,@fieldname,@zh,@readonly,@presence,@defaultvalue,100,@seq+1,@blockid,@displaytype,@typeofdata,@quickcreate,@quickcreatesequence,@info_type,@masseditable,NULL,0 from dual 
where not exists (select 1 from ld_field where tabid=@tabid and tablename=@tablename and columnname=@columnname);

select fieldid into @fieldid from ld_field where tabid=@tabid and columnname=@columnname;
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'zh','ld_field',@tabid,@fieldid,@zh from dual 
where not exists (select 1 from ld_tranlabel  where languagetype = 'zh' and trantable ='ld_field' and tabid = @tabid and relateid=@fieldid);

insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'en','ld_field',@tabid,@fieldid,@en from dual 
where not exists (select 1 from ld_tranlabel  where languagetype = 'en' and trantable ='ld_field' and tabid = @tabid and relateid=@fieldid);

call AddColumn(@tablename,@columnname,'int','1','0');
delimiter;

update ld_producttoolfield set defaultcolumn=2 where columnname='tax_amount';

call AddColumn('ld_userlogincheck','type','int','10',1);
delimiter;
update ld_userlogincheck set type = 1 where type is null;
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) 
select 'zh','SELECTHASRECEIVINGDELETINGFAILED','您选择的记录有已收款或者部分已收款的单据，删除失败！','fixedstr' 
from dual where not EXISTS(select 1 from ld_desk where languagetype='zh' and labelbol='SELECTHASRECEIVINGDELETINGFAILED' 
and Labeltype='fixedstr');

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) 
select 'en','SELECTHASRECEIVINGDELETINGFAILED','The records you choose has receivable or part of documents,delete failed!','fixedstr' 
from dual where not EXISTS(select 1 from ld_desk  where languagetype='en' and labelbol='SELECTHASRECEIVINGDELETINGFAILED' 
and Labeltype='fixedstr');
-- 2015-07-31

UPDATE ld_field SET displaytype=2 WHERE tabid=(select tabid FROM ld_tab WHERE name='Productbom') AND columnname='total';
delimiter;
update ld_producttoolfield set defaultvalue=NULL where columnname='comment';
-- 2015-08-03

update ld_desk set fieldlabel='导出类型' where labelbol='ExportRecordType' and languagetype='zh' and Labeltype='fixedstr';

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
delimiter;


update ld_version set old_version='V6.1.0' ,current_version='V6.1.0' ,remark='V6.1.0-20150803';
delimiter;