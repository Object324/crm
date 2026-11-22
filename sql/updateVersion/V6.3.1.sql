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

select tabid into @tabid from ld_tab where `name`='Rate';
update ld_blocks set sequence=100 where tabid=@tabid and blocklabel='LBL_RATE_REMARK';

set @i=0;
update ld_blocks set sequence=(@i:=@i+1) where tabid=@tabid order by sequence;
delimiter;

select tabid into @tabid from ld_tab where `name` = 'PurchaseInvoice';
delete from ld_field where tabid = @tabid and columnname = 'purchaseorder_id' and fieldname = 'purchaseorder_id' and uitype = 150;
delimiter;
-- 2016-03-31

update ld_desk set fieldlabel='状态' where labelbol='Orderstatus2' and languagetype='zh';
update ld_desk set fieldlabel='Status' where labelbol='Orderstatus2' and languagetype='en';

alter table ld_expensetype modify column `expensetype` varchar(100);
delimiter;

SELECT blockid INTO @blockid FROM ld_settings_blocks WHERE label='LBL_USER_MANAGEMENT';
UPDATE ld_settings_field SET iconpath='ico-tracks.png' WHERE  blockid = @blockid AND `name` ='TRACKPOSITONINGGROUP';
delimiter;

select tabid into @tabid from ld_tab where `name` = 'Rate';
select fieldid into @fieldid from ld_field where tabid = @tabid and columnname = 'smownerid';
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'zh','ld_field',@tabid,@fieldid,'负责人' from dual
where not exists(select 1 from ld_tranlabel where languagetype='zh' and tabid = @tabid and relateid = @fieldid);
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'en','ld_field',@tabid,@fieldid,'Assigned To' from dual
where not exists(select 1 from ld_tranlabel where languagetype='en' and tabid = @tabid and relateid = @fieldid);
delimiter;

CREATE TABLE IF NOT EXISTS `ld_tabdetailfield` (
  `tabdetailfieldid` int(11) NOT NULL auto_increment,
  `tabid` int(11) default NULL,
  `columnname` varchar(100) default NULL,
  `tablename` varchar(100) default NULL,
  `fieldlabel` varchar(100) default NULL,
  `defaultvalue` varchar(100) default NULL,
  `presence` int(2) default NULL,
  `fieldtype` varchar(50) default NULL,
  `typeofdata` varchar(100) default NULL,
  `sequence` int(11) default NULL,
  `width` int(11) default NULL,
  `edit_permission` int(11) default NULL,
  `input_type` int(11) default NULL,
  `fieldid` int(11) default NULL,
  `selectmodule` varchar(100) default NULL,
  `newline` int(11) default NULL,
  `defaultcolumn` int(11) default NULL,
  PRIMARY KEY  (`tabdetailfieldid`)
) ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=utf8;
delimiter;

select tabid into @tabid from ld_tab where `name` = 'Expense';
insert into ld_tabdetailfield(columnname,fieldlabel,defaultvalue,presence,fieldtype,typeofdata,sequence,tabid,tablename,width,edit_permission,input_type,fieldid,newline,defaultcolumn)
select 'expenseuse','费用用途','',2,'Text','V~M~200',1,@tabid,'ld_expensedetail',20,0,0,0,0,2 from DUAL
where not exists(select 1 from ld_tabdetailfield where tabid = @tabid and columnname = 'expenseuse');
select tabdetailfieldid into @id from ld_tabdetailfield where tabid = @tabid and columnname = 'expenseuse';
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel) 
select 'zh','ld_tabdetailfield',@tabid,@id,'费用用途' from DUAL
where not exists(select 1 from ld_tranlabel where languagetype = 'zh' and trantable = 'ld_tabdetailfield' and tabid = @tabid and relateid = @id);
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel) 
select 'en','ld_tabdetailfield',@tabid,@id,'Usage fees' from DUAL
where not exists(select 1 from ld_tranlabel where languagetype = 'en' and trantable = 'ld_tabdetailfield' and tabid = @tabid and relateid = @id);

insert into ld_tabdetailfield(columnname,fieldlabel,defaultvalue,presence,fieldtype,typeofdata,sequence,tabid,tablename,width,edit_permission,input_type,fieldid,newline,defaultcolumn)
select 'expensetype','费用类别','',2,'Select','V~O~50',2,@tabid,'ld_expensedetail',20,0,0,0,0,2 from DUAL
where not exists(select 1 from ld_tabdetailfield where tabid = @tabid and columnname = 'expensetype');
select tabdetailfieldid into @id from ld_tabdetailfield where tabid = @tabid and columnname = 'expensetype';
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel) 
select 'zh','ld_tabdetailfield',@tabid,@id,'费用类别' from DUAL
where not exists(select 1 from ld_tranlabel where languagetype = 'zh' and trantable = 'ld_tabdetailfield' and tabid = @tabid and relateid = @id);
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel) 
select 'en','ld_tabdetailfield',@tabid,@id,'Expense type' from DUAL
where not exists(select 1 from ld_tranlabel where languagetype = 'en' and trantable = 'ld_tabdetailfield' and tabid = @tabid and relateid = @id);

insert into ld_tabdetailfield(columnname,fieldlabel,defaultvalue,presence,fieldtype,typeofdata,sequence,tabid,tablename,width,edit_permission,input_type,fieldid,newline,defaultcolumn)
select 'startdate','开始日期','thismonth_start',0,'Date_Ymd','D~O',3,@tabid,'ld_expensedetail',22,0,0,0,0,3 from DUAL
where not exists(select 1 from ld_tabdetailfield where tabid = @tabid and columnname = 'startdate');
select tabdetailfieldid into @id from ld_tabdetailfield where tabid = @tabid and columnname = 'startdate';
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel) 
select 'zh','ld_tabdetailfield',@tabid,@id,'开始日期' from DUAL
where not exists(select 1 from ld_tranlabel where languagetype = 'zh' and trantable = 'ld_tabdetailfield' and tabid = @tabid and relateid = @id);
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel) 
select 'en','ld_tabdetailfield',@tabid,@id,'Start Date' from DUAL
where not exists(select 1 from ld_tranlabel where languagetype = 'en' and trantable = 'ld_tabdetailfield' and tabid = @tabid and relateid = @id);

insert into ld_tabdetailfield(columnname,fieldlabel,defaultvalue,presence,fieldtype,typeofdata,sequence,tabid,tablename,width,edit_permission,input_type,fieldid,newline,defaultcolumn)
select 'enddate','结束日期','thismonth_end',0,'Date_Ymd','D~O',4,@tabid,'ld_expensedetail',22,0,0,0,0,3 from DUAL
where not exists(select 1 from ld_tabdetailfield where tabid = @tabid and columnname = 'enddate');
select tabdetailfieldid into @id from ld_tabdetailfield where tabid = @tabid and columnname = 'enddate';
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel) 
select 'zh','ld_tabdetailfield',@tabid,@id,'结束日期' from DUAL
where not exists(select 1 from ld_tranlabel where languagetype = 'zh' and trantable = 'ld_tabdetailfield' and tabid = @tabid and relateid = @id);
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel) 
select 'en','ld_tabdetailfield',@tabid,@id,'End Date' from DUAL
where not exists(select 1 from ld_tranlabel where languagetype = 'en' and trantable = 'ld_tabdetailfield' and tabid = @tabid and relateid = @id);

insert into ld_tabdetailfield(columnname,fieldlabel,defaultvalue,presence,fieldtype,typeofdata,sequence,tabid,tablename,width,edit_permission,input_type,fieldid,newline,defaultcolumn,selectmodule)
select 'projectid','项目名称','',0,'SelectSource','V~O~30',5,@tabid,'ld_expensedetailscf',50,0,0,0,0,2,'Project' from DUAL
where not exists(select 1 from ld_tabdetailfield where tabid = @tabid and columnname = 'projectid');
select tabdetailfieldid into @id from ld_tabdetailfield where tabid = @tabid and columnname = 'projectid';
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel) 
select 'zh','ld_tabdetailfield',@tabid,@id,'项目名称' from DUAL
where not exists(select 1 from ld_tranlabel where languagetype = 'zh' and trantable = 'ld_tabdetailfield' and tabid = @tabid and relateid = @id);
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel) 
select 'en','ld_tabdetailfield',@tabid,@id,'Porject Name' from DUAL
where not exists(select 1 from ld_tranlabel where languagetype = 'en' and trantable = 'ld_tabdetailfield' and tabid = @tabid and relateid = @id);

insert into ld_tabdetailfield(columnname,fieldlabel,defaultvalue,presence,fieldtype,typeofdata,sequence,tabid,tablename,width,edit_permission,input_type,fieldid,newline,defaultcolumn)
select 'currency_id','币种',1,0,'SelectCurrency','V~M',6,@tabid,'ld_expensedetailscf',20,0,0,0,0,2 from DUAL
where not exists(select 1 from ld_tabdetailfield where tabid = @tabid and columnname = 'currency_id');
select tabdetailfieldid into @id from ld_tabdetailfield where tabid = @tabid and columnname = 'currency_id';
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel) 
select 'zh','ld_tabdetailfield',@tabid,@id,'币种' from DUAL
where not exists(select 1 from ld_tranlabel where languagetype = 'zh' and trantable = 'ld_tabdetailfield' and tabid = @tabid and relateid = @id);
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel) 
select 'en','ld_tabdetailfield',@tabid,@id,'Currency' from DUAL
where not exists(select 1 from ld_tranlabel where languagetype = 'en' and trantable = 'ld_tabdetailfield' and tabid = @tabid and relateid = @id);

insert into ld_tabdetailfield(columnname,fieldlabel,defaultvalue,presence,fieldtype,typeofdata,sequence,tabid,tablename,width,edit_permission,input_type,fieldid,newline,defaultcolumn)
select 'conversion_rate','汇率','1.000000',0,'Num','N~O~25,6',7,@tabid,'ld_expensedetailscf',20,0,0,0,0,2 from DUAL
where not exists(select 1 from ld_tabdetailfield where tabid = @tabid and columnname = 'conversion_rate');
select tabdetailfieldid into @id from ld_tabdetailfield where tabid = @tabid and columnname = 'conversion_rate';
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel) 
select 'zh','ld_tabdetailfield',@tabid,@id,'汇率' from DUAL
where not exists(select 1 from ld_tranlabel where languagetype = 'zh' and trantable = 'ld_tabdetailfield' and tabid = @tabid and relateid = @id);
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel) 
select 'en','ld_tabdetailfield',@tabid,@id,'Conversion_rate' from DUAL
where not exists(select 1 from ld_tranlabel where languagetype = 'en' and trantable = 'ld_tabdetailfield' and tabid = @tabid and relateid = @id);

insert into ld_tabdetailfield(columnname,fieldlabel,defaultvalue,presence,fieldtype,typeofdata,sequence,tabid,tablename,width,edit_permission,input_type,fieldid,newline,defaultcolumn)
select 'money','报销金额','',0,'Amount','N~O~20,8',8,@tabid,'ld_expensedetail',20,0,0,0,0,2 from DUAL
where not exists(select 1 from ld_tabdetailfield where tabid = @tabid and columnname = 'money');
select tabdetailfieldid into @id from ld_tabdetailfield where tabid = @tabid and columnname = 'money';
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel) 
select 'zh','ld_tabdetailfield',@tabid,@id,'报销金额' from DUAL
where not exists(select 1 from ld_tranlabel where languagetype = 'zh' and trantable = 'ld_tabdetailfield' and tabid = @tabid and relateid = @id);
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel) 
select 'en','ld_tabdetailfield',@tabid,@id,'Reimbursement Amount' from DUAL
where not exists(select 1 from ld_tranlabel where languagetype = 'en' and trantable = 'ld_tabdetailfield' and tabid = @tabid and relateid = @id);

insert into ld_tabdetailfield(columnname,fieldlabel,defaultvalue,presence,fieldtype,typeofdata,sequence,tabid,tablename,width,edit_permission,input_type,fieldid,newline,defaultcolumn)
select 'rmb_total','人民币金额','',0,'Amount','N~O~20,8',9,@tabid,'ld_expensedetailscf',22,1,0,0,0,2 from DUAL
where not exists(select 1 from ld_tabdetailfield where tabid = @tabid and columnname = 'rmb_total');
select tabdetailfieldid into @id from ld_tabdetailfield where tabid = @tabid and columnname = 'rmb_total';
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel) 
select 'zh','ld_tabdetailfield',@tabid,@id,'人民币金额' from DUAL
where not exists(select 1 from ld_tranlabel where languagetype = 'zh' and trantable = 'ld_tabdetailfield' and tabid = @tabid and relateid = @id);
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel) 
select 'en','ld_tabdetailfield',@tabid,@id,'RMB Total' from DUAL
where not exists(select 1 from ld_tranlabel where languagetype = 'en' and trantable = 'ld_tabdetailfield' and tabid = @tabid and relateid = @id);

insert into ld_tabdetailfield(columnname,fieldlabel,defaultvalue,presence,fieldtype,typeofdata,sequence,tabid,tablename,width,edit_permission,input_type,fieldid,newline,defaultcolumn)
select 'description','备注','',0,'TextArea','V~O~200',10,@tabid,'ld_expensedetail',100,0,0,0,0,3 from DUAL
where not exists(select 1 from ld_tabdetailfield where tabid = @tabid and columnname = 'description');
select tabdetailfieldid into @id from ld_tabdetailfield where tabid = @tabid and columnname = 'description';
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel) 
select 'zh','ld_tabdetailfield',@tabid,@id,'备注' from DUAL
where not exists(select 1 from ld_tranlabel where languagetype = 'zh' and trantable = 'ld_tabdetailfield' and tabid = @tabid and relateid = @id);
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel) 
select 'en','ld_tabdetailfield',@tabid,@id,'Remark' from DUAL
where not exists(select 1 from ld_tranlabel where languagetype = 'en' and trantable = 'ld_tabdetailfield' and tabid = @tabid and relateid = @id);

insert into ld_tabdetailfield(columnname,fieldlabel,defaultvalue,presence,fieldtype,typeofdata,sequence,tabid,tablename,width,edit_permission,input_type,fieldid,newline,defaultcolumn)
select 'total','合计',0,0,'Span','N~O~25,6',11,@tabid,'ld_expense',22,0,0,0,1,2 from DUAL
where not exists(select 1 from ld_tabdetailfield where tabid = @tabid and columnname = 'total');
select tabdetailfieldid into @id from ld_tabdetailfield where tabid = @tabid and columnname = 'total';
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel) 
select 'zh','ld_tabdetailfield',@tabid,@id,'合计' from DUAL
where not exists(select 1 from ld_tranlabel where languagetype = 'zh' and trantable = 'ld_tabdetailfield' and tabid = @tabid and relateid = @id);
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel) 
select 'en','ld_tabdetailfield',@tabid,@id,'Total' from DUAL
where not exists(select 1 from ld_tranlabel where languagetype = 'en' and trantable = 'ld_tabdetailfield' and tabid = @tabid and relateid = @id);
delimiter;

CREATE TABLE IF NOT EXISTS `ld_tabdetailfield_formula` (
  `formulaid` int(19) NOT NULL auto_increment,
  `tabdetailfieldid` int(19) default NULL,
  `formulastring` varchar(255) default NULL,
  `columnstring` text,
  `sequence` int(11) default '0',
  PRIMARY KEY  (`formulaid`)
) ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=utf8;
select tabid into @tabid from ld_tab where `name` = 'Expense';
select tabdetailfieldid into @tabdetailfieldid from ld_tabdetailfield where tabid = @tabid and columnname = 'rmb_total';
insert into ld_tabdetailfield_formula(tabdetailfieldid,formulastring,columnstring,sequence)
select @tabdetailfieldid,'a$b','{formulavar:[{\'lettervar\':\'a\',\'column\':\'money\'},{\'lettervar\':\'b\',\'column\':\'conversion_rate\'}]}',0 from DUAL
where not exists(select 1 from ld_tabdetailfield_formula where tabdetailfieldid = @tabdetailfieldid);
delimiter;

CREATE TABLE IF NOT EXISTS `ld_tabdetailfield_relation` (
  `relation_id` int(11) NOT NULL auto_increment,
  `tabdetailfieldid` int(11) default NULL,
  `relation_columnname` varchar(255) default NULL,
  PRIMARY KEY  (`relation_id`)
) ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=utf8;
select tabid into @tabid from ld_tab where `name` = 'Expense';
select tabdetailfieldid into @tabdetailfieldid from ld_tabdetailfield where tabid = @tabid and columnname = 'currency_id';
insert into ld_tabdetailfield_relation(tabdetailfieldid,relation_columnname)
select @tabdetailfieldid,'conversion_rate' from DUAL
where not exists(select 1 from ld_tabdetailfield_relation where tabdetailfieldid = @tabdetailfieldid and relation_columnname = 'conversion_rate');
delimiter;

CREATE TABLE IF NOT EXISTS `ld_tabdetailprofile` (
  `profileid` int(11) NOT NULL auto_increment,
  `tabdetailfieldid` int(11) default NULL COMMENT '自定义字段id',
  `tabid` int(11) default NULL COMMENT '模块id',
  `userid` int(11) default NULL COMMENT '用户id',
  PRIMARY KEY  (`profileid`)
) ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=utf8;
delimiter;

CREATE TABLE IF NOT EXISTS `ld_expensedetailscf` ( 
`expensedetailid` int(11) NOT NULL default '0', 
`projectid` int(11) default NULL, 
`currency_id` int(11) default NULL, 
`conversion_rate` decimal(25,6) default NULL, 
`rmb_total` decimal(25,8) default NULL, 
PRIMARY KEY (`expensedetailid`) 
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

DROP PROCEDURE IF  EXISTS  `insert_tabwithproductview`;
delimiter ||
CREATE PROCEDURE `insert_tabwithproductview` (
	modulename varchar(200)
)
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

declare cur1 CURSOR FOR select tabid,cvid,`name` from ld_tab inner join ld_customview on ld_tab.`name` = ld_customview.entitytype where ld_tab.`name` = modulename; 
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
fetch cur1 into p_tabid,p_cvid,p_name;
end while loop2; 
close cur1; 
end ||
delimiter;

call insert_tabwithproductview('Expense');
delimiter;

select tabid into @tabid from ld_tab where `name` = 'Expense';
update ld_field set presence = 1 where tabid = @tabid and columnname = 'currency_id';
delimiter;

SELECT tabid INTO @tabid FROM ld_tab WHERE `name`='Potentials';
SELECT sequence INTO @sequence from ld_quickactions where tabid=@tabid AND related_tabid=22;
update ld_quickactions set sequence = sequence + 1 where tabid=@tabid AND sequence > @sequence;
SELECT max(relation_id) INTO @relation_id FROM ld_quickactions;
INSERT INTO  ld_quickactions(relation_id,tabid,related_tabid,sequence,presence,label) 
SELECT @relation_id+1,@tabid,37,@sequence+1,0,null
FROM DUAL WHERE NOT EXISTS(SELECT 1 FROM ld_quickactions WHERE tabid=@tabid AND related_tabid=37);
set @i=0;
update ld_quickactions set sequence=(@i:=@i+1) where tabid=@tabid order by sequence;
delimiter;
UPDATE ld_field set presence=1 WHERE tabid=102 AND fieldname='servicegroup';
delimiter;
call AddColumn('ld_potential','lastcontactuser','int',19,0);
delimiter;
insert into ld_field(tabid,fieldid,columnname,tablename,uitype,fieldname,fieldlabel,sequence,block,displaytype,presence,typeofdata)
select 2,(select max(fieldid) from ld_field)+1,'lastcontactuser','ld_potential',52,'lastcontactuser','最新联系人',(select max(sequence) from ld_field)+1,
(select blockid from ld_blocks where blocklabel = 'LBL_OPPORTUNITY_INFORMATION'),1,0,'V~O' from dual where not exists 
(select * from ld_field where tabid = 2 and columnname = 'lastcontactuser');

select tabid into @tabid from ld_tab where `name` = 'Potentials';
select fieldid into @fieldid from ld_field where tabid = @tabid and fieldname = 'lastcontactuser';
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'zh','ld_field',@tabid,@fieldid,'最新联系人' 
from dual where not EXISTS(select 1 from ld_tranlabel  where languagetype = 'zh' 
and trantable ='ld_field' and tabid = @tabid and relateid=@fieldid);

insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'en','ld_field',@tabid,@fieldid,'lastcontactuser' 
from dual where not EXISTS(select 1 from ld_tranlabel  where languagetype = 'en' 
and trantable ='ld_field' and tabid = @tabid and relateid=@fieldid);
delimiter;
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'zh','NEXTEXAMINATIONANDAPPROVALCONTROL','下一步审批控制','fixedstr'
from dual where not EXISTS(select 1 from ld_desk where languagetype='zh' and labelbol='NEXTEXAMINATIONANDAPPROVALCONTROL' and Labeltype='fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'en','NEXTEXAMINATIONANDAPPROVALCONTROL','Next examination and approval control','fixedstr'
from dual where not EXISTS(select 1 from ld_desk  where languagetype='en' and labelbol='NEXTEXAMINATIONANDAPPROVALCONTROL' and Labeltype='fixedstr');
delimiter;
update ld_field set uitype=7,typeofdata='NN~O~50,0' where columnname='targetsize' and tabid=26;
delimiter;
update ld_relatedlists set presence=0 where tabid in(6,2,78,9) AND `name`='get_SharedUsers';
delimiter;

select Parent_id  into @parentid from ld_usereport where name='AttendanceReport';
insert into ld_usereport(name,reportlabel,tabids,basicfilter,advfilter,setcolumns,Parent_id,sequence,reporttype,pagewidthpercent)
select 'USERTRACKREPORT','移动轨迹',0,1,0,0,@parentid,2,55,100 from dual
 where not EXISTS(select 1 from ld_usereport where name='USERTRACKREPORT');

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','USERTRACKREPORT','移动轨迹','fixedstr' from DUAL
where not EXISTS(select 1 from ld_desk where labelbol='USERTRACKREPORT' and languagetype='zh' and labeltype='fixedstr');

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','USERTRACKREPORT','Move Track','fixedstr' from DUAL
where not EXISTS(select 1 from ld_desk where labelbol='USERTRACKREPORT' and languagetype='en' and labeltype='fixedstr');
delimiter;

select tabid into @tabid from ld_tab  where `name`='Expense';
select tabdetailfieldid into @tabdetailfieldid from ld_tabdetailfield where tabid=@tabid and columnname='conversion_rate';
update ld_tranlabel set fieldlabel='Exch.Rate' 
where trantable='ld_tabdetailfield' and tabid=@tabid and Relateid=@tabdetailfieldid and languagetype='en';

select tabdetailfieldid into @tabdetailfieldid from ld_tabdetailfield where tabid=@tabid and columnname='rmb_total';
update ld_tranlabel set fieldlabel='Amount(RMB)' 
where trantable='ld_tabdetailfield' and tabid=@tabid and Relateid=@tabdetailfieldid and languagetype='en';

select tabdetailfieldid into @tabdetailfieldid from ld_tabdetailfield where tabid=@tabid and columnname='money';
update ld_tranlabel set fieldlabel='Amount' 
where trantable='ld_tabdetailfield' and tabid=@tabid and Relateid=@tabdetailfieldid and languagetype='en';
delimiter;

select tabid into @tabid from ld_tab where `name`='Rate';
update ld_field set fieldlabel='费率',uitype=7,typeofdata='N~O~25,6' where tabid=@tabid and columnname='rate';
delimiter;

alter table ld_rate modify column `rate` decimal(25,6);
delimiter;
-- 2016-04-08

update ld_desk set fieldlabel='Distribute' where labelbol='ALLOCATE' and languagetype='en';
update ld_desk set fieldlabel='Distribute' where labelbol='DISTRIBUT' and languagetype='en';
update ld_desk set fieldlabel='Confirm' where labelbol='CONFIRME' and languagetype='en';
update ld_attachmentsforbills set record=related_to where record<>related_to;


CREATE TABLE IF NOT EXISTS `ld_timesheet`(
  `timesheet_id` int(11) NOT NULL AUTO_INCREMENT,  
  `timesheet_no` varchar(100) DEFAULT NULL, 
  `smownerid` int(11) DEFAULT '0',
  `smcreatorid` int(11) DEFAULT '0',
  `modifiedby` int(11) DEFAULT '0',
  `approveby` int(11) DEFAULT NULL,
  `approvestatus` VARCHAR(200) DEFAULT NULL,
  `createdtime` datetime DEFAULT NULL,
  `modifiedtime` datetime DEFAULT NULL,
  `sum_direct` DECIMAL(10,1) DEFAULT NULL,
  `sum_indirect` DECIMAL(10,1) DEFAULT NULL,
  `deleted` int(11) DEFAULT '0',
  PRIMARY KEY (`timesheet_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
delimiter;

CREATE TABLE IF NOT EXISTS  `ld_timesheetcf`(
  `timesheet_id` int(11) NOT NULL DEFAULT '0',
  PRIMARY KEY (`timesheet_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
delimiter;

CREATE TABLE  IF  not EXISTS`ld_timesheetdetail` (
  `timesheetdetail_id` int(11) NOT NULL AUTO_INCREMENT,
  `timesheet_id` int(11) DEFAULT NULL,
  `workdate` date DEFAULT NULL,
  `timetype` varchar(255) DEFAULT NULL,
  `costtime` varchar(100) DEFAULT NULL,
  `project_id` varchar(500) DEFAULT NULL,
  `indirectcharge` varchar(500) DEFAULT NULL,
  `description` text,
  `sequence` int(11) DEFAULT NULL,
  PRIMARY KEY (`timesheetdetail_id`)
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=utf8;
delimiter;

CREATE TABLE IF NOT EXISTS `ld_timesheetdetailscf`(
  `timesheetdetail_id` int(11) NOT NULL DEFAULT '0',
  PRIMARY KEY (`timesheetdetail_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
delimiter;

CREATE TABLE IF NOT EXISTS `ld_timetype`(
  `timetype_id` int(11) NOT NULL DEFAULT '0',	
  `timetype` VARCHAR(255) DEFAULT NULL,
  `presence` INT(11) DEFAULT NULL,
  `Picklist_valueid` INT(11) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
delimiter;

CREATE TABLE  IF NOT EXISTS `ld_indirectcharge`(
  `indirectcharge_id` int(11) NOT NULL DEFAULT '0',
	`indirectcharge` VARCHAR(255) DEFAULT NULL,  
  `presence` INT(11) DEFAULT NULL,
  `Picklist_valueid` INT(11) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
delimiter;

CREATE TABLE  IF NOT EXISTS `ld_costtime` (
  `costtime_id` int(11) NOT NULL DEFAULT '0',
	`costtime` VARCHAR(100) DEFAULT NULL,  
  `presence` INT(11) DEFAULT NULL,
  `Picklist_valueid` INT(11) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
delimiter;

select max(tabid) into @tabid from ld_tab;
select max(tabsequence) into @tabsequence from ld_tab;
insert into ld_tab(tabid,name,presence,tabsequence,tablabel,isentitytype,parent,printtab)
select @tabid + 1,'TimeSheet',5,@tabsequence+1,'TimeSheet',1,'Project',0 
from dual where not EXISTS(select 1 from ld_tab where `name`='TimeSheet');
delimiter;

SELECT tabid INTO @tabid_PM from ld_tab where `name`='ProjectMilestone';
select parenttabid into @parenttabid from ld_parenttab where  parenttab_label='Project';
SELECT sequence INTO @sequence from ld_parenttabrel where tabid=@tabid_PM and parenttabid=@parenttabid;
select tabid into @tabid from ld_tab where `name` = 'TimeSheet';

insert into ld_parenttabrel(parenttabid,tabid,sequence)
select @parenttabid,@tabid,@sequence+1 
from dual where not EXISTS(select 1 from ld_parenttabrel  where parenttabid = @parenttabid and tabid =@tabid);
delimiter;

select tabid into @tabid from ld_tab where `name` = 'TimeSheet';
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'zh','ld_tab',@tabid,@tabid,'工时管理' 
from dual where not EXISTS(select 1 from ld_tranlabel  where languagetype = 'zh' 
and trantable ='ld_tab' and tabid = @tabid and Relateid=@tabid);
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'en','ld_tab',@tabid,@tabid,'TimeSheet' 
from dual where not EXISTS(select 1 from ld_tranlabel  where languagetype = 'en' 
and trantable ='ld_tab' and tabid = @tabid and Relateid=@tabid);
delimiter;

call fieldprofile('TimeSheet');
delimiter;
call getallprofile('TimeSheet');
delimiter;
call addtabintoprofile('TimeSheet',0);
delimiter;

select tabid into @tabid from ld_tab where `name` = 'TimeSheet';
update ld_profile2standardpermissions set permissions = 1 where tabid = @tabid and profileid not in (
select ld_role2profile.profileid from ld_users 
inner join ld_user2role on ld_users.id = ld_user2role.userid
inner join ld_role2profile on ld_role2profile.roleid = ld_user2role.roleid  where is_admin = 'on');
delimiter;

select tabid into @tabid from ld_tab where `name` = 'TimeSheet';
insert into ld_org_share_action2tab(share_action_id,tabid) select 0,@tabid from dual 
where not exists(select 1 from ld_org_share_action2tab where share_action_id=0 and tabid=@tabid);
delimiter;

insert into ld_org_share_action2tab(share_action_id,tabid) select 1,@tabid from dual 
where not exists(select 1 from ld_org_share_action2tab where share_action_id=1 and tabid=@tabid);
delimiter;

insert into ld_org_share_action2tab(share_action_id,tabid) select 2,@tabid from dual 
where not exists(select 1 from ld_org_share_action2tab where share_action_id=2 and tabid=@tabid);
delimiter;

insert into ld_org_share_action2tab(share_action_id,tabid) select 3,@tabid from dual 
where not exists(select 1 from ld_org_share_action2tab where share_action_id=3 and tabid=@tabid);
delimiter;

select max(ruleid) into @ruleid from ld_def_org_share;
update ld_def_org_share_seq set id=@ruleid+1 where  not exists(select 1 from ld_def_org_share where tabid=@tabid);
insert into ld_def_org_share(ruleid,tabid,permission,editstatus)
select @ruleid+1,@tabid,3,0  from dual where  not exists(select 1 from ld_def_org_share where tabid=@tabid);
delimiter;

select tabid into @tabid from ld_tab where `name` = 'TimeSheet';
insert into ld_blocks(blockid,tabid,blocklabel,sequence)
select (select max(blockid) from ld_blocks)+1,@tabid,'LBL_TIMESHEET_INFO',1 from dual where not exists (select * from ld_blocks where 
tabid = @tabid and blocklabel = 'LBL_TIMESHEET_INFO' and sequence = 1);
delimiter;

insert into ld_field(tabid,fieldid,columnname,tablename,uitype,fieldname,fieldlabel,block,displaytype,presence,typeofdata,generatedtype,sequence,issmownerid)
select @tabid,(select max(fieldid) from ld_field)+1,'smownerid','ld_timesheet',53,'assigned_user_id','工程师',(select blockid from ld_blocks where blocklabel = 'LBL_TIMESHEET_INFO'),1,0,'V~M',1,1,1 from dual where not exists 
(select 1 from ld_field where tabid = @tabid and columnname = 'smownerid');
delimiter;

insert into ld_field(tabid,fieldid,columnname,tablename,uitype,fieldname,fieldlabel,block,displaytype,presence,typeofdata,generatedtype,sequence)
select @tabid,(select max(fieldid) from ld_field)+1,'timesheet_no','ld_timesheet',4,'timesheet_no','工时编号',(select blockid from ld_blocks where blocklabel = 'LBL_TIMESHEET_INFO'),1,0,'V~M',2,2 from dual where not exists 
(select 1 from ld_field where tabid = @tabid and columnname = 'timesheet_no');
delimiter;

insert into ld_field(tabid,fieldid,columnname,tablename,uitype,fieldname,fieldlabel,block,displaytype,presence,typeofdata,generatedtype,sequence)
select @tabid,(select max(fieldid) from ld_field)+1,'smcreatorid','ld_timesheet',52,'smcreatorid','创建人',(select blockid from ld_blocks where blocklabel = 'LBL_TIMESHEET_INFO'),2,0,'V~O',1,3 from dual where not exists 
(select 1 from ld_field where tabid = @tabid and columnname = 'smcreatorid');
delimiter;

insert into ld_field(tabid,fieldid,columnname,tablename,uitype,fieldname,fieldlabel,block,displaytype,presence,typeofdata,generatedtype,sequence)
select @tabid,(select max(fieldid) from ld_field)+1,'modifiedby','ld_timesheet',52,'modifiedby','修改人',(select blockid from ld_blocks where blocklabel = 'LBL_TIMESHEET_INFO'),2,0,'V~O',1,4 from dual where not exists 
(select 1 from ld_field where tabid = @tabid and columnname = 'modifiedby');
delimiter;
insert into ld_field(tabid,fieldid,columnname,tablename,uitype,fieldname,fieldlabel,block,displaytype,presence,typeofdata,generatedtype,sequence)
select @tabid,(select max(fieldid) from ld_field)+1,'approveby','ld_timesheet',131,'approveby','审批人',(select blockid from ld_blocks where blocklabel = 'LBL_TIMESHEET_INFO'),2,0,'V~O',1,5 from dual where not exists 
(select 1 from ld_field where tabid = @tabid and columnname = 'approveby');
delimiter;

insert into ld_field(tabid,fieldid,columnname,tablename,uitype,fieldname,fieldlabel,block,displaytype,presence,defaultvalue,typeofdata,generatedtype,sequence)
select @tabid,(select max(fieldid) from ld_field)+1,'approvestatus','ld_timesheet',130,'approvestatus','审批状态',(select blockid from ld_blocks where blocklabel = 'LBL_TIMESHEET_INFO'),2,0,'未提交','V~O',1,6 from dual where not exists 
(select 1 from ld_field where tabid = @tabid and columnname = 'approvestatus');
delimiter;

insert into ld_field(tabid,fieldid,columnname,tablename,uitype,fieldname,fieldlabel,block,displaytype,presence,typeofdata,generatedtype,sequence)
select @tabid,(select max(fieldid) from ld_field)+1,'createdtime','ld_timesheet',70,'createdtime','创建日期',(select blockid from ld_blocks where blocklabel = 'LBL_TIMESHEET_INFO'),2,0,'DT~O',1,7 from dual where not exists 
(select 1 from ld_field where tabid = @tabid and columnname = 'createdtime');
delimiter;

insert into ld_field(tabid,fieldid,columnname,tablename,uitype,fieldname,fieldlabel,block,displaytype,presence,typeofdata,generatedtype,sequence)
select @tabid,(select max(fieldid) from ld_field)+1,'modifiedtime','ld_timesheet',70,'modifiedtime','修改日期',(select blockid from ld_blocks where blocklabel = 'LBL_TIMESHEET_INFO'),2,0,'DT~O',1,8 from dual where not exists 
(select 1 from ld_field where tabid = @tabid and columnname = 'modifiedtime');
delimiter;

insert into ld_field(tabid,fieldid,columnname,tablename,uitype,fieldname,fieldlabel,block,displaytype,presence,typeofdata,generatedtype,sequence)
select @tabid,(select max(fieldid) from ld_field)+1,'sum_direct','ld_timesheet',7,'sum_direct','直接工时合计',(select blockid from ld_blocks where blocklabel = 'LBL_TIMESHEET_INFO'),3,0,'V~O',1,9 from dual where not exists 
(select 1 from ld_field where tabid = @tabid and columnname = 'sum_direct');
delimiter;

insert into ld_field(tabid,fieldid,columnname,tablename,uitype,fieldname,fieldlabel,block,displaytype,presence,typeofdata,generatedtype,sequence)
select @tabid,(select max(fieldid) from ld_field)+1,'sum_indirect','ld_timesheet',7,'sum_indirect','间接工时合计',(select blockid from ld_blocks where blocklabel = 'LBL_TIMESHEET_INFO'),3,0,'V~O',1,10 from dual where not exists 
(select 1 from ld_field where tabid = @tabid and columnname = 'sum_indirect');
delimiter;

insert into ld_tabdetailfield(columnname,fieldlabel,defaultvalue,presence,fieldtype,typeofdata,sequence,tabid,tablename,width,edit_permission,input_type,fieldid,newline,defaultcolumn)
select 'workdate','日期','thistoday',0,'Date_Ymd','D~O',1,@tabid,'ld_timesheetdetail',22,0,0,0,0,2 from DUAL
where not exists(select 1 from ld_tabdetailfield where tabid = @tabid and columnname = 'workdate');
select tabdetailfieldid into @id from ld_tabdetailfield where tabid = @tabid and columnname = 'workdate';
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel) 
select 'zh','ld_tabdetailfield',@tabid,@id,'日期' from DUAL
where not exists(select 1 from ld_tranlabel where languagetype = 'zh' and trantable = 'ld_tabdetailfield' and tabid = @tabid and relateid = @id);
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel) 
select 'en','ld_tabdetailfield',@tabid,@id,'Date' from DUAL
where not exists(select 1 from ld_tranlabel where languagetype = 'en' and trantable = 'ld_tabdetailfield' and tabid = @tabid and relateid = @id);
delimiter;

insert into ld_tabdetailfield(columnname,fieldlabel,defaultvalue,presence,fieldtype,typeofdata,sequence,tabid,tablename,width,edit_permission,input_type,fieldid,newline,defaultcolumn)
select 'timetype','类型','',0,'Select','V~O~50',2,@tabid,'ld_timesheetdetail',20,0,0,0,0,2 from DUAL
where not exists(select 1 from ld_tabdetailfield where tabid = @tabid and columnname = 'timetype');
select tabdetailfieldid into @id from ld_tabdetailfield where tabid = @tabid and columnname = 'timetype';
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel) 
select 'zh','ld_tabdetailfield',@tabid,@id,'类型' from DUAL
where not exists(select 1 from ld_tranlabel where languagetype = 'zh' and trantable = 'ld_tabdetailfield' and tabid = @tabid and relateid = @id);
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel) 
select 'en','ld_tabdetailfield',@tabid,@id,'Type' from DUAL
where not exists(select 1 from ld_tranlabel where languagetype = 'en' and trantable = 'ld_tabdetailfield' and tabid = @tabid and relateid = @id);
delimiter;

insert into ld_tabdetailfield(columnname,fieldlabel,defaultvalue,presence,fieldtype,typeofdata,sequence,tabid,tablename,width,edit_permission,input_type,fieldid,newline,defaultcolumn,selectmodule)
select 'projectid','项目','',0,'SelectSource','V~O~30',3,@tabid,'ld_timesheetdetail',50,0,0,0,0,2,'Project' from DUAL
where not exists(select 1 from ld_tabdetailfield where tabid = @tabid and columnname = 'projectid');
select tabdetailfieldid into @id from ld_tabdetailfield where tabid = @tabid and columnname = 'projectid';
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel) 
select 'zh','ld_tabdetailfield',@tabid,@id,'项目' from DUAL
where not exists(select 1 from ld_tranlabel where languagetype = 'zh' and trantable = 'ld_tabdetailfield' and tabid = @tabid and relateid = @id);
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel) 
select 'en','ld_tabdetailfield',@tabid,@id,'Charge Numbers' from DUAL
where not exists(select 1 from ld_tranlabel where languagetype = 'en' and trantable = 'ld_tabdetailfield' and tabid = @tabid and relateid = @id);
delimiter;

insert into ld_tabdetailfield(columnname,fieldlabel,defaultvalue,presence,fieldtype,typeofdata,sequence,tabid,tablename,width,edit_permission,input_type,fieldid,newline,defaultcolumn)
select 'indirectcharge','非项目','',0,'Select','V~O~50',4,@tabid,'ld_timesheetdetail',20,0,0,0,0,2 from DUAL
where not exists(select 1 from ld_tabdetailfield where tabid = @tabid and columnname = 'indirectcharge');
select tabdetailfieldid into @id from ld_tabdetailfield where tabid = @tabid and columnname = 'indirectcharge';
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel) 
select 'zh','ld_tabdetailfield',@tabid,@id,'非项目' from DUAL
where not exists(select 1 from ld_tranlabel where languagetype = 'zh' and trantable = 'ld_tabdetailfield' and tabid = @tabid and relateid = @id);
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel) 
select 'en','ld_tabdetailfield',@tabid,@id,'Indirect Charge' from DUAL
where not exists(select 1 from ld_tranlabel where languagetype = 'en' and trantable = 'ld_tabdetailfield' and tabid = @tabid and relateid = @id);
delimiter;

insert into ld_tabdetailfield(columnname,fieldlabel,defaultvalue,presence,fieldtype,typeofdata,sequence,tabid,tablename,width,edit_permission,input_type,fieldid,newline,defaultcolumn)
select 'costtime','工时','',0,'Select','V~O~50',5,@tabid,'ld_timesheetdetail',20,0,0,0,0,2 from DUAL
where not exists(select 1 from ld_tabdetailfield where tabid = @tabid and columnname = 'costtime');
select tabdetailfieldid into @id from ld_tabdetailfield where tabid = @tabid and columnname = 'costtime';
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel) 
select 'zh','ld_tabdetailfield',@tabid,@id,'工时' from DUAL
where not exists(select 1 from ld_tranlabel where languagetype = 'zh' and trantable = 'ld_tabdetailfield' and tabid = @tabid and relateid = @id);
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel) 
select 'en','ld_tabdetailfield',@tabid,@id,'Time' from DUAL
where not exists(select 1 from ld_tranlabel where languagetype = 'en' and trantable = 'ld_tabdetailfield' and tabid = @tabid and relateid = @id);
delimiter;

insert into ld_tabdetailfield(columnname,fieldlabel,defaultvalue,presence,fieldtype,typeofdata,sequence,tabid,tablename,width,edit_permission,input_type,fieldid,newline,defaultcolumn)
select 'description','备注','',0,'TextArea','V~O~200',6,@tabid,'ld_timesheetdetail',100,0,0,0,0,3 from DUAL
where not exists(select 1 from ld_tabdetailfield where tabid = @tabid and columnname = 'description');
select tabdetailfieldid into @id from ld_tabdetailfield where tabid = @tabid and columnname = 'description';
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel) 
select 'zh','ld_tabdetailfield',@tabid,@id,'备注' from DUAL
where not exists(select 1 from ld_tranlabel where languagetype = 'zh' and trantable = 'ld_tabdetailfield' and tabid = @tabid and relateid = @id);
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel) 
select 'en','ld_tabdetailfield',@tabid,@id,'Description' from DUAL
where not exists(select 1 from ld_tranlabel where languagetype = 'en' and trantable = 'ld_tabdetailfield' and tabid = @tabid and relateid = @id);
delimiter;

select tabid into @tabid from ld_tab where `name` = 'TimeSheet';
select blockid into @blockid from ld_blocks where tabid = @tabid and blocklabel = 'LBL_TIMESHEET_INFO';
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'zh','ld_blocks',@tabid,@blockid ,'基本信息' 
from dual where not EXISTS(select 1 from ld_tranlabel  where languagetype = 'zh' 
and trantable ='ld_blocks' and tabid = @tabid and relateid=@blockid);
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'en','ld_blocks',@tabid,@blockid,'Basic Information' 
from dual where not EXISTS(select 1 from ld_tranlabel  where languagetype = 'en' 
and trantable ='ld_blocks' and tabid = @tabid and relateid=@blockid);
delimiter;

select fieldid into @fieldid from ld_field where tabid = @tabid and fieldname = 'assigned_user_id';
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'zh','ld_field',@tabid,@fieldid,'工程师' 
from dual where not EXISTS(select 1 from ld_tranlabel  where languagetype = 'zh' 
and trantable ='ld_field' and tabid = @tabid and relateid=@fieldid);
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'en','ld_field',@tabid,@fieldid,'Engineer' 
from dual where not EXISTS(select 1 from ld_tranlabel  where languagetype = 'en' 
and trantable ='ld_field' and tabid = @tabid and relateid=@fieldid);
delimiter;

select fieldid into @fieldid from ld_field where tabid = @tabid and fieldname = 'timesheet_no';
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'zh','ld_field',@tabid,@fieldid,'工时编号' 
from dual where not EXISTS(select 1 from ld_tranlabel  where languagetype = 'zh' 
and trantable ='ld_field' and tabid = @tabid and relateid=@fieldid);
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'en','ld_field',@tabid,@fieldid,'Reimbursement No' 
from dual where not EXISTS(select 1 from ld_tranlabel  where languagetype = 'en' 
and trantable ='ld_field' and tabid = @tabid and relateid=@fieldid);
delimiter;

select fieldid into @fieldid from ld_field where tabid = @tabid and fieldname = 'smcreatorid';
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'zh','ld_field',@tabid,@fieldid,'创建人' 
from dual where not EXISTS(select 1 from ld_tranlabel  where languagetype = 'zh' 
and trantable ='ld_field' and tabid = @tabid and relateid=@fieldid);
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'en','ld_field',@tabid,@fieldid,'creator' 
from dual where not EXISTS(select 1 from ld_tranlabel  where languagetype = 'en' 
and trantable ='ld_field' and tabid = @tabid and relateid=@fieldid);
delimiter;

select fieldid into @fieldid from ld_field where tabid = @tabid and fieldname = 'modifiedby';
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'zh','ld_field',@tabid,@fieldid,'修改人' 
from dual where not EXISTS(select 1 from ld_tranlabel  where languagetype = 'zh' 
and trantable ='ld_field' and tabid = @tabid and relateid=@fieldid);
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'en','ld_field',@tabid,@fieldid,'Modified By' 
from dual where not EXISTS(select 1 from ld_tranlabel  where languagetype = 'en' 
and trantable ='ld_field' and tabid = @tabid and relateid=@fieldid);
delimiter;

select fieldid into @fieldid from ld_field where tabid = @tabid and fieldname = 'createdtime';
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'zh','ld_field',@tabid,@fieldid,'创建日期' 
from dual where not EXISTS(select 1 from ld_tranlabel  where languagetype = 'zh' 
and trantable ='ld_field' and tabid = @tabid and relateid=@fieldid);
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'en','ld_field',@tabid,@fieldid,'Created Time' 
from dual where not EXISTS(select 1 from ld_tranlabel  where languagetype = 'en' 
and trantable ='ld_field' and tabid = @tabid and relateid=@fieldid);
delimiter;

select fieldid into @fieldid from ld_field where tabid = @tabid and fieldname = 'modifiedtime';
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'zh','ld_field',@tabid,@fieldid,'修改日期' 
from dual where not EXISTS(select 1 from ld_tranlabel  where languagetype = 'zh' 
and trantable ='ld_field' and tabid = @tabid and relateid=@fieldid);
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'en','ld_field',@tabid,@fieldid,'Modified Time' 
from dual where not EXISTS(select 1 from ld_tranlabel  where languagetype = 'en' 
and trantable ='ld_field' and tabid = @tabid and relateid=@fieldid);
delimiter;

select fieldid into @fieldid from ld_field where tabid = @tabid and fieldname = 'approveby';
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'zh','ld_field',@tabid,@fieldid,'审批人' 
from dual where not EXISTS(select 1 from ld_tranlabel  where languagetype = 'zh' 
and trantable ='ld_field' and tabid = @tabid and relateid=@fieldid);
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'en','ld_field',@tabid,@fieldid,'Approve By' 
from dual where not EXISTS(select 1 from ld_tranlabel  where languagetype = 'en' 
and trantable ='ld_field' and tabid = @tabid and relateid=@fieldid);
delimiter;

select fieldid into @fieldid from ld_field where tabid = @tabid and fieldname = 'approvestatus';
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'zh','ld_field',@tabid,@fieldid,'审批状态' 
from dual where not EXISTS(select 1 from ld_tranlabel  where languagetype = 'zh' 
and trantable ='ld_field' and tabid = @tabid and relateid=@fieldid);
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'en','ld_field',@tabid,@fieldid,'Approve Status' 
from dual where not EXISTS(select 1 from ld_tranlabel  where languagetype = 'en' 
and trantable ='ld_field' and tabid = @tabid and relateid=@fieldid);
delimiter;

select fieldid into @fieldid from ld_field where tabid = @tabid and fieldname = 'sum_direct';
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'zh','ld_field',@tabid,@fieldid,'直接工时合计' 
from dual where not EXISTS(select 1 from ld_tranlabel  where languagetype = 'zh' 
and trantable ='ld_field' and tabid = @tabid and relateid=@fieldid);
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'en','ld_field',@tabid,@fieldid,'Sum Direct' 
from dual where not EXISTS(select 1 from ld_tranlabel  where languagetype = 'en' 
and trantable ='ld_field' and tabid = @tabid and relateid=@fieldid);
delimiter;

select fieldid into @fieldid from ld_field where tabid = @tabid and fieldname = 'sum_indirect';
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'zh','ld_field',@tabid,@fieldid,'间接工时合计' 
from dual where not EXISTS(select 1 from ld_tranlabel  where languagetype = 'zh' 
and trantable ='ld_field' and tabid = @tabid and relateid=@fieldid);
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'en','ld_field',@tabid,@fieldid,'Sum Indirect' 
from dual where not EXISTS(select 1 from ld_tranlabel  where languagetype = 'en' 
and trantable ='ld_field' and tabid = @tabid and relateid=@fieldid);
delimiter;

insert into ld_modentity_num(num_id,semodule,prefix,start_id,cur_id,active,datetype)
select (select max(num_id)+1 from ld_modentity_num),'Timesheet','TS',0,1,1,'none' 
from dual where not EXISTS(select 1 from ld_modentity_num  where semodule = 'TimeSheet' 
and prefix ='TS');
update ld_modentity_num_seq set id = (select max(num_id)+1 from ld_modentity_num);
delimiter;

select tabid into @tabid from ld_tab where `name` = 'TimeSheet';
insert into ld_entityname(tabid,modulename,tablename,fieldname,entityidfield,entityidcolumn)
select @tabid,'TimeSheet','ld_timesheet','timesheet_no','timesheet_id','timesheet_id'
from dual where not EXISTS(select 1 from ld_entityname  where tabid = @tabid 
and modulename ='TimeSheet');
delimiter;

select id into @id from ld_links_seq;
insert into ld_links(linkid,tabid,linktype,linklabel,linkurl,linkicon,handler_path,handler_class,handler,sequence)
select @id+1,@tabid,'DETAILVIEWBASIC','View History',"javascript:ModTrackerCommon.showhistory('$RECORD$')",
'themes/images/pointer.gif','modules/ModTracker/ModTracker.php','ModTracker','isViewPermitted',0
from dual where not EXISTS(select 1 from ld_links  where tabid = @tabid 
and linktype ='DETAILVIEWBASIC');

update ld_links_seq set id = (select max(linkid) from ld_links);
delimiter;

update ld_tab set printtab = 1 where `name` = 'TimeSheet';
delimiter;

select tabid into @tabid from ld_tab where `name` = 'TimeSheet';
insert into ld_modtracker_tabs(tabid,visible)
select @tabid,1 from dual where not EXISTS(select 1 from ld_modtracker_tabs  where tabid = @tabid 
and visible =1);
delimiter;

insert into ld_profileallpermission(tabid,operation)
select @tabid,1 
from dual where not EXISTS(select 1 from ld_profileallpermission  where tabid=@tabid AND operation=1);
insert into ld_profileallpermission(tabid,operation)
select @tabid,2
from dual where not EXISTS(select 1 from ld_profileallpermission  where tabid=@tabid AND operation=2);
insert into ld_profileallpermission(tabid,operation)
select @tabid,3 
from dual where not EXISTS(select 1 from ld_profileallpermission  where tabid=@tabid AND operation=3);
insert into ld_profileallpermission(tabid,operation)
select @tabid,4
from dual where not EXISTS(select 1 from ld_profileallpermission  where tabid=@tabid AND operation=4);
insert into ld_profileallpermission(tabid,operation)
select @tabid,5
from dual where not EXISTS(select 1 from ld_profileallpermission  where tabid=@tabid AND operation=5);
insert into ld_profileallpermission(tabid,operation)
select @tabid,6
from dual where not EXISTS(select 1 from ld_profileallpermission  where tabid=@tabid AND operation=6);
insert into ld_profileallpermission(tabid,operation)
select @tabid,11
from dual where not EXISTS(select 1 from ld_profileallpermission  where tabid=@tabid AND operation=11);
insert into ld_profileallpermission(tabid,operation)
select @tabid,12 
from dual where not EXISTS(select 1 from ld_profileallpermission  where tabid=@tabid AND operation=12);
insert into ld_profileallpermission(tabid,operation)
select @tabid,13
from dual where not EXISTS(select 1 from ld_profileallpermission  where tabid=@tabid AND operation=13);
insert into ld_profileallpermission(tabid,operation)
select @tabid,14
from dual where not EXISTS(select 1 from ld_profileallpermission  where tabid=@tabid AND operation=14);
insert into ld_profileallpermission(tabid,operation)
select @tabid,25 
from dual where not EXISTS(select 1 from ld_profileallpermission  where tabid=@tabid AND operation=25);
delimiter;

select tabid into @tabid from ld_tab where `name` = 'TimeSheet';
insert into ld_customview(cvid,viewname,setdefault,setmetrics,entitytype,status,userid,sequence,pagewidthpercent,customcategory)
select (select max(cvid)+1 from ld_customview),'All',1,0,'TimeSheet',3,1,0,100,NULL 
from dual where not EXISTS(select 1 from ld_customview  where entitytype = 'TimeSheet' 
and viewname ='All');
delimiter;

select cvid into @cvid from ld_customview where entitytype = 'TimeSheet' and viewname = 'All';
INSERT INTO ld_tabwithproductview(tabid,`columns`,sequence,cvid)
SELECT @tabid ,'ld_timesheet:timesheet_no:timesheet_no:TimeSheet_fieldlabel:V',0,@cvid
from DUAL where not exists
(select 1 from ld_tabwithproductview where tabid = @tabid and `columns`='ld_timesheet:timesheet_no:timesheet_no:TimeSheet_fieldlabel:V'
 AND sequence=0 AND cvid=@cvid);
delimiter;

INSERT INTO ld_tabwithproductview(tabid,`columns`,sequence,cvid)
SELECT @tabid ,'ld_timesheet:smownerid:assigned_user_id:TimeSheet_fieldlabel:V',1,@cvid
from DUAL where not exists
(select 1 from ld_tabwithproductview where tabid = @tabid and `columns`='ld_timesheet:smownerid:assigned_user_id:TimeSheet_fieldlabel:V'
 AND sequence=1 AND cvid=@cvid);
delimiter;

INSERT INTO ld_tabwithproductview(tabid,`columns`,sequence,cvid)
SELECT @tabid ,'ld_timesheet:sum_direct:sum_direct:TimeSheet_fieldlabel:V',2,@cvid
from DUAL where not exists
(select 1 from ld_tabwithproductview where tabid = @tabid and `columns`='ld_timesheet:sum_direct:sum_direct:TimeSheet_fieldlabel:V'
 AND sequence=2 AND cvid=@cvid);
delimiter;

INSERT INTO ld_tabwithproductview(tabid,`columns`,sequence,cvid)
SELECT @tabid ,'ld_timesheet:sum_indirect:sum_indirect:TimeSheet_fieldlabel:V',3,@cvid
from DUAL where not exists
(select 1 from ld_tabwithproductview where tabid = @tabid and `columns`='ld_timesheet:sum_indirect:sum_indirect:TimeSheet_fieldlabel:V'
 AND sequence=3 AND cvid=@cvid);
delimiter;

INSERT INTO ld_tabwithproductview(tabid,`columns`,sequence,cvid)
SELECT @tabid ,'ld_timesheet:approveby:approveby:TimeSheet_fieldlabel:V',4,@cvid
from DUAL where not exists
(select 1 from ld_tabwithproductview where tabid = @tabid and `columns`='ld_timesheet:approveby:approveby:TimeSheet_fieldlabel:V'
 AND sequence=4 AND cvid=@cvid);
delimiter;

INSERT INTO ld_tabwithproductview(tabid,`columns`,sequence,cvid)
SELECT @tabid ,'ld_timesheet:approvestatus:approvestatus:TimeSheet_fieldlabel:V',5,@cvid
from DUAL where not exists
(select 1 from ld_tabwithproductview where tabid = @tabid and `columns`='ld_timesheet:approvestatus:approvestatus:TimeSheet_fieldlabel:V'
 AND sequence=5 AND cvid=@cvid);
delimiter;

INSERT INTO ld_tabwithproductview(tabid,`columns`,sequence,cvid)
SELECT @tabid ,'ld_timesheetdetail:workdate:workdate:TimeSheetDetails_fieldlabel:D',6,@cvid
from DUAL where not exists
(select 1 from ld_tabwithproductview where tabid = @tabid and `columns`='ld_timesheetdetail:workdate:workdate:TimeSheetDetails_fieldlabel:D'
 AND sequence=6 AND cvid=@cvid);
delimiter;

INSERT INTO ld_tabwithproductview(tabid,`columns`,sequence,cvid)
SELECT @tabid ,'ld_timesheetdetail:project_id:project_id:TimeSheetDetails_fieldlabel:V',7,@cvid
from DUAL where not exists
(select 1 from ld_tabwithproductview where tabid = @tabid and `columns`='ld_timesheetdetail:project_id:project_id:TimeSheetDetails_fieldlabel:V'
 AND sequence=7 AND cvid=@cvid);
delimiter;

INSERT INTO ld_tabwithproductview(tabid,`columns`,sequence,cvid)
SELECT @tabid ,'ld_timesheetdetail:indirectcharge:indirectcharge:TimeSheetDetails_fieldlabel:V',8,@cvid
from DUAL where not exists
(select 1 from ld_tabwithproductview where tabid = @tabid and `columns`='ld_timesheetdetail:indirectcharge:indirectcharge:TimeSheetDetails_fieldlabel:v'
 AND sequence=8 AND cvid=@cvid);
delimiter;

INSERT INTO ld_tabwithproductview(tabid,`columns`,sequence,cvid)
SELECT @tabid ,'ld_timesheetdetail:costtime:costtime:TimeSheetDetails_fieldlabel:V',9,@cvid
from DUAL where not exists
(select 1 from ld_tabwithproductview where tabid = @tabid and `columns`='ld_timesheetdetail:costtime:costtime:TimeSheetDetails_fieldlabel:v'
 AND sequence=9 AND cvid=@cvid);
delimiter;

INSERT INTO ld_tabwithproductview(tabid,`columns`,sequence,cvid)
SELECT @tabid ,'ld_timesheetdetail:description:description:TimeSheetDetails_fieldlabel:V',10,@cvid
from DUAL where not exists
(select 1 from ld_tabwithproductview where tabid = @tabid and `columns`='ld_timesheetdetail:description:description:TimeSheetDetails_fieldlabel:v'
 AND sequence=10 AND cvid=@cvid);
delimiter;

SELECT max(relation_id) INTO @relation_id FROM ld_relatedlists;
INSERT INTO  ld_relatedlists(relation_id,tabid,related_tabid,NAME,sequence,label,presence,actions,mobile_presence,mobile_sequence) 
SELECT @relation_id+1,@tabid,78,'get_attachment',1,'Attachment',0,'add',1,1
FROM DUAL WHERE NOT EXISTS(SELECT 1 FROM ld_relatedlists WHERE tabid=@tabid AND NAME='get_attachment');
delimiter;

SELECT max(relation_id) INTO @relation_id FROM ld_quickactions;
INSERT INTO  ld_quickactions(relation_id,tabid,related_tabid,sequence,presence,label) 
SELECT @relation_id+1,@tabid,78,1,0,'附件管理'
FROM DUAL WHERE NOT EXISTS(SELECT 1 FROM ld_quickactions WHERE tabid=@tabid AND related_tabid=78);
delimiter;

SELECT tabid INTO @tabid FROM ld_tab WHERE `name`='TimeSheet';
SELECT max(relation_id) INTO @relation_id FROM ld_quickactions;
INSERT INTO  ld_quickactions(relation_id,tabid,related_tabid,sequence,presence,label) 
SELECT @relation_id+1,@tabid,-1,2,0,'修改日志'
FROM DUAL WHERE NOT EXISTS(SELECT 1 FROM ld_quickactions WHERE tabid=@tabid AND related_tabid=-1);
delimiter;

SELECT max(relation_id) INTO @relation_id FROM ld_quickactions;
INSERT INTO  ld_quickactions(relation_id,tabid,related_tabid,sequence,presence,label) 
SELECT @relation_id+1,@tabid,78,1,0,''
FROM DUAL WHERE NOT EXISTS(SELECT 1 FROM ld_quickactions WHERE tabid=@tabid AND related_tabid=78);
delimiter;

SELECT max(relation_id) INTO @relation_id FROM ld_quickactions;
INSERT INTO  ld_quickactions(relation_id,tabid,related_tabid,sequence,presence,label) 
SELECT @relation_id+1,@tabid,-5,5,0,'打印工具'
FROM DUAL WHERE NOT EXISTS(SELECT 1 FROM ld_quickactions WHERE tabid=@tabid AND related_tabid=-5);
delimiter;

SELECT max(relation_id) INTO @relation_id FROM ld_quickactions;
INSERT INTO  ld_quickactions(relation_id,tabid,related_tabid,sequence,presence,label) 
SELECT @relation_id+1,@tabid,61,3,0,''
FROM DUAL WHERE NOT EXISTS(SELECT 1 FROM ld_quickactions WHERE tabid=@tabid AND related_tabid=61);
delimiter;

SELECT max(relation_id) INTO @relation_id FROM ld_quickactions;
INSERT INTO  ld_quickactions(relation_id,tabid,related_tabid,sequence,presence,label) 
SELECT @relation_id+1,@tabid,-10,4,0,'负责人变更记录'
FROM DUAL WHERE NOT EXISTS(SELECT 1 FROM ld_quickactions WHERE tabid=@tabid AND related_tabid=-10);
delimiter;

select id into @id from ld_picklistvalues_seq; 
insert into ld_timetype(timetype_id,timetype,presence,picklist_valueid) 
select 1,'Direct',1,@id+1 from DUAL 
where not exists(select 1 from ld_timetype where timetype_id = 1); 
insert into ld_timetype(timetype_id,timetype,presence,picklist_valueid) 
select 2,'Indirect',1,@id+2 from DUAL 
where not exists(select 1 from ld_timetype where timetype_id = 2); 
insert into ld_indirectcharge(indirectcharge_id,indirectcharge,presence,picklist_valueid) 
select 1,'Holiday',1,@id+3 from DUAL 
where not exists(select 1 from ld_indirectcharge where indirectcharge_id = 1); 
insert into ld_indirectcharge(indirectcharge_id,indirectcharge,presence,picklist_valueid) 
select 2,'Vacation',1,@id+4 from DUAL 
where not exists(select 1 from ld_indirectcharge where indirectcharge_id = 2); 
insert into ld_indirectcharge(indirectcharge_id,indirectcharge,presence,picklist_valueid) 
select 3,'Training',1,@id+5 from DUAL 
where not exists(select 1 from ld_indirectcharge where indirectcharge_id = 3); 
insert into ld_indirectcharge(indirectcharge_id,indirectcharge,presence,picklist_valueid) 
select 4,'Sick',1,@id+6 from DUAL 
where not exists(select 1 from ld_indirectcharge where indirectcharge_id = 4); 
insert into ld_indirectcharge(indirectcharge_id,indirectcharge,presence,picklist_valueid) 
select 5,'B&P',1,@id+7 from DUAL 
where not exists(select 1 from ld_indirectcharge where indirectcharge_id = 5); 
insert into ld_indirectcharge(indirectcharge_id,indirectcharge,presence,picklist_valueid) 
select 6,'Other',1,@id+8 from DUAL 
where not exists(select 1 from ld_indirectcharge where indirectcharge_id = 6); 
insert into ld_costtime(costtime_id,costtime,presence,picklist_valueid) 
select 1,1,1,@id+9 from dual 
where not exists(select 1 from ld_costtime where costtime_id = 1); 
insert into ld_costtime(costtime_id,costtime,presence,picklist_valueid) 
select 2,2,1,@id+10 from dual 
where not exists(select 1 from ld_costtime where costtime_id = 2); 
insert into ld_costtime(costtime_id,costtime,presence,picklist_valueid) 
select 3,3,1,@id+11 from dual 
where not exists(select 1 from ld_costtime where costtime_id = 3); 
insert into ld_costtime(costtime_id,costtime,presence,picklist_valueid) 
select 4,4,1,@id+12 from dual 
where not exists(select 1 from ld_costtime where costtime_id = 4); 
insert into ld_costtime(costtime_id,costtime,presence,picklist_valueid) 
select 5,5,1,@id+13 from dual 
where not exists(select 1 from ld_costtime where costtime_id = 5); 
insert into ld_costtime(costtime_id,costtime,presence,picklist_valueid) 
select 6,6,1,@id+14 from dual 
where not exists(select 1 from ld_costtime where costtime_id = 6); 
insert into ld_costtime(costtime_id,costtime,presence,picklist_valueid) 
select 7,7,1,@id+15 from dual 
where not exists(select 1 from ld_costtime where costtime_id = 7); 
insert into ld_costtime(costtime_id,costtime,presence,picklist_valueid) 
select 8,8,1,@id+16 from dual 
where not exists(select 1 from ld_costtime where costtime_id = 8); 
insert into ld_costtime(costtime_id,costtime,presence,picklist_valueid) 
select 9,9,1,@id+17 from dual 
where not exists(select 1 from ld_costtime where costtime_id = 9); 
insert into ld_costtime(costtime_id,costtime,presence,picklist_valueid) 
select 10,10,1,@id+18 from dual 
where not exists(select 1 from ld_costtime where costtime_id = 10); 
insert into ld_costtime(costtime_id,costtime,presence,picklist_valueid) 
select 11,11,1,@id+19 from dual 
where not exists(select 1 from ld_costtime where costtime_id = 11); 
insert into ld_costtime(costtime_id,costtime,presence,picklist_valueid) 
select 12,12,1,@id+20 from dual 
where not exists(select 1 from ld_costtime where costtime_id = 12); 
update ld_picklistvalues_seq set id = (select max(picklist_valueid) from ld_costtime); 
delimiter; 

select tabid into @tabid from ld_tab where `name` = 'TimeSheet'; 
insert into ld_tabdetailfield(columnname,fieldlabel,defaultvalue,presence,fieldtype,typeofdata,sequence,tabid,tablename,width,edit_permission,input_type,fieldid,newline,defaultcolumn)
select 'sum_direct','直接工时合计',0,0,'Span','N~O',1,@tabid,'ld_timesheet',22,0,0,0,1,2 from DUAL 
where not exists(select 1 from ld_tabdetailfield where tabid = @tabid and columnname = 'sum_direct'); 
select tabdetailfieldid into @id from ld_tabdetailfield where tabid = @tabid and columnname = 'sum_direct'; 
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel) 
select 'zh','ld_tabdetailfield',@tabid,@id,'直接工时合计' from DUAL 
where not exists(select 1 from ld_tranlabel where languagetype = 'zh' and trantable = 'ld_tabdetailfield' and tabid = @tabid and relateid = @id); 
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel) 
select 'en','ld_tabdetailfield',@tabid,@id,'Sum Direct' from DUAL 
where not exists(select 1 from ld_tranlabel where languagetype = 'en' and trantable = 'ld_tabdetailfield' and tabid = @tabid and relateid = @id); 

insert into ld_tabdetailfield(columnname,fieldlabel,defaultvalue,presence,fieldtype,typeofdata,sequence,tabid,tablename,width,edit_permission,input_type,fieldid,newline,defaultcolumn)
select 'sum_indirect','间接工时合计',0,0,'Span','N~O',1,@tabid,'ld_timesheet',22,0,0,0,1,2 from DUAL 
where not exists(select 1 from ld_tabdetailfield where tabid = @tabid and columnname = 'sum_indirect'); 
select tabdetailfieldid into @id from ld_tabdetailfield where tabid = @tabid and columnname = 'sum_indirect'; 
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel) 
select 'zh','ld_tabdetailfield',@tabid,@id,'间接工时合计' from DUAL 
where not exists(select 1 from ld_tranlabel where languagetype = 'zh' and trantable = 'ld_tabdetailfield' and tabid = @tabid and relateid = @id); 
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel) 
select 'en','ld_tabdetailfield',@tabid,@id,'Sum Indirect' from DUAL 
where not exists(select 1 from ld_tranlabel where languagetype = 'en' and trantable = 'ld_tabdetailfield' and tabid = @tabid and relateid = @id); 
delimiter;

select tabid into @tabid from ld_tab where name='TimeSheet';
insert into ld_approve(id,tabid,name,status,smcreatorid,modifiedby,createdtime,modifiedtime,approveallocatetype)
select (select max(id) from ld_approve)+1,@tabid,'工时管理默认流程',0,1,1,NOW(),NOW(),0
from dual where not EXISTS(select * from ld_approve where tabid=@tabid and name='工时管理默认流程');
delimiter;
select id into @id from ld_approve where tabid=@tabid and name='工时管理默认流程';
insert into ld_approvestep(id,approveid,name,ended,step,sequence,createdtime,modifiedtime,approvetype,approvevalue,specifyapproverid)
select (select max(id) from ld_approvestep)+1,@id,'步骤一',1,1,1,NOW(),NOW(),0,1,1
from dual where not EXISTS(select 1 from ld_approvestep where approveid=@id and name='步骤一');
insert into ld_approvestep(id,approveid,name,ended,step,sequence,createdtime,modifiedtime,approvetype,approvevalue,specifyapproverid)
select (select max(id) from ld_approvestep)+1,@id,'步骤二',1,1,2,NOW(),NOW(),0,1,1
from dual where not EXISTS(select 1 from ld_approvestep where approveid=@id and name='步骤二');
delimiter;
insert into ld_approve2user(approveid,userid)
select @id,-1 from dual 
where not EXISTS(select 1 from ld_approve2user where approveid=@id and userid=-1);
delimiter;

update ld_desk set fieldlabel='Next step control' where labelbol='NEXTEXAMINATIONANDAPPROVALCONTROL' AND languagetype='en';
update ld_field set typeofdata='NN~O~50,2' where tabid=26 AND fieldname='targetsize';
delimiter;


call AddColumn('ld_quotes','vendor_id','int','19',0);
delimiter;
call AddColumn('ld_quotes','vendorcontacts_id','int','19',0);
delimiter;
call fieldprofile('Quotes');
delimiter;
call getallprofile('Quotes');
delimiter;

select tabid into @tabid from ld_tab where name='Quotes';
select max(sequence)into @sequence from ld_field where tabid = @tabid;
insert into ld_field(tabid,fieldid,columnname,tablename,uitype,fieldname,fieldlabel,block,displaytype,presence,typeofdata,sequence)
select @tabid,(select max(fieldid) from ld_field)+1,'vendor_id','ld_quotes',75,'vendor_id','供用商',(select blockid from ld_blocks where blocklabel='LBL_QUOTE_INFORMATION'),1,0,'I~O',@sequence+1 from dual 
where not EXISTS(select * from ld_field where tabid=@tabid and columnname='vendor_id');
insert into ld_field(tabid,fieldid,columnname,tablename,uitype,fieldname,fieldlabel,block,displaytype,presence,typeofdata,sequence)
select @tabid,(select max(fieldid) from ld_field)+1,'vendorcontacts_id','ld_quotes',97,'vendorcontacts_id','供应商联系人',(select blockid from ld_blocks where blocklabel='LBL_QUOTE_INFORMATION'),1,0,'I~O',@sequence+2 from dual 
where not EXISTS(select * from ld_field where tabid=@tabid and columnname='vendorcontacts_id');

select fieldid into @fieldid from ld_field where tabid = @tabid and fieldname = 'vendor_id';
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'zh','ld_field',@tabid,@fieldid,'供用商' from dual 
where not EXISTS(select 1 from ld_tranlabel  where languagetype = 'zh' and trantable ='ld_field' and tabid = @tabid and relateid=@fieldid);
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'en','ld_field',@tabid,@fieldid,'Vendor Name' from dual 
where not EXISTS(select 1 from ld_tranlabel  where languagetype = 'en' and trantable ='ld_field' and tabid = @tabid and relateid=@fieldid);  

select fieldid into @fieldid from ld_field where tabid = @tabid and fieldname = 'vendorcontacts_id';
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'zh','ld_field',@tabid,@fieldid,'供应商联系人' from dual 
where not EXISTS(select 1 from ld_tranlabel  where languagetype = 'zh' and trantable ='ld_field' and tabid = @tabid and relateid=@fieldid);
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'en','ld_field',@tabid,@fieldid,'Vendor Contacts' from dual 
where not EXISTS(select 1 from ld_tranlabel  where languagetype = 'en' and trantable ='ld_field' and tabid = @tabid and relateid=@fieldid);

SELECT tabid INTO @tabid FROM ld_tab WHERE `name`='Quotes';
SELECT max(relation_id) INTO @relation_id FROM ld_quickactions;
INSERT INTO  ld_quickactions(relation_id,tabid,related_tabid,sequence,presence,label) 
SELECT @relation_id+1,@tabid,37,5,0,''
FROM DUAL WHERE NOT EXISTS(SELECT 1 FROM ld_quickactions WHERE tabid=@tabid AND related_tabid=37);
delimiter;

call AddColumn('ld_servicecontracts','vendor_id','int','19',0);
delimiter;
call AddColumn('ld_servicecontracts','vendorcontacts_id','int','19',0);
delimiter;
call AddColumn('ld_servicecontracts','quote_id','int','19',0);
delimiter;
call fieldprofile('ServiceContracts');
delimiter;
call getallprofile('ServiceContracts');
delimiter;

select tabid into @tabid from ld_tab where name='ServiceContracts';
select max(sequence)into @sequence from ld_field where tabid = @tabid;
insert into ld_field(tabid,fieldid,columnname,tablename,uitype,fieldname,fieldlabel,block,displaytype,presence,typeofdata,sequence)
select @tabid,(select max(fieldid) from ld_field)+1,'vendor_id','ld_servicecontracts',75,'vendor_id','供应商',(select blockid from ld_blocks where blocklabel='LBL_SERVICE_CONTRACT_INFORMATION'),1,0,'I~O',@sequence+1 from dual where not EXISTS(select * from ld_field where tabid=@tabid and columnname='vendor_id');
insert into ld_field(tabid,fieldid,columnname,tablename,uitype,fieldname,fieldlabel,block,displaytype,presence,typeofdata,sequence)
select @tabid,(select max(fieldid) from ld_field)+1,'vendorcontacts_id','ld_servicecontracts',97,'vendorcontacts_id','供应商联系人',(select blockid from ld_blocks where blocklabel='LBL_SERVICE_CONTRACT_INFORMATION'),1,0,'I~O',@sequence+2 from dual where not EXISTS(select * from ld_field where tabid=@tabid and columnname='vendorcontacts_id');
insert into ld_field(tabid,fieldid,columnname,tablename,uitype,fieldname,fieldlabel,block,displaytype,presence,typeofdata,sequence)
select @tabid,(select max(fieldid) from ld_field)+1,'quote_id','ld_servicecontracts',78,'quote_id','报价单编号',(select blockid from ld_blocks where blocklabel='LBL_SERVICE_CONTRACT_INFORMATION'),1,0,'V~O',@sequence+3 from dual where not EXISTS(select * from ld_field where tabid=@tabid and columnname='quote_id');

select fieldid into @fieldid from ld_field where tabid = @tabid and fieldname = 'vendor_id';
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'zh','ld_field',@tabid,@fieldid,'供应商' 
from dual where not EXISTS(select 1 from ld_tranlabel  where languagetype = 'zh' 
and trantable ='ld_field' and tabid = @tabid and relateid=@fieldid);
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'en','ld_field',@tabid,@fieldid,'Vendor Name' 
from dual where not EXISTS(select 1 from ld_tranlabel  where languagetype = 'en' 
and trantable ='ld_field' and tabid = @tabid and relateid=@fieldid);  

select fieldid into @fieldid from ld_field where tabid = @tabid and fieldname = 'vendorcontacts_id';
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'zh','ld_field',@tabid,@fieldid,'供应商联系人' 
from dual where not EXISTS(select 1 from ld_tranlabel  where languagetype = 'zh' 
and trantable ='ld_field' and tabid = @tabid and relateid=@fieldid);
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'en','ld_field',@tabid,@fieldid,'Vendor Contacts' 
from dual where not EXISTS(select 1 from ld_tranlabel  where languagetype = 'en' 
and trantable ='ld_field' and tabid = @tabid and relateid=@fieldid);

select fieldid into @fieldid from ld_field where tabid = @tabid and fieldname = 'quote_id';
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'zh','ld_field',@tabid,@fieldid,'报价单编号' 
from dual where not EXISTS(select 1 from ld_tranlabel  where languagetype = 'zh' 
and trantable ='ld_field' and tabid = @tabid and relateid=@fieldid);
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'en','ld_field',@tabid,@fieldid,'Quote No' 
from dual where not EXISTS(select 1 from ld_tranlabel  where languagetype = 'en' 
and trantable ='ld_field' and tabid = @tabid and relateid=@fieldid);

SELECT tabid INTO @tabid FROM ld_tab WHERE `name`='ServiceContracts';
SELECT max(relation_id) INTO @relation_id FROM ld_quickactions;
INSERT INTO  ld_quickactions(relation_id,tabid,related_tabid,sequence,presence,label) 
SELECT @relation_id+1,@tabid,21,5,0,''
FROM DUAL WHERE NOT EXISTS(SELECT 1 FROM ld_quickactions WHERE tabid=@tabid AND related_tabid=21);
delimiter;

call AddColumn('ld_purchaseorder','servicecontractsid','int','19',0);
delimiter;
call fieldprofile('PurchaseOrder');
delimiter;

call getallprofile('PurchaseOrder');
delimiter;

select tabid into @tabid from ld_tab where name='PurchaseOrder';
select max(sequence)into @sequence from ld_field where tabid = @tabid;
insert into ld_field(tabid,fieldid,columnname,tablename,uitype,fieldname,fieldlabel,block,displaytype,presence,typeofdata,sequence)
select @tabid,(select max(fieldid) from ld_field)+1,'servicecontractsid','ld_purchaseorder',243,'servicecontractsid','服务合同编号',(select blockid from ld_blocks where blocklabel='LBL_PO_INFORMATION'),1,0,'V~O',@sequence+1 from dual where not EXISTS(select * from ld_field where tabid=@tabid and columnname='servicecontractsid');

select fieldid into @fieldid from ld_field where tabid = @tabid and fieldname = 'servicecontractsid';
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'zh','ld_field',@tabid,@fieldid,'服务合同编号' from dual 
where not EXISTS(select 1 from ld_tranlabel  where languagetype = 'zh' and trantable ='ld_field' and tabid = @tabid and relateid=@fieldid);
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'en','ld_field',@tabid,@fieldid,'ServiceContracts No' from dual 
where not EXISTS(select 1 from ld_tranlabel  where languagetype = 'en' and trantable ='ld_field' and tabid = @tabid and relateid=@fieldid);
delimiter;

insert into ld_ws_fieldtype(uitype,fieldtype)
select 97,'reference' from dual
where not exists(select 1 from ld_ws_fieldtype where uitype = 97 and fieldtype = 'reference');
select fieldtypeid into @fieldtypeid from ld_ws_fieldtype where uitype = 97 and fieldtype='reference';
insert into ld_ws_referencetype(fieldtypeid,type)
select @fieldtypeid,'VendorContact' from DUAL
where not exists(select 1 from ld_ws_referencetype where fieldtypeid = @fieldtypeid and type='VendorContact');
delimiter;
-- 2016-04-12

alter table ld_timesheet alter approvestatus set default '未提交';

update ld_field set presence=1 where tabid=20 and columnname in ('vendor_id','vendorcontacts_id');
update ld_quickactions set presence=1 where tabid=20 and related_tabid=37;
update ld_field set presence=1 where tabid=37 and columnname in ('vendor_id','vendorcontacts_id','quote_id');
update ld_quickactions set presence=1 where tabid=37 and related_tabid=21;
update ld_field set presence=1 where tabid=21 and columnname in ('servicecontractsid');

SELECT tabid INTO @tabid FROM ld_tab WHERE `name`='SalesOrder';
SELECT tabid INTO @tabid2 FROM ld_tab WHERE `name`='SalesOrder';
SELECT max(relation_id) INTO @relation_id FROM ld_relatedlists;
INSERT INTO  ld_relatedlists(relation_id,tabid,related_tabid,NAME,sequence,label,presence,actions,mobile_presence,mobile_sequence) 
SELECT @relation_id+1,@tabid,@tabid2,'get_salesorder',15,'SalesOrder',0,'ADD',1,15
FROM DUAL WHERE NOT EXISTS(SELECT 1 FROM ld_relatedlists WHERE tabid=@tabid AND NAME='get_salesorder');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','CHANGEORDER','变更单(子合同)','fixedstr' from dual 
where not exists(select 1 from ld_desk where labelbol = 'CHANGEORDER' and languagetype = 'zh' and labeltype = 'fixedstr');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','CHANGEORDER','Change Order','fixedstr' from dual 
where not exists(select 1 from ld_desk where labelbol = 'CHANGEORDER' and languagetype = 'en' and labeltype = 'fixedstr');
delimiter;

CREATE TABLE IF NOT EXISTS `ld_dividend_rules`(
  `divruleid`        INT(19) UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  `productid`    INT(19) ,
  `formulacapital`   CHAR(30),
  `formulamode`    CHAR(30),
  `deadline`    TINYINT(3),
  `grantdate`    TINYINT(3),
  `grantdate_switch`    CHAR(30),
  `grantdate_designated`    VARCHAR(255),
  `formulas`    VARCHAR(255),
  `float_switch`     CHAR(10) ,
  `floatstartdate`    DATE,
  `floatyield`     DECIMAL(25,6)
)ENGINE=InnoDB DEFAULT CHARSET=utf8;
delimiter;

CREATE TABLE IF NOT EXISTS `ld_dividend_rules_formulas`(
  `id`        INT(19) UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  `formulamode`    CHAR(30),
  `formulas`    VARCHAR(255),
  `describe`  VARCHAR(255)
)ENGINE=InnoDB DEFAULT CHARSET=utf8;
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,Labeltype)
  select 'zh','FULLMONTH30','满月按30','fixedstr' from dual
  where not exists(select 1 from ld_desk where labelbol='FULLMONTH30' and languagetype='zh');

insert into ld_desk(languagetype,labelbol,fieldlabel,Labeltype)
  select 'en','FULLMONTH30','FullMonth30','fixedstr' from dual
  where not exists(select 1 from ld_desk where labelbol='FULLMONTH30' and languagetype='en');


insert into ld_dividend_rules_formulas(formulamode,formulas,`describe`)
  select 'monthly','Capital*Rate*FullMonth30/360','{本金}*{固定年化收益率}*{计息天数:满月按30}/360' from dual
  where not exists(select 1 from ld_dividend_rules_formulas where formulamode='monthly' and formulas='Capital*Rate*FullMonth30/360');

insert into ld_dividend_rules_formulas(formulamode,formulas,`describe`)
  select 'monthly','Capital*Rate*Days/12','{本金}*{固定年化收益率}*{计息天数}/12' from dual
  where not exists(select 1 from ld_dividend_rules_formulas where formulamode='monthly' and formulas='Capital*Rate*Days/12');

insert into ld_dividend_rules_formulas(formulamode,formulas,`describe`)
  select 'quarterly','Capital*Rate*Days/4','{本金}*{固定年化收益率}*{计息天数}/4' from dual
  where not exists(select 1 from ld_dividend_rules_formulas where formulamode='quarterly' and formulas='Capital*Rate*Days/4');

insert into ld_dividend_rules_formulas(formulamode,formulas,`describe`)
  select 'semiannual','Capital*Rate*Days/2','{本金}*{固定年化收益率}*{计息天数}/2' from dual
  where not exists(select 1 from ld_dividend_rules_formulas where formulamode='semiannual' and formulas='Capital*Rate*Days/2');

insert into ld_dividend_rules_formulas(formulamode,formulas,`describe`)
  select 'oneoff','Capital*Rate','{本金}*{固定年化收益率}' from dual
  where not exists(select 1 from ld_dividend_rules_formulas where formulamode='oneoff' and formulas='C*R');

insert into ld_dividend_rules_formulas(formulamode,formulas,`describe`)
  select 'monthly','Capital*Rate*Days/360','{本金}*{固定年化收益率}*{计息天数}/360' from dual
  where not exists(select 1 from ld_dividend_rules_formulas where formulamode='monthly' and formulas='Capital*Rate*Days/360');
insert into ld_dividend_rules_formulas(formulamode,formulas,`describe`)
  select 'monthly','Capital*Rate*Days/365','{本金}*{固定年化收益率}*{计息天数}/365' from dual
  where not exists(select 1 from ld_dividend_rules_formulas where formulamode='monthly' and formulas='Capital*Rate*Days/365');

insert into ld_dividend_rules_formulas(formulamode,formulas,`describe`)
  select 'quarterly','Capital*Rate*Days/360','{本金}*{固定年化收益率}*{计息天数}/360' from dual
  where not exists(select 1 from ld_dividend_rules_formulas where formulamode='quarterly' and formulas='Capital*Rate*Days/360');
insert into ld_dividend_rules_formulas(formulamode,formulas,`describe`)
  select 'quarterly','Capital*Rate*Days/365','{本金}*{固定年化收益率}*{计息天数}/365' from dual
  where not exists(select 1 from ld_dividend_rules_formulas where formulamode='quarterly' and formulas='Capital*Rate*Days/365');

insert into ld_dividend_rules_formulas(formulamode,formulas,`describe`)
  select 'semiannual','Capital*Rate*Days/360','{本金}*{固定年化收益率}*{计息天数}/360' from dual
  where not exists(select 1 from ld_dividend_rules_formulas where formulamode='semiannual' and formulas='Capital*Rate*Days/360');
insert into ld_dividend_rules_formulas(formulamode,formulas,`describe`)
  select 'semiannual','Capital*Rate*Days/365','{本金}*{固定年化收益率}*{计息天数}/365' from dual
  where not exists(select 1 from ld_dividend_rules_formulas where formulamode='semiannual' and formulas='Capital*Rate*Days/365');

insert into ld_dividend_rules_formulas(formulamode,formulas,`describe`)
  select 'oneoff','Capital*Rate*Days/360','{本金}*{固定年化收益率}*{计息天数}/360' from dual
  where not exists(select 1 from ld_dividend_rules_formulas where formulamode='oneoff' and formulas='Capital*Rate*Days/360');
insert into ld_dividend_rules_formulas(formulamode,formulas,`describe`)
  select 'oneoff','Capital*Rate*Days/365','{本金}*{固定年化收益率}*{计息天数}/365' from dual
  where not exists(select 1 from ld_dividend_rules_formulas where formulamode='oneoff' and formulas='Capital*Rate*Days/365');

insert into ld_dividend_rules_formulas(formulamode,formulas,`describe`)
  select 'designated','Capital*Rate*Days/360','{本金}*{固定年化收益率}*{计息天数}/360' from dual
  where not exists(select 1 from ld_dividend_rules_formulas where formulamode='designated' and formulas='Capital*Rate*Days/360');
insert into ld_dividend_rules_formulas(formulamode,formulas,`describe`)
  select 'designated','Capital*Rate*Days/365','{本金}*{固定年化收益率}*{计息天数}/365' from dual
  where not exists(select 1 from ld_dividend_rules_formulas where formulamode='designated' and formulas='Capital*Rate*Days/365');

insert into ld_desk(languagetype,labelbol,fieldlabel,Labeltype)
  select 'zh','TIPSFORENTRYRATE','录入10表示10%','fixedstr' from dual
  where not exists(select 1 from ld_desk where labelbol='TIPSFORENTRYRATE' and languagetype='zh');

insert into ld_desk(languagetype,labelbol,fieldlabel,Labeltype)
  select 'en','TIPSFORENTRYRATE','Entry 10 said 10%','fixedstr' from dual
  where not exists(select 1 from ld_desk where labelbol='TIPSFORENTRYRATE' and languagetype='en');

insert into ld_desk(languagetype,labelbol,fieldlabel,Labeltype)
  select 'zh','REMINDFORUNLEGALCON','请录入格式合法的内容','jspop' from dual
  where not exists(select 1 from ld_desk where labelbol='REMINDFORUNLEGALCON' and languagetype='zh');

insert into ld_desk(languagetype,labelbol,fieldlabel,Labeltype)
  select 'en','REMINDFORUNLEGALCON','Please enter the legal content','jspop' from dual
  where not exists(select 1 from ld_desk where labelbol='REMINDFORUNLEGALCON' and languagetype='en');


insert into ld_desk(languagetype,labelbol,fieldlabel,Labeltype)
  select 'zh','DIVIDENDGRANTOFFONE','最晚的{合同订单}-{本金及红利返还日期}','fixedstr' from dual
  where not exists(select 1 from ld_desk where labelbol='DIVIDENDGRANTOFFONE' and languagetype='zh');

insert into ld_desk(languagetype,labelbol,fieldlabel,Labeltype)
  select 'en','DIVIDENDGRANTOFFONE','Latest{salesorder}-{The capital and the dividend return date}','fixedstr' from dual
  where not exists(select 1 from ld_desk where labelbol='DIVIDENDGRANTOFFONE' and languagetype='en');

insert into ld_desk(languagetype,labelbol,fieldlabel,Labeltype)
  select 'zh','DIVIDENDGRANTOFFTWO','{合同订单}-{本金及红利返还日期}','fixedstr' from dual
  where not exists(select 1 from ld_desk where labelbol='DIVIDENDGRANTOFFTWO' and languagetype='zh');

insert into ld_desk(languagetype,labelbol,fieldlabel,Labeltype)
  select 'en','DIVIDENDGRANTOFFTWO','{salesorder}-{The capital and the dividend return date}','fixedstr' from dual
  where not exists(select 1 from ld_desk where labelbol='DIVIDENDGRANTOFFTWO' and languagetype='en');


insert into ld_desk(languagetype,labelbol,fieldlabel,Labeltype)
  select 'zh','DATETHISMONTH','当月指定的日期','fixedstr' from dual
  where not exists(select 1 from ld_desk where labelbol='DATETHISMONTH' and languagetype='zh');

insert into ld_desk(languagetype,labelbol,fieldlabel,Labeltype)
  select 'en','DATETHISMONTH','The specified date this month','fixedstr' from dual
  where not exists(select 1 from ld_desk where labelbol='DATETHISMONTH' and languagetype='en');


insert into ld_desk(languagetype,labelbol,fieldlabel,Labeltype)
  select 'zh','DATENEXTMONTH','下月指定的日期','fixedstr' from dual
  where not exists(select 1 from ld_desk where labelbol='DATENEXTMONTH' and languagetype='zh');

insert into ld_desk(languagetype,labelbol,fieldlabel,Labeltype)
  select 'en','DATENEXTMONTH','The specified date next month','fixedstr' from dual
  where not exists(select 1 from ld_desk where labelbol='DATENEXTMONTH' and languagetype='en');


insert into ld_desk(languagetype,labelbol,fieldlabel,Labeltype)
  select 'zh','ENDOFMONTH','月末','fixedstr' from dual
  where not exists(select 1 from ld_desk where labelbol='ENDOFMONTH' and languagetype='zh');

insert into ld_desk(languagetype,labelbol,fieldlabel,Labeltype)
  select 'en','ENDOFMONTH','End of month','fixedstr' from dual
  where not exists(select 1 from ld_desk where labelbol='ENDOFMONTH' and languagetype='en');


insert into ld_desk(languagetype,labelbol,fieldlabel,Labeltype)
  select 'zh','DIVIDENDFIXEDRATEONE','相关{合同订单}-{固定年化收益率}','fixedstr' from dual
  where not exists(select 1 from ld_desk where labelbol='DIVIDENDFIXEDRATEONE' and languagetype='zh');

insert into ld_desk(languagetype,labelbol,fieldlabel,Labeltype)
  select 'en','DIVIDENDFIXEDRATEONE','The fixed-income rate of the related contract','fixedstr' from dual
  where not exists(select 1 from ld_desk where labelbol='DIVIDENDFIXEDRATEONE' and languagetype='en');

insert into ld_desk(languagetype,labelbol,fieldlabel,Labeltype)
  select 'zh','DIVIDENDFIXEDRATETWO','{合同订单}-{固定年化收益率}','fixedstr' from dual
  where not exists(select 1 from ld_desk where labelbol='DIVIDENDFIXEDRATETWO' and languagetype='zh');

insert into ld_desk(languagetype,labelbol,fieldlabel,Labeltype)
  select 'en','DIVIDENDFIXEDRATETWO','The fixed-income rate of the contract','fixedstr' from dual
  where not exists(select 1 from ld_desk where labelbol='DIVIDENDFIXEDRATETWO' and languagetype='en');


insert into ld_desk(languagetype,labelbol,fieldlabel,Labeltype)
    select 'zh','DIVIDENDRULES','派息规则','fixedstr' from dual
  where not exists(select 1 from ld_desk where labelbol='DIVIDENDRULES' and languagetype='zh');

insert into ld_desk(languagetype,labelbol,fieldlabel,Labeltype)
  select 'en','DIVIDENDRULES','Dividend Rules','fixedstr' from dual
  where not exists(select 1 from ld_desk where labelbol='DIVIDENDRULES' and languagetype='en');


insert into ld_desk(languagetype,labelbol,fieldlabel,Labeltype)
  select 'zh','FORMULACAPITAL','本金计算方法','fixedstr' from dual
  where not exists(select 1 from ld_desk where labelbol='FORMULACAPITAL' and languagetype='zh');

insert into ld_desk(languagetype,labelbol,fieldlabel,Labeltype)
  select 'en','FORMULACAPITAL','Investment Amount','fixedstr' from dual
  where not exists(select 1 from ld_desk where labelbol='FORMULACAPITAL' and languagetype='en');


insert into ld_desk(languagetype,labelbol,fieldlabel,Labeltype)
  select 'zh','FORMULATOTAL','按认购金额计算','fixedstr' from dual
  where not exists(select 1 from ld_desk where labelbol='FORMULATOTAL' and languagetype='zh');

insert into ld_desk(languagetype,labelbol,fieldlabel,Labeltype)
  select 'en','FORMULATOTAL','Total Subscription Amount','fixedstr' from dual
  where not exists(select 1 from ld_desk where labelbol='FORMULATOTAL' and languagetype='en');

insert into ld_desk(languagetype,labelbol,fieldlabel,Labeltype)
  select 'zh','FORMULAEVERYCONTRACT','按合同订单计算','fixedstr' from dual
  where not exists(select 1 from ld_desk where labelbol='FORMULAEVERYCONTRACT' and languagetype='zh');

insert into ld_desk(languagetype,labelbol,fieldlabel,Labeltype)
  select 'en','FORMULAEVERYCONTRACT','Every Contract Amount','fixedstr' from dual
  where not exists(select 1 from ld_desk where labelbol='FORMULAEVERYCONTRACT' and languagetype='en');


insert into ld_desk(languagetype,labelbol,fieldlabel,Labeltype)
  select 'zh','FORMULAMODE','利息计算方式','fixedstr' from dual
  where not exists(select 1 from ld_desk where labelbol='FORMULAMODE' and languagetype='zh');

insert into ld_desk(languagetype,labelbol,fieldlabel,Labeltype)
  select 'en','FORMULAMODE','Interest Calculation','fixedstr' from dual
  where not exists(select 1 from ld_desk where labelbol='FORMULAMODE' and languagetype='en');

insert into ld_desk(languagetype,labelbol,fieldlabel,Labeltype)
  select 'zh','FORMULASTART','计息起始日','fixedstr' from dual
  where not exists(select 1 from ld_desk where labelbol='FORMULASTART' and languagetype='zh');

insert into ld_desk(languagetype,labelbol,fieldlabel,Labeltype)
  select 'en','FORMULASTART','Start Date','fixedstr' from dual
  where not exists(select 1 from ld_desk where labelbol='FORMULASTART' and languagetype='en');

insert into ld_desk(languagetype,labelbol,fieldlabel,Labeltype)
  select 'zh','FORMULADEADLINE','月结算截止日','fixedstr' from dual
  where not exists(select 1 from ld_desk where labelbol='FORMULADEADLINE' and languagetype='zh');

insert into ld_desk(languagetype,labelbol,fieldlabel,Labeltype)
  select 'en','FORMULADEADLINE','Monthly Closing Date','fixedstr' from dual
  where not exists(select 1 from ld_desk where labelbol='FORMULADEADLINE' and languagetype='en');
insert into ld_desk(languagetype,labelbol,fieldlabel,Labeltype)
  select 'zh','FORMULAFLOATINCOME','计算浮动收益','fixedstr' from dual
  where not exists(select 1 from ld_desk where labelbol='FORMULAFLOATINCOME' and languagetype='zh');

insert into ld_desk(languagetype,labelbol,fieldlabel,Labeltype)
  select 'en','FORMULAFLOATINCOME','Whether to calculate the floating income','fixedstr' from dual
  where not exists(select 1 from ld_desk where labelbol='FORMULAFLOATINCOME' and languagetype='en');

insert into ld_desk(languagetype,labelbol,fieldlabel,Labeltype)
  select 'zh','FORMULAINCOMERATE','收益率(%)','fixedstr' from dual
  where not exists(select 1 from ld_desk where labelbol='FORMULAINCOMERATE' and languagetype='zh');

insert into ld_desk(languagetype,labelbol,fieldlabel,Labeltype)
  select 'en','FORMULAINCOMERATE','Income Rate','fixedstr' from dual
  where not exists(select 1 from ld_desk where labelbol='FORMULAINCOMERATE' and languagetype='en');

insert into ld_desk(languagetype,labelbol,fieldlabel,Labeltype)
  select 'zh','FIXEDINCOMERATE','固定年化收益率','fixedstr' from dual
  where not exists(select 1 from ld_desk where labelbol='FIXEDINCOMERATE' and languagetype='zh');

insert into ld_desk(languagetype,labelbol,fieldlabel,Labeltype)
  select 'en','FIXEDINCOMERATE','Fixed-Income Rate','fixedstr' from dual
  where not exists(select 1 from ld_desk where labelbol='FIXEDINCOMERATE' and languagetype='en');

insert into ld_desk(languagetype,labelbol,fieldlabel,Labeltype)
  select 'zh','STARTDATETYPEONE','首次购买的{合同订单}-{计息起始日期}','fixedstr' from dual
  where not exists(select 1 from ld_desk where labelbol='STARTDATETYPEONE' and languagetype='zh');

insert into ld_desk(languagetype,labelbol,fieldlabel,Labeltype)
  select 'en','STARTDATETYPEONE','The start date of the first contract','fixedstr' from dual
  where not exists(select 1 from ld_desk where labelbol='STARTDATETYPEONEE' and languagetype='en');
insert into ld_desk(languagetype,labelbol,fieldlabel,Labeltype)
  select 'zh','STARTDATETYPETWO','{合同订单}-{计息起始日期}','fixedstr' from dual
  where not exists(select 1 from ld_desk where labelbol='STARTDATETYPETWO' and languagetype='zh');

insert into ld_desk(languagetype,labelbol,fieldlabel,Labeltype)
  select 'en','STARTDATETYPETWO','The start date of the contract','fixedstr' from dual
  where not exists(select 1 from ld_desk where labelbol='STARTDATETYPETWO' and languagetype='en');

insert into ld_desk(languagetype,labelbol,fieldlabel,Labeltype)
  select 'zh','ENDDATETYPEONE','最晚的{合同订单}-{本金及红利返还日期}','fixedstr' from dual
  where not exists(select 1 from ld_desk where labelbol='ENDDATETYPEONE' and languagetype='zh');

insert into ld_desk(languagetype,labelbol,fieldlabel,Labeltype)
  select 'en','ENDDATETYPEONE','The start date of the first contract','fixedstr' from dual
  where not exists(select 1 from ld_desk where labelbol='ENDDATETYPEONE' and languagetype='en');
insert into ld_desk(languagetype,labelbol,fieldlabel,Labeltype)
  select 'zh','ENDDATETYPETWO','{合同订单}-{本金及红利返还日期}','fixedstr' from dual
  where not exists(select 1 from ld_desk where labelbol='ENDDATETYPETWO' and languagetype='zh');

insert into ld_desk(languagetype,labelbol,fieldlabel,Labeltype)
  select 'en','ENDDATETYPETWO','The start date of the contract','fixedstr' from dual
  where not exists(select 1 from ld_desk where labelbol='ENDDATETYPETWO' and languagetype='en');

insert into ld_desk(languagetype,labelbol,fieldlabel,Labeltype)
  select 'zh','DIVIDENDMONTHLY','按月派息','fixedstr' from dual
  where not exists(select 1 from ld_desk where labelbol='DIVIDENDMONTHLY' and languagetype='zh');

insert into ld_desk(languagetype,labelbol,fieldlabel,Labeltype)
  select 'en','DIVIDENDMONTHLY','Monthly Dividend','fixedstr' from dual
  where not exists(select 1 from ld_desk where labelbol='DIVIDENDMONTHLY' and languagetype='en');
insert into ld_desk(languagetype,labelbol,fieldlabel,Labeltype)
  select 'zh','DIVIDENDQUARTERLY','按季派息','fixedstr' from dual
  where not exists(select 1 from ld_desk where labelbol='DIVIDENDQUARTERLY' and languagetype='zh');

insert into ld_desk(languagetype,labelbol,fieldlabel,Labeltype)
  select 'en','DIVIDENDQUARTERLY','Quarterly Dividend','fixedstr' from dual
  where not exists(select 1 from ld_desk where labelbol='DIVIDENDQUARTERLY' and languagetype='en');

insert into ld_desk(languagetype,labelbol,fieldlabel,Labeltype)
  select 'zh','DIVIDENDSEMIAN','按半年派息','fixedstr' from dual
  where not exists(select 1 from ld_desk where labelbol='DIVIDENDSEMIAN' and languagetype='zh');

insert into ld_desk(languagetype,labelbol,fieldlabel,Labeltype)
  select 'en','DIVIDENDSEMIAN','Semiannual Dividend','fixedstr' from dual
  where not exists(select 1 from ld_desk where labelbol='DIVIDENDSEMIAN' and languagetype='en');
insert into ld_desk(languagetype,labelbol,fieldlabel,Labeltype)
  select 'zh','DIVIDENDONEOFF','一次性派息','fixedstr' from dual
  where not exists(select 1 from ld_desk where labelbol='DIVIDENDONEOFF' and languagetype='zh');

insert into ld_desk(languagetype,labelbol,fieldlabel,Labeltype)
  select 'en','DIVIDENDONEOFF','One-Off Dividend','fixedstr' from dual
  where not exists(select 1 from ld_desk where labelbol='DIVIDENDONEOFF' and languagetype='en');
insert into ld_desk(languagetype,labelbol,fieldlabel,Labeltype)
  select 'zh','DIVIDENDDESIGN','指定派息日','fixedstr' from dual
  where not exists(select 1 from ld_desk where labelbol='DIVIDENDDESIGN' and languagetype='zh');

insert into ld_desk(languagetype,labelbol,fieldlabel,Labeltype)
  select 'en','DIVIDENDDESIGN','Designated Dividend','fixedstr' from dual
  where not exists(select 1 from ld_desk where labelbol='DIVIDENDDESIGN' and languagetype='en');

update ld_desk set fieldlabel='该单据未审批，不允许创建相关联的单据' where languagetype='zh' AND labelbol='NOTCREATERELVANTBILL';
delimiter;

SELECT tabid INTO @tabid  from ld_tab where NAME='Timesheet';
UPDATE ld_field SET  fieldlabel='创建时间'
WHERE tabid=@tabid AND columnname='createdtime'; 
delimiter;
UPDATE ld_field SET  fieldlabel='修改时间'
WHERE tabid=@tabid AND columnname='modifiedtime';
delimiter;
select fieldid into @fieldid from ld_field where tabid = @tabid and fieldname = 'createdtime';
UPDATE ld_tranlabel SET fieldlabel='创建时间'
where languagetype = 'zh' and trantable ='ld_field' and tabid = @tabid and relateid=@fieldid;
delimiter;
select fieldid into @fieldid from ld_field where tabid = @tabid and fieldname = 'modifiedtime';
UPDATE ld_tranlabel SET fieldlabel='修改时间'
where languagetype = 'zh' and trantable ='ld_field' and tabid = @tabid and relateid=@fieldid;
delimiter;

select tabid into @tabid from ld_tab where name = 'Campaigns';
update ld_field set typeofdata = 'D~M' where tabid=@tabid and columnname = 'startdate' and uitype = 5;


select tabid into @tabid from ld_tab where name='Quotes';
select fieldid into @fieldid from ld_field where tabid = @tabid and fieldname = 'vendor_id';
update ld_tranlabel set fieldlabel = '供应商' where languagetype = 'zh' and trantable = 'ld_field' and tabid = @tabid and relateid = @fieldid;

alter table ld_producttoolfield_formula modify column columnstring text;
delimiter;


insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','FUTURE','未来','fixedstr' from dual 
where not exists(select 1 from ld_desk where labelbol = 'FUTURE' and languagetype = 'zh' and labeltype = 'fixedstr');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','FUTURE','future','fixedstr' from dual 
where not exists(select 1 from ld_desk where labelbol = 'FUTURE' and languagetype = 'en' and labeltype = 'fixedstr');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','LAST','过去','fixedstr' from dual 
where not exists(select 1 from ld_desk where labelbol = 'LAST' and languagetype = 'zh' and labeltype = 'fixedstr');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','LAST','last','fixedstr' from dual 
where not exists(select 1 from ld_desk where labelbol = 'LAST' and languagetype = 'en' and labeltype = 'fixedstr');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','AFTERDAY','天后','fixedstr' from dual 
where not exists(select 1 from ld_desk where labelbol = 'AFTERDAY' and languagetype = 'zh' and labeltype = 'fixedstr');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','AFTERDAY','after day','fixedstr' from dual 
where not exists(select 1 from ld_desk where labelbol = 'AFTERDAY' and languagetype = 'en' and labeltype = 'fixedstr');
delimiter;

UPDATE ld_cvstdfilter SET stdfilter='last1days' where stdfilter='last0days';
UPDATE ld_cvstdfilter SET stdfilter='before1days' where stdfilter='before0days';
UPDATE ld_cvstdfilter SET stdfilter='next1days' where stdfilter='next0days';
UPDATE ld_cvstdfilter SET stdfilter='after1days' where stdfilter='after0days';
delimiter;

select max(tabid) into @tabid from ld_tab; 
insert into ld_tab(tabid,name,presence,tabsequence,tablabel,customized,ownedby,isentitytype,parent,printtab) 
select @tabid+1,'mobileServiceCharge',1,50,'mobileServiceCharge',0,0,1,'Service',1 from dual where not exists(select 1 from ld_tab where name='mobileServiceCharge'); 
select MAX(cvid) into @maxid from ld_customview; 
update ld_customview_seq set id=@maxid+1 where not EXISTS(select 1 from ld_customview where viewname='mobileServiceCharge' and entitytype='mobileServiceCharge'); 
insert into ld_customview(cvid,viewname,setdefault,setmetrics,entitytype,status,userid,sequence,pagewidthpercent)select @maxid+1,'mobileServiceCharge',0,0,'mobileServiceCharge',0,1,1,100 
from dual where not EXISTS(select 1 from ld_customview where viewname='mobileServiceCharge' and entitytype='mobileServiceCharge'); 
select cvid into @cvid from ld_customview where viewname='mobileServiceCharge' and entitytype='mobileServiceCharge'; 
delete from ld_cvcolumnlist where cvid=(select cvid from ld_customview where viewname='mobileServiceCharge' and entitytype='mobileServiceCharge' ); 
insert into ld_cvcolumnlist (cvid,columnindex,columnname) values(@cvid,0,'ld_account:accountname:accountname:Accounts_客户名称:V' ); 
insert into ld_cvcolumnlist (cvid,columnindex,columnname) values(@cvid,1,'ld_account:servicecasher:servicecasher:Accounts_服务收费人:V' ); 
insert into ld_cvcolumnlist (cvid,columnindex,columnname) values(@cvid,2,'ld_account:rating:rating:Accounts_客户状态:V' ); 
insert into ld_cvcolumnlist (cvid,columnindex,columnname) values(@cvid,3,'ld_account:createdtime:createdtime:Accounts_创建时间:D' ); 
delimiter;
-- 2016-04-19

call AddColumn('ld_dividendorder','adjustment','decimal','20',0);
delimiter;
call AddColumn('ld_dividendorder','principal','decimal','20',0);
delimiter;
call AddColumn('ld_dividendorder','float_income','decimal','20',0);
delimiter;
call AddColumn('ld_dividendorder','rate_money','decimal','20',0);
delimiter;
call addtableIndex('ld_buyproducthistory','idx_accountid_productid_buyproducthistory','accountid,productid');
delimiter;
call addtableIndex('ld_dividendorder','idx_accountid_productid_dividendorder','accountid,product_id');
delimiter;
call addtableIndex('ld_dividendorder','idx_salesorderid_dividendorder','salesorderid');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','RATERECALCULATE','利息重算','fixedstr' from dual 
where not EXISTS(select 1 from ld_desk where LANGUAGEtype='zh' and labelbol='RATERECALCULATE' and labeltype='fixedstr');

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','RATERECALCULATE','Rate recalculate','fixedstr' from dual 
where not EXISTS(select 1 from ld_desk where LANGUAGEtype='en' and labelbol='RATERECALCULATE' and labeltype='fixedstr');

update ld_dividendorder set salesorderid=0 where product_id in  (select product_id  from ld_dividend_rules  where  formulacapital='everycontract' )
 or not EXISTS(select 1 from ld_dividend_rules);
delimiter;

update ld_dividendorder
inner join 
(select sum(ifnull(adjustment,0)) as sumadjustment,Dividendorderid from ld_dividendorderdetail  where adjustment>0 GROUP BY Dividendorderid)
as sumdetail
on ld_dividendorder.dividendorderid=sumdetail.Dividendorderid 
set adjustment=sumadjustment;

update ld_dividendorder
inner join 
(select sum(ifnull(adjustment,0)) as sumrate_money,Dividendorderid from ld_dividendorderdetail  where rate_money>0 GROUP BY Dividendorderid)
as sumdetail
on ld_dividendorder.dividendorderid=sumdetail.Dividendorderid 
set rate_money=sumrate_money;

update ld_dividendorder
INNER JOIN ( 
select princial,Dividendorderid from ld_dividendorderdetail
inner join (
select max(id) as maxid from ld_dividendorderdetail  GROUP BY Dividendorderid)
as maxdetail on maxdetail.maxid=ld_dividendorderdetail.id ) as detailprincipal
on detailprincipal.dividendorderid=ld_dividendorder.dividendorderid
set ld_dividendorder.principal=detailprincipal.princial;

update ld_dividendorder
INNER JOIN ( 
select float_income,Dividendorderid from ld_dividendorderdetail
inner join (
select max(id) as maxid from ld_dividendorderdetail  GROUP BY Dividendorderid)
as maxdetail on maxdetail.maxid=ld_dividendorderdetail.id ) as detailprincipal
on detailprincipal.dividendorderid=ld_dividendorder.dividendorderid
set ld_dividendorder.float_income=detailprincipal.float_income;
delimiter;
-- 2016-04-20

select usereportid into @parentid   from ld_usereport where name='AttendanceReport';
insert into ld_usereport(name,reportlabel,tabids,basicfilter,advfilter,setcolumns,Parent_id,sequence,reporttype,pagewidthpercent)
select 'USERTRACKREPORT','移动轨迹',0,1,0,0,@parentid,2,55,100 from dual
 where not EXISTS(select 1 from ld_usereport where name='USERTRACKREPORT');
 
select usereportid into @usereportid from ld_usereport where name='USERTRACKREPORT';
insert into ld_usereportbasic(usereportid,columns,defaultvalue,sequence)
select @usereportid,'ld_usertrack:createdtime:createdtime:OftenUsereport_createdtime:D','thistoday',1 from DUAL
where not EXISTS(select 1 from ld_usereportbasic where usereportid=@usereportid);

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','USERTRACKREPORT','移动轨迹','fixedstr' from DUAL
where not EXISTS(select 1 from ld_desk where labelbol='USERTRACKREPORT' and languagetype='zh' and labeltype='fixedstr');

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','USERTRACKREPORT','Move Track','fixedstr' from DUAL
where not EXISTS(select 1 from ld_desk where labelbol='USERTRACKREPORT' and languagetype='en' and labeltype='fixedstr');
delimiter;

update ld_tranlabel set fieldlabel='Related Orders' where trantable='ld_producttoolfield' and languagetype='en' 
and Relateid in (select producttoolfieldid from ld_producttoolfield where columnname='entitytype' and tablename='ld_inventoryproductrel')
and fieldlabel='Orignal bill';

update ld_tabdetailfield set presence=1 where columnname='projectid' and tablename='ld_expensedetailscf' 
and not exists (select 1 from ld_version where account='utrc');

UPDATE ld_dividend_rules_formulas set formulas='Capital*Rate/4',`describe` = '{本金}*{固定年化收益率}/4'
WHERE formulas='Capital*Rate*Days/4' AND formulamode = 'quarterly';
UPDATE ld_dividend_rules_formulas set formulas='Capital*Rate/2',`describe` = '{本金}*{固定年化收益率}/2'
WHERE formulas='Capital*Rate*Days/2' AND formulamode = 'semiannual';
UPDATE ld_dividend_rules_formulas set formulas='Capital*Rate*Days/12/AcMonth',`describe` = '{本金}*{固定年化收益率}*{计息天数}/12/{当月实际天数}'
WHERE formulas='Capital*Rate*Days/12' AND formulamode = 'monthly';
insert into ld_desk(languagetype,labelbol,fieldlabel,Labeltype)
  select 'zh','ACTUALDAYSOFMONTH','当月实际天数','fixedstr' from dual
  where not exists(select 1 from ld_desk where labelbol='ACTUALDAYSOFMONTH' and languagetype='zh');
insert into ld_desk(languagetype,labelbol,fieldlabel,Labeltype)
  select 'en','ACTUALDAYSOFMONTH','ActualDaysOfMonth','fixedstr' from dual
  where not exists(select 1 from ld_desk where labelbol='ACTUALDAYSOFMONTH' and languagetype='en');

update ld_systems_deploy set sequence = sequence + 1 where deploy_type = 33;
delimiter;

set @i=0;
update ld_systems_deploy set sequence=(@i:=@i+1) order by sequence;
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','SEARCHRESULTSRATERECALCULATE','重算搜索结果','fixedstr' from dual 
where not EXISTS(select 1 from ld_desk where LANGUAGEtype='zh' and labelbol='SEARCHRESULTSRATERECALCULATE' and labeltype='fixedstr');

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','SEARCHRESULTSRATERECALCULATE','The recalculation of search results','fixedstr' from dual 
where not EXISTS(select 1 from ld_desk where LANGUAGEtype='en' and labelbol='SEARCHRESULTSRATERECALCULATE' and labeltype='fixedstr');


insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','RERECALCULATESELECTED','重算选定记录','fixedstr' from dual 
where not EXISTS(select 1 from ld_desk where LANGUAGEtype='zh' and labelbol='RERECALCULATESELECTED' and labeltype='fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','RERECALCULATESELECTED','Recalculate selected records','fixedstr' from dual 
where not EXISTS(select 1 from ld_desk where LANGUAGEtype='en' and labelbol='RERECALCULATESELECTED' and labeltype='fixedstr');


insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','RERECALCULATEMETHOD','重算方式','fixedstr' from dual 
where not EXISTS(select 1 from ld_desk where LANGUAGEtype='zh' and labelbol='RERECALCULATEMETHOD' and labeltype='fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','RERECALCULATEMETHOD','Recalculation method','fixedstr' from dual 
where not EXISTS(select 1 from ld_desk where LANGUAGEtype='en' and labelbol='RERECALCULATEMETHOD' and labeltype='fixedstr');


insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','DELETENODIVIDENDRECAL','删除未派记录并重算','fixedstr' from dual 
where not EXISTS(select 1 from ld_desk where LANGUAGEtype='zh' and labelbol='DELETENODIVIDENDRECAL' and labeltype='fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','DELETENODIVIDENDRECAL','Delete no dividend and recalculation','fixedstr' from dual 
where not EXISTS(select 1 from ld_desk where LANGUAGEtype='en' and labelbol='DELETENODIVIDENDRECAL' and labeltype='fixedstr');

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','DELETEALLRECORDSRECAL','删除全部记录并重算','fixedstr' from dual 
where not EXISTS(select 1 from ld_desk where LANGUAGEtype='zh' and labelbol='DELETEALLRECORDSRECAL' and labeltype='fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','DELETEALLRECORDSRECAL','Delete all records and recalculation','fixedstr' from dual 
where not EXISTS(select 1 from ld_desk where LANGUAGEtype='en' and labelbol='DELETEALLRECORDSRECAL' and labeltype='fixedstr');

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','INTERESTRECALWILLCHANGE','利息重算将改变现有派息记录，是否继续？','jspop' from dual 
where not EXISTS(select 1 from ld_desk where LANGUAGEtype='zh' and labelbol='INTERESTRECALWILLCHANGE' and labeltype='jspop');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','INTERESTRECALWILLCHANGE','Interest recalculation will change the existing dividend records, whether to continue?','jspop' from dual 
where not EXISTS(select 1 from ld_desk where LANGUAGEtype='en' and labelbol='INTERESTRECALWILLCHANGE' and labeltype='jspop');


insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','SELECTRECALRECORD','请选择重算记录','jspop' from dual 
where not EXISTS(select 1 from ld_desk where LANGUAGEtype='zh' and labelbol='INTERESTRECALWILLCHANGE' and labeltype='jspop');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','SELECTRECALRECORD','Please select recalculation record','jspop' from dual 
where not EXISTS(select 1 from ld_desk where LANGUAGEtype='en' and labelbol='SELECTRECALRECORD' and labeltype='jspop');

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','HASSETFLOATINCOMEWHETER','已设定浮动收益参数，是否立核算浮动收益？','jspop' from dual 
where not EXISTS(select 1 from ld_desk where LANGUAGEtype='zh' and labelbol='HASSETFLOATINCOMEWHETER' and labeltype='jspop');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','HASSETFLOATINCOMEWHETER','Has set the parameters of floating income, whether or not to calculate the floating income?','jspop' from dual 
where not EXISTS(select 1 from ld_desk where LANGUAGEtype='en' and labelbol='HASSETFLOATINCOMEWHETER' and labeltype='jspop');
delimiter;
-- 2016-04-21

select usereportid into @usereportid from ld_usereport where name='AttendanceReport';
update ld_usereport set Parent_id=@usereportid where name='USERTRACKREPORT';
delimiter;

select tabid into @tabid from ld_tab where `name`='Campaigns';
select block into @blockid from ld_field where tabid=@tabid and columnname='campaignname';

update ld_field set sequence=500 where tabid=@tabid and columnname='approveby' and sequence is NULL;
update ld_field set sequence=501 where tabid=@tabid and columnname='approvestatus' and sequence is NULL;

set @i=0;
update ld_field set sequence=(@i:=@i+1) where tabid=@tabid and block=@blockid order by sequence;
delimiter;

update ld_field set uitype=52,displaytype=2 where tabid=2 and columnname='lastcontactuser';

CALL AddColumn('ld_systems_deploy','roottype','tinyint','4',0);
delimiter;
CALL AddColumn('ld_systems_deploy','inputtype','varchar','200','');
delimiter;
CALL AddColumn('ld_systems_deploy','presence','tinyint','4',0);
delimiter;
CALL AddColumn('ld_systems_deploy','inputvalue','text','','');
delimiter;

alter table ld_tranlabel modify fieldlabel text not null;

select max(sequence)+1 into @sequence from ld_systems_deploy;
insert into ld_systems_deploy(deploy_value,deploy_type,description,setype,sequence,roottype,inputtype,inputvalue,presence)
select 1,98,'项目进度是否启用审批流程。1:否，0:是','ProjectProgress',@sequence,2,'select','[{"value":"0","text":"YES"},{"value":"1","text":"NO"},{"sql":""}]',0
from dual where not EXISTS(select 1 from ld_systems_deploy where deploy_type=98);
delimiter;

CALL AddColumn('ld_projectprogress','approveby','int','19','0');
delimiter;
CALL AddColumn('ld_projectprogress','approvestatus','varchar','200','');
delimiter;
alter table ld_projectprogress alter approvestatus set default '未提交';
delimiter;
call fieldprofile('ProjectProgress');
delimiter;
call getallprofile('ProjectProgress');
delimiter;

select tabid into @tabid from ld_tab where name='ProjectProgress';
insert into ld_field(tabid,fieldid,columnname,tablename,uitype,fieldname,fieldlabel,block,displaytype,presence,typeofdata,sequence)
select @tabid,(select max(fieldid) from ld_field)+1,'approveby','ld_projectprogress',131,'approveby','审批人',(select blockid from ld_blocks where blocklabel='LBL_PROJECTPROGRESS_INFO'),1,0,'V~O',(select max(sequence)+1 from ld_field where tabid=@tabid) from dual where not EXISTS(select * from ld_field where tabid=@tabid and columnname='approveby');
insert into ld_field(tabid,fieldid,columnname,tablename,uitype,fieldname,fieldlabel,block,displaytype,presence,typeofdata,sequence)
select @tabid,(select max(fieldid) from ld_field)+1,'approvestatus','ld_projectprogress',130,'approvestatus','审批状态',(select blockid from ld_blocks where blocklabel='LBL_PROJECTPROGRESS_INFO'),1,0,'V~O',(select max(sequence)+1 from ld_field where tabid=@tabid) from dual where not EXISTS(select * from ld_field where tabid=@tabid and columnname='approvestatus');
update ld_field_seq set id=(select max(fieldid) from ld_field);
delimiter;

select fieldid into @fieldid from ld_field where tabid = @tabid and fieldname = 'approveby';
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'zh','ld_field',@tabid,@fieldid,'审批人' 
from dual where not EXISTS(select 1 from ld_tranlabel  where languagetype = 'zh' 
and trantable ='ld_field' and tabid = @tabid and relateid=@fieldid);
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'en','ld_field',@tabid,@fieldid,'Approver' 
from dual where not EXISTS(select 1 from ld_tranlabel  where languagetype = 'en' 
and trantable ='ld_field' and tabid = @tabid and relateid=@fieldid);  
select fieldid into @fieldid from ld_field where tabid = @tabid and fieldname = 'approvestatus';
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'zh','ld_field',@tabid,@fieldid,'审批状态' 
from dual where not EXISTS(select 1 from ld_tranlabel  where languagetype = 'zh' 
and trantable ='ld_field' and tabid = @tabid and relateid=@fieldid);
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'en','ld_field',@tabid,@fieldid,'Approve Status' 
from dual where not EXISTS(select 1 from ld_tranlabel  where languagetype = 'en' 
and trantable ='ld_field' and tabid = @tabid and relateid=@fieldid);
delimiter; 
select tabid into @tabid from ld_tab where name='ProjectProgress';
insert into ld_approve(id,tabid,name,status,smcreatorid,modifiedby,createdtime,modifiedtime,approveallocatetype)
select (select max(id) from ld_approve)+1,@tabid,'项目进度默认流程',0,1,1,NOW(),NOW(),0
from dual where not EXISTS(select * from ld_approve where tabid=@tabid and name='项目进度默认流程');
select id into @id from ld_approve where tabid=@tabid and name='项目进度默认流程';
insert into ld_approvestep(id,approveid,name,ended,step,sequence,createdtime,modifiedtime,approvetype,approvevalue,specifyapproverid)
select (select max(id) from ld_approvestep)+1,@id,'步骤一',1,1,1,NOW(),NOW(),0,1,1
from dual where not EXISTS(select 1 from ld_approvestep where approveid=@id and name='步骤一');
insert into ld_approvestep(id,approveid,name,ended,step,sequence,createdtime,modifiedtime,approvetype,approvevalue,specifyapproverid)
select (select max(id) from ld_approvestep)+1,@id,'步骤二',1,1,2,NOW(),NOW(),0,1,1
from dual where not EXISTS(select 1 from ld_approvestep where approveid=@id and name='步骤二');
update ld_approve_seq set id=(select max(id) from ld_approve);
update ld_approvestep_seq set id=(select max(id) from ld_approvestep);
insert into ld_approve2user(approveid,userid)
select @id,-1 from dual 
where not EXISTS(select 1 from ld_approve2user where approveid=@id and userid=-1);
delimiter;

insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'zh','ld_system_deploy',1,1,'在{$SalesOrder.SalesOrder}模块创建{$PaymentPlan.PaymentPlan}时是否控制{$PaymentPlan.PaymentPlan}总额必须等于订单金额'
from dual where not exists (select * from ld_tranlabel where languagetype='zh' and trantable='ld_system_deploy' and relateid=1);
delimiter;

insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'en','ld_system_deploy',1,1,' If the total payment plan must be equal to the amount of orders to create outstanding program in the {$SalesOrder.SalesOrder} control module'
from dual where not exists (select * from ld_tranlabel where languagetype='en' and trantable='ld_system_deploy' and relateid=1);
delete from ld_desk where labelbol='TOTALPAYMENTPLANEQUALORDER';
update ld_systems_deploy set roottype='1',inputtype='select',inputvalue='[{"value":"1","text":"YES"},{"value":"0","text":"NO"},{"sql":""},{"relatedmodule":"SalesOrder,PaymentPlan"}]',presence=0 where deploy_type=1;
delimiter;

insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'zh','ld_system_deploy',10,10,'必须严格参照源单（每种产品累计数量不允许超出源单或者出现源单外的产品）'
from dual where not exists (select * from ld_tranlabel where languagetype='zh' and trantable='ld_system_deploy' and relateid=10);
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'en','ld_system_deploy',10,10,'must be strictly according to source and single (each product cumulative quantity is not allowed to exceed the source single or source single foreign products)'
from dual where not exists (select * from ld_tranlabel where languagetype='en' and trantable='ld_system_deploy' and relateid=10);
delete from ld_desk where labelbol='OUTBOUNDSTOCKACCORDORIGNAL';
update ld_systems_deploy set roottype='1',inputtype='select',inputvalue='[{"value":"0","text":"YES"},{"value":"1","text":"NO"},{"sql":""}]',presence=0 where deploy_type=10;
delimiter;

insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'zh','ld_system_deploy',12,12,'{$SalesOrder.SalesOrder}新增保存后是否立即创建{$PaymentPlan.PaymentPlan}'
from dual where not exists (select * from ld_tranlabel where languagetype='zh' and trantable='ld_system_deploy' and relateid=12);
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'en','ld_system_deploy',12,12,'Whether to create {$PaymentPlan.PaymentPlan} immediately after creating {$SalesOrder.SalesOrder}'
from dual where not exists (select * from ld_tranlabel where languagetype='en' and trantable='ld_system_deploy' and relateid=12);
delete from ld_desk where labelbol='WHETHERIMMCREATEPAYMENTPLAN';
update ld_systems_deploy set roottype='1',inputtype='select',inputvalue='[{"value":"0","text":"YES"},{"value":"1","text":"NO"},{"sql":""},{"relatedmodule":"SalesOrder,PaymentPlan"}]',presence=0 where deploy_type=12;
delimiter;

insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'zh','ld_system_deploy',13,13,'设置序时簿列表每页显示记录的条数'
from dual where not exists (select * from ld_tranlabel where languagetype='zh' and trantable='ld_system_deploy' and relateid=13);
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'en','ld_system_deploy',13,13,'Setting the page list of chronological book displaying the number of records per page'
from dual where not exists (select * from ld_tranlabel where languagetype='en' and trantable='ld_system_deploy' and relateid=13);
delete from ld_desk where labelbol='LISTBOOKNUM';
update ld_systems_deploy set roottype='1',inputtype='text',inputvalue='',presence=0 where deploy_type=13;
delimiter;

insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'zh','ld_system_deploy',14,14,'设置相关信息列表每页显示记录的条数'
from dual where not exists (select * from ld_tranlabel where languagetype='zh' and trantable='ld_system_deploy' and relateid=14);
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'en','ld_system_deploy',14,14,'Set more page list of info displaying the number of records per page'
from dual where not exists (select * from ld_tranlabel where languagetype='en' and trantable='ld_system_deploy' and relateid=14);
delete from ld_desk where labelbol='PAGEMORELISTNUM';
update ld_systems_deploy set roottype='1',inputtype='text',inputvalue='',presence=0 where deploy_type=14;
delimiter;

insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'zh','ld_system_deploy',15,15,'{$PurchaseOrder.PurchaseOrder}新增保存后是否立即创建{$SendPayment.SendPayment}'
from dual where not exists (select * from ld_tranlabel where languagetype='zh' and trantable='ld_system_deploy' and relateid=15);
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'en','ld_system_deploy',15,15,'Whether to create {$SendPayment.SendPayment} immediately after creating {$PurchaseOrder.PurchaseOrder}'
from dual where not exists (select * from ld_tranlabel where languagetype='en' and trantable='ld_system_deploy' and relateid=15);
delete from ld_desk where labelbol='WHETHERIMMCREATESENDPAYMENT';
update ld_systems_deploy set roottype='1',inputtype='select',inputvalue='[{"value":"0","text":"YES"},{"value":"1","text":"NO"},{"sql":""}]',presence=0 where deploy_type=15;
delimiter;

insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'zh','ld_system_deploy',20,20,'在{$PurchaseOrder.PurchaseOrder}模块创建{$SendPayment.SendPayment}时是否控制{$SendPayment.SendPayment}总额必须等于订单金额'
from dual where not exists (select * from ld_tranlabel where languagetype='zh' and trantable='ld_system_deploy' and relateid=20);
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'en','ld_system_deploy',20,20,' Create payment plan in {$PurchaseOrder.PurchaseOrder} module controls whether the payment plan must be equal to the total amount of the order'
from dual where not exists (select * from ld_tranlabel where languagetype='en' and trantable='ld_system_deploy' and relateid=20);
delete from ld_desk where labelbol='CREATESENDPAMENTEQUALORDER';
update ld_systems_deploy set roottype='1',inputtype='select',inputvalue='[{"value":"1","text":"YES"},{"value":"0","text":"NO"},{"sql":""},{"relatedmodule":"PurchaseOrder,SendPayment"}]',presence=0 where deploy_type=20;
delimiter;

insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'zh','ld_system_deploy',26,26,'{$Potentials.Potentials}资料分配时是否同时分配相关信息'
from dual where not exists (select * from ld_tranlabel where languagetype='zh' and trantable='ld_system_deploy' and relateid=26);
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'en','ld_system_deploy',26,26,'Distribute the related data when distribute {$Potentials.Potentials}'
from dual where not exists (select * from ld_tranlabel where languagetype='en' and trantable='ld_system_deploy' and relateid=26);
delete from ld_desk where labelbol='POTENTIALSDISWHETHERDIS';
update ld_systems_deploy set roottype='1',inputtype='select',inputvalue='[{"value":"0","text":"YES"},{"value":"1","text":"NO"},{"sql":""},{"relatedmodule":"Potentials"}]',presence=0 where deploy_type=26;
delimiter;

insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'zh','ld_system_deploy',33,33,'设置是否仅允许系统管理员用户取消共享'
from dual where not exists (select * from ld_tranlabel where languagetype='zh' and trantable='ld_system_deploy' and relateid=33);
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'en','ld_system_deploy',33,33,'If only allows the administrator to cancel share'
from dual where not exists (select * from ld_tranlabel where languagetype='en' and trantable='ld_system_deploy' and relateid=33);
delete from ld_desk where labelbol='SHARINGSETTINGS';
update ld_systems_deploy set roottype='1',inputtype='select',inputvalue='[{"value":"0","text":"YES"},{"value":"1","text":"NO"},{"sql":""}]',presence=0 where deploy_type=33;
delimiter;

insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'zh','ld_system_deploy',37,37,'{$SalesOrder.SalesOrder}新增保存时更新{$Accounts.Accounts}的{$Accounts.rating}为（为空表示不更新）'
from dual where not exists (select * from ld_tranlabel where languagetype='zh' and trantable='ld_system_deploy' and relateid=37);
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'en','ld_system_deploy',37,37,'{$Accounts.Accounts} updated when {$SalesOrder.SalesOrder} Added save {$Accounts.rating} is (blank means no update)'
from dual where not exists (select * from ld_tranlabel where languagetype='en' and trantable='ld_system_deploy' and relateid=37);
delete from ld_desk where labelbol='UWASIBMNU';
update ld_systems_deploy set roottype='1',inputtype='select',inputvalue='[{"value":"","text":""},{"sql":"select * from ld_rating where presence=1 order by picklist_valueid asc","field":"rating"},{"relatedmodule":"SalesOrder,Accounts"}]',presence=0 where deploy_type=37;
delimiter;

insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'zh','ld_system_deploy',38,38,'{$SalesOrder.SalesOrder}新增保存时更新{$Potentials.Potentials}的{$Potentials.sales_stage}为（为空表示不更新）'
from dual where not exists (select * from ld_tranlabel where languagetype='zh' and trantable='ld_system_deploy' and relateid=38);
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'en','ld_system_deploy',38,38,'{$Potentials.Potentials} updated when {$SalesOrder.SalesOrder} Added save {$Potentials.sales_stage} is (blank means no update)'
from dual where not exists (select * from ld_tranlabel where languagetype='en' and trantable='ld_system_deploy' and relateid=38);
delete from ld_desk where labelbol='UWASIBMNU2';
update ld_systems_deploy set roottype='1',inputtype='select',inputvalue='[{"value":"","text":""},{"sql":"select * from ld_sales_stage where presence=1 order by picklist_valueid asc","field":"sales_stage"},{"relatedmodule":"SalesOrder,Potentials"}]',presence=0 where deploy_type=38;
delimiter;

insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'zh','ld_system_deploy',48,48,'更新库存流水记录触发点'
from dual where not exists (select * from ld_tranlabel where languagetype='zh' and trantable='ld_system_deploy' and relateid=48);
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'en','ld_system_deploy',48,48,' update the trigger point of inventory record'
from dual where not exists (select * from ld_tranlabel where languagetype='en' and trantable='ld_system_deploy' and relateid=48);
delete from ld_desk where labelbol='UPDATEINVENTORYLEDGER';
update ld_systems_deploy set roottype='1',inputtype='select',inputvalue='[{"value":"0","text":"Checkout"},{"value":"1","text":"SAVE"},{"sql":""}]',presence=0 where deploy_type=48;
delimiter;

insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'zh','ld_system_deploy',49,49,'设置单据分录明细中数量字段小数位数'
from dual where not exists (select * from ld_tranlabel where languagetype='zh' and trantable='ld_system_deploy' and relateid=49);
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'en','ld_system_deploy',49,49,'Length of the decimal digits'
from dual where not exists (select * from ld_tranlabel where languagetype='en' and trantable='ld_system_deploy' and relateid=49);
delete from ld_desk where labelbol='LENGTHDECIMALDIGITS';
update ld_systems_deploy set roottype='1',inputtype='opetext',inputvalue='',presence=0 where deploy_type=49;
delimiter;

insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'zh','ld_system_deploy',54,54,'{$Potentials.Potentials}新增保存后是否立即创建回款预测'
from dual where not exists (select * from ld_tranlabel where languagetype='zh' and trantable='ld_system_deploy' and relateid=54);
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'en','ld_system_deploy',54,54,'Whether to create receivables forecast immediately after creating {$Potentials.Potentials}'
from dual where not exists (select * from ld_tranlabel where languagetype='en' and trantable='ld_system_deploy' and relateid=54);
delete from ld_desk where labelbol='Whethercreatereceivablesforecastimmediately';
update ld_systems_deploy set roottype='1',inputtype='select',inputvalue='[{"value":"0","text":"YES"},{"value":"1","text":"NO"},{"sql":""},{"relatedmodule":"Potentials"}]',presence=0 where deploy_type=54;
delimiter;

insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'zh','ld_system_deploy',57,57,'{$SalesOrder.SalesOrder}新增或编辑后是否立即打印'
from dual where not exists (select * from ld_tranlabel where languagetype='zh' and trantable='ld_system_deploy' and relateid=57);
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'en','ld_system_deploy',57,57,'After creating salesorder print immediately'
from dual where not exists (select * from ld_tranlabel where languagetype='en' and trantable='ld_system_deploy' and relateid=57);
delete from ld_desk where labelbol='AFTERCREATESALESORDERPRINT';
update ld_systems_deploy set roottype='1',inputtype='select',inputvalue='[{"value":"0","text":"YES"},{"value":"1","text":"NO"},{"sql":""},{"relatedmodule":"SalesOrder"}]',presence=0 where deploy_type=57;
delimiter;

insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'zh','ld_system_deploy',56,56,'{$SalesOrder.SalesOrder}新增保存后自动创建{$OutboundOrder.OutboundOrder}，关联仓库（为空表示不创建）'
from dual where not exists (select * from ld_tranlabel where languagetype='zh' and trantable='ld_system_deploy' and relateid=56);
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'en','ld_system_deploy',56,56,'After creating salesorder create outbound order automaticly，the related warhouse is'
from dual where not exists (select * from ld_tranlabel where languagetype='en' and trantable='ld_system_deploy' and relateid=56);
delete from ld_desk where labelbol='AFTERCREATESALESORDERCREATEOUTORDER';
update ld_systems_deploy set roottype='1',inputtype='select',inputvalue='[{"value":"","text":""},{"sql":"select DISTINCT ld_warehouse.name,ld_warehouse.id from  ld_warehouse where ld_warehouse.started = 0 and ld_warehouse.status = 0 order by ld_warehouse.id","field":"name"},{"relatedmodule":"SalesOrder,OutboundOrder"}]',presence=0 where deploy_type=56;
delimiter;

insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'zh','ld_system_deploy',58,58,'{$ServiceContracts.ServiceContracts}新增保存后是否立即创建{$PaymentPlan.PaymentPlan}'
from dual where not exists (select * from ld_tranlabel where languagetype='zh' and trantable='ld_system_deploy' and relateid=58);
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'en','ld_system_deploy',58,58,'Whether to create {$PaymentPlan.PaymentPlan} immediately after creating {$ServiceContracts.ServiceContracts}'
from dual where not exists (select * from ld_tranlabel where languagetype='en' and trantable='ld_system_deploy' and relateid=58);
delete from ld_desk where labelbol='WTCPPIACSS';
update ld_systems_deploy set roottype='1',inputtype='select',inputvalue='[{"value":"0","text":"YES"},{"value":"1","text":"NO"},{"sql":""},{"relatedmodule":"PaymentPlan,ServiceContracts"}]',presence=0 where deploy_type=58;
delimiter;

insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'zh','ld_system_deploy',59,59,'在{$ServiceContracts.ServiceContracts}模块创建{$PaymentPlan.PaymentPlan}时是否控制{$PaymentPlan.PaymentPlan}总额必须等于{$ServiceContracts.ServiceContracts}金额'
from dual where not exists (select * from ld_tranlabel where languagetype='zh' and trantable='ld_system_deploy' and relateid=59);
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'en','ld_system_deploy',59,59,'Create payment plan in {$ServiceContracts.ServiceContracts} module controls whether the payment plan must be equal to the total amount of the order'
from dual where not exists (select * from ld_tranlabel where languagetype='en' and trantable='ld_system_deploy' and relateid=59);
delete from ld_desk where labelbol='WTTPPMBETTAOOWTCPPTTMOSS';
update ld_systems_deploy set roottype='1',inputtype='select',inputvalue='[{"value":"0","text":"YES"},{"value":"1","text":"NO"},{"sql":""},{"relatedmodule":"ServiceContracts,PaymentPlan"}]',presence=0 where deploy_type=59;
delimiter;

insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'zh','ld_system_deploy',61,61,'{$Accounts.Accounts}资料分配时是否同时分配相关信息'
from dual where not exists (select * from ld_tranlabel where languagetype='zh' and trantable='ld_system_deploy' and relateid=61);
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'en','ld_system_deploy',61,61,'Distribute the related data when distribute {$Accounts.Accounts}'
from dual where not exists (select * from ld_tranlabel where languagetype='en' and trantable='ld_system_deploy' and relateid=61);
delete from ld_desk where labelbol='ACCOUNTALSDISWHETHERDIS';
update ld_systems_deploy set roottype='1',inputtype='select',inputvalue='[{"value":"0","text":"YES"},{"value":"1","text":"NO"},{"sql":""},{"relatedmodule":"Accounts"}]',presence=0 where deploy_type=61;
delimiter;

insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'zh','ld_system_deploy',63,63,'{$SalesOrder.SalesOrder}编辑保存后自动创建{$OutboundOrder.OutboundOrder}，关联仓库（为空表示不创建）'
from dual where not exists (select * from ld_tranlabel where languagetype='zh' and trantable='ld_system_deploy' and relateid=63);
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'en','ld_system_deploy',63,63,'After edit salesorder create outbound order automaticly，the related warhouse is'
from dual where not exists (select * from ld_tranlabel where languagetype='en' and trantable='ld_system_deploy' and relateid=63);
delete from ld_desk where labelbol='AFTEREDITSALESORDERCREATEOUTORDER';
update ld_systems_deploy set roottype='1',inputtype='select',inputvalue='[{"value":"","text":""},{"sql":"select DISTINCT ld_warehouse.name,ld_warehouse.id from  ld_warehouse where ld_warehouse.started = 0 and ld_warehouse.status = 0 order by ld_warehouse.id","field":"name"},{"relatedmodule":"SalesOrder,OutboundOrder"}]',presence=0 where deploy_type=63;
delimiter;

insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'zh','ld_system_deploy',66,66,'设置首页默认显示的视图页签'
from dual where not exists (select * from ld_tranlabel where languagetype='zh' and trantable='ld_system_deploy' and relateid=66);
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'en','ld_system_deploy',66,66,'The default display label in the home page.'
from dual where not exists (select * from ld_tranlabel where languagetype='en' and trantable='ld_system_deploy' and relateid=66);
delete from ld_desk where labelbol='LBL_HOMECONTROLSTYLE';
update ld_systems_deploy set roottype='1',inputtype='select',inputvalue='[{"value":"0","text":"LBL_COMPONENTVIEW"},{"value":"1","text":"LBL_COOPERATIVEWORK"},{"sql":""}]',presence=0 where deploy_type=66;
delimiter;

insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'zh','ld_system_deploy',67,67,'设置序时簿中批量操作记录条数的上限'
from dual where not exists (select * from ld_tranlabel where languagetype='zh' and trantable='ld_system_deploy' and relateid=67);
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'en','ld_system_deploy',67,67,'Maximum records number of mass operation'
from dual where not exists (select * from ld_tranlabel where languagetype='en' and trantable='ld_system_deploy' and relateid=67);
delete from ld_desk where labelbol='MAXIMUMRECORDSNUMBEROFMASSOPERATION';
update ld_systems_deploy set roottype='1',inputtype='text',inputvalue='',presence=0 where deploy_type=67;
delimiter;

insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'zh','ld_system_deploy',68,68,'设置关联单据只能选择已审批单据'
from dual where not exists (select * from ld_tranlabel where languagetype='zh' and trantable='ld_system_deploy' and relateid=68);
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'en','ld_system_deploy',68,68,'Only then approved basic data can be choosed'
from dual where not exists (select * from ld_tranlabel where languagetype='en' and trantable='ld_system_deploy' and relateid=68);
delete from ld_desk where labelbol='ROCOSDOFA';
update ld_systems_deploy set roottype='1',inputtype='select',inputvalue='[{"value":"1","text":"YES"},{"value":"0","text":"NO"},{"sql":""}]',presence=0 where deploy_type=68;
delimiter;

insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'zh','ld_system_deploy',69,69,'有关联单据时是否允许删除{$Accounts.Accounts}'
from dual where not exists (select * from ld_tranlabel where languagetype='zh' and trantable='ld_system_deploy' and relateid=69);
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'en','ld_system_deploy',69,69,'Do not allowed to delete {$Accounts.Accounts} when exists associated data'
from dual where not exists (select * from ld_tranlabel where languagetype='en' and trantable='ld_system_deploy' and relateid=69);
delete from ld_desk where labelbol='ISNOTALLOWEDTOdeleteTOACCOUNTS';
update ld_systems_deploy set roottype='1',inputtype='select',inputvalue='[{"value":"0","text":"YES"},{"value":"1","text":"NO"},{"sql":""}]',presence=0 where deploy_type=69;
delimiter;

insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'zh','ld_system_deploy',72,72,'{$Accounts.Accounts}资料明细界面首要联系人是否显示'
from dual where not exists (select * from ld_tranlabel where languagetype='zh' and trantable='ld_system_deploy' and relateid=72);
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'en','ld_system_deploy',72,72,'Whether to display Primary Contact at the block of viewing the details'
from dual where not exists (select * from ld_tranlabel where languagetype='en' and trantable='ld_system_deploy' and relateid=72);
delete from ld_desk where labelbol='CUSTOMERDATAILPRIMARY';
update ld_systems_deploy set roottype='1',inputtype='select',inputvalue='[{"value":"0","text":"YES"},{"value":"1","text":"NO"},{"sql":""},{"relatedmodule":"Accounts,Contacts"}]',presence=0 where deploy_type=72;
delimiter;

insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'zh','ld_system_deploy',73,73,'设置登录时是否启用验证码'
from dual where not exists (select * from ld_tranlabel where languagetype='zh' and trantable='ld_system_deploy' and relateid=73);
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'en','ld_system_deploy',73,73,'Config whether to use the Verification code when login'
from dual where not exists (select * from ld_tranlabel where languagetype='en' and trantable='ld_system_deploy' and relateid=73);
delete from ld_desk where labelbol='LBL_SECURITYCODE_SET_DESCRIPTION';
update ld_systems_deploy set roottype='1',inputtype='select',inputvalue='[{"value":"0","text":"YES"},{"value":"1","text":"NO"},{"sql":""}]',presence=0 where deploy_type=73;
delimiter;

insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'zh','ld_system_deploy',74,74,'设置关联基础资料时是否在所有用户的数据中进行查询'
from dual where not exists (select * from ld_tranlabel where languagetype='zh' and trantable='ld_system_deploy' and relateid=74);
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'en','ld_system_deploy',74,74,'Are fuzzy match when all of the data control to select biography'
from dual where not exists (select * from ld_tranlabel where languagetype='en' and trantable='ld_system_deploy' and relateid=74);
delete from ld_desk where labelbol='AFMWWAOTDCTSB';
update ld_systems_deploy set roottype='1',inputtype='select',inputvalue='[{"value":"1","text":"YES"},{"value":"0","text":"NO"},{"sql":""}]',presence=0 where deploy_type=74;
delimiter;

insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'zh','ld_system_deploy',77,77,'同名附件上传限制方式'
from dual where not exists (select * from ld_tranlabel where languagetype='zh' and trantable='ld_system_deploy' and relateid=77);
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'en','ld_system_deploy',77,77,'The control mode about uploaded the same name attachment'
from dual where not exists (select * from ld_tranlabel where languagetype='en' and trantable='ld_system_deploy' and relateid=77);
delete from ld_desk where labelbol='CONTROLMODEUPLOADEDSAMENAMEATTACHMENT';
update ld_systems_deploy set roottype='1',inputtype='select',inputvalue='[{"value":"0","text":"NOLIMITS"},{"value":"1","text":"WARNNING"},{"value":"2","text":"FORBID"},{"sql":""}]',presence=0 where deploy_type=77;
delimiter;

insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'zh','ld_system_deploy',78,78,'设置首页组件中周月统计是否显示'
from dual where not exists (select * from ld_tranlabel where languagetype='zh' and trantable='ld_system_deploy' and relateid=78);
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'en','ld_system_deploy',78,78,'Whether to display the week and month statistics in homepage'
from dual where not exists (select * from ld_tranlabel where languagetype='en' and trantable='ld_system_deploy' and relateid=78);
delete from ld_desk where labelbol='DISPLAYWEEKMONTHSTATISTICSHOMEPAGE';
update ld_systems_deploy set roottype='1',inputtype='select',inputvalue='[{"value":"0","text":"YES"},{"value":"1","text":"NO"},{"sql":""},{"relatedmodule":"Home"}]',presence=0 where deploy_type=78;
delimiter;

insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'zh','ld_system_deploy',80,80,'设置手机号码的显示样式'
from dual where not exists (select * from ld_tranlabel where languagetype='zh' and trantable='ld_system_deploy' and relateid=80);
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'en','ld_system_deploy',80,80,'Set properties of phone numbers'
from dual where not exists (select * from ld_tranlabel where languagetype='en' and trantable='ld_system_deploy' and relateid=80);
delete from ld_desk where labelbol='SETPROPERTIESOFPHONENUMBERS';
update ld_systems_deploy set roottype='1',inputtype='select',inputvalue='[{"value":"0","text":"DISPLAYTHEALL"},{"value":"1","text":"HIDETHEMIDDLE4"},{"value":"2","text":"HIDETHELAST4NUMBERS"},{"value":"3","text":"HIDEALLNUMBERS"},{"sql":""}]',presence=0 where deploy_type=80;
delimiter;

insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'zh','ld_system_deploy',81,81,'手机号码样式影响数据范围'
from dual where not exists (select * from ld_tranlabel where languagetype='zh' and trantable='ld_system_deploy' and relateid=81);
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'en','ld_system_deploy',81,81,'Data range affected by the style of the mobile phone'
from dual where not exists (select * from ld_tranlabel where languagetype='en' and trantable='ld_system_deploy' and relateid=81);
delete from ld_desk where labelbol='DATARANGEAFFECTEDBYSTYLEOFMOBILEPHONE';
update ld_systems_deploy set roottype='1',inputtype='select',inputvalue='[{"value":"0","text":"ALLOFHEDATA"},{"value":"1","text":"THEPERSONINCHARGEISNOTHIMSELF"},{"value":"2","text":"BOTHPERSONINCHARGEANDCREATORNOTTHEMSELVES"},{"sql":""}]',presence=0 where deploy_type=81;
delimiter;

insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'zh','ld_system_deploy',89,89,'合同订单新增保存后是否立即创建派息单'
from dual where not exists (select * from ld_tranlabel where languagetype='zh' and trantable='ld_system_deploy' and relateid=89);
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'en','ld_system_deploy',89,89,'The new contract orders after preservation immediately creates a single dividend'
from dual where not exists (select * from ld_tranlabel where languagetype='en' and trantable='ld_system_deploy' and relateid=89);
delete from ld_desk where labelbol='THENEWCONTRACTORDERS';
update ld_systems_deploy set roottype='1',inputtype='select',inputvalue='[{"value":"0","text":"YES"},{"value":"1","text":"NO"},{"sql":""}]',presence=0 where deploy_type=89;
delimiter;

insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'zh','ld_system_deploy',93,93,'设置单据分录明细中单价字段小数位数'
from dual where not exists (select * from ld_tranlabel where languagetype='zh' and trantable='ld_system_deploy' and relateid=93);
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'en','ld_system_deploy',93,93,'Set the number of decimal places in the list of documents'
from dual where not exists (select * from ld_tranlabel where languagetype='en' and trantable='ld_system_deploy' and relateid=93);
delete from ld_desk where labelbol='THENUMBEROFDECIMAL_LISTOFDOCUMENTS';
update ld_systems_deploy set roottype='1',inputtype='opetext',inputvalue='',presence=0 where deploy_type=93;
delimiter;

insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'zh','ld_system_deploy',7,7,'当{$Accounts.Accounts}负责人变更时是否发送短信通知新的负责人'
from dual where not exists (select * from ld_tranlabel where languagetype='zh' and trantable='ld_system_deploy' and relateid=7);
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'en','ld_system_deploy',7,7,'When the {$Accounts.Accounts} head is changing,whether to send text messages to inform the new person in charge'
from dual where not exists (select * from ld_tranlabel where languagetype='en' and trantable='ld_system_deploy' and relateid=7);
delete from ld_desk where labelbol='NOTIFYACCOUNTASSIGNED';
update ld_systems_deploy set roottype='3',inputtype='select',inputvalue='[{"value":"1","text":"YES"},{"value":"0","text":"NO"},{"sql":""},{"relatedmodule":"Accounts,MassSMS"}]',presence=0 where deploy_type=7;
delimiter;

insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'zh','ld_system_deploy',18,18,'{$SalesOrder.SalesOrder}交付日期前N天提醒（为0表示当天提醒，为空表示不提醒）'
from dual where not exists (select * from ld_tranlabel where languagetype='zh' and trantable='ld_system_deploy' and relateid=18);
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'en','ld_system_deploy',18,18,'Reminder in N days before the delivery date （if 0 remind on the same day, if null don’t remind）'
from dual where not exists (select * from ld_tranlabel where languagetype='en' and trantable='ld_system_deploy' and relateid=18);
delete from ld_desk where labelbol='REMINDSALESORDERDUEDATE';
update ld_systems_deploy set roottype='3',inputtype='text',inputvalue='[{"relatedmodule":"Reminds,SalesOrder"}]',presence=0 where deploy_type=18;
delimiter;

insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'zh','ld_system_deploy',21,21,'当{$OutboundOrder.OutboundOrder}审核时是否发送短信通知客户'
from dual where not exists (select * from ld_tranlabel where languagetype='zh' and trantable='ld_system_deploy' and relateid=21);
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'en','ld_system_deploy',21,21,'While Confirming whether to send text messages to inform the customer {$OutboundOrder.OutboundOrder}'
from dual where not exists (select * from ld_tranlabel where languagetype='en' and trantable='ld_system_deploy' and relateid=21);
delete from ld_desk where labelbol='CONFIRMINFORMOUTBOUND';
update ld_systems_deploy set roottype='3',inputtype='select',inputvalue='[{"value":"1","text":"YES"},{"value":"0","text":"NO"},{"sql":""},{"relatedmodule":"MassSMS,OutboundOrder"}]',presence=0 where deploy_type=21;
delimiter;

insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'zh','ld_system_deploy',24,24,'{$ServiceContracts.ServiceContracts}中产品服务到期前N天提醒（为0表示当天提醒，为空表示不提醒）'
from dual where not exists (select * from ld_tranlabel where languagetype='zh' and trantable='ld_system_deploy' and relateid=24);
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'en','ld_system_deploy',24,24,'Products service reminder about the servicecontracts （if 0 remind on the same day, if null don’t remind）'
from dual where not exists (select * from ld_tranlabel where languagetype='en' and trantable='ld_system_deploy' and relateid=24);
delete from ld_desk where labelbol='REMINDSERVICECONTRACTSDEADLINE';
update ld_systems_deploy set roottype='3',inputtype='text',inputvalue='[{"relatedmodule":"Reminds,ServiceContracts"}]',presence=0 where deploy_type=24;
delimiter;

insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'zh','ld_system_deploy',40,40,'{$PaymentPlan.PaymentPlan}到期前N天提醒（为0表示当天提醒，为空表示不提醒）'
from dual where not exists (select * from ld_tranlabel where languagetype='zh' and trantable='ld_system_deploy' and relateid=40);
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'en','ld_system_deploy',40,40,'N days before the payment plan expired（if 0 remind on the same day, if null don’t remind）'
from dual where not exists (select * from ld_tranlabel where languagetype='en' and trantable='ld_system_deploy' and relateid=40);
delete from ld_desk where labelbol='PAYMENTPLAYREMINDS';
update ld_systems_deploy set roottype='3',inputtype='text',inputvalue='[{"relatedmodule":"Reminds,PaymentPlan,SalesOrder"}]',presence=0 where deploy_type=40;
delimiter;

insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'zh','ld_system_deploy',41,41,'{$SendPayment.SendPayment}到期前N天提醒（为0表示当天提醒，为空表示不提醒）'
from dual where not exists (select * from ld_tranlabel where languagetype='zh' and trantable='ld_system_deploy' and relateid=41);
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'en','ld_system_deploy',41,41,'{$SendPayment.SendPayment} N days before the payment plan expired（if 0 remind on the same day, if null don’t remind）'
from dual where not exists (select * from ld_tranlabel where languagetype='en' and trantable='ld_system_deploy' and relateid=41);
update ld_systems_deploy set roottype='3',inputtype='text',inputvalue='[{"relatedmodule":"Reminds,SendPayment"}]',presence=0 where deploy_type=41;
delimiter;

insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'zh','ld_system_deploy',51,51,'未读提醒是否弹框提示'
from dual where not exists (select * from ld_tranlabel where languagetype='zh' and trantable='ld_system_deploy' and relateid=51);
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'en','ld_system_deploy',51,51,'Wether need dialog box to notice the unread reminds'
from dual where not exists (select * from ld_tranlabel where languagetype='en' and trantable='ld_system_deploy' and relateid=51);
delete from ld_desk where labelbol='Wether_need_dialog_box_notice_unread_reminds';
update ld_systems_deploy set roottype='3',inputtype='select',inputvalue='[{"value":"1","text":"YES"},{"value":"2","text":"NO"},{"sql":""},{"relatedmodule":"Reminds"}]',presence=0 where deploy_type=51;
delimiter;

insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'zh','ld_system_deploy',53,53,'{$PaymentPlan.PaymentPlan}按照{$Project.Project}状态收款和提醒'
from dual where not exists (select * from ld_tranlabel where languagetype='zh' and trantable='ld_system_deploy' and relateid=53);
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'en','ld_system_deploy',53,53,'{$PaymentPlan.PaymentPlan} according to {$Project.Project} status to remind and get cash'
from dual where not exists (select * from ld_tranlabel where languagetype='en' and trantable='ld_system_deploy' and relateid=53);
delete from ld_desk where labelbol='PaymentPlanaccordingtoProjectstatustoremindandgetcash';
update ld_systems_deploy set roottype='3',inputtype='select',inputvalue='[{"value":"1","text":"YES"},{"value":"2","text":"NO"},{"sql":""},{"relatedmodule":"PaymentPlan,Project"}]',presence=0 where deploy_type=53;
delimiter;

insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'zh','ld_system_deploy',62,62,'当{$Potentials.Potentials}负责人变更时是否发送短信通知新的负责人'
from dual where not exists (select * from ld_tranlabel where languagetype='zh' and trantable='ld_system_deploy' and relateid=62);
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'en','ld_system_deploy',62,62,'When the {$Potentials.Potentials} head is changing,whether to send text messages to inform the new person in charge'
from dual where not exists (select * from ld_tranlabel where languagetype='en' and trantable='ld_system_deploy' and relateid=62);
delete from ld_desk where labelbol='NOTIFYPOTENTIALASSIGNED';
update ld_systems_deploy set roottype='3',inputtype='select',inputvalue='[{"value":"1","text":"YES"},{"value":"0","text":"NO"},{"sql":""},{"relatedmodule":"Potentials,MassSMS"}]',presence=0 where deploy_type=62;
delimiter;

insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'zh','ld_system_deploy',95,95,'客户重复是否弹出对冲提醒'
from dual where not exists (select * from ld_tranlabel where languagetype='zh' and trantable='ld_system_deploy' and relateid=95);
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'en','ld_system_deploy',95,95,'Whether to send reminders when customer repeat'
from dual where not exists (select * from ld_tranlabel where languagetype='en' and trantable='ld_system_deploy' and relateid=95);
delete from ld_desk where labelbol='REPEATCUSTOMERSREMIND';
update ld_systems_deploy set roottype='3',inputtype='select',inputvalue='[{"value":"0","text":"YES"},{"value":"1","text":"NO"},{"sql":""},{"relatedmodule":"Reminds,Accounts"}]',presence=0 where deploy_type=95;
delimiter;

insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'zh','ld_system_deploy',79,79,'订单中产品单价自动根据客户最近购买记录带出'
from dual where not exists (select * from ld_tranlabel where languagetype='zh' and trantable='ld_system_deploy' and relateid=79);
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'en','ld_system_deploy',79,79,'Whether the products unit price in the orders is automatically brought out according to the customers recent buy history'
from dual where not exists (select * from ld_tranlabel where languagetype='en' and trantable='ld_system_deploy' and relateid=79);
delete from ld_desk where labelbol='WHETHERPRODUCTSPRICEBROUGHTOUTACCORDINGTOCUSTOMERBUYHISTORY';
update ld_systems_deploy set roottype='4',inputtype='select',inputvalue='[{"value":"0","text":"YES"},{"value":"1","text":"NO"},{"sql":""},{"relatedmodule":"SalesOrder,Products"}]',presence=0 where deploy_type=79;
delimiter;

insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'zh','ld_system_deploy',82,82,'单据分录中调用产品资料时是否显示无效的产品'
from dual where not exists (select * from ld_tranlabel where languagetype='zh' and trantable='ld_system_deploy' and relateid=82);
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'en','ld_system_deploy',82,82,'Is allowed to select invalid products in orders, invoices and other module products list'
from dual where not exists (select * from ld_tranlabel where languagetype='en' and trantable='ld_system_deploy' and relateid=82);
delete from ld_desk where labelbol='AllowedSelectProductsOrdersOtherModuleProducts';
update ld_systems_deploy set roottype='4',inputtype='select',inputvalue='[{"value":"1","text":"YES"},{"value":"0","text":"NO"},{"sql":""}]',presence=0 where deploy_type=82;
delimiter;

insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'zh','ld_system_deploy',83,83,'已收金额计算时是否统计未审核的{$CashBill.CashBill}'
from dual where not exists (select * from ld_tranlabel where languagetype='zh' and trantable='ld_system_deploy' and relateid=83);
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'en','ld_system_deploy',83,83,'Whether the received amount calculates the non checked {$CashBill.CashBill}'
from dual where not exists (select * from ld_tranlabel where languagetype='en' and trantable='ld_system_deploy' and relateid=83);
delete from ld_desk where labelbol='Whetherreceivedamountcalculatesnoncheckedcashbills';
update ld_systems_deploy set roottype='4',inputtype='select',inputvalue='[{"value":"0","text":"YES"},{"value":"1","text":"NO"},{"sql":""}]',presence=0 where deploy_type=83;
delimiter;

insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'zh','ld_system_deploy',84,84,'已付金额计算时是否统计未审核的{$SendCashBill.SendCashBill}'
from dual where not exists (select * from ld_tranlabel where languagetype='zh' and trantable='ld_system_deploy' and relateid=84);
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'en','ld_system_deploy',84,84,'Whether the amount paid the non checked send {$SendCashBill.SendCashBill}'
from dual where not exists (select * from ld_tranlabel where languagetype='en' and trantable='ld_system_deploy' and relateid=84);
delete from ld_desk where labelbol='Whetherreceivedamountcalculatesnoncheckedsendcashbills';
update ld_systems_deploy set roottype='4',inputtype='select',inputvalue='[{"value":"0","text":"YES"},{"value":"1","text":"NO"},{"sql":""}]',presence=0 where deploy_type=84;
delimiter;

insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'zh','ld_system_deploy',85,85,'未出库订单是否允许退货'
from dual where not exists (select * from ld_tranlabel where languagetype='zh' and trantable='ld_system_deploy' and relateid=85);
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'en','ld_system_deploy',85,85,'Do not allowed to return the in storaged salesorder'
from dual where not exists (select * from ld_tranlabel where languagetype='en' and trantable='ld_system_deploy' and relateid=85);
delete from ld_desk where labelbol='Directreturnofcontract';
update ld_systems_deploy set roottype='4',inputtype='select',inputvalue='[{"value":"1","text":"YES"},{"value":"0","text":"NO"},{"sql":""}]',presence=0 where deploy_type=85;
delimiter;

insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'zh','ld_system_deploy',92,92,'订单同步接口触发点'
from dual where not exists (select * from ld_tranlabel where languagetype='zh' and trantable='ld_system_deploy' and relateid=92);
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'en','ld_system_deploy',92,92,'The trigger point of the data interface about sales orders'
from dual where not exists (select * from ld_tranlabel where languagetype='en' and trantable='ld_system_deploy' and relateid=92);
delete from ld_desk where labelbol='The trigger point of the data interface about sales orders';
update ld_systems_deploy set roottype='4',inputtype='select',inputvalue='[{"value":"0","text":"SAVE"},{"value":"1","text":"Approvals"},{"sql":""}]',presence=0 where deploy_type=92;
delimiter;

insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'zh','ld_system_deploy',16,16,'{$Accounts.Accounts}资料审批完成后是否允许进行编辑'
from dual where not exists (select * from ld_tranlabel where languagetype='zh' and trantable='ld_system_deploy' and relateid=16);
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'en','ld_system_deploy',16,16,'{$Accounts.Accounts} whether to allow for editing data after approval'
from dual where not exists (select * from ld_tranlabel where languagetype='en' and trantable='ld_system_deploy' and relateid=16);
delete from ld_desk where labelbol='WHETHEREDITAFTERAPPROVAL';
update ld_systems_deploy set roottype='2',inputtype='select',inputvalue='[{"value":"0","text":"YES"},{"value":"1","text":"NO"},{"sql":""},{"relatedmodule":"Accounts"}]',presence=0 where deploy_type=16;
delimiter;

insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'zh','ld_system_deploy',71,71,'调用产品时只能选择已审批的产品'
from dual where not exists (select * from ld_tranlabel where languagetype='zh' and trantable='ld_system_deploy' and relateid=71);
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'en','ld_system_deploy',71,71,'Only then approved products can be choosed'
from dual where not exists (select * from ld_tranlabel where languagetype='en' and trantable='ld_system_deploy' and relateid=71);
delete from ld_desk where labelbol='OTAPCBC';
update ld_systems_deploy set roottype='2',inputtype='select',inputvalue='[{"value":"0","text":"YES"},{"value":"1","text":"NO"},{"sql":""},{"relatedmodule":"Products"}]',presence=0 where deploy_type=71;
delimiter;

update ld_systems_deploy set roottype='2',inputtype='select',inputvalue='[{"value":"0","text":"YES"},{"value":"1","text":"NO"},{"sql":""}]',presence=0 where deploy_type in(3,4,5,6,8,9,11,17,22,23,27,28,29,30,31,36,47,70,94,96,97);
delimiter;

update ld_systems_deploy set presence=1 where roottype is null;
delimiter;

select usereportid into @usereportid from ld_usereport where name = 'AttendanceReport';
select tabids into @tabids from ld_usereport where name = 'AttendanceReport'; 
select max(sequence) into @sequence from ld_usereport where Parent_id = @usereportid and tabids = @tabids ;
insert into ld_usereport(name,reportlabel,tabids,Parent_id,sequence,reporttype,pagewidthpercent) 
select 'TimeSheet personal monthly summary','TimeSheet个人月汇总表',@tabids,@usereportid,@sequence+1,'',100  from dual 
where not EXISTS(select 1 from ld_usereport  where name ='TimeSheet personal monthly summary');
delimiter;
insert into ld_desk(languagetype,labelbol,fieldlabel,Labeltype)
select 'en','TimeSheet personal monthly summary','{$TimeSheet.TimeSheet} personal monthly summary','fixedstr' from dual 
where not EXISTS(select 1 from ld_desk where languagetype = 'en' and labelbol = 'TimeSheet personal monthly summary' );
insert into ld_desk(languagetype,labelbol,fieldlabel,Labeltype)
select 'zh','TimeSheet personal monthly summary','{$TimeSheet.TimeSheet}个人月汇总表','fixedstr' from dual 
where not EXISTS(select 1 from ld_desk where languagetype = 'zh' and labelbol = 'TimeSheet personal monthly summary' );
delimiter;
insert into ld_desk(languagetype,labelbol,fieldlabel,Labeltype)
select 'en','Employee Name','Employee Name','fixedstr' from dual 
where not EXISTS(select 1 from ld_desk where languagetype = 'en' and labelbol = 'Employee Name' );
insert into ld_desk(languagetype,labelbol,fieldlabel,Labeltype)
select 'zh','Employee Name','员工姓名','fixedstr' from dual 
where not EXISTS(select 1 from ld_desk where languagetype = 'zh' and labelbol = 'Employee Name' );
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,Labeltype)
  select 'zh','TIPSFORSETDIDIDNEDRULES','该产品还未设置派息规则，是否立即设置？','fixedstr' from dual
  where not exists(select 1 from ld_desk where labelbol='TIPSFORSETDIDIDNEDRULES' and languagetype='zh');

insert into ld_desk(languagetype,labelbol,fieldlabel,Labeltype)
  select 'en','TIPSFORSETDIDIDNEDRULES','Whether the product has not yet set dividend rules, set up immediately?','fixedstr' from dual
  where not exists(select 1 from ld_desk where labelbol='TIPSFORSETDIDIDNEDRULES' and languagetype='en');

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','STARTDATENOTCREATEDIVIDENDORDER','{$SalesOrder.start_date}未启用，无法创建{$DividendOrder.DividendOrder}!','fixedstr' from DUAL
where not EXISTS(select 1 from ld_desk where labelbol='STARTDATENOTCREATEDIVIDENDORDER' and languagetype='zh' and labeltype='fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','STARTDATENOTCREATEDIVIDENDORDER','The starting date of interest is not enabled, unable to create a single dividend!','fixedstr' from DUAL
where not EXISTS(select 1 from ld_desk where labelbol='STARTDATENOTCREATEDIVIDENDORDER' and languagetype='en' and labeltype='fixedstr');

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','STARTDATEEMPTYNOTCREATEDIVIDENDORDER','{$SalesOrder.start_date}为空值，无法创建{$DividendOrder.DividendOrder}!','fixedstr' from DUAL
where not EXISTS(select 1 from ld_desk where labelbol='STARTDATEEMPTYNOTCREATEDIVIDENDORDER' and languagetype='zh' and labeltype='fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','STARTDATEEMPTYNOTCREATEDIVIDENDORDER','The starting date of interest to a null value, cannot create a single dividend！','fixedstr' from DUAL
where not EXISTS(select 1 from ld_desk where labelbol='STARTDATEEMPTYNOTCREATEDIVIDENDORDER' and languagetype='en' and labeltype='fixedstr');

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','ENDDATENOTCREATEDIVIDENDORDER','{$SalesOrder.end_date}未启用，无法创建{$DividendOrder.DividendOrder}!','fixedstr' from DUAL
where not EXISTS(select 1 from ld_desk where labelbol='ENDDATENOTCREATEDIVIDENDORDER' and languagetype='zh' and labeltype='fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','ENDDATENOTCREATEDIVIDENDORDER','The principal and the dividend return date is not enabled, unable to create a single dividend！','fixedstr' from DUAL
where not EXISTS(select 1 from ld_desk where labelbol='ENDDATENOTCREATEDIVIDENDORDER' and languagetype='en' and labeltype='fixedstr');

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','ENDDATEEMPTYNOTCREATEDIVIDENDORDER','{$SalesOrder.end_date}未空值，无法创建{$DividendOrder.DividendOrder}!','fixedstr' from DUAL
where not EXISTS(select 1 from ld_desk where labelbol='ENDDATEEMPTYNOTCREATEDIVIDENDORDER' and languagetype='zh' and labeltype='fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','ENDDATEEMPTYNOTCREATEDIVIDENDORDER','The principal and dividend return date to a null value, cannot create a single dividend!','fixedstr' from DUAL
where not EXISTS(select 1 from ld_desk where labelbol='ENDDATEEMPTYNOTCREATEDIVIDENDORDER' and languagetype='en' and labeltype='fixedstr');

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','FIXEDRATENOTCREATEDIVIDENDORDER','{$SalesOrder.fixed_rate}未启用，无法创建{$DividendOrder.DividendOrder}!','fixedstr' from DUAL
where not EXISTS(select 1 from ld_desk where labelbol='FIXEDRATENOTCREATEDIVIDENDORDER' and languagetype='zh' and labeltype='fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','FIXEDRATENOTCREATEDIVIDENDORDER','A fixed annual rate of return is not enabled, unable to create a single dividend!','fixedstr' from DUAL
where not EXISTS(select 1 from ld_desk where labelbol='FIXEDRATENOTCREATEDIVIDENDORDER' and languagetype='en' and labeltype='fixedstr');

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','FIXEDRATEEMPTYNOTCREATEDIVIDENDORDER','{$SalesOrder.fixed_rate}未空值，无法创建{$DividendOrder.DividendOrder}!','fixedstr' from DUAL
where not EXISTS(select 1 from ld_desk where labelbol='FIXEDRATEEMPTYNOTCREATEDIVIDENDORDER' and languagetype='zh' and labeltype='fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','FIXEDRATEEMPTYNOTCREATEDIVIDENDORDER','A fixed annual yield of less than or equal to 0, unable to create a single dividend!','fixedstr' from DUAL
where not EXISTS(select 1 from ld_desk where labelbol='FIXEDRATEEMPTYNOTCREATEDIVIDENDORDER' and languagetype='en' and labeltype='fixedstr');


insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','DIVIDENDMONEYCHANGESAVE','派息金额有变动，请重新保存!','fixedstr' from DUAL
where not EXISTS(select 1 from ld_desk where labelbol='DIVIDENDMONEYCHANGESAVE' and languagetype='zh' and labeltype='fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','DIVIDENDMONEYCHANGESAVE','Changes in dividend payments, please save it again!','fixedstr' from DUAL
where not EXISTS(select 1 from ld_desk where labelbol='DIVIDENDMONEYCHANGESAVE' and languagetype='en' and labeltype='fixedstr');

delimiter;
update ld_field set uitype=1 where tabid=37 and columnname='priority';
delimiter;
-- 2016-04-25

set @usereportid=0;
select usereportid into @usereportid from ld_usereport where `name`='TimeSheet personal monthly summary';
delete from ld_usereport where usereportid=@usereportid;
delimiter;

DELETE FROM ld_dividend_rules_formulas;
insert into ld_desk(languagetype,labelbol,fieldlabel,Labeltype)
  select 'zh','ACTUALDAYSOFMONTH','当月实际天数','fixedstr' from dual
  where not exists(select 1 from ld_desk where labelbol='ACTUALDAYSOFMONTH' and languagetype='zh');
insert into ld_desk(languagetype,labelbol,fieldlabel,Labeltype)
  select 'en','ACTUALDAYSOFMONTH','ActualDaysOfMonth','fixedstr' from dual
  where not exists(select 1 from ld_desk where labelbol='ACTUALDAYSOFMONTH' and languagetype='en');
insert into ld_desk(languagetype,labelbol,fieldlabel,Labeltype)
  select 'zh','FULLMONTH30','满月按30','fixedstr' from dual
  where not exists(select 1 from ld_desk where labelbol='FULLMONTH30' and languagetype='zh');
insert into ld_desk(languagetype,labelbol,fieldlabel,Labeltype)
  select 'en','FULLMONTH30','FullMonth30','fixedstr' from dual
  where not exists(select 1 from ld_desk where labelbol='FULLMONTH30' and languagetype='en');
insert into ld_dividend_rules_formulas(formulamode,formulas,`describe`)
  select 'monthly','Capital*Rate*FullMonth30/360','{本金}*{固定年化收益率}*{计息天数:满月按30}/360' from dual
  where not exists(select 1 from ld_dividend_rules_formulas where formulamode='monthly' and formulas='Capital*Rate*FullMonth30/360');
insert into ld_dividend_rules_formulas(formulamode,formulas,`describe`)
  select 'monthly','Capital*Rate*Days/12/AcMonth','{本金}*{固定年化收益率}*{计息天数}/12/{当月实际天数}' from dual
  where not exists(select 1 from ld_dividend_rules_formulas where formulamode='monthly' and formulas='Capital*Rate*Days/12/AcMonth');
insert into ld_dividend_rules_formulas(formulamode,formulas,`describe`)
  select 'semiannual','Capital*Rate/2','{本金}*{固定年化收益率}/2' from dual
  where not exists(select 1 from ld_dividend_rules_formulas where formulamode='semiannual' and formulas='Capital*Rate/2');
insert into ld_dividend_rules_formulas(formulamode,formulas,`describe`)
  select 'oneoff','Capital*Rate','{本金}*{固定年化收益率}' from dual
  where not exists(select 1 from ld_dividend_rules_formulas where formulamode='oneoff' and formulas='C*R');
insert into ld_dividend_rules_formulas(formulamode,formulas,`describe`)
  select 'monthly','Capital*Rate*Days/360','{本金}*{固定年化收益率}*{计息天数}/360' from dual
  where not exists(select 1 from ld_dividend_rules_formulas where formulamode='monthly' and formulas='Capital*Rate*Days/360');
insert into ld_dividend_rules_formulas(formulamode,formulas,`describe`)
  select 'monthly','Capital*Rate*Days/365','{本金}*{固定年化收益率}*{计息天数}/365' from dual
  where not exists(select 1 from ld_dividend_rules_formulas where formulamode='monthly' and formulas='Capital*Rate*Days/365');
insert into ld_dividend_rules_formulas(formulamode,formulas,`describe`)
  select 'quarterly','Capital*Rate/4','{本金}*{固定年化收益率}/4' from dual
  where not exists(select 1 from ld_dividend_rules_formulas where formulamode='quarterly' and formulas='Capital*Rate/4');
insert into ld_dividend_rules_formulas(formulamode,formulas,`describe`)
  select 'quarterly','Capital*Rate*Days/360','{本金}*{固定年化收益率}*{计息天数}/360' from dual
  where not exists(select 1 from ld_dividend_rules_formulas where formulamode='quarterly' and formulas='Capital*Rate*Days/360');
insert into ld_dividend_rules_formulas(formulamode,formulas,`describe`)
  select 'quarterly','Capital*Rate*Days/365','{本金}*{固定年化收益率}*{计息天数}/365' from dual
  where not exists(select 1 from ld_dividend_rules_formulas where formulamode='quarterly' and formulas='Capital*Rate*Days/365');
insert into ld_dividend_rules_formulas(formulamode,formulas,`describe`)
  select 'semiannual','Capital*Rate*Days/360','{本金}*{固定年化收益率}*{计息天数}/360' from dual
  where not exists(select 1 from ld_dividend_rules_formulas where formulamode='semiannual' and formulas='Capital*Rate*Days/360');
insert into ld_dividend_rules_formulas(formulamode,formulas,`describe`)
  select 'semiannual','Capital*Rate*Days/365','{本金}*{固定年化收益率}*{计息天数}/365' from dual
  where not exists(select 1 from ld_dividend_rules_formulas where formulamode='semiannual' and formulas='Capital*Rate*Days/365');
insert into ld_dividend_rules_formulas(formulamode,formulas,`describe`)
  select 'oneoff','Capital*Rate*Days/360','{本金}*{固定年化收益率}*{计息天数}/360' from dual
  where not exists(select 1 from ld_dividend_rules_formulas where formulamode='oneoff' and formulas='Capital*Rate*Days/360');
insert into ld_dividend_rules_formulas(formulamode,formulas,`describe`)
  select 'oneoff','Capital*Rate*Days/365','{本金}*{固定年化收益率}*{计息天数}/365' from dual
  where not exists(select 1 from ld_dividend_rules_formulas where formulamode='oneoff' and formulas='Capital*Rate*Days/365');
insert into ld_dividend_rules_formulas(formulamode,formulas,`describe`)
  select 'designated','Capital*Rate*Days/360','{本金}*{固定年化收益率}*{计息天数}/360' from dual
  where not exists(select 1 from ld_dividend_rules_formulas where formulamode='designated' and formulas='Capital*Rate*Days/360');
insert into ld_dividend_rules_formulas(formulamode,formulas,`describe`)
  select 'designated','Capital*Rate*Days/365','{本金}*{固定年化收益率}*{计息天数}/365' from dual
  where not exists(select 1 from ld_dividend_rules_formulas where formulamode='designated' and formulas='Capital*Rate*Days/365');
insert into ld_desk(languagetype,labelbol,fieldlabel,Labeltype)
  select 'zh','TIPSFORSETDIDIDNEDRULES','该产品还未设置派息规则，是否立即设置？','fixedstr' from dual
  where not exists(select 1 from ld_desk where labelbol='TIPSFORSETDIDIDNEDRULES' and languagetype='zh');
insert into ld_desk(languagetype,labelbol,fieldlabel,Labeltype)
  select 'en','TIPSFORSETDIDIDNEDRULES','Whether the product has not yet set dividend rules, set up immediately?','fixedstr' from dual
  where not exists(select 1 from ld_desk where labelbol='TIPSFORSETDIDIDNEDRULES' and languagetype='en');
insert into ld_desk(languagetype,labelbol,fieldlabel,Labeltype)
  select 'zh','TIPSFORENTRYRATE','录入10表示10%','fixedstr' from dual
  where not exists(select 1 from ld_desk where labelbol='TIPSFORENTRYRATE' and languagetype='zh');
insert into ld_desk(languagetype,labelbol,fieldlabel,Labeltype)
  select 'en','TIPSFORENTRYRATE','Entry 10 said 10%','fixedstr' from dual
  where not exists(select 1 from ld_desk where labelbol='TIPSFORENTRYRATE' and languagetype='en');
insert into ld_desk(languagetype,labelbol,fieldlabel,Labeltype)
  select 'zh','REMINDFORUNLEGALCON','请录入格式合法的内容','jspop' from dual
  where not exists(select 1 from ld_desk where labelbol='REMINDFORUNLEGALCON' and languagetype='zh');
insert into ld_desk(languagetype,labelbol,fieldlabel,Labeltype)
  select 'en','REMINDFORUNLEGALCON','Please enter the legal content','jspop' from dual
  where not exists(select 1 from ld_desk where labelbol='REMINDFORUNLEGALCON' and languagetype='en');
insert into ld_desk(languagetype,labelbol,fieldlabel,Labeltype)
  select 'zh','DIVIDENDGRANTOFFONE','最晚的{合同订单}-{本金及红利返还日期}','fixedstr' from dual
  where not exists(select 1 from ld_desk where labelbol='DIVIDENDGRANTOFFONE' and languagetype='zh');
insert into ld_desk(languagetype,labelbol,fieldlabel,Labeltype)
  select 'en','DIVIDENDGRANTOFFONE','Latest{salesorder}-{The capital and the dividend return date}','fixedstr' from dual
  where not exists(select 1 from ld_desk where labelbol='DIVIDENDGRANTOFFONE' and languagetype='en');
insert into ld_desk(languagetype,labelbol,fieldlabel,Labeltype)
  select 'zh','DIVIDENDGRANTOFFTWO','{合同订单}-{本金及红利返还日期}','fixedstr' from dual
  where not exists(select 1 from ld_desk where labelbol='DIVIDENDGRANTOFFTWO' and languagetype='zh');
insert into ld_desk(languagetype,labelbol,fieldlabel,Labeltype)
  select 'en','DIVIDENDGRANTOFFTWO','{salesorder}-{The capital and the dividend return date}','fixedstr' from dual
  where not exists(select 1 from ld_desk where labelbol='DIVIDENDGRANTOFFTWO' and languagetype='en');
insert into ld_desk(languagetype,labelbol,fieldlabel,Labeltype)
  select 'zh','DATETHISMONTH','当月指定的日期','fixedstr' from dual
  where not exists(select 1 from ld_desk where labelbol='DATETHISMONTH' and languagetype='zh');
insert into ld_desk(languagetype,labelbol,fieldlabel,Labeltype)
  select 'en','DATETHISMONTH','The specified date this month','fixedstr' from dual
  where not exists(select 1 from ld_desk where labelbol='DATETHISMONTH' and languagetype='en');
insert into ld_desk(languagetype,labelbol,fieldlabel,Labeltype)
  select 'zh','DATENEXTMONTH','下月指定的日期','fixedstr' from dual
  where not exists(select 1 from ld_desk where labelbol='DATENEXTMONTH' and languagetype='zh');
insert into ld_desk(languagetype,labelbol,fieldlabel,Labeltype)
  select 'en','DATENEXTMONTH','The specified date next month','fixedstr' from dual
  where not exists(select 1 from ld_desk where labelbol='DATENEXTMONTH' and languagetype='en');
insert into ld_desk(languagetype,labelbol,fieldlabel,Labeltype)
  select 'zh','ENDOFMONTH','月末','fixedstr' from dual
  where not exists(select 1 from ld_desk where labelbol='ENDOFMONTH' and languagetype='zh');
insert into ld_desk(languagetype,labelbol,fieldlabel,Labeltype)
  select 'en','ENDOFMONTH','End of month','fixedstr' from dual
  where not exists(select 1 from ld_desk where labelbol='ENDOFMONTH' and languagetype='en');
insert into ld_desk(languagetype,labelbol,fieldlabel,Labeltype)
  select 'zh','DIVIDENDFIXEDRATEONE','相关{合同订单}-{固定年化收益率}','fixedstr' from dual
  where not exists(select 1 from ld_desk where labelbol='DIVIDENDFIXEDRATEONE' and languagetype='zh');
insert into ld_desk(languagetype,labelbol,fieldlabel,Labeltype)
  select 'en','DIVIDENDFIXEDRATEONE','The fixed-income rate of the related contract','fixedstr' from dual
  where not exists(select 1 from ld_desk where labelbol='DIVIDENDFIXEDRATEONE' and languagetype='en');
insert into ld_desk(languagetype,labelbol,fieldlabel,Labeltype)
  select 'zh','DIVIDENDFIXEDRATETWO','{合同订单}-{固定年化收益率}','fixedstr' from dual
  where not exists(select 1 from ld_desk where labelbol='DIVIDENDFIXEDRATETWO' and languagetype='zh');
insert into ld_desk(languagetype,labelbol,fieldlabel,Labeltype)
  select 'en','DIVIDENDFIXEDRATETWO','The fixed-income rate of the contract','fixedstr' from dual
  where not exists(select 1 from ld_desk where labelbol='DIVIDENDFIXEDRATETWO' and languagetype='en');
insert into ld_desk(languagetype,labelbol,fieldlabel,Labeltype)
    select 'zh','DIVIDENDRULES','派息规则','fixedstr' from dual
  where not exists(select 1 from ld_desk where labelbol='DIVIDENDRULES' and languagetype='zh');
insert into ld_desk(languagetype,labelbol,fieldlabel,Labeltype)
  select 'en','DIVIDENDRULES','Dividend Rules','fixedstr' from dual
  where not exists(select 1 from ld_desk where labelbol='DIVIDENDRULES' and languagetype='en');
insert into ld_desk(languagetype,labelbol,fieldlabel,Labeltype)
  select 'zh','FORMULACAPITAL','本金计算方法','fixedstr' from dual
  where not exists(select 1 from ld_desk where labelbol='FORMULACAPITAL' and languagetype='zh');
insert into ld_desk(languagetype,labelbol,fieldlabel,Labeltype)
  select 'en','FORMULACAPITAL','Investment Amount','fixedstr' from dual
  where not exists(select 1 from ld_desk where labelbol='FORMULACAPITAL' and languagetype='en');
insert into ld_desk(languagetype,labelbol,fieldlabel,Labeltype)
  select 'zh','FORMULATOTAL','按认购金额计算','fixedstr' from dual
  where not exists(select 1 from ld_desk where labelbol='FORMULATOTAL' and languagetype='zh');
insert into ld_desk(languagetype,labelbol,fieldlabel,Labeltype)
  select 'en','FORMULATOTAL','Total Subscription Amount','fixedstr' from dual
  where not exists(select 1 from ld_desk where labelbol='FORMULATOTAL' and languagetype='en');
insert into ld_desk(languagetype,labelbol,fieldlabel,Labeltype)
  select 'zh','FORMULAEVERYCONTRACT','按合同订单计算','fixedstr' from dual
  where not exists(select 1 from ld_desk where labelbol='FORMULAEVERYCONTRACT' and languagetype='zh');
insert into ld_desk(languagetype,labelbol,fieldlabel,Labeltype)
  select 'en','FORMULAEVERYCONTRACT','Every Contract Amount','fixedstr' from dual
  where not exists(select 1 from ld_desk where labelbol='FORMULAEVERYCONTRACT' and languagetype='en');
insert into ld_desk(languagetype,labelbol,fieldlabel,Labeltype)
  select 'zh','FORMULAMODE','利息计算方式','fixedstr' from dual
  where not exists(select 1 from ld_desk where labelbol='FORMULAMODE' and languagetype='zh');
insert into ld_desk(languagetype,labelbol,fieldlabel,Labeltype)
  select 'en','FORMULAMODE','Interest Calculation','fixedstr' from dual
  where not exists(select 1 from ld_desk where labelbol='FORMULAMODE' and languagetype='en');
insert into ld_desk(languagetype,labelbol,fieldlabel,Labeltype)
  select 'zh','FORMULASTART','计息起始日','fixedstr' from dual
  where not exists(select 1 from ld_desk where labelbol='FORMULASTART' and languagetype='zh');
insert into ld_desk(languagetype,labelbol,fieldlabel,Labeltype)
  select 'en','FORMULASTART','Start Date','fixedstr' from dual
  where not exists(select 1 from ld_desk where labelbol='FORMULASTART' and languagetype='en');
insert into ld_desk(languagetype,labelbol,fieldlabel,Labeltype)
  select 'zh','FORMULADEADLINE','月结算截止日','fixedstr' from dual
  where not exists(select 1 from ld_desk where labelbol='FORMULADEADLINE' and languagetype='zh');
insert into ld_desk(languagetype,labelbol,fieldlabel,Labeltype)
  select 'en','FORMULADEADLINE','Monthly Closing Date','fixedstr' from dual
  where not exists(select 1 from ld_desk where labelbol='FORMULADEADLINE' and languagetype='en');
insert into ld_desk(languagetype,labelbol,fieldlabel,Labeltype)
  select 'zh','FORMULAFLOATINCOME','计算浮动收益','fixedstr' from dual
  where not exists(select 1 from ld_desk where labelbol='FORMULAFLOATINCOME' and languagetype='zh');
insert into ld_desk(languagetype,labelbol,fieldlabel,Labeltype)
  select 'en','FORMULAFLOATINCOME','Whether to calculate the floating income','fixedstr' from dual
  where not exists(select 1 from ld_desk where labelbol='FORMULAFLOATINCOME' and languagetype='en');
insert into ld_desk(languagetype,labelbol,fieldlabel,Labeltype)
  select 'zh','FORMULAINCOMERATE','收益率(%)','fixedstr' from dual
  where not exists(select 1 from ld_desk where labelbol='FORMULAINCOMERATE' and languagetype='zh');
insert into ld_desk(languagetype,labelbol,fieldlabel,Labeltype)
  select 'en','FORMULAINCOMERATE','Income Rate','fixedstr' from dual
  where not exists(select 1 from ld_desk where labelbol='FORMULAINCOMERATE' and languagetype='en');
insert into ld_desk(languagetype,labelbol,fieldlabel,Labeltype)
  select 'zh','FIXEDINCOMERATE','固定年化收益率','fixedstr' from dual
  where not exists(select 1 from ld_desk where labelbol='FIXEDINCOMERATE' and languagetype='zh');
insert into ld_desk(languagetype,labelbol,fieldlabel,Labeltype)
  select 'en','FIXEDINCOMERATE','Fixed-Income Rate','fixedstr' from dual
  where not exists(select 1 from ld_desk where labelbol='FIXEDINCOMERATE' and languagetype='en');
insert into ld_desk(languagetype,labelbol,fieldlabel,Labeltype)
  select 'zh','STARTDATETYPEONE','首次购买的{合同订单}-{计息起始日期}','fixedstr' from dual
  where not exists(select 1 from ld_desk where labelbol='STARTDATETYPEONE' and languagetype='zh');
insert into ld_desk(languagetype,labelbol,fieldlabel,Labeltype)
  select 'en','STARTDATETYPEONE','The start date of the first contract','fixedstr' from dual
  where not exists(select 1 from ld_desk where labelbol='STARTDATETYPEONEE' and languagetype='en');
insert into ld_desk(languagetype,labelbol,fieldlabel,Labeltype)
  select 'zh','STARTDATETYPETWO','{合同订单}-{计息起始日期}','fixedstr' from dual
  where not exists(select 1 from ld_desk where labelbol='STARTDATETYPETWO' and languagetype='zh');
insert into ld_desk(languagetype,labelbol,fieldlabel,Labeltype)
  select 'en','STARTDATETYPETWO','The start date of the contract','fixedstr' from dual
  where not exists(select 1 from ld_desk where labelbol='STARTDATETYPETWO' and languagetype='en');
insert into ld_desk(languagetype,labelbol,fieldlabel,Labeltype)
  select 'zh','ENDDATETYPEONE','最晚的{合同订单}-{本金及红利返还日期}','fixedstr' from dual
  where not exists(select 1 from ld_desk where labelbol='ENDDATETYPEONE' and languagetype='zh');
insert into ld_desk(languagetype,labelbol,fieldlabel,Labeltype)
  select 'en','ENDDATETYPEONE','The start date of the first contract','fixedstr' from dual
  where not exists(select 1 from ld_desk where labelbol='ENDDATETYPEONE' and languagetype='en');
insert into ld_desk(languagetype,labelbol,fieldlabel,Labeltype)
  select 'zh','ENDDATETYPETWO','{合同订单}-{本金及红利返还日期}','fixedstr' from dual
  where not exists(select 1 from ld_desk where labelbol='ENDDATETYPETWO' and languagetype='zh');
insert into ld_desk(languagetype,labelbol,fieldlabel,Labeltype)
  select 'en','ENDDATETYPETWO','The start date of the contract','fixedstr' from dual
  where not exists(select 1 from ld_desk where labelbol='ENDDATETYPETWO' and languagetype='en');
insert into ld_desk(languagetype,labelbol,fieldlabel,Labeltype)
  select 'zh','DIVIDENDMONTHLY','按月派息','fixedstr' from dual
  where not exists(select 1 from ld_desk where labelbol='DIVIDENDMONTHLY' and languagetype='zh');
insert into ld_desk(languagetype,labelbol,fieldlabel,Labeltype)
  select 'en','DIVIDENDMONTHLY','Monthly Dividend','fixedstr' from dual
  where not exists(select 1 from ld_desk where labelbol='DIVIDENDMONTHLY' and languagetype='en');
insert into ld_desk(languagetype,labelbol,fieldlabel,Labeltype)
  select 'zh','DIVIDENDQUARTERLY','按季派息','fixedstr' from dual
  where not exists(select 1 from ld_desk where labelbol='DIVIDENDQUARTERLY' and languagetype='zh');
insert into ld_desk(languagetype,labelbol,fieldlabel,Labeltype)
  select 'en','DIVIDENDQUARTERLY','Quarterly Dividend','fixedstr' from dual
  where not exists(select 1 from ld_desk where labelbol='DIVIDENDQUARTERLY' and languagetype='en');
insert into ld_desk(languagetype,labelbol,fieldlabel,Labeltype)
  select 'zh','DIVIDENDSEMIAN','按半年派息','fixedstr' from dual
  where not exists(select 1 from ld_desk where labelbol='DIVIDENDSEMIAN' and languagetype='zh');
insert into ld_desk(languagetype,labelbol,fieldlabel,Labeltype)
  select 'en','DIVIDENDSEMIAN','Semiannual Dividend','fixedstr' from dual
  where not exists(select 1 from ld_desk where labelbol='DIVIDENDSEMIAN' and languagetype='en');
insert into ld_desk(languagetype,labelbol,fieldlabel,Labeltype)
  select 'zh','DIVIDENDONEOFF','一次性派息','fixedstr' from dual
  where not exists(select 1 from ld_desk where labelbol='DIVIDENDONEOFF' and languagetype='zh');
insert into ld_desk(languagetype,labelbol,fieldlabel,Labeltype)
  select 'en','DIVIDENDONEOFF','One-Off Dividend','fixedstr' from dual
  where not exists(select 1 from ld_desk where labelbol='DIVIDENDONEOFF' and languagetype='en');
insert into ld_desk(languagetype,labelbol,fieldlabel,Labeltype)
  select 'zh','DIVIDENDDESIGN','指定派息日','fixedstr' from dual
  where not exists(select 1 from ld_desk where labelbol='DIVIDENDDESIGN' and languagetype='zh');
insert into ld_desk(languagetype,labelbol,fieldlabel,Labeltype)
  select 'en','DIVIDENDDESIGN','Designated Dividend','fixedstr' from dual
  where not exists(select 1 from ld_desk where labelbol='DIVIDENDDESIGN' and languagetype='en');
-- 2016-04-26

insert into ld_desk(languagetype,labelbol,fieldlabel,Labeltype)
  select 'zh','TIPSFORASKDIDIDNEDRULES','该产品还未设置派息规则，请联系管理员设置!','fixedstr' from dual
  where not exists(select 1 from ld_desk where labelbol='TIPSFORASKDIDIDNEDRULES' and languagetype='zh');
insert into ld_desk(languagetype,labelbol,fieldlabel,Labeltype)
  select 'en','TIPSFORASKDIDIDNEDRULES','The product has not yet set dividend rules, please contact the administrator!','fixedstr' from dual
  where not exists(select 1 from ld_desk where labelbol='TIPSFORASKDIDIDNEDRULES' and languagetype='en');

update ld_desk set fieldlabel='{$SalesOrder.end_date}为空值，无法创建{$DividendOrder.DividendOrder}!' where labelbol='ENDDATEEMPTYNOTCREATEDIVIDENDORDER' and Labeltype='fixedstr' and languagetype='zh';
update ld_desk set fieldlabel='{$SalesOrder.fixed_rate}为空值，无法创建{$DividendOrder.DividendOrder}!' where labelbol='FIXEDRATEEMPTYNOTCREATEDIVIDENDORDER' and Labeltype='fixedstr' and languagetype='zh';
delimiter;

call AddColumn('ld_workreport','signaddress','varchar','200',NULL);
delimiter;
update ld_workreport set entitytype = 'weibo',signaddress= worksummary where entitytype = 'sign';
delimiter;

insert into ld_dividend_rules_formulas(formulamode,formulas,`describe`)
  select 'oneoff','Capital*Rate*(Days-1)/365','{本金}*{固定年化收益率}*{计息天数-1}/365' from dual
  where not exists(select 1 from ld_dividend_rules_formulas where formulamode='monthly' and formulas='Capital*Rate*(Days-1)/365');
UPDATE ld_desk SET fieldlabel = '按累计投资金额计算' WHERE labelbol='FORMULATOTAL' AND languagetype = 'zh' AND Labeltype='fixedstr';
UPDATE ld_desk SET fieldlabel = 'According to the total investment amount is calculated' WHERE labelbol='FORMULATOTAL' AND languagetype = 'en' AND Labeltype='fixedstr';
-- 2016-04-27


select max(sequence)+1 into @sequence from ld_systems_deploy;
insert into ld_systems_deploy(deploy_value,deploy_type,description,setype,sequence,roottype,inputtype,inputvalue,presence)
select 1,99,'工时管理是否启用审批流程。1:否，0:是','TimeSheet',@sequence,2,'select','[{"value":"0","text":"YES"},{"value":"1","text":"NO"},{"sql":""}]',0
from dual where not EXISTS(select 1 from ld_systems_deploy where deploy_type=99);
delimiter;

select tabid into @tabid from ld_tab where `name` = 'Expense';
update ld_tabdetailfield set typeofdata = 'V~M' where tabid = @tabid and columnname = 'expenseuse' and typeofdata = 'V~O';
update ld_tabdetailfield set defaultcolumn = 3 where tabid = @tabid and columnname in('startdate','enddate','projectid','currency_id','conversion_rate');
delimiter;
-- 2016-04-28

DELETE FROM ld_dividend_rules_formulas WHERE formulas = 'Capital*Rate*(Days-1)/365' AND formulamode = 'oneoff';
insert into ld_dividend_rules_formulas(formulamode,formulas,`describe`)
  select 'oneoff','Capital*Rate*(Days-1)/365','{本金}*{固定年化收益率}*{计息天数-1}/365' from dual
  where not exists(select 1 from ld_dividend_rules_formulas where formulamode='oneoff' and formulas='Capital*Rate*(Days-1)/365');
-- 2016-05-03

update ld_desk set fieldlabel='{$SalesOrder.fixed_rate}为空值或小于等于0，无法创建{$DividendOrder.DividendOrder}!' where labelbol='FIXEDRATEEMPTYNOTCREATEDIVIDENDORDER' and languagetype='zh';
update ld_producttoolfield set width=25 where columnname='listprice' and width<25;

update ld_producttoolfield set input_type=2 where producttoolfieldid in(select producttoolfieldid from ld_producttoolfield_formula);
delimiter;

select tabid into @tabid from ld_tab where name='Campaigns';
update ld_field set displaytype = 2 where tabid = @tabid and uitype in (130,131);
delimiter;

update ld_producttoolfield_formula set formulastring='date_add(a,364,day)',columnstring="{formulavar:[{'lettervar':'a','column':'servicecontracts_start_date'}]}"
where producttoolfieldid in (select producttoolfieldid from ld_producttoolfield where tabid=37 and columnname='servicecontracts_end_date' and formulastring='date_add(a,365,day)');

update ld_desk set fieldlabel='客户和联系人关联字段' where labelbol='LBL_ACCOUNTS_CONTACTS_FIELDS' AND fieldlabel='客户相关信息字段';
delimiter;
update ld_tranlabel set fieldlabel='工时' where fieldlabel='工时管理' AND trantable='ld_tab';
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,Labeltype)
  select 'zh','DIVIDENDOTHERMONTHLY','隔月派息','fixedstr' from dual
  where not exists(select 1 from ld_desk where labelbol='DIVIDENDOTHERMONTHLY' and languagetype='zh');

insert into ld_desk(languagetype,labelbol,fieldlabel,Labeltype)
  select 'en','DIVIDENDOTHERMONTHLY','Every other month','fixedstr' from dual
  where not exists(select 1 from ld_desk where labelbol='DIVIDENDOTHERMONTHLY' and languagetype='en');

insert into ld_dividend_rules_formulas(formulamode,formulas,`describe`)
  select 'othermonth','Capital*Rate/12','{本金}*{固定年化收益率}/12' from dual
  where not exists(select 1 from ld_dividend_rules_formulas where formulamode='othermonth' and formulas='Capital*Rate/12');
-- 2016-05-04

DROP PROCEDURE IF EXISTS `altercolumn`;
delimiter ||
CREATE  PROCEDURE `altercolumn`(
	tablename VARCHAR(50),
	oldcolumnname VARCHAR(100),
	newcolumnname VARCHAR(100),
	newcolumntype VARCHAR(100)
)
BEGIN
	SELECT DATABASE() INTO @tableschema;
	SET tablename=LOWER(tablename);
	SET @colName=0;

	select length(column_name) into @colName from information_schema.columns 
	where TABLE_SCHEMA= @tableschema and table_name=tablename and COLUMN_NAME=oldcolumnname;
	
	IF @colName>0 THEN
		
		SET @altersql=CONCAT(' alter table ',tablename, ' change ',oldcolumnname,' ',newcolumnname,' ',newcolumntype);
		
		PREPARE stalter FROM @altersql;
		EXECUTE stalter;
	END IF;

end ||
delimiter;

call altercolumn('ld_timesheetdetail','project_id','projectid','int(11)');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,Labeltype)
select 'zh','TOOLSFIELDSTEXTAREA','文本区域','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='TOOLSFIELDSTEXTAREA' and languagetype='zh');
insert into ld_desk(languagetype,labelbol,fieldlabel,Labeltype)
select 'en','TOOLSFIELDSTEXTAREA','TextArea','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='TOOLSFIELDSTEXTAREA' and languagetype='en');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,Labeltype)
select 'zh','TOOLSFIELDSSELECTSOURCE','选择源单','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='TOOLSFIELDSSELECTSOURCE' and languagetype='zh');
insert into ld_desk(languagetype,labelbol,fieldlabel,Labeltype)
select 'en','TOOLSFIELDSSELECTSOURCE','SelectSource','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='TOOLSFIELDSSELECTSOURCE' and languagetype='en');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,Labeltype)
select 'zh','TOOLSFIELDSDATESETTING','日期时间设置','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='TOOLSFIELDSDATESETTING' and languagetype='zh');
insert into ld_desk(languagetype,labelbol,fieldlabel,Labeltype)
select 'en','TOOLSFIELDSDATESETTING','DateSetting','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='TOOLSFIELDSDATESETTING' and languagetype='en');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,Labeltype)
select 'zh','TOOLSFIELDSINT','整型','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='TOOLSFIELDSINT' and languagetype='zh');
insert into ld_desk(languagetype,labelbol,fieldlabel,Labeltype)
select 'en','TOOLSFIELDSINT','Int','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='TOOLSFIELDSINT' and languagetype='en');
delimiter;

select tabid into @tabid from ld_tab where name='dividendorder';
select max(fieldid)  into @maxfieldid from ld_field;
select blockid into @blockid from ld_blocks where tabid=@tabid and blocklabel='LBL_DIVIDENDORDER_INFO';
update ld_field_seq set id=@maxfieldid+1 where not EXISTS(select 1 from ld_field where tabid=@tabid  and columnname='adjustment');

insert into  ld_field(tabid,fieldid,columnname,tablename,generatedtype,uitype,fieldname,fieldlabel,readonly,presence,sequence,block,displaytype,typeofdata,quickcreate,quickcreatesequence) 
select @tabid,@maxfieldid+1,'adjustment','ld_dividendorder',0,71,'adjustment','调整',0,0,30,@blockid,2,'N~O',1,10 from dual 
where not EXISTS(select 1 from ld_field where tabid=@tabid  and columnname='adjustment');

select fieldid into @relateid  from ld_field where tabid=@tabid and columnname='adjustment';
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'zh','ld_field',@tabid,@relateid ,'调整' from dual 
where not exists(select 1 from  ld_tranlabel where tabid=@tabid and trantable='ld_field' and relateid=@relateid and languagetype='zh');

insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'en','ld_field',@tabid,@relateid ,'Adjustment' from dual 
where not exists(select 1 from  ld_tranlabel where tabid=@tabid and trantable='ld_field' and relateid=@relateid and languagetype='en');
delimiter;

select tabid into @tabid from ld_tab where `name` = 'TimeSheet';
update ld_field set masseditable = 0 where tabid = @tabid and columnname = 'timesheet_no' and masseditable = 1;
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,Labeltype)
select 'zh','YOUIN','您在','jspop' from dual
where not exists(select 1 from ld_desk where labelbol='YOUIN' and languagetype='zh' and Labeltype = 'jspop');
insert into ld_desk(languagetype,labelbol,fieldlabel,Labeltype)
select 'en','YOUIN','You in','jspop' from dual
where not exists(select 1 from ld_desk where labelbol='YOUIN' and languagetype='en' and Labeltype = 'jspop');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,Labeltype)
select 'zh','OVERTIME','的工时超过','jspop' from dual
where not exists(select 1 from ld_desk where labelbol='OVERTIME' and languagetype='zh' and Labeltype = 'jspop');
insert into ld_desk(languagetype,labelbol,fieldlabel,Labeltype)
select 'en','OVERTIME',' over time ','jspop' from dual
where not exists(select 1 from ld_desk where labelbol='OVERTIME' and languagetype='en' and Labeltype = 'jspop');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,Labeltype)
select 'zh','HOUR','小时','jspop' from dual
where not exists(select 1 from ld_desk where labelbol='HOUR' and languagetype='zh' and Labeltype = 'jspop');
insert into ld_desk(languagetype,labelbol,fieldlabel,Labeltype)
select 'en','HOUR',' hour ','jspop' from dual
where not exists(select 1 from ld_desk where labelbol='HOUR' and languagetype='en' and Labeltype = 'jspop');
delimiter;

select parenttabid into @parenttabid from ld_parenttab where parenttab_label = 'Project';
select tabid into @tabid from ld_tab where `name` = 'ProjectMilestone';
select tabid into @timesheet_tabid from ld_tab where `name` = 'TimeSheet';
select sequence into @sequence from ld_parenttabrel where parenttabid = @parenttabid and tabid = @tabid;
update ld_parenttabrel set sequence = sequence + 1 where parenttabid = @parenttabid and sequence > @sequence;
update ld_parenttabrel set sequence = @sequence + 1 where parenttabid = @parenttabid and tabid = @timesheet_tabid;
set @i=0;
update ld_parenttabrel set sequence=(@i:=@i+1) where parenttabid=@parenttabid order by sequence;
delimiter;

update ld_desk set fieldlabel = '日期' where labelbol = 'TOOLSFIELDSDATESETTING' and Labeltype = 'fixedstr' and languagetype = 'zh';
update ld_desk set fieldlabel = 'Date' where labelbol = 'TOOLSFIELDSDATESETTING' and Labeltype = 'fixedstr' and languagetype = 'en';
delimiter;

update ld_desk set fieldlabel = '整数' where labelbol = 'TOOLSFIELDSINT' and Labeltype = 'fixedstr' and languagetype = 'zh';
delimiter;

select tabsequence into @tabsequence from ld_tab where `name` = 'ProjectMilestone';
update ld_tab set tabsequence = tabsequence + 1 where tabsequence > @tabsequence;
update ld_tab set tabsequence = @tabsequence + 1 where `name` = 'TimeSheet';
set @i=0;
update ld_tab set tabsequence=(@i:=@i+1) order by tabsequence;
delimiter;

update ld_quickactions set presence=1 where tabid=21 AND related_tabid=98;
delimiter;
update ld_desk set fieldlabel='明细' where labelbol='DETAIL' AND languagetype='zh';
delimiter;
update ld_desk set fieldlabel='details' where labelbol='DETAIL' AND languagetype='en';
delimiter;
-- 2016-05-06

DROP PROCEDURE IF EXISTS `update_account_lastcontactuser`;
delimiter ||
CREATE  PROCEDURE `update_account_lastcontactuser`(
)
BEGIN
	
	
		declare tmp_accountid int;
		declare tmp_smownerid int;

		declare cur1 CURSOR FOR select b.accountid,a.smownerid
														from (
																select 
																accountid,smownerid,max(contactdate) as contactdate
																from ld_contactrecords 
																where deleted=0 and accountid>0 
																GROUP BY accountid
																order by accountid, contactdate DESC) a 
														INNER JOIN ld_account b on a.accountid=b.accountid
														where b.lastcontactuser=0 and a.smownerid>0;

		DECLARE CONTINUE HANDLER FOR SQLSTATE '02000' set tmp_accountid = NULL;
	
		OPEN cur1;
		Fetch cur1 into tmp_accountid,tmp_smownerid;
		while(tmp_accountid is not null) DO
				update ld_account set lastcontactuser=tmp_smownerid where lastcontactuser=0 and accountid=tmp_accountid;
		Fetch cur1 into tmp_accountid,tmp_smownerid;
		end while;
		close cur1;
end ||
delimiter;

call update_account_lastcontactuser;
delimiter;

update ld_field set displaytype=1 where tabid=6 and columnname='smownerid';
update ld_field set typeofdata='V~O' where displaytype=2  and typeofdata='V~M';
delimiter;


insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','DISTRIBUTECHANGEASSIGNED','分配（更改负责人）','jspop' from dual 
where not exists(select 1 from ld_desk where labelbol = 'DISTRIBUTECHANGEASSIGNED' and languagetype = 'zh' and labeltype = 'jspop');
delimiter;
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','DISTRIBUTECHANGEASSIGNED','Distribute（Change Assigned）','jspop' from dual 
where not exists(select 1 from ld_desk where labelbol = 'DISTRIBUTECHANGEASSIGNED' and languagetype = 'en' and labeltype = 'jspop');
delimiter;

update ld_systems_deploy set inputvalue = '[{"value":"","text":""},{"sql":"select * from ld_rating where presence=1 order by picklist_valueid asc","field":"rating"},{"relatedmodule":"SalesOrder,Accounts"},{"isSelectValue":"yes"}]' where deploy_type = 37;
delimiter;
update ld_systems_deploy set inputvalue = '[{"value":"","text":""},{"sql":"select * from ld_sales_stage where presence=1 order by picklist_valueid asc","field":"sales_stage"},{"relatedmodule":"SalesOrder,Potentials"},{"isSelectValue":"yes"}]' where deploy_type = 38;
delimiter;
update ld_systems_deploy set inputvalue = '[{"value":"","text":""},{"sql":"select DISTINCT ld_warehouse.name,ld_warehouse.id from  ld_warehouse where ld_warehouse.started = 0 and ld_warehouse.status = 0 order by ld_warehouse.id","field":"name"},{"relatedmodule":"SalesOrder,OutboundOrder"},{"isSelectValue":"yes"}]' where deploy_type = 56;
delimiter;
update ld_systems_deploy set inputvalue = '[{"value":"","text":""},{"sql":"select DISTINCT ld_warehouse.name,ld_warehouse.id from  ld_warehouse where ld_warehouse.started = 0 and ld_warehouse.status = 0 order by ld_warehouse.id","field":"name"},{"relatedmodule":"SalesOrder,OutboundOrder"},{"isSelectValue":"yes"}]' where deploy_type = 63;
delimiter;
update ld_systems_deploy set inputvalue = '[{"value":"0","text":"YES"},{"value":"1","text":"NO"},{"sql":""},{"or_relatedmodule":"OutboundOrder,Stock"}]' where deploy_type = 10;
delimiter;
update ld_systems_deploy set inputvalue = '[{"value":"0","text":"Checkout"},{"value":"1","text":"SAVE"},{"sql":""},{"or_relatedmodule":"OutboundOrder,Stock"}]' where deploy_type = 48;
delimiter;

insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'zh','ld_system_deploy',25,25,'{$Potentials.Potentials}查看明细界面是否显示{$Accounts.Accounts}基本信息'
from dual where not exists (select * from ld_tranlabel where languagetype='zh' and trantable='ld_system_deploy' and relateid=25);
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'en','ld_system_deploy',25,25,' {$Potentials.Potentials} check detail interface whether to display the {$Accounts.Accounts} basic information'
from dual where not exists (select * from ld_tranlabel where languagetype='en' and trantable='ld_system_deploy' and relateid=25);
delete from ld_desk where labelbol='CHEKDETAILDISPLAYBASICINFO';
update ld_systems_deploy set roottype='1',inputtype='select',inputvalue='[{"value":"0","text":"YES"},{"value":"1","text":"NO"},{"sql":""},{"relatedmodule":"Accounts,Potentials"}]',presence=1 where deploy_type=25;
delimiter;

insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'zh','ld_system_deploy',32,32,'{$ProjectTask.ProjectTask}查看明细界面是否显示{$Accounts.Accounts}和{$Contacts.Contacts}基本信息'
from dual where not exists (select * from ld_tranlabel where languagetype='zh' and trantable='ld_system_deploy' and relateid=32);
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'en','ld_system_deploy',32,32,'Display the block  Basic Information of the {$Accounts.Accounts} and {$Contacts.Contacts} when viewing the details of {$ProjectTask.ProjectTask}'
from dual where not exists (select * from ld_tranlabel where languagetype='en' and trantable='ld_system_deploy' and relateid=32);
delete from ld_desk where labelbol='THEPROJECTTASKCHECKDETAILINTERFACE';
update ld_systems_deploy set roottype='1',inputtype='select',inputvalue='[{"value":"0","text":"YES"},{"value":"1","text":"NO"},{"sql":""},{"relatedmodule":"Accounts,Contacts,ProjectTask"}]',presence=1 where deploy_type=32;
delimiter;

insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'zh','ld_system_deploy',65,65,'设置首页组件视图的布局样式'
from dual where not exists (select * from ld_tranlabel where languagetype='zh' and trantable='ld_system_deploy' and relateid=65);
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'en','ld_system_deploy',65,65,'The home page component layout style.'
from dual where not exists (select * from ld_tranlabel where languagetype='en' and trantable='ld_system_deploy' and relateid=65);
delete from ld_desk where labelbol='LBL_HOMECONTROLLAYOUT';
update ld_systems_deploy set roottype='1',inputtype='select',inputvalue='[{"value":"2","text":"TWO"},{"value":"3","text":"THREE"},{"sql":""}]',presence=1 where deploy_type=65;
delimiter;

insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'zh','ld_system_deploy',86,86,'已购产品是否只统计已审批通过的合同订单'
from dual where not exists (select * from ld_tranlabel where languagetype='zh' and trantable='ld_system_deploy' and relateid=86);
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'en','ld_system_deploy',86,86,'Bought Product Has Approved Contract Orders'
from dual where not exists (select * from ld_tranlabel where languagetype='en' and trantable='ld_system_deploy' and relateid=86);
delete from ld_desk where labelbol='BOUGHTPRODUCTHASAPPROVEDCONTRACTORDERS';
update ld_systems_deploy set roottype='1',inputtype='select',inputvalue='[{"value":"0","text":"YES"},{"value":"1","text":"NO"},{"sql":""}]',presence=1 where deploy_type=86;
delimiter;

update ld_systems_deploy 
set inputvalue = '[{"value":"id","text":"name"},{"sql":"select DISTINCT ld_warehouse.name,ld_warehouse.id from  ld_warehouse where ld_warehouse.started = 0 and ld_warehouse.status = 0 order by ld_warehouse.id","field":"name"},{"relatedmodule":"SalesOrder,OutboundOrder"},{"isSelectValue":"yes"}]'
where deploy_type = 56;
delimiter;

update ld_systems_deploy
set inputvalue = '[{"value":"id","text":"name"},{"sql":"select DISTINCT ld_warehouse.name,ld_warehouse.id from  ld_warehouse where ld_warehouse.started = 0 and ld_warehouse.status = 0 order by ld_warehouse.id","field":"name"},{"relatedmodule":"SalesOrder,OutboundOrder"},{"isSelectValue":"yes"}]'
where deploy_type = 63;
delimiter;

update ld_systems_deploy
set inputvalue = '[{"value":"rating","text":"rating"},{"sql":"select * from ld_rating where presence=1 order by picklist_valueid asc","field":"rating"},{"relatedmodule":"SalesOrder,Accounts"},{"isSelectValue":"yes"}]'
where deploy_type = 37;
delimiter;

update ld_systems_deploy
set inputvalue = '[{"value":"sales_stage","text":"sales_stage"},{"sql":"select * from ld_sales_stage where presence=1 order by picklist_valueid asc","field":"sales_stage"},{"relatedmodule":"SalesOrder,Potentials"},{"isSelectValue":"yes"}]'
where deploy_type = 38;
delimiter;
-- 2016-05-07

select tabid into @tabid from ld_tab where `name` = 'TimeSheet';
select fieldid into @fieldid from ld_field where tabid = @tabid and columnname = 'timesheet_no';
insert into ld_relatedlists_lable(tabid,fieldid,width,sequence,presence,edit)
select @tabid,@fieldid,0,1,1,0 from DUAL
where not exists(select 1 from ld_relatedlists_lable where tabid = @tabid and fieldid = @fieldid);
select fieldid into @fieldid from ld_field where tabid = @tabid and columnname = 'smcreatorid';
insert into ld_relatedlists_lable(tabid,fieldid,width,sequence,presence,edit)
select @tabid,@fieldid,0,2,1,0 from DUAL
where not exists(select 1 from ld_relatedlists_lable where tabid = @tabid and fieldid = @fieldid);
select fieldid into @fieldid from ld_field where tabid = @tabid and columnname = 'approveby';
insert into ld_relatedlists_lable(tabid,fieldid,width,sequence,presence,edit)
select @tabid,@fieldid,0,3,1,0 from DUAL
where not exists(select 1 from ld_relatedlists_lable where tabid = @tabid and fieldid = @fieldid);
select fieldid into @fieldid from ld_field where tabid = @tabid and columnname = 'approvestatus';
insert into ld_relatedlists_lable(tabid,fieldid,width,sequence,presence,edit)
select @tabid,@fieldid,0,4,1,0 from DUAL
where not exists(select 1 from ld_relatedlists_lable where tabid = @tabid and fieldid = @fieldid);
select fieldid into @fieldid from ld_field where tabid = @tabid and columnname = 'smownerid';
insert into ld_relatedlists_lable(tabid,fieldid,width,sequence,presence,edit)
select @tabid,@fieldid,0,5,1,0 from DUAL
where not exists(select 1 from ld_relatedlists_lable where tabid = @tabid and fieldid = @fieldid);
delimiter;

update ld_systems_deploy set roottype=4 where deploy_type=86;
-- 2016-05-09


CREATE TABLE IF NOT EXISTS `ld_servicereturn` (
  `servicereturnid` int(19) NOT NULL AUTO_INCREMENT,
  `accountid` int(11) DEFAULT NULL,
  `contactid` int(11) DEFAULT NULL,
  `servicereturn_no` varchar(100) DEFAULT NULL,
  `troubleticketid` int(11) DEFAULT NULL,
  `projecttaskid`  int(11) DEFAULT NULL,
  `satisfaction` varchar(100) DEFAULT '100%',
  `timelyrate` varchar(100) DEFAULT '100%',
  `resolutionrate` varchar(100) DEFAULT '100%',
  `servant_come` varchar(100),
  `deleted` int(11) DEFAULT '0',
  `content` text,
  `approveby` int(19),
  `approvestatus` varchar(200) DEFAULT '未提交',
  `smownerid` int(11) DEFAULT '0',
  `smcreatorid` int(11) DEFAULT '0',
  `modifiedby` int(11) DEFAULT '0',
  `createdtime` datetime DEFAULT NULL,
  `modifiedtime` datetime DEFAULT NULL,
  PRIMARY KEY (`servicereturnid`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
delimiter;

CREATE TABLE IF NOT EXISTS `ld_servicereturncf` (
  `servicereturnid` int(11) NOT NULL DEFAULT '0',
  PRIMARY KEY (`servicereturnid`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
delimiter;

select max(tabid)+1 into @tabid from ld_tab;
select tabsequence into @tabsequence from ld_tab where `name` = 'HelpDesk';
update ld_tab set tabsequence = tabsequence + 1 where ld_tab.tabsequence > @tabsequence;
insert into ld_tab(tabid,name,presence,tabsequence,tablabel,isentitytype,parent,printtab)
select @tabid,'ServiceReturn',0,@tabsequence+1,'ServiceReturn',1,'Service',0
from dual where not EXISTS(select 1 from ld_tab  where tablabel ='ServiceReturn');
set @i=0;
update ld_tab set tabsequence=(@i:=@i+1) order by tabsequence;
delimiter;

select parenttabid into @parenttabid from ld_parenttab where parenttab_label = 'Service';
select tabid into @tabid from ld_tab where `name` = 'HelpDesk';
select sequence into @sequence from ld_parenttabrel where parenttabid = @parenttabid and tabid = @tabid;
update ld_parenttabrel set sequence = sequence + 1 where parenttabid = @parenttabid and sequence > @sequence;
select tabid into @tabid from ld_tab where `name` = 'ServiceReturn';
insert into ld_parenttabrel(parenttabid,tabid,sequence)
select @parenttabid,@tabid,@sequence+1
from dual where not EXISTS(select 1 from ld_parenttabrel  where parenttabid = @parenttabid and tabid =@tabid);
set @i=0;
update ld_parenttabrel set sequence=(@i:=@i+1) where parenttabid = @parenttabid order by sequence;
delimiter;

select tabid into @tabid from ld_tab where `name` = 'ServiceReturn';
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'zh','ld_tab',@tabid,@tabid,'服务回访单'
from dual where not EXISTS(select 1 from ld_tranlabel  where languagetype = 'zh'
and trantable ='ld_tab' and tabid = @tabid and relateid=@tabid);
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'en','ld_tab',@tabid,@tabid,'Service Return'
from dual where not EXISTS(select 1 from ld_tranlabel  where languagetype = 'en'
and trantable ='ld_tab' and tabid = @tabid and relateid=@tabid);
delimiter;

call addtabintoprofile('ServiceReturn',0);
select tabid into @tabid from ld_tab where `name` = 'ServiceReturn';
update ld_profile2standardpermissions set permissions = 1 where tabid = @tabid and profileid not in (
select ld_role2profile.profileid from ld_users
inner join ld_user2role on ld_users.id = ld_user2role.userid
inner join ld_role2profile on ld_role2profile.roleid = ld_user2role.roleid  where is_admin = 'on'
);

select tabid into @tabid from ld_tab where `name` = 'ServiceReturn';
insert into ld_org_share_action2tab(share_action_id,tabid) select 0,@tabid from dual
where not exists(select 1 from ld_org_share_action2tab where share_action_id=0 and tabid=@tabid);
delimiter;

insert into ld_org_share_action2tab(share_action_id,tabid) select 1,@tabid from dual
where not exists(select 1 from ld_org_share_action2tab where share_action_id=1 and tabid=@tabid);
delimiter;

insert into ld_org_share_action2tab(share_action_id,tabid) select 2,@tabid from dual
where not exists(select 1 from ld_org_share_action2tab where share_action_id=2 and tabid=@tabid);
delimiter;

insert into ld_org_share_action2tab(share_action_id,tabid) select 3,@tabid from dual
where not exists(select 1 from ld_org_share_action2tab where share_action_id=3 and tabid=@tabid);
delimiter;

select max(ruleid) into @ruleid from ld_def_org_share;
update ld_def_org_share_seq set id=@ruleid+1 where  not exists(select 1 from ld_def_org_share where tabid=@tabid);
insert into ld_def_org_share(ruleid,tabid,permission,editstatus)
select @ruleid+1,@tabid,3,0  from dual where  not exists(select 1 from ld_def_org_share where tabid=@tabid);
delimiter;

select tabid into @tabid from ld_tab where `name` = 'ServiceReturn';
insert into ld_blocks(blockid,tabid,blocklabel,sequence)
select (select max(blockid) from ld_blocks)+1,@tabid,'LBL_SERVICERETURN_INFO',1 from dual where not exists (select 1 from ld_blocks where
tabid = @tabid and blocklabel = 'LBL_SERVICERETURN_INFO' and sequence = 1);
insert into ld_blocks(blockid,tabid,blocklabel,sequence)
select (select max(blockid) from ld_blocks)+1,@tabid,'LBL_SERVICERETURN_DESCRIPTION',2 from dual where not exists (select 1 from ld_blocks where
tabid = @tabid and blocklabel = 'LBL_SERVICERETURN_DESCRIPTION' and sequence = 2);
update ld_blocks_seq set id = (select max(blockid)+1 from ld_blocks);
delimiter;

select blockid into @blockid from ld_blocks where tabid = @tabid and blocklabel = 'LBL_SERVICERETURN_INFO';
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'zh','ld_blocks',@tabid,@blockid,'基本信息'
from dual where not EXISTS(select 1 from ld_tranlabel  where languagetype = 'zh'
and trantable ='ld_blocks' and tabid = @tabid and relateid=@blockid);
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'en','ld_blocks',@tabid,@blockid,'Basic Information'
from dual where not EXISTS(select 1 from ld_tranlabel  where languagetype = 'en'
and trantable ='ld_blocks' and tabid = @tabid and relateid=@blockid);
delimiter;

select blockid into @blockid from ld_blocks where tabid = @tabid and blocklabel = 'LBL_SERVICERETURN_DESCRIPTION';
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'zh','ld_blocks',@tabid,@blockid,'备注'
from dual where not EXISTS(select 1 from ld_tranlabel  where languagetype = 'zh'
and trantable ='ld_blocks' and tabid = @tabid and relateid=@blockid);
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'en','ld_blocks',@tabid,@blockid,'Description Information'
from dual where not EXISTS(select 1 from ld_tranlabel  where languagetype = 'en'
and trantable ='ld_blocks' and tabid = @tabid and relateid=@blockid);
delimiter;

insert into ld_field(tabid,fieldid,columnname,tablename,uitype,fieldname,fieldlabel,block,displaytype,presence,typeofdata,sequence)
select @tabid,(select max(fieldid) from ld_field)+1,'accountid','ld_servicereturn',73,'account_id','客户名称',(select blockid from ld_blocks where blocklabel = 'LBL_SERVICERETURN_INFO'),1,0,'I~O',1 from dual where not exists
(select 1 from ld_field where tabid = @tabid and columnname = 'accountid');
delimiter;

insert into ld_field(tabid,fieldid,columnname,tablename,uitype,fieldname,fieldlabel,block,displaytype,presence,typeofdata,sequence)
select @tabid,(select max(fieldid) from ld_field)+1,'servicereturn_no','ld_servicereturn',4,'servicereturn_no','回访单编号',(select blockid from ld_blocks where blocklabel = 'LBL_SERVICERETURN_INFO'),1,0,'V~M',2 from dual where not exists
(select 1 from ld_field where tabid = @tabid and columnname = 'servicereturn_no');
delimiter;

insert into ld_field(tabid,fieldid,columnname,tablename,uitype,fieldname,fieldlabel,block,displaytype,presence,typeofdata,sequence)
select @tabid,(select max(fieldid) from ld_field)+1,'contactid','ld_servicereturn',57,'contact_id','联系人姓名',(select blockid from ld_blocks where blocklabel = 'LBL_SERVICERETURN_INFO'),1,0,'I~O',3 from dual where not exists
(select 1 from ld_field where tabid = @tabid and columnname = 'contactid');
delimiter;

insert into ld_field(tabid,fieldid,columnname,tablename,uitype,fieldname,fieldlabel,block,displaytype,presence,typeofdata,sequence)
select @tabid,(select max(fieldid) from ld_field)+1,'troubleticketid','ld_servicereturn',240,'troubleticketid','客户服务单',(select blockid from ld_blocks where blocklabel = 'LBL_SERVICERETURN_INFO'),1,0,'I~O',4 from dual where not exists
(select 1 from ld_field where tabid = @tabid and columnname = 'troubleticketid');
delimiter;

insert into ld_field(tabid,fieldid,columnname,tablename,uitype,fieldname,fieldlabel,block,displaytype,presence,typeofdata,sequence,issmownerid)
select @tabid,(select max(fieldid) from ld_field)+1,'smownerid','ld_servicereturn',53,'assigned_user_id','服务人员',(select blockid from ld_blocks where blocklabel = 'LBL_SERVICERETURN_INFO'),1,0,'V~M',5,1 from dual where not exists
(select 1 from ld_field where tabid = @tabid and columnname = 'smownerid');
delimiter;

insert into ld_field(tabid,fieldid,columnname,tablename,uitype,fieldname,fieldlabel,block,displaytype,presence,typeofdata,sequence)
select @tabid,(select max(fieldid) from ld_field)+1,'projecttaskid','ld_servicereturn',241,'projecttaskid','项目计划',(select blockid from ld_blocks where blocklabel = 'LBL_SERVICERETURN_INFO'),1,0,'V~O',6 from dual where not exists
(select 1 from ld_field where tabid = @tabid and columnname = 'projecttaskid');
delimiter;

insert into ld_field(tabid,fieldid,columnname,tablename,uitype,fieldname,fieldlabel,block,displaytype,presence,typeofdata,sequence)
select @tabid,(select max(fieldid) from ld_field)+1,'satisfaction','ld_servicereturn',15,'satisfaction','满意度',(select blockid from ld_blocks where blocklabel = 'LBL_SERVICERETURN_INFO'),1,0,'V~O',6 from dual where not exists
(select 1 from ld_field where tabid = @tabid and columnname = 'satisfaction');
delimiter;

insert into ld_field(tabid,fieldid,columnname,tablename,uitype,fieldname,fieldlabel,block,displaytype,presence,typeofdata,sequence)
select @tabid,(select max(fieldid) from ld_field)+1,'timelyrate','ld_servicereturn',15,'timelyrate','及时率',(select blockid from ld_blocks where blocklabel = 'LBL_SERVICERETURN_INFO'),1,0,'V~O',7 from dual where not exists
(select 1 from ld_field where tabid = @tabid and columnname = 'timelyrate');
delimiter;

insert into ld_field(tabid,fieldid,columnname,tablename,uitype,fieldname,fieldlabel,block,displaytype,presence,typeofdata,sequence)
select @tabid,(select max(fieldid) from ld_field)+1,'resolutionrate','ld_servicereturn',15,'resolutionrate','解决率',(select blockid from ld_blocks where blocklabel = 'LBL_SERVICERETURN_INFO'),1,0,'V~O',8 from dual where not exists
(select 1 from ld_field where tabid = @tabid and columnname = 'resolutionrate');
delimiter;

insert into ld_field(tabid,fieldid,columnname,tablename,uitype,fieldname,fieldlabel,block,displaytype,presence,typeofdata,sequence)
select @tabid,(select max(fieldid) from ld_field)+1,'servant_come','ld_servicereturn',15,'servant_come','服务人员是否来过',(select blockid from ld_blocks where blocklabel = 'LBL_SERVICERETURN_INFO'),1,0,'V~O',9 from dual where not exists
(select 1 from ld_field where tabid = @tabid and columnname = 'servant_come');
delimiter;

insert into ld_field(tabid,fieldid,columnname,tablename,uitype,fieldname,fieldlabel,block,displaytype,presence,typeofdata,sequence)
select @tabid,(select max(fieldid) from ld_field)+1,'content','ld_servicereturn',19,'content','备注',(select blockid from ld_blocks where blocklabel = 'LBL_SERVICERETURN_DESCRIPTION'),1,0,'V~O',8 from dual where not exists
(select 1 from ld_field where tabid = @tabid and columnname = 'content');
delimiter;

insert into ld_field(tabid,fieldid,columnname,tablename,uitype,fieldname,fieldlabel,block,displaytype,presence,typeofdata,sequence)
select @tabid,(select max(fieldid) from ld_field)+1,'createdtime','ld_servicereturn',70,'createdtime','创建时间',(select blockid from ld_blocks where blocklabel = 'LBL_SERVICERETURN_INFO'),2,0,'DT~O',12 from dual where not exists
(select 1 from ld_field where tabid = @tabid and columnname = 'createdtime');
delimiter;

insert into ld_field(tabid,fieldid,columnname,tablename,uitype,fieldname,fieldlabel,block,displaytype,presence,typeofdata,sequence)
select @tabid,(select max(fieldid) from ld_field)+1,'modifiedtime','ld_servicereturn',70,'modifiedtime','修改时间',(select blockid from ld_blocks where blocklabel = 'LBL_SERVICERETURN_INFO'),2,0,'DT~O',14 from dual where not exists
(select 1 from ld_field where tabid = @tabid and columnname = 'modifiedtime');
delimiter;


insert into ld_field(tabid,fieldid,columnname,tablename,uitype,fieldname,fieldlabel,block,displaytype,presence,typeofdata,generatedtype,sequence)
select @tabid,(select max(fieldid) from ld_field)+1,'smcreatorid','ld_servicereturn',52,'smcreatorid','创建人',(select blockid from ld_blocks where blocklabel = 'LBL_SERVICERETURN_INFO'),2,0,'V~O',1,11 from dual where not exists
(select 1 from ld_field where tabid = @tabid and columnname = 'smcreatorid');
delimiter;

insert into ld_field(tabid,fieldid,columnname,tablename,uitype,fieldname,fieldlabel,block,displaytype,presence,typeofdata,generatedtype,sequence)
select @tabid,(select max(fieldid) from ld_field)+1,'modifiedby','ld_servicereturn',52,'modifiedby','修改人',(select blockid from ld_blocks where blocklabel = 'LBL_SERVICERETURN_INFO'),2,0,'V~O',1,13 from dual where not exists
(select 1 from ld_field where tabid = @tabid and columnname = 'modifiedby');
delimiter;

insert into ld_field(tabid,fieldid,columnname,tablename,uitype,fieldname,fieldlabel,block,displaytype,presence,typeofdata,sequence)
select @tabid,(select max(fieldid) from ld_field)+1,'approveby','ld_servicereturn',131,'approveby','审批人',(select blockid from ld_blocks where blocklabel='LBL_SERVICERETURN_INFO'),1,0,'V~O',10 from dual where not EXISTS(select 1 from ld_field where tabid=@tabid and columnname='approveby');
delimiter;

insert into ld_field(tabid,fieldid,columnname,tablename,uitype,fieldname,fieldlabel,block,displaytype,presence,typeofdata,sequence)
select @tabid,(select max(fieldid) from ld_field)+1,'approvestatus','ld_servicereturn',130,'approvestatus','审批状态',(select blockid from ld_blocks where blocklabel='LBL_SERVICERETURN_INFO'),1,0,'V~O',15 from dual where not EXISTS(select 1 from ld_field where tabid=@tabid and columnname='approvestatus');
delimiter;



update ld_field_seq set id=(select max(fieldid) from ld_field);
delimiter;


select fieldid into @fieldid from ld_field where tabid = @tabid and fieldname = 'account_id';
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'zh','ld_field',@tabid,@fieldid,'客户名称'
from dual where not EXISTS(select 1 from ld_tranlabel  where languagetype = 'zh'
and trantable ='ld_field' and tabid = @tabid and relateid=@fieldid);
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'en','ld_field',@tabid,@fieldid,'Customer Name'
from dual where not EXISTS(select 1 from ld_tranlabel  where languagetype = 'en'
and trantable ='ld_field' and tabid = @tabid and relateid=@fieldid);
delimiter;

select fieldid into @fieldid from ld_field where tabid = @tabid and fieldname = 'servicereturn_no';
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'zh','ld_field',@tabid,@fieldid,'回访单编号'
from dual where not EXISTS(select 1 from ld_tranlabel  where languagetype = 'zh'
and trantable ='ld_field' and tabid = @tabid and relateid=@fieldid);
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'en','ld_field',@tabid,@fieldid,'Service Return No'
from dual where not EXISTS(select 1 from ld_tranlabel  where languagetype = 'en'
and trantable ='ld_field' and tabid = @tabid and relateid=@fieldid);
delimiter;

select fieldid into @fieldid from ld_field where tabid = @tabid and fieldname = 'contact_id';
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'zh','ld_field',@tabid,@fieldid,'联系人姓名'
from dual where not EXISTS(select 1 from ld_tranlabel  where languagetype = 'zh'
and trantable ='ld_field' and tabid = @tabid and relateid=@fieldid);
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'en','ld_field',@tabid,@fieldid,'Contact Name'
from dual where not EXISTS(select 1 from ld_tranlabel  where languagetype = 'en'
and trantable ='ld_field' and tabid = @tabid and relateid=@fieldid);
delimiter;

select fieldid into @fieldid from ld_field where tabid = @tabid and fieldname = 'troubleticketid';
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'zh','ld_field',@tabid,@fieldid,'客户服务单'
from dual where not EXISTS(select 1 from ld_tranlabel  where languagetype = 'zh'
and trantable ='ld_field' and tabid = @tabid and relateid=@fieldid);
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'en','ld_field',@tabid,@fieldid,'Helpdesk'
from dual where not EXISTS(select 1 from ld_tranlabel  where languagetype = 'en'
and trantable ='ld_field' and tabid = @tabid and relateid=@fieldid);
delimiter;

select fieldid into @fieldid from ld_field where tabid = @tabid and fieldname = 'assigned_user_id';
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'zh','ld_field',@tabid,@fieldid,'服务人员'
from dual where not EXISTS(select 1 from ld_tranlabel  where languagetype = 'zh'
and trantable ='ld_field' and tabid = @tabid and relateid=@fieldid);
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'en','ld_field',@tabid,@fieldid,'Assigned To'
from dual where not EXISTS(select 1 from ld_tranlabel  where languagetype = 'en'
and trantable ='ld_field' and tabid = @tabid and relateid=@fieldid);
delimiter;

select fieldid into @fieldid from ld_field where tabid = @tabid and fieldname = 'projecttaskid';
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'zh','ld_field',@tabid,@fieldid,'项目计划'
from dual where not EXISTS(select 1 from ld_tranlabel  where languagetype = 'zh'
and trantable ='ld_field' and tabid = @tabid and relateid=@fieldid);
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'en','ld_field',@tabid,@fieldid,'ProjectTask'
from dual where not EXISTS(select 1 from ld_tranlabel  where languagetype = 'en'
and trantable ='ld_field' and tabid = @tabid and relateid=@fieldid);
delimiter;

select fieldid into @fieldid from ld_field where tabid = @tabid and fieldname = 'satisfaction';
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'zh','ld_field',@tabid,@fieldid,'满意度'
from dual where not EXISTS(select 1 from ld_tranlabel  where languagetype = 'zh'
and trantable ='ld_field' and tabid = @tabid and relateid=@fieldid);
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'en','ld_field',@tabid,@fieldid,'Satisfaction degree'
from dual where not EXISTS(select 1 from ld_tranlabel  where languagetype = 'en'
and trantable ='ld_field' and tabid = @tabid and relateid=@fieldid);
delimiter;

select fieldid into @fieldid from ld_field where tabid = @tabid and fieldname = 'timelyrate';
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'zh','ld_field',@tabid,@fieldid,'及时率'
from dual where not EXISTS(select 1 from ld_tranlabel  where languagetype = 'zh'
and trantable ='ld_field' and tabid = @tabid and relateid=@fieldid);
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'en','ld_field',@tabid,@fieldid,'Timely rate'
from dual where not EXISTS(select 1 from ld_tranlabel  where languagetype = 'en'
and trantable ='ld_field' and tabid = @tabid and relateid=@fieldid);
delimiter;

select fieldid into @fieldid from ld_field where tabid = @tabid and fieldname = 'resolutionrate';
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'zh','ld_field',@tabid,@fieldid,'解决率'
from dual where not EXISTS(select 1 from ld_tranlabel  where languagetype = 'zh'
and trantable ='ld_field' and tabid = @tabid and relateid=@fieldid);
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'en','ld_field',@tabid,@fieldid,'Resolution rate'
from dual where not EXISTS(select 1 from ld_tranlabel  where languagetype = 'en'
and trantable ='ld_field' and tabid = @tabid and relateid=@fieldid);
delimiter;

select fieldid into @fieldid from ld_field where tabid = @tabid and fieldname = 'servant_come';
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'zh','ld_field',@tabid,@fieldid,'服务人员是否来过'
from dual where not EXISTS(select 1 from ld_tranlabel  where languagetype = 'zh'
and trantable ='ld_field' and tabid = @tabid and relateid=@fieldid);
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'en','ld_field',@tabid,@fieldid,'Whether the service personnel to'
from dual where not EXISTS(select 1 from ld_tranlabel  where languagetype = 'en'
and trantable ='ld_field' and tabid = @tabid and relateid=@fieldid);
delimiter;

select fieldid into @fieldid from ld_field where tabid = @tabid and fieldname = 'content';
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'zh','ld_field',@tabid,@fieldid,'备注'
from dual where not EXISTS(select 1 from ld_tranlabel  where languagetype = 'zh'
and trantable ='ld_field' and tabid = @tabid and relateid=@fieldid);
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'en','ld_field',@tabid,@fieldid,'Description'
from dual where not EXISTS(select 1 from ld_tranlabel  where languagetype = 'en'
and trantable ='ld_field' and tabid = @tabid and relateid=@fieldid);
delimiter;

select fieldid into @fieldid from ld_field where tabid = @tabid and fieldname = 'modifiedby';
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'zh','ld_field',@tabid,@fieldid,'最新更新人'
from dual where not EXISTS(select 1 from ld_tranlabel  where languagetype = 'zh'
and trantable ='ld_field' and tabid = @tabid and relateid=@fieldid);
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'en','ld_field',@tabid,@fieldid,'Modified By'
from dual where not EXISTS(select 1 from ld_tranlabel  where languagetype = 'en'
and trantable ='ld_field' and tabid = @tabid and relateid=@fieldid);
delimiter;

select fieldid into @fieldid from ld_field where tabid = @tabid and fieldname = 'modifiedtime';
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'zh','ld_field',@tabid,@fieldid,'修改时间'
from dual where not EXISTS(select 1 from ld_tranlabel  where languagetype = 'zh'
and trantable ='ld_field' and tabid = @tabid and relateid=@fieldid);
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'en','ld_field',@tabid,@fieldid,'Modified Time'
from dual where not EXISTS(select 1 from ld_tranlabel  where languagetype = 'en'
and trantable ='ld_field' and tabid = @tabid and relateid=@fieldid);
delimiter;

select fieldid into @fieldid from ld_field where tabid = @tabid and fieldname = 'createdtime';
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'zh','ld_field',@tabid,@fieldid,'创建时间'
from dual where not EXISTS(select 1 from ld_tranlabel  where languagetype = 'zh'
and trantable ='ld_field' and tabid = @tabid and relateid=@fieldid);
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'en','ld_field',@tabid,@fieldid,'CreatedTime'
from dual where not EXISTS(select 1 from ld_tranlabel  where languagetype = 'en'
and trantable ='ld_field' and tabid = @tabid and relateid=@fieldid);
delimiter;

select fieldid into @fieldid from ld_field where tabid = @tabid and fieldname = 'smownerid';
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'zh','ld_field',@tabid,@fieldid,'负责人'
from dual where not EXISTS(select 1 from ld_tranlabel  where languagetype = 'zh'
and trantable ='ld_field' and tabid = @tabid and relateid=@fieldid);
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'en','ld_field',@tabid,@fieldid,'Smownerid'
from dual where not EXISTS(select 1 from ld_tranlabel  where languagetype = 'en'
and trantable ='ld_field' and tabid = @tabid and relateid=@fieldid);
delimiter;

select fieldid into @fieldid from ld_field where tabid = @tabid and fieldname = 'smcreatorid';
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'zh','ld_field',@tabid,@fieldid,'创建人'
from dual where not EXISTS(select 1 from ld_tranlabel  where languagetype = 'zh'
and trantable ='ld_field' and tabid = @tabid and relateid=@fieldid);
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'en','ld_field',@tabid,@fieldid,'Smcreatorid'
from dual where not EXISTS(select 1 from ld_tranlabel  where languagetype = 'en'
and trantable ='ld_field' and tabid = @tabid and relateid=@fieldid);
delimiter;

select fieldid into @fieldid from ld_field where tabid = @tabid and fieldname = 'approveby';
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'zh','ld_field',@tabid,@fieldid,'审批人'
from dual where not EXISTS(select 1 from ld_tranlabel  where languagetype = 'zh'
and trantable ='ld_field' and tabid = @tabid and relateid=@fieldid);
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'en','ld_field',@tabid,@fieldid,'Approver'
from dual where not EXISTS(select 1 from ld_tranlabel  where languagetype = 'en'
and trantable ='ld_field' and tabid = @tabid and relateid=@fieldid);
delimiter;

select fieldid into @fieldid from ld_field where tabid = @tabid and fieldname = 'approvestatus';
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'zh','ld_field',@tabid,@fieldid,'审批状态'
from dual where not EXISTS(select 1 from ld_tranlabel  where languagetype = 'zh'
and trantable ='ld_field' and tabid = @tabid and relateid=@fieldid);
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'en','ld_field',@tabid,@fieldid,'Approve Status'
from dual where not EXISTS(select 1 from ld_tranlabel  where languagetype = 'en'
and trantable ='ld_field' and tabid = @tabid and relateid=@fieldid);
delimiter;

CREATE TABLE IF NOT EXISTS `ld_satisfaction` (
  `satisfactionid` int(19) NOT NULL AUTO_INCREMENT,
  `satisfaction` varchar(200) NOT NULL,
  `presence` int(1) default 1,
  `picklist_valueid` int(11) NOT NULL,
  PRIMARY KEY (`satisfactionid`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
delimiter;

CREATE TABLE IF NOT EXISTS `ld_satisfaction_seq` (
  `id` int(19) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
delimiter;
select max(id) into @id from ld_picklistvalues_seq;

delete from ld_satisfaction;
insert into ld_satisfaction(satisfaction,presence,picklist_valueid)
select '100%',1,@id+1;
insert into ld_satisfaction(satisfaction,presence,picklist_valueid)
select '90%',1,@id+2;
insert into ld_satisfaction(satisfaction,presence,picklist_valueid)
select '80%',1,@id+3;
insert into ld_satisfaction(satisfaction,presence,picklist_valueid)
select '70%',1,@id+4;
insert into ld_satisfaction(satisfaction,presence,picklist_valueid)
select '60%',1,@id+5;
insert into ld_satisfaction(satisfaction,presence,picklist_valueid)
select '50%',1,@id+6;
insert into ld_satisfaction(satisfaction,presence,picklist_valueid)
select '40%',1,@id+7;
insert into ld_satisfaction(satisfaction,presence,picklist_valueid)
select '30%',1,@id+8;
insert into ld_satisfaction(satisfaction,presence,picklist_valueid)
select '20%',1,@id+9;
insert into ld_satisfaction(satisfaction,presence,picklist_valueid)
select '10%',1,@id+10;
delimiter;

update ld_picklistvalues_seq set id = (select max(picklist_valueid) from ld_satisfaction);
delimiter;

CREATE TABLE IF NOT EXISTS `ld_timelyrate` (
  `timelyrateid` int(19) NOT NULL AUTO_INCREMENT,
  `timelyrate` varchar(200) NOT NULL,
  `presence` int(1) default 1,
  `picklist_valueid` int(11) NOT NULL,
  PRIMARY KEY (`timelyrateid`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
delimiter;

CREATE TABLE IF NOT EXISTS `ld_timelyrate_seq` (
  `id` int(19) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
delimiter;
select max(id) into @id from ld_picklistvalues_seq;

delete from ld_timelyrate;
insert into ld_timelyrate(timelyrate,presence,picklist_valueid)
select '100%',1,@id+1;
insert into ld_timelyrate(timelyrate,presence,picklist_valueid)
select '90%',1,@id+2;
insert into ld_timelyrate(timelyrate,presence,picklist_valueid)
select '80%',1,@id+3;
insert into ld_timelyrate(timelyrate,presence,picklist_valueid)
select '70%',1,@id+4;
insert into ld_timelyrate(timelyrate,presence,picklist_valueid)
select '60%',1,@id+5;
insert into ld_timelyrate(timelyrate,presence,picklist_valueid)
select '50%',1,@id+6;
insert into ld_timelyrate(timelyrate,presence,picklist_valueid)
select '40%',1,@id+7;
insert into ld_timelyrate(timelyrate,presence,picklist_valueid)
select '30%',1,@id+8;
insert into ld_timelyrate(timelyrate,presence,picklist_valueid)
select '20%',1,@id+9;
insert into ld_timelyrate(timelyrate,presence,picklist_valueid)
select '10%',1,@id+10;
delimiter;

update ld_picklistvalues_seq set id = (select max(picklist_valueid) from ld_timelyrate);
delimiter;

CREATE TABLE IF NOT EXISTS `ld_resolutionrate` (
  `resolutionrateid` int(19) NOT NULL AUTO_INCREMENT,
  `resolutionrate` varchar(200) NOT NULL,
  `presence` int(1) default 1,
  `picklist_valueid` int(11) NOT NULL,
  PRIMARY KEY (`resolutionrateid`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
delimiter;

CREATE TABLE IF NOT EXISTS `ld_resolutionrate_seq` (
  `id` int(19) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
delimiter;

select max(id) into @id from ld_picklistvalues_seq;

delete from ld_resolutionrate;
insert into ld_resolutionrate(resolutionrate,presence,picklist_valueid)
select '100%',1,@id+1;
insert into ld_resolutionrate(resolutionrate,presence,picklist_valueid)
select '90%',1,@id+2;
insert into ld_resolutionrate(resolutionrate,presence,picklist_valueid)
select '80%',1,@id+3;
insert into ld_resolutionrate(resolutionrate,presence,picklist_valueid)
select '70%',1,@id+4;
insert into ld_resolutionrate(resolutionrate,presence,picklist_valueid)
select '60%',1,@id+5;
insert into ld_resolutionrate(resolutionrate,presence,picklist_valueid)
select '50%',1,@id+6;
insert into ld_resolutionrate(resolutionrate,presence,picklist_valueid)
select '40%',1,@id+7;
insert into ld_resolutionrate(resolutionrate,presence,picklist_valueid)
select '30%',1,@id+8;
insert into ld_resolutionrate(resolutionrate,presence,picklist_valueid)
select '20%',1,@id+9;
insert into ld_resolutionrate(resolutionrate,presence,picklist_valueid)
select '10%',1,@id+10;
delimiter;

update ld_picklistvalues_seq set id = (select max(picklist_valueid) from ld_resolutionrate);
delimiter;

CREATE TABLE IF NOT EXISTS `ld_servant_come` (
  `servant_comeid` int(19) NOT NULL AUTO_INCREMENT,
  `servant_come` varchar(200) NOT NULL,
  `presence` int(1) default 1,
  `picklist_valueid` int(11) NOT NULL,
  PRIMARY KEY (`servant_comeid`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
delimiter;

CREATE TABLE IF NOT EXISTS `ld_servant_come_seq` (
  `id` int(19) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
delimiter;

select max(id) into @id from ld_picklistvalues_seq;

delete from ld_servant_come;
insert into ld_servant_come(servant_come,presence,picklist_valueid)
select '是',1,@id+1;
insert into ld_servant_come(servant_come,presence,picklist_valueid)
select '否',1,@id+2;
delimiter;

update ld_picklistvalues_seq set id = (select max(servant_comeid) from ld_servant_come);
delimiter;

select id into @id from ld_picklist_seq;
insert into ld_picklist(picklistid,name)
select @id + 1,'satisfaction' from dual where not exists(select 1 from ld_picklist where name = 'satisfaction');
insert into ld_picklist(picklistid,name)
select @id + 2,'timelyrate' from dual where not exists(select 1 from ld_picklist where name = 'timelyrate');
insert into ld_picklist(picklistid,name)
select @id + 3,'resolutionrate' from dual where not exists(select 1 from ld_picklist where name = 'resolutionrate');
insert into ld_picklist(picklistid,name)
select @id + 4,'servant_come' from dual where not exists(select 1 from ld_picklist where name = 'servant_come');
update ld_picklist_seq set id = (select max(picklistid) from ld_picklist);
delimiter;

select max(sequence)+1 into @sequence from ld_systems_deploy;
insert into ld_systems_deploy(deploy_value,deploy_type,description,setype,sequence,roottype,inputtype,inputvalue,presence)
select 0,100,'服务回访单是否启用审批流程。1:否，0:是','ServiceReturn',@sequence,2,'select','[{"value":"0","text":"YES"},{"value":"1","text":"NO"},{"sql":""}]',0
from dual where not EXISTS(select 1 from ld_systems_deploy where deploy_type=100);
delimiter;

select tabid into @tabid from ld_tab where name='ServiceReturn';
insert into ld_approve(id,tabid,name,status,smcreatorid,modifiedby,createdtime,modifiedtime,approveallocatetype)
select (select max(id) from ld_approve)+1,@tabid,'回访单默认流程',0,1,1,NOW(),NOW(),0
from dual where not EXISTS(select 1 from ld_approve where tabid=@tabid and name='回访单默认流程');
delimiter;

select id into @id from ld_approve where tabid=@tabid and name='回访单默认流程';
insert into ld_approvestep(id,approveid,name,ended,step,sequence,createdtime,modifiedtime,approvetype,approvevalue,specifyapproverid)
select (select max(id) from ld_approvestep)+1,@id,'步骤一',1,1,1,NOW(),NOW(),0,1,1
from dual where not EXISTS(select 1 from ld_approvestep where approveid=@id and name='步骤一');
delimiter;

insert into ld_approvestep(id,approveid,name,ended,step,sequence,createdtime,modifiedtime,approvetype,approvevalue,specifyapproverid)
select (select max(id) from ld_approvestep)+1,@id,'步骤二',1,1,2,NOW(),NOW(),0,1,1
from dual where not EXISTS(select 1 from ld_approvestep where approveid=@id and name='步骤二');
delimiter;

update ld_approve_seq set id=(select max(id) from ld_approve);
delimiter;
update ld_approvestep_seq set id=(select max(id) from ld_approvestep);
delimiter;

insert into ld_approve2user(approveid,userid)
select @id,-1 from dual
where not EXISTS(select 1 from ld_approve2user where approveid=@id and userid=-1);
delimiter;

select tabid into @tabid from ld_tab where `name` = 'ServiceReturn';
insert into ld_entityname(tabid,modulename,tablename,fieldname,entityidfield,entityidcolumn)
select @tabid,'ServiceReturn','ld_servicereturn','servicereturn_no','servicereturnid','servicereturnid'
from dual where not EXISTS(select 1 from ld_entityname  where tabid = @tabid
and modulename ='ServiceReturn');
delimiter;

insert into ld_modentity_num(num_id,semodule,prefix,start_id,cur_id,active,datetype)
select (select max(num_id)+1 from ld_modentity_num),'ServiceReturn','HF',1,1,1,'none'
from dual where not EXISTS(select 1 from ld_modentity_num  where semodule = 'ServiceReturn'
and prefix ='HF');
delimiter;

update ld_modentity_num_seq set id = (select max(num_id)+1 from ld_modentity_num);
delimiter;

insert into ld_customview(cvid,viewname,setdefault,setmetrics,entitytype,status,userid,sequence,pagewidthpercent,customcategory)
select (select max(cvid)+1 from ld_customview),'All',1,0,'ServiceReturn',3,1,0,100,NULL
from dual where not EXISTS(select 1 from ld_customview  where entitytype = 'ServiceReturn' and viewname ='All');
delimiter;

select cvid into @cvid from ld_customview where entitytype = 'ServiceReturn' and viewname = 'All';
delete from ld_cvcolumnlist where cvid = @cvid;
insert into ld_cvcolumnlist(cvid,columnindex,columnname)
values(@cvid,0,'ld_servicereturn:servicereturn_no:servicereturn_no:ServiceReturn_fieldlabel:V');
delimiter;

insert into ld_cvcolumnlist(cvid,columnindex,columnname)
values(@cvid,1,'ld_servicereturn:account_id:account_id:ServiceReturn_fieldlabel:V');
delimiter;

insert into ld_cvcolumnlist(cvid,columnindex,columnname)
values(@cvid,2,'ld_servicereturn:contact_id:contact_id:ServiceReturn_fieldlabel:V');
delimiter;

insert into ld_cvcolumnlist(cvid,columnindex,columnname)
values(@cvid,3,'ld_servicereturn:troubleticketid:troubleticketid:ServiceReturn_fieldlabel:V');
delimiter;

insert into ld_cvcolumnlist(cvid,columnindex,columnname)
values(@cvid,4,'ld_servicereturn:smownerid:assigned_user_id:ServiceReturn_fieldlabel:V');
delimiter;

insert into ld_cvcolumnlist(cvid,columnindex,columnname)
values(@cvid,5,'ld_servicereturn:approveby:approveby:ServiceReturn_fieldlabel:V');
delimiter;

insert into ld_cvcolumnlist(cvid,columnindex,columnname)
values(@cvid,6,'ld_servicereturn:approvestatus:approvestatus:ServiceReturn_fieldlabel:V');
delimiter;

select tabid into @tabid from ld_tab where `name` = 'ServiceReturn';
insert into ld_profileallpermission(tabid,operation)
select @tabid,4 from dual where not exists(select 1 from ld_profileallpermission where tabid = @tabid and operation=4);
insert into ld_profileallpermission(tabid,operation)
select @tabid,3 from dual where not exists(select 1 from ld_profileallpermission where tabid = @tabid and operation=3);
insert into ld_profileallpermission(tabid,operation)
select @tabid,1 from dual where not exists(select 1 from ld_profileallpermission where tabid = @tabid and operation=1);
insert into ld_profileallpermission(tabid,operation)
select @tabid,2 from dual where not exists(select 1 from ld_profileallpermission where tabid = @tabid and operation=2);
insert into ld_profileallpermission(tabid,operation)
select @tabid,12 from dual where not exists(select 1 from ld_profileallpermission where tabid = @tabid and operation=12);
insert into ld_profileallpermission(tabid,operation)
select @tabid,13 from dual where not exists(select 1 from ld_profileallpermission where tabid = @tabid and operation=13);
insert into ld_profileallpermission(tabid,operation)
select @tabid,14 from dual where not exists(select 1 from ld_profileallpermission where tabid = @tabid and operation=14);
insert into ld_profileallpermission(tabid,operation)
select @tabid,5 from dual where not exists(select 1 from ld_profileallpermission where tabid = @tabid and operation=5);
insert into ld_profileallpermission(tabid,operation)
select @tabid,6 from dual where not exists(select 1 from ld_profileallpermission where tabid = @tabid and operation=6);
insert into ld_profileallpermission(tabid,operation)
select @tabid,25 from dual where not exists(select 1 from ld_profileallpermission where tabid = @tabid and operation=25);
delimiter;

SELECT tabid INTO @tabid FROM ld_tab WHERE `name`='HelpDesk';
SELECT tabid INTO @srtabid FROM ld_tab WHERE `name`='ServiceReturn';
SELECT max(relation_id) INTO @relation_id FROM ld_relatedlists;
INSERT INTO  ld_relatedlists(relation_id,tabid,related_tabid,NAME,sequence,label,presence,actions,mobile_presence,mobile_sequence)
SELECT @relation_id+1,@tabid,@srtabid,'get_servicereturn',1,'ServiceReturn',0,'SELECT',1,1
FROM DUAL WHERE NOT EXISTS(SELECT 1 FROM ld_relatedlists WHERE tabid=@tabid AND NAME='get_servicereturn');
delimiter;

SELECT tabid INTO @tabid FROM ld_tab WHERE `name`='Accounts';
SELECT max(relation_id) INTO @relation_id FROM ld_relatedlists;
INSERT INTO  ld_relatedlists(relation_id,tabid,related_tabid,NAME,sequence,label,presence,actions,mobile_presence,mobile_sequence)
SELECT @relation_id+1,@tabid,@srtabid,'get_servicereturn',1,'ServiceReturn',0,'SELECT',1,1
FROM DUAL WHERE NOT EXISTS(SELECT 1 FROM ld_relatedlists WHERE tabid=@tabid AND NAME='get_servicereturn');
delimiter;

SELECT tabid INTO @tabid FROM ld_tab WHERE `name`='ProjectTask';
SELECT max(relation_id) INTO @relation_id FROM ld_relatedlists;
INSERT INTO  ld_relatedlists(relation_id,tabid,related_tabid,NAME,sequence,label,presence,actions,mobile_presence,mobile_sequence)
SELECT @relation_id+1,@tabid,@srtabid,'get_servicereturn',1,'ServiceReturn',0,'SELECT',1,1
FROM DUAL WHERE NOT EXISTS(SELECT 1 FROM ld_relatedlists WHERE tabid=@tabid AND NAME='get_servicereturn');
delimiter;

SELECT tabid INTO @tabid FROM ld_tab WHERE `name`='ServiceReturn';
SELECT max(relation_id) INTO @relation_id FROM ld_relatedlists;
INSERT INTO  ld_relatedlists(relation_id,tabid,related_tabid,NAME,sequence,label,presence,actions,mobile_presence,mobile_sequence)
SELECT @relation_id+1,@tabid,78,'get_attachment',3,'Attachment',0,'add',1,1
FROM DUAL WHERE NOT EXISTS(SELECT 1 FROM ld_relatedlists WHERE tabid=@tabid AND NAME='get_attachment');
delimiter;

SELECT tabid INTO @tabid FROM ld_tab WHERE `name`='ServiceReturn';
SELECT max(relation_id) INTO @relation_id FROM ld_quickactions;
INSERT INTO  ld_quickactions(relation_id,tabid,related_tabid,sequence,presence,label)
SELECT @relation_id+1,@tabid,55,1,0,''
FROM DUAL WHERE NOT EXISTS(SELECT 1 FROM ld_quickactions WHERE tabid=@tabid AND related_tabid=55);
delimiter;
SELECT max(relation_id) INTO @relation_id FROM ld_quickactions;
INSERT INTO  ld_quickactions(relation_id,tabid,related_tabid,sequence,presence,label)
SELECT @relation_id+1,@tabid,78,2,0,''
FROM DUAL WHERE NOT EXISTS(SELECT 1 FROM ld_quickactions WHERE tabid=@tabid AND related_tabid=78);
delimiter;
SELECT MAX(relation_id) into @relation_id from ld_quickactions;
INSERT into ld_quickactions(relation_id,tabid,related_tabid,sequence,presence,label)
SELECT @relation_id+1,@tabid,-1,3,0,'' FROM dual where not exists
(SELECT 1 from ld_quickactions WHERE tabid=@tabid and related_tabid=-1);
delimiter;
SELECT MAX(relation_id) into @relation_id from ld_quickactions;
INSERT into ld_quickactions(relation_id,tabid,related_tabid,sequence,presence,label)
SELECT @relation_id+1,@tabid,-10,4,0,'' FROM dual where not exists
(SELECT 1 from ld_quickactions WHERE tabid=@tabid and related_tabid=-10);
delimiter;

SELECT tabid INTO @stabid FROM ld_tab WHERE `name`='ServiceReturn';
SELECT tabid INTO @tabid FROM ld_tab WHERE `name`='HelpDesk';
SELECT max(relation_id) INTO @relation_id FROM ld_quickactions;
INSERT INTO  ld_quickactions(relation_id,tabid,related_tabid,sequence,presence,label)
SELECT @relation_id+1,@tabid,@stabid,7,0,''
FROM DUAL WHERE NOT EXISTS(SELECT 1 FROM ld_quickactions WHERE tabid=@tabid AND related_tabid=@stabid);
delimiter;

SELECT tabid INTO @tabid FROM ld_tab WHERE `name`='ProjectTask';
SELECT max(relation_id) INTO @relation_id FROM ld_quickactions;
INSERT INTO ld_quickactions(relation_id,tabid,related_tabid,sequence,presence,label)
SELECT @relation_id+1,@tabid,@stabid,2,0,''
FROM DUAL WHERE NOT EXISTS(SELECT 1 FROM ld_quickactions WHERE tabid=@tabid AND related_tabid=@stabid);
delimiter;

INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','How_to_create_return','如何创建{$ServiceReturn.ServiceReturn}','fixedstr'
from dual where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='How_to_create_return');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','How_to_create_return','How to create a {$ServiceReturn.ServiceReturn}','fixedstr'
from dual where not exists(select 1 from ld_desk where languagetype='en' and labelbol='How_to_create_return');
delimiter;

INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','How_to_create_return1','{$ServiceReturn.ServiceReturn}是针对{$HelpDesk.HelpDesk}或{$ProjectTask.ProjectTask}的，不允许直接新增','fixedstr'
from dual where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='How_to_create_return1');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','How_to_create_return1','{$ServiceReturn.ServiceReturn} is for the {$HelpDesk.HelpDesk} or {$ProjectTask.ProjectTask}, direct creation is not allowed','fixedstr'
from dual where not exists(select 1 from ld_desk where languagetype='en' and labelbol='How_to_create_return1');
delimiter;

INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','How_to_create_return2','可通过{$Accounts.Accounts}、{$HelpDesk.HelpDesk}或{$ProjectTask.ProjectTask}查看明细界面，关联创建{$ServiceReturn.ServiceReturn}增加。','fixedstr'
from dual where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='How_to_create_return2');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','How_to_create_return2','Through the {$Accounts.Accounts},{$HelpDesk.HelpDesk} , or {$ProjectTask.ProjectTask} view detail interface, associated to create a single {$ServiceReturn.ServiceReturn} visit.','fixedstr'
from dual where not exists(select 1 from ld_desk where languagetype='en' and labelbol='How_to_create_return2');
delimiter;

INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','HAVECREATEDSERVICERETURN','该单据已经创建{$ServiceReturn.ServiceReturn}','jspop'
from dual where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='HAVECREATEDSERVICERETURN');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','HAVECREATEDSERVICERETURN','The bill has created a {$ServiceReturn.ServiceReturn}','jspop'
from dual where not exists(select 1 from ld_desk where languagetype='en' and labelbol='HAVECREATEDSERVICERETURN');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','DISTRIBUTECHANGESERVANT','分配（更改服务人员）','jspop' from dual
where not exists(select 1 from ld_desk where labelbol = 'DISTRIBUTECHANGESERVANT' and languagetype = 'zh' and labeltype = 'jspop');
delimiter;
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','DISTRIBUTECHANGESERVANT','Distribute（Change Servant）','jspop' from dual
where not exists(select 1 from ld_desk where labelbol = 'DISTRIBUTECHANGESERVANT' and languagetype = 'en' and labeltype = 'jspop');
delimiter;

select tabid into @tabid from ld_tab where `name` = 'ServiceReturn';
select fieldid into @fieldid from ld_field where tabid = @tabid and columnname = 'servicereturn_no';
insert into ld_relatedlists_lable(tabid,fieldid,width,sequence,presence,edit)
select @tabid,@fieldid,0,1,1,0 from DUAL
where not exists(select 1 from ld_relatedlists_lable where tabid = @tabid and fieldid = @fieldid);
select fieldid into @fieldid from ld_field where tabid = @tabid and columnname = 'accountid';
insert into ld_relatedlists_lable(tabid,fieldid,width,sequence,presence,edit)
select @tabid,@fieldid,0,2,1,0 from DUAL
where not exists(select 1 from ld_relatedlists_lable where tabid = @tabid and fieldid = @fieldid);
select fieldid into @fieldid from ld_field where tabid = @tabid and columnname = 'contactid';
insert into ld_relatedlists_lable(tabid,fieldid,width,sequence,presence,edit)
select @tabid,@fieldid,0,3,1,0 from DUAL
where not exists(select 1 from ld_relatedlists_lable where tabid = @tabid and fieldid = @fieldid);
select fieldid into @fieldid from ld_field where tabid = @tabid and columnname = 'smownerid';
insert into ld_relatedlists_lable(tabid,fieldid,width,sequence,presence,edit)
select @tabid,@fieldid,0,4,1,0 from DUAL
where not exists(select 1 from ld_relatedlists_lable where tabid = @tabid and fieldid = @fieldid);
delimiter;

call fieldprofile('ServiceReturn');
delimiter;
call getallprofile('ServiceReturn');
delimiter;

update ld_field set displaytype=2 where tabid=(select tabid from ld_tab where `name`='ServiceReturn') and columnname in ('approvestatus','approveby');
update ld_relatedlists set actions=NULL where `name`='get_servicereturn';

update ld_desk set fieldlabel='可通过{$HelpDesk.HelpDesk}或{$ProjectTask.ProjectTask}查看明细界面,关联创建{$ServiceReturn.ServiceReturn}。' where languagetype='zh' and labelbol='How_to_create_return2';
update ld_desk set fieldlabel='Through the {$HelpDesk.HelpDesk} or {$ProjectTask.ProjectTask} view detail interface, associated to create a single {$ServiceReturn.ServiceReturn}.' where languagetype='en' and labelbol='How_to_create_return2';


insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'zh','TIMESHEETDETAIL','工时详细信息','fixedstr' from dual 
where not EXISTS(select 1 from ld_desk  where languagetype='zh' and labelbol='TIMESHEETDETAIL' and Labeltype='fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'en','TIMESHEETDETAIL','TimeSheet detail','fixedstr' from dual 
where not EXISTS(select 1 from ld_desk  where languagetype='en' and labelbol='TIMESHEETDETAIL' and Labeltype='fixedstr');
delimiter;

update ld_desk set fieldlabel='详细' where labelbol='DETAIL' AND languagetype='zh' AND fieldlabel='工时详细信息';
update ld_desk set fieldlabel='Detail' where labelbol='DETAIL' AND languagetype='en' AND fieldlabel='TimeSheet detail';
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'zh','TIMESHEETDETAIL','工时详细信息','fixedstr' from dual 
where not EXISTS(select 1 from ld_desk  where languagetype='zh' and labelbol='TIMESHEETDETAIL' and Labeltype='fixedstr');

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'en','TIMESHEETDETAIL','TimeSheet detail','fixedstr' from dual 
where not EXISTS(select 1 from ld_desk  where languagetype='en' and labelbol='TIMESHEETDETAIL' and Labeltype='fixedstr');
delimiter;

update ld_relatedlists set actions=null where `name`='get_SendPayment';
update ld_relatedlists set actions=null where `name`='get_paymentplan';
delimiter;
-- 2015-05-11


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
delimiter;

update ld_version set old_version='V6.3.1' ,current_version='V6.3.1' ,remark='V6.3.1-20160511';
delimiter;