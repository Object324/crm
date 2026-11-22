DROP PROCEDURE IF EXISTS `ldcrm_resetmodule_20180223`;
delimiter ||
CREATE PROCEDURE `ldcrm_resetmodule_20180223`( 

)
BEGIN 

	IF NOT EXISTS (SELECT 1 FROM ld_version_firstlogin) THEN
			UPDATE ld_tab SET presence=5 WHERE `name`='ReportLog' AND presence=0;
			DELETE FROM ld_parenttabrel WHERE parenttabid=1 AND tabid=(SELECT tabid FROM ld_tab WHERE `name`='ReportLog');
			DELETE FROM ld_parenttabrel WHERE  parenttabid=1 AND tabid<>3;

			SET @parenttabid=(SELECT parenttabid FROM ld_parenttab WHERE parenttab_label='Tools' LIMIT 1);
			SET @seq=(SELECT MAX(sequence) FROM ld_parenttabrel WHERE parenttabid=@parenttabid);
			SET @tabid=9;
			INSERT INTO ld_parenttabrel(parenttabid,tabid,sequence)
			SELECT @parenttabid,@tabid,@seq+1 FROM DUAL
			WHERE NOT EXISTS(SELECT 1 FROM ld_parenttabrel WHERE parenttabid=@parenttabid AND tabid=@tabid);

			SET @seq=(SELECT MAX(sequence) FROM ld_parenttabrel WHERE parenttabid=@parenttabid);
			SET @tabid=10;
			INSERT INTO ld_parenttabrel(parenttabid,tabid,sequence)
			SELECT @parenttabid,@tabid,@seq+1 FROM DUAL
			WHERE NOT EXISTS(SELECT 1 FROM ld_parenttabrel WHERE parenttabid=@parenttabid AND tabid=@tabid);

			SET @seq=(SELECT MAX(sequence) FROM ld_parenttabrel WHERE parenttabid=@parenttabid);
			SET @tabid=8;
			INSERT INTO ld_parenttabrel(parenttabid,tabid,sequence)
			SELECT @parenttabid,@tabid,@seq+1 FROM DUAL
			WHERE NOT EXISTS(SELECT 1 FROM ld_parenttabrel WHERE parenttabid=@parenttabid AND tabid=@tabid);

			SET @seq=(SELECT MAX(sequence) FROM ld_parenttabrel WHERE parenttabid=@parenttabid);
			SET @tabid=15;
			INSERT INTO ld_parenttabrel(parenttabid,tabid,sequence)
			SELECT @parenttabid,@tabid,@seq+1 FROM DUAL
			WHERE NOT EXISTS(SELECT 1 FROM ld_parenttabrel WHERE parenttabid=@parenttabid AND tabid=@tabid);

			SET @seq=(SELECT MAX(sequence) FROM ld_parenttabrel WHERE parenttabid=@parenttabid);
			SET @tabid=(SELECT tabid FROM ld_tab WHERE `name`='Attachment' LIMIT 1);
			INSERT INTO ld_parenttabrel(parenttabid,tabid,sequence)
			SELECT @parenttabid,@tabid,@seq+1 FROM DUAL
			WHERE NOT EXISTS(SELECT 1 FROM ld_parenttabrel WHERE parenttabid=@parenttabid AND tabid=@tabid);
			
	END IF;

end ||
delimiter;

CALL ldcrm_resetmodule_20180223();
DROP PROCEDURE IF EXISTS `ldcrm_resetmodule_20180223`;
-- 2018-02-23

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','NODUPRECORDS','没有重复记录！','jspop' from dual
where not exists(select 1 from ld_desk where languagetype = 'zh' and labelbol = 'NODUPRECORDS' and labeltype = 'jspop');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','NODUPRECORDS','No Duplicate Records!','jspop' from dual
where not exists(select 1 from ld_desk where languagetype = 'en' and labelbol = 'NODUPRECORDS' and labeltype = 'jspop');
delimiter;

select tabid into @tabid from ld_tab where `name` = 'Accounts';
select tabid into @related_tabid from ld_tab where `name` = 'BusinessApply';
select max(relation_id) into @relation_id from ld_relatedlists;
select max(sequence),max(wx_sequence) into @sequence,@wx_sequence from ld_relatedlists where tabid = @tabid;
insert into ld_relatedlists(relation_id,tabid,related_tabid,`name`,sequence,label,presence,actions,mobile_presence,mobile_sequence,type,related_coltable,wx_presence,wx_sequence,trade)
select @relation_id+1,@tabid,@related_tabid,'get_businessapply',@sequence+1,'BusinessApply',1,'add',1,@sequence+1,'datacategory_sql','businessapply.accountid',1,@wx_sequence+1,NULL from DUAL
where not EXISTS(select 1 from ld_relatedlists where tabid =@tabid and related_tabid = @related_tabid);
delimiter;


SET @modulename='Contacts';
SET @tabid=(SELECT tabid FROM ld_tab WHERE `name`=@modulename);
SET @blockid=(SELECT block FROM ld_field WHERE tabid=@tabid AND columnname='qq');
SET @tablename=(SELECT tablename FROM ld_field WHERE tabid=@tabid AND columnname='qq');
SET @columnname='wx';
SET @fieldname='wx';
SET @zh='微信号';
SET @en='WeChat';
SET @uitype=1;
SET @readonly=1;
SET @presence=2;
SET @defaultvalue=NULL;
SET @displaytype=1;
SET @typeofdata='V~O';
SET @quickcreate=1;
SET @quickcreatesequence=NULL;
SET @info_type='BAS';
SET @masseditable=1;
  
SET @seq=(SELECT MAX(sequence) FROM ld_field WHERE tabid=@tabid and block=@blockid);
SET @fieldid=(SELECT MAX(fieldid) FROM ld_field);

INSERT INTO ld_field(tabid,fieldid,columnname,tablename,generatedtype,uitype,fieldname,fieldlabel,readonly,presence,defaultvalue,maximumlength,sequence,block,displaytype,typeofdata,quickcreate,quickcreatesequence,info_type,masseditable,helpinfo,fieldonly)
SELECT @tabid,@fieldid+1,@columnname,@tablename,1,@uitype,@fieldname,@zh,@readonly,@presence,@defaultvalue,100,@seq+1,@blockid,@displaytype,@typeofdata,@quickcreate,@quickcreatesequence,@info_type,@masseditable,NULL,0 FROM DUAL 
WHERE NOT EXISTS (SELECT 1 FROM ld_field WHERE tabid=@tabid AND tablename=@tablename AND columnname=@columnname);

UPDATE ld_field_seq SET id=(SELECT max(fieldid) FROM ld_field);

SET @fieldid=(SELECT fieldid FROM ld_field WHERE tabid=@tabid AND columnname=@columnname);
INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
SELECT 'zh','ld_field',@tabid,@fieldid,@zh FROM DUAL 
WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE languagetype = 'zh' AND trantable ='ld_field' AND tabid = @tabid AND relateid=@fieldid);

INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
SELECT 'en','ld_field',@tabid,@fieldid,@en FROM DUAL  
WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE languagetype = 'en' AND trantable ='ld_field' AND tabid = @tabid AND relateid=@fieldid);

CALL AddColumn(@tablename,@columnname,'VARCHAR','100',NULL);
CALL getallprofile(@modulename);
CALL fieldprofile(@modulename);
delimiter;



SET @modulename='Accounts';
SET @tabid=(SELECT tabid FROM ld_tab WHERE `name`=@modulename);
SET @columnname='department';
SET @fieldname='department';
SET @tablename='ld_contactdetails';
SET @zh='联系人部门';
SET @en='Department';
SET @blockid=(SELECT block FROM ld_field WHERE tabid=@tabid AND columnname='qq' AND tablename='ld_contactscf' LIMIT 1);
SET @uitype=1;
SET @readonly=1;
SET @presence=2;
SET @defaultvalue=NULL;
SET @displaytype=1;
SET @typeofdata='V~O';
SET @quickcreate=1;
SET @quickcreatesequence=NULL;
SET @info_type='BAS';
SET @masseditable=1;
SET @seq=(SELECT MAX(sequence) FROM ld_field WHERE tabid=@tabid AND block=@block);

SET @fieldid=(SELECT MAX(fieldid) FROM ld_field);
INSERT INTO ld_field(tabid,fieldid,columnname,tablename,generatedtype,uitype,fieldname,fieldlabel,readonly,presence,defaultvalue,maximumlength,sequence,block,displaytype,typeofdata,quickcreate,quickcreatesequence,info_type,masseditable,helpinfo,fieldonly)
SELECT @tabid,@fieldid+1,@columnname,@tablename,1,@uitype,@fieldname,@zh,@readonly,@presence,@defaultvalue,100,@seq+1,@blockid,@displaytype,@typeofdata,@quickcreate,@quickcreatesequence,@info_type,@masseditable,NULL,0 FROM DUAL 
WHERE NOT EXISTS (SELECT 1 FROM ld_field WHERE tabid=@tabid AND tablename=@tablename AND columnname=@columnname);

SET @fieldid=(SELECT fieldid FROM ld_field WHERE tabid=@tabid AND columnname=@columnname);
INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
SELECT 'zh','ld_field',@tabid,@fieldid,@zh FROM DUAL 
WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE languagetype = 'zh' AND trantable ='ld_field' AND tabid = @tabid AND relateid=@fieldid);

INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
SELECT 'en','ld_field',@tabid,@fieldid,@en FROM DUAL  
WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE languagetype = 'en' AND trantable ='ld_field' AND tabid = @tabid AND relateid=@fieldid);


SET @modulename='Accounts';
SET @tabid=(SELECT tabid FROM ld_tab WHERE `name`=@modulename);
SET @columnname='wx';
SET @fieldname='wx';
SET @tablename='ld_contactscf';
SET @zh='联系人微信';
SET @en='Wechat';
SET @blockid=(SELECT block FROM ld_field WHERE tabid=@tabid AND columnname='qq' AND tablename='ld_contactscf' LIMIT 1);
SET @uitype=1;
SET @readonly=1;
SET @presence=2;
SET @defaultvalue=NULL;
SET @displaytype=1;
SET @typeofdata='V~O';
SET @quickcreate=1;
SET @quickcreatesequence=NULL;
SET @info_type='BAS';
SET @masseditable=1;
SET @seq=(SELECT MAX(sequence) FROM ld_field WHERE tabid=@tabid AND block=@block);

SET @fieldid=(SELECT MAX(fieldid) FROM ld_field);
INSERT INTO ld_field(tabid,fieldid,columnname,tablename,generatedtype,uitype,fieldname,fieldlabel,readonly,presence,defaultvalue,maximumlength,sequence,block,displaytype,typeofdata,quickcreate,quickcreatesequence,info_type,masseditable,helpinfo,fieldonly)
SELECT @tabid,@fieldid+1,@columnname,@tablename,1,@uitype,@fieldname,@zh,@readonly,@presence,@defaultvalue,100,@seq+1,@blockid,@displaytype,@typeofdata,@quickcreate,@quickcreatesequence,@info_type,@masseditable,NULL,0 FROM DUAL 
WHERE NOT EXISTS (SELECT 1 FROM ld_field WHERE tabid=@tabid AND tablename=@tablename AND columnname=@columnname);

SET @fieldid=(SELECT fieldid FROM ld_field WHERE tabid=@tabid AND columnname=@columnname);
INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
SELECT 'zh','ld_field',@tabid,@fieldid,@zh FROM DUAL 
WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE languagetype = 'zh' AND trantable ='ld_field' AND tabid = @tabid AND relateid=@fieldid);

INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
SELECT 'en','ld_field',@tabid,@fieldid,@en FROM DUAL  
WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE languagetype = 'en' AND trantable ='ld_field' AND tabid = @tabid AND relateid=@fieldid);

UPDATE ld_field_seq SET id=(SELECT max(fieldid) FROM ld_field);

CALL getallprofile(@modulename);
CALL fieldprofile(@modulename);
delimiter;

UPDATE ld_field SET presence=1 WHERE tabid=6 AND columnname IN ('qq','wx') AND tablename='ld_contactscf';
UPDATE ld_field SET presence=1 WHERE tabid=6 AND columnname IN ('department') AND tablename='ld_contactdetails';
-- 2018-02-24

UPDATE ld_profile2field 
INNER JOIN ld_field ON ld_field.fieldid = ld_profile2field.fieldid
INNER JOIN ld_tab ON ld_tab.tabid = ld_field.tabid 
SET visible = 0 WHERE ld_tab.`name` IN ('SalesOrder','Invoice') AND ld_field.columnname = 'description' AND uitype = 69;
delimiter;

select max(wx_sequence) into @sequence from ld_dashboard_app;
insert into ld_dashboard_app(`name`,labelbol,modulenames,image,presence,wx_presence,wx_sequence)
select 'Accountleadsource','CUSTOMERSOURCEDISSTATIST','Accounts','dashboard_10',2,1,@sequence+1
from dual where not exists(select 1 from ld_dashboard_app where name='Accountleadsource');
delimiter;
select max(wx_sequence) into @sequence from ld_dashboard_app;
insert into ld_dashboard_app(`name`,labelbol,modulenames,image,presence,wx_presence,wx_sequence)
select 'Accountaccounttype','CUSTOMERTYPEDISSTATIS','Accounts','dashboard_10',2,1,@sequence+1
from dual where not exists(select 1 from ld_dashboard_app where name='Accountaccounttype');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','thisstephasbeendeleted','审批流程中该步骤已删除','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype = 'zh' and labelbol = 'thisstephasbeendeleted' and labeltype = 'fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','thisstephasbeendeleted','This step has been deleted in the approval process','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype = 'en' and labelbol = 'thisstephasbeendeleted' and labeltype = 'fixedstr');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','THE_PASSWORD','密码和确认密码不一致！','jspop' from dual
where not exists(select 1 from ld_desk where languagetype = 'zh' and labelbol = 'THE_PASSWORD' and labeltype = 'jspop');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','THE_PASSWORD','Password and Confirm Password inconsistency!','jspop' from dual
where not exists(select 1 from ld_desk where languagetype = 'en' and labelbol = 'THE_PASSWORD' and labeltype = 'jspop');
delimiter;

select sequence,roottype into @sequence,@roottype from ld_systems_deploy  where deploy_type=152 ;
update ld_systems_deploy set sequence=sequence+1000 where roottype=@roottype and sequence>@sequence;
insert into ld_systems_deploy(deploy_value,deploy_type,description,setype,sequence,roottype,inputtype,presence,inputvalue)
select '1',159,'设置客户和服务收费管理是否显示自动匹配的工商查询客户列表','',@sequence,@roottype,'select',0,'[{"value":"0","text":"YES"},{"value":"1","text":"NO"},{"sql":""}]'
from dual where not exists(select 1 from ld_systems_deploy where roottype=@roottype and deploy_type=159);
set @i=0;
update ld_systems_deploy set sequence=(@i:=@i+1) where roottype = @roottype order by sequence;
delimiter;

insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'zh','ld_systems_deploy',159,159,'设置{$Accounts.Accounts}和{$ServiceCharge.ServiceCharge}是否显示自动匹配的工商查询客户列表' from DUAL
where not exists(select 1 from ld_tranlabel where languagetype='zh' and trantable='ld_systems_deploy' and relateid=159 and tabid = 159);
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'en','ld_systems_deploy',159,159,'Set up {$Accounts.Accounts} and {$ServiceCharge.ServiceCharge} charge management to show automatically matched business query customer list' from DUAL
where not exists(select 1 from ld_tranlabel where languagetype='en' and trantable='ld_systems_deploy' and relateid=159 and tabid = 159);
delimiter;

select tabid into @tabid from ld_tab where `name` = 'ModComments';
update ld_field set uitype = 112 where tabid = @tabid and uitype = 10 and columnname = 'related_to';
delimiter;

select tabid into @tabid from ld_tab where `name` = 'Reminds';
update ld_field set uitype = 112 where tabid = @tabid and uitype = 10 and columnname = 'related_to';
delimiter;

select tabid into @tabid from ld_tab where `name` = 'Quotes';
delete from ld_tranlabel where tabid = @tabid and trantable = 'ld_field' and Relateid in (
	select fieldid from ld_field where tabid = @tabid and tablename = 'ld_quotesbillads');
delete from ld_field where tablename = 'ld_quotesbillads' and tabid = @tabid;
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','visiblerangsettings','可见范围内设置','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype = 'zh' and labelbol = 'visiblerangsettings' and labeltype = 'fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','visiblerangsettings','Visible range settings','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype = 'en' and labelbol = 'visiblerangsettings' and labeltype = 'fixedstr');
delimiter;

DROP PROCEDURE IF EXISTS `ldcrm_resettoobar_20180301`;
delimiter ||
CREATE PROCEDURE `ldcrm_resettoobar_20180301`( 
)
BEGIN 

	SET @tabid=(SELECT tabid FROM ld_tab WHERE `name`='ChinaMap');
	IF NOT EXISTS (SELECT 1 FROM ld_parenttabrel WHERE tabid=@tabid) THEN
		INSERT INTO ld_parenttabrel(parenttabid,tabid,sequence)
		SELECT 3,@tabid,(SELECT MAX(sequence)+1 FROM ld_parenttabrel WHERE parenttabid=3);

		UPDATE ld_tab SET presence=5 WHERE `name`='ChinaMap';
	END IF;

end ||
delimiter;

CALL ldcrm_resettoobar_20180301();
DROP PROCEDURE IF EXISTS `ldcrm_resettoobar_20180301`;
delimiter;

DROP PROCEDURE IF EXISTS `ldcrm_resetguiji_20180301`;
delimiter ||
CREATE PROCEDURE `ldcrm_resetguiji_20180301`( 

)
BEGIN 

	IF NOT EXISTS (SELECT 1 FROM ld_version_firstlogin) OR DATABASE() LIKE 'wx1%' THEN
			SET @fieldid=(SELECT fieldid FROM ld_field WHERE tabid=29 AND columnname='trackgroupid');
			DELETE FROM ld_tranlabel WHERE tabid=29 AND Relateid=@fieldid AND trantable='ld_field';

			DELETE FROM ld_settings_field WHERE `name`='TRACKPOSITONINGGROUP';
			DELETE FROM ld_usereport WHERE `name`='USERTRACKREPORT';
	END IF;

end ||
delimiter;

CALL ldcrm_resetguiji_20180301();
DROP PROCEDURE IF EXISTS `ldcrm_resetguiji_20180301`;

CALL AddColumn('ld_account_set','usersaccount_type','varchar','100',NULL);
UPDATE ld_account_set set usersaccount_type=if(`status` = 0,'user','all') where usersaccount_type is NULL;
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','managecustomview','管理数据分类','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype = 'zh' and labelbol = 'managecustomview' and labeltype = 'fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','managecustomview','Manage customview','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype = 'en' and labelbol = 'managecustomview' and labeltype = 'fixedstr');
delimiter;


insert into ld_actionmapping(actionid,actionname,securitycheck,actionlabel)
select 37,'CustomView',0,'managecustomview' from dual
where not exists(select 1 from ld_actionmapping where actionname = 'CustomView' and actionlabel = 'managecustomview');
delimiter;

DROP PROCEDURE IF EXISTS `addProfileallpermission`;
delimiter ||
CREATE  PROCEDURE `addProfileallpermission`(
	IN `actionid` int(11)
)
BEGIN
	declare done  int  default 0;
	declare is_tabid int;

	declare cur1 CURSOR FOR select tabid from ld_profileallpermission where operation = 4;

	declare continue handler  for not found SET done =1;

	OPEN cur1;
	Fetch cur1 into is_tabid;
	 loop1: while  done<>1 DO
			
		  select max(sequence) into @sequence from ld_profileallpermission where tabid = is_tabid;
			insert into ld_profileallpermission(tabid,operation,sequence)
			select is_tabid,actionid,@sequence+1 from DUAL where not exists(select 1 from ld_profileallpermission where tabid = is_tabid and operation = actionid);
			if is_tabid = 9 then  
				set is_tabid = 16;
			end if;
			call addProfile2standardpermissions(is_tabid,actionid);
	Fetch cur1 into is_tabid;
	end while loop1;
	close cur1;
end ||
delimiter;

DROP PROCEDURE IF EXISTS `addProfile2standardpermissions`;
delimiter ||
CREATE  PROCEDURE `addProfile2standardpermissions`(
	IN `is_tabid` int(11),IN `is_actionid` int(11)
)
BEGIN
	declare done  int  default 0;
	declare is_profileid int;

	declare cur1 CURSOR FOR select profileid from ld_profile2standardpermissions where tabid = is_tabid GROUP BY profileid;

	declare continue handler  for not found SET done =1;

	OPEN cur1;
	Fetch cur1 into is_profileid;
	 loop1: while  done<>1 DO
			
		  select max(sequence) into @sequence from ld_profile2standardpermissions where profileid = is_profileid;
			insert into ld_profile2standardpermissions(profileid,tabid,operation,permissions,sequence)
			select is_profileid,is_tabid,is_actionid,0,@sequence+1 from DUAL 
			where not exists(select 1 from ld_profile2standardpermissions where tabid = is_tabid and operation = is_actionid and profileid = is_profileid);
 
	Fetch cur1 into is_profileid;
	end while loop1;
	close cur1;
end ||
delimiter;

call addProfileallpermission(37);
delimiter;

DROP PROCEDURE IF EXISTS `addProfileallpermission`;
DROP PROCEDURE IF EXISTS `addProfile2standardpermissions`;
DROP PROCEDURE IF EXISTS `addProfileallpermission`;

update ld_desk set fieldlabel = '管理分类' where labelbol = 'managecustomview' and languagetype = 'zh' and Labeltype = 'fixedstr';
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','SUREDELETEDATABASERECORDS','您确定要从数据库中永久删除这些记录？','jspop' from dual
where not exists(select 1 from ld_desk where languagetype = 'zh' and labelbol = 'SUREDELETEDATABASERECORDS' and labeltype = 'jspop');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','SUREDELETEDATABASERECORDS','Are you sure you want to permanently delete database records?','jspop' from dual
where not exists(select 1 from ld_desk where languagetype = 'en' and labelbol = 'SUREDELETEDATABASERECORDS' and labeltype = 'jspop');
delimiter;
-- 2018-03-01

DROP PROCEDURE IF EXISTS `ldcrm_resetpublicaccount_20180302`;
delimiter ||
CREATE PROCEDURE `ldcrm_resetpublicaccount_20180302`( 

)
BEGIN 

	IF NOT EXISTS (SELECT 1 FROM ld_version_firstlogin) AND EXISTS (SELECT DATABASE() LIKE 'wx1%') THEN
			UPDATE ld_account_set SET `status`=0,dataprofile=0,wheathershow=1 WHERE `status`=1;
	END IF;

end ||
delimiter;

CALL ldcrm_resetpublicaccount_20180302();
DROP PROCEDURE IF EXISTS `ldcrm_resetpublicaccount_20180302`;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','CANOTEMPTYGTH','不能为空！','jspop' from dual
where not exists(select 1 from ld_desk where languagetype = 'zh' and labelbol = 'CANOTEMPTYGTH' and labeltype = 'jspop');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','CANOTEMPTYGTH','can not be empty!','jspop' from dual
where not exists(select 1 from ld_desk where languagetype = 'en' and labelbol = 'CANOTEMPTYGTH' and labeltype = 'jspop');
delimiter;
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','LBL_Optionalmodule_Customization_Description1','设置关联单据可选模块的范围','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype = 'zh' and labelbol = 'LBL_Optionalmodule_Customization_Description1' and labeltype = 'fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','LBL_Optionalmodule_Customization_Description1','Setting the optional module of related module','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype = 'en' and labelbol = 'LBL_Optionalmodule_Customization_Description1' and labeltype = 'fixedstr');
delimiter;
update ld_desk set fieldlabel='所选范围提交的单据将通过当前审批流程进行审批' where labelbol='DOCSELECTROLEAPPROVAL' and Labeltype='fixedstr' and languagetype='zh';
delimiter;
-- 2018-03-06

update ld_desk set fieldlabel='当前流水号不能为空！' where labelbol='STARTINGNUMCANOTEMPTY' and Labeltype='jspop' and languagetype='zh';
update ld_desk set fieldlabel='当前流水号应该为数字！' where labelbol='STARTINGNUMSHOULDNUMERIC' and Labeltype='jspop' and languagetype='zh';
delimiter;

alter table ld_warehouse2products modify column productqty decimal(25,8);
delimiter;

update ld_related_field
INNER JOIN(
	select fieldid from ld_field where uitype = 96
) as tmp on tmp.fieldid = ld_related_field.effect_fieldid
set ld_related_field.curmodule_columninfo = 'contact_id,vendorcontact_name' where ld_related_field.curmodule_columninfo != '';
delimiter;


CREATE TABLE IF NOT EXISTS `ld_appuiset` (
  `userid` int(11) NOT NULL DEFAULT '0',
  `setname` varchar(100) DEFAULT NULL,
  `settype` varchar(100) DEFAULT NULL,
  `apptype` varchar(100) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
delimiter;

DROP PROCEDURE IF EXISTS `ldcrm_initial_appuiset`;
delimiter ||
CREATE PROCEDURE `ldcrm_initial_appuiset`(
)
BEGIN
	IF EXISTS (SELECT 1 FROM information_schema.TABLES WHERE TABLE_SCHEMA=DATABASE() AND TABLE_NAME='ld_wxmoduleset') THEN
		insert into ld_appuiset(`userid`,`setname`,`settype`,`apptype`)
		select userid,modulename,'module','weixin' from ld_wxmoduleset;
		drop table ld_wxmoduleset;
	END IF;
	IF EXISTS (SELECT 1 FROM information_schema.TABLES WHERE TABLE_SCHEMA=DATABASE() AND TABLE_NAME='ld_appmoduleset') THEN
		insert into ld_appuiset(`userid`,`setname`,`settype`,`apptype`)
		select userid,modulename,'module','app' from ld_appmoduleset;
		drop table ld_appmoduleset;
	END IF;
end ||
delimiter;

CALL ldcrm_initial_appuiset();
CALL AddColumn('ld_dashboard_app','kehu001_presence','int','11','');
CALL AddColumn('ld_dashboard_app','kehu001_sequence','int','11','');

update ld_dashboard_app set kehu001_presence=wx_presence,kehu001_sequence=wx_sequence;
update ld_dashboard_app set kehu001_presence=0 where name in('daylog','weeklog','monthlog');
update ld_dashboard_app set kehu001_sequence=kehu001_sequence+1 where kehu001_sequence>=3;
update ld_dashboard_app set kehu001_sequence=3 where name='Salessituation';
set @i=0;
update ld_dashboard_app set kehu001_sequence=(@i:=@i+1) where kehu001_presence=1 order by kehu001_sequence;
delimiter;
-- 2018-03-12


update ld_desk set fieldlabel='在{$PurchaseOrder.PurchaseOrder}序时簿先找到需要退货的订单，在订单查看界面单击左侧相关信息“{$PurchaseBack.PurchaseBack}”操作按钮“新建”即可' where labelbol='RETURNPURCHASE2' and Labeltype='fixedstr' and languagetype='zh';
update ld_desk set fieldlabel='In the order of purchase order, the book first finds the order that needs to be returned. At the order view interface, click the relevant information on the left side, "purchase return order" button, "newly-built".' where labelbol='RETURNPURCHASE2' and Labeltype='fixedstr' and languagetype='en';
update ld_desk set fieldlabel='在{$SalesOrder.SalesOrder}序时簿先找到需要退货的订单，在订单查看界面单击左侧相关信息“{$SalesBack.SalesBack}”操作按钮“新建”即可' where labelbol='wsfftntroboiotstroictbhrt' and Labeltype='fixedstr' and languagetype='zh';
update ld_desk set fieldlabel='In the order order, the book first finds the order that needs to be returned. At the order view interface, click the relevant information on the left side, "sales return order" button, "newly-built".' where labelbol='wsfftntroboiotstroictbhrt' and Labeltype='fixedstr' and languagetype='en';
delimiter;

UPDATE ld_field SET fieldname='userlevel' WHERE tabid=29 AND columnname='level';

CREATE TABLE IF NOT EXISTS `ld_picklist_set` (
  `listid` INT(11) AUTO_INCREMENT,
  `listname` varchar(100) NOT NULL,
  `relatetable` VARCHAR(100) DEFAULT NULL,
  `parent_listname` varchar(100) DEFAULT NULL,
  `parent_relatetable` VARCHAR(100) DEFAULT NULL,
  PRIMARY KEY (`listid`)
) ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=utf8;
delimiter;

CREATE TABLE IF NOT EXISTS `ld_picklist_values` (
  `id` INT(11) UNSIGNED PRIMARY KEY AUTO_INCREMENT,
  `listid` INT(11),
  `listvalue` VARCHAR(200) DEFAULT NULL,
  `sequence` INT(11) DEFAULT NULL,
  `scores` DECIMAL(25,2) DEFAULT NULL,
  `weight` DECIMAL(25,2) DEFAULT NULL,
  `utrc_type` VARCHAR(100) DEFAULT NULL,
  `subjectcode` VARCHAR(100) DEFAULT NULL,
  `subjectsummary` VARCHAR(200) DEFAULT NULL,
  KEY `picklist_values_listid` (`listid`) USING BTREE,
  KEY `picklist_values_sequence` (`sequence`) USING BTREE
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
delimiter;


DROP PROCEDURE IF EXISTS `ldcrm_picklist_DROPTABLE`;
delimiter ||
CREATE PROCEDURE `ldcrm_picklist_DROPTABLE`(
  listname varchar(100)
)
  BEGIN

    SET @sqlstr = CONCAT("DROP TABLE IF EXISTS ld_",listname);
    PREPARE stmt1 FROM @sqlstr;
    EXECUTE stmt1;

    SET @sqlstr = CONCAT("DROP TABLE IF EXISTS ld_",listname,"_seq");
    PREPARE stmt1 FROM @sqlstr;
    EXECUTE stmt1;

    DEALLOCATE PREPARE stmt1;

  end ||
delimiter;

DROP PROCEDURE IF EXISTS `ldcrm_initial_picklist_field`;
delimiter ||
CREATE PROCEDURE `ldcrm_initial_picklist_field`(
)
  BEGIN

    DECLARE tmp_listname varchar(100) DEFAULT 0;

    DECLARE MYCUSOR CURSOR FOR SELECT DISTINCT fieldname FROM ld_field WHERE uitype=15 AND fieldname NOT IN ('projectid','projecttaskid','projectmilestoneid','servicecontractsid') ORDER BY fieldname;
    DECLARE CONTINUE HANDLER FOR SQLSTATE '02000' SET tmp_listname = NULL;

    IF NOT EXISTS (SELECT 1 FROM ld_picklist_set WHERE relatetable='ld_field') THEN
      OPEN MYCUSOR;
      FETCH MYCUSOR INTO tmp_listname;
      WHILE (tmp_listname IS NOT NULL) DO
        IF tmp_listname='expensetype' THEN
          INSERT INTO ld_picklist_set(listname,relatetable,parent_listname,parent_relatetable)
            SELECT tmp_listname,'ld_field',tmp_listname,'ld_tabdetailfield';

        ELSEIF tmp_listname IN ('productcategory','bill_city') THEN
          INSERT INTO ld_picklist_set(listname,relatetable)
            SELECT tmp_listname,'ld_field';

					IF EXISTS (SELECT 1 FROM information_schema.TABLES WHERE TABLE_SCHEMA=DATABASE() AND TABLE_NAME=CONCAT('ld_',tmp_listname)) THEN
						SET @i=0;
						SET @listid=(SELECT listid FROM ld_picklist_set WHERE listname=tmp_listname AND relatetable='ld_field' LIMIT 1);
						SET @sqlstr = CONCAT("INSERT INTO ld_picklist_values(listid,listvalue,sequence,scores) ",
																 "SELECT ",@listid,",",tmp_listname,",(@i:=@i+1),scores ",
																 "FROM ld_",tmp_listname," ",
																 "ORDER BY picklist_valueid");

						PREPARE stmt1 FROM @sqlstr;
						EXECUTE stmt1;
						DEALLOCATE PREPARE stmt1;

						CALL ldcrm_picklist_DROPTABLE(tmp_listname);
					END IF;

        ELSEIF tmp_listname IN ('ticketcategories','servicetype','projecttasktype') THEN
          INSERT INTO ld_picklist_set(listname,relatetable)
            SELECT tmp_listname,'ld_field';
					
					IF EXISTS (SELECT 1 FROM information_schema.TABLES WHERE TABLE_SCHEMA=DATABASE() AND TABLE_NAME=CONCAT('ld_',tmp_listname)) THEN
						SET @i=0;
						SET @listid=(SELECT listid FROM ld_picklist_set WHERE listname=tmp_listname AND relatetable='ld_field' LIMIT 1);
						SET @sqlstr = CONCAT("INSERT INTO ld_picklist_values(listid,listvalue,sequence,weight) ",
																 "SELECT ",@listid,",",tmp_listname,",(@i:=@i+1),weight ",
																 "FROM ld_",tmp_listname," ",
																 "ORDER BY picklist_valueid");

						PREPARE stmt1 FROM @sqlstr;
						EXECUTE stmt1;
						DEALLOCATE PREPARE stmt1;

						CALL ldcrm_picklist_DROPTABLE(tmp_listname);
					END IF;

        ELSE
          INSERT INTO ld_picklist_set(listname,relatetable)
            SELECT tmp_listname,'ld_field';

          IF EXISTS (SELECT 1 FROM information_schema.TABLES WHERE TABLE_SCHEMA=DATABASE() AND TABLE_NAME=CONCAT('ld_',tmp_listname)) THEN 
						SET @i=0;
						SET @listid=(SELECT listid FROM ld_picklist_set WHERE listname=tmp_listname AND relatetable='ld_field' LIMIT 1);
						SET @sqlstr = CONCAT("INSERT INTO ld_picklist_values(listid,listvalue,sequence) ",
																 "SELECT ",@listid,",",tmp_listname,",(@i:=@i+1) ",
																 "FROM ld_",tmp_listname," ",
																 "ORDER BY picklist_valueid");

						PREPARE stmt1 FROM @sqlstr;
						EXECUTE stmt1;
						DEALLOCATE PREPARE stmt1;

						CALL ldcrm_picklist_DROPTABLE(tmp_listname);
					END IF;

        END IF;
        FETCH MYCUSOR INTO tmp_listname;
      END WHILE;
      CLOSE MYCUSOR;
    END IF;
  end ||
delimiter;


DROP PROCEDURE IF EXISTS `ldcrm_initial_picklist_producttoolfield`;
delimiter ||
CREATE PROCEDURE `ldcrm_initial_picklist_producttoolfield`(
)
  BEGIN

    DECLARE tmp_listname varchar(100) DEFAULT 0;

    DECLARE MYCUSOR CURSOR FOR SELECT DISTINCT columnname FROM ld_producttoolfield WHERE uitype=60 ORDER BY columnname;
    DECLARE CONTINUE HANDLER FOR SQLSTATE '02000' SET tmp_listname = NULL;

    IF NOT EXISTS (SELECT 1 FROM ld_picklist_set WHERE relatetable='ld_producttoolfield') THEN
      OPEN MYCUSOR;
      FETCH MYCUSOR INTO tmp_listname;
      WHILE (tmp_listname IS NOT NULL) DO
        INSERT INTO ld_picklist_set(listname,relatetable)
          SELECT tmp_listname,'ld_producttoolfield';

				IF EXISTS (SELECT 1 FROM information_schema.TABLES WHERE TABLE_SCHEMA=DATABASE() AND TABLE_NAME=CONCAT('ld_',tmp_listname)) THEN 
					SET @i=0;
					SET @listid=(SELECT listid FROM ld_picklist_set WHERE listname=tmp_listname AND relatetable='ld_producttoolfield' LIMIT 1);
					SET @sqlstr = CONCAT("INSERT INTO ld_picklist_values(listid,listvalue,sequence) ",
															 "SELECT ",@listid,",",tmp_listname,",(@i:=@i+1) ",
															 "FROM ld_",tmp_listname," ",
															 "ORDER BY picklist_valueid");

					PREPARE stmt1 FROM @sqlstr;
					EXECUTE stmt1;
					DEALLOCATE PREPARE stmt1;

					CALL ldcrm_picklist_DROPTABLE(tmp_listname);
				END IF;
        FETCH MYCUSOR INTO tmp_listname;
      END WHILE;
      CLOSE MYCUSOR;
    END IF;
  end ||
delimiter;


DROP PROCEDURE IF EXISTS `ldcrm_initial_picklist_tabdetailfield`;
delimiter ||
CREATE PROCEDURE `ldcrm_initial_picklist_tabdetailfield`(
)
  BEGIN

    DECLARE tmp_listname varchar(100) DEFAULT 0;

    DECLARE MYCUSOR CURSOR FOR SELECT DISTINCT columnname FROM ld_tabdetailfield WHERE fieldtype ='Select' ORDER BY columnname;
    DECLARE CONTINUE HANDLER FOR SQLSTATE '02000' SET tmp_listname = NULL;

    IF NOT EXISTS (SELECT 1 FROM ld_picklist_set WHERE relatetable='ld_tabdetailfield') THEN
      OPEN MYCUSOR;
      FETCH MYCUSOR INTO tmp_listname;
      WHILE (tmp_listname IS NOT NULL) DO
        IF tmp_listname='expensetype' AND EXISTS (SELECT 1 FROM ld_version WHERE account='utrc') THEN
          INSERT INTO ld_picklist_set(listname,relatetable)
          SELECT tmp_listname,'ld_tabdetailfield';

					IF EXISTS (SELECT 1 FROM information_schema.TABLES WHERE TABLE_SCHEMA=DATABASE() AND TABLE_NAME=CONCAT('ld_',tmp_listname)) THEN 
						SET @i=0;
						SET @listid=(SELECT listid FROM ld_picklist_set WHERE listname=tmp_listname AND relatetable='ld_tabdetailfield' LIMIT 1);
						INSERT INTO ld_picklist_values(listid,listvalue,sequence,utrc_type,subjectcode,subjectsummary)
							SELECT @listid,expensetype,(@i:=@i+1),utrc_type,subjectcode,subjectsummary FROM ld_expensetype ORDER BY picklist_valueid;
					END IF;

        ELSEIF tmp_listname='expensetype' AND NOT EXISTS (SELECT 1 FROM ld_version WHERE account='utrc') THEN
          INSERT INTO ld_picklist_set(listname,relatetable)
          SELECT tmp_listname,'ld_tabdetailfield';

					IF EXISTS (SELECT 1 FROM information_schema.TABLES WHERE TABLE_SCHEMA=DATABASE() AND TABLE_NAME=CONCAT('ld_',tmp_listname)) THEN 
						SET @i=0;
						SET @listid=(SELECT listid FROM ld_picklist_set WHERE listname=tmp_listname AND relatetable='ld_tabdetailfield' LIMIT 1);
						INSERT INTO ld_picklist_values(listid,listvalue,sequence)
						SELECT @listid,expensetype,(@i:=@i+1) FROM ld_expensetype ORDER BY picklist_valueid;
					END IF;
        ELSE
          INSERT INTO ld_picklist_set(listname,relatetable)
          SELECT tmp_listname,'ld_tabdetailfield';

					IF EXISTS (SELECT 1 FROM information_schema.TABLES WHERE TABLE_SCHEMA=DATABASE() AND TABLE_NAME=CONCAT('ld_',tmp_listname)) THEN 
						SET @i=0;
						SET @listid=(SELECT listid FROM ld_picklist_set WHERE listname=tmp_listname AND relatetable='ld_tabdetailfield' LIMIT 1);
						SET @sqlstr = CONCAT("INSERT INTO ld_picklist_values(listid,listvalue,sequence) ",
																 "SELECT ",@listid,",",tmp_listname,",(@i:=@i+1) ",
																 "FROM ld_",tmp_listname," ",
																 "ORDER BY picklist_valueid");
						
						PREPARE stmt1 FROM @sqlstr;
						EXECUTE stmt1;
						DEALLOCATE PREPARE stmt1;

						CALL ldcrm_picklist_DROPTABLE(tmp_listname);
					END IF;

        END IF;
        FETCH MYCUSOR INTO tmp_listname;
      END WHILE;
      CLOSE MYCUSOR;
    END IF;
  end ||
delimiter;

SET FOREIGN_KEY_CHECKS=0;

CALL ldcrm_initial_picklist_field();
DROP PROCEDURE IF EXISTS `ldcrm_initial_picklist_field`;
delimiter;

CALL ldcrm_initial_picklist_producttoolfield();
DROP PROCEDURE IF EXISTS `ldcrm_initial_picklist_producttoolfield`;
delimiter;

CALL ldcrm_initial_picklist_tabdetailfield();
DROP PROCEDURE IF EXISTS `ldcrm_initial_picklist_tabdetailfield`;
delimiter;

CALL ldcrm_picklist_DROPTABLE('expensetype');
DROP PROCEDURE IF EXISTS `ldcrm_picklist_DROPTABLE`;
delimiter;

DROP TABLE IF EXISTS ld_picklist;
DROP TABLE IF EXISTS ld_picklist_seq;
DROP TABLE IF EXISTS ld_picklistvalues_seq;

SET FOREIGN_KEY_CHECKS=0;
-- 2018-03-13

select max(wx_sequence) into @wx_sequence from ld_dashboard_app;
insert into ld_dashboard_app(`name`,labelbol,modulenames,image,presence,wx_presence,wx_sequence,kehu001_presence,kehu001_sequence)
select 'SalesOrderTrack','SalesOrderTrack','SalesOrder,ServiceContracts','dashboard_10',2,1,@wx_sequence+1,0,0
from dual where not exists(select 1 from ld_dashboard_app where name='SalesOrderTrack');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','SHOWMODULES','显示的模块','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype = 'zh' and labelbol = 'SHOWMODULES' and labeltype = 'fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','SHOWMODULES','Display module','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype = 'en' and labelbol = 'SHOWMODULES' and labeltype = 'fixedstr');
delimiter;

select tabid into @tabid from ld_tab where `name` = 'Attachment';
select fieldid into @fieldid from ld_field where tabid = @tabid and columnname = 'isenabled';
update ld_field set typeofdata = 'C~O' where tabid = @tabid and fieldid = @fieldid;
delimiter;

select max(wx_sequence) into @wx_sequence from ld_dashboard_app;
insert into ld_dashboard_app(`name`,labelbol,modulenames,image,presence,wx_presence,wx_sequence,kehu001_presence,kehu001_sequence)
select 'CashBillSum_SalesOrder','CashBillSum_SalesOrder','CashBill','dashboard_10',2,1,@wx_sequence+1,0,0
from dual where not exists(select 1 from ld_dashboard_app where name='CashBillSum_SalesOrder');
delimiter;

select max(wx_sequence) into @wx_sequence from ld_dashboard_app;
insert into ld_dashboard_app(`name`,labelbol,modulenames,image,presence,wx_presence,wx_sequence,kehu001_presence,kehu001_sequence)
select 'CashBillSum_Paymentplan','CashBillSum_Paymentplan','CashBill','dashboard_10',2,1,@wx_sequence+1,0,0
from dual where not exists(select 1 from ld_dashboard_app where name='CashBillSum_Paymentplan');
delimiter;

update ld_dashboard_app set kehu001_presence=0 where name in('SalesOrderTrack','CashBillSum_SalesOrder','CashBillSum_Paymentplan');
delimiter;

DROP PROCEDURE IF EXISTS `ldcrm_initial_picklist_field_20180315`;
delimiter ||
CREATE PROCEDURE `ldcrm_initial_picklist_field_20180315`(
)
BEGIN

	
	IF EXISTS (SELECT 1 FROM information_schema.TABLES WHERE TABLE_SCHEMA=DATABASE() AND TABLE_NAME='ld_campaignaccountrelstatus') THEN 
		IF NOT EXISTS (SELECT 1 FROM ld_picklist_set WHERE listname='campaignaccountrelstatus') THEN
			INSERT INTO ld_picklist_set(listname,relatetable) SELECT 'campaignaccountrelstatus','ld_field';

			SET @i=0;
			SET @listid=(SELECT listid FROM ld_picklist_set WHERE listname='campaignaccountrelstatus' AND relatetable='ld_field' LIMIT 1);
			INSERT INTO ld_picklist_values(listid,listvalue,sequence)
			SELECT @listid,campaignaccountrelstatus,(@i:=@i+1) FROM ld_campaignaccountrelstatus ORDER BY picklist_valueid;
		END IF;
		DROP TABLE ld_campaignaccountrelstatus;
	END IF;

end ||
delimiter;

CALL ldcrm_initial_picklist_field_20180315();
DROP PROCEDURE IF EXISTS `ldcrm_initial_picklist_field_20180315`;
delimiter;

update ld_actionmapping set actionlabel = 'CHECKMERGE' where actionname = 'Merge';
delimiter;
-- 2018-03-15

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

update ld_version set old_version='V7.3.0',current_version='V7.3.0',remark='V7.3.0-20180315',wx_version='V7.3.0';
delimiter;