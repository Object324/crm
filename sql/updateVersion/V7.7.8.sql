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



DROP PROCEDURE IF EXISTS `AddPrimaryKey`;
delimiter ||
CREATE  PROCEDURE `AddPrimaryKey`(
	tmp_tablename varchar(100),
	tmp_prikeyname varchar(100)
)
BEGIN
 

	IF EXISTS (SELECT 1 FROM INFORMATION_SCHEMA.KEY_COLUMN_USAGE WHERE TABLE_SCHEMA=DATABASE() AND CONSTRAINT_NAME='PRIMARY' AND TABLE_NAME=tmp_tablename) THEN
		SET @mysql=CONCAT('ALTER TABLE `',tmp_tablename,'` DROP PRIMARY KEY,ADD PRIMARY KEY (`',tmp_prikeyname,'`)');
		PREPARE mystatement FROM @mysql;
		EXECUTE mystatement;
		DEALLOCATE PREPARE mystatement;
	ELSE
		SET @mysql=CONCAT('ALTER TABLE `',tmp_tablename,'` ADD PRIMARY KEY (`',tmp_prikeyname,'`)');
		PREPARE mystatement FROM @mysql;
		EXECUTE mystatement;
		DEALLOCATE PREPARE mystatement;
	END IF;

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

UPDATE ld_producttoolfield SET defaultvalue=NULL WHERE tablename='ld_checksdetail' AND defaultvalue=0 AND columnname='remark';
-- 2019-05-31

insert into ld_desk (languagetype,labelbol,fieldlabel,labeltype)
select 'zh','DATASCOPESETTINGS','数据范围设置','fixedstr' from dual 
where not exists(select 1 from ld_desk where languagetype='zh' and labeltype='fixedstr' and labelbol='DATASCOPESETTINGS');
delimiter;

insert into ld_desk (languagetype,labelbol,fieldlabel,labeltype)
select 'en','DATASCOPESETTINGS','Data Scope Settings','fixedstr' from dual 
where not exists(select 1 from ld_desk where languagetype='en' and labeltype='fixedstr' and labelbol='DATASCOPESETTINGS');
delimiter;
-- 2019-06-03


CALl AddColumn('ld_paymentplan','approvetime','datetime','',NULL);
delimiter;

CALl AddColumn('ld_paymentplan','approvestatus','varchar','100',NULL);
delimiter;

CALl AddColumn('ld_paymentplan','currentapprover','varchar','1000',NULL);
delimiter;

CALl AddColumn('ld_paymentplan','approveby','int','19',NULL);
delimiter;


CALl AddColumn('ld_sendpayment','approvetime','datetime','',NULL);
delimiter;

CALl AddColumn('ld_sendpayment','approvestatus','varchar','100',NULL);
delimiter;

CALl AddColumn('ld_sendpayment','currentapprover','varchar','1000',NULL);
delimiter;

CALl AddColumn('ld_sendpayment','approveby','int','19',NULL);
delimiter;

select sequence into @sequence from ld_systems_deploy where roottype=3 and deploy_type=171;
update ld_systems_deploy set sequence=@sequence+2 where roottype=3 and sequence>=@sequence;

insert into ld_systems_deploy(deploy_value,deploy_type,description,setype,sequence,roottype,inputtype,presence,inputvalue)
select 1,202,'回款计划是否启用审批流程','PaymentPlan',@sequence,3,'select',0,'[{"value":"0","text":"YES"},{"value":"1","text":"NO"},{"sql":""}]'
from dual where not exists(select 1 from ld_systems_deploy where deploy_type=202);

insert into ld_systems_deploy(deploy_value,deploy_type,description,setype,sequence,roottype,inputtype,presence,inputvalue)
select 1,203,'付款计划是否启用审批流程','SendPayment',@sequence+1,3,'select',0,'[{"value":"0","text":"YES"},{"value":"1","text":"NO"},{"sql":""}]'
from dual where not exists(select 1 from ld_systems_deploy where deploy_type=203);

select tabid into @tabid  from ld_tab where name='paymentplan';
select blockid into @blockid from ld_blocks where tabid=@tabid and blocklabel='LBL_PaymentPlan_INFORMATION';
select max(sequence) into @maxsequence from ld_field where tabid=@tabid and block=@blockid;
select max(fieldid) into @maxfieldid from ld_field;
update ld_field_seq set id=@maxfieldid+1 where not exists(select 1 from ld_field where tabid=@tabid and columnname='approveby');
insert into ld_field (tabid,fieldid,columnname,allowhide,tablename,generatedtype,uitype,fieldname,fieldlabel,presence,defaultvalue,sequence,block,displaytype,typeofdata)
select @tabid,@maxfieldid+1,'approveby','yes','ld_paymentplan',1,131,'approveby','上一步审批人',1,'',@maxsequence+1,@blockid,2,'V~o' from dual 
where not exists(select 1 from ld_field where tabid=@tabid and columnname='approveby');
delimiter;

select tabid into @tabid  from ld_tab where name='paymentplan';
select blockid into @blockid from ld_blocks where tabid=@tabid and blocklabel='LBL_PaymentPlan_INFORMATION';
select max(sequence) into @maxsequence from ld_field where tabid=@tabid and block=@blockid;
select max(fieldid) into @maxfieldid from ld_field;
update ld_field_seq set id=@maxfieldid+1 where not exists(select 1 from ld_field where tabid=@tabid and columnname='currentapprover');
insert into ld_field (tabid,fieldid,columnname,allowhide,tablename,generatedtype,uitype,fieldname,fieldlabel,presence,defaultvalue,sequence,block,displaytype,typeofdata)
select @tabid,@maxfieldid+1,'currentapprover','yes','ld_paymentplan',1,132,'currentapprover','当前审批人',1,'',@maxsequence+1,@blockid,2,'V~o' from dual 
where not exists(select 1 from ld_field where tabid=@tabid and columnname='currentapprover');
delimiter;

select tabid into @tabid  from ld_tab where name='paymentplan';
select blockid into @blockid from ld_blocks where tabid=@tabid and blocklabel='LBL_PaymentPlan_INFORMATION';
select max(sequence) into @maxsequence from ld_field where tabid=@tabid and block=@blockid;
select max(fieldid) into @maxfieldid from ld_field;
update ld_field_seq set id=@maxfieldid+1 where not exists(select 1 from ld_field where tabid=@tabid and columnname='approvetime');
insert into ld_field (tabid,fieldid,columnname,allowhide,tablename,generatedtype,uitype,fieldname,fieldlabel,presence,defaultvalue,sequence,block,displaytype,typeofdata)
select @tabid,@maxfieldid+1,'approvetime','yes','ld_paymentplan',1,70,'approvetime','最新审批时间',1,'',@maxsequence+1,@blockid,2,'DT~o' from dual 
where not exists(select 1 from ld_field where tabid=@tabid and columnname='approvetime');
delimiter;

select tabid into @tabid  from ld_tab where name='paymentplan';
select blockid into @blockid from ld_blocks where tabid=@tabid and blocklabel='LBL_PaymentPlan_INFORMATION';
select max(sequence) into @maxsequence from ld_field where tabid=@tabid and block=@blockid;
select max(fieldid) into @maxfieldid from ld_field;
update ld_field_seq set id=@maxfieldid+1 where not exists(select 1 from ld_field where tabid=@tabid and columnname='approvestatus');
insert into ld_field (tabid,fieldid,columnname,allowhide,tablename,generatedtype,uitype,fieldname,fieldlabel,presence,defaultvalue,sequence,block,displaytype,typeofdata)
select @tabid,@maxfieldid+1,'approvestatus','yes','ld_paymentplan',1,609,'approvestatus','审批状态',1,'',@maxsequence+1,@blockid,2,'V~o' from dual 
where not exists(select 1 from ld_field where tabid=@tabid and columnname='approvestatus');
delimiter;

select tabid into @tabid  from ld_tab where name='SendPayment';
select blockid into @blockid from ld_blocks where tabid=@tabid and blocklabel='LBL_SendPayment_INFORMATION';
select max(sequence) into @maxsequence from ld_field where tabid=@tabid and block=@blockid;
select max(fieldid) into @maxfieldid from ld_field;
update ld_field_seq set id=@maxfieldid+1 where not exists(select 1 from ld_field where tabid=@tabid and columnname='approveby');
insert into ld_field (tabid,fieldid,columnname,allowhide,tablename,generatedtype,uitype,fieldname,fieldlabel,presence,defaultvalue,sequence,block,displaytype,typeofdata)
select @tabid,@maxfieldid+1,'approveby','yes','ld_sendpayment',1,131,'approveby','上一步审批人',1,'',@maxsequence+1,@blockid,2,'V~o' from dual 
where not exists(select 1 from ld_field where tabid=@tabid and columnname='approveby');
delimiter;

select tabid into @tabid  from ld_tab where name='SendPayment';
select blockid into @blockid from ld_blocks where tabid=@tabid and blocklabel='LBL_SendPayment_INFORMATION';
select max(sequence) into @maxsequence from ld_field where tabid=@tabid and block=@blockid;
select max(fieldid) into @maxfieldid from ld_field;
update ld_field_seq set id=@maxfieldid+1 where not exists(select 1 from ld_field where tabid=@tabid and columnname='currentapprover');
insert into ld_field (tabid,fieldid,columnname,allowhide,tablename,generatedtype,uitype,fieldname,fieldlabel,presence,defaultvalue,sequence,block,displaytype,typeofdata)
select @tabid,@maxfieldid+1,'currentapprover','yes','ld_sendpayment',1,132,'currentapprover','当前审批人',1,'',@maxsequence+1,@blockid,2,'V~o' from dual 
where not exists(select 1 from ld_field where tabid=@tabid and columnname='currentapprover');
delimiter;

select tabid into @tabid  from ld_tab where name='SendPayment';
select blockid into @blockid from ld_blocks where tabid=@tabid and blocklabel='LBL_SendPayment_INFORMATION';
select max(sequence) into @maxsequence from ld_field where tabid=@tabid and block=@blockid;
select max(fieldid) into @maxfieldid from ld_field;
update ld_field_seq set id=@maxfieldid+1 where not exists(select 1 from ld_field where tabid=@tabid and columnname='approvetime');
insert into ld_field (tabid,fieldid,columnname,allowhide,tablename,generatedtype,uitype,fieldname,fieldlabel,presence,defaultvalue,sequence,block,displaytype,typeofdata)
select @tabid,@maxfieldid+1,'approvetime','yes','ld_sendpayment',1,70,'approvetime','最新审批时间',1,'',@maxsequence+1,@blockid,2,'DT~o' from dual 
where not exists(select 1 from ld_field where tabid=@tabid and columnname='approvetime');
delimiter;

select tabid into @tabid  from ld_tab where name='SendPayment';
select blockid into @blockid from ld_blocks where tabid=@tabid and blocklabel='LBL_SendPayment_INFORMATION';
select max(sequence) into @maxsequence from ld_field where tabid=@tabid and block=@blockid;
select max(fieldid) into @maxfieldid from ld_field;
update ld_field_seq set id=@maxfieldid+1 where not exists(select 1 from ld_field where tabid=@tabid and columnname='approvestatus');
insert into ld_field (tabid,fieldid,columnname,allowhide,tablename,generatedtype,uitype,fieldname,fieldlabel,presence,defaultvalue,sequence,block,displaytype,typeofdata)
select @tabid,@maxfieldid+1,'approvestatus','yes','ld_sendpayment',1,609,'approvestatus','审批状态',1,'',@maxsequence+1,@blockid,2,'V~o' from dual 
where not exists(select 1 from ld_field where tabid=@tabid and columnname='approvestatus');
delimiter;

select tabid into @tabid  from ld_tab where name='paymentplan';
select fieldid into @fieldid from ld_field where tabid=@tabid and columnname='approveby';
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'zh','ld_field' ,@tabid,@fieldid,'上一步审批人' from dual 
where not exists(select 1 from ld_tranlabel where languagetype='zh'  and relateid=@fieldid and trantable='ld_field');

insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'en','ld_field' ,@tabid,@fieldid,'The Last Approver' from dual 
where not exists(select 1 from ld_tranlabel where languagetype='en'  and relateid=@fieldid and trantable='ld_field');
delimiter;


select tabid into @tabid  from ld_tab where name='paymentplan';
select fieldid into @fieldid from ld_field where tabid=@tabid and columnname='currentapprover';
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'zh','ld_field' ,@tabid,@fieldid,'当前审批人' from dual 
where not exists(select 1 from ld_tranlabel where languagetype='zh'  and relateid=@fieldid and trantable='ld_field');

insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'en','ld_field' ,@tabid,@fieldid,'Current Approver' from dual 
where not exists(select 1 from ld_tranlabel where languagetype='en'  and relateid=@fieldid and trantable='ld_field');
delimiter;

select tabid into @tabid  from ld_tab where name='paymentplan';
select fieldid into @fieldid from ld_field where tabid=@tabid and columnname='approvetime';
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'zh','ld_field' ,@tabid,@fieldid,'最新审批时间' from dual 
where not exists(select 1 from ld_tranlabel where languagetype='zh'  and relateid=@fieldid and trantable='ld_field');

insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'en','ld_field' ,@tabid,@fieldid,'Last approval time' from dual 
where not exists(select 1 from ld_tranlabel where languagetype='en'  and relateid=@fieldid and trantable='ld_field');
delimiter;

select tabid into @tabid  from ld_tab where name='paymentplan';
select fieldid into @fieldid from ld_field where tabid=@tabid and columnname='approvestatus';
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'zh','ld_field' ,@tabid,@fieldid,'审批状态' from dual 
where not exists(select 1 from ld_tranlabel where languagetype='zh'  and relateid=@fieldid and trantable='ld_field');

insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'en','ld_field' ,@tabid,@fieldid,'Approve Status' from dual 
where not exists(select 1 from ld_tranlabel where languagetype='en'  and relateid=@fieldid and trantable='ld_field');
delimiter;


select tabid into @tabid  from ld_tab where name='SendPayment';
select fieldid into @fieldid from ld_field where tabid=@tabid and columnname='approveby';
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'zh','ld_field' ,@tabid,@fieldid,'上一步审批人' from dual 
where not exists(select 1 from ld_tranlabel where languagetype='zh'  and relateid=@fieldid and trantable='ld_field');

insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'en','ld_field' ,@tabid,@fieldid,'The Last Approver' from dual 
where not exists(select 1 from ld_tranlabel where languagetype='en'  and relateid=@fieldid and trantable='ld_field');
delimiter;

select tabid into @tabid  from ld_tab where name='SendPayment';
select fieldid into @fieldid from ld_field where tabid=@tabid and columnname='currentapprover';
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'zh','ld_field' ,@tabid,@fieldid,'当前审批人' from dual 
where not exists(select 1 from ld_tranlabel where languagetype='zh'  and relateid=@fieldid and trantable='ld_field');

insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'en','ld_field' ,@tabid,@fieldid,'Current Approver' from dual 
where not exists(select 1 from ld_tranlabel where languagetype='en'  and relateid=@fieldid and trantable='ld_field');
delimiter;

select tabid into @tabid  from ld_tab where name='SendPayment';
select fieldid into @fieldid from ld_field where tabid=@tabid and columnname='approvetime';
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'zh','ld_field' ,@tabid,@fieldid,'最新审批时间' from dual 
where not exists(select 1 from ld_tranlabel where languagetype='zh'  and relateid=@fieldid and trantable='ld_field');

insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'en','ld_field' ,@tabid,@fieldid,'Last approval time' from dual 
where not exists(select 1 from ld_tranlabel where languagetype='en'  and relateid=@fieldid and trantable='ld_field');
delimiter;

select tabid into @tabid  from ld_tab where name='SendPayment';
select fieldid into @fieldid from ld_field where tabid=@tabid and columnname='approvestatus';
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'zh','ld_field' ,@tabid,@fieldid,'审批状态' from dual 
where not exists(select 1 from ld_tranlabel where languagetype='zh'  and relateid=@fieldid and trantable='ld_field');

insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'en','ld_field' ,@tabid,@fieldid,'Approve Status' from dual 
where not exists(select 1 from ld_tranlabel where languagetype='en'  and relateid=@fieldid and trantable='ld_field');
delimiter;

call fieldprofile('Paymenplan');
delimiter;
call fieldprofile('SendPayment');
delimiter;

insert into ld_links(tabid,linktype,linklabel,linkurl,description)
select 0,'Module','module_products','http://51mis.com.cn/forum.php?mod=viewthread&tid=452&fromuid=1','产品明细' from DUAL
where not exists(select 1 from ld_links where linktype = 'Module' and linklabel = 'module_products');
delimiter;

CALL addtableIndex('ld_customform11detail','id','id');
CALL addtableIndex('ld_customform11detail','productid','productid');

CALL addtableIndex('ld_customform12detail','id','id');
CALL addtableIndex('ld_customform12detail','productid','productid');

CALL addtableIndex('ld_customform13detail','id','id');
CALL addtableIndex('ld_customform13detail','productid','productid');

CALL addtableIndex('ld_customform14detail','id','id');
CALL addtableIndex('ld_customform14detail','productid','productid');

CALL addtableIndex('ld_customform15detail','id','id');
CALL addtableIndex('ld_customform15detail','productid','productid');

CALL addtableIndex('ld_customform16detail','id','id');
CALL addtableIndex('ld_customform16detail','productid','productid');

CALL addtableIndex('ld_customform17detail','id','id');
CALL addtableIndex('ld_customform17detail','productid','productid');

CALL addtableIndex('ld_customform18detail','id','id');
CALL addtableIndex('ld_customform18detail','productid','productid');

CALL addtableIndex('ld_customform19detail','id','id');
CALL addtableIndex('ld_customform19detail','productid','productid');

CALL addtableIndex('ld_customform20detail','id','id');
CALL addtableIndex('ld_customform20detail','productid','productid');
-- 2019-06-05

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

UPDATE ld_version SET old_version='V7.7.8',current_version='V7.7.8',remark='V7.7.8-20190605',wx_version='V7.7.7.1';
delimiter;