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

DROP TRIGGER IF EXISTS `update_account_lastservicedate`;
delimiter ||
CREATE TRIGGER `update_account_lastservicedate` AFTER INSERT ON `ld_maxservicedate` FOR EACH ROW BEGIN 

IF NEW.accountid>0 THEN
	update ld_account set lastservicedate=(SELECT max(service_enddate) from ld_maxservicedate where accountid=NEW.accountid);
END IF;

END ||
delimiter;

update ld_desk set fieldlabel='Statistics of Receivables Acc To Payment Plan' where labelbol='CashBillSum_Paymentplan' AND languagetype='en';
delimiter;

select usereportid into @usereportid from ld_usereport where `name` = 'Serviceperformanceappraisal';
update ld_usereportcolumns set `columns` = 'ld_troubletickets:category:category:HelpDesk_category:V',
realcolumns = 'ld_troubletickets:category:category:HelpDesk_故障类别:V',
realencolumns='ld_troubletickets:category:category:HelpDesk_Failure category:V' 
where `columns` = 'ld_troubletickets:ticketcategories:ticketcategories:HelpDesk_ticketcategories:V' and Usereportid = @usereportid;
delimiter;

select usereportid into @usereportid from ld_usereport where `name` = 'SalesSumSequence';
update ld_usereportcolumns set `columns` = 'ld_servicecontracts:servicecontractstotal:servicecontractstotal:oftenusereport_servicecontractstotal:N'
where `columns` = 'ld_servicecontracts:servicecontractstotal:oftenusereport_servicecontractstotal:N' and Usereportid = @usereportid;
update ld_usereportcolumns set `columns` = 'ld_servicecontracts:servicecontractscount:servicecontractscount:oftenusereport_servicecontractscount:N'
where `columns` = 'ld_servicecontracts:servicecontractscount:oftenusereport_servicecontractscount:N' and Usereportid = @usereportid;
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
  select 'zh','BACKAMOUNTMONTHYEAR','回款金额同比 ','fixedstr' from dual
  where not exists(select 1 from ld_desk where labelbol = 'BACKAMOUNTMONTHYEAR' and languagetype = 'zh' and labeltype = 'fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
  select 'en','BACKAMOUNTMONTHYEAR','Received Amount Year-on-year','fixedstr' from dual
  where not exists(select 1 from ld_desk where labelbol = 'BACKAMOUNTMONTHYEAR' and languagetype = 'en' and labeltype = 'fixedstr');
delimiter;

call AddColumn('ld_salesorder','have_invoicetotal','decimal','20',0); 
call AddColumn('ld_salesorder','nothave_invoicetotal','decimal','20',0);
call AddColumn('ld_salesorder','lastinvoicedate','date','',0); 
call AddColumn('ld_servicecontracts','have_invoicetotal','decimal','20',0); 
call AddColumn('ld_servicecontracts','nothave_invoicetotal','decimal','20',0); 
call AddColumn('ld_servicecontracts','lastinvoicedate','date','',0); 
call AddColumn('ld_outboundorder','have_invoicetotal','decimal','20',0); 
call AddColumn('ld_outboundorder','nothave_invoicetotal','decimal','20',0); 
call AddColumn('ld_outboundorder','lastinvoicedate','date','',0); 
call AddColumn('ld_purchaseorder','have_invoicetotal','decimal','20',0); 
call AddColumn('ld_purchaseorder','nothave_invoicetotal','decimal','20',0); 
call AddColumn('ld_purchaseorder','lastinvoicedate','date','',0); 
call AddColumn('ld_stock','have_invoicetotal','decimal','20',0); 
call AddColumn('ld_stock','lastinvoicedate','date','',0); 
call AddColumn('ld_stock','lastinvoicedate','date','',0); 
call AddColumn('ld_stock','nothave_invoicetotal','decimal','20',0); 
delimiter; 

select tabid into @tabid from ld_tab where name='salesorder';
select blockid into @blockid from ld_blocks  where blocklabel='LBL_SO_INFORMATION';
insert into ld_field(tabid,fieldid,columnname,tablename,uitype,fieldname,fieldlabel,block,displaytype,presence,typeofdata,generatedtype,sequence,readonly)
  select @tabid,(select max(fieldid) from ld_field)+1,'nothave_invoicetotal','ld_salesorder',72,'nothave_invoicetotal','未开票金额',@blockid,2,0,'N~O',2,2,1 from dual
  where not exists (select 1 from ld_field where tabid = @tabid and columnname = 'nothave_invoicetotal');
select fieldid into @fieldid from ld_field where tabid = @tabid and fieldname = 'nothave_invoicetotal';
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
  select 'zh','ld_field',@tabid,@fieldid,'未开票金额' from dual
  where not EXISTS(select 1 from ld_tranlabel  where languagetype = 'zh' and trantable ='ld_field' and tabid = @tabid and relateid=@fieldid);
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
  select 'en','ld_field',@tabid,@fieldid,'Not the invoice amount' from dual
  where not EXISTS(select 1 from ld_tranlabel  where languagetype = 'en' and trantable ='ld_field' and tabid = @tabid and relateid=@fieldid);


select tabid into @tabid from ld_tab where name='servicecontracts';
select blockid into @blockid from ld_blocks  where blocklabel='LBL_SERVICE_CONTRACT_INFORMATION';
insert into ld_field(tabid,fieldid,columnname,tablename,uitype,fieldname,fieldlabel,block,displaytype,presence,typeofdata,generatedtype,sequence,readonly)
  select @tabid,(select max(fieldid) from ld_field)+1,'nothave_invoicetotal','ld_servicecontracts',72,'nothave_invoicetotal','未开票金额',@blockid,2,0,'N~O',2,2,1 from dual
  where not exists (select 1 from ld_field where tabid = @tabid and columnname = 'nothave_invoicetotal');
select fieldid into @fieldid from ld_field where tabid = @tabid and fieldname = 'nothave_invoicetotal';
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
  select 'zh','ld_field',@tabid,@fieldid,'未开票金额' from dual
  where not EXISTS(select 1 from ld_tranlabel  where languagetype = 'zh' and trantable ='ld_field' and tabid = @tabid and relateid=@fieldid);
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
  select 'en','ld_field',@tabid,@fieldid,'Not the invoice amount' from dual
  where not EXISTS(select 1 from ld_tranlabel  where languagetype = 'en' and trantable ='ld_field' and tabid = @tabid and relateid=@fieldid);


select tabid into @tabid from ld_tab where name='OutboundOrder';
select blockid into @blockid from ld_blocks  where blocklabel='LBL_OUT_INFO';
insert into ld_field(tabid,fieldid,columnname,tablename,uitype,fieldname,fieldlabel,block,displaytype,presence,typeofdata,generatedtype,sequence,readonly)
  select @tabid,(select max(fieldid) from ld_field)+1,'nothave_invoicetotal','ld_outboundorder',72,'nothave_invoicetotal','未开票金额',@blockid,2,0,'N~O',2,2,1 from dual
  where not exists (select 1 from ld_field where tabid = @tabid and columnname = 'nothave_invoicetotal');
select fieldid into @fieldid from ld_field where tabid = @tabid and fieldname = 'nothave_invoicetotal';
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
  select 'zh','ld_field',@tabid,@fieldid,'未开票金额' from dual
  where not EXISTS(select 1 from ld_tranlabel  where languagetype = 'zh' and trantable ='ld_field' and tabid = @tabid and relateid=@fieldid);
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
  select 'en','ld_field',@tabid,@fieldid,'Not the invoice amount' from dual
  where not EXISTS(select 1 from ld_tranlabel  where languagetype = 'en' and trantable ='ld_field' and tabid = @tabid and relateid=@fieldid);


select tabid into @tabid from ld_tab where name='PurchaseOrder';
select blockid into @blockid from ld_blocks  where blocklabel='LBL_PO_INFORMATION';
insert into ld_field(tabid,fieldid,columnname,tablename,uitype,fieldname,fieldlabel,block,displaytype,presence,typeofdata,generatedtype,sequence,readonly)
  select @tabid,(select max(fieldid) from ld_field)+1,'nothave_invoicetotal','ld_purchaseorder',72,'nothave_invoicetotal','未开票金额',@blockid,2,0,'N~O',2,2,1 from dual
  where not exists (select 1 from ld_field where tabid = @tabid and columnname = 'nothave_invoicetotal');
select fieldid into @fieldid from ld_field where tabid = @tabid and fieldname = 'nothave_invoicetotal';
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
  select 'zh','ld_field',@tabid,@fieldid,'未开票金额' from dual
  where not EXISTS(select 1 from ld_tranlabel  where languagetype = 'zh' and trantable ='ld_field' and tabid = @tabid and relateid=@fieldid);
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
  select 'en','ld_field',@tabid,@fieldid,'Not the invoice amount' from dual
  where not EXISTS(select 1 from ld_tranlabel  where languagetype = 'en' and trantable ='ld_field' and tabid = @tabid and relateid=@fieldid);

select tabid into @tabid from ld_tab where name='stock';
select blockid into @blockid from ld_blocks  where blocklabel='LBL_WARE_INFO';
insert into ld_field(tabid,fieldid,columnname,tablename,uitype,fieldname,fieldlabel,block,displaytype,presence,typeofdata,generatedtype,sequence,readonly)
  select @tabid,(select max(fieldid) from ld_field)+1,'nothave_invoicetotal','ld_stock',72,'nothave_invoicetotal','未开票金额',@blockid,2,0,'N~O',2,2,1 from dual
  where not exists (select 1 from ld_field where tabid = @tabid and columnname = 'nothave_invoicetotal');
select fieldid into @fieldid from ld_field where tabid = @tabid and fieldname = 'nothave_invoicetotal';
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
  select 'zh','ld_field',@tabid,@fieldid,'未开票金额' from dual
  where not EXISTS(select 1 from ld_tranlabel  where languagetype = 'zh' and trantable ='ld_field' and tabid = @tabid and relateid=@fieldid);
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
  select 'en','ld_field',@tabid,@fieldid,'Not the invoice amount' from dual
  where not EXISTS(select 1 from ld_tranlabel  where languagetype = 'en' and trantable ='ld_field' and tabid = @tabid and relateid=@fieldid);


call getallprofile('salesorder');
call getallprofile('servicecontracts');
call getallprofile('outboundorder');
call getallprofile('stock');
call getallprofile('purchaseorder');
delimiter;

update ld_salesorder  LEFT JOIN
(

SELECT 
						max(ld_invoice.invoicedate) as invoicedate,
										
										ld_inventoryproductrel.entitytypeid, 
										sum(
												if(ld_invoice.currency_id > 1,
														round( 
																ld_inventoryproductrel.taxprice * ld_inventoryproductrel.quantity * ( 100 - ifnull( 
																ld_inventoryproductrel.discount_percent, 0.00 ) 
														) * 0.01 - ifnull(ld_inventoryproductrel.discount_amount,0) + 0.000001, 2 )/ld_invoice.conversion_rate,
														round( 
																ld_inventoryproductrel.taxprice * ld_inventoryproductrel.quantity * ( 100 - ifnull( 
																ld_inventoryproductrel.discount_percent, 0.00 ) 
														) * 0.01 - ifnull(ld_inventoryproductrel.discount_amount,0) + 0.000001, 2 )
												 ) 
										) AS invoicetotal 
										FROM 
										ld_invoice 
										LEFT JOIN ld_inventoryproductrel ON ld_inventoryproductrel.id = ld_invoice.invoiceid 
										WHERE 
										ld_invoice.deleted = 0 and ifnull(ld_invoice.invoicestatus,'') != '已作废'
										GROUP BY 	ld_inventoryproductrel.entitytypeid) as tmp_invoiceinventory on tmp_invoiceinventory.entitytypeid=ld_salesorder.salesorderid

set have_invoicetotal=if(ld_salesorder.currency_id=1,ifnull(tmp_invoiceinventory.invoicetotal,0),ifnull(tmp_invoiceinventory.invoicetotal,0)*ld_salesorder.conversion_rate),
nothave_invoicetotal=total-have_invoicetotal,lastinvoicedate=tmp_invoiceinventory.invoicedate;



update ld_servicecontracts  LEFT JOIN
(

SELECT 
						max(ld_invoice.invoicedate) as invoicedate,
										
										ld_inventoryproductrel.entitytypeid, 
										sum(
												if(ld_invoice.currency_id > 1,
														round( 
																ld_inventoryproductrel.taxprice * ld_inventoryproductrel.quantity * ( 100 - ifnull( 
																ld_inventoryproductrel.discount_percent, 0.00 ) 
														) * 0.01 - ifnull(ld_inventoryproductrel.discount_amount,0) + 0.000001, 2 )/ld_invoice.conversion_rate,
														round( 
																ld_inventoryproductrel.taxprice * ld_inventoryproductrel.quantity * ( 100 - ifnull( 
																ld_inventoryproductrel.discount_percent, 0.00 ) 
														) * 0.01 - ifnull(ld_inventoryproductrel.discount_amount,0) + 0.000001, 2 )
												 ) 
										) AS invoicetotal 
										FROM 
										ld_invoice 
										LEFT JOIN ld_inventoryproductrel ON ld_inventoryproductrel.id = ld_invoice.invoiceid 
										WHERE 
										ld_invoice.deleted = 0 and ifnull(ld_invoice.invoicestatus,'') != '已作废'
										GROUP BY 	ld_inventoryproductrel.entitytypeid) as tmp_invoiceinventory on tmp_invoiceinventory.entitytypeid=ld_servicecontracts.servicecontractsid

set have_invoicetotal=if(ld_servicecontracts.currency_id=1,ifnull(tmp_invoiceinventory.invoicetotal,0),ifnull(tmp_invoiceinventory.invoicetotal,0)*ld_servicecontracts.conversion_rate),
nothave_invoicetotal=total-have_invoicetotal,lastinvoicedate=tmp_invoiceinventory.invoicedate;




update ld_outboundorder  LEFT JOIN
(

SELECT 
						max(ld_invoice.invoicedate) as invoicedate,
										
										ld_inventoryproductrel.entitytypeid, 
										sum(
												if(ld_invoice.currency_id > 1,
														round( 
																ld_inventoryproductrel.taxprice * ld_inventoryproductrel.quantity * ( 100 - ifnull( 
																ld_inventoryproductrel.discount_percent, 0.00 ) 
														) * 0.01 - ifnull(ld_inventoryproductrel.discount_amount,0) + 0.000001, 2 )/ld_invoice.conversion_rate,
														round( 
																ld_inventoryproductrel.taxprice * ld_inventoryproductrel.quantity * ( 100 - ifnull( 
																ld_inventoryproductrel.discount_percent, 0.00 ) 
														) * 0.01 - ifnull(ld_inventoryproductrel.discount_amount,0) + 0.000001, 2 )
												 ) 
										) AS invoicetotal 
										FROM 
										ld_invoice 
										LEFT JOIN ld_inventoryproductrel ON ld_inventoryproductrel.id = ld_invoice.invoiceid 
										WHERE 
										ld_invoice.deleted = 0 and ifnull(ld_invoice.invoicestatus,'') != '已作废'
										GROUP BY 	ld_inventoryproductrel.entitytypeid) as tmp_invoiceinventory on tmp_invoiceinventory.entitytypeid=ld_outboundorder.out_id

set have_invoicetotal=if(ld_outboundorder.currency_id=1,ifnull(tmp_invoiceinventory.invoicetotal,0),ifnull(tmp_invoiceinventory.invoicetotal,0)*ld_outboundorder.conversion_rate),
nothave_invoicetotal=total-have_invoicetotal,lastinvoicedate=tmp_invoiceinventory.invoicedate;



update ld_purchaseorder  LEFT JOIN
(
SELECT 
                         max(ld_purchaseinvoice.purchaseinvoicedate) AS invoicedate,
                                ld_purchaseinvoice.currency_id, 
                                ld_inventoryproductrel.entitytypeid, 
                                sum(
                                    if(ld_purchaseinvoice.currency_id > 1,
                                        round( 
                                            ld_inventoryproductrel.taxprice * ld_inventoryproductrel.quantity * ( 100 - ifnull( 
                                            ld_inventoryproductrel.discount_percent, 0.00 ) 
                                        ) * 0.01 - ifnull(ld_inventoryproductrel.discount_amount,0) + 0.000001, 2 )/ld_purchaseinvoice.conversion_rate,
                                        round( 
                                            ld_inventoryproductrel.taxprice * ld_inventoryproductrel.quantity * ( 100 - ifnull( 
                                            ld_inventoryproductrel.discount_percent, 0.00 ) 
                                        ) * 0.01 - ifnull(ld_inventoryproductrel.discount_amount,0) + 0.000001, 2 )
                                     ) 
                                ) AS invoicetotal 
                                FROM 
                                ld_purchaseinvoice 
                                LEFT JOIN ld_inventoryproductrel ON ld_inventoryproductrel.id = ld_purchaseinvoice.purchaseinvoiceid 
                                WHERE 
                                ld_purchaseinvoice.deleted = 0 and ld_purchaseinvoice.purchaseinvoicestatus != '已作废'
                                GROUP BY 
                                ld_inventoryproductrel.entitytypeid ) as tmp_invoiceinventory on tmp_invoiceinventory.entitytypeid=ld_purchaseorder.purchaseorderid

set have_invoicetotal=if(ld_purchaseorder.currency_id=1,ifnull(tmp_invoiceinventory.invoicetotal,0),ifnull(tmp_invoiceinventory.invoicetotal,0)*ld_purchaseorder.conversion_rate),
nothave_invoicetotal=total-ifnull(have_invoicetotal,0),lastinvoicedate=tmp_invoiceinventory.invoicedate;


update ld_stock  LEFT JOIN
(
SELECT 
                         max(ld_purchaseinvoice.purchaseinvoicedate) AS invoicedate,
                                ld_purchaseinvoice.currency_id, 
                                ld_inventoryproductrel.entitytypeid, 
                                sum(
                                    if(ld_purchaseinvoice.currency_id > 1,
                                        round( 
                                            ld_inventoryproductrel.taxprice * ld_inventoryproductrel.quantity * ( 100 - ifnull( 
                                            ld_inventoryproductrel.discount_percent, 0.00 ) 
                                        ) * 0.01 - ifnull(ld_inventoryproductrel.discount_amount,0) + 0.000001, 2 )/ld_purchaseinvoice.conversion_rate,
                                        round( 
                                            ld_inventoryproductrel.taxprice * ld_inventoryproductrel.quantity * ( 100 - ifnull( 
                                            ld_inventoryproductrel.discount_percent, 0.00 ) 
                                        ) * 0.01 - ifnull(ld_inventoryproductrel.discount_amount,0) + 0.000001, 2 )
                                     ) 
                                ) AS invoicetotal 
                                FROM 
                                ld_purchaseinvoice 
                                LEFT JOIN ld_inventoryproductrel ON ld_inventoryproductrel.id = ld_purchaseinvoice.purchaseinvoiceid 
                                WHERE 
                                ld_purchaseinvoice.deleted = 0 and ld_purchaseinvoice.purchaseinvoicestatus != '已作废'
                                GROUP BY 
                                ld_inventoryproductrel.entitytypeid ) as tmp_invoiceinventory on tmp_invoiceinventory.entitytypeid=ld_stock.stock_id

set have_invoicetotal=if(ld_stock.currency_id=1,ifnull(tmp_invoiceinventory.invoicetotal,0),ifnull(tmp_invoiceinventory.invoicetotal,0)*ld_stock.conversion_rate),
nothave_invoicetotal=total-ifnull(have_invoicetotal,0),lastinvoicedate=tmp_invoiceinventory.invoicedate;
delimiter;

update ld_field set columnname='potentialid',fieldname='potentialid',uitype=76 where tabid in(select tabid from ld_tab where name='servicecharge') and columnname='lastpotential';
delimiter;
-- 2016-11-09

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'zh','PREVIEWPICTURE','查看图片','fixedstr' from dual 
where not EXISTS(select 1 from ld_desk where languagetype='zh' and labelbol='PREVIEWPICTURE' and Labeltype='fixedstr'); 
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'en','PREVIEWPICTURE','Preview Picture ','fixedstr' from dual 
where not EXISTS(select 1 from ld_desk where languagetype='en' and labelbol='PREVIEWPICTURE' and Labeltype='fixedstr'); 
delimiter;

select usereportid into @usereportid from ld_usereport where `name` = 'SIGNINSTATISTICS';
update ld_usereportcolumns set realencolumns = 'ld_users:last_name:last_name:OftenUseReport_Lastname:V'
where Usereportid = @usereportid and `columns` = 'ld_users:last_name:last_name:OftenUseReport_职员:V';
delimiter;

select usereportid into @usereportid from ld_usereport where `name` = 'SIGNINSTATISTICS';
update ld_usereportcolumns set realencolumns = 'ld_singin:createdtime:signedtime:OftenUseReport_Sign in Time:D'
where Usereportid = @usereportid and `columns` = 'ld_singin:createdtime:signedtime:OftenUseReport_签到时间:D';
delimiter;

select usereportid into @usereportid from ld_usereport where `name` = 'SIGNINSTATISTICS';
update ld_usereportcolumns set realencolumns = 'ld_singin:address:address:OftenUseReport_Sing in Address:V'
where Usereportid = @usereportid and `columns` = 'ld_singin:address:address:OftenUseReport_签到地址:V';
delimiter;

select usereportid into @usereportid from ld_usereport where `name` = 'SIGNINSTATISTICS';
update ld_usereportcolumns set realencolumns = 'ld_accounts:accountname:accountname:OftenUseReport_Sing in Customer:V'
where Usereportid = @usereportid and `columns` = 'ld_accounts:accountname:accountname:OftenUseReport_签到客户:V';
delimiter;

select usereportid into @usereportid from ld_usereport where `name` = 'SIGNINSTATISTICS';
update ld_usereportcolumns set realencolumns = 'ld_singin:content:content:OftenUseReport_Remark:V'
where Usereportid = @usereportid and `columns` = 'ld_singin:content:content:OftenUseReport_备注:V';
delimiter;

select usereportid into @usereportid from ld_usereport where `name` = 'SIGNINSTATISTICS';
update ld_usereportcolumns set realencolumns = 'ld_accounts:bill_street:bill_street:OftenUseReport_Related To Customer Address:V'
where Usereportid = @usereportid and `columns` = 'ld_accountbillads:bill_street:ship_street:OftenUseReport_相关客户地址（CRM系统数据）:V';
delimiter;

select usereportid into @usereportid from ld_usereport where `name` = 'SIGNINSTATISTICS';
update ld_usereportcolumns set realencolumns = 'ld_singin:uuid:uuid:OftenUseReport_Mobile ID:V'
where Usereportid = @usereportid and `columns` = 'ld_singin:uuid:uuid:OftenUseReport_手机id:V';
delimiter;

select usereportid into @usereportid from ld_usereport where `name` = 'SIGNINSTATISTICS';
update ld_usereportcolumns set realencolumns = 'ld_singin:distance:distance:OftenUseReport_Distance(m):N'
where Usereportid = @usereportid and `columns` = 'ld_singin:distance:distance:OftenUseReport_距离(米):N';
delimiter;
delimiter;
select usereportid into @usereportid from ld_usereport where `name` = 'SalesOrderTrack';
update ld_usereportcolumns set realencolumns='ld_crmentity:smownerid:assigned_user_id:SalesOrder_Assigned To:V' 
where columns='ld_crmentity:smownerid:assigned_user_id:SalesOrder_assigned_user_id:V' AND Usereportid = @usereportid;
delimiter;
select usereportid into @usereportid from ld_usereport where `name` = 'SalesOrderTrack';
update ld_usereportcolumns set realencolumns='ld_salesorder:signed_data:signed_data:SalesOrder_Date of Contract:D' 
where columns='ld_salesorder:signed_data:signed_data:SalesOrder_signed_data:D' AND Usereportid = @usereportid;
delimiter;
select usereportid into @usereportid from ld_usereport where `name` = 'SalesOrderTrack';
update ld_usereportcolumns set realencolumns='ld_servicecontracts:module_zh:module_zh:OftenUseReport_Bill Type:V' 
where columns='ld_servicecontracts:module_zh:module_zh:OftenUseReport_module_zh:V' AND Usereportid = @usereportid; 
delimiter;
select usereportid into @usereportid from ld_usereport where `name` = 'SalesOrderTrack';
update ld_usereportcolumns set realencolumns='ld_salesorder:salesorder_no:salesorder_no:SalesOrder_Sales Order No:V' 
where columns='ld_salesorder:salesorder_no:salesorder_no:SalesOrder_salesorder_no:V' AND Usereportid = @usereportid;
delimiter;
select usereportid into @usereportid from ld_usereport where `name` = 'SalesOrderTrack';
update ld_usereportcolumns set realencolumns='ld_accountSalesOrder:accountid:account_id:SalesOrder_Account Name:I'  
where columns='ld_accountSalesOrder:accountid:account_id:SalesOrder_Account_Name:I' AND Usereportid = @usereportid;
delimiter;
select usereportid into @usereportid from ld_usereport where `name` = 'SalesOrderTrack';
update ld_usereportcolumns set realencolumns='ld_salesorder:total:hdnGrandTotal:SalesOrder_Order Total:N'  
where columns='ld_salesorder:total:hdnGrandTotal:SalesOrder_Total:N' AND Usereportid = @usereportid; 
delimiter;
select usereportid into @usereportid from ld_usereport where `name` = 'SalesOrderTrack';
update ld_usereportcolumns set realencolumns='ld_reporttable:CashBillamount:已收款金额:OftenUseReport_CashBill Amount:N' 
where columns='ld_reporttable:CashBillamount:已收款金额:OftenUseReport_CashBillamount:N' AND Usereportid = @usereportid;
delimiter;
select usereportid into @usereportid from ld_usereport where `name` = 'SalesOrderTrack';
update ld_usereportcolumns set realencolumns='ld_reporttable:PaymentPlanBalance:应收款余额:OftenUseReport_Payment Balance:N' 
where columns='ld_reporttable:PaymentPlanBalance:应收款余额:OftenUseReport_PaymentBalance:N' AND Usereportid = @usereportid; 
delimiter;
select usereportid into @usereportid from ld_usereport where `name` = 'SalesOrderTrack';
update ld_usereportcolumns set realencolumns='ld_invoice:total:hdnGrandTotal:Invoice_Invoice Total:N'  
where columns='ld_invoice:total:hdnGrandTotal:Invoice_Total:N' AND Usereportid = @usereportid;
delimiter;
select usereportid into @usereportid from ld_usereport where `name` = 'SalesOrderTrack';
update ld_usereportcolumns set realencolumns='ld_reporttable:InvoiceBalance:开票余额:OftenUseReport_Invoice Balance:N'  
where columns='ld_reporttable:InvoiceBalance:开票余额:OftenUseReport_InvoiceBalance:N' AND Usereportid = @usereportid;
delimiter;
select usereportid into @usereportid from ld_usereport where `name` = 'SalesOrderTrack';
update ld_usereportcolumns set realencolumns='ld_reporttable:Expenseamount:费用金额:OftenUseReport_Expense amount:N'  
where columns='ld_reporttable:Expenseamount:费用金额:OftenUseReport_Expenseamount:N' AND Usereportid = @usereportid;
delimiter;
select usereportid into @usereportid from ld_usereport where `name` = 'SalesOrderTrack';
update ld_usereportcolumns set realencolumns='ld_commission2payment:amount:amount:OftenUseReport_Commission Total:NN'  
where columns='ld_commission2payment:amount:amount:OftenUseReport_Amount:NN' AND Usereportid = @usereportid;
delimiter;
select usereportid into @usereportid from ld_usereport where `name` = 'SalesOrderTrack';
update ld_usereportcolumns set realencolumns='ld_salesorder:TotalCost:成本合计:OftenUseReport_Total Cost:N'  
where columns='ld_salesorder:TotalCost:成本合计:OftenUseReport_TotalCost:N' AND Usereportid = @usereportid;
delimiter;
select usereportid into @usereportid from ld_usereport where `name` = 'SalesOrderTrack';
update ld_usereportcolumns set realencolumns='ld_salesorder:GrossProfit:毛利:OftenUseReport_Gross Profit:N' 
where columns='ld_salesorder:GrossProfit:毛利:OftenUseReport_GrossProfit:N' AND Usereportid = @usereportid; 
delimiter;
select usereportid into @usereportid from ld_usereport where `name` = 'SalesOrderTrack';
update ld_usereportcolumns set realencolumns='ld_salesorder:GrossProfitl:毛利率:OftenUseReport_Gross Profit:N' 
where columns='ld_salesorder:GrossProfitl:毛利率:OftenUseReport_GrossProfitl:N' AND Usereportid = @usereportid; 
delimiter;
select usereportid into @usereportid from ld_usereport where `name` = 'SalesOrderTrack';
update ld_usereportcolumns set realencolumns='ld_salesorder:sostatus:sostatus:SalesOrder_Order Status:V'  
where columns='ld_salesorder:sostatus:sostatus:SalesOrder_sostatus:V' AND Usereportid = @usereportid; 
delimiter;
select usereportid into @usereportid from ld_usereport where `name` = 'SalesOrderTrack';
update ld_usereportcolumns set realencolumns='ld_salesorder:duedate:duedate:SalesOrder_Due Date:D'  
where columns='ld_salesorder:duedate:duedate:SalesOrder_duedate:D' AND Usereportid = @usereportid; 
delimiter;
select usereportid into @usereportid from ld_usereport where `name` = 'SalesOrderTrack';
update ld_usereportcolumns set realencolumns='ld_salesorder:subject:subject:SalesOrder_Subject:V'  
where columns='ld_salesorder:subject:subject:SalesOrder_Subject:V' AND Usereportid = @usereportid; 
delimiter;
select usereportid into @usereportid from ld_usereport where `name` = 'SalesOrderTrack';
update ld_usereportcolumns set realencolumns='ld_crmentity:createdtime:createdtime:SalesOrder_CreatedTime:DT'  
where columns='ld_crmentity:createdtime:createdtime:SalesOrder_CreatedTime:DT' AND Usereportid = @usereportid; 
delimiter;
select usereportid into @usereportid from ld_usereport where `name` = 'SalesOrderTrack';
update ld_usereportcolumns set realencolumns='ld_salesorder:GrossProfitl:毛利率:OftenUseReport_Gross Profitl:N'  
where columns='ld_salesorder:GrossProfitl:毛利率:OftenUseReport_GrossProfitl:N' AND Usereportid = @usereportid; 
delimiter;
select usereportid into @usereportid from ld_usereport where `name` = 'Salesforecastandanalysistable';
update ld_usereportcolumns set realencolumns='ld_potential:lastsales_stage:lastsales_stage:Potentials_lastsales_stage:V' 
where Usereportid = @usereportid  AND `columns`='ld_potential:lastsales_stage:lastsales_stage:Potentials_LastSales_Stage:V';
delimiter;
select usereportid into @usereportid from ld_usereport where `name` = 'CashBillSum_Paymentplan';
update ld_usereportcolumns set realencolumns='ld_paymentplan:smownerid:assigned_user_id:PaymentPlan_Assigned To:V' 
where Usereportid = @usereportid  AND `columns`='ld_paymentplan:smownerid:assigned_user_id:PaymentPlan_assigned_user_id:V';
delimiter;
select usereportid into @usereportid from ld_usereport where `name` = 'CashBillSum_Paymentplan';
update ld_usereportcolumns set realencolumns='ld_salesorder:salesorder_no:salesorder_no:SalesOrder_Order No:V' 
where Usereportid = @usereportid  AND `columns`='ld_salesorder:salesorder_no:salesorder_no:SalesOrder_salesorder_no:V';
delimiter;
select usereportid into @usereportid from ld_usereport where `name` = 'CashBillSum_Paymentplan';
update ld_usereportcolumns set realencolumns='ld_paymentplan:salesorderid:salesorder_id:OftenUseReport_Order:I' 
where Usereportid = @usereportid  AND `columns`='ld_paymentplan:salesorderid:salesorder_id:OftenUseReport_salesorder:I';
delimiter;
select usereportid into @usereportid from ld_usereport where `name` = 'CashBillSum_Paymentplan';
update ld_usereportcolumns set realencolumns='ld_paymentplan:paymentplan_no:paymentplan_no:PaymentPlan_paymentplan_No:I' 
where Usereportid = @usereportid  AND `columns`='ld_paymentplan:paymentplan_no:paymentplan_no:PaymentPlan_paymentplan no:I';
delimiter;
select usereportid into @usereportid from ld_usereport where `name` = 'CashBillSum_Paymentplan';
update ld_usereportcolumns set realencolumns='ld_paymentplan:amount:amount:PaymentPlan_PaymentPlan Amount:N' 
where Usereportid = @usereportid  AND `columns`='ld_paymentplan:amount:amount:PaymentPlan_amount:N';
delimiter;
select usereportid into @usereportid from ld_usereport where `name` = 'CashBillSum_Paymentplan';
update ld_usereportcolumns set realencolumns='ld_paymentplan:actualamount:actualamount:PaymentPlan_plan Amount Received:V' 
where Usereportid = @usereportid  AND `columns`='ld_paymentplan:actualamount:actualamount:PaymentPlan_actualamount:N';
delimiter;
select usereportid into @usereportid from ld_usereport where `name` = 'CashBillSum_Paymentplan';
update ld_usereportcolumns set realencolumns='ld_paymentplan:paymentstatus:paymentstatus:PaymentPlan_Payment Status:V' 
where Usereportid = @usereportid  AND `columns`='ld_paymentplan:paymentstatus:paymentstatus:PaymentPlan_paymentstatus:V';
delimiter;

select usereportid into @usereportid from ld_usereport where `name` = 'SalesSumSequence';
update ld_usereportcolumns set realencolumns = 'ld_users:last_name:last_name:OftenUseReport_Last Name:V'
where Usereportid = @usereportid and `columns` = 'ld_users:last_name:last_name:OftenUseReport_last_name:V';
delimiter;


select usereportid into @usereportid from ld_usereport where `name` = 'SalesSumSequence';
update ld_usereportcolumns set realencolumns = 'ld_account:accountcount:accountcount:OftenUseReport_Number of New Customers:N'
where Usereportid = @usereportid and `columns` = 'ld_account:accountcount:accountcount:OftenUseReport_accountcount:N';
delimiter;
select usereportid into @usereportid from ld_usereport where `name` = 'SalesSumSequence';
update ld_usereportcolumns set realencolumns = 'ld_contactdetails:contactcount:contactcount:OftenUseReport_New Contact Number:N'
where Usereportid = @usereportid and `columns` = 'ld_contactdetails:contactcount:contactcount:OftenUseReport_contactcount:N';
delimiter;
select usereportid into @usereportid from ld_usereport where `name` = 'SalesSumSequence';
update ld_usereportcolumns set realencolumns = 'ld_potentials:potentialcount:potentialcount:OftenUseReport_Number of New Opportunities:N'
where Usereportid = @usereportid and `columns` = 'ld_potentials:potentialcount:potentialcount:OftenUseReport_potentialcount:N';
delimiter;
select usereportid into @usereportid from ld_usereport where `name` = 'SalesSumSequence';
update ld_usereportcolumns set realencolumns = 'ld_activies:calendarcount:calendarcount:OftenUseReport_New Schedule:N'
where Usereportid = @usereportid and `columns` = 'ld_activies:calendarcount:calendarcount:OftenUseReport_calendarcount:N';
delimiter;
select usereportid into @usereportid from ld_usereport where `name` = 'SalesSumSequence';
update ld_usereportcolumns set realencolumns = 'ld_contactrecords:contactrecordscount:contactrecordscount:OftenUseReport_New Contact Record:N'
where Usereportid = @usereportid and `columns` = 'ld_contactrecords:contactrecordscount:contactrecordscount:OftenUseReport_contactrecordscount:N';
delimiter;
select usereportid into @usereportid from ld_usereport where `name` = 'SalesSumSequence';
update ld_usereportcolumns set realencolumns = 'ld_troubletickets:helpdeskcount:helpdeskcount:OftenUseReport_Help Desk Count:N'
where Usereportid = @usereportid and `columns` = 'ld_troubletickets:helpdeskcount:helpdeskcount:OftenUseReport_helpdeskcount:N';
delimiter;
select usereportid into @usereportid from ld_usereport where `name` = 'SalesSumSequence';
update ld_usereportcolumns set realencolumns = 'ld_cashbill:cashbilltotal:cashbilltotal:OftenUseReport_Cashbill Total:N'
where Usereportid = @usereportid and `columns` = 'ld_cashbill:cashbilltotal:cashbilltotal:OftenUseReport_cashbilltotal:N';
delimiter;
select usereportid into @usereportid from ld_usereport where `name` = 'SalesSumSequence';
update ld_usereportcolumns set realencolumns = 'ld_cashbill:cashbillcount:cashbillcount:OftenUseReport_Number of Payment:N'
where Usereportid = @usereportid and `columns` = 'ld_cashbill:cashbillcount:cashbillcount:OftenUseReport_cashbillcount:N';
delimiter;
select usereportid into @usereportid from ld_usereport where `name` = 'SalesSumSequence';
update ld_usereportcolumns set realencolumns = 'ld_salesorder:salesordertotal:salesordertotal:OftenUseReport_Salesorder Total:N'
where Usereportid = @usereportid and `columns` = 'ld_salesorder:salesordertotal:salesordertotal:OftenUseReport_salesordertotal:N';
delimiter;
select usereportid into @usereportid from ld_usereport where `name` = 'SalesSumSequence';
update ld_usereportcolumns set realencolumns = 'ld_salesorder:salesordercount:salesordercount:OftenUseReport_Salesorder Count:N'
where Usereportid = @usereportid and `columns` = 'ld_salesorder:salesordercount:salesordercount:OftenUseReport_salesordercount:N';
delimiter;
select usereportid into @usereportid from ld_usereport where `name` = 'SalesSumSequence';
update ld_usereportcolumns set realencolumns = 'ld_servicecontracts:servicecontractstotal:servicecontractstotal:ServiceContracts Total:N'
where Usereportid = @usereportid and `columns` = 'ld_servicecontracts:servicecontractstotal:servicecontractstotal:oftenusereport_servicecontractstotal:N';
delimiter;
select usereportid into @usereportid from ld_usereport where `name` = 'SalesSumSequence';
update ld_usereportcolumns set realencolumns = 'ld_servicecontracts:servicecontractscount:servicecontractscount: ServiceContracts Count:N'
where Usereportid = @usereportid and `columns` = 'ld_servicecontracts:servicecontractscount:servicecontractscount:oftenusereport_servicecontractscount:N';
delimiter;
select usereportid into @usereportid from ld_usereport where `name` = 'Thestatisticalreportofprojectperformance';
update ld_usereportcolumns set realencolumns = 'ld_project:projectname:projectname:Project_Project Name:V'
where Usereportid = @usereportid and `columns` = 'ld_project:projectname:projectname:Project_projectname:V';
delimiter;
select usereportid into @usereportid from ld_usereport where `name` = 'Thestatisticalreportofprojectperformance';
update ld_usereportcolumns set realencolumns = 'ld_project:project_no:project_no:Project_Project No:V'
where Usereportid = @usereportid and `columns` = 'ld_project:project_no:project_no:Project_project_no:V';
delimiter;
select usereportid into @usereportid from ld_usereport where `name` = 'Thestatisticalreportofprojectperformance';
update ld_usereportcolumns set realencolumns = 'ld_account:accountname:accountname:Accounts_Amount of Receivables:V'
where Usereportid = @usereportid and `columns` = 'ld_account:accountname:accountname:Accounts_accountname:V';
delimiter;
select usereportid into @usereportid from ld_usereport where `name` = 'Thestatisticalreportofprojectperformance';
update ld_usereportcolumns set realencolumns = 'ld_project:lastname:lastname:OftenUseReport_Person in Charge:V'
where Usereportid = @usereportid and `columns` = 'ld_project:lastname:lastname:OftenUseReport_lastname:V';
delimiter;
select usereportid into @usereportid from ld_usereport where `name` = 'Thestatisticalreportofprojectperformance';
update ld_usereportcolumns set realencolumns = 'ld_project:startdate:startdate:Project_Start Date:D'
where Usereportid = @usereportid and `columns` = 'ld_project:startdate:startdate:Project_startdate:D';
delimiter;
select usereportid into @usereportid from ld_usereport where `name` = 'Thestatisticalreportofprojectperformance';
update ld_usereportcolumns set realencolumns = 'ld_project:projectstatus:projectstatus:Project_Project Status:V'
where Usereportid = @usereportid and `columns` = 'ld_project:projectstatus:projectstatus:Project_projectstatus:V';
delimiter;
select usereportid into @usereportid from ld_usereport where `name` = 'Thestatisticalreportofprojectperformance';
update ld_usereportcolumns set realencolumns = 'ld_project:progress:progress:Project_Gress:V'
where Usereportid = @usereportid and `columns` = 'ld_project:progress:progress:Project_progress:V';
delimiter;
select usereportid into @usereportid from ld_usereport where `name` = 'Thestatisticalreportofprojectperformance';
update ld_usereportcolumns set realencolumns = 'ld_project:targetenddate:targetenddate:Project_Targetend Date:D'
where Usereportid = @usereportid and `columns` = 'ld_project:targetenddate:targetenddate:Project_targetenddate:D';
delimiter;
select usereportid into @usereportid from ld_usereport where `name` = 'Thestatisticalreportofprojectperformance';
update ld_usereportcolumns set realencolumns = 'ld_project:actualenddate:actualenddate:Project_Actualend Date:D'
where Usereportid = @usereportid and `columns` = 'ld_project:actualenddate:actualenddate:Project_actualenddate:D';
delimiter;
select usereportid into @usereportid from ld_usereport where `name` = 'Thestatisticalreportofprojectperformance';
update ld_usereportcolumns set realencolumns = 'ld_salesorder:salesorder_no:salesorder_no:SalesOrder_Order No:D'
where Usereportid = @usereportid and `columns` = 'ld_salesorder:salesorder_no:salesorder_no:SalesOrder_salesorder_no:D';
delimiter;
select usereportid into @usereportid from ld_usereport where `name` = 'Thestatisticalreportofprojectperformance';
update ld_usereportcolumns set realencolumns = 'ld_salesorder:total:total:SalesOrder_Salesorder Total:NN'
where Usereportid = @usereportid and `columns` = 'ld_salesorder:total:total:SalesOrder_total:NN';
delimiter;
select usereportid into @usereportid from ld_usereport where `name` = 'Thestatisticalreportofprojectperformance';
update ld_usereportcolumns set realencolumns = 'ld_cashbill:CashBillamount:CashBillamount:CashBill_CashBill Amount:NN'
where Usereportid = @usereportid and `columns` = 'ld_cashbill:CashBillamount:CashBillamount:CashBill_CashBillamount:NN';
delimiter;
select usereportid into @usereportid from ld_usereport where `name` = 'SendCashBillSum_SendPayment';
update ld_usereportcolumns set realencolumns='ld_crmentity:smownerid:smownerid:SendPayment_Assigned To:V'
where Usereportid = @usereportid and `columns` = 'ld_crmentity:smownerid:smownerid:SendPayment_smownerid:V';
delimiter;
select usereportid into @usereportid from ld_usereport where `name` = 'SendCashBillSum_SendPayment';
update ld_usereportcolumns set realencolumns='ld_purchaseorder:signed_data:signed_data:PurchaseOrder_Date of Contract:D' 
where Usereportid = @usereportid and `columns` = 'ld_purchaseorder:signed_data:signed_data:PurchaseOrder_purchaseorder_signed_data:D';

delimiter;
select usereportid into @usereportid from ld_usereport where `name` = 'SendCashBillSum_SendPayment';
update ld_usereportcolumns set realencolumns='ld_purchaseorder:purchaseorder_no:purchaseorder_no:PurchaseOrder_Purchaseorder No:V' 
where Usereportid = @usereportid and `columns` = 'ld_purchaseorder:purchaseorder_no:purchaseorder_no:PurchaseOrder_purchaseorder_no:V';
delimiter;
select usereportid into @usereportid from ld_usereport where `name` = 'SendCashBillSum_SendPayment';
update ld_usereportcolumns set realencolumns='ld_vendor:vendorid:vendorid:SendPayment_Vendor Name:V'
where Usereportid = @usereportid and `columns` = 'ld_vendor:vendorid:vendorid:SendPayment_vendorid:V';
delimiter;
select usereportid into @usereportid from ld_usereport where `name` = 'SendCashBillSum_SendPayment';
update ld_usereportcolumns set realencolumns='ld_purchaseorder:total:hdnGrandTotal:PurchaseOrder_PurchaseOrder_Total:N:V' 
where Usereportid = @usereportid and `columns` = 'ld_purchaseorder:total:hdnGrandTotal:PurchaseOrder_Total:N';
delimiter;
select usereportid into @usereportid from ld_usereport where `name` = 'SendCashBillSum_SendPayment';
update ld_usereportcolumns set realencolumns='ld_sendpayment:plandate:plandate:SendPayment_PaymentPlan Date:D'
where Usereportid = @usereportid and `columns` = 'ld_sendpayment:plandate:plandate:SendPayment_plandate:D';
delimiter;
select usereportid into @usereportid from ld_usereport where `name` = 'SendCashBillSum_SendPayment';
update ld_usereportcolumns set realencolumns='ld_sendpayment:sendpayment_no:sendpayment_no:SendPayment_Sendpayment No:I'
where Usereportid = @usereportid and `columns` = 'ld_sendpayment:sendpayment_no:sendpayment_no:SendPayment_sendpayment_no:I';
delimiter;
select usereportid into @usereportid from ld_usereport where `name` = 'SendCashBillSum_SendPayment';
update ld_usereportcolumns set realencolumns='ld_sendpayment:Actualdate:Actualdate:SendPayment_Actual Date:V'
where Usereportid = @usereportid and `columns` = 'ld_sendpayment:Actualdate:Actualdate:SendPayment_Actualdate:D';
delimiter;
select usereportid into @usereportid from ld_usereport where `name` = 'SendCashBillSum_SendPayment';
update ld_usereportcolumns set realencolumns='ld_sendpayment:amount:amount:SendPayment_SendPayment Amount:N'
where Usereportid = @usereportid and `columns` = 'ld_sendpayment:amount:amount:SendPayment_amount:N';
delimiter;
select usereportid into @usereportid from ld_usereport where `name` = 'SendCashBillSum_SendPayment';
update ld_usereportcolumns set realencolumns='ld_sendpayment:actualamount:actualamount:SendPayment_Actual Amount:V'
where Usereportid = @usereportid and `columns` = 'ld_sendpayment:actualamount:actualamount:SendPayment_actualamount:N';
delimiter;
select usereportid into @usereportid from ld_usereport where `name` = 'SendCashBillSum_SendPayment';
update ld_usereportcolumns set realencolumns='ld_sendpayment:CPStatus:CPStatus:SendPayment_SendPayment Status:V'
where Usereportid = @usereportid and `columns` = 'ld_sendpayment:CPStatus:CPStatus:SendPayment_CPStatus:V';
delimiter;
select usereportid into @usereportid from ld_usereport where `name` = 'SendCashBillSum_SendPayment';
update ld_usereportcolumns set realencolumns='ld_sendpayment:SendPaymentBalance:SendPaymentBalance:OftenUseReport_SendPayment Balance:N'
where Usereportid = @usereportid and `columns` = 'ld_sendpayment:SendPaymentBalance:SendPaymentBalance:OftenUseReport_SendPaymentBalance:N';
delimiter;
select usereportid into @usereportid from ld_usereport where `name` = 'CashBillSum_SalesOrder';
update ld_usereportcolumns set realencolumns = 'ld_usersSalesOrder:smownerid:assigned_user_id:SalesOrder_Assigned to:V'
where Usereportid = @usereportid and `columns` = 'ld_usersSalesOrder:smownerid:assigned_user_id:SalesOrder_assigned_user_id:V';
delimiter;
select usereportid into @usereportid from ld_usereport where `name` = 'CashBillSum_SalesOrder';
update ld_usereportcolumns set realencolumns = 'ld_salesorder:salesorder_no:salesorder_no:SalesOrder_Order No:V'
where Usereportid = @usereportid and `columns` = 'ld_salesorder:salesorder_no:salesorder_no:SalesOrder_SalesOrder No:V';
delimiter;
select usereportid into @usereportid from ld_usereport where `name` = 'CashBillSum_SalesOrder';
update ld_usereportcolumns set realencolumns = 'ld_salesorder:signed_data:signed_data:SalesOrder_Date of Contract:D'
where Usereportid = @usereportid and `columns` = 'ld_salesorder:signed_data:signed_data:SalesOrder_signed_data:D';
delimiter;
select usereportid into @usereportid from ld_usereport where `name` = 'CashBillSum_SalesOrder';
update ld_usereportcolumns set realencolumns = 'ld_crmentity:createdtime:createdtime:SalesOrder_CreatedTime:DT'
where Usereportid = @usereportid and `columns` = 'ld_crmentity:createdtime:createdtime:SalesOrder_Created Time:DT';
delimiter;
select usereportid into @usereportid from ld_usereport where `name` = 'CashBillSum_SalesOrder';
update ld_usereportcolumns set realencolumns = 'ld_salesorder:subject:subject:SalesOrder_Order Subject:V'
where Usereportid = @usereportid and `columns` = 'ld_salesorder:subject:subject:SalesOrder_Subject:V';
delimiter;
select usereportid into @usereportid from ld_usereport where `name` = 'CashBillSum_SalesOrder';
update ld_usereportcolumns set realencolumns = 'ld_salesorder:accountid:account_id:SalesOrder_AccountName:I'
where Usereportid = @usereportid and `columns` = 'ld_salesorder:accountid:account_id:SalesOrder_Account Name:I';
delimiter;
select usereportid into @usereportid from ld_usereport where `name` = 'CashBillSum_SalesOrder';
update ld_usereportcolumns set realencolumns = 'ld_salesorder:sostatus:sostatus:SalesOrder_Order Status:V'
where Usereportid = @usereportid and `columns` = 'ld_salesorder:sostatus:sostatus:SalesOrder_Status:V';
delimiter;
select usereportid into @usereportid from ld_usereport where `name` = 'CashBillSum_SalesOrder';
update ld_usereportcolumns set realencolumns = 'ld_salesorder:total:hdnGrandTotal:SalesOrder_Order Total:N'
where Usereportid = @usereportid and `columns` = 'ld_salesorder:total:hdnGrandTotal:SalesOrder_Total:N';
delimiter;
select usereportid into @usereportid from ld_usereport where `name` = 'CashBillSum_SalesOrder';
update ld_usereportcolumns set realencolumns = 'ld_reporttable:CashBillamount:已收款金额:OftenUseReport_CashBill Amount:N'
where Usereportid = @usereportid and `columns` = 'ld_reporttable:CashBillamount:已收款金额:OftenUseReport_CashBillamount:N';
delimiter;
select usereportid into @usereportid from ld_usereport where `name` = 'CashBillSum_SalesOrder';
update ld_usereportcolumns set realencolumns = 'ld_reporttable:PaymentBalance:应收款余额:OftenUseReport_Payment Balance:N'
where Usereportid = @usereportid and `columns` = 'ld_reporttable:PaymentBalance:应收款余额:OftenUseReport_PaymentBalance:N';
delimiter;
select usereportid into @usereportid from ld_usereport where `name` = 'PurchaseOrderTrack';
update ld_usereportcolumns set realencolumns = 'ld_crmentity:smownerid:assigned_user_id:PurchaseOrder_Assigned To:V'
where Usereportid = @usereportid and `columns` = 'ld_crmentity:smownerid:assigned_user_id:PurchaseOrder_assigned_user_id:V';
delimiter;
select usereportid into @usereportid from ld_usereport where `name` = 'PurchaseOrderTrack';
update ld_usereportcolumns set realencolumns = 'ld_purchaseorder:duedate:duedate:PurchaseOrder_Due Date:D'
where Usereportid = @usereportid and `columns` = 'ld_purchaseorder:duedate:duedate:PurchaseOrder_duedate:D';
delimiter;
select usereportid into @usereportid from ld_usereport where `name` = 'PurchaseOrderTrack';
update ld_usereportcolumns set realencolumns = 'ld_purchaseorder:postatus:postatus:PurchaseOrder_Purchase Order Status:V'
where Usereportid = @usereportid and `columns` = 'ld_purchaseorder:postatus:postatus:PurchaseOrder_postatus:V';
delimiter;
select usereportid into @usereportid from ld_usereport where `name` = 'PurchaseOrderTrack';
update ld_usereportcolumns set realencolumns = 'ld_purchaseorder:purchaseorder_No:purchaseorder_No:PurchaseOrder_Purchaseorder No'
where Usereportid = @usereportid and `columns` = 'ld_purchaseorder:purchaseorder_No:purchaseorder_No:PurchaseOrder_purchaseorder_No:V';
delimiter;
select usereportid into @usereportid from ld_usereport where `name` = 'PurchaseOrderTrack';
update ld_usereportcolumns set realencolumns = 'ld_purchaseorder:signed_data:signed_data:PurchaseOrder_Date of Contract:D'
where Usereportid = @usereportid and `columns` = 'ld_purchaseorder:signed_data:signed_data:PurchaseOrder_purchaseorder_signed_data:D';
delimiter;
select usereportid into @usereportid from ld_usereport where `name` = 'PurchaseOrderTrack';
update ld_usereportcolumns set realencolumns = 'ld_PurchaseOrder:total:hdnGrandTotal:PurchaseOrder_PurchaseOrder Total:N'
where Usereportid = @usereportid and `columns` = 'ld_PurchaseOrder:total:hdnGrandTotal:PurchaseOrder_Total:N';
delimiter;
select usereportid into @usereportid from ld_usereport where `name` = 'PurchaseOrderTrack';
update ld_usereportcolumns set realencolumns = 'ld_SendCashBill:SendCashBillamount:SendCashBillamount:OftenUseReport_SendCashBill Amount:N'
where Usereportid = @usereportid and `columns` = 'ld_SendCashBill:SendCashBillamount:SendCashBillamount:OftenUseReport_SendCashBillamount:N';
delimiter;
select usereportid into @usereportid from ld_usereport where `name` = 'PurchaseOrderTrack';
update ld_usereportcolumns set realencolumns = 'ld_vendor:vendorname:vendorname:Vendors_Vendor Name:V'
where Usereportid = @usereportid and `columns` = 'ld_vendor:vendorname:vendorname:Vendors_vendorname:V';
delimiter;
select usereportid into @usereportid from ld_usereport where `name` = 'PurchaseOrderTrack';
update ld_usereportcolumns set realencolumns = 'ld_purchaseorder:subject:subject:PurchaseOrder_PurchaseOrder Subject:V'
where Usereportid = @usereportid and `columns` = 'ld_purchaseorder:subject:subject:PurchaseOrder_Subject:V';
delimiter;
select usereportid into @usereportid from ld_usereport where `name` = 'PurchaseOrderTrack';
update ld_usereportcolumns set realencolumns = 'ld_crmentity:createdtime:createdtime:PurchaseOrder_Created Time:DT'
where Usereportid = @usereportid and `columns` = 'ld_crmentity:createdtime:createdtime:PurchaseOrder_CreatedTime:DT';
delimiter;
select usereportid into @usereportid from ld_usereport where `name` = 'Performancestatisticscollection';
update ld_usereportcolumns set realencolumns = 'ld_users:lastname:lastname:OftenUseReport_Person in Charge:V'
where Usereportid = @usereportid and `columns` = 'ld_users:lastname:lastname:OftenUseReport_lastname:V';
delimiter;
select usereportid into @usereportid from ld_usereport where `name` = 'Performancestatisticscollection';
update ld_usereportcolumns set realencolumns = 'ld_cashbill:cashbilldate:cashbilldate:CashBill_Receipt Date:D'
where Usereportid = @usereportid and `columns` = 'ld_cashbill:cashbilldate:cashbilldate:CashBill_cashbilldate:D';
delimiter;
select usereportid into @usereportid from ld_usereport where `name` = 'Performancestatisticscollection';
update ld_usereportcolumns set realencolumns = 'ld_cashbill:cashbill_no:cashbill_no:CashBill_Cashbill No:V'
where Usereportid = @usereportid and `columns` = 'ld_cashbill:cashbill_no:cashbill_no:CashBill_cashbill_no:V';
delimiter;
select usereportid into @usereportid from ld_usereport where `name` = 'Performancestatisticscollection';
update ld_usereportcolumns set realencolumns = 'ld_account:accountname:accountname:Accounts_Amount of Receivables:V'
where Usereportid = @usereportid and `columns` = 'ld_account:accountname:accountname:Accounts_accountname:V';
delimiter;
select usereportid into @usereportid from ld_usereport where `name` = 'Performancestatisticscollection';
update ld_usereportcolumns set realencolumns = 'ld_cashbill:Atotal:Atotal:OftenUseReport_Amount of Receivables:N'
where Usereportid = @usereportid and `columns` = 'ld_cashbill:Atotal:Atotal:OftenUseReport_Atotal:N';
delimiter;
select usereportid into @usereportid from ld_usereport where `name` = 'Performancestatisticscollection';
update ld_usereportcolumns set realencolumns = 'ld_users:lastname3:lastname3:OftenUseReport_Creator:V'
where Usereportid = @usereportid and `columns` = 'ld_users:lastname3:lastname3:OftenUseReport_lastname3:V';
delimiter;
select usereportid into @usereportid from ld_usereport where `name` = 'Performancestatisticscollection';
update ld_usereportcolumns set realencolumns = 'ld_salesorder:subject:subject:SalesOrder_Contract Topic:V'
where Usereportid = @usereportid and `columns` = 'ld_salesorder:subject:subject:SalesOrder_subject:V';
delimiter;
select usereportid into @usereportid from ld_usereport where `name` = 'Performancestatisticscollection';
update ld_usereportcolumns set realencolumns = 'ld_salesorder:salesorder_no:salesorder_no:OftenUseReport_Contract Number:V'
where Usereportid = @usereportid and `columns` = 'ld_salesorder:salesorder_no:salesorder_no:SalesOrder_salesorder_no:V';
delimiter;
select usereportid into @usereportid from ld_usereport where `name` = 'Performancestatisticscollection';
update ld_usereportcolumns set realencolumns = 'ld_salesorder:ssubtotal:ssubtotal:OftenUseReport_Totalss Contract Amount:N'
where Usereportid = @usereportid and `columns` = 'ld_salesorder:ssubtotal:ssubtotal:OftenUseReport_ssubtotal:N';
delimiter;
select usereportid into @usereportid from ld_usereport where `name` = 'Performancestatisticscollection';
update ld_usereportcolumns set realencolumns = 'ld_cashbill:pamount:pamount:OftenUseReport_Amount of Receivables:N'
where Usereportid = @usereportid and `columns` = 'ld_cashbill:pamount:pamount:OftenUseReport_pamount:N';
delimiter;
select usereportid into @usereportid from ld_usereport where `name` = 'Performancestatisticscollection';
update ld_usereportcolumns set realencolumns = 'ld_salesordercost:productcost:productcost:OftenUseReport_Total Cost of Sales:N'
where Usereportid = @usereportid and `columns` = 'ld_salesordercost:productcost:productcost:OftenUseReport_productcost:N';
delimiter;
select usereportid into @usereportid from ld_usereport where `name` = 'Performancestatisticscollection';
update ld_usereportcolumns set realencolumns = 'ld_expense:etotal:etotal:OftenUseReport_Total Cost:N'
where Usereportid = @usereportid and `columns` = 'ld_expense:etotal:etotal:OftenUseReport_etotal:N';
delimiter;
select usereportid into @usereportid from ld_usereport where `name` = 'Performancestatisticscollection';
update ld_usereportcolumns set realencolumns = 'ld_salesordercost:productgp:productgp:OftenUseReport_Maori:N'
where Usereportid = @usereportid and `columns` = 'ld_salesordercost:productgp:productgp:OftenUseReport_productgp:N';
delimiter;
select usereportid into @usereportid from ld_usereport where `name` = 'Performancestatisticscollection';
update ld_usereportcolumns set realencolumns = 'ld_commission2payment:CommissionTotal:CommissionTotal:OftenUseReport_Commission Total:NN'
where Usereportid = @usereportid and `columns` = 'ld_commission2payment:CommissionTotal:CommissionTotal:OftenUseReport_CommissionTotal:NN';
delimiter;
select usereportid into @usereportid from ld_usereport where `name` = 'Performancestatisticscollection';
update ld_usereportcolumns set realencolumns = 'ld_products:productname:productname:Products_Product Name:V'
where Usereportid = @usereportid and `columns` = 'ld_products:productname:productname:Products_productname:V';
delimiter;
select usereportid into @usereportid from ld_usereport where `name` = 'Performancestatisticscollection';
update ld_usereportcolumns set realencolumns = 'ld_products:product_no:product_no:Products_Product No:V'
where Usereportid = @usereportid and `columns` = 'ld_products:product_no:product_no:Products_product_no:V';
delimiter;
select usereportid into @usereportid from ld_usereport where `name` = 'Performancestatisticscollection';
update ld_usereportcolumns set realencolumns = 'ld_products:usageunit:usageunit:Products_Unit:V'
where Usereportid = @usereportid and `columns` = 'ld_products:usageunit:usageunit:Products_usageunit:V';
delimiter;
select usereportid into @usereportid from ld_usereport where `name` = 'Performancestatisticscollection';
update ld_usereportcolumns set realencolumns = 'ld_products:productsheet:productsheet:Products_Specification:V'
where Usereportid = @usereportid and `columns` = 'ld_products:productsheet:productsheet:Products_productsheet:V';
delimiter;
select usereportid into @usereportid from ld_usereport where `name` = 'Performancestatisticscollection';
update ld_usereportcolumns set realencolumns = 'ld_inventoryproductrel:quantity:quantity:OftenUseReport_Quantity:N'
where Usereportid = @usereportid and `columns` = 'ld_inventoryproductrel:quantity:quantity:OftenUseReport_quantity:N';
delimiter;
select usereportid into @usereportid from ld_usereport where `name` = 'Performancestatisticscollection';
update ld_usereportcolumns set realencolumns = 'ld_products:unit_price:unit_price:Products_Unit Price:N'
where Usereportid = @usereportid and `columns` = 'ld_products:unit_price:unit_price:Products_unit_price:N';
delimiter;
select usereportid into @usereportid from ld_usereport where `name` = 'Performancestatisticscollection';
update ld_usereportcolumns set realencolumns = 'ld_inventoryproductrel:discountamount:discountamount:OftenUseReport_Discount AmountV'
where Usereportid = @usereportid and `columns` = 'ld_inventoryproductrel:discountamount:discountamount:OftenUseReport_discountamount:V';
delimiter;
select usereportid into @usereportid from ld_usereport where `name` = 'Performancestatisticscollection';
update ld_usereportcolumns set realencolumns = 'ld_inventoryproductrel:costprice:costprice:Products_Costprices:N'
where Usereportid = @usereportid and `columns` = 'ld_inventoryproductrel:costprice:costprice:Products_costprice:N';
delimiter;
select usereportid into @usereportid from ld_usereport where `name` = 'Performancestatisticscollection';
update ld_usereportcolumns set realencolumns = 'ld_cashbill:description:description:CashBill_Description:V'
where Usereportid = @usereportid and `columns` = 'ld_cashbill:description:description:CashBill_description:V';
delimiter;
select usereportid into @usereportid from ld_usereport where `name` = 'SendCashBillSum_PurchaseOrder';
update ld_usereportcolumns set realencolumns = 'ld_usersPurchaseOrder:smownerid:assigned_user_id:PurchaseOrder_Assigned To:V'
where Usereportid = @usereportid and `columns` = 'ld_usersPurchaseOrder:smownerid:assigned_user_id:PurchaseOrder_assigned_user_id:V';
delimiter;
select usereportid into @usereportid from ld_usereport where `name` = 'SendCashBillSum_PurchaseOrder';
update ld_usereportcolumns set realencolumns = 'ld_purchaseorder:subject:subject:PurchaseOrder_PurchaseOrder Subject:V'
where Usereportid = @usereportid and `columns` = 'ld_purchaseorder:subject:subject:PurchaseOrder_Subject:V';
delimiter;
select usereportid into @usereportid from ld_usereport where `name` = 'SendCashBillSum_PurchaseOrder';
update ld_usereportcolumns set realencolumns = 'ld_purchaseorder:vendorid:vendorid:PurchaseOrder_Vendor Name:I'
where Usereportid = @usereportid and `columns` = 'ld_purchaseorder:vendorid:vendorid:PurchaseOrder_vendorname:I';
delimiter;
select usereportid into @usereportid from ld_usereport where `name` = 'SendCashBillSum_PurchaseOrder';
update ld_usereportcolumns set realencolumns = 'ld_purchaseorder:postatus:postatus:PurchaseOrder_PurchaseOrder Status:V'
where Usereportid = @usereportid and `columns` = 'ld_purchaseorder:postatus:postatus:PurchaseOrder_Status:V';
delimiter;
select usereportid into @usereportid from ld_usereport where `name` = 'SendCashBillSum_PurchaseOrder';
update ld_usereportcolumns set realencolumns = 'ld_purchaseorder:total:hdnGrandTotal:PurchaseOrder_PurchaseOrder Total:N'
where Usereportid = @usereportid and `columns` = 'ld_purchaseorder:total:hdnGrandTotal:PurchaseOrder_Total:N';
delimiter;
select usereportid into @usereportid from ld_usereport where `name` = 'SendCashBillSum_PurchaseOrder';
update ld_usereportcolumns set realencolumns = 'ld_sendcashbill:SendCashBillamount:SendCashBillamount:oftenusereport_SendCashBill Amount:N'
where Usereportid = @usereportid and `columns` = 'ld_reporttable:CashBillamount:SendCashBillamount:oftenusereport_SendCashBillamount:N';
delimiter;
select usereportid into @usereportid from ld_usereport where `name` = 'SendCashBillSum_PurchaseOrder';
update ld_usereportcolumns set realencolumns = 'ld_sendcashbill:SendCashBillBalance:SendCashBillBalance:oftenusereport_SendCashBill Balance:N'
where Usereportid = @usereportid and `columns` = 'ld_sendcashbill:PaymentBalance:SendCashBillBalance:OftenUseReport_PaymentBalance:N';
delimiter;
select usereportid into @usereportid from ld_usereport where `name` = 'SendCashBillSum_PurchaseOrder';
update ld_usereportcolumns set realencolumns = 'ld_purchaseorder:purchaseorder_no:purchaseorder_no:PurchaseOrder_Purchase Order No:V'
where Usereportid = @usereportid and `columns` = 'ld_purchaseorder:purchaseorder_no:purchaseorder_no:PurchaseOrder_PurchaseOrder No:V';
delimiter;
select usereportid into @usereportid from ld_usereport where `name` = 'SendCashBillSum_PurchaseOrder';
update ld_usereportcolumns set realencolumns = 'ld_crmentity:createdtime:createdtime:PurchaseOrder_CreatedTime:DT'
where Usereportid = @usereportid and `columns` = 'ld_crmentity:createdtime:createdtime:PurchaseOrder_Created Time:DT';
delimiter;
select usereportid into @usereportid from ld_usereport where `name` = 'Contractnumber';
update ld_usereportcolumns set realencolumns = 'ld_salesorder:ordernum:ordernum:SalesOrder_Rank:V'
where Usereportid = @usereportid and `columns` = 'ld_salesorder:ordernum:ordernum:SalesOrder_ordernum:V';
delimiter;
select usereportid into @usereportid from ld_usereport where `name` = 'Contractnumber';
update ld_usereportcolumns set realencolumns = 'ld_salesorder:smownerid:smownerid:SalesOrder_Sales Leader:V'
where Usereportid = @usereportid and `columns` = 'ld_salesorder:smownerid:smownerid:SalesOrder_smownerid:V';
delimiter;
select usereportid into @usereportid from ld_usereport where `name` = 'Contractnumber';
update ld_usereportcolumns set realencolumns = 'ld_salesorder:groupbycount:groupbycount:SalesOrder_Contract Quantity:N'
where Usereportid = @usereportid and `columns` = 'ld_salesorder:groupbycount:groupbycount:SalesOrder_groupbycount:N';
delimiter;
select usereportid into @usereportid from ld_usereport where `name` = 'THESINGNINGAMOUNTOFBILLBOARD';
update ld_usereportcolumns set realencolumns = 'ld_cashbill:ordernum:ordernum:CashBill_Ordernum:V'
where Usereportid = @usereportid and `columns` = 'ld_cashbill:ordernum:ordernum:CashBill_ordernum:V';
delimiter;
select usereportid into @usereportid from ld_usereport where `name` = 'THESINGNINGAMOUNTOFBILLBOARD';
update ld_usereportcolumns set realencolumns = 'ld_cashbill:smownerid:smownerid:CashBill_Assigned To:V'
where Usereportid = @usereportid and `columns` = 'ld_cashbill:smownerid:smownerid:CashBill_smownerid:V';
delimiter;
select usereportid into @usereportid from ld_usereport where `name` = 'THESINGNINGAMOUNTOFBILLBOARD';
update ld_usereportcolumns set realencolumns = 'ld_cashbill:total:total:CashBill_Total:N'
where Usereportid = @usereportid and `columns` = 'ld_cashbill:total:total:CashBill_total:N';
delimiter;
select usereportid into @usereportid from ld_usereport where `name` = 'Serviceperformanceappraisal';
update ld_usereportcolumns set realencolumns = 'ld_troubletickets:module_zh:module_zh:OftenUseReport_Bill Type:V'
where Usereportid = @usereportid and `columns` = 'ld_troubletickets:module_zh:module_zh:OftenUseReport_module_zh:V';
delimiter;

select usereportid into @usereportid from ld_usereport where `name` = 'Serviceperformanceappraisal';
update ld_usereportcolumns set realencolumns = 'ld_users:lastname:lastname:OftenUseReport_Assigned To:V'
where Usereportid = @usereportid and `columns` = 'ld_users:lastname:lastname:OftenUseReport_lastname:V';
delimiter;

select usereportid into @usereportid from ld_usereport where `name` = 'Serviceperformanceappraisal';
update ld_usereportcolumns set realencolumns = 'ld_account:accountname:accountname:Accounts_Account Name:V'
where Usereportid = @usereportid and `columns` = 'ld_account:accountname:accountname:Accounts_accountname:V';
delimiter;

select usereportid into @usereportid from ld_usereport where `name` = 'Serviceperformanceappraisal';
update ld_usereportcolumns set realencolumns = 'ld_account:bill_city:bill_city:Accounts_City:V'
where Usereportid = @usereportid and `columns` = 'ld_account:bill_city:bill_city:Accounts_bill_city:V';
delimiter;

select usereportid into @usereportid from ld_usereport where `name` = 'Serviceperformanceappraisal';
update ld_usereportcolumns set realencolumns = 'ld_products:productcategory:productcategory:Products_Product Type:V'
where Usereportid = @usereportid and `columns` = 'ld_products:productcategory:productcategory:Products_productcategory:V';
delimiter;

select usereportid into @usereportid from ld_usereport where `name` = 'Serviceperformanceappraisal';
update ld_usereportcolumns set realencolumns = 'ld_troubletickets:enddate:enddate:HelpDesk_Service Date:D'
where Usereportid = @usereportid and `columns` = 'ld_troubletickets:enddate:enddate:HelpDesk_enddate:D';
delimiter;

select usereportid into @usereportid from ld_usereport where `name` = 'Serviceperformanceappraisal';
update ld_usereportcolumns set realencolumns = 'ld_troubletickets:fwyeji:fwyeji:OftenUseReport_Performance Scores:NN'
where Usereportid = @usereportid and `columns` = 'ld_troubletickets:fwyeji:fwyeji:OftenUseReport_fwyeji:NN';
delimiter;

select usereportid into @usereportid from ld_usereport where `name` = 'Serviceperformanceappraisal';
update ld_usereportcolumns set realencolumns = 'ld_troubletickets:traficfee:traficfee:HelpDesk_Traffic Expense:NN'
where Usereportid = @usereportid and `columns` = 'ld_troubletickets:traficfee:traficfee:HelpDesk_traficfee:NN';
delimiter;

select usereportid into @usereportid from ld_usereport where `name` = 'Serviceperformanceappraisal';
update ld_usereportcolumns set realencolumns = 'ld_troubletickets:ticketcategories:ticketcategories:HelpDesk_Failure Category:V'
where Usereportid = @usereportid and `columns` = 'ld_troubletickets:category:category:HelpDesk_category:V';
delimiter;

select usereportid into @usereportid from ld_usereport where `name` = 'Serviceperformanceappraisal';
update ld_usereportcolumns set realencolumns = 'ld_troubletickets:jiaotongfei:jiaotongfei:HelpDesk_Traffic Expense(Acc to Scores):NN'
where Usereportid = @usereportid and `columns` = 'ld_troubletickets:jiaotongfei:jiaotongfei:HelpDesk_jiaotongfei:NN';
delimiter;

select usereportid into @usereportid from ld_usereport where `name` = 'Serviceperformanceappraisal';
update ld_usereportcolumns set realencolumns = 'ld_troubletickets:servicetype:servicetype:HelpDesk_Service Type:V'
where Usereportid = @usereportid and `columns` = 'ld_troubletickets:servicetype:servicetype:HelpDesk_servicetype:V';
delimiter;

select usereportid into @usereportid from ld_usereport where `name` = 'Serviceperformanceappraisal';
update ld_usereportcolumns set realencolumns = 'ld_troubletickets:projecttask_no:projecttask_no:HelpDesk_Bill No:V'
where Usereportid = @usereportid and `columns` = 'ld_troubletickets:projecttask_no:projecttask_no:HelpDesk_projecttask_no:V';
delimiter;

select usereportid into @usereportid from ld_usereport where `name` = 'Serviceperformanceappraisal';
update ld_usereportcolumns set realencolumns = 'ld_troubletickets:createdtime:createdtime:HelpDesk_Create Date:V'
where Usereportid = @usereportid and `columns` = 'ld_troubletickets:createdtime:createdtime:HelpDesk_createdtime:V';
delimiter;

select usereportid into @usereportid from ld_usereport where `name` = 'Serviceperformanceappraisal';
update ld_usereportcolumns set realencolumns = 'ld_troubletickets:description:description:HelpDesk_Problem Description:V'
where Usereportid = @usereportid and `columns` = 'ld_troubletickets:description:description:HelpDesk_description:V';
delimiter;

select usereportid into @usereportid from ld_usereport where `name` = 'Serviceperformanceappraisal';
update ld_usereportcolumns set realencolumns = 'ld_troubletickets:solution:solution:HelpDesk_The Solution:V'
where Usereportid = @usereportid and `columns` = 'ld_troubletickets:solution:solution:HelpDesk_solution:V';
delimiter;

call AddColumn('ld_workreport_remind','push_to_weixin','int','1',0);
call AddColumn('ld_reminds','push_to_weixin','int','1',0);
delimiter;

select tabid into @stabid from ld_tab where name = 'SalesOrder';
select tabid into @ptabid from ld_tab where name = 'Project';
select sequence into @sequence from ld_relatedlists where tabid = @stabid and name = 'get_servicecontracts';
update ld_relatedlists set sequence = sequence+1 where tabid = @stabid and sequence > @sequence;
SELECT max(relation_id) INTO @relation_id FROM ld_relatedlists;
INSERT INTO ld_relatedlists(relation_id,tabid,related_tabid,NAME,sequence,label,presence,actions,mobile_presence,mobile_sequence)
SELECT @relation_id+1,@stabid,@ptabid,'get_project',@sequence+1,'Project',0,'add',1,1
FROM DUAL WHERE NOT EXISTS(SELECT 1 FROM ld_relatedlists WHERE tabid=@stabid AND NAME='get_project');
delimiter;
set @i=0; 
update ld_relatedlists set sequence=(@i:=@i+1) where tabid = @stabid order by sequence; 
delimiter;

call AddColumn('ld_salesorder','lastinvoice_no','varchar','200',0); 
call AddColumn('ld_servicecontracts','lastinvoice_no','varchar','200',0); 
call AddColumn('ld_outboundorder','lastinvoice_no','varchar','200',0); 
call AddColumn('ld_purchaseorder','lastinvoice_no','varchar','200',0); 
call AddColumn('ld_stock','lastinvoice_no','varchar','200',0); 
delimiter;

select tabid into @tabid from ld_tab where name='salesorder';
select blockid into @blockid from ld_blocks  where blocklabel='LBL_SO_INFORMATION';
insert into ld_field(tabid,fieldid,columnname,tablename,uitype,fieldname,fieldlabel,block,displaytype,presence,typeofdata,generatedtype,sequence,readonly)
  select @tabid,(select max(fieldid) from ld_field)+1,'have_invoicetotal','ld_salesorder',72,'have_invoicetotal','已开票金额',@blockid,2,0,'N~O',2,2,1 from dual
  where not exists (select 1 from ld_field where tabid = @tabid and columnname = 'have_invoicetotal');
select fieldid into @fieldid from ld_field where tabid = @tabid and fieldname = 'have_invoicetotal';
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
  select 'zh','ld_field',@tabid,@fieldid,'已开票金额' from dual
  where not EXISTS(select 1 from ld_tranlabel  where languagetype = 'zh' and trantable ='ld_field' and tabid = @tabid and relateid=@fieldid);
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
  select 'en','ld_field',@tabid,@fieldid,'Have the invoice amount' from dual
  where not EXISTS(select 1 from ld_tranlabel  where languagetype = 'en' and trantable ='ld_field' and tabid = @tabid and relateid=@fieldid);

select tabid into @tabid from ld_tab where name='servicecontracts';
select blockid into @blockid from ld_blocks  where blocklabel='LBL_SERVICE_CONTRACT_INFORMATION';
insert into ld_field(tabid,fieldid,columnname,tablename,uitype,fieldname,fieldlabel,block,displaytype,presence,typeofdata,generatedtype,sequence,readonly)
  select @tabid,(select max(fieldid) from ld_field)+1,'have_invoicetotal','ld_servicecontracts',72,'have_invoicetotal','已开票金额',@blockid,2,0,'N~O',2,2,1 from dual
  where not exists (select 1 from ld_field where tabid = @tabid and columnname = 'have_invoicetotal');
select fieldid into @fieldid from ld_field where tabid = @tabid and fieldname = 'have_invoicetotal';
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
  select 'zh','ld_field',@tabid,@fieldid,'已开票金额' from dual
  where not EXISTS(select 1 from ld_tranlabel  where languagetype = 'zh' and trantable ='ld_field' and tabid = @tabid and relateid=@fieldid);
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
  select 'en','ld_field',@tabid,@fieldid,'Have the invoice amount' from dual
  where not EXISTS(select 1 from ld_tranlabel  where languagetype = 'en' and trantable ='ld_field' and tabid = @tabid and relateid=@fieldid);

select tabid into @tabid from ld_tab where name='OutboundOrder';
select blockid into @blockid from ld_blocks  where blocklabel='LBL_OUT_INFO';
insert into ld_field(tabid,fieldid,columnname,tablename,uitype,fieldname,fieldlabel,block,displaytype,presence,typeofdata,generatedtype,sequence,readonly)
  select @tabid,(select max(fieldid) from ld_field)+1,'have_invoicetotal','ld_outboundorder',72,'have_invoicetotal','已开票金额',@blockid,2,0,'N~O',2,2,1 from dual
  where not exists (select 1 from ld_field where tabid = @tabid and columnname = 'have_invoicetotal');
select fieldid into @fieldid from ld_field where tabid = @tabid and fieldname = 'have_invoicetotal';
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
  select 'zh','ld_field',@tabid,@fieldid,'已开票金额' from dual
  where not EXISTS(select 1 from ld_tranlabel  where languagetype = 'zh' and trantable ='ld_field' and tabid = @tabid and relateid=@fieldid);
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
  select 'en','ld_field',@tabid,@fieldid,'Have the invoice amount' from dual
  where not EXISTS(select 1 from ld_tranlabel  where languagetype = 'en' and trantable ='ld_field' and tabid = @tabid and relateid=@fieldid);

select tabid into @tabid from ld_tab where name='PurchaseOrder';
select blockid into @blockid from ld_blocks  where blocklabel='LBL_PO_INFORMATION';
insert into ld_field(tabid,fieldid,columnname,tablename,uitype,fieldname,fieldlabel,block,displaytype,presence,typeofdata,generatedtype,sequence,readonly)
  select @tabid,(select max(fieldid) from ld_field)+1,'have_invoicetotal','ld_purchaseorder',72,'have_invoicetotal','已开票金额',@blockid,2,0,'N~O',2,2,1 from dual
  where not exists (select 1 from ld_field where tabid = @tabid and columnname = 'have_invoicetotal');
select fieldid into @fieldid from ld_field where tabid = @tabid and fieldname = 'have_invoicetotal';
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
  select 'zh','ld_field',@tabid,@fieldid,'已开票金额' from dual
  where not EXISTS(select 1 from ld_tranlabel  where languagetype = 'zh' and trantable ='ld_field' and tabid = @tabid and relateid=@fieldid);
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
  select 'en','ld_field',@tabid,@fieldid,'Have the invoice amount' from dual
  where not EXISTS(select 1 from ld_tranlabel  where languagetype = 'en' and trantable ='ld_field' and tabid = @tabid and relateid=@fieldid);

select tabid into @tabid from ld_tab where name='stock';
select blockid into @blockid from ld_blocks  where blocklabel='LBL_WARE_INFO';
insert into ld_field(tabid,fieldid,columnname,tablename,uitype,fieldname,fieldlabel,block,displaytype,presence,typeofdata,generatedtype,sequence,readonly)
  select @tabid,(select max(fieldid) from ld_field)+1,'have_invoicetotal','ld_stock',72,'have_invoicetotal','已开票金额',@blockid,2,0,'N~O',2,2,1 from dual
  where not exists (select 1 from ld_field where tabid = @tabid and columnname = 'have_invoicetotal');
select fieldid into @fieldid from ld_field where tabid = @tabid and fieldname = 'have_invoicetotal';
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
  select 'zh','ld_field',@tabid,@fieldid,'已开票金额' from dual
  where not EXISTS(select 1 from ld_tranlabel  where languagetype = 'zh' and trantable ='ld_field' and tabid = @tabid and relateid=@fieldid);
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
  select 'en','ld_field',@tabid,@fieldid,'Have the invoice amount' from dual
  where not EXISTS(select 1 from ld_tranlabel  where languagetype = 'en' and trantable ='ld_field' and tabid = @tabid and relateid=@fieldid);

select tabid into @tabid from ld_tab where name='salesorder';
select blockid into @blockid from ld_blocks  where blocklabel='LBL_SO_INFORMATION';
insert into ld_field(tabid,fieldid,columnname,tablename,uitype,fieldname,fieldlabel,block,displaytype,presence,typeofdata,generatedtype,sequence,readonly)
  select @tabid,(select max(fieldid) from ld_field)+1,'lastinvoice_no','ld_salesorder',1,'lastinvoice_no','发票号码',@blockid,2,0,'V~O',2,2,1 from dual
  where not exists (select 1 from ld_field where tabid = @tabid and columnname = 'lastinvoice_no');
select fieldid into @fieldid from ld_field where tabid = @tabid and fieldname = 'lastinvoice_no';
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
  select 'zh','ld_field',@tabid,@fieldid,'发票号码' from dual
  where not EXISTS(select 1 from ld_tranlabel  where languagetype = 'zh' and trantable ='ld_field' and tabid = @tabid and relateid=@fieldid);
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
  select 'en','ld_field',@tabid,@fieldid,'Invoice No' from dual
  where not EXISTS(select 1 from ld_tranlabel  where languagetype = 'en' and trantable ='ld_field' and tabid = @tabid and relateid=@fieldid);


select tabid into @tabid from ld_tab where name='servicecontracts';
select blockid into @blockid from ld_blocks  where blocklabel='LBL_SERVICE_CONTRACT_INFORMATION';
insert into ld_field(tabid,fieldid,columnname,tablename,uitype,fieldname,fieldlabel,block,displaytype,presence,typeofdata,generatedtype,sequence,readonly)
  select @tabid,(select max(fieldid) from ld_field)+1,'lastinvoice_no','ld_servicecontracts',1,'lastinvoice_no','发票号码',@blockid,2,0,'V~O',2,2,1 from dual
  where not exists (select 1 from ld_field where tabid = @tabid and columnname = 'lastinvoice_no');
select fieldid into @fieldid from ld_field where tabid = @tabid and fieldname = 'lastinvoice_no';
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
  select 'zh','ld_field',@tabid,@fieldid,'发票号码' from dual
  where not EXISTS(select 1 from ld_tranlabel  where languagetype = 'zh' and trantable ='ld_field' and tabid = @tabid and relateid=@fieldid);
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
  select 'en','ld_field',@tabid,@fieldid,'Invoice No' from dual
  where not EXISTS(select 1 from ld_tranlabel  where languagetype = 'en' and trantable ='ld_field' and tabid = @tabid and relateid=@fieldid);

select tabid into @tabid from ld_tab where name='OutboundOrder';
select blockid into @blockid from ld_blocks  where blocklabel='LBL_OUT_INFO';
insert into ld_field(tabid,fieldid,columnname,tablename,uitype,fieldname,fieldlabel,block,displaytype,presence,typeofdata,generatedtype,sequence,readonly)
  select @tabid,(select max(fieldid) from ld_field)+1,'lastinvoice_no','ld_outboundorder',1,'lastinvoice_no','发票号码',@blockid,2,0,'V~O',2,2,1 from dual
  where not exists (select 1 from ld_field where tabid = @tabid and columnname = 'lastinvoice_no');
select fieldid into @fieldid from ld_field where tabid = @tabid and fieldname = 'lastinvoice_no';
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
  select 'zh','ld_field',@tabid,@fieldid,'发票号码' from dual
  where not EXISTS(select 1 from ld_tranlabel  where languagetype = 'zh' and trantable ='ld_field' and tabid = @tabid and relateid=@fieldid);
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
  select 'en','ld_field',@tabid,@fieldid,'Invoice No' from dual
  where not EXISTS(select 1 from ld_tranlabel  where languagetype = 'en' and trantable ='ld_field' and tabid = @tabid and relateid=@fieldid);


select tabid into @tabid from ld_tab where name='PurchaseOrder';
select blockid into @blockid from ld_blocks  where blocklabel='LBL_PO_INFORMATION';
insert into ld_field(tabid,fieldid,columnname,tablename,uitype,fieldname,fieldlabel,block,displaytype,presence,typeofdata,generatedtype,sequence,readonly)
  select @tabid,(select max(fieldid) from ld_field)+1,'lastinvoice_no','ld_purchaseorder',1,'lastinvoice_no','发票号码',@blockid,2,0,'V~O',2,2,1 from dual
  where not exists (select 1 from ld_field where tabid = @tabid and columnname = 'lastinvoice_no');
select fieldid into @fieldid from ld_field where tabid = @tabid and fieldname = 'lastinvoice_no';
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
  select 'zh','ld_field',@tabid,@fieldid,'发票号码' from dual
  where not EXISTS(select 1 from ld_tranlabel  where languagetype = 'zh' and trantable ='ld_field' and tabid = @tabid and relateid=@fieldid);
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
  select 'en','ld_field',@tabid,@fieldid,'Invoice No' from dual
  where not EXISTS(select 1 from ld_tranlabel  where languagetype = 'en' and trantable ='ld_field' and tabid = @tabid and relateid=@fieldid);

select tabid into @tabid from ld_tab where name='stock';
select blockid into @blockid from ld_blocks  where blocklabel='LBL_WARE_INFO';
insert into ld_field(tabid,fieldid,columnname,tablename,uitype,fieldname,fieldlabel,block,displaytype,presence,typeofdata,generatedtype,sequence,readonly)
  select @tabid,(select max(fieldid) from ld_field)+1,'lastinvoice_no','ld_stock',1,'lastinvoice_no','发票号码',@blockid,2,0,'V~O',2,2,1 from dual
  where not exists (select 1 from ld_field where tabid = @tabid and columnname = 'lastinvoice_no');
select fieldid into @fieldid from ld_field where tabid = @tabid and fieldname = 'lastinvoice_no';
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
  select 'zh','ld_field',@tabid,@fieldid,'发票号码' from dual
  where not EXISTS(select 1 from ld_tranlabel  where languagetype = 'zh' and trantable ='ld_field' and tabid = @tabid and relateid=@fieldid);
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
  select 'en','ld_field',@tabid,@fieldid,'Invoice No' from dual
  where not EXISTS(select 1 from ld_tranlabel  where languagetype = 'en' and trantable ='ld_field' and tabid = @tabid and relateid=@fieldid);

select tabid into @tabid from ld_tab where name='servicecontracts';
select blockid into @blockid from ld_blocks  where blocklabel='LBL_SERVICE_CONTRACT_INFORMATION';
insert into ld_field(tabid,fieldid,columnname,tablename,uitype,fieldname,fieldlabel,block,displaytype,presence,typeofdata,generatedtype,sequence,readonly)
  select @tabid,(select max(fieldid) from ld_field)+1,'have_invoicetotal','ld_servicecontracts',72,'have_invoicetotal','已开票金额',@blockid,2,0,'N~O',2,2,1 from dual
  where not exists (select 1 from ld_field where tabid = @tabid and columnname = 'have_invoicetotal');
select fieldid into @fieldid from ld_field where tabid = @tabid and fieldname = 'have_invoicetotal';
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
  select 'zh','ld_field',@tabid,@fieldid,'已开票金额' from dual
  where not EXISTS(select 1 from ld_tranlabel  where languagetype = 'zh' and trantable ='ld_field' and tabid = @tabid and relateid=@fieldid);
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
  select 'en','ld_field',@tabid,@fieldid,'Have the invoice amount' from dual
  where not EXISTS(select 1 from ld_tranlabel  where languagetype = 'en' and trantable ='ld_field' and tabid = @tabid and relateid=@fieldid);

select tabid into @tabid from ld_tab where name='OutboundOrder';
select blockid into @blockid from ld_blocks  where blocklabel='LBL_OUT_INFO';
insert into ld_field(tabid,fieldid,columnname,tablename,uitype,fieldname,fieldlabel,block,displaytype,presence,typeofdata,generatedtype,sequence,readonly)
  select @tabid,(select max(fieldid) from ld_field)+1,'have_invoicetotal','ld_outboundorder',72,'have_invoicetotal','已开票金额',@blockid,2,0,'N~O',2,2,1 from dual
  where not exists (select 1 from ld_field where tabid = @tabid and columnname = 'have_invoicetotal');
select fieldid into @fieldid from ld_field where tabid = @tabid and fieldname = 'have_invoicetotal';
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
  select 'zh','ld_field',@tabid,@fieldid,'已开票金额' from dual
  where not EXISTS(select 1 from ld_tranlabel  where languagetype = 'zh' and trantable ='ld_field' and tabid = @tabid and relateid=@fieldid);
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
  select 'en','ld_field',@tabid,@fieldid,'Have the invoice amount' from dual
  where not EXISTS(select 1 from ld_tranlabel  where languagetype = 'en' and trantable ='ld_field' and tabid = @tabid and relateid=@fieldid);

select tabid into @tabid from ld_tab where name='PurchaseOrder';
select blockid into @blockid from ld_blocks  where blocklabel='LBL_PO_INFORMATION';
insert into ld_field(tabid,fieldid,columnname,tablename,uitype,fieldname,fieldlabel,block,displaytype,presence,typeofdata,generatedtype,sequence,readonly)
  select @tabid,(select max(fieldid) from ld_field)+1,'have_invoicetotal','ld_purchaseorder',72,'have_invoicetotal','已开票金额',@blockid,2,0,'N~O',2,2,1 from dual
  where not exists (select 1 from ld_field where tabid = @tabid and columnname = 'have_invoicetotal');
select fieldid into @fieldid from ld_field where tabid = @tabid and fieldname = 'have_invoicetotal';
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
  select 'zh','ld_field',@tabid,@fieldid,'已开票金额' from dual
  where not EXISTS(select 1 from ld_tranlabel  where languagetype = 'zh' and trantable ='ld_field' and tabid = @tabid and relateid=@fieldid);
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
  select 'en','ld_field',@tabid,@fieldid,'Have the invoice amount' from dual
  where not EXISTS(select 1 from ld_tranlabel  where languagetype = 'en' and trantable ='ld_field' and tabid = @tabid and relateid=@fieldid);

select tabid into @tabid from ld_tab where name='stock';
select blockid into @blockid from ld_blocks  where blocklabel='LBL_WARE_INFO';
insert into ld_field(tabid,fieldid,columnname,tablename,uitype,fieldname,fieldlabel,block,displaytype,presence,typeofdata,generatedtype,sequence,readonly)
  select @tabid,(select max(fieldid) from ld_field)+1,'have_invoicetotal','ld_stock',72,'have_invoicetotal','已开票金额',@blockid,2,0,'N~O',2,2,1 from dual
  where not exists (select 1 from ld_field where tabid = @tabid and columnname = 'have_invoicetotal');
select fieldid into @fieldid from ld_field where tabid = @tabid and fieldname = 'have_invoicetotal';
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
  select 'zh','ld_field',@tabid,@fieldid,'已开票金额' from dual
  where not EXISTS(select 1 from ld_tranlabel  where languagetype = 'zh' and trantable ='ld_field' and tabid = @tabid and relateid=@fieldid);
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
  select 'en','ld_field',@tabid,@fieldid,'Have the invoice amount' from dual
  where not EXISTS(select 1 from ld_tranlabel  where languagetype = 'en' and trantable ='ld_field' and tabid = @tabid and relateid=@fieldid);



select tabid into @tabid from ld_tab where name='servicecontracts';
select blockid into @blockid from ld_blocks  where blocklabel='LBL_SERVICE_CONTRACT_INFORMATION';
insert into ld_field(tabid,fieldid,columnname,tablename,uitype,fieldname,fieldlabel,block,displaytype,presence,typeofdata,generatedtype,sequence,readonly)
  select @tabid,(select max(fieldid) from ld_field)+1,'have_invoicetotal','ld_servicecontracts',72,'have_invoicetotal','已开票金额',@blockid,2,0,'N~O',2,2,1 from dual
  where not exists (select 1 from ld_field where tabid = @tabid and columnname = 'have_invoicetotal');
select fieldid into @fieldid from ld_field where tabid = @tabid and fieldname = 'have_invoicetotal';
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
  select 'zh','ld_field',@tabid,@fieldid,'已开票金额' from dual
  where not EXISTS(select 1 from ld_tranlabel  where languagetype = 'zh' and trantable ='ld_field' and tabid = @tabid and relateid=@fieldid);
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
  select 'en','ld_field',@tabid,@fieldid,'Have the invoice amount' from dual
  where not EXISTS(select 1 from ld_tranlabel  where languagetype = 'en' and trantable ='ld_field' and tabid = @tabid and relateid=@fieldid);

select tabid into @tabid from ld_tab where name='OutboundOrder';
select blockid into @blockid from ld_blocks  where blocklabel='LBL_OUT_INFO';
insert into ld_field(tabid,fieldid,columnname,tablename,uitype,fieldname,fieldlabel,block,displaytype,presence,typeofdata,generatedtype,sequence,readonly)
  select @tabid,(select max(fieldid) from ld_field)+1,'have_invoicetotal','ld_outboundorder',72,'have_invoicetotal','已开票金额',@blockid,2,0,'N~O',2,2,1 from dual
  where not exists (select 1 from ld_field where tabid = @tabid and columnname = 'have_invoicetotal');
select fieldid into @fieldid from ld_field where tabid = @tabid and fieldname = 'have_invoicetotal';
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
  select 'zh','ld_field',@tabid,@fieldid,'已开票金额' from dual
  where not EXISTS(select 1 from ld_tranlabel  where languagetype = 'zh' and trantable ='ld_field' and tabid = @tabid and relateid=@fieldid);
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
  select 'en','ld_field',@tabid,@fieldid,'Have the invoice amount' from dual
  where not EXISTS(select 1 from ld_tranlabel  where languagetype = 'en' and trantable ='ld_field' and tabid = @tabid and relateid=@fieldid);

select tabid into @tabid from ld_tab where name='PurchaseOrder';
select blockid into @blockid from ld_blocks  where blocklabel='LBL_PO_INFORMATION';
insert into ld_field(tabid,fieldid,columnname,tablename,uitype,fieldname,fieldlabel,block,displaytype,presence,typeofdata,generatedtype,sequence,readonly)
  select @tabid,(select max(fieldid) from ld_field)+1,'have_invoicetotal','ld_purchaseorder',72,'have_invoicetotal','已开票金额',@blockid,2,0,'N~O',2,2,1 from dual
  where not exists (select 1 from ld_field where tabid = @tabid and columnname = 'have_invoicetotal');
select fieldid into @fieldid from ld_field where tabid = @tabid and fieldname = 'have_invoicetotal';
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
  select 'zh','ld_field',@tabid,@fieldid,'已开票金额' from dual
  where not EXISTS(select 1 from ld_tranlabel  where languagetype = 'zh' and trantable ='ld_field' and tabid = @tabid and relateid=@fieldid);
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
  select 'en','ld_field',@tabid,@fieldid,'Have the invoice amount' from dual
  where not EXISTS(select 1 from ld_tranlabel  where languagetype = 'en' and trantable ='ld_field' and tabid = @tabid and relateid=@fieldid);

select tabid into @tabid from ld_tab where name='stock';
select blockid into @blockid from ld_blocks  where blocklabel='LBL_WARE_INFO';
insert into ld_field(tabid,fieldid,columnname,tablename,uitype,fieldname,fieldlabel,block,displaytype,presence,typeofdata,generatedtype,sequence,readonly)
  select @tabid,(select max(fieldid) from ld_field)+1,'have_invoicetotal','ld_stock',72,'have_invoicetotal','已开票金额',@blockid,2,0,'N~O',2,2,1 from dual
  where not exists (select 1 from ld_field where tabid = @tabid and columnname = 'have_invoicetotal');
select fieldid into @fieldid from ld_field where tabid = @tabid and fieldname = 'have_invoicetotal';
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
  select 'zh','ld_field',@tabid,@fieldid,'已开票金额' from dual
  where not EXISTS(select 1 from ld_tranlabel  where languagetype = 'zh' and trantable ='ld_field' and tabid = @tabid and relateid=@fieldid);
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
  select 'en','ld_field',@tabid,@fieldid,'Have the invoice amount' from dual
  where not EXISTS(select 1 from ld_tranlabel  where languagetype = 'en' and trantable ='ld_field' and tabid = @tabid and relateid=@fieldid);

call getallprofile('salesorder');
call getallprofile('servicecontracts');
call getallprofile('outboundorder');
call getallprofile('stock');
call getallprofile('purchaseorder');
delimiter;

update ld_salesorder  LEFT JOIN
(   SELECT
	invoice_num,
	invoicedate,
	currency_id,
	entitytypeid,
	SUM(tax_amount) as invoicetotal
FROM (
	SELECT
		b.invoice_num,
		a.invoicedate,
		a.currency_id,
		c.entitytypeid,
		round(c.tax_amount/ifnull(a.conversion_rate,1),2) tax_amount
	FROM ld_invoice a
	LEFT JOIN ld_invoicecf b ON a.invoiceid=b.invoiceid
	LEFT JOIN (
		SELECT 
			b.id,
			b.entitytypeid,
			a.adjustment as tax_amount
		FROM ld_invoice a
		LEFT JOIN ld_inventoryproductrel b on a.invoiceid=b.id
		WHERE ifnull(a.adjustment,0)<>0
		GROUP BY b.entitytypeid
		UNION ALL
		SELECT
			id,
			entitytypeid,
			tax_amount
		FROM ld_inventoryproductrel) c ON a.invoiceid=c.id
	WHERE a.deleted=0
		AND ifnull(a.invoicestatus,'') != '已作废'
	ORDER BY a.invoicedate DESC,createdtime DESC) c  group by c.entitytypeid ) as tmp_invoiceinventory on tmp_invoiceinventory.entitytypeid=ld_salesorder.salesorderid

set have_invoicetotal=if(ld_salesorder.currency_id=1,ifnull(tmp_invoiceinventory.invoicetotal,0),ifnull(tmp_invoiceinventory.invoicetotal,0)*ld_salesorder.conversion_rate),
nothave_invoicetotal=total-have_invoicetotal,lastinvoicedate=tmp_invoiceinventory.invoicedate,lastinvoice_no=tmp_invoiceinventory.invoice_num;



update ld_servicecontracts  LEFT JOIN
(
SELECT
	invoice_num,
	invoicedate,
	currency_id,
	entitytypeid,
	SUM(tax_amount) as invoicetotal
FROM (
	SELECT
		b.invoice_num,
		a.invoicedate,
		a.currency_id,
		c.entitytypeid,
		round(c.tax_amount/ifnull(a.conversion_rate,1),2) tax_amount
	FROM ld_invoice a
	LEFT JOIN ld_invoicecf b ON a.invoiceid=b.invoiceid
	LEFT JOIN (
		SELECT 
			b.id,
			b.entitytypeid,
			a.adjustment as tax_amount
		FROM ld_invoice a
		LEFT JOIN ld_inventoryproductrel b on a.invoiceid=b.id
		WHERE ifnull(a.adjustment,0)<>0
		GROUP BY b.entitytypeid
		UNION ALL
		SELECT
			id,
			entitytypeid,
			tax_amount
		FROM ld_inventoryproductrel) c ON a.invoiceid=c.id
	WHERE a.deleted=0
		AND ifnull(a.invoicestatus,'') != '已作废'
	ORDER BY a.invoicedate DESC,createdtime DESC) c  group by c.entitytypeid) as tmp_invoiceinventory on tmp_invoiceinventory.entitytypeid=ld_servicecontracts.servicecontractsid

set have_invoicetotal=if(ld_servicecontracts.currency_id=1,ifnull(tmp_invoiceinventory.invoicetotal,0),ifnull(tmp_invoiceinventory.invoicetotal,0)*ld_servicecontracts.conversion_rate),
nothave_invoicetotal=total-have_invoicetotal,lastinvoicedate=tmp_invoiceinventory.invoicedate ,lastinvoice_no=tmp_invoiceinventory.invoice_num;




update ld_outboundorder  LEFT JOIN
(
SELECT
	invoice_num,
	invoicedate,
	currency_id,
	entitytypeid,
	SUM(tax_amount) as invoicetotal
FROM (
	SELECT
		b.invoice_num,
		a.invoicedate,
		a.currency_id,
		c.entitytypeid,
		round(c.tax_amount/ifnull(a.conversion_rate,1),2) tax_amount
	FROM ld_invoice a
	LEFT JOIN ld_invoicecf b ON a.invoiceid=b.invoiceid
	LEFT JOIN (
		SELECT 
			b.id,
			b.entitytypeid,
			a.adjustment as tax_amount
		FROM ld_invoice a
		LEFT JOIN ld_inventoryproductrel b on a.invoiceid=b.id
		WHERE ifnull(a.adjustment,0)<>0
		GROUP BY b.entitytypeid
		UNION ALL
		SELECT
			id,
			entitytypeid,
			tax_amount
		FROM ld_inventoryproductrel) c ON a.invoiceid=c.id
	WHERE a.deleted=0
		AND ifnull(a.invoicestatus,'') != '已作废'
	ORDER BY a.invoicedate DESC,createdtime DESC) c  group by c.entitytypeid) as tmp_invoiceinventory on tmp_invoiceinventory.entitytypeid=ld_outboundorder.out_id

set have_invoicetotal=if(ld_outboundorder.currency_id=1,ifnull(tmp_invoiceinventory.invoicetotal,0),ifnull(tmp_invoiceinventory.invoicetotal,0)*ld_outboundorder.conversion_rate),
nothave_invoicetotal=total-have_invoicetotal,lastinvoicedate=tmp_invoiceinventory.invoicedate,lastinvoice_no=tmp_invoiceinventory.invoice_num;



update ld_purchaseorder  LEFT JOIN
(
			SELECT
	invoice_num,
	invoicedate,
	currency_id,
	entitytypeid,
	SUM(tax_amount) as invoicetotal
FROM (
	SELECT
		a.purchaseinvoicenum as invoice_num,
		a.purchaseinvoicedate as invoicedate,
		a.currency_id,
		c.entitytypeid,
		round(c.tax_amount/ifnull(a.conversion_rate,1),2) tax_amount
	FROM ld_purchaseinvoice a
	
	LEFT JOIN (
		SELECT 
			b.id,
			b.entitytypeid,
			a.adjustment as tax_amount
		FROM ld_purchaseinvoice a
		LEFT JOIN ld_inventoryproductrel b on a.purchaseinvoiceid=b.id
		WHERE ifnull(a.adjustment,0)<>0
		GROUP BY b.entitytypeid
		UNION ALL
		SELECT
			id,
			entitytypeid,
			tax_amount
		FROM ld_inventoryproductrel) c ON a.purchaseinvoiceid=c.id
	WHERE a.deleted=0
		AND ifnull(a.purchaseinvoicestatus,'') != '已作废'
	ORDER BY a.purchaseinvoicedate DESC,createdtime DESC) c
                                GROUP BY 
                                c.entitytypeid ) as tmp_invoiceinventory on tmp_invoiceinventory.entitytypeid=ld_purchaseorder.purchaseorderid

set have_invoicetotal=if(ld_purchaseorder.currency_id=1,ifnull(tmp_invoiceinventory.invoicetotal,0),ifnull(tmp_invoiceinventory.invoicetotal,0)*ld_purchaseorder.conversion_rate),
nothave_invoicetotal=total-ifnull(have_invoicetotal,0),lastinvoicedate=tmp_invoiceinventory.invoicedate,lastinvoice_no=tmp_invoiceinventory.invoice_num;


update ld_stock  LEFT JOIN
(
		SELECT
	invoice_num,
	invoicedate,
	currency_id,
	entitytypeid,
	SUM(tax_amount) as invoicetotal
FROM (
	SELECT
		a.purchaseinvoicenum as invoice_num,
		a.purchaseinvoicedate as invoicedate,
		a.currency_id,
		c.entitytypeid,
		round(c.tax_amount/ifnull(a.conversion_rate,1),2) tax_amount
	FROM ld_purchaseinvoice a
	
	LEFT JOIN (
		SELECT 
			b.id,
			b.entitytypeid,
			a.adjustment as tax_amount
		FROM ld_purchaseinvoice a
		LEFT JOIN ld_inventoryproductrel b on a.purchaseinvoiceid=b.id
		WHERE ifnull(a.adjustment,0)<>0
		GROUP BY b.entitytypeid
		UNION ALL
		SELECT
			id,
			entitytypeid,
			tax_amount
		FROM ld_inventoryproductrel) c ON a.purchaseinvoiceid=c.id
	WHERE a.deleted=0
		AND ifnull(a.purchaseinvoicestatus,'') != '已作废'
	ORDER BY a.purchaseinvoicedate DESC,createdtime DESC) c
                                GROUP BY 
                                c.entitytypeid) as tmp_invoiceinventory on tmp_invoiceinventory.entitytypeid=ld_stock.stock_id

set have_invoicetotal=if(ld_stock.currency_id=1,ifnull(tmp_invoiceinventory.invoicetotal,0),ifnull(tmp_invoiceinventory.invoicetotal,0)*ld_stock.conversion_rate),
nothave_invoicetotal=total-ifnull(have_invoicetotal,0),lastinvoicedate=tmp_invoiceinventory.invoicedate,lastinvoice_no=tmp_invoiceinventory.invoice_num;
delimiter;
-- 2016-11-09

select sequence,roottype into @sequence,@roottype from ld_systems_deploy where deploy_type = 109;
update ld_systems_deploy set sequence = sequence + 3 where roottype = @roottype and sequence > @sequence;
insert into ld_systems_deploy(deploy_value,deploy_type,description,setype,sequence,roottype,inputtype,inputvalue,presence)
select 0,116,'设置关联合同订单时是否在所有用户的数据中进行查询：0否，1：是','',
@sequence+1,1,'select','[{"value":"1","text":"YES"},{"value":"0","text":"NO"},{"sql":""},{"relatedmodule":"Contacts"}]',0
from dual where not EXISTS(select 1 from ld_systems_deploy where deploy_type=116);
delimiter;

insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'zh','ld_systems_deploy',116,116,'设置关联合同订单时是否在所有用户的数据中进行查询'
from dual where not exists (select * from ld_tranlabel where languagetype='zh' and trantable='ld_systems_deploy' and relateid=116);
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'en','ld_systems_deploy',116,116,'Sets the relevance of the contract order is not in all the user data query'
from dual where not exists (select * from ld_tranlabel where languagetype='en' and trantable='ld_systems_deploy' and relateid=116);
delimiter;

insert into ld_systems_deploy(deploy_value,deploy_type,description,setype,sequence,roottype,inputtype,inputvalue,presence)
select 0,117,'设置关联服务合同时是否在所有用户的数据中进行查询：0否，1：是','',
@sequence+2,1,'select','[{"value":"1","text":"YES"},{"value":"0","text":"NO"},{"sql":""},{"relatedmodule":"Contacts"}]',0
from dual where not EXISTS(select 1 from ld_systems_deploy where deploy_type=117);
delimiter;

insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'zh','ld_systems_deploy',117,117,'设置关联服务合同时是否在所有用户的数据中进行查询'
from dual where not exists (select * from ld_tranlabel where languagetype='zh' and trantable='ld_systems_deploy' and relateid=117);
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'en','ld_systems_deploy',117,117,'Sets the related service contract whether to query all the user data'
from dual where not exists (select * from ld_tranlabel where languagetype='en' and trantable='ld_systems_deploy' and relateid=117);
delimiter;

insert into ld_systems_deploy(deploy_value,deploy_type,description,setype,sequence,roottype,inputtype,inputvalue,presence)
select 0,118,'设置关联采购订单时是否在所有用户的数据中进行查询：0否，1：是','',
@sequence+3,1,'select','[{"value":"1","text":"YES"},{"value":"0","text":"NO"},{"sql":""},{"relatedmodule":"Contacts"}]',0
from dual where not EXISTS(select 1 from ld_systems_deploy where deploy_type=118);
delimiter;

insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'zh','ld_systems_deploy',118,118,'设置关联采购订单时是否在所有用户的数据中进行查询'
from dual where not exists (select * from ld_tranlabel where languagetype='zh' and trantable='ld_systems_deploy' and relateid=118);
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'en','ld_systems_deploy',118,118,'To set up the related purchase order whether the data in all users to query'
from dual where not exists (select * from ld_tranlabel where languagetype='en' and trantable='ld_systems_deploy' and relateid=118);
delimiter;

select roottype into @roottype from ld_systems_deploy where deploy_type = 109;
set @i=0;
update ld_systems_deploy set sequence=(@i:=@i+1) where roottype=1  order by sequence;
delimiter;

select deploy_value into @deploy_value from ld_systems_deploy where deploy_type = 74;
update ld_systems_deploy set deploy_value = @deploy_value where deploy_type in (108,109,116,117,118);
delimiter;

select tabid into @tabid from ld_tab where `name`='Expense';
insert into ld_templateprint(printfilename,tabid,isdefault,templateprintname,systemdefault,allocatetype)
select 'ExpenseDefault2.html',@tabid,0,'费用报销预置模板(新)',1,0 from dual 
where not exists (select 1 from ld_templateprint where tabid=@tabid and printfilename='ExpenseDefault2.html');
delimiter;

update ld_desk set fieldlabel='签约额月度同比' where labelbol='AMOUNTMONTHCONTRACTYEAR' AND languagetype='zh';
delimiter;
SELECT tabid into @tabid from ld_tab where `name`='Users';
SELECT fieldid into @fieldid from ld_field where tabid=@tabid AND columnname='accountallview';
UPDATE ld_tranlabel set fieldlabel='允许查看相关信息列表数据权限' 
where languagetype='zh' AND Relateid=@fieldid AND tabid=@tabid;
UPDATE ld_tranlabel set fieldlabel='Allows you to view the relevant information list data permissions' 
where languagetype='en' AND Relateid=@fieldid AND tabid=@tabid;
delimiter;
update ld_desk set fieldlabel='只允许在相关信息列表查询所有的数据' where labelbol='UsersALLOWQUERY' AND languagetype='zh' AND Labeltype='fixedstr';
update ld_desk set fieldlabel='Only allows the list of relevant information to query all the data' where labelbol='UsersALLOWQUERY' AND languagetype='en' AND Labeltype='fixedstr';
delimiter;

update ld_tranlabel set fieldlabel = '设置关联{$SalesOrder.SalesOrder}时是否在所有用户的数据中进行查询(包括选择源单)' where tabid = 116 and Relateid = 116 and languagetype = 'zh' and trantable = 'ld_systems_deploy';
update ld_tranlabel set fieldlabel = 'Sets the relevance of the {$SalesOrder.SalesOrder} is not in all the user data query(inclue select source)' where tabid = 116 and Relateid = 116 and languagetype = 'en' and trantable = 'ld_systems_deploy';
update ld_tranlabel set fieldlabel = '设置关联{$ServiceContracts.ServiceContracts}时是否在所有用户的数据中进行查询(包括选择源单)' where tabid = 117 and Relateid = 117 and languagetype = 'zh' and trantable = 'ld_systems_deploy';
update ld_tranlabel set fieldlabel = 'Sets the related {$ServiceContracts.ServiceContracts} whether to query all the user data(inclue select source)' where tabid = 117 and Relateid = 117 and languagetype = 'en' and trantable = 'ld_systems_deploy';
update ld_tranlabel set fieldlabel = '设置关联{$PurchaseOrder.PurchaseOrder}时是否在所有用户的数据中进行查询(包括选择源单)' where tabid = 118 and Relateid = 118 and languagetype = 'zh' and trantable = 'ld_systems_deploy';
update ld_tranlabel set fieldlabel = 'To set up the related {$PurchaseOrder.PurchaseOrder} whether the data in all users to query(inclue select source)' where tabid = 118 and Relateid = 118 and languagetype = 'en' and trantable = 'ld_systems_deploy';
delimiter;
-- 2016-11-10

set @modulename='Accounts';
select tabid into @tabid from ld_tab where `name`=@modulename;
set @blockid=9;
set @tablename='ld_account';
set @columnname='firt_concatuser';
set @fieldname='firt_concatuser';
set @zh='首次联系用户';
set @en='首次联系用户';
set @uitype=52;
set @readonly=1;
set @presence=2;
set @defaultvalue=NULL;
set @displaytype=2;
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

call AddColumn(@tablename,@columnname,'int',19,0);
delimiter;

call fieldprofile('Accounts');
delimiter;
call getallprofile('Accounts');
delimiter;

update (
	select 
		smownerid,
		accountid 
	from (
		select 
			smownerid,
			accountid 
		from ld_contactrecords 
		where deleted=0 
			and accountid>0 
				order by contactdate,contactrecordID
		) a 
	GROUP BY accountid
) t
INNER JOIN ld_account b ON t.accountid=b.accountid
SET b.firt_concatuser=t.smownerid
WHERE IFNULL(t.smownerid,0)<>IFNULL(b.firt_concatuser,0);

drop trigger if exists up_account_nolinkdays; 
delimiter;

drop trigger if exists up_account_nolinkdays; 
delimiter || 
CREATE TRIGGER up_account_nolinkdays 
BEFORE UPDATE ON ld_account 
FOR EACH ROW 
BEGIN 

IF new.lastcontactdate<>old.lastcontactdate THEN
	SET new.nolinkdays=datediff(CURDATE(),ifnull(new.lastcontactdate,date_format(new.createdtime,'%Y-%m-%d')));
END IF;

END || 
delimiter;

drop trigger if exists update_account_firtconcatuser1; 
delimiter || 
CREATE TRIGGER update_account_firtconcatuser1 
AFTER INSERT ON ld_contactrecords 
FOR EACH ROW 
BEGIN 

		set @cnt=0;
		select count(1) into @cnt from ld_contactrecords where accountid=new.accountid and deleted=0;
		
		IF @cnt=1 and new.accountid>0 THEN
				update ld_account set firt_concatuser=new.smownerid where accountid=new.accountid;
		END IF;

end || 
delimiter;

select fieldid into @fieldid from ld_field where tabid=6 and columnname='lastcontactuser';
update ld_tranlabel set fieldlabel='最新联系用户' where languagetype='zh' and trantable='ld_field' and Relateid=@fieldid;
delimiter;

select usereportid into @reportid from ld_usereport where `name`='Performancestatisticscollection';
update ld_usereportcolumns set realcolumns='ld_inventoryproductrel:costprice:costprice:Products_产品成本:N'
where `columns` like 'ld_inventoryproductrel:costprice:costprice:Products_costprice%' and Usereportid=@reportid;
delimiter;

update ld_field set typeofdata=replace(typeofdata,'I~','V~') where columnname='accountid';
update ld_field set typeofdata=replace(typeofdata,'I~','V~') where columnname='contactid';

select tabid into @tabid from ld_tab where `name` = 'Commission';
update ld_tabdetailfield set typeofdata = 'D~O',defaultcolumn = 3 where tabid = @tabid and columnname = 'cashbilldate';
update ld_tabdetailfield set typeofdata = 'N~O~25,6',defaultcolumn = 3 where tabid = @tabid and columnname = 'received_amount';
update ld_tabdetailfield set typeofdata = 'D~O',defaultcolumn = 3 where tabid = @tabid and columnname = 'due_date';
update ld_tabdetailfield set typeofdata = 'N~O~25,6',defaultcolumn = 3 where tabid = @tabid and columnname = 'source_total';
delimiter;

insert into ld_desk (languagetype,labelbol,fieldlabel,labeltype)
select 'zh','BILLNUM','单据数量','fixedstr' from dual 
where not EXISTS(select 1 from ld_desk where  labelbol= 'BILLNUM' and labeltype='fixedstr' and languagetype='zh');
insert into ld_desk (languagetype,labelbol,fieldlabel,labeltype)
select 'en','BILLNUM','Quantity','fixedstr' from dual 
where not EXISTS(select 1 from ld_desk where  labelbol= 'BILLNUM' and labeltype='fixedstr' and languagetype='en');
delimiter;

select tabid into @tabid from ld_tab where `name` = 'Expense';
update ld_tabdetailfield set defaultcolumn = 2 where columnname = 'currency_id' and tabid = @tabid;
update ld_tabdetailfield set defaultcolumn = 2 where columnname = 'conversion_rate' and tabid = @tabid;
delimiter;
-- 2016-11-11


update ld_field set typeofdata='V~O',uitype=1,displaytype=2 where columnname='nolinkdays';
-- 2016-11-14

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

update ld_version set old_version='V6.5.3' ,current_version='V6.5.3' ,remark='V6.5.3-20161114';
delimiter;