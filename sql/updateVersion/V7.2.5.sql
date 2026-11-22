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

SET @tabid=(SELECT tabid FROM ld_tab WHERE `name`='CashBill');
UPDATE ld_field SET quickcreate=1 WHERE tabid=@tabid AND columnname='cashbill_no';
UPDATE ld_field SET quickcreate=0 WHERE tabid=@tabid AND columnname IN ('description','paymentmethod');
UPDATE ld_field SET quickcreate=1,typeofdata='V~O' WHERE tabid=@tabid AND columnname='cashbill_no';
UPDATE ld_field SET quickcreate=1,typeofdata='V~O' WHERE tabid=@tabid AND columnname='cashtype';
UPDATE ld_field SET typeofdata='V~O' WHERE tabid=@tabid AND columnname='bankaccountsetid';

UPDATE ld_producttoolfield SET defaultvalue='' WHERE columnname='entitytypeid' AND defaultvalue=1;
UPDATE ld_producttoolfield SET defaultvalue=1 WHERE tabid=23 AND columnname='quantity';
UPDATE ld_producttoolfield SET defaultvalue=0 WHERE tabid=23 AND columnname IN ('tax_amount','taxprice','listprice');

UPDATE ld_field SET presence=0 WHERE columnname='description' AND tabid=22 AND NOT EXISTS (SELECT 1 FROM ld_salesorder);
UPDATE ld_field SET presence=0 WHERE columnname='description' AND tabid=23 AND NOT EXISTS (SELECT 1 FROM ld_invoice);
UPDATE ld_field SET presence=0 WHERE columnname='description' AND tabid=37 AND NOT EXISTS (SELECT 1 FROM ld_servicecontracts);


SET @fieldid=(SELECT fieldid FROM ld_field WHERE tabid=2 AND columnname='callhigh');
UPDATE ld_tranlabel SET fieldlabel='拜访高层（老板）' WHERE Relateid=@fieldid AND languagetype='zh' AND fieldlabel='Call high(见老板)';
delimiter;

UPDATE ld_modentity_num SET isallow=1 WHERE semodule='SalesOrder' AND NOT EXISTS (SELECT 1 FROM ld_salesorder);
UPDATE ld_modentity_num SET isallow=1 WHERE semodule='Invoice' AND NOT EXISTS (SELECT 1 FROM ld_invoice);
UPDATE ld_modentity_num SET isallow=1 WHERE semodule='ServiceContracts' AND NOT EXISTS (SELECT 1 FROM ld_servicecontracts);

UPDATE ld_field SET quickcreate=1,typeofdata='V~O' WHERE tabid=22 AND columnname='salesorder_no'
	AND NOT EXISTS (SELECT 1 FROM ld_salesorder);
UPDATE ld_field SET quickcreate=1,typeofdata='V~O' WHERE tablename='ld_invoice' AND columnname='invoice_no'
	AND NOT EXISTS (SELECT 1 FROM ld_invoice);
UPDATE ld_field SET quickcreate=1,typeofdata='V~O' WHERE tablename='ld_addjobbill' AND columnname='expense_no'
	AND NOT EXISTS (SELECT 1 FROM ld_addjobbill);
UPDATE ld_field SET quickcreate=1,typeofdata='V~O' WHERE tablename='ld_minusjobbill' AND columnname='minusjobbill_no'
	AND NOT EXISTS (SELECT 1 FROM ld_minusjobbill);
UPDATE ld_field SET quickcreate=1,typeofdata='V~O' WHERE tablename='ld_businessapply' AND columnname='businessapply_no'
	AND NOT EXISTS (SELECT 1 FROM ld_businessapply);
UPDATE ld_field SET quickcreate=1,typeofdata='V~O' WHERE tablename='ld_quoteschange' AND columnname='quoteschange_no'
	AND NOT EXISTS (SELECT 1 FROM ld_quoteschange);

DROP PROCEDURE IF EXISTS `ldcrm_addpermission_bytabaction`;
delimiter ||
CREATE PROCEDURE `ldcrm_addpermission_bytabaction`(
	tmp_profileid INT(19),
	tmp_modulename VARCHAR(100),
	tmp_actionname VARCHAR(100)
)
BEGIN

	SET @tabid=(SELECT tabid FROM ld_tab WHERE `name`=tmp_modulename);
	SET @actionid=(SELECT actionid FROM ld_actionmapping WHERE actionname=tmp_actionname);

	INSERT INTO ld_profile2tab(profileid,tabid,permissions)
	SELECT tmp_profileid,@tabid,0 FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM ld_profile2tab WHERE profileid=tmp_profileid AND tabid=@tabid);

	UPDATE ld_profile2tab SET permissions=0 WHERE profileid=tmp_profileid AND tabid=@tabid AND permissions=1;

	IF EXISTS (SELECT 1 FROM ld_profileallpermission WHERE tabid=@tabid AND operation=@actionid) THEN
		INSERT INTO ld_profile2standardpermissions(profileid,tabid,operation,permissions,sequence)
		SELECT tmp_profileid,tabid,operation,0,sequence FROM ld_profileallpermission WHERE tabid=@tabid AND operation=@actionid
			AND NOT EXISTS (SELECT 1 FROM ld_profile2standardpermissions WHERE profileid=tmp_profileid AND tabid=@tabid AND operation=@actionid);

		UPDATE ld_profile2standardpermissions SET permissions=0 WHERE profileid=tmp_profileid AND tabid=@tabid AND operation=@actionid;
	END IF;

end ||
delimiter;

DROP PROCEDURE IF EXISTS `ldcrm_edit_saleser_permission`;
delimiter ||
CREATE PROCEDURE `ldcrm_edit_saleser_permission`(
)
BEGIN

	IF NOT EXISTS (SELECT 1 FROM ld_version_firstlogin) OR EXISTS (SELECT 1 FROM ld_version WHERE versiontype=56) THEN
		IF EXISTS (SELECT profileid FROM ld_profile WHERE profilename='销售人员') THEN
			SET @profileid=(SELECT profileid FROM ld_profile WHERE profilename='销售人员' LIMIT 1);
			CALL ldcrm_addpermission_bytabaction(@profileid,'Invoice','Create');
			CALL ldcrm_addpermission_bytabaction(@profileid,'Invoice','EditView');
			CALL ldcrm_addpermission_bytabaction(@profileid,'Invoice','Copy');

			CALL ldcrm_addpermission_bytabaction(@profileid,'CashBill','Create');
			CALL ldcrm_addpermission_bytabaction(@profileid,'CashBill','EditView');
			CALL ldcrm_addpermission_bytabaction(@profileid,'CashBill','Copy');

			CALL ldcrm_addpermission_bytabaction(@profileid,'Products','Create');
			CALL ldcrm_addpermission_bytabaction(@profileid,'Products','EditView');
			CALL ldcrm_addpermission_bytabaction(@profileid,'Products','Copy');
		END IF;
	END IF;

end ||
delimiter;

CALL ldcrm_edit_saleser_permission();
DROP PROCEDURE IF EXISTS `ldcrm_edit_saleser_permission`;

UPDATE ld_field SET presence=1 WHERE tabid=23 AND columnname IN ('invoicestatus','invoice_num') AND NOT EXISTS (SELECT 1 FROM ld_invoice);
UPDATE ld_field SET presence=1 WHERE tabid=22 AND columnname IN ('contactid','sostatus') AND NOT EXISTS (SELECT 1 FROM ld_salesorder);

UPDATE ld_field SET defaultvalue=1 WHERE tabid=29 AND columnname IN ('viewothers','editothers','edit_me_mobile','accountallview');
UPDATE ld_users SET viewothers=1,editothers=1,edit_me_mobile=1,accountallview=1 WHERE id=1;

UPDATE ld_field SET presence=1 WHERE tabid=2 AND columnname IN ('5w2p_why1','5w2p_plan1','5w2p_plan2','5w2p_why2','5w2p_why3','5w2p_why4','5w2p_why5','swort_s',
	'swort_w','swort_o','swort_t') AND NOT EXISTS (SELECT 1 FROM ld_potential);

SET @fieldid=(SELECT fieldid FROM ld_field WHERE tabid=2 AND columnname='potentialname');
UPDATE ld_tranlabel SET fieldlabel='机会名称' WHERE tabid=2 AND Relateid=@fieldid AND fieldlabel='销售机会';
delimiter;

UPDATE ld_field SET quickcreate=1 WHERE uitype=4 AND NOT EXISTS (SELECT 1 FROM ld_version_firstlogin);
DELETE FROM ld_usageunit WHERE usageunit NOT IN ('件','箱','个','台','套','只','千克') AND NOT EXISTS (SELECT 1 FROM ld_version_firstlogin);

UPDATE ld_field SET presence=1,typeofdata='V~O',quickcreate=1 WHERE tabid=2 AND columnname='potentialname'
	AND NOT EXISTS (SELECT 1 FROM ld_potential);

UPDATE ld_entityname SET fieldname='potential_no' WHERE modulename='Potentials'
	AND NOT EXISTS (SELECT 1 FROM ld_potential);

update ld_systems_deploy set inputvalue = '[{"value":"0","text":"YES"},{"value":"1","text":"NO"},{"sql":""},{"or_relatedmodule":"SalesOrder,Quotes"}]' where deploy_type = 79;
delimiter;

update ld_tranlabel set fieldlabel = '中{$Products.Products}单价自动根据客户最近购买记录带出'
where Relateid = 79 and tabid = 79 and trantable = 'ld_systems_deploy' and languagetype = 'zh';
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','Reminder1','温馨提示','jspop' from dual
where not exists(select 1 from ld_desk where languagetype = 'zh' and labelbol = 'Reminder1' and labeltype = 'jspop');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','Reminder1',"Reminder",'jspop' from dual
where not exists(select 1 from ld_desk where languagetype = 'en' and labelbol = 'Reminder1' and labeltype = 'jspop');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','youhavechangedcustomname','您更改了客户名称，是否需要更新产品价格？','jspop' from dual
where not exists(select 1 from ld_desk where languagetype = 'zh' and labelbol = 'youhavechangedcustomname' and labeltype = 'jspop');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','youhavechangedcustomname',"You have changed custom name, do you need to reset the price of the products?",'jspop' from dual
where not exists(select 1 from ld_desk where languagetype = 'en' and labelbol = 'youhavechangedcustomname' and labeltype = 'jspop');
delimiter;

update ld_desk set fieldlabel = '重复时导入方式' where labelbol = 'REPEAT_IMPORT_MODE' and languagetype = 'zh' and Labeltype = 'fixedstr';
update ld_desk set fieldlabel = ' repeat import mode' where labelbol = 'REPEAT_IMPORT_MODE' and languagetype = 'en' and Labeltype = 'fixedstr';
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','howtodowhentheproductsisnotexists','设置{$Products.Products}不存在时导入方式','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype = 'zh' and labelbol = 'howtodowhentheproductsisnotexists' and labeltype = 'fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','howtodowhentheproductsisnotexists',"How to do when the {$Products.Products} is not exists",'fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype = 'en' and labelbol = 'howtodowhentheproductsisnotexists' and labeltype = 'fixedstr');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','Ignoretheproducts','该行不导入','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype = 'zh' and labelbol = 'Ignoretheproducts' and labeltype = 'fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','Ignoretheproducts',"Ignore the products",'fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype = 'en' and labelbol = 'Ignoretheproducts' and labeltype = 'fixedstr');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','Ignoretheorder','整单不导入','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype = 'zh' and labelbol = 'Ignoretheorder' and labeltype = 'fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','Ignoretheorder',"Ignore the order",'fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype = 'en' and labelbol = 'Ignoretheorder' and labeltype = 'fixedstr');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','Automaticallyaddproducts','自动添加新产品','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype = 'zh' and labelbol = 'Automaticallyaddproducts' and labeltype = 'fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','Automaticallyaddproducts',"Automatically add products",'fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype = 'en' and labelbol = 'Automaticallyaddproducts' and labeltype = 'fixedstr');
delimiter;

call AddColumn('ld_importcheckdupfields','product_import_type','varchar','100',NULL);
delimiter;

update ld_importcheckdupfields set product_import_type = 'AddProduct' where product_import_type is NULL;
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','onlyallowedtodeliverafter','该客户在%s之后才允许发货，保存失败！','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype = 'zh' and labelbol = 'onlyallowedtodeliverafter' and labeltype = 'fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','onlyallowedtodeliverafter',"You are only allowed to deliver after %s!",'fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype = 'en' and labelbol = 'onlyallowedtodeliverafter' and labeltype = 'fixedstr');
delimiter;

select sequence,roottype into @sequence,@roottype from ld_systems_deploy  where deploy_type=16 ;
update ld_systems_deploy set sequence=sequence+1000 where roottype=@roottype and sequence>@sequence;
insert into ld_systems_deploy(deploy_value,deploy_type,description,setype,sequence,roottype,inputtype,presence,inputvalue)
select '1',153,'报价单审批通过后才允许打印','',@sequence+1,@roottype,'select',0,'[{"value":"0","text":"YES"},{"value":"1","text":"NO"},{"sql":""}]'
from dual where not exists(select 1 from ld_systems_deploy where roottype=@roottype and deploy_type = 153);

insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'zh','ld_systems_deploy',153,153,'{$Quotes.Quotes}审批通过后才允许打印' from DUAL
where not exists(select 1 from ld_tranlabel where languagetype='zh' and trantable='ld_systems_deploy' and relateid=153 and tabid = 153);
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'en','ld_systems_deploy',153,153,'The {$Quotes.Quotes} is allowed to be printed before it is allowed to print' from DUAL
where not exists(select 1 from ld_tranlabel where languagetype='en' and trantable='ld_systems_deploy' and relateid=153 and tabid = 153);

insert into ld_systems_deploy(deploy_value,deploy_type,description,setype,sequence,roottype,inputtype,presence,inputvalue)
select '1',154,'合同订单审批完成后，显示打印','',@sequence+2,@roottype,'select',0,'[{"value":"0","text":"YES"},{"value":"1","text":"NO"},{"sql":""}]'
from dual where not exists(select 1 from ld_systems_deploy where roottype=@roottype and deploy_type = 154);

insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'zh','ld_systems_deploy',154,154,'{$SalesOrder.SalesOrder}审批通过后才允许打印' from DUAL
where not exists(select 1 from ld_tranlabel where languagetype='zh' and trantable='ld_systems_deploy' and relateid=154 and tabid = 154);
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'en','ld_systems_deploy',154,154,'The {$SalesOrder.SalesOrder} is allowed to be printed before it is allowed to print' from DUAL
where not exists(select 1 from ld_tranlabel where languagetype='en' and trantable='ld_systems_deploy' and relateid=154 and tabid = 154);

insert into ld_systems_deploy(deploy_value,deploy_type,description,setype,sequence,roottype,inputtype,presence,inputvalue)
select '1',155,'服务合同审批通过后才允许打印','',@sequence+3,@roottype,'select',0,'[{"value":"0","text":"YES"},{"value":"1","text":"NO"},{"sql":""}]'
from dual where not exists(select 1 from ld_systems_deploy where roottype=@roottype and deploy_type = 155);

insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'zh','ld_systems_deploy',155,155,'{$ServiceContracts.ServiceContracts}审批通过后才允许打印' from DUAL
where not exists(select 1 from ld_tranlabel where languagetype='zh' and trantable='ld_systems_deploy' and relateid=155 and tabid = 155);
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'en','ld_systems_deploy',155,155,'The {$ServiceContracts.ServiceContracts} is allowed to be printed before it is allowed to print' from DUAL
where not exists(select 1 from ld_tranlabel where languagetype='en' and trantable='ld_systems_deploy' and relateid=155 and tabid = 155);

insert into ld_systems_deploy(deploy_value,deploy_type,description,setype,sequence,roottype,inputtype,presence,inputvalue)
select '1',156,'采购订单审批通过后才允许打印','',@sequence+4,@roottype,'select',0,'[{"value":"0","text":"YES"},{"value":"1","text":"NO"},{"sql":""}]'
from dual where not exists(select 1 from ld_systems_deploy where roottype=@roottype and deploy_type = 156);

insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'zh','ld_systems_deploy',156,156,'{$PurchaseOrder.PurchaseOrder}审批通过后才允许打印' from DUAL
where not exists(select 1 from ld_tranlabel where languagetype='zh' and trantable='ld_systems_deploy' and relateid=156 and tabid = 156);
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'en','ld_systems_deploy',156,156,'The {$PurchaseOrder.PurchaseOrder} is allowed to be printed before it is allowed to print' from DUAL
where not exists(select 1 from ld_tranlabel where languagetype='en' and trantable='ld_systems_deploy' and relateid=156 and tabid = 156);

insert into ld_systems_deploy(deploy_value,deploy_type,description,setype,sequence,roottype,inputtype,presence,inputvalue)
select '1',157,'出库单审批通过后才允许打印','',@sequence+5,@roottype,'select',0,'[{"value":"0","text":"YES"},{"value":"1","text":"NO"},{"sql":""}]'
from dual where not exists(select 1 from ld_systems_deploy where roottype=@roottype and deploy_type = 157);

insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'zh','ld_systems_deploy',157,157,'{$OutboundOrder.OutboundOrder}审批通过后才允许打印' from DUAL
where not exists(select 1 from ld_tranlabel where languagetype='zh' and trantable='ld_systems_deploy' and relateid=157 and tabid = 157);
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'en','ld_systems_deploy',157,157,'The {$OutboundOrder.OutboundOrder} is allowed to be printed before it is allowed to print' from DUAL
where not exists(select 1 from ld_tranlabel where languagetype='en' and trantable='ld_systems_deploy' and relateid=157 and tabid = 157);

set @i=0;
update ld_systems_deploy set sequence=(@i:=@i+1) where roottype = @roottype order by sequence;
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','Thedocumentisnotapprovedandnotallowedtoprint','单据未审批，不允许打印，请批准后再打印！','jspop' from dual
where not exists(select 1 from ld_desk where languagetype = 'zh' and labelbol = 'Thedocumentisnotapprovedandnotallowedtoprint' and labeltype = 'jspop');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','Thedocumentisnotapprovedandnotallowedtoprint',"The document is not approved and not allowed to print. Please print it after approval.",'jspop' from dual
where not exists(select 1 from ld_desk where languagetype = 'en' and labelbol = 'Thedocumentisnotapprovedandnotallowedtoprint' and labeltype = 'jspop');
delimiter;

DROP PROCEDURE IF EXISTS `addModulePrintField`;
delimiter ||
CREATE  PROCEDURE `addModulePrintField`()
BEGIN
	DECLARE ftablename varchar(200);
	DECLARE ffieldname VARCHAR(200);
	DECLARE fblockid int(11);
	DECLARE fmax_fieldid int(11);
	DECLARE fmax_sequence int(11) default 0;
	declare cnt int(11) DEFAULT 0;
	declare i int(11) DEFAULT 0;

	select count(1) into cnt from ld_tab where printtab = 1;

	while i < cnt
	do
		set @stmt = concat('select tabid,`name` into @ttabid,@fname from ld_tab where tabid>0 AND printtab = ''1'' limit ?,?');
		prepare s1 from @stmt;
		set @s1 = i;
		set @s2 = 1;
		execute s1 using @s1,@s2;

		set ffieldname = 'createdtime';
		select max(fieldid) into fmax_fieldid from ld_field;
		select tablename,block into ftablename,fblockid from ld_field where tabid = @ttabid and columnname = ffieldname;
		set @sql=CONCAT('insert into ld_field (tabid ,fieldid,columnname,tablename,generatedtype,uitype,fieldname,fieldlabel,readonly,presence,sequence,block,displaytype,typeofdata,quickcreate,issmownerid,masseditable) select ',@ttabid,',',fmax_fieldid+1,',''print_times'',"',ftablename,'",''1'',''1'',''print_times'',''打印次数'',''1'',''0'',''1000'',',fblockid,',''2'',''N~O'',''1'',''0'',''0'' from dual where not exists(select 1 from ld_field where tabid=',@ttabid,' and columnname=''print_times'')');
		prepare stmt from @sql;
		execute stmt;
		deallocate  prepare  stmt;

		set @j=0;
		update ld_field set sequence=(@j:=@j+1) where tabid = @ttabid order by sequence;

		select fieldid into @fieldid from ld_field where tabid = @ttabid and columnname = 'print_times';
		set @sql_zh = CONCAT('insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel) select ''zh'',''ld_field'',',@ttabid,',',@fieldid,',''打印次数'' from dual where not exists(select 1 from ld_tranlabel where tabid = ',@ttabid,' and relateid = ',@fieldid,' and trantable = ''ld_field'' and languagetype = ''zh'')');
		prepare stmt from @sql_zh;
		execute stmt;
		deallocate  prepare  stmt;

		select fieldid into @fieldid from ld_field where tabid = @ttabid and columnname = 'print_times';
		set @sql_en = CONCAT('insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel) select ''en'',''ld_field'',',@ttabid,',',@fieldid,',''Printing times'' from dual where not exists(select 1 from ld_tranlabel where tabid = ',@ttabid,' and relateid = ',@fieldid,' and trantable = ''ld_field'' and languagetype = ''en'')');
		prepare stmt from @sql_en;
		execute stmt;
		deallocate  prepare  stmt;

		call AddColumn(ftablename,'print_times','int','11',0);
		set i = i + 1;
	end while;

	update ld_field_seq set id = (select max(fieldid) from ld_field);
end||
delimiter;

CALL addModulePrintField();
delimiter;

update ld_desk set fieldlabel = '工作汇报日志统计表' where labelbol='STATISTICALDAYLOG' and languagetype = 'zh';
delimiter;

select tabid into @tabid from ld_tab where `name` = 'Users';
select fieldlabel into @module_name from ld_tranlabel where tabid = @tabid and languagetype = 'zh' and trantable = 'ld_tab';
insert into ld_links(tabid,linktype,linklabel,linkurl,description)
select @tabid,'Import','module_import_step1','http://51mis.com.cn/forum.php?mod=viewthread&tid=309&fromuid=1',CONCAT(@module_name,'模块导入第一页，选择导入文件') from DUAL
where not exists(select 1 from ld_links where tabid = @tabid and linktype = 'Import' and linklabel = 'module_import_step1');
insert into ld_links(tabid,linktype,linklabel,linkurl,description)
select @tabid,'Import','module_import_step2','http://51mis.com.cn/forum.php?mod=viewthread&tid=309&fromuid=1',CONCAT(@module_name,'模块导入第二页，设置查重、映射字段，导入方式') from DUAL
where not exists(select 1 from ld_links where tabid = @tabid and linktype = 'Import' and linklabel = 'module_import_step2');
insert into ld_links(tabid,linktype,linklabel,linkurl,description)
select @tabid,'Import','module_import_step3','http://51mis.com.cn/forum.php?mod=viewthread&tid=309&fromuid=1',CONCAT(@module_name,'模块导入第三页，导出结果') from DUAL
where not exists(select 1 from ld_links where tabid = @tabid and linktype = 'Import' and linklabel = 'module_import_step3');
delimiter;

INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','MOBILELISTSHOWFIELDNAME','是否显示字段名称','fixedstr'
from dual where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='MOBILELISTSHOWFIELDNAME' and labeltype='fixedstr');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','MOBILELISTSHOWFIELDNAME','Display Enabled Field Name','fixedstr'
from dual where not exists(select 1 from ld_desk where languagetype='en' and labelbol='MOBILELISTSHOWFIELDNAME' and labeltype='fixedstr');
delimiter;

update ld_dashboard_app set image='dashboard_8',wx_presence=1,wx_sequence=7 where name='weeklog';
delimiter;
update ld_dashboard_app set image='dashboard_9',wx_presence=1,wx_sequence=8 where name='monthlog';
delimiter;

update ld_tab set printtab = 1 where `name` in ('Products','PutCash','CashDeposit','ModComments');
call addModulePrintField();
delimiter;
update ld_field set presence=1 where tabid=@tabid and uitype=202;
delimiter;

update ld_field set typeofdata = 'C~O' where uitype = 56;
delimiter;

select tabid into @tabid from ld_tab where name='Contacts';
update ld_fieldwxmaininfo set sequence=0,showtag='no' where fieldname='lastname' and tabid=@tabid;
update ld_fieldwxmaininfo set showtag='yes' where fieldname='account_id' and tabid=@tabid;
set @i=0;
update ld_fieldwxmaininfo set sequence=(@i:=@i+1) where tabid=@tabid order by sequence;
delimiter;
-- 2018-01-18

DROP PROCEDURE IF EXISTS `ldcrm_delete_field20180122`;
delimiter ||
CREATE PROCEDURE `ldcrm_delete_field20180122`(
)
BEGIN

	IF NOT EXISTS (SELECT 1 FROM ld_version_firstlogin) OR (EXISTS (SELECT 1 FROM ld_version WHERE versiontype=56) AND DATABASE() LIKE 'wx17%') THEN
		SET @tabid=22;
		SET @columnname='taobao_shop';
		DELETE FROM ld_tranlabel WHERE trantable='ld_field' AND tabid=@tabid AND Relateid IN (SELECT fieldid FROM ld_field WHERE tabid=@tabid AND columnname=@columnname AND presence=1); 
		DELETE FROM ld_field WHERE tabid=@tabid AND columnname=@columnname AND presence=1; 

		SET @columnname='taobao_orderamount';
		DELETE FROM ld_tranlabel WHERE trantable='ld_field' AND tabid=@tabid AND Relateid IN (SELECT fieldid FROM ld_field WHERE tabid=@tabid AND columnname=@columnname AND presence=1); 
		DELETE FROM ld_field WHERE tabid=@tabid AND columnname=@columnname AND presence=1; 

		SET @columnname='taobao_status';
		DELETE FROM ld_tranlabel WHERE trantable='ld_field' AND tabid=@tabid AND Relateid IN (SELECT fieldid FROM ld_field WHERE tabid=@tabid AND columnname=@columnname AND presence=1); 
		DELETE FROM ld_field WHERE tabid=@tabid AND columnname=@columnname AND presence=1; 

		SET @columnname='package_info';
		DELETE FROM ld_tranlabel WHERE trantable='ld_field' AND tabid=@tabid AND Relateid IN (SELECT fieldid FROM ld_field WHERE tabid=@tabid AND columnname=@columnname AND presence=1); 
		DELETE FROM ld_field WHERE tabid=@tabid AND columnname=@columnname AND presence=1; 


		SET @columnname='promotion_desc';
		DELETE FROM ld_tranlabel WHERE trantable='ld_field' AND tabid=@tabid AND Relateid IN (SELECT fieldid FROM ld_field WHERE tabid=@tabid AND columnname=@columnname AND presence=1); 
		DELETE FROM ld_field WHERE tabid=@tabid AND columnname=@columnname AND presence=1; 

		SET @columnname='buy_description';
		DELETE FROM ld_tranlabel WHERE trantable='ld_field' AND tabid=@tabid AND Relateid IN (SELECT fieldid FROM ld_field WHERE tabid=@tabid AND columnname=@columnname AND presence=1); 
		DELETE FROM ld_field WHERE tabid=@tabid AND columnname=@columnname AND presence=1; 

		SET @columnname='enable_recurring';
		DELETE FROM ld_tranlabel WHERE trantable='ld_field' AND tabid=@tabid AND Relateid IN (SELECT fieldid FROM ld_field WHERE tabid=@tabid AND columnname=@columnname AND presence=1); 
		DELETE FROM ld_field WHERE tabid=@tabid AND columnname=@columnname AND presence=1; 

		SET @columnname='recurring_frequency';
		DELETE FROM ld_tranlabel WHERE trantable='ld_field' AND tabid=@tabid AND Relateid IN (SELECT fieldid FROM ld_field WHERE tabid=@tabid AND columnname=@columnname AND presence=1); 
		DELETE FROM ld_field WHERE tabid=@tabid AND columnname=@columnname AND presence=1; 

		SET @columnname='start_period';
		DELETE FROM ld_tranlabel WHERE trantable='ld_field' AND tabid=@tabid AND Relateid IN (SELECT fieldid FROM ld_field WHERE tabid=@tabid AND columnname=@columnname AND presence=1); 
		DELETE FROM ld_field WHERE tabid=@tabid AND columnname=@columnname AND presence=1; 

		SET @columnname='end_period';
		DELETE FROM ld_tranlabel WHERE trantable='ld_field' AND tabid=@tabid AND Relateid IN (SELECT fieldid FROM ld_field WHERE tabid=@tabid AND columnname=@columnname AND presence=1); 
		DELETE FROM ld_field WHERE tabid=@tabid AND columnname=@columnname AND presence=1; 

		SET @columnname='payment_duration';
		DELETE FROM ld_tranlabel WHERE trantable='ld_field' AND tabid=@tabid AND Relateid IN (SELECT fieldid FROM ld_field WHERE tabid=@tabid AND columnname=@columnname AND presence=1); 
		DELETE FROM ld_field WHERE tabid=@tabid AND columnname=@columnname AND presence=1; 

		SET @columnname='invoice_status';
		DELETE FROM ld_tranlabel WHERE trantable='ld_field' AND tabid=@tabid AND Relateid IN (SELECT fieldid FROM ld_field WHERE tabid=@tabid AND columnname=@columnname AND presence=1); 
		DELETE FROM ld_field WHERE tabid=@tabid AND columnname=@columnname AND presence=1; 

		SET @columnname='pending';
		DELETE FROM ld_tranlabel WHERE trantable='ld_field' AND tabid=@tabid AND Relateid IN (SELECT fieldid FROM ld_field WHERE tabid=@tabid AND columnname=@columnname AND presence=1); 
		DELETE FROM ld_field WHERE tabid=@tabid AND columnname=@columnname AND presence=1; 

		SET @columnname='purchaseorder';
		DELETE FROM ld_tranlabel WHERE trantable='ld_field' AND tabid=@tabid AND Relateid IN (SELECT fieldid FROM ld_field WHERE tabid=@tabid AND columnname=@columnname AND presence=1); 
		DELETE FROM ld_field WHERE tabid=@tabid AND columnname=@columnname AND presence=1; 

		SET @columnname='salescommission';
		DELETE FROM ld_tranlabel WHERE trantable='ld_field' AND tabid=@tabid AND Relateid IN (SELECT fieldid FROM ld_field WHERE tabid=@tabid AND columnname=@columnname AND presence=1); 
		DELETE FROM ld_field WHERE tabid=@tabid AND columnname=@columnname AND presence=1; 

		SET @columnname='exciseduty';
		DELETE FROM ld_tranlabel WHERE trantable='ld_field' AND tabid=@tabid AND Relateid IN (SELECT fieldid FROM ld_field WHERE tabid=@tabid AND columnname=@columnname AND presence=1); 
		DELETE FROM ld_field WHERE tabid=@tabid AND columnname=@columnname AND presence=1; 

		UPDATE ld_field SET presence=0 WHERE columnname='description' AND tabid=@tabid; 

		SET @blocklabel='LBL_promotion_INFO';
		IF NOT EXISTS (SELECT 1 FROM ld_field WHERE tabid=@tabid AND block=(SELECT blockid FROM ld_blocks WHERE tabid=@tabid AND blocklabel=@blocklabel)) THEN
			DELETE FROM ld_tranlabel WHERE trantable='ld_blocks' AND tabid=@tabid AND Relateid IN (SELECT blockid FROM ld_blocks WHERE tabid=@tabid AND blocklabel=@blocklabel);
			DELETE FROM ld_blocks WHERE tabid=@tabid AND blocklabel=@blocklabel;
		END IF;

		SET @blocklabel='Recurring Invoice Information';
		IF NOT EXISTS (SELECT 1 FROM ld_field WHERE tabid=@tabid AND block=(SELECT blockid FROM ld_blocks WHERE tabid=@tabid AND blocklabel=@blocklabel)) THEN
			DELETE FROM ld_tranlabel WHERE trantable='ld_blocks' AND tabid=@tabid AND Relateid IN (SELECT blockid FROM ld_blocks WHERE tabid=@tabid AND blocklabel=@blocklabel);
			DELETE FROM ld_blocks WHERE tabid=@tabid AND blocklabel=@blocklabel;
		END IF;

		SET @blocklabel='LBL_CUSTOM_INFORMATION';
		IF NOT EXISTS (SELECT 1 FROM ld_field WHERE tabid=@tabid AND block=(SELECT blockid FROM ld_blocks WHERE tabid=@tabid AND blocklabel=@blocklabel)) THEN
			DELETE FROM ld_tranlabel WHERE trantable='ld_blocks' AND tabid=@tabid AND Relateid IN (SELECT blockid FROM ld_blocks WHERE tabid=@tabid AND blocklabel=@blocklabel);
			DELETE FROM ld_blocks WHERE tabid=@tabid AND blocklabel=@blocklabel;
		END IF;

		SET @blocklabel='LBL_ADDRESS_INFORMATION';
		IF NOT EXISTS (SELECT 1 FROM ld_field WHERE tabid=@tabid AND block=(SELECT blockid FROM ld_blocks WHERE tabid=@tabid AND blocklabel=@blocklabel)) THEN
			DELETE FROM ld_tranlabel WHERE trantable='ld_blocks' AND tabid=@tabid AND Relateid IN (SELECT blockid FROM ld_blocks WHERE tabid=@tabid AND blocklabel=@blocklabel);
			DELETE FROM ld_blocks WHERE tabid=@tabid AND blocklabel=@blocklabel;
		END IF;

		SET @blocklabel='LBL_RELATED_PRODUCTS';
		IF NOT EXISTS (SELECT 1 FROM ld_field WHERE tabid=@tabid AND block=(SELECT blockid FROM ld_blocks WHERE tabid=@tabid AND blocklabel=@blocklabel)) THEN
			DELETE FROM ld_tranlabel WHERE trantable='ld_blocks' AND tabid=@tabid AND Relateid IN (SELECT blockid FROM ld_blocks WHERE tabid=@tabid AND blocklabel=@blocklabel);
			DELETE FROM ld_blocks WHERE tabid=@tabid AND blocklabel=@blocklabel;
		END IF;



		SET @tabid=6;
		UPDATE ld_field SET presence=1 WHERE tabid=6 AND columnname IN ('traffic','bill_code','salutation','qq','account_type','accountrelationship','nextcontactdate','important_level','productcategory'); 
		SET @columnname='hotaccount';
		DELETE FROM ld_tranlabel WHERE trantable='ld_field' AND tabid=@tabid AND Relateid IN (SELECT fieldid FROM ld_field WHERE tabid=@tabid AND columnname=@columnname AND presence=1); 
		DELETE FROM ld_field WHERE tabid=@tabid AND columnname=@columnname AND presence=1; 

		SET @columnname='hotdegree';
		DELETE FROM ld_tranlabel WHERE trantable='ld_field' AND tabid=@tabid AND Relateid IN (SELECT fieldid FROM ld_field WHERE tabid=@tabid AND columnname=@columnname AND presence=1); 
		DELETE FROM ld_field WHERE tabid=@tabid AND columnname=@columnname AND presence=1; 

		SET @columnname='hottype';
		DELETE FROM ld_tranlabel WHERE trantable='ld_field' AND tabid=@tabid AND Relateid IN (SELECT fieldid FROM ld_field WHERE tabid=@tabid AND columnname=@columnname AND presence=1); 
		DELETE FROM ld_field WHERE tabid=@tabid AND columnname=@columnname AND presence=1; 

		SET @columnname='hotdescription';
		DELETE FROM ld_tranlabel WHERE trantable='ld_field' AND tabid=@tabid AND Relateid IN (SELECT fieldid FROM ld_field WHERE tabid=@tabid AND columnname=@columnname AND presence=1); 
		DELETE FROM ld_field WHERE tabid=@tabid AND columnname=@columnname AND presence=1; 

		SET @columnname='ship_street';
		DELETE FROM ld_tranlabel WHERE trantable='ld_field' AND tabid=@tabid AND Relateid IN (SELECT fieldid FROM ld_field WHERE tabid=@tabid AND columnname=@columnname AND presence=1); 
		DELETE FROM ld_field WHERE tabid=@tabid AND columnname=@columnname AND presence=1; 

		SET @columnname='ship_city';
		DELETE FROM ld_tranlabel WHERE trantable='ld_field' AND tabid=@tabid AND Relateid IN (SELECT fieldid FROM ld_field WHERE tabid=@tabid AND columnname=@columnname AND presence=1); 
		DELETE FROM ld_field WHERE tabid=@tabid AND columnname=@columnname AND presence=1; 

		SET @columnname='ship_state';
		DELETE FROM ld_tranlabel WHERE trantable='ld_field' AND tabid=@tabid AND Relateid IN (SELECT fieldid FROM ld_field WHERE tabid=@tabid AND columnname=@columnname AND presence=1); 
		DELETE FROM ld_field WHERE tabid=@tabid AND columnname=@columnname AND presence=1; 

		SET @columnname='ship_code';
		DELETE FROM ld_tranlabel WHERE trantable='ld_field' AND tabid=@tabid AND Relateid IN (SELECT fieldid FROM ld_field WHERE tabid=@tabid AND columnname=@columnname AND presence=1); 
		DELETE FROM ld_field WHERE tabid=@tabid AND columnname=@columnname AND presence=1; 

		SET @columnname='ship_country';
		DELETE FROM ld_tranlabel WHERE trantable='ld_field' AND tabid=@tabid AND Relateid IN (SELECT fieldid FROM ld_field WHERE tabid=@tabid AND columnname=@columnname AND presence=1); 
		DELETE FROM ld_field WHERE tabid=@tabid AND columnname=@columnname AND presence=1; 

		SET @columnname='bill_pobox';
		DELETE FROM ld_tranlabel WHERE trantable='ld_field' AND tabid=@tabid AND Relateid IN (SELECT fieldid FROM ld_field WHERE tabid=@tabid AND columnname=@columnname AND presence=1); 
		DELETE FROM ld_field WHERE tabid=@tabid AND columnname=@columnname AND presence=1; 

		SET @columnname='ship_pobox';
		DELETE FROM ld_tranlabel WHERE trantable='ld_field' AND tabid=@tabid AND Relateid IN (SELECT fieldid FROM ld_field WHERE tabid=@tabid AND columnname=@columnname AND presence=1); 
		DELETE FROM ld_field WHERE tabid=@tabid AND columnname=@columnname AND presence=1; 

		SET @columnname='otherphone';
		DELETE FROM ld_tranlabel WHERE trantable='ld_field' AND tabid=@tabid AND Relateid IN (SELECT fieldid FROM ld_field WHERE tabid=@tabid AND columnname=@columnname AND presence=1); 
		DELETE FROM ld_field WHERE tabid=@tabid AND columnname=@columnname AND presence=1; 

		SET @columnname='employees';
		DELETE FROM ld_tranlabel WHERE trantable='ld_field' AND tabid=@tabid AND Relateid IN (SELECT fieldid FROM ld_field WHERE tabid=@tabid AND columnname=@columnname AND presence=1); 
		DELETE FROM ld_field WHERE tabid=@tabid AND columnname=@columnname AND presence=1; 

		SET @columnname='email2';
		DELETE FROM ld_tranlabel WHERE trantable='ld_field' AND tabid=@tabid AND Relateid IN (SELECT fieldid FROM ld_field WHERE tabid=@tabid AND columnname=@columnname AND presence=1); 
		DELETE FROM ld_field WHERE tabid=@tabid AND columnname=@columnname AND presence=1; 

		SET @columnname='ownership';
		DELETE FROM ld_tranlabel WHERE trantable='ld_field' AND tabid=@tabid AND Relateid IN (SELECT fieldid FROM ld_field WHERE tabid=@tabid AND columnname=@columnname AND presence=1); 
		DELETE FROM ld_field WHERE tabid=@tabid AND columnname=@columnname AND presence=1; 

		SET @columnname='siccode';
		DELETE FROM ld_tranlabel WHERE trantable='ld_field' AND tabid=@tabid AND Relateid IN (SELECT fieldid FROM ld_field WHERE tabid=@tabid AND columnname=@columnname AND presence=1); 
		DELETE FROM ld_field WHERE tabid=@tabid AND columnname=@columnname AND presence=1; 

		SET @columnname='emailoptout';
		DELETE FROM ld_tranlabel WHERE trantable='ld_field' AND tabid=@tabid AND Relateid IN (SELECT fieldid FROM ld_field WHERE tabid=@tabid AND columnname=@columnname AND presence=1); 
		DELETE FROM ld_field WHERE tabid=@tabid AND columnname=@columnname AND presence=1; 

		SET @columnname='notify_owner';
		DELETE FROM ld_tranlabel WHERE trantable='ld_field' AND tabid=@tabid AND Relateid IN (SELECT fieldid FROM ld_field WHERE tabid=@tabid AND columnname=@columnname AND presence=1); 
		DELETE FROM ld_field WHERE tabid=@tabid AND columnname=@columnname AND presence=1; 

		SET @columnname='phoneoutput';
		DELETE FROM ld_tranlabel WHERE trantable='ld_field' AND tabid=@tabid AND Relateid IN (SELECT fieldid FROM ld_field WHERE tabid=@tabid AND columnname=@columnname AND presence=1); 
		DELETE FROM ld_field WHERE tabid=@tabid AND columnname=@columnname AND presence=1; 
		
		SET @blocklabel='联系信息';
		IF NOT EXISTS (SELECT 1 FROM ld_field WHERE tabid=@tabid AND block=(SELECT blockid FROM ld_blocks WHERE tabid=@tabid AND blocklabel=@blocklabel)) THEN
			DELETE FROM ld_tranlabel WHERE trantable='ld_blocks' AND tabid=@tabid AND Relateid IN (SELECT blockid FROM ld_blocks WHERE tabid=@tabid AND blocklabel=@blocklabel);
			DELETE FROM ld_blocks WHERE tabid=@tabid AND blocklabel=@blocklabel;
		END IF;

		SET @blocklabel='热点信息';
		IF NOT EXISTS (SELECT 1 FROM ld_field WHERE tabid=@tabid AND block=(SELECT blockid FROM ld_blocks WHERE tabid=@tabid AND blocklabel=@blocklabel)) THEN
			DELETE FROM ld_tranlabel WHERE trantable='ld_blocks' AND tabid=@tabid AND Relateid IN (SELECT blockid FROM ld_blocks WHERE tabid=@tabid AND blocklabel=@blocklabel);
			DELETE FROM ld_blocks WHERE tabid=@tabid AND blocklabel=@blocklabel;
		END IF;
		
		IF NOT EXISTS (SELECT 1 FROM ld_field WHERE tabid=@tabid AND columnname IN ('hotaccount','hotdegree','hottype','hotdescription')) THEN
			CALL DelColumn('ld_accountscf','hotaccount');
			CALL DelColumn('ld_accountscf','hotdegree');
			CALL DelColumn('ld_accountscf','hottype');
			CALL DelColumn('ld_accountscf','hotdescription');
		END IF;

		IF NOT EXISTS (SELECT 1 FROM ld_field WHERE tabid=@tabid AND columnname IN ('ship_street','ship_city','ship_state','ship_code','ship_country','bill_pobox','ship_pobox')) THEN
			CALL DelColumn('ld_account','ship_street');
			CALL DelColumn('ld_account','ship_city');
			CALL DelColumn('ld_account','ship_state');
			CALL DelColumn('ld_account','ship_code');
			CALL DelColumn('ld_account','ship_country');
			CALL DelColumn('ld_account','bill_pobox');
			CALL DelColumn('ld_account','ship_pobox');
		END IF;

		IF NOT EXISTS (SELECT 1 FROM ld_field WHERE tabid=@tabid AND columnname IN ('emailoptout','notify_owner','phoneoutput')) THEN
			CALL DelColumn('ld_account','emailoptout');
			CALL DelColumn('ld_account','notify_owner');
			CALL DelColumn('ld_account','phoneoutput');
		END IF;


		SET @tabid=2;
		SET @blocklabel='LBL_CUSTOM_INFORMATION';
		IF NOT EXISTS (SELECT 1 FROM ld_field WHERE tabid=@tabid AND block=(SELECT blockid FROM ld_blocks WHERE tabid=@tabid AND blocklabel=@blocklabel)) THEN
			DELETE FROM ld_tranlabel WHERE trantable='ld_blocks' AND tabid=@tabid AND Relateid IN (SELECT blockid FROM ld_blocks WHERE tabid=@tabid AND blocklabel=@blocklabel);
			DELETE FROM ld_blocks WHERE tabid=@tabid AND blocklabel=@blocklabel;
		END IF;

		SET @tabid=23;
		SET @columnname='ship_street';
		DELETE FROM ld_tranlabel WHERE trantable='ld_field' AND tabid=@tabid AND Relateid IN (SELECT fieldid FROM ld_field WHERE tabid=@tabid AND columnname=@columnname AND presence=1); 
		DELETE FROM ld_field WHERE tabid=@tabid AND columnname=@columnname AND presence=1; 

		SET @columnname='ship_city';
		DELETE FROM ld_tranlabel WHERE trantable='ld_field' AND tabid=@tabid AND Relateid IN (SELECT fieldid FROM ld_field WHERE tabid=@tabid AND columnname=@columnname AND presence=1); 
		DELETE FROM ld_field WHERE tabid=@tabid AND columnname=@columnname AND presence=1; 

		SET @columnname='ship_state';
		DELETE FROM ld_tranlabel WHERE trantable='ld_field' AND tabid=@tabid AND Relateid IN (SELECT fieldid FROM ld_field WHERE tabid=@tabid AND columnname=@columnname AND presence=1); 
		DELETE FROM ld_field WHERE tabid=@tabid AND columnname=@columnname AND presence=1; 

		SET @columnname='ship_code';
		DELETE FROM ld_tranlabel WHERE trantable='ld_field' AND tabid=@tabid AND Relateid IN (SELECT fieldid FROM ld_field WHERE tabid=@tabid AND columnname=@columnname AND presence=1); 
		DELETE FROM ld_field WHERE tabid=@tabid AND columnname=@columnname AND presence=1; 

		SET @columnname='ship_country';
		DELETE FROM ld_tranlabel WHERE trantable='ld_field' AND tabid=@tabid AND Relateid IN (SELECT fieldid FROM ld_field WHERE tabid=@tabid AND columnname=@columnname AND presence=1); 
		DELETE FROM ld_field WHERE tabid=@tabid AND columnname=@columnname AND presence=1; 

		SET @columnname='bill_pobox';
		DELETE FROM ld_tranlabel WHERE trantable='ld_field' AND tabid=@tabid AND Relateid IN (SELECT fieldid FROM ld_field WHERE tabid=@tabid AND columnname=@columnname AND presence=1); 
		DELETE FROM ld_field WHERE tabid=@tabid AND columnname=@columnname AND presence=1; 

		SET @columnname='ship_pobox';
		DELETE FROM ld_tranlabel WHERE trantable='ld_field' AND tabid=@tabid AND Relateid IN (SELECT fieldid FROM ld_field WHERE tabid=@tabid AND columnname=@columnname AND presence=1); 
		DELETE FROM ld_field WHERE tabid=@tabid AND columnname=@columnname AND presence=1; 

		SET @columnname='customerno';
		DELETE FROM ld_tranlabel WHERE trantable='ld_field' AND tabid=@tabid AND Relateid IN (SELECT fieldid FROM ld_field WHERE tabid=@tabid AND columnname=@columnname AND presence=1); 
		DELETE FROM ld_field WHERE tabid=@tabid AND columnname=@columnname AND presence=1; 

		SET @columnname='duedate';
		DELETE FROM ld_tranlabel WHERE trantable='ld_field' AND tabid=@tabid AND Relateid IN (SELECT fieldid FROM ld_field WHERE tabid=@tabid AND columnname=@columnname AND presence=1); 
		DELETE FROM ld_field WHERE tabid=@tabid AND columnname=@columnname AND presence=1; 

		SET @columnname='purchaseorder';
		DELETE FROM ld_tranlabel WHERE trantable='ld_field' AND tabid=@tabid AND Relateid IN (SELECT fieldid FROM ld_field WHERE tabid=@tabid AND columnname=@columnname AND presence=1); 
		DELETE FROM ld_field WHERE tabid=@tabid AND columnname=@columnname AND presence=1; 

		SET @columnname='salescommission';
		DELETE FROM ld_tranlabel WHERE trantable='ld_field' AND tabid=@tabid AND Relateid IN (SELECT fieldid FROM ld_field WHERE tabid=@tabid AND columnname=@columnname AND presence=1); 
		DELETE FROM ld_field WHERE tabid=@tabid AND columnname=@columnname AND presence=1; 

		SET @columnname='exciseduty';
		DELETE FROM ld_tranlabel WHERE trantable='ld_field' AND tabid=@tabid AND Relateid IN (SELECT fieldid FROM ld_field WHERE tabid=@tabid AND columnname=@columnname AND presence=1); 
		DELETE FROM ld_field WHERE tabid=@tabid AND columnname=@columnname AND presence=1; 

		SET @blocklabel='LBL_CUSTOM_INFORMATION';
		IF NOT EXISTS (SELECT 1 FROM ld_field WHERE tabid=@tabid AND block=(SELECT blockid FROM ld_blocks WHERE tabid=@tabid AND blocklabel=@blocklabel)) THEN
			DELETE FROM ld_tranlabel WHERE trantable='ld_blocks' AND tabid=@tabid AND Relateid IN (SELECT blockid FROM ld_blocks WHERE tabid=@tabid AND blocklabel=@blocklabel);
			DELETE FROM ld_blocks WHERE tabid=@tabid AND blocklabel=@blocklabel;
		END IF;

		SET @blocklabel='LBL_RELATED_PRODUCTS';
		IF NOT EXISTS (SELECT 1 FROM ld_field WHERE tabid=@tabid AND block=(SELECT blockid FROM ld_blocks WHERE tabid=@tabid AND blocklabel=@blocklabel)) THEN
			DELETE FROM ld_tranlabel WHERE trantable='ld_blocks' AND tabid=@tabid AND Relateid IN (SELECT blockid FROM ld_blocks WHERE tabid=@tabid AND blocklabel=@blocklabel);
			DELETE FROM ld_blocks WHERE tabid=@tabid AND blocklabel=@blocklabel;
		END IF;

		
		SET @tabid=14;
		SET @blocklabel='LBL_CUSTOM_INFORMATION';
		IF NOT EXISTS (SELECT 1 FROM ld_field WHERE tabid=@tabid AND block=(SELECT blockid FROM ld_blocks WHERE tabid=@tabid AND blocklabel=@blocklabel)) THEN
			DELETE FROM ld_tranlabel WHERE trantable='ld_blocks' AND tabid=@tabid AND Relateid IN (SELECT blockid FROM ld_blocks WHERE tabid=@tabid AND blocklabel=@blocklabel);
			DELETE FROM ld_blocks WHERE tabid=@tabid AND blocklabel=@blocklabel;
		END IF;


		SET @tabid=(SELECT tabid FROM ld_tab WHERE name='Commission');
		SET @blocklabel='LBL_COMMISSION_DESCRIPTION';
		IF NOT EXISTS (SELECT 1 FROM ld_field WHERE tabid=@tabid AND block=(SELECT blockid FROM ld_blocks WHERE tabid=@tabid AND blocklabel=@blocklabel)) THEN
			DELETE FROM ld_tranlabel WHERE trantable='ld_blocks' AND tabid=@tabid AND Relateid IN (SELECT blockid FROM ld_blocks WHERE tabid=@tabid AND blocklabel=@blocklabel);
			DELETE FROM ld_blocks WHERE tabid=@tabid AND blocklabel=@blocklabel;
		END IF;

		SET @tabid=(SELECT tabid FROM ld_tab WHERE name='Quotes');
		SET @columnname='ship_street';
		DELETE FROM ld_tranlabel WHERE trantable='ld_field' AND tabid=@tabid AND Relateid IN (SELECT fieldid FROM ld_field WHERE tabid=@tabid AND columnname=@columnname AND presence=1); 
		DELETE FROM ld_field WHERE tabid=@tabid AND columnname=@columnname AND presence=1; 

		SET @columnname='ship_city';
		DELETE FROM ld_tranlabel WHERE trantable='ld_field' AND tabid=@tabid AND Relateid IN (SELECT fieldid FROM ld_field WHERE tabid=@tabid AND columnname=@columnname AND presence=1); 
		DELETE FROM ld_field WHERE tabid=@tabid AND columnname=@columnname AND presence=1; 

		SET @columnname='ship_state';
		DELETE FROM ld_tranlabel WHERE trantable='ld_field' AND tabid=@tabid AND Relateid IN (SELECT fieldid FROM ld_field WHERE tabid=@tabid AND columnname=@columnname AND presence=1); 
		DELETE FROM ld_field WHERE tabid=@tabid AND columnname=@columnname AND presence=1; 

		SET @columnname='ship_code';
		DELETE FROM ld_tranlabel WHERE trantable='ld_field' AND tabid=@tabid AND Relateid IN (SELECT fieldid FROM ld_field WHERE tabid=@tabid AND columnname=@columnname AND presence=1); 
		DELETE FROM ld_field WHERE tabid=@tabid AND columnname=@columnname AND presence=1; 

		SET @columnname='ship_country';
		DELETE FROM ld_tranlabel WHERE trantable='ld_field' AND tabid=@tabid AND Relateid IN (SELECT fieldid FROM ld_field WHERE tabid=@tabid AND columnname=@columnname AND presence=1); 
		DELETE FROM ld_field WHERE tabid=@tabid AND columnname=@columnname AND presence=1; 

		SET @columnname='bill_pobox';
		DELETE FROM ld_tranlabel WHERE trantable='ld_field' AND tabid=@tabid AND Relateid IN (SELECT fieldid FROM ld_field WHERE tabid=@tabid AND columnname=@columnname AND presence=1); 
		DELETE FROM ld_field WHERE tabid=@tabid AND columnname=@columnname AND presence=1; 

		SET @columnname='ship_pobox';
		DELETE FROM ld_tranlabel WHERE trantable='ld_field' AND tabid=@tabid AND Relateid IN (SELECT fieldid FROM ld_field WHERE tabid=@tabid AND columnname=@columnname AND presence=1); 
		DELETE FROM ld_field WHERE tabid=@tabid AND columnname=@columnname AND presence=1; 

		SET @blocklabel='LBL_CUSTOM_INFORMATION';
		IF NOT EXISTS (SELECT 1 FROM ld_field WHERE tabid=@tabid AND block=(SELECT blockid FROM ld_blocks WHERE tabid=@tabid AND blocklabel=@blocklabel)) THEN
			DELETE FROM ld_tranlabel WHERE trantable='ld_blocks' AND tabid=@tabid AND Relateid IN (SELECT blockid FROM ld_blocks WHERE tabid=@tabid AND blocklabel=@blocklabel);
			DELETE FROM ld_blocks WHERE tabid=@tabid AND blocklabel=@blocklabel;
		END IF;

		SET @blocklabel='LBL_RELATED_PRODUCTS';
		IF NOT EXISTS (SELECT 1 FROM ld_field WHERE tabid=@tabid AND block=(SELECT blockid FROM ld_blocks WHERE tabid=@tabid AND blocklabel=@blocklabel)) THEN
			DELETE FROM ld_tranlabel WHERE trantable='ld_blocks' AND tabid=@tabid AND Relateid IN (SELECT blockid FROM ld_blocks WHERE tabid=@tabid AND blocklabel=@blocklabel);
			DELETE FROM ld_blocks WHERE tabid=@tabid AND blocklabel=@blocklabel;
		END IF;

		UPDATE ld_field SET presence=0 WHERE columnname='description' AND tabid=@tabid;


		SET @tabid=37;
		SET @columnname='progress';
		DELETE FROM ld_tranlabel WHERE trantable='ld_field' AND tabid=@tabid AND Relateid IN (SELECT fieldid FROM ld_field WHERE tabid=@tabid AND columnname=@columnname AND presence=1); 
		DELETE FROM ld_field WHERE tabid=@tabid AND columnname=@columnname AND presence=1; 

		SET @columnname='priority';
		DELETE FROM ld_tranlabel WHERE trantable='ld_field' AND tabid=@tabid AND Relateid IN (SELECT fieldid FROM ld_field WHERE tabid=@tabid AND columnname=@columnname AND presence=1); 
		DELETE FROM ld_field WHERE tabid=@tabid AND columnname=@columnname AND presence=1; 

		SET @blocklabel='LBL_CUSTOM_INFORMATION';
		IF NOT EXISTS (SELECT 1 FROM ld_field WHERE tabid=@tabid AND block=(SELECT blockid FROM ld_blocks WHERE tabid=@tabid AND blocklabel=@blocklabel)) THEN
			DELETE FROM ld_tranlabel WHERE trantable='ld_blocks' AND tabid=@tabid AND Relateid IN (SELECT blockid FROM ld_blocks WHERE tabid=@tabid AND blocklabel=@blocklabel);
			DELETE FROM ld_blocks WHERE tabid=@tabid AND blocklabel=@blocklabel;
		END IF;

		DELETE FROM ld_usageunit WHERE usageunit IN ('盒','条','片','令','张');



		SET @tabid=(SELECT tabid FROM ld_tab WHERE name='PriceBooks');
		SET @blocklabel='LBL_CUSTOM_INFORMATION';
		IF NOT EXISTS (SELECT 1 FROM ld_field WHERE tabid=@tabid AND block=(SELECT blockid FROM ld_blocks WHERE tabid=@tabid AND blocklabel=@blocklabel)) THEN
			DELETE FROM ld_tranlabel WHERE trantable='ld_blocks' AND tabid=@tabid AND Relateid IN (SELECT blockid FROM ld_blocks WHERE tabid=@tabid AND blocklabel=@blocklabel);
			DELETE FROM ld_blocks WHERE tabid=@tabid AND blocklabel=@blocklabel;
		END IF;

		SET @tabid=(SELECT tabid FROM ld_tab WHERE name='ModComments');
		SET @blocklabel='LBL_CUSTOM_INFORMATION';
		IF NOT EXISTS (SELECT 1 FROM ld_field WHERE tabid=@tabid AND block=(SELECT blockid FROM ld_blocks WHERE tabid=@tabid AND blocklabel=@blocklabel)) THEN
			DELETE FROM ld_tranlabel WHERE trantable='ld_blocks' AND tabid=@tabid AND Relateid IN (SELECT blockid FROM ld_blocks WHERE tabid=@tabid AND blocklabel=@blocklabel);
			DELETE FROM ld_blocks WHERE tabid=@tabid AND blocklabel=@blocklabel;
		END IF;

		
		SET @tabid=18;
		SET @columnname='pobox';
		DELETE FROM ld_tranlabel WHERE trantable='ld_field' AND tabid=@tabid AND Relateid IN (SELECT fieldid FROM ld_field WHERE tabid=@tabid AND columnname=@columnname AND presence=1); 
		DELETE FROM ld_field WHERE tabid=@tabid AND columnname=@columnname AND presence=1; 

		SET @columnname='category';
		DELETE FROM ld_tranlabel WHERE trantable='ld_field' AND tabid=@tabid AND Relateid IN (SELECT fieldid FROM ld_field WHERE tabid=@tabid AND columnname=@columnname AND presence=1); 
		DELETE FROM ld_field WHERE tabid=@tabid AND columnname=@columnname AND presence=1; 

		SET @blocklabel='LBL_CUSTOM_INFORMATION';
		IF NOT EXISTS (SELECT 1 FROM ld_field WHERE tabid=@tabid AND block=(SELECT blockid FROM ld_blocks WHERE tabid=@tabid AND blocklabel=@blocklabel)) THEN
			DELETE FROM ld_tranlabel WHERE trantable='ld_blocks' AND tabid=@tabid AND Relateid IN (SELECT blockid FROM ld_blocks WHERE tabid=@tabid AND blocklabel=@blocklabel);
			DELETE FROM ld_blocks WHERE tabid=@tabid AND blocklabel=@blocklabel;
		END IF;


		SET @tabid=(SELECT tabid FROM ld_tab WHERE name='Campaigns');
		SET @blocklabel='LBL_CUSTOM_INFORMATION';
		IF NOT EXISTS (SELECT 1 FROM ld_field WHERE tabid=@tabid AND block=(SELECT blockid FROM ld_blocks WHERE tabid=@tabid AND blocklabel=@blocklabel)) THEN
			DELETE FROM ld_tranlabel WHERE trantable='ld_blocks' AND tabid=@tabid AND Relateid IN (SELECT blockid FROM ld_blocks WHERE tabid=@tabid AND blocklabel=@blocklabel);
			DELETE FROM ld_blocks WHERE tabid=@tabid AND blocklabel=@blocklabel;
		END IF;

        UPDATE ld_field SET quickcreate=0 WHERE tabid=13 AND columnname IN ('servicetype','description');
        
	END IF;

end ||
delimiter;

CALL ldcrm_delete_field20180122();
DROP PROCEDURE IF EXISTS `ldcrm_delete_field20180122`;
delimiter;

DELETE FROM ld_usageunit WHERE usageunit IN ('盒','条','片','令','张') AND NOT EXISTS (SELECT 1 FROM ld_products);

UPDATE ld_field SET quickcreate=0 WHERE tabid=13 AND columnname IN ('servicetype','description') 
	AND NOT EXISTS (SELECT 1 FROM ld_troubletickets);
    
CALL AddColumn('ld_users','wxviewedmodules','varchar','255','modules:');
delimiter;

alter table ld_cvadvfilter  modify column comparator varchar(50);
update ld_cvadvfilter set comparator=CONCAT(comparator,'s') where comparator like 'before%' and comparator like '%day';
update ld_cvadvfilter set comparator=CONCAT(comparator,'ys') where comparator like 'before%' and comparator like '%da';
update ld_cvadvfilter set comparator=CONCAT(comparator,'ays') where comparator like 'before%' and comparator like '%d';

delete from ld_field where columnname = 'print_times';
delete from ld_tranlabel where relateid in (select fieldid from ld_field where columnname = 'print_times') and trantable = 'ld_field';
delimiter;

call addModulePrintField();
delimiter;

DROP PROCEDURE IF EXISTS `ldcrm_addcustomview_byapprovestatus`;
delimiter ||
CREATE PROCEDURE `ldcrm_addcustomview_byapprovestatus`(
	tmp_modulename VARCHAR(100),
	tmp_viewname VARCHAR(100)
)
BEGIN
	
	IF NOT EXISTS (SELECT 1 FROM ld_customview WHERE entitytype=tmp_modulename AND viewname=tmp_viewname) THEN 
		SET @cvid=IFNULL((SELECT MAX(cvid) FROM ld_customview),0)+1;
		SET @seq=IFNULL((SELECT MAX(sequence) FROM ld_customview WHERE entitytype=tmp_modulename),0)+1;

		INSERT INTO ld_customview(cvid,viewname,setdefault,setmetrics,entitytype,`status`,userid,sequence,pagewidthpercent)
		SELECT @cvid,tmp_viewname,0,0,tmp_modulename,1,1,@seq,100;

		DELETE FROM ld_cvadvfilter WHERE cvid=@cvid;
		INSERT INTO ld_cvadvfilter_grouping(groupid,cvid,group_condition,condition_expression)
		SELECT 1,@cvid,'',0;
		
		DELETE FROM ld_cvadvfilter WHERE cvid=@cvid;
		INSERT INTO ld_cvadvfilter(
			cvid,
			columnindex,
			columnname,
			comparator,
			`value`,
			groupid,
			column_condition
		)
		SELECT 
			@cvid,
			0,
			(SELECT CONCAT(tablename,':','approvestatus:approvestatus:',tmp_modulename,'_fieldlabel:V') FROM ld_field WHERE tabid=(SELECT tabid FROM ld_tab WHERE name=tmp_modulename) AND columnname='approvestatus' LIMIT 1),
			'e',
			tmp_viewname,
			1,
			'';

		IF EXISTS (SELECT 1 FROM ld_cvcolumnlist WHERE cvid=(SELECT cvid FROM ld_customview WHERE entitytype=tmp_modulename AND viewname IN ('All','全部') LIMIT 1)) THEN
			DELETE FROM ld_cvcolumnlist WHERE cvid=@cvid;
			INSERT INTO ld_cvcolumnlist(cvid,columnindex,columnname)
			SELECT @cvid,columnindex,columnname FROM ld_cvcolumnlist 
			WHERE cvid=(SELECT cvid FROM ld_customview WHERE entitytype=tmp_modulename AND viewname IN ('All','全部') LIMIT 1);
		END IF;

		IF EXISTS (SELECT 1 FROM ld_tabwithproductview WHERE cvid=(SELECT cvid FROM ld_customview WHERE entitytype=tmp_modulename AND viewname IN ('All','全部') LIMIT 1)) THEN
			DELETE FROM ld_tabwithproductview WHERE cvid=@cvid;
			INSERT INTO ld_tabwithproductview(
				tabid,
				`columns`,
				sequence,
				cvid
			)
			SELECT 
				tabid,
				`columns`,
				sequence,
				@cvid
			FROM ld_tabwithproductview
			WHERE cvid=(SELECT cvid FROM ld_customview WHERE entitytype=tmp_modulename AND viewname IN ('All','全部') LIMIT 1);
		END IF;
	END IF;

	SET @i=0;
	UPDATE ld_customview SET sequence=10001 WHERE entitytype=tmp_modulename AND viewname='已批准';
	UPDATE ld_customview SET sequence=10001 WHERE entitytype=tmp_modulename AND viewname='审批中';
	UPDATE ld_customview SET sequence=10002 WHERE entitytype=tmp_modulename AND viewname='未提交';
	UPDATE ld_customview SET sequence=10003 WHERE entitytype=tmp_modulename AND viewname='已驳回';
	UPDATE ld_customview SET sequence=10004 WHERE entitytype=tmp_modulename AND viewname='已拒绝';
	UPDATE ld_customview SET sequence=(@i:=@i+1) WHERE entitytype=tmp_modulename ORDER BY sequence;

end ||
delimiter;

DROP PROCEDURE IF EXISTS `ldcrm_restcustomview_byapprovestatus`;
delimiter ||
CREATE PROCEDURE `ldcrm_restcustomview_byapprovestatus`(
)
BEGIN

	IF NOT EXISTS (SELECT 1 FROM ld_version_firstlogin) OR DATABASE() LIKE 'wx17%' THEN
		DELETE FROM ld_customview WHERE entitytype='Accounts' AND customcategory='ALLACCOUNT' AND viewname IN ('潜在客户','客户及联系人');
	
		CALL ldcrm_addcustomview_byapprovestatus('Quotes','已批准');
		CALL ldcrm_addcustomview_byapprovestatus('Quotes','审批中');
		CALL ldcrm_addcustomview_byapprovestatus('Quotes','未提交');
		CALL ldcrm_addcustomview_byapprovestatus('Quotes','已驳回');
		CALL ldcrm_addcustomview_byapprovestatus('Quotes','已拒绝');

		DELETE FROM ld_customview WHERE entitytype='QuotesChange' AND viewname IN ('待审批','已审批');
		CALL ldcrm_addcustomview_byapprovestatus('QuotesChange','已批准');
		CALL ldcrm_addcustomview_byapprovestatus('QuotesChange','审批中');
		CALL ldcrm_addcustomview_byapprovestatus('QuotesChange','未提交');
		CALL ldcrm_addcustomview_byapprovestatus('QuotesChange','已驳回');
		CALL ldcrm_addcustomview_byapprovestatus('QuotesChange','已拒绝');

		DELETE FROM ld_customview WHERE entitytype='SalesOrder' AND viewname IN ('已采购','待采购','待审批','已审批');
		CALL ldcrm_addcustomview_byapprovestatus('SalesOrder','已批准');
		CALL ldcrm_addcustomview_byapprovestatus('SalesOrder','审批中');
		CALL ldcrm_addcustomview_byapprovestatus('SalesOrder','未提交');
		CALL ldcrm_addcustomview_byapprovestatus('SalesOrder','已驳回');
		CALL ldcrm_addcustomview_byapprovestatus('SalesOrder','已拒绝');

		CALL ldcrm_addcustomview_byapprovestatus('ServiceContracts','已批准');
		CALL ldcrm_addcustomview_byapprovestatus('ServiceContracts','审批中');
		CALL ldcrm_addcustomview_byapprovestatus('ServiceContracts','未提交');
		CALL ldcrm_addcustomview_byapprovestatus('ServiceContracts','已驳回');
		CALL ldcrm_addcustomview_byapprovestatus('ServiceContracts','已拒绝');

		CALL ldcrm_addcustomview_byapprovestatus('HelpDesk','已批准');
		CALL ldcrm_addcustomview_byapprovestatus('HelpDesk','审批中');
		CALL ldcrm_addcustomview_byapprovestatus('HelpDesk','未提交');
		CALL ldcrm_addcustomview_byapprovestatus('HelpDesk','已驳回');
		CALL ldcrm_addcustomview_byapprovestatus('HelpDesk','已拒绝');
		
		CALL ldcrm_addcustomview_byapprovestatus('ServiceReturn','已批准');
		CALL ldcrm_addcustomview_byapprovestatus('ServiceReturn','审批中');
		CALL ldcrm_addcustomview_byapprovestatus('ServiceReturn','未提交');
		CALL ldcrm_addcustomview_byapprovestatus('ServiceReturn','已驳回');
		CALL ldcrm_addcustomview_byapprovestatus('ServiceReturn','已拒绝');

		CALL ldcrm_addcustomview_byapprovestatus('NormalApprove','已驳回');
		CALL ldcrm_addcustomview_byapprovestatus('NormalApprove','已拒绝');


		CALL ldcrm_addcustomview_byapprovestatus('Project','已批准');
		CALL ldcrm_addcustomview_byapprovestatus('Project','审批中');
		CALL ldcrm_addcustomview_byapprovestatus('Project','未提交');
		CALL ldcrm_addcustomview_byapprovestatus('Project','已驳回');
		CALL ldcrm_addcustomview_byapprovestatus('Project','已拒绝');


		CALL ldcrm_addcustomview_byapprovestatus('ProjectTask','已批准');
		CALL ldcrm_addcustomview_byapprovestatus('ProjectTask','审批中');
		CALL ldcrm_addcustomview_byapprovestatus('ProjectTask','未提交');
		CALL ldcrm_addcustomview_byapprovestatus('ProjectTask','已驳回');
		CALL ldcrm_addcustomview_byapprovestatus('ProjectTask','已拒绝');
		
		CALL ldcrm_addcustomview_byapprovestatus('ProjectMilestone','已批准');
		CALL ldcrm_addcustomview_byapprovestatus('ProjectMilestone','审批中');
		CALL ldcrm_addcustomview_byapprovestatus('ProjectMilestone','未提交');
		CALL ldcrm_addcustomview_byapprovestatus('ProjectMilestone','已驳回');
		CALL ldcrm_addcustomview_byapprovestatus('ProjectMilestone','已拒绝');

		CALL ldcrm_addcustomview_byapprovestatus('TimeSheet','已批准');
		CALL ldcrm_addcustomview_byapprovestatus('TimeSheet','审批中');
		CALL ldcrm_addcustomview_byapprovestatus('TimeSheet','未提交');
		CALL ldcrm_addcustomview_byapprovestatus('TimeSheet','已驳回');
		CALL ldcrm_addcustomview_byapprovestatus('TimeSheet','已拒绝');

		CALL ldcrm_addcustomview_byapprovestatus('ProjectProgress','已批准');
		CALL ldcrm_addcustomview_byapprovestatus('ProjectProgress','审批中');
		CALL ldcrm_addcustomview_byapprovestatus('ProjectProgress','未提交');
		CALL ldcrm_addcustomview_byapprovestatus('ProjectProgress','已驳回');
		CALL ldcrm_addcustomview_byapprovestatus('ProjectProgress','已拒绝');

		CALL ldcrm_addcustomview_byapprovestatus('ProjectProgress','已批准');
		CALL ldcrm_addcustomview_byapprovestatus('ProjectProgress','审批中');
		CALL ldcrm_addcustomview_byapprovestatus('ProjectProgress','未提交');
		CALL ldcrm_addcustomview_byapprovestatus('ProjectProgress','已驳回');
		CALL ldcrm_addcustomview_byapprovestatus('ProjectProgress','已拒绝');

		DELETE FROM ld_customview WHERE entitytype='Invoice' AND viewname IN ('待审批','已审批');
		CALL ldcrm_addcustomview_byapprovestatus('Invoice','已批准');
		CALL ldcrm_addcustomview_byapprovestatus('Invoice','审批中');
		CALL ldcrm_addcustomview_byapprovestatus('Invoice','未提交');
		CALL ldcrm_addcustomview_byapprovestatus('Invoice','已驳回');
		CALL ldcrm_addcustomview_byapprovestatus('Invoice','已拒绝');

		CALL ldcrm_addcustomview_byapprovestatus('PurchaseInvoice','已批准');
		CALL ldcrm_addcustomview_byapprovestatus('PurchaseInvoice','审批中');
		CALL ldcrm_addcustomview_byapprovestatus('PurchaseInvoice','未提交');
		CALL ldcrm_addcustomview_byapprovestatus('PurchaseInvoice','已驳回');
		CALL ldcrm_addcustomview_byapprovestatus('PurchaseInvoice','已拒绝');


		DELETE FROM ld_customview WHERE entitytype='CashBill' AND viewname IN ('已审核','未审核');
		CALL ldcrm_addcustomview_byapprovestatus('CashBill','已批准');
		CALL ldcrm_addcustomview_byapprovestatus('CashBill','审批中');
		CALL ldcrm_addcustomview_byapprovestatus('CashBill','未提交');
		CALL ldcrm_addcustomview_byapprovestatus('CashBill','已驳回');
		CALL ldcrm_addcustomview_byapprovestatus('CashBill','已拒绝');

		DELETE FROM ld_customview WHERE entitytype='SendPayment' AND viewname IN ('已审核','未审核');
		CALL ldcrm_addcustomview_byapprovestatus('SendPayment','已批准');
		CALL ldcrm_addcustomview_byapprovestatus('SendPayment','审批中');
		CALL ldcrm_addcustomview_byapprovestatus('SendPayment','未提交');
		CALL ldcrm_addcustomview_byapprovestatus('SendPayment','已驳回');
		CALL ldcrm_addcustomview_byapprovestatus('SendPayment','已拒绝');

		UPDATE ld_customview SET viewname='本月退款' WHERE entitytype='PurchaseCashBack' AND viewname='本月';

		DELETE FROM ld_customview WHERE entitytype='Vendors' AND viewname IN ('供应商及联系人');

		DELETE FROM ld_customview WHERE entitytype='PurchaseOrder' AND viewname IN ('未审批','已审批');
		CALL ldcrm_addcustomview_byapprovestatus('PurchaseOrder','已批准');
		CALL ldcrm_addcustomview_byapprovestatus('PurchaseOrder','审批中');
		CALL ldcrm_addcustomview_byapprovestatus('PurchaseOrder','未提交');
		CALL ldcrm_addcustomview_byapprovestatus('PurchaseOrder','已驳回');
		CALL ldcrm_addcustomview_byapprovestatus('PurchaseOrder','已拒绝');

	END IF;

end ||
delimiter;

CALL ldcrm_restcustomview_byapprovestatus();
DROP PROCEDURE IF EXISTS `ldcrm_addcustomview_byapprovestatus`;
DROP PROCEDURE IF EXISTS `ldcrm_restcustomview_byapprovestatus`;
delimiter;
-- 2018-01-22

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
UPDATE ld_settings_field_seq SET id=(SELECT max(fieldid) FROM ld_settings_field);
delimiter;

update ld_version set old_version='V7.2.5',current_version='V7.2.5',remark='V7.2.5-20180122',wx_version='V7.2.5';
delimiter;