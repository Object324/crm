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

update ld_desk set fieldlabel='设置全部普通成员可编辑的字段' where labelbol='ALLOWEDITUSERFIELD' and labeltype='fixedstr' and languagetype='zh';
update ld_desk set fieldlabel='Set the editable fields for all common members' where labelbol='ALLOWEDITUSERFIELD' and labeltype='fixedstr' and languagetype='en';
delimiter;

update ld_desk set fieldlabel='设置工作汇报提交期限' where labelbol='LBL_REMIND_SET_DESCRIPTION' and labeltype='fixedstr' and languagetype='zh';
update ld_desk set fieldlabel='Set deadline for submission of work report' where labelbol='LBL_REMIND_SET_DESCRIPTION' and labeltype='fixedstr' and languagetype='en';
delimiter;

insert into ld_desk (languagetype,labelbol,fieldlabel,labeltype)
  select 'zh','IMPORTENTRY','导入单据分录','fixedstr' from dual
  where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='IMPORTENTRY' and Labeltype='fixedstr');
insert into ld_desk (languagetype,labelbol,fieldlabel,labeltype)
  select 'en','IMPORTENTRY','Import document entry','fixedstr' from dual
  where not exists(select 1 from ld_desk where languagetype='en' and labelbol='IMPORTENTRY' and Labeltype='fixedstr');
 delimiter;

insert into ld_desk (languagetype,labelbol,fieldlabel,labeltype)
  select 'zh','IMPORTRECORDTIPPRODUCT','共%d条记录，成功导入%d条记录，失败%d条记录。','fixedstr' from dual
  where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='IMPORTRECORDTIPPRODUCT' and Labeltype='fixedstr');
insert into ld_desk (languagetype,labelbol,fieldlabel,labeltype)
  select 'en','IMPORTRECORDTIPPRODUCT','A total of %d records,  successfully imported %d records, failed %d records.','fixedstr' from dual
  where not exists(select 1 from ld_desk where languagetype='en' and labelbol='IMPORTRECORDTIPPRODUCT' and Labeltype='fixedstr');
insert into ld_desk (languagetype,labelbol,fieldlabel,labeltype)
  select 'zh','DOCUMENTENTRY','单据分录','fixedstr' from dual
  where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='DOCUMENTENTRY' and Labeltype='fixedstr');
insert into ld_desk (languagetype,labelbol,fieldlabel,labeltype)
  select 'en','DOCUMENTENTRY','Document entry','fixedstr' from dual
  where not exists(select 1 from ld_desk where languagetype='en' and labelbol='DOCUMENTENTRY' and Labeltype='fixedstr');
call AddColumn('ld_wx_config','para_content','text',null ,null );
delimiter;

alter table `ld_wx_config` change `para_content` `para_content` text DEFAULT null COMMENT '参数Json集合' AFTER `description`;
delimiter;

insert into ld_desk (languagetype,labelbol,fieldlabel,labeltype)
  select 'zh','H5MICAPP','H5微应用','fixedstr' from dual
  where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='H5MICAPP' and Labeltype='fixedstr');
insert into ld_desk (languagetype,labelbol,fieldlabel,labeltype)
  select 'en','H5MICAPP','H5 Micro Application','fixedstr' from dual
  where not exists(select 1 from ld_desk where languagetype='en' and labelbol='H5MICAPP' and Labeltype='fixedstr');
insert into ld_desk (languagetype,labelbol,fieldlabel,labeltype)
  select 'zh','PCHOMEADDRESS','PC端首页地址','fixedstr' from dual
  where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='PCHOMEADDRESS' and Labeltype='fixedstr');
insert into ld_desk (languagetype,labelbol,fieldlabel,labeltype)
  select 'en','PCHOMEADDRESS','PC home address','fixedstr' from dual
  where not exists(select 1 from ld_desk where languagetype='en' and labelbol='PCHOMEADDRESS' and Labeltype='fixedstr');
 delimiter;
-- 2019-12-17

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','BLOG','微博','fixedstr' from dual 
where not EXISTS(select 1 from ld_desk where languagetype='zh' and labelbol='BLOG' and Labeltype='fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','BLOG','Blog','fixedstr' from dual 
where not EXISTS(select 1 from ld_desk where languagetype='en' and labelbol='BLOG' and Labeltype='fixedstr');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','BLOG','微博','jspop' from dual 
where not EXISTS(select 1 from ld_desk where languagetype='zh' and labelbol='BLOG' and Labeltype='jspop');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','BLOG','Blog','jspop' from dual 
where not EXISTS(select 1 from ld_desk where languagetype='en' and labelbol='BLOG' and Labeltype='jspop');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','JOURNAL','日志','fixedstr' from dual 
where not EXISTS(select 1 from ld_desk where languagetype='zh' and labelbol='JOURNAL' and Labeltype='fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','JOURNAL','Journal','fixedstr' from dual 
where not EXISTS(select 1 from ld_desk where languagetype='en' and labelbol='JOURNAL' and Labeltype='fixedstr');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','JOURNAL','日志','jspop' from dual 
where not EXISTS(select 1 from ld_desk where languagetype='zh' and labelbol='JOURNAL' and Labeltype='jspop');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','JOURNAL','Journal','jspop' from dual 
where not EXISTS(select 1 from ld_desk where languagetype='en' and labelbol='JOURNAL' and Labeltype='jspop');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','WEEKPLAN','周计划','fixedstr' from dual 
where not EXISTS(select 1 from ld_desk where languagetype='zh' and labelbol='WEEKPLAN' and Labeltype='fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','WEEKPLAN','Week plan','fixedstr' from dual 
where not EXISTS(select 1 from ld_desk where languagetype='en' and labelbol='WEEKPLAN' and Labeltype='fixedstr');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','WEEKPLAN','周计划','jspop' from dual 
where not EXISTS(select 1 from ld_desk where languagetype='zh' and labelbol='WEEKPLAN' and Labeltype='jspop');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','WEEKPLAN','Week plan','jspop' from dual 
where not EXISTS(select 1 from ld_desk where languagetype='en' and labelbol='WEEKPLAN' and Labeltype='jspop');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','MONTHPLAN','月计划','fixedstr' from dual 
where not EXISTS(select 1 from ld_desk where languagetype='zh' and labelbol='MONTHPLAN' and Labeltype='fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','MONTHPLAN','Month plan','fixedstr' from dual 
where not EXISTS(select 1 from ld_desk where languagetype='en' and labelbol='MONTHPLAN' and Labeltype='fixedstr');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','MONTHPLAN','月计划','jspop' from dual 
where not EXISTS(select 1 from ld_desk where languagetype='zh' and labelbol='MONTHPLAN' and Labeltype='jspop');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','MONTHPLAN','Month plan','jspop' from dual 
where not EXISTS(select 1 from ld_desk where languagetype='en' and labelbol='MONTHPLAN' and Labeltype='jspop');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','TASK','任务','fixedstr' from dual 
where not EXISTS(select 1 from ld_desk where languagetype='zh' and labelbol='TASK' and Labeltype='fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','TASK','Task','fixedstr' from dual 
where not EXISTS(select 1 from ld_desk where languagetype='en' and labelbol='TASK' and Labeltype='fixedstr');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','TASK','任务','jspop' from dual 
where not EXISTS(select 1 from ld_desk where languagetype='zh' and labelbol='TASK' and Labeltype='jspop');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','TASK','Task','jspop' from dual 
where not EXISTS(select 1 from ld_desk where languagetype='en' and labelbol='TASK' and Labeltype='jspop');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','RELEASENEW','发布','fixedstr' from dual 
where not EXISTS(select 1 from ld_desk where languagetype='zh' and labelbol='RELEASENEW' and Labeltype='fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','RELEASENEW','Release','fixedstr' from dual 
where not EXISTS(select 1 from ld_desk where languagetype='en' and labelbol='RELEASENEW' and Labeltype='fixedstr');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','RELEASENEW','发布','jspop' from dual 
where not EXISTS(select 1 from ld_desk where languagetype='zh' and labelbol='RELEASENEW' and Labeltype='jspop');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','RELEASENEW','Release','jspop' from dual 
where not EXISTS(select 1 from ld_desk where languagetype='en' and labelbol='RELEASENEW' and Labeltype='jspop');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','IINITIATED','我发起的','fixedstr' from dual 
where not EXISTS(select 1 from ld_desk where languagetype='zh' and labelbol='IINITIATED' and Labeltype='fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','IINITIATED','I initiated','fixedstr' from dual 
where not EXISTS(select 1 from ld_desk where languagetype='en' and labelbol='IINITIATED' and Labeltype='fixedstr');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','IINITIATED','我发起的','jspop' from dual 
where not EXISTS(select 1 from ld_desk where languagetype='zh' and labelbol='IINITIATED' and Labeltype='jspop');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','IINITIATED','I initiated','jspop' from dual 
where not EXISTS(select 1 from ld_desk where languagetype='en' and labelbol='IINITIATED' and Labeltype='jspop');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','IRELATED','我相关的','fixedstr' from dual 
where not EXISTS(select 1 from ld_desk where languagetype='zh' and labelbol='IRELATED' and Labeltype='fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','IRELATED','I related','fixedstr' from dual 
where not EXISTS(select 1 from ld_desk where languagetype='en' and labelbol='IRELATED' and Labeltype='fixedstr');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','IRELATED','我相关的','jspop' from dual 
where not EXISTS(select 1 from ld_desk where languagetype='zh' and labelbol='IRELATED' and Labeltype='jspop');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','IRELATED','I related','jspop' from dual 
where not EXISTS(select 1 from ld_desk where languagetype='en' and labelbol='IRELATED' and Labeltype='jspop');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','UNREVIEWED','待点评的','fixedstr' from dual 
where not EXISTS(select 1 from ld_desk where languagetype='zh' and labelbol='UNREVIEWED' and Labeltype='fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','UNREVIEWED','Unreviewed','fixedstr' from dual 
where not EXISTS(select 1 from ld_desk where languagetype='en' and labelbol='UNREVIEWED' and Labeltype='fixedstr');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','UNREVIEWED','待点评的','jspop' from dual 
where not EXISTS(select 1 from ld_desk where languagetype='zh' and labelbol='UNREVIEWED' and Labeltype='jspop');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','UNREVIEWED','Unreviewed','jspop' from dual 
where not EXISTS(select 1 from ld_desk where languagetype='en' and labelbol='UNREVIEWED' and Labeltype='jspop');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','REVIEWED','已点评的','fixedstr' from dual 
where not EXISTS(select 1 from ld_desk where languagetype='zh' and labelbol='REVIEWED' and Labeltype='fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','REVIEWED','Reviewed','fixedstr' from dual 
where not EXISTS(select 1 from ld_desk where languagetype='en' and labelbol='REVIEWED' and Labeltype='fixedstr');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','REVIEWED','已点评的','jspop' from dual 
where not EXISTS(select 1 from ld_desk where languagetype='zh' and labelbol='REVIEWED' and Labeltype='jspop');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','REVIEWED','Reviewed','jspop' from dual 
where not EXISTS(select 1 from ld_desk where languagetype='en' and labelbol='REVIEWED' and Labeltype='jspop');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','UNEXECUTED','待执行的','fixedstr' from dual 
where not EXISTS(select 1 from ld_desk where languagetype='zh' and labelbol='UNEXECUTED' and Labeltype='fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','UNEXECUTED','Unexecuted','fixedstr' from dual 
where not EXISTS(select 1 from ld_desk where languagetype='en' and labelbol='UNEXECUTED' and Labeltype='fixedstr');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','UNEXECUTED','待执行的','jspop' from dual 
where not EXISTS(select 1 from ld_desk where languagetype='zh' and labelbol='UNEXECUTED' and Labeltype='jspop');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','UNEXECUTED','Unexecuted','jspop' from dual 
where not EXISTS(select 1 from ld_desk where languagetype='en' and labelbol='UNEXECUTED' and Labeltype='jspop');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','EXECUTEDNEW','已执行的','fixedstr' from dual 
where not EXISTS(select 1 from ld_desk where languagetype='zh' and labelbol='EXECUTEDNEW' and Labeltype='fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','EXECUTEDNEW','Executed','fixedstr' from dual 
where not EXISTS(select 1 from ld_desk where languagetype='en' and labelbol='EXECUTEDNEW' and Labeltype='fixedstr');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','EXECUTEDNEW','已执行的','jspop' from dual 
where not EXISTS(select 1 from ld_desk where languagetype='zh' and labelbol='EXECUTEDNEW' and Labeltype='jspop');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','EXECUTEDNEW','Executed','jspop' from dual 
where not EXISTS(select 1 from ld_desk where languagetype='en' and labelbol='EXECUTEDNEW' and Labeltype='jspop');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','IRECEIVED','我收到的','fixedstr' from dual 
where not EXISTS(select 1 from ld_desk where languagetype='zh' and labelbol='IRECEIVED' and Labeltype='fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','IRECEIVED','I received','fixedstr' from dual 
where not EXISTS(select 1 from ld_desk where languagetype='en' and labelbol='IRECEIVED' and Labeltype='fixedstr');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','IRECEIVED','我收到的','jspop' from dual 
where not EXISTS(select 1 from ld_desk where languagetype='zh' and labelbol='IRECEIVED' and Labeltype='jspop');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','IRECEIVED','I received','jspop' from dual 
where not EXISTS(select 1 from ld_desk where languagetype='en' and labelbol='IRECEIVED' and Labeltype='jspop');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','@MY','@我的','fixedstr' from dual 
where not EXISTS(select 1 from ld_desk where languagetype='zh' and labelbol='@MY' and Labeltype='fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','@MY','@ my','fixedstr' from dual 
where not EXISTS(select 1 from ld_desk where languagetype='en' and labelbol='@MY' and Labeltype='fixedstr');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','MYREPLY','我的回复','fixedstr' from dual 
where not EXISTS(select 1 from ld_desk where languagetype='zh' and labelbol='MYREPLY' and Labeltype='fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','MYREPLY','My reply','fixedstr' from dual 
where not EXISTS(select 1 from ld_desk where languagetype='en' and labelbol='MYREPLY' and Labeltype='fixedstr');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','MYPRAISE','我的赞','fixedstr' from dual 
where not EXISTS(select 1 from ld_desk where languagetype='zh' and labelbol='MYPRAISE' and Labeltype='fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','MYPRAISE','My praise','fixedstr' from dual 
where not EXISTS(select 1 from ld_desk where languagetype='en' and labelbol='MYPRAISE' and Labeltype='fixedstr');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','MYWORKBENCH','我的工作台','fixedstr' from dual 
where not EXISTS(select 1 from ld_desk where languagetype='zh' and labelbol='MYWORKBENCH' and Labeltype='fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','MYWORKBENCH','My workbench','fixedstr' from dual 
where not EXISTS(select 1 from ld_desk where languagetype='en' and labelbol='MYWORKBENCH' and Labeltype='fixedstr');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','MYNEWS','我的消息','fixedstr' from dual 
where not EXISTS(select 1 from ld_desk where languagetype='zh' and labelbol='MYNEWS' and Labeltype='fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','MYNEWS','My news','fixedstr' from dual 
where not EXISTS(select 1 from ld_desk where languagetype='en' and labelbol='MYNEWS' and Labeltype='fixedstr');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','PICTURE','图片','fixedstr' from dual 
where not EXISTS(select 1 from ld_desk where languagetype='zh' and labelbol='PICTURE' and Labeltype='fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','PICTURE','Picture','fixedstr' from dual 
where not EXISTS(select 1 from ld_desk where languagetype='en' and labelbol='PICTURE' and Labeltype='fixedstr');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','SEARCHNEW','搜索','fixedstr' from dual 
where not EXISTS(select 1 from ld_desk where languagetype='zh' and labelbol='SEARCHNEW' and Labeltype='fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','SEARCHNEW','search','fixedstr' from dual 
where not EXISTS(select 1 from ld_desk where languagetype='en' and labelbol='SEARCHNEW' and Labeltype='fixedstr');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','SELECTCCRANGE','选择抄送范围','fixedstr' from dual 
where not EXISTS(select 1 from ld_desk where languagetype='zh' and labelbol='SELECTCCRANGE' and Labeltype='fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','SELECTCCRANGE','Select CC range','fixedstr' from dual 
where not EXISTS(select 1 from ld_desk where languagetype='en' and labelbol='SELECTCCRANGE' and Labeltype='fixedstr');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','ADDPICTURES','添加图片（多张）','fixedstr' from dual 
where not EXISTS(select 1 from ld_desk where languagetype='zh' and labelbol='ADDPICTURES' and Labeltype='fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','ADDPICTURES','Add picture (multiple)','fixedstr' from dual 
where not EXISTS(select 1 from ld_desk where languagetype='en' and labelbol='ADDPICTURES' and Labeltype='fixedstr');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','ADDATTACHMENTS','添加附件（多个）','fixedstr' from dual 
where not EXISTS(select 1 from ld_desk where languagetype='zh' and labelbol='ADDATTACHMENTS' and Labeltype='fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','ADDATTACHMENTS','Add attachments (multiple)','fixedstr' from dual 
where not EXISTS(select 1 from ld_desk where languagetype='en' and labelbol='ADDATTACHMENTS' and Labeltype='fixedstr');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','ADDCOLLEAGUES','添加同事','fixedstr' from dual 
where not EXISTS(select 1 from ld_desk where languagetype='zh' and labelbol='ADDCOLLEAGUES' and Labeltype='fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','ADDCOLLEAGUES','Add colleagues','fixedstr' from dual 
where not EXISTS(select 1 from ld_desk where languagetype='en' and labelbol='ADDCOLLEAGUES' and Labeltype='fixedstr');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','ADDEXPRESSION','添加表情','fixedstr' from dual 
where not EXISTS(select 1 from ld_desk where languagetype='zh' and labelbol='ADDEXPRESSION' and Labeltype='fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','ADDEXPRESSION','Add expression','fixedstr' from dual 
where not EXISTS(select 1 from ld_desk where languagetype='en' and labelbol='ADDEXPRESSION' and Labeltype='fixedstr');
delimiter;
-- 2019-12-19

insert into ld_setscoperhigher(userid,scopeauthority,modulename,viewothers,editothers,delothers,viewselfbills)
select userid,scopeauthority,'UnAssignedAccounts',viewothers,editothers,delothers,viewselfbills from ld_setscoperhigher  where modulename='Accounts'
and  not EXISTS (select userid from ld_setscoperhigher where modulename='UnAssignedAccounts');

insert into ld_scoperhigher(userid,viewid,scopeauthority,modulename)
select userid,viewid,scopeauthority,'UnAssignedAccounts' from ld_scoperhigher where  modulename='Accounts'
and  not EXISTS (select userid from ld_scoperhigher where modulename='UnAssignedAccounts');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
  select 'zh','ORDEROUTNOALLOWRETURN','当前系统参数设置未出库订单不允许退货，该{$SalesOrder.SalesOrder}还未出库，不允许办理退货！','fixedstr'
from dual where not EXISTS(select 1 from ld_desk where languagetype='zh' and labelbol='ORDEROUTNOALLOWRETURN' and Labeltype='fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
  select 'en','ORDEROUTNOALLOWRETURN','The {$SalesOrder.SalesOrder} not yet out of the library, do not allow for return!','fixedstr'
from dual where not EXISTS(select 1 from ld_desk  where languagetype='en' and labelbol='ORDEROUTNOALLOWRETURN' and Labeltype='fixedstr');

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
  select 'zh','OUTBOUNDCOUNTEQUALZERO','该单据已出库数量为零，请审核出库单！','fixedstr'
  from dual where not EXISTS(select 1 from ld_desk where languagetype='zh' and labelbol='OUTBOUNDCOUNTEQUALZERO' and Labeltype='fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
  select 'en','OUTBOUNDCOUNTEQUALZERO','The bill has been shipped out to zero, please check the OutboundOrder！','fixedstr'
  from dual where not EXISTS(select 1 from ld_desk  where languagetype='en' and labelbol='OUTBOUNDCOUNTEQUALZERO' and Labeltype='fixedstr');

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
  select 'zh','ORDERFULLYOUTNOALLOWRETURN','该单据已出库产品已经创建{$SalesBack.SalesBack}，不允许再办理退货！','fixedstr'
  from dual where not EXISTS(select 1 from ld_desk where languagetype='zh' and labelbol='ORDERFULLYOUTNOALLOWRETURN' and Labeltype='fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
  select 'en','ORDERFULLYOUTNOALLOWRETURN','The document has been out of the library and the product has been created {$SalesBack.SalesBack} and no return is allowed!','fixedstr'
  from dual where not EXISTS(select 1 from ld_desk  where languagetype='en' and labelbol='ORDERFULLYOUTNOALLOWRETURN' and Labeltype='fixedstr');

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
  select 'zh','PURCHASEORDEROUTNOALLOWRETURN','当前系统参数设置未入库订单不允许退货，该{$PurchaseOrder.PurchaseOrder}还未入库，不允许办理退货！，不允许再办理退货！','fixedstr'
  from dual where not EXISTS(select 1 from ld_desk where languagetype='zh' and labelbol='PURCHASEORDEROUTNOALLOWRETURN' and Labeltype='fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
  select 'en','PURCHASEORDEROUTNOALLOWRETURN','The {$PurchaseOrder.PurchaseOrder} not yet out of the library, do not allow for return!','fixedstr'
  from dual where not EXISTS(select 1 from ld_desk  where languagetype='en' and labelbol='PURCHASEORDEROUTNOALLOWRETURN' and Labeltype='fixedstr');

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
  select 'zh','THISDOCUMENTHASBEENSHIPPEDTOZERO','该单据已入库数量为零，请审核{$Stock.Stock}！','fixedstr'
  from dual where not EXISTS(select 1 from ld_desk where languagetype='zh' and labelbol='THISDOCUMENTHASBEENSHIPPEDTOZERO' and Labeltype='fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
  select 'en','THISDOCUMENTHASBEENSHIPPEDTOZERO','This document has been shipped to zero, please check {$Stock.Stock}','fixedstr'
  from dual where not EXISTS(select 1 from ld_desk  where languagetype='en' and labelbol='THISDOCUMENTHASBEENSHIPPEDTOZERO' and Labeltype='fixedstr');

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
  select 'zh','PURCHASEORDERFULLYOUTNOALLOWRETURN','该{$PurchaseOrder.PurchaseOrder}已全部退货，不允许办理退货。','fixedstr'
  from dual where not EXISTS(select 1 from ld_desk where languagetype='zh' and labelbol='PURCHASEORDERFULLYOUTNOALLOWRETURN' and Labeltype='fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
  select 'en','PURCHASEORDERFULLYOUTNOALLOWRETURN','The PurchaseOrder has been fully returned orders, handle returns are not allowed.','fixedstr'
  from dual where not EXISTS(select 1 from ld_desk  where languagetype='en' and labelbol='PURCHASEORDERFULLYOUTNOALLOWRETURN' and Labeltype='fixedstr');
delimiter;
-- 2019-12-26

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','AssessmentMethod','考核方法','fixedstr' from dual 
where not EXISTS(select 1 from ld_desk where labelbol='AssessmentMethod' and languagetype='zh' and labeltype='fixedstr');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','Assessment Method','考核方法','fixedstr' from dual 
where not EXISTS(select 1 from ld_desk where labelbol='AssessmentMethod' and languagetype='en' and labeltype='fixedstr');
delimiter;


insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','ByCity','按{$Accounts.bill_city}','fixedstr' from dual 
where not EXISTS(select 1 from ld_desk where labelbol='ByCity' and languagetype='zh' and labeltype='fixedstr');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','ByCity','By {$Accounts.bill_city}','fixedstr' from dual 
where not EXISTS(select 1 from ld_desk where labelbol='ByCity' and languagetype='en' and labeltype='fixedstr');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','ByBillArea','按{$Accounts.bill_area}','fixedstr' from dual 
where not EXISTS(select 1 from ld_desk where labelbol='ByBillArea' and languagetype='zh' and labeltype='fixedstr');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','ByBillArea','By {$Accounts.bill_area}','fixedstr' from dual 
where not EXISTS(select 1 from ld_desk where labelbol='ByBillArea' and languagetype='en' and labeltype='fixedstr');
delimiter;

insert into ld_systems_deploy(deploy_value,deploy_type,description,setype,sequence,roottype,inputtype,presence,inputvalue)
select 'bill_city',207,'服务考核方法类型','',100000,4,'select',1 ,'' from dual 
where not exists(select 1 from ld_systems_deploy where deploy_type=207);
delimiter;

call AddColumn('ld_relatedlists','dynamicstatus','varchar',50 ,'no' );
delimiter;

update ld_relatedlists 
  inner join ld_tab on ld_tab.tabid=ld_relatedlists.related_tabid
set dynamicstatus='yes' where ld_tab.name in('Contacts','Potentials','Quotes','SalesOrder','Invoice','Emails','Documents','HelpDesk','Products',
'Campaigns','ServiceContracts','ContactRecords','PaymentPlan','CashBill','Expense','Attachment',
'OutboundOrder','SalesBack','CashBack','Accounts','Commission','CommunicationLog','Calendar','Project',
'MobileReport','DividendOrder','ServiceReturn','Reminds','BusinessApply','PurchaseOrder',
'Stock','Vendors')
and ld_relatedlists.tabid=6;
delimiter;
-- 2019-12-27

CALl AddColumn('ld_quotesdetail','haveordercount','decimal','25','');
delimiter;

alter table ld_quotesdetail modify column haveordercount decimal(25,8);
delimiter;

CALl AddColumn('ld_quotesdetail','balanceordercount','decimal','25','');
delimiter;

alter table ld_quotesdetail modify column balanceordercount decimal(25,8);
delimiter;

insert into ld_systems_deploy(deploy_value,deploy_type,description,setype,sequence,roottype,inputtype,presence,inputvalue)
select 1,209,'价格表是否启用审批流程1:否，0:是','PriceBooks',20,3,'select',0,'[{"value":"0","text":"YES"},{"value":"1","text":"NO"},{"sql":""}]' from dual 
where not exists(select 1 from ld_systems_deploy where deploy_type=209);
delimiter;


SET @modulename='PriceBooks';
SET @tabid=(SELECT tabid FROM ld_tab WHERE `name`=@modulename);
SET @relateid=(SELECT block FROM ld_field WHERE tabid=@tabid AND columnname='smownerid' LIMIT 1);
SET @maxseq=IFNULL((SELECT MAX(sequence) FROM ld_field WHERE tabid=@tabid AND block=@relateid),0);
SET @trantable='ld_field';
SET @tablename=(SELECT tablename FROM ld_field WHERE tabid=@tabid AND columnname='smownerid' LIMIT 1);
SET @columnname='approvestatus'; 
SET @fieldname='approvestatus'; 
SET @zh='审批状态'; 
SET @en='审批状态'; 
SET @uitype=1; 
SET @typeofdata='V~O';
SET @quickcreate=1;
SET @displaytype=2;
SET @bigtype='';
SET @datarang=NULL;
SET @maxrowsshow=0;

SET @maxid=(SELECT MAX(fieldid) FROM ld_field);

INSERT INTO ld_field(tabid,fieldid,columnname,tablename,generatedtype,uitype,fieldname,fieldlabel,readonly,presence,defaultvalue,maximumlength,sequence,block,displaytype,typeofdata,quickcreate,quickcreatesequence,info_type,masseditable,helpinfo,fieldonly,approve_demand,is_checkimportfield,bigtype,datarang,maxrowsshow)
SELECT @tabid,@maxid+1,@columnname,@tablename,1,@uitype,@fieldname,@zh,1,2,NULL,100,@maxseq+1,@relateid,@displaytype,@typeofdata,@quickcreate,NULL,NULL,1,NULL,0,1,0,@bigtype,@datarang,@maxrowsshow from dual 
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

SET @modulename='PriceBooks';
SET @tabid=(SELECT tabid FROM ld_tab WHERE `name`=@modulename);
SET @relateid=(SELECT block FROM ld_field WHERE tabid=@tabid AND columnname='smownerid' LIMIT 1);
SET @maxseq=IFNULL((SELECT MAX(sequence) FROM ld_field WHERE tabid=@tabid AND block=@relateid),0);
SET @trantable='ld_field';
SET @tablename=(SELECT tablename FROM ld_field WHERE tabid=@tabid AND columnname='smownerid' LIMIT 1);
SET @columnname='currentapprover'; 
SET @fieldname='currentapprover'; 
SET @zh='当前审批人'; 
SET @en='当前审批人'; 
SET @uitype=132; 
SET @typeofdata='V~O';
SET @quickcreate=1;
SET @displaytype=2;
SET @bigtype='';
SET @datarang=NULL;
SET @maxrowsshow=0;

SET @maxid=(SELECT MAX(fieldid) FROM ld_field);

INSERT INTO ld_field(tabid,fieldid,columnname,tablename,generatedtype,uitype,fieldname,fieldlabel,readonly,presence,defaultvalue,maximumlength,sequence,block,displaytype,typeofdata,quickcreate,quickcreatesequence,info_type,masseditable,helpinfo,fieldonly,approve_demand,is_checkimportfield,bigtype,datarang,maxrowsshow)
SELECT @tabid,@maxid+1,@columnname,@tablename,1,@uitype,@fieldname,@zh,1,2,NULL,100,@maxseq+1,@relateid,@displaytype,@typeofdata,@quickcreate,NULL,NULL,1,NULL,0,1,0,@bigtype,@datarang,@maxrowsshow from dual 
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



SET @modulename='PriceBooks';
SET @tabid=(SELECT tabid FROM ld_tab WHERE `name`=@modulename);
SET @relateid=(SELECT block FROM ld_field WHERE tabid=@tabid AND columnname='smownerid' LIMIT 1);
SET @maxseq=IFNULL((SELECT MAX(sequence) FROM ld_field WHERE tabid=@tabid AND block=@relateid),0);
SET @trantable='ld_field';
SET @tablename=(SELECT tablename FROM ld_field WHERE tabid=@tabid AND columnname='smownerid' LIMIT 1);
SET @columnname='approvetime'; 
SET @fieldname='approvetime'; 
SET @zh='最新审批时间'; 
SET @en='最新审批时间'; 
SET @uitype=70; 
SET @typeofdata='V~O';
SET @quickcreate=1;
SET @displaytype=2;
SET @bigtype='';
SET @datarang=NULL;
SET @maxrowsshow=0;

SET @maxid=(SELECT MAX(fieldid) FROM ld_field);

INSERT INTO ld_field(tabid,fieldid,columnname,tablename,generatedtype,uitype,fieldname,fieldlabel,readonly,presence,defaultvalue,maximumlength,sequence,block,displaytype,typeofdata,quickcreate,quickcreatesequence,info_type,masseditable,helpinfo,fieldonly,approve_demand,is_checkimportfield,bigtype,datarang,maxrowsshow)
SELECT @tabid,@maxid+1,@columnname,@tablename,1,@uitype,@fieldname,@zh,1,2,NULL,100,@maxseq+1,@relateid,@displaytype,@typeofdata,@quickcreate,NULL,NULL,1,NULL,0,1,0,@bigtype,@datarang,@maxrowsshow from dual 
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

SET @modulename='PriceBooks';
SET @tabid=(SELECT tabid FROM ld_tab WHERE `name`=@modulename);
SET @relateid=(SELECT block FROM ld_field WHERE tabid=@tabid AND columnname='smownerid' LIMIT 1);
SET @maxseq=IFNULL((SELECT MAX(sequence) FROM ld_field WHERE tabid=@tabid AND block=@relateid),0);
SET @trantable='ld_field';
SET @tablename=(SELECT tablename FROM ld_field WHERE tabid=@tabid AND columnname='smownerid' LIMIT 1);
SET @columnname='approveby'; 
SET @fieldname='approveby'; 
SET @zh='上一步审批人'; 
SET @en='上一步审批人'; 
SET @uitype=131; 
SET @typeofdata='V~O';
SET @quickcreate=1;
SET @displaytype=2;
SET @bigtype='';
SET @datarang=NULL;
SET @maxrowsshow=0;

SET @maxid=(SELECT MAX(fieldid) FROM ld_field);

INSERT INTO ld_field(tabid,fieldid,columnname,tablename,generatedtype,uitype,fieldname,fieldlabel,readonly,presence,defaultvalue,maximumlength,sequence,block,displaytype,typeofdata,quickcreate,quickcreatesequence,info_type,masseditable,helpinfo,fieldonly,approve_demand,is_checkimportfield,bigtype,datarang,maxrowsshow)
SELECT @tabid,@maxid+1,@columnname,@tablename,1,@uitype,@fieldname,@zh,1,2,NULL,100,@maxseq+1,@relateid,@displaytype,@typeofdata,@quickcreate,NULL,NULL,1,NULL,0,1,0,@bigtype,@datarang,@maxrowsshow from dual 
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



call fieldprofile("PriceBooks");
delimiter;

CALl AddColumn('ld_seattachmentsrel','attachmentcolumnname','varchar','50','');
delimiter;

update ld_seattachmentsrel 
LEFT JOIN ld_attachments on ld_attachments.attachmentsid = ld_seattachmentsrel.attachmentsid 
LEFT JOIN ld_crmentity on ld_crmentity.crmid = ld_seattachmentsrel.attachmentsid 
set attachmentcolumnname = 'imagename' where locate('Image',ld_crmentity.setype) 
and (attachmentcolumnname is NULL OR attachmentcolumnname = '');
delimiter;

update ld_seattachmentsrel LEFT JOIN ld_crmentity on ld_crmentity.crmid = ld_seattachmentsrel.crmid 
set attachmentcolumnname = case when (ld_crmentity.setype = 'Documents') then 'name' when (locate('Image',ld_crmentity.setype)) then 'imagename' else 'filename' end 
where (attachmentcolumnname is NULL OR attachmentcolumnname = '');
delimiter;

select sequence into @sequence from ld_systems_deploy where deploy_type=204;
insert into ld_systems_deploy(deploy_value,deploy_type,description,sequence,roottype,inputtype,presence,inputvalue)
  select 0,210,'设置移动端带分录的单据详情界面默认值显示',@sequence+1,8,'select',0,'[{"value":"0","text":"DETAIL"},{"value":"1","text":"details1"},{"sql":""}]'
  from dual where not exists(select 1 from ld_systems_deploy  where deploy_type=210);
set @i=@sequence;
update ld_systems_deploy set sequence=(@i:=@i+1) where roottype=8 and sequence>@sequence order by sequence asc;

select deploy_type into @relateid from ld_systems_deploy where deploy_type=210;
insert into ld_tranlabel(LANGUAGEtype,trantable,tabid,relateid,fieldlabel)
  select 'zh','ld_systems_deploy',@relateid,@relateid,'设置移动端带分录的单据详情界面默认值显示' from DUAL
  where not exists(select 1 from ld_tranlabel where tabid=@relateid and relateid=@relateid and trantable='ld_systems_deploy' and languagetype='zh');

insert into ld_tranlabel(LANGUAGEtype,trantable,tabid,relateid,fieldlabel)
  select 'en','ld_systems_deploy',@relateid,@relateid,
    'Set the default value of the document details interface with entries on the mobile end to display'
  from DUAL
  where not exists(select 1 from ld_tranlabel where tabid=@relateid and relateid=@relateid and trantable='ld_systems_deploy' and languagetype='en');
delimiter;


DROP PROCEDURE IF EXISTS `ldcrm_add_reminder`;
delimiter ||
CREATE  PROCEDURE `ldcrm_add_reminder`(
	tmp_content text,
	tmp_recieverid INT(19),
    tmp_reltab VARCHAR(100),
	tmp_related_to INT(19)
    
)
BEGIN
	
	SET @max_remindid=(SELECT MAX(crmid) FROM ld_crmentity);
	INSERT INTO ld_crmentity(crmid,setype)
	SELECT @max_remindid+1,'Reminds';		

	UPDATE ld_crmentity_seq SET id=(SELECT MAX(crmid) FROM ld_crmentity);
	
	INSERT INTO ld_reminds(remindsid,content,date_time,recieverid,status_rmd,related_to,reltab,is_del_send,is_del_rec,reminds_ruleid,smownerid,smcreatorid,modifiedby,createdtime,modifiedtime,description,deleted)
	SELECT @max_remindid+1,tmp_content,now(),tmp_recieverid,'未读',tmp_related_to,tmp_reltab,0,0,0,0,0,0,now(),now(),null,0;

end||
delimiter;
-- 2019-12-31

update ld_systems_deploy set deploy_value = 1,presence = 1 where deploy_type = 159;
delimiter;

UPDATE ld_tranlabel SET fieldlabel='派工单' WHERE trantable='ld_tab' AND tabid=47 AND languagetype='zh'
	AND NOT EXISTS (SELECT 1 FROM ld_projecttask) AND fieldlabel IN ('项目任务','项目计划');

UPDATE ld_tranlabel SET fieldlabel='Dispatch order' WHERE trantable='ld_tab' AND tabid=47 AND languagetype='en'
	AND NOT EXISTS (SELECT 1 FROM ld_projecttask);

SET @fieldid=(SELECT fieldid FROM ld_field WHERE tabid=47 AND columnname='projecttaskname' LIMIT 1);
SET @is_paigong=(SELECT 1 FROM ld_tranlabel WHERE tabid=47 AND trantable='ld_tab' AND fieldlabel='派工单'  LIMIT 1);
UPDATE ld_tranlabel SET fieldlabel='派工单名称' WHERE tabid=47 AND trantable='ld_field' AND Relateid=@fieldid AND languagetype='zh'
	AND fieldlabel='任务名称' AND @is_paigong=1;
UPDATE ld_tranlabel SET fieldlabel='Dispatch Order Name' WHERE tabid=47 AND trantable='ld_field' AND Relateid=@fieldid AND languagetype='en'
	AND fieldlabel='Task Name' AND @is_paigong=1;

SET @fieldid=(SELECT fieldid FROM ld_field WHERE tabid=47 AND columnname='projecttask_no' LIMIT 1);
UPDATE ld_tranlabel SET fieldlabel='派工单编号' WHERE tabid=47 AND trantable='ld_field' AND Relateid=@fieldid AND languagetype='zh'
	AND fieldlabel='任务编号' AND @is_paigong=1;
UPDATE ld_tranlabel SET fieldlabel='Dispatch Order No' WHERE tabid=47 AND trantable='ld_field' AND Relateid=@fieldid AND languagetype='en'
	AND fieldlabel='Task No' AND @is_paigong=1;

insert into ld_ws_fieldtype(uitype,fieldtype)
select '202','reference' from dual
where not exists(select * from ld_ws_fieldtype where uitype='202' and fieldtype = 'reference');
select fieldtypeid into @fieldtypeid from ld_ws_fieldtype where uitype=202;
insert into ld_ws_referencetype(fieldtypeid,type)
select @fieldtypeid,'SalesOrder' from dual
where not exists(select * from ld_ws_referencetype where type='SalesOrder' and fieldtypeid=@fieldtypeid);
delimiter;
-- 2020-02-13

CALl AddColumn('ld_parenttab','imagename','VARCHAR','100',NULL);
delimiter;

update ld_desk set fieldlabel='纳税人识别号' where labelbol='creditCode' and labeltype='jspop' and languagetype='zh';
delimiter;

update ld_desk set fieldlabel='也可以通过{$SalesOrder.SalesOrder}、{$ServiceContracts.ServiceContracts}或{$Invoice.Invoice}的查看明细界面更多->创建{$PaymentPlan.PaymentPlan}增加。' where labelbol='How_to_create_plan3' and labeltype='fixedstr' and languagetype='zh';
delimiter;

update ld_parenttab set imagename='left_nav_home_ico.png' where parenttab_label = 'My Home Page';
update ld_parenttab set imagename='left_nav_account_ico.png' where parenttab_label = 'Parent Accounts';
update ld_parenttab set imagename='left_nav_sales_ico.png' where parenttab_label = 'Sales';
update ld_parenttab set imagename='left_nav_service_ico.png' where parenttab_label = 'Service';
update ld_parenttab set imagename='left_nav_project_ico.png' where parenttab_label = 'Project';
update ld_parenttab set imagename='left_nav_finacial_ico.png' where parenttab_label = 'Finacial';
update ld_parenttab set imagename='left_nav_purchase_ico.png' where parenttab_label = 'Purchase';
update ld_parenttab set imagename='left_nav_stock_ico.png' where parenttab_label = 'Stock';
update ld_parenttab set imagename='left_nav_oa_ico.png' where parenttab_label = 'OAForms';
update ld_parenttab set imagename='left_nav_marketing_ico.png' where parenttab_label = 'Marketing';
update ld_parenttab set imagename='left_nav_report_ico.png' where parenttab_label = 'Parent Reports';
update ld_parenttab set imagename='left_nav_custom_ico.png' where parenttab_label = 'CustomForms';
update ld_parenttab set imagename='left_nav_tools_ico.png' where parenttab_label = 'Tools';
update ld_parenttab set imagename='left_nav_tools_ico.png' where parenttab_label = 'Settings';
delimiter;
-- 2020-02-18

select tabid into @tabid from ld_tab where name = 'ContactRecords';
update ld_field set typeofdata = 'V~O' where tabid = @tabid and columnname = 'rating';
delimiter;

call AddColumn('ld_activity','cc_email','text','',0);
delimiter;

call AddColumn('ld_pricebookproductrel','description','text','','');
delimiter;

select tabid into @tabid from ld_tab where name = 'ContactRecords';
update ld_field set typeofdata = 'V~O' where tabid = @tabid and columnname = 'rating' and typeofdata = 'v~O';
delimiter;

call AddColumn('ld_attachments','storage_location','varchar',100,null);
delimiter;

call AddColumn('ld_attachments','upload_from','varchar',100,null);
delimiter;

create table if not exists `ld_attachments_tempsave`(
  `id` int(19) primary key auto_increment comment '附件临时保存表主键',
  `newfile_name` varchar(255) comment '附件新名',
  `path` text comment '附件路径',
  `userid` int(11) comment '上传操作人ID',
  `create_time` datetime
);
delimiter;

select tabid into @tabid from ld_tab where `name` = 'Leads';
update ld_field set typeofdata = 'DT~O' where tabid = @tabid and typeofdata = 'datetime';
delimiter;
-- 2020-03-03

call AddColumn('ld_attachments','cloud_path','varchar',255,null);
delimiter;

call AddColumn('ld_attachmentsforbillsdetails','cloud_path','varchar',255,null);
delimiter;

call AddColumn('ld_attachmentsforbillsdetails','storage_location','varchar',100,null);


call AddColumn('ld_attachmentsforbillsdetails','upload_from','varchar',100,null);
delimiter;


call AddColumn('ld_field','keywords','varchar',20,'no');
delimiter;

update ld_field set keywords='yes' where columnname='smownerid' ;
delimiter;

update ld_field
INNER JOIN ld_entityname
on ld_field.tablename=ld_entityname.tablename
and ld_entityname.fieldname=ld_field.fieldname
 set keywords='yes';
 delimiter;

insert into ld_links(tabid,linktype,linklabel,linkurl)
select 0,'Settings','BackupSettings','http://51mis.com.cn/forum.php?mod=viewthread&tid=271' from DUAL
where not exists(select 1 from ld_links where linktype = 'Settings' and linklabel = 'BackupSettings');
delimiter;
-- 2020-03-05

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

UPDATE ld_version SET old_version='V8.0.0',current_version='V8.0.0',remark='V8.0.0-20200327',wx_version='V8.0.0';
delimiter;