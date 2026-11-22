
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


SELECT tabid INTO @tabid  FROM ld_tab WHERE `name`='Project';
UPDATE ld_relatedlists SET actions='ADD,SELECT,CREATEBATCH'
WHERE tabid=@tabid AND label='ProjectTask' AND `name`='get_dependents_list';
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','CREATEBATCH','批量创建','fixedstr' from dual 
where not exists(select 1 from ld_desk where labelbol = 'CREATEBATCH' and languagetype = 'zh' and labeltype = 'fixedstr');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','CREATEBATCH','Create a batch','fixedstr' from dual 
where not exists(select 1 from ld_desk where labelbol = 'CREATEBATCH' and languagetype = 'en' and labeltype = 'fixedstr');
delimiter;

SELECT tabid INTO @tabid FROM ld_tab WHERE `name`='ProjectTask' ;
UPDATE ld_field SET quickcreate=2 WHERE tabid=@tabid AND fieldname='costbudget';
UPDATE ld_field SET quickcreate=2 WHERE tabid=@tabid AND fieldname='timebudget';
UPDATE ld_field SET typeofdata='V~O' WHERE tabid=@tabid AND fieldname='costbudget';
UPDATE ld_field SET typeofdata='V~O' WHERE tabid=@tabid AND fieldname='timebudget';
UPDATE ld_field SET quickcreatesequence=7 WHERE tabid=@tabid AND fieldname='costbudget';
UPDATE ld_field SET quickcreatesequence=8 WHERE tabid=@tabid AND fieldname='timebudget';
delimiter;
-- 2015-11-20

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

update ld_version set old_version='V6.1.8' ,current_version='V6.1.8' ,remark='V6.1.8-20151120';
delimiter;