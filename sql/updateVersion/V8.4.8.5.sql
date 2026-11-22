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

ALTER TABLE ld_users MODIFY COLUMN first_name VARCHAR(255);
ALTER TABLE ld_users MODIFY COLUMN last_name VARCHAR(255);
-- 2023-01-04

UPDATE ld_desk SET fieldlabel='转换公海' WHERE labelbol='Transfer'  AND Labeltype='fixedstr' AND languagetype='zh';

set @tabid=(select tabid from ld_tab where `name`='CashBill');
update ld_producttoolfield set input_type=2 where tabid=@tabid and columnname='amount';
update ld_tabdetailfield set input_type=2 where tabid=@tabid and columnname='amount';
delimiter;

set @tabid=(select tabid from ld_tab where `name`='SendCashBill');
update ld_producttoolfield set input_type=2 where tabid=@tabid and columnname='amount';
update ld_tabdetailfield set input_type=2 where tabid=@tabid and columnname='amount';
delimiter;

create table if not exists `ld_watermark_setting` (
	`id` int(11)  NOT NULL AUTO_INCREMENT,
    `presence` VARCHAR(10) DEFAULT 'no',
	`watermark_display` varchar(255) DEFAULT NULL COMMENT "水印内容",
	`custom_content`    varchar(255) DEFAULT NULL COMMENT "自定义内容",
	PRIMARY KEY (`id`)  USING BTREE
) ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=utf8;
delimiter;

insert into ld_watermark_setting(presence,watermark_display) select 'no','username' from dual
where not exists(select 1 from ld_watermark_setting);
delimiter;

select blockid into @blockid from ld_settings_blocks where label='LBL_OTHER_SETTINGS';
select sequence into @sequence from ld_settings_field where blockid = @blockid and `name` = 'LBL_COMPANY_DETAILS';
update ld_settings_field set sequence = sequence + 100 where blockid = @blockid and sequence > @sequence;
select max(fieldid) + 1 into @fieldid from ld_settings_field;
insert into ld_settings_field(fieldid,blockid,name,iconpath,description,linkto,sequence,active)
select  @fieldid,@blockid,'watermark_setting','picklistdependency.png','水印设置','index.php?module=Settings&action=watermark_setting&parenttab=Settings',@sequence+1,0
from dual where not exists(select 1 from ld_settings_field where name='watermark_setting');
delimiter;

set @i =0 ;
update ld_settings_field set sequence=(@i:=@i+1) where blockid=@blockid order by sequence asc;
delimiter;
update ld_settings_field_seq set id = (select max(fieldid) from ld_settings_field);
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','watermark_setting','水印设置','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='watermark_setting' and Labeltype='fixedstr' and languagetype='zh');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','watermark_setting','Watermark settings','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='watermark_setting' and Labeltype='fixedstr' and languagetype='en');
delimiter;
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','watermark_display','水印显示内容','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='watermark_display' and Labeltype='fixedstr' and languagetype='zh');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','watermark_display','Watermark display content','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='watermark_display' and Labeltype='fixedstr' and languagetype='en');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'zh','CUSTOMWATERMARKNOTEMPTY','自定义水印内容不能为空！','jspop' from dual 
where not EXISTS(select 1 from ld_desk  where languagetype='zh' and labelbol='CUSTOMWATERMARKNOTEMPTY' and Labeltype='jspop');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'en','CUSTOMWATERMARKNOTEMPTY','Custom watermark content can not be empty','jspop' from dual 
where not EXISTS(select 1 from ld_desk  where languagetype='en' and labelbol='CUSTOMWATERMARKNOTEMPTY' and Labeltype='jspop');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'zh','watermark_display_content','设置单据新建，编辑，列表，查看详情及相关信息列表的水印显示内容','fixedstr' from dual 
where not EXISTS(select 1 from ld_desk  where languagetype='zh' and labelbol='watermark_display_content' and Labeltype='fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'en','watermark_display_content','Set the watermark display content of document creation, editing, list, view details and related information list','fixedstr' from dual 
where not EXISTS(select 1 from ld_desk  where languagetype='en' and labelbol='watermark_display_content' and Labeltype='fixedstr');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','loginusername','登录用户名','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='loginusername' and Labeltype='fixedstr' and languagetype='zh');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','loginusername','Login user name','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='loginusername' and Labeltype='fixedstr' and languagetype='en');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','username_date','登录用户名+日期','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='username_date' and Labeltype='fixedstr' and languagetype='zh');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','username_date','Login username + date','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='username_date' and Labeltype='fixedstr' and languagetype='en');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','username_phone','登录用户名+手机尾号','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='username_phone' and Labeltype='fixedstr' and languagetype='zh');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','username_phone','Login user name + mobile phone tail number','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='username_phone' and Labeltype='fixedstr' and languagetype='en');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','Companyname_username','公司名称+登录用户名','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='Companyname_username' and Labeltype='fixedstr' and languagetype='zh');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','Companyname_username','Company name + login user name','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='Companyname_username' and Labeltype='fixedstr' and languagetype='en');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','Companyname_username_phone','公司名称+登录用户名+手机尾号','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='Companyname_username_phone' and Labeltype='fixedstr' and languagetype='zh');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','Companyname_username_phone','Company name + login user name + mobile phone tail number','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='Companyname_username_phone' and Labeltype='fixedstr' and languagetype='en');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','companyname_username_date','公司名称+登录用户名+日期','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='companyname_username_date' and Labeltype='fixedstr' and languagetype='zh');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','companyname_username_date','Company name + login user name+date','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='companyname_username_date' and Labeltype='fixedstr' and languagetype='en');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','Custom_content','自定义内容','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='Custom_content' and Labeltype='fixedstr' and languagetype='zh');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','Custom_content','Custom content','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='Custom_content' and Labeltype='fixedstr' and languagetype='en');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','loginusername_hint','当前登录账号的成员姓名','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='loginusername_hint' and Labeltype='fixedstr' and languagetype='zh');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','loginusername_hint','Member name of current login account','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='loginusername_hint' and Labeltype='fixedstr' and languagetype='en');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','username_date_hint','当前登录账号的成员姓名和当前日期','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='username_date_hint' and Labeltype='fixedstr' and languagetype='zh');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','username_date_hint','Member name  of current login account and current date','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='username_date_hint' and Labeltype='fixedstr' and languagetype='en');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','username_phone_hint','当前登录账号的成员姓名和成员管理中手机字段的后四位','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='username_phone_hint' and Labeltype='fixedstr' and languagetype='zh');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','username_phone_hint','The member name of the current login account and the last four digits of the mobile phone field in the member management','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='username_phone_hint' and Labeltype='fixedstr' and languagetype='en');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','Companyname_username_hint','系统设置公司信息中的公司名称和当前登录账号的成员姓名','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='Companyname_username_hint' and Labeltype='fixedstr' and languagetype='zh');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','Companyname_username_hint','The system sets the company name in the company information and the member name of the current login account','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='Companyname_username_hint' and Labeltype='fixedstr' and languagetype='en');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','Companyname_username_phone_hint','系统设置公司信息中的公司名称，当前登录账号的成员姓名和成员管理中手机字段的后四位','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='Companyname_username_phone_hint' and Labeltype='fixedstr' and languagetype='zh');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','Companyname_username_phone_hint','The system sets the company name in the company information， the member name of the current login account and last four digits of mobile phone field in member management','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='Companyname_username_phone_hint' and Labeltype='fixedstr' and languagetype='en');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','companyname_username_date_hint','系统设置公司信息中的公司名称，当前登录账号的成员姓名和当前日期','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='companyname_username_date_hint' and Labeltype='fixedstr' and languagetype='zh');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','companyname_username_date_hint','The system sets the company name in the company information ，member name of current login account and current date ','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='companyname_username_date_hint' and Labeltype='fixedstr' and languagetype='en');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','Custom_content_hint','请输入自定义水印内容','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='Custom_content_hint' and Labeltype='fixedstr' and languagetype='zh');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','Custom_content_hint','Please enter custom watermark content','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='Custom_content_hint' and Labeltype='fixedstr' and languagetype='en');
delimiter;

UPDATE ld_field SET keywords=null,keyword_sseq=null WHERE tablename='ld_users' AND columnname='user_password';
delimiter;

delete from ld_module_tree where fieldname='null';
delimiter;

SELECT MAX(sequence) INTO @sequence FROM ld_systems_deploy;
INSERT INTO ld_systems_deploy(deploy_value,deploy_type,description,setype,sequence,roottype,inputtype,presence,inputvalue)
SELECT '0',358,'设置明细界面评论功能是否显示在右侧','',@sequence+1,1,'select',0,'[{"value":"0","text":"YES"},{"value":"1","text":"NO"},{"sql":""}]' from dual
WHERE NOT EXISTS (SELECT 1 FROM ld_systems_deploy WHERE deploy_type = 358);
delimiter;

insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'zh','ld_systems_deploy',358,358,'设置明细界面评论功能是否显示在右侧' from dual
where not exists (select * from ld_tranlabel where languagetype='zh' and trantable='ld_systems_deploy' and relateid=358);
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'en','ld_systems_deploy',358,358,'Set whether the comment function of the details interface is displayed on the right' from dual 
where not exists (select * from ld_tranlabel where languagetype='en' and trantable='ld_systems_deploy' and relateid=358);
delimiter;

SET @modulename='ModComments';
SET @tabid=(SELECT tabid FROM ld_tab WHERE `name`=@modulename);
SET @relateid=(SELECT block FROM ld_field WHERE tabid=@tabid AND columnname='smownerid' LIMIT 1);
SET @maxseq=IFNULL((SELECT MAX(sequence) FROM ld_field WHERE tabid=@tabid AND block=@relateid),0);
SET @trantable='ld_field';
SET @tablename=(SELECT tablename FROM ld_field WHERE tabid=@tabid AND columnname='smownerid' LIMIT 1);
SET @columnname='parent_reply'; 
SET @fieldname='parent_reply'; 
SET @zh='相关回复'; 
SET @en='Relevant reply'; 
SET @uitype=10; 
SET @typeofdata='V~O';
SET @quickcreate=0;
SET @displaytype=1;
SET @bigtype=NULL;
SET @datarang=NULL;
SET @maxrowsshow=0;
SET @allowdelete='no';

SET @maxid=(SELECT MAX(fieldid) FROM ld_field);
INSERT INTO ld_field(tabid,fieldid,columnname,tablename,generatedtype,uitype,fieldname,fieldlabel,readonly,presence,defaultvalue,maximumlength,sequence,block,displaytype,typeofdata,quickcreate,quickcreatesequence,info_type,masseditable,helpinfo,fieldonly,searchfieldtype,associatedfields,approve_demand,is_checkimportfield,bigtype,datarang,maxrowsshow,allowdelete)
SELECT @tabid,@maxid+1,@columnname,@tablename,1,@uitype,@fieldname,@zh,1,2,NULL,100,@maxseq+1,@relateid,@displaytype,@typeofdata,@quickcreate,NULL,'BAS',1,NULL,0,1,1,2,0,@bigtype,@datarang,@maxrowsshow,@allowdelete from dual 
WHERE NOT EXISTS (SELECT 1 FROM ld_field WHERE tabid=@tabid AND tablename=@tablename AND columnname=@columnname); 

UPDATE ld_field_seq SET id=(SELECT max(fieldid) FROM ld_field);

SET @relateid=(SELECT fieldid FROM ld_field WHERE tabid=@tabid AND columnname=@columnname LIMIT 1);

INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
SELECT 'zh',@trantable,@tabid,@relateid,@zh FROM DUAL 
WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE languagetype = 'zh' AND trantable =@trantable AND tabid = @tabid AND relateid=@relateid);

INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
SELECT 'en',@trantable,@tabid,@relateid,@en FROM DUAL 
WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE languagetype = 'en' AND trantable =@trantable AND tabid = @tabid AND relateid=@relateid);

CALl AddColumn(@tablename,@columnname,'varchar','100',NULL);

CALL getallprofile(@modulename);
CALL fieldprofile(@modulename);
delimiter;
SET @tabid=(SELECT tabid FROM ld_tab WHERE `name`='ModComments');
set @rulename = '主题类型控制显示显示字段';
insert into ld_fieldrule(tabid,rulename,columnname,createdtime,smcreator,enablestatus)
select @tabid,@rulename,'topictype',NOW(),1,'yes' from DUAL
where not EXISTS (select 1 from ld_field where tabid=@tabid and columnname='topictype');

SET @ruleid=(SELECT id FROM ld_fieldrule WHERE `columnname`='topictype' and tabid=@tabid and rulename=@rulename);
insert into ld_fieldrulebasicsearch(ruleid,comparator,`value`)
select @ruleid,'e','回复' from DUAL
where not EXISTS ( select 1 from ld_fieldrulebasicsearch where ruleid=@ruleid  or @ruleid is  null LIMIT 1);

SET @basicsearchid=(SELECT id FROM ld_fieldrulebasicsearch WHERE ruleid=@ruleid and comparator='e' limit 1);
insert into ld_fieldrule_operate(columnname,type,`basicsearchid`)
select 'parent_reply','display',@basicsearchid from DUAL
where not EXISTS ( select 1 from ld_fieldrule_operate where basicsearchid=@basicsearchid or @basicsearchid is  null LIMIT 1);

SET @ruleid=(SELECT id FROM ld_fieldrule WHERE  `columnname`='topictype' and tabid=@tabid and rulename=@rulename);
insert into ld_fieldrulebasicsearch(ruleid,comparator,`value`)
select @ruleid,'n','回复' from DUAL
where not EXISTS ( select 1 from ld_fieldrulebasicsearch where (ruleid=@ruleid  or @ruleid is  null)and comparator='n' LIMIT 1);

SET @basicsearchid=(SELECT id FROM ld_fieldrulebasicsearch WHERE ruleid=@ruleid and comparator='n' limit 1);
insert into ld_fieldrule_operate(columnname,type,`basicsearchid`)
select 'reltab','display',@basicsearchid from DUAL
where not EXISTS ( select 1 from ld_fieldrule_operate where columnname ='reltab' and( basicsearchid=@basicsearchid or @basicsearchid is  null) LIMIT 1);
insert into ld_fieldrule_operate(columnname,type,`basicsearchid`)
select 'related_to','display',@basicsearchid from DUAL
where not EXISTS ( select 1 from ld_fieldrule_operate where columnname ='related_to' and( basicsearchid=@basicsearchid or @basicsearchid is  null)LIMIT 1);
delimiter;

SET @modulename='ModComments';
SET @tabid=(SELECT tabid FROM ld_tab WHERE `name`=@modulename);
SET @relateid=(SELECT block FROM ld_field WHERE tabid=@tabid AND columnname='smownerid' LIMIT 1);
SET @maxseq=IFNULL((SELECT MAX(sequence) FROM ld_field WHERE tabid=@tabid AND block=@relateid),0);
SET @trantable='ld_field';
SET @tablename=(SELECT tablename FROM ld_field WHERE tabid=@tabid AND columnname='smownerid' LIMIT 1);
SET @columnname='topictype'; 
SET @fieldname='topictype'; 
SET @zh='主题类型'; 
SET @en='Topic Type'; 
SET @uitype=1; 
SET @typeofdata='V~O';
SET @quickcreate=0;
SET @displaytype=1;
SET @bigtype='translatefield';
SET @datarang=NULL;
SET @maxrowsshow=0;
SET @allowedit = 'no';
SET @allowdelete='no';

SET @maxid=(SELECT MAX(fieldid) FROM ld_field);
INSERT INTO ld_field(tabid,fieldid,columnname,tablename,generatedtype,uitype,fieldname,fieldlabel,readonly,presence,defaultvalue,maximumlength,sequence,block,displaytype,typeofdata,quickcreate,quickcreatesequence,info_type,masseditable,helpinfo,fieldonly,searchfieldtype,associatedfields,approve_demand,is_checkimportfield,allowedit,bigtype,datarang,maxrowsshow,allowdelete)
SELECT @tabid,@maxid+1,@columnname,@tablename,1,@uitype,@fieldname,@zh,1,2,NULL,100,@maxseq+1,@relateid,@displaytype,@typeofdata,@quickcreate,NULL,'BAS',1,NULL,0,1,1,2,0,@allowedit,@bigtype,@datarang,@maxrowsshow,@allowdelete from dual 
WHERE NOT EXISTS (SELECT 1 FROM ld_field WHERE tabid=@tabid AND tablename=@tablename AND columnname=@columnname); 

UPDATE ld_field_seq SET id=(SELECT max(fieldid) FROM ld_field);

SET @relateid=(SELECT fieldid FROM ld_field WHERE tabid=@tabid AND columnname=@columnname LIMIT 1);

INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
SELECT 'zh',@trantable,@tabid,@relateid,@zh FROM DUAL 
WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE languagetype = 'zh' AND trantable =@trantable AND tabid = @tabid AND relateid=@relateid);

INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
SELECT 'en',@trantable,@tabid,@relateid,@en FROM DUAL 
WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE languagetype = 'en' AND trantable =@trantable AND tabid = @tabid AND relateid=@relateid);

CALl AddColumn(@tablename,@columnname,'varchar','100',NULL);

CALL getallprofile(@modulename);
CALL fieldprofile(@modulename);

SET @Dbvalue = 'comments';
SET @labelbol = 'COMMENT1';
INSERT INTO ld_translatefield(columnname,column_Dbvalue,module,labelbol)
SELECT @columnname,@Dbvalue,@modulename,@labelbol FROM DUAL
WHERE not EXISTS(SELECT 1 from ld_translatefield where columnname = @columnname and column_Dbvalue= @Dbvalue and module = @modulename);

SET @Dbvalue = 'reply';
SET @labelbol = 'Reply';
INSERT INTO ld_translatefield(columnname,column_Dbvalue,module,labelbol)
SELECT @columnname,@Dbvalue,@modulename,@labelbol FROM DUAL
WHERE not EXISTS(SELECT 1 from ld_translatefield where columnname = @columnname and column_Dbvalue= @Dbvalue and module = @modulename);
delimiter;


insert into ld_actionmapping(actionid,actionname,securitycheck,actionlabel)
SELECT 53,'Reply',0,'Reply' from DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_actionmapping where actionname='Reply' and actionid=53);
delimiter;

SET @tabid=(SELECT tabid FROM ld_tab WHERE `name`='ModComments');
SET @seq=(SELECT sequence FROM ld_profileallpermission WHERE `tabid`=@tabid and operation=2);
insert into ld_profileallpermission(tabid,operation,sequence)
SELECT @tabid,53,@seq-1 from DUAL
where NOT EXISTS (SELECT 1 FROM ld_profileallpermission where tabid=@tabid and operation=53);
SET @i=0;
update ld_profileallpermission set sequence=(@i:=@i+1) where tabid=@tabid ORDER BY sequence;
delimiter;

DROP PROCEDURE IF EXISTS `ldcrm_add_profile_for_reply_202212`;
delimiter ||
CREATE PROCEDURE `ldcrm_add_profile_for_reply_202212`(
)
BEGIN
	DECLARE tmp_profileid INT(19) DEFAULT 0;
	declare done  int  default 0;

	DECLARE MYCUSOR CURSOR FOR SELECT profileid FROM ld_profile WHERE profileid>0;
	declare continue handler  for not   found  SET done =1;
	SET @tabid=(SELECT tabid FROM ld_tab WHERE `name`='ModComments');
	IF NOT EXISTS (SELECT 1 FROM ld_profile2standardpermissions WHERE tabid=@tabid and operation=53) THEN
		OPEN MYCUSOR;
		FETCH MYCUSOR INTO tmp_profileid;
		while  done<>1 DO
			SET @profileid=tmp_profileid;
			
			INSERT INTO ld_profile2standardpermissions(profileid,tabid,operation,permissions,sequence)
			SELECT @profileid AS profileid,@tabid AS tabid,53,0,0 FROM DUAL
			WHERE NOT EXISTS (SELECT 1 FROM ld_profile2standardpermissions WHERE profileid=@profileid and tabid=@tabid and operation=53);
			
			FETCH MYCUSOR INTO tmp_profileid;
		END WHILE;
		CLOSE MYCUSOR;
	END IF;
END ||
delimiter;

CALL ldcrm_add_profile_for_reply_202212();
DROP PROCEDURE IF EXISTS `ldcrm_add_profile_for_reply_202212`;
delimiter;

update ld_field  set bigtype='text' where (uitype=1 or uitype=609) and (bigtype='' or bigtype is null);
update ld_field  set bigtype='percent' where uitype=9 and (bigtype='' or bigtype is null);
update ld_field  set bigtype='fileattachment' where (uitype=69 or uitype=105)  and (bigtype='' or bigtype is null) ;
update ld_field set bigtype='users' where (uitype=132 or uitype=52)  and (bigtype='' or bigtype is null);
update ld_field  set bigtype='datetime' where uitype='70'  and (bigtype='' or bigtype is null);
update ld_field set bigtype='currency' where uitype=72  and (bigtype='' or bigtype is null);
update ld_field set bigtype='tag' where uitype=301 and (bigtype='' or bigtype is null);
update ld_field  set bigtype='date' where  (uitype=5 or uitype=70) and (bigtype='' or bigtype is null);
delimiter;

DELETE FROM ld_tranlabel WHERE tranlabelid IN (
	SELECT
		tranlabelid_min
	FROM (
		SELECT
			MIN(tranlabelid) AS tranlabelid_min,
			languagetype,
			trantable,
			tabid,
			Relateid,
			COUNT(1) AS cnt
		FROM ld_tranlabel 
		GROUP BY trantable,languagetype,tabid,Relateid
	) a
	WHERE cnt>1
);
delimiter;
-- 2023-01-06

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
-- 2023-01-09

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

UPDATE ld_version SET old_version='V8.4.8.5',current_version='V8.4.8.5',remark='V8.4.8.5-20230109',wx_version='V8.4.8.5';
delimiter;