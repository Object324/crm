select cvid into @cvid from ld_customview  where entitytype='SalesOrder' and viewname='All';
select tabid into @tabid from ld_tab where name='salesorder';

insert into  ld_tabwithproductview (tabid,columns,sequence,cvid)
select @tabid,'LD_salesorder:subject:subject:SalesOrder_主题:V',1,@cvid from dual
where not EXISTS(select 1 from ld_tabwithproductview where tabid =@tabid  and cvid=@cvid  and COLUMNS like '%LD_salesorder:subject:subject:SalesOrder%');
insert into  ld_tabwithproductview (tabid,columns,sequence,cvid)
select @tabid,'LD_salesorder:salesorder_no:salesorder_no:SalesOrder_SalesOrder No:V',2,@cvid from dual
where not EXISTS(select 1 from ld_tabwithproductview where tabid =@tabid  and cvid=@cvid  and COLUMNS like '%LD_salesorder:salesorder_no:salesorder_no:SalesOrder%');
insert into  ld_tabwithproductview (tabid,columns,sequence,cvid)
select @tabid,'LD_salesorder:sostatus:sostatus:SalesOrder_订单状态:V',3,@cvid from dual
where not EXISTS(select 1 from ld_tabwithproductview where tabid =@tabid  and cvid=@cvid  and COLUMNS like '%LD_salesorder:sostatus:sostatus:SalesOrder%');
insert into  ld_tabwithproductview (tabid,columns,sequence,cvid)
select @tabid,'LD_salesorder:total:hdnGrandTotal:SalesOrder_Total:N',4,@cvid from dual
where not EXISTS(select 1 from ld_tabwithproductview where tabid =@tabid  and cvid=@cvid  and COLUMNS like '%LD_salesorder:total:hdnGrandTotal:SalesOrder%');
insert into  ld_tabwithproductview (tabid,columns,sequence,cvid)
select @tabid,'LD_salesorder:accountid:account_id:SalesOrder_客户名称:I',5,@cvid from dual
where not EXISTS(select 1 from ld_tabwithproductview where tabid =@tabid  and cvid=@cvid  and COLUMNS like '%LD_salesorder:accountid:account_id:SalesOrder%');
insert into  ld_tabwithproductview (tabid,columns,sequence,cvid)
select @tabid,'LD_salesorder:duedate:duedate:SalesOrder_交付日期:D',6,@cvid from dual
where not EXISTS(select 1 from ld_tabwithproductview where tabid =@tabid  and cvid=@cvid  and COLUMNS like '%LD_salesorder:duedate:duedate:SalesOrder%');
insert into  ld_tabwithproductview (tabid,columns,sequence,cvid)
select @tabid,'LD_salesorder:stockpresence:stockpresence:SalesOrder_出库状态:V',7,@cvid from dual
where not EXISTS(select 1 from ld_tabwithproductview where tabid =@tabid  and cvid=@cvid  and COLUMNS like '%LD_salesorder:stockpresence:stockpresence:SalesOrder%');

insert into  ld_tabwithproductview (tabid,columns,sequence,cvid)
select @tabid,'LD_salesorder:signed_data:signed_data:SalesOrder_签约日期:D',8,@cvid from dual
where not EXISTS(select 1 from ld_tabwithproductview where tabid =@tabid  and cvid=@cvid  and COLUMNS like '%LD_salesorder:signed_data:signed_data:SalesOrder%');

insert into  ld_tabwithproductview (tabid,columns,sequence,cvid)
select @tabid,'LD_salesorder:smownerid:assigned_user_id:SalesOrder_销售负责人:V',9,@cvid from dual
where not EXISTS(select 1 from ld_tabwithproductview where tabid =@tabid  and cvid=@cvid  and COLUMNS like '%LD_salesorder:smownerid:assigned_user_id:SalesOrder%');
delimiter;
alter table ld_bankaccountset  MODIFY banknum VARCHAR(100);
delimiter;

SELECT usereportid into @id from LD_usereport where name='SumSequence';
SELECT tabid into @tid from LD_tab where name='HelpDesk';
insert into LD_usereport(usereportid,name,reportlabel,tabids,basicfilter,advfilter,Setcolumns,Parent_id,sequence,reporttype,pagewidthpercent)
select '','Serviceperformanceappraisal','服务绩效统计表',@tid,1,1,1,@id,12,26,110
from dual where not exists(select usereportid from LD_usereport where name='Serviceperformanceappraisal');
delimiter;

select usereportid into @id from LD_usereport where name='Serviceperformanceappraisal';
insert into LD_usereportbasic(id,Usereportid,columns,Defaultvalue,Sequence)
select '',@id,'LD_troubletickets:realtime:realtime:HelpDesk_realtime:D','thisstartmonth~thisendmonth',3
from dual where not exists(select usereportid from LD_usereportbasic where Usereportid=@id and Sequence=3);

insert into LD_usereportbasic(id,Usereportid,columns,Defaultvalue,Sequence)
select '',@id,'LD_troubletickets:accountname:accountname:Accounts_accountname:I','',4
from dual where not exists(select usereportid from LD_usereportbasic where Usereportid=@id and Sequence=4);

insert into LD_usereportbasic(id,Usereportid,columns,Defaultvalue,Sequence)
select '',@id,'LD_troubletickets:approvestatus:approvestatus:HelpDesk_approvestatus:I','',5
from dual where not exists(select usereportid from LD_usereportbasic where Usereportid=@id and Sequence=5);
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'zh','Serviceperformanceappraisal','服务绩效统计表','fixedstr'
from dual where not EXISTS(select 1 from ld_desk where languagetype='zh' and labelbol='Serviceperformanceappraisal' and Labeltype='fixedstr');

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'en','Serviceperformanceappraisal','Service and performance appraisal','fixedstr'
from dual where not EXISTS(select 1 from ld_desk  where languagetype='en' and labelbol='Serviceperformanceappraisal' and Labeltype='fixedstr');

select usereportid into @id from LD_usereport where name='Serviceperformanceappraisal';

insert into LD_UseReportcolumns(id,Usereportid,columns,Sequence,columnshow,realcolumns,realencolumns)
select '', @id, 'LD_troubletickets:module_zh:module_zh:OftenUseReport_module_zh:V', 1, 1, 'LD_troubletickets:module_zh:module_zh:OftenUseReport_单据类型:V','LD_troubletickets:module_zh:module_zh:OftenUseReport_Bill Type:V'
from dual where not exists(select 1 from LD_UseReportcolumns where Usereportid=@id and realcolumns='LD_troubletickets:module_zh:module_zh:OftenUseReport_单据类型:V');

insert into LD_UseReportcolumns(id,Usereportid,columns,Sequence,columnshow,realcolumns,realencolumns)
select '', @id, 'LD_users:lastname:lastname:OftenUseReport_lastname:V', 2, 1, 'LD_users:lastname:lastname:OftenUseReport_服务人员:V','LD_users:lastname:lastname:OftenUseReport_Assigned To:V'
from dual where not exists(select 1 from LD_UseReportcolumns where Usereportid=@id and realcolumns='LD_users:lastname:lastname:OftenUseReport_服务人员:V');

insert into LD_UseReportcolumns(id,Usereportid,columns,Sequence,columnshow,realcolumns,realencolumns)
select '', @id, 'LD_account:accountname:accountname:Accounts_accountname:V', 3, 1, 'LD_account:accountname:accountname:Accounts_客户名称:V','LD_account:accountname:accountname:Accounts_Account Name:V'
from dual where not exists(select 1 from LD_UseReportcolumns where Usereportid=@id and realcolumns='LD_account:accountname:accountname:Accounts_客户名称:V');

insert into LD_UseReportcolumns(id,Usereportid,columns,Sequence,columnshow,realcolumns,realencolumns)
select '', @id, 'LD_account:bill_city:bill_city:Accounts_bill_city:V', 4, 1, 'LD_account:bill_city:bill_city:Accounts_城市:V','LD_account:bill_city:bill_city:Accounts_City:V'
from dual where not exists(select 1 from LD_UseReportcolumns where Usereportid=@id and realcolumns='LD_account:bill_city:bill_city:Accounts_城市:V');

insert into LD_UseReportcolumns(id,Usereportid,columns,Sequence,columnshow,realcolumns,realencolumns)
select '', @id, 'LD_products:productcategory:productcategory:Products_productcategory:V', 5, 1, 'LD_products:productcategory:productcategory:Products_产品类别:V','LD_products:productcategory:productcategory:Products_Product Type:V'
from dual where not exists(select 1 from LD_UseReportcolumns where Usereportid=@id and realcolumns='LD_products:productcategory:productcategory:Products_产品类别:V');

insert into LD_UseReportcolumns(id,Usereportid,columns,Sequence,columnshow,realcolumns,realencolumns)
select '', @id, 'LD_troubletickets:enddate:enddate:HelpDesk_enddate:D', 6, 1, 'LD_troubletickets:enddate:enddate:HelpDesk_上门日期:D','LD_troubletickets:enddate:enddate:HelpDesk_Service Date:D'
from dual where not exists(select 1 from LD_UseReportcolumns where Usereportid=@id and realcolumns='LD_troubletickets:enddate:enddate:HelpDesk_上门日期:D');

insert into LD_UseReportcolumns(id,Usereportid,columns,Sequence,columnshow,realcolumns,realencolumns)
select '', @id, 'LD_troubletickets:fwyeji:fwyeji:OftenUseReport_fwyeji:NN', 7, 1, 'LD_troubletickets:fwyeji:fwyeji:OftenUseReport_服务业绩:NN','LD_troubletickets:fwyeji:fwyeji:OftenUseReport_Performance scores:NN'
from dual where not exists(select 1 from LD_UseReportcolumns where Usereportid=@id and realcolumns='LD_troubletickets:fwyeji:fwyeji:OftenUseReport_服务业绩:NN');

insert into LD_UseReportcolumns(id,Usereportid,columns,Sequence,columnshow,realcolumns,realencolumns)
select '', @id, 'LD_troubletickets:traficfee:traficfee:HelpDesk_traficfee:NN', 8, 1, 'LD_troubletickets:traficfee:traficfee:HelpDesk_交通费:NN','LD_troubletickets:traficfee:traficfee:HelpDesk_Traffic Expense:NN'
from dual where not exists(select 1 from LD_UseReportcolumns where Usereportid=@id and realcolumns='LD_troubletickets:traficfee:traficfee:HelpDesk_交通费:NN');

insert into LD_UseReportcolumns(id,Usereportid,columns,Sequence,columnshow,realcolumns,realencolumns)
select '', @id, 'LD_troubletickets:jiaotongfei:jiaotongfei:HelpDesk_jiaotongfei:NN', 9, 1, 'LD_troubletickets:jiaotongfei:jiaotongfei:HelpDesk_交通费(按业绩):NN','LD_troubletickets:jiaotongfei:jiaotongfei:HelpDesk_Traffic Expense(Acc to scores):NN'
from dual where not exists(select 1 from LD_UseReportcolumns where Usereportid=@id and realcolumns='LD_troubletickets:jiaotongfei:jiaotongfei:HelpDesk_交通费(按业绩):NN');

insert into LD_UseReportcolumns(id,Usereportid,columns,Sequence,columnshow,realcolumns,realencolumns)
select '', @id, 'LD_troubletickets:projecttask_no:projecttask_no:HelpDesk_projecttask_no:V', 10, 1, 'LD_troubletickets:projecttask_no:projecttask_no:HelpDesk_单据号:V','LD_troubletickets:projecttask_no:projecttask_no:HelpDesk_Bill No:V'
from dual where not exists(select 1 from LD_UseReportcolumns where Usereportid=@id and realcolumns='LD_troubletickets:projecttask_no:projecttask_no:HelpDesk_单据号:V');

insert into LD_UseReportcolumns(id,Usereportid,columns,Sequence,columnshow,realcolumns,realencolumns)
select '', @id, 'LD_troubletickets:createdtime:createdtime:HelpDesk_createdtime:V', 11, 1, 'LD_troubletickets:createdtime:createdtime:HelpDesk_制单日期:V','LD_troubletickets:createdtime:createdtime:HelpDesk_Create Date:V'
from dual where not exists(select 1 from LD_UseReportcolumns where Usereportid=@id and realcolumns='LD_troubletickets:createdtime:createdtime:HelpDesk_制单日期:V');

insert into LD_UseReportcolumns(id,Usereportid,columns,Sequence,columnshow,realcolumns,realencolumns)
select '', @id, 'LD_troubletickets:description:description:HelpDesk_description:V', 12, 1, 'LD_troubletickets:description:description:HelpDesk_问题描述:V','LD_troubletickets:description:description:HelpDesk_Problem Description:V'
from dual where not exists(select 1 from LD_UseReportcolumns where Usereportid=@id and realcolumns='LD_troubletickets:description:description:HelpDesk_问题描述:V');

insert into LD_UseReportcolumns(id,Usereportid,columns,Sequence,columnshow,realcolumns,realencolumns)
select '', @id, 'LD_troubletickets:solution:solution:HelpDesk_solution:V', 13, 1, 'LD_troubletickets:solution:solution:HelpDesk_解决方案:V','LD_troubletickets:solution:solution:HelpDesk_The Solution:V'
from dual where not exists(select 1 from LD_UseReportcolumns where Usereportid=@id and realcolumns='LD_troubletickets:solution:solution:HelpDesk_解决方案:V');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'zh','Onlythroughdatastatisticsexaminationapproval',
'只统计审批通过的数据','fixedstr' from dual
where not EXISTS(select 1 from ld_desk  where languagetype='zh' and labelbol='Onlythroughdatastatisticsexaminationapproval'
and Labeltype='fixedstr');

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'en','Onlythroughdatastatisticsexaminationapproval',
'Only through the data statistics of examination and approval','fixedstr' from dual
where not EXISTS(select 1 from ld_desk  where languagetype='en' and labelbol='Onlythroughdatastatisticsexaminationapproval'
and Labeltype='fixedstr');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'zh','BillType',
'单据类型','fixedstr' from dual
where not EXISTS(select 1 from ld_desk  where languagetype='zh' and labelbol='BillType'
and Labeltype='fixedstr');

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'en','BillType',
'Bill Type','fixedstr' from dual
where not EXISTS(select 1 from ld_desk  where languagetype='en' and labelbol='BillType'
and Labeltype='fixedstr');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'zh','checktoday',
'今日','fixedstr' from dual
where not EXISTS(select 1 from ld_desk  where languagetype='zh' and labelbol='checktoday'
and Labeltype='fixedstr');

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'en','checktoday',
'Today','fixedstr' from dual
where not EXISTS(select 1 from ld_desk  where languagetype='en' and labelbol='checktoday'
and Labeltype='fixedstr');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'zh','checkyesterday',
'昨日','fixedstr' from dual
where not EXISTS(select 1 from ld_desk  where languagetype='zh' and labelbol='checkyesterday'
and Labeltype='fixedstr');

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'en','checkyesterday',
'Yesterday','fixedstr' from dual
where not EXISTS(select 1 from ld_desk  where languagetype='en' and labelbol='checkyesterday'
and Labeltype='fixedstr');
delimiter;

call addcolumn('ld_productcategory','scores','int',19,0);
alter table ld_productcategory modify scores decimal(25,2);
delimiter;

call addcolumn('ld_projecttasktype','weight','int',19,0);
alter table ld_projecttasktype modify weight decimal(25,2);
delimiter;

call addcolumn('ld_ticketcategories','weight','int',19,0);
alter table ld_ticketcategories modify weight decimal(25,2);
delimiter;

call addcolumn('ld_tab','Proportion','int',19,0);
alter table ld_projecttasktype modify weight decimal(25,2);
delimiter;

call addcolumn('ld_bill_city','scores ','int',19,0);
alter table ld_bill_city modify scores decimal(25,2);
delimiter;

select id into @id from ld_settings_field_seq;
select sequence into @sequence from LD_settings_field where name = 'LBL_SYSTEM_SET';
update LD_settings_field set sequence = sequence+1 where blockid = 3 and sequence > @sequence;
delimiter;
insert into LD_settings_field(fieldid,blockid,name,iconpath,description,linkto,sequence,active)
select @id+1,3,'LBL_SERVICE_PERFORMANCE_PARAMETERS','migrate.png','LBL_SERVICE_PERFORMANCE_PARAMETERS_DESCRIPTION',
'index.php?module=Settings&action=Serviceperformance&parenttab=Settings',@sequence+1,0
from dual where not EXISTS(select 1 from LD_settings_field where name ='LBL_SERVICE_PERFORMANCE_PARAMETERS');
update ld_settings_blocks_seq set id = (select max(fieldid) from LD_settings_field);
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'zh','LBL_SERVICE_PERFORMANCE_PARAMETERS',
'服务绩效参数','fixedstr' from dual
where not EXISTS(select 1 from ld_desk  where languagetype='zh' and labelbol='LBL_SERVICE_PERFORMANCE_PARAMETERS'
and Labeltype='fixedstr');

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'en','LBL_SERVICE_PERFORMANCE_PARAMETERS',
'Service performance parameters','fixedstr' from dual
where not EXISTS(select 1 from ld_desk  where languagetype='en' and labelbol='LBL_SERVICE_PERFORMANCE_PARAMETERS'
and Labeltype='fixedstr');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'zh','LBL_SERVICE_PERFORMANCE_PARAMETERS_DESCRIPTION',
'设定{$HelpDesk.HelpDesk}和{$ProjectTask.ProjectTask}绩效考核参数','fixedstr' from dual
where not EXISTS(select 1 from ld_desk  where languagetype='zh' and labelbol='LBL_SERVICE_PERFORMANCE_PARAMETERS_DESCRIPTION'
and Labeltype='fixedstr');

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'en','LBL_SERVICE_PERFORMANCE_PARAMETERS_DESCRIPTION',
'Set service performance parameters for {$HelpDesk.HelpDesk} and {$ProjectTask.ProjectTask}','fixedstr' from dual
where not EXISTS(select 1 from ld_desk  where languagetype='en' and labelbol='LBL_SERVICE_PERFORMANCE_PARAMETERS_DESCRIPTION'
and Labeltype='fixedstr');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'zh','Proportion_of_traffic_expense',
'交通补贴报销比例','fixedstr' from dual
where not EXISTS(select 1 from ld_desk  where languagetype='zh' and labelbol='Proportion_of_traffic_expense'
and Labeltype='fixedstr');

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'en','Proportion_of_traffic_expense',
'Proportion of traffic expense','fixedstr' from dual
where not EXISTS(select 1 from ld_desk  where languagetype='en' and labelbol='Proportion_of_traffic_expense'
and Labeltype='fixedstr');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'zh','Performance_scores',
'绩效基数','fixedstr' from dual
where not EXISTS(select 1 from ld_desk  where languagetype='zh' and labelbol='Performance_scores'
and Labeltype='fixedstr');

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'en','Performance_scores',
'Performance scores','fixedstr' from dual
where not EXISTS(select 1 from ld_desk  where languagetype='en' and labelbol='Performance_scores'
and Labeltype='fixedstr');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'zh','Performance_weight',
'绩效权重','fixedstr' from dual
where not EXISTS(select 1 from ld_desk  where languagetype='zh' and labelbol='Performance_weight'
and Labeltype='fixedstr');

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'en','Performance_weight',
'Performance weight','fixedstr' from dual
where not EXISTS(select 1 from ld_desk  where languagetype='en' and labelbol='Performance_weight'
and Labeltype='fixedstr');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'zh','Bill_type',
'单据类型','fixedstr' from dual
where not EXISTS(select 1 from ld_desk  where languagetype='zh' and labelbol='Bill_type'
and Labeltype='fixedstr');

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'en','Bill_type',
'Bill type','fixedstr' from dual
where not EXISTS(select 1 from ld_desk  where languagetype='en' and labelbol='Bill_type'
and Labeltype='fixedstr');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'zh','Proportion_traffic_expense',
'交通补贴报销比例(%)','fixedstr' from dual
where not EXISTS(select 1 from ld_desk  where languagetype='zh' and labelbol='Proportion_traffic_expense'
and Labeltype='fixedstr');

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'en','Proportion_traffic_expense',
'Proportion of traffic expense (%)','fixedstr' from dual
where not EXISTS(select 1 from ld_desk  where languagetype='en' and labelbol='Proportion_traffic_expense'
and Labeltype='fixedstr');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'zh','Performance_scores_1',
'1.	{$HelpDesk.HelpDesk}业绩=({$HelpDesk.productcategory}绩效基数*{$HelpDesk.ticketcategories}绩效权重*0.01+{$Accounts.bill_city}绩效基数)',
'fixedstr' from dual
where not EXISTS(select 1 from ld_desk  where languagetype='zh' and labelbol='Performance_scores_1'
and Labeltype='fixedstr');

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'en','Performance_scores_1',
'1.	Performance scores of {$HelpDesk.HelpDesk}=scores of {$HelpDesk.productcategory} * {$HelpDesk.ticketcategories} * weight*0.01+ scores of {$Accounts.bill_city}',
'fixedstr' from dual
where not EXISTS(select 1 from ld_desk  where languagetype='en' and labelbol='Performance_scores_1'
and Labeltype='fixedstr');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'zh','Performance_scores_2',
'2.	{$ProjectTask.ProjectTask}业绩=({$HelpDesk.productcategory}绩效基数*{$ProjectTask.projecttasktype}绩效权重*0.01+{$Accounts.bill_city}绩效基数)',
'fixedstr' from dual
where not EXISTS(select 1 from ld_desk  where languagetype='zh' and labelbol='Performance_scores_2'
and Labeltype='fixedstr');

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'en','Performance_scores_2',
'2.	Performance scores of {$ProjectTask.ProjectTask}=scores of {$HelpDesk.productcategory} * {$ProjectTask.projecttasktype} * weight*0.01+ scores of {$Accounts.bill_city}',
'fixedstr' from dual
where not EXISTS(select 1 from ld_desk  where languagetype='en' and labelbol='Performance_scores_2'
and Labeltype='fixedstr');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'zh','Must_number_greater_than_0',
'必须是大于等于0的数字',
'jspop' from dual
where not EXISTS(select 1 from ld_desk  where languagetype='zh' and labelbol='Must_number_greater_than_0'
and Labeltype='jspop');

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'en','Must_number_greater_than_0',
'Must be a number greater than 0',
'jspop' from dual
where not EXISTS(select 1 from ld_desk  where languagetype='en' and labelbol='Must_number_greater_than_0'
and Labeltype='jspop');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'zh','Performance_measures',
'选择绩效维度','fixedstr' from dual
where not EXISTS(select 1 from ld_desk  where languagetype='zh' and labelbol='Performance_measures'
and Labeltype='fixedstr');

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'en','Performance_measures',
'Performance measures','fixedstr' from dual
where not EXISTS(select 1 from ld_desk  where languagetype='en' and labelbol='Performance_measures'
and Labeltype='fixedstr');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'zh','FOLLOWUP','跟进','fixedstr' from dual
where not EXISTS(select 1 from ld_desk  where languagetype='zh' and labelbol='FOLLOWUP' and Labeltype='fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'en','FOLLOWUP','Follow-up','fixedstr' from dual
where not EXISTS(select 1 from ld_desk  where languagetype='en' and labelbol='FOLLOWUP' and Labeltype='fixedstr');
delimiter;
SELECT tabid into @tabid from ld_tab where name='PurchaseOrder';
SELECT tabid into @related_tabid from ld_tab where name='PurchaseBack';
SELECT sequence into @sequence from ld_quickactions where tabid=@tabid and related_tabid=-1;
UPDATE ld_quickactions set sequence=sequence+1 where tabid=@tabid and sequence>=@sequence;
UPDATE ld_quickactions set sequence=@sequence where tabid=@tabid and related_tabid=@related_tabid;
delimiter;

update ld_field set quickcreate=1 where tabid=(select tabid from ld_tab where name='PaymentPlan');
update ld_field set quickcreate=1 where tabid=(select tabid from ld_tab where name='SendPayment');

select usereportid into @id from LD_usereport where name='Serviceperformanceappraisal';
insert into LD_UseReportcolumns(id,Usereportid,columns,Sequence,columnshow,realcolumns,realencolumns)
select '', @id, 'LD_troubletickets:ticketcategories:ticketcategories:HelpDesk_ticketcategories:V', 8, 1, 'LD_troubletickets:ticketcategories:ticketcategories:HelpDesk_故障类别:V','LD_troubletickets:ticketcategories:ticketcategories:HelpDesk_Failure category:V'
from dual where not exists(select 1 from LD_UseReportcolumns where Usereportid=@id and realcolumns='LD_troubletickets:ticketcategories:ticketcategories:HelpDesk_故障类别:V');
delimiter;

insert into ld_systems_deploy(deploy_value,deploy_type,description,setype)
select 1,51,'未读提醒是否弹框提示。','' from dual where not exists
(select 1 from ld_systems_deploy where deploy_type=51);
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'zh','Wether_need_dialog_box_notice_unread_reminds','未读提醒是否弹框提示','fixedstr' from dual
where not EXISTS(select 1 from ld_desk  where languagetype='zh' and labelbol='Wether_need_dialog_box_notice_unread_reminds' and Labeltype='fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'en','Wether_need_dialog_box_notice_unread_reminds','Wether need dialog box to notice the unread reminds','fixedstr' from dual
where not EXISTS(select 1 from ld_desk  where languagetype='en' and labelbol='Wether_need_dialog_box_notice_unread_reminds' and Labeltype='fixedstr');
delimiter;

select tabid into @tabid from ld_tab where name = 'PurchaseBack';
SELECT max(sequence) into @sequence from ld_quickactions where tabid=@tabid;
insert into ld_quickactions(tabid,related_tabid,sequence,presence)
select @tabid,-5,@sequence+1,0 from dual
where not EXISTS(select 1 from ld_quickactions  where tabid=@tabid and related_tabid=-5);
delimiter;

delete from ld_desk where labelbol = 'COMMUNICATIONHISTORY' and labeltype = 'fixedstr';
delimiter;
update ld_desk set Fieldlabel='指定审批人的职位级别' where labelbol='SPECIFYPROMOTERDEP' and languagetype='zh' and Labeltype='fixedstr';
update ld_desk set Fieldlabel='Specifies the user''s Job Category' where labelbol='SPECIFYPROMOTERDEP' and languagetype='en' and Labeltype='fixedstr';
delimiter;
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'zh','SAVEREPORT','保存报告','fixedstr' from dual
where not EXISTS(select 1 from ld_desk  where languagetype='zh' and labelbol='SAVEREPORT' and Labeltype='fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'en','SAVEREPORT','Save Report','fixedstr' from dual
where not EXISTS(select 1 from ld_desk  where languagetype='en' and labelbol='SAVEREPORT' and Labeltype='fixedstr');
delimiter;

SELECT tabid into @tabid from ld_tab where name='ContactRecords';
UPDATE ld_field set quickcreate=0 where tabid=@tabid and columnname in ('accountid','contactid');
delimiter;
-- end 2014-10-10

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'zh','回撤','RETRACEMENT','fixedstr' from dual
where not EXISTS(select 1 from ld_desk  where languagetype='zh' and labelbol='RETRACEMENT' and Labeltype='fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'en','RETRACEMENT','Retracement','fixedstr' from dual
where not EXISTS(select 1 from ld_desk  where languagetype='en' and labelbol='RETRACEMENT' and Labeltype='fixedstr');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'zh','AFTEREXCYTIONTHESTATUSWILLBERESTORED','执行后，该退货单将被还原到“未入库”状态，库存数量还原到入库前。确定要撤销吗？','jspop' from dual
where not EXISTS(select 1 from ld_desk  where languagetype='zh' and labelbol='AFTEREXCYTIONTHESTATUSWILLBERESTORED' and Labeltype='jspop');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'en','AFTEREXCYTIONTHESTATUSWILLBERESTORED','After execution,the status will be restored and record the stock journal. are you sure you want to do this?','jspop' from dual
where not EXISTS(select 1 from ld_desk  where languagetype='en' and labelbol='AFTEREXCYTIONTHESTATUSWILLBERESTORED' and Labeltype='jspop');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'zh','AFTEREXCYTIONTHESTATUSWILLBERESTOREDOUT','执行后，该退货单将被还原到“未出库”状态，库存数量还原到出库前。确定要撤销吗？','jspop' from dual
where not EXISTS(select 1 from ld_desk  where languagetype='zh' and labelbol='AFTEREXCYTIONTHESTATUSWILLBERESTOREDOUT' and Labeltype='jspop');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'en','AFTEREXCYTIONTHESTATUSWILLBERESTOREDOUT','After execution,the status will be restored and record the OutboundOrder journal. are you sure you want to do this?','jspop' from dual
where not EXISTS(select 1 from ld_desk  where languagetype='en' and labelbol='AFTEREXCYTIONTHESTATUSWILLBERESTOREDOUT' and Labeltype='jspop');
delimiter;

Alter table ld_salesorder CHANGE purchaseStatus purchasestatus varchar(25);
select tabid into @tabid from ld_tab where `name`='SalesOrder';
update ld_field set columnname='purchasestatus' where tabid = @tabid and columnname = 'purchaseStatus';
update ld_field set fieldname='purchasestatus' where tabid = @tabid and fieldname = 'purchaseStatus';
update ld_tabwithproductview set `columns` = 'LD_salesorder:purchasestatus:purchasestatus:SalesOrder_fieldlabel:V'
where `columns`='LD_salesorder:purchaseStatus:purchaseStatus:SalesOrder_fieldlabel:V';
delimiter;

select tabid into @tabid from ld_tab where name = 'InventoryAccount';
update ld_field set columnname = 'productsheet' where tabid = @tabid and columnname = 'productcode';
update ld_field set fieldname = 'productsheet' where tabid = @tabid and fieldname = 'productcode';
update ld_cvcolumnlist set columnname = 'LD_products:productsheet:productsheet:InventoryAccount_产品型号:'
where columnname = 'LD_products:productcode:productcode:InventoryAccount_产品型号:'
and cvid in (select cvid from ld_customview where entitytype = 'InventoryAccount');
delimiter;

UPDATE lD_Field set fieldlabel='行业信息周刊发送' where tabid=4 and columnname='cf_1093';

UPDATE lD_Field set fieldlabel='生产变更通知发送' where tabid=4 and columnname='cf_1180';

UPDATE lD_Field set fieldlabel='客户服务月报电子版发送' where tabid=4 and columnname='cf_1186';
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'zh','RATIO',
'比例(%)',
'fixedstr' from dual
where not EXISTS(select 1 from ld_desk  where languagetype='zh' and labelbol='RATIO'
and Labeltype='fixedstr');

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'en','RATIO',
'Ratio(%)',
'fixedstr' from dual
where not EXISTS(select 1 from ld_desk  where languagetype='en' and labelbol='RATIO'
and Labeltype='fixedstr');
delimiter;

UPDATE ld_desk SET fieldlabel='Payment ratio must be greater than 0!'
WHERE labelbol='PROPORTIONBACKMUSTPOSITIVEINT' AND languagetype='en' AND Labeltype='jspop';

UPDATE ld_desk SET fieldlabel='回款比例必须大于0！'
WHERE labelbol='PROPORTIONBACKMUSTPOSITIVEINT' AND languagetype='zh' AND Labeltype='jspop';
delimiter;

UPDATE ld_desk SET fieldlabel='SendPayment ratio must be greater than 0!'
WHERE labelbol='PAYMENTPERCENTAGEPOSITIVEINT' AND languagetype='en' AND Labeltype='jspop';

UPDATE ld_desk SET fieldlabel='付款比例必须大于0！'
WHERE labelbol='PAYMENTPERCENTAGEPOSITIVEINT' AND languagetype='zh' AND Labeltype='jspop';
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'zh','How_to_create_plan',
'如何创建{$PaymentPlan.PaymentPlan}',
'fixedstr' from dual
where not EXISTS(select 1 from ld_desk  where languagetype='zh' and labelbol='How_to_create_plan'
and Labeltype='fixedstr');

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'en','How_to_create_plan',
'How to create a {$PaymentPlan.PaymentPlan}',
'fixedstr' from dual
where not EXISTS(select 1 from ld_desk  where languagetype='en' and labelbol='How_to_create_plan'
and Labeltype='fixedstr');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'zh','How_to_create_plan1',
'{$PaymentPlan.PaymentPlan}是针对{$SalesOrder.SalesOrder}的，不允许直接新增',
'fixedstr' from dual
where not EXISTS(select 1 from ld_desk  where languagetype='zh' and labelbol='How_to_create_plan1'
and Labeltype='fixedstr');

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'en','How_to_create_plan1',
'{$PaymentPlan.PaymentPlan} is for the {$SalesOrder.SalesOrder}, direct creation is not allowed',
'fixedstr' from dual
where not EXISTS(select 1 from ld_desk  where languagetype='en' and labelbol='How_to_create_plan1'
and Labeltype='fixedstr');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'zh','How_to_create_plan2',
'可通过系统参数控制，新增{$SalesOrder.SalesOrder}后自动弹出{$PaymentPlan.PaymentPlan}新增界面',
'fixedstr' from dual
where not EXISTS(select 1 from ld_desk  where languagetype='zh' and labelbol='How_to_create_plan2'
and Labeltype='fixedstr');

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'en','How_to_create_plan2',
'Can be controlled by the system parameters, after creating order，create plans immediately',
'fixedstr' from dual
where not EXISTS(select 1 from ld_desk  where languagetype='en' and labelbol='How_to_create_plan2'
and Labeltype='fixedstr');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'zh','How_to_create_plan3',
'也可以通过{$SalesOrder.SalesOrder}查看明细界面更多->创建{$PaymentPlan.PaymentPlan}增加',
'fixedstr' from dual
where not EXISTS(select 1 from ld_desk  where languagetype='zh' and labelbol='How_to_create_plan3'
and Labeltype='fixedstr');

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'en','How_to_create_plan3',
'Or view the {$SalesOrder.SalesOrder} detailes and click the button More->Create {$PaymentPlan.PaymentPlan}',
'fixedstr' from dual
where not EXISTS(select 1 from ld_desk  where languagetype='en' and labelbol='How_to_create_plan3'
and Labeltype='fixedstr');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'zh','Set_the_default_ratio',
'设置默认回款比例',
'fixedstr' from dual
where not EXISTS(select 1 from ld_desk  where languagetype='zh' and labelbol='Set_the_default_ratio'
and Labeltype='fixedstr');

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'en','Set_the_default_ratio',
'Set the default ratio',
'fixedstr' from dual
where not EXISTS(select 1 from ld_desk  where languagetype='en' and labelbol='Set_the_default_ratio'
and Labeltype='fixedstr');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'zh','Set_the_send_default_ratio',
'设置默认付款比例',
'fixedstr' from dual
where not EXISTS(select 1 from ld_desk  where languagetype='zh' and labelbol='Set_the_send_default_ratio'
and Labeltype='fixedstr');

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'en','Set_the_send_default_ratio',
'Set the default ratio',
'fixedstr' from dual
where not EXISTS(select 1 from ld_desk  where languagetype='en' and labelbol='Set_the_send_default_ratio'
and Labeltype='fixedstr');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'zh','ADDQICI',
'新增期次',
'fixedstr' from dual
where not EXISTS(select 1 from ld_desk  where languagetype='zh' and labelbol='ADDQICI'
and Labeltype='fixedstr');

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'en','ADDQICI',
'ADD',
'fixedstr' from dual
where not EXISTS(select 1 from ld_desk  where languagetype='en' and labelbol='ADDQICI'
and Labeltype='fixedstr');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'zh','Reload',
'期数重载',
'fixedstr' from dual
where not EXISTS(select 1 from ld_desk  where languagetype='zh' and labelbol='Reload'
and Labeltype='fixedstr');

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'en','Reload',
'Reload',
'fixedstr' from dual
where not EXISTS(select 1 from ld_desk  where languagetype='en' and labelbol='Reload'
and Labeltype='fixedstr');
delimiter;


insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'zh','How_to_send_create_plan',
'如何创建{$SendPayment.SendPayment}',
'fixedstr' from dual
where not EXISTS(select 1 from ld_desk  where languagetype='zh' and labelbol='How_to_send_create_plan'
and Labeltype='fixedstr');

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'en','How_to_send_create_plan',
'How to create a {$SendPayment.SendPayment}',
'fixedstr' from dual
where not EXISTS(select 1 from ld_desk  where languagetype='en' and labelbol='How_to_send_create_plan'
and Labeltype='fixedstr');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'zh','How_to_send_create_plan1',
'{$SendPayment.SendPayment}是针对{$PurchaseOrder.PurchaseOrder}的，不允许直接新增',
'fixedstr' from dual
where not EXISTS(select 1 from ld_desk  where languagetype='zh' and labelbol='How_to_send_create_plan1'
and Labeltype='fixedstr');

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'en','How_to_send_create_plan1',
'{$SendPayment.SendPayment} is for the {$PurchaseOrder.PurchaseOrder}, direct creation is not allowed',
'fixedstr' from dual
where not EXISTS(select 1 from ld_desk  where languagetype='en' and labelbol='How_to_send_create_plan1'
and Labeltype='fixedstr');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'zh','How_to_send_create_plan2',
'可通过系统参数控制，新增{$PurchaseOrder.PurchaseOrder}后自动弹出{$SendPayment.SendPayment}新增界面',
'fixedstr' from dual
where not EXISTS(select 1 from ld_desk  where languagetype='zh' and labelbol='How_to_send_create_plan2'
and Labeltype='fixedstr');

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'en','How_to_send_create_plan2',
'Can be controlled by the system parameters, after creating order，create plans immediately',
'fixedstr' from dual
where not EXISTS(select 1 from ld_desk  where languagetype='en' and labelbol='How_to_send_create_plan2'
and Labeltype='fixedstr');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'zh','How_to_send_create_plan3',
'也可以通过{$PurchaseOrder.PurchaseOrder}查看明细界面更多->创建{$SendPayment.SendPayment}增加',
'fixedstr' from dual
where not EXISTS(select 1 from ld_desk  where languagetype='zh' and labelbol='How_to_send_create_plan3'
and Labeltype='fixedstr');

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'en','How_to_send_create_plan3',
'Or view the {$PurchaseOrder.PurchaseOrder} detailes and click the button More->Create {$SendPayment.SendPayment}',
'fixedstr' from dual
where not EXISTS(select 1 from ld_desk  where languagetype='en' and labelbol='How_to_send_create_plan3'
and Labeltype='fixedstr');
delimiter;

set @cvid=0;
select cvid into @cvid from ld_customview where entitytype='SalesOrder' and viewname='本月创建';
delete from ld_cvstdfilter where cvid=@cvid;
insert into ld_cvstdfilter(cvid,columnname,stdfilter,startdate,enddate)
select @cvid,'LD_salesorder:createdtime:createdtime:SalesOrder_fieldlabel','thismonth','2014-10-01','2014-10-31' from dual
where exists (select 1 from ld_customview where cvid=@cvid);
delimiter;

call addcolumn('ld_inventoryproductrel','taxprice','int',19,0);
delimiter;
alter table ld_inventoryproductrel modify taxprice decimal(25,3);
delimiter;

DROP PROCEDURE IF EXISTS updateTaxPrice_createview; 
delimiter ||
CREATE PROCEDURE updateTaxPrice_createview() 
BEGIN 
SELECT DATABASE() INTO @tableschema; 
SET @psql = CONCAT('select IFNULL(column_name, "") into @colName from information_schema.columns 
where TABLE_SCHEMA = "',@tableschema,'" and table_name= "ld_inventoryproductrel" and COLUMN_NAME="taxprice";'); 
PREPARE stmt FROM @psql; 
EXECUTE stmt; 
DEALLOCATE PREPARE stmt; 
SET @coladd = IFNULL(@colName,'-1'); 
IF @coladd = '-1' THEN 
ALTER TABLE `ld_inventoryproductrel` ADD `taxprice` DECIMAL( 25, 3) NULL DEFAULT '0' AFTER `listprice`; 
END IF; 

SELECT GROUP_CONCAT(taxname) INTO @ptaxname FROM LD_inventorytaxinfo WHERE deleted = 0 AND taxid > 0 ORDER BY taxid; 
IF @ptaxname != '' THEN 
SET @ptaxname = REPLACE(@ptaxname,',',',0)+IFNULL('); 
SET @ptaxname = CONCAT('IFNULL(',@ptaxname,',0)'); 

SET @psql = CONCAT('SELECT lineitem_id as lineitemid,(listprice * 0.01 * (100 + (',@ptaxname,'))) as taxprice FROM ld_inventoryproductrel where listprice > 0 order by id;'); 
set @viewquery = 'drop view if exists updatetax_view'; 
PREPARE stmt from @viewquery; 
EXECUTE stmt; 
DEALLOCATE PREPARE stmt; 
set @viewquery = CONCAT('create view updatetax_view as ',@psql); 
PREPARE stmt from @viewquery; 
EXECUTE stmt; 
DEALLOCATE PREPARE stmt; 
ELSE 
SET @psql = CONCAT('SELECT lineitem_id as lineitemid,0 as taxprice FROM ld_inventoryproductrel where listprice > 0 order by id;'); 
set @viewquery = 'drop view if exists updatetax_view'; 
PREPARE stmt from @viewquery; 
EXECUTE stmt; 
DEALLOCATE PREPARE stmt; 
set @viewquery = CONCAT('create view updatetax_view as ',@psql); 
PREPARE stmt from @viewquery; 
EXECUTE stmt; 
DEALLOCATE PREPARE stmt; 
END IF; 
END ||
delimiter; 

DROP PROCEDURE IF EXISTS updateTaxPrice_cursor; 
delimiter || 
CREATE PROCEDURE updateTaxPrice_cursor() 
BEGIN 
DECLARE done int DEFAULT 0; 
DECLARE plineitemid int(11); -- 唯一键值 
DECLARE ptaxprice decimal(25,3); -- 含税单价 
DECLARE ptaxresult CURSOR FOR SELECT lineitemid,taxprice FROM updatetax_view; 
DECLARE CONTINUE HANDLER for not found set done = 1; 
OPEN ptaxresult;-- 打开游标 
FETCH ptaxresult INTO plineitemid,ptaxprice; 
LOOP1: WHILE done <> 1 DO 
IF @ptaxprice > 0 THEN 
SET @psql = CONCAT('UPDATE ld_inventoryproductrel set taxprice = ',@ptaxprice,' WHERE lineitem_id = ',plineitemid,' '); 
PREPARE stmt from @psql; 
EXECUTE stmt; 
DEALLOCATE PREPARE stmt; 
END IF; 
FETCH ptaxresult INTO plineitemid,ptaxprice; 
END WHILE LOOP1; 
CLOSE ptaxresult;-- 关闭游标 
END || 
delimiter; 

CALL updateTaxPrice_createview(); 
delimiter; 
CALL updateTaxPrice_cursor(); 
delimiter; 
DROP PROCEDURE IF EXISTS updateTaxPrice_createview; 
DROP PROCEDURE IF EXISTS updateTaxPrice_cursor; 
DROP VIEW IF EXISTS updatetax_view; 
delimiter;


INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype) SELECT 'zh','PRODUCTLIST_TAXPRICE','含税单价','fixedstr' FROM DUAL
WHERE NOT EXISTS(SELECT 1 FROM ld_desk WHERE languagetype='zh' AND labelbol='PRODUCTLIST_TAXPRICE' AND Labeltype='fixedstr');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype) SELECT 'en','PRODUCTLIST_TAXPRICE','Tax-inclusive unit price','fixedstr' FROM DUAL
WHERE NOT EXISTS(SELECT 1 FROM ld_desk WHERE languagetype='en' AND labelbol='PRODUCTLIST_TAXPRICE' AND Labeltype='fixedstr');
delimiter;

INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype) SELECT 'zh','PRODUCTLIST_LISTPRICE','不含税单价','fixedstr' FROM DUAL
WHERE NOT EXISTS(SELECT 1 FROM ld_desk WHERE languagetype='zh' AND labelbol='PRODUCTLIST_LISTPRICE' AND Labeltype='fixedstr');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype) SELECT 'en','PRODUCTLIST_LISTPRICE','Tax-free unit price','fixedstr' FROM DUAL
WHERE NOT EXISTS(SELECT 1 FROM ld_desk WHERE languagetype='en' AND labelbol='PRODUCTLIST_LISTPRICE' AND Labeltype='fixedstr');
delimiter;

INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype) SELECT 'zh','PRODUCTLIST_AMOUNT','不含税金额','fixedstr' FROM DUAL
WHERE NOT EXISTS(SELECT 1 FROM ld_desk WHERE languagetype='zh' AND labelbol='PRODUCTLIST_AMOUNT' AND Labeltype='fixedstr');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype) SELECT 'en','PRODUCTLIST_AMOUNT','Tax-free unit amount','fixedstr' FROM DUAL
WHERE NOT EXISTS(SELECT 1 FROM ld_desk WHERE languagetype='en' AND labelbol='PRODUCTLIST_AMOUNT' AND Labeltype='fixedstr');
delimiter;

INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype) SELECT 'zh','PRODUCTLIST_NETPRICE','含税金额','fixedstr' FROM DUAL
WHERE NOT EXISTS(SELECT 1 FROM ld_desk WHERE languagetype='zh' AND labelbol='PRODUCTLIST_NETPRICE' AND Labeltype='fixedstr');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype) SELECT 'en','PRODUCTLIST_NETPRICE','Tax-inclusive amount','fixedstr' FROM DUAL
WHERE NOT EXISTS(SELECT 1 FROM ld_desk WHERE languagetype='en' AND labelbol='PRODUCTLIST_NETPRICE' AND Labeltype='fixedstr');
delimiter;
-- end 2014-10-13

update ld_field set quickcreate=3 where tabid in(select tabid from ld_tab where name='paymentplan' or name='sendpayment');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','THETOTALOUTBOUNDQUANTITY','产品累计出库数量超过可出库数量，保存失败！','jspop' from dual
where not EXISTS(select 1 from ld_desk  where languagetype='zh' and labelbol='THETOTALOUTBOUNDQUANTITY'
and Labeltype='jspop');

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'en','THETOTALOUTBOUNDQUANTITY',
'The total Outbound quantity of products is greater than the allowable quantity,save failed.','jspop' from dual
where not EXISTS(select 1 from ld_desk  where languagetype='en' and labelbol='THETOTALOUTBOUNDQUANTITY'
and Labeltype='jspop');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','THECUMULATIVEQUANTITY','累计出库数量','jspop' from dual
where not EXISTS(select 1 from ld_desk  where languagetype='zh' and labelbol='THECUMULATIVEQUANTITY'
and Labeltype='jspop');

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'en','THECUMULATIVEQUANTITY','Total','jspop' from dual
where not EXISTS(select 1 from ld_desk  where languagetype='en' and labelbol='THECUMULATIVEQUANTITY'
and Labeltype='jspop');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','BUTTHENUMBEROFTHEOUT','可出库数量','jspop' from dual
where not EXISTS(select 1 from ld_desk  where languagetype='zh' and labelbol='BUTTHENUMBEROFTHEOUT'
and Labeltype='jspop');

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'en','BUTTHENUMBEROFTHEOUT','Allowable','jspop' from dual
where not EXISTS(select 1 from ld_desk  where languagetype='en' and labelbol='BUTTHENUMBEROFTHEOUT'
and Labeltype='jspop');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','THECUMULATIVEQUANTITYSTOCK','累计入库数量','jspop' from dual
where not EXISTS(select 1 from ld_desk  where languagetype='zh' and labelbol='THECUMULATIVEQUANTITYSTOCK'
and Labeltype='jspop');

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'en','THECUMULATIVEQUANTITYSTOCK','Total','jspop' from dual
where not EXISTS(select 1 from ld_desk  where languagetype='en' and labelbol='THECUMULATIVEQUANTITYSTOCK'
and Labeltype='jspop');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','BUTTHENUMBEROFTHESTOCK','可出库数量','jspop' from dual
where not EXISTS(select 1 from ld_desk  where languagetype='zh' and labelbol='BUTTHENUMBEROFTHESTOCK'
and Labeltype='jspop');

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'en','BUTTHENUMBEROFTHESTOCK','Allowable','jspop' from dual
where not EXISTS(select 1 from ld_desk  where languagetype='en' and labelbol='BUTTHENUMBEROFTHESTOCK'
and Labeltype='jspop');
delimiter;

DROP PROCEDURE IF EXISTS updateParent_lineitem_id;
delimiter ||
CREATE PROCEDURE updateParent_lineitem_id()
BEGIN

declare done int default 0;
declare second_done int default 0;
declare p_crmid int default 1;
declare p_entitytypeid int default 0;
declare p_lineitem_id int default 0;
declare p_id int default 0;
DECLARE p_productid int default 0;
declare p_cnt int default 0;
declare p_salesorderid int default 0;
declare p_salesbackid int default 0;
declare p_purchasebackid int default 0;
declare p_purchaseorder_id int default 0;

declare cur2 CURSOR FOR select crmid,lineitem_id,productid from ld_inventoryproductrel inner join ld_crmentity on ld_inventoryproductrel.id = ld_crmentity.crmid where ld_crmentity.setype in('SalesOrder','PurchaseOrder');
declare cur4 CURSOR FOR select salesbackid,salesorderid from ld_salesback where salesorderid > 0;
declare cur5 CURSOR FOR select purchasebackid,purchaseorder_id from ld_purchaseback where purchaseorder_id > 0;
declare continue handler for not found SET done =1;
-- 销售退货单产品明细表中加上对应的退货单-原单ID
open cur4;
fetch cur4 into p_salesbackid,p_salesorderid;
while done <>1 DO
update ld_inventoryproductrel set entitytypeid = p_salesorderid where id = p_salesbackid;
fetch cur4 into p_salesbackid,p_salesorderid;
end while;
close cur4;

-- 采购退货单产品明细表中加上对应的退货单-原单ID
set done = 0;
open cur5;
fetch cur5 into p_purchasebackid,p_purchaseorder_id;
while done <>1 DO
update ld_inventoryproductrel set entitytypeid = p_purchaseorder_id where id = p_purchasebackid;
fetch cur5 into p_purchasebackid,p_purchaseorder_id;
end while;
close cur5;

set done = 0;
open cur2;
fetch cur2 into p_crmid,p_lineitem_id,p_productid;
loop2: while done<>1 do
update ld_inventoryproductrel set parent_lineitem_id = p_lineitem_id where entitytypeid = p_crmid and productid = p_productid;
fetch cur2 into p_crmid,p_lineitem_id,p_productid;
end while loop2;
close cur2;

END ||
delimiter;

call updateParent_lineitem_id();
delimiter;

update ld_settings_field_seq set id = (select max(fieldid) from LD_settings_field);
select id into @id from ld_settings_field_seq;
select max(sequence) into @sequence from LD_settings_field where blockid = 5 and active = 0 ;
insert into LD_settings_field(fieldid,blockid,name,iconpath,description,linkto,sequence,active)
select @id+1,5,'LBL_PHONESTEWARD_SET','migrate.png','LBL_PHONESTEWARD_SET_DESCRIPTION','index.php?module=Settings&action=PhoneSteward&parenttab=Settings',@sequence+1,0
from dual where not EXISTS(select 1 from LD_settings_field where name ='LBL_PHONESTEWARD_SET');
update ld_settings_field_seq set id = (select max(fieldid) from LD_settings_field);
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'zh','LBL_PHONESTEWARD_SET','电话管家参数','fixedstr' from dual
where not EXISTS(select 1 from ld_desk where languagetype='zh' and labelbol='LBL_PHONESTEWARD_SET' and Labeltype='fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'en','LBL_PHONESTEWARD_SET','Phone Steward Parameters','fixedstr' from dual
where not EXISTS(select 1 from ld_desk where languagetype='en' and labelbol='LBL_PHONESTEWARD_SET' and Labeltype='fixedstr');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'zh','LBL_PHONESTEWARD_SET_DESCRIPTION','设置对应模块中的电话或者手机类型字段','fixedstr' from dual
where not EXISTS(select 1 from ld_desk where languagetype='zh' and labelbol='LBL_PHONESTEWARD_SET_DESCRIPTION' and Labeltype='fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'en','LBL_PHONESTEWARD_SET_DESCRIPTION','Set the phone or mobile phone type field in the corresponding module','fixedstr' from dual
where not EXISTS(select 1 from ld_desk where languagetype='en' and labelbol='LBL_PHONESTEWARD_SET_DESCRIPTION' and Labeltype='fixedstr');
delimiter;
call addcolumn('LD_field','callchecked','int','1',0);
delimiter;

update ld_field set callchecked =1 where tabid = 6 and columnname = 'phone' and presence<>1;
delimiter;
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'zh','CALLBOMBSCREEN','呼叫弹屏','fixedstr' from dual
where not EXISTS(select 1 from ld_desk  where languagetype='zh' and labelbol='CALLBOMBSCREEN' and Labeltype='fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'en','CALLBOMBSCREEN','Call bomb screen','fixedstr' from dual
where not EXISTS(select 1 from ld_desk  where languagetype='en' and labelbol='CALLBOMBSCREEN' and Labeltype='fixedstr');
delimiter;
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'zh','HOTLINENUMBER','热线号码：','fixedstr' from dual
where not EXISTS(select 1 from ld_desk  where languagetype='zh' and labelbol='HOTLINENUMBER' and Labeltype='fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'en','HOTLINENUMBER','Hotline number:','fixedstr' from dual
where not EXISTS(select 1 from ld_desk  where languagetype='en' and labelbol='HOTLINENUMBER' and Labeltype='fixedstr');
delimiter;
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'zh','PLEASESELECTSCREEN','，请选择需要的弹屏界面！','fixedstr' from dual
where not EXISTS(select 1 from ld_desk  where languagetype='zh' and labelbol='PLEASESELECTSCREEN' and Labeltype='fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'en','PLEASESELECTSCREEN',', Please select the interface, elastic screen!','fixedstr' from dual
where not EXISTS(select 1 from ld_desk  where languagetype='en' and labelbol='PLEASESELECTSCREEN' and Labeltype='fixedstr');
delimiter;

select tabid into @tabid from ld_tab where `name`='ServiceCharge';
update ld_field set displaytype = 2 where tabid = @tabid and fieldname='assigned_user_id';
update ld_field set displaytype = 1,uitype=53 where tabid = @tabid and fieldname='servicecasher';
delimiter;
-- end 2014-10-16


update ld_settings_field set blockid = '3',iconpath = 'ViewTemplate.png',description='EMAILTEMPLATESMANAGE',linkto='index.php?module=EmailListtmp&action=index&parenttab=Marketing',active = '0' where name='EMAILTEMPLATES';
delimiter;

select id into @id from ld_settings_field_seq;
select sequence into @sequence from LD_settings_field where name = 'LBL_PAGE_SET';
update LD_settings_field set sequence = sequence+1 where blockid = 3 and sequence > @sequence;
delimiter;

insert into LD_settings_field(fieldid,blockid,name,iconpath,description,linkto,sequence,active)
select @id+1,3,'SMS_templates','ViewTemplate.png','SMSTEMPLATESMANAGE','index.php?module=SmsPhrases&action=index&parenttab=Marketing',@sequence+1,0
from dual where not EXISTS(select 1 from LD_settings_field where name ='SMS_templates');
update ld_settings_field_seq set id = (select max(fieldid) from LD_settings_field);
delimiter;

select id into @id from ld_settings_field_seq;
select sequence into @sequence from LD_settings_field where name = 'LBL_PAGE_SET';
update LD_settings_field set sequence = sequence+1 where blockid = 3 and sequence > @sequence;
delimiter;

insert into LD_settings_field(fieldid,blockid,name,iconpath,description,linkto,sequence,active)
select @id+1,3,'THEDOCUMENTTEMPLATE','ViewTemplate.png','THETEMPLATEMANAGEMENT','index.php?module=Documents&action=showindex&parenttab=Marketing',@sequence+1,0
from dual where not EXISTS(select 1 from LD_settings_field where name ='THEDOCUMENTTEMPLATE');
update ld_settings_field_seq set id = (select max(fieldid) from LD_settings_field);
delimiter;

update ld_desk set Fieldlabel='{$PurchaseOrder.PurchaseOrder}新增保存后是否立即创建{$SendPayment.SendPayment}' where labelbol='WHETHERIMMCREATESENDPAYMENT' and languagetype='zh' and Labeltype = 'fixedstr';
update ld_desk set Fieldlabel='{$SalesOrder.SalesOrder}新增保存后是否立即创建{$PaymentPlan.PaymentPlan}' where labelbol='WHETHERIMMCREATEPAYMENTPLAN' and languagetype='zh' and Labeltype = 'fixedstr';
delimiter;
-- end 2014-10-17

select 'PaymentPlan' into @tabname;
select 'projectstatus' into @columnname;
select 'Related project state' into @en;
select '回款时项目状态' into @zh;

select tabid into @tabid from ld_tab where name=@tabname;
select ifnull(max(fieldid),0) into @maxid from ld_field;
select blockid into @blockid from ld_blocks where tabid=@tabid and blocklabel='LBL_PaymentPlan_INFORMATION';
select ifnull(max(sequence),0) into @seq from ld_field where tabid=@tabid and block=@blockid;
select sequence into @sequence from ld_field WHERE columnname='plandate' AND tabid=@tabid;

insert into ld_field (tabid,fieldid,columnname,tablename,generatedtype,uitype,fieldname,fieldlabel,readonly,presence,defaultvalue,maximumlength,sequence,block,displaytype,typeofdata,quickcreate,quickcreatesequence,info_type,masseditable,helpinfo,fieldonly)
select @tabid,@maxid+1,@columnname,'LD_paymentplan',1,15,@columnname,@columnname,0,1,'',100,@sequence-1,@blockid,1,'V~O',1,NULL,'BAS',1,NULL,0
from dual where  not exists (select 1 from  ld_field where tabid=@tabid and columnname=@columnname);

update ld_field_seq set id=(select max(fieldid) from ld_field);

select fieldid into @relateid from ld_field where tabid=@tabid and columnname=@columnname;
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'zh','LD_field',@tabid,@relateid,@zh from dual
where not EXISTS(select 1 from ld_tranlabel where languagetype='zh' and relateid=@relateid and trantable='LD_field');

insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'en','LD_field',@tabid,@relateid,@en from dual
where not EXISTS(select 1 from ld_tranlabel where languagetype='en' and relateid=@relateid and trantable='LD_field');

select max(picklistid) into @picklistid from ld_picklist;
insert into ld_picklist
select @picklistid+1,'projectstatus' from dual
where not exists (select 1 from ld_picklist where name='projectstatus');
update ld_picklist_seq set id=(select max(picklistid) from ld_picklist);

call addcolumn('LD_paymentplan',@columnname,'Varchar','100',null);
call fieldprofile(@tabname);
call getallprofile(@tabname);
delimiter;

insert into ld_systems_deploy(deploy_value,deploy_type,description,setype)
select 2,53,'回款计划按照项目状态收款和提醒','' from dual where not exists
(select 1 from ld_systems_deploy where deploy_type=53);
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'zh','PaymentPlanaccordingtoProjectstatustoremindandgetcash','{$PaymentPlan.PaymentPlan}按照{$Project.Project}状态收款和提醒','fixedstr' from dual
where not EXISTS(select 1 from ld_desk  where languagetype='zh' and labelbol='PaymentPlanaccordingtoProjectstatustoremindandgetcash' and Labeltype='fixedstr');

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'en','PaymentPlanaccordingtoProjectstatustoremindandgetcash','{$PaymentPlan.PaymentPlan} according to {$Project.Project} status to remind and get cash','fixedstr' from dual
where not EXISTS(select 1 from ld_desk  where languagetype='en' and labelbol='PaymentPlanaccordingtoProjectstatustoremindandgetcash' and Labeltype='fixedstr');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'zh','Paymentwhentheprojectstatus','回款时项目状态','fixedstr' from dual
where not EXISTS(select 1 from ld_desk  where languagetype='zh' and labelbol='Paymentwhentheprojectstatus' and Labeltype='fixedstr');

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'en','Paymentwhentheprojectstatus','Payment when the project status','fixedstr' from dual
where not EXISTS(select 1 from ld_desk  where languagetype='en' and labelbol='Paymentwhentheprojectstatus' and Labeltype='fixedstr');
delimiter;

call addcolumn('LD_users','login_sms','int','11',0);
call fieldprofile('LD_users');
call getallprofile('LD_users');
delimiter;

select tabid into @tabid from ld_tab where `name` = 'Users';
SELECT sequence into @sequence from ld_blocks where tabid=@tabid and blocklabel='LBL_USER_IMAGE_INFORMATION';
UPDATE ld_blocks set sequence=sequence+1 where tabid=@tabid and sequence>=@sequence;
select max(blockid) into @maxblockid from ld_blocks;
insert into ld_blocks(blockid,tabid,blocklabel,sequence)
select @maxblockid+1,@tabid,'LBL_USER_ENABLESMSVERIFICATION',@sequence from dual where not exists (select * from ld_blocks where
tabid = @tabid and blocklabel = 'LBL_USER_ENABLESMSVERIFICATION' );
UPDATE ld_blocks_seq set id=(select max(blockid) from ld_blocks);
delimiter;

select tabid into @tabid from ld_tab where `name` = 'Users';
select blockid into @blockid from ld_blocks where tabid = @tabid and blocklabel = 'LBL_USER_ENABLESMSVERIFICATION';
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'zh','LD_blocks',@tabid,@blockid,'登录手机短信验证'
from dual where not EXISTS(select 1 from ld_tranlabel  where languagetype = 'zh'
and trantable ='LD_blocks' and tabid = @tabid and fieldlabel='登录手机短信验证');
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'en','LD_blocks',@tabid,@blockid,'Mobile phone short message authentication login'
from dual where not EXISTS(select 1 from ld_tranlabel  where languagetype = 'en'
and trantable ='LD_blocks' and tabid = @tabid and fieldlabel='Mobile phone short message authentication login');
delimiter;

select tabid into @tabid from ld_tab where `name` = 'Users';
SELECT max(fieldid) into @maxid from ld_field;
SELECT max(sequence) into @sequence from ld_field where tabid=@tabid;
SELECT blockid INTO @blockid from ld_blocks where tabid=@tabid and blocklabel='LBL_USER_ENABLESMSVERIFICATION';
insert into ld_field (tabid,fieldid,columnname,tablename,generatedtype,uitype,fieldname,fieldlabel,readonly,presence,defaultvalue,maximumlength,sequence,block,displaytype,typeofdata,quickcreate,quickcreatesequence,info_type,masseditable,helpinfo,fieldonly)
select @tabid,@maxid+1,'login_sms','LD_users',1,56,'login_sms','登录手机短信验证',1,0,'','',@sequence+1,@blockid,1,'V~O',3,'','BAS',2,NULL,0
from dual where  not exists (select 1 from  ld_field where tabid=@tabid and columnname='login_sms');
UPDATE ld_field_seq set id=(SELECT max(fieldid) from ld_field);
delimiter;

select tabid into @tabid from ld_tab where `name` = 'Users';
select fieldid into @fieldid from ld_field where tabid = @tabid and fieldname = 'login_sms';
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'zh','LD_field',@tabid,@fieldid,'登录时启用手机短信验证(需购买并设置通讯账户)'
from dual where not EXISTS(select 1 from ld_tranlabel  where languagetype = 'zh'
and trantable ='LD_field' and tabid = @tabid and relateid = @fieldid);
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'en','LD_field',@tabid,@fieldid,'Enable SMS verification(Need to buy communication account first)'
from dual where not EXISTS(select 1 from ld_tranlabel  where languagetype = 'en'
and trantable ='LD_field' and tabid = @tabid and relateid = @fieldid);
delimiter;

CREATE TABLE IF NOT EXISTS `ld_userlogincodeentries` (
  `user_name` varchar(255) default NULL,
  `security_code` varchar(25) default NULL,
  `mobile` varchar(25) default NULL,
  `lastsendsmstime` datetime default NULL,
  `codeisvalid` int(11) default '0',
  `machinename` varchar(100) default NULL,
  `user_ip` varchar(50) default NULL
) ENGINE=MyISAM DEFAULT CHARSET=utf8;
delimiter;

call addcolumn('LD_loginhistory','machinename','varchar','100',null);
delimiter;

call addcolumn('LD_loginhistory','whethercodelogin','int','4','0');
delimiter;

call addcolumn('LD_loginhistory','mobile','varchar','25',null);
delimiter;

call addcolumn('LD_loginhistory','security_code','varchar','25',null);
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'zh','ACCOUNTSECURITYCENTER','账户安全中心','fixedstr' from dual
where not EXISTS(select 1 from ld_desk  where languagetype='zh' and labelbol='ACCOUNTSECURITYCENTER' and Labeltype='fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'en','ACCOUNTSECURITYCENTER','Account security center','fixedstr' from dual
where not EXISTS(select 1 from ld_desk  where languagetype='en' and labelbol='ACCOUNTSECURITYCENTER' and Labeltype='fixedstr');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'zh','MOBILEPHONENUMBERISNOTCORRECT','手机号码不正确，请联系管理员修改后再重新登录！','jspop' from dual
where not EXISTS(select 1 from ld_desk  where languagetype='zh' and labelbol='MOBILEPHONENUMBERISNOTCORRECT' and Labeltype='jspop');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'en','MOBILEPHONENUMBERISNOTCORRECT',"Mobile phone number is not correct, please contact the administrator to modify and then log in again!",'jspop' from dual
where not EXISTS(select 1 from ld_desk  where languagetype='en' and labelbol='MOBILEPHONENUMBERISNOTCORRECT' and Labeltype='jspop');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'zh','TOOBTAINTHEVERFICATIONCODE','重新获取验证码','jspop' from dual
where not EXISTS(select 1 from ld_desk  where languagetype='zh' and labelbol='TOOBTAINTHEVERFICATIONCODE' and Labeltype='jspop');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'en','TOOBTAINTHEVERFICATIONCODE','To obtain the verification code','jspop' from dual
where not EXISTS(select 1 from ld_desk  where languagetype='en' and labelbol='TOOBTAINTHEVERFICATIONCODE' and Labeltype='jspop');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'zh','PLEASEENTERTHECORRECTVERFICATIONCODE','请输入正确的验证码！','jspop' from dual
where not EXISTS(select 1 from ld_desk  where languagetype='zh' and labelbol='PLEASEENTERTHECORRECTVERFICATIONCODE' and Labeltype='jspop');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'en','PLEASEENTERTHECORRECTVERFICATIONCODE',"Please enter the correct verification code!",'jspop' from dual
where not EXISTS(select 1 from ld_desk  where languagetype='en' and labelbol='PLEASEENTERTHECORRECTVERFICATIONCODE' and Labeltype='jspop');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'zh','THEVERIFICATIONCODEHASEXPIRED','验证码已过期，请重新获取！','jspop' from dual
where not EXISTS(select 1 from ld_desk  where languagetype='zh' and labelbol='THEVERIFICATIONCODEHASEXPIRED' and Labeltype='jspop');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'en','THEVERIFICATIONCODEHASEXPIRED',"The verification code has expired, please obtain a new one!",'jspop' from dual
where not EXISTS(select 1 from ld_desk  where languagetype='en' and labelbol='THEVERIFICATIONCODEHASEXPIRED' and Labeltype='jspop');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'zh','THEOPERATIONFAILEDTRYAGAIN','操作失败，请重新尝试！','jspop' from dual
where not EXISTS(select 1 from ld_desk  where languagetype='zh' and labelbol='THEOPERATIONFAILEDTRYAGAIN' and Labeltype='jspop');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'en','THEOPERATIONFAILEDTRYAGAIN',"The operation failed, please try again!",'jspop' from dual
where not EXISTS(select 1 from ld_desk  where languagetype='en' and labelbol='THEOPERATIONFAILEDTRYAGAIN' and Labeltype='jspop');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'zh','VERIFICATIONCODESUCCESSFULLYSENT','验证码发送成功！','fixedstr' from dual
where not EXISTS(select 1 from ld_desk  where languagetype='zh' and labelbol='VERIFICATIONCODESUCCESSFULLYSENT' and Labeltype='fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'en','VERIFICATIONCODESUCCESSFULLYSENT',"Verification code successfully sent!",'fixedstr' from dual
where not EXISTS(select 1 from ld_desk  where languagetype='en' and labelbol='VERIFICATIONCODESUCCESSFULLYSENT' and Labeltype='fixedstr');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'zh','MOBILEPHONEVERFICATION','手机验证','fixedstr' from dual
where not EXISTS(select 1 from ld_desk  where languagetype='zh' and labelbol='MOBILEPHONEVERFICATION' and Labeltype='fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'en','MOBILEPHONEVERFICATION','Mobile phone verification','fixedstr' from dual
where not EXISTS(select 1 from ld_desk  where languagetype='en' and labelbol='MOBILEPHONEVERFICATION' and Labeltype='fixedstr');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'zh','INORDERTOPROTECTYOURACCOUNTSECURITY','为了保护您的账户安全，请先进行安全验证','fixedstr' from dual
where not EXISTS(select 1 from ld_desk  where languagetype='zh' and labelbol='INORDERTOPROTECTYOURACCOUNTSECURITY' and Labeltype='fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'en','INORDERTOPROTECTYOURACCOUNTSECURITY','In order to protect your account security, please perform the safety verification','fixedstr' from dual
where not EXISTS(select 1 from ld_desk  where languagetype='en' and labelbol='INORDERTOPROTECTYOURACCOUNTSECURITY' and Labeltype='fixedstr');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'zh','PLEASEENTERTHEMOBILEPHONENUMBER','请输入手机号','fixedstr' from dual
where not EXISTS(select 1 from ld_desk  where languagetype='zh' and labelbol='PLEASEENTERTHEMOBILEPHONENUMBER' and Labeltype='fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'en','PLEASEENTERTHEMOBILEPHONENUMBER','Please enter the mobile phone number','fixedstr' from dual
where not EXISTS(select 1 from ld_desk  where languagetype='en' and labelbol='PLEASEENTERTHEMOBILEPHONENUMBER' and Labeltype='fixedstr');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'zh','TOOBTAINTHEVERIFIFATIONCODE','获取验证码','fixedstr' from dual
where not EXISTS(select 1 from ld_desk  where languagetype='zh' and labelbol='TOOBTAINTHEVERIFIFATIONCODE' and Labeltype='fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'en','TOOBTAINTHEVERIFIFATIONCODE','To obtain the verification code','fixedstr' from dual
where not EXISTS(select 1 from ld_desk  where languagetype='en' and labelbol='TOOBTAINTHEVERIFIFATIONCODE' and Labeltype='fixedstr');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'zh','PLEASEENTERTHEVERIFIFATIONCODE','请输入收到的验证码','fixedstr' from dual
where not EXISTS(select 1 from ld_desk  where languagetype='zh' and labelbol='PLEASEENTERTHEVERIFIFATIONCODE' and Labeltype='fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'en','PLEASEENTERTHEVERIFIFATIONCODE','Please enter the verification code','fixedstr' from dual
where not EXISTS(select 1 from ld_desk  where languagetype='en' and labelbol='PLEASEENTERTHEVERIFIFATIONCODE' and Labeltype='fixedstr');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'zh','PLEASEENTERTHECORRECTMOBILEPHONENUMBER','请输入正确的手机号码','fixedstr' from dual
where not EXISTS(select 1 from ld_desk  where languagetype='zh' and labelbol='PLEASEENTERTHECORRECTMOBILEPHONENUMBER' and Labeltype='fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'en','PLEASEENTERTHECORRECTMOBILEPHONENUMBER','Please enter the correct mobile phone number','fixedstr' from dual
where not EXISTS(select 1 from ld_desk  where languagetype='en' and labelbol='PLEASEENTERTHECORRECTMOBILEPHONENUMBER' and Labeltype='fixedstr');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'zh','PLEASEENTERTHECORRECTVERFICATIONCODEZH','请输入正确的验证码！','fixedstr' from dual
where not EXISTS(select 1 from ld_desk  where languagetype='zh' and labelbol='PLEASEENTERTHECORRECTVERFICATIONCODEZH' and Labeltype='fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'en','PLEASEENTERTHECORRECTVERFICATIONCODEZH',"Please enter the correct verification code!",'fixedstr' from dual
where not EXISTS(select 1 from ld_desk  where languagetype='en' and labelbol='PLEASEENTERTHECORRECTVERFICATIONCODEZH' and Labeltype='fixedstr');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'zh','RELOGIN','重新登录','fixedstr' from dual
where not EXISTS(select 1 from ld_desk  where languagetype='zh' and labelbol='RELOGIN' and Labeltype='fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'en','RELOGIN',"Relogin",'fixedstr' from dual
where not EXISTS(select 1 from ld_desk  where languagetype='en' and labelbol='RELOGIN' and Labeltype='fixedstr');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'zh','WARMREMINDE','温馨提醒','fixedstr' from dual
where not EXISTS(select 1 from ld_desk  where languagetype='zh' and labelbol='WARMREMINDE' and Labeltype='fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'en','WARMREMINDE',"Warm reminder",'fixedstr' from dual
where not EXISTS(select 1 from ld_desk  where languagetype='en' and labelbol='WARMREMINDE' and Labeltype='fixedstr');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'zh','WARMREMINDEONE','1. 若用户已绑定手机，则无需再输入手机号。','fixedstr' from dual
where not EXISTS(select 1 from ld_desk  where languagetype='zh' and labelbol='WARMREMINDEONE' and Labeltype='fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'en','WARMREMINDEONE',"1. If have binding mobile phone,no need to enter the mobile phone number.",'fixedstr' from dual
where not EXISTS(select 1 from ld_desk  where languagetype='en' and labelbol='WARMREMINDEONE' and Labeltype='fixedstr');

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'zh','WARMREMINDETWO','2. 若用户未绑定手机，则可输入手机号，获取验证码登录后自动绑定该手机。','fixedstr' from dual
where not EXISTS(select 1 from ld_desk  where languagetype='zh' and labelbol='WARMREMINDETWO' and Labeltype='fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'en','WARMREMINDETWO',"2. If no binding mobile phone, need to enter the mobile phone number, after using the verification code to log in the system will automatically bind the mobile phone.",'fixedstr' from dual
where not EXISTS(select 1 from ld_desk  where languagetype='en' and labelbol='WARMREMINDETWO' and Labeltype='fixedstr');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'zh','WARMREMINDETHREEE','3. 同一客户端24小时内只需要验证一次。','fixedstr' from dual
where not EXISTS(select 1 from ld_desk  where languagetype='zh' and labelbol='WARMREMINDETHREEE' and Labeltype='fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'en','WARMREMINDETHREEE',"3. 24 hours just need to verify once at the same client.",'fixedstr' from dual
where not EXISTS(select 1 from ld_desk  where languagetype='en' and labelbol='WARMREMINDETHREEE' and Labeltype='fixedstr');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'zh','WARMREMINDEFOR','4. 若无法获取验证码，请联系您的营销顾问。','fixedstr' from dual
where not EXISTS(select 1 from ld_desk  where languagetype='zh' and labelbol='WARMREMINDEFOR' and Labeltype='fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'en','WARMREMINDEFOR',"4. If unable to obtain the verification code, please contact your sales consultant.",'fixedstr' from dual
where not EXISTS(select 1 from ld_desk  where languagetype='en' and labelbol='WARMREMINDEFOR' and Labeltype='fixedstr');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'zh','ENTERTHEVERIFICATIONCODEISRECEIVED','请输入验证码','fixedstr' from dual
where not EXISTS(select 1 from ld_desk  where languagetype='zh' and labelbol='ENTERTHEVERIFICATIONCODEISRECEIVED' and Labeltype='fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'en','ENTERTHEVERIFICATIONCODEISRECEIVED',"Please enter the verification code",'fixedstr' from dual
where not EXISTS(select 1 from ld_desk  where languagetype='en' and labelbol='ENTERTHEVERIFICATIONCODEISRECEIVED' and Labeltype='fixedstr');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'zh','PLEASEENTERTHEMOBILEPHONENUMBEREN','请输入手机号','jspop' from dual
where not EXISTS(select 1 from ld_desk  where languagetype='zh' and labelbol='PLEASEENTERTHEMOBILEPHONENUMBEREN' and Labeltype='jspop');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'en','PLEASEENTERTHEMOBILEPHONENUMBEREN','Please enter the mobile phone number','jspop' from dual
where not EXISTS(select 1 from ld_desk  where languagetype='en' and labelbol='PLEASEENTERTHEMOBILEPHONENUMBEREN' and Labeltype='jspop');

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'zh','PLEASEENTERTHEVERIFIFATIONCODEEN','请输入收到的验证码','jspop' from dual
where not EXISTS(select 1 from ld_desk  where languagetype='zh' and labelbol='PLEASEENTERTHEVERIFIFATIONCODEEN' and Labeltype='jspop');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'en','PLEASEENTERTHEVERIFIFATIONCODEEN','Please enter the verification code','jspop' from dual
where not EXISTS(select 1 from ld_desk  where languagetype='en' and labelbol='PLEASEENTERTHEVERIFIFATIONCODEEN' and Labeltype='jspop');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'zh','MACHINENAME','机器名称','fixedstr' from dual
where not EXISTS(select 1 from ld_desk  where languagetype='zh' and labelbol='MACHINENAME' and Labeltype='fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'en','MACHINENAME',"machine name",'fixedstr' from dual
where not EXISTS(select 1 from ld_desk  where languagetype='en' and labelbol='MACHINENAME' and Labeltype='fixedstr');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'zh','WHETHERTHEMOBILELANGING','是否手机登陆','fixedstr' from dual
where not EXISTS(select 1 from ld_desk  where languagetype='zh' and labelbol='WHETHERTHEMOBILELANGING' and Labeltype='fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'en','WHETHERTHEMOBILELANGING',"Whether the mobile phone landing",'fixedstr' from dual
where not EXISTS(select 1 from ld_desk  where languagetype='en' and labelbol='WHETHERTHEMOBILELANGING' and Labeltype='fixedstr');
delimiter;

update ld_desk set Fieldlabel='邮件模板' where labelbol='EMAILTEMPLATES' and languagetype='zh' and Labeltype = 'fixedstr';
delimiter;
-- 2014-10-20

ALTER TABLE LD_currency_info MODIFY conversion_rate DECIMAL(13,6);

SELECT MAX(id) into @currencyid FROM LD_currency_info;
INSERT INTO LD_currency_info(id,currency_name,currency_code,currency_symbol,conversion_rate,currency_status,defaultid,deleted)
SELECT @currencyid+1,'Euro','EUR','€','0.117647','Inactive','0','0' FROM DUAL
WHERE NOT EXISTS(SELECT 1 FROM LD_currency_info WHERE currency_name='Euro' AND currency_code='EUR' AND currency_symbol='€');
delimiter;

SELECT MAX(taxid) into @taxid FROM LD_inventorytaxinfo;
INSERT INTO LD_inventorytaxinfo(taxid,taxname,taxlabel,percentage,deleted)
SELECT @taxid+1,'tax_customs','关税','108.00','1' FROM DUAL
WHERE NOT EXISTS(SELECT 1 FROM LD_inventorytaxinfo WHERE taxname='tax_customs');

INSERT INTO LD_inventorytaxinfo(taxid,taxname,taxlabel,percentage,deleted)
SELECT @taxid+2,'tax_added','增值税','117.00','1' FROM DUAL
WHERE NOT EXISTS(SELECT 1 FROM LD_inventorytaxinfo WHERE taxname='tax_added');

INSERT INTO LD_inventorytaxinfo(taxid,taxname,taxlabel,percentage,deleted)
SELECT @taxid+3,'tax_profit','利润率','130.00','1' FROM DUAL
WHERE NOT EXISTS(SELECT 1 FROM LD_inventorytaxinfo WHERE taxname='tax_profit');

INSERT INTO LD_inventorytaxinfo(taxid,taxname,taxlabel,percentage,deleted)
SELECT @taxid+4,'tax_freight','运费系数','105.00','1' FROM DUAL
WHERE NOT EXISTS(SELECT 1 FROM LD_inventorytaxinfo WHERE taxname='tax_freight');
delimiter;
CALL AddColumn('ld_inventoryproductrel','rmbprice','decimal','7',0);-- 欧元含税单价
ALTER TABLE ld_inventoryproductrel MODIFY rmbprice DECIMAL(25,3);
CALL AddColumn('ld_inventoryproductrel','tax_customs','decimal','7',0);
ALTER TABLE ld_inventoryproductrel MODIFY tax_customs DECIMAL(7,3);
CALL AddColumn('ld_inventoryproductrel','tax_added','decimal','7',0);
ALTER TABLE ld_inventoryproductrel MODIFY tax_added DECIMAL(7,3);
CALL AddColumn('ld_inventoryproductrel','tax_freight','decimal','7',0);
ALTER TABLE ld_inventoryproductrel MODIFY tax_freight DECIMAL(7,3);
CALL AddColumn('ld_inventoryproductrel','tax_rate','decimal','7',0);-- 汇率
ALTER TABLE ld_inventoryproductrel MODIFY tax_rate DECIMAL(10,6);
delimiter;

insert into ld_systems_deploy(deploy_value,deploy_type,description,setype)
select '0',52,'表体产品明细录入样式 0:标准行业 1:外贸行业','' from dual
where not exists (select 1 from ld_systems_deploy where deploy_type=52);
delimiter;

INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
	SELECT 'zh','PRODUCTSDETAILSTITLE','表体产品明细录入样式','fixedstr'
		FROM DUAL WHERE NOT EXISTS
	(SELECT 1 FROM ld_desk  WHERE languagetype='zh' AND
		labelbol='PRODUCTSDETAILSTITLE' AND Labeltype='fixedstr');

INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
	SELECT 'en','PRODUCTSDETAILSTITLE','The input style of products details','fixedstr'
	FROM DUAL WHERE NOT EXISTS
	(SELECT 1 FROM ld_desk  WHERE languagetype='en' AND
		labelbol='PRODUCTSDETAILSTITLE' AND Labeltype='fixedstr');

INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
	SELECT 'zh','PRODUCTSDETAILSSTANDARD','标准行业','fixedstr'
		FROM DUAL WHERE NOT EXISTS
	(SELECT 1 FROM ld_desk  WHERE languagetype='zh' AND
		labelbol='PRODUCTSDETAILSSTANDARD' AND Labeltype='fixedstr');

INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
	SELECT 'en','PRODUCTSDETAILSSTANDARD','standard','fixedstr'
	FROM DUAL WHERE NOT EXISTS
	(SELECT 1 FROM ld_desk  WHERE languagetype='en' AND
		labelbol='PRODUCTSDETAILSSTANDARD' AND Labeltype='fixedstr');

INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
	SELECT 'zh','PRODUCTSDETAILSFOREIGNTRAD','外贸行业','fixedstr'
		FROM DUAL WHERE NOT EXISTS
	(SELECT 1 FROM ld_desk  WHERE languagetype='zh' AND
		labelbol='PRODUCTSDETAILSFOREIGNTRAD' AND Labeltype='fixedstr');

INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
	SELECT 'en','PRODUCTSDETAILSFOREIGNTRAD','foreign trad','fixedstr'
	FROM DUAL WHERE NOT EXISTS
	(SELECT 1 FROM ld_desk  WHERE languagetype='en' AND
		labelbol='PRODUCTSDETAILSFOREIGNTRAD' AND Labeltype='fixedstr');

INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
	SELECT 'zh','RMB_TAXPRICE_LABEL','RMB含税单价','fixedstr'
		FROM DUAL WHERE NOT EXISTS
	(SELECT 1 FROM ld_desk  WHERE languagetype='zh' AND
		labelbol='RMB_TAXPRICE_LABEL' AND Labeltype='fixedstr');

INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
	SELECT 'en','RMB_TAXPRICE_LABEL','RMB Price With Tax','fixedstr'
	FROM DUAL WHERE NOT EXISTS
	(SELECT 1 FROM ld_desk  WHERE languagetype='en' AND
		labelbol='RMB_TAXPRICE_LABEL' AND Labeltype='fixedstr');

INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
	SELECT 'zh','RMB_AMOUNT_LABEL','RMB含税总价','fixedstr'
		FROM DUAL WHERE NOT EXISTS
	(SELECT 1 FROM ld_desk  WHERE languagetype='zh' AND
		labelbol='RMB_AMOUNT_LABEL' AND Labeltype='fixedstr');

INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
	SELECT 'en','RMB_AMOUNT_LABEL','RMB amount With Tax','fixedstr'
	FROM DUAL WHERE NOT EXISTS
	(SELECT 1 FROM ld_desk  WHERE languagetype='en' AND
		labelbol='RMB_AMOUNT_LABEL' AND Labeltype='fixedstr');

INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
	SELECT 'zh','RMB_EUR_STANDARDPRICE','欧元标准单价','fixedstr'
		FROM DUAL WHERE NOT EXISTS
	(SELECT 1 FROM ld_desk  WHERE languagetype='zh' AND
		labelbol='RMB_EUR_STANDARDPRICE' AND Labeltype='fixedstr');

INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
	SELECT 'en','RMB_EUR_STANDARDPRICE','EUR Standard Price','fixedstr'
	FROM DUAL WHERE NOT EXISTS
	(SELECT 1 FROM ld_desk  WHERE languagetype='en' AND
		labelbol='RMB_EUR_STANDARDPRICE' AND Labeltype='fixedstr');

INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
	SELECT 'zh','RMB_DISCOUNT_RATE','欧元折扣率','fixedstr'
		FROM DUAL WHERE NOT EXISTS
	(SELECT 1 FROM ld_desk  WHERE languagetype='zh' AND
		labelbol='RMB_DISCOUNT_RATE' AND Labeltype='fixedstr');

INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
	SELECT 'en','RMB_DISCOUNT_RATE','Discount Rate','fixedstr'
	FROM DUAL WHERE NOT EXISTS
	(SELECT 1 FROM ld_desk  WHERE languagetype='en' AND
		labelbol='RMB_DISCOUNT_RATE' AND Labeltype='fixedstr');

INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
	SELECT 'zh','RMB_EUR_PRICE','欧元单价','fixedstr'
		FROM DUAL WHERE NOT EXISTS
	(SELECT 1 FROM ld_desk  WHERE languagetype='zh' AND
		labelbol='RMB_EUR_PRICE' AND Labeltype='fixedstr');

INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
	SELECT 'en','RMB_EUR_PRICE','EUR Price','fixedstr'
	FROM DUAL WHERE NOT EXISTS
	(SELECT 1 FROM ld_desk  WHERE languagetype='en' AND
		labelbol='RMB_EUR_PRICE' AND Labeltype='fixedstr');

INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
	SELECT 'zh','Exchange Rate','汇率','fixedstr'
		FROM DUAL WHERE NOT EXISTS
	(SELECT 1 FROM ld_desk  WHERE languagetype='zh' AND
		labelbol='Exchange Rate' AND Labeltype='fixedstr');

INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
	SELECT 'en','Exchange Rate','Exchange Rate','fixedstr'
	FROM DUAL WHERE NOT EXISTS
	(SELECT 1 FROM ld_desk  WHERE languagetype='en' AND
		labelbol='Exchange Rate' AND Labeltype='fixedstr');

INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
	SELECT 'zh','RMB_TARIFF_RATE','关税','fixedstr'
		FROM DUAL WHERE NOT EXISTS
	(SELECT 1 FROM ld_desk  WHERE languagetype='zh' AND
		labelbol='RMB_TARIFF_RATE' AND Labeltype='fixedstr');

INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
	SELECT 'en','RMB_TARIFF_RATE','Tariff','fixedstr'
	FROM DUAL WHERE NOT EXISTS
	(SELECT 1 FROM ld_desk  WHERE languagetype='en' AND
		labelbol='RMB_TARIFF_RATE' AND Labeltype='fixedstr');

INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
	SELECT 'zh','RMB_VAT_RATE','增值税','fixedstr'
		FROM DUAL WHERE NOT EXISTS
	(SELECT 1 FROM ld_desk  WHERE languagetype='zh' AND
		labelbol='RMB_VAT_RATE' AND Labeltype='fixedstr');

INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
	SELECT 'en','RMB_VAT_RATE','VAT','fixedstr'
	FROM DUAL WHERE NOT EXISTS
	(SELECT 1 FROM ld_desk  WHERE languagetype='en' AND
		labelbol='RMB_VAT_RATE' AND Labeltype='fixedstr');

INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
	SELECT 'zh','RMB_FREIGHT_COEFFICIENT','运费系数','fixedstr'
		FROM DUAL WHERE NOT EXISTS
	(SELECT 1 FROM ld_desk  WHERE languagetype='zh' AND
		labelbol='RMB_FREIGHT_COEFFICIENT' AND Labeltype='fixedstr');

INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
	SELECT 'en','RMB_FREIGHT_COEFFICIENT','Freight Coefficient','fixedstr'
	FROM DUAL WHERE NOT EXISTS
	(SELECT 1 FROM ld_desk  WHERE languagetype='en' AND
		labelbol='RMB_FREIGHT_COEFFICIENT' AND Labeltype='fixedstr');

INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
	SELECT 'zh','RMB_PROFIT_RATE','利润率','fixedstr'
		FROM DUAL WHERE NOT EXISTS
	(SELECT 1 FROM ld_desk  WHERE languagetype='zh' AND
		labelbol='RMB_PROFIT_RATE' AND Labeltype='fixedstr');

INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
	SELECT 'en','RMB_PROFIT_RATE','Profit Rate','fixedstr'
	FROM DUAL WHERE NOT EXISTS
	(SELECT 1 FROM ld_desk  WHERE languagetype='en' AND
		labelbol='RMB_PROFIT_RATE' AND Labeltype='fixedstr');

INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
	SELECT 'zh','RMB_SUBTOTAL','共计含税含运费RMB总价','fixedstr'
		FROM DUAL WHERE NOT EXISTS
	(SELECT 1 FROM ld_desk  WHERE languagetype='zh' AND
		labelbol='RMB_SUBTOTAL' AND Labeltype='fixedstr');

INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
	SELECT 'en','RMB_SUBTOTAL','RMB Subtotal','fixedstr'
	FROM DUAL WHERE NOT EXISTS
	(SELECT 1 FROM ld_desk  WHERE languagetype='en' AND
		labelbol='RMB_SUBTOTAL' AND Labeltype='fixedstr');
delimiter;

INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
	SELECT 'zh','RMB_DISCOUNT_AMOUNT','RMB折扣额','fixedstr'
		FROM DUAL WHERE NOT EXISTS
	(SELECT 1 FROM ld_desk  WHERE languagetype='zh' AND
		labelbol='RMB_DISCOUNT_AMOUNT' AND Labeltype='fixedstr');

INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
	SELECT 'en','RMB_DISCOUNT_AMOUNT','Discount Amount','fixedstr'
	FROM DUAL WHERE NOT EXISTS
	(SELECT 1 FROM ld_desk  WHERE languagetype='en' AND
		labelbol='RMB_DISCOUNT_AMOUNT' AND Labeltype='fixedstr');
delimiter;

call addcolumn('ld_communicationaccount','productid','int','11',0);
delimiter;
UPDATE ld_desk set  fieldlabel='短信发送失败，请联系管理员设置短信通讯账户' where labelbol='THEOPERATIONFAILEDTRYAGAIN' and Labeltype='jspop' and languagetype='zh';
UPDATE ld_desk set  fieldlabel='Send failed, please contact the administrator to set the SMS messaging account' where labelbol='THEOPERATIONFAILEDTRYAGAIN' and Labeltype='jspop' and languagetype='en';
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'zh','COMMUNICATIONACCOUNTISNOTSET','通讯账户未设置，请联系管理员','jspop' from dual
where not EXISTS(select 1 from ld_desk  where languagetype='zh' and labelbol='COMMUNICATIONACCOUNTISNOTSET' and Labeltype='jspop');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'en','COMMUNICATIONACCOUNTISNOTSET',"Communication account is not set, please contact the system administrator",'jspop' from dual
where not EXISTS(select 1 from ld_desk  where languagetype='en' and labelbol='COMMUNICATIONACCOUNTISNOTSET' and Labeltype='jspop');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'zh','COMMUNICATIONACCOUNTISNOTSETSUMISPOOR','通讯账户余额不足，请联系管理员','jspop' from dual
where not EXISTS(select 1 from ld_desk  where languagetype='zh' and labelbol='COMMUNICATIONACCOUNTISNOTSETSUMISPOOR' and Labeltype='jspop');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'en','COMMUNICATIONACCOUNTISNOTSETSUMISPOOR',"Communication account remaining sum is insufficient, please contact the system administrator",'jspop' from dual
where not EXISTS(select 1 from ld_desk  where languagetype='en' and labelbol='COMMUNICATIONACCOUNTISNOTSETSUMISPOOR' and Labeltype='jspop');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'zh','COMMUNICATIONACCOUNTISNOTSETEMPTY','通讯账户短信签名档为空，请联系管理员','jspop' from dual
where not EXISTS(select 1 from ld_desk  where languagetype='zh' and labelbol='COMMUNICATIONACCOUNTISNOTSETEMPTY' and Labeltype='jspop');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'en','COMMUNICATIONACCOUNTISNOTSETEMPTY',"Communication account SMS signature is empty, please contact the system administrator",'jspop' from dual
where not EXISTS(select 1 from ld_desk  where languagetype='en' and labelbol='COMMUNICATIONACCOUNTISNOTSETEMPTY' and Labeltype='jspop');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'zh','COMMUNICATIONACCOUNTISNOTSETEMPTYFAILED','短信发送失败，请联系管理员设置通讯账户','jspop' from dual
where not EXISTS(select 1 from ld_desk  where languagetype='zh' and labelbol='COMMUNICATIONACCOUNTISNOTSETEMPTYFAILED' and Labeltype='jspop');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'en','COMMUNICATIONACCOUNTISNOTSETEMPTYFAILED',"Send failed, please contact the administrator to set up communication account",'jspop' from dual
where not EXISTS(select 1 from ld_desk  where languagetype='en' and labelbol='COMMUNICATIONACCOUNTISNOTSETEMPTYFAILED' and Labeltype='jspop');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'zh','NOTFOUNDANYRECORD','没有找到任何记录！','jspop' from dual
where not EXISTS(select 1 from ld_desk  where languagetype='zh' and labelbol='NOTFOUNDANYRECORD' and Labeltype='jspop');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'en','NOTFOUNDANYRECORD','Not found any records!','jspop' from dual
where not EXISTS(select 1 from ld_desk  where languagetype='en' and labelbol='NOTFOUNDANYRECORD' and Labeltype='jspop');
delimiter;
-- 2014-10-21

set @tabid=0;
select tabid into @tabid from ld_tab where name='ServiceCharge';
update ld_tab set presence=0 where tabid=@tabid and exists (select 1 from ld_version where versiontype=10);
update ld_tab set presence=1 where tabid=@tabid and exists (select 1 from ld_version where versiontype in (2));
delimiter;

update ld_desk set fieldlabel='输入新的条目，每行一个' where labelbol='ONEBYONEBELOW' and languagetype='zh';

UPDATE ld_desk SET fieldlabel='Just statistic the approved bills' WHERE labelbol='Onlythroughdatastatisticsexaminationapproval'
AND languagetype='en' AND Labeltype='fixedstr';
delimiter;

call addcolumn('ld_communicationaccount','pwd','varchar','100',NULL);
delimiter;
-- 2014-10-22

select usereportid into @id from LD_usereport where name='SalesOrderTrack';
insert into LD_UseReportcolumns(id,Usereportid,columns,Sequence,columnshow,realcolumns,realencolumns)
select '', @id, 'ld_servicecontracts:module_zh:module_zh:OftenUseReport_module_zh:V', 4, 1, 'ld_servicecontracts:module_zh:module_zh:OftenUseReport_单据类型:V','ld_servicecontracts:module_zh:module_zh:OftenUseReport_Bill Type:V'
from dual where not exists(select 1 from LD_UseReportcolumns where Usereportid=@id and realcolumns like 'ld_servicecontracts:module_zh:module_zh%');

insert into LD_usereportbasic(id,Usereportid,columns,Defaultvalue,Sequence)
select '',@id,'ld_servicecontracts:contract_no:contract_no:ServiceContracts_contract_no:I','',7
from dual where not exists(select usereportid from LD_usereportbasic where Usereportid=@id and Sequence=7);

UPDATE ld_desk SET fieldlabel='订单跟踪表' WHERE labelbol='CONTRACTORDERTRACKING' AND languagetype='zh' AND Labeltype='fixedstr';

UPDATE ld_desk SET fieldlabel='Statistics of the tracks about the orders' WHERE labelbol='CONTRACTORDERTRACKING' AND languagetype='en' AND Labeltype='fixedstr';

UPDATE ld_desk SET fieldlabel='订单跟踪表' WHERE labelbol='CONTRACTORDERTRACKING' AND languagetype='zh' AND Labeltype='fixedstr';

UPDATE ld_desk SET fieldlabel='Statistics of the tracks about the orders' WHERE labelbol='CONTRACTORDERTRACKING' AND languagetype='en' AND Labeltype='fixedstr';
delimiter;

delete from ld_desk where labelbol = 'SELECTEMALTEMPLATE' and labeltype = 'fixedstr';
delimiter;
update ld_desk set fieldlabel='选择邮件模板' where labelbol='SELECTEMAILTEMPLATE' and languagetype='zh' and Labeltype = 'fixedstr';
update ld_desk set fieldlabel='创建邮件模板' where labelbol='CREATEMAILTEMPLAETES' and languagetype='zh' and Labeltype = 'fixedstr';
update ld_desk set fieldlabel='编辑邮件模板' where labelbol='EDITEMAILTEMPLAETES' and languagetype='zh' and Labeltype = 'fixedstr';
delimiter;

update ld_tab set presence=0 where name='ServiceCharge' and EXISTS(select 1 from ld_version where versiontype=10);
delimiter;
-- 2014-10-23


insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'zh','MOBILECODEDONTMATCH','手机号码和验证码不匹配，请重新尝试','jspop' from dual
where not EXISTS(select 1 from ld_desk  where languagetype='zh' and labelbol='MOBILECODEDONTMATCH' and Labeltype='jspop');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'en','MOBILECODEDONTMATCH',"Mobile phone number and the code does not match, please try again",'jspop' from dual
where not EXISTS(select 1 from ld_desk  where languagetype='en' and labelbol='MOBILECODEDONTMATCH' and Labeltype='jspop');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'zh','VERIFCATIONCODECANNOTBEEMPTY','验证码不能为空','jspop' from dual
where not EXISTS(select 1 from ld_desk  where languagetype='zh' and labelbol='VERIFCATIONCODECANNOTBEEMPTY' and Labeltype='jspop');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'en','VERIFCATIONCODECANNOTBEEMPTY',"Verification code cannot be empty",'jspop' from dual
where not EXISTS(select 1 from ld_desk  where languagetype='en' and labelbol='VERIFCATIONCODECANNOTBEEMPTY' and Labeltype='jspop');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'zh','MOBILEPHONENUMBERCANNOTBEEMPTY','手机号码不能为空','jspop' from dual
where not EXISTS(select 1 from ld_desk  where languagetype='zh' and labelbol='MOBILEPHONENUMBERCANNOTBEEMPTY' and Labeltype='jspop');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'en','MOBILEPHONENUMBERCANNOTBEEMPTY',"Mobile phone number can not be empty",'jspop' from dual
where not EXISTS(select 1 from ld_desk  where languagetype='en' and labelbol='MOBILEPHONENUMBERCANNOTBEEMPTY' and Labeltype='jspop');
delimiter;
-- 2014-10-24

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'zh','openingbalance','期初余额','fixedstr' 
from dual where not EXISTS(select 1 from ld_desk where languagetype='zh' and labelbol='openingbalance' and Labeltype='fixedstr');

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'en','openingbalance','opening balance','fixedstr' 
from dual where not EXISTS(select 1 from ld_desk  where languagetype='en' and labelbol='openingbalance' and Labeltype='fixedstr');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'zh','Thismonthdeliveryamount','本月发货金额','fixedstr' 
from dual where not EXISTS(select 1 from ld_desk where languagetype='zh' and labelbol='Thismonthdeliveryamount' and Labeltype='fixedstr');

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'en','Thismonthdeliveryamount','month delivery amount','fixedstr' 
from dual where not EXISTS(select 1 from ld_desk  where languagetype='en' and labelbol='Thismonthdeliveryamount' and Labeltype='fixedstr');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'zh','Thismonththerefundamount','本月退货金额','fixedstr' 
from dual where not EXISTS(select 1 from ld_desk where languagetype='zh' and labelbol='Thismonththerefundamount' and Labeltype='fixedstr');

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'en','Thismonththerefundamount','month refund amount','fixedstr' 
from dual where not EXISTS(select 1 from ld_desk  where languagetype='en' and labelbol='Thismonththerefundamount' and Labeltype='fixedstr');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'zh','Thismonththeamountofreceivables','本月收款金额','fixedstr' 
from dual where not EXISTS(select 1 from ld_desk where languagetype='zh' and labelbol='Thismonththeamountofreceivables' and Labeltype='fixedstr');

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'en','Thismonththeamountofreceivables','month amount receivables','fixedstr' 
from dual where not EXISTS(select 1 from ld_desk  where languagetype='en' and labelbol='Thismonththeamountofreceivables' and Labeltype='fixedstr');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'zh','Cumulativesalesthisyear','本年累计销售(元)','fixedstr' 
from dual where not EXISTS(select 1 from ld_desk where languagetype='zh' and labelbol='Cumulativesalesthisyear' and Labeltype='fixedstr');

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'en','Cumulativesalesthisyear','Cumulative sales year (yuan)','fixedstr' 
from dual where not EXISTS(select 1 from ld_desk  where languagetype='en' and labelbol='Cumulativesalesthisyear' and Labeltype='fixedstr');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'zh','Cumulativesalesthisyear2','本年累计发货次数','fixedstr' 
from dual where not EXISTS(select 1 from ld_desk where languagetype='zh' and labelbol='Cumulativesalesthisyear2' and Labeltype='fixedstr');

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'en','Cumulativesalesthisyear2','cumulative count deliveries','fixedstr' 
from dual where not EXISTS(select 1 from ld_desk  where languagetype='en' and labelbol='Cumulativesalesthisyear2' and Labeltype='fixedstr');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'zh','Thisyearaccumulativetotalrefundamount','本年累计退货金额(元)','fixedstr' 
from dual where not EXISTS(select 1 from ld_desk where languagetype='zh' and labelbol='Thisyearaccumulativetotalrefundamount' and Labeltype='fixedstr');

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'en','Thisyearaccumulativetotalrefundamount','year accumulative total refund amount','fixedstr' 
from dual where not EXISTS(select 1 from ld_desk  where languagetype='en' and labelbol='Thisyearaccumulativetotalrefundamount' and Labeltype='fixedstr');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'zh','Thereturnrate','退货率','fixedstr' 
from dual where not EXISTS(select 1 from ld_desk where languagetype='zh' and labelbol='Thereturnrate' and Labeltype='fixedstr');

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'en','Thereturnrate','return rate','fixedstr' 
from dual where not EXISTS(select 1 from ld_desk  where languagetype='en' and labelbol='Thereturnrate' and Labeltype='fixedstr');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'zh','Theyearsofaccumulatedfundswithdrawalfromcirculation','退货率','fixedstr' 
from dual where not EXISTS(select 1 from ld_desk where languagetype='zh' and labelbol='Theyearsofaccumulatedfundswithdrawalfromcirculation' and Labeltype='fixedstr');

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'en','Theyearsofaccumulatedfundswithdrawalfromcirculation','years accumulated funds withdrawal circulation (yuan)','fixedstr' 
from dual where not EXISTS(select 1 from ld_desk  where languagetype='en' and labelbol='Theyearsofaccumulatedfundswithdrawalfromcirculation' and Labeltype='fixedstr');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'zh','Returnratio','回笼比','fixedstr' 
from dual where not EXISTS(select 1 from ld_desk where languagetype='zh' and labelbol='Returnratio' and Labeltype='fixedstr');

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'en','Returnratio','Return ratio','fixedstr' 
from dual where not EXISTS(select 1 from ld_desk  where languagetype='en' and labelbol='Returnratio' and Labeltype='fixedstr');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'zh','Accountsreceivablebalance','应收余额(元)','fixedstr' 
from dual where not EXISTS(select 1 from ld_desk where languagetype='zh' and labelbol='Accountsreceivablebalance' and Labeltype='fixedstr');

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'en','Accountsreceivablebalance','Accounts receivable balance (yuan)','fixedstr' 
from dual where not EXISTS(select 1 from ld_desk  where languagetype='en' and labelbol='Accountsreceivablebalance' and Labeltype='fixedstr');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'zh','Accountsreceivablebalance','销售统计表','fixedstr' 
from dual where not EXISTS(select 1 from ld_desk where languagetype='zh' and labelbol='Accountsreceivablebalance' and Labeltype='fixedstr');

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'en','Accountsreceivablebalance','Statistics of sales','fixedstr' 
from dual where not EXISTS(select 1 from ld_desk  where languagetype='en' and labelbol='Accountsreceivablebalance' and Labeltype='fixedstr');
delimiter;

update ld_desk set Fieldlabel='high seas' where labelbol='PUBLICCUSTOMER' and languagetype='en' and Labeltype = 'fixedstr';
delimiter;
update ld_desk set fieldlabel = '订单跟踪表' where labelbol = 'SalesOrderTrack' and languagetype='zh' and Labeltype='fixedstr';
update ld_desk set fieldlabel = 'Statistics of the tracks about the orders' where labelbol = 'SalesOrderTrack' and languagetype='en' and Labeltype='fixedstr';
delimiter;

CREATE TABLE IF NOT EXISTS `ld_callbutler` (
  `id` int(19) NOT NULL auto_increment,
  `calltype` varchar(10) default NULL,
  `phone` varchar(20) default NULL,
  `status` varchar(10) default NULL,
  `begintime` datetime default NULL,
  `endtime` datetime default NULL,
  `time` int(11) default '0',
  `soundrecordingfile` varchar(200) default NULL,
  `userid` int(19) default NULL,
  PRIMARY KEY  (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=utf8;
delimiter;

-- end 2014-10-28

update ld_blocks set sequence=100 where tabid=(select tabid from ld_tab where `name`='SendCashBill') and blocklabel='LBL_DESCRIPTION_INFORMATION';
select 0 into @i;
update ld_blocks set sequence=(@i:=@i+1) where tabid=(select tabid from ld_tab where `name`='SendCashBill') order by sequence;
delimiter;

CREATE TABLE IF NOT EXISTS `ld_warehousetransfer` (
  `warehousetransferid` int(19) NOT NULL AUTO_INCREMENT,
  `transferdate` date DEFAULT NULL COMMENT '调拨日期',
  `transferdate_no` varchar(25) DEFAULT NULL COMMENT '调拨编号',
  `outwarehouse` int(19) DEFAULT NULL COMMENT '调出仓库',
  `inwarehouse` int(19) DEFAULT NULL COMMENT '调入仓库',
  `adjustment` decimal(25,2) DEFAULT NULL COMMENT '调整',
  `subtotal` decimal(25,2) DEFAULT NULL COMMENT '小计',
  `total` decimal(25,2) DEFAULT NULL COMMENT '总计',
  `taxtype` varchar(25) DEFAULT NULL COMMENT '税',
  `discount_percent` decimal(25,2) DEFAULT NULL COMMENT '折扣百分比',
  `discount_amount` decimal(25,2) DEFAULT NULL COMMENT '折扣直接降价',
  `s_h_amount` decimal(25,2) DEFAULT NULL COMMENT '运费和物流附加费',
  `transferstatus` varchar(25) DEFAULT '未审核' COMMENT '审核状态',
  `transfersmownerid` int(19) DEFAULT NULL COMMENT '审核人',
  `currency_id` int(19) DEFAULT NULL COMMENT '货币',
  `conversion_rate` decimal(25,3) DEFAULT NULL COMMENT '货币汇率',
  `smownerid` int(19) DEFAULT NULL COMMENT '负责人',
  `smcreatorid` int(19) DEFAULT NULL COMMENT '创建人',
  `modifiedby` int(19) DEFAULT NULL COMMENT '最近更新人',
  `createdtime` date DEFAULT NULL COMMENT '创建时间',
  `modifiedtime` date DEFAULT NULL COMMENT '编辑时间',
  `deleted` int(1) DEFAULT '0' COMMENT '是否删除',
  `description` text COMMENT '备注',
  PRIMARY KEY (`warehousetransferid`)
) ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=utf8;
delimiter;

CREATE TABLE IF NOT EXISTS `ld_warehousetransfercf` (
  `warehousetransferid` int(19) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
delimiter;

select max(tabid)+1 into @tabid from ld_tab;
select '' into @id;
select id into @id from ld_version where versiontype = 1;
select tabsequence into @tabsequence from ld_tab where `name` = 'Stock';
update ld_tab set tabsequence = tabsequence+1 where parent = 'Stocks' and tabsequence >@tabsequence;
insert into ld_tab(tabid,name,presence,tabsequence,tablabel,isentitytype,parent,printtab)
select @tabid,'WareHouseTransfer',case when @id != '' then 0 else 1 end,@tabsequence+1,'WareHouseTransfer',1,'Stocks',0 from dual 
where not EXISTS(select 1 from ld_tab  where tablabel ='WareHouseTransfer');
delimiter;

select parenttabid into @parenttabid from ld_parenttab where parenttab_label = 'Stock';
select tabid into @tabid from ld_tab where `name`='Stock';
select sequence into @sequence from ld_parenttabrel where parenttabid = @parenttabid and tabid = @tabid;
update ld_parenttabrel set sequence = sequence + 1 where parenttabid = @parenttabid and sequence > @sequence;
select tabid into @tabid from ld_tab where `name` = 'WareHouseTransfer';
insert into ld_parenttabrel(parenttabid,tabid,sequence)
select @parenttabid,@tabid,@sequence+1 
from dual where not EXISTS(select 1 from ld_parenttabrel  where parenttabid = @parenttabid and tabid =@tabid);
delimiter;

select tabid into @tabid from ld_tab where `name` = 'WareHouseTransfer';
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'zh','LD_tab',@tabid,@tabid,'库间调拨' 
from dual where not EXISTS(select 1 from ld_tranlabel  where languagetype = 'zh' 
and trantable ='LD_tab' and tabid = @tabid and relateid=@tabid);
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'en','LD_tab',@tabid,@tabid,'Warehouse Transfer' 
from dual where not EXISTS(select 1 from ld_tranlabel  where languagetype = 'en' 
and trantable ='LD_tab' and tabid = @tabid and relateid=@tabid);
delimiter;

insert into ld_ws_entity(name,handler_path,handler_class,ismodule)
select 'WareHouseTransfer','include/Webservices/lingdangModuleOperation.php','lingdangModuleOperation',1 
from dual where not EXISTS(select 1 from ld_ws_entity  where name = 'WareHouseTransfer' );
delimiter;

select tabid into @tabid from ld_tab where `name` = 'WareHouseTransfer';
insert into ld_entityname(tabid,modulename,tablename,fieldname,entityidfield,entityidcolumn)
select @tabid,'WareHouseTransfer','LD_warehousetransfer','transferdate_no','warehousetransferid','warehousetransferid' 
from dual where not EXISTS(select 1 from ld_entityname  where tabid = @tabid);

call fieldprofile('WareHouseTransfer');
call getallprofile('WareHouseTransfer');
call addtabintoprofile('WareHouseTransfer',0);
select tabid into @tabid from ld_tab where `name` = 'WareHouseTransfer';
update ld_profile2standardpermissions set permissions = 1 where tabid = @tabid and profileid not in (
select ld_role2profile.profileid from ld_users 
inner join ld_user2role on ld_users.id = ld_user2role.userid
inner join ld_role2profile on ld_role2profile.roleid = ld_user2role.roleid  where is_admin = 'on');

select tabid into @tabid from ld_tab where `name` = 'WareHouseTransfer';
insert into LD_org_share_action2tab(share_action_id,tabid) select 0,@tabid from dual 
where not exists(select 1 from LD_org_share_action2tab where share_action_id=0 and tabid=@tabid);

insert into LD_org_share_action2tab(share_action_id,tabid) select 1,@tabid from dual 
where not exists(select 1 from LD_org_share_action2tab where share_action_id=1 and tabid=@tabid);

insert into LD_org_share_action2tab(share_action_id,tabid) select 2,@tabid from dual 
where not exists(select 1 from LD_org_share_action2tab where share_action_id=2 and tabid=@tabid);

insert into LD_org_share_action2tab(share_action_id,tabid) select 3,@tabid from dual 
where not exists(select 1 from LD_org_share_action2tab where share_action_id=3 and tabid=@tabid);
select max(ruleid) into @ruleid from LD_def_org_share;
update LD_def_org_share_seq set id=@ruleid+1 where  not exists(select 1 from LD_Def_org_share where tabid=@tabid);
insert into LD_def_org_share(ruleid,tabid,permission,editstatus)
select @ruleid+1,@tabid,3,0  from dual where  not exists(select 1 from LD_Def_org_share where tabid=@tabid);

select tabid into @tabid from ld_tab where `name` = 'WareHouseTransfer';
insert into ld_blocks(blockid,tabid,blocklabel,sequence)
select (select max(blockid) from ld_blocks)+1,@tabid,'LBL_WAREHOUSETRANSFER_INFO',1 from dual where not exists (select * from ld_blocks where 
tabid = @tabid and blocklabel = 'LBL_WAREHOUSETRANSFER_INFO' and sequence = 1);
insert into ld_blocks(blockid,tabid,blocklabel,sequence)
select (select max(blockid) from ld_blocks)+1,@tabid,'LBL_WAREHOUSETRANSFER_DESCRIPTION',2 from dual where not exists (select * from ld_blocks where 
tabid = @tabid and blocklabel = 'LBL_WAREHOUSETRANSFER_DESCRIPTION' and sequence = 2);
update ld_blocks_seq set id = (select max(blockid)+1 from ld_blocks);

select blockid into @blockid from ld_blocks where tabid = @tabid and blocklabel = 'LBL_WAREHOUSETRANSFER_INFO';
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'zh','LD_blocks',@tabid,@blockid,'基本信息' 
from dual where not EXISTS(select 1 from ld_tranlabel  where languagetype = 'zh' 
and trantable ='LD_blocks' and tabid = @tabid and fieldlabel='基本信息');
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'en','LD_blocks',@tabid,@blockid,'Reminds Content' 
from dual where not EXISTS(select 1 from ld_tranlabel  where languagetype = 'en' 
and trantable ='LD_blocks' and tabid = @tabid and fieldlabel='Reminds Content');

DELETE from ld_field where tabid = @tabid;
select max(fieldid) into @fieldid from ld_field;
insert into ld_field(tabid,fieldid,columnname,tablename,uitype,fieldname,fieldlabel,block,displaytype,presence,typeofdata,readonly,defaultvalue)
select @tabid,@fieldid+1,'transferdate','LD_warehousetransfer',5,'transferdate','调拨日期',@blockid,1,0,'D~O',1,'thistoday' from dual where not exists
(select 1 from ld_field where tabid = @tabid and columnname = 'transferdate');

insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'zh','LD_field',@tabid,@fieldid+1,'调拨日期'
from dual where not EXISTS(select 1 from ld_tranlabel  where languagetype = 'zh'
and trantable ='LD_field' and tabid = @tabid and relateid=@fieldid+1);
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'en','LD_field',@tabid,@fieldid+1,'Transfer Date'
from dual where not EXISTS(select 1 from ld_tranlabel  where languagetype = 'en'
and trantable ='LD_field' and tabid = @tabid and relateid=@fieldid+1);

insert into ld_field(tabid,fieldid,columnname,tablename,uitype,fieldname,fieldlabel,block,displaytype,presence,typeofdata,readonly)
select @tabid,@fieldid+2,'transferdate_no','LD_warehousetransfer',4,'transferdate_no','调拨单编号',@blockid,1,0,'V~M',0 from dual where not exists
(select * from ld_field where tabid = @tabid and columnname = 'transferdate_no');

insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'zh','LD_field',@tabid,@fieldid+2,'调拨单编号'
from dual where not EXISTS(select 1 from ld_tranlabel  where languagetype = 'zh'
and trantable ='LD_field' and tabid = @tabid and relateid=@fieldid+2);
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'en','LD_field',@tabid,@fieldid+2,'Transfer No'
from dual where not EXISTS(select 1 from ld_tranlabel  where languagetype = 'en'
and trantable ='LD_field' and tabid = @tabid and relateid=@fieldid+2);


insert into ld_field(tabid,fieldid,columnname,tablename,uitype,fieldname,fieldlabel,block,displaytype,presence,typeofdata,readonly)
select @tabid,@fieldid+3,'outwarehouse','LD_warehousetransfer',151,'outwarehouse','调出仓库',@blockid,1,0,'V~M',0 from dual where not exists
(select * from ld_field where tabid = @tabid and columnname = 'outwarehouse');

insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'zh','LD_field',@tabid,@fieldid+3,'调出仓库'
from dual where not EXISTS(select 1 from ld_tranlabel  where languagetype = 'zh'
and trantable ='LD_field' and tabid = @tabid and relateid=@fieldid+3);
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'en','LD_field',@tabid,@fieldid+3,'Out Transfer'
from dual where not EXISTS(select 1 from ld_tranlabel  where languagetype = 'en'
and trantable ='LD_field' and tabid = @tabid and relateid=@fieldid+3);

insert into ld_field(tabid,fieldid,columnname,tablename,uitype,fieldname,fieldlabel,block,displaytype,presence,typeofdata,readonly)
select @tabid,@fieldid+4,'inwarehouse','LD_warehousetransfer',151,'inwarehouse','调入仓库',@blockid,1,0,'V~M',0 from dual where not exists
(select * from ld_field where tabid = @tabid and columnname = 'inwarehouse');

insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'zh','LD_field',@tabid,@fieldid+4,'调入仓库'
from dual where not EXISTS(select 1 from ld_tranlabel  where languagetype = 'zh'
and trantable ='LD_field' and tabid = @tabid and relateid=@fieldid+4);
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'en','LD_field',@tabid,@fieldid+4,'In Transfer'
from dual where not EXISTS(select 1 from ld_tranlabel  where languagetype = 'en'
and trantable ='LD_field' and tabid = @tabid and relateid=@fieldid+4);

insert into ld_field(tabid,fieldid,columnname,tablename,uitype,fieldname,fieldlabel,block,displaytype,presence,typeofdata,readonly)
select @tabid,@fieldid+5,'adjustment','LD_warehousetransfer',72,'txtAdjustment','Adjustment',@blockid,3,0,'NN~O',0 from dual where not exists
(select * from ld_field where tabid = @tabid and columnname = 'adjustment');

insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'zh','LD_field',@tabid,@fieldid+5,'调整'
from dual where not EXISTS(select 1 from ld_tranlabel  where languagetype = 'zh'
and trantable ='LD_field' and tabid = @tabid and relateid=@fieldid+5);
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'en','LD_field',@tabid,@fieldid+5,'Adjustment'
from dual where not EXISTS(select 1 from ld_tranlabel  where languagetype = 'en'
and trantable ='LD_field' and tabid = @tabid and relateid=@fieldid+5);

insert into ld_field(tabid,fieldid,columnname,tablename,uitype,fieldname,fieldlabel,block,displaytype,presence,typeofdata,readonly)
select @tabid,@fieldid+6,'subtotal','LD_warehousetransfer',72,'hdnSubTotal','Sub Total',@blockid,3,0,'N~O',0 from dual where not exists
(select * from ld_field where tabid = @tabid and columnname = 'subtotal');

insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'zh','LD_field',@tabid,@fieldid+6,'小计'
from dual where not EXISTS(select 1 from ld_tranlabel  where languagetype = 'zh'
and trantable ='LD_field' and tabid = @tabid and relateid=@fieldid+6);
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'en','LD_field',@tabid,@fieldid+6,'Sub Total'
from dual where not EXISTS(select 1 from ld_tranlabel  where languagetype = 'en'
and trantable ='LD_field' and tabid = @tabid and relateid=@fieldid+6);

insert into ld_field(tabid,fieldid,columnname,tablename,uitype,fieldname,fieldlabel,block,displaytype,presence,typeofdata,readonly)
select @tabid,@fieldid+7,'total','LD_warehousetransfer',72,'hdnGrandTotal','Total',@blockid,3,0,'N~O',0 from dual where not exists
(select * from ld_field where tabid = @tabid and columnname = 'total');

insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'zh','LD_field',@tabid,@fieldid+7,'合计'
from dual where not EXISTS(select 1 from ld_tranlabel  where languagetype = 'zh'
and trantable ='LD_field' and tabid = @tabid and relateid=@fieldid+7);
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'en','LD_field',@tabid,@fieldid+7,'Total'
from dual where not EXISTS(select 1 from ld_tranlabel  where languagetype = 'en'
and trantable ='LD_field' and tabid = @tabid and relateid=@fieldid+7);

insert into ld_field(tabid,fieldid,columnname,tablename,uitype,fieldname,fieldlabel,block,displaytype,presence,typeofdata,readonly)
select @tabid,@fieldid+8,'taxtype','LD_warehousetransfer',8,'hdnTaxType','Tax Type',@blockid,3,0,'V~0',0 from dual where not exists
(select * from ld_field where tabid = @tabid and columnname = 'taxtype');

insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'zh','LD_field',@tabid,@fieldid+8,'税种'
from dual where not EXISTS(select 1 from ld_tranlabel  where languagetype = 'zh'
and trantable ='LD_field' and tabid = @tabid and relateid=@fieldid+8);
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'en','LD_field',@tabid,@fieldid+8,'Tax'
from dual where not EXISTS(select 1 from ld_tranlabel  where languagetype = 'en'
and trantable ='LD_field' and tabid = @tabid and relateid=@fieldid+8);

insert into ld_field(tabid,fieldid,columnname,tablename,uitype,fieldname,fieldlabel,block,displaytype,presence,typeofdata,readonly)
select @tabid,@fieldid+9,'discount_percent','LD_warehousetransfer',72,'hdnDiscountPercent','Discount Percent',@blockid,3,0,'N~O',0 from dual where not exists
(select * from ld_field where tabid = @tabid and columnname = 'discount_percent');

insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'zh','LD_field',@tabid,@fieldid+9,'折扣百分比'
from dual where not EXISTS(select 1 from ld_tranlabel  where languagetype = 'zh'
and trantable ='LD_field' and tabid = @tabid and relateid=@fieldid+9);
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'en','LD_field',@tabid,@fieldid+9,'Discount Percent'
from dual where not EXISTS(select 1 from ld_tranlabel  where languagetype = 'en'
and trantable ='LD_field' and tabid = @tabid and relateid=@fieldid+9);

insert into ld_field(tabid,fieldid,columnname,tablename,uitype,fieldname,fieldlabel,block,displaytype,presence,typeofdata,readonly)
select @tabid,@fieldid+10,'discount_amount','LD_warehousetransfer',72,'hdnDiscountAmount','Discount Amount',@blockid,3,0,'N~O',0 from dual where not exists
(select * from ld_field where tabid = @tabid and columnname = 'discount_amount');

insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'zh','LD_field',@tabid,@fieldid+10,'折扣直接降价'
from dual where not EXISTS(select 1 from ld_tranlabel  where languagetype = 'zh'
and trantable ='LD_field' and tabid = @tabid and relateid=@fieldid+10);
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'en','LD_field',@tabid,@fieldid+10,'Discount Amount'
from dual where not EXISTS(select 1 from ld_tranlabel  where languagetype = 'en'
and trantable ='LD_field' and tabid = @tabid and relateid=@fieldid+10);

insert into ld_field(tabid,fieldid,columnname,tablename,uitype,fieldname,fieldlabel,block,displaytype,presence,typeofdata,readonly)
select @tabid,@fieldid+11,'s_h_amount','LD_warehousetransfer',72,'hdnS_H_Amount','运费和物流附加费',@blockid,3,0,'N~O',0 from dual where not exists
(select * from ld_field where tabid = @tabid and columnname = 's_h_amount');

insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'zh','LD_field',@tabid,@fieldid+11,'运费和物流附加费'
from dual where not EXISTS(select 1 from ld_tranlabel  where languagetype = 'zh'
and trantable ='LD_field' and tabid = @tabid and relateid=@fieldid+11);
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'en','LD_field',@tabid,@fieldid+11,'S&H Amount'
from dual where not EXISTS(select 1 from ld_tranlabel  where languagetype = 'en'
and trantable ='LD_field' and tabid = @tabid and relateid=@fieldid+11);

insert into ld_field(tabid,fieldid,columnname,tablename,uitype,fieldname,fieldlabel,block,displaytype,presence,typeofdata,issmownerid,readonly)
select @tabid,@fieldid+12,'smownerid','LD_warehousetransfer',53,'smownerid','负责人',@blockid,1,0,'V~M',1,0 from dual where not exists
(select * from ld_field where tabid = @tabid and columnname = 'smownerid');

insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'zh','LD_field',@tabid,@fieldid+12,'负责人'
from dual where not EXISTS(select 1 from ld_tranlabel  where languagetype = 'zh'
and trantable ='LD_field' and tabid = @tabid and relateid=@fieldid+12);
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'en','LD_field',@tabid,@fieldid+12,'Assigned To'
from dual where not EXISTS(select 1 from ld_tranlabel  where languagetype = 'en'
and trantable ='LD_field' and tabid = @tabid and relateid=@fieldid+12);

insert into ld_field(tabid,fieldid,columnname,tablename,uitype,fieldname,fieldlabel,block,displaytype,presence,typeofdata,readonly)
select @tabid,@fieldid+13,'createdtime','LD_warehousetransfer',70,'createdtime','创建时间',@blockid,2,0,'DT~O',0 from dual where not exists
(select * from ld_field where tabid = @tabid and columnname = 'createdtime');

insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'zh','LD_field',@tabid,@fieldid+13,'创建时间'
from dual where not EXISTS(select 1 from ld_tranlabel  where languagetype = 'zh'
and trantable ='LD_field' and tabid = @tabid and relateid=@fieldid+13);
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'en','LD_field',@tabid,@fieldid+13,'Created Time'
from dual where not EXISTS(select 1 from ld_tranlabel  where languagetype = 'en'
and trantable ='LD_field' and tabid = @tabid and relateid=@fieldid+13);

insert into ld_field(tabid,fieldid,columnname,tablename,uitype,fieldname,fieldlabel,block,displaytype,presence,typeofdata,readonly)
select @tabid,@fieldid+14,'modifiedtime','LD_warehousetransfer',70,'modifiedtime','修改时间',@blockid,2,0,'DT~O',0 from dual where not exists
(select * from ld_field where tabid = @tabid and columnname = 'modifiedtime');

insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'zh','LD_field',@tabid,@fieldid+14,'修改时间'
from dual where not EXISTS(select 1 from ld_tranlabel  where languagetype = 'zh'
and trantable ='LD_field' and tabid = @tabid and relateid=@fieldid+14);
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'en','LD_field',@tabid,@fieldid+14,'Modified Time'
from dual where not EXISTS(select 1 from ld_tranlabel  where languagetype = 'en'
and trantable ='LD_field' and tabid = @tabid and relateid=@fieldid+14);

insert into ld_field(tabid,fieldid,columnname,tablename,uitype,fieldname,fieldlabel,block,displaytype,presence,typeofdata,readonly)
select @tabid,@fieldid+15,'modifiedby','LD_warehousetransfer',52,'modifiedby','最新更新人',@blockid,3,0,'V~O',0 from dual where not exists
(select * from ld_field where tabid = @tabid and columnname = 'modifiedby');

insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'zh','LD_field',@tabid,@fieldid+15,'最新更新人'
from dual where not EXISTS(select 1 from ld_tranlabel  where languagetype = 'zh'
and trantable ='LD_field' and tabid = @tabid and relateid=@fieldid+15);
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'en','LD_field',@tabid,@fieldid+15,'Modified By'
from dual where not EXISTS(select 1 from ld_tranlabel  where languagetype = 'en'
and trantable ='LD_field' and tabid = @tabid and relateid=@fieldid+15);

insert into ld_field(tabid,fieldid,columnname,tablename,uitype,fieldname,fieldlabel,block,displaytype,presence,typeofdata,readonly)
select @tabid,@fieldid+16,'currency_id','LD_warehousetransfer',117,'currency_id','货币',@blockid,3,0,'I~O',0 from dual where not exists
(select * from ld_field where tabid = @tabid and columnname = 'currency_id');

insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'zh','LD_field',@tabid,@fieldid+16,'货币'
from dual where not EXISTS(select 1 from ld_tranlabel  where languagetype = 'zh'
and trantable ='LD_field' and tabid = @tabid and relateid=@fieldid+16);
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'en','LD_field',@tabid,@fieldid+16,'Currency'
from dual where not EXISTS(select 1 from ld_tranlabel  where languagetype = 'en'
and trantable ='LD_field' and tabid = @tabid and relateid=@fieldid+16);


insert into ld_field(tabid,fieldid,columnname,tablename,uitype,fieldname,fieldlabel,block,displaytype,presence,typeofdata,readonly)
select @tabid,@fieldid+17,'conversion_rate','LD_warehousetransfer',1,'conversion_rate','汇率',@blockid,3,0,'I~O',0 from dual where not exists
(select * from ld_field where tabid = @tabid and columnname = 'conversion_rate');

insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'zh','LD_field',@tabid,@fieldid+17,'汇率'
from dual where not EXISTS(select 1 from ld_tranlabel  where languagetype = 'zh'
and trantable ='LD_field' and tabid = @tabid and relateid=@fieldid+17);
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'en','LD_field',@tabid,@fieldid+17,'Exchange Rate'
from dual where not EXISTS(select 1 from ld_tranlabel  where languagetype = 'en'
and trantable ='LD_field' and tabid = @tabid and relateid=@fieldid+17);

insert into ld_field(tabid,fieldid,columnname,tablename,uitype,fieldname,fieldlabel,block,displaytype,presence,typeofdata,readonly)
select @tabid,@fieldid+18,'smcreatorid','LD_warehousetransfer',52,'smcreatorid','创建人',@blockid,2,0,'V~O',0 from dual where not exists
(select * from ld_field where tabid = @tabid and columnname = 'smcreatorid');
update ld_field_seq set id = (select max(fieldid)+1 from ld_field);

insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'zh','LD_field',@tabid,@fieldid+18,'创建人'
from dual where not EXISTS(select 1 from ld_tranlabel  where languagetype = 'zh'
and trantable ='LD_field' and tabid = @tabid and relateid=@fieldid+18);
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'en','LD_field',@tabid,@fieldid+18,'Creator'
from dual where not EXISTS(select 1 from ld_tranlabel  where languagetype = 'en'
and trantable ='LD_field' and tabid = @tabid and relateid=@fieldid+18);

insert into ld_field(tabid,fieldid,columnname,tablename,uitype,fieldname,fieldlabel,block,displaytype,presence,typeofdata,readonly)
select @tabid,@fieldid+19,'transferstatus','LD_warehousetransfer',130,'transferstatus','审核状态',@blockid,2,0,'V~O',0 from dual where not exists
(select * from ld_field where tabid = @tabid and columnname = 'transferstatus');

insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'zh','LD_field',@tabid,@fieldid+19,'审核状态'
from dual where not EXISTS(select 1 from ld_tranlabel  where languagetype = 'zh'
and trantable ='LD_field' and tabid = @tabid and relateid=@fieldid+19);
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'en','LD_field',@tabid,@fieldid+19,'Transfer Status'
from dual where not EXISTS(select 1 from ld_tranlabel  where languagetype = 'en'
and trantable ='LD_field' and tabid = @tabid and relateid=@fieldid+19);

insert into ld_field(tabid,fieldid,columnname,tablename,uitype,fieldname,fieldlabel,block,displaytype,presence,typeofdata,readonly)
select @tabid,@fieldid+20,'transfersmownerid','LD_warehousetransfer',52,'transfersmownerid','审核人',@blockid,2,0,'V~O',0 from dual where not exists
(select * from ld_field where tabid = @tabid and columnname = 'transfersmownerid');

insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'zh','LD_field',@tabid,@fieldid+20,'审核人'
from dual where not EXISTS(select 1 from ld_tranlabel  where languagetype = 'zh'
and trantable ='LD_field' and tabid = @tabid and relateid=@fieldid+20);
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'en','LD_field',@tabid,@fieldid+20,'Transfer By'
from dual where not EXISTS(select 1 from ld_tranlabel  where languagetype = 'en'
and trantable ='LD_field' and tabid = @tabid and relateid=@fieldid+20);


select blockid into @blockid from ld_blocks where tabid = @tabid and blocklabel = 'LBL_WAREHOUSETRANSFER_DESCRIPTION';
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'zh','LD_blocks',@tabid,@blockid,'描述信息' 
from dual where not EXISTS(select 1 from ld_tranlabel  where languagetype = 'zh' 
and trantable ='LD_blocks' and tabid = @tabid and fieldlabel='描述信息');
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'en','LD_blocks',@tabid,@blockid,'Basic Information' 
from dual where not EXISTS(select 1 from ld_tranlabel  where languagetype = 'en' 
and trantable ='LD_blocks' and tabid = @tabid and fieldlabel='Basic Information');

insert into ld_field(tabid,fieldid,columnname,tablename,uitype,fieldname,fieldlabel,block,displaytype,presence,typeofdata,readonly)
select @tabid,@fieldid+21,'description','LD_warehousetransfer',19,'description','备注',@blockid,1,0,'V~O',0 from dual where not exists
(select * from ld_field where tabid = @tabid and columnname = 'description');

insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'zh','LD_field',@tabid,@fieldid+21,'备注'
from dual where not EXISTS(select 1 from ld_tranlabel  where languagetype = 'zh'
and trantable ='LD_field' and tabid = @tabid and relateid=@fieldid+21);
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'en','LD_field',@tabid,@fieldid+21,'Description'
from dual where not EXISTS(select 1 from ld_tranlabel  where languagetype = 'en'
and trantable ='LD_field' and tabid = @tabid and relateid=@fieldid+21);

update ld_field_seq set id = (select max(fieldid) from ld_field);

insert into ld_customview(cvid,viewname,setdefault,entitytype,status,userid,pagewidthpercent)
select (select max(id)+1 from ld_customview_seq),'All',1,'WareHouseTransfer',0,1,100 
from dual where not EXISTS(select 1 from ld_customview  where viewname = 'All' 
and entitytype ='WareHouseTransfer');
update ld_customview_seq set id = (select max(cvid)+1 from ld_customview);
delimiter;
select cvid into @cvid from ld_customview where entitytype = 'WareHouseTransfer' and viewname = 'All';
select tabid into @tabid from ld_tab where `name`='WareHouseTransfer';
delete from ld_tabwithproductview where cvid =  @cvid;

insert into ld_tabwithproductview(tabid,columns,sequence,cvid)
select @tabid,'LD_warehousetransfer:transferdate_no:transferdate_no:WareHouseTransfer_fieldlabel:V',0,@cvid
from dual where not EXISTS(select 1 from ld_tabwithproductview  where cvid = @cvid
and columns = 'LD_warehousetransfer:transferdate_no:transferdate_no:WareHouseTransfer_fieldlabel:V');

insert into ld_tabwithproductview(tabid,columns,sequence,cvid)
select @tabid,'LD_warehousetransfer:transferdate:transferdate:WareHouseTransfer_fieldlabel:V',1,@cvid
from dual where not EXISTS(select 1 from ld_tabwithproductview  where cvid = @cvid
and columns = 'LD_warehousetransfer:transferdate:transferdate:WareHouseTransfer_fieldlabel:V');

insert into ld_tabwithproductview(tabid,columns,sequence,cvid)
select @tabid,'LD_warehousetransfer:outwarehouse:outwarehouse:WareHouseTransfer_fieldlabel:V',2,@cvid
from dual where not EXISTS(select 1 from ld_tabwithproductview  where cvid = @cvid
and columns = 'LD_warehousetransfer:outwarehouse:outwarehouse:WareHouseTransfer_fieldlabel:V');

insert into ld_tabwithproductview(tabid,columns,sequence,cvid)
select @tabid,'LD_warehousetransfer:inwarehouse:inwarehouse:WareHouseTransfer_fieldlabel:V',3,@cvid
from dual where not EXISTS(select 1 from ld_tabwithproductview  where cvid = @cvid
and columns = 'LD_warehousetransfer:inwarehouse:inwarehouse:WareHouseTransfer_fieldlabel:V');

insert into ld_tabwithproductview(tabid,columns,sequence,cvid)
select @tabid,'LD_warehousetransfer:transferstatus:transferstatus:WareHouseTransfer_fieldlabel:V',4,@cvid
from dual where not EXISTS(select 1 from ld_tabwithproductview  where cvid = @cvid
and columns = 'LD_warehousetransfer:transferstatus:transferstatus:WareHouseTransfer_fieldlabel:V');

insert into ld_tabwithproductview(tabid,columns,sequence,cvid)
select @tabid,'LD_warehousetransfer:smownerid:smownerid:WareHouseTransfer_fieldlabel:V',5,@cvid
from dual where not EXISTS(select 1 from ld_tabwithproductview  where cvid = @cvid
and columns = 'LD_warehousetransfer:smownerid:smownerid:WareHouseTransfer_fieldlabel:V');

insert into ld_tabwithproductview(tabid,columns,sequence,cvid)
select @tabid,'LD_warehousetransfer:transfersmownerid:transfersmownerid:WareHouseTransfer_fieldlabel:V',6,@cvid
from dual where not EXISTS(select 1 from ld_tabwithproductview  where cvid = @cvid
and columns = 'LD_warehousetransfer:transfersmownerid:transfersmownerid:WareHouseTransfer_fieldlabel:V');

insert into ld_tabwithproductview(tabid,columns,sequence,cvid)
select @tabid,'LD_products:product_no:product_no:Products_fieldlabel:V',7,@cvid
from dual where not EXISTS(select 1 from ld_tabwithproductview  where cvid = @cvid
and columns = 'LD_products:product_no:product_no:Products_fieldlabel:V');

insert into ld_tabwithproductview(tabid,columns,sequence,cvid)
select @tabid,'LD_products:productname:productname:Products_fieldlabel:V',8,@cvid
from dual where not EXISTS(select 1 from ld_tabwithproductview  where cvid = @cvid
and columns = 'LD_products:productname:productname:Products_fieldlabel:V');

insert into ld_tabwithproductview(tabid,columns,sequence,cvid)
select @tabid,'LD_inventoryproductrel:quantity:quantity:Products_fieldlabel:V',9,@cvid
from dual where not EXISTS(select 1 from ld_tabwithproductview  where cvid = @cvid
and columns = 'LD_inventoryproductrel:quantity:quantity:Products_fieldlabel:V');

insert into ld_customview(cvid,viewname,setdefault,entitytype,status,userid,pagewidthpercent)
select (select max(id)+1 from ld_customview_seq),'未审核',0,'WareHouseTransfer',1,1,100
from dual where not EXISTS(select 1 from ld_customview  where viewname = '未审核' and entitytype ='WareHouseTransfer');
update ld_customview_seq set id = (select max(cvid)+1 from ld_customview);
delimiter;
select cvid into @cvid from ld_customview where entitytype = 'WareHouseTransfer' and viewname = '未审核';
select tabid into @tabid from ld_tab where `name`='WareHouseTransfer';
delete from ld_cvadvfilter where cvid =  @cvid;
insert into ld_cvadvfilter(cvid,columnindex,columnname,comparator,`value`,groupid,column_condition)
select @cvid,0,'LD_warehousetransfer:transferstatus:transferstatus:WareHouseTransfer_fieldlabel:V','e','未审核',1,'';
delete from ld_tabwithproductview where cvid =  @cvid;

insert into ld_tabwithproductview(tabid,columns,sequence,cvid)
select @tabid,'LD_warehousetransfer:transferdate_no:transferdate_no:WareHouseTransfer_fieldlabel:V',0,@cvid
from dual where not EXISTS(select 1 from ld_tabwithproductview  where cvid = @cvid
and columns = 'LD_warehousetransfer:transferdate_no:transferdate_no:WareHouseTransfer_fieldlabel:V');

insert into ld_tabwithproductview(tabid,columns,sequence,cvid)
select @tabid,'LD_warehousetransfer:transferdate:transferdate:WareHouseTransfer_fieldlabel:V',1,@cvid
from dual where not EXISTS(select 1 from ld_tabwithproductview  where cvid = @cvid
and columns = 'LD_warehousetransfer:transferdate:transferdate:WareHouseTransfer_fieldlabel:V');

insert into ld_tabwithproductview(tabid,columns,sequence,cvid)
select @tabid,'LD_warehousetransfer:outwarehouse:outwarehouse:WareHouseTransfer_fieldlabel:V',2,@cvid
from dual where not EXISTS(select 1 from ld_tabwithproductview  where cvid = @cvid
and columns = 'LD_warehousetransfer:outwarehouse:outwarehouse:WareHouseTransfer_fieldlabel:V');

insert into ld_tabwithproductview(tabid,columns,sequence,cvid)
select @tabid,'LD_warehousetransfer:inwarehouse:inwarehouse:WareHouseTransfer_fieldlabel:V',3,@cvid
from dual where not EXISTS(select 1 from ld_tabwithproductview  where cvid = @cvid
and columns = 'LD_warehousetransfer:inwarehouse:inwarehouse:WareHouseTransfer_fieldlabel:V');

insert into ld_tabwithproductview(tabid,columns,sequence,cvid)
select @tabid,'LD_warehousetransfer:transferstatus:transferstatus:WareHouseTransfer_fieldlabel:V',4,@cvid
from dual where not EXISTS(select 1 from ld_tabwithproductview  where cvid = @cvid
and columns = 'LD_warehousetransfer:transferstatus:transferstatus:WareHouseTransfer_fieldlabel:V');

insert into ld_tabwithproductview(tabid,columns,sequence,cvid)
select @tabid,'LD_warehousetransfer:smownerid:smownerid:WareHouseTransfer_fieldlabel:V',5,@cvid
from dual where not EXISTS(select 1 from ld_tabwithproductview  where cvid = @cvid
and columns = 'LD_warehousetransfer:smownerid:smownerid:WareHouseTransfer_fieldlabel:V');

insert into ld_tabwithproductview(tabid,columns,sequence,cvid)
select @tabid,'LD_warehousetransfer:transfersmownerid:transfersmownerid:WareHouseTransfer_fieldlabel:V',6,@cvid
from dual where not EXISTS(select 1 from ld_tabwithproductview  where cvid = @cvid
and columns = 'LD_warehousetransfer:transfersmownerid:transfersmownerid:WareHouseTransfer_fieldlabel:V');

insert into ld_tabwithproductview(tabid,columns,sequence,cvid)
select @tabid,'LD_products:product_no:product_no:Products_fieldlabel:V',7,@cvid
from dual where not EXISTS(select 1 from ld_tabwithproductview  where cvid = @cvid
and columns = 'LD_products:product_no:product_no:Products_fieldlabel:V');

insert into ld_tabwithproductview(tabid,columns,sequence,cvid)
select @tabid,'LD_products:productname:productname:Products_fieldlabel:V',8,@cvid
from dual where not EXISTS(select 1 from ld_tabwithproductview  where cvid = @cvid
and columns = 'LD_products:productname:productname:Products_fieldlabel:V');

insert into ld_tabwithproductview(tabid,columns,sequence,cvid)
select @tabid,'LD_inventoryproductrel:quantity:quantity:Products_fieldlabel:V',9,@cvid
from dual where not EXISTS(select 1 from ld_tabwithproductview  where cvid = @cvid
and columns = 'LD_inventoryproductrel:quantity:quantity:Products_fieldlabel:V');


insert into ld_customview(cvid,viewname,setdefault,entitytype,status,userid,pagewidthpercent)
select (select max(id)+1 from ld_customview_seq),'已审核',0,'WareHouseTransfer',1,1,100
from dual where not EXISTS(select 1 from ld_customview  where viewname = '已审核' and entitytype ='WareHouseTransfer');
update ld_customview_seq set id = (select max(cvid)+1 from ld_customview);
delimiter;
select cvid into @cvid from ld_customview where entitytype = 'WareHouseTransfer' and viewname = '已审核';
select tabid into @tabid from ld_tab where `name`='WareHouseTransfer';
delete from ld_cvadvfilter where cvid =  @cvid;
insert into ld_cvadvfilter(cvid,columnindex,columnname,comparator,`value`,groupid,column_condition)
select @cvid,0,'LD_warehousetransfer:transferstatus:transferstatus:WareHouseTransfer_fieldlabel:V','e','已审核',1,'';
delete from ld_tabwithproductview where cvid =  @cvid;

insert into ld_tabwithproductview(tabid,columns,sequence,cvid)
select @tabid,'LD_warehousetransfer:transferdate_no:transferdate_no:WareHouseTransfer_fieldlabel:V',0,@cvid
from dual where not EXISTS(select 1 from ld_tabwithproductview  where cvid = @cvid
and columns = 'LD_warehousetransfer:transferdate_no:transferdate_no:WareHouseTransfer_fieldlabel:V');

insert into ld_tabwithproductview(tabid,columns,sequence,cvid)
select @tabid,'LD_warehousetransfer:transferdate:transferdate:WareHouseTransfer_fieldlabel:V',1,@cvid
from dual where not EXISTS(select 1 from ld_tabwithproductview  where cvid = @cvid
and columns = 'LD_warehousetransfer:transferdate:transferdate:WareHouseTransfer_fieldlabel:V');

insert into ld_tabwithproductview(tabid,columns,sequence,cvid)
select @tabid,'LD_warehousetransfer:outwarehouse:outwarehouse:WareHouseTransfer_fieldlabel:V',2,@cvid
from dual where not EXISTS(select 1 from ld_tabwithproductview  where cvid = @cvid
and columns = 'LD_warehousetransfer:outwarehouse:outwarehouse:WareHouseTransfer_fieldlabel:V');

insert into ld_tabwithproductview(tabid,columns,sequence,cvid)
select @tabid,'LD_warehousetransfer:inwarehouse:inwarehouse:WareHouseTransfer_fieldlabel:V',3,@cvid
from dual where not EXISTS(select 1 from ld_tabwithproductview  where cvid = @cvid
and columns = 'LD_warehousetransfer:inwarehouse:inwarehouse:WareHouseTransfer_fieldlabel:V');

insert into ld_tabwithproductview(tabid,columns,sequence,cvid)
select @tabid,'LD_warehousetransfer:transferstatus:transferstatus:WareHouseTransfer_fieldlabel:V',4,@cvid
from dual where not EXISTS(select 1 from ld_tabwithproductview  where cvid = @cvid
and columns = 'LD_warehousetransfer:transferstatus:transferstatus:WareHouseTransfer_fieldlabel:V');

insert into ld_tabwithproductview(tabid,columns,sequence,cvid)
select @tabid,'LD_warehousetransfer:smownerid:smownerid:WareHouseTransfer_fieldlabel:V',5,@cvid
from dual where not EXISTS(select 1 from ld_tabwithproductview  where cvid = @cvid
and columns = 'LD_warehousetransfer:smownerid:smownerid:WareHouseTransfer_fieldlabel:V');

insert into ld_tabwithproductview(tabid,columns,sequence,cvid)
select @tabid,'LD_warehousetransfer:transfersmownerid:transfersmownerid:WareHouseTransfer_fieldlabel:V',6,@cvid
from dual where not EXISTS(select 1 from ld_tabwithproductview  where cvid = @cvid
and columns = 'LD_warehousetransfer:transfersmownerid:transfersmownerid:WareHouseTransfer_fieldlabel:V');

insert into ld_tabwithproductview(tabid,columns,sequence,cvid)
select @tabid,'LD_products:product_no:product_no:Products_fieldlabel:V',7,@cvid
from dual where not EXISTS(select 1 from ld_tabwithproductview  where cvid = @cvid
and columns = 'LD_products:product_no:product_no:Products_fieldlabel:V');

insert into ld_tabwithproductview(tabid,columns,sequence,cvid)
select @tabid,'LD_products:productname:productname:Products_fieldlabel:V',8,@cvid
from dual where not EXISTS(select 1 from ld_tabwithproductview  where cvid = @cvid
and columns = 'LD_products:productname:productname:Products_fieldlabel:V');

insert into ld_tabwithproductview(tabid,columns,sequence,cvid)
select @tabid,'LD_inventoryproductrel:quantity:quantity:Products_fieldlabel:V',9,@cvid
from dual where not EXISTS(select 1 from ld_tabwithproductview  where cvid = @cvid
and columns = 'LD_inventoryproductrel:quantity:quantity:Products_fieldlabel:V');

select tabid into @tabid from ld_tab where `name` = 'WareHouseTransfer';
select id into @id from ld_links_seq;
insert into ld_links(linkid,tabid,linktype,linklabel,linkurl,linkicon,handler_path,handler_class,handler,sequence)
select @id+1,@tabid,'DETAILVIEWBASIC','View History',"javascript:ModTrackerCommon.showhistory('$RECORD$')",
'themes/images/pointer.gif','modules/ModTracker/ModTracker.php','ModTracker','isViewPermitted',0
from dual where not EXISTS(select 1 from ld_links  where tabid = @tabid
and linktype ='DETAILVIEWBASIC');
update ld_links_seq set id = (select max(linkid) from ld_links);
delimiter;

update ld_tab set printtab = 1 where `name` = 'WareHouseTransfer';
delimiter;

select tabid into @tabid from ld_tab where `name` = 'WareHouseTransfer';
insert into ld_modtracker_tabs(tabid,visible)
select @tabid,1 from dual where not EXISTS(select 1 from ld_modtracker_tabs  where tabid = @tabid
and visible =1);

select id into @num_id from ld_modentity_num_seq;
select id into @num_id from ld_modentity_num_seq;
insert into LD_modentity_num(num_id,semodule,prefix,start_id,cur_id,active)
select @num_id+1,'WareHouseTransfer','DB',1,1,1 
from dual where not EXISTS(select 1 from LD_modentity_num  where semodule = 'WareHouseTransfer'); 
update ld_modentity_num_seq set id = (select max(num_id)+1 from ld_modentity_num);
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','INANDOUTNOTSAME','调入和调出仓库不能为同一个仓库！','fixedstr' FROM DUAL
WHERE NOT EXISTS(SELECT 1 FROM ld_desk  WHERE languagetype='zh' AND labelbol='INANDOUTNOTSAME' AND Labeltype='fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','INANDOUTNOTSAME','In and out warehouse can’t be the same!','fixedstr' FROM DUAL
WHERE NOT EXISTS(SELECT 1 FROM ld_desk  WHERE languagetype='zh' AND labelbol='INANDOUTNOTSAME' AND Labeltype='fixedstr');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','INANDOUTNOTSAME','调入和调出仓库不能为同一个仓库！','jspop' FROM DUAL
WHERE NOT EXISTS(SELECT 1 FROM ld_desk  WHERE languagetype='zh' AND labelbol='INANDOUTNOTSAME' AND Labeltype='jspop');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','INANDOUTNOTSAME','In and out warehouse can’t be the same!','jspop' FROM DUAL
WHERE NOT EXISTS(SELECT 1 FROM ld_desk  WHERE languagetype='en' AND labelbol='INANDOUTNOTSAME' AND Labeltype='jspop');
delimiter;

select tabid into @tabid from ld_tab where `name` = 'WareHouseTransfer';
select tabid into @related_tabid from ld_tab where `name` = 'Attachment';
select id into @relation_id from ld_relatedlists_seq;
insert into LD_relatedlists(relation_id,tabid,related_tabid,name,sequence,label,presence,actions)
select @relation_id+1,@tabid,@related_tabid,'get_attachment',1,'Attachment',0,'add' from dual 
where not EXISTS(select 1 from LD_relatedlists  where related_tabid = @related_tabid and tabid = @tabid); 
update ld_relatedlists_seq set id = (select max(relation_id) from ld_relatedlists);
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','DETERNUBETHEALLOCATION','确定调拨吗？','jspop' FROM DUAL
WHERE NOT EXISTS(SELECT 1 FROM ld_desk  WHERE languagetype='zh' AND labelbol='DETERNUBETHEALLOCATION' AND Labeltype='jspop');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','DETERNUBETHEALLOCATION','Determine the allocation？','jspop' FROM DUAL
WHERE NOT EXISTS(SELECT 1 FROM ld_desk  WHERE languagetype='en' AND labelbol='DETERNUBETHEALLOCATION' AND Labeltype='jspop');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','AFTEREXECUTIONDETERNUBETHEALLOCATION','执行后，该库间调拨单将被还原到“未审核”状态，库存数量还原到调拨前。确定要反审核吗？','jspop' FROM DUAL
WHERE NOT EXISTS(SELECT 1 FROM ld_desk  WHERE languagetype='zh' AND labelbol='AFTEREXECUTIONDETERNUBETHEALLOCATION' AND Labeltype='jspop');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','AFTEREXECUTIONDETERNUBETHEALLOCATION','After execution,the status will be restored and record the stock journal. are you sure you want to do this?','jspop' FROM DUAL
WHERE NOT EXISTS(SELECT 1 FROM ld_desk  WHERE languagetype='en' AND labelbol='AFTEREXECUTIONDETERNUBETHEALLOCATION' AND Labeltype='jspop');
delimiter;

select tabid into @tabid from ld_tab where `name` = 'WareHouseTransfer';
select tabid into @att_tabid from ld_tab where `name` = 'Attachment';
insert into ld_quickactions(tabid,related_tabid,sequence,presence,label)
select @tabid,@att_tabid,1,0,'创建 附件' FROM DUAL
WHERE NOT EXISTS(SELECT 1 FROM ld_quickactions  WHERE tabid=@tabid AND related_tabid=@att_tabid);

insert into ld_quickactions(tabid,related_tabid,sequence,presence,label)
select @tabid,-1,2,0,'修改日志' FROM DUAL
WHERE NOT EXISTS(SELECT 1 FROM ld_quickactions  WHERE tabid=@tabid AND related_tabid=-1);

insert into ld_quickactions(tabid,related_tabid,sequence,presence,label)
select @tabid,-5,3,0,'打印工具' FROM DUAL
WHERE NOT EXISTS(SELECT 1 FROM ld_quickactions  WHERE tabid=@tabid AND related_tabid=-5);
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','SORRYYOUDONOTHAVEPERMISSIONTOTHISDOCUMENT','对不起，您对该单据的仓库没有操作权限','jspop' FROM DUAL
WHERE NOT EXISTS(SELECT 1 FROM ld_desk  WHERE languagetype='zh' AND labelbol='SORRYYOUDONOTHAVEPERMISSIONTOTHISDOCUMENT' AND Labeltype='jspop');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','SORRYYOUDONOTHAVEPERMISSIONTOTHISDOCUMENT','Sorry, you do not have permission to this document warehouse operation！','jspop' FROM DUAL
WHERE NOT EXISTS(SELECT 1 FROM ld_desk  WHERE languagetype='en' AND labelbol='SORRYYOUDONOTHAVEPERMISSIONTOTHISDOCUMENT' AND Labeltype='jspop');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','YBSRADCNBBD','您选择的记录有已审核的单据，不能进行批量删除！','fixedstr' FROM DUAL
WHERE NOT EXISTS(SELECT 1 FROM ld_desk  WHERE languagetype='zh' AND labelbol='YBSRADCNBBD' AND Labeltype='fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','YBSRADCNBBD','You have been selected record audit documents can not be bulk delete!','fixedstr' FROM DUAL
WHERE NOT EXISTS(SELECT 1 FROM ld_desk  WHERE languagetype='en' AND labelbol='YBSRADCNBBD' AND Labeltype='fixedstr');
delimiter;
-- end 2014-10-29

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'zh','THISYEAR','本年','fixedstr' from dual 
where not EXISTS(select 1 from ld_desk  where languagetype='zh' and labelbol='THISYEAR' and Labeltype='fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'en','THISYEAR','This year','fixedstr' from dual 
where not EXISTS(select 1 from ld_desk  where languagetype='en' and labelbol='THISYEAR' and Labeltype='fixedstr');
delimiter;

CREATE TABLE IF NOT EXISTS `ld_approvepickfield` (
  `tabid` int(11) NOT NULL DEFAULT '0',
  `fieldid` int(11) NOT NULL DEFAULT '0'
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
delimiter;

select tabid into @tabid from ld_tab where name = 'Accounts';
SELECT fieldid  into @fieldid from ld_field where tabid=@tabid and fieldname='rating';
insert into ld_approvepickfield(tabid,fieldid) select @tabid,@fieldid from dual 
where not EXISTS(select 1 from ld_approvepickfield  where tabid=@tabid and fieldid=@fieldid);
delimiter;

select tabid into @tabid from ld_tab where name = 'ServiceContracts';
SELECT fieldid  into @fieldid from ld_field where tabid=@tabid and fieldname='contract_status';
insert into ld_approvepickfield(tabid,fieldid) select @tabid,@fieldid from dual 
where not EXISTS(select 1 from ld_approvepickfield  where tabid=@tabid and fieldid=@fieldid);
delimiter;

select tabid into @tabid from ld_tab where name = 'HelpDesk';
SELECT fieldid  into @fieldid from ld_field where tabid=@tabid and fieldname='ticketstatus';
insert into ld_approvepickfield(tabid,fieldid) select @tabid,@fieldid from dual 
where not EXISTS(select 1 from ld_approvepickfield  where tabid=@tabid and fieldid=@fieldid);
delimiter;

select tabid into @tabid from ld_tab where name = 'Calendar';
SELECT fieldid  into @fieldid from ld_field where tabid=@tabid and fieldname='eventstatus';
insert into ld_approvepickfield(tabid,fieldid) select @tabid,@fieldid from dual 
where not EXISTS(select 1 from ld_approvepickfield  where tabid=@tabid and fieldid=@fieldid);
delimiter;

select tabid into @tabid from ld_tab where name = 'Potentials';
SELECT fieldid  into @fieldid from ld_field where tabid=@tabid and fieldname='sales_stage';
insert into ld_approvepickfield(tabid,fieldid) select @tabid,@fieldid from dual 
where not EXISTS(select 1 from ld_approvepickfield  where tabid=@tabid and fieldid=@fieldid);
delimiter;

select tabid into @tabid from ld_tab where name = 'Quotes';
SELECT fieldid  into @fieldid from ld_field where tabid=@tabid and fieldname='quotestage';
insert into ld_approvepickfield(tabid,fieldid) select @tabid,@fieldid from dual 
where not EXISTS(select 1 from ld_approvepickfield  where tabid=@tabid and fieldid=@fieldid);
delimiter;

select tabid into @tabid from ld_tab where name = 'SalesOrder';
SELECT fieldid  into @fieldid from ld_field where tabid=@tabid and fieldname='sostatus';
insert into ld_approvepickfield(tabid,fieldid) select @tabid,@fieldid from dual 
where not EXISTS(select 1 from ld_approvepickfield  where tabid=@tabid and fieldid=@fieldid);
delimiter;

select tabid into @tabid from ld_tab where name = 'PurchaseOrder';
SELECT fieldid  into @fieldid from ld_field where tabid=@tabid and fieldname='postatus';
insert into ld_approvepickfield(tabid,fieldid) select @tabid,@fieldid from dual 
where not EXISTS(select 1 from ld_approvepickfield  where tabid=@tabid and fieldid=@fieldid);
delimiter;

select tabid into @tabid from ld_tab where name = 'Project';
SELECT fieldid  into @fieldid from ld_field where tabid=@tabid and fieldname='projectstatus';
insert into ld_approvepickfield(tabid,fieldid) select @tabid,@fieldid from dual 
where not EXISTS(select 1 from ld_approvepickfield  where tabid=@tabid and fieldid=@fieldid);
delimiter;

select tabid into @tabid from ld_tab where name = 'Invoice';
SELECT fieldid  into @fieldid from ld_field where tabid=@tabid and fieldname='invoicestatus';
insert into ld_approvepickfield(tabid,fieldid) select @tabid,@fieldid from dual 
where not EXISTS(select 1 from ld_approvepickfield  where tabid=@tabid and fieldid=@fieldid);
delimiter;

select tabid into @tabid from ld_tab where name = 'PurchaseInvoice';
SELECT fieldid  into @fieldid from ld_field where tabid=@tabid and fieldname='purchaseinvoicestatus';
insert into ld_approvepickfield(tabid,fieldid) select @tabid,@fieldid from dual 
where not EXISTS(select 1 from ld_approvepickfield  where tabid=@tabid and fieldid=@fieldid);
delimiter;

update ld_tranlabel set fieldlabel = '登录时启用手机短信验证' where languagetype = 'zh' and tabid in (select tabid from ld_tab where name = 'Users') 
and Relateid in (select fieldid from ld_field where columnname= 'login_sms' and tabid in (select tabid from ld_tab where name = 'Users') );
update ld_tranlabel set fieldlabel = 'Enable SMS verification' where languagetype = 'en' and tabid in (select tabid from ld_tab where name = 'Users') 
and Relateid in (select fieldid from ld_field where columnname= 'login_sms' and tabid in (select tabid from ld_tab where name = 'Users') );
delimiter;
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'zh','NEEDBUYACCOUNT','（需购买并设置通讯账户）','fixedstr' from dual 
where not EXISTS(select 1 from ld_desk  where languagetype='zh' and labelbol='NEEDBUYACCOUNT' and Labeltype='fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'en','NEEDBUYACCOUNT','(Need to buy communication account first)','fixedstr' from dual 
where not EXISTS(select 1 from ld_desk  where languagetype='en' and labelbol='NEEDBUYACCOUNT' and Labeltype='fixedstr');
delimiter;
update ld_desk set Fieldlabel='1. 若用户已绑定手机，则无需再输入手机号；' where labelbol='WARMREMINDEONE' and languagetype='zh' and Labeltype = 'fixedstr';
update ld_desk set Fieldlabel='1. If have binding mobile phone,no need to enter the mobile phone number;' where labelbol='WARMREMINDEONE' and languagetype='en' and Labeltype = 'fixedstr';
delimiter;
update ld_desk set Fieldlabel='2. 若用户未绑定手机，则可输入手机号，获取验证码登录后自动绑定该手机；' where labelbol='WARMREMINDETWO' and languagetype='zh' and Labeltype = 'fixedstr';
update ld_desk set Fieldlabel='2. If no binding mobile phone, need to enter the mobile phone number, after using the verification code to log in the system will automatically bind the mobile phone;' where labelbol='WARMREMINDETWO' and languagetype='en' and Labeltype = 'fixedstr';
delimiter;
update ld_desk set Fieldlabel='3. 同一客户端24小时内只需要验证一次；' where labelbol='WARMREMINDETHREEE' and languagetype='zh' and Labeltype = 'fixedstr';
update ld_desk set Fieldlabel='3. 24 hours just need to verify once at the same client;' where labelbol='WARMREMINDETHREEE' and languagetype='en' and Labeltype = 'fixedstr';
delimiter;

select tabid into @tabid from ld_tab where name = 'SalesOrder';
select tabid into @tabid2 from ld_tab where name = 'PurchaseOrder';
select tabid into @tabid3 from ld_tab where name = 'Invoice';
SELECT sequence into @sequence from ld_quickactions where tabid=@tabid AND related_tabid=@tabid3; 
insert into ld_quickactions(tabid,related_tabid,sequence,presence)
select @tabid,@tabid2,@sequence+1,0 from dual 
where not EXISTS(select 1 from ld_quickactions  where tabid=@tabid and related_tabid=@tabid2);
delimiter;

select tabid into @tabid from ld_tab where `name` = 'SalesOrder';
select tabid into @related_tabid from ld_tab where `name` = 'PurchaseOrder';
select tabid into @tabid3 from ld_tab where name = 'Invoice';
SELECT sequence INTO @sequence from LD_relatedlists WHERE name = 'Invoice';
select id into @relation_id from ld_relatedlists_seq;
insert into LD_relatedlists(relation_id,tabid,related_tabid,name,sequence,label,presence,actions)
select @relation_id+1,@tabid,@related_tabid,'get_purchaseorder',@sequence+1,'PurchaseOrder',0,'add' from dual 
where not EXISTS(select 1 from LD_relatedlists  where related_tabid = @related_tabid and tabid = @tabid); 
update ld_relatedlists_seq set id = (select max(relation_id) from ld_relatedlists);
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'zh','PHONESTEWARD','电话管家','fixedstr' from dual 
where not EXISTS(select 1 from ld_desk where languagetype='zh' and labelbol='PHONESTEWARD' and Labeltype='fixedstr'); 
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'en','PHONESTEWARD','Phone Steward','fixedstr' from dual 
where not EXISTS(select 1 from ld_desk where languagetype='en' and labelbol='PHONESTEWARD' and Labeltype='fixedstr'); 
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'zh','CCEMAILERROR','您的抄送地址不正确','fixedstr' from dual 
where not EXISTS(select 1 from ld_desk  where languagetype='zh' and labelbol='CCEMAILERROR' and Labeltype='fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'en','CCEMAILERROR','Your CC address is incorrect','fixedstr' from dual 
where not EXISTS(select 1 from ld_desk  where languagetype='en' and labelbol='CCEMAILERROR' and Labeltype='fixedstr');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'zh','BCCEMAILERROR','您的密送地址不正确','fixedstr' from dual 
where not EXISTS(select 1 from ld_desk  where languagetype='zh' and labelbol='BCCEMAILERROR' and Labeltype='fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'en','BCCEMAILERROR','Your Bcc address is incorrect','fixedstr' from dual 
where not EXISTS(select 1 from ld_desk  where languagetype='en' and labelbol='BCCEMAILERROR' and Labeltype='fixedstr');
delimiter;

update ld_desk set Fieldlabel='今日计划和总结' where labelbol='VIEWTODAYPROGRAMWRITESUMMARY' and languagetype='zh' and Labeltype = 'fixedstr';
update ld_desk set Fieldlabel="Today's plan and summary" where labelbol='VIEWTODAYPROGRAMWRITESUMMARY' and languagetype='en' and Labeltype = 'fixedstr';
delimiter;

update ld_desk set Fieldlabel='明日计划' where labelbol='WRITE_TOMORROW_PLAN' and languagetype='zh' and Labeltype = 'fixedstr';
update ld_desk set Fieldlabel="Tomorrow Plan" where labelbol='WRITE_TOMORROW_PLAN' and languagetype='en' and Labeltype = 'fixedstr';
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'zh','UsersALLOWQUERY','（在客户相关信息中允许查询所有数据）','fixedstr' from dual 
where not EXISTS(select 1 from ld_desk  where languagetype='zh' and labelbol='UsersALLOWQUERY' and Labeltype='fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'en','UsersALLOWQUERY','(Allow query all data in the customer related information)','fixedstr' from dual 
where not EXISTS(select 1 from ld_desk  where languagetype='en' and labelbol='UsersALLOWQUERY' and Labeltype='fixedstr');
delimiter;


call addcolumn('LD_callbutler','accountid','int','19',0);
delimiter;
call addcolumn('LD_callbutler','contactid','int','19',0);
delimiter;
call addcolumn('LD_callbutler','ticketid','int','19',0);
delimiter;
call addcolumn('LD_callbutler','vendorid','int','19',0);
delimiter;
call addcolumn('LD_callbutler','vendorcontactid','int','19',0);
delimiter;
call addcolumn('LD_callbutler','contactrecordsid','int','19',0);
delimiter;
call addcolumn('LD_callbutler','vendorcontactrecordsid','int','19',0);
delimiter;
call addcolumn('LD_callbutler','description','varchar','500',null);
delimiter;


insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'zh','click_group_button','点击群发按钮后，邮件会逐个分别发送','fixedstr' from dual 
where not EXISTS(select 1 from ld_desk  where languagetype='zh' and labelbol='click_group_button' and Labeltype='fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'en','click_group_button','Click the group button, the message will be sent respectively','fixedstr' from dual 
where not EXISTS(select 1 from ld_desk  where languagetype='en' and labelbol='click_group_button' and Labeltype='fixedstr');
delimiter;
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'zh','Recordfile','录音文件','fixedstr' from dual 
where not EXISTS(select 1 from ld_desk  where languagetype='zh' and labelbol='Recordfile' and Labeltype='fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'en','Recordfile','Recording File','fixedstr' from dual 
where not EXISTS(select 1 from ld_desk  where languagetype='en' and labelbol='Recordfile' and Labeltype='fixedstr');
delimiter;
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'zh','Recordnotes','录音备注','fixedstr' from dual 
where not EXISTS(select 1 from ld_desk  where languagetype='zh' and labelbol='Recordnotes' and Labeltype='fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'en','Recordnotes','Recording Notes','fixedstr' from dual 
where not EXISTS(select 1 from ld_desk  where languagetype='en' and labelbol='Recordnotes' and Labeltype='fixedstr');
delimiter;
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'zh','RecordfileInfo','录音文件信息','fixedstr' from dual 
where not EXISTS(select 1 from ld_desk  where languagetype='zh' and labelbol='RecordfileInfo' and Labeltype='fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'en','RecordfileInfo','Recording file information','fixedstr' from dual 
where not EXISTS(select 1 from ld_desk  where languagetype='en' and labelbol='RecordfileInfo' and Labeltype='fixedstr');
delimiter;
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'zh','Calltype','通话类型','fixedstr' from dual 
where not EXISTS(select 1 from ld_desk  where languagetype='zh' and labelbol='Calltype' and Labeltype='fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'en','Calltype','Call Type','fixedstr' from dual 
where not EXISTS(select 1 from ld_desk  where languagetype='en' and labelbol='Calltype' and Labeltype='fixedstr');
delimiter;
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'zh','CallerID','来电号码','fixedstr' from dual 
where not EXISTS(select 1 from ld_desk  where languagetype='zh' and labelbol='CallerID' and Labeltype='fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'en','CallerID','Caller ID','fixedstr' from dual 
where not EXISTS(select 1 from ld_desk  where languagetype='en' and labelbol='CallerID' and Labeltype='fixedstr');
delimiter;
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'zh','StartTime','开始时间','fixedstr' from dual 
where not EXISTS(select 1 from ld_desk  where languagetype='zh' and labelbol='StartTime' and Labeltype='fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'en','StartTime','Start Time','fixedstr' from dual 
where not EXISTS(select 1 from ld_desk  where languagetype='en' and labelbol='StartTime' and Labeltype='fixedstr');
delimiter;
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'zh','EndTime','结束时间','fixedstr' from dual 
where not EXISTS(select 1 from ld_desk  where languagetype='zh' and labelbol='EndTime' and Labeltype='fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'en','EndTime','End Time','fixedstr' from dual 
where not EXISTS(select 1 from ld_desk  where languagetype='en' and labelbol='EndTime' and Labeltype='fixedstr');
delimiter;
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'zh','TalkTime','通话时长','fixedstr' from dual 
where not EXISTS(select 1 from ld_desk  where languagetype='zh' and labelbol='TalkTime' and Labeltype='fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'en','TalkTime','Talk Time','fixedstr' from dual 
where not EXISTS(select 1 from ld_desk  where languagetype='en' and labelbol='TalkTime' and Labeltype='fixedstr');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'zh','Second','秒','fixedstr' from dual 
where not EXISTS(select 1 from ld_desk  where languagetype='zh' and labelbol='Second' and Labeltype='fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'en','Second','Second','fixedstr' from dual 
where not EXISTS(select 1 from ld_desk  where languagetype='en' and labelbol='Second' and Labeltype='fixedstr');
delimiter;


update ld_field set fieldname = 'assigned_user_id' where columnname = 'smownerid' and fieldname = 'smownerid';
delimiter;
select tabid into @tabid from ld_tab where `name` = 'WareHouseTransfer';
update ld_tabwithproductview set `columns` = 'LD_warehousetransfer:smownerid:assigned_user_id:WareHouseTransfer_fieldlabel:V' where tabid = @tabid and `columns` = 'LD_warehousetransfer:smownerid:smownerid:WareHouseTransfer_fieldlabel:V';
delimiter;
select tabid into @tabid from ld_tab where `name` = 'PurchaseInvoice';
update ld_tabwithproductview set `columns` = 'LD_purchaseinvoice:smownerid:assigned_user_id:PurchaseInvoice_fieldlabel:V' where tabid = @tabid and `columns` = 'LD_purchaseinvoice:smownerid:smownerid:PurchaseInvoice_fieldlabel:V';
delimiter;

update ld_settings_field set active=0 where name='VTLIB_LBL_MODULE_MANAGER'  and EXISTS(select 1 from ld_version where versiontype=2);
update ld_settings_field set active=0 where name='VTLIB_LBL_MODULE_MANAGER'  and EXISTS(select 1 from ld_version where versiontype=7);
delimiter;

call addtableIndex('ld_servicecontracts','sc_accountid_servicecontacts_idx','accountid');
delimiter;

update ld_tab set ownedby = 0 where `name` = 'WareHouseTransfer';
delimiter;

INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
	SELECT 'zh','AUTOMATICBACKUP','自动备份','fixedstr'
		FROM DUAL WHERE NOT EXISTS
	(SELECT 1 FROM ld_desk  WHERE languagetype='zh' AND
		labelbol='AUTOMATICBACKUP' AND Labeltype='fixedstr');

INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
	SELECT 'en','AUTOMATICBACKUP','Automatic backup','fixedstr'
	FROM DUAL WHERE NOT EXISTS
	(SELECT 1 FROM ld_desk  WHERE languagetype='en' AND
		labelbol='AUTOMATICBACKUP' AND Labeltype='fixedstr');

INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
	SELECT 'zh','WHETHERTOENABLE','是否启用','fixedstr'
		FROM DUAL WHERE NOT EXISTS
	(SELECT 1 FROM ld_desk  WHERE languagetype='zh' AND
		labelbol='WHETHERTOENABLE' AND Labeltype='fixedstr');

INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
	SELECT 'en','WHETHERTOENABLE','Whether to enable','fixedstr'
	FROM DUAL WHERE NOT EXISTS
	(SELECT 1 FROM ld_desk  WHERE languagetype='en' AND
		labelbol='WHETHERTOENABLE' AND Labeltype='fixedstr');

INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
	SELECT 'zh','AUTOMATICBACKUPCYCLE','自动备份周期','fixedstr'
		FROM DUAL WHERE NOT EXISTS
	(SELECT 1 FROM ld_desk  WHERE languagetype='zh' AND
		labelbol='AUTOMATICBACKUPCYCLE' AND Labeltype='fixedstr');

INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
	SELECT 'en','AUTOMATICBACKUPCYCLE','Automatic backup cycle','fixedstr'
	FROM DUAL WHERE NOT EXISTS
	(SELECT 1 FROM ld_desk  WHERE languagetype='en' AND
		labelbol='AUTOMATICBACKUPCYCLE' AND Labeltype='fixedstr');

INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
	SELECT 'zh','DELETETHEBACKUPDATA','删除备份数据','fixedstr'
		FROM DUAL WHERE NOT EXISTS
	(SELECT 1 FROM ld_desk  WHERE languagetype='zh' AND
		labelbol='DELETETHEBACKUPDATA' AND Labeltype='fixedstr');

INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
	SELECT 'en','DELETETHEBACKUPDATA','Delete the backup data','fixedstr'
	FROM DUAL WHERE NOT EXISTS
	(SELECT 1 FROM ld_desk  WHERE languagetype='en' AND
		labelbol='DELETETHEBACKUPDATA' AND Labeltype='fixedstr');

INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
	SELECT 'zh','BACKUPFILENOTINFORMAT','备份文件路径格式不正确，不可以包含 \ . 等特殊字符。','jspop'
		FROM DUAL WHERE NOT EXISTS
	(SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND
		labelbol='BACKUPFILENOTINFORMAT' AND Labeltype='jspop');

INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
	SELECT 'en','BACKUPFILENOTINFORMAT','The backup file path is not in the correct format, may not contain special characters such as \ . ','jspop'
	FROM DUAL WHERE NOT EXISTS
	(SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND
		labelbol='BACKUPFILENOTINFORMAT' AND Labeltype='jspop');

INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
	SELECT 'zh','NOTTHECORRECTFILEPATH','这不是正确的文件路径。','jspop'
		FROM DUAL WHERE NOT EXISTS
	(SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND
		labelbol='NOTTHECORRECTFILEPATH' AND Labeltype='jspop');

INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
	SELECT 'en','NOTTHECORRECTFILEPATH','This is not the correct file path','jspop'
	FROM DUAL WHERE NOT EXISTS
	(SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND
		labelbol='NOTTHECORRECTFILEPATH' AND Labeltype='jspop');
delimiter;

ALTER TABLE ld_backup MODIFY intervaldays VARCHAR(100);
update ld_backup set isusing = 0 WHERE id = 2 and isusing = 1;
delimiter;

delete from ld_desk where labelbol='PLANDSTARTDATE' and Labeltype = 'fixedstr';
delimiter;
update ld_desk set Fieldlabel='总期次' where labelbol='PERIODLOAD' and languagetype='zh' and Labeltype = 'fixedstr';
update ld_desk set Fieldlabel='Total of times' where labelbol='PERIODLOAD' and languagetype='en' and Labeltype = 'fixedstr';
delimiter;
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'zh','FIRSTBACKSECTION','首次回款日期','fixedstr' from dual 
where not EXISTS(select 1 from ld_desk  where languagetype='zh' and labelbol='FIRSTBACKSECTION' and Labeltype='fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'en','FIRSTBACKSECTION','First Back Section','fixedstr' from dual 
where not EXISTS(select 1 from ld_desk  where languagetype='en' and labelbol='FIRSTBACKSECTION' and Labeltype='fixedstr');
delimiter;
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'zh','FIRSTDATEPAYMENT','首次付款日期','fixedstr' from dual 
where not EXISTS(select 1 from ld_desk  where languagetype='zh' and labelbol='FIRSTDATEPAYMENT' and Labeltype='fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'en','FIRSTDATEPAYMENT','First Payment Date','fixedstr' from dual 
where not EXISTS(select 1 from ld_desk  where languagetype='en' and labelbol='FIRSTDATEPAYMENT' and Labeltype='fixedstr');
delimiter;
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'zh','RECALCULATE','重算','fixedstr' from dual 
where not EXISTS(select 1 from ld_desk  where languagetype='zh' and labelbol='RECALCULATE' and Labeltype='fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'en','RECALCULATE','Recalculate','fixedstr' from dual 
where not EXISTS(select 1 from ld_desk  where languagetype='en' and labelbol='RECALCULATE' and Labeltype='fixedstr');
delimiter;
update ld_desk set Fieldlabel='由调出库和调入库的库管分别审核调拨明细执行调拨' where labelbol='THEFIRSTSTEPREGULATINGSASSTORAGEWAREHOUSE' and languagetype='zh' and Labeltype = 'fixedstr';
delimiter;
-- end 2014-11-03

delete from ld_announcement; 

select tabid into @tabid from ld_tab where name='Accounts';
select tabid into @relatedtabid from ld_tab where name='CommunicationLog';
select max(sequence)+1 into @sequence from ld_relatedlists where tabid = @tabid;
select max(relation_id) into @relation_id from lD_RelatedLists;
insert into LD_relatedlists(relation_id,tabid,related_tabid,name,sequence,label,presence,actions)
select @relation_id+1,@tabid,@relatedtabid,'get_CallButler',@sequence,'CallButler',0,'add' from dual where not exists(select 1 from ld_relatedlists where name='get_CallButler' and tabid=@tabid);
update lD_RelatedLists_seq set id=(select max(relation_id) from lD_RelatedLists);
delimiter;

select tabid into @tabid from ld_tab where name='Contacts';
select tabid into @relatedtabid from ld_tab where name='CommunicationLog';
select max(sequence)+1 into @sequence from ld_relatedlists where tabid = @tabid;
select max(relation_id) into @relation_id from lD_RelatedLists;
insert into LD_relatedlists(relation_id,tabid,related_tabid,name,sequence,label,presence,actions)
select @relation_id+1,@tabid,@relatedtabid,'get_CallButler',@sequence,'CallButler',0,'add' from dual where not exists(select 1 from ld_relatedlists where name='get_CallButler' and tabid=@tabid);
update lD_RelatedLists_seq set id=(select max(relation_id) from lD_RelatedLists);
delimiter;


select tabid into @tabid from ld_tab where name='HelpDesk';
select tabid into @relatedtabid from ld_tab where name='CommunicationLog';
select max(sequence)+1 into @sequence from ld_relatedlists where tabid = @tabid;
select max(relation_id) into @relation_id from lD_RelatedLists;
insert into LD_relatedlists(relation_id,tabid,related_tabid,name,sequence,label,presence,actions)
select @relation_id+1,@tabid,@relatedtabid,'get_CallButler',@sequence,'CallButler',0,'add' from dual where not exists(select 1 from ld_relatedlists where name='get_CallButler' and tabid=@tabid);
update lD_RelatedLists_seq set id=(select max(relation_id) from lD_RelatedLists);
delimiter;

select tabid into @tabid from ld_tab where name='ContactRecords';
select tabid into @relatedtabid from ld_tab where name='CommunicationLog';
select max(sequence)+1 into @sequence from ld_relatedlists where tabid = @tabid;
select max(relation_id) into @relation_id from lD_RelatedLists;
insert into LD_relatedlists(relation_id,tabid,related_tabid,name,sequence,label,presence,actions)
select @relation_id+1,@tabid,@relatedtabid,'get_CallButler',@sequence,'CallButler',0,'add' from dual where not exists(select 1 from ld_relatedlists where name='get_CallButler' and tabid=@tabid);
update lD_RelatedLists_seq set id=(select max(relation_id) from lD_RelatedLists);
delimiter;


select tabid into @tabid from ld_tab where name='Vendors';
select tabid into @relatedtabid from ld_tab where name='CommunicationLog';
select max(sequence)+1 into @sequence from ld_relatedlists where tabid = @tabid;
select max(relation_id) into @relation_id from lD_RelatedLists;
insert into LD_relatedlists(relation_id,tabid,related_tabid,name,sequence,label,presence,actions)
select @relation_id+1,@tabid,@relatedtabid,'get_CallButler',@sequence,'CallButler',0,'add' from dual where not exists(select 1 from ld_relatedlists where name='get_CallButler' and tabid=@tabid);
update lD_RelatedLists_seq set id=(select max(relation_id) from lD_RelatedLists);
delimiter;

select tabid into @tabid from ld_tab where name='VendorContact';
select tabid into @relatedtabid from ld_tab where name='CommunicationLog';
select max(sequence)+1 into @sequence from ld_relatedlists where tabid = @tabid;
select max(relation_id) into @relation_id from lD_RelatedLists;
insert into LD_relatedlists(relation_id,tabid,related_tabid,name,sequence,label,presence,actions)
select @relation_id+1,@tabid,@relatedtabid,'get_CallButler',1,'CallButler',0,'add' from dual where not exists(select 1 from ld_relatedlists where name='get_CallButler' and tabid=@tabid);
update lD_RelatedLists_seq set id=(select max(relation_id) from lD_RelatedLists);
delimiter;

select tabid into @tabid from ld_tab where name='VendorContactRecords';
select tabid into @relatedtabid from ld_tab where name='CommunicationLog';
select max(sequence)+1 into @sequence from ld_relatedlists where tabid = @tabid;
select max(relation_id) into @relation_id from lD_RelatedLists;
insert into LD_relatedlists(relation_id,tabid,related_tabid,name,sequence,label,presence,actions)
select @relation_id+1,@tabid,@relatedtabid,'get_CallButler',@sequence,'CallButler',0,'add' from dual where not exists(select 1 from ld_relatedlists where name='get_CallButler' and tabid=@tabid);
update lD_RelatedLists_seq set id=(select max(relation_id) from lD_RelatedLists);
delimiter;


SELECT usereportid INTO @usereportid  from ld_usereport where name='SalesSumSequence';
SELECT max(sequence)  into @sequence from LD_UseReportcolumns where Usereportid=@usereportid;
INSERT INTO LD_UseReportcolumns(Usereportid,columns,Sequence,columnshow,realcolumns,realencolumns)
SELECT @usereportid,'LD_servicecontracts:servicecontractstotal:oftenusereport_servicecontractstotal:N',@sequence+1,1,
'LD_servicecontracts:servicecontractstotal:servicecontractstotal:OftenUseReport_服务合同金额:N',
'LD_servicecontracts:servicecontractstotal:servicecontractstotal: ServiceContracts total:N' from dual 
where not EXISTS(select 1 from LD_UseReportcolumns  where usereportid=@usereportid and columns='LD_servicecontracts:servicecontractstotal:oftenusereport_servicecontractstotal:N');
delimiter;

SELECT usereportid INTO @usereportid  from ld_usereport where name='SalesSumSequence';
SELECT max(sequence)  into @sequence from LD_UseReportcolumns where Usereportid=@usereportid;
INSERT INTO LD_UseReportcolumns(Usereportid,columns,Sequence,columnshow,realcolumns,realencolumns)
SELECT @usereportid,'LD_servicecontracts:servicecontractscount:oftenusereport_servicecontractscount:N',@sequence+1,1,
'LD_servicecontracts:servicecontractscount:servicecontractscount:OftenUseReport_服务合同笔数:N',
'LD_servicecontracts:servicecontractscount:servicecontractscount: ServiceContracts count:N' from dual 
where not EXISTS(select 1 from LD_UseReportcolumns  where usereportid=@usereportid and columns='LD_servicecontracts:servicecontractscount:oftenusereport_servicecontractscount:N');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'zh','CHAINHOMEMONTH','环比','fixedstr' from dual 
where not EXISTS(select 1 from ld_desk  where languagetype='zh' and labelbol='CHAINHOMEMONTH' and Labeltype='fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'en','CHAINHOMEMONTH','month-on-month','fixedstr' from dual 
where not EXISTS(select 1 from ld_desk  where languagetype='en' and labelbol='CHAINHOMEMONTH' and Labeltype='fixedstr');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'zh','CHAINHOMEWEEK','环比','fixedstr' from dual 
where not EXISTS(select 1 from ld_desk  where languagetype='zh' and labelbol='CHAINHOMEWEEK' and Labeltype='fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'en','CHAINHOMEWEEK','week-on-week','fixedstr' from dual 
where not EXISTS(select 1 from ld_desk  where languagetype='en' and labelbol='CHAINHOMEWEEK' and Labeltype='fixedstr');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'zh','CONTRACTNUMBERHONE','签约数量','fixedstr' from dual 
where not EXISTS(select 1 from ld_desk  where languagetype='zh' and labelbol='CONTRACTNUMBERHONE' and Labeltype='fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'en','CONTRACTNUMBERHONE','Contract number','fixedstr' from dual 
where not EXISTS(select 1 from ld_desk  where languagetype='en' and labelbol='CONTRACTNUMBERHONE' and Labeltype='fixedstr');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'zh','THESTATICOFTHISWEEK','本周统计','fixedstr' from dual 
where not EXISTS(select 1 from ld_desk  where languagetype='zh' and labelbol='THESTATICOFTHISWEEK' and Labeltype='fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'en','THESTATICOFTHISWEEK','The statistics of this week','fixedstr' from dual 
where not EXISTS(select 1 from ld_desk  where languagetype='en' and labelbol='THESTATICOFTHISWEEK' and Labeltype='fixedstr');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'zh','THESTATICOFTHISMONTH','本月统计','fixedstr' from dual 
where not EXISTS(select 1 from ld_desk  where languagetype='zh' and labelbol='THESTATICOFTHISMONTH' and Labeltype='fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'en','THESTATICOFTHISMONTH','The statistics of this month','fixedstr' from dual 
where not EXISTS(select 1 from ld_desk  where languagetype='en' and labelbol='THESTATICOFTHISMONTH' and Labeltype='fixedstr');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'zh','THISWEEKTHENUMBEROFNEWACCOUNTS','本周新增客户数','fixedstr' from dual 
where not EXISTS(select 1 from ld_desk  where languagetype='zh' and labelbol='THISWEEKTHENUMBEROFNEWACCOUNTS' and Labeltype='fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'en','THISWEEKTHENUMBEROFNEWACCOUNTS','This week the number of new accounts','fixedstr' from dual 
where not EXISTS(select 1 from ld_desk  where languagetype='en' and labelbol='THISWEEKTHENUMBEROFNEWACCOUNTS' and Labeltype='fixedstr');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'zh','THISMONTHTHENUMBEROFNEWACCOUNTS','本月新增客户数','fixedstr' from dual 
where not EXISTS(select 1 from ld_desk  where languagetype='zh' and labelbol='THISMONTHTHENUMBEROFNEWACCOUNTS' and Labeltype='fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'en','THISMONTHTHENUMBEROFNEWACCOUNTS','This month the number of new accounts','fixedstr' from dual 
where not EXISTS(select 1 from ld_desk  where languagetype='en' and labelbol='THISMONTHTHENUMBEROFNEWACCOUNTS' and Labeltype='fixedstr');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'zh','THISWEEKTHENUMBEROFCONTACTRECORDS','本周新增联系记录数','fixedstr' from dual 
where not EXISTS(select 1 from ld_desk  where languagetype='zh' and labelbol='THISWEEKTHENUMBEROFCONTACTRECORDS' and Labeltype='fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'en','THISWEEKTHENUMBEROFCONTACTRECORDS','This week the number of new contact records','fixedstr' from dual 
where not EXISTS(select 1 from ld_desk  where languagetype='en' and labelbol='THISWEEKTHENUMBEROFCONTACTRECORDS' and Labeltype='fixedstr');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'zh','THISMONTHTHENUMBEROFCONTACTRECORDS','本月新增联系记录数','fixedstr' from dual 
where not EXISTS(select 1 from ld_desk  where languagetype='zh' and labelbol='THISMONTHTHENUMBEROFCONTACTRECORDS' and Labeltype='fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'en','THISMONTHTHENUMBEROFCONTACTRECORDS','This month the number of new contact records','fixedstr' from dual 
where not EXISTS(select 1 from ld_desk  where languagetype='en' and labelbol='THISMONTHTHENUMBEROFCONTACTRECORDS' and Labeltype='fixedstr');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'zh','THISEEKTHENUMBEROFNEWCONTRACTS','本周签约数量','fixedstr' from dual 
where not EXISTS(select 1 from ld_desk  where languagetype='zh' and labelbol='THISEEKTHENUMBEROFNEWCONTRACTS' and Labeltype='fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'en','THISEEKTHENUMBEROFNEWCONTRACTS','This week the number of new contracts','fixedstr' from dual 
where not EXISTS(select 1 from ld_desk  where languagetype='en' and labelbol='THISEEKTHENUMBEROFNEWCONTRACTS' and Labeltype='fixedstr');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'zh','THISMONTHTHENUMBEROFNEWCONTRACTS','本月签约数量','fixedstr' from dual 
where not EXISTS(select 1 from ld_desk  where languagetype='zh' and labelbol='THISMONTHTHENUMBEROFNEWCONTRACTS' and Labeltype='fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'en','THISMONTHTHENUMBEROFNEWCONTRACTS','This month the number of new contracts','fixedstr' from dual 
where not EXISTS(select 1 from ld_desk  where languagetype='en' and labelbol='THISMONTHTHENUMBEROFNEWCONTRACTS' and Labeltype='fixedstr');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'zh','THISWEEKTHEAMOUNTOFNEWCONTRACTS','本周签约金额','fixedstr' from dual 
where not EXISTS(select 1 from ld_desk  where languagetype='zh' and labelbol='THISWEEKTHEAMOUNTOFNEWCONTRACTS' and Labeltype='fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'en','THISWEEKTHEAMOUNTOFNEWCONTRACTS','This week the amount of new contracts','fixedstr' from dual 
where not EXISTS(select 1 from ld_desk  where languagetype='en' and labelbol='THISWEEKTHEAMOUNTOFNEWCONTRACTS' and Labeltype='fixedstr');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'zh','THISMONTHTHEAMOUNTOFNEWCONTRACTS','本月签约金额','fixedstr' from dual 
where not EXISTS(select 1 from ld_desk  where languagetype='zh' and labelbol='THISMONTHTHEAMOUNTOFNEWCONTRACTS' and Labeltype='fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'en','THISMONTHTHEAMOUNTOFNEWCONTRACTS','This month the amount of new contracts','fixedstr' from dual 
where not EXISTS(select 1 from ld_desk  where languagetype='en' and labelbol='THISMONTHTHEAMOUNTOFNEWCONTRACTS' and Labeltype='fixedstr');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'zh','THISWEEKTHERECEIVEDAMOUNT','本周收款金额','fixedstr' from dual 
where not EXISTS(select 1 from ld_desk  where languagetype='zh' and labelbol='THISWEEKTHERECEIVEDAMOUNT' and Labeltype='fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'en','THISWEEKTHERECEIVEDAMOUNT','This week the received amount','fixedstr' from dual 
where not EXISTS(select 1 from ld_desk  where languagetype='en' and labelbol='THISWEEKTHERECEIVEDAMOUNT' and Labeltype='fixedstr');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'zh','THISMONTHTHERECEIVEDAMOUNT','本月收款金额','fixedstr' from dual 
where not EXISTS(select 1 from ld_desk  where languagetype='zh' and labelbol='THISMONTHTHERECEIVEDAMOUNT' and Labeltype='fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'en','THISMONTHTHERECEIVEDAMOUNT','This month the received amount','fixedstr' from dual 
where not EXISTS(select 1 from ld_desk  where languagetype='en' and labelbol='THISMONTHTHERECEIVEDAMOUNT' and Labeltype='fixedstr');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'zh','CallButler','通话记录','fixedstr' from dual 
where not EXISTS(select 1 from ld_desk  where languagetype='zh' and labelbol='CallButler' and Labeltype='fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'en','CallButler','Call Records','fixedstr' from dual 
where not EXISTS(select 1 from ld_desk  where languagetype='en' and labelbol='CallButler' and Labeltype='fixedstr');
delimiter;
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'zh','CallStartTime','开始时间','fixedstr' from dual 
where not EXISTS(select 1 from ld_desk  where languagetype='zh' and labelbol='CallStartTime' and Labeltype='fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'en','CallStartTime','Start Time','fixedstr' from dual 
where not EXISTS(select 1 from ld_desk  where languagetype='en' and labelbol='CallStartTime' and Labeltype='fixedstr');
delimiter;
update ld_desk set Fieldlabel='第二步：由调出库和调入库的库管分别审核调拨明细执行调拨' where labelbol='THEFIRSTSTEPREGULATINGSASSTORAGEWAREHOUSE' and languagetype='zh' and Labeltype = 'fixedstr';
delimiter;

delete from ld_field where tabid=23 and columnname='contactid';
delimiter;

INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
	SELECT 'zh','MSG_CHANGE_CURRENCY_REVISE_UNIT_PRICE','所有单价的币种将会被修正为所选的货币，确定吗？','jspop'
		FROM DUAL WHERE NOT EXISTS
	(SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND
		labelbol='MSG_CHANGE_CURRENCY_REVISE_UNIT_PRICE' AND Labeltype='jspop');

INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
	SELECT 'en','MSG_CHANGE_CURRENCY_REVISE_UNIT_PRICE','All the unit price of the currency will be fixed for the selected currency, OK?','jspop'
	FROM DUAL WHERE NOT EXISTS
	(SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND
		labelbol='OPERATION_DENIED' AND Labeltype='jspop');
		
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
	SELECT 'zh','OPERATION_DENIED','拒绝执行该操作','jspop'
		FROM DUAL WHERE NOT EXISTS
	(SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND
		labelbol='OPERATION_DENIED' AND Labeltype='jspop');

INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
	SELECT 'en','OPERATION_DENIED','Refuse to perform this operation','jspop'
	FROM DUAL WHERE NOT EXISTS
	(SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND
		labelbol='OPERATION_DENIED' AND Labeltype='jspop');
delimiter;
-- end 2014-11-04

UPDATE ld_desk SET fieldlabel = '退货数量不能超过源单的已出库产品数量' WHERE labelbol = 'THENUMBEROFRETURNS1' AND languagetype = 'zh';
UPDATE ld_desk SET fieldlabel = 'Returns the number of not more than the number of delivered product source list' WHERE labelbol = 'THENUMBEROFRETURNS1' AND languagetype = 'en';
delimiter;

update ld_relatedlists set related_tabid = 0 where label ='CallButler' and name = 'get_CallButler';
delimiter;
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'zh','PLAYER','播放','fixedstr' from dual 
where not EXISTS(select 1 from ld_desk  where languagetype='zh' and labelbol='PLAYER' and Labeltype='fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'en','PLAYER','Play','fixedstr' from dual 
where not EXISTS(select 1 from ld_desk  where languagetype='en' and labelbol='PLAYER' and Labeltype='fixedstr');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'zh','PhoneNumber','电话号码','fixedstr' from dual 
where not EXISTS(select 1 from ld_desk  where languagetype='zh' and labelbol='PhoneNumber' and Labeltype='fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'en','PhoneNumber','Phone number','fixedstr' from dual 
where not EXISTS(select 1 from ld_desk  where languagetype='en' and labelbol='PhoneNumber' and Labeltype='fixedstr');
delimiter;
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'zh','DURATION','时长','fixedstr' from dual 
where not EXISTS(select 1 from ld_desk  where languagetype='zh' and labelbol='DURATION' and Labeltype='fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'en','DURATION','Duration','fixedstr' from dual 
where not EXISTS(select 1 from ld_desk  where languagetype='en' and labelbol='DURATION' and Labeltype='fixedstr');
delimiter;

SELECT tabid INTO @tabid from ld_tab where name='Calendar';
DELETE from ld_approvepickfield where tabid=@tabid;
delimiter;
select tabid into @tabid from ld_tab where name = 'Events';
SELECT fieldid into @fieldid  from ld_field where tabid=@tabid and fieldname='eventstatus';
insert into ld_approvepickfield(tabid,fieldid) select @tabid,@fieldid from dual 
where not EXISTS(select 1 from ld_approvepickfield  where tabid=@tabid and fieldid=@fieldid);
delimiter;
-- 2014-11-05

delete from ld_announcement;
delimiter;

SELECT tabid INTO @tabid FROM ld_tab WHERE NAME = 'Servicecontracts';
SELECT fieldid INTO @fieldid FROM ld_field WHERE fieldname = 'actual_duration' AND tabid = @tabid;
UPDATE ld_tranlabel SET fieldlabel = '实际时间' WHERE relateid = @fieldid AND languagetype = 'zh';
UPDATE ld_tranlabel SET fieldlabel = 'Actual Duration' WHERE relateid = @fieldid AND languagetype = 'en';

SELECT fieldid INTO @fieldid FROM ld_field WHERE fieldname = 'planned_duration' AND tabid = @tabid;
UPDATE ld_tranlabel SET fieldlabel = '计划时间' WHERE relateid = @fieldid AND languagetype = 'zh';
UPDATE ld_tranlabel SET fieldlabel = 'Planned Duration' WHERE relateid = @fieldid AND languagetype = 'en';
delimiter;

SELECT tabsequence INTO @seq FROM ld_tab WHERE NAME = 'Invoice';
SELECT tabid INTO @invoicetabid FROM ld_tab WHERE NAME = 'PurchaseInvoice';
SELECT @seq+1 INTO @seq1;
UPDATE ld_tab SET tabsequence = (@seq1:=@seq1+1) WHERE tabsequence > @seq ORDER BY tabsequence;
UPDATE ld_tab SET tabsequence = @seq+2 WHERE tabsequence = @seq1 AND tabid != @invoicetabid ORDER BY tabsequence;
UPDATE ld_tab SET tabsequence = @seq+1 WHERE tabid = @invoicetabid;
delimiter;

select tabid into @tabid from ld_tab where name='Potentials'; 
select sequence into @seq from ld_field where tabid=@tabid and columnname='campaignid'; 
select block into @block from ld_field where tabid=@tabid and columnname='potentialname'; 
update ld_field set sequence=sequence+1 where tabid=@tabid and block=@block and sequence>@seq; 

select 'LD_potential' into @tablename; 
select 'productcategory' into @columnname; 
select 'productcategory' into @fieldname; 
select '产品类别' into @zh; 
select 'Product Category' into @en; 
select 15 into @uitype; 
select 1 into @displaytype; 
select 'V~O' into @typeofdata; 

select max(fieldid) into @fieldid from ld_field; 
insert into ld_field(tabid,fieldid,columnname,tablename,generatedtype,uitype,fieldname,fieldlabel,readonly,presence,maximumlength,sequence,block,displaytype,typeofdata,quickcreate,info_type) 
select @tabid,@fieldid+1,@columnname,@tablename,1,@uitype,@fieldname,@zh,1,2,100,@seq+1,@block,@displaytype,@typeofdata,3,'BAS' from dual 
where not exists (select 1 from ld_field where tabid = @tabid and columnname = @columnname); 
update ld_field_seq set id = (select max(fieldid) from ld_field); 

select fieldid into @fieldid from ld_field where tabid = @tabid and columnname = @columnname; 
delete from ld_tranlabel where trantable ='LD_field' and tabid=@tabid and relateid=@fieldid; 
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel) 
select 'zh','LD_field',@tabid,@fieldid,@zh; 

insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel) 
select 'en','LD_field',@tabid,@fieldid,@en; 

select 0 into @i;
update ld_field set sequence=(@i:=@i+1) where tabid=@tabid and block=@block order by sequence;

call AddColumn(@tablename,@columnname,'varchar','200',NULL); 
delimiter;

select tabid into @tabid from ld_tab where name='Potentials'; 
select sequence into @seq from ld_field where tabid=@tabid and columnname='productcategory'; 
select block into @block from ld_field where tabid=@tabid and columnname='potentialname'; 
update ld_field set sequence=sequence+1 where tabid=@tabid and block=@block and sequence>@seq; 

select 'LD_potential' into @tablename; 
select 'Competitors' into @columnname; 
select 'Competitors' into @fieldname; 
select '竞争对手' into @zh; 
select 'Competitors' into @en; 
select 1 into @uitype; 
select 1 into @displaytype; 
select 'V~O' into @typeofdata; 

select max(fieldid) into @fieldid from ld_field; 
insert into ld_field(tabid,fieldid,columnname,tablename,generatedtype,uitype,fieldname,fieldlabel,readonly,presence,maximumlength,sequence,block,displaytype,typeofdata,quickcreate,info_type) 
select @tabid,@fieldid+1,@columnname,@tablename,1,@uitype,@fieldname,@zh,1,2,100,@seq+1,@block,@displaytype,@typeofdata,3,'BAS' from dual 
where not exists (select 1 from ld_field where tabid = @tabid and columnname = @columnname); 
update ld_field_seq set id = (select max(fieldid) from ld_field); 

select fieldid into @fieldid from ld_field where tabid = @tabid and columnname = @columnname; 
delete from ld_tranlabel where trantable ='LD_field' and tabid=@tabid and relateid=@fieldid; 
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel) 
select 'zh','LD_field',@tabid,@fieldid,@zh; 

insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel) 
select 'en','LD_field',@tabid,@fieldid,@en; 

select 0 into @i;
update ld_field set sequence=(@i:=@i+1) where tabid=@tabid and block=@block order by sequence;

call AddColumn(@tablename,@columnname,'varchar','200',NULL); 
delimiter;

call fieldprofile('Potentials');
delimiter;
call getallprofile('Potentials');
delimiter;

insert into ld_systems_deploy(deploy_value,deploy_type,description,setype)
select 0,54,'新增保存后是否立即创建回款预测','' from dual where not exists
(select 1 from ld_systems_deploy where deploy_type=54);
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'zh','Whethercreatereceivablesforecastimmediately','{$Potentials.Potentials}新增保存后是否立即创建回款预测','fixedstr' from dual 
where not EXISTS(select 1 from ld_desk  where languagetype='zh' and labelbol='Whethercreatereceivablesforecastimmediately' and Labeltype='fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'en','Whethercreatereceivablesforecastimmediately','Whether to create receivables forecast immediately after creating {$Potentials.Potentials}','fixedstr' from dual 
where not EXISTS(select 1 from ld_desk  where languagetype='en' and labelbol='Whethercreatereceivablesforecastimmediately' and Labeltype='fixedstr');
delimiter;

CREATE TABLE IF NOT EXISTS `ld_receivablesforecast` (
  `receivablesforecastid` int(11) NOT NULL auto_increment,
  `potentialsid` int(11) default NULL,
  `amount` decimal(25,2) default NULL,
  `total` decimal(25,2) default NULL,
  `periodtime` int(1) default NULL,
  `receivablesforecastdate` date default NULL,
  `smcreatorid` int(11) default NULL,
  `modifiedby` int(11) default NULL,
  `modifiedtime` datetime default NULL,
  `createdtime` datetime default NULL,
  PRIMARY KEY  (`receivablesforecastid`)
) ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=utf8;
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'zh','Createreceivablesforecast','创建回款预测','fixedstr' from dual 
where not EXISTS(select 1 from ld_desk  where languagetype='zh' and labelbol='Createreceivablesforecast' and Labeltype='fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'en','Createreceivablesforecast','Create receivables forecast','fixedstr' from dual 
where not EXISTS(select 1 from ld_desk  where languagetype='en' and labelbol='Createreceivablesforecast' and Labeltype='fixedstr');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'zh','EDITreceivablesforecast','编辑回款预测','fixedstr' from dual 
where not EXISTS(select 1 from ld_desk  where languagetype='zh' and labelbol='EDITreceivablesforecast' and Labeltype='fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'en','EDITreceivablesforecast','Edit receivables forecast','fixedstr' from dual 
where not EXISTS(select 1 from ld_desk  where languagetype='en' and labelbol='EDITreceivablesforecast' and Labeltype='fixedstr');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'zh','TotalAmount','总金额','fixedstr' from dual 
where not EXISTS(select 1 from ld_desk  where languagetype='zh' and labelbol='TotalAmount' and Labeltype='fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'en','TotalAmount','Total Amount','fixedstr' from dual 
where not EXISTS(select 1 from ld_desk  where languagetype='en' and labelbol='TotalAmount' and Labeltype='fixedstr');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'zh','PredictableAmount','	预测余额','fixedstr' from dual 
where not EXISTS(select 1 from ld_desk  where languagetype='zh' and labelbol='PredictableAmount' and Labeltype='fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'en','PredictableAmount','Predictable Amount','fixedstr' from dual 
where not EXISTS(select 1 from ld_desk  where languagetype='en' and labelbol='PredictableAmount' and Labeltype='fixedstr');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'zh','ExpectedAmount','预计回款金额','fixedstr' from dual 
where not EXISTS(select 1 from ld_desk  where languagetype='zh' and labelbol='ExpectedAmount' and Labeltype='fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'en','ExpectedAmount','Expected Amount','fixedstr' from dual 
where not EXISTS(select 1 from ld_desk  where languagetype='en' and labelbol='ExpectedAmount' and Labeltype='fixedstr');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'zh','ExpectedDate','预计回款日期','fixedstr' from dual 
where not EXISTS(select 1 from ld_desk  where languagetype='zh' and labelbol='ExpectedDate' and Labeltype='fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'en','ExpectedDate','Expected Date','fixedstr' from dual 
where not EXISTS(select 1 from ld_desk  where languagetype='en' and labelbol='ExpectedDate' and Labeltype='fixedstr');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'zh','Thepotentialhasbeencreatedreceivablesforecast','该销售机会已创建回款预测或金额为0','jspop' from dual 
where not EXISTS(select 1 from ld_desk  where languagetype='zh' and labelbol='Thepotentialhasbeencreatedreceivablesforecast' and Labeltype='jspop');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'en','Thepotentialhasbeencreatedreceivablesforecast','The potential has been created receivables forecast or the amount of 0','jspop' from dual 
where not EXISTS(select 1 from ld_desk  where languagetype='en' and labelbol='Thepotentialhasbeencreatedreceivablesforecast' and Labeltype='jspop');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'zh','Thepotentialhasbeencreatedreceivablesforecast2','总金额已经等于回款预测金额！','jspop' from dual 
where not EXISTS(select 1 from ld_desk  where languagetype='zh' and labelbol='Thepotentialhasbeencreatedreceivablesforecast2' and Labeltype='jspop');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'en','Thepotentialhasbeencreatedreceivablesforecast2','The potential has been created receivables forecast','jspop' from dual 
where not EXISTS(select 1 from ld_desk  where languagetype='en' and labelbol='Thepotentialhasbeencreatedreceivablesforecast2' and Labeltype='jspop');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'zh','Thepotentialhasbeencreatedreceivablesforecast3','总金额已等于回款预测金额，是否继续？','jspop' from dual 
where not EXISTS(select 1 from ld_desk  where languagetype='zh' and labelbol='Thepotentialhasbeencreatedreceivablesforecast3' and Labeltype='jspop');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'en','Thepotentialhasbeencreatedreceivablesforecast3','The total  Receivables Forecast has been equal to the Potentials amount of unplanned, whether to continue?','jspop' from dual 
where not EXISTS(select 1 from ld_desk  where languagetype='en' and labelbol='Thepotentialhasbeencreatedreceivablesforecast3' and Labeltype='jspop');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'zh','Thepotentialhasbeencreatedreceivablesforecast4','该销售机会已大于回款预测金额，是否继续？','jspop' from dual 
where not EXISTS(select 1 from ld_desk  where languagetype='zh' and labelbol='Thepotentialhasbeencreatedreceivablesforecast4' and Labeltype='jspop');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'en','Thepotentialhasbeencreatedreceivablesforecast4','The total Receivables Forecast has been greater than the Potentials amount of unplanned, whether to continue?','jspop' from dual 
where not EXISTS(select 1 from ld_desk  where languagetype='en' and labelbol='Thepotentialhasbeencreatedreceivablesforecast4' and Labeltype='jspop');
delimiter;


insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'zh','Createtime1','创建时间','fixedstr' from dual 
where not EXISTS(select 1 from ld_desk  where languagetype='zh' and labelbol='Createtime1' and Labeltype='fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'en','Createtime1','Create time','fixedstr' from dual 
where not EXISTS(select 1 from ld_desk  where languagetype='en' and labelbol='Createtime1' and Labeltype='fixedstr');
delimiter;

select tabid into @tabid from ld_tab where `name` = 'Potentials';
select id into @relation_id from ld_relatedlists_seq;
insert into LD_relatedlists(relation_id,tabid,related_tabid,name,sequence,label,presence,actions)
select @relation_id+1,@tabid,0,'get_receivablesforecast',1,'PaymentPlan',0,'add' from dual 
where not EXISTS(select 1 from LD_relatedlists  where related_tabid = 0 and tabid = @tabid); 
update ld_relatedlists_seq set id = (select max(relation_id) from ld_relatedlists);
delimiter;

/*添加报表*/
SELECT usereportid into @id from LD_usereport where name='SalesReport';
SELECT tabid into @tid from LD_tab where name='Potentials';
insert into LD_usereport(usereportid,name,reportlabel,tabids,basicfilter,advfilter,Setcolumns,Parent_id,sequence,reporttype,pagewidthpercent) 
select '','Salesforecastandanalysistable','销售预测分析表',@tid,1,1,1,@id,4,5,110 
from dual where not exists(select usereportid from LD_usereport where name='Salesforecastandanalysistable');
delimiter;


/*添加搜索条件*/
select usereportid into @id from LD_usereport where name='Salesforecastandanalysistable';
insert into LD_usereportbasic(id,Usereportid,columns,Defaultvalue,Sequence) 
select '',@id,'LD_potential:closingdate:closingdate:Potentials_closingdate:D','thisstartmonth~thisendmonth',3  
from dual where not exists(select usereportid from LD_usereportbasic where Usereportid=@id and Sequence=3);

insert into LD_usereportbasic(id,Usereportid,columns,Defaultvalue,Sequence) 
select '',@id,'F4:accountname:accountname:Accounts_accountname:I','',4  
from dual where not exists(select usereportid from LD_usereportbasic where Usereportid=@id and Sequence=4);

/*表名翻译*/
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'zh','Salesforecastandanalysistable','销售预测分析表','fixedstr' 
from dual where not EXISTS(select 1 from ld_desk where languagetype='zh' and labelbol='Salesforecastandanalysistable' and Labeltype='fixedstr');

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'en','Salesforecastandanalysistable','Sales forecast and analysis','fixedstr' 
from dual where not EXISTS(select 1 from ld_desk  where languagetype='en' and labelbol='Salesforecastandanalysistable' and Labeltype='fixedstr');

/**添加显示列名称**/
select usereportid into @id from LD_usereport where name='Salesforecastandanalysistable';

insert into LD_UseReportcolumns(id,Usereportid,columns,Sequence,columnshow,realcolumns,realencolumns) 
select '', @id, 'LD_potential:last_name:last_name:Potentials_last_name:V', 1, 1, 'LD_potential:last_name:last_name:Potentials_销售负责人:V','LD_potential:last_name:last_name:Potentials_Assigned To:V'   
from dual where not exists(select 1 from LD_UseReportcolumns where Usereportid=@id and realcolumns='LD_potential:last_name:last_name:Potentials_销售负责人:V');

insert into LD_UseReportcolumns(id,Usereportid,columns,Sequence,columnshow,realcolumns,realencolumns) 
select '', @id, 'LD_account:accountname:accountname:Accounts_accountname:V', 2, 1, 'LD_account:accountname:accountname:Accounts_客户名称:V','LD_account:accountname:accountname:Accounts_Account Name:V'   
from dual where not exists(select 1 from LD_UseReportcolumns where Usereportid=@id and realcolumns='LD_account:accountname:accountname:Accounts_客户名称:V');

insert into LD_UseReportcolumns(id,Usereportid,columns,Sequence,columnshow,realcolumns,realencolumns) 
select '', @id, 'LD_account:account_type:account_type:Accounts_account_type:V', 3, 1, 'LD_account:account_type:account_type:Accounts_客户类型:V','LD_account:account_type:account_type:Accounts_Account Type:V'   
from dual where not exists(select 1 from LD_UseReportcolumns where Usereportid=@id and realcolumns='LD_account:account_type:account_type:Accounts_客户类型:V');

insert into LD_UseReportcolumns(id,Usereportid,columns,Sequence,columnshow,realcolumns,realencolumns) 
select '', @id, 'LD_potential:Potentials_smcreatorid:Potentials_smcreatorid:Potentials_Potentials_smcreatorid:V', 4, 1, 'LD_potential:Potentials_smcreatorid:Potentials_smcreatorid:Potentials_创建人:V','LD_potential:Potentials_smcreatorid:Potentials_smcreatorid:Potentials_smcreator:V'   
from dual where not exists(select 1 from LD_UseReportcolumns where Usereportid=@id and realcolumns='LD_potential:Potentials_smcreatorid:Potentials_smcreatorid:Potentials_创建人:V');

insert into LD_UseReportcolumns(id,Usereportid,columns,Sequence,columnshow,realcolumns,realencolumns) 
select '', @id, 'LD_potential:potentialname:potentialname:potentials_potentialname:V', 5, 1, 'LD_potential:potentialname:potentialname:Potentials_销售机会:V','LD_potential:potentialname:potentialname:Potentials_Potentials Name:V'   
from dual where not exists(select 1 from LD_UseReportcolumns where Usereportid=@id and realcolumns='LD_potential:potentialname:potentialname:Potentials_销售机会:V');


insert into LD_UseReportcolumns(id,Usereportid,columns,Sequence,columnshow,realcolumns,realencolumns) 
select '', @id, 'LD_potential:productcategory:productcategory:Potentials_productcategory:V', 6, 1, 'LD_potential:productcategory:productcategory:Potentials_产品类别:V','LD_potential:productcategory:productcategory:Potentials_category:V'   
from dual where not exists(select 1 from LD_UseReportcolumns where Usereportid=@id and realcolumns='LD_potential:productcategory:productcategory:Potentials_产品类别:V');

insert into LD_UseReportcolumns(id,Usereportid,columns,Sequence,columnshow,realcolumns,realencolumns) 
select '', @id, 'LD_potential:sales_stage:sales_stage:potentials_sales_stage:V', 7, 1, 'LD_potential:sales_stage:sales_stage:Potentials_销售阶段:V','LD_potential:sales_stage:sales_stage:Potentials_Potentials stage:V'   
from dual where not exists(select 1 from LD_UseReportcolumns where Usereportid=@id and realcolumns='LD_potential:sales_stage:sales_stage:Potentials_销售阶段:V');

insert into LD_UseReportcolumns(id,Usereportid,columns,Sequence,columnshow,realcolumns,realencolumns) 
select '', @id, 'LD_salesorder:total:total:SalesOrder_total:NN', 8, 1, 'LD_salesorder:total:total:SalesOrder_合同金额:NN','LD_potential:total:total:SalesOrder_Order total:NN'   
from dual where not exists(select 1 from LD_UseReportcolumns where Usereportid=@id and realcolumns='LD_salesorder:total:total:SalesOrder_合同金额:NN');

insert into LD_UseReportcolumns(id,Usereportid,columns,Sequence,columnshow,realcolumns,realencolumns) 
select '', @id, 'LD_potential:closingdate:closingdate:potentials_closingdate:D', 9, 1, 'LD_potential:closingdate:closingdate:Potentials_签约日期:D','LD_potential:closingdate:closingdate:Potentials_Signing Date:D'   
from dual where not exists(select 1 from LD_UseReportcolumns where Usereportid=@id and realcolumns='LD_potential:closingdate:closingdate:Potentials_签约日期:D');

insert into LD_UseReportcolumns(id,Usereportid,columns,Sequence,columnshow,realcolumns,realencolumns) 
select '', @id, 'LD_potential:total:total:Potentials_total:NN', 10, 1, 'LD_potential:total:total:Potentials_收款金额:NN','LD_potential:reamount:reamount:Potentials_Collection Date:NN'   
from dual where not exists(select 1 from LD_UseReportcolumns where Usereportid=@id and realcolumns='LD_potential:total:total:Potentials_收款金额:NN');

insert into LD_UseReportcolumns(id,Usereportid,columns,Sequence,columnshow,realcolumns,realencolumns) 
select '', @id, 'LD_potential:receivablesforecastdate:receivablesforecastdate:potentials_receivablesforecastdate:D', 11, 1, 'LD_potential:receivablesforecastdate:receivablesforecastdate:Potentials_收款日期:D','LD_potential:receivablesforecastdate:closingdate:Potentials_Collection Date:D'   
from dual where not exists(select 1 from LD_UseReportcolumns where Usereportid=@id and realcolumns='LD_potential:receivablesforecastdate:receivablesforecastdate:Potentials_收款日期:D');

insert into LD_UseReportcolumns(id,Usereportid,columns,Sequence,columnshow,realcolumns,realencolumns) 
select '', @id, 'LD_salesorder:retotal:retotal:Potentials_retotal:NN', 12, 1, 'LD_salesorder:retotal:retotal:Potentials_合同金额:NN','LD_potential:total:total:Potentials_retotal total:NN'   
from dual where not exists(select 1 from LD_UseReportcolumns where Usereportid=@id and realcolumns='LD_salesorder:retotal:retotal:Potentials_合同金额:NN');

insert into LD_UseReportcolumns(id,Usereportid,columns,Sequence,columnshow,realcolumns,realencolumns) 
select '', @id, 'LD_potential:plandate:plandate:Potentials_plandate:D', 13, 1, 'LD_potential:plandate:plandate:Potentials_签约日期:D','LD_potential:plandate:plandate:Potentials_Collection Date:D'   
from dual where not exists(select 1 from LD_UseReportcolumns where Usereportid=@id and realcolumns='LD_potential:plandate:plandate:Potentials_签约日期:D');

insert into LD_UseReportcolumns(id,Usereportid,columns,Sequence,columnshow,realcolumns,realencolumns) 
select '', @id, 'LD_potential:amount:amount:Potentials_amount:NN', 14, 1, 'LD_potential:amount:amount:Potentials_收款金额:NN','LD_potential:amount:amount:Potentials_Collection Amount:NN'   
from dual where not exists(select 1 from LD_UseReportcolumns where Usereportid=@id and realcolumns='LD_potential:amount:amount:Potentials_收款金额:NN');

insert into LD_UseReportcolumns(id,Usereportid,columns,Sequence,columnshow,realcolumns,realencolumns) 
select '', @id, 'LD_potential:actualdate:actualdate:Potentials_actualdate:D', 15, 1, 'LD_potential:actualdate:actualdate:Potentials_收款日期:D','LD_potential:actualdate:actualdate:Potentials_Collection Date:D'   
from dual where not exists(select 1 from LD_UseReportcolumns where Usereportid=@id and realcolumns='LD_potential:actualdate:actualdate:Potentials_收款日期:D');

insert into LD_UseReportcolumns(id,Usereportid,columns,Sequence,columnshow,realcolumns,realencolumns) 
select '', @id, 'LD_potential:SWOT:SWOT:Potentials_SWOT:V', 16, 1, 'LD_potential:SWOT:SWOT:Potentials_SWOT分析:V','LD_potential:SWOT:SWOT:Potentials_SWOT:V'   
from dual where not exists(select 1 from LD_UseReportcolumns where Usereportid=@id and realcolumns='LD_potential:SWOT:SWOT:Potentials_SWOT分析:V');

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'zh','AssignedTo2','销售负责人','fixedstr' from dual 
where not EXISTS(select 1 from ld_desk  where languagetype='zh' and labelbol='AssignedTo2' and Labeltype='fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'en','AssignedTo2','Assigned To','fixedstr' from dual 
where not EXISTS(select 1 from ld_desk  where languagetype='en' and labelbol='AssignedTo2' and Labeltype='fixedstr');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'zh','AccountName','客户名称','fixedstr' from dual 
where not EXISTS(select 1 from ld_desk  where languagetype='zh' and labelbol='AccountName' and Labeltype='fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'en','AccountName','Account Name','fixedstr' from dual 
where not EXISTS(select 1 from ld_desk  where languagetype='en' and labelbol='AccountName' and Labeltype='fixedstr');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'zh','AccountType','客户类型','fixedstr' from dual 
where not EXISTS(select 1 from ld_desk  where languagetype='zh' and labelbol='AccountType' and Labeltype='fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'en','AccountType','Account Type','fixedstr' from dual 
where not EXISTS(select 1 from ld_desk  where languagetype='en' and labelbol='AccountType' and Labeltype='fixedstr');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'zh','ProductCategory','产品类别','fixedstr' from dual 
where not EXISTS(select 1 from ld_desk  where languagetype='zh' and labelbol='ProductCategory' and Labeltype='fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'en','ProductCategory','Product Category','fixedstr' from dual 
where not EXISTS(select 1 from ld_desk  where languagetype='en' and labelbol='ProductCategory' and Labeltype='fixedstr');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'zh','Potentials','销售机会','fixedstr' from dual 
where not EXISTS(select 1 from ld_desk  where languagetype='zh' and labelbol='Potentials' and Labeltype='fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'en','Potentials','Potentials','fixedstr' from dual 
where not EXISTS(select 1 from ld_desk  where languagetype='en' and labelbol='Potentials' and Labeltype='fixedstr');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'zh','sales_stage','销售阶段','fixedstr' from dual 
where not EXISTS(select 1 from ld_desk  where languagetype='zh' and labelbol='sales_stage' and Labeltype='fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'en','sales_stage','sales stage','fixedstr' from dual 
where not EXISTS(select 1 from ld_desk  where languagetype='en' and labelbol='sales_stage' and Labeltype='fixedstr');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'zh','Expect','预算','fixedstr' from dual 
where not EXISTS(select 1 from ld_desk  where languagetype='zh' and labelbol='Expect' and Labeltype='fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'en','Expect','Expect','fixedstr' from dual 
where not EXISTS(select 1 from ld_desk  where languagetype='en' and labelbol='Expect' and Labeltype='fixedstr');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'zh','Actual','实际','fixedstr' from dual 
where not EXISTS(select 1 from ld_desk  where languagetype='zh' and labelbol='Actual' and Labeltype='fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'en','Actual','Actual','fixedstr' from dual 
where not EXISTS(select 1 from ld_desk  where languagetype='en' and labelbol='Actual' and Labeltype='fixedstr');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'zh','SWOTAnalysis','SWOT分析','fixedstr' from dual 
where not EXISTS(select 1 from ld_desk  where languagetype='zh' and labelbol='SWOTAnalysis' and Labeltype='fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'en','SWOTAnalysis','SWOT Analysis','fixedstr' from dual 
where not EXISTS(select 1 from ld_desk  where languagetype='en' and labelbol='SWOTAnalysis' and Labeltype='fixedstr');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'zh','ContractAmount2','合同金额','fixedstr' from dual 
where not EXISTS(select 1 from ld_desk  where languagetype='zh' and labelbol='ContractAmount2' and Labeltype='fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'en','ContractAmount2','Contract Amount','fixedstr' from dual 
where not EXISTS(select 1 from ld_desk  where languagetype='en' and labelbol='ContractAmount2' and Labeltype='fixedstr');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'zh','SigningDate','签约日期','fixedstr' from dual 
where not EXISTS(select 1 from ld_desk  where languagetype='zh' and labelbol='SigningDate' and Labeltype='fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'en','SigningDate','Signing Date','fixedstr' from dual 
where not EXISTS(select 1 from ld_desk  where languagetype='en' and labelbol='SigningDate' and Labeltype='fixedstr');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'zh','CollectionAmount','收款金额','fixedstr' from dual 
where not EXISTS(select 1 from ld_desk  where languagetype='zh' and labelbol='CollectionAmount' and Labeltype='fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'en','CollectionAmount','Collection Amount','fixedstr' from dual 
where not EXISTS(select 1 from ld_desk  where languagetype='en' and labelbol='CollectionAmount' and Labeltype='fixedstr');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'zh','CollectionDate','收款日期','fixedstr' from dual 
where not EXISTS(select 1 from ld_desk  where languagetype='zh' and labelbol='CollectionDate' and Labeltype='fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'en','CollectionDate','Collection Date','fixedstr' from dual 
where not EXISTS(select 1 from ld_desk  where languagetype='en' and labelbol='CollectionDate' and Labeltype='fixedstr');
delimiter;
-- 2014-11-06

update ld_field set defaultvalue='电话' where tabid=13 and columnname='servicetype' and defaultvalue='上门';
update ld_relatedlists set presence=1 where `name`='get_gantt_chart';

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'zh','ASSOCIATIONTOCREATE','关联创建','fixedstr' from dual 
where not EXISTS(select 1 from ld_desk  where languagetype='zh' and labelbol='ASSOCIATIONTOCREATE' and Labeltype='fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'en','ASSOCIATIONTOCREATE','Association to create','fixedstr' from dual 
where not EXISTS(select 1 from ld_desk  where languagetype='en' and labelbol='ASSOCIATIONTOCREATE' and Labeltype='fixedstr');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'zh','ASSOCIATIONTOCREATESET','关联创建设置','fixedstr' from dual 
where not EXISTS(select 1 from ld_desk  where languagetype='zh' and labelbol='ASSOCIATIONTOCREATESET' and Labeltype='fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'en','ASSOCIATIONTOCREATESET','Association to create a set','fixedstr' from dual 
where not EXISTS(select 1 from ld_desk  where languagetype='en' and labelbol='ASSOCIATIONTOCREATESET' and Labeltype='fixedstr');
delimiter;
SELECT tabid into @tabid from ld_tab where name='SalesOrder';
SELECT tabid into @tabid2 from ld_tab where name='Documents';
SELECT sequence  into @sequence from ld_quickactions where tabid=@tabid and related_tabid=@tabid2;
UPDATE ld_quickactions set sequence=sequence+1 where sequence>@sequence and tabid=@tabid;
UPDATE ld_quickactions set sequence=@sequence+1 where related_tabid=-1 and tabid=@tabid;

ALTER TABLE LD_contactrecords MODIFY nextContactDate datetime DEFAULT null;
delimiter;
SELECT tabid into @tabid from ld_tab where name='ContactRecords';
update ld_field set uitype='86',typeofdata='DT~M~time_start' where tabid=@tabid and columnname='nextContactDate';
delimiter;

SELECT tabid INTO @tabid from ld_tab where name='Potentials';
SELECT tabid into @related_tabid from ld_tab where name='Expense';
SELECT max(sequence) INTO @sequence from ld_relatedlists where tabid=@tabid;
SELECT id into @relation_id from ld_relatedlists_seq;
INSERT into ld_relatedlists (relation_id,tabid,related_tabid,name,sequence,label,presence,actions)
SELECT @relation_id+1,@tabid,@related_tabid,'get_expense',@sequence+1,'Expense',0,'add' from dual where not EXISTS
(select 1 from ld_relatedlists  where tabid=@tabid and related_tabid=@related_tabid);
UPDATE ld_relatedlists_seq set id=(SELECT max(relation_id) from ld_relatedlists);
delimiter;

SELECT tabid INTO @tabid from ld_tab where name='Potentials';
SELECT tabid into @tabid3  from ld_tab where name='Invoice';
SELECT tabid into @tabid2  from ld_tab where name='Expense';
SELECT sequence  into @sequence from ld_quickactions where tabid=@tabid and related_tabid=@tabid3;
UPDATE ld_quickactions set sequence=sequence+1 where sequence>@sequence and tabid=@tabid;
insert into ld_quickactions(tabid,related_tabid,sequence,presence)
select @tabid,@tabid2,@sequence+1,0 from dual 
where not EXISTS(select 1 from ld_quickactions  where tabid=@tabid and related_tabid=@tabid2);
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'zh','RECEIVABLESFORECAST','回款预测','fixedstr' from dual 
where not EXISTS(select 1 from ld_desk  where languagetype='zh' and labelbol='RECEIVABLESFORECAST' and Labeltype='fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'en','RECEIVABLESFORECAST','Receivables Forecast','fixedstr' from dual 
where not EXISTS(select 1 from ld_desk  where languagetype='en' and labelbol='RECEIVABLESFORECAST' and Labeltype='fixedstr');
delimiter;

SELECT tabid INTO @id FROM ld_tab WHERE name='Potentials';
UPDATE LD_relatedlists SET label='RECEIVABLESFORECAST' WHERE name='get_receivablesforecast' AND tabid=@id;
delimiter;

select cvid into @cvid from ld_customview where entitytype = 'WareHouseTransfer' and viewname = '未审核';
insert into LD_cvadvfilter_grouping(groupid,cvid,group_condition,condition_expression)
select 1,@cvid,'',0 FROM DUAL
WHERE NOT EXISTS(SELECT 1 FROM LD_cvadvfilter_grouping  WHERE groupid=1 AND cvid=@cvid);
delimiter;

select cvid into @cvid from ld_customview where entitytype = 'WareHouseTransfer' and viewname = '已审核';
insert into LD_cvadvfilter_grouping(groupid,cvid,group_condition,condition_expression)
select 1,@cvid,'',0 FROM DUAL
WHERE NOT EXISTS(SELECT 1 FROM LD_cvadvfilter_grouping  WHERE groupid=1 AND cvid=@cvid);
delimiter;
-- 2014-11-07

select tabid into @tabid from ld_tab  where name='Products';
select fieldid into @relateid from ld_field where tabid= @tabid and columnname='qtyearly';
UPDATE ld_tranlabel set fieldlabel='最低库存' where tabid=@tabid and Relateid=@relateid and trantable='LD_field' and languagetype='zh';
UPDATE ld_tranlabel set fieldlabel='Minimum inventory' where tabid=@tabid and Relateid=@relateid and trantable='LD_field' and languagetype='en';
delimiter;

update ld_desk set fieldlabel='No data found' where labelbol='NOTFOUNDANYRECORD' and Labeltype='fixedstr' and languagetype='en';
update ld_desk set fieldlabel='No data found' where labelbol='No data found!' and Labeltype='fixedstr' and languagetype='jspop';
update ld_desk set fieldlabel='Assigned To ' where labelbol='ASSIGNEDTO' and languagetype='en';

update ld_desk set fieldlabel='Whether to create {$PaymentPlan.PaymentPlan} immediately after creating {$SalesOrder.SalesOrder}' where labelbol='WHETHERIMMCREATEPAYMENTPLAN' and languagetype='en';
update ld_desk set fieldlabel='Whether to create {$SendPayment.SendPayment} immediately after creating {$PurchaseOrder.PurchaseOrder}' where labelbol='WHETHERIMMCREATESENDPAYMENT' and languagetype='en';
update ld_desk set fieldlabel='Page Setting' where labelbol='LBL_PAGE_SET' and languagetype='en';

UPDATE ld_desk set fieldlabel='This week' WHERE labelbol='thisweek' and Labeltype='fixedstr' and languagetype='en';
UPDATE ld_desk set fieldlabel='This month' WHERE labelbol='thismonth' and Labeltype='fixedstr' and languagetype='en';
delimiter;

select usereportid into @id from LD_usereport where name='SIGNINSTATISTICS';
insert into LD_UseReportcolumns(id,Usereportid,columns,Sequence,columnshow,realcolumns,realencolumns) 
select '', @id, 'LD_singin:content:content:OftenUseReport_备注:V', 5, 1, 'LD_singin:content:content:OftenUseReport_备注:V','LD_singin:content:content:OftenUseReport_remark:V'   
from dual where not exists(select 1 from LD_UseReportcolumns where Usereportid=@id and realcolumns like 'LD_singin:content:content:%');

SELECT tabid INTO @id FROM ld_tab WHERE name='Invoice'; 
UPDATE LD_relatedlists SET presence=1 WHERE tabid=@id AND name='get_invoicestatushistory';
delimiter;
-- 2014-11-10

set @tabid=0;
select tabid into @tabid from ld_tab where `name`='CashBill';
update ld_blocks set sequence=sequence+1 where tabid=@tabid;
update ld_blocks set sequence=0 where tabid=@tabid and blocklabel='LBL_Cashbill_INFORMATION';
set @i=0;
update ld_blocks set sequence=(@i:=@i+1) where tabid=@tabid order by sequence;
delimiter;

update ld_settings_field set sequence=1 where blockid=3 and `name`= 'VTLIB_LBL_MODULE_MANAGER';
update ld_settings_field set sequence=2 where blockid=3 and `name`= 'LBL_TABLIST';
update ld_settings_field set sequence=3 where blockid=3 and `name`= 'LBL_PAGE_SET';
update ld_settings_field set sequence=4 where blockid=3 and `name`= 'LBL_SYSTEM_SET';
update ld_settings_field set sequence=5 where blockid=3 and `name`= 'LBL_PICKLIST_EDITOR';
update ld_settings_field set sequence=6 where blockid=3 and `name`= 'LBL_PICKLIST_DEPENDENCY_SETUP';
update ld_settings_field set sequence=7 where blockid=3 and `name`= 'LBL_TEMPLATES';
update ld_settings_field set sequence=8 where blockid=3 and `name`= 'LBL_PRINT_TEMPLATE';
update ld_settings_field set sequence=9 where blockid=3 and `name`= 'THEDOCUMENTTEMPLATE';
update ld_settings_field set sequence=10 where blockid=3 and `name`= 'SMS_templates';
update ld_settings_field set sequence=11 where blockid=3 and `name`= 'EMAILTEMPLATES';
update ld_settings_field set sequence=12 where blockid=3 and `name`= 'LBL_SERVICE_PERFORMANCE_PARAMETERS';

update ld_settings_field set sequence=13 where blockid=3 and `name`= 'LBL_APPROVE';
update ld_settings_field set sequence=14 where blockid=3 and `name`= 'LBL_RELATED_PARAMETERS';
update ld_settings_field set sequence=15 where blockid=3 and `name`= 'LBL_ProductTool_field';
update ld_settings_field set sequence=16 where blockid=3 and `name`= 'LBL_ACCOUNTS_CONTACTS_FIELDS';
update ld_settings_field set sequence=17 where blockid=3 and `name`= 'LBL_RELATED_RELATEDLIST';
update ld_settings_field set sequence=18 where blockid=3 and `name`= 'LBL_MENU_EDITOR';

update ld_settings_field set sequence=1 where blockid=5 and `name`= 'LBL_CURRENCY_SETTINGS';
update ld_settings_field set sequence=2 where blockid=5 and `name`= 'LBL_TAX_SETTINGS';
update ld_settings_field set sequence=3 where blockid=5 and `name`= 'LBL_COMPANY_DETAILS';
update ld_settings_field set sequence=4 where blockid=5 and `name`= 'INVENTORYTERMSANDCONDITIONS';
update ld_settings_field set sequence=5 where blockid=5 and `name`= 'LBL_BACKUP_SET';
update ld_settings_field set sequence=6 where blockid=5 and `name`= 'LBL_SMS_SETTINGS';
update ld_settings_field set sequence=7 where blockid=5 and `name`= 'LBL_MAIL_SERVER_SETTINGS';
update ld_settings_field set sequence=8 where blockid=5 and `name`= 'LBL_SECURITYCODE_SET';
update ld_settings_field set sequence=9 where blockid=5 and `name`= 'LBL_AUTOMATICREMINDS_SET';
update ld_settings_field set sequence=10 where blockid=5 and `name`= 'LBL_REMIND_SET';
update ld_settings_field set sequence=11 where blockid=5 and `name`= 'LBL_ACCOUNT_SET';
update ld_settings_field set sequence=12 where blockid=5 and `name`= 'LBL_CUSTOMIZE_MODENT_NUMBER';
update ld_settings_field set sequence=13 where blockid=5 and `name`= 'LBL_WASEHOUSE';
update ld_settings_field set sequence=14 where blockid=5 and `name`= 'LBL_PHONESTEWARD_SET';
update ld_settings_field set sequence=15 where blockid=5 and `name`= 'LBL_DATAINTERFACE_SETTING';

update ld_field set typeofdata='E~M' where tabid=29 and columnname='email1';
UPDATE ld_desk set fieldlabel='This Week' WHERE labelbol='thisweek' and Labeltype='fixedstr' and languagetype='en';
UPDATE ld_desk set fieldlabel='This Month' WHERE labelbol='thismonth' and Labeltype='fixedstr' and languagetype='en';
UPDATE ld_desk set fieldlabel='This Year' WHERE labelbol='THISYEAR' and Labeltype='fixedstr' and languagetype='en';
delimiter;
SELECT tabid into @tabid from ld_tab where name='PaymentPlan';
SELECT fieldid into @relateid from ld_field where tabid=@tabid and columnname='plandate';
UPDATE ld_tranlabel set fieldlabel='Payment Plan Date' where tabid=@tabid and Relateid=@relateid and trantable='LD_field' and languagetype='en';
delimiter;

SELECT tabid into @tabid from ld_tab where name='SendPayment';
SELECT fieldid into @relateid from ld_field where tabid=@tabid and columnname='plandate';
UPDATE ld_tranlabel set fieldlabel='Send Payment Plan Date' where tabid=@tabid and Relateid=@relateid and trantable='LD_field' and languagetype='en';
delimiter;

update ld_desk set Fieldlabel='Unplanned Amount' where labelbol='UNPLANAMOUNT' and languagetype='en' and Labeltype = 'fixedstr';
delimiter;
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'zh','SALESORDERAMOUNT','合同订单金额','fixedstr' from dual 
where not EXISTS(select 1 from ld_desk  where languagetype='zh' and labelbol='SALESORDERAMOUNT' and Labeltype='fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'en','SALESORDERAMOUNT','Sales Order Amount','fixedstr' from dual 
where not EXISTS(select 1 from ld_desk  where languagetype='en' and labelbol='SALESORDERAMOUNT' and Labeltype='fixedstr');
delimiter;
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'zh','PAYMENTPLANASSIGNED','回款计划负责人','fixedstr' from dual 
where not EXISTS(select 1 from ld_desk  where languagetype='zh' and labelbol='PAYMENTPLANASSIGNED' and Labeltype='fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'en','PAYMENTPLANASSIGNED','Payment Plan Assigned To','fixedstr' from dual 
where not EXISTS(select 1 from ld_desk  where languagetype='en' and labelbol='PAYMENTPLANASSIGNED' and Labeltype='fixedstr');
delimiter;
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'zh','PAYMENTPLANDATE','计划回款日期','fixedstr' from dual 
where not EXISTS(select 1 from ld_desk  where languagetype='zh' and labelbol='PAYMENTPLANDATE' and Labeltype='fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'en','PAYMENTPLANDATE','Payment Plan Date','fixedstr' from dual 
where not EXISTS(select 1 from ld_desk  where languagetype='en' and labelbol='PAYMENTPLANDATE' and Labeltype='fixedstr');
delimiter;

CREATE TABLE IF NOT EXISTS `ld_cvcolumnlistsort` (
  `cvid` int(19) DEFAULT NULL COMMENT '分类ID',
  `columnname` varchar(255) DEFAULT NULL COMMENT '排序字段',
  `sorttype` varchar(25) DEFAULT NULL COMMENT '排序方式(asc、desc)'
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
delimiter;

DROP PROCEDURE IF EXISTS Select_Customview_Insertinto_tabwithproductview;
delimiter ||
CREATE PROCEDURE Select_Customview_Insertinto_tabwithproductview()
BEGIN  
declare done int default 0; 
declare p_tabid int default 0; 
declare p_cvid int default 0; 
declare p_name varchar(100);
declare p_cnt int default 0; 
declare p_columnindex int DEFAULT 0; 
declare p_columnname varchar(100); 
declare isCount int default 0; 
declare cvcolumnCount int default 0; 

declare cur1 CURSOR FOR select tabid,cvid,`name` from ld_tab inner join ld_customview on ld_tab.`name` = ld_customview.entitytype where ld_tab.`name` in ('Checks','PurchaseCashBack','PurchaseBack','SalesBack','CashBack','Quotes'); 
declare continue handler for not found SET done =1; 

open cur1; 
fetch cur1 into p_tabid,p_cvid,p_name;
loop2: while done<>1 do 
	select count(1) into p_cnt from ld_tabwithproductview where tabid = p_tabid and cvid = p_cvid; 
	if p_cnt = 0 then 
		set isCount=0; 
		set cvcolumnCount = (select count(1) from ld_cvcolumnlist where cvid = p_cvid); 
		while isCount < cvcolumnCount 
		do 
			set @psql = CONCAT('select columnindex,columnname into @p_columnindex,@p_columnname from ld_cvcolumnlist where cvid = ',p_cvid,' order by columnindex asc limit ',isCount,',1;'); 
			prepare stmt from @psql; 
			execute stmt; 
			deallocate prepare stmt;
			set @psql = CONCAT('insert into ld_tabwithproductview(tabid,columns,sequence,cvid) values (',p_tabid,',"',@p_columnname,'",',@p_columnindex,',',p_cvid,');'); 
			prepare stmt from @psql; 
			execute stmt; 
			deallocate prepare stmt;
			set isCount = isCount + 1; 
		end while; 
	end if;
	if(p_name = 'SalesBack')
	then
		update ld_tabwithproductview set `columns` = REPLACE(`columns`,'LD_crmentity','LD_sashback') where cvid = p_cvid;
	elseif(p_name = 'CashBack')
	THEN
		update ld_tabwithproductview set `columns` = REPLACE(`columns`,'LD_crmentity','LD_cashback') where cvid = p_cvid;
	elseif(p_name = 'Checks')
	THEN
		update ld_tabwithproductview set `columns` = REPLACE(`columns`,'LD_crmentity','LD_checks') where cvid = p_cvid;
	elseif(p_name = 'PurchaseBack')
	THEN
		update ld_tabwithproductview set `columns` = REPLACE(`columns`,'LD_crmentity','LD_purchaseback') where cvid = p_cvid;
	elseif(p_name = 'PurchaseCashBack')
	THEN
		update ld_tabwithproductview set `columns` = REPLACE(`columns`,'LD_crmentity','LD_purchasecashback') where cvid = p_cvid;
	end if;

fetch cur1 into p_tabid,p_cvid,p_name;
end while loop2; 
close cur1; 
END ||
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','SORTORDERSETTING','排序方式设置','fixedstr' FROM DUAL
WHERE NOT EXISTS(SELECT 1 FROM ld_desk  WHERE languagetype='zh' AND labelbol='SORTORDERSETTING' AND Labeltype='fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','SORTORDERSETTING','Sort order settings','fixedstr' FROM DUAL
WHERE NOT EXISTS(SELECT 1 FROM ld_desk  WHERE languagetype='en' AND labelbol='SORTORDERSETTING' AND Labeltype='fixedstr');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','ASCENDINGORDER','升序','fixedstr' FROM DUAL
WHERE NOT EXISTS(SELECT 1 FROM ld_desk  WHERE languagetype='zh' AND labelbol='ASCENDINGORDER' AND Labeltype='fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','ASCENDINGORDER','Ascending Order','fixedstr' FROM DUAL
WHERE NOT EXISTS(SELECT 1 FROM ld_desk  WHERE languagetype='en' AND labelbol='ASCENDINGORDER' AND Labeltype='fixedstr');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','DESCENDINGORDER','降序','fixedstr' FROM DUAL
WHERE NOT EXISTS(SELECT 1 FROM ld_desk  WHERE languagetype='zh' AND labelbol='DESCENDINGORDER' AND Labeltype='fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','DESCENDINGORDER','Descending Order','fixedstr' FROM DUAL
WHERE NOT EXISTS(SELECT 1 FROM ld_desk  WHERE languagetype='en' AND labelbol='DESCENDINGORDER' AND Labeltype='fixedstr');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','DISPLAYCOLUMNSETTINGNEEDTOSELECTATLEAST','显示列设置需要至少选择一个必录项字段','jspop' FROM DUAL
WHERE NOT EXISTS(SELECT 1 FROM ld_desk  WHERE languagetype='zh' AND labelbol='DISPLAYCOLUMNSETTINGNEEDTOSELECTATLEAST' AND Labeltype='jspop');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','DISPLAYCOLUMNSETTINGNEEDTOSELECTATLEAST','Display column settings need to select at least one required field','jspop' FROM DUAL
WHERE NOT EXISTS(SELECT 1 FROM ld_desk  WHERE languagetype='en' AND labelbol='DISPLAYCOLUMNSETTINGNEEDTOSELECTATLEAST' AND Labeltype='jspop');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','SORTORDERSETTINGNEEDTOSELECTATLEASTONEFIELD','排序方式设置需要至少选择一个字段','jspop' FROM DUAL
WHERE NOT EXISTS(SELECT 1 FROM ld_desk  WHERE languagetype='zh' AND labelbol='SORTORDERSETTINGNEEDTOSELECTATLEASTONEFIELD' AND Labeltype='jspop');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','SORTORDERSETTINGNEEDTOSELECTATLEASTONEFIELD','Sort order settings need to select at least one field','jspop' FROM DUAL
WHERE NOT EXISTS(SELECT 1 FROM ld_desk  WHERE languagetype='en' AND labelbol='SORTORDERSETTINGNEEDTOSELECTATLEASTONEFIELD' AND Labeltype='jspop');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','SORTFIELDCANNOTBEDUPLICATED','排序字段不能重复','jspop' FROM DUAL
WHERE NOT EXISTS(SELECT 1 FROM ld_desk  WHERE languagetype='zh' AND labelbol='SORTFIELDCANNOTBEDUPLICATED' AND Labeltype='jspop');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','SORTFIELDCANNOTBEDUPLICATED','Sort field can not be duplicated','jspop' FROM DUAL
WHERE NOT EXISTS(SELECT 1 FROM ld_desk  WHERE languagetype='en' AND labelbol='SORTFIELDCANNOTBEDUPLICATED' AND Labeltype='jspop');
delimiter;

select tabid into @tabid from ld_tab where `name` = 'Accounts'; 
insert into ld_field(tabid,fieldid,columnname,tablename,uitype,fieldname,fieldlabel,block,displaytype,presence,typeofdata,readonly)
select @tabid,(select max(fieldid) from ld_field)+1,'publicaccount','LD_account',1,'publicaccount','公海',(select blockid from ld_blocks where tabid = @tabid and blocklabel = 'LBL_ACCOUNT_INFORMATION'),3,0,'V~O',1 
from dual where not exists(select * from ld_field where tabid = @tabid and columnname = 'publicaccount');
update ld_field_seq set id = (select max(fieldid) from ld_field);
delimiter;

select tabid into @tabid from ld_tab where `name` = 'Accounts';
select fieldid into @fieldid from ld_field where tabid = @tabid and fieldname = 'publicaccount';
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'zh','LD_field',@tabid,@fieldid,'公海' 
from dual where not EXISTS(select 1 from ld_tranlabel  where languagetype = 'zh' 
and trantable ='LD_field' and tabid = @tabid and relateid=@fieldid);
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'en','LD_field',@tabid,@fieldid,'Public Accounts' 
from dual where not EXISTS(select 1 from ld_tranlabel  where languagetype = 'en' 
and trantable ='LD_field' and tabid = @tabid and relateid=@fieldid);

select tabid into @tabid from ld_tab where `name` = 'Vendors';
update ld_field set issmownerid = 1 where tabid = @tabid and columnname = 'smcreatorid';
delimiter;

select tabid into @tabid from ld_tab where `name` = 'Vendors';
select max(fieldid) into @fieldid from ld_field;
select blockid into @blockid from ld_blocks where tabid = @tabid and blocklabel = 'LBL_VENDOR_INFORMATION';
insert into ld_field(tabid,fieldid,columnname,tablename,uitype,fieldname,fieldlabel,block,displaytype,presence,typeofdata,issmownerid,readonly)
select @tabid,@fieldid+1,'smownerid','LD_vendor',53,'assigned_user_id','负责人',@blockid,1,0,'V~M',1,0 from dual where not exists
(select * from ld_field where tabid = @tabid and columnname = 'smownerid');
delimiter;

select tabid into @tabid from ld_tab where `name` = 'Vendors';
select fieldid into @fieldid from ld_field where tabid = @tabid and columnname = 'smownerid';
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'zh','LD_field',@tabid,@fieldid,'采购负责人'
from dual where not EXISTS(select 1 from ld_tranlabel  where languagetype = 'zh'
and trantable ='LD_field' and tabid = @tabid and relateid=@fieldid);
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'en','LD_field',@tabid,@fieldid,'Assigned To'
from dual where not EXISTS(select 1 from ld_tranlabel  where languagetype = 'en'
and trantable ='LD_field' and tabid = @tabid and relateid=@fieldid);
delimiter;

select max(sequence) into @sequence from ld_customview where entitytype = 'Vendors';
insert into ld_customview(cvid,viewname,setdefault,entitytype,status,userid,sequence,pagewidthpercent)
select (select max(id)+1 from ld_customview_seq),'供应商及联系人',0,'Vendors',3,1,@sequence+1,100
from dual where not EXISTS(select 1 from ld_customview  where viewname = '供应商及联系人' and entitytype ='Vendors');
update ld_customview_seq set id = (select max(cvid)+1 from ld_customview);
delimiter;

select cvid into @cvid from ld_customview where entitytype = 'Vendors' and viewname = '供应商及联系人';
delete from ld_cvcolumnlist where cvid =  @cvid;
delete from ld_cvcolumnlistsort where cvid = @cvid;

insert into ld_cvcolumnlistsort(cvid,columnname,sorttype)
select @cvid,'LD_vendor:createdtime:createdtime:Vendors_DT~O:fieldlabel','desc';

insert into ld_cvcolumnlist(cvid,columnindex,columnname)
select @cvid,0,'LD_vendor:vendorname:vendorname:Vendors_fieldlabel:V';

insert into ld_cvcolumnlist(cvid,columnindex,columnname)
select @cvid,1,'LD_vendor:bill_city:bill_city:Vendors_fieldlabel:V';

insert into ld_cvcolumnlist(cvid,columnindex,columnname)
select @cvid,2,'LD_vendor:glacct:glacct:Vendors_fieldlabel:V';

insert into ld_cvcolumnlist(cvid,columnindex,columnname)
select @cvid,3,'LD_vendor:phone:phone:Vendors_fieldlabel:V';

insert into ld_cvcolumnlist(cvid,columnindex,columnname)
select @cvid,4,'LD_vendor:createdtime:createdtime:Vendors_fieldlabel:D';

insert into ld_cvcolumnlist(cvid,columnindex,columnname)
select @cvid,5,'LD_vendor:smownerid:assigned_user_id:Vendors_fieldlabel:V';

insert into ld_cvcolumnlist(cvid,columnindex,columnname)
select @cvid,6,'LD_vendorcontacts:lastname:lastname:VendorContact_fieldlabel:V';

insert into ld_cvcolumnlist(cvid,columnindex,columnname)
select @cvid,7,'LD_vendorcontacts:salutation:salutationtype:VendorContact_fieldlabel:V';
delimiter;

select max(sequence) into @sequence from ld_customview where entitytype = 'Accounts';
insert into ld_customview(cvid,viewname,setdefault,entitytype,status,userid,sequence,pagewidthpercent)
select (select max(id)+1 from ld_customview_seq),'客户及联系人',0,'Accounts',3,1,@sequence+1,100
from dual where not EXISTS(select 1 from ld_customview  where viewname = '客户及联系人' and entitytype ='Accounts');
update ld_customview_seq set id = (select max(cvid)+1 from ld_customview);
delimiter;
select cvid into @cvid from ld_customview where entitytype = 'Accounts' and viewname = '客户及联系人';
delete from ld_cvcolumnlist where cvid =  @cvid;
delete from ld_cvcolumnlistsort where cvid = @cvid;

insert into ld_cvcolumnlistsort(cvid,columnname,sorttype)
select @cvid,'LD_account:createdtime:createdtime:Accounts_DT~O:fieldlabel','desc';

insert into ld_cvcolumnlist(cvid,columnindex,columnname)
select @cvid,0,'LD_account:accountname:accountname:Accounts_fieldlabel:V';

insert into ld_cvcolumnlist(cvid,columnindex,columnname)
select @cvid,1,'LD_account:bill_city:bill_city:Accounts_fieldlabel:V';

insert into ld_cvcolumnlist(cvid,columnindex,columnname)
select @cvid,2,'LD_accountscf:leadsource:leadsource:Accounts_fieldlabel:V';

insert into ld_cvcolumnlist(cvid,columnindex,columnname)
select @cvid,3,'LD_account:rating:rating:Accounts_fieldlabel:V';

insert into ld_cvcolumnlist(cvid,columnindex,columnname)
select @cvid,4,'LD_account:createdtime:createdtime:Accounts_fieldlabel:D';

insert into ld_cvcolumnlist(cvid,columnindex,columnname)
select @cvid,5,'LD_account:smownerid:assigned_user_id:Accounts_fieldlabel:V';

insert into ld_cvcolumnlist(cvid,columnindex,columnname)
select @cvid,6,'LD_contactdetails:lastname:lastname:Contacts_fieldlabel:V';

insert into ld_cvcolumnlist(cvid,columnindex,columnname)
select @cvid,7,'LD_contactdetails:salutation:salutationtype:Contacts_fieldlabel:V';
delimiter;


select tabid into @tabid from ld_tab where `name` = 'ServiceContracts';
update ld_field set typeofdata = 'DT~O' where tabid = @tabid and fieldname in ('ServiceContractscreatedtime','ServiceContractsmodifiedtime');

select tabid into @tabid from ld_tab where `name` = 'Events';
insert into ld_field(tabid,fieldid,columnname,tablename,uitype,fieldname,fieldlabel,block,displaytype,presence,typeofdata,readonly)
select @tabid,(select max(fieldid) from ld_field)+1,'modifiedtime','LD_activity',70,'modifiedtime','修改时间',(select blockid from ld_blocks where blocklabel = 'LBL_EVENT_INFORMATION'),2,0,'DT~O',1 from dual where not exists 
(select * from ld_field where tabid = @tabid and columnname = 'modifiedtime');

insert into ld_field(tabid,fieldid,columnname,tablename,uitype,fieldname,fieldlabel,block,displaytype,presence,typeofdata,readonly)
select @tabid,(select max(fieldid) from ld_field)+1,'createdtime','LD_activity',70,'createdtime','创建时间',(select blockid from ld_blocks where blocklabel = 'LBL_EVENT_INFORMATION'),2,0,'DT~O',1 from dual where not exists 
(select * from ld_field where tabid = @tabid and columnname = 'createdtime');
update ld_field_seq set id = (select max(fieldid)+1 from ld_field);
delimiter;

select tabid into @tabid from ld_tab where `name` = 'Events';
select fieldid into @fieldid from ld_field where tabid = @tabid and fieldname = 'modifiedtime';
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'zh','LD_field',@tabid,@fieldid,'修改时间' 
from dual where not EXISTS(select 1 from ld_tranlabel  where languagetype = 'zh' 
and trantable ='LD_field' and tabid = @tabid and Relateid = @fieldid);
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'en','LD_field',@tabid,@fieldid,'Mody Time' 
from dual where not EXISTS(select 1 from ld_tranlabel  where languagetype = 'en' 
and trantable ='LD_field' and tabid = @tabid and Relateid = @fieldid);

select fieldid into @fieldid from ld_field where tabid = @tabid and fieldname = 'createdtime';
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'zh','LD_field',@tabid,@fieldid,'创建时间' 
from dual where not EXISTS(select 1 from ld_tranlabel  where languagetype = 'zh' 
and trantable ='LD_field' and tabid = @tabid and Relateid = @fieldid);
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'en','LD_field',@tabid,@fieldid,'Create Time' 
from dual where not EXISTS(select 1 from ld_tranlabel  where languagetype = 'en' 
and trantable ='LD_field' and tabid = @tabid and Relateid = @fieldid);

select tabid into @tabid from ld_tab where `name` = 'Accounts';
update ld_field set presence = 0 where tabid = @tabid and fieldname in ('allocatedate','protectdate');
delimiter;

call Select_Customview_Insertinto_tabwithproductview();

update ld_cvcolumnlist set columnname = 'LD_commission:total:hdnGrandTotal:Commission_fieldlabel:V' where columnname like 'LD_commission:total:total:Commission%';
delimiter;

update ld_cvcolumnlist set columnname = 'LD_cashdeposit:inaccount:inaccount:CashDeposit_转入账户:N' where columnname = 'LD_cashdeposit:inaccount:inaccount:CashDeposi%';
delimiter;

update ld_cvcolumnlist set columnname = 'LD_cashdeposit:outaccount:outaccount:CashDeposit_转出账户:N' where columnname = 'LD_cashdeposit:outaccount:outaccount:CashDeposi%';
delimiter;

update ld_cvcolumnlist set columnname = 'LD_cashdeposit:cashmoney:cashmoney:CashDeposit_金额:N' where columnname = 'LD_cashdeposit:cashmoney:cashmoney:CashDeposi%';
delimiter;

update ld_cvcolumnlist set columnname = 'LD_cashdeposit:approvestatus:approvestatus:CashDeposit_审批状态:N' where columnname = 'LD_cashdeposit:approvestatus:approvestatus:CashDeposi%';
delimiter;

update ld_cvcolumnlist set columnname = 'LD_crmentity:smownerid:assigned_user_id:CashDeposit_经办人:V' where columnname = 'LD_crmentity:smownerid:assigned_user_id:CashDeposi%';
delimiter;

update ld_cvcolumnlist set columnname = 'LD_cashdeposit:smownerid:assigned_user_id:CashDeposit_经办人:V' where columnname = 'LD_cashdeposit:smownerid:assigned_user_id:CashDeposi%';
delimiter;

update ld_cvcolumnlist set columnname = 'LD_crmentity:description:description:CashDeposit_摘要:V' where columnname = 'LD_crmentity:description:description:CashDeposi%';
delimiter;

update ld_cvcolumnlist set columnname = 'LD_cashdeposit:description:description:CashDeposit_摘要:V' where columnname = 'LD_cashdeposit:description:description:CashDeposi%';
delimiter;

select tabid into @tabid from ld_tab where `name` = 'OutboundOrder';
update ld_field set typeofdata = 'DT~O' where tabid = @tabid and uitype = 70;

select tabid into @tabid from ld_tab where `name` = 'Stock';
update ld_field set typeofdata = 'DT~O' where tabid = @tabid and uitype = 70;

select tabid into @tabid from ld_tab where `name` = 'Checks';
update ld_field set typeofdata = 'DT~O' where tabid = @tabid and uitype = 70;

update ld_inventoryproductrel set taxprice=listprice where taxprice=0 and listprice<>0;

UPDATE ld_blocks SET create_view=0 WHERE tabid=(SELECT tabid FROM ld_tab WHERE name='HelpDesk') AND blocklabel='LBL_TICKET_RESOLUTION';
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'zh','NORECORDSPLEASESELECT','，未找到相关记录，请选择要执行的操作！','fixedstr' from dual 
where not EXISTS(select 1 from ld_desk where languagetype='zh' and labelbol='NORECORDSPLEASESELECT' and Labeltype='fixedstr'); 
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'en','NORECORDSPLEASESELECT',',no records are found, please select the operation to be performed!','fixedstr' from dual 
where not EXISTS(select 1 from ld_desk where languagetype='en' and labelbol='NORECORDSPLEASESELECT' and Labeltype='fixedstr'); 
delimiter;
-- 2014-11-11

set @cvid=0;
set @columnindex=0;
select cvid into @cvid from ld_customview where entitytype='Accounts' and setdefault=1 limit 1;
select max(columnindex) into @columnindex from ld_cvcolumnlist where cvid=@cvid;
insert into ld_cvcolumnlist(cvid,columnindex,columnname)
select @cvid,@columnindex+1,'LD_account:publicaccount:publicaccount:Accounts_fieldlabel:V' from dual 
where exists (select 1 from ld_cvcolumnlist where cvid=@cvid) and not exists (select 1 from ld_cvcolumnlist where cvid=@cvid and columnname like 'LD_account:publicaccount:publicaccount%');
delimiter;

set @cvid=4;
delete from ld_cvcolumnlist where cvid=@cvid;
insert into ld_cvcolumnlist(cvid,columnindex,columnname)
select @cvid,0,'LD_account:accountname:accountname:Accounts_fieldlabel:V';

insert into ld_cvcolumnlist(cvid,columnindex,columnname)
select @cvid,1,'LD_account:account_no:account_no:Accounts_fieldlabel:V';

insert into ld_cvcolumnlist(cvid,columnindex,columnname)
select @cvid,2,'LD_account:account_type:accounttype:Accounts_fieldlabel:V';

insert into ld_cvcolumnlist(cvid,columnindex,columnname)
select @cvid,3,'LD_account:industry:industry:Accounts_fieldlabel:V';

insert into ld_cvcolumnlist(cvid,columnindex,columnname)
select @cvid,4,'LD_account:phone:phone:Accounts_fieldlabel:V';

insert into ld_cvcolumnlist(cvid,columnindex,columnname)
select @cvid,5,'LD_account:nextcontactdate:nextcontactdate:Accounts_fieldlabel:D';

insert into ld_cvcolumnlist(cvid,columnindex,columnname)
select @cvid,6,'LD_account:publicaccount:publicaccount:Accounts_fieldlabel:V';

insert into ld_cvcolumnlist(cvid,columnindex,columnname)
select @cvid,7,'LD_account:smownerid:assigned_user_id:Accounts_fieldlabel:V';

insert into ld_cvcolumnlist(cvid,columnindex,columnname)
select @cvid,8,'LD_contactdetails:lastname:lastname:Contacts_fieldlabel:V';

insert into ld_cvcolumnlist(cvid,columnindex,columnname)
select @cvid,9,'LD_contactdetails:mobile:mobile:Contacts_fieldlabel:V';

insert into ld_cvcolumnlist(cvid,columnindex,columnname)
select @cvid,10,'LD_contactdetails:pphone:phone:Contacts_fieldlabel:V';
delimiter;

set @cvid=0;
select cvid into @cvid from ld_customview where viewname='客户及联系人';
delete from ld_cvcolumnlist where cvid=@cvid;
insert into ld_cvcolumnlist(cvid,columnindex,columnname)
select @cvid,columnindex,columnname from ld_cvcolumnlist where cvid=4;
delimiter;

call fieldprofile('Accounts'); 
call getallprofile('Accounts'); 
call addtabintoprofile('Accounts',0);

set @seq=0;
update ld_field set sequence=sequence+1 where tabid=6 and block=9 and presence=1;
select max(sequence) into @seq from ld_field where tabid=6 and block=9 and presence=1;
update ld_field set sequence=@seq+1 where tabid=6 and columnname='publicaccount';
set @i=0;
update ld_field set sequence=(@i:=@i+1) where tabid=6 and block=9;
delimiter;

set @fieldid=0;
select fieldid into @fieldid from ld_field where tabid=6 and columnname='publicaccount';
update ld_tranlabel set fieldlabel='是否公海' where tabid=6 and Relateid=@fieldid and languagetype='zh' and trantable='LD_field';
update ld_tranlabel set fieldlabel='Is Public' where tabid=6 and Relateid=@fieldid and languagetype='en' and trantable='LD_field';
delimiter;

update ld_field set presence=1 where tabid=6 and columnname='publicaccount' and exists (select 1 from ld_account_set where `status`=1);
update ld_field set defaultvalue=NULL,typeofdata='DT~M~time_start' where tabid=13 and columnname='realtime';

INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
	SELECT 'zh','AUTOMANUALBACKUPMESSAGE','备份路径在服务器上，由系统自动执行，备份结果为数据库脚本文件。','fixedstr'
		FROM DUAL WHERE NOT EXISTS
	(SELECT 1 FROM ld_desk  WHERE languagetype='zh' AND
		labelbol='AUTOMANUALBACKUPMESSAGE' AND Labeltype='fixedstr');

INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
	SELECT 'en','AUTOMANUALBACKUPMESSAGE','The backup path on the server and path must exist circumstances can be successful backup, automatic backup performed by the system, the results for the database script file.','fixedstr'
	FROM DUAL WHERE NOT EXISTS
	(SELECT 1 FROM ld_desk  WHERE languagetype='en' AND
		labelbol='AUTOMANUALBACKUPMESSAGE' AND Labeltype='fixedstr');
delimiter;
UPDATE ld_desk SET fieldlabel = '手动备份和设置自动备份' WHERE labelbol = 'LBL_BACKUP_SET_DESCRIPTION' AND languagetype = 'zh';
UPDATE ld_desk SET fieldlabel = 'Manual backup and auto backup' WHERE labelbol = 'LBL_BACKUP_SET_DESCRIPTION' AND languagetype = 'en';
delimiter;

UPDATE LD_relatedlists SET sequence=0 WHERE tabid=(SELECT tabid FROM ld_tab WHERE name='Potentials') AND label='RECEIVABLESFORECAST';
delimiter;
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'zh','Thepotentialhasbeencreatedreceivablesforecast5','预测金额合计不等于预测余额，是否继续？','jspop' from dual 
where not EXISTS(select 1 from ld_desk  where languagetype='zh' and labelbol='Thepotentialhasbeencreatedreceivablesforecast5' and Labeltype='jspop');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'en','Thepotentialhasbeencreatedreceivablesforecast5','The total amount is not equal to the predictable amount, do you want to continue?','jspop' from dual 
where not EXISTS(select 1 from ld_desk  where languagetype='en' and labelbol='Thepotentialhasbeencreatedreceivablesforecast5' and Labeltype='jspop');
delimiter;
UPDATE ld_desk SET fieldlabel='合同跟踪表' WHERE labelbol='SalesOrderTrack' AND Labeltype='fixedstr' AND languagetype='zh';
delimiter;

update LD_settings_field set iconpath = 'SMSTemplate.png' where name = 'SMS_templates' and blockid = 3;
update LD_settings_field set iconpath = 'EmailTemplate.png' where name = 'EMAILTEMPLATES' and blockid = 3;
update LD_settings_field set iconpath = 'CallButler.png' where name = 'LBL_PHONESTEWARD_SET' and blockid = 5;
update LD_settings_field set iconpath = 'AccountContact.png' where name = 'LBL_ACCOUNTS_CONTACTS_FIELDS' and blockid = 3;
update LD_settings_field set iconpath = 'servicemigrate.png' where name = 'LBL_SERVICE_PERFORMANCE_PARAMETERS' and blockid = 3;
update LD_settings_field set iconpath = 'code.png' where name = 'LBL_SECURITYCODE_SET' and blockid = 5;
delimiter;
insert into ld_systems_deploy(deploy_value,deploy_type,description,setype)
select '',55,'判断当前呼叫中心接口所属公司','' from dual 
where not exists(select 1 from ld_systems_deploy where deploy_type=55);
delimiter;

call fieldprofile('Accounts');
delimiter;
call getallprofile('Accounts');
delimiter;
call addtabintoprofile('Accounts',0);
delimiter;

select tabid into @tabid from ld_tab where `name` = 'Accounts';
update ld_field set displaytype = 2 where tabid = @tabid and columnname = 'publicaccount';
delimiter;
update ld_customview set pagewidthpercent  = 100 where pagewidthpercent is null;
delimiter;
-- 2014-11-12

update ld_desk set fieldlabel='备份路径在服务器上，需要手动执行，备份结果为数据库脚本文件。' where labelbol='MANUALBACKUPMESSAGE' and languagetype='zh';
update ld_field set defaultvalue=NULL,typeofdata='DT~O~time_start' where tabid=13 and columnname='realtime';

update ld_desk set fieldlabel = '呼叫中心参数' where labelbol = 'LBL_PHONESTEWARD_SET' and languagetype = 'zh';
update ld_desk set fieldlabel = 'Call Center Parameters' where labelbol = 'LBL_PHONESTEWARD_SET' and languagetype = 'en';
delimiter;

update ld_tab set presence=1 where `name` in ('WareHouseTransfer','PurchaseInvoice','PurchaseOrder') and exists (select 1 from ld_version where versiontype in (2,5,10));
-- 2014-11-13


call getallprofile('Vendors');
delimiter;
call fieldprofile('Vendors');
delimiter;

update ld_cvcolumnlist set columnname = 'LD_products:productname:productname:InventoryQuery_fieldlabel:V' where columnname like '%LD_products:productname:productname:products_%' and cvid in (select cvid from ld_customview where entitytype = 'InventoryQuery');
delimiter;

update ld_cvcolumnlist set columnname = 'LD_products:product_no:product_no:InventoryQuery_fieldlabel:V' where columnname like '%LD_products:product_no:product_no:products_%' and cvid in (select cvid from ld_customview where entitytype = 'InventoryQuery');
delimiter;

update ld_cvcolumnlist set columnname = 'LD_products:productsheet:productsheet:InventoryQuery_fieldlabel:V' where columnname like '%products:productsheet:productsheet:products_%' and cvid in (select cvid from ld_customview where entitytype = 'InventoryQuery');
delimiter;

update ld_cvcolumnlist set columnname = 'LD_products:unit_price:unit_price:InventoryQuery_fieldlabel:V' where columnname like '%LD_products:unit_price:unit_price:products_%' and cvid in (select cvid from ld_customview where entitytype = 'InventoryQuery');
delimiter;

update ld_cvcolumnlist set columnname = 'LD_warehouse2products:productqty:productqty:InventoryQuery_fieldlabel:V' where columnname like '%LD_warehouse2products:productqty:productqty:products_%' and cvid in (select cvid from ld_customview where entitytype = 'InventoryQuery');
delimiter;

update ld_cvcolumnlist set columnname = 'LD_products:qtyearly:qtyearly:InventoryQuery_fieldlabel:V' where columnname like '%LD_products:qtyearly:qtyearly:products_%' and cvid in (select cvid from ld_customview where entitytype = 'InventoryQuery');
delimiter;

update ld_cvcolumnlist set columnname = 'LD_products:commissionrate:commissionrate:InventoryQuery_fieldlabel:V' where columnname like '%LD_products:commissionrate:commissionrate:products_%' and cvid in (select cvid from ld_customview where entitytype = 'InventoryQuery');
delimiter;

update ld_cvcolumnlist set columnname = 'LD_warehouse2products:warehouseid:warehouseid:InventoryQuery_fieldlabel:V' where columnname like '%LD_warehouse2products:warehouseid:warehouseid:products_%' and cvid in (select cvid from ld_customview where entitytype = 'InventoryQuery');
delimiter;

update ld_cvcolumnlist set columnname = 'LD_warehouse2products:productid:productid:InventoryQuery_fieldlabel:V' where columnname like '%LD_warehouse2products:productid:productid:products_%' and cvid in (select cvid from ld_customview where entitytype = 'InventoryQuery');
delimiter;

update ld_tabwithproductview set `columns`='LD_salesback:smownerid:assigned_user_id:SalesBack_销售负责人:V' 
where cvid in(select cvid from ld_customview where entitytype='SalesBack') 
and `columns` like '%LD_sashback:smownerid:assigned_user_id:SalesBack%';
delimiter;

update ld_cvcolumnlist set columnname=replace(columnname,'LD_contactdetails:lastname:lastname:Accounts_fieldlabel','LD_contactdetails:lastname:lastname:Contacts_fieldlabel')
where cvid in (select cvid from ld_customview where entitytype='Accounts');

update ld_cvcolumnlist set columnname=replace(columnname,'LD_contactdetails:firstname:firstname:Accounts_fieldlabel','LD_contactdetails:firstname:firstname:Contacts_fieldlabel')
where cvid in (select cvid from ld_customview where entitytype='Accounts');

update ld_cvcolumnlist set columnname=replace(columnname,'LD_contactdetails:salutation:salutation:Accounts_fieldlabel','LD_contactdetails:salutation:salutation:Contacts_fieldlabel')
where cvid in (select cvid from ld_customview where entitytype='Accounts');

update ld_cvcolumnlist set columnname=replace(columnname,'LD_contactdetails:title:title:Accounts_fieldlabel','LD_contactdetails:title:title:Contacts_fieldlabel')
where cvid in (select cvid from ld_customview where entitytype='Accounts');

update ld_cvcolumnlist set columnname=replace(columnname,'LD_contactdetails:pphone:pphone:Accounts_fieldlabel','LD_contactdetails:phone:phone:Contacts_fieldlabel')
where cvid in (select cvid from ld_customview where entitytype='Accounts');

update ld_cvcolumnlist set columnname=replace(columnname,'LD_contactdetails:mobile:mobile:Accounts_fieldlabel','LD_contactdetails:mobile:mobile:Contacts_fieldlabel')
where cvid in (select cvid from ld_customview where entitytype='Accounts');

update ld_cvcolumnlist set columnname=replace(columnname,'LD_contactdetails:faxx:faxx:Accounts_fieldlabel','LD_contactdetails:faxx:faxx:Contacts_fieldlabel')
where cvid in (select cvid from ld_customview where entitytype='Accounts');

update ld_cvcolumnlist set columnname=replace(columnname,'LD_contactdetails:email:email:Accounts_fieldlabel','LD_contactdetails:email:email:Contacts_fieldlabel')
where cvid in (select cvid from ld_customview where entitytype='Accounts');

update ld_cvcolumnlist set columnname=replace(columnname,'LD_contactdetails:reference:reference:Accounts_fieldlabel','LD_contactdetails:reference:reference:Contacts_fieldlabel')
where cvid in (select cvid from ld_customview where entitytype='Accounts');

update ld_cvcolumnlist set columnname=replace(columnname,'LD_contactdetails:mailingzip:mailingzip:Accounts_fieldlabel','LD_contactdetails:mailingzip:mailingzip:Contacts_fieldlabel')
where cvid in (select cvid from ld_customview where entitytype='Accounts');

update ld_cvcolumnlist set columnname=replace(columnname,'LD_contactdetails:mailingstreet:mailingstreet:Accounts_fieldlabel','LD_contactdetails:mailingstreet:mailingstreet:Contacts_fieldlabel')
where cvid in (select cvid from ld_customview where entitytype='Accounts');

DROP PROCEDURE IF EXISTS `update_account_columnindex`;
delimiter ||
CREATE  PROCEDURE `update_account_columnindex`(

)
begin

	declare tmp_cvid  int default 0;

	declare mycursor cursor for select cvid from ld_customview where entitytype='Accounts' order by cvid; 
	DECLARE CONTINUE HANDLER FOR SQLSTATE '02000' set tmp_cvid = -1;

	open mycursor;
	fetch mycursor into tmp_cvid;

	while(tmp_cvid >1) DO
			
			update ld_cvcolumnlist set columnindex=columnindex+100 where cvid=tmp_cvid and columnname like 'LD_contactdetails%';
			
			select -1 into @i;
			update ld_cvcolumnlist set columnindex=(@i:=@i+1) where cvid=tmp_cvid order by columnindex;
			
			fetch mycursor into tmp_cvid;
	end while;
	close mycursor;
end ||
delimiter;

call update_account_columnindex;
delimiter

update ld_field set fieldlabel='description',fieldlabel='问题描述' where tabid=13 and columnname='description';

set @blockid=0;
select blockid into @blockid from ld_blocks where tabid=13 and blocklabel='LBL_DESCRIPTION_INFORMATION';
update ld_tranlabel set fieldlabel='问题描述' where trantable='LD_blocks' and languagetype='zh' and Relateid=@blockid and fieldlabel='问题描述信息';
delimiter;

set @fieldid=0;
select fieldid into @fieldid from ld_field where tabid=13 and columnname='solution';
update ld_tranlabel set fieldlabel='解决方法' where trantable='LD_field' and languagetype='zh' and Relateid=@fieldid and fieldlabel='解决方案';
delimiter;

INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
	SELECT 'zh','COLUMNSELECTLEASTTHREE','显示列至少选择三列。','jspop'
		FROM DUAL WHERE NOT EXISTS
	(SELECT 1 FROM ld_desk  WHERE languagetype='zh' AND
		labelbol='COLUMNSELECTLEASTTHREE' AND Labeltype='jspop');

INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
	SELECT 'en','COLUMNSELECTLEASTTHREE','Display column select at least three columns.','jspop'
	FROM DUAL WHERE NOT EXISTS
	(SELECT 1 FROM ld_desk  WHERE languagetype='en' AND
		labelbol='COLUMNSELECTLEASTTHREE' AND Labeltype='jspop');
delimiter;
-- 2014-11-14

INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
	SELECT 'zh','THEPERCENTAGEINTERVAL','百分比区间100到500','jspop'
		FROM DUAL WHERE NOT EXISTS
	(SELECT 1 FROM ld_desk  WHERE languagetype='zh' AND
		labelbol='THEPERCENTAGEINTERVAL' AND Labeltype='jspop');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
	SELECT 'en','THEPERCENTAGEINTERVAL','The percentage of interval 100 to 500','jspop'
	FROM DUAL WHERE NOT EXISTS
	(SELECT 1 FROM ld_desk  WHERE languagetype='en' AND
		labelbol='THEPERCENTAGEINTERVAL' AND Labeltype='jspop');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,Labeltype)
select 'zh','INBOX','收件箱','fixedstr' from DUAL where not EXISTS(select 1 from ld_desk where labelbol='INBOX' and languagetype='zh');
insert into ld_desk(languagetype,labelbol,fieldlabel,Labeltype)
select 'en','INBOX','Inbox','fixedstr' from DUAL where not EXISTS(select 1 from ld_desk where labelbol='INBOX' and languagetype='en');
delimiter;
insert into ld_desk(languagetype,labelbol,fieldlabel,Labeltype)
select 'zh','Sent Messages','已发送邮件','fixedstr' from DUAL where not EXISTS(select 1 from ld_desk where labelbol='Sent Messages' and languagetype='zh');
insert into ld_desk(languagetype,labelbol,fieldlabel,Labeltype)
select 'en','Sent Messages','Sent Messages','fixedstr' from DUAL where not EXISTS(select 1 from ld_desk where labelbol='Sent Messages' and languagetype='en');
delimiter;
insert into ld_desk(languagetype,labelbol,fieldlabel,Labeltype)
select 'zh','Drafts','草稿箱','fixedstr' from DUAL where not EXISTS(select 1 from ld_desk where labelbol='Drafts' and languagetype='zh');
insert into ld_desk(languagetype,labelbol,fieldlabel,Labeltype)
select 'en','Drafts','Drafts','fixedstr' from DUAL where not EXISTS(select 1 from ld_desk where labelbol='Drafts' and languagetype='en');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,Labeltype)
select 'zh','Deleted Messages','已删除邮件','fixedstr' from DUAL where not EXISTS(select 1 from ld_desk where labelbol='Deleted Messages' and languagetype='zh');
insert into ld_desk(languagetype,labelbol,fieldlabel,Labeltype)
select 'en','Deleted Messages','Deleted Messages','fixedstr' from DUAL where not EXISTS(select 1 from ld_desk where labelbol='Deleted Messages' and languagetype='en');
delimiter;
insert into ld_desk (languagetype,labelbol,fieldlabel,labeltype)
select 'zh','THENUMBEROFRETURNS50','退货数量不能超过源单的已入库产品数量','jspop' from DUAL
 where not EXISTS(select 1 from ld_desk where languagetype='zh' and labelbol='THENUMBEROFRETURNS50');

insert into ld_desk (languagetype,labelbol,fieldlabel,labeltype)
select 'en','THENUMBEROFRETURNS50','Returns the number of not more than the number of in product source list','jspop' from DUAL
 where not EXISTS(select 1 from ld_desk where languagetype='en' and labelbol='THENUMBEROFRETURNS50');
delimiter;

select usereportid into @id from LD_usereport where name='PurchaseOrderTrack';

DELETE FROM LD_UseReportcolumns WHERE Usereportid=@id and realcolumns like 'LD_crmentity:smownerid:assigned_user_id:PurchaseOrder_%';

insert into LD_UseReportcolumns(id,Usereportid,columns,Sequence,columnshow,realcolumns,realencolumns) 
select '', @id, 'LD_crmentity:smownerid:assigned_user_id:PurchaseOrder_assigned_user_id:V', 0, 1, 'LD_crmentity:smownerid:assigned_user_id:PurchaseOrder_采购订单_采购负责人:V',
'LD_crmentity:smownerid:assigned_user_id:PurchaseOrder_assigned to:V'   
from dual where not exists(select 1 from LD_UseReportcolumns where Usereportid=@id and realcolumns like 'LD_crmentity:smownerid:assigned_user_id:PurchaseOrder_%');
delimiter;

SELECT usereportid into @usereportid from  ld_usereport where name='SalesOrderTrack';
UPDATE LD_UseReportcolumns set realcolumns='LD_salesorder:GrossProfitl:毛利率:OftenUseReport_毛利率%:N' where Usereportid=@usereportid and `columns`='LD_salesorder:GrossProfitl:毛利率:OftenUseReport_GrossProfitl:N';
delimiter;


CALL AddColumn('LD_customview','customcategory','varchar','25',null);
delimiter;
update LD_customview set customcategory = 'ALLACCOUNT' where entitytype='Accounts';
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'zh','TOTALNUMBEROFCOME','来电总数','fixedstr' from dual 
where not EXISTS(select 1 from ld_desk where languagetype='zh' and labelbol='TOTALNUMBEROFCOME' and Labeltype='fixedstr'); 
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'en','TOTALNUMBEROFCOME','Total number of calls to the','fixedstr' from dual 
where not EXISTS(select 1 from ld_desk where languagetype='en' and labelbol='TOTALNUMBEROFCOME' and Labeltype='fixedstr'); 
delimiter;
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'zh','TOTALNUMBEROFGO','去电总数','fixedstr' from dual 
where not EXISTS(select 1 from ld_desk where languagetype='zh' and labelbol='TOTALNUMBEROFGO' and Labeltype='fixedstr'); 
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'en','TOTALNUMBEROFGO','Total number of go electric','fixedstr' from dual 
where not EXISTS(select 1 from ld_desk where languagetype='en' and labelbol='TOTALNUMBEROFGO' and Labeltype='fixedstr'); 
delimiter;

select max(sequence) into @sequence from ld_customview where entitytype = 'Accounts';
insert into ld_customview(cvid,viewname,setdefault,entitytype,status,userid,sequence,pagewidthpercent,customcategory)
select (select max(id)+1 from ld_customview_seq),'All',0,'Accounts',3,1,@sequence+1,100,'PUBLICALLOCATE'
from dual where not EXISTS(select 1 from ld_customview  where viewname = 'All' and entitytype ='Accounts' and customcategory = 'PUBLICALLOCATE');
update ld_customview_seq set id = (select max(cvid)+1 from ld_customview);
delimiter;

select cvid into @cvid from ld_customview where entitytype = 'Accounts' and viewname = 'All' and customcategory = 'PUBLICALLOCATE';
delete from ld_cvcolumnlist where cvid =  @cvid;
delete from ld_cvcolumnlistsort where cvid = @cvid;

insert into ld_cvcolumnlistsort(cvid,columnname,sorttype)
select @cvid,'LD_account:createdtime:createdtime:Accounts_DT~O:fieldlabel','desc';

insert into ld_cvcolumnlist(cvid,columnindex,columnname)
select @cvid,0,'LD_account:accountname:accountname:Accounts_fieldlabel:V';

insert into ld_cvcolumnlist(cvid,columnindex,columnname)
select @cvid,1,'LD_account:account_no:account_no:Accounts_fieldlabel:V';

insert into ld_cvcolumnlist(cvid,columnindex,columnname)
select @cvid,2,'LD_account:bill_city:bill_city:Accounts_fieldlabel:V';

insert into ld_cvcolumnlist(cvid,columnindex,columnname)
select @cvid,3,'LD_accountscf:leadsource:leadsource:Accounts_fieldlabel:V';

insert into ld_cvcolumnlist(cvid,columnindex,columnname)
select @cvid,4,'LD_account:rating:rating:Accounts_fieldlabel:V';

insert into ld_cvcolumnlist(cvid,columnindex,columnname)
select @cvid,5,'LD_account:account_type:accounttype:Accounts_fieldlabel:V';

insert into ld_cvcolumnlist(cvid,columnindex,columnname)
select @cvid,6,'LD_account:smownerid:assigned_user_id:Accounts_fieldlabel:V';

insert into ld_cvcolumnlist(cvid,columnindex,columnname)
select @cvid,7,'LD_account:allocatedate:allocatedate:Accounts_fieldlabel:D';

insert into ld_cvcolumnlist(cvid,columnindex,columnname)
select @cvid,8,'LD_account:protectdate:protectdate:Accounts_fieldlabel:D';

insert into ld_cvcolumnlist(cvid,columnindex,columnname)
select @cvid,9,'LD_account:publicaccount:publicaccount:Accounts_fieldlabel:V';
delimiter;
insert into ld_cvcolumnlist(cvid,columnindex,columnname)
select @cvid,10,'LD_account:completed:completed:Accounts_fieldlabel:V';
delimiter;


select max(sequence) into @sequence from ld_customview where entitytype = 'Accounts';
insert into ld_customview(cvid,viewname,setdefault,entitytype,status,userid,sequence,pagewidthpercent,customcategory)
select (select max(id)+1 from ld_customview_seq),'All',0,'Accounts',3,1,@sequence+1,100,'NOALLOCATE'
from dual where not EXISTS(select 1 from ld_customview  where viewname = 'All' and entitytype ='Accounts' and customcategory = 'NOALLOCATE');
update ld_customview_seq set id = (select max(cvid)+1 from ld_customview);
delimiter;

select cvid into @cvid from ld_customview where entitytype = 'Accounts' and viewname = 'All' and customcategory = 'NOALLOCATE';
delete from ld_cvcolumnlist where cvid =  @cvid;
delete from ld_cvcolumnlistsort where cvid = @cvid;

insert into ld_cvcolumnlistsort(cvid,columnname,sorttype)
select @cvid,'LD_account:createdtime:createdtime:Accounts_DT~O:fieldlabel','desc';

insert into ld_cvcolumnlist(cvid,columnindex,columnname)
select @cvid,0,'LD_account:accountname:accountname:Accounts_fieldlabel:V';

insert into ld_cvcolumnlist(cvid,columnindex,columnname)
select @cvid,1,'LD_account:account_no:account_no:Accounts_fieldlabel:V';

insert into ld_cvcolumnlist(cvid,columnindex,columnname)
select @cvid,2,'LD_account:bill_city:bill_city:Accounts_fieldlabel:V';

insert into ld_cvcolumnlist(cvid,columnindex,columnname)
select @cvid,3,'LD_account:rating:rating:Accounts_fieldlabel:V';

insert into ld_cvcolumnlist(cvid,columnindex,columnname)
select @cvid,4,'LD_account:account_type:accounttype:Accounts_fieldlabel:V';

insert into ld_cvcolumnlist(cvid,columnindex,columnname)
select @cvid,5,'LD_accountscf:leadsource:leadsource:Accounts_fieldlabel:V';

insert into ld_cvcolumnlist(cvid,columnindex,columnname)
select @cvid,6,'LD_account:createdtime:createdtime:Accounts_Created:DT';

insert into ld_cvcolumnlist(cvid,columnindex,columnname)
select @cvid,7,'LD_account:nextcontactdate:nextcontactdate:Accounts_fieldlabel:V';

insert into ld_cvcolumnlist(cvid,columnindex,columnname)
select @cvid,8,'LD_account:smownerid:assigned_user_id:Accounts_fieldlabel:V';

insert into ld_cvcolumnlist(cvid,columnindex,columnname)
select @cvid,9,'LD_account:publicaccount:publicaccount:Accounts_fieldlabel:V';
delimiter;

CALL AddColumn('LD_account','completed','varchar','25',null);
delimiter;

select tabid into @tabid from ld_tab where `name` = 'Accounts';
select max(sequence) into @sequence from ld_field where tabid = @tabid;
insert into ld_field(tabid,fieldid,columnname,tablename,uitype,fieldname,fieldlabel,block,displaytype,presence,typeofdata,readonly,sequence)
select @tabid,(select max(fieldid) from ld_field)+1,'completed','LD_account',203,'completed','公海目标',(select blockid from ld_blocks where tabid = @tabid and blocklabel = 'LBL_ACCOUNT_INFORMATION'),3,0,'V~O',1,@sequence+1 
from dual where not exists(select * from ld_field where tabid = @tabid and columnname = 'completed' and uitype = 203);
update ld_field_seq set id = (select max(fieldid) from ld_field);
delimiter;

select tabid into @tabid from ld_tab where `name` = 'Accounts';
select fieldid into @fieldid from ld_field where tabid = @tabid and fieldname = 'completed' and uitype = 203;
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'zh','LD_field',@tabid,@fieldid,'公海目标' 
from dual where not EXISTS(select 1 from ld_tranlabel  where languagetype = 'zh' 
and trantable ='LD_field' and tabid = @tabid and relateid=@fieldid);
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'en','LD_field',@tabid,@fieldid,'PublicAccounts Designation' 
from dual where not EXISTS(select 1 from ld_tranlabel  where languagetype = 'en' 
and trantable ='LD_field' and tabid = @tabid and relateid=@fieldid);

call fieldprofile('Accounts');
delimiter;

call getallprofile('Accounts');
delimiter;

call addtabintoprofile('Accounts',0);
delimiter;


DROP PROCEDURE IF EXISTS `update_products_columnindex`;
delimiter ||
CREATE  PROCEDURE `update_products_columnindex`(

)
begin

	declare tmp_cvid  int default 0;

	declare mycursor cursor for select cvid from ld_customview where entitytype='Products' order by cvid; 
	DECLARE CONTINUE HANDLER FOR SQLSTATE '02000' set tmp_cvid = -1;

	open mycursor;
	fetch mycursor into tmp_cvid;

	while(tmp_cvid >1) DO
			
			update ld_cvcolumnlist set columnindex=columnindex+100 where cvid=tmp_cvid;
			update ld_cvcolumnlist set columnindex=99 where cvid=tmp_cvid and columnname like 'LD_products:productname:productname%';
			set @i=-1;
			update ld_cvcolumnlist set columnindex=(@i:=@i+1) where cvid=tmp_cvid order by columnindex;
			
			fetch mycursor into tmp_cvid;
	end while;
	close mycursor;
end ||
delimiter;

call update_products_columnindex;
delimiter;

set @blocklabel='LBL_CAMPAIGN_INFORMATION';
select tabid into @tabid from ld_tab where name='Campaigns';
select blockid into @block from ld_blocks where tabid=@tabid and blocklabel=@blocklabel;
select 'LD_campaign' into @tablename;
select 'startdate' into @columnname;
select 'startdate' into @fieldname;
select '预计开始日期' into @zh;
select 'Expected Start Date' into @en;
select 23 into @uitype;
select 1 into @displaytype;
select 'V~M' into @typeofdata;
select sequence into @seq from ld_field where tabid=@tabid and block=@block and columnname='closingdate';
update ld_field set sequence=sequence+5 where tabid=@tabid and block=@block and sequence>=@seq;

select max(fieldid) into @fieldid from ld_field;
insert into ld_field(tabid,fieldid,columnname,tablename,generatedtype,uitype,fieldname,fieldlabel,readonly,presence,maximumlength,sequence,block,displaytype,typeofdata,quickcreate,info_type,searchfieldtype)
select @tabid,@fieldid+1,@columnname,@tablename,1,@uitype,@fieldname,@zh,1,2,100,@seq,@block,@displaytype,@typeofdata,3,'BAS',1 from dual 
where not exists (select 1 from ld_field where tabid = @tabid and columnname = @columnname);
update ld_field_seq set id = (select max(fieldid) from ld_field);
update ld_field set sequence=4,presence=2 where tabid=@tabid and block=@block and columnname='contactid';

select fieldid into @fieldid from ld_field where tabid = @tabid and columnname = @columnname;
delete from ld_tranlabel where trantable ='LD_field' and relateid=@fieldid;
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'zh','LD_field',@tabid,@fieldid,@zh;

insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'en','LD_field',@tabid,@fieldid,@en;

select 0 into @i;
update ld_field set sequence=(@i:=@i+1) where tabid=@tabid and block=@block order by sequence;
update ld_field set defaultvalue='thistoday' where tabid=@tabid and columnname='startdate';
update ld_field set defaultvalue=NULL where tabid=@tabid and columnname='closingdate';

call AddColumn(@tablename,@columnname,'varchar','200',NULL);
alter table LD_campaign modify column startdate date;
delimiter;

call getallprofile('Campaigns');
delimiter;
call fieldprofile('Campaigns');
delimiter;
call addtabintoprofile('Campaigns',0);
delimiter;

call addtabintoprofile('Potentials',0);
delimiter;
call addtabintoprofile('Vendors',0);
delimiter;
call addtabintoprofile('ProjectTask',0);
delimiter;
call addtabintoprofile('HelpDesk',0);
delimiter;
-- 2014-11-17

update ld_blocks set sequence=100 where tabid=47 and blocklabel='LBL_DESCRIPTION_INFORMATION';
set @i=0;
update ld_blocks set sequence=(@i:=@i+1) where tabid=47 order by sequence;
delimiter;

set @tabid=0;
select tabid into @tabid from ld_tab where `name`='ContactRecords';
update ld_field set quickcreate=1,quickcreatesequence=NULL where tabid=@tabid;
update ld_field set quickcreate=0,quickcreatesequence=1 where tabid=@tabid and columnname='subject';
update ld_field set quickcreate=0,quickcreatesequence=2 where tabid=@tabid and columnname='accountid';
update ld_field set quickcreate=0,quickcreatesequence=3 where tabid=@tabid and columnname='contactid';
update ld_field set quickcreate=0,quickcreatesequence=4 where tabid=@tabid and columnname='potentialid';
update ld_field set quickcreate=0,quickcreatesequence=5 where tabid=@tabid and columnname='contactrecordtype';
update ld_field set quickcreate=0,quickcreatesequence=6 where tabid=@tabid and columnname='contactdate';
update ld_field set quickcreate=0,quickcreatesequence=7 where tabid=@tabid and columnname='content';
update ld_field set quickcreate=0,quickcreatesequence=8 where tabid=@tabid and columnname='smownerid';
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'zh','CALLCENTERTYPE','呼叫中心类型','fixedstr' from dual 
where not EXISTS(select 1 from ld_desk where languagetype='zh' and labelbol='CALLCENTERTYPE' and Labeltype='fixedstr'); 
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'en','CALLCENTERTYPE','Call Center Type','fixedstr' from dual 
where not EXISTS(select 1 from ld_desk where languagetype='en' and labelbol='CALLCENTERTYPE' and Labeltype='fixedstr'); 
delimiter; 

UPDATE ld_inventoryproductrel INNER JOIN ld_crmentity ON ld_inventoryproductrel.entitytypeid=ld_crmentity.crmid
SET ld_inventoryproductrel.entitytype=ld_crmentity.setype ;
delimiter;

select tabid into @tabid from ld_tab where `name`='Accounts';
select fieldid into @fieldid from ld_field where tabid = @tabid and fieldname = 'protectdate';
update ld_tranlabel set fieldlabel = '最后保护日期' where tabid = @tabid and Relateid = @fieldid and languagetype = 'zh';
delimiter;

update ld_account set completed = '达成' where publicaccount > 1 and protectdate is null;
delimiter;


select usereportid into @id from LD_usereport where name='SalesOrderTrack';
UPDATE ld_usereportcolumns SET realcolumns='LD_salesorder:GrossProfitl:毛利率:OftenUseReport_毛利率:N',
realencolumns='LD_salesorder:GrossProfitl:毛利率:OftenUseReport_Gross Profit:N' 
WHERE columns LIKE '%salesorder:GrossProfitl:毛利率:OftenUseReport_%' AND Usereportid=@id;
delimiter;


select usereportid into @id from LD_usereport where name='SendCashBillSum_PurchaseOrder';

DELETE FROM LD_UseReportcolumns WHERE Usereportid=@id and realcolumns like 
'%LD_usersPurchaseOrder:smownerid:assigned_user_id:PurchaseOrder_%';

insert into LD_UseReportcolumns(id,Usereportid,columns,Sequence,columnshow,realcolumns,realencolumns) 
select '', @id, 
'LD_usersPurchaseOrder:smownerid:assigned_user_id:PurchaseOrder_assigned_user_id:V', 0, 1, 
'LD_usersPurchaseOrder:smownerid:assigned_user_id:PurchaseOrder_采购订单_采购负责人:V',
'LD_usersPurchaseOrder:smownerid:assigned_user_id:PurchaseOrder_assigned to:V'   
from dual where not exists(select 1 from LD_UseReportcolumns where Usereportid=@id and realcolumns like 
'%LD_usersPurchaseOrder:smownerid:assigned_user_id:PurchaseOrder_%');
delimiter;

select usereportid into @id from LD_usereport where name='SendCashBillSum_SendPayment';

DELETE FROM LD_UseReportcolumns WHERE Usereportid=@id and realcolumns like 
'%LD_crmentity:smownerid:smownerid:SendPayment_%';

insert into LD_UseReportcolumns(id,Usereportid,columns,Sequence,columnshow,realcolumns,realencolumns) 
select '', @id, 
'LD_crmentity:smownerid:smownerid:SendPayment_smownerid:V', 0, 1, 
'LD_crmentity:smownerid:smownerid:SendPayment_采购订单_采购负责人:V',
'LD_crmentity:smownerid:smownerid:SendPayment_Assigned To:V'   
from dual where not exists(select 1 from LD_UseReportcolumns where Usereportid=@id and realcolumns like 
'%LD_crmentity:smownerid:smownerid:SendPayment_%');
delimiter;

update ld_tranlabel set fieldlabel='预期回报率(%)' where tabid=26 and Relateid=146 and trantable='LD_field' and languagetype='zh' and fieldlabel='预期回报率';
update ld_tranlabel set fieldlabel='实际回报率(%)' where tabid=26 and Relateid=149 and trantable='LD_field' and languagetype='zh' and fieldlabel='实际回报率';

UPDATE ld_desk SET fieldlabel = '页面宽度百分比区间为0~500' WHERE labelbol = 'THEPERCENTAGEINTERVAL' AND languagetype = 'zh';
UPDATE ld_desk SET fieldlabel = 'Page width percentage range for 0~500' WHERE labelbol = 'THEPERCENTAGEINTERVAL' AND languagetype = 'en';
delimiter;
-- 2014-11-18

select tabid into @tabid from ld_tab where `name`='Accounts';
select fieldid into @fieldid from ld_field where tabid = @tabid and fieldname = 'protectdate';
update ld_tranlabel set fieldlabel = '保护结束日期' where tabid = @tabid and Relateid = @fieldid and languagetype = 'zh';
delimiter;

call addtableIndex('ld_contactrecords','Contactrecords_createdtime_idx','createdtime');
delimiter;

set @cvid=0;
select cvid into @cvid from ld_customview where entitytype='HelpDesk' and viewname='All';
delete from ld_cvcolumnlist where cvid=@cvid;
insert into ld_cvcolumnlist(cvid,columnindex,columnname)
select @cvid,0,'LD_troubletickets:ticket_no:ticket_no:HelpDesk_fieldlabel:V';

insert into ld_cvcolumnlist(cvid,columnindex,columnname)
select @cvid,1,'LD_troubletickets:ticket_title:ticket_title:HelpDesk_fieldlabel:V';

insert into ld_cvcolumnlist(cvid,columnindex,columnname)
select @cvid,2,'LD_troubletickets:accountid:account_id:HelpDesk_fieldlabel:V';

insert into ld_cvcolumnlist(cvid,columnindex,columnname)
select @cvid,3,'LD_troubletickets:status:ticketstatus:HelpDesk_fieldlabel:V';

insert into ld_cvcolumnlist(cvid,columnindex,columnname)
select @cvid,4,'LD_troubletickets:servicetype:servicetype:HelpDesk_fieldlabel:V';

insert into ld_cvcolumnlist(cvid,columnindex,columnname)
select @cvid,5,'LD_troubletickets:category:ticketcategories:HelpDesk_fieldlabel:V';

insert into ld_cvcolumnlist(cvid,columnindex,columnname)
select @cvid,6,'LD_troubletickets:realtime:realtime:HelpDesk_fieldlabel:DT';

insert into ld_cvcolumnlist(cvid,columnindex,columnname)
select @cvid,7,'LD_troubletickets:smownerid:assigned_user_id:HelpDesk_fieldlabel:V';

update ld_cvcolumnlistsort set columnname='LD_troubletickets:realtime:realtime:HelpDesk_DT~O~time_start:fieldlabel',sorttype='desc' where cvid=@cvid;
delimiter;

select usereportid into @id from LD_usereport where name='Performancestatisticscollection';
UPDATE ld_usereportcolumns SET realcolumns='LD_cashbill:Atotal:Atotal:OftenUseReport_已收总额:N' 
WHERE columns LIKE '%LD_cashbill:Atotal:Atotal:OftenUseReport_%' AND Usereportid=@id ;
delimiter;

delete from ld_desk where labelbol = 'TEMPLATEDESCRIPTIONINFORMATION';
delimiter;
-- 2014-11-19


UPDATE ld_systems_deploy SET description='新增保存后是否立即创建回款预测。1：否，0：是' WHERE deploy_type=54;
UPDATE ld_systems_deploy SET description='回款计划按照项目状态收款和提醒。1：是，2：否' WHERE deploy_type=53;
UPDATE ld_systems_deploy SET description='未读提醒是否弹框提示。1：是，2：否' WHERE deploy_type=51;
delimiter;

UPDATE ld_inventoryproductrel INNER JOIN ld_crmentity on ld_crmentity.crmid=ld_inventoryproductrel.entitytypeid
set ld_inventoryproductrel.entitytype=ld_crmentity.setype;
delimiter;
-- 2014-11-20

update ld_field_seq set id=(select max(fieldid) from ld_field);
update ld_blocks_seq set id=(select max(blockid) from ld_blocks);
update ld_relatedlists_seq set id=(select max(relation_id) from ld_relatedlists);
update ld_customview_seq set id = (select max(cvid) from ld_customview);
update ld_links_seq set id=(select max(linkid) from ld_links);
update ld_picklist_dependency_seq set id=(select max(id) from ld_picklist_dependency);
update ld_crmentity_seq set id=(select max(crmid) from ld_crmentity);
update ld_approve_seq set id=(select max(id) from ld_approve);
update ld_approvestep_seq set id=(select max(id) from ld_approvestep);
update lD_version set old_version='V5.8.0' ,current_version='V5.8.0' ,remark='V5.8.0-20141120';
delimiter;