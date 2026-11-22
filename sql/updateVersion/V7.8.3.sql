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
select 'en', 'HAVENOPRINTTEMPLATE',"You don't have an applicable print template, please contact your administrator to check and set up the print template.",'fixedstr' from dual 
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='HAVENOPRINTTEMPLATE' and labeltype='fixedstr');
delimiter;

update ld_desk set fieldlabel='您选择了{Var}条记录，批量操作只对前{Var}条记录生效，是否继续' where labelbol='YOUSELECTMAXMASSOPERATIONLIMIT' and Labeltype='jspop' and languagetype='zh';
update ld_desk set fieldlabel='You select {Var} records, the mass operation only effect on the first {Var} records, continue or not' where labelbol='YOUSELECTMAXMASSOPERATIONLIMIT' and Labeltype='jspop' and languagetype='en';
update ld_desk set fieldlabel='确认后初始金额不可再更改，是否继续？' where labelbol='UPDATbank' and Labeltype='jspop' and languagetype='zh';
update ld_desk set fieldlabel='确认后币种和初始金额不可再更改，是否继续？' where labelbol='UPDATEBANKCURRENCY' and Labeltype='jspop' and languagetype='zh';
delimiter;

update ld_desk set fieldlabel='已找到的记录：' where labelbol='TOTALRECORDFOUND' and Labeltype='fixedstr' and languagetype='zh';
update ld_desk set fieldlabel='Total Records found:' where labelbol='TOTALRECORDFOUND' and Labeltype='fixedstr' and languagetype='en';
delimiter;

update ld_appparenttab set sequence=sequence+1 ;
select max(sequence) into @maxsequence from ld_appparenttab;
insert into ld_appparenttab(blockname,presence,sequence,systemdefault,parenttab_label)
select '报表',0,1,'yes' ,'Reports' from dual 
where not exists(select 1 from ld_appparenttab where parenttab_label='Reports');

SET @i=0;
UPDATE ld_appparenttab SET sequence=(@i:=@i+1) ORDER BY sequence;
delimiter;

CALl AddColumn('ld_appparenttabrel','relatename','text','','');
delimiter;

drop PROCEDURE if EXISTS addMobileReportBlock ;
delimiter ||
create PROCEDURE addMobileReportBlock()
begin
declare done  int  default 0;
	declare nname varchar(100);
declare iid int(11);
	declare cur1 CURSOR FOR select id,NAME FROM ld_dashboard_app 
	LEFT JOIN ld_appuiset on ld_dashboard_app.name=ld_appuiset.setname and ld_appuiset.apptype='weixin' 
   and ld_appuiset.userid=1 WHERE wx_presence = 1 and name in('Saleskit','Contractkit','Salesfunnel','InventoryQuery') order by wx_sequence ASC;
	declare continue handler  for not   found  SET done =1;
	OPEN cur1;
	Fetch cur1 into iid, nname;
	select blockid into @blockid from ld_appparenttab where parenttab_label='reports';
	set @i=1;
	loop1: while  done<>1 DO
		set @sql=concat('insert into ld_appparenttabrel(blockid,tabid,sequence,relatename) ','select ',@blockid);
		set @sql=concat(@sql,',',iid,',',@i,',"',nname,'" from dual where not exists(select 1 from ld_appparenttabrel where blockid= ',@blockid,' and  relatename="',nname,'")');
			
	  prepare stmt from @sql;
		execute stmt;
		set @i=@i+1;
		deallocate prepare stmt;
		Fetch cur1 into iid,nname;
	end while loop1;
	close cur1;
end ||
delimiter;

call addMobileReportBlock();
drop PROCEDURE if EXISTS addMobileReportBlock ;
delimiter;


select wx_sequence into @sequence from ld_dashboard_app where name='Saleskit';
update ld_dashboard_app set wx_sequence=wx_sequence+2;
insert into ld_dashboard_app(name,labelbol,modulenames,image,presence,wx_presence,wx_sequence)
select 'Contractkit','Contractkit','SalesOrder','dashboard_6',0,1,@sequence+1 from dual 
where not EXISTS(select 1 from ld_dashboard_app where name='Contractkit');
delimiter;

select blockid into @blockid from ld_appparenttab where parenttab_label='Reports';
select id into @tabid from ld_dashboard_app where name='Contractkit';
select max(sequence) into @maxsequence from ld_appparenttabrel;
insert into ld_appparenttabrel(blockid,tabid,sequence,relatename)
select @blockid,@tabid,1,'Contractkit' from dual where not EXISTS(select 1 from ld_appparenttabrel where relatename='Contractkit');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','Contractkit','合同简报','fixedstr' from dual 
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='contractkit' and Labeltype='fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','Contractkit','Contract kit','fixedstr' from dual 
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='contractkit' and Labeltype='fixedstr');
delimiter;
-- 2019-07-06

DROP PROCEDURE IF EXISTS `reset_picklist_timesheet_20190709`;
delimiter ||
CREATE  PROCEDURE `reset_picklist_timesheet_20190709`(
)
BEGIN

	IF NOT EXISTS (SELECT 1 FROM ld_timesheet) THEN
		SET @listid=(SELECT listid FROM ld_picklist_set WHERE listname='indirectcharge' AND relatetable='ld_tabdetailfield' LIMIT 1);
		IF (SELECT COUNT(1) FROM ld_picklist_values WHERE listid=@listid AND listvalue IN ('B&P','Sick','Training','Vacation','Holiday'))=5 THEN
			UPDATE ld_picklist_values SET listvalue='节日' WHERE listvalue='Holiday' AND listid=@listid;
			UPDATE ld_picklist_values SET listvalue='假期' WHERE listvalue='Vacation' AND listid=@listid;
			UPDATE ld_picklist_values SET listvalue='培训' WHERE listvalue='Training' AND listid=@listid;
			UPDATE ld_picklist_values SET listvalue='病假' WHERE listvalue='Sick' AND listid=@listid;
			UPDATE ld_picklist_values SET listvalue='其他' WHERE listvalue='Other' AND listid=@listid;
		END IF;
	END IF;

END ||
delimiter;

CALL reset_picklist_timesheet_20190709();
DROP PROCEDURE IF EXISTS `reset_picklist_timesheet_20190709`;
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','timesheet_direct','关联源单','fixedstr' from dual 
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='timesheet_direct' and Labeltype='fixedstr');

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','timesheet_direct','Direct','fixedstr' from dual 
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='timesheet_direct' and Labeltype='fixedstr');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','timesheet_indirect','不关联源单','fixedstr' from dual 
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='timesheet_indirect' and Labeltype='fixedstr');

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','timesheet_indirect','Indirect','fixedstr' from dual 
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='timesheet_indirect' and Labeltype='fixedstr');
delimiter;


UPDATE ld_producttoolfield a
INNER JOIN (SELECT fieldid,tablename FROM ld_field WHERE tabid=14) b ON b.fieldid=a.fieldid
SET a.tablename=b.tablename
WHERE a.tablename LIKE '%detailscf' 
	AND a.fieldid>0;
-- 2019-07-10

UPDATE ld_tranlabel SET fieldlabel='设置{$Accounts.Accounts}查重和选择单据弹出层界面最多显示记录的条数' WHERE languagetype='zh' AND Relateid=151 AND trantable='ld_systems_deploy';
UPDATE ld_tranlabel SET fieldlabel='Setting the maximum number of display records for the pop-up interface of the duplicate and selecting bill' WHERE languagetype='en' AND Relateid=151 AND trantable='ld_systems_deploy';
UPDATE ld_systems_deploy SET description='设置客户查重弹出层界面最多显示记录的条数' WHERE deploy_type=151;

select tabid into @tabid from ld_tab where name='contactrecords';
select blockid into @blockid  from ld_blocks where tabid=@tabid and blocklabel='LBL_CUSTOM_INFORMATION';
select sequence into @sequence from ld_field where tabid=@tabid and block=@blockid and columnname='accountid';
update ld_field set sequence=sequence+2 where tabid=@tabid and block=@blockid and sequence>@sequence; 
select max(fieldid) into @fieldid from ld_field;
update ld_field_seq set id=id+1 where not exists(select 1 from ld_field where tabid=@tabid and columnname='rating');
insert into ld_field(tabid,fieldid,columnname,tablename,uitype,fieldname,fieldlabel,presence,sequence,block,displaytype,typeofdata,bigtype)
select @tabid,@fieldid+1,'rating','ld_contactrecords',15,'rating','客户状态',2,@sequence+1,@blockid,1,'v~O','RelatedModuleField'  from dual
where not exists(select 1 from ld_field where tabid=@tabid and columnname='rating');
delimiter;

select fieldid into @fieldid from ld_field where tabid=6 and columnname='rating';
select fieldlabel into @zhlabel from ld_tranlabel where languagetype='zh' and tabid=6 and Relateid=@fieldid and trantable='ld_field';
select fieldlabel into @enlabel from ld_tranlabel where languagetype='en' and tabid=6 and Relateid=@fieldid and trantable='ld_field';

select tabid into @tabid from ld_tab where name='contactrecords';
select fieldid into @fieldid from ld_field where tabid=@tabid and columnname='rating';
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'zh' ,'ld_field',@tabid,@fieldid,@zhlabel from dual 
where not exists(select 1 from ld_tranlabel where tabid=@tabid and trantable='ld_field' and relateid=@fieldid and languagetype='zh');

insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'en' ,'ld_field',@tabid,@fieldid,@enlabel from dual 
where not exists(select 1 from ld_tranlabel where tabid=@tabid and trantable='ld_field' and relateid=@fieldid and languagetype='en');
delimiter;

call fieldprofile('ContactRecords');
delimiter;

CALl AddColumn('ld_contactrecords','rating','varchar','255','');
delimiter;

select tabid into @tabid from ld_tab where name='contactrecords';
select fieldid into @trigger_fieldid from ld_field where tabid=@tabid and columnname='accountid';
select fieldid into @effect_fieldid from ld_field where tabid=@tabid and columnname='rating';
insert into ld_related_field(fieldtype,trigger_fieldid,effect_fieldid,curmodule_columninfo,fromvalue_type,fromvalue_info)
select 'main',@trigger_fieldid,@effect_fieldid,'rating','column','rating' from dual 
where not exists(select 1 from ld_related_field where trigger_fieldid=@trigger_fieldid and effect_fieldid=@effect_fieldid);
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
-- 2019-07-12

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
-- 2019-07-16

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

DELETE FROM ld_tranlabel WHERE trantable='ld_producttoolfield' AND Relateid NOT IN (SELECT producttoolfieldid FROM ld_producttoolfield);
DELETE FROM ld_tranlabel WHERE trantable='ld_field' AND Relateid NOT IN (SELECT fieldid FROM ld_field);

insert into ld_desk (languagetype,labelbol,fieldlabel,labeltype)
select 'zh', 'THEAPPPARAMENTERS','移动端参数','fixedstr' from dual 
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='THEAPPPARAMENTERS' and labeltype='fixedstr');

insert into ld_desk (languagetype,labelbol,fieldlabel,labeltype)
select 'en', 'THEAPPPARAMENTERS','Mobile Applications','fixedstr' from dual 
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='THEAPPPARAMENTERS' and labeltype='fixedstr');
delimiter;

UPDATE ld_systems_deploy SEt roottype=8,sequence=1 WHERE deploy_type=114;
UPDATE ld_systems_deploy SEt roottype=8,sequence=2 WHERE deploy_type=143;
UPDATE ld_systems_deploy SEt roottype=8,sequence=3 WHERE deploy_type=200;
-- 2019-07-22

update ld_desk set fieldlabel='recycling rule' where labelbol='RECYCLERULE' and Labeltype='fixedstr' and languagetype='en';
update ld_desk set fieldlabel='single recycle rule' where labelbol='SINGLERULE' and Labeltype='fixedstr' and languagetype='en';
delimiter;

update ld_desk set fieldlabel='您选择了{Var}条记录，批量操作只对前{Var}条记录生效，是否继续' where labelbol='YOUSELECTMAXMASSOPERATIONLIMIT' and Labeltype='jspop' and languagetype='zh';
update ld_desk set fieldlabel='You select {Var} records, the mass operation only effect on the first {Var} records, continue or not' where labelbol='YOUSELECTMAXMASSOPERATIONLIMIT' and Labeltype='jspop' and languagetype='en';
update ld_desk set fieldlabel='确认后初始金额不可再更改，是否继续？' where labelbol='UPDATbank' and Labeltype='jspop' and languagetype='zh';
update ld_desk set fieldlabel='确认后币种和初始金额不可再更改，是否继续？' where labelbol='UPDATEBANKCURRENCY' and Labeltype='jspop' and languagetype='zh';
delimiter;

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
delimiter;

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

update ld_profile2standardpermissions set relatednames=CONCAT('contractkit,',relatednames)
where tabid=-2 and  relatednames not like '%contractkit%';
delimiter;
-- 2019-07-23

call addcolumn('ld_approve','default_on_new','varchar',255,null);
alter table `ld_approve` alter column `default_on_new` drop default;
alter table `ld_approve` alter column `default_on_new` set default 'no';
call addcolumn('ld_approve','default_on_submit','varchar',255,null);
alter table `ld_approve` alter column `default_on_submit` drop default;
alter table `ld_approve` alter column `default_on_submit` set default 'no';
update ld_approve set default_on_new='no' where ifnull(default_on_new,'') <> 'yes';
update ld_approve set default_on_submit='no' where ifnull(default_on_submit,'') <> 'yes';
delete from ld_desk where labelbol='APPROVEFINISHEDALLOWEDIT' and languagetype='en';
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
  select 'en','APPROVEFINISHEDALLOWEDIT','Whether editing documents is allowed at the end of approval','fixedstr' from dual where not exists(select 1 from ld_desk  where labelbol='APPROVEFINISHEDALLOWEDIT' and labeltype='fixedstr' and languagetype='en');
insert into ld_desk (languagetype,labelbol,fieldlabel,labeltype)
  select 'zh','APPROVEDEFAULTVALUEONNEW','是否移动端新建时默认流程','fixedstr' from dual
  where not exists(select * from ld_desk where languagetype='zh' and labelbol='APPROVEDEFAULTVALUEONNEW' and labeltype='fixedstr');
insert into ld_desk (languagetype,labelbol,fieldlabel,labeltype)
  select 'en','APPROVEDEFAULTVALUEONNEW','Default values when new on the mobile','fixedstr' from dual
  where not exists(select * from ld_desk where languagetype='en' and labelbol='APPROVEDEFAULTVALUEONNEW' and labeltype='fixedstr');
insert into ld_desk (languagetype,labelbol,fieldlabel,labeltype)
  select 'zh','APPROVEDEFAULTVALUEONSUBMIT','是否提交审批时默认流程','fixedstr' from dual
  where not exists(select * from ld_desk where languagetype='zh' and labelbol='APPROVEDEFAULTVALUEONSUBMIT' and labeltype='fixedstr');
insert into ld_desk (languagetype,labelbol,fieldlabel,labeltype)
  select 'en','APPROVEDEFAULTVALUEONSUBMIT','Default process when submitting for approval','fixedstr' from dual
  where not exists(select * from ld_desk where languagetype='en' and labelbol='APPROVEDEFAULTVALUEONSUBMIT' and labeltype='fixedstr');
delimiter;

select max(fieldtypeid) into @maxfieldtypeid from ld_ws_fieldtype ; 
insert into ld_ws_fieldtype(fieldtypeid,uitype,fieldtype)
select @maxfieldtypeid+1,150,'reference' from dual 
where not EXISTS(select * from ld_ws_fieldtype where uitype=150);
delimiter;

update ld_ws_fieldtype set fieldtype='reference' where uitype=150;
delimiter;

select fieldtypeid into @fieldtypeid from  ld_ws_fieldtype where uitype=150;
insert into ld_ws_referencetype(fieldtypeid,type)
select @fieldtypeid,'PurchaseOrder' from dual 
where not EXISTS(select 1 from ld_ws_referencetype where type='PurchaseOrder');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','SelectBill','Select An Exists Bill','fixedstr' from dual 
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='SelectBill' and labeltype='fixedstr');

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','SelectBill','关联选择单据（单选）','fixedstr' from dual 
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='SelectBill' and labeltype='fixedstr');
delimiter;


insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','ALLOWDataRange','Optional Data Range','fixedstr' from dual 
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='ALLOWDataRange' and labeltype='fixedstr');

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','ALLOWDataRange','可选择的数据范围','fixedstr' from dual 
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='ALLOWDataRange' and labeltype='fixedstr');
delimiter;


insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','MaxRowsShow','Max rows displayed','fixedstr' from dual 
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='MaxRowsShow' and labeltype='fixedstr');

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','MaxRowsShow','最多显示数据条数','fixedstr' from dual 
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='MaxRowsShow' and labeltype='fixedstr');
delimiter;


insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','RelateChoiceModule','Related Module','fixedstr' from dual 
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='RelateChoiceModule' and labeltype='fixedstr');

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','RelateChoiceModule','关联选择对象','fixedstr' from dual 
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='RelateChoiceModule' and labeltype='fixedstr');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','ALLOWINQUIRE','Permitted to inquire','fixedstr' from dual 
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='ALLOWINQUIRE' and labeltype='fixedstr');

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','ALLOWINQUIRE','有权限查询的','fixedstr' from dual 
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='ALLOWINQUIRE' and labeltype='fixedstr');
delimiter;
CALl AddColumn('ld_field','datarang','varchar','50','all');
delimiter;

CALl AddColumn('ld_field','maxrowsshow','int','11','5');
delimiter;
CALl AddColumn('ld_option_module','datarang','varchar','50','all');
delimiter;
CALl AddColumn('ld_option_module','fieldname','varchar','50','source_list');
delimiter;
CALl AddColumn('ld_option_module','maxrowsshow','int','11',5);
delimiter;
update ld_field 
INNER JOIN 
(select uitype from ld_ws_referencetype INNER JOIN ld_ws_fieldtype
on ld_ws_fieldtype.fieldtypeid=ld_ws_referencetype.fieldtypeid)
as tmpinfo on tmpinfo.uitype=ld_field.uitype
set maxrowsshow=(select deploy_value from ld_systems_deploy  where deploy_type=151) 
where   EXISTS(select 1 from ld_systems_deploy  where deploy_type=74 and presence=0);
delimiter;
update ld_option_module set maxrowsshow=(select deploy_value from ld_systems_deploy  where deploy_type=151) 
where   EXISTS(select 1 from ld_systems_deploy  where deploy_type=74 and presence=0);
delimiter;
update ld_field set datarang='all'  where uitype in(select uitype from ld_ws_fieldtype
INNER JOIN ld_ws_referencetype on ld_ws_referencetype.fieldtypeid=ld_ws_fieldtype.fieldtypeid
 where  type='accounts') and  EXISTS(select 1 from ld_systems_deploy  where deploy_type=74 and deploy_value=1 and presence=0);
update ld_field set datarang='permit'  where uitype in(select uitype from ld_ws_fieldtype
INNER JOIN ld_ws_referencetype on ld_ws_referencetype.fieldtypeid=ld_ws_fieldtype.fieldtypeid
 where  type='accounts') and  EXISTS(select 1 from ld_systems_deploy  where deploy_type=74 and deploy_value=0 and presence=0);

update ld_systems_deploy set presence=1 where deploy_type=74 ;
delimiter;

update ld_field set datarang='all'  where uitype in( select uitype from ld_ws_fieldtype
INNER JOIN ld_ws_referencetype on ld_ws_referencetype.fieldtypeid=ld_ws_fieldtype.fieldtypeid
 where  type='contacts') and  EXISTS(select 1 from ld_systems_deploy  where deploy_type=108 and deploy_value=1 and presence=0);
update ld_field set datarang='permit'  where uitype in( select uitype from ld_ws_fieldtype
INNER JOIN ld_ws_referencetype on ld_ws_referencetype.fieldtypeid=ld_ws_fieldtype.fieldtypeid
 where  type='contacts') and  EXISTS(select 1 from ld_systems_deploy  where deploy_type=108 and deploy_value=0 and presence=0);

update ld_systems_deploy set presence=1 where deploy_type=108 ;
delimiter;

update ld_field set datarang='all'  where uitype in( select uitype from ld_ws_fieldtype
INNER JOIN ld_ws_referencetype on ld_ws_referencetype.fieldtypeid=ld_ws_fieldtype.fieldtypeid
 where  type='Vendors') and  EXISTS(select 1 from ld_systems_deploy  where deploy_type=109 and deploy_value=1 and presence=0);
update ld_field set datarang='permit'  where uitype in( select uitype from ld_ws_fieldtype
INNER JOIN ld_ws_referencetype on ld_ws_referencetype.fieldtypeid=ld_ws_fieldtype.fieldtypeid
 where  type='Vendors') and  EXISTS(select 1 from ld_systems_deploy  where deploy_type=109 and deploy_value=0 and presence=0);

update ld_systems_deploy set presence=1 where deploy_type=109 ;
delimiter;

update ld_field set datarang='all'  where (uitype in( select uitype from ld_ws_fieldtype
INNER JOIN ld_ws_referencetype on ld_ws_referencetype.fieldtypeid=ld_ws_fieldtype.fieldtypeid
 where  type='SalesOrder')) and  EXISTS(select 1 from ld_systems_deploy  where deploy_type=116 and deploy_value=1 and presence=0);

update ld_field set datarang='permit'  where (uitype in( select uitype from ld_ws_fieldtype
INNER JOIN ld_ws_referencetype on ld_ws_referencetype.fieldtypeid=ld_ws_fieldtype.fieldtypeid
 where  type='SalesOrder')) and  EXISTS(select 1 from ld_systems_deploy  where deploy_type=116 and deploy_value=0 and presence=0);

delimiter;
select tabid into @option_tabid from ld_tab where name='salesorder';
update ld_option_module set datarang='all'
 where option_tabid=@option_tabid and  EXISTS(select 1 from ld_systems_deploy  where deploy_type=116 and deploy_value=1 and presence=0);
update ld_option_module set datarang='permit'
 where option_tabid=@option_tabid and  EXISTS(select 1 from ld_systems_deploy  where deploy_type=116 and deploy_value=0 and presence=0);
update ld_systems_deploy set presence=1 where deploy_type=116 ;
delimiter;

update ld_field set datarang='all'  where (uitype in( select uitype from ld_ws_fieldtype
INNER JOIN ld_ws_referencetype on ld_ws_referencetype.fieldtypeid=ld_ws_fieldtype.fieldtypeid
 where  type='ServiceContracts')) and  EXISTS(select 1 from ld_systems_deploy  where deploy_type=117 and deploy_value=1 and presence=0);


update ld_field set datarang='permit'  where (uitype in( select uitype from ld_ws_fieldtype
INNER JOIN ld_ws_referencetype on ld_ws_referencetype.fieldtypeid=ld_ws_fieldtype.fieldtypeid
 where  type='ServiceContracts')) and  EXISTS(select 1 from ld_systems_deploy  where deploy_type=117 and deploy_value=0 and presence=0);
delimiter;
select tabid into @option_tabid from ld_tab where name='ServiceContracts';
UPDATE ld_option_module set datarang='all'  
where option_tabid=@option_tabid and  EXISTS(select 1 from ld_systems_deploy  where deploy_type=117 and deploy_value=1 and presence=0);

update ld_option_module set datarang='permit'
 where option_tabid=@option_tabid and  EXISTS(select 1 from ld_systems_deploy  where deploy_type=117 and deploy_value=0 and presence=0);
update ld_systems_deploy set presence=1 where deploy_type=117 ;
delimiter;

update ld_field set datarang='all'  where (uitype in( select uitype from ld_ws_fieldtype
INNER JOIN ld_ws_referencetype on ld_ws_referencetype.fieldtypeid=ld_ws_fieldtype.fieldtypeid
 where  type='PurchaseOrder') ) and  EXISTS(select 1 from ld_systems_deploy  where deploy_type=118 and deploy_value=1 and presence=0);
update ld_field set datarang='permit'  where (uitype in( select uitype from ld_ws_fieldtype
INNER JOIN ld_ws_referencetype on ld_ws_referencetype.fieldtypeid=ld_ws_fieldtype.fieldtypeid
 where  type='PurchaseOrder') ) and  EXISTS(select 1 from ld_systems_deploy  where deploy_type=118 and deploy_value=0 and presence=0);
delimiter;
select tabid into @option_tabid from ld_tab where name='PurchaseOrder';
UPDATE ld_option_module set datarang='all'  
where option_tabid=@option_tabid and  EXISTS(select 1 from ld_systems_deploy  where deploy_type=118 and deploy_value=1 and presence=0);

update ld_option_module set datarang='permit'
 where option_tabid=@option_tabid and  EXISTS(select 1 from ld_systems_deploy  where deploy_type=118 and deploy_value=0 and presence=0);
update ld_systems_deploy set presence=1 where deploy_type=118 ;
delimiter;

update ld_field set datarang='all'  where (uitype in( select uitype from ld_ws_fieldtype
INNER JOIN ld_ws_referencetype on ld_ws_referencetype.fieldtypeid=ld_ws_fieldtype.fieldtypeid
 where  type='Project') ) and  EXISTS(select 1 from ld_systems_deploy  where deploy_type=119 and deploy_value=1 and presence=0);
update ld_field set datarang='permit'  where (uitype in( select uitype from ld_ws_fieldtype
INNER JOIN ld_ws_referencetype on ld_ws_referencetype.fieldtypeid=ld_ws_fieldtype.fieldtypeid
 where  type='Project') ) and  EXISTS(select 1 from ld_systems_deploy  where deploy_type=119 and deploy_value=0 and presence=0);
delimiter;
select tabid into @option_tabid from ld_tab where name='Project';
UPDATE ld_option_module set datarang='all'  
where option_tabid=@option_tabid and  EXISTS(select 1 from ld_systems_deploy  where deploy_type=119 and deploy_value=1 and presence=0);
update ld_option_module set datarang='permit'
 where option_tabid=@option_tabid and  EXISTS(select 1 from ld_systems_deploy  where deploy_type=119 and deploy_value=0 and presence=0);
update ld_systems_deploy set presence=1 where deploy_type=119 ;
delimiter;

update ld_field set datarang='all'  where (uitype in( select uitype from ld_ws_fieldtype
INNER JOIN ld_ws_referencetype on ld_ws_referencetype.fieldtypeid=ld_ws_fieldtype.fieldtypeid
 where  type='Potentials') ) and  EXISTS(select 1 from ld_systems_deploy  where deploy_type=138 and deploy_value=1 and presence=0);
update ld_field set datarang='permit'  where (uitype in( select uitype from ld_ws_fieldtype
INNER JOIN ld_ws_referencetype on ld_ws_referencetype.fieldtypeid=ld_ws_fieldtype.fieldtypeid
 where  type='Potentials') ) and  EXISTS(select 1 from ld_systems_deploy  where deploy_type=138 and deploy_value=0 and presence=0);

update ld_systems_deploy set presence=1 where deploy_type=138 ;
delimiter;
update ld_option_module set datarang='all' where datarang is null;
delimiter;
update ld_tranlabel set fieldlabel='设置{$Accounts.Accounts}查重列表每页显示记录的条数' where relateid=151 and  trantable='ld_systems_deploy' and languagetype='zh';
update ld_tranlabel set fieldlabel='Setting up the number of entries per page for the {$Accounts.Accounts} to check and select the {$Accounts.Accounts}  list' where relateid=151 and  trantable='ld_systems_deploy' and languagetype='en';
delimiter;

update ld_field set bigtype='reference'
where uitype in(select uitype from ld_ws_fieldtype
                 inner JOIN ld_ws_referencetype
         on ld_ws_referencetype.fieldtypeid=ld_ws_fieldtype.fieldtypeid);
delimiter;
update ld_option_module 
inner join ld_field on ld_field.tabid=ld_option_module.tabid
set ld_option_module.fieldname=ld_field.fieldname
where uitype=202 or uitype=208;
delimiter;
update ld_field set bigtype='selectsource'  where uitype=202 or uitype=208;
delimiter;

update   ld_field 
left join (select tabid  from ld_field  where searchfieldtype=0) as tmp
on tmp.tabid=ld_field.tabid 
set searchfieldtype=0 where (uitype=4 or columnname='smownereid') and tmp.tabid is null;
delimiter;

update ld_field  INNER JOIN ld_entityname on ld_entityname.fieldname=ld_field.fieldname
set searchfieldtype=0;
delimiter;
update ld_ws_fieldtype  set fieldtype='currency' where uitype=117;
delete from ld_ws_referencetype where fieldtypeid in(select fieldtypeid from  ld_ws_fieldtype where uitype=117);
delimiter;
update ld_field set fieldname='selectlistval' where columnname='source_list' and uitype=202;
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','WholeTextArea','Whole line textarea','fixedstr' from dual 
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='WholeTextArea' and labeltype='fixedstr');

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','WholeTextArea','整行文本区域','fixedstr' from dual 
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='WholeTextArea' and labeltype='fixedstr');
delimiter;


insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','AutoNumber','Auto Number','fixedstr' from dual 
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='AutoNumber' and labeltype='fixedstr');

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','AutoNumber','自动编号','fixedstr' from dual 
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='AutoNumber' and labeltype='fixedstr');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','LocationMap','Location Map','fixedstr' from dual 
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='LocationMap' and labeltype='fixedstr');

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','LocationMap','定位地图','fixedstr' from dual 
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='LocationMap' and labeltype='fixedstr');
delimiter;

update ld_field set bigtype='relatedmodulefield' where bigtype='RelatedModuleField';
delimiter;

update ld_field set bigtype='multipicklist' where bigtype='multiselectcombo';
delimiter;

insert into ld_ws_fieldtype(uitype,fieldtype)select 1101,'mobile' from dual 
where not exists(select 1 from ld_ws_fieldtype where uitype=1101);
delimiter;

insert into ld_ws_fieldtype(uitype,fieldtype)select 1102,'fax' from dual 
where not exists(select 1 from ld_ws_fieldtype where uitype=1102);
delimiter;

insert into ld_ws_fieldtype(uitype,fieldtype)select 1103,'qq' from dual 
where not exists(select 1 from ld_ws_fieldtype where uitype=1103);
delimiter;
insert into ld_ws_fieldtype(uitype,fieldtype)select 7,'number' from dual 
where not exists(select 1 from ld_ws_fieldtype where uitype=7);
delimiter;
insert into ld_ws_fieldtype(uitype,fieldtype)select 86,'datetime' from dual 
where not exists(select 1 from ld_ws_fieldtype where uitype=86);
delimiter;

insert into ld_ws_fieldtype(uitype,fieldtype)select 70,'datetime' from dual 
where not exists(select 1 from ld_ws_fieldtype where uitype=70);
delimiter;

insert into ld_ws_fieldtype(uitype,fieldtype)select 14,'time' from dual 
where not exists(select 1 from ld_ws_fieldtype where uitype=14);
delimiter;

update ld_ws_fieldtype set fieldtype='longtextarea' where uitype=19;
delimiter;
update ld_field INNER JOIN ld_ws_fieldtype on ld_field.uitype=ld_ws_fieldtype.uitype
set ld_field.bigtype=ld_ws_fieldtype.fieldtype
where ld_ws_fieldtype.fieldtype<>'reference';
delimiter;
-- 2019-07-24

UPDATE ld_tranlabel SET fieldlabel="Whether the user’s password is strictly managed"
WHERE Relateid=90 AND trantable='ld_systems_deploy' AND languagetype='en';

UPDATE ld_tranlabel SET fieldlabel="Whether to activate verification code when login"
WHERE Relateid=73 AND trantable='ld_systems_deploy' AND languagetype='en';

UPDATE ld_tranlabel SET fieldlabel="Set the style of the mobile phone field that display in the system (whether part of the content is hidden)"
WHERE Relateid=80 AND trantable='ld_systems_deploy' AND languagetype='en';

UPDATE ld_tranlabel SET fieldlabel="Set the data range influenced by the displayed style of mobile phone"
WHERE Relateid=81 AND trantable='ld_systems_deploy' AND languagetype='en';

UPDATE ld_tranlabel SET fieldlabel="Whether to allow the user to create {$HelpDesk.HelpDesk} ticket after the due date of service"
WHERE Relateid=166 AND trantable='ld_systems_deploy' AND languagetype='en';

UPDATE ld_tranlabel SET fieldlabel="Whether the sharing function can only be operated by the person in charge of the order and the administrator"
WHERE Relateid=33 AND trantable='ld_systems_deploy' AND languagetype='en';

UPDATE ld_tranlabel SET fieldlabel="Whether to display all users when using the distribution function to choose the assigner"
WHERE Relateid=110 AND trantable='ld_systems_deploy' AND languagetype='en';

UPDATE ld_tranlabel SET fieldlabel="Whether to distribute related information when distributing the {$Accounts.Accounts}"
WHERE Relateid=61 AND trantable='ld_systems_deploy' AND languagetype='en';

UPDATE ld_tranlabel SET fieldlabel="Whether to distribute related information when distributing the {$Potentials.Potentials}"
WHERE Relateid=26 AND trantable='ld_systems_deploy' AND languagetype='en';

UPDATE ld_tranlabel SET fieldlabel="Set the number of lines when adding products in the entry details"
WHERE Relateid=122 AND trantable='ld_systems_deploy' AND languagetype='en';

UPDATE ld_tranlabel SET fieldlabel="Whether to add automatically a new line after entering last product information"
WHERE Relateid=123 AND trantable='ld_systems_deploy' AND languagetype='en';

UPDATE ld_tranlabel SET fieldlabel="Set the reference field of price and calculation of {$Products.Products} in the entry details"
WHERE Relateid=124 AND trantable='ld_systems_deploy' AND languagetype='en';

UPDATE ld_tranlabel SET fieldlabel="Whether to recalculate unit price or discount after entering the total price tax in the entry details"
WHERE Relateid=140 AND trantable='ld_systems_deploy' AND languagetype='en';

UPDATE ld_tranlabel SET fieldlabel="Whether the unit price in the {$SalesOrder.SalesOrder} or {$Quotes.Quotes} is automatically based on the customer's recent purchase record"
WHERE Relateid=79 AND trantable='ld_systems_deploy' AND languagetype='en';

UPDATE ld_tranlabel SET fieldlabel="设置{$SalesOrder.SalesOrder}或{$Quotes.Quotes}中单价是否自动根据客户最近购买记录带出"
WHERE Relateid=79 AND trantable='ld_systems_deploy' AND languagetype='zh';

UPDATE ld_systems_deploy SET inputvalue='[{"value":"0","text":"YES"},{"value":"1","text":"NO"},{"sql":""},{"or_relatedmodule":""}]' WHERE deploy_type=79;

UPDATE ld_tranlabel SET fieldlabel="Whether to count unapproved {$CashBill.CashBill} when calculating the amount received"
WHERE Relateid=83 AND trantable='ld_systems_deploy' AND languagetype='en';

UPDATE ld_tranlabel SET fieldlabel="Whether to count unapproved {$SendCashBill.SendCashBill} when calculating the amount paid"
WHERE Relateid=84 AND trantable='ld_systems_deploy' AND languagetype='en';

UPDATE ld_tranlabel SET fieldlabel="Set the number of records displayed per page in the chronological list"
WHERE Relateid=13 AND trantable='ld_systems_deploy' AND languagetype='en';

UPDATE ld_tranlabel SET fieldlabel="Set the number of records displayed per page on the related information list in the detailed interface of orders"
WHERE Relateid=14 AND trantable='ld_systems_deploy' AND languagetype='en';

UPDATE ld_tranlabel SET fieldlabel="Set the maximum number of records displayed on each page for the pop-up interface of the duplicate checking"
WHERE Relateid=151 AND trantable='ld_systems_deploy' AND languagetype='en';

UPDATE ld_tranlabel SET fieldlabel="Set the upper limit of the number of records for batch operation in the chronological list"
WHERE Relateid=67 AND trantable='ld_systems_deploy' AND languagetype='en';

UPDATE ld_tranlabel SET fieldlabel="Whether to display the query statistics chart below the chronological list"
WHERE Relateid=137 AND trantable='ld_systems_deploy' AND languagetype='en';

UPDATE ld_tranlabel SET fieldlabel="Whether the date of {$CooperativeWork.CooperativeWork} is allowed to be selected"
WHERE Relateid=198 AND trantable='ld_systems_deploy' AND languagetype='en';

UPDATE ld_tranlabel SET fieldlabel="Set the decimal number of the Quantity field in the entry details of products"
WHERE Relateid=49 AND trantable='ld_systems_deploy' AND languagetype='en';

UPDATE ld_tranlabel SET fieldlabel="Set the decimal number of the Unit Price field in the entry details of products"
WHERE Relateid=93 AND trantable='ld_systems_deploy' AND languagetype='en';

DELETE FROM ld_tranlabel WHERE trantable='ld_field' AND Relateid IS NULL AND fieldlabel IN ('负责人','Assigned To');
-- 2019-07-26

DROP PROCEDURE IF EXISTS `addtableIndex`;
delimiter ||
CREATE  PROCEDURE `addtableIndex`(
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

DROP PROCEDURE IF EXISTS `Del_TableIndex`;
delimiter ||
CREATE  PROCEDURE `Del_TableIndex`(
	tmp_tablename varchar(100),
	tmp_indexname varchar(100)
)
BEGIN  

	IF EXISTS (SELECT 1 FROM information_schema.STATISTICS WHERE TABLE_SCHEMA=DATABASE() AND TABLE_NAME=tmp_tablename AND index_name=tmp_indexname) THEN  
		SET @execsql=CONCAT(' DROP INDEX ',tmp_indexname,' ON ',tmp_tablename);
		PREPARE stmt_execsql FROM @execsql; 
		EXECUTE stmt_execsql;
		DEALLOCATE PREPARE stmt_execsql;
	END IF;

end ||
delimiter;

CALL Del_TableIndex('ld_approvelog','idx_approvelog_crmid');
CALL addtableIndex('ld_approvelog','crmid','crmid');
CALL addtableIndex('ld_approvelog','approveid','approveid');
-- 2019-07-30

UPDATE ld_desk SET fieldlabel='Sharer' WHERE labelbol='ShareUsers' AND languagetype='en' AND fieldlabel='Engineers'
	AND NOT EXISTS (SELECT 1 FROM ld_version WHERE account='utrc');

UPDATE ld_tranlabel SET fieldlabel='Transfer to Account' WHERE trantable='ld_field' AND languagetype='en' AND fieldlabel='Account In' 
	AND Relateid IN (SELECT fieldid FROM ld_field WHERE columnname='inaccount' AND tablename IN ('ld_putcash','ld_cashdeposit'));
UPDATE ld_tranlabel SET fieldlabel='Transfer from  Account' WHERE trantable='ld_field' AND languagetype='en' AND fieldlabel='Account Out' 
	AND Relateid IN (SELECT fieldid FROM ld_field WHERE columnname='outaccount' AND tablename IN ('ld_putcash','ld_cashdeposit'));

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','SmownerChangeView','Change log of the person in charge','fixedstr' from dual 
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='SmownerChangeView' and labeltype='fixedstr');

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','SmownerChangeView','负责人变更历史','fixedstr' from dual 
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='SmownerChangeView' and labeltype='fixedstr');
delimiter;

UPDATE ld_desk SET fieldlabel='Please choose the emails that you want to send to' 
WHERE labelbol='CHOOSEWANTSENDEMAIL' AND languagetype='en';

UPDATE ld_desk SET fieldlabel='Please choose the emails that you want to send to' 
WHERE labelbol='PCWYWTSETE' AND languagetype='en';


UPDATE ld_desk SET fieldlabel='From the date of distribution or creation' 
WHERE labelbol='ALLOCATEORCREATETIMESTART' AND languagetype='en';

UPDATE ld_desk SET fieldlabel='The duration between the latest creation of {$ContactRecords.ContactRecords} and the day of distribution or creation has exceeded for' 
WHERE labelbol='ALLOCATEORGETSTARTNOCREATECONTACTRECORDSCREATE' AND languagetype='en';

UPDATE ld_desk SET fieldlabel='The duration between the latest creation of {$Potentials.Potentials} and the day of distribution or creation has exceeded for' 
WHERE labelbol='ALLOCATEORGETSTARTNOCREATEPOTENTIALSCREATE' AND languagetype='en';

UPDATE ld_desk SET fieldlabel='The duration between the latest creation of {$SalesOrder.SalesOrder} and the day of distribution or creation has exceeded for' 
WHERE labelbol='ALLOCATEORGETSTARTNOCREATESALESORDERCREATE' AND languagetype='en';

UPDATE ld_desk SET fieldlabel='The duration between the latest creation of {$ServiceContracts.ServiceContracts} and the day of distribution or creation has exceeded for' 
WHERE labelbol='ALLOCATEORGETSTARTNOCREATESERVICECONTRACTSCREATE' AND languagetype='en';

UPDATE ld_desk SET fieldlabel='The duration between the latest creation of {$CashBill.CashBill} and the day of distribution or creation has exceeded for' 
WHERE labelbol='ALLOCATEORGETSTARTNOCREATECASHBILLCREATE' AND languagetype='en';

UPDATE ld_desk SET fieldlabel='The duration between the latest creation of signing in and the day of distribution or creation has exceeded for' 
WHERE labelbol='ALLOCATEORGETSTARTNOCREATESINGINCREATE' AND languagetype='en';

UPDATE ld_desk SET fieldlabel='The duration between the latest creation of {$OutboundOrder.OutboundOrder} and the day of distribution or creation has exceeded for' 
WHERE labelbol='ALLOCATEORGETSTARTNOCREATEOUTBOUNDORDERCREATE' AND languagetype='en';


UPDATE ld_usereportcolumns SET realencolumns='ld_singin:record:record:OftenUseReport_Customer Type:V'
WHERE `columns`='ld_singin:record:record:OftenUseReport_拜访对象类型:V' AND realencolumns='ld_singin:record:record:OftenUseReport_SinginModule:V';

UPDATE ld_usereportcolumns SET realencolumns='ld_singin:record:record:OftenUseReport_Customer Name:V'
WHERE `columns`='ld_singin:entityname:entityname:OftenUseReport_拜访对象:V' AND realencolumns='ld_singin:record:record:OftenUseReport_SinginModuleName:V';


SET @usereportid=(SELECT usereportid FROM ld_usereport WHERE `name`='CashBillSum_Paymentplan');
UPDATE ld_usereportcolumns SET realencolumns='ld_salesorder:salesorder_no:salesorder_no:SalesOrder_SourceOrder No:V'
WHERE `columns`='ld_salesorder:salesorder_no:salesorder_no:SalesOrder_salesorder_no:V' AND Usereportid=@usereportid;


SET @usereportid=(SELECT usereportid FROM ld_usereport WHERE `name`='Performancestatisticscollection');
UPDATE ld_usereportcolumns SET realencolumns='ld_cashbill:groupname:groupname:OftenUseReport_Department:V'
WHERE `columns`='ld_cashbill:groupname:groupname:OftenUseReport_groupname:V' AND Usereportid=@usereportid;

UPDATE ld_usereportcolumns SET realencolumns='ld_account:accountname:accountname:Accounts_Customer Name:V'
WHERE `columns`='ld_account:accountname:accountname:Accounts_accountname:V' AND Usereportid=@usereportid;

UPDATE ld_usereportcolumns SET realencolumns='ld_cashbill:pamount:pamount:OftenUseReport_Latest Received Amount:N'
WHERE `columns`='ld_cashbill:pamount:pamount:OftenUseReport_pamount:N' AND Usereportid=@usereportid;

UPDATE ld_usereportcolumns SET realencolumns='ld_inventoryproductrel:costprice:costprice:Products_Product Cost:N'
WHERE `columns`='ld_inventoryproductrel:costprice:costprice:Products_costprice:N' AND Usereportid=@usereportid;

UPDATE ld_usereportcolumns SET realencolumns='ld_cashbill:Atotal:Atotal:OftenUseReport_Total Received Amount:N'
WHERE `columns`='ld_cashbill:Atotal:Atotal:OftenUseReport_Atotal:N' AND Usereportid=@usereportid;

UPDATE ld_usereportcolumns SET realencolumns='ld_salesordercost:productgp:productgp:OftenUseReport_Gross Profit:N'
WHERE `columns`='ld_salesordercost:productgp:productgp:OftenUseReport_productgp:N' AND Usereportid=@usereportid;

UPDATE ld_usereportcolumns SET realencolumns='ld_salesordercost:productgp:productgp:OftenUseReport_Gross Profit:N'
WHERE `columns`='ld_salesordercost:productgp:productgp:OftenUseReport_productgp:N' AND Usereportid=@usereportid;

UPDATE ld_usereportcolumns SET realencolumns='ld_salesorder:GrossProfitl:毛利率:OftenUseReport_Gross Profit Rate:N'
WHERE `columns`='ld_salesorder:GrossProfitl:毛利率:OftenUseReport_GrossProfitl:N' AND Usereportid=3;

UPDATE ld_desk SET fieldlabel='Whether to allow editing the order after approving' WHERE labelbol='APPROVEFINISHEDALLOWEDIT' AND languagetype='en';

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','BaiFang_DuiXiang','Customer Name','fixedstr' from dual 
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='BaiFang_DuiXiang' and labeltype='fixedstr');

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','BaiFang_DuiXiang','拜访对象','fixedstr' from dual 
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='BaiFang_DuiXiang' and labeltype='fixedstr');
delimiter;

SET @usereportid=(SELECT usereportid FROM ld_usereport WHERE `name`='PurchaseOrderTrack');
UPDATE ld_usereportcolumns SET realencolumns='ld_SendCashBill:SendCashBillamount:SendCashBillamount:OftenUseReport_Amount Paid:N'
WHERE `columns`='ld_SendCashBill:SendCashBillamount:SendCashBillamount:OftenUseReport_SendCashBillamount:N' AND Usereportid=@usereportid;

UPDATE ld_usereportcolumns SET realencolumns='ld_SendCashBill:SendCashBillbalance:SendCashBillbalance:OftenUseReport_Amount Payable:N'
WHERE `columns`='ld_SendCashBill:SendCashBillbalance:SendCashBillbalance:OftenUseReport_SendCashBillbalance:N' AND Usereportid=@usereportid;

UPDATE ld_usereportcolumns SET realencolumns='ld_vendor:vendorname:vendorname:Vendors_Supplier Name:V'
WHERE `columns`='ld_vendor:vendorname:vendorname:Vendors_vendorname:V' AND Usereportid=@usereportid;
delimiter;

SET @usereportid=(SELECT usereportid FROM ld_usereport WHERE `name`='SalesSumSequence');
UPDATE ld_usereportcolumns SET realencolumns='ld_troubletickets:helpdeskcount:helpdeskcount:OftenUseReport_New Service Tickets:N'
WHERE `columns`='ld_troubletickets:helpdeskcount:helpdeskcount:OftenUseReport_helpdeskcount:N' AND Usereportid=@usereportid;
delimiter;


SET @usereportid=(SELECT usereportid FROM ld_usereport WHERE `name`='Thestatisticalreportofprojectperformance');
UPDATE ld_usereportcolumns SET realencolumns='ld_project:lastname:lastname:OftenUseReport_Project Leader:V'
WHERE `columns`='ld_project:lastname:lastname:OftenUseReport_lastname:V' AND Usereportid=@usereportid;

UPDATE ld_usereportcolumns SET realencolumns='ld_account:last_name:last_name:Accounts_Head of Sales:V'
WHERE `columns`='ld_account:last_name:last_name:Accounts_last_name:V' AND Usereportid=@usereportid;

UPDATE ld_usereportcolumns SET realencolumns='ld_project:progress:progress:Project_Progress:V'
WHERE `columns`='ld_project:progress:progress:Project_progress:V' AND Usereportid=@usereportid;

UPDATE ld_usereportcolumns SET realencolumns='ld_project:targetenddate:targetenddate:Project_Estimated Completion Date:D'
WHERE `columns`='ld_project:targetenddate:targetenddate:Project_targetenddate:D' AND Usereportid=@usereportid;

UPDATE ld_usereportcolumns SET realencolumns='ld_project:actualenddate:actualenddate:Project_Actual Finishing Date:D'
WHERE `columns`='ld_project:actualenddate:actualenddate:Project_actualenddate:D' AND Usereportid=@usereportid;

UPDATE ld_usereportcolumns SET realencolumns='ld_cashbill:CashBillamount:CashBillamount:CashBill_Amount Received:NN'
WHERE `columns`='ld_cashbill:CashBillamount:CashBillamount:CashBill_CashBillamount:NN' AND Usereportid=@usereportid;

UPDATE ld_usereportcolumns SET realencolumns='ld_cashbill:PaymentBalance:PaymentBalance:oftenusereport_Amount Receivable:NN'
WHERE `columns`='ld_cashbill:PaymentBalance:PaymentBalance:oftenusereport_PaymentBalance:NN' AND Usereportid=@usereportid;

UPDATE ld_usereportcolumns SET realencolumns='ld_project:groupname:groupname:OftenUseReport_Department:V'
WHERE `columns`='ld_project:groupname:groupname:OftenUseReport_groupname:V' AND Usereportid=@usereportid;
delimiter;

UPDATE ld_desk SET fieldlabel='{$ServiceReturn.ServiceReturn} sheet which is only for {$HelpDesk.HelpDesk} or {$ProjectTask.ProjectTask} is not allowed to be created directly;' WHERE labelbol='How_to_create_return1_or' AND languagetype='en';
UPDATE ld_desk SET fieldlabel='{$ServiceReturn.ServiceReturn}是针对{$HelpDesk.HelpDesk}或{$ProjectTask.ProjectTask}的，不允许直接新增；' WHERE labelbol='How_to_create_return1_or' AND languagetype='zh';
UPDATE ld_desk SET fieldlabel='You can only create it by the association through the detailed interface of {$HelpDesk.HelpDesk} or {$ProjectTask.ProjectTask}.' WHERE labelbol='How_to_create_return2_or' AND languagetype='en';
UPDATE ld_desk SET fieldlabel='可通过{$HelpDesk.HelpDesk}或{$ProjectTask.ProjectTask}查看明细界面，关联创建{$ServiceReturn.ServiceReturn}增加。' WHERE labelbol='How_to_create_return2_or' AND languagetype='zh';

UPDATE ld_desk SET fieldlabel='{$SendPayment.SendPayment} which is only for {$PurchaseOrder.PurchaseOrder} or {$PurchaseInvoice.PurchaseInvoice} is not allowed to be created directly;' WHERE labelbol='How_to_send_create_plan1' AND languagetype='en';
UPDATE ld_desk SET fieldlabel='{$SendPayment.SendPayment}是针对{$PurchaseOrder.PurchaseOrder}或{$PurchaseInvoice.PurchaseInvoice}的，不允许直接新增；' WHERE labelbol='How_to_send_create_plan1' AND languagetype='zh';
UPDATE ld_desk SET fieldlabel='The interface of creating {$SendPayment.SendPayment} can automatically pop up after adding new {$PurchaseOrder.PurchaseOrder} or {$PurchaseInvoice.PurchaseInvoice} through system parameter control;' WHERE labelbol='How_to_send_create_plan2' AND languagetype='en';
UPDATE ld_desk SET fieldlabel='可通过系统参数控制，新增{$PurchaseOrder.PurchaseOrder}或{$PurchaseInvoice.PurchaseInvoice}后自动弹出{$SendPayment.SendPayment}新增界面；' WHERE labelbol='How_to_send_create_plan2' AND languagetype='zh';
UPDATE ld_desk SET fieldlabel='You can also create it through the detailed interface of {$PurchaseOrder.PurchaseOrder} or {$PurchaseInvoice.PurchaseInvoice}.' WHERE labelbol='How_to_send_create_plan3' AND languagetype='en';
UPDATE ld_desk SET fieldlabel='也可以通过{$PurchaseOrder.PurchaseOrder}或{$PurchaseInvoice.PurchaseInvoice}查看明细界面更多->创建{$SendPayment.SendPayment}增加。' WHERE labelbol='How_to_send_create_plan3' AND languagetype='zh';


UPDATE ld_desk SET fieldlabel='{$PaymentPlan.PaymentPlan} which is only for {$SalesOrder.SalesOrder}, {$ServiceContracts.ServiceContracts} or {$Invoice.Invoice} is not allowed to be created directly;' WHERE labelbol='How_to_create_plan1' AND languagetype='en';
UPDATE ld_desk SET fieldlabel='{$PaymentPlan.PaymentPlan}是针对{$SalesOrder.SalesOrder}、{$ServiceContracts.ServiceContracts}或{$Invoice.Invoice}的，不允许直接新增；' WHERE labelbol='How_to_create_plan1' AND languagetype='zh';
UPDATE ld_desk SET fieldlabel='The interface of creating {$PaymentPlan.PaymentPlan} can automatically pop up after adding new {$SalesOrder.SalesOrder}, {$ServiceContracts.ServiceContracts} or {$Invoice.Invoice} through system parameter control;' WHERE labelbol='How_to_create_plan2' AND languagetype='en';
UPDATE ld_desk SET fieldlabel='可通过系统参数控制，新增{$SalesOrder.SalesOrder}、{$ServiceContracts.ServiceContracts}或{$Invoice.Invoice}后自动弹出{$PaymentPlan.PaymentPlan}新增界面；' WHERE labelbol='How_to_create_plan2' AND languagetype='zh';
UPDATE ld_desk SET fieldlabel='You can also create it through the detailed interface of {$SalesOrder.SalesOrder}, {$ServiceContracts.ServiceContracts} or {$Invoice.Invoice}.' WHERE labelbol='How_to_create_plan3' AND languagetype='en';
UPDATE ld_desk SET fieldlabel='也可以通过{$SalesOrder.SalesOrder}、{$ServiceContracts.ServiceContracts}或{$Invoice.Invoice}的查看明细界面更多->创建{$SendPayment.SendPayment}增加。' WHERE labelbol='How_to_create_plan3' AND languagetype='zh';

UPDATE ld_desk SET fieldlabel='{$PurchaseBack.PurchaseBack} Sheet which is only for {$PurchaseOrder.PurchaseOrder} is not allowed to be created directly;' WHERE labelbol='RETURNPURCHASE1' AND languagetype='en';
UPDATE ld_desk SET fieldlabel='{$PurchaseBack.PurchaseBack}是针对{$PurchaseOrder.PurchaseOrder}的，不允许直接新增；' WHERE labelbol='RETURNPURCHASE1' AND languagetype='zh';

UPDATE ld_desk SET fieldlabel='You can choose the order that needs to be returned in the {$PurchaseOrder.PurchaseOrder} list first and click the button "New" besides "{$PurchaseBack.PurchaseBack}" through the relevant information which is on the left side of the detailed interface of the order.' WHERE labelbol='RETURNPURCHASE2' AND languagetype='en';
UPDATE ld_desk SET fieldlabel='在{$PurchaseOrder.PurchaseOrder}序时簿先找到需要退货的订单，在订单查看界面单击左侧相关信息“{$PurchaseBack.PurchaseBack}”操作按钮“新建”即可；' WHERE labelbol='RETURNPURCHASE2' AND languagetype='zh';

UPDATE ld_desk SET fieldlabel='Attention: Only the storaged orders can be returned.' WHERE labelbol='RETURNPURCHASE3' AND languagetype='en';
UPDATE ld_desk SET fieldlabel='只有已经入库的订单允许办理退货。' WHERE labelbol='RETURNPURCHASE3' AND languagetype='zh';

UPDATE ld_desk SET fieldlabel='Before sending a mass email, please set up the mail server in the System Setting first.' WHERE labelbol='Before_sending_please_go_to_SMTP' AND languagetype='en';
UPDATE ld_desk SET fieldlabel='The standard format for the receivers should be :' WHERE labelbol='Email_standard_format_recipient' AND languagetype='en';
UPDATE ld_desk SET fieldlabel='接收人Email标准格式为：' WHERE labelbol='Email_standard_format_recipient' AND languagetype='zh';

UPDATE ld_desk SET fieldlabel='If there is no group that you need, you can create a new group on your own.' WHERE labelbol='If_no_packet_you_need' AND languagetype='en';
UPDATE ld_desk SET fieldlabel='The email addresses should be separated by line feeds, such as :' WHERE labelbol='Bulk_mail_newline_interval_such_as' AND languagetype='en';
UPDATE ld_desk SET fieldlabel='群发邮件，以换行符间隔，例如：' WHERE labelbol='Bulk_mail_newline_interval_such_as' AND languagetype='zh';

UPDATE ld_desk SET fieldlabel='You can search and add {$Accounts.Accounts}, {$Contacts.Contacts} and {$Users.Users} by clicking the adding button.' WHERE labelbol='Select_Add_you_can_find_add_customers' AND languagetype='en';
UPDATE ld_desk SET fieldlabel='选择添加，可以查找添加{$Accounts.Accounts}、{$Contacts.Contacts、{$Users.Users}' WHERE labelbol='Select_Add_you_can_find_add_customers' AND languagetype='zh';

UPDATE ld_desk SET fieldlabel='After clicking the ‘Mass send’ button, the email will be sent one by one.' WHERE labelbol='click_group_button' AND languagetype='en';
UPDATE ld_desk SET fieldlabel='Before sending a mass email, please send one to yourself for testing first.' WHERE labelbol='send_yourself_test' AND languagetype='en';


SET @fieldid=(SELECT fieldid FROM ld_field WHERE tabid=29 AND columnname='helpdesk_log');
UPDATE ld_tranlabel SET fieldlabel='Display the history of the accounts trouble tickets' WHERE trantable='ld_field' AND tabid=29 AND Relateid=@fieldid AND languagetype='en';

UPDATE ld_desk SET fieldlabel='Whether to display the history of the {$HelpDesk.HelpDesk} on the detailed interface of {$HelpDesk.HelpDesk}' WHERE labelbol='helpdesk_log' AND languagetype='en';
delimiter;
UPDATE ld_desk SET fieldlabel='Restore' WHERE labelbol='REDUCTION' AND languagetype='en';


SET @fieldid=(SELECT fieldid FROM ld_field WHERE tabid=29 AND columnname='accountallview');
UPDATE ld_tranlabel SET fieldlabel='Search all relevant data through the relevant information list' WHERE trantable='ld_field' AND tabid=29 AND Relateid=@fieldid AND languagetype='en';
UPDATE ld_tranlabel SET fieldlabel='单据相关信息查询所有关联数据' WHERE trantable='ld_field' AND tabid=29 AND Relateid=@fieldid AND languagetype='zh';

UPDATE ld_desk SET fieldlabel='Whether the relevant information list of bills allows the user to search all relevant data' WHERE labelbol='accountallview' AND languagetype='en';
delimiter;


SET @fieldid=(SELECT fieldid FROM ld_field WHERE tabid=29 AND columnname='select_due_date');
UPDATE ld_tranlabel SET fieldlabel='Display the due date' WHERE trantable='ld_field' AND tabid=29 AND Relateid=@fieldid AND languagetype='en';

UPDATE ld_desk SET fieldlabel='Whether to display the due date on the detailed interface of {$Accounts.Accounts} and {$HelpDesk.HelpDesk}' WHERE labelbol='select_due_date' AND languagetype='en';
delimiter;


UPDATE ld_desk SET fieldlabel='Whether to display {$ServiceContracts.ServiceContracts} information on the detailed interface of {$Accounts.Accounts} and {$HelpDesk.HelpDesk}' WHERE labelbol='select_servicedetail' AND languagetype='en';

SET @fieldid=(SELECT fieldid FROM ld_field WHERE tabid=29 AND columnname='is_mobile_style');
UPDATE ld_tranlabel SET fieldlabel='Control the displayed style of mobile phone' WHERE trantable='ld_field' AND tabid=29 AND Relateid=@fieldid AND languagetype='en';

UPDATE ld_desk SET fieldlabel='Whether the displayed style of the mobile phone number is controlled according to the system parameter ‘Set the style of the mobile phone field that display in the system (whether part of the content is hidden)' WHERE labelbol='is_mobile_style' AND languagetype='en';
delimiter;

SET @fieldid=(SELECT fieldid FROM ld_field WHERE tabid=29 AND columnname='campaignsview');
UPDATE ld_tranlabel SET fieldlabel='Search all relevant data through the relevant information of marketing activities' WHERE trantable='ld_field' AND tabid=29 AND Relateid=@fieldid AND languagetype='en';
delimiter;

UPDATE ld_desk SET fieldlabel='Default values when submitted for approval' WHERE labelbol='APPROVEDEFAULTVALUEONSUBMIT' AND languagetype='en';

SET @relateid=(SELECT tabid FROM ld_tab WHERE `name`='OutboundOrder');
UPDATE ld_tranlabel SET fieldlabel='Outbound Order' WHERE trantable='ld_tab' AND tabid=@relateid AND Relateid=@relateid AND languagetype='en' AND fieldlabel='Out Store';

SET @relateid=(SELECT tabid FROM ld_tab WHERE `name`='Stock');
UPDATE ld_tranlabel SET fieldlabel='Warehousing Entry' WHERE trantable='ld_tab' AND tabid=@relateid AND Relateid=@relateid AND languagetype='en' AND fieldlabel='In Store';
delimiter;


SET @relateid=(SELECT tabid FROM ld_tab WHERE `name`='SendPayment');
UPDATE ld_tranlabel SET fieldlabel='Payment Plan' WHERE trantable='ld_tab' AND tabid=@relateid AND Relateid=@relateid AND languagetype='en' AND fieldlabel='Collection Plan';

SET @relateid=(SELECT tabid FROM ld_tab WHERE `name`='PaymentPlan');
UPDATE ld_tranlabel SET fieldlabel='Receivables Plan' WHERE trantable='ld_tab' AND tabid=@relateid AND Relateid=@relateid AND languagetype='en' AND fieldlabel='Payment Plan';
delimiter;

UPDATE ld_desk SET fieldlabel='Whether to activate' WHERE labelbol='WHETHERTOENABLE' AND languagetype='en';
UPDATE ld_desk SET fieldlabel='Whether to display field name' WHERE labelbol='MOBILELISTSHOWFIELDNAME' AND languagetype='en';

UPDATE ld_desk SET fieldlabel='The backup file is stored in a fixed path of the server. After the backup, the backup file can be replaced or downloaded to the local by <b>downloading the backup file</b> button. The backup results are database script files (not including attached files and pictures).'
WHERE labelbol='NEWMANUALBACKUPMESSAGE' AND languagetype='en';

SET @relateid=(SELECT tabid FROM ld_tab WHERE `name`='Vendors');
UPDATE ld_tranlabel SET fieldlabel='Supplier' WHERE trantable='ld_tab' AND tabid=@relateid AND Relateid=@relateid AND languagetype='en' AND fieldlabel='Vendors';

SET @relateid=(SELECT tabid FROM ld_tab WHERE `name`='VendorContact');
UPDATE ld_tranlabel SET fieldlabel='Supplier Contact' WHERE trantable='ld_tab' AND tabid=@relateid AND Relateid=@relateid AND languagetype='en' AND fieldlabel='Vendor Contacts';

SET @relateid=(SELECT tabid FROM ld_tab WHERE `name`='VendorContactRecords');
UPDATE ld_tranlabel SET fieldlabel='Supplier Contact Records' WHERE trantable='ld_tab' AND tabid=@relateid AND Relateid=@relateid AND languagetype='en' AND fieldlabel='Vendor records';
delimiter;
-- 2019-07-30

UPDATE ld_desk SET fieldlabel='After execution, the order will be restored to ‘Undelivered’ status, and the inventory will return to the original condition. Are you sure you want to do this?' WHERE labelbol='AFTEREXCYTIONTHESTATUSWILLBERESTOREDOUT' AND languagetype='en';

UPDATE ld_desk SET fieldlabel='The current order status is "Undelivered"' WHERE labelbol='PURCHASEENDRETURN2' AND languagetype='en';
UPDATE ld_desk SET fieldlabel='The current order status is "delivered"' WHERE labelbol='PURCHASEENDRETURN1' AND languagetype='en';

UPDATE ld_desk SET fieldlabel='After the execution, returns a single status is set to "abort" (can be considered void, without changing inventory)' WHERE labelbol='ATERASSISTACBCVWCI' AND languagetype='en';
UPDATE ld_desk SET fieldlabel='After the execution,the return of single state is set to "end"' WHERE labelbol='ATERASSISTE' AND languagetype='en';

UPDATE ld_desk SET fieldlabel='After returning the goods, editing and deleting the return order are not allowed.' WHERE labelbol='ATRINATRASEAD' AND languagetype='en';

UPDATE ld_desk SET fieldlabel='Please check the document information carefully. Do you confirm the return delivery?' WHERE labelbol='RETURNOPERATIONREVERSIBLEPURCHASE' AND languagetype='en';

UPDATE ld_desk SET fieldlabel='Add new selected members on the basis of existed sharers' WHERE labelbol='SHARETYPEADD' AND languagetype='en';
UPDATE ld_desk SET fieldlabel='Replace the existed sharers with the new selected members' WHERE labelbol='SHARETYPEREPLACE' AND languagetype='en';
UPDATE ld_desk SET fieldlabel='Remove the selected members from existed sharers' WHERE labelbol='SHARETYPECANCEL' AND languagetype='en';

UPDATE ld_desk SET fieldlabel="Please enter the customer's business name!" WHERE labelbol='pleaseenterthename' AND languagetype='en';

UPDATE ld_desk SET fieldlabel=REPLACE(fieldlabel,"’","'") WHERE fieldlabel LIKE '%’%';
UPDATE ld_tranlabel SET fieldlabel=REPLACE(fieldlabel,"’","'") WHERE fieldlabel LIKE '%’%';

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','ExportFileFormat','File Format','fixedstr' from dual 
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='ExportFileFormat' and labeltype='fixedstr');

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','ExportFileFormat','文件格式','fixedstr' from dual 
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='ExportFileFormat' and labeltype='fixedstr');
delimiter;

UPDATE ld_desk SET fieldlabel='Export data' WHERE labelbol='EXPORTDATATITLE' AND languagetype='en';

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','ExportFileFormatExcel','Excel File (Less than 2000 records)','fixedstr' from dual 
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='ExportFileFormatExcel' and labeltype='fixedstr');

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','ExportFileFormatExcel','Excel文件（2000条数据以内）','fixedstr' from dual 
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='ExportFileFormatExcel' and labeltype='fixedstr');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','ExportFileFormatCSV','CSV File (More than 2000 records)','fixedstr' from dual 
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='ExportFileFormatCSV' and labeltype='fixedstr');

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','ExportFileFormatCSV','CSV文件（超过2000条数据）','fixedstr' from dual 
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='ExportFileFormatCSV' and labeltype='fixedstr');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','ExportSuccessful','Export Successful','fixedstr' from dual 
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='ExportSuccessful' and labeltype='fixedstr');

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','ExportSuccessful','导出成功','fixedstr' from dual 
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='ExportSuccessful' and labeltype='fixedstr');
delimiter;

UPDATE ld_desk SET fieldlabel='Download the CSV file' WHERE labelbol='DOWNLOADCSV' AND languagetype='en';
UPDATE ld_desk SET fieldlabel='Download the Excel file' WHERE labelbol='DOWNLOADXLS' AND languagetype='en';

UPDATE ld_desk SET fieldlabel='You have selected $##$ records, you can only merge 10 records maximum, so please re-select the records that you need to merge!' WHERE labelbol='MASSELECTTEN' AND languagetype='en';

SET @fieldid=(SELECT fieldid FROM ld_field WHERE tabid=2 AND columnname='callhigh');
UPDATE ld_tranlabel SET fieldlabel='Visit Senior Leaders' WHERE trantable='ld_field' AND tabid=2 AND Relateid=@fieldid AND languagetype='en' AND fieldlabel='CallHigh';
delimiter;


UPDATE ld_tranlabel SET fieldlabel="Whether to compress the picture when uploading it for the web page"
WHERE Relateid=165 AND trantable='ld_systems_deploy' AND languagetype='en';

UPDATE ld_tranlabel SET fieldlabel="Whether to allow the user to choose picture from photo album for the field attendance from mobile"
WHERE Relateid=114 AND trantable='ld_systems_deploy' AND languagetype='en';

UPDATE ld_tranlabel SET fieldlabel="Whether the customer is a required field for the field attendance from mobile"
WHERE Relateid=143 AND trantable='ld_systems_deploy' AND languagetype='en';

UPDATE ld_tranlabel SET fieldlabel="Whether the photo is a required field for the field attendance from mobile"
WHERE Relateid=200 AND trantable='ld_systems_deploy' AND languagetype='en';

UPDATE ld_tranlabel SET fieldlabel="Whether to display business query function in the interface of {$Accounts.Accounts}, {$ServiceCharge.ServiceCharge} and {$Vendors.Vendors}"
WHERE Relateid=152 AND trantable='ld_systems_deploy' AND languagetype='en';

UPDATE ld_tranlabel SET fieldlabel="Whether to display the automatically matched business query customers’ list in the interface of {$Accounts.Accounts}, {$ServiceCharge.ServiceCharge} and {$Vendors.Vendors}"
WHERE Relateid=159 AND trantable='ld_systems_deploy' AND languagetype='en';

UPDATE ld_tranlabel SET fieldlabel="{$Accounts.Accounts}, {$ServiceCharge.ServiceCharge} and {$Vendors.Vendors} are not allowed to be saved without business information"
WHERE Relateid=199 AND trantable='ld_systems_deploy' AND languagetype='en';

UPDATE ld_tranlabel SET fieldlabel='Only the approved {$Quotes.Quotes} is allowed to be printed'
WHERE Relateid=153 AND trantable='ld_systems_deploy' AND languagetype='en';

UPDATE ld_tranlabel SET fieldlabel='Only the approved {$SalesOrder.SalesOrder} is allowed to be printed'
WHERE Relateid=154 AND trantable='ld_systems_deploy' AND languagetype='en';

UPDATE ld_tranlabel SET fieldlabel='Only the approved {$ServiceContracts.ServiceContracts} is allowed to be printed'
WHERE Relateid=155 AND trantable='ld_systems_deploy' AND languagetype='en';

UPDATE ld_tranlabel SET fieldlabel='Only the approved {$PurchaseOrder.PurchaseOrder} is allowed to be printed'
WHERE Relateid=156 AND trantable='ld_systems_deploy' AND languagetype='en';

UPDATE ld_tranlabel SET fieldlabel='Only the approved {$OutboundOrder.OutboundOrder} is allowed to be printed'
WHERE Relateid=157 AND trantable='ld_systems_deploy' AND languagetype='en';

UPDATE ld_tranlabel SET fieldlabel='Whether to print the {$SalesOrder.SalesOrder} immediately after creating or editing it'
WHERE Relateid=57 AND trantable='ld_systems_deploy' AND languagetype='en';


UPDATE ld_tranlabel SET fieldlabel='Whether the unstocked {$PurchaseOrder.PurchaseOrder} is allowed to be returned'
WHERE Relateid=132 AND trantable='ld_systems_deploy' AND languagetype='en';

UPDATE ld_tranlabel SET fieldlabel='Whether the unstocked {$SalesOrder.SalesOrder} is allowed to be returned'
WHERE Relateid=85 AND trantable='ld_systems_deploy' AND languagetype='en';

UPDATE ld_systems_deploy SET inputvalue='[{"value":"0","text":"YES"},{"value":"1","text":"NO"},{"sql":""}]' WHERE deploy_type=10;

UPDATE ld_tranlabel SET fieldlabel='Whether the {$OutboundOrder.OutboundOrder} and the {$Stock.Stock} must be strictly according to the original order (The cumulative quantity of each product is not allowed to exceed the quantity of the order and foreign products are not allowed to appear)'
WHERE Relateid=10 AND trantable='ld_systems_deploy' AND languagetype='en';

UPDATE ld_tranlabel SET fieldlabel='设置{$OutboundOrder.OutboundOrder}和{$Stock.Stock}必须严格参照源单（每种产品累计数量不允许超出源单或者出现源单外的产品）'
WHERE Relateid=10 AND trantable='ld_systems_deploy' AND languagetype='zh';

UPDATE ld_tranlabel SET fieldlabel='Whether to allow out of storage when the stock is negative'
WHERE Relateid=141 AND trantable='ld_systems_deploy' AND languagetype='en';

UPDATE ld_tranlabel SET fieldlabel='Whether to notify the user when the product quantity displayed in the {$SalesOrder.SalesOrder} exceeds the quantity of the security stock'
WHERE Relateid=201 AND trantable='ld_systems_deploy' AND languagetype='en';

UPDATE ld_tranlabel SET fieldlabel='Whether to activate batch management'
WHERE Relateid=196 AND trantable='ld_systems_deploy' AND languagetype='en';

UPDATE ld_tranlabel SET fieldlabel='Set the way to update the inventory quantity of the out and in-stock'
WHERE Relateid=48 AND trantable='ld_systems_deploy' AND languagetype='en';

UPDATE ld_tranlabel SET fieldlabel='设置出库和入库类库单据更新库存数量的触发点'
WHERE Relateid=48 AND trantable='ld_systems_deploy' AND languagetype='zh';

UPDATE ld_tranlabel SET fieldlabel='Whether to show negative stock when the product quantity displayed in the detailed interface of {$SalesOrder.SalesOrder} exceeds the quantity of stock'
WHERE Relateid=142 AND trantable='ld_systems_deploy' AND languagetype='en';


UPDATE ld_tranlabel SET fieldlabel="Whether to send message to remind customers when approving the {$OutboundOrder.OutboundOrder}"
WHERE Relateid=21 AND trantable='ld_systems_deploy' AND languagetype='en';

UPDATE ld_tranlabel SET fieldlabel="Whether to send message or email to the contact when allocating the {$HelpDesk.HelpDesk}"
WHERE Relateid=167 AND trantable='ld_systems_deploy' AND languagetype='en';

UPDATE ld_tranlabel SET fieldlabel="Whether to send message to the {$HelpDesk.assigned_user_id} when allocating the {$HelpDesk.HelpDesk}"
WHERE Relateid=115 AND trantable='ld_systems_deploy' AND languagetype='en';

UPDATE ld_tranlabel SET fieldlabel="Choose how many days before the due date of {$SendPayment.SendPayment} to remind the user(0 means on the same day, Null means don't remind)"
WHERE Relateid=41 AND trantable='ld_systems_deploy' AND languagetype='en';

UPDATE ld_tranlabel SET fieldlabel="Choose how many days before the due date of {$PaymentPlan.PaymentPlan} to remind the user(0 means on the same day, Null means don't remind)"
WHERE Relateid=40 AND trantable='ld_systems_deploy' AND languagetype='en';

UPDATE ld_tranlabel SET fieldlabel="Choose how many days before the delivery date of {$SalesOrder.SalesOrder} to remind the user(0 means on the same day, Null means don't remind)"
WHERE Relateid=18 AND trantable='ld_systems_deploy' AND languagetype='en';

UPDATE ld_tranlabel SET fieldlabel='Whether to activate the reminder when {$Accounts.Accounts} repeat'
WHERE Relateid=95 AND trantable='ld_systems_deploy' AND languagetype='en';

UPDATE ld_tranlabel SET fieldlabel='{$Accounts.Accounts}重复时是否启用报备提醒'
WHERE Relateid=95 AND trantable='ld_systems_deploy' AND languagetype='zh';

UPDATE ld_tranlabel SET fieldlabel='Whether to notify the person in charge by email when allocating bills'
WHERE Relateid=145 AND trantable='ld_systems_deploy' AND languagetype='en';

UPDATE ld_tranlabel SET fieldlabel='Whether the unread message will popup to remind the user'
WHERE Relateid=51 AND trantable='ld_systems_deploy' AND languagetype='en';


UPDATE ld_tranlabel SET fieldlabel="Whether to allow the users to select the disabled receipts when entering {$Products.Products} information"
WHERE Relateid=82 AND trantable='ld_systems_deploy' AND languagetype='en';

UPDATE ld_tranlabel SET fieldlabel="Whether only approved bills are allowed to be selected when entering {$Products.Products} information in the entry details of products"
WHERE Relateid=71 AND trantable='ld_systems_deploy' AND languagetype='en';

UPDATE ld_tranlabel SET fieldlabel="Whether to display Primary Contact in the detailed interface of {$Accounts.Accounts}"
WHERE Relateid=72 AND trantable='ld_systems_deploy' AND languagetype='en';

UPDATE ld_tranlabel SET fieldlabel="Whether to allow the users to delete the orders that related to {$Accounts.Accounts} existed"
WHERE Relateid=69 AND trantable='ld_systems_deploy' AND languagetype='en';

UPDATE ld_tranlabel SET fieldlabel="Whether to query all users’ data when setting the related {$Accounts.Accounts}"
WHERE Relateid=74 AND trantable='ld_systems_deploy' AND languagetype='en';

UPDATE ld_tranlabel SET fieldlabel="Whether to query all users’ data when setting the related {$Contacts.Contacts}"
WHERE Relateid=108 AND trantable='ld_systems_deploy' AND languagetype='en';

UPDATE ld_tranlabel SET fieldlabel="Whether to query all users’ data when setting the related {$Vendors.Vendors}"
WHERE Relateid=109 AND trantable='ld_systems_deploy' AND languagetype='en';

UPDATE ld_tranlabel SET fieldlabel="Whether to query all users’ data when setting the related {$VendorContact.VendorContact}"
WHERE Relateid=139 AND trantable='ld_systems_deploy' AND languagetype='en';

UPDATE ld_tranlabel SET fieldlabel="Whether to query all users’ data when setting the related {$Potentials.Potentials}"
WHERE Relateid=138 AND trantable='ld_systems_deploy' AND languagetype='en';

UPDATE ld_tranlabel SET fieldlabel="Whether to query all users’ data when setting the related {$Project.Project}(including Selecting Source Order)"
WHERE Relateid=119 AND trantable='ld_systems_deploy' AND languagetype='en';

UPDATE ld_tranlabel SET fieldlabel="Whether to query all users’ data when setting the related {$SalesOrder.SalesOrder}(including Selecting Source Order)"
WHERE Relateid=116 AND trantable='ld_systems_deploy' AND languagetype='en';

UPDATE ld_tranlabel SET fieldlabel="Whether to query all users’ data when setting the related {$ServiceContracts.ServiceContracts}(including Selecting Source Order)"
WHERE Relateid=117 AND trantable='ld_systems_deploy' AND languagetype='en';

UPDATE ld_tranlabel SET fieldlabel="Whether to query all users’ data when setting the related {$PurchaseOrder.PurchaseOrder}(including Selecting Source Order)"
WHERE Relateid=118 AND trantable='ld_systems_deploy' AND languagetype='en';


UPDATE ld_tranlabel SET fieldlabel="Whether to create receivables forecast immediately after creating {$Potentials.Potentials}"
WHERE Relateid=54 AND trantable='ld_systems_deploy' AND languagetype='en';

UPDATE ld_tranlabel SET fieldlabel="After creating {$SalesOrder.SalesOrder}, whether to update the {$Accounts.rating} of {$Accounts.Accounts} as (empty means no update):"
WHERE Relateid=37 AND trantable='ld_systems_deploy' AND languagetype='en';

UPDATE ld_tranlabel SET fieldlabel="After creating {$SalesOrder.SalesOrder}, whether to update the {$Potentials.sales_stage} of {$Potentials.Potentials} as (empty means no update):"
WHERE Relateid=38 AND trantable='ld_systems_deploy' AND languagetype='en';

UPDATE ld_tranlabel SET fieldlabel="After creating {$ServiceContracts.ServiceContracts}, whether to update the {$Accounts.rating} of {$Accounts.Accounts} as (empty means no update):"
WHERE Relateid=161 AND trantable='ld_systems_deploy' AND languagetype='en';

UPDATE ld_tranlabel SET fieldlabel="Whether to create {$PaymentPlan.PaymentPlan} immediately after creating {$SalesOrder.SalesOrder}"
WHERE Relateid=12 AND trantable='ld_systems_deploy' AND languagetype='en';

UPDATE ld_tranlabel SET fieldlabel="Whether to create {$ServiceContracts.ServiceContracts} (free of service charge for 1 year) immediately after creating {$SalesOrder.SalesOrder}"
WHERE Relateid=130 AND trantable='ld_systems_deploy' AND languagetype='en';

UPDATE ld_tranlabel SET fieldlabel="Whether to control the total amount of {$PaymentPlan.PaymentPlan} equivalent to the amount of {$SalesOrder.SalesOrder} when creating the {$PaymentPlan.PaymentPlan} related to the {$SalesOrder.SalesOrder}"
WHERE Relateid=1 AND trantable='ld_systems_deploy' AND languagetype='en';

UPDATE ld_tranlabel SET fieldlabel="Whether to create {$CashBill.CashBill} immediately after creating {$SalesOrder.SalesOrder}"
WHERE Relateid=162 AND trantable='ld_systems_deploy' AND languagetype='en';

UPDATE ld_tranlabel SET fieldlabel="After creating {$SalesOrder.SalesOrder}, whether to create the {$OutboundOrder.OutboundOrder} automatically, the related warehouse is"
WHERE Relateid=56 AND trantable='ld_systems_deploy' AND languagetype='en';

UPDATE ld_tranlabel SET fieldlabel="After editing {$SalesOrder.SalesOrder}, whether to create the {$OutboundOrder.OutboundOrder} automatically, the related warehouse is"
WHERE Relateid=63 AND trantable='ld_systems_deploy' AND languagetype='en';

UPDATE ld_tranlabel SET fieldlabel="Whether to display products automatically after creating {$ServiceContracts.ServiceContracts} related to {$SalesOrder.SalesOrder}"
WHERE Relateid=164 AND trantable='ld_systems_deploy' AND languagetype='en';

UPDATE ld_tranlabel SET fieldlabel="After creating {$ServiceContracts.ServiceContracts}, whether to update the {$Accounts.rating} of {$Accounts.Accounts} as (empty means no update):"
WHERE Relateid=161 AND trantable='ld_systems_deploy' AND languagetype='en';

UPDATE ld_tranlabel SET fieldlabel="Whether to create {$PaymentPlan.PaymentPlan} immediately after creating {$ServiceContracts.ServiceContracts}"
WHERE Relateid=58 AND trantable='ld_systems_deploy' AND languagetype='en';

UPDATE ld_tranlabel SET fieldlabel="Whether to control the total amount of {$PaymentPlan.PaymentPlan} equivalent to the amount of {$ServiceContracts.ServiceContracts} when creating the {$PaymentPlan.PaymentPlan} related to the {$ServiceContracts.ServiceContracts}"
WHERE Relateid=59 AND trantable='ld_systems_deploy' AND languagetype='en';

UPDATE ld_tranlabel SET fieldlabel="Whether to create {$CashBill.CashBill} immediately after creating {$ServiceContracts.ServiceContracts}"
WHERE Relateid=163 AND trantable='ld_systems_deploy' AND languagetype='en';

UPDATE ld_tranlabel SET fieldlabel="Whether to create {$PaymentPlan.PaymentPlan} immediately after creating {$Invoice.Invoice}"
WHERE Relateid=146 AND trantable='ld_systems_deploy' AND languagetype='en';

UPDATE ld_tranlabel SET fieldlabel="Whether to control the total amount of {$PaymentPlan.PaymentPlan} equivalent to the amount of {$Invoice.Invoice} when creating the {$PaymentPlan.PaymentPlan} related to the {$Invoice.Invoice}"
WHERE Relateid=147 AND trantable='ld_systems_deploy' AND languagetype='en';

UPDATE ld_tranlabel SET fieldlabel="Whether to control the total amount of {$SendPayment.SendPayment} equivalent to the amount of {$PurchaseInvoice.PurchaseInvoice} when creating the {$SendPayment.SendPayment} related to the {$PurchaseInvoice.PurchaseInvoice}"
WHERE Relateid=149 AND trantable='ld_systems_deploy' AND languagetype='en';

UPDATE ld_tranlabel SET fieldlabel="Whether to control the total amount of {$SendPayment.SendPayment} equivalent to the amount of {$PurchaseOrder.PurchaseOrder} when creating the {$SendPayment.SendPayment} related to the {$PurchaseOrder.PurchaseOrder}"
WHERE Relateid=20 AND trantable='ld_systems_deploy' AND languagetype='en';

UPDATE ld_tranlabel SET fieldlabel="Whether to create  {$SendPayment.SendPayment} immediately after creating {$PurchaseOrder.PurchaseOrder}"
WHERE Relateid=15 AND trantable='ld_systems_deploy' AND languagetype='en';

UPDATE ld_tranlabel SET fieldlabel="Whether to create  {$SendPayment.SendPayment} immediately after creating {$PurchaseInvoice.PurchaseInvoice}"
WHERE Relateid=148 AND trantable='ld_systems_deploy' AND languagetype='en';
-- 2019-07-31

insert into ld_desk(languagetype,fieldlabel,labelbol,labeltype)
select 'zh','改单据审批步骤已变化，请重新加载改单据！','Approvestephavechangetip' ,'fixedstr' from dual 
where not exists(select 1 from ld_desk where labelbol='Approvestephavechangetip' and languagetype='zh' and labeltype='fixedstr' );

insert into ld_desk(languagetype,fieldlabel,labelbol,labeltype)
select 'en','The status of this record has been changed,please reload this record','Approvestephavechangetip' ,'fixedstr' from dual 
where not exists(select 1 from ld_desk where labelbol='Approvestephavechangetip' and languagetype='en' and labeltype='fixedstr' );
delimiter;

DROP PROCEDURE IF EXISTS `ldcrm_delete_related_field_by_module`;
delimiter ||
CREATE  PROCEDURE `ldcrm_delete_related_field_by_module`(
	tmp_modulename VARCHAR(100)
)
BEGIN

	DELETE FROM ld_related_field WHERE effect_fieldid IN (
		SELECT
			a.fieldid
		FROM ld_field a
		LEFT JOIN ld_tab b ON b.tabid=a.tabid
		LEFT JOIN ld_tranlabel c ON c.trantable='ld_tab' AND c.languagetype='zh' AND c.Relateid=b.tabid
		WHERE a.columnname='smownerid'
			AND (b.`name`=tmp_modulename OR c.fieldlabel=tmp_modulename)
	);
	
END ||
delimiter;

call addcolumn('ld_communicationaccount','service_tel','varchar',255,null);
delimiter;

insert into ld_desk(languagetype,fieldlabel,labelbol,labeltype)
select 'zh','该单据审批状态已变化，请重新加载该单据','Approvestephavechangetip' ,'fixedstr' from dual 
where not exists(select 1 from ld_desk where labelbol='Approvestephavechangetip' and languagetype='zh' and labeltype='fixedstr' );

insert into ld_desk(languagetype,fieldlabel,labelbol,labeltype)
select 'en','The status of this record has been changed,please reload this record','Approvestephavechangetip' ,'fixedstr' from dual 
where not exists(select 1 from ld_desk where labelbol='Approvestephavechangetip' and languagetype='en' and labeltype='fixedstr' );
delimiter;

call addcolumn('ld_approve','default_on_new','varchar',255,null);
alter table `ld_approve` alter column `default_on_new` drop default;
alter table `ld_approve` alter column `default_on_new` set default 'no';
call addcolumn('ld_approve','default_on_submit','varchar',255,null);
alter table `ld_approve` alter column `default_on_submit` drop default;
alter table `ld_approve` alter column `default_on_submit` set default 'no';
update ld_approve set default_on_new='no' where default_on_new <> 'yes';
update ld_approve set default_on_submit='no' where default_on_new <> 'yes';
delete from ld_desk where labelbol='APPROVEFINISHEDALLOWEDIT' and languagetype='en';
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
  select 'en','APPROVEFINISHEDALLOWEDIT','Whether editing documents is allowed at the end of approval','fixedstr' from dual where not exists(select 1 from ld_desk  where labelbol='APPROVEFINISHEDALLOWEDIT' and labeltype='fixedstr' and languagetype='en');
insert into ld_desk (languagetype,labelbol,fieldlabel,labeltype)
  select 'zh','APPROVEDEFAULTVALUEONNEW','是否移动端新建时默认流程','fixedstr' from dual
  where not exists(select * from ld_desk where languagetype='zh' and labelbol='APPROVEDEFAULTVALUEONNEW' and labeltype='fixedstr');
insert into ld_desk (languagetype,labelbol,fieldlabel,labeltype)
  select 'en','APPROVEDEFAULTVALUEONNEW','Default values when new on the mobile','fixedstr' from dual
  where not exists(select * from ld_desk where languagetype='en' and labelbol='APPROVEDEFAULTVALUEONNEW' and labeltype='fixedstr');
insert into ld_desk (languagetype,labelbol,fieldlabel,labeltype)
  select 'zh','APPROVEDEFAULTVALUEONSUBMIT','是否提交审批时默认流程','fixedstr' from dual
  where not exists(select * from ld_desk where languagetype='zh' and labelbol='APPROVEDEFAULTVALUEONSUBMIT' and labeltype='fixedstr');
insert into ld_desk (languagetype,labelbol,fieldlabel,labeltype)
  select 'en','APPROVEDEFAULTVALUEONSUBMIT','Default process when submitting for approval','fixedstr' from dual
  where not exists(select * from ld_desk where languagetype='en' and labelbol='APPROVEDEFAULTVALUEONSUBMIT' and labeltype='fixedstr');
delimiter;
-- 2019-08-04


UPDATE ld_systems_deploy SET presence=0,roottype=6,sequence=100,inputtype='text',inputvalue='' WHERE deploy_type=75;
SET @i=0;
UPDATE ld_systems_deploy SET sequence=(@i:=@i+1) WHERE roottype=6 ORDER BY sequence;
delimiter;

SET @relateid=75;
SET @trantable='ld_systems_deploy';
SET @zh='设置图片打印时的尺寸(宽，高)';
SET @en='Set the size (width, height) of the picture when it is printed';
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'zh' ,@trantable,@relateid,@relateid,@zh from dual 
where not exists(select 1 from ld_tranlabel where tabid=@relateid and trantable=@trantable and relateid=@relateid and languagetype='zh');

insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'en' ,@trantable,@relateid,@relateid,@en from dual 
where not exists(select 1 from ld_tranlabel where tabid=@relateid and trantable=@trantable and relateid=@relateid and languagetype='en');
delimiter;

UPDATE ld_workreport
SET sendlog_workdate=(
	CASE
		WHEN type=1 THEN DATE_FORMAT(createdtime,'%Y-%m-%d')
		WHEN type=2 THEN CONCAT(DATE_SUB(DATE_FORMAT(createdtime,'%Y-%m-%d'),INTERVAL DATE_FORMAT(createdtime,'%w')-1 DAY),' ~ ',DATE_SUB(DATE_FORMAT(createdtime,'%Y-%m-%d'),INTERVAL DATE_FORMAT(createdtime,'%w')-7 DAY))
		WHEN type=3 THEN CONCAT(DATE_FORMAT(LAST_DAY(createdtime),'%Y-%m-'),'01',' ~ ',LAST_DAY(createdtime)) 
	END
)
WHERE IFNULL(sendlog_workdate,'')='';


CALL AddColumn('ld_salesorder','kis_no','varchar','255',NULL);
delimiter;
-- 2019-08-05

DROP PROCEDURE IF EXISTS `ldcrm_createtable_productbomdetail`;
delimiter ||
CREATE  PROCEDURE `ldcrm_createtable_productbomdetail`(
)
BEGIN

	IF NOT EXISTS (SELECT 1 FROM information_schema.TABLES WHERE TABLE_NAME='ld_productbomdetail' AND  TABLE_SCHEMA=DATABASE()) THEN
		IF EXISTS (SELECT 1 FROM information_schema.TABLES WHERE TABLE_NAME='ld_salesorderdetail' AND  TABLE_SCHEMA=DATABASE()) THEN
			CREATE TABLE IF NOT EXISTS ld_productbomdetail LIKE ld_salesorderdetail;
			CREATE TABLE IF NOT EXISTS ld_productbomdetailscf LIKE ld_salesorderdetailscf;
		END IF;
	END IF;

end ||
delimiter;

CALL ldcrm_createtable_productbomdetail();
DROP PROCEDURE IF EXISTS `ldcrm_createtable_productbomdetail`;
delimiter;

insert into ld_ws_fieldtype(uitype,fieldtype)
select 137,'reference' from dual 
where not exists(select 1 from ld_ws_fieldtype where uitype='137');
select fieldtypeid into @fieldtypeid from ld_ws_fieldtype where uitype=137;

insert into ld_ws_referencetype(fieldtypeid,type)select @fieldtypeid,'CardApply' from dual 
where not exists(select 1 from ld_ws_referencetype where type='CardApply');
delimiter;

CALL AddColumn('ld_salesorder','kis_no','varchar','255',NULL);
delimiter;

update ld_parenttab set menu_profieldid='';
delimiter;
select tabid into @tabid from ld_tab where name='PurchaseInquiryOrder';
insert into  ld_modtracker_tabs(tabid,visible)select @tabid,1 from dual 
where not EXISTS(select 1 from ld_modtracker_tabs where tabid=@tabid);
delimiter;

SET @block=(SELECT block FROM ld_field WHERE tablename='ld_contactrecords' AND columnname='accountid');
UPDATE ld_field SET presence=0,block=@block WHERE tablename='ld_contactrecords' AND columnname='potentialid' AND presence=1
	AND EXISTS (SELECT 1 FROM ld_tab WHERE tabid=2 AND presence=0)
	AND NOT EXISTS (SELECT 1 FROM ld_contactrecords);
-- 2019-08-08

UPDATE ld_desk SET fieldlabel='System Setting' WHERE labelbol='CONTROLPANEL' AND languagetype='en'; 

insert into ld_desk(languagetype,fieldlabel,labelbol,labeltype)
select 'zh','规则名称','RULENAME','fixedstr' from dual 
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='RULENAME' and labeltype='fixedstr');
delimiter;

insert into ld_desk(languagetype,fieldlabel,labelbol,labeltype)
select 'en','Rule Name','FieldLayout','fixedstr' from dual 
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='RULENAME' and labeltype='fixedstr');
delimiter;

insert into ld_desk(languagetype,fieldlabel,labelbol,labeltype)
select 'zh','字段布局','FieldLayout','fixedstr' from dual 
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='FieldLayout' and labeltype='fixedstr');
delimiter;

insert into ld_desk(languagetype,fieldlabel,labelbol,labeltype)
select 'en','Field Layout','FieldLayout','fixedstr' from dual 
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='FieldLayout' and labeltype='fixedstr');
delimiter;

insert into ld_desk(languagetype,fieldlabel,labelbol,labeltype)
select 'zh','布局规则','LayoutRules','fixedstr' from dual 
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='LayoutRules' and labeltype='fixedstr');
delimiter;

insert into ld_desk(languagetype,fieldlabel,labelbol,labeltype)
select 'en','Layout Rules','LayoutRules','fixedstr' from dual 
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='LayoutRules' and labeltype='fixedstr');
delimiter;

insert into ld_desk(languagetype,fieldlabel,labelbol,labeltype)
select 'zh','布局规则','LayoutRules','fixedstr' from dual 
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='LayoutRules' and labeltype='fixedstr');
delimiter;

insert into ld_desk(languagetype,fieldlabel,labelbol,labeltype)
select 'en','Layout Rules','LayoutRules','fixedstr' from dual 
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='LayoutRules' and labeltype='fixedstr');
delimiter;

insert into ld_desk(languagetype,fieldlabel,labelbol,labeltype)
select 'zh','触发字段','TriggerField','fixedstr' from dual 
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='TriggerField' and labeltype='fixedstr');
delimiter;

insert into ld_desk(languagetype,fieldlabel,labelbol,labeltype)
select 'en','Trigger Field','TriggerField','fixedstr' from dual 
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='TriggerField' and labeltype='fixedstr');
delimiter;

insert into ld_desk(languagetype,fieldlabel,labelbol,labeltype)
select 'zh','新增布局规则','CreateLayoutRules','fixedstr' from dual 
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='CreateLayoutRules' and labeltype='fixedstr');
delimiter;

insert into ld_desk(languagetype,fieldlabel,labelbol,labeltype)
select 'en','Create Layout Rules','CreateLayoutRules','fixedstr' from dual 
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='CreateLayoutRules' and labeltype='fixedstr');
delimiter;

insert into ld_desk(languagetype,fieldlabel,labelbol,labeltype)
select 'zh','触发字段条件','TriggerFieldCondition','fixedstr' from dual 
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='TriggerFieldCondition' and labeltype='fixedstr');
delimiter;

insert into ld_desk(languagetype,fieldlabel,labelbol,labeltype)
select 'en','Trigger field condition','TriggerFieldCondition','fixedstr' from dual 
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='TriggerFieldCondition' and labeltype='fixedstr');
delimiter;

insert into ld_desk(languagetype,fieldlabel,labelbol,labeltype)
select 'zh','其它条件','OtherCondition','fixedstr' from dual 
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='OtherCondition' and labeltype='fixedstr');
delimiter;

insert into ld_desk(languagetype,fieldlabel,labelbol,labeltype)
select 'en','Other conditions','OtherCondition','fixedstr' from dual 
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='OtherCondition' and labeltype='fixedstr');
delimiter;

insert into ld_desk(languagetype,fieldlabel,labelbol,labeltype)
select 'zh','触发操作','Triggeredoperation','fixedstr' from dual 
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='Triggeredoperation' and labeltype='fixedstr');
delimiter;

insert into ld_desk(languagetype,fieldlabel,labelbol,labeltype)
select 'en','Triggered operation','Triggeredoperation','fixedstr' from dual 
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='Triggeredoperation' and labeltype='fixedstr');
delimiter;

insert into ld_desk(languagetype,fieldlabel,labelbol,labeltype)
select 'zh','显示字段','Displayfields','fixedstr' from dual 
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='Displayfields' and labeltype='fixedstr');
delimiter;

insert into ld_desk(languagetype,fieldlabel,labelbol,labeltype)
select 'en','Display fields','Displayfields','fixedstr' from dual 
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='Displayfields' and labeltype='fixedstr');
delimiter;

insert into ld_desk(languagetype,fieldlabel,labelbol,labeltype)
select 'zh','设置必填字段','Setmandatoryfield','fixedstr' from dual 
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='Setmandatoryfield' and labeltype='fixedstr');
delimiter;

insert into ld_desk(languagetype,fieldlabel,labelbol,labeltype)
select 'en','Setting mandatory fields','Setmandatoryfield','fixedstr' from dual 
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='Setmandatoryfield' and labeltype='fixedstr');
delimiter;

insert into ld_desk(languagetype,fieldlabel,labelbol,labeltype)
select 'zh','设置触发字段条件','SetTriggerFieldCondition','fixedstr' from dual 
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='SetTriggerFieldCondition' and labeltype='fixedstr');
delimiter;

insert into ld_desk(languagetype,fieldlabel,labelbol,labeltype)
select 'en','Setting trigger field condition','SetTriggerFieldCondition','fixedstr' from dual 
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='SetTriggerFieldCondition' and labeltype='fixedstr');
delimiter;

insert into ld_desk(languagetype,fieldlabel,labelbol,labeltype)
select 'zh','其他条件','OtherConditions','fixedstr' from dual 
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='OtherConditions' and labeltype='fixedstr');
delimiter;

insert into ld_desk(languagetype,fieldlabel,labelbol,labeltype)
select 'en','Other conditions','OtherConditions','fixedstr' from dual 
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='OtherConditions' and labeltype='fixedstr');
delimiter;

insert into ld_desk(languagetype,fieldlabel,labelbol,labeltype)
select 'zh','显示字段','DisplayFields','fixedstr' from dual 
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='DisplayFields' and labeltype='fixedstr');
delimiter;

insert into ld_desk(languagetype,fieldlabel,labelbol,labeltype)
select 'en','Display fields','DisplayFields','fixedstr' from dual 
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='DisplayFields' and labeltype='fixedstr');
delimiter;

update ld_field set bigtype='picklistid' where uitype=251 or uitype=252;
delimiter;

update ld_field set bigtype='fileattachment' where uitype=1108 or uitype=1109 or uitype=28 or uitype=69;
delimiter;

CREATE TABLE if not exists `ld_fieldrule` (
  `id` int(19) NOT NULL AUTO_INCREMENT,
  `tabid` int(19) DEFAULT NULL,
  `rulename` varchar(200) DEFAULT NULL,
  `columnname` varchar(100) DEFAULT NULL,
  `createdtime` datetime DEFAULT NULL,
  `smcreator` int(19) DEFAULT NULL,
  `enablestatus` varchar(20) DEFAULT 'yes',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=utf8;
delimiter;

CREATE TABLE if not exists `ld_fieldrule_operate` (
  `id` int(19) NOT NULL AUTO_INCREMENT,
  `columnname` varchar(200) DEFAULT NULL,
  `type` varchar(20) DEFAULT NULL,
  `basicsearchid` int(19) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=utf8;
delimiter;

CREATE TABLE if not exists `ld_fieldrulebasicsearch` (
  `id` int(19) NOT NULL AUTO_INCREMENT,
  `ruleid` int(19) DEFAULT NULL,
  `comparator` varchar(50) DEFAULT NULL,
  `value` varchar(200) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=utf8;
delimiter;
-- 2019-08-14


DROP PROCEDURE IF EXISTS `ldcrm_add_relatedlists_20190815`;
delimiter ||
CREATE PROCEDURE `ldcrm_add_relatedlists_20190815`(
)
BEGIN

	DECLARE tmp_module VARCHAR(100) DEFAULT '';
	DECLARE tmp_tabid INT(19) DEFAULT 0;
	DECLARE tmp_optiontabid INT(19) DEFAULT 0; 

	DECLARE tmp_relatetype VARCHAR(100) DEFAULT '';
	DECLARE tmp_relatecoltable VARCHAR(100) DEFAULT '';
	
	DECLARE MYCUSOR CURSOR FOR 
		SELECT 
			b.`name` AS module,
			a.tabid,
			a.option_tabid,
			CASE
				WHEN REPLACE(b.`name`,'CustomForm','')+0>20 THEN 'datacategory_sql'
				ELSE 'entitytype_datacategory_sql'
			END AS relate_type,
			CASE
				WHEN REPLACE(b.`name`,'CustomForm','')+0>20 THEN CONCAT(LOWER(b.`name`),'detail.entitytypeid')
				ELSE 'tmpsourcedetail.id'
			END AS relate_coltable
		FROM ld_option_module a
		LEFT JOIN ld_tab b ON a.tabid=b.tabid
		WHERE REPLACE(b.`name`,'CustomForm','')+0>10
		ORDER BY a.tabid,a.option_tabid;

	DECLARE CONTINUE HANDLER FOR SQLSTATE '02000' SET tmp_tabid = NULL;

	OPEN MYCUSOR; 
	FETCH MYCUSOR INTO tmp_module,tmp_tabid,tmp_optiontabid,tmp_relatetype,tmp_relatecoltable;
	WHILE(tmp_tabid IS NOT NULL) DO
		SET @tmp_tabid=tmp_tabid;
		SET @maxrelation_id=(SELECT MAX(relation_id) FROM ld_relatedlists);
		SET @max_pcseq=IFNULL((SELECT MAX(sequence) FROM ld_relatedlists WHERE tabid=@tmp_tabid),0);
		SET @max_mobseq=IFNULL((SELECT MAX(mobile_sequence) FROM ld_relatedlists WHERE tabid=@tmp_tabid),0);
		SET @max_wxseq=IFNULL((SELECT MAX(wx_sequence) FROM ld_relatedlists WHERE tabid=@tmp_tabid),0);

		INSERT INTO ld_relatedlists(
			relation_id,
			tabid,
			related_tabid,
			`name`,
			sequence,

			label,
			presence,
			actions,
			mobile_presence,
			mobile_sequence,

			type,
			related_coltable,
			wx_presence,
			wx_sequence				
		)
		SELECT
			@maxrelation_id+1,
			tmp_optiontabid,
			@tmp_tabid,
			CONCAT('get',LOWER(tmp_module)),
			@max_pcseq+1,

			tmp_module,
			1,
			'add',
			1,
			@max_mobseq+1,

			tmp_relatetype,
			tmp_relatecoltable,
			0,
			@max_wxseq+1
		FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM ld_relatedlists WHERE tabid=tmp_optiontabid AND related_tabid=@tmp_tabid);
		
		UPDATE ld_relatedlists_seq SET id=(SELECT MAX(relation_id) FROM ld_relatedlists);

		FETCH MYCUSOR INTO tmp_module,tmp_tabid,tmp_optiontabid,tmp_relatetype,tmp_relatecoltable;
	END WHILE;
	CLOSE MYCUSOR;

end ||
delimiter;

CALL ldcrm_add_relatedlists_20190815();
DROP PROCEDURE IF EXISTS `ldcrm_add_relatedlists_20190815`;

CREATE TABLE if not exists `ld_fieldruleadvancesearch` (
  `id` int(19) NOT NULL AUTO_INCREMENT,
  `basicsearchid` int(19) DEFAULT NULL,
  `columnname` varchar(255) DEFAULT NULL,
  `comparator` varchar(20) DEFAULT NULL,
  `value` varchar(100) DEFAULT NULL,
  `columncondition` varchar(20) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=utf8;
delimiter;


insert into ld_desk(languagetype,fieldlabel,labelbol,labeltype)
select 'zh','设置其他条件','SettingOtherCondition','fixedstr' from dual 
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='SettingOtherCondition' and labeltype='fixedstr');
delimiter;
insert into ld_desk(languagetype,fieldlabel,labelbol,labeltype)
select 'en','Setting other conditions','SettingOtherCondition','fixedstr' from dual 
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='SettingOtherCondition' and labeltype='fixedstr');
delimiter;
-- 2019-08-15

UPDATE ld_bankaccountset SET conversion_rate='1.000000',currency_symbol='¥' WHERE currency_id=1 AND (conversion_rate IS NULL OR currency_symbol IS NULL);

UPDATE ld_relatedlists SET presence=1 WHERE tabid=14 AND `name`='get_purchaseinquiryorder' AND NOT EXISTS (SELECT 1 FROM ld_purchaseinquiryorder);
    
UPDATE ld_field SET typeofdata='V~M' WHERE tabid=15 AND columnname IN ('faqtype','category') AND NOT EXISTS (SELECT 1 FROM ld_faq);
UPDATE ld_field SET defaultvalue='已审批' WHERE tabid=15 AND columnname='status' AND defaultvalue='草案' AND NOT EXISTS (SELECT 1 FROM ld_faq)
    AND EXISTS (SELECT 1 FROM ld_picklist_values WHERE listid IN (SELECT listid FROM ld_picklist_set WHERE listname='faqstatus') AND listvalue='已审批');

update ld_field set searchfieldtype=1 where fieldname='locationaddress' or fieldname='locationaddress_map';
delimiter;

create table if not exists `ld_wx_checkin`(
  `id` int(19)  auto_increment  primary key comment '企业微信打卡表主键',
  `userid` varchar(255) comment '微信成员ID',
  `groupname` varchar(255) comment '打卡规则名称',
  `checkin_type` varchar(255) comment '打卡类型，包含上班打卡，下班打卡，外出打卡',
  `exception_type` varchar(255) comment '异常类型,包含时间异常，地点异常，未打卡，wifi异常，非常用设备。如果有多个异常，以分号间隔',
  `checkin_time` int comment '打卡时间',
  `checkin_time_date` datetime comment '格式化的打卡时间',
  `location_title` varchar(255) comment '打卡地点title',
  `location_detail` text comment '打卡地点详情',
  `wifiname` varchar(255) comment '打卡wifi名称',
  `notes` text comment '打卡备注',
  `wifimac` varchar(255) comment '打卡的MAC地址/bssid',
  `mediaids` varchar(255) comment '打卡的附件media_id'
);
delimiter;

insert into ld_wx_config (name,description,switch)
  select 'checkin_monthly','企业微信打卡同步','open' from dual
  where not exists(select 1 from ld_wx_config where name='checkin_monthly');

select usereportid into @usereportid from ld_usereport where name='AttendanceReport';
insert into ld_usereport(name, reportlabel, tabids, basicfilter, advfilter, Setcolumns,
                         Parent_id, sequence, reporttype, pagewidthpercent)
  select 'checkin_monthly','月度考勤统计表',0,1,0,1,@usereportid,1,51,100 from dual
  where not exists(select 1 from ld_usereport where name='checkin_monthly');
update ld_usereport set sequence=2 where name='SIGNINSTATISTICS';

insert into ld_desk (languagetype, labelbol, fieldlabel, Labeltype)
  select 'zh','checkin_monthly','月度考勤统计表','fixedstr' from dual
  where not exists(select 1 from ld_desk where labelbol='checkin_monthly' and languagetype='zh' and Labeltype='fixedstr');

insert into ld_desk (languagetype, labelbol, fieldlabel, Labeltype)
  select 'en','checkin_monthly','Monthly attendance sheet','fixedstr' from dual
  where not exists(select 1 from ld_desk where labelbol='checkin_monthly' and languagetype='en' and Labeltype='fixedstr');

select usereportid into @id from ld_usereport where name='checkin_monthly';
insert into ld_usereportcolumns(usereportid,columns,sequence,columnshow,realcolumns,realencolumns)
  select  @id, 'time', 1, 1, '时间','Time'
  from dual where not exists(select 1 from ld_usereportcolumns where usereportid=@id and columns='time');

insert into ld_usereportcolumns(usereportid,columns,sequence,columnshow,realcolumns,realencolumns)
  select  @id, 'lastname', 2, 1, '姓名','Name'
  from dual where not exists(select 1 from ld_usereportcolumns where usereportid=@id and columns='lastname');

insert into ld_usereportcolumns(usereportid,columns,sequence,columnshow,realcolumns,realencolumns)
  select  @id, 'group', 3, 1, '部门','Department'
  from dual where not exists(select 1 from ld_usereportcolumns where usereportid=@id and columns='group');

insert into ld_usereportcolumns(usereportid,columns,sequence,columnshow,realcolumns,realencolumns)
  select  @id, 'groupname', 4, 1, '所属规则','Rule'
  from dual where not exists(select 1 from ld_usereportcolumns where usereportid=@id and columns='groupname');

insert into ld_usereportcolumns(usereportid,columns,sequence,columnshow,realcolumns,realencolumns)
  select  @id, 'total_days', 5, 1, '应打卡天数','Days to clock in'
  from dual where not exists(select 1 from ld_usereportcolumns where usereportid=@id and columns='total_days');

insert into ld_usereportcolumns(usereportid,columns,sequence,columnshow,realcolumns,realencolumns)
  select  @id, 'normal_days', 6, 1, '正常天数','Normal days'
  from dual where not exists(select 1 from ld_usereportcolumns where usereportid=@id and columns='normal_days');

insert into ld_usereportcolumns(usereportid,columns,sequence,columnshow,realcolumns,realencolumns)
  select  @id, 'abnormal_days', 7, 1, '异常天数','Abnormal days'
  from dual where not exists(select 1 from ld_usereportcolumns where usereportid=@id and columns='abnormal_days');

insert into ld_usereportcolumns(usereportid,columns,sequence,columnshow,realcolumns,realencolumns)
  select  @id, 'signin_days', 8, 1, '外出签到次数','Outbound sign in times'
  from dual where not exists(select 1 from ld_usereportcolumns where usereportid=@id and columns='signin_days');

insert into ld_desk (languagetype, labelbol, fieldlabel, Labeltype)
  select 'zh','CHECKINSYNCBUTTON','同步企业微信考勤打卡数据','fixedstr' from dual
  where not exists(select 1 from ld_desk where labelbol='CHECKINSYNCBUTTON' and languagetype='zh' and Labeltype='fixedstr');

insert into ld_desk (languagetype, labelbol, fieldlabel, Labeltype)
  select 'en','CHECKINSYNCBUTTON','Synchronize enterprise WeChat timing-in data','fixedstr' from dual
  where not exists(select 1 from ld_desk where labelbol='CHECKINSYNCBUTTON' and languagetype='en' and Labeltype='fixedstr');


select usereportid into @usereportid from ld_usereport where name='AttendanceReport';
insert into ld_usereport(name, reportlabel, tabids, basicfilter, advfilter, Setcolumns,
                         Parent_id, sequence, reporttype, pagewidthpercent)
  select 'checkin_abnormal','考勤异常明细表',0,1,0,1,@usereportid,4,51,100 from dual
  where not exists(select 1 from ld_usereport where name='checkin_abnormal');

insert into ld_desk (languagetype, labelbol, fieldlabel, Labeltype)
  select 'zh','checkin_abnormal','考勤异常明细表','fixedstr' from dual
  where not exists(select 1 from ld_desk where labelbol='checkin_abnormal' and languagetype='zh' and Labeltype='fixedstr');

insert into ld_desk (languagetype, labelbol, fieldlabel, Labeltype)
  select 'en','checkin_abnormal','Anormal attendence sheet','fixedstr' from dual
  where not exists(select 1 from ld_desk where labelbol='checkin_abnormal' and languagetype='en' and Labeltype='fixedstr');

select usereportid into @id from ld_usereport where name='checkin_abnormal';
insert into ld_usereportcolumns(usereportid,columns,sequence,columnshow,realcolumns,realencolumns)
  select  @id, 'time', 1, 1, '时间','Time'
  from dual where not exists(select 1 from ld_usereportcolumns where usereportid=@id and columns='time');
insert into ld_usereportcolumns(usereportid,columns,sequence,columnshow,realcolumns,realencolumns)
  select  @id, 'lastname', 2, 1, '姓名','Name'
  from dual where not exists(select 1 from ld_usereportcolumns where usereportid=@id and columns='lastname');
insert into ld_usereportcolumns(usereportid,columns,sequence,columnshow,realcolumns,realencolumns)
  select  @id, 'group', 3, 1, '部门','Department'
  from dual where not exists(select 1 from ld_usereportcolumns where usereportid=@id and columns='group');
insert into ld_usereportcolumns(usereportid,columns,sequence,columnshow,realcolumns,realencolumns)
  select  @id, 'groupname', 4, 1, '所属规则','Rule'
  from dual where not exists(select 1 from ld_usereportcolumns where usereportid=@id and columns='groupname');
insert into ld_usereportcolumns(usereportid,columns,sequence,columnshow,realcolumns,realencolumns)
  select  @id, 'first_checkin', 5, 1, '最早打卡','The first to clock in'
  from dual where not exists(select 1 from ld_usereportcolumns where usereportid=@id and columns='first_checkin');
insert into ld_usereportcolumns(usereportid,columns,sequence,columnshow,realcolumns,realencolumns)
  select  @id, 'latest_checkin', 6, 1, '最晚打卡','The latest to clock in'
  from dual where not exists(select 1 from ld_usereportcolumns where usereportid=@id and columns='latest_checkin');
insert into ld_usereportcolumns(usereportid,columns,sequence,columnshow,realcolumns,realencolumns)
  select  @id, 'frequency', 7, 1, '次数','Frequency'
  from dual where not exists(select 1 from ld_usereportcolumns where usereportid=@id and columns='frequency');
insert into ld_usereportcolumns(usereportid,columns,sequence,columnshow,realcolumns,realencolumns)
  select  @id, 'work_hour', 8, 1, '工作时长(h)','Working hours(h)'
  from dual where not exists(select 1 from ld_usereportcolumns where usereportid=@id and columns='work_hour');
insert into ld_usereportcolumns(usereportid,columns,sequence,columnshow,realcolumns,realencolumns)
  select  @id, 'condition', 9, 1, '状态','Condition'
  from dual where not exists(select 1 from ld_usereportcolumns where usereportid=@id and columns='condition');

select usereportid into @usereportid from ld_usereport where name='AttendanceReport';
insert into ld_usereport(name, reportlabel, tabids, basicfilter, advfilter, Setcolumns,
                         Parent_id, sequence, reporttype, pagewidthpercent)
  select 'minusjob_billdetail','请假明细表',0,1,0,1,@usereportid,3,51,100 from dual
  where not exists(select 1 from ld_usereport where name='minusjob_billdetail');

insert into ld_desk (languagetype, labelbol, fieldlabel, Labeltype)
  select 'zh','minusjob_billdetail','请假明细表','fixedstr' from dual
  where not exists(select 1 from ld_desk where labelbol='minusjob_billdetail' and languagetype='zh' and Labeltype='fixedstr');

insert into ld_desk (languagetype, labelbol, fieldlabel, Labeltype)
  select 'en','minusjob_billdetail','Absence form','fixedstr' from dual
  where not exists(select 1 from ld_desk where labelbol='minusjob_billdetail' and languagetype='en' and Labeltype='fixedstr');

select blockid into @blockid from ld_settings_blocks where label='LBL_INTERFACE_SETTINGS';
select max(sequence) into @sequence from ld_settings_field where blockid=@blockid;
select max(fieldid) into @fieldid from ld_settings_field;
insert into ld_settings_field(fieldid,blockid,name,iconpath,description,linkto,sequence,active)
  select @fieldid+1,@blockid,'CHECKINSETTING','picklistdependency.png','CHECKINSETTING_DESCRIB',
    'index.php?module=Settings&action=checkin_setting&parenttab=Settings',@sequence+1,0 from DUAL
  where not exists(select 1 from ld_settings_field where blockid = @blockid and `name` = 'CHECKINSETTING');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
  select 'zh','CHECKINSETTING','企业微信考勤接口设置','fixedstr' from DUAL
  where not exists(select 1 from ld_desk where labelbol = 'CHECKINSETTING' and languagetype='zh' and labeltype = 'fixedstr');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
  select 'en','CHECKINSETTING','Enterprise WeChat Attendance Data Interface','fixedstr' from DUAL
  where not exists(select 1 from ld_desk where labelbol = 'CHECKINSETTING' and languagetype='en' and labeltype = 'fixedstr');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
  select 'zh','CHECKINSETTING_DESCRIB','接入企业微信考勤打卡数据并增加相关的考勤统计表','fixedstr' from DUAL
  where not exists(select 1 from ld_desk where labelbol = 'CHECKINSETTING_DESCRIB' and languagetype='zh' and labeltype = 'fixedstr');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
  select 'en','CHECKINSETTING_DESCRIB','Get enterprise Wechat attendance data and add related report','fixedstr' from DUAL
  where not exists(select 1 from ld_desk where labelbol = 'CHECKINSETTING_DESCRIB' and languagetype='en' and labeltype = 'fixedstr');

INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
  select 'zh','CHECKINSETTING_TITLE1','企业微信企业号ID','fixedstr' from DUAL
  where not exists(select 1 from ld_desk where labelbol = 'CHECKINSETTING_TITLE1' and languagetype='zh' and labeltype = 'fixedstr');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
  select 'en','CHECKINSETTING_TITLE1','CorpID','fixedstr' from DUAL
  where not exists(select 1 from ld_desk where labelbol = 'CHECKINSETTING_TITLE1' and languagetype='en' and labeltype = 'fixedstr');

INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
  select 'zh','CHECKINSETTING_TITLE2','企业微信打卡应用Secret','fixedstr' from DUAL
  where not exists(select 1 from ld_desk where labelbol = 'CHECKINSETTING_TITLE2' and languagetype='zh' and labeltype = 'fixedstr');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
  select 'en','CHECKINSETTING_TITLE2','Checkin App Secret','fixedstr' from DUAL
  where not exists(select 1 from ld_desk where labelbol = 'CHECKINSETTING_TITLE2' and languagetype='en' and labeltype = 'fixedstr');
delimiter;
-- 2019-08-16


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

UPDATE ld_version SET old_version='V7.8.3',current_version='V7.8.3',remark='V7.8.3-20190816',wx_version='V7.8.3';
delimiter;