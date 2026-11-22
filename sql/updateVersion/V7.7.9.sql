DROP PROCEDURE IF EXISTS `AddPrimaryKey`;
delimiter ||
CREATE  PROCEDURE `AddPrimaryKey`(
	tmp_tablename varchar(100),
	tmp_prikeyname varchar(100)
)
BEGIN
 

	IF EXISTS (SELECT 1 FROM INFORMATION_SCHEMA.KEY_COLUMN_USAGE WHERE TABLE_SCHEMA=DATABASE() AND CONSTRAINT_NAME='PRIMARY' AND TABLE_NAME=tmp_tablename) THEN
		SET @mysql=CONCAT('ALTER TABLE `',tmp_tablename,'` DROP PRIMARY KEY,ADD PRIMARY KEY (`',tmp_prikeyname,'`)');
		PREPARE mystatement FROM @mysql;
		EXECUTE mystatement;
		DEALLOCATE PREPARE mystatement;
	ELSE
		SET @mysql=CONCAT('ALTER TABLE `',tmp_tablename,'` ADD PRIMARY KEY (`',tmp_prikeyname,'`)');
		PREPARE mystatement FROM @mysql;
		EXECUTE mystatement;
		DEALLOCATE PREPARE mystatement;
	END IF;

end ||
delimiter;

DROP PROCEDURE IF EXISTS `addtableIndex`;
delimiter ||
CREATE  PROCEDURE `addtableIndex`(
	tablename 	varchar(50),
	indexname 	varchar(50),
	columnlist 	varchar(50)
)
begin
	
	SELECT DATABASE() into @datebase;

	SET @sql2=CONCAT('select count(*) into @cnt from information_schema.statistics where table_name=''',tablename,''' and index_name=''',indexname,'''  and table_schema=''',@datebase,'''');  
	PREPARE statement_name FROM @sql2;  
	EXECUTE statement_name; 
	DEALLOCATE PREPARE statement_name;

	IF @cnt=0 THEN 
		SET @sql3=CONCAT('alter  table ',tablename,' add  index ',indexname,' (',columnlist,')' );
		PREPARE statement_name FROM @sql3;  
		EXECUTE statement_name; 
		DEALLOCATE PREPARE statement_name;
  END IF;
	
end ||
delimiter;

update ld_desk set fieldlabel='4.密码至少需要符合以下4项要求：$=$
            包含大写英文字母(A-Z)$=$
            包含小写英文字母(a-z)$=$
            包含数字(0-9)$=$
            包含特殊字符(!@#$...)' where labelbol='PMWARMREMINDFORPASSWORDADD' and Labeltype='fixedstr' and languagetype='zh';
update ld_desk set fieldlabel='密码规则$=$
            1.普通用户每隔90天需要重置密码，管理员用户每隔30天需要重置密码；$=$
            2.普通用户密码至少需要8位，管理员至少需要15位；$=$
            3.密码不能包含用户账户或者用户名信息；' where labelbol='PMWARMREMINDFORPASSWORD' and Labeltype='fixedstr' and languagetype='zh';
delimiter;

UPDATE ld_field SET allowhide='yes' WHERE tablename='ld_normalapprove' AND columnname IN ('normalapprovetype','description');
-- 2019-06-10

select tabid into @tabid from ld_tab where name='PutCash';
select tabid into @tabid2 from ld_tab where name='CashDeposit';
select blockid into @blockid from ld_appparenttab where parenttab_label='Finacial';
select tabid into @tabid_seq from ld_tab where name='PurchaseCashBack';
select sequence into @sequence from ld_appparenttabrel where blockid=@blockid and tabid=@tabid_seq;
update ld_appparenttabrel set sequence=sequence+10000 where sequence > @sequence;
insert into ld_appparenttabrel(blockid,tabid,sequence)
  select @blockid,@tabid,@sequence+1 from dual
  where not exists(select 1 from ld_appparenttabrel where blockid=@blockid and tabid=@tabid);
insert into ld_appparenttabrel(blockid,tabid,sequence)
  select @blockid,@tabid2,@sequence+2 from dual
  where not exists(select 1 from ld_appparenttabrel where blockid=@blockid and tabid=@tabid2);
set @i = 0;
update ld_appparenttabrel set sequence=(@i:=@i+1) where blockid=@blockid order by sequence asc;
update ld_tab set mobilepresence='weixin' where tabid=@tabid;
update ld_tab set mobilepresence='weixin' where tabid=@tabid2;
insert into ld_cvcolumnlist_wx(modulename,rownumber,listnumber,columnname,type,showtag)
  select 'PutCash',1,1,'ld_putcash:putcash_no:putcash_no:PutCash_fieldlabel:V',2,'yes'
  from dual where not exists(select 1 from ld_cvcolumnlist_wx
  where modulename = 'PutCash' and columnname LIKE 'ld_putcash:putcash_no:%');
insert into ld_cvcolumnlist_wx(modulename,rownumber,listnumber,columnname,showtag)
  select 'PutCash',2,1,'ld_putcash:putcashdate:putcashdate:PutCash_fieldlabel:V','yes'
  from dual where not exists(select 1 from ld_cvcolumnlist_wx
  where modulename = 'PutCash' and columnname LIKE 'ld_putcash:putcashdate:%');
insert into ld_cvcolumnlist_wx(modulename,rownumber,listnumber,columnname,showtag)
  select 'PutCash',3,1,'ld_putcash:cashmoney:cashmoney:PutCash_fieldlabel:V','yes'
  from dual where not exists(select 1 from ld_cvcolumnlist_wx
  where modulename = 'PutCash' and columnname LIKE 'ld_putcash:cashmoney:%');
insert into ld_cvcolumnlist_wx(modulename,rownumber,listnumber,columnname,showtag)
  select 'PutCash',4,1,'ld_putcash:smownerid:assigned_user_id:PutCash_fieldlabel:V','yes'
  from dual where not exists(select 1 from ld_cvcolumnlist_wx
  where modulename = 'PutCash' and columnname LIKE 'ld_putcash:smownerid:%');

DELETE FROM ld_fieldwxmaininfo  WHERE tabid=@tabid;
SET @i=0;
INSERT INTO ld_fieldwxmaininfo(tabid,fieldname,sequence,displaytype,presence,showtag)
  SELECT @tabid,'putcash_no',(@i:=@i+1),'title',0,'yes' FROM DUAL
  WHERE NOT EXISTS(SELECT 1 FROM ld_fieldwxmaininfo WHERE tabid=@tabid AND fieldname='putcash_no');
INSERT INTO ld_fieldwxmaininfo(tabid,fieldname,sequence,displaytype,presence,showtag)
  SELECT @tabid,'putcashdate',(@i:=@i+1),'normal',0,'yes' FROM DUAL
  WHERE NOT EXISTS(SELECT 1 FROM ld_fieldwxmaininfo WHERE tabid=@tabid AND fieldname='putcashdate');
INSERT INTO ld_fieldwxmaininfo(tabid,fieldname,sequence,displaytype,presence,showtag)
  SELECT @tabid,'cashmoney',(@i:=@i+1),'normal',0,'yes' FROM DUAL
  WHERE NOT EXISTS(SELECT 1 FROM ld_fieldwxmaininfo WHERE tabid=@tabid AND fieldname='cashmoney');
INSERT INTO ld_fieldwxmaininfo(tabid,fieldname,sequence,displaytype,presence,showtag)
  SELECT @tabid,'assigned_user_id',(@i:=@i+1),'normal',0,'yes' FROM DUAL
  WHERE NOT EXISTS(SELECT 1 FROM ld_fieldwxmaininfo WHERE tabid=@tabid AND fieldname='assigned_user_id');

insert into ld_cvcolumnlist_wx(modulename,rownumber,listnumber,columnname,type,showtag)
  select 'CashDeposit',1,1,'ld_cashdeposit:cashdeposit_no:cashdeposit_no:CashDeposit_fieldlabel:V',2,'yes'
  from dual where not exists(select 1 from ld_cvcolumnlist_wx
  where modulename = 'CashDeposit' and columnname LIKE 'ld_cashdeposit:cashdeposit_no:%');
insert into ld_cvcolumnlist_wx(modulename,rownumber,listnumber,columnname,showtag)
  select 'CashDeposit',2,1,'ld_cashdeposit:cashdepositdate:cashdepositdate:CashDeposit_fieldlabel:V','yes'
  from dual where not exists(select 1 from ld_cvcolumnlist_wx
  where modulename = 'CashDeposit' and columnname LIKE 'ld_cashdeposit:cashdepositdate:%');
insert into ld_cvcolumnlist_wx(modulename,rownumber,listnumber,columnname,showtag)
  select 'CashDeposit',3,1,'ld_cashdeposit:cashmoney:cashmoney:CashDeposit_fieldlabel:V','yes'
  from dual where not exists(select 1 from ld_cvcolumnlist_wx
  where modulename = 'CashDeposit' and columnname LIKE 'ld_cashdeposit:cashmoney:%');
insert into ld_cvcolumnlist_wx(modulename,rownumber,listnumber,columnname,showtag)
  select 'CashDeposit',4,1,'ld_cashdeposit:smownerid:assigned_user_id:CashDeposit_fieldlabel:V','yes'
  from dual where not exists(select 1 from ld_cvcolumnlist_wx
  where modulename = 'CashDeposit' and columnname LIKE 'ld_cashdeposit:smownerid:%');

DELETE FROM ld_fieldwxmaininfo  WHERE tabid=@tabid2;
SET @i=0;
INSERT INTO ld_fieldwxmaininfo(tabid,fieldname,sequence,displaytype,presence,showtag)
  SELECT @tabid2,'cashdeposit_no',(@i:=@i+1),'title',0,'yes' FROM DUAL
  WHERE NOT EXISTS(SELECT 1 FROM ld_fieldwxmaininfo WHERE tabid=@tabid2 AND fieldname='cashdeposit_no');
INSERT INTO ld_fieldwxmaininfo(tabid,fieldname,sequence,displaytype,presence,showtag)
  SELECT @tabid2,'cashdepositdate',(@i:=@i+1),'normal',0,'yes' FROM DUAL
  WHERE NOT EXISTS(SELECT 1 FROM ld_fieldwxmaininfo WHERE tabid=@tabid2 AND fieldname='cashdepositdate');
INSERT INTO ld_fieldwxmaininfo(tabid,fieldname,sequence,displaytype,presence,showtag)
  SELECT @tabid2,'cashmoney',(@i:=@i+1),'normal',0,'yes' FROM DUAL
  WHERE NOT EXISTS(SELECT 1 FROM ld_fieldwxmaininfo WHERE tabid=@tabid2 AND fieldname='cashmoney');
INSERT INTO ld_fieldwxmaininfo(tabid,fieldname,sequence,displaytype,presence,showtag)
  SELECT @tabid2,'assigned_user_id',(@i:=@i+1),'normal',0,'yes' FROM DUAL
  WHERE NOT EXISTS(SELECT 1 FROM ld_fieldwxmaininfo WHERE tabid=@tabid2 AND fieldname='assigned_user_id');
delimiter;


insert into ld_desk (languagetype,labelbol,fieldlabel,labeltype)
select 'zh','CURMEMBER','当前成员','fixedstr' from dual 
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='CURMEMBER' and Labeltype='fixedstr');
insert into ld_desk (languagetype,labelbol,fieldlabel,labeltype)
select 'en','CURMEMBER','Current user','fixedstr' from dual 
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='CURMEMBER' and Labeltype='fixedstr');
delimiter;


select tabid into @tabid1 from ld_tab where name='Documents';
DELETE FROM ld_fieldwxmaininfo  WHERE tabid=@tabid1;
SET @i=0;
INSERT INTO ld_fieldwxmaininfo(tabid,fieldname,sequence,displaytype,presence,showtag)
  SELECT @tabid1,'notes_title',(@i:=@i+1),'title',0,'yes' FROM DUAL
  WHERE NOT EXISTS(SELECT 1 FROM ld_fieldwxmaininfo WHERE tabid=@tabid1 AND fieldname='notes_title');
INSERT INTO ld_fieldwxmaininfo(tabid,fieldname,sequence,displaytype,presence,showtag)
  SELECT @tabid1,'folderid',(@i:=@i+1),'normal',0,'yes' FROM DUAL
  WHERE NOT EXISTS(SELECT 1 FROM ld_fieldwxmaininfo WHERE tabid=@tabid1 AND fieldname='folderid');
INSERT INTO ld_fieldwxmaininfo(tabid,fieldname,sequence,displaytype,presence,showtag)
  SELECT @tabid1,'assigned_user_id',(@i:=@i+1),'normal',0,'yes' FROM DUAL
  WHERE NOT EXISTS(SELECT 1 FROM ld_fieldwxmaininfo WHERE tabid=@tabid1 AND fieldname='assigned_user_id');

select tabid into @tabid2 from ld_tab where name='Events';
DELETE FROM ld_fieldwxmaininfo  WHERE tabid=@tabid2;
SET @i=0;
INSERT INTO ld_fieldwxmaininfo(tabid,fieldname,sequence,displaytype,presence,showtag)
  SELECT @tabid2,'subject',(@i:=@i+1),'title',0,'yes' FROM DUAL
  WHERE NOT EXISTS(SELECT 1 FROM ld_fieldwxmaininfo WHERE tabid=@tabid2 AND fieldname='subject');
INSERT INTO ld_fieldwxmaininfo(tabid,fieldname,sequence,displaytype,presence,showtag)
  SELECT @tabid2,'date_start',(@i:=@i+1),'normal',0,'yes' FROM DUAL
  WHERE NOT EXISTS(SELECT 1 FROM ld_fieldwxmaininfo WHERE tabid=@tabid2 AND fieldname='date_start');
INSERT INTO ld_fieldwxmaininfo(tabid,fieldname,sequence,displaytype,presence,showtag)
  SELECT @tabid2,'due_date',(@i:=@i+1),'normal',0,'yes' FROM DUAL
  WHERE NOT EXISTS(SELECT 1 FROM ld_fieldwxmaininfo WHERE tabid=@tabid2 AND fieldname='due_date');
INSERT INTO ld_fieldwxmaininfo(tabid,fieldname,sequence,displaytype,presence,showtag)
  SELECT @tabid2,'assigned_user_id',(@i:=@i+1),'normal',0,'yes' FROM DUAL
  WHERE NOT EXISTS(SELECT 1 FROM ld_fieldwxmaininfo WHERE tabid=@tabid2 AND fieldname='assigned_user_id');
INSERT INTO ld_fieldwxmaininfo(tabid,fieldname,sequence,displaytype,presence,showtag)
  SELECT @tabid2,'account_id',(@i:=@i+1),'normal',0,'yes' FROM DUAL
  WHERE NOT EXISTS(SELECT 1 FROM ld_fieldwxmaininfo WHERE tabid=@tabid2 AND fieldname='account_id');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','DOWNLOADCSV','点击下载csv表','fixedstr' from dual 
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='DOWNLOADCSV' and Labeltype='fixedstr');

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','DOWNLOADCSV','Download csv','fixedstr' from dual 
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='DOWNLOADCSV' and Labeltype='fixedstr');
delimiter;


insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','DOWNLOADXLS','点击下载Excel表','fixedstr' from dual 
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='DOWNLOADXLS' and Labeltype='fixedstr');

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','DOWNLOADXLS','Download excel','fixedstr' from dual 
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='DOWNLOADXLS' and Labeltype='fixedstr');
delimiter;

select tabid into @tabid from  ld_tab where name='PaymentPlan';
select fieldlabel into @tmp_zhmoudulename from ld_tranlabel where tabid=@tabid and relateid=@tabid and languagetype='zh' and trantable='ld_tab' ;
SET @approvename=CONCAT(@tmp_zhmoudulename,'选人审批流程');
SET @approveid=(SELECT MAX(id) FROM ld_approve);
INSERT INTO ld_approve(id,tabid,`name`,`status`,smcreatorid,modifiedby,createdtime,modifiedtime,approveallocatetype,allowediting,allowantiapproval,finishedallowedit)
	SELECT @approveid+1,@tabid,@approvename,0,1,1,now(),now(),0,0,0,'no' FROM DUAL
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

SET @stepid=(SELECT id FROM ld_approvestep WHERE approveid=@approveid AND `name`='一级审批');
INSERT INTO ld_approvereminds(stepid,type,remindmethod,reminduser,remindcontent)
		SELECT @stepid,0,'dialog','approver','有新的单据需要审批，请及时处理！' FROM DUAL
		WHERE NOT EXISTS (SELECT 1 FROM ld_approvereminds WHERE stepid=@stepid AND type=0);

SET @stepid=(SELECT id FROM ld_approvestep WHERE approveid=@approveid AND `name`='一级审批');
INSERT INTO ld_approvereminds(stepid,type,remindmethod,reminduser,remindcontent)
		SELECT @stepid,1,'dialog','smowner','您提交的单据已通过审批步骤{step}' FROM DUAL
		WHERE NOT EXISTS (SELECT 1 FROM ld_approvereminds WHERE stepid=@stepid AND type=1);

SET @stepid=(SELECT id FROM ld_approvestep WHERE approveid=@approveid AND `name`='一级审批');
INSERT INTO ld_approvereminds(stepid,type,remindmethod,reminduser,remindcontent)
		SELECT @stepid,2,'dialog','smowner','您提交的单据未通过审批步骤{step}，原因：{description}' FROM DUAL
		WHERE NOT EXISTS (SELECT 1 FROM ld_approvereminds WHERE stepid=@stepid AND type=2);

SET @stepid=(SELECT id FROM ld_approvestep WHERE approveid=@approveid AND `name`='二级审批');
INSERT INTO ld_approvereminds(stepid,type,remindmethod,reminduser,remindcontent)
		SELECT @stepid,0,'dialog','approver','有新的单据需要审批，请及时处理！' FROM DUAL
		WHERE NOT EXISTS (SELECT 1 FROM ld_approvereminds WHERE stepid=@stepid AND type=0);

SET @stepid=(SELECT id FROM ld_approvestep WHERE approveid=@approveid AND `name`='二级审批');
INSERT INTO ld_approvereminds(stepid,type,remindmethod,reminduser,remindcontent)
		SELECT @stepid,1,'dialog','smowner','您提交的单据已通过审批步骤{step}' FROM DUAL
		WHERE NOT EXISTS (SELECT 1 FROM ld_approvereminds WHERE stepid=@stepid AND type=1);

SET @stepid=(SELECT id FROM ld_approvestep WHERE approveid=@approveid AND `name`='二级审批');
INSERT INTO ld_approvereminds(stepid,type,remindmethod,reminduser,remindcontent)
		SELECT @stepid,2,'dialog','smowner','您提交的单据未通过审批步骤{step}，原因：{description}' FROM DUAL
		WHERE NOT EXISTS (SELECT 1 FROM ld_approvereminds WHERE stepid=@stepid AND type=2);

SET @stepid=(SELECT id FROM ld_approvestep WHERE approveid=@approveid AND `name`='三级审批');
INSERT INTO ld_approvereminds(stepid,type,remindmethod,reminduser,remindcontent)
		SELECT @stepid,0,'dialog','approver','有新的单据需要审批，请及时处理！' FROM DUAL
		WHERE NOT EXISTS (SELECT 1 FROM ld_approvereminds WHERE stepid=@stepid AND type=0);

SET @stepid=(SELECT id FROM ld_approvestep WHERE approveid=@approveid AND `name`='三级审批');
INSERT INTO ld_approvereminds(stepid,type,remindmethod,reminduser,remindcontent)
		SELECT @stepid,1,'dialog','smowner','您提交的单据已通过审批步骤{step}' FROM DUAL
		WHERE NOT EXISTS (SELECT 1 FROM ld_approvereminds WHERE stepid=@stepid AND type=1);

SET @stepid=(SELECT id FROM ld_approvestep WHERE approveid=@approveid AND `name`='三级审批');
INSERT INTO ld_approvereminds(stepid,type,remindmethod,reminduser,remindcontent)
		SELECT @stepid,2,'dialog','smowner','您提交的单据未通过审批步骤{step}，原因：{description}' FROM DUAL
		WHERE NOT EXISTS (SELECT 1 FROM ld_approvereminds WHERE stepid=@stepid AND type=2);
delimiter;


select tabid into @tabid from  ld_tab where name='SendPayment';
select fieldlabel into @tmp_zhmoudulename from ld_tranlabel where tabid=@tabid and relateid=@tabid and languagetype='zh' and trantable='ld_tab' ;
SET @approvename=CONCAT(@tmp_zhmoudulename,'选人审批流程');
SET @approveid=(SELECT MAX(id) FROM ld_approve);
INSERT INTO ld_approve(id,tabid,`name`,`status`,smcreatorid,modifiedby,createdtime,modifiedtime,approveallocatetype,allowediting,allowantiapproval,finishedallowedit)
	SELECT @approveid+1,@tabid,@approvename,0,1,1,now(),now(),0,0,0,'no' FROM DUAL
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

SET @stepid=(SELECT id FROM ld_approvestep WHERE approveid=@approveid AND `name`='一级审批');
INSERT INTO ld_approvereminds(stepid,type,remindmethod,reminduser,remindcontent)
		SELECT @stepid,0,'dialog','approver','有新的单据需要审批，请及时处理！' FROM DUAL
		WHERE NOT EXISTS (SELECT 1 FROM ld_approvereminds WHERE stepid=@stepid AND type=0);

SET @stepid=(SELECT id FROM ld_approvestep WHERE approveid=@approveid AND `name`='一级审批');
INSERT INTO ld_approvereminds(stepid,type,remindmethod,reminduser,remindcontent)
		SELECT @stepid,1,'dialog','smowner','您提交的单据已通过审批步骤{step}' FROM DUAL
		WHERE NOT EXISTS (SELECT 1 FROM ld_approvereminds WHERE stepid=@stepid AND type=1);

SET @stepid=(SELECT id FROM ld_approvestep WHERE approveid=@approveid AND `name`='一级审批');
INSERT INTO ld_approvereminds(stepid,type,remindmethod,reminduser,remindcontent)
		SELECT @stepid,2,'dialog','smowner','您提交的单据未通过审批步骤{step}，原因：{description}' FROM DUAL
		WHERE NOT EXISTS (SELECT 1 FROM ld_approvereminds WHERE stepid=@stepid AND type=2);

SET @stepid=(SELECT id FROM ld_approvestep WHERE approveid=@approveid AND `name`='二级审批');
INSERT INTO ld_approvereminds(stepid,type,remindmethod,reminduser,remindcontent)
		SELECT @stepid,0,'dialog','approver','有新的单据需要审批，请及时处理！' FROM DUAL
		WHERE NOT EXISTS (SELECT 1 FROM ld_approvereminds WHERE stepid=@stepid AND type=0);

SET @stepid=(SELECT id FROM ld_approvestep WHERE approveid=@approveid AND `name`='二级审批');
INSERT INTO ld_approvereminds(stepid,type,remindmethod,reminduser,remindcontent)
		SELECT @stepid,1,'dialog','smowner','您提交的单据已通过审批步骤{step}' FROM DUAL
		WHERE NOT EXISTS (SELECT 1 FROM ld_approvereminds WHERE stepid=@stepid AND type=1);

SET @stepid=(SELECT id FROM ld_approvestep WHERE approveid=@approveid AND `name`='二级审批');
INSERT INTO ld_approvereminds(stepid,type,remindmethod,reminduser,remindcontent)
		SELECT @stepid,2,'dialog','smowner','您提交的单据未通过审批步骤{step}，原因：{description}' FROM DUAL
		WHERE NOT EXISTS (SELECT 1 FROM ld_approvereminds WHERE stepid=@stepid AND type=2);

SET @stepid=(SELECT id FROM ld_approvestep WHERE approveid=@approveid AND `name`='三级审批');
INSERT INTO ld_approvereminds(stepid,type,remindmethod,reminduser,remindcontent)
		SELECT @stepid,0,'dialog','approver','有新的单据需要审批，请及时处理！' FROM DUAL
		WHERE NOT EXISTS (SELECT 1 FROM ld_approvereminds WHERE stepid=@stepid AND type=0);

SET @stepid=(SELECT id FROM ld_approvestep WHERE approveid=@approveid AND `name`='三级审批');
INSERT INTO ld_approvereminds(stepid,type,remindmethod,reminduser,remindcontent)
		SELECT @stepid,1,'dialog','smowner','您提交的单据已通过审批步骤{step}' FROM DUAL
		WHERE NOT EXISTS (SELECT 1 FROM ld_approvereminds WHERE stepid=@stepid AND type=1);

SET @stepid=(SELECT id FROM ld_approvestep WHERE approveid=@approveid AND `name`='三级审批');
INSERT INTO ld_approvereminds(stepid,type,remindmethod,reminduser,remindcontent)
		SELECT @stepid,2,'dialog','smowner','您提交的单据未通过审批步骤{step}，原因：{description}' FROM DUAL
		WHERE NOT EXISTS (SELECT 1 FROM ld_approvereminds WHERE stepid=@stepid AND type=2);
delimiter;
-- 2019-06-12

CALL AddPrimaryKey('ld_customform11detailscf','lineitem_id');
CALL AddPrimaryKey('ld_customform12detailscf','lineitem_id');
CALL AddPrimaryKey('ld_customform13detailscf','lineitem_id');
CALL AddPrimaryKey('ld_customform14detailscf','lineitem_id');
CALL AddPrimaryKey('ld_customform15detailscf','lineitem_id');

CALL AddPrimaryKey('ld_customform16detailscf','lineitem_id');
CALL AddPrimaryKey('ld_customform17detailscf','lineitem_id');
CALL AddPrimaryKey('ld_customform18detailscf','lineitem_id');
CALL AddPrimaryKey('ld_customform19detailscf','lineitem_id');
CALL AddPrimaryKey('ld_customform20detailscf','lineitem_id');

CALL AddColumn('ld_leads','bill_area','varchar','100',NULL);


DROP PROCEDURE IF EXISTS `account_singlerecycle_normal_rule`;
delimiter ||
CREATE PROCEDURE `account_singlerecycle_normal_rule`(
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
	declare cur1 CURSOR FOR select tabname,ld_account_set_rule.columnname,ld_field.tablename ,
	ld_account_set_rule.iscycle,`condition`,ld_account_set_rule.days
 ,ld_account_set_rule.otherwhere from ld_account_set_rule  inner join ld_tab on ld_tab.name=ld_account_set_rule.tabname and (presence in(0,2) or ld_account_set_rule.tabname='singin')
	INNER JOIN ld_field on ld_field.tabid=ld_tab.tabid and ld_account_set_rule.columnname=ld_field.columnname
	and ld_field.presence in(0,2) where ld_account_set_rule.type='normal' and ld_account_set_rule.`status`='active';
	declare continue handler  for not   found  SET done =1;
	set @tmpint=0;
	set @tmpsql='';
	select max(ld_account_set_rule.days) into @maxdays
  from ld_account_set_rule  inner join ld_tab on ld_tab.name=ld_account_set_rule.tabname and (presence in(0,2) or ld_account_set_rule.tabname='singin')
	INNER JOIN ld_field on ld_field.tabid=ld_tab.tabid and ld_account_set_rule.columnname=ld_field.columnname
	and ld_field.presence in(0,2) where ld_account_set_rule.type='normal' and ld_account_set_rule.`status`='active';
   
	select recycleselect into @recycleselect from ld_account_set;
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
				 
				set @TMPSQL_ONE=concat( ' select "系统","LOGPUBLICNORMAL",now(), ld_account.accountid  from ld_account left join ( ',@tmpsql,' ) as lingdangtmp  on  lingdangtmp.accountid=ld_account.accountid ') ;
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
			
				set @TMPSQL_ONE=concat( ' select "系统","LOGPUBLICNORMAL",now(), ld_account.accountid  from ld_account inner join ( ',@sql,' ) as lingdangtmp  on  lingdangtmp.accountid=ld_account.accountid ') ;
				set @TMPSQL_TWO=concat(@TMPSQL_ONE,' where ld_account.deleted=0 and( ifnull(ld_account.publicaccount,0)<1)'  );
		 end if;

	   set @TMPSQL_THREE=concat('insert into ld_logpublicaccount(username,operation,opdate,accountid) ',@TMPSQL_TWO);
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
				set @TMPSQL_ONE =concat(@TMPSQL_ONE,' set ld_account.publicaccount=1 ,protectdate=null ,allocatedate=null') ;
  
					set @TMPSQL_TWO=concat(@TMPSQL_ONE,' where ld_account.deleted=0 and( ifnull(ld_account.publicaccount,0)<1)    ');
		      set @TMPSQL_TWO=concat(@TMPSQL_TWO, " and lingdangtmp.accountid is null and datediff(curdate(),case when ifnull(ld_account.distributiondate,'')='' then ld_account.createdtime else ld_account.distributiondate end)>",@maxdays);
					if @recycleselect<>'' and @recycleselect is not null THEN	 
					   set @TMPSQL_TWO=concat(@TMPSQL_TWO, ' and recyclewheretableset.accountid is not null  ');
				  end if;
			ELSE
				set @TMPSQL_ONE=concat( ' update  ld_account inner join ( ',@sql,' ) as lingdangtmp  on  lingdangtmp.accountid=ld_account.accountid set ld_account.publicaccount=1 ,protectdate=null ,allocatedate=null') ;
		    set @TMPSQL_TWO=concat(@TMPSQL_ONE,' where ld_account.deleted=0 and( ifnull(ld_account.publicaccount,0)<1)    ');
					
		 end if;
		prepare stmt from @TMPSQL_TWO;
		execute stmt;
		deallocate prepare stmt;

	end if;


end||
delimiter;

select tabsequence into @tabsequence from ld_tab where name='oftenusereport';
update ld_tab set tabsequence=tabsequence+2  where tabsequence>@tabsequence;
insert into ld_tab (tabid,name,presence,tabsequence)
select -2,'MobileReport',1,@tabsequence+1 from dual 
where not exists(select 1 from ld_tab where name='MobileReport');
delimiter;

insert into ld_tranlabel(languagetype,relateid,trantable,tabid,fieldlabel)
select 'zh','-2','ld_tab' ,'-2' ,'移动端报表' from dual 
where not exists(select 1 from ld_tranlabel where tabid=-2 and relateid=-2 and trantable='ld_tab' and languagetype='zh');

insert into ld_tranlabel(languagetype,relateid,trantable,tabid,fieldlabel)
select 'en','-2','ld_tab' ,'-2' ,'Mobile Report' from dual 
where not exists(select 1 from ld_tranlabel where tabid=-2 and relateid=-2 and trantable='ld_tab' and languagetype='en');
delimiter;

insert into ld_profileallpermission(tabid,operation,sequence)
select -2,3,0 from dual where not exists(select 1 from ld_profileallpermission where tabid=-2);
delimiter;

SELECT
	GROUP_CONCAT(lower(name)) into @realtednames FROM ld_dashboard_app
LEFT JOIN ld_appuiset ON ld_dashboard_app. NAME = ld_appuiset.setname
AND ld_appuiset.apptype = 'weixin'
AND ld_appuiset.userid = 1
WHERE wx_presence = 1 ORDER BY wx_sequence ASC;

insert into ld_profile2standardpermissions(profileid,tabid,operation,permissions,sequence,relatednames)
select profileid,-2,3,0,0,@realtednames from (
select  GROUP_CONCAT( DISTINCT tabid) as tabids,profileid from ld_profile2standardpermissions 
GROUP BY profileid ) as tmp where tabids not like '%-2,%';
delimiter;

update ld_desk set fieldlabel='审批流程定制' where labelbol='LBL_APPROVE' and Labeltype='fixedstr' and languagetype='zh' and 
fieldlabel='审批流程管理';
delimiter;

call AddColumn('ld_organizationdetails','menuback_color','varchar','255',NULL);
call AddColumn('ld_organizationdetails','menuhover_color','varchar','255',NULL);
delimiter;

update ld_outboundorderdetail inner join 
( SELECT (ld_outboundorderdetail.quantity - 
ifnull(sum(ifnull(ld_invoicedetail.quantity,0)),0)) 
AS tmpbalance, ld_outboundorderdetail.lineitem_id, ld_invoicedetail.productid
 FROM ld_outboundorderdetail left join ld_invoicedetail on
 ld_outboundorderdetail.lineitem_id=ld_invoicedetail.parent_lineitem_id
 left  JOIN ld_invoice ON ld_invoicedetail.id=ld_invoice.invoiceid 
and ld_invoice.deleted = 0 and ld_invoice.approvestatus<>'已拒绝'
group by ld_outboundorderdetail.lineitem_id,ld_outboundorderdetail.productid) 
as tmp on tmp.lineitem_id=ld_outboundorderdetail.lineitem_id
 set balanceinvoicecount=tmpbalance ;
delimiter;

update ld_outboundorderdetail set haveinvoicecount=quantity-balanceinvoicecount;
delimiter;

select usereportid into @usereportid from ld_usereport where name='InventoryQuery';
select Sequence into @sequence from ld_usereportcolumns
where Usereportid=@usereportid and columns like 'ld_stock:batchtext:batchtext%';
insert into ld_usereportcolumns (Usereportid,columns, Sequence, realcolumns, realencolumns)
  SELECT @usereportid,'ld_stock:wareid:wareid:Stock_仓库#:V',@sequence+1,'ld_stock:wareid:wareid:Stock_仓库:V',
    'ld_stock:wareid:wareid:Stock_Warehouse:V' from dual where not exists(select 1 from ld_usereportcolumns
  where columns like 'ld_stock:wareid:wareid%' and Usereportid=@usereportid);
set @i=0;
update ld_usereportcolumns set Sequence=(@i:=@i+1) where Usereportid=@usereportid order by Sequence ASC ;
select usereportid into @usereportid from ld_usereport where name='InventoryLedger';
select Sequence into @sequence from ld_usereportcolumns
where Usereportid=@usereportid and columns like 'ld_stock:batchtext:batchtext%';
insert into ld_usereportcolumns (Usereportid,columns, Sequence, realcolumns, realencolumns)
  SELECT @usereportid,'ld_stock:wareid:wareid:Stock_仓库#:V',@sequence+1,'ld_stock:wareid:wareid:Stock_仓库:V',
    'ld_stock:wareid:wareid:Stock_Warehouse:V' from dual where not exists(select 1 from ld_usereportcolumns
  where columns like 'ld_stock:wareid:wareid%' and Usereportid=@usereportid);
set @i=0;
update ld_usereportcolumns set Sequence=(@i:=@i+1) where Usereportid=@usereportid order by Sequence ASC ;
insert into ld_desk (languagetype,labelbol, fieldlabel, Labeltype)
  select 'zh','OFTENUSEREPORTWORD','报表','fixedstr' from dual
  where not exists(select 1 from ld_desk where labelbol='OFTENUSEREPORTWORD' and languagetype='zh' and Labeltype='fixedstr');
insert into ld_desk (languagetype, labelbol, fieldlabel, Labeltype)
  select 'en','OFTENUSEREPORTWORD','Report','fixedstr' from dual
  where not exists(select 1 from ld_desk where labelbol='OFTENUSEREPORTWORD' and languagetype='en' and Labeltype='fixedstr');
delimiter;
-- 2019-06-14

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

UPDATE ld_version SET old_version='V7.7.9',current_version='V7.7.9',remark='V7.7.9-20190614',wx_version='V7.7.9';
delimiter;