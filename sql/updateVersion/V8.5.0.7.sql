SET @usereportid = (select usereportid from ld_usereport where `name`='SalesCommissionsByCash');
update ld_usereportcolumns set realcolumns=replace(realcolumns,":V",":N") ,`columns`=replace(`columns`,":V",":N"),realencolumns=replace(realencolumns,":V",":N")   where columns ='ld_oftenusereport:source_displayreceived:source_displayreceived:CashBill_source_displayreceived:V' and Usereportid=@usereportid;
delimiter;

insert into ld_desk (languagetype,labelbol,fieldlabel,Labeltype)
select 'zh','BEYONDHEIGHT','高度请设置150~230之间！','jspop' from dual
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='BEYONDHEIGHT' and labeltype='jspop');
insert into ld_desk (languagetype,labelbol,fieldlabel,Labeltype)
select 'en','BEYONDHEIGHT','Please set the height between 150~230！','jspop' from dual
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='BEYONDHEIGHT' and labeltype='jspop');
delimiter;

insert into ld_desk (languagetype,labelbol,fieldlabel,Labeltype)
select 'zh','NOTSEARCHHISTORY','没有搜索历史','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='NOTSEARCHHISTORY' and labeltype='fixedstr');
insert into ld_desk (languagetype,labelbol,fieldlabel,Labeltype)
select 'en','NOTSEARCHHISTORY','not to exist Search History','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='NOTSEARCHHISTORY' and labeltype='fixedstr');
delimiter;

insert into ld_desk (languagetype,labelbol,fieldlabel,Labeltype)
select 'zh','GROUPNO','部门编号','jspop' from dual
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='GROUPNO' and labeltype='jspop');
insert into ld_desk (languagetype,labelbol,fieldlabel,Labeltype)
select 'en','GROUPNO','Group No','jspop' from dual
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='GROUPNO' and labeltype='jspop');
delimiter;


INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'zh','STATISTICALFIELD','统计字段','jspop' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol='STATISTICALFIELD' and Labeltype='jspop');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'en','STATISTICALFIELD','Statistical field','jspop' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol='STATISTICALFIELD' and Labeltype='jspop');
delimiter;

insert into ld_desk (languagetype,labelbol,fieldlabel,labeltype)
select 'zh','StatisticsModule','统计模块','jspop' from dual
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='StatisticsModule' and labeltype='jspop');
delimiter;
insert into ld_desk (languagetype,labelbol,fieldlabel,labeltype)
select 'en','StatisticsModule','Statistics module','jspop' from dual
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='StatisticsModule' and labeltype='jspop');
delimiter;


select tabid into @tabid from ld_tab where `name` = 'SalesOrder';
select blockid into @blockid from ld_blocks where tabid = @tabid and blocklabel = 'LBL_SO_INFORMATION';
select max(sequence) into @sequence from ld_field where tabid = @tabid and block = @blockid;
select max(fieldid) into @max_fieldid from ld_field;
insert into ld_field(tabid,fieldid,columnname,allowhide,tablename,generatedtype,uitype,fieldname,fieldlabel,readonly,presence,defaultvalue,maximumlength,
                     sequence,block,displaytype,typeofdata,quickcreate,quickcreatesequence,info_type,masseditable,helpinfo,fieldonly,issmownerid,searchfieldtype,associatedfields,
                     associatedsequence,callchecked,duplicatefield,relate_search_parent_columnname,approve_demand,is_checkimportfield,allowedit,allowedit_presence,allowcreate,allowcreate_presence,allowdetail_presence,savedatabase,bigtype)
select @tabid,@max_fieldid+1,'havebackcount','yes','ld_salesorder',1,7,'havebackcount','已退货数量',0,2,NULL,NULL,@sequence+1,@blockid,2,'NN~O~25,4',0,NULL,NULL,1,NULL,0,0,0,1,0,0,NULL,NULL,2,0,'no','no','no','no','yes','yes','number'
from DUAL where not exists(select 1 from ld_field where tabid = @tabid and columnname = 'havebackcount');
delimiter;

select tabid into @tabid from ld_tab where `name` = 'SalesOrder';
select fieldid into @relateid from ld_field where tabid = @tabid and columnname = 'havebackcount';
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'zh','ld_field',@tabid,@relateid,'已退货数量' from DUAL
where not exists(select 1 from ld_tranlabel where tabid = @tabid and relateid = @relateid and languagetype = 'zh' and trantable = 'ld_field');
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'en','ld_field',@tabid,@relateid,'Quantity returned' from DUAL
where not exists(select 1 from ld_tranlabel where tabid = @tabid and relateid = @relateid and languagetype = 'en' and trantable = 'ld_field');
delimiter;

CALL AddColumn('ld_salesorder','havebackcount','decimal','25,6','0.000000');
ALTER TABLE ld_salesorder MODIFY COLUMN `havebackcount` decimal(25,6) NOT NULL DEFAULT 0.000000 AFTER `balanceoutboundcount`;
delimiter;

call AddColumn('ld_salesorderdetail','havebackproductcount','decimal','25,6','');
ALTER TABLE ld_salesorderdetail MODIFY COLUMN `havebackproductcount` decimal(25,6) NOT NULL DEFAULT 0.000000;
delimiter;
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'zh','HAVEBACKPROQUAN','已退货数量','fixedstr' from dual
where not EXISTS(select 1 from ld_desk  where languagetype='zh' and labelbol='HAVEBACKPROQUAN' and Labeltype='fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'en','HAVEBACKPROQUAN','Quantity returned','fixedstr' from dual
where not EXISTS(select 1 from ld_desk  where languagetype='en' and labelbol='HAVEBACKPROQUAN' and Labeltype='fixedstr');
delimiter;

select tabid into @tabid from ld_tab where `name` = 'SalesOrder';
select blockid into @blockid from ld_blocks where tabid = @tabid and blocklabel = 'LBL_SO_INFORMATION';
select max(sequence) into @sequence from ld_field where tabid = @tabid and block = @blockid;
select max(fieldid) into @max_fieldid from ld_field;
insert into ld_field(tabid,fieldid,columnname,allowhide,tablename,generatedtype,uitype,fieldname,fieldlabel,readonly,presence,defaultvalue,maximumlength,
                     sequence,block,displaytype,typeofdata,quickcreate,quickcreatesequence,info_type,masseditable,helpinfo,fieldonly,issmownerid,searchfieldtype,associatedfields,
                     associatedsequence,callchecked,duplicatefield,relate_search_parent_columnname,approve_demand,is_checkimportfield,allowedit,allowedit_presence,allowcreate,allowcreate_presence,allowdetail_presence,savedatabase,bigtype)
select @tabid,@max_fieldid+1,'totalcashbackamount','yes','ld_salesorder',1,72,'totalcashbackamount','应退款金额',0,2,NULL,NULL,@sequence+1,@blockid,2,'N~O~25,2',0,NULL,NULL,1,NULL,0,0,1,1,
       0,0,NULL,NULL,2,0,'no','no','no','no','yes','yes','currency'
from DUAL where not exists(select 1 from ld_field where tabid = @tabid and columnname = 'totalcashbackamount');
delimiter;

select tabid into @tabid from ld_tab where `name` = 'SalesOrder';
select fieldid into @relateid from ld_field where tabid = @tabid and columnname = 'totalcashbackamount';
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'zh','ld_field',@tabid,@relateid,'应退款金额' from DUAL
where not exists(select 1 from ld_tranlabel where tabid = @tabid and relateid = @relateid and languagetype = 'zh' and trantable = 'ld_field');
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'en','ld_field',@tabid,@relateid,'Total refundable amount' from DUAL
where not exists(select 1 from ld_tranlabel where tabid = @tabid and relateid = @relateid and languagetype = 'en' and trantable = 'ld_field');
delimiter;

CALL AddColumn('ld_salesorder','totalcashbackamount','decimal','25,8','');
ALTER TABLE ld_salesorder MODIFY COLUMN `totalcashbackamount` decimal(25,6) NOT NULL DEFAULT 0.00000000 AFTER `havebackcount`;
delimiter;

call AddColumn('ld_salesorderdetail','total_cashbackamount','decimal','25,8','');
ALTER TABLE ld_salesorderdetail MODIFY COLUMN `total_cashbackamount` decimal(25,8) NOT NULL DEFAULT 0.00000000;
delimiter;
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'zh','TotalCashBackAmount','应退款金额','fixedstr' from dual
where not EXISTS(select 1 from ld_desk  where languagetype='zh' and labelbol='TotalCashBackAmount' and Labeltype='fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'en','TotalCashBackAmount','Quantity returned','fixedstr' from dual
where not EXISTS(select 1 from ld_desk  where languagetype='en' and labelbol='TotalCashBackAmount' and Labeltype='fixedstr');
delimiter;

select tabid into @tabid from ld_tab where `name` = 'SalesOrder';
select blockid into @blockid from ld_blocks where tabid = @tabid and blocklabel = 'LBL_SO_INFORMATION';
select max(sequence) into @sequence from ld_field where tabid = @tabid and block = @blockid;
select max(fieldid) into @max_fieldid from ld_field;
insert into ld_field(tabid,fieldid,columnname,allowhide,tablename,generatedtype,uitype,fieldname,fieldlabel,readonly,presence,defaultvalue,maximumlength,
                     sequence,block,displaytype,typeofdata,quickcreate,quickcreatesequence,info_type,masseditable,helpinfo,fieldonly,issmownerid,searchfieldtype,associatedfields,
                     associatedsequence,callchecked,duplicatefield,relate_search_parent_columnname,approve_demand,is_checkimportfield,allowedit,allowedit_presence,allowcreate,allowcreate_presence,allowdetail_presence,savedatabase,bigtype)
select @tabid,@max_fieldid+1,'havecashbackamount','yes','ld_salesorder',1,72,'havecashbackamount','已退款金额',0,2,NULL,NULL,@sequence+1,@blockid,2,'N~O~25,2',0,NULL,NULL,1,NULL,0,0,1,1,
       0,0,NULL,NULL,2,0,'no','no','no','no','yes','yes','currency'
from DUAL where not exists(select 1 from ld_field where tabid = @tabid and columnname = 'havecashbackamount');
delimiter;

select tabid into @tabid from ld_tab where `name` = 'SalesOrder';
select fieldid into @relateid from ld_field where tabid = @tabid and columnname = 'havecashbackamount';
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'zh','ld_field',@tabid,@relateid,'已退款金额' from DUAL
where not exists(select 1 from ld_tranlabel where tabid = @tabid and relateid = @relateid and languagetype = 'zh' and trantable = 'ld_field');
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'en','ld_field',@tabid,@relateid,'Amount refunded' from DUAL
where not exists(select 1 from ld_tranlabel where tabid = @tabid and relateid = @relateid and languagetype = 'en' and trantable = 'ld_field');
delimiter;

CALL AddColumn('ld_salesorder','havecashbackamount','decimal','25,8','');
ALTER TABLE ld_salesorder MODIFY COLUMN `havecashbackamount` decimal(25,8) NOT NULL DEFAULT 0.00000000 AFTER `totalcashbackamount`;
delimiter;

call AddColumn('ld_salesorderdetail','have_cashbackamount','decimal','25,8','');
ALTER TABLE ld_salesorderdetail MODIFY COLUMN `have_cashbackamount` decimal(25,8) NOT NULL DEFAULT 0.00000000;
delimiter;
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'zh','HaveCashBackAmount','已退款金额','fixedstr' from dual
where not EXISTS(select 1 from ld_desk  where languagetype='zh' and labelbol='HaveCashBackAmount' and Labeltype='fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'en','HaveCashBackAmount','Amount refunded','fixedstr' from dual
where not EXISTS(select 1 from ld_desk  where languagetype='en' and labelbol='HaveCashBackAmount' and Labeltype='fixedstr');
delimiter;


select tabid into @tabid from ld_tab where `name` = 'SalesOrder';
select blockid into @blockid from ld_blocks where tabid = @tabid and blocklabel = 'LBL_SO_INFORMATION';
select max(sequence) into @sequence from ld_field where tabid = @tabid and block = @blockid;
select max(fieldid) into @max_fieldid from ld_field;
insert into ld_field(tabid,fieldid,columnname,allowhide,tablename,generatedtype,uitype,fieldname,fieldlabel,readonly,presence,defaultvalue,maximumlength,
                     sequence,block,displaytype,typeofdata,quickcreate,quickcreatesequence,info_type,masseditable,helpinfo,fieldonly,issmownerid,searchfieldtype,associatedfields,
                     associatedsequence,callchecked,duplicatefield,relate_search_parent_columnname,approve_demand,is_checkimportfield,allowedit,allowedit_presence,allowcreate,allowcreate_presence,allowdetail_presence,savedatabase,bigtype)
select @tabid,@max_fieldid+1,'balancecashbackamount','yes','ld_salesorder',1,72,'balancecashbackamount','应退款余额',0,2,NULL,NULL,@sequence+1,@blockid,2,'N~O~25,2',0,NULL,NULL,1,NULL,0,0,1,1,
       0,0,NULL,NULL,2,0,'no','no','no','no','yes','yes','currency'
from DUAL where not exists(select 1 from ld_field where tabid = @tabid and columnname = 'balancecashbackamount');
delimiter;

select tabid into @tabid from ld_tab where `name` = 'SalesOrder';
select fieldid into @relateid from ld_field where tabid = @tabid and columnname = 'balancecashbackamount';
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'zh','ld_field',@tabid,@relateid,'应退款余额' from DUAL
where not exists(select 1 from ld_tranlabel where tabid = @tabid and relateid = @relateid and languagetype = 'zh' and trantable = 'ld_field');
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'en','ld_field',@tabid,@relateid,'Refundable balance' from DUAL
where not exists(select 1 from ld_tranlabel where tabid = @tabid and relateid = @relateid and languagetype = 'en' and trantable = 'ld_field');
delimiter;

CALL AddColumn('ld_salesorder','balancecashbackamount','decimal','25,8','');
ALTER TABLE ld_salesorder MODIFY COLUMN `balancecashbackamount` decimal(25,8) NOT NULL DEFAULT 0.00000000 AFTER `havecashbackamount`;
delimiter;

call AddColumn('ld_salesorderdetail','balance_cashbackamount','decimal','25,8','');
ALTER TABLE ld_salesorderdetail MODIFY COLUMN `balance_cashbackamount` decimal(25,8) NOT NULL DEFAULT 0.00000000;
delimiter;
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'zh','BalanceCashBackAmount','应退款余额','fixedstr' from dual
where not EXISTS(select 1 from ld_desk  where languagetype='zh' and labelbol='BalanceCashBackAmount' and Labeltype='fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'en','BalanceCashBackAmount','Refundable balance','fixedstr' from dual
where not EXISTS(select 1 from ld_desk  where languagetype='en' and labelbol='BalanceCashBackAmount' and Labeltype='fixedstr');
delimiter;


call AddColumn('ld_salesbackdetail','have_cashbackamount','decimal','25,8','');
ALTER TABLE ld_salesbackdetail MODIFY COLUMN `have_cashbackamount` decimal(25,8) NOT NULL DEFAULT 0.00000000;
delimiter;

call AddColumn('ld_salesbackdetail','balance_cashbackamount','decimal','25,8','');
ALTER TABLE ld_salesbackdetail MODIFY COLUMN `balance_cashbackamount` decimal(25,8) NOT NULL DEFAULT 0.00000000;
delimiter;

select tabid into @tabid from ld_tab where `name` = 'PurchaseOrder';
select blockid into @blockid from ld_blocks where tabid = @tabid and blocklabel = 'LBL_PO_INFORMATION';
select max(sequence) into @sequence from ld_field where tabid = @tabid and block = @blockid;
select max(fieldid) into @max_fieldid from ld_field;
insert into ld_field(tabid,fieldid,columnname,allowhide,tablename,generatedtype,uitype,fieldname,fieldlabel,readonly,presence,defaultvalue,maximumlength,
                     sequence,block,displaytype,typeofdata,quickcreate,quickcreatesequence,info_type,masseditable,helpinfo,fieldonly,issmownerid,searchfieldtype,associatedfields,
                     associatedsequence,callchecked,duplicatefield,relate_search_parent_columnname,approve_demand,is_checkimportfield,allowedit,allowedit_presence,allowcreate,allowcreate_presence,allowdetail_presence,savedatabase,bigtype)
select @tabid,@max_fieldid+1,'totalcashbackamount','yes','ld_purchaseorder',1,72,'totalcashbackamount','应退款金额',0,2,NULL,NULL,@sequence+1,@blockid,2,'N~O~25,2',0,NULL,NULL,1,NULL,0,0,1,1,
       0,0,NULL,NULL,2,0,'no','no','no','no','yes','yes','currency'
from DUAL where not exists(select 1 from ld_field where tabid = @tabid and columnname = 'totalcashbackamount');
delimiter;

select tabid into @tabid from ld_tab where `name` = 'PurchaseOrder';
select fieldid into @relateid from ld_field where tabid = @tabid and columnname = 'totalcashbackamount';
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'zh','ld_field',@tabid,@relateid,'应退款金额' from DUAL
where not exists(select 1 from ld_tranlabel where tabid = @tabid and relateid = @relateid and languagetype = 'zh' and trantable = 'ld_field');
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'en','ld_field',@tabid,@relateid,'Total refundable amount' from DUAL
where not exists(select 1 from ld_tranlabel where tabid = @tabid and relateid = @relateid and languagetype = 'en' and trantable = 'ld_field');
delimiter;

CALL AddColumn('ld_purchaseorder','totalcashbackamount','decimal','25,8','');
ALTER TABLE ld_purchaseorder MODIFY COLUMN `totalcashbackamount` decimal(25,6) NOT NULL DEFAULT 0.00000000;
delimiter;

call AddColumn('ld_purchaseorderdetail','total_cashbackamount','decimal','25,8','');
ALTER TABLE ld_purchaseorderdetail MODIFY COLUMN `total_cashbackamount` decimal(25,8) NOT NULL DEFAULT 0.00000000;
delimiter;


select tabid into @tabid from ld_tab where `name` = 'PurchaseOrder';
select blockid into @blockid from ld_blocks where tabid = @tabid and blocklabel = 'LBL_PO_INFORMATION';
select max(sequence) into @sequence from ld_field where tabid = @tabid and block = @blockid;
select max(fieldid) into @max_fieldid from ld_field;
insert into ld_field(tabid,fieldid,columnname,allowhide,tablename,generatedtype,uitype,fieldname,fieldlabel,readonly,presence,defaultvalue,maximumlength,
                     sequence,block,displaytype,typeofdata,quickcreate,quickcreatesequence,info_type,masseditable,helpinfo,fieldonly,issmownerid,searchfieldtype,associatedfields,
                     associatedsequence,callchecked,duplicatefield,relate_search_parent_columnname,approve_demand,is_checkimportfield,allowedit,allowedit_presence,allowcreate,allowcreate_presence,allowdetail_presence,savedatabase,bigtype)
select @tabid,@max_fieldid+1,'havecashbackamount','yes','ld_purchaseorder',1,72,'havecashbackamount','已退款金额',0,2,NULL,NULL,@sequence+1,@blockid,2,'N~O~25,2',0,NULL,NULL,1,NULL,0,0,1,1,
       0,0,NULL,NULL,2,0,'no','no','no','no','yes','yes','currency'
from DUAL where not exists(select 1 from ld_field where tabid = @tabid and columnname = 'havecashbackamount');
delimiter;

select tabid into @tabid from ld_tab where `name` = 'PurchaseOrder';
select fieldid into @relateid from ld_field where tabid = @tabid and columnname = 'havecashbackamount';
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'zh','ld_field',@tabid,@relateid,'已退款金额' from DUAL
where not exists(select 1 from ld_tranlabel where tabid = @tabid and relateid = @relateid and languagetype = 'zh' and trantable = 'ld_field');
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'en','ld_field',@tabid,@relateid,'Amount refunded' from DUAL
where not exists(select 1 from ld_tranlabel where tabid = @tabid and relateid = @relateid and languagetype = 'en' and trantable = 'ld_field');
delimiter;

CALL AddColumn('ld_purchaseorder','havecashbackamount','decimal','25,8','');
ALTER TABLE ld_salesorder MODIFY COLUMN `havecashbackamount` decimal(25,8) NOT NULL DEFAULT 0.00000000 AFTER `totalcashbackamount`;
delimiter;

call AddColumn('ld_purchaseorderdetail','have_cashbackamount','decimal','25,8','');
ALTER TABLE ld_purchaseorderdetail MODIFY COLUMN `have_cashbackamount` decimal(25,8) NOT NULL DEFAULT 0.00000000;
delimiter;


select tabid into @tabid from ld_tab where `name` = 'PurchaseOrder';
select blockid into @blockid from ld_blocks where tabid = @tabid and blocklabel = 'LBL_PO_INFORMATION';
select max(sequence) into @sequence from ld_field where tabid = @tabid and block = @blockid;
select max(fieldid) into @max_fieldid from ld_field;
insert into ld_field(tabid,fieldid,columnname,allowhide,tablename,generatedtype,uitype,fieldname,fieldlabel,readonly,presence,defaultvalue,maximumlength,
                     sequence,block,displaytype,typeofdata,quickcreate,quickcreatesequence,info_type,masseditable,helpinfo,fieldonly,issmownerid,searchfieldtype,associatedfields,
                     associatedsequence,callchecked,duplicatefield,relate_search_parent_columnname,approve_demand,is_checkimportfield,allowedit,allowedit_presence,allowcreate,allowcreate_presence,allowdetail_presence,savedatabase,bigtype)
select @tabid,@max_fieldid+1,'balancecashbackamount','yes','ld_purchaseorder',1,72,'balancecashbackamount','应退款余额',0,2,NULL,NULL,@sequence+1,@blockid,2,'N~O~25,2',0,NULL,NULL,1,NULL,0,0,1,1,
       0,0,NULL,NULL,2,0,'no','no','no','no','yes','yes','currency'
from DUAL where not exists(select 1 from ld_field where tabid = @tabid and columnname = 'balancecashbackamount');
delimiter;

select tabid into @tabid from ld_tab where `name` = 'PurchaseOrder';
select fieldid into @relateid from ld_field where tabid = @tabid and columnname = 'balancecashbackamount';
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'zh','ld_field',@tabid,@relateid,'应退款余额' from DUAL
where not exists(select 1 from ld_tranlabel where tabid = @tabid and relateid = @relateid and languagetype = 'zh' and trantable = 'ld_field');
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'en','ld_field',@tabid,@relateid,'Refundable balance' from DUAL
where not exists(select 1 from ld_tranlabel where tabid = @tabid and relateid = @relateid and languagetype = 'en' and trantable = 'ld_field');
delimiter;

CALL AddColumn('ld_purchaseorder','balancecashbackamount','decimal','25,8','');
ALTER TABLE ld_purchaseorder MODIFY COLUMN `balancecashbackamount` decimal(25,8) NOT NULL DEFAULT 0.00000000 AFTER `havecashbackamount`;
delimiter;


call AddColumn('ld_purchaseorderdetail','balance_cashbackamount','decimal','25,8','');
ALTER TABLE ld_purchaseorderdetail MODIFY COLUMN `balance_cashbackamount` decimal(25,8) NOT NULL DEFAULT 0.00000000;
delimiter;
call AddColumn('ld_purchasebackdetail','have_cashbackamount','decimal','25,8','');
ALTER TABLE ld_purchasebackdetail MODIFY COLUMN `have_cashbackamount` decimal(25,8) NOT NULL DEFAULT 0.00000000;
delimiter;
call AddColumn('ld_purchasebackdetail','balance_cashbackamount','decimal','25,8','');
ALTER TABLE ld_purchasebackdetail MODIFY COLUMN `balance_cashbackamount` decimal(25,8) NOT NULL DEFAULT 0.00000000;
delimiter;

set @cur_module = 'Accounts';set @option_module = 'LoanApply';
set @related_coltable = 'loanapply.accountid';set @type = 'datacategory_sql';
set @tabid = (SELECT tabid from ld_tab where `name` = @cur_module);
set @option_tabid = (SELECT tabid from ld_tab where `name` = @option_module);
SET @i=IFNULL((SELECT MAX(sequence) FROM ld_relatedlists WHERE tabid=@tabid),0);
SET @maxrelation_id=(SELECT max(relation_id) FROM ld_relatedlists);
INSERT INTO ld_relatedlists(relation_id,tabid,related_tabid,`name`,sequence,label,presence,actions,related_coltable,type)
SELECT @maxrelation_id+1,@tabid,@option_tabid,CONCAT('get_',LOWER(@option_module)),@i+1,@option_module,1,'add',@related_coltable,@type FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_relatedlists WHERE tabid=@tabid AND related_tabid=@option_tabid AND `name`=CONCAT('get_',LOWER(@option_module)));
delimiter;

CALl AddColumn('ld_customform14','triggercount','INT','11',0);
delimiter;

set @tabid = (SELECT tabid from ld_tab where `name` = 'Products');

INSERT into ld_profile2standardpermissions(profileid,tabid,operation,permissions,sequence)
select tmp_profile.profileid,@tabid,38,0,1 from ld_profile2standardpermissions as tmp_profile where tabid = @tabid and operation = 1
and NOT EXISTS (SELECT 1 from ld_profile2standardpermissions where tabid = @tabid and operation = 38 
	and ld_profile2standardpermissions.profileid = tmp_profile.profileid);

INSERT into ld_profile2standardpermissions(profileid,tabid,operation,permissions,sequence)
select tmp_profile.profileid,@tabid,8,0,1 from ld_profile2standardpermissions as tmp_profile where tabid = @tabid and operation = 1
and NOT EXISTS (SELECT 1 from ld_profile2standardpermissions where tabid = @tabid and operation = 8 
	and ld_profile2standardpermissions.profileid = tmp_profile.profileid);

set @tmp_sequence = (SELECT sequence from ld_profileallpermission where tabid = @tabid and operation = 6);
set @havemerge = 'no';
set @havemerge = (SELECT 'yes' from ld_profileallpermission where tabid = @tabid and operation = 8);
UPDATE  ld_profileallpermission set sequence = sequence +2 where tabid = @tabid and sequence >@tmp_sequence 
and @havemerge <> 'yes';

INSERT INTO ld_profileallpermission(tabid, operation, sequence)
select @tabid,8,13 from dual where NOT EXISTS (SELECT 1 from ld_profileallpermission where tabid = @tabid and operation = 8 );

INSERT INTO ld_profileallpermission(tabid, operation, sequence)
select @tabid,38,14 from dual where NOT EXISTS (SELECT 1 from ld_profileallpermission where tabid = @tabid and operation = 38 );
delimiter;

SET @labelbol = 'DOCUMENTNOPROCESSPLEASESETPROCESS';
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'zh',@labelbol,'当前单据没有适用的审批流程，请联系管理员检查并设置审批流程！','jspop' FROM DUAL 
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol=@labelbol and Labeltype='jspop');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'en',@labelbol,'This document do not have appropriate approval process, please contact the administrator to check and set the approval process!','jspop' FROM DUAL 
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol=@labelbol and Labeltype='jspop');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','selectfilter','请选择需要的筛选器','jspop' from dual
where not exists(select 1 from ld_desk where labelbol='selectfilter' and Labeltype='jspop' and languagetype='zh');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','selectfilter','Please select the required filter','jspop' from dual
where not exists(select 1 from ld_desk where labelbol='selectfilter' and Labeltype='jspop' and languagetype='en');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','Addcustomquery','添加自定义查询','jspop' from dual
where not exists(select 1 from ld_desk where labelbol='Addcustomquery' and Labeltype='jspop' and languagetype='zh');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','Addcustomquery','Add custom query','jspop' from dual
where not exists(select 1 from ld_desk where labelbol='Addcustomquery' and Labeltype='jspop' and languagetype='en');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','Calladvancedsearchcomponent','调用高级查找组件','jspop' from dual
where not exists(select 1 from ld_desk where labelbol='Calladvancedsearchcomponent' and Labeltype='jspop' and languagetype='zh');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','Calladvancedsearchcomponent','Call advanced search component','jspop' from dual
where not exists(select 1 from ld_desk where labelbol='Calladvancedsearchcomponent' and Labeltype='jspop' and languagetype='en');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','VIEWRANGE','查看范围','jspop' from dual
where not exists(select 1 from ld_desk where labelbol='VIEWRANGE' and Labeltype='jspop' and languagetype='zh');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','VIEWRANGE','View Range','jspop' from dual
where not exists(select 1 from ld_desk where labelbol='VIEWRANGE' and Labeltype='jspop' and languagetype='en');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','TIMERANGE','时间范围','jspop' from dual
where not exists(select 1 from ld_desk where labelbol='TIMERANGE' and Labeltype='jspop' and languagetype='zh');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','TIMERANGE','Time Range','jspop' from dual
where not exists(select 1 from ld_desk where labelbol='TIMERANGE' and Labeltype='jspop' and languagetype='en');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','APPROVESTATUS','审批状态','jspop' from dual
where not exists(select 1 from ld_desk where labelbol='APPROVESTATUS' and Labeltype='jspop' and languagetype='zh');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','APPROVESTATUS','Approve Status','jspop' from dual
where not exists(select 1 from ld_desk where labelbol='APPROVESTATUS' and Labeltype='jspop' and languagetype='en');
delimiter;


call AddColumn('ld_homeboard','boardtype','varchar','200','Home');
delimiter;

DROP PROCEDURE IF EXISTS `alter_table_homeboard_plate_stuff`;
delimiter ||
CREATE  PROCEDURE `alter_table_homeboard_plate_stuff`(
)
BEGIN

	IF NOT EXISTS (SELECT 1 FROM information_schema.COLUMNS WHERE TABLE_SCHEMA=DATABASE() AND TABLE_NAME='ld_homeboard_plate_stuff' AND COLUMN_NAME='boardstuffid') THEN
ALTER TABLE ld_homeboard_plate_stuff ADD COLUMN boardstuffid INT(19) NOT NULL AUTO_INCREMENT PRIMARY KEY AFTER stuffid;
ALTER TABLE ld_homeboard_plate_stuff MODIFY COLUMN stuffid INT (11) AFTER boardstuffid;
END IF;

end ||
delimiter;

CALL alter_table_homeboard_plate_stuff();
DROP PROCEDURE IF EXISTS `alter_table_homeboard_plate_stuff`;
delimiter;


DROP PROCEDURE IF EXISTS `ld_addtable_homeboard_plate_filter`;
delimiter ||
CREATE  PROCEDURE `ld_addtable_homeboard_plate_filter`(

)
BEGIN

IF NOT EXISTS (select 1 from information_schema.`COLUMNS` where TABLE_SCHEMA=database() and TABLE_NAME='ld_homeboard_plate_filter') THEN

	CREATE TABLE if not EXISTS `ld_homeboard_plate_filter` (
		`filterid` int(11) NOT NULL AUTO_INCREMENT,
		`boardstuffid` int(11) NOT NULL COMMENT"ld_homeboard_plate_stuff表的主键id ",
		`conditionkey` varchar(255) DEFAULT NULL COMMENT"条件关键词 ",
		`isrelated` varchar(20) DEFAULT 'no' COMMENT"是否关联该条件",
		`filters` varchar(255) DEFAULT NULL COMMENT"筛选条件 自定义统计图下拉选字段（用户字段、时间字段、审批字段）、sql统计图下拉选变量（用户组件、时间组件、审批组件）",
		`filtermodule` varchar(100) DEFAULT NULL,
		`stuffmodule` varchar(100) DEFAULT NULL COMMENT"组件哪个模块的筛选（仅想签约排行榜这种涉及两个模块的组件会用到该字段）",
		`advance_demand` text DEFAULT NULL COMMENT"高级查找条件",
		`advance_demand_groups` text DEFAULT NULL COMMENT"高级查找条件分组",
		PRIMARY KEY (`filterid`)
	) ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=utf8;


	INSERT INTO ld_homeboard_plate_filter(boardstuffid,conditionkey,isrelated,filters,filtermodule,stuffmodule,advance_demand,advance_demand_groups)
	SELECT
		s.boardstuffid,
		(case when f.uses='smownerid' then 'usercomponent' when f.uses='start' then 'timecomponent1' when f.uses='end' then 'timecomponent2' when f.uses='approvestatus' then 'approvestatuscomponent' else '' end) as conditionkey,
		'yes' as isrelated,
		f.id as filters,
		'' as filtermodule ,
		'' as stuffmodule,
		'' as advance_demand,
		'' as advance_demand_groups
	from ld_homeboard_plate_stuff s
	inner join ld_customreport c on c.report_id=s.stuffid and s.stufftype="customreport"
	inner  join ld_customreportsql_filter f on f.report_id=c.report_id
	where f.uses in ('smownerid','start','end','approvestatus');


	INSERT INTO ld_homeboard_plate_filter(boardstuffid,conditionkey,isrelated,filters,filtermodule,stuffmodule,advance_demand,advance_demand_groups)
	SELECT
		s.boardstuffid,
		(case when f.comparator='show_athome_person' then 'usercomponent' when f.comparator='show_athome_timecheck' then 'timecomponent' when f.comparator='show_athome_approve' then 'approvestatuscomponent' else '' end) as conditionkey,
		'yes' as isrelated,
		(case when ifnull(f.columns,'')!='' then REPLACE(`columns`,REVERSE(SUBSTRING(REVERSE(`columns`),LOCATE(':',REVERSE(`columns`))+1,LOCATE('_',REVERSE(`columns`))-LOCATE(':',REVERSE(`columns`))-1)),'fieldlabel')
			  when ifnull(f.columns,'')='' and f.comparator='show_athome_person' then CONCAT(t.main_tablename,':smownerid:assigned_user_id:',c.mainmodule,'_fieldlabel:V')
			  when ifnull(f.columns,'')='' and f.comparator='show_athome_approve' then CONCAT(t.main_tablename,':approvestatus:approvestatus:',c.mainmodule,'_fieldlabel:V') end  ) as filters,
		c.mainmodule as filtermodule ,
		c.mainmodule as stuffmodule,
		'' as advance_demand,
		'' as advance_demand_groups
	from ld_homeboard_plate_stuff s
	inner join ld_customreport c on c.report_id=s.stuffid and s.stufftype="customreport"
	inner join ld_customreport_cvadvfilter f on f.report_id=c.report_id
	left join ld_tab t on t.name=c.mainmodule
	where f.comparator IN ('show_athome_timecheck','show_athome_person','show_athome_approve');

	call AddColumn('ld_stuff','datarangmodule','varchar','200','');

	update ld_stuff set datarangmodule=relatedmodule;
	update ld_stuff set datarangmodule='SalesOrder,ServiceContracts' where stufftitle='SALESSIXMONTH';

	update ld_stuff set datarangmodule='SalesOrder,ServiceContracts,CashBill' where stufftitle='ANNUALSALES';
	update ld_stuff set datarangmodule='Products' where stufftitle='INVENTORYDATA';
	update ld_stuff set datarangmodule='SalesOrder,ServiceContracts' where stufftitle='AMOUNTMONTHCONTRACTYEAR';
	update ld_stuff set datarangmodule='CashBill' where stufftitle='BACKAMOUNTMONTHYEAR';
	update ld_stuff set datarangmodule='SalesOrder,ServiceContracts,PaymentPlan,Invoice,PurchaseOrder,SendCashBill,SendPayment' where stufftitle='RECEIVESUMMARY';
	update ld_stuff set datarangmodule='Accounts,Calendar,Potentials,SalesOrder,ServiceContracts,CashBill' where stufftitle='SUBORDINATEMOTHSALESDATA';

	update ld_stuff set datarangmodule='Accounts,Calendar,Potentials,SalesOrder,ServiceContracts,CashBill' where stufftitle='Penson Month Sales';
	update ld_stuff set datarangmodule='SalesOrder,ServiceContracts' where stufftitle='INDIVIDUALSIXMONTH';
	update ld_stuff set datarangmodule='Calendar' where stufftitle='OVERSERVENDAYSSCHEDULE';
	update ld_stuff set datarangmodule='Calendar' where stufftitle='FUTURESEVENDAYSSCHEDULE';
	update ld_stuff set datarangmodule='Calendar' where stufftitle='EXPIREDAGENDA';
	update ld_stuff set datarangmodule='Accounts' where stufftitle='TODAYCONTACTCUSTOMER';
	update ld_stuff set datarangmodule='Potentials' where stufftitle='LATESTPOTENTIALS';
	update ld_stuff set datarangmodule='Quotes' where stufftitle='LATESTQUOTATION';
	update ld_stuff set datarangmodule='SalesOrder' where stufftitle='NEWCONTRACTORDERS';
	update ld_stuff set datarangmodule='Invoice' where stufftitle='LATESTINVOICE';
	update ld_stuff set datarangmodule='Potentials' where stufftitle='SALESFUNNEL';
	update ld_stuff set datarangmodule='PaymentPlan' where stufftitle='WITHINPAYMENTPLAN';
	update ld_stuff set datarangmodule='Expense' where stufftitle='LATESTEXPENSE';
	update ld_stuff set datarangmodule='CashBill' where stufftitle='LATESTCASHBILL';
	update ld_stuff set datarangmodule='SendCashBill' where stufftitle='LATESTSENDCASHBILL';
	update ld_stuff set datarangmodule='CashDeposit' where stufftitle='LATESTCASHDEPOSIT';
	update ld_stuff set datarangmodule='PutCash' where stufftitle='LATESTPUTCASH';

	update ld_stuff set datarangmodule='PutCash,CashDeposit,SendCashBill,CashBill,Commission,Expense' where stufftitle='BANKCASH';
	update ld_stuff set datarangmodule='PublicAnnouncement' where stufftitle='PUBLICANNOUNCEMENT';
	update ld_stuff set datarangmodule='SalesOrder,ServiceContracts,CashBill' where stufftitle='SALESCHARTS';

	update ld_stuff set datarangmodule='SalesOrder,ServiceContracts,CashBill,CashBack' where stufftitle='transaction';
	update ld_stuff set datarangmodule='SalesOrder,ServiceContracts,CashBill,Accounts,Invoice,OutboundOrder' where stufftitle='COMPLATIONRATESIXMONTH';
	update ld_stuff set datarangmodule='Invoice' where stufftitle='INVOICEAMOUNTYEAR';
	update ld_stuff set datarangmodule='OutboundOrder' where stufftitle='OUTBOUNDORDERAMOUNTYEAR';
	update ld_stuff set datarangmodule='Calendar' where stufftitle='日程管理';

	update ld_stuff set datarangmodule='Potentials' where stufftitle='StatisticsPotentialsBySalesPersonAndSalesStage';
	update ld_stuff set datarangmodule='Potentials' where stufftitle='StatisticalPotentialsByTheAccountIndustryAndSalesStage';
	update ld_stuff set datarangmodule='ContactRecords,Singin' where stufftitle='ContactTimesRanking';
	update ld_stuff set datarangmodule='SalesOrder,Products' where stufftitle='ProductsSalesRanking';
	update ld_stuff set datarangmodule='HelpDesk' where stufftitle='ServiceKanban';

	insert into ld_homeboard_plate_filter (boardstuffid,conditionkey,isrelated,filters,filtermodule,stuffmodule,advance_demand,advance_demand_groups)
	SELECT
		s.boardstuffid,'highsearch','yes','','ServiceContracts','ServiceContracts','[null,{"groupid":"1","columnname":"ld_servicecontracts:invoicestatus:contract_status:ServiceContracts_合同状态:V","comparator":"n","value":"已作废","columncondition":""}]','[null,{"groupcondition":""}]'
	from ld_homeboard_plate_stuff s left join ld_stuff on ld_stuff.stuffid=s.stuffid
	where ld_stuff.datarangmodule like '%ServiceContracts%';

	insert into ld_homeboard_plate_filter (boardstuffid,conditionkey,isrelated,filters,filtermodule,stuffmodule,advance_demand,advance_demand_groups)
	SELECT
		s.boardstuffid,'highsearch','yes','','SalesOrder','SalesOrder','[null,{"groupid":"1","columnname":"ld_salesorder:sostatus:sostatus:SalesOrder_订单状态:V","comparator":"n","value":"已作废","columncondition":""}]','[null,{"groupcondition":""}]'
	from ld_homeboard_plate_stuff s left join ld_stuff on ld_stuff.stuffid=s.stuffid
	where ld_stuff.datarangmodule like '%SalesOrder%';

	insert into ld_homeboard_plate_filter (boardstuffid,conditionkey,isrelated,filters,filtermodule,stuffmodule,advance_demand,advance_demand_groups)
	SELECT
		s.boardstuffid,'highsearch','yes','','Invoice','Invoice','[null,{"groupid":"1","columnname":"ld_invoice:invoicestatus:invoicestatus:Invoice_状态:V","comparator":"n","value":"已作废","columncondition":""}]','[null,{"groupcondition":""}]'
	from ld_homeboard_plate_stuff s left join ld_stuff on ld_stuff.stuffid=s.stuffid
	where ld_stuff.datarangmodule like '%Invoice%';
	
END IF;

end ||
delimiter;

CALl ld_addtable_homeboard_plate_filter();
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','DRAGGABLESETTING','可拖动调整快捷筛选的显示','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='DRAGGABLESETTING' and Labeltype='fixedstr' and languagetype='zh');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','DRAGGABLESETTING','Drag to adjust the display of shortcut filters','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='DRAGGABLESETTING' and Labeltype='fixedstr' and languagetype='en');
delimiter;

CALl AddColumn('ld_checksdetail','erpentryid','VARCHAR','100',NULL);
delimiter;

CALl AddColumn('ld_customform14','triggercount','INT','11',0);
CALl AddColumn('ld_customform18','triggercount','INT','11',0);
CALl AddColumn('ld_customform22','triggercount','INT','11',0);
delimiter;

insert into ld_desk (languagetype,labelbol,fieldlabel,Labeltype)
select 'zh','SelectIcon','选择图标','jspop' from dual
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='SelectIcon' and labeltype='jspop');
insert into ld_desk (languagetype,labelbol,fieldlabel,Labeltype)
select 'en','SelectIcon','Select Icon','jspop' from dual
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='SelectIcon' and labeltype='jspop');
delimiter;
-- 2023-06-29

CALL AddColumn('ld_modtracker_basic','operation_logid','int','19','');
delimiter;

DROP PROCEDURE IF EXISTS `ldcrm_add_profile_for_default_print`;
delimiter ||
CREATE PROCEDURE `ldcrm_add_profile_for_default_print`(in tmp_tabid int(19) , in `tmp_operation` int(19))
BEGIN

	DECLARE tmp_profileid INT(19) DEFAULT 0;

	DECLARE MYCUSOR CURSOR FOR SELECT profileid FROM ld_profile WHERE profileid>0;

DECLARE CONTINUE HANDLER FOR SQLSTATE '02000' SET tmp_profileid = NULL;

	SET @tabid=tmp_tabid;

	set @operation = tmp_operation;

OPEN MYCUSOR;
FETCH MYCUSOR INTO tmp_profileid;
WHILE(tmp_profileid IS NOT NULL) DO
		SET @profileid=tmp_profileid;
		IF NOT EXISTS (SELECT 1 FROM ld_profile2standardpermissions WHERE tabid=@tabid and operation = @operation and profileid = @profileid)
		THEN
			INSERT INTO ld_profile2standardpermissions(profileid,tabid,operation,permissions,sequence)
SELECT
    @profileid AS profileid,
    @tabid AS tabid,
    @operation,
    0,
    0
FROM ld_profile2standardpermissions a
         LEFT JOIN ld_tab b ON b.tabid=a.tabid
WHERE a.profileid=@profileid
  AND a.operation=@operation
    LIMIT 1;
END IF;

		SET @i=0;
UPDATE ld_profile2standardpermissions SET sequence=(@i:=@i+1) WHERE tabid=@tabid AND profileid=@profileid ORDER BY sequence;

IF NOT EXISTS (SELECT 1 FROM ld_profile2tab WHERE tabid=@tabid AND profileid=@profileid) THEN
			INSERT INTO ld_profile2tab(profileid,tabid,permissions)
SELECT profileid,@tabid,IF(MIN(permissions)=0,1,0) FROM ld_profile2standardpermissions WHERE tabid=@tabid AND profileid=@profileid;
END IF;

		IF NOT EXISTS (SELECT 1 FROM ld_profile2standardpermissions WHERE tabid=@tabid AND profileid=@profileid AND permissions=0) THEN
UPDATE ld_profile2standardpermissions SET permissions=1 WHERE tabid=@tabid AND profileid=@profileid AND operation=0;
END IF;

FETCH MYCUSOR INTO tmp_profileid;
END WHILE;
CLOSE MYCUSOR;
END ||
delimiter;

DROP PROCEDURE IF EXISTS `update_profile_print`;
delimiter ||
create PROCEDURE `update_profile_print`
(
    print_actionid int(10),
    changecreator_actionid int(10)
)
BEGIN
	declare var_tabid int(19);
	declare done  int  default 0;
	declare cur1 CURSOR FOR SELECT tabid from ld_tab;
    declare continue handler  for not   found  SET done =1;
    open cur1;
    loop1: while  done<>1 DO
    Fetch cur1 into var_tabid;
        if EXISTS(SELECT 1 from ld_profileallpermission where tabid = var_tabid and operation = changecreator_actionid) then
            set @change_sequence = (SELECT sequence from ld_profileallpermission where tabid = var_tabid and operation = changecreator_actionid);
            if EXISTS(SELECT 1 from ld_profileallpermission where tabid = var_tabid and operation = print_actionid) then
                if EXISTS(SELECT 1 from ld_profileallpermission where tabid = var_tabid and operation = print_actionid and sequence <> @change_sequence +1 ) then
                    UPDATE ld_profileallpermission set sequence = sequence +1 where tabid = var_tabid and sequence > @change_sequence;
                    UPDATE ld_profileallpermission set sequence = @change_sequence +1 where tabid = var_tabid and operation = print_actionid;
                end if;
            else
                UPDATE ld_profileallpermission set sequence = sequence +1 where tabid = var_tabid and sequence > @change_sequence;
                INSERT INTO ld_profileallpermission(tabid,operation,sequence) value(var_tabid,print_actionid,@change_sequence+1);
            end if;
        end if;
        CALL ldcrm_add_profile_for_default_print(var_tabid,print_actionid);
    end while loop1;
    close cur1;
end ||
delimiter;

set @actionid1 = (SELECT actionid from ld_actionmapping where actionname='Print');
set @actionid2 = (SELECT actionid from ld_actionmapping where actionname='ChangeCreator');
call update_profile_print(@actionid1,@actionid2);
drop PROCEDURE  if EXISTS update_profile_print;
delimiter;


SET @labelbol = 'Printsettings';
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'zh',@labelbol,'打印设置','fixedstr' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol=@labelbol and Labeltype='fixedstr');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'en',@labelbol,'Print settings','fixedstr' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol=@labelbol and Labeltype='fixedstr');
delimiter;

SET @labelbol = 'Operationcategory';
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'zh',@labelbol,'操作类别','fixedstr' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol=@labelbol and Labeltype='fixedstr');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'en',@labelbol,'Operation category','fixedstr' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol=@labelbol and Labeltype='fixedstr');
delimiter;

SET @labelbol = 'exporttopdf1';
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'zh',@labelbol,'导出成PDF格式','fixedstr' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol=@labelbol and Labeltype='fixedstr');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'en',@labelbol,'Export to PDF format','fixedstr' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol=@labelbol and Labeltype='fixedstr');
delimiter;

SET @labelbol = 'Send_Email_Add_DOC';
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'zh',@labelbol,'发送邮件并添加DOC格式附件','fixedstr' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol=@labelbol and Labeltype='fixedstr');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'en',@labelbol,'Send email and attach as DOC','fixedstr' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol=@labelbol and Labeltype='fixedstr');
delimiter;


SET @labelbol = 'Enable_Category_Tip';
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'zh',@labelbol,'未能关闭.请至少启用一个类别.','jspop' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol=@labelbol and Labeltype='jspop');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'en',@labelbol,'Failed to close. Please enable at least one category.','jspop' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol=@labelbol and Labeltype='jspop');
delimiter;

call AddColumn('ld_fileoperationlog','lineitem_id','int','11',0);
delimiter;

update ld_desk set fieldlabel = '数据简报定制' WHERE labelbol = 'SALESKITCUSTOMIZATION' and languagetype = 'zh';
delimiter;

CALl AddColumn('ld_activity','bgcolor','VARCHAR','100',NULL);
delimiter;
-- 2023-07-03

UPDATE ld_relatedlists SET actions='import,select' where tabid = (select tabid from ld_tab where `name`='PriceBooks') and `name`='get_pricebook_products' and actions='select';
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'zh','PCsettingsonlytakeeffect','PC端设置才生效','fixedstr' from dual
where not EXISTS(select 1 from ld_desk  where languagetype='zh' and labelbol='PCsettingsonlytakeeffect' and Labeltype='fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'en','PCsettingsonlytakeeffect','PC settings only take effect','fixedstr' from dual
where not EXISTS(select 1 from ld_desk  where languagetype='en' and labelbol='PCsettingsonlytakeeffect' and Labeltype='fixedstr');
delimiter;

delete from ld_option_module where ld_option_module.tabid=61 and option_tabid in (256,-12,253,257,249,205);
delimiter;
-- 2023-07-04

delete from ld_option_module where ld_option_module.tabid=61 and option_tabid in (256,-12,253,257,249,205);
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','DRAGTOSORT','可上下轻拽进行排序','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='DRAGTOSORT' and Labeltype='fixedstr' and languagetype='zh');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','DRAGTOSORT','Can be dragged up and down to sort','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='DRAGTOSORT' and Labeltype='fixedstr' and languagetype='en');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','DRAGTOSORT','可上下轻拽进行排序','jspop' from dual
where not exists(select 1 from ld_desk where labelbol='DRAGTOSORT' and Labeltype='jspop' and languagetype='zh');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','DRAGTOSORT','Can be dragged up and down to sort','jspop' from dual
where not exists(select 1 from ld_desk where labelbol='DRAGTOSORT' and Labeltype='jspop' and languagetype='en');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'zh','INACTIVATE','停用','jspop' from dual
where not EXISTS(select 1 from ld_desk  where languagetype='zh' and labelbol='INACTIVATE' and Labeltype='jspop');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'en','INACTIVATE','Inactivate','jspop' from dual
where not EXISTS(select 1 from ld_desk  where languagetype='en' and labelbol='INACTIVATE' and Labeltype='jspop');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','CANNOTREPEAT','不能重复','jspop' from dual
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='CANNOTREPEAT' and labeltype='jspop');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','CANNOTREPEAT',"can not repeat",'jspop' from dual
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='CANNOTREPEAT' and labeltype='jspop');
delimiter;

UPDATE ld_tranlabel SET fieldlabel='设置出库类单据是否允许负库存出库（根据参数出库和入库类单据更新库存数量的触发点在保存或审批通过时判断）'
WHERE languagetype='zh' AND Relateid=141 AND trantable='ld_systems_deploy';
delimiter;
update ld_desk set fieldlabel='设为看板可选组件' where labelbol='showAtPcHome' and languagetype='zh' and Labeltype='fixedstr';
update ld_desk set fieldlabel='Set as an optional component of Kanban' where labelbol='showAtPcHome' and languagetype='en' and Labeltype='fixedstr';
delimiter;
SELECT tabid  into @tabid from ld_tab where name = 'Users';
select fieldid into @fieldid from ld_field where tabid = @tabid and columnname = 'filename' ;
UPDATE ld_tranlabel SET fieldlabel = 'Attachment' WHERE ld_tranlabel.languagetype ='en' AND trantable = 'ld_field' AND tabid = @tabid and Relateid = @fieldid;
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','ADVANCEDMODE','高级模式','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='ADVANCEDMODE' and Labeltype='fixedstr' and languagetype='zh');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','ADVANCEDMODE','Advanced Mode','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='ADVANCEDMODE' and Labeltype='fixedstr' and languagetype='en');

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','CONCISEMODE','洁简模式','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='CONCISEMODE' and Labeltype='fixedstr' and languagetype='zh');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','CONCISEMODE','Concise Mode','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='CONCISEMODE' and Labeltype='fixedstr' and languagetype='en');
delimiter;

update ld_stuff set stufftitle='Calendar' where stufftitle='日程管理';

SET @labelbol = 'Calendar';
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'zh',@labelbol,'{$Calendar.Calendar}','fixedstr' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol=@labelbol and Labeltype='fixedstr');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'en',@labelbol,'{$Calendar.Calendar}','fixedstr' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol=@labelbol and Labeltype='fixedstr');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','GROUPNO','部门编号','jspop' from dual
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='GROUPNO' and labeltype='jspop');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','GROUPNO',"GROUPNO",'jspop' from dual
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='GROUPNO' and labeltype='jspop');
delimiter;

SET @labelbol = 'OPERATIONBUTTONNUM';
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'zh',@labelbol,'显示在列表的操作按钮个数','fixedstr' FROM DUAL 
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol=@labelbol and Labeltype='fixedstr');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'en',@labelbol,'The number of operation buttons displayed in the list' ,'fixedstr' FROM DUAL 
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol=@labelbol and Labeltype='fixedstr');
delimiter;

SET @labelbol = 'OPERATIONBUTTONNAME';
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'zh',@labelbol,'操作按钮名称','fixedstr' FROM DUAL 
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol=@labelbol and Labeltype='fixedstr');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'en',@labelbol,'Operation button name' ,'fixedstr' FROM DUAL 
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol=@labelbol and Labeltype='fixedstr');
delimiter;

SET @labelbol = 'OPERATIONBUTTONSET';
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'zh',@labelbol,'操作按钮设置','fixedstr' FROM DUAL 
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol=@labelbol and Labeltype='fixedstr');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'en',@labelbol,'Operation button settings' ,'fixedstr' FROM DUAL 
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol=@labelbol and Labeltype='fixedstr');
delimiter;

CREATE TABLE IF NOT EXISTS `ld_btnset` (
  `buttonid` int(10) NOT NULL AUTO_INCREMENT,
  `tabid` int(10) NOT NULL ,
  `buttonlabel` varchar(100) DEFAULT NULL,
  `sequence` int(10) DEFAULT NULL,
  `btnkey` varchar(100) DEFAULT NULL,
  `shownum` int(10) DEFAULT NULL,
  `createdtime` timestamp DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`buttonid`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','BusinessInterfaceExpiredOrOutOfBalance','工商接口过期/余额不足','jspop' from dual
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='BusinessInterfaceExpiredOrOutOfBalance' and labeltype='jspop');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','BusinessInterfaceExpiredOrOutOfBalance',"BusinessInterfaceExpiredOrOutOfBalance",'jspop' from dual
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='BusinessInterfaceExpiredOrOutOfBalance' and labeltype='jspop');
delimiter;

drop PROCEDURE if EXISTS updatadiscount_percentypeofdata_20230707;
delimiter ||
create PROCEDURE updatadiscount_percentypeofdata_20230707(
)
begin 
	declare tfieldtab varchar(50);
	declare ttablename varchar(50);
  declare ttableid int(11);
  declare tproducttoolfieldid int(11);
	declare tcolumnname varchar(50);
	declare ttypeofdata varchar(50);
	declare tamountlength int(11);
	declare totallength int(11);
  declare done  int  default 0;
	declare cur2 CURSOR FOR select  'ld_producttoolfield' as infotablename,tablename,tabid,producttoolfieldid,columnname,typeofdata,substring_index(typeofdata,',',-1)+0 as tamountlength,substring_index(substring_index(typeofdata,'~',-1),',',1)+0 as length  from ld_producttoolfield where  uitype=15 and columnname='discount_percent' ;
				
	declare continue handler  for not   found  SET done =1;
	open cur2;
	fetch cur2 into tfieldtab,ttablename,ttableid,tproducttoolfieldid,tcolumnname,ttypeofdata,tamountlength,totallength;
	set @disable_triggers = 'updatadiscount_percentypeofdata_20230707';
	loop2: while  done<>1 DO
		IF(tamountlength<8) and  (tfieldtab = 'ld_producttoolfield' and tcolumnname ='discount_percent') THEN
					set @sql=Concat(' 	alter  table ',ttablename,' modify column ',tcolumnname,' decimal(25,8) ');
					prepare stmt1 from @sql;
					execute stmt1;
					deallocate  prepare  stmt1;
		END IF;
		IF (tamountlength>0  ) THEN
				set @sql=Concat('update ',tfieldtab,' set typeofdata=replace(typeofdata,"',totallength,',',tamountlength,'"',',"25,',tamountlength,'") where tablename="', ttablename,'" and tabid=',ttableid,' and columnname="',tcolumnname,'"');
				prepare stmt2 from @sql;
				execute stmt2;
				deallocate  prepare  stmt2;
		END IF;
	fetch cur2 into tfieldtab,ttablename,ttableid,tproducttoolfieldid,tcolumnname,ttypeofdata,tamountlength,totallength;
	end while loop2;
	close cur2;
end ||
delimiter;

call updatadiscount_percentypeofdata_20230707(); 
delimiter;
drop PROCEDURE if EXISTS updatadiscount_percentypeofdata_20230707;
delimiter;
-- 2023-07-07

SET @disable_triggers=NULL;
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

UPDATE ld_version SET old_version='V8.5.0.7',current_version='V8.5.0.7',remark='V8.5.0.7-20230707',wx_version='V8.5.0.7';
delimiter;