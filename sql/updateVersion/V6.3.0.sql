call AddColumn('ld_account','potentialid','int','11',0);
delimiter;

select tabid into @tabid from ld_tab where `name` = 'Accounts';
update ld_field set columnname = 'potentialid',fieldname='potential_id',uitype='76'
where tabid = @tabid and columnname ='lastpotential' and fieldname = 'lastpotential';
delimiter;
-- 2016-02-17

update (
	select t.potentialid,t.accountid from (
		select potentialid,accountid from ld_potential where accountid>0 order by accountid,createdtime desc) as t group by t.accountid)
as f LEFT JOIN ld_account on f.accountid=ld_account.accountid set ld_account.potentialid=f.potentialid;
-- 2016-02-18

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
delimiter;

update ld_version set old_version='V6.2.1' ,current_version='V6.2.1' ,remark='V6.2.1-20160218(V6.2.0SP1)';
delimiter;

call AddColumn('ld_expensetype','debitsubjectid','int','11',0);
delimiter;
call AddColumn('ld_expensetype','creditsubjectid','int','11',0);
delimiter;
-- 2016-02-19


select tabsequence into @seq1 from ld_tab where `name`='BankCash';
update ld_tab set tabsequence=@seq1+1 where `name`='BankAccountSet';
update ld_tab set tabsequence=@seq1+2 where `name`='OftenUseReport';

set @i=0;
update ld_tab set tabsequence=(@i:=@i+1) order by tabsequence,tabid;
delimiter;
-- 2016-02-23


CALL AddColumn('ld_contactdetails','approveby','int','19','0');
delimiter;

CALL AddColumn('ld_contactdetails','approvestatus','varchar','200',NULL);
alter table ld_contactdetails alter approvestatus set default '未提交';
delimiter;

SELECT tabid into @tabid from ld_tab WHERE `name` = 'Contacts';
insert into ld_field(tabid,fieldid,columnname,tablename,generatedtype,uitype,fieldname,fieldlabel,readonly,block,displaytype,presence,typeofdata)
select @tabid,(select max(fieldid) from ld_field)+1,'approvestatus','ld_contactdetails',1,130,'approvestatus','审批状态',1,(select blockid from ld_blocks where blocklabel = 'LBL_CONTACT_INFORMATION'),2,0,'V~O' from dual where not exists
(select 1 from ld_field where tabid = @tabid and columnname = 'approvestatus');

insert into ld_field(tabid,fieldid,columnname,tablename,generatedtype,uitype,fieldname,fieldlabel,readonly,block,displaytype,presence,typeofdata)
select @tabid,(select max(fieldid) from ld_field)+1,'approveby','ld_contactdetails',1,131,'approveby','审批人',1,(select blockid from ld_blocks where blocklabel = 'LBL_CONTACT_INFORMATION'),2,2,'V~O' from dual where not exists
(select 1 from ld_field where tabid = @tabid and columnname = 'approveby');

SELECT fieldid INTO @Relateid from ld_field WHERE tabid = @tabid AND columnname = 'approvestatus';
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'zh','ld_field',@tabid,@Relateid,'审批状态'
from dual where not EXISTS(select 1 from ld_tranlabel  where languagetype = 'zh'
and trantable ='ld_field' and tabid = @tabid and relateid=@Relateid);
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'en','ld_field',@tabid,@Relateid,'Approve Status'
from dual where not EXISTS(select 1 from ld_tranlabel  where languagetype = 'en'
and trantable ='ld_field' and tabid = @tabid and relateid=@Relateid);

SELECT fieldid INTO @Relateid from ld_field WHERE tabid = @tabid AND columnname = 'approveby';
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'zh','ld_field',@tabid,@Relateid,'审批人'
from dual where not EXISTS(select 1 from ld_tranlabel  where languagetype = 'zh'
and trantable ='ld_field' and tabid = @tabid and relateid=@Relateid);
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'en','ld_field',@tabid,@Relateid,'Approver'
from dual where not EXISTS(select 1 from ld_tranlabel  where languagetype = 'en'
and trantable ='ld_field' and tabid = @tabid and relateid=@Relateid);
delimiter;

SELECT MAX(sequence) INTO @sequence FROM ld_systems_deploy;
INSERT INTO ld_systems_deploy(deploy_value,deploy_type,description,setype,sequence)
SELECT '0',94,'联系人是否启用审批流程。1:否，0:是','Contacts',@sequence+1
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM ld_systems_deploy WHERE deploy_type = 94);
delimiter;

SELECT MAX(id) INTO @id from ld_approve;
SELECT tabid INTO @tabid FROM ld_tab WHERE `name` = 'Contacts';
INSERT INTO ld_approve(id,tabid,name,description,status,smcreatorid,modifiedby,createdtime,modifiedtime,approveallocatetype)
SELECT @id+1,@tabid,'联系人二级审批流程','联系人预置二级审批流程',0,1,1,current_timestamp(),current_timestamp(),0
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM ld_approve WHERE tabid = @tabid AND name = '联系人二级审批流程');
delimiter;

SELECT id INTO @approveid FROM ld_approve WHERE `name` = '联系人二级审批流程';
SELECT MAX(id) INTO @id FROM ld_approvestep;
INSERT INTO ld_approvestep (id,approveid,name,description,ended,step,sequence,createdtime,modifiedtime,approvetype,approvevalue,specifyapproverid)
SELECT @id+1,@approveid,'一级审批','',1,1,1,current_timestamp(),current_timestamp(),0,1,1
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM ld_approvestep WHERE approveid = @approveid AND sequence = 1);

SELECT MAX(id) INTO @id FROM ld_approvestep;
INSERT INTO ld_approvestep (id,approveid,name,description,ended,step,sequence,createdtime,modifiedtime,approvetype,approvevalue,specifyapproverid)
SELECT @id+1,@approveid,'二级审批','',1,1,2,current_timestamp(),current_timestamp(),0,1,1
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM ld_approvestep WHERE approveid = @approveid AND sequence = 2);
delimiter;

update ld_desk set fieldlabel = '帐户设置' where labelbol = 'LBL_SETTINGS' and languagetype = 'zh' and fieldlabel = '账户设置';
delimiter;

select max(sequence) into @sequence from ld_systems_deploy;
insert into ld_systems_deploy(deploy_value,deploy_type,description,sequence)
select 0,92,'订单同步接口触发点',@sequence from dual
where not exists(select 1 from ld_systems_deploy where deploy_type = 92);
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','The trigger point of the data interface about sales orders','订单同步接口触发点','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='The trigger point of the data interface about sales orders' and labeltype = 'fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','The trigger point of the data interface about sales orders','The trigger point of the data interface about sales orders','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='The trigger point of the data interface about sales orders' and labeltype = 'fixedstr');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','Approvals','审批通过','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='Approvals' and labeltype = 'fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','Approvals','Approval','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='Approvals' and labeltype = 'fixedstr');
delimiter;

alter table ld_inventoryproductrel modify column `comment` text(0);
delimiter;

alter table ld_inventoryproductrel modify column `remark` text(0);
delimiter;

call AddColumn('ld_users','is_mobile_style','int','2',0);
delimiter;

alter table ld_users alter column is_mobile_style set default '1';
delimiter;

update ld_users set is_mobile_style=1;

select tabid into @tabid from ld_tab where `name` = 'Users';
select blockid into @blockid from ld_blocks where blocklabel = 'LBL_USER_DATAACCESS' and tabid = @tabid;
select max(fieldid) into @fieldid from ld_field;
select max(sequence) into @sequence from ld_field where tabid = @tabid and block = @blockid;
insert into ld_field(tabid,fieldid,columnname,tablename,generatedtype,uitype,fieldname,fieldlabel,readonly,presence,sequence,block,displaytype,typeofdata,quickcreate,quickcreatesequence,info_type,masseditable)
select @tabid,@fieldid+1,'is_mobile_style','ld_users',1,56,'is_mobile_style','手机号码显示样式根据系统参数控制',0,0,@sequence+1,@blockid,1,'V~O',3,0,'BAS',2 from DUAL
where not exists(select 1 from ld_field where tabid = @tabid and columnname = 'is_mobile_style' and fieldname = 'is_mobile_style');
delimiter;
update ld_field_seq set id = (select max(fieldid) from ld_field);
delimiter;

select tabid into @tabid from ld_tab where `name` = 'Users';
select fieldid into @fieldid from ld_field where tabid = @tabid and columnname = 'is_mobile_style' and fieldname = 'is_mobile_style';
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'zh','ld_field',@tabid,@fieldid,'手机号码显示样式根据系统参数控制' from DUAL
where not exists(select 1 from ld_tranlabel where languagetype = 'zh' and tabid = @tabid and relateid = @fieldid);
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'en','ld_field',@tabid,@fieldid,'Phone num style according to parameters' from DUAL
where not exists(select 1 from ld_tranlabel where languagetype = 'en' and tabid = @tabid and relateid = @fieldid);
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','Allowtoeditotherusersmobile','允许编辑其他用户单据的手机号码字段','jspop' from DUAL
where not exists(select 1 from ld_desk where languagetype= 'zh' and labelbol = 'Allowtoeditotherusersmobile' and labeltype = 'jspop');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','Allowtoeditotherusersmobile','Allow to edit other users mobile','jspop' from DUAL
where not exists(select 1 from ld_desk where languagetype= 'en' and labelbol = 'Allowtoeditotherusersmobile' and labeltype = 'jspop');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','phonenumstyleaccordingtoparameters','手机号码显示样式根据系统参数控制','jspop' from DUAL
where not exists(select 1 from ld_desk where languagetype= 'zh' and labelbol = 'phonenumstyleaccordingtoparameters' and labeltype = 'jspop');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','phonenumstyleaccordingtoparameters','Phone num style according to parameters','jspop' from DUAL
where not exists(select 1 from ld_desk where languagetype= 'en' and labelbol = 'phonenumstyleaccordingtoparameters' and labeltype = 'jspop');
delimiter;

update ld_field set defaultvalue=1 where tabid=29 and columnname='is_mobile_style';
delimiter;
-- 2015-02-26


call getallprofile('Contacts');
delimiter;
call fieldprofile('Contacts');
delimiter;

call getallprofile('Potentials');
delimiter;
call fieldprofile('Potentials');
delimiter;


select tabid into @tabid from ld_tab where name='dividendorder';
update ld_field set displaytype=2 where tabid=@tabid and (columnname='actualdividend_date' or  columnname='cashmoney');
select max(relation_id) into @relation_id from ld_relatedlists  ;
select tabid into @dividendordertabid from ld_tab where name='dividendorder';
update ld_relatedlists_seq set id=@relation_id+1 where not exists(select 1 from ld_relatedlists where tabid=@dividendordertabid and name='get_dividendorderDetail');
insert into ld_relatedlists(relation_id,tabid,name,related_tabid,sequence,label,presence,mobile_presence,mobile_sequence)
select @relation_id+1,@dividendordertabid,'get_dividendorderDetail',0,2,'DividendOrder',0,1,1 from DUAL
where not exists(select 1 from ld_relatedlists where tabid=@dividendordertabid and name='get_dividendorderDetail');
delimiter;

select usereportid into @usereportid from ld_usereport where `name` = 'Thestatisticalreportofprojectperformance';
update ld_usereportbasic set `columns` = 'ld_project:startdate:startdate:Project_startdate:D'
where `columns` = 'ld_project:actualenddate:actualenddate:Project_actualenddate:D' and Usereportid = @usereportid;
delimiter;

SELECT MAX(sequence) INTO @sequence FROM ld_systems_deploy;
INSERT INTO ld_systems_deploy(deploy_value,deploy_type,description,setype,sequence)
SELECT '2',93,'设置单据分录明细中单价字段小数位数。','',@sequence+1
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM ld_systems_deploy WHERE deploy_type = 93);
delimiter;

INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,Labeltype)
SELECT 'zh','THENUMBEROFDECIMAL_LISTOFDOCUMENTS','设置单据分录明细中单价字段小数位数。','fixedstr'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol ='THENUMBEROFDECIMAL_LISTOFDOCUMENTS' AND Labeltype = 'fixedstr');
delimiter;

INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,Labeltype)
SELECT 'en','THENUMBEROFDECIMAL_LISTOFDOCUMENTS','Set the number of decimal places in the list of documents.','fixedstr'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol ='THENUMBEROFDECIMAL_LISTOFDOCUMENTS' AND Labeltype = 'fixedstr');
delimiter;

UPDATE ld_producttoolfield SET uitype = 163 WHERE columnname in ('taxprice','listprice','productcost');
delimiter;

alter table ld_inventoryproductrel modify listprice decimal(25,8);
delimiter;

alter table ld_inventoryproductrel modify taxprice decimal(25,8);
delimiter;

alter table ld_inventoryproductrel modify productcost decimal(25,8);
delimiter;


select max(relation_id) into @relation_id from ld_relatedlists  ;
select tabid into @dividendordertabid from ld_tab where name='dividendorder';
update ld_relatedlists_seq set id=@relation_id+1 where not exists(select 1 from ld_relatedlists where tabid=6 and name='get_dividendorder');
insert into ld_relatedlists(relation_id,tabid,name,related_tabid,sequence,label,presence,mobile_presence,mobile_sequence)
select @relation_id+1,6,'get_dividendorder',@dividendordertabid,4,'DividendOrder',0,1,1 from DUAL
where not exists(select 1 from ld_relatedlists where tabid=6 and name='get_dividendorder');

set @tabid=6;
select sequence into @seq from ld_relatedlists where tabid=@tabid and `name`='get_salesorder';
update ld_relatedlists set sequence=sequence+10 where tabid=@tabid and sequence>@seq;
update ld_relatedlists set sequence=@seq+1 where tabid=@tabid and `name`='get_dividendorder';

set @i=0;
update ld_relatedlists set sequence=(@i:=@i+1) where tabid=@tabid order by sequence;
delimiter;


update ld_desk set fieldlabel='已存在，保存时将生成新的编号！' where labelbol='NUNMBERALREADYEXIST' and languagetype='zh';
update ld_desk set fieldlabel=' already exists,the system will automatically generates a new number.' where labelbol='NUNMBERALREADYEXIST' and languagetype='en';


select max(tabid) into @tabid from ld_tab;
select tabsequence,parent into @tabsequence,@parent from ld_tab where `name` = 'Comprehensivereport';
insert into ld_tab(tabid,`name`,presence,tabsequence,tablabel,parent)
select @tabid+1,'Customreport',0,@tabsequence+1,'Customreport',@parent from DUAL
where not exists(select 1 from ld_tab where `name` = 'Customreport');
delimiter;

select tabid into @tabid from ld_tab where `name` = 'Customreport';
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'en','ld_tab',@tabid,@tabid,'Customreport' from DUAL
where not exists(select 1 from ld_tranlabel where languagetype='en' and trantable='ld_tab' and tabid = @tabid and relateid = @tabid);
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'zh','ld_tab',@tabid,@tabid,'定制报表' from DUAL
where not exists(select 1 from ld_tranlabel where languagetype='zh' and trantable='ld_tab' and tabid = @tabid and relateid = @tabid);
delimiter;

select tabid into @tabid from ld_tab where `name` = 'Customreport';
insert into ld_profileallpermission(tabid,operation)
select @tabid,3 from DUAL
where not exists(select 1 from ld_profileallpermission where tabid = @tabid and operation = 3);
delimiter;

select tabid into @tabid from ld_tab where `name` = 'Customreport';
select parenttabid into @parenttabid from ld_parenttab where parenttab_label = 'Parent Reports';
select max(sequence) into @sequence from ld_parenttabrel where parenttabid = @parenttabid;
insert into ld_parenttabrel(parenttabid,tabid,sequence)
select @parenttabid,@tabid,@sequence+1 from DUAL
where not exists(select 1 from ld_parenttabrel where parenttabid = @parenttabid and tabid = @tabid);
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,Labeltype)
select 'zh','reportsort','报表排序','fixedstr' from DUAL
where not exists(select 1 from ld_desk where languagetype = 'zh' and labelbol = 'reportsort' and Labeltype = 'fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,Labeltype)
select 'en','reportsort','Report Sort','fixedstr' from DUAL
where not exists(select 1 from ld_desk where languagetype = 'en' and labelbol = 'reportsort' and Labeltype = 'fixedstr');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,Labeltype)
select 'zh','reportdescription','报表说明','fixedstr' from DUAL
where not exists(select 1 from ld_desk where languagetype = 'zh' and labelbol = 'reportdescription' and Labeltype = 'fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,Labeltype)
select 'en','reportdescription','Report Description','fixedstr' from DUAL
where not exists(select 1 from ld_desk where languagetype = 'en' and labelbol = 'reportdescription' and Labeltype = 'fixedstr');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,Labeltype)
select 'zh','reporttype','报表类型','fixedstr' from DUAL
where not exists(select 1 from ld_desk where languagetype = 'zh' and labelbol = 'reporttype' and Labeltype = 'fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,Labeltype)
select 'en','reporttype','Report Type','fixedstr' from DUAL
where not exists(select 1 from ld_desk where languagetype = 'en' and labelbol = 'reporttype' and Labeltype = 'fixedstr');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,Labeltype)
select 'zh','STIMULSORTREPORTSPHP','Stimulsoft Reports.PHP模板','fixedstr' from DUAL
where not exists(select 1 from ld_desk where languagetype = 'zh' and labelbol = 'STIMULSORTREPORTSPHP' and Labeltype = 'fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,Labeltype)
select 'en','STIMULSORTREPORTSPHP','Template of Stimulsoft Reports.PHP','fixedstr' from DUAL
where not exists(select 1 from ld_desk where languagetype = 'en' and labelbol = 'STIMULSORTREPORTSPHP' and Labeltype = 'fixedstr');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,Labeltype)
select 'zh','LINKADDRESS','链接地址','fixedstr' from DUAL
where not exists(select 1 from ld_desk where languagetype = 'zh' and labelbol = 'LINKADDRESS' and Labeltype = 'fixedstr');

insert into ld_desk(languagetype,labelbol,fieldlabel,Labeltype)
select 'en','LINKADDRESS','Link address','fixedstr' from DUAL
where not exists(select 1 from ld_desk where languagetype = 'en' and labelbol = 'LINKADDRESS' and Labeltype = 'fixedstr');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,Labeltype)
select 'zh','TEMPLATEREPORT','报表模板','fixedstr' from DUAL
where not exists(select 1 from ld_desk where languagetype = 'zh' and labelbol = 'TEMPLATEREPORT' and Labeltype = 'fixedstr');

insert into ld_desk(languagetype,labelbol,fieldlabel,Labeltype)
select 'en','TEMPLATEREPORT','Template','fixedstr' from DUAL
where not exists(select 1 from ld_desk where languagetype = 'en' and labelbol = 'TEMPLATEREPORT' and Labeltype = 'fixedstr');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,Labeltype)
select 'zh','CUSTOMTEMPLATEUSEREPORTDESIGNTOOLSTIMULSOFTREPORT','请先使用报表设计工具Stimulsoft Reports.PHP定制模板','fixedstr' from DUAL
where not exists(select 1 from ld_desk where languagetype = 'zh' and labelbol = 'CUSTOMTEMPLATEUSEREPORTDESIGNTOOLSTIMULSOFTREPORT' and Labeltype = 'fixedstr');

insert into ld_desk(languagetype,labelbol,fieldlabel,Labeltype)
select 'en','CUSTOMTEMPLATEUSEREPORTDESIGNTOOLSTIMULSOFTREPORT','Custom template use report design tool stimulsoft reports.php','fixedstr' from DUAL
where not exists(select 1 from ld_desk where languagetype = 'en' and labelbol = 'CUSTOMTEMPLATEUSEREPORTDESIGNTOOLSTIMULSOFTREPORT' and Labeltype = 'fixedstr');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,Labeltype)
select 'zh','SETBYDEPARTMENT','按部门','fixedstr' from DUAL
where not exists(select 1 from ld_desk where languagetype = 'zh' and labelbol = 'SETBYDEPARTMENT' and Labeltype = 'fixedstr');

insert into ld_desk(languagetype,labelbol,fieldlabel,Labeltype)
select 'en','SETBYDEPARTMENT','Set By Department','fixedstr' from DUAL
where not exists(select 1 from ld_desk where languagetype = 'en' and labelbol = 'SETBYDEPARTMENT' and Labeltype = 'fixedstr');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,Labeltype)
select 'zh','SETBYUSERS','按用户','fixedstr' from DUAL
where not exists(select 1 from ld_desk where languagetype = 'zh' and labelbol = 'SETBYUSERS' and Labeltype = 'fixedstr');

insert into ld_desk(languagetype,labelbol,fieldlabel,Labeltype)
select 'en','SETBYUSERS','Set By Users','fixedstr' from DUAL
where not exists(select 1 from ld_desk where languagetype = 'en' and labelbol = 'SETBYUSERS' and Labeltype = 'fixedstr');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,Labeltype)
select 'zh','CANNOTEXCEED','不能超出','jspop' from DUAL
where not exists(select 1 from ld_desk where languagetype = 'zh' and labelbol = 'CANNOTEXCEED' and Labeltype = 'jspop');

insert into ld_desk(languagetype,labelbol,fieldlabel,Labeltype)
select 'en','CANNOTEXCEED',' can not exceed ','jspop' from DUAL
where not exists(select 1 from ld_desk where languagetype = 'en' and labelbol = 'CANNOTEXCEED' and Labeltype = 'jspop');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,Labeltype)
select 'zh','AWORD','个字','jspop' from DUAL
where not exists(select 1 from ld_desk where languagetype = 'zh' and labelbol = 'AWORD' and Labeltype = 'jspop');

insert into ld_desk(languagetype,labelbol,fieldlabel,Labeltype)
select 'en','AWORD',' a word ','jspop' from DUAL
where not exists(select 1 from ld_desk where languagetype = 'en' and labelbol = 'AWORD' and Labeltype = 'jspop');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,Labeltype)
select 'zh','THEFILEISZEROBYTEORDAMAGEDPLEASERESELECT','文件是零字节或者已损坏，请重新选择','fixedstr' from DUAL
where not exists(select 1 from ld_desk where languagetype = 'zh' and labelbol = 'THEFILEISZEROBYTEORDAMAGEDPLEASERESELECT' and Labeltype = 'fixedstr');

insert into ld_desk(languagetype,labelbol,fieldlabel,Labeltype)
select 'en','THEFILEISZEROBYTEORDAMAGEDPLEASERESELECT','The file is zero byte or damaged, please re select','fixedstr' from DUAL
where not exists(select 1 from ld_desk where languagetype = 'en' and labelbol = 'THEFILEISZEROBYTEORDAMAGEDPLEASERESELECT' and Labeltype = 'fixedstr');
delimiter;

update ld_desk set fieldlabel = '适用范围' where labelbol = 'APPLICABLESCOPE' and languagetype = 'zh';
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,Labeltype)
select 'zh','THEFOLDERLISTEXISTSNOTALLOWEDTODELETE','该文件夹下有报表，不允许删除','jspop' from DUAL
where not exists(select 1 from ld_desk where languagetype = 'zh' and labelbol = 'THEFOLDERLISTEXISTSNOTALLOWEDTODELETE' and Labeltype = 'jspop');

insert into ld_desk(languagetype,labelbol,fieldlabel,Labeltype)
select 'en','THEFOLDERLISTEXISTSNOTALLOWEDTODELETE','The folder list exists，not allowed to delete','jspop' from DUAL
where not exists(select 1 from ld_desk where languagetype = 'en' and labelbol = 'THEFOLDERLISTEXISTSNOTALLOWEDTODELETE' and Labeltype = 'jspop');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,Labeltype)
select 'zh','THEREISAREPORTTEMPLATETHEREPORT','该报表下存在报表模板，是否确认要删除？','jspop' from DUAL
where not exists(select 1 from ld_desk where languagetype = 'zh' and labelbol = 'THEREISAREPORTTEMPLATETHEREPORT' and Labeltype = 'jspop');

insert into ld_desk(languagetype,labelbol,fieldlabel,Labeltype)
select 'en','THEREISAREPORTTEMPLATETHEREPORT','There is a report template the report, are you sure you want to delete?','jspop' from DUAL
where not exists(select 1 from ld_desk where languagetype = 'en' and labelbol = 'THEREISAREPORTTEMPLATETHEREPORT' and Labeltype = 'jspop');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,Labeltype)
select 'zh','ERRORDELETEINGSTATEMENTS','删除报表时出错，请刷新后重试','jspop' from DUAL
where not exists(select 1 from ld_desk where languagetype = 'zh' and labelbol = 'ERRORDELETEINGSTATEMENTS' and Labeltype = 'jspop');

insert into ld_desk(languagetype,labelbol,fieldlabel,Labeltype)
select 'en','ERRORDELETEINGSTATEMENTS','Error deleting statements, please refresh and try again','jspop' from DUAL
where not exists(select 1 from ld_desk where languagetype = 'en' and labelbol = 'ERRORDELETEINGSTATEMENTS' and Labeltype = 'jspop');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,Labeltype)
select 'zh','EDITREPORT','编辑报表','fixedstr' from DUAL
where not exists(select 1 from ld_desk where languagetype = 'zh' and labelbol = 'EDITREPORT' and Labeltype = 'fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,Labeltype)
select 'en','EDITREPORT','Edit Report','fixedstr' from DUAL
where not exists(select 1 from ld_desk where languagetype = 'en' and labelbol = 'EDITREPORT' and Labeltype = 'fixedstr');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,Labeltype)
select 'zh','SETPARAMFORAPPROVAL','审批参数设置','fixedstr' from dual
where not EXISTS(select 1 from ld_desk  where labelbol='SETPARAMFORAPPROVAL' and Labeltype='fixedstr' AND languagetype='zh');

insert into ld_desk(languagetype,labelbol,fieldlabel,Labeltype)
select 'en','SETPARAMFORAPPROVAL','Setting the approval parameters','fixedstr' from dual
where not EXISTS(select 1 from ld_desk  where labelbol='SETPARAMFORAPPROVAL' and Labeltype='fixedstr' AND languagetype='en');

insert into ld_desk(languagetype,labelbol,fieldlabel,Labeltype)
select 'zh','NEXTAPPROVESTEP','下一审批步骤','fixedstr' from dual
where not EXISTS(select 1 from ld_desk  where labelbol='NEXTAPPROVESTEP' and Labeltype='fixedstr' AND languagetype='zh');

insert into ld_desk(languagetype,labelbol,fieldlabel,Labeltype)
select 'en','NEXTAPPROVESTEP','Next Approve Step','fixedstr' from dual
where not EXISTS(select 1 from ld_desk  where labelbol='NEXTAPPROVESTEP' and Labeltype='fixedstr' AND languagetype='en');

insert into ld_desk(languagetype,labelbol,fieldlabel,Labeltype)
select 'zh','APPROVELEASTONEFORREMIND','已启用审批通过提醒，请至少选择1个提醒人','jspop' from dual
where not EXISTS(select 1 from ld_desk  where labelbol='APPROVELEASTONEFORREMIND' and Labeltype='jspop' AND languagetype='zh');

insert into ld_desk(languagetype,labelbol,fieldlabel,Labeltype)
select 'en','APPROVELEASTONEFORREMIND','Enabled by reminding of examination and approval, please select at least one remind people','jspop' from dual
where not EXISTS(select 1 from ld_desk  where labelbol='APPROVELEASTONEFORREMIND' and Labeltype='jspop' AND languagetype='en');


insert into ld_desk(languagetype,labelbol,fieldlabel,Labeltype)
  select 'zh','APPROVEREFUSELEASTONEFORREMIND','已启用审批不通过提醒，请至少选择1个提醒人','jspop'
  from dual where not EXISTS(select 1 from ld_desk  where labelbol='APPROVEREFUSELEASTONEFORREMIND' and Labeltype='jspop' AND languagetype='zh');

insert into ld_desk(languagetype,labelbol,fieldlabel,Labeltype)
select 'en','APPROVEREFUSELEASTONEFORREMIND','Enabled failure reminds of examination and approval, please select at least one remind people','jspop' from dual
where not EXISTS(select 1 from ld_desk  where labelbol='APPROVEREFUSELEASTONEFORREMIND' and Labeltype='jspop' AND languagetype='en');

insert into ld_desk(languagetype,labelbol,fieldlabel,Labeltype)
select 'zh','SETBYDEPARTMENT','按部门','fixedstr' from dual
where not EXISTS(select 1 from ld_desk  where labelbol='SETBYDEPARTMENT' and Labeltype='fixedstr' AND languagetype='zh');

insert into ld_desk(languagetype,labelbol,fieldlabel,Labeltype)
select 'en','SETBYDEPARTMENT','Set by department','fixedstr' from dual
where not EXISTS(select 1 from ld_desk  where labelbol='SETBYDEPARTMENT' and Labeltype='fixedstr' AND languagetype='en');

insert into ld_desk(languagetype,labelbol,fieldlabel,Labeltype)
select 'zh','SETBYUSERS','按用户 ','fixedstr' from dual
where not EXISTS(select 1 from ld_desk  where labelbol='SETBYUSERS' and Labeltype='fixedstr' AND languagetype='zh');

insert into ld_desk(languagetype,labelbol,fieldlabel,Labeltype)
select 'en','SETBYUSERS','Set by user','fixedstr' from dual
where not EXISTS(select 1 from ld_desk  where labelbol='SETBYUSERS' and Labeltype='fixedstr' AND languagetype='en');

insert into ld_desk(languagetype,labelbol,fieldlabel,Labeltype)
select 'zh','APPROVEREMINDS','审批通知 ','fixedstr' from dual
where not EXISTS(select 1 from ld_desk  where labelbol='APPROVEREMINDS' and Labeltype='fixedstr' AND languagetype='zh');

insert into ld_desk(languagetype,labelbol,fieldlabel,Labeltype)
select 'en','APPROVEREMINDS','Approval notice','fixedstr' from dual
where not EXISTS(select 1 from ld_desk  where labelbol='APPROVEREMINDS' and Labeltype='fixedstr' AND languagetype='en');


insert into ld_desk(languagetype,labelbol,fieldlabel,Labeltype)
select 'zh','APPROVEBEFOREPROCESS','审批处理前 ','fixedstr' from dual
where not EXISTS(select 1 from ld_desk  where labelbol='APPROVEBEFOREPROCESS' and Labeltype='fixedstr' AND languagetype='zh');

insert into ld_desk(languagetype,labelbol,fieldlabel,Labeltype)
select 'en','APPROVEBEFOREPROCESS','Approval before processing','fixedstr' from dual
where not EXISTS(select 1 from ld_desk  where labelbol='APPROVEBEFOREPROCESS' and Labeltype='fixedstr' AND languagetype='en');

insert into ld_desk(languagetype,labelbol,fieldlabel,Labeltype)
select 'zh','APPROVEDSUCCESS','审批通过 ','fixedstr' from dual
where not EXISTS(select 1 from ld_desk  where labelbol='APPROVEDSUCCESS' and Labeltype='fixedstr' AND languagetype='zh');

insert into ld_desk(languagetype,labelbol,fieldlabel,Labeltype)
select 'en','APPROVEDSUCCESS','Approved successfully','fixedstr' from dual
where not EXISTS(select 1 from ld_desk  where labelbol='APPROVEDSUCCESS' and Labeltype='fixedstr' AND languagetype='en');

insert into ld_desk(languagetype,labelbol,fieldlabel,Labeltype)
select 'zh','APPROVEREFUSE','审批不通过 ','fixedstr' from dual
where not EXISTS(select 1 from ld_desk  where labelbol='APPROVEREFUSE' and Labeltype='fixedstr' AND languagetype='zh');

insert into ld_desk(languagetype,labelbol,fieldlabel,Labeltype)
select 'en','APPROVEREFUSE','Approval refused','fixedstr' from dual
where not EXISTS(select 1 from ld_desk  where labelbol='APPROVEREFUSE' and Labeltype='fixedstr' AND languagetype='en');

insert into ld_desk(languagetype,labelbol,fieldlabel,Labeltype)
select 'zh','SETREMINDSCONTENT','设置提醒内容 ','fixedstr' from dual
where not EXISTS(select 1 from ld_desk  where labelbol='SETREMINDSCONTENT' and Labeltype='fixedstr' AND languagetype='zh');

insert into ld_desk(languagetype,labelbol,fieldlabel,Labeltype)
select 'en','SETREMINDSCONTENT','Set reminders content','fixedstr' from dual
where not EXISTS(select 1 from ld_desk  where labelbol='SETREMINDSCONTENT' and Labeltype='fixedstr' AND languagetype='en');

insert into ld_desk(languagetype,labelbol,fieldlabel,Labeltype)
select 'zh','APPROVALNOTE','审批备注 ','fixedstr' from dual
where not EXISTS(select 1 from ld_desk  where labelbol='APPROVALNOTE' and Labeltype='fixedstr' AND languagetype='zh');

insert into ld_desk(languagetype,labelbol,fieldlabel,Labeltype)
select 'en','APPROVALNOTE','Approval Note','fixedstr' from dual
where not EXISTS(select 1 from ld_desk  where labelbol='APPROVALNOTE' and Labeltype='fixedstr' AND languagetype='en');

CREATE TABLE IF NOT EXISTS `ld_approvereminds`(
  `id`        INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  `stepid`     INT ,
  `type`      TINYINT,
  `remindmethod`  VARCHAR(100) ,
  `reminduser`       VARCHAR(100),
  `remindcontent`      TEXT
)ENGINE=InnoDB DEFAULT CHARSET=utf8;
delimiter;
-- 2016-03-08

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'zh','IMPORTRECIPIENTPHONE','导入接收人手机','fixedstr' from dual
where not EXISTS(select 1 from ld_desk  where languagetype='zh' and labelbol='IMPORTRECIPIENTPHONE' and Labeltype='fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'en','IMPORTRECIPIENTPHONE','Import recipient phone','fixedstr' from dual
where not EXISTS(select 1 from ld_desk  where languagetype='en' and labelbol='IMPORTRECIPIENTPHONE' and Labeltype='fixedstr');
delimiter;

SELECT max(sequence) INTO @sequence FROM ld_systems_deploy;
insert into ld_systems_deploy(deploy_value,deploy_type,description,setype,sequence)
select 1,95,'客户重复是否弹出对冲提醒 1:否，0:是','',@sequence+1  from dual
where not exists(select 1 from ld_systems_deploy where deploy_type = 95);

insert into ld_desk(languagetype,labelbol,fieldlabel,Labeltype)
select 'zh','REPEATCUSTOMERSREMIND','客户重复是否弹出对冲提醒','fixedstr'  from dual
where not exists(select 1 from ld_desk where labelbol='REPEATCUSTOMERSREMIND' and languagetype='zh');

insert into ld_desk(languagetype,labelbol,fieldlabel,Labeltype)
select 'en','REPEATCUSTOMERSREMIND','Whether to send reminders when customer repeat','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='REPEATCUSTOMERSREMIND' and languagetype='en');

insert into ld_desk(languagetype,labelbol,fieldlabel,Labeltype)
select 'zh','REMINDHEDGING','对冲提醒','jspop' from dual
where not exists(select 1 from ld_desk where labelbol='REMINDHEDGING' and languagetype='zh');

insert into ld_desk(languagetype,labelbol,fieldlabel,Labeltype)
select 'en','REMINDHEDGING','Hedging Remind','jspop' from dual
where not exists(select 1 from ld_desk where labelbol='REMINDHEDGING' and languagetype='en');

insert into ld_desk(languagetype,labelbol,fieldlabel,Labeltype)
select 'zh','NOENTRY','暂未录入','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='NOENTRY' and languagetype='zh');

insert into ld_desk(languagetype,labelbol,fieldlabel,Labeltype)
select 'en','NOENTRY','NO ENTRY','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='NOENTRY' and languagetype='en');

insert into ld_desk(languagetype,labelbol,fieldlabel,Labeltype)
select 'zh','REMINDOPEAFORHEDGING','您的{accountname}客户已有{operator}在{nowtime}正在尝试报备，联系电话：{operatorphone}','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='REMINDOPEAFORHEDGING' and languagetype='zh');

insert into ld_desk(languagetype,labelbol,fieldlabel,Labeltype)
select 'en','REMINDOPEAFORHEDGING','Your {accountname} customer already has {operator} in {nowtime} is attempting to report, contact phone: {operatorphone}','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='REMINDOPEAFORHEDGING' and languagetype='en');

insert into ld_desk(languagetype,labelbol,fieldlabel,Labeltype)
select 'zh','REMINDOWNEFORHEDGING','{accountname}已被{smowner}在{createdtime}报备，请联系{smowner}，联系电话：{smownerphone}','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='REMINDOWNEFORHEDGING' and languagetype='zh');

insert into ld_desk(languagetype,labelbol,fieldlabel,Labeltype)
select 'en','REMINDOWNEFORHEDGING','{accountname} has been {smowner} in {createdtime} report preparation, please contact {smowner}, the telephone: {smownerphone}','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='REMINDOWNEFORHEDGING' and languagetype='en');
delimiter;

UPDATE ld_desk SET fieldlabel = '设置单据分录明细中单价字段小数位数' WHERE languagetype = 'zh' AND labelbol ='THENUMBEROFDECIMAL_LISTOFDOCUMENTS' AND Labeltype = 'fixedstr';
UPDATE ld_desk SET fieldlabel = 'Set the number of decimal places in the list of documents' WHERE languagetype = 'en' AND labelbol ='THENUMBEROFDECIMAL_LISTOFDOCUMENTS' AND Labeltype = 'fixedstr';
delimiter;
select tabid into @tabid from ld_tab where `name` = 'Accounts';
update ld_field set uitype = 56 where uitype = 1 and tabid = @tabid and columnname = 'publicaccount';
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','NOTESELECTTHEUSERDOESNOTHAVETHEFIELDVIEWANDEDITPERMISSIONS','Note: select the user does not have the field view and edit permissions','jspop' from DUAL
where not exists(select 1 from ld_desk where languagetype = 'en' and labelbol = 'NOTE:SELECTTHEUSERDOESNOTHAVETHEFIELDVIEWANDEDITPERMISSIONS' and Labeltype='jspop');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','NOTESELECTTHEUSERDOESNOTHAVETHEFIELDVIEWANDEDITPERMISSIONS','注意：选择的用户没有该字段的查看和编辑权限','jspop' from DUAL
where not exists(select 1 from ld_desk where languagetype = 'zh' and labelbol = 'NOTE:SELECTTHEUSERDOESNOTHAVETHEFIELDVIEWANDEDITPERMISSIONS' and Labeltype='jspop');
delimiter;
alter table ld_customreport_folder modify column folder_name VARCHAR(100);
delimiter;
-- 2016-03-10

set @tabname='ProjectProgress';
set @columnname='timecost';
select tabid into @tabid from ld_tab where `name`=@tabname;
select fieldid into @fieldid from ld_field where tabid=@tabid and columnname=@columnname;
update ld_field set uitype=7,typeofdata='N~M~25,2' where tabid=@tabid and columnname=@columnname;
alter table ld_projectprogress modify column `timecost` decimal(25,2);
delimiter;

set @zh='提交审批';
set @en='Submitted for approval';
set @labelbol='Leadersubmittedforapproval';
update ld_desk set fieldlabel=@zh where languagetype='zh' and labelbol=@labelbol;
update ld_desk set fieldlabel=@en where languagetype='en' and labelbol=@labelbol;
delimiter;

select sequence into @sequence from ld_systems_deploy where deploy_type = 49;
update ld_systems_deploy set sequence = @sequence + 1 where deploy_type = 93;
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','PROGRESS','进度','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol = 'PROGRESS' and languagetype = 'zh' and labeltype = 'fixedstr');
delimiter;
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','PROGRESS','Progress','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol = 'PROGRESS' and languagetype = 'en' and labeltype = 'fixedstr');
delimiter;

select tabid into @tabid from ld_tab where name = 'Accounts';
update ld_relatedlists set mobile_presence =0 where tabid = @tabid and label in ('Expense');
delimiter;

select tabid into @tabid from ld_tab where name = 'Potentials';
update ld_relatedlists set mobile_presence =0 where tabid = @tabid and label in ('ServiceContracts');
delimiter;
-- 2016-03-11

update ld_desk set fieldlabel = 'Folder ' where labelbol = 'MAILFOLDER' and languagetype = 'en' and labeltype='fixedstr';
delimiter;
update ld_desk set fieldlabel = 'Add Report' where labelbol = 'Creating_a_Report' and languagetype = 'en' and labeltype='fixedstr';
delimiter;
update ld_desk set fieldlabel = 'Are you sure you want to delete this folder' where labelbol = 'CONFIRMWANTDELETEFOLDER' and languagetype = 'en' and labeltype='jspop';
delimiter;
update ld_desk set fieldlabel = 'Are you sure you want to delete this report?' where labelbol = 'CONFIRMWANTDELETEREPORTS' and languagetype = 'en' and labeltype='jspop';
delimiter;
update ld_desk set fieldlabel = 'The folder list exists，not allowed to delete?' where labelbol = 'THEREISAREPORTTEMPLATETHEREPORT' and languagetype = 'en' and labeltype='jspop';
delimiter;

update ld_templateprint set templateprintname='日程管理预置模板' where tabid=16 and templateprintname='销售机会预置模板';
delimiter;
-- 2016-03-14

call AddColumn('ld_account','lastcontactuser','int','19',0);
delimiter;

call getallprofile('ld_account');
delimiter;

call fieldprofile('ld_account');
delimiter;

select tabid into @tabid from ld_tab where `name` = 'Accounts';
insert into ld_field(tabid,fieldid,columnname,tablename,uitype,fieldname,fieldlabel,readonly,block,displaytype,presence,typeofdata,generatedtype,sequence)
select @tabid,(select max(fieldid) from ld_field)+1,'lastcontactuser','ld_account',52,'lastcontactuser','最新联系人',1,(select blockid from ld_blocks where blocklabel = 'LBL_ACCOUNT_INFORMATION' AND tabid=6 limit 1),2,2,'V~O',1,65 from dual
where not exists (select 1 from ld_field where tabid = @tabid and columnname = 'lastcontactuser');

select fieldid into @fieldid from ld_field where tabid = @tabid and fieldname = 'lastcontactuser';
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'zh','ld_field',@tabid,@fieldid,'最新联系人' from dual
where not EXISTS(select 1 from ld_tranlabel  where languagetype = 'zh' and trantable ='ld_field' and tabid = @tabid and relateid=@fieldid);

insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'en','ld_field',@tabid,@fieldid,'Last Contact' from dual
where not EXISTS(select 1 from ld_tranlabel  where languagetype = 'en' and trantable ='ld_field' and tabid = @tabid and relateid=@fieldid);
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','OPENMODULE','开启','jspop' from dual
where not exists(select 1 from ld_desk where languagetype= 'zh' and labelbol = 'OPENMODULE' and labeltype='jspop');

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','OPENMODULE','Open Module','jspop' from dual
where not exists(select 1 from ld_desk where languagetype= 'en' and labelbol = 'OPENMODULE' and labeltype='jspop');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,Labeltype)
select 'zh','LBL_FIELDS_ACCESS','字段权限','jspop' from dual
where not EXISTS(select 1 from ld_desk  where labelbol='LBL_FIELDS_ACCESS' and Labeltype='jspop' AND languagetype='zh');
insert into ld_desk(languagetype,labelbol,fieldlabel,Labeltype)
select 'en','LBL_FIELDS_ACCESS','Fields Access','jspop' from dual
where not EXISTS(select 1 from ld_desk  where labelbol='LBL_FIELDS_ACCESS' and Labeltype='jspop' AND languagetype='en');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','DOESNOT_HAVE_AN_MAILID','没有邮箱地址','jspop' from DUAL
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol ='DOESNOT_HAVE_AN_MAILID' and labeltype='jspop');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','DOESNOT_HAVE_AN_MAILID','No mail set','jspop' from DUAL
where not exists(select 1 from ld_desk where languagetype='en' and labelbol ='DOESNOT_HAVE_AN_MAILID' and labeltype='jspop');
delimiter;

update ld_desk set fieldlabel='请输入正确的邮箱地址以允许用户登录！' where labelbol='PLEASEENTERVALIDEMAIL' and languagetype='zh';
update ld_desk set fieldlabel='没有任何邮箱地址' where labelbol='THERENOMESSAGENUM' and languagetype='zh';

update ld_desk set fieldlabel='Follow' where labelbol='FOLLOWUP' and languagetype='en';
update ld_desk set fieldlabel='Turn to public' where labelbol='TURNHIGHSEAS' and languagetype='en';
update ld_desk set fieldlabel='Turn to normal' where labelbol='TURNORDINARY' and languagetype='en';


insert into ld_desk(languagetype,labelbol,fieldlabel,Labeltype)
select 'zh','NONEXTAPPROVER','暂无审批人','jspop' from dual
where not exists(select 1 from ld_desk where labelbol='NONEXTAPPROVER' and languagetype='zh');

insert into ld_desk(languagetype,labelbol,fieldlabel,Labeltype)
select 'en','NONEXTAPPROVER','Approver does not exist','jspop' from dual
where not exists(select 1 from ld_desk where labelbol='NONEXTAPPROVER' and languagetype='en');
delimiter;

update ld_desk set fieldlabel = '定制订单、发票等模块单据分录中的自定义字段' where labelbol = 'LBL_ProductTool_Description' and languagetype = 'zh' and labeltype='fixedstr';
update ld_desk set fieldlabel = 'Customise the detail entry fields for orders,invoices,expense,etc.' where labelbol = 'LBL_ProductTool_Description' and languagetype = 'en' and labeltype='fixedstr';
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,Labeltype)
select 'zh','Select the hidden fields to be removed','选择要取消隐藏的字段','fixedstr' from DUAL
where not exists(select 1 from ld_desk where languagetype = 'zh' and labelbol = 'Select the hidden fields to be removed' and Labeltype = 'fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,Labeltype)
select 'en','Select the hidden fields to be removed','Select the hidden fields to be removed','fixedstr' from DUAL
where not exists(select 1 from ld_desk where languagetype = 'en' and labelbol = 'Select the hidden fields to be removed' and Labeltype = 'fixedstr');
delimiter;


DROP PROCEDURE IF  EXISTS  `rel_shareuser`;
delimiter ||
CREATE PROCEDURE `rel_shareuser` ()
BEGIN
DECLARE moduleid int;
DECLARE relshareuser_cur CURSOR FOR SELECT  tabid from ld_profileallpermission where operation=14 ;
DECLARE CONTINUE HANDLER FOR SQLSTATE '02000' set moduleid = NULL;
OPEN relshareuser_cur;
Fetch relshareuser_cur into moduleid;
while(moduleid is not null) DO
  SELECT max(relation_id) INTO @relation_id FROM ld_relatedlists;
  SELECT if(MAX(sequence),MAX(sequence),1) INTO @sequence2 from ld_relatedlists where tabid=moduleid;
  SELECT IF(MIN(related_tabid)<=0,MIN(related_tabid)-1,0) INTO @related_tabid from ld_relatedlists where tabid=moduleid;
  INSERT INTO  ld_relatedlists(relation_id,tabid,related_tabid,NAME,sequence,label,presence,actions,mobile_presence,mobile_sequence)
  SELECT @relation_id+1,moduleid,@related_tabid,'get_SharedUsers',@sequence2,'SharedUsers',0,'share',1,@sequence2+1
  FROM DUAL WHERE NOT EXISTS(SELECT 1 FROM ld_relatedlists WHERE tabid=moduleid AND NAME='get_SharedUsers');
Fetch relshareuser_cur into moduleid;
END WHILE;
close relshareuser_cur;
end ||
delimiter;

call rel_shareuser();
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','ShareUsers','共享人','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol = 'ShareUsers' and languagetype = 'zh' and labeltype = 'fixedstr');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','ShareUsers','Share Users','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol = 'ShareUsers' and languagetype = 'en' and labeltype = 'fixedstr');
delimiter;

DROP PROCEDURE IF  EXISTS  `update_relatedlists_seq`;
delimiter ||
CREATE PROCEDURE `update_relatedlists_seq`()
BEGIN

DECLARE tmptabid int DEFAULT 0;

DECLARE cur1 CURSOR FOR SELECT tabid from ld_tab;
DECLARE CONTINUE HANDLER FOR SQLSTATE '02000' SET tmptabid = NULL;

OPEN cur1;
Fetch cur1 into tmptabid;
while(tmptabid is not null) DO
	set @seq=0;
	set @tabid=tmptabid;
  select ifnull(sequence,0) into @seq from ld_relatedlists where tabid=@tabid and `name`='get_WorkReport';
	update ld_relatedlists set sequence=sequence+100 where tabid=@tabid and sequence>@seq;
	update ld_relatedlists set sequence=@seq+1 where tabid=@tabid and `name`='get_SharedUsers';

	set @i=0;
	update ld_relatedlists set sequence=(@i:=@i+1) where tabid=@tabid order by sequence;
	Fetch cur1 into tmptabid;
END WHILE;
close cur1;
end ||
delimiter;

call update_relatedlists_seq();
delimiter;
-- 2016-03-22

CREATE TABLE IF NOT EXISTS`ld_workcalender` (
  `workcalender_id` int(19) NOT NULL AUTO_INCREMENT,
  `workcalender_name` varchar(500) NOT NULL,
  `defined_working_day` varchar(500) NOT NULL ,
  PRIMARY KEY (`workcalender_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
delimiter;

CREATE TABLE IF NOT EXISTS`ld_trackpostion` (
  `trackpostion_id` int(19) NOT NULL AUTO_INCREMENT,
  `trackpostion` varchar(500) NOT NULL,
  `starttime` VARCHAR(255) NOT NULL,
  `stoptime`  VARCHAR(255) NOT NULL,
  `presence`  int(19) not null,
  `workcalender_id` int(19) DEFAULT 1,
  `picklist_valueid` INT(19) ,
  PRIMARY KEY (`trackpostion_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
delimiter;

CREATE TABLE IF NOT EXISTS`ld_workingdays` (
  `workingdays_id` int(19) NOT NULL AUTO_INCREMENT,
  `workcalender_year` varchar(255) NOT NULL,
  `date` date NOT NULL,
  `workingdaytype` int(19) NOT NULL,
  `remark` varchar(255) NOT NULL,
  `workcalender_id` int(19) NOT NULL,
  PRIMARY KEY (`workingdays_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
delimiter;

SELECT blockid INTO @blockid FROM ld_settings_blocks WHERE label='LBL_USER_MANAGEMENT';
SELECT max(sequence)INTO @sequence from ld_settings_field WHERE blockid=@blockid;
insert into ld_settings_field(blockid,NAME,iconpath,description,linkto,sequence,active)
select @blockid,'TRACKPOSITONINGGROUP','ico-roles.png','DEFINEWORKTRACKPOSITIONINGTIMEANDMEMBERS',
'index.php?module=Settings&action=listtracks&parenttab=Settings&blockidsetting=2&fieldidsetting=2',@sequence+1,0
from dual where not EXISTS(select 1 from ld_settings_field  where blockid = @blockid and `name` ='TRACKPOSITONINGGROUP');
delimiter;
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','TRACKPOSITONINGGROUP','轨迹定位组','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol = 'TRACKPOSITONINGGROUP' and languagetype = 'zh' and labeltype = 'fixedstr');
delimiter;
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','TRACKPOSITONINGGROUP','Track Positioning Group','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol = 'TRACKPOSITONINGGROUP' and languagetype = 'en' and labeltype = 'fixedstr');
delimiter;
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','DEFINEWORKTRACKPOSITIONINGTIMEANDMEMBERS','定义工作轨迹定位时间和成员','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol = 'DEFINEWORKTRACKPOSITIONINGTIMEANDMEMBERS' and languagetype = 'zh' and labeltype = 'fixedstr');
delimiter;
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','DEFINEWORKTRACKPOSITIONINGTIMEANDMEMBERS','Define work track positioning time and members','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol = 'DEFINEWORKTRACKPOSITIONINGTIMEANDMEMBERS' and languagetype = 'en' and labeltype = 'fixedstr');
delimiter;
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','TRACKGROUPNAME','定位组名称','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol = 'TRACKGROUPNAME' and languagetype = 'zh' and labeltype = 'fixedstr');
delimiter;
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','TRACKGROUPNAME','Track group name','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol = 'TRACKGROUPNAME' and languagetype = 'en' and labeltype = 'fixedstr');
delimiter;
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','TRACKGROUPNAME','定位组名称','jspop' from dual
where not exists(select 1 from ld_desk where labelbol = 'TRACKGROUPNAME' and languagetype = 'zh' and labeltype = 'jspop');
delimiter;
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','TRACKGROUPNAME','Track group name','jspop' from dual
where not exists(select 1 from ld_desk where labelbol = 'TRACKGROUPNAME' and languagetype = 'en' and labeltype = 'jspop');
delimiter;
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','TRACKPERIOD','定位周期','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol = 'TRACKPERIOD' and languagetype = 'zh' and labeltype = 'fixedstr');
delimiter;
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','TRACKPERIOD','Track period','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol = 'TRACKPERIOD' and languagetype = 'en' and labeltype = 'fixedstr');
delimiter;
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','STARTSTOPTIME','起止日期','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol = 'STARTSTOPTIME' and languagetype = 'zh' and labeltype = 'fixedstr');
delimiter;
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','STARTSTOPTIME','Start & Stop time','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol = 'STARTSTOPTIME' and languagetype = 'en' and labeltype = 'fixedstr');
delimiter;
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','NUMBEROFMEMBER','成员人数','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol = 'NUMBEROFMEMBER' and languagetype = 'zh' and labeltype = 'fixedstr');
delimiter;
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','NUMBEROFMEMBER','Number of members','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol = 'NUMBEROFMEMBER' and languagetype = 'en' and labeltype = 'fixedstr');
delimiter;
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','BASICINFORMATION','基本信息','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol = 'BASICINFORMATION' and languagetype = 'zh' and labeltype = 'fixedstr');
delimiter;
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','BASICINFORMATION','Basic information','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol = 'BASICINFORMATION' and languagetype = 'en' and labeltype = 'fixedstr');
delimiter;
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','POSTIONTIME','定位时间','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol = 'POSTIONTIME' and languagetype = 'zh' and labeltype = 'fixedstr');
delimiter;
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','POSTIONTIME','Position time','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol = 'POSTIONTIME' and languagetype = 'en' and labeltype = 'fixedstr');
delimiter;
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','STARTTIMEPERDAY','每天定位开始的时间','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol = 'STARTTIMEPERDAY' and languagetype = 'zh' and labeltype = 'fixedstr');
delimiter;
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','STARTTIMEPERDAY','Start time per day','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol = 'STARTTIMEPERDAY' and languagetype = 'en' and labeltype = 'fixedstr');
delimiter;
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','ENDTIMEPERDAY','每天定位结束的时间','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol = 'ENDTIMEPERDAY' and languagetype = 'zh' and labeltype = 'fixedstr');
delimiter;
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','ENDTIMEPERDAY','End time per day','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol = 'ENDTIMEPERDAY' and languagetype = 'en' and labeltype = 'fixedstr');
delimiter;
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','WORKCALENDER','工作日历','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol = 'WORKCALENDER' and languagetype = 'zh' and labeltype = 'fixedstr');
delimiter;
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','WORKCALENDER','working calender','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol = 'WORKCALENDER' and languagetype = 'en' and labeltype = 'fixedstr');
delimiter;
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','POSITIONINGGROUPNAMECANNOTBEREPEATED','定位组名称不能重复','jspop' from dual
where not exists(select 1 from ld_desk where labelbol = 'POSITIONINGGROUPNAMECANNOTBEREPEATED' and languagetype = 'zh' and labeltype = 'jspop');
delimiter;
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','POSITIONINGGROUPNAMECANNOTBEREPEATED','Positioning group name cannot be repeated','jspop' from dual
where not exists(select 1 from ld_desk where labelbol = 'POSITIONINGGROUPNAMECANNOTBEREPEATED' and languagetype = 'en' and labeltype = 'jspop');
delimiter;
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','WORKCALENDERMANAGEMENT','工作日历管理','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol = 'WORKCALENDERMANAGEMENT' and languagetype = 'zh' and labeltype = 'fixedstr');
delimiter;
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','WORKCALENDERMANAGEMENT','Work calendar management','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol = 'WORKCALENDERMANAGEMENT' and languagetype = 'en' and labeltype = 'fixedstr');
delimiter;
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','ADD','新增','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol = 'ADD' and languagetype = 'zh' and labeltype = 'fixedstr');
delimiter;
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','ADD','Add','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol = 'ADD' and languagetype = 'en' and labeltype = 'fixedstr');
delimiter;
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','CALENDERNAME','日历名称','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol = 'CALENDERNAME' and languagetype = 'zh' and labeltype = 'fixedstr');
delimiter;
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','CALENDERNAME','Calender name','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol = 'CALENDERNAME' and languagetype = 'en' and labeltype = 'fixedstr');
delimiter;
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','CALENDERNAME','日历名称','jspop' from dual
where not exists(select 1 from ld_desk where labelbol = 'CALENDERNAME' and languagetype = 'zh' and labeltype = 'jspop');
delimiter;
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','CALENDERNAME','Calender name','jspop' from dual
where not exists(select 1 from ld_desk where labelbol = 'CALENDERNAME' and languagetype = 'en' and labeltype = 'jspop');
delimiter;
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','DEFINEDWORKINGDAYS','定义工作日','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol = 'DEFINEDWORKINGDAYS' and languagetype = 'zh' and labeltype = 'fixedstr');
delimiter;
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','DEFINEDWORKINGDAYS','Defined working days','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol = 'DEFINEDWORKINGDAYS' and languagetype = 'en' and labeltype = 'fixedstr');
delimiter;
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','SPECIALWORKINGDAYS','特殊工作日','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol = 'SPECIALWORKINGDAYS' and languagetype = 'zh' and labeltype = 'fixedstr');
delimiter;
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','SPECIALWORKINGDAYS','Special working days','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol = 'SPECIALWORKINGDAYS' and languagetype = 'en' and labeltype = 'fixedstr');
delimiter;
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','HOLIDAYANDVACATIONS','节假日','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol = 'HOLIDAYANDVACATIONS' and languagetype = 'zh' and labeltype = 'fixedstr');
delimiter;
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','HOLIDAYANDVACATIONS','Holiday and vacations','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol = 'HOLIDAYANDVACATIONS' and languagetype = 'en' and labeltype = 'fixedstr');
delimiter;
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','NOTEDEFAULTHOLIDAYDAYNEEDTOWORK','注：默认是节假日，但是需要上班的日期','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol = 'NOTEDEFAULTHOLIDAYDAYNEEDTOWORK' and languagetype = 'zh' and labeltype = 'fixedstr');
delimiter;
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','NOTEDEFAULTWORKDAYSETHOLIDAY','注：默认是上班日期，但是设置为节假日的日期','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol = 'NOTEDEFAULTWORKDAYSETHOLIDAY' and languagetype = 'zh' and labeltype = 'fixedstr');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','ADDITION','添加','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol = 'ADDITION' and languagetype = 'zh' and labeltype = 'fixedstr');
delimiter;
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','ADDITION','Addition','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol = 'ADDITION' and languagetype = 'en' and labeltype = 'fixedstr');
delimiter;
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','WORKCALENDERCANNOTBEREPEATED','日历名称不能重复','jspop' from dual
where not exists(select 1 from ld_desk where labelbol = 'WORKCALENDERCANNOTBEREPEATED' and languagetype = 'zh' and labeltype = 'jspop');
delimiter;
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','WORKCALENDERCANNOTBEREPEATED','Calender Name Can Not Be Repeted ','jspop' from dual
where not exists(select 1 from ld_desk where labelbol = 'WORKCALENDERCANNOTBEREPEATED' and languagetype = 'en' and labeltype = 'jspop');
delimiter;
CALL AddColumn('ld_users','trackgroupid','int','11',1);
delimiter;
SELECT MAX(trackpostion_id) into @trackpostion_id  from ld_trackpostion;
insert into ld_trackpostion(trackpostion_id,trackpostion,starttime,stoptime,presence,workcalender_id,picklist_valueid)
select 1,'不定位组(Non track group)','','',1,'0',@trackpostion_id+1 from dual
where not exists(select 1 from ld_trackpostion where trackpostion_id=1);
delimiter;
insert into ld_trackpostion(trackpostion_id,trackpostion,starttime,stoptime,presence,workcalender_id,picklist_valueid)
select 2,'标准定位组(Standard track group)','08:30','17:30',1,'1',@trackpostion_id+1 from dual
where not exists(select 1 from ld_trackpostion where trackpostion_id=2);
delimiter;
insert into ld_workcalender(workcalender_id,workcalender_name,defined_working_day)
select 1,'默认工作日','1,1,1,1,1,0,0' from dual
where not exists(select 1 from ld_workcalender where workcalender_id=1);
delimiter;
insert into ld_workingdays(workcalender_year,date,workingdaytype,remark,workcalender_id)
select '2016','2016-02-06',1,'补春节假',1 from dual
where not exists(select 1 from ld_workingdays where date='2016-02-06' );
delimiter;
insert into ld_workingdays(workcalender_year,date,workingdaytype,remark,workcalender_id)
select '2016','2016-02-14',1,'补春节假',1 from dual
where not exists(select 1 from ld_workingdays where date='2016-02-14' );
delimiter;
insert into ld_workingdays(workcalender_year,date,workingdaytype,remark,workcalender_id)
select '2016','2016-06-12',1,'补端午假',1 from dual
where not exists(select 1 from ld_workingdays where date='2016-06-12' );
delimiter;
insert into ld_workingdays(workcalender_year,date,workingdaytype,remark,workcalender_id)
select '2016','2016-09-18',1,'补中秋假',1 from dual
where not exists(select 1 from ld_workingdays where date='2016-09-18' );
delimiter;
insert into ld_workingdays(workcalender_year,date,workingdaytype,remark,workcalender_id)
select '2016','2016-10-08',1,'补国庆假',1 from dual
where not exists(select 1 from ld_workingdays where date='2016-10-08' );
delimiter;
insert into ld_workingdays(workcalender_year,date,workingdaytype,remark,workcalender_id)
select '2016','2016-10-09',1,'补国庆假',1 from dual
where not exists(select 1 from ld_workingdays where date='2016-10-09' );
delimiter;
insert into ld_workingdays(workcalender_year,date,workingdaytype,remark,workcalender_id)
select '2016','2016-01-01',2,'元旦放假',1 from dual
where not exists(select 1 from ld_workingdays where date='2016-01-01' );
delimiter;
insert into ld_workingdays(workcalender_year,date,workingdaytype,remark,workcalender_id)
select '2016','2016-01-02',2,'元旦放假',1 from dual
where not exists(select 1 from ld_workingdays where date='2016-01-02' );
delimiter;
insert into ld_workingdays(workcalender_year,date,workingdaytype,remark,workcalender_id)
select '2016','2016-01-03',2,'元旦放假',1 from dual
where not exists(select 1 from ld_workingdays where date='2016-01-03' );
delimiter;
insert into ld_workingdays(workcalender_year,date,workingdaytype,remark,workcalender_id)
select '2016','2016-01-07',2,'春节放假',1 from dual
where not exists(select 1 from ld_workingdays where date='2016-01-07' );
delimiter;
insert into ld_workingdays(workcalender_year,date,workingdaytype,remark,workcalender_id)
select '2016','2016-01-08',2,'春节放假',1 from dual
where not exists(select 1 from ld_workingdays where date='2016-01-08' );
delimiter;
insert into ld_workingdays(workcalender_year,date,workingdaytype,remark,workcalender_id)
select '2016','2016-01-09',2,'春节放假',1 from dual
where not exists(select 1 from ld_workingdays where date='2016-01-09' );
delimiter;
insert into ld_workingdays(workcalender_year,date,workingdaytype,remark,workcalender_id)
select '2016','2016-01-10',2,'春节放假',1 from dual
where not exists(select 1 from ld_workingdays where date='2016-01-10' );
delimiter;
insert into ld_workingdays(workcalender_year,date,workingdaytype,remark,workcalender_id)
select '2016','2016-01-11',2,'春节放假',1 from dual
where not exists(select 1 from ld_workingdays where date='2016-01-11' );
delimiter;
insert into ld_workingdays(workcalender_year,date,workingdaytype,remark,workcalender_id)
select '2016','2016-01-12',2,'春节放假',1 from dual
where not exists(select 1 from ld_workingdays where date='2016-01-12' );
delimiter;
insert into ld_workingdays(workcalender_year,date,workingdaytype,remark,workcalender_id)
select '2016','2016-01-13',2,'春节放假',1 from dual
where not exists(select 1 from ld_workingdays where date='2016-01-13' );
delimiter;
insert into ld_workingdays(workcalender_year,date,workingdaytype,remark,workcalender_id)
select '2016','2016-04-02',2,'清明假',1 from dual
where not exists(select 1 from ld_workingdays where date='2016-04-02' );
delimiter;
insert into ld_workingdays(workcalender_year,date,workingdaytype,remark,workcalender_id)
select '2016','2016-04-03',2,'清明假',1 from dual
where not exists(select 1 from ld_workingdays where date='2016-04-03' );
delimiter;
insert into ld_workingdays(workcalender_year,date,workingdaytype,remark,workcalender_id)
select '2016','2016-04-04',2,'清明假',1 from dual
where not exists(select 1 from ld_workingdays where date='2016-04-04' );
delimiter;
insert into ld_workingdays(workcalender_year,date,workingdaytype,remark,workcalender_id)
select '2016','2016-04-30',2,'五一假',1 from dual
where not exists(select 1 from ld_workingdays where date='2016-04-30' );
delimiter;
insert into ld_workingdays(workcalender_year,date,workingdaytype,remark,workcalender_id)
select '2016','2016-05-01',2,'五一假',1 from dual
where not exists(select 1 from ld_workingdays where date='2016-05-01' );
delimiter;
insert into ld_workingdays(workcalender_year,date,workingdaytype,remark,workcalender_id)
select '2016','2016-05-01',2,'五一假',1 from dual
where not exists(select 1 from ld_workingdays where date='2016-05-01' );
delimiter;
insert into ld_workingdays(workcalender_year,date,workingdaytype,remark,workcalender_id)
select '2016','2016-06-09',2,'端午假',1 from dual
where not exists(select 1 from ld_workingdays where date='2016-06-09' );
delimiter;
insert into ld_workingdays(workcalender_year,date,workingdaytype,remark,workcalender_id)
select '2016','2016-06-10',2,'端午假',1 from dual
where not exists(select 1 from ld_workingdays where date='2016-06-10' );
delimiter;
insert into ld_workingdays(workcalender_year,date,workingdaytype,remark,workcalender_id)
select '2016','2016-06-11',2,'端午假',1 from dual
where not exists(select 1 from ld_workingdays where date='2016-06-11' );
delimiter;
insert into ld_workingdays(workcalender_year,date,workingdaytype,remark,workcalender_id)
select '2016','2016-09-15',2,'中秋假',1 from dual
where not exists(select 1 from ld_workingdays where date='2016-09-15' );
delimiter;
insert into ld_workingdays(workcalender_year,date,workingdaytype,remark,workcalender_id)
select '2016','2016-09-16',2,'中秋假',1 from dual
where not exists(select 1 from ld_workingdays where date='2016-09-16' );
delimiter;
insert into ld_workingdays(workcalender_year,date,workingdaytype,remark,workcalender_id)
select '2016','2016-09-17',2,'中秋假',1 from dual
where not exists(select 1 from ld_workingdays where date='2016-09-17' );
delimiter;
insert into ld_workingdays(workcalender_year,date,workingdaytype,remark,workcalender_id)
select '2016','2016-10-01',2,'国庆假',1 from dual
where not exists(select 1 from ld_workingdays where date='2016-10-01' );
delimiter;
insert into ld_workingdays(workcalender_year,date,workingdaytype,remark,workcalender_id)
select '2016','2016-10-02',2,'国庆假',1 from dual
where not exists(select 1 from ld_workingdays where date='2016-10-02' );
delimiter;
insert into ld_workingdays(workcalender_year,date,workingdaytype,remark,workcalender_id)
select '2016','2016-10-03',2,'国庆假',1 from dual
where not exists(select 1 from ld_workingdays where date='2016-10-03' );
delimiter;
insert into ld_workingdays(workcalender_year,date,workingdaytype,remark,workcalender_id)
select '2016','2016-10-04',2,'国庆假',1 from dual
where not exists(select 1 from ld_workingdays where date='2016-10-04' );
delimiter;
insert into ld_workingdays(workcalender_year,date,workingdaytype,remark,workcalender_id)
select '2016','2016-10-05',2,'国庆假',1 from dual
where not exists(select 1 from ld_workingdays where date='2016-10-05' );
delimiter;
insert into ld_workingdays(workcalender_year,date,workingdaytype,remark,workcalender_id)
select '2016','2016-10-06',2,'国庆假',1 from dual
where not exists(select 1 from ld_workingdays where date='2016-10-06' );
delimiter;
insert into ld_workingdays(workcalender_year,date,workingdaytype,remark,workcalender_id)
select '2016','2016-10-07',2,'国庆假',1 from dual
where not exists(select 1 from ld_workingdays where date='2016-10-07' );
delimiter;
SELECT tabid INTO @tabid from ld_tab where `name`='Users';
SELECT sequence INTO @sequence from ld_blocks where tabid=@tabid  AND blocklabel='LBL_ATTACHMENTS_INFOMATION';
SELECT max(blockid) INTO @blockid from ld_blocks ;
insert into ld_blocks(blockid,tabid,blocklabel,sequence,show_title,visible,create_view,edit_view,detail_view,display_status,iscustom)
select @blockid+1,@tabid,'LBL_TRACKPOSTIONINGGROUP',@sequence-1,0,0,0,0,0,1,0 from dual
where not exists(select 1 from ld_blocks where tabid=@tabid AND blocklabel='LBL_TRACKPOSTIONINGGROUP');
delimiter;

SELECT tabid INTO @tabid from ld_tab where `name`='Users';
insert into ld_field(tabid,fieldid,columnname,tablename,uitype,fieldname,fieldlabel,block,displaytype,presence,typeofdata,generatedtype,sequence,issmownerid)
select @tabid,(select max(fieldid) from ld_field)+1,'trackgroupid','ld_users',601,'trackpostion','定位组名称',(select blockid from ld_blocks where blocklabel = 'LBL_TRACKPOSTIONINGGROUP'),1,0,'V~O',1,1,0 from dual where not exists
(select 1 from ld_field where tabid = @tabid and columnname = 'trackgroupid');
delimiter;
select blockid into @blockid from ld_blocks where tabid = @tabid and blocklabel = 'LBL_TRACKPOSTIONINGGROUP';
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'zh','ld_blocks',@tabid,@blockid ,'轨迹定位组'
from dual where not EXISTS(select 1 from ld_tranlabel  where languagetype = 'zh'
and trantable ='ld_blocks' and tabid = @tabid and relateid=@blockid);
delimiter;

insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'en','ld_blocks',@tabid,@blockid,'Track Positioning Group'
from dual where not EXISTS(select 1 from ld_tranlabel  where languagetype = 'en'
and trantable ='ld_blocks' and tabid = @tabid and relateid=@blockid);
delimiter;
select fieldid into @fieldid from ld_field where tabid = @tabid and fieldname = 'trackpostion';
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'zh','ld_field',@tabid,@fieldid,'定位组名称'
from dual where not EXISTS(select 1 from ld_tranlabel  where languagetype = 'zh'
and trantable ='ld_field' and tabid = @tabid and relateid=@fieldid);
delimiter;
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'en','ld_field',@tabid,@fieldid,'Track group name'
from dual where not EXISTS(select 1 from ld_tranlabel  where languagetype = 'en'
and trantable ='ld_field' and tabid = @tabid and relateid=@fieldid);
delimiter;

CREATE TABLE if not exists`ld_usertrack` (
  `id` int(19) NOT NULL auto_increment,
  `longtitude` varchar(100) default NULL,
  `latitude` varchar(100) default NULL,
  `userid` int(19) default NULL,
  `createdtime` datetime default NULL,
  `address` varchar(300) default NULL,
  `distince` decimal(20,2) default NULL,
  PRIMARY KEY  (`id`),
  KEY `idx_usertrack_userid_createdtime` USING BTREE (`userid`,`createdtime`)
) ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=utf8;
delimiter;
-- 2016-03-25

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','BEGINTIME','起始时间','jspop' from dual
where not exists(select 1 from ld_desk where labelbol = 'BEGINTIME' and languagetype = 'zh' and labeltype = 'jspop');
delimiter;
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','BEGINTIME','Begin Time','jspop' from dual
where not exists(select 1 from ld_desk where labelbol = 'BEGINTIME' and languagetype = 'en' and labeltype = 'jspop');
delimiter;
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','GREATETHAN','应该大于','jspop' from dual
where not exists(select 1 from ld_desk where labelbol = 'GREATETHAN' and languagetype = 'zh' and labeltype = 'jspop');
delimiter;
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','GREATETHAN','Greater Than','jspop' from dual
where not exists(select 1 from ld_desk where labelbol = 'GREATETHAN' and languagetype = 'en' and labeltype = 'jspop');
delimiter;

select usereportid into @usereportid from ld_usereport where `name` = 'PurchaseOrderTrack';
UPDATE ld_usereportcolumns SET realcolumns = 'ld_SendCashBill:SendCashBillamount:SendCashBillamount:OftenUseReport_已付款金额:N'
,realencolumns = 'ld_SendCashBill:SendCashBillamount:SendCashBillamount:OftenUseReport_Payed Amount:N'
WHERE Usereportid = @usereportid AND `columns` = 'ld_SendCashBill:SendCashBillamount:SendCashBillamount:OftenUseReport_SendCashBillamount:N';
delimiter;

select usereportid into @usereportid from ld_usereport where `name` = 'PurchaseOrderTrack';
SELECT sequence INTO @sequence FROM ld_usereportcolumns WHERE columns = 'ld_SendCashBill:SendCashBillamount:SendCashBillamount:OftenUseReport_SendCashBillamount:N' AND Usereportid = @usereportid;
UPDATE ld_usereportcolumns SET Sequence = Sequence + 1 WHERE usereportid = 10 AND Sequence > @sequence;
INSERT INTO ld_usereportcolumns(Usereportid,columns,Sequence,columnshow,realcolumns,realencolumns)
SELECT @usereportid,'ld_SendCashBill:SendCashBillbalance:SendCashBillbalance:OftenUseReport_SendCashBillbalance:N',@sequence+1,1,'ld_SendCashBill:SendCashBillbalance:SendCashBillbalance:OftenUseReport_应付款余额:N','ld_SendCashBill:SendCashBillbalance:SendCashBillbalance:OftenUseReport_Payable Balance:N'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM ld_usereportcolumns WHERE Usereportid = @usereportid AND columns = 'ld_SendCashBill:SendCashBillbalance:SendCashBillbalance:OftenUseReport_SendCashBillbalance:N');
delimiter;

select usereportid into @usereportid from ld_usereport where `name` = 'PurchaseOrderTrack';
SELECT sequence INTO @sequence FROM ld_usereportcolumns WHERE columns = 'ld_SendCashBill:SendCashBillbalance:SendCashBillbalance:OftenUseReport_SendCashBillbalance:N' AND Usereportid = @usereportid;
UPDATE ld_usereportcolumns SET Sequence = Sequence + 1 WHERE usereportid = 10 AND Sequence > @sequence;
INSERT INTO ld_usereportcolumns(Usereportid,columns,Sequence,columnshow,realcolumns,realencolumns)
SELECT 10,'ld_SendCashBill:InvoiceBalance:InvoiceBalance:OftenUseReport_InvoiceBalance:N',@sequence+1,1,'ld_SendCashBill:InvoiceBalance:InvoiceBalance:OftenUseReport_开票余额:N','ld_SendCashBill:InvoiceBalance:InvoiceBalance:OftenUseReport_Invoice Balance:N'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM ld_usereportcolumns WHERE Usereportid = 10 AND columns = 'ld_SendCashBill:InvoiceBalance:InvoiceBalance:OftenUseReport_InvoiceBalance:N');
delimiter;

select usereportid into @usereportid from ld_usereport where `name` = 'PurchaseOrderTrack';
set @i=0;
UPDATE ld_usereportcolumns SET sequence=(@i:=@i+1) WHERE usereportid = @usereportid order by sequence asc;
delimiter;

select max(sequence)+1 into @sequence from ld_systems_deploy;
insert into ld_systems_deploy(deploy_value,deploy_type,description,setype,sequence)
select 1,96,'市场活动是否启用审批流程。1:否，0:是','Campaigns',@sequence from dual
where not EXISTS(select 1 from ld_systems_deploy where deploy_type=96);
delimiter;

CALL AddColumn('ld_campaign','approveby','int','19','0');
delimiter;
CALL AddColumn('ld_campaign','approvestatus','varchar','200',Null);
delimiter;

alter table ld_campaign alter approvestatus set default '未提交';

call fieldprofile('Campaigns');
delimiter;

call getallprofile('Campaigns');
delimiter;

select tabid into @tabid from ld_tab where name='Campaigns';
insert into ld_field(tabid,fieldid,columnname,tablename,uitype,fieldname,fieldlabel,block,displaytype,presence,typeofdata)
select @tabid,(select max(fieldid) from ld_field)+1,'approveby','ld_campaign',131,'approveby','审批人',(select blockid from ld_blocks where blocklabel='LBL_CAMPAIGN_INFORMATION'),1,0,'V~O' from dual where not EXISTS(select * from ld_field where tabid=@tabid and columnname='approveby');
insert into ld_field(tabid,fieldid,columnname,tablename,uitype,fieldname,fieldlabel,block,displaytype,presence,typeofdata)
select @tabid,(select max(fieldid) from ld_field)+1,'approvestatus','ld_campaign',130,'approvestatus','审批状态',(select blockid from ld_blocks where blocklabel='LBL_CAMPAIGN_INFORMATION'),1,0,'V~O' from dual where not EXISTS(select * from ld_field where tabid=@tabid and columnname='approvestatus');
delimiter;

select fieldid into @fieldid from ld_field where tabid = @tabid and fieldname = 'approveby';
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'zh','ld_field',@tabid,@fieldid,'审批人'
from dual where not EXISTS(select 1 from ld_tranlabel  where languagetype = 'zh'
and trantable ='ld_field' and tabid = @tabid and relateid=@fieldid);
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'en','ld_field',@tabid,@fieldid,'Approver'
from dual where not EXISTS(select 1 from ld_tranlabel  where languagetype = 'en'
and trantable ='ld_field' and tabid = @tabid and relateid=@fieldid);
delimiter;

select fieldid into @fieldid from ld_field where tabid = @tabid and fieldname = 'approvestatus';
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'zh','ld_field',@tabid,@fieldid,'审批状态'
from dual where not EXISTS(select 1 from ld_tranlabel  where languagetype = 'zh'
and trantable ='ld_field' and tabid = @tabid and relateid=@fieldid);
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'en','ld_field',@tabid,@fieldid,'Approve Status'
from dual where not EXISTS(select 1 from ld_tranlabel  where languagetype = 'en'
and trantable ='ld_field' and tabid = @tabid and relateid=@fieldid);
delimiter;

select tabid into @tabid from ld_tab where name='Campaigns';
insert into ld_approve(id,tabid,name,status,smcreatorid,modifiedby,createdtime,modifiedtime,approveallocatetype)
select (select max(id) from ld_approve)+1,@tabid,'市场活动默认流程',0,1,1,NOW(),NOW(),0
from dual where not EXISTS(select * from ld_approve where tabid=@tabid and name='市场活动默认流程');

select id into @id from ld_approve where tabid=@tabid and name='市场活动默认流程';
insert into ld_approvestep(id,approveid,name,ended,step,sequence,createdtime,modifiedtime,approvetype,approvevalue,specifyapproverid)
select (select max(id) from ld_approvestep)+1,@id,'步骤一',1,1,1,NOW(),NOW(),0,1,1
from dual where not EXISTS(select 1 from ld_approvestep where approveid=@id and name='步骤一');
insert into ld_approvestep(id,approveid,name,ended,step,sequence,createdtime,modifiedtime,approvetype,approvevalue,specifyapproverid)
select (select max(id) from ld_approvestep)+1,@id,'步骤二',1,1,2,NOW(),NOW(),0,1,1
from dual where not EXISTS(select 1 from ld_approvestep where approveid=@id and name='步骤二');

insert into ld_approve2user(approveid,userid)
select @id,-1 from dual
where not EXISTS(select 1 from ld_approve2user where approveid=@id and userid=-1);
delimiter;
-- 2016-03-30

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
delimiter;

update ld_version set old_version='V6.3.0' ,current_version='V6.3.0' ,remark='V6.3.0-20160330';
delimiter;