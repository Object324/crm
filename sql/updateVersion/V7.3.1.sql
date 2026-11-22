UPDATE ld_field SET typeofdata='DT~O' WHERE columnname IN ('createdtime','modifiedtime') AND typeofdata='DT~M';
-- 2018-03-16

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','noproductpermissions','您没有{$Products.Products}模块权限！','jspop' from dual
where not exists(select 1 from ld_desk where languagetype = 'zh' and labelbol = 'noproductpermissions' and labeltype = 'jspop');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','noproductpermissions','You have no {$Products.Products} permissions!','jspop' from dual
where not exists(select 1 from ld_desk where languagetype = 'en' and labelbol = 'noproductpermissions' and labeltype = 'jspop');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','setproductpermissions','请联系管理员在角色权限中设置{$Products.Products}模块权限！','jspop' from dual
where not exists(select 1 from ld_desk where languagetype = 'zh' and labelbol = 'setproductpermissions' and labeltype = 'jspop');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','setproductpermissions','Please contact the administrator to set the {$Products.Products} permissions in the role rights!','jspop' from dual
where not exists(select 1 from ld_desk where languagetype = 'en' and labelbol = 'setproductpermissions' and labeltype = 'jspop');
delimiter;

update ld_desk set fieldlabel = 'Check weight merger' where labelbol = 'CHECKMERGE' and languagetype = 'en' and Labeltype = 'fixedstr';
delimiter;

CREATE TABLE if not exists `ld_account_set_rule` (
  `tabname` varchar(50) DEFAULT NULL,
  `type` varchar(20) DEFAULT NULL,
  `condition` varchar(20) DEFAULT NULL,
  `labelbol` varchar(200) DEFAULT NULL,
  `sequence` int(10) DEFAULT NULL,
  `days` int(10) DEFAULT NULL,
  `status` varchar(50) DEFAULT NULL,
  `columnname` varchar(50) DEFAULT NULL,
  `otherwhere` varchar(200) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
delimiter;

insert into ld_desk (languagetype,labelbol,fieldlabel,labeltype)
select 'zh','AUTOMATICRECOVERYRULE','自动回收规则设置','fixedstr' from dual where not exists(select 1 from ld_desk where labelbol='AUTOMATICRECOVERYRULE' and Labeltype='fixedstr' and languagetype='zh');

insert into ld_desk (languagetype,labelbol,fieldlabel,labeltype)
select 'en','AUTOMATICRECOVERYRULE','Automatic recovery rule setting','fixedstr' from dual where not exists(select 1 from ld_desk where labelbol='AUTOMATICRECOVERYRULE' and Labeltype='fixedstr' and languagetype='en');
delimiter;
insert into ld_desk (languagetype,labelbol,fieldlabel,labeltype)
select 'zh','NOCOMPLETEAUTORECOVERYRULE','公海目标未达成时，自动回收规则','fixedstr' from dual where not exists(select 1 from ld_desk where labelbol='NOCOMPLETEAUTORECOVERYRULE' and Labeltype='fixedstr' and languagetype='zh');

insert into ld_desk (languagetype,labelbol,fieldlabel,labeltype)
select 'en','NOCOMPLETEAUTORECOVERYRULE','Automatic recovery rules when the target of the high seas is not reached','fixedstr' from dual where not exists(select 1 from ld_desk where labelbol='NOCOMPLETEAUTORECOVERYRULE' and Labeltype='fixedstr' and languagetype='en');
delimiter;

insert into ld_desk (languagetype,labelbol,fieldlabel,labeltype)
select 'zh','RULEENABLED','启用规则，多个回收条件之间的逻辑关系为','fixedstr' from dual where not exists(select 1 from ld_desk where labelbol='RULEENABLED' and Labeltype='fixedstr' and languagetype='zh');
insert into ld_desk (languagetype,labelbol,fieldlabel,labeltype)
select 'en','RULEENABLED','The rules are enabled, and the logical relationship between multiple recovery conditions is','fixedstr' from dual where not exists(select 1 from ld_desk where labelbol='RULEENABLED' and Labeltype='fixedstr' and languagetype='en');
delimiter;

insert into ld_desk (languagetype,labelbol,fieldlabel,labeltype)
select 'zh','ALLOCATEORGETSTART','自分配或领用之日起','fixedstr' from dual where not exists(select 1 from ld_desk where labelbol='ALLOCATEORGETSTART' and Labeltype='fixedstr' and languagetype='zh');

insert into ld_desk (languagetype,labelbol,fieldlabel,labeltype)
select 'en','ALLOCATEORGETSTART','from the date of distribution or receiv','fixedstr' from dual where not exists(select 1 from ld_desk where labelbol='ALLOCATEORGETSTART' and Labeltype='fixedstr' and languagetype='en');
delimiter;

insert into ld_desk (languagetype,labelbol,fieldlabel,labeltype)
select 'zh','NOTCREATECONTACTRECORDS','天没有创建{$ContactRecords.ContactRecords}','fixedstr' from dual where not exists(select 1 from ld_desk where labelbol='NOTCREATECONTACTRECORDS' and Labeltype='fixedstr' and languagetype='zh');

insert into ld_desk (languagetype,labelbol,fieldlabel,labeltype)
select 'en','NOTCREATECONTACTRECORDS','days no new {$ContactRecords.ContactRecords}','fixedstr' from dual where not exists(select 1 from ld_desk where labelbol='NOTCREATECONTACTRECORDS' and Labeltype='fixedstr' and languagetype='en');
delimiter;

insert into ld_desk (languagetype,labelbol,fieldlabel,labeltype)
select 'zh','NOTCREATEPOTENTIALS','天没有创建{$Potentials.Potentials}','fixedstr' from dual where not exists(select 1 from ld_desk where labelbol='NOTCREATEPOTENTIALS' and Labeltype='fixedstr' and languagetype='zh');
insert into ld_desk (languagetype,labelbol,fieldlabel,labeltype)
select 'en','NOTCREATEPOTENTIALS','days no new {$Potentials.Potentials}','fixedstr' from dual where not exists(select 1 from ld_desk where labelbol='NOTCREATEPOTENTIALS' and Labeltype='fixedstr' and languagetype='en');
delimiter;

insert into ld_desk (languagetype,labelbol,fieldlabel,labeltype)
select 'zh','NOTCREATESALESORDER','天没有创建{$SalesOrder.SalesOrder}','fixedstr' from dual where not exists(select 1 from ld_desk where labelbol='NOTCREATESALESORDER' and Labeltype='fixedstr' and languagetype='zh');
insert into ld_desk (languagetype,labelbol,fieldlabel,labeltype)
select 'en','NOTCREATESALESORDER','days no new {$SalesOrder.SalesOrder}','fixedstr' from dual where not exists(select 1 from ld_desk where labelbol='NOTCREATESALESORDER' and Labeltype='fixedstr' and languagetype='en');
delimiter;

insert into ld_desk (languagetype,labelbol,fieldlabel,labeltype)
select 'zh','NOTCREATESERVICECONTRACTS','天没有创建{$ServiceContracts.ServiceContracts}','fixedstr' from dual where not exists(select 1 from ld_desk where labelbol='NOTCREATESERVICECONTRACTS' and Labeltype='fixedstr' and languagetype='zh');
insert into ld_desk (languagetype,labelbol,fieldlabel,labeltype)
select 'en','NOTCREATESERVICECONTRACTS','days no new {$ServiceContracts.ServiceContracts}','fixedstr' from dual where not exists(select 1 from ld_desk where labelbol='NOTCREATESERVICECONTRACTS' and Labeltype='fixedstr' and languagetype='en');
delimiter;

insert into ld_desk (languagetype,labelbol,fieldlabel,labeltype)
select 'zh','NOTCREATECASHBILL','天没有创建{$CashBill.CashBill}','fixedstr' from dual where not exists(select 1 from ld_desk where labelbol='NOTCREATECASHBILL' and Labeltype='fixedstr' and languagetype='zh');
insert into ld_desk (languagetype,labelbol,fieldlabel,labeltype)
select 'en','NOTCREATECASHBILL','days no new {$CashBill.CashBill}','fixedstr' from dual where not exists(select 1 from ld_desk where labelbol='NOTCREATECASHBILL' and Labeltype='fixedstr' and languagetype='en');
delimiter;

insert into ld_desk (languagetype,labelbol,fieldlabel,labeltype)
select 'zh','COMPLETEAUTOMATICRECOVERYRULE','公海目标达成后，自动回收规则','fixedstr' from dual where not exists(select 1 from ld_desk where labelbol='COMPLETEAUTOMATICRECOVERYRULE' and Labeltype='fixedstr' and languagetype='zh');
insert into ld_desk (languagetype,labelbol,fieldlabel,labeltype)
select 'en','COMPLETEAUTOMATICRECOVERYRULE','Automatic recovery rules after the attainment of the high seas target','fixedstr' from dual where not exists(select 1 from ld_desk where labelbol='COMPLETEAUTOMATICRECOVERYRULE' and Labeltype='fixedstr' and languagetype='en');
delimiter;

insert into ld_desk (languagetype,labelbol,fieldlabel,labeltype)
select 'zh','ALLOCATEORGETSTARTNOCREATECONTACTRECORDS','自分配或领用之日起距最近一次{$ContactRecords.ContactRecords}的{$ContactRecords.contactdate}已超过','fixedstr' from dual where not exists(select 1 from ld_desk where labelbol='ALLOCATEORGETSTARTNOCREATECONTACTRECORDS' and Labeltype='fixedstr' and languagetype='zh');
insert into ld_desk (languagetype,labelbol,fieldlabel,labeltype)
select 'en','ALLOCATEORGETSTARTNOCREATECONTACTRECORDS','The nearest {$ContactRecords.contactdate} of {$ContactRecords.ContactRecords} has exceed  the date of distribution or receive','fixedstr' from dual where not exists(select 1 from ld_desk where labelbol='ALLOCATEORGETSTARTNOCREATECONTACTRECORDS' and Labeltype='fixedstr' and languagetype='en');
delimiter;

insert into ld_desk (languagetype,labelbol,fieldlabel,labeltype)
select 'zh','ALLOCATEORGETSTARTNOCREATEPOTENTIALS','自分配或领用之日起距最近一次{$Potentials.Potentials}的{$Potentials.createdtime}已超过','fixedstr' from dual where not exists(select 1 from ld_desk where labelbol='ALLOCATEORGETSTARTNOCREATEPOTENTIALS' and Labeltype='fixedstr' and languagetype='zh');
insert into ld_desk (languagetype,labelbol,fieldlabel,labeltype)
select 'en','ALLOCATEORGETSTARTNOCREATEPOTENTIALS',' The nearest {$Potentials.createdtime} of {$Potentials.Potentials} has exceed  the date of distribution or receive','fixedstr' from dual where not exists(select 1 from ld_desk where labelbol='ALLOCATEORGETSTARTNOCREATEPOTENTIALS' and Labeltype='fixedstr' and languagetype='en');
delimiter;

insert into ld_desk (languagetype,labelbol,fieldlabel,labeltype)
select 'zh','ALLOCATEORGETSTARTNOCREATESALESORDER','自分配或领用之日起距最近一次{$SalesOrder.SalesOrder}的{$SalesOrder.signed_data}已超过','fixedstr' from dual where not exists(select 1 from ld_desk where labelbol='ALLOCATEORGETSTARTNOCREATESALESORDER' and Labeltype='fixedstr' and languagetype='zh');
insert into ld_desk (languagetype,labelbol,fieldlabel,labeltype)
select 'en','ALLOCATEORGETSTARTNOCREATESALESORDER','The nearest {$SalesOrder.signed_data} of {$SalesOrder.SalesOrder} has exceed  the date of distribution or receive','fixedstr' from dual where not exists(select 1 from ld_desk where labelbol='ALLOCATEORGETSTARTNOCREATESALESORDER' and Labeltype='fixedstr' and languagetype='en');
delimiter;

insert into ld_desk (languagetype,labelbol,fieldlabel,labeltype)
select 'zh','ALLOCATEORGETSTARTNOCREATESERVICECONTRACTS','自分配或领用之日起距最近一次{$ServiceContracts.ServiceContracts}的{$ServiceContracts.due_date}已超过','fixedstr' from dual where not exists(select 1 from ld_desk where labelbol='ALLOCATEORGETSTARTNOCREATESERVICECONTRACTS' and Labeltype='fixedstr' and languagetype='zh');
insert into ld_desk (languagetype,labelbol,fieldlabel,labeltype)
select 'en','ALLOCATEORGETSTARTNOCREATESERVICECONTRACTS','The nearest {$ServiceContracts.due_date} of {$ServiceContracts.ServiceContracts} has exceed  the date of distribution or receive','fixedstr' from dual where not exists(select 1 from ld_desk where labelbol='ALLOCATEORGETSTARTNOCREATESERVICECONTRACTS' and Labeltype='fixedstr' and languagetype='en');
delimiter;

insert into ld_desk (languagetype,labelbol,fieldlabel,labeltype)
select 'zh','ALLOCATEORGETSTARTNOCREATECASHBILL','自分配或领用之日起距最近一次{$CashBill.CashBill}的{$CashBill.cashbilldate}已超过','fixedstr' from dual where not exists(select 1 from ld_desk where labelbol='ALLOCATEORGETSTARTNOCREATECASHBILL' and Labeltype='fixedstr' and languagetype='zh');
insert into ld_desk (languagetype,labelbol,fieldlabel,labeltype)
select 'en','ALLOCATEORGETSTARTNOCREATECASHBILL','The nearest {$CashBill.cashbilldate} of {$CashBill.CashBill} has exceed  the date of distribution or receive','fixedstr' from dual where not exists(select 1 from ld_desk where labelbol='ALLOCATEORGETSTARTNOCREATECASHBILL' and Labeltype='fixedstr' and languagetype='en');
delimiter;

insert into ld_desk (languagetype,labelbol,fieldlabel,labeltype)
select 'zh','ALLOCATEORGETSTARTNOCREATECONTACTRECORDSCREATE','自分配或创建之日起距最近一次{$ContactRecords.ContactRecords}的{$ContactRecords.contactdate}已超过','fixedstr' from dual where not exists(select 1 from ld_desk where labelbol='ALLOCATEORGETSTARTNOCREATECONTACTRECORDSCREATE' and Labeltype='fixedstr' and languagetype='zh');
insert into ld_desk (languagetype,labelbol,fieldlabel,labeltype)
select 'en','ALLOCATEORGETSTARTNOCREATECONTACTRECORDSCREATE','The nearest {$ContactRecords.contactdate} of {$ContactRecords.ContactRecords} has exceed  the date of distribution or creation','fixedstr' from dual where not exists(select 1 from ld_desk where labelbol='ALLOCATEORGETSTARTNOCREATECONTACTRECORDSCREATE' and Labeltype='fixedstr' and languagetype='en');
delimiter;

insert into ld_desk (languagetype,labelbol,fieldlabel,labeltype)
select 'zh','ALLOCATEORGETSTARTNOCREATEPOTENTIALSCREATE','自分配或创建之日起距最近一次{$Potentials.Potentials}的{$Potentials.createdtime}已超过','fixedstr' from dual where not exists(select 1 from ld_desk where labelbol='ALLOCATEORGETSTARTNOCREATEPOTENTIALSCREATE' and Labeltype='fixedstr' and languagetype='zh');
insert into ld_desk (languagetype,labelbol,fieldlabel,labeltype)
select 'en','ALLOCATEORGETSTARTNOCREATEPOTENTIALSCREATE',' The nearest {$Potentials.createdtime} of {$Potentials.Potentials} has exceed  the date of distribution or creation','fixedstr' from dual where not exists(select 1 from ld_desk where labelbol='ALLOCATEORGETSTARTNOCREATEPOTENTIALSCREATE' and Labeltype='fixedstr' and languagetype='en');
delimiter;

insert into ld_desk (languagetype,labelbol,fieldlabel,labeltype)
select 'zh','ALLOCATEORGETSTARTNOCREATESALESORDERCREATE','自分配或创建之日起距最近一次{$SalesOrder.SalesOrder}的{$SalesOrder.signed_data}已超过','fixedstr' from dual where not exists(select 1 from ld_desk where labelbol='ALLOCATEORGETSTARTNOCREATESALESORDERCREATE' and Labeltype='fixedstr' and languagetype='zh');
insert into ld_desk (languagetype,labelbol,fieldlabel,labeltype)
select 'en','ALLOCATEORGETSTARTNOCREATESALESORDERCREATE','The nearest {$SalesOrder.signed_data} of {$SalesOrder.SalesOrder} has exceed  the date of distribution or creation','fixedstr' from dual where not exists(select 1 from ld_desk where labelbol='ALLOCATEORGETSTARTNOCREATESALESORDERCREATE' and Labeltype='fixedstr' and languagetype='en');
delimiter;

insert into ld_desk (languagetype,labelbol,fieldlabel,labeltype)
select 'zh','ALLOCATEORGETSTARTNOCREATESERVICECONTRACTSCREATE','自分配或创建之日起距最近一次{$ServiceContracts.ServiceContracts}的{$ServiceContracts.due_date}已超过','fixedstr' from dual where not exists(select 1 from ld_desk where labelbol='ALLOCATEORGETSTARTNOCREATESERVICECONTRACTSCREATE' and Labeltype='fixedstr' and languagetype='zh');
insert into ld_desk (languagetype,labelbol,fieldlabel,labeltype)
select 'en','ALLOCATEORGETSTARTNOCREATESERVICECONTRACTSCREATE','The nearest {$ServiceContracts.due_date} of {$ServiceContracts.ServiceContracts} has exceed  the date of distribution or creation','fixedstr' from dual where not exists(select 1 from ld_desk where labelbol='ALLOCATEORGETSTARTNOCREATESERVICECONTRACTSCREATE' and Labeltype='fixedstr' and languagetype='en');
delimiter;

insert into ld_desk (languagetype,labelbol,fieldlabel,labeltype)
select 'zh','ALLOCATEORGETSTARTNOCREATECASHBILLCREATE','自分配或创建之日起距最近一次{$CashBill.CashBill}的{$CashBill.cashbilldate}已超过','fixedstr' from dual where not exists(select 1 from ld_desk where labelbol='ALLOCATEORGETSTARTNOCREATECASHBILLCREATE' and Labeltype='fixedstr' and languagetype='zh');
insert into ld_desk (languagetype,labelbol,fieldlabel,labeltype)
select 'en','ALLOCATEORGETSTARTNOCREATECASHBILLCREATE','The nearest {$CashBill.cashbilldate} of {$CashBill.CashBill} has exceed  the date of distribution or creation','fixedstr' from dual where not exists(select 1 from ld_desk where labelbol='ALLOCATEORGETSTARTNOCREATECASHBILLCREATE' and Labeltype='fixedstr' and languagetype='en');
delimiter;


insert into ld_desk (languagetype,labelbol,fieldlabel,labeltype)
select 'zh','REGULARCUSTOMERRECOVERYRULE','普通客户参与回收，自动回收规则','fixedstr' from dual where not exists(select 1 from ld_desk where labelbol='REGULARCUSTOMERRECOVERYRULE' and Labeltype='fixedstr' and languagetype='zh');
insert into ld_desk (languagetype,labelbol,fieldlabel,labeltype)
select 'en','REGULARCUSTOMERRECOVERYRULE','Regular customer participation in recycling and auto recovery rules','fixedstr' from dual where not exists(select 1 from ld_desk where labelbol='REGULARCUSTOMERRECOVERYRULE' and Labeltype='fixedstr' and languagetype='en');
delimiter;

insert into ld_account_set_rule(tabname,type,`condition`,labelbol,days,status,columnname,sequence)
select 'ContactRecords','nocomplete','and','ALLOCATEORGETSTART/NOTCREATECONTACTRECORDS',10,'active','createdtime',1 from dual
 where not exists(select 1 from ld_account_set_rule where type='nocomplete' and tabname='contactrecords');

insert into ld_account_set_rule(tabname,type,`condition`,labelbol,days,status,columnname,sequence)
select 'Potentials','nocomplete','and','ALLOCATEORGETSTART/NOTCREATEPOTENTIALS',15,'inactive','createdtime',2 from dual
 where not exists(select 1 from ld_account_set_rule where type='nocomplete' and tabname='Potentials');

insert into ld_account_set_rule(tabname,type,`condition`,labelbol,days,status,columnname,sequence)
select 'SalesOrder','nocomplete','and','ALLOCATEORGETSTART/NOTCREATESALESORDER',30,'inactive','createdtime',3 from dual
 where not exists(select 1 from ld_account_set_rule where type='nocomplete' and tabname='SalesOrder');

insert into ld_account_set_rule(tabname,type,`condition`,labelbol,days,status,columnname,sequence)
select 'ServiceContracts','nocomplete','and','ALLOCATEORGETSTART/NOTCREATESERVICECONTRACTS',30,'inactive','createdtime',4 from dual
 where not exists(select 1 from ld_account_set_rule where type='nocomplete' and tabname='ServiceContracts');

insert into ld_account_set_rule(tabname,type,`condition`,labelbol,days,status,columnname,sequence)
select 'CashBill','nocomplete','and','ALLOCATEORGETSTART/NOTCREATECASHBILL',40,'inactive','createdtime',5 from dual
 where not exists(select 1 from ld_account_set_rule where type='nocomplete' and tabname='CashBill');
delimiter;

insert into ld_account_set_rule(tabname,type,`condition`,labelbol,days,status,columnname,sequence)
select 'ContactRecords','complete','or','ALLOCATEORGETSTARTNOCREATECONTACTRECORDS/Days',10,'inactive','contactdate',1 from dual
 where not exists(select 1 from ld_account_set_rule where type='complete' and tabname='contactrecords');

insert into ld_account_set_rule(tabname,type,`condition`,labelbol,days,status,columnname,sequence)
select 'Potentials','complete','or','ALLOCATEORGETSTARTNOCREATEPOTENTIALS/Days',15,'inactive','createdtime',2 from dual
 where not exists(select 1 from ld_account_set_rule where type='complete' and tabname='Potentials');

insert into ld_account_set_rule(tabname,type,`condition`,labelbol,days,status,columnname,sequence)
select 'SalesOrder','complete','or','ALLOCATEORGETSTARTNOCREATESALESORDER/Days',30,'inactive','signed_data',3 from dual
 where not exists(select 1 from ld_account_set_rule where type='complete' and tabname='SalesOrder');

insert into ld_account_set_rule(tabname,type,`condition`,labelbol,days,status,columnname,sequence)
select 'ServiceContracts','complete','or','ALLOCATEORGETSTARTNOCREATESERVICECONTRACTS/Days',30,'inactive','due_date',4 from dual
 where not exists(select 1 from ld_account_set_rule where type='complete' and tabname='ServiceContracts');

insert into ld_account_set_rule(tabname,type,`condition`,labelbol,days,status,columnname,sequence)
select 'CashBill','complete','or','ALLOCATEORGETSTARTNOCREATECASHBILL/Days',40,'inactive','cashbilldate',5 from dual
 where not exists(select 1 from ld_account_set_rule where type='complete' and tabname='CashBill');
delimiter;

insert into ld_account_set_rule(tabname,type,`condition`,labelbol,days,status,columnname,sequence)
select 'ContactRecords','normal','and','ALLOCATEORGETSTARTNOCREATECONTACTRECORDSCREATE/Days',10,'inactive','contactdate',1 from dual
 where not exists(select 1 from ld_account_set_rule where type='normal' and tabname='contactrecords');

insert into ld_account_set_rule(tabname,type,`condition`,labelbol,days,status,columnname,sequence)
select 'Potentials','normal','and','ALLOCATEORGETSTARTNOCREATEPOTENTIALSCREATE/Days',15,'inactive','createdtime',2 from dual
 where not exists(select 1 from ld_account_set_rule where type='normal' and tabname='Potentials');


insert into ld_account_set_rule(tabname,type,`condition`,labelbol,days,status,columnname,sequence)
select 'SalesOrder','normal','and','ALLOCATEORGETSTARTNOCREATESALESORDERCREATE/Days',30,'inactive','signed_data',3 from dual
 where not exists(select 1 from ld_account_set_rule where type='normal' and tabname='SalesOrder');

insert into ld_account_set_rule(tabname,type,`condition`,labelbol,days,status,columnname,sequence)
select 'ServiceContracts','normal','and','ALLOCATEORGETSTARTNOCREATESERVICECONTRACTSCREATE/Days',30,'inactive','due_date',4 from dual
 where not exists(select 1 from ld_account_set_rule where type='normal' and tabname='ServiceContracts');

insert into ld_account_set_rule(tabname,type,`condition`,labelbol,days,status,columnname,sequence)
select 'CashBill','normal','and','ALLOCATEORGETSTARTNOCREATECASHBILLCREATE/Days',40,'inactive','cashbilldate',5 from dual
 where not exists(select 1 from ld_account_set_rule where type='normal' and tabname='CashBill');
delimiter;


drop PROCEDURE if exists splitstr  ;
delimiter ||
create PROCEDURE splitstr(s_str varchar(128), s_split varchar(3))
begin

	drop table if exists splitstrlist;
	create temporary table splitstrlist( str varchar(100));
  set @i = length(s_str) - length(replace(s_str,s_split,''));  -- 算出分隔符的总数
  set @left_str = s_str;
  while @i>0                -- 有多少个分隔符就循环多少遍
  do
  set @sub_str = substr(@left_str,1,instr(@left_str,s_split)-1);            -- 得到分隔符前面的字符串
  set @left_str = substr(@left_str,length(@sub_str)+length(s_split)+1);     -- 得到分隔符后面的字符串
  set @n = trim(@sub_str);
  insert into splitstrlist(str) values(@n);
  set @i = @i - 1;
  end while;
  set @n = trim(@left_str);
  insert into splitstrlist(str) values(@n);
end ||
delimiter;

select bills into @bills from ld_account_set;
call splitstr(@bills,'/');
delimiter;

drop PROCEDURE if EXISTS insertaccountsetcondition;
delimiter ||
create PROCEDURE insertaccountsetcondition()
BEGIN
	declare done  int  default 0;
declare  mmodulename varchar(100);
declare cur1 CURSOR FOR SELECT str  FROM  splitstrlist;
	  declare continue handler  for not   found  SET done =1;
	select days into @oldday from ld_account_set;
	 select bills into @bills from ld_account_set;
		set @days=@oldday;
		if(@bills='' or @bills=null ) THEN
			 set @days=0;

		end if;

		OPEN cur1;
	  Fetch cur1 into mmodulename;
	 loop1: while  done<>1 DO
		update ld_account_set_rule set days=@days,status='active' ,`condition`='or'  where tabname=mmodulename and type='complete' ;
		Fetch cur1 into mmodulename;
	  end while loop1;
	close cur1;

end ||
delimiter;
call insertaccountsetcondition();


update ld_account_set_rule set otherwhere="  and ld_salesorder.sostatus<>'已作废' " where tabname='salesorder';
update ld_account_set_rule set otherwhere="  and ld_servicecontracts.contract_status<>'已作废' " where tabname='servicecontracts';
drop PROCEDURE if EXISTS account_nocomplete_recoveryrule;
delimiter ||
create PROCEDURE  account_nocomplete_recoveryrule()
BEGIN

	DECLARE var_tabname varchar(100);
	DECLARE var_columnname varchar(100);
	DECLARE var_tablename varchar(100);
	DECLARE var_condition varchar(50);
	DECLARE var_days int(11);
	DECLARE var_otherwhere varchar(200);

	declare done  int  default 0;

	declare cur1 CURSOR FOR select tabname,ld_account_set_rule.columnname,ld_field.tablename ,`condition`,ld_account_set_rule.days
 ,ld_account_set_rule.otherwhere from ld_account_set_rule  inner join ld_tab on ld_tab.name=ld_account_set_rule.tabname and presence in(0,2)
	INNER JOIN ld_field on ld_field.tabid=ld_tab.tabid and ld_account_set_rule.columnname=ld_field.columnname
	and ld_field.presence in(0,2) where ld_account_set_rule.type='nocomplete' and ld_account_set_rule.`status`='active';
	declare continue handler  for not   found  SET done =1;
	set @tmpint=0;
	set @tmpsql='';
  select max(ld_account_set_rule.days) into @maxdays
  from ld_account_set_rule  inner join ld_tab on ld_tab.name=ld_account_set_rule.tabname and presence in(0,2)
	INNER JOIN ld_field on ld_field.tabid=ld_tab.tabid and ld_account_set_rule.columnname=ld_field.columnname
	and ld_field.presence in(0,2) where ld_account_set_rule.type='nocomplete' and ld_account_set_rule.`status`='active';


	OPEN cur1;

	Fetch cur1 into var_tabname,var_columnname,var_tablename,var_condition,var_days,var_otherwhere;
	loop1: while  done<>1 DO

		  if var_condition='and'  then

			set @tmpsqlone =concat("select ld_account.accountid,ld_account.allocatedate from ld_account ");
			set @tmpsqlone=concat(@tmpsqlone," inner join ",var_tablename,' on ',var_tablename,'.accountid=ld_account.accountid ');
			set @tmpsqlone=concat(@tmpsqlone," and  ",var_tablename,'.smownerid=ld_account.smownerid' );
			set @tmpsqlone=concat(@tmpsqlone," where   ",var_tablename,".deleted=0   ");

		   if var_otherwhere is not null and  var_otherwhere<>'' then
					set @tmpsqlone=concat(@tmpsqlone,var_otherwhere);
				end if;
		  set @tmpsqlone=concat( @tmpsqlone,' group by ld_account.accountid ') ;
			set @tmpsqlone=concat(@tmpsqlone,"  having  datediff(curdate(),case when ld_account.allocatedate>max( ",var_tablename,'.',var_columnname,")   then ld_account.allocatedate else max(",var_tablename,'.',var_columnname,") end  )>",var_days );

			set @tmpsqltwo=concat('select ld_account.accountid,ld_account.allocatedate from  ld_account LEFT JOIN(select ld_account.accountid
					from ld_account inner join ',var_tablename,' on ld_account.accountid=',var_tablename,'.accountid
						and ld_account.smownerid=',var_tablename,'.smownerid  where ',var_tablename,'.deleted=0' );

		   if var_otherwhere is not null and  var_otherwhere<>'' then
					set @tmpsqltwo=concat(@tmpsqltwo, var_otherwhere);
				end if;
			set @tmpsqltwo=concat(@tmpsqltwo,' ) 	as ttt_',var_tablename,'  on ld_account.accountid=ttt_',var_tablename,'.accountid   where ttt_',var_tablename,'.accountid is null  ' );
			set @tmpsqltwo=concat(@tmpsqltwo," and datediff(curdate(),ld_account.allocatedate ) >",var_days);


			set @tmpthree=concat( @tmpsqlone,' union all ',@tmpsqltwo);
			set @tmpsql=concat(@tmpsql," select * from ( ",@tmpthree," ) as  tttt_",var_tabname);
			set @tmpsql=concat(@tmpsql,' union all ' );

			elseif (var_condition='or')  then

				set @tmpsql=concat(@tmpsql ,' select ld_account.accountid,ld_account.allocatedate from ld_account inner join '  ,var_tablename,' on ',var_tablename,'.accountid=ld_account.accountid  ');

			  set @tmpsql=concat(@tmpsql,' and ' ,var_tablename,'.smownerid=ld_account.smownerid ' );
				set @tmpsql=concat(@tmpsql,' where  ' , var_tablename,'.deleted=0 ' );
				if var_otherwhere is not null and  var_otherwhere<>'' then
					set @tmpsql=concat(@tmpsql,var_otherwhere);
				end if;
				set @tmpsql=concat(@tmpsql," group by ld_account.accountid ");

				set @tmpsql=concat(@tmpsql," having    datediff ( curdate(), case when ld_account.allocatedate > max(" , var_tablename,".",var_columnname," ) then ld_account.allocatedate else max(" , var_tablename,".",var_columnname,") end  )<=",var_days );

				set @tmpsql=concat(@tmpsql,' union all ' );

			end if;
			set @tmpint=@tmpint+1;
			Fetch cur1 into var_tabname,var_columnname,var_tablename,var_condition,var_days,var_otherwhere;
		end while loop1;
		close cur1;


	if @tmpint>0 then
		set @len=CHAR_LENGTH(' union all ');

		set @tmpsql=left(@tmpsql,CHAR_LENGTH(@tmpsql)-@len);

		set @sql=concat(' select accountid from (',@tmpsql, ') as tmpone group by accountid ') ;
	  if var_condition='or'  then
			set @TMPSQL_ONE=concat( ' select "系统","LOGPUBLICNOCOMPLETE",now(), ld_account.accountid  from ld_account left join ( ',@sql,' ) as lingdangtmp  on  lingdangtmp.accountid=ld_account.accountid ') ;
		  set @TMPSQL_TWO=concat(@TMPSQL_ONE,' where ld_account.deleted=0 and( ld_account.publicaccount=2 or ld_account.publicaccount=3)  and ifnull(ld_account.completed,"")<>"达成"');
		  set @TMPSQL_TWO=concat(@TMPSQL_TWO, ' and lingdangtmp.accountid is null  and datediff(curdate(),ld_account.allocatedate)>',@maxdays);
	  else
			set @TMPSQL_ONE=concat( ' select "系统","LOGPUBLICNOCOMPLETE",now(), ld_account.accountid  from ld_account inner join ( ',@sql,' ) as lingdangtmp  on  lingdangtmp.accountid=ld_account.accountid ') ;
		  set @TMPSQL_TWO=concat(@TMPSQL_ONE,' where ld_account.deleted=0 and( ld_account.publicaccount=2 or ld_account.publicaccount=3)  and ifnull(ld_account.completed,"")<>"达成"');
		 end if;
	   set @TMPSQL_THREE=concat('insert into ld_logpublicaccount(username,operation,opdate,accountid) ',@TMPSQL_TWO);

		 prepare stmt from @TMPSQL_THREE;
		 execute stmt;
		 deallocate prepare stmt;

			if var_condition='or'  then
				set @TMPSQL_ONE=concat( ' update  ld_account left join ( ',@sql,' ) as lingdangtmp  on  lingdangtmp.accountid=ld_account.accountid set ld_account.publicaccount=1 ,protectdate=null ,allocatedate=null') ;
				set @TMPSQL_TWO=concat(@TMPSQL_ONE,' where ld_account.deleted=0 and( ld_account.publicaccount=2 or ld_account.publicaccount=3)  and ifnull(ld_account.completed,"")<>"达成"  ');
				set @TMPSQL_TWO=concat(@TMPSQL_TWO, ' and lingdangtmp.accountid is null and datediff(curdate(),ld_account.allocatedate)>',@maxdays);
		 else
				set @TMPSQL_ONE=concat( ' update  ld_account inner join ( ',@sql,' ) as lingdangtmp  on  lingdangtmp.accountid=ld_account.accountid set ld_account.publicaccount=1 ,protectdate=null ,allocatedate=null') ;
				set @TMPSQL_TWO=concat(@TMPSQL_ONE,' where ld_account.deleted=0 and( ld_account.publicaccount=2 or ld_account.publicaccount=3)  and ifnull(ld_account.completed,"")<>"达成"  ');
		  end if;
		prepare stmt from @TMPSQL_TWO;
		execute stmt;
		deallocate prepare stmt;
	end if;


end ||
delimiter;


drop PROCEDURE if EXISTS account_complete_recoveryrule;
delimiter ||
create PROCEDURE  account_complete_recoveryrule()
BEGIN

	DECLARE var_tabname varchar(100);
	DECLARE var_columnname varchar(100);
	DECLARE var_tablename varchar(100);
	DECLARE var_condition varchar(50);
	DECLARE var_days int(11);
	DECLARE var_otherwhere varchar(200);
	declare done  int  default 0;

	declare cur1 CURSOR FOR select tabname,ld_account_set_rule.columnname,ld_field.tablename ,`condition`,ld_account_set_rule.days
 ,ld_account_set_rule.otherwhere from ld_account_set_rule  inner join ld_tab on ld_tab.name=ld_account_set_rule.tabname and presence in(0,2)
	INNER JOIN ld_field on ld_field.tabid=ld_tab.tabid and ld_account_set_rule.columnname=ld_field.columnname
	and ld_field.presence in(0,2) where ld_account_set_rule.type='complete' and ld_account_set_rule.`status`='active';
	declare continue handler  for not   found  SET done =1;
	set @tmpint=0;
	set @tmpsql='';
 select max(ld_account_set_rule.days) into @maxdays
  from ld_account_set_rule  inner join ld_tab on ld_tab.name=ld_account_set_rule.tabname and presence in(0,2)
	INNER JOIN ld_field on ld_field.tabid=ld_tab.tabid and ld_account_set_rule.columnname=ld_field.columnname
	and ld_field.presence in(0,2) where ld_account_set_rule.type='complete' and ld_account_set_rule.`status`='active';

	OPEN cur1;

	Fetch cur1 into var_tabname,var_columnname,var_tablename,var_condition,var_days,var_otherwhere;
	loop1: while  done<>1 DO

		  if(var_condition='and' ) then

			set @tmpsqlone =concat("select ld_account.accountid,ld_account.allocatedate from ld_account ");
			set @tmpsqlone=concat(@tmpsqlone," inner join ",var_tablename,' on ',var_tablename,'.accountid=ld_account.accountid ');
			set @tmpsqlone=concat(@tmpsqlone," and  ",var_tablename,'.smownerid=ld_account.smownerid' );

			set @tmpsqlone=concat(@tmpsqlone ,"  where  ",var_tablename,".deleted=0");
		   if var_otherwhere is not null and  var_otherwhere<>'' then
					set @tmpsqlone=concat(@tmpsqlone,var_otherwhere);
				end if;
		  set @tmpsqlone=concat( @tmpsqlone,' group by ld_account.accountid ') ;
		  set @tmpsqlone=concat(@tmpsqlone,"   having datediff(curdate(), case when ld_account.allocatedate> max( " ,var_tablename,'.',var_columnname," )  then ld_account.allocatedate else max( " ,var_tablename,'.',var_columnname," ) end  ) >",var_days);

			set @tmpsqltwo=concat('select ld_account.accountid,ld_account.allocatedate from  ld_account LEFT JOIN(select ld_account.accountid
					from ld_account inner join ',var_tablename,' on ld_account.accountid=',var_tablename,'.accountid
						and ld_account.smownerid=',var_tablename,'.smownerid  where ',var_tablename,'.deleted=0' );

		   if var_otherwhere is not null and  var_otherwhere<>'' then
					set @tmpsqltwo=concat(@tmpsqltwo, var_otherwhere);
				end if;
			set @tmpsqltwo=concat(@tmpsqltwo,' ) 	as ttt_',var_tablename,'  on ld_account.accountid=ttt_',var_tablename,'.accountid   where ttt_',var_tablename,'.accountid is null  ' );
			set @tmpsqltwo=concat(@tmpsqltwo," and datediff(curdate(),ld_account.allocatedate ) >",var_days);

			set @tmpthree=concat( @tmpsqlone,' union all ',@tmpsqltwo);
			set @tmpsql=concat(@tmpsql," select * from ( ",@tmpthree," ) as  tttt_",var_tabname);
			set @tmpsql=concat(@tmpsql,' union all ' );

			elseif (var_condition='or')  then
				set @tmpsql=concat(@tmpsql ,' select ld_account.accountid,ld_account.allocatedate from ld_account inner join '  ,var_tablename,' on ',var_tablename,'.accountid=ld_account.accountid  ');

			  set @tmpsql=concat(@tmpsql,' and ' ,var_tablename,'.smownerid=ld_account.smownerid ' );
				set @tmpsql=concat(@tmpsql,' where  ' , var_tablename,'.deleted=0 ' );
			  if var_otherwhere is not null and  var_otherwhere<>'' then
					set @tmpsql=concat(@tmpsql,var_otherwhere);
				end if;

			  set @tmpsql=concat( @tmpsqlone,' group by ld_account.accountid ') ;
				set @tmpsql=concat(@tmpsql," having    datediff ( curdate(), case when ld_account.allocatedate> max( ",var_tablename,'.',var_columnname," ) then ld_account.allocatedate else max( ",var_tablename,'.',var_columnname," )  end )<=",var_days );


				set @tmpsql=concat(@tmpsql,' union all ' );

			end if;
			set @tmpint=@tmpint+1;
			Fetch cur1 into var_tabname,var_columnname,var_tablename,var_condition,var_days,var_otherwhere;
		end while loop1;
		close cur1;


	if @tmpint>0 then
		set @len=CHAR_LENGTH(' union all ');
		set @tmpsql=left(@tmpsql,CHAR_LENGTH(@tmpsql)-@len);
		set @sql=concat(' select accountid from (',@tmpsql, ') as tmpone group by accountid ') ;


	  if var_condition='or'  then
			set @TMPSQL_ONE=concat( ' select "系统","LOGPUBLICCOMPLETE",now(), ld_account.accountid  from ld_account left join ( ',@sql,' ) as lingdangtmp  on  lingdangtmp.accountid=ld_account.accountid ') ;
			set @TMPSQL_TWO=concat(@TMPSQL_ONE,' where ld_account.deleted=0 and( ld_account.publicaccount=2 or ld_account.publicaccount=3)  and ifnull(ld_account.completed,"")="达成"');
		  set @TMPSQL_TWO=concat(@TMPSQL_TWO, ' and lingdangtmp.accountid is null  and datediff(curdate(),ld_account.allocatedate)>',@maxdays);
		else
			set @TMPSQL_ONE=concat( ' select "系统","LOGPUBLICCOMPLETE",now(), ld_account.accountid  from ld_account inner join ( ',@sql,' ) as lingdangtmp  on  lingdangtmp.accountid=ld_account.accountid ') ;
			set @TMPSQL_TWO=concat(@TMPSQL_ONE,' where ld_account.deleted=0 and( ld_account.publicaccount=2 or ld_account.publicaccount=3)  and ifnull(ld_account.completed,"")="达成"');

		end if;
	   set @TMPSQL_THREE=concat('insert into ld_logpublicaccount(username,operation,opdate,accountid) ',@TMPSQL_TWO);
		 prepare stmt from @TMPSQL_THREE;
		 execute stmt;
		 deallocate prepare stmt;


			if var_condition='or'  then
			set @TMPSQL_ONE=concat( ' update  ld_account left join ( ',@sql,' ) as lingdangtmp  on  lingdangtmp.accountid=ld_account.accountid set ld_account.publicaccount=1 ,protectdate=null ,allocatedate=null') ;
		  set @TMPSQL_TWO=concat(@TMPSQL_ONE,' where ld_account.deleted=0 and( ld_account.publicaccount=2 or ld_account.publicaccount=3)  and ifnull(ld_account.completed,"")="达成"  ');
		  set @TMPSQL_TWO=concat(@TMPSQL_TWO, ' and lingdangtmp.accountid is null and datediff(curdate(),ld_account.allocatedate)>',@maxdays);
			ELSE
			set @TMPSQL_ONE=concat( ' update  ld_account inner join ( ',@sql,' ) as lingdangtmp  on  lingdangtmp.accountid=ld_account.accountid set ld_account.publicaccount=1 ,protectdate=null ,allocatedate=null') ;
		  set @TMPSQL_TWO=concat(@TMPSQL_ONE,' where ld_account.deleted=0 and( ld_account.publicaccount=2 or ld_account.publicaccount=3)  and ifnull(ld_account.completed,"")="达成"  ');
		 end if;
		prepare stmt from @TMPSQL_TWO;
		execute stmt;
		deallocate prepare stmt;

	end if;



end ||
delimiter;

drop PROCEDURE if EXISTS account_normal_recoveryrule;
delimiter ||
create PROCEDURE  account_normal_recoveryrule()
BEGIN

	DECLARE var_tabname varchar(100);
	DECLARE var_columnname varchar(100);
	DECLARE var_tablename varchar(100);
	DECLARE var_condition varchar(50);
	DECLARE var_days int(11);
	DECLARE var_otherwhere varchar(200);
	declare done  int  default 0;

	declare cur1 CURSOR FOR select tabname,ld_account_set_rule.columnname,ld_field.tablename ,`condition`,ld_account_set_rule.days
 ,ld_account_set_rule.otherwhere from ld_account_set_rule  inner join ld_tab on ld_tab.name=ld_account_set_rule.tabname and presence in(0,2)
	INNER JOIN ld_field on ld_field.tabid=ld_tab.tabid and ld_account_set_rule.columnname=ld_field.columnname
	and ld_field.presence in(0,2) where ld_account_set_rule.type='normal' and ld_account_set_rule.`status`='active';
	declare continue handler  for not   found  SET done =1;
	set @tmpint=0;
	set @tmpsql='';
	select max(ld_account_set_rule.days) into @maxdays
  from ld_account_set_rule  inner join ld_tab on ld_tab.name=ld_account_set_rule.tabname and presence in(0,2)
	INNER JOIN ld_field on ld_field.tabid=ld_tab.tabid and ld_account_set_rule.columnname=ld_field.columnname
	and ld_field.presence in(0,2) where ld_account_set_rule.type='normal' and ld_account_set_rule.`status`='active';

	OPEN cur1;

	Fetch cur1 into var_tabname,var_columnname,var_tablename,var_condition,var_days,var_otherwhere;
	loop1: while  done<>1 DO

		  if(var_condition='and' ) then

			set @tmpsqlone =concat("select ld_account.accountid,ld_account.distributiondate,ld_account.createdtime from ld_account ");
			set @tmpsqlone=concat(@tmpsqlone," inner join ",var_tablename,' on ',var_tablename,'.accountid=ld_account.accountid' );
			set @tmpsqltwo=concat(@tmpsqltwo," and  ",var_tablename,'.smownerid=ld_account.smownerid ');

			set @tmpsqlone=concat(@tmpsqlone," where   ",var_tablename,".deleted=0  ");
		   if var_otherwhere is not null and  var_otherwhere<>'' then
					set @tmpsqlone=concat(@tmpsqlone,var_otherwhere);
				end if;
		  set @tmpsqlone=concat( @tmpsqlone,' group by ld_account.accountid ') ;
			set @tmpsqlone=concat(@tmpsqlone,"   having    datediff(curdate(),case when   case when ifnull(ld_account.distributiondate,'')='' then ld_account.createdtime else ld_account.distributiondate end>    max(",var_tablename,'.',var_columnname,") then  case when ifnull(ld_account.distributiondate,'')='' then ld_account.createdtime else ld_account.distributiondate end  else max(",var_tablename,'.',var_columnname,") end  ) >",var_days   );

      set @tmpsqltwo=concat('select ld_account.accountid,ld_account.distributiondate,ld_account.createdtime from  ld_account LEFT JOIN(select ld_account.accountid
					from ld_account inner join ',var_tablename,' on ld_account.accountid=',var_tablename,'.accountid
						and ld_account.smownerid=',var_tablename,'.smownerid  where ',var_tablename,'.deleted=0' );

		   if var_otherwhere is not null and  var_otherwhere<>'' then
					set @tmpsqltwo=concat(@tmpsqltwo, var_otherwhere);
				end if;
			set @tmpsqltwo=concat(@tmpsqltwo,' ) 	as ttt_',var_tablename,'  on ld_account.accountid=ttt_',var_tablename,'.accountid   where ttt_',var_tablename,'.accountid is null  ' );
			set @tmpsqltwo=concat(@tmpsqltwo," and datediff(curdate(),case when ifnull(ld_account.distributiondate,'')='' then ld_account.createdtime else ld_account.distributiondate end ) >",var_days);


			set @tmpthree=concat( @tmpsqlone,' union all ',@tmpsqltwo);
			set @tmpsql=concat(@tmpsql," select * from ( ",@tmpthree," ) as  tttt_",var_tabname);
			set @tmpsql=concat(@tmpsql,' union all ' );

			elseif (var_condition='or')  then
				set @tmpsql=concat(@tmpsql ,' select ld_account.accountid,ld_account.distributiondate,ld_account.createdtime from ld_account inner join '  ,var_tablename,' on ',var_tablename,'.accountid=ld_account.accountid  ');
			  set @tmpsql=concat(@tmpsql,' and ' ,var_tablename,'.smownerid=ld_account.smownerid ' );
				set @tmpsql=concat(@tmpsql,' where  ' , var_tablename,'.deleted=0 ' );
				if var_otherwhere is not null and  var_otherwhere<>'' then
					set @tmpsql=concat(@tmpsql,var_otherwhere);
				end if;
				set @tmpsql=concat(@tmpsql," group by ld_account.accountid ");
				set @tmpsql=concat(@tmpsql," having datediff(curdate(), case when  case when ifnull(ld_account.distributiondate,'')='' then ld_account.createdtime else ld_account.distributiondate end>max( ", var_tablename,'.',var_columnname,") then  case when ifnull(ld_account.distributiondate,'')='' then ld_account.createdtime else ld_account.distributiondate end   else  max( ", var_tablename,'.',var_columnname,") end )<= ",var_days);


				set @tmpsql=concat(@tmpsql,' union all ' );

			end if;
			set @tmpint=@tmpint+1;
			Fetch cur1 into var_tabname,var_columnname,var_tablename,var_condition,var_days,var_otherwhere;
		end while loop1;
		close cur1;


	if @tmpint>0 then
		set @len=CHAR_LENGTH(' union all ');
		set @tmpsql=left(@tmpsql,CHAR_LENGTH(@tmpsql)-@len);
			select @tmpsql;

		set @sql=concat(' select accountid from (',@tmpsql, ') as tmpone group by accountid ') ;


	  if var_condition='or'  then
			set @TMPSQL_ONE=concat( ' select "系统","LOGPUBLICNORMAL",now(), ld_account.accountid  from ld_account left join ( ',@sql,' ) as lingdangtmp  on  lingdangtmp.accountid=ld_account.accountid ') ;
		  set @TMPSQL_TWO=concat(@TMPSQL_ONE,' where ld_account.deleted=0 and( ifnull(ld_account.publicaccount,0)<1)'  );
		  set @TMPSQL_TWO=concat(@TMPSQL_TWO, ' and lingdangtmp.accountid is null  and datediff(curdate(),ld_account.allocatedate)>',@maxdays);
		else
			set @TMPSQL_ONE=concat( ' select "系统","LOGPUBLICNORMAL",now(), ld_account.accountid  from ld_account inner join ( ',@sql,' ) as lingdangtmp  on  lingdangtmp.accountid=ld_account.accountid ') ;
		  set @TMPSQL_TWO=concat(@TMPSQL_ONE,' where ld_account.deleted=0 and( ifnull(ld_account.publicaccount,0)<1)'  );
		 end if;
	   set @TMPSQL_THREE=concat('insert into ld_logpublicaccount(username,operation,opdate,accountid) ',@TMPSQL_TWO);
		 prepare stmt from @TMPSQL_THREE;
		 execute stmt;
		 deallocate prepare stmt;

			if var_condition='or'  then
			  	set @TMPSQL_ONE=concat( ' update  ld_account left join ( ',@sql,' ) as lingdangtmp  on  lingdangtmp.accountid=ld_account.accountid set ld_account.publicaccount=1 ,protectdate=null ,allocatedate=null') ;
		      set @TMPSQL_TWO=concat(@TMPSQL_ONE,' where ld_account.deleted=0 and( ifnull(ld_account.publicaccount,0)<1)    ');
		      set @TMPSQL_TWO=concat(@TMPSQL_TWO, " and lingdangtmp.accountid is null and datediff(curdate(),case when ifnull(ld_account.distributiondate,'')='' then ld_account.createdtime else ld_account.distributiondate end)>",@maxdays);
			ELSE
				set @TMPSQL_ONE=concat( ' update  ld_account inner join ( ',@sql,' ) as lingdangtmp  on  lingdangtmp.accountid=ld_account.accountid set ld_account.publicaccount=1 ,protectdate=null ,allocatedate=null') ;
		    set @TMPSQL_TWO=concat(@TMPSQL_ONE,' where ld_account.deleted=0 and( ifnull(ld_account.publicaccount,0)<1)    ');
     end if;
		prepare stmt from @TMPSQL_TWO;
		execute stmt;
		deallocate prepare stmt;

	end if;

end ||
delimiter;

set global event_scheduler = on;

DROP EVENT IF EXISTS `lingdang_public_account_event`;
CREATE EVENT `lingdang_public_account_event`
ON SCHEDULE EVERY 5  MINUTE STARTS '2016-02-20 00:00:01'
ON COMPLETION NOT PRESERVE
ENABLE
DO
	call execute_account_publicoperation();
delimiter;

CREATE TABLE if not EXISTS`ld_sys_event` (
  `eventdate` datetime DEFAULT NULL,
  `type` varchar(100) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
delimiter;

insert into ld_sys_event(eventdate,type)select '1600-01-01 00:00:00','publicaccount' from dual where not exists(select 1 from ld_sys_event where type='publicaccount');
delimiter;

drop PROCEDURE if EXISTS execute_account_publicoperation;
delimiter ||
create PROCEDURE execute_account_publicoperation()
BEGIN
	select `status` into @status  from ld_account_set;


	if @status=0   then
		select eventdate into @eventdate from ld_sys_event where type='publicaccount' ORDER BY eventdate DESC LIMIT 1;
		if @eventdate!=CURDATE() then
			 update  ld_sys_event set eventdate=now() where type='publicaccount';
				call  account_nocomplete_recoveryrule();
				call  account_complete_recoveryrule();
				call account_normal_recoveryrule();
		end if;

	end if;
end ||
delimiter;


insert into ld_desk (languagetype,labelbol,fieldlabel,labeltype)
select 'zh','LOGPUBLICNOCOMPLETE','公海目标未达成，释放到公海未分配','fixedstr' from dual where not exists(select 1 from ld_desk where labelbol='LOGPUBLICNOCOMPLETE' and Labeltype='fixedstr' and languagetype='zh');
insert into ld_desk (languagetype,labelbol,fieldlabel,labeltype)
select 'en','LOGPUBLICNOCOMPLETE','The target of the high seas has not been reached and released to the high seas.','fixedstr' from dual where not exists(select 1 from ld_desk where labelbol='LOGPUBLICNOCOMPLETE' and Labeltype='fixedstr' and languagetype='en');
delimiter;

insert into ld_desk (languagetype,labelbol,fieldlabel,labeltype)
select 'zh','LOGPUBLICCOMPLETE','公海目标达成后，设置的回收条件未达成，释放到公海未分配','fixedstr' from dual where not exists(select 1 from ld_desk where labelbol='LOGPUBLICCOMPLETE' and Labeltype='fixedstr' and languagetype='zh');
insert into ld_desk (languagetype,labelbol,fieldlabel,labeltype)
select 'en','LOGPUBLICNOCOMPLETE','After the target of the high seas is reached, the conditions for the recovery have not been reached and are undistributed to the high seas.','fixedstr' from dual where not exists(select 1 from ld_desk where labelbol='LOGPUBLICCOMPLETE' and Labeltype='fixedstr' and languagetype='en');
delimiter;

insert into ld_desk (languagetype,labelbol,fieldlabel,labeltype)
select 'zh','LOGPUBLICNORMAL','普通客户参与回收，设置的回收条件未达成，释放到公海未分配','fixedstr' from dual where not exists(select 1 from ld_desk where labelbol='LOGPUBLICNORMAL' and Labeltype='fixedstr' and languagetype='zh');
insert into ld_desk (languagetype,labelbol,fieldlabel,labeltype)
select 'en','LOGPUBLICNORMAL','The general customer is involved in the recovery, the reclaim conditions are not reached, and it is undistributed to the high seas','fixedstr' from dual where not exists(select 1 from ld_desk where labelbol='LOGPUBLICNORMAL' and Labeltype='fixedstr' and languagetype='en');
delimiter;

insert into ld_desk (languagetype,labelbol,fieldlabel,labeltype)
select 'zh','LOGICRELATIONDESCRIPTION','逻辑关系说明：','fixedstr' from dual where not exists(select 1 from ld_desk where labelbol='LOGICRELATIONDESCRIPTION' and Labeltype='fixedstr' and languagetype='zh');
insert into ld_desk (languagetype,labelbol,fieldlabel,labeltype)
select 'en','LOGICRELATIONDESCRIPTION','Logical relation description:','fixedstr' from dual where not exists(select 1 from ld_desk where labelbol='LOGICRELATIONDESCRIPTION' and Labeltype='fixedstr' and languagetype='en');
delimiter;

insert into ld_desk (languagetype,labelbol,fieldlabel,labeltype)
select 'zh','ANDOFSETTING','“且”的设置：','fixedstr' from dual where not exists(select 1 from ld_desk where labelbol='ANDOFSETTING' and Labeltype='fixedstr' and languagetype='zh');
insert into ld_desk (languagetype,labelbol,fieldlabel,labeltype)
select 'en','ANDOFSETTING','The setting of "and":','fixedstr' from dual where not exists(select 1 from ld_desk where labelbol='ANDOFSETTING' and Labeltype='fixedstr' and languagetype='en');
delimiter;

insert into ld_desk (languagetype,labelbol,fieldlabel,labeltype)
select 'zh','ANDWHATRECOVERY','什么情况会回收？勾选的条件只要有一个没有达成；','fixedstr' from dual where not exists(select 1 from ld_desk where labelbol='ANDWHATRECOVERY' and Labeltype='fixedstr' and languagetype='zh');
insert into ld_desk (languagetype,labelbol,fieldlabel,labeltype)
select 'en','ANDWHATRECOVERY','What will be reclaimed? As long as one of the conditions for the election is not reached;','fixedstr' from dual where not exists(select 1 from ld_desk where labelbol='ANDWHATRECOVERY' and Labeltype='fixedstr' and languagetype='en');
delimiter;

insert into ld_desk (languagetype,labelbol,fieldlabel,labeltype)
select 'zh','ANDWHATNOTRECOVERY','什么情况不会回收？所有勾选的条件都达成；','fixedstr' from dual where not exists(select 1 from ld_desk where labelbol='ANDWHATNOTRECOVERY' and Labeltype='fixedstr' and languagetype='zh');
insert into ld_desk (languagetype,labelbol,fieldlabel,labeltype)
select 'en','ANDWHATNOTRECOVERY','What will not be recovered? All the conditions for the election are reached;','fixedstr' from dual where not exists(select 1 from ld_desk where labelbol='ANDWHATNOTRECOVERY' and Labeltype='fixedstr' and languagetype='en');
delimiter;

insert into ld_desk (languagetype,labelbol,fieldlabel,labeltype)
select 'zh','OROFSETTING','“或”的设置：','fixedstr' from dual where not exists(select 1 from ld_desk where labelbol='OROFSETTING' and Labeltype='fixedstr' and languagetype='zh');
insert into ld_desk (languagetype,labelbol,fieldlabel,labeltype)
select 'en','OROFSETTING','The setting of "or":','fixedstr' from dual where not exists(select 1 from ld_desk where labelbol='OROFSETTING' and Labeltype='fixedstr' and languagetype='en');
delimiter;

insert into ld_desk (languagetype,labelbol,fieldlabel,labeltype)
select 'zh','ORWHATRECOVERY','什么情况会回收？所有勾选的条件都没有达成；','fixedstr' from dual where not exists(select 1 from ld_desk where labelbol='ORWHATRECOVERY' and Labeltype='fixedstr' and languagetype='zh');
insert into ld_desk (languagetype,labelbol,fieldlabel,labeltype)
select 'en','ORWHATRECOVERY','What will be reclaimed? All the conditions for the election were not reached','fixedstr' from dual where not exists(select 1 from ld_desk where labelbol='ORWHATRECOVERY' and Labeltype='fixedstr' and languagetype='en');
delimiter;

insert into ld_desk (languagetype,labelbol,fieldlabel,labeltype)
select 'zh','ORWHATNOTRECOVERY','什么情况不会回收？勾选的条件只要有一个达成；','fixedstr' from dual where not exists(select 1 from ld_desk where labelbol='ORWHATNOTRECOVERY' and Labeltype='fixedstr' and languagetype='zh');
insert into ld_desk (languagetype,labelbol,fieldlabel,labeltype)
select 'en','ORWHATNOTRECOVERY','What will not be recovered? As long as there is one condition to be reached','fixedstr' from dual where not exists(select 1 from ld_desk where labelbol='ORWHATNOTRECOVERY' and Labeltype='fixedstr' and languagetype='en');
delimiter;

insert into ld_desk (languagetype,labelbol,fieldlabel ,labeltype)
select  'zh', 'DAYSMUSTGREATERQUZERO',  '天数必须输入大于等于0','jspop' from dual where not exists(select 1 from ld_desk where languagetype='zh' and labeltype='jspopup' and labelbol='DAYSMUSTGREATERQUZERO');
insert into ld_desk (languagetype,labelbol,fieldlabel ,labeltype)
select  'en', 'DAYSMUSTGREATERQUZERO',  'The number of days must be more than or equal to zero','jspop' from dual where not exists(select 1 from ld_desk where languagetype='zh' and labeltype='jspopup' and labelbol='DAYSMUSTGREATERQUZERO');
delimiter;
-- 2018-03-19

SET FOREIGN_KEY_CHECKS=0;
DROP TABLE IF EXISTS com_ld_workflow_activatedonce;
DROP TABLE IF EXISTS com_ld_workflows;
DROP TABLE IF EXISTS com_ld_workflows_seq;
DROP TABLE IF EXISTS com_ld_workflowtask_queue;
DROP TABLE IF EXISTS com_ld_workflowtasks;
DROP TABLE IF EXISTS com_ld_workflowtasks_entitymethod;
DROP TABLE IF EXISTS com_ld_workflowtasks_entitymethod_seq;
DROP TABLE IF EXISTS com_ld_workflowtasks_seq;
DROP TABLE IF EXISTS com_ld_workflowtemplates;
DROP TABLE IF EXISTS ld_account2userview;
DROP TABLE IF EXISTS ld_accountdepstatus;
DROP TABLE IF EXISTS ld_accountownership;
DROP TABLE IF EXISTS ld_activity_view;
DROP TABLE IF EXISTS ld_activity_view_seq;
DROP TABLE IF EXISTS ld_assets;
DROP TABLE IF EXISTS ld_assetscf;
DROP TABLE IF EXISTS ld_assetstatus;
DROP TABLE IF EXISTS ld_assetstatus_seq;
DROP TABLE IF EXISTS ld_asterisk;
DROP TABLE IF EXISTS ld_asteriskextensions;
DROP TABLE IF EXISTS ld_asteriskincomingcalls;
DROP TABLE IF EXISTS ld_asteriskincomingevents;
DROP TABLE IF EXISTS ld_chat_pchat;
DROP TABLE IF EXISTS ld_chat_pvchat;
DROP TABLE IF EXISTS ld_chat_msg;
DROP TABLE IF EXISTS ld_chat_users;
DROP TABLE IF EXISTS ld_cncontactrecordrel;
DROP TABLE IF EXISTS ld_cntactivityrel;
DROP TABLE IF EXISTS ld_code;
DROP TABLE IF EXISTS ld_competitor;
DROP TABLE IF EXISTS ld_contactsubdetails;
DROP TABLE IF EXISTS ld_convertleadmapping;
DROP TABLE IF EXISTS ld_cron_task;
DROP TABLE IF EXISTS ld_currency_decimal_separator;
DROP TABLE IF EXISTS ld_currency_decimal_separator_seq;
DROP TABLE IF EXISTS ld_currency_grouping_pattern;
DROP TABLE IF EXISTS ld_currency_grouping_pattern_seq;
DROP TABLE IF EXISTS ld_currency_grouping_separator;
DROP TABLE IF EXISTS ld_currency_grouping_separator_seq;
DROP TABLE IF EXISTS ld_currency_symbol_placement;
DROP TABLE IF EXISTS ld_currency_symbol_placement_seq;
DROP TABLE IF EXISTS ld_customaction;
DROP TABLE IF EXISTS ld_customerdetails;
DROP TABLE IF EXISTS ld_customerportal_fields;
DROP TABLE IF EXISTS ld_customerportal_prefs;
DROP TABLE IF EXISTS ld_customerportal_tabs;
DROP TABLE IF EXISTS ld_customfield_sequence_seq;
DROP TABLE IF EXISTS ld_date_format;
DROP TABLE IF EXISTS ld_date_format_seq;
DROP TABLE IF EXISTS ld_dealintimation;
DROP TABLE IF EXISTS ld_defaultcv;
DROP TABLE IF EXISTS ld_downloadpurpose;
DROP TABLE IF EXISTS ld_duration_minutes;
DROP TABLE IF EXISTS ld_duration_minutes_seq;
DROP TABLE IF EXISTS ld_durationhrs;
DROP TABLE IF EXISTS ld_durationmins;
DROP TABLE IF EXISTS ld_evaluationstatus;
DROP TABLE IF EXISTS ld_eventhandler_module;
DROP TABLE IF EXISTS ld_eventhandler_module_seq;
DROP TABLE IF EXISTS ld_eventhandlers;
DROP TABLE IF EXISTS ld_eventhandlers_seq;
DROP TABLE IF EXISTS ld_freetagged_objects;
DROP TABLE IF EXISTS ld_freetags;
DROP TABLE IF EXISTS ld_freetags_seq;
DROP TABLE IF EXISTS ld_headers;
DROP TABLE IF EXISTS ld_home_layout;
DROP TABLE IF EXISTS ld_homedashbd;
DROP TABLE IF EXISTS ld_homedefault;
DROP TABLE IF EXISTS ld_homemoduleflds;
DROP TABLE IF EXISTS ld_homemodulename;
DROP TABLE IF EXISTS ld_homereportchart;
DROP TABLE IF EXISTS ld_homemodule;
DROP TABLE IF EXISTS ld_homerss;
DROP TABLE IF EXISTS ld_hotdegree;
DROP TABLE IF EXISTS ld_hotdegree_seq;
DROP TABLE IF EXISTS ld_hottype;
DROP TABLE IF EXISTS ld_hottype_seq;
DROP TABLE IF EXISTS ld_language;
DROP TABLE IF EXISTS ld_language_seq;
DROP TABLE IF EXISTS ld_languagepackage;
DROP TABLE IF EXISTS ld_lar;
DROP TABLE IF EXISTS ld_lead_view;
DROP TABLE IF EXISTS ld_lead_view_seq;
DROP TABLE IF EXISTS ld_leadacctrel;
DROP TABLE IF EXISTS ld_leadaddress;
DROP TABLE IF EXISTS ld_leadcontrel;
DROP TABLE IF EXISTS ld_leadpotrel;
DROP TABLE IF EXISTS ld_leadstage;
DROP TABLE IF EXISTS ld_leadstatus;
DROP TABLE IF EXISTS ld_leadstatus_seq;
DROP TABLE IF EXISTS ld_leadsubdetails;
DROP TABLE IF EXISTS ld_licencekeystatus;
DROP TABLE IF EXISTS ld_mobile_alerts;
DROP TABLE IF EXISTS ld_payment_duration;
DROP TABLE IF EXISTS ld_payment_duration_seq;
DROP TABLE IF EXISTS ld_pbxmanager;
DROP TABLE IF EXISTS ld_pobillads;
DROP TABLE IF EXISTS ld_portal;
DROP TABLE IF EXISTS ld_portalinfo;
DROP TABLE IF EXISTS ld_poshipads;
DROP TABLE IF EXISTS ld_potcompetitorrel;
DROP TABLE IF EXISTS ld_profile2utility;
DROP TABLE IF EXISTS ld_quickactions;
DROP TABLE IF EXISTS ld_quickview;
DROP TABLE IF EXISTS ld_quotesbillads;
DROP TABLE IF EXISTS ld_rss;
DROP TABLE IF EXISTS ld_role2picklist;
DROP TABLE IF EXISTS ld_tmp_read_group_rel_sharing_per;
DROP TABLE IF EXISTS ld_tmp_read_group_sharing_per;
DROP TABLE IF EXISTS ld_tmp_read_user_rel_sharing_per;
DROP TABLE IF EXISTS ld_tmp_read_user_sharing_per;
DROP TABLE IF EXISTS ld_tmp_write_group_rel_sharing_per;
DROP TABLE IF EXISTS ld_tmp_write_group_sharing_per;
DROP TABLE IF EXISTS ld_tmp_write_user_rel_sharing_per;
DROP TABLE IF EXISTS ld_tmp_write_user_sharing_per;
DROP TABLE IF EXISTS ld_tracker;
DROP TABLE IF EXISTS ld_ws_operation;
DROP TABLE IF EXISTS ld_ws_operation_seq;
DROP TABLE IF EXISTS ld_ws_operation_parameters;
DROP TABLE IF EXISTS ld_wsapp;
DROP TABLE IF EXISTS ld_wsapp_handlerdetails;
DROP TABLE IF EXISTS ld_wsapp_handlerdetails;
DROP TABLE IF EXISTS ld_wsapp_queuerecords;
DROP TABLE IF EXISTS ld_wsapp_recordmapping;
DROP TABLE IF EXISTS ld_wsapp_sync_state;
DROP TABLE IF EXISTS tmp_taxformula;

drop table if exists ld_datashare_grp2grp;
drop table if exists ld_datashare_grp2role;
drop table if exists ld_datashare_grp2rs;
drop table if exists ld_datashare_module_rel;
drop table if exists ld_datashare_module_rel_seq;
drop table if exists ld_datashare_relatedmodule_permission;
drop table if exists ld_datashare_relatedmodules;
drop table if exists ld_datashare_relatedmodules_seq;
drop table if exists ld_datashare_role2group;
drop table if exists ld_datashare_role2role;
drop table if exists ld_datashare_role2rs;
drop table if exists ld_datashare_rs2grp;
drop table if exists ld_datashare_rs2role;
drop table if exists ld_datashare_rs2rs;
drop table if exists ld_service;
drop table if exists ld_servicecf;
drop table if exists ld_servicegroup;
drop table if exists ld_reportdatefilter;
drop table if exists ld_reportfilters;
drop table if exists ld_reportfolder;
drop table if exists ld_reportgroupbycolumn;
drop table if exists ld_reportmodules;
drop table if exists ld_reportsharing;
drop table if exists ld_reportsortcol;
drop table if exists ld_reportsummary;
drop table if exists ld_report;

drop table if exists ld_users_last_import;
drop table if exists ld_import_locks;
drop table if exists ld_import_locks_seq;
drop table if exists ld_import_maps;
drop table if exists ld_import_queue;
drop table if exists ld_import_queue_seq;

drop table if EXISTS `ld_group2role`;
drop table if EXISTS `ld_group2grouprel`;
drop table if EXISTS `ld_group2rs`;
drop table if exists `ld_webforms_field`;
drop table if exists `ld_webforms`;
drop table if exists `ld_voucher_log`;
drop table if EXISTS ld_tab_info ;
drop table if EXISTS ld_version_seq;
drop table if exists ld_smsnotifier;
drop table if exists ld_smsnotifer_servers;
drop table if exists ld_smsnotifercf;
drop table if EXISTS ld_user2role;
drop table if EXISTS ld_ws_entity_name;
drop table if EXISTS ld_ws_entity_referencetype;
drop table if EXISTS ld_systems_seq;

SET FOREIGN_KEY_CHECKS=1;
delimiter;

UPDATE ld_picklist_values a
LEFT JOIN ld_picklist_set b ON a.listid = b.listid
SET a.weight=a.scores
WHERE b.listname IN ('servicetype','ticketcategories','projecttasktype')
	AND b.relatetable = 'ld_field'
	AND a.weight IS NULL;

UPDATE ld_picklist_values a
LEFT JOIN ld_picklist_set b ON a.listid = b.listid
SET a.scores=NULL
WHERE b.listname IN ('servicetype','ticketcategories','projecttasktype')
	AND b.relatetable = 'ld_field'
	AND a.weight IS NOT NULL;

update ld_field set displaytype = 2 where fieldname = 'print_times' and displaytype = 3;
delimiter;

select max(wx_sequence) into @wx_sequence from ld_dashboard_app;
insert into ld_dashboard_app(`name`,labelbol,modulenames,image,presence,wx_presence,wx_sequence,kehu001_presence,kehu001_sequence)
select 'AccountsMap','ACCOUNTSMAP','Accounts','dashboard_10',0,1,@wx_sequence+1,0,0
from dual where not exists(select 1 from ld_dashboard_app where name='AccountsMap');
delimiter;

update ld_dashboard_app set presence=0 where id>=12;
delimiter;

select tabid into @tabid from ld_tab where `name`= 'Invoice';
update ld_relatedlists set presence = 1 where tabid = @tabid and `name` = 'get_invoicestatushistory' and related_tabid = 0;
delimiter;

update ld_desk set fieldlabel='天数必须输入大于等于0的整数！' where labelbol='DAYSMUSTGREATERQUZERO' and languagetype='zh' and Labeltype='jspop';
delimiter;
-- 2018-03-20

drop PROCEDURE if EXISTS execute_account_publicoperation;
delimiter ||
create PROCEDURE execute_account_publicoperation
(
)
BEGIN
	select `status` into @status  from ld_account_set;


	if @status=0   then
		select DATE_FORMAT(eventdate,"%Y-%m-%d") into @eventdate from ld_sys_event where type='publicaccount';
		if @eventdate!=CURDATE() then
			 update  ld_sys_event set eventdate=now() where type='publicaccount';
				call  account_nocomplete_recoveryrule();
				call  account_complete_recoveryrule();
				call account_normal_recoveryrule();
		end if;

	end if ;
end||
delimiter;

update ld_account_set_rule set otherwhere=' and ifnull(ld_salesorder.sostatus,"")<>"已作废" ' where tabname='SalesOrder';
update ld_account_set_rule set otherwhere=' and ifnull(ld_servicecontracts.contract_status,"")<>"已作废" ' where tabname='ServiceContracts';
delimiter;
-- 2018-03-21

CREATE TABLE if not exists `ld_publicaccount_remindtableview` (
  `type` varchar(100) DEFAULT NULL,
  `names` text,
  `totalaccounts` int(19) DEFAULT NULL,
  `smownerid` int(19) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
delimiter;

drop PROCEDURE if EXISTS account_nocomplete_recoveryrule;
delimiter ||
create PROCEDURE  account_nocomplete_recoveryrule()
BEGIN

	DECLARE var_tabname varchar(100);
	DECLARE var_columnname varchar(100);
	DECLARE var_tablename varchar(100);
	DECLARE var_condition varchar(50);
	DECLARE var_days int(11);
	DECLARE var_otherwhere varchar(200);

	declare done  int  default 0;

	declare cur1 CURSOR FOR select tabname,ld_account_set_rule.columnname,ld_field.tablename ,`condition`,ld_account_set_rule.days
 ,ld_account_set_rule.otherwhere from ld_account_set_rule  inner join ld_tab on ld_tab.name=ld_account_set_rule.tabname and presence in(0,2)
	INNER JOIN ld_field on ld_field.tabid=ld_tab.tabid and ld_account_set_rule.columnname=ld_field.columnname
	and ld_field.presence in(0,2) where ld_account_set_rule.type='nocomplete' and ld_account_set_rule.`status`='active';
	declare continue handler  for not   found  SET done =1;
	set @tmpint=0;
	set @tmpsql='';
  select max(ld_account_set_rule.days) into @maxdays
  from ld_account_set_rule  inner join ld_tab on ld_tab.name=ld_account_set_rule.tabname and presence in(0,2)
	INNER JOIN ld_field on ld_field.tabid=ld_tab.tabid and ld_account_set_rule.columnname=ld_field.columnname
	and ld_field.presence in(0,2) where ld_account_set_rule.type='nocomplete' and ld_account_set_rule.`status`='active';


	OPEN cur1;

	Fetch cur1 into var_tabname,var_columnname,var_tablename,var_condition,var_days,var_otherwhere;
	loop1: while  done<>1 DO

		  if var_condition='and'  then

			set @tmpsqlone =concat("select ld_account.accountid,ld_account.allocatedate from ld_account ");
			set @tmpsqlone=concat(@tmpsqlone," inner join ",var_tablename,' on ',var_tablename,'.accountid=ld_account.accountid ');
			set @tmpsqlone=concat(@tmpsqlone," and  ",var_tablename,'.smownerid=ld_account.smownerid' );
			set @tmpsqlone=concat(@tmpsqlone," where   ",var_tablename,".deleted=0   ");

		   if var_otherwhere is not null and  var_otherwhere<>'' then
					set @tmpsqlone=concat(@tmpsqlone,var_otherwhere);
				end if;
		  set @tmpsqlone=concat( @tmpsqlone,' group by ld_account.accountid ') ;
			set @tmpsqlone=concat(@tmpsqlone,"  having  datediff(curdate(),case when ld_account.allocatedate>max( ",var_tablename,'.',var_columnname,")   then ld_account.allocatedate else max(",var_tablename,'.',var_columnname,") end  )>",var_days );

			set @tmpsqltwo=concat('select ld_account.accountid,ld_account.allocatedate from  ld_account LEFT JOIN(select ld_account.accountid
					from ld_account inner join ',var_tablename,' on ld_account.accountid=',var_tablename,'.accountid
						and ld_account.smownerid=',var_tablename,'.smownerid  where ',var_tablename,'.deleted=0' );

		   if var_otherwhere is not null and  var_otherwhere<>'' then
					set @tmpsqltwo=concat(@tmpsqltwo, var_otherwhere);
				end if;
			set @tmpsqltwo=concat(@tmpsqltwo,' ) 	as ttt_',var_tablename,'  on ld_account.accountid=ttt_',var_tablename,'.accountid   where ttt_',var_tablename,'.accountid is null  ' );
			set @tmpsqltwo=concat(@tmpsqltwo," and datediff(curdate(),ld_account.allocatedate ) >",var_days);


			set @tmpthree=concat( @tmpsqlone,' union all ',@tmpsqltwo);
			set @tmpsql=concat(@tmpsql," select * from ( ",@tmpthree," ) as  tttt_",var_tabname);
			set @tmpsql=concat(@tmpsql,' union all ' );

			elseif (var_condition='or')  then

				set @tmpsql=concat(@tmpsql ,' select ld_account.accountid,ld_account.allocatedate from ld_account inner join '  ,var_tablename,' on ',var_tablename,'.accountid=ld_account.accountid  ');

			  set @tmpsql=concat(@tmpsql,' and ' ,var_tablename,'.smownerid=ld_account.smownerid ' );
				set @tmpsql=concat(@tmpsql,' where  ' , var_tablename,'.deleted=0 ' );
				if var_otherwhere is not null and  var_otherwhere<>'' then
					set @tmpsql=concat(@tmpsql,var_otherwhere);
				end if;
				set @tmpsql=concat(@tmpsql," group by ld_account.accountid ");

				set @tmpsql=concat(@tmpsql," having    datediff ( curdate(), case when ld_account.allocatedate > max(" , var_tablename,".",var_columnname," ) then ld_account.allocatedate else max(" , var_tablename,".",var_columnname,") end  )<=",var_days );

				set @tmpsql=concat(@tmpsql,' union all ' );

			end if;
			set @tmpint=@tmpint+1;
			Fetch cur1 into var_tabname,var_columnname,var_tablename,var_condition,var_days,var_otherwhere;
		end while loop1;
		close cur1;


	if @tmpint>0 then
		set @len=CHAR_LENGTH(' union all ');

		set @tmpsql=left(@tmpsql,CHAR_LENGTH(@tmpsql)-@len);

		set @sql=concat(' select accountid from (',@tmpsql, ') as tmpone group by accountid ') ;
	  if var_condition='or'  then
			set @TMPSQL_ONE=concat( ' select "系统","LOGPUBLICNOCOMPLETE",now(), ld_account.accountid  from ld_account left join ( ',@sql,' ) as lingdangtmp  on  lingdangtmp.accountid=ld_account.accountid ') ;
		  set @TMPSQL_TWO=concat(@TMPSQL_ONE,' where ld_account.deleted=0 and( ld_account.publicaccount=2 or ld_account.publicaccount=3)  and ifnull(ld_account.completed,"")<>"达成"');
		  set @TMPSQL_TWO=concat(@TMPSQL_TWO, ' and lingdangtmp.accountid is null  and datediff(curdate(),ld_account.allocatedate)>',@maxdays);
	  else
			set @TMPSQL_ONE=concat( ' select "系统","LOGPUBLICNOCOMPLETE",now(), ld_account.accountid  from ld_account inner join ( ',@sql,' ) as lingdangtmp  on  lingdangtmp.accountid=ld_account.accountid ') ;
		  set @TMPSQL_TWO=concat(@TMPSQL_ONE,' where ld_account.deleted=0 and( ld_account.publicaccount=2 or ld_account.publicaccount=3)  and ifnull(ld_account.completed,"")<>"达成"');
		 end if;
	   set @TMPSQL_THREE=concat('insert into ld_logpublicaccount(username,operation,opdate,accountid) ',@TMPSQL_TWO);

		 prepare stmt from @TMPSQL_THREE;
		 execute stmt;
		 deallocate prepare stmt;


		if var_condition='or'  then
			 set @TMPSQL_ONE=concat( ' select "nocomplete" as type, GROUP_CONCAT(accountname,"<br>")as accountnames,count(ld_account.accountid)  as totalaccounts,ld_account.smownerid from    ld_account left join ( ',@sql,' ) as lingdangtmp  on  lingdangtmp.accountid=ld_account.accountid ') ;
		    set @TMPSQL_TWO=concat(@TMPSQL_ONE,' where ld_account.deleted=0 and( ld_account.publicaccount=2 or ld_account.publicaccount=3)  and ifnull(ld_account.completed,"")<>"达成"  ');
				set @TMPSQL_TWO=concat(@TMPSQL_TWO, ' and lingdangtmp.accountid is null and datediff(curdate(),ld_account.allocatedate)>',@maxdays);

		else
			set @TMPSQL_ONE=concat( ' select "nocomplete" as type, GROUP_CONCAT(ld_account.accountname,"<br>")as accountnames,count(ld_account.accountid)  as totalaccounts,ld_account.smownerid from    ld_account  inner join ( ',@sql,' ) as lingdangtmp  on  lingdangtmp.accountid=ld_account.accountid ') ;
		   set @TMPSQL_TWO=concat(@TMPSQL_ONE,' where ld_account.deleted=0 and( ld_account.publicaccount=2 or ld_account.publicaccount=3)  and ifnull(ld_account.completed,"")<>"达成"  ');
		end if;
     delete from ld_publicaccount_remindtableview where type='nocomplete';

     set @tmpthree=concat(" insert into ld_publicaccount_remindtableview(type,names,totalaccounts,smownerid )  ", @TMPSQL_TWO);
		prepare stmt from @tmpthree;
		execute stmt;
		deallocate prepare stmt;
   call crm_publicaccount_recoveryreminds();

			if var_condition='or'  then
				set @TMPSQL_ONE=concat( ' update  ld_account left join ( ',@sql,' ) as lingdangtmp  on  lingdangtmp.accountid=ld_account.accountid set ld_account.publicaccount=1 ,protectdate=null ,allocatedate=null') ;
				set @TMPSQL_TWO=concat(@TMPSQL_ONE,' where ld_account.deleted=0 and( ld_account.publicaccount=2 or ld_account.publicaccount=3)  and ifnull(ld_account.completed,"")<>"达成"  ');
				set @TMPSQL_TWO=concat(@TMPSQL_TWO, ' and lingdangtmp.accountid is null and datediff(curdate(),ld_account.allocatedate)>',@maxdays);
		 else
				set @TMPSQL_ONE=concat( ' update  ld_account inner join ( ',@sql,' ) as lingdangtmp  on  lingdangtmp.accountid=ld_account.accountid set ld_account.publicaccount=1 ,protectdate=null ,allocatedate=null') ;
				set @TMPSQL_TWO=concat(@TMPSQL_ONE,' where ld_account.deleted=0 and( ld_account.publicaccount=2 or ld_account.publicaccount=3)  and ifnull(ld_account.completed,"")<>"达成"  ');
		  end if;
		prepare stmt from @TMPSQL_TWO;
		execute stmt;
		deallocate prepare stmt;
	end if;


end ||
delimiter;


drop PROCEDURE if EXISTS account_complete_recoveryrule;
delimiter ||
create PROCEDURE  account_complete_recoveryrule()
BEGIN

	DECLARE var_tabname varchar(100);
	DECLARE var_columnname varchar(100);
	DECLARE var_tablename varchar(100);
	DECLARE var_condition varchar(50);
	DECLARE var_days int(11);
	DECLARE var_otherwhere varchar(200);
	declare done  int  default 0;

	declare cur1 CURSOR FOR select tabname,ld_account_set_rule.columnname,ld_field.tablename ,`condition`,ld_account_set_rule.days
 ,ld_account_set_rule.otherwhere from ld_account_set_rule  inner join ld_tab on ld_tab.name=ld_account_set_rule.tabname and presence in(0,2)
	INNER JOIN ld_field on ld_field.tabid=ld_tab.tabid and ld_account_set_rule.columnname=ld_field.columnname
	and ld_field.presence in(0,2) where ld_account_set_rule.type='complete' and ld_account_set_rule.`status`='active';
	declare continue handler  for not   found  SET done =1;
	set @tmpint=0;
	set @tmpsql='';
 select max(ld_account_set_rule.days) into @maxdays
  from ld_account_set_rule  inner join ld_tab on ld_tab.name=ld_account_set_rule.tabname and presence in(0,2)
	INNER JOIN ld_field on ld_field.tabid=ld_tab.tabid and ld_account_set_rule.columnname=ld_field.columnname
	and ld_field.presence in(0,2) where ld_account_set_rule.type='complete' and ld_account_set_rule.`status`='active';

	OPEN cur1;

	Fetch cur1 into var_tabname,var_columnname,var_tablename,var_condition,var_days,var_otherwhere;
	loop1: while  done<>1 DO

		  if(var_condition='and' ) then

			set @tmpsqlone =concat("select ld_account.accountid,ld_account.allocatedate from ld_account ");
			set @tmpsqlone=concat(@tmpsqlone," inner join ",var_tablename,' on ',var_tablename,'.accountid=ld_account.accountid ');
			set @tmpsqlone=concat(@tmpsqlone," and  ",var_tablename,'.smownerid=ld_account.smownerid' );

			set @tmpsqlone=concat(@tmpsqlone ,"  where  ",var_tablename,".deleted=0");
		   if var_otherwhere is not null and  var_otherwhere<>'' then
					set @tmpsqlone=concat(@tmpsqlone,var_otherwhere);
				end if;
		  set @tmpsqlone=concat( @tmpsqlone,' group by ld_account.accountid ') ;
		  set @tmpsqlone=concat(@tmpsqlone,"   having datediff(curdate(), case when ld_account.allocatedate> max( " ,var_tablename,'.',var_columnname," )  then ld_account.allocatedate else max( " ,var_tablename,'.',var_columnname," ) end  ) >",var_days);

			set @tmpsqltwo=concat('select ld_account.accountid,ld_account.allocatedate from  ld_account LEFT JOIN(select ld_account.accountid
					from ld_account inner join ',var_tablename,' on ld_account.accountid=',var_tablename,'.accountid
						and ld_account.smownerid=',var_tablename,'.smownerid  where ',var_tablename,'.deleted=0' );

		   if var_otherwhere is not null and  var_otherwhere<>'' then
					set @tmpsqltwo=concat(@tmpsqltwo, var_otherwhere);
				end if;
			set @tmpsqltwo=concat(@tmpsqltwo,' ) 	as ttt_',var_tablename,'  on ld_account.accountid=ttt_',var_tablename,'.accountid   where ttt_',var_tablename,'.accountid is null  ' );
			set @tmpsqltwo=concat(@tmpsqltwo," and datediff(curdate(),ld_account.allocatedate ) >",var_days);

			set @tmpthree=concat( @tmpsqlone,' union all ',@tmpsqltwo);
			set @tmpsql=concat(@tmpsql," select * from ( ",@tmpthree," ) as  tttt_",var_tabname);
			set @tmpsql=concat(@tmpsql,' union all ' );

			elseif (var_condition='or')  then
				set @tmpsql=concat(@tmpsql ,' select ld_account.accountid,ld_account.allocatedate from ld_account inner join '  ,var_tablename,' on ',var_tablename,'.accountid=ld_account.accountid  ');

			  set @tmpsql=concat(@tmpsql,' and ' ,var_tablename,'.smownerid=ld_account.smownerid ' );
				set @tmpsql=concat(@tmpsql,' where  ' , var_tablename,'.deleted=0 ' );
			  if var_otherwhere is not null and  var_otherwhere<>'' then
					set @tmpsql=concat(@tmpsql,var_otherwhere);
				end if;

			  set @tmpsql=concat( @tmpsql,' group by ld_account.accountid ') ;
				set @tmpsql=concat(@tmpsql," having    datediff ( curdate(), case when ld_account.allocatedate> max( ",var_tablename,'.',var_columnname," ) then ld_account.allocatedate else max( ",var_tablename,'.',var_columnname," )  end )<=",var_days );


				set @tmpsql=concat(@tmpsql,' union all ' );

			end if;
			set @tmpint=@tmpint+1;
			Fetch cur1 into var_tabname,var_columnname,var_tablename,var_condition,var_days,var_otherwhere;
		end while loop1;
		close cur1;


	if @tmpint>0 then
		set @len=CHAR_LENGTH(' union all ');
		set @tmpsql=left(@tmpsql,CHAR_LENGTH(@tmpsql)-@len);
		set @sql=concat(' select accountid from (',@tmpsql, ') as tmpone group by accountid ') ;


	  if var_condition='or'  then
			set @TMPSQL_ONE=concat( ' select "系统","LOGPUBLICCOMPLETE",now(), ld_account.accountid  from ld_account left join ( ',@sql,' ) as lingdangtmp  on  lingdangtmp.accountid=ld_account.accountid ') ;
			set @TMPSQL_TWO=concat(@TMPSQL_ONE,' where ld_account.deleted=0 and( ld_account.publicaccount=2 or ld_account.publicaccount=3)  and ifnull(ld_account.completed,"")="达成"');
		  set @TMPSQL_TWO=concat(@TMPSQL_TWO, ' and lingdangtmp.accountid is null  and datediff(curdate(),ld_account.allocatedate)>',@maxdays);
		else
			set @TMPSQL_ONE=concat( ' select "系统","LOGPUBLICCOMPLETE",now(), ld_account.accountid  from ld_account inner join ( ',@sql,' ) as lingdangtmp  on  lingdangtmp.accountid=ld_account.accountid ') ;
			set @TMPSQL_TWO=concat(@TMPSQL_ONE,' where ld_account.deleted=0 and( ld_account.publicaccount=2 or ld_account.publicaccount=3)  and ifnull(ld_account.completed,"")="达成"');

		end if;
	   set @TMPSQL_THREE=concat('insert into ld_logpublicaccount(username,operation,opdate,accountid) ',@TMPSQL_TWO);
		 prepare stmt from @TMPSQL_THREE;
		 execute stmt;
		 deallocate prepare stmt;



   if var_condition='or'  then
			 set @TMPSQL_ONE=concat( ' select "complete" as type, GROUP_CONCAT(accountname,"<br>")as accountnames,count(ld_account.accountid)  as totalaccounts,ld_account.smownerid from    ld_account left join ( ',@sql,' ) as lingdangtmp  on  lingdangtmp.accountid=ld_account.accountid ') ;
		    set @TMPSQL_TWO=concat(@TMPSQL_ONE,' where ld_account.deleted=0 and( ld_account.publicaccount=2 or ld_account.publicaccount=3)  and ifnull(ld_account.completed,"")="达成"  ');
		    set @TMPSQL_TWO=concat(@TMPSQL_TWO, ' and lingdangtmp.accountid is null and datediff(curdate(),ld_account.allocatedate)>',@maxdays);

		else
			set @TMPSQL_ONE=concat( ' select "complete" as type, GROUP_CONCAT(ld_account.accountname,"<br>")as accountnames,count(ld_account.accountid)  as totalaccounts,ld_account.smownerid from    ld_account  inner join ( ',@sql,' ) as lingdangtmp  on  lingdangtmp.accountid=ld_account.accountid ') ;
		    set @TMPSQL_TWO=concat(@TMPSQL_ONE,' where ld_account.deleted=0 and( ld_account.publicaccount=2 or ld_account.publicaccount=3)  and ifnull(ld_account.completed,"")="达成"  ');
		end if;
     delete from ld_publicaccount_remindtableview where type='complete';

     set @tmpthree=concat(" insert into ld_publicaccount_remindtableview(type,names,totalaccounts,smownerid )  ", @TMPSQL_TWO);
		prepare stmt from @tmpthree;
		execute stmt;
		deallocate prepare stmt;
    call crm_publicaccount_recoveryreminds();

	  if var_condition='or'  then
			set @TMPSQL_ONE=concat( ' update  ld_account left join ( ',@sql,' ) as lingdangtmp  on  lingdangtmp.accountid=ld_account.accountid set ld_account.publicaccount=1 ,protectdate=null ,allocatedate=null') ;
		  set @TMPSQL_TWO=concat(@TMPSQL_ONE,' where ld_account.deleted=0 and( ld_account.publicaccount=2 or ld_account.publicaccount=3)  and ifnull(ld_account.completed,"")="达成"  ');
		  set @TMPSQL_TWO=concat(@TMPSQL_TWO, ' and lingdangtmp.accountid is null and datediff(curdate(),ld_account.allocatedate)>',@maxdays);
		ELSE
			set @TMPSQL_ONE=concat( ' update  ld_account inner join ( ',@sql,' ) as lingdangtmp  on  lingdangtmp.accountid=ld_account.accountid set ld_account.publicaccount=1 ,protectdate=null ,allocatedate=null') ;
		  set @TMPSQL_TWO=concat(@TMPSQL_ONE,' where ld_account.deleted=0 and( ld_account.publicaccount=2 or ld_account.publicaccount=3)  and ifnull(ld_account.completed,"")="达成"  ');
		end if;
		prepare stmt from @TMPSQL_TWO;
		execute stmt;
		deallocate prepare stmt;
	end if;



end||
delimiter;

drop PROCEDURE if EXISTS account_normal_recoveryrule;
delimiter ||
create PROCEDURE  account_normal_recoveryrule()
BEGIN

	DECLARE var_tabname varchar(100);
	DECLARE var_columnname varchar(100);
	DECLARE var_tablename varchar(100);
	DECLARE var_condition varchar(50);
	DECLARE var_days int(11);
	DECLARE var_otherwhere varchar(200);
	declare done  int  default 0;

	declare cur1 CURSOR FOR select tabname,ld_account_set_rule.columnname,ld_field.tablename ,`condition`,ld_account_set_rule.days
 ,ld_account_set_rule.otherwhere from ld_account_set_rule  inner join ld_tab on ld_tab.name=ld_account_set_rule.tabname and presence in(0,2)
	INNER JOIN ld_field on ld_field.tabid=ld_tab.tabid and ld_account_set_rule.columnname=ld_field.columnname
	and ld_field.presence in(0,2) where ld_account_set_rule.type='normal' and ld_account_set_rule.`status`='active';
	declare continue handler  for not   found  SET done =1;
	set @tmpint=0;
	set @tmpsql='';
	select max(ld_account_set_rule.days) into @maxdays
  from ld_account_set_rule  inner join ld_tab on ld_tab.name=ld_account_set_rule.tabname and presence in(0,2)
	INNER JOIN ld_field on ld_field.tabid=ld_tab.tabid and ld_account_set_rule.columnname=ld_field.columnname
	and ld_field.presence in(0,2) where ld_account_set_rule.type='normal' and ld_account_set_rule.`status`='active';

	OPEN cur1;

	Fetch cur1 into var_tabname,var_columnname,var_tablename,var_condition,var_days,var_otherwhere;
	loop1: while  done<>1 DO

		  if(var_condition='and' ) then

			set @tmpsqlone =concat("select ld_account.accountid,ld_account.distributiondate,ld_account.createdtime from ld_account ");
			set @tmpsqlone=concat(@tmpsqlone," inner join ",var_tablename,' on ',var_tablename,'.accountid=ld_account.accountid' );
			set @tmpsqltwo=concat(@tmpsqltwo," and  ",var_tablename,'.smownerid=ld_account.smownerid ');

			set @tmpsqlone=concat(@tmpsqlone," where   ",var_tablename,".deleted=0  ");
		   if var_otherwhere is not null and  var_otherwhere<>'' then
					set @tmpsqlone=concat(@tmpsqlone,var_otherwhere);
				end if;
		  set @tmpsqlone=concat( @tmpsqlone,' group by ld_account.accountid ') ;
			set @tmpsqlone=concat(@tmpsqlone,"   having    datediff(curdate(),case when   case when ifnull(ld_account.distributiondate,'')='' then ld_account.createdtime else ld_account.distributiondate end>    max(",var_tablename,'.',var_columnname,") then  case when ifnull(ld_account.distributiondate,'')='' then ld_account.createdtime else ld_account.distributiondate end  else max(",var_tablename,'.',var_columnname,") end  ) >",var_days   );

      set @tmpsqltwo=concat('select ld_account.accountid,ld_account.distributiondate,ld_account.createdtime from  ld_account LEFT JOIN(select ld_account.accountid
					from ld_account inner join ',var_tablename,' on ld_account.accountid=',var_tablename,'.accountid
						and ld_account.smownerid=',var_tablename,'.smownerid  where ',var_tablename,'.deleted=0' );

		   if var_otherwhere is not null and  var_otherwhere<>'' then
					set @tmpsqltwo=concat(@tmpsqltwo, var_otherwhere);
				end if;
			set @tmpsqltwo=concat(@tmpsqltwo,' ) 	as ttt_',var_tablename,'  on ld_account.accountid=ttt_',var_tablename,'.accountid   where ttt_',var_tablename,'.accountid is null  ' );
			set @tmpsqltwo=concat(@tmpsqltwo," and datediff(curdate(),case when ifnull(ld_account.distributiondate,'')='' then ld_account.createdtime else ld_account.distributiondate end ) >",var_days);


			set @tmpthree=concat( @tmpsqlone,' union all ',@tmpsqltwo);
			set @tmpsql=concat(@tmpsql," select * from ( ",@tmpthree," ) as  tttt_",var_tabname);
			set @tmpsql=concat(@tmpsql,' union all ' );

			elseif (var_condition='or')  then
				set @tmpsql=concat(@tmpsql ,' select ld_account.accountid,ld_account.distributiondate,ld_account.createdtime from ld_account inner join '  ,var_tablename,' on ',var_tablename,'.accountid=ld_account.accountid  ');
			  set @tmpsql=concat(@tmpsql,' and ' ,var_tablename,'.smownerid=ld_account.smownerid ' );
				set @tmpsql=concat(@tmpsql,' where  ' , var_tablename,'.deleted=0 ' );
				if var_otherwhere is not null and  var_otherwhere<>'' then
					set @tmpsql=concat(@tmpsql,var_otherwhere);
				end if;
				set @tmpsql=concat(@tmpsql," group by ld_account.accountid ");
				set @tmpsql=concat(@tmpsql," having datediff(curdate(), case when  case when ifnull(ld_account.distributiondate,'')='' then ld_account.createdtime else ld_account.distributiondate end>max( ", var_tablename,'.',var_columnname,") then  case when ifnull(ld_account.distributiondate,'')='' then ld_account.createdtime else ld_account.distributiondate end   else  max( ", var_tablename,'.',var_columnname,") end )<= ",var_days);


				set @tmpsql=concat(@tmpsql,' union all ' );

			end if;
			set @tmpint=@tmpint+1;
			Fetch cur1 into var_tabname,var_columnname,var_tablename,var_condition,var_days,var_otherwhere;
		end while loop1;
		close cur1;


	if @tmpint>0 then
		set @len=CHAR_LENGTH(' union all ');
		set @tmpsql=left(@tmpsql,CHAR_LENGTH(@tmpsql)-@len);
			select @tmpsql;

		set @sql=concat(' select accountid from (',@tmpsql, ') as tmpone group by accountid ') ;


	  if var_condition='or'  then
			set @TMPSQL_ONE=concat( ' select "系统","LOGPUBLICNORMAL",now(), ld_account.accountid  from ld_account left join ( ',@sql,' ) as lingdangtmp  on  lingdangtmp.accountid=ld_account.accountid ') ;
		  set @TMPSQL_TWO=concat(@TMPSQL_ONE,' where ld_account.deleted=0 and( ifnull(ld_account.publicaccount,0)<1)'  );
		  set @TMPSQL_TWO=concat(@TMPSQL_TWO, " and lingdangtmp.accountid is null  and datediff(curdate(),case when ifnull(ld_account.distributiondate,'')='' then ld_account.createdtime else ld_account.distributiondate end)>",@maxdays);
		else
			set @TMPSQL_ONE=concat( ' select "系统","LOGPUBLICNORMAL",now(), ld_account.accountid  from ld_account inner join ( ',@sql,' ) as lingdangtmp  on  lingdangtmp.accountid=ld_account.accountid ') ;
		  set @TMPSQL_TWO=concat(@TMPSQL_ONE,' where ld_account.deleted=0 and( ifnull(ld_account.publicaccount,0)<1)'  );
		 end if;
	   set @TMPSQL_THREE=concat('insert into ld_logpublicaccount(username,operation,opdate,accountid) ',@TMPSQL_TWO);
		 prepare stmt from @TMPSQL_THREE;
		 execute stmt;
		 deallocate prepare stmt;



		if var_condition='or'  then
			 set @TMPSQL_ONE=concat( ' select "normal" as type, GROUP_CONCAT(accountname,"<br>")as accountnames,count(ld_account.accountid)  as totalaccounts,ld_account.smownerid from    ld_account left join ( ',@sql,' ) as lingdangtmp  on  lingdangtmp.accountid=ld_account.accountid ') ;
		   set @TMPSQL_TWO=concat(@TMPSQL_ONE,' where ld_account.deleted=0 and( ifnull(ld_account.publicaccount,0)<1)    ');
		   set @TMPSQL_TWO=concat(@TMPSQL_TWO, " and lingdangtmp.accountid is null and datediff(curdate(),case when ifnull(ld_account.distributiondate,'')='' then ld_account.createdtime else ld_account.distributiondate end)>",@maxdays);

		else
			set @TMPSQL_ONE=concat( ' select "normal" as type, GROUP_CONCAT(ld_account.accountname,"<br>")as accountnames,count(ld_account.accountid)  as totalaccounts,ld_account.smownerid from    ld_account  inner join ( ',@sql,' ) as lingdangtmp  on  lingdangtmp.accountid=ld_account.accountid ') ;
		   set @TMPSQL_TWO=concat(@TMPSQL_ONE,' where ld_account.deleted=0 and( ifnull(ld_account.publicaccount,0)<1)     ');
		end if;
     delete from ld_publicaccount_remindtableview where type='normal';

     set @tmpthree=concat(" insert into ld_publicaccount_remindtableview(type,names,totalaccounts,smownerid )  ", @TMPSQL_TWO);
		prepare stmt from @tmpthree;
		execute stmt;
		deallocate prepare stmt;

   call crm_publicaccount_recoveryreminds();


		if var_condition='or'  then
			  	set @TMPSQL_ONE=concat( ' update  ld_account left join ( ',@sql,' ) as lingdangtmp  on  lingdangtmp.accountid=ld_account.accountid set ld_account.publicaccount=1 ,protectdate=null ,allocatedate=null') ;
		      set @TMPSQL_TWO=concat(@TMPSQL_ONE,' where ld_account.deleted=0 and( ifnull(ld_account.publicaccount,0)<1)    ');
		      set @TMPSQL_TWO=concat(@TMPSQL_TWO, " and lingdangtmp.accountid is null and datediff(curdate(),case when ifnull(ld_account.distributiondate,'')='' then ld_account.createdtime else ld_account.distributiondate end)>",@maxdays);
			ELSE
				set @TMPSQL_ONE=concat( ' update  ld_account inner join ( ',@sql,' ) as lingdangtmp  on  lingdangtmp.accountid=ld_account.accountid set ld_account.publicaccount=1 ,protectdate=null ,allocatedate=null') ;
		    set @TMPSQL_TWO=concat(@TMPSQL_ONE,' where ld_account.deleted=0 and( ifnull(ld_account.publicaccount,0)<1)    ');
     end if;
		prepare stmt from @TMPSQL_TWO;
		execute stmt;
		deallocate prepare stmt;

	end if;

end ||
delimiter;


drop PROCEDURE if EXISTS crm_publicaccount_recoveryreminds;
delimiter ||
create PROCEDURE crm_publicaccount_recoveryreminds(
)
BEGIN
	declare var_type varchar(100);
	DECLARE var_accountnames text;
	DECLARE var_totalaccounts int(19);
	declare var_smownerid int(19);
	declare done  int  default 0;

   declare cur1 CURSOR FOR select * from ld_publicaccount_remindtableview;
	 declare continue handler  for not   found  SET done =1;
	 OPEN cur1;

	 Fetch cur1 into var_type, var_accountnames,var_totalaccounts,var_smownerid;
	 loop1: while  done<>1 DO
		if var_totalaccounts>0 then
			if var_type='normal' THEN
			 set @tmpcontent=concat("您有",var_totalaccounts,"条普通客户未达成目标，回收到公海池。客户名称如下：<br>",var_accountnames);
				call ldcrm_add_reminder(@tmpcontent,var_smownerid,'',0);
			elseif var_type='complete' THEN
				 set @tmpcontent=concat("您有",var_totalaccounts,"条公海客户达成条件后未达成目标，回收到公海池。客户名称如下：<br>",var_accountnames);
				call ldcrm_add_reminder(@tmpcontent,var_smownerid,'',0);
			else
				 set @tmpcontent=concat("您有",var_totalaccounts,"条公海客户未达成公海目标，回收到公海池。客户名称如下：<br>",var_accountnames);
				 call ldcrm_add_reminder(@tmpcontent,var_smownerid,'',0);
			end if;
	end if;
   Fetch cur1 into var_type, var_accountnames,var_totalaccounts,var_smownerid;
	end while loop1;
	close cur1;

end ||
delimiter;


insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','associateddocuments','关联单据：','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype = 'zh' and labelbol = 'associateddocuments' and labeltype = 'fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','associateddocuments','Associated documents:','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype = 'en' and labelbol = 'associateddocuments' and labeltype = 'fixedstr');
delimiter;


insert into ld_desk (languagetype,labelbol,fieldlabel,labeltype)
select 'zh', 'ATLEASTONECONDITIONSENABLED', '至少启用1个条件','jspop' from dual
where not EXISTS(select 1 from ld_desk where languagetype='zh' and labelbol='ATLEASTONECONDITIONSENABLED' and Labeltype='jspop');
insert into ld_desk (languagetype,labelbol,fieldlabel,labeltype)
select 'en', 'ATLEASTONECONDITIONSENABLED', 'At least 1 conditions are enabled','jspop' from dual
where not EXISTS(select 1 from ld_desk where languagetype='en' and labelbol='ATLEASTONECONDITIONSENABLED' and Labeltype='jspop');
delimiter;
select tabid into @tabid  from ld_tab  where name='servicecharge';
select block into @block from ld_field where tabid=@tabid and  columnname='accountname';
update ld_field set block=@block where tabid=@tabid and columnname='currentapprover'  and block is null;
delimiter;
SET GLOBAL table_open_cache=128;
SET GLOBAL table_definition_cache=400;

DROP PROCEDURE if EXISTS addlastapprovetimecolumn;
delimiter ||
CREATE PROCEDURE  addlastapprovetimecolumn()
BEGIN


	DECLARE var_tablename varchar(100);
  DECLARE var_tabid int(19);
	DECLARE var_presence int(10);
	DECLARE var_block int(19);
	DECLARE var_sequence int(19);
	DECLARE var_displaytype int(10);

	declare done  int  default 0;

	declare cur1 CURSOR FOR select tablename,tabid,presence,displaytype,block,sequence from ld_field   where  columnname='currentapprover' and tabid!=29;
	declare continue handler  for not   found  SET done =1;



	IF NOT EXISTS (SELECT 1 FROM ld_field WHERE tabid IN (2,4,6) AND columnname='approvetime') THEN

		OPEN cur1;
		Fetch cur1 into var_tablename,var_tabid,var_presence,var_displaytype,var_block,var_sequence;
		loop1: while  done<>1 DO
				CALL AddColumn(var_tablename,'approvetime','datetime',12,0);
				set @tmpsql=" update ld_field set sequence=sequence+1  where tabid= ";
				set @tmpsql=concat(@tmpsql,var_tabid,' and block=',var_block, ' and sequence>',var_sequence);
				prepare stmt from @tmpsql;
				execute stmt;
				deallocate prepare stmt;

			 select max(fieldid) into @maxfieldid from ld_field;
			 set @tmpsqlone=concat("insert into ld_field  (tabid,fieldid,columnname,allowhide,tablename,generatedtype,uitype,fieldname,fieldlabel,readonly,presence,defaultvalue,sequence,block,displaytype,typeofdata)"," select ");
			 set @tmpsqlone=concat(@tmpsqlone ,var_tabid,',',@maxfieldid+1,",'approvetime','yes',","'",var_tablename,"' ,",1,',',70,",'approvetime','最新审批时间',",1,",",var_presence,",'',",var_sequence+1,",",var_block,",",var_displaytype,",'DT~O' from dual " );
			 set @tmpsqlone=concat(@tmpsqlone," where not exists(select 1 from ld_field where tabid=",var_tabid," and columnname='approvetime')");
			 prepare stmt from @tmpsqlone;
			 execute stmt;
			 deallocate prepare stmt;

			 select fieldid into @fieldid from ld_field where tabid=var_tabid and columnname='approvetime';

			 set @tmpsqltwo="insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)";
			 set @tmpsqltwo=concat(@tmpsqltwo,"select 'zh','ld_field',",var_tabid,",",@fieldid,",'最新审批时间' from dual ");
			 set @tmpsqltwo=concat(@tmpsqltwo," where not EXISTS(select 1 from ld_tranlabel where languagetype='zh' and trantable='ld_field' and relateid=",@fieldid," and tabid=",var_tabid,")");
			 prepare stmt from @tmpsqltwo;
			 execute stmt;
			 deallocate prepare stmt;


			 set @tmpsqltwo="insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)";
			 set @tmpsqltwo=concat(@tmpsqltwo,"select 'en','ld_field',",var_tabid,",",@fieldid,",'Last approval time' from dual ");
			 set @tmpsqltwo=concat(@tmpsqltwo," where not EXISTS(select 1 from ld_tranlabel where languagetype='en' and trantable='ld_field' and relateid=",@fieldid," and tabid=",var_tabid,")");
			 prepare stmt from @tmpsqltwo;
			 execute stmt;
			 deallocate prepare stmt;

			select entityidfield into @entityidfieldid from ld_entityname INNER JOIN ld_tab  on ld_tab.name=ld_entityname.modulename
			 where ld_tab.tabid=var_tabid;
			if var_tabid=16 or var_tabid=9 THEN
				set @entityidfieldid="activityid";
			end if;

			set @tmpthree=concat(" update ", var_tablename," INNER JOIN (	select max(createdtime) as maxtime,crmid from ld_approvelog  GROUP BY crmid) as tmp ");
			set @tmpthree=concat(@tmpthree," on tmp.crmid=",var_tablename,".",@entityidfieldid);
			set @tmpthree=concat(@tmpthree," set ", var_tablename,".approvetime=tmp.maxtime ");
			prepare stmt from @tmpthree;
			 execute stmt;
			 deallocate prepare stmt;

			Fetch cur1 into var_tablename,var_tabid,var_presence,var_displaytype,var_block,var_sequence;
		end while loop1;
		close cur1;
	END IF;
end ||
delimiter;

call addlastapprovetimecolumn();
delimiter;

DROP PROCEDURE if EXISTS addlastapprovetimecolumn;

update ld_field set uitype=71 where tablename='ld_businessapply' and fieldname in ('budget','preparemoney');
delimiter;

select tabid into @tabid from ld_tab where `name` = 'Quotes';
select tabid into @related_tabid from ld_tab where `name` = 'PurchaseInquiryOrder';
select sequence into @sequence from ld_relatedlists where tabid = @tabid and label = 'ServiceContracts';
update ld_relatedlists set sequence = sequence + 1000 where tabid  =@tabid and sequence > @sequence;
select max(relation_id) into @relation_id from ld_relatedlists;
insert into ld_relatedlists(relation_id,tabid,related_tabid,`name`,sequence,label,presence,actions,mobile_presence,type,related_coltable,wx_presence)
select @relation_id+1,@tabid,@related_tabid,'get_purchaseinquiryorder',@sequence+1,'PurchaseInquiryOrder',0,'add',1,'datacategory_sql','inventoryproductrel.entitytypeid',1 from DUAL
where not exists(select 1 from ld_relatedlists where tabid = @tabid and related_tabid = @related_tabid);
set @i=0;
update ld_relatedlists set sequence=(@i:=@i+1) where tabid = @tabid order by sequence;
delimiter;

select tabid into @tabid from ld_tab where `name` = 'PurchaseInquiryOrder';
select max(producttoolfieldid) into @producttoolfieldid from ld_producttoolfield;
select sequence into @sequence from ld_producttoolfield where tabid = @tabid and columnname = 'quantity';
update ld_producttoolfield set sequence = sequence + 1000 where tabid = @tabid and sequence >= @sequence;
insert into ld_producttoolfield(producttoolfieldid,columnname,allowhide,fieldlabel,presence,uitype,typeofdata,sequence,tabid,tablename,width,edit_permission,input_type,fieldid,newline,defaultcolumn,is_checkimportfield,nullfield)
select @producttoolfieldid+1,'entitytype','no','源单类型',0,204,'V~O~100',@sequence+1,@tabid,'ld_inventoryproductrel',22,1,0,0,0,4,0,1 from DUAL
where not exists(select 1 from ld_producttoolfield where tabid = @tabid and columnname = 'entitytype');
insert into ld_producttoolfield(producttoolfieldid,columnname,allowhide,fieldlabel,presence,uitype,typeofdata,sequence,tabid,tablename,width,edit_permission,input_type,fieldid,newline,defaultcolumn,is_checkimportfield,nullfield)
select @producttoolfieldid+2,'entitytypeid','no','源单',0,201,'V~O~100',@sequence+2,@tabid,'ld_inventoryproductrel',22,1,0,0,0,3,0,1 from DUAL
where not exists(select 1 from ld_producttoolfield where tabid = @tabid and columnname = 'entitytypeid');
delimiter;

select tabid into @tabid from ld_tab where `name` = 'PurchaseInquiryOrder';
select producttoolfieldid into @producttoolfieldid from ld_producttoolfield where tabid = @tabid and columnname = 'entitytype';
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'zh','ld_producttoolfield',@tabid,@producttoolfieldid,'源单类型' from DUAL
where not exists(select 1 from ld_tranlabel where tabid = @tabid and relateid = @producttoolfieldid and languagetype = 'zh');
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'en','ld_producttoolfield',@tabid,@producttoolfieldid,'Sourcemodule type' from DUAL
where not exists(select 1 from ld_tranlabel where tabid = @tabid and relateid = @producttoolfieldid and languagetype = 'en');
delimiter;

select tabid into @tabid from ld_tab where `name` = 'PurchaseInquiryOrder';
select producttoolfieldid into @producttoolfieldid from ld_producttoolfield where tabid = @tabid and columnname = 'entitytypeid';
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'zh','ld_producttoolfield',@tabid,@producttoolfieldid,'源单' from DUAL
where not exists(select 1 from ld_tranlabel where tabid = @tabid and relateid = @producttoolfieldid and languagetype = 'zh');
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'en','ld_producttoolfield',@tabid,@producttoolfieldid,'Sourcemodule' from DUAL
where not exists(select 1 from ld_tranlabel where tabid = @tabid and relateid = @producttoolfieldid and languagetype = 'en');
delimiter;

update ld_desk set fieldlabel='The target of the high seas has not been reached and released to the high seas.' where labelbol='LOGPUBLICNOCOMPLETE' and languagetype='en' and Labeltype='fixedstr';
update ld_desk set fieldlabel='After the target of the high seas is reached, the conditions for the recovery have not been reached and are undistributed to the high seas.' where labelbol='LOGPUBLICCOMPLETE' and languagetype='en' and Labeltype='fixedstr';
update ld_desk set fieldlabel='The general customer is involved in the recovery, the reclaim conditions are not reached, and it is undistributed to the high seas.' where labelbol='LOGPUBLICNORMAL' and languagetype='en' and Labeltype='fixedstr';
delimiter;

update ld_field set displaytype = 2 where columnname = 'approvestatus' and uitype != 15;
delimiter;
-- 2018-03-22

UPDATE ld_wx_config SET time_interval=25 WHERE id=1 AND time_interval<25;

drop PROCEDURE if EXISTS account_nocomplete_recoveryrule;
delimiter ||
create PROCEDURE  account_nocomplete_recoveryrule()
BEGIN

	DECLARE var_tabname varchar(100);
	DECLARE var_columnname varchar(100);
	DECLARE var_tablename varchar(100);
	DECLARE var_condition varchar(50);
	DECLARE var_days int(11);
	DECLARE var_otherwhere varchar(200);

	declare done  int  default 0;

	declare cur1 CURSOR FOR select tabname,ld_account_set_rule.columnname,ld_field.tablename ,`condition`,ld_account_set_rule.days
 ,ld_account_set_rule.otherwhere from ld_account_set_rule  inner join ld_tab on ld_tab.name=ld_account_set_rule.tabname and presence in(0,2)
	INNER JOIN ld_field on ld_field.tabid=ld_tab.tabid and ld_account_set_rule.columnname=ld_field.columnname
	and ld_field.presence in(0,2) where ld_account_set_rule.type='nocomplete' and ld_account_set_rule.`status`='active';
	declare continue handler  for not   found  SET done =1;
	set @tmpint=0;
	set @tmpsql='';
  select max(ld_account_set_rule.days) into @maxdays
  from ld_account_set_rule  inner join ld_tab on ld_tab.name=ld_account_set_rule.tabname and presence in(0,2)
	INNER JOIN ld_field on ld_field.tabid=ld_tab.tabid and ld_account_set_rule.columnname=ld_field.columnname
	and ld_field.presence in(0,2) where ld_account_set_rule.type='nocomplete' and ld_account_set_rule.`status`='active';

  select allotaccount into @allotaccount from ld_account_set ;
	OPEN cur1;

	Fetch cur1 into var_tabname,var_columnname,var_tablename,var_condition,var_days,var_otherwhere;
	loop1: while  done<>1 DO

		  if var_condition='and'  then

			set @tmpsqlone =concat("select ld_account.accountid,ld_account.allocatedate from ld_account ");
			set @tmpsqlone=concat(@tmpsqlone," inner join ",var_tablename,' on ',var_tablename,'.accountid=ld_account.accountid ');
			set @tmpsqlone=concat(@tmpsqlone," and  ",var_tablename,'.smownerid=ld_account.smownerid' );
			set @tmpsqlone=concat(@tmpsqlone," where   ",var_tablename,".deleted=0   ");

		   if var_otherwhere is not null and  var_otherwhere<>'' then
					set @tmpsqlone=concat(@tmpsqlone,var_otherwhere);
				end if;
		  set @tmpsqlone=concat( @tmpsqlone,' group by ld_account.accountid ') ;
			set @tmpsqlone=concat(@tmpsqlone,"  having  datediff(curdate(),case when ld_account.allocatedate>max( ",var_tablename,'.',var_columnname,")   then ld_account.allocatedate else max(",var_tablename,'.',var_columnname,") end  )>",var_days );

			set @tmpsqltwo=concat('select ld_account.accountid,ld_account.allocatedate from  ld_account LEFT JOIN(select ld_account.accountid
					from ld_account inner join ',var_tablename,' on ld_account.accountid=',var_tablename,'.accountid
						and ld_account.smownerid=',var_tablename,'.smownerid  where ',var_tablename,'.deleted=0' );

		   if var_otherwhere is not null and  var_otherwhere<>'' then
					set @tmpsqltwo=concat(@tmpsqltwo, var_otherwhere);
				end if;
			set @tmpsqltwo=concat(@tmpsqltwo,' ) 	as ttt_',var_tablename,'  on ld_account.accountid=ttt_',var_tablename,'.accountid   where ttt_',var_tablename,'.accountid is null  ' );
			set @tmpsqltwo=concat(@tmpsqltwo," and datediff(curdate(),ld_account.allocatedate ) >",var_days);


			set @tmpthree=concat( @tmpsqlone,' union all ',@tmpsqltwo);
			set @tmpsql=concat(@tmpsql," select * from ( ",@tmpthree," ) as  tttt_",var_tabname);
			set @tmpsql=concat(@tmpsql,' union all ' );

			elseif (var_condition='or')  then

				set @tmpsql=concat(@tmpsql ,' select ld_account.accountid,ld_account.allocatedate from ld_account inner join '  ,var_tablename,' on ',var_tablename,'.accountid=ld_account.accountid  ');

			  set @tmpsql=concat(@tmpsql,' and ' ,var_tablename,'.smownerid=ld_account.smownerid ' );
				set @tmpsql=concat(@tmpsql,' where  ' , var_tablename,'.deleted=0 ' );
				if var_otherwhere is not null and  var_otherwhere<>'' then
					set @tmpsql=concat(@tmpsql,var_otherwhere);
				end if;
				set @tmpsql=concat(@tmpsql," group by ld_account.accountid ");

				set @tmpsql=concat(@tmpsql," having    datediff ( curdate(), case when ld_account.allocatedate > max(" , var_tablename,".",var_columnname," ) then ld_account.allocatedate else max(" , var_tablename,".",var_columnname,") end  )<=",var_days );

				set @tmpsql=concat(@tmpsql,' union all ' );

			end if;
			set @tmpint=@tmpint+1;
			Fetch cur1 into var_tabname,var_columnname,var_tablename,var_condition,var_days,var_otherwhere;
		end while loop1;
		close cur1;


	if @tmpint>0 then
		set @len=CHAR_LENGTH(' union all ');

		set @tmpsql=left(@tmpsql,CHAR_LENGTH(@tmpsql)-@len);

		set @sql=concat(' select accountid from (',@tmpsql, ') as tmpone group by accountid ') ;
	  if var_condition='or'  then
			set @TMPSQL_ONE=concat( ' select "系统","LOGPUBLICNOCOMPLETE",now(), ld_account.accountid  from ld_account left join ( ',@sql,' ) as lingdangtmp  on  lingdangtmp.accountid=ld_account.accountid ') ;
		  set @TMPSQL_TWO=concat(@TMPSQL_ONE,' where ld_account.deleted=0 and( ld_account.publicaccount=2 or ld_account.publicaccount=3)  and ifnull(ld_account.completed,"")<>"达成"');
		  set @TMPSQL_TWO=concat(@TMPSQL_TWO, ' and lingdangtmp.accountid is null  and datediff(curdate(),ld_account.allocatedate)>',@maxdays);
	  else
			set @TMPSQL_ONE=concat( ' select "系统","LOGPUBLICNOCOMPLETE",now(), ld_account.accountid  from ld_account inner join ( ',@sql,' ) as lingdangtmp  on  lingdangtmp.accountid=ld_account.accountid ') ;
		  set @TMPSQL_TWO=concat(@TMPSQL_ONE,' where ld_account.deleted=0 and( ld_account.publicaccount=2 or ld_account.publicaccount=3)  and ifnull(ld_account.completed,"")<>"达成"');
		 end if;
	   set @TMPSQL_THREE=concat('insert into ld_logpublicaccount(username,operation,opdate,accountid) ',@TMPSQL_TWO);

		 prepare stmt from @TMPSQL_THREE;
		 execute stmt;
		 deallocate prepare stmt;

			if var_condition='or'  then
				set @TMPSQL_ONE=concat( ' update  ld_account left join ( ',@sql,' ) as lingdangtmp  on  lingdangtmp.accountid=ld_account.accountid set ld_account.publicaccount=1 ,protectdate=null ,allocatedate=null') ;
				if @allotaccount>0 THEN
					set @TMPSQL_ONE=concat(@TMPSQL_ONE,",smownerid=",@allotaccount);
				end if;
				set @TMPSQL_TWO=concat(@TMPSQL_ONE,' where ld_account.deleted=0 and( ld_account.publicaccount=2 or ld_account.publicaccount=3)  and ifnull(ld_account.completed,"")<>"达成"  ');
				set @TMPSQL_TWO=concat(@TMPSQL_TWO, ' and lingdangtmp.accountid is null and datediff(curdate(),ld_account.allocatedate)>',@maxdays);
		 else
				set @TMPSQL_ONE=concat( ' update  ld_account inner join ( ',@sql,' ) as lingdangtmp  on  lingdangtmp.accountid=ld_account.accountid set ld_account.publicaccount=1 ,protectdate=null ,allocatedate=null') ;
				if @allotaccount>0 THEN
					set @TMPSQL_ONE=concat(@TMPSQL_ONE,",smownerid=",@allotaccount);
				end if;
				set @TMPSQL_TWO=concat(@TMPSQL_ONE,' where ld_account.deleted=0 and( ld_account.publicaccount=2 or ld_account.publicaccount=3)  and ifnull(ld_account.completed,"")<>"达成"  ');
		  end if;
		prepare stmt from @TMPSQL_TWO;
		execute stmt;
		deallocate prepare stmt;
	end if;


end ||
delimiter;

drop PROCEDURE if EXISTS account_complete_recoveryrule;
delimiter ||
create PROCEDURE  account_complete_recoveryrule()
BEGIN

	DECLARE var_tabname varchar(100);
	DECLARE var_columnname varchar(100);
	DECLARE var_tablename varchar(100);
	DECLARE var_condition varchar(50);
	DECLARE var_days int(11);
	DECLARE var_otherwhere varchar(200);
	declare done  int  default 0;

	declare cur1 CURSOR FOR select tabname,ld_account_set_rule.columnname,ld_field.tablename ,`condition`,ld_account_set_rule.days
 ,ld_account_set_rule.otherwhere from ld_account_set_rule  inner join ld_tab on ld_tab.name=ld_account_set_rule.tabname and presence in(0,2)
	INNER JOIN ld_field on ld_field.tabid=ld_tab.tabid and ld_account_set_rule.columnname=ld_field.columnname
	and ld_field.presence in(0,2) where ld_account_set_rule.type='complete' and ld_account_set_rule.`status`='active';
	declare continue handler  for not   found  SET done =1;
	set @tmpint=0;
	set @tmpsql='';
 select max(ld_account_set_rule.days) into @maxdays
  from ld_account_set_rule  inner join ld_tab on ld_tab.name=ld_account_set_rule.tabname and presence in(0,2)
	INNER JOIN ld_field on ld_field.tabid=ld_tab.tabid and ld_account_set_rule.columnname=ld_field.columnname
	and ld_field.presence in(0,2) where ld_account_set_rule.type='complete' and ld_account_set_rule.`status`='active';

  select allotaccount into @allotaccount from ld_account_set;
	OPEN cur1;

	Fetch cur1 into var_tabname,var_columnname,var_tablename,var_condition,var_days,var_otherwhere;
	loop1: while  done<>1 DO

		  if(var_condition='and' ) then

			set @tmpsqlone =concat("select ld_account.accountid,ld_account.allocatedate from ld_account ");
			set @tmpsqlone=concat(@tmpsqlone," inner join ",var_tablename,' on ',var_tablename,'.accountid=ld_account.accountid ');
			set @tmpsqlone=concat(@tmpsqlone," and  ",var_tablename,'.smownerid=ld_account.smownerid' );

			set @tmpsqlone=concat(@tmpsqlone ,"  where  ",var_tablename,".deleted=0");
		   if var_otherwhere is not null and  var_otherwhere<>'' then
					set @tmpsqlone=concat(@tmpsqlone,var_otherwhere);
				end if;
		  set @tmpsqlone=concat( @tmpsqlone,' group by ld_account.accountid ') ;
		  set @tmpsqlone=concat(@tmpsqlone,"   having datediff(curdate(), case when ld_account.allocatedate> max( " ,var_tablename,'.',var_columnname," )  then ld_account.allocatedate else max( " ,var_tablename,'.',var_columnname," ) end  ) >",var_days);

			set @tmpsqltwo=concat('select ld_account.accountid,ld_account.allocatedate from  ld_account LEFT JOIN(select ld_account.accountid
					from ld_account inner join ',var_tablename,' on ld_account.accountid=',var_tablename,'.accountid
						and ld_account.smownerid=',var_tablename,'.smownerid  where ',var_tablename,'.deleted=0' );

		   if var_otherwhere is not null and  var_otherwhere<>'' then
					set @tmpsqltwo=concat(@tmpsqltwo, var_otherwhere);
				end if;
			set @tmpsqltwo=concat(@tmpsqltwo,' ) 	as ttt_',var_tablename,'  on ld_account.accountid=ttt_',var_tablename,'.accountid   where ttt_',var_tablename,'.accountid is null  ' );
			set @tmpsqltwo=concat(@tmpsqltwo," and datediff(curdate(),ld_account.allocatedate ) >",var_days);

			set @tmpthree=concat( @tmpsqlone,' union all ',@tmpsqltwo);
			set @tmpsql=concat(@tmpsql," select * from ( ",@tmpthree," ) as  tttt_",var_tabname);
			set @tmpsql=concat(@tmpsql,' union all ' );

			elseif (var_condition='or')  then
				set @tmpsql=concat(@tmpsql ,' select ld_account.accountid,ld_account.allocatedate from ld_account inner join '  ,var_tablename,' on ',var_tablename,'.accountid=ld_account.accountid  ');

			  set @tmpsql=concat(@tmpsql,' and ' ,var_tablename,'.smownerid=ld_account.smownerid ' );
				set @tmpsql=concat(@tmpsql,' where  ' , var_tablename,'.deleted=0 ' );
			  if var_otherwhere is not null and  var_otherwhere<>'' then
					set @tmpsql=concat(@tmpsql,var_otherwhere);
				end if;

			  set @tmpsql=concat( @tmpsqlone,' group by ld_account.accountid ') ;
				set @tmpsql=concat(@tmpsql," having    datediff ( curdate(), case when ld_account.allocatedate> max( ",var_tablename,'.',var_columnname," ) then ld_account.allocatedate else max( ",var_tablename,'.',var_columnname," )  end )<=",var_days );


				set @tmpsql=concat(@tmpsql,' union all ' );

			end if;
			set @tmpint=@tmpint+1;
			Fetch cur1 into var_tabname,var_columnname,var_tablename,var_condition,var_days,var_otherwhere;
		end while loop1;
		close cur1;


	if @tmpint>0 then
		set @len=CHAR_LENGTH(' union all ');
		set @tmpsql=left(@tmpsql,CHAR_LENGTH(@tmpsql)-@len);
		set @sql=concat(' select accountid from (',@tmpsql, ') as tmpone group by accountid ') ;


	  if var_condition='or'  then
			set @TMPSQL_ONE=concat( ' select "系统","LOGPUBLICCOMPLETE",now(), ld_account.accountid  from ld_account left join ( ',@sql,' ) as lingdangtmp  on  lingdangtmp.accountid=ld_account.accountid ') ;
			set @TMPSQL_TWO=concat(@TMPSQL_ONE,' where ld_account.deleted=0 and( ld_account.publicaccount=2 or ld_account.publicaccount=3)  and ifnull(ld_account.completed,"")="达成"');
		  set @TMPSQL_TWO=concat(@TMPSQL_TWO, ' and lingdangtmp.accountid is null  and datediff(curdate(),ld_account.allocatedate)>',@maxdays);
		else
			set @TMPSQL_ONE=concat( ' select "系统","LOGPUBLICCOMPLETE",now(), ld_account.accountid  from ld_account inner join ( ',@sql,' ) as lingdangtmp  on  lingdangtmp.accountid=ld_account.accountid ') ;
			set @TMPSQL_TWO=concat(@TMPSQL_ONE,' where ld_account.deleted=0 and( ld_account.publicaccount=2 or ld_account.publicaccount=3)  and ifnull(ld_account.completed,"")="达成"');

		end if;
	   set @TMPSQL_THREE=concat('insert into ld_logpublicaccount(username,operation,opdate,accountid) ',@TMPSQL_TWO);
		 prepare stmt from @TMPSQL_THREE;
		 execute stmt;
		 deallocate prepare stmt;


			if var_condition='or'  then
			 set @TMPSQL_ONE=concat( ' update  ld_account left join ( ',@sql,' ) as lingdangtmp  on  lingdangtmp.accountid=ld_account.accountid set ld_account.publicaccount=1 ,protectdate=null ,allocatedate=null') ;
			 if @allotaccount>0 THEN
					set @TMPSQL_ONE=concat(@TMPSQL_ONE,",smownerid=",@allotaccount);
				end if;
		   set @TMPSQL_TWO=concat(@TMPSQL_ONE,' where ld_account.deleted=0 and( ld_account.publicaccount=2 or ld_account.publicaccount=3)  and ifnull(ld_account.completed,"")="达成"  ');
		   set @TMPSQL_TWO=concat(@TMPSQL_TWO, ' and lingdangtmp.accountid is null and datediff(curdate(),ld_account.allocatedate)>',@maxdays);
			ELSE
			  set @TMPSQL_ONE=concat( ' update  ld_account inner join ( ',@sql,' ) as lingdangtmp  on  lingdangtmp.accountid=ld_account.accountid set ld_account.publicaccount=1 ,protectdate=null ,allocatedate=null') ;
		    if @allotaccount>0 THEN
					set @TMPSQL_ONE=concat(@TMPSQL_ONE,",smownerid=",@allotaccount);
				end if;
		  	set @TMPSQL_TWO=concat(@TMPSQL_ONE,' where ld_account.deleted=0 and( ld_account.publicaccount=2 or ld_account.publicaccount=3)  and ifnull(ld_account.completed,"")="达成"  ');
		 end if;
		prepare stmt from @TMPSQL_TWO;
		execute stmt;
		deallocate prepare stmt;

	end if;



end ||
delimiter;

DROP PROCEDURE IF EXISTS `DelColumn`;
delimiter ||
CREATE PROCEDURE `DelColumn`(
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

DROP PROCEDURE IF EXISTS `ldcrm_resetfield_20180323`;
delimiter ||
CREATE PROCEDURE `ldcrm_resetfield_20180323`(

)
BEGIN


	SET @tabid=20;
	IF EXISTS (SELECT 1 FROM ld_field WHERE columnname='carrier' AND tabid=@tabid AND presence=1) THEN
		SET @fieldid=(SELECT fieldid FROM ld_field WHERE columnname='carrier' AND tabid=@tabid);
		DELETE FROM ld_tranlabel WHERE trantable='ld_field' AND tabid=@tabid AND Relateid=@fieldid;
		DELETE FROM ld_field WHERE fieldid=@fieldid;

		CALL DelColumn('ld_quotes','carrier');
	END IF;

	SET @tabid=21;
	IF EXISTS (SELECT 1 FROM ld_field WHERE columnname='carrier' AND tabid=@tabid AND presence=1) THEN
		SET @fieldid=(SELECT fieldid FROM ld_field WHERE columnname='carrier' AND tabid=@tabid);
		DELETE FROM ld_tranlabel WHERE trantable='ld_field' AND tabid=@tabid AND Relateid=@fieldid;
		DELETE FROM ld_field WHERE fieldid=@fieldid;

		CALL DelColumn('ld_purchaseorder','carrier');
	END IF;

	SET @tabid=22;
	IF EXISTS (SELECT 1 FROM ld_field WHERE columnname='carrier' AND tabid=@tabid AND presence=1) THEN
		SET @fieldid=(SELECT fieldid FROM ld_field WHERE columnname='carrier' AND tabid=@tabid);
		DELETE FROM ld_tranlabel WHERE trantable='ld_field' AND tabid=@tabid AND Relateid=@fieldid;
		DELETE FROM ld_field WHERE fieldid=@fieldid;

		CALL DelColumn('ld_salesorder','carrier');
	END IF;


	IF NOT EXISTS (SELECT 1 FROM ld_field WHERE columnname='carrier') THEN
		SET @listid=(SELECT listid FROM ld_picklist_set WHERE listname='carrier');
		IF IFNULL(@listid,0)>0 THEN
			DELETE FROM ld_picklist_values WHERE listid=@listid;
			DELETE FROM ld_picklist_set WHERE listname='carrier';
		END IF;
	END IF;


	SET @columnname='ziptype';
	SET @tabid=20;
	IF EXISTS (SELECT 1 FROM ld_field WHERE columnname=@columnname AND tabid=@tabid AND presence=1) THEN
		SET @fieldid=(SELECT fieldid FROM ld_field WHERE columnname=@columnname AND tabid=@tabid);
		DELETE FROM ld_tranlabel WHERE trantable='ld_field' AND tabid=@tabid AND Relateid=@fieldid;
		DELETE FROM ld_field WHERE fieldid=@fieldid;

		CALL DelColumn('ld_quotes',@columnname);
	END IF;

	SET @tabid=21;
	IF EXISTS (SELECT 1 FROM ld_field WHERE columnname=@columnname AND tabid=@tabid AND presence=1) THEN
		SET @fieldid=(SELECT fieldid FROM ld_field WHERE columnname=@columnname AND tabid=@tabid);
		DELETE FROM ld_tranlabel WHERE trantable='ld_field' AND tabid=@tabid AND Relateid=@fieldid;
		DELETE FROM ld_field WHERE fieldid=@fieldid;

		CALL DelColumn('ld_purchaseorder',@columnname);
	END IF;

	SET @tabid=22;
	IF EXISTS (SELECT 1 FROM ld_field WHERE columnname=@columnname AND tabid=@tabid AND presence=1) THEN
		SET @fieldid=(SELECT fieldid FROM ld_field WHERE columnname=@columnname AND tabid=@tabid);
		DELETE FROM ld_tranlabel WHERE trantable='ld_field' AND tabid=@tabid AND Relateid=@fieldid;
		DELETE FROM ld_field WHERE fieldid=@fieldid;

		CALL DelColumn('ld_salesorder',@columnname);
	END IF;


	IF NOT EXISTS (SELECT 1 FROM ld_field WHERE columnname=@columnname) THEN
		SET @listid=(SELECT listid FROM ld_picklist_set WHERE listname=@columnname);
		IF IFNULL(@listid,0)>0 THEN
			DELETE FROM ld_picklist_values WHERE listid=@listid;
			DELETE FROM ld_picklist_set WHERE listname=@columnname;
		END IF;
	END IF;

	SET @columnname='logistics_no';
	SET @tabid=22;
	IF EXISTS (SELECT 1 FROM ld_field WHERE columnname=@columnname AND tabid=@tabid AND presence=1) THEN
		SET @fieldid=(SELECT fieldid FROM ld_field WHERE columnname=@columnname AND tabid=@tabid);
		DELETE FROM ld_tranlabel WHERE trantable='ld_field' AND tabid=@tabid AND Relateid=@fieldid;
		DELETE FROM ld_field WHERE fieldid=@fieldid;

		CALL DelColumn('ld_salesorder',@columnname);
	END IF;

end ||
delimiter;

CALL ldcrm_resetfield_20180323();
DROP PROCEDURE IF EXISTS `ldcrm_resetfield_20180323`;

DELETE FROM ld_cvcolumnlist_wx WHERE modulename='ServiceContracts';
CALL rest_cvcolumnlist_wx('ServiceContracts','accountid','1','1','yes','yes');
CALL rest_cvcolumnlist_wx('ServiceContracts','contract_no','2','1','yes','yes');
CALL rest_cvcolumnlist_wx('ServiceContracts','total','3','1','yes','yes');
CALL rest_cvcolumnlist_wx('ServiceContracts','smownerid','4','1','yes','yes');
delimiter;
-- 2018-03-23

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

update ld_version set old_version='V7.3.1',current_version='V7.3.1',remark='V7.3.1-20180323',wx_version='V7.3.1';
delimiter;