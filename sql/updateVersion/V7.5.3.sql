UPDATE ld_producttoolfield SET typeofdata=REPLACE(typeofdata,'V~M','V~O') WHERE tabid=(SELECT tabid FROM ld_tab WHERE `name`='QuotesChange') AND columnname='prosheet';
-- 2018-09-17

update ld_desk set fieldlabel = '显示成员账号' where labelbol = 'USEUSERACCOUNT' and languagetype = 'zh' and Labeltype = 'fixedstr';
update ld_desk set fieldlabel = 'Display User Name' where labelbol = 'USEUSERACCOUNT' and languagetype = 'en' and Labeltype = 'fixedstr';
delimiter;

update ld_systems_deploy set description='调用产品资料时是否显示无效的产品。0:否，1:是' where deploy_type=82 ;
delimiter;

update ld_tranlabel set fieldlabel='录入{$Products.Products}时允许选择禁用的产品管理' 
where tabid=82 and languagetype='zh' and trantable='ld_systems_deploy';
delimiter;

update ld_tranlabel set fieldlabel='Is allowed to select invalid products?' 
where tabid=82 and languagetype='en' and trantable='ld_systems_deploy';
delimiter;
 
call AddColumn('ld_singin','tabid','int','11',0);
call AddColumn('ld_singin','record','int','11',0);
update ld_singin set tabid = 6,record = accountid where accountid > 0 and tabid = 0 and record = 0;
delimiter;

select tabid into @tabid from ld_tab where `name` = 'ContactRecords';
select sequence into @sequence from ld_relatedlists where tabid = @tabid and `name` = 'get_attachment';
update ld_relatedlists set sequence = sequence + 1000 where tabid = @tabid and sequence > @sequence;
select max(relation_id) into @maxrelation_id from ld_relatedlists;
insert into ld_relatedlists(relation_id, tabid,related_tabid,name,sequence,label,presence,actions,related_coltable,type)
select @maxrelation_id+1,@tabid,0,'get_singin',@sequence+1,'Singin',0,'','','' from dual
where not EXISTS(select 1 from ld_relatedlists where tabid=@tabid and related_tabid=0 and `name`='get_singin');
set @i=0;
update ld_relatedlists set sequence=(@i:=@i+1) where tabid = @tabid order by sequence;
delimiter;

select tabid into @tabid from ld_tab where `name` = 'Contacts';
select sequence into @sequence from ld_relatedlists where tabid = @tabid and `name` = 'get_communicationLog';
update ld_relatedlists set sequence = sequence + 1000 where tabid = @tabid and sequence > @sequence;
select max(relation_id) into @maxrelation_id from ld_relatedlists;
insert into ld_relatedlists(relation_id, tabid,related_tabid,name,sequence,label,presence,actions,related_coltable,type)
select @maxrelation_id+1,@tabid,0,'get_singin',@sequence+1,'Singin',0,'','','' from dual
where not EXISTS(select 1 from ld_relatedlists where tabid=@tabid and related_tabid=0 and `name`='get_singin');
set @i=0;
update ld_relatedlists set sequence=(@i:=@i+1) where tabid = @tabid order by sequence;
delimiter;

select tabid into @tabid from ld_tab where `name` = 'Potentials';
select sequence into @sequence from ld_relatedlists where tabid = @tabid and `name` = 'get_contactrecords';
update ld_relatedlists set sequence = sequence + 1000 where tabid = @tabid and sequence > @sequence;
select max(relation_id) into @maxrelation_id from ld_relatedlists;
insert into ld_relatedlists(relation_id, tabid,related_tabid,name,sequence,label,presence,actions,related_coltable,type)
select @maxrelation_id+1,@tabid,0,'get_singin',@sequence+1,'Singin',0,'','','' from dual
where not EXISTS(select 1 from ld_relatedlists where tabid=@tabid and related_tabid=0 and `name`='get_singin');
set @i=0;
update ld_relatedlists set sequence=(@i:=@i+1) where tabid = @tabid order by sequence;
delimiter;

select tabid into @tabid from ld_tab where `name` = 'Project';
select sequence into @sequence from ld_relatedlists where tabid = @tabid and `name` = 'get_contactrecords';
update ld_relatedlists set sequence = sequence + 1000 where tabid = @tabid and sequence > @sequence;
select max(relation_id) into @maxrelation_id from ld_relatedlists;
insert into ld_relatedlists(relation_id, tabid,related_tabid,name,sequence,label,presence,actions,related_coltable,type)
select @maxrelation_id+1,@tabid,0,'get_singin',@sequence+1,'Singin',0,'','','' from dual
where not EXISTS(select 1 from ld_relatedlists where tabid=@tabid and related_tabid=0 and `name`='get_singin');
set @i=0;
update ld_relatedlists set sequence=(@i:=@i+1) where tabid = @tabid order by sequence;
delimiter;

select tabid into @tabid from ld_tab where `name` = 'Products';
select sequence into @sequence from ld_relatedlists where tabid = @tabid and `name` = 'get_attachment';
update ld_relatedlists set sequence = sequence + 1000 where tabid = @tabid and sequence > @sequence;
select max(relation_id) into @maxrelation_id from ld_relatedlists;
insert into ld_relatedlists(relation_id, tabid,related_tabid,name,sequence,label,presence,actions,related_coltable,type)
select @maxrelation_id+1,@tabid,0,'get_singin',@sequence+1,'Singin',0,'','','' from dual
where not EXISTS(select 1 from ld_relatedlists where tabid=@tabid and related_tabid=0 and `name`='get_singin');
set @i=0;
update ld_relatedlists set sequence=(@i:=@i+1) where tabid = @tabid order by sequence;
delimiter;

update ld_desk set fieldlabel = '签到地址' where languagetype = 'zh' and labelbol = 'SINGINADDRESS' and Labeltype = 'fixedstr';
update ld_desk set fieldlabel = '备注' where languagetype = 'zh' and labelbol = 'SINGINREMARKS' and Labeltype = 'fixedstr';
delimiter;

select tabid into @tabid from ld_tab where `name` = 'ContactRecords';
select fieldid into @trigger_fieldid from ld_field where tabid = @tabid and columnname = 'contactid';
select fieldid into @effect_fieldid from ld_field where tabid = @tabid and columnname = 'accountid';
insert into ld_related_field(fieldtype,trigger_fieldid,effect_fieldid,curmodule_columninfo,fromvalue_type,fromvalue_info)
select 'main',@trigger_fieldid,@effect_fieldid,'account_id,accounts_name','column','accountid' from dual
where not exists(select 1 from ld_related_field where trigger_fieldid = @trigger_fieldid and effect_fieldid = @effect_fieldid);
delimiter;
-- 2018-09-19

DROP PROCEDURE IF EXISTS `rest_quickcreatefield_PurchaseOrder`;
delimiter ||
CREATE PROCEDURE `rest_quickcreatefield_PurchaseOrder`()
BEGIN

	IF NOT EXISTS (SELECT 1 FROM ld_purchaseorder) OR DATABASE() LIKE 'wx1%' OR DATABASE() LIKE 'wx2%' OR DATABASE() LIKE 'wx3%' THEN

		SET @tabid=21;
		UPDATE ld_field SET quickcreate=1 WHERE tabid=@tabid;
		SET @i=0;
		SET @block=(SELECT block FROM ld_field WHERE tabid=@tabid AND columnname='smownerid');
		UPDATE ld_field SET sequence=sequence+100 WHERE tabid=@tabid AND block=@block;
		UPDATE ld_field SET sequence=1 WHERE tabid=@tabid AND block=@block AND columnname='vendorid';
		UPDATE ld_field SET sequence=2 WHERE tabid=@tabid AND block=@block AND columnname='contactid';
		UPDATE ld_field SET sequence=3 WHERE tabid=@tabid AND block=@block AND columnname='signed_data';
		UPDATE ld_field SET sequence=4 WHERE tabid=@tabid AND block=@block AND columnname='duedate';
		UPDATE ld_field SET sequence=5 WHERE tabid=@tabid AND block=@block AND uitype=202;
		UPDATE ld_field SET sequence=6 WHERE tabid=@tabid AND block=@block AND columnname='postatus';
		UPDATE ld_field SET sequence=7 WHERE tabid=@tabid AND block=@block AND columnname='smownerid';

		UPDATE ld_field SET sequence=(@i:=@i+1) WHERE tabid=@tabid AND block=@block ORDER BY sequence;
		UPDATE ld_field SET typeofdata=REPLACE(typeofdata,'V~M','V~O') WHERE tabid=@tabid AND columnname IN ('postatus','purchaseorder_no');
	END IF;

END ||
delimiter;

CALL `rest_quickcreatefield_PurchaseOrder`();
DROP PROCEDURE IF EXISTS `rest_quickcreatefield_PurchaseOrder`;
delimiter;


DROP PROCEDURE IF EXISTS `rest_quickcreatefield_OutboundOrder`;
delimiter ||
CREATE PROCEDURE `rest_quickcreatefield_OutboundOrder`()
BEGIN

	IF NOT EXISTS (SELECT 1 FROM ld_outboundorder) OR DATABASE() LIKE 'wx1%' OR DATABASE() LIKE 'wx2%' OR DATABASE() LIKE 'wx3%' THEN

		SET @tabid=(SELECT tabid FROM ld_tab WHERE `name`='OutboundOrder');
		UPDATE ld_field SET quickcreate=1 WHERE tabid=@tabid;
		SET @i=0;
		SET @block=(SELECT block FROM ld_field WHERE tabid=@tabid AND columnname='smownerid');
		UPDATE ld_field SET sequence=sequence+100 WHERE tabid=@tabid AND block=@block;
		UPDATE ld_field SET sequence=1 WHERE tabid=@tabid AND block=@block AND columnname='accountid';
		UPDATE ld_field SET sequence=2 WHERE tabid=@tabid AND block=@block AND columnname='contactid';
		UPDATE ld_field SET sequence=3 WHERE tabid=@tabid AND block=@block AND columnname='outdate';
		UPDATE ld_field SET sequence=4 WHERE tabid=@tabid AND block=@block AND columnname='wareid';
		UPDATE ld_field SET sequence=5 WHERE tabid=@tabid AND block=@block AND uitype=202;
		UPDATE ld_field SET sequence=(@i:=@i+1) WHERE tabid=@tabid AND block=@block ORDER BY sequence;
	END IF;

END ||
delimiter;

CALL `rest_quickcreatefield_OutboundOrder`();
DROP PROCEDURE IF EXISTS `rest_quickcreatefield_OutboundOrder`;
delimiter;


DROP PROCEDURE IF EXISTS `rest_quickcreatefield_Stock`;
delimiter ||
CREATE PROCEDURE `rest_quickcreatefield_Stock`()
BEGIN

	IF NOT EXISTS (SELECT 1 FROM ld_stock) OR DATABASE() LIKE 'wx1%' OR DATABASE() LIKE 'wx2%' OR DATABASE() LIKE 'wx3%' THEN

		SET @tabid=(SELECT tabid FROM ld_tab WHERE `name`='Stock');
		UPDATE ld_field SET quickcreate=1 WHERE tabid=@tabid;
		SET @i=0;
		SET @block=(SELECT block FROM ld_field WHERE tabid=@tabid AND columnname='smownerid');
		UPDATE ld_field SET sequence=sequence+100 WHERE tabid=@tabid AND block=@block;
		UPDATE ld_field SET sequence=1 WHERE tabid=@tabid AND block=@block AND columnname='vendorid';
		UPDATE ld_field SET sequence=2 WHERE tabid=@tabid AND block=@block AND columnname='contactid';
		UPDATE ld_field SET sequence=3 WHERE tabid=@tabid AND block=@block AND columnname='createdate';
		UPDATE ld_field SET sequence=4 WHERE tabid=@tabid AND block=@block AND columnname='wareid';
		UPDATE ld_field SET sequence=5 WHERE tabid=@tabid AND block=@block AND uitype=202;
		UPDATE ld_field SET sequence=(@i:=@i+1) WHERE tabid=@tabid AND block=@block ORDER BY sequence;
	END IF;

END ||
delimiter;

CALL `rest_quickcreatefield_Stock`();
DROP PROCEDURE IF EXISTS `rest_quickcreatefield_Stock`;
delimiter;


DROP PROCEDURE IF EXISTS `rest_quickcreatefield_PurchaseInvoice`;
delimiter ||
CREATE PROCEDURE `rest_quickcreatefield_PurchaseInvoice`()
BEGIN

	IF NOT EXISTS (SELECT 1 FROM ld_purchaseinvoice) OR DATABASE() LIKE 'wx1%' OR DATABASE() LIKE 'wx2%' OR DATABASE() LIKE 'wx3%' THEN

		SET @tabid=(SELECT tabid FROM ld_tab WHERE `name`='PurchaseInvoice');
		UPDATE ld_field SET quickcreate=1 WHERE tabid=@tabid;
		SET @i=0;
		SET @block=(SELECT block FROM ld_field WHERE tabid=@tabid AND columnname='smownerid');
		UPDATE ld_field SET sequence=sequence+100 WHERE tabid=@tabid AND block=@block;
		UPDATE ld_field SET sequence=1 WHERE tabid=@tabid AND block=@block AND columnname='vendorid';
		UPDATE ld_field SET sequence=2 WHERE tabid=@tabid AND block=@block AND columnname='purchaseinvoicetype';
		UPDATE ld_field SET sequence=3 WHERE tabid=@tabid AND block=@block AND columnname='purchaseinvoicedate';
		UPDATE ld_field SET sequence=4 WHERE tabid=@tabid AND block=@block AND columnname='purchaseinvoicenum';
		UPDATE ld_field SET sequence=5 WHERE tabid=@tabid AND block=@block AND uitype=202;
		UPDATE ld_field SET sequence=6 WHERE tabid=@tabid AND block=@block AND columnname='purchaseinvoicestatus';
		UPDATE ld_field SET presence=1,displaytype=3 WHERE columnname='discount_amount' AND tabid=@tabid AND NOT EXISTS (SELECT 1 FROM ld_purchaseinvoice);
		UPDATE ld_field SET sequence=(@i:=@i+1) WHERE tabid=@tabid AND block=@block ORDER BY sequence;
	END IF;

END ||
delimiter;

CALL `rest_quickcreatefield_PurchaseInvoice`();
DROP PROCEDURE IF EXISTS `rest_quickcreatefield_PurchaseInvoice`;
delimiter;


DROP PROCEDURE IF EXISTS `rest_quickcreatefield_PurchaseInquiryOrder`;
delimiter ||
CREATE PROCEDURE `rest_quickcreatefield_PurchaseInquiryOrder`()
BEGIN

	IF NOT EXISTS (SELECT 1 FROM ld_purchaseinquiryorder) OR DATABASE() LIKE 'wx1%' OR DATABASE() LIKE 'wx2%' OR DATABASE() LIKE 'wx3%' THEN

		SET @tabid=(SELECT tabid FROM ld_tab WHERE `name`='PurchaseInquiryOrder');
		UPDATE ld_field SET quickcreate=1 WHERE tabid=@tabid;
		SET @i=0;
		SET @block=(SELECT block FROM ld_field WHERE tabid=@tabid AND columnname='vendorid');
		UPDATE ld_field SET sequence=sequence+100 WHERE tabid=@tabid AND block=@block;
		UPDATE ld_field SET sequence=1 WHERE tabid=@tabid AND block=@block AND columnname='vendorid';
		UPDATE ld_field SET sequence=2 WHERE tabid=@tabid AND block=@block AND columnname='contactid';
		UPDATE ld_field SET sequence=3 WHERE tabid=@tabid AND block=@block AND uitype=202;
		UPDATE ld_field SET sequence=4 WHERE tabid=@tabid AND block=@block AND columnname='smownerid';
		UPDATE ld_field SET sequence=10000 WHERE tabid=@tabid AND block=@block AND columnname='purchaseinquiryorder_no';
		UPDATE ld_field SET sequence=(@i:=@i+1) WHERE tabid=@tabid AND block=@block ORDER BY sequence;
	END IF;

END ||
delimiter;

CALL `rest_quickcreatefield_PurchaseInquiryOrder`();
DROP PROCEDURE IF EXISTS `rest_quickcreatefield_PurchaseInquiryOrder`;
delimiter;

insert into ld_desk (languagetype,labelbol,fieldlabel,Labeltype)
select 'zh','COOPERATIVEWORKTITLE',"一天的工作开始于前一天晚上，创建工作汇报吧！",'fixedstr' from DUAL
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='COOPERATIVEWORKTITLE' and Labeltype='fixedstr');
insert into ld_desk (languagetype,labelbol,fieldlabel,Labeltype)
select 'en','COOPERATIVEWORKTITLE',"A day's work starts the night before. Create a Cooperative Work!",'fixedstr' from DUAL
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='COOPERATIVEWORKTITLE' and Labeltype='fixedstr');
delimiter;

UPDATE ld_desk SET fieldlabel='一天的工作开始于前一天晚上，创建工作汇报吧！' WHERE labelbol='COOPERATIVEWORKTITLE' AND Labeltype='fixedstr' AND languagetype='zh';
-- 2018-09-20

select tabid into @tabid from ld_tab where `name` = 'SendCashBill';
select fieldid into @trigger_fieldid from ld_field where tabid = @tabid and uitype = 202;
select fieldid into @effect_fieldid from ld_field where tabid = @tabid and columnname = 'vendorid';
update ld_related_field set curmodule_columninfo = 'vendor_id,vendors_name' where trigger_fieldid = @trigger_fieldid and effect_fieldid = @effect_fieldid;
delimiter;

select max(tabid) into @tabid from ld_tab;
select max(tabsequence) into @tabsequence from ld_tab;
insert into ld_tab(tabid,name,presence,tabsequence,tablabel,isentitytype,parent,printtab)
select @tabid + 1,'Singin',1,@tabsequence+1,'Singin',1,'Tools',0 
from dual where not EXISTS(select 1 from ld_tab where `name`='Singin');
delimiter;

select tabid into @tabid from ld_tab where `name` = 'Singin';
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'zh','ld_tab',@tabid,@tabid,'签到' 
from dual where not EXISTS(select 1 from ld_tranlabel  where languagetype = 'zh' 
and trantable ='ld_tab' and tabid = @tabid and Relateid=@tabid);
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'en','ld_tab',@tabid,@tabid,'Singin' 
from dual where not EXISTS(select 1 from ld_tranlabel  where languagetype = 'en' 
and trantable ='ld_tab' and tabid = @tabid and Relateid=@tabid);
delimiter;

select tabid into @tabid from ld_tab where name = 'Singin';
insert into ld_option_module(tabid,option_tabid,presence,`default`,approve_demand,sequence)
select @tabid,6,0,1,0,1
from dual where not exists(select 1 from ld_option_module where tabid = @tabid and option_tabid = 6);
delimiter;
insert into ld_option_module(tabid,option_tabid,presence,`default`,approve_demand,sequence)
select @tabid,4,0,0,0,2 
from dual where not exists(select 1 from ld_option_module where tabid = @tabid and option_tabid = 4);
delimiter;
select tabid into @ContactRecords_tabid from ld_tab where `name` = 'ContactRecords';
insert into ld_option_module(tabid,option_tabid,presence,`default`,approve_demand,sequence)
select @tabid,@ContactRecords_tabid,0,0,0,3
from dual where not exists(select 1 from ld_option_module where tabid = @tabid and option_tabid = @ContactRecords_tabid);
delimiter;

insert into ld_option_module(tabid,option_tabid,presence,`default`,approve_demand,sequence)
select @tabid,2,0,0,0,4
from dual where not exists(select 1 from ld_option_module where tabid = @tabid and option_tabid = 2);
delimiter;

select tabid into @Project_tabid from ld_tab where `name` = 'Project';
insert into ld_option_module(tabid,option_tabid,presence,`default`,approve_demand,sequence)
select @tabid,@Project_tabid,0,0,0,5
from dual where not exists(select 1 from ld_option_module where tabid = @tabid and option_tabid = @Project_tabid);
delimiter;

select tabid into @Products_tabid from ld_tab where `name` = 'Products';
insert into ld_option_module(tabid,option_tabid,presence,`default`,approve_demand,sequence)
select @tabid,@Products_tabid,1,0,0,6
from dual where not exists(select 1 from ld_option_module where tabid = @tabid and option_tabid = @Products_tabid);
delimiter;

select tabid into @tabid from ld_tab where `name` = 'Singin';
select max(fieldid) into @max_fieldid from ld_field;
set @blockid = 1;

insert into ld_field(tabid,fieldid,columnname,allowhide,tablename,generatedtype,uitype,fieldname,fieldlabel,readonly,presence,defaultvalue,maximumlength,
sequence,block,displaytype,typeofdata,quickcreate,quickcreatesequence,info_type,masseditable,helpinfo,fieldonly,issmownerid,searchfieldtype,associatedfields,
associatedsequence,callchecked,duplicatefield,relate_search_parent_columnname,approve_demand,is_checkimportfield)
select @tabid,@max_fieldid+1,'record','yes','ld_singin',1,1,'record','拜访对象类型',1,2,NULL,NULL,1,@blockid,1,'V~O',1,NULL,NULL,1,NULL,0,0,0,0,0,0,NULL,NULL,0,0 
from DUAL where not exists(select 1 from ld_field where tabid = @tabid and columnname = 'record');

insert into ld_field(tabid,fieldid,columnname,allowhide,tablename,generatedtype,uitype,fieldname,fieldlabel,readonly,presence,defaultvalue,maximumlength,
sequence,block,displaytype,typeofdata,quickcreate,quickcreatesequence,info_type,masseditable,helpinfo,fieldonly,issmownerid,searchfieldtype,associatedfields,
associatedsequence,callchecked,duplicatefield,relate_search_parent_columnname,approve_demand,is_checkimportfield,allowedit)
select @tabid,@max_fieldid+2,'address','yes','ld_singin',1,1,'address','拜访地址',1,2,NULL,NULL,1,@blockid,1,'V~O',1,NULL,NULL,1,NULL,0,0,0,0,0,0,NULL,NULL,0,0,'no' 
from DUAL where not exists(select 1 from ld_field where tabid = @tabid and columnname = 'address');
delimiter;

update ld_field_seq set id = (select max(fieldid) from ld_field);
delimiter;

select tabid into @tabid from ld_tab where `name` = 'Singin';
select fieldid into @relateid from ld_field where tabid = @tabid and columnname = 'record';
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'zh','ld_field',@tabid,@relateid,'拜访对象类型' from DUAL
where not exists(select 1 from ld_tranlabel where tabid = @tabid and relateid = @relateid and languagetype = 'zh' and trantable = 'ld_field');
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'en','ld_field',@tabid,@relateid,'Singin type' from DUAL
where not exists(select 1 from ld_tranlabel where tabid = @tabid and relateid = @relateid and languagetype = 'en' and trantable = 'ld_field');
delimiter;

select tabid into @tabid from ld_tab where `name` = 'Singin';
select fieldid into @relateid from ld_field where tabid = @tabid and columnname = 'address';
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'zh','ld_field',@tabid,@relateid,'拜访地址' from DUAL
where not exists(select 1 from ld_tranlabel where tabid = @tabid and relateid = @relateid and languagetype = 'zh' and trantable = 'ld_field');
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'en','ld_field',@tabid,@relateid,'Singin address' from DUAL
where not exists(select 1 from ld_tranlabel where tabid = @tabid and relateid = @relateid and languagetype = 'en' and trantable = 'ld_field');
delimiter;

call fieldprofile('Singin');
delimiter;

call getallprofile('Singin');
delimiter;

select tabid into @tabid from ld_tab where `name` = 'Singin';
select fieldid into @trigger_fieldid from ld_field where tabid = @tabid and columnname = 'record';
select fieldid into @effect_fieldid from ld_field where tabid = @tabid and columnname = 'address';
insert into ld_related_field(fieldtype,trigger_fieldid,effect_fieldid,curmodule_columninfo,fromvalue_type,fromvalue_info)
select 'main',@trigger_fieldid,@effect_fieldid,'','sql','select CONCAT(ld_account.bill_city,ld_account.bill_street) as address from ld_account where ld_account.deleted = 0 and accountid = ? UNION select CONCAT(ld_account.bill_city,ld_account.bill_street) as address from ld_contactdetails INNER JOIN ld_account on ld_account.accountid = ld_contactdetails.accountid where ld_account.deleted = 0 and ld_contactdetails.contactid = ? UNION select CONCAT(ld_account.bill_city,ld_account.bill_street) as address from ld_contactrecords INNER JOIN ld_account on ld_account.accountid = ld_contactrecords.accountid where ld_account.deleted = 0 and ld_contactrecords.contactrecordID = ? UNION select CONCAT(ld_account.bill_city,ld_account.bill_street) as address from ld_potential INNER JOIN ld_account on ld_account.accountid = ld_potential.accountid where ld_account.deleted = 0 and ld_potential.potentialid = ? UNION select CONCAT(ld_account.bill_city,ld_account.bill_street) as address from ld_project INNER JOIN ld_account on ld_account.accountid = ld_project.accountid where ld_account.deleted = 0 and ld_project.projectid = ?' from dual
where not exists(select 1 from ld_related_field where trigger_fieldid = @trigger_fieldid and effect_fieldid = @effect_fieldid);
delimiter;

select sequence into @sequence from ld_systems_deploy where deploy_type=132;
update ld_systems_deploy set sequence=sequence+1 where roottype=4 and sequence>@sequence;
delimiter;

insert into ld_systems_deploy(deploy_value,deploy_type,description,sequence,roottype,inputtype,presence,inputvalue)
select 0,165,'设置网页端上传图片时是否压缩',@sequence+1,4,'select',0,'[{"value":"0","text":"YES"},{"value":"1","text":"NO"},{"sql":""}]'
from dual where not exists(select 1 from ld_systems_deploy  where deploy_type=165);
delimiter;

select deploy_type into @relateid from ld_systems_deploy where deploy_type=165;
insert into ld_tranlabel(LANGUAGEtype,trantable,tabid,relateid,fieldlabel)
select 'zh','ld_systems_deploy',@relateid,@relateid,'设置网页端上传图片时是否压缩' from DUAL
where not exists(select 1 from ld_tranlabel where tabid=@relateid and relateid=@relateid and trantable='ld_systems_deploy' and languagetype='zh');

insert into ld_tranlabel(LANGUAGEtype,trantable,tabid,relateid,fieldlabel)
select 'en','ld_systems_deploy',@relateid,@relateid,'Do you want to compress web pages when uploading pictures?' from DUAL
where not exists(select 1 from ld_tranlabel where tabid=@relateid and relateid=@relateid and trantable='ld_systems_deploy' and languagetype='en');
delimiter;

call AddColumn('ld_singin','entityname','varchar','100',NULL);
delimiter;

select usereportid into @usereportid from ld_usereport where `name`= 'SIGNINSTATISTICS';
select Sequence into @sequence from ld_usereportcolumns where Usereportid = @usereportid and `columns` like '%ld_accounts:accountname:accountname:OftenUseReport_%';
update ld_usereportcolumns set Sequence = Sequence + 1000 where Usereportid = @usereportid and Sequence > @sequence;
insert into ld_usereportcolumns(Usereportid,`columns`,Sequence,columnshow,realcolumns,realencolumns)
select @usereportid,'ld_singin:record:record:OftenUseReport_拜访对象类型:V',@sequence+1,1,'ld_singin:record:record:OftenUseReport_拜访对象类型:V','ld_singin:record:record:OftenUseReport_SinginModule:V' from DUAL
where not exists(select 1 from ld_usereportcolumns where `columns` = 'ld_singin:record:record:OftenUseReport_拜访对象类型:V');
insert into ld_usereportcolumns(Usereportid,`columns`,Sequence,columnshow,realcolumns,realencolumns)
select @usereportid,'ld_singin:entityname:entityname:OftenUseReport_拜访对象:V',@sequence+2,1,'ld_singin:entityname:entityname:OftenUseReport_拜访对象:V','ld_singin:record:record:OftenUseReport_SinginModuleName:V' from DUAL
where not exists(select 1 from ld_usereportcolumns where `columns` = 'ld_singin:entityname:entityname:OftenUseReport_拜访对象:V');
set @i=0;
update ld_usereportcolumns set Sequence=(@i:=@i+1) where Usereportid = @usereportid order by Sequence;
delimiter;

select usereportid into @usereportid from ld_usereport where `name`= 'SIGNINSTATISTICS';
delete from ld_usereportcolumns where Usereportid = @usereportid and `columns` like '%ld_accounts:accountname:accountname:OftenUseReport_%';
delimiter;
-- 2018-09-21

select usereportid into @usereportid from ld_usereport where `name`= 'SIGNINSTATISTICS';
select Sequence into @sequence from ld_usereportcolumns where Usereportid = @usereportid and `columns` like '%ld_users:last_name:last_name:OftenUseReport_%';
update ld_usereportcolumns set Sequence = Sequence + 1000 where Usereportid = @usereportid and Sequence > @sequence;
insert into ld_usereportcolumns(Usereportid,`columns`,Sequence,columnshow,realcolumns,realencolumns)
select @usereportid,'ld_users:groupname:groupname:OftenUseReport_部门:V',@sequence+1,1,'ld_users:groupname:groupname:OftenUseReport_部门:V','ld_users:groupname:groupname:OftenUseReport_Groupname:V' from DUAL
where not exists(select 1 from ld_usereportcolumns where `columns` = 'ld_users:groupname:groupname:OftenUseReport_部门:V' and Usereportid = @usereportid);
set @i=0;
update ld_usereportcolumns set Sequence=(@i:=@i+1) where Usereportid = @usereportid order by Sequence;
delimiter;

select usereportid into @usereportid from ld_usereport where `name`= 'SalesOrderTrack';
select Sequence into @sequence from ld_usereportcolumns where Usereportid = @usereportid and `columns` like '%ld_crmentity:smownerid:assigned_user_id:SalesOrder_assigned_user_id:V%';
update ld_usereportcolumns set Sequence = Sequence + 1000 where Usereportid = @usereportid and Sequence > @sequence;
insert into ld_usereportcolumns(Usereportid,`columns`,Sequence,columnshow,realcolumns,realencolumns)
select @usereportid,'ld_crmentity:groupname:groupname:OftenUseReport_groupname:V',@sequence+1,1,'ld_crmentity:groupname:groupname:OftenUseReport_部门:V','ld_crmentity:groupname:groupname:OftenUseReport_Groupname:V' from DUAL
where not exists(select 1 from ld_usereportcolumns where `columns` = 'ld_crmentity:groupname:groupname:OftenUseReport_groupname:V' and Usereportid = @usereportid);
set @i=0;
update ld_usereportcolumns set Sequence=(@i:=@i+1) where Usereportid = @usereportid order by Sequence;
delimiter;

select usereportid into @usereportid from ld_usereport where `name`= 'Salesforecastandanalysistable';
select Sequence into @sequence from ld_usereportcolumns where Usereportid = @usereportid and `columns` like '%ld_potential:last_name:last_name:Potentials_last_name:V%';
update ld_usereportcolumns set Sequence = Sequence + 1000 where Usereportid = @usereportid and Sequence > @sequence;
insert into ld_usereportcolumns(Usereportid,`columns`,Sequence,columnshow,realcolumns,realencolumns)
select @usereportid,'ld_potential:groupname:groupname:Potentials_groupname:V',@sequence+1,1,'ld_potential:groupname:groupname:Potentials_部门:V','ld_potential:groupname:groupname:Potentials_Groupname:V' from DUAL
where not exists(select 1 from ld_usereportcolumns where `columns` = 'ld_potential:groupname:groupname:Potentials_groupname:V' and Usereportid = @usereportid);
set @i=0;
update ld_usereportcolumns set Sequence=(@i:=@i+1) where Usereportid = @usereportid order by Sequence;
delimiter;

select usereportid into @usereportid from ld_usereport where `name`= 'CashBillSum_Paymentplan';
select Sequence into @sequence from ld_usereportcolumns where Usereportid = @usereportid and `columns` like '%ld_paymentplan:smownerid:assigned_user_id:PaymentPlan_assigned_user_id:V%';
update ld_usereportcolumns set Sequence = Sequence + 1000 where Usereportid = @usereportid and Sequence > @sequence;
insert into ld_usereportcolumns(Usereportid,`columns`,Sequence,columnshow,realcolumns,realencolumns)
select @usereportid,'ld_paymentplan:groupname:groupname:PaymentPlan_groupname:V',@sequence+1,1,'ld_paymentplan:groupname:groupname:PaymentPlan_部门:V','ld_paymentplan:groupname:groupname:PaymentPlan_Groupname:V' from DUAL
where not exists(select 1 from ld_usereportcolumns where `columns` = 'ld_paymentplan:groupname:groupname:PaymentPlan_groupname:V' and Usereportid = @usereportid);
set @i=0;
update ld_usereportcolumns set Sequence=(@i:=@i+1) where Usereportid = @usereportid order by Sequence;
delimiter;

select usereportid into @usereportid from ld_usereport where `name`= 'CashBillSum_SalesOrder';
select Sequence into @sequence from ld_usereportcolumns where Usereportid = @usereportid and `columns` like '%ld_usersSalesOrder:smownerid:assigned_user_id:SalesOrder_assigned_user_id:V%';
update ld_usereportcolumns set Sequence = Sequence + 1000 where Usereportid = @usereportid and Sequence > @sequence;
insert into ld_usereportcolumns(Usereportid,`columns`,Sequence,columnshow,realcolumns,realencolumns)
select @usereportid,'ld_salesorder:groupname:groupname:SalesOrder_groupname:V',@sequence+1,1,'ld_salesorder:groupname:groupname:SalesOrder_部门:V','ld_salesorder:groupname:groupname:SalesOrder_Groupname:V' from DUAL
where not exists(select 1 from ld_usereportcolumns where `columns` = 'ld_salesorder:groupname:groupname:SalesOrder_groupname:V' and Usereportid = @usereportid);
set @i=0;
update ld_usereportcolumns set Sequence=(@i:=@i+1) where Usereportid = @usereportid order by Sequence;
delimiter;

select usereportid into @usereportid from ld_usereport where `name`= 'Performancestatisticscollection';
select Sequence into @sequence from ld_usereportcolumns where Usereportid = @usereportid and `columns` like '%ld_users:lastname:lastname:OftenUseReport_lastname:V%';
update ld_usereportcolumns set Sequence = Sequence + 1000 where Usereportid = @usereportid and Sequence > @sequence;
insert into ld_usereportcolumns(Usereportid,`columns`,Sequence,columnshow,realcolumns,realencolumns)
select @usereportid,'ld_cashbill:groupname:groupname:OftenUseReport_groupname:V',@sequence+1,1,'ld_cashbill:groupname:groupname:OftenUseReport_部门:V','ld_cashbill:groupname:groupname:OftenUseReport_Groupname:V' from DUAL
where not exists(select 1 from ld_usereportcolumns where `columns` = 'ld_cashbill:groupname:groupname:OftenUseReport_groupname:V' and Usereportid = @usereportid);
set @i=0;
update ld_usereportcolumns set Sequence=(@i:=@i+1) where Usereportid = @usereportid order by Sequence;
delimiter;

select usereportid into @usereportid from ld_usereport where `name`= 'PurchaseOrderTrack';
select Sequence into @sequence from ld_usereportcolumns where Usereportid = @usereportid and `columns` like '%ld_crmentity:smownerid:assigned_user_id:PurchaseOrder_assigned_user_id:V%';
update ld_usereportcolumns set Sequence = Sequence + 1000 where Usereportid = @usereportid and Sequence > @sequence;
insert into ld_usereportcolumns(Usereportid,`columns`,Sequence,columnshow,realcolumns,realencolumns)
select @usereportid,'ld_crmentity:groupname:groupname:PurchaseOrder_groupname:V',@sequence+1,1,'ld_crmentity:groupname:groupname:PurchaseOrder_部门:V','ld_crmentity:groupname:groupname:PurchaseOrder_Groupname:V' from DUAL
where not exists(select 1 from ld_usereportcolumns where `columns` = 'ld_crmentity:groupname:groupname:PurchaseOrder_groupname:V' and Usereportid = @usereportid);
set @i=0;
update ld_usereportcolumns set Sequence=(@i:=@i+1) where Usereportid = @usereportid order by Sequence;
delimiter;

select usereportid into @usereportid from ld_usereport where `name`= 'SendCashBillSum_PurchaseOrder';
select Sequence into @sequence from ld_usereportcolumns where Usereportid = @usereportid and `columns` like '%ld_usersPurchaseOrder:smownerid:assigned_user_id:PurchaseOrder_assigned_user_id:V%';
update ld_usereportcolumns set Sequence = Sequence + 1000 where Usereportid = @usereportid and Sequence > @sequence;
insert into ld_usereportcolumns(Usereportid,`columns`,Sequence,columnshow,realcolumns,realencolumns)
select @usereportid,'ld_usersPurchaseOrder:groupname:groupname:PurchaseOrder_groupname:V',@sequence+1,1,'ld_usersPurchaseOrder:groupname:groupname:PurchaseOrder_部门:V','ld_usersPurchaseOrder:groupname:groupname:PurchaseOrder_Groupname:V' from DUAL
where not exists(select 1 from ld_usereportcolumns where `columns` = 'ld_usersPurchaseOrder:groupname:groupname:PurchaseOrder_groupname:V' and Usereportid = @usereportid);
set @i=0;
update ld_usereportcolumns set Sequence=(@i:=@i+1) where Usereportid = @usereportid order by Sequence;
delimiter;

select usereportid into @usereportid from ld_usereport where `name`= 'SendCashBillSum_SendPayment';
select Sequence into @sequence from ld_usereportcolumns where Usereportid = @usereportid and `columns` like '%ld_crmentity:smownerid:smownerid:SendPayment_smownerid:V%';
update ld_usereportcolumns set Sequence = Sequence + 1000 where Usereportid = @usereportid and Sequence > @sequence;
insert into ld_usereportcolumns(Usereportid,`columns`,Sequence,columnshow,realcolumns,realencolumns)
select @usereportid,'ld_crmentity:groupname:groupname:SendPayment_groupname:V',@sequence+1,1,'ld_crmentity:groupname:groupname:SendPayment_部门:V','ld_crmentity:groupname:groupname:SendPayment_Groupname:V' from DUAL
where not exists(select 1 from ld_usereportcolumns where `columns` = 'ld_crmentity:groupname:groupname:SendPayment_groupname:V' and Usereportid = @usereportid);
set @i=0;
update ld_usereportcolumns set Sequence=(@i:=@i+1) where Usereportid = @usereportid order by Sequence;
delimiter;

select usereportid into @usereportid from ld_usereport where `name`= 'Contractnumber';
select Sequence into @sequence from ld_usereportcolumns where Usereportid = @usereportid and `columns` like '%ld_salesorder:smownerid:smownerid:SalesOrder_smownerid:V%';
update ld_usereportcolumns set Sequence = Sequence + 1000 where Usereportid = @usereportid and Sequence > @sequence;
insert into ld_usereportcolumns(Usereportid,`columns`,Sequence,columnshow,realcolumns,realencolumns)
select @usereportid,'ld_salesorder:groupname:groupname:SalesOrder_groupname:V',@sequence+1,1,'ld_salesorder:groupname:groupname:SalesOrder_部门:V','ld_salesorder:groupname:groupname:SalesOrder_Groupname:V' from DUAL
where not exists(select 1 from ld_usereportcolumns where `columns` = 'ld_salesorder:groupname:groupname:SalesOrder_groupname:V' and Usereportid = @usereportid);
set @i=0;
update ld_usereportcolumns set Sequence=(@i:=@i+1) where Usereportid = @usereportid order by Sequence;
delimiter;

select usereportid into @usereportid from ld_usereport where `name`= 'Contractamount';
select Sequence into @sequence from ld_usereportcolumns where Usereportid = @usereportid and `columns` like '%ld_salesorder:smownerid:smownerid:SalesOrder_smownerid:V%';
update ld_usereportcolumns set Sequence = Sequence + 1000 where Usereportid = @usereportid and Sequence > @sequence;
insert into ld_usereportcolumns(Usereportid,`columns`,Sequence,columnshow,realcolumns,realencolumns)
select @usereportid,'ld_salesorder:groupname:groupname:SalesOrder_groupname:V',@sequence+1,1,'ld_salesorder:groupname:groupname:SalesOrder_部门:V','ld_salesorder:groupname:groupname:SalesOrder_Groupname:V' from DUAL
where not exists(select 1 from ld_usereportcolumns where `columns` = 'ld_salesorder:groupname:groupname:SalesOrder_groupname:V' and Usereportid = @usereportid);
set @i=0;
update ld_usereportcolumns set Sequence=(@i:=@i+1) where Usereportid = @usereportid order by Sequence;
delimiter;

select usereportid into @usereportid from ld_usereport where `name`= 'THESINGNINGAMOUNTOFBILLBOARD';
select Sequence into @sequence from ld_usereportcolumns where Usereportid = @usereportid and `columns` like '%ld_cashbill:smownerid:smownerid:CashBill_smownerid:V%';
update ld_usereportcolumns set Sequence = Sequence + 1000 where Usereportid = @usereportid and Sequence > @sequence;
insert into ld_usereportcolumns(Usereportid,`columns`,Sequence,columnshow,realcolumns,realencolumns)
select @usereportid,'ld_cashbill:groupname:groupname:CashBill_groupname:V',@sequence+1,1,'ld_cashbill:groupname:groupname:CashBill_部门:V','ld_cashbill:groupname:groupname:CashBill_Groupname:V' from DUAL
where not exists(select 1 from ld_usereportcolumns where `columns` = 'ld_cashbill:groupname:groupname:CashBill_groupname:V' and Usereportid = @usereportid);
set @i=0;
update ld_usereportcolumns set Sequence=(@i:=@i+1) where Usereportid = @usereportid order by Sequence;
delimiter;

select usereportid into @usereportid from ld_usereport where `name`= 'SalesSumSequence';
select Sequence into @sequence from ld_usereportcolumns where Usereportid = @usereportid and `columns` like '%ld_users:last_name:last_name:OftenUseReport_last_name:V%';
update ld_usereportcolumns set Sequence = Sequence + 1000 where Usereportid = @usereportid and Sequence > @sequence;
insert into ld_usereportcolumns(Usereportid,`columns`,Sequence,columnshow,realcolumns,realencolumns)
select @usereportid,'ld_users:groupname:groupname:OftenUseReport_groupname:V',@sequence+1,1,'ld_users:groupname:groupname:OftenUseReport_部门:V','ld_users:groupname:groupname:OftenUseReport_Groupname:V' from DUAL
where not exists(select 1 from ld_usereportcolumns where `columns` = 'ld_users:groupname:groupname:OftenUseReport_groupname:V' and Usereportid = @usereportid);
set @i=0;
update ld_usereportcolumns set Sequence=(@i:=@i+1) where Usereportid = @usereportid order by Sequence;
delimiter;

select usereportid into @usereportid from ld_usereport where `name`= 'Thestatisticalreportofprojectperformance';
select Sequence into @sequence from ld_usereportcolumns where Usereportid = @usereportid and `columns` like '%ld_account:last_name:last_name:Accounts_last_name:V%';
update ld_usereportcolumns set Sequence = Sequence + 1000 where Usereportid = @usereportid and Sequence > @sequence;
insert into ld_usereportcolumns(Usereportid,`columns`,Sequence,columnshow,realcolumns,realencolumns)
select @usereportid,'ld_project:groupname:groupname:OftenUseReport_groupname:V',@sequence+1,1,'ld_project:groupname:groupname:OftenUseReport_部门:V','ld_project:groupname:groupname:OftenUseReport_Groupname:V' from DUAL
where not exists(select 1 from ld_usereportcolumns where `columns` = 'ld_project:groupname:groupname:OftenUseReport_groupname:V' and Usereportid = @usereportid);
set @i=0;
update ld_usereportcolumns set Sequence=(@i:=@i+1) where Usereportid = @usereportid order by Sequence;
delimiter;

select usereportid into @usereportid from ld_usereport where `name`= 'Serviceperformanceappraisal';
select Sequence into @sequence from ld_usereportcolumns where Usereportid = @usereportid and `columns` like '%ld_users:lastname:lastname:OftenUseReport_lastname:V%';
update ld_usereportcolumns set Sequence = Sequence + 1000 where Usereportid = @usereportid and Sequence > @sequence;
insert into ld_usereportcolumns(Usereportid,`columns`,Sequence,columnshow,realcolumns,realencolumns)
select @usereportid,'ld_users:groupname:groupname:OftenUseReport_groupname:V',@sequence+1,1,'ld_users:groupname:groupname:OftenUseReport_部门:V','ld_project:groupname:groupname:OftenUseReport_Groupname:V' from DUAL
where not exists(select 1 from ld_usereportcolumns where `columns` = 'ld_users:groupname:groupname:OftenUseReport_groupname:V' and Usereportid = @usereportid);
set @i=0;
update ld_usereportcolumns set Sequence=(@i:=@i+1) where Usereportid = @usereportid order by Sequence;
delimiter;

call AddColumn('ld_contactrecords','longtitude','varchar','200',NULL);
call AddColumn('ld_contactrecords','latitude','varchar','200',NULL);
call AddColumn('ld_contactrecords','location_address','varchar','200',NULL);

select tabid into @tabid from ld_tab where `name` = 'ContactRecords';
select max(blockid)+1 into @max_blockid from ld_blocks;
insert into ld_blocks(blockid,tabid,blocklabel,sequence,show_title,visible,create_view,edit_view,detail_view,display_status,iscustom)
select @max_blockid,@tabid,'LBL_ADDRESS_SINGIN',10000,0,0,0,0,0,1,0 from DUAL
where not exists(select 1 from ld_blocks where tabid = @tabid and blocklabel = 'LBL_ADDRESS_SINGIN');
set @i=0;
update ld_blocks set sequence=(@i:=@i+1) where tabid = @tabid order by sequence;
select blockid into @blockid from ld_blocks where tabid = @tabid and blocklabel = 'LBL_ADDRESS_SINGIN';

insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'zh','ld_blocks',@tabid,@blockid,'签到地址信息' from dual
where not exists(select 1 from ld_tranlabel where languagetype = 'zh' and trantable = 'ld_blocks' and tabid = @tabid and relateid = @blockid);
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'en','ld_blocks',@tabid,@blockid,'Sing Address Information' from dual
where not exists(select 1 from ld_tranlabel where languagetype = 'en' and trantable = 'ld_blocks' and tabid = @tabid and relateid = @blockid);
update ld_blocks_seq set id = (select max(blockid) from ld_blocks);
delimiter;

select tabid into @tabid from ld_tab where `name` = 'ContactRecords';
select blockid into @blockid from ld_blocks where tabid = @tabid and blocklabel = 'LBL_ADDRESS_SINGIN';
select max(fieldid)+1 into @fieldid from ld_field;
insert into ld_field(tabid,fieldid,columnname,allowhide,tablename,generatedtype,uitype,fieldname,fieldlabel,readonly,presence,defaultvalue,maximumlength,
sequence,block,displaytype,typeofdata,quickcreate,quickcreatesequence,info_type,masseditable,helpinfo,fieldonly,issmownerid,searchfieldtype,associatedfields,
associatedsequence,callchecked,duplicatefield,relate_search_parent_columnname,approve_demand,is_checkimportfield)
select @tabid,@fieldid,'location_address','no','ld_contactrecords',1,1,'location_address','签到地址',1,2,NULL,NULL,1,@blockid,2,'V~O',1,NULL,NULL,1,NULL,0,0,0,0,0,0,NULL,NULL,0,0 
from DUAL where not exists(select 1 from ld_field where tabid = @tabid and columnname = 'location_address');
select fieldid into @relateid from ld_field where tabid = @tabid and columnname = 'location_address';

insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'zh','ld_field',@tabid,@relateid,'签到地址' from DUAL
where not exists(select 1 from ld_tranlabel where tabid = @tabid and relateid = @relateid and languagetype = 'zh' and trantable = 'ld_field');

insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'en','ld_field',@tabid,@relateid,'Sing address' from DUAL
where not exists(select 1 from ld_tranlabel where tabid = @tabid and relateid = @relateid and languagetype = 'en' and trantable = 'ld_field');
delimiter;

select usereportid into @usereportid from ld_usereport where `name` = 'SumSequence';
update ld_usereport set sequence = sequence + 1000 where parent_id = @usereportid;
insert into ld_usereport(`name`,reportlabel,tabids,basicfilter,advfilter,Setcolumns,Parent_id,sequence,reporttype,pagewidthpercent,presence,setype)
select 'Salesranking','销售排行榜',22,1,0,0,@usereportid,1,60,100,0,'SalesOrder' from DUAL
where not exists(select 1 from ld_usereport where `name` = 'Salesranking');
set @i=0;
update ld_usereport set sequence=(@i:=@i+1) where parent_id = @usereportid order by Sequence;
delimiter;

insert into ld_desk (languagetype,labelbol,fieldlabel,Labeltype)
select 'zh','Salesranking',"销售排行榜",'fixedstr' from DUAL
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='Salesranking' and Labeltype='fixedstr');
insert into ld_desk (languagetype,labelbol,fieldlabel,Labeltype)
select 'en','Salesranking',"Sales ranking",'fixedstr' from DUAL
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='Salesranking' and Labeltype='fixedstr');
delimiter;

select usereportid into @usereportid from ld_usereport where `name` = 'Salesranking';
insert into ld_usereportbasic(Usereportid,`columns`,Defaultvalue,Sequence)
select @usereportid,'ld_salesorder:signed_data:signed_data:SalesOrder_signed_data:D','thisstartmonth~thisendmonth',1 from DUAL
where not exists(select 1 from ld_usereportbasic where Usereportid = @usereportid);
delimiter;

insert into ld_desk (languagetype,labelbol,fieldlabel,Labeltype)
select 'zh','Rankingdimension',"排行维度",'fixedstr' from DUAL
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='Rankingdimension' and Labeltype='fixedstr');
insert into ld_desk (languagetype,labelbol,fieldlabel,Labeltype)
select 'en','Rankingdimension',"Ranking dimension",'fixedstr' from DUAL
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='Rankingdimension' and Labeltype='fixedstr');
delimiter;

insert into ld_desk (languagetype,labelbol,fieldlabel,Labeltype)
select 'zh','Onlythroughdatastatisticsexaminationapproval1',"只统计审批通过的",'fixedstr' from DUAL
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='Onlythroughdatastatisticsexaminationapproval1' and Labeltype='fixedstr');
insert into ld_desk (languagetype,labelbol,fieldlabel,Labeltype)
select 'en','Onlythroughdatastatisticsexaminationapproval1',"Ranking dimension",'fixedstr' from DUAL
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='Onlythroughdatastatisticsexaminationapproval1' and Labeltype='fixedstr');
delimiter;

select usereportid into @usereportid from ld_usereport where `name` = 'SumSequence';
update ld_usereport set presence = 1 where Parent_id = @usereportid and `name` in ('Contractnumber','Contractamount','THESINGNINGAMOUNTOFBILLBOARD');
delimiter;

call AddColumn('ld_attachments','newfile_name','varchar','100',0);
call AddColumn('ld_workachments','newfile_name','varchar','100',0);

update ld_attachments set newfile_name=`name` where newfile_name is null or newfile_name ='';

update ld_workachments set newfile_name=`name` where newfile_name is null or newfile_name ='';
delimiter;

insert into ld_desk (languagetype,labelbol,fieldlabel,Labeltype)
select 'zh','onlyshowpaymorethanzero',"只显示应付款大于0",'fixedstr' from DUAL
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='onlyshowpaymorethanzero' and Labeltype='fixedstr');
insert into ld_desk (languagetype,labelbol,fieldlabel,Labeltype)
select 'en','onlyshowpaymorethanzero',"Only shows that the payment is more than 0.",'fixedstr' from DUAL
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='onlyshowpaymorethanzero' and Labeltype='fixedstr');
delimiter;


select usereportid into @usereportid from ld_usereport where `name` = 'SumSequence';
DELETE FROM ld_usereport where Parent_id = @usereportid and `name` in ('Contractnumber','Contractamount','THESINGNINGAMOUNTOFBILLBOARD');
delimiter;

insert into ld_desk (languagetype,labelbol,fieldlabel,Labeltype)
select 'zh','Invoiceamount1',"开票额",'fixedstr' from DUAL
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='Invoiceamount1' and Labeltype='fixedstr');
insert into ld_desk (languagetype,labelbol,fieldlabel,Labeltype)
select 'en','Invoiceamount1',"Invoice amount",'fixedstr' from DUAL
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='Invoiceamount1' and Labeltype='fixedstr');
delimiter;

insert into ld_desk (languagetype,labelbol,fieldlabel,Labeltype)
select 'zh','outamount',"出库额",'fixedstr' from DUAL
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='outamount' and Labeltype='fixedstr');
insert into ld_desk (languagetype,labelbol,fieldlabel,Labeltype)
select 'en','outamount',"OutboundOrder amount",'fixedstr' from DUAL
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='outamount' and Labeltype='fixedstr');
delimiter;

CALL AddColumn('ld_salestarget','invoiceamount','decimal','25,2',0);
CALL AddColumn('ld_salestarget','outboundorderamount','decimal','25,2',0);
delimiter;
-- 2018-09-28

update ld_relatedlists set  type='seproductsrel_datacategory_sql',related_coltable='seproductsrel.crmid',actions='select' where name='get_products' and tabid=18;
call AddColumn('ld_workreport','workplan_tuesday','text',NULL,NULL);
call AddColumn('ld_workreport','workplan_wednesday','text',NULL,NULL);
call AddColumn('ld_workreport','workplan_thursday','text',NULL,NULL);
call AddColumn('ld_workreport','workplan_friday','text',NULL,NULL);

select max(id) into @max_id from ld_workreport_field;
update ld_workreport_field set label = '下周一工作计划' where entitytype = 'workreport' and `name` = 'workplan' and type = 2;
select sequence into @sequence from ld_workreport_field where entitytype = 'workreport' and `name` = 'workplan' and type = 2;
update ld_workreport_field set sequence = sequence + 1000 where entitytype = 'workreport' and type = 2 and `name` = 'workexperience';
insert into ld_workreport_field(id,`name`,label,entitytype,type,defaultvalue,defaultheight,is_mandatory,is_activate,deleted,sequence,tablename)
select @max_id+1,'workplan_tuesday','下周二工作计划','workreport',2,NULL,50,1,0,0,@sequence+1,'ld_workreport' from DUAL
where not exists(select 1 from ld_workreport_field where `name` = 'workplan_tuesday' and type = 2);
insert into ld_workreport_field(id,`name`,label,entitytype,type,defaultvalue,defaultheight,is_mandatory,is_activate,deleted,sequence,tablename)
select @max_id+2,'workplan_wednesday','下周三工作计划','workreport',2,NULL,50,1,0,0,@sequence+2,'ld_workreport' from DUAL
where not exists(select 1 from ld_workreport_field where `name` = 'workplan_wednesday' and type = 2);
insert into ld_workreport_field(id,`name`,label,entitytype,type,defaultvalue,defaultheight,is_mandatory,is_activate,deleted,sequence,tablename)
select @max_id+3,'workplan_thursday','下周四工作计划','workreport',2,NULL,50,1,0,0,@sequence+3,'ld_workreport' from DUAL
where not exists(select 1 from ld_workreport_field where `name` = 'workplan_thursday' and type = 2);
insert into ld_workreport_field(id,`name`,label,entitytype,type,defaultvalue,defaultheight,is_mandatory,is_activate,deleted,sequence,tablename)
select @max_id+4,'workplan_friday','下周五工作计划','workreport',2,NULL,50,1,0,0,@sequence+4,'ld_workreport' from DUAL
where not exists(select 1 from ld_workreport_field where `name` = 'workplan_friday' and type = 2);
update ld_workreport_field set label = '本周没有按照计划完成的工作内容及原因说明。' where entitytype = 'workreport' and `name` = 'workexperience' and type = 2;
set @i=0;
update ld_workreport_field set sequence=(@i:=@i+1) where type = 2 order by Sequence;
delimiter;

select usereportid into @usereportid from ld_usereport where `name` = 'SalesSumSequence';
insert into ld_usereportcolumns(Usereportid,`columns`,Sequence,columnshow,realcolumns,realencolumns)
select @usereportid,'ld_invoice:invoicetotal:invoicetotal:OftenUseReport_invoicetotal:N',2000,1,'ld_invoice:invoicetotal:invoicetotal:OftenUseReport_销售发票金额:N','ld_invoice:invoicetotal:invoicetotal:OftenUseReport_Invoicetotal:N' from DUAL
where not exists(select 1 from ld_usereportcolumns where `columns` = 'ld_invoice:invoicetotal:invoicetotal:OftenUseReport_invoicetotal:N' and Usereportid = @usereportid);
set @i=0;
update ld_usereportcolumns set Sequence=(@i:=@i+1) where Usereportid = @usereportid order by Sequence;
delimiter;

select usereportid into @usereportid from ld_usereport where `name` = 'SalesSumSequence';
insert into ld_usereportcolumns(Usereportid,`columns`,Sequence,columnshow,realcolumns,realencolumns)
select @usereportid,'ld_outboundorder:outboundordertotal:outboundordertotal:OftenUseReport_outboundordertotal:N',3000,1,'ld_outboundorder:outboundordertotal:outboundordertotal:OftenUseReport_出库单金额:N','ld_outboundorder:outboundordertotal:outboundordertotal:OftenUseReport_Outboundordertotal:N' from DUAL
where not exists(select 1 from ld_usereportcolumns where `columns` = 'ld_outboundorder:outboundordertotal:outboundordertotal:OftenUseReport_outboundordertotal:N' and Usereportid = @usereportid);
set @i=0;
update ld_usereportcolumns set Sequence=(@i:=@i+1) where Usereportid = @usereportid order by Sequence;
delimiter;

update ld_desk set fieldlabel='覆盖方式会更新系统原有的数据，但是不会更新关联单据产品分录的信息，请慎用！' 
where labelbol='coveragemethodwillupdate' and languagetype='zh' and Labeltype='fixedstr';
update ld_desk set fieldlabel='Coverage method will update the original data of the system, but will not update the information related to the product catalog of documents, please use caution！' 
where labelbol='coveragemethodwillupdate' and languagetype='en' and Labeltype='fixedstr';

delimiter;

select tabid into @tabid from ld_tab where `name` = 'ContactRecords';
update ld_field set displaytype = 3 where tabid = @tabid and columnname = 'location_address';
delimiter;
-- 2018-09-29

call AddColumn('ld_singin','entityaddress','varchar','255',null);
delimiter;

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

update ld_version set old_version='V7.5.3',current_version='V7.5.3',remark='V7.5.3-20180929',wx_version='V7.5.3';
delimiter;