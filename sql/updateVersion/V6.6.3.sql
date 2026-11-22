select tabid into @tabid from ld_tab where `name`='Attachment';
update ld_field set defaultvalue='公开' where  columnname='isenabled' and tabid=@tabid and ifnull(defaultvalue,'')='';
delimiter;
-- 2017-02-06

call del_idx('troubletickets_multi_idx','ld_troubletickets');
call del_idx('parentid_idx','ld_troubletickets');
call del_idx('productid_idx','ld_troubletickets');
delimiter;

INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','WHETHERTOALLOWEDITINGOFDATA','是否允许编辑单据','fixedstr'
from dual where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='WHETHERTOALLOWEDITINGOFDATA');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','WHETHERTOALLOWEDITINGOFDATA','Whether to allow editing of data','fixedstr'
from dual where not exists(select 1 from ld_desk where languagetype='en' and labelbol='WHETHERTOALLOWEDITINGOFDATA');
delimiter;
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','WHETHERTOALLOWANTIAPPROVALOFDATA','是否允许反审批单据','fixedstr'
from dual where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='WHETHERTOALLOWANTIAPPROVALOFDATA');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','WHETHERTOALLOWANTIAPPROVALOFDATA','Whether to allow anti approval of data','fixedstr'
from dual where not exists(select 1 from ld_desk where languagetype='en' and labelbol='WHETHERTOALLOWANTIAPPROVALOFDATA');
delimiter;
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','FAILEDEDITERRORAPPROVING','单据[%s]%s不成功！原因：该单据审批流程设置不允许编辑!','fixedstr'
from dual where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='FAILEDEDITERRORAPPROVING');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','FAILEDEDITERRORAPPROVING','Document[%s] %s no success!Reason:The document approval process setting does not allow editing','fixedstr'
from dual where not exists(select 1 from ld_desk where languagetype='en' and labelbol='FAILEDEDITERRORAPPROVING');
delimiter;

call AddColumn('ld_approve','allowediting','int','1','1');
call AddColumn('ld_approve','allowantiapproval','int','1','1');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,Labeltype)
select 'zh','IMPORTRELATESHIPOR','若字段关系设置为"或"，则任意一个查重字段重复时，会根据选择的重复方式导入数据','fixedstr' from DUAL
where not exists(select 1 from ld_desk where languagetype = 'zh' and labelbol = 'IMPORTRELATESHIPOR' and Labeltype = 'fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,Labeltype)
select 'en','IMPORTRELATESHIPOR','If the field relationship is set to "or", then any duplicate of the search field will import the data according to the selected method','fixedstr' from DUAL
where not exists(select 1 from ld_desk where languagetype = 'en' and labelbol = 'IMPORTRELATESHIPOR' and Labeltype = 'fixedstr');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,Labeltype)
select 'zh','IMPORTRELATESHIPAND','若字段关系设置为"且"，则所有查重字段重复时，会根据选择的重复方式导入数据','fixedstr' from DUAL
where not exists(select 1 from ld_desk where languagetype = 'zh' and labelbol = 'IMPORTRELATESHIPAND' and Labeltype = 'fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,Labeltype)
select 'en','IMPORTRELATESHIPAND','If the field relationship is set to "and", then all the duplicate fields will import the data according to the selected method','fixedstr' from DUAL
where not exists(select 1 from ld_desk where languagetype = 'en' and labelbol = 'IMPORTRELATESHIPAND' and Labeltype = 'fixedstr');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,Labeltype)
select 'zh','SETDUPFIELD','设置查重字段','fixedstr' from DUAL
where not exists(select 1 from ld_desk where languagetype = 'zh' and labelbol = 'SETDUPFIELD' and Labeltype = 'fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,Labeltype)
select 'en','SETDUPFIELD','Set duplicate check fields','fixedstr' from DUAL
where not exists(select 1 from ld_desk where languagetype = 'en' and labelbol = 'SETDUPFIELD' and Labeltype = 'fixedstr');
delimiter;

call AddColumn('ld_contactdetails','uniquenumber','text',NULL,NULL);
delimiter;
-- 2017-02-14

update ld_field set masseditable = 0 where tabid = 6 and columnname in('smcreatorid','servicecasher');
delimiter;

call AddColumn('ld_fund_net','feebeforenet','decimal',20,0);
call AddColumn('ld_fund_net','accumlative_reward','decimal',20,0);
call AddColumn('ld_fund_net','reward_cashbill_money','decimal',20,0);
delimiter;

alter table ld_fund_net modify accumlative_reward decimal(20,3);
alter table ld_fund_net modify feebeforenet decimal(20,4);
alter table ld_fund_net modify reward_cashbill_money decimal(20,3);
delimiter;

select tabid into @tabid from ld_tab where name='fundnet';
select blockid into @blockid from ld_blocks where tabid=@tabid and blocklabel='LBL_FUNDNET_INFO';
insert into ld_field(tabid,fieldid,columnname,tablename,uitype,fieldname,fieldlabel,block,displaytype,presence,typeofdata) 
select @tabid,(select max(fieldid) from ld_field)+1,'feebeforenet','ld_fund_net',1,'feebeforenet','费前净值',@blockid,2,0,'V~O' from dual where not exists 
(select 1 from ld_field where tabid = @tabid and columnname = 'feebeforenet'); 
select fieldid into @fieldid from ld_field where tabid = @tabid and fieldname = 'feebeforenet'; 
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel) 
select 'zh','ld_field',@tabid,@fieldid,'费前净值' from dual 
where not EXISTS(select 1 from ld_tranlabel where languagetype = 'zh' and trantable ='ld_field' and tabid = @tabid and relateid=@fieldid); 
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel) 
select 'en','ld_field',@tabid,@fieldid,'费前净值' from dual 
where not EXISTS(select 1 from ld_tranlabel where languagetype = 'en' and trantable ='ld_field' and tabid = @tabid and relateid=@fieldid); 
delimiter;

select tabid into @tabid from ld_tab where name='fundnet';
select blockid into @blockid from ld_blocks where tabid=@tabid and blocklabel='LBL_FUNDNET_INFO';
insert into ld_field(tabid,fieldid,columnname,tablename,uitype,fieldname,fieldlabel,block,displaytype,presence,typeofdata) 
select @tabid,(select max(fieldid) from ld_field)+1,'accumlative_reward','ld_fund_net',72,'accumlative_reward','累计业绩报酬',@blockid,1,0,'N~O' from dual where not exists 
(select 1 from ld_field where tabid = @tabid and columnname = 'accumlative_reward'); 
select fieldid into @fieldid from ld_field where tabid = @tabid and fieldname = 'accumlative_reward'; 
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel) 
select 'zh','ld_field',@tabid,@fieldid,'累计业绩报酬' from dual 
where not EXISTS(select 1 from ld_tranlabel where languagetype = 'zh' and trantable ='ld_field' and tabid = @tabid and relateid=@fieldid); 
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel) 
select 'en','ld_field',@tabid,@fieldid,'累计业绩报酬' from dual 
where not EXISTS(select 1 from ld_tranlabel where languagetype = 'en' and trantable ='ld_field' and tabid = @tabid and relateid=@fieldid); 
delimiter;

select tabid into @tabid from ld_tab where name='fundnet';
select blockid into @blockid from ld_blocks where tabid=@tabid and blocklabel='LBL_FUNDNET_INFO';
insert into ld_field(tabid,fieldid,columnname,tablename,uitype,fieldname,fieldlabel,block,displaytype,presence,typeofdata) 
select @tabid,(select max(fieldid) from ld_field)+1,'reward_cashbill_money','ld_fund_net',72,'reward_cashbill_money','业绩报酬取现金额',@blockid,1,0,'N~O' from dual where not exists 
(select 1 from ld_field where tabid = @tabid and columnname = 'reward_cashbill_money'); 
select fieldid into @fieldid from ld_field where tabid = @tabid and fieldname = 'reward_cashbill_money'; 
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel) 
select 'zh','ld_field',@tabid,@fieldid,'业绩报酬取现金额' from dual 
where not EXISTS(select 1 from ld_tranlabel where languagetype = 'zh' and trantable ='ld_field' and tabid = @tabid and relateid=@fieldid); 
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel) 
select 'en','ld_field',@tabid,@fieldid,'业绩报酬取现金额' from dual 
where not EXISTS(select 1 from ld_tranlabel where languagetype = 'en' and trantable ='ld_field' and tabid = @tabid and relateid=@fieldid); 
delimiter;

call getallprofile("FundNet");
call getallprofile("FundNet");
delimiter;

call AddColumn('ld_contactdetails','uniquenumber','text','','');
delimiter;

CREATE TABLE IF NOT EXISTS `ld_wx_config` (
  `id`            INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  `name`          VARCHAR(255),
  `description`   VARCHAR(255),
  `time`          INT(14),
  `time_interval` INT(14),
  `switch` VARCHAR(255) DEFAULT 'open'
) ENGINE = InnoDB DEFAULT CHARSET = utf8;
delimiter;

INSERT INTO ld_wx_config (name, description, time, time_interval,switch)
SELECT 'remind_time','提醒时间',0,300,'open' FROM dual
WHERE NOT exists(SELECT 1 FROM ld_wx_config WHERE name = 'remind_time');

INSERT INTO ld_wx_config (name, description, time, time_interval,switch)
SELECT 'bw_helpdesk_time','帮我吧同步服务单时间',0,14400,'close' FROM dual 
WHERE NOT exists(SELECT 1 FROM ld_wx_config WHERE name = 'bw_helpdesk_time');
delimiter;

INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','GETTINGDATAFROMBANGWO8PLEASEWAITFORAMEMENT','正在同步帮我吧服务记录，请稍后……','fixedstr'
from dual where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='GETTINGDATAFROMBANGWO8PLEASEWAITFORAMEMENT');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','GETTINGDATAFROMBANGWO8PLEASEWAITFORAMEMENT','Getting data from bangwo8, Please wait for a moment!','fixedstr'
from dual where not exists(select 1 from ld_desk where languagetype='en' and labelbol='GETTINGDATAFROMBANGWO8PLEASEWAITFORAMEMENT');
delimiter;
-- 2017-02-15

INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','PLEASEUSETHEEXPORTTEMPLATETABLE','（请使用导出模板表格）','fixedstr'
from dual where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='PLEASEUSETHEEXPORTTEMPLATETABLE');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','PLEASEUSETHEEXPORTTEMPLATETABLE','(Please use the export template table)','fixedstr'
from dual where not exists(select 1 from ld_desk where languagetype='en' and labelbol='PLEASEUSETHEEXPORTTEMPLATETABLE');
delimiter;

INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','THECONTACTINFORMATIONISNOTIMPORTED','若联系人查重字段设置为"无"，则不导入联系人信息！','jspop'
from dual where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='THECONTACTINFORMATIONISNOTIMPORTED'  AND Labeltype='jspop');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','THECONTACTINFORMATIONISNOTIMPORTED','If the contact check field is set to "none", the contact information is not imported!','jspop'
from dual where not exists(select 1 from ld_desk where languagetype='en' and labelbol='THECONTACTINFORMATIONISNOTIMPORTED'  AND Labeltype='jspop');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
  select 'zh','CALLCENTERPREFIX','呼叫中心坐席前缀 ','fixedstr' from dual
  where not exists(select 1 from ld_desk where labelbol = 'CALLCENTERPREFIX' and languagetype = 'zh' and labeltype = 'fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
  select 'en','CALLCENTERPREFIX','Call center reclined at the table prefix','fixedstr' from dual
  where not exists(select 1 from ld_desk where labelbol = 'CALLCENTERPREFIX' and languagetype = 'en' and labeltype = 'fixedstr');
delimiter;
-- 2017-02-16

update ld_desk set fieldlabel='如果查重字段之间的关系设置为“或”，那么任一查重字段内容重复就认为记录重复。' 
where labelbol='IMPORTRELATESHIPOR' and languagetype='zh';
update ld_desk set fieldlabel='If the relationship between duplicate fields is “or”, any content of the duplicate fields repeat then considered as the same records.' 
where labelbol='IMPORTRELATESHIPOR' and languagetype='en';
update ld_desk set fieldlabel='如果查重字段之间的关系设置为“且”，那么所有查重字段内容重复才认为记录重复。' 
where labelbol='IMPORTRELATESHIPAND' and languagetype='zh';
update ld_desk set fieldlabel='If the relationship between duplicate fields is “and”, all content of the duplicate fields repeat then considered as the same records.' 
where labelbol='IMPORTRELATESHIPAND' and languagetype='en';
delimiter;

ALTER TABLE ld_account  MODIFY COLUMN nolinkdays int(19);
delimiter;
SELECT tabid into @tabid FROM ld_tab where `name`='Accounts';
UPDATE ld_field set uitype=7,typeofdata='NN~O~13,0' where columnname='nolinkdays' AND tabid=@tabid;
delimiter;
-- 2017-02-17

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','BWHELPDESKSYNC','同步帮我吧','fixedstr' from DUAL
where not exists(select 1 from ld_desk where languagetype = 'zh' and labelbol = 'BWHELPDESKSYNC' and labeltype = 'fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','BWHELPDESKSYNC','Get Data From bangwo8','fixedstr' from DUAL
where not exists(select 1 from ld_desk where languagetype = 'en' and labelbol = 'BWHELPDESKSYNC' and labeltype = 'fixedstr');
delimiter;

select blockid into @blockid from ld_settings_blocks where label = 'LBL_STUDIO';
UPDATE ld_settings_field set active=0 where `name`='LBL_TEMPLATES' AND blockid=@blockid;
delimiter;

select tabid into @tabid from ld_tab where `name` = 'Users';
SELECT sequence into @sequence FROM ld_blocks WHERE blocklabel = 'SOPHO_INTERFACE_INFO' and tabid = @tabid;
set @i=@sequence+1;
update ld_blocks set sequence=(@i:=@i+1) where tabid=@tabid and sequence > @sequence order by sequence asc;
insert into ld_blocks(blockid,tabid,blocklabel,sequence,visible,display_status)
  select (select max(blockid) from ld_blocks)+1,@tabid,'HANTIAN_INTERFACE_INFO',@sequence+1,1,1 from dual
  where not exists (select 1 from ld_blocks where tabid = @tabid and blocklabel = 'HANTIAN_INTERFACE_INFO');
set @j=@sequence;
update ld_blocks set sequence=(@j:=@j+1) where tabid=@tabid and sequence > @sequence order by sequence asc;
update ld_blocks_seq set id = (select max(blockid)+1 from ld_blocks);
select blockid into @blockid from ld_blocks where tabid = @tabid and blocklabel = 'HANTIAN_INTERFACE_INFO';
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
  select 'zh','ld_blocks',@tabid,@blockid ,'汉天呼叫中心设置' from dual
  where not EXISTS(select 1 from ld_tranlabel  where languagetype = 'zh' and trantable ='ld_blocks' and tabid = @tabid and relateid=@blockid);
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
  select 'en','ld_blocks',@tabid,@blockid,'Hantian CallCenter Setting' from dual
  where not EXISTS(select 1 from ld_tranlabel  where languagetype = 'en' and trantable ='ld_blocks' and tabid = @tabid and relateid=@blockid);
call AddColumn('ld_users','hantian_exten','varchar','25',null);
call fieldprofile('Users');
call getallprofile('Users');

insert into ld_field(tabid,fieldid,columnname,tablename,uitype,fieldname,fieldlabel,block,displaytype,presence,typeofdata,generatedtype,sequence,readonly)
  select @tabid,(select max(fieldid) from ld_field)+1,'hantian_exten','ld_users',2,'hantian_exten','分机号',@blockid,1,0,'V~O',2,1,1 from dual
  where not exists (select 1 from ld_field where tabid = @tabid and columnname = 'hantian_exten');
select fieldid into @fieldid from ld_field where tabid = @tabid and fieldname = 'hantian_exten';
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
  select 'zh','ld_field',@tabid,@fieldid,'分机号' from dual
  where not EXISTS(select 1 from ld_tranlabel  where languagetype = 'zh' and trantable ='ld_field' and tabid = @tabid and relateid=@fieldid);
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
  select 'en','ld_field',@tabid,@fieldid,'ExtenNumber' from dual
  where not EXISTS(select 1 from ld_tranlabel  where languagetype = 'en' and trantable ='ld_field' and tabid = @tabid and relateid=@fieldid);

INSERT INTO ld_systems_deploy (deploy_value, deploy_type, description, sequence, presence)
SELECT 'http://',121,'呼叫中心地址',76,0 FROM dual
WHERE NOT exists(SELECT 1 FROM ld_systems_deploy WHERE deploy_type = 121);
delimiter;

insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'zh','ld_systems_deploy',121,121,'呼叫中心地址' from dual
where not exists (select * from ld_tranlabel where languagetype='zh' and trantable='ld_systems_deploy' and relateid=121);
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'en','ld_systems_deploy',121,121,'Call center address' from dual
where not exists (select * from ld_tranlabel where languagetype='en' and trantable='ld_systems_deploy' and relateid=121);
delimiter;

CREATE TABLE IF NOT EXISTS `ld_hantian_phonerecord`(
  `id`        INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  `uniqueid`  VARCHAR(100),
  `userid`     TINYINT(4),
  `usernum`     VARCHAR(25),
  `is_bombscreen` VARCHAR(25),
  `type`      VARCHAR(25),
  `caller`  VARCHAR(25),
  `callee` VARCHAR(25),
  `indexid` INT(11),
  `modulename` VARCHAR(100),
  `recordnum` VARCHAR(100),
  `starttime` DATETIME,
  `deadline` DATETIME,
  `talktime` INT(11)
)ENGINE=InnoDB DEFAULT CHARSET=utf8;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','FAILEDFORORDERISAPPROVINGFORINVEN','单据[%s]%s不成功！原因：该产品已有关联单据！','fixedstr' from DUAL
where not exists(select 1 from ld_desk where languagetype = 'zh' and labelbol = 'FAILEDFORORDERISAPPROVINGFORINVEN' and labeltype = 'fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','FAILEDFORORDERISAPPROVINGFORINVEN','Document[%s]%s delete no success! The reason: The product has associated documents!','fixedstr' from DUAL
where not exists(select 1 from ld_desk where languagetype = 'en' and labelbol = 'FAILEDFORORDERISAPPROVINGFORINVEN' and labeltype = 'fixedstr');
delimiter;

call AddColumn('ld_bangwo8','presence','int','11',0);
update ld_bangwo8 set presence = if(vendorid > 0 ,0,1);
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','NOHELPDESKSERVICERECORD','暂无帮我吧服务记录','jspop' from DUAL
where not exists(select 1 from ld_desk where languagetype = 'zh' and labelbol = 'NOHELPDESKSERVICERECORD' and labeltype = 'jspop');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','NOHELPDESKSERVICERECORD','No helpdesk service record','jspop' from DUAL
where not exists(select 1 from ld_desk where languagetype = 'en' and labelbol = 'NOHELPDESKSERVICERECORD' and labeltype = 'jspop');
delimiter;
-- 2017-02-21

update ld_field set displaytype=1 where tabid=29 and columnname='approveby';
update ld_servicetype set servicetype='其他' where servicetype='其它';
update ld_troubletickets set servicetype='其他' where servicetype='其它';
-- 2017-02-22

update ld_desk set fieldlabel='产品[%s]%s失败！原因：该产品已有关联单据！' where labelbol='FAILEDFORORDERISAPPROVINGFORINVEN' and languagetype='zh';
update ld_desk set fieldlabel='The product "%s" has been used,delete failed！' where labelbol='FAILEDFORORDERISAPPROVINGFORINVEN' and languagetype='en';

insert into ld_cvcolumnlist_wx(modulename,rownumber,listnumber,columnname,type)
  select 'Campaigns',0,0,'ld_campaign:campaignname:campaignname:Campaigns_市场活动:V',2 from dual
  where not exists(select 1 from ld_cvcolumnlist_wx
  where modulename = 'Campaigns' and rownumber=0 AND listnumber=0);
insert into ld_cvcolumnlist_wx(modulename,rownumber,listnumber,columnname)
  select 'Campaigns',1,0,'ld_campaign:smownerid:assigned_user_id:Campaigns_负责人:V' from dual
  where not exists(select 1 from ld_cvcolumnlist_wx
  where modulename = 'Campaigns' and rownumber=1 AND listnumber=0);
insert into ld_cvcolumnlist_wx(modulename,rownumber,listnumber,columnname)
  select 'Campaigns',1,1,'ld_campaign:createdtime:createdtime:Campaigns_创建时间:I' from dual
  where not exists(select 1 from ld_cvcolumnlist_wx
  where modulename = 'Campaigns' and rownumber=1 AND listnumber=1);
insert into ld_cvcolumnlist_wx(modulename,rownumber,listnumber,columnname,type)
  select 'Expense',0,0,'ld_expense:expense_no:expense_no:Expense_fieldlabel:V',2 from dual
  where not exists(select 1 from ld_cvcolumnlist_wx
  where modulename = 'Expense' and rownumber=0 AND listnumber=0);
insert into ld_cvcolumnlist_wx(modulename,rownumber,listnumber,columnname,type)
  select 'Expense',0,1,'ld_expense:accountid:account_id:Expense_fieldlabel:V',2 from dual
  where not exists(select 1 from ld_cvcolumnlist_wx
  where modulename = 'Expense' and rownumber=0 AND listnumber=1);
insert into ld_cvcolumnlist_wx(modulename,rownumber,listnumber,columnname)
  select 'Expense',1,0,'ld_expense:total:hdnGrandTotal:Expense_fieldlabel:V' from dual
  where not exists(select 1 from ld_cvcolumnlist_wx
  where modulename = 'Expense' and rownumber=1 AND listnumber=0);
insert into ld_cvcolumnlist_wx(modulename,rownumber,listnumber,columnname)
  select 'Expense',1,1,'ld_expense:smownerid:assigned_user_id:Expense_fieldlabel:V' from dual
  where not exists(select 1 from ld_cvcolumnlist_wx
  where modulename = 'Expense' and rownumber=1 AND listnumber=1);
insert into ld_cvcolumnlist_wx(modulename,rownumber,listnumber,columnname)
  select 'Expense',1,2,'ld_expense:expensedate:expensedate:Expense_fieldlabel:V' from dual
  where not exists(select 1 from ld_cvcolumnlist_wx
  where modulename = 'Expense' and rownumber=1 AND listnumber=2);
insert into ld_cvcolumnlist_wx(modulename,rownumber,listnumber,columnname,type)
  select 'Commission',0,0,'ld_commission:commission_no:commission_no:Commission_fieldlabel:V',2 from dual
  where not exists(select 1 from ld_cvcolumnlist_wx
  where modulename = 'Commission' and rownumber=0 AND listnumber=0);
insert into ld_cvcolumnlist_wx(modulename,rownumber,listnumber,columnname,type)
  select 'Commission',0,1,'ld_commission:accountid:account_id:Commission_fieldlabel:V',2 from dual
  where not exists(select 1 from ld_cvcolumnlist_wx
  where modulename = 'Commission' and rownumber=0 AND listnumber=1);
insert into ld_cvcolumnlist_wx(modulename,rownumber,listnumber,columnname)
  select 'Commission',1,0,'ld_commission:total:hdnGrandTotal:Commission_fieldlabel:V' from dual
  where not exists(select 1 from ld_cvcolumnlist_wx
  where modulename = 'Commission' and rownumber=1 AND listnumber=0);
insert into ld_cvcolumnlist_wx(modulename,rownumber,listnumber,columnname)
  select 'Commission',1,1,'ld_commission:smownerid:assigned_user_id:Commission_fieldlabel:V' from dual
  where not exists(select 1 from ld_cvcolumnlist_wx
  where modulename = 'Commission' and rownumber=1 AND listnumber=1);
insert into ld_cvcolumnlist_wx(modulename,rownumber,listnumber,columnname)
  select 'Commission',1,2,'ld_commission:expensedate:expensedate:Commission_fieldlabel:V' from dual
  where not exists(select 1 from ld_cvcolumnlist_wx
  where modulename = 'Commission' and rownumber=1 AND listnumber=2);
  
insert into ld_desk (languagetype,labelbol,fieldlabel,labeltype)
select 'zh','BELOW','以下','jspop' from dual 
where not EXISTS(select 1 from ld_desk where  labelbol= 'BELOW' and labeltype='jspop' and languagetype='zh');
insert into ld_desk (languagetype,labelbol,fieldlabel,labeltype)
select 'en','BELOW','Below ','jspop' from dual 
where not EXISTS(select 1 from ld_desk where  labelbol= 'BELOW' and labeltype='jspop' and languagetype='en');
delimiter;
-- 2017-02-24


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

update ld_version set old_version='V6.6.3' ,current_version='V6.6.3' ,remark='V6.6.3-20170224';
delimiter;