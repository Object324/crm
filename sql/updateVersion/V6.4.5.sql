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
select 'zh','CUSTOMERBILLSTATE','{$Accounts.bill_state}分布统计','fixedstr' from dual 
where not exists(select 1 from ld_desk where labelbol = 'CUSTOMERBILLSTATE' and languagetype = 'zh' and labeltype = 'fixedstr');
delimiter;
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','CUSTOMERBILLSTATE','{$Accounts.bill_state} distribution statistics','fixedstr' from dual 
where not exists(select 1 from ld_desk where labelbol = 'CUSTOMERBILLSTATE' and languagetype = 'en' and labeltype = 'fixedstr');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','CUSTOMERBILLCITY','{$Accounts.bill_city}分布统计','fixedstr' from dual 
where not exists(select 1 from ld_desk where labelbol = 'CUSTOMERBILLCITY' and languagetype = 'zh' and labeltype = 'fixedstr');
delimiter;
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','CUSTOMERBILLCITY','{$Accounts.bill_city} distribution statistics','fixedstr' from dual 
where not exists(select 1 from ld_desk where labelbol = 'CUSTOMERBILLCITY' and languagetype = 'en' and labeltype = 'fixedstr');
delimiter;

select tabid into @tabid from ld_tab where name='potentials';
select max(relation_id) into @relation_id from ld_relatedlists;
update ld_relatedlists_seq set id=@relation_id+1 where not exists(select 1 from ld_relatedlists where tabid=@tabid and related_tabid=9 and name='get_schedule');
insert into ld_relatedlists(relation_id,tabid,related_tabid,name,sequence,label,presence,actions,mobile_presence,mobile_sequence)
select @relation_id+1,@tabid,9,'get_schedule',12,'Calendar',0,'add',0,0 from dual 
where not exists(select 1 from ld_relatedlists where tabid=@tabid and related_tabid=9 and name='get_schedule');

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'zh','OFTOO','共','fixedstr' from dual 
where not EXISTS(select 1 from ld_desk where languagetype='zh' and labelbol='OFTOO' and Labeltype='fixedstr'); 
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'en','OFTOO','of','fixedstr' from dual 
where not EXISTS(select 1 from ld_desk where languagetype='en' and labelbol='OFTOO' and Labeltype='fixedstr'); 
delimiter; 

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) 
select 'zh','SENDERCANOTEMPTY','发件人不能为空!','jspop' from dual 
where not EXISTS(select 1 from ld_desk  where languagetype='zh' and labelbol='SENDERCANOTEMPTY' and Labeltype='jspop');

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) 
select 'en','SENDERCANOTEMPTY','sender can not tempty!','jspop' from dual 
where not EXISTS(select 1 from ld_desk  where languagetype='en' and labelbol='SENDERCANOTEMPTY' and Labeltype='jspop');
delimiter;
-- 2016-07-18

set @modulename='HelpDesk';
select tabid into @tabid from ld_tab where `name`=@modulename;
select blockid into @blockid from ld_blocks where tabid=@tabid and blocklabel='LBL_TICKET_INFORMATION';
set @tablename='ld_troubletickets';
set @columnname='distributetime';
set @fieldname='distributetime';
set @zh='最新分配时间';
set @en='Last distribute time';
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

call AddColumn(@tablename,@columnname,'varchar','100',NULL);
delimiter;

alter table ld_troubletickets modify column distributetime datetime;
delimiter;

call fieldprofile('HelpDesk');
delimiter;
call getallprofile('HelpDesk');
delimiter;

drop trigger if exists update_tickets_distributetime; 
delimiter || 
CREATE TRIGGER update_tickets_distributetime 
BEFORE UPDATE ON ld_troubletickets 
FOR EACH ROW 
BEGIN 
		
		IF new.smownerid>0 and new.smownerid<>old.smownerid THEN
				set new.distributetime=now();
		END IF;

END || 
delimiter;

set @modulename='ProjectTask';
select tabid into @tabid from ld_tab where `name`=@modulename;
select blockid into @blockid from ld_blocks where tabid=@tabid and blocklabel='LBL_PROJECT_TASK_INFORMATION';
set @tablename='ld_projecttask';
set @columnname='distributetime';
set @fieldname='distributetime';
set @zh='最新分配时间';
set @en='Last distribute time';
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

call AddColumn(@tablename,@columnname,'varchar','100',NULL);
delimiter;

alter table ld_troubletickets modify column distributetime datetime;
delimiter;

call fieldprofile('ProjectTask');
delimiter;
call getallprofile('ProjectTask');
delimiter;

drop trigger if exists update_projecttask_distributetime; 
delimiter || 
CREATE TRIGGER update_projecttask_distributetime 
BEFORE UPDATE ON ld_projecttask 
FOR EACH ROW 
BEGIN 
		
		IF new.smownerid>0 and new.smownerid<>old.smownerid THEN
				set new.distributetime=now();
		END IF;

END || 
delimiter;

update ld_workcalender set workcalender_name='默认工作日(Default calender)' where workcalender_id=1;
update ld_desk set fieldlabel='Add' where labelbol='ADDITION' and languagetype='en' and Labeltype='fixedstr';

select tabid into @tabid from ld_tab where `name` = 'ServiceReturn'; 
delete from ld_profileallpermission where tabid=@tabid and operation=5;
delimiter;
-- 2016-07-19

update ld_desk set fieldlabel='小数位数' where labelbol ='PRECISION' AND Labeltype='fixedstr' AND languagetype='zh';
update ld_desk set fieldlabel='小数位数' where labelbol ='PRECISIONVALUE' AND Labeltype='jspop' AND languagetype='zh';
update ld_desk set fieldlabel='Decimal digits' where labelbol in('PRECISION','PRECISIONVALUE') AND languagetype='en';
delimiter;
SELECT max(relation_id) into @max_relation_id from ld_relatedlists;
update ld_relatedlists set relation_id=@max_relation_id+1 where tabid=2 AND label='Calendar' AND related_tabid=9 AND relation_id=0;
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','TRACKGROUP','轨迹定位组','fixedstr' from dual 
where not exists(select 1 from ld_desk where labelbol = 'TRACKGROUP' and languagetype = 'zh' and labeltype = 'fixedstr');
delimiter;
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','TRACKGROUP','track group','fixedstr' from dual 
where not exists(select 1 from ld_desk where labelbol = 'TRACKGROUP' and languagetype = 'en' and labeltype = 'fixedstr');
delimiter;
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','ADDSPECIALDAY','添加特殊工作日','fixedstr' from dual 
where not exists(select 1 from ld_desk where labelbol = 'ADDSPECIALDAY' and languagetype = 'zh' and labeltype = 'fixedstr');
delimiter;
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','ADDSPECIALDAY','Add special working day','fixedstr' from dual 
where not exists(select 1 from ld_desk where labelbol = 'ADDSPECIALDAY' and languagetype = 'en' and labeltype = 'fixedstr');
delimiter;
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','ADDHOLIDAYVACATION','添加节假日','fixedstr' from dual 
where not exists(select 1 from ld_desk where labelbol = 'ADDHOLIDAYVACATION' and languagetype = 'zh' and labeltype = 'fixedstr');
delimiter;
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','ADDHOLIDAYVACATION','Add holiday and vacations','fixedstr' from dual 
where not exists(select 1 from ld_desk where labelbol = 'ADDHOLIDAYVACATION' and languagetype = 'en' and labeltype = 'fixedstr');
delimiter;
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','ADDITIONAL','添加','fixedstr' from dual 
where not exists(select 1 from ld_desk where labelbol = 'ADDITIONAL' and languagetype = 'zh' and labeltype = 'fixedstr');
delimiter;
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','ADDITIONAL','Add','fixedstr' from dual 
where not exists(select 1 from ld_desk where labelbol = 'ADDITIONAL' and languagetype = 'en' and labeltype = 'fixedstr');
delimiter;
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','BEIZHU','备注','fixedstr' from dual 
where not exists(select 1 from ld_desk where labelbol = 'BEIZHU' and languagetype = 'zh' and labeltype = 'fixedstr');
delimiter;
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','BEIZHU','Description','fixedstr' from dual 
where not exists(select 1 from ld_desk where labelbol = 'BEIZHU' and languagetype = 'en' and labeltype = 'fixedstr');
delimiter;

update ld_quickactions set related_tabid=9 where tabid in (SELECT tabid from ld_tab where `name`='Potentials') AND related_tabid=16;
delimiter;
-- 2016-07-20

update ld_quickactions set related_tabid=9 where tabid=2 AND related_tabid=16;
delimiter;

select sequence into @sequence from ld_systems_deploy where deploy_type=81;
update ld_systems_deploy set sequence = sequence+1 where sequence > @sequence;
insert into ld_systems_deploy(deploy_value,deploy_type,description,setype,sequence,roottype,inputtype,inputvalue,presence)
select 1,104,'分配弹出层是否显示所有用户','',@sequence+1,1,'select','[{"value":"0","text":"YES"},{"value":"1","text":"NO"},{"sql":""}]',0
from dual where not EXISTS(select 1 from ld_systems_deploy where deploy_type=104);
set @i=0; 

update ld_systems_deploy set sequence=(@i:=@i+1) where roottype=1 order by sequence; 
delimiter;

insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'zh','ld_systems_deploy',104,104,'分配弹出层是否显示所有用户'
from dual where not exists (select * from ld_tranlabel where languagetype='zh' and trantable='ld_systems_deploy' and relateid=104);
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'en','ld_systems_deploy',104,104,'Allocate pop up layer to display all users'
from dual where not exists (select * from ld_tranlabel where languagetype='en' and trantable='ld_systems_deploy' and relateid=104);
delimiter;

select tabid into @tabid from ld_tab where `name` = 'SendCashBill';
delete from ld_field where tabid = @tabid and fieldname = 'purchaseorder_id' and presence=1;
delimiter;

update ld_field set uitype = 86 where columnname='distributetime' and tablename in('ld_troubletickets','ld_projecttask');
-- 2016-07-21

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) 
select 'zh','ZHLABELALREADYEXISTS','中文标签已存在，请输入其他标签！','jspop' from dual 
where not EXISTS(select 1 from ld_desk where languagetype='zh' and labelbol='ZHLABELALREADYEXISTS' and Labeltype='jspop'); 

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) 
select 'en','ZHLABELALREADYEXISTS','Chinese label already exists, please enter another tag!','jspop' from dual 
where not EXISTS(select 1 from ld_desk where languagetype='en' and labelbol='ZHLABELALREADYEXISTS' and Labeltype='jspop'); 
delimiter; 

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) 
select 'zh','ENLABELALREADYEXISTS','英文标签已存在，请输入其他标签！','jspop' from dual 
where not EXISTS(select 1 from ld_desk where languagetype='zh' and labelbol='ENLABELALREADYEXISTS' and Labeltype='jspop'); 

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) 
select 'en','ENLABELALREADYEXISTS','English label already exists, please enter another tag!','jspop' from dual 
where not EXISTS(select 1 from ld_desk where languagetype='en' and labelbol='ENLABELALREADYEXISTS' and Labeltype='jspop'); 
delimiter; 

insert into ld_systems_deploy(deploy_value,deploy_type,description,sequence,roottype,inputtype,presence)
select '123',105,'Api接口授权码(只能输入字母和数字)',105,4,'text',0 from dual 
where not exists(select 1 from ld_systems_deploy where deploy_type=105);

insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'zh','ld_systems_deploy',105,105,'Api接口授权码(只能输入字母和数字)' from dual 
where not exists(select 1 from ld_tranlabel where trantable='ld_systems_deploy' and languagetype='zh' and Relateid=105);
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'en','ld_systems_deploy',105,105,'Api authorization code(only letters and numbers)' from dual 
where not exists(select 1 from ld_tranlabel where trantable='ld_systems_deploy' and languagetype='en' and Relateid=105);
delimiter;

insert into ld_systems_deploy(deploy_value,deploy_type,description,sequence,roottype,inputtype,presence)
select 'abc123',106,'Api接口key(只能输入字母和数字)',106,4,'text',0 from dual 
where not exists(select 1 from ld_systems_deploy where deploy_type=106);

insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'zh','ld_systems_deploy',106,106,'Api接口key(只能输入字母和数字)' from dual 
where not exists(select 1 from ld_tranlabel where trantable='ld_systems_deploy' and languagetype='zh' and Relateid=106);
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'en','ld_systems_deploy',106,106,'Api key(only letters and numbers)' from dual 
where not exists(select 1 from ld_tranlabel where trantable='ld_systems_deploy' and languagetype='en' and Relateid=106);
delimiter;
-- 2016-07-22

call AddColumn('ld_troubletickets','bw8_id','int','11',0); 
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
delimiter;

update ld_version set old_version='V6.4.5' ,current_version='V6.4.5' ,remark='V6.4.5-20160722';
delimiter;