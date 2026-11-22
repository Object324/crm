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

DROP PROCEDURE IF EXISTS `fieldintoprofile`;
delimiter ||
CREATE  PROCEDURE `fieldintoprofile`(
	profileid int(19),
	tabname varchar(50)
)
begin
    declare done  int  default 0;
	declare ttabid  int ;
	declare ffieldid int ;
	declare cur2 CURSOR FOR SELECT fieldid,tabid   FROM  ld_field where tabid in(select tabid from ld_tab where name=tabname);
	declare continue handler  for not   found  SET done =1;

	OPEN cur2;
	Fetch cur2 into ffieldid,ttabid;

 	loop1: while  done<>1 DO
		set @sql=Concat('insert into ld_profile2field(profileid,tabid,fieldid,visible,readonly) select ',profileid,',',ttabid,',',ffieldid,',',0,',',0 ,' from dual where not exists(select 1 from ld_profile2field where fieldid=',ffieldid,' and profileid=',profileid,')');

		prepare stmt from @sql;
	      execute stmt;
	      deallocate  prepare  stmt;
		Fetch cur2 into ffieldid,ttabid;
	end while loop1;
	close cur2;

end ||
delimiter;

DROP PROCEDURE IF EXISTS `getallprofile`;
delimiter ||
CREATE  PROCEDURE `getallprofile`(

 tabname varchar(50)
)
begin

	declare done  int  default 0;
	declare pdone int default 0;
	declare ttabid  int ;
	declare ffieldid int ;
	declare pprofileid int;

	declare cur2 CURSOR FOR SELECT profileid   FROM  ld_profile;
	declare continue handler  for not   found  SET done =1;

	open cur2;
	fetch cur2 into pprofileid;
	loop2: while  done<>1 DO

		call fieldintoprofile(pprofileid,tabname);
		fetch cur2 into pprofileid;
	end while loop2;
	close cur2;
end ||
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','ALLSELECT','全选','jspop' from dual
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='ALLSELECT' and labeltype='jspop');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','ALLSELECT',"Select all",'jspop' from dual
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='ALLSELECT' and labeltype='jspop');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','SELECTTHESELECTEDPERMISSIONS','选择所选权限','jspop' from dual
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='SELECTTHESELECTEDPERMISSIONS' and labeltype='jspop');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','SELECTTHESELECTEDPERMISSIONS',"Select the selected permissions",'jspop' from dual
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='SELECTTHESELECTEDPERMISSIONS' and labeltype='jspop');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','CLOSE','关闭','jspop' from dual
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='CLOSE' and labeltype='jspop');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','CLOSE',"Close",'jspop' from dual
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='CLOSE' and labeltype='jspop');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','AddApprover','添加审批人','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='AddApprover' and labeltype='fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','AddApprover',"Add approver",'fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='AddApprover' and labeltype='fixedstr');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','AddApprover','添加审批人','jspop' from dual
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='AddApprover' and labeltype='jspop');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','AddApprover',"Add approver",'jspop' from dual
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='AddApprover' and labeltype='jspop');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','APPROVALSTEP','审批步骤','jspop' from dual
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='APPROVALSTEP' and labeltype='jspop');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','APPROVALSTEP',"Approval step",'jspop' from dual
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='APPROVALSTEP' and labeltype='jspop');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','menuOthertab','其他','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='menuOthertab' and labeltype='fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','menuOthertab',"Others",'fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='menuOthertab' and labeltype='fixedstr');
delimiter;

update ld_desk set fieldlabel='Permissions' where languagetype='en' and labelbol='SELECTTHESELECTEDPERMISSIONS' and labeltype='jspop';
delimiter;
-- 2022-02-24

CREATE TABLE  if not EXISTS `ld_upgrade_external_userid` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `contactid` int(11) DEFAULT NULL,
  `upgrade` varchar(20) DEFAULT NULL,
  `upgradedatetime` datetime DEFAULT NULL,
  `external_userid` varchar(100) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `upgrade` (`upgrade`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
delimiter;


ALTER TABLE ld_contactdetails MODIFY COLUMN unionid VARCHAR(255);
ALTER TABLE ld_wechatuser MODIFY COLUMN unionid VARCHAR(255);
ALTER TABLE ld_wechatuser MODIFY COLUMN open_id VARCHAR(255);
CALL addtableIndex('ld_contactdetails','unionid','unionid');
CALL addtableIndex('ld_wechatuser','unionid','unionid');
CALL addtableIndex('ld_wechatuser_sign','sign_date','sign_date');
CALL addtableIndex('ld_wechatuser_sign','channelcode_id','channelcode_id');
delimiter;


call AddColumn('ld_account','recharge_amount','decimal','25,6','0');
call AddColumn('ld_account','order_amount','decimal','25,6','0');
call AddColumn('ld_account','balance_amount','decimal','25,6','0');

SET @modulename='Accounts';
SET @tabid=(SELECT tabid FROM ld_tab WHERE `name`=@modulename);
SET @relateid=(select block from ld_field where columnname = 'account_no' and tabid = @tabid);
SET @maxseq=IFNULL((SELECT MAX(sequence) FROM ld_field WHERE tabid=@tabid AND block=@relateid),0);
SET @trantable='ld_field';
SET @tablename=(SELECT tablename FROM ld_field WHERE tabid=@tabid AND columnname='smownerid' LIMIT 1);
SET @columnname='recharge_amount';
SET @fieldname='recharge_amount';
SET @zh='累计充值金额';
SET @en='Cumulative recharge amount';
SET @uitype=72;
SET @typeofdata='N~O';
SET @quickcreate=0;
SET @displaytype=1;
SET @bigtype='currency';
SET @datarang=NULL;
SET @maxrowsshow=0;
SET @savedatabase = 'yes';
SET @allowedit = 'yes';
SET @maxid=(SELECT MAX(fieldid) FROM ld_field);
INSERT INTO ld_field(tabid,fieldid,columnname,tablename,generatedtype,uitype,fieldname,fieldlabel,readonly,presence,defaultvalue,maximumlength,sequence,block,displaytype,typeofdata,quickcreate,quickcreatesequence,info_type,masseditable,helpinfo,fieldonly,approve_demand,is_checkimportfield,bigtype,datarang,maxrowsshow,savedatabase,allowedit)
SELECT @tabid,@maxid+1,@columnname,@tablename,1,@uitype,@fieldname,@zh,0,1,NULL,100,@maxseq+1,@relateid,@displaytype,@typeofdata,@quickcreate,NULL,'BAS',1,NULL,0,2,0,@bigtype,@datarang,@maxrowsshow,@savedatabase,@allowedit from dual
WHERE NOT EXISTS (SELECT 1 FROM ld_field WHERE tabid=@tabid AND tablename=@tablename AND columnname=@columnname);
UPDATE ld_field_seq SET id=(SELECT max(fieldid) FROM ld_field);

SET @relateid=(SELECT fieldid FROM ld_field WHERE tabid=@tabid AND columnname=@columnname LIMIT 1);
INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
SELECT 'zh',@trantable,@tabid,@relateid,@zh FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE languagetype = 'zh' AND trantable =@trantable AND tabid = @tabid AND relateid=@relateid);
INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
SELECT 'en',@trantable,@tabid,@relateid,@en FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE languagetype = 'en' AND trantable =@trantable AND tabid = @tabid AND relateid=@relateid);


SET @modulename='Accounts';
SET @tabid=(SELECT tabid FROM ld_tab WHERE `name`=@modulename);
SET @relateid=(select block from ld_field where columnname = 'account_no' and tabid = @tabid);
SET @maxseq=IFNULL((SELECT MAX(sequence) FROM ld_field WHERE tabid=@tabid AND block=@relateid),0);
SET @trantable='ld_field';
SET @tablename=(SELECT tablename FROM ld_field WHERE tabid=@tabid AND columnname='smownerid' LIMIT 1);
SET @columnname='order_amount';
SET @fieldname='order_amount';
SET @zh='累计订货金额';
SET @en='Cumulative order amount';
SET @uitype=72;
SET @typeofdata='N~O';
SET @quickcreate=0;
SET @displaytype=1;
SET @bigtype='currency';
SET @datarang=NULL;
SET @maxrowsshow=0;
SET @savedatabase = 'yes';
SET @allowedit = 'yes';
SET @maxid=(SELECT MAX(fieldid) FROM ld_field);
INSERT INTO ld_field(tabid,fieldid,columnname,tablename,generatedtype,uitype,fieldname,fieldlabel,readonly,presence,defaultvalue,maximumlength,sequence,block,displaytype,typeofdata,quickcreate,quickcreatesequence,info_type,masseditable,helpinfo,fieldonly,approve_demand,is_checkimportfield,bigtype,datarang,maxrowsshow,savedatabase,allowedit)
SELECT @tabid,@maxid+1,@columnname,@tablename,1,@uitype,@fieldname,@zh,0,1,NULL,100,@maxseq+1,@relateid,@displaytype,@typeofdata,@quickcreate,NULL,'BAS',1,NULL,0,2,0,@bigtype,@datarang,@maxrowsshow,@savedatabase,@allowedit from dual
WHERE NOT EXISTS (SELECT 1 FROM ld_field WHERE tabid=@tabid AND tablename=@tablename AND columnname=@columnname);
UPDATE ld_field_seq SET id=(SELECT max(fieldid) FROM ld_field);

SET @relateid=(SELECT fieldid FROM ld_field WHERE tabid=@tabid AND columnname=@columnname LIMIT 1);
INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
SELECT 'zh',@trantable,@tabid,@relateid,@zh FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE languagetype = 'zh' AND trantable =@trantable AND tabid = @tabid AND relateid=@relateid);
INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
SELECT 'en',@trantable,@tabid,@relateid,@en FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE languagetype = 'en' AND trantable =@trantable AND tabid = @tabid AND relateid=@relateid);

SET @modulename='Accounts';
SET @tabid=(SELECT tabid FROM ld_tab WHERE `name`=@modulename);
SET @relateid=(select block from ld_field where columnname = 'account_no' and tabid = @tabid);
SET @maxseq=IFNULL((SELECT MAX(sequence) FROM ld_field WHERE tabid=@tabid AND block=@relateid),0);
SET @trantable='ld_field';
SET @tablename=(SELECT tablename FROM ld_field WHERE tabid=@tabid AND columnname='smownerid' LIMIT 1);
SET @columnname='balance_amount';
SET @fieldname='balance_amount';
SET @zh='充值余额';
SET @en='Recharge balance';
SET @uitype=72;
SET @typeofdata='N~O';
SET @quickcreate=0;
SET @displaytype=1;
SET @bigtype='currency';
SET @datarang=NULL;
SET @maxrowsshow=0;
SET @savedatabase = 'yes';
SET @allowedit = 'yes';
SET @maxid=(SELECT MAX(fieldid) FROM ld_field);
INSERT INTO ld_field(tabid,fieldid,columnname,tablename,generatedtype,uitype,fieldname,fieldlabel,readonly,presence,defaultvalue,maximumlength,sequence,block,displaytype,typeofdata,quickcreate,quickcreatesequence,info_type,masseditable,helpinfo,fieldonly,approve_demand,is_checkimportfield,bigtype,datarang,maxrowsshow,savedatabase,allowedit)
SELECT @tabid,@maxid+1,@columnname,@tablename,1,@uitype,@fieldname,@zh,0,1,NULL,100,@maxseq+1,@relateid,@displaytype,@typeofdata,@quickcreate,NULL,'BAS',1,NULL,0,2,0,@bigtype,@datarang,@maxrowsshow,@savedatabase,@allowedit from dual
WHERE NOT EXISTS (SELECT 1 FROM ld_field WHERE tabid=@tabid AND tablename=@tablename AND columnname=@columnname);
UPDATE ld_field_seq SET id=(SELECT max(fieldid) FROM ld_field);

SET @relateid=(SELECT fieldid FROM ld_field WHERE tabid=@tabid AND columnname=@columnname LIMIT 1);
INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
SELECT 'zh',@trantable,@tabid,@relateid,@zh FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE languagetype = 'zh' AND trantable =@trantable AND tabid = @tabid AND relateid=@relateid);
INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
SELECT 'en',@trantable,@tabid,@relateid,@en FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE languagetype = 'en' AND trantable =@trantable AND tabid = @tabid AND relateid=@relateid);
delimiter;

DROP TABLE if EXISTS `ld_shop_tempordercash`;
CREATE TABLE IF NOT EXISTS `ld_shop_tempordercash` (
    `salesorder_no` varchar(255) PRIMARY KEY,
    `cashbillid` int(19),
    `cashamount` decimal(19,2),
    `createdtime` Datetime
)ENGINE=InnoDB DEFAULT CHARSET=utf8;
delimiter;

call AddColumn('ld_salesorder','kis_log','text','','');
delimiter;
-- 2022-02-27

SET @tabid=(SELECT tabid FROM ld_tab WHERE `name`='ServiceCharge');
SET @relateid=(SELECT block FROM ld_field WHERE tabid=@tabid AND columnname='smownerid' LIMIT 1);
SET @maxseq=IFNULL((SELECT MAX(sequence) FROM ld_field WHERE tabid=@tabid AND block=@relateid),0);
SET @trantable='ld_account';
SET @tablename=(SELECT tablename FROM ld_field WHERE tabid=@tabid AND columnname='smownerid' LIMIT 1);
SET @columnname='service_representative'; 
SET @fieldname='service_representative'; 
SET @zh='服务代表'; 
SET @en='Service Representative'; 
SET @uitype=153;
SET @typeofdata='V~0';
SET @quickcreate=1;
SET @displaytype=1;
SET @datarang='all';
SET @maxrowsshow=10;
SET @savedatabase = 'YES';
SET @allowedit = 'YES';
SET @bigtype = 'selectoneuser';
SET @maxid=(SELECT MAX(fieldid) FROM ld_field);
INSERT INTO ld_field(tabid,fieldid,columnname,tablename,generatedtype,uitype,fieldname,fieldlabel,readonly,presence,defaultvalue,maximumlength,sequence,block,displaytype,typeofdata,quickcreate,quickcreatesequence,info_type,masseditable,helpinfo,fieldonly,approve_demand,is_checkimportfield,bigtype,datarang,maxrowsshow,savedatabase,allowedit)
SELECT @tabid,@maxid+1,@columnname,@tablename,2,@uitype,@fieldname,@zh,0,2,NULL,100,@maxseq+1,@relateid,@displaytype,@typeofdata,@quickcreate,NULL,NULL,1,NULL,0,2,0,@bigtype,@datarang,@maxrowsshow,@savedatabase,@allowedit from dual 
WHERE NOT EXISTS (SELECT 1 FROM ld_field WHERE tabid=@tabid AND tablename=@tablename AND columnname=@columnname); 
UPDATE ld_field_seq SET id=(SELECT max(fieldid) FROM ld_field);
delimiter;


SET @tabid=(SELECT tabid FROM ld_tab WHERE `name`='ServiceCharge');
SET @relateid=(SELECT fieldid FROM ld_field WHERE tabid=@tabid AND columnname='service_representative' LIMIT 1);
SET @zh_label = '服务代表';
SET @en_label = 'Service Representative';
SET @trantable = 'ld_field';
INSERT INTO ld_tranlabel(languagetype,trantable,tabid,Relateid,fieldlabel)
SELECT 'zh',@trantable,@tabid,@relateid,@zh_label FROM DUAL 
WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE tabid = @tabid AND fieldlabel=@zh_label);
INSERT INTO ld_tranlabel(languagetype,trantable,tabid,Relateid,fieldlabel)
SELECT 'en',@trantable,@tabid,@relateid,@en_label FROM DUAL 
WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE tabid = @tabid AND fieldlabel=@en_label);
delimiter;


SET @tabid=(SELECT tabid FROM ld_tab WHERE `name`='Accounts');
SET @relateid=(SELECT block FROM ld_field WHERE tabid=@tabid AND columnname='smownerid' LIMIT 1);
SET @maxseq=IFNULL((SELECT MAX(sequence) FROM ld_field WHERE tabid=@tabid AND block=@relateid),0);
SET @trantable='ld_account';
SET @tablename=(SELECT tablename FROM ld_field WHERE tabid=@tabid AND columnname='smownerid' LIMIT 1);
SET @columnname='service_representative'; 
SET @fieldname='service_representative'; 
SET @zh='服务代表'; 
SET @en='Service Representative'; 
SET @uitype=153;
SET @typeofdata='V~0';
SET @quickcreate=1;
SET @displaytype=1;
SET @datarang='all';
SET @maxrowsshow=10;
SET @savedatabase = 'YES';
SET @allowedit = 'YES';
SET @bigtype = 'selectoneuser';
SET @maxid=(SELECT MAX(fieldid) FROM ld_field);
INSERT INTO ld_field(tabid,fieldid,columnname,tablename,generatedtype,uitype,fieldname,fieldlabel,readonly,presence,defaultvalue,maximumlength,sequence,block,displaytype,typeofdata,quickcreate,quickcreatesequence,info_type,masseditable,helpinfo,fieldonly,approve_demand,is_checkimportfield,bigtype,datarang,maxrowsshow,savedatabase,allowedit)
SELECT @tabid,@maxid+1,@columnname,@tablename,2,@uitype,@fieldname,@zh,0,2,NULL,100,@maxseq+1,@relateid,@displaytype,@typeofdata,@quickcreate,NULL,NULL,1,NULL,0,2,0,@bigtype,@datarang,@maxrowsshow,@savedatabase,@allowedit from dual 
WHERE NOT EXISTS (SELECT 1 FROM ld_field WHERE tabid=@tabid AND tablename=@tablename AND columnname=@columnname); 
UPDATE ld_field_seq SET id=(SELECT max(fieldid) FROM ld_field);
delimiter;


SET @tabid=(SELECT tabid FROM ld_tab WHERE `name`='Accounts');
SET @relateid=(SELECT fieldid FROM ld_field WHERE tabid=@tabid AND columnname='service_representative' LIMIT 1);
SET @zh_label = '服务代表';
SET @en_label = 'Service Representative';
SET @trantable = 'ld_field';
INSERT INTO ld_tranlabel(languagetype,trantable,tabid,Relateid,fieldlabel)
SELECT 'zh',@trantable,@tabid,@relateid,@zh_label FROM DUAL 
WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE tabid = @tabid AND fieldlabel=@zh_label);
INSERT INTO ld_tranlabel(languagetype,trantable,tabid,Relateid,fieldlabel)
SELECT 'en',@trantable,@tabid,@relateid,@en_label FROM DUAL 
WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE tabid = @tabid AND fieldlabel=@en_label);
delimiter;


CALL AddColumn('ld_account','service_representative','varchar','255','');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','CHANGEEXISTINGDATACONTINUE','可能会改变已有数据，是否继续？','jspop' from dual
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='CHANGEEXISTINGDATACONTINUE' and labeltype='jspop');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','CHANGEEXISTINGDATACONTINUE',"May change existing data. Do you want to continue?",'jspop' from dual
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='CHANGEEXISTINGDATACONTINUE' and labeltype='jspop');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','EXPLAIN','说明','jspop' from dual
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='EXPLAIN' and labeltype='jspop');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','EXPLAIN',"Explain",'jspop' from dual
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='EXPLAIN' and labeltype='jspop');
delimiter;

SET @report_name='员工日常跟进服务统计表';
select sequence into @sequence from ld_customreport_info where report_template='oa_attendance_statistics.mrt';
update ld_customreport_info set sequence=sequence+1 where sequence>=@sequence;
SET @report_type='template_js';
SET @report_template='default_servicerecord_daily.mrt';
SET @setype='';
SET @report_describe='';
SET @report_url='';
SELECT id into @id from ld_customreport_folder where description='Tabular Data Reports';

insert into ld_customreport_info(folder_id,report_name,report_type,report_template,report_url,sequence,allocatetype,systemdefault,presence,setype,report_describe)
SELECT @id,@report_name,@report_type,@report_template,@report_url,@sequence-1,0,1,0,@setype,@report_describe from DUAL
where not exists (select 1 from ld_customreport_info where report_template=@report_template and systemdefault=1);

update ld_customreport_info set setype="ContactRecords,HelpDesk" where report_name='员工日常跟进服务统计表';
update ld_customreport_info set databaselinktype="crmlink" where report_name='员工日常跟进服务统计表';
delimiter;

SET @listid = (SELECT listid from ld_picklist_set where listname = 'status');
set @sequence = (SELECT max(sequence) from ld_picklist_values where listid = @listid);
INSERT into ld_picklist_values(listid,listvalue,sequence)
SELECT @listid,'升级到客户和销售机会',@sequence+1 from dual 
where not EXISTS(SELECT 1 from ld_picklist_values where listid = @listid and listvalue = '升级到客户和销售机会');
delimiter;

SET @labelbol = 'TRANSFERTOPOTENTIALS';
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'zh',@labelbol,'升级后将转入"{$Accounts.Accounts}"和"{$Potentials.Potentials}"模块，是否继续？','jspop' FROM DUAL 
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol=@labelbol and Labeltype='jspop');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'en',@labelbol,'After operation this record will be transferred to "{$Accounts.Accounts}" and "{$Potentials.Potentials}",continue or not?','jspop' FROM DUAL 
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol=@labelbol and Labeltype='jspop');
delimiter;

SET @labelbol = 'UPGRADETOPOTENTIALS';
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'zh',@labelbol,'升级到"{$Accounts.Accounts}"和"{$Potentials.Potentials}"','fixedstr' FROM DUAL 
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol=@labelbol and Labeltype='fixedstr');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'en',@labelbol,'Upgrade to "{$Accounts.Accounts}" and "{$Potentials.Potentials}"','fixedstr' FROM DUAL 
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol=@labelbol and Labeltype='fixedstr');
delimiter;

SET @labelbol = 'UPGRADETOACCOUNT';
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'zh',@labelbol,'升级到"{$Accounts.Accounts}"','fixedstr' FROM DUAL 
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol=@labelbol and Labeltype='fixedstr');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'en',@labelbol,'Upgrade to "{$Accounts.Accounts}"','fixedstr' FROM DUAL 
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol=@labelbol and Labeltype='fixedstr');
delimiter;


SET @tabid=(SELECT tabid FROM ld_tab WHERE `name`='Potentials');
SET @relateid=(SELECT block FROM ld_field WHERE tabid=@tabid AND columnname='smownerid' LIMIT 1);
SET @maxseq=IFNULL((SELECT MAX(sequence) FROM ld_field WHERE tabid=@tabid AND block=@relateid),0);
SET @trantable='ld_field';
SET @tablename=(SELECT tablename FROM ld_field WHERE tabid=@tabid AND columnname='smownerid' LIMIT 1);
SET @columnname='kis_no'; 
SET @fieldname='kis_no'; 
SET @zh='线索升级状态'; 
SET @en='Leads upgrade status'; 
SET @uitype=1; 
SET @typeofdata='V~O';
SET @quickcreate=1;
SET @displaytype=3;
SET @bigtype='translatefield';
SET @datarang='';
SET @maxrowsshow=0;

SET @maxid=(SELECT MAX(fieldid) FROM ld_field);
INSERT INTO ld_field(tabid,fieldid,columnname,tablename,generatedtype,uitype,fieldname,fieldlabel,readonly,presence,defaultvalue,maximumlength,sequence,block,displaytype,typeofdata,quickcreate,quickcreatesequence,info_type,masseditable,helpinfo,fieldonly,approve_demand,is_checkimportfield,bigtype,datarang,maxrowsshow)
SELECT @tabid,@maxid+1,@columnname,@tablename,1,@uitype,@fieldname,@zh,1,0,NULL,100,@maxseq+1,@relateid,@displaytype,@typeofdata,@quickcreate,NULL,NULL,1,NULL,0,2,0,@bigtype,@datarang,@maxrowsshow from dual 
WHERE NOT EXISTS (SELECT 1 FROM ld_field WHERE tabid=@tabid AND tablename=@tablename AND columnname=@columnname); 

UPDATE ld_field_seq SET id=(SELECT max(fieldid) FROM ld_field);
SET @relateid=(SELECT fieldid FROM ld_field WHERE tabid=@tabid AND columnname=@columnname LIMIT 1);

INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
SELECT 'zh',@trantable,@tabid,@relateid,@zh FROM DUAL 
WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE languagetype = 'zh' AND trantable =@trantable AND tabid = @tabid AND relateid=@relateid);

INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
SELECT 'en',@trantable,@tabid,@relateid,@en FROM DUAL 
WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE languagetype = 'en' AND trantable =@trantable AND tabid = @tabid AND relateid=@relateid);

call AddColumn(@tablename,@columnname,'varchar','100','');
delimiter;

SET @labelbol = 'LeadUgradeToPotentials';
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'zh',@labelbol,'线索升级到{$Accounts.Accounts}和{$Potentials.Potentials}数','fixedstr' FROM DUAL 
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol=@labelbol and Labeltype='fixedstr');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'en',@labelbol,'The lead upgrade to{$Accounts.Accounts} and {$Potentials.Potentials} count"','fixedstr' FROM DUAL 
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol=@labelbol and Labeltype='fixedstr');

SET @sequence = (SELECT max(sequence) from ld_homestuffdetail);
INSERT into ld_homestuffdetail(stuffid,stufflabel,stufflabeltype,compute_columns,compute_type,pageurl,sequence,cssname,presence,icon)
SELECT 35,@labelbol,'fixedstr','ld_potential.potentialid','count','index.php?pageto_module=Accounts&pageto_action=index,index.php?pageto_module=Potentials&pageto_action=index',
		@sequence,'item-ico-potentials','no','crm_Potentials.png' from dual
WHERE NOT EXISTS(SELECT 1 from ld_homestuffdetail where stufflabel = @labelbol);

set @homestuffdetailid = (SELECT id from ld_homestuffdetail where stufflabel = @labelbol);
SET @column_field = 'ld_potential:kis_no:kis_no:Potentials_fieldlabel:V';
SET @column_value = 'upgradeto_potentials';
INSERT into ld_homestuffdetailcondition(homestuffdetailid,groupid,`columns`,`value`,comparator)
SELECT @homestuffdetailid,1,@column_field,@column_value,'e' from dual
where NOT EXISTS(SELECT 1 from ld_homestuffdetailcondition where `columns`=@column_field and `value`=@column_value and homestuffdetailid=@homestuffdetailid and groupid=1);

SET @column_field = 'ld_account:kis_no:kis_no:Accounts_fieldlabel:V';
INSERT into ld_homestuffdetailcondition(homestuffdetailid,groupid,`columns`,`value`,comparator)
SELECT @homestuffdetailid,1,@column_field,@column_value,'e' from dual
where NOT EXISTS(SELECT 1 from ld_homestuffdetailcondition where `columns`=@column_field and `value`=@column_value and homestuffdetailid=@homestuffdetailid and groupid=1);

SET @column_field = 'ld_account:createdtime:createdtime:Accounts_创建时间:DT';
INSERT into ld_homestuffdetailcondition(homestuffdetailid,groupid,`columns`,`value`,comparator)
SELECT @homestuffdetailid,1,@column_field,'','' from dual
where NOT EXISTS(SELECT 1 from ld_homestuffdetailcondition where `columns`=@column_field  and homestuffdetailid=@homestuffdetailid and groupid=1);

SET @column_field = 'ld_potential:createdtime:createdtime:Potentials_创建时间:DT';
INSERT into ld_homestuffdetailcondition(homestuffdetailid,groupid,`columns`,`value`,comparator)
SELECT @homestuffdetailid,1,@column_field,'','' from dual
where NOT EXISTS(SELECT 1 from ld_homestuffdetailcondition where `columns`=@column_field  and homestuffdetailid=@homestuffdetailid and groupid=1);

SET @column_field = 'ld_account:approvestatus:approvestatus:Accounts_fieldlabel:V';
INSERT into ld_homestuffdetailcondition(homestuffdetailid,groupid,`columns`,`value`,comparator)
SELECT @homestuffdetailid,1,@column_field,'','' from dual
where NOT EXISTS(SELECT 1 from ld_homestuffdetailcondition where `columns`=@column_field  and homestuffdetailid=@homestuffdetailid and groupid=1);

SET @column_field = 'ld_potential:approvestatus:approvestatus:Potentials_fieldlabel:V';
INSERT into ld_homestuffdetailcondition(homestuffdetailid,groupid,`columns`,`value`,comparator)
SELECT @homestuffdetailid,1,@column_field,'','' from dual
where NOT EXISTS(SELECT 1 from ld_homestuffdetailcondition where `columns`=@column_field  and homestuffdetailid=@homestuffdetailid and groupid=1);
delimiter;

set @homestuffdetailid = (SELECT id from ld_homestuffdetail where stufflabel = 'LeadUgradeToCustomerCount');
SET @column_field = 'ld_account:kis_no:kis_no:Accounts_fieldlabel:V';
set @column_value = 'upgradeto_potentials';
INSERT into ld_homestuffdetailcondition(homestuffdetailid,groupid,`columns`,`value`,comparator)
SELECT @homestuffdetailid,2,@column_field,@column_value,'e' from dual
where NOT EXISTS(SELECT 1 from ld_homestuffdetailcondition where `columns`=@column_field and `value`=@column_value and homestuffdetailid=@homestuffdetailid and groupid=2);

SET @column_field = 'ld_account:approvestatus:approvestatus:Accounts_fieldlabel:V';
INSERT into ld_homestuffdetailcondition(homestuffdetailid,groupid,`columns`,`value`,comparator)
SELECT @homestuffdetailid,2,@column_field,'','' from dual
where NOT EXISTS(SELECT 1 from ld_homestuffdetailcondition where `columns`=@column_field and homestuffdetailid=@homestuffdetailid and groupid=2);

SET @column_field = 'ld_account:createdtime:createdtime:Accounts_创建时间:DT';
INSERT into ld_homestuffdetailcondition(homestuffdetailid,groupid,`columns`,`value`,comparator)
SELECT @homestuffdetailid,2,@column_field,'','' from dual
where NOT EXISTS(SELECT 1 from ld_homestuffdetailcondition where `columns`=@column_field  and homestuffdetailid=@homestuffdetailid and groupid=2);
delimiter;

insert into ld_translatefield(columnname,column_Dbvalue,module,labelbol)
select 'kis_no','upgradeto_potentials','Accounts','UPGRADETOPOTENTIALS' from dual
where not exists(select 1 from ld_translatefield where columnname='kis_no' and column_Dbvalue='upgradeto_potentials' and module='Accounts');
delimiter;

insert into ld_translatefield(columnname,column_Dbvalue,module,labelbol)
select 'kis_no','upgradeto_potentials','Potentials','UPGRADETOPOTENTIALS' from dual
where not exists(select 1 from ld_translatefield where columnname='kis_no' and column_Dbvalue='upgradeto_potentials' and module='Potentials');
delimiter;

update ld_translatefield SET labelbol = 'UPGRADETOACCOUNT' where column_Dbvalue = 'from_leads' and module ='Accounts';
delimiter;

SET @tabid = (SELECT tabid from ld_tab where `name` = 'Accounts');
SET @relatedid = (SELECT fieldid from ld_field where tabid = @tabid and columnname = 'kis_no');
UPDATE ld_tranlabel set fieldlabel = '线索升级状态' 
where tabid = @tabid and trantable = 'ld_field' and Relateid = @relatedid AND languagetype = 'zh' and fieldlabel = '是否来源销售线索';
UPDATE ld_tranlabel set fieldlabel = 'Leads upgrade status' 
where tabid = @tabid and trantable = 'ld_field' and Relateid = @relatedid AND languagetype = 'zh' and fieldlabel = '是否来源销售线索';
delimiter;

UPDATE ld_blocks SET visible=0 WHERE blocklabel='LBL_LABEL';
UPDATE ld_blocks SET display_status=2 WHERE blocklabel='LBL_LABEL' AND tabid NOT IN (6,4,102) AND NOT EXISTS (SELECT 1 FROM ld_module_tag);
delimiter;

SET @tabid = (SELECT tabid from ld_tab where `name` = 'PaymentPlan');
UPDATE ld_field SET defaultvalue = '未收' where tabid = @tabid AND columnname = 'paymentstatus';
delimiter;

UPDATE ld_desk SET fieldlabel = '提交审批后是否允许编辑' where labelbol = 'ALLOWVIEWINGAPPROVE' and languagetype = 'zh';
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','recyclingscheme','回收方案','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='recyclingscheme' and labeltype='fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','recyclingscheme',"Recycling scheme",'fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='recyclingscheme' and labeltype='fixedstr');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','recoveryconditions','回收条件','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='recoveryconditions' and labeltype='fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','recoveryconditions',"Recycling conditions",'fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='recoveryconditions' and labeltype='fixedstr');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','recyclingrules','回收规则','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='recyclingrules' and labeltype='fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','recyclingrules',"Recycling rules",'fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='recyclingrules' and labeltype='fixedstr');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','createecyclingscheme','回收至公海','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='createecyclingscheme' and labeltype='fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','createecyclingscheme',"Create RecyclingScheme",'fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='createecyclingscheme' and labeltype='fixedstr');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','rulecomments','规则备注','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='rulecomments' and labeltype='fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','rulecomments',"Rule comments",'fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='rulecomments' and labeltype='fixedstr');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','addrulecomments','新增回收方案','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='addrulecomments' and labeltype='fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','addrulecomments',"Rule comments",'fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='addrulecomments' and labeltype='fixedstr');
delimiter;

CREATE TABLE IF NOT EXISTS `ld_account_normal` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `description` text,
  `recycleselect` text,
  `pool_id` int(11) DEFAULT NULL,
  `advfilter` text,
  `advfilter_grouping` text,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=utf8;
delimiter;

CREATE TABLE IF NOT EXISTS `ld_account_set_rule_normal` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `normal_id` int(11) DEFAULT NULL,
  `tabname` varchar(50) DEFAULT NULL,
  `condition` varchar(20) DEFAULT NULL,
  `labelbol` varchar(100) DEFAULT NULL,
  `sequence` int(10) DEFAULT NULL,
  `days` int(10) DEFAULT NULL,
  `status` varchar(50) DEFAULT NULL,
  `columnname` varchar(50) DEFAULT NULL,
  `otherwhere` varchar(100) DEFAULT NULL,
  `iscycle` varchar(100) DEFAULT NULL,
  `singlelabelbol` varchar(100) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=utf8;

select count(1) into @cnt from ld_account_normal;
select CASE WHEN account_rule_pool_id >= 1 then account_rule_pool_id else 1 end into @account_rule_pool_id from ld_account_public;
select CONCAT('[',GROUP_CONCAT(CONCAT('{"groupid":"',groupid,'","columnname":"',columnname,'","comparator":"',comparator,'","value":"',`value`,'","columncondition":"',column_condition,'"}')),']') into @advfilter from ld_account_set_advfilter where pool_id = -1;
select CONCAT('[null,',GROUP_CONCAT(CONCAT('{"groupcondition":"',group_condition,'"}')),']') into @advfilter_grouping from ld_account_set_advfilter_grouping where pool_id = -1 ORDER BY condition_expression asc;
insert into ld_account_normal(recycleselect,pool_id,advfilter,advfilter_grouping)
select recycleselect,@account_rule_pool_id,@advfilter,@advfilter_grouping from ld_account_public where @cnt = 0;
delimiter;

select count(1) into @cnt from ld_account_set_rule_normal;
insert into ld_account_set_rule_normal(normal_id,tabname,`condition`,labelbol,sequence,days,`status`,columnname,otherwhere,iscycle,singlelabelbol)
select 1,tabname,`condition`,labelbol,sequence,days,`status`,columnname,otherwhere,iscycle,singlelabelbol from ld_account_set_rule where type = 'normal' and @cnt = 0;
delimiter;

DROP PROCEDURE IF EXISTS `account_singlerecycle_normal`;
delimiter ||
CREATE  PROCEDURE `account_singlerecycle_normal`()
BEGIN

	DECLARE normal_id int(11);
	DECLARE var_pool_id int(11);
	declare done  int  default 0;
	declare cur1 CURSOR FOR select id,pool_id from ld_account_normal;
	declare continue handler  for not   found  SET done =1;
		OPEN cur1;
			Fetch cur1 into normal_id,var_pool_id;
			loop1: while  done<>1 DO

				if normal_id > 0 THEN
						call account_singlerecycle_normal_rule_copy1(normal_id,var_pool_id);
						call account_singlerecycle_normal_rule_beforeremind_copy(normal_id,var_pool_id);
				end IF;

    	Fetch cur1 into normal_id,var_pool_id;
    	end while loop1;
    close cur1;

end ||
delimiter;

DROP PROCEDURE IF EXISTS `account_singlerecycle_normal_rule`;
delimiter ||
CREATE  PROCEDURE `account_singlerecycle_normal_rule`(
	new_normal_id 	int(11),
	new_pool_id 	int(11)
)
BEGIN

	DECLARE var_tabname varchar(100);
	DECLARE var_columnname varchar(100);
	DECLARE var_tablename varchar(100);
	DECLARE var_condition varchar(50);
	declare var_iscycle varchar(50);
	DECLARE var_days int(11);
	DECLARE var_otherwhere varchar(200);
	declare done  int  default 0;
  DECLARE var_smownercolumn varchar(50);
	declare cur1 CURSOR FOR select tabname,ld_account_set_rule_normal.columnname,ld_field.tablename ,
		ld_account_set_rule_normal.iscycle,`condition`,ld_account_set_rule_normal.days
		,ld_account_set_rule_normal.otherwhere from ld_account_set_rule_normal  inner join ld_tab on ld_tab.name=ld_account_set_rule_normal.tabname and (presence in(0,2) or ld_account_set_rule_normal.tabname='singin')
		INNER JOIN ld_field on ld_field.tabid=ld_tab.tabid and ld_account_set_rule_normal.columnname=ld_field.columnname
		and ld_field.presence in(0,2) where ld_account_set_rule_normal.`status`='active' and normal_id = new_normal_id;

    declare continue handler  for not   found  SET done =1;
    select userid_after_transfer into @allotaccount from ld_account_public_pool where id = new_pool_id;

    IF EXISTS (SELECT 1 FROM ld_account_public WHERE show_account_rule='yes') THEN
    	set @tmpint=0;
    	set @tmpsql='';
    	select max(ld_account_set_rule_normal.days) into @maxdays
			from ld_account_set_rule_normal  inner join ld_tab on ld_tab.name=ld_account_set_rule_normal.tabname and (presence in(0,2) or ld_account_set_rule_normal.tabname='singin')
			INNER JOIN ld_field on ld_field.tabid=ld_tab.tabid and ld_account_set_rule_normal.columnname=ld_field.columnname
			and ld_field.presence in(0,2) where ld_account_set_rule_normal.`status`='active' and normal_id = new_normal_id;

			select recycleselect into @recycleselect from ld_account_normal where id = new_normal_id;
			set @account_rule_pool_id = new_pool_id;

    	if @recycleselect is not null and @recycleselect<>'' then
    			set @recycleselect=concat( '( ', @recycleselect,' ) as recyclewheretableset ');
    	end if;
    	OPEN cur1;

    	Fetch cur1 into var_tabname,var_columnname,var_tablename,var_iscycle,var_condition,var_days,var_otherwhere;
    	loop1: while  done<>1 DO
    			if var_tablename='ld_singin' THEN
    					set var_smownercolumn='userid';
    		   else
    				set	var_smownercolumn='smownerid' ;
    			end if;
    		  if(var_condition='and' ) then

    			set @tmpsqlone =concat("select ld_account.accountid,ld_account.distributiondate,ld_account.createdtime from ld_account ");
    			set @tmpsqlone=concat(@tmpsqlone," inner join ",var_tablename,' on ',var_tablename,'.accountid=ld_account.accountid' );
    			set @tmpsqltwo=concat(@tmpsqltwo," and  ",var_tablename,'.',var_smownercolumn,'=ld_account.smownerid ');

    			 set @tmpsqlone=concat(@tmpsqlone," where   ",var_tablename,".deleted=0  ");
    		   if var_otherwhere is not null and  var_otherwhere<>'' then
    					set @tmpsqlone=concat(@tmpsqlone,var_otherwhere);
    				end if;

    		  if var_iscycle ='yes' then
    				 set @tmpsqlone=concat( @tmpsqlone,' group by ld_account.accountid ') ;
    				set @tmpsqlone=concat(@tmpsqlone,"   having    datediff(curdate(),case when   IF(IFNULL(ld_account.distributiondate,'0000-00-00')<='1600-00-00',ld_account.createdtime,ld_account.distributiondate)>    max(",var_tablename,'.',var_columnname,") then  IF(IFNULL(ld_account.distributiondate,'0000-00-00')<='1600-00-00',ld_account.createdtime,ld_account.distributiondate)  else max(",var_tablename,'.',var_columnname,") end  ) >",var_days   );
    			else
    				set @tmpsqlone=concat(@tmpsqlone," and IF(IFNULL(ld_account.distributiondate,'0000-00-00')<='1600-00-00',ld_account.createdtime,ld_account.distributiondate)<=",var_tablename,'.',var_columnname);
    				 set @tmpsqlone=concat( @tmpsqlone,' group by ld_account.accountid ') ;
    				set @tmpsqlone=concat(@tmpsqlone,"  having datediff(min( ",var_tablename,'.',var_columnname,"),IF(IFNULL(ld_account.distributiondate,'0000-00-00')<='1600-00-00',ld_account.createdtime,ld_account.distributiondate))>",var_days);

    			 end if;
          set @tmpsqltwo=concat('select ld_account.accountid,ld_account.distributiondate,ld_account.createdtime from  ld_account LEFT JOIN(select ld_account.accountid
    					from ld_account inner join ',var_tablename,' on ld_account.accountid=',var_tablename,'.accountid
    						and ld_account.smownerid=',var_tablename,'.',var_smownercolumn,'  where ',var_tablename,'.deleted=0' );

    		   if var_otherwhere is not null and  var_otherwhere<>'' then
    					set @tmpsqltwo=concat(@tmpsqltwo, var_otherwhere);
    				end if;
    			set @tmpsqltwo=concat(@tmpsqltwo,' ) 	as ttt_',var_tablename,'  on ld_account.accountid=ttt_',var_tablename,'.accountid   where ttt_',var_tablename,'.accountid is null  ' );
    			set @tmpsqltwo=concat(@tmpsqltwo," having datediff(curdate(),IF(IFNULL(ld_account.distributiondate,'0000-00-00')<='1600-00-00',ld_account.createdtime,ld_account.distributiondate) ) >",var_days);


    			set @tmpthree=concat( @tmpsqlone,' union all ',@tmpsqltwo);
    			set @tmpsql=concat(@tmpsql," select * from ( ",@tmpthree," ) as  tttt_",var_tabname);
    			set @tmpsql=concat(@tmpsql,' union all ' );

    			elseif (var_condition='or')  then
    				set @tmpsql=concat(@tmpsql ,' select ld_account.accountid,ld_account.distributiondate,ld_account.createdtime from ld_account inner join '  ,var_tablename,' on ',var_tablename,'.accountid=ld_account.accountid  ');
    			  set @tmpsql=concat(@tmpsql,' and ' ,var_tablename,'.',var_smownercolumn,'=ld_account.smownerid ' );
    				set @tmpsql=concat(@tmpsql,' where  ' , var_tablename,'.deleted=0 ' );
    				if var_otherwhere is not null and  var_otherwhere<>'' then
    					set @tmpsql=concat(@tmpsql,var_otherwhere);
    				end if;

    				if var_iscycle='yes' then
    					set @tmpsql=concat(@tmpsql," group by ld_account.accountid ");
    						set @tmpsql=concat(@tmpsql," having datediff(curdate(), case when  IF(IFNULL(ld_account.distributiondate,'0000-00-00')<='1600-00-00',ld_account.createdtime,ld_account.distributiondate)>max( ", var_tablename,'.',var_columnname,") then  IF(IFNULL(ld_account.distributiondate,'0000-00-00')<='1600-00-00',ld_account.createdtime,ld_account.distributiondate)   else  max( ", var_tablename,'.',var_columnname,") end )<= ",var_days);
    				else
    						set @tmpsqlone=concat(@tmpsql," and IF(IFNULL(ld_account.distributiondate,'0000-00-00')<='1600-00-00',ld_account.createdtime,ld_account.distributiondate)<=",var_tablename,'.',var_columnname);
    						set @tmpsql=concat(@tmpsql," group by ld_account.accountid ");
    						set @tmpsqlone=concat(@tmpsql,"  having datediff(min( ",var_tablename,'.',var_columnname,"),IF(IFNULL(ld_account.distributiondate,'0000-00-00')<='1600-00-00',ld_account.createdtime,ld_account.distributiondate))<=",var_days);
    			   end if;

    				set @tmpsql=concat(@tmpsql,' union all ' );

    			end if;
    			set @tmpint=@tmpint+1;
    			Fetch cur1 into var_tabname,var_columnname,var_tablename,var_iscycle, var_condition,var_days,var_otherwhere;
    		end while loop1;
    		close cur1;


    	if @tmpint>0 then
    		set @len=CHAR_LENGTH(' union all ');
    		set @tmpsql=left(@tmpsql,CHAR_LENGTH(@tmpsql)-@len);

    	  if var_condition='or'  then

    				set @TMPSQL_ONE=concat( ' select "系统","LOGPUBLICNORMAL",now(), ld_account.accountid,ld_account.pool_id  from ld_account left join ( ',@tmpsql,' ) as lingdangtmp  on  lingdangtmp.accountid=ld_account.accountid ') ;
    			if @recycleselect<>'' and @recycleselect is not null THEN
    				set @TMPSQL_ONE=concat(@TMPSQL_ONE,' left join ',@recycleselect,' on recyclewheretableset.accountid=ld_account.accountid ');
    		 	end if;
    			 set @TMPSQL_TWO=concat(@TMPSQL_ONE,' where ld_account.deleted=0 and( ifnull(ld_account.publicaccount,0)<1)'  );
    				set @TMPSQL_TWO=concat(@TMPSQL_TWO, " and lingdangtmp.accountid is null  and datediff(curdate(),case when ifnull(ld_account.distributiondate,'')='' then ld_account.createdtime else ld_account.distributiondate end)>",@maxdays);
    				if @recycleselect<>'' and @recycleselect is not null THEN
    					set @TMPSQL_TWO=concat(@TMPSQL_TWO, ' and recyclewheretableset.accountid is not null ');
    				end if;
    		else
    			 if @recycleselect is not null and @recycleselect<>'' then

    					set @sql=concat(' select tmpone.accountid from  (',@tmpsql, ' ) as tmpone inner join ',@recycleselect,' on tmpone.accountid=recyclewheretableset.accountid  group by tmpone.accountid ') ;
    				ELSE
    					set @sql=concat(' select accountid from (',@tmpsql, ') as tmpone group by accountid ') ;
    				end if;

    				set @TMPSQL_ONE=concat( ' select "系统","LOGPUBLICNORMAL",now(), ld_account.accountid,ld_account.pool_id  from ld_account inner join ( ',@sql,' ) as lingdangtmp  on  lingdangtmp.accountid=ld_account.accountid ') ;
    				set @TMPSQL_TWO=concat(@TMPSQL_ONE,' where ld_account.deleted=0 and( ifnull(ld_account.publicaccount,0)<1)'  );
    		 end if;

    	   set @TMPSQL_THREE=concat('insert into ld_logpublicaccount(username,operation,opdate,accountid,pool_id) ',@TMPSQL_TWO);
    		 prepare stmt from @TMPSQL_THREE;
    		 execute stmt;
    		 deallocate prepare stmt;



    		if var_condition='or'  then
    			 set @TMPSQL_ONE=concat( ' select "normal" as type, GROUP_CONCAT(accountname separator "<br>")as accountnames,count(ld_account.accountid)  as totalaccounts,ld_account.smownerid from    ld_account left join ( ',@tmpsql,' ) as lingdangtmp  on  lingdangtmp.accountid=ld_account.accountid ') ;
    		   if @recycleselect<>'' and @recycleselect is not null THEN
    				set @TMPSQL_ONE=concat(@TMPSQL_ONE,' left join ',@recycleselect,' on recyclewheretableset.accountid=ld_account.accountid ');
    		 	end if;
    			set @TMPSQL_TWO=concat(@TMPSQL_ONE,' where ld_account.deleted=0 and( ifnull(ld_account.publicaccount,0)<1)    ');
    		   set @TMPSQL_TWO=concat(@TMPSQL_TWO, " and lingdangtmp.accountid is null and datediff(curdate(),case when ifnull(ld_account.distributiondate,'')='' then ld_account.createdtime else ld_account.distributiondate end)>",@maxdays);
    			if @recycleselect<>'' and @recycleselect is not null THEN
    					set @TMPSQL_TWO=concat(@TMPSQL_TWO, ' and recyclewheretableset.accountid is not null  ');
    				end if;
    			set @TMPSQL_TWO=concat(@TMPSQL_TWO," group by ld_account.smownerid ");
    		else
    			set @TMPSQL_ONE=concat( ' select "normal" as type, GROUP_CONCAT(ld_account.accountname separator "<br>")as accountnames,count(ld_account.accountid)  as totalaccounts,ld_account.smownerid from    ld_account  inner join ( ',@sql,' ) as lingdangtmp  on  lingdangtmp.accountid=ld_account.accountid ') ;
    		   set @TMPSQL_TWO=concat(@TMPSQL_ONE,' where ld_account.deleted=0 and( ifnull(ld_account.publicaccount,0)<1) group by ld_account.smownerid    ');
    		end if;

         delete from ld_publicaccount_remindtableview ;

         set @tmpthree=concat(" insert into ld_publicaccount_remindtableview(type,names,totalaccounts,smownerid )  ", @TMPSQL_TWO);
    		prepare stmt from @tmpthree;
    		execute stmt;
    		deallocate prepare stmt;

       call crm_publicaccount_recoveryreminds();


    		if var_condition='or'  then
    			  	set @TMPSQL_ONE=concat( ' update  ld_account left join ( ',@tmpsql,' ) as lingdangtmp  on  lingdangtmp.accountid=ld_account.accountid ');

    		      if @recycleselect<>'' and @recycleselect is not null THEN
    						set @TMPSQL_ONE=concat(@TMPSQL_ONE,' left join ',@recycleselect,' on recyclewheretableset.accountid=ld_account.accountid ');
    					end if;
    				set @TMPSQL_ONE =concat(@TMPSQL_ONE,' set ld_account.publicaccount=1,ld_account.pool_id=',@account_rule_pool_id,' ,protectdate=null ,allocatedate=null') ;
							if @allotaccount>0 THEN
							set @TMPSQL_ONE=concat(@TMPSQL_ONE,",smownerid=",@allotaccount);
						end if;
    					set @TMPSQL_TWO=concat(@TMPSQL_ONE,' where ld_account.deleted=0 and( ifnull(ld_account.publicaccount,0)<1)');
    		      set @TMPSQL_TWO=concat(@TMPSQL_TWO, " and lingdangtmp.accountid is null and datediff(curdate(),case when ifnull(ld_account.distributiondate,'')='' then ld_account.createdtime else ld_account.distributiondate end)>",@maxdays);
    					if @recycleselect<>'' and @recycleselect is not null THEN
    					   set @TMPSQL_TWO=concat(@TMPSQL_TWO, ' and recyclewheretableset.accountid is not null  ');
    				  end if;

    			ELSE
    				set @TMPSQL_ONE=concat( ' update  ld_account inner join ( ',@sql,' ) as lingdangtmp  on  lingdangtmp.accountid=ld_account.accountid set ld_account.publicaccount=1,ld_account.pool_id=',@account_rule_pool_id,' ,protectdate=null ,allocatedate=null') ;
							if @allotaccount>0 THEN
								set @TMPSQL_ONE=concat(@TMPSQL_ONE,",smownerid=",@allotaccount);
						end if;

						set @TMPSQL_TWO=concat(@TMPSQL_ONE,' where ld_account.deleted=0 and( ifnull(ld_account.publicaccount,0)<1)');

    		 end if;
    		prepare stmt from @TMPSQL_TWO;
    		execute stmt;
    		deallocate prepare stmt;

    	end if;
    END IF;

end;
||
delimiter;

DROP PROCEDURE IF EXISTS `account_singlerecycle_normal_rule_beforeremind`;
delimiter ||
CREATE PROCEDURE `account_singlerecycle_normal_rule_beforeremind`(
new_normal_id 	int(11),
new_pool_id 	int(11)
)
label_a:BEGIN

	DECLARE var_tabname varchar(100);
	DECLARE var_columnname varchar(100);
	DECLARE var_tablename varchar(100);
	DECLARE var_condition varchar(50);
	DECLARE var_smownercolumn varchar(50);
	declare var_iscycle varchar(50);
	DECLARE var_days int(11);
	DECLARE var_otherwhere varchar(200);
	declare done  int  default 0;

	declare cur1 CURSOR FOR select tabname,ld_account_set_rule_normal.columnname,ld_field.tablename ,
		ld_account_set_rule_normal.iscycle,`condition`,ld_account_set_rule_normal.days
		,ld_account_set_rule_normal.otherwhere from ld_account_set_rule_normal  inner join ld_tab on ld_tab.name=ld_account_set_rule_normal.tabname and (presence in(0,2) or ld_account_set_rule_normal.tabname='singin')
		INNER JOIN ld_field on ld_field.tabid=ld_tab.tabid and ld_account_set_rule_normal.columnname=ld_field.columnname
		and ld_field.presence in(0,2) where ld_account_set_rule_normal.`status`='active' and normal_id = new_normal_id;

    declare continue handler  for not   found  SET done =1;

    IF EXISTS (SELECT 1 FROM ld_account_public WHERE show_account_rule='yes') THEN
    	set @tmpint=0;
    	set @tmpsql='';
    	select max(ld_account_set_rule_normal.days) into @maxdays
			from ld_account_set_rule_normal  inner join ld_tab on ld_tab.name=ld_account_set_rule_normal.tabname and (presence in(0,2) or ld_account_set_rule_normal.tabname='singin')
			INNER JOIN ld_field on ld_field.tabid=ld_tab.tabid and ld_account_set_rule_normal.columnname=ld_field.columnname
			and ld_field.presence in(0,2) where ld_account_set_rule_normal.`status`='active' and normal_id = new_normal_id;

    	select recycleselect into @recycleselect from ld_account_normal where id = new_normal_id;

    	select beforereminddays into @var_beforereminddays from ld_account_public_pool where id = new_pool_id;
      if @var_beforereminddays='' or @var_beforereminddays is null or @var_beforereminddays=0 then
    		leave label_a ;
    	end if;
       set @maxdays=@maxdays-@var_beforereminddays;

    	if @recycleselect is not null and @recycleselect<>'' then
    			set @recycleselect=concat( '( ', @recycleselect,' ) as recyclewheretableset ');
    	end if;
    	OPEN cur1;

    	Fetch cur1 into var_tabname,var_columnname,var_tablename,var_iscycle,var_condition,var_days,var_otherwhere;
    	loop1: while  done<>1 DO
    			if var_tablename='ld_singin' THEN
    					set var_smownercolumn='userid';
    		   else
    				set	var_smownercolumn='smownerid' ;
    			end if;
    			 set var_days=var_days-@var_beforereminddays;
    			if var_days<=0 THEN
    				leave loop1;
    		   end if;
    		  if(var_condition='and' ) then

    			set @tmpsqlone =concat("select ld_account.accountid,ld_account.distributiondate,ld_account.createdtime, '",var_tabname,"' as remindtabname from ld_account ");
    			set @tmpsqlone=concat(@tmpsqlone," inner join ",var_tablename,' on ',var_tablename,'.accountid=ld_account.accountid' );
    			set @tmpsqltwo=concat(@tmpsqltwo," and  ",var_tablename,'.',var_smownercolumn,'=ld_account.smownerid ');

    			 set @tmpsqlone=concat(@tmpsqlone," where   ",var_tablename,".deleted=0  ");
    		   if var_otherwhere is not null and  var_otherwhere<>'' then
    					set @tmpsqlone=concat(@tmpsqlone,var_otherwhere);
    				end if;

    		  if var_iscycle ='yes' then
    				 set @tmpsqlone=concat( @tmpsqlone,' group by ld_account.accountid ') ;
    				set @tmpsqlone=concat(@tmpsqlone,"   having    datediff(curdate(),case when   IF(IFNULL(ld_account.distributiondate,'0000-00-00')<='1600-00-00',ld_account.createdtime,ld_account.distributiondate)>    max(",var_tablename,'.',var_columnname,") then  IF(IFNULL(ld_account.distributiondate,'0000-00-00')<='1600-00-00',ld_account.createdtime,ld_account.distributiondate)  else max(",var_tablename,'.',var_columnname,") end  ) >",var_days   );
    			else
    				set @tmpsqlone=concat(@tmpsqlone," and IF(IFNULL(ld_account.distributiondate,'0000-00-00')<='1600-00-00',ld_account.createdtime,ld_account.distributiondate)<=",var_tablename,'.',var_columnname);
    				 set @tmpsqlone=concat( @tmpsqlone,' group by ld_account.accountid ') ;
    				set @tmpsqlone=concat(@tmpsqlone,"  having datediff(min( ",var_tablename,'.',var_columnname,"),IF(IFNULL(ld_account.distributiondate,'0000-00-00')<='1600-00-00',ld_account.createdtime,ld_account.distributiondate))>",var_days);

    			 end if;

               set @tmpsqltwo=concat("select ld_account.accountid,ld_account.distributiondate,ld_account.createdtime , '",var_tabname,"' as remindtabname from ld_account LEFT JOIN (select ld_account.accountid from ld_account inner join ",var_tablename,' on ld_account.accountid=',
                    var_tablename,'.accountid and ld_account.smownerid=',var_tablename,'.',var_smownercolumn,'  where ',var_tablename,'.deleted=0');

    		   if var_otherwhere is not null and  var_otherwhere<>'' then
    					set @tmpsqltwo=concat(@tmpsqltwo, var_otherwhere);
    				end if;
    			set @tmpsqltwo=concat(@tmpsqltwo,' ) 	as ttt_',var_tablename,'  on ld_account.accountid=ttt_',var_tablename,'.accountid   where ttt_',var_tablename,'.accountid is null  ' );
    			set @tmpsqltwo=concat(@tmpsqltwo," having datediff(curdate(),IF(IFNULL(ld_account.distributiondate,'0000-00-00')<='1600-00-00',ld_account.createdtime,ld_account.distributiondate) ) >",var_days);


    			set @tmpthree=concat( @tmpsqlone,' union all ',@tmpsqltwo);
    			set @tmpsql=concat(@tmpsql," select * from ( ",@tmpthree," ) as  tttt_",var_tabname);
    			set @tmpsql=concat(@tmpsql,' union all ' );

    			elseif (var_condition='or')  then
    				set @tmpsql=concat(@tmpsql ," select ld_account.accountid,ld_account.distributiondate,ld_account.createdtime, '",var_tabname,"' as remindtabname from ld_account inner join "  ,var_tablename,' on ',var_tablename,'.accountid=ld_account.accountid  ');
    			  set @tmpsql=concat(@tmpsql,' and ' ,var_tablename,'.',var_smownercolumn,'=ld_account.smownerid ' );
    				set @tmpsql=concat(@tmpsql,' where  ' , var_tablename,'.deleted=0 ' );
    				if var_otherwhere is not null and  var_otherwhere<>'' then
    					set @tmpsql=concat(@tmpsql,var_otherwhere);
    				end if;

    				if var_iscycle='yes' then
    					set @tmpsql=concat(@tmpsql," group by ld_account.accountid ");
    						set @tmpsql=concat(@tmpsql," having datediff(curdate(), case when  IF(IFNULL(ld_account.distributiondate,'0000-00-00')<='1600-00-00',ld_account.createdtime,ld_account.distributiondate)>max( ", var_tablename,'.',var_columnname,") then  IF(IFNULL(ld_account.distributiondate,'0000-00-00')<='1600-00-00',ld_account.createdtime,ld_account.distributiondate)   else  max( ", var_tablename,'.',var_columnname,") end )<= ",var_days);
    				else
    						set @tmpsqlone=concat(@tmpsql," and IF(IFNULL(ld_account.distributiondate,'0000-00-00')<='1600-00-00',ld_account.createdtime,ld_account.distributiondate)<=",var_tablename,'.',var_columnname);
    						set @tmpsql=concat(@tmpsql," group by ld_account.accountid ");
    						set @tmpsqlone=concat(@tmpsql,"  having datediff(min( ",var_tablename,'.',var_columnname,"),IF(IFNULL(ld_account.distributiondate,'0000-00-00')<='1600-00-00',ld_account.createdtime,ld_account.distributiondate))<=",var_days);
    			   end if;

    				set @tmpsql=concat(@tmpsql,' union all ' );

    			end if;
    			set @tmpint=@tmpint+1;
    			Fetch cur1 into var_tabname,var_columnname,var_tablename,var_iscycle, var_condition,var_days,var_otherwhere;
    		end while loop1;
    		close cur1;


    	if @tmpint>0 then
    			set @len=CHAR_LENGTH(' union all ');
    			set @tmpsql=left(@tmpsql,CHAR_LENGTH(@tmpsql)-@len);

    			if var_condition='or'  then
    				 set @TMP_TMPTable=concat(' ( select  concat("(",GROUP_CONCAT(ld_tranlabel.fieldlabel),")")  from ld_account_set_rule_normal
							INNER JOIN ld_tab on ld_tab.name=ld_account_set_rule_normal.tabname
							INNER JOIN ld_tranlabel on ld_tab.tabid=ld_tranlabel.tabid
							and ld_tab.tabid=ld_tranlabel.Relateid and languagetype="zh" and trantable="ld_tab"
							where ld_account_set_rule_normal.status="active" and normal_id = ',new_normal_id,' ORDER BY ld_account_set_rule_normal.sequence asc ) ');

    				set @sql=concat(' select accountid from (',@tmpsql, ') as tmpone group by accountid ') ;

    				set @TMPSQL_ONE=concat( ' select "normal", group_concat(concat (ld_account.accountname,',@TMP_TMPTable,') separator "<br>" )  as accouontnames ,count(distinct ld_account.accountid)  as totalaccounts,ld_account.smownerid from ld_account left join ( ',@sql,' ) as lingdangtmp  on  lingdangtmp.accountid=ld_account.accountid ') ;
    				if @recycleselect<>'' and @recycleselect is not null THEN
    					set @TMPSQL_ONE=concat(@TMPSQL_ONE,' left join ',@recycleselect,' on recyclewheretableset.accountid=ld_account.accountid ');
    				end if;
    				 set @TMPSQL_TWO=concat(@TMPSQL_ONE,' where ld_account.deleted=0 and( ifnull(ld_account.publicaccount,0)<1)');
    					set @TMPSQL_TWO=concat(@TMPSQL_TWO, " and lingdangtmp.accountid is null  and datediff(curdate(),case when ifnull(ld_account.distributiondate,'')='' then ld_account.createdtime else ld_account.distributiondate end)>",@maxdays);
    					if @recycleselect<>'' and @recycleselect is not null THEN
    						set @TMPSQL_TWO=concat(@TMPSQL_TWO, ' and recyclewheretableset.accountid is not null ');
    					end if;
    				 set @TMPSQL_TWO=concat(@TMPSQL_TWO," group by ld_account.smownerid ");
    		  else
    				if @recycleselect is not null and @recycleselect<>'' then

    					set @sql=concat(' select tmpone.accountid,GROUP_CONCAT(ld_tranlabel.fieldlabel) as fieldlabel from  (',@tmpsql, ' ) as tmpone
    												inner join ',@recycleselect,' on tmpone.accountid=recyclewheretableset.accountid
    												inner join ld_tab on ld_tab.name=tmpone.remindtabname
    										 	INNER JOIN ld_tranlabel on ld_tab.tabid=ld_tranlabel.tabid
    										  and ld_tab.tabid=ld_tranlabel.Relateid and languagetype="zh" and trantable="ld_tab"
    											 group by accountid ') ;
    				ELSE
    					set @sql=concat(' select accountid,GROUP_CONCAT(ld_tranlabel.fieldlabel) as fieldlabel from (',@tmpsql, ') as tmpone
    											inner join ld_tab on ld_tab.name=tmpone.remindtabname
    											INNER JOIN ld_tranlabel on ld_tab.tabid=ld_tranlabel.tabid
    										  and ld_tab.tabid=ld_tranlabel.Relateid and languagetype="zh" and trantable="ld_tab"
    											 group by accountid') ;
    				end if;

    				set @TMPSQL_ONE=concat( ' select "normal",  GROUP_CONCAT(concat(ld_account.accountname,"(",lingdangtmp.fieldlabel,")") separator "<br>")as accountnames,count(distinct ld_account.accountid)  as totalaccounts,ld_account.smownerid from    ld_account  inner join ( ',@sql,' ) as lingdangtmp  on  lingdangtmp.accountid=ld_account.accountid ') ;
    				set @TMPSQL_TWO=concat(@TMPSQL_ONE,' where ld_account.deleted=0 and( ifnull(ld_account.publicaccount,0)<1) group by ld_account.smownerid'  );
    			end if;

    	 	delete from ld_publicaccount_remindtableview ;
    		 set @tmpthree=concat(" insert into ld_publicaccount_remindtableview(type,names,totalaccounts,smownerid )  ", @TMPSQL_TWO);
    			prepare stmt from @tmpthree;
    			execute stmt;
    			deallocate prepare stmt;

    			call crm_publicaccount_beforereminds();
    	 end if;
    END IF;

end ||
delimiter;

DROP PROCEDURE IF EXISTS `execute_account_publicoperation`;
delimiter ||
CREATE PROCEDURE `execute_account_publicoperation`()
BEGIN
	declare done  int  default 0;
	DECLARE tmp_pool_id varchar(200);
	declare cur1 CURSOR FOR SELECT id  FROM  ld_account_public_pool where deleted = 0;
	declare continue handler  for not   found  SET done =1;
	if  EXISTS (SELECT 1 FROM ld_account_public WHERE STATUS = 'yes')  THEN
		if NOT EXISTS (SELECT 1 FROM ld_sys_event WHERE eventdate>CURDATE() AND type='publicaccount')  THEN
			UPDATE ld_sys_event SET eventdate=NOW() WHERE type='publicaccount';
			call account_singlerecycle_normal();
			OPEN cur1;
				Fetch cur1 into tmp_pool_id;
					loop1: while  done<>1 DO
						call account_singlerecycle_highsea_rule(tmp_pool_id);
						call account_singlerecycle_highsea_rule_beforeremind(tmp_pool_id);
				Fetch cur1 into tmp_pool_id;
			end while loop1;
			close cur1;
		end if;
	end if;
end ||
delimiter;

update ld_account_normal set description = '' where description is NULL;
delimiter;

drop PROCEDURE if exists `addReferenceUitypmodule`;
delimiter ||
create PROCEDURE `addReferenceUitypmodule`(
  referenceuitype varchar(100)
)
begin
 set @sql=concat('select ld_ws_fieldtype.uitype into @uitype from ld_ws_fieldtype LEFT JOIN ld_ws_referencetype on ld_ws_referencetype.fieldtypeid=ld_ws_fieldtype.fieldtypeid
				where type="',referenceuitype,'"' );
		prepare stmt from @sql;
		execute stmt;
		deallocate prepare stmt;
if ifnull(@uitype,'')='' then
		select max(uitype+0) into @maxuitype from ld_ws_fieldtype;
		if @maxuitype<2000  then

					set @maxuitype=2000;

			 else

					set @maxuitype=@maxuitype+1;
		end if;

		 set @sql=concat('insert into ld_ws_fieldtype(uitype,fieldtype)value("',@maxuitype,'","reference")');
		 prepare stmta from @sql;
		 execute stmta;
		deallocate prepare stmta;
		set @sql=concat('select fieldtypeid  into @lastid from ld_ws_fieldtype where uitype ="',@maxuitype,'"');
		prepare stmt1 from @sql;
		execute stmt1;
		deallocate prepare stmt1;

		set @sql=concat('insert into ld_ws_referencetype(fieldtypeid,type)value("',@lastid,'","',referenceuitype,'")');
		prepare stmt2 from @sql;
		execute stmt2;
		deallocate prepare stmt2;
end if;
end ||
delimiter;
call addReferenceUitypmodule('CustomForm14');
DROP PROCEDURE IF EXISTS `addReferenceUitypmodule`;

DROP PROCEDURE IF EXISTS `ldcrm_addnewmoudule_BudgetChange`;
delimiter ||
CREATE  PROCEDURE `ldcrm_addnewmoudule_BudgetChange`(
	tmp_modulename VARCHAR(100),
	tmp_zhmoudulename VARCHAR(100),
	tmp_enmoudulename VARCHAR(100),
	tmp_deploy_type INT(19)
)
BEGIN
	-- begin 新增模块
	SET @maxtabid=(SELECT MAX(tabid) FROM ld_tab);
	SET @tabsequence=(SELECT tabsequence FROM ld_tab WHERE `name`='QuotesChange' LIMIT 1);
	INSERT INTO ld_tab(tabid,`name`,presence,tabsequence,tablabel,printtab,description)
	SELECT @maxtabid+1,tmp_modulename,0,@tabsequence,tmp_modulename,0,'' FROM DUAL
	WHERE NOT EXISTS (SELECT 1 FROM ld_tab WHERE `name`=tmp_modulename);
	SET @i=0;
	UPDATE ld_tab SET tabsequence=(@i:=@i+1) ORDER BY tabsequence;

	SET @tabid=(SELECT tabid FROM ld_tab WHERE `name`=tmp_modulename);
	INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
	SELECT 'zh','ld_tab',@tabid,@tabid,tmp_zhmoudulename FROM DUAL
	WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE tabid=@tabid AND relateid=@tabid AND languagetype='zh' AND trantable='ld_tab');
	INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
	SELECT 'en','ld_tab',@tabid,@tabid,tmp_enmoudulename FROM DUAL
	WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE tabid=@tabid AND relateid=@tabid AND languagetype='en' AND trantable='ld_tab');

	-- 单据编号
	SET @maxnum_id=(SELECT MAX(num_id) FROM ld_modentity_num);
	INSERT INTO ld_modentity_num(num_id,semodule,prefix,start_id,cur_id,active,datetype,useuseraccount,isallow,prefixtype)
	SELECT @maxnum_id+1,tmp_modulename,'BUC',1,1,1,'none',0,0,0 FROM DUAL
	WHERE NOT EXISTS(SELECT 1 FROM ld_modentity_num WHERE semodule=tmp_modulename);
	UPDATE ld_modentity_num_seq SET id=@maxnum_id+1;

	INSERT INTO ld_modtracker_tabs(tabid,visible)
	SELECT @tabid,1 FROM DUAL
	WHERE NOT EXISTS (SELECT 1 FROM ld_modtracker_tabs WHERE tabid=@tabid);

	-- 增加权限
	SET @i=0;
	INSERT INTO ld_profileallpermission(tabid,operation,sequence)
	SELECT @tabid,actionid,(@i:=@i+1) FROM ld_actionmapping
	WHERE NOT EXISTS (SELECT 1 FROM ld_profileallpermission WHERE tabid=@tabid) AND actionname IN
		('index','QuotesChange_Add','QuotesChange_Replace','QuotesChange_Edit','Detailview','EditView','Delete','Copy','Allocate','Share','Import','Export','ChangeCreator','CustomView','Advance','DownLoad','Preview','FileReadHistory');

	-- 表的主键信息
	INSERT INTO ld_entityname(tabid ,modulename,tablename,fieldname,entityidfield,entityidcolumn)
	SELECT @tabid,tmp_modulename,CONCAT('ld_',LOWER(tmp_modulename)),CONCAT(LOWER(tmp_modulename),'_no'),CONCAT(LOWER(tmp_modulename),'id'),CONCAT(LOWER(tmp_modulename),'id') FROM DUAl
	WHERE NOT EXISTS (SELECT 1 FROM ld_entityname WHERE tabid=@tabid AND modulename=tmp_modulename);



		-- 添加区块-基本信息

		SET @maxblockid=(SELECT MAX(blockid) FROM ld_blocks);
		INSERT INTO ld_blocks(blockid,tabid,blocklabel,sequence,show_title,visible,create_view,edit_view,detail_view,display_status,iscustom)
		SELECT @maxblockid+1,@tabid,CONCAT('LBL_',UPPER(tmp_modulename),'_BASICINFORMATION'),1,0,0,0,0,0,1,0 FROM DUAL
		WHERE NOT EXISTS (SELECT 1 FROM ld_blocks WHERE blocklabel=CONCAT('LBL_',UPPER(tmp_modulename),'_BASICINFORMATION') AND tabid=@tabid);

		SET @blockid=(SELECT blockid FROM ld_blocks WHERE blocklabel=CONCAT('LBL_',UPPER(tmp_modulename),'_BASICINFORMATION') AND tabid=@tabid);
		INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
		SELECT 'zh','ld_blocks',@tabid,@blockid,'基本信息' FROM DUAL
		WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE tabid=@tabid AND relateid=@blockid AND languagetype='zh' and trantable='ld_blocks');
		INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
		SELECT 'en','ld_blocks',@tabid,@blockid,'Basic Information' FROM DUAL
		WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE tabid=@tabid AND relateid=@blockid AND languagetype='en' and trantable='ld_blocks');
		UPDATE ld_blocks_seq SET id=(SELECT MAX(blockid) FROM ld_blocks);

		SET @i=IFNULL((SELECT MAX(sequence) FROM ld_field WHERE block=@blockid),0);
		-- 添加字段
		SET @maxfieldid=(SELECT MAX(fieldid) from ld_field);
		INSERT INTO ld_field (tabid,fieldid,columnname,allowhide,tablename,generatedtype,uitype,fieldname,fieldlabel,readonly,presence,defaultvalue,sequence,block,displaytype,typeofdata,quickcreate,issmownerid,masseditable,approve_demand,bigtype,datarang,maxrowsshow)
		SELECT @tabid,@maxfieldid+1,'change_date','yes',CONCAT('ld_',LOWER(tmp_modulename)),1,5,'change_date','变更日期',0,0,'thistoday',(@i:=@i+1),@blockid ,1,'D~O',0,0,1,2,'date',NULL,0 FROM DUAL
		WHERE NOT EXISTS (SELECT 1 FROM ld_field WHERE tabid=@tabid AND columnname='change_date');

    SET @fieldid=(SELECT fieldid FROM ld_field WHERE tabid=@tabid AND columnname='change_date');
		INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
		SELECT 'zh','ld_field',@tabid, @fieldid,'变更日期' FROM DUAL
		WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE tabid=@tabid AND relateid=@fieldid AND languagetype='zh' AND trantable='ld_field' );
		INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
		SELECT 'en','ld_field',@tabid, @fieldid,'Change Date' FROM DUAL
		WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE tabid=@tabid AND relateid=@fieldid AND languagetype='en' AND trantable='ld_field' );

		SET @maxfieldid=(SELECT MAX(fieldid) from ld_field);
		INSERT INTO ld_field (tabid,fieldid,columnname,allowhide,tablename,generatedtype,uitype,fieldname,fieldlabel,readonly,presence,sequence,block,displaytype,typeofdata,quickcreate,issmownerid,masseditable,approve_demand,bigtype,datarang,maxrowsshow)
		SELECT @tabid,@maxfieldid+1,'budgetchange_no','no',CONCAT('ld_',LOWER(tmp_modulename)),1,4,'budgetchange_no','预算变更单编号',0,0,(@i:=@i+1),@blockid ,1,'V~O',0,0,1,2,'moduleno',NULL,0 FROM DUAL
		WHERE NOT EXISTS (SELECT 1 FROM ld_field WHERE tabid=@tabid AND columnname='budgetchange_no');

    SET @fieldid=(SELECT fieldid FROM ld_field WHERE tabid=@tabid AND columnname='budgetchange_no');
		INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
		SELECT 'zh','ld_field',@tabid, @fieldid,'预算变更单' FROM DUAL
		WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE tabid=@tabid AND relateid=@fieldid AND languagetype='zh' AND trantable='ld_field' );
		INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
		SELECT 'en','ld_field',@tabid, @fieldid,'Bill NO' FROM DUAL
		WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE tabid=@tabid AND relateid=@fieldid AND languagetype='en' AND trantable='ld_field' );

		SET @maxfieldid=(SELECT MAX(fieldid) from ld_field);
		INSERT INTO ld_field (tabid,fieldid,columnname,allowhide,tablename,generatedtype,uitype,fieldname,fieldlabel,readonly,presence,sequence,block,displaytype,typeofdata,quickcreate,issmownerid,masseditable,approve_demand,allowedit,allowedit_presence,allowcreate,allowcreate_presence,bigtype,datarang,maxrowsshow)
		SELECT @tabid,@maxfieldid+1,'change_type','yes',CONCAT('ld_',LOWER(tmp_modulename)),1,1,'change_type','变更类型',0,0,(@i:=@i+1),@blockid ,2,'V~O',0,0,1,2,'no','no','no','no','text',NULL,0 FROM DUAL
		WHERE NOT EXISTS (SELECT 1 FROM ld_field WHERE tabid=@tabid AND columnname='change_type');

    SET @fieldid=(SELECT fieldid FROM ld_field WHERE tabid=@tabid AND columnname='change_type');
		INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
		SELECT 'zh','ld_field',@tabid, @fieldid,'变更类型' FROM DUAL
		WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE tabid=@tabid AND relateid=@fieldid AND languagetype='zh' AND trantable='ld_field' );
		INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
		SELECT 'en','ld_field',@tabid, @fieldid,'Change Type' FROM DUAL
		WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE tabid=@tabid AND relateid=@fieldid AND languagetype='en' AND trantable='ld_field' );

		SET @maxfieldid=(SELECT MAX(fieldid) from ld_field);
		INSERT INTO ld_field (tabid,fieldid,columnname,allowhide,tablename,generatedtype,uitype,fieldname,fieldlabel,readonly,presence,sequence,block,displaytype,typeofdata,quickcreate,issmownerid,masseditable,approve_demand,bigtype,datarang,maxrowsshow)
		SELECT @tabid,@maxfieldid+1,'smownerid','no',CONCAT('ld_',LOWER(tmp_modulename)),1,53,'assigned_user_id','负责人',0,0,(@i:=@i+1),@blockid ,1,'V~M',0,1,0,2,'users',NULL,0 FROM DUAL
		WHERE NOT EXISTS (SELECT 1 FROM ld_field WHERE tabid=@tabid AND columnname='smownerid');

    SET @fieldid=(SELECT fieldid FROM ld_field WHERE tabid=@tabid AND columnname='smownerid');
		INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
		SELECT 'zh','ld_field',@tabid, @fieldid,'负责人' FROM DUAL
		WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE tabid=@tabid AND relateid=@fieldid AND languagetype='zh' AND trantable='ld_field' );
		INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
		SELECT 'en','ld_field',@tabid, @fieldid,'Assigned To' FROM DUAL
		WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE tabid=@tabid AND relateid=@fieldid AND languagetype='en' AND trantable='ld_field' );

		SET @maxfieldid=(SELECT MAX(fieldid) from ld_field);
		INSERT INTO ld_field (tabid,fieldid,columnname,allowhide,tablename,generatedtype,uitype,fieldname,fieldlabel,readonly,presence,sequence,block,displaytype,typeofdata,quickcreate,issmownerid,masseditable,approve_demand,allowedit,allowedit_presence,allowcreate,allowcreate_presence,bigtype,datarang,maxrowsshow)
		SELECT @tabid,@maxfieldid+1,'accountid','yes',CONCAT('ld_',LOWER(tmp_modulename)),1,73,'account_id','客户名称',0,0,(@i:=@i+1),@blockid ,2,'V~O',0,0,1,0,'no','no','no','no','reference','permit',10 FROM DUAL
		WHERE NOT EXISTS (SELECT 1 FROM ld_field WHERE tabid=@tabid AND columnname='accountid');

    SET @fieldid=(SELECT fieldid FROM ld_field WHERE tabid=@tabid AND columnname='accountid');
		INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
		SELECT 'zh','ld_field',@tabid, @fieldid,'客户名称' FROM DUAL
		WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE tabid=@tabid AND relateid=@fieldid AND languagetype='zh' AND trantable='ld_field' );
		INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
		SELECT 'en','ld_field',@tabid, @fieldid,'Customer Name' FROM DUAL
		WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE tabid=@tabid AND relateid=@fieldid AND languagetype='en' AND trantable='ld_field' );


		SET @customform14uitype = (select ld_ws_fieldtype.uitype  from ld_ws_fieldtype
										 LEFT JOIN ld_ws_referencetype
						 on ld_ws_referencetype.fieldtypeid=ld_ws_fieldtype.fieldtypeid where type='CustomForm14'   group by uitype );
		SET @maxfieldid=(SELECT MAX(fieldid) from ld_field);
		INSERT INTO ld_field (tabid,fieldid,columnname,allowhide,tablename,generatedtype,uitype,fieldname,fieldlabel,readonly,presence,sequence,block,displaytype,typeofdata,quickcreate,issmownerid,masseditable,approve_demand,allowedit,allowedit_presence,allowcreate,allowcreate_presence,bigtype,datarang,maxrowsshow)
		SELECT @tabid,@maxfieldid+1,'customform14id','no',CONCAT('ld_',LOWER(tmp_modulename)),1,@customform14uitype,'customform14_id','成本预算单',0,0,(@i:=@i+1),@blockid ,2,'I~O',0,0,1,0,'no','no','no','no','reference','all',10 FROM DUAL
		WHERE NOT EXISTS (SELECT 1 FROM ld_field WHERE tabid=@tabid AND columnname='customform14id');

		SET @fieldid=(SELECT fieldid FROM ld_field WHERE tabid=@tabid AND columnname='customform14id');
		INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
		SELECT 'zh','ld_field',@tabid, @fieldid,'成本预算单' FROM DUAL
		WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE tabid=@tabid AND relateid=@fieldid AND languagetype='zh' AND trantable='ld_field' );
		INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
		SELECT 'en','ld_field',@tabid, @fieldid,'Cost Budget No' FROM DUAL
		WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE tabid=@tabid AND relateid=@fieldid AND languagetype='en' AND trantable='ld_field' );

		SET @maxfieldid=(SELECT MAX(fieldid) from ld_field);
		INSERT INTO ld_field (tabid,fieldid,columnname,allowhide,tablename,generatedtype,uitype,fieldname,fieldlabel,readonly,presence,sequence,block,displaytype,typeofdata,quickcreate,issmownerid,masseditable,approve_demand,allowedit,bigtype,datarang,maxrowsshow)
		SELECT @tabid,@maxfieldid+1,'form14_type','yes',CONCAT('ld_',LOWER(tmp_modulename)),1,1,'form14_type','单据类型',1,0,(@i:=@i+1),@blockid ,1,'V~O',0,0,1,2,'no','text','all',10 FROM DUAL
		WHERE NOT EXISTS (SELECT 1 FROM ld_field WHERE tabid=@tabid AND columnname='form14_type');

    SET @fieldid=(SELECT fieldid FROM ld_field WHERE tabid=@tabid AND columnname='form14_type');
		INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
		SELECT 'zh','ld_field',@tabid, @fieldid,'单据类型' FROM DUAL
		WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE tabid=@tabid AND relateid=@fieldid AND languagetype='zh' AND trantable='ld_field' );
		INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
		SELECT 'en','ld_field',@tabid, @fieldid,'Document type' FROM DUAL
		WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE tabid=@tabid AND relateid=@fieldid AND languagetype='en' AND trantable='ld_field' );


		SET @maxfieldid=(SELECT MAX(fieldid) from ld_field);
		INSERT INTO ld_field (tabid,fieldid,columnname,allowhide,tablename,generatedtype,uitype,fieldname,fieldlabel,readonly,presence,sequence,block,displaytype,typeofdata,quickcreate,issmownerid,masseditable,approve_demand,allowedit,allowedit_presence,allowcreate,allowcreate_presence,bigtype,datarang,maxrowsshow)
		SELECT @tabid,@maxfieldid+1,'approveby','yes',CONCAT('ld_',LOWER(tmp_modulename)),1,131,'approveby','上一步审批人',0,1,(@i:=@i+1),@blockid ,2,'V~O',0,0,1,2,'no','no','no','no','',NULL,0 FROM DUAL
		WHERE NOT EXISTS (SELECT 1 FROM ld_field WHERE tabid=@tabid AND columnname='approveby');

    SET @fieldid=(SELECT fieldid FROM ld_field WHERE tabid=@tabid AND columnname='approveby');
		INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
		SELECT 'zh','ld_field',@tabid, @fieldid,'上一步审批人' FROM DUAL
		WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE tabid=@tabid AND relateid=@fieldid AND languagetype='zh' AND trantable='ld_field' );
		INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
		SELECT 'en','ld_field',@tabid, @fieldid,'The Last Approver' FROM DUAL
		WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE tabid=@tabid AND relateid=@fieldid AND languagetype='en' AND trantable='ld_field' );

		SET @maxfieldid=(SELECT MAX(fieldid) from ld_field);
		INSERT INTO ld_field (tabid,fieldid,columnname,allowhide,tablename,generatedtype,uitype,fieldname,fieldlabel,readonly,presence,sequence,block,displaytype,typeofdata,quickcreate,issmownerid,masseditable,approve_demand,allowedit,allowedit_presence,allowcreate,allowcreate_presence,bigtype,datarang,maxrowsshow)
		SELECT @tabid,@maxfieldid+1,'approvestatus','yes',CONCAT('ld_',LOWER(tmp_modulename)),1,609,'approvestatus','审批状态',0,1,(@i:=@i+1),@blockid ,2,'V~O',0,0,1,2,'no','no','no','no',NULL,NULL,0 FROM DUAL
		WHERE NOT EXISTS (SELECT 1 FROM ld_field WHERE tabid=@tabid AND columnname='approvestatus');

    SET @fieldid=(SELECT fieldid FROM ld_field WHERE tabid=@tabid AND columnname='approvestatus');
		INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
		SELECT 'zh','ld_field',@tabid, @fieldid,'审批状态' FROM DUAL
		WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE tabid=@tabid AND relateid=@fieldid AND languagetype='zh' AND trantable='ld_field' );
		INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
		SELECT 'en','ld_field',@tabid, @fieldid,'Approve Status' FROM DUAL
		WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE tabid=@tabid AND relateid=@fieldid AND languagetype='en' AND trantable='ld_field' );

		SET @maxfieldid=(SELECT MAX(fieldid) from ld_field);
		INSERT INTO ld_field (tabid,fieldid,columnname,allowhide,tablename,generatedtype,uitype,fieldname,fieldlabel,readonly,presence,sequence,block,displaytype,typeofdata,quickcreate,issmownerid,masseditable,approve_demand,allowedit,allowedit_presence,allowcreate,allowcreate_presence,bigtype,datarang,maxrowsshow)
		SELECT @tabid,@maxfieldid+1,'currentapprover','yes',CONCAT('ld_',LOWER(tmp_modulename)),1,132,'currentapprover','下一步审批人',1,1,(@i:=@i+1),@blockid ,2,'V~O',0,0,1,2,'no','no','no','no',NULL,NULL,0 FROM DUAL
		WHERE NOT EXISTS (SELECT 1 FROM ld_field WHERE tabid=@tabid AND columnname='currentapprover');

    SET @fieldid=(SELECT fieldid FROM ld_field WHERE tabid=@tabid AND columnname='currentapprover');
		INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
		SELECT 'zh','ld_field',@tabid, @fieldid,'下一步审批人' FROM DUAL
		WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE tabid=@tabid AND relateid=@fieldid AND languagetype='zh' AND trantable='ld_field' );
		INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
		SELECT 'en','ld_field',@tabid, @fieldid,'Next Approver' FROM DUAL
		WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE tabid=@tabid AND relateid=@fieldid AND languagetype='en' AND trantable='ld_field' );

		SET @maxfieldid=(SELECT MAX(fieldid) from ld_field);
		INSERT INTO ld_field (tabid,fieldid,columnname,allowhide,tablename,generatedtype,uitype,fieldname,fieldlabel,readonly,presence,sequence,block,displaytype,typeofdata,quickcreate,issmownerid,masseditable,approve_demand,allowedit,allowedit_presence,allowcreate,allowcreate_presence,bigtype,datarang,maxrowsshow)
		SELECT @tabid,@maxfieldid+1,'createdtime','yes',CONCAT('ld_',LOWER(tmp_modulename)),1,70,'createdtime','创建时间',1,0,(@i:=@i+1),@blockid ,2,'DT~O',0,0,1,2,'no','no','no','no','datetime',NULL,0 FROM DUAL
		WHERE NOT EXISTS (SELECT 1 FROM ld_field WHERE tabid=@tabid AND columnname='createdtime');

    SET @fieldid=(SELECT fieldid FROM ld_field WHERE tabid=@tabid AND columnname='createdtime');
		INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
		SELECT 'zh','ld_field',@tabid, @fieldid,'创建时间' FROM DUAL
		WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE tabid=@tabid AND relateid=@fieldid AND languagetype='zh' AND trantable='ld_field' );
		INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
		SELECT 'en','ld_field',@tabid, @fieldid,'Created Time' FROM DUAL
		WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE tabid=@tabid AND relateid=@fieldid AND languagetype='en' AND trantable='ld_field' );


		SET @maxfieldid=(SELECT MAX(fieldid) from ld_field);
		INSERT INTO ld_field (tabid,fieldid,columnname,allowhide,tablename,generatedtype,uitype,fieldname,fieldlabel,readonly,presence,sequence,block,displaytype,typeofdata,quickcreate,issmownerid,masseditable,approve_demand,allowedit,allowedit_presence,allowcreate,allowcreate_presence,bigtype,datarang,maxrowsshow)
		SELECT @tabid,@maxfieldid+1,'smcreatorid','yes',CONCAT('ld_',LOWER(tmp_modulename)),1,52,'smcreatorid','创建人',1,0,(@i:=@i+1),@blockid ,2,'V~O',0,0,1,2,'no','no','no','no','users',NULL,0 FROM DUAL
		WHERE NOT EXISTS (SELECT 1 FROM ld_field WHERE tabid=@tabid AND columnname='smcreatorid');

    SET @fieldid=(SELECT fieldid FROM ld_field WHERE tabid=@tabid AND columnname='smcreatorid');
		INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
		SELECT 'zh','ld_field',@tabid, @fieldid,'创建人' FROM DUAL
		WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE tabid=@tabid AND relateid=@fieldid AND languagetype='zh' AND trantable='ld_field' );
		INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
		SELECT 'en','ld_field',@tabid, @fieldid,'Creator' FROM DUAL
		WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE tabid=@tabid AND relateid=@fieldid AND languagetype='en' AND trantable='ld_field' );


		SET @maxfieldid=(SELECT MAX(fieldid) from ld_field);
		INSERT INTO ld_field (tabid,fieldid,columnname,allowhide,tablename,generatedtype,uitype,fieldname,fieldlabel,readonly,presence,sequence,block,displaytype,typeofdata,quickcreate,issmownerid,masseditable,approve_demand,allowedit,allowedit_presence,allowcreate,allowcreate_presence,bigtype,datarang,maxrowsshow)
		SELECT @tabid,@maxfieldid+1,'modifiedtime','yes',CONCAT('ld_',LOWER(tmp_modulename)),1,70,'modifiedtime','更新时间',1,0,(@i:=@i+1),@blockid ,2,'DT~O',0,0,1,2,'no','no','no','no','datetime',NULL,0 FROM DUAL
		WHERE NOT EXISTS (SELECT 1 FROM ld_field WHERE tabid=@tabid AND columnname='modifiedtime');

    SET @fieldid=(SELECT fieldid FROM ld_field WHERE tabid=@tabid AND columnname='modifiedtime');
		INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
		SELECT 'zh','ld_field',@tabid, @fieldid,'更新时间' FROM DUAL
		WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE tabid=@tabid AND relateid=@fieldid AND languagetype='zh' AND trantable='ld_field' );
		INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
		SELECT 'en','ld_field',@tabid, @fieldid,'Modified Time' FROM DUAL
		WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE tabid=@tabid AND relateid=@fieldid AND languagetype='en' AND trantable='ld_field' );


		SET @maxfieldid=(SELECT MAX(fieldid) from ld_field);
		INSERT INTO ld_field (tabid,fieldid,columnname,allowhide,tablename,generatedtype,uitype,fieldname,fieldlabel,readonly,presence,sequence,block,displaytype,typeofdata,quickcreate,issmownerid,masseditable,approve_demand,allowedit,allowedit_presence,allowcreate,allowcreate_presence,bigtype,datarang,maxrowsshow)
		SELECT @tabid,@maxfieldid+1,'modifiedby','yes',CONCAT('ld_',LOWER(tmp_modulename)),1,52,'modifiedby','最新更新人',1,1,(@i:=@i+1),@blockid ,2,'V~O',0,0,1,2,'no','no','no','no','users',NULL,0 FROM DUAL
		WHERE NOT EXISTS (SELECT 1 FROM ld_field WHERE tabid=@tabid AND columnname='modifiedby');

    SET @fieldid=(SELECT fieldid FROM ld_field WHERE tabid=@tabid AND columnname='modifiedby');
		INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
		SELECT 'zh','ld_field',@tabid, @fieldid,'最新更新人' FROM DUAL
		WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE tabid=@tabid AND relateid=@fieldid AND languagetype='zh' AND trantable='ld_field' );
		INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
		SELECT 'en','ld_field',@tabid, @fieldid,'Modified By' FROM DUAL
		WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE tabid=@tabid AND relateid=@fieldid AND languagetype='en' AND trantable='ld_field' );


		SET @maxfieldid=(SELECT MAX(fieldid) from ld_field);
		INSERT INTO ld_field (tabid,fieldid,columnname,allowhide,tablename,generatedtype,uitype,fieldname,fieldlabel,readonly,presence,sequence,block,displaytype,typeofdata,quickcreate,issmownerid,masseditable,approve_demand,allowedit,allowedit_presence,allowcreate,allowcreate_presence,allowdetail_presence,bigtype,datarang,maxrowsshow)
		SELECT @tabid,@maxfieldid+1,'subtotal','yes',CONCAT('ld_',LOWER(tmp_modulename)),1,72,'hdnSubTotal','小计',1,0,(@i:=@i+1),@blockid ,3,'N~O',0,0,1,2,'no','no','no','no','no','currency',NULL,0 FROM DUAL
		WHERE NOT EXISTS (SELECT 1 FROM ld_field WHERE tabid=@tabid AND columnname='subtotal');

    SET @fieldid=(SELECT fieldid FROM ld_field WHERE tabid=@tabid AND columnname='subtotal');
		INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
		SELECT 'zh','ld_field',@tabid, @fieldid,'小计' FROM DUAL
		WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE tabid=@tabid AND relateid=@fieldid AND languagetype='zh' AND trantable='ld_field' );
		INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
		SELECT 'en','ld_field',@tabid, @fieldid,'Sub Total' FROM DUAL
		WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE tabid=@tabid AND relateid=@fieldid AND languagetype='en' AND trantable='ld_field' );


		SET @maxfieldid=(SELECT MAX(fieldid) from ld_field);
		INSERT INTO ld_field (tabid,fieldid,columnname,allowhide,tablename,generatedtype,uitype,fieldname,fieldlabel,readonly,presence,sequence,block,displaytype,typeofdata,quickcreate,issmownerid,masseditable,approve_demand,allowedit,allowedit_presence,allowcreate,allowcreate_presence,allowdetail_presence,bigtype,datarang,maxrowsshow)
		SELECT @tabid,@maxfieldid+1,'total','no',CONCAT('ld_',LOWER(tmp_modulename)),1,72,'hdnGrandTotal','合计',1,0,(@i:=@i+1),@blockid ,3,'N~O',0,0,1,2,'no','no','no','no','no','currency',NULL,0 FROM DUAL
		WHERE NOT EXISTS (SELECT 1 FROM ld_field WHERE tabid=@tabid AND columnname='total');

    SET @fieldid=(SELECT fieldid FROM ld_field WHERE tabid=@tabid AND columnname='total');
		INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
		SELECT 'zh','ld_field',@tabid, @fieldid,'合计' FROM DUAL
		WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE tabid=@tabid AND relateid=@fieldid AND languagetype='zh' AND trantable='ld_field' );
		INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
		SELECT 'en','ld_field',@tabid, @fieldid,'Total' FROM DUAL
		WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE tabid=@tabid AND relateid=@fieldid AND languagetype='en' AND trantable='ld_field' );


		SET @maxfieldid=(SELECT MAX(fieldid) from ld_field);
		INSERT INTO ld_field (tabid,fieldid,columnname,allowhide,tablename,generatedtype,uitype,fieldname,fieldlabel,readonly,presence,sequence,block,displaytype,typeofdata,quickcreate,issmownerid,masseditable,approve_demand,allowedit,allowedit_presence,allowcreate,allowcreate_presence,allowdetail_presence,bigtype,datarang,maxrowsshow)
		SELECT @tabid,@maxfieldid+1,'adjustment','yes',CONCAT('ld_',LOWER(tmp_modulename)),1,72,'txtAdjustment','调整',1,0,(@i:=@i+1),@blockid ,3,'NN~O',0,0,1,2,'no','no','no','no','no','currency',NULL,0 FROM DUAL
		WHERE NOT EXISTS (SELECT 1 FROM ld_field WHERE tabid=@tabid AND columnname='adjustment');

    SET @fieldid=(SELECT fieldid FROM ld_field WHERE tabid=@tabid AND columnname='adjustment');
		INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
		SELECT 'zh','ld_field',@tabid, @fieldid,'调整' FROM DUAL
		WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE tabid=@tabid AND relateid=@fieldid AND languagetype='zh' AND trantable='ld_field' );
		INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
		SELECT 'en','ld_field',@tabid, @fieldid,'Adjustment' FROM DUAL
		WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE tabid=@tabid AND relateid=@fieldid AND languagetype='en' AND trantable='ld_field' );


		SET @maxfieldid=(SELECT MAX(fieldid) from ld_field);
		INSERT INTO ld_field (tabid,fieldid,columnname,allowhide,tablename,generatedtype,uitype,fieldname,fieldlabel,readonly,presence,sequence,block,displaytype,typeofdata,quickcreate,issmownerid,masseditable,approve_demand,allowedit,allowedit_presence,allowcreate,allowcreate_presence,allowdetail_presence,bigtype,datarang,maxrowsshow)
		SELECT @tabid,@maxfieldid+1,'discount_amount','yes',CONCAT('ld_',LOWER(tmp_modulename)),1,72,'hdnDiscountAmount','整单折扣',1,0,(@i:=@i+1),@blockid ,3,'N~O',0,0,1,2,'no','no','no','no','no','currency',NULL,0 FROM DUAL
		WHERE NOT EXISTS (SELECT 1 FROM ld_field WHERE tabid=@tabid AND columnname='discount_amount');

    SET @fieldid=(SELECT fieldid FROM ld_field WHERE tabid=@tabid AND columnname='discount_amount');
		INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
		SELECT 'zh','ld_field',@tabid, @fieldid,'整单折扣' FROM DUAL
		WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE tabid=@tabid AND relateid=@fieldid AND languagetype='zh' AND trantable='ld_field' );
		INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
		SELECT 'en','ld_field',@tabid, @fieldid,'Discount Amount' FROM DUAL
		WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE tabid=@tabid AND relateid=@fieldid AND languagetype='en' AND trantable='ld_field' );


		SET @maxfieldid=(SELECT MAX(fieldid) from ld_field);
		INSERT INTO ld_field (tabid,fieldid,columnname,allowhide,tablename,generatedtype,uitype,fieldname,fieldlabel,readonly,presence,sequence,block,displaytype,typeofdata,quickcreate,issmownerid,masseditable,approve_demand,allowedit,allowedit_presence,allowcreate,allowcreate_presence,allowdetail_presence,bigtype,datarang,maxrowsshow)
		SELECT @tabid,@maxfieldid+1,'currency_id','yes',CONCAT('ld_',LOWER(tmp_modulename)),1,117,'currency_id','货币',1,0,(@i:=@i+1),@blockid ,3,'V~M',0,0,1,2,'no','no','no','no','no','currency',NULL,10 FROM DUAL
		WHERE NOT EXISTS (SELECT 1 FROM ld_field WHERE tabid=@tabid AND columnname='currency_id');

    SET @fieldid=(SELECT fieldid FROM ld_field WHERE tabid=@tabid AND columnname='currency_id');
		INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
		SELECT 'zh','ld_field',@tabid, @fieldid,'货币' FROM DUAL
		WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE tabid=@tabid AND relateid=@fieldid AND languagetype='zh' AND trantable='ld_field' );
		INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
		SELECT 'en','ld_field',@tabid, @fieldid,'Currency Id' FROM DUAL
		WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE tabid=@tabid AND relateid=@fieldid AND languagetype='en' AND trantable='ld_field' );


		SET @maxfieldid=(SELECT MAX(fieldid) from ld_field);
		INSERT INTO ld_field (tabid,fieldid,columnname,allowhide,tablename,generatedtype,uitype,fieldname,fieldlabel,readonly,presence,sequence,block,displaytype,typeofdata,quickcreate,issmownerid,masseditable,approve_demand,allowedit,allowedit_presence,allowcreate,allowcreate_presence,allowdetail_presence,bigtype,datarang,maxrowsshow)
		SELECT @tabid,@maxfieldid+1,'conversion_rate','yes',CONCAT('ld_',LOWER(tmp_modulename)),1,1,'conversion_rate','汇率',1,0,(@i:=@i+1),@blockid ,3,'N~O',0,0,1,2,'no','no','no','no','no','currency',NULL,0 FROM DUAL
		WHERE NOT EXISTS (SELECT 1 FROM ld_field WHERE tabid=@tabid AND columnname='conversion_rate');

    SET @fieldid=(SELECT fieldid FROM ld_field WHERE tabid=@tabid AND columnname='conversion_rate');
		INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
		SELECT 'zh','ld_field',@tabid, @fieldid,'汇率' FROM DUAL
		WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE tabid=@tabid AND relateid=@fieldid AND languagetype='zh' AND trantable='ld_field' );
		INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
		SELECT 'en','ld_field',@tabid, @fieldid,'Conversion_rate' FROM DUAL
		WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE tabid=@tabid AND relateid=@fieldid AND languagetype='en' AND trantable='ld_field' );


		SET @maxfieldid=(SELECT MAX(fieldid) from ld_field);
		INSERT INTO ld_field (tabid,fieldid,columnname,allowhide,tablename,generatedtype,uitype,fieldname,fieldlabel,readonly,presence,sequence,block,displaytype,typeofdata,quickcreate,issmownerid,masseditable,approve_demand,allowedit,allowedit_presence,allowcreate,allowcreate_presence,bigtype,datarang,maxrowsshow)
		SELECT @tabid,@maxfieldid+1,'print_times','yes',CONCAT('ld_',LOWER(tmp_modulename)),1,1,'print_times','打印次数',1,1,(@i:=@i+1),@blockid ,2,'N~O',0,0,0,2,'no','no','no','no','text',NULL,0 FROM DUAL
		WHERE NOT EXISTS (SELECT 1 FROM ld_field WHERE tabid=@tabid AND columnname='print_times');

    SET @fieldid=(SELECT fieldid FROM ld_field WHERE tabid=@tabid AND columnname='print_times');
		INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
		SELECT 'zh','ld_field',@tabid, @fieldid,'打印次数' FROM DUAL
		WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE tabid=@tabid AND relateid=@fieldid AND languagetype='zh' AND trantable='ld_field' );
		INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
		SELECT 'en','ld_field',@tabid, @fieldid,'Printing times' FROM DUAL
		WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE tabid=@tabid AND relateid=@fieldid AND languagetype='en' AND trantable='ld_field' );


		SET @maxfieldid=(SELECT MAX(fieldid) from ld_field);
		INSERT INTO ld_field (tabid,fieldid,columnname,allowhide,tablename,generatedtype,uitype,fieldname,fieldlabel,readonly,presence,sequence,block,displaytype,typeofdata,quickcreate,issmownerid,masseditable,approve_demand,allowedit,allowedit_presence,allowcreate,allowcreate_presence,bigtype,datarang,maxrowsshow)
		SELECT @tabid,@maxfieldid+1,'approvetime','yes',CONCAT('ld_',LOWER(tmp_modulename)),1,70,'approvetime','最新审批时间',1,1,(@i:=@i+1),@blockid ,2,'DT~O',0,0,1,2,'no','no','no','no','datetime',NULL,0 FROM DUAL
		WHERE NOT EXISTS (SELECT 1 FROM ld_field WHERE tabid=@tabid AND columnname='approvetime');

    SET @fieldid=(SELECT fieldid FROM ld_field WHERE tabid=@tabid AND columnname='approvetime');
		INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
		SELECT 'zh','ld_field',@tabid, @fieldid,'最新审批时间' FROM DUAL
		WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE tabid=@tabid AND relateid=@fieldid AND languagetype='zh' AND trantable='ld_field' );
		INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
		SELECT 'en','ld_field',@tabid, @fieldid,'Last approval time' FROM DUAL
		WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE tabid=@tabid AND relateid=@fieldid AND languagetype='en' AND trantable='ld_field' );

		SET @maxfieldid=(SELECT MAX(fieldid) from ld_field);
		INSERT INTO ld_field (tabid,fieldid,columnname,allowhide,tablename,generatedtype,uitype,fieldname,fieldlabel,readonly,presence,sequence,block,displaytype,typeofdata,quickcreate,issmownerid,masseditable,approve_demand,allowedit,allowedit_presence,allowcreate,allowcreate_presence,bigtype,datarang,maxrowsshow)
		SELECT @tabid,@maxfieldid+1,'pricebooksid','yes',CONCAT('ld_',LOWER(tmp_modulename)),1,281,'pricebooksid','价格表',1,1,(@i:=@i+1),@blockid ,3,'V~O',0,0,1,2,'yes','','','','reference','permit',20 FROM DUAL
		WHERE NOT EXISTS (SELECT 1 FROM ld_field WHERE tabid=@tabid AND columnname='pricebooksid');

    SET @fieldid=(SELECT fieldid FROM ld_field WHERE tabid=@tabid AND columnname='pricebooksid');
		INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
		SELECT 'zh','ld_field',@tabid, @fieldid,'价格表' FROM DUAL
		WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE tabid=@tabid AND relateid=@fieldid AND languagetype='zh' AND trantable='ld_field' );
		INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
		SELECT 'en','ld_field',@tabid, @fieldid,'Price Book' FROM DUAL
		WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE tabid=@tabid AND relateid=@fieldid AND languagetype='en' AND trantable='ld_field' );


		SET @maxfieldid=(SELECT MAX(fieldid) from ld_field);
		INSERT INTO ld_field (tabid,fieldid,columnname,allowhide,tablename,generatedtype,uitype,fieldname,fieldlabel,readonly,presence,sequence,block,displaytype,typeofdata,quickcreate,issmownerid,masseditable,approve_demand,allowedit,allowedit_presence,allowcreate,allowcreate_presence,bigtype,datarang,maxrowsshow)
		SELECT @tabid,@maxfieldid+1,'advance_stage','yes',CONCAT('ld_',LOWER(tmp_modulename)),1,1,'advance_stage','推进阶段',1,1,(@i:=@i+1),@blockid ,3,'V~O',0,0,1,1,'yes','','','','',NULL,0 FROM DUAL
		WHERE NOT EXISTS (SELECT 1 FROM ld_field WHERE tabid=@tabid AND columnname='advance_stage');

    SET @fieldid=(SELECT fieldid FROM ld_field WHERE tabid=@tabid AND columnname='advance_stage');
		INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
		SELECT 'zh','ld_field',@tabid, @fieldid,'推进阶段' FROM DUAL
		WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE tabid=@tabid AND relateid=@fieldid AND languagetype='zh' AND trantable='ld_field' );
		INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
		SELECT 'en','ld_field',@tabid, @fieldid,'Advance Stage' FROM DUAL
		WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE tabid=@tabid AND relateid=@fieldid AND languagetype='en' AND trantable='ld_field' );


		SET @maxfieldid=(SELECT MAX(fieldid) from ld_field);
		INSERT INTO ld_field (tabid,fieldid,columnname,allowhide,tablename,generatedtype,uitype,fieldname,fieldlabel,readonly,presence,sequence,block,displaytype,typeofdata,quickcreate,issmownerid,masseditable,approve_demand,bigtype,datarang,maxrowsshow)
		SELECT @tabid,@maxfieldid+1,'team_memberid','yes',CONCAT('ld_',LOWER(tmp_modulename)),1,154,'team_memberid','团队成员',1,1,(@i:=@i+1),@blockid ,1,'V~O',0,0,1,1,'text',NULL,0 FROM DUAL
		WHERE NOT EXISTS (SELECT 1 FROM ld_field WHERE tabid=@tabid AND columnname='team_memberid');

    SET @fieldid=(SELECT fieldid FROM ld_field WHERE tabid=@tabid AND columnname='team_memberid');
		INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
		SELECT 'zh','ld_field',@tabid, @fieldid,'团队成员' FROM DUAL
		WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE tabid=@tabid AND relateid=@fieldid AND languagetype='zh' AND trantable='ld_field' );
		INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
		SELECT 'en','ld_field',@tabid, @fieldid,'Team Members' FROM DUAL
		WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE tabid=@tabid AND relateid=@fieldid AND languagetype='en' AND trantable='ld_field' );

		update ld_field_seq set id = (select max(fieldid) from ld_field);

		-- 产品分录字段
		SET @copytabid = (SELECT tabid FROM ld_tab WHERE `name`='Quoteschange');
		SET @i=(SELECT MAX(producttoolfieldid) FROM ld_producttoolfield);
		SET @j=0;
		INSERT INTO ld_producttoolfield(producttoolfieldid,columnname,allowhide,fieldlabel,defaultvalue,presence,uitype,typeofdata,sequence,tabid,tablename,width,edit_permission,input_type,fieldid,newline,defaultcolumn,is_checkimportfield,nullfield)
		SELECT (@i:=@i+1),columnname,allowhide,fieldlabel,defaultvalue,presence,uitype,typeofdata,(@j:=@j+1),@tabid,
			CASE
				WHEN tablename='ld_products' THEN 'ld_products'
				WHEN tablename='ld_productcf' THEN 'ld_productcf'
				WHEN tablename='ld_quoteschange' THEN CONCAT('ld_',LOWER(tmp_modulename))
				WHEN tablename='ld_quoteschangedetail' THEN CONCAT('ld_',LOWER(tmp_modulename),'detail')
			END AS tablename,width,edit_permission,input_type,
		CASE
			WHEN tablename='ld_products' OR columnname IN ('listprice','taxprice','productcost') THEN fieldid
			WHEN tablename='ld_productcf'  THEN fieldid
			WHEN columnname IN ('tax1','tax2','tax3') THEN (SELECT taxid FROM ld_inventorytaxinfo WHERE taxname=ld_producttoolfield.columnname)
			WHEN columnname IN ('discount_amount','adjustment','subtotal','total') THEN (SELECT fieldid FROM ld_field WHERE tabid=@tabid AND columnname=ld_producttoolfield.columnname)
			ELSE 0
		END AS fieldid,newline,defaultcolumn,is_checkimportfield,nullfield
		FROM ld_producttoolfield
		WHERE tabid=@copytabid and tablename <> 'ld_quoteschangedetailscf'
			AND NOT EXISTS (SELECT 1 FROM ld_producttoolfield WHERE tabid=@tabid)
		ORDER BY IFNULL(sequence,1000);

		DELETE FROM ld_producttoolfield_formula WHERE producttoolfieldid IN (SELECT producttoolfieldid FROM ld_producttoolfield WHERE tabid=@tabid);
		INSERT INTO ld_producttoolfield_formula(producttoolfieldid,formulastring,columnstring,sequence)
		SELECT
			c.producttoolfieldid,
			a.formulastring,
			a.columnstring,
			a.sequence
		FROM ld_producttoolfield_formula a
		LEFT JOIN ld_producttoolfield b ON a.producttoolfieldid=b.producttoolfieldid
		LEFT JOIN ld_producttoolfield c ON c.columnname=b.columnname AND c.tabid=@tabid
		WHERE b.tabid=@copytabid
		ORDER BY a.sequence;

		DELETE FROM ld_tranlabel WHERE tabid=@tabid AND trantable='ld_producttoolfield';
		INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
		SELECT
		b.languagetype,
		b.trantable,
		@tabid,
		c.producttoolfieldid,
		b.fieldlabel
		FROM ld_producttoolfield a
		LEFT JOIN ld_tranlabel b ON b.Relateid=a.producttoolfieldid AND b.trantable='ld_producttoolfield'
		LEFT JOIN ld_producttoolfield c ON c.columnname=a.columnname AND c.tabid=@tabid
		WHERE a.tabid=@copytabid
		ORDER BY a.producttoolfieldid;


		CALL getallprofile(tmp_modulename);
		CALL fieldprofile(tmp_modulename);

	-- 数据分类
		SELECT MAX(cvid) INTO @maxcvid  FROM ld_customview;
		INSERT INTO ld_customview (cvid,viewname,setdefault,setmetrics,entitytype,status,userid,sequence)
		SELECT @maxcvid+1,'All',1,0,tmp_modulename,3,1,1 FROM dual
		WHERE NOT EXISTS (SELECT 1 FROM ld_customview where entitytype=tmp_modulename and viewname='All');

		UPDATE ld_customview_seq SET id=(SELECT MAX(cvid) FROM ld_customview);
		SET @cvid=(SELECT cvid FROM ld_customview WHERE entitytype=tmp_modulename AND viewname='All');
		DELETE FROM ld_cvadvfilter WHERE cvid=@cvid;
		DELETE FROM ld_cvadvfilter_grouping WHERE cvid=@cvid;
		DELETE FROM ld_tabwithproductview WHERE cvid=@cvid;

		INSERT INTO ld_tabwithproductview(tabid,cvid,sequence,columns)
		SELECT @tabid,@cvid,0,CONCAT('ld_',LOWER(tmp_modulename),':',LOWER(tmp_modulename),'_no',':',LOWER(tmp_modulename),'_no',':',tmp_modulename,'_fieldlabel:V');
		INSERT INTO ld_tabwithproductview(tabid,cvid,sequence,columns)
		SELECT @tabid,@cvid,1,CONCAT('ld_',LOWER(tmp_modulename),':','change_type:change_type:BudgetChange_fieldlabel:V');
		INSERT INTO ld_tabwithproductview(tabid,cvid,sequence,columns)
		SELECT @tabid,@cvid,2,CONCAT('ld_',LOWER(tmp_modulename),':','accountid:account_id:BudgetChange_fieldlabel:V');
		INSERT INTO ld_tabwithproductview(tabid,cvid,sequence,columns)
		SELECT @tabid,@cvid,3,CONCAT('ld_',LOWER(tmp_modulename),':','change_date:change_date:BudgetChange_fieldlabel:V');
		INSERT INTO ld_tabwithproductview(tabid,cvid,sequence,columns)
		SELECT @tabid,@cvid,4,CONCAT('ld_',LOWER(tmp_modulename),':','total:hdnGrandTotal:BudgetChange_fieldlabel:V');
		INSERT INTO ld_tabwithproductview(tabid,cvid,sequence,columns)
		SELECT @tabid,@cvid,5,CONCAT('ld_',LOWER(tmp_modulename),':','smownerid:assigned_user_id:BudgetChange_fieldlabel:V');
		INSERT INTO ld_tabwithproductview(tabid,cvid,sequence,columns)
		SELECT @tabid,@cvid,6,CONCAT('ld_',LOWER(tmp_modulename),':','worksheet_type:worksheet_type:BudgetChange_fieldlabel:V');
		INSERT INTO ld_tabwithproductview(tabid,cvid,sequence,`columns`)
		SELECT @tabid,@cvid,7,CONCAT('ld_',LOWER(tmp_modulename),'detailscf:','pro_id:pro_id:Products_fieldlabel:V');
		INSERT INTO ld_tabwithproductview(tabid,cvid,sequence,`columns`)
		SELECT @tabid,@cvid,8,'ld_products:productname:productname:Products_fieldlabel:V';
		INSERT INTO ld_tabwithproductview(tabid,cvid,sequence,`columns`)
		SELECT @tabid,@cvid,9,CONCAT('ld_',LOWER(tmp_modulename),'detail:','quantity:quantity:Products_fieldlabel:V');

		-- 相关信息
		SET @i=IFNULL((SELECT MAX(sequence) FROM ld_relatedlists WHERE tabid=@tabid),0);
		SET @maxrelation_id=(SELECT max(relation_id) FROM ld_relatedlists);
		INSERT INTO ld_relatedlists(relation_id,tabid,related_tabid,`name`,sequence,label,presence,actions,related_coltable,type)
		SELECT @maxrelation_id+1,@tabid,'-1','get_SharedUsers',(@i:=@i+1),'SharedUsers',0,'share','','' FROM DUAL
		WHERE NOT EXISTS (SELECT 1 FROM ld_relatedlists WHERE tabid=@tabid AND related_tabid='-1' AND `name`='get_SharedUsers');

		SET @maxrelation_id=(SELECT max(relation_id) FROM ld_relatedlists);
		INSERT INTO ld_relatedlists(relation_id,tabid,related_tabid,`name`,sequence,label,presence,actions,related_coltable,type)
		SELECT @maxrelation_id+1,@tabid,'-7','get_viewhistory',(@i:=@i+1),'ViewHistory',1,'','','' FROM DUAL
		WHERE NOT EXISTS (SELECT 1 FROM ld_relatedlists WHERE tabid=@tabid AND related_tabid='-7' AND `name`='get_viewhistory');

		SET @maxrelation_id=(SELECT max(relation_id) FROM ld_relatedlists);
		INSERT INTO ld_relatedlists(relation_id,tabid,related_tabid,`name`,sequence,label,presence,actions,related_coltable,type)
		SELECT @maxrelation_id+1,@tabid,'-10','get_changeview',(@i:=@i+1),'ChangeView',1,'','','' FROM DUAL
		WHERE NOT EXISTS (SELECT 1 FROM ld_relatedlists WHERE tabid=@tabid AND related_tabid='-10' AND `name`='get_changeview');

		UPDATE ld_relatedlists_seq SET id=(SELECT MAX(relation_id) FROM ld_relatedlists);


	-- 模块共享规则
		INSERT INTO ld_org_share_action2tab(share_action_id,tabid)
		SELECT 0,@tabid FROM DUAL
		WHERE NOT EXISTS (SELECT 1 FROM ld_org_share_action2tab WHERE tabid=@tabid AND share_action_id=0);
		INSERT INTO ld_org_share_action2tab(share_action_id,tabid)
		SELECT 1,@tabid FROM DUAL
		WHERE NOT EXISTS (SELECT 1 FROM ld_org_share_action2tab WHERE tabid=@tabid AND share_action_id=1);
		INSERT INTO ld_org_share_action2tab(share_action_id,tabid)
		SELECT 2,@tabid FROM DUAL
		WHERE NOT EXISTS (SELECT 1 FROM ld_org_share_action2tab WHERE tabid=@tabid AND share_action_id=2);
		INSERT INTO ld_org_share_action2tab(share_action_id,tabid)
		SELECT 3,@tabid FROM DUAL
		WHERE NOT EXISTS (SELECT 1 FROM ld_org_share_action2tab WHERE tabid=@tabid AND share_action_id=3);

		INSERT INTO ld_def_org_share(tabid,permission,editstatus)
		SELECT @tabid,3,0 FROM DUAL
		WHERE NOT EXISTS (SELECT 1 FROM ld_def_org_share WHERE tabid=@tabid);

		call addtabintoprofile(tmp_modulename,1);

	-- 审批流程
		SET @roottype=(SELECT roottype FROM ld_systems_deploy WHERE deploy_type=112);
		SET @seq=(SELECT MAX(sequence) FROM ld_systems_deploy WHERE roottype=@roottype);
		INSERT INTO ld_systems_deploy(deploy_value,deploy_type,description,setype,sequence,roottype,inputtype,presence,inputvalue)
		SELECT 0,tmp_deploy_type,CONCAT(tmp_zhmoudulename,'是否启用审批流程'),tmp_modulename,@seq+1,@roottype,'select',0,'[{"value":"0","text":"YES"},{"value":"1","text":"NO"},{"sql":""}]' FROM DUAL
		WHERE NOT EXISTS (SELECT 1 FROM ld_systems_deploy WHERE deploy_type=tmp_deploy_type);

		SET @approvename=CONCAT(tmp_zhmoudulename,'审批流程');
		SET @approveid=(SELECT MAX(id) FROM ld_approve);
		INSERT INTO ld_approve(id,tabid,`name`,`status`,smcreatorid,modifiedby,createdtime,modifiedtime,approveallocatetype,allowediting,allowantiapproval,finishedallowedit)
		SELECT @approveid+1,@tabid,CONCAT(tmp_zhmoudulename,'审批流程'),0,1,1,now(),now(),0,0,0,'no' FROM DUAL
		WHERE NOT EXISTS (SELECT 1 FROM ld_approve WHERE tabid=@tabid AND `name`=@approvename);

		SET @approveid=(SELECT id FROM ld_approve WHERE tabid=@tabid AND `name`=@approvename);
		SET @maxsetpid=(SELECT MAX(id) FROM ld_approvestep);
		SET @hadinsert=(SELECT COUNT(1) FROM ld_approvestep WHERE approveid=@approveid);
		INSERT INTO ld_approvestep(id,approveid,`name`,ended,step,sequence,createdtime,modifiedtime,approvetype,approvevalue,specifyapproverid)
		SELECT @maxsetpid+1,@approveid,'一级审批',0,1,1,now(),now(),0,1,0 FROM DUAL WHERE @hadinsert=0;

		INSERT INTO ld_approvestep(id,approveid,`name`,ended,step,sequence,createdtime,modifiedtime,approvetype,approvevalue,specifyapproverid)
		SELECT @maxsetpid+2,@approveid,'二级审批',1,1,2,now(),now(),0,1,0 FROM DUAL WHERE @hadinsert=0;

		INSERT INTO ld_approvestep(id,approveid,`name`,ended,step,sequence,createdtime,modifiedtime,approvetype,approvevalue,specifyapproverid)
		SELECT @maxsetpid+3,@approveid,'三级审批',1,1,3,now(),now(),0,1,0 FROM DUAL WHERE @hadinsert=0;

		UPDATE ld_approvestep_seq SET id=(SELECT MAX(id) FROM ld_approvestep);

		SET @stepid=(SELECT id FROM ld_approvestep WHERE approveid=@approveid AND `name`='一级审批' LIMIT 1);
		INSERT INTO ld_approvereminds(stepid,type,remindmethod,reminduser,remindcontent)
		SELECT @stepid,0,'dialog','approver','有新的单据需要审批，请及时处理！' FROM DUAL
		WHERE NOT EXISTS (SELECT 1 FROM ld_approvereminds WHERE stepid=@stepid AND type=0);

		SET @stepid=(SELECT id FROM ld_approvestep WHERE approveid=@approveid AND `name`='一级审批' LIMIT 1);
		INSERT INTO ld_approvereminds(stepid,type,remindmethod,reminduser,remindcontent)
		SELECT @stepid,1,'dialog','smowner','您提交的单据已通过审批步骤{step}' FROM DUAL
		WHERE NOT EXISTS (SELECT 1 FROM ld_approvereminds WHERE stepid=@stepid AND type=1);

		SET @stepid=(SELECT id FROM ld_approvestep WHERE approveid=@approveid AND `name`='一级审批' LIMIT 1);
		INSERT INTO ld_approvereminds(stepid,type,remindmethod,reminduser,remindcontent)
		SELECT @stepid,2,'dialog','smowner','您提交的单据未通过审批步骤{step}，原因：{description}' FROM DUAL
		WHERE NOT EXISTS (SELECT 1 FROM ld_approvereminds WHERE stepid=@stepid AND type=2);

		SET @stepid=(SELECT id FROM ld_approvestep WHERE approveid=@approveid AND `name`='二级审批' LIMIT 1);
		INSERT INTO ld_approvereminds(stepid,type,remindmethod,reminduser,remindcontent)
		SELECT @stepid,0,'dialog','approver','有新的单据需要审批，请及时处理！' FROM DUAL
		WHERE NOT EXISTS (SELECT 1 FROM ld_approvereminds WHERE stepid=@stepid AND type=0);

		SET @stepid=(SELECT id FROM ld_approvestep WHERE approveid=@approveid AND `name`='二级审批' LIMIT 1);
		INSERT INTO ld_approvereminds(stepid,type,remindmethod,reminduser,remindcontent)
		SELECT @stepid,1,'dialog','smowner','您提交的单据已通过审批步骤{step}' FROM DUAL
		WHERE NOT EXISTS (SELECT 1 FROM ld_approvereminds WHERE stepid=@stepid AND type=1);

		SET @stepid=(SELECT id FROM ld_approvestep WHERE approveid=@approveid AND `name`='二级审批' LIMIT 1);
		INSERT INTO ld_approvereminds(stepid,type,remindmethod,reminduser,remindcontent)
		SELECT @stepid,2,'dialog','smowner','您提交的单据未通过审批步骤{step}，原因：{description}' FROM DUAL
		WHERE NOT EXISTS (SELECT 1 FROM ld_approvereminds WHERE stepid=@stepid AND type=2);

		SET @stepid=(SELECT id FROM ld_approvestep WHERE approveid=@approveid AND `name`='三级审批' LIMIT 1);
		INSERT INTO ld_approvereminds(stepid,type,remindmethod,reminduser,remindcontent)
		SELECT @stepid,0,'dialog','approver','有新的单据需要审批，请及时处理！' FROM DUAL
		WHERE NOT EXISTS (SELECT 1 FROM ld_approvereminds WHERE stepid=@stepid AND type=0);

		SET @stepid=(SELECT id FROM ld_approvestep WHERE approveid=@approveid AND `name`='三级审批' LIMIT 1);
		INSERT INTO ld_approvereminds(stepid,type,remindmethod,reminduser,remindcontent)
		SELECT @stepid,1,'dialog','smowner','您提交的单据已通过审批步骤{step}' FROM DUAL
		WHERE NOT EXISTS (SELECT 1 FROM ld_approvereminds WHERE stepid=@stepid AND type=1);

		SET @stepid=(SELECT id FROM ld_approvestep WHERE approveid=@approveid AND `name`='三级审批' LIMIT 1);
		INSERT INTO ld_approvereminds(stepid,type,remindmethod,reminduser,remindcontent)
		SELECT @stepid,2,'dialog','smowner','您提交的单据未通过审批步骤{step}，原因：{description}' FROM DUAL
		WHERE NOT EXISTS (SELECT 1 FROM ld_approvereminds WHERE stepid=@stepid AND type=2);

		SET @querysql=CONCAT("CREATE TABLE IF NOT EXISTS `ld_",LOWER(tmp_modulename),"` (
			`",LOWER(tmp_modulename),"id` INT(19) NOT NULL NOT NULL AUTO_INCREMENT,
			`",LOWER(tmp_modulename),"_no` VARCHAR(100) DEFAULT NULL,
			`change_date` date DEFAULT NULL,
			`change_type` varchar(255) DEFAULT NULL,
			`smownerid` int(11) DEFAULT NULL,
			`accountid` int(11) DEFAULT NULL,
			`customform14id` int(11) DEFAULT NULL,

			`deleted` INT(19) NOT NULL DEFAULT '0',

			`approveby` INT(11) DEFAULT NULL,
			`approvestatus` VARCHAR(50) DEFAULT '未提交',
			`currentapprover` TEXT DEFAULT NULL,
			`createdtime` DATETIME DEFAULT NULL,
			`smcreatorid` INT(19) DEFAULT NULL,
			`modifiedby` INT(19) DEFAULT NULL,
			`modifiedtime` DATETIME DEFAULT NULL,
			`form14_type` varchar(50) DEFAULT NULL,

			`approvetime` DATETIME DEFAULT NULL,
			`print_times` INT(11) DEFAULT '0',
			`total` DECIMAL(25,6) DEFAULT NULL,
			`subtotal` DECIMAL(25,6) DEFAULT NULL,
			`adjustment` DECIMAL(25,6) DEFAULT NULL,
			`discount_amount` DECIMAL(25,6) DEFAULT NULL,
			`discount_percent` decimal(25,2) DEFAULT NULL,
			`discount_type` int(2) DEFAULT '0',
			`currency_id` INT(19) DEFAULT '1',
			`currency_symbol` varchar(30)  DEFAULT NULL,
			`conversion_rate` DECIMAL(25,6) DEFAULT NULL,
			`pricebooksid` INT(19)  DEFAULT NULL,
			`advance_stage` varchar(20) DEFAULT NULL,
			`approvesubmitter` INT(19) DEFAULT '0',
			`approvesubmittedtime` DATETIME DEFAULT NULL,
			`approveurgent` VARCHAR(10) DEFAULT 'no',
			`approveexpediting` VARCHAR(10) DEFAULT 'no',
			`currentapprovestepid` INT(19) DEFAULT '0',
			`team_memberid` TEXT DEFAULT NULL,
			PRIMARY KEY (`",LOWER(tmp_modulename),"id`)
		) ENGINE=InnoDB DEFAULT CHARSET=utf8;");

		SET @querysql1=CONCAT("CREATE TABLE IF NOT EXISTS `ld_",LOWER(tmp_modulename),"scf` (
			`",LOWER(tmp_modulename),"id` INT(19) NOT NULL AUTO_INCREMENT,
			PRIMARY KEY (`",LOWER(tmp_modulename),"id`)
		) ENGINE=InnoDB DEFAULT CHARSET=utf8;");

			SET @querysql2=CONCAT("CREATE TABLE IF NOT EXISTS `ld_",LOWER(tmp_modulename),"detail` LIKE ld_quoteschangedetail");

		SET @querysql3=CONCAT("CREATE TABLE IF NOT EXISTS `ld_",LOWER(tmp_modulename),"detailscf` (
			`lineitem_id` INT(19) NOT NULL DEFAULT '0',
			`sequence` INT(1) DEFAULT NULL,
			PRIMARY KEY (`lineitem_id`)
		) ENGINE=InnoDB DEFAULT CHARSET=utf8;");



		PREPARE stmt FROM @querysql;
		EXECUTE stmt;

		PREPARE stmt FROM @querysql1;
		EXECUTE stmt;

		PREPARE stmt FROM @querysql2;
		EXECUTE stmt;

		PREPARE stmt FROM @querysql3;
		EXECUTE stmt;
		DROP PREPARE stmt;



end ||
delimiter;

DROP PROCEDURE IF EXISTS `ldcrm_addBudgetChange`;
delimiter ||
CREATE  PROCEDURE `ldcrm_addBudgetChange`(
)
BEGIN
   CALL ldcrm_addnewmoudule_BudgetChange('BudgetChange','预算变更单','Budget Change',347);
end ||
delimiter;

CALL ldcrm_addBudgetChange();
DROP PROCEDURE IF EXISTS `ldcrm_addBudgetChange`;
DROP PROCEDURE IF EXISTS `ldcrm_addnewmoudule_BudgetChange`;
delimiter;


UPDATE ld_tab SET main_tablename = 'ld_budgetchange',custom_tablename='ld_budgetchangescf',primary_key = 'budgetchangeid' where name = 'BudgetChange';
delimiter;

SET @modulename ='BudgetChange';
SET @tabid=(SELECT tabid from ld_tab where name = @modulename);
SET @maxblockid=(SELECT MAX(blockid) FROM ld_blocks);
SET @blockname = 'LBL_FILE_INFORMATION';

SET @sequence = (SELECT max(sequence) from ld_blocks where tabid=@tabid);
INSERT INTO ld_blocks(blockid,tabid,blocklabel,sequence,show_title,visible,create_view,edit_view,detail_view,display_status,iscustom)
SELECT @maxblockid+1,@tabid,@blockname,@sequence+1,0,0,0,0,0,1,0 FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_blocks WHERE blocklabel=@blockname AND tabid=@tabid);

SET @blockid=(SELECT blockid FROM ld_blocks WHERE blocklabel=@blockname AND tabid=@tabid);
INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
SELECT 'zh','ld_blocks',@tabid,@blockid,'附件信息' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE tabid=@tabid AND relateid=@blockid AND languagetype='zh' and trantable='ld_blocks');
INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
SELECT 'en','ld_blocks',@tabid,@blockid,'Attachments Information' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE tabid=@tabid AND relateid=@blockid AND languagetype='en' and trantable='ld_blocks');
UPDATE ld_blocks_seq SET id=(SELECT MAX(blockid) FROM ld_blocks);

SET @relateid=@blockid;
SET @maxseq=IFNULL((SELECT MAX(sequence) FROM ld_field WHERE tabid=@tabid AND block=@relateid),0);
SET @trantable='ld_field';
SET @tablename='ld_attachments';
SET @columnname='filename';
SET @fieldname='filename';
SET @zh='附件';
SET @en='Attachments';
SET @uitype=1109;
SET @typeofdata='V~O';
SET @quickcreate=0;
SET @displaytype=1;
SET @bigtype='fileattachment';
SET @datarang=NULL;
SET @maxrowsshow=0;
SET @savedatabase = 'YES';
SET @allowedit = 'YES';
SET @maxid=(SELECT MAX(fieldid) FROM ld_field);
INSERT INTO ld_field(tabid,fieldid,columnname,tablename,generatedtype,uitype,fieldname,fieldlabel,readonly,presence,defaultvalue,maximumlength,sequence,block,displaytype,typeofdata,quickcreate,quickcreatesequence,info_type,masseditable,helpinfo,fieldonly,approve_demand,is_checkimportfield,bigtype,datarang,maxrowsshow,savedatabase,allowedit)
SELECT @tabid,@maxid+1,@columnname,@tablename,1,@uitype,@fieldname,@zh,1,0,NULL,100,@maxseq+1,@relateid,@displaytype,@typeofdata,@quickcreate,NULL,NULL,1,NULL,0,2,0,@bigtype,@datarang,@maxrowsshow,@savedatabase,@allowedit from dual
WHERE NOT EXISTS (SELECT 1 FROM ld_field WHERE tabid=@tabid AND tablename=@tablename AND columnname=@columnname);
UPDATE ld_field_seq SET id=(SELECT max(fieldid) FROM ld_field);


SET @relateid=(SELECT fieldid FROM ld_field WHERE tabid=@tabid AND columnname=@columnname LIMIT 1);
INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
SELECT 'zh',@trantable,@tabid,@relateid,@zh FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE languagetype = 'zh' AND trantable =@trantable AND tabid = @tabid AND relateid=@relateid);
INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
SELECT 'en',@trantable,@tabid,@relateid,@en FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE languagetype = 'en' AND trantable =@trantable AND tabid = @tabid AND relateid=@relateid);
delimiter;


call AddColumn('ld_budgetchangedetailscf','prosheet','varchar','20','');
delimiter;

select tabid into @tabid from ld_tab where `name`='BudgetChange';
select max(producttoolfieldid) into @maxproducttoolfieldid from ld_producttoolfield;
update ld_producttoolfield set sequence = sequence + 1000 where tabid = @tabid;
insert into ld_producttoolfield(producttoolfieldid,columnname,allowhide,fieldlabel,presence,uitype,typeofdata,sequence,tabid,tablename,width,edit_permission,input_type,fieldid,newline,
defaultcolumn,is_checkimportfield,nullfield,description)
select @maxproducttoolfieldid+1,'prosheet','no','规格型号（更换前）',0,1,'V~O~100',3,@tabid,'ld_budgetchangedetailscf',40,3,0,0,0,3,0,1,NULL from DUAL
where not exists(select 1 from ld_producttoolfield where tabid = @tabid and columnname = 'prosheet');
set @i=0;
update ld_producttoolfield set sequence=(@i:=@i+1) where tabid = @tabid order by sequence;
delimiter;

select tabid into @tabid from ld_tab where `name`='BudgetChange';
select producttoolfieldid into @producttoolfieldid from ld_producttoolfield where tabid = @tabid and columnname = 'prosheet';
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'zh','ld_producttoolfield',@tabid,@producttoolfieldid,'规格型号（更换前）' from DUAL
where not exists(select 1 from ld_tranlabel where tabid =@tabid and Relateid = @producttoolfieldid and languagetype = 'zh' and trantable = 'ld_producttoolfield');
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'en','ld_producttoolfield',@tabid,@producttoolfieldid,'ProductSheet(Before replacement)' from DUAL
where not exists(select 1 from ld_tranlabel where tabid =@tabid and Relateid = @producttoolfieldid and languagetype = 'en' and trantable = 'ld_producttoolfield');
delimiter;


call AddColumn('ld_budgetchangedetailscf','pro_id','int','11',0);
delimiter;
select tabid into @tabid from ld_tab where `name`='BudgetChange';
select max(producttoolfieldid) into @maxproducttoolfieldid from ld_producttoolfield;
update ld_producttoolfield set sequence = sequence + 1000 where tabid = @tabid;
insert into ld_producttoolfield(producttoolfieldid,columnname,allowhide,fieldlabel,presence,uitype,typeofdata,sequence,tabid,tablename,width,edit_permission,input_type,fieldid,newline,
defaultcolumn,is_checkimportfield,nullfield,description)
select @maxproducttoolfieldid+1,'pro_id','no','产品名称(变更前)',0,188,'V~M~100',1,@tabid,'ld_budgetchangedetailscf',40,1,0,0,0,3,0,1,NULL from DUAL
where not exists(select 1 from ld_producttoolfield where tabid = @tabid and columnname = 'pro_id');
set @i=0;
update ld_producttoolfield set sequence=(@i:=@i+1) where tabid = @tabid order by sequence;
delimiter;

select tabid into @tabid from ld_tab where `name`='BudgetChange';
select producttoolfieldid into @producttoolfieldid from ld_producttoolfield where tabid = @tabid and columnname = 'pro_id';
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'zh','ld_producttoolfield',@tabid,@producttoolfieldid,'产品名称（变更前）' from DUAL
where not exists(select 1 from ld_tranlabel where tabid =@tabid and Relateid = @producttoolfieldid and languagetype = 'zh' and trantable = 'ld_producttoolfield');
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'en','ld_producttoolfield',@tabid,@producttoolfieldid,'Product name(Before replacement)' from DUAL
where not exists(select 1 from ld_tranlabel where tabid =@tabid and Relateid = @producttoolfieldid and languagetype = 'en' and trantable = 'ld_producttoolfield');
delimiter;

select tabid into @tabid from ld_tab where `name`='BudgetChange';
select producttoolfieldid into @producttoolfieldid from ld_producttoolfield where tabid = @tabid and columnname = 'productname';
update ld_tranlabel set fieldlabel = '产品名称（更换后）' where tabid= @tabid and Relateid = @producttoolfieldid and languagetype = 'zh' and trantable = 'ld_producttoolfield';
update ld_tranlabel set fieldlabel = 'Product name(After replacement)' where tabid= @tabid and Relateid = @producttoolfieldid and languagetype = 'en' and trantable = 'ld_producttoolfield';
delimiter;

select tabid into @tabid from ld_tab where `name` = 'CustomForm14';
SELECT tabid into @related_tabid from ld_tab where name='BudgetChange';
select sequence into @sequence from ld_relatedlists where tabid= @tabid and `name` ='get_viewhistory';
select max(relation_id) into @maxrelation_id from ld_relatedlists;
update ld_relatedlists set sequence = sequence + 1000 where tabid = @tabid and sequence > @sequence;
insert into ld_relatedlists(relation_id, tabid,related_tabid,name,sequence,label,presence,actions,related_coltable,type)
select @maxrelation_id+1,@tabid,@related_tabid,'get_budgetchange',@sequence+1,'BudgetChange',0,'approvedadd','BudgetChange.customform14id','datacategory_sql' from dual
where not EXISTS(select 1 from ld_relatedlists where tabid=@tabid and related_tabid=@related_tabid and name='get_quoteschange');
set @i=0;
update ld_relatedlists set sequence=(@i:=@i+1) where tabid = @tabid order by sequence;
delimiter;

UPDATE ld_relatedlists_seq SET id=(SELECT MAX(relation_id) FROM ld_relatedlists);
delimiter;


insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','How_to_create_budgetchange','如何创建{$BudgetChange.BudgetChange}','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype = 'zh' and labelbol = 'How_to_create_budgetchange' and labeltype = 'fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','How_to_create_budgetchange','How to create a{$BudgetChange.BudgetChange}','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype = 'en' and labelbol = 'How_to_create_budgetchange' and labeltype = 'fixedstr');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','How_to_create_budgetchange_infos','{$BudgetChange.BudgetChange}是针对{$CustomForm14.CustomForm14}的，不允许直接新增，可通过{$CustomForm14.CustomForm14}关联新建。','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype = 'zh' and labelbol = 'How_to_create_budgetchange_infos' and labeltype = 'fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','How_to_create_budgetchange_infos','{$BudgetChange.BudgetChange} is for the {$CustomForm14.CustomForm14},direct creation is not allowed;You can create it by {$Quotes.Quotes}.','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype = 'en' and labelbol = 'How_to_create_budgetchange_infos' and labeltype = 'fixedstr');
delimiter;

SET @modulename = 'BudgetChange';
INSERT INTO ld_relatecreatecondition(modulename,columnname,comparator,content,relatecreatemodule,sequence,contenttype)
SELECT 'Products','productid','','ld_products.productcategory=\'{$BudgetChange.form14_type}\'',@modulename,1,'sql' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_relatecreatecondition WHERE modulename='Products' AND relatecreatemodule=@modulename AND columnname='productid');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','port','端口','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='port' and labeltype='fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','port',"Rule comments",'fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='port' and labeltype='fixedstr');
delimiter;

SET @labelbol = 'SETEFFECTIVECONDITIONS';
SET @labeltype = 'fixedstr';
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'zh',@labelbol,'设置控制生效条件',@labeltype FROM DUAL 
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol=@labelbol and Labeltype=@labeltype);
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'en',@labelbol,'Effective conditions',@labeltype FROM DUAL 
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol=@labelbol and Labeltype=@labeltype);
delimiter;

CALL AddColumn('ld_option_module','effectivecondition','text','','');
delimiter;

UPDATE ld_desk SET fieldlabel = '勾选失败，请前往系统设置->接口设置->短信账户设置添加短信账户！' where labelbol = 'ifyoufailpleasesetupashort' and languagetype = 'zh' and Labeltype = 'jspop';
UPDATE ld_desk SET fieldlabel = 'Check failed, please go to system settings - > interface settings - > SMS account settings to add SMS account!' where labelbol = 'ifyoufailpleasesetupashort' and languagetype = 'en' and Labeltype = 'jspop';
delimiter;

UPDATE ld_approvestep SET ended = 1 where concurrentid>0;
delimiter;


call AddColumn('ld_field','createdtime','datetime','','');
ALTER TABLE `ld_field` MODIFY COLUMN `createdtime` TIMESTAMP NULL DEFAULT CURRENT_TIMESTAMP;
delimiter;

call AddColumn('ld_field','modifiedtime','datetime','','');
ALTER TABLE `ld_field` MODIFY COLUMN `modifiedtime` TIMESTAMP NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP;
delimiter;

UPDATE ld_field SET createdtime = NOW() WHERE IFNULL(createdtime,'') = '';
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','FieldList','字段列表','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='FieldList' and labeltype='fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','FieldList','field list','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='FieldList' and labeltype='fixedstr');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','SearchPleaseEnter','请输入字段名称','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='SearchPleaseEnter' and labeltype='fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','SearchPleaseEnter','Please enter a field name','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='SearchPleaseEnter' and labeltype='fixedstr');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','DatabaseFieldName','数据库字段名称','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='DatabaseFieldName' and labeltype='fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','DatabaseFieldName','Database field name','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='DatabaseFieldName' and labeltype='fixedstr');
delimiter;
-- 2021-03-11

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

UPDATE ld_version SET old_version='V8.4.5.9',current_version='V8.4.5.9',remark='V8.4.5.9-20220314',wx_version='V8.4.5.9';
delimiter;