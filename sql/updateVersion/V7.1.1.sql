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
CREATE PROCEDURE `addtableIndex`(
	tablename 	varchar(50),
	indexname 	varchar(50),
	columnlist 	varchar(50)
)
begin
	
	SELECT DATABASE() into @datebase;

	SET @sql2=CONCAT('select count(*) into @cnt from information_schema.statistics where table_name=''',tablename,''' and index_name=''',indexname,'''  and table_schema=''',@datebase,'''');  
	PREPARE statement_name FROM @sql2;  
	EXECUTE statement_name; 
	DEALLOCATE PREPARE statement_name;

	IF @cnt=0 THEN 
		SET @sql3=CONCAT('alter  table ',tablename,' add  index ',indexname,' (',columnlist,')' );
		PREPARE statement_name FROM @sql3;  
		EXECUTE statement_name; 
		DEALLOCATE PREPARE statement_name;
  END IF;
	
end ||
delimiter;

UPDATE ld_field SET allowhide='yes' WHERE tabid=14 AND columnname='unit_price';
update ld_systems_deploy set inputvalue='[{"value":"1","text":"MANDATORYFIELDS"},{"value":"2","text":"NONMANDATORY"},{"sql":""}]',deploy_value=1 where deploy_type=143;
delimiter;

UPDATE ld_systems_deploy SET deploy_value=1 WHERE deploy_type=70
	AND NOT EXISTS (SELECT 1 FROM ld_products);
UPDATE ld_field SET presence=1 WHERE tabid=14 AND columnname='approvestatus'
	AND NOT EXISTS (SELECT 1 FROM ld_products);

UPDATE ld_systems_deploy SET deploy_value=1 WHERE deploy_type=11
	AND NOT EXISTS (SELECT 1 FROM ld_account);
UPDATE ld_field SET presence=1 WHERE tabid=6 AND columnname='approvestatus'
	AND NOT EXISTS (SELECT 1 FROM ld_account);

UPDATE ld_systems_deploy SET deploy_value=1 WHERE deploy_type=94
	AND NOT EXISTS (SELECT 1 FROM ld_contactdetails);
UPDATE ld_field SET presence=1 WHERE tabid=4 AND columnname='approvestatus'
	AND NOT EXISTS (SELECT 1 FROM ld_contactdetails);

UPDATE ld_systems_deploy SET deploy_value=1 WHERE deploy_type=112
	AND NOT EXISTS (SELECT 1 FROM ld_vendor);
UPDATE ld_field SET presence=1 WHERE tabid=(SELECT tabid FROM ld_tab WHERE `name`='Vendors') AND columnname='approvestatus'
	AND NOT EXISTS (SELECT 1 FROM ld_vendor);

UPDATE ld_systems_deploy SET deploy_value=1 WHERE deploy_type=113
	AND NOT EXISTS (SELECT 1 FROM ld_vendorcontacts);
UPDATE ld_field SET presence=1 WHERE tabid=(SELECT tabid FROM ld_tab WHERE `name`='VendorContact') AND columnname='approvestatus'
	AND NOT EXISTS (SELECT 1 FROM ld_vendorcontacts);

UPDATE ld_systems_deploy SET deploy_value=1 WHERE deploy_type=27
	AND NOT EXISTS (SELECT 1 FROM ld_contactrecords);
UPDATE ld_field SET presence=1 WHERE tabid=(SELECT tabid FROM ld_tab WHERE `name`='ContactRecords') AND columnname='approvestatus'
	AND NOT EXISTS (SELECT 1 FROM ld_contactrecords);

UPDATE ld_systems_deploy SET deploy_value=1 WHERE deploy_type=29
	AND NOT EXISTS (SELECT 1 FROM ld_potential);
UPDATE ld_field SET presence=1 WHERE tabid=(SELECT tabid FROM ld_tab WHERE `name`='Potentials') AND columnname='approvestatus'
	AND NOT EXISTS (SELECT 1 FROM ld_potential);

UPDATE ld_field SET presence=1
WHERE tabid=6 AND columnname IN ('modifiedby','lastorderdate','lastcontactdate','allocatedate','protectdate',
    'potentialid','lastservicedate','distributiondate','firt_concatuser','lastcontactuser','product_id','servicecasher')
	AND NOT EXISTS(SELECT 1 FROM ld_account);
-- 2017-10-26

update ld_systems_deploy set inputvalue='[{"relatedmodule":"Reminds,PaymentPlan"}]' where deploy_type=40;
delimiter;

select max(tabid)into @maxtabid from ld_tab ;
select tabsequence,presence into @tabsequence,@presence from ld_tab where `name` = 'Quotes';
update ld_tab set tabsequence = tabsequence +1000 where tabsequence > @tabsequence;
insert into ld_tab(tabid,name,presence,tabsequence,tablabel,printtab )
select @maxtabid+1,'QuotesChange',@presence,@tabsequence,'QuotesChange',1 from dual
where not EXISTS(select 1 from ld_tab where name='QuotesChange');
set @i=0;
update ld_tab set tabsequence=(@i:=@i+1) order by tabsequence;
delimiter;

select tabid into @tabid from ld_tab  where name='QuotesChange';
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'zh','ld_tab',@tabid,@tabid,'报价变更单' from dual
where not exists(select 1 from ld_tranlabel where tabid=@tabid and relateid=@tabid and languagetype='zh'and trantable='ld_tab' );
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'en','ld_tab',@tabid,@tabid,'Quotes Change' from dual
where not exists(select 1 from ld_tranlabel where tabid=@tabid and relateid=@tabid and languagetype='en' and trantable='ld_tab');
delimiter;

set @parenttabid = 4;
select tabid into @tabid from ld_tab where `name` = 'Quotes';
select parenttabid,sequence into @parenttabid,@sequence from ld_parenttabrel where tabid = @tabid LIMIT 1;
update ld_parenttabrel set sequence = sequence +1000 where parenttabid = @parenttabid and sequence > @sequence;
select tabid into @tabid from ld_tab  where name='QuotesChange';
insert into ld_parenttabrel(parenttabid,tabid,sequence)
select @parenttabid,@tabid,@sequence+1 from dual where not EXISTS(select 1 from ld_parenttabrel where parenttabid=@parenttabid and tabid=@tabid);
set @i=0;
update ld_parenttabrel set sequence=(@i:=@i+1) where parenttabid=@parenttabid order by sequence;
delimiter;

select max(num_id) into @maxnum_id from ld_modentity_num ;
insert into ld_modentity_num(num_id,semodule,prefix,start_id,cur_id,active,datetype,useuseraccount,isallow,prefixtype)
select @maxnum_id+1 ,'QuotesChange','QUC',1,1,1,'none',0,1,0 from dual
where not EXISTS(select 1 from ld_modentity_num where semodule='QuotesChange');
update ld_modentity_num_seq set id=@maxnum_id+1;
delimiter;

select tabid into @tabid from ld_tab where name='QuotesChange';
insert into  ld_modtracker_tabs(tabid,visible)select @tabid,1 from dual where not EXISTS(select 1 from ld_modtracker_tabs where tabid = @tabid);
delimiter;

select tabid into @tabid from ld_tab where name='QuotesChange';
insert into ld_profileallpermission(tabid,operation) select @tabid,actionid from ld_actionmapping
where not EXISTS(select 1 from ld_profileallpermission where tabid=@tabid)
and actionname in('index','Detailview','export','allocate','share','Delete','EditView','ChangeCreator');
delimiter;

select tabid into @tabid from ld_tab where name='QuotesChange';
insert into ld_entityname(tabid ,modulename,tablename,fieldname,entityidfield,entityidcolumn)
select @tabid,'QuotesChange','ld_quoteschange','quoteschange_no','quoteschangeid','quoteschangeid' from dual
where not exists(select 1 from ld_entityname where tabid=@tabid and modulename='QuotesChange');
delimiter;

select tabid into @tabid from ld_tab where name='QuotesChange';
select max(blockid) into @maxblockid from ld_blocks;
insert into ld_blocks(blockid,tabid,blocklabel,sequence,show_title,visible,create_view,edit_view,detail_view,display_status,iscustom)
select @maxblockid+1,@tabid,'LBL_QUOTESCHANGE_BASICINFORMATION',1,0,0,0,0,0,1,0 from dual
where not exists(select 1 from ld_blocks where blocklabel='LBL_QUOTESCHANGE_BASICINFORMATION' and tabid=@tabid);
select blockid into @blockid from ld_blocks where blocklabel='LBL_QUOTESCHANGE_BASICINFORMATION' and tabid=@tabid;
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'zh','ld_blocks',@tabid,@blockid,'基本信息' from dual
where not exists(select 1 from ld_tranlabel where tabid=@tabid and relateid=@blockid and languagetype='zh' and trantable='ld_blocks');
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'en','ld_blocks',@tabid,@blockid,'Basic Information' from dual
where not exists(select 1 from ld_tranlabel where tabid=@tabid and relateid=@blockid and languagetype='en' and trantable='ld_blocks');

insert into ld_blocks(blockid,tabid,blocklabel,sequence,show_title,visible,create_view,edit_view,detail_view,display_status,iscustom)
select @maxblockid+2,@tabid,'LBL_TERMS_INFORMATION',2,0,0,0,0,0,1,0 from dual
where not exists(select 1 from ld_blocks where blocklabel='LBL_TERMS_INFORMATION' and tabid=@tabid);
select blockid into @blockid from ld_blocks where blocklabel='LBL_TERMS_INFORMATION' and tabid=@tabid;
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'zh','ld_blocks',@tabid,@blockid,'条款与条件' from dual
where not exists(select 1 from ld_tranlabel where tabid=@tabid and relateid=@blockid and languagetype='zh' and trantable='ld_blocks');
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'en','ld_blocks',@tabid,@blockid,'Terms & Conditions' from dual
where not exists(select 1 from ld_tranlabel where tabid=@tabid and relateid=@blockid and languagetype='en' and trantable='ld_blocks');

insert into ld_blocks(blockid,tabid,blocklabel,sequence,show_title,visible,create_view,edit_view,detail_view,display_status,iscustom)
select @maxblockid+3,@tabid,'LBI_ATTACHMENT_FILE',3,0,0,0,0,0,1,0 from dual
where not exists(select 1 from ld_blocks where blocklabel='LBI_ATTACHMENT_FILE' and tabid=@tabid);
select blockid into @blockid from ld_blocks where blocklabel='LBI_ATTACHMENT_FILE' and tabid=@tabid;
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'zh','ld_blocks',@tabid,@blockid,'附件信息' from dual
where not exists(select 1 from ld_tranlabel where tabid=@tabid and relateid=@blockid and languagetype='zh' and trantable='ld_blocks');
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'en','ld_blocks',@tabid,@blockid,'Attachment Infos' from dual
where not exists(select 1 from ld_tranlabel where tabid=@tabid and relateid=@blockid and languagetype='en' and trantable='ld_blocks');
delimiter;

select tabid into @tabid from ld_tab where name='QuotesChange';
select blockid into @blockid  from ld_blocks where tabid=@tabid and blocklabel='LBL_QUOTESCHANGE_BASICINFORMATION';
select max(fieldid) into @maxfieldid from ld_field;
insert into ld_field (tabid ,fieldid,columnname,tablename,generatedtype,uitype,fieldname,fieldlabel,readonly,presence,sequence,block,displaytype,typeofdata,quickcreate,issmownerid)
select @tabid,@maxfieldid+1,'change_date','ld_quoteschange',1,5,'change_date','变更日期',1,0,1,@blockid ,1,'D~O',0,0 from dual
where not EXISTS(select 1 from ld_field where tabid=@tabid and columnname='change_date');

insert into ld_field (tabid ,fieldid,columnname,tablename,generatedtype,uitype,fieldname,fieldlabel,readonly,presence,sequence,block,displaytype,typeofdata,quickcreate,issmownerid)
select @tabid,@maxfieldid+2,'quoteschange_no','ld_quoteschange',1,4,'quoteschange_no','单据编号',1,0,2,@blockid ,1,'V~M',0,0 from dual
where not EXISTS(select 1 from ld_field where tabid=@tabid and columnname='quoteschange_no');

insert into ld_field (tabid ,fieldid,columnname,tablename,generatedtype,uitype,fieldname,fieldlabel,readonly,presence,sequence,block,displaytype,typeofdata,quickcreate,issmownerid)
select @tabid,@maxfieldid+3,'change_type','ld_quoteschange',1,1,'change_type','变更类型',1,0,3,@blockid ,2,'V~O',0,0 from dual
where not EXISTS(select 1 from ld_field where tabid=@tabid and columnname='change_type');

insert into ld_field (tabid ,fieldid,columnname,tablename,generatedtype,uitype,fieldname,fieldlabel,readonly,presence,sequence,block,displaytype,typeofdata,quickcreate,issmownerid)
select @tabid,@maxfieldid+4,'smownerid','ld_quoteschange',1,53,'assigned_user_id','销售负责人',1,0,4,@blockid ,1,'V~M',0,1 from dual
where not EXISTS(select 1 from ld_field where tabid=@tabid and columnname='smownerid');

insert into ld_field (tabid ,fieldid,columnname,tablename,generatedtype,uitype,fieldname,fieldlabel,readonly,presence,sequence,block,displaytype,typeofdata,quickcreate,issmownerid)
select @tabid,@maxfieldid+5,'accountid','ld_quoteschange',1,73,'account_id','客户名称',1,0,5,@blockid ,2,'V~O',0,0 from dual
where not EXISTS(select 1 from ld_field where tabid=@tabid and columnname='accountid');

insert into ld_field (tabid ,fieldid,columnname,tablename,generatedtype,uitype,fieldname,fieldlabel,readonly,presence,sequence,block,displaytype,typeofdata,quickcreate,issmownerid)
select @tabid,@maxfieldid+6,'quoteid','ld_quoteschange',1,78,'quote_id','报价单',1,0,6,@blockid ,2,'I~O',0,0 from dual
where not EXISTS(select 1 from ld_field where tabid=@tabid and columnname='quoteid');

insert into ld_field (tabid ,fieldid,columnname,tablename,generatedtype,uitype,fieldname,fieldlabel,readonly,presence,sequence,block,displaytype,typeofdata,quickcreate,issmownerid)
select @tabid,@maxfieldid+7,'approveby','ld_quoteschange',1,131,'approveby','审批人',1,0,7,@blockid ,2,'V~O',0,0 from dual
where not EXISTS(select 1 from ld_field where tabid=@tabid and columnname='approveby');

insert into ld_field (tabid ,fieldid,columnname,tablename,generatedtype,uitype,fieldname,fieldlabel,readonly,presence,sequence,block,displaytype,typeofdata,quickcreate,issmownerid)
select @tabid,@maxfieldid+8,'approvestatus','ld_quoteschange',1,609,'approvestatus','审批状态',1,0,8,@blockid ,2,'V~O',0,0 from dual
where not EXISTS(select 1 from ld_field where tabid=@tabid and columnname='approvestatus');

insert into ld_field (tabid ,fieldid,columnname,tablename,generatedtype,uitype,fieldname,fieldlabel,readonly,presence,sequence,block,displaytype,typeofdata,quickcreate,issmownerid)
select @tabid,@maxfieldid+9,'currentapprover','ld_quoteschange',1,132,'currentapprover','当前审批人',1,0,9,@blockid ,2,'V~O',0,0 from dual
where not EXISTS(select 1 from ld_field where tabid=@tabid and columnname='currentapprover');

insert into ld_field (tabid ,fieldid,columnname,tablename,generatedtype,uitype,fieldname,fieldlabel,readonly,presence,sequence,block,displaytype,typeofdata,quickcreate,issmownerid)
select @tabid,@maxfieldid+10,'createdtime','ld_quoteschange',1,70,'createdtime','创建时间',1,0,10,@blockid ,2,'DT~O',1,0 from dual
where not EXISTS(select 1 from ld_field where tabid=@tabid and columnname='createdtime');

insert into ld_field (tabid ,fieldid,columnname,tablename,generatedtype,uitype,fieldname,fieldlabel,readonly,presence,sequence,block,displaytype,typeofdata,quickcreate,issmownerid)
select @tabid,@maxfieldid+11,'smcreatorid','ld_quoteschange',1,52,'smcreatorid','创建人',1,0,11,@blockid ,2,'V~O',1,0 from dual
where not EXISTS(select 1 from ld_field where tabid=@tabid and columnname='smcreatorid');

insert into ld_field (tabid ,fieldid,columnname,tablename,generatedtype,uitype,fieldname,fieldlabel,readonly,presence,sequence,block,displaytype,typeofdata,quickcreate,issmownerid)
select @tabid,@maxfieldid+12,'modifiedtime','ld_quoteschange',1,70,'modifiedtime','修改时间',1,0,12,@blockid ,2,'DT~O',1,0 from dual
where not EXISTS(select 1 from ld_field where tabid=@tabid and columnname='modifiedtime');

insert into ld_field (tabid ,fieldid,columnname,tablename,generatedtype,uitype,fieldname,fieldlabel,readonly,presence,sequence,block,displaytype,typeofdata,quickcreate,issmownerid)
select @tabid,@maxfieldid+13,'modifiedby','ld_quoteschange',1,52,'modifiedby','最新更新人',1,0,13,@blockid ,2,'V~O',1,0 from dual
where not EXISTS(select 1 from ld_field where tabid=@tabid and columnname='modifiedby');
delimiter;

select tabid into @tabid from ld_tab where name='QuotesChange';
select blockid into @blockid  from ld_blocks where tabid=@tabid and blocklabel='LBL_TERMS_INFORMATION';
insert into ld_field (tabid ,fieldid,columnname,tablename,generatedtype,uitype,fieldname,fieldlabel,readonly,presence,sequence,block,displaytype,typeofdata,quickcreate,issmownerid)
select @tabid,@maxfieldid+14,'terms_conditions','ld_quoteschange',1,19,'terms_conditions','条款与条件',1,0,14,@blockid ,1,'V~O',1,0 from dual
where not EXISTS(select 1 from ld_field where tabid=@tabid and columnname='terms_conditions');
delimiter;

select tabid into @tabid from ld_tab where name='QuotesChange';
select blockid into @blockid  from ld_blocks where tabid=@tabid and blocklabel='LBI_ATTACHMENT_FILE';
insert into ld_field (tabid ,fieldid,columnname,tablename,generatedtype,uitype,fieldname,fieldlabel,readonly,presence,sequence,block,displaytype,typeofdata,quickcreate,issmownerid)
select @tabid,@maxfieldid+15,'filename','ld_attachments',1,1109,'filename','附件',1,0,15,@blockid ,1,'V~O',1,0 from dual
where not EXISTS(select 1 from ld_field where tabid=@tabid and columnname='filename');
delimiter;

select tabid into @tabid from ld_tab where name='QuotesChange';
select blockid into @blockid  from ld_blocks where tabid=@tabid and blocklabel='LBL_QUOTESCHANGE_BASICINFORMATION';
insert into ld_field (tabid ,fieldid,columnname,tablename,generatedtype,uitype,fieldname,fieldlabel,readonly,presence,sequence,block,displaytype,typeofdata,quickcreate,issmownerid)
select @tabid,@maxfieldid+16,'subtotal','ld_quoteschange',1,72,'hdnSubTotal','小计',1,0,16,@blockid ,3,'N~O',1,0 from dual
where not EXISTS(select 1 from ld_field where tabid=@tabid and columnname='subtotal');

select blockid into @blockid  from ld_blocks where tabid=@tabid and blocklabel='LBL_QUOTESCHANGE_BASICINFORMATION';
insert into ld_field (tabid ,fieldid,columnname,tablename,generatedtype,uitype,fieldname,fieldlabel,readonly,presence,sequence,block,displaytype,typeofdata,quickcreate,issmownerid)
select @tabid,@maxfieldid+17,'total','ld_quoteschange',1,72,'hdnGrandTotal','合计',1,0,17,@blockid ,3,'N~O',1,0 from dual
where not EXISTS(select 1 from ld_field where tabid=@tabid and columnname='total');
delimiter;

select blockid into @blockid  from ld_blocks where tabid=@tabid and blocklabel='LBL_QUOTESCHANGE_BASICINFORMATION';
insert into ld_field (tabid ,fieldid,columnname,tablename,generatedtype,uitype,fieldname,fieldlabel,readonly,presence,sequence,block,displaytype,typeofdata,quickcreate,issmownerid)
select @tabid,@maxfieldid+18,'adjustment','ld_quoteschange',1,72,'txtAdjustment','Adjustment',1,0,18,@blockid ,3,'NN~O',1,0 from dual
where not EXISTS(select 1 from ld_field where tabid=@tabid and columnname='adjustment');
delimiter;

select blockid into @blockid  from ld_blocks where tabid=@tabid and blocklabel='LBL_QUOTESCHANGE_BASICINFORMATION';
insert into ld_field (tabid ,fieldid,columnname,tablename,generatedtype,uitype,fieldname,fieldlabel,readonly,presence,sequence,block,displaytype,typeofdata,quickcreate,issmownerid)
select @tabid,@maxfieldid+19,'discount_amount','ld_quoteschange',1,72,'hdnDiscountAmount','整单折扣',1,0,19,@blockid ,3,'N~O',1,0 from dual
where not EXISTS(select 1 from ld_field where tabid=@tabid and columnname='discount_amount');
delimiter;

select blockid into @blockid  from ld_blocks where tabid=@tabid and blocklabel='LBL_QUOTESCHANGE_BASICINFORMATION';
insert into ld_field (tabid ,fieldid,columnname,tablename,generatedtype,uitype,fieldname,fieldlabel,readonly,presence,sequence,block,displaytype,typeofdata,quickcreate,issmownerid)
select @tabid,@maxfieldid+20,'currency_id','ld_quoteschange',1,117,'currency_id','货币',1,0,20,@blockid ,3,'V~M',1,0 from dual
where not EXISTS(select 1 from ld_field where tabid=@tabid and columnname='currency_id');
delimiter;

select blockid into @blockid  from ld_blocks where tabid=@tabid and blocklabel='LBL_QUOTESCHANGE_BASICINFORMATION';
insert into ld_field (tabid ,fieldid,columnname,tablename,generatedtype,uitype,fieldname,fieldlabel,readonly,presence,sequence,block,displaytype,typeofdata,quickcreate,issmownerid)
select @tabid,@maxfieldid+21,'conversion_rate','ld_quoteschange',1,1,'conversion_rate','汇率',1,0,21,@blockid ,3,'N~O',1,0 from dual
where not EXISTS(select 1 from ld_field where tabid=@tabid and columnname='conversion_rate');
delimiter;

call getallprofile('QuotesChange');
delimiter;

select tabid into @tabid from ld_tab  where name='QuotesChange';
select fieldid into @fieldid from ld_field where tabid=@tabid and columnname='change_date';
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'zh','ld_field',@tabid, @fieldid,'变更日期' from dual
where not exists(select 1 from ld_tranlabel where tabid=@tabid and relateid=@fieldid and languagetype='zh'and trantable='ld_field' );
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'en','ld_field',@tabid,@fieldid,'Change Date' from dual
where not exists(select 1 from ld_tranlabel where tabid=@tabid and relateid=@fieldid and languagetype='en' and trantable='ld_field');
delimiter;

select tabid into @tabid from ld_tab  where name='QuotesChange';
select fieldid into @fieldid from ld_field where tabid=@tabid and columnname='quoteschange_no';
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'zh','ld_field',@tabid, @fieldid,'单据编号' from dual
where not exists(select 1 from ld_tranlabel where tabid=@tabid and relateid=@fieldid and languagetype='zh'and trantable='ld_field' );
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'en','ld_field',@tabid,@fieldid,'Leads No' from dual
where not exists(select 1 from ld_tranlabel where tabid=@tabid and relateid=@fieldid and languagetype='en' and trantable='ld_field');
delimiter;

select tabid into @tabid from ld_tab  where name='QuotesChange';
select fieldid into @fieldid from ld_field where tabid=@tabid and columnname='change_type';
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'zh','ld_field',@tabid, @fieldid,'变更类型' from dual
where not exists(select 1 from ld_tranlabel where tabid=@tabid and relateid=@fieldid and languagetype='zh'and trantable='ld_field' );
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'en','ld_field',@tabid,@fieldid,'Change Type' from dual
where not exists(select 1 from ld_tranlabel where tabid=@tabid and relateid=@fieldid and languagetype='en' and trantable='ld_field');
delimiter;

select tabid into @tabid from ld_tab  where name='QuotesChange';
select fieldid into @fieldid from ld_field where tabid=@tabid and columnname='smownerid';
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'zh','ld_field',@tabid, @fieldid,'销售负责人' from dual
where not exists(select 1 from ld_tranlabel where tabid=@tabid and relateid=@fieldid and languagetype='zh'and trantable='ld_field' );
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'en','ld_field',@tabid,@fieldid,'Assigned To' from dual
where not exists(select 1 from ld_tranlabel where tabid=@tabid and relateid=@fieldid and languagetype='en' and trantable='ld_field');
delimiter;

select tabid into @tabid from ld_tab  where name='QuotesChange';
select fieldid into @fieldid from ld_field where tabid=@tabid and columnname='accountid';
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'zh','ld_field',@tabid, @fieldid,'客户名称' from dual
where not exists(select 1 from ld_tranlabel where tabid=@tabid and relateid=@fieldid and languagetype='zh'and trantable='ld_field' );
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'en','ld_field',@tabid,@fieldid,'Customer Name' from dual
where not exists(select 1 from ld_tranlabel where tabid=@tabid and relateid=@fieldid and languagetype='en' and trantable='ld_field');
delimiter;

select tabid into @tabid from ld_tab  where name='QuotesChange';
select fieldid into @fieldid from ld_field where tabid=@tabid and columnname='quoteid';
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'zh','ld_field',@tabid, @fieldid,'报价单' from dual
where not exists(select 1 from ld_tranlabel where tabid=@tabid and relateid=@fieldid and languagetype='zh'and trantable='ld_field' );
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'en','ld_field',@tabid,@fieldid,'Quotes' from dual
where not exists(select 1 from ld_tranlabel where tabid=@tabid and relateid=@fieldid and languagetype='en' and trantable='ld_field');
delimiter;

select tabid into @tabid from ld_tab  where name='QuotesChange';
select fieldid into @fieldid from ld_field where tabid=@tabid and columnname='approvestatus';
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'zh','ld_field',@tabid, @fieldid,'审批状态' from dual
where not exists(select 1 from ld_tranlabel where tabid=@tabid and relateid=@fieldid and languagetype='zh'and trantable='ld_field' );
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'en','ld_field',@tabid,@fieldid,'Approve Status' from dual
where not exists(select 1 from ld_tranlabel where tabid=@tabid and relateid=@fieldid and languagetype='en' and trantable='ld_field');
delimiter;

select tabid into @tabid from ld_tab  where name='QuotesChange';
select fieldid into @fieldid from ld_field where tabid=@tabid and columnname='approveby';
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'zh','ld_field',@tabid, @fieldid,'上一步审批人' from dual
where not exists(select 1 from ld_tranlabel where tabid=@tabid and relateid=@fieldid and languagetype='zh'and trantable='ld_field' );
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'en','ld_field',@tabid,@fieldid,'The Last Approver' from dual
where not exists(select 1 from ld_tranlabel where tabid=@tabid and relateid=@fieldid and languagetype='en' and trantable='ld_field');
delimiter;

select tabid into @tabid from ld_tab  where name='QuotesChange';
select fieldid into @fieldid from ld_field where tabid=@tabid and columnname='currentapprover';
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'zh','ld_field',@tabid, @fieldid,'下一步审批人' from dual
where not exists(select 1 from ld_tranlabel where tabid=@tabid and relateid=@fieldid and languagetype='zh'and trantable='ld_field' );
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'en','ld_field',@tabid,@fieldid,'Next Approver' from dual
where not exists(select 1 from ld_tranlabel where tabid=@tabid and relateid=@fieldid and languagetype='en' and trantable='ld_field');
delimiter;

select tabid into @tabid from ld_tab  where name='QuotesChange';
select fieldid into @fieldid from ld_field where tabid=@tabid and columnname='createdtime';
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'zh','ld_field',@tabid, @fieldid,'创建时间' from dual
where not exists(select 1 from ld_tranlabel where tabid=@tabid and relateid=@fieldid and languagetype='zh'and trantable='ld_field' );
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'en','ld_field',@tabid,@fieldid,'Created Time' from dual
where not exists(select 1 from ld_tranlabel where tabid=@tabid and relateid=@fieldid and languagetype='en' and trantable='ld_field');
delimiter;

select tabid into @tabid from ld_tab  where name='QuotesChange';
select fieldid into @fieldid from ld_field where tabid=@tabid and columnname='smcreatorid';
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'zh','ld_field',@tabid, @fieldid,'创建人' from dual
where not exists(select 1 from ld_tranlabel where tabid=@tabid and relateid=@fieldid and languagetype='zh'and trantable='ld_field' );
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'en','ld_field',@tabid,@fieldid,'Creator' from dual
where not exists(select 1 from ld_tranlabel where tabid=@tabid and relateid=@fieldid and languagetype='en' and trantable='ld_field');
delimiter;

select tabid into @tabid from ld_tab  where name='QuotesChange';
select fieldid into @fieldid from ld_field where tabid=@tabid and columnname='modifiedtime';
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'zh','ld_field',@tabid, @fieldid,'修改时间' from dual
where not exists(select 1 from ld_tranlabel where tabid=@tabid and relateid=@fieldid and languagetype='zh'and trantable='ld_field' );
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'en','ld_field',@tabid,@fieldid,'Modified Time' from dual
where not exists(select 1 from ld_tranlabel where tabid=@tabid and relateid=@fieldid and languagetype='en' and trantable='ld_field');
delimiter;

select tabid into @tabid from ld_tab  where name='QuotesChange';
select fieldid into @fieldid from ld_field where tabid=@tabid and columnname='modifiedby';
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'zh','ld_field',@tabid, @fieldid,'最新更新人' from dual
where not exists(select 1 from ld_tranlabel where tabid=@tabid and relateid=@fieldid and languagetype='zh'and trantable='ld_field' );
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'en','ld_field',@tabid,@fieldid,'Modified By' from dual
where not exists(select 1 from ld_tranlabel where tabid=@tabid and relateid=@fieldid and languagetype='en' and trantable='ld_field');
delimiter;

select tabid into @tabid from ld_tab  where name='QuotesChange';
select fieldid into @fieldid from ld_field where tabid=@tabid and columnname='terms_conditions';
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'zh','ld_field',@tabid, @fieldid,'条款与条件' from dual
where not exists(select 1 from ld_tranlabel where tabid=@tabid and relateid=@fieldid and languagetype='zh'and trantable='ld_field' );
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'en','ld_field',@tabid,@fieldid,'Description' from dual
where not exists(select 1 from ld_tranlabel where tabid=@tabid and relateid=@fieldid and languagetype='en' and trantable='ld_field');
delimiter;

select tabid into @tabid from ld_tab  where name='QuotesChange';
select fieldid into @fieldid from ld_field where tabid=@tabid and columnname='filename';
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'zh','ld_field',@tabid, @fieldid,'附件' from dual
where not exists(select 1 from ld_tranlabel where tabid=@tabid and relateid=@fieldid and languagetype='zh'and trantable='ld_field' );
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'en','ld_field',@tabid,@fieldid,'Attachment' from dual
where not exists(select 1 from ld_tranlabel where tabid=@tabid and relateid=@fieldid and languagetype='en' and trantable='ld_field');
delimiter;

select tabid into @tabid from ld_tab  where name='QuotesChange';
select fieldid into @fieldid from ld_field where tabid=@tabid and columnname='subtotal';
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'zh','ld_field',@tabid, @fieldid,'小计' from dual
where not exists(select 1 from ld_tranlabel where tabid=@tabid and relateid=@fieldid and languagetype='zh'and trantable='ld_field' );
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'en','ld_field',@tabid,@fieldid,'Sub Total' from dual
where not exists(select 1 from ld_tranlabel where tabid=@tabid and relateid=@fieldid and languagetype='en' and trantable='ld_field');
delimiter;

select tabid into @tabid from ld_tab  where name='QuotesChange';
select fieldid into @fieldid from ld_field where tabid=@tabid and columnname='total';
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'zh','ld_field',@tabid, @fieldid,'合计' from dual
where not exists(select 1 from ld_tranlabel where tabid=@tabid and relateid=@fieldid and languagetype='zh'and trantable='ld_field' );
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'en','ld_field',@tabid,@fieldid,'Total' from dual
where not exists(select 1 from ld_tranlabel where tabid=@tabid and relateid=@fieldid and languagetype='en' and trantable='ld_field');
delimiter;

select tabid into @tabid from ld_tab  where name='QuotesChange';
select fieldid into @fieldid from ld_field where tabid=@tabid and columnname='adjustment';
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'zh','ld_field',@tabid, @fieldid,'调整' from dual
where not exists(select 1 from ld_tranlabel where tabid=@tabid and relateid=@fieldid and languagetype='zh'and trantable='ld_field' );
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'en','ld_field',@tabid,@fieldid,'Adjustment' from dual
where not exists(select 1 from ld_tranlabel where tabid=@tabid and relateid=@fieldid and languagetype='en' and trantable='ld_field');
delimiter;

select tabid into @tabid from ld_tab  where name='QuotesChange';
select fieldid into @fieldid from ld_field where tabid=@tabid and columnname='discount_amount';
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'zh','ld_field',@tabid, @fieldid,'整单折扣' from dual
where not exists(select 1 from ld_tranlabel where tabid=@tabid and relateid=@fieldid and languagetype='zh'and trantable='ld_field' );
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'en','ld_field',@tabid,@fieldid,'Discount Amount' from dual
where not exists(select 1 from ld_tranlabel where tabid=@tabid and relateid=@fieldid and languagetype='en' and trantable='ld_field');
delimiter;

select tabid into @tabid from ld_tab  where name='QuotesChange';
select fieldid into @fieldid from ld_field where tabid=@tabid and columnname='currency_id';
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'zh','ld_field',@tabid, @fieldid,'货币' from dual
where not exists(select 1 from ld_tranlabel where tabid=@tabid and relateid=@fieldid and languagetype='zh'and trantable='ld_field' );
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'en','ld_field',@tabid,@fieldid,'Currency Id' from dual
where not exists(select 1 from ld_tranlabel where tabid=@tabid and relateid=@fieldid and languagetype='en' and trantable='ld_field');
delimiter;

select tabid into @tabid from ld_tab  where name='QuotesChange';
select fieldid into @fieldid from ld_field where tabid=@tabid and columnname='conversion_rate';
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'zh','ld_field',@tabid, @fieldid,'汇率' from dual
where not exists(select 1 from ld_tranlabel where tabid=@tabid and relateid=@fieldid and languagetype='zh'and trantable='ld_field' );
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'en','ld_field',@tabid,@fieldid,'Conversion_rate' from dual
where not exists(select 1 from ld_tranlabel where tabid=@tabid and relateid=@fieldid and languagetype='en' and trantable='ld_field');
delimiter;

update ld_field_seq set id = (select max(fieldid) from ld_field);
delimiter;

select max(cvid) into @maxcvid  from ld_customview;
insert into ld_customview (cvid,viewname,setdefault,setmetrics,entitytype,status,userid,sequence)
select @maxcvid+1,'All',1,0,'QuotesChange',3,1,1 from dual
where not EXISTS(select 1 from ld_customview where entitytype='QuotesChange' and viewname='All');
insert into ld_customview (cvid,viewname,setdefault,setmetrics,entitytype,status,userid,sequence)
select @maxcvid+2,'追加',0,0,'QuotesChange',3,1,2 from dual
where not EXISTS(select 1 from ld_customview where entitytype='QuotesChange' and viewname='追加');
insert into ld_customview (cvid,viewname,setdefault,setmetrics,entitytype,status,userid,sequence)
select @maxcvid+3,'更换',0,0,'QuotesChange',3,1,3 from dual
where not EXISTS(select 1 from ld_customview where entitytype='QuotesChange' and viewname='更换');
insert into ld_customview (cvid,viewname,setdefault,setmetrics,entitytype,status,userid,sequence)
select @maxcvid+4,'待审批',0,0,'QuotesChange',3,1,4 from dual
where not EXISTS(select 1 from ld_customview where entitytype='QuotesChange' and viewname='待审批');
insert into ld_customview (cvid,viewname,setdefault,setmetrics,entitytype,status,userid,sequence)
select @maxcvid+5,'已审批',0,0,'QuotesChange',3,1,5 from dual
where not EXISTS(select 1 from ld_customview where entitytype='QuotesChange' and viewname='已审批');
update ld_customview_seq set id = (select max(cvid) from ld_customview);
delimiter;

select tabid into @tabid from ld_tab where name='QuotesChange';
select cvid into @cvid from ld_customview where entitytype='QuotesChange' and viewname='All';
DELETE from ld_tabwithproductview where tabid = @tabid and cvid = @cvid;
insert into ld_tabwithproductview(tabid,cvid,sequence,`columns`)
select @tabid,@cvid,0,'ld_quoteschange:quoteschange_no:quoteschange_no:QuotesChange_fieldlabel:V';
insert into ld_tabwithproductview(tabid,cvid,sequence,`columns`)
select @tabid,@cvid,1,'ld_quoteschange:change_type:change_type:QuotesChange_fieldlabel:V';
insert into ld_tabwithproductview(tabid,cvid,sequence,`columns`)
select @tabid,@cvid,2,'ld_quoteschange:accountid:account_id:QuotesChange_fieldlabel:V';
insert into ld_tabwithproductview(tabid,cvid,sequence,`columns`)
select @tabid,@cvid,3,'ld_quoteschange:change_date:change_date:QuotesChange_fieldlabel:V';
insert into ld_tabwithproductview(tabid,cvid,sequence,`columns`)
select @tabid,@cvid,4,'ld_quoteschange:approvestatus:approvestatus:QuotesChange_fieldlabel:V';
insert into ld_tabwithproductview(tabid,cvid,sequence,`columns`)
select @tabid,@cvid,5,'ld_quoteschange:currentapprover:currentapprover:QuotesChange_fieldlabel:V';
insert into ld_tabwithproductview(tabid,cvid,sequence,`columns`)
select @tabid,@cvid,6,'ld_quoteschange:total:hdnGrandTotal:QuotesChange_fieldlabel:V';
insert into ld_tabwithproductview(tabid,cvid,sequence,`columns`)
select @tabid,@cvid,7,'ld_quoteschange:smownerid:assigned_user_id:QuotesChange_fieldlabel:V';
insert into ld_tabwithproductview(tabid,cvid,sequence,`columns`)
select @tabid,@cvid,8,'ld_inventoryproductrelscf:pro_id:pro_id:Products_fieldlabel:V';
insert into ld_tabwithproductview(tabid,cvid,sequence,`columns`)
select @tabid,@cvid,9,'ld_products:productname:productname:Products_fieldlabel:V';
insert into ld_tabwithproductview(tabid,cvid,sequence,`columns`)
select @tabid,@cvid,10,'ld_inventoryproductrel:quantity:quantity:Products_fieldlabel:N';
delimiter;

select tabid into @tabid from ld_tab where name='QuotesChange';
select cvid into @cvid from ld_customview where entitytype='QuotesChange' and viewname='追加';
delete from ld_cvadvfilter where cvid = @cvid;
insert into ld_cvadvfilter(cvid,columnindex,columnname,comparator,value,groupid,column_condition)
select @cvid,0,'ld_quoteschange:change_type:change_type:QuotesChange_fieldlabel:V','e','追加',1,'';
delete from ld_cvadvfilter_grouping where cvid = @cvid;
insert into ld_cvadvfilter_grouping(groupid,cvid,group_condition,condition_expression)
select 1,@cvid,'',0;
DELETE from ld_tabwithproductview where tabid = @tabid and cvid = @cvid;
insert into ld_tabwithproductview(tabid,cvid,sequence,`columns`)
select @tabid,@cvid,0,'ld_quoteschange:quoteschange_no:quoteschange_no:QuotesChange_fieldlabel:V';
insert into ld_tabwithproductview(tabid,cvid,sequence,`columns`)
select @tabid,@cvid,1,'ld_quoteschange:change_type:change_type:QuotesChange_fieldlabel:V';
insert into ld_tabwithproductview(tabid,cvid,sequence,`columns`)
select @tabid,@cvid,2,'ld_quoteschange:accountid:account_id:QuotesChange_fieldlabel:V';
insert into ld_tabwithproductview(tabid,cvid,sequence,`columns`)
select @tabid,@cvid,3,'ld_quoteschange:change_date:change_date:QuotesChange_fieldlabel:V';
insert into ld_tabwithproductview(tabid,cvid,sequence,`columns`)
select @tabid,@cvid,4,'ld_quoteschange:approvestatus:approvestatus:QuotesChange_fieldlabel:V';
insert into ld_tabwithproductview(tabid,cvid,sequence,`columns`)
select @tabid,@cvid,5,'ld_quoteschange:currentapprover:currentapprover:QuotesChange_fieldlabel:V';
insert into ld_tabwithproductview(tabid,cvid,sequence,`columns`)
select @tabid,@cvid,6,'ld_quoteschange:total:hdnGrandTotal:QuotesChange_fieldlabel:V';
insert into ld_tabwithproductview(tabid,cvid,sequence,`columns`)
select @tabid,@cvid,7,'ld_quoteschange:smownerid:assigned_user_id:QuotesChange_fieldlabel:V';
insert into ld_tabwithproductview(tabid,cvid,sequence,`columns`)
select @tabid,@cvid,8,'ld_inventoryproductrelscf:pro_id:pro_id:Products_fieldlabel:V';
insert into ld_tabwithproductview(tabid,cvid,sequence,`columns`)
select @tabid,@cvid,9,'ld_products:productname:productname:Products_fieldlabel:V';
insert into ld_tabwithproductview(tabid,cvid,sequence,`columns`)
select @tabid,@cvid,10,'ld_inventoryproductrel:quantity:quantity:Products_fieldlabel:N';
delimiter;

select tabid into @tabid from ld_tab where name='QuotesChange';
select cvid into @cvid from ld_customview where entitytype='QuotesChange' and viewname='更换';
delete from ld_cvadvfilter where cvid = @cvid;
insert into ld_cvadvfilter(cvid,columnindex,columnname,comparator,value,groupid,column_condition)
select @cvid,0,'ld_quoteschange:change_type:change_type:QuotesChange_fieldlabel:V','e','更换',1,'';
delete from ld_cvadvfilter_grouping where cvid = @cvid;
insert into ld_cvadvfilter_grouping(groupid,cvid,group_condition,condition_expression)
select 1,@cvid,'',0;
DELETE from ld_tabwithproductview where tabid = @tabid and cvid = @cvid;
insert into ld_tabwithproductview(tabid,cvid,sequence,`columns`)
select @tabid,@cvid,0,'ld_quoteschange:quoteschange_no:quoteschange_no:QuotesChange_fieldlabel:V';
insert into ld_tabwithproductview(tabid,cvid,sequence,`columns`)
select @tabid,@cvid,1,'ld_quoteschange:change_type:change_type:QuotesChange_fieldlabel:V';
insert into ld_tabwithproductview(tabid,cvid,sequence,`columns`)
select @tabid,@cvid,2,'ld_quoteschange:accountid:account_id:QuotesChange_fieldlabel:V';
insert into ld_tabwithproductview(tabid,cvid,sequence,`columns`)
select @tabid,@cvid,3,'ld_quoteschange:change_date:change_date:QuotesChange_fieldlabel:V';
insert into ld_tabwithproductview(tabid,cvid,sequence,`columns`)
select @tabid,@cvid,4,'ld_quoteschange:approvestatus:approvestatus:QuotesChange_fieldlabel:V';
insert into ld_tabwithproductview(tabid,cvid,sequence,`columns`)
select @tabid,@cvid,5,'ld_quoteschange:currentapprover:currentapprover:QuotesChange_fieldlabel:V';
insert into ld_tabwithproductview(tabid,cvid,sequence,`columns`)
select @tabid,@cvid,6,'ld_quoteschange:total:hdnGrandTotal:QuotesChange_fieldlabel:V';
insert into ld_tabwithproductview(tabid,cvid,sequence,`columns`)
select @tabid,@cvid,7,'ld_quoteschange:smownerid:assigned_user_id:QuotesChange_fieldlabel:V';
insert into ld_tabwithproductview(tabid,cvid,sequence,`columns`)
select @tabid,@cvid,8,'ld_inventoryproductrelscf:pro_id:pro_id:Products_fieldlabel:V';
insert into ld_tabwithproductview(tabid,cvid,sequence,`columns`)
select @tabid,@cvid,9,'ld_products:productname:productname:Products_fieldlabel:V';
insert into ld_tabwithproductview(tabid,cvid,sequence,`columns`)
select @tabid,@cvid,10,'ld_inventoryproductrel:quantity:quantity:Products_fieldlabel:N';
delimiter;

select tabid into @tabid from ld_tab where name='QuotesChange';
select cvid into @cvid from ld_customview where entitytype='QuotesChange' and viewname='待审批';
delete from ld_cvadvfilter where cvid = @cvid;
insert into ld_cvadvfilter(cvid,columnindex,columnname,comparator,value,groupid,column_condition)
select @cvid,0,'ld_quoteschange:approvestatus:approvestatus:QuotesChange_fieldlabel:V','e','审批中',1,'';
delete from ld_cvadvfilter_grouping where cvid = @cvid;
insert into ld_cvadvfilter_grouping(groupid,cvid,group_condition,condition_expression)
select 1,@cvid,'',0;
DELETE from ld_tabwithproductview where tabid = @tabid and cvid = @cvid;
insert into ld_tabwithproductview(tabid,cvid,sequence,`columns`)
select @tabid,@cvid,0,'ld_quoteschange:quoteschange_no:quoteschange_no:QuotesChange_fieldlabel:V';
insert into ld_tabwithproductview(tabid,cvid,sequence,`columns`)
select @tabid,@cvid,1,'ld_quoteschange:change_type:change_type:QuotesChange_fieldlabel:V';
insert into ld_tabwithproductview(tabid,cvid,sequence,`columns`)
select @tabid,@cvid,2,'ld_quoteschange:accountid:account_id:QuotesChange_fieldlabel:V';
insert into ld_tabwithproductview(tabid,cvid,sequence,`columns`)
select @tabid,@cvid,3,'ld_quoteschange:change_date:change_date:QuotesChange_fieldlabel:V';
insert into ld_tabwithproductview(tabid,cvid,sequence,`columns`)
select @tabid,@cvid,4,'ld_quoteschange:approvestatus:approvestatus:QuotesChange_fieldlabel:V';
insert into ld_tabwithproductview(tabid,cvid,sequence,`columns`)
select @tabid,@cvid,5,'ld_quoteschange:currentapprover:currentapprover:QuotesChange_fieldlabel:V';
insert into ld_tabwithproductview(tabid,cvid,sequence,`columns`)
select @tabid,@cvid,6,'ld_quoteschange:total:hdnGrandTotal:QuotesChange_fieldlabel:V';
insert into ld_tabwithproductview(tabid,cvid,sequence,`columns`)
select @tabid,@cvid,7,'ld_quoteschange:smownerid:assigned_user_id:QuotesChange_fieldlabel:V';
insert into ld_tabwithproductview(tabid,cvid,sequence,`columns`)
select @tabid,@cvid,8,'ld_inventoryproductrelscf:pro_id:pro_id:Products_fieldlabel:V';
insert into ld_tabwithproductview(tabid,cvid,sequence,`columns`)
select @tabid,@cvid,9,'ld_products:productname:productname:Products_fieldlabel:V';
insert into ld_tabwithproductview(tabid,cvid,sequence,`columns`)
select @tabid,@cvid,10,'ld_inventoryproductrel:quantity:quantity:Products_fieldlabel:N';
delimiter;

select tabid into @tabid from ld_tab where name='QuotesChange';
select cvid into @cvid from ld_customview where entitytype='QuotesChange' and viewname='已审批';
delete from ld_cvadvfilter where cvid = @cvid;
insert into ld_cvadvfilter(cvid,columnindex,columnname,comparator,value,groupid,column_condition)
select @cvid,0,'ld_quoteschange:approvestatus:approvestatus:QuotesChange_fieldlabel:V','e','已批准',1,'';
delete from ld_cvadvfilter_grouping where cvid = @cvid;
insert into ld_cvadvfilter_grouping(groupid,cvid,group_condition,condition_expression)
select 1,@cvid,'',0;
DELETE from ld_tabwithproductview where tabid = @tabid and cvid = @cvid;
insert into ld_tabwithproductview(tabid,cvid,sequence,`columns`)
select @tabid,@cvid,0,'ld_quoteschange:quoteschange_no:quoteschange_no:QuotesChange_fieldlabel:V';
insert into ld_tabwithproductview(tabid,cvid,sequence,`columns`)
select @tabid,@cvid,1,'ld_quoteschange:change_type:change_type:QuotesChange_fieldlabel:V';
insert into ld_tabwithproductview(tabid,cvid,sequence,`columns`)
select @tabid,@cvid,2,'ld_quoteschange:accountid:account_id:QuotesChange_fieldlabel:V';
insert into ld_tabwithproductview(tabid,cvid,sequence,`columns`)
select @tabid,@cvid,3,'ld_quoteschange:change_date:change_date:QuotesChange_fieldlabel:V';
insert into ld_tabwithproductview(tabid,cvid,sequence,`columns`)
select @tabid,@cvid,4,'ld_quoteschange:approvestatus:approvestatus:QuotesChange_fieldlabel:V';
insert into ld_tabwithproductview(tabid,cvid,sequence,`columns`)
select @tabid,@cvid,5,'ld_quoteschange:currentapprover:currentapprover:QuotesChange_fieldlabel:V';
insert into ld_tabwithproductview(tabid,cvid,sequence,`columns`)
select @tabid,@cvid,6,'ld_quoteschange:total:hdnGrandTotal:QuotesChange_fieldlabel:V';
insert into ld_tabwithproductview(tabid,cvid,sequence,`columns`)
select @tabid,@cvid,7,'ld_quoteschange:smownerid:assigned_user_id:QuotesChange_fieldlabel:V';
insert into ld_tabwithproductview(tabid,cvid,sequence,`columns`)
select @tabid,@cvid,8,'ld_inventoryproductrelscf:pro_id:pro_id:Products_fieldlabel:V';
insert into ld_tabwithproductview(tabid,cvid,sequence,`columns`)
select @tabid,@cvid,9,'ld_products:productname:productname:Products_fieldlabel:V';
insert into ld_tabwithproductview(tabid,cvid,sequence,`columns`)
select @tabid,@cvid,10,'ld_inventoryproductrel:quantity:quantity:Products_fieldlabel:N';
delimiter;

select tabid into @tabid from ld_tab where name='QuotesChange';
select tabid into @related_tabid from ld_tab where name='reminds';
insert into ld_quickactions(tabid,related_tabid,sequence,presence,label)
select @tabid,@related_tabid,1,0,'创建提醒' from dual
where not EXISTS(select 1 from ld_quickactions where tabid=@tabid and related_tabid=@related_tabid);
insert into ld_quickactions(tabid,related_tabid,sequence,presence,label)
select @tabid,'-1',2,0,'修改日志' from dual
where not EXISTS(select 1 from ld_quickactions where tabid=@tabid and related_tabid='-1');
insert into ld_quickactions(tabid,related_tabid,sequence,presence,label)
select @tabid,'-10',3,0,'负责人变更记录' from dual
where not EXISTS(select 1 from ld_quickactions where tabid=@tabid and related_tabid='-10');
delimiter;

SELECT tabid into @tabid from ld_tab where name='QuotesChange';
insert into ld_quickactions(tabid,related_tabid,sequence,presence,label)
select @tabid,-5,5,0,'打印工具' from dual where not exists(select 1 from ld_quickactions where tabid=@tabid and related_tabid=-5);
delimiter;

select tabid into @tabid from ld_tab where name='QuotesChange';
select max(relation_id) into @maxrelation_id from ld_relatedlists;
insert into ld_relatedlists(relation_id, tabid,related_tabid,name,sequence,label,presence,actions,related_coltable,type)
select @maxrelation_id+1,@tabid,-1,'get_SharedUsers',1,'SharedUsers',0,'share','','' from dual
where not EXISTS(select 1 from ld_relatedlists where tabid=@tabid and related_tabid='-1' and name='get_SharedUsers');
delimiter;

select tabid into @tabid from ld_tab where name='QuotesChange';
select max(relation_id) into @maxrelation_id from ld_relatedlists;
insert into ld_relatedlists(relation_id, tabid,related_tabid,name,sequence,label,presence,actions,related_coltable,type)
select @maxrelation_id+1,@tabid,-7,'get_viewhistory',2,'ViewHistory',0,'','','' from dual
where not EXISTS(select 1 from ld_relatedlists where tabid=@tabid and related_tabid='-7' and name='get_viewhistory');
delimiter;

select tabid into @tabid from ld_tab where name='QuotesChange';
select tabid into @related_tabid from ld_tab where name='Attachment';
select max(relation_id) into @maxrelation_id from ld_relatedlists;
insert into ld_relatedlists(relation_id, tabid,related_tabid,name,sequence,label,presence,actions,related_coltable,type)
select @maxrelation_id+1,@tabid,@related_tabid,'get_attachment',3,'Attachment',0,'add','attachmentsforbills.related_to','datacategory_sql' from dual
where not EXISTS(select 1 from ld_relatedlists where tabid=@tabid and related_tabid=@related_tabid and name='get_attachment');
delimiter;

SELECT tabid into @tabid from ld_tab where name='QuotesChange';
insert into ld_def_org_share(tabid,permission,editstatus)
select @tabid,3,0 from DUAL
where not exists(select 1 from ld_def_org_share where tabid = @tabid);
delimiter;

call addtabintoprofile('QuotesChange',1);
delimiter;

select tabid into @tabid from ld_tab where `name` = 'Quotes';
SELECT tabid into @related_tabid from ld_tab where name='QuotesChange';
select sequence into @sequence from ld_relatedlists where tabid= @tabid and `name` ='get_salesorder';
select max(relation_id) into @maxrelation_id from ld_relatedlists;
update ld_relatedlists set sequence = sequence + 1000 where tabid = @tabid and sequence > @sequence;
insert into ld_relatedlists(relation_id, tabid,related_tabid,name,sequence,label,presence,actions,related_coltable,type)
select @maxrelation_id+1,@tabid,@related_tabid,'get_quoteschange',@sequence+1,'QuotesChange',0,'add','quoteschange.quoteid','datacategory_sql' from dual
where not EXISTS(select 1 from ld_relatedlists where tabid=@tabid and related_tabid=@related_tabid and name='get_quoteschange');
set @i=0;
update ld_relatedlists set sequence=(@i:=@i+1) where tabid = @tabid order by sequence;
delimiter;

select tabid into @tabid from ld_tab where `name` = 'QuotesChange';
update ld_field set defaultvalue = 'thistoday' where tabid = @tabid and columnname = 'change_date';
delimiter;

DROP PROCEDURE IF EXISTS `copy_producttoolfield`;
delimiter ||
CREATE PROCEDURE `copy_producttoolfield`(
	copymodule_tabid int(50),module_tabid int(50)
)
BEGIN
	declare done int default 0;
	DECLARE p_producttoolfieldid int default 0;
	DECLARE p_columnname VARCHAR(100);
	DECLARE p_allowhide VARCHAR(100);
	DECLARE p_fieldlabel VARCHAR(100);
	DECLARE p_defaultvalue VARCHAR(100);
	DECLARE p_presence int default 0;
	DECLARE p_uitype int default 0;
	DECLARE p_typeofdata VARCHAR(100);
	DECLARE p_sequence int default 0;
	DECLARE p_tabid int default 0;
	DECLARE p_tablename VARCHAR(100);
	DECLARE p_width VARCHAR(100);
	DECLARE p_edit_permission int default 0;
	DECLARE p_input_type int default 0;
	DECLARE p_fieldid int default 0;
	DECLARE p_newline int default 0;
	DECLARE p_defaultcolumn int default 0;
	DECLARE p_is_checkimportfield int default 0;
	DECLARE p_nullfield int default 0;
	DECLARE p_description VARCHAR(255);
	DECLARE p_max_id int default 0;
	declare p_max_formula_id int default 0;
	DECLARE p_cnt int default 0;


	declare cur1 CURSOR FOR select producttoolfieldid,columnname,allowhide,fieldlabel,defaultvalue,presence,uitype,typeofdata,sequence,tabid,tablename,width,edit_permission,input_type,
fieldid,newline,defaultcolumn,is_checkimportfield,nullfield,description from ld_producttoolfield where tabid= copymodule_tabid;
	declare continue handler for not found SET done =1;
	open cur1;
	fetch cur1 into p_producttoolfieldid,p_columnname,p_allowhide,p_fieldlabel,p_defaultvalue,p_presence,p_uitype,p_typeofdata,p_sequence,p_tabid,p_tablename,p_width,p_edit_permission,
	p_input_type,p_fieldid,p_newline,p_defaultcolumn,p_is_checkimportfield,p_nullfield,p_description;
	loop2: while done<>1 do
		select count(1) into p_cnt from ld_producttoolfield where columnname = p_columnname and tabid = module_tabid;
		if p_cnt = 0 then
			-- 分录明细表
			select max(producttoolfieldid) into p_max_id from ld_producttoolfield;
			insert into ld_producttoolfield(producttoolfieldid,columnname,allowhide,fieldlabel,defaultvalue,presence,uitype,typeofdata,sequence,tabid,tablename,width,edit_permission,input_type,
	fieldid,newline,defaultcolumn,is_checkimportfield,nullfield,description) values (p_max_id+1,p_columnname,p_allowhide,p_fieldlabel,p_defaultvalue,p_presence,p_uitype,p_typeofdata,p_sequence,module_tabid,p_tablename,p_width,p_edit_permission,
		p_input_type,p_fieldid,p_newline,p_defaultcolumn,p_is_checkimportfield,p_nullfield,p_description);

			-- 分录明细字段公式表
			if p_input_type = 2 THEN
				insert into ld_producttoolfield_formula(producttoolfieldid,formulastring,columnstring,sequence)
				select p_max_id+1,formulastring,columnstring,sequence from ld_producttoolfield_formula where producttoolfieldid = p_producttoolfieldid;
			end if;

			-- 分录明细字段翻译表
			insert into ld_tranlabel(languagetype,trantable,tabid,Relateid,fieldlabel)
			select 'zh','ld_producttoolfield',module_tabid,p_max_id+1,fieldlabel from ld_tranlabel where tabid = copymodule_tabid and Relateid = p_producttoolfieldid and trantable = 'ld_producttoolfield' and languagetype = 'zh';

			insert into ld_tranlabel(languagetype,trantable,tabid,Relateid,fieldlabel)
			select 'en','ld_producttoolfield',module_tabid,p_max_id+1,fieldlabel from ld_tranlabel where tabid = copymodule_tabid and Relateid = p_producttoolfieldid and trantable = 'ld_producttoolfield' and languagetype = 'en';
		end if;
	fetch cur1 into p_producttoolfieldid,p_columnname,p_allowhide,p_fieldlabel,p_defaultvalue,p_presence,p_uitype,p_typeofdata,p_sequence,p_tabid,p_tablename,p_width,p_edit_permission,
	p_input_type,p_fieldid,p_newline,p_defaultcolumn,p_is_checkimportfield,p_nullfield,p_description;
	end while loop2;
	close cur1;
END ||
delimiter;

select tabid into @copy_moduletabid from ld_tab where `name` = 'Quotes';
select tabid into @tabid from ld_tab where `name` = 'QuotesChange';
call copy_producttoolfield(@copy_moduletabid,@tabid);
delimiter;

select tabid into @tabid from ld_tab where `name` = 'QuotesChange';
update ld_producttoolfield set tablename = 'ld_quoteschange' where tablename = 'ld_quotes' and tabid = @tabid;
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','How_to_create_quoteschange','如何创建{$QuotesChange.QuotesChange}','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype = 'zh' and labelbol = 'How_to_create_quoteschange' and labeltype = 'fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','How_to_create_quoteschange','How to create a{$QuotesChange.QuotesChange}','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype = 'en' and labelbol = 'How_to_create_quoteschange' and labeltype = 'fixedstr');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','How_to_create_quoteschange_infos','{$QuotesChange.QuotesChange}是针对{$Quotes.Quotes}的，不允许直接新增，可通过{$Quotes.Quotes}关联新建。','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype = 'zh' and labelbol = 'How_to_create_quoteschange_infos' and labeltype = 'fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','How_to_create_quoteschange_infos','{$QuotesChange.QuotesChange} is for the {$Quotes.Quotes},direct creation is not allowed;You can create it by {$Quotes.Quotes}.','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype = 'en' and labelbol = 'How_to_create_quoteschange_infos' and labeltype = 'fixedstr');
delimiter;

select deploy_value,sequence,roottype,presence into @deploy_value,@sequence,@roottype,@presence from ld_systems_deploy where deploy_type = 5;
update ld_systems_deploy set sequence = sequence + 1000 where roottype = @roottype and sequence > @sequence;
insert into ld_systems_deploy(deploy_value,deploy_type,description,setype,sequence,roottype,inputtype,presence,inputvalue)
select @deploy_value,150,'报价变更单是否启用审批流程','QuotesChange',@sequence+1,@roottype,'select',@presence,'[{"value":"0","text":"YES"},{"value":"1","text":"NO"},{"sql":""}]' from dual
where not EXISTS(select 1 from ld_systems_deploy where deploy_type=150);
set @i=0;
update ld_systems_deploy set sequence=(@i:=@i+1) where roottype = @roottype order by sequence;
delimiter;

select tabid into @tabid from ld_tab where `name`='QuotesChange';
set @approvename='报价变更单审批流程';
select max(id) into @appid from ld_approve;
insert into ld_approve(id,tabid,`name`,`status`,smcreatorid,modifiedby,createdtime,modifiedtime,approveallocatetype,allowediting,allowantiapproval)
select @appid+1,@tabid,@approvename,0,1,1,now(),now(),0,0,0 from dual
where not exists (select 1 from ld_approve where tabid=@tabid and `name`=@approvename);

select id into @approveid from ld_approve where tabid=@tabid and `name`=@approvename;
select max(id) into @id from ld_approvestep;
select count(1) into @cnt from ld_approvestep where approveid=@approveid;
insert into ld_approvestep(id,approveid,`name`,ended,step,sequence,createdtime,modifiedtime,approvetype,approvevalue,specifyapproverid)
select @id+1,@approveid,'步骤一',1,1,1,now(),now(),0,1,1 from dual where @cnt=0;

insert into ld_approvestep(id,approveid,`name`,ended,step,sequence,createdtime,modifiedtime,approvetype,approvevalue,specifyapproverid)
select @id+2,@approveid,'步骤二',1,1,1,now(),now(),0,1,1 from dual where @cnt=0;
delimiter;

select tabid into @tabid from ld_tab where `name`='QuotesChange';
update ld_field set approve_demand = 1 where tabid = @tabid and columnname = 'quoteid';
delimiter;

call AddColumn('ld_inventoryproductrelscf','pro_id','int','11',0);
select tabid into @tabid from ld_tab where `name`='QuotesChange';
select max(producttoolfieldid) into @producttoolfieldid from ld_producttoolfield;
update ld_producttoolfield set sequence = sequence + 1000 where tabid = @tabid;
insert into ld_producttoolfield(producttoolfieldid,columnname,allowhide,fieldlabel,presence,uitype,typeofdata,sequence,tabid,tablename,width,edit_permission,input_type,fieldid,newline,
defaultcolumn,is_checkimportfield,nullfield,description)
select @producttoolfieldid+1,'pro_id','no','产品名称(变更前)',0,188,'V~M~100',1,@tabid,'ld_inventoryproductrelscf',40,1,0,0,0,3,0,1,NULL from DUAL
where not exists(select 1 from ld_producttoolfield where tabid = @tabid and columnname = 'pro_id');
set @i=0;
update ld_producttoolfield set sequence=(@i:=@i+1) where tabid = @tabid order by sequence;
delimiter;

select tabid into @tabid from ld_tab where `name`='QuotesChange';
select producttoolfieldid into @producttoolfieldid from ld_producttoolfield where tabid = @tabid and columnname = 'pro_id';
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'zh','ld_producttoolfield',@tabid,@producttoolfieldid,'产品名称（更换前）' from DUAL
where not exists(select 1 from ld_tranlabel where tabid =@tabid and Relateid = @producttoolfieldid and languagetype = 'zh' and trantable = 'ld_producttoolfield');
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'en','ld_producttoolfield',@tabid,@producttoolfieldid,'Product name(Before replacement)' from DUAL
where not exists(select 1 from ld_tranlabel where tabid =@tabid and Relateid = @producttoolfieldid and languagetype = 'en' and trantable = 'ld_producttoolfield');
delimiter;

select tabid into @tabid from ld_tab where `name`='QuotesChange';
select producttoolfieldid into @producttoolfieldid from ld_producttoolfield where tabid = @tabid and columnname = 'productname';
update ld_tranlabel set fieldlabel = '产品名称（更换后）' where tabid= @tabid and Relateid = @producttoolfieldid and languagetype = 'zh' and trantable = 'ld_producttoolfield';
update ld_tranlabel set fieldlabel = 'Product name(After replacement)' where tabid= @tabid and Relateid = @producttoolfieldid and languagetype = 'en' and trantable = 'ld_producttoolfield';
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','thereisnochangedonline','第{num}行更换前后没有变化，保存失败。','jspop' from dual
where not exists(select 1 from ld_desk where languagetype = 'zh' and labelbol = 'thereisnochangedonline' and labeltype = 'jspop');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','thereisnochangedonline','There is no changed on line {num}.','jspop' from dual
where not exists(select 1 from ld_desk where languagetype = 'en' and labelbol = 'thereisnochangedonline' and labeltype = 'jspop');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','replacement','更换','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype = 'zh' and labelbol = 'replacement' and labeltype = 'fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','replacement','Replacement','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype = 'en' and labelbol = 'replacement' and labeltype = 'fixedstr');
delimiter;

CREATE TABLE IF NOT EXISTS `ld_quoteschange` (
  `quoteschangeid` int(11) NOT NULL AUTO_INCREMENT,
  `quoteschange_no` varchar(100) DEFAULT NULL,
  `change_date` date DEFAULT NULL,
  `change_type` varchar(255) DEFAULT NULL,
  `smownerid` int(11) DEFAULT '0',
  `smcreatorid` int(11) DEFAULT '0',
  `accountid` int(11) DEFAULT '0',
  `quoteid` int(11) DEFAULT '0',
  `approvestatus` varchar(200) DEFAULT '未提交',
  `approveby` int(11) DEFAULT '0',
  `currentapprover` int(11) DEFAULT '0',
  `modifiedby` int(11) DEFAULT '0',
  `createdtime` datetime DEFAULT NULL,
  `modifiedtime` datetime DEFAULT NULL,
  `adjustment` decimal(25,6) DEFAULT NULL,
  `subtotal` decimal(25,6) DEFAULT NULL,
  `total` decimal(25,6) DEFAULT NULL,
  `discount_amount` decimal(25,6) DEFAULT NULL,
  `discount_percent` decimal(25,2) DEFAULT NULL,
  `discount_type` int(2) DEFAULT '0',
  `currency_id` int(19) DEFAULT '1',
  `conversion_rate` decimal(25,6) DEFAULT NULL,
  `currency_symbol` varchar(30) DEFAULT NULL,
  `description` text,
  `terms_conditions` text,
  `deleted` int(11) DEFAULT '0',
  PRIMARY KEY (`quoteschangeid`)
) ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=utf8;
delimiter;

CREATE TABLE IF NOT EXISTS `ld_quoteschangescf` (
  `quoteschangeid` int(11) NOT NULL AUTO_INCREMENT,
  PRIMARY KEY (`quoteschangeid`)
) ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=utf8;
delimiter;

select tabid into @tabid from ld_tab where `name`='QuotesChange';
insert into ld_org_share_action2tab(share_action_id,tabid)
select  0 ,@tabid from dual where not exists(select 1 from ld_org_share_action2tab where tabid=@tabid and share_action_id=0);
insert into ld_org_share_action2tab(share_action_id,tabid)
select  1 ,@tabid from dual where not exists(select 1 from ld_org_share_action2tab where tabid=@tabid and share_action_id=1);
insert into ld_org_share_action2tab(share_action_id,tabid)
select  2,@tabid from dual where not exists(select 1 from ld_org_share_action2tab where tabid=@tabid and share_action_id=2);
insert into ld_org_share_action2tab(share_action_id,tabid)
select  3,@tabid from dual where not exists(select 1 from ld_org_share_action2tab where tabid=@tabid and share_action_id=3);
delimiter;

select tabid into @tabid from ld_tab where `name`='QuotesChange';
update ld_field set allowhide = 'no' where tabid = @tabid and columnname in ('quoteschange_no','accountid','change_date','smownerid','quoteid','total');
delimiter;

DROP PROCEDURE IF EXISTS `copy_producttoolfield`;
delimiter;
-- 2017-10-30

select tabid into @tabid from ld_tab where `name` = 'QuotesChange';
select fieldid into @fieldid from ld_field where tabid = @tabid and columnname = 'quoteschange_no';
select fieldid into @quo_fieldid from ld_field where tabid = @tabid and columnname = 'quoteid';
update ld_tranlabel set fieldlabel = 'Bill NO' where tabid = @tabid and Relateid = @fieldid and trantable = 'ld_field' and languagetype = 'en';
update ld_tranlabel set fieldlabel = 'Quote No' where tabid = @tabid and Relateid = @quo_fieldid and trantable = 'ld_field' and languagetype = 'en';
update ld_field set masseditable = 0 where tabid = @tabid and columnname = 'smownerid' and uitype = 53;
delimiter;

select tabid into @tabid from ld_tab where name='QuotesChange';
select max(relation_id) into @maxrelation_id from ld_relatedlists;
insert into ld_relatedlists(relation_id, tabid,related_tabid,name,sequence,label,presence,actions,related_coltable,type)
select @maxrelation_id+1,@tabid,-11,'get_print',4,'Print',0,'','','' from dual 
where not EXISTS(select 1 from ld_relatedlists where tabid=@tabid and related_tabid='-11' and name='get_print');
delimiter;

select tabid into @tabid from ld_tab where name='Vendors';
update ld_relatedlists set wx_presence=presence 
where tabid=@tabid and label in ('Products','VendorContact','VendorContactRecords');
delimiter;

call addtableIndex('ld_modtracker_detail','idx_ld_modtracker_detail_id','id'); 
delimiter;

update ld_desk set fieldlabel='该单据未审批，不允许创建相关联的单据！' 
where labelbol='NOTCREATERELVANTBILL' and languagetype='zh';
delimiter;
update ld_desk set fieldlabel='The record has not approved, not allow to create a relevant bill!' 
where labelbol='NOTCREATERELVANTBILL' and languagetype='en';
delimiter;
delete from ld_desk where labelbol='theorderisnotapproved';
delimiter;
update ld_desk set fieldlabel='您的权限不足，无权操作任何银行账户！' 
where labelbol='INSUFFICIENTPRIVILEGES' and languagetype='zh';
delimiter;
update ld_desk set fieldlabel='You have insufficient privileges, no access to operate any bank account!' 
where labelbol='INSUFFICIENTPRIVILEGES' and languagetype='en';
delimiter;
-- 2017-11-05

SELECT tabid INTO @tabid FROM ld_tab WHERE `name`='Contacts';
UPDATE ld_field SET fieldname='bill_country',uitype=15,defaultvalue='中国' WHERE tabid=@tabid AND columnname='mailingcountry' 
	AND NOT EXISTS (SELECT 1 FROM ld_contactdetails);

UPDATE ld_field SET fieldname='bill_state',uitype=15 WHERE tabid=@tabid AND columnname='mailingstate' 
	AND NOT EXISTS (SELECT 1 FROM ld_contactdetails);

UPDATE ld_field SET fieldname='bill_city',uitype=15 WHERE tabid=@tabid AND columnname='mailingcity' 
	AND NOT EXISTS (SELECT 1 FROM ld_contactdetails);

SELECT tabid INTO @tabid FROM ld_tab WHERE `name`='Contacts';
DELETE FROM ld_picklist_dependency WHERE tabid=@tabid AND sourcefield in ('bill_country','bill_state');

SELECT max(id) INTO @id FROM ld_picklist_dependency;
INSERT INTO ld_picklist_dependency(id,tabid,sourcefield,targetfield,sourcevalue,targetvalues)
SELECT (@id:=@id+1),@tabid,sourcefield,targetfield,sourcevalue,targetvalues FROM ld_picklist_dependency WHERE tabid=6 AND sourcefield in ('bill_country','bill_state');
delimiter;

DELETE FROM ld_bill_city WHERE bill_city='闸北区';
UPDATE ld_account SET bill_city='静安区' WHERE bill_city='闸北区';
UPDATE ld_vendor SET bill_city='静安区' WHERE bill_city='闸北区';

UPDATE ld_field SET presence=0 WHERE tabid=4 AND columnname IN ('mailingcountry','mailingstate','mailingcity','mailingzip','mailingstreet')
	AND NOT EXISTS (SELECT 1 FROM ld_contactdetails);
    
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','business','工商','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype = 'zh' and labelbol = 'business' and labeltype = 'fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','business','Business','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype = 'en' and labelbol = 'business' and labeltype = 'fixedstr');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','thecustomerbusiness','该客户工商信息不存在！','jspop' from dual
where not exists(select 1 from ld_desk where languagetype = 'zh' and labelbol = 'thecustomerbusiness' and labeltype = 'jspop');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','thecustomerbusiness','The customer business information does not exist!','jspop' from dual
where not exists(select 1 from ld_desk where languagetype = 'en' and labelbol = 'thecustomerbusiness' and labeltype = 'jspop');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','thecustomerbusiness','该客户工商信息不存在！','jspop' from dual
where not exists(select 1 from ld_desk where languagetype = 'zh' and labelbol = 'thecustomerbusiness' and labeltype = 'jspop');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','thecustomerbusiness','The customer business information does not exist!','jspop' from dual
where not exists(select 1 from ld_desk where languagetype = 'en' and labelbol = 'thecustomerbusiness' and labeltype = 'jspop');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','creditCode','统一社会信用代码','jspop' from dual
where not exists(select 1 from ld_desk where languagetype = 'zh' and labelbol = 'creditCode' and labeltype = 'jspop');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','creditCode','CreditCode','jspop' from dual
where not exists(select 1 from ld_desk where languagetype = 'en' and labelbol = 'creditCode' and labeltype = 'jspop');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','regNumber','注册号','jspop' from dual
where not exists(select 1 from ld_desk where languagetype = 'zh' and labelbol = 'regNumber' and labeltype = 'jspop');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','regNumber','RegNumber','jspop' from dual
where not exists(select 1 from ld_desk where languagetype = 'en' and labelbol = 'regNumber' and labeltype = 'jspop');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','companyOrgType','企业类型','jspop' from dual
where not exists(select 1 from ld_desk where languagetype = 'zh' and labelbol = 'companyOrgType' and labeltype = 'jspop');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','companyOrgType','CompanyOrgType','jspop' from dual
where not exists(select 1 from ld_desk where languagetype = 'en' and labelbol = 'companyOrgType' and labeltype = 'jspop');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','estiblishTime','注册时间','jspop' from dual
where not exists(select 1 from ld_desk where languagetype = 'zh' and labelbol = 'estiblishTime' and labeltype = 'jspop');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','estiblishTime','EstiblishTime','jspop' from dual
where not exists(select 1 from ld_desk where languagetype = 'en' and labelbol = 'estiblishTime' and labeltype = 'jspop');
delimiter;


insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','legalPersonName','法定代表人','jspop' from dual
where not exists(select 1 from ld_desk where languagetype = 'zh' and labelbol = 'legalPersonName' and labeltype = 'jspop');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','legalPersonName','LegalPersonName','jspop' from dual
where not exists(select 1 from ld_desk where languagetype = 'en' and labelbol = 'legalPersonName' and labeltype = 'jspop');
delimiter;


insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','regCapital','注册资本','jspop' from dual
where not exists(select 1 from ld_desk where languagetype = 'zh' and labelbol = 'regCapital' and labeltype = 'jspop');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','regCapital','RegCapital','jspop' from dual
where not exists(select 1 from ld_desk where languagetype = 'en' and labelbol = 'regCapital' and labeltype = 'jspop');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','toTime','营业期限','jspop' from dual
where not exists(select 1 from ld_desk where languagetype = 'zh' and labelbol = 'toTime' and labeltype = 'jspop');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','toTime','ToTime','jspop' from dual
where not exists(select 1 from ld_desk where languagetype = 'en' and labelbol = 'toTime' and labeltype = 'jspop');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','regInstitute','登记机关','jspop' from dual
where not exists(select 1 from ld_desk where languagetype = 'zh' and labelbol = 'regInstitute' and labeltype = 'jspop');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','regInstitute','RegInstitute','jspop' from dual
where not exists(select 1 from ld_desk where languagetype = 'en' and labelbol = 'regInstitute' and labeltype = 'jspop');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','approvedTime','核准日期','jspop' from dual
where not exists(select 1 from ld_desk where languagetype = 'zh' and labelbol = 'approvedTime' and labeltype = 'jspop');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','approvedTime','ApprovedTime','jspop' from dual
where not exists(select 1 from ld_desk where languagetype = 'en' and labelbol = 'approvedTime' and labeltype = 'jspop');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','businessScope','经营范围','jspop' from dual
where not exists(select 1 from ld_desk where languagetype = 'zh' and labelbol = 'businessScope' and labeltype = 'jspop');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','businessScope','BusinessScope','jspop' from dual
where not exists(select 1 from ld_desk where languagetype = 'en' and labelbol = 'businessScope' and labeltype = 'jspop');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','regLocation','注册地址','jspop' from dual
where not exists(select 1 from ld_desk where languagetype = 'zh' and labelbol = 'regLocation' and labeltype = 'jspop');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','regLocation','RegLocation','jspop' from dual
where not exists(select 1 from ld_desk where languagetype = 'en' and labelbol = 'regLocation' and labeltype = 'jspop');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','regStatus','经营状态','jspop' from dual
where not exists(select 1 from ld_desk where languagetype = 'zh' and labelbol = 'regStatus' and labeltype = 'jspop');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','regStatus','RegStatus','jspop' from dual
where not exists(select 1 from ld_desk where languagetype = 'en' and labelbol = 'regStatus' and labeltype = 'jspop');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','industry','行业','jspop' from dual
where not exists(select 1 from ld_desk where languagetype = 'zh' and labelbol = 'industry' and labeltype = 'jspop');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','industry','Industry','jspop' from dual
where not exists(select 1 from ld_desk where languagetype = 'en' and labelbol = 'industry' and labeltype = 'jspop');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','orgNumber','组织机构代码','jspop' from dual
where not exists(select 1 from ld_desk where languagetype = 'zh' and labelbol = 'orgNumber' and labeltype = 'jspop');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','orgNumber','OrgNumber','jspop' from dual
where not exists(select 1 from ld_desk where languagetype = 'en' and labelbol = 'orgNumber' and labeltype = 'jspop');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','COMPANYNAME','公司名称','jspop' from dual
where not exists(select 1 from ld_desk where languagetype = 'zh' and labelbol = 'COMPANYNAME' and labeltype = 'jspop');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','COMPANYNAME','Company Name','jspop' from dual
where not exists(select 1 from ld_desk where languagetype = 'en' and labelbol = 'COMPANYNAME' and labeltype = 'jspop');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','pleaseenterthename','请输入客户工商名称！','jspop' from dual
where not exists(select 1 from ld_desk where languagetype = 'zh' and labelbol = 'pleaseenterthename' and labeltype = 'jspop');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','pleaseenterthename','Please enter the name of customer business name!','jspop' from dual
where not exists(select 1 from ld_desk where languagetype = 'en' and labelbol = 'pleaseenterthename' and labeltype = 'jspop');
delimiter;

select tabid into @tabid from ld_tab where name='QuotesChange';
select max(relation_id) into @maxrelation_id from ld_relatedlists;
select sequence into @sequence from ld_relatedlists where tabid = @tabid and `name` = 'get_attachment';
update ld_relatedlists set sequence = sequence + 1000 where tabid = @tabid and sequence > @sequence;
insert into ld_relatedlists(relation_id, tabid,related_tabid,name,sequence,label,presence,actions,related_coltable,type)
select @maxrelation_id+1,@tabid,-10,'get_changeview',@sequence+1,'ChangeView',0,'','','' from dual 
where not EXISTS(select 1 from ld_relatedlists where tabid=@tabid and related_tabid='-10' and name='get_changeview');
set @i=0;
update ld_relatedlists set sequence=(@i:=@i+1) where tabid = @tabid order by sequence;
delimiter;
-- 2017-11-08

UPDATE ld_blockdisplay SET is_display=1 WHERE NOT EXISTS (SELECT 1 FROM ld_account);

UPDATE ld_field SET typeofdata='D~M~OTH~GE~startdate~startdate' WHERE tabid=26 AND columnname='closingdate'
	AND NOT EXISTS (SELECT 1 FROM ld_campaign);
    
SELECT fieldid INTO @relateid FROM ld_field WHERE tabid=29 AND columnname='scopeauthority';
UPDATE ld_tranlabel SET fieldlabel='业务单据数据范围' WHERE Relateid=@relateid AND tabid=29 AND fieldlabel='业务单据授权范围';
delimiter;

DROP PROCEDURE IF EXISTS `ldcrm_reset_relatedlists`;
delimiter ||
CREATE PROCEDURE `ldcrm_reset_relatedlists`(
)
BEGIN

	DECLARE tmp_tabid INT(19) DEFAULT 0; 

	DECLARE MYCUSOR CURSOR FOR SELECT DISTINCT tabid FROM ld_relatedlists ORDER BY tabid;
	DECLARE CONTINUE HANDLER FOR SQLSTATE '02000' SET tmp_tabid = NULL;

	IF NOT EXISTS (SELECT 1 FROM ld_crmentity WHERE crmid>2) THEN

		UPDATE ld_relatedlists SET presence=1;

		OPEN MYCUSOR; 
		Fetch MYCUSOR INTO tmp_tabid;
		WHILE(tmp_tabid IS NOT NULL) DO
			UPDATE ld_relatedlists SET sequence=sequence+100 WHERE tabid=tmp_tabid;
			SET @i=0;
			UPDATE ld_relatedlists SET presence=0,sequence=(@i:=@i+1) WHERE tabid=tmp_tabid AND `name`='get_projectabstract';	
			UPDATE ld_relatedlists SET presence=0,sequence=(@i:=@i+1) WHERE tabid=tmp_tabid AND `name`='get_product_pricebooks' AND tabid=14;	
			UPDATE ld_relatedlists SET presence=0,sequence=(@i:=@i+1) WHERE tabid=tmp_tabid AND `name`='get_WorkReport';
			UPDATE ld_relatedlists SET presence=0,sequence=(@i:=@i+1) WHERE tabid=tmp_tabid AND `name`='get_accounts';
			UPDATE ld_relatedlists SET presence=0,sequence=(@i:=@i+1) WHERE tabid=tmp_tabid AND `name`='get_contacts';
			UPDATE ld_relatedlists SET presence=1 WHERE tabid=tmp_tabid AND `name`='get_contacts' AND tabid IN (14);
			UPDATE ld_relatedlists SET presence=0,sequence=(@i:=@i+1) WHERE tabid=tmp_tabid AND label='VendorContact';
			UPDATE ld_relatedlists SET presence=0,sequence=(@i:=@i+1) WHERE tabid=tmp_tabid AND `name`='get_contactrecords';
			UPDATE ld_relatedlists SET presence=0,sequence=(@i:=@i+1) WHERE tabid=tmp_tabid AND `label`='VendorContactRecords';	
			UPDATE ld_relatedlists SET presence=0,sequence=(@i:=@i+1) WHERE tabid=tmp_tabid AND `name`='get_opportunities';
			UPDATE ld_relatedlists SET presence=1 WHERE tabid=tmp_tabid AND `name`='get_opportunities' AND tabid IN (14);
			UPDATE ld_relatedlists SET presence=0,sequence=(@i:=@i+1) WHERE tabid=tmp_tabid AND `name`='get_quotes';	
			UPDATE ld_relatedlists SET presence=1 WHERE tabid=tmp_tabid AND `name`='get_quotes' AND tabid IN (14);
			UPDATE ld_relatedlists SET presence=0,sequence=(@i:=@i+1) WHERE tabid=tmp_tabid AND `name`='get_salesorder';
			UPDATE ld_relatedlists SET presence=1 WHERE tabid=tmp_tabid AND `name`='get_salesorder' AND tabid IN (14);
			UPDATE ld_relatedlists SET presence=0,sequence=(@i:=@i+1) WHERE tabid=tmp_tabid AND label='PurchaseOrder';
			UPDATE ld_relatedlists SET presence=1 WHERE tabid=tmp_tabid AND label='PurchaseOrder' AND tabid IN (14);
			UPDATE ld_relatedlists SET presence=0,sequence=(@i:=@i+1) WHERE tabid=tmp_tabid AND `name`='get_ServiceContracts';	
			UPDATE ld_relatedlists SET presence=1 WHERE tabid=tmp_tabid AND `name`='get_ServiceContracts' AND tabid IN (14);
			UPDATE ld_relatedlists SET presence=0,sequence=(@i:=@i+1) WHERE tabid=tmp_tabid AND `name`='get_tickets';
			UPDATE ld_relatedlists SET presence=1 WHERE tabid=tmp_tabid AND `name`='get_tickets' AND tabid IN (14,22);
			UPDATE ld_relatedlists SET presence=0,sequence=(@i:=@i+1) WHERE tabid=tmp_tabid AND `name`='get_servicereturn';	
			UPDATE ld_relatedlists SET presence=0,sequence=(@i:=@i+1) WHERE tabid=tmp_tabid AND `name`='get_invoices';
			UPDATE ld_relatedlists SET presence=1 WHERE tabid=tmp_tabid AND `name`='get_invoices' AND tabid IN (14);
			UPDATE ld_relatedlists SET presence=0,sequence=(@i:=@i+1) WHERE tabid=tmp_tabid AND `name`='get_purchaseinvoice';
			UPDATE ld_relatedlists SET presence=0,sequence=(@i:=@i+1) WHERE tabid=tmp_tabid AND `name`='get_paymentplan';	
			UPDATE ld_relatedlists SET presence=0,sequence=(@i:=@i+1) WHERE tabid=tmp_tabid AND `name`='get_sendpayment';	
			UPDATE ld_relatedlists SET presence=0,sequence=(@i:=@i+1) WHERE tabid=tmp_tabid AND `name`='get_cashbill';	
			UPDATE ld_relatedlists SET presence=0,sequence=(@i:=@i+1) WHERE tabid=tmp_tabid AND `name`='get_sendcashbill';	
			UPDATE ld_relatedlists SET presence=0,sequence=(@i:=@i+1) WHERE tabid=tmp_tabid AND `name`='get_outorder';	
			UPDATE ld_relatedlists SET presence=0,sequence=(@i:=@i+1) WHERE tabid=tmp_tabid AND `name`='get_stock';	
			UPDATE ld_relatedlists SET presence=0,sequence=(@i:=@i+1) WHERE tabid=tmp_tabid AND `name`='get_commission';	
			UPDATE ld_relatedlists SET presence=0,sequence=(@i:=@i+1) WHERE tabid=tmp_tabid AND `name`='get_expense';	
			UPDATE ld_relatedlists SET presence=0,sequence=(@i:=@i+1) WHERE tabid=tmp_tabid AND `name`='get_salesback';	
			UPDATE ld_relatedlists SET presence=0,sequence=(@i:=@i+1) WHERE tabid=tmp_tabid AND `name`='get_purchaseback';	
			UPDATE ld_relatedlists SET presence=0,sequence=(@i:=@i+1) WHERE tabid=tmp_tabid AND `name`='get_cashback';	
			UPDATE ld_relatedlists SET presence=0,sequence=(@i:=@i+1) WHERE tabid=tmp_tabid AND `name`='get_purchasecashback';

			UPDATE ld_relatedlists SET presence=0,sequence=(@i:=@i+1) WHERE tabid=tmp_tabid AND `name`='get_project';	
			UPDATE ld_relatedlists SET presence=1 WHERE tabid=tmp_tabid AND `name`='get_project' AND tabid IN (14,22);
			UPDATE ld_relatedlists SET presence=0,sequence=(@i:=@i+1) WHERE tabid=tmp_tabid AND `name`='get_dependents_list' AND label='ProjectTask';	
			UPDATE ld_relatedlists SET presence=0,sequence=(@i:=@i+1) WHERE tabid=tmp_tabid AND `name`='get_dependents_list' AND label='ProjectProgress';
			UPDATE ld_relatedlists SET presence=0,sequence=(@i:=@i+1) WHERE tabid=tmp_tabid AND `name`='get_dependents_list' AND label='ProjectMilestone';
			UPDATE ld_relatedlists SET presence=0,sequence=(@i:=@i+1) WHERE tabid=tmp_tabid AND `name`='get_tickets' AND tabid=48;
			UPDATE ld_relatedlists SET presence=0,sequence=(@i:=@i+1) WHERE tabid=tmp_tabid AND `name`='get_campaigns';	
			UPDATE ld_relatedlists SET presence=0,sequence=(@i:=@i+1) WHERE tabid=tmp_tabid AND `name`='get_reminds';	
			UPDATE ld_relatedlists SET presence=0,sequence=(@i:=@i+1) WHERE tabid=tmp_tabid AND `name`='get_attachment';	
			UPDATE ld_relatedlists SET presence=0,sequence=(@i:=@i+1) WHERE tabid=tmp_tabid AND `name`='get_print';	

			SET @i=0;
			UPDATE ld_relatedlists SET sequence=(@i:=@i+1) WHERE tabid=tmp_tabid ORDER BY sequence;
			
			Fetch MYCUSOR INTO tmp_tabid;
		END WHILE;
		CLOSE MYCUSOR;
	END IF;
end ||
delimiter;

CALL ldcrm_reset_relatedlists;
DROP PROCEDURE IF EXISTS `ldcrm_reset_relatedlists`;

DROP PROCEDURE IF EXISTS `ldcrm_reset_quickactions`;
delimiter ||
CREATE PROCEDURE `ldcrm_reset_quickactions`(
)
BEGIN

	IF NOT EXISTS (SELECT 1 FROM ld_crmentity WHERE crmid>2) THEN

		UPDATE ld_quickactions SET presence=1;

		SET @tabname='Accounts';
		SELECT tabid INTO @tabid FROM ld_tab WHERE `name`=@tabname;
		UPDATE ld_quickactions SET sequence=sequence+100 WHERE tabid=@tabid;

		SET @i=0;
		UPDATE ld_quickactions SET presence=0,sequence=(@i:=@i+1) WHERE related_tabid=(SELECT tabid FROM ld_tab WHERE `name`='Contacts') AND tabid=@tabid; 
		UPDATE ld_quickactions SET presence=0,sequence=(@i:=@i+1) WHERE related_tabid=(SELECT tabid FROM ld_tab WHERE `name`='ContactRecords') AND tabid=@tabid; 
		UPDATE ld_quickactions SET presence=0,sequence=(@i:=@i+1) WHERE related_tabid=(SELECT tabid FROM ld_tab WHERE `name`='Potentials') AND tabid=@tabid; 
		UPDATE ld_quickactions SET presence=0,sequence=(@i:=@i+1) WHERE related_tabid=(SELECT tabid FROM ld_tab WHERE `name`='Quotes') AND tabid=@tabid; 
		UPDATE ld_quickactions SET presence=0,sequence=(@i:=@i+1) WHERE related_tabid=(SELECT tabid FROM ld_tab WHERE `name`='SalesOrder') AND tabid=@tabid; 
		UPDATE ld_quickactions SET presence=0,sequence=(@i:=@i+1) WHERE related_tabid=(SELECT tabid FROM ld_tab WHERE `name`='ServiceContracts') AND tabid=@tabid; 
		UPDATE ld_quickactions SET presence=0,sequence=(@i:=@i+1) WHERE related_tabid=(SELECT tabid FROM ld_tab WHERE `name`='Reminds') AND tabid=@tabid; 
		UPDATE ld_quickactions SET presence=0,sequence=(@i:=@i+1) WHERE related_tabid=(SELECT tabid FROM ld_tab WHERE `name`='Calendar') AND tabid=@tabid; 
		UPDATE ld_quickactions SET presence=0,sequence=(@i:=@i+1) WHERE related_tabid=(SELECT tabid FROM ld_tab WHERE `name`='Attachment') AND tabid=@tabid; 
		UPDATE ld_quickactions SET presence=1,sequence=(@i:=@i+1) WHERE related_tabid=(SELECT tabid FROM ld_tab WHERE `name`='MassSMS') AND tabid=@tabid;

		SET @i=0;
		UPDATE ld_quickactions SET sequence=(@i:=@i+1) WHERE tabid=@tabid ORDER BY sequence;

		SET @tabname='Contacts';
		SELECT tabid INTO @tabid FROM ld_tab WHERE `name`=@tabname;
		UPDATE ld_quickactions SET sequence=sequence+100 WHERE tabid=@tabid;

		SET @i=0;
		UPDATE ld_quickactions SET presence=0,sequence=(@i:=@i+1) WHERE related_tabid=(SELECT tabid FROM ld_tab WHERE `name`='ContactRecords') AND tabid=@tabid; 
		UPDATE ld_quickactions SET presence=0,sequence=(@i:=@i+1) WHERE related_tabid=(SELECT tabid FROM ld_tab WHERE `name`='Potentials') AND tabid=@tabid; 
		UPDATE ld_quickactions SET presence=0,sequence=(@i:=@i+1) WHERE related_tabid=(SELECT tabid FROM ld_tab WHERE `name`='Quotes') AND tabid=@tabid; 
		UPDATE ld_quickactions SET presence=0,sequence=(@i:=@i+1) WHERE related_tabid=(SELECT tabid FROM ld_tab WHERE `name`='SalesOrder') AND tabid=@tabid; 
		UPDATE ld_quickactions SET presence=0,sequence=(@i:=@i+1) WHERE related_tabid=(SELECT tabid FROM ld_tab WHERE `name`='ServiceContracts') AND tabid=@tabid; 
		UPDATE ld_quickactions SET presence=0,sequence=(@i:=@i+1) WHERE related_tabid=(SELECT tabid FROM ld_tab WHERE `name`='Reminds') AND tabid=@tabid; 
		UPDATE ld_quickactions SET presence=0,sequence=(@i:=@i+1) WHERE related_tabid=(SELECT tabid FROM ld_tab WHERE `name`='Calendar') AND tabid=@tabid; 
		UPDATE ld_quickactions SET presence=0,sequence=(@i:=@i+1) WHERE related_tabid=(SELECT tabid FROM ld_tab WHERE `name`='Attachment') AND tabid=@tabid; 
		UPDATE ld_quickactions SET presence=1,sequence=(@i:=@i+1) WHERE related_tabid=(SELECT tabid FROM ld_tab WHERE `name`='MassSMS') AND tabid=@tabid;

		SET @i=0;
		UPDATE ld_quickactions SET sequence=(@i:=@i+1) WHERE tabid=@tabid ORDER BY sequence;

		SET @tabname='ContactRecords';
		SELECT tabid INTO @tabid FROM ld_tab WHERE `name`=@tabname;
		UPDATE ld_quickactions SET sequence=sequence+100 WHERE tabid=@tabid;

		SET @i=0;
		UPDATE ld_quickactions SET presence=0,sequence=(@i:=@i+1) WHERE related_tabid=(SELECT tabid FROM ld_tab WHERE `name`='Reminds') AND tabid=@tabid; 
		UPDATE ld_quickactions SET presence=0,sequence=(@i:=@i+1) WHERE related_tabid=(SELECT tabid FROM ld_tab WHERE `name`='Attachment') AND tabid=@tabid; 

		SET @i=0;
		UPDATE ld_quickactions SET sequence=(@i:=@i+1) WHERE tabid=@tabid ORDER BY sequence;

		SET @tabname='Potentials';
		SELECT tabid INTO @tabid FROM ld_tab WHERE `name`=@tabname;
		UPDATE ld_quickactions SET sequence=sequence+100 WHERE tabid=@tabid;

		SET @i=0;
		UPDATE ld_quickactions SET presence=0,sequence=(@i:=@i+1) WHERE related_tabid=(SELECT tabid FROM ld_tab WHERE `name`='ContactRecords') AND tabid=@tabid; 
		UPDATE ld_quickactions SET presence=0,sequence=(@i:=@i+1) WHERE related_tabid=(SELECT tabid FROM ld_tab WHERE `name`='Quotes') AND tabid=@tabid; 
		UPDATE ld_quickactions SET presence=0,sequence=(@i:=@i+1) WHERE related_tabid=(SELECT tabid FROM ld_tab WHERE `name`='SalesOrder') AND tabid=@tabid; 
		UPDATE ld_quickactions SET presence=0,sequence=(@i:=@i+1) WHERE related_tabid=(SELECT tabid FROM ld_tab WHERE `name`='ServiceContracts') AND tabid=@tabid; 
		UPDATE ld_quickactions SET presence=0,sequence=(@i:=@i+1) WHERE related_tabid=(SELECT tabid FROM ld_tab WHERE `name`='Reminds') AND tabid=@tabid; 
		UPDATE ld_quickactions SET presence=0,sequence=(@i:=@i+1) WHERE related_tabid=(SELECT tabid FROM ld_tab WHERE `name`='Calendar') AND tabid=@tabid; 
		UPDATE ld_quickactions SET presence=0,sequence=(@i:=@i+1) WHERE related_tabid=(SELECT tabid FROM ld_tab WHERE `name`='Attachment') AND tabid=@tabid; 
		SET @i=0;
		UPDATE ld_quickactions SET sequence=(@i:=@i+1) WHERE tabid=@tabid ORDER BY sequence;

		SET @tabname='Quotes';
		SELECT tabid INTO @tabid FROM ld_tab WHERE `name`=@tabname;
		UPDATE ld_quickactions SET sequence=sequence+100 WHERE tabid=@tabid;

		SET @i=0;
		UPDATE ld_quickactions SET presence=0,sequence=(@i:=@i+1) WHERE related_tabid=(SELECT tabid FROM ld_tab WHERE `name`='SalesOrder') AND tabid=@tabid; 
		UPDATE ld_quickactions SET presence=0,sequence=(@i:=@i+1) WHERE related_tabid=(SELECT tabid FROM ld_tab WHERE `name`='Attachment') AND tabid=@tabid; 
		SET @i=0;
		UPDATE ld_quickactions SET sequence=(@i:=@i+1) WHERE tabid=@tabid ORDER BY sequence;

		SET @tabname='SalesOrder';
		SELECT tabid INTO @tabid FROM ld_tab WHERE `name`=@tabname;
		UPDATE ld_quickactions SET sequence=sequence+100 WHERE tabid=@tabid;

		SET @i=0;
		UPDATE ld_quickactions SET presence=0,sequence=(@i:=@i+1) WHERE related_tabid=(SELECT tabid FROM ld_tab WHERE `name`='ContactRecords') AND tabid=@tabid; 
		UPDATE ld_quickactions SET presence=1,sequence=(@i:=@i+1) WHERE related_tabid=(SELECT tabid FROM ld_tab WHERE `name`='PaymentPlan') AND tabid=@tabid; 
		UPDATE ld_quickactions SET presence=0,sequence=(@i:=@i+1) WHERE related_tabid=(SELECT tabid FROM ld_tab WHERE `name`='CashBill') AND tabid=@tabid;
		UPDATE ld_quickactions SET presence=0,sequence=(@i:=@i+1) WHERE related_tabid=(SELECT tabid FROM ld_tab WHERE `name`='OutboundOrder') AND tabid=@tabid; 
		UPDATE ld_quickactions SET presence=0,sequence=(@i:=@i+1) WHERE related_tabid=(SELECT tabid FROM ld_tab WHERE `name`='Invoice') AND tabid=@tabid; 
		UPDATE ld_quickactions SET presence=0,sequence=(@i:=@i+1) WHERE related_tabid=(SELECT tabid FROM ld_tab WHERE `name`='PurchaseOrder') AND tabid=@tabid; 
		UPDATE ld_quickactions SET presence=0,sequence=(@i:=@i+1) WHERE related_tabid=(SELECT tabid FROM ld_tab WHERE `name`='Commission') AND tabid=@tabid; 
		UPDATE ld_quickactions SET presence=0,sequence=(@i:=@i+1) WHERE related_tabid=(SELECT tabid FROM ld_tab WHERE `name`='Expense') AND tabid=@tabid; 
		UPDATE ld_quickactions SET presence=0,sequence=(@i:=@i+1) WHERE related_tabid=(SELECT tabid FROM ld_tab WHERE `name`='Attachment') AND tabid=@tabid;
		UPDATE ld_quickactions SET presence=0,sequence=(@i:=@i+1) WHERE related_tabid=(SELECT tabid FROM ld_tab WHERE `name`='SalesBack') AND tabid=@tabid; 
		SET @i=0;
		UPDATE ld_quickactions SET sequence=(@i:=@i+1) WHERE tabid=@tabid ORDER BY sequence;

		SET @tabname='SalesBack';
		SELECT tabid INTO @tabid FROM ld_tab WHERE `name`=@tabname;
		UPDATE ld_quickactions SET sequence=sequence+100 WHERE tabid=@tabid;

		SET @i=0;
		UPDATE ld_quickactions SET presence=0,sequence=(@i:=@i+1) WHERE related_tabid=(SELECT tabid FROM ld_tab WHERE `name`='CashBack') AND tabid=@tabid; 
		UPDATE ld_quickactions SET presence=0,sequence=(@i:=@i+1) WHERE related_tabid=(SELECT tabid FROM ld_tab WHERE `name`='Attachment') AND tabid=@tabid;

		SET @i=0;
		UPDATE ld_quickactions SET sequence=(@i:=@i+1) WHERE tabid=@tabid ORDER BY sequence;

		SET @tabname='ServiceContracts';
		SELECT tabid INTO @tabid FROM ld_tab WHERE `name`=@tabname;
		UPDATE ld_quickactions SET sequence=sequence+100 WHERE tabid=@tabid;

		SET @i=0;
		UPDATE ld_quickactions SET presence=0,sequence=(@i:=@i+1) WHERE related_tabid=(SELECT tabid FROM ld_tab WHERE `name`='ContactRecords') AND tabid=@tabid; 
		UPDATE ld_quickactions SET presence=1,sequence=(@i:=@i+1) WHERE related_tabid=(SELECT tabid FROM ld_tab WHERE `name`='PaymentPlan') AND tabid=@tabid; 
		UPDATE ld_quickactions SET presence=0,sequence=(@i:=@i+1) WHERE related_tabid=(SELECT tabid FROM ld_tab WHERE `name`='CashBill') AND tabid=@tabid;
		UPDATE ld_quickactions SET presence=0,sequence=(@i:=@i+1) WHERE related_tabid=(SELECT tabid FROM ld_tab WHERE `name`='OutboundOrder') AND tabid=@tabid; 
		UPDATE ld_quickactions SET presence=0,sequence=(@i:=@i+1) WHERE related_tabid=(SELECT tabid FROM ld_tab WHERE `name`='Invoice') AND tabid=@tabid; 
		UPDATE ld_quickactions SET presence=0,sequence=(@i:=@i+1) WHERE related_tabid=(SELECT tabid FROM ld_tab WHERE `name`='PurchaseOrder') AND tabid=@tabid; 
		UPDATE ld_quickactions SET presence=0,sequence=(@i:=@i+1) WHERE related_tabid=(SELECT tabid FROM ld_tab WHERE `name`='Commission') AND tabid=@tabid; 
		UPDATE ld_quickactions SET presence=0,sequence=(@i:=@i+1) WHERE related_tabid=(SELECT tabid FROM ld_tab WHERE `name`='Expense') AND tabid=@tabid; 
		UPDATE ld_quickactions SET presence=0,sequence=(@i:=@i+1) WHERE related_tabid=(SELECT tabid FROM ld_tab WHERE `name`='Attachment') AND tabid=@tabid;
		UPDATE ld_quickactions SET presence=0,sequence=(@i:=@i+1) WHERE related_tabid=(SELECT tabid FROM ld_tab WHERE `name`='SalesBack') AND tabid=@tabid; 

		SET @i=0;
		UPDATE ld_quickactions SET sequence=(@i:=@i+1) WHERE tabid=@tabid ORDER BY sequence;

		SET @tabname='ServiceCharge';
		SELECT tabid INTO @tabid FROM ld_tab WHERE `name`=@tabname;
		UPDATE ld_quickactions SET sequence=sequence+100 WHERE tabid=@tabid;

		SET @i=0;
		UPDATE ld_quickactions SET presence=0,sequence=(@i:=@i+1) WHERE related_tabid=(SELECT tabid FROM ld_tab WHERE `name`='Contacts') AND tabid=@tabid; 
		UPDATE ld_quickactions SET presence=0,sequence=(@i:=@i+1) WHERE related_tabid=(SELECT tabid FROM ld_tab WHERE `name`='ContactRecords') AND tabid=@tabid; 
		UPDATE ld_quickactions SET presence=0,sequence=(@i:=@i+1) WHERE related_tabid=(SELECT tabid FROM ld_tab WHERE `name`='Potentials') AND tabid=@tabid; 
		UPDATE ld_quickactions SET presence=0,sequence=(@i:=@i+1) WHERE related_tabid=(SELECT tabid FROM ld_tab WHERE `name`='Quotes') AND tabid=@tabid; 
		UPDATE ld_quickactions SET presence=0,sequence=(@i:=@i+1) WHERE related_tabid=(SELECT tabid FROM ld_tab WHERE `name`='SalesOrder') AND tabid=@tabid; 
		UPDATE ld_quickactions SET presence=0,sequence=(@i:=@i+1) WHERE related_tabid=(SELECT tabid FROM ld_tab WHERE `name`='ServiceContracts') AND tabid=@tabid; 
		UPDATE ld_quickactions SET presence=0,sequence=(@i:=@i+1) WHERE related_tabid=(SELECT tabid FROM ld_tab WHERE `name`='Reminds') AND tabid=@tabid; 
		UPDATE ld_quickactions SET presence=0,sequence=(@i:=@i+1) WHERE related_tabid=(SELECT tabid FROM ld_tab WHERE `name`='Calendar') AND tabid=@tabid; 
		UPDATE ld_quickactions SET presence=0,sequence=(@i:=@i+1) WHERE related_tabid=(SELECT tabid FROM ld_tab WHERE `name`='Attachment') AND tabid=@tabid; 
		UPDATE ld_quickactions SET presence=1,sequence=(@i:=@i+1) WHERE related_tabid=(SELECT tabid FROM ld_tab WHERE `name`='MassSMS') AND tabid=@tabid;

		SET @i=0;
		UPDATE ld_quickactions SET sequence=(@i:=@i+1) WHERE tabid=@tabid ORDER BY sequence;

		SET @tabname='HelpDesk';
		SELECT tabid INTO @tabid FROM ld_tab WHERE `name`=@tabname;
		UPDATE ld_quickactions SET sequence=sequence+100 WHERE tabid=@tabid;

		SET @i=0;
		UPDATE ld_quickactions SET presence=0,sequence=(@i:=@i+1) WHERE related_tabid=(SELECT tabid FROM ld_tab WHERE `name`='ServiceReturn') AND tabid=@tabid; 
		UPDATE ld_quickactions SET presence=0,sequence=(@i:=@i+1) WHERE related_tabid=(SELECT tabid FROM ld_tab WHERE `name`='Reminds') AND tabid=@tabid;
		UPDATE ld_quickactions SET presence=0,sequence=(@i:=@i+1) WHERE related_tabid=(SELECT tabid FROM ld_tab WHERE `name`='Documents') AND tabid=@tabid;  
		UPDATE ld_quickactions SET presence=0,sequence=(@i:=@i+1) WHERE related_tabid=(SELECT tabid FROM ld_tab WHERE `name`='Attachment') AND tabid=@tabid; 

		SET @i=0;
		UPDATE ld_quickactions SET sequence=(@i:=@i+1) WHERE tabid=@tabid ORDER BY sequence;

		SET @tabname='ServiceReturn';
		SELECT tabid INTO @tabid FROM ld_tab WHERE `name`=@tabname;
		UPDATE ld_quickactions SET sequence=sequence+100 WHERE tabid=@tabid;

		SET @i=0;
		UPDATE ld_quickactions SET presence=0,sequence=(@i:=@i+1) WHERE related_tabid=(SELECT tabid FROM ld_tab WHERE `name`='Attachment') AND tabid=@tabid; 

		SET @i=0;
		UPDATE ld_quickactions SET sequence=(@i:=@i+1) WHERE tabid=@tabid ORDER BY sequence;

		SET @tabname='Project';
		SELECT tabid INTO @tabid FROM ld_tab WHERE `name`=@tabname;
		UPDATE ld_quickactions SET sequence=sequence+100 WHERE tabid=@tabid;

		SET @i=0;
		UPDATE ld_quickactions SET presence=0,sequence=(@i:=@i+1) WHERE related_tabid=(SELECT tabid FROM ld_tab WHERE `name`='ContactRecords') AND tabid=@tabid; 
		UPDATE ld_quickactions SET presence=1,sequence=(@i:=@i+1) WHERE related_tabid=(SELECT tabid FROM ld_tab WHERE `name`='ProjectTask') AND tabid=@tabid; 
		UPDATE ld_quickactions SET presence=0,sequence=(@i:=@i+1) WHERE related_tabid=(SELECT tabid FROM ld_tab WHERE `name`='ProjectProgress') AND tabid=@tabid;
		UPDATE ld_quickactions SET presence=0,sequence=(@i:=@i+1) WHERE related_tabid=(SELECT tabid FROM ld_tab WHERE `name`='ProjectMilestone') AND tabid=@tabid; 
		UPDATE ld_quickactions SET presence=0,sequence=(@i:=@i+1) WHERE related_tabid=(SELECT tabid FROM ld_tab WHERE `name`='Reminds') AND tabid=@tabid; 
		UPDATE ld_quickactions SET presence=0,sequence=(@i:=@i+1) WHERE related_tabid=(SELECT tabid FROM ld_tab WHERE `name`='Attachment') AND tabid=@tabid;

		SET @i=0;
		UPDATE ld_quickactions SET sequence=(@i:=@i+1) WHERE tabid=@tabid ORDER BY sequence;

		SET @tabname='ProjectTask';
		SELECT tabid INTO @tabid FROM ld_tab WHERE `name`=@tabname;
		UPDATE ld_quickactions SET sequence=sequence+100 WHERE tabid=@tabid;

		SET @i=0;
		UPDATE ld_quickactions SET presence=0,sequence=(@i:=@i+1) WHERE related_tabid=(SELECT tabid FROM ld_tab WHERE `name`='ContactRecords') AND tabid=@tabid;
		UPDATE ld_quickactions SET presence=0,sequence=(@i:=@i+1) WHERE related_tabid=(SELECT tabid FROM ld_tab WHERE `name`='ProjectProgress') AND tabid=@tabid;
		UPDATE ld_quickactions SET presence=1,sequence=(@i:=@i+1) WHERE related_tabid=(SELECT tabid FROM ld_tab WHERE `name`='ServiceReturn') AND tabid=@tabid; 
		UPDATE ld_quickactions SET presence=0,sequence=(@i:=@i+1) WHERE related_tabid=(SELECT tabid FROM ld_tab WHERE `name`='Reminds') AND tabid=@tabid; 
		UPDATE ld_quickactions SET presence=0,sequence=(@i:=@i+1) WHERE related_tabid=(SELECT tabid FROM ld_tab WHERE `name`='Attachment') AND tabid=@tabid;

		SET @i=0;
		UPDATE ld_quickactions SET sequence=(@i:=@i+1) WHERE tabid=@tabid ORDER BY sequence;

		SET @tabname='ProjectMilestone';
		SELECT tabid INTO @tabid FROM ld_tab WHERE `name`=@tabname;
		UPDATE ld_quickactions SET presence=0,sequence=(@i:=@i+1) WHERE related_tabid=(SELECT tabid FROM ld_tab WHERE `name`='Reminds') AND tabid=@tabid; 
		UPDATE ld_quickactions SET sequence=sequence+100 WHERE tabid=@tabid;

		SET @i=0;
		UPDATE ld_quickactions SET presence=0,sequence=(@i:=@i+1) WHERE related_tabid=(SELECT tabid FROM ld_tab WHERE `name`='Attachment') AND tabid=@tabid; 

		SET @i=0;
		UPDATE ld_quickactions SET sequence=(@i:=@i+1) WHERE tabid=@tabid ORDER BY sequence;

		SET @tabname='TimeSheet';
		SELECT tabid INTO @tabid FROM ld_tab WHERE `name`=@tabname;
		UPDATE ld_quickactions SET sequence=sequence+100 WHERE tabid=@tabid;

		SET @i=0;
		UPDATE ld_quickactions SET presence=0,sequence=(@i:=@i+1) WHERE related_tabid=(SELECT tabid FROM ld_tab WHERE `name`='Reminds') AND tabid=@tabid; 
		UPDATE ld_quickactions SET presence=0,sequence=(@i:=@i+1) WHERE related_tabid=(SELECT tabid FROM ld_tab WHERE `name`='Attachment') AND tabid=@tabid; 

		SET @i=0;
		UPDATE ld_quickactions SET sequence=(@i:=@i+1) WHERE tabid=@tabid ORDER BY sequence;

		SET @tabname='ProjectProgress';
		SELECT tabid INTO @tabid FROM ld_tab WHERE `name`=@tabname;
		UPDATE ld_quickactions SET sequence=sequence+100 WHERE tabid=@tabid;

		SET @i=0;
		UPDATE ld_quickactions SET presence=0,sequence=(@i:=@i+1) WHERE related_tabid=(SELECT tabid FROM ld_tab WHERE `name`='Reminds') AND tabid=@tabid; 
		UPDATE ld_quickactions SET presence=0,sequence=(@i:=@i+1) WHERE related_tabid=(SELECT tabid FROM ld_tab WHERE `name`='Attachment') AND tabid=@tabid; 

		SET @i=0;
		UPDATE ld_quickactions SET sequence=(@i:=@i+1) WHERE tabid=@tabid ORDER BY sequence;

		SET @tabname='Rate';
		SELECT tabid INTO @tabid FROM ld_tab WHERE `name`=@tabname;
		UPDATE ld_quickactions SET sequence=sequence+100 WHERE tabid=@tabid;

		SET @i=0;
		UPDATE ld_quickactions SET presence=0,sequence=(@i:=@i+1) WHERE related_tabid=(SELECT tabid FROM ld_tab WHERE `name`='Attachment') AND tabid=@tabid; 

		SET @i=0;
		UPDATE ld_quickactions SET sequence=(@i:=@i+1) WHERE tabid=@tabid ORDER BY sequence;

		SET @tabname='Invoice';
		SELECT tabid INTO @tabid FROM ld_tab WHERE `name`=@tabname;
		UPDATE ld_quickactions SET sequence=sequence+100 WHERE tabid=@tabid;

		SET @i=0;
		UPDATE ld_quickactions SET presence=0,sequence=(@i:=@i+1) WHERE related_tabid=(SELECT tabid FROM ld_tab WHERE `name`='CashBill') AND tabid=@tabid; 
		UPDATE ld_quickactions SET presence=0,sequence=(@i:=@i+1) WHERE related_tabid=(SELECT tabid FROM ld_tab WHERE `name`='Attachment') AND tabid=@tabid; 

		SET @i=0;
		UPDATE ld_quickactions SET sequence=(@i:=@i+1) WHERE tabid=@tabid ORDER BY sequence;

		SET @tabname='PurchaseInvoice';
		SELECT tabid INTO @tabid FROM ld_tab WHERE `name`=@tabname;
		UPDATE ld_quickactions SET sequence=sequence+100 WHERE tabid=@tabid;

		SET @i=0;
		UPDATE ld_quickactions SET presence=0,sequence=(@i:=@i+1) WHERE related_tabid=(SELECT tabid FROM ld_tab WHERE `name`='SendCashBill') AND tabid=@tabid; 
		UPDATE ld_quickactions SET presence=0,sequence=(@i:=@i+1) WHERE related_tabid=(SELECT tabid FROM ld_tab WHERE `name`='Attachment') AND tabid=@tabid; 

		SET @i=0;
		UPDATE ld_quickactions SET sequence=(@i:=@i+1) WHERE tabid=@tabid ORDER BY sequence;

		SET @tabname='CashBill';
		SELECT tabid INTO @tabid FROM ld_tab WHERE `name`=@tabname;
		UPDATE ld_quickactions SET sequence=sequence+100 WHERE tabid=@tabid;

		SET @i=0;
		UPDATE ld_quickactions SET presence=0,sequence=(@i:=@i+1) WHERE related_tabid=(SELECT tabid FROM ld_tab WHERE `name`='Attachment') AND tabid=@tabid; 

		SET @i=0;
		UPDATE ld_quickactions SET sequence=(@i:=@i+1) WHERE tabid=@tabid ORDER BY sequence;

		SET @tabname='SendCashBill';
		SELECT tabid INTO @tabid FROM ld_tab WHERE `name`=@tabname;
		UPDATE ld_quickactions SET sequence=sequence+100 WHERE tabid=@tabid;

		SET @i=0;
		UPDATE ld_quickactions SET presence=0,sequence=(@i:=@i+1) WHERE related_tabid=(SELECT tabid FROM ld_tab WHERE `name`='Attachment') AND tabid=@tabid; 

		SET @i=0;
		UPDATE ld_quickactions SET sequence=(@i:=@i+1) WHERE tabid=@tabid ORDER BY sequence;

		SET @tabname='CashBack';
		SELECT tabid INTO @tabid FROM ld_tab WHERE `name`=@tabname;
		UPDATE ld_quickactions SET sequence=sequence+100 WHERE tabid=@tabid;

		SET @i=0;
		UPDATE ld_quickactions SET presence=0,sequence=(@i:=@i+1) WHERE related_tabid=(SELECT tabid FROM ld_tab WHERE `name`='Attachment') AND tabid=@tabid; 

		SET @i=0;
		UPDATE ld_quickactions SET sequence=(@i:=@i+1) WHERE tabid=@tabid ORDER BY sequence;

		SET @tabname='PurchaseCashBack';
		SELECT tabid INTO @tabid FROM ld_tab WHERE `name`=@tabname;
		UPDATE ld_quickactions SET sequence=sequence+100 WHERE tabid=@tabid;

		SET @i=0;
		UPDATE ld_quickactions SET presence=0,sequence=(@i:=@i+1) WHERE related_tabid=(SELECT tabid FROM ld_tab WHERE `name`='Attachment') AND tabid=@tabid; 

		SET @i=0;
		UPDATE ld_quickactions SET sequence=(@i:=@i+1) WHERE tabid=@tabid ORDER BY sequence;

		SET @tabname='PaymentPlan';
		SELECT tabid INTO @tabid FROM ld_tab WHERE `name`=@tabname;
		UPDATE ld_quickactions SET sequence=sequence+100 WHERE tabid=@tabid;

		SET @i=0;
		UPDATE ld_quickactions SET presence=0,sequence=(@i:=@i+1) WHERE related_tabid=(SELECT tabid FROM ld_tab WHERE `name`='CashBill') AND tabid=@tabid; 
		UPDATE ld_quickactions SET presence=0,sequence=(@i:=@i+1) WHERE related_tabid=(SELECT tabid FROM ld_tab WHERE `name`='Attachment') AND tabid=@tabid; 

		SET @i=0;
		UPDATE ld_quickactions SET sequence=(@i:=@i+1) WHERE tabid=@tabid ORDER BY sequence;

		SET @tabname='SendPayment';
		SELECT tabid INTO @tabid FROM ld_tab WHERE `name`=@tabname;
		UPDATE ld_quickactions SET sequence=sequence+100 WHERE tabid=@tabid;

		SET @i=0;
		UPDATE ld_quickactions SET presence=0,sequence=(@i:=@i+1) WHERE related_tabid=(SELECT tabid FROM ld_tab WHERE `name`='SendCashBill') AND tabid=@tabid; 
		UPDATE ld_quickactions SET presence=0,sequence=(@i:=@i+1) WHERE related_tabid=(SELECT tabid FROM ld_tab WHERE `name`='Attachment') AND tabid=@tabid; 

		SET @i=0;
		UPDATE ld_quickactions SET sequence=(@i:=@i+1) WHERE tabid=@tabid ORDER BY sequence;

		SET @tabname='PutCash';
		SELECT tabid INTO @tabid FROM ld_tab WHERE `name`=@tabname;
		UPDATE ld_quickactions SET sequence=sequence+100 WHERE tabid=@tabid;

		SET @i=0;
		UPDATE ld_quickactions SET presence=0,sequence=(@i:=@i+1) WHERE related_tabid=(SELECT tabid FROM ld_tab WHERE `name`='Attachment') AND tabid=@tabid; 

		SET @i=0;
		UPDATE ld_quickactions SET sequence=(@i:=@i+1) WHERE tabid=@tabid ORDER BY sequence;

		SET @tabname='CashDeposit';
		SELECT tabid INTO @tabid FROM ld_tab WHERE `name`=@tabname;
		UPDATE ld_quickactions SET sequence=sequence+100 WHERE tabid=@tabid;

		SET @i=0;
		UPDATE ld_quickactions SET presence=0,sequence=(@i:=@i+1) WHERE related_tabid=(SELECT tabid FROM ld_tab WHERE `name`='Attachment') AND tabid=@tabid; 

		SET @i=0;
		UPDATE ld_quickactions SET sequence=(@i:=@i+1) WHERE tabid=@tabid ORDER BY sequence;

		SET @tabname='BankAccountSet';
		SELECT tabid INTO @tabid FROM ld_tab WHERE `name`=@tabname;
		UPDATE ld_quickactions SET sequence=sequence+100 WHERE tabid=@tabid;

		SET @i=0;
		UPDATE ld_quickactions SET presence=0,sequence=(@i:=@i+1) WHERE related_tabid=(SELECT tabid FROM ld_tab WHERE `name`='Attachment') AND tabid=@tabid; 

		SET @i=0;
		UPDATE ld_quickactions SET sequence=(@i:=@i+1) WHERE tabid=@tabid ORDER BY sequence;

		SET @tabname='OutboundOrder';
		SELECT tabid INTO @tabid FROM ld_tab WHERE `name`=@tabname;
		UPDATE ld_quickactions SET sequence=sequence+100 WHERE tabid=@tabid;

		SET @i=0;
		UPDATE ld_quickactions SET presence=0,sequence=(@i:=@i+1) WHERE related_tabid='-9' AND tabid=@tabid; 
		UPDATE ld_quickactions SET presence=0,sequence=(@i:=@i+1) WHERE related_tabid=(SELECT tabid FROM ld_tab WHERE `name`='Attachment') AND tabid=@tabid; 

		SET @i=0;
		UPDATE ld_quickactions SET sequence=(@i:=@i+1) WHERE tabid=@tabid ORDER BY sequence;

		SET @tabname='Stock';
		SELECT tabid INTO @tabid FROM ld_tab WHERE `name`=@tabname;
		UPDATE ld_quickactions SET sequence=sequence+100 WHERE tabid=@tabid;

		SET @i=0;
		UPDATE ld_quickactions SET presence=0,sequence=(@i:=@i+1) WHERE related_tabid=(SELECT tabid FROM ld_tab WHERE `name`='Attachment') AND tabid=@tabid; 

		SET @i=0;
		UPDATE ld_quickactions SET sequence=(@i:=@i+1) WHERE tabid=@tabid ORDER BY sequence;

		SET @tabname='WareHouseTransfer';
		SELECT tabid INTO @tabid FROM ld_tab WHERE `name`=@tabname;
		UPDATE ld_quickactions SET sequence=sequence+100 WHERE tabid=@tabid;

		SET @i=0;
		UPDATE ld_quickactions SET presence=0,sequence=(@i:=@i+1) WHERE related_tabid=(SELECT tabid FROM ld_tab WHERE `name`='Attachment') AND tabid=@tabid; 

		SET @i=0;
		UPDATE ld_quickactions SET sequence=(@i:=@i+1) WHERE tabid=@tabid ORDER BY sequence;

		SET @tabname='Checks';
		SELECT tabid INTO @tabid FROM ld_tab WHERE `name`=@tabname;
		UPDATE ld_quickactions SET sequence=sequence+100 WHERE tabid=@tabid;

		SET @i=0;
		UPDATE ld_quickactions SET presence=0,sequence=(@i:=@i+1) WHERE related_tabid=(SELECT tabid FROM ld_tab WHERE `name`='Attachment') AND tabid=@tabid; 

		SET @i=0;
		UPDATE ld_quickactions SET sequence=(@i:=@i+1) WHERE tabid=@tabid ORDER BY sequence;

		SET @tabname='Vendors';
		SELECT tabid INTO @tabid FROM ld_tab WHERE `name`=@tabname;
		UPDATE ld_quickactions SET sequence=sequence+100 WHERE tabid=@tabid;

		SET @i=0;
		UPDATE ld_quickactions SET presence=0,sequence=(@i:=@i+1) WHERE related_tabid=(SELECT tabid FROM ld_tab WHERE `name`='VendorContact') AND tabid=@tabid; 
		UPDATE ld_quickactions SET presence=0,sequence=(@i:=@i+1) WHERE related_tabid=(SELECT tabid FROM ld_tab WHERE `name`='VendorContactRecords') AND tabid=@tabid; 
		UPDATE ld_quickactions SET presence=0,sequence=(@i:=@i+1) WHERE related_tabid=(SELECT tabid FROM ld_tab WHERE `name`='PurchaseOrder') AND tabid=@tabid; 
		UPDATE ld_quickactions SET presence=0,sequence=(@i:=@i+1) WHERE related_tabid=(SELECT tabid FROM ld_tab WHERE `name`='Reminds') AND tabid=@tabid;  
		UPDATE ld_quickactions SET presence=0,sequence=(@i:=@i+1) WHERE related_tabid=(SELECT tabid FROM ld_tab WHERE `name`='Attachment') AND tabid=@tabid; 

		SET @i=0;
		UPDATE ld_quickactions SET sequence=(@i:=@i+1) WHERE tabid=@tabid ORDER BY sequence;

		SET @tabname='VendorContact';
		SELECT tabid INTO @tabid FROM ld_tab WHERE `name`=@tabname;
		UPDATE ld_quickactions SET sequence=sequence+100 WHERE tabid=@tabid;

		SET @i=0;
		UPDATE ld_quickactions SET presence=0,sequence=(@i:=@i+1) WHERE related_tabid=(SELECT tabid FROM ld_tab WHERE `name`='VendorContactRecords') AND tabid=@tabid; 
		UPDATE ld_quickactions SET presence=0,sequence=(@i:=@i+1) WHERE related_tabid=(SELECT tabid FROM ld_tab WHERE `name`='Attachment') AND tabid=@tabid; 

		SET @i=0;
		UPDATE ld_quickactions SET sequence=(@i:=@i+1) WHERE tabid=@tabid ORDER BY sequence;

		SET @tabname='VendorContactRecords';
		SELECT tabid INTO @tabid FROM ld_tab WHERE `name`=@tabname;
		UPDATE ld_quickactions SET sequence=sequence+100 WHERE tabid=@tabid;

		SET @i=0;
		UPDATE ld_quickactions SET presence=0,sequence=(@i:=@i+1) WHERE related_tabid=(SELECT tabid FROM ld_tab WHERE `name`='Reminds') AND tabid=@tabid; 
		UPDATE ld_quickactions SET presence=0,sequence=(@i:=@i+1) WHERE related_tabid=(SELECT tabid FROM ld_tab WHERE `name`='Attachment') AND tabid=@tabid; 

		SET @i=0;
		UPDATE ld_quickactions SET sequence=(@i:=@i+1) WHERE tabid=@tabid ORDER BY sequence;

		SET @tabname='PurchaseOrder';
		SELECT tabid INTO @tabid FROM ld_tab WHERE `name`=@tabname;
		UPDATE ld_quickactions SET sequence=sequence+100 WHERE tabid=@tabid;

		SET @i=0;
		UPDATE ld_quickactions SET presence=0,sequence=(@i:=@i+1) WHERE related_tabid=(SELECT tabid FROM ld_tab WHERE `name`='Stock') AND tabid=@tabid; 
		UPDATE ld_quickactions SET presence=0,sequence=(@i:=@i+1) WHERE related_tabid=(SELECT tabid FROM ld_tab WHERE `name`='SendCashBill') AND tabid=@tabid; 
		UPDATE ld_quickactions SET presence=0,sequence=(@i:=@i+1) WHERE related_tabid=(SELECT tabid FROM ld_tab WHERE `name`='PurchaseInvoice') AND tabid=@tabid; 
		UPDATE ld_quickactions SET presence=0,sequence=(@i:=@i+1) WHERE related_tabid=(SELECT tabid FROM ld_tab WHERE `name`='PurchaseBack') AND tabid=@tabid; 
		UPDATE ld_quickactions SET presence=0,sequence=(@i:=@i+1) WHERE related_tabid=(SELECT tabid FROM ld_tab WHERE `name`='Attachment') AND tabid=@tabid; 

		SET @i=0;
		UPDATE ld_quickactions SET sequence=(@i:=@i+1) WHERE tabid=@tabid ORDER BY sequence;

		SET @tabname='PurchaseBack';
		SELECT tabid INTO @tabid FROM ld_tab WHERE `name`=@tabname;
		UPDATE ld_quickactions SET sequence=sequence+100 WHERE tabid=@tabid;

		SET @i=0;
		UPDATE ld_quickactions SET presence=0,sequence=(@i:=@i+1) WHERE related_tabid=(SELECT tabid FROM ld_tab WHERE `name`='PurchaseCashBack') AND tabid=@tabid; 
		UPDATE ld_quickactions SET presence=0,sequence=(@i:=@i+1) WHERE related_tabid=(SELECT tabid FROM ld_tab WHERE `name`='Attachment') AND tabid=@tabid; 

		SET @i=0;
		UPDATE ld_quickactions SET sequence=(@i:=@i+1) WHERE tabid=@tabid ORDER BY sequence;

		SET @tabname='Campaigns';
		SELECT tabid INTO @tabid FROM ld_tab WHERE `name`=@tabname;
		UPDATE ld_quickactions SET sequence=sequence+100 WHERE tabid=@tabid;

		SET @i=0;
		UPDATE ld_quickactions SET presence=0,sequence=(@i:=@i+1) WHERE related_tabid=(SELECT tabid FROM ld_tab WHERE `name`='Reminds') AND tabid=@tabid; 
		UPDATE ld_quickactions SET presence=0,sequence=(@i:=@i+1) WHERE related_tabid=(SELECT tabid FROM ld_tab WHERE `name`='Attachment') AND tabid=@tabid; 

		SET @i=0;
		UPDATE ld_quickactions SET sequence=(@i:=@i+1) WHERE tabid=@tabid ORDER BY sequence;

		SET @tabname='NormalApprove';
		SELECT tabid INTO @tabid FROM ld_tab WHERE `name`=@tabname;
		UPDATE ld_quickactions SET sequence=sequence+100 WHERE tabid=@tabid;

		SET @i=0;
		UPDATE ld_quickactions SET presence=0,sequence=(@i:=@i+1) WHERE related_tabid=(SELECT tabid FROM ld_tab WHERE `name`='Reminds') AND tabid=@tabid; 

		SET @i=0;
		UPDATE ld_quickactions SET sequence=(@i:=@i+1) WHERE tabid=@tabid ORDER BY sequence;

		SET @tabname='AddJobBill';
		SELECT tabid INTO @tabid FROM ld_tab WHERE `name`=@tabname;
		UPDATE ld_quickactions SET sequence=sequence+100 WHERE tabid=@tabid;

		SET @i=0;
		UPDATE ld_quickactions SET presence=0,sequence=(@i:=@i+1) WHERE related_tabid=(SELECT tabid FROM ld_tab WHERE `name`='Reminds') AND tabid=@tabid; 

		SET @i=0;
		UPDATE ld_quickactions SET sequence=(@i:=@i+1) WHERE tabid=@tabid ORDER BY sequence;

		SET @tabname='MinusJobBill';
		SELECT tabid INTO @tabid FROM ld_tab WHERE `name`=@tabname;
		UPDATE ld_quickactions SET sequence=sequence+100 WHERE tabid=@tabid;

		SET @i=0;
		UPDATE ld_quickactions SET presence=0,sequence=(@i:=@i+1) WHERE related_tabid=(SELECT tabid FROM ld_tab WHERE `name`='Reminds') AND tabid=@tabid; 

		SET @i=0;
		UPDATE ld_quickactions SET sequence=(@i:=@i+1) WHERE tabid=@tabid ORDER BY sequence;

		SET @tabname='BusinessApply';
		SELECT tabid INTO @tabid FROM ld_tab WHERE `name`=@tabname;
		UPDATE ld_quickactions SET sequence=sequence+100 WHERE tabid=@tabid;

		SET @i=0;
		UPDATE ld_quickactions SET presence=0,sequence=(@i:=@i+1) WHERE related_tabid=(SELECT tabid FROM ld_tab WHERE `name`='Reminds') AND tabid=@tabid; 

		SET @i=0;
		UPDATE ld_quickactions SET sequence=(@i:=@i+1) WHERE tabid=@tabid ORDER BY sequence;


		SET @tabname='LoanApply';
		SELECT tabid INTO @tabid FROM ld_tab WHERE `name`=@tabname;
		UPDATE ld_quickactions SET sequence=sequence+100 WHERE tabid=@tabid;

		SET @i=0;
		UPDATE ld_quickactions SET presence=0,sequence=(@i:=@i+1) WHERE related_tabid=(SELECT tabid FROM ld_tab WHERE `name`='Reminds') AND tabid=@tabid; 

		SET @i=0;
		UPDATE ld_quickactions SET sequence=(@i:=@i+1) WHERE tabid=@tabid ORDER BY sequence;

		SET @tabname='CardApply';
		SELECT tabid INTO @tabid FROM ld_tab WHERE `name`=@tabname;
		UPDATE ld_quickactions SET sequence=sequence+100 WHERE tabid=@tabid;

		SET @i=0;
		UPDATE ld_quickactions SET presence=0,sequence=(@i:=@i+1) WHERE related_tabid=(SELECT tabid FROM ld_tab WHERE `name`='Reminds') AND tabid=@tabid; 

		SET @i=0;
		UPDATE ld_quickactions SET sequence=(@i:=@i+1) WHERE tabid=@tabid ORDER BY sequence;


		SET @tabname='Commission';
		SELECT tabid INTO @tabid FROM ld_tab WHERE `name`=@tabname;
		UPDATE ld_quickactions SET sequence=sequence+100 WHERE tabid=@tabid;

		SET @i=0;
		UPDATE ld_quickactions SET presence=0,sequence=(@i:=@i+1) WHERE related_tabid=(SELECT tabid FROM ld_tab WHERE `name`='Reminds') AND tabid=@tabid; 

		SET @i=0;
		UPDATE ld_quickactions SET sequence=(@i:=@i+1) WHERE tabid=@tabid ORDER BY sequence;

		SET @tabname='Expense';
		SELECT tabid INTO @tabid FROM ld_tab WHERE `name`=@tabname;
		UPDATE ld_quickactions SET sequence=sequence+100 WHERE tabid=@tabid;

		SET @i=0;
		UPDATE ld_quickactions SET presence=0,sequence=(@i:=@i+1) WHERE related_tabid=(SELECT tabid FROM ld_tab WHERE `name`='Reminds') AND tabid=@tabid; 

		SET @i=0;
		UPDATE ld_quickactions SET sequence=(@i:=@i+1) WHERE tabid=@tabid ORDER BY sequence;

		SET @tabname='Products';
		SELECT tabid INTO @tabid FROM ld_tab WHERE `name`=@tabname;
		UPDATE ld_quickactions SET sequence=sequence+100 WHERE tabid=@tabid;

		SET @i=0;
		UPDATE ld_quickactions SET presence=0,sequence=(@i:=@i+1) WHERE related_tabid=(SELECT tabid FROM ld_tab WHERE `name`='Quotes') AND tabid=@tabid; 
		UPDATE ld_quickactions SET presence=0,sequence=(@i:=@i+1) WHERE related_tabid=(SELECT tabid FROM ld_tab WHERE `name`='SalesOrder') AND tabid=@tabid; 
		UPDATE ld_quickactions SET presence=0,sequence=(@i:=@i+1) WHERE related_tabid=(SELECT tabid FROM ld_tab WHERE `name`='ServiceContracts') AND tabid=@tabid; 
		UPDATE ld_quickactions SET presence=0,sequence=(@i:=@i+1) WHERE related_tabid=(SELECT tabid FROM ld_tab WHERE `name`='Reminds') AND tabid=@tabid; 

		SET @i=0;
		UPDATE ld_quickactions SET sequence=(@i:=@i+1) WHERE tabid=@tabid ORDER BY sequence;

		SET @tabname='PriceBooks';
		SELECT tabid INTO @tabid FROM ld_tab WHERE `name`=@tabname;
		UPDATE ld_quickactions SET sequence=sequence+100 WHERE tabid=@tabid;

		SET @i=0;
		UPDATE ld_quickactions SET presence=0,sequence=(@i:=@i+1) WHERE related_tabid=(SELECT tabid FROM ld_tab WHERE `name`='Attachment') AND tabid=@tabid; 

		SET @i=0;
		UPDATE ld_quickactions SET sequence=(@i:=@i+1) WHERE tabid=@tabid ORDER BY sequence;

	END IF;
end ||
delimiter;

CALL ldcrm_reset_quickactions;
DROP PROCEDURE IF EXISTS `ldcrm_reset_quickactions`;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','thecurrentdocumenthasbeenpaid','当前单据已付款，不允许编辑！','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype = 'zh' and labelbol = 'thecurrentdocumenthasbeenpaid' and labeltype = 'fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','thecurrentdocumenthasbeenpaid','The current document has been paid, and the editor is not allowed!','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype = 'en' and labelbol = 'thecurrentdocumenthasbeenpaid' and labeltype = 'fixedstr');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','thecurrenrpartofthebillhasbeenpaid','当前单据部分已付款，不允许编辑！','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype = 'zh' and labelbol = 'thecurrenrpartofthebillhasbeenpaid' and labeltype = 'fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','thecurrenrpartofthebillhasbeenpaid','The current part of the bill has been paid, and the editor is not allowed!','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype = 'en' and labelbol = 'thecurrenrpartofthebillhasbeenpaid' and labeltype = 'fixedstr');
delimiter;

alter table ld_users alter column push_wx_reminds set default 1;
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','QuotesChange_Add','新增->追加','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype = 'zh' and labelbol = 'QuotesChange_Add' and labeltype = 'fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','QuotesChange_Add','QuotesChange Add','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype = 'en' and labelbol = 'QuotesChange_Add' and labeltype = 'fixedstr');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','QuotesChange_Replace','新增->更换','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype = 'zh' and labelbol = 'QuotesChange_Replace' and labeltype = 'fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','QuotesChange_Replace','QuotesChange Replace','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype = 'en' and labelbol = 'QuotesChange_Replace' and labeltype = 'fixedstr');
delimiter;

select max(actionid) into @actionid from ld_actionmapping;
insert into ld_actionmapping(actionid,actionname,securitycheck,actionlabel)
select @actionid+1,'QuotesChange_Add',0,'QuotesChange_Add' from DUAL
where not exists(select 1 from ld_actionmapping where actionname = 'QuotesChange_Add');
insert into ld_actionmapping(actionid,actionname,securitycheck,actionlabel)
select @actionid+2,'QuotesChange_Replace',0,'QuotesChange_Replace' from DUAL
where not exists(select 1 from ld_actionmapping where actionname = 'QuotesChange_Replace');
delimiter;

select tabid into @tabid from ld_tab where `name` = 'Quoteschange';
select actionid into @actionid_add from ld_actionmapping where actionname = 'QuotesChange_Add';
select actionid into @actionid_replace from ld_actionmapping where actionname = 'QuotesChange_Replace';
insert into ld_profileallpermission(tabid,operation)
select @tabid,@actionid_add from dual
where not exists(select 1 from ld_profileallpermission where tabid = @tabid and operation = @actionid_add);
insert into ld_profileallpermission(tabid,operation)
select @tabid,@actionid_replace from dual
where not exists(select 1 from ld_profileallpermission where tabid = @tabid and operation = @actionid_replace);
delimiter;

select sequence into @sequence from ld_appparenttab where parenttab_label='Sales';
update ld_appparenttab set sequence=sequence+2 where sequence>@sequence;
update ld_appparenttab set sequence=@sequence+1 where parenttab_label='Office' 
and not exists(select 1 from ld_crmentity where crmid>2);
set @i=0;
update ld_appparenttab set sequence=(@i:=@i+1) order by sequence;
delimiter;
-- 2017-11-09

select sequence into @sequence from ld_appparenttab where parenttab_label='Sales';
update ld_appparenttab set sequence=sequence+2 where sequence>@sequence;
update ld_appparenttab set sequence=@sequence+1 where parenttab_label='Office' 
and not exists(select 1 from ld_crmentity where crmid>2);
set @i=0;
update ld_appparenttab set sequence=(@i:=@i+1) order by sequence;
delimiter;

INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','DELETEMULTIPICKLISTVALUE','删除多选框选项','fixedstr'
from dual where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='DELETEMULTIPICKLISTVALUE' and labeltype='fixedstr');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','DELETEMULTIPICKLISTVALUE','Delete the multi-drop-down option','fixedstr'
from dual where not exists(select 1 from ld_desk where languagetype='en' and labelbol='DELETEMULTIPICKLISTVALUE' and labeltype='fixedstr');
delimiter;

call altercolumn('ld_rating','rating_id','ratingid','int(19) AUTO_INCREMENT');
call altercolumn('ld_salutationtype','salutationid','salutationtypeid','int(19) AUTO_INCREMENT');
call altercolumn('ld_opportunity_type','opptypeid','opportunity_typeid','int(19) AUTO_INCREMENT');
call altercolumn('ld_ticketpriorities','ticketpriorities_id','ticketprioritiesid','int(19) AUTO_INCREMENT');
call altercolumn('ld_ticketseverities','ticketseverities_id','ticketseveritiesid','int(19) AUTO_INCREMENT');
call altercolumn('ld_ticketstatus','ticketstatus_id','ticketstatusid','int(19) AUTO_INCREMENT');
call altercolumn('ld_ticketcategories','ticketcategories_id','ticketcategoriesid','int(19) AUTO_INCREMENT');
call altercolumn('ld_faqcategories','faqcategories_id','faqcategoriesid','int(19) AUTO_INCREMENT');
call altercolumn('ld_faqstatus','faqstatus_id','faqstatusid','int(19) AUTO_INCREMENT');

update ld_settings_field set active=1 where name='LBL_PICKLIST_EDITOR';
delimiter;

insert into ld_desk (languagetype,labelbol,fieldlabel,labeltype)
select 'zh','ALLSETROLEDATAPROFILE','允许设置用户的角色和数据权限','fixedstr' from DUAL
where not EXISTS(select 1 from ld_desk  where labelbol='ALLSETROLEDATAPROFILE' and languagetype='zh' and labeltype='fixedstr');
insert into ld_desk (languagetype,labelbol,fieldlabel,labeltype)
select 'en','ALLSETROLEDATAPROFILE','Allow user roles and data permissions to be set','fixedstr' from DUAL
where not EXISTS(select 1 from ld_desk  where labelbol='ALLSETROLEDATAPROFILE' and languagetype='en' and labeltype='fixedstr');
delimiter;
update ld_settings_field set linkto='index.php?module=Users&action=index&parenttab=Settings' where name='lBl_users';
delimiter;

select max(actionid) into @actionid from ld_actionmapping;
insert into ld_actionmapping(actionid,actionname,securitycheck, actionlabel)
select @actionid+1,'RoleProfile',0,'ROLES'  from  dual 
where not EXISTS(select 1 from ld_actionmapping where actionname='RoleProfile');

insert into ld_actionmapping(actionid,actionname,securitycheck, actionlabel)
select @actionid+2,'DataScope',0,'DATARANGE'  from  dual 
where not EXISTS(select 1 from ld_actionmapping where actionname='DataScope');

insert into ld_actionmapping(actionid,actionname,securitycheck, actionlabel)
select @actionid+4,'UserActivate',0,'ACTIVATE'  from  dual 
where not EXISTS(select 1 from ld_actionmapping where actionname='UserActivate');
delimiter;

insert into ld_actionmapping(actionid,actionname,securitycheck, actionlabel)
select @actionid+3,'UserStop',0,'INACTIVATE'  from  dual 
where not EXISTS(select 1 from ld_actionmapping where actionname='UserStop');
delimiter;

insert into ld_actionmapping(actionid,actionname,securitycheck, actionlabel)
select @actionid+5,'AllowSetRoleDataProfile',0,'ALLSETROLEDATAPROFILE'  from  dual 
where not EXISTS(select 1 from ld_actionmapping where actionname='AllowSetRoleDataProfile');
delimiter;

call AddColumn('ld_users','createdtime','datetime','','');
delimiter;
call AddColumn('ld_users','modifiedtime','datetime','','');
delimiter;


call AddColumn('ld_users','modifiedby','int','19','0');
delimiter;
call AddColumn('ld_users','smcreatorid','int','19','0');
delimiter;

call AddColumn('ld_profileallpermission','sequence','int','19','');
delimiter;

select blockid into @blockid from ld_blocks where tabid=29 and blocklabel='LBL_USERLOGIN_ROLE';
update ld_tranlabel set  fieldlabel='用户信息' where tabid=29 and trantable='ld_blocks' and  Relateid=@blockid and languagetype='zh' ;
update ld_tranlabel set  fieldlabel='User Info' where tabid=29 and trantable='ld_blocks' and Relateid=@blockid and languagetype='en';
delimiter;


select blockid into @blockid from ld_blocks where tabid=29 and blocklabel='LBL_USER_DATAACCESS';
update ld_tranlabel set  fieldlabel='角色与权限' where tabid=29 and trantable='ld_blocks' and  Relateid=@blockid and languagetype='zh';
update ld_tranlabel set  fieldlabel='Role&Profile' where tabid=29 and trantable='ld_blocks' and Relateid=@blockid and languagetype='en';
delimiter;

select blockid into @blockid from ld_blocks where tabid=29 and blocklabel='LBL_USERLOGIN_MOBILE';
update ld_tranlabel set  fieldlabel='其他设置' where tabid=29 and trantable='ld_blocks' and  Relateid=@blockid and languagetype='zh';
update ld_tranlabel set  fieldlabel='Other settings' where tabid=29 and trantable='ld_blocks' and Relateid=@blockid and languagetype='en';
delimiter;


select blockid into @blockid from ld_blocks where tabid=29 and blocklabel='LBL_USER_DATAACCESS';
update ld_field set block =@blockid,sequence=1  where tabid=29 and columnname='profileid';
update ld_field set block =@blockid,sequence=2  where tabid=29 and columnname='scopeauthority';
delimiter;
select blockid into @blockid from ld_blocks where tabid=29 and blocklabel='LBL_USER_DATAACCESS';
select max(sequence)  into @sequence from ld_field where tabid=29 and block=@blockid;

update ld_field set block =@blockid,sequence=@sequence+3  where tabid=29 and columnname='select_servicedetail';
update ld_field set block =@blockid,sequence=@sequence+6  where tabid=29 and columnname='select_due_date';
update ld_field set block =@blockid,sequence=@sequence+9  where tabid=29 and columnname='accountallview';
update ld_field set block =@blockid,sequence=@sequence+12  where tabid=29 and columnname='trackgroupid';
delimiter;

select blockid into @blockid from ld_blocks where tabid=29 and blocklabel='LBL_USERLOGIN_MOBILE';
select max(sequence)  into @sequence from ld_field where tabid=29 and block=@blockid;
update ld_field set block =@blockid,sequence=3  where tabid=29 and columnname='login_sms';
update ld_field set block =@blockid,sequence=@sequence+3  where tabid=29 and columnname='push_wx_reminds';
delimiter;
select blockid into @blockid from ld_blocks where tabid=29 and blocklabel='LBL_USERLOGIN_ROLE';
select max(sequence)  into @sequence from ld_field where tabid=29 and block=@blockid;
update ld_field set block =@blockid,sequence=@sequence+3  where tabid=29 and columnname='imagename';
delimiter;


select max(cvid) into @maxcvid  from ld_customview;
update ld_customview_seq set id=@cvid+1 where not EXISTS(select 1 from ld_customview where entitytype='Users' and viewname='All');
insert into ld_customview (cvid,viewname,setdefault,setmetrics,entitytype,status,userid,sequence)
select @maxcvid+1,'All',1,0,'Users',3,1,1 from dual 
where not EXISTS(select 1 from ld_customview where entitytype='Users' and viewname='All');
delimiter;

select cvid into @cvid from ld_customview where entitytype='Users' and viewname='All';
DELETE FROM ld_cvcolumnlist WHERE cvid=@cvid;
insert into ld_cvcolumnlist(cvid , columnindex,columnname)
select @cvid,0,'ld_users:user_name:user_name:Users_fieldlabel:V' from dual 
where not EXISTS(select 1 from ld_cvcolumnlist where cvid=@cvid and columnname like '%ld_users:user_name%');
insert into ld_cvcolumnlist(cvid , columnindex,columnname)
select @cvid,1,'ld_users:last_name:last_name:Users_fieldlabel:V' from dual 
where not EXISTS(select 1 from ld_cvcolumnlist where cvid=@cvid and columnname like '%ld_users:last_name%');
insert into ld_cvcolumnlist(cvid , columnindex,columnname)
select @cvid,2,'ld_users:profileid:Users_fieldlabel:V' from dual 
where not EXISTS(select 1 from ld_cvcolumnlist where cvid=@cvid and columnname like '%ld_users:profileid%');
insert into ld_cvcolumnlist(cvid , columnindex,columnname)
select @cvid,3,'ld_users:email1:email1:Users_fieldlabel:V' from dual 
where not EXISTS(select 1 from ld_cvcolumnlist where cvid=@cvid and columnname like '%ld_users:email1%');
insert into ld_cvcolumnlist(cvid , columnindex,columnname)
select @cvid,4,'ld_users:phone_mobile:phone_mobile:Users_fieldlabel:V' from dual 
where not EXISTS(select 1 from ld_cvcolumnlist where cvid=@cvid and columnname like '%ld_users:phone_mobile%');
insert into ld_cvcolumnlist(cvid , columnindex,columnname)
select @cvid,5,'ld_users:userlevel:userlevel:Users_fieldlabel:V' from dual 
where not EXISTS(select 1 from ld_cvcolumnlist where cvid=@cvid and columnname like '%ld_users:userlevel%');

insert into ld_cvcolumnlist(cvid , columnindex,columnname)
select @cvid,6,'ld_users:is_admin:is_admin:Users_fieldlabel:C' from dual 
where not EXISTS(select 1 from ld_cvcolumnlist where cvid=@cvid and columnname like '%ld_users:is_admin%');
insert into ld_cvcolumnlist(cvid , columnindex,columnname)
select @cvid,7,'ld_users:status:status:Users_fieldlabel:V' from dual 
where not EXISTS(select 1 from ld_cvcolumnlist where cvid=@cvid and columnname like '%ld_users:status%');

delimiter;
select cvid into @cvid from ld_customview where entitytype='Users' and viewname='All';
insert into ld_cvcolumnlistsort (cvid,columnname,sorttype)
select @cvid,'ld_users:createdtime:createdtime:Users_DT~O:fieldlabel' ,'desc' from DUAL
where not exists(select 1 from ld_cvcolumnlistsort where cvid=@cvid and columnname like '%ld_users:createdtime%');
delimiter;

set @tabid=29;
select blockid into @blockid from ld_blocks where tabid=@tabid and blocklabel='LBL_USERLOGIN_ROLE';
select max(fieldid) into @maxfieldid from ld_field;
update ld_field_seq set id=@maxfieldid+1 where not EXISTS(select 1 from ld_field where tabid=@tabid and columnname='createdtime');
insert into ld_field (tabid ,fieldid,columnname,tablename,generatedtype,uitype,fieldname,fieldlabel,readonly,presence,sequence,block,displaytype,typeofdata,quickcreate,issmownerid)
select @tabid,@maxfieldid+1,'createdtime','ld_users',1,70,'createdtime','创建时间',1,0,35,@blockid ,2,'DT~O',1,0 from dual 
where not EXISTS(select 1 from ld_field where tabid=@tabid and columnname='createdtime');

select max(fieldid) into @maxfieldid from ld_field;
update ld_field_seq set id=@maxfieldid+1 where not EXISTS(select 1 from ld_field where tabid=@tabid and columnname='smcreatorid');
insert into ld_field (tabid ,fieldid,columnname,tablename,generatedtype,uitype,fieldname,fieldlabel,readonly,presence,sequence,block,displaytype,typeofdata,quickcreate,issmownerid)
select @tabid,@maxfieldid+1,'smcreatorid','ld_users',1,52,'smcreatorid','创建人',1,0,36,@blockid ,2,'V~O',1,0 from dual 
where not EXISTS(select 1 from ld_field where tabid=@tabid and columnname='smcreatorid');

select max(fieldid) into @maxfieldid from ld_field;
update ld_field_seq set id=@maxfieldid+1 where not EXISTS(select 1 from ld_field where tabid=@tabid and columnname='modifiedtime');
insert into ld_field (tabid ,fieldid,columnname,tablename,generatedtype,uitype,fieldname,fieldlabel,readonly,presence,sequence,block,displaytype,typeofdata,quickcreate,issmownerid)
select @tabid,@maxfieldid+1,'modifiedtime','ld_users',1,70,'modifiedtime','修改时间',1,0,37,@blockid ,2,'DT~O',1,0 from dual 
where not EXISTS(select 1 from ld_field where tabid=@tabid and columnname='modifiedtime');

select max(fieldid) into @maxfieldid from ld_field;
update ld_field_seq set id=@maxfieldid+1 where not EXISTS(select 1 from ld_field where tabid=@tabid and columnname='modifiedby');
insert into ld_field (tabid ,fieldid,columnname,tablename,generatedtype,uitype,fieldname,fieldlabel,readonly,presence,sequence,block,displaytype,typeofdata,quickcreate,issmownerid)
select @tabid,@maxfieldid+1,'modifiedby','ld_users',1,52,'modifiedby','最新更新人',1,0,38,@blockid ,2,'V~O',1,0 from dual 
where not EXISTS(select 1 from ld_field where tabid=@tabid and columnname='modifiedby');
delimiter;



set @tabid=29;
select fieldid into @fieldid from ld_field where tabid=@tabid and columnname='createdtime';
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'zh','ld_field',@tabid, @fieldid,'创建时间' from dual 
where not exists(select 1 from ld_tranlabel where tabid=@tabid and relateid=@fieldid and languagetype='zh'and trantable='ld_field' );
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'en','ld_field',@tabid,@fieldid,'Created Time' from dual 
where not exists(select 1 from ld_tranlabel where tabid=@tabid and relateid=@fieldid and languagetype='en' and trantable='ld_field');
delimiter;


set @tabid=29;
select fieldid into @fieldid from ld_field where tabid=@tabid and columnname='smcreatorid';
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'zh','ld_field',@tabid, @fieldid,'创建人' from dual 
where not exists(select 1 from ld_tranlabel where tabid=@tabid and relateid=@fieldid and languagetype='zh'and trantable='ld_field' );
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'en','ld_field',@tabid,@fieldid,'Creator' from dual 
where not exists(select 1 from ld_tranlabel where tabid=@tabid and relateid=@fieldid and languagetype='en' and trantable='ld_field');
delimiter;

set @tabid=29;
select fieldid into @fieldid from ld_field where tabid=@tabid and columnname='modifiedtime';
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'zh','ld_field',@tabid, @fieldid,'修改时间' from dual 
where not exists(select 1 from ld_tranlabel where tabid=@tabid and relateid=@fieldid and languagetype='zh'and trantable='ld_field' );
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'en','ld_field',@tabid,@fieldid,'Modified Time' from dual 
where not exists(select 1 from ld_tranlabel where tabid=@tabid and relateid=@fieldid and languagetype='en' and trantable='ld_field');
delimiter;

set @tabid=29;
select fieldid into @fieldid from ld_field where tabid=@tabid and columnname='modifiedby';
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'zh','ld_field',@tabid, @fieldid,'最新更新人' from dual 
where not exists(select 1 from ld_tranlabel where tabid=@tabid and relateid=@fieldid and languagetype='zh'and trantable='ld_field' );
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'en','ld_field',@tabid,@fieldid,'Modified By' from dual 
where not exists(select 1 from ld_tranlabel where tabid=@tabid and relateid=@fieldid and languagetype='en' and trantable='ld_field');
delimiter;

update ld_blocks set visible=1 where tabid=29 and (blocklabel='LBL_MORE_INFORMATION' 
		or blocklabel='LBL_ACCOUNT_MOREINFORMATION' or blocklabel='LBL_USER_IMAGE_INFORMATION'
or blocklabel='LBL_USERLOGIN_WEIXIN' or blocklabel='LBL_TRACKPOSTIONINGGROUP' or blocklabel='LBL_SERVICECONTRACTS'
or blocklabel='LBL_USER_ENABLESMSVERIFICATION');
delimiter;

set @tabid=29;
insert into ld_profileallpermission(tabid,operation) select @tabid,actionid from ld_actionmapping
where not EXISTS(select 1 from ld_profileallpermission where tabid=@tabid  and operation=4)
and actionname in('Detailview','Create','EditView','RoleProfile' ,'DataScope', 'import', 'export','UserStop','Delete','Copy');
delimiter;
set @tabid=29;
select actionid into @actionid from ld_actionmapping where actionname='UserActivate';
insert into ld_profileallpermission(tabid,operation) select @tabid,@actionid from dual
where not EXISTS(select 1 from ld_profileallpermission where tabid=@tabid  and operation=@actionid);
delimiter;

set @tabid=29;
select actionid into @actionid from ld_actionmapping where actionname='AllowSetRoleDataProfile';
insert into ld_profileallpermission(tabid,operation) select @tabid,@actionid from dual
where not EXISTS(select 1 from ld_profileallpermission where tabid=@tabid  and operation=@actionid);
delimiter;

DROP PROCEDURE IF EXISTS  moveuserscffield;
delimiter ||
create PROCEDURE moveuserscffield
(
)
BEGIN
	declare done  int  default 0;
	declare ffieldid  int ;
	declare cur1 CURSOR FOR SELECT fieldid   FROM  ld_field where tabid=29  and block!=@blockid and tablename='ld_usersscf';
	declare continue handler  for not   found  SET done =1;
  	OPEN cur1;
	Fetch cur1 into ffieldid;
set @i=0;
 loop1: while  done<>1 DO

		set @sql=CONCAT('update ld_field set sequence=40+',@i,' where fieldid=', ffieldid);
				  prepare stmt from @sql;
			 execute stmt;
	deallocate prepare stmt;
	set @i=@i+1;

	Fetch cur1 into  ffieldid;
	end while loop1;
	close cur1;
end ||
delimiter;
call moveuserscffield();
delimiter;

DROP PROCEDURE IF EXISTS  moveuserscffield;

DROP PROCEDURE IF EXISTS addusertabprofile;
delimiter ||
create PROCEDURE addusertabprofile
(
tabname varchar(200),
permissions int
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
set @permissions=1;
				set @sql=CONCAT('select ifnull(permissions,1) into @permissions from ld_profile2standardpermissions where tabid=29 and operation=3 and profileid=',pprofileid );
				  prepare stmt from @sql;
				 execute stmt;
				deallocate prepare stmt;
		


			set @sql=CONCAT('insert into ld_profile2standardpermissions(profileid,tabid,operation,permissions,sequence) select  ' ,pprofileid,',',@tabid,',',0,',',@permissions,' ,0  from dual  where not exists (select 1 from ld_profile2standardpermissions where profileid=',pprofileid, ' and  tabid=',@tabid,' and operation=0)' );
				  prepare stmt from @sql;
			 execute stmt;
			deallocate prepare stmt;

	select actionid into @actionid from ld_actionmapping where actionname='DetailView';
	set @sql=CONCAT('insert into ld_profile2standardpermissions(profileid,tabid,operation,permissions,sequence) select  ' ,pprofileid,',',@tabid,',',@actionid,',',@permissions,',1  from dual  where not exists (select 1 from ld_profile2standardpermissions where profileid=',pprofileid, ' and  tabid=',@tabid,' and operation=',@actionid,')' );
				  prepare stmt from @sql;

			 execute stmt;
	deallocate prepare stmt;

	select actionid into @actionid from ld_actionmapping where actionname='Create';
	set @sql=CONCAT('insert into ld_profile2standardpermissions(profileid,tabid,operation,permissions,sequence) select  ' ,pprofileid,',',@tabid,',',@actionid,',',@permissions,',2  from dual  where not exists (select 1 from ld_profile2standardpermissions where profileid=',pprofileid, ' and  tabid=',@tabid,' and operation=',@actionid,')' );
				  prepare stmt from @sql;

			 execute stmt;
	deallocate prepare stmt;

select actionid into @actionid from ld_actionmapping where actionname='EditView';

	set @sql=CONCAT('insert into ld_profile2standardpermissions(profileid,tabid,operation,permissions,sequence) select  ' ,pprofileid,',',@tabid,',',@actionid,',',@permissions,',3  from dual  where not exists (select 1 from ld_profile2standardpermissions where profileid=',pprofileid, ' and  tabid=',@tabid,' and operation=',@actionid,')' );
				  prepare stmt from @sql;
			 execute stmt;
	deallocate prepare stmt;

select actionid into @actionid from ld_actionmapping where actionname='RoleProfile';
set @sql=CONCAT('insert into ld_profile2standardpermissions(profileid,tabid,operation,permissions,sequence) select  ' ,pprofileid,',',@tabid,',',@actionid,',',@permissions,' ,4 from dual  where not exists (select 1 from ld_profile2standardpermissions where profileid=',pprofileid, ' and  tabid=',@tabid,' and operation=',@actionid,')' );
				  prepare stmt from @sql;
			 execute stmt;
	deallocate prepare stmt;

select actionid into @actionid from ld_actionmapping where actionname='DataScope';
	set @sql=CONCAT('insert into ld_profile2standardpermissions(profileid,tabid,operation,permissions,sequence) select  ' ,pprofileid,',',@tabid,',',@actionid,',',@permissions,',5  from dual  where not exists (select 1 from ld_profile2standardpermissions where profileid=',pprofileid, ' and  tabid=',@tabid,' and operation=',@actionid,' )');
				  prepare stmt from @sql;
			 execute stmt;
	deallocate prepare stmt;

select actionid into @actionid from ld_actionmapping where actionname='Import';
	set @sql=CONCAT('insert into ld_profile2standardpermissions(profileid,tabid,operation,permissions,sequence) select  ' ,pprofileid,',',@tabid,',',@actionid,',',@permissions,',6  from dual  where not exists (select 1 from ld_profile2standardpermissions where profileid=',pprofileid, ' and  tabid=',@tabid,' and operation=',@actionid,')' );
				  prepare stmt from @sql;
			 execute stmt;
	deallocate prepare stmt;

select actionid into @actionid from ld_actionmapping where actionname='Export';
	set @sql=CONCAT('insert into ld_profile2standardpermissions(profileid,tabid,operation,permissions,sequence) select  ' ,pprofileid,',',@tabid,',',@actionid,',',@permissions,',7  from dual  where not exists (select 1 from ld_profile2standardpermissions where profileid=',pprofileid, ' and  tabid=',@tabid,' and operation=',@actionid,')' );
				  prepare stmt from @sql;
			 execute stmt;
	deallocate prepare stmt;

	select actionid into @actionid from ld_actionmapping where actionname='UserStop';
	set @sql=CONCAT('insert into ld_profile2standardpermissions(profileid,tabid,operation,permissions,sequence) select  ' ,pprofileid,',',@tabid,',',@actionid,',',@permissions,' ,8 from dual  where not exists (select 1 from ld_profile2standardpermissions where profileid=',pprofileid, ' and  tabid=',@tabid,' and operation=',@actionid,')' );
				  prepare stmt from @sql;
			 execute stmt;
	deallocate prepare stmt;

select actionid into @actionid from ld_actionmapping where actionname='UserActivate';
	set @sql=CONCAT('insert into ld_profile2standardpermissions(profileid,tabid,operation,permissions,sequence) select  ' ,pprofileid,',',@tabid,',',@actionid,',',@permissions,',9  from dual  where not exists (select 1 from ld_profile2standardpermissions where profileid=',pprofileid, ' and  tabid=',@tabid,' and operation=',@actionid,')' );
				  prepare stmt from @sql;
			 execute stmt;
	deallocate prepare stmt;

	select actionid into @actionid from ld_actionmapping where actionname='Delete';
	set @sql=CONCAT('insert into ld_profile2standardpermissions(profileid,tabid,operation,permissions,sequence) select  ' ,pprofileid,',',@tabid,',',@actionid,',',@permissions,',10  from dual  where not exists (select 1 from ld_profile2standardpermissions where profileid=',pprofileid, ' and  tabid=',@tabid,' and operation=',@actionid,')' );
	prepare stmt from @sql;
			 execute stmt;
	deallocate prepare stmt;

		select actionid into @actionid from ld_actionmapping where actionname='Copy';
			  set @sql=CONCAT('insert into ld_profile2standardpermissions(profileid,tabid,operation,permissions,sequence) select  ' ,pprofileid,',',@tabid,',',@actionid,',',@permissions,' ,11 from dual  where not exists (select 1 from ld_profile2standardpermissions where profileid=',pprofileid, ' and  tabid=',@tabid,' and operation=',@actionid,')' );
				  prepare stmt from @sql;
			 execute stmt;
	deallocate prepare stmt;

		select actionid into @actionid from ld_actionmapping where actionname='AllowSetRoleDataProfile';

		 set @sql=CONCAT('insert into ld_profile2standardpermissions(profileid,tabid,operation,permissions,sequence) select  ' ,pprofileid,',',@tabid,',',@actionid,',',@permissions,',12  from dual  where not exists (select 1 from ld_profile2standardpermissions where profileid=',pprofileid, ' and  tabid=',@tabid,' and operation=',@actionid,')' );
				  prepare stmt from @sql;
			 execute stmt;
	deallocate prepare stmt;

  


	Fetch cur1 into pprofileid;
	end while loop1;
	close cur1;
end||
delimiter;

call addusertabprofile('Users',0);
delimiter;

DROP PROCEDURE IF EXISTS addusertabprofile;

drop PROCEDURE if exists setprofileallpermissionsequence;
delimiter ||
create PROCEDURE setprofileallpermissionsequence
(

)
begin
	declare done  int  default 0;
	declare ttabid  int ;
	declare cur1 CURSOR FOR SELECT tabid  FROM  ld_tab  where tabid<>29;
	declare continue handler  for not   found  SET done =1;
	
	OPEN cur1;
	Fetch cur1 into ttabid;
	 loop1: while  done<>1 DO
    
		select actionid into @actionid from ld_actionmapping where actionname='DetailView';
		set @sql=CONCAT('update ld_profileallpermission set sequence=1  where operation=',@actionid,' and tabid=',ttabid);
		prepare stmt from @sql;
		execute stmt;
	 deallocate prepare stmt;
	


	select actionid into @actionid from ld_actionmapping where actionname='Create';
		set @sql=CONCAT('update ld_profileallpermission set sequence=2  where operation=',@actionid,' and tabid=',ttabid);
		prepare stmt from @sql;
		execute stmt;
	 deallocate prepare stmt;

	 select actionid into @actionid from ld_actionmapping where actionname='EditView';
		set @sql=CONCAT('update ld_profileallpermission set sequence=3  where operation=',@actionid,' and tabid=',ttabid);
		prepare stmt from @sql;
		execute stmt;
	 deallocate prepare stmt;

		select actionid into @actionid from ld_actionmapping where actionname='Delete';
		set @sql=CONCAT('update ld_profileallpermission set sequence=4  where operation=',@actionid,' and tabid=',ttabid);
		prepare stmt from @sql;
		execute stmt;
	 deallocate prepare stmt;

			select actionid into @actionid from ld_actionmapping where actionname='accountdatadup';
		set @sql=CONCAT('update ld_profileallpermission set sequence=5  where operation=',@actionid,' and tabid=',ttabid);
		prepare stmt from @sql;
		execute stmt;
	 deallocate prepare stmt;


			select actionid into @actionid from ld_actionmapping where actionname='Copy';
		set @sql=CONCAT('update ld_profileallpermission set sequence=6  where operation=',@actionid,' and tabid=',ttabid);
		prepare stmt from @sql;
		execute stmt;
		deallocate prepare stmt;
	select actionid into @actionid from ld_actionmapping where actionname='Allocate';
		set @sql=CONCAT('update ld_profileallpermission set sequence=7  where operation=',@actionid,' and tabid=',ttabid);
		prepare stmt from @sql;
		execute stmt;
	deallocate prepare stmt;

	select actionid into @actionid from ld_actionmapping where actionname='Share';
		set @sql=CONCAT('update ld_profileallpermission set sequence=8  where operation=',@actionid,' and tabid=',ttabid);
		prepare stmt from @sql;
		execute stmt;
	deallocate prepare stmt;
		select actionid into @actionid from ld_actionmapping where actionname='Import';
		set @sql=CONCAT('update ld_profileallpermission set sequence=9 where operation=',@actionid,' and tabid=',ttabid);
		prepare stmt from @sql;
		execute stmt;
	deallocate prepare stmt;

		select actionid into @actionid from ld_actionmapping where actionname='Export';
		set @sql=CONCAT('update ld_profileallpermission set sequence=10 where operation=',@actionid,' and tabid=',ttabid);
		prepare stmt from @sql;
		execute stmt;
	deallocate prepare stmt;

		select actionid into @actionid from ld_actionmapping where actionname='Merge';
		set @sql=CONCAT('update ld_profileallpermission set sequence=11 where operation=',@actionid,' and tabid=',ttabid);
		prepare stmt from @sql;
		execute stmt;
	deallocate prepare stmt;

		select actionid into @actionid from ld_actionmapping where actionname='DuplicatesHandling';
		set @sql=CONCAT('update ld_profileallpermission set sequence=11 where operation=',@actionid,' and tabid=',ttabid);
		prepare stmt from @sql;
		execute stmt;
	deallocate prepare stmt;

select actionid into @actionid from ld_actionmapping where actionname='Merge';
		set @sql=CONCAT('update ld_profileallpermission set sequence=11 where operation=',@actionid,' and tabid=',ttabid);
		prepare stmt from @sql;
		execute stmt;
	deallocate prepare stmt;

	select actionid into @actionid from ld_actionmapping where actionname='Updatestate';
		set @sql=CONCAT('update ld_profileallpermission set sequence=12 where operation=',@actionid,' and tabid=',ttabid);
		prepare stmt from @sql;
		execute stmt;
	deallocate prepare stmt;


	select actionid into @actionid from ld_actionmapping where actionname='ChangeCreator';
		set @sql=CONCAT('update ld_profileallpermission set sequence=13 where operation=',@actionid,' and tabid=',ttabid);
		prepare stmt from @sql;
		execute stmt;
	deallocate prepare stmt;

	

	Fetch cur1 into ttabid;
	end while loop1;
	close cur1;
end||
delimiter;

call setprofileallpermissionsequence();
delimiter;

DROP PROCEDURE IF exists setprofileallpermissionsequence;

select actionid into @actionid from ld_actionmapping where actionname='Create';
update ld_profileallpermission set sequence=1  where operation=@actionid and tabid=29;
delimiter;
select actionid into @actionid from ld_actionmapping where actionname='EditView';
update ld_profileallpermission set sequence=2  where operation=@actionid and tabid=29;
delimiter;
select actionid into @actionid from ld_actionmapping where actionname='RoleProfile';
update ld_profileallpermission set sequence=3  where operation=@actionid and tabid=29;
delimiter;

select actionid into @actionid from ld_actionmapping where actionname='DataScope';
update ld_profileallpermission set sequence=4  where operation=@actionid and tabid=29;
delimiter;

select actionid into @actionid from ld_actionmapping where actionname='Import';
update ld_profileallpermission set sequence=5  where operation=@actionid and tabid=29;
delimiter;

select actionid into @actionid from ld_actionmapping where actionname='Export';
update ld_profileallpermission set sequence=6  where operation=@actionid and tabid=29;
delimiter;
	
select actionid into @actionid from ld_actionmapping where actionname='UserStop';
update ld_profileallpermission set sequence=7  where operation=@actionid and tabid=29;
delimiter;
select actionid into @actionid from ld_actionmapping where actionname='UserActivate';
update ld_profileallpermission set sequence=8  where operation=@actionid and tabid=29;
delimiter;
select actionid into @actionid from ld_actionmapping where actionname='Delete';
update ld_profileallpermission set sequence=9  where operation=@actionid and tabid=29;
delimiter;
select actionid into @actionid from ld_actionmapping where actionname='Copy';
update ld_profileallpermission set sequence=10  where operation=@actionid and tabid=29;
delimiter;
select actionid into @actionid from ld_actionmapping where actionname='AllowSetRoleDataProfile';
update ld_profileallpermission set sequence=11  where operation=@actionid and tabid=29;
delimiter;


insert into ld_desk (languagetype,labelbol,fieldlabel,labeltype)
select 'zh','USESAVEREMINDROLEPROFILE','保存成功，请联系管理员设置用户的角色与权限','jspop' from dual 
where not exists(select 1 from ld_desk  where languagetype='zh' and labelbol='USESAVEREMINDROLEPROFILE' and labeltype='jspop');

insert into ld_desk (languagetype,labelbol,fieldlabel,labeltype)
select 'en','USESAVEREMINDROLEPROFILE','保存成功，请联系管理员设置用户的角色与权限','jspop' from dual 
where not exists(select 1 from ld_desk  where languagetype='en' and labelbol='USESAVEREMINDROLEPROFILE' and labeltype='jspop');
delimiter;
-- 2017-11-10

SELECT fieldid INTO @fieldid FROM ld_field WHERE tabid=29 AND columnname='is_admin'; 
UPDATE ld_tranlabel SET fieldlabel='是否管理员' WHERE Relateid=@fieldid AND trantable='ld_field' AND languagetype='zh';
UPDATE ld_tranlabel SET fieldlabel='IS Admin' WHERE Relateid=@fieldid AND trantable='ld_field' AND languagetype='en';
delimiter;

SELECT fieldid INTO @fieldid FROM ld_field WHERE tabid=29 AND columnname='groupid'; 
UPDATE ld_tranlabel SET fieldlabel='部门' WHERE Relateid=@fieldid AND trantable='ld_field' AND languagetype='zh' AND fieldlabel='选择部门';
UPDATE ld_tranlabel SET fieldlabel='Department' WHERE Relateid=@fieldid AND trantable='ld_field' AND languagetype='en' AND fieldlabel='Select Group';
delimiter;

SELECT cvid INTO @cvid FROM ld_customview WHERE entitytype='Users' AND viewname='All' LIMIT 1;
SET @i=0;
DELETE FROM ld_cvcolumnlist WHERE cvid=@cvid;
INSERT INTO ld_cvcolumnlist(cvid,columnindex,columnname)
SELECT @cvid,@i,'ld_users:last_name:last_name:Users_fieldlabel:V'; 
INSERT INTO ld_cvcolumnlist(cvid,columnindex,columnname)
SELECT @cvid,(@i:=@i+1),'ld_users:user_name:user_name:Users_fieldlabel:V'; 
INSERT INTO ld_cvcolumnlist(cvid,columnindex,columnname)
SELECT @cvid,(@i:=@i+1),'ld_users:groupid:groupid:Users_fieldlabel:V'; 
INSERT INTO ld_cvcolumnlist(cvid,columnindex,columnname)
SELECT @cvid,(@i:=@i+1),'ld_users:profileid:profileid:Users_fieldlabel:V'; 
INSERT INTO ld_cvcolumnlist(cvid,columnindex,columnname)
SELECT @cvid,(@i:=@i+1),'ld_users:userlevel:userlevel:Users_fieldlabel:V'; 
INSERT INTO ld_cvcolumnlist(cvid,columnindex,columnname)
SELECT @cvid,(@i:=@i+1),'ld_users:phone_mobile:phone_mobile:Users_fieldlabel:V'; 
INSERT INTO ld_cvcolumnlist(cvid,columnindex,columnname)
SELECT @cvid,(@i:=@i+1),'ld_users:email1:email1:Users_fieldlabel:E'; 
INSERT INTO ld_cvcolumnlist(cvid,columnindex,columnname)
SELECT @cvid,(@i:=@i+1),'ld_users:is_admin:is_admin:Users_fieldlabel:V'; 
INSERT INTO ld_cvcolumnlist(cvid,columnindex,columnname)
SELECT @cvid,(@i:=@i+1),'ld_users:status:status:Users_fieldlabel:V'; 
delimiter;

UPDATE ld_desk SET fieldlabel='设置业务单据可查询的数据范围' WHERE fieldlabel='业务单据授权范围' AND labelbol in ('THEQUERYSCOPE','Thequeryscope');
UPDATE ld_desk SET fieldlabel='设置用户可操作功能的权限' WHERE fieldlabel='角色权限' AND labelbol='SETTHEPERMISSIONS';


set @tabid=29;
select max(relation_id) into @maxrelation_id from ld_relatedlists;
select tabid into @related_tabid from ld_tab where name='Attachment';
insert into ld_relatedlists(relation_id,tabid,related_tabid,name,sequence,label,presence,actions,type,related_coltable)
select @maxrelation_id+1,@tabid,@related_tabid,'get_attachment',1,'Attachment',0,'add','datacategory_sql','attachmentsforbills.related_to' from DUAL
where not exists(select 1 from ld_relatedlists where tabid=@tabid and related_tabid=@related_tabid);
delimiter;

delete from ld_field  where tabid=29 and columnname='attachmentsid';
delimiter;

update ld_desk set fieldlabel = '{$OutboundOrder.OutboundOrder}产品累计出库数量超过源单产品可出库数量' where labelbol = 'THETOTALOUTBOUNDQUANTITY' and languagetype = 'zh' and Labeltype = 'jspop';
update ld_desk set fieldlabel = 'The {$OutboundOrder.OutboundOrder} total Outbound quantity of products is greater than the allowable quantity' where labelbol = 'THETOTALOUTBOUNDQUANTITY' and languagetype = 'en' and Labeltype = 'jspop';
delimiter;

update ld_desk set fieldlabel='你可以点击下面' where labelbol='YOUCANCLICKONTHE' and Labeltype='fixedstr' and languagetype='zh';
update ld_desk set fieldlabel='You can click below ' where labelbol='YOUCANCLICKONTHE' and Labeltype='fixedstr' and languagetype='en';
update ld_desk set fieldlabel='按钮增加一条记录。' where labelbol='ADDARECORD' and Labeltype='fixedstr' and languagetype='zh';
delimiter;

select tabid into @tabid from ld_tab where `name` = 'OutboundOrder';
insert into ld_links(tabid,linktype,linklabel,linkurl,description)
select @tabid,'Module','toexamine','http://51mis.com.cn/forum.php?mod=viewthread&tid=274&fromuid=1','可出/入库数量超过源单跳转链接,负库存跳转链接' from DUAL
where not exists(select 1 from ld_links where tabid = @tabid and linktype = 'Module' and linklabel = 'toexamine');
delimiter;

DELETE FROM ld_settings_field WHERE `name`='LBL_PICKLIST_EDITOR';

update ld_desk set fieldlabel = '新增->追加' where labelbol = 'QuotesChange_Add' and languagetype = 'zh' and Labeltype = 'fixedstr';
update ld_desk set fieldlabel = '新增->变更' where labelbol = 'QuotesChange_Replace' and languagetype = 'zh' and Labeltype = 'fixedstr';
delimiter;

select tabid into @tabid from ld_tab where name='QuotesChange';
select blockid into @blockid from ld_appparenttab where parenttab_label='Sales';
select tabid into @quotabid from ld_tab where name='Quotes';
select sequence into @sequence from ld_appparenttabrel where blockid=@blockid and tabid=@quotabid;
insert into ld_appparenttabrel(blockid,tabid,sequence)
select @blockid,@tabid,@sequence from dual 
where not exists(select 1 from ld_appparenttabrel where blockid=@blockid and tabid=@tabid);
set @i=0;
update ld_appparenttabrel set sequence=(@i:=@i+1) where blockid=@blockid order by sequence;
delimiter;
update ld_tab set mobilepresence='weixin' where tabid=@tabid;
delimiter;

insert into ld_cvcolumnlist_wx(modulename,rownumber,listnumber,columnname,type)
  select 'QuotesChange',1,1,'ld_quoteschange:quoteschange_no:quoteschange_no:QuotesChange_fieldlabel:V',2 
  from dual where not exists(select 1 from ld_cvcolumnlist_wx
  where modulename = 'QuotesChange' and columnname LIKE 'ld_quoteschange:quoteschange_no:%');
insert into ld_cvcolumnlist_wx(modulename,rownumber,listnumber,columnname)
  select 'QuotesChange',1,2,'ld_quoteschange:accountid:account_id:QuotesChange_fieldlabel:V' 
  from dual where not exists(select 1 from ld_cvcolumnlist_wx
  where modulename = 'QuotesChange' and columnname LIKE 'ld_quoteschange:accountid:%');
insert into ld_cvcolumnlist_wx(modulename,rownumber,listnumber,columnname,type)
  select 'QuotesChange',2,1,'ld_quoteschange:change_type:change_type:QuotesChange_fieldlabel:V',2 
  from dual where not exists(select 1 from ld_cvcolumnlist_wx
  where modulename = 'QuotesChange' and columnname LIKE 'ld_quoteschange:change_type:%');
insert into ld_cvcolumnlist_wx(modulename,rownumber,listnumber,columnname)
  select 'QuotesChange',2,2,'ld_quoteschange:change_date:change_date:QuotesChange_fieldlabel:V' 
  from dual where not exists(select 1 from ld_cvcolumnlist_wx
  where modulename = 'QuotesChange' and columnname LIKE 'ld_quoteschange:total:%');
insert into ld_cvcolumnlist_wx(modulename,rownumber,listnumber,columnname)
  select 'QuotesChange',2,3,'ld_quoteschange:smownerid:assigned_user_id:QuotesChange_fieldlabel:V' 
  from dual where not exists(select 1 from ld_cvcolumnlist_wx
  where modulename = 'QuotesChange' and columnname LIKE 'ld_quoteschange:smownerid:%');
delimiter;

update ld_desk set fieldlabel='To save successfully, please contact the administrator to set up the roles and permissions of the user'  where labeltype='jspop' and labelbol='USESAVEREMINDROLEPROFILE' and languagetype='en';
delimiter;
-- 2017-11-13

select tabid into @tabid from ld_tab where name='Users';
select tabid into @related_tabid from ld_tab where name='Attachment';
insert into ld_quickactions(tabid,related_tabid,sequence,presence,label)
select @tabid,@related_tabid,1,0,NULL from dual
where not EXISTS(select 1 from ld_quickactions where tabid=@tabid and related_tabid=@related_tabid);

DELETE FROM ld_field WHERE columnname='salesorderid' AND presence=1 AND tablename IN ('ld_outboundorder','ld_invoice');

set @tabid=29;
select max(relation_id) into @maxrelation_id from ld_quickactions;
select tabid into @related_tabid from ld_tab where name='Attachment';
insert into ld_quickactions(relation_id,tabid,related_tabid,sequence,label)
select @maxrelation_id+1,@tabid,@related_tabid,1,'Attachment' from DUAL
where not exists(select 1 from ld_quickactions where tabid=@tabid and related_tabid=@related_tabid);
delimiter;

update ld_field set defaultvalue='公开' where tabid in(select tabid from ld_tab where name='Attachment') and columnname='isenabled'
 and not exists(select crmid from ld_crmentity where crmid>2);
 delimiter;
 
 insert into ld_modtracker_tabs(tabid,visible)
select 29,1 from dual where not EXISTS(select 1 from ld_modtracker_tabs where tabid=29);
delimiter;
select max(relation_id) into @maxrelation_id from ld_relatedlists;
insert into ld_relatedlists(relation_id,tabid,related_tabid,name,sequence,label,presence,actions)
select @maxrelation_id+1,29,'-7','get_viewhistory',2,'ViewHistory',0,'' from DUAL
where not EXISTS(select 1 from ld_relatedlists where tabid=29 and related_tabid='-7');
delimiter;

select tabid into @tabid from ld_tab where `name` = 'Users';
select fieldid into @fieldid from ld_field where tabid = @tabid and columnname = 'select_servicedetail';
update ld_tranlabel set fieldlabel = '{$Accounts.Accounts}和{$HelpDesk.HelpDesk}界面是否显示服务信息' 
where tabid = @tabid and Relateid = @fieldid and languagetype = 'zh' and trantable = 'ld_field';
update ld_tranlabel set fieldlabel = '{$Accounts.Accounts} and {$HelpDesk.HelpDesk} view whether to display the information service' 
where tabid = @tabid and Relateid = @fieldid and languagetype = 'en' and trantable = 'ld_field';
delimiter;

select tabid into @tabid from ld_tab where `name` = 'Users';
select fieldid into @fieldid from ld_field where tabid = @tabid and columnname = 'select_due_date';
update ld_tranlabel set fieldlabel = '{$Accounts.Accounts}和{$HelpDesk.HelpDesk}界面显示具体的服务到期日' 
where tabid = @tabid and Relateid = @fieldid and languagetype = 'zh' and trantable = 'ld_field';
update ld_tranlabel set fieldlabel = '{$Accounts.Accounts} and {$HelpDesk.HelpDesk} view the real service enddate' 
where tabid = @tabid and Relateid = @fieldid and languagetype = 'en' and trantable = 'ld_field';
delimiter;

select tabid into @tabid from ld_tab where `name` = 'Users';
select fieldid into @fieldid from ld_field where tabid = @tabid and columnname = 'accountallview';
update ld_tranlabel set fieldlabel = '相关信息列表是否允许查询所有数据' 
where tabid = @tabid and Relateid = @fieldid and languagetype = 'zh' and trantable = 'ld_field';
update ld_tranlabel set fieldlabel = 'Allows you to view the relevant information list data permissions' 
where tabid = @tabid and Relateid = @fieldid and languagetype = 'en' and trantable = 'ld_field';
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','documenterrorinfo','单据[%s]%s不成功！原因：%s!','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype = 'zh' and labelbol = 'documenterrorinfo' and labeltype = 'fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','documenterrorinfo','Document [%s]%s is not successful! Reason: %s!','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype = 'en' and labelbol = 'documenterrorinfo' and labeltype = 'fixedstr');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','usernamecannotbepurenumbers','用户账号不能为纯数字！','jspop' from dual
where not exists(select 1 from ld_desk where languagetype = 'zh' and labelbol = 'usernamecannotbepurenumbers' and labeltype = 'jspop');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','usernamecannotbepurenumbers','User name cannot be pure numbers!','jspop' from dual
where not exists(select 1 from ld_desk where languagetype = 'en' and labelbol = 'usernamecannotbepurenumbers' and labeltype = 'jspop');
delimiter;

select count(1) into @count from ld_crmentity;
select blockid into @blockid from ld_appparenttab where parenttab_label = 'OAForms';
select tabid into @tabid from ld_tab where `name` = 'BusinessApply';
select tabid into @expense_tabid from ld_tab where `name` = 'Expense';
select sequence into @sequence from ld_appparenttabrel where blockid = @blockid and tabid = @tabid;
update ld_appparenttabrel set sequence = sequence + 1000 where blockid = @blockid and sequence > @sequence and @count <= 2;
update ld_appparenttabrel set sequence = @sequence + 1 where blockid = @blockid and tabid = @expense_tabid and @count <= 2;
set @i=0;
update ld_appparenttabrel set sequence=(@i:=@i+1) where blockid = @blockid order by sequence;
delimiter;

update ld_desk set fieldlabel = '恢复预设列宽' where labelbol = 'ResetListWidth' and languagetype = 'zh' and Labeltype = 'fixedstr';
update ld_desk set fieldlabel = 'Restore the default column width' where labelbol = 'ResetListWidth' and languagetype = 'en' and Labeltype = 'fixedstr';
delimiter;

select tabid into @tabid from ld_tab where name='Attachment';
update ld_field set defaultvalue='公开' where  columnname='isenabled';
delimiter;

select max(sequence) into @sequence from ld_parenttab;
select max(parenttabid) into @parenttabid from ld_parenttab;
insert into ld_parenttab(parenttabid,parenttab_label,sequence,visible)
select @parenttabid+1,'Setup',@sequence+1,0 from DUAL
where not exists(select 1 from ld_parenttab where parenttab_label = 'Setup');
delimiter;

select parenttabid into @parenttabid from ld_parenttab where parenttab_label = 'Setup';
insert into ld_tranlabel(languagetype,trantable,tabid,Relateid,fieldlabel)
select 'zh','ld_parenttab',@parenttabid,@parenttabid,'设置' from DUAL
where not exists(select 1 from ld_tranlabel where languagetype = 'zh' and trantable = 'ld_parenttab' and tabid = @parenttabid and Relateid = @parenttabid);
insert into ld_tranlabel(languagetype,trantable,tabid,Relateid,fieldlabel)
select 'en','ld_parenttab',@parenttabid,@parenttabid,'Setup' from DUAL
where not exists(select 1 from ld_tranlabel where languagetype = 'en' and trantable = 'ld_parenttab' and tabid = @parenttabid and Relateid = @parenttabid);
delimiter;

select tabid into @user_tabid from ld_tab where `name` = 'Users';
select parenttabid into @parenttabid from ld_parenttab where parenttab_label = 'Setup';
delete from ld_parenttabrel where tabid = @user_tabid and parenttabid != @parenttabid;
insert into ld_parenttabrel(parenttabid,tabid,sequence)
select @parenttabid,@user_tabid,1 from DUAL
where not exists(select 1 from ld_parenttabrel where parenttabid = @parenttabid and tabid = @user_tabid);
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','SYSTEM_DESCRIPTION','系统设置','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype = 'zh' and labelbol = 'SYSTEM_DESCRIPTION' and labeltype = 'fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','SYSTEM_DESCRIPTION','System Setup','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype = 'en' and labelbol = 'SYSTEM_DESCRIPTION' and labeltype = 'fixedstr');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','CANCELACCOUNT','注销账户','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype = 'zh' and labelbol = 'CANCELACCOUNT' and labeltype = 'fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','CANCELACCOUNT','Cancel Account','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype = 'en' and labelbol = 'CANCELACCOUNT' and labeltype = 'fixedstr');
delimiter;

select blockid into @blockid from ld_settings_blocks where active=0 and label = 'LBL_USER_MANAGEMENT';
delete from ld_settings_field where blockid = @blockid and `name` = 'LBL_USERS';
delimiter;

UPDATE ld_desk SET fieldlabel='拜访签到' WHERE labelbol='OUTSIDESIGN' AND languagetype='zh';
UPDATE ld_desk SET fieldlabel='系统设置' WHERE labelbol='CONTROLPANEL' AND languagetype='zh';
delimiter;

update ld_desk set fieldlabel = '权限管理' where labelbol = 'LBL_USER_MANAGEMENT' and languagetype = 'zh' and Labeltype = 'fixedstr';
update ld_desk set fieldlabel = 'Profile Management' where labelbol = 'LBL_USER_MANAGEMENT' and languagetype = 'en' and Labeltype = 'fixedstr';
delimiter;

UPDATE ld_desk SET fieldlabel='工作汇报' WHERE labelbol='LBL_COOPERATIVEWORK' AND languagetype='zh';
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','Displaycontacts','显示联系人','jspop' from dual
where not exists(select 1 from ld_desk where languagetype = 'zh' and labelbol = 'Displaycontacts' and labeltype = 'jspop');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','Displaycontacts','Display contacts','jspop' from dual
where not exists(select 1 from ld_desk where languagetype = 'en' and labelbol = 'Displaycontacts' and labeltype = 'jspop');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','Viewupperandlowerrelations','查看上下级关系','jspop' from dual
where not exists(select 1 from ld_desk where languagetype = 'zh' and labelbol = 'Viewupperandlowerrelations' and labeltype = 'jspop');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','Viewupperandlowerrelations','View organizational structure','jspop' from dual
where not exists(select 1 from ld_desk where languagetype = 'en' and labelbol = 'Viewupperandlowerrelations' and labeltype = 'jspop');
delimiter;

update ld_desk set fieldlabel = '查看上下级关系' where labelbol = 'LBL_SHOW_ACCOUNT_HIERARCHY' and languagetype = 'zh' and Labeltype = 'fixedstr';
update ld_desk set fieldlabel = 'View organizational structure' where labelbol = 'LBL_SHOW_ACCOUNT_HIERARCHY' and languagetype = 'en' and Labeltype = 'fixedstr';
delimiter;

update ld_desk set fieldlabel = '查看上下级关系' where labelbol = 'LBL_SHOW_ACCOUNT_HIERARCHY' and languagetype = 'zh' and Labeltype = 'fixedstr';
update ld_desk set fieldlabel = 'View organizational structure' where labelbol = 'LBL_SHOW_ACCOUNT_HIERARCHY' and languagetype = 'en' and Labeltype = 'fixedstr';
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','ACCOUNTS','客户','jspop' from dual
where not exists(select 1 from ld_desk where languagetype = 'zh' and labelbol = 'ACCOUNTS' and labeltype = 'jspop');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','ACCOUNTS','Accounts','jspop' from dual
where not exists(select 1 from ld_desk where languagetype = 'en' and labelbol = 'ACCOUNTS' and labeltype = 'jspop');
delimiter;

select parenttabid into @parenttabid from ld_parenttab where parenttab_label = 'Setup';
delete from ld_parenttab where parenttabid = @parenttabid;
delete from ld_parenttabrel where parenttabid = @parenttabid;
delimiter;

UPDATE ld_tranlabel SET fieldlabel='产品管理' WHERE tabid=14 AND trantable='ld_tab' AND languagetype='zh' AND fieldlabel='产品'
	AND EXISTS (SELECT 1 FROM ld_version WHERE versiontype IN (55,56,57,58));

UPDATE ld_tranlabel SET fieldlabel='产品管理' WHERE tabid=14 AND trantable='ld_tab' AND languagetype='zh'
	AND NOT EXISTS (SELECT 1 FROM ld_products);
-- 2017-11-20

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','Setup','设置','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype = 'zh' and labelbol = 'Setup' and labeltype = 'fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','Setup','Setup','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype = 'en' and labelbol = 'Setup' and labeltype = 'fixedstr');
delimiter;

CALL AddColumn('ld_dashboard_app','wx_presence','int','19',0);
CALL AddColumn('ld_dashboard_app','wx_sequence','int','19',0);

update ld_dashboard_app set wx_presence=1,wx_sequence=1 where name='Contractamount';
update ld_dashboard_app set wx_presence=1,wx_sequence=2 where name='Returnamount';
update ld_dashboard_app set wx_presence=1,wx_sequence=3 where name='Salessituation';
update ld_dashboard_app set wx_presence=1,wx_sequence=4 where name='Salesfunnel';
update ld_dashboard_app set wx_presence=1,wx_sequence=5 where name='daylog';
update ld_desk set fieldlabel='签约金额同比' where labelbol='STATISTICALSIGNQUOTA' and languagetype='zh';
update ld_desk set fieldlabel='日志提交情况统计表' where labelbol='STATISTICALDAYLOG' and languagetype='zh';
update ld_desk set fieldlabel='Daylog submission on statistical' where labelbol='STATISTICALDAYLOG' and languagetype='en';
delimiter;

delete from ld_appparenttabrel where tabid in(-3,-4);
SET @blockid=0;
select blockid into @blockid from ld_appparenttab where parenttab_label='BaseSetting';
delete from ld_appparenttab where blockid=@blockid;
delete from ld_appparenttabrel where blockid=@blockid;
delimiter;


insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','Setup','设置','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype = 'zh' and labelbol = 'Setup' and labeltype = 'fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','Setup','Setup','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype = 'en' and labelbol = 'Setup' and labeltype = 'fixedstr');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','staydo','待办','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype = 'zh' and labelbol = 'staydo' and labeltype = 'fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','staydo','Setup','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype = 'en' and labelbol = 'staydo' and labeltype = 'fixedstr');
delimiter;

select blockid into @blockid from ld_settings_blocks where active=0 and label = 'LBL_USER_MANAGEMENT';
delete from ld_settings_field where blockid = @blockid and `name` in('LBL_ROLES','USERGROUPLIST');
delimiter;

delete from ld_appparenttabrel where tabid in(-3,-4);
SET @blockid=0;
select blockid into @blockid from ld_appparenttab where parenttab_label='BaseSetting';
delete from ld_appparenttab where blockid=@blockid;
delete from ld_appparenttabrel where blockid=@blockid;
delimiter;
-- 2017-11-21

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','signout','退出登录','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype = 'zh' and labelbol = 'signout' and labeltype = 'fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','signout','Setup','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype = 'en' and labelbol = 'signout' and labeltype = 'fixedstr');
delimiter;

select tabid into @qtabid from ld_tab where name = 'Quotes';
select tabid into @stabid from ld_tab where name = 'ServiceContracts';
select sequence into @sequence from ld_relatedlists where tabid = @qtabid and name = 'get_salesorder';
update ld_relatedlists set sequence = sequence+1 where tabid = @qtabid and sequence > @sequence;
SELECT max(relation_id) INTO @relation_id FROM ld_relatedlists;
INSERT INTO  ld_relatedlists(relation_id,tabid,related_tabid,NAME,sequence,label,presence,actions,mobile_presence,mobile_sequence)
SELECT @relation_id+1,@qtabid,@stabid,'get_ServiceContracts',@sequence+1,'ServiceContracts',0,'add',1,1
FROM DUAL WHERE NOT EXISTS(SELECT 1 FROM ld_relatedlists WHERE tabid=@qtabid AND NAME='get_ServiceContracts');
delimiter;

set @i=0; 
update ld_relatedlists set sequence=(@i:=@i+1) where tabid = @qtabid order by sequence; 
delimiter;

select tabid into @stabid from ld_tab where name = 'ServiceContracts';
select tabid into @ptabid from ld_tab where name = 'PurchaseOrder';
select sequence into @sequence from ld_relatedlists where tabid = @stabid and name = 'get_invoice';
update ld_relatedlists set sequence = sequence+1 where tabid = @stabid and sequence > @sequence;
SELECT max(relation_id) INTO @relation_id FROM ld_relatedlists;
INSERT INTO  ld_relatedlists(relation_id,tabid,related_tabid,NAME,sequence,label,presence,actions,mobile_presence,mobile_sequence,type,related_coltable)
SELECT @relation_id+1,@stabid,@ptabid,'get_purchaseorder',@sequence+1,'PurchaseOrder',1,'add',1,1,'datacategory_sql','inventoryproductrel.entitytypeid'
FROM DUAL WHERE NOT EXISTS(SELECT 1 FROM ld_relatedlists WHERE tabid=@stabid AND NAME='get_purchaseorder');
delimiter;

set @i=0; 
update ld_relatedlists set sequence=(@i:=@i+1) where tabid = @stabid order by sequence; 
delimiter;

select tabid into @vtabid from ld_tab where name = 'Vendors';
select tabid into @etabid from ld_tab where name = 'Expense';
select sequence into @sequence from ld_relatedlists where tabid = @vtabid and name = 'get_stock';
update ld_relatedlists set sequence = sequence+1 where tabid = @vtabid and sequence > @sequence;
SELECT max(relation_id) INTO @relation_id FROM ld_relatedlists;
INSERT INTO  ld_relatedlists(relation_id,tabid,related_tabid,NAME,sequence,label,presence,actions,mobile_presence,mobile_sequence,wx_presence,wx_sequence,type,related_coltable)
SELECT @relation_id+1,@vtabid,@etabid,'get_expense',@sequence+1,'Expense',0,'add',1,1,0,@sequence+1,'',''
FROM DUAL WHERE NOT EXISTS(SELECT 1 FROM ld_relatedlists WHERE tabid=@vtabid AND NAME='get_expense');
delimiter;

set @i=0; 
update ld_relatedlists set sequence=(@i:=@i+1) where tabid = @vtabid order by sequence; 
delimiter;

select tabid into @tabid from ld_tab where name='SalesOrder';
select tabid into @related_tabid from ld_tab where name='SalesBack';
update ld_relatedlists set actions='add' where tabid=@tabid and related_tabid=@related_tabid;
delimiter;

select tabid into @tabid from ld_tab where name='SalesOrder';
select tabid into @related_tabid from ld_tab where name='PaymentPlan';
update ld_relatedlists set actions='add' where tabid=@tabid and related_tabid=@related_tabid;
delimiter;

select tabid into @tabid from ld_tab where name='SalesBack';
select tabid into @related_tabid from ld_tab where name='CashBack';
update ld_relatedlists set actions='add' where tabid=@tabid and related_tabid=@related_tabid;
delimiter;
select tabid into @tabid from ld_tab where name='PurchaseOrder';
select tabid into @related_tabid from ld_tab where name='PurchaseBack';
update ld_relatedlists set actions='add' where tabid=@tabid and related_tabid=@related_tabid;
delimiter;

select tabid into @tabid from ld_tab where name='PurchaseBack';
select tabid into @related_tabid from ld_tab where name='CashBack';
update ld_relatedlists set actions='add' where tabid=@tabid and related_tabid=@related_tabid;
delimiter;

select max(tabsequence) into @tabsequence from ld_tab;
insert into ld_tab(tabid,name,presence,tabsequence,tablabel,printtab )
select -1,'CooperativeWork',0,@tabsequence+1,'CooperativeWork',1 from dual 
where not EXISTS(select 1 from ld_tab where name='CooperativeWork');

select tabid into @tabid from ld_tab  where name='CooperativeWork';
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'zh','ld_tab',@tabid,@tabid,'工作协同' from dual 
where not exists(select 1 from ld_tranlabel where tabid=@tabid and relateid=@tabid and languagetype='zh'and trantable='ld_tab' );
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'en','ld_tab',@tabid,@tabid,'Cooperative Work' from dual 
where not exists(select 1 from ld_tranlabel where tabid=@tabid and relateid=@tabid and languagetype='en' and trantable='ld_tab');
delimiter;

update ld_systems_deploy set inputvalue = '[{"value":"0","text":"YES"},{"value":"1","text":"NO"},{"sql":""}]',deploy_value = 1
where deploy_type = 66;
delimiter;

update ld_tranlabel set fieldlabel = '设置首页组件是否显示客户地图' where trantable = 'ld_systems_deploy' and languagetype = 'zh' and tabid = 66 and Relateid = 66;
update ld_tranlabel set fieldlabel = 'Setting home page components to display account maps' where trantable = 'ld_systems_deploy' and languagetype = 'en' and tabid = 66 and Relateid = 66;
delimiter;

DROP PROCEDURE IF EXISTS `ldcrm_reset_appparenttab`;
delimiter ||
CREATE PROCEDURE `ldcrm_reset_appparenttab`(
)
BEGIN

	IF EXISTS (SELECT 1 FROM ld_version WHERE versiontype IN (55,56,57,58)) AND NOT EXISTS (SELECT 1 FROM ld_account) THEN
	    SET @blockid=0;
		SELECT blockid INTO @blockid FROM ld_appparenttab WHERE parenttab_label='Accounts' AND systemdefault='yes';
		DELETE FROM ld_appparenttabrel WHERE blockid=@blockid;
		SET @i=0;
		INSERT INTO ld_appparenttabrel(blockid,tabid,sequence)
		SELECT @blockid,6,(@i:=@i+1);
		INSERT INTO ld_appparenttabrel(blockid,tabid,sequence)
		SELECT @blockid,4,(@i:=@i+1);
		INSERT INTO ld_appparenttabrel(blockid,tabid,sequence)
		SELECT @blockid,(SELECT tabid FROM ld_tab WHERE `name`='ContactRecords'),(@i:=@i+1);
		INSERT INTO ld_appparenttabrel(blockid,tabid,sequence)
		SELECT @blockid,-2,(@i:=@i+1);


        SET @blockid=0;
		SELECT blockid INTO @blockid FROM ld_appparenttab WHERE parenttab_label='Sales' AND systemdefault='yes';
		DELETE FROM ld_appparenttabrel WHERE blockid=@blockid;
		SET @i=0;
		INSERT INTO ld_appparenttabrel(blockid,tabid,sequence)
		SELECT @blockid,2,(@i:=@i+1);
		INSERT INTO ld_appparenttabrel(blockid,tabid,sequence)
		SELECT @blockid,22,(@i:=@i+1);
		INSERT INTO ld_appparenttabrel(blockid,tabid,sequence)
		SELECT @blockid,23,(@i:=@i+1);
		INSERT INTO ld_appparenttabrel(blockid,tabid,sequence)
		SELECT @blockid,(SELECT tabid FROM ld_tab WHERE `name`='CashBill'),(@i:=@i+1);
        
        SET @blockid=0;
		SELECT blockid INTO @blockid FROM ld_appparenttab WHERE parenttab_label='OAForms' AND systemdefault='yes';
		UPDATE ld_appparenttab SET blockname='申请汇报' WHERE blockid=@blockid AND blockname IN ('OA表单','申报中心');
		DELETE FROM ld_appparenttabrel WHERE blockid=@blockid;
		SET @i=0;
		INSERT INTO ld_appparenttabrel(blockid,tabid,sequence)
		SELECT @blockid,-1,(@i:=@i+1);
		INSERT INTO ld_appparenttabrel(blockid,tabid,sequence)
		SELECT @blockid,(SELECT tabid FROM ld_tab WHERE `name`='BusinessApply'),(@i:=@i+1);
		INSERT INTO ld_appparenttabrel(blockid,tabid,sequence)
		SELECT @blockid,(SELECT tabid FROM ld_tab WHERE `name`='Commission'),(@i:=@i+1);
		INSERT INTO ld_appparenttabrel(blockid,tabid,sequence)
		SELECT @blockid,(SELECT tabid FROM ld_tab WHERE `name`='CardApply'),(@i:=@i+1);
		INSERT INTO ld_appparenttabrel(blockid,tabid,sequence)
		SELECT @blockid,(SELECT tabid FROM ld_tab WHERE `name`='Expense'),(@i:=@i+1);



        SET @blockid=0;
		SELECT parenttabid INTO @blockid FROM ld_parenttab WHERE parenttab_label='My Home Page';
		DELETE FROM ld_parenttabrel WHERE parenttabid=@blockid;
		SET @i=0;
		INSERT INTO ld_parenttabrel(parenttabid,tabid,sequence)
		SELECT @blockid,3,(@i:=@i+1);

        SET @blockid=0;
		SELECT parenttabid INTO @blockid FROM ld_parenttab WHERE parenttab_label='Parent Accounts';
		DELETE FROM ld_parenttabrel WHERE parenttabid=@blockid;
		SET @i=0;
		INSERT INTO ld_parenttabrel(parenttabid,tabid,sequence)
		SELECT @blockid,6,(@i:=@i+1);
		INSERT INTO ld_parenttabrel(parenttabid,tabid,sequence)
		SELECT @blockid,4,(@i:=@i+1);
		INSERT INTO ld_parenttabrel(parenttabid,tabid,sequence)
		SELECT @blockid,(SELECT tabid FROM ld_tab WHERE `name`='ContactRecords'),(@i:=@i+1);

        SET @blockid=0;
		SELECT parenttabid INTO @blockid FROM ld_parenttab WHERE parenttab_label='Sales';
		DELETE FROM ld_parenttabrel WHERE parenttabid=@blockid;
		SET @i=0;
		INSERT INTO ld_parenttabrel(parenttabid,tabid,sequence)
		SELECT @blockid,2,(@i:=@i+1);
		INSERT INTO ld_parenttabrel(parenttabid,tabid,sequence)
		SELECT @blockid,22,(@i:=@i+1);
		INSERT INTO ld_parenttabrel(parenttabid,tabid,sequence)
		SELECT @blockid,23,(@i:=@i+1);
		INSERT INTO ld_parenttabrel(parenttabid,tabid,sequence)
		SELECT @blockid,(SELECT tabid FROM ld_tab WHERE `name`='CashBill'),(@i:=@i+1);

        SET @blockid=0;
		SELECT parenttabid INTO @blockid FROM ld_parenttab WHERE parenttab_label='OAForms';
		UPDATE ld_tranlabel SET fieldlabel='申请汇报' WHERE Relateid=@blockid AND trantable='ld_parenttab' AND languagetype='zh' AND fieldlabel='OA表单';
		DELETE FROM ld_parenttabrel WHERE parenttabid=@blockid;
		SET @i=0;
		INSERT INTO ld_parenttabrel(parenttabid,tabid,sequence)
		SELECT @blockid,-1,(@i:=@i+1);
		INSERT INTO ld_parenttabrel(parenttabid,tabid,sequence)
		SELECT @blockid,(SELECT tabid FROM ld_tab WHERE `name`='BusinessApply'),(@i:=@i+1);
		INSERT INTO ld_parenttabrel(parenttabid,tabid,sequence)
		SELECT @blockid,(SELECT tabid FROM ld_tab WHERE `name`='Commission'),(@i:=@i+1);
		INSERT INTO ld_parenttabrel(parenttabid,tabid,sequence)
		SELECT @blockid,(SELECT tabid FROM ld_tab WHERE `name`='CardApply'),(@i:=@i+1);
		INSERT INTO ld_parenttabrel(parenttabid,tabid,sequence)
		SELECT @blockid,(SELECT tabid FROM ld_tab WHERE `name`='Expense'),(@i:=@i+1);

        SET @blockid=0;
		SELECT parenttabid INTO @blockid FROM ld_parenttab WHERE parenttab_label='Parent Reports';
		DELETE FROM ld_parenttabrel WHERE parenttabid=@blockid AND tabid=(SELECT tabid FROM ld_tab WHERE `name`='Comprehensivereport');
		DELETE FROM ld_parenttabrel WHERE parenttabid=@blockid AND tabid=(SELECT tabid FROM ld_tab WHERE `name`='Customreport');

		UPDATE ld_parenttab SET visible=1 WHERE parenttab_label='Finacial';

END IF;

END ||
delimiter;

CALL ldcrm_reset_appparenttab();
delimiter;

DROP PROCEDURE IF EXISTS `ldcrm_reset_appparenttab`;
delimiter;
-- 2017-11-22

select tabid into @tabid from ld_tab where `name` = 'Users'; 
select fieldid into @fieldid from ld_field where tabid = @tabid and columnname = 'viewothers'; 
update ld_tranlabel set fieldlabel = '查看其他用户单据' where languagetype = 'zh' and trantable = 'ld_field' and tabid = @tabid and Relateid = @fieldid; 
update ld_tranlabel set fieldlabel = 'Allow to view other users data' where languagetype = 'en' and trantable = 'ld_field' and tabid = @tabid and Relateid = @fieldid; 
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) 
select 'zh','viewothers','允许查看其他用户的单据(优先于角色权限)','fixedstr' from dual 
where not exists(select 1 from ld_desk where languagetype = 'zh' and labelbol = 'viewothers' and labeltype = 'fixedstr'); 
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) 
select 'en','viewothers','Allow to view other users data','fixedstr' from dual 
where not exists(select 1 from ld_desk where languagetype = 'en' and labelbol = 'viewothers' and labeltype = 'fixedstr'); 
delimiter; 

select tabid into @tabid from ld_tab where `name` = 'Users'; 
select fieldid into @fieldid from ld_field where tabid = @tabid and columnname = 'editothers'; 
update ld_tranlabel set fieldlabel = '编辑其他用户单据' where languagetype = 'zh' and trantable = 'ld_field' and tabid = @tabid and Relateid = @fieldid; 
update ld_tranlabel set fieldlabel = 'Allow to edit other users data' where languagetype = 'en' and trantable = 'ld_field' and tabid = @tabid and Relateid = @fieldid; 
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) 
select 'zh','editothers','允许编辑其他用户的单据(优先于角色权限)','fixedstr' from dual 
where not exists(select 1 from ld_desk where languagetype = 'zh' and labelbol = 'editothers' and labeltype = 'fixedstr'); 
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) 
select 'en','editothers','Allow to edit other users data','fixedstr' from dual 
where not exists(select 1 from ld_desk where languagetype = 'en' and labelbol = 'editothers' and labeltype = 'fixedstr'); 
delimiter; 

select tabid into @tabid from ld_tab where `name` = 'Users'; 
select fieldid into @fieldid from ld_field where tabid = @tabid and columnname = 'delothers'; 
update ld_tranlabel set fieldlabel = '删除其他用户单据' where languagetype = 'zh' and trantable = 'ld_field' and tabid = @tabid and Relateid = @fieldid; 
update ld_tranlabel set fieldlabel = 'Allow to delete other users data' where languagetype = 'en' and trantable = 'ld_field' and tabid = @tabid and Relateid = @fieldid; 
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) 
select 'zh','delothers','允许删除其他用户的单据(优先于角色权限)','fixedstr' from dual 
where not exists(select 1 from ld_desk where languagetype = 'zh' and labelbol = 'delothers' and labeltype = 'fixedstr'); 
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) 
select 'en','delothers','Allow to delete other users data','fixedstr' from dual 
where not exists(select 1 from ld_desk where languagetype = 'en' and labelbol = 'delothers' and labeltype = 'fixedstr'); 
delimiter; 


select tabid into @tabid from ld_tab where `name` = 'Users'; 
select fieldid into @fieldid from ld_field where tabid = @tabid and columnname = 'viewselfbills'; 
update ld_tranlabel set fieldlabel = '查询自己创建单据' where languagetype = 'zh' and trantable = 'ld_field' and tabid = @tabid and Relateid = @fieldid; 
update ld_tranlabel set fieldlabel = 'view me created data' where languagetype = 'en' and trantable = 'ld_field' and tabid = @tabid and Relateid = @fieldid; 
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) 
select 'zh','viewselfbills','允许查询自已创建的单据(负责人不是自已的单据)','fixedstr' from dual 
where not exists(select 1 from ld_desk where languagetype = 'zh' and labelbol = 'viewselfbills' and labeltype = 'fixedstr'); 
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) 
select 'en','viewselfbills','Allows to query the data which created by myself(smownerid are not responsible for their own documents)','fixedstr' from dual 
where not exists(select 1 from ld_desk where languagetype = 'en' and labelbol = 'viewselfbills' and labeltype = 'fixedstr'); 
delimiter; 


select tabid into @tabid from ld_tab where `name` = 'Users'; 
select fieldid into @fieldid from ld_field where tabid = @tabid and columnname = 'edit_other_mobile'; 
update ld_tranlabel set fieldlabel = '编辑其他用户单据手机' where languagetype = 'zh' and trantable = 'ld_field' and tabid = @tabid and Relateid = @fieldid; 
update ld_tranlabel set fieldlabel = 'edit other users mobile number' where languagetype = 'en' and trantable = 'ld_field' and tabid = @tabid and Relateid = @fieldid; 
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) 
select 'zh','edit_other_mobile','允许编辑其他用户单据的手机号码字段','fixedstr' from dual 
where not exists(select 1 from ld_desk where languagetype = 'zh' and labelbol = 'edit_other_mobile' and labeltype = 'fixedstr'); 
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) 
select 'en','edit_other_mobile','Allow to edit other users mobile number','fixedstr' from dual 
where not exists(select 1 from ld_desk where languagetype = 'en' and labelbol = 'edit_other_mobile' and labeltype = 'fixedstr'); 
delimiter; 


select tabid into @tabid from ld_tab where `name` = 'Users'; 
select fieldid into @fieldid from ld_field where tabid = @tabid and columnname = 'edit_me_mobile'; 
update ld_tranlabel set fieldlabel = '编辑自己单据手机' where languagetype = 'zh' and trantable = 'ld_field' and tabid = @tabid and Relateid = @fieldid; 
update ld_tranlabel set fieldlabel = 'edit my bills mobile number' where languagetype = 'en' and trantable = 'ld_field' and tabid = @tabid and Relateid = @fieldid; 
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) 
select 'zh','edit_me_mobile','允许编辑自己单据的手机号码字段','fixedstr' from dual 
where not exists(select 1 from ld_desk where languagetype = 'zh' and labelbol = 'edit_me_mobile' and labeltype = 'fixedstr'); 
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) 
select 'en','edit_me_mobile','Allow to edit my bills mobile number','fixedstr' from dual 
where not exists(select 1 from ld_desk where languagetype = 'en' and labelbol = 'edit_me_mobile' and labeltype = 'fixedstr'); 
delimiter; 

select tabid into @tabid from ld_tab where `name` = 'Users'; 
select fieldid into @fieldid from ld_field where tabid = @tabid and columnname = 'is_mobile_style'; 
update ld_tranlabel set fieldlabel = '手机显示样式控制' where languagetype = 'zh' and trantable = 'ld_field' and tabid = @tabid and Relateid = @fieldid; 
update ld_tranlabel set fieldlabel = 'Phone num style according' where languagetype = 'en' and trantable = 'ld_field' and tabid = @tabid and Relateid = @fieldid; 
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) 
select 'zh','is_mobile_style','手机号码显示样式根据系统参数控制','fixedstr' from dual 
where not exists(select 1 from ld_desk where languagetype = 'zh' and labelbol = 'is_mobile_style' and labeltype = 'fixedstr'); 
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) 
select 'en','is_mobile_style','Phone num style according to parameters','fixedstr' from dual 
where not exists(select 1 from ld_desk where languagetype = 'en' and labelbol = 'is_mobile_style' and labeltype = 'fixedstr'); 
delimiter; 

select tabid into @tabid from ld_tab where `name` = 'Users'; 
select fieldid into @fieldid from ld_field where tabid = @tabid and columnname = 'select_servicedetail'; 
update ld_tranlabel set fieldlabel = '显示服务信息' where languagetype = 'zh' and trantable = 'ld_field' and tabid = @tabid and Relateid = @fieldid; 
update ld_tranlabel set fieldlabel = 'view the information service' where languagetype = 'en' and trantable = 'ld_field' and tabid = @tabid and Relateid = @fieldid; 
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) 
select 'zh','select_servicedetail','{$Accounts.Accounts}和{$HelpDesk.HelpDesk}界面是否显示服务信息','fixedstr' from dual 
where not exists(select 1 from ld_desk where languagetype = 'zh' and labelbol = 'select_servicedetail' and labeltype = 'fixedstr'); 
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) 
select 'en','select_servicedetail','{$Accounts.Accounts} and {$HelpDesk.HelpDesk} view whether to display the information service','fixedstr' from dual 
where not exists(select 1 from ld_desk where languagetype = 'en' and labelbol = 'select_servicedetail' and labeltype = 'fixedstr'); 
delimiter; 


select tabid into @tabid from ld_tab where `name` = 'Users'; 
select fieldid into @fieldid from ld_field where tabid = @tabid and columnname = 'select_due_date'; 
update ld_tranlabel set fieldlabel = '显示具体服务到期日' where languagetype = 'zh' and trantable = 'ld_field' and tabid = @tabid and Relateid = @fieldid; 
update ld_tranlabel set fieldlabel = 'view the real service enddate' where languagetype = 'en' and trantable = 'ld_field' and tabid = @tabid and Relateid = @fieldid; 
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) 
select 'zh','select_due_date','{$Accounts.Accounts}和{$HelpDesk.HelpDesk}界面显示具体的服务到期日','fixedstr' from dual 
where not exists(select 1 from ld_desk where languagetype = 'zh' and labelbol = 'select_due_date' and labeltype = 'fixedstr'); 
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) 
select 'en','select_due_date','{$Accounts.Accounts} and {$HelpDesk.HelpDesk} view the real service enddate','fixedstr' from dual 
where not exists(select 1 from ld_desk where languagetype = 'en' and labelbol = 'select_due_date' and labeltype = 'fixedstr'); 
delimiter; 

select tabid into @tabid from ld_tab where `name` = 'Users'; 
select fieldid into @fieldid from ld_field where tabid = @tabid and columnname = 'accountallview'; 
update ld_tranlabel set fieldlabel = '相关信息查询所有数据' where languagetype = 'zh' and trantable = 'ld_field' and tabid = @tabid and Relateid = @fieldid; 
update ld_tranlabel set fieldlabel = 'view the relevant information list' where languagetype = 'en' and trantable = 'ld_field' and tabid = @tabid and Relateid = @fieldid; 
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) 
select 'zh','accountallview','相关信息列表是否允许查询所有数据','fixedstr' from dual 
where not exists(select 1 from ld_desk where languagetype = 'zh' and labelbol = 'accountallview' and labeltype = 'fixedstr'); 
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) 
select 'en','accountallview','Allows you to view the relevant information list data permissions','fixedstr' from dual 
where not exists(select 1 from ld_desk where languagetype = 'en' and labelbol = 'accountallview' and labeltype = 'fixedstr'); 
delimiter; 

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','list','列表','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype = 'zh' and labelbol = 'list' and labeltype = 'fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','list',' list','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype = 'en' and labelbol = 'list' and labeltype = 'fixedstr');
delimiter;

DELETE FROM ld_appparenttab WHERE parenttab_label IN ('Office','BaseSetting') AND systemdefault='yes';
UPDATE ld_tranlabel SET fieldlabel='工作汇报' WHERE Relateid=-1 AND trantable='ld_tab' AND languagetype='zh';
-- 2017-11-23

CREATE TABLE IF NOT EXISTS `ld_fieldwxmaininfo`(
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `tabid` int(11) NOT NULL,
  `fieldname` varchar(255) NOT NULL,
  `sequence` int(4) DEFAULT NULL,
  `displaytype` varchar(100) DEFAULT 'normal',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=utf8;
delimiter;

SET @tabid=6;
SET @i=0;
INSERT INTO ld_fieldwxmaininfo(tabid,fieldname,sequence,displaytype)
SELECT @tabid,'bill_street',(@i:=@i+1),'normal' FROM DUAL
WHERE NOT EXISTS(SELECT 1 FROM ld_fieldwxmaininfo WHERE tabid=@tabid AND fieldname='bill_street');

INSERT INTO ld_fieldwxmaininfo(tabid,fieldname,sequence,displaytype)
SELECT @tabid,'assigned_user_id',(@i:=@i+1),'normal' FROM DUAL
WHERE NOT EXISTS(SELECT 1 FROM ld_fieldwxmaininfo WHERE tabid=@tabid AND fieldname='assigned_user_id');

INSERT INTO ld_fieldwxmaininfo(tabid,fieldname,sequence,displaytype)
SELECT @tabid,'rating',(@i:=@i+1),'normal' FROM DUAL
WHERE NOT EXISTS(SELECT 1 FROM ld_fieldwxmaininfo WHERE tabid=@tabid AND fieldname='rating');


SET @tabid=4;
SET @i=0;
INSERT INTO ld_fieldwxmaininfo(tabid,fieldname,sequence,displaytype)
SELECT @tabid,'mobile',(@i:=@i+1),'normal' FROM DUAL
WHERE NOT EXISTS(SELECT 1 FROM ld_fieldwxmaininfo WHERE tabid=@tabid AND fieldname='mobile');

INSERT INTO ld_fieldwxmaininfo(tabid,fieldname,sequence,displaytype)
SELECT @tabid,'email',(@i:=@i+1),'normal' FROM DUAL
WHERE NOT EXISTS(SELECT 1 FROM ld_fieldwxmaininfo WHERE tabid=@tabid AND fieldname='email');

INSERT INTO ld_fieldwxmaininfo(tabid,fieldname,sequence,displaytype)
SELECT @tabid,'account_id',(@i:=@i+1),'link' FROM DUAL
WHERE NOT EXISTS(SELECT 1 FROM ld_fieldwxmaininfo WHERE tabid=@tabid AND fieldname='account_id');


SET @tabid=(SELECT tabid FROM ld_tab WHERE `name`='ContactRecords');
SET @i=0;
INSERT INTO ld_fieldwxmaininfo(tabid,fieldname,sequence,displaytype)
SELECT @tabid,'contactdate',(@i:=@i+1),'normal' FROM DUAL
WHERE NOT EXISTS(SELECT 1 FROM ld_fieldwxmaininfo WHERE tabid=@tabid AND fieldname='contactdate');

INSERT INTO ld_fieldwxmaininfo(tabid,fieldname,sequence,displaytype)
SELECT @tabid,'nextcontactdate',(@i:=@i+1),'normal' FROM DUAL
WHERE NOT EXISTS(SELECT 1 FROM ld_fieldwxmaininfo WHERE tabid=@tabid AND fieldname='nextcontactdate');

INSERT INTO ld_fieldwxmaininfo(tabid,fieldname,sequence,displaytype)
SELECT @tabid,'account_id',(@i:=@i+1),'link' FROM DUAL
WHERE NOT EXISTS(SELECT 1 FROM ld_fieldwxmaininfo WHERE tabid=@tabid AND fieldname='account_id');



SET @tabid=(SELECT tabid FROM ld_tab WHERE `name`='Potentials');
SET @i=0;
INSERT INTO ld_fieldwxmaininfo(tabid,fieldname,sequence,displaytype)
SELECT @tabid,'sales_stage',(@i:=@i+1),'normal' FROM DUAL
WHERE NOT EXISTS(SELECT 1 FROM ld_fieldwxmaininfo WHERE tabid=@tabid AND fieldname='sales_stage');

INSERT INTO ld_fieldwxmaininfo(tabid,fieldname,sequence,displaytype)
SELECT @tabid,'closingdate',(@i:=@i+1),'normal' FROM DUAL
WHERE NOT EXISTS(SELECT 1 FROM ld_fieldwxmaininfo WHERE tabid=@tabid AND fieldname='closingdate');

INSERT INTO ld_fieldwxmaininfo(tabid,fieldname,sequence,displaytype)
SELECT @tabid,'amount',(@i:=@i+1),'normal' FROM DUAL
WHERE NOT EXISTS(SELECT 1 FROM ld_fieldwxmaininfo WHERE tabid=@tabid AND fieldname='amount');

INSERT INTO ld_fieldwxmaininfo(tabid,fieldname,sequence,displaytype)
SELECT @tabid,'account_id',(@i:=@i+1),'link' FROM DUAL
WHERE NOT EXISTS(SELECT 1 FROM ld_fieldwxmaininfo WHERE tabid=@tabid AND fieldname='account_id');


SET @tabid=(SELECT tabid FROM ld_tab WHERE `name`='Campaigns');
SET @i=0;
INSERT INTO ld_fieldwxmaininfo(tabid,fieldname,sequence,displaytype)
SELECT @tabid,'campaignstatus',(@i:=@i+1),'normal' FROM DUAL
WHERE NOT EXISTS(SELECT 1 FROM ld_fieldwxmaininfo WHERE tabid=@tabid AND fieldname='campaignstatus');

INSERT INTO ld_fieldwxmaininfo(tabid,fieldname,sequence,displaytype)
SELECT @tabid,'startdate',(@i:=@i+1),'normal' FROM DUAL
WHERE NOT EXISTS(SELECT 1 FROM ld_fieldwxmaininfo WHERE tabid=@tabid AND fieldname='startdate');

INSERT INTO ld_fieldwxmaininfo(tabid,fieldname,sequence,displaytype)
SELECT @tabid,'closingdate',(@i:=@i+1),'normal' FROM DUAL
WHERE NOT EXISTS(SELECT 1 FROM ld_fieldwxmaininfo WHERE tabid=@tabid AND fieldname='closingdate');

INSERT INTO ld_fieldwxmaininfo(tabid,fieldname,sequence,displaytype)
SELECT @tabid,'assigned_user_id',(@i:=@i+1),'normal' FROM DUAL
WHERE NOT EXISTS(SELECT 1 FROM ld_fieldwxmaininfo WHERE tabid=@tabid AND fieldname='assigned_user_id');


SET @tabid=(SELECT tabid FROM ld_tab WHERE `name`='Products');
SET @i=0;
INSERT INTO ld_fieldwxmaininfo(tabid,fieldname,sequence,displaytype)
SELECT @tabid,'product_no',(@i:=@i+1),'normal' FROM DUAL
WHERE NOT EXISTS(SELECT 1 FROM ld_fieldwxmaininfo WHERE tabid=@tabid AND fieldname='product_no');

INSERT INTO ld_fieldwxmaininfo(tabid,fieldname,sequence,displaytype)
SELECT @tabid,'productsheet',(@i:=@i+1),'normal' FROM DUAL
WHERE NOT EXISTS(SELECT 1 FROM ld_fieldwxmaininfo WHERE tabid=@tabid AND fieldname='productsheet');

INSERT INTO ld_fieldwxmaininfo(tabid,fieldname,sequence,displaytype)
SELECT @tabid,'qtyinstock',(@i:=@i+1),'normal' FROM DUAL
WHERE NOT EXISTS(SELECT 1 FROM ld_fieldwxmaininfo WHERE tabid=@tabid AND fieldname='qtyinstock');


SET @tabid=(SELECT tabid FROM ld_tab WHERE `name`='Quotes');
SET @i=0;
INSERT INTO ld_fieldwxmaininfo(tabid,fieldname,sequence,displaytype)
SELECT @tabid,'hdnGrandTotal',(@i:=@i+1),'normal' FROM DUAL
WHERE NOT EXISTS(SELECT 1 FROM ld_fieldwxmaininfo WHERE tabid=@tabid AND fieldname='hdnGrandTotal');

INSERT INTO ld_fieldwxmaininfo(tabid,fieldname,sequence,displaytype)
SELECT @tabid,'account_id',(@i:=@i+1),'link' FROM DUAL
WHERE NOT EXISTS(SELECT 1 FROM ld_fieldwxmaininfo WHERE tabid=@tabid AND fieldname='account_id');



SET @tabid=22;
SET @i=0;
INSERT INTO ld_fieldwxmaininfo(tabid,fieldname,sequence,displaytype)
SELECT @tabid,'signed_data',(@i:=@i+1),'normal' FROM DUAL
WHERE NOT EXISTS(SELECT 1 FROM ld_fieldwxmaininfo WHERE tabid=@tabid AND fieldname='signed_data');

INSERT INTO ld_fieldwxmaininfo(tabid,fieldname,sequence,displaytype)
SELECT @tabid,'hdnGrandTotal',(@i:=@i+1),'normal' FROM DUAL
WHERE NOT EXISTS(SELECT 1 FROM ld_fieldwxmaininfo WHERE tabid=@tabid AND fieldname='hdnGrandTotal');

INSERT INTO ld_fieldwxmaininfo(tabid,fieldname,sequence,displaytype)
SELECT @tabid,'receivable_balance',(@i:=@i+1),'normal' FROM DUAL
WHERE NOT EXISTS(SELECT 1 FROM ld_fieldwxmaininfo WHERE tabid=@tabid AND fieldname='receivable_balance');

INSERT INTO ld_fieldwxmaininfo(tabid,fieldname,sequence,displaytype)
SELECT @tabid,'nothave_invoicetotal',(@i:=@i+1),'normal' FROM DUAL
WHERE NOT EXISTS(SELECT 1 FROM ld_fieldwxmaininfo WHERE tabid=@tabid AND fieldname='nothave_invoicetotal');

INSERT INTO ld_fieldwxmaininfo(tabid,fieldname,sequence,displaytype)
SELECT @tabid,'account_id',(@i:=@i+1),'link' FROM DUAL
WHERE NOT EXISTS(SELECT 1 FROM ld_fieldwxmaininfo WHERE tabid=@tabid AND fieldname='account_id');


SET @tabid=(SELECT tabid FROM ld_tab WHERE `name`='ServiceContracts');
SET @i=0;
INSERT INTO ld_fieldwxmaininfo(tabid,fieldname,sequence,displaytype)
SELECT @tabid,'due_date',(@i:=@i+1),'normal' FROM DUAL
WHERE NOT EXISTS(SELECT 1 FROM ld_fieldwxmaininfo WHERE tabid=@tabid AND fieldname='due_date');

INSERT INTO ld_fieldwxmaininfo(tabid,fieldname,sequence,displaytype)
SELECT @tabid,'hdnGrandTotal',(@i:=@i+1),'normal' FROM DUAL
WHERE NOT EXISTS(SELECT 1 FROM ld_fieldwxmaininfo WHERE tabid=@tabid AND fieldname='hdnGrandTotal');

INSERT INTO ld_fieldwxmaininfo(tabid,fieldname,sequence,displaytype)
SELECT @tabid,'receivable_balance',(@i:=@i+1),'normal' FROM DUAL
WHERE NOT EXISTS(SELECT 1 FROM ld_fieldwxmaininfo WHERE tabid=@tabid AND fieldname='receivable_balance');

INSERT INTO ld_fieldwxmaininfo(tabid,fieldname,sequence,displaytype)
SELECT @tabid,'nothave_invoicetotal',(@i:=@i+1),'normal' FROM DUAL
WHERE NOT EXISTS(SELECT 1 FROM ld_fieldwxmaininfo WHERE tabid=@tabid AND fieldname='nothave_invoicetotal');

INSERT INTO ld_fieldwxmaininfo(tabid,fieldname,sequence,displaytype)
SELECT @tabid,'account_id',(@i:=@i+1),'link' FROM DUAL
WHERE NOT EXISTS(SELECT 1 FROM ld_fieldwxmaininfo WHERE tabid=@tabid AND fieldname='account_id');


SET @tabid=(SELECT tabid FROM ld_tab WHERE `name`='ServiceCharge');
SET @i=0;
INSERT INTO ld_fieldwxmaininfo(tabid,fieldname,sequence,displaytype)
SELECT @tabid,'bill_street',(@i:=@i+1),'normal' FROM DUAL
WHERE NOT EXISTS(SELECT 1 FROM ld_fieldwxmaininfo WHERE tabid=@tabid AND fieldname='bill_street');

INSERT INTO ld_fieldwxmaininfo(tabid,fieldname,sequence,displaytype)
SELECT @tabid,'assigned_user_id',(@i:=@i+1),'normal' FROM DUAL
WHERE NOT EXISTS(SELECT 1 FROM ld_fieldwxmaininfo WHERE tabid=@tabid AND fieldname='assigned_user_id');

INSERT INTO ld_fieldwxmaininfo(tabid,fieldname,sequence,displaytype)
SELECT @tabid,'rating',(@i:=@i+1),'normal' FROM DUAL
WHERE NOT EXISTS(SELECT 1 FROM ld_fieldwxmaininfo WHERE tabid=@tabid AND fieldname='rating');


SET @tabid=(SELECT tabid FROM ld_tab WHERE `name`='HelpDesk');
SET @i=0;
INSERT INTO ld_fieldwxmaininfo(tabid,fieldname,sequence,displaytype)
SELECT @tabid,'ticketpriorities',(@i:=@i+1),'normal' FROM DUAL
WHERE NOT EXISTS(SELECT 1 FROM ld_fieldwxmaininfo WHERE tabid=@tabid AND fieldname='ticketpriorities');

INSERT INTO ld_fieldwxmaininfo(tabid,fieldname,sequence,displaytype)
SELECT @tabid,'realtime',(@i:=@i+1),'normal' FROM DUAL
WHERE NOT EXISTS(SELECT 1 FROM ld_fieldwxmaininfo WHERE tabid=@tabid AND fieldname='realtime');

INSERT INTO ld_fieldwxmaininfo(tabid,fieldname,sequence,displaytype)
SELECT @tabid,'assigned_user_id',(@i:=@i+1),'normal' FROM DUAL
WHERE NOT EXISTS(SELECT 1 FROM ld_fieldwxmaininfo WHERE tabid=@tabid AND fieldname='assigned_user_id');

INSERT INTO ld_fieldwxmaininfo(tabid,fieldname,sequence,displaytype)
SELECT @tabid,'account_id',(@i:=@i+1),'link' FROM DUAL
WHERE NOT EXISTS(SELECT 1 FROM ld_fieldwxmaininfo WHERE tabid=@tabid AND fieldname='account_id');


SET @tabid=(SELECT tabid FROM ld_tab WHERE `name`='Faq');
SET @i=0;
INSERT INTO ld_fieldwxmaininfo(tabid,fieldname,sequence,displaytype)
SELECT @tabid,'faqcategories',(@i:=@i+1),'normal' FROM DUAL
WHERE NOT EXISTS(SELECT 1 FROM ld_fieldwxmaininfo WHERE tabid=@tabid AND fieldname='faqcategories');

INSERT INTO ld_fieldwxmaininfo(tabid,fieldname,sequence,displaytype)
SELECT @tabid,'faqtype',(@i:=@i+1),'normal' FROM DUAL
WHERE NOT EXISTS(SELECT 1 FROM ld_fieldwxmaininfo WHERE tabid=@tabid AND fieldname='faqtype');

INSERT INTO ld_fieldwxmaininfo(tabid,fieldname,sequence,displaytype)
SELECT @tabid,'question',(@i:=@i+1),'normal' FROM DUAL
WHERE NOT EXISTS(SELECT 1 FROM ld_fieldwxmaininfo WHERE tabid=@tabid AND fieldname='question');


SET @tabid=(SELECT tabid FROM ld_tab WHERE `name`='ServiceReturn');
SET @i=0;
INSERT INTO ld_fieldwxmaininfo(tabid,fieldname,sequence,displaytype)
SELECT @tabid,'ticket_servicer',(@i:=@i+1),'normal' FROM DUAL
WHERE NOT EXISTS(SELECT 1 FROM ld_fieldwxmaininfo WHERE tabid=@tabid AND fieldname='ticket_servicer');

INSERT INTO ld_fieldwxmaininfo(tabid,fieldname,sequence,displaytype)
SELECT @tabid,'assigned_user_id',(@i:=@i+1),'normal' FROM DUAL
WHERE NOT EXISTS(SELECT 1 FROM ld_fieldwxmaininfo WHERE tabid=@tabid AND fieldname='assigned_user_id');

INSERT INTO ld_fieldwxmaininfo(tabid,fieldname,sequence,displaytype)
SELECT @tabid,'account_id',(@i:=@i+1),'link' FROM DUAL
WHERE NOT EXISTS(SELECT 1 FROM ld_fieldwxmaininfo WHERE tabid=@tabid AND fieldname='account_id');



SET @tabid=(SELECT tabid FROM ld_tab WHERE `name`='Project');
SET @i=0;
INSERT INTO ld_fieldwxmaininfo(tabid,fieldname,sequence,displaytype)
SELECT @tabid,'assigned_user_id',(@i:=@i+1),'normal' FROM DUAL
WHERE NOT EXISTS(SELECT 1 FROM ld_fieldwxmaininfo WHERE tabid=@tabid AND fieldname='assigned_user_id');

INSERT INTO ld_fieldwxmaininfo(tabid,fieldname,sequence,displaytype)
SELECT @tabid,'projectstatus',(@i:=@i+1),'normal' FROM DUAL
WHERE NOT EXISTS(SELECT 1 FROM ld_fieldwxmaininfo WHERE tabid=@tabid AND fieldname='projectstatus');

INSERT INTO ld_fieldwxmaininfo(tabid,fieldname,sequence,displaytype)
SELECT @tabid,'account_id',(@i:=@i+1),'link' FROM DUAL
WHERE NOT EXISTS(SELECT 1 FROM ld_fieldwxmaininfo WHERE tabid=@tabid AND fieldname='account_id');


SET @tabid=(SELECT tabid FROM ld_tab WHERE `name`='ProjectTask');
SET @i=0;
INSERT INTO ld_fieldwxmaininfo(tabid,fieldname,sequence,displaytype)
SELECT @tabid,'account_id',(@i:=@i+1),'normal' FROM DUAL
WHERE NOT EXISTS(SELECT 1 FROM ld_fieldwxmaininfo WHERE tabid=@tabid AND fieldname='account_id');

INSERT INTO ld_fieldwxmaininfo(tabid,fieldname,sequence,displaytype)
SELECT @tabid,'assigned_user_id',(@i:=@i+1),'normal' FROM DUAL
WHERE NOT EXISTS(SELECT 1 FROM ld_fieldwxmaininfo WHERE tabid=@tabid AND fieldname='assigned_user_id');

INSERT INTO ld_fieldwxmaininfo(tabid,fieldname,sequence,displaytype)
SELECT @tabid,'projecttaskstatus',(@i:=@i+1),'normal' FROM DUAL
WHERE NOT EXISTS(SELECT 1 FROM ld_fieldwxmaininfo WHERE tabid=@tabid AND fieldname='projecttaskstatus');

INSERT INTO ld_fieldwxmaininfo(tabid,fieldname,sequence,displaytype)
SELECT @tabid,'projectid',(@i:=@i+1),'link' FROM DUAL
WHERE NOT EXISTS(SELECT 1 FROM ld_fieldwxmaininfo WHERE tabid=@tabid AND fieldname='projectid');


SET @tabid=(SELECT tabid FROM ld_tab WHERE `name`='ProjectProgress');
SET @i=0;
INSERT INTO ld_fieldwxmaininfo(tabid,fieldname,sequence,displaytype)
SELECT @tabid,'account_id',(@i:=@i+1),'normal' FROM DUAL
WHERE NOT EXISTS(SELECT 1 FROM ld_fieldwxmaininfo WHERE tabid=@tabid AND fieldname='account_id');

INSERT INTO ld_fieldwxmaininfo(tabid,fieldname,sequence,displaytype)
SELECT @tabid,'projecttaskid',(@i:=@i+1),'normal' FROM DUAL
WHERE NOT EXISTS(SELECT 1 FROM ld_fieldwxmaininfo WHERE tabid=@tabid AND fieldname='projecttaskid');

INSERT INTO ld_fieldwxmaininfo(tabid,fieldname,sequence,displaytype)
SELECT @tabid,'assigned_user_id',(@i:=@i+1),'normal' FROM DUAL
WHERE NOT EXISTS(SELECT 1 FROM ld_fieldwxmaininfo WHERE tabid=@tabid AND fieldname='assigned_user_id');

INSERT INTO ld_fieldwxmaininfo(tabid,fieldname,sequence,displaytype)
SELECT @tabid,'projectid',(@i:=@i+1),'link' FROM DUAL
WHERE NOT EXISTS(SELECT 1 FROM ld_fieldwxmaininfo WHERE tabid=@tabid AND fieldname='projectid');


SET @tabid=(SELECT tabid FROM ld_tab WHERE `name`='TimeSheet');
SET @i=0;
INSERT INTO ld_fieldwxmaininfo(tabid,fieldname,sequence,displaytype)
SELECT @tabid,'assigned_user_id',(@i:=@i+1),'normal' FROM DUAL
WHERE NOT EXISTS(SELECT 1 FROM ld_fieldwxmaininfo WHERE tabid=@tabid AND fieldname='assigned_user_id');

INSERT INTO ld_fieldwxmaininfo(tabid,fieldname,sequence,displaytype)
SELECT @tabid,'total',(@i:=@i+1),'normal' FROM DUAL
WHERE NOT EXISTS(SELECT 1 FROM ld_fieldwxmaininfo WHERE tabid=@tabid AND fieldname='total');


SET @tabid=(SELECT tabid FROM ld_tab WHERE `name`='ProjectMilestone');
SET @i=0;
INSERT INTO ld_fieldwxmaininfo(tabid,fieldname,sequence,displaytype)
SELECT @tabid,'projectmilestonedate',(@i:=@i+1),'normal' FROM DUAL
WHERE NOT EXISTS(SELECT 1 FROM ld_fieldwxmaininfo WHERE tabid=@tabid AND fieldname='projectmilestonedate');

INSERT INTO ld_fieldwxmaininfo(tabid,fieldname,sequence,displaytype)
SELECT @tabid,'assigned_user_id',(@i:=@i+1),'normal' FROM DUAL
WHERE NOT EXISTS(SELECT 1 FROM ld_fieldwxmaininfo WHERE tabid=@tabid AND fieldname='assigned_user_id');

INSERT INTO ld_fieldwxmaininfo(tabid,fieldname,sequence,displaytype)
SELECT @tabid,'projectid',(@i:=@i+1),'link' FROM DUAL
WHERE NOT EXISTS(SELECT 1 FROM ld_fieldwxmaininfo WHERE tabid=@tabid AND fieldname='projectid');


SET @tabid=(SELECT tabid FROM ld_tab WHERE `name`='Rate');
SET @i=0;
INSERT INTO ld_fieldwxmaininfo(tabid,fieldname,sequence,displaytype)
SELECT @tabid,'rate',(@i:=@i+1),'normal' FROM DUAL
WHERE NOT EXISTS(SELECT 1 FROM ld_fieldwxmaininfo WHERE tabid=@tabid AND fieldname='rate');

SET @i=0;
INSERT INTO ld_fieldwxmaininfo(tabid,fieldname,sequence,displaytype)
SELECT @tabid,'startdate',(@i:=@i+1),'normal' FROM DUAL
WHERE NOT EXISTS(SELECT 1 FROM ld_fieldwxmaininfo WHERE tabid=@tabid AND fieldname='startdate');

SET @i=0;
INSERT INTO ld_fieldwxmaininfo(tabid,fieldname,sequence,displaytype)
SELECT @tabid,'enddate',(@i:=@i+1),'normal' FROM DUAL
WHERE NOT EXISTS(SELECT 1 FROM ld_fieldwxmaininfo WHERE tabid=@tabid AND fieldname='enddate');

INSERT INTO ld_fieldwxmaininfo(tabid,fieldname,sequence,displaytype)
SELECT @tabid,'assigned_user_id',(@i:=@i+1),'normal' FROM DUAL
WHERE NOT EXISTS(SELECT 1 FROM ld_fieldwxmaininfo WHERE tabid=@tabid AND fieldname='assigned_user_id');


SET @tabid=(SELECT tabid FROM ld_tab WHERE `name`='ProjectProgress');
SET @i=0;
INSERT INTO ld_fieldwxmaininfo(tabid,fieldname,sequence,displaytype)
SELECT @tabid,'account_id',(@i:=@i+1),'normal' FROM DUAL
WHERE NOT EXISTS(SELECT 1 FROM ld_fieldwxmaininfo WHERE tabid=@tabid AND fieldname='account_id');

INSERT INTO ld_fieldwxmaininfo(tabid,fieldname,sequence,displaytype)
SELECT @tabid,'projecttaskid',(@i:=@i+1),'normal' FROM DUAL
WHERE NOT EXISTS(SELECT 1 FROM ld_fieldwxmaininfo WHERE tabid=@tabid AND fieldname='projecttaskid');

INSERT INTO ld_fieldwxmaininfo(tabid,fieldname,sequence,displaytype)
SELECT @tabid,'assigned_user_id',(@i:=@i+1),'normal' FROM DUAL
WHERE NOT EXISTS(SELECT 1 FROM ld_fieldwxmaininfo WHERE tabid=@tabid AND fieldname='assigned_user_id');

INSERT INTO ld_fieldwxmaininfo(tabid,fieldname,sequence,displaytype)
SELECT @tabid,'projectid',(@i:=@i+1),'link' FROM DUAL
WHERE NOT EXISTS(SELECT 1 FROM ld_fieldwxmaininfo WHERE tabid=@tabid AND fieldname='projectid');


SET @tabid=(SELECT tabid FROM ld_tab WHERE `name`='TimeSheet');
SET @i=0;
INSERT INTO ld_fieldwxmaininfo(tabid,fieldname,sequence,displaytype)
SELECT @tabid,'assigned_user_id',(@i:=@i+1),'normal' FROM DUAL
WHERE NOT EXISTS(SELECT 1 FROM ld_fieldwxmaininfo WHERE tabid=@tabid AND fieldname='assigned_user_id');

INSERT INTO ld_fieldwxmaininfo(tabid,fieldname,sequence,displaytype)
SELECT @tabid,'total',(@i:=@i+1),'normal' FROM DUAL
WHERE NOT EXISTS(SELECT 1 FROM ld_fieldwxmaininfo WHERE tabid=@tabid AND fieldname='total');


SET @tabid=(SELECT tabid FROM ld_tab WHERE `name`='ProjectMilestone');
SET @i=0;
INSERT INTO ld_fieldwxmaininfo(tabid,fieldname,sequence,displaytype)
SELECT @tabid,'projectmilestonedate',(@i:=@i+1),'normal' FROM DUAL
WHERE NOT EXISTS(SELECT 1 FROM ld_fieldwxmaininfo WHERE tabid=@tabid AND fieldname='projectmilestonedate');

INSERT INTO ld_fieldwxmaininfo(tabid,fieldname,sequence,displaytype)
SELECT @tabid,'assigned_user_id',(@i:=@i+1),'normal' FROM DUAL
WHERE NOT EXISTS(SELECT 1 FROM ld_fieldwxmaininfo WHERE tabid=@tabid AND fieldname='assigned_user_id');

INSERT INTO ld_fieldwxmaininfo(tabid,fieldname,sequence,displaytype)
SELECT @tabid,'projectid',(@i:=@i+1),'link' FROM DUAL
WHERE NOT EXISTS(SELECT 1 FROM ld_fieldwxmaininfo WHERE tabid=@tabid AND fieldname='projectid');


SET @tabid=(SELECT tabid FROM ld_tab WHERE `name`='Rate');
SET @i=0;
INSERT INTO ld_fieldwxmaininfo(tabid,fieldname,sequence,displaytype)
SELECT @tabid,'rate',(@i:=@i+1),'normal' FROM DUAL
WHERE NOT EXISTS(SELECT 1 FROM ld_fieldwxmaininfo WHERE tabid=@tabid AND fieldname='rate');

SET @i=0;
INSERT INTO ld_fieldwxmaininfo(tabid,fieldname,sequence,displaytype)
SELECT @tabid,'startdate',(@i:=@i+1),'normal' FROM DUAL
WHERE NOT EXISTS(SELECT 1 FROM ld_fieldwxmaininfo WHERE tabid=@tabid AND fieldname='startdate');

SET @i=0;
INSERT INTO ld_fieldwxmaininfo(tabid,fieldname,sequence,displaytype)
SELECT @tabid,'enddate',(@i:=@i+1),'normal' FROM DUAL
WHERE NOT EXISTS(SELECT 1 FROM ld_fieldwxmaininfo WHERE tabid=@tabid AND fieldname='enddate');

INSERT INTO ld_fieldwxmaininfo(tabid,fieldname,sequence,displaytype)
SELECT @tabid,'assigned_user_id',(@i:=@i+1),'normal' FROM DUAL
WHERE NOT EXISTS(SELECT 1 FROM ld_fieldwxmaininfo WHERE tabid=@tabid AND fieldname='assigned_user_id');


SET @tabid=(SELECT tabid FROM ld_tab WHERE `name`='NormalApprove');
SET @i=0;
INSERT INTO ld_fieldwxmaininfo(tabid,fieldname,sequence,displaytype)
SELECT @tabid,'normalapprovetype',(@i:=@i+1),'normal' FROM DUAL
WHERE NOT EXISTS(SELECT 1 FROM ld_fieldwxmaininfo WHERE tabid=@tabid AND fieldname='normalapprovetype');

INSERT INTO ld_fieldwxmaininfo(tabid,fieldname,sequence,displaytype)
SELECT @tabid,'assigned_user_id',(@i:=@i+1),'normal' FROM DUAL
WHERE NOT EXISTS(SELECT 1 FROM ld_fieldwxmaininfo WHERE tabid=@tabid AND fieldname='assigned_user_id');

INSERT INTO ld_fieldwxmaininfo(tabid,fieldname,sequence,displaytype)
SELECT @tabid,'description',(@i:=@i+1),'normal' FROM DUAL
WHERE NOT EXISTS(SELECT 1 FROM ld_fieldwxmaininfo WHERE tabid=@tabid AND fieldname='description');


SET @tabid=(SELECT tabid FROM ld_tab WHERE `name`='NormalApprove');
SET @i=0;
INSERT INTO ld_fieldwxmaininfo(tabid,fieldname,sequence,displaytype)
SELECT @tabid,'createdtime',(@i:=@i+1),'normal' FROM DUAL
WHERE NOT EXISTS(SELECT 1 FROM ld_fieldwxmaininfo WHERE tabid=@tabid AND fieldname='createdtime');

INSERT INTO ld_fieldwxmaininfo(tabid,fieldname,sequence,displaytype)
SELECT @tabid,'normalapprovetype',(@i:=@i+1),'normal' FROM DUAL
WHERE NOT EXISTS(SELECT 1 FROM ld_fieldwxmaininfo WHERE tabid=@tabid AND fieldname='normalapprovetype');

INSERT INTO ld_fieldwxmaininfo(tabid,fieldname,sequence,displaytype)
SELECT @tabid,'assigned_user_id',(@i:=@i+1),'normal' FROM DUAL
WHERE NOT EXISTS(SELECT 1 FROM ld_fieldwxmaininfo WHERE tabid=@tabid AND fieldname='assigned_user_id');


SET @tabid=(SELECT tabid FROM ld_tab WHERE `name`='AddJobBill');
SET @i=0;
INSERT INTO ld_fieldwxmaininfo(tabid,fieldname,sequence,displaytype)
SELECT @tabid,'createdtime',(@i:=@i+1),'normal' FROM DUAL
WHERE NOT EXISTS(SELECT 1 FROM ld_fieldwxmaininfo WHERE tabid=@tabid AND fieldname='createdtime');

INSERT INTO ld_fieldwxmaininfo(tabid,fieldname,sequence,displaytype)
SELECT @tabid,'assigned_user_id',(@i:=@i+1),'normal' FROM DUAL
WHERE NOT EXISTS(SELECT 1 FROM ld_fieldwxmaininfo WHERE tabid=@tabid AND fieldname='assigned_user_id');

INSERT INTO ld_fieldwxmaininfo(tabid,fieldname,sequence,displaytype)
SELECT @tabid,'hdnGrandTotal',(@i:=@i+1),'normal' FROM DUAL
WHERE NOT EXISTS(SELECT 1 FROM ld_fieldwxmaininfo WHERE tabid=@tabid AND fieldname='hdnGrandTotal');



SET @tabid=(SELECT tabid FROM ld_tab WHERE `name`='MinusJobBill');
SET @i=0;
INSERT INTO ld_fieldwxmaininfo(tabid,fieldname,sequence,displaytype)
SELECT @tabid,'createdtime',(@i:=@i+1),'normal' FROM DUAL
WHERE NOT EXISTS(SELECT 1 FROM ld_fieldwxmaininfo WHERE tabid=@tabid AND fieldname='createdtime');

INSERT INTO ld_fieldwxmaininfo(tabid,fieldname,sequence,displaytype)
SELECT @tabid,'assigned_user_id',(@i:=@i+1),'normal' FROM DUAL
WHERE NOT EXISTS(SELECT 1 FROM ld_fieldwxmaininfo WHERE tabid=@tabid AND fieldname='assigned_user_id');

INSERT INTO ld_fieldwxmaininfo(tabid,fieldname,sequence,displaytype)
SELECT @tabid,'hdnGrandTotal',(@i:=@i+1),'normal' FROM DUAL
WHERE NOT EXISTS(SELECT 1 FROM ld_fieldwxmaininfo WHERE tabid=@tabid AND fieldname='hdnGrandTotal');



SET @tabid=(SELECT tabid FROM ld_tab WHERE `name`='BusinessApply');
SET @i=0;
INSERT INTO ld_fieldwxmaininfo(tabid,fieldname,sequence,displaytype)
SELECT @tabid,'createdtime',(@i:=@i+1),'normal' FROM DUAL
WHERE NOT EXISTS(SELECT 1 FROM ld_fieldwxmaininfo WHERE tabid=@tabid AND fieldname='createdtime');

INSERT INTO ld_fieldwxmaininfo(tabid,fieldname,sequence,displaytype)
SELECT @tabid,'assigned_user_id',(@i:=@i+1),'normal' FROM DUAL
WHERE NOT EXISTS(SELECT 1 FROM ld_fieldwxmaininfo WHERE tabid=@tabid AND fieldname='assigned_user_id');

INSERT INTO ld_fieldwxmaininfo(tabid,fieldname,sequence,displaytype)
SELECT @tabid,'hdnGrandTotal',(@i:=@i+1),'normal' FROM DUAL
WHERE NOT EXISTS(SELECT 1 FROM ld_fieldwxmaininfo WHERE tabid=@tabid AND fieldname='hdnGrandTotal');

INSERT INTO ld_fieldwxmaininfo(tabid,fieldname,sequence,displaytype)
SELECT @tabid,'account_id',(@i:=@i+1),'normal' FROM DUAL
WHERE NOT EXISTS(SELECT 1 FROM ld_fieldwxmaininfo WHERE tabid=@tabid AND fieldname='account_id');


SET @tabid=(SELECT tabid FROM ld_tab WHERE `name`='LoanApply');
SET @i=0;
INSERT INTO ld_fieldwxmaininfo(tabid,fieldname,sequence,displaytype)
SELECT @tabid,'paymentdate',(@i:=@i+1),'normal' FROM DUAL
WHERE NOT EXISTS(SELECT 1 FROM ld_fieldwxmaininfo WHERE tabid=@tabid AND fieldname='paymentdate');

INSERT INTO ld_fieldwxmaininfo(tabid,fieldname,sequence,displaytype)
SELECT @tabid,'assigned_user_id',(@i:=@i+1),'normal' FROM DUAL
WHERE NOT EXISTS(SELECT 1 FROM ld_fieldwxmaininfo WHERE tabid=@tabid AND fieldname='assigned_user_id');

INSERT INTO ld_fieldwxmaininfo(tabid,fieldname,sequence,displaytype)
SELECT @tabid,'loanmoney',(@i:=@i+1),'normal' FROM DUAL
WHERE NOT EXISTS(SELECT 1 FROM ld_fieldwxmaininfo WHERE tabid=@tabid AND fieldname='loanmoney');


SET @tabid=(SELECT tabid FROM ld_tab WHERE `name`='CardApply');
SET @i=0;
INSERT INTO ld_fieldwxmaininfo(tabid,fieldname,sequence,displaytype)
SELECT @tabid,'applydate',(@i:=@i+1),'normal' FROM DUAL
WHERE NOT EXISTS(SELECT 1 FROM ld_fieldwxmaininfo WHERE tabid=@tabid AND fieldname='applydate');

INSERT INTO ld_fieldwxmaininfo(tabid,fieldname,sequence,displaytype)
SELECT @tabid,'assigned_user_id',(@i:=@i+1),'normal' FROM DUAL
WHERE NOT EXISTS(SELECT 1 FROM ld_fieldwxmaininfo WHERE tabid=@tabid AND fieldname='assigned_user_id');

INSERT INTO ld_fieldwxmaininfo(tabid,fieldname,sequence,displaytype)
SELECT @tabid,'printnum',(@i:=@i+1),'normal' FROM DUAL
WHERE NOT EXISTS(SELECT 1 FROM ld_fieldwxmaininfo WHERE tabid=@tabid AND fieldname='printnum');


SET @tabid=(SELECT tabid FROM ld_tab WHERE `name`='Commission');
SET @i=0;
INSERT INTO ld_fieldwxmaininfo(tabid,fieldname,sequence,displaytype)
SELECT @tabid,'expensedate',(@i:=@i+1),'normal' FROM DUAL
WHERE NOT EXISTS(SELECT 1 FROM ld_fieldwxmaininfo WHERE tabid=@tabid AND fieldname='expensedate');

INSERT INTO ld_fieldwxmaininfo(tabid,fieldname,sequence,displaytype)
SELECT @tabid,'commissiontype',(@i:=@i+1),'normal' FROM DUAL
WHERE NOT EXISTS(SELECT 1 FROM ld_fieldwxmaininfo WHERE tabid=@tabid AND fieldname='commissiontype');

INSERT INTO ld_fieldwxmaininfo(tabid,fieldname,sequence,displaytype)
SELECT @tabid,'assigned_user_id',(@i:=@i+1),'normal' FROM DUAL
WHERE NOT EXISTS(SELECT 1 FROM ld_fieldwxmaininfo WHERE tabid=@tabid AND fieldname='assigned_user_id');

INSERT INTO ld_fieldwxmaininfo(tabid,fieldname,sequence,displaytype)
SELECT @tabid,'hdnGrandTotal',(@i:=@i+1),'normal' FROM DUAL
WHERE NOT EXISTS(SELECT 1 FROM ld_fieldwxmaininfo WHERE tabid=@tabid AND fieldname='hdnGrandTotal');

INSERT INTO ld_fieldwxmaininfo(tabid,fieldname,sequence,displaytype)
SELECT @tabid,'account_id',(@i:=@i+1),'link' FROM DUAL
WHERE NOT EXISTS(SELECT 1 FROM ld_fieldwxmaininfo WHERE tabid=@tabid AND fieldname='account_id');

SET @tabid=(SELECT tabid FROM ld_tab WHERE `name`='Expense');
SET @i=0;
INSERT INTO ld_fieldwxmaininfo(tabid,fieldname,sequence,displaytype)
SELECT @tabid,'expensedate',(@i:=@i+1),'normal' FROM DUAL
WHERE NOT EXISTS(SELECT 1 FROM ld_fieldwxmaininfo WHERE tabid=@tabid AND fieldname='expensedate');

INSERT INTO ld_fieldwxmaininfo(tabid,fieldname,sequence,displaytype)
SELECT @tabid,'assigned_user_id',(@i:=@i+1),'normal' FROM DUAL
WHERE NOT EXISTS(SELECT 1 FROM ld_fieldwxmaininfo WHERE tabid=@tabid AND fieldname='assigned_user_id');

INSERT INTO ld_fieldwxmaininfo(tabid,fieldname,sequence,displaytype)
SELECT @tabid,'hdnGrandTotal',(@i:=@i+1),'normal' FROM DUAL
WHERE NOT EXISTS(SELECT 1 FROM ld_fieldwxmaininfo WHERE tabid=@tabid AND fieldname='hdnGrandTotal');

INSERT INTO ld_fieldwxmaininfo(tabid,fieldname,sequence,displaytype)
SELECT @tabid,'account_id',(@i:=@i+1),'link' FROM DUAL
WHERE NOT EXISTS(SELECT 1 FROM ld_fieldwxmaininfo WHERE tabid=@tabid AND fieldname='account_id');


SET @tabid=(SELECT tabid FROM ld_tab WHERE `name`='Vendors');
SET @i=0;
INSERT INTO ld_fieldwxmaininfo(tabid,fieldname,sequence,displaytype)
SELECT @tabid,'street',(@i:=@i+1),'normal' FROM DUAL
WHERE NOT EXISTS(SELECT 1 FROM ld_fieldwxmaininfo WHERE tabid=@tabid AND fieldname='street');

INSERT INTO ld_fieldwxmaininfo(tabid,fieldname,sequence,displaytype)
SELECT @tabid,'phone',(@i:=@i+1),'normal' FROM DUAL
WHERE NOT EXISTS(SELECT 1 FROM ld_fieldwxmaininfo WHERE tabid=@tabid AND fieldname='phone');

INSERT INTO ld_fieldwxmaininfo(tabid,fieldname,sequence,displaytype)
SELECT @tabid,'assigned_user_id',(@i:=@i+1),'normal' FROM DUAL
WHERE NOT EXISTS(SELECT 1 FROM ld_fieldwxmaininfo WHERE tabid=@tabid AND fieldname='assigned_user_id');



SET @tabid=(SELECT tabid FROM ld_tab WHERE `name`='VendorContact');
SET @i=0;
INSERT INTO ld_fieldwxmaininfo(tabid,fieldname,sequence,displaytype)
SELECT @tabid,'mobile',(@i:=@i+1),'normal' FROM DUAL
WHERE NOT EXISTS(SELECT 1 FROM ld_fieldwxmaininfo WHERE tabid=@tabid AND fieldname='mobile');

INSERT INTO ld_fieldwxmaininfo(tabid,fieldname,sequence,displaytype)
SELECT @tabid,'assigned_user_id',(@i:=@i+1),'normal' FROM DUAL
WHERE NOT EXISTS(SELECT 1 FROM ld_fieldwxmaininfo WHERE tabid=@tabid AND fieldname='assigned_user_id');

INSERT INTO ld_fieldwxmaininfo(tabid,fieldname,sequence,displaytype)
SELECT @tabid,'vendor_id',(@i:=@i+1),'link' FROM DUAL
WHERE NOT EXISTS(SELECT 1 FROM ld_fieldwxmaininfo WHERE tabid=@tabid AND fieldname='vendor_id');



SET @tabid=(SELECT tabid FROM ld_tab WHERE `name`='VendorContactRecords');
SET @i=0;
INSERT INTO ld_fieldwxmaininfo(tabid,fieldname,sequence,displaytype)
SELECT @tabid,'contactdate',(@i:=@i+1),'normal' FROM DUAL
WHERE NOT EXISTS(SELECT 1 FROM ld_fieldwxmaininfo WHERE tabid=@tabid AND fieldname='contactdate');

INSERT INTO ld_fieldwxmaininfo(tabid,fieldname,sequence,displaytype)
SELECT @tabid,'assigned_user_id',(@i:=@i+1),'normal' FROM DUAL
WHERE NOT EXISTS(SELECT 1 FROM ld_fieldwxmaininfo WHERE tabid=@tabid AND fieldname='assigned_user_id');

INSERT INTO ld_fieldwxmaininfo(tabid,fieldname,sequence,displaytype)
SELECT @tabid,'vendor_id',(@i:=@i+1),'link' FROM DUAL
WHERE NOT EXISTS(SELECT 1 FROM ld_fieldwxmaininfo WHERE tabid=@tabid AND fieldname='vendor_id');


SET @tabid=(SELECT tabid FROM ld_tab WHERE `name`='PurchaseOrder');
SET @i=0;
INSERT INTO ld_fieldwxmaininfo(tabid,fieldname,sequence,displaytype)
SELECT @tabid,'signed_data',(@i:=@i+1),'normal' FROM DUAL
WHERE NOT EXISTS(SELECT 1 FROM ld_fieldwxmaininfo WHERE tabid=@tabid AND fieldname='signed_data');

INSERT INTO ld_fieldwxmaininfo(tabid,fieldname,sequence,displaytype)
SELECT @tabid,'hdnGrandTotal',(@i:=@i+1),'normal' FROM DUAL
WHERE NOT EXISTS(SELECT 1 FROM ld_fieldwxmaininfo WHERE tabid=@tabid AND fieldname='hdnGrandTotal');

INSERT INTO ld_fieldwxmaininfo(tabid,fieldname,sequence,displaytype)
SELECT @tabid,'pay_balance',(@i:=@i+1),'normal' FROM DUAL
WHERE NOT EXISTS(SELECT 1 FROM ld_fieldwxmaininfo WHERE tabid=@tabid AND fieldname='pay_balance');

INSERT INTO ld_fieldwxmaininfo(tabid,fieldname,sequence,displaytype)
SELECT @tabid,'nothave_invoicetotal',(@i:=@i+1),'normal' FROM DUAL
WHERE NOT EXISTS(SELECT 1 FROM ld_fieldwxmaininfo WHERE tabid=@tabid AND fieldname='nothave_invoicetotal');

INSERT INTO ld_fieldwxmaininfo(tabid,fieldname,sequence,displaytype)
SELECT @tabid,'vendor_id',(@i:=@i+1),'link' FROM DUAL
WHERE NOT EXISTS(SELECT 1 FROM ld_fieldwxmaininfo WHERE tabid=@tabid AND fieldname='vendor_id');


SET @tabid=(SELECT tabid FROM ld_tab WHERE `name`='CashBill');
SET @i=0;
INSERT INTO ld_fieldwxmaininfo(tabid,fieldname,sequence,displaytype)
SELECT @tabid,'cashbilldate',(@i:=@i+1),'normal' FROM DUAL
WHERE NOT EXISTS(SELECT 1 FROM ld_fieldwxmaininfo WHERE tabid=@tabid AND fieldname='cashbilldate');

INSERT INTO ld_fieldwxmaininfo(tabid,fieldname,sequence,displaytype)
SELECT @tabid,'assigned_user_id',(@i:=@i+1),'normal' FROM DUAL
WHERE NOT EXISTS(SELECT 1 FROM ld_fieldwxmaininfo WHERE tabid=@tabid AND fieldname='assigned_user_id');

INSERT INTO ld_fieldwxmaininfo(tabid,fieldname,sequence,displaytype)
SELECT @tabid,'hdnGrandTotal',(@i:=@i+1),'normal' FROM DUAL
WHERE NOT EXISTS(SELECT 1 FROM ld_fieldwxmaininfo WHERE tabid=@tabid AND fieldname='hdnGrandTotal');

INSERT INTO ld_fieldwxmaininfo(tabid,fieldname,sequence,displaytype)
SELECT @tabid,'account_id',(@i:=@i+1),'link' FROM DUAL
WHERE NOT EXISTS(SELECT 1 FROM ld_fieldwxmaininfo WHERE tabid=@tabid AND fieldname='account_id');



SET @tabid=(SELECT tabid FROM ld_tab WHERE `name`='SendCashBill');
SET @i=0;
INSERT INTO ld_fieldwxmaininfo(tabid,fieldname,sequence,displaytype)
SELECT @tabid,'cashbilldate',(@i:=@i+1),'normal' FROM DUAL
WHERE NOT EXISTS(SELECT 1 FROM ld_fieldwxmaininfo WHERE tabid=@tabid AND fieldname='cashbilldate');

INSERT INTO ld_fieldwxmaininfo(tabid,fieldname,sequence,displaytype)
SELECT @tabid,'assigned_user_id',(@i:=@i+1),'normal' FROM DUAL
WHERE NOT EXISTS(SELECT 1 FROM ld_fieldwxmaininfo WHERE tabid=@tabid AND fieldname='assigned_user_id');

INSERT INTO ld_fieldwxmaininfo(tabid,fieldname,sequence,displaytype)
SELECT @tabid,'hdnGrandTotal',(@i:=@i+1),'normal' FROM DUAL
WHERE NOT EXISTS(SELECT 1 FROM ld_fieldwxmaininfo WHERE tabid=@tabid AND fieldname='hdnGrandTotal');

INSERT INTO ld_fieldwxmaininfo(tabid,fieldname,sequence,displaytype)
SELECT @tabid,'vendor_id',(@i:=@i+1),'link' FROM DUAL
WHERE NOT EXISTS(SELECT 1 FROM ld_fieldwxmaininfo WHERE tabid=@tabid AND fieldname='vendor_id');



SET @tabid=(SELECT tabid FROM ld_tab WHERE `name`='Invoice');
SET @i=0;
INSERT INTO ld_fieldwxmaininfo(tabid,fieldname,sequence,displaytype)
SELECT @tabid,'invoicedate',(@i:=@i+1),'normal' FROM DUAL
WHERE NOT EXISTS(SELECT 1 FROM ld_fieldwxmaininfo WHERE tabid=@tabid AND fieldname='invoicedate');

INSERT INTO ld_fieldwxmaininfo(tabid,fieldname,sequence,displaytype)
SELECT @tabid,'assigned_user_id',(@i:=@i+1),'normal' FROM DUAL
WHERE NOT EXISTS(SELECT 1 FROM ld_fieldwxmaininfo WHERE tabid=@tabid AND fieldname='assigned_user_id');

INSERT INTO ld_fieldwxmaininfo(tabid,fieldname,sequence,displaytype)
SELECT @tabid,'hdnGrandTotal',(@i:=@i+1),'normal' FROM DUAL
WHERE NOT EXISTS(SELECT 1 FROM ld_fieldwxmaininfo WHERE tabid=@tabid AND fieldname='hdnGrandTotal');

INSERT INTO ld_fieldwxmaininfo(tabid,fieldname,sequence,displaytype)
SELECT @tabid,'account_id',(@i:=@i+1),'link' FROM DUAL
WHERE NOT EXISTS(SELECT 1 FROM ld_fieldwxmaininfo WHERE tabid=@tabid AND fieldname='account_id');


SET @tabid=(SELECT tabid FROM ld_tab WHERE `name`='PurchaseInvoice');
SET @i=0;
INSERT INTO ld_fieldwxmaininfo(tabid,fieldname,sequence,displaytype)
SELECT @tabid,'purchaseinvoicedate',(@i:=@i+1),'normal' FROM DUAL
WHERE NOT EXISTS(SELECT 1 FROM ld_fieldwxmaininfo WHERE tabid=@tabid AND fieldname='purchaseinvoicedate');

INSERT INTO ld_fieldwxmaininfo(tabid,fieldname,sequence,displaytype)
SELECT @tabid,'assigned_user_id',(@i:=@i+1),'normal' FROM DUAL
WHERE NOT EXISTS(SELECT 1 FROM ld_fieldwxmaininfo WHERE tabid=@tabid AND fieldname='assigned_user_id');

INSERT INTO ld_fieldwxmaininfo(tabid,fieldname,sequence,displaytype)
SELECT @tabid,'hdnGrandTotal',(@i:=@i+1),'normal' FROM DUAL
WHERE NOT EXISTS(SELECT 1 FROM ld_fieldwxmaininfo WHERE tabid=@tabid AND fieldname='hdnGrandTotal');

INSERT INTO ld_fieldwxmaininfo(tabid,fieldname,sequence,displaytype)
SELECT @tabid,'vendor_id',(@i:=@i+1),'link' FROM DUAL
WHERE NOT EXISTS(SELECT 1 FROM ld_fieldwxmaininfo WHERE tabid=@tabid AND fieldname='vendor_id');


SET @tabid=(SELECT tabid FROM ld_tab WHERE `name`='PaymentPlan');
SET @i=0;
INSERT INTO ld_fieldwxmaininfo(tabid,fieldname,sequence,displaytype)
SELECT @tabid,'plandate',(@i:=@i+1),'normal' FROM DUAL
WHERE NOT EXISTS(SELECT 1 FROM ld_fieldwxmaininfo WHERE tabid=@tabid AND fieldname='plandate');

INSERT INTO ld_fieldwxmaininfo(tabid,fieldname,sequence,displaytype)
SELECT @tabid,'paymentstatus',(@i:=@i+1),'normal' FROM DUAL
WHERE NOT EXISTS(SELECT 1 FROM ld_fieldwxmaininfo WHERE tabid=@tabid AND fieldname='paymentstatus');

INSERT INTO ld_fieldwxmaininfo(tabid,fieldname,sequence,displaytype)
SELECT @tabid,'assigned_user_id',(@i:=@i+1),'normal' FROM DUAL
WHERE NOT EXISTS(SELECT 1 FROM ld_fieldwxmaininfo WHERE tabid=@tabid AND fieldname='assigned_user_id');

INSERT INTO ld_fieldwxmaininfo(tabid,fieldname,sequence,displaytype)
SELECT @tabid,'amount',(@i:=@i+1),'normal' FROM DUAL
WHERE NOT EXISTS(SELECT 1 FROM ld_fieldwxmaininfo WHERE tabid=@tabid AND fieldname='amount');


SET @tabid=(SELECT tabid FROM ld_tab WHERE `name`='SendPayment');
SET @i=0;
INSERT INTO ld_fieldwxmaininfo(tabid,fieldname,sequence,displaytype)
SELECT @tabid,'plandate',(@i:=@i+1),'normal' FROM DUAL
WHERE NOT EXISTS(SELECT 1 FROM ld_fieldwxmaininfo WHERE tabid=@tabid AND fieldname='plandate');

INSERT INTO ld_fieldwxmaininfo(tabid,fieldname,sequence,displaytype)
SELECT @tabid,'cpstatus',(@i:=@i+1),'normal' FROM DUAL
WHERE NOT EXISTS(SELECT 1 FROM ld_fieldwxmaininfo WHERE tabid=@tabid AND fieldname='cpstatus');

INSERT INTO ld_fieldwxmaininfo(tabid,fieldname,sequence,displaytype)
SELECT @tabid,'assigned_user_id',(@i:=@i+1),'normal' FROM DUAL
WHERE NOT EXISTS(SELECT 1 FROM ld_fieldwxmaininfo WHERE tabid=@tabid AND fieldname='assigned_user_id');

INSERT INTO ld_fieldwxmaininfo(tabid,fieldname,sequence,displaytype)
SELECT @tabid,'amount',(@i:=@i+1),'normal' FROM DUAL
WHERE NOT EXISTS(SELECT 1 FROM ld_fieldwxmaininfo WHERE tabid=@tabid AND fieldname='amount');


SET @tabid=(SELECT tabid FROM ld_tab WHERE `name`='ModComments');
SET @i=0;
INSERT INTO ld_fieldwxmaininfo(tabid,fieldname,sequence,displaytype)
SELECT @tabid,'reltab',(@i:=@i+1),'normal' FROM DUAL
WHERE NOT EXISTS(SELECT 1 FROM ld_fieldwxmaininfo WHERE tabid=@tabid AND fieldname='reltab');

INSERT INTO ld_fieldwxmaininfo(tabid,fieldname,sequence,displaytype)
SELECT @tabid,'related_to',(@i:=@i+1),'normal' FROM DUAL
WHERE NOT EXISTS(SELECT 1 FROM ld_fieldwxmaininfo WHERE tabid=@tabid AND fieldname='related_to');

INSERT INTO ld_fieldwxmaininfo(tabid,fieldname,sequence,displaytype)
SELECT @tabid,'assigned_user_id',(@i:=@i+1),'normal' FROM DUAL
WHERE NOT EXISTS(SELECT 1 FROM ld_fieldwxmaininfo WHERE tabid=@tabid AND fieldname='assigned_user_id');


SET @tabid=(SELECT tabid FROM ld_tab WHERE `name`='PublicAnnouncement');
SET @i=0;
INSERT INTO ld_fieldwxmaininfo(tabid,fieldname,sequence,displaytype)
SELECT @tabid,'startdate',(@i:=@i+1),'normal' FROM DUAL
WHERE NOT EXISTS(SELECT 1 FROM ld_fieldwxmaininfo WHERE tabid=@tabid AND fieldname='startdate');

INSERT INTO ld_fieldwxmaininfo(tabid,fieldname,sequence,displaytype)
SELECT @tabid,'enddate',(@i:=@i+1),'normal' FROM DUAL
WHERE NOT EXISTS(SELECT 1 FROM ld_fieldwxmaininfo WHERE tabid=@tabid AND fieldname='enddate');

INSERT INTO ld_fieldwxmaininfo(tabid,fieldname,sequence,displaytype)
SELECT @tabid,'assigned_user_id',(@i:=@i+1),'normal' FROM DUAL
WHERE NOT EXISTS(SELECT 1 FROM ld_fieldwxmaininfo WHERE tabid=@tabid AND fieldname='assigned_user_id');

SET @tabid=(SELECT tabid FROM ld_tab WHERE `name`='QuotesChange');
SET @i=0;
INSERT INTO ld_fieldwxmaininfo(tabid,fieldname,sequence,displaytype)
SELECT @tabid,'change_date',(@i:=@i+1),'normal' FROM DUAL
WHERE NOT EXISTS(SELECT 1 FROM ld_fieldwxmaininfo WHERE tabid=@tabid AND fieldname='change_date');

INSERT INTO ld_fieldwxmaininfo(tabid,fieldname,sequence,displaytype)
SELECT @tabid,'change_type',(@i:=@i+1),'normal' FROM DUAL
WHERE NOT EXISTS(SELECT 1 FROM ld_fieldwxmaininfo WHERE tabid=@tabid AND fieldname='change_type');

INSERT INTO ld_fieldwxmaininfo(tabid,fieldname,sequence,displaytype)
SELECT @tabid,'assigned_user_id',(@i:=@i+1),'normal' FROM DUAL
WHERE NOT EXISTS(SELECT 1 FROM ld_fieldwxmaininfo WHERE tabid=@tabid AND fieldname='assigned_user_id');

INSERT INTO ld_fieldwxmaininfo(tabid,fieldname,sequence,displaytype)
SELECT @tabid,'account_id',(@i:=@i+1),'link' FROM DUAL
WHERE NOT EXISTS(SELECT 1 FROM ld_fieldwxmaininfo WHERE tabid=@tabid AND fieldname='account_id');


select tabid into @tabid from ld_tab where `name` = 'Users'; 
select fieldid into @fieldid from ld_field where tabid = @tabid and columnname = 'viewothers'; 
update ld_tranlabel set fieldlabel = '查看其他用户单据' where languagetype = 'zh' and trantable = 'ld_field' and tabid = @tabid and Relateid = @fieldid; 
update ld_tranlabel set fieldlabel = 'Allow to view other users data' where languagetype = 'en' and trantable = 'ld_field' and tabid = @tabid and Relateid = @fieldid; 
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) 
select 'zh','viewothers','允许查看其他用户的单据(优先于角色权限)','fixedstr' from dual 
where not exists(select 1 from ld_desk where languagetype = 'zh' and labelbol = 'viewothers' and labeltype = 'fixedstr'); 
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) 
select 'en','viewothers','Allow to view other users data','fixedstr' from dual 
where not exists(select 1 from ld_desk where languagetype = 'en' and labelbol = 'viewothers' and labeltype = 'fixedstr'); 
delimiter; 

select tabid into @tabid from ld_tab where `name` = 'Users'; 
select fieldid into @fieldid from ld_field where tabid = @tabid and columnname = 'editothers'; 
update ld_tranlabel set fieldlabel = '编辑其他用户单据' where languagetype = 'zh' and trantable = 'ld_field' and tabid = @tabid and Relateid = @fieldid; 
update ld_tranlabel set fieldlabel = 'Allow to edit other users data' where languagetype = 'en' and trantable = 'ld_field' and tabid = @tabid and Relateid = @fieldid; 
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) 
select 'zh','editothers','允许编辑其他用户的单据(优先于角色权限)','fixedstr' from dual 
where not exists(select 1 from ld_desk where languagetype = 'zh' and labelbol = 'editothers' and labeltype = 'fixedstr'); 
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) 
select 'en','editothers','Allow to edit other users data','fixedstr' from dual 
where not exists(select 1 from ld_desk where languagetype = 'en' and labelbol = 'editothers' and labeltype = 'fixedstr'); 
delimiter; 

select tabid into @tabid from ld_tab where `name` = 'Users'; 
select fieldid into @fieldid from ld_field where tabid = @tabid and columnname = 'delothers'; 
update ld_tranlabel set fieldlabel = '删除其他用户单据' where languagetype = 'zh' and trantable = 'ld_field' and tabid = @tabid and Relateid = @fieldid; 
update ld_tranlabel set fieldlabel = 'Allow to delete other users data' where languagetype = 'en' and trantable = 'ld_field' and tabid = @tabid and Relateid = @fieldid; 
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) 
select 'zh','delothers','允许删除其他用户的单据(优先于角色权限)','fixedstr' from dual 
where not exists(select 1 from ld_desk where languagetype = 'zh' and labelbol = 'delothers' and labeltype = 'fixedstr'); 
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) 
select 'en','delothers','Allow to delete other users data','fixedstr' from dual 
where not exists(select 1 from ld_desk where languagetype = 'en' and labelbol = 'delothers' and labeltype = 'fixedstr'); 
delimiter; 


select tabid into @tabid from ld_tab where `name` = 'Users'; 
select fieldid into @fieldid from ld_field where tabid = @tabid and columnname = 'viewselfbills'; 
update ld_tranlabel set fieldlabel = '查询自己创建单据' where languagetype = 'zh' and trantable = 'ld_field' and tabid = @tabid and Relateid = @fieldid; 
update ld_tranlabel set fieldlabel = 'view me created data' where languagetype = 'en' and trantable = 'ld_field' and tabid = @tabid and Relateid = @fieldid; 
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) 
select 'zh','viewselfbills','允许查询自已创建的单据(负责人不是自已的单据)','fixedstr' from dual 
where not exists(select 1 from ld_desk where languagetype = 'zh' and labelbol = 'viewselfbills' and labeltype = 'fixedstr'); 
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) 
select 'en','viewselfbills','Allows to query the data which created by myself(smownerid are not responsible for their own documents)','fixedstr' from dual 
where not exists(select 1 from ld_desk where languagetype = 'en' and labelbol = 'viewselfbills' and labeltype = 'fixedstr'); 
delimiter; 


select tabid into @tabid from ld_tab where `name` = 'Users'; 
select fieldid into @fieldid from ld_field where tabid = @tabid and columnname = 'edit_other_mobile'; 
update ld_tranlabel set fieldlabel = '编辑其他用户单据手机' where languagetype = 'zh' and trantable = 'ld_field' and tabid = @tabid and Relateid = @fieldid; 
update ld_tranlabel set fieldlabel = 'edit other users mobile number' where languagetype = 'en' and trantable = 'ld_field' and tabid = @tabid and Relateid = @fieldid; 
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) 
select 'zh','edit_other_mobile','允许编辑其他用户单据的手机号码字段','fixedstr' from dual 
where not exists(select 1 from ld_desk where languagetype = 'zh' and labelbol = 'edit_other_mobile' and labeltype = 'fixedstr'); 
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) 
select 'en','edit_other_mobile','Allow to edit other users mobile number','fixedstr' from dual 
where not exists(select 1 from ld_desk where languagetype = 'en' and labelbol = 'edit_other_mobile' and labeltype = 'fixedstr'); 
delimiter; 


select tabid into @tabid from ld_tab where `name` = 'Users'; 
select fieldid into @fieldid from ld_field where tabid = @tabid and columnname = 'edit_me_mobile'; 
update ld_tranlabel set fieldlabel = '编辑自己单据手机' where languagetype = 'zh' and trantable = 'ld_field' and tabid = @tabid and Relateid = @fieldid; 
update ld_tranlabel set fieldlabel = 'edit my bills mobile number' where languagetype = 'en' and trantable = 'ld_field' and tabid = @tabid and Relateid = @fieldid; 
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) 
select 'zh','edit_me_mobile','允许编辑自己单据的手机号码字段','fixedstr' from dual 
where not exists(select 1 from ld_desk where languagetype = 'zh' and labelbol = 'edit_me_mobile' and labeltype = 'fixedstr'); 
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) 
select 'en','edit_me_mobile','Allow to edit my bills mobile number','fixedstr' from dual 
where not exists(select 1 from ld_desk where languagetype = 'en' and labelbol = 'edit_me_mobile' and labeltype = 'fixedstr'); 
delimiter; 

select tabid into @tabid from ld_tab where `name` = 'Users'; 
select fieldid into @fieldid from ld_field where tabid = @tabid and columnname = 'is_mobile_style'; 
update ld_tranlabel set fieldlabel = '手机显示样式控制' where languagetype = 'zh' and trantable = 'ld_field' and tabid = @tabid and Relateid = @fieldid; 
update ld_tranlabel set fieldlabel = 'Phone num style according' where languagetype = 'en' and trantable = 'ld_field' and tabid = @tabid and Relateid = @fieldid; 
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) 
select 'zh','is_mobile_style','手机号码显示样式根据系统参数控制','fixedstr' from dual 
where not exists(select 1 from ld_desk where languagetype = 'zh' and labelbol = 'is_mobile_style' and labeltype = 'fixedstr'); 
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) 
select 'en','is_mobile_style','Phone num style according to parameters','fixedstr' from dual 
where not exists(select 1 from ld_desk where languagetype = 'en' and labelbol = 'is_mobile_style' and labeltype = 'fixedstr'); 
delimiter; 

select tabid into @tabid from ld_tab where `name` = 'Users'; 
select fieldid into @fieldid from ld_field where tabid = @tabid and columnname = 'select_servicedetail'; 
update ld_tranlabel set fieldlabel = '显示服务信息' where languagetype = 'zh' and trantable = 'ld_field' and tabid = @tabid and Relateid = @fieldid; 
update ld_tranlabel set fieldlabel = 'view the information service' where languagetype = 'en' and trantable = 'ld_field' and tabid = @tabid and Relateid = @fieldid; 
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) 
select 'zh','select_servicedetail','{$Accounts.Accounts}和{$HelpDesk.HelpDesk}界面是否显示服务信息','fixedstr' from dual 
where not exists(select 1 from ld_desk where languagetype = 'zh' and labelbol = 'select_servicedetail' and labeltype = 'fixedstr'); 
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) 
select 'en','select_servicedetail','{$Accounts.Accounts} and {$HelpDesk.HelpDesk} view whether to display the information service','fixedstr' from dual 
where not exists(select 1 from ld_desk where languagetype = 'en' and labelbol = 'select_servicedetail' and labeltype = 'fixedstr'); 
delimiter; 


select tabid into @tabid from ld_tab where `name` = 'Users'; 
select fieldid into @fieldid from ld_field where tabid = @tabid and columnname = 'select_due_date'; 
update ld_tranlabel set fieldlabel = '显示具体服务到期日' where languagetype = 'zh' and trantable = 'ld_field' and tabid = @tabid and Relateid = @fieldid; 
update ld_tranlabel set fieldlabel = 'view the real service enddate' where languagetype = 'en' and trantable = 'ld_field' and tabid = @tabid and Relateid = @fieldid; 
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) 
select 'zh','select_due_date','{$Accounts.Accounts}和{$HelpDesk.HelpDesk}界面显示具体的服务到期日','fixedstr' from dual 
where not exists(select 1 from ld_desk where languagetype = 'zh' and labelbol = 'select_due_date' and labeltype = 'fixedstr'); 
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) 
select 'en','select_due_date','{$Accounts.Accounts} and {$HelpDesk.HelpDesk} view the real service enddate','fixedstr' from dual 
where not exists(select 1 from ld_desk where languagetype = 'en' and labelbol = 'select_due_date' and labeltype = 'fixedstr'); 
delimiter; 

select tabid into @tabid from ld_tab where `name` = 'Users'; 
select fieldid into @fieldid from ld_field where tabid = @tabid and columnname = 'accountallview'; 
update ld_tranlabel set fieldlabel = '相关信息查询所有数据' where languagetype = 'zh' and trantable = 'ld_field' and tabid = @tabid and Relateid = @fieldid; 
update ld_tranlabel set fieldlabel = 'view the relevant information list' where languagetype = 'en' and trantable = 'ld_field' and tabid = @tabid and Relateid = @fieldid; 
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) 
select 'zh','accountallview','相关信息列表是否允许查询所有数据','fixedstr' from dual 
where not exists(select 1 from ld_desk where languagetype = 'zh' and labelbol = 'accountallview' and labeltype = 'fixedstr'); 
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) 
select 'en','accountallview','Allows you to view the relevant information list data permissions','fixedstr' from dual 
where not exists(select 1 from ld_desk where languagetype = 'en' and labelbol = 'accountallview' and labeltype = 'fixedstr'); 
delimiter; 

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','list','列表','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype = 'zh' and labelbol = 'list' and labeltype = 'fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','list',' list','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype = 'en' and labelbol = 'list' and labeltype = 'fixedstr');
delimiter;

update  ld_relatedlists set type='datacategory_sql',related_coltable='servicecontracts.quote_id' where tabid=20 and  name='get_servicecontracts';
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','EDITPERSONALACCOUNT','个人设置','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype = 'zh' and labelbol = 'EDITPERSONALACCOUNT' and labeltype = 'fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','EDITPERSONALACCOUNT','Users','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype = 'en' and labelbol = 'EDITPERSONALACCOUNT' and labeltype = 'fixedstr');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','UPDATENOTES','升级说明','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype = 'zh' and labelbol = 'UPDATENOTES' and labeltype = 'fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','UPDATENOTES','Update notes','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype = 'en' and labelbol = 'UPDATENOTES' and labeltype = 'fixedstr');
delimiter;

update ld_desk set fieldlabel='退出登录' where labelbol='LOGOUT' and languagetype='zh' and Labeltype='fixedstr';
delimiter;
-- 2017-11-24

SELECT cvid INTO @cvid FROM ld_customview WHERE entitytype='Users' AND viewname='All' LIMIT 1;
SET @i=0;
DELETE FROM ld_cvcolumnlist WHERE cvid=@cvid;
INSERT INTO ld_cvcolumnlist(cvid,columnindex,columnname)
SELECT @cvid,@i,'ld_users:last_name:last_name:Users_fieldlabel:V'; 
INSERT INTO ld_cvcolumnlist(cvid,columnindex,columnname)
SELECT @cvid,(@i:=@i+1),'ld_users:user_name:user_name:Users_fieldlabel:V'; 
INSERT INTO ld_cvcolumnlist(cvid,columnindex,columnname)
SELECT @cvid,(@i:=@i+1),'ld_users:groupid:groupid:Users_fieldlabel:V'; 
INSERT INTO ld_cvcolumnlist(cvid,columnindex,columnname)
SELECT @cvid,(@i:=@i+1),'ld_users:profileid:profileid:Users_fieldlabel:V'; 
INSERT INTO ld_cvcolumnlist(cvid,columnindex,columnname)
SELECT @cvid,(@i:=@i+1),'ld_users:userlevel:userlevel:Users_fieldlabel:V'; 
INSERT INTO ld_cvcolumnlist(cvid,columnindex,columnname)
SELECT @cvid,(@i:=@i+1),'ld_users:phone_mobile:phone_mobile:Users_fieldlabel:V'; 
INSERT INTO ld_cvcolumnlist(cvid,columnindex,columnname)
SELECT @cvid,(@i:=@i+1),'ld_users:email1:email1:Users_fieldlabel:E'; 
INSERT INTO ld_cvcolumnlist(cvid,columnindex,columnname)
SELECT @cvid,(@i:=@i+1),'ld_users:is_admin:is_admin:Users_fieldlabel:V'; 
INSERT INTO ld_cvcolumnlist(cvid,columnindex,columnname)
SELECT @cvid,(@i:=@i+1),'ld_users:status:status:Users_fieldlabel:V'; 
delimiter;

select tabid into @vtabid from ld_tab where name = 'Vendors';
select tabid into @etabid from ld_tab where name = 'Expense';
update ld_relatedlists set type='datacategory_sql',related_coltable='expense.vendorid' 
where tabid=@vtabid and related_tabid=@etabid;
delimiter;

insert into ld_desk (languagetype,labelbol,fieldlabel,labeltype)
SELECT 'zh','DISPLAYMOREITEM','展示更多栏目' ,'fixedstr' from dual 
where not exists(select 1 from ld_desk where languagetype='zh' and Labeltype='fixedstr' and labelbol='fixedstr');

insert into ld_desk (languagetype,labelbol,fieldlabel,labeltype)
SELECT 'en','DISPLAYMOREITEM','Display more item' ,'fixedstr' from dual 
where not exists(select 1 from ld_desk where languagetype='en' and Labeltype='fixedstr' and labelbol='fixedstr');
delimiter;
-- 2017-11-27

CALL DelForeignkey('ld_settings_field','ld_settings_field_ibfk_1');
delimiter;

SET FOREIGN_KEY_CHECKS=0;
UPDATE ld_settings_blocks SET blockid=blockid+10000;
DELETE FROM ld_settings_blocks; 
INSERT INTO ld_settings_blocks(blockid,label,sequence,active)
SELECT 1,'LBL_SYSTEM_SETTINGS',1,0;
INSERT INTO ld_settings_blocks(blockid,label,sequence,active)
SELECT 2,'LBL_PARAMETER_SETTINGS',2,0;
INSERT INTO ld_settings_blocks(blockid,label,sequence,active)
SELECT 3,'LBL_TEMPLATE_SETTINGS',3,0;
INSERT INTO ld_settings_blocks(blockid,label,sequence,active)
SELECT 4,'LBL_INTERFACE_SETTINGS',5,0;
INSERT INTO ld_settings_blocks(blockid,label,sequence,active)
SELECT 5,'LBL_OTHER_SETTINGS',5,0;

DELETE FROM ld_desk WHERE labelbol IN ('LBL_COMMUNICATION_TEMPLATES','LBL_STUDIO','LBL_USER_MANAGEMENT','LBL_MODULE_MANAGER','LBL_OTHER_SETTINGS');

SET @labelbol='LBL_SYSTEM_SETTINGS';
SET @zh='系统定制';
SET @en='System Settings';
SET @labeltype='fixedstr';
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'zh',@labelbol,@zh,@labeltype FROM DUAL
WHERE NOT EXISTS(SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol = @labelbol AND labeltype=@labeltype);

INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'en',@labelbol,@en,@labeltype FROM DUAL
WHERE NOT EXISTS(SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol = @labelbol AND labeltype=@labeltype);
delimiter;

SET @labelbol='LBL_PARAMETER_SETTINGS';
SET @zh='参数设置';
SET @en='Parameter Settings';
SET @labeltype='fixedstr';
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'zh',@labelbol,@zh,@labeltype FROM DUAL
WHERE NOT EXISTS(SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol = @labelbol AND labeltype=@labeltype);

INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'en',@labelbol,@en,@labeltype FROM DUAL
WHERE NOT EXISTS(SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol = @labelbol AND labeltype=@labeltype);
delimiter;

SET @labelbol='LBL_TEMPLATE_SETTINGS';
SET @zh='模板设置';
SET @en='Template Settings';
SET @labeltype='fixedstr';
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'zh',@labelbol,@zh,@labeltype FROM DUAL
WHERE NOT EXISTS(SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol = @labelbol AND labeltype=@labeltype);

INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'en',@labelbol,@en,@labeltype FROM DUAL
WHERE NOT EXISTS(SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol = @labelbol AND labeltype=@labeltype);
delimiter;

SET @labelbol='LBL_INTERFACE_SETTINGS';
SET @zh='接口设置';
SET @en='Interface Settings';
SET @labeltype='fixedstr';
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'zh',@labelbol,@zh,@labeltype FROM DUAL
WHERE NOT EXISTS(SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol = @labelbol AND labeltype=@labeltype);

INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'en',@labelbol,@en,@labeltype FROM DUAL
WHERE NOT EXISTS(SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol = @labelbol AND labeltype=@labeltype);
delimiter;

SET @labelbol='LBL_OTHER_SETTINGS';
SET @zh='其他设置';
SET @en='Other Settings';
SET @labeltype='fixedstr';
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'zh',@labelbol,@zh,@labeltype FROM DUAL
WHERE NOT EXISTS(SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol = @labelbol AND labeltype=@labeltype);

INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'en',@labelbol,@en,@labeltype FROM DUAL
WHERE NOT EXISTS(SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol = @labelbol AND labeltype=@labeltype);
delimiter;

UPDATE ld_settings_blocks_seq SET id=(SELECT max(blockid) FROM ld_settings_blocks);

UPDATE ld_settings_field SET blockid=0;
SET @i=0;
SET @blockid=1;
UPDATE ld_settings_field SET blockid=@blockid,sequence=(@i:=@i+1) WHERE `name`='VTLIB_LBL_MODULE_MANAGER';
UPDATE ld_settings_field SET blockid=@blockid,sequence=(@i:=@i+1) WHERE `name`='LBL_TABLIST';
UPDATE ld_settings_field SET blockid=@blockid,sequence=(@i:=@i+1) WHERE `name`='LBL_PAGE_SET';
UPDATE ld_settings_field SET blockid=@blockid,sequence=(@i:=@i+1) WHERE `name`='LBL_ProductTool_field';
UPDATE ld_settings_field SET blockid=@blockid,sequence=(@i:=@i+1) WHERE `name`='LBL_Optionalmodule_Customization';
UPDATE ld_settings_field SET blockid=@blockid,sequence=(@i:=@i+1) WHERE `name`='LBL_APPROVE';
UPDATE ld_settings_field SET blockid=@blockid,sequence=(@i:=@i+1) WHERE `name`='LBL_CUSTOMIZE_MODENT_NUMBER';
UPDATE ld_settings_field SET blockid=@blockid,sequence=(@i:=@i+1) WHERE `name`='LBL_PICKLIST_DEPENDENCY_SETUP';
UPDATE ld_settings_field SET blockid=@blockid,sequence=(@i:=@i+1) WHERE `name`='MobileAppMenuCustomization';
UPDATE ld_settings_field SET blockid=@blockid,sequence=(@i:=@i+1) WHERE `name`='MobileAppDataListCustomization';
delimiter;

SET @i=0;
SET @blockid=2;
UPDATE ld_settings_field SET blockid=@blockid,sequence=(@i:=@i+1) WHERE `name`='LBL_SYSTEM_SET';
UPDATE ld_settings_field SET blockid=@blockid,sequence=(@i:=@i+1) WHERE `name`='LBL_ACCOUNT_SET';
UPDATE ld_settings_field SET blockid=@blockid,sequence=(@i:=@i+1) WHERE `name`='LBL_SERVICE_PERFORMANCE_PARAMETERS';
UPDATE ld_settings_field SET blockid=@blockid,sequence=(@i:=@i+1) WHERE `name`='LBL_AUTOMATICREMINDS_SET';
UPDATE ld_settings_field SET blockid=@blockid,sequence=(@i:=@i+1) WHERE `name`='LBL_REMIND_SET';

SET @i=0;
SET @blockid=3;
UPDATE ld_settings_field SET blockid=@blockid,sequence=(@i:=@i+1) WHERE `name`='LBL_PRINT_TEMPLATE';
UPDATE ld_settings_field SET blockid=@blockid,sequence=(@i:=@i+1) WHERE `name`='THEDOCUMENTTEMPLATE';
UPDATE ld_settings_field SET blockid=@blockid,sequence=(@i:=@i+1) WHERE `name`='LBL_CALENDAR_TEMPLATE';
UPDATE ld_settings_field SET blockid=@blockid,sequence=(@i:=@i+1) WHERE `name`='LBL_WORK_TEMPLATE';
UPDATE ld_settings_field SET blockid=@blockid,sequence=(@i:=@i+1) WHERE `name`='LBL_TEMPLATES';

SET @i=0;
SET @blockid=4;
UPDATE ld_settings_field SET blockid=@blockid,sequence=(@i:=@i+1) WHERE `name`='LBL_DATAINTERFACE_SETTING';
UPDATE ld_settings_field SET blockid=@blockid,sequence=(@i:=@i+1) WHERE `name`='LBL_EXPANSION_CAMCARD';
UPDATE ld_settings_field SET blockid=@blockid,sequence=(@i:=@i+1) WHERE `name`='LBL_SMS_SETTINGS';
UPDATE ld_settings_field SET blockid=@blockid,sequence=(@i:=@i+1) WHERE `name`='LBL_MAIL_SERVER_SETTINGS';
UPDATE ld_settings_field SET blockid=@blockid,sequence=(@i:=@i+1) WHERE `name`='BANGWO8INTERFACE';
UPDATE ld_settings_field SET blockid=@blockid,sequence=(@i:=@i+1) WHERE `name`='LBL_PHONESTEWARD_SET';

SET @i=0;
SET @blockid=5;

UPDATE ld_settings_field SET blockid=@blockid,sequence=(@i:=@i+1) WHERE `name`='LBL_COMPANY_DETAILS';
UPDATE ld_settings_field SET blockid=@blockid,sequence=(@i:=@i+1) WHERE `name`='LBL_CURRENCY_SETTINGS';
UPDATE ld_settings_field SET blockid=@blockid,sequence=(@i:=@i+1) WHERE `name`='LBL_TAX_SETTINGS';
UPDATE ld_settings_field SET blockid=@blockid,sequence=(@i:=@i+1) WHERE `name`='LBL_WASEHOUSE';
UPDATE ld_settings_field SET blockid=@blockid,sequence=(@i:=@i+1) WHERE `name`='TRACKPOSITONINGGROUP';
UPDATE ld_settings_field SET blockid=@blockid,sequence=(@i:=@i+1) WHERE `name`='LBL_BACKUP_SET';
UPDATE ld_settings_field SET blockid=@blockid,sequence=(@i:=@i+1) WHERE `name`='LBL_AUTOMATIC_TASK';
UPDATE ld_settings_field SET blockid=@blockid,sequence=(@i:=@i+1) WHERE `name`='LBL_SHARING_ACCESS';
UPDATE ld_settings_field SET blockid=@blockid,sequence=(@i:=@i+1) WHERE `name`='LBL_LOGIN_HISTORY_DETAILS';
UPDATE ld_settings_field SET blockid=@blockid,sequence=(@i:=@i+1) WHERE `name`='LBL_ACCOUNTS_CONTACTS_FIELDS';

UPDATE ld_desk SET fieldlabel='首页组件模板定制' WHERE labelbol='LBL_TEMPLATES' AND languagetype='zh' AND Labeltype='fixedstr';
UPDATE ld_desk SET fieldlabel='工作汇报模板定制' WHERE labelbol='LBL_WORK_TEMPLATE' AND languagetype='zh' AND Labeltype='fixedstr';
UPDATE ld_desk SET fieldlabel='单据编号定制' WHERE labelbol='LBL_CUSTOMIZE_MODENT_NUMBER' AND languagetype='zh' AND Labeltype='fixedstr';
UPDATE ld_desk SET fieldlabel='呼叫中心参数设置' WHERE labelbol='LBL_PHONESTEWARD_SET' AND languagetype='zh' AND Labeltype='fixedstr';

UPDATE ld_desk SET fieldlabel='帮我吧接口设置' WHERE labelbol='BANGWO8INTERFACE' AND languagetype='zh' AND Labeltype='fixedstr';
UPDATE ld_desk SET fieldlabel='ERP接口设置' WHERE labelbol='LBL_DATAINTERFACE_SETTING' AND languagetype='zh' AND Labeltype='fixedstr';
UPDATE ld_desk SET fieldlabel='名片接口设置' WHERE labelbol='LBL_EXPANSION_CAMCARD' AND languagetype='zh' AND Labeltype='fixedstr';
UPDATE ld_desk SET fieldlabel='短信账户设置' WHERE labelbol='LBL_SMS_SETTINGS' AND languagetype='zh' AND Labeltype='fixedstr';
UPDATE ld_desk SET fieldlabel='邮件服务器设置' WHERE labelbol='LBL_MAIL_SERVER_SETTINGS' AND languagetype='zh' AND Labeltype='fixedstr';
UPDATE ld_desk SET fieldlabel='服务考核设置' WHERE labelbol='LBL_SERVICE_PERFORMANCE_PARAMETERS' AND languagetype='zh' AND Labeltype='fixedstr';

UPDATE ld_desk SET fieldlabel='登录日志查询' WHERE labelbol='LBL_LOGIN_HISTORY_DETAILS' AND languagetype='zh' AND Labeltype='fixedstr';
UPDATE ld_desk SET fieldlabel='数据库备份' WHERE labelbol='LBL_BACKUP_SET' AND languagetype='zh' AND Labeltype='fixedstr';
UPDATE ld_desk SET fieldlabel='级联字段定制' WHERE labelbol='LBL_PICKLIST_DEPENDENCY_SETUP' AND languagetype='zh' AND Labeltype='fixedstr';
delimiter;

DELETE FROM ld_settings_field WHERE `name`='LBL_AUTOMATIC_TASK' AND NOT EXISTS (SELECT 1 FROM ld_crmentity WHERE crmid>2); 
DELETE FROM ld_settings_field WHERE `name`='LBL_AUTOMATIC_TASK' AND NOT EXISTS (SELECT 1 FROM ld_version WHERE versiontype=1);


select max(tabsequence) into @tabsequence from ld_tab;
select max(tabid) into @tabid from ld_tab;
insert into ld_tab(tabid,name,presence,tabsequence,tablabel,printtab )
select @tabid+1,'ChinaMap',0,@tabsequence+1,'ChinaMap',1 from dual 
where not EXISTS(select 1 from ld_tab where name='ChinaMap');

select tabid into @tabid from ld_tab  where name='ChinaMap';
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'zh','ld_tab',@tabid,@tabid,'客户地图' from dual 
where not exists(select 1 from ld_tranlabel where tabid=@tabid and relateid=@tabid and languagetype='zh'and trantable='ld_tab' );
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'en','ld_tab',@tabid,@tabid,'China Map' from dual 
where not exists(select 1 from ld_tranlabel where tabid=@tabid and relateid=@tabid and languagetype='en' and trantable='ld_tab');
delimiter;

delete from ld_systems_deploy where deploy_type = 66;
delete from ld_tranlabel where tabid = 66 and relateid = 66 and trantable = 'ld_systems_deploy';
delimiter;
call AddColumn('ld_templatesstuff','presence','int','11',0);

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','transaction','交易','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype = 'zh' and labelbol = 'transaction' and labeltype = 'fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','transaction','交易','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype = 'en' and labelbol = 'transaction' and labeltype = 'fixedstr');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','saleskit','销售简报','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype = 'zh' and labelbol = 'saleskit' and labeltype = 'fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','saleskit','Sales Kit','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype = 'en' and labelbol = 'saleskit' and labeltype = 'fixedstr');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','availablecomponents','可用的组建','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype = 'zh' and labelbol = 'availablecomponents' and labeltype = 'fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','availablecomponents','Available Components','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype = 'en' and labelbol = 'availablecomponents' and labeltype = 'fixedstr');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','diplayorganizationandsequence','显示的组建及顺序','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype = 'zh' and labelbol = 'diplayorganizationandsequence' and labeltype = 'fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','diplayorganizationandsequence','Display organization and sequence','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype = 'en' and labelbol = 'diplayorganizationandsequence' and labeltype = 'fixedstr');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','homepagedisplaysettings','首页组建显示设置','jspop' from dual
where not exists(select 1 from ld_desk where languagetype = 'zh' and labelbol = 'homepagedisplaysettings' and labeltype = 'jspop');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','homepagedisplaysettings','Home page display settings','jspop' from dual
where not exists(select 1 from ld_desk where languagetype = 'en' and labelbol = 'homepagedisplaysettings' and labeltype = 'jspop');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','pleaseselectatleast','请至少选择一个组建！','jspop' from dual
where not exists(select 1 from ld_desk where languagetype = 'zh' and labelbol = 'pleaseselectatleast' and labeltype = 'jspop');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','pleaseselectatleast','Please select at least one build!','jspop' from dual
where not exists(select 1 from ld_desk where languagetype = 'en' and labelbol = 'pleaseselectatleast' and labeltype = 'jspop');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','ETC','等','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype = 'zh' and labelbol = 'ETC' and labeltype = 'fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','ETC',' etc ','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype = 'en' and labelbol = 'ETC' and labeltype = 'fixedstr');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','people','人','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype = 'zh' and labelbol = 'people' and labeltype = 'fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','people',' people','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype = 'en' and labelbol = 'people' and labeltype = 'fixedstr');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','thisyear1','本年度','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype = 'zh' and labelbol = 'thisyear1' and labeltype = 'fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','thisyear1',' This Year Quarter','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype = 'en' and labelbol = 'thisyear1' and labeltype = 'fixedstr');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','lastyear1','上年度','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype = 'zh' and labelbol = 'lastyear1' and labeltype = 'fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','lastyear1',' Last Year Quarter','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype = 'en' and labelbol = 'lastyear1' and labeltype = 'fixedstr');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','stagechange','阶段变化的','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype = 'zh' and labelbol = 'stagechange' and labeltype = 'fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','stagechange','Stage change ','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype = 'en' and labelbol = 'stagechange' and labeltype = 'fixedstr');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','receivablebalance','应收余额','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype = 'zh' and labelbol = 'receivablebalance' and labeltype = 'fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','receivablebalance','Receivable balance','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype = 'en' and labelbol = 'receivablebalance' and labeltype = 'fixedstr');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','Paymentplan','回款','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype = 'zh' and labelbol = 'Paymentplan' and labeltype = 'fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','Paymentplan','Payment','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype = 'en' and labelbol = 'Paymentplan' and labeltype = 'fixedstr');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','Payment1','退款','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype = 'zh' and labelbol = 'Payment1' and labeltype = 'fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','Payment1','SendPayment','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype = 'en' and labelbol = 'Payment1' and labeltype = 'fixedstr');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','Confirmed','已确认','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype = 'zh' and labelbol = 'Confirmed' and labeltype = 'fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','Confirmed','Confirmed','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype = 'en' and labelbol = 'Confirmed' and labeltype = 'fixedstr');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','tobeconfirmed','待确认','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype = 'zh' and labelbol = 'tobeconfirmed' and labeltype = 'fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','tobeconfirmed','To be confirmed','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype = 'en' and labelbol = 'tobeconfirmed' and labeltype = 'fixedstr');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','num','数','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype = 'zh' and labelbol = 'num' and labeltype = 'fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','num',' num','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype = 'en' and labelbol = 'num' and labeltype = 'fixedstr');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','cashbackdate','退款日期','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype = 'zh' and labelbol = 'cashbackdate' and labeltype = 'fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','cashbackdate','CashbackDate','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype = 'en' and labelbol = 'cashbackdate' and labeltype = 'fixedstr');
delimiter;

DELETE FROM ld_templatesstuff WHERE NOT EXISTS (SELECT 1 FROM ld_crmentity WHERE crmid>2);
DELETE FROM ld_templatesstuff WHERE EXISTS (SELECT 1 FROM ld_version WHERE versiontype=56);
delimiter;

delete from ld_systems_deploy where deploy_type = 78;
delete from ld_tranlabel where tabid = 78 and relateid = 78 and trantable = 'ld_systems_deploy';
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','News','消息','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype = 'zh' and labelbol = 'News' and labeltype = 'fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','News','News','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype = 'en' and labelbol = 'News' and labeltype = 'fixedstr');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','Documenthandling','单据处理','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype = 'zh' and labelbol = 'Documenthandling' and labeltype = 'fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','Documenthandling','Document handling','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype = 'en' and labelbol = 'Documenthandling' and labeltype = 'fixedstr');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','Startprocessing','开始处理','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype = 'zh' and labelbol = 'Startprocessing' and labeltype = 'fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','Startprocessing','Start processing','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype = 'en' and labelbol = 'Startprocessing' and labeltype = 'fixedstr');
delimiter;
-- 2017-11-28

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','selectmore','查看更多','jspop' from dual
where not exists(select 1 from ld_desk where languagetype = 'zh' and labelbol = 'selectmore' and labeltype = 'jspop');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','selectmore','Select more','jspop' from dual
where not exists(select 1 from ld_desk where languagetype = 'en' and labelbol = 'selectmore' and labeltype = 'jspop');
delimiter;

update ld_producttoolfield 
INNER JOIN(
	select tabid from ld_tab where `name` in ('SalesOrder','Quotes','QuotesChange','ServiceContracts')
) as tmp on tmp.tabid = ld_producttoolfield.tabid set defaultvalue = 1 where columnname = 'quantity' and defaultvalue ='';
delimiter;

SET @blockid=0;
SELECT blockid INTO @blockid FROM ld_appparenttab WHERE parenttab_label='Sales' AND systemdefault='yes';
SET @i=0;
UPDATE ld_appparenttabrel SET sequence=sequence+1 WHERE blockid=@blockid;
INSERT INTO ld_appparenttabrel(blockid,tabid,sequence)
SELECT @blockid,2,0 FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_appparenttabrel WHERE blockid=@blockid AND tabid=2);
UPDATE ld_appparenttabrel SET sequence=(@i:=@i+1) WHERE blockid=@blockid ORDER BY sequence;
delimiter;

SET @blockid=0;
SELECT blockid INTO @blockid FROM ld_appparenttab WHERE parenttab_label='OAForms' AND systemdefault='yes';
SET @i=0;
UPDATE ld_appparenttabrel SET sequence=sequence+1 WHERE blockid=@blockid;
INSERT INTO ld_appparenttabrel(blockid,tabid,sequence)
SELECT @blockid,-1,0 FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_appparenttabrel WHERE blockid=@blockid AND tabid=-1);
UPDATE ld_appparenttabrel SET sequence=(@i:=@i+1) WHERE blockid=@blockid ORDER BY sequence;
delimiter;

call AddColumn('ld_inventoryproductrelscf','prosheet','varchar','20',0);
delimiter;

select tabid into @tabid from ld_tab where `name`='QuotesChange';
select max(producttoolfieldid) into @producttoolfieldid from ld_producttoolfield;
select sequence into @sequence  from ld_producttoolfield where tabid = @tabid and columnname = 'pro_id';
update ld_producttoolfield set sequence = sequence + 1000 where tabid = @tabid and sequence > @sequence;
insert into ld_producttoolfield(producttoolfieldid,columnname,allowhide,fieldlabel,presence,uitype,typeofdata,sequence,tabid,tablename,width,edit_permission,input_type,fieldid,newline,
defaultcolumn,is_checkimportfield,nullfield,description)
select @producttoolfieldid+1,'prosheet','no','规格型号（变更前）',0,1,'V~M~100',@sequence+1,@tabid,'ld_inventoryproductrelscf',40,3,0,0,0,3,0,1,NULL from DUAL
where not exists(select 1 from ld_producttoolfield where tabid = @tabid and columnname = 'prosheet');
set @i=0;
update ld_producttoolfield set sequence=(@i:=@i+1) where tabid = @tabid order by sequence;
delimiter;

select tabid into @tabid from ld_tab where `name`='QuotesChange';
select producttoolfieldid into @producttoolfieldid from ld_producttoolfield where tabid = @tabid and columnname = 'prosheet';
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'zh','ld_producttoolfield',@tabid,@producttoolfieldid,'规格型号（变更前）' from DUAL
where not exists(select 1 from ld_tranlabel where tabid =@tabid and Relateid = @producttoolfieldid and languagetype = 'zh' and trantable = 'ld_producttoolfield');
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'en','ld_producttoolfield',@tabid,@producttoolfieldid,'ProductSheet(Before replacement)' from DUAL
where not exists(select 1 from ld_tranlabel where tabid =@tabid and Relateid = @producttoolfieldid and languagetype = 'en' and trantable = 'ld_producttoolfield');
delimiter;

select tabid into @tabid from ld_tab where `name` = 'QuotesChange';
update ld_producttoolfield set width = 40 where tabid = @tabid and columnname = 'productsheet' and tablename = 'ld_products';
select producttoolfieldid into @relateid from ld_producttoolfield where tabid = @tabid and columnname = 'productsheet' and tablename = 'ld_products';
update ld_tranlabel set fieldlabel = '规格型号（变更后）' where trantable = 'ld_producttoolfield' and tabid = @tabid and Relateid = @relateid and languagetype = 'zh';
delimiter;

update ld_desk set fieldlabel='工作汇报提交统计表' where labelbol='STATISTICALDAYLOG' and languagetype='zh';
delimiter;

update ld_templatesstuff set stufftitle = 'STATISTICALWEEKMONTH' where stuffid = 36 and stufftype = 'saleskit';
delimiter;

SET @minid=(SELECT MIN(relation_id) FROM ld_relatedlists WHERE tabid=20 AND related_tabid=37);
DELETE FROM ld_relatedlists WHERE tabid=20 AND related_tabid=37 AND relation_id<>@minid;
delimiter;
-- 2017-11-29

CALL addtableIndex('ld_modtracker_basic','crmid','crmid');
CALL addtableIndex('ld_modtracker_detail','idx_ld_modtracker_detail_id','id');
CALL del_idx('idx_ld_modtracker_detail_fieldname','ld_modtracker_detail');
delimiter;

update ld_inventoryproductrelscf set prosheet = pro_id where pro_id > 0;
delimiter;

DROP PROCEDURE IF EXISTS `AddColumn`;
delimiter ||
CREATE  PROCEDURE `AddColumn`(
	tablename VARCHAR(50),
	columnname VARCHAR(100),
	columntype VARCHAR(50),
	columnlen INT(5),
	moren VARCHAR(50)
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
			 IF moren IS NULL OR TRIM(moren)='' THEN
					SET @alterColumn=CONCAT(' alter table ',tablename, ' add column ',columnname, ' ',columntype,'(',columnlen,')',' default NULL');
				ELSE
					SET @alterColumn=CONCAT(' alter table ',tablename, ' add column ',columnname, ' ',columntype,'(',columnlen,')'," default '",moren,"'");
			 END IF;
		END IF;
	PREPARE stalter FROM @altercolumn;
		EXECUTE stalter;
	END IF;
end ||
delimiter;

CALL AddColumn('ld_cvcolumnlist_wx','showtag','VARCHAR','10','no');
delimiter;

insert into ld_links(tabid,linktype,linklabel,linkurl,description)
select '','Settings','AutomaticReminds','http://51mis.com.cn/forum.php?mod=viewthread&tid=33&highlight=%D7%D4%B6%AF%CC%E1%D0%D1','控制面板-自动提醒' from DUAL
where not exists(select 1 from ld_links where linktype = 'Settings' and linklabel = 'AutomaticReminds');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','LBL_ROLENAME_EXIST','角色已存在，请重新录入！','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype = 'zh' and labelbol = 'LBL_ROLENAME_EXIST' and labeltype = 'fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','LBL_ROLENAME_EXIST','Profilename lready exists, please re-entry!','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype = 'en' and labelbol = 'LBL_ROLENAME_EXIST' and labeltype = 'fixedstr');
delimiter;
-- 2017-11-30

DELETE FROM ld_field WHERE tablename='ldr_sobillads' AND presence=1;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','Receivables1','收款','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype = 'zh' and labelbol = 'Receivables1' and labeltype = 'fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','Receivables1','Receivables','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype = 'en' and labelbol = 'Receivables1' and labeltype = 'fixedstr');
delimiter;

DROP PROCEDURE IF EXISTS `rest_cvcolumnlist_wx`;
delimiter ||
CREATE  PROCEDURE `rest_cvcolumnlist_wx`(
	tmp_module VARCHAR(100),
	tmp_column VARCHAR(100),
	tmp_rownum INT(1),
	tmp_colnum INT(1),
	tmp_showtag VARCHAR(20),
	tmp_sysdefault VARCHAR(20)
)
BEGIN
	
	SET @columnname=(
		SELECT 
			CONCAT(b.tablename,':',b.columnname,':',b.fieldname,':',a.`name`,'_',b.fieldlabel,':',LEFT(b.typeofdata,1)) 
		FROM ld_tab a
		LEFT JOIN ld_field b ON a.tabid=b.tabid
		WHERE a.`name`=tmp_module
			AND b.columnname=tmp_column
		LIMIT 1);

	DELETE FROM ld_cvcolumnlist_wx WHERE modulename=tmp_module AND LOCATE(CONCAT(':',tmp_column,':'),columnname)>0;
	INSERT INTO ld_cvcolumnlist_wx(modulename,rownumber,listnumber,columnname,systemdefault,showtag)
	SELECT tmp_module,tmp_rownum,tmp_colnum,@columnname,tmp_sysdefault,tmp_showtag;

end ||
delimiter;


DROP PROCEDURE IF EXISTS `rest_cvcolumnlist_wx_newdatabase`;
delimiter ||
CREATE  PROCEDURE `rest_cvcolumnlist_wx_newdatabase`(
)
BEGIN
	
	IF 1=1 THEN
		SET @modulename='Accounts';
		DELETE FROM ld_cvcolumnlist_wx WHERE modulename=@modulename;
		CALL rest_cvcolumnlist_wx(@modulename,'accountname',1,1,'no','yes');
		CALL rest_cvcolumnlist_wx(@modulename,'bill_street',2,1,'no','yes');
		CALL rest_cvcolumnlist_wx(@modulename,'smownerid',3,1,'yes','yes');
		CALL rest_cvcolumnlist_wx(@modulename,'rating',3,2,'yes','yes');

		SET @modulename='Contacts';
		DELETE FROM ld_cvcolumnlist_wx WHERE modulename=@modulename;
		CALL rest_cvcolumnlist_wx(@modulename,'lastname',1,1,'no','yes');
		CALL rest_cvcolumnlist_wx(@modulename,'accountid',2,1,'no','yes');
		CALL rest_cvcolumnlist_wx(@modulename,'smownerid',3,1,'yes','yes');
		CALL rest_cvcolumnlist_wx(@modulename,'title',3,2,'yes','yes');

		SET @modulename='ContactRecords';
		DELETE FROM ld_cvcolumnlist_wx WHERE modulename=@modulename;
		CALL rest_cvcolumnlist_wx(@modulename,'accountid',1,1,'no','yes');
		CALL rest_cvcolumnlist_wx(@modulename,'smownerid',2,1,'yes','yes');
		CALL rest_cvcolumnlist_wx(@modulename,'contactdate',2,2,'yes','yes');
		CALL rest_cvcolumnlist_wx(@modulename,'content',3,1,'yes','yes');

		SET @modulename='ServiceContracts';
		DELETE FROM ld_cvcolumnlist_wx WHERE modulename=@modulename;
		CALL rest_cvcolumnlist_wx(@modulename,'contract_no',1,1,'yes','yes');
		CALL rest_cvcolumnlist_wx(@modulename,'accountid',2,1,'no','yes');
		CALL rest_cvcolumnlist_wx(@modulename,'smownerid',2,2,'yes','yes');
		CALL rest_cvcolumnlist_wx(@modulename,'total',3,1,'yes','yes');
		CALL rest_cvcolumnlist_wx(@modulename,'due_date',3,2,'yes','yes');

		SET @modulename='HelpDesk';
		DELETE FROM ld_cvcolumnlist_wx WHERE modulename=@modulename;
		CALL rest_cvcolumnlist_wx(@modulename,'ticket_no',1,1,'yes','yes');
		CALL rest_cvcolumnlist_wx(@modulename,'accountid',2,1,'no','yes');
		CALL rest_cvcolumnlist_wx(@modulename,'smownerid',2,2,'yes','yes');
		CALL rest_cvcolumnlist_wx(@modulename,'status',3,1,'yes','yes');
		CALL rest_cvcolumnlist_wx(@modulename,'hopetime',3,2,'yes','yes');

		SET @modulename='ServiceReturn';
		DELETE FROM ld_cvcolumnlist_wx WHERE modulename=@modulename;
		CALL rest_cvcolumnlist_wx(@modulename,'servicereturn_no',1,1,'yes','yes');
		CALL rest_cvcolumnlist_wx(@modulename,'accountid',2,1,'no','yes');
		CALL rest_cvcolumnlist_wx(@modulename,'smownerid',2,2,'yes','yes');

		SET @modulename='ServiceCharge';
		DELETE FROM ld_cvcolumnlist_wx WHERE modulename=@modulename;
		CALL rest_cvcolumnlist_wx(@modulename,'accountname',1,1,'no','yes');
		CALL rest_cvcolumnlist_wx(@modulename,'bill_street',2,1,'no','yes');
		CALL rest_cvcolumnlist_wx(@modulename,'smownerid',3,1,'yes','yes');
		CALL rest_cvcolumnlist_wx(@modulename,'lastservicedate',3,2,'yes','yes');

		SET @modulename='Campaigns';
		DELETE FROM ld_cvcolumnlist_wx WHERE modulename=@modulename;
		CALL rest_cvcolumnlist_wx(@modulename,'campaignname',1,1,'no','yes');
		CALL rest_cvcolumnlist_wx(@modulename,'smownerid',2,1,'yes','yes');
		CALL rest_cvcolumnlist_wx(@modulename,'campaignstatus',2,2,'yes','yes');
		CALL rest_cvcolumnlist_wx(@modulename,'startdate',3,1,'yes','yes');
		CALL rest_cvcolumnlist_wx(@modulename,'closingdate',3,2,'yes','yes');

		SET @modulename='Potentials';
		DELETE FROM ld_cvcolumnlist_wx WHERE modulename=@modulename;
		CALL rest_cvcolumnlist_wx(@modulename,'potentialname',1,1,'no','yes');
		CALL rest_cvcolumnlist_wx(@modulename,'accountid',2,1,'no','yes');
		CALL rest_cvcolumnlist_wx(@modulename,'smownerid',2,2,'yes','yes');
		CALL rest_cvcolumnlist_wx(@modulename,'amount',3,1,'yes','yes');
		CALL rest_cvcolumnlist_wx(@modulename,'sales_stage',3,2,'yes','yes');

		SET @modulename='Quotes';
		DELETE FROM ld_cvcolumnlist_wx WHERE modulename=@modulename;
		CALL rest_cvcolumnlist_wx(@modulename,'quote_no',1,1,'yes','yes');
		CALL rest_cvcolumnlist_wx(@modulename,'accountid',2,1,'no','yes');
		CALL rest_cvcolumnlist_wx(@modulename,'smownerid',2,2,'yes','yes');
		CALL rest_cvcolumnlist_wx(@modulename,'total',3,1,'yes','yes');
		CALL rest_cvcolumnlist_wx(@modulename,'validtill',3,2,'yes','yes');

		SET @modulename='QuotesChange';
		DELETE FROM ld_cvcolumnlist_wx WHERE modulename=@modulename;
		CALL rest_cvcolumnlist_wx(@modulename,'quoteschange_no',1,1,'yes','yes');
		CALL rest_cvcolumnlist_wx(@modulename,'accountid',2,1,'no','yes');
		CALL rest_cvcolumnlist_wx(@modulename,'smownerid',2,2,'yes','yes');
		CALL rest_cvcolumnlist_wx(@modulename,'change_type',3,1,'yes','yes');
		CALL rest_cvcolumnlist_wx(@modulename,'change_date',3,2,'yes','yes');

		SET @modulename='SalesOrder';
		DELETE FROM ld_cvcolumnlist_wx WHERE modulename=@modulename;
		CALL rest_cvcolumnlist_wx(@modulename,'salesorder_no',1,1,'yes','yes');
		CALL rest_cvcolumnlist_wx(@modulename,'accountid',2,1,'no','yes');
		CALL rest_cvcolumnlist_wx(@modulename,'smownerid',2,2,'yes','yes');
		CALL rest_cvcolumnlist_wx(@modulename,'total',3,1,'yes','yes');
		CALL rest_cvcolumnlist_wx(@modulename,'signed_data',3,2,'yes','yes');

		SET @modulename='Vendors';
		DELETE FROM ld_cvcolumnlist_wx WHERE modulename=@modulename;
		CALL rest_cvcolumnlist_wx(@modulename,'vendorname',1,1,'no','yes');
		CALL rest_cvcolumnlist_wx(@modulename,'smownerid',2,1,'yes','yes');

		SET @modulename='VendorContact';
		DELETE FROM ld_cvcolumnlist_wx WHERE modulename=@modulename;
		CALL rest_cvcolumnlist_wx(@modulename,'lastname',1,1,'no','yes');
		CALL rest_cvcolumnlist_wx(@modulename,'vendorid',2,1,'no','yes');
		CALL rest_cvcolumnlist_wx(@modulename,'smownerid',2,2,'yes','yes');

		SET @modulename='VendorContactRecords';
		DELETE FROM ld_cvcolumnlist_wx WHERE modulename=@modulename;
		CALL rest_cvcolumnlist_wx(@modulename,'vendorid',1,1,'no','yes');
		CALL rest_cvcolumnlist_wx(@modulename,'smownerid',2,1,'yes','yes');
		CALL rest_cvcolumnlist_wx(@modulename,'contactdate',2,2,'yes','yes');
		CALL rest_cvcolumnlist_wx(@modulename,'description',3,1,'yes','yes');


		SET @modulename='PurchaseOrder';
		DELETE FROM ld_cvcolumnlist_wx WHERE modulename=@modulename;
		CALL rest_cvcolumnlist_wx(@modulename,'purchaseorder_no',1,1,'yes','yes');
		CALL rest_cvcolumnlist_wx(@modulename,'vendorid',2,1,'no','yes');
		CALL rest_cvcolumnlist_wx(@modulename,'smownerid',2,2,'yes','yes');
		CALL rest_cvcolumnlist_wx(@modulename,'total',3,1,'yes','yes');
		CALL rest_cvcolumnlist_wx(@modulename,'signed_data',3,2,'yes','yes');

		SET @modulename='Project';
		DELETE FROM ld_cvcolumnlist_wx WHERE modulename=@modulename;
		CALL rest_cvcolumnlist_wx(@modulename,'projectname',1,1,'no','yes');
		CALL rest_cvcolumnlist_wx(@modulename,'accountid',2,1,'no','yes');
		CALL rest_cvcolumnlist_wx(@modulename,'project_no',2,2,'yes','yes');
		CALL rest_cvcolumnlist_wx(@modulename,'smownerid',3,1,'yes','yes');
		CALL rest_cvcolumnlist_wx(@modulename,'projectstatus',3,2,'yes','yes');

		SET @modulename='ProjectTask';
		DELETE FROM ld_cvcolumnlist_wx WHERE modulename=@modulename;
		CALL rest_cvcolumnlist_wx(@modulename,'projecttaskname',1,1,'no','yes');
		CALL rest_cvcolumnlist_wx(@modulename,'accountid',2,1,'no','yes');
		CALL rest_cvcolumnlist_wx(@modulename,'projecttask_no',2,2,'yes','yes');
		CALL rest_cvcolumnlist_wx(@modulename,'smownerid',3,1,'yes','yes');
		CALL rest_cvcolumnlist_wx(@modulename,'projecttaskstatus',3,2,'yes','yes');

		SET @modulename='ProjectProgress';
		DELETE FROM ld_cvcolumnlist_wx WHERE modulename=@modulename;
		CALL rest_cvcolumnlist_wx(@modulename,'projectprogress_no',1,1,'yes','yes');
		CALL rest_cvcolumnlist_wx(@modulename,'smownerid',2,1,'yes','yes');
		CALL rest_cvcolumnlist_wx(@modulename,'projectid',2,2,'yes','yes');

		SET @modulename='ProjectMilestone';
		DELETE FROM ld_cvcolumnlist_wx WHERE modulename=@modulename;
		CALL rest_cvcolumnlist_wx(@modulename,'projectmilestonename',1,1,'no','yes');
		CALL rest_cvcolumnlist_wx(@modulename,'projectid',2,1,'yes','yes');
		CALL rest_cvcolumnlist_wx(@modulename,'smownerid',3,1,'yes','yes');
		CALL rest_cvcolumnlist_wx(@modulename,'projectmilestonedate',3,2,'yes','yes');

		SET @modulename='TimeSheet';
		DELETE FROM ld_cvcolumnlist_wx WHERE modulename=@modulename;
		CALL rest_cvcolumnlist_wx(@modulename,'timesheet_no',1,1,'yes','yes');
		CALL rest_cvcolumnlist_wx(@modulename,'total',2,1,'yes','yes');
		CALL rest_cvcolumnlist_wx(@modulename,'smownerid',2,2,'yes','yes');

		SET @modulename='Rate';
		DELETE FROM ld_cvcolumnlist_wx WHERE modulename=@modulename;
		CALL rest_cvcolumnlist_wx(@modulename,'ratename',1,1,'no','yes');
		CALL rest_cvcolumnlist_wx(@modulename,'rate',2,1,'yes','yes');
		CALL rest_cvcolumnlist_wx(@modulename,'smownerid',2,2,'yes','yes');

		SET @modulename='OutboundOrder';
		DELETE FROM ld_cvcolumnlist_wx WHERE modulename=@modulename;
		CALL rest_cvcolumnlist_wx(@modulename,'out_no',1,1,'yes','yes');
		CALL rest_cvcolumnlist_wx(@modulename,'accountid',2,1,'no','yes');
		CALL rest_cvcolumnlist_wx(@modulename,'smownerid',2,2,'yes','yes');
		CALL rest_cvcolumnlist_wx(@modulename,'total',3,1,'no','yes');
		CALL rest_cvcolumnlist_wx(@modulename,'outdate',3,2,'yes','yes');

		SET @modulename='Stock';
		DELETE FROM ld_cvcolumnlist_wx WHERE modulename=@modulename;
		CALL rest_cvcolumnlist_wx(@modulename,'ware_stock_no',1,1,'yes','yes');
		CALL rest_cvcolumnlist_wx(@modulename,'vendorid',2,1,'no','yes');
		CALL rest_cvcolumnlist_wx(@modulename,'smownerid',2,2,'yes','yes');
		CALL rest_cvcolumnlist_wx(@modulename,'total',3,1,'no','yes');
		CALL rest_cvcolumnlist_wx(@modulename,'createdate',3,2,'yes','yes');

		SET @modulename='Invoice';
		DELETE FROM ld_cvcolumnlist_wx WHERE modulename=@modulename;
		CALL rest_cvcolumnlist_wx(@modulename,'invoice_no',1,1,'yes','yes');
		CALL rest_cvcolumnlist_wx(@modulename,'accountid',2,1,'no','yes');
		CALL rest_cvcolumnlist_wx(@modulename,'smownerid',2,2,'yes','yes');
		CALL rest_cvcolumnlist_wx(@modulename,'total',3,1,'no','yes');
		CALL rest_cvcolumnlist_wx(@modulename,'invoicedate',3,2,'yes','yes');

		SET @modulename='CashBill';
		DELETE FROM ld_cvcolumnlist_wx WHERE modulename=@modulename;
		CALL rest_cvcolumnlist_wx(@modulename,'cashbill_no',1,1,'yes','yes');
		CALL rest_cvcolumnlist_wx(@modulename,'accountid',2,1,'no','yes');
		CALL rest_cvcolumnlist_wx(@modulename,'smownerid',2,2,'yes','yes');
		CALL rest_cvcolumnlist_wx(@modulename,'total',3,1,'no','yes');
		CALL rest_cvcolumnlist_wx(@modulename,'cashbilldate',3,2,'yes','yes');

		SET @modulename='PublicAnnouncement';
		DELETE FROM ld_cvcolumnlist_wx WHERE modulename=@modulename;
		CALL rest_cvcolumnlist_wx(@modulename,'subject',1,1,'no','yes');
		CALL rest_cvcolumnlist_wx(@modulename,'smownerid',2,1,'yes','yes');
		CALL rest_cvcolumnlist_wx(@modulename,'startdate',3,1,'no','yes');

		SET @modulename='PaymentPlan';
		DELETE FROM ld_cvcolumnlist_wx WHERE modulename=@modulename;
		CALL rest_cvcolumnlist_wx(@modulename,'paymentplan_no',1,1,'yes','yes');
		CALL rest_cvcolumnlist_wx(@modulename,'accountid',2,1,'no','yes');
		CALL rest_cvcolumnlist_wx(@modulename,'smownerid',2,2,'yes','yes');
		CALL rest_cvcolumnlist_wx(@modulename,'total',3,1,'yes','yes');
		CALL rest_cvcolumnlist_wx(@modulename,'plandate',3,2,'yes','yes');

		SET @modulename='NormalApprove';
		DELETE FROM ld_cvcolumnlist_wx WHERE modulename=@modulename;
		CALL rest_cvcolumnlist_wx(@modulename,'normalapprove_no',1,1,'yes','yes');
		CALL rest_cvcolumnlist_wx(@modulename,'smownerid',2,1,'yes','yes');
		CALL rest_cvcolumnlist_wx(@modulename,'approvestatus',2,2,'yes','yes');
		CALL rest_cvcolumnlist_wx(@modulename,'description',3,1,'yes','yes');

		SET @modulename='AddJobBill';
		DELETE FROM ld_cvcolumnlist_wx WHERE modulename=@modulename;
		CALL rest_cvcolumnlist_wx(@modulename,'addjobbill_no',1,1,'yes','yes');
		CALL rest_cvcolumnlist_wx(@modulename,'smownerid',2,1,'yes','yes');
		CALL rest_cvcolumnlist_wx(@modulename,'approvestatus',2,2,'yes','yes');
		CALL rest_cvcolumnlist_wx(@modulename,'total',3,1,'yes','yes');

		SET @modulename='MinusJobBill';
		DELETE FROM ld_cvcolumnlist_wx WHERE modulename=@modulename;
		CALL rest_cvcolumnlist_wx(@modulename,'minusjobbill_no',1,1,'yes','yes');
		CALL rest_cvcolumnlist_wx(@modulename,'smownerid',2,1,'yes','yes');
		CALL rest_cvcolumnlist_wx(@modulename,'approvestatus',2,2,'yes','yes');
		CALL rest_cvcolumnlist_wx(@modulename,'total',3,1,'yes','yes');

		SET @modulename='BusinessApply';
		DELETE FROM ld_cvcolumnlist_wx WHERE modulename=@modulename;
		CALL rest_cvcolumnlist_wx(@modulename,'businessapply_no',1,1,'yes','yes');
		CALL rest_cvcolumnlist_wx(@modulename,'accountid',2,1,'no','yes');
		CALL rest_cvcolumnlist_wx(@modulename,'smownerid',2,2,'yes','yes');
		CALL rest_cvcolumnlist_wx(@modulename,'total',3,1,'yes','yes');
		CALL rest_cvcolumnlist_wx(@modulename,'approvestatus',3,2,'yes','yes');

		SET @modulename='LoanApply';
		DELETE FROM ld_cvcolumnlist_wx WHERE modulename=@modulename;
		CALL rest_cvcolumnlist_wx(@modulename,'loanapply_no',1,1,'yes','yes');
		CALL rest_cvcolumnlist_wx(@modulename,'smownerid',2,1,'yes','yes');
		CALL rest_cvcolumnlist_wx(@modulename,'approvestatus',2,2,'yes','yes');
		CALL rest_cvcolumnlist_wx(@modulename,'loanmoney',3,1,'yes','yes');
		CALL rest_cvcolumnlist_wx(@modulename,'paymentdate',3,2,'yes','yes');

		SET @modulename='CardApply';
		DELETE FROM ld_cvcolumnlist_wx WHERE modulename=@modulename;
		CALL rest_cvcolumnlist_wx(@modulename,'cardapply_no',1,1,'yes','yes');
		CALL rest_cvcolumnlist_wx(@modulename,'smownerid',2,1,'yes','yes');
		CALL rest_cvcolumnlist_wx(@modulename,'approvestatus',2,2,'yes','yes');
		CALL rest_cvcolumnlist_wx(@modulename,'printnum',3,1,'yes','yes');
		CALL rest_cvcolumnlist_wx(@modulename,'applydate',3,2,'yes','yes');

		SET @modulename='Commission';
		DELETE FROM ld_cvcolumnlist_wx WHERE modulename=@modulename;
		CALL rest_cvcolumnlist_wx(@modulename,'commission_no',1,1,'yes','yes');
		CALL rest_cvcolumnlist_wx(@modulename,'accountid',2,1,'no','yes');
		CALL rest_cvcolumnlist_wx(@modulename,'smownerid',2,2,'yes','yes');
		CALL rest_cvcolumnlist_wx(@modulename,'total',3,1,'yes','yes');
		CALL rest_cvcolumnlist_wx(@modulename,'expensedate',3,2,'yes','yes');

		SET @modulename='Expense';
		DELETE FROM ld_cvcolumnlist_wx WHERE modulename=@modulename;
		CALL rest_cvcolumnlist_wx(@modulename,'expense_no',1,1,'yes','yes');
		CALL rest_cvcolumnlist_wx(@modulename,'accountid',2,1,'no','yes');
		CALL rest_cvcolumnlist_wx(@modulename,'smownerid',2,2,'yes','yes');
		CALL rest_cvcolumnlist_wx(@modulename,'total',3,1,'yes','yes');
		CALL rest_cvcolumnlist_wx(@modulename,'expensedate',3,2,'yes','yes');

		SET @modulename='ModComments';
		DELETE FROM ld_cvcolumnlist_wx WHERE modulename=@modulename;
		CALL rest_cvcolumnlist_wx(@modulename,'commentcontent',1,1,'no','yes');
		CALL rest_cvcolumnlist_wx(@modulename,'smownerid',2,1,'yes','yes');
		CALL rest_cvcolumnlist_wx(@modulename,'related_to',2,2,'yes','yes');

		SET @modulename='Products';
		DELETE FROM ld_cvcolumnlist_wx WHERE modulename=@modulename;
		CALL rest_cvcolumnlist_wx(@modulename,'productname',1,1,'no','yes');
		CALL rest_cvcolumnlist_wx(@modulename,'productsheet',2,1,'yes','yes');
		CALL rest_cvcolumnlist_wx(@modulename,'product_no',2,2,'yes','yes');
	END IF;
end ||
delimiter;

CALL rest_cvcolumnlist_wx_newdatabase();
delimiter;

DROP PROCEDURE IF EXISTS `rest_cvcolumnlist_wx_newdatabase`;
delimiter;

SET @tabid=(SELECT tabid FROM ld_tab WHERE name='BusinessApply');
SET @fieldid=(SELECT fieldid FROM ld_field WHERE tabid=@tabid AND columnname='total');
UPDATE ld_tranlabel SET fieldlabel='合计天数' WHERE trantable='ld_field' AND tabid=@tabid AND Relateid=@fieldid AND languagetype='zh';

INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','MOBILELISTSHOWFIELDNAME','是否显示字段名称','fixedstr'
from dual where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='MOBILELISTSHOWFIELDNAME' and labeltype='fixedstr');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','MOBILELISTSHOWFIELDNAME','Display Enabled Field Name','fixedstr'
from dual where not exists(select 1 from ld_desk where languagetype='en' and labelbol='MOBILELISTSHOWFIELDNAME' and labeltype='fixedstr');
delimiter;

DROP PROCEDURE IF EXISTS `ldcrm_reset_appparenttab`;
delimiter ||
CREATE PROCEDURE `ldcrm_reset_appparenttab`(
)
BEGIN

	IF EXISTS (SELECT 1 FROM ld_version WHERE versiontype IN (55,56,57,58)) AND NOT EXISTS (SELECT 1 FROM ld_account) THEN
	  SET @blockid=0;
		SELECT blockid INTO @blockid FROM ld_appparenttab WHERE parenttab_label='Accounts' AND systemdefault='yes';
		DELETE FROM ld_appparenttabrel WHERE blockid=@blockid;
		SET @i=0;
		INSERT INTO ld_appparenttabrel(blockid,tabid,sequence)
		SELECT @blockid,6,(@i:=@i+1);
		INSERT INTO ld_appparenttabrel(blockid,tabid,sequence)
		SELECT @blockid,4,(@i:=@i+1);
		INSERT INTO ld_appparenttabrel(blockid,tabid,sequence)
		SELECT @blockid,(SELECT tabid FROM ld_tab WHERE `name`='ContactRecords'),(@i:=@i+1);
		INSERT INTO ld_appparenttabrel(blockid,tabid,sequence)
		SELECT @blockid,-2,(@i:=@i+1);


    SET @blockid=0;
		SELECT blockid INTO @blockid FROM ld_appparenttab WHERE parenttab_label='Sales' AND systemdefault='yes';
		DELETE FROM ld_appparenttabrel WHERE blockid=@blockid;
		SET @i=0;
		INSERT INTO ld_appparenttabrel(blockid,tabid,sequence)
		SELECT @blockid,2,(@i:=@i+1);
		INSERT INTO ld_appparenttabrel(blockid,tabid,sequence)
		SELECT @blockid,22,(@i:=@i+1);
		INSERT INTO ld_appparenttabrel(blockid,tabid,sequence)
		SELECT @blockid,23,(@i:=@i+1);
		INSERT INTO ld_appparenttabrel(blockid,tabid,sequence)
		SELECT @blockid,(SELECT tabid FROM ld_tab WHERE `name`='CashBill'),(@i:=@i+1);
        
    SET @blockid=0;
		SELECT blockid INTO @blockid FROM ld_appparenttab WHERE parenttab_label='OAForms' AND systemdefault='yes';
		UPDATE ld_appparenttab SET blockname='汇报审批' WHERE blockid=@blockid AND blockname IN ('OA表单','申报中心');
		DELETE FROM ld_appparenttabrel WHERE blockid=@blockid;
		SET @i=0;
		INSERT INTO ld_appparenttabrel(blockid,tabid,sequence)
		SELECT @blockid,-1,(@i:=@i+1);
		INSERT INTO ld_appparenttabrel(blockid,tabid,sequence)
		SELECT @blockid,(SELECT tabid FROM ld_tab WHERE `name`='AddJobBill'),(@i:=@i+1);
		INSERT INTO ld_appparenttabrel(blockid,tabid,sequence)
		SELECT @blockid,(SELECT tabid FROM ld_tab WHERE `name`='MinusJobBill'),(@i:=@i+1);
		INSERT INTO ld_appparenttabrel(blockid,tabid,sequence)
		SELECT @blockid,(SELECT tabid FROM ld_tab WHERE `name`='BusinessApply'),(@i:=@i+1);
		INSERT INTO ld_appparenttabrel(blockid,tabid,sequence)
		SELECT @blockid,(SELECT tabid FROM ld_tab WHERE `name`='LoanApply'),(@i:=@i+1);
		INSERT INTO ld_appparenttabrel(blockid,tabid,sequence)
		SELECT @blockid,(SELECT tabid FROM ld_tab WHERE `name`='CardApply'),(@i:=@i+1);
		INSERT INTO ld_appparenttabrel(blockid,tabid,sequence)
		SELECT @blockid,(SELECT tabid FROM ld_tab WHERE `name`='Commission'),(@i:=@i+1);
		INSERT INTO ld_appparenttabrel(blockid,tabid,sequence)
		SELECT @blockid,(SELECT tabid FROM ld_tab WHERE `name`='Expense'),(@i:=@i+1);



    SET @blockid=0;
		SELECT parenttabid INTO @blockid FROM ld_parenttab WHERE parenttab_label='My Home Page';
		DELETE FROM ld_parenttabrel WHERE parenttabid=@blockid;
		SET @i=0;
		INSERT INTO ld_parenttabrel(parenttabid,tabid,sequence)
		SELECT @blockid,3,(@i:=@i+1);

        SET @blockid=0;
		SELECT parenttabid INTO @blockid FROM ld_parenttab WHERE parenttab_label='Parent Accounts';
		DELETE FROM ld_parenttabrel WHERE parenttabid=@blockid;
		SET @i=0;
		INSERT INTO ld_parenttabrel(parenttabid,tabid,sequence)
		SELECT @blockid,6,(@i:=@i+1);
		INSERT INTO ld_parenttabrel(parenttabid,tabid,sequence)
		SELECT @blockid,4,(@i:=@i+1);
		INSERT INTO ld_parenttabrel(parenttabid,tabid,sequence)
		SELECT @blockid,(SELECT tabid FROM ld_tab WHERE `name`='ContactRecords'),(@i:=@i+1);

    SET @blockid=0;
		SELECT parenttabid INTO @blockid FROM ld_parenttab WHERE parenttab_label='Sales';
		DELETE FROM ld_parenttabrel WHERE parenttabid=@blockid;
		SET @i=0;
		INSERT INTO ld_parenttabrel(parenttabid,tabid,sequence)
		SELECT @blockid,2,(@i:=@i+1);
		INSERT INTO ld_parenttabrel(parenttabid,tabid,sequence)
		SELECT @blockid,22,(@i:=@i+1);
		INSERT INTO ld_parenttabrel(parenttabid,tabid,sequence)
		SELECT @blockid,23,(@i:=@i+1);
		INSERT INTO ld_parenttabrel(parenttabid,tabid,sequence)
		SELECT @blockid,(SELECT tabid FROM ld_tab WHERE `name`='CashBill'),(@i:=@i+1);
		INSERT INTO ld_parenttabrel(parenttabid,tabid,sequence)
		SELECT @blockid,14,(@i:=@i+1);

    SET @blockid=0;
		SELECT parenttabid INTO @blockid FROM ld_parenttab WHERE parenttab_label='OAForms';
		UPDATE ld_tranlabel SET fieldlabel='汇报审批' WHERE Relateid=@blockid AND trantable='ld_parenttab' AND languagetype='zh' AND fieldlabel='OA表单';
		DELETE FROM ld_parenttabrel WHERE parenttabid=@blockid;
		SET @i=0;
		INSERT INTO ld_parenttabrel(parenttabid,tabid,sequence)
		SELECT @blockid,-1,(@i:=@i+1);
		INSERT INTO ld_parenttabrel(parenttabid,tabid,sequence)
		SELECT @blockid,(SELECT tabid FROM ld_tab WHERE `name`='AddJobBill'),(@i:=@i+1);
		INSERT INTO ld_parenttabrel(parenttabid,tabid,sequence)
		SELECT @blockid,(SELECT tabid FROM ld_tab WHERE `name`='MinusJobBill'),(@i:=@i+1);
		INSERT INTO ld_parenttabrel(parenttabid,tabid,sequence)
		SELECT @blockid,(SELECT tabid FROM ld_tab WHERE `name`='BusinessApply'),(@i:=@i+1);
		INSERT INTO ld_parenttabrel(parenttabid,tabid,sequence)
		SELECT @blockid,(SELECT tabid FROM ld_tab WHERE `name`='LoanApply'),(@i:=@i+1);
		INSERT INTO ld_parenttabrel(parenttabid,tabid,sequence)
		SELECT @blockid,(SELECT tabid FROM ld_tab WHERE `name`='CardApply'),(@i:=@i+1);
		INSERT INTO ld_parenttabrel(parenttabid,tabid,sequence)
		SELECT @blockid,(SELECT tabid FROM ld_tab WHERE `name`='Commission'),(@i:=@i+1);
		INSERT INTO ld_parenttabrel(parenttabid,tabid,sequence)
		SELECT @blockid,(SELECT tabid FROM ld_tab WHERE `name`='Expense'),(@i:=@i+1);

    SET @blockid=0;
		SELECT parenttabid INTO @blockid FROM ld_parenttab WHERE parenttab_label='Parent Reports';
		DELETE FROM ld_parenttabrel WHERE parenttabid=@blockid AND tabid=(SELECT tabid FROM ld_tab WHERE `name`='Comprehensivereport');
		DELETE FROM ld_parenttabrel WHERE parenttabid=@blockid AND tabid=(SELECT tabid FROM ld_tab WHERE `name`='Customreport');

		UPDATE ld_parenttab SET visible=1 WHERE parenttab_label='Finacial';
		UPDATE ld_tab SET presence=5 WHERE `name` IN('AddJobBill','MinusJobBill','LoanApply') AND presence=0;

END IF;

END ||
delimiter;

CALL ldcrm_reset_appparenttab();
delimiter;

DROP PROCEDURE IF EXISTS `ldcrm_reset_appparenttab`;
delimiter;

SET @blockid=(SELECT blockid FROM ld_appparenttab WHERE parenttab_label='OAForms' AND systemdefault='yes');
UPDATE ld_appparenttab SET blockname='汇报审批' WHERE blockid=@blockid AND blockname IN ('OA表单','申报中心','申请汇报')
	AND EXISTS (SELECT 1 FROM ld_version WHERE versiontype IN (55,56,57,58));

SELECT parenttabid INTO @blockid FROM ld_parenttab WHERE parenttab_label='OAForms';
UPDATE ld_tranlabel SET fieldlabel='汇报审批' WHERE Relateid=@blockid AND trantable='ld_parenttab' AND languagetype='zh' AND fieldlabel IN ('OA表单','申报中心','申请汇报')
	AND EXISTS (SELECT 1 FROM ld_version WHERE versiontype IN (55,56,57,58));
    
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','MOBILELISTSHOWFIELDNAME','是否显示字段名称','fixedstr'
from dual where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='MOBILELISTSHOWFIELDNAME' and labeltype='fixedstr');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','MOBILELISTSHOWFIELDNAME','Display Enabled Field Name','fixedstr'
from dual where not exists(select 1 from ld_desk where languagetype='en' and labelbol='MOBILELISTSHOWFIELDNAME' and labeltype='fixedstr');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','Audited','已审核','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype = 'zh' and labelbol = 'Audited' and labeltype = 'fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','Audited','Audited','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype = 'en' and labelbol = 'Audited' and labeltype = 'fixedstr');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','Unaudited','未审核','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype = 'zh' and labelbol = 'Unaudited' and labeltype = 'fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','Unaudited','Unaudited','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype = 'en' and labelbol = 'Unaudited' and labeltype = 'fixedstr');
delimiter;

UPDATE ld_field SET allowhide='yes' WHERE allowhide='no' AND columnname='accountid' AND tablename<>'ld_account';
UPDATE ld_field SET allowhide='yes' WHERE allowhide='no' AND columnname like '%status%' AND tablename<>'ld_users';
UPDATE ld_field SET allowhide='yes' WHERE allowhide='no' AND columnname like '%date';
UPDATE ld_field SET allowhide='yes' WHERE tabid=2 AND columnname IN ('amount','closingdate','currency_id');
UPDATE ld_field SET allowhide='yes' WHERE tabid=13 AND columnname IN ('category','servicetype');
UPDATE ld_field SET allowhide='yes' WHERE tabid=14 AND columnname IN ('productsheet');
UPDATE ld_field SET allowhide='yes' WHERE columnname='currency_id' AND tablename IN ('ld_cashbill','ld_sendcashbill');
-- 2017-12-01
SET FOREIGN_KEY_CHECKS=1;

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

update ld_version set old_version='V7.1.1',current_version='V7.1.1',remark='V7.1.1-20171201',wx_version='V6';
delimiter;