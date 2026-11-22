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

select max(tabid)into @maxtabid from ld_tab ;
select tabsequence into @tabsequence from ld_tab where `name` = 'VendorContact';
update ld_tab set tabsequence = tabsequence +1000 where tabsequence > @tabsequence;
insert into ld_tab(tabid,name,presence,tabsequence,tablabel,printtab )
select @maxtabid+1,'PurchaseInquiryOrder',0,@tabsequence+1,'PurchaseInquiryOrder',1 from dual
where not EXISTS(select 1 from ld_tab where name='PurchaseInquiryOrder');
set @i=0;
update ld_tab set tabsequence=(@i:=@i+1) order by tabsequence;
delimiter;

select tabid into @tabid from ld_tab  where name='PurchaseInquiryOrder';
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'zh','ld_tab',@tabid,@tabid,'采购询价单' from dual
where not exists(select 1 from ld_tranlabel where tabid=@tabid and relateid=@tabid and languagetype='zh'and trantable='ld_tab' );
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'en','ld_tab',@tabid,@tabid,'PurchaseInquiryOrder' from dual
where not exists(select 1 from ld_tranlabel where tabid=@tabid and relateid=@tabid and languagetype='en' and trantable='ld_tab');
delimiter;

set @parenttab_label = 'Purchase';
select parenttabid into @parenttabid from ld_parenttab where parenttab_label=@parenttab_label;
select sequence into @sequence from ld_parenttabrel where parenttabid = @parenttabid and tabid = (select tabid from ld_tab where `name` = 'VendorContact');
update ld_parenttabrel set sequence = sequence + 1000 where parenttabid = @parenttabid and sequence > @sequence;
select tabid into @tabid from ld_tab  where name='PurchaseInquiryOrder';
insert into ld_parenttabrel(parenttabid,tabid,sequence)
select @parenttabid,@tabid,@sequence+1 from dual where not EXISTS(select 1 from ld_parenttabrel where parenttabid=@parenttabid and tabid=@tabid);
set @i=0;
update ld_parenttabrel set sequence=(@i:=@i+1) where parenttabid = @parenttabid order by sequence;
delimiter;

select max(num_id) into @maxnum_id from ld_modentity_num ;
insert into ld_modentity_num(num_id,semodule,prefix,start_id,cur_id,active,datetype,useuseraccount,isallow,prefixtype)
select @maxnum_id+1 ,'PurchaseInquiryOrder','CGXJ',1,1,1,'none',0,1,0 from dual
where not EXISTS(select 1 from ld_modentity_num where semodule='PurchaseInquiryOrder');
update ld_modentity_num_seq set id=@maxnum_id+1;
delimiter;

select tabid into @tabid from ld_tab where name='PurchaseInquiryOrder';
insert into  ld_modtracker_tabs(tabid,visible)select @tabid,1 from dual where not EXISTS(select 1 from ld_modtracker_tabs);
delimiter;

select tabid into @tabid from ld_tab where name='PurchaseInquiryOrder';
insert into ld_profileallpermission(tabid,operation) select @tabid,actionid from ld_actionmapping
where not EXISTS(select 1 from ld_profileallpermission where tabid=@tabid)
and actionname in('index','Detailview','import','export','Create','Copy','allocate','share','Delete','EditView','ADVANCE','ChangeCreator');
delimiter;

select tabid into @tabid from ld_tab where name='PurchaseInquiryOrder';
insert into ld_entityname(tabid ,modulename,tablename,fieldname,entityidfield,entityidcolumn)
select @tabid,'PurchaseInquiryOrder','ld_purchaseinquiryorder','purchaseinquiryorder_no','purchaseinquiryorderid','purchaseinquiryorderid' from dual
where not exists(select 1 from ld_entityname where tabid=@tabid and modulename='PurchaseInquiryOrder');
delimiter;

select tabid into @tabid from ld_tab where name='PurchaseInquiryOrder';
select max(blockid) into @maxblockid from ld_blocks;
insert into ld_blocks(blockid,tabid,blocklabel,sequence,show_title,visible,create_view,edit_view,detail_view,display_status,iscustom)
select @maxblockid+1,@tabid,'LBL_PURCHASEINQUIRYORDER_BASICINFORMATION',1,0,0,0,0,0,1,0 from dual
where not exists(select 1 from ld_blocks where blocklabel='LBL_PURCHASEINQUIRYORDER_BASICINFORMATION' and tabid=@tabid);
select blockid into @blockid from ld_blocks where blocklabel='LBL_PURCHASEINQUIRYORDER_BASICINFORMATION' and tabid=@tabid;
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'zh','ld_blocks',@tabid,@blockid,'基本信息' from dual
where not exists(select 1 from ld_tranlabel where tabid=@tabid and relateid=@blockid and languagetype='zh' and trantable='ld_blocks');
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'en','ld_blocks',@tabid,@blockid,'Basic Information' from dual
where not exists(select 1 from ld_tranlabel where tabid=@tabid and relateid=@blockid and languagetype='en' and trantable='ld_blocks');

select tabid into @tabid from ld_tab where name='PurchaseInquiryOrder';
select blockid into @blockid  from ld_blocks where tabid=@tabid and blocklabel='LBL_PURCHASEINQUIRYORDER_BASICINFORMATION';
select max(fieldid) into @maxfieldid from ld_field;

insert into ld_field (tabid ,fieldid,columnname,tablename,generatedtype,uitype,fieldname,fieldlabel,readonly,presence,sequence,block,displaytype,typeofdata,quickcreate,issmownerid)
select @tabid,@maxfieldid+1,'purchaseinquiryorder_no','ld_purchaseinquiryorder',1,4,'purchaseinquiryorder_no','单据编号',1,0,1,@blockid ,1,'V~M',0,0 from dual
where not EXISTS(select 1 from ld_field where tabid=@tabid and columnname='purchaseinquiryorder_no');

insert into ld_field (tabid ,fieldid,columnname,tablename,generatedtype,uitype,fieldname,fieldlabel,readonly,presence,sequence,block,displaytype,typeofdata,quickcreate,issmownerid)
select @tabid,@maxfieldid+2,'vendorid','ld_purchaseinquiryorder',1,81,'vendor_id','供应商名称',1,0,2,@blockid ,1,'V~O',0,1 from dual
where not EXISTS(select 1 from ld_field where tabid=@tabid and columnname='vendorid');

insert into ld_field (tabid ,fieldid,columnname,tablename,generatedtype,uitype,fieldname,fieldlabel,readonly,presence,sequence,block,displaytype,typeofdata,quickcreate,issmownerid)
select @tabid,@maxfieldid+3,'contactid','ld_purchaseinquiryorder',1,96,'contact_id','供应商联系人姓名',1,0,3,@blockid ,1,'V~O',0,1 from dual
where not EXISTS(select 1 from ld_field where tabid=@tabid and columnname='contactid');

insert into ld_field (tabid ,fieldid,columnname,tablename,generatedtype,uitype,fieldname,fieldlabel,readonly,presence,sequence,block,displaytype,typeofdata,quickcreate,issmownerid,masseditable)
select @tabid,@maxfieldid+4,'smownerid','ld_purchaseinquiryorder',1,53,'assigned_user_id','采购负责人',1,0,4,@blockid ,1,'V~M',0,1,0 from dual
where not EXISTS(select 1 from ld_field where tabid=@tabid and columnname='smownerid');

insert into ld_field (tabid ,fieldid,columnname,tablename,generatedtype,uitype,fieldname,fieldlabel,readonly,presence,sequence,block,displaytype,typeofdata,quickcreate,issmownerid)
select @tabid,@maxfieldid+5,'approvestatus','ld_purchaseinquiryorder',1,609,'approvestatus','审批状态',1,0,5,@blockid ,2,'V~O',0,1 from dual
where not EXISTS(select 1 from ld_field where tabid=@tabid and columnname='approvestatus');

insert into ld_field (tabid ,fieldid,columnname,tablename,generatedtype,uitype,fieldname,fieldlabel,readonly,presence,sequence,block,displaytype,typeofdata,quickcreate,issmownerid)
select @tabid,@maxfieldid+6,'approveby','ld_purchaseinquiryorder',1,131,'approveby','上一步审批人',1,0,6,@blockid ,2,'V~O',0,1 from dual
where not EXISTS(select 1 from ld_field where tabid=@tabid and columnname='approveby');

insert into ld_field (tabid ,fieldid,columnname,tablename,generatedtype,uitype,fieldname,fieldlabel,readonly,presence,sequence,block,displaytype,typeofdata,quickcreate,issmownerid)
select @tabid,@maxfieldid+7,'currentapprover','ld_purchaseinquiryorder',1,132,'currentapprover','当前审批人',1,0,7,@blockid ,2,'V~O',0,1 from dual
where not EXISTS(select 1 from ld_field where tabid=@tabid and columnname='currentapprover');

insert into ld_field (tabid ,fieldid,columnname,tablename,generatedtype,uitype,fieldname,fieldlabel,readonly,presence,sequence,block,displaytype,typeofdata,quickcreate,issmownerid)
select @tabid,@maxfieldid+8,'createdtime','ld_purchaseinquiryorder',1,70,'createdtime','创建时间',1,0,8,@blockid ,2,'DT~O',1,0 from dual
where not EXISTS(select 1 from ld_field where tabid=@tabid and columnname='createdtime');

insert into ld_field (tabid ,fieldid,columnname,tablename,generatedtype,uitype,fieldname,fieldlabel,readonly,presence,sequence,block,displaytype,typeofdata,quickcreate,issmownerid)
select @tabid,@maxfieldid+9,'smcreatorid','ld_purchaseinquiryorder',1,52,'smcreatorid','创建人',1,0,9,@blockid ,2,'V~O',1,0 from dual
where not EXISTS(select 1 from ld_field where tabid=@tabid and columnname='smcreatorid');

insert into ld_field (tabid ,fieldid,columnname,tablename,generatedtype,uitype,fieldname,fieldlabel,readonly,presence,sequence,block,displaytype,typeofdata,quickcreate,issmownerid)
select @tabid,@maxfieldid+10,'modifiedtime','ld_purchaseinquiryorder',1,70,'modifiedtime','修改时间',1,0,10,@blockid ,2,'DT~O',1,0 from dual
where not EXISTS(select 1 from ld_field where tabid=@tabid and columnname='modifiedtime');

insert into ld_field (tabid ,fieldid,columnname,tablename,generatedtype,uitype,fieldname,fieldlabel,readonly,presence,sequence,block,displaytype,typeofdata,quickcreate,issmownerid)
select @tabid,@maxfieldid+11,'modifiedby','ld_purchaseinquiryorder',1,52,'modifiedby','最新更新人',1,0,11,@blockid ,2,'V~O',1,0 from dual
where not EXISTS(select 1 from ld_field where tabid=@tabid and columnname='modifiedby');

insert into ld_field (tabid ,fieldid,columnname,tablename,generatedtype,uitype,fieldname,fieldlabel,readonly,presence,sequence,block,displaytype,typeofdata,quickcreate,issmownerid)
select @tabid,@maxfieldid+12,'total','ld_purchaseinquiryorder',1,72,'hdnGrandTotal','合计',1,0,12,@blockid ,3,'N~O',3,0 from dual
where not EXISTS(select 1 from ld_field where tabid=@tabid and columnname='total');

insert into ld_field (tabid ,fieldid,columnname,tablename,generatedtype,uitype,fieldname,fieldlabel,readonly,presence,sequence,block,displaytype,typeofdata,quickcreate,issmownerid)
select @tabid,@maxfieldid+13,'subtotal','ld_purchaseinquiryorder',1,72,'hdnSubTotal','小计',1,0,13,@blockid ,3,'N~O',3,0 from dual
where not EXISTS(select 1 from ld_field where tabid=@tabid and columnname='subtotal');

insert into ld_field (tabid ,fieldid,columnname,tablename,generatedtype,uitype,fieldname,fieldlabel,readonly,presence,sequence,block,displaytype,typeofdata,quickcreate,issmownerid)
select @tabid,@maxfieldid+14,'taxtype','ld_purchaseinquiryorder',1,16,'hdnTaxType','Tax Type',1,1,14,@blockid ,3,'V~O',3,0 from dual
where not EXISTS(select 1 from ld_field where tabid=@tabid and columnname='subtotal');

insert into ld_field (tabid ,fieldid,columnname,tablename,generatedtype,uitype,fieldname,fieldlabel,readonly,presence,sequence,block,displaytype,typeofdata,quickcreate,issmownerid)
select @tabid,@maxfieldid+15,'discount_percent','ld_purchaseinquiryorder',1,9,'hdnDiscountPercent','Discount Percent',1,1,15,@blockid ,3,'N~O',3,0 from dual
where not EXISTS(select 1 from ld_field where tabid=@tabid and columnname='discount_percent');

insert into ld_field (tabid ,fieldid,columnname,tablename,generatedtype,uitype,fieldname,fieldlabel,readonly,presence,sequence,block,displaytype,typeofdata,quickcreate,issmownerid)
select @tabid,@maxfieldid+16,'discount_amount','ld_purchaseinquiryorder',1,72,'hdnDiscountAmount','Discount Percent',1,0,16,@blockid ,3,'N~O',3,0 from dual
where not EXISTS(select 1 from ld_field where tabid=@tabid and columnname='discount_amount');

insert into ld_field (tabid ,fieldid,columnname,tablename,generatedtype,uitype,fieldname,fieldlabel,readonly,presence,sequence,block,displaytype,typeofdata,quickcreate,issmownerid)
select @tabid,@maxfieldid+17,'s_h_amount','ld_purchaseinquiryorder',1,72,'hdnS_H_Amount','运费和物流附加费',1,1,17,@blockid ,3,'N~O',3,0 from dual
where not EXISTS(select 1 from ld_field where tabid=@tabid and columnname='s_h_amount');

insert into ld_field (tabid ,fieldid,columnname,tablename,generatedtype,uitype,fieldname,fieldlabel,readonly,presence,sequence,block,displaytype,typeofdata,quickcreate,issmownerid)
select @tabid,@maxfieldid+18,'print_times','ld_purchaseinquiryorder',1,1,'print_times','打印次数',1,0,18,@blockid ,2,'N~O',3,0 from dual
where not EXISTS(select 1 from ld_field where tabid=@tabid and columnname='print_times');

insert into ld_field (tabid ,fieldid,columnname,tablename,generatedtype,uitype,fieldname,fieldlabel,readonly,presence,sequence,block,displaytype,typeofdata,quickcreate,issmownerid)
select @tabid,@maxfieldid+19,'currency_id','ld_purchaseinquiryorder',1,117,'currency_id','货币',1,0,19,@blockid ,3,'V~M',1,0 from dual
where not EXISTS(select 1 from ld_field where tabid=@tabid and columnname='currency_id');
delimiter;

insert into ld_field (tabid ,fieldid,columnname,tablename,generatedtype,uitype,fieldname,fieldlabel,readonly,presence,sequence,block,displaytype,typeofdata,quickcreate,issmownerid)
select @tabid,@maxfieldid+20,'conversion_rate','ld_purchaseinquiryorder',1,1,'conversion_rate','汇率',1,0,20,@blockid ,3,'N~O',1,0 from dual
where not EXISTS(select 1 from ld_field where tabid=@tabid and columnname='conversion_rate');
delimiter;

call getallprofile('PurchaseInquiryOrder');
delimiter;

select tabid into @tabid from ld_tab  where name='PurchaseInquiryOrder';
select fieldid into @fieldid from ld_field where tabid=@tabid and columnname='purchaseinquiryorder_no';
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'zh','ld_field',@tabid, @fieldid,'单据编号' from dual
where not exists(select 1 from ld_tranlabel where tabid=@tabid and relateid=@fieldid and languagetype='zh'and trantable='ld_field' );
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'en','ld_field',@tabid,@fieldid,'Leads No' from dual
where not exists(select 1 from ld_tranlabel where tabid=@tabid and relateid=@fieldid and languagetype='en' and trantable='ld_field');
delimiter;

select tabid into @tabid from ld_tab  where name='PurchaseInquiryOrder';
select fieldid into @fieldid from ld_field where tabid=@tabid and columnname='vendorid';
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'zh','ld_field',@tabid, @fieldid,'供应商名称' from dual
where not exists(select 1 from ld_tranlabel where tabid=@tabid and relateid=@fieldid and languagetype='zh'and trantable='ld_field' );
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'en','ld_field',@tabid,@fieldid,'Vendor name' from dual
where not exists(select 1 from ld_tranlabel where tabid=@tabid and relateid=@fieldid and languagetype='en' and trantable='ld_field');
delimiter;

select tabid into @tabid from ld_tab  where name='PurchaseInquiryOrder';
select fieldid into @fieldid from ld_field where tabid=@tabid and columnname='contactid';
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'zh','ld_field',@tabid, @fieldid,'供应商联系人姓名' from dual
where not exists(select 1 from ld_tranlabel where tabid=@tabid and relateid=@fieldid and languagetype='zh'and trantable='ld_field' );
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'en','ld_field',@tabid,@fieldid,'Vendorcontact name' from dual
where not exists(select 1 from ld_tranlabel where tabid=@tabid and relateid=@fieldid and languagetype='en' and trantable='ld_field');
delimiter;

select tabid into @tabid from ld_tab  where name='PurchaseInquiryOrder';
select fieldid into @fieldid from ld_field where tabid=@tabid and columnname='smownerid';
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'zh','ld_field',@tabid, @fieldid,'采购负责人' from dual
where not exists(select 1 from ld_tranlabel where tabid=@tabid and relateid=@fieldid and languagetype='zh'and trantable='ld_field' );
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'en','ld_field',@tabid,@fieldid,'Smownerid' from dual
where not exists(select 1 from ld_tranlabel where tabid=@tabid and relateid=@fieldid and languagetype='en' and trantable='ld_field');
delimiter;

select tabid into @tabid from ld_tab  where name='PurchaseInquiryOrder';
select fieldid into @fieldid from ld_field where tabid=@tabid and columnname='approvestatus';
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'zh','ld_field',@tabid, @fieldid,'审批状态' from dual
where not exists(select 1 from ld_tranlabel where tabid=@tabid and relateid=@fieldid and languagetype='zh'and trantable='ld_field' );
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'en','ld_field',@tabid,@fieldid,'Approve status' from dual
where not exists(select 1 from ld_tranlabel where tabid=@tabid and relateid=@fieldid and languagetype='en' and trantable='ld_field');
delimiter;

select tabid into @tabid from ld_tab  where name='PurchaseInquiryOrder';
select fieldid into @fieldid from ld_field where tabid=@tabid and columnname='approveby';
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'zh','ld_field',@tabid, @fieldid,'上一步审批人' from dual
where not exists(select 1 from ld_tranlabel where tabid=@tabid and relateid=@fieldid and languagetype='zh'and trantable='ld_field' );
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'en','ld_field',@tabid,@fieldid,'The Last Approver' from dual
where not exists(select 1 from ld_tranlabel where tabid=@tabid and relateid=@fieldid and languagetype='en' and trantable='ld_field');
delimiter;

select tabid into @tabid from ld_tab  where name='PurchaseInquiryOrder';
select fieldid into @fieldid from ld_field where tabid=@tabid and columnname='currentapprover';
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'zh','ld_field',@tabid, @fieldid,'当前审批人' from dual
where not exists(select 1 from ld_tranlabel where tabid=@tabid and relateid=@fieldid and languagetype='zh'and trantable='ld_field' );
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'en','ld_field',@tabid,@fieldid,'Current Approver' from dual
where not exists(select 1 from ld_tranlabel where tabid=@tabid and relateid=@fieldid and languagetype='en' and trantable='ld_field');
delimiter;

select tabid into @tabid from ld_tab  where name='PurchaseInquiryOrder';
select fieldid into @fieldid from ld_field where tabid=@tabid and columnname='createdtime';
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'zh','ld_field',@tabid, @fieldid,'创建时间' from dual
where not exists(select 1 from ld_tranlabel where tabid=@tabid and relateid=@fieldid and languagetype='zh'and trantable='ld_field' );
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'en','ld_field',@tabid,@fieldid,'Created Time' from dual
where not exists(select 1 from ld_tranlabel where tabid=@tabid and relateid=@fieldid and languagetype='en' and trantable='ld_field');
delimiter;

select tabid into @tabid from ld_tab  where name='PurchaseInquiryOrder';
select fieldid into @fieldid from ld_field where tabid=@tabid and columnname='smcreatorid';
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'zh','ld_field',@tabid, @fieldid,'创建人' from dual
where not exists(select 1 from ld_tranlabel where tabid=@tabid and relateid=@fieldid and languagetype='zh'and trantable='ld_field' );
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'en','ld_field',@tabid,@fieldid,'Creator' from dual
where not exists(select 1 from ld_tranlabel where tabid=@tabid and relateid=@fieldid and languagetype='en' and trantable='ld_field');
delimiter;

select tabid into @tabid from ld_tab  where name='PurchaseInquiryOrder';
select fieldid into @fieldid from ld_field where tabid=@tabid and columnname='modifiedtime';
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'zh','ld_field',@tabid, @fieldid,'修改时间' from dual
where not exists(select 1 from ld_tranlabel where tabid=@tabid and relateid=@fieldid and languagetype='zh'and trantable='ld_field' );
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'en','ld_field',@tabid,@fieldid,'Modified Time' from dual
where not exists(select 1 from ld_tranlabel where tabid=@tabid and relateid=@fieldid and languagetype='en' and trantable='ld_field');
delimiter;

select tabid into @tabid from ld_tab  where name='PurchaseInquiryOrder';
select fieldid into @fieldid from ld_field where tabid=@tabid and columnname='modifiedby';
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'zh','ld_field',@tabid, @fieldid,'最新更新人' from dual
where not exists(select 1 from ld_tranlabel where tabid=@tabid and relateid=@fieldid and languagetype='zh'and trantable='ld_field' );
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'en','ld_field',@tabid,@fieldid,'Modified By' from dual
where not exists(select 1 from ld_tranlabel where tabid=@tabid and relateid=@fieldid and languagetype='en' and trantable='ld_field');
delimiter;

select tabid into @tabid from ld_tab  where name='PurchaseInquiryOrder';
select fieldid into @fieldid from ld_field where tabid=@tabid and columnname='total';
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'zh','ld_field',@tabid, @fieldid,'合计' from dual
where not exists(select 1 from ld_tranlabel where tabid=@tabid and relateid=@fieldid and languagetype='zh'and trantable='ld_field' );
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'en','ld_field',@tabid,@fieldid,'Total' from dual
where not exists(select 1 from ld_tranlabel where tabid=@tabid and relateid=@fieldid and languagetype='en' and trantable='ld_field');
delimiter;

select tabid into @tabid from ld_tab  where name='PurchaseInquiryOrder';
select fieldid into @fieldid from ld_field where tabid=@tabid and columnname='subtotal';
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'zh','ld_field',@tabid, @fieldid,'小计' from dual
where not exists(select 1 from ld_tranlabel where tabid=@tabid and relateid=@fieldid and languagetype='zh'and trantable='ld_field' );
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'en','ld_field',@tabid,@fieldid,'Sub Total' from dual
where not exists(select 1 from ld_tranlabel where tabid=@tabid and relateid=@fieldid and languagetype='en' and trantable='ld_field');
delimiter;

select tabid into @tabid from ld_tab  where name='PurchaseInquiryOrder';
select fieldid into @fieldid from ld_field where tabid=@tabid and columnname='taxtype';
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'zh','ld_field',@tabid, @fieldid,'税种' from dual
where not exists(select 1 from ld_tranlabel where tabid=@tabid and relateid=@fieldid and languagetype='zh'and trantable='ld_field' );
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'en','ld_field',@tabid,@fieldid,'Tax Type' from dual
where not exists(select 1 from ld_tranlabel where tabid=@tabid and relateid=@fieldid and languagetype='en' and trantable='ld_field');
delimiter;

select tabid into @tabid from ld_tab  where name='PurchaseInquiryOrder';
select fieldid into @fieldid from ld_field where tabid=@tabid and columnname='discount_percent';
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'zh','ld_field',@tabid, @fieldid,'折扣百分比' from dual
where not exists(select 1 from ld_tranlabel where tabid=@tabid and relateid=@fieldid and languagetype='zh'and trantable='ld_field' );
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'en','ld_field',@tabid,@fieldid,'Discount Percent' from dual
where not exists(select 1 from ld_tranlabel where tabid=@tabid and relateid=@fieldid and languagetype='en' and trantable='ld_field');
delimiter;

select tabid into @tabid from ld_tab  where name='PurchaseInquiryOrder';
select fieldid into @fieldid from ld_field where tabid=@tabid and columnname='discount_amount';
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'zh','ld_field',@tabid, @fieldid,'折扣直接降价' from dual
where not exists(select 1 from ld_tranlabel where tabid=@tabid and relateid=@fieldid and languagetype='zh'and trantable='ld_field' );
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'en','ld_field',@tabid,@fieldid,'Discount Amount' from dual
where not exists(select 1 from ld_tranlabel where tabid=@tabid and relateid=@fieldid and languagetype='en' and trantable='ld_field');
delimiter;

select tabid into @tabid from ld_tab  where name='PurchaseInquiryOrder';
select fieldid into @fieldid from ld_field where tabid=@tabid and columnname='s_h_amount';
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'zh','ld_field',@tabid, @fieldid,'运费和物流附加费' from dual
where not exists(select 1 from ld_tranlabel where tabid=@tabid and relateid=@fieldid and languagetype='zh'and trantable='ld_field' );
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'en','ld_field',@tabid,@fieldid,'S&H Amount' from dual
where not exists(select 1 from ld_tranlabel where tabid=@tabid and relateid=@fieldid and languagetype='en' and trantable='ld_field');
delimiter;

select tabid into @tabid from ld_tab  where name='PurchaseInquiryOrder';
select fieldid into @fieldid from ld_field where tabid=@tabid and columnname='print_times';
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'zh','ld_field',@tabid, @fieldid,'打印次数' from dual
where not exists(select 1 from ld_tranlabel where tabid=@tabid and relateid=@fieldid and languagetype='zh'and trantable='ld_field' );
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'en','ld_field',@tabid,@fieldid,'Print times' from dual
where not exists(select 1 from ld_tranlabel where tabid=@tabid and relateid=@fieldid and languagetype='en' and trantable='ld_field');
delimiter;

select tabid into @tabid from ld_tab  where name='PurchaseInquiryOrder';
select fieldid into @fieldid from ld_field where tabid=@tabid and columnname='currency_id';
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'zh','ld_field',@tabid, @fieldid,'币种' from dual
where not exists(select 1 from ld_tranlabel where tabid=@tabid and relateid=@fieldid and languagetype='zh'and trantable='ld_field' );
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'en','ld_field',@tabid,@fieldid,'Currency' from dual
where not exists(select 1 from ld_tranlabel where tabid=@tabid and relateid=@fieldid and languagetype='en' and trantable='ld_field');
delimiter;

select tabid into @tabid from ld_tab  where name='PurchaseInquiryOrder';
select fieldid into @fieldid from ld_field where tabid=@tabid and columnname='conversion_rate';
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'zh','ld_field',@tabid, @fieldid,'汇率' from dual
where not exists(select 1 from ld_tranlabel where tabid=@tabid and relateid=@fieldid and languagetype='zh'and trantable='ld_field' );
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'en','ld_field',@tabid,@fieldid,'Conversion rate' from dual
where not exists(select 1 from ld_tranlabel where tabid=@tabid and relateid=@fieldid and languagetype='en' and trantable='ld_field');
delimiter;

update ld_field_seq set id = (select max(fieldid) from ld_field);
delimiter;


select max(cvid) into @maxcvid  from ld_customview;
insert into ld_customview (cvid,viewname,setdefault,setmetrics,entitytype,status,userid,sequence)
select @maxcvid+1,'All',1,0,'PurchaseInquiryOrder',3,1,1 from dual
where not EXISTS(select 1 from ld_customview where entitytype='PurchaseInquiryOrder' and viewname='All');
insert into ld_customview (cvid,viewname,setdefault,setmetrics,entitytype,status,userid,sequence)
select @maxcvid+2,'已批准',0,0,'PurchaseInquiryOrder',3,1,2 from dual
where not EXISTS(select 1 from ld_customview where entitytype='PurchaseInquiryOrder' and viewname='已批准');
insert into ld_customview (cvid,viewname,setdefault,setmetrics,entitytype,status,userid,sequence)
select @maxcvid+3,'审批中',0,0,'PurchaseInquiryOrder',3,1,3 from dual
where not EXISTS(select 1 from ld_customview where entitytype='PurchaseInquiryOrder' and viewname='审批中');
insert into ld_customview (cvid,viewname,setdefault,setmetrics,entitytype,status,userid,sequence)
select @maxcvid+4,'未提交',0,0,'PurchaseInquiryOrder',3,1,4 from dual
where not EXISTS(select 1 from ld_customview where entitytype='PurchaseInquiryOrder' and viewname='未提交');
insert into ld_customview (cvid,viewname,setdefault,setmetrics,entitytype,status,userid,sequence)
select @maxcvid+5,'已驳回',0,0,'PurchaseInquiryOrder',3,1,5 from dual
where not EXISTS(select 1 from ld_customview where entitytype='PurchaseInquiryOrder' and viewname='已驳回');
insert into ld_customview (cvid,viewname,setdefault,setmetrics,entitytype,status,userid,sequence)
select @maxcvid+6,'已拒绝',0,0,'PurchaseInquiryOrder',3,1,6 from dual
where not EXISTS(select 1 from ld_customview where entitytype='PurchaseInquiryOrder' and viewname='已拒绝');
update ld_customview_seq set id = (select max(cvid) from ld_customview);
delimiter;

select tabid into @tabid from ld_tab where name='PurchaseInquiryOrder';
select cvid into @cvid from ld_customview where entitytype='PurchaseInquiryOrder' and viewname='All';
delete from ld_tabwithproductview where cvid = @cvid and tabid = @tabid;
insert into ld_tabwithproductview(tabid,columns,sequence,cvid)
select @tabid,'ld_purchaseinquiryorder:purchaseinquiryorder_no:purchaseinquiryorder_no:PurchaseInquiryOrder_fieldlabel:V',0,@cvid;
insert into ld_tabwithproductview(tabid,columns,sequence,cvid)
select @tabid,'ld_purchaseinquiryorder:vendorid:vendor_id:PurchaseInquiryOrder_fieldlabel:V',1,@cvid;
insert into ld_tabwithproductview(tabid,columns,sequence,cvid)
select @tabid,'ld_purchaseinquiryorder:contactid:contact_id:PurchaseInquiryOrder_fieldlabel:V',2,@cvid;
insert into ld_tabwithproductview(tabid,columns,sequence,cvid)
select @tabid,'ld_purchaseinquiryorder:approvestatus:approvestatus:PurchaseInquiryOrder_fieldlabel:V',3,@cvid;
insert into ld_tabwithproductview(tabid,columns,sequence,cvid)
select @tabid,'ld_purchaseinquiryorder:currentapprover:currentapprover:PurchaseInquiryOrder_fieldlabel:V',4,@cvid;
insert into ld_tabwithproductview(tabid,columns,sequence,cvid)
select @tabid,'ld_purchaseinquiryorder:total:hdnGrandTotal:PurchaseInquiryOrder_fieldlabel:N',5,@cvid;
insert into ld_tabwithproductview(tabid,columns,sequence,cvid)
select @tabid,'ld_purchaseinquiryorder:smownerid:assigned_user_id:PurchaseInquiryOrder_fieldlabel:N',6,@cvid;
insert into ld_tabwithproductview(tabid,columns,sequence,cvid)
select @tabid,'ld_products:productname:productname:Products_fieldlabel:V',7,@cvid;
insert into ld_tabwithproductview(tabid,columns,sequence,cvid)
select @tabid,'ld_inventoryproductrel:quantity:quantity:Products_fieldlabel:N',8,@cvid;
delimiter;

select tabid into @tabid from ld_tab where name='PurchaseInquiryOrder';
select cvid into @cvid from ld_customview where entitytype='PurchaseInquiryOrder' and viewname='已批准';
delete from ld_tabwithproductview where cvid = @cvid;
delete from ld_cvadvfilter where cvid = @cvid;
insert into ld_cvadvfilter(cvid,columnindex,columnname,comparator,value,groupid,column_condition)
select @cvid,0,'ld_purchaseinquiryorder:approvestatus:approvestatus:PurchaseInquiryOrder_fieldlabel:V','e','已批准',1,'';
delete from ld_cvadvfilter_grouping where cvid = @cvid;
insert into ld_cvadvfilter_grouping(groupid,cvid,group_condition,condition_expression)
select 1,@cvid,'',0;
insert into ld_tabwithproductview(tabid,columns,sequence,cvid)
select @tabid,'ld_purchaseinquiryorder:purchaseinquiryorder_no:purchaseinquiryorder_no:PurchaseInquiryOrder_fieldlabel:V',0,@cvid;
insert into ld_tabwithproductview(tabid,columns,sequence,cvid)
select @tabid,'ld_purchaseinquiryorder:vendorid:vendor_id:PurchaseInquiryOrder_fieldlabel:V',1,@cvid;
insert into ld_tabwithproductview(tabid,columns,sequence,cvid)
select @tabid,'ld_purchaseinquiryorder:contactid:contact_id:PurchaseInquiryOrder_fieldlabel:V',2,@cvid;
insert into ld_tabwithproductview(tabid,columns,sequence,cvid)
select @tabid,'ld_purchaseinquiryorder:approvestatus:approvestatus:PurchaseInquiryOrder_fieldlabel:V',3,@cvid;
insert into ld_tabwithproductview(tabid,columns,sequence,cvid)
select @tabid,'ld_purchaseinquiryorder:currentapprover:currentapprover:PurchaseInquiryOrder_fieldlabel:V',4,@cvid;
insert into ld_tabwithproductview(tabid,columns,sequence,cvid)
select @tabid,'ld_purchaseinquiryorder:total:hdnGrandTotal:PurchaseInquiryOrder_fieldlabel:N',5,@cvid;
insert into ld_tabwithproductview(tabid,columns,sequence,cvid)
select @tabid,'ld_purchaseinquiryorder:smownerid:assigned_user_id:PurchaseInquiryOrder_fieldlabel:N',6,@cvid;
insert into ld_tabwithproductview(tabid,columns,sequence,cvid)
select @tabid,'ld_products:productname:productname:Products_fieldlabel:V',7,@cvid;
insert into ld_tabwithproductview(tabid,columns,sequence,cvid)
select @tabid,'ld_inventoryproductrel:quantity:quantity:Products_fieldlabel:N',8,@cvid;
delimiter;

select tabid into @tabid from ld_tab where name='PurchaseInquiryOrder';
select cvid into @cvid from ld_customview where entitytype='PurchaseInquiryOrder' and viewname='审批中';
delete from ld_tabwithproductview where cvid = @cvid;
delete from ld_cvadvfilter where cvid = @cvid;
insert into ld_cvadvfilter(cvid,columnindex,columnname,comparator,value,groupid,column_condition)
select @cvid,0,'ld_purchaseinquiryorder:approvestatus:approvestatus:PurchaseInquiryOrder_fieldlabel:V','e','审批中',1,'';
delete from ld_cvadvfilter_grouping where cvid = @cvid;
insert into ld_cvadvfilter_grouping(groupid,cvid,group_condition,condition_expression)
select 1,@cvid,'',0;
insert into ld_tabwithproductview(tabid,columns,sequence,cvid)
select @tabid,'ld_purchaseinquiryorder:purchaseinquiryorder_no:purchaseinquiryorder_no:PurchaseInquiryOrder_fieldlabel:V',0,@cvid;
insert into ld_tabwithproductview(tabid,columns,sequence,cvid)
select @tabid,'ld_purchaseinquiryorder:vendorid:vendor_id:PurchaseInquiryOrder_fieldlabel:V',1,@cvid;
insert into ld_tabwithproductview(tabid,columns,sequence,cvid)
select @tabid,'ld_purchaseinquiryorder:contactid:contact_id:PurchaseInquiryOrder_fieldlabel:V',2,@cvid;
insert into ld_tabwithproductview(tabid,columns,sequence,cvid)
select @tabid,'ld_purchaseinquiryorder:approvestatus:approvestatus:PurchaseInquiryOrder_fieldlabel:V',3,@cvid;
insert into ld_tabwithproductview(tabid,columns,sequence,cvid)
select @tabid,'ld_purchaseinquiryorder:currentapprover:currentapprover:PurchaseInquiryOrder_fieldlabel:V',4,@cvid;
insert into ld_tabwithproductview(tabid,columns,sequence,cvid)
select @tabid,'ld_purchaseinquiryorder:total:hdnGrandTotal:PurchaseInquiryOrder_fieldlabel:N',5,@cvid;
insert into ld_tabwithproductview(tabid,columns,sequence,cvid)
select @tabid,'ld_purchaseinquiryorder:smownerid:assigned_user_id:PurchaseInquiryOrder_fieldlabel:N',6,@cvid;
insert into ld_tabwithproductview(tabid,columns,sequence,cvid)
select @tabid,'ld_products:productname:productname:Products_fieldlabel:V',7,@cvid;
insert into ld_tabwithproductview(tabid,columns,sequence,cvid)
select @tabid,'ld_inventoryproductrel:quantity:quantity:Products_fieldlabel:N',8,@cvid;
delimiter;

select tabid into @tabid from ld_tab where name='PurchaseInquiryOrder';
select cvid into @cvid from ld_customview where entitytype='PurchaseInquiryOrder' and viewname='未提交';
delete from ld_tabwithproductview where cvid = @cvid;
delete from ld_cvadvfilter where cvid = @cvid;
insert into ld_cvadvfilter(cvid,columnindex,columnname,comparator,value,groupid,column_condition)
select @cvid,0,'ld_purchaseinquiryorder:approvestatus:approvestatus:PurchaseInquiryOrder_fieldlabel:V','e','未提交',1,'';
delete from ld_cvadvfilter_grouping where cvid = @cvid;
insert into ld_cvadvfilter_grouping(groupid,cvid,group_condition,condition_expression)
select 1,@cvid,'',0;
insert into ld_tabwithproductview(tabid,columns,sequence,cvid)
select @tabid,'ld_purchaseinquiryorder:purchaseinquiryorder_no:purchaseinquiryorder_no:PurchaseInquiryOrder_fieldlabel:V',0,@cvid;
insert into ld_tabwithproductview(tabid,columns,sequence,cvid)
select @tabid,'ld_purchaseinquiryorder:vendorid:vendor_id:PurchaseInquiryOrder_fieldlabel:V',1,@cvid;
insert into ld_tabwithproductview(tabid,columns,sequence,cvid)
select @tabid,'ld_purchaseinquiryorder:contactid:contact_id:PurchaseInquiryOrder_fieldlabel:V',2,@cvid;
insert into ld_tabwithproductview(tabid,columns,sequence,cvid)
select @tabid,'ld_purchaseinquiryorder:approvestatus:approvestatus:PurchaseInquiryOrder_fieldlabel:V',3,@cvid;
insert into ld_tabwithproductview(tabid,columns,sequence,cvid)
select @tabid,'ld_purchaseinquiryorder:currentapprover:currentapprover:PurchaseInquiryOrder_fieldlabel:V',4,@cvid;
insert into ld_tabwithproductview(tabid,columns,sequence,cvid)
select @tabid,'ld_purchaseinquiryorder:total:hdnGrandTotal:PurchaseInquiryOrder_fieldlabel:N',5,@cvid;
insert into ld_tabwithproductview(tabid,columns,sequence,cvid)
select @tabid,'ld_purchaseinquiryorder:smownerid:assigned_user_id:PurchaseInquiryOrder_fieldlabel:N',6,@cvid;
insert into ld_tabwithproductview(tabid,columns,sequence,cvid)
select @tabid,'ld_products:productname:productname:Products_fieldlabel:V',7,@cvid;
insert into ld_tabwithproductview(tabid,columns,sequence,cvid)
select @tabid,'ld_inventoryproductrel:quantity:quantity:Products_fieldlabel:N',8,@cvid;
delimiter;

select tabid into @tabid from ld_tab where name='PurchaseInquiryOrder';
select cvid into @cvid from ld_customview where entitytype='PurchaseInquiryOrder' and viewname='已驳回';
delete from ld_tabwithproductview where cvid = @cvid;
delete from ld_cvadvfilter where cvid = @cvid;
insert into ld_cvadvfilter(cvid,columnindex,columnname,comparator,value,groupid,column_condition)
select @cvid,0,'ld_purchaseinquiryorder:approvestatus:approvestatus:PurchaseInquiryOrder_fieldlabel:V','e','已驳回',1,'';
delete from ld_cvadvfilter_grouping where cvid = @cvid;
insert into ld_cvadvfilter_grouping(groupid,cvid,group_condition,condition_expression)
select 1,@cvid,'',0;
insert into ld_tabwithproductview(tabid,columns,sequence,cvid)
select @tabid,'ld_purchaseinquiryorder:purchaseinquiryorder_no:purchaseinquiryorder_no:PurchaseInquiryOrder_fieldlabel:V',0,@cvid;
insert into ld_tabwithproductview(tabid,columns,sequence,cvid)
select @tabid,'ld_purchaseinquiryorder:vendorid:vendor_id:PurchaseInquiryOrder_fieldlabel:V',1,@cvid;
insert into ld_tabwithproductview(tabid,columns,sequence,cvid)
select @tabid,'ld_purchaseinquiryorder:contactid:contact_id:PurchaseInquiryOrder_fieldlabel:V',2,@cvid;
insert into ld_tabwithproductview(tabid,columns,sequence,cvid)
select @tabid,'ld_purchaseinquiryorder:approvestatus:approvestatus:PurchaseInquiryOrder_fieldlabel:V',3,@cvid;
insert into ld_tabwithproductview(tabid,columns,sequence,cvid)
select @tabid,'ld_purchaseinquiryorder:currentapprover:currentapprover:PurchaseInquiryOrder_fieldlabel:V',4,@cvid;
insert into ld_tabwithproductview(tabid,columns,sequence,cvid)
select @tabid,'ld_purchaseinquiryorder:total:hdnGrandTotal:PurchaseInquiryOrder_fieldlabel:N',5,@cvid;
insert into ld_tabwithproductview(tabid,columns,sequence,cvid)
select @tabid,'ld_purchaseinquiryorder:smownerid:assigned_user_id:PurchaseInquiryOrder_fieldlabel:N',6,@cvid;
insert into ld_tabwithproductview(tabid,columns,sequence,cvid)
select @tabid,'ld_products:productname:productname:Products_fieldlabel:V',7,@cvid;
insert into ld_tabwithproductview(tabid,columns,sequence,cvid)
select @tabid,'ld_inventoryproductrel:quantity:quantity:Products_fieldlabel:N',8,@cvid;
delimiter;

select tabid into @tabid from ld_tab where name='PurchaseInquiryOrder';
select cvid into @cvid from ld_customview where entitytype='PurchaseInquiryOrder' and viewname='已拒绝';
delete from ld_tabwithproductview where cvid = @cvid;
delete from ld_cvadvfilter where cvid = @cvid;
insert into ld_cvadvfilter(cvid,columnindex,columnname,comparator,value,groupid,column_condition)
select @cvid,0,'ld_purchaseinquiryorder:approvestatus:approvestatus:PurchaseInquiryOrder_fieldlabel:V','e','已拒绝',1,'';
delete from ld_cvadvfilter_grouping where cvid = @cvid;
insert into ld_cvadvfilter_grouping(groupid,cvid,group_condition,condition_expression)
select 1,@cvid,'',0;
insert into ld_tabwithproductview(tabid,columns,sequence,cvid)
select @tabid,'ld_purchaseinquiryorder:purchaseinquiryorder_no:purchaseinquiryorder_no:PurchaseInquiryOrder_fieldlabel:V',0,@cvid;
insert into ld_tabwithproductview(tabid,columns,sequence,cvid)
select @tabid,'ld_purchaseinquiryorder:vendorid:vendor_id:PurchaseInquiryOrder_fieldlabel:V',1,@cvid;
insert into ld_tabwithproductview(tabid,columns,sequence,cvid)
select @tabid,'ld_purchaseinquiryorder:contactid:contact_id:PurchaseInquiryOrder_fieldlabel:V',2,@cvid;
insert into ld_tabwithproductview(tabid,columns,sequence,cvid)
select @tabid,'ld_purchaseinquiryorder:approvestatus:approvestatus:PurchaseInquiryOrder_fieldlabel:V',3,@cvid;
insert into ld_tabwithproductview(tabid,columns,sequence,cvid)
select @tabid,'ld_purchaseinquiryorder:currentapprover:currentapprover:PurchaseInquiryOrder_fieldlabel:V',4,@cvid;
insert into ld_tabwithproductview(tabid,columns,sequence,cvid)
select @tabid,'ld_purchaseinquiryorder:total:hdnGrandTotal:PurchaseInquiryOrder_fieldlabel:N',5,@cvid;
insert into ld_tabwithproductview(tabid,columns,sequence,cvid)
select @tabid,'ld_purchaseinquiryorder:smownerid:assigned_user_id:PurchaseInquiryOrder_fieldlabel:N',6,@cvid;
insert into ld_tabwithproductview(tabid,columns,sequence,cvid)
select @tabid,'ld_products:productname:productname:Products_fieldlabel:V',7,@cvid;
insert into ld_tabwithproductview(tabid,columns,sequence,cvid)
select @tabid,'ld_inventoryproductrel:quantity:quantity:Products_fieldlabel:N',8,@cvid;
delimiter;

select tabid into @tabid from ld_tab where name='PurchaseInquiryOrder';
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

SELECT tabid into @tabid from ld_tab where name='PurchaseInquiryOrder';
insert into ld_quickactions(tabid,related_tabid,sequence,presence,label)
select @tabid,-5,5,0,'打印工具' from dual where not exists(select 1 from ld_quickactions where tabid=@tabid and related_tabid=-5);
delimiter;

select tabid into @tabid from ld_tab where name='PurchaseInquiryOrder';
select tabid into @related_tabid from ld_tab where name='Quotes';
select max(relation_id) into @maxrelation_id from ld_relatedlists;
insert into ld_relatedlists(relation_id, tabid,related_tabid,name,sequence,label,presence,actions,related_coltable,type)
select @maxrelation_id+1,@tabid,@related_tabid,'get_quotes',1,'Quotes',0,'add','quotes.purchaseinquiryorderid','datacategory_sql' from dual
where not EXISTS(select 1 from ld_relatedlists where tabid=@tabid and related_tabid=@related_tabid and name='get_quotes');
delimiter;

select tabid into @tabid from ld_tab where name='PurchaseInquiryOrder';
select tabid into @related_tabid from ld_tab where name='PurchaseOrder';
select max(relation_id) into @maxrelation_id from ld_relatedlists;
insert into ld_relatedlists(relation_id, tabid,related_tabid,name,sequence,label,presence,actions,related_coltable,type)
select @maxrelation_id+1,@tabid,@related_tabid,'get_purchaseorder',2,'PurchaseOrder',0,'add','inventoryproductrel.entitytypeid','datacategory_sql' from dual
where not EXISTS(select 1 from ld_relatedlists where tabid=@tabid and related_tabid=@related_tabid and name='get_purchaseorder');
delimiter;

select tabid into @tabid from ld_tab where name='PurchaseInquiryOrder';
select tabid into @related_tabid from ld_tab where name='Attachment';
select max(relation_id) into @maxrelation_id from ld_relatedlists;
insert into ld_relatedlists(relation_id, tabid,related_tabid,name,sequence,label,presence,actions,related_coltable,type)
select @maxrelation_id+1,@tabid,@related_tabid,'get_attachment',3,'Attachment',0,'add','attachmentsforbills.related_to','datacategory_sql' from dual
where not EXISTS(select 1 from ld_relatedlists where tabid=@tabid and related_tabid=@related_tabid and name='get_attachment');
delimiter;

select tabid into @tabid from ld_tab where name='PurchaseInquiryOrder';
select max(relation_id) into @maxrelation_id from ld_relatedlists;
insert into ld_relatedlists(relation_id, tabid,related_tabid,name,sequence,label,presence,actions,related_coltable,type)
select @maxrelation_id+1,@tabid,-1,'get_SharedUsers',4,'SharedUsers',0,'share','','' from dual
where not EXISTS(select 1 from ld_relatedlists where tabid=@tabid and related_tabid='-1' and name='get_SharedUsers');
delimiter;

select tabid into @tabid from ld_tab where name='PurchaseInquiryOrder';
select max(relation_id) into @maxrelation_id from ld_relatedlists;
insert into ld_relatedlists(relation_id, tabid,related_tabid,name,sequence,label,presence,actions,related_coltable,type)
select @maxrelation_id+1,@tabid,-7,'get_viewhistory',5,'ViewHistory',0,'','','' from dual
where not EXISTS(select 1 from ld_relatedlists where tabid=@tabid and related_tabid='-7' and name='get_viewhistory');
delimiter;

select tabid into @tabid from ld_tab where name='PurchaseInquiryOrder';
select max(relation_id) into @maxrelation_id from ld_relatedlists;
insert into ld_relatedlists(relation_id, tabid,related_tabid,name,sequence,label,presence,actions,related_coltable,type)
select @maxrelation_id+1,@tabid,-10,'get_changeview',6,'ChangeView',0,'','','' from dual
where not EXISTS(select 1 from ld_relatedlists where tabid=@tabid and related_tabid='-10' and name='get_changeview');
delimiter;

SELECT tabid into @tabid from ld_tab where name='PurchaseInquiryOrder';
insert into ld_def_org_share(tabid,permission,editstatus)
select @tabid,3,0 from DUAL
where not exists(select 1 from ld_def_org_share where tabid = @tabid);
delimiter;

call addtabintoprofile('PurchaseInquiryOrder',1);
delimiter;

select deploy_value,sequence,roottype,presence into @deploy_value,@sequence,@roottype,@presence from ld_systems_deploy where deploy_type = 150;
update ld_systems_deploy set sequence = sequence + 1000 where roottype = @roottype and sequence > @sequence;
insert into ld_systems_deploy(deploy_value,deploy_type,description,setype,sequence,roottype,inputtype,presence,inputvalue)
select @deploy_value,158,'采购询价单是否启用审批流程','PurchaseInquiryOrder',@sequence+1,@roottype,'select',@presence,'[{"value":"0","text":"YES"},{"value":"1","text":"NO"},{"sql":""}]' from dual
where not EXISTS(select 1 from ld_systems_deploy where deploy_type=158);
set @i=0;
update ld_systems_deploy set sequence=(@i:=@i+1) where roottype = @roottype order by sequence;
delimiter;

select tabid into @tabid from ld_tab where `name`='PurchaseInquiryOrder';
set @approvename='采购询价单审批流程';
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

DROP PROCEDURE IF EXISTS `CopyProducttoolfield`;
delimiter ||
CREATE  PROCEDURE `CopyProducttoolfield`(
	IN `copymodule` varchar(100),IN `tomodule` varchar(100)
)
BEGIN
	#Routine body goes here...
declare done  int  default 0;
declare is_producttoolfieldid int;
declare is_columnname  varchar (30);
declare is_allowhide varchar(30);
declare is_fieldlabel varchar (50) ;
declare is_defaultvalue varchar (255) ;
declare is_presence int ;
declare is_uitype varchar (19);
declare is_typeofdata varchar(100);
declare is_sequence int;
declare is_tablename varchar (50) ;
declare is_width int ;
declare is_edit_permission int ;
declare is_input_type int;
declare is_fieldid int;
declare is_newline int;
declare is_defaultcolumn int;
declare is_is_checkimportfield int;
declare is_nullfield int;
declare is_description varchar(255);
DECLARE p_cnt int default 0;

declare cur1 CURSOR FOR select producttoolfieldid,columnname,allowhide,fieldlabel,defaultvalue,presence,uitype,typeofdata,sequence,tablename,width,edit_permission,
input_type,fieldid,newline,defaultcolumn,is_checkimportfield,nullfield,description from ld_producttoolfield where tabid = (select tabid from ld_tab where name = copymodule) and uitype != 200 and uitype != 204;
declare continue handler  for not   found  SET done =1;

select tabid into @to_tabid from ld_tab where `name` = tomodule;
select tabid into @copy_tabid from ld_tab where `name` = copymodule;

OPEN cur1;
Fetch cur1 into is_producttoolfieldid,is_columnname,is_allowhide,is_fieldlabel,is_defaultvalue,is_presence,is_uitype,is_typeofdata,is_sequence,is_tablename,is_width,is_edit_permission,
is_input_type,is_fieldid,is_newline,is_defaultcolumn,is_is_checkimportfield,is_nullfield,is_description;
 loop1: while  done<>1 DO
	select count(1) into p_cnt from ld_producttoolfield where columnname = is_columnname and tabid = @to_tabid;

	if p_cnt = 0 then
		select max(producttoolfieldid) into @producttoolfieldid from ld_producttoolfield;
		set @producttoolfieldid = @producttoolfieldid +1;
		-- 插入is_producttoolfield
			insert into ld_producttoolfield(producttoolfieldid,tabid,columnname,allowhide,fieldlabel,defaultvalue,presence,uitype,typeofdata,sequence,tablename,width,edit_permission,
		input_type,fieldid,newline,defaultcolumn,is_checkimportfield,nullfield,description)
			select @producttoolfieldid,@to_tabid,is_columnname,is_allowhide,is_fieldlabel,is_defaultvalue,is_presence,is_uitype,is_typeofdata,is_sequence,is_tablename,is_width,is_edit_permission,
		is_input_type,is_fieldid,is_newline,is_defaultcolumn,is_is_checkimportfield,is_nullfield,is_description from dual  where not exists(select 1 from ld_producttoolfield where tabid=@to_tabid and columnname = is_columnname);

		-- 分录明细字段公式表
			if is_input_type = 2 THEN
				insert into ld_producttoolfield_formula(producttoolfieldid,formulastring,columnstring,sequence)
				select @producttoolfieldid,formulastring,columnstring,sequence from ld_producttoolfield_formula where producttoolfieldid = is_producttoolfieldid;
			end if;

		-- 中文插入
		select ld_tranlabel.fieldlabel into @fieldlabel from ld_tranlabel where tabid = @copy_tabid and Relateid = is_producttoolfieldid and trantable = 'ld_producttoolfield' and languagetype = 'zh';
		insert into ld_tranlabel(languagetype,trantable,tabid,Relateid,fieldlabel)
		select 'zh','ld_producttoolfield',@to_tabid,@producttoolfieldid,@fieldlabel from dual where not exists(select 1 from ld_tranlabel where tabid = @to_tabid and Relateid = @producttoolfieldid and languagetype = 'zh' and trantable = 'ld_producttoolfield');
		-- 英文插入
		select ld_tranlabel.fieldlabel into @fieldlabel from ld_tranlabel where tabid = @copy_tabid and Relateid = is_producttoolfieldid and trantable = 'ld_producttoolfield' and languagetype = 'en';
		insert into ld_tranlabel(languagetype,trantable,tabid,Relateid,fieldlabel)
		select 'en','ld_producttoolfield',@to_tabid,@producttoolfieldid,@fieldlabel from dual where not exists(select 1 from ld_tranlabel where tabid = @to_tabid and Relateid = @producttoolfieldid and languagetype = 'en' and trantable = 'ld_producttoolfield');
	end if;
Fetch cur1 into is_producttoolfieldid,is_columnname,is_allowhide,is_fieldlabel,is_defaultvalue,is_presence,is_uitype,is_typeofdata,is_sequence,is_tablename,is_width,is_edit_permission,
is_input_type,is_fieldid,is_newline,is_defaultcolumn,is_is_checkimportfield,is_nullfield,is_description;
end while loop1;
close cur1;

update ld_field_seq set id = (select max(fieldid) from ld_field);

end ||
delimiter;

call CopyProducttoolfield('Quotes','PurchaseInquiryOrder');
SELECT tabid into @tabid from ld_tab where name='PurchaseInquiryOrder';
update ld_producttoolfield set tablename = 'ld_purchaseinquiryorder' where tablename = 'ld_quotes' and tabid = @tabid;
delimiter;

select tabid into @tabid from ld_tab where name='Quotes';
select blockid into @blockid  from ld_blocks where tabid=@tabid and blocklabel='LBL_QUOTE_INFORMATION';
select max(fieldid) into @maxfieldid from ld_field;
select max(sequence) into @sequence from ld_field where tabid = @tabid and block = @blockid;
insert into ld_field (tabid ,fieldid,columnname,tablename,generatedtype,uitype,fieldname,fieldlabel,readonly,presence,sequence,block,displaytype,typeofdata,quickcreate,issmownerid)
select @tabid,@maxfieldid+1,'','',1,204,'','选择源单-询价单',1,0,@sequence,@blockid ,1,'V~O',0,1 from dual
where not EXISTS(select 1 from ld_field where tabid=@tabid and uitype = 204);

select tabid into @tabid from ld_tab  where name='Quotes';
select fieldid into @fieldid from ld_field where tabid=@tabid and uitype = 204;
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'zh','ld_field',@tabid, @fieldid,'采购询价单' from dual
where not exists(select 1 from ld_tranlabel where tabid=@tabid and relateid=@fieldid and languagetype='zh'and trantable='ld_field' );
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'en','ld_field',@tabid,@fieldid,'Purchase Inquiry Order' from dual
where not exists(select 1 from ld_tranlabel where tabid=@tabid and relateid=@fieldid and languagetype='en' and trantable='ld_field');
delimiter;

select tabid into @tabid from ld_tab where `name` = 'Quotes';
select max(producttoolfieldid) into @producttoolfieldid from ld_producttoolfield;
select sequence into @sequence from ld_producttoolfield where tabid = @tabid and columnname = 'quantity';
update ld_producttoolfield set sequence = sequence + 1000 where tabid = @tabid and sequence >= @sequence;
insert into ld_producttoolfield(producttoolfieldid,columnname,allowhide,fieldlabel,defaultvalue,presence,uitype,typeofdata,sequence,tabid,tablename,width,edit_permission,
input_type,fieldid,newline,defaultcolumn,is_checkimportfield,nullfield,description)
select @producttoolfieldid+1,'entitytype','no','源单类型','',0,204,'V~O~100',@sequence,@tabid,'ld_inventoryproductrel',22,1,
0,0,0,4,0,1,'' from DUAL where not exists(select 1 from ld_producttoolfield where tabid = @tabid and columnname = 'entitytype');
insert into ld_producttoolfield(producttoolfieldid,columnname,allowhide,fieldlabel,defaultvalue,presence,uitype,typeofdata,sequence,tabid,tablename,width,edit_permission,
input_type,fieldid,newline,defaultcolumn,is_checkimportfield,nullfield,description)
select @producttoolfieldid+2,'entitytypeid','no','源单','',0,200,'V~O~100',@sequence,@tabid,'ld_inventoryproductrel',22,1,
0,0,0,3,0,1,'' from DUAL where not exists(select 1 from ld_producttoolfield where tabid = @tabid and columnname = 'entitytypeid');
set @i=0;
update ld_producttoolfield set sequence=(@i:=@i+1) where tabid = @tabid order by sequence;
delimiter;

select tabid into @tabid from ld_tab where `name` = 'Quotes';
select producttoolfieldid into @producttoolfieldid from ld_producttoolfield where tabid = @tabid and columnname = 'entitytype';
insert into ld_tranlabel(languagetype,trantable,tabid,Relateid,fieldlabel)
select 'zh','ld_producttoolfield',@tabid,@producttoolfieldid,'源单类型' from dual
where not exists(select 1 from ld_tranlabel where tabid = @tabid and Relateid = @producttoolfieldid and languagetype = 'zh' and trantable = 'ld_producttoolfield');
delimiter;

select tabid into @tabid from ld_tab where `name` = 'Quotes';
select producttoolfieldid into @producttoolfieldid from ld_producttoolfield where tabid = @tabid and columnname = 'entitytype';
insert into ld_tranlabel(languagetype,trantable,tabid,Relateid,fieldlabel)
select 'en','ld_producttoolfield',@tabid,@producttoolfieldid,'Source type' from dual
where not exists(select 1 from ld_tranlabel where tabid = @tabid and Relateid = @producttoolfieldid and languagetype = 'en' and trantable = 'ld_producttoolfield');
delimiter;

select tabid into @tabid from ld_tab where `name` = 'Quotes';
select producttoolfieldid into @producttoolfieldid from ld_producttoolfield where tabid = @tabid and columnname = 'entitytypeid';
insert into ld_tranlabel(languagetype,trantable,tabid,Relateid,fieldlabel)
select 'zh','ld_producttoolfield',@tabid,@producttoolfieldid,'源单' from dual
where not exists(select 1 from ld_tranlabel where tabid = @tabid and Relateid = @producttoolfieldid and languagetype = 'zh' and trantable = 'ld_producttoolfield');
delimiter;

select tabid into @tabid from ld_tab where `name` = 'Quotes';
select producttoolfieldid into @producttoolfieldid from ld_producttoolfield where tabid = @tabid and columnname = 'entitytypeid';
insert into ld_tranlabel(languagetype,trantable,tabid,Relateid,fieldlabel)
select 'en','ld_producttoolfield',@tabid,@producttoolfieldid,'Source module' from dual
where not exists(select 1 from ld_tranlabel where tabid = @tabid and Relateid = @producttoolfieldid and languagetype = 'en' and trantable = 'ld_producttoolfield');
delimiter;


select tabid into @tabid from ld_tab where name='Products';
select tabid into @related_tabid from ld_tab where name='PurchaseInquiryOrder';
select sequence into @sequence from ld_relatedlists where tabid = @tabid and `name` = 'get_purchase_orders' and label = 'PurchaseOrder';
update ld_relatedlists set sequence = sequence + 1000 where tabid = @tabid and sequence >= @sequence;
select max(relation_id) into @maxrelation_id from ld_relatedlists;
insert into ld_relatedlists(relation_id, tabid,related_tabid,name,sequence,label,presence,actions,related_coltable,type)
select @maxrelation_id+1,@tabid,@related_tabid,'get_purchaseinquiryorder',@sequence,'PurchaseInquiryOrder',0,'add','inventoryproductrel.productid','datacategory_sql' from dual
where not EXISTS(select 1 from ld_relatedlists where tabid=@tabid and related_tabid=@related_tabid and `name`='get_purchaseinquiryorder');
set @i=0;
update ld_relatedlists set sequence=(@i:=@i+1) where tabid = @tabid order by sequence;
delimiter;

select tabid into @tabid from ld_tab where `name` = 'PurchaseOrder';
select tabid into @sa_tabid from ld_tab where `name` = 'SalesOrder';
select tabid into @pur_tabid from ld_tab where `name` = 'PurchaseInquiryOrder';
select max(table_sequence) into @table_sequence from ld_option_module;
update ld_field set uitype = 202 where uitype = 200;
select fieldid into @fieldid from ld_field where tabid = @tabid and uitype = 202;
update ld_tranlabel set fieldlabel = '选择源单' where tabid = @tabid and Relateid = @fieldid and languagetype = 'zh' and trantable = 'ld_field';
update ld_tranlabel set fieldlabel = 'Select Sourcemodule' where tabid = @tabid and Relateid = @fieldid and languagetype = 'en' and trantable = 'ld_field';
insert into ld_option_module(tabid,option_tabid,presence,`default`,approve_demand,sequence,table_sequence)
select @tabid,@sa_tabid,0,1,0,1,@table_sequence from DUAL
where not exists(select 1 from ld_option_module where tabid = @tabid and option_tabid = @sa_tabid);
insert into ld_option_module(tabid,option_tabid,presence,`default`,approve_demand,sequence,table_sequence)
select @tabid,@pur_tabid,0,0,0,2,@table_sequence from DUAL
where not exists(select 1 from ld_option_module where tabid = @tabid and option_tabid = @pur_tabid);
delimiter;

select tabid into @tabid from ld_tab where `name` = 'PurchaseOrder';
select fieldid into @fieldid from ld_field where tabid = @tabid and uitype = 202;
select fieldid into @eff_fieldid from ld_field where tabid = @tabid and columnname = 'vendorid';
select fieldid into @eff2_fieldid from ld_field where tabid = @tabid and columnname = 'contactid';
insert into ld_related_field(fieldid,fieldtype,trigger_fieldid,effect_fieldid,curmodule_columninfo,fromvalue_type,fromvalue_info)
select '','main',@fieldid,@eff_fieldid,'','column','vendorid' from DUAL
where not exists(select 1 from ld_related_field where trigger_fieldid = @fieldid and effect_fieldid = @eff_fieldid);
insert into ld_related_field(fieldid,fieldtype,trigger_fieldid,effect_fieldid,curmodule_columninfo,fromvalue_type,fromvalue_info)
select '','main',@fieldid,@eff2_fieldid,'','column','contactid' from DUAL
where not exists(select 1 from ld_related_field where trigger_fieldid = @fieldid and effect_fieldid = @eff2_fieldid);
delimiter;

select tabid into @tabid from ld_tab where `name` = 'PurchaseOrder';
select fieldid into @fieldid from ld_field where tabid = @tabid and uitype = 202;
select fieldid into @eff_fieldid from ld_field where tabid = @tabid and columnname = 'vendorid';
select fieldid into @eff2_fieldid from ld_field where tabid = @tabid and columnname = 'contactid';
insert into ld_related_field(fieldid,fieldtype,trigger_fieldid,effect_fieldid,curmodule_columninfo,fromvalue_type,fromvalue_info)
select '','main',@fieldid,@eff_fieldid,'','column','vendorid' from DUAL
where not exists(select 1 from ld_related_field where trigger_fieldid = @fieldid and effect_fieldid = @eff_fieldid);
insert into ld_related_field(fieldid,fieldtype,trigger_fieldid,effect_fieldid,curmodule_columninfo,fromvalue_type,fromvalue_info)
select '','main',@fieldid,@eff2_fieldid,'','column','contactid' from DUAL
where not exists(select 1 from ld_related_field where trigger_fieldid = @fieldid and effect_fieldid = @eff2_fieldid);
delimiter;

select tabid into @tabid from ld_tab where `name` = 'PurchaseInquiryOrder';
update ld_field set approve_demand = 2 where tabid = @tabid;
update ld_field set allowhide = 'no' where tabid = @tabid and columnname not in('vendorid','contactid','approvestatus','approveby','currentapprover');
update ld_field set issmownerid = 0 where tabid = @tabid;
update ld_field set issmownerid = 1 where tabid = @tabid and columnname = 'smownerid';
delimiter;

CREATE TABLE IF NOT EXISTS `ld_purchaseinquiryorder` (
  `purchaseinquiryorderid` int(11) NOT NULL DEFAULT '0',
  `purchaseinquiryorder_no` varchar(100) DEFAULT NULL,
  `vendorid` int(19) DEFAULT NULL,
  `contactid` int(19) DEFAULT NULL,
  `total` decimal(25,6) DEFAULT NULL,
  `subtotal` decimal(25,6) DEFAULT NULL,
  `adjustment` decimal(25,6) DEFAULT NULL,
  `taxtype` varchar(20) DEFAULT NULL,
  `discount_percent` decimal(25,3) NOT NULL DEFAULT '0.000',
  `discount_amount` decimal(25,6) DEFAULT NULL,
  `s_h_amount` decimal(25,3) DEFAULT NULL,
  `currency_id` int(19) DEFAULT '1',
  `conversion_rate` decimal(25,6) DEFAULT NULL,
  `currency_symbol` varchar(30) DEFAULT NULL,
  `approvestatus` varchar(200) DEFAULT '未提交',
  `approveby` int(19) DEFAULT NULL,
  `smownerid` int(11) DEFAULT NULL,
  `smcreatorid` int(11) DEFAULT NULL,
  `modifiedby` int(11) DEFAULT NULL,
  `createdtime` datetime DEFAULT NULL,
  `modifiedtime` datetime DEFAULT NULL,
  `deleted` int(11) DEFAULT '0',
  `description` text,
  `discount_type` int(1) DEFAULT NULL,
  `currentapprover` int(19) DEFAULT NULL,
  `print_times` int(11) DEFAULT '0',
  PRIMARY KEY (`purchaseinquiryorderid`,`discount_percent`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
delimiter;


CREATE TABLE IF NOT EXISTS `ld_purchaseinquiryordercf` (
  `purchaseinquiryorderid` int(11) NOT NULL DEFAULT '0',
  PRIMARY KEY (`purchaseinquiryorderid`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','many','多','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype = 'zh' and labelbol = 'many' and labeltype = 'fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','many','Many','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype = 'en' and labelbol = 'many' and labeltype = 'fixedstr');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','less','少','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype = 'zh' and labelbol = 'less' and labeltype = 'fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','less','Less','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype = 'en' and labelbol = 'less' and labeltype = 'fixedstr');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','CHECKFIELDS','（请勾选需要修改的字段）','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype = 'zh' and labelbol = 'CHECKFIELDS' and labeltype = 'fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','CHECKFIELDS','(Please check the fields that need to be modified)','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype = 'en' and labelbol = 'CHECKFIELDS' and labeltype = 'fixedstr');
delimiter;
-- 2018-01-31

DROP PROCEDURE IF EXISTS `ldcrm_resetfields_20180201`;
delimiter ||
CREATE PROCEDURE `ldcrm_resetfields_20180201`(
)
BEGIN

	IF EXISTS (SELECT 1 FROM ld_version WHERE trade='jiangjing') THEN

		select tabid into @tabid from ld_tab where `name` = 'Users';
		select blockid into @blockid from ld_blocks where tabid=@tabid and blocklabel='LBL_USER_DATAACCESS';
		select max(fieldid) into @maxfieldid from ld_field;
		select sequence into @sequence from ld_field where tabid = @tabid and columnname = 'trackgroupid';
		update ld_field set sequence = sequence + 1000 where tabid = @tabid and block = @blockid and sequence >= @sequence;
		insert into ld_field (tabid ,fieldid,columnname,allowhide,tablename,generatedtype,uitype,fieldname,fieldlabel,readonly,presence,sequence,block,displaytype,typeofdata,quickcreate,masseditable,issmownerid,approve_demand,defaultvalue)
		select @tabid,@maxfieldid+1,'view_quantity','no','ld_users',1,56,'view_quantity','显示具体总库存数量',1,0,@sequence,@blockid ,1,'C~O',1,1,0,2,1 from dual
		where not EXISTS(select 1 from ld_field where tabid=@tabid and columnname = 'view_quantity');

		set @i=0;
		update ld_field set sequence=(@i:=@i+1) where tabid = @tabid and block = @blockid order by sequence;

		select tabid into @tabid from ld_tab where `name` = 'Users';
		select fieldid into @fieldid from ld_field where tabid = @tabid and columnname = 'view_quantity';
		insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
		select 'zh','ld_field',@tabid,@fieldid,'显示具体总库存数量' from dual
		where not exists(select 1 from ld_tranlabel where tabid=@tabid and relateid=@fieldid and languagetype='zh'and trantable='ld_field' );
		insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
		select 'en','ld_field',@tabid,@fieldid,'Display specific total inventory' from dual
		where not exists(select 1 from ld_tranlabel where tabid=@tabid and relateid=@fieldid and languagetype='en' and trantable='ld_field');

		call AddColumn('ld_users','view_quantity','varchar','20',NULL);
		update ld_users set view_quantity = 1 where view_quantity is null;


		insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
		select 'zh','showthetotalinventory','显示具体的产品总库存数量','fixedstr' from dual
		where not exists(select 1 from ld_desk where languagetype = 'zh' and labelbol = 'showthetotalinventory' and labeltype = 'fixedstr');
		insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
		select 'en','showthetotalinventory','show the total inventory of the product','fixedstr' from dual
		where not exists(select 1 from ld_desk where languagetype = 'en' and labelbol = 'showthetotalinventory' and labeltype = 'fixedstr');

	END IF;


end ||
delimiter;

CALL ldcrm_resetfields_20180201();
DROP PROCEDURE IF EXISTS `ldcrm_resetfields_20180201`;
delimiter;
-- 2018-02-01

select tabid into @tabid from ld_tab where `name` = 'PurchaseInquiryOrder';
insert into ld_org_share_action2tab(share_action_id,tabid)
select 0,@tabid from dual where not exists(select 1 from ld_org_share_action2tab where tabid = @tabid and share_action_id = 0);
insert into ld_org_share_action2tab(share_action_id,tabid)
select 1,@tabid from dual where not exists(select 1 from ld_org_share_action2tab where tabid = @tabid and share_action_id = 1);
insert into ld_org_share_action2tab(share_action_id,tabid)
select 2,@tabid from dual where not exists(select 1 from ld_org_share_action2tab where tabid = @tabid and share_action_id = 2);
insert into ld_org_share_action2tab(share_action_id,tabid)
select 3,@tabid from dual where not exists(select 1 from ld_org_share_action2tab where tabid = @tabid and share_action_id = 3);
insert into ld_def_org_share(tabid,permission,editstatus)
select @tabid,3,0 from dual where not exists(select 1 from ld_def_org_share where tabid = @tabid and permission = 3);
delimiter;

SELECT tabid into @tabid from ld_tab where name='PurchaseInquiryOrder';
delete from ld_profileallpermission where tabid = @tabid and operation = 22;
delimiter;

select tabid into @tabid from ld_tab where name='PurchaseInquiryOrder';
select max(blockid) into @maxblockid from ld_blocks;
insert into ld_blocks(blockid,tabid,blocklabel,sequence,show_title,visible,create_view,edit_view,detail_view,display_status,iscustom)
select @maxblockid+1,@tabid,'LBI_ATTACHMENT_FILE',2,0,0,0,0,0,1,0 from dual 
where not exists(select 1 from ld_blocks where blocklabel='LBI_ATTACHMENT_FILE' and tabid=@tabid);
select blockid into @blockid from ld_blocks where blocklabel='LBI_ATTACHMENT_FILE' and tabid=@tabid;
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'zh','ld_blocks',@tabid,@blockid,'附件信息' from dual 
where not exists(select 1 from ld_tranlabel where tabid=@tabid and relateid=@blockid and languagetype='zh' and trantable='ld_blocks');
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'en','ld_blocks',@tabid,@blockid,'Attachment Information' from dual 
where not exists(select 1 from ld_tranlabel where tabid=@tabid and relateid=@blockid and languagetype='en' and trantable='ld_blocks');
delimiter;

select tabid into @tabid from ld_tab where name='PurchaseInquiryOrder';
select blockid into @blockid  from ld_blocks where tabid=@tabid and blocklabel='LBI_ATTACHMENT_FILE';
select max(fieldid) into @maxfieldid from ld_field;
insert into ld_field (tabid ,fieldid,columnname,tablename,generatedtype,uitype,fieldname,fieldlabel,readonly,presence,sequence,block,displaytype,typeofdata,quickcreate,issmownerid)
select @tabid,@maxfieldid+1,'filename','ld_attachments',1,1109,'filename','附件',1,0,1,@blockid ,1,'V~O',0,0 from dual 
where not EXISTS(select 1 from ld_field where tabid=@tabid and columnname='filename');
delimiter;

select tabid into @tabid from ld_tab  where name='PurchaseInquiryOrder';
select fieldid into @fieldid from ld_field where tabid=@tabid and columnname='filename';
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'zh','ld_field',@tabid, @fieldid,'附件' from dual 
where not exists(select 1 from ld_tranlabel where tabid=@tabid and relateid=@fieldid and languagetype='zh'and trantable='ld_field' );
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'en','ld_field',@tabid,@fieldid,'Attachment' from dual 
where not exists(select 1 from ld_tranlabel where tabid=@tabid and relateid=@fieldid and languagetype='en' and trantable='ld_field');
delimiter;

update ld_field_seq set id = (select max(fieldid) from ld_field);
delimiter;

update ld_blocks_seq set id = (select max(blockid) from ld_blocks);
delimiter;

update ld_relatedlists set related_tabid = -11 where `name` = 'get_WorkReport';
delimiter;

select tabid into @tabid from ld_tab where `name` = 'Users';
select blockid into @blockid from ld_blocks where tabid = @tabid and blocklabel = 'LBL_USERLOGIN_ROLE';
update ld_tranlabel set fieldlabel = '成员信息' where tabid = @tabid and Relateid = @blockid and languagetype = 'zh' and trantable = 'ld_blocks';
delimiter;

select tabid into @tabid from ld_tab where `name` = 'HelpDesk';
update ld_field set uitype = 112 where tabid = @tabid and columnname = 'parent_id' and tablename = 'ld_troubletickets';
delimiter;
-- 2018-02-05

call AddColumn('ld_account','bw_id','int','11',0);
delimiter;
call AddColumn('ld_contactdetails','bw_id','int','11',0);
delimiter;
call AddColumn('ld_bangwo8_supportname','supportpwd','varchar','200',NULL);
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','syncaccandcon','同步{$Accounts.Accounts}和{$Contacts.Contacts}','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype = 'zh' and labelbol = 'syncaccandcon' and labeltype = 'fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','syncaccandcon','Synchronizing {$Accounts.Accounts} and {$Contacts.Contacts}','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype = 'en' and labelbol = 'syncaccandcon' and labeltype = 'fixedstr');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','bangwowiththecustomer','帮我吧客服账号','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype = 'zh' and labelbol = 'bangwowiththecustomer' and labeltype = 'fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','bangwowiththecustomer','bangwo8 with the customer service account','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype = 'en' and labelbol = 'bangwowiththecustomer' and labeltype = 'fixedstr');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','thecustomerservicenotexists','帮我吧客服账号不存在！','jspop' from dual
where not exists(select 1 from ld_desk where languagetype = 'zh' and labelbol = 'thecustomerservicenotexists' and labeltype = 'jspop');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','thecustomerservicenotexists','the customer service account number does not exist!','jspop' from dual
where not exists(select 1 from ld_desk where languagetype = 'en' and labelbol = 'thecustomerservicenotexists' and labeltype = 'jspop');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','theaccountnotcorrect','帮我吧账号和密码不正确！','jspop' from dual
where not exists(select 1 from ld_desk where languagetype = 'zh' and labelbol = 'theaccountnotcorrect' and labeltype = 'jspop');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','theaccountnotcorrect','the account number and the password are not correct!','jspop' from dual
where not exists(select 1 from ld_desk where languagetype = 'en' and labelbol = 'theaccountnotcorrect' and labeltype = 'jspop');
delimiter;

update ld_desk set fieldlabel = '是否同步{$Accounts.Accounts}和{$Contacts.Contacts}到帮我吧' where labelbol = 'iscustomer' and languagetype = 'zh' and Labeltype = 'fixedstr';
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','selectdetails','查看明细','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype = 'zh' and labelbol = 'selectdetails' and labeltype = 'fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','selectdetails','Select details','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype = 'en' and labelbol = 'selectdetails' and labeltype = 'fixedstr');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','details1','详情','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype = 'zh' and labelbol = 'details1' and labeltype = 'fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','details1',' details','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype = 'en' and labelbol = 'details1' and labeltype = 'fixedstr');
delimiter;

update ld_blocks set create_view = 0 where tabid = 4 and blocklabel = 'LBL_CUSTOMER_PORTAL_INFORMATION';
delimiter;
update ld_blocks set edit_view = 0 where tabid = 4 and blocklabel = 'LBL_CUSTOMER_PORTAL_INFORMATION';
delimiter;
update ld_blocks set detail_view = 0 where tabid = 4 and blocklabel = 'LBL_CUSTOMER_PORTAL_INFORMATION'; 
delimiter;

call AddColumn("ld_users","usercolor",'varchar',50,'');
delimiter;

DROP TABLE IF EXISTS ld_usercolor;
CREATE TABLE ld_usercolor (
  `id` int(19) NOT NULL AUTO_INCREMENT,
  `color` varchar(100) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=utf8;
delimiter;

INSERT INTO ld_usercolor VALUES ('1', '#ff0256');
INSERT INTO ld_usercolor VALUES ('2', '#6ac2f0');
INSERT INTO ld_usercolor VALUES ('3', '#a7fe6b');
INSERT INTO ld_usercolor VALUES ('4', '#faae0a');
INSERT INTO ld_usercolor VALUES ('5', '#05d136');
INSERT INTO ld_usercolor VALUES ('6', '#e1fa22');
INSERT INTO ld_usercolor VALUES ('7', '#67e4cf');
INSERT INTO ld_usercolor VALUES ('8', '#02fea8');
INSERT INTO ld_usercolor VALUES ('9', '#13ebeb');
INSERT INTO ld_usercolor VALUES ('10', '#c0d009');
INSERT INTO ld_usercolor VALUES ('11', '#a99a7b');
INSERT INTO ld_usercolor VALUES ('12', '#f70adb');
INSERT INTO ld_usercolor VALUES ('13', '#f3971d');
INSERT INTO ld_usercolor VALUES ('14', '#fd6780');
INSERT INTO ld_usercolor VALUES ('15', '#9bb733');
INSERT INTO ld_usercolor VALUES ('16', '#f23a8c');
INSERT INTO ld_usercolor VALUES ('17', '#d5480a');
INSERT INTO ld_usercolor VALUES ('18', '#51c82e');
INSERT INTO ld_usercolor VALUES ('19', '#178dc9');
INSERT INTO ld_usercolor VALUES ('20', '#a28549');
INSERT INTO ld_usercolor VALUES ('21', '#4f9717');
INSERT INTO ld_usercolor VALUES ('22', '#b2bf7b');
INSERT INTO ld_usercolor VALUES ('23', '#d513bb');
INSERT INTO ld_usercolor VALUES ('24', '#ebc522');
INSERT INTO ld_usercolor VALUES ('25', '#51c7b0');
INSERT INTO ld_usercolor VALUES ('26', '#83b85d');
INSERT INTO ld_usercolor VALUES ('27', '#cbe0d6');
INSERT INTO ld_usercolor VALUES ('28', '#6ce2e9');
INSERT INTO ld_usercolor VALUES ('29', '#48cc96');
INSERT INTO ld_usercolor VALUES ('30', '#aedc81');
INSERT INTO ld_usercolor VALUES ('31', '#820b53');
INSERT INTO ld_usercolor VALUES ('32', '#d6fadd');
INSERT INTO ld_usercolor VALUES ('33', '#7be4b6');
INSERT INTO ld_usercolor VALUES ('34', '#c5d1fc');
INSERT INTO ld_usercolor VALUES ('35', '#45b585');
INSERT INTO ld_usercolor VALUES ('36', '#4dd1b4');
INSERT INTO ld_usercolor VALUES ('37', '#6efaba');
INSERT INTO ld_usercolor VALUES ('38', '#2b9cde');
INSERT INTO ld_usercolor VALUES ('39', '#0aa91a');
INSERT INTO ld_usercolor VALUES ('40', '#8d6897');
INSERT INTO ld_usercolor VALUES ('41', '#a989aa');
INSERT INTO ld_usercolor VALUES ('42', '#abc6b7');
INSERT INTO ld_usercolor VALUES ('43', '#d6e959');
INSERT INTO ld_usercolor VALUES ('44', '#e11c58');
INSERT INTO ld_usercolor VALUES ('45', '#b3b5f4');
INSERT INTO ld_usercolor VALUES ('46', '#bad8f5');
INSERT INTO ld_usercolor VALUES ('47', '#9eef7e');
INSERT INTO ld_usercolor VALUES ('48', '#8fde8a');
INSERT INTO ld_usercolor VALUES ('49', '#e51af7');
INSERT INTO ld_usercolor VALUES ('50', '#da145b');
INSERT INTO ld_usercolor VALUES ('51', '#73b872');
INSERT INTO ld_usercolor VALUES ('52', '#d2a38f');
INSERT INTO ld_usercolor VALUES ('53', '#e65809');
INSERT INTO ld_usercolor VALUES ('54', '#9dd15a');
INSERT INTO ld_usercolor VALUES ('55', '#d3d30a');
INSERT INTO ld_usercolor VALUES ('56', '#a85763');
INSERT INTO ld_usercolor VALUES ('57', '#cec709');
INSERT INTO ld_usercolor VALUES ('58', '#edf2b2');
INSERT INTO ld_usercolor VALUES ('59', '#a3d347');
INSERT INTO ld_usercolor VALUES ('60', '#5690c3');
INSERT INTO ld_usercolor VALUES ('61', '#879313');
INSERT INTO ld_usercolor VALUES ('62', '#2bb4d8');
INSERT INTO ld_usercolor VALUES ('63', '#e56783');
INSERT INTO ld_usercolor VALUES ('64', '#b6eaf0');
INSERT INTO ld_usercolor VALUES ('65', '#02a271');
INSERT INTO ld_usercolor VALUES ('66', '#c4431c');
INSERT INTO ld_usercolor VALUES ('67', '#31eed3');
INSERT INTO ld_usercolor VALUES ('68', '#be8c26');
INSERT INTO ld_usercolor VALUES ('69', '#fed7f8');
INSERT INTO ld_usercolor VALUES ('70', '#a48145');
INSERT INTO ld_usercolor VALUES ('71', '#bf24bc');
INSERT INTO ld_usercolor VALUES ('72', '#c11c67');
INSERT INTO ld_usercolor VALUES ('73', '#197eac');
INSERT INTO ld_usercolor VALUES ('74', '#1ac1ba');
INSERT INTO ld_usercolor VALUES ('75', '#22815d');
INSERT INTO ld_usercolor VALUES ('76', '#d73a81');
INSERT INTO ld_usercolor VALUES ('77', '#6ba69f');
INSERT INTO ld_usercolor VALUES ('78', '#bbc484');
INSERT INTO ld_usercolor VALUES ('79', '#7d98d4');
INSERT INTO ld_usercolor VALUES ('80', '#d2f0b3');
INSERT INTO ld_usercolor VALUES ('81', '#caad2e');
INSERT INTO ld_usercolor VALUES ('82', '#1252de');
INSERT INTO ld_usercolor VALUES ('83', '#ea282d');
INSERT INTO ld_usercolor VALUES ('84', '#fc0c83');
INSERT INTO ld_usercolor VALUES ('85', '#5cd858');
INSERT INTO ld_usercolor VALUES ('86', '#e48184');
INSERT INTO ld_usercolor VALUES ('87', '#29ad53');
INSERT INTO ld_usercolor VALUES ('88', '#f271ef');
INSERT INTO ld_usercolor VALUES ('89', '#5aa85b');
INSERT INTO ld_usercolor VALUES ('90', '#ebddaa');
INSERT INTO ld_usercolor VALUES ('91', '#6cf05e');
INSERT INTO ld_usercolor VALUES ('92', '#14a9c2');
INSERT INTO ld_usercolor VALUES ('93', '#c54c1d');
INSERT INTO ld_usercolor VALUES ('94', '#5e4bea');
INSERT INTO ld_usercolor VALUES ('95', '#1161ef');
INSERT INTO ld_usercolor VALUES ('96', '#c9eab4');
INSERT INTO ld_usercolor VALUES ('97', '#7f4750');
INSERT INTO ld_usercolor VALUES ('98', '#de33c4');
INSERT INTO ld_usercolor VALUES ('99', '#fad324');
INSERT INTO ld_usercolor VALUES ('100', '#d4594c');
INSERT INTO ld_usercolor VALUES ('101', '#c76a9f');
INSERT INTO ld_usercolor VALUES ('102', '#0a86fd');
INSERT INTO ld_usercolor VALUES ('103', '#3b6fbe');
INSERT INTO ld_usercolor VALUES ('104', '#acd24d');
INSERT INTO ld_usercolor VALUES ('105', '#c5b94e');
INSERT INTO ld_usercolor VALUES ('106', '#3ec7b6');
INSERT INTO ld_usercolor VALUES ('107', '#c65cf5');
INSERT INTO ld_usercolor VALUES ('108', '#ec6abc');
INSERT INTO ld_usercolor VALUES ('109', '#a9a5b7');
INSERT INTO ld_usercolor VALUES ('110', '#8ab54f');
INSERT INTO ld_usercolor VALUES ('111', '#4baa0b');
INSERT INTO ld_usercolor VALUES ('112', '#679bf7');
INSERT INTO ld_usercolor VALUES ('113', '#76a107');
INSERT INTO ld_usercolor VALUES ('114', '#f59bde');
INSERT INTO ld_usercolor VALUES ('115', '#afc737');
INSERT INTO ld_usercolor VALUES ('116', '#4d9857');
INSERT INTO ld_usercolor VALUES ('117', '#189412');
INSERT INTO ld_usercolor VALUES ('118', '#d39fbe');
INSERT INTO ld_usercolor VALUES ('119', '#2b7466');
INSERT INTO ld_usercolor VALUES ('120', '#6039d9');
INSERT INTO ld_usercolor VALUES ('121', '#8467d8');
INSERT INTO ld_usercolor VALUES ('122', '#dbbc85');
INSERT INTO ld_usercolor VALUES ('123', '#c9ebc9');
INSERT INTO ld_usercolor VALUES ('124', '#99e0d4');
INSERT INTO ld_usercolor VALUES ('125', '#85c413');
INSERT INTO ld_usercolor VALUES ('126', '#c06f46');
INSERT INTO ld_usercolor VALUES ('127', '#94ad67');
INSERT INTO ld_usercolor VALUES ('128', '#e52ca7');
INSERT INTO ld_usercolor VALUES ('129', '#9c790c');
INSERT INTO ld_usercolor VALUES ('130', '#02b585');
INSERT INTO ld_usercolor VALUES ('131', '#40fa70');
INSERT INTO ld_usercolor VALUES ('132', '#9ecc53');
INSERT INTO ld_usercolor VALUES ('133', '#a85702');
INSERT INTO ld_usercolor VALUES ('134', '#3d74f5');
INSERT INTO ld_usercolor VALUES ('135', '#28cb03');
INSERT INTO ld_usercolor VALUES ('136', '#34fd29');
INSERT INTO ld_usercolor VALUES ('137', '#2b82f0');
INSERT INTO ld_usercolor VALUES ('138', '#1ae382');
INSERT INTO ld_usercolor VALUES ('139', '#fdeafa');
INSERT INTO ld_usercolor VALUES ('140', '#6bba68');
INSERT INTO ld_usercolor VALUES ('141', '#c7ceeb');
INSERT INTO ld_usercolor VALUES ('142', '#af14e8');
INSERT INTO ld_usercolor VALUES ('143', '#338d63');
INSERT INTO ld_usercolor VALUES ('144', '#f61a10');
INSERT INTO ld_usercolor VALUES ('145', '#087b96');
INSERT INTO ld_usercolor VALUES ('146', '#b4915a');
INSERT INTO ld_usercolor VALUES ('147', '#a8c771');
INSERT INTO ld_usercolor VALUES ('148', '#c29619');
INSERT INTO ld_usercolor VALUES ('149', '#4033dd');
INSERT INTO ld_usercolor VALUES ('150', '#4bb80b');
INSERT INTO ld_usercolor VALUES ('151', '#04d121');
INSERT INTO ld_usercolor VALUES ('152', '#a90acf');
INSERT INTO ld_usercolor VALUES ('153', '#a4bf45');
INSERT INTO ld_usercolor VALUES ('154', '#26abe5');
INSERT INTO ld_usercolor VALUES ('155', '#a0ad81');
INSERT INTO ld_usercolor VALUES ('156', '#7bab95');
INSERT INTO ld_usercolor VALUES ('157', '#21e9de');
INSERT INTO ld_usercolor VALUES ('158', '#269fe4');
INSERT INTO ld_usercolor VALUES ('159', '#7d3d4c');
INSERT INTO ld_usercolor VALUES ('160', '#d66330');
INSERT INTO ld_usercolor VALUES ('161', '#7922dc');
INSERT INTO ld_usercolor VALUES ('162', '#76f5b0');
INSERT INTO ld_usercolor VALUES ('163', '#9ad56e');
INSERT INTO ld_usercolor VALUES ('164', '#d387fb');
INSERT INTO ld_usercolor VALUES ('165', '#907054');
INSERT INTO ld_usercolor VALUES ('166', '#f194b7');
INSERT INTO ld_usercolor VALUES ('167', '#f03c89');
INSERT INTO ld_usercolor VALUES ('168', '#4d760c');
INSERT INTO ld_usercolor VALUES ('169', '#b911e4');
INSERT INTO ld_usercolor VALUES ('170', '#32d2cd');
INSERT INTO ld_usercolor VALUES ('171', '#3cb71e');
INSERT INTO ld_usercolor VALUES ('172', '#8493ff');
INSERT INTO ld_usercolor VALUES ('173', '#942974');
INSERT INTO ld_usercolor VALUES ('174', '#a3e6e9');
INSERT INTO ld_usercolor VALUES ('175', '#2ab513');
INSERT INTO ld_usercolor VALUES ('176', '#5df702');
INSERT INTO ld_usercolor VALUES ('177', '#f258d4');
INSERT INTO ld_usercolor VALUES ('178', '#a4fedd');
INSERT INTO ld_usercolor VALUES ('179', '#80e33e');
INSERT INTO ld_usercolor VALUES ('180', '#618104');
INSERT INTO ld_usercolor VALUES ('181', '#d6d542');
INSERT INTO ld_usercolor VALUES ('182', '#55855e');
INSERT INTO ld_usercolor VALUES ('183', '#50c686');
INSERT INTO ld_usercolor VALUES ('184', '#b0262a');
INSERT INTO ld_usercolor VALUES ('185', '#9c8199');
INSERT INTO ld_usercolor VALUES ('186', '#ebfd43');
INSERT INTO ld_usercolor VALUES ('187', '#ab2d9f');
INSERT INTO ld_usercolor VALUES ('188', '#866914');
INSERT INTO ld_usercolor VALUES ('189', '#d054bc');
INSERT INTO ld_usercolor VALUES ('190', '#424ab0');
INSERT INTO ld_usercolor VALUES ('191', '#e4a63a');
INSERT INTO ld_usercolor VALUES ('192', '#368f93');
INSERT INTO ld_usercolor VALUES ('193', '#5590cf');
INSERT INTO ld_usercolor VALUES ('194', '#a35374');
INSERT INTO ld_usercolor VALUES ('195', '#1abb9d');
INSERT INTO ld_usercolor VALUES ('196', '#70f4ac');
INSERT INTO ld_usercolor VALUES ('197', '#0994f6');
INSERT INTO ld_usercolor VALUES ('198', '#baaa55');
INSERT INTO ld_usercolor VALUES ('199', '#2e575a');
INSERT INTO ld_usercolor VALUES ('200', '#18dd41');

UPDATE ld_users SET usercolor=(SELECT color FROM ld_usercolor WHERE id=ld_users.id) WHERE id<=200;

DROP PROCEDURE IF EXISTS `ldcrm_restusercolor_20180209`;
delimiter ||
CREATE PROCEDURE `ldcrm_restusercolor_20180209`( 

)
BEGIN 

	DECLARE tmp_id INT(19) DEFAULT 0; 

	DECLARE mycusor CURSOR FOR SELECT id FROM ld_users WHERE id>200;

	DECLARE CONTINUE HANDLER FOR SQLSTATE '02000' SET tmp_id = NULL;

	OPEN mycusor; 
	Fetch mycusor INTO tmp_id;
	WHILE(tmp_id IS NOT NULL) DO
		SET @cid=(SELECT FLOOR(RAND()*200));
		UPDATE ld_users SET usercolor=(SELECT color FROM ld_usercolor WHERE id=@cid LIMIT 1) WHERE id=tmp_id;
		
		Fetch mycusor INTO tmp_id;
	END WHILE;
	CLOSE mycusor;
end ||
delimiter;

CALL ldcrm_restusercolor_20180209();
DROP PROCEDURE IF EXISTS `ldcrm_restusercolor_20180209`;
-- 2018-02-09

alter table ld_potential modify potentialname varchar(120) null;
UPDATE ld_salesorder SET discount_amount=ROUND(discount_amount,2),total=subtotal + adjustment - ROUND(discount_amount,2) WHERE discount_percent>0;
ALTER TABLE ld_salesorder MODIFY COLUMN discount_amount DECIMAL(25,2);

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

update ld_version set old_version='V7.2.9',current_version='V7.2.9',remark='V7.2.9-20180209',wx_version='V7.2.9';
delimiter;