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


call addcolumn('ld_loginhistory','udid','varchar','100',null);
delimiter;

update ld_desk set fieldlabel='Notsubmitted' where labelbol='Unapproved' and languagetype='en'; 
update ld_desk set fieldlabel='Approvaling' where labelbol='Approvalof' and languagetype='en'; 
update ld_desk set fieldlabel='Approved' where labelbol='Approved' and languagetype='en'; 
update ld_desk set fieldlabel='Rejected' where labelbol='Rejected' and languagetype='en'; 
update ld_desk set fieldlabel='Dismissed' where labelbol='Dismissed' and languagetype='en';
update ld_field set uitype=609   where uitype=130 and columnname='approvestatus';
delimiter;
-- 2016-11-01

update ld_desk set fieldlabel='Sales Report' where labelbol='SalesReport' AND languagetype='en';
delimiter;

update ld_desk set fieldlabel='Purchasing Report' where labelbol='PurchaseReport' AND languagetype='en';
delimiter;

update ld_desk set fieldlabel='Statistical Ranking' where labelbol='SumSequence' AND languagetype='en';
delimiter;

update ld_desk set fieldlabel='Statistics of Mobile Phone Check-in' where labelbol='SIGNINSTATISTICS' AND languagetype='en';
delimiter;

update ld_desk set fieldlabel='Statistics of The Tracks About The Orders' where labelbol='SalesOrderTrack' AND languagetype='en';
delimiter;

update ld_desk set fieldlabel='Sales Forecast and Analysis' where labelbol='Salesforecastandanalysistable' AND languagetype='en';
delimiter;

update ld_desk set fieldlabel='Statistics of Receivables Acc To Order' where labelbol='CashBillSum_SalesOrder' AND languagetype='en';
delimiter;

update ld_desk set fieldlabel='Statistics of Collection Cash Performance' where labelbol='Performancestatisticscollection' AND languagetype='en';
delimiter;

update ld_desk set fieldlabel='Statistics of The Tracks About Purchase Order' where labelbol='PurchaseOrderTrack' AND languagetype='en';
delimiter;

update ld_desk set fieldlabel='Statistics of Payables Acc To Purchase Order' where labelbol='SendCashBillSum_PurchaseOrder' AND languagetype='en';
delimiter;

update ld_desk set fieldlabel='Statistics of Payables Acc To Repayment Plan' where labelbol='SendCashBillSum_SendPayment' AND languagetype='en';
delimiter;

update ld_desk set fieldlabel='Ranking List of Signing Money' where labelbol='Contractnumber' AND languagetype='en';
delimiter;

update ld_desk set fieldlabel='The Signing Amount of Billboard' where labelbol='Contractamount' AND languagetype='en';
delimiter;

update ld_desk set fieldlabel='The Billboard of Receivables' where labelbol='THESINGNINGAMOUNTOFBILLBOARD' AND languagetype='en';
delimiter;

update ld_desk set fieldlabel='Sales and Performance Appraisal' where labelbol='SalesSumSequence' AND languagetype='en';
delimiter;

update ld_desk set fieldlabel='Service and Performance Appraisal' where labelbol='Serviceperformanceappraisal' AND languagetype='en';
delimiter;

update ld_desk set fieldlabel='Statistical Report of {$Project.Project} Performance' where labelbol='Thestatisticalreportofprojectperformance' AND languagetype='en';
delimiter;

update ld_producttoolfield set is_checkimportfield=1 where columnname in('productname','productsheet','product_no');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','ACCOUNT_ACCESS_INFO','当{$Accounts.Accounts}访问权为私有的时候: {$Potentials.Potentials}、{$HelpDesk.HelpDesk}、{$Quotes.Quotes}、{$SalesOrder.SalesOrder}、{$Invoice.Invoice} 访问权限必须设为私有','jspop' from DUAL
where not exists(select 1 from ld_desk where languagetype = 'zh' and labelbol = 'ACCOUNT_ACCESS_INFO' and labeltype = 'jspop');

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','ACCOUNT_ACCESS_INFO','{$Potentials.Potentials}, {$HelpDesk.HelpDesk}, {$Quotes.Quotes}, {$SalesOrder.SalesOrder} and {$Invoice.Invoice} access must be set to Private when the {$Accounts.Accounts} access is set to Private','jspop' from DUAL
where not exists(select 1 from ld_desk where languagetype = 'en' and labelbol = 'ACCOUNT_ACCESS_INFO' and labeltype = 'jspop');
delimiter;

update ld_desk set fieldlabel = '最多仅允许设置6个查找字段' where labelbol = 'O5SFAA' and languagetype = 'zh' and Labeltype = 'jspop';
update ld_desk set fieldlabel = 'Only 6 search fields are allowed' where labelbol = 'O5SFAA' and languagetype = 'en' and Labeltype = 'jspop';
delimiter;

UPDATE ld_quickactions set presence=0 where presence=5 AND tabid in(SELECT tabid from ld_tab where `name`='HelpDesk') AND related_tabid in(SELECT tabid from ld_tab where `name`='ServiceReturn');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','DATAINTERFACESTEP8','6.该接口仅支持单账套对接，即一个CRM系统账套只对接一个ERP系统。','fixedstr' from DUAL
where not exists(select 1 from ld_desk where languagetype = 'zh' and labelbol = 'DATAINTERFACESTEP8' and labeltype = 'fixedstr'); 
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','DATAINTERFACESTEP8','6.The interface only supports single account docking, that is, a CRM system account only for docking a ERP system.','fixedstr' from DUAL
where not exists(select 1 from ld_desk where languagetype = 'en' and labelbol = 'DATAINTERFACESTEP8' and labeltype = 'fixedstr'); 
delimiter;

update ld_desk set fieldlabel = 'ERP接口信息' where labelbol = 'LBL_DATAINTERFACE_SETTING' and languagetype ='zh' and Labeltype = 'fixedstr';
update ld_desk set fieldlabel = 'ERP Interface Information' where labelbol = 'LBL_DATAINTERFACE_SETTING' and languagetype ='en' and Labeltype = 'fixedstr';
delimiter;

update ld_desk set fieldlabel = '设置ERP接口账套信息' where labelbol = 'LBL_SETTING_DATAINTERFACE_DEMOINFO' and languagetype ='zh' and Labeltype = 'fixedstr';
update ld_desk set fieldlabel = 'Set ERP interface account information' where labelbol = 'LBL_SETTING_DATAINTERFACE_DEMOINFO' and languagetype ='en' and Labeltype = 'fixedstr';
delimiter;

select usereportid into @usereportid from ld_usereport where `name` = 'Performancestatisticscollection';
update ld_usereportcolumns set realencolumns = 'ld_salesorder:Atotal:Atotal:OftenUseReport_Order Received Amount:N' where Usereportid = @usereportid and `columns` = 'ld_cashbill:Atotal:Atotal:OftenUseReport_Atotal:N';
delimiter;

update ld_option_showtableheader  set from_clause='[{"tablename":"ld_inventoryproductrel","othertablename":"", "jointype":"left","joincontent":"ld_inventoryproductrel.id=ld_stock.stock_id"},
{"tablename":"fun:getPurchaseInvoice_date_amount","othertablename":"crminvoice", "jointype":"left","joincontent":"crminvoice.entitytypeid=ld_stock.stock_id"},
{"tablename":"sourcetablename","othertablename":"", "jointype":"left","joincontent":"ld_inventoryproductrel.contractid={sourcetablename}"}]' 
 where module='purchaseinvoice' and selectmodule='stock';

update ld_option_showtableheader  set from_clause='[{"tablename":"ld_inventoryproductrel","othertablename":"", "jointype":"left","joincontent":"ld_inventoryproductrel.id=ld_outboundorder.out_id"},
{"tablename":"fun:getInvoice_date_amount","othertablename":"crminvoice", "jointype":"left","joincontent":"crminvoice.entitytypeid=ld_outboundorder.out_id"},{"tablename":"sourcetablename","othertablename":"", "jointype":"left","joincontent":"ld_inventoryproductrel.contractid={sourcetablename}"}]' 
 where module='invoice' and selectmodule='outboundorder';
delimiter;

update ld_desk set fieldlabel = '当{$Accounts.Accounts}访问权为私有时: {$Potentials.Potentials}、{$HelpDesk.HelpDesk}、{$Quotes.Quotes}、{$SalesOrder.SalesOrder}、{$Invoice.Invoice} 访问权限必须设为私有'
where labelbol = 'ACCOUNT_ACCESS_INFO' and languagetype = 'zh' and Labeltype = 'jspop';
delimiter;

select tabid into @tabid from ld_tab where `name` = 'Invoice';
update ld_field set displaytype = 2 where tabid = @tabid and columnname = 'stockpresence';
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','LBL_TEMPLATENAME_EXIST','模板名称已经存在','fixedstr' from DUAL
where not exists(select 1 from ld_desk where languagetype ='zh' and labelbol = 'LBL_TEMPLATENAME_EXIST' and labeltype = 'fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','LBL_TEMPLATENAME_EXIST','Template name already exists','fixedstr' from DUAL
where not exists(select 1 from ld_desk where languagetype ='en' and labelbol = 'LBL_TEMPLATENAME_EXIST' and labeltype = 'fixedstr');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','UPLOADUPTP20PICTURES','最多上传20张图片，支持类型：jpg、jpeg、gif、png、bmp、ico','fixedstr' from DUAL
where not exists(select 1 from ld_desk where languagetype ='zh' and labelbol = 'UPLOADUPTP20PICTURES' and labeltype = 'fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','UPLOADUPTP20PICTURES','Upload up to 20 pictures, support type: JPG, JPEG, GIF, PNG, BMP, ICO
','fixedstr' from DUAL
where not exists(select 1 from ld_desk where languagetype ='en' and labelbol = 'UPLOADUPTP20PICTURES' and labeltype = 'fixedstr');
delimiter;

CALL AddColumn('ld_account','qualifymaturitydate','date','','');
delimiter;
CALL AddColumn('ld_vendor','qualifymaturitydate','date','','');
delimiter;
CALL AddColumn('ld_products','regmaturitydate','date','','');
delimiter;

select tabid into @tabid from ld_tab where name='Accounts';
insert into ld_field(tabid,fieldid,columnname,tablename,uitype,fieldname,fieldlabel,block,displaytype,presence,typeofdata)
select @tabid,(select max(fieldid) from ld_field)+1,'qualifymaturitydate','ld_account',5,'qualifymaturitydate','资质到期日',(select blockid from ld_blocks where blocklabel='LBL_ACCOUNT_INFORMATION' and tabid = @tabid),1,1,'D~M' from dual where not EXISTS(select * from ld_field where tabid=@tabid and columnname='qualifymaturitydate');

select fieldid into @fieldid from ld_field where tabid = @tabid and fieldname = 'qualifymaturitydate';
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'zh','ld_field',@tabid,@fieldid,'资质到期日' 
from dual where not EXISTS(select 1 from ld_tranlabel  where languagetype = 'zh' 
and trantable ='ld_field' and tabid = @tabid and relateid=@fieldid);
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'en','ld_field',@tabid,@fieldid,'Qualifications Maturity Date' 
from dual where not EXISTS(select 1 from ld_tranlabel  where languagetype = 'en' 
and trantable ='ld_field' and tabid = @tabid and relateid=@fieldid);  

select tabid into @tabid from ld_tab where name='Vendors';
insert into ld_field(tabid,fieldid,columnname,tablename,uitype,fieldname,fieldlabel,block,displaytype,presence,typeofdata)
select @tabid,(select max(fieldid) from ld_field)+1,'qualifymaturitydate','ld_vendor',5,'qualifymaturitydate','资质到期日',(select blockid from ld_blocks where blocklabel='LBL_VENDOR_INFORMATION' and tabid = @tabid),1,1,'D~M' from dual where not EXISTS(select * from ld_field where tabid=@tabid and columnname='qualifymaturitydate');

select fieldid into @fieldid from ld_field where tabid = @tabid and fieldname = 'qualifymaturitydate';
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'zh','ld_field',@tabid,@fieldid,'资质到期日' 
from dual where not EXISTS(select 1 from ld_tranlabel  where languagetype = 'zh' 
and trantable ='ld_field' and tabid = @tabid and relateid=@fieldid);
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'en','ld_field',@tabid,@fieldid,'Qualifications Maturity Date' 
from dual where not EXISTS(select 1 from ld_tranlabel  where languagetype = 'en' 
and trantable ='ld_field' and tabid = @tabid and relateid=@fieldid);

select tabid into @tabid from ld_tab where name='Products';
insert into ld_field(tabid,fieldid,columnname,tablename,uitype,fieldname,fieldlabel,block,displaytype,presence,typeofdata)
select @tabid,(select max(fieldid) from ld_field)+1,'regmaturitydate','ld_products',5,'regmaturitydate','注册证到期日',(select blockid from ld_blocks where blocklabel='LBL_PRODUCT_INFORMATION' and tabid = @tabid),1,1,'D~M' from dual where not EXISTS(select * from ld_field where tabid=@tabid and columnname='regmaturitydate');

select fieldid into @fieldid from ld_field where tabid = @tabid and fieldname = 'regmaturitydate';
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'zh','ld_field',@tabid,@fieldid,'注册证到期日' 
from dual where not EXISTS(select 1 from ld_tranlabel  where languagetype = 'zh' 
and trantable ='ld_field' and tabid = @tabid and relateid=@fieldid);
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'en','ld_field',@tabid,@fieldid,'The Registration Card Maturity Date' 
from dual where not EXISTS(select 1 from ld_tranlabel  where languagetype = 'en' 
and trantable ='ld_field' and tabid = @tabid and relateid=@fieldid);

insert into ld_desk (languagetype,labelbol,fieldlabel,labeltype)
select 'zh','QUALIFYMATURITYDATEEXPIRED','保存失败！原因：该%s的%s已经过期。','fixedstr' from dual 
where not EXISTS(select 1 from ld_desk where  labelbol= 'QUALIFYMATURITYDATEEXPIRED' and labeltype='fixedstr' and languagetype='zh');
insert into ld_desk (languagetype,labelbol,fieldlabel,labeltype)
select 'en','QUALIFYMATURITYDATEEXPIRED','Save failed! Reason: the %s of the %s has expired.','fixedstr' from dual 
where not EXISTS(select 1 from ld_desk where  labelbol= 'QUALIFYMATURITYDATEEXPIRED' and labeltype='fixedstr' and languagetype='en');
delimiter;

insert into ld_desk (languagetype,labelbol,fieldlabel,labeltype)
select 'zh','REGMATURITYDATEEXPIRED','保存失败！原因：{$Products.Products}[%s]{$Products.regmaturitydate}已经过期。','fixedstr' from dual 
where not EXISTS(select 1 from ld_desk where  labelbol= 'REGMATURITYDATEEXPIRED' and labeltype='fixedstr' and languagetype='zh');
insert into ld_desk (languagetype,labelbol,fieldlabel,labeltype)
select 'en','REGMATURITYDATEEXPIRED','Save failed! Reason: the {$Products.regmaturitydate} of the {$Products.Products} [%s] has expired.','fixedstr' from dual 
where not EXISTS(select 1 from ld_desk where  labelbol= 'REGMATURITYDATEEXPIRED' and labeltype='fixedstr' and languagetype='en');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','LBL_SMS_USERINFO','用户名或密码有误，请重新输入！','fixedstr' from DUAL
where not exists(select 1 from ld_desk where languagetype ='zh' and labelbol = 'LBL_SMS_USERINFO' and labeltype = 'fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','LBL_SMS_USERINFO','User name or password is incorrect, please re-enter!','fixedstr' from DUAL
where not exists(select 1 from ld_desk where languagetype ='en' and labelbol = 'LBL_SMS_USERINFO' and labeltype = 'fixedstr');
delimiter;
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','LBL_SMS_DELACCOUNT','账户已停用！','fixedstr' from DUAL
where not exists(select 1 from ld_desk where languagetype ='zh' and labelbol = 'LBL_SMS_DELACCOUNT' and labeltype = 'fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','LBL_SMS_DELACCOUNT','Account is disabled!','fixedstr' from DUAL
where not exists(select 1 from ld_desk where languagetype ='en' and labelbol = 'LBL_SMS_DELACCOUNT' and labeltype = 'fixedstr');
delimiter;


select usereportid into @usereportid from ld_usereport where `name`='Performancestatisticscollection';
update ld_usereportcolumns set realcolumns = 'ld_cashbill:Atotal:Atotal:OftenUseReport_合同已收总额:N' where Usereportid=@usereportid and `columns` = 'ld_cashbill:Atotal:Atotal:OftenUseReport_Atotal:N';
delimiter;

select usereportid into @usereportid from ld_usereport where `name`='Performancestatisticscollection';
update ld_usereportcolumns set realcolumns='ld_salesordercost:productcost:productcost:OftenUseReport_产品成本合计:N' 
where Usereportid=@usereportid and `columns` like 'ld_salesordercost:productcost:productcost%' and realcolumns like '%销售成本合计%';
delimiter;

update ld_cashbill2paymentplan set entitytype='PaymentPlan',entitytypeid=paymentplanid where paymentplanid>0;
update ld_sendcashbill2payment set entitytypeid=sendpaymentid,entitytype='SendPayment' where sendpaymentid>0;
delimiter; 

DROP TRIGGER IF EXISTS `update_by_salesorder1`;
call update_sales_total3();
delimiter; 
call update_purs_total1();
delimiter; 

DROP TRIGGER IF EXISTS `update_by_salesorder1`;
delimiter ||
CREATE TRIGGER `update_by_salesorder1` BEFORE UPDATE ON `ld_salesorder` FOR EACH ROW 
BEGIN 
	set new.receivable_balance=round(ifnull(new.total,0)-ifnull(new.received_amount,0),2);		
END ||
delimiter; 

select fieldid into @fieldid from ld_field where tabid=14 and columnname='costprice';
update ld_tranlabel set fieldlabel='参考成本价(RMB)' WHERE tabid=14 and trantable='ld_field' and Relateid=@fieldid and languagetype='zh' and fieldlabel='参考成本价';
update ld_tranlabel set fieldlabel='Reference CostPrice(RMB)' WHERE tabid=14 and trantable='ld_field' and Relateid=@fieldid and languagetype='en' and fieldlabel='Reference CostPrice';
delimiter;

select usereportid into @usereportid from ld_usereport where `name`='SendCashBillSum_PurchaseOrder';
update ld_usereportcolumns set `columns`='ld_purchaseorder:signed_data:signed_data:PurchaseOrder_Signed Data:DT',
	realcolumns='ld_purchaseorder:signed_data:signed_data:PurchaseOrder_签约日期:DT',realencolumns='ld_purchaseorder:signed_data:signed_data:PurchaseOrder_Signed Data:DT'
where usereportid=@usereportid and `columns` like 'ld_crmentity:createdtime:createdtime%';
delimiter;

select usereportid into @usereportid from ld_usereport where `name`='SendCashBillSum_PurchaseOrder';
update ld_usereportcolumns set `columns`='ld_purchaseorder:signed_data:signed_data:PurchaseOrder_Signed Data:DT',
	realcolumns='ld_purchaseorder:signed_data:signed_data:PurchaseOrder_签约日期:DT',realencolumns='ld_purchaseorder:signed_data:signed_data:PurchaseOrder_Signed Data:DT'
where usereportid=@usereportid and `columns` like 'ld_purchaseorder:signed_data:signed_data%';
delimiter;

select usereportid into @usereportid from ld_usereport where `name`='SendCashBillSum_PurchaseOrder';
update ld_usereportbasic set `columns`='ld_purchaseorder:signed_data:signed_data:PurchaseOrder_signed_data:D' where Usereportid=@usereportid
	and `columns` like '%ld_purchaseorder:duedate:duedate%';
delimiter;
-- 2016-11-04

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
delimiter;

update ld_version set old_version='V6.5.1' ,current_version='V6.5.1' ,remark='V6.5.1-20161104';
delimiter;