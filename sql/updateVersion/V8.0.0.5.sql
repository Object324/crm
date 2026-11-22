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

UPDATE ld_parenttab SET imagename='left_nav_custom_ico.png' WHERE IFNULL(imagename,'')='';
ALTER TABLE ld_parenttab ALTER COLUMN imagename SET DEFAULT 'left_nav_custom_ico.png';

update ld_desk set fieldlabel='该单据审批步骤已变化，请重新加载该单据！' where labelbol='Approvestephavechangetip' and labeltype='fixedstr' and languagetype='zh';
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','mywork','我的工作','jspop' from dual 
where not EXISTS(select 1 from ld_desk where languagetype='zh' and labelbol='mywork' and Labeltype='jspop');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','mywork','My work','jspop' from dual 
where not EXISTS(select 1 from ld_desk where languagetype='en' and labelbol='mywork' and Labeltype='jspop');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','MYREPLY','我的回复','jspop' from dual 
where not EXISTS(select 1 from ld_desk where languagetype='zh' and labelbol='MYREPLY' and Labeltype='jspop');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','MYREPLY','My reply','jspop' from dual 
where not EXISTS(select 1 from ld_desk where languagetype='en' and labelbol='MYREPLY' and Labeltype='jspop');
delimiter;

DELETE FROM ld_tab WHERE `name`='ReportLog' AND DATABASE() LIKE 'yanshi_%';
DELETE FROM ld_tab WHERE `name`='ReportLog' AND DATABASE() LIKE 'demo_%';
DELETE FROM ld_tab WHERE `name`='ReportLog' AND DATABASE() IN ('crmqy_20150916','360_lingdang','360_puyong','360_zhuanye');

DELETE FROM ld_settings_field WHERE `name`='LBL_REMIND_SET' AND NOT EXISTS (SELECT 1 FROM ld_tab WHERE `name`='ReportLog');

DROP PROCEDURE IF EXISTS `reset_newdemoaccount_20200409`;
delimiter ||
CREATE  PROCEDURE `reset_newdemoaccount_20200409`(
)
BEGIN

	IF NOT EXISTS (SELECT 1 FROM ld_version_firstlogin) THEN 
		SET @my_blockid=(SELECT blockid FROM ld_appparenttab WHERE parenttab_label='Reports' LIMIT 1);
		DELETE FROM ld_appparenttabrel WHERE blockid=@my_blockid AND relatename='contractkit';
		
		update ld_dashboard_app set home_presence='no' WHERE  NAME='Contractkit';
	END IF;

end ||
delimiter;

CALL reset_newdemoaccount_20200409();
DROP PROCEDURE IF EXISTS `reset_newdemoaccount_20200409`;

UPDATE ld_tab SET isduplicate='yes' WHERE DATABASE() LIKE 'yanshi_%';
UPDATE ld_tab SET isduplicate='yes' WHERE DATABASE() LIKE 'demo_%';
UPDATE ld_tab SET isduplicate='yes' WHERE DATABASE() IN ('crmqy_20150916','360_lingdang','360_puyong','360_zhuanye');

DROP PROCEDURE IF EXISTS `reset_newdemoaccount_20200409_01`;
delimiter ||
CREATE  PROCEDURE `reset_newdemoaccount_20200409_01`(
)
BEGIN

	IF EXISTS (SELECT 1 FROM ld_field WHERE tabid=6 AND columnname='account_type' AND presence=1) THEN 
		SET @my_cvid=(SELECT cvid FROM ld_customview WHERE entitytype='Accounts' AND viewname='重点客户' LIMIT 1);
		DELETE FROM ld_cvadvfilter WHERE cvid=@my_cvid;
		DELETE FROM ld_cvadvfilter_grouping WHERE cvid=@my_cvid;
		DELETE FROM ld_cvstdfilter WHERE cvid=@my_cvid;
		DELETE FROM ld_cvcolumnlistsort WHERE cvid=@my_cvid;
		DELETE FROM ld_cvcolumnlist WHERE cvid=@my_cvid;
		DELETE FROM ld_customview WHERE cvid=@my_cvid;
	END IF;

	IF EXISTS (SELECT 1 FROM ld_customview WHERE entitytype='Accounts' AND viewname='本月创建') THEN
		SET @my_cvid=(SELECT cvid FROM ld_customview WHERE entitytype='Accounts' AND viewname='本月创建' LIMIT 1);
		DELETE FROM ld_cvadvfilter WHERE cvid=@my_cvid;
		DELETE FROM ld_cvadvfilter_grouping WHERE cvid=@my_cvid;
		DELETE FROM ld_cvstdfilter WHERE cvid=@my_cvid;

		INSERT INTO ld_cvadvfilter(cvid,columnindex,columnname,comparator,`value`,groupid,column_condition)
		SELECT @my_cvid,0,'ld_account:createdtime:createdtime:Accounts_fieldlabel:DT','thismonth','2020-04-01 00:00:00,2020-04-30 23:59:59',1,'';
		INSERT INTO ld_cvadvfilter_grouping(groupid,cvid,group_condition,condition_expression)
		SELECT 1,@my_cvid,'',0;
	END IF;

	UPDATE ld_field SET presence=0 WHERE tabid=6 AND columnname='lastcontactdate' AND (SELECT COUNT(1) FROM ld_crmentity)<7;
	IF EXISTS (SELECT 1 FROM ld_field WHERE tabid=6 AND columnname='lastcontactdate' AND presence=1) THEN 
		SET @my_cvid=(SELECT cvid FROM ld_customview WHERE entitytype='Accounts' AND viewname='今日待联系' LIMIT 1);
		DELETE FROM ld_cvadvfilter WHERE cvid=@my_cvid;
		DELETE FROM ld_cvadvfilter_grouping WHERE cvid=@my_cvid;
		DELETE FROM ld_cvstdfilter WHERE cvid=@my_cvid;
		DELETE FROM ld_cvcolumnlistsort WHERE cvid=@my_cvid;
		DELETE FROM ld_cvcolumnlist WHERE cvid=@my_cvid;
		DELETE FROM ld_customview WHERE cvid=@my_cvid;
	END IF;
    
	IF EXISTS (SELECT 1 FROM ld_customview WHERE entitytype='Accounts' AND viewname='今日待联系') THEN
		SET @my_cvid=(SELECT cvid FROM ld_customview WHERE entitytype='Accounts' AND viewname='今日待联系' LIMIT 1);
		DELETE FROM ld_cvadvfilter WHERE cvid=@my_cvid;
		DELETE FROM ld_cvadvfilter_grouping WHERE cvid=@my_cvid;
		DELETE FROM ld_cvstdfilter WHERE cvid=@my_cvid;

		INSERT INTO ld_cvadvfilter(cvid,columnindex,columnname,comparator,`value`,groupid,column_condition)
		SELECT @my_cvid,0,'ld_account:lastcontactdate:lastcontactdate:Accounts_fieldlabel:D','today','2020-04-09 00:00:00,2020-04-09 00:00:00',1,'';
		INSERT INTO ld_cvadvfilter_grouping(groupid,cvid,group_condition,condition_expression)
		SELECT 1,@my_cvid,'',0;
	END IF;

	IF EXISTS (SELECT 1 FROM ld_customview WHERE entitytype='Contacts' AND viewname='本周生日') THEN
		SET @my_cvid=(SELECT cvid FROM ld_customview WHERE entitytype='Contacts' AND viewname='本周生日' LIMIT 1);
		DELETE FROM ld_cvadvfilter WHERE cvid=@my_cvid;
		DELETE FROM ld_cvadvfilter_grouping WHERE cvid=@my_cvid;
		DELETE FROM ld_cvstdfilter WHERE cvid=@my_cvid;

		INSERT INTO ld_cvadvfilter(cvid,columnindex,columnname,comparator,`value`,groupid,column_condition)
		SELECT @my_cvid,0,'ld_contactdetails:birthday:birthday:Contacts_fieldlabel:D','thisweek','2020-04-06,2020-04-12',1,'';
		INSERT INTO ld_cvadvfilter_grouping(groupid,cvid,group_condition,condition_expression)
		SELECT 1,@my_cvid,'',0;
	END IF;

	-- 跟进记录
	IF EXISTS (SELECT 1 FROM ld_customview WHERE entitytype='ContactRecords' AND viewname='今日联系') THEN
		SET @my_cvid=(SELECT cvid FROM ld_customview WHERE entitytype='ContactRecords' AND viewname='今日联系' LIMIT 1);
		DELETE FROM ld_cvadvfilter WHERE cvid=@my_cvid;
		DELETE FROM ld_cvadvfilter_grouping WHERE cvid=@my_cvid;
		DELETE FROM ld_cvstdfilter WHERE cvid=@my_cvid;

		INSERT INTO ld_cvadvfilter(cvid,columnindex,columnname,comparator,`value`,groupid,column_condition)
		SELECT @my_cvid,0,'ld_contactrecords:contactdate:contactdate:ContactRecords_fieldlabel:DT','today','2020-04-09 00:00:00,2020-04-09 23:59:59',1,'';
		INSERT INTO ld_cvadvfilter_grouping(groupid,cvid,group_condition,condition_expression)
		SELECT 1,@my_cvid,'',0;
	END IF;


	IF EXISTS (SELECT 1 FROM ld_customview WHERE entitytype='ContactRecords' AND viewname='本周联系') THEN
		SET @my_cvid=(SELECT cvid FROM ld_customview WHERE entitytype='ContactRecords' AND viewname='本周联系' LIMIT 1);
		DELETE FROM ld_cvadvfilter WHERE cvid=@my_cvid;
		DELETE FROM ld_cvadvfilter_grouping WHERE cvid=@my_cvid;
		DELETE FROM ld_cvstdfilter WHERE cvid=@my_cvid;

		INSERT INTO ld_cvadvfilter(cvid,columnindex,columnname,comparator,`value`,groupid,column_condition)
		SELECT @my_cvid,0,'ld_contactrecords:contactdate:contactdate:ContactRecords_fieldlabel:DT','thisweek','2020-04-06 00:00:00,2020-04-12 23:59:59',1,'';
		INSERT INTO ld_cvadvfilter_grouping(groupid,cvid,group_condition,condition_expression)
		SELECT 1,@my_cvid,'',0;
	END IF;

	IF EXISTS (SELECT 1 FROM ld_customview WHERE entitytype='ContactRecords' AND viewname='本月联系') THEN
		SET @my_cvid=(SELECT cvid FROM ld_customview WHERE entitytype='ContactRecords' AND viewname='本月联系' LIMIT 1);
		DELETE FROM ld_cvadvfilter WHERE cvid=@my_cvid;
		DELETE FROM ld_cvadvfilter_grouping WHERE cvid=@my_cvid;
		DELETE FROM ld_cvstdfilter WHERE cvid=@my_cvid;

		INSERT INTO ld_cvadvfilter(cvid,columnindex,columnname,comparator,`value`,groupid,column_condition)
		SELECT @my_cvid,0,'ld_contactrecords:contactdate:contactdate:ContactRecords_fieldlabel:DT','thismonth','2020-04-01 00:00:00,2020-04-30 23:59:59',1,'';
		INSERT INTO ld_cvadvfilter_grouping(groupid,cvid,group_condition,condition_expression)
		SELECT 1,@my_cvid,'',0;
	END IF;

	-- 销售机会
	IF EXISTS (SELECT 1 FROM ld_customview WHERE entitytype='Potentials' AND viewname='本周预计成交') THEN
		SET @my_cvid=(SELECT cvid FROM ld_customview WHERE entitytype='Potentials' AND viewname='本周预计成交' LIMIT 1);
		DELETE FROM ld_cvadvfilter WHERE cvid=@my_cvid;
		DELETE FROM ld_cvadvfilter_grouping WHERE cvid=@my_cvid;
		DELETE FROM ld_cvstdfilter WHERE cvid=@my_cvid;

		INSERT INTO ld_cvadvfilter(cvid,columnindex,columnname,comparator,`value`,groupid,column_condition)
		SELECT @my_cvid,0,'ld_potential:closingdate:closingdate:Potentials_fieldlabel:D','thisweek','2020-04-06,2020-04-12',1,'';
		INSERT INTO ld_cvadvfilter_grouping(groupid,cvid,group_condition,condition_expression)
		SELECT 1,@my_cvid,'',0;
	END IF;

	IF EXISTS (SELECT 1 FROM ld_customview WHERE entitytype='Potentials' AND viewname='本月预计成交') THEN
		SET @my_cvid=(SELECT cvid FROM ld_customview WHERE entitytype='Potentials' AND viewname='本月预计成交' LIMIT 1);
		DELETE FROM ld_cvadvfilter WHERE cvid=@my_cvid;
		DELETE FROM ld_cvadvfilter_grouping WHERE cvid=@my_cvid;
		DELETE FROM ld_cvstdfilter WHERE cvid=@my_cvid;

		INSERT INTO ld_cvadvfilter(cvid,columnindex,columnname,comparator,`value`,groupid,column_condition)
		SELECT @my_cvid,0,'ld_potential:closingdate:closingdate:Potentials_fieldlabel:D','thismonth','2020-04-01,2020-04-30',1,'';
		INSERT INTO ld_cvadvfilter_grouping(groupid,cvid,group_condition,condition_expression)
		SELECT 1,@my_cvid,'',0;
	END IF;

	-- 合同订单
	IF EXISTS (SELECT 1 FROM ld_field WHERE tabid=22 AND columnname='stockpresence' AND presence=1) THEN
		SET @my_cvid=(SELECT cvid FROM ld_customview WHERE entitytype='SalesOrder' AND viewname='已发货' LIMIT 1);
		DELETE FROM ld_cvadvfilter WHERE cvid=@my_cvid;
		DELETE FROM ld_cvadvfilter_grouping WHERE cvid=@my_cvid;
		DELETE FROM ld_cvstdfilter WHERE cvid=@my_cvid;
		DELETE FROM ld_cvcolumnlistsort WHERE cvid=@my_cvid;
		DELETE FROM ld_cvcolumnlist WHERE cvid=@my_cvid;
		DELETE FROM ld_customview WHERE cvid=@my_cvid;
	END IF;

	-- 合同订单
	IF EXISTS (SELECT 1 FROM ld_field WHERE tabid=22 AND columnname='sostatus' AND presence=1) THEN
		SET @my_cvid=(SELECT cvid FROM ld_customview WHERE entitytype='SalesOrder' AND viewname='已作废' LIMIT 1);
		DELETE FROM ld_cvadvfilter WHERE cvid=@my_cvid;
		DELETE FROM ld_cvadvfilter_grouping WHERE cvid=@my_cvid;
		DELETE FROM ld_cvstdfilter WHERE cvid=@my_cvid;
		DELETE FROM ld_cvcolumnlistsort WHERE cvid=@my_cvid;
		DELETE FROM ld_cvcolumnlist WHERE cvid=@my_cvid;
		DELETE FROM ld_customview WHERE cvid=@my_cvid;
	END IF;

	-- 合同订单
	IF EXISTS (SELECT 1 FROM ld_field WHERE tabid=22 AND columnname='duedate' AND presence=1) THEN
		SET @my_cvid=(SELECT cvid FROM ld_customview WHERE entitytype='SalesOrder' AND viewname='已作废' LIMIT 1);
		DELETE FROM ld_cvadvfilter WHERE cvid=@my_cvid;
		DELETE FROM ld_cvadvfilter_grouping WHERE cvid=@my_cvid;
		DELETE FROM ld_cvstdfilter WHERE cvid=@my_cvid;
		DELETE FROM ld_cvcolumnlistsort WHERE cvid=@my_cvid;
		DELETE FROM ld_cvcolumnlist WHERE cvid=@my_cvid;
		DELETE FROM ld_customview WHERE cvid=@my_cvid;		
	END IF;

	IF EXISTS (SELECT 1 FROM ld_customview WHERE entitytype='SalesOrder' AND viewname='本月交付') THEN
		SET @my_cvid=(SELECT cvid FROM ld_customview WHERE entitytype='SalesOrder' AND viewname='本月交付' LIMIT 1);
		DELETE FROM ld_cvadvfilter WHERE cvid=@my_cvid;
		DELETE FROM ld_cvadvfilter_grouping WHERE cvid=@my_cvid;
		DELETE FROM ld_cvstdfilter WHERE cvid=@my_cvid;

		INSERT INTO ld_cvadvfilter(cvid,columnindex,columnname,comparator,`value`,groupid,column_condition)
		SELECT @my_cvid,0,'ld_salesorder:duedate:duedate:SalesOrder_fieldlabel:D','thismonth','2020-04-01,2020-04-30',1,'';
		INSERT INTO ld_cvadvfilter_grouping(groupid,cvid,group_condition,condition_expression)
		SELECT 1,@my_cvid,'',0;
	END IF;

	-- 服务收费管理
	IF EXISTS (SELECT 1 FROM ld_customview WHERE entitytype='ServiceCharge' AND viewname='无服务') THEN
		SET @my_cvid=(SELECT cvid FROM ld_customview WHERE entitytype='ServiceCharge' AND viewname='无服务' LIMIT 1);
		DELETE FROM ld_cvadvfilter WHERE cvid=@my_cvid;
		DELETE FROM ld_cvadvfilter_grouping WHERE cvid=@my_cvid;
		DELETE FROM ld_cvstdfilter WHERE cvid=@my_cvid;

		INSERT INTO ld_cvadvfilter(cvid,columnindex,columnname,comparator,`value`,groupid,column_condition)
		SELECT @my_cvid,0,'ld_products:productname:productname:Products_fieldlabel:V','isnull','',1,'';
		INSERT INTO ld_cvadvfilter_grouping(groupid,cvid,group_condition,condition_expression)
		SELECT 1,@my_cvid,'',0;
	END IF;
	
	-- 服务收费管理
	IF EXISTS (SELECT 1 FROM ld_customview WHERE entitytype='ServiceCharge' AND viewname='已过期') THEN
		SET @my_cvid=(SELECT cvid FROM ld_customview WHERE entitytype='ServiceCharge' AND viewname='已过期' LIMIT 1);
		DELETE FROM ld_cvadvfilter WHERE cvid=@my_cvid;
		DELETE FROM ld_cvadvfilter_grouping WHERE cvid=@my_cvid;
		DELETE FROM ld_cvstdfilter WHERE cvid=@my_cvid;

		INSERT INTO ld_cvadvfilter(cvid,columnindex,columnname,comparator,`value`,groupid,column_condition)
		SELECT @my_cvid,0,'ld_servicecontractsdetail:servicecontracts_end_date:servicecontracts_end_date:Products_fieldlabel:D','before1days','1600-01-01,2020-04-08',1,'';
		INSERT INTO ld_cvadvfilter_grouping(groupid,cvid,group_condition,condition_expression)
		SELECT 1,@my_cvid,'',0;
	END IF;

	-- 服务收费管理
	IF EXISTS (SELECT 1 FROM ld_customview WHERE entitytype='ServiceCharge' AND viewname='过期未超60天') THEN
		SET @my_cvid=(SELECT cvid FROM ld_customview WHERE entitytype='ServiceCharge' AND viewname='过期未超60天' LIMIT 1);
		DELETE FROM ld_cvadvfilter WHERE cvid=@my_cvid;
		DELETE FROM ld_cvadvfilter_grouping WHERE cvid=@my_cvid;
		DELETE FROM ld_cvstdfilter WHERE cvid=@my_cvid;

		INSERT INTO ld_cvadvfilter(cvid,columnindex,columnname,comparator,`value`,groupid,column_condition)
		SELECT @my_cvid,0,'ld_servicecontractsdetail:servicecontracts_end_date:servicecontracts_end_date:Products_fieldlabel:D','last60days','',1,'';
		INSERT INTO ld_cvadvfilter_grouping(groupid,cvid,group_condition,condition_expression)
		SELECT 1,@my_cvid,'',0;
	END IF;

	-- 服务收费管理
	IF EXISTS (SELECT 1 FROM ld_customview WHERE entitytype='ServiceCharge' AND viewname='过期未超30天') THEN
		SET @my_cvid=(SELECT cvid FROM ld_customview WHERE entitytype='ServiceCharge' AND viewname='过期未超30天' LIMIT 1);
		DELETE FROM ld_cvadvfilter WHERE cvid=@my_cvid;
		DELETE FROM ld_cvadvfilter_grouping WHERE cvid=@my_cvid;
		DELETE FROM ld_cvstdfilter WHERE cvid=@my_cvid;

		INSERT INTO ld_cvadvfilter(cvid,columnindex,columnname,comparator,`value`,groupid,column_condition)
		SELECT @my_cvid,0,'ld_servicecontractsdetail:servicecontracts_end_date:servicecontracts_end_date:Products_fieldlabel:D','last30days','',1,'';
		INSERT INTO ld_cvadvfilter_grouping(groupid,cvid,group_condition,condition_expression)
		SELECT 1,@my_cvid,'',0;
	END IF;

	UPDATE ld_cvadvfilter SET columnname=REPLACE(columnname,'ld_inventoryproductrel','ld_servicecontractsdetail') WHERE cvid IN (SELECT cvid FROM ld_customview WHERE entitytype='ServiceCharge');


	DELETE FROM ld_cvadvfilter WHERE cvid IN (SELECT cvid FROM ld_customview WHERE entitytype='ProjectMilestone' AND viewname IN ('已批准','审批中','未提交','已驳回','已拒绝'));
	DELETE FROM ld_cvadvfilter_grouping WHERE cvid IN (SELECT cvid FROM ld_customview WHERE entitytype='ProjectMilestone' AND viewname IN ('已批准','审批中','未提交','已驳回','已拒绝'));
	DELETE FROM ld_cvstdfilter WHERE cvid IN (SELECT cvid FROM ld_customview WHERE entitytype='ProjectMilestone' AND viewname IN ('已批准','审批中','未提交','已驳回','已拒绝'));
	DELETE FROM ld_cvcolumnlistsort WHERE cvid IN (SELECT cvid FROM ld_customview WHERE entitytype='ProjectMilestone' AND viewname IN ('已批准','审批中','未提交','已驳回','已拒绝'));
	DELETE FROM ld_cvcolumnlist WHERE cvid IN (SELECT cvid FROM ld_customview WHERE entitytype='ProjectMilestone' AND viewname IN ('已批准','审批中','未提交','已驳回','已拒绝'));
	DELETE FROM ld_customview WHERE entitytype='ProjectMilestone' AND viewname IN ('已批准','审批中','未提交','已驳回','已拒绝');


	-- 销售发票
	IF EXISTS (SELECT 1 FROM ld_field WHERE tabid=23 AND columnname='invoicestatus' AND presence=1) THEN 
		DELETE FROM ld_cvadvfilter WHERE cvid IN (SELECT cvid FROM ld_customview WHERE entitytype='Invoice' AND viewname IN ('未付款','已付款'));
		DELETE FROM ld_cvadvfilter_grouping WHERE cvid IN (SELECT cvid FROM ld_customview WHERE entitytype='Invoice' AND viewname IN ('未付款','已付款'));
		DELETE FROM ld_cvstdfilter WHERE cvid IN (SELECT cvid FROM ld_customview WHERE entitytype='Invoice' AND viewname IN ('未付款','已付款'));
		DELETE FROM ld_cvcolumnlistsort WHERE cvid IN (SELECT cvid FROM ld_customview WHERE entitytype='Invoice' AND viewname IN ('未付款','已付款'));
		DELETE FROM ld_cvcolumnlist WHERE cvid IN (SELECT cvid FROM ld_customview WHERE entitytype='Invoice' AND viewname IN ('未付款','已付款'));
		DELETE FROM ld_customview WHERE entitytype='Invoice' AND viewname IN ('未付款','已付款');
	END IF;

	-- 销售发票
	IF EXISTS (SELECT 1 FROM ld_customview WHERE entitytype='Invoice' AND viewname='本周开票') THEN
		SET @my_cvid=(SELECT cvid FROM ld_customview WHERE entitytype='Invoice' AND viewname='本周开票' LIMIT 1);
		DELETE FROM ld_cvadvfilter WHERE cvid=@my_cvid;
		DELETE FROM ld_cvadvfilter_grouping WHERE cvid=@my_cvid;
		DELETE FROM ld_cvstdfilter WHERE cvid=@my_cvid;

		INSERT INTO ld_cvadvfilter(cvid,columnindex,columnname,comparator,`value`,groupid,column_condition)
		SELECT @my_cvid,0,'ld_invoice:invoicedate:invoicedate:Invoice_fieldlabel:D','thisweek','2020-04-06,2020-04-12',1,'';
		INSERT INTO ld_cvadvfilter_grouping(groupid,cvid,group_condition,condition_expression)
		SELECT 1,@my_cvid,'',0;
	END IF;

	-- 销售发票
	IF EXISTS (SELECT 1 FROM ld_customview WHERE entitytype='Invoice' AND viewname='本月开票') THEN
		SET @my_cvid=(SELECT cvid FROM ld_customview WHERE entitytype='Invoice' AND viewname='本月开票' LIMIT 1);
		DELETE FROM ld_cvadvfilter WHERE cvid=@my_cvid;
		DELETE FROM ld_cvadvfilter_grouping WHERE cvid=@my_cvid;
		DELETE FROM ld_cvstdfilter WHERE cvid=@my_cvid;

		INSERT INTO ld_cvadvfilter(cvid,columnindex,columnname,comparator,`value`,groupid,column_condition)
		SELECT @my_cvid,0,'ld_invoice:invoicedate:invoicedate:Invoice_fieldlabel:D','thismonth','2020-04-01,2020-04-30',1,'';
		INSERT INTO ld_cvadvfilter_grouping(groupid,cvid,group_condition,condition_expression)
		SELECT 1,@my_cvid,'',0;
	END IF;


	SET @my_tabid=(SELECT tabid FROM ld_tab WHERE `name`='SendPayment');
	IF EXISTS (SELECT 1 FROM ld_field WHERE tabid=@my_tabid AND columnname='approvestatus' AND presence=1) THEN
		DELETE FROM ld_cvadvfilter WHERE cvid IN (SELECT cvid FROM ld_customview WHERE entitytype='ProjectMilestone' AND viewname IN ('已批准','审批中','未提交','已驳回','已拒绝'));
		DELETE FROM ld_cvadvfilter_grouping WHERE cvid IN (SELECT cvid FROM ld_customview WHERE entitytype='ProjectMilestone' AND viewname IN ('已批准','审批中','未提交','已驳回','已拒绝'));
		DELETE FROM ld_cvstdfilter WHERE cvid IN (SELECT cvid FROM ld_customview WHERE entitytype='ProjectMilestone' AND viewname IN ('已批准','审批中','未提交','已驳回','已拒绝'));
		DELETE FROM ld_cvcolumnlistsort WHERE cvid IN (SELECT cvid FROM ld_customview WHERE entitytype='ProjectMilestone' AND viewname IN ('已批准','审批中','未提交','已驳回','已拒绝'));
		DELETE FROM ld_cvcolumnlist WHERE cvid IN (SELECT cvid FROM ld_customview WHERE entitytype='ProjectMilestone' AND viewname IN ('已批准','审批中','未提交','已驳回','已拒绝'));
		DELETE FROM ld_customview WHERE entitytype='ProjectMilestone' AND viewname IN ('已批准','审批中','未提交','已驳回','已拒绝');
	END IF;

	-- 付款计划
	IF EXISTS (SELECT 1 FROM ld_customview WHERE entitytype='SendPayment' AND viewname='审批中') THEN
		SET @my_cvid=(SELECT cvid FROM ld_customview WHERE entitytype='SendPayment' AND viewname='审批中' LIMIT 1);
		DELETE FROM ld_cvadvfilter WHERE cvid=@my_cvid;
		DELETE FROM ld_cvadvfilter_grouping WHERE cvid=@my_cvid;
		DELETE FROM ld_cvstdfilter WHERE cvid=@my_cvid;

		INSERT INTO ld_cvadvfilter(cvid,columnindex,columnname,comparator,`value`,groupid,column_condition)
		SELECT @my_cvid,0,'ld_sendpayment:approvestatus:approvestatus:SendPayment_fieldlabel:V','e','审批中',1,'';
		INSERT INTO ld_cvadvfilter_grouping(groupid,cvid,group_condition,condition_expression)
		SELECT 1,@my_cvid,'',0;
	END IF;

	-- 付款计划
	IF EXISTS (SELECT 1 FROM ld_customview WHERE entitytype='SendPayment' AND viewname='未提交') THEN
		SET @my_cvid=(SELECT cvid FROM ld_customview WHERE entitytype='SendPayment' AND viewname='未提交' LIMIT 1);
		DELETE FROM ld_cvadvfilter WHERE cvid=@my_cvid;
		DELETE FROM ld_cvadvfilter_grouping WHERE cvid=@my_cvid;
		DELETE FROM ld_cvstdfilter WHERE cvid=@my_cvid;

		INSERT INTO ld_cvadvfilter(cvid,columnindex,columnname,comparator,`value`,groupid,column_condition)
		SELECT @my_cvid,0,'ld_sendpayment:approvestatus:approvestatus:SendPayment_fieldlabel:V','e','未提交',1,'';
		INSERT INTO ld_cvadvfilter_grouping(groupid,cvid,group_condition,condition_expression)
		SELECT 1,@my_cvid,'',0;
	END IF;

	-- 付款计划
	IF EXISTS (SELECT 1 FROM ld_customview WHERE entitytype='SendPayment' AND viewname='已驳回') THEN
		SET @my_cvid=(SELECT cvid FROM ld_customview WHERE entitytype='SendPayment' AND viewname='已驳回' LIMIT 1);
		DELETE FROM ld_cvadvfilter WHERE cvid=@my_cvid;
		DELETE FROM ld_cvadvfilter_grouping WHERE cvid=@my_cvid;
		DELETE FROM ld_cvstdfilter WHERE cvid=@my_cvid;

		INSERT INTO ld_cvadvfilter(cvid,columnindex,columnname,comparator,`value`,groupid,column_condition)
		SELECT @my_cvid,0,'ld_sendpayment:approvestatus:approvestatus:SendPayment_fieldlabel:V','e','已驳回',1,'';
		INSERT INTO ld_cvadvfilter_grouping(groupid,cvid,group_condition,condition_expression)
		SELECT 1,@my_cvid,'',0;
	END IF;

	-- 付款计划
	IF EXISTS (SELECT 1 FROM ld_customview WHERE entitytype='SendPayment' AND viewname='已拒绝') THEN
		SET @my_cvid=(SELECT cvid FROM ld_customview WHERE entitytype='SendPayment' AND viewname='已拒绝' LIMIT 1);
		DELETE FROM ld_cvadvfilter WHERE cvid=@my_cvid;
		DELETE FROM ld_cvadvfilter_grouping WHERE cvid=@my_cvid;
		DELETE FROM ld_cvstdfilter WHERE cvid=@my_cvid;

		INSERT INTO ld_cvadvfilter(cvid,columnindex,columnname,comparator,`value`,groupid,column_condition)
		SELECT @my_cvid,0,'ld_sendpayment:approvestatus:approvestatus:SendPayment_fieldlabel:V','e','已拒绝',1,'';
		INSERT INTO ld_cvadvfilter_grouping(groupid,cvid,group_condition,condition_expression)
		SELECT 1,@my_cvid,'',0;
	END IF;

	-- 付款计划
	IF EXISTS (SELECT 1 FROM ld_customview WHERE entitytype='SendPayment' AND viewname='已批准') THEN
		SET @my_cvid=(SELECT cvid FROM ld_customview WHERE entitytype='SendPayment' AND viewname='已批准' LIMIT 1);
		DELETE FROM ld_cvadvfilter WHERE cvid=@my_cvid;
		DELETE FROM ld_cvadvfilter_grouping WHERE cvid=@my_cvid;
		DELETE FROM ld_cvstdfilter WHERE cvid=@my_cvid;

		INSERT INTO ld_cvadvfilter(cvid,columnindex,columnname,comparator,`value`,groupid,column_condition)
		SELECT @my_cvid,0,'ld_sendpayment:approvestatus:approvestatus:SendPayment_fieldlabel:V','e','已批准',1,'';
		INSERT INTO ld_cvadvfilter_grouping(groupid,cvid,group_condition,condition_expression)
		SELECT 1,@my_cvid,'',0;
	END IF;


	-- 供应商联系记录
	IF EXISTS (SELECT 1 FROM ld_customview WHERE entitytype='VendorContactRecords' AND viewname='今日联系') THEN
		SET @my_cvid=(SELECT cvid FROM ld_customview WHERE entitytype='VendorContactRecords' AND viewname='今日联系' LIMIT 1);
		DELETE FROM ld_cvadvfilter WHERE cvid=@my_cvid;
		DELETE FROM ld_cvadvfilter_grouping WHERE cvid=@my_cvid;
		DELETE FROM ld_cvstdfilter WHERE cvid=@my_cvid;

		INSERT INTO ld_cvadvfilter(cvid,columnindex,columnname,comparator,`value`,groupid,column_condition)
		SELECT @my_cvid,0,'ld_vendorcontactrecords:contactdate:contactdate:VendorContactRecords_fieldlabel:D','today','2020-04-09,2020-04-09',1,'';
		INSERT INTO ld_cvadvfilter_grouping(groupid,cvid,group_condition,condition_expression)
		SELECT 1,@my_cvid,'',0;
	END IF;

	-- 供应商联系记录
	IF EXISTS (SELECT 1 FROM ld_customview WHERE entitytype='VendorContactRecords' AND viewname='本周联系') THEN
		SET @my_cvid=(SELECT cvid FROM ld_customview WHERE entitytype='VendorContactRecords' AND viewname='本周联系' LIMIT 1);
		DELETE FROM ld_cvadvfilter WHERE cvid=@my_cvid;
		DELETE FROM ld_cvadvfilter_grouping WHERE cvid=@my_cvid;
		DELETE FROM ld_cvstdfilter WHERE cvid=@my_cvid;

		INSERT INTO ld_cvadvfilter(cvid,columnindex,columnname,comparator,`value`,groupid,column_condition)
		SELECT @my_cvid,0,'ld_vendorcontactrecords:contactdate:contactdate:VendorContactRecords_fieldlabel:D','thisweek','2020-04-06,2020-04-12',1,'';
		INSERT INTO ld_cvadvfilter_grouping(groupid,cvid,group_condition,condition_expression)
		SELECT 1,@my_cvid,'',0;
	END IF;

-- 供应商联系记录
	IF EXISTS (SELECT 1 FROM ld_customview WHERE entitytype='VendorContactRecords' AND viewname='本月联系') THEN
		SET @my_cvid=(SELECT cvid FROM ld_customview WHERE entitytype='VendorContactRecords' AND viewname='本月联系' LIMIT 1);
		DELETE FROM ld_cvadvfilter WHERE cvid=@my_cvid;
		DELETE FROM ld_cvadvfilter_grouping WHERE cvid=@my_cvid;
		DELETE FROM ld_cvstdfilter WHERE cvid=@my_cvid;

		INSERT INTO ld_cvadvfilter(cvid,columnindex,columnname,comparator,`value`,groupid,column_condition)
		SELECT @my_cvid,0,'ld_vendorcontactrecords:contactdate:contactdate:VendorContactRecords_fieldlabel:D','thismonth','2020-04-01,2020-04-30',1,'';
		INSERT INTO ld_cvadvfilter_grouping(groupid,cvid,group_condition,condition_expression)
		SELECT 1,@my_cvid,'',0;
	END IF;

	-- 公告
	IF EXISTS (SELECT 1 FROM ld_customview WHERE entitytype='PublicAnnouncement' AND viewname='今日') THEN
		SET @my_cvid=(SELECT cvid FROM ld_customview WHERE entitytype='PublicAnnouncement' AND viewname='今日' LIMIT 1);
		DELETE FROM ld_cvadvfilter WHERE cvid=@my_cvid;
		DELETE FROM ld_cvadvfilter_grouping WHERE cvid=@my_cvid;
		DELETE FROM ld_cvstdfilter WHERE cvid=@my_cvid;

		INSERT INTO ld_cvadvfilter(cvid,columnindex,columnname,comparator,`value`,groupid,column_condition)
		SELECT @my_cvid,0,'ld_publicannouncement:startdate:startdate:PublicAnnouncement_fieldlabel:D','today','2020-04-09,2020-04-09',1,'';
		INSERT INTO ld_cvadvfilter_grouping(groupid,cvid,group_condition,condition_expression)
		SELECT 1,@my_cvid,'',0;
	END IF;

	-- 公告
	IF EXISTS (SELECT 1 FROM ld_customview WHERE entitytype='PublicAnnouncement' AND viewname='本周') THEN
		SET @my_cvid=(SELECT cvid FROM ld_customview WHERE entitytype='PublicAnnouncement' AND viewname='本周' LIMIT 1);
		DELETE FROM ld_cvadvfilter WHERE cvid=@my_cvid;
		DELETE FROM ld_cvadvfilter_grouping WHERE cvid=@my_cvid;
		DELETE FROM ld_cvstdfilter WHERE cvid=@my_cvid;

		INSERT INTO ld_cvadvfilter(cvid,columnindex,columnname,comparator,`value`,groupid,column_condition)
		SELECT @my_cvid,0,'ld_publicannouncement:startdate:startdate:PublicAnnouncement_fieldlabel:D','thisweek','2020-04-06,2020-04-12',1,'';
		INSERT INTO ld_cvadvfilter_grouping(groupid,cvid,group_condition,condition_expression)
		SELECT 1,@my_cvid,'',0;
	END IF;

	-- 公告
	IF EXISTS (SELECT 1 FROM ld_customview WHERE entitytype='PublicAnnouncement' AND viewname='本月') THEN
		SET @my_cvid=(SELECT cvid FROM ld_customview WHERE entitytype='PublicAnnouncement' AND viewname='本月' LIMIT 1);
		DELETE FROM ld_cvadvfilter WHERE cvid=@my_cvid;
		DELETE FROM ld_cvadvfilter_grouping WHERE cvid=@my_cvid;
		DELETE FROM ld_cvstdfilter WHERE cvid=@my_cvid;

		INSERT INTO ld_cvadvfilter(cvid,columnindex,columnname,comparator,`value`,groupid,column_condition)
		SELECT @my_cvid,0,'ld_publicannouncement:startdate:startdate:PublicAnnouncement_fieldlabel:D','thismonth','2020-04-01,2020-04-30',1,'';
		INSERT INTO ld_cvadvfilter_grouping(groupid,cvid,group_condition,condition_expression)
		SELECT 1,@my_cvid,'',0;
	END IF;


end ||
delimiter;

CALL reset_newdemoaccount_20200409_01();
DROP PROCEDURE IF EXISTS `reset_newdemoaccount_20200409_01`;

UPDATE ld_entityname SET fieldname='purchaseorder_no' WHERE tabid=21 AND fieldname='subject' 
	AND EXISTS (SELECT 1 FROM ld_field WHERE tabid=21 AND columnname='subject' AND presence=1);
    
UPDATE ld_entityname SET fieldname='quote_no' WHERE tabid=20 AND fieldname='subject' 
	AND EXISTS (SELECT 1 FROM ld_field WHERE tabid=20 AND columnname='subject' AND presence=1);
    
DROP PROCEDURE IF EXISTS `reset_newdemoaccount_20200409_02`;
delimiter ||
CREATE  PROCEDURE `reset_newdemoaccount_20200409_02`(
)
BEGIN

	IF EXISTS (SELECT 1 FROM ld_version WHERE trade='puyoung') AND EXISTS (SELECT 1 FROM ld_groups WHERE groupid=1 AND groupname='某某公司') THEN 

		UPDATE ld_parenttab SET sequence=1001 WHERE parenttab_label='Marketing';
		UPDATE ld_parenttab SET sequence=1002 WHERE parenttab_label='OAForms';
		UPDATE ld_parenttab SET sequence=1003 WHERE parenttab_label='CustomForms';
		UPDATE ld_parenttab SET sequence=1004 WHERE parenttab_label='Tools';
		
		SET @i=0;
		UPDATE ld_parenttab SET sequence=(@i:=@i+1) WHERE visible=0 ORDER BY sequence;
		
	END IF;

end ||
delimiter;

CALL reset_newdemoaccount_20200409_02();
DROP PROCEDURE IF EXISTS `reset_newdemoaccount_20200409_02`;

UPDATE ld_groups SET description='' WHERE description='某某公司' AND parentid=-1;

select tabid into @tabid from ld_tab where name='cashbill';
update ld_field  set displaytype=2,presence=2,bigtype='translatefield',uitype=1,allowhide='no' where tabid=@tabid and columnname='cashtype';
delimiter;

insert into ld_desk (languagetype,labelbol,fieldlabel,labeltype)
select 'zh' ,'CreateCashBill','收款','fixedstr' from dual 
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='CreateCashBill' and labeltype='fixedstr');
delimiter;

insert into ld_desk (languagetype,labelbol,fieldlabel,labeltype)
select 'en' ,'CreateCashBill','Actual receipts','fixedstr' from dual 
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='CreateCashBill' and labeltype='fixedstr');
delimiter;


insert into ld_desk (languagetype,labelbol,fieldlabel,labeltype)
select 'zh' ,'CreateDebuction','预收','fixedstr' from dual 
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='CreateDebuction' and labeltype='fixedstr');
delimiter;

insert into ld_desk (languagetype,labelbol,fieldlabel,labeltype)
select 'en' ,'CreateDebuction','Collect in advance','fixedstr' from dual 
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='CreateDebuction' and labeltype='fixedstr');
delimiter;

SET @disable_triggers=1;
alter table ld_cashbill alter cashtype set default 'cashbill';
update ld_cashbill set cashtype='cashbill' where cashtype is null or cashtype='';
SET @disable_triggers=NULL;
delimiter;


CREATE TABLE if not exists `ld_translatefield` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `columnname` varchar(50) DEFAULT NULL,
	`column_Dbvalue` varchar(100) DEFAULT NULL,
  `module` varchar(50) DEFAULT NULL,
  `labelbol` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
delimiter;

insert into ld_translatefield(columnname,module,column_Dbvalue,labelbol)
select 'cashtype','CashBill','cashbill','CreateCashBill' from dual 
where not exists(select 1 from ld_translatefield where module='CashBill' and columnname='cashtype' and column_Dbvalue='cashbill');
delimiter;

insert into ld_translatefield(columnname,module,column_Dbvalue,labelbol)
select 'cashtype','CashBill','debuction','CreateDebuction' from dual 
where not exists(select 1 from ld_translatefield where module='CashBill' and columnname='cashtype' and column_Dbvalue='debuction');
delimiter;

update ld_tranlabel 
INNER JOIN ld_field on ld_field.fieldid=ld_tranlabel.relateid
and ld_tranlabel.trantable='ld_field'
INNER JOIN ld_tab on ld_tab.tabid=ld_field.tabid
set ld_tranlabel.fieldlabel='实际收款金额'
where ld_tab.name='cashbill' and ld_field.columnname='total' and ld_tranlabel.languagetype='zh' ;
delimiter;

update ld_tranlabel 
INNER JOIN ld_field on ld_field.fieldid=ld_tranlabel.relateid
and ld_tranlabel.trantable='ld_field'
INNER JOIN ld_tab on ld_tab.tabid=ld_field.tabid
set ld_tranlabel.fieldlabel='Actual Receipts'
where ld_tab.name='cashbill' and ld_field.columnname='total' and ld_tranlabel.languagetype='en' ;
delimiter;

insert into ld_desk (languagetype,labelbol,fieldlabel,labeltype)
select 'zh' ,'ActualReceipts','实际收款金额','fixedstr' from dual 
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='ActualReceipts' and labeltype='fixedstr');
delimiter;

insert into ld_desk (languagetype,labelbol,fieldlabel,labeltype)
select 'en' ,'ActualReceipts','Actual Receipts','fixedstr' from dual 
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='ActualReceipts' and labeltype='fixedstr');
delimiter;

CALl AddColumn('ld_cashbill','debuctionamount','decimal','20','0');
CALl AddColumn('ld_cashbill','debuctionbalanceamount','decimal','20','0');
delimiter;

alter table ld_cashbill  modify column debuctionamount decimal(22,8);
delimiter;
alter table ld_cashbill  modify column debuctionbalanceamount decimal(22,8);
delimiter;

insert into ld_desk (languagetype,labelbol,fieldlabel,labeltype)
select 'zh' ,'DeductedAmount','本次抵扣金额','fixedstr' from dual 
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='DeductedAmount' and labeltype='fixedstr');
delimiter;

insert into ld_desk (languagetype,labelbol,fieldlabel,labeltype)
select 'en' ,'DeductedAmount','deducted amount','fixedstr' from dual 
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='DeductedAmount' and labeltype='fixedstr');
delimiter;


insert into ld_desk (languagetype,labelbol,fieldlabel,labeltype)
select 'zh' ,'CanDeductibleAmount','可抵扣金额','fixedstr' from dual 
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='CanDeductibleAmount' and labeltype='fixedstr');
delimiter;

insert into ld_desk (languagetype,labelbol,fieldlabel,labeltype)
select 'en' ,'CanDeductibleAmount','can deductible amount','fixedstr' from dual 
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='CanDeductibleAmount' and labeltype='fixedstr');
delimiter;

insert into ld_desk (languagetype,labelbol,fieldlabel,labeltype)
select 'zh' ,'UsedAmount','核销金额','fixedstr' from dual 
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='UsedAmount' and labeltype='fixedstr');
delimiter;

insert into ld_desk (languagetype,labelbol,fieldlabel,labeltype)
select 'en' ,'UsedAmount','Used Amount','fixedstr' from dual 
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='UsedAmount' and labeltype='fixedstr');
delimiter;

insert into ld_desk (languagetype,labelbol,fieldlabel,labeltype)
select 'zh' ,'AvailableAmount','余额','fixedstr' from dual 
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='AvailableAmount' and labeltype='fixedstr');
delimiter;

insert into ld_desk (languagetype,labelbol,fieldlabel,labeltype)
select 'en' ,'AvailableAmount','Available Amount','fixedstr' from dual 
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='AvailableAmount' and labeltype='fixedstr');
delimiter;

insert into ld_desk (languagetype,labelbol,fieldlabel,labeltype)
select 'zh' ,'UsedAmountHistory','核销记录','fixedstr' from dual 
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='UsedAmountHistory' and labeltype='fixedstr');
delimiter;

insert into ld_desk (languagetype,labelbol,fieldlabel,labeltype)
select 'en' ,'UsedAmountHistory','Used Amount Detail','fixedstr' from dual 
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='UsedAmountHistory' and labeltype='fixedstr');
delimiter;

CALL getallprofile('CashBill');
CALL fieldprofile('CashBill');
delimiter;

CREATE TABLE if not exists `ld_cashbilldebuctiondetail` (
  `id` int(19) NOT NULL AUTO_INCREMENT,
  `cashbillid` int(19) DEFAULT NULL,
	`debuctionid` int(19) DEFAULT NULL,
	`amount` decimal(22,8) default 0,
  `userid` int(11) DEFAULT NULL,
  `modifiedtime` datetime DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
delimiter;

SET @modulename='CashBill';
SET @tabid=(SELECT tabid FROM ld_tab WHERE `name`=@modulename);
SET @blockid=(SELECT block FROM ld_field WHERE tabid=@tabid AND columnname='cashbill_no' LIMIT 1);
SET @maxseq=IFNULL((SELECT MAX(sequence) FROM ld_field WHERE tabid=@tabid AND block=@blockid),0);
SET @trantable='ld_field';
SET @tablename=(SELECT tablename FROM ld_field WHERE tabid=@tabid AND columnname='cashbill_no' LIMIT 1);
SET @columnname='debuctionamount';
SET @fieldname='debuctionamount';
SET @zh='已核销金额';
SET @en='Used Amount';
SET @uitype=72;
SET @typeofdata='N~O~22,2';
SET @quickcreate=0;
SET @displaytype=2;

INSERT INTO ld_field
(tabid,fieldid,columnname,tablename,generatedtype,uitype,fieldname,fieldlabel,readonly,presence,defaultvalue,maximumlength,sequence,block,displaytype,typeofdata,quickcreate,quickcreatesequence,info_type,masseditable,helpinfo,fieldonly,approve_demand,is_checkimportfield)
SELECT @tabid,@maxid+1,@columnname,@tablename,1,@uitype,@fieldname,@zh,1,2,NULL,100,@maxseq+1,@blockid,@displaytype,@typeofdata,@quickcreate,NULL,NULL,1,NULL,0,2,0 from dual 
WHERE NOT EXISTS (SELECT 1 FROM ld_field WHERE tabid=@tabid AND tablename=@tablename AND columnname=@columnname);


set @relateid=(select fieldid from ld_field where tabid=@tabid and columnname=@columnname);

insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'zh' ,'ld_field' ,@tabid,@relateid,@zh from dual 
where not exists(select 1 from ld_tranlabel where tabid=@tabid and relateid=@relateid and languagetype='zh' and trantable='ld_field');
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'en' ,'ld_field' ,@tabid,@relateid,@en from dual 
where not exists(select 1 from ld_tranlabel where tabid=@tabid and relateid=@relateid and languagetype='en' and trantable='ld_field');

SET @columnname='debuctionbalanceamount';
SET @fieldname='debuctionbalanceamount';
SET @zh='余额';
SET @en='Available Amount';
SET @maxid=(SELECT MAX(fieldid) FROM ld_field);
SET @maxseq=IFNULL((SELECT MAX(sequence) FROM ld_field WHERE tabid=@tabid AND block=@blockid),0);

INSERT INTO ld_field
(tabid,fieldid,columnname,tablename,generatedtype,uitype,fieldname,fieldlabel,readonly,presence,defaultvalue,maximumlength,sequence,block,displaytype,typeofdata,quickcreate,quickcreatesequence,info_type,masseditable,helpinfo,fieldonly,approve_demand,is_checkimportfield)
SELECT @tabid,@maxid+1,@columnname,@tablename,1,@uitype,@fieldname,@zh,1,2,NULL,100,@maxseq+1,@blockid,@displaytype,@typeofdata,@quickcreate,NULL,NULL,1,NULL,0,2,0 from dual 
WHERE NOT EXISTS (SELECT 1 FROM ld_field WHERE tabid=@tabid AND tablename=@tablename AND columnname=@columnname);

set @relateid=(select fieldid from ld_field where tabid=@tabid and columnname=@columnname);
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'zh' ,'ld_field' ,@tabid,@relateid,@zh from dual 
where not exists(select 1 from ld_tranlabel where tabid=@tabid and relateid=@relateid and languagetype='zh' and trantable='ld_field');
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'en' ,'ld_field' ,@tabid,@relateid,@en from dual 
where not exists(select 1 from ld_tranlabel where tabid=@tabid and relateid=@relateid and languagetype='en' and trantable='ld_field');
delimiter;
insert into ld_desk (languagetype,labelbol,fieldlabel,Labeltype)
select 'zh','CANNOTEMPTYORZERO','不能为空或0','jspop' from DUAL
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='CANNOTEMPTYORZERO' and Labeltype='jspop');
insert into ld_desk (languagetype,labelbol,fieldlabel,Labeltype)
select 'en','CANNOTEMPTYORZERO','cannot be empty or 0','jspop' from DUAL
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='CANNOTEMPTYORZERO' and Labeltype='jspop');
delimiter;
update ld_relatedlists set label='Download_Browse_Record'  where name='getAuditTrialLog';

update ld_desk set labelbol='Download_Browse_Record' where labelbol='Download Browse Record';
delimiter;


update ld_field set tablename='ld_attachments' where uitype=1109;
delimiter;
-- 2020-04-09

UPDATE ld_warehouse SET started=0 WHERE id IN (2,3,4) AND `name` IN ('总仓','赠品仓','其他仓');

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

UPDATE ld_version SET old_version='V8.0.0.5',current_version='V8.0.0.5',remark='V8.0.0.5-20200410',wx_version='V8.0.0.2';
delimiter;