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

update ld_tabdetailfield set newline=0 where (columnname='entitytype' or columnname='entitytypeid' ) and tablename='ld_cashbill2paymentplan';
delimiter;

select tabid into @tabid from ld_tab where `name` = 'PurchaseOrder';
update ld_tab set mobilepresence='mobile' where tabid=@tabid;
insert into ld_appparenttabrel(blockid,tabid,sequence)
select 5,@tabid,4 from DUAL
where not exists(select 1 from ld_appparenttabrel where blockid = 5 and tabid=@tabid);
delimiter;

select max(minusjobtypeid) into @id from ld_minusjobtype;
insert into ld_minusjobtype (minusjobtypeid,minusjobtype,presence)
select @id+1,'迟到',1 from dual where not exists (select 1 from ld_minusjobtype where minusjobtype='迟到');

select max(minusjobtypeid) into @id from ld_minusjobtype;
insert into ld_minusjobtype (minusjobtypeid,minusjobtype,presence)
select @id+1,'早退',1 from dual where not exists (select 1 from ld_minusjobtype where minusjobtype='早退');
delimiter;

update ld_minusjobtype set Picklist_valueid=Picklist_valueid+10;
update ld_minusjobtype set Picklist_valueid=1 where minusjobtype='调休';
update ld_minusjobtype set Picklist_valueid=2 where minusjobtype='年假';
update ld_minusjobtype set Picklist_valueid=3 where minusjobtype='事假';
update ld_minusjobtype set Picklist_valueid=4 where minusjobtype='迟到';
update ld_minusjobtype set Picklist_valueid=5 where minusjobtype='早退';

set @i=0;
update ld_minusjobtype set Picklist_valueid=(@i:=@i+1) ORDER BY Picklist_valueid;
delimiter;
-- 2017-06-14

select tabid into @tabid from ld_tab where `name` = 'InventoryQuery';
delete from ld_tranlabel where trantable = 'ld_field' and tabid = @tabid and Relateid in (select fieldid from ld_field where tabid = @tabid and columnname = 'qtyinstock');
delete from ld_field where tabid = @tabid and columnname = 'qtyinstock';
select blockid into @blockid from ld_blocks where blocklabel = 'LBL_INVENTORYQUERY_INFO';
select max(fieldid) into @max_fieldid from ld_field;
insert ld_field(tabid,fieldid,columnname,allowhide,tablename,generatedtype,uitype,fieldname,fieldlabel,readonly,presence,block,displaytype,typeofdata,quickcreate)
select @tabid,@max_fieldid+1,'qtyinstock','yes','ld_products',1,166,'qtyinstock','安全库存差额',1,0,@blockid,1,'V~M',3 from DUAL
where not exists(select 1 from ld_field where tabid = @tabid and columnname = 'qtyinstock');
select fieldid into @fieldid from ld_field where tabid = @tabid and columnname = 'qtyinstock';
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'zh','ld_field',@tabid,@fieldid,'安全库存差额' from DUAL
where not exists(select 1 from ld_tranlabel where tabid = @tabid and relateid = @fieldid and trantable = 'ld_field' and languagetype = 'zh');
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'en','ld_field',@tabid,@fieldid,'Safe Stock Balance' from DUAL
where not exists(select 1 from ld_tranlabel where tabid = @tabid and relateid = @fieldid and trantable = 'ld_field' and languagetype = 'en');
delimiter;
-- 2017-06-15

call AddColumn('ld_appparenttab','parenttab_label','varchar','255',null);
delimiter;

update ld_appparenttab set parenttab_label='Accounts' where blockid=1 and parenttab_label is NULL;
update ld_appparenttab set parenttab_label='Sales' where blockid=2 and parenttab_label is NULL;
update ld_appparenttab set parenttab_label='Service' where blockid=3 and parenttab_label is NULL;
update ld_appparenttab set parenttab_label='OAForms' where blockid=4 and parenttab_label is NULL;
update ld_appparenttab set parenttab_label='Purchase' where blockid=5 and parenttab_label is NULL;

insert into ld_appparenttab(blockname,presence,systemdefault,parenttab_label)
select '项目管理',0,'yes','Project' from dual 
where not exists (select 1 from ld_appparenttab where parenttab_label='Project');

update ld_appparenttab set blockname='采购管理' where parenttab_label='Purchase' and blockname='供应商管理';

select sequence into @seq from ld_appparenttab where parenttab_label='Service' limit 1;
update ld_appparenttab set sequence=sequence+1 where sequence>@seq;
update ld_appparenttab set sequence=@seq+1 where parenttab_label='Project';

set @i=0;
update ld_appparenttab set sequence=(@i:=@i+1) order by sequence;
delimiter;

set @tabid=48;
select blockid into @blockid from ld_appparenttab where parenttab_label='Project' limit 1;
insert into ld_appparenttabrel(blockid,tabid,sequence)
select @blockid,@tabid,1 from dual where not exists (select 1 from ld_appparenttabrel where blockid=@blockid and tabid=@tabid);

set @tabid=47;
select blockid into @blockid from ld_appparenttab where parenttab_label='Project';
insert into ld_appparenttabrel(blockid,tabid,sequence)
select @blockid,@tabid,2 from dual where not exists (select 1 from ld_appparenttabrel where blockid=@blockid and tabid=@tabid);
delimiter;

select blockid into @blockid from ld_appparenttab where parenttab_label='Service' limit 1;
delete from ld_appparenttabrel where blockid=@blockid and tabid in (47,48);
delimiter;

insert into ld_links(linktype,linklabel,linkurl,description)
select 'Settings','TemplateprintList','http://www.51mis.com.cn/forum.php?mod=viewthread&tid=1&extra=','打印模板定制列表' from DUAL
where not exists(select 1 from ld_links where linktype = 'Settings' and linklabel = 'TemplateprintList');
delimiter;

insert into ld_links(linktype,linklabel,linkurl,description)
select 'Settings','createtemplatePrint','http://www.51mis.com.cn/forum.php?mod=viewthread&tid=1&extra=','打印模板新增' from DUAL
where not exists(select 1 from ld_links where linktype = 'Settings' and linklabel = 'createtemplatePrint');
delimiter;

insert into ld_links(linktype,linklabel,linkurl,description)
select 'Settings','publicAccountSet','http://www.51mis.com.cn/forum.php?mod=viewthread&tid=1&extra=','公海参数设置' from DUAL
where not exists(select 1 from ld_links where linktype = 'Settings' and linklabel = 'publicAccountSet');
delimiter;

insert into ld_links(tabid,linktype,linklabel,linkurl,description)
select 6,'Allocate','averageDistribution','http://www.51mis.com.cn/forum.php?mod=viewthread&tid=1&extra=','平均分配' from DUAL
where not exists(select 1 from ld_links where tabid = 6 and linktype = 'Allocate' and linklabel = 'averageDistribution');
delimiter;

update ld_desk set fieldlabel = '只统计已审批的{$Expense.Expense}和{$Commission.Commission}' where languagetype = 'zh' and labelbol = 'EXCOMMTOTAL' and Labeltype = 'fixedstr';
update ld_desk set fieldlabel = 'Only statistics are approved for {$Expense.Expense} and {$Commission.Commission}' where languagetype = 'en' and labelbol = 'EXCOMMTOTAL' and Labeltype = 'fixedstr';
delimiter;
select usereportid into @usereportid from ld_usereport where `name` = 'Performancestatisticscollection';
select max(Sequence) into @Sequence from ld_usereportbasic  where usereportid=@usereportid;
insert into ld_usereportbasic(Usereportid,columns,Defaultvalue,Sequence)
select @usereportid,'ld_expense:approvestatus:approvestatus:Expense_approvestatus:I','',@Sequence from DUAL
where not exists(select 1 from ld_usereportbasic where Usereportid = @usereportid and `columns` = 'ld_expense:approvestatus:approvestatus:Expense_approvestatus:I');
delimiter;

select usereportid into @reportid from ld_usereport where `name`='SalesOrderTrack';
set @zh='ld_salesorder:stockpresence:stockpresence:SalesOrder_出库状态:V';
set @en='ld_salesorder:stockpresence:stockpresence:SalesOrder_stockpresence:V';
insert into ld_usereportcolumns(Usereportid,`columns`,columnshow,realcolumns,realencolumns)
select @reportid,'ld_salesorder:stockpresence:stockpresence:salesorder_stockpresence:V',1,@zh,@en from dual 
where not exists (select 1 from ld_usereportcolumns where `columns` like 'ld_salesorder:stockpresence:stockpresence%');

select Sequence into @seq from ld_usereportcolumns where Usereportid=@reportid and `columns` like 'ld_salesorder:salesorder_no:salesorder_no%' limit 1;
update ld_usereportcolumns set sequence=sequence+1 where Usereportid=@reportid and sequence>@seq;
update ld_usereportcolumns set sequence=@seq+1 where Usereportid=@reportid and `columns` like 'ld_salesorder:stockpresence:stockpresence%';

set @i=0;
update ld_usereportcolumns set sequence=(@i:=@i+1) where Usereportid=@reportid order by sequence;
delimiter;


select tabid into @tabid from ld_tab where `name`='ServiceContracts';
select block into @blockid from ld_field where tabid=@tabid and columnname='smownerid';
select tablename into @tablename from ld_field where tabid=@tabid and columnname='smownerid';
set @columnname='stockpresence';
set @fieldname='stockpresence';
set @zh='出库状态';
set @en='Stock Presence';
set @uitype=1;
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

call AddColumn(@tablename,@columnname,'varchar','50','');
delimiter;

call getallprofile('ServiceContracts');
delimiter;
call fieldprofile('ServiceContracts');
delimiter;


call AddColumn('ld_servicecontracts','stockpresence','varchar','50','');
delimiter;

ALTER TABLE ld_servicecontracts ALTER COLUMN stockpresence SET DEFAULT '未出库';
delimiter;
-- 2017-06-15

update ld_servicecontracts set stockpresence='未出库' where stockpresence is NULL;
update ld_servicecontracts set stockpresence='未出库' where stockpresence ='';
UPDATE (
	SELECT
		b.entitytypeid
	FROM ld_outboundorder a
	LEFT JOIN ld_inventoryproductrel b ON a.out_id=b.id
	WHERE a.deleted=0
		AND a.approvestatus<>'已拒绝'
		AND b.entitytype='ServiceContracts'
	GROUP BY b.entitytypeid
) a
LEFT JOIN ld_servicecontracts b ON a.entitytypeid=b.servicecontractsid
LEFT JOIN (
	SELECT 
		id,
		SUM(quantity) AS quantity,
		SUM(balanceoutproductcount) AS balanceoutproductcount,
		SUM(haveoutproductcount) AS haveoutproductcount 
	FROM ld_inventoryproductrel 
	GROUP BY id
) c ON c.id=a.entitytypeid
SET b.stockpresence=(
	CASE
		WHEN c.haveoutproductcount=0 THEN '未出库'
		WHEN c.balanceoutproductcount>0 AND c.haveoutproductcount>0 THEN '部分出库'
		ELSE '全部出库'
	END)
WHERE b.stockpresence='未出库';

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) 
select 'zh','THISDOCUMENTHASBEENSHIPPEDTOZERO','该单据已入库数量为零，请审核{$Stock.Stock}！','jspop' from dual 
where not exists(select 1 from ld_desk where languagetype = 'zh' and labelbol = 'THISDOCUMENTHASBEENSHIPPEDTOZERO' and labeltype = 'jspop'); 
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) 
select 'en','THISDOCUMENTHASBEENSHIPPEDTOZERO','This document has been shipped to zero, please check {$Stock.Stock}','jspop' from dual 
where not exists(select 1 from ld_desk where languagetype = 'en' and labelbol = 'THISDOCUMENTHASBEENSHIPPEDTOZERO' and labeltype = 'jspop');
delimiter;

update ld_tabdetailfield set edit_permission=0 where tabid in(select tabid from ld_tab where name='cashbill');
update ld_tabdetailfield set edit_permission=0 where tabid in(select tabid from ld_tab where name='sendcashbill');
delimiter;
-- 2017-06-16


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

update ld_version set old_version='V7.0.2',current_version='V7.0.2',remark='V7.0.2-20170616';
delimiter;