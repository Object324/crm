DROP PROCEDURE IF EXISTS `del_idx`;
delimiter ||
CREATE DEFINER=`root`@`localhost` PROCEDURE `del_idx`(
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

call del_idx( 'Contactrecords_createdtime_idx', 'ld_contactrecords');
call del_idx( 'Contactrecords_contactrecordid_idx', 'ld_contactrecords');
delimiter;

update ld_desk set fieldlabel = '模块共享规则' where labelbol = 'LBL_SHARING_ACCESS' and Labeltype = 'fixedstr' and languagetype = 'zh';
update ld_desk set fieldlabel = 'Module Sharing Rule' where labelbol = 'LBL_SHARING_ACCESS' and Labeltype = 'fixedstr' and languagetype = 'en';
delimiter;
update ld_desk set fieldlabel = '管理模块全局共享规则，模块数据整体共享' where labelbol = 'MANAGEMODULESHARE' and Labeltype = 'fixedstr' and languagetype = 'zh';
update ld_desk set fieldlabel = 'Management module global sharing rule, module data sharing' where labelbol = 'MANAGEMODULESHARE' and Labeltype = 'fixedstr' and languagetype = 'en';
delimiter;

insert into ld_cvcolumnlist_wx(modulename,rownumber,listnumber,columnname,type)
  select 'Stock',0,0,'ld_stock:ware_stock_no:ware_stock_no:Stock_fieldlabel:V',2 from dual
  where not exists(select 1 from ld_cvcolumnlist_wx
  where modulename = 'Stock' and rownumber=0 AND listnumber=0);
insert into ld_cvcolumnlist_wx(modulename,rownumber,listnumber,columnname,type)
  select 'Stock',0,1,'ld_stock:vendorid:vendor_id:Stock_fieldlabel:V',2 from dual
  where not exists(select 1 from ld_cvcolumnlist_wx
  where modulename = 'Stock' and rownumber=0 AND listnumber=1);
insert into ld_cvcolumnlist_wx(modulename,rownumber,listnumber,columnname)
  select 'Stock',1,0,'ld_stock:total:hdnGrandTotal:Stock_fieldlabel:V' from dual
  where not exists(select 1 from ld_cvcolumnlist_wx
  where modulename = 'Stock' and rownumber=1 AND listnumber=0);
insert into ld_cvcolumnlist_wx(modulename,rownumber,listnumber,columnname)
  select 'Stock',1,1,'ld_stock:smownerid:assigned_user_id:Stock_fieldlabel:V' from dual
  where not exists(select 1 from ld_cvcolumnlist_wx
  where modulename = 'Stock' and rownumber=1 AND listnumber=1);
insert into ld_cvcolumnlist_wx(modulename,rownumber,listnumber,columnname)
  select 'Stock',1,2,'ld_stock:createdate:createdate:Stock_fieldlabel:V' from dual
  where not exists(select 1 from ld_cvcolumnlist_wx
  where modulename = 'Stock' and rownumber=1 AND listnumber=2);
delimiter;

SET @tabid=29;
UPDATE ld_field SET presence=2,displaytype=1 WHERE tabid=@tabid and columnname in ('approvestatus','approveby');
UPDATE ld_users SET approvestatus=1 WHERE IFNULL(approveby,0)=0 AND approvestatus=0;
delimiter;

DROP TRIGGER IF EXISTS `ldcrm_updatesykq_byminusjobbill`;
delimiter ||
CREATE TRIGGER `ldcrm_updatesykq_byminusjobbill` AFTER UPDATE ON `ld_minusjobbill` FOR EACH ROW BEGIN 

	IF (new.approvestatus='已批准' and old.approvestatus<>'已批准') OR (new.approvestatus<>'已批准' and old.approvestatus='已批准') THEN
		CALL ldcrm_update_sykq_byuserid(new.smownerid);
	END IF;

	IF new.smownerid<>old.smownerid THEN
		CALL ldcrm_update_sykq_byuserid(new.smownerid);
		CALL ldcrm_update_sykq_byuserid(old.smownerid);
	END IF;
	
END ||
delimiter;

DROP TRIGGER IF EXISTS `ldcrm_updatesykq_byaddjobbill`;
delimiter ||
CREATE TRIGGER `ldcrm_updatesykq_byaddjobbill` AFTER UPDATE ON `ld_addjobbill` FOR EACH ROW BEGIN 

	IF (new.approvestatus='已批准' and old.approvestatus<>'已批准') OR (new.approvestatus<>'已批准' and old.approvestatus='已批准') THEN
		CALL ldcrm_update_sykq_byuserid(new.smownerid);
	END IF;

	IF new.smownerid<>old.smownerid THEN
		CALL ldcrm_update_sykq_byuserid(new.smownerid);
		CALL ldcrm_update_sykq_byuserid(old.smownerid);
	END IF;
	
END ||
delimiter;
-- 2017-07-24

call AddColumn('ld_salesorder','kis_id','int','20',0);
delimiter;

select tabid into @tabid from ld_tab where `name` = 'Campaigns';
insert into ld_profileallpermission(tabid,operation)
select @tabid,5 from DUAL
where not exists(select 1 from ld_profileallpermission where tabid = @tabid and operation = 5);
delimiter;

select tabid into @tabid from ld_tab where `name` = 'Campaigns';
insert into ld_links(tabid,linktype,linklabel,linkurl,description)
select @tabid,'Import','module_import_step1','http://51mis.com.cn/forum.php?mod=viewthread&tid=152&fromuid=1','合同订单模块导入第一页，选择导入文件' from DUAL
where not exists(select 1 from ld_links where tabid = @tabid and linktype = 'Import' and linklabel = 'module_import_step1');
insert into ld_links(tabid,linktype,linklabel,linkurl,description)
select @tabid,'Import','module_import_step2','http://51mis.com.cn/forum.php?mod=viewthread&tid=152&fromuid=1','合同订单模块导入第一页，选择导入文件' from DUAL
where not exists(select 1 from ld_links where tabid = @tabid and linktype = 'Import' and linklabel = 'module_import_step2');
insert into ld_links(tabid,linktype,linklabel,linkurl,description)
select @tabid,'Import','module_import_step3','http://51mis.com.cn/forum.php?mod=viewthread&tid=152&fromuid=1','合同订单模块导入第一页，选择导入文件' from DUAL
where not exists(select 1 from ld_links where tabid = @tabid and linktype = 'Import' and linklabel = 'module_import_step3');
delimiter;
-- 2017-07-26

select tabid into @tabid from ld_tab where `name`='Accounts';
select block into @blockid from ld_field where tabid=@tabid and columnname='smownerid';
select tablename into @tablename from ld_field where tabid=@tabid and columnname='smownerid';
set @columnname='productcategory';
set @fieldname='productcategory';
set @zh='产品类别';
set @en='Product Category';
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

select fieldid into @fieldid from ld_field where tabid=@tabid and columnname=@columnname;
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'zh','ld_field',@tabid,@fieldid,@zh from dual 
where not exists (select 1 from ld_tranlabel  where languagetype = 'zh' and trantable ='ld_field' and tabid = @tabid and relateid=@fieldid);

insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'en','ld_field',@tabid,@fieldid,@en from dual 
where not exists (select 1 from ld_tranlabel  where languagetype = 'en' and trantable ='ld_field' and tabid = @tabid and relateid=@fieldid);

call AddColumn(@tablename,@columnname,'varchar','200',NULL);
delimiter;

call getallprofile('Accounts');
delimiter;
call fieldprofile('Accounts');
delimiter;

SELECT fieldid INTO @trigger_fieldid FROM ld_field where tabid=13 AND columnname='accountid';
SELECT fieldid INTO @effect_fieldid  FROM ld_field WHERE tabid=13 and columnname='productcategory';
INSERT INTO ld_related_field(fieldtype,trigger_fieldid,effect_fieldid,curmodule_columninfo,fromvalue_type,fromvalue_info) 
SELECT 'main',@trigger_fieldid,@effect_fieldid,'','column','productcategory' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_related_field WHERE trigger_fieldid=@trigger_fieldid AND effect_fieldid=@effect_fieldid);
delimiter;

update ld_cvcolumnlist_wx set systemdefault = 'yes' where systemdefault is NULL or systemdefault = '';
delimiter;

DELETE
FROM ld_cvcolumnlist_wx
WHERE columnname IN (
  SELECT
    TempA.columnname
  FROM (SELECT * from ld_cvcolumnlist_wx) TempA
  GROUP BY
    TempA.modulename, substring_index(TempA.columnname, ':', 2)
  HAVING
    count(TempA.columnname) > 1) AND modulename IN (
  SELECT TempB.modulename
  FROM  (SELECT * from ld_cvcolumnlist_wx) TempB
  GROUP BY
    TempB.modulename, substring_index(TempB.columnname, ':', 2)
  HAVING
    count(TempB.columnname) > 1) AND id NOT IN (
  SELECT min(TempA.id)
  FROM
    (SELECT * from ld_cvcolumnlist_wx) TempA
  GROUP BY
    TempA.modulename, substring_index(TempA.columnname, ':', 2)
  HAVING
    count(TempA.columnname) > 1
) AND systemdefault='yes';
delimiter;

update ld_relatedlists set actions='add,sendemail,select' where tabid=26 and name='get_accounts';
update ld_relatedlists set actions='add,sendemail,select' where tabid=26 and name='get_contacts';
delimiter;

insert into ld_links(tabid,linktype,linklabel,linkurl,description)
select 0,'Export','module_export','http://51mis.com.cn/forum.php?mod=viewthread&tid=50','模块导出' from DUAL
where not exists(select 1 from ld_links where linktype = 'Export' and linklabel = 'module_export');
delimiter;

insert into ld_links(tabid,linktype,linklabel,linkurl,description)
select 0,'Module','ProductDetails','http://51mis.com.cn/forum.php?mod=viewthread&tid=55','模块导出' from DUAL
where not exists(select 1 from ld_links where linktype = 'Module' and linklabel = 'ProductDetails');
delimiter;

select tabid into @tabid from ld_tab where `name` = 'CommunicationLog';
insert into ld_links(tabid,linktype,linklabel,linkurl,description)
select @tabid,'Module','ListView','http://51mis.com.cn/forum.php?mod=viewthread&tid=69','短信记录列表' from DUAL
where not exists(select 1 from ld_links where tabid = @tabid and linktype = 'Module' and linklabel = 'ListView');
delimiter;

select tabid into @tabid from ld_tab where `name` = 'OftenUseReport';
insert into ld_links(tabid,linktype,linklabel,linkurl,description)
select @tabid,'OftenUseReport','SIGNINSTATISTICS','http://51mis.com.cn/forum.php?mod=viewthread&tid=79','常用报表-签到统计表' from DUAL
where not exists(select 1 from ld_links where tabid = @tabid and linktype = 'OftenUseReport' and linklabel = 'SIGNINSTATISTICS');
delimiter;

select tabid into @tabid from ld_tab where `name` = 'OftenUseReport';
insert into ld_links(tabid,linktype,linklabel,linkurl,description)
select @tabid,'OftenUseReport','Serviceperformanceappraisal','http://51mis.com.cn/forum.php?mod=viewthread&tid=81','常用报表-签到统计表' from DUAL
where not exists(select 1 from ld_links where tabid = @tabid and linktype = 'OftenUseReport' and linklabel = 'Serviceperformanceappraisal');
delimiter;

insert into ld_links(tabid,linktype,linklabel,linkurl,description)
select 0,'Share','module_list_share','http://51mis.com.cn/forum.php?mod=viewthread&tid=82','模块列表共享' from DUAL
where not exists(select 1 from ld_links where linktype = 'Share' and linklabel = 'module_list_share');
delimiter;

insert into ld_links(tabid,linktype,linklabel,linkurl,description)
select 0,'Settings','OrganizationConfig','http://www.51mis.com.cn/forum.php?mod=viewthread&tid=129&fromuid=1','控制面板-公司信息' from DUAL
where not exists(select 1 from ld_links where linktype = 'Settings' and linklabel = 'OrganizationConfig');
delimiter;

insert into ld_links(tabid,linktype,linklabel,linkurl,description)
select 0,'Settings','bangwo8interface','http://www.51mis.com.cn/forum.php?mod=viewthread&tid=149&fromuid=1','控制面板-帮我吧设置' from DUAL
where not exists(select 1 from ld_links where linktype = 'Settings' and linklabel = 'bangwo8interface');
delimiter;

CREATE TABLE IF NOT EXISTS `ld_campaignaccountrelstatus` (
  `campaignaccountrelstatusid` int(19) NOT NULL AUTO_INCREMENT,
  `campaignaccountrelstatus` varchar(200) NOT NULL,
  `presence` int(1) NOT NULL DEFAULT '1',
  `picklist_valueid` int(19) NOT NULL DEFAULT '0',
  PRIMARY KEY (`campaignaccountrelstatusid`)
) ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=utf8;
delimiter;

CREATE TABLE IF NOT EXISTS `ld_campaignaccountrelstatus_seq` (
  `id` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
delimiter;

select id into @id from ld_picklistvalues_seq;
set @typevalue='已邀约';
insert into ld_campaignaccountrelstatus(campaignaccountrelstatus,presence,picklist_valueid)
select @typevalue,1,(@id:=@id+1) from dual 
where not exists (select 1 from ld_campaignaccountrelstatus where campaignaccountrelstatus=@typevalue);

set @typevalue='有兴趣';
insert into ld_campaignaccountrelstatus(campaignaccountrelstatus,presence,picklist_valueid)
select @typevalue,1,(@id:=@id+1) from dual 
where not exists (select 1 from ld_campaignaccountrelstatus where campaignaccountrelstatus=@typevalue);

set @typevalue='准备参加';
insert into ld_campaignaccountrelstatus(campaignaccountrelstatus,presence,picklist_valueid)
select @typevalue,1,(@id:=@id+1) from dual 
where not exists (select 1 from ld_campaignaccountrelstatus where campaignaccountrelstatus=@typevalue);

set @typevalue='已报名';
insert into ld_campaignaccountrelstatus(campaignaccountrelstatus,presence,picklist_valueid)
select @typevalue,1,(@id:=@id+1) from dual 
where not exists (select 1 from ld_campaignaccountrelstatus where campaignaccountrelstatus=@typevalue);

select ifnull(max(picklist_valueid),0) into @picklist_valueid from ld_campaignaccountrelstatus;
update ld_picklistvalues_seq set id=@picklist_valueid where id<@picklist_valueid;
delimiter;

call AddColumn('ld_campaignaccountrel','campaignaccountrelstatus','varchar','255',NULL);
delimiter;

UPDATE ld_entityname SET fieldname='campaignname' WHERE modulename='Campaigns'
	AND NOT EXISTS (SELECT 1 FROM ld_campaign);
delimiter;

select tabid into @tabid from ld_tab where `name`='ServiceCharge';
select block into @blockid from ld_field where tabid=@tabid and columnname='smownerid';
select tablename into @tablename from ld_field where tabid=@tabid and columnname='smownerid';
set @columnname='productcategory';
set @fieldname='productcategory';
set @zh='产品类别';
set @en='Product Category';
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

select fieldid into @fieldid from ld_field where tabid=@tabid and columnname=@columnname;
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'zh','ld_field',@tabid,@fieldid,@zh from dual 
where not exists (select 1 from ld_tranlabel  where languagetype = 'zh' and trantable ='ld_field' and tabid = @tabid and relateid=@fieldid);

insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'en','ld_field',@tabid,@fieldid,@en from dual 
where not exists (select 1 from ld_tranlabel  where languagetype = 'en' and trantable ='ld_field' and tabid = @tabid and relateid=@fieldid);

call AddColumn(@tablename,@columnname,'varchar','200',NULL);
delimiter;

call getallprofile('ServiceCharge');
delimiter;
call fieldprofile('ServiceCharge');
delimiter;

update ld_tab set mobilepresence='weixin' where name='Stock';

select tabid into @tabid from ld_tab where name='Stock';
select blockid into @blockid from ld_appparenttab where parenttab_label='Inventory' and systemdefault='yes';
select max(sequence) into @maxid from ld_appparenttabrel where blockid=@blockid;
insert into ld_appparenttabrel(blockid,tabid,sequence)
select @blockid,@tabid,@maxid+1 from dual 
where not exists(select 1 from ld_appparenttabrel where tabid=@tabid);
delimiter;
-- 2017-07-27

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
update ld_tabdetailfield_seq set id=(select max(tabdetailfieldid) from ld_tabdetailfield);
update ld_customreport_info_seq set id=(select max(report_id) from ld_customreport_info);
update ld_producttoolfield_seq set id=(select MAX(producttoolfieldid) from ld_producttoolfield);
delimiter;

update ld_version set old_version='V7.0.7',current_version='V7.0.7',remark='V7.0.7-20170727';
delimiter;