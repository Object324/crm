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
		ELSEIF isdefault=0 THEN
			SET @alterColumn=CONCAT(' alter table ',tablename, ' add column ',columnname, ' ',columntype, ' default 0 ');
		ELSE
			 SET @alterColumn=CONCAT(' alter table ',tablename, ' add column ',columnname, ' ',columntype,'(',columnlen,')');
		END IF;
	PREPARE stalter FROM @altercolumn;
		EXECUTE stalter;
	END IF;
END ||
delimiter;

DROP PROCEDURE IF EXISTS `DelColumn`;
delimiter ||
CREATE  PROCEDURE `DelColumn`(
-- tableschema varchar(50),
tablename varchar(50),
columnname varchar(50)
)
begin

set @tableschema=NULL;
set @tsql=NULL;
set @coladd=-1;
set @alterColumn=NULL;
set @colName=NULL;

select database() into @tableschema;

set tablename=lower(tablename);

SET @tsql=CONCAT('select  IFNULL(column_name, '''') into @colName  from information_schema.columns where  TABLE_SCHEMA =','''',@tableschema,'''','  and  table_name= ','''',tablename,'''',' and COLUMN_NAME=','''',columnname,'''');

prepare stmt from @tsql;
execute stmt;


set @coladd=IFNULL(@colName,'-1');

IF @coladd <> '-1'  and @coladd=columnname THEN
	set @alterColumn=CONCAT(' alter table ',tablename, ' drop ',columnname);
	prepare stalter from @altercolumn;
	execute stalter;
	deallocate prepare stalter;
END IF;
deallocate prepare stmt;
end ||
delimiter;

DROP PROCEDURE IF EXISTS `del_idx`;
delimiter ||
CREATE  PROCEDURE `del_idx`(
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

select tabid into @tabid from ld_tab where `name` = 'Contacts';
delete from ld_field where tabid = @tabid and fieldname = 'contact_id' and columnname = 'reportsto';
delimiter;

update ld_cvcolumnlist set columnname = 'LD_faq:answer:faq_answer:Faq_fieldlabel:V' where columnname like '%LD_faq:answer:faq_answer:%';
delimiter;

update ld_blocks set create_view = 0 where tabid = 15 and blockid = 38;
delimiter;

select tabid into @accounttabid from ld_tab where name = 'Accounts';
select tabid into @potentialsid from ld_tab where name = 'Potentials';
select sequence into @sequence from ld_relatedlists where tabid = @potentialsid and label = 'Contacts';
UPDATE ld_relatedlists set sequence=sequence+1 where sequence >= @sequence and tabid=@potentialsid;
SELECT max(relation_id) into @relation_id from ld_relatedlists;
insert into ld_relatedlists(relation_id,tabid,related_tabid,name,sequence,label,actions)
select @relation_id+1,@potentialsid,@accounttabid,'get_accounts',@sequence,'Accounts','add,select' from dual 
where not EXISTS(select 1 from ld_relatedlists  where tabid=@potentialsid and related_tabid=@accounttabid);
update ld_relatedlists_seq set id=(select max(relation_id) from ld_relatedlists);
delimiter;

CREATE TABLE IF NOT EXISTS `ld_accountpotentialrel` (
  `accountid` int(19) NOT NULL DEFAULT '0',
  `potentialid` int(19) NOT NULL DEFAULT '0',
  PRIMARY KEY (`accountid`,`potentialid`),
  KEY `accountpotentialrel_potentialid_idx` (`potentialid`) USING BTREE,
  KEY `accountpotentialrel_accountid_idx` (`accountid`) USING BTREE,
  CONSTRAINT `ld_accountpotentialrel_ibfk_1` FOREIGN KEY (`potentialid`) REFERENCES `ld_potential` (`potentialid`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
delimiter;

select tabid into @tabid from ld_tab where `name`= 'BankAccountSet';
select sequence,block into @sequence,@block from ld_field where tabid = @tabid and fieldname = 'initmoney';
select max(fieldid) into @fieldid from ld_field;
insert into ld_field(tabid,fieldid,columnname,tablename,uitype,fieldname,fieldlabel,block,displaytype,presence,typeofdata,readonly,sequence,masseditable,info_type)
select @tabid,@fieldid+1,'currency_id','LD_bankaccountset',117,'currency_id','币种',@block,1,0,'I~O',1,@sequence,1,'BAS' from dual where not exists
(select * from ld_field where tabid = @tabid and columnname = 'currency_id');
update ld_field set sequence = sequence +1 where tabid = @tabid and sequence >=@sequence and columnname != 'currency_id';
delimiter;

select tabid into @tabid from ld_tab where `name`= 'BankAccountSet';
select fieldid into @fieldid from ld_field where tabid = @tabid and columnname = 'currency_id';
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'zh','LD_field',@tabid,@fieldid,'币种'
from dual where not EXISTS(select 1 from ld_tranlabel  where languagetype = 'zh'
and trantable ='LD_field' and tabid = @tabid and relateid=@fieldid);
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'en','LD_field',@tabid,@fieldid,'Currency'
from dual where not EXISTS(select 1 from ld_tranlabel  where languagetype = 'en'
and trantable ='LD_field' and tabid = @tabid and relateid=@fieldid);
delimiter;

CALL AddColumn('LD_bankaccountset','currency_symbol','varchar','30',null);
ALTER TABLE `LD_bankaccountset` CHANGE `currency_symbol` `currency_symbol` VARCHAR(30) AFTER `conversion_rate`;
delimiter;

INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
	SELECT 'zh','UPDATEBANKCURRENCY','确认后币种和初始金额不可再更改，是否继续?','jspop'
		FROM DUAL WHERE NOT EXISTS
	(SELECT 1 FROM ld_desk  WHERE languagetype='zh' AND
		labelbol='UPDATEBANKCURRENCY' AND Labeltype='jspop');

INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
	SELECT 'en','UPDATEBANKCURRENCY','After confirming the currency and initial amount can not be changed, whether to continue?','jspop'
	FROM DUAL WHERE NOT EXISTS
	(SELECT 1 FROM ld_desk  WHERE languagetype='en' AND
		labelbol='UPDATEBANKCURRENCY' AND Labeltype='jspop');
delimiter;

Alter table LD_bankaccountset MODIFY conversion_rate decimal(25,3);
update ld_bankaccountset set currency_id = 1 where currency_id = 0;
update ld_bankaccountset left join ld_currency_info on ld_bankaccountset.currency_id = ld_currency_info.id 
set ld_bankaccountset.conversion_rate = ld_currency_info.conversion_rate where ld_bankaccountset.conversion_rate is NULL;
update ld_bankaccountset left join ld_currency_info on ld_bankaccountset.currency_id = ld_currency_info.id 
set ld_bankaccountset.currency_symbol = ld_currency_info.currency_symbol where ld_bankaccountset.currency_symbol is NULL;
delimiter;

select tabid into @tabid from ld_tab where `name`= 'Potentials';
select sequence,block into @sequence,@block from ld_field where tabid = @tabid and fieldname = 'amount';
select max(fieldid) into @fieldid from ld_field;
insert into ld_field(tabid,fieldid,columnname,tablename,uitype,fieldname,fieldlabel,block,displaytype,presence,typeofdata,readonly,sequence,masseditable,info_type)
select @tabid,@fieldid+1,'currency_id','LD_potential',117,'currency_id','币种',@block,1,0,'I~O',1,@sequence,1,'BAS' from dual where not exists
(select * from ld_field where tabid = @tabid and columnname = 'currency_id');
update ld_field set sequence = sequence +1 where tabid = @tabid and sequence >=@sequence and columnname != 'currency_id';
delimiter;

select tabid into @tabid from ld_tab where `name`= 'Potentials';
select fieldid into @fieldid from ld_field where tabid = @tabid and columnname = 'currency_id';
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'zh','LD_field',@tabid,@fieldid,'币种'
from dual where not EXISTS(select 1 from ld_tranlabel  where languagetype = 'zh'
and trantable ='LD_field' and tabid = @tabid and relateid=@fieldid);
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'en','LD_field',@tabid,@fieldid,'Currency'
from dual where not EXISTS(select 1 from ld_tranlabel  where languagetype = 'en'
and trantable ='LD_field' and tabid = @tabid and relateid=@fieldid);
delimiter;

CALL AddColumn('LD_potential','currency_id','int',1,1);
CALL AddColumn('LD_potential','conversion_rate','int',1,1);
CALL AddColumn('LD_potential','currency_symbol','varchar','30',null);
delimiter;

alter table LD_potential MODIFY conversion_rate decimal(25,6);
update LD_potential set currency_id = 1 where currency_id = 0;
update ld_potential set conversion_rate = '1.000000' where conversion_rate is null;
update LD_potential set currency_symbol = '¥' where currency_symbol is NULL;
delimiter;

call fieldprofile('Potentials');
call getallprofile('Potentials');
call addtabintoprofile('Potentials',0);

select tabid into @tabid from ld_tab where `name`= 'Potentials';
select Relateid into @fieldid from ld_tranlabel where fieldlabel like '%预算绝对值%' and tabid = @tabid and languagetype = 'zh';
update ld_field set uitype = 71 where tabid = @tabid and fieldid = @fieldid;
select Relateid into @fieldid from ld_tranlabel where fieldlabel like '%机会预测金额%' and tabid = @tabid and languagetype = 'zh';
update ld_field set uitype = 71 where tabid = @tabid and fieldid = @fieldid;
delimiter;

INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
	SELECT 'zh','UPDATEBANKCURRENCY','所有金额的币种将会被修正为所选的货币，确定吗？','jspop'
		FROM DUAL WHERE NOT EXISTS
	(SELECT 1 FROM ld_desk  WHERE languagetype='zh' AND
		labelbol='UPDATEBANKCURRENCY' AND Labeltype='jspop');

INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
	SELECT 'en','UPDATEBANKCURRENCY','All currency of amount will be fixed for the selected currency,are you sure?','jspop'
	FROM DUAL WHERE NOT EXISTS
	(SELECT 1 FROM ld_desk  WHERE languagetype='en' AND
		labelbol='UPDATEBANKCURRENCY' AND Labeltype='jspop');

CALL AddColumn('LD_salesorder','currency_symbol','varchar','30',null);
ALTER TABLE `LD_salesorder` CHANGE `currency_symbol` `currency_symbol` VARCHAR(30) AFTER `conversion_rate`;
update ld_salesorder left join ld_currency_info on ld_salesorder.currency_id = ld_currency_info.id set ld_salesorder.currency_symbol = ld_currency_info.currency_symbol;
delimiter;

select tabid into @tabid from ld_tab where `name`= 'PaymentPlan';
select sequence,block into @sequence,@block from ld_field where tabid = @tabid and fieldname = 'amount';
select max(fieldid) into @fieldid from ld_field;
insert into ld_field(tabid,fieldid,columnname,tablename,uitype,fieldname,fieldlabel,block,displaytype,presence,typeofdata,readonly,sequence,masseditable,info_type)
select @tabid,@fieldid+1,'currency_id','LD_paymentplan',117,'currency_id','币种',@block,1,0,'I~O',1,@sequence,1,'BAS' from dual where not exists
(select * from ld_field where tabid = @tabid and columnname = 'currency_id');
update ld_field set sequence = sequence +1 where tabid = @tabid and sequence >=@sequence and columnname != 'currency_id';
delimiter;

select tabid into @tabid from ld_tab where `name`= 'PaymentPlan';
select fieldid into @fieldid from ld_field where tabid = @tabid and columnname = 'currency_id';
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'zh','LD_field',@tabid,@fieldid,'币种'
from dual where not EXISTS(select 1 from ld_tranlabel  where languagetype = 'zh'
and trantable ='LD_field' and tabid = @tabid and relateid=@fieldid);
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'en','LD_field',@tabid,@fieldid,'Currency'
from dual where not EXISTS(select 1 from ld_tranlabel  where languagetype = 'en'
and trantable ='LD_field' and tabid = @tabid and relateid=@fieldid);
delimiter;

CALL AddColumn('LD_paymentplan','currency_id','int',1,1);
CALL AddColumn('LD_paymentplan','conversion_rate','int',1,1);
CALL AddColumn('LD_paymentplan','currency_symbol','varchar','30',null);

alter table LD_paymentplan MODIFY conversion_rate decimal(25,6);
update LD_paymentplan set currency_id = 1 where currency_id = 0;
update LD_paymentplan left join ld_currency_info on LD_paymentplan.currency_id = ld_currency_info.id 
set LD_paymentplan.conversion_rate = ld_currency_info.conversion_rate where LD_paymentplan.conversion_rate is NULL;
update LD_paymentplan left join ld_currency_info on LD_paymentplan.currency_id = ld_currency_info.id 
set LD_paymentplan.currency_symbol = ld_currency_info.currency_symbol where LD_paymentplan.currency_symbol is NULL;
delimiter;

call fieldprofile('PaymentPlan');
call getallprofile('PaymentPlan');
call addtabintoprofile('PaymentPlan',0);

select tabid into @tabid from ld_tab where `name`= 'CashBill';
select sequence,block into @sequence,@block from ld_field where tabid = @tabid and fieldname = 'bankaccountsetid';
select max(fieldid) into @fieldid from ld_field;
insert into ld_field(tabid,fieldid,columnname,tablename,uitype,fieldname,fieldlabel,block,displaytype,presence,typeofdata,readonly,sequence,masseditable,info_type)
select @tabid,@fieldid+1,'currency_id','LD_cashbill',117,'currency_id','币种',@block,1,0,'I~O',1,@sequence,1,'BAS' from dual where not exists
(select * from ld_field where tabid = @tabid and columnname = 'currency_id');
update ld_field set sequence = sequence +1 where tabid = @tabid and sequence >=@sequence and columnname != 'currency_id';
delimiter;

select tabid into @tabid from ld_tab where `name`= 'CashBill';
select fieldid into @fieldid from ld_field where tabid = @tabid and columnname = 'currency_id';
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'zh','LD_field',@tabid,@fieldid,'币种'
from dual where not EXISTS(select 1 from ld_tranlabel  where languagetype = 'zh'
and trantable ='LD_field' and tabid = @tabid and relateid=@fieldid);
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'en','LD_field',@tabid,@fieldid,'Currency'
from dual where not EXISTS(select 1 from ld_tranlabel  where languagetype = 'en'
and trantable ='LD_field' and tabid = @tabid and relateid=@fieldid);
delimiter;

CALL AddColumn('LD_cashbill','currency_id','int',1,1);
CALL AddColumn('LD_cashbill','conversion_rate','int',1,1);
CALL AddColumn('LD_cashbill','currency_symbol','varchar','30',null);

alter table LD_cashbill MODIFY conversion_rate decimal(25,6);
update LD_cashbill set currency_id = 1 where currency_id = 0;
update LD_cashbill left join ld_currency_info on LD_cashbill.currency_id = ld_currency_info.id 
set LD_cashbill.conversion_rate = ld_currency_info.conversion_rate where LD_cashbill.conversion_rate is NULL;
update LD_cashbill left join ld_currency_info on LD_cashbill.currency_id = ld_currency_info.id 
set LD_cashbill.currency_symbol = ld_currency_info.currency_symbol where LD_cashbill.currency_symbol is NULL;
delimiter;
call fieldprofile('CashBill');
call getallprofile('CashBill');

CALL AddColumn('ld_invoice','currency_symbol','varchar','30',NULL);
ALTER TABLE `LD_invoice` CHANGE `currency_symbol` `currency_symbol` VARCHAR(30) AFTER `conversion_rate`;
update LD_invoice left join ld_currency_info on LD_invoice.currency_id = ld_currency_info.id set LD_invoice.currency_symbol = ld_currency_info.currency_symbol;
delimiter;

select tabid into @tabid from ld_tab where `name` = 'CashBill';
update ld_field set uitype = 71 where tabid = @tabid and fieldname= 'Total';
select tabid into @tabid from ld_tab where `name` = 'SendCashBill';
update ld_field set uitype = 71 where tabid = @tabid and fieldname= 'hdnGrandTotal';

CALL AddColumn('LD_purchaseorder','currency_symbol','varchar','30',NULL);
ALTER TABLE `LD_purchaseorder` CHANGE `currency_symbol` `currency_symbol` VARCHAR(30) AFTER `conversion_rate`;
update LD_purchaseorder left join ld_currency_info on LD_purchaseorder.currency_id = ld_currency_info.id set LD_purchaseorder.currency_symbol = ld_currency_info.currency_symbol;
delimiter;

select tabid into @tabid from ld_tab where `name`= 'SendPayment';
select sequence,block into @sequence,@block from ld_field where tabid = @tabid and fieldname = 'amount';
select max(fieldid) into @fieldid from ld_field;
insert into ld_field(tabid,fieldid,columnname,tablename,uitype,fieldname,fieldlabel,block,displaytype,presence,typeofdata,readonly,sequence,masseditable,info_type)
select @tabid,@fieldid+1,'currency_id','LD_sendpayment',117,'currency_id','币种',@block,1,0,'I~O',1,@sequence,1,'BAS' from dual where not exists
(select * from ld_field where tabid = @tabid and columnname = 'currency_id');
update ld_field set sequence = sequence +1 where tabid = @tabid and sequence >=@sequence and columnname != 'currency_id';
delimiter;

select tabid into @tabid from ld_tab where `name`= 'SendPayment';
select fieldid into @fieldid from ld_field where tabid = @tabid and columnname = 'currency_id';
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'zh','LD_field',@tabid,@fieldid,'币种'
from dual where not EXISTS(select 1 from ld_tranlabel  where languagetype = 'zh'
and trantable ='LD_field' and tabid = @tabid and relateid=@fieldid);
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'en','LD_field',@tabid,@fieldid,'Currency'
from dual where not EXISTS(select 1 from ld_tranlabel  where languagetype = 'en'
and trantable ='LD_field' and tabid = @tabid and relateid=@fieldid);
delimiter;

CALL AddColumn('LD_sendpayment','currency_id','int',1,1);
CALL AddColumn('LD_sendpayment','conversion_rate','int',1,1);
CALL AddColumn('LD_sendpayment','currency_symbol','varchar','30',null);

alter table LD_sendpayment MODIFY conversion_rate decimal(25,6);
update LD_sendpayment set currency_id = 1 where currency_id = 0;
update LD_sendpayment left join ld_currency_info on LD_sendpayment.currency_id = ld_currency_info.id 
set LD_sendpayment.conversion_rate = ld_currency_info.conversion_rate where LD_sendpayment.conversion_rate is NULL;
update LD_sendpayment left join ld_currency_info on LD_sendpayment.currency_id = ld_currency_info.id 
set LD_sendpayment.currency_symbol = ld_currency_info.currency_symbol where LD_sendpayment.currency_symbol is NULL;
delimiter;
call fieldprofile('SendPayment');
call getallprofile('SendPayment');
call addtabintoprofile('SendPayment',0);

select tabid into @tabid from ld_tab where `name`= 'SendCashBill';
select sequence,block into @sequence,@block from ld_field where tabid = @tabid and fieldname = 'bankaccountsetid';
select max(fieldid) into @fieldid from ld_field;
insert into ld_field(tabid,fieldid,columnname,tablename,uitype,fieldname,fieldlabel,block,displaytype,presence,typeofdata,readonly,sequence,masseditable,info_type)
select @tabid,@fieldid+1,'currency_id','LD_sendcashbill',117,'currency_id','币种',@block,1,0,'I~O',1,@sequence,1,'BAS' from dual where not exists
(select * from ld_field where tabid = @tabid and columnname = 'currency_id');
update ld_field set sequence = sequence +1 where tabid = @tabid and sequence >=@sequence and columnname != 'currency_id';
delimiter;

select tabid into @tabid from ld_tab where `name`= 'SendCashBill';
select fieldid into @fieldid from ld_field where tabid = @tabid and columnname = 'currency_id';
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'zh','LD_field',@tabid,@fieldid,'币种'
from dual where not EXISTS(select 1 from ld_tranlabel  where languagetype = 'zh'
and trantable ='LD_field' and tabid = @tabid and relateid=@fieldid);
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'en','LD_field',@tabid,@fieldid,'Currency'
from dual where not EXISTS(select 1 from ld_tranlabel  where languagetype = 'en'
and trantable ='LD_field' and tabid = @tabid and relateid=@fieldid);
delimiter;

CALL AddColumn('LD_sendcashbill','currency_id','int',1,1);
CALL AddColumn('LD_sendcashbill','conversion_rate','int',1,1);
CALL AddColumn('LD_sendcashbill','currency_symbol','varchar','30',null);

alter table LD_sendcashbill MODIFY conversion_rate decimal(25,6);
update LD_sendcashbill set currency_id = 1 where currency_id = 0;
update LD_sendcashbill left join ld_currency_info on LD_sendcashbill.currency_id = ld_currency_info.id 
set LD_sendcashbill.conversion_rate = ld_currency_info.conversion_rate where LD_sendcashbill.conversion_rate is NULL;
update LD_sendcashbill left join ld_currency_info on LD_sendcashbill.currency_id = ld_currency_info.id 
set LD_sendcashbill.currency_symbol = ld_currency_info.currency_symbol where LD_sendcashbill.currency_symbol is NULL;
delimiter;

call fieldprofile('SendCashBill');
call getallprofile('SendCashBill');

select tabid into @tabid from ld_tab where `name` = 'SalesBack';
update ld_field set uitype = 72 where tabid = @tabid and columnname in ('havebackamount','total');
delimiter;

select tabid into @tabid from ld_tab where `name` = 'CashBack';
update ld_field set uitype = 72 where tabid = @tabid and columnname in ('total');
delimiter;

select tabid into @tabid from ld_tab where `name` = 'PurchaseBack';
update ld_field set uitype = 72 where tabid = @tabid and columnname in ('havebackamount','total');
delimiter;

select tabid into @tabid from ld_tab where `name` = 'PurchaseCashBack';
update ld_field set uitype = 72 where tabid = @tabid and columnname in ('total');
delimiter;

select tabid into @tabid from ld_tab where `name` = 'Commission';
update ld_field set uitype = 72 where tabid = @tabid and columnname in ('total');
delimiter;

select tabid into @tabid from ld_tab where `name`= 'Commission';
select sequence,block into @sequence,@block from ld_field where tabid = @tabid and fieldname = 'bankaccountsetid';
select max(fieldid) into @fieldid from ld_field;
insert into ld_field(tabid,fieldid,columnname,tablename,uitype,fieldname,fieldlabel,block,displaytype,presence,typeofdata,readonly,sequence,masseditable,info_type)
select @tabid,@fieldid+1,'currency_id','LD_commission',117,'currency_id','币种',@block,1,0,'I~O',1,@sequence,1,'BAS' from dual where not exists
(select * from ld_field where tabid = @tabid and columnname = 'currency_id');
update ld_field set sequence = sequence +1 where tabid = @tabid and sequence >=@sequence and columnname != 'currency_id';
delimiter;

select tabid into @tabid from ld_tab where `name`= 'Commission';
select fieldid into @fieldid from ld_field where tabid = @tabid and columnname = 'currency_id';
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'zh','LD_field',@tabid,@fieldid,'币种'
from dual where not EXISTS(select 1 from ld_tranlabel  where languagetype = 'zh'
and trantable ='LD_field' and tabid = @tabid and relateid=@fieldid);
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'en','LD_field',@tabid,@fieldid,'Currency'
from dual where not EXISTS(select 1 from ld_tranlabel  where languagetype = 'en'
and trantable ='LD_field' and tabid = @tabid and relateid=@fieldid);
delimiter;

CALL AddColumn('LD_commission','currency_id','int',1,1);
CALL AddColumn('LD_commission','conversion_rate','int',1,1);
CALL AddColumn('LD_commission','currency_symbol','varchar','30',null);

alter table LD_commission MODIFY conversion_rate decimal(25,6);
update LD_commission set currency_id = 1 where currency_id = 0;
update LD_commission left join ld_currency_info on LD_commission.currency_id = ld_currency_info.id 
set LD_commission.conversion_rate = ld_currency_info.conversion_rate where LD_commission.conversion_rate is NULL;
update LD_commission left join ld_currency_info on LD_commission.currency_id = ld_currency_info.id 
set LD_commission.currency_symbol = ld_currency_info.currency_symbol where LD_commission.currency_symbol is NULL;
delimiter;
call fieldprofile('Commission');
call getallprofile('Commission');
call addtabintoprofile('Commission',0);

select tabid into @tabid from ld_tab where `name`= 'Expense';
select sequence,block into @sequence,@block from ld_field where tabid = @tabid and fieldname = 'bankaccountsetid';
select max(fieldid) into @fieldid from ld_field;
insert into ld_field(tabid,fieldid,columnname,tablename,uitype,fieldname,fieldlabel,block,displaytype,presence,typeofdata,readonly,sequence,masseditable,info_type)
select @tabid,@fieldid+1,'currency_id','LD_expense',117,'currency_id','币种',@block,1,0,'I~O',1,@sequence,1,'BAS' from dual where not exists
(select * from ld_field where tabid = @tabid and columnname = 'currency_id');
update ld_field set sequence = sequence +1 where tabid = @tabid and sequence >=@sequence and columnname != 'currency_id';
delimiter;

select tabid into @tabid from ld_tab where `name`= 'Expense';
select fieldid into @fieldid from ld_field where tabid = @tabid and columnname = 'currency_id';
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'zh','LD_field',@tabid,@fieldid,'币种'
from dual where not EXISTS(select 1 from ld_tranlabel  where languagetype = 'zh'
and trantable ='LD_field' and tabid = @tabid and relateid=@fieldid);
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'en','LD_field',@tabid,@fieldid,'Currency'
from dual where not EXISTS(select 1 from ld_tranlabel  where languagetype = 'en'
and trantable ='LD_field' and tabid = @tabid and relateid=@fieldid);
delimiter;

CALL AddColumn('LD_expense','currency_id','int',1,1);
CALL AddColumn('LD_expense','conversion_rate','int',1,1);
CALL AddColumn('LD_expense','currency_symbol','varchar','30',null);

alter table LD_expense MODIFY conversion_rate decimal(25,6);
update LD_expense set currency_id = 1 where currency_id = 0;
update LD_expense set conversion_rate = '1.000000' where conversion_rate is null;
update LD_expense set currency_symbol = '¥' where currency_symbol is NULL;
delimiter;

call fieldprofile('Expense');
call getallprofile('Expense');
call addtabintoprofile('Expense',0);

select tabid into @tabid from ld_tab where `name`= 'PutCash';
select sequence,block into @sequence,@block from ld_field where tabid = @tabid and fieldname = 'cashmoney';
select max(fieldid) into @fieldid from ld_field;
insert into ld_field(tabid,fieldid,columnname,tablename,uitype,fieldname,fieldlabel,block,displaytype,presence,typeofdata,readonly,sequence,masseditable,info_type)
select @tabid,@fieldid+1,'currency_id','LD_putcash',117,'currency_id','币种',@block,1,0,'I~O',1,@sequence,1,'BAS' from dual where not exists
(select * from ld_field where tabid = @tabid and columnname = 'currency_id');
update ld_field set sequence = sequence +1 where tabid = @tabid and sequence >=@sequence and columnname != 'currency_id';
delimiter;

select tabid into @tabid from ld_tab where `name`= 'PutCash';
select fieldid into @fieldid from ld_field where tabid = @tabid and columnname = 'currency_id';
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'zh','LD_field',@tabid,@fieldid,'币种'
from dual where not EXISTS(select 1 from ld_tranlabel  where languagetype = 'zh'
and trantable ='LD_field' and tabid = @tabid and relateid=@fieldid);
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'en','LD_field',@tabid,@fieldid,'Currency'
from dual where not EXISTS(select 1 from ld_tranlabel  where languagetype = 'en'
and trantable ='LD_field' and tabid = @tabid and relateid=@fieldid);
delimiter;

CALL AddColumn('LD_putcash','currency_id','int',1,1);
CALL AddColumn('LD_putcash','conversion_rate','int',1,1);
CALL AddColumn('LD_putcash','currency_symbol','varchar','30',null);

alter table LD_putcash MODIFY conversion_rate decimal(25,6);
update LD_putcash set currency_id = 1 where currency_id = 0;
update LD_putcash set conversion_rate = '1.000000' where conversion_rate is null;
update LD_putcash set currency_symbol = '¥' where currency_symbol is NULL;
call fieldprofile('PutCash');
call getallprofile('PutCash');
call addtabintoprofile('PutCash',0);

select tabid into @tabid from ld_tab where `name`= 'CashDeposit';
select sequence,block into @sequence,@block from ld_field where tabid = @tabid and fieldname = 'cashmoney';
select max(fieldid) into @fieldid from ld_field;
insert into ld_field(tabid,fieldid,columnname,tablename,uitype,fieldname,fieldlabel,block,displaytype,presence,typeofdata,readonly,sequence,masseditable,info_type)
select @tabid,@fieldid+1,'currency_id','LD_cashdeposit',117,'currency_id','币种',@block,1,0,'I~O',1,@sequence,1,'BAS' from dual where not exists
(select * from ld_field where tabid = @tabid and columnname = 'currency_id');
update ld_field set sequence = sequence +1 where tabid = @tabid and sequence >=@sequence and columnname != 'currency_id';
delimiter;

select tabid into @tabid from ld_tab where `name`= 'CashDeposit';
select fieldid into @fieldid from ld_field where tabid = @tabid and columnname = 'currency_id';
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'zh','LD_field',@tabid,@fieldid,'币种'
from dual where not EXISTS(select 1 from ld_tranlabel  where languagetype = 'zh'
and trantable ='LD_field' and tabid = @tabid and relateid=@fieldid);
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'en','LD_field',@tabid,@fieldid,'Currency'
from dual where not EXISTS(select 1 from ld_tranlabel  where languagetype = 'en'
and trantable ='LD_field' and tabid = @tabid and relateid=@fieldid);
delimiter;

CALL AddColumn('LD_cashdeposit','currency_id','int',1,1);
CALL AddColumn('LD_cashdeposit','conversion_rate','int',1,1);
CALL AddColumn('LD_cashdeposit','currency_symbol','varchar','30',null);

alter table LD_cashdeposit MODIFY conversion_rate decimal(25,6);
update LD_cashdeposit set currency_id = 1 where currency_id = 0;
update LD_cashdeposit set conversion_rate = '1.000000' where conversion_rate is null;
update LD_cashdeposit set currency_symbol = '¥' where currency_symbol is NULL;
delimiter;

call fieldprofile('CashDeposit');
call getallprofile('CashDeposit');
call addtabintoprofile('CashDeposit',0);

CALL AddColumn('LD_servicecontracts','currency_symbol','varchar','30',null);
ALTER TABLE `LD_servicecontracts` CHANGE `currency_symbol` `currency_symbol` VARCHAR(30) AFTER `conversion_rate`;
update LD_servicecontracts left join ld_currency_info on LD_servicecontracts.currency_id = ld_currency_info.id set LD_servicecontracts.currency_symbol = ld_currency_info.currency_symbol;
delimiter;


select usereportid into @usereportid from ld_usereport where `name` = 'CashBillSum_Paymentplan';
update ld_usereportcolumns set `columns` = 'LD_paymentplan:actualamount:actualamount:PaymentPlan_actualamount:N',
realcolumns = 'LD_paymentplan:actualamount:actualamount:PaymentPlan_回款计划已收金额:N',realencolumns='LD_paymentplan:actualamount:actualamount:PaymentPlan_plan amount received:V' 
where Usereportid = @usereportid and `columns` = 'LD_paymentplan:actualamount:actualamount:PaymentPlan_actualamount:V';
delimiter;

select usereportid into @usereportid from ld_usereport where `name` = 'SendCashBillSum_SendPayment';
update ld_usereportcolumns set `columns` = 'LD_sendpayment:actualamount:actualamount:SendPayment_actualamount:N',
realcolumns = 'LD_sendpayment:actualamount:actualamount:SendPayment_已付金额:N',realencolumns='LD_sendpayment:actualamount:actualamount:SendPayment_actual amount:V' 
where Usereportid = @usereportid and `columns` = 'LD_sendpayment:actualamount:actualamount:SendPayment_actualamount:V';
delimiter;


INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
	SELECT 'zh','ALLCURRENCYOFAMOUNTWILLBEFIXED','所有金额的币种将会被修正为所选的货币，确定吗？','jspop'
		FROM DUAL WHERE NOT EXISTS
	(SELECT 1 FROM ld_desk  WHERE languagetype='zh' AND
		labelbol='ALLCURRENCYOFAMOUNTWILLBEFIXED' AND Labeltype='jspop');

INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
	SELECT 'en','ALLCURRENCYOFAMOUNTWILLBEFIXED','All currency of amount will be fixed for the selected currency,are you sure? ','jspop'
	FROM DUAL WHERE NOT EXISTS
	(SELECT 1 FROM ld_desk  WHERE languagetype='en' AND
		labelbol='ALLCURRENCYOFAMOUNTWILLBEFIXED' AND Labeltype='jspop');

CALL AddColumn('LD_receivablesforecast','currency_id','int',1,1);
CALL AddColumn('LD_receivablesforecast','conversion_rate','int',5,1);
CALL AddColumn('LD_receivablesforecast','currency_symbol','varchar','30',null);

alter table LD_receivablesforecast MODIFY conversion_rate decimal(25,6);
update LD_receivablesforecast set currency_id = 1 where currency_id = 0;
update LD_receivablesforecast set conversion_rate = '1.000000' where conversion_rate is null;
update LD_receivablesforecast set currency_symbol = '¥' where currency_symbol is NULL;
delimiter;

CALL AddColumn('LD_quotes','currency_symbol','varchar','30',NULL);
ALTER TABLE `LD_quotes` CHANGE `currency_symbol` `currency_symbol` VARCHAR(30) AFTER `conversion_rate`;
update LD_quotes left join ld_currency_info on LD_quotes.currency_id = ld_currency_info.id set LD_quotes.currency_symbol = ld_currency_info.currency_symbol;
delimiter;

CALL AddColumn('LD_salesback','currency_symbol','varchar','30',NULL);
ALTER TABLE `LD_salesback` CHANGE `currency_symbol` `currency_symbol` VARCHAR(30) AFTER `conversion_rate`;
update LD_salesback left join ld_currency_info on LD_salesback.currency_id = ld_currency_info.id set LD_salesback.currency_symbol = ld_currency_info.currency_symbol;
delimiter;

CALL AddColumn('LD_purchaseinvoice','currency_symbol','varchar','30',NULL);
ALTER TABLE `LD_purchaseinvoice` CHANGE `currency_symbol` `currency_symbol` VARCHAR(30) AFTER `conversion_rate`;
update LD_purchaseinvoice left join ld_currency_info on LD_purchaseinvoice.currency_id = ld_currency_info.id set LD_purchaseinvoice.currency_symbol = ld_currency_info.currency_symbol;
delimiter;

CALL AddColumn('LD_cashback','currency_symbol','varchar','30',NULL);
ALTER TABLE `LD_cashback` CHANGE `currency_symbol` `currency_symbol` VARCHAR(30) AFTER `conversion_rate`;
update LD_cashback left join ld_currency_info on LD_cashback.currency_id = ld_currency_info.id set LD_cashback.currency_symbol = ld_currency_info.currency_symbol;
delimiter;

CALL AddColumn('LD_purchasecashback','currency_symbol','varchar','30',NULL);
ALTER TABLE `LD_purchasecashback` CHANGE `currency_symbol` `currency_symbol` VARCHAR(30) AFTER `conversion_rate`;
update LD_purchasecashback left join ld_currency_info on LD_purchasecashback.currency_id = ld_currency_info.id set LD_purchasecashback.currency_symbol = ld_currency_info.currency_symbol;
delimiter;

CALL AddColumn('LD_outboundorder','currency_symbol','varchar','30',NULL);
ALTER TABLE `LD_outboundorder` CHANGE `currency_symbol` `currency_symbol` VARCHAR(30) AFTER `conversion_rate`;
update LD_outboundorder left join ld_currency_info on LD_outboundorder.currency_id = ld_currency_info.id set LD_outboundorder.currency_symbol = ld_currency_info.currency_symbol;
delimiter;

CALL AddColumn('LD_stock','currency_symbol','varchar','30',NULL);
ALTER TABLE `LD_stock` CHANGE `currency_symbol` `currency_symbol` VARCHAR(30) AFTER `conversion_rate`;
update LD_stock left join ld_currency_info on LD_stock.currency_id = ld_currency_info.id set LD_stock.currency_symbol = ld_currency_info.currency_symbol;
delimiter;

CALL AddColumn('LD_warehousetransfer','currency_symbol','varchar','30',null);
ALTER TABLE `LD_warehousetransfer` CHANGE `currency_symbol` `currency_symbol` VARCHAR(30) AFTER `conversion_rate`;
update LD_warehousetransfer left join ld_currency_info on LD_warehousetransfer.currency_id = ld_currency_info.id set LD_warehousetransfer.currency_symbol = ld_currency_info.currency_symbol;
delimiter;

CALL AddColumn('LD_purchaseback','currency_symbol','varchar','30',NULL);
ALTER TABLE `LD_purchaseback` CHANGE `currency_symbol` `currency_symbol` VARCHAR(30) AFTER `conversion_rate`;
update LD_purchaseback left join ld_currency_info on LD_purchaseback.currency_id = ld_currency_info.id set LD_purchaseback.currency_symbol = ld_currency_info.currency_symbol;
delimiter;

CALL AddColumn('LD_productbom','currency_symbol','varchar','30',NULL);
ALTER TABLE `LD_productbom` CHANGE `currency_symbol` `currency_symbol` VARCHAR(30) AFTER `conversion_rate`;
update LD_productbom left join ld_currency_info on LD_productbom.currency_id = ld_currency_info.id set LD_productbom.currency_symbol = ld_currency_info.currency_symbol;
delimiter;

CALL AddColumn('LD_checks','currency_symbol','varchar','30',NULL);
ALTER TABLE `LD_checks` CHANGE `currency_symbol` `currency_symbol` VARCHAR(30) AFTER `conversion_rate`;
update LD_checks left join ld_currency_info on LD_checks.currency_id = ld_currency_info.id set LD_checks.currency_symbol = ld_currency_info.currency_symbol;
delimiter;

select tabid into @tabid from ld_tab where `name` = 'CashBill';
update ld_field set uitype = 71 where tabid = @tabid and fieldname in ('hdnGrandTotal','hdnSubTotal');
delimiter;

CALL AddColumn('LD_pricebook','conversion_rate','int',1,1);
CALL AddColumn('LD_pricebook','currency_symbol','varchar','30',null);
delimiter;

alter table LD_pricebook MODIFY conversion_rate decimal(25,6);
update LD_pricebook set currency_id = 1 where currency_id = 0;
update LD_pricebook set conversion_rate = '1.000000' where conversion_rate is null;
update LD_pricebook set currency_symbol = '¥' where currency_symbol is NULL;
delimiter;
-- 2014-12-31

select tabid into @tabid from ld_tab where `name`= 'Users'; 
select block,sequence into @block,@sequence from ld_field where tabid = @tabid and fieldname = 'level'; 
select max(fieldid) into @fieldid from ld_field; 
insert into ld_field(tabid,fieldid,columnname,tablename,uitype,fieldname,fieldlabel,block,displaytype,presence,typeofdata,readonly,sequence,masseditable,info_type) 
select @tabid,@fieldid+1,'approvestatus','LD_users',15,'approvestatus','Approvestatus',@block,1,2,'V~O',1,@sequence,1,'BAS' from dual where not exists 
(select * from ld_field where tabid = @tabid and columnname = 'approvestatus'); 

insert into ld_field(tabid,fieldid,columnname,tablename,uitype,fieldname,fieldlabel,block,displaytype,presence,typeofdata,readonly,sequence,masseditable,info_type) 
select @tabid,@fieldid+2,'approveby','LD_users',11,'approveby','审批人',@block,1,2,'V~O',1,@sequence,1,'BAS' from dual where not exists 
(select * from ld_field where tabid = @tabid and columnname = 'approveby'); 
update ld_field_seq set id = (select max(fieldid) from ld_field); 
delimiter; 


select tabid into @tabid from ld_tab where `name`= 'Users'; 
select fieldid into @fieldid from ld_field where tabid = @tabid and columnname = 'approvestatus'; 
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel) 
select 'zh','LD_field',@tabid,@fieldid,'审批委托' 
from dual where not EXISTS(select 1 from ld_tranlabel where languagetype = 'zh' 
and trantable ='LD_field' and tabid = @tabid and relateid=@fieldid); 
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel) 
select 'en','LD_field',@tabid,@fieldid,'Approve delegate' 
from dual where not EXISTS(select 1 from ld_tranlabel where languagetype = 'en' 
and trantable ='LD_field' and tabid = @tabid and relateid=@fieldid); 
delimiter; 

select tabid into @tabid from ld_tab where `name`= 'Users'; 
select fieldid into @fieldid from ld_field where tabid = @tabid and columnname = 'approveby'; 
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel) 
select 'zh','LD_field',@tabid,@fieldid,'审批委托人' 
from dual where not EXISTS(select 1 from ld_tranlabel where languagetype = 'zh' 
and trantable ='LD_field' and tabid = @tabid and relateid=@fieldid); 
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel) 
select 'en','LD_field',@tabid,@fieldid,'Approval of the principal' 
from dual where not EXISTS(select 1 from ld_tranlabel where languagetype = 'en' 
and trantable ='LD_field' and tabid = @tabid and relateid=@fieldid); 
delimiter;

INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype) SELECT 'zh','APPROVE_BATCHSUBMIT','批量提交','fixedstr' FROM DUAL
WHERE NOT EXISTS(SELECT 1 FROM ld_desk  WHERE languagetype='zh' AND labelbol='APPROVE_BATCHSUBMIT' AND Labeltype='fixedstr');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype) SELECT 'en','APPROVE_BATCHSUBMIT','Batch Submission','fixedstr' FROM DUAL
WHERE NOT EXISTS(SELECT 1 FROM ld_desk  WHERE languagetype='en' AND labelbol='APPROVE_BATCHSUBMIT' AND Labeltype='fixedstr');
delimiter;
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype) SELECT 'zh','APPROVE_BATCHAPPROVED','批量审批','fixedstr' FROM DUAL
WHERE NOT EXISTS(SELECT 1 FROM ld_desk  WHERE languagetype='zh' AND labelbol='APPROVE_BATCHAPPROVED' AND Labeltype='fixedstr');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype) SELECT 'en','APPROVE_BATCHAPPROVED','Batch approval','fixedstr' FROM DUAL
WHERE NOT EXISTS(SELECT 1 FROM ld_desk  WHERE languagetype='en' AND labelbol='APPROVE_BATCHAPPROVED' AND Labeltype='fixedstr');
delimiter;
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype) SELECT 'zh','APPROVE_ANTIAPPROVAL','反审批','fixedstr' FROM DUAL
WHERE NOT EXISTS(SELECT 1 FROM ld_desk  WHERE languagetype='zh' AND labelbol='APPROVE_ANTIAPPROVAL' AND Labeltype='fixedstr');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype) SELECT 'en','APPROVE_ANTIAPPROVAL','Anti Approval','fixedstr' FROM DUAL
WHERE NOT EXISTS(SELECT 1 FROM ld_desk  WHERE languagetype='en' AND labelbol='APPROVE_ANTIAPPROVAL' AND Labeltype='fixedstr');
delimiter;

INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype) SELECT 'zh','APPROVE_BATCHSUBMITLOG_INFO','共选择 %d 条记录，成功提交 %d 条，失败 %d 条。','fixedstr' FROM DUAL
WHERE NOT EXISTS(SELECT 1 FROM ld_desk  WHERE languagetype='zh' AND labelbol='APPROVE_BATCHSUBMITLOG_INFO' AND Labeltype='fixedstr');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype) SELECT 'en','APPROVE_BATCHSUBMITLOG_INFO',' Submit %d records,%d successful, %d failed.','fixedstr' FROM DUAL
WHERE NOT EXISTS(SELECT 1 FROM ld_desk  WHERE languagetype='en' AND labelbol='APPROVE_BATCHSUBMITLOG_INFO' AND Labeltype='fixedstr');

INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype) SELECT 'zh','APPROVE_BATCHSUBMITLOG_SUBMIT','单据[%s]提交不成功！原因：该单据已经提交！','fixedstr' FROM DUAL
WHERE NOT EXISTS(SELECT 1 FROM ld_desk  WHERE languagetype='zh' AND labelbol='APPROVE_BATCHSUBMITLOG_SUBMIT' AND Labeltype='fixedstr');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype) SELECT 'en','APPROVE_BATCHSUBMITLOG_SUBMIT',' Record  [%s] submit failed.The reason is that it had been submitted.','fixedstr' FROM DUAL
WHERE NOT EXISTS(SELECT 1 FROM ld_desk  WHERE languagetype='en' AND labelbol='APPROVE_BATCHSUBMITLOG_SUBMIT' AND Labeltype='fixedstr');

INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype) SELECT 'zh','APPROVE_BATCHSUBMITLOG_APPROVED','单据[%s]提交不成功！原因：该单据已经审批！','fixedstr' FROM DUAL
WHERE NOT EXISTS(SELECT 1 FROM ld_desk  WHERE languagetype='zh' AND labelbol='APPROVE_BATCHSUBMITLOG_APPROVED' AND Labeltype='fixedstr');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype) SELECT 'en','APPROVE_BATCHSUBMITLOG_APPROVED',' Record  [%s] submit failed.The reason is that it had been approved.','fixedstr' FROM DUAL
WHERE NOT EXISTS(SELECT 1 FROM ld_desk  WHERE languagetype='en' AND labelbol='APPROVE_BATCHSUBMITLOG_APPROVED' AND Labeltype='fixedstr');
delimiter;

INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype) SELECT 'zh','APPROVE_CANCEL_BACKUP','回撤到上一步','fixedstr' FROM DUAL
WHERE NOT EXISTS(SELECT 1 FROM ld_desk  WHERE languagetype='zh' AND labelbol='APPROVE_CANCEL_BACKUP' AND Labeltype='fixedstr');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype) SELECT 'en','APPROVE_CANCEL_BACKUP','Back to the previous step','fixedstr' FROM DUAL
WHERE NOT EXISTS(SELECT 1 FROM ld_desk  WHERE languagetype='en' AND labelbol='APPROVE_CANCEL_BACKUP' AND Labeltype='fixedstr');
delimiter;
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype) SELECT 'zh','APPROVE_CANCEL_BACKAPPROVE','使用当前流程重新流转','fixedstr' FROM DUAL
WHERE NOT EXISTS(SELECT 1 FROM ld_desk  WHERE languagetype='zh' AND labelbol='APPROVE_CANCEL_BACKAPPROVE' AND Labeltype='fixedstr');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype) SELECT 'en','APPROVE_CANCEL_BACKAPPROVE','Using the current process to re approve','fixedstr' FROM DUAL
WHERE NOT EXISTS(SELECT 1 FROM ld_desk  WHERE languagetype='en' AND labelbol='APPROVE_CANCEL_BACKAPPROVE' AND Labeltype='fixedstr');
delimiter;
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype) SELECT 'zh','APPROVE_CANCEL_SELECTAPPROVE','使用新的流程重新流转','fixedstr' FROM DUAL
WHERE NOT EXISTS(SELECT 1 FROM ld_desk  WHERE languagetype='zh' AND labelbol='APPROVE_CANCEL_SELECTAPPROVE' AND Labeltype='fixedstr');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype) SELECT 'en','APPROVE_CANCEL_SELECTAPPROVE','Using a new process to re approve','fixedstr' FROM DUAL
WHERE NOT EXISTS(SELECT 1 FROM ld_desk  WHERE languagetype='en' AND labelbol='APPROVE_CANCEL_SELECTAPPROVE' AND Labeltype='fixedstr');
delimiter;

update ld_desk set fieldlabel = '第一步：由系统管理员用户设置仓库并指定仓库管理用户' 
where labelbol = 'THEFIRSTSTEPADMINSTRATOR' and languagetype = 'zh';
update ld_desk set fieldlabel = 'The first step: by the system administrator user settings and user specified warehouse management warehouse' 
where labelbol = 'THEFIRSTSTEPADMINSTRATOR' and languagetype = 'en';
delimiter; 
update ld_desk set fieldlabel = '第二步：由仓库管理用户执行初始化库存' 
where labelbol = 'THESECONDSTEPFROMPRODUCT' and languagetype = 'zh';
update ld_desk set fieldlabel = 'The second step: by users to perform initialization inventory of warehouse management' 
where labelbol = 'THESECONDSTEPFROMPRODUCT' and languagetype = 'en';
delimiter; 
delete from ld_desk where labelbol = 'THETHIRDSTEPBYLISTAFFINIZATION';
delimiter; 
update ld_desk set fieldlabel = '第一步：由采购员用户新建采购订单' 
where labelbol = 'THEORDERFILLEDINBYTHEPURCHASER' and languagetype = 'zh';
update ld_desk set fieldlabel = 'The first step: by the purchaser users create purchase order' 
where labelbol = 'THEORDERFILLEDINBYTHEPURCHASER' and languagetype = 'en';
delimiter; 
update ld_desk set fieldlabel = '第二步：由采购员用户按采购单新建入库单' 
where labelbol = 'THEPROCUREMENTSTAFFGENERAION' and languagetype = 'zh';
update ld_desk set fieldlabel = 'The second step: by the purchaser by purchasing new warehousing single user single' 
where labelbol = 'THEPROCUREMENTSTAFFGENERAION' and languagetype = 'en';
delimiter; 
update ld_desk set fieldlabel = '第三步：仓库管理用户按实际收货情况，确认入库单' 
where labelbol = 'THETHIRDSTEOPACTUALDELIVERYCON' and languagetype = 'zh';
update ld_desk set fieldlabel = 'The third step: warehouse management users according to the actual situation to confirm receipt, warehousing single' 
where labelbol = 'THETHIRDSTEOPACTUALDELIVERYCON' and languagetype = 'en';
delimiter; 
update ld_desk set fieldlabel = '第一步：销售员用户新建合同订单' 
where labelbol = 'THEFIRSTSTEPCONTRACTSALES' and languagetype = 'zh';
update ld_desk set fieldlabel = 'The first step: Sales users create new contract order' 
where labelbol = 'THEFIRSTSTEPCONTRACTSALES' and languagetype = 'en';
delimiter; 
update ld_desk set fieldlabel = '第二步：销售员用户按合同订单新建出库单' 
where labelbol = 'THESECONDPERSONACCORDINGTOCONTRACT' and languagetype = 'zh';
update ld_desk set fieldlabel = 'The second step: the sales of new treasury single user orders under the contract' 
where labelbol = 'THESECONDPERSONACCORDINGTOCONTRACT' and languagetype = 'en';
delimiter; 
update ld_desk set fieldlabel = '第三步：仓库管理用户按单出库，确认出库单' 
where labelbol = 'THETHIRDRECEPITCIONFIRMED' and languagetype = 'zh';
update ld_desk set fieldlabel = 'The third step: warehouse management user according to the single library, confirm the outgoing list' 
where labelbol = 'THETHIRDRECEPITCIONFIRMED' and languagetype = 'en';
delimiter; 

update ld_desk set fieldlabel = '第一步：由调入仓库管理用户新建库间调拨单' 
where labelbol = 'THEFIRSTSTEPREGULATINGSTORAGEWAREHOUSE' and languagetype = 'zh';
update ld_desk set fieldlabel = 'The first step: from the redeployment of warehouse management users create new inter library allocation list' 
where labelbol = 'THEFIRSTSTEPREGULATINGSTORAGEWAREHOUSE' and languagetype = 'en';
delimiter; 
update ld_desk set fieldlabel = '第二步：由调出仓库管理用户审核调拨单' 
where labelbol = 'THEFIRSTSTEPREGULATINGSASSTORAGEWAREHOUSE' and languagetype = 'zh';
update ld_desk set fieldlabel = 'The second step: the redeployment of warehouse management user audit form' 
where labelbol = 'THEFIRSTSTEPREGULATINGSASSTORAGEWAREHOUSE' and languagetype = 'en';
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'zh','THEFIRSTSTEPREGULATINGSTORAGEWAREHOUSEOUT','第一步：由调出仓库管理用户新建库间调拨单','fixedstr' from dual 
where not EXISTS(select 1 from ld_desk where languagetype='zh' and labelbol='THEFIRSTSTEPREGULATINGSTORAGEWAREHOUSEOUT' and Labeltype='fixedstr'); 
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'en','THEFIRSTSTEPREGULATINGSTORAGEWAREHOUSEOUT','The first step: the redeployment of warehouse management users create new inter library allocation list','fixedstr' from dual 
where not EXISTS(select 1 from ld_desk where languagetype='en' and labelbol='THEFIRSTSTEPREGULATINGSTORAGEWAREHOUSEOUT' and Labeltype='fixedstr'); 
delimiter; 
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'zh','THEFIRSTSTEPREGULATINGSASSTORAGEWAREHOUSEOUT','第二步：由调入仓库管理用户审核调拨单','fixedstr' from dual 
where not EXISTS(select 1 from ld_desk where languagetype='zh' and labelbol='THEFIRSTSTEPREGULATINGSASSTORAGEWAREHOUSEOUT' and Labeltype='fixedstr'); 
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'en','THEFIRSTSTEPREGULATINGSASSTORAGEWAREHOUSEOUT','The second step: by a warehouse management user audit form','fixedstr' from dual 
where not EXISTS(select 1 from ld_desk where languagetype='en' and labelbol='THEFIRSTSTEPREGULATINGSASSTORAGEWAREHOUSEOUT' and Labeltype='fixedstr'); 
delimiter; 
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'zh','PICKUP','（取货）','fixedstr' from dual 
where not EXISTS(select 1 from ld_desk where languagetype='zh' and labelbol='PICKUP' and Labeltype='fixedstr'); 
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'en','PICKUP','(Pickup)','fixedstr' from dual 
where not EXISTS(select 1 from ld_desk where languagetype='en' and labelbol='PICKUP' and Labeltype='fixedstr'); 
delimiter; 
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'zh','DELIVERY','（送货）','fixedstr' from dual 
where not EXISTS(select 1 from ld_desk where languagetype='zh' and labelbol='DELIVERY' and Labeltype='fixedstr'); 
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'en','DELIVERY','(Delivery)','fixedstr' from dual 
where not EXISTS(select 1 from ld_desk where languagetype='en' and labelbol='DELIVERY' and Labeltype='fixedstr'); 
delimiter; 
delete from ld_desk where labelbol = 'MESSAGENOTMORETHAN64CHARACTERS';
delimiter; 
update ld_desk set fieldlabel = '关于短信字数：空格、数字、字母、汉字等均为一个字，短信签名也包含在短信字数中' 
where labelbol = 'Acaswaw' and languagetype = 'zh';
update ld_desk set fieldlabel = 'On the text word count: spaces, numbers, letters, Chinese characters are as a word, message signature is also included in the message in words' 
where labelbol = 'Acaswaw' and languagetype = 'en';
delimiter;

call AddColumn('LD_salesorder','consignee','varchar','100',NULL); 
call AddColumn('LD_salesorder','backup_phone','varchar','100',NULL); 
call AddColumn('LD_salesorder','consignee_phone','varchar','100',NULL); 
call AddColumn('LD_salesorder','delivery_address','varchar','200',NULL); 
delimiter;

select blockid into @blockid from ld_blocks where tabid = 22 and blocklabel = 'LBL_SO_INFORMATION';
select tabid into @tabid from ld_tab where name='SalesOrder';
update ld_field_seq set id=id+1 where not exists (select * from ld_field where tabid = @tabid and columnname = 'consignee')
and  EXISTS (select 1 from ld_version where trade='adoodoo');

insert into ld_field(tabid,fieldid,columnname,tablename,generatedtype,uitype,fieldname,fieldlabel,readonly,presence,
defaultvalue,maximumlength,sequence,block,displaytype,typeofdata,quickcreate,quickcreatesequence,info_type,masseditable,
helpinfo,fieldonly,issmownerid,searchfieldtype,associatedfields,associatedsequence,callchecked)
select @tabid,(select max(fieldid) from ld_field)+1,'consignee','LD_salesorder',2,1,'consignee','consignee',1,2,
'',100,1,@blockid,1,'V~O',1,0,'BAS',1,
null,0,0,null,null,0,0  from dual where not exists (select * from ld_field where tabid = @tabid and columnname = 'consignee')
and  EXISTS (select 1 from ld_version where trade='adoodoo');

select fieldid into @fieldid from ld_field where tabid = 22 and fieldname = 'consignee';
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'zh','LD_field',22,@fieldid,'收货人' 
from dual where not EXISTS(select 1 from ld_tranlabel  where languagetype = 'zh' 
and trantable ='LD_field' and tabid = 22 and relateid=@fieldid) and  EXISTS (select 1 from ld_version where trade='adoodoo');
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'en','LD_field',22,@fieldid,'consignee' 
from dual where not EXISTS(select 1 from ld_tranlabel  where languagetype = 'en' 
and trantable ='LD_field' and tabid = 22 and relateid=@fieldid )and  EXISTS (select 1 from ld_version where trade='adoodoo');
delimiter;


select blockid into @blockid from ld_blocks where tabid = 22 and blocklabel = 'LBL_SO_INFORMATION';
select tabid into @tabid from ld_tab where name='SalesOrder';
update ld_field_seq set id=id+1  where not exists (select * from ld_field where tabid = @tabid and columnname = 'consignee_phone')
and  EXISTS (select 1 from ld_version where trade='adoodoo');
insert into ld_field(tabid,fieldid,columnname,tablename,generatedtype,uitype,fieldname,fieldlabel,readonly,presence,
defaultvalue,maximumlength,sequence,block,displaytype,typeofdata,quickcreate,quickcreatesequence,info_type,masseditable,
helpinfo,fieldonly,issmownerid,searchfieldtype,associatedfields,associatedsequence,callchecked)
select @tabid,(select max(fieldid) from ld_field)+1,'consignee_phone','LD_salesorder',2,1,'consignee_phone','consignee_phone',1,2,
'',100,1,@blockid,1,'V~O',1,0,'BAS',1,
null,0,0,null,null,0,0  from dual where not exists (select * from ld_field where tabid = @tabid and columnname = 'consignee_phone')
and  EXISTS (select 1 from ld_version where trade='adoodoo');

delimiter;
select fieldid into @fieldid from ld_field where tabid = 22 and fieldname = 'consignee_phone';
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'zh','LD_field',22,@fieldid,'联系人电话' 
from dual where not EXISTS(select 1 from ld_tranlabel  where languagetype = 'zh' 
and trantable ='LD_field' and tabid = 22 and relateid=@fieldid) and  EXISTS (select 1 from ld_version where trade='adoodoo');
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'en','LD_field',22,@fieldid,'contact phone' 
from dual where not EXISTS(select 1 from ld_tranlabel  where languagetype = 'en' 
and trantable ='LD_field' and tabid = 22 and relateid=@fieldid )and  EXISTS (select 1 from ld_version where trade='adoodoo');
delimiter;

select blockid into @blockid from ld_blocks where tabid = 22 and blocklabel = 'LBL_SO_INFORMATION';
select tabid into @tabid from ld_tab where name='SalesOrder';

update ld_field_seq set id=id+1  where not exists (select * from ld_field where tabid = @tabid and columnname = 'backup_phone')
and  EXISTS (select 1 from ld_version where trade='adoodoo');

insert into ld_field(tabid,fieldid,columnname,tablename,generatedtype,uitype,fieldname,fieldlabel,readonly,presence,
defaultvalue,maximumlength,sequence,block,displaytype,typeofdata,quickcreate,quickcreatesequence,info_type,masseditable,
helpinfo,fieldonly,issmownerid,searchfieldtype,associatedfields,associatedsequence,callchecked)
select @tabid,(select max(fieldid) from ld_field)+1,'backup_phone','LD_salesorder',2,1,'backup_phone','backup_phone',1,2,
'',100,1,@blockid,1,'V~O',1,0,'BAS',1,null,0,0,null,null,0,0  from dual where not exists (select * from ld_field where tabid = @tabid and columnname = 'backup_phone')
and  EXISTS (select 1 from ld_version where trade='adoodoo');
delimiter;

select fieldid into @fieldid from ld_field where tabid = 22 and fieldname = 'backup_phone';
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'zh','LD_field',22,@fieldid,'备用电话' 
from dual where not EXISTS(select 1 from ld_tranlabel  where languagetype = 'zh' 
and trantable ='LD_field' and tabid = 22 and relateid=@fieldid) and  EXISTS (select 1 from ld_version where trade='adoodoo');
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'en','LD_field',22,@fieldid,'backup phone' 
from dual where not EXISTS(select 1 from ld_tranlabel  where languagetype = 'en' 
and trantable ='LD_field' and tabid = 22 and relateid=@fieldid )and  EXISTS (select 1 from ld_version where trade='adoodoo');
delimiter;

select blockid into @blockid from ld_blocks where tabid = 22 and blocklabel = 'LBL_SO_INFORMATION';
select tabid into @tabid from ld_tab where name='SalesOrder';
update ld_field_seq set id=id+1  where not exists (select * from ld_field where tabid = @tabid and columnname = 'delivery_address')
and  EXISTS (select 1 from ld_version where trade='adoodoo');


insert into ld_field(tabid,fieldid,columnname,tablename,generatedtype,uitype,fieldname,fieldlabel,readonly,presence,
defaultvalue,maximumlength,sequence,block,displaytype,typeofdata,quickcreate,quickcreatesequence,info_type,masseditable,
helpinfo,fieldonly,issmownerid,searchfieldtype,associatedfields,associatedsequence,callchecked)
select @tabid,(select max(fieldid) from ld_field)+1,'delivery_address','LD_salesorder',2,1,'delivery_address','delivery_address',1,2,
'',100,1,@blockid,1,'V~O',1,0,'BAS',1,null,0,0,null,null,0,0  from dual where not exists (select * from ld_field where tabid = @tabid and columnname = 'delivery_address')
and  EXISTS (select 1 from ld_version where trade='adoodoo');
delimiter;

select fieldid into @fieldid from ld_field where tabid = 22 and fieldname = 'delivery_address';
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'zh','LD_field',22,@fieldid,'收货地址' 
from dual where not EXISTS(select 1 from ld_tranlabel  where languagetype = 'zh' 
and trantable ='LD_field' and tabid = 22 and relateid=@fieldid) and  EXISTS (select 1 from ld_version where trade='adoodoo');
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'en','LD_field',22,@fieldid,'Delivery address' 
from dual where not EXISTS(select 1 from ld_tranlabel  where languagetype = 'en' 
and trantable ='LD_field' and tabid = 22 and relateid=@fieldid )and  EXISTS (select 1 from ld_version where trade='adoodoo');
delimiter;

call fieldprofile('SalesOrder');
delimiter;
call getallprofile('SalesOrder');
delimiter;
-- 2015-01-04

update ld_field set presence=1 where tabid=22 and block=61 and columnname='contactid' 
and exists (select 1 from ld_version where trade='adoodoo');

set @seq=0;
select sequence into @seq from ld_field where tabid=22 and columnname='accountid';
update ld_field set sequence=sequence+10 where tabid=22 and block=61 and sequence>@seq;
update ld_field set sequence=@seq+1 where tabid=22 and block=61 and columnname='consignee';
update ld_field set sequence=@seq+2 where tabid=22 and block=61 and columnname='consignee_phone';
update ld_field set sequence=@seq+3 where tabid=22 and block=61 and columnname='backup_phone';
update ld_field set sequence=@seq+4 where tabid=22 and block=61 and columnname='delivery_address';

set @i=0;
update ld_field set sequence=(@i:=@i+1) where tabid=22 and block=61 order by sequence;
delimiter;

INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
	SELECT 'zh','LENGTHDECIMALDIGITS','单据明细中数量小数位数','fixedstr'
		FROM DUAL WHERE NOT EXISTS
	(SELECT 1 FROM ld_desk  WHERE languagetype='zh' AND
		labelbol='LENGTHDECIMALDIGITS' AND Labeltype='fixedstr');

INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
	SELECT 'en','LENGTHDECIMALDIGITS','Length of the decimal digits',
	'fixedstr' FROM DUAL WHERE NOT EXISTS
	(SELECT 1 FROM ld_desk  WHERE languagetype='en' AND
		labelbol='LENGTHDECIMALDIGITS' AND Labeltype='fixedstr');
delimiter;

DROP PROCEDURE IF EXISTS DEL_FK;
delimiter ||
CREATE PROCEDURE DEL_FK(
	tablename varchar(200), 
	fkname varchar(200)
)
BEGIN
  SELECT DATABASE() INTO @tableschema;
	SET tablename=LOWER(tablename);
	
	set@cnt=0;
  SET @tsql=CONCAT(' alter table ', tablename, ' drop foreign key ', fkname);
  select count(*) INTO @cnt FROM information_schema.key_column_usage WHERE TABLE_NAME=tablename and CONSTRAINT_NAME=fkname and TABLE_SCHEMA=@tableschema;
  IF @cnt >0 THEN
    PREPARE stmt FROM @tsql;
    EXECUTE stmt;
  END IF;
END ||
delimiter;

call DEL_FK('ld_salesorder','fk_3_vtiger_salesorder');
call DEL_FK('ld_salesorder','ld_salesorder_ibfk_1');
delimiter;

call del_idx('salesorder_vendorid_idx','ld_salesorder');
call del_idx('salesorder_contactid_idx','ld_salesorder');
delimiter;

select cvid into @cvid from ld_customview where entitytype='mobileProducts'  and viewname='mobileProducts';
insert into ld_cvcolumnlist(cvid,columnindex,columnname) select @cvid,1,'LD_products:productsheet:productsheet:Products_fieldlabel:V' from DUAL
where not EXISTS(select 1 from ld_cvcolumnlist where cvid=@cvid and columnname like '%LD_products:productsheet:productsheet:Products%') ;
delimiter;
call fieldprofile('Events');
call getallprofile('events');
delimiter;

update ld_desk set fieldlabel = '（可用的文件类型：jpg, jpeg, gif, png, bmp, ico）' 
where labelbol = 'AVAILABLEFILETYS' and languagetype = 'zh';
delimiter;
update ld_desk set fieldlabel = '(Available file types: jpg, jpeg, gif, png, bmp, ico)' 
where labelbol = 'AVAILABLEFILETYS' and languagetype = 'en';
delimiter;
update ld_desk set fieldlabel = '（只允许使用 jpg、jpeg、gif、png、bmp 与 ico 格式图片，建议图片大小不超过3M）' 
where labelbol = 'ONLYJPGGIFIMG' and languagetype = 'zh';
delimiter;
update ld_desk set fieldlabel = '(Only jpg,jpeg, gif,png, bmp and ico images ,Recommended size of not more than 3M)' 
where labelbol = 'ONLYJPGGIFIMG' and languagetype = 'en';
delimiter;
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'zh','CANNOTUOLOAD','不能上传','jspop' from dual 
where not EXISTS(select 1 from ld_desk  where languagetype='zh' and labelbol='CANNOTUOLOAD' and Labeltype='jspop');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'en','CANNOTUOLOAD','Cannot upload','jspop' from dual 
where not EXISTS(select 1 from ld_desk  where languagetype='en' and labelbol='CANNOTUOLOAD' and Labeltype='jspop');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'zh','THEALLOWEDTYPES','允许的类型','jspop' from dual 
where not EXISTS(select 1 from ld_desk  where languagetype='zh' and labelbol='THEALLOWEDTYPES' and Labeltype='jspop');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'en','THEALLOWEDTYPES','The allowed types','jspop' from dual 
where not EXISTS(select 1 from ld_desk  where languagetype='en' and labelbol='THEALLOWEDTYPES' and Labeltype='jspop');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'zh','FORSECURITYREASONS','出于安全性考虑，不允许添加以下可执行文件.','jspop' from dual 
where not EXISTS(select 1 from ld_desk  where languagetype='zh' and labelbol='FORSECURITYREASONS' and Labeltype='jspop');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'en','FORSECURITYREASONS','For security reasons, add the following the executable file is not allowed','jspop' from dual 
where not EXISTS(select 1 from ld_desk  where languagetype='en' and labelbol='FORSECURITYREASONS' and Labeltype='jspop');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'zh','FILEISZEROBYTESABDCANNOTBEUPLOADED','文件是零字节，无法上传','jspop' from dual 
where not EXISTS(select 1 from ld_desk  where languagetype='zh' and labelbol='FILEISZEROBYTESABDCANNOTBEUPLOADED' and Labeltype='jspop');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'en','FILEISZEROBYTESABDCANNOTBEUPLOADED','File is zero bytes and cannot be uploaded.','jspop' from dual 
where not EXISTS(select 1 from ld_desk  where languagetype='en' and labelbol='FILEISZEROBYTESABDCANNOTBEUPLOADED' and Labeltype='jspop');
delimiter;
-- 2014-01-05

select tabid into @tabid from ld_tab where `name` = 'ServiceContracts';
select max(fieldid) into @fieldid from ld_field;
select blockid into @blockid from ld_blocks where blocklabel = 'LBL_SERVICE_CONTRACT_INFORMATION';

insert into ld_field(tabid,fieldid,columnname,tablename,uitype,fieldname,fieldlabel,block,displaytype,presence,typeofdata)
select @tabid,@fieldid+1,'currency_id','LD_servicecontracts',117,'currency_id','货币',@blockid,3,0,'I~O' from dual where not exists
(select * from ld_field where tabid = @tabid and columnname = 'currency_id');

insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'zh','LD_field',@tabid,@fieldid+1,'货币'
from dual where not EXISTS(select 1 from ld_tranlabel  where languagetype = 'zh'
and trantable ='LD_field' and tabid = @tabid and relateid=@fieldid+1);
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'en','LD_field',@tabid,@fieldid+1,'Currency'
from dual where not EXISTS(select 1 from ld_tranlabel  where languagetype = 'en'
and trantable ='LD_field' and tabid = @tabid and relateid=@fieldid+1);

insert into ld_field(tabid,fieldid,columnname,tablename,uitype,fieldname,fieldlabel,block,displaytype,presence,typeofdata)
select @tabid,@fieldid+2,'conversion_rate','LD_servicecontracts',1,'conversion_rate','汇率',@blockid,3,0,'I~O' from dual where not exists
(select * from ld_field where tabid = @tabid and columnname = 'conversion_rate');

insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'zh','LD_field',@tabid,@fieldid+2,'汇率'
from dual where not EXISTS(select 1 from ld_tranlabel  where languagetype = 'zh'
and trantable ='LD_field' and tabid = @tabid and relateid=@fieldid+2);
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'en','LD_field',@tabid,@fieldid+2,'Exchange Rate'
from dual where not EXISTS(select 1 from ld_tranlabel  where languagetype = 'en'
and trantable ='LD_field' and tabid = @tabid and relateid=@fieldid+2);

update ld_field_seq set id = (select max(fieldid) from ld_field);
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,Labeltype) select 'zh','FUNDINDUSTRYEXCHANGEINTEGRAL','基金行业兑换积分基础值','fixedstr' from dual 
where not EXISTS(select 1 from ld_desk where labelbol='FUNDINDUSTRYEXCHANGEINTEGRAL' and languagetype='zh' and Labeltype='fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,Labeltype)select 'en','FUNDINDUSTRYEXCHANGEINTEGRAL','Fund industry based exchange integral value','fixedstr' from dual
where not EXISTS(select 1 from ld_desk where labelbol='FUNDINDUSTRYEXCHANGEINTEGRAL' and languagetype='en' and Labeltype='fixedstr');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,Labeltype)
select 'zh','INVALIDFUNDINDUSTRYEXCHANGEINTEGRAL','无效的基金行业兑换积分基础值！','jspop' 
from DUAL where not EXISTS(select 1 from ld_desk where labelbol='INVALIDFUNDINDUSTRYEXCHANGEINTEGRAL' and languagetype='zh' and Labeltype='jspop');
insert into ld_desk(languagetype,labelbol,fieldlabel,Labeltype)
select 'en','INVALIDFUNDINDUSTRYEXCHANGEINTEGRAL','Invalid fund industry based exchange integral value!','jspop' 
from DUAL where not EXISTS(select 1 from ld_desk where labelbol='INVALIDFUNDINDUSTRYEXCHANGEINTEGRAL' and languagetype='en' and Labeltype='jspop');
delimiter;

insert into ld_systems_deploy(deploy_value,deploy_type,description,setype)
select '1',62,'当销售机会负责人变更时是否发送短信通知新的负责人。1:是, 0:否','' from dual 
where not exists(select 1 from ld_systems_deploy where deploy_type=62);
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,Labeltype) select 'zh','NOTIFYPOTENTIALASSIGNED','当{$Potentials.Potentials}负责人变更时是否发送短信通知新的负责人','fixedstr' from dual 
where not EXISTS(select 1 from ld_desk where labelbol='NOTIFYPOTENTIALASSIGNED' and languagetype='zh' and Labeltype='fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,Labeltype)select 'en','NOTIFYPOTENTIALASSIGNED','When the {$Potentials.Potentials} head is changing,whether to send text messages to inform the new person in charge','fixedstr' from dual
where not EXISTS(select 1 from ld_desk where labelbol='NOTIFYPOTENTIALASSIGNED' and languagetype='en' and Labeltype='fixedstr');
delimiter;

ALTER TABLE LD_warehousetransfer MODIFY COLUMN createdtime datetime;
ALTER TABLE LD_warehousetransfer MODIFY COLUMN modifiedtime datetime;
delimiter;

call fieldprofile('WareHouseTransfer');
call getallprofile('WareHouseTransfer');
call addtabintoprofile('WareHouseTransfer',0);
-- 2015-01-07

insert into ld_desk(languagetype,labelbol,fieldlabel,Labeltype) select 'zh','PRODUCTFIELDNULLCOLS','产品空列','fixedstr' from dual 
where not EXISTS(select 1 from ld_desk where labelbol='PRODUCTFIELDNULLCOLS' and languagetype='zh' and Labeltype='fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,Labeltype)select 'en','PRODUCTFIELDNULLCOLS','Air column','fixedstr' from dual
where not EXISTS(select 1 from ld_desk where labelbol='PRODUCTFIELDNULLCOLS' and languagetype='en' and Labeltype='fixedstr');
delimiter;

SELECT id INTO @id FROM ld_relatedlists_seq;
SELECT tabid INTO @tabid FROM ld_tab WHERE NAME = 'Accounts';
SELECT MAX(sequence) INTO @sequence FROM ld_relatedlists WHERE tabid = @tabid;
INSERT INTO ld_relatedlists(relation_id,tabid,related_tabid,NAME,sequence,label,actions)
SELECT @id+1,@tabid,0,'get_dingjiesales',@sequence+1,'DingjieSales',''
FROM DUAL WHERE NOT EXISTS(SELECT 1 FROM ld_relatedlists  WHERE tabid = @tabid AND NAME = 'get_dingjiesales');
UPDATE ld_relatedlists_seq SET id = (SELECT MAX(relation_id) FROM ld_relatedlists);
delimiter;

INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype) SELECT 'zh','DingjieSales','鼎捷订单','fixedstr' FROM DUAL
WHERE NOT EXISTS(SELECT 1 FROM ld_desk  WHERE languagetype='zh' AND labelbol='DingjieSales' AND Labeltype='fixedstr');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype) SELECT 'en','DingjieSales','Dingjie Order','fixedstr' FROM DUAL
WHERE NOT EXISTS(SELECT 1 FROM ld_desk  WHERE languagetype='en' AND labelbol='DingjieSales' AND Labeltype='fixedstr');
delimiter;

select tabid into @tabid from ld_tab where `name` = 'InventoryAccount';
update ld_field set uitype = 7 where tabid = @tabid and columnname in ('inputqty','outputqty','lastqty','firstqty');
delimiter;
-- 2015-01-07


select tabid into @tabid from ld_tab where `name`= 'Products'; 
update ld_field set searchfieldtype = 0 where tabid = @tabid and fieldname = 'productsheet'; 
delimiter;

SELECT tabid INTO @tabid from ld_tab where name='ServiceContracts';
SELECT tabid into @tabid3  from ld_tab where name='Expense';
SELECT tabid into @tabid2  from ld_tab where name='Reminds';
SELECT sequence  into @sequence from ld_quickactions where tabid=@tabid and related_tabid=@tabid3;
UPDATE ld_quickactions set sequence=sequence+1 where sequence>@sequence and tabid=@tabid;
insert into ld_quickactions(tabid,related_tabid,sequence,presence)
select @tabid,@tabid2,@sequence+1,0 from dual 
where not EXISTS(select 1 from ld_quickactions  where tabid=@tabid and related_tabid=@tabid2);
delimiter;

SELECT tabid INTO @tabid from ld_tab where name='ProjectTask';
SELECT tabid into @tabid3  from ld_tab where name='ContactRecords';
SELECT tabid into @tabid2  from ld_tab where name='Reminds';
SELECT sequence  into @sequence from ld_quickactions where tabid=@tabid and related_tabid=@tabid3;
UPDATE ld_quickactions set sequence=sequence+1 where sequence>@sequence and tabid=@tabid;
insert into ld_quickactions(tabid,related_tabid,sequence,presence)
select @tabid,@tabid2,@sequence+1,0 from dual 
where not EXISTS(select 1 from ld_quickactions  where tabid=@tabid and related_tabid=@tabid2);
delimiter;

SELECT tabid into @tabid from ld_tab where name='Reminds';
SELECT fieldid into @fieldid from ld_field where tabid=@tabid and columnname='related_to';
INSERT into LD_fieldmodulerel(fieldid,module,relmodule,status,sequence) SELECT @fieldid,'Reminds',
'ProjectTask',0,0  from dual where not exists (select * from LD_fieldmodulerel where module = 'Reminds' and fieldid = @fieldid and relmodule='ProjectTask');
delimiter;
-- 2015-01-09

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'zh','DISPLAYPOSITION','显示位置','fixedstr' from dual 
where not EXISTS(select 1 from ld_desk  where languagetype='zh' and labelbol='DISPLAYPOSITION' and Labeltype='fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'en','DISPLAYPOSITION','Display Position','fixedstr' from dual 
where not EXISTS(select 1 from ld_desk  where languagetype='en' and labelbol='DISPLAYPOSITION' and Labeltype='fixedstr');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'zh','THEFIRSTBLOCK','第一个区块','fixedstr' from dual 
where not EXISTS(select 1 from ld_desk  where languagetype='zh' and labelbol='THEFIRSTBLOCK' and Labeltype='fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'en','THEFIRSTBLOCK','The first block','fixedstr' from dual 
where not EXISTS(select 1 from ld_desk  where languagetype='en' and labelbol='THEFIRSTBLOCK' and Labeltype='fixedstr');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'zh','THELASTBLOCK','最后一区块','fixedstr' from dual 
where not EXISTS(select 1 from ld_desk  where languagetype='zh' and labelbol='THELASTBLOCK' and Labeltype='fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'en','THELASTBLOCK','The last block','fixedstr' from dual 
where not EXISTS(select 1 from ld_desk  where languagetype='en' and labelbol='THELASTBLOCK' and Labeltype='fixedstr');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'zh','BLOCKINFOMATION','区块信息','fixedstr' from dual 
where not EXISTS(select 1 from ld_desk  where languagetype='zh' and labelbol='BLOCKINFOMATION' and Labeltype='fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'en','BLOCKINFOMATION','Block Information','fixedstr' from dual 
where not EXISTS(select 1 from ld_desk  where languagetype='en' and labelbol='BLOCKINFOMATION' and Labeltype='fixedstr');
delimiter;

update ld_desk set fieldlabel = '定制客户和联系人的关联字段' where labelbol = 'LBL_ACCOUNTS_CONTACTS_DESCRIPTION' and languagetype = 'zh';
update ld_desk set fieldlabel = 'Set the related fields of accounts and contacts' where labelbol = 'LBL_ACCOUNTS_CONTACTS_DESCRIPTION' and languagetype = 'en';
delimiter;

CREATE TABLE IF NOT EXISTS `ld_blockdisplay` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `zh_blockname` varchar(255) DEFAULT NULL COMMENT '中文区块名称',
  `en_blockname` varchar(255) DEFAULT NULL COMMENT '英文区块名称',
  `display_position` tinyint(1) DEFAULT '0' COMMENT '0：第一个区块，1：最后个区块',
  `is_display` tinyint(1) DEFAULT '0' COMMENT '0:显示，1：不显示',
  `block_type` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8;
delimiter;

insert into LD_blockdisplay(zh_blockname,en_blockname,display_position,is_display,block_type)
select '客户和联系人关联字段','Related fields of accounts and contacts',0,0,'AccountContacts' from dual 
where not EXISTS(select 1 from ld_blockdisplay where block_type = 'AccountContacts');

select tabid into @tabid from ld_tab where `name`= 'Stock';
select block into @block from ld_field where tabid = @tabid and fieldname = 'ware_stock_no';
select max(fieldid) into @fieldid from ld_field;
insert into ld_field(tabid,fieldid,columnname,tablename,uitype,fieldname,fieldlabel,block,displaytype,presence,typeofdata,readonly,sequence,masseditable,info_type)
select @tabid,@fieldid+1,'currency_id','LD_stock',117,'currency_id','币种',@block,1,0,'I~O',1,@sequence,1,'BAS' from dual where not exists
(select * from ld_field where tabid = @tabid and columnname = 'currency_id');
delimiter;

select tabid into @tabid from ld_tab where `name`= 'Stock';
select fieldid into @fieldid from ld_field where tabid = @tabid and columnname = 'currency_id';
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'zh','LD_field',@tabid,@fieldid,'币种'
from dual where not EXISTS(select 1 from ld_tranlabel  where languagetype = 'zh'
and trantable ='LD_field' and tabid = @tabid and relateid=@fieldid);
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'en','LD_field',@tabid,@fieldid,'Currency'
from dual where not EXISTS(select 1 from ld_tranlabel  where languagetype = 'en'
and trantable ='LD_field' and tabid = @tabid and relateid=@fieldid);
delimiter;
call fieldprofile('Stock');
call getallprofile('Stock');

update ld_field set typeofdata = 'V~M' where fieldname = 'currency_id';
delimiter;

call fieldprofile('ServiceContracts');
call getallprofile('ServiceContracts');
-- 2015-01-13
  
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'zh','SNOWBEARREPORTS','小白熊报表','fixedstr' from dual 
where not EXISTS(select 1 from ld_desk  where languagetype='zh' and labelbol='SNOWBEARREPORTS' and Labeltype='fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'en','SNOWBEARREPORTS','Snow Bear Reports','fixedstr' from dual 
where not EXISTS(select 1 from ld_desk  where languagetype='en' and labelbol='SNOWBEARREPORTS' and Labeltype='fixedstr');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'zh','SNOWBEARRPISP','维修点配件发放汇总表','fixedstr' from dual 
where not EXISTS(select 1 from ld_desk  where languagetype='zh' and labelbol='SNOWBEARRPISP' and Labeltype='fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'en','SNOWBEARRPISP','Repair parts issued summary report','fixedstr' from dual 
where not EXISTS(select 1 from ld_desk  where languagetype='en' and labelbol='SNOWBEARRPISP' and Labeltype='fixedstr');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'zh','SNOWBEARProductName','配件名称','fixedstr' from dual 
where not EXISTS(select 1 from ld_desk  where languagetype='zh' and labelbol='SNOWBEARProductName' and Labeltype='fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'en','SNOWBEARProductName','Product Name','fixedstr' from dual 
where not EXISTS(select 1 from ld_desk  where languagetype='en' and labelbol='SNOWBEARProductName' and Labeltype='fixedstr');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'zh','SNOWBEARApplicableModel','适用型号','fixedstr' from dual 
where not EXISTS(select 1 from ld_desk  where languagetype='zh' and labelbol='SNOWBEARApplicableModel' and Labeltype='fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'en','SNOWBEARApplicableModel','Applicable Model','fixedstr' from dual 
where not EXISTS(select 1 from ld_desk  where languagetype='en' and labelbol='SNOWBEARApplicableModel' and Labeltype='fixedstr');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'zh','SNOWBEARYear','年度','fixedstr' from dual 
where not EXISTS(select 1 from ld_desk  where languagetype='zh' and labelbol='SNOWBEARYear' and Labeltype='fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'en','SNOWBEARYear','YEAR','fixedstr' from dual 
where not EXISTS(select 1 from ld_desk  where languagetype='en' and labelbol='SNOWBEARYear' and Labeltype='fixedstr');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'zh','Containsapprovaldocument','包含未审批单据','fixedstr' from dual 
where not EXISTS(select 1 from ld_desk  where languagetype='zh' and labelbol='Containsapprovaldocument' and Labeltype='fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'en','Containsapprovaldocument','Contains approval Sales','fixedstr' from dual 
where not EXISTS(select 1 from ld_desk  where languagetype='en' and labelbol='Containsapprovaldocument' and Labeltype='fixedstr');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'zh','SNOWBEARRPSL','维修点配件申请明细表','fixedstr' from dual 
where not EXISTS(select 1 from ld_desk  where languagetype='zh' and labelbol='SNOWBEARRPSL' and Labeltype='fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'en','SNOWBEARRPSL','Repair parts application list','fixedstr' from dual 
where not EXISTS(select 1 from ld_desk  where languagetype='en' and labelbol='SNOWBEARRPSL' and Labeltype='fixedstr');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'zh','TDOA','申请日期','fixedstr' from dual 
where not EXISTS(select 1 from ld_desk  where languagetype='zh' and labelbol='TDOA' and Labeltype='fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'en','TDOA','date of application','fixedstr' from dual 
where not EXISTS(select 1 from ld_desk  where languagetype='en' and labelbol='TDOA' and Labeltype='fixedstr');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'zh','SRPN','特约维修点名称','fixedstr' from dual 
where not EXISTS(select 1 from ld_desk  where languagetype='zh' and labelbol='SRPN' and Labeltype='fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'en','SRPN','Special repair point name','fixedstr' from dual 
where not EXISTS(select 1 from ld_desk  where languagetype='en' and labelbol='SRPN' and Labeltype='fixedstr');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'zh','TUOM','计量单位','fixedstr' from dual 
where not EXISTS(select 1 from ld_desk  where languagetype='zh' and labelbol='TUOM' and Labeltype='fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'en','TUOM','The unit of measurement','fixedstr' from dual 
where not EXISTS(select 1 from ld_desk  where languagetype='en' and labelbol='TUOM' and Labeltype='fixedstr');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'zh','ProductCategories','产品大类','fixedstr' from dual 
where not EXISTS(select 1 from ld_desk  where languagetype='zh' and labelbol='ProductCategories' and Labeltype='fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'en','ProductCategories','Product Categories','fixedstr' from dual 
where not EXISTS(select 1 from ld_desk  where languagetype='en' and labelbol='ProductCategories' and Labeltype='fixedstr');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'zh','SNOWBEARHNSRSR','热线单数量区域汇总表','fixedstr' from dual 
where not EXISTS(select 1 from ld_desk  where languagetype='zh' and labelbol='SNOWBEARHNSRSR' and Labeltype='fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'en','SNOWBEARHNSRSR','Hotline number single regional summary report','fixedstr' from dual 
where not EXISTS(select 1 from ld_desk  where languagetype='en' and labelbol='SNOWBEARHNSRSR' and Labeltype='fixedstr');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'zh','area','区域','fixedstr' from dual 
where not EXISTS(select 1 from ld_desk  where languagetype='zh' and labelbol='area' and Labeltype='fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'en','area','Area','fixedstr' from dual 
where not EXISTS(select 1 from ld_desk  where languagetype='en' and labelbol='area' and Labeltype='fixedstr');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'zh','AreaGravity','区域比重','fixedstr' from dual 
where not EXISTS(select 1 from ld_desk  where languagetype='zh' and labelbol='AreaGravity' and Labeltype='fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'en','AreaGravity','Area Gravity','fixedstr' from dual 
where not EXISTS(select 1 from ld_desk  where languagetype='en' and labelbol='AreaGravity' and Labeltype='fixedstr');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'zh','Customercomplaintanalysisreport','客诉分析表','fixedstr' from dual 
where not EXISTS(select 1 from ld_desk  where languagetype='zh' and labelbol='Customercomplaintanalysisreport' and Labeltype='fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'en','Customercomplaintanalysisreport','Customer complaint analysis report','fixedstr' from dual 
where not EXISTS(select 1 from ld_desk  where languagetype='en' and labelbol='Customercomplaintanalysisreport' and Labeltype='fixedstr');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'zh','Productseries','产品系列','fixedstr' from dual 
where not EXISTS(select 1 from ld_desk  where languagetype='zh' and labelbol='Productseries' and Labeltype='fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'en','Productseries','Product series','fixedstr' from dual 
where not EXISTS(select 1 from ld_desk  where languagetype='en' and labelbol='Productseries' and Labeltype='fixedstr');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'zh','AOTABR','实际不良原因分析','fixedstr' from dual 
where not EXISTS(select 1 from ld_desk  where languagetype='zh' and labelbol='AOTABR' and Labeltype='fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'en','AOTABR','Analysis of the actual bad reasons','fixedstr' from dual 
where not EXISTS(select 1 from ld_desk  where languagetype='en' and labelbol='AOTABR' and Labeltype='fixedstr');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'zh','CCN','客诉次数','fixedstr' from dual 
where not EXISTS(select 1 from ld_desk  where languagetype='zh' and labelbol='CCN' and Labeltype='fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'en','CCN','customer complaints number','fixedstr' from dual 
where not EXISTS(select 1 from ld_desk  where languagetype='en' and labelbol='CCN' and Labeltype='fixedstr');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'zh','CCR','客诉占比%','fixedstr' from dual 
where not EXISTS(select 1 from ld_desk  where languagetype='zh' and labelbol='CCR' and Labeltype='fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'en','CCR','Customer complaint ratio%','fixedstr' from dual 
where not EXISTS(select 1 from ld_desk  where languagetype='en' and labelbol='CCR' and Labeltype='fixedstr');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'zh','POTS','占总销量比例','fixedstr' from dual 
where not EXISTS(select 1 from ld_desk  where languagetype='zh' and labelbol='POTS' and Labeltype='fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'en','POTS','proportion of total sales','fixedstr' from dual 
where not EXISTS(select 1 from ld_desk  where languagetype='en' and labelbol='POTS' and Labeltype='fixedstr');
delimiter

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'zh','PRODUCTNAME','产品名称','fixedstr' from dual 
where not EXISTS(select 1 from ld_desk  where languagetype='zh' and labelbol='PRODUCTNAME' and Labeltype='fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'en','PRODUCTNAME','Product Name','fixedstr' from dual 
where not EXISTS(select 1 from ld_desk  where languagetype='en' and labelbol='PRODUCTNAME' and Labeltype='fixedstr');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'zh','Customercomplaintanalysisreport2','客诉分析表-汇总表','fixedstr' from dual 
where not EXISTS(select 1 from ld_desk  where languagetype='zh' and labelbol='Customercomplaintanalysisreport2' and Labeltype='fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'en','Customercomplaintanalysisreport2','Customer complaint analysis report--Summary','fixedstr' from dual 
where not EXISTS(select 1 from ld_desk  where languagetype='en' and labelbol='Customercomplaintanalysisreport2' and Labeltype='fixedstr');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'zh','Returnamountregionaldatasummaryreport','退换货金额各区域数据汇总表','fixedstr' from dual 
where not EXISTS(select 1 from ld_desk  where languagetype='zh' and labelbol='Returnamountregionaldatasummaryreport' and Labeltype='fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'en','Returnamountregionaldatasummaryreport','Return amount of regional data summary report','fixedstr' from dual 
where not EXISTS(select 1 from ld_desk  where languagetype='en' and labelbol='Returnamountregionaldatasummaryreport' and Labeltype='fixedstr');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'zh','admissibilitytype','受理类型','fixedstr' from dual 
where not EXISTS(select 1 from ld_desk  where languagetype='zh' and labelbol='admissibilitytype' and Labeltype='fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'en','admissibilitytype','admissibility type','fixedstr' from dual 
where not EXISTS(select 1 from ld_desk  where languagetype='en' and labelbol='admissibilitytype' and Labeltype='fixedstr');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'zh','Customercategory','客户类别','fixedstr' from dual 
where not EXISTS(select 1 from ld_desk  where languagetype='zh' and labelbol='Customercategory' and Labeltype='fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'en','Customercategory','Customer category','fixedstr' from dual 
where not EXISTS(select 1 from ld_desk  where languagetype='en' and labelbol='Customercategory' and Labeltype='fixedstr');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'zh','Returnnumberregionaldatasummaryreport','退换货数量区域汇总分析表','fixedstr' from dual 
where not EXISTS(select 1 from ld_desk  where languagetype='zh' and labelbol='Returnnumberregionaldatasummaryreport' and Labeltype='fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'en','Returnnumberregionaldatasummaryreport','Return number of regional data summary report','fixedstr' from dual 
where not EXISTS(select 1 from ld_desk  where languagetype='en' and labelbol='Returnnumberregionaldatasummaryreport' and Labeltype='fixedstr');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'zh','Productcustomerservicenumberfailurestatistics','产品售后故障分析表','fixedstr' from dual 
where not EXISTS(select 1 from ld_desk  where languagetype='zh' and labelbol='Productcustomerservicenumberfailurestatistics' and Labeltype='fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'en','Productcustomerservicenumberfailurestatistics','Product customer service number of failure statistics','fixedstr' from dual 
where not EXISTS(select 1 from ld_desk  where languagetype='en' and labelbol='Productcustomerservicenumberfailurestatistics' and Labeltype='fixedstr');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'zh','causefault','故障原因','fixedstr' from dual 
where not EXISTS(select 1 from ld_desk  where languagetype='zh' and labelbol='causefault' and Labeltype='fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'en','causefault','cause fault','fixedstr' from dual 
where not EXISTS(select 1 from ld_desk  where languagetype='en' and labelbol='causefault' and Labeltype='fixedstr');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'zh','Cumulative','累积','fixedstr' from dual 
where not EXISTS(select 1 from ld_desk  where languagetype='zh' and labelbol='Cumulative' and Labeltype='fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'en','Cumulative','Cumulative','fixedstr' from dual 
where not EXISTS(select 1 from ld_desk  where languagetype='en' and labelbol='Cumulative' and Labeltype='fixedstr');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'zh','faultratio','故障占比','fixedstr' from dual 
where not EXISTS(select 1 from ld_desk  where languagetype='zh' and labelbol='faultratio' and Labeltype='fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'en','faultratio','fault ratio','fixedstr' from dual 
where not EXISTS(select 1 from ld_desk  where languagetype='en' and labelbol='faultratio' and Labeltype='fixedstr');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'zh','Seriesproportion','系列占比例','fixedstr' from dual 
where not EXISTS(select 1 from ld_desk  where languagetype='zh' and labelbol='Seriesproportion' and Labeltype='fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'en','Seriesproportion','Series proportion','fixedstr' from dual 
where not EXISTS(select 1 from ld_desk  where languagetype='en' and labelbol='Seriesproportion' and Labeltype='fixedstr');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'zh','Productcustomerservicenumberfailurestatistics2','售后故障次数统计-汇总','fixedstr' from dual 
where not EXISTS(select 1 from ld_desk  where languagetype='zh' and labelbol='Productcustomerservicenumberfailurestatistics2' and Labeltype='fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'en','Productcustomerservicenumberfailurestatistics2','Product customer service number of failure statistics','fixedstr' from dual 
where not EXISTS(select 1 from ld_desk  where languagetype='en' and labelbol='Productcustomerservicenumberfailurestatistics2' and Labeltype='fixedstr');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'zh','Customerservicenumberofsummarytableoffaultarea','售后故障数量区域汇总表','fixedstr' from dual 
where not EXISTS(select 1 from ld_desk  where languagetype='zh' and labelbol='Customerservicenumberofsummarytableoffaultarea' and Labeltype='fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'en','Customerservicenumberofsummarytableoffaultarea','Customer service number of summary table of fault area','fixedstr' from dual 
where not EXISTS(select 1 from ld_desk  where languagetype='en' and labelbol='Customerservicenumberofsummarytableoffaultarea' and Labeltype='fixedstr');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'zh','Summary400hotlinesinglestatistics','400热线单统计汇总表','fixedstr' from dual 
where not EXISTS(select 1 from ld_desk  where languagetype='zh' and labelbol='Summary400hotlinesinglestatistics' and Labeltype='fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'en','Summary400hotlinesinglestatistics','Summary of the 400 hotline single statistics','fixedstr' from dual 
where not EXISTS(select 1 from ld_desk  where languagetype='en' and labelbol='Summary400hotlinesinglestatistics' and Labeltype='fixedstr');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'zh','Analysisofthetablecustomerservicefailure','热线单来电类型分析表','fixedstr' from dual 
where not EXISTS(select 1 from ld_desk  where languagetype='zh' and labelbol='Analysisofthetablecustomerservicefailure' and Labeltype='fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'en','Analysisofthetablecustomerservicefailure','Analysis of the table customer service failure','fixedstr' from dual 
where not EXISTS(select 1 from ld_desk  where languagetype='en' and labelbol='Analysisofthetablecustomerservicefailure' and Labeltype='fixedstr');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'zh','Theprice','出货价','fixedstr' from dual 
where not EXISTS(select 1 from ld_desk  where languagetype='zh' and labelbol='Theprice' and Labeltype='fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'en','Theprice','The price','fixedstr' from dual 
where not EXISTS(select 1 from ld_desk  where languagetype='en' and labelbol='Theprice' and Labeltype='fixedstr');
delimiter;


update ld_tranlabel LEFT JOIN ld_field on ld_tranlabel.tabid = ld_field.tabid and ld_tranlabel.Relateid = ld_field.fieldid set ld_tranlabel.fieldlabel = '货币' where ld_field.fieldname = 'currency_id';
delimiter;
select tabid into @tabid from ld_tab where `name`= 'Stock';
update ld_field set displaytype = 3 where tabid = @tabid and fieldname = 'currency_id';
delimiter;

CALL AddColumn('LD_salesorder','cashbilldate','date','0',null);
select tabid into @tabid from ld_tab where `name` = 'SalesOrder';
select max(fieldid) into @fieldid from ld_field;
select sequence,block,fieldid into @sequence,@block,@create_fieldid from ld_field where tabid = @tabid and fieldname = 'createdtime';
SELECT @sequence+1 INTO @seq1;
insert into ld_field(tabid,fieldid,columnname,tablename,uitype,fieldname,fieldlabel,block,displaytype,presence,typeofdata,info_type,sequence)
select @tabid,@fieldid+1,'cashbilldate','LD_salesorder',256,'cashbilldate','收款日期',@block,2,2,'D~M','BAS',@seq1 from dual where not exists
(select * from ld_field where tabid = @tabid and columnname = 'cashbilldate');

select fieldid into @fieldid from ld_field where tabid = @tabid and fieldname = 'cashbilldate';
UPDATE ld_field SET sequence = (@seq1:=@seq1+1) WHERE tabid = @tabid and fieldid != @fieldid  AND sequence > @sequence ORDER BY sequence;
UPDATE ld_field SET sequence = @sequence+2 WHERE tabid = @tabid AND sequence = @sequence and fieldid != @create_fieldid ORDER BY sequence;

insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'zh','LD_field',@tabid,@fieldid,'收款日期'
from dual where not EXISTS(select 1 from ld_tranlabel  where languagetype = 'zh'
and trantable ='LD_field' and tabid = @tabid and relateid=@fieldid);
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'en','LD_field',@tabid,@fieldid,'Cashbill Date'
from dual where not EXISTS(select 1 from ld_tranlabel  where languagetype = 'en'
and trantable ='LD_field' and tabid = @tabid and relateid=@fieldid);
delimiter;
update ld_tranlabel LEFT JOIN ld_field on ld_tranlabel.tabid = ld_field.tabid and ld_tranlabel.Relateid = ld_field.fieldid set ld_tranlabel.fieldlabel = '币种' where ld_field.fieldname = 'currency_id';
delimiter;

CALL DelColumn('LD_smssend','Priority');
delimiter;
CALL DelColumn('LD_smssend','AliveStartTime');
delimiter;
CALL DelColumn('LD_smssend','AliveEndTime');
delimiter;
CALL DelColumn('LD_smssend','ServerJobNo');
delimiter;
CALL DelColumn('LD_smssend','ServerTaskID');
delimiter;
CALL DelColumn('LD_smssend','SmsSegment');
delimiter;
CALL DelColumn('LD_smssend','ReceiveCompany');
delimiter;
CALL DelColumn('LD_smssend','FAccount');
delimiter;

update ld_desk set Fieldlabel='退货金额不允许超过原单金额' where labelbol='THENUMBEROFRETURNS2' and languagetype='zh' and Labeltype = 'jspop';
delimiter;
-- 2015-01-14

CALL AddColumn('LD_smssend','relatieid','int',19,0);
delimiter;

Alter table LD_salesorder MODIFY conversion_rate decimal(25,6);
Alter table LD_pricebook MODIFY conversion_rate decimal(25,6);
Alter table LD_quotes MODIFY conversion_rate decimal(25,6);
Alter table LD_purchaseorder MODIFY conversion_rate decimal(25,6);
Alter table LD_invoice MODIFY conversion_rate decimal(25,6);
Alter table LD_salesback MODIFY conversion_rate decimal(25,6);
Alter table LD_cashback MODIFY conversion_rate decimal(25,6);
Alter table LD_outboundorder MODIFY conversion_rate decimal(25,6);
Alter table LD_purchaseback MODIFY conversion_rate decimal(25,6);
Alter table LD_purchasecashback MODIFY conversion_rate decimal(25,6);
Alter table LD_purchaseinvoice MODIFY conversion_rate decimal(25,6);
Alter table LD_warehousetransfer MODIFY conversion_rate decimal(25,6);
Alter table LD_bankaccountset MODIFY conversion_rate decimal(25,6);
Alter table LD_potential MODIFY conversion_rate decimal(25,6);
Alter table LD_paymentplan MODIFY conversion_rate decimal(25,6);
Alter table LD_cashbill MODIFY conversion_rate decimal(25,6);
Alter table LD_sendpayment MODIFY conversion_rate decimal(25,6);
Alter table LD_sendcashbill MODIFY conversion_rate decimal(25,6);
Alter table LD_commission MODIFY conversion_rate decimal(25,6);
Alter table LD_expense MODIFY conversion_rate decimal(25,6);
Alter table LD_putcash MODIFY conversion_rate decimal(25,6);
Alter table LD_putcash MODIFY conversion_rate decimal(25,6);
Alter table LD_cashdeposit MODIFY conversion_rate decimal(25,6);
Alter table LD_servicecontracts MODIFY conversion_rate decimal(25,6);
Alter table LD_stock MODIFY conversion_rate decimal(25,6);
Alter table LD_productbom MODIFY conversion_rate decimal(25,6);
Alter table LD_currency_info MODIFY conversion_rate decimal(25,6);
update ld_field set typeofdata = 'D~O' where tabid = 22 and fieldname = 'cashbilldate';
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'zh','MESSCATEGORY','短信类别','fixedstr' from dual
where not EXISTS(select 1 from ld_desk where languagetype='zh' and labelbol='MESSCATEGORY' and labeltype='fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'en','MESSCATEGORY','Message category','fixedstr' from dual
where not EXISTS(select 1 from ld_desk where languagetype='en' and labelbol='MESSCATEGORY' and labeltype='fixedstr');
delimiter;
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'zh','SMS_Blessing','祝福短信','fixedstr' from dual 
where not EXISTS(select 1 from ld_desk  where languagetype='zh' and labelbol='SMS_Blessing' and Labeltype='fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'en','SMS_Blessing','Blessing SMS','fixedstr' from dual 
where not EXISTS(select 1 from ld_desk  where languagetype='en' and labelbol='SMS_Blessing' and Labeltype='fixedstr');
delimiter;
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'zh','SMS_Notification','通知短信','fixedstr' from dual 
where not EXISTS(select 1 from ld_desk  where languagetype='zh' and labelbol='SMS_Notification' and Labeltype='fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'en','SMS_Notification','SMS notification','fixedstr' from dual 
where not EXISTS(select 1 from ld_desk  where languagetype='en' and labelbol='SMS_Notification' and Labeltype='fixedstr');
delimiter;
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'zh','CONFIRMMESSCATEGORY','请将短信类别选择营销短信，然后再点群发！','jspop' from dual 
where not EXISTS(select 1 from ld_desk  where languagetype='zh' and labelbol='CONFIRMMESSCATEGORY' and Labeltype='jspop');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'en','CONFIRMMESSCATEGORY','Please send the message category choice of marketing messages, and then point mass!','jspop' from dual 
where not EXISTS(select 1 from ld_desk  where languagetype='en' and labelbol='CONFIRMMESSCATEGORY' and Labeltype='jspop');
delimiter;


INSERT INTO ld_sendinformcontent (`content`, `type`, `description`) 
select  '短信1：通知个人（接收人取自订单上的产品），立即发送', 2, '短信1：通知个人（接收人取自订单上的产品），立即发送'
FROM DUAL WHERE NOT EXISTS(select 1 from ld_sendinformcontent where type =2);
delimiter;
INSERT INTO ld_sendinformcontent (`content`, `type`, `description`) 
select  '短信2：通知个人（接收人取自订单上的产品），定时发送，根据登机时间提前固定的时间发送', 3, '短信2：通知个人（接收人取自订单上的产品），定时发送，根据登机时间提前固定的时间发送'
FROM DUAL WHERE NOT EXISTS(select 1 from ld_sendinformcontent where type =3);
delimiter;
INSERT INTO ld_sendinformcontent (`content`, `type`, `description`) 
select  '短信3：通知领队（接收人取自订单上的客户或者联系人）', 4, '短信3：通知领队（接收人取自订单上的客户或者联系人）'
FROM DUAL WHERE NOT EXISTS(select 1 from ld_sendinformcontent where type =4);
delimiter;
INSERT INTO ld_sendinformcontent (`content`, `type`, `description`) 
select  '短信1：销售退货单退货短信内容', 5, '短信1：销售退货单退货短信内容'
FROM DUAL WHERE NOT EXISTS(select 1 from ld_sendinformcontent where type =5);
delimiter;
INSERT INTO ld_sendinformcontent (`content`, `type`, `description`) 
select  '短信2：销售退货单退货短信内容', 6, '短信2：销售退货单退货短信内容'
FROM DUAL WHERE NOT EXISTS(select 1 from ld_sendinformcontent where type =6);
delimiter;

update ld_quickactions set sequence = sequence+1 WHERE tabid=22;
insert into ld_quickactions(tabid,related_tabid,sequence,presence,label)
select 22,-9,0,0,'发送短信' from dual 
where not EXISTS(select 1 from ld_quickactions  where tabid=22 and related_tabid=-9);
delimiter;
select tabid into @tabid from ld_tab where name = 'SalesBack';
update ld_quickactions set sequence = sequence+1 WHERE tabid=@tabid;
insert into ld_quickactions(tabid,related_tabid,sequence,presence,label)
select @tabid,-9,0,0,'发送短信' from dual 
where not EXISTS(select 1 from ld_quickactions  where tabid=@tabid and related_tabid=-9);
delimiter;

CREATE TABLE IF NOT EXISTS `ld_sendphoneset` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `fieldids` varchar(200) DEFAULT NULL,
  `type` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=0 DEFAULT CHARSET=utf8;
delimiter;

CREATE TABLE IF NOT EXISTS `ld_sendtimeset` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `fieldid1` int(19) default NULL, 
  `fieldid2` int(19) default NULL, 
	`day` int(11) default NULL,
	`hours` int(11) default NULL,
	`minutes` int(11) default NULL, 
  `type` int(11) default NULL,
  PRIMARY KEY  (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=0 DEFAULT CHARSET=utf8;
delimiter;

select tabid into @tabid from ld_tab where name = 'SalesOrder';
select tabid into @CommunicationLogid from ld_tab where name = 'CommunicationLog';
select max(relation_id) into @sequence from ld_relatedlists where tabid =@tabid;
SELECT max(relation_id) into @relation_id from ld_relatedlists;
insert into ld_relatedlists(relation_id,tabid,related_tabid,name,sequence,label,actions)
select @relation_id+1,@tabid,@CommunicationLogid,'get_communicationLog',@sequence+1,'CommunicationLog','' from dual 
where not EXISTS(select 1 from ld_relatedlists  where tabid=@tabid and related_tabid=@CommunicationLogid);
update ld_relatedlists_seq set id=(select max(relation_id) from ld_relatedlists);
delimiter;

select tabid into @tabid from ld_tab where name = 'SalesBack';
select tabid into @CommunicationLogid from ld_tab where name = 'CommunicationLog';
select max(relation_id) into @sequence from ld_relatedlists where tabid =@tabid;
SELECT max(relation_id) into @relation_id from ld_relatedlists;
insert into ld_relatedlists(relation_id,tabid,related_tabid,name,sequence,label,actions)
select @relation_id+1,@tabid,@CommunicationLogid,'get_communicationLog',@sequence+1,'CommunicationLog','' from dual 
where not EXISTS(select 1 from ld_relatedlists  where tabid=@tabid and related_tabid=@CommunicationLogid);
update ld_relatedlists_seq set id=(select max(relation_id) from ld_relatedlists);
delimiter;
-- 2015-01-15

insert into ld_field(tabid,fieldid,columnname,tablename,generatedtype,uitype,fieldname,fieldlabel,readonly,presence,
defaultvalue,maximumlength,sequence,block,displaytype,typeofdata,quickcreate,quickcreatesequence,info_type,masseditable,
helpinfo,fieldonly,issmownerid,searchfieldtype,associatedfields,associatedsequence,callchecked)
select 22,(select max(fieldid) from ld_field)+1,'smsfirstdate','LD_salesorder',2,70,'smsfirstdate','SMS FirstDate',1,2,
'',100,(select max(sequence) from ld_field where tabid=22 and block=61)+1,61,2,'DT~O',1,0,'BAS',1,
null,0,null,1,1,0,0
from dual where not exists (select * from ld_field where tabid = 22 and columnname = 'smsfirstdate');
delimiter;

insert into ld_field(tabid,fieldid,columnname,tablename,generatedtype,uitype,fieldname,fieldlabel,readonly,presence,
defaultvalue,maximumlength,sequence,block,displaytype,typeofdata,quickcreate,quickcreatesequence,info_type,masseditable,
helpinfo,fieldonly,issmownerid,searchfieldtype,associatedfields,associatedsequence,callchecked)
select 22,(select max(fieldid) from ld_field)+1,'smsseconddate','LD_salesorder',2,70,'smsseconddate','SMS SecondDate',1,2,
'',100,(select max(sequence) from ld_field where tabid=22 and block=61)+1,61,2,'DT~O',1,0,'BAS',1,
null,0,null,1,1,0,0
from dual where not exists (select * from ld_field where tabid = 22 and columnname = 'smsseconddate');
delimiter;

insert into ld_field(tabid,fieldid,columnname,tablename,generatedtype,uitype,fieldname,fieldlabel,readonly,presence,
defaultvalue,maximumlength,sequence,block,displaytype,typeofdata,quickcreate,quickcreatesequence,info_type,masseditable,
helpinfo,fieldonly,issmownerid,searchfieldtype,associatedfields,associatedsequence,callchecked)
select 22,(select max(fieldid) from ld_field)+1,'smsthirddate','LD_salesorder',2,70,'smsthirddate','SMS ThirdDate',1,2,
'',100,(select max(sequence) from ld_field where tabid=22 and block=61)+1,61,2,'DT~O',1,0,'BAS',1,
null,0,null,1,1,0,0
from dual where not exists (select * from ld_field where tabid = 22 and columnname = 'smsthirddate');
delimiter;

select fieldid into @fieldid from ld_field where tabid = 22 and fieldname = 'smsfirstdate';
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'zh','LD_field',22,@fieldid,'短信1发送时间' 
from dual where not EXISTS(select 1 from ld_tranlabel  where languagetype = 'zh' 
and trantable ='LD_field' and tabid = 22 and relateid=@fieldid);
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'en','LD_field',22,@fieldid,'SMS FirstDate' 
from dual where not EXISTS(select 1 from ld_tranlabel  where languagetype = 'en' 
and trantable ='LD_field' and tabid = 22 and relateid=@fieldid );
delimiter;

select fieldid into @fieldid from ld_field where tabid = 22 and fieldname = 'smsseconddate';
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'zh','LD_field',22,@fieldid,'短信2定时时间' 
from dual where not EXISTS(select 1 from ld_tranlabel  where languagetype = 'zh' 
and trantable ='LD_field' and tabid = 22 and relateid=@fieldid);
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'en','LD_field',22,@fieldid,'SMS SecondDate' 
from dual where not EXISTS(select 1 from ld_tranlabel  where languagetype = 'en' 
and trantable ='LD_field' and tabid = 22 and relateid=@fieldid );
delimiter;

select fieldid into @fieldid from ld_field where tabid = 22 and fieldname = 'smsthirddate';
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'zh','LD_field',22,@fieldid,'短信3定时时间' 
from dual where not EXISTS(select 1 from ld_tranlabel  where languagetype = 'zh' 
and trantable ='LD_field' and tabid = 22 and relateid=@fieldid);
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'en','LD_field',22,@fieldid,'SMS ThirdDate' 
from dual where not EXISTS(select 1 from ld_tranlabel  where languagetype = 'en' 
and trantable ='LD_field' and tabid = 22 and relateid=@fieldid );
delimiter;

CALL AddColumn('LD_salesorder','smsfirstdate','datetime',0,null);
delimiter;
CALL AddColumn('LD_salesorder','smsseconddate','datetime',0,null);
delimiter;
CALL AddColumn('LD_salesorder','smsthirddate','datetime',0,null);
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'zh','CHECKFORMISSING','检查遗漏','fixedstr' from dual 
where not EXISTS(select 1 from ld_desk where languagetype='zh' and labelbol='CHECKFORMISSING' and Labeltype='fixedstr'); 
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'en','CHECKFORMISSING','Check For Missing','fixedstr' from dual 
where not EXISTS(select 1 from ld_desk where languagetype='en' and labelbol='CHECKFORMISSING' and Labeltype='fixedstr'); 
delimiter; 

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'zh','DELIVERGOODS','发货','fixedstr' from dual 
where not EXISTS(select 1 from ld_desk where languagetype='zh' and labelbol='DELIVERGOODS' and Labeltype='fixedstr'); 
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'en','DELIVERGOODS','Deliver Goods','fixedstr' from dual 
where not EXISTS(select 1 from ld_desk where languagetype='en' and labelbol='DELIVERGOODS' and Labeltype='fixedstr'); 
delimiter; 

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'zh','TAOBAOORDERS','淘宝订单','fixedstr' from dual 
where not EXISTS(select 1 from ld_desk where languagetype='zh' and labelbol='TAOBAOORDERS' and Labeltype='fixedstr'); 
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'en','TAOBAOORDERS','Taobao orders','fixedstr' from dual 
where not EXISTS(select 1 from ld_desk where languagetype='en' and labelbol='TAOBAOORDERS' and Labeltype='fixedstr'); 
delimiter; 

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'zh','SMS','短信','fixedstr' from dual 
where not EXISTS(select 1 from ld_desk where languagetype='zh' and labelbol='SMS' and Labeltype='fixedstr'); 
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'en','SMS','SMS','fixedstr' from dual 
where not EXISTS(select 1 from ld_desk where languagetype='en' and labelbol='SMS' and Labeltype='fixedstr'); 
delimiter; 

call fieldprofile('SalesOrder');
delimiter; 

call getallprofile('SalesOrder');
delimiter; 

delete from ld_desk where labelbol='SORTORDERSETTINGNEEDTOSELECTATLEASTONEFIELD' and Labeltype = 'jspop';
delete from ld_desk where labelbol='SORTORDERSETTINGNEEDTOSELECTATLEASTONEFIELD' and Labeltype = 'fixedstr';
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'zh','SETSORTORDER','请设置排序方式','jspop' from dual 
where not EXISTS(select 1 from ld_desk  where languagetype='zh' and labelbol='SETSORTORDER' and Labeltype='jspop');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'en','SETSORTORDER','Please set the sort order','jspop' from dual 
where not EXISTS(select 1 from ld_desk  where languagetype='en' and labelbol='SETSORTORDER' and Labeltype='jspop');
delimiter;

 insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'zh','SETSORTORDER','请设置排序方式','fixedstr' from dual 
where not EXISTS(select 1 from ld_desk  where languagetype='zh' and labelbol='SETSORTORDER' and Labeltype='fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'en','SETSORTORDER','Please set the sort order','fixedstr' from dual 
where not EXISTS(select 1 from ld_desk  where languagetype='en' and labelbol='SETSORTORDER' and Labeltype='fixedstr');
delimiter;
-- 2015-01-16

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'zh','SMSSENDINSTANT','即时发送','fixedstr' from dual 
where not EXISTS(select 1 from ld_desk  where languagetype='zh' and labelbol='SMSSENDINSTANT' and Labeltype='fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'en','SMSSENDINSTANT','Send instant','fixedstr' from dual 
where not EXISTS(select 1 from ld_desk  where languagetype='en' and labelbol='SMSSENDINSTANT' and Labeltype='fixedstr');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'zh','MOBILEPHONEFROMPRODUCTORDER','手机号码取自订单产品信息','fixedstr' from dual 
where not EXISTS(select 1 from ld_desk  where languagetype='zh' and labelbol='MOBILEPHONEFROMPRODUCTORDER' and Labeltype='fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'en','MOBILEPHONEFROMPRODUCTORDER','Mobile phone number from the product order information','fixedstr' from dual 
where not EXISTS(select 1 from ld_desk  where languagetype='en' and labelbol='MOBILEPHONEFROMPRODUCTORDER' and Labeltype='fixedstr');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'zh','SETRECEIVERMOBILE','设置接收人手机字段','fixedstr' from dual 
where not EXISTS(select 1 from ld_desk  where languagetype='zh' and labelbol='SETRECEIVERMOBILE' and Labeltype='fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'en','SETRECEIVERMOBILE','Set the recipient mobile phone fields','fixedstr' from dual 
where not EXISTS(select 1 from ld_desk  where languagetype='en' and labelbol='SETRECEIVERMOBILE' and Labeltype='fixedstr');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'zh','SETSMSCONTENTTEMPLATE','设置短信内容格式模板','fixedstr' from dual 
where not EXISTS(select 1 from ld_desk  where languagetype='zh' and labelbol='SETSMSCONTENTTEMPLATE' and Labeltype='fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'en','SETSMSCONTENTTEMPLATE','Set SMS content format template','fixedstr' from dual 
where not EXISTS(select 1 from ld_desk  where languagetype='en' and labelbol='SETSMSCONTENTTEMPLATE' and Labeltype='fixedstr');
delimiter;
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'zh','SETTIMINGRULES','设置定时规则','fixedstr' from dual 
where not EXISTS(select 1 from ld_desk  where languagetype='zh' and labelbol='SETTIMINGRULES' and Labeltype='fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'en','SETTIMINGRULES','Set timing rules','fixedstr' from dual 
where not EXISTS(select 1 from ld_desk  where languagetype='en' and labelbol='SETTIMINGRULES' and Labeltype='fixedstr');
delimiter;
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'zh','SETSMSCONTENT','设置短信内容','fixedstr' from dual 
where not EXISTS(select 1 from ld_desk  where languagetype='zh' and labelbol='SETSMSCONTENT' and Labeltype='fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'en','SETSMSCONTENT','Set SMS content','fixedstr' from dual 
where not EXISTS(select 1 from ld_desk  where languagetype='en' and labelbol='SETSMSCONTENT' and Labeltype='fixedstr');
delimiter;
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'zh','SEX','性别','fixedstr' from dual 
where not EXISTS(select 1 from ld_desk  where languagetype='zh' and labelbol='SEX' and Labeltype='fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'en','SEX','Sex','fixedstr' from dual 
where not EXISTS(select 1 from ld_desk  where languagetype='en' and labelbol='SEX' and Labeltype='fixedstr');
delimiter;
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'zh','IDNUMBERFIELD','身份证号码','fixedstr' from dual 
where not EXISTS(select 1 from ld_desk  where languagetype='zh' and labelbol='IDNUMBERFIELD' and Labeltype='fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'en','IDNUMBERFIELD','ID number field','fixedstr' from dual 
where not EXISTS(select 1 from ld_desk  where languagetype='en' and labelbol='IDNUMBERFIELD' and Labeltype='fixedstr');
delimiter;
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'zh','WEATHERFORECAST','天气预报','fixedstr' from dual 
where not EXISTS(select 1 from ld_desk  where languagetype='zh' and labelbol='WEATHERFORECAST' and Labeltype='fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'en','WEATHERFORECAST','Weather forecast','fixedstr' from dual 
where not EXISTS(select 1 from ld_desk  where languagetype='en' and labelbol='WEATHERFORECAST' and Labeltype='fixedstr');
delimiter;
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'zh','CITYNEEDFORECASTWEATHER','需要预报天气的城市字段','fixedstr' from dual 
where not EXISTS(select 1 from ld_desk  where languagetype='zh' and labelbol='CITYNEEDFORECASTWEATHER' and Labeltype='fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'en','CITYNEEDFORECASTWEATHER','The city needs to forecast the weather field','fixedstr' from dual 
where not EXISTS(select 1 from ld_desk  where languagetype='en' and labelbol='CITYNEEDFORECASTWEATHER' and Labeltype='fixedstr');
delimiter;
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'zh','SPECIALFUNCTIONS','特殊函数','fixedstr' from dual 
where not EXISTS(select 1 from ld_desk  where languagetype='zh' and labelbol='SPECIALFUNCTIONS' and Labeltype='fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'en','SPECIALFUNCTIONS','Special Functions','fixedstr' from dual 
where not EXISTS(select 1 from ld_desk  where languagetype='en' and labelbol='SPECIALFUNCTIONS' and Labeltype='fixedstr');
delimiter;
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'zh','WEATHERFORECASTNOTES','如果需要天气预报，定时规则必须设置提前，天气预报是根据信息发送的日期来计算的。','fixedstr' from dual 
where not EXISTS(select 1 from ld_desk  where languagetype='zh' and labelbol='WEATHERFORECASTNOTES' and Labeltype='fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'en','WEATHERFORECASTNOTES','If you need a weather forecast, timing rules must be set in advance, the weather forecast is calculated according to the information delivery date.','fixedstr' from dual 
where not EXISTS(select 1 from ld_desk  where languagetype='en' and labelbol='WEATHERFORECASTNOTES' and Labeltype='fixedstr');
delimiter;
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'zh','ONLYENTERPOSITIVEINTEGER','只能输入正整数，不输入即为不提前','fixedstr' from dual 
where not EXISTS(select 1 from ld_desk  where languagetype='zh' and labelbol='ONLYENTERPOSITIVEINTEGER' and Labeltype='fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'en','ONLYENTERPOSITIVEINTEGER','You can only enter a positive integer, that is, do not enter without prior','fixedstr' from dual 
where not EXISTS(select 1 from ld_desk  where languagetype='en' and labelbol='ONLYENTERPOSITIVEINTEGER' and Labeltype='fixedstr');
delimiter;
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'zh','NUMBERDAYS','天数','fixedstr' from dual 
where not EXISTS(select 1 from ld_desk  where languagetype='zh' and labelbol='NUMBERDAYS' and Labeltype='fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'en','NUMBERDAYS','Days','fixedstr' from dual 
where not EXISTS(select 1 from ld_desk  where languagetype='en' and labelbol='NUMBERDAYS' and Labeltype='fixedstr');
delimiter;
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'zh','PHONEFROMCUSTOMERSCONTACT','手机号码取自客户或者联系人','fixedstr' from dual 
where not EXISTS(select 1 from ld_desk  where languagetype='zh' and labelbol='PHONEFROMCUSTOMERSCONTACT' and Labeltype='fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'en','PHONEFROMCUSTOMERSCONTACT','Mobile phone number from customers or contact','fixedstr' from dual 
where not EXISTS(select 1 from ld_desk  where languagetype='en' and labelbol='PHONEFROMCUSTOMERSCONTACT' and Labeltype='fixedstr');
delimiter;

SELECT usereportid into @urid FROM ld_usereport WHERE name='Salesforecastandanalysistable';

DELETE FROM ld_usereportcolumns WHERE Usereportid=@urid AND columns = 'LD_potential:retotal:retotal:Potentials_retotal:N';
delimiter;

CREATE TABLE IF NOT EXISTS `ld_autotask` (
  `autotaskid` int(11) NOT NULL default '0',
  `tabid` int(11) default '0',
  `autotaskname` varchar(100) default '',
  `autotaskmode` int(1) default '1',
  `autotaskdate` varchar(10) default '',
  `autotasktype` int(1) default '1',
  `filtergroup` varchar(100) default '',
  `execution` int(1) default '0',
  `presence` int(1) default '0',
  PRIMARY KEY  (`autotaskid`),
  KEY `fk_2_ldcrm_autotask` USING BTREE (`autotaskid`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
delimiter;

CREATE TABLE IF NOT EXISTS `ld_autostdfilter` (
  `autotaskid` int(11) NOT NULL default '0',
  `columnname` varchar(200) default '',
  `stdfilter` varchar(100) default '',
  `startdate` date,
  `enddate` date,
  PRIMARY KEY  (`autotaskid`),
  KEY `fk_2_ldcrm_autostdfilter` USING BTREE (`autotaskid`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
delimiter;

CREATE TABLE IF NOT EXISTS `ld_autoadvfilter` (
  `autotaskid` int(11) NOT NULL default '0',
  `columnindex` int(11) default 0,
  `columnname` varchar(200) default '',
  `comparator` varchar(10) default '',
  `value` varchar(100) default '',
  `groupid` int(11) default '0',
  `column_condition` varchar(10) default '',
  PRIMARY KEY  (`autotaskid`,`columnindex`),
  KEY `fk_2_ldcrm_autoadvfilter` USING BTREE (`autotaskid`,`columnindex`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
delimiter;

CREATE TABLE IF NOT EXISTS `ld_autotaskfilter` (
  `autotaskid` int(11) NOT NULL default '0',
  `columnindex` int(11) default 0,
  `columnname` varchar(200) default '',
  `value` varchar(100) default '',
  PRIMARY KEY  (`autotaskid`,`columnindex`),
  KEY `fk_2_ldcrm_autotackfilter` USING BTREE (`autotaskid`,`columnindex`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
delimiter;

CREATE TABLE IF NOT EXISTS `ld_autotaskquery` (
  `autotaskid` int(11) NOT NULL default '0',
  `query` text default '',
  PRIMARY KEY  (`autotaskid`),
  KEY `fk_2_ldcrm_autotackquery` USING BTREE (`autotaskid`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
delimiter;

INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype) SELECT 'zh','LBL_AUTOMATIC_TASK','自动任务','fixedstr' FROM DUAL
WHERE NOT EXISTS(SELECT 1 FROM ld_desk  WHERE languagetype='zh' AND labelbol='LBL_AUTOMATIC_TASK' AND Labeltype='fixedstr');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype) SELECT 'en','LBL_AUTOMATIC_TASK','Automatic Task','fixedstr' FROM DUAL
WHERE NOT EXISTS(SELECT 1 FROM ld_desk  WHERE languagetype='en' AND labelbol='LBL_AUTOMATIC_TASK' AND Labeltype='fixedstr');

INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype) SELECT 'zh','LBL_AUTOMATIC_TASK_DESCRIPTION','定制任务计划','fixedstr' FROM DUAL
WHERE NOT EXISTS(SELECT 1 FROM ld_desk  WHERE languagetype='zh' AND labelbol='LBL_AUTOMATIC_TASK_DESCRIPTION' AND Labeltype='fixedstr');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype) SELECT 'en','LBL_AUTOMATIC_TASK_DESCRIPTION','Customized task plan','fixedstr' FROM DUAL
WHERE NOT EXISTS(SELECT 1 FROM ld_desk  WHERE languagetype='en' AND labelbol='LBL_AUTOMATIC_TASK_DESCRIPTION' AND Labeltype='fixedstr');

SELECT blockid INTO @blockid FROM ld_settings_blocks WHERE label = 'LBL_OTHER_SETTINGS' ORDER BY sequence;
SELECT MAX(fieldid),MAX(sequence) INTO @fieldid,@seq FROM ld_settings_field;
INSERT INTO LD_settings_field(fieldid,blockid,NAME,iconpath,description,linkto,sequence,active)
SELECT @fieldid+1,@blockid,'LBL_AUTOMATIC_TASK','Cron.png','LBL_AUTOMATIC_TASK_DESCRIPTION','index.php?module=Settings&action=AutomaticTask&parenttab=Settings',@seq+1,0 FROM DUAL
WHERE NOT EXISTS(SELECT 1 FROM LD_settings_field WHERE NAME='LBL_AUTOMATIC_TASK');
delimiter;

INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype) SELECT 'zh','LBL_AUTOMATICTASK_NAME','任务名称','fixedstr' FROM DUAL
WHERE NOT EXISTS(SELECT 1 FROM ld_desk  WHERE languagetype='zh' AND labelbol='LBL_AUTOMATICTASK_NAME' AND Labeltype='fixedstr');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype) SELECT 'en','LBL_AUTOMATICTASK_NAME','The Task Name','fixedstr' FROM DUAL
WHERE NOT EXISTS(SELECT 1 FROM ld_desk  WHERE languagetype='en' AND labelbol='LBL_AUTOMATICTASK_NAME' AND Labeltype='fixedstr');

INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype) SELECT 'zh','LBL_AUTOMATICTASK_TYPE','执行方式','fixedstr' FROM DUAL
WHERE NOT EXISTS(SELECT 1 FROM ld_desk  WHERE languagetype='zh' AND labelbol='LBL_AUTOMATICTASK_TYPE' AND Labeltype='fixedstr');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype) SELECT 'en','LBL_AUTOMATICTASK_TYPE','Execution Mode','fixedstr' FROM DUAL
WHERE NOT EXISTS(SELECT 1 FROM ld_desk  WHERE languagetype='en' AND labelbol='LBL_AUTOMATICTASK_TYPE' AND Labeltype='fixedstr');

INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype) SELECT 'zh','LBL_AUTOMATICTASK_FREQUENCY','执行频率','fixedstr' FROM DUAL
WHERE NOT EXISTS(SELECT 1 FROM ld_desk  WHERE languagetype='zh' AND labelbol='LBL_AUTOMATICTASK_FREQUENCY' AND Labeltype='fixedstr');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype) SELECT 'en','LBL_AUTOMATICTASK_FREQUENCY','Execution Frequency','fixedstr' FROM DUAL
WHERE NOT EXISTS(SELECT 1 FROM ld_desk  WHERE languagetype='en' AND labelbol='LBL_AUTOMATICTASK_FREQUENCY' AND Labeltype='fixedstr');

INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype) SELECT 'zh','LBL_AUTOMATICTASK_CONTENT','任务内容','fixedstr' FROM DUAL
WHERE NOT EXISTS(SELECT 1 FROM ld_desk  WHERE languagetype='zh' AND labelbol='LBL_AUTOMATICTASK_CONTENT' AND Labeltype='fixedstr');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype) SELECT 'en','LBL_AUTOMATICTASK_CONTENT','Task Content','fixedstr' FROM DUAL
WHERE NOT EXISTS(SELECT 1 FROM ld_desk  WHERE languagetype='en' AND labelbol='LBL_AUTOMATICTASK_CONTENT' AND Labeltype='fixedstr');

INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype) SELECT 'zh','LBL_AUTOMATICTASK_CUSTOMIZED','定制任务','fixedstr' FROM DUAL
WHERE NOT EXISTS(SELECT 1 FROM ld_desk  WHERE languagetype='zh' AND labelbol='LBL_AUTOMATICTASK_CUSTOMIZED' AND Labeltype='fixedstr');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype) SELECT 'en','LBL_AUTOMATICTASK_CUSTOMIZED','Customized task','fixedstr' FROM DUAL
WHERE NOT EXISTS(SELECT 1 FROM ld_desk  WHERE languagetype='en' AND labelbol='LBL_AUTOMATICTASK_CUSTOMIZED' AND Labeltype='fixedstr');

INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype) SELECT 'zh','LBL_AUTOMATICTASK_SQL','SQL脚本','fixedstr' FROM DUAL
WHERE NOT EXISTS(SELECT 1 FROM ld_desk  WHERE languagetype='zh' AND labelbol='LBL_AUTOMATICTASK_SQL' AND Labeltype='fixedstr');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype) SELECT 'en','LBL_AUTOMATICTASK_SQL','The SQL Script','fixedstr' FROM DUAL
WHERE NOT EXISTS(SELECT 1 FROM ld_desk  WHERE languagetype='en' AND labelbol='LBL_AUTOMATICTASK_SQL' AND Labeltype='fixedstr');
delimiter;


INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype) SELECT 'zh','LBL_AUTOMATIC_EXECUTION','自动执行','fixedstr' FROM DUAL
WHERE NOT EXISTS(SELECT 1 FROM ld_desk  WHERE languagetype='zh' AND labelbol='LBL_AUTOMATIC_EXECUTION' AND Labeltype='fixedstr');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype) SELECT 'en','LBL_AUTOMATIC_EXECUTION','Automatic Execution','fixedstr' FROM DUAL
WHERE NOT EXISTS(SELECT 1 FROM ld_desk  WHERE languagetype='en' AND labelbol='LBL_AUTOMATIC_EXECUTION' AND Labeltype='fixedstr');

INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype) SELECT 'zh','LBL_MANUAL_EXECUTION','手动执行','fixedstr' FROM DUAL
WHERE NOT EXISTS(SELECT 1 FROM ld_desk  WHERE languagetype='zh' AND labelbol='LBL_MANUAL_EXECUTION' AND Labeltype='fixedstr');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype) SELECT 'en','LBL_MANUAL_EXECUTION','Manual Execution','fixedstr' FROM DUAL
WHERE NOT EXISTS(SELECT 1 FROM ld_desk  WHERE languagetype='en' AND labelbol='LBL_MANUAL_EXECUTION' AND Labeltype='fixedstr');
delimiter;

INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype) SELECT 'zh','LBL_UPDATE_FOR','更新为','fixedstr' FROM DUAL
WHERE NOT EXISTS(SELECT 1 FROM ld_desk  WHERE languagetype='zh' AND labelbol='LBL_UPDATE_FOR' AND Labeltype='fixedstr');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype) SELECT 'en','LBL_UPDATE_FOR','Update For','fixedstr' FROM DUAL
WHERE NOT EXISTS(SELECT 1 FROM ld_desk  WHERE languagetype='en' AND labelbol='LBL_UPDATE_FOR' AND Labeltype='fixedstr');

INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype) SELECT 'zh','LBL_THENEWTASK','新任务','fixedstr' FROM DUAL
WHERE NOT EXISTS(SELECT 1 FROM ld_desk  WHERE languagetype='zh' AND labelbol='LBL_THENEWTASK' AND Labeltype='fixedstr');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype) SELECT 'en','LBL_THENEWTASK','The new task','fixedstr' FROM DUAL
WHERE NOT EXISTS(SELECT 1 FROM ld_desk  WHERE languagetype='en' AND labelbol='LBL_THENEWTASK' AND Labeltype='fixedstr');

INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype) SELECT 'zh','LBL_AUTOTASKSQLFILTER','此功能仅建议熟悉数据库的高级人员使用。','fixedstr' FROM DUAL
WHERE NOT EXISTS(SELECT 1 FROM ld_desk  WHERE languagetype='zh' AND labelbol='LBL_AUTOTASKSQLFILTER' AND Labeltype='fixedstr');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype) SELECT 'en','LBL_AUTOTASKSQLFILTER','This function is only recommend the use of senior personnel familiar with the database.','fixedstr' FROM DUAL
WHERE NOT EXISTS(SELECT 1 FROM ld_desk  WHERE languagetype='en' AND labelbol='LBL_AUTOTASKSQLFILTER' AND Labeltype='fixedstr');
delimiter;

INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype) SELECT 'zh','LBL_AUTOTASKCLOSE','自动任务已关闭，不能执行。','fixedstr' FROM DUAL
WHERE NOT EXISTS(SELECT 1 FROM ld_desk  WHERE languagetype='zh' AND labelbol='LBL_AUTOTASKCLOSE' AND Labeltype='fixedstr');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype) SELECT 'en','LBL_AUTOTASKCLOSE','Automatic task has been closed, can not be executed.','fixedstr' FROM DUAL
WHERE NOT EXISTS(SELECT 1 FROM ld_desk  WHERE languagetype='en' AND labelbol='LBL_AUTOTASKCLOSE' AND Labeltype='fixedstr');

INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype) SELECT 'zh','LBL_AUTOTASK_CHECKQUERY','SQL脚本格式不正确。','fixedstr' FROM DUAL
WHERE NOT EXISTS(SELECT 1 FROM ld_desk  WHERE languagetype='zh' AND labelbol='LBL_AUTOTASK_CHECKQUERY' AND Labeltype='fixedstr');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype) SELECT 'en','LBL_AUTOTASK_CHECKQUERY','The SQL script is not in the correct format.','fixedstr' FROM DUAL
WHERE NOT EXISTS(SELECT 1 FROM ld_desk  WHERE languagetype='en' AND labelbol='LBL_AUTOTASK_CHECKQUERY' AND Labeltype='fixedstr');
delimiter;
-- 2015-01-19

CREATE TABLE IF NOT EXISTS `ld_autotask_seq` (
	`id` INT(11) NOT NULL DEFAULT '0'
) ENGINE=INNODB DEFAULT CHARSET=utf8;
delimiter;

insert into ld_autotask_seq select 0 from dual 
where not exists(select id from ld_autotask_seq);

SELECT id INTO @autotaskid FROM ld_autotask_seq;
SELECT tabid INTO @tabid FROM ld_tab WHERE NAME = 'Accounts';
INSERT INTO ld_autotask(autotaskid,tabid,autotaskname,autotaskmode,autotaskdate,autotasktype,filtergroup,execution,presence) SELECT @autotaskid+1,@tabid,'30天未联系客户自动转公海',0,'day',1,'',0,1 FROM DUAL
WHERE NOT EXISTS(SELECT 1 FROM ld_autotask WHERE autotaskname='30天未联系客户自动转公海' AND tabid = @tabid);


select autotaskid into @autotaskid from ld_autotask where tabid=6 and autotaskname='30天未联系客户自动转公海';
INSERT INTO `ld_autotaskquery`(autotaskid,`query`) 
SELECT @autotaskid,concat("update ld_account set protectdate=NULL,publicaccount=1 where TIMESTAMPDIFF(DAY,ifnull(lastcontactdate,'2000-01-01'),now())>=30 and publicaccount=0;
DROP PROCEDURE IF EXISTS `task_Addremind`;
delimiter $$
CREATE  PROCEDURE `task_Addremind`(
)
BEGIN
     declare tmp_accountid  int default 0;
     declare tmp_accountname varchar(200) default '';
     declare tmp_smownerid  int default 0;
     declare mycursor cursor for select accountid, accountname,smownerid from ld_account where TIMESTAMPDIFF(DAY,ifnull(lastcontactdate,'2000-01-01'),now())>=30 and publicaccount=0;
     DECLARE CONTINUE HANDLER FOR SQLSTATE '02000' set tmp_accountid = NULL;
     open mycursor;
     fetch mycursor into tmp_accountid,tmp_accountname,tmp_smownerid;
     while(tmp_accountid is not null) DO
               set @maxid=0;
               select max(crmid) into @maxid from ld_crmentity;
               insert into ld_crmentity(crmid,setype)
               select @maxid+1,'Reminds';
               insert into ld_reminds(remindsid,content,date_time,recieverid,status_rmd,related_to,reltab,is_del_send,is_del_rec,reminds_ruleid,smownerid,smcreatorid,modifiedby,createdtime,modifiedtime,description,deleted)
      select @maxid+1,concat('计划任务：30天未联系客户自动转公海已执行，客户：',tmp_accountname,'已自动转公海！'),now(),tmp_smownerid,'未读',tmp_accountid,'Accounts',0,0,0,1,1,1,now(),now(),null,0;
               insert into ld_logpublicaccount(username,operation,opdate,accountid)
               select '系统管理员','计划任务：30天未联系客户自动转公海',NOW(),tmp_accountid;
               fetch mycursor into tmp_accountid,tmp_accountname,tmp_smownerid;
     end while;
     close mycursor;
END $$
DELIMITER;
call task_Addremind;
update ld_crmentity_seq set id=(select max(crmid) from ld_crmentity);
DELIMITER;") FROM DUAL
WHERE NOT EXISTS(SELECT 1 FROM ld_autotaskquery WHERE autotaskid=@autotaskid);

UPDATE ld_autotask_seq SET id = (SELECT MAX(autotaskid) AS COUNT FROM ld_autotask);
delimiter;

SELECT id INTO @autotaskid FROM ld_autotask_seq;
SELECT tabid INTO @tabid FROM ld_tab WHERE NAME = 'Contacts';
INSERT INTO ld_autotask(autotaskid,tabid,autotaskname,autotaskmode,autotaskdate,autotasktype,filtergroup,execution,presence) SELECT @autotaskid+1,@tabid,'联系人生日自动提醒',0,'day',1,'',0,1 FROM DUAL
WHERE NOT EXISTS(SELECT 1 FROM ld_autotask WHERE autotaskname='联系人生日自动提醒' AND tabid = @tabid);
delimiter;

select autotaskid into @autotaskid from ld_autotask where tabid=4 and autotaskname='联系人生日自动提醒';
INSERT INTO `ld_autotaskquery`(autotaskid,`query`) 
SELECT @autotaskid,concat("DROP PROCEDURE IF EXISTS `task_contact_birthday_reminds`; 
delimiter $$
CREATE PROCEDURE `task_contact_birthday_reminds`( 
) 
BEGIN 
DECLARE done int DEFAULT 0; 
DECLARE task_crmid int default 0; 
DECLARE task_name varchar(200) default ''; 
DECLARE task_user int default 0; 
DECLARE task_time datetime DEFAULT NOW(); 
DECLARE mycursor cursor for SELECT contactid,lastname,smownerid FROM ld_contactdetails WHERE deleted = 0 AND birthday != '' AND 
(DATE_FORMAT(birthday,'%m%d') - DATE_FORMAT(CURDATE(),'%m%d') = 0) ORDER BY contactid; 
DECLARE CONTINUE HANDLER for not found set done = 1; 
OPEN mycursor; 
fetch mycursor into task_crmid,task_name,task_user; 
LOOP1: WHILE done != 1 DO 
IF task_crmid > 0 THEN 
set @maxid = 0; 
select max(crmid) into @maxid from ld_crmentity; 
insert into ld_crmentity(crmid,setype) 
select @maxid+1,'Reminds'; 
insert into ld_reminds(remindsid,content,date_time,recieverid,status_rmd,related_to,reltab,is_del_send,is_del_rec,reminds_ruleid,smownerid,smcreatorid,modifiedby,createdtime,modifiedtime,description,deleted) 
select @maxid+1,concat('计划任务：联系人生日自动提醒已执行，今天是联系人：',task_name,'的生日，请送上生日的祝福。'),task_time,task_user,'未读',task_crmid,'Contacts',0,0,0,1,1,1,task_time,task_time,'',0; 
END IF; 
FETCH mycursor INTO task_crmid,task_name,task_user; 
END WHILE LOOP1; 
close mycursor; 
END $$
DELIMITER;
call `task_contact_birthday_reminds`(); 
update ld_crmentity_seq set id=(select max(crmid) from ld_crmentity); 
DELIMITER;") from dual
WHERE NOT EXISTS(SELECT 1 FROM ld_autotaskquery where autotaskid=@autotaskid);
delimiter;

UPDATE ld_autotask_seq SET id = (SELECT MAX(autotaskid) AS COUNT FROM ld_autotask);
delimiter;


Alter table ld_inventoryproductrel MODIFY balanceoutproductcount decimal(25,2);
delimiter;

Alter table ld_inventoryproductrel MODIFY balanceoutproductcount decimal(25,2);
delimiter;

select tabid into @tabid from ld_tab where `name`=  'SendCashBill';
update ld_field set uitype=201,typeofdata='V~O' where tabid = @tabid and fieldname = 'purchaseorder_id';
delimiter;

update ld_field set quickcreate = 3 where tabid = 22;
delimiter;

CALL AddColumn('LD_currencies','description','varchar','100',null);
delimiter;

update ld_currencies set currency_name='Albania, Lek',currency_code='ALL',currency_symbol='ALL',description='阿尔巴尼亚勒克' where currencyid=1;
update ld_currencies set currency_name='Argentina, Pesos',currency_code='ARP',currency_symbol='ARP',description='阿根廷比索' where currencyid=2;
update ld_currencies set currency_name='Aruba, Florins',currency_code='AWG',currency_symbol='AWG',description='阿鲁巴荷兰盾' where currencyid=3;
update ld_currencies set currency_name='Australia, Dollars',currency_code='AUD',currency_symbol='AUD',description='澳元' where currencyid=4;
update ld_currencies set currency_name='Azerbaijan, New Manats',currency_code='AZN',currency_symbol='AZN',description='阿塞拜疆新马纳特' where currencyid=5;
update ld_currencies set currency_name='Bahamas, Dollars',currency_code='BSD',currency_symbol='BSD',description='巴哈马元' where currencyid=6;
update ld_currencies set currency_name='Bahrain, Dinar',currency_code='BHD',currency_symbol='BHD',description='巴林第纳尔' where currencyid=7;
update ld_currencies set currency_name='Barbados, Dollars',currency_code='BBD',currency_symbol='BBD',description='巴巴多斯元' where currencyid=8;
update ld_currencies set currency_name='Belarus, Rubles',currency_code='BYR',currency_symbol='BYR',description='白俄罗斯卢布' where currencyid=9;
update ld_currencies set currency_name='Belize, Dollars',currency_code='BZD',currency_symbol='BZD',description='伯利兹元' where currencyid=10;

update ld_currencies set currency_name='Bermuda, Dollars',currency_code='BMD',currency_symbol='BMD',description='百慕大元' where currencyid=11;
update ld_currencies set currency_name='Bolivia, Pesos',currency_code='BOP',currency_symbol='BOP',description='玻利维亚比索' where currencyid=12;
update ld_currencies set currency_name='China, Yuan Renminbi',currency_code='CNY',currency_symbol='¥',description='人民币' where currencyid=13;
update ld_currencies set currency_name='Bosnia and Herzegovina, Convertible Marka',currency_code='BAM',currency_symbol='BAM',description='波黑马克' where currencyid=14;
update ld_currencies set currency_name='Botswana, Pulas',currency_code='BWP',currency_symbol='BWP',description='博兹瓦纳普拉' where currencyid=15;
update ld_currencies set currency_name='Bulgaria, Lei',currency_code='BGL',currency_symbol='BGL',description='保加利亚列弗' where currencyid=16;
update ld_currencies set currency_name='Brazil, New Cruzeiro G',currency_code='BRC',currency_symbol='BRC',description='新克鲁赛罗' where currencyid=17;
update ld_currencies set currency_name='United Kingdom, Pounds',currency_code='GBP',currency_symbol='￡',description='英镑' where currencyid=18;
update ld_currencies set currency_name='Brunei Darussalam, Dollars',currency_code='BND',currency_symbol='BND',description='文莱元' where currencyid=19;
update ld_currencies set currency_name='Canada, Dollars',currency_code='CAD',currency_symbol='CAD',description='加元 ' where currencyid=20;

update ld_currencies set currency_name='Cayman Islands, Dollars',currency_code='KYD',currency_symbol='KYD',description='开曼群岛元' where currencyid=21;
update ld_currencies set currency_name='Chile, Pesos',currency_code='CLP ',currency_symbol='CLP ',description='智利比索' where currencyid=22;
update ld_currencies set currency_name='Colombia, Pesos',currency_code='COP',currency_symbol='COP',description='哥伦比亚比索' where currencyid=23;
update ld_currencies set currency_name='Costa Rica, Colon',currency_code='CRC',currency_symbol='CRC',description='哥斯达黎加科朗' where currencyid=24;
update ld_currencies set currency_name='Croatia, Kuna',currency_code='HRK',currency_symbol='HRK',description='克罗地亚库纳' where currencyid=25;
update ld_currencies set currency_name='Cuba, Pesos',currency_code='CUP',currency_symbol='CUP',description='古巴比索 ' where currencyid=26;
update ld_currencies set currency_name='Czech Republic, Koruny',currency_code='CZK',currency_symbol='CZK',description='捷克克朗' where currencyid=27;
update ld_currencies set currency_name='Cyprus, Pounds',currency_code='CYP',currency_symbol='CYP',description='塞浦路斯镑' where currencyid=28;
update ld_currencies set currency_name='Denmark, Kroner',currency_code='DKK',currency_symbol='DKK',description='丹麦克朗' where currencyid=29;
update ld_currencies set currency_name='Dominican Republic, Pesos',currency_code='DOP',currency_symbol='DOP',description='多米尼加比索' where currencyid=30;

update ld_currencies set currency_name='East Caribbean, Dollars',currency_code='XCD',currency_symbol='XCD',description='东加勒比元' where currencyid=31;
update ld_currencies set currency_name='Egypt, Pounds',currency_code='EGP',currency_symbol='EGP',description='埃及镑' where currencyid=32;
update ld_currencies set currency_name='El Salvador, Colones',currency_code='SVC',currency_symbol='SVC',description='萨尔瓦多科朗' where currencyid=33;
update ld_currencies set currency_name='England, Pounds',currency_code='GBP',currency_symbol='￡',description='英镑' where currencyid=34;
update ld_currencies set currency_name='Estonia, Krooni',currency_code='EEK',currency_symbol='EEK',description='爱沙尼亚克朗' where currencyid=35;
update ld_currencies set currency_name='Euro',currency_code='EUR',currency_symbol='€',description='欧元' where currencyid=36;
update ld_currencies set currency_name='Falkland Islands, Pounds',currency_code='FKP',currency_symbol='FKP',description='福克兰群岛镑' where currencyid=37;
update ld_currencies set currency_name='Fiji, Dollars',currency_code='FJD',currency_symbol='FJD',description='斐济元' where currencyid=38;
update ld_currencies set currency_name='Ghana, Cedis',currency_code='GHC',currency_symbol='GHC',description='加纳赛地' where currencyid=39;
update ld_currencies set currency_name='Gibraltar, Pounds',currency_code='GIP',currency_symbol='GIP',description='直布罗陀镑' where currencyid=40;

update ld_currencies set currency_name='Guatemala, Quetzales',currency_code='GTQ',currency_symbol='GTQ',description='危地马拉格查尔' where currencyid=41;
update ld_currencies set currency_name='Guernsey, Pounds',currency_code='GGP',currency_symbol='GGP',description='根西岛镑' where currencyid=42;
update ld_currencies set currency_name='Guyana, Dollars',currency_code='GYD',currency_symbol='GYD',description='圭亚那元' where currencyid=43;
update ld_currencies set currency_name='Honduras, Lempiras',currency_code='HNL',currency_symbol='HNL',description='洪都拉斯伦皮拉' where currencyid=44;
update ld_currencies set currency_name='Hong Kong, Dollars',currency_code='HKD',currency_symbol='HKD',description='港元' where currencyid=45;
update ld_currencies set currency_name='Hungary, Forint',currency_code='HUF',currency_symbol='HUF',description='匈牙利福林' where currencyid=46;
update ld_currencies set currency_name='Iceland, Krona',currency_code='ISK',currency_symbol='ISK',description='冰岛克朗' where currencyid=47;
update ld_currencies set currency_name='India, Rupees',currency_code='INR',currency_symbol='INR',description='印度卢布' where currencyid=48;
update ld_currencies set currency_name='Indonesia, Rupiahs',currency_code='IDR',currency_symbol='IDR',description='印尼盾' where currencyid=49;
update ld_currencies set currency_name='Iran, Rials',currency_code='IRR',currency_symbol='IRR',description='伊朗里亚尔' where currencyid=50;

update ld_currencies set currency_symbol='IMP',description='马恩岛镑 ' where currencyid=51;
update ld_currencies set currency_symbol='ILS',description='以色列新谢克尔' where currencyid=52;
update ld_currencies set currency_symbol='JMD',description='牙买加元' where currencyid=53;
update ld_currencies set currency_symbol='JPY',description='日元' where currencyid=54;
update ld_currencies set currency_symbol='JEP',description='新泽西岛磅' where currencyid=55;
update ld_currencies set currency_symbol='JOD',description='约旦第纳尔' where currencyid=56;
update ld_currencies set currency_symbol='KZT',description='哈萨克斯坦坚戈' where currencyid=57;
update ld_currencies set currency_symbol='KES',description='肯尼亚先令' where currencyid=58;
update ld_currencies set currency_symbol='KPW',description='朝鲜元' where currencyid=59;
update ld_currencies set currency_symbol='KRW',description='韩元' where currencyid=60;

update ld_currencies set currency_symbol='KWD',description='科威特第纳尔' where currencyid=61;
update ld_currencies set currency_symbol='KGS',description='吉尔吉斯斯坦索姆' where currencyid=62;
update ld_currencies set currency_symbol='LAK',description='老挝基普' where currencyid=63;
update ld_currencies set currency_symbol='LVL',description='拉脱维亚拉提' where currencyid=64;
update ld_currencies set currency_symbol='LBP',description='黎巴嫩镑' where currencyid=65;
update ld_currencies set currency_symbol='LRD',description='利比里亚元' where currencyid=66;
update ld_currencies set currency_symbol='CHF',description='瑞士法郎' where currencyid=67;
update ld_currencies set currency_symbol='LTL',description='立陶宛立特' where currencyid=68;
update ld_currencies set currency_symbol='MGA',description='马达加斯加阿里亚里' where currencyid=69;
update ld_currencies set currency_symbol='MKD',description='马其顿第纳尔' where currencyid=70; 

update ld_currencies set currency_symbol='MYR',description='马来西亚林吉特' where currencyid=71;
update ld_currencies set currency_symbol='MTL',description='马耳他里拉' where currencyid=72;
update ld_currencies set currency_symbol='MUR',description='毛里求斯卢比' where currencyid=73;
update ld_currencies set currency_symbol='MXP',description='墨西哥比索' where currencyid=74;
update ld_currencies set currency_symbol='MNT',description='蒙古图格里克' where currencyid=75;
update ld_currencies set currency_symbol='MZN',description='莫桑比克梅蒂卡尔' where currencyid=76;
update ld_currencies set currency_symbol='NAD',description='纳米比亚元' where currencyid=77;
update ld_currencies set currency_symbol='NPR',description='尼泊尔卢比' where currencyid=78;
update ld_currencies set currency_name='Netherlands Antilles, Florins',currency_symbol='ANG',description='列斯荷兰盾' where currencyid=79;
update ld_currencies set currency_symbol='NZD',description='新西兰元' where currencyid=80;

update ld_currencies set currency_symbol='NIO',description='尼加拉瓜科多巴' where currencyid=81;
update ld_currencies set currency_symbol='NGN',description='尼日利亚奈拉' where currencyid=82;
update ld_currencies set currency_symbol='KPW',description='朝鲜元' where currencyid=83;
update ld_currencies set currency_symbol='NOK',description='挪威克朗 ' where currencyid=84;
update ld_currencies set currency_symbol='OMR',description='阿曼里亚尔' where currencyid=85;
update ld_currencies set currency_symbol='PKR',description='巴基斯坦卢比' where currencyid=86;
update ld_currencies set currency_symbol='PAB',description='巴拿马巴尔博亚' where currencyid=87;
update ld_currencies set currency_symbol='PYG',description='巴拉圭瓜拉尼' where currencyid=88;
update ld_currencies set currency_symbol='PEN',description='秘鲁新索尔' where currencyid=89;
update ld_currencies set currency_symbol='PHP',description='菲律宾比索' where currencyid=90;

update ld_currencies set currency_symbol='PLN',description='波兰兹罗提' where currencyid=91;
update ld_currencies set currency_symbol='QAR',description='卡塔尔里亚尔' where currencyid=92;
update ld_currencies set currency_symbol='RON',description='罗马尼亚新雷' where currencyid=93;
update ld_currencies set currency_symbol='RUB',description='俄罗斯卢布 ' where currencyid=94;
update ld_currencies set currency_symbol='SHP',description='圣赫勒拿镑' where currencyid=95;
update ld_currencies set currency_symbol='SAR',description='沙特阿拉伯里亚尔' where currencyid=96;
update ld_currencies set currency_symbol='RSD',description='塞尔维亚第纳尔' where currencyid=97;
update ld_currencies set currency_symbol='SCR',description='塞舌尔卢比' where currencyid=98;
update ld_currencies set currency_symbol='SGD',description='新元' where currencyid=99;
update ld_currencies set currency_symbol='SBD',description='所罗门群岛元' where currencyid=100;

update ld_currencies set currency_symbol='SOS',description='索马里先令' where currencyid=101;
update ld_currencies set currency_symbol='ZAR',description='南非兰特' where currencyid=102;
update ld_currencies set currency_symbol='KRW',description='韩元' where currencyid=103;
update ld_currencies set currency_symbol='LKR',description='斯里兰卡卢比' where currencyid=104;
update ld_currencies set currency_symbol='SEK',description='瑞典克朗' where currencyid=105;
update ld_currencies set currency_symbol='CHF',description='瑞士法郎' where currencyid=106;
update ld_currencies set currency_symbol='SRD',description='苏里南元' where currencyid=107;
update ld_currencies set currency_symbol='SYP',description='叙利亚镑' where currencyid=108;
update ld_currencies set currency_symbol='TWD',description='新台币' where currencyid=109;
update ld_currencies set currency_symbol='THB',description='泰铢' where currencyid=110;

update ld_currencies set currency_symbol='TTD',description='特里尼达和多巴哥元' where currencyid=111;
update ld_currencies set currency_symbol='TRY',description='土耳其新里拉' where currencyid=112;
update ld_currencies set currency_symbol='TRL',description='土耳其里拉' where currencyid=113;
update ld_currencies set currency_symbol='TVD',description='图瓦卢美元' where currencyid=114;
update ld_currencies set currency_symbol='UAH',description='乌克兰赫夫纳' where currencyid=115;
update ld_currencies set currency_symbol='AED',description='阿联酋迪拉姆' where currencyid=116;
update ld_currencies set currency_symbol='￡',description='英镑' where currencyid=117;
update ld_currencies set currency_symbol='TZS',description='坦桑尼亚先令' where currencyid=118;
update ld_currencies set currency_symbol='$',description='美元' where currencyid=119;
update ld_currencies set currency_name='Uruguay, New Pesos',currency_symbol='UYU',description='乌拉圭新比索' where currencyid=120;

update ld_currencies set currency_symbol='UZS',description='乌兹别克斯坦苏姆' where currencyid=121;
update ld_currencies set currency_symbol='VEF',description='委内瑞拉玻利瓦尔' where currencyid=122;
update ld_currencies set currency_symbol='VND',description='越南盾' where currencyid=123;
update ld_currencies set currency_symbol='ZMK',description='赞比亚克瓦查' where currencyid=124;
update ld_currencies set currency_symbol='YER',description='也门里亚尔' where currencyid=125;
update ld_currencies set currency_symbol='ZWD',description='津巴布韦元' where currencyid=126;
update ld_currencies set currency_symbol='MWK',description='马拉维克瓦查' where currencyid=127;
update ld_currencies set currency_code='TND', currency_symbol='TND',description='突尼斯第纳尔' where currencyid=128;
update ld_currencies set currency_symbol='MAD',description='摩洛哥迪拉姆' where currencyid=129;

update ld_currency_info set currency_name='Albania, Lek' where currency_name='Albania, Leke';
update ld_currency_info set currency_name='Hong Kong, Dollars' where currency_name='LvHong Kong, Dollars';
update ld_currency_info set currency_name='Bosnia and Herzegovina, Convertible Marka' where currency_name='Convertible Marka';
update ld_currency_info set currency_name='Bulgaria, Lei' where currency_name='Bulgaria, Leva';
update ld_currency_info set currency_name='Brazil, New Cruzeiro G' where currency_name='Brazil, Reais';
update ld_currency_info set currency_name='United Kingdom, Pounds' where currency_name='Great Britain Pounds';
update ld_currency_info set currency_name='Costa Rica, Colon' where currency_name='Costa Rica, Colón';
update ld_currency_info set currency_name='Uruguay, New Pesos' where currency_name='Uruguay, Pesos';
update ld_currency_info set currency_name='Netherlands Antilles, Florins' where currency_name='Netherlands Antilles, Guilders';
delimiter;

delete from ld_currencies where currencyid=103; 
delete from ld_currencies where currencyid=83;
delete from ld_currencies where currencyid=106; 
delete from ld_currencies where currencyid=34; 
delete from ld_currencies where currencyid=117; 
delimiter;

update ld_currency_info
inner join ld_currencies on ld_currency_info.currency_name=ld_currencies.currency_name 
set ld_currency_info.currency_code=ld_currencies.currency_code,ld_currency_info.currency_symbol=ld_currencies.currency_symbol;
delimiter;

update ld_currency_info set currency_name='Korea (North), Won' where currency_name='North Korea, Won';
update ld_currency_info set currency_name='Korea (South), Won' where currency_name='South Korea, Won';
update ld_currency_info set currency_name='Switzerland Francs' where currency_name='Switzerland, Francs';
update ld_currency_info set currency_name='United Kingdom, Pounds' where currency_name='England, Pounds';
delimiter;

update ld_salesorder set currency_id=1,currency_symbol='¥' where ifnull(currency_id,0)=0;
update ld_salesorder
left join ld_currency_info on ld_currency_info.id=ld_salesorder.currency_id
set ld_salesorder.currency_symbol=ld_currency_info.currency_symbol;

update ld_servicecontracts set currency_id=1,currency_symbol='¥' where ifnull(currency_id,0)=0;
update ld_servicecontracts
left join ld_currency_info on ld_currency_info.id=ld_servicecontracts.currency_id
set ld_servicecontracts.currency_symbol=ld_currency_info.currency_symbol;

update ld_bankaccountset set currency_id=1,currency_symbol='¥' where ifnull(currency_id,0)=0;
update ld_bankaccountset
left join ld_currency_info on ld_currency_info.id=ld_bankaccountset.currency_id
set ld_bankaccountset.currency_symbol=ld_currency_info.currency_symbol;

update LD_potential set currency_id=1,currency_symbol='¥' where ifnull(currency_id,0)=0;
update LD_potential
left join ld_currency_info on ld_currency_info.id=LD_potential.currency_id
set LD_potential.currency_symbol=ld_currency_info.currency_symbol;

update LD_paymentplan set currency_id=1,currency_symbol='¥' where ifnull(currency_id,0)=0;
update LD_paymentplan
left join ld_currency_info on ld_currency_info.id=LD_paymentplan.currency_id
set LD_paymentplan.currency_symbol=ld_currency_info.currency_symbol;

update LD_cashbill set currency_id=1,currency_symbol='¥' where ifnull(currency_id,0)=0;
update LD_cashbill
left join ld_currency_info on ld_currency_info.id=LD_cashbill.currency_id
set LD_cashbill.currency_symbol=ld_currency_info.currency_symbol;

update LD_purchaseorder set currency_id=1,currency_symbol='¥' where ifnull(currency_id,0)=0;
update LD_purchaseorder
left join ld_currency_info on ld_currency_info.id=LD_purchaseorder.currency_id
set LD_purchaseorder.currency_symbol=ld_currency_info.currency_symbol;

update LD_sendpayment set currency_id=1,currency_symbol='¥' where ifnull(currency_id,0)=0;
update LD_sendpayment
left join ld_currency_info on ld_currency_info.id=LD_sendpayment.currency_id
set LD_sendpayment.currency_symbol=ld_currency_info.currency_symbol;

update LD_sendcashbill set currency_id=1,currency_symbol='¥' where ifnull(currency_id,0)=0;
update LD_sendcashbill
left join ld_currency_info on ld_currency_info.id=LD_sendcashbill.currency_id
set LD_sendcashbill.currency_symbol=ld_currency_info.currency_symbol;

update LD_commission set currency_id=1,currency_symbol='¥' where ifnull(currency_id,0)=0;
update LD_commission
left join ld_currency_info on ld_currency_info.id=LD_commission.currency_id
set LD_commission.currency_symbol=ld_currency_info.currency_symbol;

update LD_expense set currency_id=1,currency_symbol='¥' where ifnull(currency_id,0)=0;
update LD_expense
left join ld_currency_info on ld_currency_info.id=LD_expense.currency_id
set LD_expense.currency_symbol=ld_currency_info.currency_symbol;

update LD_putcash set currency_id=1,currency_symbol='¥' where ifnull(currency_id,0)=0;
update LD_putcash
left join ld_currency_info on ld_currency_info.id=LD_putcash.currency_id
set LD_putcash.currency_symbol=ld_currency_info.currency_symbol;

update LD_cashdeposit set currency_id=1,currency_symbol='¥' where ifnull(currency_id,0)=0;
update LD_cashdeposit
left join ld_currency_info on ld_currency_info.id=LD_cashdeposit.currency_id
set LD_cashdeposit.currency_symbol=ld_currency_info.currency_symbol;

update LD_quotes set currency_id=1,currency_symbol='¥' where ifnull(currency_id,0)=0;
update LD_quotes
left join ld_currency_info on ld_currency_info.id=LD_quotes.currency_id
set LD_quotes.currency_symbol=ld_currency_info.currency_symbol;

update LD_salesback set currency_id=1,currency_symbol='¥' where ifnull(currency_id,0)=0;
update LD_salesback 
left join ld_currency_info on ld_currency_info.id=LD_salesback.currency_id
set LD_salesback.currency_symbol=ld_currency_info.currency_symbol;

update LD_purchaseinvoice set currency_id=1,currency_symbol='¥' where ifnull(currency_id,0)=0;
update LD_purchaseinvoice 
left join ld_currency_info on ld_currency_info.id=LD_purchaseinvoice.currency_id
set LD_purchaseinvoice.currency_symbol=ld_currency_info.currency_symbol;

update LD_cashback set currency_id=1,currency_symbol='¥' where ifnull(currency_id,0)=0;
update LD_cashback 
left join ld_currency_info on ld_currency_info.id=LD_cashback.currency_id
set LD_cashback.currency_symbol=ld_currency_info.currency_symbol;

update LD_purchasecashback set currency_id=1,currency_symbol='¥' where ifnull(currency_id,0)=0;
update LD_purchasecashback 
left join ld_currency_info on ld_currency_info.id=LD_purchasecashback.currency_id
set LD_purchasecashback.currency_symbol=ld_currency_info.currency_symbol;

update LD_outboundorder set currency_id=1,currency_symbol='¥' where ifnull(currency_id,0)=0;
update LD_outboundorder 
left join ld_currency_info on ld_currency_info.id=LD_outboundorder.currency_id
set LD_outboundorder.currency_symbol=ld_currency_info.currency_symbol;

update LD_stock set currency_id=1,currency_symbol='¥' where ifnull(currency_id,0)=0;
update LD_stock 
left join ld_currency_info on ld_currency_info.id=LD_stock.currency_id
set LD_stock.currency_symbol=ld_currency_info.currency_symbol;

update LD_warehousetransfer set currency_id=1,currency_symbol='¥' where ifnull(currency_id,0)=0;
update LD_warehousetransfer 
left join ld_currency_info on ld_currency_info.id=LD_warehousetransfer.currency_id
set LD_warehousetransfer.currency_symbol=ld_currency_info.currency_symbol;

update LD_productbom set currency_id=1,currency_symbol='¥' where ifnull(currency_id,0)=0;
update LD_productbom 
left join ld_currency_info on ld_currency_info.id=LD_productbom.currency_id
set LD_productbom.currency_symbol=ld_currency_info.currency_symbol;

update LD_checks set currency_id=1,currency_symbol='¥' where ifnull(currency_id,0)=0;
update LD_checks 
left join ld_currency_info on ld_currency_info.id=LD_checks.currency_id
set LD_checks.currency_symbol=ld_currency_info.currency_symbol;

update LD_pricebook set currency_id=1,currency_symbol='¥' where ifnull(currency_id,0)=0;
update LD_pricebook 
left join ld_currency_info on ld_currency_info.id=LD_pricebook.currency_id
set LD_pricebook.currency_symbol=ld_currency_info.currency_symbol;
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'zh','MESSAGESNOTCHECKED','没有勾选短信，发送失败！','jspop' from dual 
where not EXISTS(select 1 from ld_desk  where languagetype='zh' and labelbol='MESSAGESNOTCHECKED' and Labeltype='jspop');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'en','MESSAGESNOTCHECKED','Do not check the message, send failure!','jspop' from dual 
where not EXISTS(select 1 from ld_desk  where languagetype='en' and labelbol='MESSAGESNOTCHECKED' and Labeltype='jspop');
delimiter;
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'zh','SMS1RECIPIENTISEMPTY','短信1接收人信息为空！','jspop' from dual 
where not EXISTS(select 1 from ld_desk  where languagetype='zh' and labelbol='SMS1RECIPIENTISEMPTY' and Labeltype='jspop');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'en','SMS1RECIPIENTISEMPTY','SMS 1 recipient information is empty!','jspop' from dual 
where not EXISTS(select 1 from ld_desk  where languagetype='en' and labelbol='SMS1RECIPIENTISEMPTY' and Labeltype='jspop');
delimiter;
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'zh','SMS1RECEPTIONCONTENTEMPTY','短信1接收内容为空！','jspop' from dual 
where not EXISTS(select 1 from ld_desk  where languagetype='zh' and labelbol='SMS1RECEPTIONCONTENTEMPTY' and Labeltype='jspop');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'en','SMS1RECEPTIONCONTENTEMPTY','SMS 1 receives the content is empty!','jspop' from dual 
where not EXISTS(select 1 from ld_desk  where languagetype='en' and labelbol='SMS1RECEPTIONCONTENTEMPTY' and Labeltype='jspop');
delimiter;
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'zh','SMS2RECIPIENTISEMPTY','短信2接收人信息为空！','jspop' from dual 
where not EXISTS(select 1 from ld_desk  where languagetype='zh' and labelbol='SMS2RECIPIENTISEMPTY' and Labeltype='jspop');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'en','SMS2RECIPIENTISEMPTY','SMS 2 recipient information is empty!','jspop' from dual 
where not EXISTS(select 1 from ld_desk  where languagetype='en' and labelbol='SMS2RECIPIENTISEMPTY' and Labeltype='jspop');
delimiter;
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'zh','SMS2RECEPTIONCONTENTEMPTY','短信2接收内容为空！','jspop' from dual 
where not EXISTS(select 1 from ld_desk  where languagetype='zh' and labelbol='SMS2RECEPTIONCONTENTEMPTY' and Labeltype='jspop');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'en','SMS2RECEPTIONCONTENTEMPTY','SMS 2 receives the content is empty!','jspop' from dual 
where not EXISTS(select 1 from ld_desk  where languagetype='en' and labelbol='SMS2RECEPTIONCONTENTEMPTY' and Labeltype='jspop');
delimiter;
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'zh','SMS3RECIPIENTISEMPTY','短信3接收人信息为空！','jspop' from dual 
where not EXISTS(select 1 from ld_desk  where languagetype='zh' and labelbol='SMS3RECIPIENTISEMPTY' and Labeltype='jspop');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'en','SMS3RECIPIENTISEMPTY','SMS 3 recipient information is empty!','jspop' from dual 
where not EXISTS(select 1 from ld_desk  where languagetype='en' and labelbol='SMS3RECIPIENTISEMPTY' and Labeltype='jspop');
delimiter;
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'zh','SMS3RECIPIENTISEMPTY','短信3接收内容为空！','jspop' from dual 
where not EXISTS(select 1 from ld_desk  where languagetype='zh' and labelbol='SMS3RECIPIENTISEMPTY' and Labeltype='jspop');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'en','SMS3RECIPIENTISEMPTY','SMS 3 receives the content is empty!','jspop' from dual 
where not EXISTS(select 1 from ld_desk  where languagetype='en' and labelbol='SMS3RECIPIENTISEMPTY' and Labeltype='jspop');
delimiter;
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'zh','PLEASESELECTANITEM','请选择一项！','jspop' from dual 
where not EXISTS(select 1 from ld_desk  where languagetype='zh' and labelbol='PLEASESELECTANITEM' and Labeltype='jspop');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'en','PLEASESELECTANITEM','Please select an item!','jspop' from dual 
where not EXISTS(select 1 from ld_desk  where languagetype='en' and labelbol='PLEASESELECTANITEM' and Labeltype='jspop');
delimiter;
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'zh','ATLEASTONEASSIGNMENT','至少有一个参数要赋值！','jspop' from dual 
where not EXISTS(select 1 from ld_desk  where languagetype='zh' and labelbol='ATLEASTONEASSIGNMENT' and Labeltype='jspop');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'en','ATLEASTONEASSIGNMENT','At least one parameter assignment!','jspop' from dual 
where not EXISTS(select 1 from ld_desk  where languagetype='en' and labelbol='ATLEASTONEASSIGNMENT' and Labeltype='jspop');
delimiter;
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'zh','DAYSENTERPOSITIVENUMBER','天数请输入正整数！','jspop' from dual 
where not EXISTS(select 1 from ld_desk  where languagetype='zh' and labelbol='DAYSENTERPOSITIVENUMBER' and Labeltype='jspop');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'en','DAYSENTERPOSITIVENUMBER','Please enter a positive integer number of days!','jspop' from dual 
where not EXISTS(select 1 from ld_desk  where languagetype='en' and labelbol='DAYSENTERPOSITIVENUMBER' and Labeltype='jspop');
delimiter;
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'zh','HOURSENTERPOSITIVENUMBER','小时请输入正整数！','jspop' from dual 
where not EXISTS(select 1 from ld_desk  where languagetype='zh' and labelbol='HOURSENTERPOSITIVENUMBER' and Labeltype='jspop');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'en','HOURSENTERPOSITIVENUMBER','Hours please enter a positive integer!','jspop' from dual 
where not EXISTS(select 1 from ld_desk  where languagetype='en' and labelbol='HOURSENTERPOSITIVENUMBER' and Labeltype='jspop');
delimiter;
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'zh','MINUTESENTERPOSITIVENUMBER','分钟请输入正整数！','jspop' from dual 
where not EXISTS(select 1 from ld_desk  where languagetype='zh' and labelbol='MINUTESENTERPOSITIVENUMBER' and Labeltype='jspop');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'en','MINUTESENTERPOSITIVENUMBER','Minutes please enter a positive integer!','jspop' from dual 
where not EXISTS(select 1 from ld_desk  where languagetype='en' and labelbol='MINUTESENTERPOSITIVENUMBER' and Labeltype='jspop');
delimiter;
-- 2015-01-20

insert into ld_systems_deploy(deploy_value,deploy_type,description,setype)
select '',63,'合同订单编辑保存后
是否自动生成出库单。仓库名称为空:否，仓库名称不为空:是','' from dual 
where not exists(select 1 from ld_systems_deploy where deploy_type=63);
delimiter;
insert into ld_desk(languagetype,labelbol,fieldlabel,Labeltype)
select 'zh','AFTEREDITSALESORDERCREATEOUTORDER','{$SalesOrder.SalesOrder}编辑保存后自动创建{$OutboundOrder.OutboundOrder}，关联仓库（为空表示不创建）','fixedstr' 
from DUAL where not EXISTS(select 1 from ld_desk where labelbol='AFTEREDITSALESORDERCREATEOUTORDER' and languagetype='zh');
insert into ld_desk(languagetype,labelbol,fieldlabel,Labeltype)
select 'en','AFTEREDITSALESORDERCREATEOUTORDER','After edit salesorder create outbound order automaticly，the related warhouse is','fixedstr' 
from DUAL where not EXISTS(select 1 from ld_desk where labelbol='AFTEREDITSALESORDERCREATEOUTORDER' and languagetype='en');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'zh','cheer100','集家网报表','fixedstr' from dual 
where not EXISTS(select 1 from ld_desk  where languagetype='zh' and labelbol='cheer100' and Labeltype='fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'en','cheer100','cheer100','fixedstr' from dual 
where not EXISTS(select 1 from ld_desk  where languagetype='en' and labelbol='cheer100' and Labeltype='fixedstr');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'zh','TheProjectSalesOrderNo','立项号/合同号','fixedstr' from dual 
where not EXISTS(select 1 from ld_desk  where languagetype='zh' and labelbol='TheProjectSalesOrderNo' and Labeltype='fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'en','TheProjectSalesOrderNo','The Project/SalesOrder No.','fixedstr' from dual 
where not EXISTS(select 1 from ld_desk  where languagetype='en' and labelbol='TheProjectSalesOrderNo' and Labeltype='fixedstr');
delimiter;


insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'zh','Thecompanyprojectsdate','公司立项日期','fixedstr' from dual 
where not EXISTS(select 1 from ld_desk  where languagetype='zh' and labelbol='Thecompanyprojectsdate' and Labeltype='fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'en','Thecompanyprojectsdate','The company projects date','fixedstr' from dual 
where not EXISTS(select 1 from ld_desk  where languagetype='en' and labelbol='Thecompanyprojectsdate' and Labeltype='fixedstr');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'zh','Sourceofinformation','信息来源','fixedstr' from dual 
where not EXISTS(select 1 from ld_desk  where languagetype='zh' and labelbol='Sourceofinformation' and Labeltype='fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'en','Sourceofinformation','Source of information','fixedstr' from dual 
where not EXISTS(select 1 from ld_desk  where languagetype='en' and labelbol='Sourceofinformation' and Labeltype='fixedstr');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'zh','Sourceofinformation','信息来源','fixedstr' from dual 
where not EXISTS(select 1 from ld_desk  where languagetype='zh' and labelbol='Sourceofinformation' and Labeltype='fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'en','Sourceofinformation','Source of information','fixedstr' from dual 
where not EXISTS(select 1 from ld_desk  where languagetype='en' and labelbol='Sourceofinformation' and Labeltype='fixedstr');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'zh','TheSalesDepartment','销售部门','fixedstr' from dual 
where not EXISTS(select 1 from ld_desk  where languagetype='zh' and labelbol='TheSalesDepartment' and Labeltype='fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'en','TheSalesDepartment','The Sales Department','fixedstr' from dual 
where not EXISTS(select 1 from ld_desk  where languagetype='en' and labelbol='TheSalesDepartment' and Labeltype='fixedstr');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'zh','Salespersonnel','销售人员','fixedstr' from dual 
where not EXISTS(select 1 from ld_desk  where languagetype='zh' and labelbol='Salespersonnel' and Labeltype='fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'en','Salespersonnel','Sales personnel','fixedstr' from dual 
where not EXISTS(select 1 from ld_desk  where languagetype='en' and labelbol='Salespersonnel' and Labeltype='fixedstr');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'zh','Technicalpersonnel','技术人员','fixedstr' from dual 
where not EXISTS(select 1 from ld_desk  where languagetype='zh' and labelbol='Technicalpersonnel' and Labeltype='fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'en','Technicalpersonnel','Technical personnel','fixedstr' from dual 
where not EXISTS(select 1 from ld_desk  where languagetype='en' and labelbol='Technicalpersonnel' and Labeltype='fixedstr');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'zh','Projectsupervision','项目监理','fixedstr' from dual 
where not EXISTS(select 1 from ld_desk  where languagetype='zh' and labelbol='Projectsupervision' and Labeltype='fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'en','Projectsupervision','Project supervision','fixedstr' from dual 
where not EXISTS(select 1 from ld_desk  where languagetype='en' and labelbol='Projectsupervision' and Labeltype='fixedstr');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'zh','Constructionteam','施工班组','fixedstr' from dual 
where not EXISTS(select 1 from ld_desk  where languagetype='zh' and labelbol='Constructionteam' and Labeltype='fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'en','Constructionteam','Construction team','fixedstr' from dual 
where not EXISTS(select 1 from ld_desk  where languagetype='en' and labelbol='Constructionteam' and Labeltype='fixedstr');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'zh','Constructionteam','客户名称','fixedstr' from dual 
where not EXISTS(select 1 from ld_desk  where languagetype='zh' and labelbol='Constructionteam' and Labeltype='fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'en','Constructionteam','Construction team','fixedstr' from dual 
where not EXISTS(select 1 from ld_desk  where languagetype='en' and labelbol='Constructionteam' and Labeltype='fixedstr');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'zh','Projectaddress','项目地址','fixedstr' from dual 
where not EXISTS(select 1 from ld_desk  where languagetype='zh' and labelbol='Projectaddress' and Labeltype='fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'en','Projectaddress','Project address','fixedstr' from dual 
where not EXISTS(select 1 from ld_desk  where languagetype='en' and labelbol='Projectaddress' and Labeltype='fixedstr');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'zh','Typehousing','房屋类型','fixedstr' from dual 
where not EXISTS(select 1 from ld_desk  where languagetype='zh' and labelbol='Typehousing' and Labeltype='fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'en','Typehousing','Type of housing','fixedstr' from dual 
where not EXISTS(select 1 from ld_desk  where languagetype='en' and labelbol='Typehousing' and Labeltype='fixedstr');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'zh','Theprojectbrand','立项品牌','fixedstr' from dual 
where not EXISTS(select 1 from ld_desk  where languagetype='zh' and labelbol='Theprojectbrand' and Labeltype='fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'en','Theprojectbrand','The project brand','fixedstr' from dual 
where not EXISTS(select 1 from ld_desk  where languagetype='en' and labelbol='Theprojectbrand' and Labeltype='fixedstr');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'zh','Thedevicename','设备名称','fixedstr' from dual 
where not EXISTS(select 1 from ld_desk  where languagetype='zh' and labelbol='Thedevicename' and Labeltype='fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'en','Thedevicename','The device name','fixedstr' from dual 
where not EXISTS(select 1 from ld_desk  where languagetype='en' and labelbol='Thedevicename' and Labeltype='fixedstr');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'zh','Specifications','规格型号','fixedstr' from dual 
where not EXISTS(select 1 from ld_desk  where languagetype='zh' and labelbol='Specifications' and Labeltype='fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'en','Specifications','Specifications','fixedstr' from dual 
where not EXISTS(select 1 from ld_desk  where languagetype='en' and labelbol='Specifications' and Labeltype='fixedstr');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'zh','Datecontract','签定日期','fixedstr' from dual 
where not EXISTS(select 1 from ld_desk  where languagetype='zh' and labelbol='Datecontract' and Labeltype='fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'en','Datecontract','Date of contract','fixedstr' from dual 
where not EXISTS(select 1 from ld_desk  where languagetype='en' and labelbol='Datecontract' and Labeltype='fixedstr');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'zh','Thetotalamountcontract','总合同金额','fixedstr' from dual 
where not EXISTS(select 1 from ld_desk  where languagetype='zh' and labelbol='Thetotalamountcontract' and Labeltype='fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'en','Thetotalamountcontract','The total amount of the contract','fixedstr' from dual 
where not EXISTS(select 1 from ld_desk  where languagetype='en' and labelbol='Thetotalamountcontract' and Labeltype='fixedstr');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'zh','billamount','签单金额','fixedstr' from dual 
where not EXISTS(select 1 from ld_desk  where languagetype='zh' and labelbol='billamount' and Labeltype='fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'en','billamount','bill amount','fixedstr' from dual 
where not EXISTS(select 1 from ld_desk  where languagetype='en' and labelbol='billamount' and Labeltype='fixedstr');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'zh','Servicefee','业务费','fixedstr' from dual 
where not EXISTS(select 1 from ld_desk  where languagetype='zh' and labelbol='Servicefee' and Labeltype='fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'en','Servicefee','Service fee','fixedstr' from dual 
where not EXISTS(select 1 from ld_desk  where languagetype='en' and labelbol='Servicefee' and Labeltype='fixedstr');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'zh','Receivables','应收款','fixedstr' from dual 
where not EXISTS(select 1 from ld_desk  where languagetype='zh' and labelbol='Receivables' and Labeltype='fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'en','Receivables','Receivables','fixedstr' from dual 
where not EXISTS(select 1 from ld_desk  where languagetype='en' and labelbol='Receivables' and Labeltype='fixedstr');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'zh','Orderchange','合同变更','fixedstr' from dual 
where not EXISTS(select 1 from ld_desk  where languagetype='zh' and labelbol='Orderchange' and Labeltype='fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'en','Orderchange','Order change','fixedstr' from dual 
where not EXISTS(select 1 from ld_desk  where languagetype='en' and labelbol='Orderchange' and Labeltype='fixedstr');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'zh','Factoryprojectstatus','厂家立项状态','fixedstr' from dual 
where not EXISTS(select 1 from ld_desk  where languagetype='zh' and labelbol='Factoryprojectstatus' and Labeltype='fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'en','Factoryprojectstatus','Factory project status','fixedstr' from dual 
where not EXISTS(select 1 from ld_desk  where languagetype='en' and labelbol='Factoryprojectstatus' and Labeltype='fixedstr');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'zh','Orderstatus2','订单状态','fixedstr' from dual 
where not EXISTS(select 1 from ld_desk  where languagetype='zh' and labelbol='Orderstatus2' and Labeltype='fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'en','Orderstatus2','Order status','fixedstr' from dual 
where not EXISTS(select 1 from ld_desk  where languagetype='en' and labelbol='Orderstatus2' and Labeltype='fixedstr');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'zh','Constructionstate','施工状态','fixedstr' from dual 
where not EXISTS(select 1 from ld_desk  where languagetype='zh' and labelbol='Constructionstate' and Labeltype='fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'en','Constructionstate','Construction state','fixedstr' from dual 
where not EXISTS(select 1 from ld_desk  where languagetype='en' and labelbol='Constructionstate' and Labeltype='fixedstr');
delimiter;

update ld_desk set fieldlabel = '只能输入正整数和0，不设置定时规则可输入0' 
where labelbol = 'ONLYENTERPOSITIVEINTEGER' and languagetype = 'zh';
update ld_desk set fieldlabel = 'You can only enter a positive integer and 0, timing rules can input 0 does not set' 
where labelbol = 'ONLYENTERPOSITIVEINTEGER' and languagetype = 'en';
delimiter; 

call AddColumn('LD_salesorder','dianshang_orderno','varchar','100',NULL); 

select tabid into @tabid from ld_tab where name='SalesOrder';
select blockid into @blockid from ld_blocks where tabid = @tabid and blocklabel = 'LBL_SO_INFORMATION';

update ld_field_seq set id=id+1 where not exists (select 1 from ld_field where tabid = @tabid and columnname = 'dianshang_orderno')
and  EXISTS (select 1 from ld_version where trade='adoodoo');

insert into ld_field(tabid,fieldid,columnname,tablename,generatedtype,uitype,fieldname,fieldlabel,readonly,presence,
defaultvalue,maximumlength,sequence,block,displaytype,typeofdata,quickcreate,quickcreatesequence,info_type,masseditable,
helpinfo,fieldonly,issmownerid,searchfieldtype,associatedfields,associatedsequence,callchecked)
select @tabid,(select max(fieldid) from ld_field)+1,'dianshang_orderno','LD_salesorder',2,1,'dianshang_orderno','dianshang_orderno',1,2,
'',100,1,@blockid,1,'V~O',1,0,'BAS',1,
null,0,0,null,null,0,0  from dual where not exists (select 1 from ld_field where tabid = @tabid and columnname = 'dianshang_orderno')
and  EXISTS (select 1 from ld_version where trade='adoodoo');


select fieldid into @fieldid from ld_field where tabid =@tabid and fieldname = 'dianshang_orderno';
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'zh','LD_field',22,@fieldid,'淘宝编号' 
from dual where not EXISTS(select 1 from ld_tranlabel  where languagetype = 'zh' 
and trantable ='LD_field' and tabid = 22 and relateid=@fieldid) and  EXISTS (select 1 from ld_version where trade='adoodoo');
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'en','LD_field',22,@fieldid,'dianshang_orderno' 
from dual where not EXISTS(select 1 from ld_tranlabel  where languagetype = 'en' 
and trantable ='LD_field' and tabid = 22 and relateid=@fieldid )and  EXISTS (select 1 from ld_version where trade='adoodoo');
delimiter;

call fieldprofile('SalesOrder');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','BARCODE','条形码','fixedstr' from dual
 where not EXISTS(select 1 from  ld_desk where languagetype='zh' and labelbol='BARCODE' and Labeltype='fixedstr');

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','BARCODE','Bar code','fixedstr' from dual
 where not EXISTS(select 1 from  ld_desk where languagetype='en' and labelbol='BARCODE' and Labeltype='fixedstr');
delimiter;
-- 2015-01-21

update ld_desk set fieldlabel='After converting common customers to the hign seas customers ,modify the owner as(do nothing if empty)'
where labelbol='AFTERCONVERTINGMODIFYTHEOWNER' and languagetype='en' and Labeltype='fixedstr';
select tabid into @tabid from ld_tab where `name` = 'Accounts';
update ld_field LEFT JOIN ld_entityname on ld_field.fieldname = ld_entityname.fieldname set ld_field.searchfieldtype = 0 
where ld_field.tabid = ld_entityname.tabid and ld_field.tabid = @tabid;
delimiter;

select tabid into @tabid from ld_tab where `name` = 'Contacts';
update ld_field LEFT JOIN ld_entityname on ld_field.fieldname = ld_entityname.fieldname set ld_field.searchfieldtype = 0 
where ld_field.tabid = ld_entityname.tabid and ld_field.tabid = @tabid;
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','ACCOUNTGETBILL','客户应收款','fixedstr' from dual
 where not EXISTS(select 1 from  ld_desk where languagetype='zh' and labelbol='ACCOUNTGETBILL' and Labeltype='fixedstr');

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','ACCOUNTGETBILL','Customer receivables','fixedstr' from dual
 where not EXISTS(select 1 from  ld_desk where languagetype='en' and labelbol='ACCOUNTGETBILL' and Labeltype='fixedstr');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','ORDERGETBILL','订单应收款','fixedstr' from dual
 where not EXISTS(select 1 from  ld_desk where languagetype='zh' and labelbol='ORDERGETBILL' and Labeltype='fixedstr');

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','ORDERGETBILL','Order receivables','fixedstr' from dual
 where not EXISTS(select 1 from  ld_desk where languagetype='en' and labelbol='ORDERGETBILL' and Labeltype='fixedstr');
delimiter;

update ld_field set uitype = 1 where tabid = 14 and fieldname = 'costprice';
delimiter;
select tabid into @tabid from ld_tab where `name` = 'ServiceCharge';
update ld_field set issmownerid = 0 where tabid = @tabid and columnname = 'smownerid';
update ld_field set issmownerid = 1 where tabid = @tabid and columnname = 'servicecasher';
delimiter;

set @tabid=0;
select tabid into @tabid from ld_tab where name='ContactRecords';
update ld_field set typeofdata='DT~O' where tabid=@tabid and columnname='nextcontactdate';
update ld_field set generatedtype=2 where tabid=@tabid and columnname='subject';
delimiter;

update ld_field set uitype = 1 where tabid = 14 and fieldname = 'costprice';
delimiter;

select tabid into @tabid from ld_tab where `name` = 'ServiceCharge';
update ld_field set issmownerid = 0 where tabid = @tabid and columnname = 'smownerid';
update ld_field set issmownerid = 1 where tabid = @tabid and columnname = 'servicecasher';
delimiter;

insert into ld_systems_deploy(deploy_value,deploy_type,description,setype)
select 0,64,'公海已分配客户释放后，更改客户负责人为（为空表示不更改）','Accounts' 
from dual where not exists(select 1 from ld_systems_deploy where deploy_type=64);
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,Labeltype) select 'zh','AFTERRELEASINGTHEALLOCATEDHIGNSEAS','公海已分配{$Accounts.Accounts}释放后，更改{$Accounts.Accounts}负责人为（为空表示不更改）','fixedstr' from dual 
where not EXISTS(select 1 from ld_desk where labelbol='AFTERRELEASINGTHEALLOCATEDHIGNSEAS' and languagetype='zh' and Labeltype='fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,Labeltype)select 'en','AFTERRELEASINGTHEALLOCATEDHIGNSEAS','After releasing the allocated hign seas customers ,modify the owner as(do nothing if empty) ','fixedstr' from dual
where not EXISTS(select 1 from ld_desk where labelbol='AFTERRELEASINGTHEALLOCATEDHIGNSEAS' and languagetype='en' and Labeltype='fixedstr');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'zh','unitrumpreport','优创报表','fixedstr' from dual 
where not EXISTS(select 1 from ld_desk  where languagetype='zh' and labelbol='unitrumpreport' and Labeltype='fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'en','unitrumpreport','uni trump report','fixedstr' from dual 
where not EXISTS(select 1 from ld_desk  where languagetype='en' and labelbol='unitrumpreport' and Labeltype='fixedstr');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'zh','Salessummaryreport','销售汇总表','fixedstr' from dual 
where not EXISTS(select 1 from ld_desk  where languagetype='zh' and labelbol='Salessummaryreport' and Labeltype='fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'en','Salessummaryreport','Sales summary report','fixedstr' from dual 
where not EXISTS(select 1 from ld_desk  where languagetype='en' and labelbol='Salessummaryreport' and Labeltype='fixedstr');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'zh','Project','项目','fixedstr' from dual 
where not EXISTS(select 1 from ld_desk  where languagetype='zh' and labelbol='Project' and Labeltype='fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'en','Project','Project','fixedstr' from dual 
where not EXISTS(select 1 from ld_desk  where languagetype='en' and labelbol='Project' and Labeltype='fixedstr');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'zh','Productlinesaleperformancereport','产品线销售业绩报表','fixedstr' from dual 
where not EXISTS(select 1 from ld_desk  where languagetype='zh' and labelbol='Productlinesaleperformancereport' and Labeltype='fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'en','Productlinesaleperformancereport','Product line sales performance report','fixedstr' from dual 
where not EXISTS(select 1 from ld_desk  where languagetype='en' and labelbol='Productlinesaleperformancereport' and Labeltype='fixedstr');
delimiter;
-- 2015-01-23

update ld_field set quickcreate=1 where tabid=18;
update ld_field set quickcreate=0,quickcreatesequence=1 where tabid=18 and columnname='vendorname';
update ld_field set quickcreate=0,quickcreatesequence=2 where tabid=18 and columnname='smownerid';
update ld_field set quickcreate=0,quickcreatesequence=3 where tabid=18 and columnname='phone';
update ld_field set quickcreate=0,quickcreatesequence=4 where tabid=18 and columnname='email';
update ld_field set quickcreate=0,quickcreatesequence=5 where tabid=18 and columnname='glacct';

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'zh', 'HASRECEIVABLES','已收款','fixedstr' from dual 
where not EXISTS(select 1 from  ld_desk where languagetype='zh' and labelbol='HASRECEIVABLES' and labeltype='fixestr');

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'en', 'HASRECEIVABLES','Has receivables','fixedstr' from dual 
where not EXISTS(select 1 from  ld_desk where languagetype='en' and labelbol='HASRECEIVABLES' and labeltype='fixestr');
delimiter;

update ld_customview set viewname = 'All' where entitytype = 'Accounts' and customcategory = 'PUBLICALLOCATE' and viewname = '全部';
delimiter;

DROP PROCEDURE IF EXISTS addUserMenuApprove;
delimiter ||
CREATE PROCEDURE addUserMenuApprove()
BEGIN
	SELECT DATABASE() INTO @tableschema;
	SELECT COUNT(1) INTO @count FROM information_schema.columns WHERE TABLE_SCHEMA = @tableschema AND table_name = 'ld_users' AND COLUMN_NAME = 'menuapproval';
	IF @count = 0 then
		alter table ld_users add column menuapproval int(1) default 0;
	end if;
end ||
delimiter;
CALL addUserMenuApprove();
DROP PROCEDURE IF EXISTS addUserMenuApprove;
call fieldprofile('LD_users');
call getallprofile('LD_users');
delimiter;

select tabid into @tabid from ld_tab where `name` = 'Users';
SELECT sequence,blockid into @sequence,@block_id from ld_blocks
	where tabid=@tabid and blocklabel='LBL_USER_ENABLESMSVERIFICATION';
set @seq = @sequence + 1;
UPDATE ld_blocks set sequence= (@seq:=@seq+1) where tabid=@tabid and sequence > @sequence;
UPDATE ld_blocks SET sequence = @seq+2 WHERE tabid=@tabid AND sequence = @seq and blockid != @block_id ORDER BY sequence;
select max(blockid) into @maxblockid from ld_blocks;
insert into ld_blocks(blockid,tabid,blocklabel,sequence)
select @maxblockid+1,@tabid,'LBL_USER_MENUAPPROVAL1',@sequence+2
	from dual where not exists (select * from ld_blocks where
		tabid = @tabid and blocklabel = 'LBL_USER_MENUAPPROVAL1' );
UPDATE ld_blocks_seq set id=(select max(blockid) from ld_blocks);
delimiter;

select tabid into @tabid from ld_tab where `name` = 'Users';
select blockid into @blockid from ld_blocks where tabid = @tabid and blocklabel = 'LBL_USER_MENUAPPROVAL1';
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'zh','LD_blocks',@tabid,@blockid,'是否允许使用选单审批'
from dual where not EXISTS(select 1 from ld_tranlabel  where languagetype = 'zh'
and trantable ='LD_blocks' and tabid = @tabid and relateid=@blockid);

insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'en','LD_blocks',@tabid,@blockid,'Whether to allow the use of menu for approval'
from dual where not EXISTS(select 1 from ld_tranlabel  where languagetype = 'en'
and trantable ='LD_blocks' and tabid = @tabid and relateid=@blockid);
delimiter;

select tabid into @tabid from ld_tab where `name` = 'Users';
SELECT max(fieldid) into @maxid from ld_field;
SELECT max(sequence) into @sequence from ld_field where tabid=@tabid;
SELECT blockid INTO @blockid from ld_blocks where tabid=@tabid and blocklabel='LBL_USER_MENUAPPROVAL1';
insert into ld_field (tabid,fieldid,columnname,tablename,generatedtype,uitype,fieldname,fieldlabel,readonly,presence,defaultvalue,maximumlength,sequence,block,displaytype,typeofdata,quickcreate,quickcreatesequence,info_type,masseditable,helpinfo,fieldonly)
select @tabid,@maxid+1,'menuapproval','LD_users',1,56,'menuapproval','是否允许使用选单审批',1,0,'','',@sequence+1,@blockid,1,'V~O',3,'','BAS',2,NULL,0
from dual where  not exists (select 1 from  ld_field where tabid=@tabid and columnname='menuapproval');
UPDATE ld_field_seq set id=(SELECT max(fieldid) from ld_field);
delimiter;

select tabid into @tabid from ld_tab where `name` = 'Users';
select fieldid into @fieldid from ld_field where tabid = @tabid and fieldname = 'menuapproval';
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'zh','LD_field',@tabid,@fieldid,'审批中心增加选单审批'
from dual where not EXISTS(select 1 from ld_tranlabel  where languagetype = 'zh'
and trantable ='LD_field' and tabid = @tabid and relateid = @fieldid);
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'en','LD_field',@tabid,@fieldid,'The examination and approval center increases menu approval'
from dual where not EXISTS(select 1 from ld_tranlabel  where languagetype = 'en'
and trantable ='LD_field' and tabid = @tabid and relateid = @fieldid);
delimiter;

INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype) SELECT 'zh','APPROVE_USER_MENUAPPROVAL','选单审批','fixedstr' FROM DUAL
WHERE NOT EXISTS(SELECT 1 FROM ld_desk  WHERE languagetype='zh' AND labelbol='APPROVE_USER_MENUAPPROVAL' AND Labeltype='fixedstr');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype) SELECT 'en','APPROVE_USER_MENUAPPROVAL','Menu For Approval','fixedstr' FROM DUAL
WHERE NOT EXISTS(SELECT 1 FROM ld_desk  WHERE languagetype='en' AND labelbol='APPROVE_USER_MENUAPPROVAL' AND Labeltype='fixedstr');
delimiter;
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype) SELECT 'zh','Remove','移除','fixedstr' FROM DUAL
WHERE NOT EXISTS(SELECT 1 FROM ld_desk  WHERE languagetype='zh' AND labelbol='Remove' AND Labeltype='fixedstr');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype) SELECT 'en','Remove','Remove','fixedstr' FROM DUAL
WHERE NOT EXISTS(SELECT 1 FROM ld_desk  WHERE languagetype='en' AND labelbol='Remove' AND Labeltype='fixedstr');
delimiter;

INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype) SELECT 'zh','PLEASECONFIRMWHETHERREMOVE','请确认，是否移除？','jspop' FROM DUAL
WHERE NOT EXISTS(SELECT 1 FROM ld_desk  WHERE languagetype='zh' AND labelbol='PLEASECONFIRMWHETHERREMOVE' AND Labeltype='jspop');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype) SELECT 'en','PLEASECONFIRMWHETHERREMOVE','Please confirm, whether to remove?','jspop' FROM DUAL
WHERE NOT EXISTS(SELECT 1 FROM ld_desk  WHERE languagetype='en' AND labelbol='PLEASECONFIRMWHETHERREMOVE' AND Labeltype='jspop');
delimiter;

INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype) SELECT 'zh','PLEASESELECTDAPPROVALOCUMENTS','请选择一个模块的单据审批。','jspop' FROM DUAL
WHERE NOT EXISTS(SELECT 1 FROM ld_desk  WHERE languagetype='zh' AND labelbol='PLEASESELECTDAPPROVALOCUMENTS' AND Labeltype='jspop');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype) SELECT 'en','PLEASESELECTDAPPROVALOCUMENTS','Please select a module for the examination and approval of documents.','jspop' FROM DUAL
WHERE NOT EXISTS(SELECT 1 FROM ld_desk  WHERE languagetype='en' AND labelbol='PLEASESELECTDAPPROVALOCUMENTS' AND Labeltype='jspop');
delimiter;

INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype) SELECT 'zh','LBL_PLEASE_SELECT','请选择','fixedstr' FROM DUAL
WHERE NOT EXISTS(SELECT 1 FROM ld_desk  WHERE languagetype='zh' AND labelbol='LBL_PLEASE_SELECT' AND Labeltype='fixedstr');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype) SELECT 'en','LBL_PLEASE_SELECT','Please Select','fixedstr' FROM DUAL
WHERE NOT EXISTS(SELECT 1 FROM ld_desk  WHERE languagetype='en' AND labelbol='LBL_PLEASE_SELECT' AND Labeltype='fixedstr');
delimiter;
-- 2015-01-26

insert into ld_desk(languagetype,labelbol,fieldlabel,Labeltype)
select 'zh','next180days','未来180天','fixedstr' 
from dual where not EXISTS(select 1 from ld_desk where languagetype ='zh' and labelbol='next180days');
insert into ld_desk(languagetype,labelbol,fieldlabel,Labeltype)
select 'en','next180days','Next 180 Days','fixedstr' 
from dual where not EXISTS(select 1 from ld_desk where languagetype ='en' and labelbol='next180days');
delimiter;
insert into ld_desk(languagetype,labelbol,fieldlabel,Labeltype)
select 'zh','last180days','过去180天','fixedstr' 
from dual where not EXISTS(select 1 from ld_desk where languagetype ='zh' and labelbol='last180days');
insert into ld_desk(languagetype,labelbol,fieldlabel,Labeltype)
select 'en','last180days','Last 180 Days','fixedstr' 
from dual where not EXISTS(select 1 from ld_desk where languagetype ='en' and labelbol='last180days');
delimiter;

update ld_field set generatedtype=1,displaytype=3 where tabid=22 and columnname in ('smsfirstdate','smsseconddate','smsthirddate');
update ld_field set uitype=230 where tabid=8 and columnname='notecontent';


call AddColumn('LD_account_set','allotaccount','int','11','0');
delimiter;
-- 2015-01-27

select autotaskid into @autotaskid from ld_autotask where tabid=6 and autotaskname='30天未联系客户自动转公海';
update `ld_autotaskquery` set `query`=concat("update ld_account set protectdate=NULL,publicaccount=1 where TIMESTAMPDIFF(DAY,ifnull(lastcontactdate,'2000-01-01'),now())>=30 and publicaccount=0;
DROP PROCEDURE IF EXISTS `task_Addremind`;
delimiter $$
CREATE  PROCEDURE `task_Addremind`(
)
BEGIN
     declare tmp_accountid  int default 0;
     declare tmp_accountname varchar(200) default '';
     declare tmp_smownerid  int default 0;
     declare mycursor cursor for select accountid, accountname,smownerid from ld_account where TIMESTAMPDIFF(DAY,ifnull(lastcontactdate,'2000-01-01'),now())>=30 and publicaccount=0;
     DECLARE CONTINUE HANDLER FOR SQLSTATE '02000' set tmp_accountid = NULL;
     open mycursor;
     fetch mycursor into tmp_accountid,tmp_accountname,tmp_smownerid;
     while(tmp_accountid is not null) DO
               set @maxid=0;
               select max(crmid) into @maxid from ld_crmentity;
               insert into ld_crmentity(crmid,setype)
               select @maxid+1,'Reminds';
               insert into ld_reminds(remindsid,content,date_time,recieverid,status_rmd,related_to,reltab,is_del_send,is_del_rec,reminds_ruleid,smownerid,smcreatorid,modifiedby,createdtime,modifiedtime,description,deleted)
      select @maxid+1,concat('计划任务：30天未联系客户自动转公海已执行，客户：',tmp_accountname,'已自动转公海！'),now(),tmp_smownerid,'未读',tmp_accountid,'Accounts',0,0,0,1,1,1,now(),now(),null,0;
               insert into ld_logpublicaccount(username,operation,opdate,accountid)
               select '系统管理员','计划任务：30天未联系客户自动转公海',NOW(),tmp_accountid;
               fetch mycursor into tmp_accountid,tmp_accountname,tmp_smownerid;
     end while;
     close mycursor;
END $$
delimi","ter;
call task_Addremind;
update ld_crmentity_seq set id=(select max(crmid) from ld_crmentity);
delimi","ter;") WHERE autotaskid=@autotaskid;

select tabid into @tabid from ld_tab where name = 'Contacts'; 
select autotaskid into @autotaskid from ld_autotask where tabid = @tabid and autotaskname='联系人生日自动提醒'; 
update `ld_autotaskquery` set `query` = concat("DROP PROCEDURE IF EXISTS `task_contact_birthday_reminds`; 
delimiter $$ 
CREATE PROCEDURE `task_contact_birthday_reminds`( 
) 
BEGIN 
DECLARE done int DEFAULT 0; 
DECLARE task_crmid int default 0; 
DECLARE task_name varchar(200) default ''; 
DECLARE task_user int default 0; 
DECLARE task_time datetime DEFAULT NOW(); 
DECLARE mycursor cursor for SELECT contactid,lastname,smownerid FROM ld_contactdetails WHERE deleted = 0 AND birthday != '' AND 
(DATE_FORMAT(birthday,'%m%d') - DATE_FORMAT(CURDATE(),'%m%d') = 0) ORDER BY contactid; 
DECLARE CONTINUE HANDLER for not found set done = 1; 
OPEN mycursor; 
fetch mycursor into task_crmid,task_name,task_user; 
LOOP1: WHILE done != 1 DO 
IF task_crmid > 0 THEN 
set @maxid = 0; 
select max(crmid) into @maxid from ld_crmentity; 
insert into ld_crmentity(crmid,setype) 
select @maxid+1,'Reminds'; 
insert into ld_reminds(remindsid,content,date_time,recieverid,status_rmd,related_to,reltab,is_del_send,is_del_rec,reminds_ruleid,smownerid,smcreatorid,modifiedby,createdtime,modifiedtime,description,deleted) 
select @maxid+1,concat('计划任务：联系人生日自动提醒已执行，今天是联系人：',task_name,'的生日，请送上生日的祝福。'),task_time,task_user,'未读',task_crmid,'Contacts',0,0,0,1,1,1,task_time,task_time,'',0; 
END IF; 
FETCH mycursor INTO task_crmid,task_name,task_user; 
END WHILE LOOP1; 
close mycursor; 
END $$
delimi","ter;
call `task_contact_birthday_reminds`(); 
update ld_crmentity_seq set id=(select max(crmid) from ld_crmentity); 
delimi","ter;") where autotaskid = @autotaskid; 
delimiter;
-- 2015-01-28

delete from ld_systems_deploy  where deploy_type=64;
delimiter;

insert into ld_desk (languagetype,labelbol,fieldlabel,Labeltype)select 'zh','THETOTALSTOCKQUANTITY','产品累计入库数量超过可入库数量，保存失败！','jspop' from DUAL
where not EXISTS(select 1 from ld_desk where  languagetype='zh' and labelbol='THETOTALSTOCKQUANTITY' and Labeltype='jspop');

insert into ld_desk (languagetype,labelbol,fieldlabel,Labeltype)select 'en','THETOTALSTOCKQUANTITY','The total stock quantity of products is greater than the allowable quantity,save failed.','jspop' from DUAL
where not EXISTS(select 1 from ld_desk where  languagetype='en' and labelbol='THETOTALSTOCKQUANTITY' and Labeltype='jspop');

update ld_desk set fieldlabel='可入库数量' where languagetype='zh' and labelbol='BUTTHENUMBEROFTHESTOCK' and Labeltype='jspop'  and fieldlabel='可出库数量';
delimiter;

update LD_outboundorder left join ld_currency_info on LD_outboundorder.currency_id = ld_currency_info.id set LD_outboundorder.currency_symbol = ld_currency_info.currency_symbol;
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'zh','SERVICE','服务器','fixedstr' from dual 
where not EXISTS(select 1 from ld_desk  where languagetype='zh' and labelbol='SERVICE' and Labeltype='fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'en','SERVICE','Service','fixedstr' from dual 
where not EXISTS(select 1 from ld_desk  where languagetype='en' and labelbol='SERVICE' and Labeltype='fixedstr');
delimiter;
update ld_desk set fieldlabel = '设定相关信息列表每页显示记录条数' where labelbol = 'PAGEMORELISTNUM' and languagetype ='zh';
delimiter;
-- 2015-01-29

update ld_desk set fieldlabel='任务' where labelbol='LBL_AUTOMATICTASK_CUSTOMIZED' and languagetype='zh';
select max(tabid) into @tabid from ld_tab ;
insert into ld_tab (tabid,name,presence,tabsequence,tablabel,customized,ownedby,isentitytype,parent,printtab,proportion)
select @tabid+1,'mobileHelpDesk',0,50,'mobileHelpDesk',0,0,1,'Finacial',1,0 from dual 
where  not EXISTS(select 1 from ld_tab where  name='mobileHelpDesk');
 
select max(cvid) into @cvid from ld_customview ;
insert into ld_customview(cvid,viewname,setdefault,setmetrics,entitytype,status,userid,sequence,pagewidthpercent)
select @cvid+1 ,'mobileHelpDesk',0,0,'mobileHelpDesk',0,1,1,100 from dual 
where not exists(select 1 from ld_customview where viewname='mobileHelpDesk' and entitytype='mobileHelpdesk');
update ld_customview_seq set id=(select max(cvid) from ld_customview);
 
select cvid into @cvid from ld_customview where viewname='mobileHelpDesk' and entitytype='mobileHelpdesk';
delete from ld_cvcolumnlist where cvid=@cvid;
insert into ld_cvcolumnlist(cvid,columnindex,columnname)select @cvid,0,'LD_troubletickets:ticket_title:ticket_title:HelpDesk_fieldlabel:V' from DUAL 
where not exists(select 1 from ld_cvcolumnlist where columnname like '%LD_troubletickets:ticket_title:ticket_title:HelpDesk%' and cvid=@cvid);

insert into ld_cvcolumnlist(cvid,columnindex,columnname)select @cvid,1,'LD_troubletickets:ticket_no:ticket_no:HelpDesk_编号:V' from DUAL 
where not exists(select 1 from ld_cvcolumnlist where columnname like '%LD_troubletickets:ticket_no:ticket_no:HelpDesk%' and cvid=@cvid);

insert into ld_cvcolumnlist(cvid,columnindex,columnname)select @cvid,2,'LD_troubletickets:smownerid:assigned_user_id:HelpDesk_fieldlabel:V' from DUAL 
where not exists(select 1 from ld_cvcolumnlist where columnname like '%LD_troubletickets:smownerid:assigned_user_id:HelpDesk%' and cvid=@cvid);

insert into ld_cvcolumnlist(cvid,columnindex,columnname)select @cvid,3,'LD_troubletickets:status:ticketstatus:HelpDesk_状态:V' from DUAL 
where not exists(select 1 from ld_cvcolumnlist where columnname like '%LD_troubletickets:status:ticketstatus:HelpDesk%' and cvid=@cvid);

insert into ld_cvcolumnlist(cvid,columnindex,columnname)select @cvid,4,'LD_troubletickets:accountid:account_id:HelpDesk_fieldlabel:V' from DUAL 
where not exists(select 1 from ld_cvcolumnlist where columnname like '%LD_troubletickets:accountid:account_id:HelpDesk%' and cvid=@cvid);

insert into ld_cvcolumnlist(cvid,columnindex,columnname)select @cvid,5,'LD_troubletickets:createdtime:createdtime:HelpDesk_fieldlabel:DT' from DUAL 
where not exists(select 1 from ld_cvcolumnlist where columnname like '%LD_troubletickets:createdtime:createdtime:HelpDesk%' and cvid=@cvid);
delimiter; 
-- 2015-01-30

update ld_field_seq set id=(select max(fieldid) from ld_field);
update ld_blocks_seq set id=(select max(blockid) from ld_blocks);
update ld_relatedlists_seq set id=(select max(relation_id) from ld_relatedlists);
update ld_customview_seq set id = (select max(cvid) from ld_customview);
update ld_links_seq set id=(select max(linkid) from ld_links);
update ld_picklist_dependency_seq set id=(select max(id) from ld_picklist_dependency);
update ld_crmentity_seq set id=(select max(crmid) from ld_crmentity);
update ld_approve_seq set id=(select max(id) from ld_approve);
update ld_approvestep_seq set id=(select max(id) from ld_approvestep);
UPDATE ld_autotask_seq SET id = (SELECT MAX(autotaskid) AS COUNT FROM ld_autotask);
update lD_version set old_version='V5.9.0' ,current_version='V5.9.0' ,remark='V5.9.0-20150130';
delimiter;