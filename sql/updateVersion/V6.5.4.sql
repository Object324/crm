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

update ld_field set typeofdata='V~O',uitype=1,displaytype=2 where columnname='nolinkdays';

select tabid into @tabid from ld_tab where `name` = 'Potentials';
select fieldid into @fieldid from ld_field where tabid = @tabid and columnname = 'allocated_time';
update ld_field set typeofdata = 'D~O' where tabid = @tabid and columnname = 'allocated_time';
update ld_tranlabel set fieldlabel = '分配日期' where tabid = @tabid and Relateid = @fieldid and trantable = 'ld_field' and languagetype ='zh';
update ld_tranlabel set fieldlabel = 'Allocated Date' where tabid = @tabid and Relateid = @fieldid and trantable = 'ld_field' and languagetype ='en';
delimiter;

select tabid into @tabid from ld_tab where `name` = 'VendorContactRecords';
update ld_field set typeofdata = 'V~M' where tabid = @tabid and columnname = 'vendorid' and fieldname = 'vendor_id';
delimiter;

select tabid into @tabid from ld_tab where name = 'ServiceReturn';
delete from ld_profileallpermission where tabid = @tabid and operation=12;

update ld_producttoolfield SET uitype = 163 WHERE columnname in ('taxprice','listprice','productcost');
delimiter;
-- 2016-11-16

alter table ld_potential modify allocated_time DATE;
delimiter;

update ld_field set uitype = 1 where tabid = 2 and columnname = 'staydays';
delimiter;

call AddColumn('ld_projecttask','solution','text','','');
delimiter;

DROP TRIGGER IF EXISTS `update_account_lastservicedate`;
delimiter ||
CREATE TRIGGER `update_account_lastservicedate` AFTER INSERT ON `ld_maxservicedate` FOR EACH ROW BEGIN 

IF NEW.accountid>0 THEN
	update ld_account set lastservicedate=(SELECT max(service_enddate) from ld_maxservicedate where accountid=NEW.accountid) where accountid=NEW.accountid;
END IF;

END ||
delimiter;

update ld_salesorder set nothave_invoicetotal=total-have_invoicetotal where nothave_invoicetotal<>total-have_invoicetotal;
update ld_servicecontracts set nothave_invoicetotal=total-have_invoicetotal where nothave_invoicetotal<>total-have_invoicetotal;
update ld_outboundorder set nothave_invoicetotal=total-have_invoicetotal where nothave_invoicetotal<>total-have_invoicetotal;
update ld_purchaseorder set nothave_invoicetotal=total-have_invoicetotal where nothave_invoicetotal<>total-have_invoicetotal;
update ld_stock set nothave_invoicetotal=total-have_invoicetotal where nothave_invoicetotal<>total-have_invoicetotal;

update ld_backup set backuppath=NULL;
update ld_field set fieldonly=1 where tabid=29 and columnname='wx_userid';

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'zh','ZIDUANLENGTH','字段长度','jspop' from dual 
where not EXISTS(select 1 from ld_desk where languagetype='zh' and labelbol='ZIDUANLENGTH' and Labeltype='jspop'); 
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'en','ZIDUANLENGTH','CharacterLength','jspop' from dual 
where not EXISTS(select 1 from ld_desk where languagetype='en' and labelbol='ZIDUANLENGTH' and Labeltype='jspop'); 
delimiter; 
select usereportid into @usereportid from ld_usereport where `name` = 'CashBillSum_Paymentplan';
update ld_usereportcolumns set realencolumns = 'ld_paymentplan:paymentplan_no:paymentplan_no:PaymentPlan_Paymentplan No:I'
where Usereportid = @usereportid and `columns` = 'ld_paymentplan:paymentplan_no:paymentplan_no:PaymentPlan_paymentplan_no:I';
delimiter;
select usereportid into @usereportid from ld_usereport where `name` = 'SalesSumSequence';
update ld_usereportcolumns set realencolumns = 'ld_servicecontracts:servicecontractstotal:servicecontractstotal:_ServiceContracts Total:N'
where Usereportid = @usereportid and `columns` = 'ld_servicecontracts:servicecontractstotal:servicecontractstotal:oftenusereport_servicecontractstotal:N';
delimiter;
select usereportid into @usereportid from ld_usereport where `name` = 'SalesSumSequence';
update ld_usereportcolumns set realencolumns = 'ld_servicecontracts:servicecontractscount:servicecontractscount:_ServiceContracts Count:N'
where Usereportid = @usereportid and `columns` = 'ld_servicecontracts:servicecontractscount:servicecontractscount:oftenusereport_servicecontractscount:N';
delimiter;
select usereportid into @usereportid from ld_usereport where `name` = 'Salesforecastandanalysistable';
update ld_usereportcolumns set realencolumns = 'ld_potential:potential_no:potential_no:Potentials_Potential No:V'
where Usereportid = @usereportid and `columns` = 'ld_potential:potential_no:potential_no:potentials_potential_no:V';
delimiter;
select usereportid into @usereportid from ld_usereport where `name` = 'Salesforecastandanalysistable';
update ld_usereportcolumns set realencolumns = 'ld_potential:lastsales_stage:lastsales_stage:Potentials_Lastsales_Stage:V'
where Usereportid = @usereportid and `columns` = 'ld_potential:sales_stage:sales_stage:potentials_sales_stage:V';
delimiter;
select usereportid into @usereportid from ld_usereport where `name` = 'Salesforecastandanalysistable';
update ld_usereportcolumns set realencolumns = 'ld_potential:Potentials_smcreatorid:Potentials_smcreatorid:Potentials_Smcreator:V'
where Usereportid = @usereportid and `columns` = 'ld_potential:Potentials_smcreatorid:Potentials_smcreatorid:Potentials_Potentials_smcreatorid:V';
delimiter;
select usereportid into @usereportid from ld_usereport where `name` = 'Salesforecastandanalysistable';
update ld_usereportcolumns set realencolumns = 'ld_potential:productcategory:productcategory:Potentials_Category:V'
where Usereportid = @usereportid and `columns` = 'ld_potential:productcategory:productcategory:Potentials_productcategory:V';
delimiter;
select usereportid into @usereportid from ld_usereport where `name` = 'Salesforecastandanalysistable';
update ld_usereportcolumns set realencolumns = 'ld_potential:total:total:SalesOrder_Order Total:NN'
where Usereportid = @usereportid and `columns` = 'ld_salesorder:total:total:SalesOrder_total:NN';
delimiter;
select usereportid into @usereportid from ld_usereport where `name` = 'Salesforecastandanalysistable';
update ld_usereportcolumns set realencolumns = 'ld_potential:total:total:Potentials_retotal Total:NN'
where Usereportid = @usereportid and `columns` = 'ld_salesorder:retotal:retotal:Potentials_retotal:NN';
delimiter;
select usereportid into @usereportid from ld_usereport where `name` = 'CashBillSum_Paymentplan';
update ld_usereportcolumns set realencolumns = 'ld_paymentplan:actualamount:actualamount:PaymentPlan_Plan Amount Received:V'
where Usereportid = @usereportid and `columns` = 'ld_paymentplan:actualamount:actualamount:PaymentPlan_actualamount:N';
delimiter;

update ld_desk set fieldlabel = '{$ServiceReturn.ServiceReturn}是针对{$HelpDesk.HelpDesk}{$ProjectTask.ProjectTask}的，不允许直接新增'
where labelbol = 'How_to_create_return1' and languagetype = 'zh' and Labeltype = 'fixedstr';
delimiter;
update ld_desk set fieldlabel = '{$ServiceReturn.ServiceReturn} is for the {$HelpDesk.HelpDesk} {$ProjectTask.ProjectTask}, direct creation is not allowed'
where labelbol = 'How_to_create_return1' and languagetype = 'en' and Labeltype = 'fixedstr';
delimiter;

update ld_desk set fieldlabel = '可通过{$HelpDesk.HelpDesk}{$ProjectTask.ProjectTask}查看明细界面，关联创建{$ServiceReturn.ServiceReturn}增加。'
where labelbol = 'How_to_create_return2' and languagetype = 'zh' and Labeltype = 'fixedstr';
delimiter;

update ld_desk set fieldlabel = 'Through the {$HelpDesk.HelpDesk} {$ProjectTask.ProjectTask} view detail interface, associated to create a single {$ServiceReturn.ServiceReturn}.'
where labelbol = 'How_to_create_return2' and languagetype = 'en' and Labeltype = 'fixedstr';

select tabid into @tabid from ld_tab where name = 'SalesOrder';
select max(sequence)+1 into @sequence from ld_field where tabid = @tabid;
insert into ld_field(tabid,fieldid,columnname,tablename,uitype,fieldname,fieldlabel,block,displaytype,presence,typeofdata,sequence)
select @tabid,(select max(fieldid) from ld_field)+1,'lastinvoicedate','ld_salesorder',5,'lastinvoicedate','最新开票日期',(select blockid from ld_blocks where blocklabel = 'LBL_SO_INFORMATION'),2,0,'D~O',@sequence from dual where not exists
(select 1 from ld_field where tabid = @tabid and columnname = 'lastinvoicedate');
delimiter;

select fieldid into @fieldid from ld_field where tabid = @tabid and fieldname = 'lastinvoicedate';
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'zh','ld_field',@tabid,@fieldid,'最新开票日期'
from dual where not EXISTS(select 1 from ld_tranlabel  where languagetype = 'zh'
and trantable ='ld_field' and tabid = @tabid and relateid=@fieldid);
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'en','ld_field',@tabid,@fieldid,'Last Invoice Date'
from dual where not EXISTS(select 1 from ld_tranlabel  where languagetype = 'en'
and trantable ='ld_field' and tabid = @tabid and relateid=@fieldid);
delimiter;

select tabid into @tabid from ld_tab where name = 'ServiceContracts';
select max(sequence)+1 into @sequence from ld_field where tabid = @tabid;
insert into ld_field(tabid,fieldid,columnname,tablename,uitype,fieldname,fieldlabel,block,displaytype,presence,typeofdata,sequence)
select @tabid,(select max(fieldid) from ld_field)+1,'lastinvoicedate','ld_servicecontracts',5,'lastinvoicedate','最新开票日期',(select blockid from ld_blocks where blocklabel = 'LBL_SERVICE_CONTRACT_INFORMATION'),2,0,'D~O',@sequence from dual where not exists
(select 1 from ld_field where tabid = @tabid and columnname = 'lastinvoicedate');
delimiter;

select fieldid into @fieldid from ld_field where tabid = @tabid and fieldname = 'lastinvoicedate';
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'zh','ld_field',@tabid,@fieldid,'最新开票日期'
from dual where not EXISTS(select 1 from ld_tranlabel  where languagetype = 'zh'
and trantable ='ld_field' and tabid = @tabid and relateid=@fieldid);
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'en','ld_field',@tabid,@fieldid,'Last Invoice Date'
from dual where not EXISTS(select 1 from ld_tranlabel  where languagetype = 'en'
and trantable ='ld_field' and tabid = @tabid and relateid=@fieldid);
delimiter;

select tabid into @tabid from ld_tab where name = 'OutBoundOrder';
select max(sequence)+1 into @sequence from ld_field where tabid = @tabid;
insert into ld_field(tabid,fieldid,columnname,tablename,uitype,fieldname,fieldlabel,block,displaytype,presence,typeofdata,sequence)
select @tabid,(select max(fieldid) from ld_field)+1,'lastinvoicedate','ld_outboundorder',5,'lastinvoicedate','最新开票日期',(select blockid from ld_blocks where blocklabel = 'LBL_OUT_INFO'),2,0,'D~O',@sequence from dual where not exists
(select 1 from ld_field where tabid = @tabid and columnname = 'lastinvoicedate');
delimiter;

select fieldid into @fieldid from ld_field where tabid = @tabid and fieldname = 'lastinvoicedate';
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'zh','ld_field',@tabid,@fieldid,'最新开票日期'
from dual where not EXISTS(select 1 from ld_tranlabel  where languagetype = 'zh'
and trantable ='ld_field' and tabid = @tabid and relateid=@fieldid);
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'en','ld_field',@tabid,@fieldid,'Last Invoice Date'
from dual where not EXISTS(select 1 from ld_tranlabel  where languagetype = 'en'
and trantable ='ld_field' and tabid = @tabid and relateid=@fieldid);
delimiter;

select tabid into @tabid from ld_tab where name = 'PurchaseOrder';
select max(sequence)+1 into @sequence from ld_field where tabid = @tabid;
insert into ld_field(tabid,fieldid,columnname,tablename,uitype,fieldname,fieldlabel,block,displaytype,presence,typeofdata,sequence)
select @tabid,(select max(fieldid) from ld_field)+1,'lastinvoicedate','ld_purchaseorder',5,'lastinvoicedate','最新开票日期',(select blockid from ld_blocks where blocklabel = 'LBL_PO_INFORMATION'),2,0,'D~O',@sequence from dual where not exists
(select 1 from ld_field where tabid = @tabid and columnname = 'lastinvoicedate');
delimiter;

select fieldid into @fieldid from ld_field where tabid = @tabid and fieldname = 'lastinvoicedate';
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'zh','ld_field',@tabid,@fieldid,'最新开票日期'
from dual where not EXISTS(select 1 from ld_tranlabel  where languagetype = 'zh'
and trantable ='ld_field' and tabid = @tabid and relateid=@fieldid);
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'en','ld_field',@tabid,@fieldid,'Last Invoice Date'
from dual where not EXISTS(select 1 from ld_tranlabel  where languagetype = 'en'
and trantable ='ld_field' and tabid = @tabid and relateid=@fieldid);
delimiter;

select tabid into @tabid from ld_tab where name = 'Stock';
select max(sequence)+1 into @sequence from ld_field where tabid = @tabid;
insert into ld_field(tabid,fieldid,columnname,tablename,uitype,fieldname,fieldlabel,block,displaytype,presence,typeofdata,sequence)
select @tabid,(select max(fieldid) from ld_field)+1,'lastinvoicedate','ld_stock',5,'lastinvoicedate','最新开票日期',(select blockid from ld_blocks where blocklabel = 'LBL_WARE_INFO'),2,0,'D~O',@sequence from dual where not exists
(select 1 from ld_field where tabid = @tabid and columnname = 'lastinvoicedate');
delimiter;

select fieldid into @fieldid from ld_field where tabid = @tabid and fieldname = 'lastinvoicedate';
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'zh','ld_field',@tabid,@fieldid,'最新开票日期'
from dual where not EXISTS(select 1 from ld_tranlabel  where languagetype = 'zh'
and trantable ='ld_field' and tabid = @tabid and relateid=@fieldid);
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'en','ld_field',@tabid,@fieldid,'Last Invoice Date'
from dual where not EXISTS(select 1 from ld_tranlabel  where languagetype = 'en'
and trantable ='ld_field' and tabid = @tabid and relateid=@fieldid);
delimiter;
-- 2016-11-17

select tabid into @tabid from ld_tab where `name`='OutboundOrder';
select block into @blockid from ld_field where tabid=@tabid and columnname='out_no';
select max(sequence) into @seq from ld_field where tabid=@tabid and block=@blockid;

update ld_field set sequence=@seq+1 where tabid=@tabid and block=@blockid and columnname='received_amount';
update ld_field set sequence=@seq+2 where tabid=@tabid and block=@blockid and columnname='receivable_balance';
update ld_field set sequence=@seq+3 where tabid=@tabid and block=@blockid and columnname='cashbilldate';
update ld_field set sequence=@seq+4 where tabid=@tabid and block=@blockid and columnname='have_invoicetotal';
update ld_field set sequence=@seq+5 where tabid=@tabid and block=@blockid and columnname='nothave_invoicetotal';
update ld_field set sequence=@seq+6 where tabid=@tabid and block=@blockid and columnname='lastinvoicedate';
update ld_field set sequence=@seq+7 where tabid=@tabid and block=@blockid and columnname='lastinvoice_no';

select fieldid into @fieldid from ld_field where tabid=@tabid and columnname='cashbilldate';
update ld_tranlabel set fieldlabel='最新收款日期' where trantable='ld_field' and languagetype='zh' and Relateid=@fieldid;

select fieldid into @fieldid from ld_field where tabid=@tabid and columnname='lastinvoice_no';
update ld_tranlabel set fieldlabel='最新发票号' where trantable='ld_field' and languagetype='zh' and Relateid=@fieldid;

set @i=0;
update ld_field set sequence=(@i:=@i+1) where tabid=@tabid and block=@blockid order by sequence;
delimiter;

select tabid into @tabid from ld_tab where `name`='stock';
select block into @blockid from ld_field where tabid=@tabid and columnname='ware_stock_no';
select max(sequence) into @seq from ld_field where tabid=@tabid and block=@blockid;

update ld_field set sequence=@seq+1 where tabid=@tabid and block=@blockid and columnname='stockpresence';
update ld_field set sequence=@seq+2 where tabid=@tabid and block=@blockid and columnname='pay_amount';
update ld_field set sequence=@seq+3 where tabid=@tabid and block=@blockid and columnname='pay_balance';
update ld_field set sequence=@seq+4 where tabid=@tabid and block=@blockid and columnname='sendcashbilldate';
update ld_field set sequence=@seq+5 where tabid=@tabid and block=@blockid and columnname='have_invoicetotal';
update ld_field set sequence=@seq+6 where tabid=@tabid and block=@blockid and columnname='nothave_invoicetotal';
update ld_field set sequence=@seq+7 where tabid=@tabid and block=@blockid and columnname='lastinvoicedate';
update ld_field set sequence=@seq+8 where tabid=@tabid and block=@blockid and columnname='lastinvoice_no';

select fieldid into @fieldid from ld_field where tabid=@tabid and columnname='sendcashbilldate';
update ld_tranlabel set fieldlabel='最新付款日期' where trantable='ld_field' and languagetype='zh' and Relateid=@fieldid;

select fieldid into @fieldid from ld_field where tabid=@tabid and columnname='lastinvoice_no';
update ld_tranlabel set fieldlabel='最新发票号' where trantable='ld_field' and languagetype='zh' and Relateid=@fieldid;

set @i=0;
update ld_field set sequence=(@i:=@i+1) where tabid=@tabid and block=@blockid order by sequence;
delimiter;

select tabid into @tabid from ld_tab where `name`='PurchaseOrder';
select block into @blockid from ld_field where tabid=@tabid and columnname='purchaseorder_no';
select max(sequence) into @seq from ld_field where tabid=@tabid and block=@blockid;

update ld_field set sequence=@seq+2 where tabid=@tabid and block=@blockid and columnname='pay_amount';
update ld_field set sequence=@seq+3 where tabid=@tabid and block=@blockid and columnname='pay_balance';
update ld_field set sequence=@seq+4 where tabid=@tabid and block=@blockid and columnname='sendcashbilldate';
update ld_field set sequence=@seq+5 where tabid=@tabid and block=@blockid and columnname='have_invoicetotal';
update ld_field set sequence=@seq+6 where tabid=@tabid and block=@blockid and columnname='nothave_invoicetotal';
update ld_field set sequence=@seq+7 where tabid=@tabid and block=@blockid and columnname='lastinvoicedate';
update ld_field set sequence=@seq+8 where tabid=@tabid and block=@blockid and columnname='lastinvoice_no';

select fieldid into @fieldid from ld_field where tabid=@tabid and columnname='sendcashbilldate';
update ld_tranlabel set fieldlabel='最新付款日期' where trantable='ld_field' and languagetype='zh' and Relateid=@fieldid;

select fieldid into @fieldid from ld_field where tabid=@tabid and columnname='lastinvoice_no';
update ld_tranlabel set fieldlabel='最新发票号' where trantable='ld_field' and languagetype='zh' and Relateid=@fieldid;

set @i=0;
update ld_field set sequence=(@i:=@i+1) where tabid=@tabid and block=@blockid order by sequence;
delimiter;

select tabid into @tabid from ld_tab where `name`='SalesOrder';
select block into @blockid from ld_field where tabid=@tabid and columnname='salesorder_no';
select max(sequence) into @seq from ld_field where tabid=@tabid and block=@blockid;

update ld_field set sequence=@seq+2 where tabid=@tabid and block=@blockid and columnname='received_amount';
update ld_field set sequence=@seq+3 where tabid=@tabid and block=@blockid and columnname='receivable_balance';
update ld_field set sequence=@seq+4 where tabid=@tabid and block=@blockid and columnname='cashbilldate';
update ld_field set sequence=@seq+5 where tabid=@tabid and block=@blockid and columnname='have_invoicetotal';
update ld_field set sequence=@seq+6 where tabid=@tabid and block=@blockid and columnname='nothave_invoicetotal';
update ld_field set sequence=@seq+7 where tabid=@tabid and block=@blockid and columnname='lastinvoicedate';
update ld_field set sequence=@seq+8 where tabid=@tabid and block=@blockid and columnname='lastinvoice_no';

select fieldid into @fieldid from ld_field where tabid=@tabid and columnname='cashbilldate';
update ld_tranlabel set fieldlabel='最新收款日期' where trantable='ld_field' and languagetype='zh' and Relateid=@fieldid;

select fieldid into @fieldid from ld_field where tabid=@tabid and columnname='lastinvoice_no';
update ld_tranlabel set fieldlabel='最新发票号' where trantable='ld_field' and languagetype='zh' and Relateid=@fieldid;

set @i=0;
update ld_field set sequence=(@i:=@i+1) where tabid=@tabid and block=@blockid order by sequence;
delimiter;

select tabid into @tabid from ld_tab where `name`='Invoice';
select block into @blockid from ld_field where tabid=@tabid and columnname='accountid';
select max(sequence) into @seq from ld_field where tabid=@tabid and block=@blockid;

update ld_field set sequence=@seq+1 where tabid=@tabid and block=@blockid and columnname='stockpresence';
update ld_field set sequence=@seq+2 where tabid=@tabid and block=@blockid and columnname='received_amount';
update ld_field set sequence=@seq+3 where tabid=@tabid and block=@blockid and columnname='receivable_balance';
update ld_field set sequence=@seq+4 where tabid=@tabid and block=@blockid and columnname='cashbilldate';

select fieldid into @fieldid from ld_field where tabid=@tabid and columnname='cashbilldate';
update ld_tranlabel set fieldlabel='最新收款日期' where trantable='ld_field' and languagetype='zh' and Relateid=@fieldid;

select fieldid into @fieldid from ld_field where tabid=@tabid and columnname='lastinvoice_no';
update ld_tranlabel set fieldlabel='最新发票号' where trantable='ld_field' and languagetype='zh' and Relateid=@fieldid;

set @i=0;
update ld_field set sequence=(@i:=@i+1) where tabid=@tabid and block=@blockid order by sequence;
delimiter;

select tabid into @tabid from ld_tab where `name`='PurchaseInvoice';
select block into @blockid from ld_field where tabid=@tabid and columnname='vendorid';
select max(sequence) into @seq from ld_field where tabid=@tabid and block=@blockid;

update ld_field set sequence=@seq+1 where tabid=@tabid and block=@blockid and columnname='stockpresence';
update ld_field set sequence=@seq+2 where tabid=@tabid and block=@blockid and columnname='pay_amount';
update ld_field set sequence=@seq+3 where tabid=@tabid and block=@blockid and columnname='pay_balance';
update ld_field set sequence=@seq+4 where tabid=@tabid and block=@blockid and columnname='sendcashbilldate';

select fieldid into @fieldid from ld_field where tabid=@tabid and columnname='sendcashbilldate';
update ld_tranlabel set fieldlabel='最新付款日期' where trantable='ld_field' and languagetype='zh' and Relateid=@fieldid;

select fieldid into @fieldid from ld_field where tabid=@tabid and columnname='lastinvoice_no';
update ld_tranlabel set fieldlabel='最新发票号' where trantable='ld_field' and languagetype='zh' and Relateid=@fieldid;

set @i=0;
update ld_field set sequence=(@i:=@i+1) where tabid=@tabid and block=@blockid order by sequence;
delimiter;

select tabid into @tabid from ld_tab where `name`='PaymentPlan';
select block into @blockid from ld_field where tabid=@tabid and columnname='accountid';
select sequence into @seq from ld_field where tabid=@tabid and block=@blockid and columnname='actualamount';
update ld_field set sequence=sequence+10 where tabid=@tabid and block=@blockid and sequence>@seq;

update ld_field set sequence=@seq+1 where tabid=@tabid and block=@blockid and columnname='actualamount';
update ld_field set sequence=@seq+2 where tabid=@tabid and block=@blockid and columnname='receivable_balance';
update ld_field set sequence=@seq+3 where tabid=@tabid and block=@blockid and columnname='actualdate';

select fieldid into @fieldid from ld_field where tabid=@tabid and columnname='actualdate';
update ld_tranlabel set fieldlabel='最新收款日期' where trantable='ld_field' and languagetype='zh' and Relateid=@fieldid;

set @i=0;
update ld_field set sequence=(@i:=@i+1) where tabid=@tabid and block=@blockid order by sequence;
delimiter;

select tabid into @tabid from ld_tab where `name`='SendPayment';
select block into @blockid from ld_field where tabid=@tabid and columnname='vendorid';
select sequence into @seq from ld_field where tabid=@tabid and block=@blockid and columnname='actualamount';
update ld_field set sequence=sequence+10 where tabid=@tabid and block=@blockid and sequence>@seq;

update ld_field set sequence=@seq+1 where tabid=@tabid and block=@blockid and columnname='actualamount';
update ld_field set sequence=@seq+2 where tabid=@tabid and block=@blockid and columnname='pay_balance';
update ld_field set sequence=@seq+3 where tabid=@tabid and block=@blockid and columnname='actualdate';

select fieldid into @fieldid from ld_field where tabid=@tabid and columnname='actualdate';
update ld_tranlabel set fieldlabel='最新付款日期' where trantable='ld_field' and languagetype='zh' and Relateid=@fieldid;

set @i=0;
update ld_field set sequence=(@i:=@i+1) where tabid=@tabid and block=@blockid order by sequence;
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

select usereportid into @usereportid from ld_usereport where `name` = 'SalesOrderTrack';
update ld_usereportcolumns set realencolumns = 'ld_crmentity:createdtime:createdtime:SalesOrder _CreatedTime:DT'
where Usereportid = @usereportid and `columns` = 'ld_crmentity:createdtime:createdtime:SalesOrder_CreatedTime:DT';
delimiter;
select usereportid into @usereportid from ld_usereport where `name` = 'SalesOrderTrack';
update ld_usereportcolumns set realencolumns = 'ld_salesorder:subject:subject:SalesOrder _Subject:V'
where Usereportid = @usereportid and `columns` = 'ld_salesorder:subject:subject:SalesOrder_Subject:V';
delimiter;
select usereportid into @usereportid from ld_usereport where `name` = 'SIGNINSTATISTICS';
update ld_usereportcolumns set realencolumns = 'ld_accounts:accountname:accountname:OftenUseReport_Sign in Customer:V'
where Usereportid = @usereportid and `columns` = 'ld_accounts:accountname:accountname:OftenUseReport_签到客户:V';
delimiter;
select usereportid into @usereportid from ld_usereport where `name` = 'SIGNINSTATISTICS';
update ld_usereportcolumns set realencolumns = 'ld_singin:address:address:OftenUseReport_Sign in Address:V'
where Usereportid = @usereportid and `columns` = 'ld_singin:address:address:OftenUseReport_签到地址:V';
delimiter;

SET GLOBAL event_scheduler = on;
DROP EVENT IF EXISTS `insert_tmp_date`;
CREATE EVENT `insert_tmp_date`
ON SCHEDULE EVERY 700 DAY STARTS '2016-10-14 00:30:00'
ON COMPLETION NOT PRESERVE
ENABLE
DO

call insert_tmp_date();
delimiter;

DROP EVENT IF EXISTS `update_potential_staydays`;
CREATE EVENT `update_potential_staydays`
ON SCHEDULE EVERY 1 DAY STARTS '2016-09-01 00:30:00'
ON COMPLETION NOT PRESERVE
ENABLE
DO

update 
ld_potential a
LEFT JOIN (
	select 
		potentialid,max(lastmodified) as lastmodified
	from ld_potstagehistory 
	where stage<>sales_stage 
	GROUP BY potentialid) b on a.potentialid=b.potentialid
set a.staydays=datediff(NOW(),ifnull(b.lastmodified,a.createdtime));
delimiter;

update 
ld_potential a
LEFT JOIN (
	select 
		potentialid,max(lastmodified) as lastmodified
	from ld_potstagehistory 
	where stage<>sales_stage 
	GROUP BY potentialid) b on a.potentialid=b.potentialid
set a.staydays=datediff(NOW(),ifnull(b.lastmodified,a.createdtime));
-- 2016-11-18

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

update ld_version set old_version='V6.5.4' ,current_version='V6.5.4' ,remark='V6.5.4-20161118';
delimiter;