insert into ld_desk (languagetype,labelbol,fieldlabel,labeltype)
  select 'zh','EVALUATESETTING02','服务评价','fixedstr' from dual
  where not exists(select * from ld_desk where languagetype='zh' and labelbol='EVALUATESETTING02' and labeltype='fixedstr');
insert into ld_desk (languagetype,labelbol,fieldlabel,labeltype)
  select 'en','EVALUATESETTING02','Service Evaluation','fixedstr' from dual
  where not exists(select * from ld_desk where languagetype='en' and labelbol='EVALUATESETTING02' and labeltype='fixedstr');

insert into ld_desk (languagetype,labelbol,fieldlabel,labeltype)
  select 'zh','EVALUATESETTING01','自助服务小程序是否启用服务评价','fixedstr' from dual
  where not exists(select * from ld_desk where languagetype='zh' and labelbol='EVALUATESETTING01' and labeltype='fixedstr');
insert into ld_desk (languagetype,labelbol,fieldlabel,labeltype)
  select 'en','EVALUATESETTING01','Whether the self-service applet enables service evaluation','fixedstr' from dual
  where not exists(select * from ld_desk where languagetype='en' and labelbol='EVALUATESETTING01' and labeltype='fixedstr');

insert into ld_desk (languagetype,labelbol,fieldlabel,labeltype)
  select 'zh','EVALUATESETTING','服务评价设置','fixedstr' from dual
  where not exists(select * from ld_desk where languagetype='zh' and labelbol='EVALUATESETTING' and labeltype='fixedstr');
insert into ld_desk (languagetype,labelbol,fieldlabel,labeltype)
  select 'en','EVALUATESETTING','Service evaluation settings','fixedstr' from dual
  where not exists(select * from ld_desk where languagetype='en' and labelbol='EVALUATESETTING' and labeltype='fixedstr');

insert into ld_wx_config (name,description,switch)
  select 'helpdesk_evaluate','服务小程序是否启用评价','open' from dual
where not exists(select 1 from ld_wx_config where name='helpdesk_evaluate');
delimiter;

create table  if not exists `ld_wx_evaluate_field`(
  `id` int primary key auto_increment,
  `columname` varchar(255) default '' comment '标签名称',
  `zh_label` varchar(255) default '' comment '标签中文名称',
  `en_label` varchar(255) default '' comment '标签英文名称',
  `optionid` int default null comment '录入方式',
  `presence` varchar(100) default 'no' comment '是否启用yes/no',
  `sequence` tinyint comment '显示顺序'
) ENGINE=InnoDB DEFAULT CHARSET utf8;
delimiter;

create table  if not exists `ld_wx_evaluate_option`(
  `id` int primary key auto_increment,
  `columname` varchar(255) default '' comment '录入方式',
  `zh_label` varchar(255) default '' comment '录入方式中文名',
  `en_label` varchar(255) default '' comment '录入方式英文名',
  `presence` varchar(100) default 'no' comment '是否启用yes/no',
  `sequence` tinyint comment '显示顺序'
) ENGINE=InnoDB DEFAULT CHARSET utf8;
delimiter;

create table  if not exists `ld_wx_evaluate_content`(
  `id` int primary key auto_increment,
  `record` int comment '单据id',
  `fieldid` int comment '评价字段表id',
  `content` text  comment '评价内容'
) ENGINE=InnoDB DEFAULT CHARSET utf8;
delimiter;

insert into ld_wx_evaluate_option (columname,zh_label , presence,sequence) select 'five_star','五星选择','yes',1 from dual
where not exists(select 1 from ld_wx_evaluate_option where columname='five_star');
insert into ld_wx_evaluate_option (columname,zh_label , presence,sequence) select 'satisfaction','满意度','yes',2 from dual
where not exists(select 1 from ld_wx_evaluate_option where columname='satisfaction');
insert into ld_wx_evaluate_option (columname,zh_label , presence,sequence) select 'ten','下拉框十分制','yes',3 from dual
where not exists(select 1 from ld_wx_evaluate_option where columname='ten');
insert into ld_wx_evaluate_option (columname,zh_label , presence,sequence) select 'hundred','下拉框百分制','yes',4 from dual
where not exists(select 1 from ld_wx_evaluate_option where columname='hundred');
insert into ld_wx_evaluate_option (columname,zh_label , presence,sequence) select 'input','文本框','yes',5 from dual
where not exists(select 1 from ld_wx_evaluate_option where columname='input');
insert into ld_wx_evaluate_option (columname,zh_label , presence,sequence) select 'text','文本区域','yes',6 from dual
where not exists(select 1 from ld_wx_evaluate_option where columname='text');

insert into ld_wx_evaluate_field (columname, zh_label,presence, sequence)
  select 'grade','服务评分','yes',1 from dual where not exists(
      select 1 from ld_wx_evaluate_field where columname='grade');
insert into ld_wx_evaluate_field (columname, zh_label,presence, sequence)
  select 'satisfaction','满意度','no',2 from dual where not exists(
      select 1 from ld_wx_evaluate_field where columname='satisfaction');
insert into ld_wx_evaluate_field (columname, zh_label,presence, sequence)
  select 'timeliness_rate','及时率','no',3 from dual where not exists(
      select 1 from ld_wx_evaluate_field where columname='timeliness_rate');
insert into ld_wx_evaluate_field (columname, zh_label,presence, sequence)
  select 'resolution_rate','解决率','no',4 from dual where not exists(
      select 1 from ld_wx_evaluate_field where columname='resolution_rate');
select id into @optionid from ld_wx_evaluate_option where columname='text';
insert into ld_wx_evaluate_field (columname, zh_label,presence, sequence,optionid)
  select 'service_experience','服务体验','yes',5,@optionid from dual where not exists(
      select 1 from ld_wx_evaluate_field where columname='service_experience');
insert into ld_wx_evaluate_field (columname, zh_label,presence, sequence)
  select 'custom1','自定义项1','no',6 from dual where not exists(
      select 1 from ld_wx_evaluate_field where columname='custom1');
insert into ld_wx_evaluate_field (columname, zh_label,presence, sequence)
  select 'custom2','自定义项2','no',7 from dual where not exists(
      select 1 from ld_wx_evaluate_field where columname='custom2');
insert into ld_wx_evaluate_field (columname, zh_label,presence, sequence)
  select 'custom3','自定义项3','no',8 from dual where not exists(
      select 1 from ld_wx_evaluate_field where columname='custom3');
delimiter;

insert into ld_desk (languagetype,labelbol,fieldlabel,labeltype)
select 'zh', 'ALLOCATEORGETSTARTNOCREATEOUTBOUNDORDERCREATE','自分配或创建之日起距最近一次{$OutboundOrder.OutboundOrder}的{$OutboundOrder.createdtime}已超过','fixedstr' from dual 
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='ALLOCATEORGETSTARTNOCREATEOUTBOUNDORDERCREATE' and labeltype='fixedstr');

insert into ld_desk (languagetype,labelbol,fieldlabel,labeltype)
select 'en', 'ALLOCATEORGETSTARTNOCREATEOUTBOUNDORDERCREATE','The nearest {$OutboundOrder.createdtime} of {$OutboundOrder.OutboundOrder} has exceed  the date of distribution or creation','fixedstr' from dual 
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='ALLOCATEORGETSTARTNOCREATEOUTBOUNDORDERCREATE' and labeltype='fixedstr');
delimiter;

insert into ld_desk (languagetype,labelbol,fieldlabel,labeltype)
select 'zh', 'NOTCREATEOutboundOrder','天没有创建{$OutboundOrder.OutboundOrder}','fixedstr' from dual 
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='NOTCREATEOutboundOrder' and labeltype='fixedstr');

insert into ld_desk (languagetype,labelbol,fieldlabel,labeltype)
select 'en', 'NOTCREATEOutboundOrder','days no new {$OutboundOrder.OutboundOrder}','fixedstr' from dual 
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='NOTCREATEOutboundOrder' and labeltype='fixedstr');
delimiter;

insert into ld_account_set_rule(tabname,type,`condition`,labelbol,sequence,`status`,columnname,otherwhere,iscycle,singlelabelbol)
select 'OutboundOrder','normal','and','ALLOCATEORGETSTARTNOCREATEOUTBOUNDORDERCREATE/Days',6,'inactive','createdtime','','no','ALLOCATEORCREATETIMESTART/NOTCREATEOutboundOrder'
from dual where not exists(select 1 from ld_account_set_rule where tabname='OutboundOrder' and type='normal');
update ld_account_set_rule set sequence=7 where type='normal' and tabname='ServiceContracts';
delimiter;

insert into ld_desk (languagetype,labelbol,fieldlabel,labeltype)
select 'zh', 'ALLOCATEORGETSTARTNOCREATEOutboundOrder','自分配或领用之日起距最近一次{$OutboundOrder.OutboundOrder}的{$OutboundOrder.createdtime}已超过','fixedstr' from dual 
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='ALLOCATEORGETSTARTNOCREATEOutboundOrder' and labeltype='fixedstr');

insert into ld_desk (languagetype,labelbol,fieldlabel,labeltype)
select 'en', 'ALLOCATEORGETSTARTNOCREATEOutboundOrder','The nearest {$OutboundOrder.createdtime} of {$OutboundOrder.OutboundOrder} has exceed  the date of distribution or receive','fixedstr' from dual 
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='ALLOCATEORGETSTARTNOCREATEOutboundOrder' and labeltype='fixedstr');
delimiter;

insert into ld_account_set_rule(tabname,type,`condition`,labelbol,sequence,`status`,columnname,otherwhere,iscycle,singlelabelbol)
select 'OutboundOrder','complete','and','ALLOCATEORGETSTARTNOCREATEOutboundOrder/Days',6,'inactive','createdtime','','no','ALLOCATEORCREATETIMESTART/NOTCREATEOutboundOrder'
from dual where not exists(select 1 from ld_account_set_rule where tabname='OutboundOrder' and type='complete');
update ld_account_set_rule set sequence=7 where type='complete' and tabname='ServiceContracts';
delimiter;

update ld_account_set_rule set singlelabelbol='ALLOCATEORGETSTART/NOTCREATEOutboundOrder' where type='complete' and tabname='OutboundOrder';
delimiter;

SET @tabid=(SELECT tabid FROM ld_tab WHERE `name`='BusinessApply');
SET @fieldid=(SELECT fieldid FROM ld_field WHERE tabid=@tabid AND columnname='preparemoney');
UPDATE ld_tranlabel SET fieldlabel='Prepaid Expenses(¥)' WHERE tabid=@tabid AND Relateid=@fieldid AND trantable='ld_field' AND languagetype='en' AND fieldlabel='Advance Money(¥)';
delimiter;

SET @tabid=(SELECT tabid FROM ld_tab WHERE `name`='PutCash');
SET @fieldid=(SELECT fieldid FROM ld_field WHERE tabid=@tabid AND columnname='cashmoney');
UPDATE ld_tranlabel SET fieldlabel='Amount' WHERE tabid=@tabid AND Relateid=@fieldid AND trantable='ld_field' AND languagetype='en' AND fieldlabel='Money';
delimiter;

SET @tabid=(SELECT tabid FROM ld_tab WHERE `name`='CashDeposit');
SET @fieldid=(SELECT fieldid FROM ld_field WHERE tabid=@tabid AND columnname='cashmoney');
UPDATE ld_tranlabel SET fieldlabel='Amount' WHERE tabid=@tabid AND Relateid=@fieldid AND trantable='ld_field' AND languagetype='en' AND fieldlabel='Money';
delimiter;

SET @tabid=(SELECT tabid FROM ld_tab WHERE `name`='CashBack');
SET @fieldid=(SELECT fieldid FROM ld_field WHERE tabid=@tabid AND columnname='salesbackid');
UPDATE ld_tranlabel SET fieldlabel='Return Number' WHERE tabid=@tabid AND Relateid=@fieldid AND trantable='ld_field' AND languagetype='en' AND fieldlabel='Returns single';
delimiter;

SET @tabid=(SELECT tabid FROM ld_tab WHERE `name`='SendCashBill');
SET @fieldid=(SELECT fieldid FROM ld_field WHERE tabid=@tabid AND columnname='corporatename');
UPDATE ld_tranlabel SET fieldlabel='Corporation Name' WHERE tabid=@tabid AND Relateid=@fieldid AND trantable='ld_field' AND languagetype='en' AND fieldlabel='Corporate name';
delimiter; 

UPDATE ld_desk SET fieldlabel='The unallocated unassigned customers are not allowed to obtain (Only can be distributed by administrators)' 
WHERE labelbol='UNALLOCATECUSTOMERADMIN' AND languagetype='en';

UPDATE ld_desk SET fieldlabel='The unallocated unassigned customers do not control data access (All unassigned accounts are queryable)' 
WHERE labelbol='CUSTOMERCONTROLPUBLIC' AND languagetype='en';

UPDATE ld_desk SET fieldlabel='The tab of chronological book of unassigned customers is shown as' 
WHERE labelbol='WEHERTODISPLAYTHEPUBLICCUSTOMERES' AND languagetype='en';

UPDATE ld_desk SET fieldlabel='The drop-down button option of creating new function in chronological book of unassigned customers' 
WHERE labelbol='NEWBUTTONDROP-DOWNOPTIONS' AND languagetype='en';

UPDATE ld_desk SET fieldlabel='The default state of the unassigned customers which is quickly created by the members of the unassigned' 
WHERE labelbol='quicklycreatedefaultaccount' AND languagetype='en';

UPDATE ld_desk SET fieldlabel='After converting common accounts to the unassigned accounts, modify the owner as (do nothing if empty)' 
WHERE labelbol='AFTERCONVERTINGMODIFYTHEOWNER' AND languagetype='en';

UPDATE ld_desk SET fieldlabel='After releasing the allocated unassigned customers, modify the owner as (do nothing if empty)' 
WHERE labelbol='AFTERRELEASINGTHEALLOCATEDHIGNSEAS' AND languagetype='en';

UPDATE ld_desk SET fieldlabel='One-off rules' WHERE labelbol='SINGLERULE' AND languagetype='en';
UPDATE ld_desk SET fieldlabel='Circularity rules' WHERE labelbol='RECYCLERULE' AND languagetype='en';
UPDATE ld_desk SET fieldlabel='days' WHERE labelbol='Days' AND languagetype='en';

UPDATE ld_desk SET fieldlabel='From the date of distribution or receiving' 
WHERE labelbol='ALLOCATEORGETSTART' AND languagetype='en';

UPDATE ld_desk SET fieldlabel='days without creating {$ContactRecords.ContactRecords}' 
WHERE labelbol='NOTCREATECONTACTRECORDS' AND languagetype='en';

UPDATE ld_desk SET fieldlabel='The duration between the latest creation of {$ContactRecords.ContactRecords} and the day of distribution or receiving has exceeded for' 
WHERE labelbol='ALLOCATEORGETSTARTNOCREATECONTACTRECORDS' AND languagetype='en';

UPDATE ld_desk SET fieldlabel='days without creating work attendance' 
WHERE labelbol='NOTCREATESINGIN' AND languagetype='en';

UPDATE ld_desk SET fieldlabel='days without creating {$Potentials.Potentials}' 
WHERE labelbol='NOTCREATEPOTENTIALS' AND languagetype='en';

UPDATE ld_desk SET fieldlabel='days without creating {$SalesOrder.SalesOrder}' 
WHERE labelbol='NOTCREATESALESORDER' AND languagetype='en';

UPDATE ld_desk SET fieldlabel='days without creating {$CashBill.CashBill}' 
WHERE labelbol='NOTCREATECASHBILL' AND languagetype='en';

UPDATE ld_desk SET fieldlabel='days without creating {$ServiceContracts.ServiceContracts}' 
WHERE labelbol='NOTCREATESERVICECONTRACTS' AND languagetype='en';

UPDATE ld_desk SET fieldlabel='days without creating {$OutboundOrder.OutboundOrder}' 
WHERE labelbol='NOTCREATEOutboundOrder' AND languagetype='en';


UPDATE ld_desk SET fieldlabel='自分配或领用之日起距最近一次外勤签到的创建时间已超过' 
WHERE labelbol='ALLOCATEORGETSTARTNOCREATESINGIN' AND languagetype='zh';

UPDATE ld_desk SET fieldlabel='The duration between the latest creation of signing in and the day of distribution or receiving has exceeded for' 
WHERE labelbol='ALLOCATEORGETSTARTNOCREATESINGIN' AND languagetype='en';

UPDATE ld_desk SET fieldlabel='The duration between the latest creation of {$Potentials.Potentials} and the day of distribution or receiving has exceeded for' 
WHERE labelbol='ALLOCATEORGETSTARTNOCREATEPOTENTIALS' AND languagetype='en';

UPDATE ld_desk SET fieldlabel='The duration between the latest creation of {$SalesOrder.SalesOrder} and the day of distribution or receiving has exceeded for' 
WHERE labelbol='ALLOCATEORGETSTARTNOCREATESALESORDER' AND languagetype='en';

UPDATE ld_desk SET fieldlabel='The duration between the latest creation of {$ServiceContracts.ServiceContracts} and the day of distribution or receiving has exceeded for' 
WHERE labelbol='ALLOCATEORGETSTARTNOCREATESERVICECONTRACTS' AND languagetype='en';

UPDATE ld_desk SET fieldlabel='The duration between the latest creation of {$CashBill.CashBill} and the day of distribution or receiving has exceeded for' 
WHERE labelbol='ALLOCATEORGETSTARTNOCREATECASHBILL' AND languagetype='en';

UPDATE ld_desk SET fieldlabel='The duration between the latest creation of {$OutboundOrder.OutboundOrder} and the day of distribution or receiving has exceeded for' 
WHERE labelbol='ALLOCATEORGETSTARTNOCREATEOutboundOrder' AND languagetype='en';

UPDATE ld_desk SET fieldlabel='Enable the unassigned customers' WHERE labelbol='ACTIVATEPUBLICCUST' AND languagetype='en';

UPDATE ld_desk SET fieldlabel='Unassigned customers execution recycling, set the rules' WHERE labelbol='COMPLETEAUTOMATICRECOVERYRULE' AND languagetype='en';
UPDATE ld_desk SET fieldlabel='Common customers execution recycling, set the rules' WHERE labelbol='NORMALCUSTOMRECYCLE' AND languagetype='en';

UPDATE ld_desk SET fieldlabel='How many days before the customer is recycled to remind the owner (0 means on the day of recycling and empty means no reminder)' WHERE labelbol='BEFOREREMINDDAYSCUSTOMER' AND languagetype='en';

UPDATE ld_desk SET fieldlabel='Data classification settings for recycling rules' WHERE labelbol='AUTORECYCLERULEDATACATEGORY' AND languagetype='en';


UPDATE ld_desk SET fieldlabel='All (excluding public account)' WHERE labelbol='allexcludinghignseas' AND languagetype='en';
UPDATE ld_desk SET fieldlabel='Set by department' WHERE labelbol='SETBYDEPARTMENT' AND languagetype='en';
UPDATE ld_desk SET fieldlabel='Set by users' WHERE labelbol='SETBYUSERS' AND languagetype='en';

insert into ld_desk (languagetype,labelbol,fieldlabel,labeltype)
select 'zh', 'SETBYSHIYONGFANWEI','按成员适用范围','fixedstr' from dual 
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='SETBYSHIYONGFANWEI' and labeltype='fixedstr');

insert into ld_desk (languagetype,labelbol,fieldlabel,labeltype)
select 'en', 'SETBYSHIYONGFANWEI','Set by the scope of application of users','fixedstr' from dual 
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='SETBYSHIYONGFANWEI' and labeltype='fixedstr');
delimiter;

UPDATE ld_desk SET fieldlabel=', ' WHERE labelbol='commasymbols' AND languagetype='en';

SET @tabid=(SELECT tabid FROM ld_tab WHERE `name`='PurchaseOrder');
SET @fieldid=(SELECT fieldid FROM ld_field WHERE tabid=@tabid AND columnname='vendorid');
UPDATE ld_tranlabel SET fieldlabel='Name of Supplier' WHERE tabid=@tabid AND Relateid=@fieldid AND trantable='ld_field' AND languagetype='en' AND fieldlabel='Vendor Name';
delimiter;

SET @tabid=(SELECT tabid FROM ld_tab WHERE `name`='PurchaseOrder');
SET @fieldid=(SELECT fieldid FROM ld_field WHERE tabid=@tabid AND columnname='sendcashbilldate');
UPDATE ld_tranlabel SET fieldlabel='Latest Payment' WHERE tabid=@tabid AND Relateid=@fieldid AND trantable='ld_field' AND languagetype='en' AND fieldlabel='New pay date';
delimiter;

SET @tabid=(SELECT tabid FROM ld_tab WHERE `name`='PurchaseOrder');
SET @fieldid=(SELECT fieldid FROM ld_field WHERE tabid=@tabid AND columnname='stockpresence');
UPDATE ld_tranlabel SET fieldlabel='Database Status' WHERE tabid=@tabid AND Relateid=@fieldid AND trantable='ld_field' AND languagetype='en' AND fieldlabel='Batabase State';
delimiter;


SET @tabid=16;
SET @fieldid=(SELECT fieldid FROM ld_field WHERE tabid=@tabid AND columnname='potentialid');
UPDATE ld_tranlabel SET fieldlabel='Potentials' WHERE tabid=@tabid AND Relateid=@fieldid AND trantable='ld_field' AND languagetype='en' AND fieldlabel='Potentail';
delimiter;

SET @tabid=16;
SET @fieldid=(SELECT fieldid FROM ld_field WHERE tabid=@tabid AND columnname='modifiedtime');
UPDATE ld_tranlabel SET fieldlabel='Update Time' WHERE tabid=@tabid AND Relateid=@fieldid AND trantable='ld_field' AND languagetype='en' AND fieldlabel='Mody Time';
delimiter;

SET @tabid=(SELECT tabid FROM ld_tab WHERE `name`='ContactRecords');
SET @fieldid=(SELECT fieldid FROM ld_field WHERE tabid=@tabid AND columnname='product_id');
UPDATE ld_tranlabel SET fieldlabel='Product Name' WHERE tabid=@tabid AND Relateid=@fieldid AND trantable='ld_field' AND languagetype='en' AND fieldlabel='产品名称';
delimiter;

SET @tabid=(SELECT tabid FROM ld_tab WHERE `name`='ContactRecords');
SET @fieldid=(SELECT fieldid FROM ld_field WHERE tabid=@tabid AND columnname='approveby');
UPDATE ld_tranlabel SET fieldlabel='Approved by' WHERE tabid=@tabid AND Relateid=@fieldid AND trantable='ld_field' AND languagetype='en' AND fieldlabel='approveby';
delimiter;

SET @tabid=(SELECT tabid FROM ld_tab WHERE `name`='Faq');
SET @fieldid=(SELECT fieldid FROM ld_field WHERE tabid=@tabid AND columnname='pinci');
UPDATE ld_tranlabel SET fieldlabel='Frequence' WHERE tabid=@tabid AND Relateid=@fieldid AND trantable='ld_field' AND languagetype='en' AND fieldlabel='使用频次';
delimiter;


SET @tabid=(SELECT tabid FROM ld_tab WHERE `name`='Accounts');
SET @fieldid=(SELECT fieldid FROM ld_field WHERE tabid=@tabid AND columnname='lastcontactuser');
UPDATE ld_tranlabel SET fieldlabel='Latest Contact Client' WHERE tabid=@tabid AND Relateid=@fieldid AND trantable='ld_field' AND languagetype='en' AND fieldlabel='Last Contact';
delimiter;

SET @tabid=(SELECT tabid FROM ld_tab WHERE `name`='Accounts');
SET @fieldid=(SELECT fieldid FROM ld_field WHERE tabid=@tabid AND columnname='tickersymbol');
UPDATE ld_tranlabel SET fieldlabel='Ticker Symbol' WHERE tabid=@tabid AND Relateid=@fieldid AND trantable='ld_field' AND languagetype='en' AND fieldlabel='tickersymbol';
delimiter;

SET @tabid=(SELECT tabid FROM ld_tab WHERE `name`='Accounts');
SET @fieldid=(SELECT fieldid FROM ld_field WHERE tabid=@tabid AND columnname='lastquotedate');
UPDATE ld_tranlabel SET fieldlabel='Last Quote Date' WHERE tabid=@tabid AND Relateid=@fieldid AND trantable='ld_field' AND languagetype='en' AND fieldlabel='lastquotedate';
delimiter;

SET @tabid=(SELECT tabid FROM ld_tab WHERE `name`='Accounts');
SET @fieldid=(SELECT fieldid FROM ld_field WHERE tabid=@tabid AND columnname='lastdistributedate');
UPDATE ld_tranlabel SET fieldlabel='Unassigned Distribution Date' WHERE tabid=@tabid AND Relateid=@fieldid AND trantable='ld_field' AND languagetype='en' AND fieldlabel='highseas distributdate';
delimiter;

SET @tabid=(SELECT tabid FROM ld_tab WHERE `name`='HelpDesk');
SET @fieldid=(SELECT fieldid FROM ld_field WHERE tabid=@tabid AND columnname='traficfee');
UPDATE ld_tranlabel SET fieldlabel='Traffic Fees' WHERE tabid=@tabid AND Relateid=@fieldid AND trantable='ld_field' AND languagetype='en' AND fieldlabel='Trafic Fee';
delimiter;

SET @tabid=(SELECT tabid FROM ld_tab WHERE `name`='HelpDesk');
SET @fieldid=(SELECT fieldid FROM ld_field WHERE tabid=@tabid AND columnname='projectid');
UPDATE ld_tranlabel SET fieldlabel='Projects' WHERE tabid=@tabid AND Relateid=@fieldid AND trantable='ld_field' AND languagetype='en' AND fieldlabel='项目';
delimiter;

SET @tabid=(SELECT tabid FROM ld_tab WHERE `name`='HelpDesk');
SET @fieldid=(SELECT fieldid FROM ld_field WHERE tabid=@tabid AND columnname='consumetime');
UPDATE ld_tranlabel SET fieldlabel='Required Time' WHERE tabid=@tabid AND Relateid=@fieldid AND trantable='ld_field' AND languagetype='en' AND fieldlabel='Spend Time';
delimiter;

SET @tabid=(SELECT tabid FROM ld_tab WHERE `name`='ServiceReturn');
SET @fieldid=(SELECT fieldid FROM ld_field WHERE tabid=@tabid AND columnname='smcreatorid');
UPDATE ld_tranlabel SET fieldlabel='Creator' WHERE tabid=@tabid AND Relateid=@fieldid AND trantable='ld_field' AND languagetype='en' AND fieldlabel='Smcreatorid';
delimiter;

SET @tabid=(SELECT tabid FROM ld_tab WHERE `name`='ServiceReturn');
SET @fieldid=(SELECT fieldid FROM ld_field WHERE tabid=@tabid AND columnname='servant_come');
UPDATE ld_tranlabel SET fieldlabel='Visit of the servicer' WHERE tabid=@tabid AND Relateid=@fieldid AND trantable='ld_field' AND languagetype='en' AND fieldlabel='Whether the service personnel to';
delimiter;

SET @tabid=(SELECT tabid FROM ld_tab WHERE `name`='ServiceContracts');
SET @fieldid=(SELECT fieldid FROM ld_field WHERE tabid=@tabid AND columnname='have_invoicetotal');
UPDATE ld_tranlabel SET fieldlabel='Invoiced Amount' WHERE tabid=@tabid AND Relateid=@fieldid AND trantable='ld_field' AND languagetype='en' AND fieldlabel='Have the invoice amount';
delimiter;

SET @tabid=(SELECT tabid FROM ld_tab WHERE `name`='ServiceContracts');
SET @fieldid=(SELECT fieldid FROM ld_field WHERE tabid=@tabid AND columnname='nothave_invoicetotal');
UPDATE ld_tranlabel SET fieldlabel='Uninvoiced Amount' WHERE tabid=@tabid AND Relateid=@fieldid AND trantable='ld_field' AND languagetype='en' AND fieldlabel='Not the invoice amount';
delimiter;
-- 2019-07-12

UPDATE ld_desk SET fieldlabel='All (exclude unassigned accounts)' WHERE labelbol='allexcludinghignseas' AND languagetype='en';
UPDATE ld_desk SET fieldlabel='Allocated unassigned accounts' WHERE labelbol='LBL_PUBLICALLOCATE' AND languagetype='en';
UPDATE ld_desk SET fieldlabel='Unallocated unassigned accounts' WHERE labelbol='LBL_NOALLOCATE' AND languagetype='en';

UPDATE ld_desk SET fieldlabel='Basic Search' WHERE labelbol='BASICFIND' AND languagetype='en';
UPDATE ld_desk SET fieldlabel='Automatic duplicate checking and merging' WHERE labelbol='CHECKMERGE' AND languagetype='en';
UPDATE ld_desk SET fieldlabel='Display the separating employees' WHERE labelbol='LBL_VIEWDISABLEUSER' AND languagetype='en';

UPDATE ld_desk SET fieldlabel='Send email and attach as DOC' WHERE labelbol='Send_Email_Add_DOC' AND languagetype='en';
UPDATE ld_desk SET fieldlabel='Send email and attach as PDF' WHERE labelbol='Send_Email_Add_PDF' AND languagetype='en';

SET @tabid=4;
SET @fieldid=(SELECT fieldid FROM ld_field WHERE tabid=@tabid AND columnname='salutation');
UPDATE ld_tranlabel SET fieldlabel='Title' WHERE tabid=@tabid AND Relateid=@fieldid AND trantable='ld_field' AND languagetype='en' AND fieldlabel='salutation';
delimiter;

SET @tabid=4;
SET @fieldid=(SELECT fieldid FROM ld_field WHERE tabid=@tabid AND columnname='title');
UPDATE ld_tranlabel SET fieldlabel='Position' WHERE tabid=@tabid AND Relateid=@fieldid AND trantable='ld_field' AND languagetype='en' AND fieldlabel='salutation';
delimiter;

SET @tabid=4;
SET @fieldid=(SELECT fieldid FROM ld_field WHERE tabid=@tabid AND columnname='reference');
UPDATE ld_tranlabel SET fieldlabel='Primary contact' WHERE tabid=@tabid AND Relateid=@fieldid AND trantable='ld_field' AND languagetype='en' AND fieldlabel='Reference';
delimiter;

UPDATE ld_desk SET fieldlabel='Shows that customers exist in this province' WHERE labelbol='thattheprovincehascustomers' AND languagetype='en';
UPDATE ld_desk SET fieldlabel='Shows that no customers exist in this province' WHERE labelbol='indicatesthattheprovincehasnocustomers' AND languagetype='en';

insert into ld_desk (languagetype,labelbol,fieldlabel,labeltype)
select 'zh', 'HAVENOPRINTTEMPLATE','您没有适用的打印模板，请联系管理员检查并设置打印模板！','fixedstr' from dual 
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='HAVENOPRINTTEMPLATE' and labeltype='fixedstr');

insert into ld_desk (languagetype,labelbol,fieldlabel,labeltype)
select 'en', 'HAVENOPRINTTEMPLATE',"You don’t have an applicable print template, please contact your administrator to check and set up the print template.",'fixedstr' from dual 
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='HAVENOPRINTTEMPLATE' and labeltype='fixedstr');
delimiter;

update ld_desk set fieldlabel='您选择了{Var}条记录，批量操作只对前{Var}条记录生效，是否继续' where labelbol='YOUSELECTMAXMASSOPERATIONLIMIT' and Labeltype='jspop' and languagetype='zh';
update ld_desk set fieldlabel='You select {Var} records, the mass operation only effect on the first {Var} records, continue or not' where labelbol='YOUSELECTMAXMASSOPERATIONLIMIT' and Labeltype='jspop' and languagetype='en';
update ld_desk set fieldlabel='确认后初始金额不可再更改，是否继续？' where labelbol='UPDATbank' and Labeltype='jspop' and languagetype='zh';
update ld_desk set fieldlabel='确认后币种和初始金额不可再更改，是否继续？' where labelbol='UPDATEBANKCURRENCY' and Labeltype='jspop' and languagetype='zh';
delimiter;

SET @user_reportid=(SELECT usereportid FROM ld_usereport WHERE `name`='Thestatisticalreportofprojectperformance');
SET @seq=(SELECT sequence FROM ld_usereportcolumns WHERE Usereportid=@user_reportid AND `columns`='ld_project:project_no:project_no:Project_project_no:V');
UPDATE ld_usereportcolumns SET Sequence=sequence+2 WHERE Usereportid=@user_reportid AND sequence>@seq;
UPDATE ld_usereportcolumns SET realcolumns='ld_project:lastname:lastname:OftenUseReport_项目负责人:V',
realencolumns='ld_project:lastname:lastname:OftenUseReport_Person in Charge:V',sequence=@seq+1
WHERE `columns`='ld_project:lastname:lastname:OftenUseReport_lastname:V' AND Usereportid=@user_reportid;

SET @seq=(SELECT sequence FROM ld_usereportcolumns WHERE Usereportid=@user_reportid AND `columns`='ld_account:accountname:accountname:Accounts_accountname:V');
UPDATE ld_usereportcolumns SET Sequence=sequence+2 WHERE Usereportid=@user_reportid AND sequence>@seq;
UPDATE ld_usereportcolumns SET realcolumns='ld_account:last_name:last_name:Accounts_客户负责人:V',
realencolumns='ld_account:last_name:last_name:Accounts_Person in Account:V',sequence=sequence=@seq+1
WHERE `columns`='ld_account:last_name:last_name:Accounts_last_name:V' AND Usereportid=@user_reportid;

SET @i=0;
UPDATE ld_usereportcolumns SET sequence=(@i:=@i+1) WHERE Usereportid=@user_reportid ORDER BY sequence;
delimiter;

UPDATE ld_project a
LEFT JOIN (
	SELECT 
		projectid,
		COUNT(projecttaskid) AS qty_total 
	FROM ld_projecttask 
	WHERE deleted=0 
		AND projectid>0
	GROUP BY projectid
) b ON b.projectid=a.projectid
LEFT JOIN (
	SELECT 
		projectid,
		COUNT(projecttaskid) AS qty_done 
	FROM ld_projecttask 
	WHERE deleted=0 
		AND projectid>0
		AND projecttaskstatus='已完成'
	GROUP BY projectid
) c ON c.projectid=a.projectid
SET a.completetask=IF(IFNULL(b.qty_total,0)<=0,NULL,CONCAT(IFNULL(c.qty_done,0),'/',b.qty_total));
-- 2019-07-16

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

UPDATE ld_version SET old_version='V7.8.1.2',current_version='V7.8.1.2',remark='V7.8.1.2-20190716',wx_version='V7.8.1.2';
delimiter;