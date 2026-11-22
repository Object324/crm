DROP PROCEDURE IF EXISTS `AddPrimaryKey`;
delimiter ||
CREATE  PROCEDURE `AddPrimaryKey`(
	tmp_tablename varchar(100),
	tmp_prikeyname varchar(100)
)
BEGIN
 

	IF EXISTS (SELECT 1 FROM INFORMATION_SCHEMA.KEY_COLUMN_USAGE WHERE TABLE_SCHEMA=DATABASE() AND CONSTRAINT_NAME='PRIMARY' AND TABLE_NAME=tmp_tablename) THEN
		SET @mysql=CONCAT('ALTER TABLE `',tmp_tablename,'` DROP PRIMARY KEY,ADD PRIMARY KEY (`',tmp_prikeyname,'`)');
		PREPARE mystatement FROM @mysql;
		EXECUTE mystatement;
		DEALLOCATE PREPARE mystatement;
	ELSE
		SET @mysql=CONCAT('ALTER TABLE `',tmp_tablename,'` ADD PRIMARY KEY (`',tmp_prikeyname,'`)');
		PREPARE mystatement FROM @mysql;
		EXECUTE mystatement;
		DEALLOCATE PREPARE mystatement;
	END IF;

end ||
delimiter;

insert into ld_appsystem(deploy_value,deploy_type,description,is_open,name,sequence)
select '',4,'是否显示销售助手','no' ,'',0 from dual
where not exists(select 1 from ld_appsystem where deploy_type=4);
delimiter;

insert into ld_appsystem(deploy_value,deploy_type,description,is_open,name,sequence)
select 7,5,'超过N天没有跟进的客户','no' ,'Accounts',0 from dual
where not exists(select 1 from ld_appsystem where deploy_type=5 and name='Accounts');
delimiter;

insert into ld_appsystem(deploy_value,deploy_type,description,is_open,name,sequence)
select 30,5,'预计N天内成交的销售机会','no' ,'Potentials',1 from dual
where not exists(select 1 from ld_appsystem where deploy_type=5 and name='Potentials');
delimiter;

insert into ld_appsystem(deploy_value,deploy_type,description,is_open,name,sequence)
select 7,5,'N天内需要收款的回款计划','no' ,'PaymentPlan',2 from dual
where not exists(select 1 from ld_appsystem where deploy_type=5 and name='PaymentPlan');
delimiter;

insert into ld_appsystem(deploy_value,deploy_type,description,is_open,name,sequence)
select 30,5,'N天内将到期的服务合同','no' ,'ServiceContracts',3 from dual
where not exists(select 1 from ld_appsystem where deploy_type=5 and name='ServiceContracts');
delimiter;

insert into ld_appsystem(deploy_value,deploy_type,description,is_open,name,sequence)
select 7,5,'最近N天将要过生日的联系人','no' ,'Contacts',4 from dual
where not exists(select 1 from ld_appsystem where deploy_type=5 and name='Contacts');
delimiter;

insert into ld_appsystem(deploy_value,deploy_type,description,is_open,name,sequence)
select '',6,'是否显示关键视图','no' ,'',6 from dual
where not exists(select 1 from ld_appsystem where deploy_type=6 and description='是否显示关键视图');
delimiter;

insert into ld_systems_deploy(deploy_value,deploy_type,description,setype,sequence,roottype,inputtype,presence,inputvalue)
select 0,360,'设置移动端登录时已被关联的账号是否允许其他用户继续登录 1:否，0:是','',0,8,'select',0,'[{"value":"0","text":"YES"},{"value":"1","text":"NO"},{"sql":""}]' from dual
where not exists(select 1 from ld_systems_deploy where deploy_type = 360);
set @i=0;
update ld_systems_deploy set sequence=(@i:=@i+1) where roottype=8 ORDER BY sequence;

insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'zh','ld_systems_deploy',360,360,'设置移动端登录时已被关联的账号是否允许其他用户继续登录'
from dual where not EXISTS(select 1 from ld_tranlabel  where languagetype = 'zh'
and trantable ='ld_systems_deploy' and tabid = 360 and relateid=360);
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'en','ld_systems_deploy',360,360,'Set whether the associated account allows other users to continue to log in when the mobile terminal logs in'
from dual where not EXISTS(select 1 from ld_tranlabel  where languagetype = 'en'
and trantable ='ld_systems_deploy' and tabid = 360 and relateid=360);
delimiter;

update ld_desk set fieldlabel='收款额统计收款单金额，根据收款日期计算；签约额统计未作废的合同订单金额和服务合同金额，按照签约日期计算；' where languagetype='zh' and labelbol='SALESGOALINSTRUCTION6' and Labeltype='fixedstr';
update ld_desk set fieldlabel='The amount of statistical bill amount, calculated according to the date of payment; The signing amount of contract amount and service contract amount is not obsolete, calculated in accordance with the date of contract.' where languagetype='en' and labelbol='SALESGOALINSTRUCTION6' and Labeltype='fixedstr';
delimiter;

set @tabid = (select tabid from ld_tab where `name`='CashBill');
update ld_producttoolfield set edit_permission=1,defaultcolumn=2 where tabid=@tabid and columnname='total';
update ld_tabdetailfield set edit_permission=1,defaultcolumn=2 where tabid=@tabid and columnname='total';
delimiter;
set @tabid = (select tabid from ld_tab where `name`='SendCashBill');
update ld_producttoolfield set edit_permission=1,defaultcolumn=2 where tabid=@tabid and columnname='total';
update ld_tabdetailfield set edit_permission=1,defaultcolumn=2 where tabid=@tabid and columnname='total';
delimiter;

set @listid = (select listid from ld_picklist_set where listname = 'express_company' and relatetable = 'ld_field');
set @sequence = (select max(sequence) from ld_picklist_values where listid = @listid);
insert into ld_picklist_values(listid,listvalue,sequence)
select @listid,'顺心捷达',@sequence+1 from dual
where not EXISTS(SELECT 1 from ld_picklist_values where listid = @listid and listvalue = '顺心捷达');
delimiter;

set @sequence = (select max(sequence) from ld_picklist_values where listid = @listid);
insert into ld_picklist_values(listid,listvalue,sequence)
select @listid,'宇鑫物流',@sequence+1 from dual
where not EXISTS(SELECT 1 from ld_picklist_values where listid = @listid and listvalue = '宇鑫物流');
delimiter;

set @sequence = (select max(sequence) from ld_picklist_values where listid = @listid);
insert into ld_picklist_values(listid,listvalue,sequence)
select @listid,'三志物流',@sequence+1 from dual
where not EXISTS(SELECT 1 from ld_picklist_values where listid = @listid and listvalue = '三志物流');
delimiter;

set @sequence = (select max(sequence) from ld_picklist_values where listid = @listid);
insert into ld_picklist_values(listid,listvalue,sequence)
select @listid,'壹米滴答',@sequence+1 from dual
where not EXISTS(SELECT 1 from ld_picklist_values where listid = @listid and listvalue = '壹米滴答');
delimiter;

set @sequence = (select max(sequence) from ld_picklist_values where listid = @listid);
insert into ld_picklist_values(listid,listvalue,sequence)
select @listid,'红滨物流',@sequence+1 from dual
where not EXISTS(SELECT 1 from ld_picklist_values where listid = @listid and listvalue = '红滨物流');
delimiter;

SET @tabid=(SELECT tabid FROM ld_tab WHERE `name`='ModComments');
set @rulename = '主题类型控制显示显示字段';
SET @ruleid=(SELECT id FROM ld_fieldrule WHERE `columnname`='topictype' and tabid=@tabid and rulename=@rulename);
SET @basicsearchid=(SELECT id FROM ld_fieldrulebasicsearch WHERE ruleid=@ruleid and comparator='e' and `value`='回复' limit 1);
insert into ld_fieldrule_operate(columnname,type,`basicsearchid`)
select 'parent_comments','display',@basicsearchid from DUAL
where not EXISTS ( select 1 from ld_fieldrule_operate where columnname = 'parent_comments' and (basicsearchid=@basicsearchid or @basicsearchid is  null) LIMIT 1);
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) 
select 'zh','COLLAPSE','收起','jspop' from dual 
where not EXISTS(select 1 from ld_desk  where languagetype='zh' and labelbol='COLLAPSE' and Labeltype='jspop');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) 
select 'en','COLLAPSE','Collapse','jspop' from dual 
where not EXISTS(select 1 from ld_desk  where languagetype='en' and labelbol='COLLAPSE' and Labeltype='jspop');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) 
select 'zh','EXPANSION','展开','jspop' from dual 
where not EXISTS(select 1 from ld_desk  where languagetype='zh' and labelbol='EXPANSION' and Labeltype='jspop');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) 
select 'en','EXPANSION','Expansion','jspop' from dual 
where not EXISTS(select 1 from ld_desk  where languagetype='en' and labelbol='EXPANSION' and Labeltype='jspop');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) 
select 'zh','COMMENT','评论信息','jspop' from dual 
where not EXISTS(select 1 from ld_desk  where languagetype='zh' and labelbol='COMMENT' and Labeltype='jspop');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) 
select 'en','COMMENT','Comment','jspop' from dual 
where not EXISTS(select 1 from ld_desk  where languagetype='en' and labelbol='COMMENT' and Labeltype='jspop');
delimiter;

update ld_linkmodulecustom set url="gantindex.php?" where url='gantindex.php';
delimiter;

SET FOREIGN_KEY_CHECKS=0;
CALL AddPrimaryKey('ld_salesback','salesbackid');
SET FOREIGN_KEY_CHECKS=1;
-- 2023-01-13

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

UPDATE ld_version SET old_version='V8.4.8.7',current_version='V8.4.8.7',remark='V8.4.8.7-20230113',wx_version='V8.4.8.6';
delimiter;