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
select block into @block from ld_field where tabid=@tabid and columnname='ratename';
select sequence into @seq from ld_field where tabid=@tabid and columnname='enddate';

update ld_field set sequence=sequence+1 where tabid=@tabid and sequence>@seq and block=@block;
update ld_field set sequence=@seq+1,block=@block where tabid=@tabid and columnname='strrole_id';

set @i=0;
update ld_field set sequence=(@i:=@i+1) where tabid=@tabid and block=@block order by sequence;
delimiter;

select tabid into @tabid from ld_tab where `name`='TimeSheet';
delete from ld_tabdetailfield where tabid=@tabid and columnname='project_id';
delimiter;
-- 2016-06-02

ALTER TABLE ld_project ALTER COLUMN hascost set DEFAULT '0.00';
delimiter;
ALTER TABLE ld_project ALTER COLUMN hastime set DEFAULT '0.00';
delimiter;
ALTER TABLE ld_projecttask ALTER COLUMN hascost set DEFAULT '0.00';
delimiter;
ALTER TABLE ld_projecttask ALTER COLUMN hastime set DEFAULT '0.00';
delimiter;

update ld_project set hascost='0.00' where hascost IS null;
delimiter;

update ld_project set hastime='0.00' where hastime IS null;
delimiter;

update ld_projecttask set hascost='0.00' where hascost IS null;
delimiter;

update ld_projecttask set hastime='0.00' where hastime IS null;
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,Labeltype)
select 'en','Synchronizedsuccess','同步成功','jspop' from dual 
where not EXISTS(select 1 from ld_desk where languagetype = 'en' and labelbol = 'Synchronizedsuccess' and labeltype = 'jspop');

insert into ld_desk(languagetype,labelbol,fieldlabel,Labeltype)
select 'zh','Synchronizedsuccess','同步成功','jspop' from dual 
where not EXISTS(select 1 from ld_desk where languagetype = 'zh' and labelbol = 'Synchronizedsuccess' and labeltype = 'jspop');
delimiter;

call AddColumn('ld_troubletickets','bw8_datetime','datetime','',NULL);
delimiter;

select tabid into @tabid from ld_tab where `name` = 'ServiceContracts';
SELECT fieldid into @fieldid from ld_field where tabid=@tabid AND columnname='contract_type';
update ld_tranlabel SET fieldlabel='合同类型' where fieldlabel = '类型' and Relateid=@fieldid AND tabid=@tabid AND languagetype='zh';
SELECT fieldid into @fieldid from ld_field where tabid=@tabid AND columnname='contract_status';
update ld_tranlabel SET fieldlabel='合同状态' where fieldlabel = '状态' and Relateid=@fieldid AND tabid=@tabid AND languagetype='zh';
delimiter;

insert into ld_desk (languagetype,labelbol,fieldlabel,labeltype)
select  'zh','SERVICECONTRACTSUPDATE','更改{$ServiceContracts.contract_status}','fixedstr' from DUAL
where not exists(select 1 from ld_desk where labelbol='SERVICECONTRACTSUPDATE' and languagetype='zh' and labeltype='fixedstr');
delimiter;

insert into ld_desk (languagetype,labelbol,fieldlabel,labeltype)
select  'en','SERVICECONTRACTSUPDATE','Update{$ServiceContracts.contract_status}','fixedstr' from DUAL
where not exists(select 1 from ld_desk where labelbol='SERVICECONTRACTSUPDATE' and languagetype='en' and labeltype='fixedstr');
delimiter;

insert into ld_desk (languagetype,labelbol,fieldlabel,labeltype)
select  'zh','PURCHASEORDERUPDATE','更改{$PurchaseOrder.postatus}','fixedstr' from DUAL
where not exists(select 1 from ld_desk where labelbol='PURCHASEORDERUPDATE' and languagetype='zh' and labeltype='fixedstr');
delimiter;

insert into ld_desk (languagetype,labelbol,fieldlabel,labeltype)
select  'en','PURCHASEORDERUPDATE','Update{$PurchaseOrder.postatus}','fixedstr' from DUAL
where not exists(select 1 from ld_desk where labelbol='PURCHASEORDERUPDATE' and languagetype='en' and labeltype='fixedstr');
delimiter;

insert into ld_desk (languagetype,labelbol,fieldlabel,labeltype)
select  'zh','UPDATEPROJECTASKSTATUS','更改{$ProjectTask.projecttaskstatus}','fixedstr' from DUAL
where not exists(select 1 from ld_desk where labelbol='UPDATEPROJECTASKSTATUS' and languagetype='zh' and labeltype='fixedstr');
delimiter;

insert into ld_desk (languagetype,labelbol,fieldlabel,labeltype)
select  'en','UPDATEPROJECTASKSTATUS','Update {$ProjectTask.projecttaskstatus}','fixedstr' from DUAL
where not exists(select 1 from ld_desk where labelbol='UPDATEPROJECTASKSTATUS' and languagetype='en' and labeltype='fixedstr');
delimiter;
insert into ld_desk (languagetype,labelbol,fieldlabel,labeltype)
select  'zh','INVOICEUPDATE','更改{$Invoice.invoicestatus}','fixedstr' from DUAL
where not exists(select 1 from ld_desk where labelbol='INVOICEUPDATE' and languagetype='zh' and labeltype='fixedstr');
delimiter;

insert into ld_desk (languagetype,labelbol,fieldlabel,labeltype)
select  'en','INVOICEUPDATE','Update{$Invoice.invoicestatus}','fixedstr' from DUAL
where not exists(select 1 from ld_desk where labelbol='INVOICEUPDATE' and languagetype='en' and labeltype='fixedstr');
delimiter;

insert into ld_desk (languagetype,labelbol,fieldlabel,labeltype)
select  'zh','PURCHASEINVOICEUPDATE','更改{$PurchaseInvoice.purchaseinvoicestatus}','fixedstr' from DUAL
where not exists(select 1 from ld_desk where labelbol='PURCHASEINVOICEUPDATE' and languagetype='zh' and labeltype='fixedstr');
delimiter;

insert into ld_desk (languagetype,labelbol,fieldlabel,labeltype)
select  'en','PURCHASEINVOICEUPDATE','Update{$PurchaseInvoice.purchaseinvoicestatus}','fixedstr' from DUAL
where not exists(select 1 from ld_desk where labelbol='PURCHASEINVOICEUPDATE' and languagetype='en' and labeltype='fixedstr');
delimiter;

alter table ld_users alter column is_admin set default 'off';
update ld_users set is_admin='off' where is_admin='' or is_admin is null;
delimiter;
-- 2016-06-03

DROP PROCEDURE IF EXISTS `altercolumn`;
delimiter ||
CREATE PROCEDURE `altercolumn`(
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

CALL altercolumn('ld_jiuweiak_phonerecord','contactid','modulename','VARCHAR(100)');
delimiter;
CALL altercolumn('ld_jiuweiak_phonerecord','accountid','indexid','INT(11)');
delimiter;
-- 2016-06-06

DROP PROCEDURE IF EXISTS `update_tranlabel`;
delimiter ||
CREATE  PROCEDURE `update_tranlabel`(
	tmp_modulename VARCHAR(50),
	tmp_type VARCHAR(50),
	tmp_columnname VARCHAR(100),
	tmp_zh VARCHAR(200),
	tmp_en VARCHAR(200)
)
BEGIN
		
		set @tabid=0;
		set @Relateid=0;

		select tabid into @tabid from ld_tab where `name`=tmp_modulename;
		
		IF tmp_type='ld_field' Then
				select fieldid into @Relateid from ld_field where tabid=@tabid and columnname=tmp_columnname;
				update ld_field set fieldlabel=tmp_zh where tabid=@tabid and fieldid=@Relateid;
				update ld_tranlabel set fieldlabel=tmp_zh where trantable=tmp_type and languagetype='zh' and tabid=@tabid and Relateid=@Relateid;
				update ld_tranlabel set fieldlabel=tmp_en where trantable=tmp_type and languagetype='en' and tabid=@tabid and Relateid=@Relateid;
		ELSEIF tmp_type='ld_producttoolfield' Then
				select producttoolfieldid into @Relateid from ld_producttoolfield where tabid=@tabid and columnname=tmp_columnname;
				update ld_producttoolfield set fieldlabel=tmp_zh where tabid=@tabid and producttoolfieldid=@Relateid;
				update ld_tranlabel set fieldlabel=tmp_zh where trantable=tmp_type and languagetype='zh' and tabid=@tabid and Relateid=@Relateid;
				update ld_tranlabel set fieldlabel=tmp_en where trantable=tmp_type and languagetype='en' and tabid=@tabid and Relateid=@Relateid;
		ELSEIF tmp_type='ld_tab' Then
				update ld_tranlabel set fieldlabel=tmp_zh where trantable=tmp_type and languagetype='zh' and tabid=@tabid and Relateid=@tabid;
				update ld_tranlabel set fieldlabel=tmp_en where trantable=tmp_type and languagetype='en' and tabid=@tabid and Relateid=@tabid;
		ELSEIF tmp_type='ld_parenttab' Then
				select parenttabid into @Relateid from ld_parenttab where parenttab_label=tmp_columnname;
				update ld_tranlabel set fieldlabel=tmp_zh where trantable=tmp_type and languagetype='zh' and Relateid=@Relateid;
				update ld_tranlabel set fieldlabel=tmp_en where trantable=tmp_type and languagetype='en' and Relateid=@Relateid;
		ELSEIF tmp_type='ld_blocks' Then
				select blockid into @Relateid from ld_blocks where tabid=@tabid and blocklabel=tmp_columnname;
				update ld_tranlabel set fieldlabel=tmp_zh where trantable=tmp_type and languagetype='zh' and tabid=@tabid and Relateid=@Relateid;
				update ld_tranlabel set fieldlabel=tmp_en where trantable=tmp_type and languagetype='en' and tabid=@tabid and Relateid=@Relateid;
		END IF;
		
end ||
delimiter;

update ld_desk set fieldlabel = 'Synchronized success' where labelbol = 'Synchronizedsuccess' and languagetype = 'en' and Labeltype = 'jspop';
delimiter;

update ld_desk set Fieldlabel='设置显示列字段' where labelbol='SETUPCOLUMNHEADER' and languagetype='zh' and Labeltype = 'fixedstr';
update ld_desk set Fieldlabel='Set column' where labelbol='SETUPCOLUMNHEADER' and languagetype='en' and Labeltype = 'fixedstr';
delimiter;
-- 2016-06-12

update ld_settings_field set linkto='index.php?module=Settings&action=showDocTemplateindex' where name='THEDOCUMENTTEMPLATE';
delimiter;
-- 2016-06-21

select max(tabid) into @tabid from ld_tab;
insert into ld_tab(tabid,name,presence,tabsequence,tablabel,customized,ownedby,isentitytype,parent,printtab)
select @tabid+1,'mobileProject',1,50,'mobileProject',0,0,1,'Finacial',1 from dual where not exists(select 1 from ld_tab where name='mobileProject');
select MAX(cvid) into @maxid  from ld_customview;
update ld_customview_seq set id=@maxid+1 where not EXISTS(select 1 from ld_customview where viewname='mobileProject' and entitytype='mobileProject');
insert into ld_customview(cvid,viewname,setdefault,setmetrics,entitytype,status,userid,sequence,pagewidthpercent)select @maxid+1,'mobileProject',0,0,'mobileProject',0,1,1,100 
from dual where not EXISTS(select 1 from ld_customview where viewname='mobileProject' and entitytype='mobileProject');
select cvid into @cvid   from ld_customview where viewname='mobileProject' and entitytype='mobileProject';
delete from ld_cvcolumnlist where cvid=(select cvid from ld_customview where viewname='mobileProject' and entitytype='mobileProject' );
insert into ld_cvcolumnlist (cvid,columnindex,columnname) values(@cvid,0,'ld_project:project_no:project_no:Project_fieldlabel:V' );
insert into ld_cvcolumnlist (cvid,columnindex,columnname) values(@cvid,1,'ld_project:accountid:account_id:Project_fieldlabel:V' );
insert into ld_cvcolumnlist (cvid,columnindex,columnname) values(@cvid,2,'ld_project:targetbudget:targetbudget:Project_fieldlabel:V' );
insert into ld_cvcolumnlist (cvid,columnindex,columnname) values(@cvid,3,'ld_project:smownerid:assigned_user_id:Project_fieldlabel:V' );
insert into ld_cvcolumnlist (cvid,columnindex,columnname) values(@cvid,4,'ld_project:projectstatus:projectstatus:Project_fieldlabel:V' );
delimiter;

select max(tabid) into @tabid from ld_tab;
insert into ld_tab(tabid,name,presence,tabsequence,tablabel,customized,ownedby,isentitytype,parent,printtab)
select @tabid+1,'mobileProjectTask',1,50,'mobileProjectTask',0,0,1,'Finacial',1 from dual where not exists(select 1 from ld_tab where name='mobileProjectTask');
select MAX(cvid) into @maxid  from ld_customview;
update ld_customview_seq set id=@maxid+1 where not EXISTS(select 1 from ld_customview where viewname='mobileProjectTask' and entitytype='mobileProjectTask');
insert into ld_customview(cvid,viewname,setdefault,setmetrics,entitytype,status,userid,sequence,pagewidthpercent)select @maxid+1,'mobileProjectTask',0,0,'mobileProjectTask',0,1,1,100 
from dual where not EXISTS(select 1 from ld_customview where viewname='mobileProjectTask' and entitytype='mobileProjectTask');
select cvid into @cvid   from ld_customview where viewname='mobileProjectTask' and entitytype='mobileProjectTask';
delete from ld_cvcolumnlist where cvid=(select cvid from ld_customview where viewname='mobileProjectTask' and entitytype='mobileProjectTask' );
insert into ld_cvcolumnlist (cvid,columnindex,columnname) values(@cvid,0,'ld_projecttask:projecttask_no:projecttask_no:ProjectTask_fieldlabel:V' );
insert into ld_cvcolumnlist (cvid,columnindex,columnname) values(@cvid,1,'ld_projecttask:accountid:account_id:ProjectTask_fieldlabel:V' );
insert into ld_cvcolumnlist (cvid,columnindex,columnname) values(@cvid,2,'ld_projecttask:costbudget:costbudget:ProjectTask_fieldlabel:V' );
insert into ld_cvcolumnlist (cvid,columnindex,columnname) values(@cvid,3,'ld_projecttask:smownerid:assigned_user_id:ProjectTask_fieldlabel:V' );
insert into ld_cvcolumnlist (cvid,columnindex,columnname) values(@cvid,4,'ld_projecttask:projecttaskstatus:projecttaskstatus:ProjectTask_fieldlabel:V' );
delimiter;

select tabid into @tabid from ld_tab where name = 'Project';
update ld_relatedlists set mobile_presence =0 where tabid = @tabid and label in ('ContactRecords','ProjectTask','HelpDesk');
delimiter;
select tabid into @tabid from ld_tab where name = 'ProjectTask';
update ld_relatedlists set mobile_presence =0 where tabid = @tabid and label in ('ContactRecords');
delimiter;

select cvid into @cvid from ld_customview where entitytype='DividendOrder' and viewname='All';
delete from ld_cvcolumnlistsort where cvid=@cvid;
insert into ld_cvcolumnlistsort(cvid,columnname,sorttype)
select @cvid,'ld_dividendorder:plandividend_date:plandividend_date:DividendOrder_D~O:fieldlabel','asc';

select cvid into @cvid from ld_customview where entitytype='DividendOrder' and viewname='本月应派';
delete from ld_cvcolumnlistsort where cvid=@cvid;
insert into ld_cvcolumnlistsort(cvid,columnname,sorttype)
select @cvid,'ld_dividendorder:plandividend_date:plandividend_date:DividendOrder_D~O:fieldlabel','asc';

select cvid into @cvid from ld_customview where entitytype='DividendOrder' and viewname='本月已派';
delete from ld_cvcolumnlistsort where cvid=@cvid;
insert into ld_cvcolumnlistsort(cvid,columnname,sorttype)
select @cvid,'ld_dividendorder:plandividend_date:plandividend_date:DividendOrder_D~O:fieldlabel','asc';

select cvid into @cvid from ld_customview where entitytype='DividendOrder' and viewname='本月未派';
delete from ld_cvcolumnlistsort where cvid=@cvid;
insert into ld_cvcolumnlistsort(cvid,columnname,sorttype)
select @cvid,'ld_dividendorder:plandividend_date:plandividend_date:DividendOrder_D~O:fieldlabel','asc';
delimiter;

update ld_field set uitype=602  where tabid=22  and columnname='contactrecordsid';
delimiter;
-- 2016-06-22

insert into ld_ws_fieldtype(uitype,fieldtype) select 602,'reference' from dual 
where not exists(select 1 from ld_ws_fieldtype where uitype=602);

select fieldtypeid into @fieldtypeid from ld_ws_fieldtype where uitype=602;
insert into ld_ws_referencetype(fieldtypeid,type)select @fieldtypeid ,'VendorContactRecords' from DUAL
where not exists(select 1 from ld_ws_referencetype where fieldtypeid=@fieldtypeid and type='VendorContactRecords');
delimiter;

update ld_desk set fieldlabel='帮我吧客服账号' where fieldlabel='客服账号' AND languagetype='zh' AND labelbol='CUSTOMERSERVICEACCOUNT';
update ld_desk set fieldlabel='可见CRM系统客户和联系人数据范围' where fieldlabel='可见本系统客户和联系人范围' AND languagetype='zh' AND labelbol='SYSTEMSCOPECLIENTSANDCONTACTS';
update ld_desk set fieldlabel='在帮我吧系统新增或者编辑单据同步到CRM系统的负责人' where fieldlabel='在帮我吧新增或编辑单据对应本系统操作人' AND languagetype='zh' AND labelbol='ADDOREDITRECORDONBANGWO8TOSYSTEMOPERATE';
update ld_desk set fieldlabel='在帮我吧系统新增或者编辑单据同步到CRM系统的负责人' where  fieldlabel='新增或编辑单据对应本系统操作人' AND languagetype='zh' AND labelbol='ADDOREDITRECORDSYSTEMOPERATE';
update ld_desk set fieldlabel='新增合同数' where fieldlabel='新增合同订单数' AND labelbol='SALESORDERCOUNT' AND languagetype='zh' AND Labeltype='fixedstr';
update ld_desk set fieldlabel='合同金额' where fieldlabel='订单金额' AND labelbol='SALESORDERTOTAL' AND languagetype='zh' AND Labeltype='fixedstr';
delimiter;
-- 2016-06-24

SELECT tabid INTO @tabid FROM ld_tab WHERE `name`='TimeSheet'; 
SELECT max(relation_id) INTO @relation_id FROM ld_relatedlists; 
INSERT INTO ld_relatedlists(relation_id,tabid,related_tabid,NAME,sequence,label,presence,actions,mobile_presence,mobile_sequence) 
SELECT @relation_id+1,@tabid,0,'get_SharedUsers',1,'SharedUsers',0,'share',1,1 
FROM DUAL WHERE NOT EXISTS(SELECT 1 FROM ld_relatedlists WHERE tabid=@tabid AND NAME='get_SharedUsers'); 
delimiter;
-- 2016-06-27

update ld_systems_deploy set presence=0,roottype=1,inputtype='select',inputvalue='[{"value":"0","text":"YES"},{"value":"1","text":"NO"},{"sql":""}]'  where deploy_type=90; 

insert  into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'zh','ld_systems_deploy',90,90,'用户密码严格管理' from dual
where not exists(select 1 from ld_tranlabel where languagetype='zh' and  tabid=90 and relateid=90 and trantable='ld_systems_deploy');

insert  into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'en','ld_systems_deploy',90,90,'User strict password' from dual
where not exists(select 1 from ld_tranlabel where languagetype='en' and  tabid=90 and relateid=90 and trantable='ld_systems_deploy');
delimiter;

select cvid into @cvid from ld_customview where viewname='mobileQuotes' and entitytype='mobileQuotes';
delete from ld_cvcolumnlist where cvid=@cvid;
insert into ld_cvcolumnlist (cvid,columnindex,columnname) values(@cvid,0,'ld_quotes:quote_no:quote_no:Quotes_编号:V' );
insert into ld_cvcolumnlist (cvid,columnindex,columnname) values(@cvid,1,'ld_quotes:accountid:account_id:Quotes_客户:I' );
insert into ld_cvcolumnlist (cvid,columnindex,columnname) values(@cvid,2,'ld_quotes:total:hdnGrandTotal:Quotes_合计:N' );
insert into ld_cvcolumnlist (cvid,columnindex,columnname) values(@cvid,3,'ld_quotes:smownerid:assigned_user_id:Quotes_销售负责人:V' );
insert into ld_cvcolumnlist (cvid,columnindex,columnname) values(@cvid,4,'ld_quotes:createdtime:createdtime:Quotes_创建日期:D' );
delimiter;

update ld_relatedlists set tabid=16 where tabid=9 AND `name`='get_contacts';
delimiter;

SELECT tabid INTO @tabid FROM ld_tab WHERE `name`='Mcommission'; 
SELECT max(relation_id) INTO @relation_id FROM ld_relatedlists; 
INSERT INTO ld_relatedlists(relation_id,tabid,related_tabid,NAME,sequence,label,presence,actions,mobile_presence,mobile_sequence) 
SELECT @relation_id+1,@tabid,0,'get_SharedUsers',1,'SharedUsers',0,'share',1,1 
FROM DUAL WHERE NOT EXISTS(SELECT 1 FROM ld_relatedlists WHERE tabid=@tabid AND NAME='get_SharedUsers'); 
delimiter;

SELECT tabid INTO @tabid FROM ld_tab WHERE `name`='Management'; 
SELECT max(relation_id) INTO @relation_id FROM ld_relatedlists; 
INSERT INTO ld_relatedlists(relation_id,tabid,related_tabid,NAME,sequence,label,presence,actions,mobile_presence,mobile_sequence) 
SELECT @relation_id+1,@tabid,0,'get_SharedUsers',1,'SharedUsers',0,'share',1,1 
FROM DUAL WHERE NOT EXISTS(SELECT 1 FROM ld_relatedlists WHERE tabid=@tabid AND NAME='get_SharedUsers'); 
delimiter;

select tabid into @tabid from ld_tab where `name` = 'Management';
update ld_field set fieldname = 'assigned_user_id',issmownerid = 1 where tabid = @tabid and columnname = 'smownerid';
delimiter;

select tabid into @tabid from ld_tab where `name` = 'Mcommission';
update ld_field set fieldname = 'assigned_user_id',issmownerid = 1 where tabid = @tabid and columnname = 'smownerid';
delimiter;

call getallprofile('Campaigns');
delimiter;

call fieldprofile('Campaigns');
delimiter;
-- 2016-06-28

select tabid into @tabid from ld_tab where `name` = 'PurchaseOrder';
select tabid into @PurchaseCashBack_tabid from ld_tab where `name` = 'PurchaseCashBack';
delete from ld_relatedlists where tabid = @tabid and label = 'PurchaseCashBack';
delete from ld_quickactions where tabid = @tabid and related_tabid = @PurchaseCashBack_tabid;
delimiter;
select tabid into @tabid from ld_tab where `name` = 'Products';
update ld_field set uitype = 72 where tabid = @tabid and columnname = 'costprice';
delimiter;

DROP PROCEDURE IF EXISTS `DelForeignkey`;
delimiter ||
CREATE  PROCEDURE `DelForeignkey`(
tablename varchar(50),
foreignname varchar(50)
)
begin

		select database() into @tableschema;
		
		set @cnt=0;
		set tablename=lower(tablename);
		select count(1) into @cnt from information_schema.INNODB_SYS_FOREIGN where ID=concat(DATABASE(),'/',foreignname) and FOR_NAME=concat(DATABASE(),'/',tablename);
		
		IF @cnt>0 THEN
				set @sql1=CONCAT(' alter table ',tablename, ' drop foreign key ',foreignname);
				prepare stalter from @sql1;
				execute stalter;
				deallocate prepare stalter;
		END IF;

end ||
delimiter;

call DelForeignkey('ld_cashbill2paymentplan','ld_cashbill2paymentplan_ibfk_1');
delimiter;
-- 2016-07-01

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

update ld_version set old_version='V6.4.0' ,current_version='V6.4.0' ,remark='V6.4.0-20160701';
delimiter;