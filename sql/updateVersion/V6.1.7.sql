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

CREATE TABLE IF NOT EXISTS `ld_projectprogress` (
  `projectprogressid` int(11) NOT NULL,  
  `projectprogress_no` varchar(100) DEFAULT NULL,  
  `startdate` date DEFAULT NULL,
  `enddate` date DEFAULT NULL,
  `projectid` varchar(100) DEFAULT NULL,
  `projecttaskid` varchar(100) DEFAULT NULL,   
  `smownerid` int(11) DEFAULT '0',
  `smcreatorid` int(11) DEFAULT '0',
  `modifiedby` int(11) DEFAULT '0',
  `approveby` int(11) DEFAULT NULL,
  `approvestatus` VARCHAR(200) DEFAULT NULL,
  `createdtime` datetime DEFAULT NULL,
  `modifiedtime` datetime DEFAULT NULL,
  `deleted` int(11) DEFAULT '0',
  `description` text,
  `totalcost` decimal(25,2) DEFAULT '0.00',
  `timecost` decimal(25,1) DEFAULT '0.0',
  PRIMARY KEY (`projectprogressid`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
delimiter;

CREATE TABLE IF NOT EXISTS `ld_projectprogresscf` (
  `projectprogressid` int(11) NOT NULL DEFAULT '0',
  PRIMARY KEY (`projectprogressid`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
delimiter;

select max(tabid) into @tabid from ld_tab;
select max(tabsequence) into @tabsequence from ld_tab;
insert into ld_tab(tabid,name,presence,tabsequence,tablabel,isentitytype,parent,printtab)
select @tabid + 1,'ProjectProgress',0,@tabsequence+1,'ProjectProgress',1,'Project',0 
from dual where not EXISTS(select 1 from ld_tab where `name`='ProjectProgress');
delimiter;

select parenttabid into @parenttabid from ld_parenttab where parenttab_label = 'Project';
select max(sequence) into @sequence from ld_parenttabrel where parenttabid = @parenttabid;
select tabid into @tabid from ld_tab where `name` = 'ProjectProgress';
insert into ld_parenttabrel(parenttabid,tabid,sequence)
select @parenttabid,@tabid,@sequence+1 
from dual where not EXISTS(select 1 from ld_parenttabrel  where parenttabid = @parenttabid and tabid =@tabid);
delimiter;

select tabid into @tabid from ld_tab where `name` = 'ProjectProgress';
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'zh','ld_tab',@tabid,@tabid,'项目进度' 
from dual where not EXISTS(select 1 from ld_tranlabel  where languagetype = 'zh' 
and trantable ='ld_tab' and tabid = @tabid and Relateid=@tabid);
delimiter;

insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'en','ld_tab',@tabid,@tabid,'ProjectProgress' 
from dual where not EXISTS(select 1 from ld_tranlabel  where languagetype = 'en' 
and trantable ='ld_tab' and tabid = @tabid and Relateid=@tabid);
delimiter;

call fieldprofile('ProjectProgress');
delimiter;
call getallprofile('ProjectProgress');
delimiter;
call addtabintoprofile('ProjectProgress',0);
delimiter;

select tabid into @tabid from ld_tab where `name` = 'ProjectProgress';
update ld_profile2standardpermissions set permissions = 1 where tabid = @tabid and profileid not in (
select ld_role2profile.profileid from ld_users 
inner join ld_user2role on ld_users.id = ld_user2role.userid
inner join ld_role2profile on ld_role2profile.roleid = ld_user2role.roleid  where is_admin = 'on');
delimiter;

select tabid into @tabid from ld_tab where `name` = 'ProjectProgress';
insert into ld_org_share_action2tab(share_action_id,tabid) select 0,@tabid from dual 
where not exists(select 1 from ld_org_share_action2tab where share_action_id=0 and tabid=@tabid);
delimiter;

insert into ld_org_share_action2tab(share_action_id,tabid) select 1,@tabid from dual 
where not exists(select 1 from ld_org_share_action2tab where share_action_id=1 and tabid=@tabid);
delimiter;

insert into ld_org_share_action2tab(share_action_id,tabid) select 2,@tabid from dual 
where not exists(select 1 from ld_org_share_action2tab where share_action_id=2 and tabid=@tabid);
delimiter;

insert into ld_org_share_action2tab(share_action_id,tabid) select 3,@tabid from dual 
where not exists(select 1 from ld_org_share_action2tab where share_action_id=3 and tabid=@tabid);
delimiter;

select max(ruleid) into @ruleid from ld_def_org_share;
update ld_def_org_share_seq set id=@ruleid+1 where  not exists(select 1 from ld_def_org_share where tabid=@tabid);
insert into ld_def_org_share(ruleid,tabid,permission,editstatus)
select @ruleid+1,@tabid,3,0  from dual where  not exists(select 1 from ld_def_org_share where tabid=@tabid);
delimiter;

select tabid into @tabid from ld_tab where `name` = 'ProjectProgress';
insert into ld_blocks(blockid,tabid,blocklabel,sequence)
select (select max(blockid) from ld_blocks)+1,@tabid,'LBL_PROJECTPROGRESS_INFO',1 from dual where not exists (select * from ld_blocks where 
tabid = @tabid and blocklabel = 'LBL_PROJECTPROGRESS_INFO' and sequence = 1);
delimiter;

insert into ld_blocks(blockid,tabid,blocklabel,sequence)
select (select max(blockid) from ld_blocks)+1,@tabid,'LBL_REMARKS',2 from dual where not exists (select * from ld_blocks where 
tabid = @tabid and blocklabel = 'LBL_REMARKS' and sequence = 2);
delimiter;

update ld_blocks_seq set id = (select max(blockid)+1 from ld_blocks);
delimiter;

insert into ld_field(tabid,fieldid,columnname,tablename,uitype,fieldname,fieldlabel,block,displaytype,presence,typeofdata,generatedtype,sequence,issmownerid)
select @tabid,(select max(fieldid) from ld_field)+1,'smownerid','ld_projectprogress',53,'assigned_user_id','负责人',(select blockid from ld_blocks where blocklabel = 'LBL_PROJECTPROGRESS_INFO'),1,0,'V~M',1,1,1 from dual where not exists 
(select * from ld_field where tabid = @tabid and columnname = 'smownerid');
delimiter;

insert into ld_field(tabid,fieldid,columnname,tablename,uitype,fieldname,fieldlabel,block,displaytype,presence,typeofdata,generatedtype,sequence)
select @tabid,(select max(fieldid) from ld_field)+1,'projectprogress_no','ld_projectprogress',4,'projectprogress_no','项目进度编号',(select blockid from ld_blocks where blocklabel = 'LBL_PROJECTPROGRESS_INFO'),1,0,'V~M',2,2 from dual where not exists 
(select * from ld_field where tabid = @tabid and columnname = 'projectprogress_no');
delimiter;

insert into ld_field(tabid,fieldid,columnname,tablename,uitype,fieldname,fieldlabel,block,displaytype,presence,typeofdata,generatedtype,sequence,defaultvalue)
select @tabid,(select max(fieldid) from ld_field)+1,'startdate','ld_projectprogress',5,'startdate','起始日期',(select blockid from ld_blocks where blocklabel = 'LBL_PROJECTPROGRESS_INFO'),1,0,'D~M',1,3,'thistoday' from dual where not exists 
(select * from ld_field where tabid = @tabid and columnname = 'startdate');
delimiter;

insert into ld_field(tabid,fieldid,columnname,tablename,uitype,fieldname,fieldlabel,block,displaytype,presence,typeofdata,generatedtype,sequence,defaultvalue)
select @tabid,(select max(fieldid) from ld_field)+1,'enddate','ld_projectprogress',5,'enddate','截止日期',(select blockid from ld_blocks where blocklabel = 'LBL_PROJECTPROGRESS_INFO'),1,0,'D~M',1,4,'thistoday' from dual where not exists 
(select * from ld_field where tabid = @tabid and columnname = 'enddate');
delimiter;

insert into ld_field(tabid,fieldid,columnname,tablename,uitype,fieldname,fieldlabel,block,displaytype,presence,typeofdata,generatedtype,quickcreate,sequence)
select @tabid,(select max(fieldid) from ld_field)+1,'projectid','ld_projectprogress',10,'projectid','项目名称',(select blockid from ld_blocks where blocklabel = 'LBL_PROJECTPROGRESS_INFO'),1,0,'V~M',1,0,5 from dual where not exists 
(select * from ld_field where tabid = @tabid and columnname = 'projectid');
delimiter;

insert into ld_field(tabid,fieldid,columnname,tablename,uitype,fieldname,fieldlabel,block,displaytype,presence,typeofdata,generatedtype,quickcreate,sequence)
select @tabid,(select max(fieldid) from ld_field)+1,'projecttaskid','ld_projectprogress',10,'projecttaskid','项目计划',(select blockid from ld_blocks where blocklabel = 'LBL_PROJECTPROGRESS_INFO'),1,0,'V~M',1,0,6 from dual where not exists 
(select * from ld_field where tabid = @tabid and columnname = 'projecttaskid');
delimiter;

insert into ld_field(tabid,fieldid,columnname,tablename,uitype,fieldname,fieldlabel,block,displaytype,presence,typeofdata,generatedtype,sequence)
select @tabid,(select max(fieldid) from ld_field)+1,'smcreatorid','ld_projectprogress',52,'smcreatorid','创建人',(select blockid from ld_blocks where blocklabel = 'LBL_PROJECTPROGRESS_INFO'),2,0,'V~O',1,7 from dual where not exists 
(select * from ld_field where tabid = @tabid and columnname = 'smcreatorid');
delimiter;

insert into ld_field(tabid,fieldid,columnname,tablename,uitype,fieldname,fieldlabel,block,displaytype,presence,typeofdata,generatedtype,sequence)
select @tabid,(select max(fieldid) from ld_field)+1,'modifiedby','ld_projectprogress',52,'modifiedby','最新修改人',(select blockid from ld_blocks where blocklabel = 'LBL_PROJECTPROGRESS_INFO'),2,0,'V~O',1,8 from dual where not exists 
(select * from ld_field where tabid = @tabid and columnname = 'modifiedby');
delimiter;

insert into ld_field(tabid,fieldid,columnname,tablename,uitype,fieldname,fieldlabel,block,displaytype,presence,typeofdata,generatedtype,sequence)
select @tabid,(select max(fieldid) from ld_field)+1,'createdtime','ld_projectprogress',70,'createdtime','创建日期',(select blockid from ld_blocks where blocklabel = 'LBL_PROJECTPROGRESS_INFO'),2,0,'DT~O',1,9 from dual where not exists 
(select * from ld_field where tabid = @tabid and columnname = 'createdtime');
delimiter;

insert into ld_field(tabid,fieldid,columnname,tablename,uitype,fieldname,fieldlabel,block,displaytype,presence,typeofdata,generatedtype,sequence)
select @tabid,(select max(fieldid) from ld_field)+1,'modifiedtime','ld_projectprogress',70,'modifiedtime','修改日期',(select blockid from ld_blocks where blocklabel = 'LBL_PROJECTPROGRESS_INFO'),2,0,'DT~O',1,10 from dual where not exists 
(select * from ld_field where tabid = @tabid and columnname = 'modifiedtime');
delimiter;

insert into ld_field(tabid,fieldid,columnname,tablename,uitype,fieldname,fieldlabel,block,displaytype,presence,typeofdata,generatedtype,sequence)
select @tabid,(select max(fieldid) from ld_field)+1,'timecost','ld_projectprogress',7,'timecost','消耗工时',(select blockid from ld_blocks where blocklabel = 'LBL_PROJECTPROGRESS_INFO'),1,0,'V~M',1,13 from dual where not exists 
(select * from ld_field where tabid = @tabid and columnname = 'timecost');
delimiter;

insert into ld_field(tabid,fieldid,columnname,tablename,uitype,fieldname,fieldlabel,block,displaytype,presence,typeofdata,generatedtype,sequence)
select @tabid,(select max(fieldid) from ld_field)+1,'totalcost','ld_projectprogress',7,'totalcost','消耗费用',(select blockid from ld_blocks where blocklabel = 'LBL_PROJECTPROGRESS_INFO'),1,0,'V~M',1,14 from dual where not exists 
(select * from ld_field where tabid = @tabid and columnname = 'totalcost');
delimiter;

insert into ld_field(tabid,fieldid,columnname,tablename,uitype,fieldname,fieldlabel,block,displaytype,presence,typeofdata,generatedtype,sequence)
select @tabid,(select max(fieldid) from ld_field)+1,'description','ld_projectprogress',19,'description','备注',(select blockid from ld_blocks where blocklabel = 'LBL_REMARKS'),1,0,'V~O',1,1 from dual where not exists 
(select * from ld_field where tabid = @tabid and columnname = 'description');
delimiter;

select tabid into @tabid from ld_tab where `name` = 'ProjectProgress';
select blockid into @blockid from ld_blocks where tabid = @tabid and blocklabel = 'LBL_PROJECTPROGRESS_INFO';
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'zh','ld_blocks',@tabid,@blockid ,'基本信息' 
from dual where not EXISTS(select 1 from ld_tranlabel  where languagetype = 'zh' 
and trantable ='ld_blocks' and tabid = @tabid and relateid=@blockid);
delimiter;

insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'en','ld_blocks',@tabid,@blockid,'Basic Information' 
from dual where not EXISTS(select 1 from ld_tranlabel  where languagetype = 'en' 
and trantable ='ld_blocks' and tabid = @tabid and relateid=@blockid);
delimiter;

select blockid into @blockid from ld_blocks where tabid = @tabid and blocklabel = 'LBL_REMARKS';
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'zh','ld_blocks',@tabid,@blockid ,'备注信息' 
from dual where not EXISTS(select 1 from ld_tranlabel  where languagetype = 'zh' 
and trantable ='ld_blocks' and tabid = @tabid and relateid=@blockid);
delimiter;

insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'en','ld_blocks',@tabid,@blockid,'Description Information' 
from dual where not EXISTS(select 1 from ld_tranlabel  where languagetype = 'en' 
and trantable ='ld_blocks' and tabid = @tabid and relateid=@blockid);
delimiter;

select fieldid into @fieldid from ld_field where tabid = @tabid and fieldname = 'assigned_user_id';
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'zh','ld_field',@tabid,@fieldid,'负责人' 
from dual where not EXISTS(select 1 from ld_tranlabel  where languagetype = 'zh' 
and trantable ='ld_field' and tabid = @tabid and relateid=@fieldid);
delimiter;

insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'en','ld_field',@tabid,@fieldid,'assigned user' 
from dual where not EXISTS(select 1 from ld_tranlabel  where languagetype = 'en' 
and trantable ='ld_field' and tabid = @tabid and relateid=@fieldid);
delimiter;

select fieldid into @fieldid from ld_field where tabid = @tabid and fieldname = 'projectprogress_no';
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'zh','ld_field',@tabid,@fieldid,'项目进度编号' 
from dual where not EXISTS(select 1 from ld_tranlabel  where languagetype = 'zh' 
and trantable ='ld_field' and tabid = @tabid and relateid=@fieldid);
delimiter;

insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'en','ld_field',@tabid,@fieldid,'Projectprogress No' 
from dual where not EXISTS(select 1 from ld_tranlabel  where languagetype = 'en' 
and trantable ='ld_field' and tabid = @tabid and relateid=@fieldid);
delimiter;

select fieldid into @fieldid from ld_field where tabid = @tabid and fieldname = 'smcreatorid';
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'zh','ld_field',@tabid,@fieldid,'创建人' 
from dual where not EXISTS(select 1 from ld_tranlabel  where languagetype = 'zh' 
and trantable ='ld_field' and tabid = @tabid and relateid=@fieldid);
delimiter;

insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'en','ld_field',@tabid,@fieldid,'creator' 
from dual where not EXISTS(select 1 from ld_tranlabel  where languagetype = 'en' 
and trantable ='ld_field' and tabid = @tabid and relateid=@fieldid);
delimiter;

select fieldid into @fieldid from ld_field where tabid = @tabid and fieldname = 'modifiedby';
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'zh','ld_field',@tabid,@fieldid,'最新修改人' 
from dual where not EXISTS(select 1 from ld_tranlabel  where languagetype = 'zh' 
and trantable ='ld_field' and tabid = @tabid and relateid=@fieldid);
delimiter;

insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'en','ld_field',@tabid,@fieldid,'Modified By' 
from dual where not EXISTS(select 1 from ld_tranlabel  where languagetype = 'en' 
and trantable ='ld_field' and tabid = @tabid and relateid=@fieldid);
delimiter;

select fieldid into @fieldid from ld_field where tabid = @tabid and fieldname = 'createdtime';
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'zh','ld_field',@tabid,@fieldid,'创建日期' 
from dual where not EXISTS(select 1 from ld_tranlabel  where languagetype = 'zh' 
and trantable ='ld_field' and tabid = @tabid and relateid=@fieldid);
delimiter;

insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'en','ld_field',@tabid,@fieldid,'Created Time' 
from dual where not EXISTS(select 1 from ld_tranlabel  where languagetype = 'en' 
and trantable ='ld_field' and tabid = @tabid and relateid=@fieldid);
delimiter;

select fieldid into @fieldid from ld_field where tabid = @tabid and fieldname = 'modifiedtime';
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'zh','ld_field',@tabid,@fieldid,'修改日期' 
from dual where not EXISTS(select 1 from ld_tranlabel  where languagetype = 'zh' 
and trantable ='ld_field' and tabid = @tabid and relateid=@fieldid);
delimiter;

insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'en','ld_field',@tabid,@fieldid,'Modified Time' 
from dual where not EXISTS(select 1 from ld_tranlabel  where languagetype = 'en' 
and trantable ='ld_field' and tabid = @tabid and relateid=@fieldid);
delimiter;

select fieldid into @fieldid from ld_field where tabid = @tabid and fieldname = 'startdate';
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'zh','ld_field',@tabid,@fieldid,'起始日期' 
from dual where not EXISTS(select 1 from ld_tranlabel  where languagetype = 'zh' 
and trantable ='ld_field' and tabid = @tabid and relateid=@fieldid);
delimiter;

insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'en','ld_field',@tabid,@fieldid,'Start Date' 
from dual where not EXISTS(select 1 from ld_tranlabel  where languagetype = 'en' 
and trantable ='ld_field' and tabid = @tabid and relateid=@fieldid);
delimiter;

select fieldid into @fieldid from ld_field where tabid = @tabid and fieldname = 'enddate';
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'zh','ld_field',@tabid,@fieldid,'截止日期' 
from dual where not EXISTS(select 1 from ld_tranlabel  where languagetype = 'zh' 
and trantable ='ld_field' and tabid = @tabid and relateid=@fieldid);
delimiter;

insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'en','ld_field',@tabid,@fieldid,'End Date' 
from dual where not EXISTS(select 1 from ld_tranlabel  where languagetype = 'en' 
and trantable ='ld_field' and tabid = @tabid and relateid=@fieldid);
delimiter;

select fieldid into @fieldid from ld_field where tabid = @tabid and fieldname = 'projectid';
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'zh','ld_field',@tabid,@fieldid,'项目名称' 
from dual where not EXISTS(select 1 from ld_tranlabel  where languagetype = 'zh' 
and trantable ='ld_field' and tabid = @tabid and relateid=@fieldid);
delimiter;

insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'en','ld_field',@tabid,@fieldid,'Project Name' 
from dual where not EXISTS(select 1 from ld_tranlabel  where languagetype = 'en' 
and trantable ='ld_field' and tabid = @tabid and relateid=@fieldid);
delimiter;

select fieldid into @fieldid from ld_field where tabid = @tabid and fieldname = 'projecttaskid';
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'zh','ld_field',@tabid,@fieldid,'项目计划' 
from dual where not EXISTS(select 1 from ld_tranlabel  where languagetype = 'zh' 
and trantable ='ld_field' and tabid = @tabid and relateid=@fieldid);
delimiter;

insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'en','ld_field',@tabid,@fieldid,'Project Plan' 
from dual where not EXISTS(select 1 from ld_tranlabel  where languagetype = 'en' 
and trantable ='ld_field' and tabid = @tabid and relateid=@fieldid);
delimiter;

select fieldid into @fieldid from ld_field where tabid = @tabid and fieldname = 'timecost';
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'zh','ld_field',@tabid,@fieldid,'消耗工时' 
from dual where not EXISTS(select 1 from ld_tranlabel  where languagetype = 'zh' 
and trantable ='ld_field' and tabid = @tabid and relateid=@fieldid);
delimiter;

insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'en','ld_field',@tabid,@fieldid,'Time Cost' 
from dual where not EXISTS(select 1 from ld_tranlabel  where languagetype = 'en' 
and trantable ='ld_field' and tabid = @tabid and relateid=@fieldid);
delimiter;

select fieldid into @fieldid from ld_field where tabid = @tabid and fieldname = 'totalcost';
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'zh','ld_field',@tabid,@fieldid,'消耗费用' 
from dual where not EXISTS(select 1 from ld_tranlabel  where languagetype = 'zh' 
and trantable ='ld_field' and tabid = @tabid and relateid=@fieldid);
delimiter;

insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'en','ld_field',@tabid,@fieldid,'Total Cost' 
from dual where not EXISTS(select 1 from ld_tranlabel  where languagetype = 'en' 
and trantable ='ld_field' and tabid = @tabid and relateid=@fieldid);
delimiter;

select fieldid into @fieldid from ld_field where tabid = @tabid and fieldname = 'description';
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'zh','ld_field',@tabid,@fieldid,'备注' 
from dual where not EXISTS(select 1 from ld_tranlabel  where languagetype = 'zh' 
and trantable ='ld_field' and tabid = @tabid and relateid=@fieldid);
delimiter;

insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'en','ld_field',@tabid,@fieldid,'Description' 
from dual where not EXISTS(select 1 from ld_tranlabel  where languagetype = 'en' 
and trantable ='ld_field' and tabid = @tabid and relateid=@fieldid);
delimiter;

insert into ld_modentity_num(num_id,semodule,prefix,start_id,cur_id,active,datetype)
select (select max(num_id)+1 from ld_modentity_num),'ProjectProgress','Pro',0,2,1,'none' 
from dual where not EXISTS(select 1 from ld_modentity_num  where semodule = 'ProjectProgress' 
and prefix ='Pro');
delimiter;

update ld_modentity_num_seq set id = (select max(num_id)+1 from ld_modentity_num);
delimiter;

insert into ld_customview(cvid,viewname,setdefault,setmetrics,entitytype,status,userid,sequence,pagewidthpercent,customcategory)
select (select max(cvid)+1 from ld_customview),'All',1,0,'ProjectProgress',3,1,0,100,NULL 
from dual where not EXISTS(select 1 from ld_customview  where entitytype = 'ProjectProgress' and viewname ='All');
delimiter;

select cvid into @cvid from ld_customview where entitytype = 'ProjectProgress' and viewname = 'All';
insert into ld_cvcolumnlist(cvid,columnindex,columnname)
select @cvid,0,'ld_projectprogress:projectprogress_no:projectprogress_no:ProjectProgress_fieldlabel:V' 
from dual where not EXISTS(select 1 from ld_cvcolumnlist  where cvid = @cvid 
and columnindex =0 and columnname = 'ld_projectprogress:projectprogress_no:projectprogress_no:ProjectProgress_fieldlabel:V');
delimiter;

insert into ld_cvcolumnlist(cvid,columnindex,columnname)
select @cvid,1,'ld_projectprogress:projectid:projectid:ProjectProgress_fieldlabel:V' 
from dual where not EXISTS(select 1 from ld_cvcolumnlist  where cvid = @cvid 
and columnindex =1 and columnname = 'ld_projectprogress:projectid:projectid:ProjectProgress_fieldlabel:V');
delimiter;

insert into ld_cvcolumnlist(cvid,columnindex,columnname)
select @cvid,2,'ld_projectprogress:projecttaskid:projecttaskid:ProjectProgress_fieldlabel:V' 
from dual where not EXISTS(select 1 from ld_cvcolumnlist  where cvid = @cvid 
and columnindex =2 and columnname = 'ld_projectprogress:projecttaskid:projecttaskid:ProjectProgress_fieldlabel:V');
delimiter;

insert into ld_cvcolumnlist(cvid,columnindex,columnname)
select @cvid,5,'ld_projectprogress:timecost:timecost:ProjectProgress_fieldlabel:V' 
from dual where not EXISTS(select 1 from ld_cvcolumnlist  where cvid = @cvid 
and columnindex =5 and columnname = 'ld_projectprogress:timecost:timecost:ProjectProgress_fieldlabel:V');
delimiter;

insert into ld_cvcolumnlist(cvid,columnindex,columnname)
select @cvid,6,'ld_projectprogress:totalcost:totalcost:ProjectProgress_fieldlabel:V' 
from dual where not EXISTS(select 1 from ld_cvcolumnlist  where cvid = @cvid 
and columnindex =6 and columnname = 'ld_projectprogress:totalcost:totalcost:ProjectProgress_fieldlabel:V');
delimiter;

insert into ld_cvcolumnlist(cvid,columnindex,columnname)
select @cvid,7,'ld_projectprogress:smownerid:assigned_user_id:ProjectProgress_fieldlabel:V' 
from dual where not EXISTS(select 1 from ld_cvcolumnlist  where cvid = @cvid 
and columnindex =7 and columnname = 'ld_projectprogress:smownerid:assigned_user_id:ProjectProgress_fieldlabel:V');
delimiter;

select tabid into @tabid from ld_tab where `name` = 'ProjectProgress';
insert into ld_entityname(tabid,modulename,tablename,fieldname,entityidfield,entityidcolumn)
select @tabid,'ProjectProgress','ld_projectprogress','projectprogress_no','projectprogressid','projectprogressid'
from dual where not EXISTS(select 1 from ld_entityname  where tabid = @tabid 
and modulename ='ProjectProgress');

select tabid into @tabid from ld_tab where `name` = 'ProjectProgress';
select id into @id from ld_links_seq;
insert into ld_links(linkid,tabid,linktype,linklabel,linkurl,linkicon,handler_path,handler_class,handler,sequence)
select @id+1,@tabid,'DETAILVIEWBASIC','View History',"javascript:ModTrackerCommon.showhistory('$RECORD$')",
'themes/images/pointer.gif','modules/ModTracker/ModTracker.php','ModTracker','isViewPermitted',0
from dual where not EXISTS(select 1 from ld_links  where tabid = @tabid 
and linktype ='DETAILVIEWBASIC');
update ld_links_seq set id = (select max(linkid) from ld_links);
delimiter;

update ld_tab set printtab = 1 where `name` = 'ProjectProgress';
delimiter;

select tabid into @tabid from ld_tab where `name` = 'ProjectProgress';
insert into ld_modtracker_tabs(tabid,visible)
select @tabid,1 from dual where not EXISTS(select 1 from ld_modtracker_tabs  where tabid = @tabid 
and visible =1);

SELECT tabid into @tabid from ld_tab  WHERE tablabel='ProjectProgress';
insert into ld_profileallpermission(tabid,operation)
select @tabid,1 
from dual where not EXISTS(select 1 from ld_profileallpermission  where tabid=@tabid AND operation=1);
insert into ld_profileallpermission(tabid,operation)
select @tabid,2
from dual where not EXISTS(select 1 from ld_profileallpermission  where tabid=@tabid AND operation=2);
insert into ld_profileallpermission(tabid,operation)
select @tabid,3 
from dual where not EXISTS(select 1 from ld_profileallpermission  where tabid=@tabid AND operation=3);
insert into ld_profileallpermission(tabid,operation)
select @tabid,4
from dual where not EXISTS(select 1 from ld_profileallpermission  where tabid=@tabid AND operation=4);
insert into ld_profileallpermission(tabid,operation)
select @tabid,5
from dual where not EXISTS(select 1 from ld_profileallpermission  where tabid=@tabid AND operation=5);
insert into ld_profileallpermission(tabid,operation)
select @tabid,6
from dual where not EXISTS(select 1 from ld_profileallpermission  where tabid=@tabid AND operation=6);
insert into ld_profileallpermission(tabid,operation)
select @tabid,11
from dual where not EXISTS(select 1 from ld_profileallpermission  where tabid=@tabid AND operation=11);
insert into ld_profileallpermission(tabid,operation)
select @tabid,12 
from dual where not EXISTS(select 1 from ld_profileallpermission  where tabid=@tabid AND operation=12);
insert into ld_profileallpermission(tabid,operation)
select @tabid,13
from dual where not EXISTS(select 1 from ld_profileallpermission  where tabid=@tabid AND operation=13);
insert into ld_profileallpermission(tabid,operation)
select @tabid,14
from dual where not EXISTS(select 1 from ld_profileallpermission  where tabid=@tabid AND operation=14);
insert into ld_profileallpermission(tabid,operation)
select @tabid,25 
from dual where not EXISTS(select 1 from ld_profileallpermission  where tabid=@tabid AND operation=25);

SELECT tabid  INTO @tabid FROM ld_tab  WHERE NAME='ProjectProgress';
SELECT fieldid INTO @fieldid FROM ld_field WHERE tabid=@tabid AND fieldname='projectid'; 
INSERT INTO  ld_fieldmodulerel(fieldid,module,relmodule,STATUS,sequence)
SELECT @fieldid,'ProjectProgress','Project',0,0 
from dual where not EXISTS
(select 1 from ld_fieldmodulerel  where fieldid=@fieldid AND module='ProjectProgress'AND relmodule='Project');
delimiter;

SELECT tabid  INTO @tabid FROM ld_tab  WHERE NAME='ProjectProgress';
SELECT fieldid INTO @fieldid FROM ld_field WHERE tabid=@tabid AND fieldname='projecttaskid'; 
INSERT INTO  ld_fieldmodulerel(fieldid,module,relmodule,STATUS,sequence)
SELECT @fieldid,'ProjectProgress','ProjectTask',0,0 
from dual where not EXISTS
(select 1 from ld_fieldmodulerel  where fieldid=@fieldid AND module='ProjectProgress'AND relmodule='ProjectTask');
delimiter;


SELECT tabid INTO @tabid FROM ld_tab WHERE `name`='ProjectProgress';
SELECT max(relation_id) INTO @relation_id FROM ld_relatedlists;
INSERT INTO  ld_relatedlists(relation_id,tabid,related_tabid,NAME,sequence,label,presence,actions,mobile_presence,mobile_sequence) 
SELECT @relation_id+1,@tabid,8,'get_attachments',0,'Documents',0,'ADD,SELECT',1,0
FROM DUAL WHERE NOT EXISTS(SELECT 1 FROM ld_relatedlists WHERE tabid=@tabid AND NAME='get_attachments');
delimiter;

SELECT max(relation_id) INTO @relation_id FROM ld_relatedlists;
INSERT INTO  ld_relatedlists(relation_id,tabid,related_tabid,NAME,sequence,label,presence,actions,mobile_presence,mobile_sequence) 
SELECT @relation_id+1,@tabid,78,'get_attachment',1,'Attachment',0,'add',1,1
FROM DUAL WHERE NOT EXISTS(SELECT 1 FROM ld_relatedlists WHERE tabid=@tabid AND NAME='get_attachment');
delimiter;

SELECT max(relation_id) INTO @relation_id FROM ld_relatedlists;
SELECT tabid INTO @tabid2 FROM ld_tab WHERE `name`='Project';
INSERT INTO  ld_relatedlists(relation_id,tabid,related_tabid,NAME,sequence,label,presence,actions,mobile_presence,mobile_sequence) 
SELECT @relation_id+1,@tabid,@tabid2,'get_project',2,'Project',0,'add,select',1,2
FROM DUAL WHERE NOT EXISTS(SELECT 1 FROM ld_relatedlists WHERE tabid=@tabid AND NAME='get_project');
delimiter;

SELECT max(relation_id) INTO @relation_id FROM ld_relatedlists;
SELECT tabid INTO @tabid3 FROM ld_tab WHERE `name`='ProjectTask';
INSERT INTO  ld_relatedlists(relation_id,tabid,related_tabid,NAME,sequence,label,presence,actions,mobile_presence,mobile_sequence) 
SELECT @relation_id+1,@tabid,@tabid3,'get_projecttask',3,'ProjectTask',0,'add,select',1,3
FROM DUAL WHERE NOT EXISTS(SELECT 1 FROM ld_relatedlists WHERE tabid=@tabid AND NAME='get_projecttask');
delimiter;


SELECT tabid INTO @tabid FROM ld_tab WHERE `name`='ProjectProgress';
SELECT max(relation_id) INTO @relation_id FROM ld_quickactions;
INSERT INTO  ld_quickactions(relation_id,tabid,related_tabid,sequence,presence,label) 
SELECT @relation_id+1,@tabid,-1,2,0,'修改日志'
FROM DUAL WHERE NOT EXISTS(SELECT 1 FROM ld_quickactions WHERE tabid=@tabid AND related_tabid=-1);
delimiter;

SELECT max(relation_id) INTO @relation_id FROM ld_quickactions;
INSERT INTO  ld_quickactions(relation_id,tabid,related_tabid,sequence,presence,label) 
SELECT @relation_id+1,@tabid,78,1,0,''
FROM DUAL WHERE NOT EXISTS(SELECT 1 FROM ld_quickactions WHERE tabid=@tabid AND related_tabid=78);
delimiter;
SELECT max(relation_id) INTO @relation_id FROM ld_quickactions;
INSERT INTO  ld_quickactions(relation_id,tabid,related_tabid,sequence,presence,label) 
SELECT @relation_id+1,@tabid,-5,5,0,'打印工具'
FROM DUAL WHERE NOT EXISTS(SELECT 1 FROM ld_quickactions WHERE tabid=@tabid AND related_tabid=-5);
delimiter;
SELECT max(relation_id) INTO @relation_id FROM ld_quickactions;
INSERT INTO  ld_quickactions(relation_id,tabid,related_tabid,sequence,presence,label) 
SELECT @relation_id+1,@tabid,61,3,0,''
FROM DUAL WHERE NOT EXISTS(SELECT 1 FROM ld_quickactions WHERE tabid=@tabid AND related_tabid=61);
delimiter;
SELECT max(relation_id) INTO @relation_id FROM ld_quickactions;
INSERT INTO  ld_quickactions(relation_id,tabid,related_tabid,sequence,presence,label) 
SELECT @relation_id+1,@tabid,-10,4,0,'负责人变更记录'
FROM DUAL WHERE NOT EXISTS(SELECT 1 FROM ld_quickactions WHERE tabid=@tabid AND related_tabid=-10);
delimiter;
SELECT tabid INTO @tabid FROM ld_tab WHERE `name`='ProjectProgress';
SELECT tabid INTO @tabid2 FROM ld_tab WHERE `name`='Project';
SELECT max(relation_id) INTO @relation_id FROM ld_quickactions;
INSERT INTO  ld_quickactions(relation_id,tabid,related_tabid,sequence,presence,label) 
SELECT @relation_id+1,@tabid,@tabid2,5,0,'项目'
FROM DUAL WHERE NOT EXISTS(SELECT 1 FROM ld_quickactions WHERE tabid=@tabid AND related_tabid=@tabid2);
delimiter;
SELECT tabid INTO @tabid3 FROM ld_tab WHERE `name`='ProjectTask';
SELECT max(relation_id) INTO @relation_id FROM ld_quickactions;
INSERT INTO  ld_quickactions(relation_id,tabid,related_tabid,sequence,presence,label) 
SELECT @relation_id+1,@tabid,@tabid3,6,0,'项目计划'
FROM DUAL WHERE NOT EXISTS(SELECT 1 FROM ld_quickactions WHERE tabid=@tabid AND related_tabid=@tabid3);
delimiter;

SELECT tabid INTO @tabid FROM ld_tab WHERE `name`='ProjectTask';
UPDATE ld_entityname SET fieldname='projecttaskname' 
WHERE tabid=@tabid;

SELECT tabid INTO @tabid  FROM ld_tab WHERE `name`='ProjectTask';
UPDATE ld_tranlabel SET fieldlabel='项目计划' WHERE tabid=@tabid   AND  trantable='ld_tab' AND languagetype='zh';
delimiter;

call AddColumn('ld_project','costbudget','int','11', '');
delimiter;

alter table ld_project modify costbudget decimal(25,2);
delimiter;

call AddColumn('ld_project','timebudget','decimal','25,2', '');
alter table ld_project modify timebudget decimal(25,2);
delimiter;

call AddColumn('ld_project','hascost','decimal','25,2', '');
alter table ld_project modify hascost decimal(25,2);
delimiter;

call AddColumn('ld_project','hastime','decimal','25,2', '');
alter table ld_project modify hastime decimal(25,2);
delimiter;

call AddColumn('ld_project','completetask','varchar','100', NULL);
delimiter;

select tabid into @tabid from ld_tab where `name` = 'Project';
DELETE FROM ld_blocks WHERE tabid=@tabid AND blocklabel='LBL_CUSTOM_INFORMATION';
insert into ld_blocks(blockid,tabid,blocklabel,sequence)
select (select max(blockid) from ld_blocks)+1,@tabid,'LBL_BUDGET_SCHEDULE_INFO',2 from dual where not exists (select * from ld_blocks where 
tabid = @tabid and blocklabel = 'LBL_BUDGET_SCHEDULE_INFO' and sequence = 2);
delimiter;

select tabid into @tabid from ld_tab where `name` = 'Project';
SELECT blockid INTO @blockid FROM ld_blocks WHERE tabid=@tabid AND blocklabel='LBL_BUDGET_SCHEDULE_INFO';
UPDATE ld_field SET block=@blockid WHERE tabid=@tabid AND block=110;
UPDATE ld_field SET block=@blockid  WHERE tabid=@tabid AND block=109 AND columnname='startdate';
UPDATE ld_field SET block=@blockid  WHERE tabid=@tabid AND block=109 AND columnname='projectstatus';
UPDATE ld_field SET block=@blockid  WHERE tabid=@tabid AND block=109 AND columnname='targetenddate';
UPDATE ld_field SET block=@blockid  WHERE tabid=@tabid AND block=109 AND columnname='actualenddate';
delimiter;

insert into ld_field(tabid,fieldid,columnname,tablename,uitype,fieldname,fieldlabel,block,displaytype,presence,typeofdata,generatedtype,sequence)
select @tabid,(select max(fieldid) from ld_field)+1,'costbudget','ld_project',7,'costbudget','费用预算',(select blockid from ld_blocks where blocklabel = 'LBL_BUDGET_SCHEDULE_INFO'),1,0,'V~M',1,6 from dual where not exists 
(select 1 from ld_field where tabid = @tabid and columnname = 'costbudget');
delimiter;

insert into ld_field(tabid,fieldid,columnname,tablename,uitype,fieldname,fieldlabel,block,displaytype,presence,typeofdata,generatedtype,sequence)
select @tabid,(select max(fieldid) from ld_field)+1,'timebudget','ld_project',7,'timebudget','工时预算',(select blockid from ld_blocks where blocklabel = 'LBL_BUDGET_SCHEDULE_INFO'),1,0,'V~M',1,7 from dual where not exists 
(select 1 from ld_field where tabid = @tabid and columnname = 'timebudget');
delimiter;

insert into ld_field(tabid,fieldid,columnname,tablename,uitype,fieldname,fieldlabel,block,displaytype,presence,typeofdata,generatedtype,readonly,sequence)
select @tabid,(select max(fieldid) from ld_field)+1,'hascost','ld_project',7,'hascost','已用费用',(select blockid from ld_blocks where blocklabel = 'LBL_BUDGET_SCHEDULE_INFO'),1,0,'V~O',1,1,13 from dual where not exists 
(select 1 from ld_field where tabid = @tabid and columnname = 'hascost');
delimiter;

insert into ld_field(tabid,fieldid,columnname,tablename,uitype,fieldname,fieldlabel,block,displaytype,presence,typeofdata,generatedtype,readonly,sequence)
select @tabid,(select max(fieldid) from ld_field)+1,'hastime','ld_project',7,'hastime','已用工时',(select blockid from ld_blocks where blocklabel = 'LBL_BUDGET_SCHEDULE_INFO'),1,0,'V~O',1,1,14 from dual where not exists 
(select 1 from ld_field where tabid = @tabid and columnname = 'hastime');
delimiter;

insert into ld_field(tabid,fieldid,columnname,tablename,uitype,fieldname,fieldlabel,block,displaytype,presence,typeofdata,generatedtype,readonly,sequence)
select @tabid,(select max(fieldid) from ld_field)+1,'completetask','ld_project',2,'completetask','已完成任务数',(select blockid from ld_blocks where blocklabel = 'LBL_BUDGET_SCHEDULE_INFO'),1,0,'V~O',1,1,15 from dual where not exists 
(select * from ld_field where tabid = @tabid and columnname = 'completetask');
delimiter;

insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'zh','ld_blocks',@tabid,@blockid ,'预算和进度' 
from dual where not EXISTS(select 1 from ld_tranlabel  where languagetype = 'zh' 
and trantable ='ld_blocks' and tabid = @tabid and relateid=@blockid);
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'en','ld_blocks',@tabid,@blockid,'Budget And Schedule' 
from dual where not EXISTS(select 1 from ld_tranlabel  where languagetype = 'en' 
and trantable ='ld_blocks' and tabid = @tabid and relateid=@blockid);
delimiter;

select fieldid into @fieldid from ld_field where tabid = @tabid and fieldname = 'costbudget';
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'zh','ld_field',@tabid,@fieldid,'费用预算' 
from dual where not EXISTS(select 1 from ld_tranlabel  where languagetype = 'zh' 
and trantable ='ld_field' and tabid = @tabid and relateid=@fieldid);
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'en','ld_field',@tabid,@fieldid,'Cost Budget' 
from dual where not EXISTS(select 1 from ld_tranlabel  where languagetype = 'en' 
and trantable ='ld_field' and tabid = @tabid and relateid=@fieldid);
delimiter;

select fieldid into @fieldid from ld_field where tabid = @tabid and fieldname = 'timebudget';
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'zh','ld_field',@tabid,@fieldid,'工时预算' 
from dual where not EXISTS(select 1 from ld_tranlabel  where languagetype = 'zh' 
and trantable ='ld_field' and tabid = @tabid and relateid=@fieldid);
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'en','ld_field',@tabid,@fieldid,'Time Budget' 
from dual where not EXISTS(select 1 from ld_tranlabel  where languagetype = 'en' 
and trantable ='ld_field' and tabid = @tabid and relateid=@fieldid);
delimiter;

select fieldid into @fieldid from ld_field where tabid = @tabid and fieldname = 'hascost';
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'zh','ld_field',@tabid,@fieldid,'已用费用' 
from dual where not EXISTS(select 1 from ld_tranlabel  where languagetype = 'zh' 
and trantable ='ld_field' and tabid = @tabid and relateid=@fieldid);
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'en','ld_field',@tabid,@fieldid,'Has cost' 
from dual where not EXISTS(select 1 from ld_tranlabel  where languagetype = 'en' 
and trantable ='ld_field' and tabid = @tabid and relateid=@fieldid);
delimiter;

select fieldid into @fieldid from ld_field where tabid = @tabid and fieldname = 'hastime';
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'zh','ld_field',@tabid,@fieldid,'已用工时' 
from dual where not EXISTS(select 1 from ld_tranlabel  where languagetype = 'zh' 
and trantable ='ld_field' and tabid = @tabid and relateid=@fieldid);
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'en','ld_field',@tabid,@fieldid,'Has Time' 
from dual where not EXISTS(select 1 from ld_tranlabel  where languagetype = 'en' 
and trantable ='ld_field' and tabid = @tabid and relateid=@fieldid);
delimiter;

select fieldid into @fieldid from ld_field where tabid = @tabid and fieldname = 'completetask';
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'zh','ld_field',@tabid,@fieldid,'已完成任务数' 
from dual where not EXISTS(select 1 from ld_tranlabel  where languagetype = 'zh' 
and trantable ='ld_field' and tabid = @tabid and relateid=@fieldid);
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'en','ld_field',@tabid,@fieldid,'Complete Task' 
from dual where not EXISTS(select 1 from ld_tranlabel  where languagetype = 'en' 
and trantable ='ld_field' and tabid = @tabid and relateid=@fieldid);
delimiter;

call AddColumn('ld_projecttask','costbudget','int','11', '');
alter table ld_projecttask modify costbudget decimal(25,2);
call AddColumn('ld_projecttask','timebudget','decimal','25,2', '');
alter table ld_projecttask modify timebudget decimal(25,2);
call AddColumn('ld_projecttask','hascost','decimal','25,2', '');
alter table ld_projecttask modify hascost decimal(25,2);
call AddColumn('ld_projecttask','hastime','decimal','25,2', '');
alter table ld_projecttask modify hastime decimal(25,2);

call AddColumn('ld_projecttask','projecttaskstatus','varchar','100',NULL);
call AddColumn('ld_projecttask','actualenddate','date','', '');
delimiter;

select tabid into @tabid from ld_tab where `name` = 'ProjectTask';
DELETE FROM ld_blocks WHERE tabid=@tabid AND blocklabel='LBL_CUSTOM_INFORMATION';
insert into ld_blocks(blockid,tabid,blocklabel,sequence)
select (select max(blockid) from ld_blocks)+1,@tabid,'LBL_BUDGET_SCHEDULE_INFO',2 from dual where not exists (select * from ld_blocks where 
tabid = @tabid and blocklabel = 'LBL_BUDGET_SCHEDULE_INFO' and sequence = 2);
delimiter;

select tabid into @tabid from ld_tab where `name` = 'ProjectTask';
SELECT blockid INTO @blockid FROM ld_blocks WHERE tabid=@tabid AND blocklabel='LBL_BUDGET_SCHEDULE_INFO';
UPDATE ld_field SET block=@blockid WHERE tabid=@tabid AND block=107;
UPDATE ld_field SET block=@blockid  WHERE tabid=@tabid AND block=106 AND columnname='projecttaskpriority';
delimiter;

insert into ld_field(tabid,fieldid,columnname,tablename,uitype,fieldname,fieldlabel,block,displaytype,presence,typeofdata,generatedtype,sequence)
select @tabid,(select max(fieldid) from ld_field)+1,'costbudget','ld_projecttask',7,'costbudget','费用预算',(select blockid from ld_blocks where blocklabel = 'LBL_BUDGET_SCHEDULE_INFO' AND tabid=@tabid),1,0,'V~M',1,6 from dual where not exists 
(select 1 from ld_field where tabid = @tabid and columnname = 'costbudget');
delimiter;

insert into ld_field(tabid,fieldid,columnname,tablename,uitype,fieldname,fieldlabel,block,displaytype,presence,typeofdata,generatedtype,sequence)
select @tabid,(select max(fieldid) from ld_field)+1,'timebudget','ld_projecttask',7,'timebudget','工时预算',(select blockid from ld_blocks where blocklabel = 'LBL_BUDGET_SCHEDULE_INFO' AND tabid=@tabid ),1,0,'V~M',1,7 from dual where not exists 
(select 1 from ld_field where tabid = @tabid and columnname = 'timebudget');
delimiter;
insert into ld_field(tabid,fieldid,columnname,tablename,uitype,fieldname,fieldlabel,block,displaytype,presence,typeofdata,generatedtype,readonly,sequence)
select @tabid,(select max(fieldid) from ld_field)+1,'hascost','ld_projecttask',7,'hascost','已用费用',(select blockid from ld_blocks where blocklabel = 'LBL_BUDGET_SCHEDULE_INFO' and  tabid=@tabid),1,0,'V~O',1,1,13 from dual where not exists 
(select 1 from ld_field where tabid = @tabid and columnname = 'hascost');
delimiter;

insert into ld_field(tabid,fieldid,columnname,tablename,uitype,fieldname,fieldlabel,block,displaytype,presence,typeofdata,generatedtype,readonly,sequence)
select @tabid,(select max(fieldid) from ld_field)+1,'hastime','ld_projecttask',7,'hastime','已用工时',(select blockid from ld_blocks where blocklabel = 'LBL_BUDGET_SCHEDULE_INFO' AND tabid=@tabid),1,0,'V~O',1,1,14 from dual where not exists 
(select 1 from ld_field where tabid = @tabid and columnname = 'hastime');
delimiter;

insert into ld_field(tabid,fieldid,columnname,tablename,uitype,fieldname,fieldlabel,block,displaytype,presence,typeofdata,generatedtype,readonly,sequence)
select @tabid,(select max(fieldid) from ld_field)+1,'actualenddate','ld_projecttask',5,'actualenddate','实际完成日期',(select blockid from ld_blocks where blocklabel = 'LBL_BUDGET_SCHEDULE_INFO' AND tabid=@tabid),1,0,'V~M',1,1,15 from dual where not exists 
(select 1 from ld_field where tabid = @tabid and columnname = 'actualenddate');
delimiter;

insert into ld_field(tabid,fieldid,columnname,tablename,uitype,fieldname,fieldlabel,block,displaytype,presence,typeofdata,defaultvalue,generatedtype,sequence)
select @tabid,(select max(fieldid) from ld_field)+1,'projecttaskstatus','ld_projecttask',15,'projecttaskstatus','状态',(select blockid from ld_blocks where blocklabel = 'LBL_BUDGET_SCHEDULE_INFO'  AND tabid=@tabid),1,0,'V~O','未开始',1,1 from dual where not exists 
(select 1 from ld_field where tabid = @tabid and columnname = 'projecttaskstatus');
delimiter;

insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'zh','ld_blocks',@tabid,@blockid ,'预算和进度' 
from dual where not EXISTS(select 1 from ld_tranlabel  where languagetype = 'zh' 
and trantable ='ld_blocks' and tabid = @tabid and relateid=@blockid);
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'en','ld_blocks',@tabid,@blockid,'Budget And Schedule' 
from dual where not EXISTS(select 1 from ld_tranlabel  where languagetype = 'en' 
and trantable ='ld_blocks' and tabid = @tabid and relateid=@blockid);
delimiter;

select fieldid into @fieldid from ld_field where tabid = @tabid and fieldname = 'costbudget';
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'zh','ld_field',@tabid,@fieldid,'费用预算' 
from dual where not EXISTS(select 1 from ld_tranlabel  where languagetype = 'zh' 
and trantable ='ld_field' and tabid = @tabid and relateid=@fieldid);
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'en','ld_field',@tabid,@fieldid,'Cost Budget' 
from dual where not EXISTS(select 1 from ld_tranlabel  where languagetype = 'en' 
and trantable ='ld_field' and tabid = @tabid and relateid=@fieldid);
delimiter;

select fieldid into @fieldid from ld_field where tabid = @tabid and fieldname = 'timebudget';
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'zh','ld_field',@tabid,@fieldid,'工时预算' 
from dual where not EXISTS(select 1 from ld_tranlabel  where languagetype = 'zh' 
and trantable ='ld_field' and tabid = @tabid and relateid=@fieldid);
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'en','ld_field',@tabid,@fieldid,'Time Budget' 
from dual where not EXISTS(select 1 from ld_tranlabel  where languagetype = 'en' 
and trantable ='ld_field' and tabid = @tabid and relateid=@fieldid);
delimiter;

select fieldid into @fieldid from ld_field where tabid = @tabid and fieldname = 'hascost';
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'zh','ld_field',@tabid,@fieldid,'已用费用' 
from dual where not EXISTS(select 1 from ld_tranlabel  where languagetype = 'zh' 
and trantable ='ld_field' and tabid = @tabid and relateid=@fieldid);
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'en','ld_field',@tabid,@fieldid,'Has cost' 
from dual where not EXISTS(select 1 from ld_tranlabel  where languagetype = 'en' 
and trantable ='ld_field' and tabid = @tabid and relateid=@fieldid);
delimiter;

select fieldid into @fieldid from ld_field where tabid = @tabid and fieldname = 'hastime';
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'zh','ld_field',@tabid,@fieldid,'已用工时' 
from dual where not EXISTS(select 1 from ld_tranlabel  where languagetype = 'zh' 
and trantable ='ld_field' and tabid = @tabid and relateid=@fieldid);
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'en','ld_field',@tabid,@fieldid,'Has Time' 
from dual where not EXISTS(select 1 from ld_tranlabel  where languagetype = 'en' 
and trantable ='ld_field' and tabid = @tabid and relateid=@fieldid);
delimiter;

select fieldid into @fieldid from ld_field where tabid = @tabid and fieldname = 'actualenddate';
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'zh','ld_field',@tabid,@fieldid,'实际完成日期' 
from dual where not EXISTS(select 1 from ld_tranlabel  where languagetype = 'zh' 
and trantable ='ld_field' and tabid = @tabid and relateid=@fieldid);
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'en','ld_field',@tabid,@fieldid,'Actual Date' 
from dual where not EXISTS(select 1 from ld_tranlabel  where languagetype = 'en' 
and trantable ='ld_field' and tabid = @tabid and relateid=@fieldid);
delimiter;

select fieldid into @fieldid from ld_field where tabid = @tabid and fieldname = 'projecttaskstatus';
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'zh','ld_field',@tabid,@fieldid,'状态' 
from dual where not EXISTS(select 1 from ld_tranlabel  where languagetype = 'zh' 
and trantable ='ld_field' and tabid = @tabid and relateid=@fieldid);
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'en','ld_field',@tabid,@fieldid,'ProjectTask Status' 
from dual where not EXISTS(select 1 from ld_tranlabel  where languagetype = 'en' 
and trantable ='ld_field' and tabid = @tabid and relateid=@fieldid);
delimiter;

SELECT tabid INTO @tabid FROM ld_tab WHERE `name`='Project';
SELECT tabid INTO @tabid2 FROM ld_tab WHERE `name`='ProjectProgress';
SELECT max(relation_id) INTO @relation_id FROM ld_relatedlists;
INSERT INTO  ld_relatedlists(relation_id,tabid,related_tabid,NAME,sequence,label,presence,actions,mobile_presence,mobile_sequence) 
SELECT @relation_id+1,@tabid,@tabid2,'get_dependents_list',7,'ProjectProgress',0,'ADD',1,7
FROM DUAL WHERE NOT EXISTS(SELECT 1 FROM ld_relatedlists WHERE tabid=@tabid AND NAME='get_dependents_list');
delimiter;

SELECT tabid INTO @tabid1 FROM ld_tab WHERE `name`='ProjectTask';
SELECT tabid INTO @tabid2 FROM ld_tab WHERE `name`='ProjectProgress';
SELECT max(relation_id) INTO @relation_id FROM ld_relatedlists;
INSERT INTO  ld_relatedlists(relation_id,tabid,related_tabid,NAME,sequence,label,presence,actions,mobile_presence,mobile_sequence) 
SELECT @relation_id+1,@tabid1,@tabid2,'get_dependents_list',3,'ProjectProgress',0,'ADD',1,3
FROM DUAL WHERE NOT EXISTS(SELECT 1 FROM ld_relatedlists WHERE tabid=@tabid1 AND NAME='get_dependents_list');
delimiter;

SELECT tabid INTO @tabid FROM ld_tab WHERE `name`='Project';
SELECT tabid INTO @tabid2 FROM ld_tab WHERE `name`='ProjectProgress';
SELECT max(relation_id) INTO @relation_id FROM ld_quickactions;
INSERT INTO  ld_quickactions(relation_id,tabid,related_tabid,sequence,presence,label) 
SELECT @relation_id+1,@tabid,@tabid2,9,0,'项目进度'
FROM DUAL WHERE NOT EXISTS(SELECT 1 FROM ld_quickactions WHERE tabid=@tabid AND related_tabid=@tabid2);
delimiter;

SELECT tabid INTO @tabid1 FROM ld_tab WHERE `name`='ProjectTask';
SELECT tabid INTO @tabid3 FROM ld_tab WHERE `name`='ProjectProgress';
SELECT max(relation_id) INTO @relation_id FROM ld_quickactions;
INSERT INTO  ld_quickactions(relation_id,tabid,related_tabid,sequence,presence,label) 
SELECT @relation_id+1,@tabid1,@tabid3,7,0,'项目进度'
FROM DUAL WHERE NOT EXISTS(SELECT 1 FROM ld_quickactions WHERE tabid=@tabid1 AND related_tabid=@tabid3);
delimiter;


CREATE TABLE IF not EXISTS `ld_projecttaskstatus` (
  `projecttaskstatusid` int(11) NOT NULL AUTO_INCREMENT,
  `projecttaskstatus` varchar(200) NOT NULL,
  `presence` int(1) NOT NULL DEFAULT '1',
  `picklist_valueid` int(11) NOT NULL DEFAULT '0',
  PRIMARY KEY (`projecttaskstatusid`)
) ENGINE=InnoDB AUTO_INCREMENT=5 DEFAULT CHARSET=utf8;
delimiter;


SELECT id INTO @picklist_valueid FROM ld_picklistvalues_seq;
select ifnull(max(projecttaskstatusid),0) into @projecttaskstatusid from ld_projecttaskstatus;
INSERT INTO ld_projecttaskstatus(projecttaskstatusid,projecttaskstatus,presence,picklist_valueid)
SELECT @projecttaskstatusid+1,'未开始',1, @picklist_valueid+1 FROM DUAL
where not exists(SELECT 1 FROM ld_projecttaskstatus WHERE projecttaskstatus='未开始');
update ld_picklistvalues_seq set id=@picklist_valueid+1 where not EXISTS (SELECT 1 FROM ld_projecttaskstatus WHERE projecttaskstatus='未开始');

INSERT INTO ld_projecttaskstatus(projecttaskstatusid,projecttaskstatus,presence,picklist_valueid)
SELECT 2,'执行中',1, @picklist_valueid+2 FROM DUAL
where not exists(SELECT 1 FROM ld_projecttaskstatus WHERE projecttaskstatus='执行中');
update ld_picklistvalues_seq set id=@picklist_valueid+1 where not EXISTS (SELECT 1 FROM ld_projecttaskstatus WHERE projecttaskstatus='执行中');

INSERT INTO ld_projecttaskstatus(projecttaskstatusid,projecttaskstatus,presence,picklist_valueid)
SELECT 3,'已搁置',1, @picklist_valueid+3 FROM DUAL
where not exists(SELECT 1 FROM ld_projecttaskstatus WHERE projecttaskstatus='已搁置');
update ld_picklistvalues_seq set id=@picklist_valueid+1 where not EXISTS (SELECT 1 FROM ld_projecttaskstatus WHERE projecttaskstatus='已搁置');


INSERT INTO ld_projecttaskstatus(projecttaskstatusid,projecttaskstatus,presence,picklist_valueid)
SELECT 4,'已完成',1, @picklist_valueid+4 FROM DUAL
where not exists(SELECT 1 FROM ld_projecttaskstatus WHERE projecttaskstatus='已完成');
delimiter;

SELECT tabid INTO @tabid FROM ld_tab WHERE NAME='ProjectTask';
SELECT fieldid INTO @fieldid FROM ld_field WHERE tabid=@tabid AND columnname='smownerid';
SELECT fieldid INTO @fieldid2 FROM ld_field WHERE tabid=@tabid AND columnname='projecttaskname';
UPDATE ld_tranlabel SET fieldlabel='负责人' where tabid=@tabid AND Relateid=@fieldid AND languagetype='zh';
UPDATE ld_tranlabel SET fieldlabel='计划名称' where tabid=@tabid AND Relateid=@fieldid2 AND languagetype='zh';
delimiter;

select cvid into @cvid from ld_customview where viewname='All' and entitytype='ProjectTask';
DELETE FROM ld_cvcolumnlist WHERE cvid=@cvid ;
insert into ld_cvcolumnlist(cvid,columnindex,columnname)
select @cvid,0,'ld_projecttask:projecttask_no:projecttask_no:ProjectTask_fieldlabel:V';

insert into ld_cvcolumnlist(cvid,columnindex,columnname)
select @cvid,1,'ld_projecttask:projecttaskname:projecttaskname:ProjectTask_fieldlabel:V';

insert into ld_cvcolumnlist(cvid,columnindex,columnname)
select @cvid,2,'ld_projecttask:projectid:projectid:ProjectTask_fieldlabel:V';

insert into ld_cvcolumnlist(cvid,columnindex,columnname)
select @cvid,3,'ld_projecttask:accountid:accountid:ProjectTask_fieldlabel:V';

insert into ld_cvcolumnlist(cvid,columnindex,columnname)
select @cvid,4,'ld_projecttask:projecttaskpriority:projecttaskpriority:ProjectTask_fieldlabel:V';

insert into ld_cvcolumnlist(cvid,columnindex,columnname)
select @cvid,5,'ld_projecttask:projecttaskstatus:projecttaskstatus:ProjectTask_fieldlabel:V';

insert into ld_cvcolumnlist(cvid,columnindex,columnname)
select @cvid,6,'ld_projecttask:costbudget:costbudget:ProjectTask_fieldlabel:V';

insert into ld_cvcolumnlist(cvid,columnindex,columnname)
select @cvid,7,'ld_projecttask:hascost:hascost:ProjectTask_fieldlabel:V';

insert into ld_cvcolumnlist(cvid,columnindex,columnname)
select @cvid,8,'ld_projecttask:timebudget:timebudget:ProjectTask_fieldlabel:V';

insert into ld_cvcolumnlist(cvid,columnindex,columnname)
select @cvid,9,'ld_projecttask:hastime:hastime:ProjectTask_fieldlabel:V';

insert into ld_cvcolumnlist(cvid,columnindex,columnname)
select @cvid,10,'ld_projecttask:smownerid:assigned_user_id:ProjectTask_fieldlabel:V' 
from dual where not EXISTS(select 1 from ld_cvcolumnlist  where cvid = @cvid 
and columnindex =10 and columnname ='ld_projecttask:smownerid:assigned_user_id:ProjectTask_fieldlabel:V');
delimiter;

select cvid into @cvid2 from ld_customview where entitytype = 'Project' and viewname = 'All';
DELETE FROM ld_cvcolumnlist WHERE  cvid=@cvid2;
insert into ld_cvcolumnlist(cvid,columnindex,columnname)
select @cvid2,0,'ld_project:project_no:project_no:Project_fieldlabel:V' 
from dual where not EXISTS(select 1 from ld_cvcolumnlist  where cvid = @cvid2 
and columnindex =0 and columnname ='ld_project:project_no:project_no:Project_fieldlabel:V');
delimiter;

insert into ld_cvcolumnlist(cvid,columnindex,columnname)
select @cvid2,1,'ld_project:projectname:projectname:Project_fieldlabel:V' 
from dual where not EXISTS(select 1 from ld_cvcolumnlist  where cvid = @cvid2 
and columnindex =1 and columnname ='ld_project:projectname:projectname:Project_fieldlabel:V');
delimiter;

insert into ld_cvcolumnlist(cvid,columnindex,columnname)
select @cvid2,2,'ld_project:accountid:accountid:Project_fieldlabel:V' 
from dual where not EXISTS(select 1 from ld_cvcolumnlist  where cvid = @cvid2 
and columnindex =2 and columnname ='ld_project:accountid:accountid:Project_fieldlabel:V');
delimiter; 

insert into ld_cvcolumnlist(cvid,columnindex,columnname)
select @cvid2,3,'ld_project:salesorderid:salesorder_id:Project_fieldlabel:V' 
from dual where not EXISTS(select 1 from ld_cvcolumnlist  where cvid = @cvid2 
and columnindex =3 and columnname ='ld_project:salesorderid:salesorderid:Project_fieldlabel:V');
delimiter; 
insert into ld_cvcolumnlist(cvid,columnindex,columnname)
select @cvid2,4,'ld_project:projectstatus:projectstatus:Project_fieldlabel:V' 
from dual where not EXISTS(select 1 from ld_cvcolumnlist  where cvid = @cvid2 
and columnindex =4 and columnname ='ld_project:projectstatus:projectstatus:Project_fieldlabel:V');
delimiter; 

insert into ld_cvcolumnlist(cvid,columnindex,columnname)
select @cvid2,5,'ld_project:startdate:startdate:Project_fieldlabel:V' 
from dual where not EXISTS(select 1 from ld_cvcolumnlist  where cvid = @cvid2 
and columnindex =5 and columnname ='ld_project:startdate:startdate:Project_fieldlabel:V');
delimiter; 

insert into ld_cvcolumnlist(cvid,columnindex,columnname)
select @cvid2,6,'ld_project:targetenddate:targetenddate:Project_fieldlabel:V' 
from dual where not EXISTS(select 1 from ld_cvcolumnlist  where cvid = @cvid2 
and columnindex =6 and columnname ='ld_project:targetenddate:targetenddate:Project_fieldlabel:V');
delimiter;
insert into ld_cvcolumnlist(cvid,columnindex,columnname)
select @cvid2,7,'ld_project:costbudget:costbudget:Project_fieldlabel:V' 
from dual where not EXISTS(select 1 from ld_cvcolumnlist  where cvid = @cvid2 
and columnindex =7 and columnname ='ld_project:costbudget:costbudget:Project_fieldlabel:V');
delimiter;

insert into ld_cvcolumnlist(cvid,columnindex,columnname)
select @cvid2,8,'ld_project:timebudget:timebudget:Project_fieldlabel:V' 
from dual where not EXISTS(select 1 from ld_cvcolumnlist  where cvid = @cvid2 
and columnindex =8 and columnname ='ld_project:timebudget:timebudget:Project_fieldlabel:V');
delimiter;
insert into ld_cvcolumnlist(cvid,columnindex,columnname)
select @cvid2,9,'ld_project:smownerid:assigned_user_id:Project_fieldlabel:V' 
from dual where not EXISTS(select 1 from ld_cvcolumnlist  where cvid = @cvid2 
and columnindex =9 and columnname ='ld_project:smownerid:assigned_user_id:Project_fieldlabel:V');

SELECT tabid INTO @tabid FROM ld_tab WHERE `name`='ProjectTask';
insert into ld_profileallpermission(tabid,operation)
select @tabid,23 
from dual where not EXISTS(select 1 from ld_profileallpermission  where tabid=@tabid AND operation=23);
delimiter;
DELETE FROM ld_profile2standardpermissions WHERE tabid=@tabid;
call addtabintoprofile('ProjectTask',0);

SELECT tabid INTO @tabid FROM ld_tab WHERE NAME='ProjectTask';
SELECT fieldid INTO @fieldid FROM ld_field WHERE tabid=@tabid  AND fieldname='projecttask_no';
UPDATE ld_tranlabel set fieldlabel='计划编号'
where tabid=@tabid AND Relateid=@fieldid AND languagetype='zh';
delimiter;

SELECT fieldid INTO @fieldid FROM ld_field WHERE tabid=@tabid  AND fieldname='projecttasknumber';
UPDATE ld_tranlabel set fieldlabel='计划数量'
where tabid=@tabid AND Relateid=@fieldid AND languagetype='zh';
delimiter;

SELECT fieldid INTO @fieldid FROM ld_field WHERE tabid=@tabid  AND fieldname='projecttasktype';
UPDATE ld_tranlabel set fieldlabel='计划类别'
where tabid=@tabid AND Relateid=@fieldid AND languagetype='zh';
delimiter;

SELECT fieldid INTO @fieldid FROM ld_field WHERE tabid=@tabid  AND fieldname='projecttaskprogress';
UPDATE ld_tranlabel set fieldlabel='计划进度'
where tabid=@tabid AND Relateid=@fieldid AND languagetype='zh';
delimiter;

select parenttabid into @parenttabid from ld_parenttab where parenttab_label='Project';
select tabid into @tabid1 from ld_tab where `name`='ProjectProgress';
select tabid into @tabid2 from ld_tab where `name`='Rate';
update ld_parenttabrel set sequence=sequence+20 where parenttabid=@parenttabid;
update ld_parenttabrel set sequence=1 where parenttabid=@parenttabid and tabid=48;
update ld_parenttabrel set sequence=2 where parenttabid=@parenttabid and tabid=47;
update ld_parenttabrel set sequence=3 where parenttabid=@parenttabid and tabid=@tabid1;
update ld_parenttabrel set sequence=4 where parenttabid=@parenttabid and tabid=46;
update ld_parenttabrel set sequence=5 where parenttabid=@parenttabid and tabid=@tabid2;
set @i=0;
update ld_parenttabrel set sequence=(@i:=@i+1) where parenttabid=@parenttabid order by sequence;
delimiter;

update ld_field set uitype=1 where tabid=47 and columnname='projecttasknumber';
update ld_tranlabel set fieldlabel='已完成任务' where languagetype='zh' and trantable='ld_field' and tabid=48 and 
Relateid=(select fieldid from ld_field where columnname='completetask');
delimiter;

CREATE TABLE IF NOT EXISTS `ld_rate` (
  `rate_id` int(19) NOT NULL AUTO_INCREMENT,
  `ratename` varchar(50) NOT NULL,
  `rate` decimal(25,2) DEFAULT '0.00',
  `startdate` date DEFAULT NULL,
  `enddate` date DEFAULT NULL,
  `remark` varchar(200) DEFAULT NULL,
  `modifiedby` int(11) DEFAULT NULL,
  `modifiedtime` date DEFAULT NULL,
  `createdtime` date DEFAULT NULL,
  `smownerid` int(11) DEFAULT NULL,
  `smcreatorid` int(11) DEFAULT NULL,
  `strrole_id` varchar(200) DEFAULT NULL,
  `struser_id` varchar(200) DEFAULT NULL,
  `deleted` int(11) DEFAULT '0',
  PRIMARY KEY (`rate_id`)
) ENGINE=InnoDB AUTO_INCREMENT=130433 DEFAULT CHARSET=utf8;
delimiter;

CREATE TABLE IF NOT EXISTS `ld_ratescf` (
  `rate_id` int(19) NOT NULL DEFAULT '1',
  PRIMARY KEY (`rate_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
delimiter;

select max(tabid) into @tabid from ld_tab;
select max(tabsequence) into @tabsequence from ld_tab;
insert into ld_tab(tabid,name,presence,tabsequence,tablabel,isentitytype,parent,printtab)
select @tabid + 1,'Rate',1,@tabsequence+1,'Rate',1,'Support',0 
from dual where not exists(select 1 from ld_tab  where `name`='Rate');
delimiter;

select parenttabid into @parenttabid from ld_parenttab where parenttab_label = 'Project';
select max(sequence) into @sequence from ld_parenttabrel where parenttabid = @parenttabid;
select tabid into @tabid from ld_tab where `name` = 'Rate';
insert into ld_parenttabrel(parenttabid,tabid,sequence)
select @parenttabid,@tabid,@sequence+1 
from dual where not EXISTS(select 1 from ld_parenttabrel  where parenttabid = @parenttabid and tabid =@tabid);
delimiter;

select tabid into @tabid from ld_tab where `name` = 'Rate';
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'zh','ld_tab',@tabid,@tabid,'费率' from dual 
where not EXISTS(select 1 from ld_tranlabel  where languagetype = 'zh' and trantable ='ld_tab' and tabid = @tabid and relateid=@tabid);

insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'en','ld_tab',@tabid,@tabid,'Rate' from dual 
where not EXISTS(select 1 from ld_tranlabel  where languagetype = 'en' and trantable ='ld_tab' and tabid = @tabid and relateid=@tabid);

select tabid into @tabid from ld_tab where `name` = 'Rate';
insert into ld_org_share_action2tab(share_action_id,tabid) select 0,@tabid from dual 
where not exists(select 1 from ld_org_share_action2tab where share_action_id=0 and tabid=@tabid);

insert into ld_org_share_action2tab(share_action_id,tabid) select 1,@tabid from dual 
where not exists(select 1 from ld_org_share_action2tab where share_action_id=1 and tabid=@tabid);

insert into ld_org_share_action2tab(share_action_id,tabid) select 2,@tabid from dual 
where not exists(select 1 from ld_org_share_action2tab where share_action_id=2 and tabid=@tabid);

insert into ld_org_share_action2tab(share_action_id,tabid) select 3,@tabid from dual 
where not exists(select 1 from ld_org_share_action2tab where share_action_id=3 and tabid=@tabid);

select max(ruleid) into @ruleid from ld_def_org_share;
update ld_def_org_share_seq set id=@ruleid+1 where  not exists(select 1 from ld_def_org_share where tabid=@tabid);
insert into ld_def_org_share(ruleid,tabid,permission,editstatus)
select @ruleid+1,@tabid,0,0  from dual where  not exists(select 1 from ld_def_org_share where tabid=@tabid);
delimiter;

select tabid into @tabid from ld_tab where `name` = 'Rate';
insert into ld_blocks(blockid,tabid,blocklabel,sequence)
select (select max(blockid) from ld_blocks)+1,@tabid,'LBL_RATE_INFO',1 from dual where not exists (select * from ld_blocks where 
tabid = @tabid and blocklabel = 'LBL_RATE_INFO' and sequence = 1);
insert into ld_blocks(blockid,tabid,blocklabel,sequence)
select (select max(blockid) from ld_blocks)+1,@tabid,'LBL_RATE_REMARK',2 from dual where not exists (select * from ld_blocks where 
tabid = @tabid and blocklabel = 'LBL_RATE_REMARK' and sequence = 2);
update ld_blocks_seq set id = (select max(blockid)+1 from ld_blocks);

insert into ld_field(tabid,fieldid,columnname,tablename,uitype,fieldname,fieldlabel,block,displaytype,presence,typeofdata,sequence)
select @tabid,(select max(fieldid) from ld_field)+1,'ratename','ld_rate',1,'ratename','费率名称',(select blockid from ld_blocks where blocklabel = 'LBL_RATE_INFO'),1,0,'V~M',1 from dual where not exists 
(select * from ld_field where tabid = @tabid and columnname = 'ratename');

insert into ld_field(tabid,fieldid,columnname,tablename,uitype,fieldname,fieldlabel,block,displaytype,presence,typeofdata,sequence)
select @tabid,(select max(fieldid) from ld_field)+1,'rate','ld_rate',1,'rate','费率(￥)',(select blockid from ld_blocks where blocklabel = 'LBL_RATE_INFO'),1,0,'V~O',2 from dual where not exists 
(select * from ld_field where tabid = @tabid and columnname = 'rate');

insert into ld_field(tabid,fieldid,columnname,tablename,uitype,fieldname,fieldlabel,block,displaytype,presence,typeofdata,sequence)
select @tabid,(select max(fieldid) from ld_field)+1,'startdate','ld_rate',5,'startdate','起始日期',(select blockid from ld_blocks where blocklabel = 'LBL_RATE_INFO'),1,0,'D~M',3 from dual where not exists 
(select * from ld_field where tabid = @tabid and columnname = 'startdate');

insert into ld_field(tabid,fieldid,columnname,tablename,uitype,fieldname,fieldlabel,block,displaytype,presence,typeofdata,sequence)
select @tabid,(select max(fieldid) from ld_field)+1,'enddate','ld_rate',5,'enddate','截止日期',(select blockid from ld_blocks where blocklabel = 'LBL_RATE_INFO'),1,0,'D~M',4 from dual where not exists 
(select * from ld_field where tabid = @tabid and columnname = 'enddate');

insert into ld_field(tabid,fieldid,columnname,tablename,uitype,fieldname,fieldlabel,block,displaytype,presence,typeofdata,sequence)
select @tabid,(select max(fieldid) from ld_field)+1,'remark','ld_rate',19,'remark','备注',(select blockid from ld_blocks where blocklabel = 'LBL_RATE_REMARK'),1,0,'V~O',5 from dual where not exists 
(select * from ld_field where tabid = @tabid and columnname = 'remark');

insert into ld_field(tabid,fieldid,columnname,tablename,uitype,fieldname,fieldlabel,block,displaytype,presence,typeofdata,sequence)
select @tabid,(select max(fieldid) from ld_field)+1,'modifiedby','ld_rate',53,'modifiedby','最新更新人',(select blockid from ld_blocks where blocklabel = 'LBL_RATE_INFO'),2,0,'V~O',6 from dual where not exists 
(select * from ld_field where tabid = @tabid and columnname = 'modifiedby');

insert into ld_field(tabid,fieldid,columnname,tablename,uitype,fieldname,fieldlabel,block,displaytype,presence,typeofdata,sequence)
select @tabid,(select max(fieldid) from ld_field)+1,'modifiedtime','ld_rate',5,'modifiedtime','修改时间',(select blockid from ld_blocks where blocklabel = 'LBL_RATE_INFO'),2,0,'D~O',7 from dual where not exists 
(select * from ld_field where tabid = @tabid and columnname = 'modifiedtime');

insert into ld_field(tabid,fieldid,columnname,tablename,uitype,fieldname,fieldlabel,block,displaytype,presence,typeofdata,sequence)
select @tabid,(select max(fieldid) from ld_field)+1,'createdtime','ld_rate',5,'createdtime','创建时间',(select blockid from ld_blocks where blocklabel = 'LBL_RATE_INFO'),2,0,'D~O',8 from dual where not exists 
(select * from ld_field where tabid = @tabid and columnname = 'createdtime');

insert into ld_field(tabid,fieldid,columnname,tablename,uitype,fieldname,fieldlabel,block,displaytype,presence,typeofdata,sequence,issmownerid)
select @tabid,(select max(fieldid) from ld_field)+1,'smownerid','ld_rate',53,'assigned_user_id','负责人',(select blockid from ld_blocks where blocklabel = 'LBL_RATE_INFO'),1,0,'V~O',9,1 from dual where not exists 
(select * from ld_field where tabid = @tabid and columnname = 'smownerid');

insert into ld_field(tabid,fieldid,columnname,tablename,uitype,fieldname,fieldlabel,block,displaytype,presence,typeofdata,sequence)
select @tabid,(select max(fieldid) from ld_field)+1,'smcreatorid','ld_rate',52,'creator','创建人',(select blockid from ld_blocks where blocklabel = 'LBL_RATE_INFO'),2,0,'V~O',10 from dual where not exists 
(select * from ld_field where tabid = @tabid and columnname = 'smcreatorid');

insert into ld_field(tabid,fieldid,columnname,tablename,uitype,fieldname,fieldlabel,block,displaytype,presence,typeofdata,sequence)
select @tabid,(select max(fieldid) from ld_field)+1,'strrole_id','ld_rate',1,'strrole_id','适用范围',(select blockid from ld_blocks where blocklabel = 'LBL_RATE_INFO'),1,0,'V~O',11 from dual where not exists 
(select * from ld_field where tabid = @tabid and columnname = 'strrole_id');


select tabid into @tabid from ld_tab where `name` = 'Rate';
select fieldid into @fieldid from ld_field where tabid = @tabid and fieldname = 'ratename';
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'zh','ld_field',@tabid,@fieldid,'费率名称' 
from dual where not EXISTS(select 1 from ld_tranlabel  where languagetype = 'zh' 
and trantable ='ld_field' and tabid = @tabid and relateid=@fieldid);
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'en','ld_field',@tabid,@fieldid,'Rate Name' 
from dual where not EXISTS(select 1 from ld_tranlabel  where languagetype = 'en' 
and trantable ='ld_field' and tabid = @tabid and relateid=@fieldid);

select fieldid into @fieldid from ld_field where tabid = @tabid and fieldname = 'rate';
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'zh','ld_field',@tabid,@fieldid,'费率(￥)' 
from dual where not EXISTS(select 1 from ld_tranlabel  where languagetype = 'zh' 
and trantable ='ld_field' and tabid = @tabid and relateid=@fieldid);
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'en','ld_field',@tabid,@fieldid,'Rate' 
from dual where not EXISTS(select 1 from ld_tranlabel  where languagetype = 'en' 
and trantable ='ld_field' and tabid = @tabid and relateid=@fieldid);

select fieldid into @fieldid from ld_field where tabid = @tabid and fieldname = 'startdate';
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'zh','ld_field',@tabid,@fieldid,'起始日期' 
from dual where not EXISTS(select 1 from ld_tranlabel  where languagetype = 'zh' 
and trantable ='ld_field' and tabid = @tabid and relateid=@fieldid);
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'en','ld_field',@tabid,@fieldid,'Start Date' 
from dual where not EXISTS(select 1 from ld_tranlabel  where languagetype = 'en' 
and trantable ='ld_field' and tabid = @tabid and relateid=@fieldid);

select fieldid into @fieldid from ld_field where tabid = @tabid and fieldname = 'enddate';
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'zh','ld_field',@tabid,@fieldid,'截止日期' 
from dual where not EXISTS(select 1 from ld_tranlabel  where languagetype = 'zh' 
and trantable ='ld_field' and tabid = @tabid and relateid=@fieldid);
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'en','ld_field',@tabid,@fieldid,'End Date' 
from dual where not EXISTS(select 1 from ld_tranlabel  where languagetype = 'en' 
and trantable ='ld_field' and tabid = @tabid and relateid=@fieldid);

select fieldid into @fieldid from ld_field where tabid = @tabid and fieldname = 'remark';
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'zh','ld_field',@tabid,@fieldid,'备注' 
from dual where not EXISTS(select 1 from ld_tranlabel  where languagetype = 'zh' 
and trantable ='ld_field' and tabid = @tabid and relateid=@fieldid);
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'en','ld_field',@tabid,@fieldid,'Remark' 
from dual where not EXISTS(select 1 from ld_tranlabel  where languagetype = 'en' 
and trantable ='ld_field' and tabid = @tabid and relateid=@fieldid);

select fieldid into @fieldid from ld_field where tabid = @tabid and fieldname = 'modifiedby';
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'zh','ld_field',@tabid,@fieldid,'最新更新人' 
from dual where not EXISTS(select 1 from ld_tranlabel  where languagetype = 'zh' 
and trantable ='ld_field' and tabid = @tabid and relateid=@fieldid);
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'en','ld_field',@tabid,@fieldid,'Modified By' 
from dual where not EXISTS(select 1 from ld_tranlabel  where languagetype = 'en' 
and trantable ='ld_field' and tabid = @tabid and relateid=@fieldid);

select fieldid into @fieldid from ld_field where tabid = @tabid and fieldname = 'modifiedtime';
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'zh','ld_field',@tabid,@fieldid,'修改时间' 
from dual where not EXISTS(select 1 from ld_tranlabel  where languagetype = 'zh' 
and trantable ='ld_field' and tabid = @tabid and relateid=@fieldid);
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'en','ld_field',@tabid,@fieldid,'Modified Time' 
from dual where not EXISTS(select 1 from ld_tranlabel  where languagetype = 'en' 
and trantable ='ld_field' and tabid = @tabid and relateid=@fieldid);

select fieldid into @fieldid from ld_field where tabid = @tabid and fieldname = 'createdtime';
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'zh','ld_field',@tabid,@fieldid,'创建时间' 
from dual where not EXISTS(select 1 from ld_tranlabel  where languagetype = 'zh' 
and trantable ='ld_field' and tabid = @tabid and relateid=@fieldid);
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'en','ld_field',@tabid,@fieldid,'CreatedTime' 
from dual where not EXISTS(select 1 from ld_tranlabel  where languagetype = 'en' 
and trantable ='ld_field' and tabid = @tabid and relateid=@fieldid);

select fieldid into @fieldid from ld_field where tabid = @tabid and fieldname = 'smownerid';
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'zh','ld_field',@tabid,@fieldid,'负责人' 
from dual where not EXISTS(select 1 from ld_tranlabel  where languagetype = 'zh' 
and trantable ='ld_field' and tabid = @tabid and relateid=@fieldid);
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'en','ld_field',@tabid,@fieldid,'Smownerid' 
from dual where not EXISTS(select 1 from ld_tranlabel  where languagetype = 'en' 
and trantable ='ld_field' and tabid = @tabid and relateid=@fieldid);

select fieldid into @fieldid from ld_field where tabid = @tabid and fieldname = 'smcreatorid';
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'zh','ld_field',@tabid,@fieldid,'创建人' 
from dual where not EXISTS(select 1 from ld_tranlabel  where languagetype = 'zh' 
and trantable ='ld_field' and tabid = @tabid and relateid=@fieldid);
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'en','ld_field',@tabid,@fieldid,'Smcreatorid' 
from dual where not EXISTS(select 1 from ld_tranlabel  where languagetype = 'en' 
and trantable ='ld_field' and tabid = @tabid and relateid=@fieldid);

select fieldid into @fieldid from ld_field where tabid = @tabid and fieldname = 'strrole_id';
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'zh','ld_field',@tabid,@fieldid,'适用范围' 
from dual where not EXISTS(select 1 from ld_tranlabel  where languagetype = 'zh' 
and trantable ='ld_field' and tabid = @tabid and Relateid=@fieldid);
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'en','ld_field',@tabid,@fieldid,'StrroleId' 
from dual where not EXISTS(select 1 from ld_tranlabel  where languagetype = 'en' 
and trantable ='ld_field' and tabid = @tabid and Relateid=@fieldid);

SELECT max(cvid) into @cvid from ld_customview;
INSERT INTO ld_customview (cvid,viewname,setdefault,setmetrics,entitytype,status,userid,sequence,pagewidthpercent,customcategory)
SELECT @cvid+1,'All',1,0,'Rate',3,1,0,100,''
from dual where not EXISTS(select 1 from ld_customview  where viewname = 'All' 
and entitytype ='Rate');
delimiter;

select cvid into @cvid from ld_customview where entitytype = 'Rate' and viewname = 'All';
delete from ld_cvcolumnlist where cvid=@cvid;
insert into ld_cvcolumnlist(cvid,columnindex,columnname)
select @cvid,0,'ld_rate:rate_id:rate_id:Rate_fieldlabel:I';

insert into ld_cvcolumnlist(cvid,columnindex,columnname)
select @cvid,1,'ld_rate:ratename:ratename:Rate_fieldlabel:V';

insert into ld_cvcolumnlist(cvid,columnindex,columnname)
select @cvid,2,'ld_rate:rate:rate:Rate_fieldlabel:N';

insert into ld_cvcolumnlist(cvid,columnindex,columnname)
select @cvid,3,'ld_rate:startdate:startdate:Rate_fieldlabel:D';

insert into ld_cvcolumnlist(cvid,columnindex,columnname)
select @cvid,4,'ld_rate:enddate:enddate:Rate_fieldlabel:D';

insert into ld_cvcolumnlist(cvid,columnindex,columnname)
select @cvid,5,'ld_rate:remark:remark:Rate_fieldlabel:V';

insert into ld_cvcolumnlist(cvid,columnindex,columnname)
select @cvid,6,'ld_rate:modifiedby:modifiedby:Rate_fieldlabel:V';

insert into ld_cvcolumnlist(cvid,columnindex,columnname)
select @cvid,7,'ld_rate:modifiedtime:modifiedtime:Rate_fieldlabel:D';

insert into ld_cvcolumnlist(cvid,columnindex,columnname)
select @cvid,8,'ld_rate:createdtime:createdtime:Rate_fieldlabel:D';

insert into ld_cvcolumnlist(cvid,columnindex,columnname)
select @cvid,9,'ld_rate:smownerid:smownerid:Rate_fieldlabel:V';

insert into ld_cvcolumnlist(cvid,columnindex,columnname)
select @cvid,10,'ld_rate:smcreatorid:smcreatorid:Rate_fieldlabel:V';

insert into ld_cvcolumnlist(cvid,columnindex,columnname)
select @cvid,11,'ld_rate:strrole_id:strrole_id:Rate_fieldlabel:V';

insert into ld_cvcolumnlist(cvid,columnindex,columnname)
select @cvid,12,'ld_rate:struser_id:struser_id:Rate_fieldlabel:V';

select tabid into @tabid from ld_tab where `name` = 'Rate';
select id into @id from ld_links_seq;
insert into ld_links(linkid,tabid,linktype,linklabel,linkurl,linkicon,handler_path,handler_class,handler,sequence)
select @id+1,@tabid,'DETAILVIEWBASIC','View History',"javascript:ModTrackerCommon.showhistory('$RECORD$')",
'themes/images/pointer.gif','modules/ModTracker/ModTracker.php','ModTracker','isViewPermitted',0
from dual where not EXISTS(select 1 from ld_links  where tabid = @tabid 
and linktype ='DETAILVIEWBASIC');
update ld_links_seq set id = (select max(linkid) from ld_links);

update ld_tab set printtab = 1 where `name` = 'Rate';
delimiter;

select tabid into @tabid from ld_tab where `name` = 'Rate';
insert into ld_modtracker_tabs(tabid,visible)
select @tabid,1 from dual where not EXISTS(select 1 from ld_modtracker_tabs  where tabid = @tabid 
and visible =1);

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'zh','RATENAME','费率名称','fixedstr' from dual 
where not EXISTS(select 1 from ld_desk  where languagetype='zh' and labelbol='RATENAME' and Labeltype='fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'en','RATENAME','Rate Name','fixedstr' from dual 
where not EXISTS(select 1 from ld_desk  where languagetype='en' and labelbol='RATENAME' and Labeltype='fixedstr');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'zh','RATE','费率','fixedstr' from dual 
where not EXISTS(select 1 from ld_desk  where languagetype='zh' and labelbol='RATE' and Labeltype='fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'en','RATE','Rate','fixedstr' from dual 
where not EXISTS(select 1 from ld_desk  where languagetype='en' and labelbol='RATE' and Labeltype='fixedstr');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'zh','RATEID','费率ID','fixedstr' from dual 
where not EXISTS(select 1 from ld_desk  where languagetype='zh' and labelbol='RATEID' and Labeltype='fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'en','RATEID','Rate ID','fixedstr' from dual 
where not EXISTS(select 1 from ld_desk  where languagetype='en' and labelbol='RATEID' and Labeltype='fixedstr');
delimiter;

select tabid into @tabid from ld_tab where `name` = 'Rate';
select blockid into @blockid from ld_blocks where tabid = @tabid and blocklabel = 'LBL_RATE_INFO';
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'zh','ld_blocks',@tabid,@blockid,'基本信息' 
from dual where not EXISTS(select 1 from ld_tranlabel  where languagetype = 'zh' 
and trantable ='ld_blocks' and tabid = @tabid and relateid=@blockid);

insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'en','ld_blocks',@tabid,@blockid,'Basic Information' 
from dual where not EXISTS(select 1 from ld_tranlabel  where languagetype = 'en' 
and trantable ='ld_blocks' and tabid = @tabid and relateid=@blockid);

select tabid into @tabid from ld_tab where `name` = 'Rate';
select blockid into @blockid from ld_blocks where tabid = @tabid and blocklabel = 'LBL_RATE_REMARK';
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'zh','ld_blocks',@tabid,@blockid,'备注' 
from dual where not EXISTS(select 1 from ld_tranlabel  where languagetype = 'zh' 
and trantable ='ld_blocks' and tabid = @tabid and relateid=@blockid);

insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'en','ld_blocks',@tabid,@blockid,'Description Information' 
from dual where not EXISTS(select 1 from ld_tranlabel  where languagetype = 'en' 
and trantable ='ld_blocks' and tabid = @tabid and relateid=@blockid);

select tabid into @tabid from ld_tab where `name` = 'Rate';
insert into ld_entityname(tabid,modulename,tablename,fieldname,entityidfield,entityidcolumn)
select @tabid,'Rate','ld_rate','ratename','rate_id','rate_id'
from dual where not EXISTS(select 1 from ld_entityname  where tabid = @tabid 
and modulename ='Rate');

SELECT tabid into @tabid from ld_tab where name ='Rate';
INSERT into ld_profileallpermission(tabid,operation)
SELECT @tabid,3 FROM dual where not exists
(SELECT 1 from ld_profileallpermission WHERE tabid=@tabid and operation=3);

INSERT into ld_profileallpermission(tabid,operation)
SELECT @tabid,11 FROM dual where not exists
(SELECT 1 from ld_profileallpermission WHERE tabid=@tabid and operation=11);

INSERT into ld_profileallpermission(tabid,operation)
SELECT @tabid,1 FROM dual where not exists
(SELECT 1 from ld_profileallpermission WHERE tabid=@tabid and operation=1);

INSERT into ld_profileallpermission(tabid,operation)
SELECT @tabid,2 FROM dual where not exists
(SELECT 1 from ld_profileallpermission WHERE tabid=@tabid and operation=2);

INSERT into ld_profileallpermission(tabid,operation)
SELECT @tabid,12 FROM dual where not exists
(SELECT 1 from ld_profileallpermission WHERE tabid=@tabid and operation=12);

INSERT into ld_profileallpermission(tabid,operation)
SELECT @tabid,13 FROM dual where not exists
(SELECT 1 from ld_profileallpermission WHERE tabid=@tabid and operation=13);

INSERT into ld_profileallpermission(tabid,operation)
SELECT @tabid,14 FROM dual where not exists
(SELECT 1 from ld_profileallpermission WHERE tabid=@tabid and operation=14);

INSERT into ld_profileallpermission(tabid,operation)
SELECT @tabid,6 FROM dual where not exists
(SELECT 1 from ld_profileallpermission WHERE tabid=@tabid and operation=6);

INSERT into ld_profileallpermission(tabid,operation)
SELECT @tabid,25 FROM dual where not exists
(SELECT 1 from ld_profileallpermission WHERE tabid=@tabid and operation=25);

SELECT tabid into @tabid from ld_tab WHERE name = 'Rate';
SELECT MAX(relation_id) into @relation_id from ld_quickactions;
INSERT into ld_quickactions(relation_id,tabid,related_tabid,sequence,presence,label)
SELECT @relation_id+1,@tabid,-1,0,0,'' FROM dual where not exists
(SELECT 1 from ld_quickactions WHERE tabid=@tabid and related_tabid=-1);

SELECT MAX(relation_id) into @relation_id from ld_quickactions;
INSERT into ld_quickactions(relation_id,tabid,related_tabid,sequence,presence,label)
SELECT @relation_id+1,@tabid,78,0,0,'' FROM dual where not exists
(SELECT 1 from ld_quickactions WHERE tabid=@tabid and related_tabid=78);

SELECT MAX(relation_id) into @relation_id from ld_quickactions;
INSERT into ld_quickactions(relation_id,tabid,related_tabid,sequence,presence,label)
SELECT @relation_id+1,@tabid,-5,0,0,'' FROM dual where not exists
(SELECT 1 from ld_quickactions WHERE tabid=@tabid and related_tabid=-5);

CREATE TABLE IF NOT EXISTS `ld_projectabstract` (
  `projectid` int(11) NOT NULL,
  `module` varchar(255) DEFAULT NULL,
  `smcreatorid` int(11) DEFAULT NULL,
  `createdtime` datetime DEFAULT NULL,
  `description` varchar(255) DEFAULT NULL,
  `recordid` int(11) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
delimiter;

SELECT tabid INTO @tabid from ld_tab WHERE `name` ='Project';
SELECT MAX(relation_id) into @relation_id from ld_relatedlists;
SELECT MAX(mobile_sequence) INTO @mobile_sequence FROM ld_relatedlists WHERE tabid =@tabid;
SELECT MAX(sequence) INTO @sequence FROM ld_relatedlists WHERE tabid =@tabid;
insert into ld_relatedlists
(relation_id,tabid,related_tabid,name,sequence,label,presence,actions,mobile_presence,mobile_sequence)
select @relation_id+1,@tabid,0,'get_projectabstract',@sequence+1,'ProjectAbstract',0,'ADD,SELECT',1,@mobile_sequence+1
from dual where not EXISTS(select 1 from ld_relatedlists where tabid = @tabid and name ='get_projectabstract');
delimiter;

SELECT tabid INTO @tabid from ld_tab WHERE `name` ='ProjectMilestone';
SELECT MAX(relation_id) into @relation_id from ld_relatedlists;
SELECT MAX(mobile_sequence) INTO @mobile_sequence FROM ld_relatedlists WHERE tabid = @tabid;
SELECT MAX(sequence) INTO @sequence FROM ld_relatedlists WHERE tabid =@tabid;
insert into ld_relatedlists
(relation_id,tabid,related_tabid,name,sequence,label,presence,actions,mobile_presence,mobile_sequence)
select @relation_id+1,@tabid,0,'get_projectabstract',@sequence+1,'ProjectAbstract',0,'ADD,SELECT',1,@mobile_sequence+1
from dual where not EXISTS(select 1 from ld_relatedlists where tabid = @tabid and name ='get_projectabstract');
delimiter;

SELECT tabid INTO @tabid from ld_tab WHERE `name` ='ProjectTask';
SELECT MAX(relation_id) into @relation_id from ld_relatedlists;
SELECT MAX(mobile_sequence) INTO @mobile_sequence FROM ld_relatedlists WHERE tabid = @tabid;
SELECT MAX(sequence) INTO @sequence FROM ld_relatedlists WHERE tabid =@tabid;
insert into ld_relatedlists
(relation_id,tabid,related_tabid,name,sequence,label,presence,actions,mobile_presence,mobile_sequence)
select @relation_id+1,@tabid,0,'get_projectabstract',@sequence+1,'ProjectAbstract',0,'ADD,SELECT',1,@mobile_sequence+1
from dual where not EXISTS(select 1 from ld_relatedlists where tabid = @tabid and name ='get_projectabstract');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,Labeltype)
select 'zh','ProjectAbstract','项目摘要','fixedstr'
from dual where not EXISTS(select 1 from ld_desk where languagetype = 'zh' and labelbol ='ProjectAbstract');
delimiter;
insert into ld_desk(languagetype,labelbol,fieldlabel,Labeltype)
select 'en','ProjectAbstract','ProjectAbstract','fixedstr'
from dual where not EXISTS(select 1 from ld_desk where languagetype = 'en' and labelbol ='ProjectAbstract');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,Labeltype)
select 'zh','OPERATORTYPE','操作类型','fixedstr'
from dual where not EXISTS(select 1 from ld_desk where languagetype = 'zh' and labelbol ='OPERATORTYPE' and 
Labeltype='fixedstr');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,Labeltype)
select 'en','OPERATORTYPE','Operator Type','fixedstr'
from dual where not EXISTS(select 1 from ld_desk where languagetype = 'en' and labelbol ='OPERATORTYPE' and 
Labeltype='fixedstr');
delimiter;

update ld_tab set presence=0 where `name`='Rate';
update ld_tranlabel set fieldlabel='费率设定' where languagetype='zh' and trantable='ld_tab' and tabid=(select tabid from ld_tab where `name`='Rate');

update ld_relatedlists set sequence=sequence+10 where tabid=48;
update ld_relatedlists set sequence=0 where tabid=48 and label='ProjectAbstract';
update ld_relatedlists set sequence=1 where tabid=48 and label='ProjectTask';
update ld_relatedlists set sequence=2 where tabid=48 and label='ProjectMilestone';
set @i=0;
update ld_relatedlists set sequence=(@i:=@i+1) where tabid=48 order by sequence;
delimiter;

select tabid into @tabid from ld_tab where `name`='ProjectProgress';
select sequence into @seq from ld_quickactions where tabid=48 and related_tabid=47;
update ld_quickactions set sequence=sequence+10 where tabid=48 and sequence>@seq;
update ld_quickactions set sequence=@seq+1 where tabid=48 and related_tabid=@tabid;
set @i=0;
update ld_quickactions set sequence=(@i:=@i+1) where tabid=48 order by sequence;
delimiter;

delete from ld_relatedlists where tabid=47 and label='ProjectAbstract';
update ld_relatedlists set presence=0 where tabid=47 and label in ('Attachment','ContactRecords');

update ld_relatedlists set sequence=sequence+10 where tabid=47;
update ld_relatedlists set sequence=0 where tabid=48 and label='ProjectProgress';
update ld_relatedlists set sequence=1 where tabid=48 and label='ContactRecords';
update ld_relatedlists set sequence=2 where tabid=48 and label='Attachment';
update ld_relatedlists set sequence=3 where tabid=48 and label='Documents';
set @i=0;
update ld_relatedlists set sequence=(@i:=@i+1) where tabid=48 order by sequence;
delimiter;

select tabid into @tabid from ld_tab where `name`='ProjectProgress';
update ld_quickactions set sequence=sequence+10 where tabid=47;
update ld_quickactions set sequence=1 where tabid=47 and related_tabid=@tabid;
set @i=0;
update ld_quickactions set sequence=(@i:=@i+1) where tabid=47 order by sequence;
delimiter;

select max(sequence) into @seq from ld_field where tabid=47 and block=106;
update ld_field set sequence=@seq+1,block=106 where tabid=47 and columnname='createdtime';
update ld_field set sequence=@seq+2,block=106 where tabid=47 and columnname='modifiedby';
update ld_field set sequence=@seq+3,block=106 where tabid=47 and columnname='modifiedtime';
set @i=0;
update ld_field set sequence=(@i:=@i+1) where tabid=47 and block=106 order by sequence;
delimiter;

select blockid into @blockid from ld_blocks where blocklabel='LBL_BUDGET_SCHEDULE_INFO' and tabid=47;
update ld_field set sequence=sequence+50 where tabid=47 and block=@blockid;
update ld_field set presence=1 where tabid=47 and columnname='projecttaskhours';
update ld_field set displaytype=2 where tabid=47 and columnname in ('hascost','hastime');
update ld_field set sequence=1 where tabid=47 and block=@blockid and columnname='projecttaskstatus';
update ld_field set sequence=2 where tabid=47 and block=@blockid and columnname='projecttaskpriority';
update ld_field set sequence=3 where tabid=47 and block=@blockid and columnname='startdate';
update ld_field set sequence=4 where tabid=47 and block=@blockid and columnname='enddate';
update ld_field set sequence=5 where tabid=47 and block=@blockid and columnname='costbudget';
update ld_field set sequence=6 where tabid=47 and block=@blockid and columnname='timebudget';
update ld_field set sequence=7 where tabid=47 and block=@blockid and columnname='projecttaskprogress';
update ld_field set sequence=8 where tabid=47 and block=@blockid and columnname='actualenddate';
update ld_field set sequence=9 where tabid=47 and block=@blockid and columnname='hascost';
update ld_field set sequence=10 where tabid=47 and block=@blockid and columnname='hastime';
update ld_field set sequence=11 where tabid=47 and block=@blockid and columnname='projecttaskhours';
set @i=0;
update ld_field set sequence=(@i:=@i+1) where tabid=47 and block=@blockid order by sequence;
delimiter;

select tabid into @tabid from ld_tab where `name`='ProjectProgress';
delete from ld_relatedlists where label in ('Project','ProjectTask') and tabid=tabid;
delete from ld_quickactions where tabid=@tabid and related_tabid in (47,48);
update ld_relatedlists set sequence=sequence+5 where tabid=@tabid;
update ld_relatedlists set sequence=1 where tabid=@tabid and label='Attachment';
update ld_relatedlists set sequence=2 where tabid=@tabid and label='Documents';
set @i=0;
update ld_relatedlists set sequence=(@i:=@i+1) where tabid=@tabid order by sequence;
delimiter;

select tabid into @tabid from ld_tab where `name`='ProjectProgress';
update ld_field set uitype=241 where tabid=@tabid and columnname='projecttaskid';
delimiter;
-- 2015-11-16

insert into ld_systems_deploy(deploy_value,deploy_type,description,setype,sequence)
select 0,85,'未出库订单是否允许退货 1：是，0：否','','138' from dual 
where not exists (select 1 from ld_systems_deploy where deploy_type=85);
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) 
select 'zh','Directreturnofcontract','未出库订单是否允许退货','fixedstr' from dual 
where not EXISTS(select 1 from ld_desk where languagetype='zh' and labelbol='Directreturnofcontract' and Labeltype='fixedstr');

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) 
select 'en','Directreturnofcontract','Do not allowed to return the in storaged salesorder','fixedstr' 
from dual where not EXISTS(select 1 from ld_desk  where languagetype='en' and labelbol='Directreturnofcontract' and Labeltype='fixedstr');
delimiter;

select tabid into @tabid from ld_tab where `name` = 'Rate';
update ld_field set uitype = 111 where tabid = @tabid and fieldname = 'strrole_id';

call AddColumn('ld_rate','selecttype','varchar','200',NULL);
call AddColumn('ld_rate','selectvalue','varchar','200',NULL);
delimiter;

insert into ld_desk(languagetype,fieldlabel,labelbol,labeltype)
select 'zh','适用范围','applicablescope','jspop' 
from dual where not exists(select 1 from ld_desk where languagetype = 'zh' and labelbol = 'applicablescope' and labeltype = 'jspop');
delimiter;

insert into ld_desk(languagetype,fieldlabel,labelbol,labeltype)
select 'en','Applicablescope','applicablescope','jspop' 
from dual where not exists(select 1 from ld_desk where languagetype = 'en' and labelbol = 'applicablescope' and labeltype = 'jspop');
delimiter;

update ld_field set presence = 1 where uitype = 170 and fieldname = 'servicegroup';
delimiter;
-- 2015-11-17

update ld_field set presence = 1 where uitype = 170 and fieldname = 'servicegroup';
delimiter;

update ld_usereportcolumns set `columns`='ld_sendpayment:Actualdate:Actualdate:SendPayment_Actualdate:D',
	realcolumns='ld_sendpayment:Actualdate:Actualdate:SendPayment_实际付款时间:D'
where  `columns` like '%ld_sendpayment:Actualdate:Actualdate:SendPayment%';
delimiter;

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

update ld_field set searchfieldtype=0 where tabid=47 and columnname='projecttaskname';
update ld_field set searchfieldtype=0 where tabid=47 and columnname='projecttask_no';
update ld_field set searchfieldtype=0 where tabid=47 and columnname='accountid';
update ld_field set searchfieldtype=0 where tabid=47 and columnname='projectid';

update ld_field set typeofdata='I~O' where tabid=47 and columnname='accountid';
update ld_field set typeofdata='D~O~OTH~GE~startdate~startdate' where tabid=47 and columnname='actualenddate';

select tabid into @tabid from ld_tab where `name`='ProjectProgress';
select blockid into @blockid from ld_blocks where tabid=@tabid and blocklabel='LBL_PROJECTPROGRESS_INFO';

update ld_field set sequence=sequence+50 where tabid=@tabid and block=@blockid;
update ld_field set sequence=1 where tabid=@tabid and columnname='projectid';
update ld_field set sequence=2 where tabid=@tabid and columnname='projectprogress_no';
update ld_field set sequence=3 where tabid=@tabid and columnname='projecttaskid';
update ld_field set sequence=4 where tabid=@tabid and columnname='smownerid';
update ld_field set sequence=5 where tabid=@tabid and columnname='startdate';
update ld_field set sequence=6 where tabid=@tabid and columnname='enddate';
update ld_field set sequence=7 where tabid=@tabid and columnname='timecost';
update ld_field set sequence=8 where tabid=@tabid and columnname='totalcost';

update ld_field set quickcreate=1,quickcreatesequence=100 where tabid=@tabid;
update ld_field set quickcreate=0,quickcreatesequence=1 where tabid=@tabid and columnname='projectid';
update ld_field set quickcreate=0,quickcreatesequence=2 where tabid=@tabid and columnname='projecttaskid';
update ld_field set quickcreate=0,quickcreatesequence=3 where tabid=@tabid and columnname='startdate';
update ld_field set quickcreate=0,quickcreatesequence=4 where tabid=@tabid and columnname='enddate';
update ld_field set quickcreate=0,quickcreatesequence=5 where tabid=@tabid and columnname='timecost';
update ld_field set quickcreate=0,quickcreatesequence=6 where tabid=@tabid and columnname='totalcost';
update ld_field set quickcreate=0,quickcreatesequence=7 where tabid=@tabid and columnname='smownerid';

set @i=0;
update ld_field set sequence=(@i:=@i+1) where tabid=@tabid and block=@blockid order by sequence;
delimiter;

select tabsequence into @seq from ld_tab where `name`='ProjectTask';
update ld_tab set tabsequence=@seq+1 where `name`='ProjectProgress';
update ld_tab set tabsequence=@seq+2 where `name`='ProjectMilestone';

set @tabid=47;
update ld_field set quickcreate=1,quickcreatesequence=100 where tabid=@tabid;
update ld_field set quickcreate=0,quickcreatesequence=1 where tabid=@tabid and columnname='projecttaskname';
update ld_field set quickcreate=0,quickcreatesequence=2 where tabid=@tabid and columnname='smownerid';
update ld_field set quickcreate=0,quickcreatesequence=3 where tabid=@tabid and columnname='accountid';
update ld_field set quickcreate=0,quickcreatesequence=4 where tabid=@tabid and columnname='contactid';
update ld_field set quickcreate=0,quickcreatesequence=5 where tabid=@tabid and columnname='projectid';
update ld_field set quickcreate=0,quickcreatesequence=6 where tabid=@tabid and columnname='projecttasktype';
update ld_field set quickcreate=0,quickcreatesequence=7 where tabid=@tabid and columnname='costbudget';
update ld_field set quickcreate=0,quickcreatesequence=8 where tabid=@tabid and columnname='timebudget';
delimiter;

set @tabid=48;
select tabid into @tabid1 from ld_tab where `name`='ProjectProgress';
select sequence into @seq from ld_relatedlists where tabid=@tabid and label='ProjectMilestone';
update ld_relatedlists set sequence=sequence+10 where tabid=@tabid and sequence>=@seq;

delete from ld_relatedlists where relation_id=0;
select max(relation_id) into @relation_id from ld_relatedlists;
insert into ld_relatedlists(relation_id,tabid,related_tabid,`name`,sequence,label,presence,actions,mobile_presence,mobile_sequence)
select @relation_id+1,@tabid,47,'get_dependents_list',@seq,'ProjectTask',0,'ADD,SELECT',1,1 from dual 
where not exists (select 1 from ld_relatedlists where tabid=@tabid and label='ProjectTask' and `name`='get_dependents_list');

select max(relation_id) into @relation_id from ld_relatedlists;
insert into ld_relatedlists(relation_id,tabid,related_tabid,`name`,sequence,label,presence,actions,mobile_presence,mobile_sequence)
select @relation_id+1,@tabid,@tabid1,'get_dependents_list',@seq+1,'ProjectProgress',0,'ADD,SELECT',1,1 from dual 
where not exists (select 1 from ld_relatedlists where tabid=@tabid and label='ProjectProgress' and `name`='get_dependents_list');

update ld_relatedlists_seq set id=(select max(relation_id) from ld_relatedlists);

set @i=0;
update ld_relatedlists set sequence=(@i:=@i+1),mobile_sequence=sequence where tabid=@tabid order by sequence;
delimiter;

update ld_relatedlists set actions='ADD' where label in ('ProjectMilestone','ProjectProgress');

insert into ld_desk (languagetype,labelbol,fieldlabel,labeltype)
select 'zh','HIGHSEASREACHEDCREATE','您拥有的公海客户数量已经达到上限，创建失败！','jspop' from dual 
where not EXISTS(select 1 from ld_desk where LANGUAGEtype='zh' and labelbol='HIGHSEASREACHEDCREATE' and labeltype='jspop');

insert into ld_desk (languagetype,labelbol,fieldlabel,labeltype)
select 'en','HIGHSEASREACHEDCREATE','The number of customers of the high seas you have have reached the limit, creating failed','jspop' from dual 
where not EXISTS(select 1 from ld_desk where LANGUAGEtype='en' and labelbol='HIGHSEASREACHEDCREATE' and labeltype='jspop');
delimiter;
-- 2015-11-18

update ld_cvcolumnlist set columnname='ld_notes:filename:filename:Documents_File:V' where columnname like '%ld_notes:filename:filename:Notes%';
update ld_cvcolumnlist set columnname='ld_notes:notes_title:notes_title:Documents_Title:V' where columnname like '%ld_notes:notes_title:notes_title:Notes%';
update ld_cvcolumnlist set columnname='ld_notes:note_no:note_no:Documents_Note:V' where columnname like '%ld_notes:note_no:note_no:Notes%';
update ld_cvcolumnlist set columnname='ld_notes:smownerid:assigned_user_id:Documents_Assigned:V' where columnname like '%ld_notes:smownerid:assigned_user_id:Notes%';
delimiter;
-- 2015-11-19

update ld_tab set presence=1 where `name`='Rate';

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

update ld_version set old_version='V6.1.7' ,current_version='V6.1.7' ,remark='V6.1.7-20151119';
delimiter;