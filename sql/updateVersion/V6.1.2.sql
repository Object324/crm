select tabid into @tabid from ld_tab where `name` = 'Checks';
select producttoolfieldid into @producttoolfieldid from ld_producttoolfield where tabid = @tabid and columnname = 'profitloss' and input_type = 2 and defaultcolumn = 3;
update ld_producttoolfield_formula set formulastring = 'a-(b)' where producttoolfieldid = @producttoolfieldid;
delimiter;
-- 2015-08-12

select tabid into @tabid from ld_tab where `name`='Productbom';
select sequence into @seq from ld_producttoolfield where tabid=@tabid and columnname='taxprice';
update ld_producttoolfield set sequence=sequence+5 where tabid=@tabid and sequence>=@seq;
update ld_producttoolfield set sequence=@seq-1,uitype=1 where tabid=@tabid and columnname='unit_price';
set @i=0;
update ld_producttoolfield set sequence=(@i:=@i+1) where tabid=@tabid order by sequence;
delimiter;

update ld_field set sequence=sequence+10 where tabid=19 and block=46;
update ld_field set sequence=1 where tabid=19 and block=46 and columnname='bookname';
update ld_field set sequence=2 where tabid=19 and block=46 and columnname='pricebook_no';
update ld_field set sequence=3 where tabid=19 and block=46 and columnname='currency_id';
update ld_field set sequence=4 where tabid=19 and block=46 and columnname='active';
update ld_field set sequence=5 where tabid=19 and block=46 and columnname='smownerid';
set @i=0;
update ld_field set sequence=(@i:=@i+1) where tabid=19 and block=46 order by sequence;
delimiter;

update ld_producttoolfield set tablename = 'ld_productcf' where tablename = 'ld_products' and columnname like 'cf_%';
delimiter;

select tabid into @tabid from ld_tab where `name` = 'CashBill';
update ld_field set presence = 1 where tabid = @tabid and fieldname = 'salesorder_id';
delete from ld_field where tabid = @tabid and fieldname = 'salesorder_id';
delimiter;
-- 2015-08-13

UPDATE ld_field set searchfieldtype=0 WHERE tabid=(SELECT tabid FROM ld_tab WHERE name='ProjectTask') 
and columnname in ('projecttask_no','projectid');
delimiter;
-- 2015-08-14

DROP PROCEDURE IF EXISTS `DEL_FK`;
delimiter ||
CREATE DEFINER=`root`@`localhost` PROCEDURE `DEL_FK`(
	tablename varchar(200),
	fkname varchar(200)
)
BEGIN
  SELECT DATABASE() INTO @tableschema;
	SET tablename=LOWER(tablename);

	set@cnt=0;
  SET @tsql=CONCAT(' alter table ', tablename, ' drop foreign key ', fkname);
  select count(*) INTO @cnt FROM information_schema.key_column_usage WHERE TABLE_NAME=tablename and CONSTRAINT_NAME=fkname and TABLE_SCHEMA=@tableschema;
  IF @cnt >0 THEN
    PREPARE stmt FROM @tsql;
    EXECUTE stmt;
  END IF;
end ||
delimiter;

call DEL_FK('ld_purchaseorder','ld_purchaseorder_ibfk_1');
delimiter;

update ld_desk set fieldlabel = '根节点下显示无部门用户（用户姓名显示为红色字体）' where labelbol = 'SHOWNOGROUPUSER' and languagetype = 'zh';
delimiter;

insert into ld_desk (languagetype,labelbol,fieldlabel,Labeltype)
select 'zh','Download Browse Record','下载浏览记录','fixedstr'
from dual where not exists (select 1 from ld_desk where labelbol ='Download Browse Record' and languagetype='zh' and  Labeltype='fixedstr');
delimiter;
insert into ld_desk (languagetype,labelbol,fieldlabel,Labeltype)
select 'en','Download Browse Record','Download Browse Record','fixedstr'
from dual where not exists (select 1 from ld_desk where labelbol ='Download Browse Record' and languagetype='en' and Labeltype='fixedstr');
delimiter;
insert into ld_desk (languagetype,labelbol,fieldlabel,Labeltype)
select 'zh','OPERATMETHOD','操作方式','fixedstr'
from dual where not exists (select 1 from ld_desk where labelbol ='OPERATMETHOD' and languagetype='zh' and Labeltype='fixedstr');
delimiter;
insert into ld_desk (languagetype,labelbol,fieldlabel,Labeltype)
select 'en','OPERATMETHOD','Operating method','fixedstr'
from dual where not exists (select 1 from ld_desk where labelbol ='OPERATMETHOD' and languagetype='en' and Labeltype='fixedstr');
delimiter;
select id into @id from ld_relatedlists_seq;
select tabid into @tabid from ld_tab WHERE name='Attachment';
insert into ld_relatedlists (relation_id,tabid,related_tabid,name,sequence,label, presence,actions)
select @id+1,@tabid,0,'getAuditTrialLog','0','Download Browse Record',0,''
from dual where not exists (select 1 from ld_relatedlists where tabid =@tabid and name ='getAuditTrialLog');
update ld_relatedlists_seq set id=(select max(relation_id) from ld_relatedlists);
delimiter;
call AddColumn('ld_audit_trial','recordname','varchar','200',NULL);
delimiter;
delete from ld_audit_trial where action = 'Authenticate';
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','ALLTHEUSERS','所有用户 ','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol = 'ALLTHEUSERS' and languagetype = 'zh' and labeltype = 'fixedstr');
delimiter;
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','ALLTHEUSERS','all the users','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol = 'ALLTHEUSERS' and languagetype = 'en' and labeltype = 'fixedstr');
delimiter;
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','ALLTHEUSERS','所有用户 ','jspop' from dual
where not exists(select 1 from ld_desk where labelbol = 'ALLTHEUSERS' and languagetype = 'zh' and labeltype = 'jspop');
delimiter;
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','ALLTHEUSERS','all the users','jspop' from dual
where not exists(select 1 from ld_desk where labelbol = 'ALLTHEUSERS' and languagetype = 'en' and labeltype = 'jspop');
delimiter;
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','SELECTTHEUSERS','部分用户 ','jspop' from dual
where not exists(select 1 from ld_desk where labelbol = 'SELECTTHEUSERS' and languagetype = 'zh' and labeltype = 'jspop');
delimiter;
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','SELECTTHEUSERS','select the users','jspop' from dual
where not exists(select 1 from ld_desk where labelbol = 'SELECTTHEUSERS' and languagetype = 'en' and labeltype = 'jspop');
delimiter;
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','ALLOWSYOUTOSPECIFYUSERTHETEMPLATE','只允许指定用户使用该模板 ','jspop' from dual
where not exists(select 1 from ld_desk where labelbol = 'ALLOWSYOUTOSPECIFYUSERTHETEMPLATE' and languagetype = 'zh' and labeltype = 'jspop');
delimiter;
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','ALLOWSYOUTOSPECIFYUSERTHETEMPLATE','Allows you to specify a user only use the template ','jspop' from dual
where not exists(select 1 from ld_desk where labelbol = 'ALLOWSYOUTOSPECIFYUSERTHETEMPLATE' and languagetype = 'en' and labeltype = 'jspop');
delimiter;

select max(sequence) into @sequence from ld_systems_deploy;
insert into ld_systems_deploy(deploy_value,deploy_type,description,setype,sequence)
select '0',77,'同名附件上传限制方式 0:不限制，1:提示，2:禁止','',@sequence+1 from dual
where not exists(select 1 from ld_systems_deploy where description= '同名附件上传限制方式 0:不限制，1:提示，2:禁止' and deploy_type=77 );
delimiter;
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','CONTROLMODEUPLOADEDSAMENAMEATTACHMENT','同名附件上传限制方式','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol = 'CONTROLMODEUPLOADEDSAMENAMEATTACHMENT' and languagetype = 'zh' and labeltype = 'fixedstr');
delimiter;
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','CONTROLMODEUPLOADEDSAMENAMEATTACHMENT','The control mode about uploaded the same name attachment','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol = 'CONTROLMODEUPLOADEDSAMENAMEATTACHMENT' and languagetype = 'en' and labeltype = 'fixedstr');
delimiter;
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','FORBID','禁止','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol = 'FORBID' and languagetype = 'zh' and labeltype = 'fixedstr');
delimiter;
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','FORBID','Forbid','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol = 'FORBID' and languagetype = 'en' and labeltype = 'fixedstr');
delimiter;
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','NOLIMITS','不限制','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol = 'NOLIMITS' and languagetype = 'zh' and labeltype = 'fixedstr');
delimiter;
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','NOLIMITS','No limits','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol = 'NOLIMITS' and languagetype = 'en' and labeltype = 'fixedstr');
delimiter;
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','WARNNING','提示','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol = 'WARNNING' and languagetype = 'zh' and labeltype = 'fixedstr');
delimiter;
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','WARNNING','Warnning','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol = 'WARNNING' and languagetype = 'en' and labeltype = 'fixedstr');
delimiter;
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','ALREADYEXISTSATTACHMENT','已存在同名附件','jspop' from dual
where not exists(select 1 from ld_desk where labelbol = 'ALREADYEXISTSATTACHMENT' and languagetype = 'zh' and labeltype = 'jspop');
delimiter;
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','ALREADYEXISTSATTACHMENT','Already exists with the same name attachment','jspop' from dual
where not exists(select 1 from ld_desk where labelbol = 'ALREADYEXISTSATTACHMENT' and languagetype = 'en' and labeltype = 'jspop');
delimiter;
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','WHETHERTOCONTINUE','是否继续？','jspop' from dual
where not exists(select 1 from ld_desk where labelbol = 'WHETHERTOCONTINUE' and languagetype = 'zh' and labeltype = 'jspop');
delimiter;
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','WHETHERTOCONTINUE','whether to continue?','jspop' from dual
where not exists(select 1 from ld_desk where labelbol = 'WHETHERTOCONTINUE' and languagetype = 'en' and labeltype = 'jspop');
delimiter;
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','NOTALLOWEDTOUPLOAD','不允许再上传！','jspop' from dual
where not exists(select 1 from ld_desk where labelbol = 'NOTALLOWEDTOUPLOAD' and languagetype = 'zh' and labeltype = 'jspop');
delimiter;
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','NOTALLOWEDTOUPLOAD','not allowed to upload!','jspop' from dual
where not exists(select 1 from ld_desk where labelbol = 'NOTALLOWEDTOUPLOAD' and languagetype = 'en' and labeltype = 'jspop');
delimiter;

select tabid into @tabid from ld_tab WHERE name='Attachment';
delete from ld_relatedlists where `name` = 'get_attachmentrecord' and tabid = @tabid;
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','SELECTTHEUSERS','部分用户 ','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol = 'SELECTTHEUSERS' and languagetype = 'zh' and labeltype = 'fixedstr');
delimiter;
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','SELECTTHEUSERS','select the users','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol = 'SELECTTHEUSERS' and languagetype = 'en' and labeltype = 'fixedstr');
delimiter;

update ld_desk set fieldlabel = '注意事项' where languagetype = 'zh' and labelbol = 'NOTE' and Labeltype = 'fixedstr';
delimiter;
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','AUTOMATICDIALINGPREFIX','软拨号自动加拨前缀','fixedstr'
from dual where not exists(select 1 from ld_desk where languagetype = 'zh' and labelbol = 'AUTOMATICDIALINGPREFIX' and labeltype = 'fixedstr');
delimiter;
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','AUTOMATICDIALINGPREFIX','Automatic dialing prefix','fixedstr'
from dual where not exists(select 1 from ld_desk where languagetype = 'en' and labelbol = 'AUTOMATICDIALINGPREFIX' and labeltype = 'fixedstr');
delimiter;
select max(sequence) into @sequence from ld_systems_deploy;
insert into ld_systems_deploy(deploy_value,deploy_type,description,setype,sequence)
select '',76,'软拨号自动加拨前缀','',@sequence from dual where not exists(select 1 from ld_systems_deploy where deploy_type = 76);
delimiter;


select tabid into @tabid from ld_tab where `name` = 'BankAccountSet';
update ld_tranlabel set fieldlabel = '银行账户' where tabid = @tabid and trantable = 'ld_tab' and languagetype = 'zh' and fieldlabel = '银行初始化';
delimiter;

delete from ld_tranlabel where relateid in(select fieldid from ld_field where tabid=8 and columnname='filedownloadcount') and trantable='ld_field' and tabid=8;
delete from ld_field where tabid=8 and columnname='filedownloadcount';
-- 2015-08-20

update ld_field set uitype=5 where tabid=2 and columnname='closingdate';
update ld_field set uitype=5 where tabid=37 and columnname='due_date';
update ld_field set uitype=5 where tabid=48 and columnname in('targetenddate','actualenddate','startdate');
update ld_field set uitype=5 where tabid=26 and columnname in('closingdate','startdate');
select  tabid into @tabid from ld_tab where name='VendorContact';
update ld_field set uitype=15 where tabid=@tabid and columnname='salutation';
update ld_field set uitype=15 where tabid=4 and columnname='salutation';
select tabid into @tabid from ld_tab where name='documents';
select max(fieldid)into @fieldid from ld_field;
update ld_field_seq set id=@fieldid+1 where not EXISTS(select 1 from ld_field where tabid=@tabid and  columnname='filedownloadcount');
insert into ld_field (tabid,fieldid,columnname,tablename,generatedtype,uitype,fieldname,fieldlabel,readonly,presence,maximumlength,sequence,block,displaytype,typeofdata,quickcreate,quickcreatesequence,info_type,masseditable)
select @tabid,@fieldid+1,'filedownloadcount','ld_notes',1,1,'filedownloadcount','下载次数',1,2,100,7,18,2,'I~O',3,0,'BAS',0
from dual where not EXISTS(select 1 from ld_field where tabid=@tabid and  columnname='filedownloadcount');
select fieldid into @relateid from ld_field where tabid=@tabid  and  columnname='filedownloadcount';
insert into ld_tranlabel(LANGUAGEtype,trantable,tabid,relateid,fieldlabel)
SELECT  'zh','ld_field',@tabid,@fieldid,'下载次数' from dual where not exists(select 1 from ld_tranlabel where languagetype='zh' and relateid=@fieldid and trantable='ld_field');
insert into ld_tranlabel(LANGUAGEtype,trantable,tabid,relateid,fieldlabel)
SELECT  'en','ld_field',@tabid,@fieldid,'down load count' from dual where not exists(select 1 from ld_tranlabel where languagetype='en' and relateid=@fieldid and trantable='ld_field');
delimiter;
-- 2015-08-25

select max(sequence) into @sequence from ld_systems_deploy;
insert into ld_systems_deploy(deploy_value,deploy_type,description,setype,sequence)
select '0',78,'设置首页组件中周月统计是否显示 0:是，1:否','',@sequence+1 from dual
where not exists(select 1 from ld_systems_deploy where description= '设置首页组件中周月统计是否显示 0:是，1:否' and deploy_type=78 );
update ld_relatedlists_seq set id=(select max(relation_id) from ld_relatedlists);
delimiter;
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','DISPLAYWEEKMONTHSTATISTICSHOMEPAGE','设置首页组件中周月统计是否显示','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol = 'DISPLAYWEEKMONTHSTATISTICSHOMEPAGE' and languagetype = 'zh' and labeltype = 'fixedstr');
delimiter;
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','DISPLAYWEEKMONTHSTATISTICSHOMEPAGE','Whether to display the week and month statistics in homepage','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol = 'DISPLAYWEEKMONTHSTATISTICSHOMEPAGE' and languagetype = 'en' and labeltype = 'fixedstr');
delimiter;
insert into ld_desk (languagetype,labelbol,fieldlabel,Labeltype)
select 'zh','LASTSTATICOFTHISMONTH','上月统计','fixedstr'
from dual where not exists (select 1 from ld_desk where labelbol ='LASTSTATICOFTHISMONTH' and languagetype='zh' and  Labeltype='fixedstr');
delimiter;
insert into ld_desk (languagetype,labelbol,fieldlabel,Labeltype)
select 'en','LASTSTATICOFTHISMONTH','Last statistics of this month','fixedstr'
from dual where not exists (select 1 from ld_desk where labelbol ='LASTSTATICOFTHISMONTH' and languagetype='en' and Labeltype='fixedstr');
delimiter;
insert into ld_desk (languagetype,labelbol,fieldlabel,Labeltype)
select 'zh','LASTSTATICOFTHISWEEK','上周统计','fixedstr'
from dual where not exists (select 1 from ld_desk where labelbol ='LASTSTATICOFTHISWEEK' and languagetype='zh' and  Labeltype='fixedstr');
delimiter;
insert into ld_desk (languagetype,labelbol,fieldlabel,Labeltype)
select 'en','LASTSTATICOFTHISWEEK','Last statistics of this week','fixedstr'
from dual where not exists (select 1 from ld_desk where labelbol ='LASTSTATICOFTHISWEEK' and languagetype='en' and Labeltype='fixedstr');
delimiter;
insert into ld_desk (languagetype,labelbol,fieldlabel,Labeltype)
select 'zh','LASTMONTHTHENUMBEROFNEWACCOUNTS','上月新增客户数','fixedstr'
from dual where not exists (select 1 from ld_desk where labelbol ='LASTMONTHTHENUMBEROFNEWACCOUNTS' and languagetype='zh' and  Labeltype='fixedstr');
delimiter;
insert into ld_desk (languagetype,labelbol,fieldlabel,Labeltype)
select 'en','LASTMONTHTHENUMBEROFNEWACCOUNTS','Last month the number of new accounts','fixedstr'
from dual where not exists (select 1 from ld_desk where labelbol ='LASTMONTHTHENUMBEROFNEWACCOUNTS' and languagetype='en' and Labeltype='fixedstr');
delimiter;
insert into ld_desk (languagetype,labelbol,fieldlabel,Labeltype)
select 'zh','LASTWEEKTHENUMBEROFNEWACCOUNTS','上周新增客户数','fixedstr'
from dual where not exists (select 1 from ld_desk where labelbol ='LASTWEEKTHENUMBEROFNEWACCOUNTS' and languagetype='zh' and  Labeltype='fixedstr');
delimiter;
insert into ld_desk (languagetype,labelbol,fieldlabel,Labeltype)
select 'en','LASTWEEKTHENUMBEROFNEWACCOUNTS','Last week the number of new accounts','fixedstr'
from dual where not exists (select 1 from ld_desk where labelbol ='LASTWEEKTHENUMBEROFNEWACCOUNTS' and languagetype='en' and Labeltype='fixedstr');
delimiter;
insert into ld_desk (languagetype,labelbol,fieldlabel,Labeltype)
select 'zh','LASTMONTHTHENUMBEROFCONTACTRECORDS','上月新增联系记录数','fixedstr'
from dual where not exists (select 1 from ld_desk where labelbol ='LASTMONTHTHENUMBEROFCONTACTRECORDS' and languagetype='zh' and  Labeltype='fixedstr');
delimiter;
insert into ld_desk (languagetype,labelbol,fieldlabel,Labeltype)
select 'en','LASTMONTHTHENUMBEROFCONTACTRECORDS','Last month the number of new contact records','fixedstr'
from dual where not exists (select 1 from ld_desk where labelbol ='LASTMONTHTHENUMBEROFCONTACTRECORDS' and languagetype='en' and Labeltype='fixedstr');
delimiter;
insert into ld_desk (languagetype,labelbol,fieldlabel,Labeltype)
select 'zh','LASTWEEKTHENUMBEROFCONTACTRECORDS','上周新增联系记录数','fixedstr'
from dual where not exists (select 1 from ld_desk where labelbol ='LASTWEEKTHENUMBEROFCONTACTRECORDS' and languagetype='zh' and  Labeltype='fixedstr');
delimiter;
insert into ld_desk (languagetype,labelbol,fieldlabel,Labeltype)
select 'en','LASTWEEKTHENUMBEROFCONTACTRECORDS','Last week the number of new contact records','fixedstr'
from dual where not exists (select 1 from ld_desk where labelbol ='LASTWEEKTHENUMBEROFCONTACTRECORDS' and languagetype='en' and Labeltype='fixedstr');
delimiter;
insert into ld_desk (languagetype,labelbol,fieldlabel,Labeltype)
select 'zh','LASTMONTHTHENUMBEROFNEWCONTRACTS','上月签约数量','fixedstr'
from dual where not exists (select 1 from ld_desk where labelbol ='LASTMONTHTHENUMBEROFNEWCONTRACTS' and languagetype='zh' and  Labeltype='fixedstr');
delimiter;
insert into ld_desk (languagetype,labelbol,fieldlabel,Labeltype)
select 'en','LASTMONTHTHENUMBEROFNEWCONTRACTS','Last month the number of new contracts','fixedstr'
from dual where not exists (select 1 from ld_desk where labelbol ='LASTMONTHTHENUMBEROFNEWCONTRACTS' and languagetype='en' and Labeltype='fixedstr');
delimiter;
insert into ld_desk (languagetype,labelbol,fieldlabel,Labeltype)
select 'zh','LASTWEEKTHENUMBEROFNEWCONTRACTS','上周签约数量','fixedstr'
from dual where not exists (select 1 from ld_desk where labelbol ='LASTWEEKTHENUMBEROFNEWCONTRACTS' and languagetype='zh' and  Labeltype='fixedstr');
delimiter;
insert into ld_desk (languagetype,labelbol,fieldlabel,Labeltype)
select 'en','LASTWEEKTHENUMBEROFNEWCONTRACTS','Last week the number of new contracts','fixedstr'
from dual where not exists (select 1 from ld_desk where labelbol ='LASTWEEKTHENUMBEROFNEWCONTRACTS' and languagetype='en' and Labeltype='fixedstr');
delimiter;
insert into ld_desk (languagetype,labelbol,fieldlabel,Labeltype)
select 'zh','LASTMONTHTHEAMOUNTOFNEWCONTRACTS','上月签约金额','fixedstr'
from dual where not exists (select 1 from ld_desk where labelbol ='LASTMONTHTHEAMOUNTOFNEWCONTRACTS' and languagetype='zh' and  Labeltype='fixedstr');
delimiter;
insert into ld_desk (languagetype,labelbol,fieldlabel,Labeltype)
select 'en','LASTMONTHTHEAMOUNTOFNEWCONTRACTS','Last month the amount of new contracts','fixedstr'
from dual where not exists (select 1 from ld_desk where labelbol ='LASTMONTHTHEAMOUNTOFNEWCONTRACTS' and languagetype='en' and Labeltype='fixedstr');
delimiter;
insert into ld_desk (languagetype,labelbol,fieldlabel,Labeltype)
select 'zh','LASTWEEKTHEAMOUNTOFNEWCONTRACTS','上周签约金额','fixedstr'
from dual where not exists (select 1 from ld_desk where labelbol ='LASTWEEKTHEAMOUNTOFNEWCONTRACTS' and languagetype='zh' and  Labeltype='fixedstr');
delimiter;
insert into ld_desk (languagetype,labelbol,fieldlabel,Labeltype)
select 'en','LASTWEEKTHEAMOUNTOFNEWCONTRACTS','Last week the amount of new contracts','fixedstr'
from dual where not exists (select 1 from ld_desk where labelbol ='LASTWEEKTHEAMOUNTOFNEWCONTRACTS' and languagetype='en' and Labeltype='fixedstr');
delimiter;
insert into ld_desk (languagetype,labelbol,fieldlabel,Labeltype)
select 'zh','LASTMONTHTHERECEIVEDAMOUNT','上月收款金额','fixedstr'
from dual where not exists (select 1 from ld_desk where labelbol ='LASTMONTHTHERECEIVEDAMOUNT' and languagetype='zh' and  Labeltype='fixedstr');
delimiter;
insert into ld_desk (languagetype,labelbol,fieldlabel,Labeltype)
select 'en','LASTMONTHTHERECEIVEDAMOUNT','Last month the received amount','fixedstr'
from dual where not exists (select 1 from ld_desk where labelbol ='LASTMONTHTHERECEIVEDAMOUNT' and languagetype='en' and Labeltype='fixedstr');
delimiter;
insert into ld_desk (languagetype,labelbol,fieldlabel,Labeltype)
select 'zh','LASTWEEKTHERECEIVEDAMOUNT','上周收款金额','fixedstr'
from dual where not exists (select 1 from ld_desk where labelbol ='LASTWEEKTHERECEIVEDAMOUNT' and languagetype='zh' and  Labeltype='fixedstr');
delimiter;
insert into ld_desk (languagetype,labelbol,fieldlabel,Labeltype)
select 'en','LASTWEEKTHERECEIVEDAMOUNT','Last week the received amount','fixedstr'
from dual where not exists (select 1 from ld_desk where labelbol ='LASTWEEKTHERECEIVEDAMOUNT' and languagetype='en' and Labeltype='fixedstr');
delimiter;
insert into ld_desk (languagetype,labelbol,fieldlabel,Labeltype)
select 'zh','beflastweek','上上周','fixedstr'
from dual where not exists (select 1 from ld_desk where labelbol ='beflastweek' and languagetype='zh' and  Labeltype='fixedstr');
delimiter;
insert into ld_desk (languagetype,labelbol,fieldlabel,Labeltype)
select 'en','beflastweek','the week before last','fixedstr'
from dual where not exists (select 1 from ld_desk where labelbol ='beflastweek' and languagetype='en' and Labeltype='fixedstr');
delimiter;
insert into ld_desk (languagetype,labelbol,fieldlabel,Labeltype)
select 'zh','beflastmonth','上上月','fixedstr'
from dual where not exists (select 1 from ld_desk where labelbol ='beflastmonth' and languagetype='zh' and  Labeltype='fixedstr');
delimiter;
insert into ld_desk (languagetype,labelbol,fieldlabel,Labeltype)
select 'en','beflastmonth','the month before last','fixedstr'
from dual where not exists (select 1 from ld_desk where labelbol ='beflastmonth' and languagetype='en' and Labeltype='fixedstr');
delimiter;

update ld_tranlabel set fieldlabel='角色权限' where tabid=29 and trantable='ld_field' and Relateid=481 and languagetype='zh';
update ld_desk set fieldlabel='角色权限' where labelbol='ROLES' and languagetype='zh';
update ld_desk set fieldlabel='Role' where labelbol='ROLES' and languagetype='en';
update ld_desk set fieldlabel='角色权限' where labelbol='PROFILES' and languagetype='zh';
update ld_desk set fieldlabel='Role' where labelbol='PROFILES' and languagetype='en';
update ld_desk set fieldlabel='修改角色权限为' where labelbol='SETTHEPERMISSIONSAS' and languagetype='zh' and Labeltype='jspop';
-- 2015-08-27

select tabid into @tabid from ld_tab where `name` = 'Stock';
update ld_field set presence = 0 where uitype = 201 and tabid = @tabid;
update ld_field set presence = 1 where columnname = 'purchaseorder_id' and uitype =  150 and tabid = @tabid;
delimiter;
select tabid into @tabid from ld_tab where `name` = 'PublicAnnouncement';
insert into ld_profileallpermission(tabid,operation)
select @tabid,14 from dual where not exists(select 1 from ld_profileallpermission where tabid = @tabid and operation = 14);
delimiter;

update ld_applabelset set display = 1 where htmlname = 'work' and
EXISTS (select 1 from ld_version where versiontype=2);
delimiter;

update ld_systems_deploy set deploy_value=0 where deploy_type=66 and not exists(select 1 from ld_crmentity where crmid>2);

select tabid into @tabid from ld_tab where `name` = 'SalesOrder';
update ld_quickactions set presence = 0 where tabid =@tabid and related_tabid = -9;
delimiter;
insert into ld_sendinformcontent(content,type,description)
select '尊敬的客户您好,您订购的产品已下单，总金额：[var.salesorder_hdnGrandTotal_SalesOrder]',7,'尊敬的客户您好,您订购的产品已下单'
from dual where not exists(select 1 from ld_sendinformcontent where type = 7);
delimiter;

select cvid into @cvid from ld_customview where viewname='mobileAccounts' and entitytype='mobileAccounts';
delete from ld_cvcolumnlist where cvid=@cvid;
insert into ld_cvcolumnlist (cvid,columnindex,columnname) values(@cvid,0,'ld_account:accountname:accountname:Accounts_客户名称:V' );
insert into ld_cvcolumnlist (cvid,columnindex,columnname) values(@cvid,1,'ld_account:rating:rating:Accounts_客户状态:V' );
insert into ld_cvcolumnlist (cvid,columnindex,columnname) values(@cvid,2,'ld_account:createdtime:createdtime:Accounts_创建时间:D' );
insert into ld_cvcolumnlist (cvid,columnindex,columnname) values(@cvid,3,'ld_account:bill_state:bill_state:Accounts_省份:V' );
insert into ld_cvcolumnlist (cvid,columnindex,columnname) values(@cvid,4,'ld_account:bill_city:bill_city:Accounts_城市:V' );
insert into ld_cvcolumnlist (cvid,columnindex,columnname) values(@cvid,5,'ld_account:bill_street:bill_street:Accounts_地址:V' );
delimiter;

select usereportid into @usereportid from ld_usereport where name = 'SumSequence';
select tabid into @tabid from ld_tab where `name` = 'CashBill';
select sequence into @sequence from ld_usereport where name = 'Contractamount';
update ld_usereport set sequence = sequence + 1 where Parent_id = @usereportid and sequence >@sequence;
insert into ld_usereport(name,reportlabel,tabids,basicfilter,advfilter,Setcolumns,Parent_id,sequence,reporttype,pagewidthpercent)
select 'The billboard of Receivables','回款金额龙虎榜',@tabid,1,0,0,@usereportid,@sequence+1,20,100 from dual where not exists(select 1 from ld_usereport where name = 'The billboard of Receivables');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','The billboard of Receivables','回款金额龙虎榜','fixedstr' from dual where not exists(select 1 from ld_desk where labelbol='The billboard of Receivables' and languagetype='zh' and labeltype='fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','The billboard of Receivables','The billboard of Receivables','fixedstr' from dual where not exists(select 1 from ld_desk where labelbol='The billboard of Receivables' and languagetype='en' and labeltype='fixedstr');
delimiter;

select usereportid into @usereportid from ld_usereport where name = 'The billboard of Receivables';
insert into ld_usereportcolumns(Usereportid,columns,Sequence,columnshow,realcolumns,realencolumns)
select @usereportid,'ld_cashbill:ordernum:ordernum:CashBill_ordernum:V',1,1,'ld_cashbill:ordernum:ordernum:CashBill_ordernum:V','ld_cashbill:ordernum:ordernum:CashBill_Rank:V'
from dual where not exists(select 1 from ld_usereportcolumns where Usereportid = @usereportid and columns = 'ld_cashbill:ordernum:ordernum:CashBill_ordernum:V');
delimiter;

insert into ld_usereportcolumns(Usereportid,columns,Sequence,columnshow,realcolumns,realencolumns)
select @usereportid,'ld_cashbill:smownerid:smownerid:CashBill_smownerid:V',2,1,'ld_cashbill:smownerid:smownerid:CashBill_smownerid:V','ld_cashbill:smownerid:smownerid:CashBill_Rank:V'
from dual where not exists(select 1 from ld_usereportcolumns where Usereportid = @usereportid and columns = 'ld_cashbill:smownerid:smownerid:CashBill_smownerid:V');
delimiter;

insert into ld_usereportcolumns(Usereportid,columns,Sequence,columnshow,realcolumns,realencolumns)
select @usereportid,'ld_cashbill:total:total:CashBill_total:N',3,1,'ld_cashbill:total:total:CashBill_total:N','ld_cashbill:total:total:CashBill_total:N'
from dual where not exists(select 1 from ld_usereportcolumns where Usereportid = @usereportid and columns = 'ld_cashbill:total:total:CashBill_total:N');
delimiter;

select usereportid into @usereportid from ld_usereport where name = 'The billboard of Receivables';
insert into ld_usereportbasic (Usereportid,columns,Defaultvalue,Sequence)
SELECT @usereportid,'ld_cashbill:cashbilldate:cashbilldate:SalesOrder_cashbilldate:D','thisstartmonth~thisendmonth',3
from dual where not exists(select 1 from ld_usereportbasic WHERE Usereportid = @usereportid and columns = 'ld_cashbill:cashbilldate:cashbilldate:SalesOrder_cashbilldate:D');
delimiter;

update ld_usereport set advfilter = 0 where name = 'The billboard of Receivables';
delimiter;

select max(sequence) into @sequence from ld_systems_deploy;
insert into ld_systems_deploy(deploy_value,deploy_type,description,setype,sequence)
select '1',79,'参数控制订单中产品单价是否需要根据客户购买记录带出 0:是，1:否','',@sequence+1 from dual
where not exists(select 1 from ld_systems_deploy where description= '参数控制订单中产品单价是否需要根据客户购买记录带出 0:是，1:否' and deploy_type=79 );
delimiter;
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','WHETHERPRODUCTSPRICEBROUGHTOUTACCORDINGTOCUSTOMERBUYHISTORY','订单中产品单价自动根据客户最近购买记录带出','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol = 'WHETHERPRODUCTSPRICEBROUGHTOUTACCORDINGTOCUSTOMERBUYHISTORY' and languagetype = 'zh' and labeltype = 'fixedstr');
delimiter;
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','WHETHERPRODUCTSPRICEBROUGHTOUTACCORDINGTOCUSTOMERBUYHISTORY','Whether the products unit price in the orders is automatically brought out according to the customers recent buy history','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol = 'WHETHERPRODUCTSPRICEBROUGHTOUTACCORDINGTOCUSTOMERBUYHISTORY' and languagetype = 'en' and labeltype = 'fixedstr');
delimiter;
-- 2015-9-01

select tabid into @tabid from ld_tab where name = 'Accounts';
SELECT sequence+1 INTO @sequence FROM ld_quickactions WHERE related_tabid=-1 AND tabid=@tabid;
insert into ld_quickactions(tabid,related_tabid,sequence,presence,label)
select @tabid,-10,@sequence,0,'负责人变更记录' from dual 
where not EXISTS(select 1 from ld_quickactions  where tabid=@tabid and label='负责人变更记录');
delimiter;

select tabid into @tabid from ld_tab where name = 'SalesOrder';
SELECT sequence+1 INTO @sequence FROM ld_quickactions WHERE related_tabid=-1 AND tabid=@tabid;
insert into ld_quickactions(tabid,related_tabid,sequence,presence,label)
select @tabid,-10,@sequence,0,'负责人变更记录' from dual 
where not EXISTS(select 1 from ld_quickactions  where tabid=@tabid and label='负责人变更记录');
delimiter;

select tabid into @tabid from ld_tab where name = 'Events';
SELECT sequence+1 INTO @sequence FROM ld_quickactions WHERE related_tabid=-1 AND tabid=@tabid;
insert into ld_quickactions(tabid,related_tabid,sequence,presence,label)
select @tabid,-10,@sequence,0,'负责人变更记录' from dual 
where not EXISTS(select 1 from ld_quickactions  where tabid=@tabid and label='负责人变更记录');
delimiter;

select tabid into @tabid from ld_tab where name = 'Documents';
SELECT sequence INTO @sequence FROM ld_quickactions WHERE related_tabid=-1 AND tabid=@tabid;
insert into ld_quickactions(tabid,related_tabid,sequence,presence,label)
select @tabid,-10,@sequence,0,'负责人变更记录' from dual 
where not EXISTS(select 1 from ld_quickactions  where tabid=@tabid and label='负责人变更记录');
delimiter;

select tabid into @tabid from ld_tab where name = 'Faq';
SELECT sequence+1 INTO @sequence FROM ld_quickactions WHERE related_tabid=-1 AND tabid=@tabid;
insert into ld_quickactions(tabid,related_tabid,sequence,presence,label)
select @tabid,-10,@sequence,0,'负责人变更记录' from dual 
where not EXISTS(select 1 from ld_quickactions  where tabid=@tabid and label='负责人变更记录');
delimiter;

select tabid into @tabid from ld_tab where name = 'Contacts';
SELECT sequence+1 INTO @sequence FROM ld_quickactions WHERE related_tabid=-1 AND tabid=@tabid;
insert into ld_quickactions(tabid,related_tabid,sequence,presence,label)
select @tabid,-10,@sequence,0,'负责人变更记录' from dual 
where not EXISTS(select 1 from ld_quickactions  where tabid=@tabid and label='负责人变更记录');
delimiter;

select tabid into @tabid from ld_tab where name = 'ContactRecords';
SELECT sequence+1 INTO @sequence FROM ld_quickactions WHERE related_tabid=-1 AND tabid=@tabid;
insert into ld_quickactions(tabid,related_tabid,sequence,presence,label)
select @tabid,-10,@sequence,0,'负责人变更记录' from dual 
where not EXISTS(select 1 from ld_quickactions  where tabid=@tabid and label='负责人变更记录');
delimiter;

select tabid into @tabid from ld_tab where name = 'Quotes';
SELECT sequence+1 INTO @sequence FROM ld_quickactions WHERE related_tabid=-1 AND tabid=@tabid;
insert into ld_quickactions(tabid,related_tabid,sequence,presence,label)
select @tabid,-10,@sequence,0,'负责人变更记录' from dual 
where not EXISTS(select 1 from ld_quickactions  where tabid=@tabid and label='负责人变更记录');
delimiter;

select tabid into @tabid from ld_tab where name = 'Potentials';
SELECT sequence+1 INTO @sequence FROM ld_quickactions WHERE related_tabid=-1 AND tabid=@tabid;
insert into ld_quickactions(tabid,related_tabid,sequence,presence,label)
select @tabid,-10,@sequence,0,'负责人变更记录' from dual 
where not EXISTS(select 1 from ld_quickactions  where tabid=@tabid and label='负责人变更记录');
delimiter;

select tabid into @tabid from ld_tab where name = 'SalesBack';
SELECT sequence+1 INTO @sequence FROM ld_quickactions WHERE related_tabid=-1 AND tabid=@tabid;
insert into ld_quickactions(tabid,related_tabid,sequence,presence,label)
select @tabid,-10,@sequence,0,'负责人变更记录' from dual 
where not EXISTS(select 1 from ld_quickactions  where tabid=@tabid and label='负责人变更记录');
delimiter;

select tabid into @tabid from ld_tab where name = 'ServiceContracts';
SELECT sequence+1 INTO @sequence FROM ld_quickactions WHERE related_tabid=-1 AND tabid=@tabid;
insert into ld_quickactions(tabid,related_tabid,sequence,presence,label)
select @tabid,-10,@sequence,0,'负责人变更记录' from dual 
where not EXISTS(select 1 from ld_quickactions  where tabid=@tabid and label='负责人变更记录');
delimiter;

select tabid into @tabid from ld_tab where name = 'ServiceCharge';
SELECT sequence INTO @sequence FROM ld_quickactions WHERE related_tabid=-1 AND tabid=@tabid;
insert into ld_quickactions(tabid,related_tabid,sequence,presence,label)
select @tabid,-10,@sequence,0,'负责人变更记录' from dual 
where not EXISTS(select 1 from ld_quickactions  where tabid=@tabid and label='负责人变更记录');
delimiter;

select tabid into @tabid from ld_tab where name = 'HelpDesk';
SELECT sequence+1 INTO @sequence FROM ld_quickactions WHERE related_tabid=-1 AND tabid=@tabid;
insert into ld_quickactions(tabid,related_tabid,sequence,presence,label)
select @tabid,-10,@sequence,0,'负责人变更记录' from dual 
where not EXISTS(select 1 from ld_quickactions  where tabid=@tabid and label='负责人变更记录');
delimiter;

select tabid into @tabid from ld_tab where name = 'Project';
SELECT sequence+1 INTO @sequence FROM ld_quickactions WHERE related_tabid=-1 AND tabid=@tabid;
insert into ld_quickactions(tabid,related_tabid,sequence,presence,label)
select @tabid,-10,@sequence,0,'负责人变更记录' from dual 
where not EXISTS(select 1 from ld_quickactions  where tabid=@tabid and label='负责人变更记录');
delimiter;

select tabid into @tabid from ld_tab where name = 'ProjectTask';
SELECT sequence+1 INTO @sequence FROM ld_quickactions WHERE related_tabid=-1 AND tabid=@tabid;
insert into ld_quickactions(tabid,related_tabid,sequence,presence,label)
select @tabid,-10,@sequence,0,'负责人变更记录' from dual 
where not EXISTS(select 1 from ld_quickactions  where tabid=@tabid and label='负责人变更记录');
delimiter;

select tabid into @tabid from ld_tab where name = 'ProjectMilestone';
SELECT sequence+1 INTO @sequence FROM ld_quickactions WHERE related_tabid=-1 AND tabid=@tabid;
insert into ld_quickactions(tabid,related_tabid,sequence,presence,label)
select @tabid,-10,@sequence,0,'负责人变更记录' from dual 
where not EXISTS(select 1 from ld_quickactions  where tabid=@tabid and label='负责人变更记录');
delimiter;

select tabid into @tabid from ld_tab where name = 'PurchaseInvoice';
SELECT sequence+1 INTO @sequence FROM ld_quickactions WHERE related_tabid=-1 AND tabid=@tabid;
insert into ld_quickactions(tabid,related_tabid,sequence,presence,label)
select @tabid,-10,@sequence,0,'负责人变更记录' from dual 
where not EXISTS(select 1 from ld_quickactions  where tabid=@tabid and label='负责人变更记录');
delimiter;

select tabid into @tabid from ld_tab where name = 'Invoice';
SELECT sequence+1 INTO @sequence FROM ld_quickactions WHERE related_tabid=-1 AND tabid=@tabid;
insert into ld_quickactions(tabid,related_tabid,sequence,presence,label)
select @tabid,-10,@sequence,0,'负责人变更记录' from dual 
where not EXISTS(select 1 from ld_quickactions  where tabid=@tabid and label='负责人变更记录');
delimiter;

select tabid into @tabid from ld_tab where name = 'CashBill';
SELECT sequence+1 INTO @sequence FROM ld_quickactions WHERE related_tabid=-1 AND tabid=@tabid;
insert into ld_quickactions(tabid,related_tabid,sequence,presence,label)
select @tabid,-10,@sequence,0,'负责人变更记录' from dual 
where not EXISTS(select 1 from ld_quickactions  where tabid=@tabid and label='负责人变更记录');
delimiter;

select tabid into @tabid from ld_tab where name = 'SendCashBill';
SELECT sequence+1 INTO @sequence FROM ld_quickactions WHERE related_tabid=-1 AND tabid=@tabid;
insert into ld_quickactions(tabid,related_tabid,sequence,presence,label)
select @tabid,-10,@sequence,0,'负责人变更记录' from dual 
where not EXISTS(select 1 from ld_quickactions  where tabid=@tabid and label='负责人变更记录');
delimiter;

select tabid into @tabid from ld_tab where name = 'CashBack';
SELECT sequence+1 INTO @sequence FROM ld_quickactions WHERE related_tabid=-1 AND tabid=@tabid;
insert into ld_quickactions(tabid,related_tabid,sequence,presence,label)
select @tabid,-10,@sequence,0,'负责人变更记录' from dual 
where not EXISTS(select 1 from ld_quickactions  where tabid=@tabid and label='负责人变更记录');
delimiter;

select tabid into @tabid from ld_tab where name = 'PurchaseCashBack';
SELECT sequence+1 INTO @sequence FROM ld_quickactions WHERE related_tabid=-1 AND tabid=@tabid;
insert into ld_quickactions(tabid,related_tabid,sequence,presence,label)
select @tabid,-10,@sequence,0,'负责人变更记录' from dual 
where not EXISTS(select 1 from ld_quickactions  where tabid=@tabid and label='负责人变更记录');
delimiter;

select tabid into @tabid from ld_tab where name = 'PaymentPlan';
SELECT sequence+1 INTO @sequence FROM ld_quickactions WHERE related_tabid=-1 AND tabid=@tabid;
insert into ld_quickactions(tabid,related_tabid,sequence,presence,label)
select @tabid,-10,@sequence,0,'负责人变更记录' from dual 
where not EXISTS(select 1 from ld_quickactions  where tabid=@tabid and label='负责人变更记录');
delimiter;

select tabid into @tabid from ld_tab where name = 'SendPayment';
SELECT sequence+1 INTO @sequence FROM ld_quickactions WHERE related_tabid=-1 AND tabid=@tabid;
insert into ld_quickactions(tabid,related_tabid,sequence,presence,label)
select @tabid,-10,@sequence,0,'负责人变更记录' from dual 
where not EXISTS(select 1 from ld_quickactions  where tabid=@tabid and label='负责人变更记录');
delimiter;

select tabid into @tabid from ld_tab where name = 'PutCash';
SELECT sequence+1 INTO @sequence FROM ld_quickactions WHERE related_tabid=-1 AND tabid=@tabid;
insert into ld_quickactions(tabid,related_tabid,sequence,presence,label)
select @tabid,-10,@sequence,0,'负责人变更记录' from dual 
where not EXISTS(select 1 from ld_quickactions  where tabid=@tabid and label='负责人变更记录');
delimiter;

select tabid into @tabid from ld_tab where name = 'CashDeposit';
SELECT sequence+1 INTO @sequence FROM ld_quickactions WHERE related_tabid=-1 AND tabid=@tabid;
insert into ld_quickactions(tabid,related_tabid,sequence,presence,label)
select @tabid,-10,@sequence,0,'负责人变更记录' from dual 
where not EXISTS(select 1 from ld_quickactions  where tabid=@tabid and label='负责人变更记录');
delimiter;

select tabid into @tabid from ld_tab where name = 'Expense';
SELECT sequence+1 INTO @sequence FROM ld_quickactions WHERE related_tabid=-1 AND tabid=@tabid;
insert into ld_quickactions(tabid,related_tabid,sequence,presence,label)
select @tabid,-10,@sequence,0,'负责人变更记录' from dual 
where not EXISTS(select 1 from ld_quickactions  where tabid=@tabid and label='负责人变更记录');
delimiter;

select tabid into @tabid from ld_tab where name = 'Commission';
SELECT sequence+1 INTO @sequence FROM ld_quickactions WHERE related_tabid=-1 AND tabid=@tabid;
insert into ld_quickactions(tabid,related_tabid,sequence,presence,label)
select @tabid,-10,@sequence,0,'负责人变更记录' from dual 
where not EXISTS(select 1 from ld_quickactions  where tabid=@tabid and label='负责人变更记录');
delimiter;

select tabid into @tabid from ld_tab where name = 'Stock';
SELECT sequence+1 INTO @sequence FROM ld_quickactions WHERE related_tabid=-1 AND tabid=@tabid;
insert into ld_quickactions(tabid,related_tabid,sequence,presence,label)
select @tabid,-10,@sequence,0,'负责人变更记录' from dual 
where not EXISTS(select 1 from ld_quickactions  where tabid=@tabid and label='负责人变更记录');
delimiter;

select tabid into @tabid from ld_tab where name = 'OutboundOrder';
SELECT sequence+1 INTO @sequence FROM ld_quickactions WHERE related_tabid=-1 AND tabid=@tabid;
insert into ld_quickactions(tabid,related_tabid,sequence,presence,label)
select @tabid,-10,@sequence,0,'负责人变更记录' from dual 
where not EXISTS(select 1 from ld_quickactions  where tabid=@tabid and label='负责人变更记录');
delimiter;

select tabid into @tabid from ld_tab where name = 'Checks';
SELECT sequence+1 INTO @sequence FROM ld_quickactions WHERE related_tabid=-1 AND tabid=@tabid;
insert into ld_quickactions(tabid,related_tabid,sequence,presence,label)
select @tabid,-10,@sequence,0,'负责人变更记录' from dual 
where not EXISTS(select 1 from ld_quickactions  where tabid=@tabid and label='负责人变更记录');
delimiter;

select tabid into @tabid from ld_tab where name = 'WareHouseTransfer';
SELECT sequence+1 INTO @sequence FROM ld_quickactions WHERE related_tabid=-1 AND tabid=@tabid;
insert into ld_quickactions(tabid,related_tabid,sequence,presence,label)
select @tabid,-10,@sequence,0,'负责人变更记录' from dual 
where not EXISTS(select 1 from ld_quickactions  where tabid=@tabid and label='负责人变更记录');
delimiter;

select tabid into @tabid from ld_tab where name = 'Vendors';
SELECT sequence+1 INTO @sequence FROM ld_quickactions WHERE related_tabid=-1 AND tabid=@tabid;
insert into ld_quickactions(tabid,related_tabid,sequence,presence,label)
select @tabid,-10,@sequence,0,'负责人变更记录' from dual 
where not EXISTS(select 1 from ld_quickactions  where tabid=@tabid and label='负责人变更记录');
delimiter;

select tabid into @tabid from ld_tab where name = 'PurchaseOrder';
SELECT sequence+1 INTO @sequence FROM ld_quickactions WHERE related_tabid=-1 AND tabid=@tabid;
insert into ld_quickactions(tabid,related_tabid,sequence,presence,label)
select @tabid,-10,@sequence,0,'负责人变更记录' from dual 
where not EXISTS(select 1 from ld_quickactions  where tabid=@tabid and label='负责人变更记录');
delimiter;

select tabid into @tabid from ld_tab where name = 'PurchaseBack';
SELECT sequence+1 INTO @sequence FROM ld_quickactions WHERE related_tabid=-1 AND tabid=@tabid;
insert into ld_quickactions(tabid,related_tabid,sequence,presence,label)
select @tabid,-10,@sequence,0,'负责人变更记录' from dual 
where not EXISTS(select 1 from ld_quickactions  where tabid=@tabid and label='负责人变更记录');
delimiter;

select tabid into @tabid from ld_tab where name = 'VendorContact';
SELECT sequence+1 INTO @sequence FROM ld_quickactions WHERE related_tabid=-1 AND tabid=@tabid;
insert into ld_quickactions(tabid,related_tabid,sequence,presence,label)
select @tabid,-10,@sequence,0,'负责人变更记录' from dual 
where not EXISTS(select 1 from ld_quickactions  where tabid=@tabid and label='负责人变更记录');
delimiter;

select tabid into @tabid from ld_tab where name = 'VendorContactRecords';
SELECT sequence+1 INTO @sequence FROM ld_quickactions WHERE related_tabid=-1 AND tabid=@tabid;
insert into ld_quickactions(tabid,related_tabid,sequence,presence,label)
select @tabid,-10,@sequence,0,'负责人变更记录' from dual 
where not EXISTS(select 1 from ld_quickactions  where tabid=@tabid and label='负责人变更记录');
delimiter;

select tabid into @tabid from ld_tab where name = 'Campaigns';
SELECT sequence+1 INTO @sequence FROM ld_quickactions WHERE related_tabid=-1 AND tabid=@tabid;
insert into ld_quickactions(tabid,related_tabid,sequence,presence,label)
select @tabid,-10,@sequence,0,'负责人变更记录' from dual 
where not EXISTS(select 1 from ld_quickactions  where tabid=@tabid and label='负责人变更记录');
delimiter;

select tabid into @tabid from ld_tab where name = 'ModComments';
SELECT sequence+1 INTO @sequence FROM ld_quickactions WHERE related_tabid=-1 AND tabid=@tabid;
insert into ld_quickactions(tabid,related_tabid,sequence,presence,label)
select @tabid,-10,@sequence,0,'负责人变更记录' from dual 
where not EXISTS(select 1 from ld_quickactions  where tabid=@tabid and label='负责人变更记录');
delimiter;

select tabid into @tabid from ld_tab where name = 'Products';
SELECT sequence+1 INTO @sequence FROM ld_quickactions WHERE related_tabid=-1 AND tabid=@tabid;
insert into ld_quickactions(tabid,related_tabid,sequence,presence,label)
select @tabid,-10,@sequence,0,'负责人变更记录' from dual 
where not EXISTS(select 1 from ld_quickactions  where tabid=@tabid and label='负责人变更记录');
delimiter;

select tabid into @tabid from ld_tab where name = 'Productbom';
SELECT sequence+1 INTO @sequence FROM ld_quickactions WHERE related_tabid=-1 AND tabid=@tabid;
insert into ld_quickactions(tabid,related_tabid,sequence,presence,label)
select @tabid,-10,@sequence,0,'负责人变更记录' from dual 
where not EXISTS(select 1 from ld_quickactions  where tabid=@tabid and label='负责人变更记录');
delimiter;

select tabid into @tabid from ld_tab where name = 'PriceBooks';
SELECT sequence+1 INTO @sequence FROM ld_quickactions WHERE related_tabid=-1 AND tabid=@tabid;
insert into ld_quickactions(tabid,related_tabid,sequence,presence,label)
select @tabid,-10,@sequence,0,'负责人变更记录' from dual 
where not EXISTS(select 1 from ld_quickactions  where tabid=@tabid and label='负责人变更记录');
delimiter;

select tabid into @tabid from ld_tab where name = 'PublicAnnouncement';
SELECT sequence+1 INTO @sequence FROM ld_quickactions WHERE related_tabid=-1 AND tabid=@tabid;
insert into ld_quickactions(tabid,related_tabid,sequence,presence,label)
select @tabid,-10,@sequence,0,'负责人变更记录' from dual 
where not EXISTS(select 1 from ld_quickactions  where tabid=@tabid and label='负责人变更记录');
delimiter;

select tabid INTO @tabid from ld_tab where `name` = 'PaymentPlan';
select actionid INTO @actionid from ld_actionmapping WHERE actionname='Import';
insert into ld_profileallpermission(tabid,operation)
select @tabid,@actionid from dual 
where not EXISTS(select 1 from ld_profileallpermission  where tabid=@tabid and operation=@actionid);
delimiter;
select tabid INTO @tabid from ld_tab where `name` = 'SendPayment';
select actionid INTO @actionid from ld_actionmapping WHERE actionname='Import';
insert into ld_profileallpermission(tabid,operation)
select @tabid,@actionid from dual 
where not EXISTS(select 1 from ld_profileallpermission  where tabid=@tabid and operation=@actionid);
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) 
select 'zh','ChangeView','变更历史','fixedstr' 
from dual where not EXISTS(select 1 from ld_desk where languagetype='zh' 
and labelbol='ChangeView' and Labeltype='fixedstr');

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) 
select 'en','ChangeView',' Change Log','fixedstr' 
from dual where not EXISTS(select 1 from ld_desk  where languagetype='en' 
and labelbol='ChangeView' and Labeltype='fixedstr');
delimiter;

UPDATE ld_modtracker_detail SET fieldname = 'ServiceContractsassigned_user_id' WHERE id IN ( SELECT id FROM ld_modtracker_basic WHERE module = 'ServiceContracts' ) AND fieldname = 'assigned_user_id';
delimiter;
UPDATE ld_modtracker_detail SET fieldname = 'prosmownerid' WHERE id IN ( SELECT id FROM ld_modtracker_basic WHERE module = 'Products' ) AND fieldname = 'assigned_user_id';
delimiter;
-- 2015-09-06

update ld_desk set fieldlabel = '进行修改后，点击保存按钮，共享规则生效' where labelbol = 'AFTERMAKINGMODIFIPRESS' and languagetype = 'zh' and Labeltype = 'fixedstr';
delimiter;
update ld_desk set fieldlabel = 'Make changes, click the Save button, sharing rules take effect' where labelbol = 'AFTERMAKINGMODIFIPRESS' and languagetype = 'en' and Labeltype = 'fixedstr';
delimiter;
update ld_cvstdfilter set columnname = 'ld_inventoryproductrel:servicecontracts_end_date:servicecontracts_end_date:Products_fieldlabel:D' where cvid in (
select cvid from ld_customview where entitytype = 'ServiceCharge' and viewname in ('已过期','过期未超60天','过期未超30天','即将到期60天','即将到期30天'));
delimiter;


select tabid into @tabid from ld_tab where `name`='Accounts';
select block into @blockid from ld_field where tabid=@tabid and columnname='smownerid';
set @tablename='ld_account';
set @columnname='lastservicedate';
set @fieldname='lastservicedate';
set @zh='最晚服务到期日';
set @en='Last Service Date';
set @uitype=5;
set @readonly=1;
set @presence=2;
set @defaultvalue=NULL;
set @displaytype=1;
set @typeofdata='D~O';
set @quickcreate=1;
set @quickcreatesequence=NULL;
set @info_type='BAS';
set @masseditable=1;
  
select max(sequence) into @seq from ld_field where tabid=@tabid and block=@blockid;

select max(fieldid) into @fieldid from ld_field;
insert into ld_field(tabid,fieldid,columnname,tablename,generatedtype,uitype,fieldname,fieldlabel,readonly,presence,defaultvalue,maximumlength,sequence,block,displaytype,typeofdata,quickcreate,quickcreatesequence,info_type,masseditable,helpinfo,fieldonly)
select @tabid,@fieldid+1,@columnname,@tablename,1,@uitype,@fieldname,@zh,@readonly,@presence,@defaultvalue,100,@seq+1,@blockid,@displaytype,@typeofdata,@quickcreate,@quickcreatesequence,@info_type,@masseditable,NULL,0 from dual 
where not exists (select 1 from ld_field where tabid=@tabid and tablename=@tablename and columnname=@columnname);

select fieldid into @fieldid from ld_field where tabid=@tabid and columnname=@columnname;
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'zh','ld_field',@tabid,@fieldid,@zh from dual 
where not exists (select 1 from ld_tranlabel  where languagetype = 'zh' and trantable ='ld_field' and tabid = @tabid and relateid=@fieldid);

insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'en','ld_field',@tabid,@fieldid,@en from dual 
where not exists (select 1 from ld_tranlabel  where languagetype = 'en' and trantable ='ld_field' and tabid = @tabid and relateid=@fieldid);
delimiter;

select tabid into @tabid from ld_tab where `name`='ServiceCharge';
select block into @blockid from ld_field where tabid=@tabid and columnname='smownerid';
set @tablename='ld_account';
set @columnname='lastservicedate';
set @fieldname='lastservicedate';
set @zh='最晚服务到期日';
set @en='Last Service Date';
set @uitype=5;
set @readonly=1;
set @presence=2;
set @defaultvalue=NULL;
set @displaytype=1;
set @typeofdata='D~O';
set @quickcreate=1;
set @quickcreatesequence=NULL;
set @info_type='BAS';
set @masseditable=1;
  
select max(sequence) into @seq from ld_field where tabid=@tabid and block=@blockid;

select max(fieldid) into @fieldid from ld_field;
insert into ld_field(tabid,fieldid,columnname,tablename,generatedtype,uitype,fieldname,fieldlabel,readonly,presence,defaultvalue,maximumlength,sequence,block,displaytype,typeofdata,quickcreate,quickcreatesequence,info_type,masseditable,helpinfo,fieldonly)
select @tabid,@fieldid+1,@columnname,@tablename,1,@uitype,@fieldname,@zh,@readonly,@presence,@defaultvalue,100,@seq+1,@blockid,@displaytype,@typeofdata,@quickcreate,@quickcreatesequence,@info_type,@masseditable,NULL,0 from dual 
where not exists (select 1 from ld_field where tabid=@tabid and tablename=@tablename and columnname=@columnname);

select fieldid into @fieldid from ld_field where tabid=@tabid and columnname=@columnname;
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'zh','ld_field',@tabid,@fieldid,@zh from dual 
where not exists (select 1 from ld_tranlabel  where languagetype = 'zh' and trantable ='ld_field' and tabid = @tabid and relateid=@fieldid);

insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'en','ld_field',@tabid,@fieldid,@en from dual 
where not exists (select 1 from ld_tranlabel  where languagetype = 'en' and trantable ='ld_field' and tabid = @tabid and relateid=@fieldid);

call AddColumn(@tablename,@columnname,'date','1','0');
delimiter;

alter table ld_account modify column lastservicedate date;
delimiter;

call getallprofile('Accounts');
delimiter;
call fieldprofile('Accounts');
delimiter;

call getallprofile('ServiceCharge');
delimiter;
call fieldprofile('ServiceCharge');
delimiter;

UPDATE (
	SELECT
		a.accountid,
		max(
			b.servicecontracts_end_date
		) AS servicecontracts_end_date
	FROM
		ld_servicecontracts a
	LEFT JOIN ld_inventoryproductrel b ON a.servicecontractsid = b.id
	WHERE
		a.deleted = 0
	AND a.accountid > 0
	AND a.contract_status <> '已作废'
	GROUP BY
		a.accountid
) AS t
LEFT JOIN ld_account ON t.accountid = ld_account.accountid
SET ld_account.lastservicedate = t.servicecontracts_end_date;

drop trigger if exists update_account_lastservicedate; 
delimiter || 
CREATE TRIGGER update_account_lastservicedate AFTER UPDATE ON ld_servicecontracts 
FOR EACH ROW 
BEGIN 

update ld_account set lastservicedate=(select
		max(
			b.servicecontracts_end_date
		) AS servicecontracts_end_date
	FROM
		ld_servicecontracts a
	LEFT JOIN ld_inventoryproductrel b ON a.servicecontractsid = b.id
	WHERE
		a.deleted = 0
	AND a.accountid =NEW.accountid
	AND a.contract_status <> '已作废'
	GROUP BY
		a.accountid) where ld_account.accountid =NEW.accountid;

update ld_account set lastservicedate=(select
		max(
			b.servicecontracts_end_date
		) AS servicecontracts_end_date
	FROM
		ld_servicecontracts a
	LEFT JOIN ld_inventoryproductrel b ON a.servicecontractsid = b.id
	WHERE
		a.deleted = 0
	AND a.accountid =OLD.accountid
	AND a.contract_status <> '已作废'
	GROUP BY
		a.accountid) where ld_account.accountid =OLD.accountid;

END || 
delimiter; 

DROP PROCEDURE IF EXISTS `update_ServiceCharge_cvcolumnlist`;
delimiter ||
CREATE  PROCEDURE `update_ServiceCharge_cvcolumnlist`(
)
BEGIN 

		DECLARE done int DEFAULT 0; 
		DECLARE tmp_cvid int(11); 

		DECLARE mycursor CURSOR FOR select cvid from ld_customview where entitytype='ServiceCharge';
		DECLARE CONTINUE HANDLER FOR SQLSTATE '02000' set tmp_cvid = NULL;

		select tabid into @tabid from ld_tab where `name`='ServiceCharge';

		OPEN mycursor; 
		fetch mycursor into tmp_cvid; 
		while(tmp_cvid is not null) DO	

				select sequence into @seq from ld_tabwithproductview where tabid=@tabid and cvid=tmp_cvid and `columns` like 'ld_account:accountname:accountname:%' limit 1;
				update ld_tabwithproductview set sequence=sequence+10 where tabid=@tabid and cvid=tmp_cvid and sequence>@seq;
				
				insert into ld_tabwithproductview(tabid,`columns`,sequence,cvid)
				select @tabid,'ld_account:lastservicedate:lastservicedate:Accounts_fieldlabel:D',@seq+1,tmp_cvid from dual 
				where not exists (select 1 from ld_tabwithproductview where tabid=@tabid and cvid=tmp_cvid and `columns` like 'ld_account:lastservicedate:lastservicedate%');
				
				set @i=0;
				update ld_tabwithproductview set sequence=(@i:=@i+1) where tabid=@tabid and cvid=tmp_cvid order by sequence; 
				fetch mycursor into tmp_cvid;
		end while;
		close mycursor;
end ||
delimiter;

call update_ServiceCharge_cvcolumnlist();
delimiter;
-- 2015-09-07

update ld_field set uitype=5,typeofdata='D~O' where tabid=6 and columnname='lastservicedate';
update ld_field set uitype=5,typeofdata='D~O' where tabid=(select tabid from ld_tab where `name`='ServiceCharge' ) and columnname='lastservicedate';

call AddColumn('ld_potential','lastsales_stage','varchar','255',NULL);
delimiter;
select tabid into @tabid from ld_tab where `name` = 'Potentials';
select blockid into @blockid from ld_blocks where tabid = @tabid and blocklabel = 'LBL_OPPORTUNITY_INFORMATION';
select sequence into @sequence from ld_field where columnname = 'sales_stage';
update ld_field set sequence = sequence + 1 where tabid =@tabid and sequence >@sequence;
update ld_field_seq set id = (select max(fieldid) from ld_field);
SELECT id into @id FROM ld_field_seq;
insert into ld_field(tabid,fieldid,columnname,tablename,generatedtype,uitype,fieldname,fieldlabel,readonly,presence,defaultvalue,maximumlength,sequence,block,displaytype,typeofdata,quickcreate,quickcreatesequence,info_type,masseditable,helpinfo,fieldonly,issmownerid,searchfieldtype,associatedfields,associatedsequence,callchecked)
select  @tabid,@id+1,'lastsales_stage','ld_potential',1,1,'lastsales_stage','lastsales_stage',0,2,'无',100,@sequence+1,@blockid,2,'V~M',1,5,'BAS',0,'',0,0,1,1,0,0
from dual where not exists(select 1 from ld_field where columnname='lastsales_stage' and tablename='ld_potential' and tabid = @tabid);
delimiter;
select tabid into @tabid from ld_tab where `name` = 'Potentials';
SELECT fieldid into @fieldid from ld_field where columnname ='lastsales_stage' and tablename='ld_potential';
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select  'zh','ld_field',@tabid,@fieldid,'上一销售阶段' from dual where not exists(select 1 from ld_tranlabel where fieldlabel='上一销售阶段' and languagetype='zh');
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select  'en','ld_field',@tabid,@fieldid,'lastsales_stage' from dual where not exists(select 1 from ld_tranlabel where fieldlabel='lastsales_stage' and languagetype='en');
update ld_field_seq set id = (select max(fieldid) from ld_field);
delimiter;
update ld_potential LEFT JOIN (
	select potentialid,stage from ld_potstagehistory GROUP BY potentialid  ORDER BY potentialid desc
) as history on history.potentialid = ld_potential.potentialid set lastsales_stage = history.stage where lastsales_stage is null or lastsales_stage = '';
delimiter;
select usereportid into @usereportid from ld_usereport where `name` = 'Salesforecastandanalysistable';
select Sequence into @Sequence from ld_usereportcolumns where Usereportid=@usereportid and realcolumns='ld_potential:sales_stage:sales_stage:Potentials_销售阶段:V';
update ld_usereportcolumns set sequence = sequence + 1 where Usereportid =@usereportid and sequence >@sequence;
insert into ld_usereportcolumns(Usereportid,columns,Sequence,columnshow,realcolumns,realencolumns)
select  @usereportid,'ld_potential:lastsales_stage:lastsales_stage:potentials_lastsales_stage:V',@Sequence+1,1,'ld_potential:lastsales_stage:lastsales_stage:Potentials_上一销售阶段:V','ld_potential:lastsales_stage:lastsales_stage:Potentials_lastsales_stage:V' from dual where not exists(select 1 from ld_usereportcolumns where realcolumns='ld_potential:lastsales_stage:lastsales_stage:Potentials_上一销售阶段:V' and Usereportid=@usereportid);
delimiter;

select cvid into @cvid from ld_customview where viewname='mobileAccounts' and entitytype='mobileAccounts';
delete from ld_cvcolumnlist where cvid=@cvid;
insert into ld_cvcolumnlist (cvid,columnindex,columnname) values(@cvid,0,'ld_account:accountname:accountname:Accounts_客户名称:V' );
insert into ld_cvcolumnlist (cvid,columnindex,columnname) values(@cvid,1,'ld_account:smownerid:assigned_user_id:Accounts_销售负责人:V' );
insert into ld_cvcolumnlist (cvid,columnindex,columnname) values(@cvid,2,'ld_account:rating:rating:Accounts_客户状态:V' );
insert into ld_cvcolumnlist (cvid,columnindex,columnname) values(@cvid,3,'ld_account:createdtime:createdtime:Accounts_创建时间:D' );
insert into ld_cvcolumnlist (cvid,columnindex,columnname) values(@cvid,4,'ld_account:bill_state:bill_state:Accounts_省份:V' );
insert into ld_cvcolumnlist (cvid,columnindex,columnname) values(@cvid,5,'ld_account:bill_city:bill_city:Accounts_城市:V' );
insert into ld_cvcolumnlist (cvid,columnindex,columnname) values(@cvid,6,'ld_account:bill_street:bill_street:Accounts_地址:V' );
delimiter;

select cvid into @cvid from ld_customview where viewname='mobileContactRecords' and entitytype='mobileContactRecords';
delete from ld_cvcolumnlist where cvid=@cvid;
insert into ld_cvcolumnlist (cvid,columnindex,columnname) values(@cvid,0,'ld_contactrecords:subject:subject:ContactRecords_subject:V' );
insert into ld_cvcolumnlist (cvid,columnindex,columnname) values(@cvid,1,'ld_contactrecords:smownerid:assigned_user_id:ContactRecords_assigned_Name:V' );
insert into ld_cvcolumnlist (cvid,columnindex,columnname) values(@cvid,2,'ld_contactrecords:accountid:account_id:ContactRecords_Account_Name:V' );
insert into ld_cvcolumnlist (cvid,columnindex,columnname) values(@cvid,3,'ld_contactrecords:contactdate:contactdate:ContactRecords_contactdate:D' );
insert into ld_cvcolumnlist (cvid,columnindex,columnname) values(@cvid,4,'ld_contactrecords:contactid:contact_id:ContactRecords_Contact_Name:V' );
delimiter;

select cvid into @cvid from ld_customview where viewname='mobileSalesOrder' and entitytype='mobileSalesOrder';
delete from ld_cvcolumnlist where cvid=@cvid;
insert into ld_cvcolumnlist (cvid,columnindex,columnname) values(@cvid,0,'ld_salesorder:salesorder_no:salesorder_no:SalesOrder_编号:V' );
insert into ld_cvcolumnlist (cvid,columnindex,columnname) values(@cvid,1,'ld_salesorder:subject:subject:Quotes_主题:V' );
insert into ld_cvcolumnlist (cvid,columnindex,columnname) values(@cvid,2,'ld_salesorder:accountid:account_id:SalesOrder_客户:I' );
insert into ld_cvcolumnlist (cvid,columnindex,columnname) values(@cvid,3,'ld_salesorder:total:hdnGrandTotal:SalesOrder_合计:N' );
insert into ld_cvcolumnlist (cvid,columnindex,columnname) values(@cvid,4,'ld_salesorder:smownerid:assigned_user_id:SalesOrder_销售负责人:V' );
insert into ld_cvcolumnlist (cvid,columnindex,columnname) values(@cvid,5,'ld_salesorder:signed_data:signed_data:SalesOrder_签约日期:D' );
delimiter;

select cvid into @cvid from ld_customview where viewname='mobileQuotes' and entitytype='mobileQuotes';
delete from ld_cvcolumnlist where cvid=@cvid;
insert into ld_cvcolumnlist (cvid,columnindex,columnname) values(@cvid,0,'ld_quotes:quote_no:quote_no:Quotes_编号:V' );
insert into ld_cvcolumnlist (cvid,columnindex,columnname) values(@cvid,1,'ld_quotes:subject:subject:Quotes_主题:V' );
insert into ld_cvcolumnlist (cvid,columnindex,columnname) values(@cvid,2,'ld_quotes:accountid:account_id:Quotes_客户:I' );
insert into ld_cvcolumnlist (cvid,columnindex,columnname) values(@cvid,3,'ld_quotes:subtotal:hdnSubTotal:Quotes_合计:N' );
insert into ld_cvcolumnlist (cvid,columnindex,columnname) values(@cvid,4,'ld_quotes:smownerid:assigned_user_id:Quotes_销售负责人:V' );
insert into ld_cvcolumnlist (cvid,columnindex,columnname) values(@cvid,5,'ld_quotes:createdtime:createdtime:Quotes_创建日期:D' );
delimiter;

select cvid into @cvid from ld_customview where viewname='mobileServiceContracts' and entitytype='mobileServiceContracts';
delete from ld_cvcolumnlist where cvid=@cvid;
insert into ld_cvcolumnlist (cvid,columnindex,columnname) values(@cvid,0,'ld_servicecontracts:contract_no:contract_no:ServiceContracts_编号:V' );
insert into ld_cvcolumnlist (cvid,columnindex,columnname) values(@cvid,1,'ld_servicecontracts:subject:subject:ServiceContracts_主题:V' );
insert into ld_cvcolumnlist (cvid,columnindex,columnname) values(@cvid,2,'ld_servicecontracts:accountid:account_id:ServiceContracts_客户:I' );
insert into ld_cvcolumnlist (cvid,columnindex,columnname) values(@cvid,3,'ld_servicecontracts:total:hdnGrandTotal:ServiceContracts_合计:N' );
insert into ld_cvcolumnlist (cvid,columnindex,columnname) values(@cvid,4,'ld_servicecontracts:smownerid:ServiceContractsassigned_user_id:ServiceContracts_销售负责人:V' );
insert into ld_cvcolumnlist (cvid,columnindex,columnname) values(@cvid,5,'ld_servicecontracts:due_date:due_date:ServiceContracts_签约日期:D' );
delimiter;

select cvid into @cvid from ld_customview where viewname='mobileCampaigns' and entitytype='mobileCampaigns';
delete from ld_cvcolumnlist where cvid=@cvid;
insert into ld_cvcolumnlist (cvid,columnindex,columnname) values(@cvid,0,'ld_campaign:campaignname:campaignname:Campaigns_市场活动:V' );
insert into ld_cvcolumnlist (cvid,columnindex,columnname) values(@cvid,1,'ld_campaign:smownerid:assigned_user_id:Campaigns_负责人:V' );
insert into ld_cvcolumnlist (cvid,columnindex,columnname) values(@cvid,2,'ld_campaign:createdtime:createdtime:Campaigns_创建时间:I' );
delimiter;

select cvid into @cvid from ld_customview where viewname='mobilePotentials' and entitytype='mobilePotentials';
delete from ld_cvcolumnlist where cvid=@cvid;
insert into ld_cvcolumnlist (cvid,columnindex,columnname) values(@cvid,0,'ld_potential:potentialname:potentialname:Potentials_机会名称:V' );
insert into ld_cvcolumnlist (cvid,columnindex,columnname) values(@cvid,1,'ld_potential:smownerid:assigned_user_id:Potentials_负责人:V' );
insert into ld_cvcolumnlist (cvid,columnindex,columnname) values(@cvid,2,'ld_potential:createdtime:createdtime:Potentials_创建时间:I' );
delimiter;
-- 2015-09-08

select cvid into @cvid from ld_customview where viewname='mobileContacts' and entitytype='mobileContacts';
delete from ld_cvcolumnlist where cvid=@cvid;
insert into ld_cvcolumnlist (cvid,columnindex,columnname) values(@cvid,0,'ld_contactdetails:lastname:lastname:Contacts_姓名:V' );
insert into ld_cvcolumnlist (cvid,columnindex,columnname) values(@cvid,1,'ld_contactdetails:smownerid:assigned_user_id:Contacts_负责人:V' );
insert into ld_cvcolumnlist (cvid,columnindex,columnname) values(@cvid,2,'ld_contactdetails:accountid:account_id:Contacts_Account_Name:V' );
insert into ld_cvcolumnlist (cvid,columnindex,columnname) values(@cvid,3,'ld_contactdetails:mobile:mobile:Contacts_Mobile:V' );
delimiter;

select tabid into @tabid from ld_tab where name = 'Attachment';
insert into ld_quickactions(tabid,related_tabid,sequence,presence,label)
select @tabid,-10,2,0,'负责人变更记录' from dual 
where not EXISTS(select 1 from ld_quickactions  where tabid=@tabid and label='负责人变更记录');
delimiter;
-- 2015-09-09

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','PERCENTAGEPRICE','百分比降价','fixedstr' from dual   
where not exists(select 1 from ld_desk where labelbol = 'PERCENTAGEPRICE' and languagetype = 'zh' and labeltype = 'fixedstr');
delimiter;
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','PERCENTAGEPRICE','Percentage price','fixedstr' from dual 
where not exists(select 1 from ld_desk where labelbol = 'PERCENTAGEPRICE' and languagetype = 'en' and labeltype = 'fixedstr');
delimiter;
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','PLEASEENTERNUMBERBETWEEN0AND100','请输入0~100之间数字','jspop' from dual   
where not exists(select 1 from ld_desk where labelbol = 'PLEASEENTERNUMBERBETWEEN0AND100' and languagetype = 'zh' and labeltype = 'jspop');
delimiter;
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','PLEASEENTERNUMBERBETWEEN0AND100','Please enter a number between 0 and 100','jspop' from dual 
where not exists(select 1 from ld_desk where labelbol = 'PLEASEENTERNUMBERBETWEEN0AND100' and languagetype = 'en' and labeltype = 'jspop');
delimiter;

call AddColumn('ld_salesorder','discount_type','int','1', 0);
call AddColumn('ld_servicecontracts','discount_type','int','1', 0);
call AddColumn('ld_quotes','discount_type','int','1', 0);
call AddColumn('ld_salesback','discount_type','int','1',0);
call AddColumn('ld_purchaseorder','discount_type','int','1', 0);
call AddColumn('ld_purchaseback','discount_type','int','1', 0);
call AddColumn('ld_outboundorder','discount_type','int','1', 0);
call AddColumn('ld_stock','discount_type','int','1', 0);
call AddColumn('ld_warehousetransfer','discount_type','int','1', 0);
call AddColumn('ld_checks','discount_type','int','1', 0);
call AddColumn('ld_invoice','discount_type','int','1', 0);
call AddColumn('ld_purchaseinvoice','discount_type','int','1', 0);
call AddColumn('ld_cashback','discount_type','int','1', 0);
call AddColumn('ld_purchasecashback','discount_type','int','1', 0);
delimiter;
-- 2015-09-11

alter table ld_singin change distince  distince varchar(50);
alter table ld_activity alter column visibility set default '公共';
UPDATE ld_activity SET visibility='公共' WHERE visibility='all';
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','HAVEALLGENERATEDASINGLE','已全部生成出库单，是否继续？','jspop' from dual   
where not exists(select 1 from ld_desk where labelbol = 'HAVEALLGENERATEDASINGLE' and languagetype = 'zh' and labeltype = 'jspop');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','HAVEALLGENERATEDASINGLE','Have all generated a single, whether to continue?','jspop' from dual 
where not exists(select 1 from ld_desk where labelbol = 'HAVEALLGENERATEDASINGLE' and languagetype = 'en' and labeltype = 'jspop');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','HAVEALLGENERATEDASINGLES','已全部生成入库单，是否继续？','jspop' from dual   
where not exists(select 1 from ld_desk where labelbol = 'HAVEALLGENERATEDASINGLES' and languagetype = 'zh' and labeltype = 'jspop');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','HAVEALLGENERATEDASINGLES','Have all generated a single, whether to continue?','jspop' from dual 
where not exists(select 1 from ld_desk where labelbol = 'HAVEALLGENERATEDASINGLES' and languagetype = 'en' and labeltype = 'jspop');
delimiter;

select tabid into @tabid from ld_tab where name = 'PurchaseInvoice';
update ld_producttoolfield set tablename = 'ld_inventoryproductrel' where columnname = 'listprice' and uitype = 26 and tablename = 'ld_products' and tabid = @tabid;
update ld_producttoolfield set tablename = 'ld_inventoryproductrel' where columnname = 'taxprice' and uitype = 26 and tablename = 'ld_products' and tabid = @tabid;
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','SOQD5D','仅显示符合条件的前5条数据。','fixedstr' from dual   
where not exists(select 1 from ld_desk where labelbol = 'SOQD5D' and languagetype = 'zh' and labeltype = 'fixedstr');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','SOQD5D','Show only qualified before 5 data.','fixedstr' from dual 
where not exists(select 1 from ld_desk where labelbol = 'SOQD5D' and languagetype = 'en' and labeltype = 'fixedstr');
delimiter;
-- 2015-09-14

insert into ld_desk(languagetype,labelbol,fieldlabel,Labeltype)
select  'en','Applicable personnel','Applicable personnel','fixedstr'
from dual where not exists(select 1 from ld_desk where labelbol='Applicable personnel' and languagetype='en');
delimiter;
insert into ld_desk(languagetype,labelbol,fieldlabel,Labeltype)
select  'zh','Applicable personnel','适用人员','fixedstr'
from dual where not exists(select 1 from ld_desk where labelbol='Applicable personnel' and languagetype='zh');
delimiter

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) 
select 'zh','TORELEASETHECUSTOMERTOTHEHIGNSEAS','将客户释放到公海未分配','fixedstr' 
from dual where not exists(select 1 from ld_desk where languagetype='zh' and labelbol = 'TORELEASETHECUSTOMERTOTHEHIGNSEAS' and labeltype = 'fixedstr'); 
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) 
select 'en','TORELEASETHECUSTOMERTOTHEHIGNSEAS','To release the customer to the high seas not allocated','fixedstr' 
from dual where not exists(select 1 from ld_desk where languagetype='en' and labelbol = 'TORELEASETHECUSTOMERTOTHEHIGNSEAS' and labeltype = 'fixedstr'); 
delimiter;
update ld_logpublicaccount set operation = 'TORELEASETHECUSTOMERTOTHEHIGNSEAS' where operation = '将客户释放到公海未分配';
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) 
select 'zh','YOUDONOTHAVETHECONTRACTPORDER','您没有编辑权限','jspop' 
from dual where not exists(select 1 from ld_desk where languagetype='zh' and labelbol = 'YOUDONOTHAVETHECONTRACTPORDER' and labeltype = 'jspop'); 
delimiter;
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) 
select 'en','YOUDONOTHAVETHECONTRACTPORDER','You do not have the permissions to edit the current payment plan','jspop' 
from dual where not exists(select 1 from ld_desk where languagetype='en' and labelbol = 'YOUDONOTHAVETHECONTRACTPORDER' and labeltype = 'jspop'); 
delimiter;

select cvid into @cvid from ld_customview where viewname='mobileProducts' and entitytype='mobileProducts';
delete from ld_cvcolumnlist where cvid=@cvid;
insert into ld_cvcolumnlist (cvid,columnindex,columnname) values(@cvid,0,'ld_products:productname:productname:InventoryQuery_fieldlabel:V' );
insert into ld_cvcolumnlist (cvid,columnindex,columnname) values(@cvid,1,'ld_products:productsheet:productsheet:Products_fieldlabel:V' );
insert into ld_cvcolumnlist (cvid,columnindex,columnname) values(@cvid,2,'ld_products:usageunit:usageunit:Products_计量单位:V' );
delimiter;
-- 2015-09-15

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) 
select 'zh','POSTITIONLEVELCANNOTBEEMPTY','职位级别不能为空！','jspop' 
from dual where not exists(select 1 from ld_desk where languagetype='zh' and labelbol = 'POSTITIONLEVELCANNOTBEEMPTY' and labeltype = 'jspop'); 
delimiter;
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) 
select 'en','POSTITIONLEVELCANNOTBEEMPTY','Position level can not be empty!','jspop' 
from dual where not exists(select 1 from ld_desk where languagetype='en' and labelbol = 'POSTITIONLEVELCANNOTBEEMPTY' and labeltype = 'jspop'); 
delimiter;
-- 2015-09-18

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
delimiter;

update ld_version set old_version='V6.1.2' ,current_version='V6.1.2' ,remark='V6.1.2-20150918';
delimiter;