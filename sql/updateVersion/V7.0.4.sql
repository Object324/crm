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

DROP PROCEDURE IF EXISTS `addtabintoprofile`;
delimiter ||
CREATE  PROCEDURE `addtabintoprofile`(
tabname varchar(50),
permissions int(19)

)
begin
	declare done  int  default 0;
	declare pprofileid  int ;
	declare cur1 CURSOR FOR SELECT profileid  FROM  ld_profile;
	declare continue handler  for not   found  SET done =1;
	set @sql =concat('select tabid into @tabid from ld_tab where name=','''',tabname,'''');
	prepare stmt from @sql;
	execute stmt;
	deallocate  prepare stmt;
	OPEN cur1;
	Fetch cur1 into pprofileid;
	 loop1: while  done<>1 DO
	set @sql=CONCAT('insert into ld_profile2standardpermissions(profileid,tabid,operation,permissions) select  ' ,pprofileid,',',@tabid,',',0,',',permissions,'  from dual  where not exists (select 1 from ld_profile2standardpermissions where profileid=',pprofileid, ' and  tabid=',@tabid,' and operation=0)' );
				  prepare stmt from @sql;
			 execute stmt;
	deallocate prepare stmt;
	set @sql=CONCAT('insert into ld_profile2standardpermissions(profileid,tabid,operation,permissions) select  ' ,pprofileid,',',@tabid,',',1,',',permissions,'  from dual  where not exists (select 1 from ld_profile2standardpermissions where profileid=',pprofileid, ' and  tabid=',@tabid,' and operation=1)' );
				  prepare stmt from @sql;
			 execute stmt;
	deallocate prepare stmt;
	set @sql=CONCAT('insert into ld_profile2standardpermissions(profileid,tabid,operation,permissions) select  ' ,pprofileid,',',@tabid,',',2,',',permissions,'  from dual  where not exists (select 1 from ld_profile2standardpermissions where profileid=',pprofileid, ' and  tabid=',@tabid,' and operation=2)' );
				  prepare stmt from @sql;
			 execute stmt;
	deallocate prepare stmt;
	set @sql=CONCAT('insert into ld_profile2standardpermissions(profileid,tabid,operation,permissions) select  ' ,pprofileid,',',@tabid,',',3,',',permissions,'  from dual  where not exists (select 1 from ld_profile2standardpermissions where profileid=',pprofileid, ' and  tabid=',@tabid,' and operation=3)' );
	prepare stmt from @sql;
			 execute stmt;
	deallocate prepare stmt;
			  set @sql=CONCAT('insert into ld_profile2standardpermissions(profileid,tabid,operation,permissions) select  ' ,pprofileid,',',@tabid,',',4,',',permissions,'  from dual  where not exists (select 1 from ld_profile2standardpermissions where profileid=',pprofileid, ' and  tabid=',@tabid,' and operation=4)' );
				  prepare stmt from @sql;
			 execute stmt;
	deallocate prepare stmt;
		 set @sql=CONCAT('insert into ld_profile2standardpermissions(profileid,tabid,operation,permissions) select  ' ,pprofileid,',',@tabid,',',11,',',permissions,'  from dual  where not exists (select 1 from ld_profile2standardpermissions where profileid=',pprofileid, ' and  tabid=',@tabid,' and operation=11)' );
				  prepare stmt from @sql;
			 execute stmt;
	deallocate prepare stmt;
	Fetch cur1 into pprofileid;
	end while loop1;
	close cur1;
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

DROP FUNCTION IF EXISTS `getPY`;
delimiter ||
CREATE  FUNCTION `getPY`(in_string text) RETURNS mediumtext CHARSET utf8
BEGIN
	DECLARE tmp_str text charset gbk DEFAULT '' ;
	DECLARE tmp_len SMALLINT DEFAULT 0; 
	DECLARE tmp_char VARCHAR(2) charset gbk DEFAULT '';
	DECLARE tmp_rs text charset gbk DEFAULT '';
	DECLARE tmp_cc VARCHAR(2) charset gbk DEFAULT '';

	SET tmp_str = in_string;
	SET tmp_len = LENGTH(tmp_str);

	WHILE tmp_len > 0 DO 
		SET tmp_char = LEFT(tmp_str,1); 
		SET tmp_cc = tmp_char;
		IF LENGTH(tmp_char)>1 THEN
			SELECT ELT(INTERVAL(CONV(HEX(tmp_char),16,10),0xB0A1,0xB0C5,0xB2C1,0xB4EE,0xB6EA,0xB7A2,0xB8C1,0xB9FE,0xBBF7,0xBFA6,0xC0AC
			,0xC2E8,0xC4C3,0xC5B6,0xC5BE,0xC6DA,0xC8BB,0xC8F6,0xCBFA,0xCDDA ,0xCEF4,0xD1B9,0xD4D1), 
			'A','B','C','D','E','F','G','H','J','K','L','M','N','O','P','Q','R','S','T','W','X','Y','Z') INTO tmp_cc;
		END IF; 
		SET tmp_rs = CONCAT(tmp_rs,tmp_cc);
		SET tmp_str = SUBSTRING(tmp_str,2);
		SET tmp_len = LENGTH(tmp_str);
	END WHILE; 
	RETURN tmp_rs;
END ||
delimiter;

CREATE TABLE IF NOT EXISTS `tmp_symbol` (
  `id` int(19) NOT NULL,
  `symbol` varchar(50) NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
delimiter;

insert into tmp_symbol(id,symbol) 
select 1,'{' from dual where not exists (select 1 from tmp_symbol where id=1);
insert into tmp_symbol(id,symbol) 
select 2,'}' from dual where not exists (select 1 from tmp_symbol where id=2);
delimiter; 

select tabid into @tabid from ld_tab where `name`='Attachment';
select block into @block from ld_field where tabid=@tabid and columnname='filename';
update ld_field set displaytype=3,allowhide='no',block=@block where tabid=@tabid and columnname in ('imagefromtype','uuid','size');
delimiter;

set @i=0;
select tabid into @tabid from ld_tab where `name`='Attachment';
select cvid into @cvid from ld_customview where entitytype='Attachment' and viewname='相册选择';
delete from ld_tabwithproductview where cvid=@cvid;
insert into ld_tabwithproductview(tabid,`columns`,sequence,cvid)
select @tabid,'ld_attachmentsforbills:attachment_no:attachment_no:Attachment_fieldlabel:V',@i,@cvid;

insert into ld_tabwithproductview(tabid,`columns`,sequence,cvid)
select @tabid,'ld_attachmentsforbills:smownerid:assigned_user_id:Attachment_fieldlabel:V',(@i:=@i+1),@cvid;

insert into ld_tabwithproductview(tabid,`columns`,sequence,cvid)
select @tabid,'ld_attachmentsforbills:reltab:reltab:Attachment_fieldlabel:V',(@i:=@i+1),@cvid;

insert into ld_tabwithproductview(tabid,`columns`,sequence,cvid)
select @tabid,'ld_attachmentsforbills:related_to:related_to:Attachment_fieldlabel:V',(@i:=@i+1),@cvid;

insert into ld_tabwithproductview(tabid,`columns`,sequence,cvid)
select @tabid,'ld_attachmentsforbills:createdtime:createdtime:Attachment_fieldlabel:V',(@i:=@i+1),@cvid;

insert into ld_tabwithproductview(tabid,`columns`,sequence,cvid)
select @tabid,'ld_attachmentsforbills:description:description:Attachment_fieldlabel:V',(@i:=@i+1),@cvid;

insert into ld_tabwithproductview(tabid,`columns`,sequence,cvid)
select @tabid,'ld_attachmentsforbillsdetails:filename:filename:Attachment_fieldlabel:V',(@i:=@i+1),@cvid;

insert into ld_tabwithproductview(tabid,`columns`,sequence,cvid)
select @tabid,'ld_attachmentsforbillsdetails:size:size:Attachment_fieldlabel:V',(@i:=@i+1),@cvid;

insert into ld_tabwithproductview(tabid,`columns`,sequence,cvid)
select @tabid,'ld_attachmentsforbillsdetails:imagefromtype:imagefromtype:Attachment_fieldlabel:V',(@i:=@i+1),@cvid;

insert into ld_tabwithproductview(tabid,`columns`,sequence,cvid)
select @tabid,'ld_attachmentsforbillsdetails:uuid:uuid:Attachment_fieldlabel:V',(@i:=@i+1),@cvid;
delimiter;

set @i=0;
select tabid into @tabid from ld_tab where `name`='Attachment';
select cvid into @cvid from ld_customview where entitytype='Attachment' and viewname='拍照上传';
delete from ld_tabwithproductview where cvid=@cvid;
insert into ld_tabwithproductview(tabid,`columns`,sequence,cvid)
select @tabid,'ld_attachmentsforbills:attachment_no:attachment_no:Attachment_fieldlabel:V',@i,@cvid;

insert into ld_tabwithproductview(tabid,`columns`,sequence,cvid)
select @tabid,'ld_attachmentsforbills:smownerid:assigned_user_id:Attachment_fieldlabel:V',(@i:=@i+1),@cvid;

insert into ld_tabwithproductview(tabid,`columns`,sequence,cvid)
select @tabid,'ld_attachmentsforbills:reltab:reltab:Attachment_fieldlabel:V',(@i:=@i+1),@cvid;

insert into ld_tabwithproductview(tabid,`columns`,sequence,cvid)
select @tabid,'ld_attachmentsforbills:related_to:related_to:Attachment_fieldlabel:V',(@i:=@i+1),@cvid;

insert into ld_tabwithproductview(tabid,`columns`,sequence,cvid)
select @tabid,'ld_attachmentsforbills:createdtime:createdtime:Attachment_fieldlabel:V',(@i:=@i+1),@cvid;

insert into ld_tabwithproductview(tabid,`columns`,sequence,cvid)
select @tabid,'ld_attachmentsforbills:description:description:Attachment_fieldlabel:V',(@i:=@i+1),@cvid;

insert into ld_tabwithproductview(tabid,`columns`,sequence,cvid)
select @tabid,'ld_attachmentsforbillsdetails:filename:filename:Attachment_fieldlabel:V',(@i:=@i+1),@cvid;

insert into ld_tabwithproductview(tabid,`columns`,sequence,cvid)
select @tabid,'ld_attachmentsforbillsdetails:size:size:Attachment_fieldlabel:V',(@i:=@i+1),@cvid;

insert into ld_tabwithproductview(tabid,`columns`,sequence,cvid)
select @tabid,'ld_attachmentsforbillsdetails:imagefromtype:imagefromtype:Attachment_fieldlabel:V',(@i:=@i+1),@cvid;

insert into ld_tabwithproductview(tabid,`columns`,sequence,cvid)
select @tabid,'ld_attachmentsforbillsdetails:uuid:uuid:Attachment_fieldlabel:V',(@i:=@i+1),@cvid;
delimiter;
-- 2017-06-26

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'zh','LBL_DATAINTERFACE_SETTING','数据接口信息','fixedstr' from dual where not EXISTS(select 1 from ld_desk where languagetype='zh' and labelbol='LBL_DATAINTERFACE_SETTING' and Labeltype='fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'en','LBL_DATAINTERFACE_SETTING','Data Interface Information','fixedstr' from dual where not EXISTS(select 1 from ld_desk  where languagetype='en' and labelbol='LBL_DATAINTERFACE_SETTING' and Labeltype='fixedstr');

update ld_desk set fieldlabel = 'ERP接口信息' where labelbol = 'LBL_DATAINTERFACE_SETTING' and languagetype ='zh' and Labeltype = 'fixedstr';
update ld_desk set fieldlabel = 'ERP Interface Information' where labelbol = 'LBL_DATAINTERFACE_SETTING' and languagetype ='en' and Labeltype = 'fixedstr';
delimiter;

update ld_desk set fieldlabel = '设置ERP接口账套信息' where labelbol = 'LBL_SETTING_DATAINTERFACE_DEMOINFO' and languagetype ='zh' and Labeltype = 'fixedstr';
update ld_desk set fieldlabel = 'Set ERP interface account information' where labelbol = 'LBL_SETTING_DATAINTERFACE_DEMOINFO' and languagetype ='en' and Labeltype = 'fixedstr';
delimiter;

update ld_field set allowhide='no',presence=2,displaytype=3 where tabid=8 and columnname in ('type','size');
update ld_tranlabel set fieldlabel='允许查看或下载' where trantable='ld_field' and tabid=8 and Relateid=215 and languagetype='zh' and fieldlabel='启用';
update ld_tranlabel set fieldlabel='Allow viewing or downloading' where trantable='ld_field' and tabid=8 and Relateid=215 and languagetype='en' and fieldlabel='Active';
delimiter;
-- 2017-06-28

INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','custom','自定义','jspop' from dual
where not exists(select 1 from ld_desk where languagetype = 'zh' and labelbol = 'custom' and labeltype = 'jspop');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','custom','Custom','jspop' from dual
where not exists(select 1 from ld_desk where languagetype = 'en' and labelbol = 'custom' and labeltype = 'jspop');
delimiter;

INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','TIMES','时间','jspop' from dual
where not exists(select 1 from ld_desk where languagetype = 'zh' and labelbol = 'TIMES' and labeltype = 'jspop');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','TIMES','Times','jspop' from dual
where not exists(select 1 from ld_desk where languagetype = 'en' and labelbol = 'TIMES' and labeltype = 'jspop');
delimiter;

INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','ENDDATE1','截止日期','jspop' from dual
where not exists(select 1 from ld_desk where languagetype = 'zh' and labelbol = 'ENDDATE1' and labeltype = 'jspop');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','ENDDATE1','End Date','jspop' from dual
where not exists(select 1 from ld_desk where languagetype = 'en' and labelbol = 'ENDDATE1' and labeltype = 'jspop');
delimiter;

INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','pleaseselectdate','请选择日期','jspop' from dual
where not exists(select 1 from ld_desk where languagetype = 'zh' and labelbol = 'pleaseselectdate' and labeltype = 'jspop');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','pleaseselectdate','Please select date','jspop' from dual
where not exists(select 1 from ld_desk where languagetype = 'en' and labelbol = 'pleaseselectdate' and labeltype = 'jspop');
delimiter;

INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','screen','筛选','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype = 'zh' and labelbol = 'screen' and labeltype = 'fixedstr');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','screen','Search','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype = 'en' and labelbol = 'screen' and labeltype = 'fixedstr');
delimiter;

INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','STARTDATE1','起始日期','jspop' from dual
where not exists(select 1 from ld_desk where languagetype = 'zh' and labelbol = 'STARTDATE1' and labeltype = 'jspop');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','STARTDATE1','Start Date','jspop' from dual
where not exists(select 1 from ld_desk where languagetype = 'en' and labelbol = 'STARTDATE1' and labeltype = 'jspop');
delimiter;

select sequence,roottype into @sequence,@roottype from ld_systems_deploy where deploy_type = 109;
update ld_systems_deploy set sequence = sequence+1000 where roottype = @roottype and sequence > @sequence;
insert into ld_systems_deploy(deploy_value,deploy_type,description,setype,sequence,roottype,inputtype,presence,inputvalue)
select 0,138,'设置关联销售机会时是否在所有用户的数据中进行查询','',@sequence+1,@roottype,'select',0,'[{"value":"1","text":"YES"},{"value":"0","text":"NO"},{"sql":""},{"relatedmodule":"Potentials"},{"selectmodule":"Potentials"}]' from DUAL
where not EXISTS(select 1 from ld_systems_deploy where deploy_type = 138);
set @i=0;
update ld_systems_deploy set sequence=(@i:=@i+1) where roottype = @roottype order by sequence;
delimiter;
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'zh','ld_systems_deploy',138,138,'设置关联{$Potentials.Potentials}时是否在所有用户的数据中进行查询' from DUAL
where not exists(select 1 from ld_tranlabel where languagetype = 'zh' and trantable = 'ld_systems_deploy' and tabid = 138 and Relateid = 138);
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'en','ld_systems_deploy',138,138,'Whether to query all users’ data when related to {$Potentials.Potentials}' from DUAL
where not exists(select 1 from ld_tranlabel where languagetype = 'en' and trantable = 'ld_systems_deploy' and tabid = 138 and Relateid = 138);
delimiter;
-- 2017-06-29

update ld_links set linkurl='http://51mis.com.cn/forum.php?mod=viewthread&tid=40&fromuid=1' where linktype='Settings' and linklabel='WorkRemindSet';

select sequence,roottype into @sequence,@roottype from ld_systems_deploy where deploy_type = 109;
update ld_systems_deploy set sequence = sequence+1000 where roottype = @roottype and sequence > @sequence;
insert into ld_systems_deploy(deploy_value,deploy_type,description,setype,sequence,roottype,inputtype,presence,inputvalue)
select 0,139,'设置关联供应商联系人时是否在所有用户的数据中进行查询','',@sequence+1,@roottype,'select',0,'[{"value":"1","text":"YES"},{"value":"0","text":"NO"},{"sql":""},{"relatedmodule":"VendorContact"},{"selectmodule":"VendorContact"}]' from DUAL
where not EXISTS(select 1 from ld_systems_deploy where deploy_type = 139);

set @i=0;
update ld_systems_deploy set sequence=(@i:=@i+1) where roottype = @roottype order by sequence;
delimiter;

insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'zh','ld_systems_deploy',139,139,'设置关联{$VendorContact.VendorContact}时是否在所有用户的数据中进行查询' from DUAL
where not exists(select 1 from ld_tranlabel where languagetype = 'zh' and trantable = 'ld_systems_deploy' and tabid = 139 and Relateid = 139);
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'en','ld_systems_deploy',139,139,'Whether to query all users’ data when related to {$VendorContact.VendorContact}' from DUAL
where not exists(select 1 from ld_tranlabel where languagetype = 'en' and trantable = 'ld_systems_deploy' and tabid = 139 and Relateid = 139);
delimiter;

update ld_tranlabel set fieldlabel='设置用户的密码是否严格管理' where trantable='ld_systems_deploy'  AND languagetype='zh' AND Relateid=90;
update ld_tranlabel set fieldlabel='设置系统登录时是否启用验证码' where trantable='ld_systems_deploy'  AND languagetype='zh' AND Relateid=73;
update ld_tranlabel set fieldlabel='设置系统中手机字段显示的样式（是否隐藏部分内容）' where trantable='ld_systems_deploy'  AND languagetype='zh' AND Relateid=80;
update ld_tranlabel set fieldlabel='设置手机号码显示样式影响的数据范围' where trantable='ld_systems_deploy'  AND languagetype='zh' AND Relateid=81;
update ld_tranlabel set fieldlabel='设置序时簿列表下方是否显示本次查询统计图表' where trantable='ld_systems_deploy'  AND languagetype='zh' AND Relateid=137;

update ld_tranlabel set fieldlabel='设置当{$Accounts.Accounts}有关联的单据时是否允许删除' where trantable='ld_systems_deploy'  AND languagetype='zh' AND Relateid=69;
update ld_tranlabel set fieldlabel='设置同名附件上传限制方式' where trantable='ld_systems_deploy'  AND languagetype='zh' AND Relateid=77;
update ld_tranlabel set fieldlabel='设置移动端外勤签到上传图片时是否允许选择相册图片' where trantable='ld_systems_deploy'  AND languagetype='zh' AND Relateid=114;
update ld_tranlabel set fieldlabel='设置首页组件视图的布局样式' where trantable='ld_systems_deploy'  AND languagetype='zh' AND Relateid=65;
update ld_tranlabel set fieldlabel='设置首页组件默认显示的视图页签' where trantable='ld_systems_deploy'  AND languagetype='zh' AND Relateid=66;
update ld_tranlabel set fieldlabel='设置首页组件中是否显示周月统计' where trantable='ld_systems_deploy'  AND languagetype='zh' AND Relateid=78;

update ld_tranlabel set fieldlabel='设置关联{$Accounts.Accounts}时是否在所有用户的数据中进行查询' where trantable='ld_systems_deploy'  AND languagetype='zh' AND Relateid=74;
update ld_tranlabel set fieldlabel='设置关联{$Contacts.Contacts}时是否在所有用户的数据中进行查询' where trantable='ld_systems_deploy'  AND languagetype='zh' AND Relateid=108;
update ld_tranlabel set fieldlabel='设置关联{$Vendors.Vendors}时是否在所有用户的数据中进行查询' where trantable='ld_systems_deploy'  AND languagetype='zh' AND Relateid=109;
update ld_tranlabel set fieldlabel='设置{$Potentials.Potentials}新增保存后是否立即创建回款预测' where trantable='ld_systems_deploy'  AND languagetype='zh' AND Relateid=54;
update ld_tranlabel set fieldlabel='设置{$SalesOrder.SalesOrder}新增或编辑后是否立即打印' where trantable='ld_systems_deploy'  AND languagetype='zh' AND Relateid=57;
update ld_tranlabel set fieldlabel='设置{$SalesOrder.SalesOrder}新增保存后是否立即创建{$PaymentPlan.PaymentPlan}' where trantable='ld_systems_deploy'  AND languagetype='zh' AND Relateid=12;

update ld_tranlabel set fieldlabel='设置{$SalesOrder.SalesOrder}关联创建{$PaymentPlan.PaymentPlan}时是否控制{$PaymentPlan.PaymentPlan}总金额等于{$SalesOrder.SalesOrder}金额' where trantable='ld_systems_deploy'  AND languagetype='zh' AND Relateid=1;
update ld_tranlabel set fieldlabel='设置{$SalesOrder.SalesOrder}保存后是否自动创建1年免服务费的{$ServiceContracts.ServiceContracts}' where trantable='ld_systems_deploy'  AND languagetype='zh' AND Relateid=130;

update ld_tranlabel set fieldlabel='设置{$SalesOrder.SalesOrder}新增保存后是否自动创建{$OutboundOrder.OutboundOrder}（为空表示不创建）' where trantable='ld_systems_deploy'  AND languagetype='zh' AND Relateid=56;
update ld_tranlabel set fieldlabel='设置{$SalesOrder.SalesOrder}编辑保存后是否自动创建{$OutboundOrder.OutboundOrder}（为空表示不创建）' where trantable='ld_systems_deploy'  AND languagetype='zh' AND Relateid=63;
update ld_tranlabel set fieldlabel='设置{$SalesOrder.SalesOrder}新增保存后是否更新{$Accounts.Accounts}的{$Accounts.rating}字段为（为空表示不更新）' where trantable='ld_systems_deploy'  AND languagetype='zh' AND Relateid=37;
update ld_tranlabel set fieldlabel='设置{$SalesOrder.SalesOrder}新增保存后是否更新{$Potentials.Potentials}的{$Potentials.sales_stage}字段为（为空表示不更新）' where trantable='ld_systems_deploy'  AND languagetype='zh' AND Relateid=38;

update ld_tranlabel set fieldlabel='设置{$ServiceContracts.ServiceContracts}新增保存后是否立即创建{$PaymentPlan.PaymentPlan}' where trantable='ld_systems_deploy'  AND languagetype='zh' AND Relateid=58;
update ld_tranlabel set fieldlabel='设置{$ServiceContracts.ServiceContracts}关联创建{$PaymentPlan.PaymentPlan}时是否控制{$PaymentPlan.PaymentPlan}总金额等于{$ServiceContracts.ServiceContracts}金额' where trantable='ld_systems_deploy'  AND languagetype='zh' AND Relateid=59;
update ld_tranlabel set fieldlabel='设置{$PurchaseOrder.PurchaseOrder}新增保存后是否立即创建{$SendPayment.SendPayment}' where trantable='ld_systems_deploy'  AND languagetype='zh' AND Relateid=15;
update ld_tranlabel set fieldlabel='设置{$PurchaseOrder.PurchaseOrder}关联创建{$SendPayment.SendPayment}时是否控制{$SendPayment.SendPayment}总金额等于{$PurchaseOrder.PurchaseOrder}金额' where trantable='ld_systems_deploy'  AND languagetype='zh' AND Relateid=20;
update ld_tranlabel set fieldlabel='更新库存流水记录的触发点' where trantable='ld_systems_deploy'  AND languagetype='zh' AND Relateid=48;
update ld_tranlabel set fieldlabel='必须严格参照源单（每种产品累计数量不允许超出源单或者出现源单外的产品）' where trantable='ld_systems_deploy'  AND languagetype='zh' AND Relateid=10;

update ld_tranlabel set fieldlabel='设置序时簿列表页面批量操作记录条数的上限' where trantable='ld_systems_deploy'  AND languagetype='zh' AND Relateid=67;
update ld_tranlabel set fieldlabel='设置序时簿列表每页显示记录的条数' where trantable='ld_systems_deploy'  AND languagetype='zh' AND Relateid=13;
update ld_tranlabel set fieldlabel='设置单据明细界面相关信息列表每页显示记录的条数' where trantable='ld_systems_deploy'  AND languagetype='zh' AND Relateid=14;
update ld_tranlabel set fieldlabel='设置{$Accounts.Accounts}明细界面是否显示首要联系人' where trantable='ld_systems_deploy'  AND languagetype='zh' AND Relateid=72;

update ld_tranlabel set fieldlabel='设置单据新增时分录明细中预置的分录行数' where trantable='ld_systems_deploy'  AND languagetype='zh' AND Relateid=122;
update ld_tranlabel set fieldlabel='设置单据分录明细中最后一行录入产品后是否自动新增行' where trantable='ld_systems_deploy'  AND languagetype='zh' AND Relateid=123;
update ld_tranlabel set fieldlabel='设置单据分录明细中数量字段小数位数' where trantable='ld_systems_deploy'  AND languagetype='zh' AND Relateid=49;
update ld_tranlabel set fieldlabel='设置单据分录明细中单价字段小数位数' where trantable='ld_systems_deploy'  AND languagetype='zh' AND Relateid=93;

update ld_tranlabel set fieldlabel='设置{$Potentials.Potentials}查看明细界面是否显示{$Accounts.Accounts}和{$Contacts.Contacts}基本信息基本信息' where trantable='ld_systems_deploy'  AND languagetype='zh' AND Relateid=25;
update ld_tranlabel set fieldlabel='设置{$ProjectTask.ProjectTask}查看明细界面是否显示{$Accounts.Accounts}和{$Contacts.Contacts}基本信息' where trantable='ld_systems_deploy'  AND languagetype='zh' AND Relateid=32;
update ld_tranlabel set fieldlabel='设置关联单据时只能选择已审批的单据' where trantable='ld_systems_deploy'  AND languagetype='zh' AND Relateid=68;
update ld_tranlabel set fieldlabel='设置{$SalesOrder.SalesOrder}新增保存后是否立即创建{$DividendOrder.DividendOrder}' where trantable='ld_systems_deploy'  AND languagetype='zh' AND Relateid=89;

set @i=0;
update ld_systems_deploy set roottype=1,sequence=(@i:=@i+1) where deploy_type=90;
update ld_systems_deploy set roottype=1,sequence=(@i:=@i+1) where deploy_type=73;
update ld_systems_deploy set roottype=1,sequence=(@i:=@i+1) where deploy_type=80;
update ld_systems_deploy set roottype=1,sequence=(@i:=@i+1) where deploy_type=81;
update ld_systems_deploy set roottype=1,sequence=(@i:=@i+1) where deploy_type=137;
update ld_systems_deploy set roottype=1,sequence=(@i:=@i+1) where deploy_type=33;
update ld_systems_deploy set roottype=1,sequence=(@i:=@i+1) where deploy_type=69;
update ld_systems_deploy set roottype=1,sequence=(@i:=@i+1) where deploy_type=72;
update ld_systems_deploy set roottype=1,sequence=(@i:=@i+1) where deploy_type=77;
update ld_systems_deploy set roottype=1,sequence=(@i:=@i+1) where deploy_type=114;
update ld_systems_deploy set roottype=1,sequence=(@i:=@i+1) where deploy_type=65;

update ld_systems_deploy set roottype=1,sequence=(@i:=@i+1) where deploy_type=66;
update ld_systems_deploy set roottype=1,sequence=(@i:=@i+1) where deploy_type=78;
update ld_systems_deploy set roottype=1,sequence=(@i:=@i+1) where deploy_type=68;
update ld_systems_deploy set roottype=1,sequence=(@i:=@i+1) where deploy_type=74;
update ld_systems_deploy set roottype=1,sequence=(@i:=@i+1) where deploy_type=108;
update ld_systems_deploy set roottype=1,sequence=(@i:=@i+1) where deploy_type=109;
update ld_systems_deploy set roottype=1,sequence=(@i:=@i+1) where deploy_type=139;
update ld_systems_deploy set roottype=1,sequence=(@i:=@i+1) where deploy_type=138;
update ld_systems_deploy set roottype=1,sequence=(@i:=@i+1) where deploy_type=119;
update ld_systems_deploy set roottype=1,sequence=(@i:=@i+1) where deploy_type=116;
update ld_systems_deploy set roottype=1,sequence=(@i:=@i+1) where deploy_type=117;
update ld_systems_deploy set roottype=1,sequence=(@i:=@i+1) where deploy_type=118;

update ld_systems_deploy set roottype=1,sequence=(@i:=@i+1) where deploy_type=54;
update ld_systems_deploy set roottype=1,sequence=(@i:=@i+1) where deploy_type=57;
update ld_systems_deploy set roottype=1,sequence=(@i:=@i+1) where deploy_type=89;
update ld_systems_deploy set roottype=1,sequence=(@i:=@i+1) where deploy_type=12;
update ld_systems_deploy set roottype=1,sequence=(@i:=@i+1) where deploy_type=1;
update ld_systems_deploy set roottype=1,sequence=(@i:=@i+1) where deploy_type=130;
update ld_systems_deploy set roottype=1,sequence=(@i:=@i+1) where deploy_type=56;
update ld_systems_deploy set roottype=1,sequence=(@i:=@i+1) where deploy_type=63;
update ld_systems_deploy set roottype=1,sequence=(@i:=@i+1) where deploy_type=37;
update ld_systems_deploy set roottype=1,sequence=(@i:=@i+1) where deploy_type=38;
update ld_systems_deploy set roottype=1,sequence=(@i:=@i+1) where deploy_type=58;

update ld_systems_deploy set roottype=1,sequence=(@i:=@i+1) where deploy_type=59;
update ld_systems_deploy set roottype=1,sequence=(@i:=@i+1) where deploy_type=15;
update ld_systems_deploy set roottype=1,sequence=(@i:=@i+1) where deploy_type=20;
update ld_systems_deploy set roottype=1,sequence=(@i:=@i+1) where deploy_type=48;
update ld_systems_deploy set roottype=1,sequence=(@i:=@i+1) where deploy_type=10;
update ld_systems_deploy set roottype=1,sequence=(@i:=@i+1) where deploy_type=67;
update ld_systems_deploy set roottype=1,sequence=(@i:=@i+1) where deploy_type=13;
update ld_systems_deploy set roottype=1,sequence=(@i:=@i+1) where deploy_type=14;

update ld_systems_deploy set roottype=1,sequence=(@i:=@i+1) where deploy_type=123;
update ld_systems_deploy set roottype=1,sequence=(@i:=@i+1) where deploy_type=122;
update ld_systems_deploy set roottype=1,sequence=(@i:=@i+1) where deploy_type=49;
update ld_systems_deploy set roottype=1,sequence=(@i:=@i+1) where deploy_type=93;

update ld_systems_deploy set roottype=1,sequence=(@i:=@i+1) where deploy_type=25;
update ld_systems_deploy set roottype=1,sequence=(@i:=@i+1) where deploy_type=32;
delimiter;

set @i=0;
update ld_systems_deploy set roottype=2,sequence=(@i:=@i+1) where deploy_type=70;
update ld_systems_deploy set roottype=2,sequence=(@i:=@i+1) where deploy_type=11;
update ld_systems_deploy set roottype=2,sequence=(@i:=@i+1) where deploy_type=94;
update ld_systems_deploy set roottype=2,sequence=(@i:=@i+1) where deploy_type=112;
update ld_systems_deploy set roottype=2,sequence=(@i:=@i+1) where deploy_type=113;
update ld_systems_deploy set roottype=2,sequence=(@i:=@i+1) where deploy_type=27;
update ld_systems_deploy set roottype=2,sequence=(@i:=@i+1) where deploy_type=29;

update ld_systems_deploy set roottype=2,sequence=(@i:=@i+1) where deploy_type=5;
update ld_systems_deploy set roottype=2,sequence=(@i:=@i+1) where deploy_type=8;
update ld_systems_deploy set roottype=2,sequence=(@i:=@i+1) where deploy_type=3;
update ld_systems_deploy set roottype=2,sequence=(@i:=@i+1) where deploy_type=47;
update ld_systems_deploy set roottype=2,sequence=(@i:=@i+1) where deploy_type=6;
update ld_systems_deploy set roottype=2,sequence=(@i:=@i+1) where deploy_type=100;
update ld_systems_deploy set roottype=2,sequence=(@i:=@i+1) where deploy_type=22;
update ld_systems_deploy set roottype=2,sequence=(@i:=@i+1) where deploy_type=23;
update ld_systems_deploy set roottype=2,sequence=(@i:=@i+1) where deploy_type=98;

update ld_systems_deploy set roottype=2,sequence=(@i:=@i+1) where deploy_type=99;
update ld_systems_deploy set roottype=2,sequence=(@i:=@i+1) where deploy_type=96;
update ld_systems_deploy set roottype=2,sequence=(@i:=@i+1) where deploy_type=28;
update ld_systems_deploy set roottype=2,sequence=(@i:=@i+1) where deploy_type=120;
update ld_systems_deploy set roottype=2,sequence=(@i:=@i+1) where deploy_type=17;

update ld_systems_deploy set roottype=2,sequence=(@i:=@i+1) where deploy_type=4;
update ld_systems_deploy set roottype=2,sequence=(@i:=@i+1) where deploy_type=50;
update ld_systems_deploy set roottype=2,sequence=(@i:=@i+1) where deploy_type=30;
update ld_systems_deploy set roottype=2,sequence=(@i:=@i+1) where deploy_type=31;
update ld_systems_deploy set roottype=2,sequence=(@i:=@i+1) where deploy_type=133;
update ld_systems_deploy set roottype=2,sequence=(@i:=@i+1) where deploy_type=134;

update ld_systems_deploy set roottype=2,sequence=(@i:=@i+1) where deploy_type=135;
update ld_systems_deploy set roottype=2,sequence=(@i:=@i+1) where deploy_type=136;
update ld_systems_deploy set roottype=2,sequence=(@i:=@i+1) where deploy_type=125;
update ld_systems_deploy set roottype=2,sequence=(@i:=@i+1) where deploy_type=126;
update ld_systems_deploy set roottype=2,sequence=(@i:=@i+1) where deploy_type=127;
update ld_systems_deploy set roottype=2,sequence=(@i:=@i+1) where deploy_type=128;
update ld_systems_deploy set roottype=2,sequence=(@i:=@i+1) where deploy_type=129;
update ld_systems_deploy set roottype=2,sequence=(@i:=@i+1) where deploy_type=131;
update ld_systems_deploy set roottype=2,sequence=(@i:=@i+1) where deploy_type=36;
update ld_systems_deploy set roottype=2,sequence=(@i:=@i+1) where deploy_type=9;
delimiter;


update ld_tranlabel set fieldlabel='{$Accounts.Accounts}的{$Accounts.assigned_user_id}变更时是否发送短信通知新的{$Accounts.assigned_user_id}' where trantable='ld_systems_deploy'  AND languagetype='zh' AND Relateid=7;
update ld_tranlabel set fieldlabel='{$Potentials.Potentials}的{$Potentials.assigned_user_id}变更时是否发送短信通知新的{$Potentials.assigned_user_id}' where trantable='ld_systems_deploy'  AND languagetype='zh' AND Relateid=62;
update ld_tranlabel set fieldlabel='{$HelpDesk.HelpDesk}分配时是否发送短信通知{$HelpDesk.assigned_user_id}' where trantable='ld_systems_deploy'  AND languagetype='zh' AND Relateid=115;
update ld_tranlabel set fieldlabel='{$OutboundOrder.OutboundOrder}审核时是否发送短信通知客户' where trantable='ld_systems_deploy'  AND languagetype='zh' AND Relateid=21;
update ld_tranlabel set fieldlabel='{$PaymentPlan.PaymentPlan}是否按照{$Project.Project}的{$Project.projectstatus}进行收款提醒' where trantable='ld_systems_deploy'  AND languagetype='zh' AND Relateid=53;
update ld_tranlabel set fieldlabel='{$SalesOrder.SalesOrder}{$SalesOrder.duedate}前N天提醒（为0表示当天提醒，为空表示不提醒）' where trantable='ld_systems_deploy'  AND languagetype='zh' AND Relateid=18;

set @i=0;
update ld_systems_deploy set roottype=3,sequence=(@i:=@i+1) where deploy_type=51;
update ld_systems_deploy set roottype=3,sequence=(@i:=@i+1) where deploy_type=95;
update ld_systems_deploy set roottype=3,sequence=(@i:=@i+1) where deploy_type=7;
update ld_systems_deploy set roottype=3,sequence=(@i:=@i+1) where deploy_type=62;
update ld_systems_deploy set roottype=3,sequence=(@i:=@i+1) where deploy_type=115;
update ld_systems_deploy set roottype=3,sequence=(@i:=@i+1) where deploy_type=21;
update ld_systems_deploy set roottype=3,sequence=(@i:=@i+1) where deploy_type=53;
update ld_systems_deploy set roottype=3,sequence=(@i:=@i+1) where deploy_type=40;
update ld_systems_deploy set roottype=3,sequence=(@i:=@i+1) where deploy_type=41;
update ld_systems_deploy set roottype=3,sequence=(@i:=@i+1) where deploy_type=18;
update ld_systems_deploy set roottype=3,sequence=(@i:=@i+1) where deploy_type=24;
delimiter;


update ld_tranlabel set fieldlabel='{$Accounts.Accounts}审批通过后是否还允许编辑' where trantable='ld_systems_deploy'  AND languagetype='zh' AND Relateid=16;
update ld_tranlabel set fieldlabel='分配单据时被分配人是否显示所有用户' where trantable='ld_systems_deploy'  AND languagetype='zh' AND Relateid=110;
update ld_tranlabel set fieldlabel='分配{$Accounts.Accounts}时是否同时分配相关信息' where trantable='ld_systems_deploy'  AND languagetype='zh' AND Relateid=61;
update ld_tranlabel set fieldlabel='分配{$Potentials.Potentials}时是否同时分配相关信息' where trantable='ld_systems_deploy'  AND languagetype='zh' AND Relateid=26;
update ld_tranlabel set fieldlabel='单据分录明细中产品的价格和金额计算时的基准字段' where trantable='ld_systems_deploy'  AND languagetype='zh' AND Relateid=124;
update ld_tranlabel set fieldlabel='单据分录明细中录入产品资料时是否显示无效的产品' where trantable='ld_systems_deploy'  AND languagetype='zh' AND Relateid=82;
update ld_tranlabel set fieldlabel='单据分录明细中录入产品时只允许选择已审批的产品' where trantable='ld_systems_deploy'  AND languagetype='zh' AND Relateid=71;
update ld_tranlabel set fieldlabel='ERP接口中订单数据同步的触发点' where trantable='ld_systems_deploy'  AND languagetype='zh' AND Relateid=92;

set @i=0;
update ld_systems_deploy set roottype=4,sequence=(@i:=@i+1) where deploy_type=16;
update ld_systems_deploy set roottype=4,sequence=(@i:=@i+1) where deploy_type=110;
update ld_systems_deploy set roottype=4,sequence=(@i:=@i+1) where deploy_type=61;
update ld_systems_deploy set roottype=4,sequence=(@i:=@i+1) where deploy_type=26;
update ld_systems_deploy set roottype=4,sequence=(@i:=@i+1) where deploy_type=83;
update ld_systems_deploy set roottype=4,sequence=(@i:=@i+1) where deploy_type=84;

update ld_systems_deploy set roottype=4,sequence=(@i:=@i+1) where deploy_type=79;
update ld_systems_deploy set roottype=4,sequence=(@i:=@i+1) where deploy_type=124;
update ld_systems_deploy set roottype=4,sequence=(@i:=@i+1) where deploy_type=82;
update ld_systems_deploy set roottype=4,sequence=(@i:=@i+1) where deploy_type=71;

update ld_systems_deploy set roottype=4,sequence=(@i:=@i+1) where deploy_type=86;
update ld_systems_deploy set roottype=4,sequence=(@i:=@i+1) where deploy_type=111;
update ld_systems_deploy set roottype=4,sequence=(@i:=@i+1) where deploy_type=85;
update ld_systems_deploy set roottype=4,sequence=(@i:=@i+1) where deploy_type=132;
update ld_systems_deploy set roottype=4,sequence=(@i:=@i+1) where deploy_type=102;
update ld_systems_deploy set roottype=4,sequence=(@i:=@i+1) where deploy_type=103;
update ld_systems_deploy set roottype=4,sequence=(@i:=@i+1) where deploy_type=92;
update ld_systems_deploy set roottype=4,sequence=(@i:=@i+1) where deploy_type=105;
update ld_systems_deploy set roottype=4,sequence=(@i:=@i+1) where deploy_type=106;
delimiter;

DROP PROCEDURE IF EXISTS `ldcrm_read_tmpreminder`;
delimiter ||
CREATE PROCEDURE `ldcrm_read_tmpreminder`(
)
BEGIN

	DECLARE tmp_id INT(19) DEFAULT 0;
	DECLARE tmp_content text DEFAULT '';
	DECLARE tmp_recieverid INT(19) DEFAULT 0;
	DECLARE tmp_remindtime datetime;
	DECLARE tmp_reltab varchar(100) DEFAULT '';
	DECLARE tmp_related_to INT(19) DEFAULT 0;
	DECLARE tmp_ruleid INT(19) DEFAULT 0;

	DECLARE Mycur CURSOR FOR 
		SELECT
			id,
			content,
			reminderid,
			remindtime,
			reltab,
			related_to,
			reminds_ruleid 
		FROM ld_tmpreminder 
		WHERE remindtime<=NOW() 
			AND IFNULL(content,'') not like '%[var.%'
		ORDER BY remindtime DESC LIMIT 50;

	DECLARE CONTINUE HANDLER FOR SQLSTATE '02000' set tmp_id = NULL;

	OPEN Mycur;
	FETCH Mycur INTO tmp_id,tmp_content,tmp_recieverid,tmp_remindtime,tmp_reltab,tmp_related_to,tmp_ruleid;
	WHILE (tmp_id IS NOT NULL) DO
		DELETE FROM ld_tmpreminder WHERE id=tmp_id;
		set @maxid=0;
		select max(crmid) into @maxid from ld_crmentity;
		insert into ld_crmentity(crmid,setype)
		select @maxid+1,'Reminds';
		
		update ld_crmentity_seq set id=(select max(crmid) from ld_crmentity);
			
		insert into ld_reminds(remindsid,content,date_time,recieverid,status_rmd,related_to,reltab,is_del_send,is_del_rec,reminds_ruleid,smownerid,smcreatorid,modifiedby,createdtime,modifiedtime,description,deleted)
		select @maxid+1,tmp_content,tmp_remindtime,tmp_recieverid,'未读',tmp_related_to,tmp_reltab,0,0,tmp_ruleid,0,0,0,tmp_remindtime,tmp_remindtime,null,0;

	FETCH Mycur INTO tmp_id,tmp_content,tmp_recieverid,tmp_remindtime,tmp_reltab,tmp_related_to,tmp_ruleid;
	END WHILE;
	CLOSE Mycur;	
	
end ||
delimiter;

DROP EVENT IF EXISTS `task_read_tmpreminder`;
CREATE EVENT `task_read_tmpreminder`
ON SCHEDULE EVERY 30 SECOND STARTS '2017-06-23 14:00:00'
ON COMPLETION NOT PRESERVE
ENABLE
DO

CALL ldcrm_read_tmpreminder();
delimiter;
-- 2017-06-30

update ld_relatedlists set wx_presence=1 where name = 'get_attachment';
delimiter;

select tabid into @tabid from ld_tab where `name` = 'PurchaseOrder';
update ld_field set typeofdata = 'V~O' where tabid = @tabid and columnname = 'vendorid';
delimiter;
-- 2017-07-03

set @tabname='AddJobBill';
select tabid into @tabid from ld_tab where `name`=@tabname;
select block into @blockid from ld_field where tabid=@tabid and columnname='addjobbill_no';
set @tablename='ld_addjobbillscf';
set @columnname='sytx';
set @fieldname='sytx';
set @zh='剩余调休(h)';
set @en='Available Overtime(h)';
set @uitype=1;
set @readonly=0;
set @presence=2;
set @defaultvalue=NULL;
set @displaytype=2;
set @typeofdata='V~O';
set @quickcreate=1;
set @quickcreatesequence=NULL;
set @info_type='BAS';
set @masseditable=1;
  
select sequence into @seq from ld_field where tabid=@tabid and columnname='addjobbill_no';
update ld_field set sequence=sequence+1 where tabid=@tabid and block=@blockid and sequence>@seq;

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

call AddColumn(@tablename,@columnname,'varchar','20',NULL);
delimiter;

set @tabname='AddJobBill';
select tabid into @tabid from ld_tab where `name`=@tabname;
select block into @blockid from ld_field where tabid=@tabid and columnname='addjobbill_no';
set @tablename='ld_addjobbillscf';
set @columnname='synj';
set @fieldname='synj';
set @zh='剩余年假(h)';
set @en='Available Annual Leave(h)';
set @uitype=1;
set @readonly=0;
set @presence=2;
set @defaultvalue=NULL;
set @displaytype=2;
set @typeofdata='V~O';
set @quickcreate=1;
set @quickcreatesequence=NULL;
set @info_type='BAS';
set @masseditable=1;
  
select sequence into @seq from ld_field where tabid=@tabid and columnname='sytx';
update ld_field set sequence=sequence+1 where tabid=@tabid and block=@blockid and sequence>@seq;

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

call AddColumn(@tablename,@columnname,'varchar','20',NULL);
delimiter;

set @i=0;
update ld_field set sequence=(@i:=@i+1) where tabid=@tabid and block=@blockid order by sequence;

call getallprofile(@tabname);
delimiter;
call fieldprofile(@tabname);
delimiter;


set @tabname='MinusJobBill';
select tabid into @tabid from ld_tab where `name`=@tabname;
select block into @blockid from ld_field where tabid=@tabid and columnname='minusjobbill_no';
set @tablename='ld_minusjobbillscf';
set @columnname='sytx';
set @fieldname='sytx';
set @zh='剩余调休(h)';
set @en='Available Overtime(h)';
set @uitype=1;
set @readonly=0;
set @presence=2;
set @defaultvalue=NULL;
set @displaytype=2;
set @typeofdata='V~O';
set @quickcreate=1;
set @quickcreatesequence=NULL;
set @info_type='BAS';
set @masseditable=1;
  
select sequence into @seq from ld_field where tabid=@tabid and columnname='minusjobbill_no';
update ld_field set sequence=sequence+1 where tabid=@tabid and block=@blockid and sequence>@seq;

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

call AddColumn(@tablename,@columnname,'varchar','20',NULL);
delimiter;

set @tabname='MinusJobBill';
select tabid into @tabid from ld_tab where `name`=@tabname;
select block into @blockid from ld_field where tabid=@tabid and columnname='minusjobbill_no';
set @tablename='ld_minusjobbillscf';
set @columnname='synj';
set @fieldname='synj';
set @zh='剩余年假(h)';
set @en='Available Annual Leave(h)';
set @uitype=1;
set @readonly=0;
set @presence=2;
set @defaultvalue=NULL;
set @displaytype=2;
set @typeofdata='V~O';
set @quickcreate=1;
set @quickcreatesequence=NULL;
set @info_type='BAS';
set @masseditable=1;
  
select sequence into @seq from ld_field where tabid=@tabid and columnname='sytx';
update ld_field set sequence=sequence+1 where tabid=@tabid and block=@blockid and sequence>@seq;

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

call AddColumn(@tablename,@columnname,'varchar','20',NULL);
delimiter;

set @i=0;
update ld_field set sequence=(@i:=@i+1) where tabid=@tabid and block=@blockid order by sequence;

call getallprofile(@tabname);
delimiter;
call fieldprofile(@tabname);
delimiter;

DROP PROCEDURE IF EXISTS `ldcrm_update_sykq_byuserid`;
delimiter ||
CREATE  PROCEDURE `ldcrm_update_sykq_byuserid`(
	tmp_id int(19)
)
BEGIN
  
    insert into ld_minusjobbillscf(minusjobbillid)
    select minusjobbillid from ld_minusjobbill where minusjobbillid not in (select minusjobbillid from ld_minusjobbillscf);
    
	-- 更新请假单上的剩余调休和剩余年假
	UPDATE ld_minusjobbill a
	LEFT JOIN ld_minusjobbillscf b ON a.minusjobbillid=b.minusjobbillid
	LEFT JOIN (
		SELECT
			a.id, 
			a.last_name,
            a.this_njstart,
			IFNULL((SELECT SUM(costtime) FROM vw_oa_attendance WHERE smownerid=a.id AND timetype='加班' AND approvestatus='已批准'),0)
				-IFNULL((SELECT SUM(costtime) FROM vw_oa_attendance WHERE smownerid=a.id AND timetype='调休' AND approvestatus='已批准'),0) AS total_sy_tx,
			CASE
				WHEN LENGTH(IFNULL(a.hire_date,''))<1 OR a.hire_date='0000-00-00' THEN
					0-IFNULL((SELECT SUM(costtime) FROM vw_oa_attendance WHERE smownerid=a.id AND timetype='年假' AND approvestatus='已批准'),0)
				WHEN a.hire_date>'1990-01-01' AND DATE_ADD(a.hire_date,INTERVAL 1 YEAR)>CURDATE() THEN
					0
				WHEN a.hire_date>'1990-01-01' AND DATE_ADD(a.hire_date,INTERVAL 1 YEAR)<=CURDATE() AND DATE_ADD(a.hire_date,INTERVAL 10 YEAR)>CURDATE() THEN
					5*8-IFNULL((SELECT SUM(costtime) FROM vw_oa_attendance WHERE smownerid=a.id AND timetype='年假' AND approvestatus='已批准' AND workdate>=a.this_njstart AND workdate<DATE_ADD(a.this_njstart,INTERVAL 1 YEAR)),0)
				WHEN a.hire_date>'1990-01-01' AND DATE_ADD(a.hire_date,INTERVAL 10 YEAR)<=CURDATE() AND DATE_ADD(a.hire_date,INTERVAL 20 YEAR)>CURDATE() THEN
					10*8-IFNULL((SELECT SUM(costtime) FROM vw_oa_attendance WHERE smownerid=a.id AND timetype='年假' AND approvestatus='已批准' AND workdate>=a.this_njstart AND workdate<DATE_ADD(a.this_njstart,INTERVAL 1 YEAR)),0)
				WHEN a.hire_date>'1990-01-01' AND DATE_ADD(a.hire_date,INTERVAL 20 YEAR)<=CURDATE() THEN
					15*8-IFNULL((SELECT SUM(costtime) FROM vw_oa_attendance WHERE smownerid=a.id AND timetype='年假' AND approvestatus='已批准' AND workdate>=a.this_njstart AND workdate<DATE_ADD(a.this_njstart,INTERVAL 1 YEAR)),0)
				ELSE 112
			END AS total_sy_nj
		FROM (
			SELECT
					a.id,
					a.last_name,
					a.`status`,
					a.hire_date,
					CASE
						WHEN LENGTH(IFNULL(a.hire_date,''))<1 OR a.hire_date='0000-00-00' THEN NULL
						WHEN DATE_ADD(a.hire_date,INTERVAL YEAR(CURDATE())-YEAR(a.hire_date) YEAR)<=CURDATE() THEN
							DATE_ADD(a.hire_date,INTERVAL YEAR(CURDATE())-YEAR(a.hire_date) YEAR)
						ELSE
							DATE_ADD(a.hire_date,INTERVAL YEAR(CURDATE())-YEAR(a.hire_date)-1 YEAR)
					END AS this_njstart,
					CASE
						WHEN LENGTH(IFNULL(a.hire_date,''))<1 OR a.hire_date='0000-00-00' THEN NULL
						ELSE
							DATE_ADD(a.hire_date,INTERVAL 2017-YEAR(a.hire_date) YEAR)
					END AS extra_njend
				FROM ld_users a
		) a
	) t ON a.smownerid=t.id
	SET b.sytx=t.total_sy_tx,b.synj=concat(t.total_sy_nj,IFNULL(CONCAT('(',t.this_njstart,')'),''))
	WHERE a.smownerid=tmp_id;


    insert into ld_addjobbillscf(addjobbillid)
    select addjobbillid from ld_addjobbill where addjobbillid not in (select addjobbillid from ld_addjobbillscf);

	-- 更新加班单上的剩余调休和剩余年假
	UPDATE ld_addjobbill a
	LEFT JOIN ld_addjobbillscf b ON a.addjobbillid=b.addjobbillid
	LEFT JOIN (
		SELECT
			a.id, 
			a.last_name,
            a.this_njstart,
			IFNULL((SELECT SUM(costtime) FROM vw_oa_attendance WHERE smownerid=a.id AND timetype='加班' AND approvestatus='已批准'),0)
				-IFNULL((SELECT SUM(costtime) FROM vw_oa_attendance WHERE smownerid=a.id AND timetype='调休' AND approvestatus='已批准'),0) AS total_sy_tx,
			CASE
				WHEN LENGTH(IFNULL(a.hire_date,''))<1 OR a.hire_date='0000-00-00' THEN
					0-IFNULL((SELECT SUM(costtime) FROM vw_oa_attendance WHERE smownerid=a.id AND timetype='年假' AND approvestatus='已批准'),0)
				WHEN a.hire_date>'1990-01-01' AND DATE_ADD(a.hire_date,INTERVAL 1 YEAR)>CURDATE() THEN
					0
				WHEN a.hire_date>'1990-01-01' AND DATE_ADD(a.hire_date,INTERVAL 1 YEAR)<=CURDATE() AND DATE_ADD(a.hire_date,INTERVAL 10 YEAR)>CURDATE() THEN
					5*8-IFNULL((SELECT SUM(costtime) FROM vw_oa_attendance WHERE smownerid=a.id AND timetype='年假' AND approvestatus='已批准' AND workdate>=a.this_njstart AND workdate<DATE_ADD(a.this_njstart,INTERVAL 1 YEAR)),0)
				WHEN a.hire_date>'1990-01-01' AND DATE_ADD(a.hire_date,INTERVAL 10 YEAR)<=CURDATE() AND DATE_ADD(a.hire_date,INTERVAL 20 YEAR)>CURDATE() THEN
					10*8-IFNULL((SELECT SUM(costtime) FROM vw_oa_attendance WHERE smownerid=a.id AND timetype='年假' AND approvestatus='已批准' AND workdate>=a.this_njstart AND workdate<DATE_ADD(a.this_njstart,INTERVAL 1 YEAR)),0)
				WHEN a.hire_date>'1990-01-01' AND DATE_ADD(a.hire_date,INTERVAL 20 YEAR)<=CURDATE() THEN
					15*8-IFNULL((SELECT SUM(costtime) FROM vw_oa_attendance WHERE smownerid=a.id AND timetype='年假' AND approvestatus='已批准' AND workdate>=a.this_njstart AND workdate<DATE_ADD(a.this_njstart,INTERVAL 1 YEAR)),0)
				ELSE 112
			END AS total_sy_nj
		FROM (
			SELECT
					a.id,
					a.last_name,
					a.`status`,
					a.hire_date,
					CASE
						WHEN LENGTH(IFNULL(a.hire_date,''))<1 OR a.hire_date='0000-00-00' THEN NULL
						WHEN DATE_ADD(a.hire_date,INTERVAL YEAR(CURDATE())-YEAR(a.hire_date) YEAR)<=CURDATE() THEN
							DATE_ADD(a.hire_date,INTERVAL YEAR(CURDATE())-YEAR(a.hire_date) YEAR)
						ELSE
							DATE_ADD(a.hire_date,INTERVAL YEAR(CURDATE())-YEAR(a.hire_date)-1 YEAR)
					END AS this_njstart,
					CASE
						WHEN LENGTH(IFNULL(a.hire_date,''))<1 OR a.hire_date='0000-00-00' THEN NULL
						ELSE
							DATE_ADD(a.hire_date,INTERVAL 2017-YEAR(a.hire_date) YEAR)
					END AS extra_njend
				FROM ld_users a
		) a
	) t ON a.smownerid=t.id
	SET b.sytx=t.total_sy_tx,b.synj=concat(t.total_sy_nj,IFNULL(CONCAT('(',t.this_njstart,')'),''))
	WHERE a.smownerid=tmp_id;
	
end ||
delimiter;

drop trigger if exists `ldcrm_updatesykq_byaddjobbill`; 
delimiter || 
CREATE TRIGGER ldcrm_updatesykq_byaddjobbill 
AFTER UPDATE ON ld_addjobbill 
FOR EACH ROW 
BEGIN 

	IF (new.approvestatus='已批准' and old.approvestatus<>'已批准') OR (new.approvestatus<>'已批准' and old.approvestatus='已批准') THEN
		CALL ldcrm_update_sykq_byuserid(new.smownerid);
	END IF;
	
END || 
delimiter;

drop trigger if exists `ldcrm_insertsykq_byaddjobbill`; 
delimiter || 
CREATE TRIGGER ldcrm_insertsykq_byaddjobbill 
BEFORE INSERT ON ld_addjobbillscf 
FOR EACH ROW 
BEGIN 


	SET @total_sy_tx=0;
	SET @total_sy_nj=0;
	
	SELECT
		total_sy_tx into @total_sy_tx
	FROM (
		SELECT
			a.id, 
			a.last_name,
			IFNULL((SELECT SUM(costtime) FROM vw_oa_attendance WHERE smownerid=a.id AND timetype='加班' AND approvestatus='已批准'),0)
				-IFNULL((SELECT SUM(costtime) FROM vw_oa_attendance WHERE smownerid=a.id AND timetype='调休' AND approvestatus='已批准'),0) AS total_sy_tx,
			CASE
				WHEN LENGTH(IFNULL(a.hire_date,''))<1 OR a.hire_date='0000-00-00' THEN
					0-IFNULL((SELECT SUM(costtime) FROM vw_oa_attendance WHERE smownerid=a.id AND timetype='年假' AND approvestatus='已批准'),0)
				WHEN a.hire_date>'1990-01-01' AND DATE_ADD(a.hire_date,INTERVAL 1 YEAR)>CURDATE() THEN
					0
				WHEN a.hire_date>'1990-01-01' AND DATE_ADD(a.hire_date,INTERVAL 1 YEAR)<=CURDATE() AND DATE_ADD(a.hire_date,INTERVAL 10 YEAR)>CURDATE() THEN
					5*8-IFNULL((SELECT SUM(costtime) FROM vw_oa_attendance WHERE smownerid=a.id AND timetype='年假' AND approvestatus='已批准' AND workdate>=a.this_njstart AND workdate<DATE_ADD(a.this_njstart,INTERVAL 1 YEAR)),0)
				WHEN a.hire_date>'1990-01-01' AND DATE_ADD(a.hire_date,INTERVAL 10 YEAR)<=CURDATE() AND DATE_ADD(a.hire_date,INTERVAL 20 YEAR)>CURDATE() THEN
					10*8-IFNULL((SELECT SUM(costtime) FROM vw_oa_attendance WHERE smownerid=a.id AND timetype='年假' AND approvestatus='已批准' AND workdate>=a.this_njstart AND workdate<DATE_ADD(a.this_njstart,INTERVAL 1 YEAR)),0)
				WHEN a.hire_date>'1990-01-01' AND DATE_ADD(a.hire_date,INTERVAL 20 YEAR)<=CURDATE() THEN
					15*8-IFNULL((SELECT SUM(costtime) FROM vw_oa_attendance WHERE smownerid=a.id AND timetype='年假' AND approvestatus='已批准' AND workdate>=a.this_njstart AND workdate<DATE_ADD(a.this_njstart,INTERVAL 1 YEAR)),0)
				ELSE 112
			END AS total_sy_nj
		FROM (
			SELECT
					a.id,
					a.last_name,
					a.`status`,
					a.hire_date,
					CASE
						WHEN LENGTH(IFNULL(a.hire_date,''))<1 OR a.hire_date='0000-00-00' THEN NULL
						WHEN DATE_ADD(a.hire_date,INTERVAL YEAR(CURDATE())-YEAR(a.hire_date) YEAR)<=CURDATE() THEN
							DATE_ADD(a.hire_date,INTERVAL YEAR(CURDATE())-YEAR(a.hire_date) YEAR)
						ELSE
							DATE_ADD(a.hire_date,INTERVAL YEAR(CURDATE())-YEAR(a.hire_date)-1 YEAR)
					END AS this_njstart,
					CASE
						WHEN LENGTH(IFNULL(a.hire_date,''))<1 OR a.hire_date='0000-00-00' THEN NULL
						ELSE
							DATE_ADD(a.hire_date,INTERVAL 2017-YEAR(a.hire_date) YEAR)
					END AS extra_njend
				FROM ld_users a
		) a
	) t
	WHERE id=(SELECT smownerid FROM ld_addjobbill WHERE addjobbillid=NEW.addjobbillid) LIMIT 1;
	
	SELECT
		concat(t.total_sy_nj,IFNULL(CONCAT('(',t.this_njstart,')'),'')) into @total_sy_nj
	FROM (
		SELECT
			a.id, 
			a.last_name,
            a.this_njstart,
			IFNULL((SELECT SUM(costtime) FROM vw_oa_attendance WHERE smownerid=a.id AND timetype='加班' AND approvestatus='已批准'),0)
				-IFNULL((SELECT SUM(costtime) FROM vw_oa_attendance WHERE smownerid=a.id AND timetype='调休' AND approvestatus='已批准'),0) AS total_sy_tx,
			CASE
				WHEN LENGTH(IFNULL(a.hire_date,''))<1 OR a.hire_date='0000-00-00' THEN
					0-IFNULL((SELECT SUM(costtime) FROM vw_oa_attendance WHERE smownerid=a.id AND timetype='年假' AND approvestatus='已批准'),0)
				WHEN a.hire_date>'1990-01-01' AND DATE_ADD(a.hire_date,INTERVAL 1 YEAR)>CURDATE() THEN
					0
				WHEN a.hire_date>'1990-01-01' AND DATE_ADD(a.hire_date,INTERVAL 1 YEAR)<=CURDATE() AND DATE_ADD(a.hire_date,INTERVAL 10 YEAR)>CURDATE() THEN
					5*8-IFNULL((SELECT SUM(costtime) FROM vw_oa_attendance WHERE smownerid=a.id AND timetype='年假' AND approvestatus='已批准' AND workdate>=a.this_njstart AND workdate<DATE_ADD(a.this_njstart,INTERVAL 1 YEAR)),0)
				WHEN a.hire_date>'1990-01-01' AND DATE_ADD(a.hire_date,INTERVAL 10 YEAR)<=CURDATE() AND DATE_ADD(a.hire_date,INTERVAL 20 YEAR)>CURDATE() THEN
					10*8-IFNULL((SELECT SUM(costtime) FROM vw_oa_attendance WHERE smownerid=a.id AND timetype='年假' AND approvestatus='已批准' AND workdate>=a.this_njstart AND workdate<DATE_ADD(a.this_njstart,INTERVAL 1 YEAR)),0)
				WHEN a.hire_date>'1990-01-01' AND DATE_ADD(a.hire_date,INTERVAL 20 YEAR)<=CURDATE() THEN
					15*8-IFNULL((SELECT SUM(costtime) FROM vw_oa_attendance WHERE smownerid=a.id AND timetype='年假' AND approvestatus='已批准' AND workdate>=a.this_njstart AND workdate<DATE_ADD(a.this_njstart,INTERVAL 1 YEAR)),0)
				ELSE 112
			END AS total_sy_nj
		FROM (
			SELECT
					a.id,
					a.last_name,
					a.`status`,
					a.hire_date,
					CASE
						WHEN LENGTH(IFNULL(a.hire_date,''))<1 OR a.hire_date='0000-00-00' THEN NULL
						WHEN DATE_ADD(a.hire_date,INTERVAL YEAR(CURDATE())-YEAR(a.hire_date) YEAR)<=CURDATE() THEN
							DATE_ADD(a.hire_date,INTERVAL YEAR(CURDATE())-YEAR(a.hire_date) YEAR)
						ELSE
							DATE_ADD(a.hire_date,INTERVAL YEAR(CURDATE())-YEAR(a.hire_date)-1 YEAR)
					END AS this_njstart,
					CASE
						WHEN LENGTH(IFNULL(a.hire_date,''))<1 OR a.hire_date='0000-00-00' THEN NULL
						ELSE
							DATE_ADD(a.hire_date,INTERVAL 2017-YEAR(a.hire_date) YEAR)
					END AS extra_njend
				FROM ld_users a
		) a
	) t
	WHERE id=(SELECT smownerid FROM ld_addjobbill WHERE addjobbillid=NEW.addjobbillid) LIMIT 1;

	SET NEW.sytx=@total_sy_tx;
	SET NEW.synj=@total_sy_nj;	
	
END || 
delimiter;

drop trigger if exists `ldcrm_updatesykq_byminusjobbill`; 
delimiter || 
CREATE TRIGGER ldcrm_updatesykq_byminusjobbill 
AFTER UPDATE ON ld_minusjobbill 
FOR EACH ROW 
BEGIN 

	IF (new.approvestatus='已批准' and old.approvestatus<>'已批准') OR (new.approvestatus<>'已批准' and old.approvestatus='已批准') THEN
		CALL ldcrm_update_sykq_byuserid(new.smownerid);
	END IF;
	
END || 
delimiter;

drop trigger if exists `ldcrm_insertsykq_byminusjobbill`; 
delimiter || 
CREATE TRIGGER ldcrm_insertsykq_byminusjobbill 
BEFORE INSERT ON ld_minusjobbillscf 
FOR EACH ROW 
BEGIN 

	SET @total_sy_tx=0;
	SET @total_sy_nj=0;
	
	SELECT
		total_sy_tx into @total_sy_tx
	FROM (
		SELECT
			a.id, 
			a.last_name,
			IFNULL((SELECT SUM(costtime) FROM vw_oa_attendance WHERE smownerid=a.id AND timetype='加班' AND approvestatus='已批准'),0)
				-IFNULL((SELECT SUM(costtime) FROM vw_oa_attendance WHERE smownerid=a.id AND timetype='调休' AND approvestatus='已批准'),0) AS total_sy_tx,
			CASE
				WHEN LENGTH(IFNULL(a.hire_date,''))<1 OR a.hire_date='0000-00-00' THEN
					0-IFNULL((SELECT SUM(costtime) FROM vw_oa_attendance WHERE smownerid=a.id AND timetype='年假' AND approvestatus='已批准'),0)
				WHEN a.hire_date>'1990-01-01' AND DATE_ADD(a.hire_date,INTERVAL 1 YEAR)>CURDATE() THEN
					0
				WHEN a.hire_date>'1990-01-01' AND DATE_ADD(a.hire_date,INTERVAL 1 YEAR)<=CURDATE() AND DATE_ADD(a.hire_date,INTERVAL 10 YEAR)>CURDATE() THEN
					5*8-IFNULL((SELECT SUM(costtime) FROM vw_oa_attendance WHERE smownerid=a.id AND timetype='年假' AND approvestatus='已批准' AND workdate>=a.this_njstart AND workdate<DATE_ADD(a.this_njstart,INTERVAL 1 YEAR)),0)
				WHEN a.hire_date>'1990-01-01' AND DATE_ADD(a.hire_date,INTERVAL 10 YEAR)<=CURDATE() AND DATE_ADD(a.hire_date,INTERVAL 20 YEAR)>CURDATE() THEN
					10*8-IFNULL((SELECT SUM(costtime) FROM vw_oa_attendance WHERE smownerid=a.id AND timetype='年假' AND approvestatus='已批准' AND workdate>=a.this_njstart AND workdate<DATE_ADD(a.this_njstart,INTERVAL 1 YEAR)),0)
				WHEN a.hire_date>'1990-01-01' AND DATE_ADD(a.hire_date,INTERVAL 20 YEAR)<=CURDATE() THEN
					15*8-IFNULL((SELECT SUM(costtime) FROM vw_oa_attendance WHERE smownerid=a.id AND timetype='年假' AND approvestatus='已批准' AND workdate>=a.this_njstart AND workdate<DATE_ADD(a.this_njstart,INTERVAL 1 YEAR)),0)
				ELSE 112
			END AS total_sy_nj
		FROM (
			SELECT
					a.id,
					a.last_name,
					a.`status`,
					a.hire_date,
					CASE
						WHEN LENGTH(IFNULL(a.hire_date,''))<1 OR a.hire_date='0000-00-00' THEN NULL
						WHEN DATE_ADD(a.hire_date,INTERVAL YEAR(CURDATE())-YEAR(a.hire_date) YEAR)<=CURDATE() THEN
							DATE_ADD(a.hire_date,INTERVAL YEAR(CURDATE())-YEAR(a.hire_date) YEAR)
						ELSE
							DATE_ADD(a.hire_date,INTERVAL YEAR(CURDATE())-YEAR(a.hire_date)-1 YEAR)
					END AS this_njstart,
					CASE
						WHEN LENGTH(IFNULL(a.hire_date,''))<1 OR a.hire_date='0000-00-00' THEN NULL
						ELSE
							DATE_ADD(a.hire_date,INTERVAL 2017-YEAR(a.hire_date) YEAR)
					END AS extra_njend
				FROM ld_users a
		) a
	) t
	WHERE id=(SELECT smownerid FROM ld_minusjobbill WHERE minusjobbillid=NEW.minusjobbillid) LIMIT 1;
	
	SELECT
		concat(t.total_sy_nj,IFNULL(CONCAT('(',t.this_njstart,')'),'')) into @total_sy_nj
	FROM (
		SELECT
			a.id, 
			a.last_name,
            a.this_njstart,
			IFNULL((SELECT SUM(costtime) FROM vw_oa_attendance WHERE smownerid=a.id AND timetype='加班' AND approvestatus='已批准'),0)
				-IFNULL((SELECT SUM(costtime) FROM vw_oa_attendance WHERE smownerid=a.id AND timetype='调休' AND approvestatus='已批准'),0) AS total_sy_tx,
			CASE
				WHEN LENGTH(IFNULL(a.hire_date,''))<1 OR a.hire_date='0000-00-00' THEN
					0-IFNULL((SELECT SUM(costtime) FROM vw_oa_attendance WHERE smownerid=a.id AND timetype='年假' AND approvestatus='已批准'),0)
				WHEN a.hire_date>'1990-01-01' AND DATE_ADD(a.hire_date,INTERVAL 1 YEAR)>CURDATE() THEN
					0
				WHEN a.hire_date>'1990-01-01' AND DATE_ADD(a.hire_date,INTERVAL 1 YEAR)<=CURDATE() AND DATE_ADD(a.hire_date,INTERVAL 10 YEAR)>CURDATE() THEN
					5*8-IFNULL((SELECT SUM(costtime) FROM vw_oa_attendance WHERE smownerid=a.id AND timetype='年假' AND approvestatus='已批准' AND workdate>=a.this_njstart AND workdate<DATE_ADD(a.this_njstart,INTERVAL 1 YEAR)),0)
				WHEN a.hire_date>'1990-01-01' AND DATE_ADD(a.hire_date,INTERVAL 10 YEAR)<=CURDATE() AND DATE_ADD(a.hire_date,INTERVAL 20 YEAR)>CURDATE() THEN
					10*8-IFNULL((SELECT SUM(costtime) FROM vw_oa_attendance WHERE smownerid=a.id AND timetype='年假' AND approvestatus='已批准' AND workdate>=a.this_njstart AND workdate<DATE_ADD(a.this_njstart,INTERVAL 1 YEAR)),0)
				WHEN a.hire_date>'1990-01-01' AND DATE_ADD(a.hire_date,INTERVAL 20 YEAR)<=CURDATE() THEN
					15*8-IFNULL((SELECT SUM(costtime) FROM vw_oa_attendance WHERE smownerid=a.id AND timetype='年假' AND approvestatus='已批准' AND workdate>=a.this_njstart AND workdate<DATE_ADD(a.this_njstart,INTERVAL 1 YEAR)),0)
				ELSE 112
			END AS total_sy_nj
		FROM (
			SELECT
					a.id,
					a.last_name,
					a.`status`,
					a.hire_date,
					CASE
						WHEN LENGTH(IFNULL(a.hire_date,''))<1 OR a.hire_date='0000-00-00' THEN NULL
						WHEN DATE_ADD(a.hire_date,INTERVAL YEAR(CURDATE())-YEAR(a.hire_date) YEAR)<=CURDATE() THEN
							DATE_ADD(a.hire_date,INTERVAL YEAR(CURDATE())-YEAR(a.hire_date) YEAR)
						ELSE
							DATE_ADD(a.hire_date,INTERVAL YEAR(CURDATE())-YEAR(a.hire_date)-1 YEAR)
					END AS this_njstart,
					CASE
						WHEN LENGTH(IFNULL(a.hire_date,''))<1 OR a.hire_date='0000-00-00' THEN NULL
						ELSE
							DATE_ADD(a.hire_date,INTERVAL 2017-YEAR(a.hire_date) YEAR)
					END AS extra_njend
				FROM ld_users a
		) a
	) t
	WHERE id=(SELECT smownerid FROM ld_minusjobbill WHERE minusjobbillid=NEW.minusjobbillid) LIMIT 1;

	SET NEW.sytx=@total_sy_tx;
	SET NEW.synj=@total_sy_nj;	
	
END || 
delimiter;

insert into ld_addjobbillscf(addjobbillid)
select addjobbillid from ld_addjobbill where addjobbillid not in (select addjobbillid from ld_addjobbillscf);

insert into ld_minusjobbillscf(minusjobbillid)
select minusjobbillid from ld_minusjobbill where minusjobbillid not in (select minusjobbillid from ld_minusjobbillscf);

UPDATE ld_minusjobbill a
LEFT JOIN ld_minusjobbillscf b ON a.minusjobbillid=b.minusjobbillid
LEFT JOIN (
	SELECT
		a.id, 
		a.last_name,
        a.this_njstart,
		IFNULL((SELECT SUM(costtime) FROM vw_oa_attendance WHERE smownerid=a.id AND timetype='加班' AND approvestatus='已批准'),0)
			-IFNULL((SELECT SUM(costtime) FROM vw_oa_attendance WHERE smownerid=a.id AND timetype='调休' AND approvestatus='已批准'),0) AS total_sy_tx,
		CASE
			WHEN LENGTH(IFNULL(a.hire_date,''))<1 OR a.hire_date='0000-00-00' THEN
				0-IFNULL((SELECT SUM(costtime) FROM vw_oa_attendance WHERE smownerid=a.id AND timetype='年假' AND approvestatus='已批准'),0)
			WHEN a.hire_date>'1990-01-01' AND DATE_ADD(a.hire_date,INTERVAL 1 YEAR)>CURDATE() THEN
				0
			WHEN a.hire_date>'1990-01-01' AND DATE_ADD(a.hire_date,INTERVAL 1 YEAR)<=CURDATE() AND DATE_ADD(a.hire_date,INTERVAL 10 YEAR)>CURDATE() THEN
				5*8-IFNULL((SELECT SUM(costtime) FROM vw_oa_attendance WHERE smownerid=a.id AND timetype='年假' AND approvestatus='已批准' AND workdate>=a.this_njstart AND workdate<DATE_ADD(a.this_njstart,INTERVAL 1 YEAR)),0)
			WHEN a.hire_date>'1990-01-01' AND DATE_ADD(a.hire_date,INTERVAL 10 YEAR)<=CURDATE() AND DATE_ADD(a.hire_date,INTERVAL 20 YEAR)>CURDATE() THEN
				10*8-IFNULL((SELECT SUM(costtime) FROM vw_oa_attendance WHERE smownerid=a.id AND timetype='年假' AND approvestatus='已批准' AND workdate>=a.this_njstart AND workdate<DATE_ADD(a.this_njstart,INTERVAL 1 YEAR)),0)
			WHEN a.hire_date>'1990-01-01' AND DATE_ADD(a.hire_date,INTERVAL 20 YEAR)<=CURDATE() THEN
				15*8-IFNULL((SELECT SUM(costtime) FROM vw_oa_attendance WHERE smownerid=a.id AND timetype='年假' AND approvestatus='已批准' AND workdate>=a.this_njstart AND workdate<DATE_ADD(a.this_njstart,INTERVAL 1 YEAR)),0)
			ELSE 112
		END AS total_sy_nj
	FROM (
		SELECT
				a.id,
				a.last_name,
				a.`status`,
				a.hire_date,
				CASE
					WHEN LENGTH(IFNULL(a.hire_date,''))<1 OR a.hire_date='0000-00-00' THEN NULL
					WHEN DATE_ADD(a.hire_date,INTERVAL YEAR(CURDATE())-YEAR(a.hire_date) YEAR)<=CURDATE() THEN
						DATE_ADD(a.hire_date,INTERVAL YEAR(CURDATE())-YEAR(a.hire_date) YEAR)
					ELSE
						DATE_ADD(a.hire_date,INTERVAL YEAR(CURDATE())-YEAR(a.hire_date)-1 YEAR)
				END AS this_njstart,
				CASE
					WHEN LENGTH(IFNULL(a.hire_date,''))<1 OR a.hire_date='0000-00-00' THEN NULL
					ELSE
						DATE_ADD(a.hire_date,INTERVAL 2017-YEAR(a.hire_date) YEAR)
				END AS extra_njend
			FROM ld_users a
	) a
) t ON a.smownerid=t.id
SET b.sytx=t.total_sy_tx,b.synj=concat(t.total_sy_nj,IFNULL(CONCAT('(',t.this_njstart,')'),''));

UPDATE ld_addjobbill a
LEFT JOIN ld_addjobbillscf b ON a.addjobbillid=b.addjobbillid
LEFT JOIN (
	SELECT
		a.id, 
		a.last_name,
        a.this_njstart,
		IFNULL((SELECT SUM(costtime) FROM vw_oa_attendance WHERE smownerid=a.id AND timetype='加班' AND approvestatus='已批准'),0)
			-IFNULL((SELECT SUM(costtime) FROM vw_oa_attendance WHERE smownerid=a.id AND timetype='调休' AND approvestatus='已批准'),0) AS total_sy_tx,
		CASE
			WHEN LENGTH(IFNULL(a.hire_date,''))<1 OR a.hire_date='0000-00-00' THEN
				0-IFNULL((SELECT SUM(costtime) FROM vw_oa_attendance WHERE smownerid=a.id AND timetype='年假' AND approvestatus='已批准'),0)
			WHEN a.hire_date>'1990-01-01' AND DATE_ADD(a.hire_date,INTERVAL 1 YEAR)>CURDATE() THEN
				0
			WHEN a.hire_date>'1990-01-01' AND DATE_ADD(a.hire_date,INTERVAL 1 YEAR)<=CURDATE() AND DATE_ADD(a.hire_date,INTERVAL 10 YEAR)>CURDATE() THEN
				5*8-IFNULL((SELECT SUM(costtime) FROM vw_oa_attendance WHERE smownerid=a.id AND timetype='年假' AND approvestatus='已批准' AND workdate>=a.this_njstart AND workdate<DATE_ADD(a.this_njstart,INTERVAL 1 YEAR)),0)
			WHEN a.hire_date>'1990-01-01' AND DATE_ADD(a.hire_date,INTERVAL 10 YEAR)<=CURDATE() AND DATE_ADD(a.hire_date,INTERVAL 20 YEAR)>CURDATE() THEN
				10*8-IFNULL((SELECT SUM(costtime) FROM vw_oa_attendance WHERE smownerid=a.id AND timetype='年假' AND approvestatus='已批准' AND workdate>=a.this_njstart AND workdate<DATE_ADD(a.this_njstart,INTERVAL 1 YEAR)),0)
			WHEN a.hire_date>'1990-01-01' AND DATE_ADD(a.hire_date,INTERVAL 20 YEAR)<=CURDATE() THEN
				15*8-IFNULL((SELECT SUM(costtime) FROM vw_oa_attendance WHERE smownerid=a.id AND timetype='年假' AND approvestatus='已批准' AND workdate>=a.this_njstart AND workdate<DATE_ADD(a.this_njstart,INTERVAL 1 YEAR)),0)
			ELSE 112
		END AS total_sy_nj
	FROM (
		SELECT
				a.id,
				a.last_name,
				a.`status`,
				a.hire_date,
				CASE
					WHEN LENGTH(IFNULL(a.hire_date,''))<1 OR a.hire_date='0000-00-00' THEN NULL
					WHEN DATE_ADD(a.hire_date,INTERVAL YEAR(CURDATE())-YEAR(a.hire_date) YEAR)<=CURDATE() THEN
						DATE_ADD(a.hire_date,INTERVAL YEAR(CURDATE())-YEAR(a.hire_date) YEAR)
					ELSE
						DATE_ADD(a.hire_date,INTERVAL YEAR(CURDATE())-YEAR(a.hire_date)-1 YEAR)
				END AS this_njstart,
				CASE
					WHEN LENGTH(IFNULL(a.hire_date,''))<1 OR a.hire_date='0000-00-00' THEN NULL
					ELSE
						DATE_ADD(a.hire_date,INTERVAL 2017-YEAR(a.hire_date) YEAR)
				END AS extra_njend
			FROM ld_users a
	) a
) t ON a.smownerid=t.id
SET b.sytx=t.total_sy_tx,b.synj=concat(t.total_sy_nj,IFNULL(CONCAT('(',t.this_njstart,')'),''));

SET @tabname='AddJobBill';
SET @viewname='All';
SELECT tabid into @tabid FROM ld_tab WHERE `name`=@tabname;
SELECT cvid into @cvid FROM ld_customview WHERE entitytype=@tabname AND viewname=@viewname LIMIT 1;
DELETE FROM ld_tabwithproductview WHERE cvid=@cvid AND tabid=@tabid;
SET @i=0;
INSERT INTO ld_tabwithproductview(tabid,`columns`,sequence,cvid)
SELECT @tabid,'ld_addjobbill:addjobbill_no:addjobbill_no:AddJobBill_fieldlabel:V',@i,@cvid;

INSERT INTO ld_tabwithproductview(tabid,`columns`,sequence,cvid)
SELECT @tabid,'ld_addjobbill:smownerid:assigned_user_id:AddJobBill_fieldlabel:V',(@i:=@i+1),@cvid;

INSERT INTO ld_tabwithproductview(tabid,`columns`,sequence,cvid)
SELECT @tabid,'ld_addjobbillscf:sytx:sytx:AddJobBill_fieldlabel:V',(@i:=@i+1),@cvid;

INSERT INTO ld_tabwithproductview(tabid,`columns`,sequence,cvid)
SELECT @tabid,'ld_addjobbillscf:synj:synj:AddJobBill_fieldlabel:V',(@i:=@i+1),@cvid;

INSERT INTO ld_tabwithproductview(tabid,`columns`,sequence,cvid)
SELECT @tabid,'ld_addjobbill:approvestatus:approvestatus:AddJobBill_fieldlabel:V',(@i:=@i+1),@cvid;

INSERT INTO ld_tabwithproductview(tabid,`columns`,sequence,cvid)
SELECT @tabid,'ld_addjobbill:currentapprover:currentapprover:AddJobBill_fieldlabel:V',(@i:=@i+1),@cvid;

INSERT INTO ld_tabwithproductview(tabid,`columns`,sequence,cvid)
SELECT @tabid,'ld_addjobbilldetail:starttime:starttime:AddJobBillDetails_fieldlabel:DT',(@i:=@i+1),@cvid;

INSERT INTO ld_tabwithproductview(tabid,`columns`,sequence,cvid)
SELECT @tabid,'ld_addjobbilldetail:endtime:endtime:AddJobBillDetails_fieldlabel:DT',(@i:=@i+1),@cvid;

INSERT INTO ld_tabwithproductview(tabid,`columns`,sequence,cvid)
SELECT @tabid,'ld_addjobbilldetail:costtime:costtime:AddJobBillDetails_fieldlabel:N',(@i:=@i+1),@cvid;

INSERT INTO ld_tabwithproductview(tabid,`columns`,sequence,cvid)
SELECT @tabid,'ld_addjobbilldetail:description:description:AddJobBillDetails_fieldlabel:V',(@i:=@i+1),@cvid;
delimiter;

SET @tabname='AddJobBill';
SET @viewname='已批准';
SELECT tabid into @tabid FROM ld_tab WHERE `name`=@tabname;
SELECT cvid into @cvid FROM ld_customview WHERE entitytype=@tabname AND viewname=@viewname LIMIT 1;
SELECT cvid into @cvid_all FROM ld_customview WHERE entitytype=@tabname AND viewname='All' LIMIT 1;
DELETE FROM ld_tabwithproductview WHERE cvid=@cvid AND tabid=@tabid;
INSERT INTO ld_tabwithproductview(tabid,`columns`,sequence,cvid)
SELECT @tabid,`columns`,sequence,@cvid FROM ld_tabwithproductview WHERE cvid=@cvid_all;
delimiter;

SET @tabname='AddJobBill';
SET @viewname='审批中';
SELECT tabid into @tabid FROM ld_tab WHERE `name`=@tabname;
SELECT cvid into @cvid FROM ld_customview WHERE entitytype=@tabname AND viewname=@viewname LIMIT 1;
SELECT cvid into @cvid_all FROM ld_customview WHERE entitytype=@tabname AND viewname='All' LIMIT 1;
DELETE FROM ld_tabwithproductview WHERE cvid=@cvid AND tabid=@tabid;
INSERT INTO ld_tabwithproductview(tabid,`columns`,sequence,cvid)
SELECT @tabid,`columns`,sequence,@cvid FROM ld_tabwithproductview WHERE cvid=@cvid_all;
delimiter;

SET @tabname='AddJobBill';
SET @viewname='未提交';
SELECT tabid into @tabid FROM ld_tab WHERE `name`=@tabname;
SELECT cvid into @cvid FROM ld_customview WHERE entitytype=@tabname AND viewname=@viewname LIMIT 1;
SELECT cvid into @cvid_all FROM ld_customview WHERE entitytype=@tabname AND viewname='All' LIMIT 1;
DELETE FROM ld_tabwithproductview WHERE cvid=@cvid AND tabid=@tabid;
INSERT INTO ld_tabwithproductview(tabid,`columns`,sequence,cvid)
SELECT @tabid,`columns`,sequence,@cvid FROM ld_tabwithproductview WHERE cvid=@cvid_all;
delimiter;

SET @tabname='AddJobBill';
SET @viewname='已驳回';
SELECT tabid into @tabid FROM ld_tab WHERE `name`=@tabname;
SELECT cvid into @cvid FROM ld_customview WHERE entitytype=@tabname AND viewname=@viewname LIMIT 1;
SELECT cvid into @cvid_all FROM ld_customview WHERE entitytype=@tabname AND viewname='All' LIMIT 1;
DELETE FROM ld_tabwithproductview WHERE cvid=@cvid AND tabid=@tabid;
INSERT INTO ld_tabwithproductview(tabid,`columns`,sequence,cvid)
SELECT @tabid,`columns`,sequence,@cvid FROM ld_tabwithproductview WHERE cvid=@cvid_all;
delimiter;

SET @tabname='AddJobBill';
SET @viewname='已拒绝';
SELECT tabid into @tabid FROM ld_tab WHERE `name`=@tabname;
SELECT cvid into @cvid FROM ld_customview WHERE entitytype=@tabname AND viewname=@viewname LIMIT 1;
SELECT cvid into @cvid_all FROM ld_customview WHERE entitytype=@tabname AND viewname='All' LIMIT 1;
DELETE FROM ld_tabwithproductview WHERE cvid=@cvid AND tabid=@tabid;
INSERT INTO ld_tabwithproductview(tabid,`columns`,sequence,cvid)
SELECT @tabid,`columns`,sequence,@cvid FROM ld_tabwithproductview WHERE cvid=@cvid_all;
delimiter;

SET @tabname='MinusJobBill';
SET @viewname='All';
SELECT tabid into @tabid FROM ld_tab WHERE `name`=@tabname;
SELECT cvid into @cvid FROM ld_customview WHERE entitytype=@tabname AND viewname=@viewname LIMIT 1;
DELETE FROM ld_tabwithproductview WHERE cvid=@cvid AND tabid=@tabid;
SET @i=0;
INSERT INTO ld_tabwithproductview(tabid,`columns`,sequence,cvid)
SELECT @tabid,'ld_minusjobbill:minusjobbill_no:minusjobbill_no:MinusJobBill_fieldlabel:V',@i,@cvid;

INSERT INTO ld_tabwithproductview(tabid,`columns`,sequence,cvid)
SELECT @tabid,'ld_minusjobbill:smownerid:assigned_user_id:MinusJobBill_fieldlabel:V',(@i:=@i+1),@cvid;

INSERT INTO ld_tabwithproductview(tabid,`columns`,sequence,cvid)
SELECT @tabid,'ld_minusjobbillscf:sytx:sytx:MinusJobBill_fieldlabel:V',(@i:=@i+1),@cvid;

INSERT INTO ld_tabwithproductview(tabid,`columns`,sequence,cvid)
SELECT @tabid,'ld_minusjobbillscf:synj:synj:MinusJobBill_fieldlabel:V',(@i:=@i+1),@cvid;

INSERT INTO ld_tabwithproductview(tabid,`columns`,sequence,cvid)
SELECT @tabid,'ld_minusjobbill:approvestatus:approvestatus:MinusJobBill_fieldlabel:V',(@i:=@i+1),@cvid;

INSERT INTO ld_tabwithproductview(tabid,`columns`,sequence,cvid)
SELECT @tabid,'ld_minusjobbill:currentapprover:currentapprover:MinusJobBill_fieldlabel:V',(@i:=@i+1),@cvid;

INSERT INTO ld_tabwithproductview(tabid,`columns`,sequence,cvid)
SELECT @tabid,'ld_minusjobbilldetail:minusjobtype:minusjobtype:MinusJobBillDetails_fieldlabel:DT',(@i:=@i+1),@cvid;

INSERT INTO ld_tabwithproductview(tabid,`columns`,sequence,cvid)
SELECT @tabid,'ld_minusjobbilldetail:starttime:starttime:MinusJobBillDetails_fieldlabel:DT',(@i:=@i+1),@cvid;

INSERT INTO ld_tabwithproductview(tabid,`columns`,sequence,cvid)
SELECT @tabid,'ld_minusjobbilldetail:endtime:endtime:MinusJobBillDetails_fieldlabel:DT',(@i:=@i+1),@cvid;

INSERT INTO ld_tabwithproductview(tabid,`columns`,sequence,cvid)
SELECT @tabid,'ld_minusjobbilldetail:costtime:costtime:MinusJobBillDetails_fieldlabel:N',(@i:=@i+1),@cvid;
delimiter;

INSERT INTO ld_tabwithproductview(tabid,`columns`,sequence,cvid)
SELECT @tabid,'ld_minusjobbilldetail:description:description:MinusJobBillDetails_fieldlabel:V',(@i:=@i+1),@cvid;
delimiter;

SET @tabname='MinusJobBill';
SET @viewname='已批准';
SELECT tabid into @tabid FROM ld_tab WHERE `name`=@tabname;
SELECT cvid into @cvid FROM ld_customview WHERE entitytype=@tabname AND viewname=@viewname LIMIT 1;
SELECT cvid into @cvid_all FROM ld_customview WHERE entitytype=@tabname AND viewname='All' LIMIT 1;
DELETE FROM ld_tabwithproductview WHERE cvid=@cvid AND tabid=@tabid;
INSERT INTO ld_tabwithproductview(tabid,`columns`,sequence,cvid)
SELECT @tabid,`columns`,sequence,@cvid FROM ld_tabwithproductview WHERE cvid=@cvid_all;
delimiter;

SET @tabname='MinusJobBill';
SET @viewname='审批中';
SELECT tabid into @tabid FROM ld_tab WHERE `name`=@tabname;
SELECT cvid into @cvid FROM ld_customview WHERE entitytype=@tabname AND viewname=@viewname LIMIT 1;
SELECT cvid into @cvid_all FROM ld_customview WHERE entitytype=@tabname AND viewname='All' LIMIT 1;
DELETE FROM ld_tabwithproductview WHERE cvid=@cvid AND tabid=@tabid;
INSERT INTO ld_tabwithproductview(tabid,`columns`,sequence,cvid)
SELECT @tabid,`columns`,sequence,@cvid FROM ld_tabwithproductview WHERE cvid=@cvid_all;
delimiter;

SET @tabname='MinusJobBill';
SET @viewname='未提交';
SELECT tabid into @tabid FROM ld_tab WHERE `name`=@tabname;
SELECT cvid into @cvid FROM ld_customview WHERE entitytype=@tabname AND viewname=@viewname LIMIT 1;
SELECT cvid into @cvid_all FROM ld_customview WHERE entitytype=@tabname AND viewname='All' LIMIT 1;
DELETE FROM ld_tabwithproductview WHERE cvid=@cvid AND tabid=@tabid;
INSERT INTO ld_tabwithproductview(tabid,`columns`,sequence,cvid)
SELECT @tabid,`columns`,sequence,@cvid FROM ld_tabwithproductview WHERE cvid=@cvid_all;
delimiter;

SET @tabname='MinusJobBill';
SET @viewname='已驳回';
SELECT tabid into @tabid FROM ld_tab WHERE `name`=@tabname;
SELECT cvid into @cvid FROM ld_customview WHERE entitytype=@tabname AND viewname=@viewname LIMIT 1;
SELECT cvid into @cvid_all FROM ld_customview WHERE entitytype=@tabname AND viewname='All' LIMIT 1;
DELETE FROM ld_tabwithproductview WHERE cvid=@cvid AND tabid=@tabid;
INSERT INTO ld_tabwithproductview(tabid,`columns`,sequence,cvid)
SELECT @tabid,`columns`,sequence,@cvid FROM ld_tabwithproductview WHERE cvid=@cvid_all;
delimiter;

SET @tabname='MinusJobBill';
SET @viewname='已拒绝';
SELECT tabid into @tabid FROM ld_tab WHERE `name`=@tabname;
SELECT cvid into @cvid FROM ld_customview WHERE entitytype=@tabname AND viewname=@viewname LIMIT 1;
SELECT cvid into @cvid_all FROM ld_customview WHERE entitytype=@tabname AND viewname='All' LIMIT 1;
DELETE FROM ld_tabwithproductview WHERE cvid=@cvid AND tabid=@tabid;
INSERT INTO ld_tabwithproductview(tabid,`columns`,sequence,cvid)
SELECT @tabid,`columns`,sequence,@cvid FROM ld_tabwithproductview WHERE cvid=@cvid_all;
delimiter;

DROP PROCEDURE IF EXISTS `ldcrm_add_reminder`;
delimiter ||
CREATE PROCEDURE `ldcrm_add_reminder`(
	tmp_content text,
	tmp_recieverid int(19),
    tmp_reltab varchar(100),
	tmp_related_to int(19)
    
)
BEGIN
	
	set @maxid=0;
	select max(crmid) into @maxid from ld_crmentity;
	insert into ld_crmentity(crmid,setype)
	select @maxid+1,'Reminds';			
	insert into ld_reminds(remindsid,content,date_time,recieverid,status_rmd,related_to,reltab,is_del_send,is_del_rec,reminds_ruleid,smownerid,smcreatorid,modifiedby,createdtime,modifiedtime,description,deleted)
	select @maxid+1,tmp_content,now(),tmp_recieverid,'未读',tmp_related_to,tmp_reltab,0,0,0,0,0,0,now(),now(),null,0;

	update ld_crmentity_seq set id=(select max(crmid) from ld_crmentity);

end ||
delimiter;

DROP PROCEDURE IF EXISTS `task_gonggao_reminder`;
delimiter ||
CREATE PROCEDURE `task_gonggao_reminder`(
)
BEGIN
	
	DECLARE tmp_id INT(19) DEFAULT 0;
	DECLARE tmp_userid INT(19) DEFAULT 0;
	DECLARE tmp_content text DEFAULT '';

	DECLARE Mycur CURSOR FOR
		SELECT 
			a.publicannouncementid,
			b.userid
		FROM ld_publicannouncement a
		LEFT JOIN ld_publicannouncement_reminds b ON a.publicannouncementid=b.crmid
		WHERE a.deleted=0
			AND CURDATE() BETWEEN startdate AND enddate
			AND NOT EXISTS (SELECT 1 FROM ld_reminds WHERE related_to=a.publicannouncementid AND recieverid=b.userid AND content like '公告提醒：有新的公告，请及时关注！');

	DECLARE CONTINUE HANDLER FOR SQLSTATE '02000' set tmp_id = NULL;

	OPEN Mycur;
	FETCH Mycur INTO tmp_id,tmp_userid;
	WHILE (tmp_id IS NOT NULL) DO
		SET @content='公告提醒：有新的公告，请及时关注！';
		CALL ldcrm_add_reminder(@content,tmp_userid,'PublicAnnouncement',tmp_id);
		FETCH Mycur INTO tmp_id,tmp_userid;
	END WHILE;
	CLOSE Mycur;	
end ||
delimiter;

SET GLOBAL event_scheduler = on;
DROP EVENT IF EXISTS `task_gonggao_reminder`;
CREATE EVENT `task_gonggao_reminder`
ON SCHEDULE EVERY 300 SECOND STARTS '2017-06-23 14:00:00'
ON COMPLETION NOT PRESERVE
ENABLE
DO

CALL task_gonggao_reminder();
delimiter;
-- 2017-07-04

select tabid into @tabid from ld_tab where `name` = 'Expense';
select tabdetailfieldid into @tabdetailfieldid from ld_tabdetailfield where tabid = @tabid and columnname = 'total';
update ld_tabdetailfield_formula set columnstring = "{formulavar:[{'lettervar':'a','column':'rmb_total'}]}" where tabdetailfieldid = @tabdetailfieldid;
delimiter;

INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','row','行','jspop' from dual
where not exists(select 1 from ld_desk where languagetype = 'zh' and labelbol = 'row' and labeltype = 'jspop');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','row','Row','jspop' from dual
where not exists(select 1 from ld_desk where languagetype = 'en' and labelbol = 'row' and labeltype = 'jspop');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,Labeltype)
select 'zh','APPROVEALSTATUS1ORDELETED','该审批流程已经被禁用或者删除，请联系系统管理员！','fixedstr'
from dual where not exists 
(select 1 from ld_desk where labelbol='APPROVEALSTATUS1ORDELETED' and Labeltype='fixedstr' and languagetype='zh');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,Labeltype)
select 'zh','APPROVEALSTATUS1ORDELETED','该审批流程已经被禁用或者删除，请联系系统管理员！','fixedstr'
from dual where not exists 
(select 1 from ld_desk where labelbol='APPROVEALSTATUS1ORDELETED' and Labeltype='fixedstr' and languagetype='zh');
delimiter;

update ld_tab set mobilepresence='mobile,weixin' where name 
in('Vendors','VendorContact','VendorContactRecords','PurchaseOrder','ServiceCharge','OutBoundOrder','TimeSheet');
delimiter;

insert into ld_appparenttab(blockname,presence,sequence,systemdefault)
select '仓库管理',0,7,'yes' from dual 
where not exists(select 1 from ld_appparenttab where blockname = '仓库管理');
select tabid into @tabid from ld_tab where name='OutBoundOrder';
insert into ld_appparenttabrel(blockid,tabid,sequence)
select 7,@tabid,1 from dual 
where not exists(select 1 from ld_appparenttabrel where tabid=@tabid);
delimiter;

select tabid into @tabid from ld_tab where name='TimeSheet';
insert into ld_appparenttabrel(blockid,tabid,sequence)
select 6,@tabid,3 from dual 
where not exists(select 1 from ld_appparenttabrel where tabid=@tabid);
delimiter;

CREATE TABLE IF NOT EXISTS `ld_attachmentstype` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `file_type` varchar(200) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=45 DEFAULT CHARSET=utf8;
delimiter;

insert into ld_attachmentstype(file_type)
select 'doc' from DUAL
where not exists(select 1 from ld_attachmentstype where file_type = 'doc');

insert into ld_attachmentstype(file_type)
select 'docx' from DUAL
where not exists(select 1 from ld_attachmentstype where file_type = 'docx');

insert into ld_attachmentstype(file_type)
select 'xls' from DUAL
where not exists(select 1 from ld_attachmentstype where file_type = 'xls');

insert into ld_attachmentstype(file_type)
select 'xlsx' from DUAL
where not exists(select 1 from ld_attachmentstype where file_type = 'xlsx');

insert into ld_attachmentstype(file_type)
select 'csv' from DUAL
where not exists(select 1 from ld_attachmentstype where file_type = 'csv');

insert into ld_attachmentstype(file_type)
select 'ppt' from DUAL
where not exists(select 1 from ld_attachmentstype where file_type = 'ppt');

insert into ld_attachmentstype(file_type)
select 'pptx' from DUAL
where not exists(select 1 from ld_attachmentstype where file_type = 'pptx');

insert into ld_attachmentstype(file_type)
select 'pdf' from DUAL
where not exists(select 1 from ld_attachmentstype where file_type = 'pdf');

insert into ld_attachmentstype(file_type)
select 'txt' from DUAL
where not exists(select 1 from ld_attachmentstype where file_type = 'txt');

insert into ld_attachmentstype(file_type)
select 'png' from DUAL
where not exists(select 1 from ld_attachmentstype where file_type = 'png');

insert into ld_attachmentstype(file_type)
select 'jpg' from DUAL
where not exists(select 1 from ld_attachmentstype where file_type = 'jpg');

insert into ld_attachmentstype(file_type)
select 'jpeg' from DUAL
where not exists(select 1 from ld_attachmentstype where file_type = 'jpeg');

insert into ld_attachmentstype(file_type)
select 'gif' from DUAL
where not exists(select 1 from ld_attachmentstype where file_type = 'gif');

insert into ld_attachmentstype(file_type)
select 'bmp' from DUAL
where not exists(select 1 from ld_attachmentstype where file_type = 'bmp');

insert into ld_attachmentstype(file_type)
select 'ico' from DUAL
where not exists(select 1 from ld_attachmentstype where file_type = 'ico');

insert into ld_attachmentstype(file_type)
select 'rar' from DUAL
where not exists(select 1 from ld_attachmentstype where file_type = 'rar');

insert into ld_attachmentstype(file_type)
select 'zip' from DUAL
where not exists(select 1 from ld_attachmentstype where file_type = 'zip');

insert into ld_attachmentstype(file_type)
select 'iso' from DUAL
where not exists(select 1 from ld_attachmentstype where file_type = 'iso');

insert into ld_attachmentstype(file_type)
select 'chm' from DUAL
where not exists(select 1 from ld_attachmentstype where file_type = 'chm');

insert into ld_attachmentstype(file_type)
select 'chw' from DUAL
where not exists(select 1 from ld_attachmentstype where file_type = 'chw');

insert into ld_attachmentstype(file_type)
select 'dat' from DUAL
where not exists(select 1 from ld_attachmentstype where file_type = 'dat');

insert into ld_attachmentstype(file_type)
select 'dot' from DUAL
where not exists(select 1 from ld_attachmentstype where file_type = 'dot');

insert into ld_attachmentstype(file_type)
select 'dps' from DUAL
where not exists(select 1 from ld_attachmentstype where file_type = 'dps');

insert into ld_attachmentstype(file_type)
select 'dpt' from DUAL
where not exists(select 1 from ld_attachmentstype where file_type = 'dpt');

insert into ld_attachmentstype(file_type)
select 'et' from DUAL
where not exists(select 1 from ld_attachmentstype where file_type = 'et');

insert into ld_attachmentstype(file_type)
select 'ett' from DUAL
where not exists(select 1 from ld_attachmentstype where file_type = 'ett');

insert into ld_attachmentstype(file_type)
select 'html' from DUAL
where not exists(select 1 from ld_attachmentstype where file_type = 'html');

insert into ld_attachmentstype(file_type)
select 'ini' from DUAL
where not exists(select 1 from ld_attachmentstype where file_type = 'ini');

insert into ld_attachmentstype(file_type)
select 'js' from DUAL
where not exists(select 1 from ld_attachmentstype where file_type = 'js');

insert into ld_attachmentstype(file_type)
select 'ptf' from DUAL
where not exists(select 1 from ld_attachmentstype where file_type = 'ptf');

insert into ld_attachmentstype(file_type)
select 'pot' from DUAL
where not exists(select 1 from ld_attachmentstype where file_type = 'pot');

insert into ld_attachmentstype(file_type)
select 'pps' from DUAL
where not exists(select 1 from ld_attachmentstype where file_type = 'pps');

insert into ld_attachmentstype(file_type)
select 'rtf' from DUAL
where not exists(select 1 from ld_attachmentstype where file_type = 'rtf');

insert into ld_attachmentstype(file_type)
select 'sql' from DUAL
where not exists(select 1 from ld_attachmentstype where file_type = 'sql');

insert into ld_attachmentstype(file_type)
select 'wps' from DUAL
where not exists(select 1 from ld_attachmentstype where file_type = 'wps');

insert into ld_attachmentstype(file_type)
select 'wpt' from DUAL
where not exists(select 1 from ld_attachmentstype where file_type = 'wpt');

insert into ld_attachmentstype(file_type)
select 'xml' from DUAL
where not exists(select 1 from ld_attachmentstype where file_type = 'xml');

insert into ld_attachmentstype(file_type)
select 'xlt' from DUAL
where not exists(select 1 from ld_attachmentstype where file_type = 'xlt');

insert into ld_attachmentstype(file_type)
select 'eml' from DUAL
where not exists(select 1 from ld_attachmentstype where file_type = 'eml');

insert into ld_attachmentstype(file_type)
select 'msg' from DUAL
where not exists(select 1 from ld_attachmentstype where file_type = 'msg');

insert into ld_attachmentstype(file_type)
select 'dwg' from DUAL
where not exists(select 1 from ld_attachmentstype where file_type = 'dwg');

insert into ld_attachmentstype(file_type)
select 'vsd' from DUAL
where not exists(select 1 from ld_attachmentstype where file_type = 'vsd');

insert into ld_attachmentstype(file_type)
select 'sn' from DUAL
where not exists(select 1 from ld_attachmentstype where file_type = 'sn');

insert into ld_attachmentstype(file_type)
select 'mpp' from DUAL
where not exists(select 1 from ld_attachmentstype where file_type = 'mpp');
delimiter;

INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','setthefileformat','设置允许上传的文件格式','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype = 'zh' and labelbol = 'setthefileformat' and labeltype = 'fixedstr');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','setthefileformat','Set the file format that you can upload','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype = 'en' and labelbol = 'setthefileformat' and labeltype = 'fixedstr');
delimiter;

INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','viewthefileformat','查看允许上传的文件格式','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype = 'zh' and labelbol = 'viewthefileformat' and labeltype = 'fixedstr');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','viewthefileformat','View the file format that you can upload','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype = 'en' and labelbol = 'viewthefileformat' and labeltype = 'fixedstr');
delimiter;

INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','fileformat','文件格式','jspop' from dual
where not exists(select 1 from ld_desk where languagetype = 'zh' and labelbol = 'fileformat' and labeltype = 'jspop');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','fileformat','File Format','jspop' from dual
where not exists(select 1 from ld_desk where languagetype = 'en' and labelbol = 'fileformat' and labeltype = 'jspop');
delimiter;

update ld_customreport_info set report_name='即时库存余额表' where report_template='default_warehouse_products.mrt' and systemdefault=1 and report_name='库存余额表';

update ld_producttoolfield set typeofdata='V~O' where columnname='product_no' and uitype=4 and tablename='ld_products' and defaultcolumn=4;

select tabid into @tabid from ld_tab where `name`='ServiceCharge';
update ld_field set typeofdata='V~M' where tabid=@tabid and columnname='servicecasher';
delimiter;

select tabid into @tabid from ld_tab where `name` = 'PaymentPlan';
update ld_field set searchfieldtype = 0 where tabid = @tabid and columnname in('paymentplan_no','plandate','actualdate','smownerid');
delimiter;
-- 2017-07-05

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

update ld_version set old_version='V7.0.4',current_version='V7.0.4',remark='V7.0.4-20170705';
delimiter;