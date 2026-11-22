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

call AddColumn('ld_products','productdate','date','','' );
delimiter;
call AddColumn('ld_warehouse2products','createdtime','datetime','','' );
delimiter;


call AddColumn('ld_products','protectqualitydate','date','','' );
delimiter;
call AddColumn('ld_inventoryproductrel','batchtext','varchar','200','' );
delimiter;
call AddColumn('ld_warehousecondtions','batchtext','varchar','200','' );
delimiter;
call AddColumn('ld_warehouse2products','batchtext','varchar','200','' );
delimiter;

select tabid into @tabid from ld_tab where `name` = 'products';
select max(fieldid) into @max_fieldid from ld_field;
select blockid into @blockid from ld_blocks where blocklabel = 'LBL_PRODUCT_INFORMATION' and tabid = @tabid;
select max(sequence) into @sequence from ld_field where tabid = @tabid and block = @blockid;
insert into ld_field(tabid,fieldid,columnname,allowhide,tablename,generatedtype,uitype,fieldname,fieldlabel,readonly,presence,defaultvalue,maximumlength,
sequence,block,displaytype,typeofdata,quickcreate,quickcreatesequence,info_type,masseditable,helpinfo,fieldonly,issmownerid,searchfieldtype,associatedfields,
associatedsequence,callchecked,duplicatefield,relate_search_parent_columnname,approve_demand,is_checkimportfield)
select @tabid,@max_fieldid+1,'productdate','yes','ld_products',1,5,'productdate','生产日期',0,1,NULL,NULL,
@sequence+1,@blockid,1,'D~O',1,NULL,NULL,2,NULL,0,0,1,0,
0,0,NULL,NULL,2,0 from DUAL
where not exists(select 1 from ld_field where tabid = @tabid and columnname = 'productdate');
set @i=0;
update ld_field set sequence=(@i:=@i+1) where tabid = @tabid order by sequence;
update ld_field_seq set id=@max_fieldid+1;
delimiter;

select tabid into @tabid from ld_tab where `name` = 'products';
select fieldid into @relateid from ld_field where tabid = @tabid and columnname = 'productdate';
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'zh','ld_field',@tabid,@relateid,'生产日期' from DUAL
where not exists(select 1 from ld_tranlabel where tabid = @tabid and relateid = @relateid and languagetype = 'zh' and trantable = 'ld_field');
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'en','ld_field',@tabid,@relateid,'Date of manufacture' from DUAL
where not exists(select 1 from ld_tranlabel where tabid = @tabid and relateid = @relateid and languagetype = 'en' and trantable = 'ld_field');
delimiter;

select tabid into @tabid from ld_tab where `name` = 'products';
select max(fieldid) into @max_fieldid from ld_field;
select blockid into @blockid from ld_blocks where blocklabel = 'LBL_PRODUCT_INFORMATION' and tabid = @tabid;
select max(sequence) into @sequence from ld_field where tabid = @tabid and block = @blockid;
insert into ld_field(tabid,fieldid,columnname,allowhide,tablename,generatedtype,uitype,fieldname,fieldlabel,readonly,presence,defaultvalue,maximumlength,
sequence,block,displaytype,typeofdata,quickcreate,quickcreatesequence,info_type,masseditable,helpinfo,fieldonly,issmownerid,searchfieldtype,associatedfields,
associatedsequence,callchecked,duplicatefield,relate_search_parent_columnname,approve_demand,is_checkimportfield)
select @tabid,@max_fieldid+1,'protectqualitydate','yes','ld_products',1,5,'protectqualitydate','保质期',0,1,NULL,NULL,
@sequence+1,@blockid,1,'D~O',1,NULL,NULL,2,NULL,0,0,1,0,
0,0,NULL,NULL,2,0 from DUAL
where not exists(select 1 from ld_field where tabid = @tabid and columnname = 'protectqualitydate');
set @i=0;
update ld_field set sequence=(@i:=@i+1) where tabid = @tabid order by sequence;

update ld_field_seq set id=@max_fieldid+1;
delimiter;

select tabid into @tabid from ld_tab where `name` = 'products';
select fieldid into @relateid from ld_field where tabid = @tabid and columnname = 'protectqualitydate';
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'zh','ld_field',@tabid,@relateid,'保质期' from DUAL
where not exists(select 1 from ld_tranlabel where tabid = @tabid and relateid = @relateid and languagetype = 'zh' and trantable = 'ld_field');
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'en','ld_field',@tabid,@relateid,'Quality guarantee period' from DUAL
where not exists(select 1 from ld_tranlabel where tabid = @tabid and relateid = @relateid and languagetype = 'en' and trantable = 'ld_field');
delimiter;


select tabid into @tabid from ld_tab where name='stock';
select max(producttoolfieldid) into @maxfieldid from ld_producttoolfield;
select sequence into @sequence from ld_producttoolfield where columnname='productname' and tabid=@tabid LIMIT 1;
update ld_producttoolfield set sequence=sequence+1 where tabid=@tabid and sequence>@sequence;
update ld_producttoolfield_seq set id=@maxfieldid+1 where not exists(select 1 from ld_producttoolfield where tabid=@tabid and columnname='batchtext'); 
insert into ld_producttoolfield(producttoolfieldid, columnname,allowhide,fieldlabel,defaultvalue,presence,uitype,typeofdata,sequence,tabid,tablename,width,edit_permission,input_type,fieldid,newline,defaultcolumn)
select @maxfieldid+1, 'batchtext','yes','批次','',1,729,'V~O',@sequence+1,@tabid ,'ld_inventoryproductrel',22,0,0,0,0,1 from dual 
where not exists(select 1 from ld_producttoolfield where tabid=@tabid and columnname='batchtext');
delimiter;

select tabid into @tabid from ld_tab where name='stock';
select producttoolfieldid into @relateid from ld_producttoolfield where tabid=@tabid and columnname='batchtext';
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'zh','ld_producttoolfield',@tabid,@relateid,'批次' from dual 
where not exists(select 1 from ld_tranlabel   where languagetype='zh' and trantable='ld_producttoolfield' and relateid=@relateid);

 select producttoolfieldid into @realteid from ld_producttoolfield where tabid=@tabid and columnname='batchtext';
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'en','ld_producttoolfield',@tabid,@relateid,'batch' from dual 
where not exists(select 1 from ld_tranlabel   where languagetype='en' and trantable='ld_producttoolfield' and relateid=@relateid);
delimiter;


select tabid into @tabid from ld_tab where name='outboundorder';
select max(producttoolfieldid) into @maxfieldid from ld_producttoolfield;
select sequence into @sequence from ld_producttoolfield where columnname='productname' and tabid=@tabid LIMIT 1;
update ld_producttoolfield set sequence=sequence+1 where tabid=@tabid and sequence>@sequence;
update ld_producttoolfield_seq set id=@maxfieldid+1 where not exists(select 1 from ld_producttoolfield where tabid=@tabid and columnname='batchtext'); 
insert into ld_producttoolfield(producttoolfieldid, columnname,allowhide,fieldlabel,defaultvalue,presence,uitype,typeofdata,sequence,tabid,tablename,width,edit_permission,input_type,fieldid,newline,defaultcolumn)
select @maxfieldid+1, 'batchtext','yes','批次','',1,737,'V~O',@sequence+1,@tabid ,'ld_inventoryproductrel',50,0,0,0,0,1 from dual 
where not exists(select 1 from ld_producttoolfield where tabid=@tabid and columnname='batchtext');
delimiter;

select tabid into @tabid from ld_tab where name='outboundorder';
 select producttoolfieldid into @relateid from ld_producttoolfield where tabid=@tabid and columnname='batchtext';
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'zh','ld_producttoolfield',@tabid,@relateid,'批次' from dual 
where not exists(select 1 from ld_tranlabel   where languagetype='zh' and trantable='ld_producttoolfield' and relateid=@relateid);

select producttoolfieldid into @realteid from ld_producttoolfield where tabid=@tabid and columnname='batchtext';
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'en','ld_producttoolfield',@tabid,@relateid,'batch' from dual 
where not exists(select 1 from ld_tranlabel   where languagetype='en' and trantable='ld_producttoolfield' and relateid=@relateid);
delimiter;


select tabid into @tabid from ld_tab where name='Checks';
select max(producttoolfieldid) into @maxfieldid from ld_producttoolfield;
select sequence into @sequence from ld_producttoolfield where columnname='productname' and tabid=@tabid LIMIT 1;
update ld_producttoolfield set sequence=sequence+1 where tabid=@tabid and sequence>@sequence;
update ld_producttoolfield_seq set id=@maxfieldid+1 where not exists(select 1 from ld_producttoolfield where tabid=@tabid and columnname='batchtext'); 
insert into ld_producttoolfield(producttoolfieldid, columnname,allowhide,fieldlabel,defaultvalue,presence,uitype,typeofdata,sequence,tabid,tablename,width,edit_permission,input_type,fieldid,newline,defaultcolumn)
select @maxfieldid+1, 'batchtext','yes','批次','',1,737,'V~O',@sequence+1,@tabid ,'ld_inventoryproductrel',50,0,0,0,0,1 from dual 
where not exists(select 1 from ld_producttoolfield where tabid=@tabid and columnname='batchtext');
delimiter;

select tabid into @tabid from ld_tab where name='Checks';
 select producttoolfieldid into @relateid from ld_producttoolfield where tabid=@tabid and columnname='batchtext';
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'zh','ld_producttoolfield',@tabid,@relateid,'批次' from dual 
where not exists(select 1 from ld_tranlabel   where languagetype='zh' and trantable='ld_producttoolfield' and relateid=@relateid);

select producttoolfieldid into @realteid from ld_producttoolfield where tabid=@tabid and columnname='batchtext';
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'en','ld_producttoolfield',@tabid,@relateid,'batch' from dual 
where not exists(select 1 from ld_tranlabel   where languagetype='en' and trantable='ld_producttoolfield' and relateid=@relateid);
delimiter;


select tabid into @tabid from ld_tab where name='WareHouseTransfer';
select max(producttoolfieldid) into @maxfieldid from ld_producttoolfield;
select sequence into @sequence from ld_producttoolfield where columnname='productname' and tabid=@tabid LIMIT 1;
update ld_producttoolfield set sequence=sequence+1 where tabid=@tabid and sequence>@sequence;
update ld_producttoolfield_seq set id=@maxfieldid+1 where not exists(select 1 from ld_producttoolfield where tabid=@tabid and columnname='batchtext'); 
insert into ld_producttoolfield(producttoolfieldid, columnname,allowhide,fieldlabel,defaultvalue,presence,uitype,typeofdata,sequence,tabid,tablename,width,edit_permission,input_type,fieldid,newline,defaultcolumn)
select @maxfieldid+1, 'batchtext','yes','批次','',1,737,'V~O',@sequence+1,@tabid ,'ld_inventoryproductrel',50,0,0,0,0,1 from dual 
where not exists(select 1 from ld_producttoolfield where tabid=@tabid and columnname='batchtext');
delimiter;

select tabid into @tabid from ld_tab where name='WareHouseTransfer';
 select producttoolfieldid into @relateid from ld_producttoolfield where tabid=@tabid and columnname='batchtext';
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'zh','ld_producttoolfield',@tabid,@relateid,'批次' from dual 
where not exists(select 1 from ld_tranlabel   where languagetype='zh' and trantable='ld_producttoolfield' and relateid=@relateid);

select producttoolfieldid into @realteid from ld_producttoolfield where tabid=@tabid and columnname='batchtext';
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'en','ld_producttoolfield',@tabid,@relateid,'batch' from dual 
where not exists(select 1 from ld_tranlabel   where languagetype='en' and trantable='ld_producttoolfield' and relateid=@relateid);
delimiter;


insert into ld_desk(fieldlabel,languagetype,labelbol,labeltype)
select '批次','zh','BATCH','fixedstr' from dual 
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='BATCH' and labeltype='fixedstr');

insert into ld_desk(fieldlabel,languagetype,labelbol,labeltype)
select 'Batch','en','BATCH','fixedstr' from dual 
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='BATCH' and labeltype='fixedstr');
delimiter;

insert into ld_desk (languagetype,labelbol,fieldlabel,labeltype)
select 'zh','QUANTITYMORTHANCURRENTROWBATCH','数量大于当前批次号产品数量!','jspop' from dual 
where not exists(select 1 from ld_desk  where languagetype='zh' and labelbol='QUANTITYMORTHANCURRENTROWBATCH' and labeltype='jspop');
insert into ld_desk (languagetype,labelbol,fieldlabel,labeltype)
select 'en','QUANTITYMORTHANCURRENTROWBATCH','数量大于当前批次号产品数量!','jspop' from dual 
where not exists(select 1 from ld_desk  where languagetype='en' and labelbol='QUANTITYMORTHANCURRENTROWBATCH' and labeltype='jspop');
delimiter;


select tabid into @tabid from ld_tab where name='SalesBack';
select max(producttoolfieldid) into @maxfieldid from ld_producttoolfield;
select sequence into @sequence from ld_producttoolfield where columnname='productname' and tabid=@tabid LIMIT 1;
update ld_producttoolfield set sequence=sequence+1 where tabid=@tabid and sequence>@sequence;
update ld_producttoolfield_seq set id=@maxfieldid+1 where not exists(select 1 from ld_producttoolfield where tabid=@tabid and columnname='batchtext'); 
insert into ld_producttoolfield(producttoolfieldid, columnname,allowhide,fieldlabel,defaultvalue,presence,uitype,typeofdata,sequence,tabid,tablename,width,edit_permission,input_type,fieldid,newline,defaultcolumn)
select @maxfieldid+1, 'batchtext','yes','批次','',1,737,'V~O',@sequence+1,@tabid ,'ld_inventoryproductrel',50,0,0,0,0,1 from dual 
where not exists(select 1 from ld_producttoolfield where tabid=@tabid and columnname='batchtext');
delimiter;

select tabid into @tabid from ld_tab where name='SalesBack';
 select producttoolfieldid into @relateid from ld_producttoolfield where tabid=@tabid and columnname='batchtext';
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'zh','ld_producttoolfield',@tabid,@relateid,'批次' from dual 
where not exists(select 1 from ld_tranlabel   where languagetype='zh' and trantable='ld_producttoolfield' and relateid=@relateid);

select producttoolfieldid into @realteid from ld_producttoolfield where tabid=@tabid and columnname='batchtext';
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'en','ld_producttoolfield',@tabid,@relateid,'batch' from dual 
where not exists(select 1 from ld_tranlabel   where languagetype='en' and trantable='ld_producttoolfield' and relateid=@relateid);
delimiter;

select tabid into @tabid from ld_tab where name='PurchaseBack';
select max(producttoolfieldid) into @maxfieldid from ld_producttoolfield;
select sequence into @sequence from ld_producttoolfield where columnname='productname' and tabid=@tabid LIMIT 1;
update ld_producttoolfield set sequence=sequence+1 where tabid=@tabid and sequence>@sequence;
update ld_producttoolfield_seq set id=@maxfieldid+1 where not exists(select 1 from ld_producttoolfield where tabid=@tabid and columnname='batchtext'); 
insert into ld_producttoolfield(producttoolfieldid, columnname,allowhide,fieldlabel,defaultvalue,presence,uitype,typeofdata,sequence,tabid,tablename,width,edit_permission,input_type,fieldid,newline,defaultcolumn)
select @maxfieldid+1, 'batchtext','yes','批次','',1,737,'V~O',@sequence+1,@tabid ,'ld_inventoryproductrel',50,0,0,0,0,1 from dual 
where not exists(select 1 from ld_producttoolfield where tabid=@tabid and columnname='batchtext');
delimiter;

select tabid into @tabid from ld_tab where name='PurchaseBack';
 select producttoolfieldid into @relateid from ld_producttoolfield where tabid=@tabid and columnname='batchtext';
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'zh','ld_producttoolfield',@tabid,@relateid,'批次' from dual 
where not exists(select 1 from ld_tranlabel   where languagetype='zh' and trantable='ld_producttoolfield' and relateid=@relateid);

select producttoolfieldid into @realteid from ld_producttoolfield where tabid=@tabid and columnname='batchtext';
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'en','ld_producttoolfield',@tabid,@relateid,'batch' from dual 
where not exists(select 1 from ld_tranlabel   where languagetype='en' and trantable='ld_producttoolfield' and relateid=@relateid);
delimiter;

select tabid into @tabid from ld_tab where `name` = 'OutboundOrder';
select usereportid into @usereportid from ld_usereport where parent_id=0 and `name` = 'SalesReport';
select Parent_id,sequence,reporttype into @Parent_id,@sequence,@reporttype from ld_usereport where `name` = 'CashBillSum_SalesOrder';
update ld_usereport set sequence = sequence + 1000 where Parent_id = @Parent_id and sequence > @sequence;
insert into ld_usereport(`name`,reportlabel,tabids,basicfilter,advfilter,setcolumns,parent_id,sequence,reporttype,pagewidthpercent,presence,setype)
select 'CashBillSum_Outboundorder','应收款统计表_按{$OutboundOrder}统计',@tabid,1,1,1,@usereportid,@sequence+1,@reporttype,100,0,'OutboundOrder' from DUAL
where not exists(select 1 from ld_usereport where `name` = 'CashBillSum_Outboundorder');
set @i=0;
update ld_usereport set sequence=(@i:=@i+1) where parent_id = @usereportid order by sequence;
delimiter;

insert into ld_desk (languagetype,labelbol,fieldlabel,Labeltype)
select 'zh','CashBillSum_Outboundorder',"应收款统计表_按 {$OutboundOrder.OutboundOrder}统计",'fixedstr' from DUAL
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='CashBillSum_Outboundorder' and Labeltype='fixedstr');
insert into ld_desk (languagetype,labelbol,fieldlabel,Labeltype)
select 'en','CashBillSum_Outboundorder',"Statistics of Receivables Acc To  {$OutboundOrder.OutboundOrder}",'fixedstr' from DUAL
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='CashBillSum_Outboundorder' and Labeltype='fixedstr');
delimiter;

select usereportid into @usereportid from ld_usereport where `name` = 'CashBillSum_Outboundorder';
insert into ld_usereportcolumns(Usereportid,`columns`,Sequence,columnshow,realcolumns,realencolumns)
select @usereportid,'ld_usersOutboundOrder:smownerid:assigned_user_id:OutboundOrder_assigned_user_id:V',1,1,'ld_usersOutboundOrder:smownerid:assigned_user_id:OutboundOrder_销售负责人:V','ld_usersOutboundOrder:smownerid:assigned_user_id:OutboundOrder_Assigned to:V' from DUAL
where not exists(select 1 from ld_usereportcolumns where Usereportid = @usereportid and `columns` = 'ld_usersOutboundOrder:smownerid:assigned_user_id:OutboundOrder_assigned_user_id:V');
insert into ld_usereportcolumns(Usereportid,`columns`,Sequence,columnshow,realcolumns,realencolumns)
select @usereportid,'ld_outboundorder:groupname:groupname:OutboundOrder_groupname:V',2,1,'ld_outboundorder:groupname:groupname:OutboundOrder_部门:V','ld_outboundorder:groupname:groupname:OutboundOrder_Groupname:V' from DUAL
where not exists(select 1 from ld_usereportcolumns where Usereportid = @usereportid and `columns` = 'ld_outboundorder:groupname:groupname:OutboundOrder_groupname:V');
insert into ld_usereportcolumns(Usereportid,`columns`,Sequence,columnshow,realcolumns,realencolumns)
select @usereportid,'ld_outboundorder:out_no:out_no:OutboundOrder_Out no:V',3,1,'ld_outboundorder:out_no:out_no:OutboundOrder_出库编号:V','ld_outboundorder:out_no:out_no:OutboundOrder_Out No:V' from DUAL
where not exists(select 1 from ld_usereportcolumns where Usereportid = @usereportid and `columns` = 'ld_outboundorder:out_no:out_no:OutboundOrder_Out no:V');
insert into ld_usereportcolumns(Usereportid,`columns`,Sequence,columnshow,realcolumns,realencolumns)
select @usereportid,'ld_outboundorder:outdate:outdate:OutboundOrder_outdate:D',4,1,'ld_outboundorder:outdate:outdate:OutboundOrder_出库日期:D','ld_outboundorder:outdate:outdate:OutboundOrder_Outdate:D' from DUAL
where not exists(select 1 from ld_usereportcolumns where Usereportid = @usereportid and `columns` = 'ld_outboundorder:outdate:outdate:OutboundOrder_outdate:D');
insert into ld_usereportcolumns(Usereportid,`columns`,Sequence,columnshow,realcolumns,realencolumns)
select @usereportid,'ld_outboundorder:accountid:account_id:OutboundOrder_Account Name:I',5,1,'ld_outboundorder:accountid:account_id:OutboundOrder_出库_客户名称:I','ld_outboundorder:accountid:account_id:OutboundOrder_AccountName:I' from DUAL
where not exists(select 1 from ld_usereportcolumns where Usereportid = @usereportid and `columns` = 'ld_outboundorder:accountid:account_id:OutboundOrder_Account Name:I');
insert into ld_usereportcolumns(Usereportid,`columns`,Sequence,columnshow,realcolumns,realencolumns)
select @usereportid,'ld_outboundorder:presence:presence:OutboundOrder_Status:V',6,1,'ld_outboundorder:presence:presence:OutboundOrder_出库_出库状态:V','ld_outboundorder:presence:presence:OutboundOrder_Status:V' from DUAL
where not exists(select 1 from ld_usereportcolumns where Usereportid = @usereportid and `columns` = 'ld_outboundorder:presence:presence:OutboundOrder_Status:V');
insert into ld_usereportcolumns(Usereportid,`columns`,Sequence,columnshow,realcolumns,realencolumns)
select @usereportid,'ld_outboundorder:total:hdnGrandTotal:OutboundOrder_Total:N',7,1,'ld_outboundorder:total:hdnGrandTotal:OutboundOrder_合计:N','ld_outboundorder:total:hdnGrandTotal:OutboundOrder_Total:N' from DUAL
where not exists(select 1 from ld_usereportcolumns where Usereportid = @usereportid and `columns` = 'ld_outboundorder:total:hdnGrandTotal:OutboundOrder_Total:N');
insert into ld_usereportcolumns(Usereportid,`columns`,Sequence,columnshow,realcolumns,realencolumns)
select @usereportid,'ld_reporttable:CashBillamount:已收款金额:OftenUseReport_CashBillamount:N',8,1,'ld_reporttable:CashBillamount:已收款金额:OftenUseReport_已收金额:N','ld_reporttable:CashBillamount:已收款金额:OftenUseReport_CashBill Amount:N' from DUAL
where not exists(select 1 from ld_usereportcolumns where Usereportid = @usereportid and `columns` = 'ld_reporttable:CashBillamount:已收款金额:OftenUseReport_CashBillamount:N');
insert into ld_usereportcolumns(Usereportid,`columns`,Sequence,columnshow,realcolumns,realencolumns)
select @usereportid,'ld_reporttable:PaymentBalance:应收款余额:OftenUseReport_PaymentBalance:N',9,1,'ld_reporttable:PaymentBalance:应收款余额:OftenUseReport_应收款余额:N','ld_reporttable:PaymentBalance:应收款余额:OftenUseReport_Payment Balance:N' from DUAL
where not exists(select 1 from ld_usereportcolumns where Usereportid = @usereportid and `columns` = 'ld_reporttable:PaymentBalance:应收款余额:OftenUseReport_PaymentBalance:N');
delimiter;

select usereportid into @usereportid from ld_usereport where `name` = 'CashBillSum_Outboundorder';
insert into ld_usereportbasic(Usereportid,`columns`,Defaultvalue,Sequence)
select @usereportid,'ld_outboundorder:outdate:outdate:OutboundOrder_outdate:D','thisstartmonth~thisendmonth',1 from DUAL
where not exists(select 1 from ld_usereportbasic where Usereportid = @usereportid and `columns` = 'ld_outboundorder:outdate:outdate:OutboundOrder_outdate:D');
insert into ld_usereportbasic(Usereportid,`columns`,Defaultvalue,Sequence)
select @usereportid,'ld_accountoutboundorder:accountname:account_id:OutboundOrder_Account Name:I','',2 from DUAL
where not exists(select 1 from ld_usereportbasic where Usereportid = @usereportid and `columns` = 'ld_accountoutboundorder:accountname:account_id:OutboundOrder_Account Name:I');
delimiter;

DROP PROCEDURE IF EXISTS `ldcrm_addpermission_bytabaction`;
DROP PROCEDURE IF EXISTS `ldcrm_allprofile_bytabaction`;

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


DROP FUNCTION IF EXISTS `getPY`;
delimiter ||
CREATE  FUNCTION `getPY`(in_string text) RETURNS mediumtext CHARSET utf8
BEGIN
	DECLARE tmp_str text charset gbk DEFAULT '' ;
	DECLARE tmp_len SMALLINT DEFAULT 0; 
	DECLARE tmp_char VARCHAR(2) charset gbk DEFAULT '';
	DECLARE tmp_rs text charset gbk DEFAULT '';
	DECLARE tmp_cc VARCHAR(2) charset gbk DEFAULT '';

	SET tmp_str = in_string;
	SET tmp_len = LENGTH(tmp_str);

	WHILE tmp_len > 0 DO 
		SET tmp_char = LEFT(tmp_str,1); 
		SET tmp_cc = tmp_char;
		IF LENGTH(tmp_char)>1 THEN
			SELECT ELT(INTERVAL(CONV(HEX(tmp_char),16,10),0xB0A1,0xB0C5,0xB2C1,0xB4EE,0xB6EA,0xB7A2,0xB8C1,0xB9FE,0xBBF7,0xBFA6,0xC0AC
			,0xC2E8,0xC4C3,0xC5B6,0xC5BE,0xC6DA,0xC8BB,0xC8F6,0xCBFA,0xCDDA ,0xCEF4,0xD1B9,0xD4D1), 
			'A','B','C','D','E','F','G','H','J','K','L','M','N','O','P','Q','R','S','T','W','X','Y','Z') INTO tmp_cc;
		END IF; 
		SET tmp_rs = CONCAT(tmp_rs,tmp_cc);
		SET tmp_str = SUBSTRING(tmp_str,2);
		SET tmp_len = LENGTH(tmp_str);
	END WHILE; 
	RETURN tmp_rs;
END ||
delimiter;


DROP PROCEDURE IF EXISTS `ldcrm_addnewmoudule`;
delimiter ||
CREATE  PROCEDURE `ldcrm_addnewmoudule`(
	tmp_moduletype VARCHAR(100),
	tmp_modulename VARCHAR(100),
	tmp_zhmoudulename VARCHAR(100),
	tmp_enmoudulename VARCHAR(100),
	tmp_parenttabid INT(19),
	tmp_deploy_type INT(19)
)
BEGIN

	IF tmp_moduletype='basic' THEN
		INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,Labeltype)
		SELECT 'zh','CUSTOMFORMBASIC','自定义表单，没有单据分录','fixedstr' FROM DUAL
		WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE labelbol='CUSTOMFORMBASIC' AND languagetype='zh' AND Labeltype='fixedstr');

		INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,Labeltype)
		SELECT 'en','CUSTOMFORMBASIC','Custom form without entry','fixedstr' FROM DUAL
		WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE labelbol='CUSTOMFORMBASIC' AND languagetype='en' AND Labeltype='fixedstr');

		SET @maxtabid=(SELECT MAX(tabid) FROM ld_tab);
		SET @maxtseq=(SELECT MAX(tabsequence) FROM ld_tab);
		INSERT INTO ld_tab(tabid,`name`,presence,tabsequence,tablabel,printtab,description)
		SELECT @maxtabid+1,tmp_modulename,5,@maxtseq+1,tmp_modulename,1,'CUSTOMFORMBASIC' FROM DUAL
		WHERE NOT EXISTS (SELECT 1 FROM ld_tab WHERE `name`=tmp_modulename);

		SET @tabid=(SELECT tabid FROM ld_tab WHERE `name`=tmp_modulename);
		INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
		SELECT 'zh','ld_tab',@tabid,@tabid,tmp_zhmoudulename FROM DUAL
		WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE tabid=@tabid AND relateid=@tabid AND languagetype='zh' AND trantable='ld_tab');
		INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
		SELECT 'en','ld_tab',@tabid,@tabid,tmp_enmoudulename FROM DUAL
		WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE tabid=@tabid AND relateid=@tabid AND languagetype='en' AND trantable='ld_tab');

		SET @labseq=IFNULL((SELECT MAX(sequence) FROM ld_parenttabrel WHERE parenttabid=tmp_parenttabid),0);
		INSERT INTO ld_parenttabrel(parenttabid,tabid,sequence)
		SELECT tmp_parenttabid,@tabid,@labseq+1 FROM DUAL
		WHERE NOT EXISTS (SELECT 1 FROM ld_parenttabrel WHERE parenttabid=tmp_parenttabid AND tabid=@tabid);

		SET @maxnum_id=(SELECT MAX(num_id) FROM ld_modentity_num);
		INSERT INTO ld_modentity_num(num_id,semodule,prefix,start_id,cur_id,active,datetype,useuseraccount,isallow,prefixtype)
		SELECT @maxnum_id+1,tmp_modulename,getPY(tmp_zhmoudulename),1,1,1,'none',0,1,0 FROM DUAL
		WHERE NOT EXISTS(SELECT 1 FROM ld_modentity_num WHERE semodule=tmp_modulename);
		UPDATE ld_modentity_num_seq SET id=@maxnum_id+1;

		INSERT INTO ld_modtracker_tabs(tabid,visible) 
		SELECT @tabid,1 FROM DUAL 
		WHERE NOT EXISTS (SELECT 1 FROM ld_modtracker_tabs WHERE tabid=@tabid);

		SET @i=0;
		INSERT INTO ld_profileallpermission(tabid,operation,sequence) 
		SELECT @tabid,actionid,(@i:=@i+1) FROM ld_actionmapping 
		WHERE NOT EXISTS (SELECT 1 FROM ld_profileallpermission WHERE tabid=@tabid) AND actionname IN 
			('index','Detailview','Create','EditView','Delete','Copy','Allocate','Share','Import','Export','ChangeCreator','CustomView');

		INSERT INTO ld_entityname(tabid ,modulename,tablename,fieldname,entityidfield,entityidcolumn)
		SELECT @tabid,tmp_modulename,CONCAT('ld_',LOWER(tmp_modulename)),CONCAT(LOWER(tmp_modulename),'_no'),CONCAT(LOWER(tmp_modulename),'id'),CONCAT(LOWER(tmp_modulename),'id') FROM DUAl
		WHERE NOT EXISTS (SELECT 1 FROM ld_entityname WHERE tabid=@tabid AND modulename=tmp_modulename);


		SET @maxblockid=(SELECT MAX(blockid) FROM ld_blocks);
		INSERT INTO ld_blocks(blockid,tabid,blocklabel,sequence,show_title,visible,create_view,edit_view,detail_view,display_status,iscustom)
		SELECT @maxblockid+1,@tabid,CONCAT('LBL_',UPPER(tmp_modulename),'_BASICINFORMATION'),1,0,0,0,0,0,1,0 FROM DUAL
		WHERE NOT EXISTS (SELECT 1 FROM ld_blocks WHERE blocklabel=CONCAT('LBL_',UPPER(tmp_modulename),'_BASICINFORMATION') AND tabid=@tabid);

		SET @blockid=(SELECT blockid FROM ld_blocks WHERE blocklabel=CONCAT('LBL_',UPPER(tmp_modulename),'_BASICINFORMATION') AND tabid=@tabid);
		INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
		SELECT 'zh','ld_blocks',@tabid,@blockid,'基本信息' FROM DUAL
		WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE tabid=@tabid AND relateid=@blockid AND languagetype='zh' and trantable='ld_blocks');	
		INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
		SELECT 'en','ld_blocks',@tabid,@blockid,'Basic Information' FROM DUAL
		WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE tabid=@tabid AND relateid=@blockid AND languagetype='en' and trantable='ld_blocks');
		UPDATE ld_blocks_seq SET id=(SELECT MAX(blockid) FROM ld_blocks);


		SET @i=IFNULL((SELECT MAX(sequence) FROM ld_field WHERE block=@blockid),0);
	  SET @maxfieldid=(SELECT MAX(fieldid) from ld_field);
		INSERT INTO ld_field (tabid,fieldid,columnname,allowhide,tablename,generatedtype,uitype,fieldname,fieldlabel,readonly,presence,sequence,block,displaytype,typeofdata,quickcreate,issmownerid,masseditable,approve_demand)
		SELECT @tabid,@maxfieldid+1,CONCAT(LOWER(tmp_modulename),'_no'),'no',CONCAT('ld_',LOWER(tmp_modulename)),1,4,CONCAT(LOWER(tmp_modulename),'_no'),'单据编号',1,0,(@i:=@i+1),@blockid ,1,'V~M',1,0,0,2 FROM DUAL
		WHERE NOT EXISTS (SELECT 1 FROM ld_field WHERE tabid=@tabid AND columnname=CONCAT(LOWER(tmp_modulename),'_no'));

		SET @fieldid=(SELECT fieldid FROM ld_field WHERE tabid=@tabid AND columnname=CONCAT(LOWER(tmp_modulename),'_no'));
		INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
		SELECT 'zh','ld_field',@tabid, @fieldid,'单据编号' FROM DUAL
		WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE tabid=@tabid AND relateid=@fieldid AND languagetype='zh' AND trantable='ld_field' );
		INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
		SELECT 'en','ld_field',@tabid, @fieldid,'Bill NO.' FROM DUAL
		WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE tabid=@tabid AND relateid=@fieldid AND languagetype='en' AND trantable='ld_field' );


		SET @maxfieldid=(SELECT MAX(fieldid) from ld_field);
		INSERT INTO ld_field (tabid,fieldid,columnname,allowhide,tablename,generatedtype,uitype,fieldname,fieldlabel,readonly,presence,sequence,block,displaytype,typeofdata,quickcreate,issmownerid,masseditable,approve_demand)
		SELECT @tabid,@maxfieldid+1,'smownerid','no',CONCAT('ld_',LOWER(tmp_modulename)),1,53,'assigned_user_id','负责人',1,0,(@i:=@i+1),@blockid ,1,'V~M',1,1,1,2 FROM DUAL
		WHERE NOT EXISTS (SELECT 1 FROM ld_field WHERE tabid=@tabid AND columnname='smownerid');

		SET @fieldid=(SELECT fieldid FROM ld_field WHERE tabid=@tabid AND columnname='smownerid');
		INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
		SELECT 'zh','ld_field',@tabid, @fieldid,'负责人' FROM DUAL
		WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE tabid=@tabid AND relateid=@fieldid AND languagetype='zh' AND trantable='ld_field' );
		INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
		SELECT 'en','ld_field',@tabid, @fieldid,'Assigned To' FROM DUAL
		WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE tabid=@tabid AND relateid=@fieldid AND languagetype='en' AND trantable='ld_field' );


		SET @maxfieldid=(SELECT MAX(fieldid) from ld_field);
		INSERT INTO ld_field (tabid,fieldid,columnname,allowhide,tablename,generatedtype,uitype,fieldname,fieldlabel,readonly,presence,sequence,block,displaytype,typeofdata,quickcreate,issmownerid,masseditable,approve_demand)
		SELECT @tabid,@maxfieldid+1,'smcreatorid','yes',CONCAT('ld_',LOWER(tmp_modulename)),1,52,'smcreatorid','创建人',1,0,(@i:=@i+1),@blockid ,2,'V~O',1,0,1,2 FROM DUAL
		WHERE NOT EXISTS (SELECT 1 FROM ld_field WHERE tabid=@tabid AND columnname='smcreatorid');

		SET @fieldid=(SELECT fieldid FROM ld_field WHERE tabid=@tabid AND columnname='smcreatorid');
		INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
		SELECT 'zh','ld_field',@tabid, @fieldid,'创建人' FROM DUAL
		WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE tabid=@tabid AND relateid=@fieldid AND languagetype='zh' AND trantable='ld_field' );
		INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
		SELECT 'en','ld_field',@tabid, @fieldid,'Creator' FROM DUAL
		WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE tabid=@tabid AND relateid=@fieldid AND languagetype='en' AND trantable='ld_field' );


		SET @maxfieldid=(SELECT MAX(fieldid) from ld_field);
		INSERT INTO ld_field (tabid,fieldid,columnname,allowhide,tablename,generatedtype,uitype,fieldname,fieldlabel,readonly,presence,sequence,block,displaytype,typeofdata,quickcreate,issmownerid,masseditable,approve_demand)
		SELECT @tabid,@maxfieldid+1,'createdtime','yes',CONCAT('ld_',LOWER(tmp_modulename)),1,70,'createdtime','创建时间',1,0,(@i:=@i+1),@blockid ,2,'DT~O',1,0,1,2 FROM DUAL
		WHERE NOT EXISTS (SELECT 1 FROM ld_field WHERE tabid=@tabid AND columnname='createdtime');

		SET @fieldid=(SELECT fieldid FROM ld_field WHERE tabid=@tabid AND columnname='createdtime');
		INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
		SELECT 'zh','ld_field',@tabid, @fieldid,'创建时间' FROM DUAL
		WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE tabid=@tabid AND relateid=@fieldid AND languagetype='zh' AND trantable='ld_field' );
		INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
		SELECT 'en','ld_field',@tabid, @fieldid,'Created Time' FROM DUAL
		WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE tabid=@tabid AND relateid=@fieldid AND languagetype='en' AND trantable='ld_field' );


		SET @maxfieldid=(SELECT MAX(fieldid) from ld_field);
		INSERT INTO ld_field (tabid,fieldid,columnname,allowhide,tablename,generatedtype,uitype,fieldname,fieldlabel,readonly,presence,sequence,block,displaytype,typeofdata,quickcreate,issmownerid,masseditable,approve_demand)
		SELECT @tabid,@maxfieldid+1,'modifiedby','yes',CONCAT('ld_',LOWER(tmp_modulename)),1,52,'modifiedby','最新更新人',1,0,(@i:=@i+1),@blockid ,2,'V~O',1,0,1,2 FROM DUAL
		WHERE NOT EXISTS (SELECT 1 FROM ld_field WHERE tabid=@tabid AND columnname='modifiedby');
		
		SET @fieldid=(SELECT fieldid FROM ld_field WHERE tabid=@tabid AND columnname='modifiedby');
		INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
		SELECT 'zh','ld_field',@tabid, @fieldid,'最新更新人' FROM DUAL
		WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE tabid=@tabid AND relateid=@fieldid AND languagetype='zh' AND trantable='ld_field' );
		INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
		SELECT 'en','ld_field',@tabid, @fieldid,'Modified By' FROM DUAL
		WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE tabid=@tabid AND relateid=@fieldid AND languagetype='en' AND trantable='ld_field' );


		SET @maxfieldid=(SELECT MAX(fieldid) from ld_field);
		INSERT INTO ld_field (tabid,fieldid,columnname,allowhide,tablename,generatedtype,uitype,fieldname,fieldlabel,readonly,presence,sequence,block,displaytype,typeofdata,quickcreate,issmownerid,masseditable,approve_demand)
		SELECT @tabid,@maxfieldid+1,'modifiedtime','yes',CONCAT('ld_',LOWER(tmp_modulename)),1,70,'modifiedtime','更新时间',1,0,(@i:=@i+1),@blockid ,2,'DT~O',1,0,1,2 FROM DUAL
		WHERE NOT EXISTS (SELECT 1 FROM ld_field WHERE tabid=@tabid AND columnname='modifiedtime');

		SET @fieldid=(SELECT fieldid FROM ld_field WHERE tabid=@tabid AND columnname='modifiedtime');
		INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
		SELECT 'zh','ld_field',@tabid, @fieldid,'更新时间' FROM DUAL
		WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE tabid=@tabid AND relateid=@fieldid AND languagetype='zh' AND trantable='ld_field' );
		INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
		SELECT 'en','ld_field',@tabid, @fieldid,'Modified Time' FROM DUAL
		WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE tabid=@tabid AND relateid=@fieldid AND languagetype='en' AND trantable='ld_field' );


		SET @maxfieldid=(SELECT MAX(fieldid) from ld_field);
		INSERT INTO ld_field (tabid,fieldid,columnname,allowhide,tablename,generatedtype,uitype,fieldname,fieldlabel,readonly,presence,sequence,block,displaytype,typeofdata,quickcreate,issmownerid,masseditable,approve_demand)
		SELECT @tabid,@maxfieldid+1,'approvestatus','yes',CONCAT('ld_',LOWER(tmp_modulename)),1,609,'approvestatus','审批状态',1,0,(@i:=@i+1),@blockid ,2,'V~O',1,0,1,2 FROM DUAL
		WHERE NOT EXISTS (SELECT 1 FROM ld_field WHERE tabid=@tabid AND columnname='approvestatus');

		SET @fieldid=(SELECT fieldid FROM ld_field WHERE tabid=@tabid AND columnname='approvestatus');
		INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
		SELECT 'zh','ld_field',@tabid, @fieldid,'审批状态' FROM DUAL
		WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE tabid=@tabid AND relateid=@fieldid AND languagetype='zh' AND trantable='ld_field' );
		INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
		SELECT 'en','ld_field',@tabid, @fieldid,'Approve Status' FROM DUAL
		WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE tabid=@tabid AND relateid=@fieldid AND languagetype='en' AND trantable='ld_field' );


		SET @maxfieldid=(SELECT MAX(fieldid) from ld_field);
		INSERT INTO ld_field (tabid,fieldid,columnname,allowhide,tablename,generatedtype,uitype,fieldname,fieldlabel,readonly,presence,sequence,block,displaytype,typeofdata,quickcreate,issmownerid,masseditable,approve_demand)
		SELECT @tabid,@maxfieldid+1,'approvetime','yes',CONCAT('ld_',LOWER(tmp_modulename)),1,70,'approvetime','最新审批时间',1,0,(@i:=@i+1),@blockid ,2,'DT~O',1,0,1,2 FROM DUAL
		WHERE NOT EXISTS (SELECT 1 FROM ld_field WHERE tabid=@tabid AND columnname='approvetime');

		SET @fieldid=(SELECT fieldid FROM ld_field WHERE tabid=@tabid AND columnname='approvetime');
		INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
		SELECT 'zh','ld_field',@tabid, @fieldid,'最新审批时间' FROM DUAL
		WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE tabid=@tabid AND relateid=@fieldid AND languagetype='zh' AND trantable='ld_field' );
		INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
		SELECT 'en','ld_field',@tabid, @fieldid,'Last Approval Time' FROM DUAL
		WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE tabid=@tabid AND relateid=@fieldid AND languagetype='en' AND trantable='ld_field' );


		SET @maxfieldid=(SELECT MAX(fieldid) from ld_field);
		INSERT INTO ld_field (tabid,fieldid,columnname,allowhide,tablename,generatedtype,uitype,fieldname,fieldlabel,readonly,presence,sequence,block,displaytype,typeofdata,quickcreate,issmownerid,masseditable,approve_demand)
		SELECT @tabid,@maxfieldid+1,'approveby','yes',CONCAT('ld_',LOWER(tmp_modulename)),1,131,'approveby','上一步审批人',1,0,(@i:=@i+1),@blockid ,2,'V~O',1,0,1,2 FROM DUAL
		WHERE NOT EXISTS (SELECT 1 FROM ld_field WHERE tabid=@tabid AND columnname='approveby');

		SET @fieldid=(SELECT fieldid FROM ld_field WHERE tabid=@tabid AND columnname='approveby');
		INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
		SELECT 'zh','ld_field',@tabid, @fieldid,'上一步审批人' FROM DUAL
		WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE tabid=@tabid AND relateid=@fieldid AND languagetype='zh' AND trantable='ld_field' );
		INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
		SELECT 'en','ld_field',@tabid, @fieldid,'The Last Approver' FROM DUAL
		WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE tabid=@tabid AND relateid=@fieldid AND languagetype='en' AND trantable='ld_field' );


		SET @maxfieldid=(SELECT MAX(fieldid) from ld_field);
		INSERT INTO ld_field (tabid,fieldid,columnname,allowhide,tablename,generatedtype,uitype,fieldname,fieldlabel,readonly,presence,sequence,block,displaytype,typeofdata,quickcreate,issmownerid,masseditable,approve_demand)
		SELECT @tabid,@maxfieldid+1,'currentapprover','yes',CONCAT('ld_',LOWER(tmp_modulename)),1,132,'currentapprover','当前审批人',1,0,(@i:=@i+1),@blockid ,2,'V~O',1,0,1,2 FROM DUAL
		WHERE NOT EXISTS (SELECT 1 FROM ld_field WHERE tabid=@tabid AND columnname='currentapprover');
		
		SET @fieldid=(SELECT fieldid FROM ld_field WHERE tabid=@tabid AND columnname='currentapprover');
		INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
		SELECT 'zh','ld_field',@tabid, @fieldid,'当前审批人' FROM DUAL
		WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE tabid=@tabid AND relateid=@fieldid AND languagetype='zh' AND trantable='ld_field' );
		INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
		SELECT 'en','ld_field',@tabid, @fieldid,'Current Approver' FROM DUAL
		WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE tabid=@tabid AND relateid=@fieldid AND languagetype='en' AND trantable='ld_field' );
		UPDATE ld_field_seq SET id=(SELECT MAX(fieldid) FROM ld_field);

		SET @maxfieldid=(SELECT MAX(fieldid) from ld_field);
		INSERT INTO ld_field (tabid,fieldid,columnname,allowhide,tablename,generatedtype,uitype,fieldname,fieldlabel,readonly,presence,sequence,block,displaytype,typeofdata,quickcreate,issmownerid,masseditable,approve_demand)
		SELECT @tabid,@maxfieldid+1,'print_times','yes',CONCAT('ld_',LOWER(tmp_modulename)),1,1,'print_times','打印次数',1,1,(@i:=@i+1),@blockid ,2,'N~O',1,0,1,2 FROM DUAL
		WHERE NOT EXISTS (SELECT 1 FROM ld_field WHERE tabid=@tabid AND columnname='print_times');
		
		SET @fieldid=(SELECT fieldid FROM ld_field WHERE tabid=@tabid AND columnname='print_times');
		INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
		SELECT 'zh','ld_field',@tabid, @fieldid,'打印次数' FROM DUAL
		WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE tabid=@tabid AND relateid=@fieldid AND languagetype='zh' AND trantable='ld_field' );
		INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
		SELECT 'en','ld_field',@tabid, @fieldid,'Print Times' FROM DUAL
		WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE tabid=@tabid AND relateid=@fieldid AND languagetype='en' AND trantable='ld_field' );
		UPDATE ld_field_seq SET id=(SELECT MAX(fieldid) FROM ld_field);

		CALL getallprofile(tmp_modulename);
		CALL fieldprofile(tmp_modulename);


		SELECT MAX(cvid) INTO @maxcvid  FROM ld_customview;
		INSERT INTO ld_customview (cvid,viewname,setdefault,setmetrics,entitytype,status,userid,sequence)
		SELECT @maxcvid+1,'All',1,0,tmp_modulename,3,1,1 FROM dual
		WHERE NOT EXISTS (SELECT 1 FROM ld_customview where entitytype=tmp_modulename and viewname='All');

		INSERT INTO ld_customview (cvid,viewname,setdefault,setmetrics,entitytype,status,userid,sequence)
		SELECT @maxcvid+2,'已批准',0,0,tmp_modulename,3,1,2 FROM dual
		WHERE NOT EXISTS (SELECT 1 FROM ld_customview where entitytype=tmp_modulename and viewname='已批准');

		INSERT INTO ld_customview (cvid,viewname,setdefault,setmetrics,entitytype,status,userid,sequence)
		SELECT @maxcvid+3,'审批中',0,0,tmp_modulename,3,1,3 FROM dual
		WHERE NOT EXISTS (SELECT 1 FROM ld_customview where entitytype=tmp_modulename and viewname='审批中');

		INSERT INTO ld_customview (cvid,viewname,setdefault,setmetrics,entitytype,status,userid,sequence)
		SELECT @maxcvid+4,'未提交',0,0,tmp_modulename,3,1,4 FROM dual
		WHERE NOT EXISTS (SELECT 1 FROM ld_customview where entitytype=tmp_modulename and viewname='未提交');

		INSERT INTO ld_customview (cvid,viewname,setdefault,setmetrics,entitytype,status,userid,sequence)
		SELECT @maxcvid+5,'已驳回',0,0,tmp_modulename,3,1,5 FROM dual
		WHERE NOT EXISTS (SELECT 1 FROM ld_customview where entitytype=tmp_modulename and viewname='已驳回');

		INSERT INTO ld_customview (cvid,viewname,setdefault,setmetrics,entitytype,status,userid,sequence)
		SELECT @maxcvid+6,'已拒绝',0,0,tmp_modulename,3,1,6 FROM dual
		WHERE NOT EXISTS (SELECT 1 FROM ld_customview where entitytype=tmp_modulename and viewname='已拒绝');

		UPDATE ld_customview_seq SET id=(SELECT MAX(cvid) FROM ld_customview);

		
		SET @cvid=(SELECT cvid FROM ld_customview WHERE entitytype=tmp_modulename AND viewname='All');
		DELETE FROM ld_cvadvfilter WHERE cvid=@cvid;
		DELETE FROM ld_cvadvfilter_grouping WHERE cvid=@cvid;
		DELETE FROM ld_cvcolumnlist WHERE cvid=@cvid;

		INSERT INTO ld_cvcolumnlist(cvid,columnindex,columnname)
		SELECT @cvid,0,CONCAT('ld_',LOWER(tmp_modulename),':',LOWER(tmp_modulename),'_no',':',LOWER(tmp_modulename),'_no',':',tmp_modulename,'_fieldlabel:V');
		INSERT INTO ld_cvcolumnlist(cvid,columnindex,columnname)
		SELECT @cvid,1,CONCAT('ld_',LOWER(tmp_modulename),':','smownerid',':','assigned_user_id',':',tmp_modulename,'_fieldlabel:V');
		INSERT INTO ld_cvcolumnlist(cvid,columnindex,columnname)
		SELECT @cvid,2,CONCAT('ld_',LOWER(tmp_modulename),':','approvestatus',':','approvestatus',':',tmp_modulename,'_fieldlabel:V');
		INSERT INTO ld_cvcolumnlist(cvid,columnindex,columnname)
		SELECT @cvid,3,CONCAT('ld_',LOWER(tmp_modulename),':','smcreatorid',':','smcreatorid',':',tmp_modulename,'_fieldlabel:V');
		INSERT INTO ld_cvcolumnlist(cvid,columnindex,columnname)
		SELECT @cvid,4,CONCAT('ld_',LOWER(tmp_modulename),':','createdtime',':','createdtime',':',tmp_modulename,'_fieldlabel:DT');


		SET @cvid=(SELECT cvid FROM ld_customview WHERE entitytype=tmp_modulename AND viewname='已批准');
		DELETE FROM ld_cvadvfilter WHERE cvid=@cvid;
		DELETE FROM ld_cvadvfilter_grouping WHERE cvid=@cvid;
		DELETE FROM ld_cvcolumnlist WHERE cvid=@cvid;

		INSERT INTO ld_cvadvfilter(cvid,columnindex,columnname,comparator,value,groupid,column_condition)
		SELECT @cvid,0,CONCAT('ld_',LOWER(tmp_modulename),':','approvestatus',':','approvestatus',':',tmp_modulename,'_fieldlabel:V'),'e','已批准',1,'';

		INSERT INTO ld_cvadvfilter_grouping(groupid,cvid,condition_expression)
		SELECT 1,@cvid,0;

		INSERT INTO ld_cvcolumnlist(cvid,columnindex,columnname)
		SELECT @cvid,columnindex,columnname FROM ld_cvcolumnlist 
		WHERE cvid=(SELECT cvid FROM ld_customview WHERE entitytype=tmp_modulename AND viewname='All');


		SET @cvid=(SELECT cvid FROM ld_customview WHERE entitytype=tmp_modulename AND viewname='审批中');
		DELETE FROM ld_cvadvfilter WHERE cvid=@cvid;
		DELETE FROM ld_cvadvfilter_grouping WHERE cvid=@cvid;
		DELETE FROM ld_cvcolumnlist WHERE cvid=@cvid;

		INSERT INTO ld_cvadvfilter(cvid,columnindex,columnname,comparator,value,groupid,column_condition)
		SELECT @cvid,0,CONCAT('ld_',LOWER(tmp_modulename),':','approvestatus',':','approvestatus',':',tmp_modulename,'_fieldlabel:V'),'e','审批中',1,'';

		INSERT INTO ld_cvadvfilter_grouping(groupid,cvid,condition_expression)
		SELECT 1,@cvid,0;

		INSERT INTO ld_cvcolumnlist(cvid,columnindex,columnname)
		SELECT @cvid,columnindex,columnname FROM ld_cvcolumnlist 
		WHERE cvid=(SELECT cvid FROM ld_customview WHERE entitytype=tmp_modulename AND viewname='All');


		SET @cvid=(SELECT cvid FROM ld_customview WHERE entitytype=tmp_modulename AND viewname='未提交');
		DELETE FROM ld_cvadvfilter WHERE cvid=@cvid;
		DELETE FROM ld_cvadvfilter_grouping WHERE cvid=@cvid;
		DELETE FROM ld_cvcolumnlist WHERE cvid=@cvid;

		INSERT INTO ld_cvadvfilter(cvid,columnindex,columnname,comparator,value,groupid,column_condition)
		SELECT @cvid,0,CONCAT('ld_',LOWER(tmp_modulename),':','approvestatus',':','approvestatus',':',tmp_modulename,'_fieldlabel:V'),'e','未提交',1,'';

		INSERT INTO ld_cvadvfilter_grouping(groupid,cvid,condition_expression)
		SELECT 1,@cvid,0;

		INSERT INTO ld_cvcolumnlist(cvid,columnindex,columnname)
		SELECT @cvid,columnindex,columnname FROM ld_cvcolumnlist 
		WHERE cvid=(SELECT cvid FROM ld_customview WHERE entitytype=tmp_modulename AND viewname='All');


		SET @cvid=(SELECT cvid FROM ld_customview WHERE entitytype=tmp_modulename AND viewname='已驳回');
		DELETE FROM ld_cvadvfilter WHERE cvid=@cvid;
		DELETE FROM ld_cvadvfilter_grouping WHERE cvid=@cvid;
		DELETE FROM ld_cvcolumnlist WHERE cvid=@cvid;

		INSERT INTO ld_cvadvfilter(cvid,columnindex,columnname,comparator,value,groupid,column_condition)
		SELECT @cvid,0,CONCAT('ld_',LOWER(tmp_modulename),':','approvestatus',':','approvestatus',':',tmp_modulename,'_fieldlabel:V'),'e','已驳回',1,'';

		INSERT INTO ld_cvadvfilter_grouping(groupid,cvid,condition_expression)
		SELECT 1,@cvid,0;

		INSERT INTO ld_cvcolumnlist(cvid,columnindex,columnname)
		SELECT @cvid,columnindex,columnname FROM ld_cvcolumnlist 
		WHERE cvid=(SELECT cvid FROM ld_customview WHERE entitytype=tmp_modulename AND viewname='All');


		SET @cvid=(SELECT cvid FROM ld_customview WHERE entitytype=tmp_modulename AND viewname='已拒绝');
		DELETE FROM ld_cvadvfilter WHERE cvid=@cvid;
		DELETE FROM ld_cvadvfilter_grouping WHERE cvid=@cvid;
		DELETE FROM ld_cvcolumnlist WHERE cvid=@cvid;

		INSERT INTO ld_cvadvfilter(cvid,columnindex,columnname,comparator,value,groupid,column_condition)
		SELECT @cvid,0,CONCAT('ld_',LOWER(tmp_modulename),':','approvestatus',':','approvestatus',':',tmp_modulename,'_fieldlabel:V'),'e','已拒绝',1,'';

		INSERT INTO ld_cvadvfilter_grouping(groupid,cvid,condition_expression)
		SELECT 1,@cvid,0;

		INSERT INTO ld_cvcolumnlist(cvid,columnindex,columnname)
		SELECT @cvid,columnindex,columnname FROM ld_cvcolumnlist 
		WHERE cvid=(SELECT cvid FROM ld_customview WHERE entitytype=tmp_modulename AND viewname='All');

		DELETE FROM ld_relatedlists WHERE tabid=@tabid;
		SET @i=IFNULL((SELECT MAX(sequence) FROM ld_relatedlists WHERE tabid=@tabid),0);
		SET @maxrelation_id=(SELECT max(relation_id) FROM ld_relatedlists);
		INSERT INTO ld_relatedlists(relation_id,tabid,related_tabid,`name`,sequence,label,presence,actions,related_coltable,type)
		SELECT @maxrelation_id+1,@tabid,'-1','get_SharedUsers',(@i:=@i+1),'SharedUsers',0,'share','','' FROM DUAL
		WHERE NOT EXISTS (SELECT 1 FROM ld_relatedlists WHERE tabid=@tabid AND related_tabid='-1' AND `name`='get_SharedUsers');

		SET @maxrelation_id=(SELECT max(relation_id) FROM ld_relatedlists);
		INSERT INTO ld_relatedlists(relation_id,tabid,related_tabid,`name`,sequence,label,presence,actions,related_coltable,type)
		SELECT @maxrelation_id+1,@tabid,'-7','get_viewhistory',(@i:=@i+1),'ViewHistory',1,'','','' FROM DUAL
		WHERE NOT EXISTS (SELECT 1 FROM ld_relatedlists WHERE tabid=@tabid AND related_tabid='-7' AND `name`='get_viewhistory');

		SET @maxrelation_id=(SELECT max(relation_id) FROM ld_relatedlists);
		INSERT INTO ld_relatedlists(relation_id,tabid,related_tabid,`name`,sequence,label,presence,actions,related_coltable,type)
		SELECT @maxrelation_id+1,@tabid,'-10','get_changeview',(@i:=@i+1),'ChangeView',1,'','','' FROM DUAL
		WHERE NOT EXISTS (SELECT 1 FROM ld_relatedlists WHERE tabid=@tabid AND related_tabid='-10' AND `name`='get_changeview');
		
		UPDATE ld_relatedlists_seq SET id=(SELECT MAX(relation_id) FROM ld_relatedlists);

		
		INSERT INTO ld_def_org_share(tabid,permission,editstatus)
		SELECT @tabid,3,0 FROM DUAL
		WHERE NOT EXISTS (SELECT 1 FROM ld_def_org_share WHERE tabid=@tabid);

		CALL addtabintoprofile(tmp_modulename,1);

		SET @roottype=(SELECT roottype FROM ld_systems_deploy WHERE deploy_type=112);
		SET @seq=(SELECT MAX(sequence) FROM ld_systems_deploy WHERE roottype=@roottype);
		INSERT INTO ld_systems_deploy(deploy_value,deploy_type,description,setype,sequence,roottype,inputtype,presence,inputvalue)
		SELECT 0,tmp_deploy_type,CONCAT(tmp_zhmoudulename,'是否启用审批流程'),tmp_modulename,@seq+1,@roottype,'select',0,'[{"value":"0","text":"YES"},{"value":"1","text":"NO"},{"sql":""}]' FROM DUAL
		WHERE NOT EXISTS (SELECT 1 FROM ld_systems_deploy WHERE deploy_type=tmp_deploy_type);


		SET @approvename=CONCAT(tmp_zhmoudulename,'审批流程');
		SET @approveid=(SELECT MAX(id) FROM ld_approve);
		INSERT INTO ld_approve(id,tabid,`name`,`status`,smcreatorid,modifiedby,createdtime,modifiedtime,approveallocatetype,allowediting,allowantiapproval,finishedallowedit)
		SELECT @approveid+1,@tabid,CONCAT(tmp_zhmoudulename,'审批流程'),0,1,1,now(),now(),0,0,0,'no' FROM DUAL
		WHERE NOT EXISTS (SELECT 1 FROM ld_approve WHERE tabid=@tabid AND `name`=@approvename);

		SET @approveid=(SELECT id FROM ld_approve WHERE tabid=@tabid AND `name`=@approvename);
		SET @maxsetpid=(SELECT MAX(id) FROM ld_approvestep);
		SET @hadinsert=(SELECT COUNT(1) FROM ld_approvestep WHERE approveid=@approveid);
		INSERT INTO ld_approvestep(id,approveid,`name`,ended,step,sequence,createdtime,modifiedtime,approvetype,approvevalue,specifyapproverid)
		SELECT @maxsetpid+1,@approveid,'一级审批',0,1,1,now(),now(),0,1,0 FROM DUAL WHERE @hadinsert=0;

		INSERT INTO ld_approvestep(id,approveid,`name`,ended,step,sequence,createdtime,modifiedtime,approvetype,approvevalue,specifyapproverid)
		SELECT @maxsetpid+2,@approveid,'二级审批',1,1,2,now(),now(),0,1,0 FROM DUAL WHERE @hadinsert=0;

		INSERT INTO ld_approvestep(id,approveid,`name`,ended,step,sequence,createdtime,modifiedtime,approvetype,approvevalue,specifyapproverid)
		SELECT @maxsetpid+3,@approveid,'三级审批',1,1,3,now(),now(),0,1,0 FROM DUAL WHERE @hadinsert=0;

		UPDATE ld_approvestep_seq SET id=(SELECT MAX(id) FROM ld_approvestep);

		SET @stepid=(SELECT id FROM ld_approvestep WHERE approveid=@approveid AND `name`='一级审批');
		INSERT INTO ld_approvereminds(stepid,type,remindmethod,reminduser,remindcontent)
		SELECT @stepid,0,'dialog','approver','有新的单据需要审批，请及时处理！' FROM DUAL
		WHERE NOT EXISTS (SELECT 1 FROM ld_approvereminds WHERE stepid=@stepid AND type=0);

		SET @stepid=(SELECT id FROM ld_approvestep WHERE approveid=@approveid AND `name`='一级审批');
		INSERT INTO ld_approvereminds(stepid,type,remindmethod,reminduser,remindcontent)
		SELECT @stepid,1,'dialog','smowner','您提交的单据已通过审批步骤{step}' FROM DUAL
		WHERE NOT EXISTS (SELECT 1 FROM ld_approvereminds WHERE stepid=@stepid AND type=1);

		SET @stepid=(SELECT id FROM ld_approvestep WHERE approveid=@approveid AND `name`='一级审批');
		INSERT INTO ld_approvereminds(stepid,type,remindmethod,reminduser,remindcontent)
		SELECT @stepid,2,'dialog','smowner','您提交的单据未通过审批步骤{step}，原因：{description}' FROM DUAL
		WHERE NOT EXISTS (SELECT 1 FROM ld_approvereminds WHERE stepid=@stepid AND type=2);

		SET @stepid=(SELECT id FROM ld_approvestep WHERE approveid=@approveid AND `name`='二级审批');
		INSERT INTO ld_approvereminds(stepid,type,remindmethod,reminduser,remindcontent)
		SELECT @stepid,0,'dialog','approver','有新的单据需要审批，请及时处理！' FROM DUAL
		WHERE NOT EXISTS (SELECT 1 FROM ld_approvereminds WHERE stepid=@stepid AND type=0);

		SET @stepid=(SELECT id FROM ld_approvestep WHERE approveid=@approveid AND `name`='二级审批');
		INSERT INTO ld_approvereminds(stepid,type,remindmethod,reminduser,remindcontent)
		SELECT @stepid,1,'dialog','smowner','您提交的单据已通过审批步骤{step}' FROM DUAL
		WHERE NOT EXISTS (SELECT 1 FROM ld_approvereminds WHERE stepid=@stepid AND type=1);

		SET @stepid=(SELECT id FROM ld_approvestep WHERE approveid=@approveid AND `name`='二级审批');
		INSERT INTO ld_approvereminds(stepid,type,remindmethod,reminduser,remindcontent)
		SELECT @stepid,2,'dialog','smowner','您提交的单据未通过审批步骤{step}，原因：{description}' FROM DUAL
		WHERE NOT EXISTS (SELECT 1 FROM ld_approvereminds WHERE stepid=@stepid AND type=2);

		SET @stepid=(SELECT id FROM ld_approvestep WHERE approveid=@approveid AND `name`='三级审批');
		INSERT INTO ld_approvereminds(stepid,type,remindmethod,reminduser,remindcontent)
		SELECT @stepid,0,'dialog','approver','有新的单据需要审批，请及时处理！' FROM DUAL
		WHERE NOT EXISTS (SELECT 1 FROM ld_approvereminds WHERE stepid=@stepid AND type=0);

		SET @stepid=(SELECT id FROM ld_approvestep WHERE approveid=@approveid AND `name`='三级审批');
		INSERT INTO ld_approvereminds(stepid,type,remindmethod,reminduser,remindcontent)
		SELECT @stepid,1,'dialog','smowner','您提交的单据已通过审批步骤{step}' FROM DUAL
		WHERE NOT EXISTS (SELECT 1 FROM ld_approvereminds WHERE stepid=@stepid AND type=1);

		SET @stepid=(SELECT id FROM ld_approvestep WHERE approveid=@approveid AND `name`='三级审批');
		INSERT INTO ld_approvereminds(stepid,type,remindmethod,reminduser,remindcontent)
		SELECT @stepid,2,'dialog','smowner','您提交的单据未通过审批步骤{step}，原因：{description}' FROM DUAL
		WHERE NOT EXISTS (SELECT 1 FROM ld_approvereminds WHERE stepid=@stepid AND type=2);


		
		SET @querysql=CONCAT("CREATE TABLE IF NOT EXISTS `ld_",LOWER(tmp_modulename),"` (
  `",LOWER(tmp_modulename),"id` INT(19) NOT NULL DEFAULT '0',
  `",LOWER(tmp_modulename),"_no` VARCHAR(255) DEFAULT NULL,
  `smownerid` INT(19) DEFAULT NULL,
  `smcreatorid` INT(19) DEFAULT NULL,
  `createdtime` DATETIME DEFAULT NULL,
	`modifiedby` INT(19) DEFAULT NULL,
	`modifiedtime` DATETIME DEFAULT NULL,
  `approvestatus` VARCHAR(50) DEFAULT '未提交',
  `approvetime` DATETIME DEFAULT NULL,
  `approveby` INT(19) DEFAULT NULL,
  `currentapprover` TEXT DEFAULT NULL,
	`print_times` INT(11) DEFAULT '0',
  `deleted` INT(19) NOT NULL DEFAULT '0',
  PRIMARY KEY (`",LOWER(tmp_modulename),"id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;");

		SET @querysql1=CONCAT("CREATE TABLE IF NOT EXISTS `ld_",LOWER(tmp_modulename),"scf` (
  `",LOWER(tmp_modulename),"id` INT(19) NOT NULL DEFAULT '0',
  PRIMARY KEY (`",LOWER(tmp_modulename),"id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;");


		PREPARE stmt FROM @querysql;
		EXECUTE stmt;

		PREPARE stmt FROM @querysql1;
		EXECUTE stmt;
		DROP PREPARE stmt;
				
	ELSEIF tmp_moduletype='productrel' THEN
		-- 有产品分录
		INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,Labeltype)
		SELECT 'zh','CUSTOMFORMPRODUCTREL','自定义表单，有产品分录','fixedstr' FROM DUAL
		WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE labelbol='CUSTOMFORMPRODUCTREL' AND languagetype='zh' AND Labeltype='fixedstr');

		INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,Labeltype)
		SELECT 'en','CUSTOMFORMPRODUCTREL','Custom form with products entry','fixedstr' FROM DUAL
		WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE labelbol='CUSTOMFORMPRODUCTREL' AND languagetype='en' AND Labeltype='fixedstr');

		SET @maxtabid=(SELECT MAX(tabid) FROM ld_tab);
		SET @maxtseq=(SELECT MAX(tabsequence) FROM ld_tab);
		INSERT INTO ld_tab(tabid,`name`,presence,tabsequence,tablabel,printtab,description)
		SELECT @maxtabid+1,tmp_modulename,5,@maxtseq+1,tmp_modulename,1,'CUSTOMFORMPRODUCTREL' FROM DUAL
		WHERE NOT EXISTS (SELECT 1 FROM ld_tab WHERE `name`=tmp_modulename);

		SET @tabid=(SELECT tabid FROM ld_tab WHERE `name`=tmp_modulename);
		INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
		SELECT 'zh','ld_tab',@tabid,@tabid,tmp_zhmoudulename FROM DUAL
		WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE tabid=@tabid AND relateid=@tabid AND languagetype='zh' AND trantable='ld_tab');
		INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
		SELECT 'en','ld_tab',@tabid,@tabid,tmp_enmoudulename FROM DUAL
		WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE tabid=@tabid AND relateid=@tabid AND languagetype='en' AND trantable='ld_tab');

		SET @labseq=IFNULL((SELECT MAX(sequence) FROM ld_parenttabrel WHERE parenttabid=tmp_parenttabid),0);
		INSERT INTO ld_parenttabrel(parenttabid,tabid,sequence)
		SELECT tmp_parenttabid,@tabid,@labseq+1 FROM DUAL
		WHERE NOT EXISTS (SELECT 1 FROM ld_parenttabrel WHERE parenttabid=tmp_parenttabid AND tabid=@tabid);

		SET @maxnum_id=(SELECT MAX(num_id) FROM ld_modentity_num);
		INSERT INTO ld_modentity_num(num_id,semodule,prefix,start_id,cur_id,active,datetype,useuseraccount,isallow,prefixtype)
		SELECT @maxnum_id+1,tmp_modulename,getPY(tmp_zhmoudulename),1,1,1,'none',0,1,0 FROM DUAL
		WHERE NOT EXISTS(SELECT 1 FROM ld_modentity_num WHERE semodule=tmp_modulename);
		UPDATE ld_modentity_num_seq SET id=@maxnum_id+1;

		INSERT INTO ld_modtracker_tabs(tabid,visible) 
		SELECT @tabid,1 FROM DUAL 
		WHERE NOT EXISTS (SELECT 1 FROM ld_modtracker_tabs WHERE tabid=@tabid);

		SET @i=0;
		INSERT INTO ld_profileallpermission(tabid,operation,sequence) 
		SELECT @tabid,actionid,(@i:=@i+1) FROM ld_actionmapping 
		WHERE NOT EXISTS (SELECT 1 FROM ld_profileallpermission WHERE tabid=@tabid) AND actionname IN 
			('index','Detailview','Create','EditView','Delete','Copy','Allocate','Share','Import','Export','ChangeCreator','CustomView');

		INSERT INTO ld_entityname(tabid ,modulename,tablename,fieldname,entityidfield,entityidcolumn)
		SELECT @tabid,tmp_modulename,CONCAT('ld_',LOWER(tmp_modulename)),CONCAT(LOWER(tmp_modulename),'_no'),CONCAT(LOWER(tmp_modulename),'id'),CONCAT(LOWER(tmp_modulename),'id') FROM DUAl
		WHERE NOT EXISTS (SELECT 1 FROM ld_entityname WHERE tabid=@tabid AND modulename=tmp_modulename);


		SET @maxblockid=(SELECT MAX(blockid) FROM ld_blocks);
		INSERT INTO ld_blocks(blockid,tabid,blocklabel,sequence,show_title,visible,create_view,edit_view,detail_view,display_status,iscustom)
		SELECT @maxblockid+1,@tabid,CONCAT('LBL_',UPPER(tmp_modulename),'_BASICINFORMATION'),1,0,0,0,0,0,1,0 FROM DUAL
		WHERE NOT EXISTS (SELECT 1 FROM ld_blocks WHERE blocklabel=CONCAT('LBL_',UPPER(tmp_modulename),'_BASICINFORMATION') AND tabid=@tabid);

		SET @blockid=(SELECT blockid FROM ld_blocks WHERE blocklabel=CONCAT('LBL_',UPPER(tmp_modulename),'_BASICINFORMATION') AND tabid=@tabid);
		INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
		SELECT 'zh','ld_blocks',@tabid,@blockid,'基本信息' FROM DUAL
		WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE tabid=@tabid AND relateid=@blockid AND languagetype='zh' and trantable='ld_blocks');	
		INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
		SELECT 'en','ld_blocks',@tabid,@blockid,'Basic Information' FROM DUAL
		WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE tabid=@tabid AND relateid=@blockid AND languagetype='en' and trantable='ld_blocks');
		UPDATE ld_blocks_seq SET id=(SELECT MAX(blockid) FROM ld_blocks);


		SET @i=IFNULL((SELECT MAX(sequence) FROM ld_field WHERE block=@blockid),0);
	  SET @maxfieldid=(SELECT MAX(fieldid) from ld_field);
		INSERT INTO ld_field (tabid,fieldid,columnname,allowhide,tablename,generatedtype,uitype,fieldname,fieldlabel,readonly,presence,sequence,block,displaytype,typeofdata,quickcreate,issmownerid,masseditable,approve_demand)
		SELECT @tabid,@maxfieldid+1,CONCAT(LOWER(tmp_modulename),'_no'),'no',CONCAT('ld_',LOWER(tmp_modulename)),1,4,CONCAT(LOWER(tmp_modulename),'_no'),'单据编号',1,0,(@i:=@i+1),@blockid ,1,'V~M',1,0,0,2 FROM DUAL
		WHERE NOT EXISTS (SELECT 1 FROM ld_field WHERE tabid=@tabid AND columnname=CONCAT(LOWER(tmp_modulename),'_no'));

		SET @fieldid=(SELECT fieldid FROM ld_field WHERE tabid=@tabid AND columnname=CONCAT(LOWER(tmp_modulename),'_no'));
		INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
		SELECT 'zh','ld_field',@tabid, @fieldid,'单据编号' FROM DUAL
		WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE tabid=@tabid AND relateid=@fieldid AND languagetype='zh' AND trantable='ld_field' );
		INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
		SELECT 'en','ld_field',@tabid, @fieldid,'Bill NO.' FROM DUAL
		WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE tabid=@tabid AND relateid=@fieldid AND languagetype='en' AND trantable='ld_field' );

		SET @maxfieldid=(SELECT MAX(fieldid) from ld_field);
		INSERT INTO ld_field (tabid,fieldid,columnname,allowhide,tablename,generatedtype,uitype,fieldname,fieldlabel,readonly,presence,sequence,block,displaytype,typeofdata,quickcreate,issmownerid,masseditable,approve_demand)
		SELECT @tabid,@maxfieldid+1,'','no','',1,202,'','选择源单',1,0,(@i:=@i+1),@blockid ,1,'V~O',1,1,1,2 FROM DUAL
		WHERE NOT EXISTS (SELECT 1 FROM ld_field WHERE tabid=@tabid AND uitype=202);

		SET @fieldid=(SELECT fieldid FROM ld_field WHERE tabid=@tabid AND columnname='smownerid');
		INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
		SELECT 'zh','ld_field',@tabid, @fieldid,'负责人' FROM DUAL
		WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE tabid=@tabid AND relateid=@fieldid AND languagetype='zh' AND trantable='ld_field' );
		INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
		SELECT 'en','ld_field',@tabid, @fieldid,'Assigned To' FROM DUAL
		WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE tabid=@tabid AND relateid=@fieldid AND languagetype='en' AND trantable='ld_field' );
	
		
		SET @maxfieldid=(SELECT MAX(fieldid) from ld_field);
		INSERT INTO ld_field (tabid,fieldid,columnname,allowhide,tablename,generatedtype,uitype,fieldname,fieldlabel,readonly,presence,sequence,block,displaytype,typeofdata,quickcreate,issmownerid,masseditable,approve_demand)
		SELECT @tabid,@maxfieldid+1,'smownerid','no',CONCAT('ld_',LOWER(tmp_modulename)),1,53,'assigned_user_id','负责人',1,0,(@i:=@i+1),@blockid ,1,'V~M',1,1,1,2 FROM DUAL
		WHERE NOT EXISTS (SELECT 1 FROM ld_field WHERE tabid=@tabid AND columnname='smownerid');

		SET @fieldid=(SELECT fieldid FROM ld_field WHERE tabid=@tabid AND columnname='smownerid');
		INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
		SELECT 'zh','ld_field',@tabid, @fieldid,'负责人' FROM DUAL
		WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE tabid=@tabid AND relateid=@fieldid AND languagetype='zh' AND trantable='ld_field' );
		INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
		SELECT 'en','ld_field',@tabid, @fieldid,'Assigned To' FROM DUAL
		WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE tabid=@tabid AND relateid=@fieldid AND languagetype='en' AND trantable='ld_field' );


		SET @maxfieldid=(SELECT MAX(fieldid) from ld_field);
		INSERT INTO ld_field (tabid,fieldid,columnname,allowhide,tablename,generatedtype,uitype,fieldname,fieldlabel,readonly,presence,sequence,block,displaytype,typeofdata,quickcreate,issmownerid,masseditable,approve_demand)
		SELECT @tabid,@maxfieldid+1,'smcreatorid','yes',CONCAT('ld_',LOWER(tmp_modulename)),1,52,'smcreatorid','创建人',1,0,(@i:=@i+1),@blockid ,2,'V~O',1,0,1,2 FROM DUAL
		WHERE NOT EXISTS (SELECT 1 FROM ld_field WHERE tabid=@tabid AND columnname='smcreatorid');

		SET @fieldid=(SELECT fieldid FROM ld_field WHERE tabid=@tabid AND columnname='smcreatorid');
		INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
		SELECT 'zh','ld_field',@tabid, @fieldid,'创建人' FROM DUAL
		WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE tabid=@tabid AND relateid=@fieldid AND languagetype='zh' AND trantable='ld_field' );
		INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
		SELECT 'en','ld_field',@tabid, @fieldid,'Creator' FROM DUAL
		WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE tabid=@tabid AND relateid=@fieldid AND languagetype='en' AND trantable='ld_field' );


		SET @maxfieldid=(SELECT MAX(fieldid) from ld_field);
		INSERT INTO ld_field (tabid,fieldid,columnname,allowhide,tablename,generatedtype,uitype,fieldname,fieldlabel,readonly,presence,sequence,block,displaytype,typeofdata,quickcreate,issmownerid,masseditable,approve_demand)
		SELECT @tabid,@maxfieldid+1,'createdtime','yes',CONCAT('ld_',LOWER(tmp_modulename)),1,70,'createdtime','创建时间',1,0,(@i:=@i+1),@blockid ,2,'DT~O',1,0,1,2 FROM DUAL
		WHERE NOT EXISTS (SELECT 1 FROM ld_field WHERE tabid=@tabid AND columnname='createdtime');

		SET @fieldid=(SELECT fieldid FROM ld_field WHERE tabid=@tabid AND columnname='createdtime');
		INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
		SELECT 'zh','ld_field',@tabid, @fieldid,'创建时间' FROM DUAL
		WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE tabid=@tabid AND relateid=@fieldid AND languagetype='zh' AND trantable='ld_field' );
		INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
		SELECT 'en','ld_field',@tabid, @fieldid,'Created Time' FROM DUAL
		WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE tabid=@tabid AND relateid=@fieldid AND languagetype='en' AND trantable='ld_field' );


		SET @maxfieldid=(SELECT MAX(fieldid) from ld_field);
		INSERT INTO ld_field (tabid,fieldid,columnname,allowhide,tablename,generatedtype,uitype,fieldname,fieldlabel,readonly,presence,sequence,block,displaytype,typeofdata,quickcreate,issmownerid,masseditable,approve_demand)
		SELECT @tabid,@maxfieldid+1,'modifiedby','yes',CONCAT('ld_',LOWER(tmp_modulename)),1,52,'modifiedby','最新更新人',1,0,(@i:=@i+1),@blockid ,2,'V~O',1,0,1,2 FROM DUAL
		WHERE NOT EXISTS (SELECT 1 FROM ld_field WHERE tabid=@tabid AND columnname='modifiedby');
		
		SET @fieldid=(SELECT fieldid FROM ld_field WHERE tabid=@tabid AND columnname='modifiedby');
		INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
		SELECT 'zh','ld_field',@tabid, @fieldid,'最新更新人' FROM DUAL
		WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE tabid=@tabid AND relateid=@fieldid AND languagetype='zh' AND trantable='ld_field' );
		INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
		SELECT 'en','ld_field',@tabid, @fieldid,'Modified By' FROM DUAL
		WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE tabid=@tabid AND relateid=@fieldid AND languagetype='en' AND trantable='ld_field' );


		SET @maxfieldid=(SELECT MAX(fieldid) from ld_field);
		INSERT INTO ld_field (tabid,fieldid,columnname,allowhide,tablename,generatedtype,uitype,fieldname,fieldlabel,readonly,presence,sequence,block,displaytype,typeofdata,quickcreate,issmownerid,masseditable,approve_demand)
		SELECT @tabid,@maxfieldid+1,'modifiedtime','yes',CONCAT('ld_',LOWER(tmp_modulename)),1,70,'modifiedtime','更新时间',1,0,(@i:=@i+1),@blockid ,2,'DT~O',1,0,1,2 FROM DUAL
		WHERE NOT EXISTS (SELECT 1 FROM ld_field WHERE tabid=@tabid AND columnname='modifiedtime');

		SET @fieldid=(SELECT fieldid FROM ld_field WHERE tabid=@tabid AND columnname='modifiedtime');
		INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
		SELECT 'zh','ld_field',@tabid, @fieldid,'更新时间' FROM DUAL
		WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE tabid=@tabid AND relateid=@fieldid AND languagetype='zh' AND trantable='ld_field' );
		INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
		SELECT 'en','ld_field',@tabid, @fieldid,'Modified Time' FROM DUAL
		WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE tabid=@tabid AND relateid=@fieldid AND languagetype='en' AND trantable='ld_field' );


		SET @maxfieldid=(SELECT MAX(fieldid) from ld_field);
		INSERT INTO ld_field (tabid,fieldid,columnname,allowhide,tablename,generatedtype,uitype,fieldname,fieldlabel,readonly,presence,sequence,block,displaytype,typeofdata,quickcreate,issmownerid,masseditable,approve_demand)
		SELECT @tabid,@maxfieldid+1,'approvestatus','yes',CONCAT('ld_',LOWER(tmp_modulename)),1,609,'approvestatus','审批状态',1,0,(@i:=@i+1),@blockid ,2,'V~O',1,0,1,2 FROM DUAL
		WHERE NOT EXISTS (SELECT 1 FROM ld_field WHERE tabid=@tabid AND columnname='approvestatus');

		SET @fieldid=(SELECT fieldid FROM ld_field WHERE tabid=@tabid AND columnname='approvestatus');
		INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
		SELECT 'zh','ld_field',@tabid, @fieldid,'审批状态' FROM DUAL
		WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE tabid=@tabid AND relateid=@fieldid AND languagetype='zh' AND trantable='ld_field' );
		INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
		SELECT 'en','ld_field',@tabid, @fieldid,'Approve Status' FROM DUAL
		WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE tabid=@tabid AND relateid=@fieldid AND languagetype='en' AND trantable='ld_field' );


		SET @maxfieldid=(SELECT MAX(fieldid) from ld_field);
		INSERT INTO ld_field (tabid,fieldid,columnname,allowhide,tablename,generatedtype,uitype,fieldname,fieldlabel,readonly,presence,sequence,block,displaytype,typeofdata,quickcreate,issmownerid,masseditable,approve_demand)
		SELECT @tabid,@maxfieldid+1,'approvetime','yes',CONCAT('ld_',LOWER(tmp_modulename)),1,70,'approvetime','最新审批时间',1,0,(@i:=@i+1),@blockid ,2,'DT~O',1,0,1,2 FROM DUAL
		WHERE NOT EXISTS (SELECT 1 FROM ld_field WHERE tabid=@tabid AND columnname='approvetime');

		SET @fieldid=(SELECT fieldid FROM ld_field WHERE tabid=@tabid AND columnname='approvetime');
		INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
		SELECT 'zh','ld_field',@tabid, @fieldid,'最新审批时间' FROM DUAL
		WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE tabid=@tabid AND relateid=@fieldid AND languagetype='zh' AND trantable='ld_field' );
		INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
		SELECT 'en','ld_field',@tabid, @fieldid,'Last Approval Time' FROM DUAL
		WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE tabid=@tabid AND relateid=@fieldid AND languagetype='en' AND trantable='ld_field' );


		SET @maxfieldid=(SELECT MAX(fieldid) from ld_field);
		INSERT INTO ld_field (tabid,fieldid,columnname,allowhide,tablename,generatedtype,uitype,fieldname,fieldlabel,readonly,presence,sequence,block,displaytype,typeofdata,quickcreate,issmownerid,masseditable,approve_demand)
		SELECT @tabid,@maxfieldid+1,'approveby','yes',CONCAT('ld_',LOWER(tmp_modulename)),1,131,'approveby','上一步审批人',1,0,(@i:=@i+1),@blockid ,2,'V~O',1,0,1,2 FROM DUAL
		WHERE NOT EXISTS (SELECT 1 FROM ld_field WHERE tabid=@tabid AND columnname='approveby');

		SET @fieldid=(SELECT fieldid FROM ld_field WHERE tabid=@tabid AND columnname='approveby');
		INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
		SELECT 'zh','ld_field',@tabid, @fieldid,'上一步审批人' FROM DUAL
		WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE tabid=@tabid AND relateid=@fieldid AND languagetype='zh' AND trantable='ld_field' );
		INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
		SELECT 'en','ld_field',@tabid, @fieldid,'The Last Approver' FROM DUAL
		WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE tabid=@tabid AND relateid=@fieldid AND languagetype='en' AND trantable='ld_field' );


		SET @maxfieldid=(SELECT MAX(fieldid) from ld_field);
		INSERT INTO ld_field (tabid,fieldid,columnname,allowhide,tablename,generatedtype,uitype,fieldname,fieldlabel,readonly,presence,sequence,block,displaytype,typeofdata,quickcreate,issmownerid,masseditable,approve_demand)
		SELECT @tabid,@maxfieldid+1,'currentapprover','yes',CONCAT('ld_',LOWER(tmp_modulename)),1,132,'currentapprover','当前审批人',1,0,(@i:=@i+1),@blockid ,2,'V~O',1,0,1,2 FROM DUAL
		WHERE NOT EXISTS (SELECT 1 FROM ld_field WHERE tabid=@tabid AND columnname='currentapprover');
		
		SET @fieldid=(SELECT fieldid FROM ld_field WHERE tabid=@tabid AND columnname='currentapprover');
		INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
		SELECT 'zh','ld_field',@tabid, @fieldid,'当前审批人' FROM DUAL
		WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE tabid=@tabid AND relateid=@fieldid AND languagetype='zh' AND trantable='ld_field' );
		INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
		SELECT 'en','ld_field',@tabid, @fieldid,'Current Approver' FROM DUAL
		WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE tabid=@tabid AND relateid=@fieldid AND languagetype='en' AND trantable='ld_field' );
		UPDATE ld_field_seq SET id=(SELECT MAX(fieldid) FROM ld_field);

		SET @maxfieldid=(SELECT MAX(fieldid) from ld_field);
		INSERT INTO ld_field (tabid,fieldid,columnname,allowhide,tablename,generatedtype,uitype,fieldname,fieldlabel,readonly,presence,sequence,block,displaytype,typeofdata,quickcreate,issmownerid,masseditable,approve_demand)
		SELECT @tabid,@maxfieldid+1,'print_times','yes',CONCAT('ld_',LOWER(tmp_modulename)),1,1,'print_times','打印次数',1,1,(@i:=@i+1),@blockid ,2,'N~O',1,0,1,2 FROM DUAL
		WHERE NOT EXISTS (SELECT 1 FROM ld_field WHERE tabid=@tabid AND columnname='print_times');
		
		SET @fieldid=(SELECT fieldid FROM ld_field WHERE tabid=@tabid AND columnname='print_times');
		INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
		SELECT 'zh','ld_field',@tabid, @fieldid,'打印次数' FROM DUAL
		WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE tabid=@tabid AND relateid=@fieldid AND languagetype='zh' AND trantable='ld_field' );
		INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
		SELECT 'en','ld_field',@tabid, @fieldid,'Print Times' FROM DUAL
		WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE tabid=@tabid AND relateid=@fieldid AND languagetype='en' AND trantable='ld_field' );
		UPDATE ld_field_seq SET id=(SELECT MAX(fieldid) FROM ld_field);


		SET @maxfieldid=(SELECT MAX(fieldid) from ld_field);
		INSERT INTO ld_field (tabid,fieldid,columnname,allowhide,tablename,generatedtype,uitype,fieldname,fieldlabel,readonly,presence,sequence,block,displaytype,typeofdata,quickcreate,issmownerid,masseditable,approve_demand)
		SELECT @tabid,@maxfieldid+1,'total','yes',CONCAT('ld_',LOWER(tmp_modulename)),1,72,'hdnGrandTotal','合计',1,0,(@i:=@i+1),@blockid ,3,'N~O',1,0,1,2 FROM DUAL
		WHERE NOT EXISTS (SELECT 1 FROM ld_field WHERE tabid=@tabid AND columnname='total');
		
		SET @fieldid=(SELECT fieldid FROM ld_field WHERE tabid=@tabid AND columnname='total');
		INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
		SELECT 'zh','ld_field',@tabid, @fieldid,'合计' FROM DUAL
		WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE tabid=@tabid AND relateid=@fieldid AND languagetype='zh' AND trantable='ld_field' );
		INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
		SELECT 'en','ld_field',@tabid, @fieldid,'Total' FROM DUAL
		WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE tabid=@tabid AND relateid=@fieldid AND languagetype='en' AND trantable='ld_field' );
		UPDATE ld_field_seq SET id=(SELECT MAX(fieldid) FROM ld_field);

		SET @maxfieldid=(SELECT MAX(fieldid) from ld_field);
		INSERT INTO ld_field (tabid,fieldid,columnname,allowhide,tablename,generatedtype,uitype,fieldname,fieldlabel,readonly,presence,sequence,block,displaytype,typeofdata,quickcreate,issmownerid,masseditable,approve_demand)
		SELECT @tabid,@maxfieldid+1,'subtotal','yes',CONCAT('ld_',LOWER(tmp_modulename)),1,72,'hdnSubTotal','小计',1,0,(@i:=@i+1),@blockid ,3,'N~O',1,0,1,2 FROM DUAL
		WHERE NOT EXISTS (SELECT 1 FROM ld_field WHERE tabid=@tabid AND columnname='subtotal');
		
		SET @fieldid=(SELECT fieldid FROM ld_field WHERE tabid=@tabid AND columnname='subtotal');
		INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
		SELECT 'zh','ld_field',@tabid, @fieldid,'小计' FROM DUAL
		WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE tabid=@tabid AND relateid=@fieldid AND languagetype='zh' AND trantable='ld_field' );
		INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
		SELECT 'en','ld_field',@tabid, @fieldid,'Subtotal' FROM DUAL
		WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE tabid=@tabid AND relateid=@fieldid AND languagetype='en' AND trantable='ld_field' );
		UPDATE ld_field_seq SET id=(SELECT MAX(fieldid) FROM ld_field);


		SET @maxfieldid=(SELECT MAX(fieldid) from ld_field);
		INSERT INTO ld_field (tabid,fieldid,columnname,allowhide,tablename,generatedtype,uitype,fieldname,fieldlabel,readonly,presence,sequence,block,displaytype,typeofdata,quickcreate,issmownerid,masseditable,approve_demand)
		SELECT @tabid,@maxfieldid+1,'discount_amount','yes',CONCAT('ld_',LOWER(tmp_modulename)),1,72,'hdnDiscountAmount','折扣直接降价',1,0,(@i:=@i+1),@blockid ,3,'N~O',1,0,1,2 FROM DUAL
		WHERE NOT EXISTS (SELECT 1 FROM ld_field WHERE tabid=@tabid AND columnname='discount_amount');
		
		SET @fieldid=(SELECT fieldid FROM ld_field WHERE tabid=@tabid AND columnname='discount_amount');
		INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
		SELECT 'zh','ld_field',@tabid, @fieldid,'折扣直接降价' FROM DUAL
		WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE tabid=@tabid AND relateid=@fieldid AND languagetype='zh' AND trantable='ld_field' );
		INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
		SELECT 'en','ld_field',@tabid, @fieldid,'Discount Amount' FROM DUAL
		WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE tabid=@tabid AND relateid=@fieldid AND languagetype='en' AND trantable='ld_field' );
		UPDATE ld_field_seq SET id=(SELECT MAX(fieldid) FROM ld_field);


		SET @maxfieldid=(SELECT MAX(fieldid) from ld_field);
		INSERT INTO ld_field (tabid,fieldid,columnname,allowhide,tablename,generatedtype,uitype,fieldname,fieldlabel,readonly,presence,sequence,block,displaytype,typeofdata,quickcreate,issmownerid,masseditable,approve_demand)
		SELECT @tabid,@maxfieldid+1,'currency_id','yes',CONCAT('ld_',LOWER(tmp_modulename)),1,117,'currency_id','币种',1,0,(@i:=@i+1),@blockid ,3,'V~M',1,0,1,2 FROM DUAL
		WHERE NOT EXISTS (SELECT 1 FROM ld_field WHERE tabid=@tabid AND columnname='currency_id');
		
		SET @fieldid=(SELECT fieldid FROM ld_field WHERE tabid=@tabid AND columnname='currency_id');
		INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
		SELECT 'zh','ld_field',@tabid, @fieldid,'币种' FROM DUAL
		WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE tabid=@tabid AND relateid=@fieldid AND languagetype='zh' AND trantable='ld_field' );
		INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
		SELECT 'en','ld_field',@tabid, @fieldid,'Currency' FROM DUAL
		WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE tabid=@tabid AND relateid=@fieldid AND languagetype='en' AND trantable='ld_field' );
		UPDATE ld_field_seq SET id=(SELECT MAX(fieldid) FROM ld_field);


		SET @maxfieldid=(SELECT MAX(fieldid) from ld_field);
		INSERT INTO ld_field (tabid,fieldid,columnname,allowhide,tablename,generatedtype,uitype,fieldname,fieldlabel,readonly,presence,sequence,block,displaytype,typeofdata,quickcreate,issmownerid,masseditable,approve_demand)
		SELECT @tabid,@maxfieldid+1,'conversion_rate','yes',CONCAT('ld_',LOWER(tmp_modulename)),1,1,'conversion_rate','汇率',1,0,(@i:=@i+1),@blockid ,3,'N~O',1,0,1,2 FROM DUAL
		WHERE NOT EXISTS (SELECT 1 FROM ld_field WHERE tabid=@tabid AND columnname='conversion_rate');
		
		SET @fieldid=(SELECT fieldid FROM ld_field WHERE tabid=@tabid AND columnname='conversion_rate');
		INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
		SELECT 'zh','ld_field',@tabid, @fieldid,'汇率' FROM DUAL
		WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE tabid=@tabid AND relateid=@fieldid AND languagetype='zh' AND trantable='ld_field' );
		INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
		SELECT 'en','ld_field',@tabid, @fieldid,'Conversion Rate' FROM DUAL
		WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE tabid=@tabid AND relateid=@fieldid AND languagetype='en' AND trantable='ld_field' );
		UPDATE ld_field_seq SET id=(SELECT MAX(fieldid) FROM ld_field);

		SET @i=(SELECT MAX(producttoolfieldid) FROM ld_producttoolfield);
		SET @j=0;
		INSERT INTO ld_producttoolfield(producttoolfieldid,columnname,allowhide,fieldlabel,defaultvalue,presence,uitype,typeofdata,sequence,tabid,tablename,width,edit_permission,input_type,fieldid,newline,defaultcolumn,is_checkimportfield,nullfield)
		SELECT (@i:=@i+1),columnname,allowhide,fieldlabel,defaultvalue,presence,uitype,typeofdata,(@j:=@j+1),@tabid,
			CASE
				WHEN tablename='ld_products' THEN 'ld_products'
				WHEN tablename='ld_inventoryproductrel' THEN CONCAT('ld_',LOWER(tmp_modulename),'detail')
				WHEN tablename='ld_inventoryproductrelscf' THEN CONCAT('ld_',LOWER(tmp_modulename),'detailscf')
				WHEN tablename='ld_invoice' THEN CONCAT('ld_',LOWER(tmp_modulename))
			END AS tablename,width,edit_permission,input_type,
		CASE
			WHEN tablename='ld_products' OR columnname IN ('listprice','taxprice','productcost') THEN fieldid
			WHEN columnname IN ('tax1','tax2','tax3') THEN (SELECT taxid FROM ld_inventorytaxinfo WHERE taxname=ld_producttoolfield.columnname)
			WHEN columnname IN ('discount_amount','adjustment','subtotal','total') THEN (SELECT fieldid FROM ld_field WHERE tabid=@tabid AND columnname=ld_producttoolfield.columnname)
			ELSE 0
		END AS fieldid,newline,defaultcolumn,is_checkimportfield,nullfield
		FROM ld_producttoolfield 
		WHERE tabid=23 
			AND NOT EXISTS (SELECT 1 FROM ld_producttoolfield WHERE tabid=@tabid)
		ORDER BY IFNULL(sequence,1000);

		DELETE FROM ld_producttoolfield_formula WHERE producttoolfieldid IN (SELECT producttoolfieldid FROM ld_producttoolfield WHERE tabid=@tabid);
		INSERT INTO ld_producttoolfield_formula(producttoolfieldid,formulastring,columnstring,sequence)
		SELECT  
			c.producttoolfieldid,
			a.formulastring,
			a.columnstring,
			a.sequence
		FROM ld_producttoolfield_formula a
		LEFT JOIN ld_producttoolfield b ON a.producttoolfieldid=b.producttoolfieldid
		LEFT JOIN ld_producttoolfield c ON c.columnname=b.columnname AND c.tabid=@tabid
		WHERE b.tabid=23
		ORDER BY a.sequence;

		DELETE FROM ld_tranlabel WHERE tabid=@tabid AND trantable='ld_producttoolfield';
		INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
		SELECT
		b.languagetype,
		b.trantable,
		@tabid,
		c.producttoolfieldid,
		b.fieldlabel
		FROM ld_producttoolfield a
		LEFT JOIN ld_tranlabel b ON b.Relateid=a.producttoolfieldid AND b.trantable='ld_producttoolfield'
		LEFT JOIN ld_producttoolfield c ON c.columnname=a.columnname AND c.tabid=@tabid
		WHERE a.tabid=23
		ORDER BY a.producttoolfieldid;


		CALL getallprofile(tmp_modulename);
		CALL fieldprofile(tmp_modulename);


		SELECT MAX(cvid) INTO @maxcvid  FROM ld_customview;
		INSERT INTO ld_customview (cvid,viewname,setdefault,setmetrics,entitytype,status,userid,sequence)
		SELECT @maxcvid+1,'All',1,0,tmp_modulename,3,1,1 FROM dual
		WHERE NOT EXISTS (SELECT 1 FROM ld_customview where entitytype=tmp_modulename and viewname='All');

		INSERT INTO ld_customview (cvid,viewname,setdefault,setmetrics,entitytype,status,userid,sequence)
		SELECT @maxcvid+2,'已批准',0,0,tmp_modulename,3,1,2 FROM dual
		WHERE NOT EXISTS (SELECT 1 FROM ld_customview where entitytype=tmp_modulename and viewname='已批准');

		INSERT INTO ld_customview (cvid,viewname,setdefault,setmetrics,entitytype,status,userid,sequence)
		SELECT @maxcvid+3,'审批中',0,0,tmp_modulename,3,1,3 FROM dual
		WHERE NOT EXISTS (SELECT 1 FROM ld_customview where entitytype=tmp_modulename and viewname='审批中');

		INSERT INTO ld_customview (cvid,viewname,setdefault,setmetrics,entitytype,status,userid,sequence)
		SELECT @maxcvid+4,'未提交',0,0,tmp_modulename,3,1,4 FROM dual
		WHERE NOT EXISTS (SELECT 1 FROM ld_customview where entitytype=tmp_modulename and viewname='未提交');

		INSERT INTO ld_customview (cvid,viewname,setdefault,setmetrics,entitytype,status,userid,sequence)
		SELECT @maxcvid+5,'已驳回',0,0,tmp_modulename,3,1,5 FROM dual
		WHERE NOT EXISTS (SELECT 1 FROM ld_customview where entitytype=tmp_modulename and viewname='已驳回');

		INSERT INTO ld_customview (cvid,viewname,setdefault,setmetrics,entitytype,status,userid,sequence)
		SELECT @maxcvid+6,'已拒绝',0,0,tmp_modulename,3,1,6 FROM dual
		WHERE NOT EXISTS (SELECT 1 FROM ld_customview where entitytype=tmp_modulename and viewname='已拒绝');

		UPDATE ld_customview_seq SET id=(SELECT MAX(cvid) FROM ld_customview);

		
		SET @cvid=(SELECT cvid FROM ld_customview WHERE entitytype=tmp_modulename AND viewname='All');
		DELETE FROM ld_cvadvfilter WHERE cvid=@cvid;
		DELETE FROM ld_cvadvfilter_grouping WHERE cvid=@cvid;
		DELETE FROM ld_tabwithproductview WHERE cvid=@cvid;

		INSERT INTO ld_tabwithproductview(tabid,cvid,sequence,columns)
		SELECT @tabid,@cvid,0,CONCAT('ld_',LOWER(tmp_modulename),':',LOWER(tmp_modulename),'_no',':',LOWER(tmp_modulename),'_no',':',tmp_modulename,'_fieldlabel:V');
		INSERT INTO ld_tabwithproductview(tabid,cvid,sequence,columns)
		SELECT @tabid,@cvid,1,CONCAT('ld_',LOWER(tmp_modulename),':','total',':','hdnGrandTotal',':',tmp_modulename,'_fieldlabel:N');
		INSERT INTO ld_tabwithproductview(tabid,cvid,sequence,columns)
		SELECT @tabid,@cvid,2,CONCAT('ld_',LOWER(tmp_modulename),':','smownerid',':','assigned_user_id',':',tmp_modulename,'_fieldlabel:V');
		INSERT INTO ld_tabwithproductview(tabid,cvid,sequence,columns)
		SELECT @tabid,@cvid,3,CONCAT('ld_',LOWER(tmp_modulename),':','approvestatus',':','approvestatus',':',tmp_modulename,'_fieldlabel:V');
		INSERT INTO ld_tabwithproductview(tabid,cvid,sequence,columns)
		SELECT @tabid,@cvid,4,CONCAT('ld_',LOWER(tmp_modulename),':','smcreatorid',':','smcreatorid',':',tmp_modulename,'_fieldlabel:V');
		INSERT INTO ld_tabwithproductview(tabid,cvid,sequence,columns)
		SELECT @tabid,@cvid,5,CONCAT('ld_',LOWER(tmp_modulename),':','createdtime',':','createdtime',':',tmp_modulename,'_fieldlabel:DT');


		SET @cvid=(SELECT cvid FROM ld_customview WHERE entitytype=tmp_modulename AND viewname='已批准');
		DELETE FROM ld_cvadvfilter WHERE cvid=@cvid;
		DELETE FROM ld_cvadvfilter_grouping WHERE cvid=@cvid;
		DELETE FROM ld_tabwithproductview WHERE cvid=@cvid;

		INSERT INTO ld_cvadvfilter(cvid,columnindex,columnname,comparator,value,groupid,column_condition)
		SELECT @cvid,0,CONCAT('ld_',LOWER(tmp_modulename),':','approvestatus',':','approvestatus',':',tmp_modulename,'_fieldlabel:V'),'e','已批准',1,'';

		INSERT INTO ld_cvadvfilter_grouping(groupid,cvid,condition_expression)
		SELECT 1,@cvid,0;

		INSERT INTO ld_tabwithproductview(tabid,cvid,sequence,columns)
		SELECT @tabid,@cvid,sequence,columns FROM ld_tabwithproductview 
		WHERE tabid=@tabid AND cvid=(SELECT cvid FROM ld_customview WHERE entitytype=tmp_modulename AND viewname='All');


		SET @cvid=(SELECT cvid FROM ld_customview WHERE entitytype=tmp_modulename AND viewname='审批中');
		DELETE FROM ld_cvadvfilter WHERE cvid=@cvid;
		DELETE FROM ld_cvadvfilter_grouping WHERE cvid=@cvid;
		DELETE FROM ld_tabwithproductview WHERE cvid=@cvid;

		INSERT INTO ld_cvadvfilter(cvid,columnindex,columnname,comparator,value,groupid,column_condition)
		SELECT @cvid,0,CONCAT('ld_',LOWER(tmp_modulename),':','approvestatus',':','approvestatus',':',tmp_modulename,'_fieldlabel:V'),'e','审批中',1,'';

		INSERT INTO ld_cvadvfilter_grouping(groupid,cvid,condition_expression)
		SELECT 1,@cvid,0;

		INSERT INTO ld_tabwithproductview(tabid,cvid,sequence,columns)
		SELECT @tabid,@cvid,sequence,columns FROM ld_tabwithproductview 
		WHERE tabid=@tabid AND cvid=(SELECT cvid FROM ld_customview WHERE entitytype=tmp_modulename AND viewname='All');


		SET @cvid=(SELECT cvid FROM ld_customview WHERE entitytype=tmp_modulename AND viewname='未提交');
		DELETE FROM ld_cvadvfilter WHERE cvid=@cvid;
		DELETE FROM ld_cvadvfilter_grouping WHERE cvid=@cvid;
		DELETE FROM ld_tabwithproductview WHERE cvid=@cvid;

		INSERT INTO ld_cvadvfilter(cvid,columnindex,columnname,comparator,value,groupid,column_condition)
		SELECT @cvid,0,CONCAT('ld_',LOWER(tmp_modulename),':','approvestatus',':','approvestatus',':',tmp_modulename,'_fieldlabel:V'),'e','未提交',1,'';

		INSERT INTO ld_cvadvfilter_grouping(groupid,cvid,condition_expression)
		SELECT 1,@cvid,0;

		INSERT INTO ld_tabwithproductview(tabid,cvid,sequence,columns)
		SELECT @tabid,@cvid,sequence,columns FROM ld_tabwithproductview 
		WHERE tabid=@tabid AND cvid=(SELECT cvid FROM ld_customview WHERE entitytype=tmp_modulename AND viewname='All');


		SET @cvid=(SELECT cvid FROM ld_customview WHERE entitytype=tmp_modulename AND viewname='已驳回');
		DELETE FROM ld_cvadvfilter WHERE cvid=@cvid;
		DELETE FROM ld_cvadvfilter_grouping WHERE cvid=@cvid;
		DELETE FROM ld_tabwithproductview WHERE cvid=@cvid;

		INSERT INTO ld_cvadvfilter(cvid,columnindex,columnname,comparator,value,groupid,column_condition)
		SELECT @cvid,0,CONCAT('ld_',LOWER(tmp_modulename),':','approvestatus',':','approvestatus',':',tmp_modulename,'_fieldlabel:V'),'e','已驳回',1,'';

		INSERT INTO ld_cvadvfilter_grouping(groupid,cvid,condition_expression)
		SELECT 1,@cvid,0;

		INSERT INTO ld_tabwithproductview(tabid,cvid,sequence,columns)
		SELECT @tabid,@cvid,sequence,columns FROM ld_tabwithproductview 
		WHERE tabid=@tabid AND cvid=(SELECT cvid FROM ld_customview WHERE entitytype=tmp_modulename AND viewname='All');


		SET @cvid=(SELECT cvid FROM ld_customview WHERE entitytype=tmp_modulename AND viewname='已拒绝');
		DELETE FROM ld_cvadvfilter WHERE cvid=@cvid;
		DELETE FROM ld_cvadvfilter_grouping WHERE cvid=@cvid;
		DELETE FROM ld_tabwithproductview WHERE cvid=@cvid;

		INSERT INTO ld_cvadvfilter(cvid,columnindex,columnname,comparator,value,groupid,column_condition)
		SELECT @cvid,0,CONCAT('ld_',LOWER(tmp_modulename),':','approvestatus',':','approvestatus',':',tmp_modulename,'_fieldlabel:V'),'e','已拒绝',1,'';

		INSERT INTO ld_cvadvfilter_grouping(groupid,cvid,condition_expression)
		SELECT 1,@cvid,0;

		INSERT INTO ld_tabwithproductview(tabid,cvid,sequence,columns)
		SELECT @tabid,@cvid,sequence,columns FROM ld_tabwithproductview 
		WHERE tabid=@tabid AND cvid=(SELECT cvid FROM ld_customview WHERE entitytype=tmp_modulename AND viewname='All');

		DELETE FROM ld_relatedlists WHERE tabid=@tabid;
		SET @i=IFNULL((SELECT MAX(sequence) FROM ld_relatedlists WHERE tabid=@tabid),0);
		SET @maxrelation_id=(SELECT max(relation_id) FROM ld_relatedlists);
		INSERT INTO ld_relatedlists(relation_id,tabid,related_tabid,`name`,sequence,label,presence,actions,related_coltable,type)
		SELECT @maxrelation_id+1,@tabid,'-1','get_SharedUsers',(@i:=@i+1),'SharedUsers',0,'share','','' FROM DUAL
		WHERE NOT EXISTS (SELECT 1 FROM ld_relatedlists WHERE tabid=@tabid AND related_tabid='-1' AND `name`='get_SharedUsers');

		SET @maxrelation_id=(SELECT max(relation_id) FROM ld_relatedlists);
		INSERT INTO ld_relatedlists(relation_id,tabid,related_tabid,`name`,sequence,label,presence,actions,related_coltable,type)
		SELECT @maxrelation_id+1,@tabid,'-7','get_viewhistory',(@i:=@i+1),'ViewHistory',1,'','','' FROM DUAL
		WHERE NOT EXISTS (SELECT 1 FROM ld_relatedlists WHERE tabid=@tabid AND related_tabid='-7' AND `name`='get_viewhistory');

		SET @maxrelation_id=(SELECT max(relation_id) FROM ld_relatedlists);
		INSERT INTO ld_relatedlists(relation_id,tabid,related_tabid,`name`,sequence,label,presence,actions,related_coltable,type)
		SELECT @maxrelation_id+1,@tabid,'-10','get_changeview',(@i:=@i+1),'ChangeView',1,'','','' FROM DUAL
		WHERE NOT EXISTS (SELECT 1 FROM ld_relatedlists WHERE tabid=@tabid AND related_tabid='-10' AND `name`='get_changeview');
		
		UPDATE ld_relatedlists_seq SET id=(SELECT MAX(relation_id) FROM ld_relatedlists);

		
		INSERT INTO ld_def_org_share(tabid,permission,editstatus)
		SELECT @tabid,3,0 FROM DUAL
		WHERE NOT EXISTS (SELECT 1 FROM ld_def_org_share WHERE tabid=@tabid);

		CALL addtabintoprofile(tmp_modulename,1);

		SET @roottype=(SELECT roottype FROM ld_systems_deploy WHERE deploy_type=112);
		SET @seq=(SELECT MAX(sequence) FROM ld_systems_deploy WHERE roottype=@roottype);
		INSERT INTO ld_systems_deploy(deploy_value,deploy_type,description,setype,sequence,roottype,inputtype,presence,inputvalue)
		SELECT 0,tmp_deploy_type,CONCAT(tmp_zhmoudulename,'是否启用审批流程'),tmp_modulename,@seq+1,@roottype,'select',0,'[{"value":"0","text":"YES"},{"value":"1","text":"NO"},{"sql":""}]' FROM DUAL
		WHERE NOT EXISTS (SELECT 1 FROM ld_systems_deploy WHERE deploy_type=tmp_deploy_type);


		SET @approvename=CONCAT(tmp_zhmoudulename,'审批流程');
		SET @approveid=(SELECT MAX(id) FROM ld_approve);
		INSERT INTO ld_approve(id,tabid,`name`,`status`,smcreatorid,modifiedby,createdtime,modifiedtime,approveallocatetype,allowediting,allowantiapproval,finishedallowedit)
		SELECT @approveid+1,@tabid,CONCAT(tmp_zhmoudulename,'审批流程'),0,1,1,now(),now(),0,0,0,'no' FROM DUAL
		WHERE NOT EXISTS (SELECT 1 FROM ld_approve WHERE tabid=@tabid AND `name`=@approvename);

		SET @approveid=(SELECT id FROM ld_approve WHERE tabid=@tabid AND `name`=@approvename);
		SET @maxsetpid=(SELECT MAX(id) FROM ld_approvestep);
		SET @hadinsert=(SELECT COUNT(1) FROM ld_approvestep WHERE approveid=@approveid);
		INSERT INTO ld_approvestep(id,approveid,`name`,ended,step,sequence,createdtime,modifiedtime,approvetype,approvevalue,specifyapproverid)
		SELECT @maxsetpid+1,@approveid,'一级审批',0,1,1,now(),now(),0,1,0 FROM DUAL WHERE @hadinsert=0;

		INSERT INTO ld_approvestep(id,approveid,`name`,ended,step,sequence,createdtime,modifiedtime,approvetype,approvevalue,specifyapproverid)
		SELECT @maxsetpid+2,@approveid,'二级审批',1,1,2,now(),now(),0,1,0 FROM DUAL WHERE @hadinsert=0;

		INSERT INTO ld_approvestep(id,approveid,`name`,ended,step,sequence,createdtime,modifiedtime,approvetype,approvevalue,specifyapproverid)
		SELECT @maxsetpid+3,@approveid,'三级审批',1,1,3,now(),now(),0,1,0 FROM DUAL WHERE @hadinsert=0;

		UPDATE ld_approvestep_seq SET id=(SELECT MAX(id) FROM ld_approvestep);

		SET @stepid=(SELECT id FROM ld_approvestep WHERE approveid=@approveid AND `name`='一级审批');
		INSERT INTO ld_approvereminds(stepid,type,remindmethod,reminduser,remindcontent)
		SELECT @stepid,0,'dialog','approver','有新的单据需要审批，请及时处理！' FROM DUAL
		WHERE NOT EXISTS (SELECT 1 FROM ld_approvereminds WHERE stepid=@stepid AND type=0);

		SET @stepid=(SELECT id FROM ld_approvestep WHERE approveid=@approveid AND `name`='一级审批');
		INSERT INTO ld_approvereminds(stepid,type,remindmethod,reminduser,remindcontent)
		SELECT @stepid,1,'dialog','smowner','您提交的单据已通过审批步骤{step}' FROM DUAL
		WHERE NOT EXISTS (SELECT 1 FROM ld_approvereminds WHERE stepid=@stepid AND type=1);

		SET @stepid=(SELECT id FROM ld_approvestep WHERE approveid=@approveid AND `name`='一级审批');
		INSERT INTO ld_approvereminds(stepid,type,remindmethod,reminduser,remindcontent)
		SELECT @stepid,2,'dialog','smowner','您提交的单据未通过审批步骤{step}，原因：{description}' FROM DUAL
		WHERE NOT EXISTS (SELECT 1 FROM ld_approvereminds WHERE stepid=@stepid AND type=2);

		SET @stepid=(SELECT id FROM ld_approvestep WHERE approveid=@approveid AND `name`='二级审批');
		INSERT INTO ld_approvereminds(stepid,type,remindmethod,reminduser,remindcontent)
		SELECT @stepid,0,'dialog','approver','有新的单据需要审批，请及时处理！' FROM DUAL
		WHERE NOT EXISTS (SELECT 1 FROM ld_approvereminds WHERE stepid=@stepid AND type=0);

		SET @stepid=(SELECT id FROM ld_approvestep WHERE approveid=@approveid AND `name`='二级审批');
		INSERT INTO ld_approvereminds(stepid,type,remindmethod,reminduser,remindcontent)
		SELECT @stepid,1,'dialog','smowner','您提交的单据已通过审批步骤{step}' FROM DUAL
		WHERE NOT EXISTS (SELECT 1 FROM ld_approvereminds WHERE stepid=@stepid AND type=1);

		SET @stepid=(SELECT id FROM ld_approvestep WHERE approveid=@approveid AND `name`='二级审批');
		INSERT INTO ld_approvereminds(stepid,type,remindmethod,reminduser,remindcontent)
		SELECT @stepid,2,'dialog','smowner','您提交的单据未通过审批步骤{step}，原因：{description}' FROM DUAL
		WHERE NOT EXISTS (SELECT 1 FROM ld_approvereminds WHERE stepid=@stepid AND type=2);

		SET @stepid=(SELECT id FROM ld_approvestep WHERE approveid=@approveid AND `name`='三级审批');
		INSERT INTO ld_approvereminds(stepid,type,remindmethod,reminduser,remindcontent)
		SELECT @stepid,0,'dialog','approver','有新的单据需要审批，请及时处理！' FROM DUAL
		WHERE NOT EXISTS (SELECT 1 FROM ld_approvereminds WHERE stepid=@stepid AND type=0);

		SET @stepid=(SELECT id FROM ld_approvestep WHERE approveid=@approveid AND `name`='三级审批');
		INSERT INTO ld_approvereminds(stepid,type,remindmethod,reminduser,remindcontent)
		SELECT @stepid,1,'dialog','smowner','您提交的单据已通过审批步骤{step}' FROM DUAL
		WHERE NOT EXISTS (SELECT 1 FROM ld_approvereminds WHERE stepid=@stepid AND type=1);

		SET @stepid=(SELECT id FROM ld_approvestep WHERE approveid=@approveid AND `name`='三级审批');
		INSERT INTO ld_approvereminds(stepid,type,remindmethod,reminduser,remindcontent)
		SELECT @stepid,2,'dialog','smowner','您提交的单据未通过审批步骤{step}，原因：{description}' FROM DUAL
		WHERE NOT EXISTS (SELECT 1 FROM ld_approvereminds WHERE stepid=@stepid AND type=2);


		
		SET @querysql=CONCAT("CREATE TABLE IF NOT EXISTS `ld_",LOWER(tmp_modulename),"` (
  `",LOWER(tmp_modulename),"id` INT(19) NOT NULL DEFAULT '0',
  `",LOWER(tmp_modulename),"_no` VARCHAR(255) DEFAULT NULL,
  `smownerid` INT(19) DEFAULT NULL,
  `smcreatorid` INT(19) DEFAULT NULL,
  `createdtime` DATETIME DEFAULT NULL,
  `modifiedby` INT(19) DEFAULT NULL,
  `modifiedtime` DATETIME DEFAULT NULL,
  `approvestatus` VARCHAR(50) DEFAULT '未提交',
  `approvetime` DATETIME DEFAULT NULL,
  `approveby` INT(19) DEFAULT NULL,
  `currentapprover` TEXT DEFAULT NULL,
  `print_times` INT(11) DEFAULT '0',
  `total` DECIMAL(25,6) DEFAULT NULL,
  `subtotal` DECIMAL(25,6) DEFAULT NULL,
  `adjustment` DECIMAL(25,6) DEFAULT NULL,
  `discount_type` INT(1) DEFAULT 0,
  `discount_percent` DECIMAL(25,3) NOT NULL DEFAULT '0.000',
  `discount_amount` DECIMAL(25,6) DEFAULT NULL,
  `s_h_amount` DECIMAL(25,3) DEFAULT NULL,
  `currency_id` INT(19) DEFAULT '1',
  `conversion_rate` DECIMAL(25,6) DEFAULT NULL,
  `currency_symbol` VARCHAR(30) DEFAULT NULL,
  `deleted` INT(19) NOT NULL DEFAULT '0',
  PRIMARY KEY (`",LOWER(tmp_modulename),"id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;");

		SET @querysql1=CONCAT("CREATE TABLE IF NOT EXISTS `ld_",LOWER(tmp_modulename),"scf` (
  `",LOWER(tmp_modulename),"id` INT(19) NOT NULL DEFAULT '0',
  PRIMARY KEY (`",LOWER(tmp_modulename),"id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;");

		SET @querysql2=CONCAT("CREATE TABLE IF NOT EXISTS `ld_",LOWER(tmp_modulename),"detail` LIKE ld_inventoryproductrel");
		SET @querysql3=CONCAT("CREATE TABLE IF NOT EXISTS `ld_",LOWER(tmp_modulename),"detailscf` LIKE ld_inventoryproductrelscf");

		PREPARE stmt FROM @querysql;
		EXECUTE stmt;

		PREPARE stmt FROM @querysql1;
		EXECUTE stmt;

		PREPARE stmt FROM @querysql2;
		EXECUTE stmt;

		PREPARE stmt FROM @querysql3;
		EXECUTE stmt;
		DROP PREPARE stmt;


	ELSEIF tmp_moduletype='basicrel' THEN
		-- 普通带单据分录的单据
		INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,Labeltype)
		SELECT 'zh','CUSTOMFORMBASICREL','自定义表单，有分录','fixedstr' FROM DUAL
		WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE labelbol='CUSTOMFORMBASICREL' AND languagetype='zh' AND Labeltype='fixedstr');

		INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,Labeltype)
		SELECT 'en','CUSTOMFORMBASICREL','Custom form with entry','fixedstr' FROM DUAL
		WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE labelbol='CUSTOMFORMBASICREL' AND languagetype='en' AND Labeltype='fixedstr');

		SET @maxtabid=(SELECT MAX(tabid) FROM ld_tab);
		SET @maxtseq=(SELECT MAX(tabsequence) FROM ld_tab);
		INSERT INTO ld_tab(tabid,`name`,presence,tabsequence,tablabel,printtab,description)
		SELECT @maxtabid+1,tmp_modulename,5,@maxtseq+1,tmp_modulename,1,'CUSTOMFORMBASICREL' FROM DUAL
		WHERE NOT EXISTS (SELECT 1 FROM ld_tab WHERE `name`=tmp_modulename);

		SET @tabid=(SELECT tabid FROM ld_tab WHERE `name`=tmp_modulename);
		INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
		SELECT 'zh','ld_tab',@tabid,@tabid,tmp_zhmoudulename FROM DUAL
		WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE tabid=@tabid AND relateid=@tabid AND languagetype='zh' AND trantable='ld_tab');
		INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
		SELECT 'en','ld_tab',@tabid,@tabid,tmp_enmoudulename FROM DUAL
		WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE tabid=@tabid AND relateid=@tabid AND languagetype='en' AND trantable='ld_tab');

		SET @labseq=IFNULL((SELECT MAX(sequence) FROM ld_parenttabrel WHERE parenttabid=tmp_parenttabid),0);
		INSERT INTO ld_parenttabrel(parenttabid,tabid,sequence)
		SELECT tmp_parenttabid,@tabid,@labseq+1 FROM DUAL
		WHERE NOT EXISTS (SELECT 1 FROM ld_parenttabrel WHERE parenttabid=tmp_parenttabid AND tabid=@tabid);

		SET @maxnum_id=(SELECT MAX(num_id) FROM ld_modentity_num);
		INSERT INTO ld_modentity_num(num_id,semodule,prefix,start_id,cur_id,active,datetype,useuseraccount,isallow,prefixtype)
		SELECT @maxnum_id+1,tmp_modulename,getPY(tmp_zhmoudulename),1,1,1,'none',0,1,0 FROM DUAL
		WHERE NOT EXISTS(SELECT 1 FROM ld_modentity_num WHERE semodule=tmp_modulename);
		UPDATE ld_modentity_num_seq SET id=@maxnum_id+1;

		INSERT INTO ld_modtracker_tabs(tabid,visible) 
		SELECT @tabid,1 FROM DUAL 
		WHERE NOT EXISTS (SELECT 1 FROM ld_modtracker_tabs WHERE tabid=@tabid);

		SET @i=0;
		INSERT INTO ld_profileallpermission(tabid,operation,sequence) 
		SELECT @tabid,actionid,(@i:=@i+1) FROM ld_actionmapping 
		WHERE NOT EXISTS (SELECT 1 FROM ld_profileallpermission WHERE tabid=@tabid) AND actionname IN 
			('index','Detailview','Create','EditView','Delete','Copy','Allocate','Share','Import','Export','ChangeCreator','CustomView');

		INSERT INTO ld_entityname(tabid ,modulename,tablename,fieldname,entityidfield,entityidcolumn)
		SELECT @tabid,tmp_modulename,CONCAT('ld_',LOWER(tmp_modulename)),CONCAT(LOWER(tmp_modulename),'_no'),CONCAT(LOWER(tmp_modulename),'id'),CONCAT(LOWER(tmp_modulename),'id') FROM DUAl
		WHERE NOT EXISTS (SELECT 1 FROM ld_entityname WHERE tabid=@tabid AND modulename=tmp_modulename);


		SET @maxblockid=(SELECT MAX(blockid) FROM ld_blocks);
		INSERT INTO ld_blocks(blockid,tabid,blocklabel,sequence,show_title,visible,create_view,edit_view,detail_view,display_status,iscustom)
		SELECT @maxblockid+1,@tabid,CONCAT('LBL_',UPPER(tmp_modulename),'_BASICINFORMATION'),1,0,0,0,0,0,1,0 FROM DUAL
		WHERE NOT EXISTS (SELECT 1 FROM ld_blocks WHERE blocklabel=CONCAT('LBL_',UPPER(tmp_modulename),'_BASICINFORMATION') AND tabid=@tabid);

		SET @blockid=(SELECT blockid FROM ld_blocks WHERE blocklabel=CONCAT('LBL_',UPPER(tmp_modulename),'_BASICINFORMATION') AND tabid=@tabid);
		INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
		SELECT 'zh','ld_blocks',@tabid,@blockid,'基本信息' FROM DUAL
		WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE tabid=@tabid AND relateid=@blockid AND languagetype='zh' and trantable='ld_blocks');	
		INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
		SELECT 'en','ld_blocks',@tabid,@blockid,'Basic Information' FROM DUAL
		WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE tabid=@tabid AND relateid=@blockid AND languagetype='en' and trantable='ld_blocks');
		UPDATE ld_blocks_seq SET id=(SELECT MAX(blockid) FROM ld_blocks);


		SET @i=IFNULL((SELECT MAX(sequence) FROM ld_field WHERE block=@blockid),0);
	  SET @maxfieldid=(SELECT MAX(fieldid) from ld_field);
		INSERT INTO ld_field (tabid,fieldid,columnname,allowhide,tablename,generatedtype,uitype,fieldname,fieldlabel,readonly,presence,sequence,block,displaytype,typeofdata,quickcreate,issmownerid,masseditable,approve_demand)
		SELECT @tabid,@maxfieldid+1,CONCAT(LOWER(tmp_modulename),'_no'),'no',CONCAT('ld_',LOWER(tmp_modulename)),1,4,CONCAT(LOWER(tmp_modulename),'_no'),'单据编号',1,0,(@i:=@i+1),@blockid ,1,'V~M',1,0,0,2 FROM DUAL
		WHERE NOT EXISTS (SELECT 1 FROM ld_field WHERE tabid=@tabid AND columnname=CONCAT(LOWER(tmp_modulename),'_no'));

		SET @fieldid=(SELECT fieldid FROM ld_field WHERE tabid=@tabid AND columnname=CONCAT(LOWER(tmp_modulename),'_no'));
		INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
		SELECT 'zh','ld_field',@tabid, @fieldid,'单据编号' FROM DUAL
		WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE tabid=@tabid AND relateid=@fieldid AND languagetype='zh' AND trantable='ld_field' );
		INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
		SELECT 'en','ld_field',@tabid, @fieldid,'Bill NO.' FROM DUAL
		WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE tabid=@tabid AND relateid=@fieldid AND languagetype='en' AND trantable='ld_field' );


		SET @fieldid=(SELECT fieldid FROM ld_field WHERE tabid=@tabid AND columnname='smownerid');
		INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
		SELECT 'zh','ld_field',@tabid, @fieldid,'负责人' FROM DUAL
		WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE tabid=@tabid AND relateid=@fieldid AND languagetype='zh' AND trantable='ld_field' );
		INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
		SELECT 'en','ld_field',@tabid, @fieldid,'Assigned To' FROM DUAL
		WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE tabid=@tabid AND relateid=@fieldid AND languagetype='en' AND trantable='ld_field' );
	
		
		SET @maxfieldid=(SELECT MAX(fieldid) from ld_field);
		INSERT INTO ld_field (tabid,fieldid,columnname,allowhide,tablename,generatedtype,uitype,fieldname,fieldlabel,readonly,presence,sequence,block,displaytype,typeofdata,quickcreate,issmownerid,masseditable,approve_demand)
		SELECT @tabid,@maxfieldid+1,'smownerid','no',CONCAT('ld_',LOWER(tmp_modulename)),1,53,'assigned_user_id','负责人',1,0,(@i:=@i+1),@blockid ,1,'V~M',1,1,1,2 FROM DUAL
		WHERE NOT EXISTS (SELECT 1 FROM ld_field WHERE tabid=@tabid AND columnname='smownerid');

		SET @fieldid=(SELECT fieldid FROM ld_field WHERE tabid=@tabid AND columnname='smownerid');
		INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
		SELECT 'zh','ld_field',@tabid, @fieldid,'负责人' FROM DUAL
		WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE tabid=@tabid AND relateid=@fieldid AND languagetype='zh' AND trantable='ld_field' );
		INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
		SELECT 'en','ld_field',@tabid, @fieldid,'Assigned To' FROM DUAL
		WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE tabid=@tabid AND relateid=@fieldid AND languagetype='en' AND trantable='ld_field' );


		SET @maxfieldid=(SELECT MAX(fieldid) from ld_field);
		INSERT INTO ld_field (tabid,fieldid,columnname,allowhide,tablename,generatedtype,uitype,fieldname,fieldlabel,readonly,presence,sequence,block,displaytype,typeofdata,quickcreate,issmownerid,masseditable,approve_demand)
		SELECT @tabid,@maxfieldid+1,'smcreatorid','yes',CONCAT('ld_',LOWER(tmp_modulename)),1,52,'smcreatorid','创建人',1,0,(@i:=@i+1),@blockid ,2,'V~O',1,0,1,2 FROM DUAL
		WHERE NOT EXISTS (SELECT 1 FROM ld_field WHERE tabid=@tabid AND columnname='smcreatorid');

		SET @fieldid=(SELECT fieldid FROM ld_field WHERE tabid=@tabid AND columnname='smcreatorid');
		INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
		SELECT 'zh','ld_field',@tabid, @fieldid,'创建人' FROM DUAL
		WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE tabid=@tabid AND relateid=@fieldid AND languagetype='zh' AND trantable='ld_field' );
		INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
		SELECT 'en','ld_field',@tabid, @fieldid,'Creator' FROM DUAL
		WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE tabid=@tabid AND relateid=@fieldid AND languagetype='en' AND trantable='ld_field' );


		SET @maxfieldid=(SELECT MAX(fieldid) from ld_field);
		INSERT INTO ld_field (tabid,fieldid,columnname,allowhide,tablename,generatedtype,uitype,fieldname,fieldlabel,readonly,presence,sequence,block,displaytype,typeofdata,quickcreate,issmownerid,masseditable,approve_demand)
		SELECT @tabid,@maxfieldid+1,'createdtime','yes',CONCAT('ld_',LOWER(tmp_modulename)),1,70,'createdtime','创建时间',1,0,(@i:=@i+1),@blockid ,2,'DT~O',1,0,1,2 FROM DUAL
		WHERE NOT EXISTS (SELECT 1 FROM ld_field WHERE tabid=@tabid AND columnname='createdtime');

		SET @fieldid=(SELECT fieldid FROM ld_field WHERE tabid=@tabid AND columnname='createdtime');
		INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
		SELECT 'zh','ld_field',@tabid, @fieldid,'创建时间' FROM DUAL
		WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE tabid=@tabid AND relateid=@fieldid AND languagetype='zh' AND trantable='ld_field' );
		INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
		SELECT 'en','ld_field',@tabid, @fieldid,'Created Time' FROM DUAL
		WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE tabid=@tabid AND relateid=@fieldid AND languagetype='en' AND trantable='ld_field' );


		SET @maxfieldid=(SELECT MAX(fieldid) from ld_field);
		INSERT INTO ld_field (tabid,fieldid,columnname,allowhide,tablename,generatedtype,uitype,fieldname,fieldlabel,readonly,presence,sequence,block,displaytype,typeofdata,quickcreate,issmownerid,masseditable,approve_demand)
		SELECT @tabid,@maxfieldid+1,'modifiedby','yes',CONCAT('ld_',LOWER(tmp_modulename)),1,52,'modifiedby','最新更新人',1,0,(@i:=@i+1),@blockid ,2,'V~O',1,0,1,2 FROM DUAL
		WHERE NOT EXISTS (SELECT 1 FROM ld_field WHERE tabid=@tabid AND columnname='modifiedby');
		
		SET @fieldid=(SELECT fieldid FROM ld_field WHERE tabid=@tabid AND columnname='modifiedby');
		INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
		SELECT 'zh','ld_field',@tabid, @fieldid,'最新更新人' FROM DUAL
		WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE tabid=@tabid AND relateid=@fieldid AND languagetype='zh' AND trantable='ld_field' );
		INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
		SELECT 'en','ld_field',@tabid, @fieldid,'Modified By' FROM DUAL
		WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE tabid=@tabid AND relateid=@fieldid AND languagetype='en' AND trantable='ld_field' );


		SET @maxfieldid=(SELECT MAX(fieldid) from ld_field);
		INSERT INTO ld_field (tabid,fieldid,columnname,allowhide,tablename,generatedtype,uitype,fieldname,fieldlabel,readonly,presence,sequence,block,displaytype,typeofdata,quickcreate,issmownerid,masseditable,approve_demand)
		SELECT @tabid,@maxfieldid+1,'modifiedtime','yes',CONCAT('ld_',LOWER(tmp_modulename)),1,70,'modifiedtime','更新时间',1,0,(@i:=@i+1),@blockid ,2,'DT~O',1,0,1,2 FROM DUAL
		WHERE NOT EXISTS (SELECT 1 FROM ld_field WHERE tabid=@tabid AND columnname='modifiedtime');

		SET @fieldid=(SELECT fieldid FROM ld_field WHERE tabid=@tabid AND columnname='modifiedtime');
		INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
		SELECT 'zh','ld_field',@tabid, @fieldid,'更新时间' FROM DUAL
		WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE tabid=@tabid AND relateid=@fieldid AND languagetype='zh' AND trantable='ld_field' );
		INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
		SELECT 'en','ld_field',@tabid, @fieldid,'Modified Time' FROM DUAL
		WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE tabid=@tabid AND relateid=@fieldid AND languagetype='en' AND trantable='ld_field' );


		SET @maxfieldid=(SELECT MAX(fieldid) from ld_field);
		INSERT INTO ld_field (tabid,fieldid,columnname,allowhide,tablename,generatedtype,uitype,fieldname,fieldlabel,readonly,presence,sequence,block,displaytype,typeofdata,quickcreate,issmownerid,masseditable,approve_demand)
		SELECT @tabid,@maxfieldid+1,'approvestatus','yes',CONCAT('ld_',LOWER(tmp_modulename)),1,609,'approvestatus','审批状态',1,0,(@i:=@i+1),@blockid ,2,'V~O',1,0,1,2 FROM DUAL
		WHERE NOT EXISTS (SELECT 1 FROM ld_field WHERE tabid=@tabid AND columnname='approvestatus');

		SET @fieldid=(SELECT fieldid FROM ld_field WHERE tabid=@tabid AND columnname='approvestatus');
		INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
		SELECT 'zh','ld_field',@tabid, @fieldid,'审批状态' FROM DUAL
		WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE tabid=@tabid AND relateid=@fieldid AND languagetype='zh' AND trantable='ld_field' );
		INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
		SELECT 'en','ld_field',@tabid, @fieldid,'Approve Status' FROM DUAL
		WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE tabid=@tabid AND relateid=@fieldid AND languagetype='en' AND trantable='ld_field' );


		SET @maxfieldid=(SELECT MAX(fieldid) from ld_field);
		INSERT INTO ld_field (tabid,fieldid,columnname,allowhide,tablename,generatedtype,uitype,fieldname,fieldlabel,readonly,presence,sequence,block,displaytype,typeofdata,quickcreate,issmownerid,masseditable,approve_demand)
		SELECT @tabid,@maxfieldid+1,'approvetime','yes',CONCAT('ld_',LOWER(tmp_modulename)),1,70,'approvetime','最新审批时间',1,0,(@i:=@i+1),@blockid ,2,'DT~O',1,0,1,2 FROM DUAL
		WHERE NOT EXISTS (SELECT 1 FROM ld_field WHERE tabid=@tabid AND columnname='approvetime');

		SET @fieldid=(SELECT fieldid FROM ld_field WHERE tabid=@tabid AND columnname='approvetime');
		INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
		SELECT 'zh','ld_field',@tabid, @fieldid,'最新审批时间' FROM DUAL
		WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE tabid=@tabid AND relateid=@fieldid AND languagetype='zh' AND trantable='ld_field' );
		INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
		SELECT 'en','ld_field',@tabid, @fieldid,'Last Approval Time' FROM DUAL
		WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE tabid=@tabid AND relateid=@fieldid AND languagetype='en' AND trantable='ld_field' );


		SET @maxfieldid=(SELECT MAX(fieldid) from ld_field);
		INSERT INTO ld_field (tabid,fieldid,columnname,allowhide,tablename,generatedtype,uitype,fieldname,fieldlabel,readonly,presence,sequence,block,displaytype,typeofdata,quickcreate,issmownerid,masseditable,approve_demand)
		SELECT @tabid,@maxfieldid+1,'approveby','yes',CONCAT('ld_',LOWER(tmp_modulename)),1,131,'approveby','上一步审批人',1,0,(@i:=@i+1),@blockid ,2,'V~O',1,0,1,2 FROM DUAL
		WHERE NOT EXISTS (SELECT 1 FROM ld_field WHERE tabid=@tabid AND columnname='approveby');

		SET @fieldid=(SELECT fieldid FROM ld_field WHERE tabid=@tabid AND columnname='approveby');
		INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
		SELECT 'zh','ld_field',@tabid, @fieldid,'上一步审批人' FROM DUAL
		WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE tabid=@tabid AND relateid=@fieldid AND languagetype='zh' AND trantable='ld_field' );
		INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
		SELECT 'en','ld_field',@tabid, @fieldid,'The Last Approver' FROM DUAL
		WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE tabid=@tabid AND relateid=@fieldid AND languagetype='en' AND trantable='ld_field' );


		SET @maxfieldid=(SELECT MAX(fieldid) from ld_field);
		INSERT INTO ld_field (tabid,fieldid,columnname,allowhide,tablename,generatedtype,uitype,fieldname,fieldlabel,readonly,presence,sequence,block,displaytype,typeofdata,quickcreate,issmownerid,masseditable,approve_demand)
		SELECT @tabid,@maxfieldid+1,'currentapprover','yes',CONCAT('ld_',LOWER(tmp_modulename)),1,132,'currentapprover','当前审批人',1,0,(@i:=@i+1),@blockid ,2,'V~O',1,0,1,2 FROM DUAL
		WHERE NOT EXISTS (SELECT 1 FROM ld_field WHERE tabid=@tabid AND columnname='currentapprover');
		
		SET @fieldid=(SELECT fieldid FROM ld_field WHERE tabid=@tabid AND columnname='currentapprover');
		INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
		SELECT 'zh','ld_field',@tabid, @fieldid,'当前审批人' FROM DUAL
		WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE tabid=@tabid AND relateid=@fieldid AND languagetype='zh' AND trantable='ld_field' );
		INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
		SELECT 'en','ld_field',@tabid, @fieldid,'Current Approver' FROM DUAL
		WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE tabid=@tabid AND relateid=@fieldid AND languagetype='en' AND trantable='ld_field' );
		UPDATE ld_field_seq SET id=(SELECT MAX(fieldid) FROM ld_field);

		SET @maxfieldid=(SELECT MAX(fieldid) from ld_field);
		INSERT INTO ld_field (tabid,fieldid,columnname,allowhide,tablename,generatedtype,uitype,fieldname,fieldlabel,readonly,presence,sequence,block,displaytype,typeofdata,quickcreate,issmownerid,masseditable,approve_demand)
		SELECT @tabid,@maxfieldid+1,'print_times','yes',CONCAT('ld_',LOWER(tmp_modulename)),1,1,'print_times','打印次数',1,1,(@i:=@i+1),@blockid ,2,'N~O',1,0,1,2 FROM DUAL
		WHERE NOT EXISTS (SELECT 1 FROM ld_field WHERE tabid=@tabid AND columnname='print_times');
		
		SET @fieldid=(SELECT fieldid FROM ld_field WHERE tabid=@tabid AND columnname='print_times');
		INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
		SELECT 'zh','ld_field',@tabid, @fieldid,'打印次数' FROM DUAL
		WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE tabid=@tabid AND relateid=@fieldid AND languagetype='zh' AND trantable='ld_field' );
		INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
		SELECT 'en','ld_field',@tabid, @fieldid,'Print Times' FROM DUAL
		WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE tabid=@tabid AND relateid=@fieldid AND languagetype='en' AND trantable='ld_field' );
		UPDATE ld_field_seq SET id=(SELECT MAX(fieldid) FROM ld_field);


		SET @maxfieldid=(SELECT MAX(fieldid) from ld_field);
		INSERT INTO ld_field (tabid,fieldid,columnname,allowhide,tablename,generatedtype,uitype,fieldname,fieldlabel,readonly,presence,sequence,block,displaytype,typeofdata,quickcreate,issmownerid,masseditable,approve_demand)
		SELECT @tabid,@maxfieldid+1,'total','yes',CONCAT('ld_',LOWER(tmp_modulename)),1,72,'hdnGrandTotal','合计',1,0,(@i:=@i+1),@blockid ,3,'N~O',1,0,1,2 FROM DUAL
		WHERE NOT EXISTS (SELECT 1 FROM ld_field WHERE tabid=@tabid AND columnname='total');
		
		SET @fieldid=(SELECT fieldid FROM ld_field WHERE tabid=@tabid AND columnname='total');
		INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
		SELECT 'zh','ld_field',@tabid, @fieldid,'合计' FROM DUAL
		WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE tabid=@tabid AND relateid=@fieldid AND languagetype='zh' AND trantable='ld_field' );
		INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
		SELECT 'en','ld_field',@tabid, @fieldid,'Total' FROM DUAL
		WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE tabid=@tabid AND relateid=@fieldid AND languagetype='en' AND trantable='ld_field' );
		UPDATE ld_field_seq SET id=(SELECT MAX(fieldid) FROM ld_field);



		SET @j=0;
		INSERT INTO ld_tabdetailfield(tabid,columnname,allowhide,tablename,fieldlabel,defaultvalue,presence,fieldtype,typeofdata,sequence,width,edit_permission,input_type,fieldid,newline,is_checkimportfield,nullfield)
		SELECT @tabid,columnname,allowhide,
			CASE
				WHEN columnname IN ('entitytypeid','source_total','amount','remark','due_date','received_amount','cashbilldate') THEN CONCAT('ld_',LOWER(tmp_modulename),'detail')
				WHEN columnname IN ('total') THEN CONCAT('ld_',LOWER(tmp_modulename))
			END AS tablename,fieldlabel,defaultvalue,presence,fieldtype,typeofdata,(@j:=@j+1),width,edit_permission,input_type,
			fieldid,newline,is_checkimportfield,nullfield
		FROM ld_tabdetailfield 
		WHERE tabid=(SELECT tabid FROM ld_tab WHERE `name`='Commission')
			AND columnname IN ('entitytypeid','source_total','amount','remark','total','due_date','received_amount','cashbilldate')
			AND NOT EXISTS (SELECT 1 FROM ld_tabdetailfield WHERE tabid=@tabid)
		ORDER BY IFNULL(sequence,1000);


		DELETE FROM ld_tranlabel WHERE tabid=@tabid AND trantable='ld_tabdetailfield' AND Relateid IN (
				SELECT tabdetailfieldid FROM ld_tabdetailfield WHERE tabid=@tabid AND columnname IN ('entitytypeid','source_total','amount','remark','total','due_date','received_amount','cashbilldate'));
		INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
		SELECT
			b.languagetype,
			b.trantable,
			@tabid,
			c.tabdetailfieldid,
			b.fieldlabel
		FROM ld_tabdetailfield a
		LEFT JOIN ld_tranlabel b ON b.Relateid=a.tabdetailfieldid AND b.trantable='ld_tabdetailfield'
		LEFT JOIN ld_tabdetailfield c ON c.columnname=a.columnname AND c.tabid=@tabid
		WHERE a.tabid=(SELECT tabid FROM ld_tab WHERE `name`='Commission')
			AND a.columnname IN ('entitytypeid','source_total','amount','remark','total','due_date','received_amount','cashbilldate')
		ORDER BY a.tabdetailfieldid;

		DELETE FROM ld_option_module WHERE tabid=@tabid;
		INSERT INTO ld_option_module(tabid,option_tabid,presence,`default`,approve_demand,sequence,table_sequence)
		SELECT @tabid,option_tabid,presence,`default`,approve_demand,sequence,table_sequence FROM ld_option_module 
		WHERE tabid=(SELECT tabid FROM ld_tab WHERE `name`='Commission');

		DELETE FROM ld_select_related_field WHERE module=tmp_modulename;
		INSERT INTO ld_select_related_field(module,selectmodule,relatedstring)
		SELECT tmp_modulename,selectmodule,relatedstring FROM ld_select_related_field
		WHERE module='Commission';
        
        DELETE FROM ld_tabdetailfield_formula WHERE tabdetailfieldid IN (SELECT tabdetailfieldid FROM ld_tabdetailfield WHERE tabid=@tabid);
        INSERT INTO ld_tabdetailfield_formula(tabdetailfieldid,formulastring,columnstring,sequence)
        SELECT  
        	c.tabdetailfieldid,
        	a.formulastring,
        	a.columnstring,
        	a.sequence
        FROM ld_tabdetailfield_formula a
        LEFT JOIN ld_tabdetailfield b ON a.tabdetailfieldid=b.tabdetailfieldid
        INNER JOIN ld_tabdetailfield c ON c.columnname=b.columnname AND c.tabid=@tabid
        WHERE b.tabid=(SELECT tabid FROM ld_tab WHERE `name`='Commission')
        ORDER BY a.sequence;

		CALL getallprofile(tmp_modulename);
		CALL fieldprofile(tmp_modulename);


		SELECT MAX(cvid) INTO @maxcvid  FROM ld_customview;
		INSERT INTO ld_customview (cvid,viewname,setdefault,setmetrics,entitytype,status,userid,sequence)
		SELECT @maxcvid+1,'All',1,0,tmp_modulename,3,1,1 FROM dual
		WHERE NOT EXISTS (SELECT 1 FROM ld_customview where entitytype=tmp_modulename and viewname='All');

		INSERT INTO ld_customview (cvid,viewname,setdefault,setmetrics,entitytype,status,userid,sequence)
		SELECT @maxcvid+2,'已批准',0,0,tmp_modulename,3,1,2 FROM dual
		WHERE NOT EXISTS (SELECT 1 FROM ld_customview where entitytype=tmp_modulename and viewname='已批准');

		INSERT INTO ld_customview (cvid,viewname,setdefault,setmetrics,entitytype,status,userid,sequence)
		SELECT @maxcvid+3,'审批中',0,0,tmp_modulename,3,1,3 FROM dual
		WHERE NOT EXISTS (SELECT 1 FROM ld_customview where entitytype=tmp_modulename and viewname='审批中');

		INSERT INTO ld_customview (cvid,viewname,setdefault,setmetrics,entitytype,status,userid,sequence)
		SELECT @maxcvid+4,'未提交',0,0,tmp_modulename,3,1,4 FROM dual
		WHERE NOT EXISTS (SELECT 1 FROM ld_customview where entitytype=tmp_modulename and viewname='未提交');

		INSERT INTO ld_customview (cvid,viewname,setdefault,setmetrics,entitytype,status,userid,sequence)
		SELECT @maxcvid+5,'已驳回',0,0,tmp_modulename,3,1,5 FROM dual
		WHERE NOT EXISTS (SELECT 1 FROM ld_customview where entitytype=tmp_modulename and viewname='已驳回');

		INSERT INTO ld_customview (cvid,viewname,setdefault,setmetrics,entitytype,status,userid,sequence)
		SELECT @maxcvid+6,'已拒绝',0,0,tmp_modulename,3,1,6 FROM dual
		WHERE NOT EXISTS (SELECT 1 FROM ld_customview where entitytype=tmp_modulename and viewname='已拒绝');

		UPDATE ld_customview_seq SET id=(SELECT MAX(cvid) FROM ld_customview);

		
		SET @cvid=(SELECT cvid FROM ld_customview WHERE entitytype=tmp_modulename AND viewname='All');
		DELETE FROM ld_cvadvfilter WHERE cvid=@cvid;
		DELETE FROM ld_cvadvfilter_grouping WHERE cvid=@cvid;
		DELETE FROM ld_tabwithproductview WHERE cvid=@cvid;

		INSERT INTO ld_tabwithproductview(tabid,cvid,sequence,columns)
		SELECT @tabid,@cvid,0,CONCAT('ld_',LOWER(tmp_modulename),':',LOWER(tmp_modulename),'_no',':',LOWER(tmp_modulename),'_no',':',tmp_modulename,'_fieldlabel:V');
		INSERT INTO ld_tabwithproductview(tabid,cvid,sequence,columns)
		SELECT @tabid,@cvid,1,CONCAT('ld_',LOWER(tmp_modulename),':','total',':','hdnGrandTotal',':',tmp_modulename,'_fieldlabel:N');
		INSERT INTO ld_tabwithproductview(tabid,cvid,sequence,columns)
		SELECT @tabid,@cvid,2,CONCAT('ld_',LOWER(tmp_modulename),':','smownerid',':','assigned_user_id',':',tmp_modulename,'_fieldlabel:V');
		INSERT INTO ld_tabwithproductview(tabid,cvid,sequence,columns)
		SELECT @tabid,@cvid,3,CONCAT('ld_',LOWER(tmp_modulename),':','approvestatus',':','approvestatus',':',tmp_modulename,'_fieldlabel:V');
		INSERT INTO ld_tabwithproductview(tabid,cvid,sequence,columns)
		SELECT @tabid,@cvid,4,CONCAT('ld_',LOWER(tmp_modulename),':','smcreatorid',':','smcreatorid',':',tmp_modulename,'_fieldlabel:V');
		INSERT INTO ld_tabwithproductview(tabid,cvid,sequence,columns)
		SELECT @tabid,@cvid,5,CONCAT('ld_',LOWER(tmp_modulename),':','createdtime',':','createdtime',':',tmp_modulename,'_fieldlabel:DT');


		SET @cvid=(SELECT cvid FROM ld_customview WHERE entitytype=tmp_modulename AND viewname='已批准');
		DELETE FROM ld_cvadvfilter WHERE cvid=@cvid;
		DELETE FROM ld_cvadvfilter_grouping WHERE cvid=@cvid;
		DELETE FROM ld_tabwithproductview WHERE cvid=@cvid;

		INSERT INTO ld_cvadvfilter(cvid,columnindex,columnname,comparator,value,groupid,column_condition)
		SELECT @cvid,0,CONCAT('ld_',LOWER(tmp_modulename),':','approvestatus',':','approvestatus',':',tmp_modulename,'_fieldlabel:V'),'e','已批准',1,'';

		INSERT INTO ld_cvadvfilter_grouping(groupid,cvid,condition_expression)
		SELECT 1,@cvid,0;

		INSERT INTO ld_tabwithproductview(tabid,cvid,sequence,columns)
		SELECT @tabid,@cvid,sequence,columns FROM ld_tabwithproductview 
		WHERE tabid=@tabid AND cvid=(SELECT cvid FROM ld_customview WHERE entitytype=tmp_modulename AND viewname='All');


		SET @cvid=(SELECT cvid FROM ld_customview WHERE entitytype=tmp_modulename AND viewname='审批中');
		DELETE FROM ld_cvadvfilter WHERE cvid=@cvid;
		DELETE FROM ld_cvadvfilter_grouping WHERE cvid=@cvid;
		DELETE FROM ld_tabwithproductview WHERE cvid=@cvid;

		INSERT INTO ld_cvadvfilter(cvid,columnindex,columnname,comparator,value,groupid,column_condition)
		SELECT @cvid,0,CONCAT('ld_',LOWER(tmp_modulename),':','approvestatus',':','approvestatus',':',tmp_modulename,'_fieldlabel:V'),'e','审批中',1,'';

		INSERT INTO ld_cvadvfilter_grouping(groupid,cvid,condition_expression)
		SELECT 1,@cvid,0;

		INSERT INTO ld_tabwithproductview(tabid,cvid,sequence,columns)
		SELECT @tabid,@cvid,sequence,columns FROM ld_tabwithproductview 
		WHERE tabid=@tabid AND cvid=(SELECT cvid FROM ld_customview WHERE entitytype=tmp_modulename AND viewname='All');


		SET @cvid=(SELECT cvid FROM ld_customview WHERE entitytype=tmp_modulename AND viewname='未提交');
		DELETE FROM ld_cvadvfilter WHERE cvid=@cvid;
		DELETE FROM ld_cvadvfilter_grouping WHERE cvid=@cvid;
		DELETE FROM ld_tabwithproductview WHERE cvid=@cvid;

		INSERT INTO ld_cvadvfilter(cvid,columnindex,columnname,comparator,value,groupid,column_condition)
		SELECT @cvid,0,CONCAT('ld_',LOWER(tmp_modulename),':','approvestatus',':','approvestatus',':',tmp_modulename,'_fieldlabel:V'),'e','未提交',1,'';

		INSERT INTO ld_cvadvfilter_grouping(groupid,cvid,condition_expression)
		SELECT 1,@cvid,0;

		INSERT INTO ld_tabwithproductview(tabid,cvid,sequence,columns)
		SELECT @tabid,@cvid,sequence,columns FROM ld_tabwithproductview 
		WHERE tabid=@tabid AND cvid=(SELECT cvid FROM ld_customview WHERE entitytype=tmp_modulename AND viewname='All');


		SET @cvid=(SELECT cvid FROM ld_customview WHERE entitytype=tmp_modulename AND viewname='已驳回');
		DELETE FROM ld_cvadvfilter WHERE cvid=@cvid;
		DELETE FROM ld_cvadvfilter_grouping WHERE cvid=@cvid;
		DELETE FROM ld_tabwithproductview WHERE cvid=@cvid;

		INSERT INTO ld_cvadvfilter(cvid,columnindex,columnname,comparator,value,groupid,column_condition)
		SELECT @cvid,0,CONCAT('ld_',LOWER(tmp_modulename),':','approvestatus',':','approvestatus',':',tmp_modulename,'_fieldlabel:V'),'e','已驳回',1,'';

		INSERT INTO ld_cvadvfilter_grouping(groupid,cvid,condition_expression)
		SELECT 1,@cvid,0;

		INSERT INTO ld_tabwithproductview(tabid,cvid,sequence,columns)
		SELECT @tabid,@cvid,sequence,columns FROM ld_tabwithproductview 
		WHERE tabid=@tabid AND cvid=(SELECT cvid FROM ld_customview WHERE entitytype=tmp_modulename AND viewname='All');


		SET @cvid=(SELECT cvid FROM ld_customview WHERE entitytype=tmp_modulename AND viewname='已拒绝');
		DELETE FROM ld_cvadvfilter WHERE cvid=@cvid;
		DELETE FROM ld_cvadvfilter_grouping WHERE cvid=@cvid;
		DELETE FROM ld_tabwithproductview WHERE cvid=@cvid;

		INSERT INTO ld_cvadvfilter(cvid,columnindex,columnname,comparator,value,groupid,column_condition)
		SELECT @cvid,0,CONCAT('ld_',LOWER(tmp_modulename),':','approvestatus',':','approvestatus',':',tmp_modulename,'_fieldlabel:V'),'e','已拒绝',1,'';

		INSERT INTO ld_cvadvfilter_grouping(groupid,cvid,condition_expression)
		SELECT 1,@cvid,0;

		INSERT INTO ld_tabwithproductview(tabid,cvid,sequence,columns)
		SELECT @tabid,@cvid,sequence,columns FROM ld_tabwithproductview 
		WHERE tabid=@tabid AND cvid=(SELECT cvid FROM ld_customview WHERE entitytype=tmp_modulename AND viewname='All');

		DELETE FROM ld_relatedlists WHERE tabid=@tabid;
		SET @i=IFNULL((SELECT MAX(sequence) FROM ld_relatedlists WHERE tabid=@tabid),0);
		SET @maxrelation_id=(SELECT max(relation_id) FROM ld_relatedlists);
		INSERT INTO ld_relatedlists(relation_id,tabid,related_tabid,`name`,sequence,label,presence,actions,related_coltable,type)
		SELECT @maxrelation_id+1,@tabid,'-1','get_SharedUsers',(@i:=@i+1),'SharedUsers',0,'share','','' FROM DUAL
		WHERE NOT EXISTS (SELECT 1 FROM ld_relatedlists WHERE tabid=@tabid AND related_tabid='-1' AND `name`='get_SharedUsers');

		SET @maxrelation_id=(SELECT max(relation_id) FROM ld_relatedlists);
		INSERT INTO ld_relatedlists(relation_id,tabid,related_tabid,`name`,sequence,label,presence,actions,related_coltable,type)
		SELECT @maxrelation_id+1,@tabid,'-7','get_viewhistory',(@i:=@i+1),'ViewHistory',1,'','','' FROM DUAL
		WHERE NOT EXISTS (SELECT 1 FROM ld_relatedlists WHERE tabid=@tabid AND related_tabid='-7' AND `name`='get_viewhistory');

		SET @maxrelation_id=(SELECT max(relation_id) FROM ld_relatedlists);
		INSERT INTO ld_relatedlists(relation_id,tabid,related_tabid,`name`,sequence,label,presence,actions,related_coltable,type)
		SELECT @maxrelation_id+1,@tabid,'-10','get_changeview',(@i:=@i+1),'ChangeView',1,'','','' FROM DUAL
		WHERE NOT EXISTS (SELECT 1 FROM ld_relatedlists WHERE tabid=@tabid AND related_tabid='-10' AND `name`='get_changeview');
		
		UPDATE ld_relatedlists_seq SET id=(SELECT MAX(relation_id) FROM ld_relatedlists);

		
		INSERT INTO ld_def_org_share(tabid,permission,editstatus)
		SELECT @tabid,3,0 FROM DUAL
		WHERE NOT EXISTS (SELECT 1 FROM ld_def_org_share WHERE tabid=@tabid);

		CALL addtabintoprofile(tmp_modulename,1);

		SET @roottype=(SELECT roottype FROM ld_systems_deploy WHERE deploy_type=112);
		SET @seq=(SELECT MAX(sequence) FROM ld_systems_deploy WHERE roottype=@roottype);
		INSERT INTO ld_systems_deploy(deploy_value,deploy_type,description,setype,sequence,roottype,inputtype,presence,inputvalue)
		SELECT 0,tmp_deploy_type,CONCAT(tmp_zhmoudulename,'是否启用审批流程'),tmp_modulename,@seq+1,@roottype,'select',0,'[{"value":"0","text":"YES"},{"value":"1","text":"NO"},{"sql":""}]' FROM DUAL
		WHERE NOT EXISTS (SELECT 1 FROM ld_systems_deploy WHERE deploy_type=tmp_deploy_type);


		SET @approvename=CONCAT(tmp_zhmoudulename,'审批流程');
		SET @approveid=(SELECT MAX(id) FROM ld_approve);
		INSERT INTO ld_approve(id,tabid,`name`,`status`,smcreatorid,modifiedby,createdtime,modifiedtime,approveallocatetype,allowediting,allowantiapproval,finishedallowedit)
		SELECT @approveid+1,@tabid,CONCAT(tmp_zhmoudulename,'审批流程'),0,1,1,now(),now(),0,0,0,'no' FROM DUAL
		WHERE NOT EXISTS (SELECT 1 FROM ld_approve WHERE tabid=@tabid AND `name`=@approvename);

		SET @approveid=(SELECT id FROM ld_approve WHERE tabid=@tabid AND `name`=@approvename);
		SET @maxsetpid=(SELECT MAX(id) FROM ld_approvestep);
		SET @hadinsert=(SELECT COUNT(1) FROM ld_approvestep WHERE approveid=@approveid);
		INSERT INTO ld_approvestep(id,approveid,`name`,ended,step,sequence,createdtime,modifiedtime,approvetype,approvevalue,specifyapproverid)
		SELECT @maxsetpid+1,@approveid,'一级审批',0,1,1,now(),now(),0,1,0 FROM DUAL WHERE @hadinsert=0;

		INSERT INTO ld_approvestep(id,approveid,`name`,ended,step,sequence,createdtime,modifiedtime,approvetype,approvevalue,specifyapproverid)
		SELECT @maxsetpid+2,@approveid,'二级审批',1,1,2,now(),now(),0,1,0 FROM DUAL WHERE @hadinsert=0;

		INSERT INTO ld_approvestep(id,approveid,`name`,ended,step,sequence,createdtime,modifiedtime,approvetype,approvevalue,specifyapproverid)
		SELECT @maxsetpid+3,@approveid,'三级审批',1,1,3,now(),now(),0,1,0 FROM DUAL WHERE @hadinsert=0;

		UPDATE ld_approvestep_seq SET id=(SELECT MAX(id) FROM ld_approvestep);

		SET @stepid=(SELECT id FROM ld_approvestep WHERE approveid=@approveid AND `name`='一级审批');
		INSERT INTO ld_approvereminds(stepid,type,remindmethod,reminduser,remindcontent)
		SELECT @stepid,0,'dialog','approver','有新的单据需要审批，请及时处理！' FROM DUAL
		WHERE NOT EXISTS (SELECT 1 FROM ld_approvereminds WHERE stepid=@stepid AND type=0);

		SET @stepid=(SELECT id FROM ld_approvestep WHERE approveid=@approveid AND `name`='一级审批');
		INSERT INTO ld_approvereminds(stepid,type,remindmethod,reminduser,remindcontent)
		SELECT @stepid,1,'dialog','smowner','您提交的单据已通过审批步骤{step}' FROM DUAL
		WHERE NOT EXISTS (SELECT 1 FROM ld_approvereminds WHERE stepid=@stepid AND type=1);

		SET @stepid=(SELECT id FROM ld_approvestep WHERE approveid=@approveid AND `name`='一级审批');
		INSERT INTO ld_approvereminds(stepid,type,remindmethod,reminduser,remindcontent)
		SELECT @stepid,2,'dialog','smowner','您提交的单据未通过审批步骤{step}，原因：{description}' FROM DUAL
		WHERE NOT EXISTS (SELECT 1 FROM ld_approvereminds WHERE stepid=@stepid AND type=2);

		SET @stepid=(SELECT id FROM ld_approvestep WHERE approveid=@approveid AND `name`='二级审批');
		INSERT INTO ld_approvereminds(stepid,type,remindmethod,reminduser,remindcontent)
		SELECT @stepid,0,'dialog','approver','有新的单据需要审批，请及时处理！' FROM DUAL
		WHERE NOT EXISTS (SELECT 1 FROM ld_approvereminds WHERE stepid=@stepid AND type=0);

		SET @stepid=(SELECT id FROM ld_approvestep WHERE approveid=@approveid AND `name`='二级审批');
		INSERT INTO ld_approvereminds(stepid,type,remindmethod,reminduser,remindcontent)
		SELECT @stepid,1,'dialog','smowner','您提交的单据已通过审批步骤{step}' FROM DUAL
		WHERE NOT EXISTS (SELECT 1 FROM ld_approvereminds WHERE stepid=@stepid AND type=1);

		SET @stepid=(SELECT id FROM ld_approvestep WHERE approveid=@approveid AND `name`='二级审批');
		INSERT INTO ld_approvereminds(stepid,type,remindmethod,reminduser,remindcontent)
		SELECT @stepid,2,'dialog','smowner','您提交的单据未通过审批步骤{step}，原因：{description}' FROM DUAL
		WHERE NOT EXISTS (SELECT 1 FROM ld_approvereminds WHERE stepid=@stepid AND type=2);

		SET @stepid=(SELECT id FROM ld_approvestep WHERE approveid=@approveid AND `name`='三级审批');
		INSERT INTO ld_approvereminds(stepid,type,remindmethod,reminduser,remindcontent)
		SELECT @stepid,0,'dialog','approver','有新的单据需要审批，请及时处理！' FROM DUAL
		WHERE NOT EXISTS (SELECT 1 FROM ld_approvereminds WHERE stepid=@stepid AND type=0);

		SET @stepid=(SELECT id FROM ld_approvestep WHERE approveid=@approveid AND `name`='三级审批');
		INSERT INTO ld_approvereminds(stepid,type,remindmethod,reminduser,remindcontent)
		SELECT @stepid,1,'dialog','smowner','您提交的单据已通过审批步骤{step}' FROM DUAL
		WHERE NOT EXISTS (SELECT 1 FROM ld_approvereminds WHERE stepid=@stepid AND type=1);

		SET @stepid=(SELECT id FROM ld_approvestep WHERE approveid=@approveid AND `name`='三级审批');
		INSERT INTO ld_approvereminds(stepid,type,remindmethod,reminduser,remindcontent)
		SELECT @stepid,2,'dialog','smowner','您提交的单据未通过审批步骤{step}，原因：{description}' FROM DUAL
		WHERE NOT EXISTS (SELECT 1 FROM ld_approvereminds WHERE stepid=@stepid AND type=2);


		
		SET @querysql=CONCAT("CREATE TABLE IF NOT EXISTS `ld_",LOWER(tmp_modulename),"` (
  `",LOWER(tmp_modulename),"id` INT(19) NOT NULL DEFAULT '0',
  `",LOWER(tmp_modulename),"_no` VARCHAR(255) DEFAULT NULL,
  `smownerid` INT(19) DEFAULT NULL,
  `smcreatorid` INT(19) DEFAULT NULL,
  `createdtime` DATETIME DEFAULT NULL,
  `modifiedby` INT(19) DEFAULT NULL,
  `modifiedtime` DATETIME DEFAULT NULL,
  `approvestatus` VARCHAR(50) DEFAULT '未提交',
  `approvetime` DATETIME DEFAULT NULL,
  `approveby` INT(19) DEFAULT NULL,
  `currentapprover` TEXT DEFAULT NULL,
  `print_times` INT(11) DEFAULT '0',
  `total` DECIMAL(25,6) DEFAULT NULL,
  `subtotal` DECIMAL(25,6) DEFAULT NULL,
  `deleted` INT(19) NOT NULL DEFAULT '0',
  PRIMARY KEY (`",LOWER(tmp_modulename),"id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;");

		SET @querysql1=CONCAT("CREATE TABLE IF NOT EXISTS `ld_",LOWER(tmp_modulename),"scf` (
  `",LOWER(tmp_modulename),"id` INT(19) NOT NULL DEFAULT '0',
  PRIMARY KEY (`",LOWER(tmp_modulename),"id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;");

		SET @querysql2=CONCAT("CREATE TABLE IF NOT EXISTS `ld_",LOWER(tmp_modulename),"detail` (
  `lineitem_id` INT(19) NOT NULL AUTO_INCREMENT,
  `id` INT(19) DEFAULT 0,
  `entitytype` varchar(100) DEFAULT NULL,
  `entitytypeid` INT(19) DEFAULT 0,
  `entitytype_value` varchar(100) DEFAULT NULL,
  `amount` DECIMAL(25,2) DEFAULT '0',
  `remark` TEXT DEFAULT NULL,
  `source_total` DECIMAL(25,6) DEFAULT '0',
  `due_date` DATE DEFAULT NULL,
  `cashbilldate` DATE DEFAULT NULL,
  `received_amount` DECIMAL(25,6) DEFAULT '0',
  `sequence` INT(11) DEFAULT NULL,
  PRIMARY KEY (`lineitem_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;");

		SET @querysql3=CONCAT("CREATE TABLE IF NOT EXISTS `ld_",LOWER(tmp_modulename),"detailscf` (
  `lineitem_id` INT(19) NOT NULL DEFAULT '0',
  PRIMARY KEY (`lineitem_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;");

		PREPARE stmt FROM @querysql;
		EXECUTE stmt;

		PREPARE stmt FROM @querysql1;
		EXECUTE stmt;
        
		PREPARE stmt FROM @querysql2;
		EXECUTE stmt;
        
		PREPARE stmt FROM @querysql3;
		EXECUTE stmt;
		DROP PREPARE stmt;
	END IF;

end ||
delimiter;

DROP PROCEDURE IF EXISTS `ldcrm_addcustomform20`;
delimiter ||
CREATE  PROCEDURE `ldcrm_addcustomform20`(
)
BEGIN

	declare i int default 1; 

	SET @maxid=(SELECT MAX(parenttabid) FROM ld_parenttab);
	SET @seq=(SELECT MAX(sequence) FROM ld_parenttab);
	INSERT INTO ld_parenttab(parenttabid,parenttab_label,sequence,visible,allocatetype)
	SELECT @maxid+1,'CustomForms',@seq+1,0,'all' FROM DUAL
	WHERE NOT EXISTS (SELECT 1 FROM ld_parenttab WHERE parenttab_label='CustomForms');

	SET @myparenttabid=(SELECT parenttabid FROM ld_parenttab WHERE parenttab_label='CustomForms');
	INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
	SELECT 'zh','ld_parenttab',@myparenttabid, @myparenttabid,'自定义表单' FROM DUAL
	WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE tabid=@myparenttabid AND relateid=@fieldid AND languagetype='zh' AND trantable='ld_parenttab');
	INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
	SELECT 'en','ld_parenttab',@myparenttabid, @myparenttabid,'Custom Forms' FROM DUAL
	WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE tabid=@myparenttabid AND relateid=@fieldid AND languagetype='en' AND trantable='ld_parenttab');

	WHILE i<=25 DO 
		IF i>=1 AND i<=10 THEN
			CALL ldcrm_addnewmoudule('basic',CONCAT('CustomForm',LPAD(i,2,0)),CONCAT('自定义表单',LPAD(i,2,0)),CONCAT('Custom Form ',LPAD(i,2,0)),@myparenttabid,170+i);
		ELSEIF i>=11 AND i<=20 THEN
			CALL ldcrm_addnewmoudule('productrel',CONCAT('CustomForm',LPAD(i,2,0)),CONCAT('自定义表单',LPAD(i,2,0)),CONCAT('Custom Form ',LPAD(i,2,0)),@myparenttabid,170+i);
		ELSEIF i>=21 AND i<=25 THEN
			CALL ldcrm_addnewmoudule('basicrel',CONCAT('CustomForm',LPAD(i,2,0)),CONCAT('自定义表单',LPAD(i,2,0)),CONCAT('Custom Form ',LPAD(i,2,0)),@myparenttabid,170+i);
		END IF;
		SET i=i+1;
	END WHILE;

end ||
delimiter;

CALL ldcrm_addcustomform20();
DROP PROCEDURE IF EXISTS `ldcrm_addcustomform20`;

DROP PROCEDURE IF EXISTS `ldcrm_resetapprovereminds_20181106`;
delimiter ||
CREATE  PROCEDURE `ldcrm_resetapprovereminds_20181106`(
)
BEGIN

	DECLARE tmp_stepid INT(19) DEFAULT 0; 

	DECLARE MYCUSOR CURSOR FOR SELECT id FROM ld_approvestep;
	DECLARE CONTINUE HANDLER FOR SQLSTATE '02000' SET tmp_stepid = NULL;

	OPEN MYCUSOR; 
	FETCH MYCUSOR INTO tmp_stepid;
	WHILE(tmp_stepid IS NOT NULL) DO
		INSERT INTO ld_approvereminds(stepid,type,remindmethod,reminduser,remindcontent)
		SELECT tmp_stepid,0,'dialog','approver','有新的单据需要审批，请及时处理！' FROM DUAL
		WHERE NOT EXISTS (SELECT 1 FROM ld_approvereminds WHERE stepid=tmp_stepid AND type=0);

		INSERT INTO ld_approvereminds(stepid,type,remindmethod,reminduser,remindcontent)
		SELECT tmp_stepid,1,'dialog','smowner','您提交的单据已通过审批步骤{step}' FROM DUAL
		WHERE NOT EXISTS (SELECT 1 FROM ld_approvereminds WHERE stepid=tmp_stepid AND type=1);

		INSERT INTO ld_approvereminds(stepid,type,remindmethod,reminduser,remindcontent)
		SELECT tmp_stepid,2,'dialog','smowner','您提交的单据未通过审批步骤{step}，原因：{description}' FROM DUAL
		WHERE NOT EXISTS (SELECT 1 FROM ld_approvereminds WHERE stepid=tmp_stepid AND type=2);
		FETCH MYCUSOR INTO tmp_stepid;
	END WHILE;
	CLOSE MYCUSOR;
	
END ||
delimiter;

CALL ldcrm_resetapprovereminds_20181106();
DROP PROCEDURE IF EXISTS `ldcrm_resetapprovereminds_20181106`;
-- 2018-11-09

UPDATE ld_field SET approve_demand=2 WHERE uitype IN (72,5,1,1109,70,15,64,65,52,131,132,560,4,56,
	166,130,11,1101,1102,117,118,13,19,2,21,609,7,71,53,153,154);
UPDATE ld_field SET approve_demand=2 WHERE tabid=6 AND columnname='potentialid' AND displaytype=2;
UPDATE ld_field SET approve_demand=2 WHERE tablename='ld_dividendorder' AND columnname='accountid' AND displaytype=2;

ALTER TABLE ld_field ALTER COLUMN approve_demand SET DEFAULT 2;

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

update ld_version set old_version='V7.5.6',current_version='V7.5.6',remark='V7.5.6-20181109',wx_version='V7.5.5';
delimiter;