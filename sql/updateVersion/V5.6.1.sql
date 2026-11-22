insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'zh','DOCUEMNTNUMBERREPEAT','单据编号重复','jspop' from dual 
where not EXISTS(select 1 from ld_desk  where languagetype='zh' and labelbol='DOCUEMNTNUMBERREPEAT' and Labeltype='jspop');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'en','DOCUEMNTNUMBERREPEAT',"Document number repeat",'jspop' from dual 
where not EXISTS(select 1 from ld_desk  where languagetype='en' and labelbol='DOCUEMNTNUMBERREPEAT' and Labeltype='jspop');
delimiter;
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'zh','THEINTIALSEQUENCENUMBERSHOULDBEAPOSSITIVE','起始流水号应该为正整数!','jspop' from dual 
where not EXISTS(select 1 from ld_desk  where languagetype='zh' and labelbol='THEINTIALSEQUENCENUMBERSHOULDBEAPOSSITIVE' and Labeltype='jspop');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'en','THEINTIALSEQUENCENUMBERSHOULDBEAPOSSITIVE',"The initial sequence number should be a positive integer!",'jspop' from dual 
where not EXISTS(select 1 from ld_desk  where languagetype='en' and labelbol='THEINTIALSEQUENCENUMBERSHOULDBEAPOSSITIVE' and Labeltype='jspop');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'zh','PERSONALINFORMATION','个人信息','fixedstr' from dual 
where not EXISTS(select 1 from ld_desk  where languagetype='zh' and labelbol='PERSONALINFORMATION' and Labeltype='fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'en','PERSONALINFORMATION','Personal information','fixedstr' from dual 
where not EXISTS(select 1 from ld_desk  where languagetype='en' and labelbol='PERSONALINFORMATION' and Labeltype='fixedstr');
delimiter;

update ld_desk set Fieldlabel='小计' where labelbol='SUBTOTAL' and languagetype='zh' and Labeltype='fixedstr';
delimiter;

SELECT deploy_value into  @deploy_value from ld_systems_deploy where deploy_type=40;
SELECT id into @wayid from ld_automaticreminds where defaultnum=40;
UPDATE ld_remindway set remindsday=-@deploy_value where wayid=@wayid; 
delimiter;

SELECT deploy_value into  @deploy_value from ld_systems_deploy where deploy_type=41;
SELECT id into @wayid from ld_automaticreminds where defaultnum=41;
UPDATE ld_remindway set remindsday=-@deploy_value where wayid=@wayid; 
delimiter;

update ld_tranlabel set fieldlabel = '出库审核人' where fieldlabel = '确认出库人';
update ld_tranlabel set fieldlabel = '入库审核人' where fieldlabel = '确认入库人';
-- end 2014-08-11

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'zh','CHARACTER','字符','fixedstr' from dual 
where not EXISTS(select 1 from ld_desk  where languagetype='zh' and labelbol='CHARACTER' and Labeltype='fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'en','CHARACTER','Character','fixedstr' from dual 
where not EXISTS(select 1 from ld_desk  where languagetype='en' and labelbol='CHARACTER' and Labeltype='fixedstr');
delimiter;
update ld_desk set Fieldlabel='角色是用来定义可以对系统中哪些模块具备操作权限，角色的层次关系可以视作公司的组织架构' where labelbol='ROLEUSEDDEFINEMODULE' and languagetype='zh' and Labeltype = 'fixedstr';
delimiter;
update ld_tranlabel set fieldlabel = '概率' where languagetype = 'zh' and tabid in (select tabid from ld_tab where name = 'Potentials') and 
Relateid in (select fieldid from LD_field where columnname= 'probability' and tabid in (select tabid from ld_tab where name = 'Potentials') );
delimiter;
update ld_tranlabel set fieldlabel = '个人头像' where languagetype = 'zh' and tabid in (select tabid from ld_tab where name = 'Users') and 
Relateid in (select fieldid from LD_field where columnname= 'imagename' and tabid in (select tabid from ld_tab where name = 'Users') );
delimiter;

SELECT tabid INTO @tabid FROM ld_tab WHERE NAME = 'Accounts';
SELECT tabid INTO @tabid2 FROM ld_tab WHERE NAME = 'ServiceContracts';
INSERT INTO ld_quickactions(tabid,related_tabid,sequence,presence)
SELECT @tabid,@tabid2,6,0 FROM DUAL
WHERE NOT EXISTS(SELECT 1 FROM ld_quickactions  WHERE tabid=@tabid AND related_tabid=@tabid2);
DELIMITER;

select tabid into @tabid from ld_tab where `name` = 'Project';
select fieldid into @fieldid from ld_field where tabid = @tabid and columnname = 'targetenddate';
update ld_field set typeofdata = 'D~O~OTH~GE~startdate~startdate' where tabid = @tabid and fieldid = @fieldid;
delimiter;
select tabid into @tabid from ld_tab where `name` = 'Project';
select fieldid into @fieldid from ld_field where tabid = @tabid and columnname = 'actualenddate';
update ld_field set typeofdata = 'D~O~OTH~GE~startdate~startdate' where tabid = @tabid and fieldid = @fieldid;
delimiter;
select tabid into @tabid from ld_tab where `name` = 'ContactRecords';
select fieldid into @fieldid from ld_field where tabid = @tabid and columnname = 'nextcontactdate';
update ld_field set typeofdata = 'D~O~OTH~GE~contactdate~contactdate' where tabid = @tabid and fieldid = @fieldid;
delimiter;

update ld_tranlabel set fieldlabel = '允许查看客户全景' where languagetype = 'zh' and tabid in (select tabid from ld_tab where name = 'Users') and 
Relateid in (select fieldid from LD_field where columnname= 'accountallview' and tabid in (select tabid from ld_tab where name = 'Users') );
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'zh','ACCOUNTALLVIEWREMIND','(在客户相关的更多信息中允许查询所有数据)','fixedstr' from dual 
where not EXISTS(select 1 from ld_desk  where languagetype='zh' and labelbol='ACCOUNTALLVIEWREMIND' and Labeltype='fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'en','ACCOUNTALLVIEWREMIND','(Allow query all data for more information on customer related)','fixedstr' from dual 
where not EXISTS(select 1 from ld_desk  where languagetype='en' and labelbol='ACCOUNTALLVIEWREMIND' and Labeltype='fixedstr');
delimiter;

update ld_tranlabel set fieldlabel = '是否显示服务信息' where languagetype = 'zh' and tabid in (select tabid from ld_tab where name = 'Users') and 
Relateid in (select fieldid from LD_field where columnname= 'select_servicedetail' and tabid in (select tabid from ld_tab where name = 'Users') );
delimiter;
update ld_tranlabel set fieldlabel = 'Whether to display the information service' where languagetype = 'en' and tabid in (select tabid from ld_tab where name = 'Users') and 
Relateid in (select fieldid from LD_field where columnname= 'select_servicedetail' and tabid in (select tabid from ld_tab where name = 'Users') );
delimiter;
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'zh','SERVICEINFOREMIND','({$Accounts.Accounts}和{$HelpDesk.HelpDesk}明细界面)','fixedstr' from dual 
where not EXISTS(select 1 from ld_desk  where languagetype='zh' and labelbol='SERVICEINFOREMIND' and Labeltype='fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'en','SERVICEINFOREMIND','({$Accounts.Accounts} and {$HelpDesk.HelpDesk}detail interface)','fixedstr' from dual 
where not EXISTS(select 1 from ld_desk  where languagetype='en' and labelbol='SERVICEINFOREMIND' and Labeltype='fixedstr');
delimiter;
update ld_desk set Fieldlabel='只允许使用 jpg、gif、bmp 与 png 格式图片，建议图片大小不超过3M）' where labelbol='ONLYJPGGIFIMG' and languagetype='zh' and Labeltype = 'fixedstr';
update ld_desk set Fieldlabel='(Only jpg, gif, bmp and png images ,Recommended size of not more than 3M)' where labelbol='ONLYJPGGIFIMG' and languagetype='en' and Labeltype = 'fixedstr';
delimiter;


select tabid into @tabid from ld_tab where name='FieldFormulas';
select tabid into @relateid from ld_tab where name='FieldFormulas';
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel) 
select 'zh','LD_tab',@tabid,@relateid,'字段公式' from dual 
where not EXISTS(select 1 from ld_tranlabel where languagetype='zh' and relateid=@relateid and trantable='LD_tab');

insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel) 
select 'en','LD_tab',@tabid,@relateid,'Field Formulas' from dual 
where not EXISTS(select 1 from ld_tranlabel where languagetype='en' and relateid=@relateid and trantable='LD_tab');
delimiter;
select tabid into @tabid from ld_tab where name='MailManager';
select tabid into @relateid from ld_tab where name='MailManager';
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel) 
select 'zh','LD_tab',@tabid,@relateid,'邮件管理' from dual 
where not EXISTS(select 1 from ld_tranlabel where languagetype='zh' and relateid=@relateid and trantable='LD_tab');

insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel) 
select 'en','LD_tab',@tabid,@relateid,'Mail Manager' from dual 
where not EXISTS(select 1 from ld_tranlabel where languagetype='en' and relateid=@relateid and trantable='LD_tab');
delimiter;
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'zh','ZHENCHARACTERS','一个中文占2个字符，一个英文占1个字符','fixedstr' from dual 
where not EXISTS(select 1 from ld_desk  where languagetype='zh' and labelbol='ZHENCHARACTERS' and Labeltype='fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'en','ZHENCHARACTERS','A Chinese account for 2 characters, an English accounted for 1 characters','fixedstr' from dual 
where not EXISTS(select 1 from ld_desk  where languagetype='en' and labelbol='ZHENCHARACTERS' and Labeltype='fixedstr');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'zh','allowtospecifytheapprover','是否允许指定下一步处理人','fixedstr' from dual 
where not EXISTS(select 1 from ld_desk where languagetype='zh' and labelbol='allowtospecifytheapprover' and Labeltype='fixedstr');

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'en','allowtospecifytheapprover','allow to specify the approver','fixedstr' from dual 
where not EXISTS(select 1 from ld_desk  where languagetype='en' and labelbol='allowtospecifytheapprover' and Labeltype='fixedstr');
delimiter;

call addcolumn('ld_approvestep','specifyapproverid','int','18',1);
UPDATE ld_approvestep SET specifyapproverid=1 WHERE specifyapproverid IS NULL;
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'zh','SOURCEMODULE','选择源单','fixedstr' 
from dual where not EXISTS(select 1 from ld_desk where languagetype='zh' and labelbol='SOURCEMODULE' and Labeltype='fixedstr');

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'en','SOURCEMODULE','Select SourceModule','fixedstr' 
from dual where not EXISTS(select 1 from ld_desk  where languagetype='en' and labelbol='SOURCEMODULE' and Labeltype='fixedstr');

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'zh','Billingbalance','开票余额','fixedstr' 
from dual where not EXISTS(select 1 from ld_desk where languagetype='zh' and labelbol='Billingbalance' and Labeltype='fixedstr');

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'en','Billingbalance','Billing balance','fixedstr' 
from dual where not EXISTS(select 1 from ld_desk  where languagetype='en' and labelbol='Billingbalance' and Labeltype='fixedstr');

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'zh','Billingbalance','开票余额','fixedstr' 
from dual where not EXISTS(select 1 from ld_desk where languagetype='zh' and labelbol='Billingbalance' and Labeltype='fixedstr');

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'en','Billingbalance','Billing balance','fixedstr' 
from dual where not EXISTS(select 1 from ld_desk  where languagetype='en' and labelbol='Billingbalance' and Labeltype='fixedstr');
delimiter;

select tabid into @tabid from ld_tab where `name` = 'ProjectTask';
select fieldid into @fieldid from ld_field where tabid = @tabid and columnname = 'enddate';
update ld_field set typeofdata = 'D~O~OTH~GE~startdate~startdate' where tabid = @tabid and fieldid = @fieldid;
delimiter;

update ld_field set fieldname='promodifiedby' where tabid=14 and columnname='modifiedby';
update ld_field set fieldname='promodifiedtime' where tabid=14 and columnname='modifiedtime';

update ld_field set fieldname='procreatedtime' where tabid=14 and columnname='createdtime';
update ld_field set fieldname='procreator' where tabid=14 and columnname='creator';
update ld_field set fieldname='prosmownerid' where tabid=14 and columnname='smownerid';

update ld_tabwithproductview set COLUMNS='LD_products:smownerid:prosmownerid:Products_fieldlabel:V' where COLUMNS like 
'%LD_products:smownerid:assigned_user_id:Products%';

update ld_tabwithproductview set COLUMNS='LD_products:smcreatorid:procreator:Products_fieldlabel:V' where COLUMNS like 
'%LD_products:smcreatorid:creator:Products%';
update ld_tabwithproductview set COLUMNS='LD_products:createdtime:procreatedtime:Products_fieldlabel:V' where COLUMNS like 
'%LD_products:createdtime:createdtime:Products%';

update ld_tabwithproductview set COLUMNS='LD_products:modifiedby:promodifiedby:Products_fieldlabel:V' where COLUMNS like 
'%LD_products:modifiedby:modifiedby:Products%';

update ld_tabwithproductview set COLUMNS='LD_products:modifiedtime:procreatedtime:Products_fieldlabel:V' where COLUMNS like 
'%LD_products:modifiedtime:modifiedtime:Products%';
delimiter;

INSERT INTO ld_systems_deploy(deploy_value,deploy_type,description,setype)
SELECT '2',49,'单据明细中数量小数位数','' FROM DUAL WHERE NOT EXISTS
(SELECT 1 FROM ld_systems_deploy WHERE deploy_type=49);
DELIMITER;

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
DELIMITER;

ALTER TABLE ld_inventoryproductrel MODIFY quantity DECIMAL(25,8);
DELIMITER;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'zh','COMBINATION','组合','fixedstr' from dual 
where not EXISTS(select 1 from ld_desk  where languagetype='zh' and labelbol='COMBINATION' and Labeltype='fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'en','COMBINATION','Combination','fixedstr' from dual 
where not EXISTS(select 1 from ld_desk  where languagetype='en' and labelbol='COMBINATION' and Labeltype='fixedstr');
delimiter;
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'zh','FORMATERROR','格式错误','jspop' from dual 
where not EXISTS(select 1 from ld_desk  where languagetype='zh' and labelbol='FORMATERROR' and Labeltype='jspop');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'en','FORMATERROR',"Format error",'jspop' from dual 
where not EXISTS(select 1 from ld_desk  where languagetype='en' and labelbol='FORMATERROR' and Labeltype='jspop');
delimiter;


alter table ld_campaign modify column targetsize decimal(25,2);
update ld_field set typeofdata='N~O' where tabid=26 and columnname='targetsize';
-- end 2014-08-14

select tabid into @tabid from ld_tab where name = 'Commission';
update ld_field set defaultvalue = 'thistoday' where tabid = @tabid and fieldname = 'expensedate';
delimiter;

select tabid into @tabid from ld_tab where name = 'ContactRecords';
update ld_field set defaultvalue = 'thistoday' where tabid = @tabid and fieldname = 'contactdate';
delimiter;

select tabid into @tabid from ld_tab where name = 'CashBill';
update ld_field set defaultvalue = 'thistoday' where tabid = @tabid and fieldname = 'cashbilldate';
delimiter;

UPDATE ld_desk SET Fieldlabel='允许结束审批流程' WHERE labelbol='WHETHERAPPROVALPROCESS' AND languagetype='zh' AND Labeltype='fixedstr';

UPDATE ld_desk SET Fieldlabel='允许审批步骤' WHERE labelbol='WHETHERAPPROVALSTEP' AND languagetype='zh' AND Labeltype='fixedstr';

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'zh','specifytheapproval','允许指定审批人','fixedstr' 
from dual where not EXISTS(select 1 from ld_desk where languagetype='zh' and labelbol='specifytheapproval' and Labeltype='fixedstr');

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'en','specifytheapproval','Allow specify approval','fixedstr' 
from dual where not EXISTS(select 1 from ld_desk  where languagetype='en' and labelbol='specifytheapproval' and Labeltype='fixedstr');

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'zh','nextstepofapproval','下一步骤的审批人','fixedstr' 
from dual where not EXISTS(select 1 from ld_desk where languagetype='zh' and labelbol='nextstepofapproval' and Labeltype='fixedstr');

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'en','nextstepofapproval','next step approval','fixedstr' 
from dual where not EXISTS(select 1 from ld_desk  where languagetype='en' and labelbol='nextstepofapproval' and Labeltype='fixedstr');
delimiter;


update ld_tranlabel set fieldlabel = '是否允许查看服务到期日' where languagetype = 'zh' and tabid in (select tabid from ld_tab where name = 'Users') and 
Relateid in (select fieldid from LD_field where columnname= 'select_due_date' and tabid in (select tabid from ld_tab where name = 'Users') );
delimiter;
update ld_tranlabel set fieldlabel = 'Whether to allow the service maturity' where languagetype = 'en' and tabid in (select tabid from ld_tab where name = 'Users') and 
Relateid in (select fieldid from LD_field where columnname= 'select_due_date' and tabid in (select tabid from ld_tab where name = 'Users') );
delimiter;
UPDATE ld_desk set Fieldlabel='（在客户相关信息中允许查询所有数据）' where labelbol='ACCOUNTALLVIEWREMIND' and languagetype='zh';
UPDATE ld_desk set Fieldlabel='(Allow query all data in the customer related information)' where labelbol='ACCOUNTALLVIEWREMIND' and languagetype='en';
delimiter;
UPDATE ld_desk set Fieldlabel='关联产品明细信息时是否显示"成本价"和"GP(毛利率 %)"' where labelbol='PRODUCTSETLABEL' and languagetype='zh' and Labeltype = 'fixedstr';
UPDATE ld_desk set Fieldlabel="Whether to display 'Cost Price' and 'GP(Cost Profit %)' when relate to products details" where labelbol='PRODUCTSETLABEL' and languagetype='en' and Labeltype = 'fixedstr';
delimiter;
-- end 2014-08-15

CALL addfldcrmentityinfo('LessionPlan');
delimiter;

update ld_field set defaultvalue=NULL where tabid=48 and columnname in ('targetenddate','actualenddate');

UPDATE ld_usereport SET reporttype=4 WHERE name='Performancestatisticscollection';
delimiter;

UPDATE ld_desk SET Fieldlabel='允许指定下一步审批人' WHERE labelbol='specifytheapproval' AND languagetype='zh' AND Labeltype='fixedstr';
delimiter;

UPDATE ld_desk SET Fieldlabel='是否允许指定审批步骤' WHERE labelbol='WHETHERAPPROVALSTEP' AND languagetype='zh' AND Labeltype='fixedstr';
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'zh','editingprocess','编辑步骤','fixedstr' 
from dual where not EXISTS(select 1 from ld_desk where languagetype='zh' and labelbol='editingprocess' and Labeltype='fixedstr');

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'en','editingprocess','editing process','fixedstr' 
from dual where not EXISTS(select 1 from ld_desk  where languagetype='en' and labelbol='editingprocess' and Labeltype='fixedstr');

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'zh','editingprocessd','指定审批步骤','fixedstr' 
from dual where not EXISTS(select 1 from ld_desk where languagetype='zh' and labelbol='editingprocessd' and Labeltype='fixedstr');

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'en','editingprocessd','editing process','fixedstr' 
from dual where not EXISTS(select 1 from ld_desk  where languagetype='en' and labelbol='editingprocessd' and Labeltype='fixedstr');
delimiter;

DELETE FROM ld_usereportcolumns WHERE Usereportid=22 AND columns LIKE '%LD_commission2payment:CommissionTotal:CommissionTotal:OftenUseReport_%';

select usereportid into @id from LD_usereport where name='Performancestatisticscollection';
insert into LD_UseReportcolumns(id,Usereportid,columns,Sequence,columnshow,realcolumns,realencolumns) 
select '', @id, 'LD_commission2payment:CommissionTotal:CommissionTotal:OftenUseReport_CommissionTotal:NN', 12, 1, 
'LD_commission2payment:CommissionTotal:CommissionTotal:OftenUseReport_佣金合计:NN',
'LD_commission2payment:CommissionTotal:CommissionTotal:OftenUseReport_Commission Total:NN'   
from dual where not exists(select 1 from LD_UseReportcolumns where Usereportid=@id and 
realcolumns='LD_commission2payment:CommissionTotal:CommissionTotal:OftenUseReport_佣金合计:NN');
delimiter;


select tabid into @tabid from ld_tab where `name` = 'PublicAnnouncement';
select fieldid into @fieldid from ld_field where tabid = @tabid and columnname = 'enddate';
update ld_field set typeofdata = 'D~O~OTH~GE~startdate~startdate' where tabid = @tabid and fieldid = @fieldid;
delimiter;
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'zh','CHARACTERLENGTH','字符长度应该为大于0的整数！','jspop' 
from dual where not EXISTS(select 1 from ld_desk where languagetype='zh' and labelbol='CHARACTERLENGTH' and Labeltype='jspop');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'en','CHARACTERLENGTH','Character length should be an integer greater than 0!','jspop' 
from dual where not EXISTS(select 1 from ld_desk  where languagetype='en' and labelbol='CHARACTERLENGTH' and Labeltype='jspop');
delimiter;

SELECT tabid into @tabid  from ld_tab where name='HelpDesk';
SELECT blockid into @blockid  from ld_blocks where tabid=@tabid and blocklabel='LBL_DESCRIPTION_INFORMATION';
UPDATE ld_tranlabel set fieldlabel='问题描述信息' where tabid=@tabid and trantable='LD_blocks' and languagetype='zh' and Relateid=@blockid;
UPDATE ld_tranlabel set fieldlabel='Problem description information' where tabid=@tabid and trantable='LD_blocks' and languagetype='en' and Relateid=@blockid;
SELECT fieldid into @fieldid from ld_field where tabid=@tabid and columnname='description';
UPDATE ld_tranlabel set fieldlabel='问题描述' where tabid=@tabid and trantable='LD_field' and languagetype='zh' and Relateid=@fieldid;
UPDATE ld_tranlabel set fieldlabel='Problem description' where tabid=@tabid and trantable='LD_field' and languagetype='en' and Relateid=@fieldid;
delimiter;

update ld_tranlabel set fieldlabel = '客户服务单' where languagetype = 'zh' and tabid in (select tabid from ld_tab where name = 'HelpDesk') 
and Relateid in (select tabid from ld_tab where name = 'HelpDesk') and trantable = 'LD_tab';
delimiter;
update ld_tranlabel set fieldlabel = 'Account Trouble Tickets' where languagetype = 'en' and tabid in (select tabid from ld_tab where name = 'HelpDesk') 
and Relateid in (select tabid from ld_tab where name = 'HelpDesk') and trantable = 'LD_tab';
delimiter;
update ld_desk set Fieldlabel='（只允许使用 jpg、gif、bmp 与 png 格式图片，建议图片大小不超过3M）' where labelbol='ONLYJPGGIFIMG' and languagetype='zh' and Labeltype = 'fixedstr';
delimiter;
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'zh','PROCESSINFO','流程信息','fixedstr' from dual 
where not EXISTS(select 1 from ld_desk  where languagetype='zh' and labelbol='PROCESSINFO' and Labeltype='fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'en','PROCESSINFO','Process Information','fixedstr' from dual 
where not EXISTS(select 1 from ld_desk  where languagetype='en' and labelbol='PROCESSINFO' and Labeltype='fixedstr');
delimiter;
-- end 2014-08-18 

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'zh','STATISTICALDISTRIBUTION','分布统计','fixedstr' from dual 
where not EXISTS(select 1 from ld_desk  where languagetype='zh' and labelbol='STATISTICALDISTRIBUTION' and Labeltype='fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'en','STATISTICALDISTRIBUTION','Statistical distribution','fixedstr' from dual 
where not EXISTS(select 1 from ld_desk  where languagetype='en' and labelbol='STATISTICALDISTRIBUTION' and Labeltype='fixedstr');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'zh','OPENMODULE','开启','fixedstr' from dual 
where not EXISTS(select 1 from ld_desk  where languagetype='zh' and labelbol='OPENMODULE' and Labeltype='fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'en','OPENMODULE','Open','fixedstr' from dual 
where not EXISTS(select 1 from ld_desk  where languagetype='en' and labelbol='OPENMODULE' and Labeltype='fixedstr');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'zh','REMOVECOMBINATION','删除组合','fixedstr' from dual 
where not EXISTS(select 1 from ld_desk  where languagetype='zh' and labelbol='REMOVECOMBINATION' and Labeltype='fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'en','REMOVECOMBINATION','Remove combination','fixedstr' from dual 
where not EXISTS(select 1 from ld_desk  where languagetype='en' and labelbol='REMOVECOMBINATION' and Labeltype='fixedstr');
delimiter;

update ld_tranlabel set fieldlabel = '优先级别' where languagetype = 'zh' and tabid in (select tabid from ld_tab where name = 'HelpDesk') 
and Relateid in (select fieldid from ld_field where columnname= 'priority' and tabid in (select tabid from ld_tab where name = 'HelpDesk') );
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'zh','MODULENAMECANNOTBEEMPTY','模块中英文名称不能为空!','jspop' from dual 
where not EXISTS(select 1 from ld_desk  where languagetype='zh' and labelbol='MODULENAMECANNOTBEEMPTY' and Labeltype='jspop');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'en','MODULENAMECANNOTBEEMPTY','Module English name and Chinese name cannot be empty!','jspop' from dual 
where not EXISTS(select 1 from ld_desk  where languagetype='en' and labelbol='MODULENAMECANNOTBEEMPTY' and Labeltype='jspop');
delimiter;
-- end 2014-08-19

update ld_field_seq set id=(select max(fieldid) from ld_field);
update ld_blocks_seq set id=(select max(blockid) from ld_blocks);
update ld_relatedlists_seq set id=(select max(relation_id) from ld_relatedlists);
update ld_customview_seq set id = (select max(cvid) from ld_customview);
update ld_links_seq set id=(select max(linkid) from ld_links);
update ld_picklist_dependency_seq set id=(select max(id) from ld_picklist_dependency);
update ld_crmentity_seq set id=(select max(crmid) from ld_crmentity);
update ld_approve_seq set id=(select max(id) from ld_approve);
update ld_approvestep_seq set id=(select max(id) from ld_approvestep);
update lD_version set old_version='V5.6.1' ,current_version='V5.6.1' ,remark='V5.6.1-20140819';
delimiter;