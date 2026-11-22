INSERT INTO ld_desk (languagetype,labelbol,fieldlabel,Labeltype)SELECT 'zh','SWITCHINGMODULEEMPTYLIST','如果切换模块，将清空列表，请确定，是否继续！','jspop' FROM DUAL
WHERE NOT EXISTS(SELECT 1 FROM ld_desk WHERE  languagetype='zh' AND labelbol='SWITCHINGMODULEEMPTYLIST' AND Labeltype='jspop');

INSERT INTO ld_desk (languagetype,labelbol,fieldlabel,Labeltype)SELECT 'en','SWITCHINGMODULEEMPTYLIST','If the switching module, the empty list, please make sure, whether to continue!','jspop' FROM DUAL
WHERE NOT EXISTS(SELECT 1 FROM ld_desk WHERE  languagetype='en' AND labelbol='SWITCHINGMODULEEMPTYLIST' AND Labeltype='jspop');
delimiter;

update ld_smssendtype set typename ='祝福短信' where typeid = '2';
delimiter;
insert into ld_smssendtype (typeid,typename) select '3','通知短信' from dual
where not exists(select 1 from ld_smssendtype where typeid='3' and typename='通知短信');
delimiter;
update ld_desk set Fieldlabel='公海已分配{$Accounts.Accounts}释放后，更改{$Accounts.Accounts}负责人为（为空表示不更改）' where labelbol='AFTERRELEASINGTHEALLOCATEDHIGNSEAS' and languagetype='zh' and Labeltype = 'fixedstr';
update ld_desk set Fieldlabel='After releasing the allocated hign seas customers ,modify the owner as(do nothing if empty) ' where labelbol='AFTERRELEASINGTHEALLOCATEDHIGNSEAS' and languagetype='en' and Labeltype = 'fixedstr';
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,Labeltype)
select 'zh','next15days','未来15天','fixedstr' 
from dual where not EXISTS(select 1 from ld_desk where languagetype ='zh' and labelbol='next15days');
insert into ld_desk(languagetype,labelbol,fieldlabel,Labeltype)
select 'en','next15days','Next 15 Days','fixedstr' 
from dual where not EXISTS(select 1 from ld_desk where languagetype ='en' and labelbol='next15days');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'zh','FINDANDADDAPPROVALLIST','查找并添加到审批列表','fixedstr' from dual 
where not EXISTS(select 1 from ld_desk  where languagetype='zh' and labelbol='FINDANDADDAPPROVALLIST' and Labeltype='fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'en','FINDANDADDAPPROVALLIST','Find and add to the approval list','fixedstr' from dual 
where not EXISTS(select 1 from ld_desk  where languagetype='en' and labelbol='FINDANDADDAPPROVALLIST' and Labeltype='fixedstr');
delimiter;

update ld_desk set fieldlabel='SQL脚本格式不正确,不允许带有关键字：delete、drop table' where labelbol='LBL_AUTOTASK_CHECKQUERY' and languagetype='zh';
update ld_desk set fieldlabel='The SQL script is not in the correct format. Do not allow the keywords such as delete and drop table' where labelbol='LBL_AUTOTASK_CHECKQUERY' and languagetype='en';


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

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'zh','FIXEDCYCLEREMINDRULES','自提醒时间参考字段之日起每隔N天提醒一次','fixedstr' from dual 
where not EXISTS(select 1 from ld_desk  where languagetype='zh' and labelbol='FIXEDCYCLEREMINDRULES' and Labeltype='fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'en','FIXEDCYCLEREMINDRULES','Reference fields from the day on which the reminder time,remind once every N days','fixedstr' from dual 
where not EXISTS(select 1 from ld_desk  where languagetype='en' and labelbol='FIXEDCYCLEREMINDRULES' and Labeltype='fixedstr');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'zh','REMINDRULESPECIFIEDPERIOD','自提醒时间参考字段之日起提前或者延后N天提醒：负数表示提前，正数表示延后。','fixedstr' from dual 
where not EXISTS(select 1 from ld_desk  where languagetype='zh' and labelbol='REMINDRULESPECIFIEDPERIOD' and Labeltype='fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'en','REMINDRULESPECIFIEDPERIOD','Reference fields from the day on which the reminder time，remind earlier or later in N days.','fixedstr' from dual 
where not EXISTS(select 1 from ld_desk  where languagetype='en' and labelbol='REMINDRULESPECIFIEDPERIOD' and Labeltype='fixedstr');
delimiter;

select max(tabid) into @tabid from ld_tab ;
insert into ld_tab (tabid,name,presence,tabsequence,tablabel,customized,ownedby,isentitytype,parent,printtab,proportion)
select @tabid+1,'mobileHelpDesk',0,50,'mobileHelpDesk',0,0,1,'Finacial',1,0 from dual 
where not EXISTS(select 1 from ld_tab where name='mobileHelpDesk');

select max(cvid) into @cvid from ld_customview ;
insert into ld_customview(cvid,viewname,setdefault,setmetrics,entitytype,status,userid,sequence,pagewidthpercent)
select @cvid+1 ,'mobileHelpDesk',0,0,'mobileHelpDesk',0,1,1,100 from dual 
where not exists(select 1 from ld_customview where viewname='mobileHelpDesk' and entitytype='mobileHelpdesk');

update ld_customview_seq set id=(select max(cvid) from ld_customview);
delimiter;
 
select cvid into @cvid from ld_customview where viewname='mobileHelpDesk' and entitytype='mobileHelpdesk';
delete from ld_cvcolumnlist where cvid=@cvid;
insert into ld_cvcolumnlist(cvid,columnindex,columnname)select @cvid,0,'LD_troubletickets:ticket_no:ticket_no:HelpDesk_编号:V' from DUAL 
where not exists(select 1 from ld_cvcolumnlist where columnname like '%LD_troubletickets:ticket_no:ticket_no:HelpDesk%' and cvid=@cvid);

insert into ld_cvcolumnlist(cvid,columnindex,columnname)select @cvid,1,'LD_troubletickets:realtime:realtime:HelpDesk_fieldlabel:DT' from DUAL 
where not exists(select 1 from ld_cvcolumnlist where columnname like '%LD_troubletickets:realtime:realtime:HelpDesk%' and cvid=@cvid);

insert into ld_cvcolumnlist(cvid,columnindex,columnname)select @cvid,2,'LD_troubletickets:smownerid:assigned_user_id:HelpDesk_fieldlabel:V' from DUAL 
where not exists(select 1 from ld_cvcolumnlist where columnname like '%LD_troubletickets:smownerid:assigned_user_id:HelpDesk%' and cvid=@cvid);

insert into ld_cvcolumnlist(cvid,columnindex,columnname)select @cvid,3,'LD_troubletickets:accountid:account_id:HelpDesk_fieldlabel:V' from DUAL 
where not exists(select 1 from ld_cvcolumnlist where columnname like '%LD_troubletickets:accountid:account_id:HelpDesk%' and cvid=@cvid);

insert into ld_cvcolumnlist(cvid,columnindex,columnname)select @cvid,4,'LD_troubletickets:status:ticketstatus:HelpDesk_状态:V' from DUAL 
where not exists(select 1 from ld_cvcolumnlist where columnname like '%LD_troubletickets:status:ticketstatus:HelpDesk%' and cvid=@cvid);
delimiter; 
-- 2015-02-05

update ld_salesorder set conversion_rate=1.000000 where currency_id=1;
update ld_servicecontracts set conversion_rate=1.000000 where currency_id=1;
update ld_bankaccountset set conversion_rate=1.000000 where currency_id=1;
update LD_potential set conversion_rate=1.000000 where currency_id=1;
update LD_paymentplan set conversion_rate=1.000000 where currency_id=1;
update LD_cashbill set conversion_rate=1.000000 where currency_id=1;
update LD_purchaseorder set conversion_rate=1.000000 where currency_id=1;
update LD_sendpayment set conversion_rate=1.000000 where currency_id=1;
update LD_sendcashbill set conversion_rate=1.000000 where currency_id=1;
update LD_commission set conversion_rate=1.000000 where currency_id=1;
update LD_expense set conversion_rate=1.000000 where currency_id=1;
update LD_putcash set conversion_rate=1.000000 where currency_id=1;
update LD_cashdeposit set conversion_rate=1.000000 where currency_id=1;
update LD_quotes set conversion_rate=1.000000 where currency_id=1;
update LD_salesback set conversion_rate=1.000000 where currency_id=1;
update LD_purchaseinvoice set conversion_rate=1.000000 where currency_id=1;
update LD_cashback set conversion_rate=1.000000 where currency_id=1;
update LD_purchasecashback set conversion_rate=1.000000 where currency_id=1;
update LD_outboundorder set conversion_rate=1.000000 where currency_id=1;
update LD_stock set conversion_rate=1.000000 where currency_id=1;
update LD_warehousetransfer set conversion_rate=1.000000 where currency_id=1;
update LD_productbom set conversion_rate=1.000000 where currency_id=1;
update LD_checks set conversion_rate=1.000000 where currency_id=1;
update LD_pricebook set conversion_rate=1.000000 where currency_id=1;
update ld_desk set fieldlabel='高级选项' where labelbol='DISPLAY' and languagetype='zh';
update ld_desk set fieldlabel='Advanced options' where labelbol='DISPLAY' and languagetype='en';
-- 2015-02-06

SELECT usereportid into @id from LD_usereport where name='SumSequence';
SELECT tabid into @tid from LD_tab where name='Project';
insert into LD_usereport(usereportid,name,reportlabel,tabids,basicfilter,advfilter,Setcolumns,Parent_id,sequence,reporttype,pagewidthpercent) 
select '','Thestatisticalreportofprojectperformance','项目业绩统计表',@tid,1,0,1,@id,11,5,100 
from dual where not exists(select usereportid from LD_usereport where name='Thestatisticalreportofprojectperformance');
delimiter;


insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'zh','Thestatisticalreportofprojectperformance','{$Project.Project}业绩统计表','fixedstr' from dual where not EXISTS(select 1 from ld_desk where languagetype='zh' and labelbol='Thestatisticalreportofprojectperformance' and Labeltype='fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'en','Thestatisticalreportofprojectperformance','statistical report of {$Project.Project} performance','fixedstr' from dual where not EXISTS(select 1 from ld_desk  where languagetype='en' and labelbol='Thestatisticalreportofprojectperformance' and Labeltype='fixedstr');
delimiter;

select usereportid into @id from LD_usereport where name='Thestatisticalreportofprojectperformance';
insert into LD_usereportbasic(id,Usereportid,columns,Defaultvalue,Sequence) 
select '',@id,'LD_project:actualenddate:actualenddate:Project_actualenddate:D','thisstartmonth~thisendmonth',3  
from dual where not exists(select usereportid from LD_usereportbasic where Usereportid=@id and Sequence=3);

select usereportid into @id from LD_usereport where name='Thestatisticalreportofprojectperformance';
insert into LD_usereportbasic(id,Usereportid,columns,Defaultvalue,Sequence) 
select '',@id,'LD_project:projectstatus:projectstatus:Project_projectstatus:I','',4  
from dual where not exists(select usereportid from LD_usereportbasic where Usereportid=@id and Sequence=4);

select usereportid into @id from LD_usereport where name='Thestatisticalreportofprojectperformance';
insert into LD_usereportbasic(id,Usereportid,columns,Defaultvalue,Sequence) 
select '',@id,'LD_project:progress:progress:Project_progress:I','',5  
from dual where not exists(select usereportid from LD_usereportbasic where Usereportid=@id and Sequence=5);

insert into LD_usereportbasic(id,Usereportid,columns,Defaultvalue,Sequence) 
select '',@id,'ld_account:accountname:accountname:Accounts_accountname:I','',6  
from dual where not exists(select usereportid from LD_usereportbasic where Usereportid=@id and Sequence=6);
delimiter;


select usereportid into @id from LD_usereport where name='Thestatisticalreportofprojectperformance';
insert into LD_UseReportcolumns(id,Usereportid,columns,Sequence,columnshow,realcolumns,realencolumns) 
select '', @id, 'LD_project:projectname:projectname:Project_projectname:V', 1, 1, 'LD_project:projectname:projectname:Project_项目名称:V','LD_project:projectname:projectname:Project_project name:V'   
from dual where not exists(select 1 from LD_UseReportcolumns where Usereportid=@id and realcolumns like 'LD_project:projectname:projectname:Project_%');

insert into LD_UseReportcolumns(id,Usereportid,columns,Sequence,columnshow,realcolumns,realencolumns) 
select '', @id, 'LD_project:project_no:project_no:Project_project_no:V', 2, 1, 'LD_project:project_no:project_no:Project_项目编号:V','LD_project:project_no:project_no:Project_project No:V'   
from dual where not exists(select 1 from LD_UseReportcolumns where Usereportid=@id and realcolumns like 'LD_project:project_no:project_no:Project_%');

insert into LD_UseReportcolumns(id,Usereportid,columns,Sequence,columnshow,realcolumns,realencolumns) 
select '', @id, 'LD_project:lastname:lastname:OftenUseReport_lastname:V', 5, 1, 'LD_project:lastname:lastname:OftenUseReport_销售负责人:V','LD_project:lastname:lastname:OftenUseReport_Person in charge:V'   
from dual where not exists(select 1 from LD_UseReportcolumns where Usereportid=@id and realcolumns like 'LD_project:lastname:lastname:OftenUseReport_%');

insert into LD_UseReportcolumns(id,Usereportid,columns,Sequence,columnshow,realcolumns,realencolumns) 
select '', @id, 'LD_account:accountname:accountname:Accounts_accountname:V', 4, 1, 'LD_account:accountname:accountname:Accounts_客户名称:V','LD_account:accountname:accountname:Accounts_amount of receivables:V'   
from dual where not exists(select 1 from LD_UseReportcolumns where Usereportid=@id and realcolumns like 'LD_account:accountname:accountname:Accounts_%');

insert into LD_UseReportcolumns(id,Usereportid,columns,Sequence,columnshow,realcolumns,realencolumns) 
select '', @id, 'LD_account:last_name:last_name:Accounts_last_name:V', 3, 1, 'LD_account:last_name:last_name:Accounts_项目负责人:V','LD_account:last_name:last_name:Accounts_Person in Account:V'   
from dual where not exists(select 1 from LD_UseReportcolumns where Usereportid=@id and realcolumns like 'LD_account:last_name:last_name:Accounts_%');

insert into LD_UseReportcolumns(id,Usereportid,columns,Sequence,columnshow,realcolumns,realencolumns) 
select '', @id, 'LD_project:startdate:startdate:Project_startdate:D', 6, 1, 'LD_project:startdate:startdate:Project_开始日期:D','LD_project:startdate:startdate:Project_start date:D'   
from dual where not exists(select 1 from LD_UseReportcolumns where Usereportid=@id and realcolumns like 'LD_project:startdate:startdate:Project_%');

insert into LD_UseReportcolumns(id,Usereportid,columns,Sequence,columnshow,realcolumns,realencolumns) 
select '', @id, 'LD_project:projectstatus:projectstatus:Project_projectstatus:V', 7, 1, 'LD_project:projectstatus:projectstatus:Project_状态:V','LD_project:projectstatus:projectstatus:Project_project status:V'   
from dual where not exists(select 1 from LD_UseReportcolumns where Usereportid=@id and realcolumns like 'LD_project:projectstatus:projectstatus:Project_%');

insert into LD_UseReportcolumns(id,Usereportid,columns,Sequence,columnshow,realcolumns,realencolumns) 
select '', @id, 'LD_project:progress:progress:Project_progress:V', 8, 1, 'LD_project:progress:progress:Project_完成进度:V','LD_project:progress:progress:Project_gress:V'   
from dual where not exists(select 1 from LD_UseReportcolumns where Usereportid=@id and realcolumns like 'LD_project:progress:progress:Project_%');

insert into LD_UseReportcolumns(id,Usereportid,columns,Sequence,columnshow,realcolumns,realencolumns) 
select '', @id, 'LD_project:targetenddate:targetenddate:Project_targetenddate:D', 9, 1, 'LD_project:targetenddate:targetenddate:Project_预计完成日期:D','LD_project:targetenddate:targetenddate:Project_targetend date:D'   
from dual where not exists(select 1 from LD_UseReportcolumns where Usereportid=@id and realcolumns like 'LD_project:targetenddate:targetenddate:Project_%');

insert into LD_UseReportcolumns(id,Usereportid,columns,Sequence,columnshow,realcolumns,realencolumns) 
select '', @id, 'LD_project:actualenddate:actualenddate:Project_actualenddate:D', 10, 1, 'LD_project:actualenddate:actualenddate:Project_实际完成日期:D','LD_project:actualenddate:actualenddate:Project_actualend date:D'   
from dual where not exists(select 1 from LD_UseReportcolumns where Usereportid=@id and realcolumns like 'LD_project:actualenddate:actualenddate:Project_%');

insert into LD_UseReportcolumns(id,Usereportid,columns,Sequence,columnshow,realcolumns,realencolumns) 
select '', @id, 'LD_salesorder:salesorder_no:salesorder_no:SalesOrder_salesorder_no:D', 11, 1, 'LD_salesorder:salesorder_no:salesorder_no:SalesOrder_合同订单:D','LD_salesorder:salesorder_no:salesorder_no:SalesOrder_salesorder no:D'   
from dual where not exists(select 1 from LD_UseReportcolumns where Usereportid=@id and realcolumns like 'LD_salesorder:salesorder_no:salesorder_no:SalesOrder_%');

insert into LD_UseReportcolumns(id,Usereportid,columns,Sequence,columnshow,realcolumns,realencolumns) 
select '', @id, 'LD_salesorder:total:total:SalesOrder_total:NN', 12, 1, 'LD_salesorder:total:total:SalesOrder_订单金额:NN','LD_salesorder:total:total:SalesOrder_salesorder total:NN'   
from dual where not exists(select 1 from LD_UseReportcolumns where Usereportid=@id and realcolumns like 'LD_salesorder:total:total:SalesOrder_%');


insert into LD_UseReportcolumns(id,Usereportid,columns,Sequence,columnshow,realcolumns,realencolumns) 
select '', @id, 'LD_cashbill:CashBillamount:CashBillamount:CashBill_CashBillamount:NN', 13, 1, 'LD_cashbill:CashBillamount:CashBillamount:CashBill_已收款:NN','LD_cashbill:CashBillamount:CashBillamount:CashBill_CashBill amount:NN'   
from dual where not exists(select 1 from LD_UseReportcolumns where Usereportid=@id and realcolumns like 'LD_cashbill:CashBillamount:CashBillamount:CashBill_%');

insert into LD_UseReportcolumns(id,Usereportid,columns,Sequence,columnshow,realcolumns,realencolumns) 
select '', @id, 'LD_cashbill:PaymentBalance:PaymentBalance:oftenusereport_PaymentBalance:NN', 14, 1, 'LD_cashbill:PaymentBalance:PaymentBalance:oftenusereport_应收款:NN','LD_cashbill:PaymentBalance:PaymentBalance:oftenusereport_Payment Balance:NN'   
from dual where not exists(select 1 from LD_UseReportcolumns where Usereportid=@id and realcolumns like 'LD_cashbill:PaymentBalance:PaymentBalance:oftenusereport_%');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'zh','DAILYHASBEENSUBMITTED','日报已提交','fixedstr' from dual 
where not EXISTS(select 1 from ld_desk where languagetype='zh' and labelbol='DAILYHASBEENSUBMITTED' and Labeltype='fixedstr'); 
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'en','DAILYHASBEENSUBMITTED','Daily has been submitted','fixedstr' from dual 
where not EXISTS(select 1 from ld_desk where languagetype='en' and labelbol='DAILYHASBEENSUBMITTED' and Labeltype='fixedstr'); 
delimiter; 
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'zh','WEEKLYREPORTHASBEENSUBMITTED','周报已提交','fixedstr' from dual 
where not EXISTS(select 1 from ld_desk where languagetype='zh' and labelbol='WEEKLYREPORTHASBEENSUBMITTED' and Labeltype='fixedstr'); 
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'en','WEEKLYREPORTHASBEENSUBMITTED','Weekly report has been submitted','fixedstr' from dual 
where not EXISTS(select 1 from ld_desk where languagetype='en' and labelbol='WEEKLYREPORTHASBEENSUBMITTED' and Labeltype='fixedstr'); 
delimiter; 

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'zh','REPORTHASBEENSUBMITTED','月报已提交','fixedstr' from dual 
where not EXISTS(select 1 from ld_desk where languagetype='zh' and labelbol='REPORTHASBEENSUBMITTED' and Labeltype='fixedstr'); 
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'en','REPORTHASBEENSUBMITTED','Report has been submitted','fixedstr' from dual 
where not EXISTS(select 1 from ld_desk where languagetype='en' and labelbol='REPORTHASBEENSUBMITTED' and Labeltype='fixedstr'); 
delimiter; 

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'zh','WRITEDAILYREMINDER','提醒写日报','fixedstr' from dual 
where not EXISTS(select 1 from ld_desk where languagetype='zh' and labelbol='WRITEDAILYREMINDER' and Labeltype='fixedstr'); 
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'en','WRITEDAILYREMINDER','Write daily reminder','fixedstr' from dual 
where not EXISTS(select 1 from ld_desk where languagetype='en' and labelbol='WRITEDAILYREMINDER' and Labeltype='fixedstr'); 
delimiter; 

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'zh','WRITEWEEKLYREMINDER','提醒写周报','fixedstr' from dual 
where not EXISTS(select 1 from ld_desk where languagetype='zh' and labelbol='WRITEWEEKLYREMINDER' and Labeltype='fixedstr'); 
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'en','WRITEWEEKLYREMINDER','Write weekly reminder','fixedstr' from dual 
where not EXISTS(select 1 from ld_desk where languagetype='en' and labelbol='WRITEWEEKLYREMINDER' and Labeltype='fixedstr'); 
delimiter; 

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'zh','WRITEMONTHLYREMINDER','提醒写月报','fixedstr' from dual 
where not EXISTS(select 1 from ld_desk where languagetype='zh' and labelbol='WRITEMONTHLYREMINDER' and Labeltype='fixedstr'); 
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'en','WRITEMONTHLYREMINDER','Write monthly reminder','fixedstr' from dual 
where not EXISTS(select 1 from ld_desk where languagetype='en' and labelbol='WRITEMONTHLYREMINDER' and Labeltype='fixedstr'); 
delimiter; 

call AddColumn('ld_attachmentsforbills','uuid','varchar',100,NULL);
call AddColumn('ld_attachmentsforbills','imagefromtype','varchar',100,NULL);
select tabid into @tabid from ld_tab where name='Attachment';
select blockid into @blockid from ld_blocks where blocklabel='LBL_Attachment_INFORMATION';
select max(fieldid) into @maxfieldid from ld_field ;
update ld_field_seq  set id=@maxfieldid+1 where not EXISTS(select 1 from ld_field where tabid=@tabid and columnname='uuid'); 
insert into ld_field(tabid,columnname,tablename,generatedtype,uitype,fieldname,fieldlabel,readonly,presence,
defaultvalue,maximumlength,sequence,block,displaytype,typeofdata,quickcreate,quickcreatesequence,info_type,masseditable,fieldonly,
issmownerid,searchfieldtype,associatedfields,associatedsequence,callchecked)
select @tabid,'uuid','LD_attachmentsforbills',1,1,'uuid','手机id',1,0,'',100,8,@blockid,2,'V~O',3,0,'BAS',0,0,0,1,1,0,0
from dual where not EXISTS(select 1 from ld_field where tabid=@tabid and columnname='uuid');

select max(fieldid) into @maxfieldid from ld_field ;
update ld_field_seq  set id=@maxfieldid+1 where not EXISTS(select 1 from ld_field where tabid=@tabid and columnname='imagefromtype'); 
insert into ld_field(tabid,columnname,tablename,generatedtype,uitype,fieldname,fieldlabel,readonly,presence,
defaultvalue,maximumlength,sequence,block,displaytype,typeofdata,quickcreate,quickcreatesequence,info_type,masseditable,fieldonly,
issmownerid,searchfieldtype,associatedfields,associatedsequence,callchecked)
select @tabid,'imagefromtype','LD_attachmentsforbills',1,1,'imagefromtype','附件来源',1,0,'',100,9,@blockid,2,'V~O',3,0,'BAS',0,0,0,1,1,0,0
from dual where not EXISTS(select 1 from ld_field where tabid=@tabid and columnname='imagefromtype');

select fieldid into @fieldid from ld_field where tabid=@tabid and COLUMNname='uuid';
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'zh','LD_field',@tabid ,@fieldid, '手机id' from dual 
where not EXISTS(select 1 from ld_tranlabel where languagetype='zh' and tabid=@tabid and relateid=@fieldid);

insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'en','LD_field',@tabid ,@fieldid, 'uuid' from dual 
where not EXISTS(select 1 from ld_tranlabel where languagetype='en' and tabid=@tabid and relateid=@fieldid);

select fieldid into @fieldid from ld_field where tabid=@tabid and COLUMNname='imagefromtype';
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'zh','LD_field',@tabid ,@fieldid, '附件来源' from dual 
where not EXISTS(select 1 from ld_tranlabel where languagetype='zh' and tabid=@tabid and relateid=@fieldid);

insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'en','LD_field',@tabid ,@fieldid, 'image from ' from dual 
where not EXISTS(select 1 from ld_tranlabel where languagetype='en' and tabid=@tabid and relateid=@fieldid);
delimiter;

CREATE TABLE if not EXISTS `ld_workreportreader` (
  `workreportreaderid` int(19) NOT NULL AUTO_INCREMENT,
  `userid` int(19) DEFAULT NULL,
  `content` text,
  `Score` int(4) DEFAULT NULL,
  `Workreportid` int(19) DEFAULT NULL,
  `Createdtime` datetime DEFAULT NULL,
  PRIMARY KEY (`workreportreaderid`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
delimiter;

CREATE TABLE if not EXISTS `ld_workreportreader2user` (
  `id` int(19) NOT NULL AUTO_INCREMENT,
  `workreportreaderid` int(19) DEFAULT NULL,
  `userid` int(19) DEFAULT 0,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
delimiter;

CREATE TABLE  if not EXISTS `ld_workreportrelatedto` (
  `id` int(19) NOT NULL AUTO_INCREMENT,
  `Relatedto` int(19) DEFAULT NULL,
  `relatedtab` varchar(50) DEFAULT NULL,
  `workreportid` int(19) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
delimiter;

insert into ld_systems_deploy(deploy_value,deploy_type,description,setype)
select '3',65,'首页组件布局样式','' from dual where not exists
(select 1 from ld_systems_deploy where deploy_type=65);

insert into ld_systems_deploy(deploy_value,deploy_type,description,setype)
select '0',66,'首页默认显示页签','' from dual where not exists
(select 1 from ld_systems_deploy where deploy_type=66);
delimiter;
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype) SELECT 'zh','LBL_HOMECONTROLLAYOUT','系统组件布局','fixedstr' FROM DUAL
WHERE NOT EXISTS(SELECT 1 FROM ld_desk  WHERE languagetype='zh' AND labelbol='LBL_HOMECONTROLLAYOUT' AND Labeltype='fixedstr');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype) SELECT 'en','LBL_HOMECONTROLLAYOUT','The home page component layout style.','fixedstr' FROM DUAL
WHERE NOT EXISTS(SELECT 1 FROM ld_desk  WHERE languagetype='en' AND labelbol='LBL_HOMECONTROLLAYOUT' AND Labeltype='fixedstr');

INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype) SELECT 'zh','LBL_HOMECONTROLSTYLE','首页默认显示页签','fixedstr' FROM DUAL
WHERE NOT EXISTS(SELECT 1 FROM ld_desk  WHERE languagetype='zh' AND labelbol='LBL_HOMECONTROLSTYLE' AND Labeltype='fixedstr');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype) SELECT 'en','LBL_HOMECONTROLSTYLE','The default display label in the home page.','fixedstr' FROM DUAL
WHERE NOT EXISTS(SELECT 1 FROM ld_desk  WHERE languagetype='en' AND labelbol='LBL_HOMECONTROLSTYLE' AND Labeltype='fixedstr');

INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype) SELECT 'zh','LBL_COMPONENTVIEW','组件视图','fixedstr' FROM DUAL
WHERE NOT EXISTS(SELECT 1 FROM ld_desk  WHERE languagetype='zh' AND labelbol='LBL_COMPONENTVIEW' AND Labeltype='fixedstr');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype) SELECT 'en','LBL_COMPONENTVIEW','Component View','fixedstr' FROM DUAL
WHERE NOT EXISTS(SELECT 1 FROM ld_desk  WHERE languagetype='en' AND labelbol='LBL_COMPONENTVIEW' AND Labeltype='fixedstr');

INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype) SELECT 'zh','LBL_COOPERATIVEWORK','工作协同','fixedstr' FROM DUAL
WHERE NOT EXISTS(SELECT 1 FROM ld_desk  WHERE languagetype='zh' AND labelbol='LBL_COOPERATIVEWORK' AND Labeltype='fixedstr');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype) SELECT 'en','LBL_COOPERATIVEWORK','Cooperative Work','fixedstr' FROM DUAL
WHERE NOT EXISTS(SELECT 1 FROM ld_desk  WHERE languagetype='en' AND labelbol='LBL_COOPERATIVEWORK' AND Labeltype='fixedstr');
delimiter;

CREATE TABLE IF NOT EXISTS `ld_workachments` (
  `achmentid` int(19) NOT NULL default '0',
  `name` varchar(255) default '',
  `type` VARCHAR(100) default '',
  `path` text,
  `workreportid` int(19) default '0',
  `workreplyid` int(19) default '0',
  PRIMARY KEY  (`achmentid`),
  KEY `fk_2_ldcrm_workrachments` USING BTREE (`achmentid`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
delimiter;

CALL AddColumn('ld_workreport','approved','int','4',1);
CALL AddColumn('ld_users','reader','int','4',0);
CALL AddColumn('ld_workreport','reader','int','4',0);
delimiter;
update ld_workreport set approved=0 where approved is null or approved='';
delimiter;

set @tabid=48;
update ld_field set presence=0 where tabid=@tabid and columnname='potentialid' and exists (select 1 from ld_tab where `name`='Potentials' and presence<>1);
select sequence into @seq from ld_field where tabid=@tabid and columnname='salesorderid';
update ld_field set sequence=sequence+5 where tabid=@tabid and sequence>=@seq;
update ld_field set sequence=@seq where tabid=@tabid and columnname='potentialid';

select 0 into @i;
update ld_field set sequence=(@i:=@i+1) where tabid=@tabid and block=109 order by sequence;

select fieldlabel into @zh from ld_tranlabel where trantable='LD_tab' and tabid=2 and languagetype='zh' limit 1;
select fieldlabel into @en from ld_tranlabel where trantable='LD_tab' and tabid=2 and languagetype='en' limit 1;

select fieldid into @fieldid from ld_field where tabid=@tabid and columnname='potentialid';
delete from ld_tranlabel where trantable ='LD_field' and tabid=@tabid and relateid=@fieldid; 
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel) 
select 'zh','LD_field',@tabid,@fieldid,@zh; 

insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel) 
select 'en','LD_field',@tabid,@fieldid,@en; 
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'zh','nodata','没有数据','fixedstr' from dual where not EXISTS(select 1 from ld_desk where languagetype='zh' and labelbol='nodata' and Labeltype='fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'en','nodata','No Data','fixedstr' from dual where not EXISTS(select 1 from ld_desk  where languagetype='en' and labelbol='nodata' and Labeltype='fixedstr');
delimiter;
-- 2015-02-10

update ld_field set fieldname='procostprice' where tabid=14 and columnname='costprice';
update ld_productfieldlist set fieldname='procostprice' where fieldname='costprice';
delimiter;

insert into LD_usereport(usereportid,name,reportlabel,tabids,basicfilter,advfilter,Setcolumns,Parent_id,sequence,reporttype,pagewidthpercent) 
select '','XuanYuanLawn','轩辕草坪',0,0,0,0,0,2,0,''  
from dual where not exists(select 1 from LD_usereport where name='XuanYuanLawn');

SELECT usereportid into @id from LD_usereport where name='XuanYuanLawn';
SELECT tabid into @tid from LD_tab where name='Accounts';
insert into LD_usereport(usereportid,name,reportlabel,tabids,basicfilter,advfilter,Setcolumns,Parent_id,sequence,reporttype,pagewidthpercent) 
select '','Xuanyuanlawnbusinessmanagementreport','轩辕草坪业务管理报表',@tid,1,0,2,@id,1,3,100 
from dual where not exists(select usereportid from LD_usereport where name='Xuanyuanlawnbusinessmanagementreport');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'zh','XuanYuanLawn','轩辕草坪','fixedstr' from dual where not EXISTS(select 1 from ld_desk where languagetype='zh' and labelbol='XuanYuanLawn' and Labeltype='fixedstr');

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'en','XuanYuanLawn','Xuan Yuan Lawn','fixedstr' from dual where not EXISTS(select 1 from ld_desk  where languagetype='en' and labelbol='XuanYuanLawn' and Labeltype='fixedstr');

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'zh','Xuanyuanlawnbusinessmanagementreport','轩辕草坪业务管理报表','fixedstr' from dual where not EXISTS(select 1 from ld_desk where languagetype='zh' and labelbol='Xuanyuanlawnbusinessmanagementreport' and Labeltype='fixedstr');

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'en','Xuanyuanlawnbusinessmanagementreport','Xuanyuan lawn business management report','fixedstr' from dual where not EXISTS(select 1 from ld_desk  where languagetype='en' and labelbol='Xuanyuanlawnbusinessmanagementreport' and Labeltype='fixedstr');
delimiter;

select usereportid into @id from LD_usereport where name='Xuanyuanlawnbusinessmanagementreport';
insert into LD_usereportbasic(id,Usereportid,columns,Defaultvalue,Sequence) 
select '',@id,'LD_SalesOrder:signed_data:signed_data:SalesOrder_signed_data:D','thisstartmonth~thisendmonth',3  
from dual where not exists(select usereportid from LD_usereportbasic where Usereportid=@id and Sequence=3);

insert into LD_usereportbasic(id,Usereportid,columns,Defaultvalue,Sequence) 
select '',@id,'LD_accountscf:cf_1428:cf_1428:Accounts_cf_1428:I','',6  
from dual where not exists(select usereportid from LD_usereportbasic where Usereportid=@id and Sequence=6);

insert into LD_usereportbasic(id,Usereportid,columns,Defaultvalue,Sequence) 
select '',@id,'LD_products:productname:productname:Products_productname:I','',9  
from dual where not exists(select usereportid from LD_usereportbasic where Usereportid=@id and Sequence=9);

select usereportid into @id from LD_usereport where name='Xuanyuanlawnbusinessmanagementreport';

insert into LD_UseReportcolumns(id,Usereportid,columns,Sequence,columnshow,realcolumns,realencolumns) 
select '', @id, 'LD_account:accountname:accountname:Accounts_accountname:V', 1, 1, 'LD_account:accountname:accountname:Accounts_客户名称:V','LD_account:accountname:accountname:Accounts_account name:V'   
from dual where not exists(select 1 from LD_UseReportcolumns where Usereportid=@id and realcolumns like 'LD_account:accountname:accountname:Accounts_%');

insert into LD_UseReportcolumns(id,Usereportid,columns,Sequence,columnshow,realcolumns,realencolumns) 
select '', @id, 'LD_account:cf_1519:cf_1519:Accounts_cf_1519:V', 2, 1, 'LD_account:cf_1519:cf_1519:Accounts_项目部:V','LD_account:cf_1519:cf_1519:Accounts_Project Department:V'   
from dual where not exists(select 1 from LD_UseReportcolumns where Usereportid=@id and realcolumns like 'LD_account:cf_1519:cf_1519:Accounts_%');

insert into LD_UseReportcolumns(id,Usereportid,columns,Sequence,columnshow,realcolumns,realencolumns) 
select '', @id, 'LD_account:rating:rating:Accounts_rating:V', 3, 1, 'LD_account:rating:rating:Accounts_客户类型:V','LD_account:rating:rating:Accounts_Account Type:V'   
from dual where not exists(select 1 from LD_UseReportcolumns where Usereportid=@id and realcolumns like 'LD_account:rating:rating:Accounts_%');

insert into LD_UseReportcolumns(id,Usereportid,columns,Sequence,columnshow,realcolumns,realencolumns) 
select '', @id, 'LD_outboundorder:cf_1423:cf_1423:OutboundOrder_cf_1423:V', 4, 1, 'LD_outboundorder:cf_1423:cf_1423:OutboundOrder_应用类型:V','LD_outboundorder:cf_1423:cf_1423:OutboundOrder_Application Type:V'   
from dual where not exists(select 1 from LD_UseReportcolumns where Usereportid=@id and realcolumns like 'LD_outboundorder:cf_1423:cf_1423:OutboundOrder_%');

insert into LD_UseReportcolumns(id,Usereportid,columns,Sequence,columnshow,realcolumns,realencolumns) 
select '', @id, 'LD_outboundorder:cf_1212:cf_1212:OutboundOrder_cf_1212:V', 5, 1, 'LD_outboundorder:cf_1212:cf_1212:OutboundOrder_收货区域:V','LD_outboundorder:cf_1212:cf_1212:OutboundOrder_Receiving Area:V'   
from dual where not exists(select 1 from LD_UseReportcolumns where Usereportid=@id and realcolumns like 'LD_outboundorder:cf_1212:cf_1212:OutboundOrder_%');

insert into LD_UseReportcolumns(id,Usereportid,columns,Sequence,columnshow,realcolumns,realencolumns) 
select '', @id, 'LD_contactdetails:lastname:lastname:Contacts_lastname:V', 6, 1, 'LD_contactdetails:lastname:lastname:Contacts_联系人名称:V','LD_contactdetails:lastname:lastname:Contacts_Contacts Name:V'   
from dual where not exists(select 1 from LD_UseReportcolumns where Usereportid=@id and realcolumns like 'LD_contactdetails:lastname:lastname:Contacts_%');

insert into LD_UseReportcolumns(id,Usereportid,columns,Sequence,columnshow,realcolumns,realencolumns) 
select '', @id, 'LD_outboundorder:outdate:outdate:OutboundOrder_outdate:D', 7, 1, 'LD_outboundorder:outdate:outdate:OutboundOrder_出货日期:D','LD_outboundorder:outdate:outdate:OutboundOrder_Out Date:D'   
from dual where not exists(select 1 from LD_UseReportcolumns where Usereportid=@id and realcolumns like 'LD_outboundorder:outdate:outdate:OutboundOrder_%');

insert into LD_UseReportcolumns(id,Usereportid,columns,Sequence,columnshow,realcolumns,realencolumns) 
select '', @id, 'LD_SalesOrder:signed_data:signed_data:SalesOrder_signed_data:D', 8, 1, 'LD_SalesOrder:signed_data:signed_data:SalesOrder_订单签约时间:D','LD_SalesOrder:signed_data:signed_data:SalesOrder_signed data:D'   
from dual where not exists(select 1 from LD_UseReportcolumns where Usereportid=@id and realcolumns like 'LD_SalesOrder:signed_data:signed_data:SalesOrder_%');

insert into LD_UseReportcolumns(id,Usereportid,columns,Sequence,columnshow,realcolumns,realencolumns) 
select '', @id, 'LD_products:productname:productname:Products_productname:V', 9, 1, 'LD_products:productname:productname:Products_产品名称:V','LD_products:productname:productname:Products_Product Name:V'   
from dual where not exists(select 1 from LD_UseReportcolumns where Usereportid=@id and realcolumns like 'LD_products:productname:productname:Products_%');

insert into LD_UseReportcolumns(id,Usereportid,columns,Sequence,columnshow,realcolumns,realencolumns) 
select '', @id, 'LD_products:cf_1516:cf_1516:Products_cf_1516:V', 21, 1, 'LD_products:cf_1516:cf_1516:Products_品种:V','LD_products:cf_1516:cf_1516:Products_Varieties:V'   
from dual where not exists(select 1 from LD_UseReportcolumns where Usereportid=@id and realcolumns like 'LD_products:cf_1516:cf_1516:Products_%');

insert into LD_UseReportcolumns(id,Usereportid,columns,Sequence,columnshow,realcolumns,realencolumns) 
select '', @id, 'LD_SalesOrder:quantity:quantity:SalesOrder_quantity:N', 11, 1, 'LD_SalesOrder:quantity:quantity:SalesOrder_面积:N','LD_SalesOrder:quantity:quantity:SalesOrder_Varieties:N'   
from dual where not exists(select 1 from LD_UseReportcolumns where Usereportid=@id and realcolumns like 'LD_SalesOrder:quantity:quantity:SalesOrder_%');

insert into LD_UseReportcolumns(id,Usereportid,columns,Sequence,columnshow,realcolumns,realencolumns) 
select '', @id, 'LD_SalesOrder:listprice:listprice:SalesOrder_listprice:NN', 12, 1, 'LD_SalesOrder:listprice:listprice:SalesOrder_单价:NN','LD_SalesOrder:listprice:listprice:SalesOrder_listprice:NN'   
from dual where not exists(select 1 from LD_UseReportcolumns where Usereportid=@id and realcolumns like 'LD_SalesOrder:listprice:listprice:SalesOrder_%');

insert into LD_UseReportcolumns(id,Usereportid,columns,Sequence,columnshow,realcolumns,realencolumns) 
select '', @id, 'LD_SalesOrder:total:total:SalesOrder_total:NN', 13, 1, 'LD_SalesOrder:total:total:SalesOrder_产品合价:NN','LD_SalesOrder:total:total:SalesOrder_total:NN'   
from dual where not exists(select 1 from LD_UseReportcolumns where Usereportid=@id and realcolumns like 'LD_SalesOrder:total:total:SalesOrder_%');

insert into LD_UseReportcolumns(id,Usereportid,columns,Sequence,columnshow,realcolumns,realencolumns) 
select '', @id, 'LD_cashbill:CashBillamount:CashBillamount:CashBill_CashBillamount:NN', 14, 1, 'LD_cashbill:CashBillamount:CashBillamount:CashBill_已收款:NN','LD_cashbill:CashBillamount:CashBillamount:CashBill_CashBill amount:NN'   
from dual where not exists(select 1 from LD_UseReportcolumns where Usereportid=@id and realcolumns like 'LD_cashbill:CashBillamount:CashBillamount:CashBill_%');

insert into LD_UseReportcolumns(id,Usereportid,columns,Sequence,columnshow,realcolumns,realencolumns) 
select '', @id, 'LD_cashbill:PaymentBalance:PaymentBalance:oftenusereport_PaymentBalance:NN', 15, 1, 'LD_cashbill:PaymentBalance:PaymentBalance:oftenusereport_应收款:NN','LD_cashbill:PaymentBalance:PaymentBalance:oftenusereport_Payment Balance:NN'   
from dual where not exists(select 1 from LD_UseReportcolumns where Usereportid=@id and realcolumns like 'LD_cashbill:PaymentBalance:PaymentBalance:oftenusereport_%');

insert into LD_UseReportcolumns(id,Usereportid,columns,Sequence,columnshow,realcolumns,realencolumns) 
select '', @id, 'LD_SalesOrder:cf_1209:cf_1209:SalesOrder_cf_1209:V', 16, 1, 'LD_SalesOrder:cf_1209:cf_1209:SalesOrder_付款方式:V','LD_SalesOrder:cf_1209:cf_1209:SalesOrder_Payment Type:V'   
from dual where not exists(select 1 from LD_UseReportcolumns where Usereportid=@id and realcolumns like 'LD_SalesOrder:cf_1209:cf_1209:SalesOrder_%');

insert into LD_UseReportcolumns(id,Usereportid,columns,Sequence,columnshow,realcolumns,realencolumns) 
select '', @id, 'LD_users:lastname:lastname:OftenUseReport_lastname:V', 17, 1, 'LD_users:lastname:lastname:OftenUseReport_业务负责人:V','LD_users:lastname:lastname:OftenUseReport_Person in charge:V'   
from dual where not exists(select 1 from LD_UseReportcolumns where Usereportid=@id and realcolumns like '%LD_users:lastname:lastname:OftenUseReport_%:V');

insert into LD_UseReportcolumns(id,Usereportid,columns,Sequence,columnshow,realcolumns,realencolumns) 
select '', @id, 'LD_account:cf_1428:cf_1428:Accounts_cf_1428:V', 18, 1, 'LD_account:cf_1428:cf_1428:Accounts_业务人员所属子公司:V','LD_account:cf_1428:cf_1428:Accounts_ye wu ren yuan zi gong si:V'   
from dual where not exists(select 1 from LD_UseReportcolumns where Usereportid=@id and realcolumns like '%LD_account:cf_1428:cf_1428:Accounts_%:V');

insert into LD_UseReportcolumns(id,Usereportid,columns,Sequence,columnshow,realcolumns,realencolumns) 
select '', @id, 'LD_outboundorder:cf_1488:cf_1488:OutboundOrder_cf_1488:V', 19, 1, 'LD_outboundorder:cf_1488:cf_1488:OutboundOrder_基地:V','LD_outboundorder:cf_1488:cf_1488:OutboundOrder_ji di:V'   
from dual where not exists(select 1 from LD_UseReportcolumns where Usereportid=@id and realcolumns like '%LD_outboundorder:cf_1488:cf_1488:OutboundOrder_%:V');

insert into LD_UseReportcolumns(id,Usereportid,columns,Sequence,columnshow,realcolumns,realencolumns) 
select '', @id, 'LD_outboundorder:cf_1401:cf_1401:OutboundOrder_cf_1401:V', 20, 1, 'LD_outboundorder:cf_1401:cf_1401:OutboundOrder_铲出地块:V','LD_outboundorder:cf_1401:cf_1401:OutboundOrder_chan chu ban kuai:V'   
from dual where not exists(select 1 from LD_UseReportcolumns where Usereportid=@id and realcolumns like '%LD_outboundorder:cf_1401:cf_1401:OutboundOrder_%:V');
delimiter;

update ld_desk set fieldlabel='更改模块后会清空已有的列表数据，是否继续？' where labelbol='SWITCHINGMODULEEMPTYLIST' and languagetype='zh';
update ld_code set `status`=0 where exists (select 1 from ld_crmentity_seq where id=2);
update ld_customview set sequence=0 where entitytype='Accounts' and customcategory='NOALLOCATE' and viewname='All';
update ld_systems_deploy set deploy_value=2 where deploy_type=65;
update ld_field set typeofdata='DT~O' where columnname in ('createdtime','modifiedtime') and typeofdata='T~O';

update ld_field set fieldname='procostprice' where tabid=14 and columnname='costprice';
update ld_productfieldlist set fieldname='procostprice' where fieldname='costprice';
delimiter;

update ld_blockdisplay set is_display=1 where exists(select 1 from ld_crmentity_seq where id in (0,2));
-- 2015-02-11
UPDATE ld_usereport SET Setcolumns=1 WHERE name='Xuanyuanlawnbusinessmanagementreport';
delimiter;

SELECT tabid INTO @tabid FROM ld_tab WHERE NAME = 'Project';
SELECT fieldid INTO @fieldid FROM ld_field WHERE tabid = @tabid AND columnname = 'salesorderid';
UPDATE ld_field SET uitype = 102 WHERE fieldid = @fieldid;
UPDATE ld_tranlabel SET fieldlabel = '选择源单' WHERE tabid = @tabid AND relateid = @fieldid AND languagetype = 'zh';
UPDATE ld_tranlabel SET fieldlabel = 'Data sources' WHERE tabid = @tabid AND relateid = @fieldid AND languagetype = 'en';
INSERT INTO LD_fieldmodulerel(fieldid,module,relmodule,STATUS,sequence) 
	SELECT @fieldid,'Project','SalesOrder',0,0 FROM DUAL
WHERE NOT EXISTS(SELECT 1 FROM LD_fieldmodulerel WHERE fieldid= @fieldid AND relmodule='SalesOrder');
INSERT INTO LD_fieldmodulerel(fieldid,module,relmodule,STATUS,sequence) 
	SELECT @fieldid,'Project','ServiceContracts',0,0 FROM DUAL
WHERE NOT EXISTS(SELECT 1 FROM LD_fieldmodulerel WHERE fieldid= @fieldid AND relmodule='ServiceContracts');
delimiter;

DROP PROCEDURE IF EXISTS `f_addTableKeyIndex`;
delimiter ||
CREATE  PROCEDURE `f_addTableKeyIndex`(
	tablename 	VARCHAR(50),
	columnlist 	VARCHAR(50)
)
BEGIN
	SELECT DATABASE() INTO @datebase;
	SET @sql1 = CONCAT('select count(*) into @cnt from information_schema.statistics where table_name=''',tablename,''' and index_name=''PRIMARY''  and table_schema=''',@datebase,'''');
	PREPARE statement_name FROM @sql1;
		EXECUTE statement_name;
	DEALLOCATE PREPARE statement_name;
	IF @cnt = 0 THEN
		SET @sql = CONCAT('alter  table ',tablename,' add  PRIMARY KEY(',columnlist,')' );
		PREPARE statement_name FROM @sql;
			EXECUTE statement_name;
		DEALLOCATE PREPARE statement_name;
	END IF;
END ||
delimiter;
call `f_addTableKeyIndex`('ld_project','projectid');
delimiter;

update ld_tab set presence=1 where `name`='mobileHelpDesk';
ALTER TABLE `ld_workachments` CHANGE `achmentid` `achmentid` INT(19) NOT NULL AUTO_INCREMENT;
INSERT INTO ld_workachments (name, type,path,workreportid) 
SELECT filename,'image',filepath,workreportid  FROM ld_workreport
 where  ld_workreport.workreportid not in(select workreportid from ld_workachments)
 and ld_workreport.filename is not null  and ld_workreport.filename!='';
 delimiter;
-- 2015-02-12

select tabid into @tabid from ld_tab where `name` = 'Reminds';
select fieldid into @fieldid from ld_field where tabid = @tabid and fieldname = 'reltab';
delete from ld_tranlabel where tabid != @tabid and Relateid = @fieldid;
delimiter;

update ld_desk set fieldlabel = '请仔细确认单据信息,是否确认退货入库？' 
where labelbol = 'RETURNSWAREHOUSINGOPERATIONNOTREVERSIBLE' and languagetype = 'zh' and Labeltype = 'jspop';
delimiter;

DROP PROCEDURE IF EXISTS `updatecontactscolumnindex`;
delimiter ||
CREATE  PROCEDURE `updatecontactscolumnindex`(

)
begin

	declare tmp_cvid  int default 0;
	
	declare mycursor cursor for select cvid from ld_customview where entitytype='Contacts'; 
	DECLARE CONTINUE HANDLER FOR SQLSTATE '02000' set tmp_cvid = NULL;
	
	open mycursor;
	fetch mycursor into tmp_cvid;
	while(tmp_cvid is not null) DO
			
			update ld_cvcolumnlist set columnindex=columnindex+100 where cvid=tmp_cvid;
			update ld_cvcolumnlist set columnindex=0 where cvid=tmp_cvid and columnname like 'LD_contactdetails:lastname:lastname:%';
			
			set @i=0;
			update ld_cvcolumnlist set columnindex=(@i:=@i+1) where cvid=tmp_cvid order by columnindex;

			fetch mycursor into tmp_cvid;
	end while;
	close mycursor;
end ||
delimiter;

call updatecontactscolumnindex();
delimiter;

update ld_desk set fieldlabel='许可用户数' where languagetype='zh' and labelbol='LICENSEDUSER';
-- 2015-02-28


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
update lD_version set old_version='V5.9.1' ,current_version='V5.9.1' ,remark='V5.9.1-20150228';
delimiter;