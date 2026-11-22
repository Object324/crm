set @tabid=2;
select fieldname into @fieldname from ld_field where tabid=@tabid and helpinfo='absamount(预算绝对值)';
delete from  ld_fieldformulas where expression_engine like '%cf_1308%' or expression_engine is NULL;
select max(expressionid) into @expressionid from ld_fieldformulas;
insert into ld_fieldformulas(expressionid,modulename,expression_engine)
select @expressionid+1,'Potentials',concat('O:18:"VTExpressionEngine":6:{s:4:"data";a:0:{}s:11:"expressions";a:1:{s:7:"',@fieldname,'";O:10:"VTTreeNode":1:{s:3:"arr";a:3:{i:0;O:6:"Symbol":1:{s:5:"value";s:1:"*";}i:1;O:6:"Symbol":1:{s:5:"value";s:6:"amount";}i:2;O:10:"VTTreeNode":1:{s:3:"arr";a:3:{i:0;O:6:"Symbol":1:{s:5:"value";s:1:"/";}i:1;O:6:"Symbol":1:{s:5:"value";s:11:"possibility";}i:2;i:100;}}}}}s:19:"unparsedExpressions";a:1:{s:7:"',@fieldname,'";s:22:"amount*possibility/100";}s:4:"vars";a:1:{i:0;s:7:"',@fieldname,'";}s:12:"independents";a:0:{}s:10:"dependents";a:0:{}}');
update ld_fieldformulas_seq set id=(select max(expressionid) from ld_fieldformulas);
delimiter;
delete from ld_remindcvstdfilter where startdate  is null;
delete from ld_remindcvstdfilter where enddate  is null;
delimiter;

update ld_tab set presence = 1 where `name` = 'SalesGoal' and exists (select * from ld_version where versiontype = 2);
update ld_tab set presence = 1 where `name` = 'SalesGoal' and exists (select * from ld_version where versiontype = 7);

set @tabid=0;
select tabid into @tabid from ld_tab where name='ServiceCharge';
update ld_tab set presence=1 where tabid=@tabid and exists (select 1 from ld_version where versiontype in (2,7));
delimiter;

update ld_tab set presence=1 where `name` in ('WareHouseTransfer','PurchaseInvoice','PurchaseOrder') and exists (select 1 from ld_version where versiontype in (2,5,7,10));
update ld_relatedlists set presence=1 where tabid=6 and `name`='get_balanceofaccount' and exists (select 1 from ld_version where versiontype in (2,7));
delimiter;

call AddColumn('LD_smssend','reminds_ruleid','int',11,1);
delimiter;
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','XBXImportProjectandAccounts','导入{$Project.Project}和{$Accounts.Accounts}','fixedstr' from dual
where not EXISTS(select 1 from ld_desk where languagetype='zh' and labelbol='XBXImportProjectandAccounts' and Labeltype='fixedstr');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','XBXImportProjectandAccounts','Import {$Project.Project} and {$Accounts.Accounts}','fixedstr' from dual
where not EXISTS(select 1 from ld_desk  where languagetype='en' and labelbol='XBXImportProjectandAccounts' and Labeltype='fixedstr');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','IMPORTEXCELTEMPLATE','导入excel格式模板','fixedstr' from dual
where not EXISTS(select 1 from ld_desk  where languagetype='zh' and labelbol='IMPORTEXCELTEMPLATE' and Labeltype='fixedstr');

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','IMPORTEXCELTEMPLATE','Importing excel format template','fixedstr' from dual
where not EXISTS(select 1 from ld_desk  where languagetype='en' and labelbol='IMPORTEXCELTEMPLATE' and Labeltype='fixedstr');
delimiter;

select templateid into @templateid from ld_templates where templatename='老板桌面';
insert into ld_templatesstuff(stuffId,templateid,Stufftype,stuffsequence,stufftitle)
select 33,@templateid,'Default',0,'SALESCHARTS' from dual
where not exists (select 1 from ld_templatesstuff where templateid=@templateid and stuffId=33);
delimiter;

select templateid into @templateid from ld_templates where templatename='销售经理桌面';
insert into ld_templatesstuff(stuffId,templateid,Stufftype,stuffsequence,stufftitle)
select 33,@templateid,'Default',0,'SALESCHARTS' from dual
where not exists (select 1 from ld_templatesstuff where templateid=@templateid and stuffId=33);
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'zh','SALESCHARTS','销售排行榜','fixedstr' from dual
where not EXISTS(select 1 from ld_desk  where languagetype='zh' and labelbol='SALESCHARTS' and Labeltype='fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'en','SALESCHARTS','Sales charts','fixedstr' from dual
where not EXISTS(select 1 from ld_desk  where languagetype='en' and labelbol='SALESCHARTS' and Labeltype='fixedstr');

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'zh','CONTRACTAOUNT','签约金额','fixedstr' from dual
where not EXISTS(select 1 from ld_desk  where languagetype='zh' and labelbol='CONTRACTAOUNT' and Labeltype='fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'en','CONTRACTAOUNT','Contract amount','fixedstr' from dual
where not EXISTS(select 1 from ld_desk  where languagetype='en' and labelbol='CONTRACTAOUNT' and Labeltype='fixedstr');

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'zh','CONTRACTQUANTITY','签约数量','fixedstr' from dual
where not EXISTS(select 1 from ld_desk  where languagetype='zh' and labelbol='CONTRACTQUANTITY' and Labeltype='fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'en','CONTRACTQUANTITY','Contract quantity','fixedstr' from dual
where not EXISTS(select 1 from ld_desk  where languagetype='en' and labelbol='CONTRACTQUANTITY' and Labeltype='fixedstr');
delimiter;

SELECT usereportid into @usereportid FROM ld_usereport WHERE name='Contractnumber';
UPDATE ld_usereportcolumns SET realencolumns='LD_salesorder:groupbycount:groupbycount:SalesOrder_Contract quantity:N'
WHERE Usereportid=@usereportid AND columns LIKE 'LD_salesorder:groupbycount:groupbycount:SalesOrder_%';
delimiter;

select usereportid into @id from LD_usereport where name='Performancestatisticscollection';
SELECT Sequence into @sid FROM ld_usereportcolumns WHERE columns like 'LD_account:accountname:accountname:Accounts_%' AND Usereportid=@id;
insert into LD_UseReportcolumns(id,Usereportid,columns,Sequence,columnshow,realcolumns,realencolumns)
select '', @id, 'LD_users:lastname3:lastname3:OftenUseReport_lastname3:V', @sid+1, 1, 'LD_users:lastname3:lastname3:OftenUseReport_创建人:V','LD_users:lastname3:lastname3:OftenUseReport_creator:V' from dual
where not exists(select 1 from LD_UseReportcolumns where Usereportid=@id and realcolumns like 'LD_users:lastname3:lastname3:OftenUseReport_%');
delimiter;

select tabid into @tabid from ld_tab where name = 'Campaigns';
select tabid into @tabid2 from ld_tab where name = 'Reminds';
SELECT max(sequence) into @sequence from ld_quickactions where tabid=@tabid;

insert into ld_quickactions(tabid,related_tabid,sequence,presence)
select @tabid,@tabid2,@sequence+1,0 from dual
where not EXISTS(select 1 from ld_quickactions  where tabid=@tabid and related_tabid=@tabid2);
delimiter;

select tabid into @tabid from ld_tab where name = 'ServiceContracts';
select tabid into @tabid2 from ld_tab where name = 'Project';
SELECT max(sequence) into @sequence from ld_quickactions where tabid=@tabid;
insert into ld_quickactions(tabid,related_tabid,sequence,presence)
select @tabid,@tabid2,@sequence+1,0 from dual
where not EXISTS(select 1 from ld_quickactions  where tabid=@tabid and related_tabid=@tabid2);
delimiter;

update ld_relatedlists_seq set id = (select max(relation_id) from ld_relatedlists);
select tabid into @tabid from ld_tab where `name` = 'ServiceContracts';
select tabid into @related_tabid from ld_tab where `name` = 'Project';
select id into @relation_id from ld_relatedlists_seq;
insert into LD_relatedlists(relation_id,tabid,related_tabid,name,sequence,label,presence,actions)
select @relation_id+1,@tabid,@related_tabid,'get_Project',1,'Project',0,'add' from dual
where not EXISTS(select 1 from LD_relatedlists  where related_tabid = @related_tabid and tabid = @tabid);
update ld_relatedlists_seq set id = (select max(relation_id) from ld_relatedlists);
delimiter;

DROP PROCEDURE IF EXISTS insertReader;
delimiter ||
CREATE PROCEDURE insertReader()
BEGIN
	SELECT DATABASE() INTO @tableschema;
	SET @tablename='ld_workreport';
	SET @colName=NULL;
  SET @columnname='reader';
	SET @tsql=CONCAT('select  IFNULL(column_name, '''') into @colName  from information_schema.columns where  TABLE_SCHEMA =','''',@tableschema,'''','  and
	table_name= ','''',@tablename,'''',' and COLUMN_NAME=','''',@columnname,'''');
	PREPARE stmt FROM @tsql;
	EXECUTE stmt;
    DEALLOCATE PREPARE stmt;
	SET @colinsert=IFNULL(@colName,'-1');
	IF @colinsert = 'reader' THEN

	insert into ld_workreport2user(workreportid,userid,user_type) select workreportid,reader,5 from ld_workreport;


	END IF;
END ||
delimiter;


DROP PROCEDURE IF EXISTS insertWorkreply;
delimiter ||
CREATE PROCEDURE insertWorkreply()

BEGIN
	SELECT DATABASE() INTO @tableschema;
	IF EXISTS (select 1 from information_schema.`TABLES` where TABLE_SCHEMA = @tableschema and TABLE_NAME = 'ld_workreportreader') then
		insert into ld_workreply(workreportid,text,replyuserid,createdtime,type)
		select workreportid,  content,userid,createdtime,1 from ld_workreportreader;

  END IF;
END ||
delimiter;

DROP PROCEDURE IF EXISTS insertWorkreply2user;
delimiter ||
CREATE PROCEDURE insertWorkreply2user()

BEGIN
	SELECT DATABASE() INTO @tableschema;
	IF EXISTS (select 1 from information_schema.`TABLES` where TABLE_SCHEMA = @tableschema and TABLE_NAME = 'ld_workreportreader2user') then
		insert into ld_workreply2user(workreplyid,userid,user_type)
		select workreportreaderid,userid,1 from ld_workreportreader2user;

	END IF;
END ||
delimiter;

ALTER TABLE LD_workreport ALTER COLUMN praisecount SET DEFAULT 0;
delimiter;

call AddColumn('LD_workreport','startdate','datetime','',NULL);
delimiter;

call AddColumn('LD_workreport','enddate','datetime','',NULL);
delimiter;

call AddColumn('LD_workreport','entitytype','varchar','50',null);
delimiter;

call AddColumn('LD_workreply','type','int','11',0);
delimiter;

update ld_workreport set entitytype = 'workreport' where entitytype is null or entitytype = '';
delimiter;

CALL insertReader();
delimiter;


CALL insertWorkreply();
delimiter;

DROP TABLE IF EXISTS ld_workreportreader2user;
delimiter;

DROP TABLE IF EXISTS LD_workreportreader;
delimiter;

CALL insertWorkreply2user();
delimiter;

DROP TABLE IF EXISTS ld_workreportreader2user;
delimiter;


insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'zh','ISNULL',
'为空值','fixedstr' from dual
where not EXISTS(select 1 from ld_desk  where languagetype='zh' and labelbol='ISNULL'
and Labeltype='fixedstr');

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'en','ISNULL',
'IS NULL','fixedstr' from dual
where not EXISTS(select 1 from ld_desk  where languagetype='en' and labelbol='ISNULL'
and Labeltype='fixedstr');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'zh','ISNOTNULL',
'不为空值','fixedstr' from dual
where not EXISTS(select 1 from ld_desk  where languagetype='zh' and labelbol='ISNOTNULL'
and Labeltype='fixedstr');

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'en','ISNOTNULL',
'IS NOT NULL','fixedstr' from dual
where not EXISTS(select 1 from ld_desk  where languagetype='en' and labelbol='ISNOTNULL'
and Labeltype='fixedstr');
delimiter;

UPDATE ld_field SET displaytype=4 WHERE  fieldname='approvestatus' AND  tabid=(SELECT tabid FROM ld_tab WHERE name='Project');
delimiter;

-- 2015-03-25

select max(fieldid) into @maxfieldid from ld_field ;
update ld_field_seq  set id=@maxfieldid;

select tabid into @tabid from ld_tab where name='Project';
select blockid into @blockid from ld_blocks where blocklabel='LBL_PROJECT_INFORMATION';
update ld_field_seq  set id=@maxfieldid+1 where not EXISTS(select 1 from ld_field where tabid=@tabid and columnname='smcreatorid');
insert into ld_field(tabid,columnname,tablename,generatedtype,uitype,fieldname,fieldlabel,readonly,presence,
defaultvalue,maximumlength,sequence,block,displaytype,typeofdata,quickcreate,quickcreatesequence,info_type,masseditable,fieldonly,
issmownerid,searchfieldtype,associatedfields,associatedsequence,callchecked)
select @tabid,'smcreatorid','LD_project',1,52,'smcreatorid','创建人',1,2,'',100,8,@blockid,2,'V~O',1,0,'BAS',1,0,0,1,1,0,0
from dual where not EXISTS(select 1 from ld_field where tabid=@tabid and columnname='smcreatorid');

select fieldid into @fieldid from ld_field where tabid=@tabid and COLUMNname='smcreatorid';
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'zh','LD_field',@tabid ,@fieldid, '创建人' from dual
where not EXISTS(select 1 from ld_tranlabel where languagetype='zh' and tabid=@tabid and relateid=@fieldid);

insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'en','LD_field',@tabid ,@fieldid, 'creator' from dual
where not EXISTS(select 1 from ld_tranlabel where languagetype='en' and tabid=@tabid and relateid=@fieldid);
delimiter;

select tabid into @tabid from ld_tab where name='ProjectTask';
select blockid into @blockid from ld_blocks where blocklabel='LBL_PROJECT_TASK_INFORMATION';
select max(fieldid) into @maxfieldid from ld_field ;
update ld_field_seq  set id=@maxfieldid+1 where not EXISTS(select 1 from ld_field where tabid=@tabid and columnname='smcreatorid');
insert into ld_field(tabid,columnname,tablename,generatedtype,uitype,fieldname,fieldlabel,readonly,presence,
defaultvalue,maximumlength,sequence,block,displaytype,typeofdata,quickcreate,quickcreatesequence,info_type,masseditable,fieldonly,
issmownerid,searchfieldtype,associatedfields,associatedsequence,callchecked)
select @tabid,'smcreatorid','LD_projecttask',1,52,'smcreatorid','创建人',1,2,'',100,8,@blockid,2,'V~O',1,0,'BAS',1,0,0,1,1,0,0
from dual where not EXISTS(select 1 from ld_field where tabid=@tabid and columnname='smcreatorid');

select fieldid into @fieldid from ld_field where tabid=@tabid and COLUMNname='smcreatorid';
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'zh','LD_field',@tabid ,@fieldid, '创建人' from dual
where not EXISTS(select 1 from ld_tranlabel where languagetype='zh' and tabid=@tabid and relateid=@fieldid);

insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'en','LD_field',@tabid ,@fieldid, 'creator' from dual
where not EXISTS(select 1 from ld_tranlabel where languagetype='en' and tabid=@tabid and relateid=@fieldid);
delimiter;

select tabid into @tabid from ld_tab where name='ProjectMilestone';
select blockid into @blockid from ld_blocks where blocklabel='LBL_PROJECT_MILESTONE_INFORMATION';
select max(fieldid) into @maxfieldid from ld_field ;
update ld_field_seq  set id=@maxfieldid+1 where not EXISTS(select 1 from ld_field where tabid=@tabid and columnname='smcreatorid');
insert into ld_field(tabid,columnname,tablename,generatedtype,uitype,fieldname,fieldlabel,readonly,presence,
defaultvalue,maximumlength,sequence,block,displaytype,typeofdata,quickcreate,quickcreatesequence,info_type,masseditable,fieldonly,
issmownerid,searchfieldtype,associatedfields,associatedsequence,callchecked)
select @tabid,'smcreatorid','LD_projectmilestone',1,52,'smcreatorid','创建人',1,2,'',100,8,@blockid,2,'V~O',1,0,'BAS',1,0,0,1,1,0,0
from dual where not EXISTS(select 1 from ld_field where tabid=@tabid and columnname='smcreatorid');

select fieldid into @fieldid from ld_field where tabid=@tabid and COLUMNname='smcreatorid';
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'zh','LD_field',@tabid ,@fieldid, '创建人' from dual
where not EXISTS(select 1 from ld_tranlabel where languagetype='zh' and tabid=@tabid and relateid=@fieldid);

insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'en','LD_field',@tabid ,@fieldid, 'creator' from dual
where not EXISTS(select 1 from ld_tranlabel where languagetype='en' and tabid=@tabid and relateid=@fieldid);
delimiter;
-- 2015-03-26

UPDATE ld_field SET displaytype=3 WHERE  fieldname='approvestatus' AND  tabid=(SELECT tabid FROM ld_tab WHERE name='Project');
delimiter;

update ld_desk set fieldlabel = '权限管理' where labelbol = 'LBL_ROLES' and languagetype = 'zh';
delimiter;
update ld_desk set fieldlabel = 'Privileges Management' where labelbol = 'LBL_ROLES' and languagetype = 'en';
delimiter;
update ld_desk set fieldlabel = '定义角色并为角色设置权限' where labelbol = 'LBL_ROLE_DESCRIPTION' and languagetype = 'zh';
delimiter;
update ld_desk set fieldlabel = 'Define and set permissions for the roles' where labelbol = '定义角色并为角色设置权限' and languagetype = 'en';
delimiter;
update ld_role set parentrole=CONCAT('H1::',roleid),depth=1 where roleid<>'H1';
delimiter;
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','OPERATIONAUTHORITY','操作权限','fixedstr' from dual
where not EXISTS(select 1 from ld_desk  where languagetype='zh' and labelbol='OPERATIONAUTHORITY' and Labeltype='fixedstr');
delimiter;
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','OPERATIONAUTHORITY','Operation Authority','fixedstr' from dual
where not EXISTS(select 1 from ld_desk  where languagetype='en' and labelbol='OPERATIONAUTHORITY' and Labeltype='fixedstr');
delimiter;
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','SETMEMBERS','设置成员','fixedstr' from dual
where not EXISTS(select 1 from ld_desk  where languagetype='zh' and labelbol='SETMEMBERS' and Labeltype='fixedstr');
delimiter;
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','SETMEMBERS','Set Members','fixedstr' from dual
where not EXISTS(select 1 from ld_desk  where languagetype='en' and labelbol='SETMEMBERS' and Labeltype='fixedstr');
delimiter;
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','LOCATION','定位','fixedstr' from dual
where not EXISTS(select 1 from ld_desk  where languagetype='zh' and labelbol='LOCATION' and Labeltype='fixedstr');
delimiter;
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','LOCATION','Location','fixedstr' from dual
where not EXISTS(select 1 from ld_desk  where languagetype='en' and labelbol='LOCATION' and Labeltype='fixedstr');
delimiter;
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','PLEASEINPUTYOUWANTTOFINDTHEUSER','请输入要查找的用户','fixedstr' from dual
where not EXISTS(select 1 from ld_desk  where languagetype='zh' and labelbol='PLEASEINPUTYOUWANTTOFINDTHEUSER' and Labeltype='fixedstr');
delimiter;
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','PLEASEINPUTYOUWANTTOFINDTHEUSER','Please input you want to find the user','fixedstr' from dual
where not EXISTS(select 1 from ld_desk  where languagetype='en' and labelbol='PLEASEINPUTYOUWANTTOFINDTHEUSER' and Labeltype='fixedstr');
delimiter;
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','PLEASEINPUTYOUWANTTOFINDTHEUSER','请输入要查找的用户','jspop' from dual
where not EXISTS(select 1 from ld_desk  where languagetype='zh' and labelbol='PLEASEINPUTYOUWANTTOFINDTHEUSER' and Labeltype='jspop');
delimiter;
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','PLEASEINPUTYOUWANTTOFINDTHEUSER','Please input you want to find the user','jspop' from dual
where not EXISTS(select 1 from ld_desk  where languagetype='en' and labelbol='PLEASEINPUTYOUWANTTOFINDTHEUSER' and Labeltype='jspop');
delimiter;
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','PLEASESELECTATLEASTONEMEMBER','请至少选择一位成员','jspop' from dual
where not EXISTS(select 1 from ld_desk  where languagetype='zh' and labelbol='PLEASESELECTATLEASTONEMEMBER' and Labeltype='jspop');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','PLEASESELECTATLEASTONEMEMBER','Please select at least one member','jspop' from dual
where not EXISTS(select 1 from ld_desk  where languagetype='en' and labelbol='PLEASESELECTATLEASTONEMEMBER' and Labeltype='jspop');
delimiter;

call AddColumn('LD_actionmapping','actionlabel','varchar','200',NULL);
delimiter;

update ld_actionmapping set actionlabel = 'SAVE' where actionid = 0 and actionname = 'Save' and (actionlabel is null or actionlabel='');
update ld_actionmapping set actionlabel = 'EDIT' where actionid = 1 and actionname = 'EditView' and (actionlabel is null or actionlabel='');
update ld_actionmapping set actionlabel = 'DELETE' where actionid = 2 and actionname = 'Delete' and (actionlabel is null or actionlabel='');
update ld_actionmapping set actionlabel = 'VIEW' where actionid = 4 and actionname = 'DetailView' and (actionlabel is null or actionlabel='');
update ld_actionmapping set actionlabel = 'IMPORT' where actionid = 5 and actionname = 'Import' and (actionlabel is null or actionlabel='');
update ld_actionmapping set actionlabel = 'EXPORT' where actionid = 6 and actionname = 'Export' and (actionlabel is null or actionlabel='');
update ld_actionmapping set actionlabel = 'FINDDUPLICATES' where actionid = 10 and actionname = 'DuplicatesHandling' and (actionlabel is null or actionlabel='');
update ld_actionmapping set actionlabel = 'CREATE' where actionid = 11 and actionname = 'Create' and (actionlabel is null or actionlabel='');
update ld_actionmapping set actionlabel = 'Merge' where actionid = 8 and actionname = 'Merge' and (actionlabel is null or actionlabel='');
update ld_actionmapping set actionlabel = 'ConvertLead' where actionid = 9 and actionname = 'ConvertLead' and (actionlabel is null or actionlabel='');


insert into ld_actionmapping(actionid,actionname,actionlabel,securitycheck)
select 12,'Copy','COPY',0 from dual
where not EXISTS(select 1 from ld_actionmapping  where actionid = 12); -- 8:合并  10 查重
delimiter;

insert into ld_actionmapping(actionid,actionname,actionlabel,securitycheck)
select 13,'Allocate','ALLOCATE',0 from dual
where not EXISTS(select 1 from ld_actionmapping  where actionid = 13);  -- 分配
delimiter;

insert into ld_actionmapping(actionid,actionname,actionlabel,securitycheck)
select 14,'Share','SHARE',0 from dual
where not EXISTS(select 1 from ld_actionmapping  where actionid = 14); -- 共享
delimiter;

insert into ld_actionmapping(actionid,actionname,actionlabel,securitycheck)
select 15,'WarehouseConfirmed','WAREHOUSECONFIRMED',0 from dual
where not EXISTS(select 1 from ld_actionmapping  where actionid = 15); --  入库确认
delimiter;
insert into ld_actionmapping(actionid,actionname,actionlabel,securitycheck)
select 16,'EndreturnGood','ENDRETURNGOODS',0 from dual
where not EXISTS(select 1 from ld_actionmapping  where actionid = 16); --  结束退货
delimiter;

insert into ld_actionmapping(actionid,actionname,actionlabel,securitycheck)
select 17,'Reteacement','RETRACEMENT',0 from dual
where not EXISTS(select 1 from ld_actionmapping  where actionid = 17); --  回撤
delimiter;
insert into ld_actionmapping(actionid,actionname,actionlabel,securitycheck)
select 18,'Checkout','Checkout',0 from dual
where not EXISTS(select 1 from ld_actionmapping  where actionid = 18); --  审核
delimiter;
insert into ld_actionmapping(actionid,actionname,actionlabel,securitycheck)
select 19,'ACheckout','ACheckout',0 from dual
where not EXISTS(select 1 from ld_actionmapping  where actionid = 19); --  反审核
delimiter;
insert into ld_actionmapping(actionid,actionname,actionlabel,securitycheck)
select 20,'Confirminventory','CONFIRMINVENTORY',0 from dual
where not EXISTS(select 1 from ld_actionmapping  where actionid = 20); --  确认盘点
delimiter;
insert into ld_actionmapping(actionid,actionname,actionlabel,securitycheck)
select 21,'RevocationInventory','REVOCATIONINVENTORY',0 from dual
where not EXISTS(select 1 from ld_actionmapping  where actionid = 21); --  撤销盘点
delimiter;

CREATE TABLE IF NOT EXISTS `ld_profileallpermission` (
  `tabid` int(11) NOT NULL DEFAULT '0',
  `operation` int(11) DEFAULT NULL,
	PRIMARY KEY (`tabid`,`operation`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
select tabid into @tabid from ld_tab where `name` = 'Accounts';
insert into LD_profileallpermission(tabid,operation)
select @tabid,3 from dual where not exists
(select 1 from LD_profileallpermission where tabid = @tabid and operation=3);
insert into LD_profileallpermission(tabid,operation)
select @tabid,4 from dual where not exists
(select 1 from LD_profileallpermission where tabid = @tabid and operation=4);
insert into LD_profileallpermission(tabid,operation)
select @tabid,11 from dual where not exists
(select 1 from LD_profileallpermission where tabid = @tabid and operation=11);
insert into LD_profileallpermission(tabid,operation)
select @tabid,1 from dual where not exists
(select 1 from LD_profileallpermission where tabid = @tabid and operation=1);
insert into LD_profileallpermission(tabid,operation)
select @tabid,2 from dual where not exists
(select 1 from LD_profileallpermission where tabid = @tabid and operation=2);
insert into LD_profileallpermission(tabid,operation)
select @tabid,12 from dual where not exists
(select 1 from LD_profileallpermission where tabid = @tabid and operation=12);
insert into LD_profileallpermission(tabid,operation)
select @tabid,13 from dual where not exists
(select 1 from LD_profileallpermission where tabid = @tabid and operation=13);
insert into LD_profileallpermission(tabid,operation)
select @tabid,14 from dual where not exists
(select 1 from LD_profileallpermission where tabid = @tabid and operation=14);
insert into LD_profileallpermission(tabid,operation)
select @tabid,5 from dual where not exists
(select 1 from LD_profileallpermission where tabid = @tabid and operation=5);
insert into LD_profileallpermission(tabid,operation)
select @tabid,6 from dual where not exists
(select 1 from LD_profileallpermission where tabid = @tabid and operation=6);
insert into LD_profileallpermission(tabid,operation)
select @tabid,10 from dual where not exists
(select 1 from LD_profileallpermission where tabid = @tabid and operation=10);
insert into LD_profileallpermission(tabid,operation)
select @tabid,8 from dual where not exists
(select 1 from LD_profileallpermission where tabid = @tabid and operation=8);
delimiter;

select tabid into @tabid from ld_tab where `name` = 'Contacts';
insert into LD_profileallpermission(tabid,operation)
select @tabid,3 from dual where not exists
(select 1 from LD_profileallpermission where tabid = @tabid and operation=3);
insert into LD_profileallpermission(tabid,operation)
select @tabid,4 from dual where not exists
(select 1 from LD_profileallpermission where tabid = @tabid and operation=4);
insert into LD_profileallpermission(tabid,operation)
select @tabid,11 from dual where not exists
(select 1 from LD_profileallpermission where tabid = @tabid and operation=11);
insert into LD_profileallpermission(tabid,operation)
select @tabid,1 from dual where not exists
(select 1 from LD_profileallpermission where tabid = @tabid and operation=1);
insert into LD_profileallpermission(tabid,operation)
select @tabid,2 from dual where not exists
(select 1 from LD_profileallpermission where tabid = @tabid and operation=2);
insert into LD_profileallpermission(tabid,operation)
select @tabid,12 from dual where not exists
(select 1 from LD_profileallpermission where tabid = @tabid and operation=12);
insert into LD_profileallpermission(tabid,operation)
select @tabid,13 from dual where not exists
(select 1 from LD_profileallpermission where tabid = @tabid and operation=13);
insert into LD_profileallpermission(tabid,operation)
select @tabid,14 from dual where not exists
(select 1 from LD_profileallpermission where tabid = @tabid and operation=14);
insert into LD_profileallpermission(tabid,operation)
select @tabid,5 from dual where not exists
(select 1 from LD_profileallpermission where tabid = @tabid and operation=5);
insert into LD_profileallpermission(tabid,operation)
select @tabid,6 from dual where not exists
(select 1 from LD_profileallpermission where tabid = @tabid and operation=6);
insert into LD_profileallpermission(tabid,operation)
select @tabid,10 from dual where not exists
(select 1 from LD_profileallpermission where tabid = @tabid and operation=10);
insert into LD_profileallpermission(tabid,operation)
select @tabid,8 from dual where not exists
(select 1 from LD_profileallpermission where tabid = @tabid and operation=8);
delimiter;

select tabid into @tabid from ld_tab where `name` = 'ContactRecords';
insert into LD_profileallpermission(tabid,operation)
select @tabid,3 from dual where not exists
(select 1 from LD_profileallpermission where tabid = @tabid and operation=3);
insert into LD_profileallpermission(tabid,operation)
select @tabid,4 from dual where not exists
(select 1 from LD_profileallpermission where tabid = @tabid and operation=4);
insert into LD_profileallpermission(tabid,operation)
select @tabid,11 from dual where not exists
(select 1 from LD_profileallpermission where tabid = @tabid and operation=11);
insert into LD_profileallpermission(tabid,operation)
select @tabid,1 from dual where not exists
(select 1 from LD_profileallpermission where tabid = @tabid and operation=1);
insert into LD_profileallpermission(tabid,operation)
select @tabid,2 from dual where not exists
(select 1 from LD_profileallpermission where tabid = @tabid and operation=2);
insert into LD_profileallpermission(tabid,operation)
select @tabid,12 from dual where not exists
(select 1 from LD_profileallpermission where tabid = @tabid and operation=12);
insert into LD_profileallpermission(tabid,operation)
select @tabid,13 from dual where not exists
(select 1 from LD_profileallpermission where tabid = @tabid and operation=13);
insert into LD_profileallpermission(tabid,operation)
select @tabid,14 from dual where not exists
(select 1 from LD_profileallpermission where tabid = @tabid and operation=14);
insert into LD_profileallpermission(tabid,operation)
select @tabid,5 from dual where not exists
(select 1 from LD_profileallpermission where tabid = @tabid and operation=5);
insert into LD_profileallpermission(tabid,operation)
select @tabid,6 from dual where not exists
(select 1 from LD_profileallpermission where tabid = @tabid and operation=6);
delimiter;

select tabid into @tabid from ld_tab where `name` = 'ServiceContracts';
insert into LD_profileallpermission(tabid,operation)
select @tabid,3 from dual where not exists
(select 1 from LD_profileallpermission where tabid = @tabid and operation=3);
insert into LD_profileallpermission(tabid,operation)
select @tabid,4 from dual where not exists
(select 1 from LD_profileallpermission where tabid = @tabid and operation=4);
insert into LD_profileallpermission(tabid,operation)
select @tabid,11 from dual where not exists
(select 1 from LD_profileallpermission where tabid = @tabid and operation=11);
insert into LD_profileallpermission(tabid,operation)
select @tabid,1 from dual where not exists
(select 1 from LD_profileallpermission where tabid = @tabid and operation=1);
insert into LD_profileallpermission(tabid,operation)
select @tabid,2 from dual where not exists
(select 1 from LD_profileallpermission where tabid = @tabid and operation=2);
insert into LD_profileallpermission(tabid,operation)
select @tabid,12 from dual where not exists
(select 1 from LD_profileallpermission where tabid = @tabid and operation=12);
insert into LD_profileallpermission(tabid,operation)
select @tabid,13 from dual where not exists
(select 1 from LD_profileallpermission where tabid = @tabid and operation=13);
insert into LD_profileallpermission(tabid,operation)
select @tabid,14 from dual where not exists
(select 1 from LD_profileallpermission where tabid = @tabid and operation=14);
insert into LD_profileallpermission(tabid,operation)
select @tabid,5 from dual where not exists
(select 1 from LD_profileallpermission where tabid = @tabid and operation=5);
insert into LD_profileallpermission(tabid,operation)
select @tabid,6 from dual where not exists
(select 1 from LD_profileallpermission where tabid = @tabid and operation=6);
delimiter;

select tabid into @tabid from ld_tab where `name` = 'HelpDesk';
insert into LD_profileallpermission(tabid,operation)
select @tabid,3 from dual where not exists
(select 1 from LD_profileallpermission where tabid = @tabid and operation=3);
insert into LD_profileallpermission(tabid,operation)
select @tabid,4 from dual where not exists
(select 1 from LD_profileallpermission where tabid = @tabid and operation=4);
insert into LD_profileallpermission(tabid,operation)
select @tabid,11 from dual where not exists
(select 1 from LD_profileallpermission where tabid = @tabid and operation=11);
insert into LD_profileallpermission(tabid,operation)
select @tabid,1 from dual where not exists
(select 1 from LD_profileallpermission where tabid = @tabid and operation=1);
insert into LD_profileallpermission(tabid,operation)
select @tabid,2 from dual where not exists
(select 1 from LD_profileallpermission where tabid = @tabid and operation=2);
insert into LD_profileallpermission(tabid,operation)
select @tabid,12 from dual where not exists
(select 1 from LD_profileallpermission where tabid = @tabid and operation=12);
insert into LD_profileallpermission(tabid,operation)
select @tabid,13 from dual where not exists
(select 1 from LD_profileallpermission where tabid = @tabid and operation=13);
insert into LD_profileallpermission(tabid,operation)
select @tabid,14 from dual where not exists
(select 1 from LD_profileallpermission where tabid = @tabid and operation=14);
insert into LD_profileallpermission(tabid,operation)
select @tabid,6 from dual where not exists
(select 1 from LD_profileallpermission where tabid = @tabid and operation=6);
delimiter;

select tabid into @tabid from ld_tab where `name` = 'ServiceCharge';
insert into LD_profileallpermission(tabid,operation)
select @tabid,3 from dual where not exists
(select 1 from LD_profileallpermission where tabid = @tabid and operation=3);
insert into LD_profileallpermission(tabid,operation)
select @tabid,4 from dual where not exists
(select 1 from LD_profileallpermission where tabid = @tabid and operation=4);
insert into LD_profileallpermission(tabid,operation)
select @tabid,11 from dual where not exists
(select 1 from LD_profileallpermission where tabid = @tabid and operation=11);
insert into LD_profileallpermission(tabid,operation)
select @tabid,1 from dual where not exists
(select 1 from LD_profileallpermission where tabid = @tabid and operation=1);
insert into LD_profileallpermission(tabid,operation)
select @tabid,2 from dual where not exists
(select 1 from LD_profileallpermission where tabid = @tabid and operation=2);
insert into LD_profileallpermission(tabid,operation)
select @tabid,12 from dual where not exists
(select 1 from LD_profileallpermission where tabid = @tabid and operation=12);
insert into LD_profileallpermission(tabid,operation)
select @tabid,13 from dual where not exists
(select 1 from LD_profileallpermission where tabid = @tabid and operation=13);
insert into LD_profileallpermission(tabid,operation)
select @tabid,14 from dual where not exists
(select 1 from LD_profileallpermission where tabid = @tabid and operation=14);
insert into LD_profileallpermission(tabid,operation)
select @tabid,6 from dual where not exists
(select 1 from LD_profileallpermission where tabid = @tabid and operation=6);
insert into LD_profileallpermission(tabid,operation)
select @tabid,10 from dual where not exists
(select 1 from LD_profileallpermission where tabid = @tabid and operation=10);
insert into LD_profileallpermission(tabid,operation)
select @tabid,8 from dual where not exists
(select 1 from LD_profileallpermission where tabid = @tabid and operation=8);
delimiter;

select tabid into @tabid from ld_tab where `name` = 'ReportLog';
insert into LD_profileallpermission(tabid,operation)
select @tabid,3 from dual where not exists
(select 1 from LD_profileallpermission where tabid = @tabid and operation=3);
delimiter;

select tabid into @tabid from ld_tab where `name` = 'Calendar';
insert into LD_profileallpermission(tabid,operation)
select @tabid,3 from dual where not exists
(select 1 from LD_profileallpermission where tabid = @tabid and operation=3);
insert into LD_profileallpermission(tabid,operation)
select @tabid,4 from dual where not exists
(select 1 from LD_profileallpermission where tabid = @tabid and operation=4);
insert into LD_profileallpermission(tabid,operation)
select @tabid,11 from dual where not exists
(select 1 from LD_profileallpermission where tabid = @tabid and operation=11);
insert into LD_profileallpermission(tabid,operation)
select @tabid,1 from dual where not exists
(select 1 from LD_profileallpermission where tabid = @tabid and operation=1);
insert into LD_profileallpermission(tabid,operation)
select @tabid,2 from dual where not exists
(select 1 from LD_profileallpermission where tabid = @tabid and operation=2);
insert into LD_profileallpermission(tabid,operation)
select @tabid,12 from dual where not exists
(select 1 from LD_profileallpermission where tabid = @tabid and operation=12);
insert into LD_profileallpermission(tabid,operation)
select @tabid,13 from dual where not exists
(select 1 from LD_profileallpermission where tabid = @tabid and operation=13);
insert into LD_profileallpermission(tabid,operation)
select @tabid,14 from dual where not exists
(select 1 from LD_profileallpermission where tabid = @tabid and operation=14);
insert into LD_profileallpermission(tabid,operation)
select @tabid,6 from dual where not exists
(select 1 from LD_profileallpermission where tabid = @tabid and operation=6);
delimiter;

select tabid into @tabid from ld_tab where `name` = 'Documents';
insert into LD_profileallpermission(tabid,operation)
select @tabid,3 from dual where not exists
(select 1 from LD_profileallpermission where tabid = @tabid and operation=3);
insert into LD_profileallpermission(tabid,operation)
select @tabid,4 from dual where not exists
(select 1 from LD_profileallpermission where tabid = @tabid and operation=4);
insert into LD_profileallpermission(tabid,operation)
select @tabid,11 from dual where not exists
(select 1 from LD_profileallpermission where tabid = @tabid and operation=11);
insert into LD_profileallpermission(tabid,operation)
select @tabid,1 from dual where not exists
(select 1 from LD_profileallpermission where tabid = @tabid and operation=1);
insert into LD_profileallpermission(tabid,operation)
select @tabid,2 from dual where not exists
(select 1 from LD_profileallpermission where tabid = @tabid and operation=2);
insert into LD_profileallpermission(tabid,operation)
select @tabid,13 from dual where not exists
(select 1 from LD_profileallpermission where tabid = @tabid and operation=13);
insert into LD_profileallpermission(tabid,operation)
select @tabid,14 from dual where not exists
(select 1 from LD_profileallpermission where tabid = @tabid and operation=14);
insert into LD_profileallpermission(tabid,operation)
select @tabid,6 from dual where not exists
(select 1 from LD_profileallpermission where tabid = @tabid and operation=6);
delimiter;

select tabid into @tabid from ld_tab where `name` = 'Emails';
insert into LD_profileallpermission(tabid,operation)
select @tabid,3 from dual where not exists
(select 1 from LD_profileallpermission where tabid = @tabid and operation=3);
delimiter;

select tabid into @tabid from ld_tab where `name` = 'Faq';
insert into LD_profileallpermission(tabid,operation)
select @tabid,3 from dual where not exists
(select 1 from LD_profileallpermission where tabid = @tabid and operation=3);
insert into LD_profileallpermission(tabid,operation)
select @tabid,4 from dual where not exists
(select 1 from LD_profileallpermission where tabid = @tabid and operation=4);
insert into LD_profileallpermission(tabid,operation)
select @tabid,11 from dual where not exists
(select 1 from LD_profileallpermission where tabid = @tabid and operation=11);
insert into LD_profileallpermission(tabid,operation)
select @tabid,1 from dual where not exists
(select 1 from LD_profileallpermission where tabid = @tabid and operation=1);
insert into LD_profileallpermission(tabid,operation)
select @tabid,2 from dual where not exists
(select 1 from LD_profileallpermission where tabid = @tabid and operation=2);
insert into LD_profileallpermission(tabid,operation)
select @tabid,12 from dual where not exists
(select 1 from LD_profileallpermission where tabid = @tabid and operation=12);
insert into LD_profileallpermission(tabid,operation)
select @tabid,13 from dual where not exists
(select 1 from LD_profileallpermission where tabid = @tabid and operation=13);
insert into LD_profileallpermission(tabid,operation)
select @tabid,14 from dual where not exists
(select 1 from LD_profileallpermission where tabid = @tabid and operation=14);
insert into LD_profileallpermission(tabid,operation)
select @tabid,6 from dual where not exists
(select 1 from LD_profileallpermission where tabid = @tabid and operation=6);
delimiter;

select tabid into @tabid from ld_tab where `name` = 'Campaigns';
insert into LD_profileallpermission(tabid,operation)
select @tabid,3 from dual where not exists
(select 1 from LD_profileallpermission where tabid = @tabid and operation=3);
insert into LD_profileallpermission(tabid,operation)
select @tabid,4 from dual where not exists
(select 1 from LD_profileallpermission where tabid = @tabid and operation=4);
insert into LD_profileallpermission(tabid,operation)
select @tabid,11 from dual where not exists
(select 1 from LD_profileallpermission where tabid = @tabid and operation=11);
insert into LD_profileallpermission(tabid,operation)
select @tabid,1 from dual where not exists
(select 1 from LD_profileallpermission where tabid = @tabid and operation=1);
insert into LD_profileallpermission(tabid,operation)
select @tabid,2 from dual where not exists
(select 1 from LD_profileallpermission where tabid = @tabid and operation=2);
insert into LD_profileallpermission(tabid,operation)
select @tabid,12 from dual where not exists
(select 1 from LD_profileallpermission where tabid = @tabid and operation=12);
insert into LD_profileallpermission(tabid,operation)
select @tabid,13 from dual where not exists
(select 1 from LD_profileallpermission where tabid = @tabid and operation=13);
insert into LD_profileallpermission(tabid,operation)
select @tabid,14 from dual where not exists
(select 1 from LD_profileallpermission where tabid = @tabid and operation=14);
insert into LD_profileallpermission(tabid,operation)
select @tabid,6 from dual where not exists
(select 1 from LD_profileallpermission where tabid = @tabid and operation=6);
delimiter;

select tabid into @tabid from ld_tab where `name` = 'MassSMS';
insert into LD_profileallpermission(tabid,operation)
select @tabid,3 from dual where not exists
(select 1 from LD_profileallpermission where tabid = @tabid and operation=3);
delimiter;

select tabid into @tabid from ld_tab where `name` = 'MassEmails';
insert into LD_profileallpermission(tabid,operation)
select @tabid,3 from dual where not exists
(select 1 from LD_profileallpermission where tabid = @tabid and operation=3);
delimiter;

select tabid into @tabid from ld_tab where `name` = 'SmsPhrases';
insert into LD_profileallpermission(tabid,operation)
select @tabid,3 from dual where not exists
(select 1 from LD_profileallpermission where tabid = @tabid and operation=3);
delimiter;

select tabid into @tabid from ld_tab where `name` = 'EmailListtmp';
insert into LD_profileallpermission(tabid,operation)
select @tabid,3 from dual where not exists
(select 1 from LD_profileallpermission where tabid = @tabid and operation=3);
delimiter;

select tabid into @tabid from ld_tab where `name` = 'CommunicationLog';
insert into LD_profileallpermission(tabid,operation)
select @tabid,3 from dual where not exists
(select 1 from LD_profileallpermission where tabid = @tabid and operation=3);
delimiter;

select tabid into @tabid from ld_tab where `name` = 'Potentials';
insert into LD_profileallpermission(tabid,operation)
select @tabid,3 from dual where not exists
(select 1 from LD_profileallpermission where tabid = @tabid and operation=3);
insert into LD_profileallpermission(tabid,operation)
select @tabid,4 from dual where not exists
(select 1 from LD_profileallpermission where tabid = @tabid and operation=4);
insert into LD_profileallpermission(tabid,operation)
select @tabid,11 from dual where not exists
(select 1 from LD_profileallpermission where tabid = @tabid and operation=11);
insert into LD_profileallpermission(tabid,operation)
select @tabid,1 from dual where not exists
(select 1 from LD_profileallpermission where tabid = @tabid and operation=1);
insert into LD_profileallpermission(tabid,operation)
select @tabid,2 from dual where not exists
(select 1 from LD_profileallpermission where tabid = @tabid and operation=2);
insert into LD_profileallpermission(tabid,operation)
select @tabid,12 from dual where not exists
(select 1 from LD_profileallpermission where tabid = @tabid and operation=12);
insert into LD_profileallpermission(tabid,operation)
select @tabid,13 from dual where not exists
(select 1 from LD_profileallpermission where tabid = @tabid and operation=13);
insert into LD_profileallpermission(tabid,operation)
select @tabid,14 from dual where not exists
(select 1 from LD_profileallpermission where tabid = @tabid and operation=14);
insert into LD_profileallpermission(tabid,operation)
select @tabid,5 from dual where not exists
(select 1 from LD_profileallpermission where tabid = @tabid and operation=5);
insert into LD_profileallpermission(tabid,operation)
select @tabid,6 from dual where not exists
(select 1 from LD_profileallpermission where tabid = @tabid and operation=6);
delimiter;

select tabid into @tabid from ld_tab where `name` = 'Quotes';
insert into LD_profileallpermission(tabid,operation)
select @tabid,3 from dual where not exists
(select 1 from LD_profileallpermission where tabid = @tabid and operation=3);
insert into LD_profileallpermission(tabid,operation)
select @tabid,4 from dual where not exists
(select 1 from LD_profileallpermission where tabid = @tabid and operation=4);
insert into LD_profileallpermission(tabid,operation)
select @tabid,11 from dual where not exists
(select 1 from LD_profileallpermission where tabid = @tabid and operation=11);
insert into LD_profileallpermission(tabid,operation)
select @tabid,1 from dual where not exists
(select 1 from LD_profileallpermission where tabid = @tabid and operation=1);
insert into LD_profileallpermission(tabid,operation)
select @tabid,2 from dual where not exists
(select 1 from LD_profileallpermission where tabid = @tabid and operation=2);
insert into LD_profileallpermission(tabid,operation)
select @tabid,12 from dual where not exists
(select 1 from LD_profileallpermission where tabid = @tabid and operation=12);
insert into LD_profileallpermission(tabid,operation)
select @tabid,13 from dual where not exists
(select 1 from LD_profileallpermission where tabid = @tabid and operation=13);
insert into LD_profileallpermission(tabid,operation)
select @tabid,14 from dual where not exists
(select 1 from LD_profileallpermission where tabid = @tabid and operation=14);
insert into LD_profileallpermission(tabid,operation)
select @tabid,5 from dual where not exists
(select 1 from LD_profileallpermission where tabid = @tabid and operation=5);
insert into LD_profileallpermission(tabid,operation)
select @tabid,6 from dual where not exists
(select 1 from LD_profileallpermission where tabid = @tabid and operation=6);
delimiter;

select tabid into @tabid from ld_tab where `name` = 'SalesOrder';
insert into LD_profileallpermission(tabid,operation)
select @tabid,3 from dual where not exists
(select 1 from LD_profileallpermission where tabid = @tabid and operation=3);
insert into LD_profileallpermission(tabid,operation)
select @tabid,4 from dual where not exists
(select 1 from LD_profileallpermission where tabid = @tabid and operation=4);
insert into LD_profileallpermission(tabid,operation)
select @tabid,11 from dual where not exists
(select 1 from LD_profileallpermission where tabid = @tabid and operation=11);
insert into LD_profileallpermission(tabid,operation)
select @tabid,1 from dual where not exists
(select 1 from LD_profileallpermission where tabid = @tabid and operation=1);
insert into LD_profileallpermission(tabid,operation)
select @tabid,2 from dual where not exists
(select 1 from LD_profileallpermission where tabid = @tabid and operation=2);
insert into LD_profileallpermission(tabid,operation)
select @tabid,12 from dual where not exists
(select 1 from LD_profileallpermission where tabid = @tabid and operation=12);
insert into LD_profileallpermission(tabid,operation)
select @tabid,13 from dual where not exists
(select 1 from LD_profileallpermission where tabid = @tabid and operation=13);
insert into LD_profileallpermission(tabid,operation)
select @tabid,14 from dual where not exists
(select 1 from LD_profileallpermission where tabid = @tabid and operation=14);
insert into LD_profileallpermission(tabid,operation)
select @tabid,5 from dual where not exists
(select 1 from LD_profileallpermission where tabid = @tabid and operation=5);
insert into LD_profileallpermission(tabid,operation)
select @tabid,6 from dual where not exists
(select 1 from LD_profileallpermission where tabid = @tabid and operation=6);
delimiter;

select tabid into @tabid from ld_tab where `name` = 'SalesBack';
insert into LD_profileallpermission(tabid,operation)
select @tabid,3 from dual where not exists
(select 1 from LD_profileallpermission where tabid = @tabid and operation=3);
insert into LD_profileallpermission(tabid,operation)
select @tabid,4 from dual where not exists
(select 1 from LD_profileallpermission where tabid = @tabid and operation=4);
insert into LD_profileallpermission(tabid,operation)
select @tabid,1 from dual where not exists
(select 1 from LD_profileallpermission where tabid = @tabid and operation=1);
insert into LD_profileallpermission(tabid,operation)
select @tabid,2 from dual where not exists
(select 1 from LD_profileallpermission where tabid = @tabid and operation=2);
insert into LD_profileallpermission(tabid,operation)
select @tabid,13 from dual where not exists
(select 1 from LD_profileallpermission where tabid = @tabid and operation=13);
insert into LD_profileallpermission(tabid,operation)
select @tabid,14 from dual where not exists
(select 1 from LD_profileallpermission where tabid = @tabid and operation=14);
insert into LD_profileallpermission(tabid,operation)
select @tabid,15 from dual where not exists
(select 1 from LD_profileallpermission where tabid = @tabid and operation=15);
insert into LD_profileallpermission(tabid,operation)
select @tabid,16 from dual where not exists
(select 1 from LD_profileallpermission where tabid = @tabid and operation=16);
insert into LD_profileallpermission(tabid,operation)
select @tabid,17 from dual where not exists
(select 1 from LD_profileallpermission where tabid = @tabid and operation=17);
insert into LD_profileallpermission(tabid,operation)
select @tabid,6 from dual where not exists
(select 1 from LD_profileallpermission where tabid = @tabid and operation=6);
delimiter;

select tabid into @tabid from ld_tab where `name` = 'Vendors';
insert into LD_profileallpermission(tabid,operation)
select @tabid,3 from dual where not exists
(select 1 from LD_profileallpermission where tabid = @tabid and operation=3);
insert into LD_profileallpermission(tabid,operation)
select @tabid,4 from dual where not exists
(select 1 from LD_profileallpermission where tabid = @tabid and operation=4);
insert into LD_profileallpermission(tabid,operation)
select @tabid,11 from dual where not exists
(select 1 from LD_profileallpermission where tabid = @tabid and operation=11);
insert into LD_profileallpermission(tabid,operation)
select @tabid,1 from dual where not exists
(select 1 from LD_profileallpermission where tabid = @tabid and operation=1);
insert into LD_profileallpermission(tabid,operation)
select @tabid,2 from dual where not exists
(select 1 from LD_profileallpermission where tabid = @tabid and operation=2);
insert into LD_profileallpermission(tabid,operation)
select @tabid,12 from dual where not exists
(select 1 from LD_profileallpermission where tabid = @tabid and operation=12);
insert into LD_profileallpermission(tabid,operation)
select @tabid,13 from dual where not exists
(select 1 from LD_profileallpermission where tabid = @tabid and operation=13);
insert into LD_profileallpermission(tabid,operation)
select @tabid,14 from dual where not exists
(select 1 from LD_profileallpermission where tabid = @tabid and operation=14);
insert into LD_profileallpermission(tabid,operation)
select @tabid,5 from dual where not exists
(select 1 from LD_profileallpermission where tabid = @tabid and operation=5);
insert into LD_profileallpermission(tabid,operation)
select @tabid,6 from dual where not exists
(select 1 from LD_profileallpermission where tabid = @tabid and operation=6);
insert into LD_profileallpermission(tabid,operation)
select @tabid,10 from dual where not exists
(select 1 from LD_profileallpermission where tabid = @tabid and operation=10);
insert into LD_profileallpermission(tabid,operation)
select @tabid,8 from dual where not exists
(select 1 from LD_profileallpermission where tabid = @tabid and operation=8);
delimiter;
select tabid into @tabid from ld_tab where `name` = 'PurchaseOrder';
insert into LD_profileallpermission(tabid,operation)
select @tabid,3 from dual where not exists
(select 1 from LD_profileallpermission where tabid = @tabid and operation=3);
insert into LD_profileallpermission(tabid,operation)
select @tabid,4 from dual where not exists
(select 1 from LD_profileallpermission where tabid = @tabid and operation=4);
insert into LD_profileallpermission(tabid,operation)
select @tabid,11 from dual where not exists
(select 1 from LD_profileallpermission where tabid = @tabid and operation=11);
insert into LD_profileallpermission(tabid,operation)
select @tabid,1 from dual where not exists
(select 1 from LD_profileallpermission where tabid = @tabid and operation=1);
insert into LD_profileallpermission(tabid,operation)
select @tabid,2 from dual where not exists
(select 1 from LD_profileallpermission where tabid = @tabid and operation=2);
insert into LD_profileallpermission(tabid,operation)
select @tabid,12 from dual where not exists
(select 1 from LD_profileallpermission where tabid = @tabid and operation=12);
insert into LD_profileallpermission(tabid,operation)
select @tabid,13 from dual where not exists
(select 1 from LD_profileallpermission where tabid = @tabid and operation=13);
insert into LD_profileallpermission(tabid,operation)
select @tabid,14 from dual where not exists
(select 1 from LD_profileallpermission where tabid = @tabid and operation=14);
insert into LD_profileallpermission(tabid,operation)
select @tabid,5 from dual where not exists
(select 1 from LD_profileallpermission where tabid = @tabid and operation=5);
insert into LD_profileallpermission(tabid,operation)
select @tabid,6 from dual where not exists
(select 1 from LD_profileallpermission where tabid = @tabid and operation=6);
delimiter;

select tabid into @tabid from ld_tab where `name` = 'PurchaseBack';
insert into LD_profileallpermission(tabid,operation)
select @tabid,3 from dual where not exists
(select 1 from LD_profileallpermission where tabid = @tabid and operation=3);
insert into LD_profileallpermission(tabid,operation)
select @tabid,4 from dual where not exists
(select 1 from LD_profileallpermission where tabid = @tabid and operation=4);
insert into LD_profileallpermission(tabid,operation)
select @tabid,1 from dual where not exists
(select 1 from LD_profileallpermission where tabid = @tabid and operation=1);
insert into LD_profileallpermission(tabid,operation)
select @tabid,2 from dual where not exists
(select 1 from LD_profileallpermission where tabid = @tabid and operation=2);
insert into LD_profileallpermission(tabid,operation)
select @tabid,13 from dual where not exists
(select 1 from LD_profileallpermission where tabid = @tabid and operation=13);
insert into LD_profileallpermission(tabid,operation)
select @tabid,14 from dual where not exists
(select 1 from LD_profileallpermission where tabid = @tabid and operation=14);
insert into LD_profileallpermission(tabid,operation)
select @tabid,15 from dual where not exists
(select 1 from LD_profileallpermission where tabid = @tabid and operation=15);
insert into LD_profileallpermission(tabid,operation)
select @tabid,16 from dual where not exists
(select 1 from LD_profileallpermission where tabid = @tabid and operation=16);
insert into LD_profileallpermission(tabid,operation)
select @tabid,17 from dual where not exists
(select 1 from LD_profileallpermission where tabid = @tabid and operation=17);
insert into LD_profileallpermission(tabid,operation)
select @tabid,6 from dual where not exists
(select 1 from LD_profileallpermission where tabid = @tabid and operation=6);
delimiter;

select tabid into @tabid from ld_tab where `name` = 'VendorContact';
insert into LD_profileallpermission(tabid,operation)
select @tabid,3 from dual where not exists
(select 1 from LD_profileallpermission where tabid = @tabid and operation=3);
insert into LD_profileallpermission(tabid,operation)
select @tabid,4 from dual where not exists
(select 1 from LD_profileallpermission where tabid = @tabid and operation=4);
insert into LD_profileallpermission(tabid,operation)
select @tabid,11 from dual where not exists
(select 1 from LD_profileallpermission where tabid = @tabid and operation=11);
insert into LD_profileallpermission(tabid,operation)
select @tabid,1 from dual where not exists
(select 1 from LD_profileallpermission where tabid = @tabid and operation=1);
insert into LD_profileallpermission(tabid,operation)
select @tabid,2 from dual where not exists
(select 1 from LD_profileallpermission where tabid = @tabid and operation=2);
insert into LD_profileallpermission(tabid,operation)
select @tabid,12 from dual where not exists
(select 1 from LD_profileallpermission where tabid = @tabid and operation=12);
insert into LD_profileallpermission(tabid,operation)
select @tabid,13 from dual where not exists
(select 1 from LD_profileallpermission where tabid = @tabid and operation=13);
insert into LD_profileallpermission(tabid,operation)
select @tabid,14 from dual where not exists
(select 1 from LD_profileallpermission where tabid = @tabid and operation=14);
insert into LD_profileallpermission(tabid,operation)
select @tabid,5 from dual where not exists
(select 1 from LD_profileallpermission where tabid = @tabid and operation=5);
insert into LD_profileallpermission(tabid,operation)
select @tabid,6 from dual where not exists
(select 1 from LD_profileallpermission where tabid = @tabid and operation=6);
insert into LD_profileallpermission(tabid,operation)
select @tabid,10 from dual where not exists
(select 1 from LD_profileallpermission where tabid = @tabid and operation=10);
insert into LD_profileallpermission(tabid,operation)
select @tabid,8 from dual where not exists
(select 1 from LD_profileallpermission where tabid = @tabid and operation=8);
delimiter;

select tabid into @tabid from ld_tab where `name` = 'VendorContactRecords';
insert into LD_profileallpermission(tabid,operation)
select @tabid,3 from dual where not exists
(select 1 from LD_profileallpermission where tabid = @tabid and operation=3);
insert into LD_profileallpermission(tabid,operation)
select @tabid,4 from dual where not exists
(select 1 from LD_profileallpermission where tabid = @tabid and operation=4);
insert into LD_profileallpermission(tabid,operation)
select @tabid,11 from dual where not exists
(select 1 from LD_profileallpermission where tabid = @tabid and operation=11);
insert into LD_profileallpermission(tabid,operation)
select @tabid,1 from dual where not exists
(select 1 from LD_profileallpermission where tabid = @tabid and operation=1);
insert into LD_profileallpermission(tabid,operation)
select @tabid,2 from dual where not exists
(select 1 from LD_profileallpermission where tabid = @tabid and operation=2);
insert into LD_profileallpermission(tabid,operation)
select @tabid,12 from dual where not exists
(select 1 from LD_profileallpermission where tabid = @tabid and operation=12);
insert into LD_profileallpermission(tabid,operation)
select @tabid,13 from dual where not exists
(select 1 from LD_profileallpermission where tabid = @tabid and operation=13);
insert into LD_profileallpermission(tabid,operation)
select @tabid,14 from dual where not exists
(select 1 from LD_profileallpermission where tabid = @tabid and operation=14);
insert into LD_profileallpermission(tabid,operation)
select @tabid,5 from dual where not exists
(select 1 from LD_profileallpermission where tabid = @tabid and operation=5);
insert into LD_profileallpermission(tabid,operation)
select @tabid,6 from dual where not exists
(select 1 from LD_profileallpermission where tabid = @tabid and operation=6);
delimiter;

select tabid into @tabid from ld_tab where `name` = 'Project';
insert into LD_profileallpermission(tabid,operation)
select @tabid,3 from dual where not exists
(select 1 from LD_profileallpermission where tabid = @tabid and operation=3);
insert into LD_profileallpermission(tabid,operation)
select @tabid,4 from dual where not exists
(select 1 from LD_profileallpermission where tabid = @tabid and operation=4);
insert into LD_profileallpermission(tabid,operation)
select @tabid,11 from dual where not exists
(select 1 from LD_profileallpermission where tabid = @tabid and operation=11);
insert into LD_profileallpermission(tabid,operation)
select @tabid,1 from dual where not exists
(select 1 from LD_profileallpermission where tabid = @tabid and operation=1);
insert into LD_profileallpermission(tabid,operation)
select @tabid,2 from dual where not exists
(select 1 from LD_profileallpermission where tabid = @tabid and operation=2);
insert into LD_profileallpermission(tabid,operation)
select @tabid,12 from dual where not exists
(select 1 from LD_profileallpermission where tabid = @tabid and operation=12);
insert into LD_profileallpermission(tabid,operation)
select @tabid,13 from dual where not exists
(select 1 from LD_profileallpermission where tabid = @tabid and operation=13);
insert into LD_profileallpermission(tabid,operation)
select @tabid,14 from dual where not exists
(select 1 from LD_profileallpermission where tabid = @tabid and operation=14);
insert into LD_profileallpermission(tabid,operation)
select @tabid,5 from dual where not exists
(select 1 from LD_profileallpermission where tabid = @tabid and operation=5);
insert into LD_profileallpermission(tabid,operation)
select @tabid,6 from dual where not exists
(select 1 from LD_profileallpermission where tabid = @tabid and operation=6);
delimiter;

select tabid into @tabid from ld_tab where `name` = 'ProjectTask';
insert into LD_profileallpermission(tabid,operation)
select @tabid,3 from dual where not exists
(select 1 from LD_profileallpermission where tabid = @tabid and operation=3);
insert into LD_profileallpermission(tabid,operation)
select @tabid,4 from dual where not exists
(select 1 from LD_profileallpermission where tabid = @tabid and operation=4);
insert into LD_profileallpermission(tabid,operation)
select @tabid,11 from dual where not exists
(select 1 from LD_profileallpermission where tabid = @tabid and operation=11);
insert into LD_profileallpermission(tabid,operation)
select @tabid,1 from dual where not exists
(select 1 from LD_profileallpermission where tabid = @tabid and operation=1);
insert into LD_profileallpermission(tabid,operation)
select @tabid,2 from dual where not exists
(select 1 from LD_profileallpermission where tabid = @tabid and operation=2);
insert into LD_profileallpermission(tabid,operation)
select @tabid,12 from dual where not exists
(select 1 from LD_profileallpermission where tabid = @tabid and operation=12);
insert into LD_profileallpermission(tabid,operation)
select @tabid,13 from dual where not exists
(select 1 from LD_profileallpermission where tabid = @tabid and operation=13);
insert into LD_profileallpermission(tabid,operation)
select @tabid,14 from dual where not exists
(select 1 from LD_profileallpermission where tabid = @tabid and operation=14);
insert into LD_profileallpermission(tabid,operation)
select @tabid,5 from dual where not exists
(select 1 from LD_profileallpermission where tabid = @tabid and operation=5);
insert into LD_profileallpermission(tabid,operation)
select @tabid,6 from dual where not exists
(select 1 from LD_profileallpermission where tabid = @tabid and operation=6);
delimiter;

select tabid into @tabid from ld_tab where `name` = 'ProjectMilestone';
insert into LD_profileallpermission(tabid,operation)
select @tabid,3 from dual where not exists
(select 1 from LD_profileallpermission where tabid = @tabid and operation=3);
insert into LD_profileallpermission(tabid,operation)
select @tabid,4 from dual where not exists
(select 1 from LD_profileallpermission where tabid = @tabid and operation=4);
insert into LD_profileallpermission(tabid,operation)
select @tabid,11 from dual where not exists
(select 1 from LD_profileallpermission where tabid = @tabid and operation=11);
insert into LD_profileallpermission(tabid,operation)
select @tabid,1 from dual where not exists
(select 1 from LD_profileallpermission where tabid = @tabid and operation=1);
insert into LD_profileallpermission(tabid,operation)
select @tabid,2 from dual where not exists
(select 1 from LD_profileallpermission where tabid = @tabid and operation=2);
insert into LD_profileallpermission(tabid,operation)
select @tabid,12 from dual where not exists
(select 1 from LD_profileallpermission where tabid = @tabid and operation=12);
insert into LD_profileallpermission(tabid,operation)
select @tabid,13 from dual where not exists
(select 1 from LD_profileallpermission where tabid = @tabid and operation=13);
insert into LD_profileallpermission(tabid,operation)
select @tabid,14 from dual where not exists
(select 1 from LD_profileallpermission where tabid = @tabid and operation=14);
insert into LD_profileallpermission(tabid,operation)
select @tabid,5 from dual where not exists
(select 1 from LD_profileallpermission where tabid = @tabid and operation=5);
insert into LD_profileallpermission(tabid,operation)
select @tabid,6 from dual where not exists
(select 1 from LD_profileallpermission where tabid = @tabid and operation=6);
delimiter;

select tabid into @tabid from ld_tab where `name` = 'Navigation';
insert into LD_profileallpermission(tabid,operation)
select @tabid,3 from dual where not exists
(select 1 from LD_profileallpermission where tabid = @tabid and operation=3);
delimiter;

select tabid into @tabid from ld_tab where `name` = 'OutboundOrder';
insert into LD_profileallpermission(tabid,operation)
select @tabid,3 from dual where not exists
(select 1 from LD_profileallpermission where tabid = @tabid and operation=3);
insert into LD_profileallpermission(tabid,operation)
select @tabid,4 from dual where not exists
(select 1 from LD_profileallpermission where tabid = @tabid and operation=4);
insert into LD_profileallpermission(tabid,operation)
select @tabid,11 from dual where not exists
(select 1 from LD_profileallpermission where tabid = @tabid and operation=11);
insert into LD_profileallpermission(tabid,operation)
select @tabid,1 from dual where not exists
(select 1 from LD_profileallpermission where tabid = @tabid and operation=1);
insert into LD_profileallpermission(tabid,operation)
select @tabid,2 from dual where not exists
(select 1 from LD_profileallpermission where tabid = @tabid and operation=2);
insert into LD_profileallpermission(tabid,operation)
select @tabid,12 from dual where not exists
(select 1 from LD_profileallpermission where tabid = @tabid and operation=12);
insert into LD_profileallpermission(tabid,operation)
select @tabid,13 from dual where not exists
(select 1 from LD_profileallpermission where tabid = @tabid and operation=13);
insert into LD_profileallpermission(tabid,operation)
select @tabid,14 from dual where not exists
(select 1 from LD_profileallpermission where tabid = @tabid and operation=14);
insert into LD_profileallpermission(tabid,operation)
select @tabid,18 from dual where not exists
(select 1 from LD_profileallpermission where tabid = @tabid and operation=18);
insert into LD_profileallpermission(tabid,operation)
select @tabid,19 from dual where not exists
(select 1 from LD_profileallpermission where tabid = @tabid and operation=19);
insert into LD_profileallpermission(tabid,operation)
select @tabid,6 from dual where not exists
(select 1 from LD_profileallpermission where tabid = @tabid and operation=6);
delimiter;

select tabid into @tabid from ld_tab where `name` = 'Stock';
insert into LD_profileallpermission(tabid,operation)
select @tabid,3 from dual where not exists
(select 1 from LD_profileallpermission where tabid = @tabid and operation=3);
insert into LD_profileallpermission(tabid,operation)
select @tabid,4 from dual where not exists
(select 1 from LD_profileallpermission where tabid = @tabid and operation=4);
insert into LD_profileallpermission(tabid,operation)
select @tabid,11 from dual where not exists
(select 1 from LD_profileallpermission where tabid = @tabid and operation=11);
insert into LD_profileallpermission(tabid,operation)
select @tabid,1 from dual where not exists
(select 1 from LD_profileallpermission where tabid = @tabid and operation=1);
insert into LD_profileallpermission(tabid,operation)
select @tabid,2 from dual where not exists
(select 1 from LD_profileallpermission where tabid = @tabid and operation=2);
insert into LD_profileallpermission(tabid,operation)
select @tabid,12 from dual where not exists
(select 1 from LD_profileallpermission where tabid = @tabid and operation=12);
insert into LD_profileallpermission(tabid,operation)
select @tabid,13 from dual where not exists
(select 1 from LD_profileallpermission where tabid = @tabid and operation=13);
insert into LD_profileallpermission(tabid,operation)
select @tabid,14 from dual where not exists
(select 1 from LD_profileallpermission where tabid = @tabid and operation=14);
insert into LD_profileallpermission(tabid,operation)
select @tabid,18 from dual where not exists
(select 1 from LD_profileallpermission where tabid = @tabid and operation=18);
insert into LD_profileallpermission(tabid,operation)
select @tabid,19 from dual where not exists
(select 1 from LD_profileallpermission where tabid = @tabid and operation=19);
insert into LD_profileallpermission(tabid,operation)
select @tabid,6 from dual where not exists
(select 1 from LD_profileallpermission where tabid = @tabid and operation=6);
delimiter;

select tabid into @tabid from ld_tab where `name` = 'WareHouseTransfer';
insert into LD_profileallpermission(tabid,operation)
select @tabid,3 from dual where not exists
(select 1 from LD_profileallpermission where tabid = @tabid and operation=3);
insert into LD_profileallpermission(tabid,operation)
select @tabid,4 from dual where not exists
(select 1 from LD_profileallpermission where tabid = @tabid and operation=4);
insert into LD_profileallpermission(tabid,operation)
select @tabid,11 from dual where not exists
(select 1 from LD_profileallpermission where tabid = @tabid and operation=11);
insert into LD_profileallpermission(tabid,operation)
select @tabid,1 from dual where not exists
(select 1 from LD_profileallpermission where tabid = @tabid and operation=1);
insert into LD_profileallpermission(tabid,operation)
select @tabid,2 from dual where not exists
(select 1 from LD_profileallpermission where tabid = @tabid and operation=2);
insert into LD_profileallpermission(tabid,operation)
select @tabid,12 from dual where not exists
(select 1 from LD_profileallpermission where tabid = @tabid and operation=12);
insert into LD_profileallpermission(tabid,operation)
select @tabid,13 from dual where not exists
(select 1 from LD_profileallpermission where tabid = @tabid and operation=13);
insert into LD_profileallpermission(tabid,operation)
select @tabid,14 from dual where not exists
(select 1 from LD_profileallpermission where tabid = @tabid and operation=14);
insert into LD_profileallpermission(tabid,operation)
select @tabid,18 from dual where not exists
(select 1 from LD_profileallpermission where tabid = @tabid and operation=18);
insert into LD_profileallpermission(tabid,operation)
select @tabid,19 from dual where not exists
(select 1 from LD_profileallpermission where tabid = @tabid and operation=19);
insert into LD_profileallpermission(tabid,operation)
select @tabid,6 from dual where not exists
(select 1 from LD_profileallpermission where tabid = @tabid and operation=6);
delimiter;

select tabid into @tabid from ld_tab where `name` = 'Checks';
insert into LD_profileallpermission(tabid,operation)
select @tabid,3 from dual where not exists
(select 1 from LD_profileallpermission where tabid = @tabid and operation=3);
insert into LD_profileallpermission(tabid,operation)
select @tabid,4 from dual where not exists
(select 1 from LD_profileallpermission where tabid = @tabid and operation=4);
insert into LD_profileallpermission(tabid,operation)
select @tabid,11 from dual where not exists
(select 1 from LD_profileallpermission where tabid = @tabid and operation=11);
insert into LD_profileallpermission(tabid,operation)
select @tabid,1 from dual where not exists
(select 1 from LD_profileallpermission where tabid = @tabid and operation=1);
insert into LD_profileallpermission(tabid,operation)
select @tabid,2 from dual where not exists
(select 1 from LD_profileallpermission where tabid = @tabid and operation=2);
insert into LD_profileallpermission(tabid,operation)
select @tabid,12 from dual where not exists
(select 1 from LD_profileallpermission where tabid = @tabid and operation=12);
insert into LD_profileallpermission(tabid,operation)
select @tabid,13 from dual where not exists
(select 1 from LD_profileallpermission where tabid = @tabid and operation=13);
insert into LD_profileallpermission(tabid,operation)
select @tabid,14 from dual where not exists
(select 1 from LD_profileallpermission where tabid = @tabid and operation=14);
insert into LD_profileallpermission(tabid,operation)
select @tabid,20 from dual where not exists
(select 1 from LD_profileallpermission where tabid = @tabid and operation=20);
insert into LD_profileallpermission(tabid,operation)
select @tabid,21 from dual where not exists
(select 1 from LD_profileallpermission where tabid = @tabid and operation=21);
insert into LD_profileallpermission(tabid,operation)
select @tabid,6 from dual where not exists
(select 1 from LD_profileallpermission where tabid = @tabid and operation=6);
delimiter;

select tabid into @tabid from ld_tab where `name` = 'InventoryLedger';
insert into LD_profileallpermission(tabid,operation)
select @tabid,3 from dual where not exists
(select 1 from LD_profileallpermission where tabid = @tabid and operation=3);
delimiter;

select tabid into @tabid from ld_tab where `name` = 'InventoryAccount';
insert into LD_profileallpermission(tabid,operation)
select @tabid,3 from dual where not exists
(select 1 from LD_profileallpermission where tabid = @tabid and operation=3);
delimiter;

select tabid into @tabid from ld_tab where `name` = 'InventoryQuery';
insert into LD_profileallpermission(tabid,operation)
select @tabid,3 from dual where not exists
(select 1 from LD_profileallpermission where tabid = @tabid and operation=3);
delimiter;

select tabid into @tabid from ld_tab where `name` = 'Prdtnums';
insert into LD_profileallpermission(tabid,operation)
select @tabid,3 from dual where not exists
(select 1 from LD_profileallpermission where tabid = @tabid and operation=3);
delimiter;

select tabid into @tabid from ld_tab where `name` = 'Invoice';
insert into LD_profileallpermission(tabid,operation)
select @tabid,3 from dual where not exists
(select 1 from LD_profileallpermission where tabid = @tabid and operation=3);
insert into LD_profileallpermission(tabid,operation)
select @tabid,4 from dual where not exists
(select 1 from LD_profileallpermission where tabid = @tabid and operation=4);
insert into LD_profileallpermission(tabid,operation)
select @tabid,11 from dual where not exists
(select 1 from LD_profileallpermission where tabid = @tabid and operation=11);
insert into LD_profileallpermission(tabid,operation)
select @tabid,1 from dual where not exists
(select 1 from LD_profileallpermission where tabid = @tabid and operation=1);
insert into LD_profileallpermission(tabid,operation)
select @tabid,2 from dual where not exists
(select 1 from LD_profileallpermission where tabid = @tabid and operation=2);
insert into LD_profileallpermission(tabid,operation)
select @tabid,12 from dual where not exists
(select 1 from LD_profileallpermission where tabid = @tabid and operation=12);
insert into LD_profileallpermission(tabid,operation)
select @tabid,13 from dual where not exists
(select 1 from LD_profileallpermission where tabid = @tabid and operation=13);
insert into LD_profileallpermission(tabid,operation)
select @tabid,14 from dual where not exists
(select 1 from LD_profileallpermission where tabid = @tabid and operation=14);
insert into LD_profileallpermission(tabid,operation)
select @tabid,6 from dual where not exists
(select 1 from LD_profileallpermission where tabid = @tabid and operation=6);
delimiter;

select tabid into @tabid from ld_tab where `name` = 'PurchaseInvoice';
insert into LD_profileallpermission(tabid,operation)
select @tabid,3 from dual where not exists
(select 1 from LD_profileallpermission where tabid = @tabid and operation=3);
insert into LD_profileallpermission(tabid,operation)
select @tabid,4 from dual where not exists
(select 1 from LD_profileallpermission where tabid = @tabid and operation=4);
insert into LD_profileallpermission(tabid,operation)
select @tabid,11 from dual where not exists
(select 1 from LD_profileallpermission where tabid = @tabid and operation=11);
insert into LD_profileallpermission(tabid,operation)
select @tabid,1 from dual where not exists
(select 1 from LD_profileallpermission where tabid = @tabid and operation=1);
insert into LD_profileallpermission(tabid,operation)
select @tabid,2 from dual where not exists
(select 1 from LD_profileallpermission where tabid = @tabid and operation=2);
insert into LD_profileallpermission(tabid,operation)
select @tabid,12 from dual where not exists
(select 1 from LD_profileallpermission where tabid = @tabid and operation=12);
insert into LD_profileallpermission(tabid,operation)
select @tabid,13 from dual where not exists
(select 1 from LD_profileallpermission where tabid = @tabid and operation=13);
insert into LD_profileallpermission(tabid,operation)
select @tabid,14 from dual where not exists
(select 1 from LD_profileallpermission where tabid = @tabid and operation=14);
insert into LD_profileallpermission(tabid,operation)
select @tabid,6 from dual where not exists
(select 1 from LD_profileallpermission where tabid = @tabid and operation=6);
delimiter;

select tabid into @tabid from ld_tab where `name` = 'PublicAnnouncement';
insert into LD_profileallpermission(tabid,operation)
select @tabid,3 from dual where not exists
(select 1 from LD_profileallpermission where tabid = @tabid and operation=3);
insert into LD_profileallpermission(tabid,operation)
select @tabid,4 from dual where not exists
(select 1 from LD_profileallpermission where tabid = @tabid and operation=4);
insert into LD_profileallpermission(tabid,operation)
select @tabid,11 from dual where not exists
(select 1 from LD_profileallpermission where tabid = @tabid and operation=11);
insert into LD_profileallpermission(tabid,operation)
select @tabid,1 from dual where not exists
(select 1 from LD_profileallpermission where tabid = @tabid and operation=1);
insert into LD_profileallpermission(tabid,operation)
select @tabid,2 from dual where not exists
(select 1 from LD_profileallpermission where tabid = @tabid and operation=2);
insert into LD_profileallpermission(tabid,operation)
select @tabid,12 from dual where not exists
(select 1 from LD_profileallpermission where tabid = @tabid and operation=12);
insert into LD_profileallpermission(tabid,operation)
select @tabid,13 from dual where not exists
(select 1 from LD_profileallpermission where tabid = @tabid and operation=13);
delimiter;

select tabid into @tabid from ld_tab where `name` = 'CashBill';
insert into LD_profileallpermission(tabid,operation)
select @tabid,3 from dual where not exists
(select 1 from LD_profileallpermission where tabid = @tabid and operation=3);
insert into LD_profileallpermission(tabid,operation)
select @tabid,4 from dual where not exists
(select 1 from LD_profileallpermission where tabid = @tabid and operation=4);
insert into LD_profileallpermission(tabid,operation)
select @tabid,11 from dual where not exists
(select 1 from LD_profileallpermission where tabid = @tabid and operation=11);
insert into LD_profileallpermission(tabid,operation)
select @tabid,1 from dual where not exists
(select 1 from LD_profileallpermission where tabid = @tabid and operation=1);
insert into LD_profileallpermission(tabid,operation)
select @tabid,2 from dual where not exists
(select 1 from LD_profileallpermission where tabid = @tabid and operation=2);
insert into LD_profileallpermission(tabid,operation)
select @tabid,12 from dual where not exists
(select 1 from LD_profileallpermission where tabid = @tabid and operation=12);
insert into LD_profileallpermission(tabid,operation)
select @tabid,13 from dual where not exists
(select 1 from LD_profileallpermission where tabid = @tabid and operation=13);
insert into LD_profileallpermission(tabid,operation)
select @tabid,14 from dual where not exists
(select 1 from LD_profileallpermission where tabid = @tabid and operation=14);
insert into LD_profileallpermission(tabid,operation)
select @tabid,18 from dual where not exists
(select 1 from LD_profileallpermission where tabid = @tabid and operation=18);
insert into LD_profileallpermission(tabid,operation)
select @tabid,19 from dual where not exists
(select 1 from LD_profileallpermission where tabid = @tabid and operation=19);
insert into LD_profileallpermission(tabid,operation)
select @tabid,6 from dual where not exists
(select 1 from LD_profileallpermission where tabid = @tabid and operation=6);
delimiter;

select tabid into @tabid from ld_tab where `name` = 'SendCashBill';
insert into LD_profileallpermission(tabid,operation)
select @tabid,3 from dual where not exists
(select 1 from LD_profileallpermission where tabid = @tabid and operation=3);
insert into LD_profileallpermission(tabid,operation)
select @tabid,4 from dual where not exists
(select 1 from LD_profileallpermission where tabid = @tabid and operation=4);
insert into LD_profileallpermission(tabid,operation)
select @tabid,11 from dual where not exists
(select 1 from LD_profileallpermission where tabid = @tabid and operation=11);
insert into LD_profileallpermission(tabid,operation)
select @tabid,1 from dual where not exists
(select 1 from LD_profileallpermission where tabid = @tabid and operation=1);
insert into LD_profileallpermission(tabid,operation)
select @tabid,2 from dual where not exists
(select 1 from LD_profileallpermission where tabid = @tabid and operation=2);
insert into LD_profileallpermission(tabid,operation)
select @tabid,12 from dual where not exists
(select 1 from LD_profileallpermission where tabid = @tabid and operation=12);
insert into LD_profileallpermission(tabid,operation)
select @tabid,13 from dual where not exists
(select 1 from LD_profileallpermission where tabid = @tabid and operation=13);
insert into LD_profileallpermission(tabid,operation)
select @tabid,14 from dual where not exists
(select 1 from LD_profileallpermission where tabid = @tabid and operation=14);
insert into LD_profileallpermission(tabid,operation)
select @tabid,18 from dual where not exists
(select 1 from LD_profileallpermission where tabid = @tabid and operation=18);
insert into LD_profileallpermission(tabid,operation)
select @tabid,19 from dual where not exists
(select 1 from LD_profileallpermission where tabid = @tabid and operation=19);
insert into LD_profileallpermission(tabid,operation)
select @tabid,6 from dual where not exists
(select 1 from LD_profileallpermission where tabid = @tabid and operation=6);
delimiter;

select tabid into @tabid from ld_tab where `name` = 'CashBack';
insert into LD_profileallpermission(tabid,operation)
select @tabid,3 from dual where not exists
(select 1 from LD_profileallpermission where tabid = @tabid and operation=3);
insert into LD_profileallpermission(tabid,operation)
select @tabid,4 from dual where not exists
(select 1 from LD_profileallpermission where tabid = @tabid and operation=4);
insert into LD_profileallpermission(tabid,operation)
select @tabid,1 from dual where not exists
(select 1 from LD_profileallpermission where tabid = @tabid and operation=1);
insert into LD_profileallpermission(tabid,operation)
select @tabid,2 from dual where not exists
(select 1 from LD_profileallpermission where tabid = @tabid and operation=2);
insert into LD_profileallpermission(tabid,operation)
select @tabid,13 from dual where not exists
(select 1 from LD_profileallpermission where tabid = @tabid and operation=13);
insert into LD_profileallpermission(tabid,operation)
select @tabid,14 from dual where not exists
(select 1 from LD_profileallpermission where tabid = @tabid and operation=14);
insert into LD_profileallpermission(tabid,operation)
select @tabid,6 from dual where not exists
(select 1 from LD_profileallpermission where tabid = @tabid and operation=6);
delimiter;

select tabid into @tabid from ld_tab where `name` = 'PurchaseCashBack';
insert into LD_profileallpermission(tabid,operation)
select @tabid,3 from dual where not exists
(select 1 from LD_profileallpermission where tabid = @tabid and operation=3);
insert into LD_profileallpermission(tabid,operation)
select @tabid,4 from dual where not exists
(select 1 from LD_profileallpermission where tabid = @tabid and operation=4);
insert into LD_profileallpermission(tabid,operation)
select @tabid,1 from dual where not exists
(select 1 from LD_profileallpermission where tabid = @tabid and operation=1);
insert into LD_profileallpermission(tabid,operation)
select @tabid,2 from dual where not exists
(select 1 from LD_profileallpermission where tabid = @tabid and operation=2);
insert into LD_profileallpermission(tabid,operation)
select @tabid,13 from dual where not exists
(select 1 from LD_profileallpermission where tabid = @tabid and operation=13);
insert into LD_profileallpermission(tabid,operation)
select @tabid,14 from dual where not exists
(select 1 from LD_profileallpermission where tabid = @tabid and operation=14);
insert into LD_profileallpermission(tabid,operation)
select @tabid,6 from dual where not exists
(select 1 from LD_profileallpermission where tabid = @tabid and operation=6);
delimiter;

select tabid into @tabid from ld_tab where `name` = 'PaymentPlan';
insert into LD_profileallpermission(tabid,operation)
select @tabid,3 from dual where not exists
(select 1 from LD_profileallpermission where tabid = @tabid and operation=3);
insert into LD_profileallpermission(tabid,operation)
select @tabid,4 from dual where not exists
(select 1 from LD_profileallpermission where tabid = @tabid and operation=4);
insert into LD_profileallpermission(tabid,operation)
select @tabid,1 from dual where not exists
(select 1 from LD_profileallpermission where tabid = @tabid and operation=1);
insert into LD_profileallpermission(tabid,operation)
select @tabid,2 from dual where not exists
(select 1 from LD_profileallpermission where tabid = @tabid and operation=2);
insert into LD_profileallpermission(tabid,operation)
select @tabid,12 from dual where not exists
(select 1 from LD_profileallpermission where tabid = @tabid and operation=12);
insert into LD_profileallpermission(tabid,operation)
select @tabid,13 from dual where not exists
(select 1 from LD_profileallpermission where tabid = @tabid and operation=13);
insert into LD_profileallpermission(tabid,operation)
select @tabid,14 from dual where not exists
(select 1 from LD_profileallpermission where tabid = @tabid and operation=14);
insert into LD_profileallpermission(tabid,operation)
select @tabid,6 from dual where not exists
(select 1 from LD_profileallpermission where tabid = @tabid and operation=6);
delimiter;

select tabid into @tabid from ld_tab where `name` = 'SendPayment';
insert into LD_profileallpermission(tabid,operation)
select @tabid,3 from dual where not exists
(select 1 from LD_profileallpermission where tabid = @tabid and operation=3);
insert into LD_profileallpermission(tabid,operation)
select @tabid,4 from dual where not exists
(select 1 from LD_profileallpermission where tabid = @tabid and operation=4);
insert into LD_profileallpermission(tabid,operation)
select @tabid,1 from dual where not exists
(select 1 from LD_profileallpermission where tabid = @tabid and operation=1);
insert into LD_profileallpermission(tabid,operation)
select @tabid,2 from dual where not exists
(select 1 from LD_profileallpermission where tabid = @tabid and operation=2);
insert into LD_profileallpermission(tabid,operation)
select @tabid,12 from dual where not exists
(select 1 from LD_profileallpermission where tabid = @tabid and operation=12);
insert into LD_profileallpermission(tabid,operation)
select @tabid,13 from dual where not exists
(select 1 from LD_profileallpermission where tabid = @tabid and operation=13);
insert into LD_profileallpermission(tabid,operation)
select @tabid,14 from dual where not exists
(select 1 from LD_profileallpermission where tabid = @tabid and operation=14);
insert into LD_profileallpermission(tabid,operation)
select @tabid,6 from dual where not exists
(select 1 from LD_profileallpermission where tabid = @tabid and operation=6);
delimiter;

select tabid into @tabid from ld_tab where `name` = 'PutCash';
insert into LD_profileallpermission(tabid,operation)
select @tabid,3 from dual where not exists
(select 1 from LD_profileallpermission where tabid = @tabid and operation=3);
insert into LD_profileallpermission(tabid,operation)
select @tabid,4 from dual where not exists
(select 1 from LD_profileallpermission where tabid = @tabid and operation=4);
insert into LD_profileallpermission(tabid,operation)
select @tabid,11 from dual where not exists
(select 1 from LD_profileallpermission where tabid = @tabid and operation=11);
insert into LD_profileallpermission(tabid,operation)
select @tabid,1 from dual where not exists
(select 1 from LD_profileallpermission where tabid = @tabid and operation=1);
insert into LD_profileallpermission(tabid,operation)
select @tabid,2 from dual where not exists
(select 1 from LD_profileallpermission where tabid = @tabid and operation=2);
insert into LD_profileallpermission(tabid,operation)
select @tabid,12 from dual where not exists
(select 1 from LD_profileallpermission where tabid = @tabid and operation=12);
insert into LD_profileallpermission(tabid,operation)
select @tabid,13 from dual where not exists
(select 1 from LD_profileallpermission where tabid = @tabid and operation=13);
insert into LD_profileallpermission(tabid,operation)
select @tabid,14 from dual where not exists
(select 1 from LD_profileallpermission where tabid = @tabid and operation=14);
insert into LD_profileallpermission(tabid,operation)
select @tabid,6 from dual where not exists
(select 1 from LD_profileallpermission where tabid = @tabid and operation=6);
delimiter;

select tabid into @tabid from ld_tab where `name` = 'CashDeposit';
insert into LD_profileallpermission(tabid,operation)
select @tabid,3 from dual where not exists
(select 1 from LD_profileallpermission where tabid = @tabid and operation=3);
insert into LD_profileallpermission(tabid,operation)
select @tabid,4 from dual where not exists
(select 1 from LD_profileallpermission where tabid = @tabid and operation=4);
insert into LD_profileallpermission(tabid,operation)
select @tabid,11 from dual where not exists
(select 1 from LD_profileallpermission where tabid = @tabid and operation=11);
insert into LD_profileallpermission(tabid,operation)
select @tabid,1 from dual where not exists
(select 1 from LD_profileallpermission where tabid = @tabid and operation=1);
insert into LD_profileallpermission(tabid,operation)
select @tabid,2 from dual where not exists
(select 1 from LD_profileallpermission where tabid = @tabid and operation=2);
insert into LD_profileallpermission(tabid,operation)
select @tabid,12 from dual where not exists
(select 1 from LD_profileallpermission where tabid = @tabid and operation=12);
insert into LD_profileallpermission(tabid,operation)
select @tabid,13 from dual where not exists
(select 1 from LD_profileallpermission where tabid = @tabid and operation=13);
insert into LD_profileallpermission(tabid,operation)
select @tabid,14 from dual where not exists
(select 1 from LD_profileallpermission where tabid = @tabid and operation=14);
insert into LD_profileallpermission(tabid,operation)
select @tabid,6 from dual where not exists
(select 1 from LD_profileallpermission where tabid = @tabid and operation=6);
delimiter;

select tabid into @tabid from ld_tab where `name` = 'Expense';
insert into LD_profileallpermission(tabid,operation)
select @tabid,3 from dual where not exists
(select 1 from LD_profileallpermission where tabid = @tabid and operation=3);
insert into LD_profileallpermission(tabid,operation)
select @tabid,4 from dual where not exists
(select 1 from LD_profileallpermission where tabid = @tabid and operation=4);
insert into LD_profileallpermission(tabid,operation)
select @tabid,11 from dual where not exists
(select 1 from LD_profileallpermission where tabid = @tabid and operation=11);
insert into LD_profileallpermission(tabid,operation)
select @tabid,1 from dual where not exists
(select 1 from LD_profileallpermission where tabid = @tabid and operation=1);
insert into LD_profileallpermission(tabid,operation)
select @tabid,2 from dual where not exists
(select 1 from LD_profileallpermission where tabid = @tabid and operation=2);
insert into LD_profileallpermission(tabid,operation)
select @tabid,12 from dual where not exists
(select 1 from LD_profileallpermission where tabid = @tabid and operation=12);
insert into LD_profileallpermission(tabid,operation)
select @tabid,13 from dual where not exists
(select 1 from LD_profileallpermission where tabid = @tabid and operation=13);
insert into LD_profileallpermission(tabid,operation)
select @tabid,14 from dual where not exists
(select 1 from LD_profileallpermission where tabid = @tabid and operation=14);
insert into LD_profileallpermission(tabid,operation)
select @tabid,6 from dual where not exists
(select 1 from LD_profileallpermission where tabid = @tabid and operation=6);
delimiter;

select tabid into @tabid from ld_tab where `name` = 'Commission';
insert into LD_profileallpermission(tabid,operation)
select @tabid,3 from dual where not exists
(select 1 from LD_profileallpermission where tabid = @tabid and operation=3);
insert into LD_profileallpermission(tabid,operation)
select @tabid,4 from dual where not exists
(select 1 from LD_profileallpermission where tabid = @tabid and operation=4);
insert into LD_profileallpermission(tabid,operation)
select @tabid,11 from dual where not exists
(select 1 from LD_profileallpermission where tabid = @tabid and operation=11);
insert into LD_profileallpermission(tabid,operation)
select @tabid,1 from dual where not exists
(select 1 from LD_profileallpermission where tabid = @tabid and operation=1);
insert into LD_profileallpermission(tabid,operation)
select @tabid,2 from dual where not exists
(select 1 from LD_profileallpermission where tabid = @tabid and operation=2);
insert into LD_profileallpermission(tabid,operation)
select @tabid,12 from dual where not exists
(select 1 from LD_profileallpermission where tabid = @tabid and operation=12);
insert into LD_profileallpermission(tabid,operation)
select @tabid,13 from dual where not exists
(select 1 from LD_profileallpermission where tabid = @tabid and operation=13);
insert into LD_profileallpermission(tabid,operation)
select @tabid,14 from dual where not exists
(select 1 from LD_profileallpermission where tabid = @tabid and operation=14);
insert into LD_profileallpermission(tabid,operation)
select @tabid,6 from dual where not exists
(select 1 from LD_profileallpermission where tabid = @tabid and operation=6);
delimiter;

select tabid into @tabid from ld_tab where `name` = 'BankCash';
insert into LD_profileallpermission(tabid,operation)
select @tabid,3 from dual where not exists
(select 1 from LD_profileallpermission where tabid = @tabid and operation=3);
delimiter;

select tabid into @tabid from ld_tab where `name` = 'OftenUseReport';
insert into LD_profileallpermission(tabid,operation)
select @tabid,3 from dual where not exists
(select 1 from LD_profileallpermission where tabid = @tabid and operation=3);
delimiter;

select tabid into @tabid from ld_tab where `name` = 'BankAccountSet';
insert into LD_profileallpermission(tabid,operation)
select @tabid,3 from dual where not exists
(select 1 from LD_profileallpermission where tabid = @tabid and operation=3);
delimiter;

select tabid into @tabid from ld_tab where `name` = 'Dashboard';
insert into LD_profileallpermission(tabid,operation)
select @tabid,3 from dual where not exists
(select 1 from LD_profileallpermission where tabid = @tabid and operation=3);
delimiter;

select tabid into @tabid from ld_tab where `name` = 'Comprehensivereport';
insert into LD_profileallpermission(tabid,operation)
select @tabid,3 from dual where not exists
(select 1 from LD_profileallpermission where tabid = @tabid and operation=3);
delimiter;

select tabid into @tabid from ld_tab where `name` = 'Reports';
insert into LD_profileallpermission(tabid,operation)
select @tabid,3 from dual where not exists
(select 1 from LD_profileallpermission where tabid = @tabid and operation=3);
delimiter;

select tabid into @tabid from ld_tab where `name` = 'ModComments';
insert into LD_profileallpermission(tabid,operation)
select @tabid,3 from dual where not exists
(select 1 from LD_profileallpermission where tabid = @tabid and operation=3);
insert into LD_profileallpermission(tabid,operation)
select @tabid,4 from dual where not exists
(select 1 from LD_profileallpermission where tabid = @tabid and operation=4);
insert into LD_profileallpermission(tabid,operation)
select @tabid,11 from dual where not exists
(select 1 from LD_profileallpermission where tabid = @tabid and operation=11);
insert into LD_profileallpermission(tabid,operation)
select @tabid,1 from dual where not exists
(select 1 from LD_profileallpermission where tabid = @tabid and operation=1);
insert into LD_profileallpermission(tabid,operation)
select @tabid,2 from dual where not exists
(select 1 from LD_profileallpermission where tabid = @tabid and operation=2);
insert into LD_profileallpermission(tabid,operation)
select @tabid,12 from dual where not exists
(select 1 from LD_profileallpermission where tabid = @tabid and operation=12);
insert into LD_profileallpermission(tabid,operation)
select @tabid,13 from dual where not exists
(select 1 from LD_profileallpermission where tabid = @tabid and operation=13);
insert into LD_profileallpermission(tabid,operation)
select @tabid,14 from dual where not exists
(select 1 from LD_profileallpermission where tabid = @tabid and operation=14);
insert into LD_profileallpermission(tabid,operation)
select @tabid,6 from dual where not exists
(select 1 from LD_profileallpermission where tabid = @tabid and operation=6);
delimiter;

select tabid into @tabid from ld_tab where `name` = 'Products';
insert into LD_profileallpermission(tabid,operation)
select @tabid,3 from dual where not exists
(select 1 from LD_profileallpermission where tabid = @tabid and operation=3);
insert into LD_profileallpermission(tabid,operation)
select @tabid,4 from dual where not exists
(select 1 from LD_profileallpermission where tabid = @tabid and operation=4);
insert into LD_profileallpermission(tabid,operation)
select @tabid,11 from dual where not exists
(select 1 from LD_profileallpermission where tabid = @tabid and operation=11);
insert into LD_profileallpermission(tabid,operation)
select @tabid,1 from dual where not exists
(select 1 from LD_profileallpermission where tabid = @tabid and operation=1);
insert into LD_profileallpermission(tabid,operation)
select @tabid,2 from dual where not exists
(select 1 from LD_profileallpermission where tabid = @tabid and operation=2);
insert into LD_profileallpermission(tabid,operation)
select @tabid,12 from dual where not exists
(select 1 from LD_profileallpermission where tabid = @tabid and operation=12);
insert into LD_profileallpermission(tabid,operation)
select @tabid,13 from dual where not exists
(select 1 from LD_profileallpermission where tabid = @tabid and operation=13);
insert into LD_profileallpermission(tabid,operation)
select @tabid,14 from dual where not exists
(select 1 from LD_profileallpermission where tabid = @tabid and operation=14);
insert into LD_profileallpermission(tabid,operation)
select @tabid,5 from dual where not exists
(select 1 from LD_profileallpermission where tabid = @tabid and operation=5);
insert into LD_profileallpermission(tabid,operation)
select @tabid,6 from dual where not exists
(select 1 from LD_profileallpermission where tabid = @tabid and operation=6);
insert into LD_profileallpermission(tabid,operation)
select @tabid,10 from dual where not exists
(select 1 from LD_profileallpermission where tabid = @tabid and operation=10);
insert into LD_profileallpermission(tabid,operation)
select @tabid,8 from dual where not exists
(select 1 from LD_profileallpermission where tabid = @tabid and operation=8);
delimiter;

select tabid into @tabid from ld_tab where `name` = 'Productbom';
insert into LD_profileallpermission(tabid,operation)
select @tabid,3 from dual where not exists
(select 1 from LD_profileallpermission where tabid = @tabid and operation=3);
insert into LD_profileallpermission(tabid,operation)
select @tabid,4 from dual where not exists
(select 1 from LD_profileallpermission where tabid = @tabid and operation=4);
insert into LD_profileallpermission(tabid,operation)
select @tabid,11 from dual where not exists
(select 1 from LD_profileallpermission where tabid = @tabid and operation=11);
insert into LD_profileallpermission(tabid,operation)
select @tabid,1 from dual where not exists
(select 1 from LD_profileallpermission where tabid = @tabid and operation=1);
insert into LD_profileallpermission(tabid,operation)
select @tabid,2 from dual where not exists
(select 1 from LD_profileallpermission where tabid = @tabid and operation=2);
insert into LD_profileallpermission(tabid,operation)
select @tabid,12 from dual where not exists
(select 1 from LD_profileallpermission where tabid = @tabid and operation=12);
insert into LD_profileallpermission(tabid,operation)
select @tabid,13 from dual where not exists
(select 1 from LD_profileallpermission where tabid = @tabid and operation=13);
insert into LD_profileallpermission(tabid,operation)
select @tabid,14 from dual where not exists
(select 1 from LD_profileallpermission where tabid = @tabid and operation=14);
insert into LD_profileallpermission(tabid,operation)
select @tabid,6 from dual where not exists
(select 1 from LD_profileallpermission where tabid = @tabid and operation=6);
delimiter;

select tabid into @tabid from ld_tab where `name` = 'PriceBooks';
insert into LD_profileallpermission(tabid,operation)
select @tabid,3 from dual where not exists
(select 1 from LD_profileallpermission where tabid = @tabid and operation=3);
insert into LD_profileallpermission(tabid,operation)
select @tabid,4 from dual where not exists
(select 1 from LD_profileallpermission where tabid = @tabid and operation=4);
insert into LD_profileallpermission(tabid,operation)
select @tabid,11 from dual where not exists
(select 1 from LD_profileallpermission where tabid = @tabid and operation=11);
insert into LD_profileallpermission(tabid,operation)
select @tabid,1 from dual where not exists
(select 1 from LD_profileallpermission where tabid = @tabid and operation=1);
insert into LD_profileallpermission(tabid,operation)
select @tabid,2 from dual where not exists
(select 1 from LD_profileallpermission where tabid = @tabid and operation=2);
insert into LD_profileallpermission(tabid,operation)
select @tabid,12 from dual where not exists
(select 1 from LD_profileallpermission where tabid = @tabid and operation=12);
insert into LD_profileallpermission(tabid,operation)
select @tabid,13 from dual where not exists
(select 1 from LD_profileallpermission where tabid = @tabid and operation=13);
insert into LD_profileallpermission(tabid,operation)
select @tabid,14 from dual where not exists
(select 1 from LD_profileallpermission where tabid = @tabid and operation=14);
delimiter;

select tabid into @tabid from ld_tab where `name` = 'Attachment';
insert into LD_profileallpermission(tabid,operation)
select @tabid,3 from dual where not exists
(select 1 from LD_profileallpermission where tabid = @tabid and operation=3);
insert into LD_profileallpermission(tabid,operation)
select @tabid,4 from dual where not exists
(select 1 from LD_profileallpermission where tabid = @tabid and operation=4);
insert into LD_profileallpermission(tabid,operation)
select @tabid,11 from dual where not exists
(select 1 from LD_profileallpermission where tabid = @tabid and operation=11);
insert into LD_profileallpermission(tabid,operation)
select @tabid,1 from dual where not exists
(select 1 from LD_profileallpermission where tabid = @tabid and operation=1);
insert into LD_profileallpermission(tabid,operation)
select @tabid,2 from dual where not exists
(select 1 from LD_profileallpermission where tabid = @tabid and operation=2);
insert into LD_profileallpermission(tabid,operation)
select @tabid,13 from dual where not exists
(select 1 from LD_profileallpermission where tabid = @tabid and operation=13);
insert into LD_profileallpermission(tabid,operation)
select @tabid,14 from dual where not exists
(select 1 from LD_profileallpermission where tabid = @tabid and operation=14);
delimiter;

select tabid into @tabid from ld_tab where `name` = 'SalesGoal';
insert into LD_profileallpermission(tabid,operation)
select @tabid,3 from dual where not exists
(select 1 from LD_profileallpermission where tabid = @tabid and operation=3);
delimiter;

select tabid into @tabid from ld_tab where `name` = 'Cache';
insert into LD_profileallpermission(tabid,operation)
select @tabid,3 from dual where not exists
(select 1 from LD_profileallpermission where tabid = @tabid and operation=3);
delimiter;

call AddColumn('LD_users','profileid','int','11',0);
delimiter;

update ld_users
left JOIN ld_user2role on ld_users.id = ld_user2role.userid
LEFT JOIN ld_role2profile on ld_role2profile.roleid = ld_user2role.roleid set ld_users.profileid = ld_role2profile.profileid
where ld_users.profileid = '' or ld_users.profileid is null;
delimiter;

select tabid into @tabid from ld_tab where `name` = 'Users';
update ld_field set columnname = 'profileid',tablename='LD_users',fieldname='profileid' where tabid = @tabid and fieldname = 'roleid';
delimiter;

CREATE TABLE IF NOT EXISTS `ld_tabshare` (
  `crmid` int(11) DEFAULT NULL,
  `viewuserid` int(11) DEFAULT NULL,
  `Shareuserid` int(11) DEFAULT NULL,
	PRIMARY KEY (`crmid`,`viewuserid`,`Shareuserid`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE IF NOT EXISTS `ld_userscoperhigher` (
  `userid` int(11) NOT NULL DEFAULT '0',
  `viewuserid` int(11) NOT NULL DEFAULT '0',
  PRIMARY KEY (`userid`,`viewuserid`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','YOUARENOTALLOWEDTOVIEWOTHERUSERSDATE','您没有权限查看其他用户的单据','fixedstr' from dual
where not EXISTS(select 1 from ld_desk  where languagetype='zh' and labelbol='YOUARENOTALLOWEDTOVIEWOTHERUSERSDATE' and Labeltype='fixedstr');
delimiter;
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','YOUARENOTALLOWEDTOVIEWOTHERUSERSDATE','You are not allowed to view other users data.','fixedstr' from dual
where not EXISTS(select 1 from ld_desk  where languagetype='en' and labelbol='YOUARENOTALLOWEDTOVIEWOTHERUSERSDATE' and Labeltype='fixedstr');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','YOUARENOTALLOWEDTOEDITOTHERUSERSDATE','您没有权限编辑其他用户的单据','fixedstr' from dual
where not EXISTS(select 1 from ld_desk  where languagetype='zh' and labelbol='YOUARENOTALLOWEDTOEDITOTHERUSERSDATE' and Labeltype='fixedstr');
delimiter;
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','YOUARENOTALLOWEDTOEDITOTHERUSERSDATE','You are not allowed to edit other users data.','fixedstr' from dual
where not EXISTS(select 1 from ld_desk  where languagetype='en' and labelbol='YOUARENOTALLOWEDTOEDITOTHERUSERSDATE' and Labeltype='fixedstr');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','YOUARENOTALLOWEDTOOTHEROTHERUSERSDATE','您没有权限删除其他用户的单据','fixedstr' from dual
where not EXISTS(select 1 from ld_desk  where languagetype='zh' and labelbol='YOUARENOTALLOWEDTOOTHEROTHERUSERSDATE' and Labeltype='fixedstr');
delimiter;
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','YOUARENOTALLOWEDTOOTHEROTHERUSERSDATE','You are not allowed to delete other users data.','fixedstr' from dual
where not EXISTS(select 1 from ld_desk  where languagetype='en' and labelbol='YOUARENOTALLOWEDTOOTHEROTHERUSERSDATE' and Labeltype='fixedstr');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','YOUARENOTALLOWEDTOSHAREOTHERUSERSDATE','您没有权限共享其他用户的单据','fixedstr' from dual
where not EXISTS(select 1 from ld_desk  where languagetype='zh' and labelbol='YOUARENOTALLOWEDTOSHAREOTHERUSERSDATE' and Labeltype='fixedstr');
delimiter;
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','YOUARENOTALLOWEDTOSHAREOTHERUSERSDATE','You are not allowed to share other users data.','fixedstr' from dual
where not EXISTS(select 1 from ld_desk  where languagetype='en' and labelbol='YOUARENOTALLOWEDTOSHAREOTHERUSERSDATE' and Labeltype='fixedstr');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','YOUARENOTALLOWEDTOSHAREOTHERUSERSDATE','您没有权限共享其他用户的单据','jspop' from dual
where not EXISTS(select 1 from ld_desk  where languagetype='zh' and labelbol='YOUARENOTALLOWEDTOSHAREOTHERUSERSDATE' and Labeltype='jspop');
delimiter;
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','YOUARENOTALLOWEDTOSHAREOTHERUSERSDATE','You are not allowed to share other users data.','jspop' from dual
where not EXISTS(select 1 from ld_desk  where languagetype='en' and labelbol='YOUARENOTALLOWEDTOSHAREOTHERUSERSDATE' and Labeltype='jspop');
delimiter;

select tabid into @tabid from ld_tab where `name` = 'PriceBooks';
select id into @fieldid from ld_field_seq;
select blockid into @blockid from ld_blocks where blocklabel = 'LBL_PRICEBOOK_INFORMATION' and tabid = @tabid;
insert into ld_field(tabid,fieldid,columnname,tablename,uitype,fieldname,fieldlabel,block,displaytype,presence,typeofdata,issmownerid)
select @tabid,@fieldid+1,'smownerid','LD_pricebook',53,'smownerid','负责人',@blockid,1,0,'V~M',1 from dual where not exists
(select * from ld_field where tabid = @tabid and columnname = 'smownerid');
update ld_field_seq set id = (select max(fieldid) from ld_field);

select fieldid into @fieldid from ld_field where tabid = @tabid and columnname = 'smownerid';
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'zh','LD_field',@tabid,@fieldid,'负责人'
from dual where not EXISTS(select 1 from ld_tranlabel  where languagetype = 'zh'
and trantable ='LD_field' and tabid = @tabid and relateid=@fieldid);
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'en','LD_field',@tabid,@fieldid,'Assigned To'
from dual where not EXISTS(select 1 from ld_tranlabel  where languagetype = 'en'
and trantable ='LD_field' and tabid = @tabid and relateid=@fieldid);
delimiter;

select tabid into @tabid from ld_tab where `name` = 'Attachment';
select id into @fieldid from ld_field_seq;
select blockid into @blockid from ld_blocks where blocklabel = 'LBL_Attachment_INFORMATION' and tabid = @tabid;
insert into ld_field(tabid,fieldid,columnname,tablename,uitype,fieldname,fieldlabel,block,displaytype,presence,typeofdata,issmownerid,info_type)
select @tabid,@fieldid+1,'smownerid','LD_attachmentsforbills',53,'smownerid','负责人',@blockid,1,0,'V~M',1,'BAS' from dual where not exists
(select * from ld_field where tabid = @tabid and columnname = 'smownerid');
update ld_field_seq set id = (select max(fieldid) from ld_field);
select fieldid into @fieldid from ld_field where tabid = @tabid and columnname = 'smownerid';
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'zh','LD_field',@tabid,@fieldid,'负责人'
from dual where not EXISTS(select 1 from ld_tranlabel  where languagetype = 'zh'
and trantable ='LD_field' and tabid = @tabid and relateid=@fieldid);
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'en','LD_field',@tabid,@fieldid,'Assigned To'
from dual where not EXISTS(select 1 from ld_tranlabel  where languagetype = 'en'
and trantable ='LD_field' and tabid = @tabid and relateid=@fieldid);
delimiter;

call AddColumn('LD_receivablesforecast','smownerid','int','11',0);
delimiter;
call AddColumn('LD_profile2standardpermissions','sequence','int','11',0);
delimiter;

CALL AddColumn('ld_groups','parentgroup','varchar','255',NULL);
delimiter;

CALL AddColumn('ld_groups','depth','int','11',0);
delimiter;

CALL AddColumn('ld_groups','parentid','int','11',0);
delimiter;

SELECT ifnull(MAX(groupid),0) INTO @groupid FROM ld_groups;
INSERT INTO ld_groups(groupid,groupname,description,depth,parentid,parentgroup)
SELECT @groupid+1,'组织结构','组织结构',0,'-1',@groupid+1
	FROM DUAL WHERE NOT EXISTS (SELECT groupid FROM ld_groups WHERE
		parentid = '-1');
UPDATE ld_groups SET parentid = @groupid+1,parentgroup=CONCAT(@groupid+1,'::',groupid),depth=1 WHERE parentid = 0;

INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype) SELECT 'zh','LBL_USERTOTRANSFER','转移关联用户到','fixedstr' FROM DUAL
WHERE NOT EXISTS(SELECT 1 FROM ld_desk  WHERE languagetype='zh' AND labelbol='LBL_USERTOTRANSFER' AND Labeltype='fixedstr');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype) SELECT 'en','LBL_USERTOTRANSFER','The associated user to transfer','fixedstr' FROM DUAL
WHERE NOT EXISTS(SELECT 1 FROM ld_desk  WHERE languagetype='en' AND labelbol='LBL_USERTOTRANSFER' AND Labeltype='fixedstr');

INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype) SELECT 'zh','LBL_GROUPOTRANSFER','转移下级部门到','fixedstr' FROM DUAL
WHERE NOT EXISTS(SELECT 1 FROM ld_desk  WHERE languagetype='zh' AND labelbol='LBL_GROUPOTRANSFER' AND Labeltype='fixedstr');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype) SELECT 'en','LBL_GROUPOTRANSFER','Subordinate departments to transfer','fixedstr' FROM DUAL
WHERE NOT EXISTS(SELECT 1 FROM ld_desk  WHERE languagetype='en' AND labelbol='LBL_GROUPOTRANSFER' AND Labeltype='fixedstr');

DROP PROCEDURE IF EXISTS addUserMenuApprove;
delimiter ||
CREATE PROCEDURE addUserMenuApprove()
BEGIN
	SELECT DATABASE() INTO @tableschema;
	SELECT COUNT(1) INTO @count FROM information_schema.columns WHERE TABLE_SCHEMA = @tableschema AND table_name = 'ld_users' AND COLUMN_NAME = 'scopeauthority';
	IF @count = 0 THEN
		ALTER TABLE ld_users ADD COLUMN scopeauthority INT(1) DEFAULT 0;
		ALTER TABLE ld_users ADD COLUMN viewothers INT(1) DEFAULT 0;
		ALTER TABLE ld_users ADD COLUMN editothers INT(1) DEFAULT 0;
		ALTER TABLE ld_users ADD COLUMN delothers INT(1) DEFAULT 0;
		ALTER TABLE ld_users ADD COLUMN viewselfbills INT(1) DEFAULT 0;
	END IF;
END ||
delimiter;

CALL addUserMenuApprove();
delimiter;

DROP PROCEDURE IF EXISTS addUserMenuApprove;
delimiter;
CALL fieldprofile('LD_users');
delimiter;
CALL getallprofile('LD_users');
delimiter;

SELECT tabid INTO @tabid FROM ld_tab WHERE `name` = 'Users';
SELECT sequence,blockid INTO @sequence,@block_id FROM ld_blocks
	WHERE tabid=@tabid AND blocklabel='LBL_SERVICECONTRACTS';
SET @seq = @sequence + 1;
UPDATE ld_blocks SET sequence= (@seq:=@seq+1) WHERE tabid=@tabid AND sequence > @sequence ORDER BY sequence;
UPDATE ld_blocks SET sequence = @seq+2 WHERE tabid=@tabid AND sequence = @seq AND blockid != @block_id ORDER BY sequence;
SELECT MAX(blockid) INTO @maxblockid FROM ld_blocks;
INSERT INTO ld_blocks(blockid,tabid,blocklabel,sequence)
SELECT @maxblockid+1,@tabid,'LBL_USER_DATAACCESS',@sequence+2
	FROM DUAL WHERE NOT EXISTS (SELECT * FROM ld_blocks WHERE
		tabid = @tabid AND blocklabel = 'LBL_USER_DATAACCESS' );
UPDATE ld_blocks set sequence = @sequence+1 where tabid = @tabid and blocklabel = 'LBL_USER_DATAACCESS';
UPDATE ld_blocks_seq SET id=(SELECT MAX(blockid) FROM ld_blocks);
delimiter;

SELECT tabid INTO @tabid FROM ld_tab WHERE `name` = 'Users';
SELECT blockid INTO @blockid FROM ld_blocks WHERE tabid = @tabid AND blocklabel = 'LBL_USER_DATAACCESS';
INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
SELECT 'zh','LD_blocks',@tabid,@blockid,'数据权限'
FROM DUAL WHERE NOT EXISTS(SELECT 1 FROM ld_tranlabel  WHERE languagetype = 'zh'
AND trantable ='LD_blocks' AND tabid = @tabid AND relateid=@blockid);
INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
SELECT 'en','LD_blocks',@tabid,@blockid,'Data Access'
FROM DUAL WHERE NOT EXISTS(SELECT 1 FROM ld_tranlabel  WHERE languagetype = 'en'
AND trantable ='LD_blocks' AND tabid = @tabid AND relateid=@blockid);
delimiter;

select tabid into @tabid from ld_tab where `name` = 'Users';
SELECT max(fieldid) into @maxid from ld_field;
SELECT max(sequence) into @sequence from ld_field where tabid=@tabid;
SELECT blockid INTO @blockid from ld_blocks where tabid=@tabid and blocklabel='LBL_USER_DATAACCESS';
insert into ld_field (tabid,fieldid,columnname,tablename,generatedtype,uitype,fieldname,fieldlabel,readonly,presence,defaultvalue,maximumlength,sequence,block,displaytype,typeofdata,quickcreate,quickcreatesequence,info_type,masseditable,helpinfo,fieldonly)
select @tabid,@maxid+1,'scopeauthority','LD_users',1,56,'scopeauthority','授权范围',1,0,'','',@sequence+1,@blockid,1,'V~O',3,'','BAS',2,NULL,0
from dual where  not exists (select 1 from  ld_field where tabid=@tabid and columnname='scopeauthority');
UPDATE ld_field_seq set id=(SELECT max(fieldid) from ld_field);
delimiter;

select tabid into @tabid from ld_tab where `name` = 'Users';
select fieldid into @fieldid from ld_field where tabid = @tabid and fieldname = 'scopeauthority';
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'zh','LD_field',@tabid,@fieldid,'授权范围'
from dual where not EXISTS(select 1 from ld_tranlabel  where languagetype = 'zh'
and trantable ='LD_field' and tabid = @tabid and relateid = @fieldid);
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'en','LD_field',@tabid,@fieldid,'The scope of authorization'
from dual where not EXISTS(select 1 from ld_tranlabel  where languagetype = 'en'
and trantable ='LD_field' and tabid = @tabid and relateid = @fieldid);
delimiter;

select tabid into @tabid from ld_tab where `name` = 'Users';
SELECT max(fieldid) into @maxid from ld_field;
SELECT max(sequence) into @sequence from ld_field where tabid=@tabid;
SELECT blockid INTO @blockid from ld_blocks where tabid=@tabid and blocklabel='LBL_USER_DATAACCESS';
insert into ld_field (tabid,fieldid,columnname,tablename,generatedtype,uitype,fieldname,fieldlabel,readonly,presence,defaultvalue,maximumlength,sequence,block,displaytype,typeofdata,quickcreate,quickcreatesequence,info_type,masseditable,helpinfo,fieldonly)
select @tabid,@maxid+1,'viewothers','LD_users',1,56,'viewothers','查看其他用户单据',1,0,'','',@sequence+1,@blockid,1,'V~O',3,'','BAS',2,NULL,0
from dual where  not exists (select 1 from  ld_field where tabid=@tabid and columnname='viewothers');
UPDATE ld_field_seq set id=(SELECT max(fieldid) from ld_field);
delimiter;

select tabid into @tabid from ld_tab where `name` = 'Users';
select fieldid into @fieldid from ld_field where tabid = @tabid and fieldname = 'viewothers';
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'zh','LD_field',@tabid,@fieldid,'查看其他用户单据'
from dual where not EXISTS(select 1 from ld_tranlabel  where languagetype = 'zh'
and trantable ='LD_field' and tabid = @tabid and relateid = @fieldid);
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'en','LD_field',@tabid,@fieldid,'View other user documents'
from dual where not EXISTS(select 1 from ld_tranlabel  where languagetype = 'en'
and trantable ='LD_field' and tabid = @tabid and relateid = @fieldid);
delimiter;

select tabid into @tabid from ld_tab where `name` = 'Users';
SELECT max(fieldid) into @maxid from ld_field;
SELECT max(sequence) into @sequence from ld_field where tabid=@tabid;
SELECT blockid INTO @blockid from ld_blocks where tabid=@tabid and blocklabel='LBL_USER_DATAACCESS';
insert into ld_field (tabid,fieldid,columnname,tablename,generatedtype,uitype,fieldname,fieldlabel,readonly,presence,defaultvalue,maximumlength,sequence,block,displaytype,typeofdata,quickcreate,quickcreatesequence,info_type,masseditable,helpinfo,fieldonly)
select @tabid,@maxid+1,'editothers','LD_users',1,56,'editothers','编辑其他用户单据',1,0,'','',@sequence+1,@blockid,1,'V~O',3,'','BAS',2,NULL,0
from dual where  not exists (select 1 from  ld_field where tabid=@tabid and columnname='editothers');
UPDATE ld_field_seq set id=(SELECT max(fieldid) from ld_field);
delimiter;

select tabid into @tabid from ld_tab where `name` = 'Users';
select fieldid into @fieldid from ld_field where tabid = @tabid and fieldname = 'editothers';
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'zh','LD_field',@tabid,@fieldid,'编辑其他用户单据'
from dual where not EXISTS(select 1 from ld_tranlabel  where languagetype = 'zh'
and trantable ='LD_field' and tabid = @tabid and relateid = @fieldid);
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'en','LD_field',@tabid,@fieldid,'To edit other user documents'
from dual where not EXISTS(select 1 from ld_tranlabel  where languagetype = 'en'
and trantable ='LD_field' and tabid = @tabid and relateid = @fieldid);
delimiter;

select tabid into @tabid from ld_tab where `name` = 'Users';
SELECT max(fieldid) into @maxid from ld_field;
SELECT max(sequence) into @sequence from ld_field where tabid=@tabid;
SELECT blockid INTO @blockid from ld_blocks where tabid=@tabid and blocklabel='LBL_USER_DATAACCESS';
insert into ld_field (tabid,fieldid,columnname,tablename,generatedtype,uitype,fieldname,fieldlabel,readonly,presence,defaultvalue,maximumlength,sequence,block,displaytype,typeofdata,quickcreate,quickcreatesequence,info_type,masseditable,helpinfo,fieldonly)
select @tabid,@maxid+1,'delothers','LD_users',1,56,'delothers','删除其他用户单据',1,0,'','',@sequence+1,@blockid,1,'V~O',3,'','BAS',2,NULL,0
from dual where  not exists (select 1 from  ld_field where tabid=@tabid and columnname='delothers');
UPDATE ld_field_seq set id=(SELECT max(fieldid) from ld_field);
delimiter;

select tabid into @tabid from ld_tab where `name` = 'Users';
select fieldid into @fieldid from ld_field where tabid = @tabid and fieldname = 'delothers';
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'zh','LD_field',@tabid,@fieldid,'删除其他用户单据'
from dual where not EXISTS(select 1 from ld_tranlabel  where languagetype = 'zh'
and trantable ='LD_field' and tabid = @tabid and relateid = @fieldid);
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'en','LD_field',@tabid,@fieldid,'To edit other user documents'
from dual where not EXISTS(select 1 from ld_tranlabel  where languagetype = 'en'
and trantable ='LD_field' and tabid = @tabid and relateid = @fieldid);
delimiter;

select tabid into @tabid from ld_tab where `name` = 'Users';
SELECT max(fieldid) into @maxid from ld_field;
SELECT max(sequence) into @sequence from ld_field where tabid=@tabid;
SELECT blockid INTO @blockid from ld_blocks where tabid=@tabid and blocklabel='LBL_USER_DATAACCESS';
insert into ld_field (tabid,fieldid,columnname,tablename,generatedtype,uitype,fieldname,fieldlabel,readonly,presence,defaultvalue,maximumlength,sequence,block,displaytype,typeofdata,quickcreate,quickcreatesequence,info_type,masseditable,helpinfo,fieldonly)
select @tabid,@maxid+1,'viewselfbills','LD_users',1,56,'viewselfbills','查看自己创建的单据',1,0,'','',@sequence+1,@blockid,1,'V~O',3,'','BAS',2,NULL,0
from dual where  not exists (select 1 from  ld_field where tabid=@tabid and columnname='viewselfbills');
UPDATE ld_field_seq set id=(SELECT max(fieldid) from ld_field);
delimiter;

select tabid into @tabid from ld_tab where `name` = 'Users';
select fieldid into @fieldid from ld_field where tabid = @tabid and fieldname = 'viewselfbills';
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'zh','LD_field',@tabid,@fieldid,'查看自己创建的单据'
from dual where not EXISTS(select 1 from ld_tranlabel  where languagetype = 'zh'
and trantable ='LD_field' and tabid = @tabid and relateid = @fieldid);
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'en','LD_field',@tabid,@fieldid,'Create your own document view'
from dual where not EXISTS(select 1 from ld_tranlabel  where languagetype = 'en'
and trantable ='LD_field' and tabid = @tabid and relateid = @fieldid);
delimiter;

INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype) SELECT 'zh','LBL_PERSONAL','个人','fixedstr' FROM DUAL
WHERE NOT EXISTS(SELECT 1 FROM ld_desk  WHERE languagetype='zh' AND labelbol='LBL_PERSONAL' AND Labeltype='fixedstr');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype) SELECT 'en','LBL_PERSONAL','Personal','fixedstr' FROM DUAL
WHERE NOT EXISTS(SELECT 1 FROM ld_desk  WHERE languagetype='en' AND labelbol='LBL_PERSONAL' AND Labeltype='fixedstr');

INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype) SELECT 'zh','LBL_SENIOR','高级','fixedstr' FROM DUAL
WHERE NOT EXISTS(SELECT 1 FROM ld_desk  WHERE languagetype='zh' AND labelbol='LBL_SENIOR' AND Labeltype='fixedstr');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype) SELECT 'en','LBL_SENIOR','Senior','fixedstr' FROM DUAL
WHERE NOT EXISTS(SELECT 1 FROM ld_desk  WHERE languagetype='en' AND labelbol='LBL_SENIOR' AND Labeltype='fixedstr');
delimiter;

INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype) SELECT 'zh','LBL_LOCATION','定位','jspop' FROM DUAL
WHERE NOT EXISTS(SELECT 1 FROM ld_desk  WHERE languagetype='zh' AND labelbol='LBL_LOCATION' AND Labeltype='jspop');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype) SELECT 'en','LBL_LOCATION','Location','jspop' FROM DUAL
WHERE NOT EXISTS(SELECT 1 FROM ld_desk  WHERE languagetype='en' AND labelbol='LBL_LOCATION' AND Labeltype='jspop');
delimiter;

INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype) SELECT 'zh','LBL_VIEWDISABLEUSER','显示停用用户','jspop' FROM DUAL
WHERE NOT EXISTS(SELECT 1 FROM ld_desk  WHERE languagetype='zh' AND labelbol='LBL_VIEWDISABLEUSER' AND Labeltype='jspop');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype) SELECT 'en','LBL_VIEWDISABLEUSER','Disable the display of the user','jspop' FROM DUAL
WHERE NOT EXISTS(SELECT 1 FROM ld_desk  WHERE languagetype='en' AND labelbol='LBL_VIEWDISABLEUSER' AND Labeltype='jspop');
delimiter;

INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype) SELECT 'zh','LBL_CLOSE','关闭','jspop' FROM DUAL
WHERE NOT EXISTS(SELECT 1 FROM ld_desk  WHERE languagetype='zh' AND labelbol='LBL_CLOSE' AND Labeltype='jspop');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype) SELECT 'en','LBL_CLOSE','Close','jspop' FROM DUAL
WHERE NOT EXISTS(SELECT 1 FROM ld_desk  WHERE languagetype='en' AND labelbol='LBL_CLOSE' AND Labeltype='jspop');
delimiter;

INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype) SELECT 'zh','LBL_SELECTUSER','选择用户','jspop' FROM DUAL
WHERE NOT EXISTS(SELECT 1 FROM ld_desk  WHERE languagetype='zh' AND labelbol='LBL_SELECTUSER' AND Labeltype='jspop');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype) SELECT 'en','LBL_SELECTUSER','Select User','jspop' FROM DUAL
WHERE NOT EXISTS(SELECT 1 FROM ld_desk  WHERE languagetype='en' AND labelbol='LBL_SELECTUSER' AND Labeltype='jspop');
delimiter;

update LD_users set profileid = 1 where profileid = '' or profileid is null;

update ld_desk set fieldlabel = '权限管理 - 角色列表' where labelbol = 'ROLESHIERARCHY' and languagetype = 'zh';
delimiter;

update ld_desk set fieldlabel = 'Authority management - the list of roles' where labelbol = 'ROLESHIERARCHY' and languagetype = 'en';
delimiter;

INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype) SELECT 'zh','LBL_NOTGROUPINFO','没有部门数据，请通知管理员设置部门及部门成员。','fixedstr' FROM DUAL
WHERE NOT EXISTS(SELECT 1 FROM ld_desk  WHERE languagetype='zh' AND labelbol='LBL_NOTGROUPINFO' AND Labeltype='fixedstr');

INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype) SELECT 'en','LBL_NOTGROUPINFO','No departments data found, please notice the administrator to define departments and members.','fixedstr' FROM DUAL
WHERE NOT EXISTS(SELECT 1 FROM ld_desk  WHERE languagetype='en' AND labelbol='LBL_NOTGROUPINFO' AND Labeltype='fixedstr');
delimiter;

select tabid into @tabid from ld_tab where `name` = 'Users';
select fieldid into @fieldid from LD_field where tabid = @tabid and fieldname = 'select_due_date';
update ld_tranlabel set fieldlabel = '是否允许查看具体的服务到期日' where tabid = @tabid and Relateid = @fieldid and languagetype ='zh' and trantable='LD_field';
update ld_tranlabel set fieldlabel = 'Wether allowed to view the real service enddate' where tabid = @tabid and Relateid = @fieldid and languagetype ='en' and trantable='LD_field';
delimiter;

select tabid into @tabid from ld_tab where `name` = 'Users';
select fieldid into @fieldid from LD_field where tabid = @tabid and fieldname = 'scopeauthority';
update ld_tranlabel set fieldlabel = '业务单据授权范围' where tabid = @tabid and Relateid = @fieldid and languagetype ='zh' and trantable='LD_field';
update ld_tranlabel set fieldlabel = 'The query scope' where tabid = @tabid and Relateid = @fieldid and languagetype ='en' and trantable='LD_field';
delimiter;

select tabid into @tabid from ld_tab where `name` = 'Users';
select fieldid into @fieldid from LD_field where tabid = @tabid and fieldname = 'viewothers';
update ld_tranlabel set fieldlabel = '允许查看其他用户的单据' where tabid = @tabid and Relateid = @fieldid and languagetype ='zh' and trantable='LD_field';
update ld_tranlabel set fieldlabel = 'Allow to view other users data' where tabid = @tabid and Relateid = @fieldid and languagetype ='en' and trantable='LD_field';
delimiter;

select tabid into @tabid from ld_tab where `name` = 'Users';
select fieldid into @fieldid from LD_field where tabid = @tabid and fieldname = 'editothers';
update ld_tranlabel set fieldlabel = '允许编辑其他用户的单据' where tabid = @tabid and Relateid = @fieldid and languagetype ='zh' and trantable='LD_field';
update ld_tranlabel set fieldlabel = 'Allow to edit other users data' where tabid = @tabid and Relateid = @fieldid and languagetype ='en' and trantable='LD_field';
delimiter;

select tabid into @tabid from ld_tab where `name` = 'Users';
select fieldid into @fieldid from LD_field where tabid = @tabid and fieldname = 'delothers';
update ld_tranlabel set fieldlabel = '允许删除其他用户的单据' where tabid = @tabid and Relateid = @fieldid and languagetype ='zh' and trantable='LD_field';
update ld_tranlabel set fieldlabel = 'Allow to delete other users data' where tabid = @tabid and Relateid = @fieldid and languagetype ='en' and trantable='LD_field';
delimiter;

select tabid into @tabid from ld_tab where `name` = 'Users';
select fieldid into @fieldid from LD_field where tabid = @tabid and fieldname = 'viewselfbills';
update ld_tranlabel set fieldlabel = '允许查询自己创建的单据' where tabid = @tabid and Relateid = @fieldid and languagetype ='zh' and trantable='LD_field';
update ld_tranlabel set fieldlabel = 'Allows to query the data which created by myself' where tabid = @tabid and Relateid = @fieldid and languagetype ='en' and trantable='LD_field';
delimiter;

INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype) SELECT 'zh','THEQUERYSCOPE','业务单据授权范围','jspop' FROM DUAL
WHERE NOT EXISTS(SELECT 1 FROM ld_desk  WHERE languagetype='zh' AND labelbol='THEQUERYSCOPE' AND Labeltype='jspop');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype) SELECT 'en','THEQUERYSCOPE','The query scope','jspop' FROM DUAL
WHERE NOT EXISTS(SELECT 1 FROM ld_desk  WHERE languagetype='en' AND labelbol='THEQUERYSCOPE' AND Labeltype='jspop');
delimiter;

INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype) SELECT 'zh','SHARE','共享','jspop' FROM DUAL
WHERE NOT EXISTS(SELECT 1 FROM ld_desk  WHERE languagetype='zh' AND labelbol='SHARE' AND Labeltype='jspop');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype) SELECT 'en','SHARE','Share','jspop' FROM DUAL
WHERE NOT EXISTS(SELECT 1 FROM ld_desk  WHERE languagetype='en' AND labelbol='SHARE' AND Labeltype='jspop');
delimiter;

INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype) SELECT 'zh','VIEWRANGESENIOR','查看范围 - 高级','jspop' FROM DUAL
WHERE NOT EXISTS(SELECT 1 FROM ld_desk  WHERE languagetype='zh' AND labelbol='VIEWRANGESENIOR' AND Labeltype='jspop');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype) SELECT 'en','VIEWRANGESENIOR','ViewRange Senior','jspop' FROM DUAL
WHERE NOT EXISTS(SELECT 1 FROM ld_desk  WHERE languagetype='en' AND labelbol='VIEWRANGESENIOR' AND Labeltype='jspop');
delimiter;

INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype) SELECT 'zh','EDITGROUP','编辑部门','fixedstr' FROM DUAL
WHERE NOT EXISTS(SELECT 1 FROM ld_desk  WHERE languagetype='zh' AND labelbol='EDITGROUP' AND Labeltype='fixedstr');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype) SELECT 'en','EDITGROUP','Edit Group','fixedstr' FROM DUAL
WHERE NOT EXISTS(SELECT 1 FROM ld_desk  WHERE languagetype='en' AND labelbol='EDITGROUP' AND Labeltype='fixedstr');
delimiter;

INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype) SELECT 'zh','EDITGROUP','编辑部门','jspop' FROM DUAL
WHERE NOT EXISTS(SELECT 1 FROM ld_desk  WHERE languagetype='zh' AND labelbol='EDITGROUP' AND Labeltype='jspop');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype) SELECT 'en','EDITGROUP','Edit Group','jspop' FROM DUAL
WHERE NOT EXISTS(SELECT 1 FROM ld_desk  WHERE languagetype='en' AND labelbol='EDITGROUP' AND Labeltype='jspop');
delimiter;

INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype) SELECT 'zh','NEWGROUP','新增部门','jspop' FROM DUAL
WHERE NOT EXISTS(SELECT 1 FROM ld_desk  WHERE languagetype='zh' AND labelbol='NEWGROUP' AND Labeltype='jspop');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype) SELECT 'en','NEWGROUP','New Group','jspop' FROM DUAL
WHERE NOT EXISTS(SELECT 1 FROM ld_desk  WHERE languagetype='en' AND labelbol='NEWGROUP' AND Labeltype='jspop');
delimiter;

update LD_profile2field
LEFT JOIN LD_tab on LD_tab.tabid = LD_profile2field.tabid
LEFT JOIN LD_field on LD_tab.tabid = LD_field.tabid set LD_profile2field.visible = 0
where LD_tab.`name` = 'Accounts' and LD_field.fieldname in ('allocatedate','protectdate');
delimiter;

update LD_desk set fieldlabel = '(在客户相关信息中允许查询所有数据)' where labelbol = 'UsersALLOWQUERY' and languagetype = 'zh' and Labeltype = 'fixedstr';
delimiter;
update LD_desk set fieldlabel = '(需购买并设置通讯账户)' where labelbol = 'NEEDBUYACCOUNT' and languagetype = 'zh' and Labeltype = 'fixedstr';
delimiter;
-- 2015-03-31

DELETE FROM ld_workachments WHERE achmentid = 0;
ALTER TABLE ld_workachments CHANGE achmentid achmentid INT(19);
ALTER TABLE ld_workachments DROP PRIMARY KEY;
ALTER TABLE ld_workachments CHANGE achmentid achmentid INT(19) NOT NULL AUTO_INCREMENT PRIMARY KEY;
delimiter;
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype) SELECT 'zh','LBL_DISTRIBUT_HIGHSEAS','公海分配','fixedstr' FROM DUAL
WHERE NOT EXISTS(SELECT 1 FROM ld_desk  WHERE languagetype='zh' AND labelbol='LBL_DISTRIBUT_HIGHSEAS' AND Labeltype='fixedstr');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype) SELECT 'en','LBL_DISTRIBUT_HIGHSEAS','Distribut highseas','fixedstr' FROM DUAL
WHERE NOT EXISTS(SELECT 1 FROM ld_desk  WHERE languagetype='en' AND labelbol='LBL_DISTRIBUT_HIGHSEAS' AND Labeltype='fixedstr');
delimiter;
SELECT tabid INTO @tabid FROM ld_tab WHERE NAME = 'Accounts';
SELECT fieldid INTO @fieldid FROM ld_field WHERE fieldname = 'lastdistributedate' AND tabid = @tabid;
UPDATE ld_tranlabel SET fieldlabel = '公海分配日期' WHERE tabid = @tabid AND relateid = @fieldid AND languagetype = 'zh';
UPDATE ld_tranlabel SET fieldlabel = 'highseas distributdate' WHERE tabid = @tabid AND relateid = @fieldid AND languagetype = 'en';
delimiter;

INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype) SELECT 'zh','LBL_SUPEGROUP','上级部门','fixedstr' FROM DUAL
WHERE NOT EXISTS(SELECT 1 FROM ld_desk  WHERE languagetype='zh' AND labelbol='LBL_SUPEGROUP' AND Labeltype='fixedstr');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype) SELECT 'en','LBL_SUPEGROUP','The higher authorities','fixedstr' FROM DUAL
WHERE NOT EXISTS(SELECT 1 FROM ld_desk  WHERE languagetype='en' AND labelbol='LBL_SUPEGROUP' AND Labeltype='fixedstr');
delimiter;
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype) SELECT 'zh','LBL_EDITGROUP','编辑部门','fixedstr' FROM DUAL
WHERE NOT EXISTS(SELECT 1 FROM ld_desk  WHERE languagetype='zh' AND labelbol='LBL_EDITGROUP' AND Labeltype='fixedstr');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype) SELECT 'en','LBL_EDITGROUP','The editorial department','fixedstr' FROM DUAL
WHERE NOT EXISTS(SELECT 1 FROM ld_desk  WHERE languagetype='en' AND labelbol='LBL_EDITGROUP' AND Labeltype='fixedstr');
delimiter;
SELECT tabid INTO @tabid FROM ld_tab WHERE NAME = 'PriceBooks';
SELECT MAX(ruleid) INTO @ruleid FROM ld_def_org_share;
INSERT INTO LD_def_org_share(ruleid,tabid,permission,editstatus) SELECT @ruleid+1,@tabid,3,0 FROM DUAL
WHERE NOT EXISTS(SELECT 1 FROM LD_def_org_share WHERE tabid=@tabid);
UPDATE ld_def_org_share_seq SET id = (SELECT MAX(ruleid) FROM ld_def_org_share);
delimiter;
UPDATE ld_desk SET fieldlabel = '管理模块全局共享规则' WHERE labelbol = 'MANAGEMODULESHARE' AND languagetype = 'zh';
UPDATE ld_desk SET fieldlabel = 'Manage module sharing rules' WHERE labelbol = 'MANAGEMODULESHARE' AND languagetype = 'en';
UPDATE ld_settings_field SET description = 'MANAGEMODULESHARE' WHERE NAME = 'LBL_SHARING_ACCESS';
delimiter;
UPDATE ld_settings_field SET active = 1 WHERE NAME = 'LBL_FIELDS_ACCESS';
delimiter;

call AddColumn('LD_templatesrole','profileid','int',11,0);
update LD_templatesrole LEFT JOIN LD_role2profile ON LD_templatesrole.roleid = LD_role2profile.roleid
set LD_templatesrole.profileid = LD_role2profile.profileid;
delimiter;
-- 2015-04-03

call AddColumn('LD_role2picklist','profileid','int',11,0);
update LD_role2picklist LEFT JOIN LD_role2profile ON LD_role2picklist.roleid = LD_role2profile.roleid
set LD_role2picklist.profileid = LD_role2profile.profileid;
delimiter;

insert into ld_actionmapping(actionid,actionname,actionlabel,securitycheck)
select 22,'Advance','ADVANCE',0 from dual
where not EXISTS(select 1 from ld_actionmapping  where actionid = 22);
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','ADVANCE','推进','fixedstr' from dual
where not EXISTS(select 1 from ld_desk  where languagetype='zh' and labelbol='ADVANCE' and Labeltype='fixedstr');
delimiter;
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','ADVANCE','Advance','fixedstr' from dual
where not EXISTS(select 1 from ld_desk  where languagetype='en' and labelbol='ADVANCE' and Labeltype='fixedstr');
delimiter;

select tabid into @tabid from ld_tab where `name` = 'Potentials';
insert into LD_profileallpermission(tabid,operation)
select @tabid,22 from dual where not exists
(select 1 from LD_profileallpermission where tabid = @tabid and operation=22);
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'zh','IMPORT','导入','jspop' from dual
where not EXISTS(select 1 from ld_desk where languagetype='zh' and labelbol='IMPORT' and Labeltype='jspop');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'en','IMPORT','Import','jspop' from dual
where not EXISTS(select 1 from ld_desk where languagetype='en' and labelbol='IMPORT' and Labeltype='jspop');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'zh','Schoolrecorddetails','上课记录明细','fixedstr' from dual
where not EXISTS(select 1 from ld_desk where languagetype='zh' and labelbol='Schoolrecorddetails' and Labeltype='fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'en','Schoolrecorddetails','School record details','fixedstr' from dual
where not EXISTS(select 1 from ld_desk where languagetype='en' and labelbol='Schoolrecorddetails' and Labeltype='fixedstr');
delimiter;

UPDATE ld_relatedlists SET actions='add,select,Import' WHERE related_tabid=(SELECT tabid FROM ld_tab where name='Contacts')
AND tabid=(SELECT tabid FROM ld_tab where name='Potentials');


call addcolumn('ld_potential','classtime','int',19,0);
delimiter;
call addcolumn('ld_potential','product_id','int',19,NULL);
delimiter;
call fieldprofile('Potentials');
delimiter;
call getallprofile('Potentials');
delimiter;


select tabid into @tabid from ld_tab where `name` = 'Potentials';
select id into @fieldid from ld_field_seq;
select blockid into @blockid from ld_blocks where blocklabel = 'LBL_OPPORTUNITY_INFORMATION' and tabid = @tabid;
insert into ld_field(tabid,fieldid,columnname,tablename,uitype,fieldname,fieldlabel,sequence,block,displaytype,presence,typeofdata,quickcreate,info_type)
select @tabid,@fieldid+1,'product_id','LD_potential',59,'product_id','课程',5,@blockid,1,0,'I~O',3,'BAS' from dual where not exists
(select * from ld_field where tabid = @tabid and columnname = 'product_id');
update ld_field_seq set id = (select max(fieldid) from ld_field);

select fieldid into @fieldid from ld_field where tabid = @tabid and columnname = 'product_id';
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'zh','LD_field',@tabid,@fieldid,'课程'
from dual where not EXISTS(select 1 from ld_tranlabel  where languagetype = 'zh'
and trantable ='LD_field' and tabid = @tabid and relateid=@fieldid);
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'en','LD_field',@tabid,@fieldid,'Curriculum'
from dual where not EXISTS(select 1 from ld_tranlabel  where languagetype = 'en'
and trantable ='LD_field' and tabid = @tabid and relateid=@fieldid);
delimiter;

select tabid into @tabid from ld_tab where `name` = 'Potentials';
select id into @fieldid from ld_field_seq;
select blockid into @blockid from ld_blocks where blocklabel = 'LBL_OPPORTUNITY_INFORMATION' and tabid = @tabid;

insert into ld_field(tabid,fieldid,columnname,tablename,uitype,fieldname,fieldlabel,sequence,block,displaytype,presence,typeofdata,quickcreate,info_type)
select @tabid,@fieldid+1,'classtime','LD_potential',2,'classtime','课时',6,@blockid,1,0,'I~O',3,'BAS' from dual where not exists
(select 1 from ld_field where tabid = @tabid and columnname = 'classtime');
update ld_field_seq set id = (select max(fieldid) from ld_field);

select fieldid into @fieldid from ld_field where tabid = @tabid and columnname = 'classtime';
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'zh','LD_field',@tabid,@fieldid,'课时' from dual
where not EXISTS(select 1 from ld_tranlabel  where languagetype = 'zh' and trantable ='LD_field' and tabid = @tabid and relateid=@fieldid);

insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'en','LD_field',@tabid,@fieldid,'Class Time' from dual
where not EXISTS(select 1 from ld_tranlabel  where languagetype = 'en' and trantable ='LD_field' and tabid = @tabid and relateid=@fieldid);
delimiter;

select tabid into @tabid from ld_tab where name = 'Potentials';
SELECT fieldid into @fieldid FROM ld_field WHERE tabid=@tabid AND fieldname='closingdate';
UPDATE ld_tranlabel SET fieldlabel='上课日期' WHERE tabid=@tabid AND Relateid=@fieldid AND languagetype='zh'
and exists (select 1 from ld_version where trade='futai');

UPDATE ld_tranlabel SET fieldlabel='Class Dates' WHERE tabid=@tabid AND Relateid=@fieldid AND languagetype='en'
and exists (select 1 from ld_version where trade='futai');
delimiter;

SELECT usereportid into @id from LD_usereport where name='SalesReport';
SELECT tabid into @tid from LD_tab where name='ServiceContracts';
insert into LD_usereport(usereportid,name,reportlabel,tabids,basicfilter,advfilter,Setcolumns,Parent_id,sequence,reporttype,pagewidthpercent)
select '','hoursqueryreport','复泰课时查询报表',@tid,1,0,1,@id,12,11,100
from dual where not exists(select usereportid from LD_usereport where name='hoursqueryreport');
delimiter;

alter table ld_usereportbasic modify column columns varchar(200);
delimiter;
alter table LD_UseReportcolumns modify column columns varchar(200);
delimiter;
alter table LD_UseReportcolumns modify column realencolumns varchar(200);
delimiter;
alter table LD_UseReportcolumns modify column realcolumns varchar(200);
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','hoursqueryreport','复泰课时查询报表','fixedstr' from dual
where not EXISTS(select 1 from ld_desk where languagetype='zh' and labelbol='hoursqueryreport' and Labeltype='fixedstr');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','hoursqueryreport','Foretell Hours Query Report','fixedstr'
from dual where not EXISTS(select 1 from ld_desk  where languagetype='en' and labelbol='hoursqueryreport' and Labeltype='fixedstr');
delimiter;

select usereportid into @id from LD_usereport where name='hoursqueryreport';
insert into LD_usereportbasic(id,Usereportid,columns,Defaultvalue,Sequence)
select '',@id,'LD_inventoryproductrel:servicecontracts_start_date:servicecontracts_start_date:ServiceContracts_servicecontracts_start_date:D','thisstartmonth~thisendmonth',3
from dual where not exists(select usereportid from LD_usereportbasic where Usereportid=@id and Sequence=3);

select usereportid into @id from LD_usereport where name='hoursqueryreport';
insert into LD_usereportbasic(id,Usereportid,columns,Defaultvalue,Sequence)
select '',@id,'LD_servicecontracts:contract_no:contract_no:ServiceContracts_contract_no:I','',4
from dual where not exists(select usereportid from LD_usereportbasic where Usereportid=@id and Sequence=4);

select usereportid into @id from LD_usereport where name='hoursqueryreport';
insert into LD_usereportbasic(id,Usereportid,columns,Defaultvalue,Sequence)
select '',@id,'LD_products:productname:productname:Products_productname:I','',5
from dual where not exists(select usereportid from LD_usereportbasic where Usereportid=@id and Sequence=5);

select usereportid into @id from LD_usereport where name='hoursqueryreport';
insert into LD_usereportbasic(id,Usereportid,columns,Defaultvalue,Sequence)
select '',@id,'LD_account:accountname:accountname:Accounts_accountname:I','',6
from dual where not exists(select usereportid from LD_usereportbasic where Usereportid=@id and Sequence=6);

select usereportid into @id from LD_usereport where name='hoursqueryreport';

insert into LD_UseReportcolumns(id,Usereportid,columns,Sequence,columnshow,realcolumns,realencolumns)
select '', @id, 'LD_account:last_name:last_name:Accounts_last_name:V', 1, 1, 'LD_account:last_name:last_name:Accounts_销售顾问:V','LD_account:last_name:last_name:Accounts_Sales Consultant:V' from dual
where not exists(select 1 from LD_UseReportcolumns where Usereportid=@id and realcolumns like 'LD_account:last_name:last_name:Accounts_%');

insert into LD_UseReportcolumns(id,Usereportid,columns,Sequence,columnshow,realcolumns,realencolumns)
select '', @id, 'LD_products:productname:productname:Products_productname:V', 2, 1, 'LD_products:productname:productname:Products_课程类别:V','LD_products:productname:productname:Products_Course categories:V' from dual
where not exists(select 1 from LD_UseReportcolumns where Usereportid=@id and realcolumns like 'LD_products:productname:productname:Products_%');

insert into LD_UseReportcolumns(id,Usereportid,columns,Sequence,columnshow,realcolumns,realencolumns)
select '', @id, 'LD_account:accountname:accountname:Accounts_accountname:V', 3, 1, 'LD_account:accountname:accountname:Accounts_客户名称:V','LD_account:accountname:accountname:Accounts_Account name:V' from dual
where not exists(select 1 from LD_UseReportcolumns where Usereportid=@id and realcolumns like 'LD_account:accountname:accountname:Accounts_%');

insert into LD_UseReportcolumns(id,Usereportid,columns,Sequence,columnshow,realcolumns,realencolumns)
select '', @id, 'LD_servicecontracts:contract_no:contract_no:ServiceContracts_contract_no:V', 4, 1, 'LD_servicecontracts:contract_no:contract_no:ServiceContracts_合同编号:V','LD_servicecontracts:contract_no:contract_no:ServiceContracts_Order No:V' from dual
where not exists(select 1 from LD_UseReportcolumns where Usereportid=@id and realcolumns like 'LD_servicecontracts:contract_no:contract_no:ServiceContracts_%');

insert into LD_UseReportcolumns(id,Usereportid,columns,Sequence,columnshow,realcolumns,realencolumns)
select '', @id, 'LD_servicecontracts:start_date:start_date:OftenUseReport_start_date:D', 5, 1, 'LD_servicecontracts:start_date:start_date:OftenUseReport_起始日期:D','LD_servicecontracts:start_date:start_date:OftenUseReport_start date:D' from dual
where not exists(select 1 from LD_UseReportcolumns where Usereportid=@id and realcolumns like 'LD_servicecontracts:start_date:start_date:OftenUseReport_%');

insert into LD_UseReportcolumns(id,Usereportid,columns,Sequence,columnshow,realcolumns,realencolumns)
select '', @id, 'LD_servicecontracts:end_date:end_date:OftenUseReport_end_date:D', 6, 1, 'LD_servicecontracts:end_date:end_date:OftenUseReport_截止日期:D','LD_servicecontracts:end_date:end_date:OftenUseReport_end date:D' from dual
where not exists(select 1 from LD_UseReportcolumns where Usereportid=@id and realcolumns like 'LD_servicecontracts:end_date:end_date:OftenUseReport_%');

insert into LD_UseReportcolumns(id,Usereportid,columns,Sequence,columnshow,realcolumns,realencolumns)
select '', @id, 'LD_servicecontracts:quantity:quantity:OftenUseReport_quantity:N', 7, 1, 'LD_servicecontracts:quantity:quantity:OftenUseReport_总课时:N','LD_servicecontracts:quantity:quantity:OftenUseReport_Total Hours:N' from dual
where not exists(select 1 from LD_UseReportcolumns where Usereportid=@id and realcolumns like 'LD_servicecontracts:quantity:quantity:OftenUseReport_%');

insert into LD_UseReportcolumns(id,Usereportid,columns,Sequence,columnshow,realcolumns,realencolumns)
select '', @id, 'LD_servicecontracts:yiyongtime:yiyongtime:OftenUseReport_yiyongtime:N', 8, 1, 'LD_servicecontracts:yiyongtime:yiyongtime:OftenUseReport_已用课时:N','LD_servicecontracts:yiyongtime:yiyongtime:OftenUseReport_have spent hours:N' from dual
where not exists(select 1 from LD_UseReportcolumns where Usereportid=@id and realcolumns like 'LD_servicecontracts:yiyongtime:yiyongtime:OftenUseReport_%');

insert into LD_UseReportcolumns(id,Usereportid,columns,Sequence,columnshow,realcolumns,realencolumns)
select '', @id, 'LD_servicecontracts:shenyutime:shenyutime:OftenUseReport_shenyutime:N', 9, 1, 'LD_servicecontracts:shenyutime:shenyutime:OftenUseReport_剩余课时:N','LD_servicecontracts:shenyutime:shenyutime:OftenUseReport_remaining hours:N' from dual
where not exists(select 1 from LD_UseReportcolumns where Usereportid=@id and realcolumns like 'LD_servicecontracts:shenyutime:shenyutime:OftenUseReport_%');

insert into LD_UseReportcolumns(id,Usereportid,columns,Sequence,columnshow,realcolumns,realencolumns)
select '', @id, 'LD_potential:description:description:Potentials_description:V', 10, 1, 'LD_potential:description:description:Potentials_备注:V','LD_potential:description:description:Potentials_description:V' from dual
where not exists(select 1 from LD_UseReportcolumns where Usereportid=@id and realcolumns like 'LD_potential:description:description:Potentials_%');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'zh','ClassDates','上课日期','fixedstr' from dual
where not EXISTS(select 1 from ld_desk where languagetype='zh' and labelbol='ClassDates' and Labeltype='fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'en','ClassDates','Class Dates','fixedstr' from dual
where not EXISTS(select 1 from ld_desk where languagetype='en' and labelbol='ClassDates' and Labeltype='fixedstr');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'zh','ClassName','课程名称','fixedstr' from dual
where not EXISTS(select 1 from ld_desk where languagetype='zh' and labelbol='ClassName' and Labeltype='fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'en','ClassName','Class Name','fixedstr' from dual
where not EXISTS(select 1 from ld_desk where languagetype='en' and labelbol='ClassName' and Labeltype='fixedstr');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'zh','StudentName','学员姓名','fixedstr' from dual
where not EXISTS(select 1 from ld_desk where languagetype='zh' and labelbol='StudentName' and Labeltype='fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'en','StudentName','Student Name','fixedstr' from dual
where not EXISTS(select 1 from ld_desk where languagetype='en' and labelbol='StudentName' and Labeltype='fixedstr');
delimiter;

DROP PROCEDURE IF EXISTS `updatecaidandingzhi`;
delimiter ||
CREATE PROCEDURE `updatecaidandingzhi`(

)
begin

CREATE TABLE if not EXISTS digits (digit INT(1));
INSERT INTO digits
VALUES
(0),
(1),
(2),
(3),
(4),
(5),
(6),
(7),
(8),
(9);
CREATE TABLE if not EXISTS sequence (seq INT(3));
INSERT INTO sequence (
SELECT
D1.digit + D2.digit * 10
FROM
digits D1
CROSS JOIN digits D2
);

CREATE TABLE if not exists `parenttab` (
`parenttabid` int(19) NOT NULL,
`menu_profieldid` varchar(255) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

insert into parenttab
select parenttabid,
SUBSTRING_INDEX(SUBSTRING_INDEX(menu_profieldid, ',', seq),',' ,- 1) as menu_profieldid
from sequence cross join ld_parenttab
where
seq BETWEEN 1
AND (
SELECT
1 + LENGTH(menu_profieldid) - LENGTH(REPLACE(menu_profieldid, ',', ''))
)
ORDER BY
parenttabid,
menu_profieldid;

update parenttab inner join ld_role2profile ON parenttab.menu_profieldid=ld_role2profile.roleid set parenttab.menu_profieldid=ld_role2profile.profileid;

update ld_parenttab inner join
(select parenttabid,group_concat(menu_profieldid) as menu_profieldid1 from (select DISTINCT parenttabid,menu_profieldid from parenttab group by parenttabid,menu_profieldid) as parenttab group by parenttabid) as t1
on t1.parenttabid=ld_parenttab.parenttabid set ld_parenttab.menu_profieldid=t1.menu_profieldid1;

drop table digits;
drop table sequence;
drop table parenttab;
end ||
delimiter;

call updatecaidandingzhi;
delimiter;

insert into ld_actionmapping(actionid,actionname,actionlabel,securitycheck)
select 23,'Updatestate','UPDATESTATE',0 from dual
where not EXISTS(select 1 from ld_actionmapping  where actionid = 23);
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','UPDATESTATE','更改状态','fixedstr' from dual
where not EXISTS(select 1 from ld_desk  where languagetype='zh' and labelbol='UPDATESTATE' and Labeltype='fixedstr');
delimiter;
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','UPDATESTATE','Update state','fixedstr' from dual
where not EXISTS(select 1 from ld_desk  where languagetype='en' and labelbol='UPDATESTATE' and Labeltype='fixedstr');
delimiter;

select tabid into @tabid from ld_tab where `name` = 'SalesOrder';
insert into LD_profileallpermission(tabid,operation)
select @tabid,23 from dual where not exists
(select 1 from LD_profileallpermission where tabid = @tabid and operation=23);
delimiter;

select tabid into @tabid from ld_tab where `name` = 'ServiceContracts';
insert into LD_profileallpermission(tabid,operation)
select @tabid,23 from dual where not exists
(select 1 from LD_profileallpermission where tabid = @tabid and operation=23);
delimiter;


select tabid into @tabid from ld_tab where `name` = 'PurchaseOrder';
insert into LD_profileallpermission(tabid,operation)
select @tabid,23 from dual where not exists
(select 1 from LD_profileallpermission where tabid = @tabid and operation=23);
delimiter;

update ld_approve2role
INNER JOIN ld_role2profile on ld_role2profile.roleid = ld_approve2role.roleid set ld_approve2role.roleid = ld_role2profile.profileid;
delimiter;

update ld_users
INNER JOIN ld_user2role on ld_user2role.userid = ld_users.id
INNER JOIN ld_role2profile on ld_role2profile.roleid = ld_user2role.roleid
set ld_users.profileid = ld_role2profile.profileid where ld_users.profileid = '' or ld_users.profileid is null or ld_users.profileid = 0;
delimiter;
-- 2015-04-07

CREATE TABLE if not exists `ld_workreport_remind` (
  `relatedtable` varchar(20) DEFAULT NULL ,
  `id` int(19) NOT NULL AUTO_INCREMENT,
  `remindtype` int(4) DEFAULT NULL ,
  `relatedto` int(19) DEFAULT NULL,
  `userid` int(19) DEFAULT NULL ,
  `createdtime` datetime DEFAULT NULL,
  `content` text,
  `remind_status` int(4) DEFAULT '0' ,
  `operationtype` int(4) DEFAULT NULL ,
  PRIMARY KEY (`id`),
  KEY `idx_reminds_tabletype_remindtype_remindstatus` (`relatedtable`,`remindtype`)
) ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=utf8;
delimiter;

call AddColumn('ld_praise','createdtime','datetime',10,NULL);
delimiter;

update ld_users set scopeauthority = 1,viewothers = 1,editothers = 1,delothers = 1,viewselfbills = 1 where id = 1;
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'zh','lotrecreport','乐瑞固报表','fixedstr' from dual
where not EXISTS(select 1 from ld_desk where languagetype='zh' and labelbol='lotrecreport' and Labeltype='fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'en','lotrecreport','lotrec report','fixedstr' from dual
where not EXISTS(select 1 from ld_desk where languagetype='en' and labelbol='lotrecreport' and Labeltype='fixedstr');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'zh','lotrectotalreceivablesalesreport','乐瑞固总帐款销售表','fixedstr' from dual
where not EXISTS(select 1 from ld_desk where languagetype='zh' and labelbol='lotrectotalreceivablesalesreport' and Labeltype='fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'en','lotrectotalreceivablesalesreport','lotrectotal receivable sales report','fixedstr' from dual
where not EXISTS(select 1 from ld_desk where languagetype='en' and labelbol='lotrectotalreceivablesalesreport' and Labeltype='fixedstr');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'zh','DeliveryDate','交付日期','fixedstr' from dual
where not EXISTS(select 1 from ld_desk where languagetype='zh' and labelbol='DeliveryDate' and Labeltype='fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'en','DeliveryDate','Delivery Date','fixedstr' from dual
where not EXISTS(select 1 from ld_desk where languagetype='en' and labelbol='DeliveryDate' and Labeltype='fixedstr');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'zh','Lotnumber','批号','fixedstr' from dual
where not EXISTS(select 1 from ld_desk where languagetype='zh' and labelbol='Lotnumber' and Labeltype='fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'en','Lotnumber','Lot number','fixedstr' from dual
where not EXISTS(select 1 from ld_desk where languagetype='en' and labelbol='Lotnumber' and Labeltype='fixedstr');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'zh','Servicepersonnel','服务人员','fixedstr' from dual
where not EXISTS(select 1 from ld_desk where languagetype='zh' and labelbol='Servicepersonnel' and Labeltype='fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'en','Servicepersonnel','Service personnel','fixedstr' from dual
where not EXISTS(select 1 from ld_desk where languagetype='en' and labelbol='Servicepersonnel' and Labeltype='fixedstr');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'zh','Newandoldcustomers','新老客户','fixedstr' from dual
where not EXISTS(select 1 from ld_desk where languagetype='zh' and labelbol='Newandoldcustomers' and Labeltype='fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'en','Newandoldcustomers','New and old customers','fixedstr' from dual
where not EXISTS(select 1 from ld_desk where languagetype='en' and labelbol='Newandoldcustomers' and Labeltype='fixedstr');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'zh','Todatemodels','到款日期','fixedstr' from dual
where not EXISTS(select 1 from ld_desk where languagetype='zh' and labelbol='Todatemodels' and Labeltype='fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'en','Todatemodels','To date models','fixedstr' from dual
where not EXISTS(select 1 from ld_desk where languagetype='en' and labelbol='Todatemodels' and Labeltype='fixedstr');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'zh','ProductCategories1','产品分类','fixedstr' from dual
where not EXISTS(select 1 from ld_desk where languagetype='zh' and labelbol='ProductCategories1' and Labeltype='fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'en','ProductCategories1','Product Categories','fixedstr' from dual
where not EXISTS(select 1 from ld_desk where languagetype='en' and labelbol='ProductCategories1' and Labeltype='fixedstr');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'zh','Brand','品牌','fixedstr' from dual
where not EXISTS(select 1 from ld_desk where languagetype='zh' and labelbol='Brand' and Labeltype='fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'en','Brand','Brand','fixedstr' from dual
where not EXISTS(select 1 from ld_desk where languagetype='en' and labelbol='Brand' and Labeltype='fixedstr');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'zh','Trademark','牌号','fixedstr' from dual
where not EXISTS(select 1 from ld_desk where languagetype='zh' and labelbol='Trademark' and Labeltype='fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'en','Trademark','Trademark','fixedstr' from dual
where not EXISTS(select 1 from ld_desk where languagetype='en' and labelbol='Trademark' and Labeltype='fixedstr');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'zh','Packing','包装规格','fixedstr' from dual
where not EXISTS(select 1 from ld_desk where languagetype='zh' and labelbol='Packing' and Labeltype='fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'en','Packing','Packing','fixedstr' from dual
where not EXISTS(select 1 from ld_desk where languagetype='en' and labelbol='Packing' and Labeltype='fixedstr');
delimiter;
SELECT usereportid INTO @id FROM ld_usereport WHERE NAME='Thestatisticalreportofprojectperformance';

UPDATE ld_usereportcolumns SET realcolumns='LD_salesorder:salesorder_no:salesorder_no:SalesOrder_订单:D',
realencolumns='LD_salesorder:salesorder_no:salesorder_no:SalesOrder_order no:D'
WHERE Usereportid=@id AND columns LIKE 'LD_salesorder:salesorder_no:salesorder_no:SalesOrder_%';
delimiter;
-- 2015-04-11

SELECT tabid INTO @tabid FROM ld_tab WHERE NAME = 'Users';
SELECT fieldid INTO @fieldid FROM ld_field WHERE tabid = @tabid AND columnname = 'accountallview';
UPDATE ld_tranlabel SET fieldlabel = '允许查看全景资料' WHERE relateid = @fieldid AND languagetype = 'zh';
UPDATE ld_tranlabel SET fieldlabel = 'Allows to view all data' WHERE relateid = @fieldid AND languagetype = 'en';
delimiter;
UPDATE ld_desk SET fieldlabel = '在相关信息中允许查询所有数据' WHERE labelbol = 'UsersALLOWQUERY' AND languagetype = 'zh';
UPDATE ld_desk SET fieldlabel = 'Allows to view all data in the relevant information' WHERE labelbol = 'UsersALLOWQUERY' AND languagetype = 'en';
delimiter;
-- 2015-04-13

call AddColumn('ld_workreport','longtitude','varchar',50,NULL);
call AddColumn('ld_workreport','latitude','varchar',50,NULL);
delete from ld_actionmapping where securitycheck = 1;
-- 2015-04-15


select tabid into @tabid from ld_tab where `name` = 'PriceBooks';
insert into LD_org_share_action2tab(share_action_id,tabid)
select 0,@tabid from dual where not exists(select 1 from ld_org_share_action2tab where share_action_id = 0 and tabid = @tabid);
insert into LD_org_share_action2tab(share_action_id,tabid)
select 1,@tabid from dual where not exists(select 1 from ld_org_share_action2tab where share_action_id = 1 and tabid = @tabid);
insert into LD_org_share_action2tab(share_action_id,tabid)
select 2,@tabid from dual where not exists(select 1 from ld_org_share_action2tab where share_action_id = 2 and tabid = @tabid);
insert into LD_org_share_action2tab(share_action_id,tabid)
select 3,@tabid from dual where not exists(select 1 from ld_org_share_action2tab where share_action_id = 3 and tabid = @tabid);
update ld_def_org_share set permission = 3 where tabid = @tabid and (permission is null or permission = '');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,Labeltype)
select 'zh','DELETEPROFILE','删除权限','fixedstr'
from dual where not exists(select 1 from ld_desk where languagetype = 'zh' and labelbol = 'DELETEPROFILE' and Labeltype='fixedstr');
delimiter;
insert into ld_desk(languagetype,labelbol,fieldlabel,Labeltype)
select 'en','DELETEPROFILE','Delete Profile','fixedstr'
from dual where not exists(select 1 from ld_desk where languagetype = 'en' and labelbol = 'DELETEPROFILE' and Labeltype='fixedstr');
delimiter;

insert into LD_usereport(usereportid,name,reportlabel,tabids,basicfilter,advfilter,Setcolumns,Parent_id,sequence,reporttype,pagewidthpercent)
select '','JIERUNREPORTS','杰润报表',0,0,0,0,0,5,0,100
from dual where not exists(select usereportid from LD_usereport where name='JIERUNREPORTS');

SELECT usereportid into @id from LD_usereport where name='JIERUNREPORTS';
SELECT tabid into @tid from LD_tab where name='Potentials';
insert into LD_usereport(usereportid,name,reportlabel,tabids,basicfilter,advfilter,Setcolumns,Parent_id,sequence,reporttype,pagewidthpercent)
select '','Eachprojectcontractincomestatisticsreport','合同收入统计表',@tid,1,0,1,@id,1,5,100
from dual where not exists(select usereportid from LD_usereport where name='Eachprojectcontractincomestatisticsreport');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'zh','JIERUNREPORTS','杰润报表','fixedstr' from dual where not EXISTS(select 1 from ld_desk where languagetype='zh' and labelbol='JIERUNREPORTS' and Labeltype='fixedstr');

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'en','JIERUNREPORTS','jierun report','fixedstr' from dual where not EXISTS(select 1 from ld_desk  where languagetype='en' and labelbol='JIERUNREPORTS' and Labeltype='fixedstr');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'zh','Eachprojectcontractincomestatisticsreport','合同收入统计表','fixedstr' from dual where not EXISTS(select 1 from ld_desk where languagetype='zh' and labelbol='Eachprojectcontractincomestatisticsreport' and Labeltype='fixedstr');

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'en','Eachprojectcontractincomestatisticsreport','Each project contract income statistics report','fixedstr' from dual where not EXISTS(select 1 from ld_desk  where languagetype='en' and labelbol='Eachprojectcontractincomestatisticsreport' and Labeltype='fixedstr');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'zh','Collectioncompleted','收款已完成','fixedstr' from dual where not EXISTS(select 1 from ld_desk where languagetype='zh' and labelbol='Collectioncompleted' and Labeltype='fixedstr');

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'en','Collectioncompleted','Collection completed','fixedstr' from dual where not EXISTS(select 1 from ld_desk  where languagetype='en' and labelbol='Collectioncompleted' and Labeltype='fixedstr');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'zh','Collectionnotcompleted','收款未完成','fixedstr' from dual where not EXISTS(select 1 from ld_desk where languagetype='zh' and labelbol='Collectionnotcompleted' and Labeltype='fixedstr');

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'en','Collectionnotcompleted','Collection not completed','fixedstr' from dual where not EXISTS(select 1 from ld_desk  where languagetype='en' and labelbol='Collectionnotcompleted' and Labeltype='fixedstr');
delimiter;

select usereportid into @id from LD_usereport where name='Eachprojectcontractincomestatisticsreport';
insert into LD_usereportbasic(id,Usereportid,columns,Defaultvalue,Sequence)
select '',@id,'LD_potential:createdtime:createdtime:Potentials_createdtime:D','thisstartmonth~thisendmonth',3
from dual where not exists(select usereportid from LD_usereportbasic where Usereportid=@id and Sequence=3);
delimiter;

select usereportid into @id from LD_usereport where name='Eachprojectcontractincomestatisticsreport';
insert into LD_usereportbasic(id,Usereportid,columns,Defaultvalue,Sequence)
select '',@id,'LD_potential:potentialname:potentialname:Potentials_potentialname:I','',4
from dual where not exists(select usereportid from LD_usereportbasic where Usereportid=@id and Sequence=4);
delimiter;

select usereportid into @id from LD_usereport where name='Eachprojectcontractincomestatisticsreport';
insert into LD_usereportbasic(id,Usereportid,columns,Defaultvalue,Sequence)
select '',@id,'LD_potential:potential_no:potential_no:Potentials_potential_no:I','',5
from dual where not exists(select usereportid from LD_usereportbasic where Usereportid=@id and Sequence=5);
delimiter;

select usereportid into @id from LD_usereport where name='Eachprojectcontractincomestatisticsreport';
insert into LD_usereportbasic(id,Usereportid,columns,Defaultvalue,Sequence)
select '',@id,'ld_account:accountname:accountname:Accounts_accountname:I','',6
from dual where not exists(select usereportid from LD_usereportbasic where Usereportid=@id and Sequence=6);
delimiter;

select usereportid into @id from LD_usereport where name='Eachprojectcontractincomestatisticsreport';
insert into LD_usereportbasic(id,Usereportid,columns,Defaultvalue,Sequence)
select '',@id,'LD_salesorder:subject:subject:SalesOrder_subject:I','',7
from dual where not exists(select usereportid from LD_usereportbasic where Usereportid=@id and Sequence=7);
delimiter;

select usereportid into @id from LD_usereport where name='Eachprojectcontractincomestatisticsreport';
insert into LD_usereportbasic(id,Usereportid,columns,Defaultvalue,Sequence)
select '',@id,'LD_salesorder:signed_data:signed_data:SalesOrder_subject:I','',8
from dual where not exists(select usereportid from LD_usereportbasic where Usereportid=@id and Sequence=8);
delimiter;

select usereportid into @id from LD_usereport where name='Eachprojectcontractincomestatisticsreport';

insert into LD_UseReportcolumns(id,Usereportid,columns,Sequence,columnshow,realcolumns,realencolumns)
select '', @id, 'LD_potential:potentialname:potentialname:Potentials_potentialname:V', 1, 1, 'LD_potential:potentialname:potentialname:Potentials_项目:V','LD_potential:potentialname:potentialname:Potentials_project:V'
from dual where not exists(select 1 from LD_UseReportcolumns where Usereportid=@id and realcolumns like 'LD_potential:potentialname:potentialname:Potentials_%');

insert into LD_UseReportcolumns(id,Usereportid,columns,Sequence,columnshow,realcolumns,realencolumns)
select '', @id, 'LD_account:accountname:accountname:Accounts_accountname:V', 2, 1, 'LD_account:accountname:accountname:Accounts_客户:V','LD_account:last_name:last_name:Accounts_Accounts:V'
from dual where not exists(select 1 from LD_UseReportcolumns where Usereportid=@id and realcolumns like 'LD_account:accountname:accountname:Accounts_%');

insert into LD_UseReportcolumns(id,Usereportid,columns,Sequence,columnshow,realcolumns,realencolumns)
select '', @id, 'LD_salesorder:subject:subject:SalesOrder_subject:V', 3, 1, 'LD_salesorder:subject:subject:SalesOrder_合同:V','LD_salesorder:subject:subject:SalesOrder_Sales Order:V'
from dual where not exists(select 1 from LD_UseReportcolumns where Usereportid=@id and realcolumns like 'LD_salesorder:subject:subject:SalesOrder_%');

insert into LD_UseReportcolumns(id,Usereportid,columns,Sequence,columnshow,realcolumns,realencolumns)
select '', @id, 'LD_salesorder:total:total:SalesOrder_total:N', 4, 1, 'LD_salesorder:total:total:SalesOrder_合同价:N','LD_salesorder:total:total:SalesOrder_Sales Order Total:N'
from dual where not exists(select 1 from LD_UseReportcolumns where Usereportid=@id and realcolumns like 'LD_salesorder:total:total:SalesOrder_%');

insert into LD_UseReportcolumns(id,Usereportid,columns,Sequence,columnshow,realcolumns,realencolumns)
select '', @id, 'LD_reporttable:CashBillamount:CashBillamount:OftenUseReport_CashBillamount:N', 5, 1, 'LD_reporttable:CashBillamount:CashBillamount:OftenUseReport_已收款:N','LD_reporttable:CashBillamount:CashBillamount:OftenUseReport_CashBill amount:N'
from dual where not exists(select 1 from LD_UseReportcolumns where Usereportid=@id and realcolumns like 'LD_reporttable:CashBillamount:CashBillamount:OftenUseReport_%');

insert into LD_UseReportcolumns(id,Usereportid,columns,Sequence,columnshow,realcolumns,realencolumns)
select '', @id, 'LD_reporttable:Receivedproportion:Receivedproportion:OftenUseReport_Receivedproportion:V', 6, 1, 'LD_reporttable:Receivedproportion:Receivedproportion:OftenUseReport_已收比例:V','LD_reporttable:Receivedproportion:Receivedproportion:OftenUseReport_Received proportion:V'
from dual where not exists(select 1 from LD_UseReportcolumns where Usereportid=@id and realcolumns like 'LD_reporttable:Receivedproportion:Receivedproportion:OftenUseReport_%');

insert into LD_UseReportcolumns(id,Usereportid,columns,Sequence,columnshow,realcolumns,realencolumns)
select '', @id, 'LD_reporttable:PaymentPlanBalance:PaymentPlanBalance:OftenUseReport_PaymentPlanBalance:N', 7, 1, 'LD_reporttable:PaymentPlanBalance:PaymentPlanBalance:OftenUseReport_未收款:N','LD_reporttable:PaymentPlanBalance:PaymentPlanBalance:OftenUseReport_CashBill amount:N'
from dual where not exists(select 1 from LD_UseReportcolumns where Usereportid=@id and realcolumns like 'LD_reporttable:PaymentPlanBalance:PaymentPlanBalance:OftenUseReport_%');

insert into LD_UseReportcolumns(id,Usereportid,columns,Sequence,columnshow,realcolumns,realencolumns)
select '', @id, 'LD_reporttable:proportionuncollected:proportionuncollected:OftenUseReport_proportionuncollected:V', 8, 1, 'LD_reporttable:proportionuncollected:proportionuncollected:OftenUseReport_未收比例:V','LD_reporttable:proportionuncollected:proportionuncollected:OftenUseReport_proportion uncollected:V'
from dual where not exists(select 1 from LD_UseReportcolumns where Usereportid=@id and realcolumns like 'LD_reporttable:proportionuncollected:proportionuncollected:OftenUseReport_%');

insert into LD_UseReportcolumns(id,Usereportid,columns,Sequence,columnshow,realcolumns,realencolumns)
select '', @id, 'LD_potentialscf:cf_1556:cf_1556:Potentials_cf_1556:N', 9, 1, 'LD_potentialscf:cf_1556:cf_1556:Potentials_工程进度:V','LD_potentialscf:cf_1556:cf_1556:Potentials_Progress:V'
from dual where not exists(select 1 from LD_UseReportcolumns where Usereportid=@id and realcolumns like 'LD_potentialscf:cf_1556:cf_1556:Potentials_%');

SELECT usereportid into @id from LD_usereport where name='JIERUNREPORTS';
SELECT tabid into @tid from LD_tab where name='Potentials';
insert into LD_usereport(usereportid,name,reportlabel,tabids,basicfilter,advfilter,Setcolumns,Parent_id,sequence,reporttype,pagewidthpercent)
select '','Orderexpenditurestatisticsreport','合同支出统计表',@tid,1,0,1,@id,2,5,100
from dual where not exists(select usereportid from LD_usereport where name='Orderexpenditurestatisticsreport');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'zh','Orderexpenditurestatisticsreport','合同支出统计表','fixedstr' from dual where not EXISTS(select 1 from ld_desk where languagetype='zh' and labelbol='Orderexpenditurestatisticsreport' and Labeltype='fixedstr');

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'en','Orderexpenditurestatisticsreport','Order expenditure statistics report','fixedstr' from dual where not EXISTS(select 1 from ld_desk  where languagetype='en' and labelbol='Orderexpenditurestatisticsreport' and Labeltype='fixedstr');
delimiter;

select usereportid into @id from LD_usereport where name='Orderexpenditurestatisticsreport';
insert into LD_usereportbasic(id,Usereportid,columns,Defaultvalue,Sequence)
select '',@id,'LD_potential:createdtime:createdtime:Potentials_createdtime:D','thisstartmonth~thisendmonth',3
from dual where not exists(select usereportid from LD_usereportbasic where Usereportid=@id and Sequence=3);
delimiter;

select usereportid into @id from LD_usereport where name='Orderexpenditurestatisticsreport';
insert into LD_usereportbasic(id,Usereportid,columns,Defaultvalue,Sequence)
select '',@id,'LD_potential:potentialname:potentialname:Potentials_potentialname:I','',4
from dual where not exists(select usereportid from LD_usereportbasic where Usereportid=@id and Sequence=4);
delimiter;

select usereportid into @id from LD_usereport where name='Orderexpenditurestatisticsreport';
insert into LD_usereportbasic(id,Usereportid,columns,Defaultvalue,Sequence)
select '',@id,'LD_potential:potential_no:potential_no:Potentials_potential_no:I','',5
from dual where not exists(select usereportid from LD_usereportbasic where Usereportid=@id and Sequence=5);
delimiter;

select usereportid into @id from LD_usereport where name='Orderexpenditurestatisticsreport';
insert into LD_usereportbasic(id,Usereportid,columns,Defaultvalue,Sequence)
select '',@id,'ld_account:accountname:accountname:Accounts_accountname:I','',6
from dual where not exists(select usereportid from LD_usereportbasic where Usereportid=@id and Sequence=6);
delimiter;

select usereportid into @id from LD_usereport where name='Orderexpenditurestatisticsreport';
insert into LD_usereportbasic(id,Usereportid,columns,Defaultvalue,Sequence)
select '',@id,'LD_purchaseorder:subject:subject:PurchaseOrder_subject:I','',7
from dual where not exists(select usereportid from LD_usereportbasic where Usereportid=@id and Sequence=7);
delimiter;

select usereportid into @id from LD_usereport where name='Orderexpenditurestatisticsreport';
insert into LD_UseReportcolumns(id,Usereportid,columns,Sequence,columnshow,realcolumns,realencolumns)
select '', @id, 'LD_potential:potentialname:potentialname:Potentials_potentialname:V', 1, 1, 'LD_potential:potentialname:potentialname:Potentials_项目:V','LD_potential:potentialname:potentialname:Potentials_project:V'
from dual where not exists(select 1 from LD_UseReportcolumns where Usereportid=@id and realcolumns like 'LD_potential:potentialname:potentialname:Potentials_%');

insert into LD_UseReportcolumns(id,Usereportid,columns,Sequence,columnshow,realcolumns,realencolumns)
select '', @id, 'LD_account:accountname:accountname:Accounts_accountname:V', 2, 1, 'LD_account:accountname:accountname:Accounts_客户:V','LD_account:last_name:last_name:Accounts_Accounts:V'
from dual where not exists(select 1 from LD_UseReportcolumns where Usereportid=@id and realcolumns like 'LD_account:accountname:accountname:Accounts_%');

insert into LD_UseReportcolumns(id,Usereportid,columns,Sequence,columnshow,realcolumns,realencolumns)
select '', @id, 'LD_salesorder:subject:subject:SalesOrder_subject:V', 3, 1, 'LD_salesorder:subject:subject:SalesOrder_收入合同:V','LD_salesorder:subject:subject:SalesOrder_Sales Order:V'
from dual where not exists(select 1 from LD_UseReportcolumns where Usereportid=@id and realcolumns like 'LD_salesorder:subject:subject:SalesOrder_%');

insert into LD_UseReportcolumns(id,Usereportid,columns,Sequence,columnshow,realcolumns,realencolumns)
select '', @id, 'LD_purchaseorder:subject:subject:PurchaseOrder_subject:V', 4, 1, 'LD_purchaseorder:subject:subject:PurchaseOrder_付款合同:V','LD_purchaseorder:subject:subject:PurchaseOrder_
Payment Order:V'
from dual where not exists(select 1 from LD_UseReportcolumns where Usereportid=@id and realcolumns like 'LD_purchaseorder:subject:subject:PurchaseOrder_%');

insert into LD_UseReportcolumns(id,Usereportid,columns,Sequence,columnshow,realcolumns,realencolumns)
select '', @id, 'LD_purchaseorder:total:total:PurchaseOrder_total:N', 5, 1, 'LD_purchaseorder:total:total:PurchaseOrder_合同价:N','LD_purchaseorder:total:total:PurchaseOrder_Order Total:N'
from dual where not exists(select 1 from LD_UseReportcolumns where Usereportid=@id and realcolumns like 'LD_purchaseorder:total:total:PurchaseOrder_%');

insert into LD_UseReportcolumns(id,Usereportid,columns,Sequence,columnshow,realcolumns,realencolumns)
select '', @id, 'LD_reporttable:SendCashBillamount:SendCashBillamount:OftenUseReport_SendCashBillamount:N', 6, 1, 'LD_reporttable:SendCashBillamount:SendCashBillamount:OftenUseReport_已付:N','LD_reporttable:SendCashBillamount:SendCashBillamount:OftenUseReport_CashBill amount:N'
from dual where not exists(select 1 from LD_UseReportcolumns where Usereportid=@id and realcolumns like 'LD_reporttable:SendCashBillamount:SendCashBillamount:OftenUseReport_%');

insert into LD_UseReportcolumns(id,Usereportid,columns,Sequence,columnshow,realcolumns,realencolumns)
select '', @id, 'LD_reporttable:SendCashBillBalance:SendCashBillBalance:OftenUseReport_SendCashBillBalance:N', 7, 1, 'LD_reporttable:SendCashBillBalance:SendCashBillBalance:OftenUseReport_未付:N','LD_reporttable:SendCashBillBalance:SendCashBillBalance:OftenUseReport_CashBill amount:N'
from dual where not exists(select 1 from LD_UseReportcolumns where Usereportid=@id and realcolumns like 'LD_reporttable:SendCashBillBalance:SendCashBillBalance:OftenUseReport_%');

insert into LD_UseReportcolumns(id,Usereportid,columns,Sequence,columnshow,realcolumns,realencolumns)
select '', @id, 'LD_reporttable:proportionpaid:proportionpaid:OftenUseReport_proportionpaid:V', 8, 1, 'LD_reporttable:proportionpaid:proportionpaid:OftenUseReport_已付比例:V','LD_reporttable:proportionpaid:proportionpaid:OftenUseReport_Received proportion:V'
from dual where not exists(select 1 from LD_UseReportcolumns where Usereportid=@id and realcolumns like 'LD_reporttable:proportionpaid:proportionpaid:OftenUseReport_%');

insert into LD_UseReportcolumns(id,Usereportid,columns,Sequence,columnshow,realcolumns,realencolumns)
select '', @id, 'LD_reporttable:Unpaidproportion:Unpaidproportion:OftenUseReport_Unpaidproportion:V', 9, 1, 'LD_reporttable:Unpaidproportion:Unpaidproportion:OftenUseReport_未付比例:V','LD_reporttable:Unpaidproportion:Unpaidproportion:OftenUseReport_Received proportion:V'
from dual where not exists(select 1 from LD_UseReportcolumns where Usereportid=@id and realcolumns like 'LD_reporttable:Unpaidproportion:Unpaidproportion:OftenUseReport_%');

SELECT usereportid into @id from LD_usereport where name='JIERUNREPORTS';
SELECT tabid into @tid from LD_tab where name='Potentials';
insert into LD_usereport(usereportid,name,reportlabel,tabids,basicfilter,advfilter,Setcolumns,Parent_id,sequence,reporttype,pagewidthpercent)
select '','Allpaymentsstatisticsreport','所有收支统计表',@tid,1,0,1,@id,3,5,100
from dual where not exists(select usereportid from LD_usereport where name='Allpaymentsstatisticsreport');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'zh','Allpaymentsstatisticsreport','所有收支统计表','fixedstr' from dual where not EXISTS(select 1 from ld_desk where languagetype='zh' and labelbol='Allpaymentsstatisticsreport' and Labeltype='fixedstr');

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'en','Allpaymentsstatisticsreport','All payments statistics report','fixedstr' from dual where not EXISTS(select 1 from ld_desk  where languagetype='en' and labelbol='Allpaymentsstatisticsreport' and Labeltype='fixedstr');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'zh','Paymentcompleted','付款已完成','fixedstr' from dual where not EXISTS(select 1 from ld_desk where languagetype='zh' and labelbol='Paymentcompleted' and Labeltype='fixedstr');

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'en','Paymentcompleted','Payment completed','fixedstr' from dual where not EXISTS(select 1 from ld_desk  where languagetype='en' and labelbol='Paymentcompleted' and Labeltype='fixedstr');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'zh','Paymentnotcompleted','付款未完成','fixedstr' from dual where not EXISTS(select 1 from ld_desk where languagetype='zh' and labelbol='Paymentnotcompleted' and Labeltype='fixedstr');

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'en','Paymentnotcompleted','Payment not completed','fixedstr' from dual where not EXISTS(select 1 from ld_desk  where languagetype='en' and labelbol='Paymentnotcompleted' and Labeltype='fixedstr');
delimiter;

select usereportid into @id from LD_usereport where name='Allpaymentsstatisticsreport';
insert into LD_usereportbasic(id,Usereportid,columns,Defaultvalue,Sequence)
select '',@id,'LD_potential:createdtime:createdtime:Potentials_createdtime:D','thisstartmonth~thisendmonth',3
from dual where not exists(select usereportid from LD_usereportbasic where Usereportid=@id and Sequence=3);
delimiter;

select usereportid into @id from LD_usereport where name='Allpaymentsstatisticsreport';
insert into LD_usereportbasic(id,Usereportid,columns,Defaultvalue,Sequence)
select '',@id,'LD_potential:potentialname:potentialname:Potentials_potentialname:I','',4
from dual where not exists(select usereportid from LD_usereportbasic where Usereportid=@id and Sequence=4);
delimiter;

select usereportid into @id from LD_usereport where name='Allpaymentsstatisticsreport';
insert into LD_usereportbasic(id,Usereportid,columns,Defaultvalue,Sequence)
select '',@id,'LD_potential:potential_no:potential_no:Potentials_potential_no:I','',5
from dual where not exists(select usereportid from LD_usereportbasic where Usereportid=@id and Sequence=5);
delimiter;

select usereportid into @id from LD_usereport where name='Allpaymentsstatisticsreport';
insert into LD_usereportbasic(id,Usereportid,columns,Defaultvalue,Sequence)
select '',@id,'ld_account:accountname:accountname:Accounts_accountname:I','',6
from dual where not exists(select usereportid from LD_usereportbasic where Usereportid=@id and Sequence=6);
delimiter;

select usereportid into @id from LD_usereport where name='Allpaymentsstatisticsreport';
insert into LD_usereportbasic(id,Usereportid,columns,Defaultvalue,Sequence)
select '',@id,'LD_purchaseorder:subject:subject:PurchaseOrder_subject:I','',7
from dual where not exists(select usereportid from LD_usereportbasic where Usereportid=@id and Sequence=7);
delimiter;

select usereportid into @id from LD_usereport where name='Allpaymentsstatisticsreport';
insert into LD_usereportbasic(id,Usereportid,columns,Defaultvalue,Sequence)
select '',@id,'LD_salesorder:salesorder_no:salesorder_no:SalesOrder_salesorder_no:I','',8
from dual where not exists(select usereportid from LD_usereportbasic where Usereportid=@id and Sequence=8);
delimiter;

select usereportid into @id from LD_usereport where name='Allpaymentsstatisticsreport';
insert into LD_UseReportcolumns(id,Usereportid,columns,Sequence,columnshow,realcolumns,realencolumns)
select '', @id, 'LD_potential:potentialname:potentialname:Potentials_potentialname:V', 1, 1, 'LD_potential:potentialname:potentialname:Potentials_项目:V','LD_potential:potentialname:potentialname:Potentials_project:V'
from dual where not exists(select 1 from LD_UseReportcolumns where Usereportid=@id and realcolumns like 'LD_potential:potentialname:potentialname:Potentials_%');

insert into LD_UseReportcolumns(id,Usereportid,columns,Sequence,columnshow,realcolumns,realencolumns)
select '', @id, 'LD_account:accountname:accountname:Accounts_accountname:V', 2, 1, 'LD_account:accountname:accountname:Accounts_客户:V','LD_account:last_name:last_name:Accounts_Accounts:V'
from dual where not exists(select 1 from LD_UseReportcolumns where Usereportid=@id and realcolumns like 'LD_account:accountname:accountname:Accounts_%');

insert into LD_UseReportcolumns(id,Usereportid,columns,Sequence,columnshow,realcolumns,realencolumns)
select '', @id, 'LD_salesorder:subject:subject:SalesOrder_subject:V', 3, 1, 'LD_salesorder:subject:subject:SalesOrder_合同:V','LD_salesorder:subject:subject:SalesOrder_Sales Order:V'
from dual where not exists(select 1 from LD_UseReportcolumns where Usereportid=@id and realcolumns like 'LD_salesorder:subject:subject:SalesOrder_%');

insert into LD_UseReportcolumns(id,Usereportid,columns,Sequence,columnshow,realcolumns,realencolumns)
select '', @id, 'LD_salesorder:total:total:SalesOrder_total:N', 4, 1, 'LD_salesorder:total:total:SalesOrder_合同价:N','LD_salesorder:total:total:SalesOrder_Sales Order Total:N'
from dual where not exists(select 1 from LD_UseReportcolumns where Usereportid=@id and realcolumns like 'LD_salesorder:total:total:SalesOrder_%');

insert into LD_UseReportcolumns(id,Usereportid,columns,Sequence,columnshow,realcolumns,realencolumns)
select '', @id, 'LD_reporttable:CashBillamount:CashBillamount:OftenUseReport_CashBillamount:N', 5, 1, 'LD_reporttable:CashBillamount:CashBillamount:OftenUseReport_已收款:N','LD_reporttable:CashBillamount:CashBillamount:OftenUseReport_CashBill amount:N'
from dual where not exists(select 1 from LD_UseReportcolumns where Usereportid=@id and realcolumns like 'LD_reporttable:CashBillamount:CashBillamount:OftenUseReport_%');

insert into LD_UseReportcolumns(id,Usereportid,columns,Sequence,columnshow,realcolumns,realencolumns)
select '', @id, 'LD_reporttable:PaymentPlanBalance:PaymentPlanBalance:OftenUseReport_PaymentPlanBalance:N', 6, 1, 'LD_reporttable:PaymentPlanBalance:PaymentPlanBalance:OftenUseReport_未收款:N','LD_reporttable:PaymentPlanBalance:PaymentPlanBalance:OftenUseReport_CashBill amount:N'
from dual where not exists(select 1 from LD_UseReportcolumns where Usereportid=@id and realcolumns like 'LD_reporttable:PaymentPlanBalance:PaymentPlanBalance:OftenUseReport_%');

insert into LD_UseReportcolumns(id,Usereportid,columns,Sequence,columnshow,realcolumns,realencolumns)
select '', @id, 'LD_purchaseorder:total:total:PurchaseOrder_total:N', 7, 1, 'LD_purchaseorder:total:total:PurchaseOrder_付款合同价:N','LD_purchaseorder:total:total:PurchaseOrder_Order Total:N'
from dual where not exists(select 1 from LD_UseReportcolumns where Usereportid=@id and realcolumns like 'LD_purchaseorder:total:total:PurchaseOrder_%');

insert into LD_UseReportcolumns(id,Usereportid,columns,Sequence,columnshow,realcolumns,realencolumns)
select '', @id, 'LD_reporttable:SendCashBillamount:SendCashBillamount:OftenUseReport_SendCashBillamount:N', 8, 1, 'LD_reporttable:SendCashBillamount:SendCashBillamount:OftenUseReport_已付:N','LD_reporttable:SendCashBillamount:SendCashBillamount:OftenUseReport_CashBill amount:N'
from dual where not exists(select 1 from LD_UseReportcolumns where Usereportid=@id and realcolumns like 'LD_reporttable:SendCashBillamount:SendCashBillamount:OftenUseReport_%');

insert into LD_UseReportcolumns(id,Usereportid,columns,Sequence,columnshow,realcolumns,realencolumns)
select '', @id, 'LD_reporttable:SendCashBillBalance:SendCashBillBalance:OftenUseReport_SendCashBillBalance:N', 9, 1, 'LD_reporttable:SendCashBillBalance:SendCashBillBalance:OftenUseReport_未付:N','LD_reporttable:SendCashBillBalance:SendCashBillBalance:OftenUseReport_CashBill amount:N'
from dual where not exists(select 1 from LD_UseReportcolumns where Usereportid=@id and realcolumns like 'LD_reporttable:SendCashBillBalance:SendCashBillBalance:OftenUseReport_%');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'zh','EXPORTTEMPLATEANDEDITTHEDATA','导出模板并编辑数据','fixedstr' from dual where not EXISTS(select 1 from ld_desk where languagetype='zh' and labelbol='EXPORTTEMPLATEANDEDITTHEDATA' and Labeltype='fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'en','EXPORTTEMPLATEANDEDITTHEDATA','Export template and edit the data','fixedstr' from dual where not EXISTS(select 1 from ld_desk  where languagetype='en' and labelbol='EXPORTTEMPLATEANDEDITTHEDATA' and Labeltype='fixedstr');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,Labeltype)
select 'zh','VIEWTHEDETAILS','(查看单据明细界面)','fixedstr'
from dual where not exists(select 1 from ld_desk where languagetype = 'zh' and labelbol = 'VIEWTHEDETAILS' and Labeltype='fixedstr');
delimiter;
insert into ld_desk(languagetype,labelbol,fieldlabel,Labeltype)
select 'en','VIEWTHEDETAILS','(View the details)','fixedstr'
from dual where not exists(select 1 from ld_desk where languagetype = 'en' and labelbol = 'VIEWTHEDETAILS' and Labeltype='fixedstr');
delimiter;

select tabid into @tabid from ld_tab where `name` = 'InventoryQuery';
insert into LD_profileallpermission(tabid,operation)
select @tabid,6 from dual where not exists
(select 1 from LD_profileallpermission where tabid = @tabid and operation=6);
delimiter;

select tabid into @tabid from ld_tab where `name` = 'InventoryAccount';
insert into LD_profileallpermission(tabid,operation)
select @tabid,6 from dual where not exists
(select 1 from LD_profileallpermission where tabid = @tabid and operation=6);
delimiter;

CREATE TABLE if not EXISTS `ld_approve2user` (
  `approveid` int(19) NOT NULL AUTO_INCREMENT,
  `userid` int(19) DEFAULT NULL,
  PRIMARY KEY (`approveid`,`userid`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
delimiter;
CREATE TABLE if not EXISTS `ld_userlevel` (
  `userlevelid` int(19) NOT NULL AUTO_INCREMENT,
  `userlevel` varchar(200) DEFAULT NULL,
  `presence` int(1) DEFAULT 0,
  `picklist_valueid` int(19) DEFAULT 0,
  PRIMARY KEY (`userlevelid`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
delimiter;
CALL AddColumn('ld_users','userlevel','varchar','200',null);
delimiter;
select tabid into @tabid from ld_tab where `name` = 'Users';
SELECT max(fieldid) into @maxid from ld_field;
SELECT sequence,fieldid into @sequence,@levelfieldid from ld_field where tabid=@tabid and columnname = 'level';
SELECT blockid INTO @blockid from ld_blocks where tabid=@tabid and blocklabel='LBL_USERLOGIN_ROLE';
insert into ld_field (tabid,fieldid,columnname,tablename,generatedtype,uitype,fieldname,fieldlabel,readonly,presence,defaultvalue,maximumlength,sequence,block,displaytype,typeofdata,quickcreate,quickcreatesequence,info_type,masseditable,helpinfo,fieldonly)
select @tabid,@maxid+1,'userlevel','LD_users',1,15,'userlevel','User Level',1,0,'','',@sequence,@blockid,1,'V~O',3,'','BAS',2,NULL,0
from dual where  not exists (select 1 from  ld_field where tabid=@tabid and columnname='userlevel');
UPDATE ld_field_seq set id=(SELECT max(fieldid) from ld_field);
update ld_tranlabel set relateid = @maxid+1 where relateid = @levelfieldid;
update ld_field set presence = 3 where fieldid = @levelfieldid;
delimiter;

CREATE TABLE if not EXISTS `ld_userlevel_seq` (
  `id` int(19) NOT NULL AUTO_INCREMENT,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
delimiter;

insert into ld_userlevel_seq (id)
select 2 from dual where  not exists (select 1 from ld_userlevel_seq where id>0);
delimiter;

select id into @picklistid from ld_picklist_seq;
insert into ld_picklist (picklistid,name)
select @picklistid+1,'userlevel'
from dual where not exists (select 1 from ld_picklist where name='userlevel');

UPDATE ld_picklist_seq set id=(SELECT max(picklistid) from ld_picklist);
delimiter;
select id into @picklistid from ld_picklistvalues_seq;
delete from ld_userlevel where userlevelid in (1,2,3);
insert into ld_userlevel (userlevelid,userlevel,presence,picklist_valueid)
select 1,'普通用户','1',@picklistid+1
from dual where  not exists (select 1 from ld_userlevel where userlevel='普通用户' and userlevelid = 1);

insert into ld_userlevel (userlevelid,userlevel,presence,picklist_valueid)
select 2,'总经理','1',@picklistid+2
from dual where  not exists (select 1 from ld_userlevel where userlevel='总经理' and userlevelid = 2);

insert into ld_userlevel (userlevelid,userlevel,presence,picklist_valueid)
select 3,'副总经理','1',@picklistid+3
from dual where  not exists (select 1 from ld_userlevel where userlevel='副总经理' and userlevelid = 3);
update ld_picklistvalues_seq set id = @picklistid+3;
update ld_userlevel_seq set id = (select MAX(userlevelid) from ld_userlevel);
delimiter;

update ld_desk set fieldlabel = '本部门用户的职位级别' where labelbol = 'SPECIFYPROMOTERDEP' and languagetype = 'zh';
UPDATE ld_desk SET fieldlabel = 'The position level of the department users' WHERE labelbol = 'SPECIFYPROMOTERDEP' AND languagetype = 'en';
delimiter;

INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype) SELECT 'zh','LBL_POSITIONLEVEL','直属上级部门用户的职位级别','fixedstr' FROM DUAL
WHERE NOT EXISTS(SELECT 1 FROM ld_desk  WHERE languagetype='zh' AND labelbol='LBL_POSITIONLEVEL' AND Labeltype='fixedstr');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype) SELECT 'en','LBL_POSITIONLEVEL','The position level of the higher department users','fixedstr' FROM DUAL
WHERE NOT EXISTS(SELECT 1 FROM ld_desk  WHERE languagetype='en' AND labelbol='LBL_POSITIONLEVEL' AND Labeltype='fixedstr');
delimiter;
-- 2015-04-16

select tabid into @tabid from ld_tab where `name` = 'Invoice';
select blockid into @blockid from ld_blocks where blocklabel = 'LBL_INVOICE_INFORMATION';
update ld_field set block = @blockid where tabid = @tabid and fieldname = 'hdnS_H_Amount';
delimiter;

select tabid into @tabid from ld_tab where `name` = 'BankAccountSet';
insert into LD_profileallpermission(tabid,operation)
select @tabid,3 from dual where not exists
(select 1 from LD_profileallpermission where tabid = @tabid and operation=3);
insert into LD_profileallpermission(tabid,operation)
select @tabid,4 from dual where not exists
(select 1 from LD_profileallpermission where tabid = @tabid and operation=4);
insert into LD_profileallpermission(tabid,operation)
select @tabid,11 from dual where not exists
(select 1 from LD_profileallpermission where tabid = @tabid and operation=11);
insert into LD_profileallpermission(tabid,operation)
select @tabid,1 from dual where not exists
(select 1 from LD_profileallpermission where tabid = @tabid and operation=1);
insert into LD_profileallpermission(tabid,operation)
select @tabid,2 from dual where not exists
(select 1 from LD_profileallpermission where tabid = @tabid and operation=2);
insert into LD_profileallpermission(tabid,operation)
select @tabid,6 from dual where not exists
(select 1 from LD_profileallpermission where tabid = @tabid and operation=6);
delimiter;

INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype) SELECT 'zh','LBL_POSITIONDEPARTMENT','指定部门的职位级别','fixedstr' FROM DUAL
WHERE NOT EXISTS(SELECT 1 FROM ld_desk  WHERE languagetype='zh' AND labelbol='LBL_POSITIONDEPARTMENT' AND Labeltype='fixedstr');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype) SELECT 'en','LBL_POSITIONDEPARTMENT','Specify the position leve of department。','fixedstr' FROM DUAL
WHERE NOT EXISTS(SELECT 1 FROM ld_desk  WHERE languagetype='en' AND labelbol='LBL_POSITIONDEPARTMENT' AND Labeltype='fixedstr');
delimiter;

select picklistid into @picklistid from ld_picklist where `name` = 'userlevel';
insert into LD_userlevel(userlevel,presence,picklist_valueid)
select '财务总监',1,@picklistid from dual where not exists(select 1 from LD_userlevel where userlevel = '财务总监' and picklist_valueid = @picklistid);
insert into LD_userlevel(userlevel,presence,picklist_valueid)
select '部门经理',1,@picklistid from dual where not exists(select 1 from LD_userlevel where userlevel = '部门经理' and picklist_valueid = @picklistid);
delimiter;
select tabid into @tabid from ld_tab where `name`= 'Users';
select blockid into @blockid from ld_blocks where blocklabel = 'LBL_ACCOUNT_MOREINFORMATION';
update ld_tranlabel set fieldlabel = '相关信息的数据查询' where tabid = @tabid and Relateid = @blockid;
delimiter;
-- 2015-04-20

select ifnull(profileid,1) into @profileid from ld_profile order by profileid limit 1;
update ld_users set profileid=@profileid where id=1;
delimiter;

update ld_desk set fieldlabel='指定部门用户的职位级别' where labelbol='LBL_POSITIONDEPARTMENT' and languagetype='zh';
update ld_desk set fieldlabel='Specify the position leve of department users' where labelbol='LBL_POSITIONDEPARTMENT' and languagetype='en';
update ld_desk set fieldlabel='Please input the user name' where labelbol='PLEASEINPUTYOUWANTTOFINDTHEUSER' and languagetype='en';

UPDATE ld_role_astrictcount
	INNER JOIN ld_role2profile ON ld_role2profile.`roleid` = ld_role_astrictcount.`roleid`
SET ld_role_astrictcount.roleid = ld_role2profile.profileid
WHERE ld_role_astrictcount.roleid IS NOT NULL;
delimiter;

select max(blockid) into @blockid from ld_blocks;
select tabid into @tabid from LD_tab where `name` = 'Users';
select max(sequence) into @sequence from LD_blocks where tabid = @tabid;
insert into LD_blocks(blockid,tabid,blocklabel,sequence,visible,display_status)
select @blockid+1,@tabid,'LBL_ATTACHMENTS_INFOMATION',@sequence+1,0,1
from dual where not exists(select 1 from LD_blocks where tabid = @tabid and blocklabel = 'LBL_ATTACHMENTS_INFOMATION');

select blockid into @blockid from ld_blocks where tabid = @tabid and blocklabel = 'LBL_ATTACHMENTS_INFOMATION';
insert into ld_tranlabel(languagetype,trantable,tabid,Relateid,fieldlabel)
select 'zh','LD_blocks',@tabid,@blockid,'附件' from dual
where not exists(select 1 from ld_tranlabel where tabid = @tabid and Relateid = @blockid and languagetype = 'zh');

insert into ld_tranlabel(languagetype,trantable,tabid,Relateid,fieldlabel)
select 'en','LD_blocks',@tabid,@blockid,'Attachments' from dual
where not exists(select 1 from ld_tranlabel where tabid = @tabid and Relateid = @blockid and languagetype = 'en');
update ld_blocks_seq set id = @blockid + 1;
delimiter;

select tabid into @tabid from LD_tab where `name` = 'Users';
insert into ld_field(tabid,fieldid,columnname,tablename,uitype,fieldname,fieldlabel,block,displaytype,presence,typeofdata)
select @tabid,(select max(fieldid) from ld_field)+1,'attachmentsid','LD_attachments',266,'attachmentsid','附件',(select blockid from ld_blocks where blocklabel = 'LBL_ATTACHMENTS_INFOMATION'),1,0,'V~O' from dual where not exists
(select * from ld_field where tabid = @tabid and uitype = '266');
delimiter;

select tabid into @tabid from ld_tab where `name` = 'Users';
select fieldid into @fieldid from ld_field where tabid = @tabid and fieldname = 'attachmentsid';
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'zh','LD_field',@tabid,@fieldid,'附件'
from dual where not EXISTS(select 1 from ld_tranlabel where languagetype = 'zh'
and trantable ='LD_field' and tabid = @tabid and fieldlabel='附件');
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'en','LD_field',@tabid,@fieldid,'Attachments'
from dual where not EXISTS(select 1 from ld_tranlabel where languagetype = 'en'
and trantable ='LD_field' and tabid = @tabid and fieldlabel='Attachments');
delimiter;

update ld_field set uitype=102 where tabid=(select tabid from ld_tab where `name`='Attachment') and columnname='related_to';
update ld_field set tablename='LD_lessionplan'
where tabid=(select tabid from ld_tab where name='LessionPlan') and columnname in ('modifiedtime','smcreatorid','createdtime');
update ld_field set tablename='LD_cashbill'
where tabid=(select tabid from ld_tab where name='CashBill') and columnname in ('smownerid');

select tabid into @tabid from ld_tab where `name` = 'LessionPlan';
select fieldid into @fieldid from ld_field where tabid =@tabid and columnname = 'modifiedtime';
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'zh','LD_field',@tabid,@fieldid,'修改时间' from dual
where not exists(select 1 from ld_tranlabel where tabid = @tabid and Relateid=@fieldid and languagetype = 'zh');

insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'en','LD_field',@tabid,@fieldid,'Modified Time' from dual
where not exists(select 1 from ld_tranlabel where tabid = @tabid and Relateid=@fieldid and languagetype = 'en');

select fieldid into @fieldid from ld_field where tabid =@tabid and columnname = 'smcreatorid';
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'zh','LD_field',@tabid,@fieldid,'创建人' from dual
where not exists(select 1 from ld_tranlabel where tabid = @tabid and Relateid=@fieldid and languagetype = 'zh');

insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'en','LD_field',@tabid,@fieldid,'Creator' from dual
where not exists(select 1 from ld_tranlabel where tabid = @tabid and Relateid=@fieldid and languagetype = 'en');

select fieldid into @fieldid from ld_field where tabid =@tabid and columnname = 'createdtime';
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'zh','LD_field',@tabid,@fieldid,'创建时间' from dual
where not exists(select 1 from ld_tranlabel where tabid = @tabid and Relateid=@fieldid and languagetype = 'zh');

insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'en','LD_field',@tabid,@fieldid,'Created Time' from dual
where not exists(select 1 from ld_tranlabel where tabid = @tabid and Relateid=@fieldid and languagetype = 'en');
-- 2015-04-21

update ld_tranlabel set fieldlabel='序时簿中业务单据授权范围' where tabid=29 and Relateid=@fieldid and languagetype='zh';
update ld_desk set fieldlabel='请仔细确认单据信息,是否确认退货出库？' where labelbol='RETURNOPERATIONREVERSIBLEPURCHASE' and languagetype='zh';

UPDATE ld_desk SET fieldlabel='序时簿“全部”页签是否显示公海客户' WHERE labelbol ='WEHERTODISPLAYTHEPUBLICCUST OMERES' AND languagetype='zh';
delimiter;

insert into ld_desk (languagetype,labelbol,fieldlabel,Labeltype)
select 'zh', 'NEWBUTTONDROP-DOWNOPTIONS','序时簿“新建”功能下拉按钮选项','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype = 'zh' and labelbol = 'NEWBUTTONDROP-DOWNOPTIONS' and Labeltype = 'fixedstr');
insert into ld_desk (languagetype,labelbol,fieldlabel,Labeltype)
SELECT 'en', 'NEWBUTTONDROP-DOWNOPTIONS','The new button drop-down option style','fixedstr' FROM DUAL
where not exists (SELECT 1 FROM ld_desk WHERE languagetype ='en' and labelbol = 'NEWBUTTONDROP-DOWNOPTIONS' and Labeltype ='fixedstr');
delimiter;

insert into ld_desk (languagetype,labelbol,fieldlabel,Labeltype)
select 'zh', 'COMMONONLY','仅普通','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype = 'zh' and labelbol = 'COMMONONLY' and Labeltype = 'fixedstr');
insert into ld_desk (languagetype,labelbol,fieldlabel,Labeltype)
SELECT 'en', 'COMMONONLY','Common customer','fixedstr' FROM DUAL
where not exists (SELECT 1 FROM ld_desk WHERE languagetype ='en' and labelbol = 'COMMONONLY' and Labeltype ='fixedstr');
delimiter;

insert into ld_desk (languagetype,labelbol,fieldlabel,Labeltype)
select 'zh', 'HIGHSEAONLY','仅公海','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype = 'zh' and labelbol = 'HIGHSEAONLY' and Labeltype = 'fixedstr');
insert into ld_desk (languagetype,labelbol,fieldlabel,Labeltype)
SELECT 'en', 'HIGHSEAONLY','The hign seas customer','fixedstr' FROM DUAL
where not exists (SELECT 1 FROM ld_desk WHERE languagetype ='en' and labelbol = 'HIGHSEAONLY' and Labeltype ='fixedstr');
delimiter;

call AddColumn('LD_account_set','buttontype','int',11,0);
delimiter;

UPDATE ld_tranlabel set fieldlabel='Currency' WHERE fieldlabel='币种' AND languagetype='en';
delimiter;
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'zh','Currentinput','当前输入','fixedstr' from dual
where not EXISTS(select 1 from ld_desk  where languagetype='zh' and labelbol='Currentinput' and Labeltype='fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'en','Currentinput',' Current input ','fixedstr' from dual
where not EXISTS(select 1 from ld_desk  where languagetype='en' and labelbol='Currentinput' and Labeltype='fixedstr');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'zh','Word','字,签名包含','fixedstr' from dual
where not EXISTS(select 1 from ld_desk  where languagetype='zh' and labelbol='Word' and Labeltype='fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'en','Word',' Word,Signature contains ','fixedstr' from dual
where not EXISTS(select 1 from ld_desk  where languagetype='en' and labelbol='Word' and Labeltype='fixedstr');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'zh','Word','字,签名包含','fixedstr' from dual
where not EXISTS(select 1 from ld_desk  where languagetype='zh' and labelbol='Word' and Labeltype='fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'en','Word',' Word,Signature contains ','fixedstr' from dual
where not EXISTS(select 1 from ld_desk  where languagetype='en' and labelbol='Word' and Labeltype='fixedstr');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'zh','Word2','个字','fixedstr' from dual
where not EXISTS(select 1 from ld_desk  where languagetype='zh' and labelbol='Word2' and Labeltype='fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'en','Word2',' Word ','fixedstr' from dual
where not EXISTS(select 1 from ld_desk  where languagetype='en' and labelbol='Word2' and Labeltype='fixedstr');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'zh','Totalcontentofthemessage',',短信内容总共','fixedstr' from dual
where not EXISTS(select 1 from ld_desk  where languagetype='zh' and labelbol='Totalcontentofthemessage' and Labeltype='fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'en','Totalcontentofthemessage',',Total content of the message ','fixedstr' from dual
where not EXISTS(select 1 from ld_desk  where languagetype='en' and labelbol='Totalcontentofthemessage' and Labeltype='fixedstr');
delimiter;
UPDATE ld_desk SET fieldlabel='Create payment plan in {$ServiceContracts.ServiceContracts} module controls whether the payment plan must be equal to the total amount of the order'
WHERE languagetype='en' AND labelbol='WTTPPMBETTAOOWTCPPTTMOSS';
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'zh','InterfaceType','接口类型','fixedstr' from dual
where not EXISTS(select 1 from ld_desk  where languagetype='zh' and labelbol='InterfaceType' and Labeltype='fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'en','InterfaceType','Interface Type','fixedstr' from dual
where not EXISTS(select 1 from ld_desk  where languagetype='en' and labelbol='InterfaceType' and Labeltype='fixedstr');
delimiter;
-- 2015-04-23

update ld_desk set fieldlabel='Specify profile' where labelbol='SPECIFYROLE' and languagetype='en' and Labeltype='fixedstr';
update ld_desk set fieldlabel='定制订单、发票等模块产品明细中的产品关联字段' where labelbol='LBL_RELATED_PARAMETERS_DESCRIPTION' and languagetype='zh';

UPDATE ld_field set presence=1 WHERE columnname in ('hour_format','end_hour','start_hour') and tabid=29;
delimiter;

select tabid into @tabid from ld_tab where `name`='SendCashBill';
UPDATE ld_field set presence=1 WHERE columnname ='criscashbill' and tabid=@tabid  and EXISTS(select 1 from ld_crmentity_seq where id=2);
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,Labeltype)
select 'zh','ACCOUNT','账号','fixedstr'
from dual where not exists(select 1 from ld_desk where languagetype = 'zh' and labelbol = 'ACCOUNT' and Labeltype='fixedstr');
delimiter;
insert into ld_desk(languagetype,labelbol,fieldlabel,Labeltype)
select 'en','ACCOUNT','Account','fixedstr'
from dual where not exists(select 1 from ld_desk where languagetype = 'en' and labelbol = 'ACCOUNT' and Labeltype='fixedstr');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,Labeltype)
select 'zh','SETTHEPERMISSIONS','设置角色','fixedstr'
from dual where not exists(select 1 from ld_desk where languagetype = 'zh' and labelbol = 'SETTHEPERMISSIONS' and Labeltype='fixedstr');
delimiter;
insert into ld_desk(languagetype,labelbol,fieldlabel,Labeltype)
select 'en','SETTHEPERMISSIONS','Set the permissions','fixedstr'
from dual where not exists(select 1 from ld_desk where languagetype = 'en' and labelbol = 'SETTHEPERMISSIONS' and Labeltype='fixedstr');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,Labeltype)
select 'zh','SETTHEPERMISSIONS','设置角色','jspop'
from dual where not exists(select 1 from ld_desk where languagetype = 'zh' and labelbol = 'SETTHEPERMISSIONS' and Labeltype='jspop');
delimiter;
insert into ld_desk(languagetype,labelbol,fieldlabel,Labeltype)
select 'en','SETTHEPERMISSIONS','Set the permissions','jspop'
from dual where not exists(select 1 from ld_desk where languagetype = 'en' and labelbol = 'SETTHEPERMISSIONS' and Labeltype='jspop');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,Labeltype)
select 'zh','SETTHEPERMISSIONSAS','修改角色为','jspop'
from dual where not exists(select 1 from ld_desk where languagetype = 'zh' and labelbol = 'SETTHEPERMISSIONSAS' and Labeltype='jspop');
delimiter;
insert into ld_desk(languagetype,labelbol,fieldlabel,Labeltype)
select 'en','SETTHEPERMISSIONSAS','Set the permissions as','jspop'
from dual where not exists(select 1 from ld_desk where languagetype = 'en' and labelbol = 'SETTHEPERMISSIONSAS' and Labeltype='jspop');
delimiter;

update ld_profile2standardpermissions set tabid = 16 where tabid = 9;
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'zh','ATOTALOF','共','jspop' from dual
where not EXISTS(select 1 from ld_desk  where languagetype='zh' and labelbol='ATOTALOF' and Labeltype='jspop');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'en','ATOTALOF','A total of ','jspop' from dual
where not EXISTS(select 1 from ld_desk  where languagetype='en' and labelbol='ATOTALOF' and Labeltype='jspop');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'zh','RECORDSEXPORTING','条记录，正在导出第','jspop' from dual
where not EXISTS(select 1 from ld_desk  where languagetype='zh' and labelbol='RECORDSEXPORTING' and Labeltype='jspop');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'en','RECORDSEXPORTING',' records, exporting ','jspop' from dual
where not EXISTS(select 1 from ld_desk  where languagetype='en' and labelbol='RECORDSEXPORTING' and Labeltype='jspop');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'zh','EXPORTTO2','-','jspop' from dual
where not EXISTS(select 1 from ld_desk  where languagetype='zh' and labelbol='EXPORTTO2' and Labeltype='jspop');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'en','EXPORTTO2',' to ','jspop' from dual
where not EXISTS(select 1 from ld_desk  where languagetype='en' and labelbol='EXPORTTO2' and Labeltype='jspop');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'zh','PLEASEWAITFORAMOMENT','条数据，请稍候……','jspop' from dual
where not EXISTS(select 1 from ld_desk  where languagetype='zh' and labelbol='PLEASEWAITFORAMOMENT' and Labeltype='jspop');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'en','PLEASEWAITFORAMOMENT',' . Please wait for a moment! ','jspop' from dual
where not EXISTS(select 1 from ld_desk  where languagetype='en' and labelbol='PLEASEWAITFORAMOMENT' and Labeltype='jspop');
delimiter;

select fieldid into @fieldid from ld_field where tabid=29 and columnname='viewothers';
update ld_tranlabel set fieldlabel='允许查看其他用户的单据(权限优先于角色)'
where tabid=29 and trantable='LD_field' and Relateid=@fieldid and languagetype='zh';

select fieldid into @fieldid from ld_field where tabid=29 and columnname='editothers';
update ld_tranlabel set fieldlabel='允许编辑其他用户的单据(权限优先于角色)'
where tabid=29 and trantable='LD_field' and Relateid=@fieldid and languagetype='zh';

select fieldid into @fieldid from ld_field where tabid=29 and columnname='delothers';
update ld_tranlabel set fieldlabel='允许删除其他用户的单据(权限优先于角色)'
where tabid=29 and trantable='LD_field' and Relateid=@fieldid and languagetype='zh';

insert into ld_desk(languagetype,labelbol,fieldlabel,Labeltype)
select 'zh','MAXIMUMRECORDSNUMBEROFMASSOPERATION','批量操作时记录数上限','fixedstr'
from dual where not exists(select 1 from ld_desk where languagetype = 'zh' and labelbol = 'MAXIMUMRECORDSNUMBEROFMASSOPERATION' and Labeltype = 'fixedstr');

insert into ld_desk(languagetype,labelbol,fieldlabel,Labeltype)
select 'en','MAXIMUMRECORDSNUMBEROFMASSOPERATION','Maximum records number of mass operation','fixedstr'
from dual where not exists(select 1 from ld_desk where languagetype = 'en' and labelbol = 'MAXIMUMRECORDSNUMBEROFMASSOPERATION' and Labeltype = 'fixedstr');
delimiter;

insert into ld_systems_deploy(deploy_value,deploy_type,description)
select 500,67,'批量操作时记录数上限'
from dual where not exists(select 1 from ld_systems_deploy where deploy_type = 67);
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,Labeltype)
select 'zh','YOUSELECTMAXMASSOPERATIONLIMIT','您选择了{Var}条记录，批量操作只对前{Var}条记录生效，是否继续?','jspop'
from dual where not exists(select 1 from ld_desk where languagetype = 'zh' and labelbol = 'YOUSELECTMAXMASSOPERATIONLIMIT' and Labeltype = 'jspop');

insert into ld_desk(languagetype,labelbol,fieldlabel,Labeltype)
select 'en','YOUSELECTMAXMASSOPERATIONLIMIT','You select {Var} records, the mass operation only effect on the first {Var} records,whether to continue?','jspop'
from dual where not exists(select 1 from ld_desk where languagetype = 'en' and labelbol = 'YOUSELECTMAXMASSOPERATIONLIMIT' and Labeltype = 'jspop');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,Labeltype)
select 'zh','DOCUMENTNOSUCCESS','单据[%s]%s不成功！原因：您没有该单据的%s权限!','fixedstr'
from dual where not exists(select 1 from ld_desk where languagetype = 'zh' and labelbol = 'DOCUMENTNOSUCCESS' and Labeltype = 'fixedstr');

insert into ld_desk(languagetype,labelbol,fieldlabel,Labeltype)
select 'en','DOCUMENTNOSUCCESS','Document[%s]%sno success! The reason: you do not have the permissions to %s the document!','fixedstr'
from dual where not exists(select 1 from ld_desk where languagetype = 'en' and labelbol = 'DOCUMENTNOSUCCESS' and Labeltype = 'fixedstr');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,Labeltype)
select 'zh','DOCUMENTSUCCESS','单据[%s]%s成功！','fixedstr'
from dual where not exists(select 1 from ld_desk where languagetype = 'zh' and labelbol = 'DOCUMENTSUCCESS' and Labeltype = 'fixedstr');

insert into ld_desk(languagetype,labelbol,fieldlabel,Labeltype)
select 'en','DOCUMENTSUCCESS','Document[%s]%s success!','fixedstr'
from dual where not exists(select 1 from ld_desk where languagetype = 'en' and labelbol = 'DOCUMENTSUCCESS' and Labeltype = 'fixedstr');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,Labeltype)
select 'zh','DOCUMENTNOOTHERSUCCESS','单据[%s]%s不成功！原因：您没有权限%s其他用户的单据!','fixedstr'
from dual where not exists(select 1 from ld_desk where languagetype = 'zh' and labelbol = 'DOCUMENTNOOTHERSUCCESS' and Labeltype = 'fixedstr');

insert into ld_desk(languagetype,labelbol,fieldlabel,Labeltype)
select 'en','DOCUMENTNOOTHERSUCCESS','Document[%s] %s no success! The reason: you do not have permissions to other %s users!','fixedstr'
from dual where not exists(select 1 from ld_desk where languagetype = 'en' and labelbol = 'DOCUMENTNOOTHERSUCCESS' and Labeltype = 'fixedstr');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,Labeltype)
select 'zh','DOCUMENTNOOTHERSUCCESSCHECK','单据[%s]%s不成功！原因：该单据已审核!','fixedstr'
from dual where not exists(select 1 from ld_desk where languagetype = 'zh' and labelbol = 'DOCUMENTNOOTHERSUCCESSCHECK' and Labeltype = 'fixedstr');

insert into ld_desk(languagetype,labelbol,fieldlabel,Labeltype)
select 'en','DOCUMENTNOOTHERSUCCESSCHECK','Document[%s] %s no success! The reason: The document has been audited!','fixedstr'
from dual where not exists(select 1 from ld_desk where languagetype = 'en' and labelbol = 'DOCUMENTNOOTHERSUCCESSCHECK' and Labeltype = 'fixedstr');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,Labeltype)
select 'zh','DOCUMENTNOOTHERSUCCESSCHECKOVER','单据[%s]%s不成功！原因：该单据已经盘点结束!','fixedstr'
from dual where not exists(select 1 from ld_desk where languagetype = 'zh' and labelbol = 'DOCUMENTNOOTHERSUCCESSCHECKOVER' and Labeltype = 'fixedstr');

insert into ld_desk(languagetype,labelbol,fieldlabel,Labeltype)
select 'en','DOCUMENTNOOTHERSUCCESSCHECKOVER','Document[%s] %s no success! The reason: The documents have been the end of the inventory!','fixedstr'
from dual where not exists(select 1 from ld_desk where languagetype = 'en' and labelbol = 'DOCUMENTNOOTHERSUCCESSCHECKOVER' and Labeltype = 'fixedstr');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,Labeltype)
select 'zh','DOCUMENTNOOTHERSUCCESSCHECKOVERING','单据[%s]%s不成功！原因：该单据已审批或者正在审批中!','fixedstr'
from dual where not exists(select 1 from ld_desk where languagetype = 'zh' and labelbol = 'DOCUMENTNOOTHERSUCCESSCHECKOVERING' and Labeltype = 'fixedstr');

insert into ld_desk(languagetype,labelbol,fieldlabel,Labeltype)
select 'en','DOCUMENTNOOTHERSUCCESSCHECKOVERING','Document[%s] %s no success! The reason: The document has been approved or pending!','fixedstr'
from dual where not exists(select 1 from ld_desk where languagetype = 'en' and labelbol = 'DOCUMENTNOOTHERSUCCESSCHECKOVERING' and Labeltype = 'fixedstr');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,Labeltype)
select 'zh','DOCUMENTNOOTHERSUCCESSCHECKOVERFUKUAN','单据[%s]%s不成功！原因：该单据已付款或者部分已付款!','fixedstr'
from dual where not exists(select 1 from ld_desk where languagetype = 'zh' and labelbol = 'DOCUMENTNOOTHERSUCCESSCHECKOVERFUKUAN' and Labeltype = 'fixedstr');

insert into ld_desk(languagetype,labelbol,fieldlabel,Labeltype)
select 'en','DOCUMENTNOOTHERSUCCESSCHECKOVERFUKUAN','Document[%s] %s no success! The reason: The documents have been paid or part payment!','fixedstr'
from dual where not exists(select 1 from ld_desk where languagetype = 'en' and labelbol = 'DOCUMENTNOOTHERSUCCESSCHECKOVERFUKUAN' and Labeltype = 'fixedstr');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,Labeltype)
select 'zh','DOCUMENTNOOTHERSUCCESSCHECKOVERSHOUKUAN','单据[%s]%s不成功！原因：该单据已收款或者部分已收款!','fixedstr'
from dual where not exists(select 1 from ld_desk where languagetype = 'zh' and labelbol = 'DOCUMENTNOOTHERSUCCESSCHECKOVERSHOUKUAN' and Labeltype = 'fixedstr');

insert into ld_desk(languagetype,labelbol,fieldlabel,Labeltype)
select 'en','DOCUMENTNOOTHERSUCCESSCHECKOVERSHOUKUAN','Document[%s] %s no success! The reason: The documents have been received or part payment!','fixedstr'
from dual where not exists(select 1 from ld_desk where languagetype = 'en' and labelbol = 'DOCUMENTNOOTHERSUCCESSCHECKOVERSHOUKUAN' and Labeltype = 'fixedstr');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,Labeltype)
select 'zh','DOCUMENTNOOTHERSUCCESSCHECKOVERGUANLIAN','单据[%s]%s不成功！原因：该单据有关联数据!','fixedstr'
from dual where not exists(select 1 from ld_desk where languagetype = 'zh' and labelbol = 'DOCUMENTNOOTHERSUCCESSCHECKOVERGUANLIAN' and Labeltype = 'fixedstr');

insert into ld_desk(languagetype,labelbol,fieldlabel,Labeltype)
select 'en','DOCUMENTNOOTHERSUCCESSCHECKOVERGUANLIAN','Document[%s] %s no success! The reason: The documents have associated data!','fixedstr'
from dual where not exists(select 1 from ld_desk where languagetype = 'en' and labelbol = 'DOCUMENTNOOTHERSUCCESSCHECKOVERGUANLIAN' and Labeltype = 'fixedstr');
delimiter;
-- 2015-04-24

update ld_desk set fieldlabel='知识文档模板' where labelbol='THEDOCUMENTTEMPLATE' and languagetype='zh' and Labeltype='fixedstr';
select cvid into @cvid from ld_customview where viewname ='无服务' and entitytype = 'ServiceCharge';
delete from ld_cvadvfilter where cvid = @cvid;
insert into ld_cvadvfilter(cvid,columnindex,columnname,comparator,groupid)
select @cvid,0,'LD_inventoryproductrel:servicecontracts_end_date:servicecontracts_end_date:Products_fieldlabel:D','isnull',1
from dual where not exists(select 1 from ld_cvadvfilter where cvid = @cvid and columnindex = 'LD_inventoryproductrel:servicecontracts_end_date:servicecontracts_end_date:Products_fieldlabel:D');
delimiter;

update ld_field set columnname='entitytypeid',fieldname='entitytypeid',tablename='LD_cashbill2paymentplan'
 where uitype=202 and  tabid=(select tabid from ld_tab where name='cashbill');
delimiter;
update ld_field set columnname='entitytypeid',fieldname='entitytypeid',tablename='LD_commission2payment'
where uitype=202 and  tabid=(select tabid from ld_tab where name='Commission');
delimiter;


select tabid into @tabid from ld_tab where `name`='Attachment';
update ld_field set sequence=sequence+20 where tabid=@tabid;
update ld_field set sequence=1 where tabid=@tabid and columnname='isenabled';
update ld_field set sequence=2 where tabid=@tabid and columnname='reltab';
update ld_field set sequence=3 where tabid=@tabid and columnname='related_to';
update ld_field set sequence=4 where tabid=@tabid and columnname='filename';
update ld_field set sequence=5 where tabid=@tabid and columnname='size';
update ld_field set sequence=6 where tabid=@tabid and columnname='description';
update ld_field set sequence=7 where tabid=@tabid and columnname='creator';
update ld_field set sequence=8 where tabid=@tabid and columnname='createdtime';
update ld_field set sequence=9 where tabid=@tabid and columnname='smownerid';
update ld_field set sequence=10 where tabid=@tabid and columnname='modifiedtime';
update ld_field set sequence=11 where tabid=@tabid and columnname='uuid';
update ld_field set sequence=12 where tabid=@tabid and columnname='imagefromtype';

set @i=0;
update ld_field set sequence=(@i:=@i+1) where tabid=@tabid order by sequence;
delimiter;

update ld_desk set fieldlabel='共享给他人的' where labelbol='Ishared' and languagetype='zh' and Labeltype='fixedstr';
update ld_desk set fieldlabel='Shared with others' where labelbol='Ishared' and languagetype='en' and Labeltype='fixedstr';
delimiter;



SELECT tabid INTO @tabid FROM ld_tab WHERE NAME = 'Faq';
SELECT MAX(ruleid) INTO @ruleid FROM ld_def_org_share;
INSERT INTO ld_def_org_share(ruleid,tabid,permission,editstatus)
SELECT @ruleid+1,@tabid,3,0 FROM DUAL
WHERE NOT EXISTS(SELECT 1 FROM ld_def_org_share WHERE tabid = @tabid);
UPDATE ld_def_org_share_seq SET id = (SELECT MAX(ruleid) FROM ld_def_org_share);
delimiter;
SELECT tabid INTO @tabid FROM ld_tab WHERE NAME = 'Faq';
INSERT INTO LD_org_share_action2tab(share_action_id,tabid)
SELECT 0,@tabid FROM DUAL
WHERE NOT EXISTS(SELECT 1 FROM LD_org_share_action2tab WHERE tabid = @tabid AND share_action_id = 0);

INSERT INTO LD_org_share_action2tab(share_action_id,tabid)
SELECT 1,@tabid FROM DUAL
WHERE NOT EXISTS(SELECT 1 FROM LD_org_share_action2tab WHERE tabid = @tabid AND share_action_id = 1);

INSERT INTO LD_org_share_action2tab(share_action_id,tabid)
SELECT 2,@tabid FROM DUAL
WHERE NOT EXISTS(SELECT 1 FROM LD_org_share_action2tab WHERE tabid = @tabid AND share_action_id = 2);

INSERT INTO LD_org_share_action2tab(share_action_id,tabid)
SELECT 3,@tabid FROM DUAL
WHERE NOT EXISTS(SELECT 1 FROM LD_org_share_action2tab WHERE tabid = @tabid AND share_action_id = 3);
delimiter;

update ld_field set masseditable = 0 where uitype = 53;
delimiter;
select tabid into @tabid from ld_tab where `name` = 'Attachment';
insert into ld_profileallpermission(tabid,operation)
select @tabid,6 from dual where not exists(select 1 from ld_profileallpermission where tabid = @tabid and operation = 6);
delimiter;

INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,Labeltype)
SELECT 'zh','NOPERMITTEDEXECUTE','您没有权限执行这个操作','jspop'
FROM DUAL WHERE NOT EXISTS(SELECT 1 FROM ld_desk WHERE languagetype = 'zh'
AND labelbol = 'NOPERMITTEDEXECUTE' AND Labeltype = 'jspop');

INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,Labeltype)
SELECT 'en','NOPERMITTEDEXECUTE','You are not permitted to execute this Operation','jspop'
FROM DUAL WHERE NOT EXISTS(SELECT 1 FROM ld_desk WHERE languagetype = 'en'
AND labelbol = 'NOPERMITTEDEXECUTE' AND Labeltype = 'jspop');
delimiter;
select tabid into @tabid from ld_tab where `name` = 'Attachment';
update LD_field set fieldname = 'assigned_user_id' where tabid = @tabid and columnname = 'smownerid';
update LD_attachmentsforbills set smownerid = 1 where smownerid is null or smownerid = '';
delimiter;


select tabid into @tabid from ld_tab where `name`='Attachment';
update ld_field set sequence=sequence+20 where tabid=@tabid;
update ld_field set sequence=1 where tabid=@tabid and columnname='isenabled';
update ld_field set sequence=2 where tabid=@tabid and columnname='reltab';
update ld_field set sequence=3 where tabid=@tabid and columnname='related_to';
update ld_field set sequence=4 where tabid=@tabid and columnname='filename';
update ld_field set sequence=5 where tabid=@tabid and columnname='size';
update ld_field set sequence=6 where tabid=@tabid and columnname='description';
update ld_field set sequence=7 where tabid=@tabid and columnname='creator';
update ld_field set sequence=8 where tabid=@tabid and columnname='createdtime';
update ld_field set sequence=9 where tabid=@tabid and columnname='smownerid';
update ld_field set sequence=10 where tabid=@tabid and columnname='modifiedtime';
update ld_field set sequence=11 where tabid=@tabid and columnname='uuid';
update ld_field set sequence=12 where tabid=@tabid and columnname='imagefromtype';

set @i=0;
update ld_field set sequence=(@i:=@i+1) where tabid=@tabid order by sequence;
delimiter;
drop PROCEDURE  if EXISTS `DelColumn`;
delimiter ||
create PROCEDURE `DelColumn`
(
tablename varchar(50),
columnname varchar(50)
)
begin

select database() into @tableschema;

set tablename=lower(tablename);
set @colName='';
SET @tsql=CONCAT('select  IFNULL(column_name, '''') into @colName  from information_schema.columns where  TABLE_SCHEMA =','''',@tableschema,'''','  and  table_name= ','''',tablename,'''',' and COLUMN_NAME=','''',columnname,'''');

prepare stmt from @tsql;
execute stmt;

set @coldel=IFNULL(@colName,'-1');

IF @coldel <> '-1'  and  @coldel=columnname THEN

	set @alterColumn=CONCAT(' alter table ',tablename, ' drop ',columnname);

	prepare stalter from @altercolumn;
	execute stalter;
deallocate prepare stalter;
END IF;
deallocate prepare stmt;
end ||
delimiter;
CALL DelColumn('LD_workreport','reader');
delimiter;

update ld_desk set fieldlabel='共享给他人的' where labelbol='Ishared' and languagetype='zh' and Labeltype='fixedstr';
update ld_desk set fieldlabel='Shared with others' where labelbol='Ishared' and languagetype='en' and Labeltype='fixedstr';
delimiter;

select tabid into @tabid from ld_tab where `name` = 'Faq';
select max(fieldid) into @fieldid from ld_field;
select blockid into @blockid from ld_blocks where blocklabel = 'LBL_FAQ_INFORMATION' and tabid = @tabid;
insert into ld_field(tabid,fieldid,columnname,tablename,uitype,fieldname,fieldlabel,block,displaytype,presence,typeofdata,issmownerid,masseditable)
select @tabid,@fieldid+1,'smownerid','LD_faq',53,'assigned_user_id','负责人',@blockid,1,0,'V~M',1,0 from dual where not exists
(select * from ld_field where tabid = @tabid and columnname = 'smownerid');
update ld_field_seq set id = (select max(fieldid) from ld_field);

select fieldid into @fieldid from ld_field where tabid = @tabid and columnname = 'smownerid';
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'zh','LD_field',@tabid,@fieldid,'负责人'
from dual where not EXISTS(select 1 from ld_tranlabel  where languagetype = 'zh'
and trantable ='LD_field' and tabid = @tabid and relateid=@fieldid);
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'en','LD_field',@tabid,@fieldid,'Assigned To'
from dual where not EXISTS(select 1 from ld_tranlabel  where languagetype = 'en'
and trantable ='LD_field' and tabid = @tabid and relateid=@fieldid);
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,Labeltype)
select 'zh','DOCUMENTNOOTHERSUCCESSCHECKSALESBACK','单据[%s]%s不成功！原因：该单据已入库或者结束退货!','fixedstr'
from dual where not exists(select 1 from ld_desk where languagetype = 'zh' and labelbol = 'DOCUMENTNOOTHERSUCCESSCHECKSALESBACK' and Labeltype = 'fixedstr');

insert into ld_desk(languagetype,labelbol,fieldlabel,Labeltype)
select 'en','DOCUMENTNOOTHERSUCCESSCHECKSALESBACK','Document[%s] %s no success! The reason: The document has been audited!','fixedstr'
from dual where not exists(select 1 from ld_desk where languagetype = 'en' and labelbol = 'DOCUMENTNOOTHERSUCCESSCHECKSALESBACK' and Labeltype = 'fixedstr');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,Labeltype)
select 'zh','DOCUMENTNOOTHERSUCCESSCHECKPURCHASEBACK','单据[%s]%s不成功！原因：该单据已出库或者结束退货!','fixedstr'
from dual where not exists(select 1 from ld_desk where languagetype = 'zh' and labelbol = 'DOCUMENTNOOTHERSUCCESSCHECKPURCHASEBACK' and Labeltype = 'fixedstr');

insert into ld_desk(languagetype,labelbol,fieldlabel,Labeltype)
select 'en','DOCUMENTNOOTHERSUCCESSCHECKPURCHASEBACK','Document[%s] %s no success! The reason: The document has been audited!','fixedstr'
from dual where not exists(select 1 from ld_desk where languagetype = 'en' and labelbol = 'DOCUMENTNOOTHERSUCCESSCHECKPURCHASEBACK' and Labeltype = 'fixedstr');
delimiter;

call AddColumn('LD_users','dailyreporttemplet','text','',0);
delimiter;
call AddColumn('LD_users','weekreporttemplet','text','',0);
delimiter;
call AddColumn('LD_users','monthtypetemplet','text','',0);
delimiter;
UPDATE ld_users set dailyreporttemplet='<p>
    今日计划(昨日填写)：<br/><br/>今日总结：
</p>' WHERE dailyreporttemplet='' or dailyreporttemplet is null;
UPDATE ld_users set weekreporttemplet='<p>
    本周计划(上周填写)：<br/><br/>本周总结：
</p>' WHERE weekreporttemplet='' or weekreporttemplet is null; 
UPDATE ld_users set monthtypetemplet='<p>
    本月计划(上月填写)：<br/><br/>本月总结：
</p>' WHERE monthtypetemplet='' or monthtypetemplet is null; 
delimiter;
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) 
	select 'zh','EACHUSERCANSETTHEIROWNTEMPLATES','每个用户可设置自己的模板','fixedstr' from dual 
where not EXISTS(select 1 from ld_desk  where languagetype='zh' and 
labelbol='EACHUSERCANSETTHEIROWNTEMPLATES' and labeltype='fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) 
select 'en','EACHUSERCANSETTHEIROWNTEMPLATES' ,'Each user can set their own templets','fixedstr' from dual 
where not EXISTS(select 1 from ld_desk  where languagetype='en' 
and labelbol='EACHUSERCANSETTHEIROWNTEMPLATES' and Labeltype='fixedstr');
delimiter;
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) 
	select 'zh','DEFINEATEMPLATE','设置模板','fixedstr' from dual 
where not EXISTS(select 1 from ld_desk  where languagetype='zh' and 
labelbol='DEFINEATEMPLATE' and labeltype='fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) 
select 'en','DEFINEATEMPLATE' ,'Define a templet','fixedstr' from dual 
where not EXISTS(select 1 from ld_desk  where languagetype='en' 
and labelbol='DEFINEATEMPLATE' and Labeltype='fixedstr');
delimiter;
update ld_field set typeofdata='V~O' where typeofdata='I~O' and tabid=22 and uitype=150;
delimiter;
select tabid into @tabid from ld_tab where `name` = 'PriceBooks';
select fieldid into @fieldid from ld_field where tabid = @tabid and columnname = 'smownerid';
update ld_field set fieldname = 'assigned_user_id' where tabid = @tabid and fieldid = @fieldid;
insert into LD_def_org_field(tabid ,fieldid,visible,readonly)
select @tabid,@fieldid,0,0 from dual where not exists(select 1 from LD_def_org_field where tabid = @tabid and fieldid = @fieldid);
delimiter;

select  tabid into @tabid from ld_tab where name='OutboundOrder';
select fieldid into @relatedid from ld_field where tabid=@tabid and  columnname='adjustment';
insert into ld_tranlabel (languagetype,trantable,tabid,relateid,fieldlabel)
select 'zh','ld_field',@tabid,@relatedid,'调整' from dual 
where not EXISTS(select 1 from ld_tranlabel where LANGUAGEtype='zh' and trantable='ld_field' and tabid=@tabid and relateid=@relatedid);
insert into ld_tranlabel (languagetype,trantable,tabid,relateid,fieldlabel)
select 'en','ld_field',@tabid,@relatedid,'Adjustment' from dual 
where not EXISTS(select 1 from ld_tranlabel where LANGUAGEtype='en' and trantable='ld_field' and tabid=@tabid and relateid=@relatedid);
delimiter;

select tabid into @tabid from ld_tab where `name` = 'PriceBooks';
select fieldid into @fieldid from ld_field where tabid = @tabid and columnname = 'smownerid';
update ld_field set fieldname = 'assigned_user_id' where tabid = @tabid and fieldid = @fieldid;
insert into LD_def_org_field(tabid ,fieldid,visible,readonly)
select @tabid,@fieldid,0,0 from dual where not exists(select 1 from LD_def_org_field where tabid = @tabid and fieldid = @fieldid);
delimiter;

select tabid into @tabid  from ld_tab where name='purchaseorder';
select actionid into @actionid  from ld_actionmapping  where actionname='IMPORT';
delete from ld_profileallpermission where  operation=@actionid  and tabid=@tabid;
delimiter;
select usereportid into @usereportid from ld_usereport where  name="SIGNINSTATISTICS";
select max(sequence) into @maxsequnce from ld_usereportcolumns where Usereportid=@usereportid;
insert into ld_usereportcolumns(usereportid,columns,sequence,columnshow,realcolumns,realencolumns)
select @usereportid,'LD_singin:distance:distance:OftenUseReport_距离(米):N',@maxsequnce+1,1,'LD_singin:distance:distance:OftenUseReport_距离(米):N','LD_singin:distance:distance:OftenUseReport_distance(m):N'
from dual where not exists(select 1 from ld_usereportcolumns where Usereportid=@usereportid and  realcolumns like '%LD_singin:distance:distance:OftenUseReport%');
delimiter;

DELETE FROM ld_quickactions  WHERE tabid=(SELECT tabid FROM ld_tab WHERE name='Accounts') AND related_tabid=(SELECT tabid FROM ld_tab WHERE name='Events');
delimiter;

INSERT INTO ld_desk (languagetype,labelbol,fieldlabel,Labeltype)
SELECT 'zh', 'LBL_AUTOMATICCALLING','自动外呼','fixedstr' FROM DUAL
WHERE NOT EXISTS(SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol = 'LBL_AUTOMATICCALLING' AND Labeltype = 'fixedstr');
INSERT INTO ld_desk (languagetype,labelbol,fieldlabel,Labeltype)
SELECT 'en', 'LBL_AUTOMATICCALLING','Automatic calling','fixedstr' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype ='en' AND labelbol = 'LBL_AUTOMATICCALLING' AND Labeltype ='fixedstr');
delimiter;

INSERT INTO ld_desk (languagetype,labelbol,fieldlabel,Labeltype)
SELECT 'zh', 'LBL_SUPPORTTHESELECTALL','暂不支持全选所有！','jspop' FROM DUAL
WHERE NOT EXISTS(SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol = 'LBL_SUPPORTTHESELECTALL' AND Labeltype = 'jspop');
INSERT INTO ld_desk (languagetype,labelbol,fieldlabel,Labeltype)
SELECT 'en', 'LBL_SUPPORTTHESELECTALL','Does not support the select all!','jspop' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype ='en' AND labelbol = 'LBL_SUPPORTTHESELECTALL' AND Labeltype ='jspop');
delimiter;

INSERT INTO ld_desk (languagetype,labelbol,fieldlabel,Labeltype)
SELECT 'zh', 'LBL_CALLNOTAVAILABLE','没有可供外呼的电话，或电话字段未设置为外呼字段。','jspop' FROM DUAL
WHERE NOT EXISTS(SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol = 'LBL_CALLNOTAVAILABLE' AND Labeltype = 'jspop');
INSERT INTO ld_desk (languagetype,labelbol,fieldlabel,Labeltype)
SELECT 'en', 'LBL_CALLNOTAVAILABLE','Not available for outbound calls, or the phone field is not set to external field.','jspop' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype ='en' AND labelbol = 'LBL_CALLNOTAVAILABLE' AND Labeltype ='jspop');
delimiter;

INSERT INTO ld_desk (languagetype,labelbol,fieldlabel,Labeltype)
SELECT 'zh', 'LBL_CALLOUTBOUNDENDED','当前外呼计划已经结束。','jspop' FROM DUAL
WHERE NOT EXISTS(SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol = 'LBL_CALLOUTBOUNDENDED' AND Labeltype = 'jspop');
INSERT INTO ld_desk (languagetype,labelbol,fieldlabel,Labeltype)
SELECT 'en', 'LBL_CALLOUTBOUNDENDED','Current outbound program has ended.','jspop' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype ='en' AND labelbol = 'LBL_CALLOUTBOUNDENDED' AND Labeltype ='jspop');
delimiter;

INSERT INTO ld_desk (languagetype,labelbol,fieldlabel,Labeltype)
SELECT 'zh', 'LBL_CALLSECONDSNEXTCUSTOMER','秒后呼叫下一个客户。','jspop' FROM DUAL
WHERE NOT EXISTS(SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol = 'LBL_CALLSECONDSNEXTCUSTOMER' AND Labeltype = 'jspop');
INSERT INTO ld_desk (languagetype,labelbol,fieldlabel,Labeltype)
SELECT 'en', 'LBL_CALLSECONDSNEXTCUSTOMER','Seconds after the call the next customer.','jspop' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype ='en' AND labelbol = 'LBL_CALLSECONDSNEXTCUSTOMER' AND Labeltype ='jspop');
delimiter;

INSERT INTO ld_desk (languagetype,labelbol,fieldlabel,Labeltype)
SELECT 'zh', 'LBL_STOP','停止','jspop' FROM DUAL
WHERE NOT EXISTS(SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol = 'LBL_STOP' AND Labeltype = 'jspop');
INSERT INTO ld_desk (languagetype,labelbol,fieldlabel,Labeltype)
SELECT 'en', 'LBL_STOP','Stop','jspop' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype ='en' AND labelbol = 'LBL_STOP' AND Labeltype ='jspop');
delimiter;

INSERT INTO ld_desk (languagetype,labelbol,fieldlabel,Labeltype)
SELECT 'zh', 'LBL_START','开始','jspop' FROM DUAL
WHERE NOT EXISTS(SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol = 'LBL_START' AND Labeltype = 'jspop');
INSERT INTO ld_desk (languagetype,labelbol,fieldlabel,Labeltype)
SELECT 'en', 'LBL_START','Start','jspop' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype ='en' AND labelbol = 'LBL_START' AND Labeltype ='jspop');
delimiter;

INSERT INTO ld_desk (languagetype,labelbol,fieldlabel,Labeltype)
SELECT 'zh', 'LBL_SELECTNUMBERCALL','请选择一个号码点击外呼','jspop' FROM DUAL
WHERE NOT EXISTS(SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol = 'LBL_SELECTNUMBERCALL' AND Labeltype = 'jspop');
INSERT INTO ld_desk (languagetype,labelbol,fieldlabel,Labeltype)
SELECT 'en', 'LBL_SELECTNUMBERCALL','Please select a number click call','jspop' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype ='en' AND labelbol = 'LBL_SELECTNUMBERCALL' AND Labeltype ='jspop');
delimiter;

INSERT INTO ld_desk (languagetype,labelbol,fieldlabel,Labeltype)
SELECT 'zh', 'LBL_CANCELCALLQUEUE','确定清除当前呼叫队列？','jspop' FROM DUAL
WHERE NOT EXISTS(SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol = 'LBL_CANCELCALLQUEUE' AND Labeltype = 'jspop');
INSERT INTO ld_desk (languagetype,labelbol,fieldlabel,Labeltype)
SELECT 'en', 'LBL_CANCELCALLQUEUE','Clear the current call queue?','jspop' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype ='en' AND labelbol = 'LBL_CANCELCALLQUEUE' AND Labeltype ='jspop');
delimiter;

SELECT tabid INTO @tabid FROM ld_tab WHERE NAME = 'Faq';
SELECT fieldid INTO @fieldid FROM ld_field WHERE tabid = @tabid AND fieldname = 'assigned_user_id';
INSERT INTO LD_def_org_field (tabid,fieldid,visible,readonly)
SELECT @tabid,@fieldid,0,0
FROM DUAL WHERE  NOT EXISTS (SELECT 1 FROM LD_def_org_field WHERE tabid=@tabid AND fieldid=@fieldid);
delimiter;

select tabid into @tabid from ld_tab where name ='VendorContact';
select fieldid into @fieldid from ld_field where columnname = 'vendorid' and tabid = @tabid;
update ld_tranlabel set fieldlabel='供应商名称' where Relateid = @fieldid and languagetype='zh';
delimiter;

select tabid into @tabid from ld_tab where name ='VendorContact';
update ld_field set quickcreatesequence=1 where  tabid = @tabid and columnname = 'lastname';
update ld_field set quickcreatesequence=2 where  tabid = @tabid and columnname = 'firstname';
update ld_field set quickcreatesequence=3 where  tabid = @tabid and columnname = 'mobile';
update ld_field set quickcreatesequence=4 where  tabid = @tabid and columnname = 'officephone';
update ld_field set quickcreatesequence=5 where  tabid = @tabid and columnname = 'email';
update ld_field set quickcreatesequence=6 where  tabid = @tabid and columnname = 'vendorid';
update ld_field set quickcreatesequence=7 where  tabid = @tabid and columnname = 'smownerid';
delimiter;

UPDATE ld_desk SET fieldlabel='序时簿“全部”页签是否显示公海客户' WHERE labelbol ='WEHERTODISPLAYTHEPUBLICCUSTOMERES' AND languagetype='zh';
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,Labeltype)
select 'zh','SEARCHCHOOSE','查询选择','fixedstr' 
from dual where not exists(select 1 from ld_desk where languagetype = 'zh' and labelbol = 'SEARCHCHOOSE' and Labeltype='fixedstr');
delimiter;
insert into ld_desk(languagetype,labelbol,fieldlabel,Labeltype)
select 'en','SEARCHCHOOSE','Search Choose','fixedstr' 
from dual where not exists(select 1 from ld_desk where languagetype = 'en' and labelbol = 'SEARCHCHOOSE' and Labeltype='fixedstr');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,Labeltype)
select 'zh','LBL_SEARCHCHOOSE','查询选择','jspop' 
from dual where not exists(select 1 from ld_desk where languagetype = 'zh' and labelbol = 'LBL_SEARCHCHOOSE' and Labeltype='jspop');
delimiter;
insert into ld_desk(languagetype,labelbol,fieldlabel,Labeltype)
select 'en','LBL_SEARCHCHOOSE','Search Choose','jspop' 
from dual where not exists(select 1 from ld_desk where languagetype = 'en' and labelbol = 'LBL_SEARCHCHOOSE' and Labeltype='jspop');
delimiter;

UPDATE ld_field SET defaultvalue='普通用户' WHERE tabid=(SELECT tabid FROM ld_tab WHERE name='users') AND columnname='userlevel';
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'zh','ATOTALOF','共','jspop' from dual 
where not EXISTS(select 1 from ld_desk  where languagetype='zh' and labelbol='ATOTALOF' and Labeltype='jspop');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'en','ATOTALOF','A total of ','jspop' from dual 
where not EXISTS(select 1 from ld_desk  where languagetype='en' and labelbol='ATOTALOF' and Labeltype='jspop');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'zh','RECORDSEXPORTING','条记录，正在导出第','jspop' from dual 
where not EXISTS(select 1 from ld_desk  where languagetype='zh' and labelbol='RECORDSEXPORTING' and Labeltype='jspop');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'en','RECORDSEXPORTING',' records, exporting ','jspop' from dual 
where not EXISTS(select 1 from ld_desk  where languagetype='en' and labelbol='RECORDSEXPORTING' and Labeltype='jspop');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'zh','EXPORTTO2','-','jspop' from dual 
where not EXISTS(select 1 from ld_desk  where languagetype='zh' and labelbol='EXPORTTO2' and Labeltype='jspop');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'en','EXPORTTO2',' to ','jspop' from dual 
where not EXISTS(select 1 from ld_desk  where languagetype='en' and labelbol='EXPORTTO2' and Labeltype='jspop');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'zh','PLEASEWAITFORAMOMENT','条数据，请稍候……','jspop' from dual 
where not EXISTS(select 1 from ld_desk  where languagetype='zh' and labelbol='PLEASEWAITFORAMOMENT' and Labeltype='jspop');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'en','PLEASEWAITFORAMOMENT',' . Please wait for a moment! ','jspop' from dual 
where not EXISTS(select 1 from ld_desk  where languagetype='en' and labelbol='PLEASEWAITFORAMOMENT' and Labeltype='jspop');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'zh','RECORDSIMPORTING','条记录，正在导入第','jspop' from dual 
where not EXISTS(select 1 from ld_desk  where languagetype='zh' and labelbol='RECORDSIMPORTING' and Labeltype='jspop');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'en','RECORDSIMPORTING',' records, importing ','jspop' from dual 
where not EXISTS(select 1 from ld_desk  where languagetype='en' and labelbol='RECORDSIMPORTING' and Labeltype='jspop');
delimiter;

INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype) SELECT 'zh','LBL_WORK_TEMPLATE','工作协同模板','fixedstr' FROM DUAL
WHERE NOT EXISTS(SELECT 1 FROM ld_desk  WHERE languagetype='zh' AND labelbol='LBL_WORK_TEMPLATE' AND Labeltype='fixedstr');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype) SELECT 'en','LBL_WORK_TEMPLATE','The work schemes template','fixedstr' FROM DUAL
WHERE NOT EXISTS(SELECT 1 FROM ld_desk  WHERE languagetype='en' AND labelbol='LBL_WORK_TEMPLATE' AND Labeltype='fixedstr');
delimiter;
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype) SELECT 'zh','LBL_WORKSCHEMES_TEMPLATES','定制工作协同日志模板','fixedstr' FROM DUAL
WHERE NOT EXISTS(SELECT 1 FROM ld_desk  WHERE languagetype='zh' AND labelbol='LBL_WORKSCHEMES_TEMPLATES' AND Labeltype='fixedstr');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype) SELECT 'en','LBL_WORKSCHEMES_TEMPLATES','Customise the work schemes templates','fixedstr' FROM DUAL
WHERE NOT EXISTS(SELECT 1 FROM ld_desk  WHERE languagetype='en' AND labelbol='LBL_WORKSCHEMES_TEMPLATES' AND Labeltype='fixedstr');
delimiter;
SELECT blockid,sequence INTO @blockid,@seq FROM ld_settings_field WHERE NAME = 'THEDOCUMENTTEMPLATE';
set @seq1 = @seq + 1;
update ld_settings_field set sequence = (@seq1:=@seq1+1) where blockid = @blockid and sequence >= @seq and NAME not in ('THEDOCUMENTTEMPLATE','LBL_WORK_TEMPLATE');
SELECT MAX(fieldid) INTO @fieldid FROM ld_settings_field;
INSERT INTO LD_settings_field(fieldid,blockid,NAME,iconpath,description,linkto,sequence,active)
SELECT @fieldid+1,@blockid,'LBL_WORK_TEMPLATE','work_template.png','LBL_WORKSCHEMES_TEMPLATES','index.php?module=Settings&action=WorkTemplate&parenttab=Settings',@seq+1,0 FROM DUAL
WHERE NOT EXISTS(SELECT 1 FROM LD_settings_field WHERE NAME='LBL_WORK_TEMPLATE');
delimiter;
CREATE TABLE if not EXISTS `ld_workreport_field` (
  `id` int(19) NOT NULL,
  `name` varchar(100) DEFAULT NULL,
  `label` varchar(240) DEFAULT NULL,
  `entitytype` varchar(50) DEFAULT NULL,
  `type` int(4) DEFAULT NULL,
  `defaultvalue` varchar(240) DEFAULT NULL,
  `defaultheight` varchar(240) DEFAULT NULL,
  `is_mandatory` tinyint(1) DEFAULT 0,
  `is_activate` tinyint(1) DEFAULT 0,
  `deleted` tinyint(1) DEFAULT 0,
  `sequence` int(11) DEFAULT 0,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
delimiter;
CREATE TABLE IF NOT EXISTS `ld_workreport_field_seq` (
	`id` int(11) NOT NULL default '0',
	PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
delimiter;
INSERT INTO ld_workreport_field_seq(id) SELECT 0 FROM DUAL
WHERE NOT EXISTS(SELECT 1 FROM ld_workreport_field_seq  WHERE id>=0);
delimiter;
CREATE TABLE IF NOT EXISTS `ld_workreportcf` (
	`workreportid` int(11) NOT NULL default '0',
	PRIMARY KEY (`workreportid`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
delimiter;
select id into @id from ld_workreport_field_seq limit 1;
set @id = @id + 1;
INSERT INTO `ld_workreport_field`(id,name,label,entitytype,type,defaultheight,is_mandatory)
	SELECT @id,'worksummary','请填写今日工作总结','workreport',1,50,0 FROM DUAL
WHERE NOT EXISTS(SELECT 1 FROM `ld_workreport_field` WHERE entitytype = 'workreport'
	and type = 1 and name = 'worksummary');
set @id = @id + 1;
INSERT INTO `ld_workreport_field`(id,name,label,entitytype,type,defaultheight,is_mandatory)
	SELECT @id,'workplan','请填写明日工作计划','workreport',1,50,1 FROM DUAL
WHERE NOT EXISTS(SELECT 1 FROM `ld_workreport_field` WHERE entitytype = 'workreport'
	and type = 1 and name = 'workplan');
set @id = @id + 1;
INSERT INTO `ld_workreport_field`(id,name,label,entitytype,type,defaultheight,is_mandatory)
	SELECT @id,'workexperience','请填写工作心得体会','workreport',1,50,1 FROM DUAL
WHERE NOT EXISTS(SELECT 1 FROM `ld_workreport_field` WHERE entitytype = 'workreport'
	and type = 1 and name = 'workexperience');
update ld_workreport_field_seq set id = (select max(id) from `ld_workreport_field`);
delimiter;
select id into @id from ld_workreport_field_seq limit 1;
set @id = @id + 1;
INSERT INTO `ld_workreport_field`(id,name,label,entitytype,type,defaultheight,is_mandatory)
	SELECT @id,'worksummary','请填写本周工作总结','workreport',2,50,0 FROM DUAL
WHERE NOT EXISTS(SELECT 1 FROM `ld_workreport_field` WHERE entitytype = 'workreport'
	and type = 2 and name = 'worksummary');
set @id = @id + 1;
INSERT INTO `ld_workreport_field`(id,name,label,entitytype,type,defaultheight,is_mandatory)
	SELECT @id,'workplan','请填写下周工作计划','workreport',2,50,1 FROM DUAL
WHERE NOT EXISTS(SELECT 1 FROM `ld_workreport_field` WHERE entitytype = 'workreport'
	and type = 2 and name = 'workplan');
set @id = @id + 1;
INSERT INTO `ld_workreport_field`(id,name,label,entitytype,type,defaultheight,is_mandatory)
	SELECT @id,'workexperience','请填写工作心得体会','workreport',2,50,1 FROM DUAL
WHERE NOT EXISTS(SELECT 1 FROM `ld_workreport_field` WHERE entitytype = 'workreport'
	and type = 2 and name = 'workexperience');
update ld_workreport_field_seq set id = (select max(id) from `ld_workreport_field`);
delimiter;
select id into @id from ld_workreport_field_seq limit 1;
set @id = @id + 1;
INSERT INTO `ld_workreport_field`(id,name,label,entitytype,type,defaultheight,is_mandatory)
	SELECT @id,'worksummary','请填写本月工作总结','workreport',3,50,0 FROM DUAL
WHERE NOT EXISTS(SELECT 1 FROM `ld_workreport_field` WHERE entitytype = 'workreport'
	and type = 3 and name = 'worksummary');
set @id = @id + 1;
INSERT INTO `ld_workreport_field`(id,name,label,entitytype,type,defaultheight,is_mandatory)
	SELECT @id,'workplan','请填写下月工作计划','workreport',3,50,1 FROM DUAL
WHERE NOT EXISTS(SELECT 1 FROM `ld_workreport_field` WHERE entitytype = 'workreport'
	and type = 3 and name = 'workplan');
set @id = @id + 1;
INSERT INTO `ld_workreport_field`(id,name,label,entitytype,type,defaultheight,is_mandatory)
	SELECT @id,'workexperience','请填写工作心得体会','workreport',3,50,1 FROM DUAL
WHERE NOT EXISTS(SELECT 1 FROM `ld_workreport_field` WHERE entitytype = 'workreport'
	and type = 3 and name = 'workexperience');
update ld_workreport_field_seq set id = (select max(id) from `ld_workreport_field`);
delimiter;
update ld_workreport_field set sequence = id where entitytype = 'workreport' and sequence = 0;
delimiter;
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype) SELECT 'zh','LBL_FIELDNAME','字段名称','fixedstr' FROM DUAL
WHERE NOT EXISTS(SELECT 1 FROM ld_desk  WHERE languagetype='zh' AND labelbol='LBL_FIELDNAME' AND Labeltype='fixedstr');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype) SELECT 'en','LBL_FIELDNAME','Field Name','fixedstr' FROM DUAL
WHERE NOT EXISTS(SELECT 1 FROM ld_desk  WHERE languagetype='en' AND labelbol='LBL_FIELDNAME' AND Labeltype='fixedstr');
delimiter;
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype) SELECT 'zh','LBL_MANDATORYFIELDS','是否必填','fixedstr' FROM DUAL
WHERE NOT EXISTS(SELECT 1 FROM ld_desk  WHERE languagetype='zh' AND labelbol='LBL_MANDATORYFIELDS' AND Labeltype='fixedstr');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype) SELECT 'en','LBL_MANDATORYFIELDS','Mandatory Fields','fixedstr' FROM DUAL
WHERE NOT EXISTS(SELECT 1 FROM ld_desk  WHERE languagetype='en' AND labelbol='LBL_MANDATORYFIELDS' AND Labeltype='fixedstr');
delimiter;
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype) SELECT 'zh','LBL_DEFAULTHEIGHT','默认高度(px)','fixedstr' FROM DUAL
WHERE NOT EXISTS(SELECT 1 FROM ld_desk  WHERE languagetype='zh' AND labelbol='LBL_DEFAULTHEIGHT' AND Labeltype='fixedstr');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype) SELECT 'en','LBL_DEFAULTHEIGHT','Default height(px)','fixedstr' FROM DUAL
WHERE NOT EXISTS(SELECT 1 FROM ld_desk  WHERE languagetype='en' AND labelbol='LBL_DEFAULTHEIGHT' AND Labeltype='fixedstr');
delimiter;
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype) SELECT 'zh','LBL_DEFAULTVALUE','默认值','fixedstr' FROM DUAL
WHERE NOT EXISTS(SELECT 1 FROM ld_desk  WHERE languagetype='zh' AND labelbol='LBL_DEFAULTVALUE' AND Labeltype='fixedstr');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype) SELECT 'en','LBL_DEFAULTVALUE','Default','fixedstr' FROM DUAL
WHERE NOT EXISTS(SELECT 1 FROM ld_desk  WHERE languagetype='en' AND labelbol='LBL_DEFAULTVALUE' AND Labeltype='fixedstr');
delimiter;
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype) SELECT 'zh','LBL_ACTIVATE','状态','fixedstr' FROM DUAL
WHERE NOT EXISTS(SELECT 1 FROM ld_desk  WHERE languagetype='zh' AND labelbol='LBL_ACTIVATE' AND Labeltype='fixedstr');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype) SELECT 'en','LBL_ACTIVATE','Activate','fixedstr' FROM DUAL
WHERE NOT EXISTS(SELECT 1 FROM ld_desk  WHERE languagetype='en' AND labelbol='LBL_ACTIVATE' AND Labeltype='fixedstr');
delimiter;
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype) SELECT 'zh','LBL_WORKSCHEMESTYPE','日志类型','fixedstr' FROM DUAL
WHERE NOT EXISTS(SELECT 1 FROM ld_desk  WHERE languagetype='zh' AND labelbol='LBL_WORKSCHEMESTYPE' AND Labeltype='fixedstr');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype) SELECT 'en','LBL_WORKSCHEMESTYPE','Work schemes type','fixedstr' FROM DUAL
WHERE NOT EXISTS(SELECT 1 FROM ld_desk  WHERE languagetype='en' AND labelbol='LBL_WORKSCHEMESTYPE' AND Labeltype='fixedstr');
delimiter;
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype) SELECT 'zh','LBL_USERDEFINEDFIELDS','用户自定义字段','fixedstr' FROM DUAL
WHERE NOT EXISTS(SELECT 1 FROM ld_desk  WHERE languagetype='zh' AND labelbol='LBL_USERDEFINEDFIELDS' AND Labeltype='fixedstr');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype) SELECT 'en','LBL_USERDEFINEDFIELDS','User defined fields','fixedstr' FROM DUAL
WHERE NOT EXISTS(SELECT 1 FROM ld_desk  WHERE languagetype='en' AND labelbol='LBL_USERDEFINEDFIELDS' AND Labeltype='fixedstr');
delimiter;
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype) SELECT 'zh','LBL_DAILYRECORD','日志','fixedstr' FROM DUAL
WHERE NOT EXISTS(SELECT 1 FROM ld_desk  WHERE languagetype='zh' AND labelbol='LBL_DAILYRECORD' AND Labeltype='fixedstr');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype) SELECT 'en','LBL_DAILYRECORD','Daily record','fixedstr' FROM DUAL
WHERE NOT EXISTS(SELECT 1 FROM ld_desk  WHERE languagetype='en' AND labelbol='LBL_DAILYRECORD' AND Labeltype='fixedstr');
delimiter;
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype) SELECT 'zh','LBL_WEEKLYSCHEMES','周计划','fixedstr' FROM DUAL
WHERE NOT EXISTS(SELECT 1 FROM ld_desk  WHERE languagetype='zh' AND labelbol='LBL_WEEKLYSCHEMES' AND Labeltype='fixedstr');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype) SELECT 'en','LBL_WEEKLYSCHEMES','Weekly schemes','fixedstr' FROM DUAL
WHERE NOT EXISTS(SELECT 1 FROM ld_desk  WHERE languagetype='en' AND labelbol='LBL_WEEKLYSCHEMES' AND Labeltype='fixedstr');
delimiter;
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype) SELECT 'zh','LBL_MONTHLYSCHEMES','月计划','fixedstr' FROM DUAL
WHERE NOT EXISTS(SELECT 1 FROM ld_desk  WHERE languagetype='zh' AND labelbol='LBL_MONTHLYSCHEMES' AND Labeltype='fixedstr');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype) SELECT 'en','LBL_MONTHLYSCHEMES','Monthly schemes','fixedstr' FROM DUAL
WHERE NOT EXISTS(SELECT 1 FROM ld_desk  WHERE languagetype='en' AND labelbol='LBL_MONTHLYSCHEMES' AND Labeltype='fixedstr');
delimiter;

UPDATE ld_desk SET fieldlabel = '( 查看单据明细界面 )'WHERE labelbol='VIEWTHEDETAILS' and languagetype='zh';
UPDATE ld_desk SET fieldlabel = '( View the details )'WHERE labelbol='VIEWTHEDETAILS' and languagetype='en';
UPDATE ld_desk SET fieldlabel = '( 需购买并设置通讯账户 )'WHERE labelbol='NEEDBUYACCOUNT' and languagetype='zh';
UPDATE ld_desk SET fieldlabel = '( Need to buy communication account first )'WHERE labelbol='NEEDBUYACCOUNT' and languagetype='en';
UPDATE ld_desk SET fieldlabel = '( {$Accounts.Accounts}和{$HelpDesk.HelpDesk}明细界面 )' WHERE labelbol='SERVICEINFOREMIND' and languagetype='zh';
UPDATE ld_desk SET fieldlabel = '( {$Accounts.Accounts} and {$HelpDesk.HelpDesk}detail interface )' WHERE labelbol='SERVICEINFOREMIND' and languagetype='en';
delimiter;



insert into ld_desk(languagetype,labelbol,fieldlabel,Labeltype)
select 'zh','TOTHEHIGNSEASCUSTOMERSUCCESS','单据[%s]转为公海客户成功！','fixedstr' 
from dual where not exists(select 1 from ld_desk where languagetype = 'zh' and labelbol = 'TOTHEHIGNSEASCUSTOMERSUCCESS' and Labeltype = 'fixedstr');

insert into ld_desk(languagetype,labelbol,fieldlabel,Labeltype)
select 'en','TOTHEHIGNSEASCUSTOMERSUCCESS','Document[%s] To the high seas customer success','fixedstr' 
from dual where not exists(select 1 from ld_desk where languagetype = 'en' and labelbol = 'TOTHEHIGNSEASCUSTOMERSUCCESS' and Labeltype = 'fixedstr');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,Labeltype)
select 'zh','TOTHEHIGNSEASCUSTOMERERROR','单据[%s]转为公海客户失败，原因：当前单据已经时公海客户了！','fixedstr' 
from dual where not exists(select 1 from ld_desk where languagetype = 'zh' and labelbol = 'TOTHEHIGNSEASCUSTOMERERROR' and Labeltype = 'fixedstr');

insert into ld_desk(languagetype,labelbol,fieldlabel,Labeltype)
select 'en','TOTHEHIGNSEASCUSTOMERERROR','Document[%s] To the high seas customer success，The reason: when the customer documents have been on the high seas!','fixedstr' 
from dual where not exists(select 1 from ld_desk where languagetype = 'en' and labelbol = 'TOTHEHIGNSEASCUSTOMERERROR' and Labeltype = 'fixedstr');
delimiter;


insert into ld_desk(languagetype,labelbol,fieldlabel,Labeltype)
select 'zh','TOANORDINARYCUSTOMERSUCCESS','单据[%s]转为普通客户成功！','fixedstr' 
from dual where not exists(select 1 from ld_desk where languagetype = 'zh' and labelbol = 'TOANORDINARYCUSTOMERSUCCESS' and Labeltype = 'fixedstr');

insert into ld_desk(languagetype,labelbol,fieldlabel,Labeltype)
select 'en','TOANORDINARYCUSTOMERSUCCESS','Document[%s] To an ordinary customer success','fixedstr' 
from dual where not exists(select 1 from ld_desk where languagetype = 'en' and labelbol = 'TOANORDINARYCUSTOMERSUCCESS' and Labeltype = 'fixedstr');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,Labeltype)
select 'zh','TOANORDINARYCUSTOMERERROR','单据[%s]转为普通客户失败，原因：当前单据已经时普通客户了！','fixedstr' 
from dual where not exists(select 1 from ld_desk where languagetype = 'zh' and labelbol = 'TOANORDINARYCUSTOMERERROR' and Labeltype = 'fixedstr');

insert into ld_desk(languagetype,labelbol,fieldlabel,Labeltype)
select 'en','TOANORDINARYCUSTOMERERROR','Document[%s] To an ordinary customer success，The reason: when the customer documents have been on an ordinary!','fixedstr' 
from dual where not exists(select 1 from ld_desk where languagetype = 'en' and labelbol = 'TOANORDINARYCUSTOMERERROR' and Labeltype = 'fixedstr');
delimiter;


insert into ld_desk(languagetype,labelbol,fieldlabel,Labeltype)
select 'zh','SETREADSUCCESS','单据[%s]设为已读成功！','fixedstr' 
from dual where not exists(select 1 from ld_desk where languagetype = 'zh' and labelbol = 'SETREADSUCCESS' and Labeltype = 'fixedstr');

insert into ld_desk(languagetype,labelbol,fieldlabel,Labeltype)
select 'en','SETREADSUCCESS','Document[%s] set read success','fixedstr' 
from dual where not exists(select 1 from ld_desk where languagetype = 'en' and labelbol = 'SETREADSUCCESS' and Labeltype = 'fixedstr');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,Labeltype)
select 'zh','SETREADERROR','单据[%s]设为已读失败！原因：当前单据已经是已读！','fixedstr' 
from dual where not exists(select 1 from ld_desk where languagetype = 'zh' and labelbol = 'SETREADERROR' and Labeltype = 'fixedstr');

insert into ld_desk(languagetype,labelbol,fieldlabel,Labeltype)
select 'en','SETREADERROR','Document[%s] set read lose!','fixedstr' 
from dual where not exists(select 1 from ld_desk where languagetype = 'en' and labelbol = 'SETREADERROR' and Labeltype = 'fixedstr');
delimiter;


insert into ld_desk(languagetype,labelbol,fieldlabel,Labeltype)
select 'zh','SETUNREADSUCCESS','单据[%s]设为未读成功！','fixedstr' 
from dual where not exists(select 1 from ld_desk where languagetype = 'zh' and labelbol = 'SETUNREADSUCCESS' and Labeltype = 'fixedstr');

insert into ld_desk(languagetype,labelbol,fieldlabel,Labeltype)
select 'en','SETUNREADSUCCESS','Document[%s] set unread success','fixedstr' 
from dual where not exists(select 1 from ld_desk where languagetype = 'en' and labelbol = 'SETUNREADSUCCESS' and Labeltype = 'fixedstr');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,Labeltype)
select 'zh','SETUNREADERROR','单据[%s]设为未读失败！原因：当前单据已经是未读！','fixedstr' 
from dual where not exists(select 1 from ld_desk where languagetype = 'zh' and labelbol = 'SETUNREADERROR' and Labeltype = 'fixedstr');

insert into ld_desk(languagetype,labelbol,fieldlabel,Labeltype)
select 'en','SETUNREADERROR','Document[%s] set unread lose!','fixedstr' 
from dual where not exists(select 1 from ld_desk where languagetype = 'en' and labelbol = 'SETUNREADERROR' and Labeltype = 'fixedstr');
delimiter;

update ld_desk set fieldlabel = 'Each user can set their own template' where labelbol ='EACHUSERCANSETTHEIROWNTEMPLATES' and languagetype ='en';
update ld_desk set fieldlabel = 'Define a template' where labelbol='DEFINEATEMPLATE' and languagetype ='en';
delimiter;

SELECT tabid INTO @tabid FROM ld_tab WHERE NAME = 'Attachment';
SELECT fieldid INTO @fieldid FROM ld_field WHERE tabid = @tabid AND fieldname = 'assigned_user_id';
INSERT INTO LD_def_org_field (tabid,fieldid,visible,readonly)
SELECT @tabid,@fieldid,0,0
FROM DUAL WHERE  NOT EXISTS (SELECT 1 FROM LD_def_org_field WHERE tabid=@tabid AND fieldid=@fieldid);
delimiter;

CALL addColumn('ld_workreport_field','tablename','varchar','100',1);
DELIMITER;
UPDATE ld_workreport_field SET tablename = (CASE SUBSTR(NAME,8,1) WHEN '_' THEN 'ld_workreportcf' ELSE 'ld_wordreport' END)
WHERE tablename IS NULL;
DELIMITER;

insert into ld_desk(languagetype,labelbol,fieldlabel,Labeltype)
select 'zh','RELEASESUCCESS','单据[%s]释放成功！','fixedstr' 
from dual where not exists(select 1 from ld_desk where languagetype = 'zh' and labelbol = 'RELEASESUCCESS' and Labeltype = 'fixedstr');

insert into ld_desk(languagetype,labelbol,fieldlabel,Labeltype)
select 'en','RELEASESUCCESS','Document[%s] release success!','fixedstr' 
from dual where not exists(select 1 from ld_desk where languagetype = 'en' and labelbol = 'RELEASESUCCESS' and Labeltype = 'fixedstr');
delimiter;

UPDATE ld_field SET issmownerid=1 WHERE tabid =(SELECT tabid FROM ld_tab WHERE name='Products') AND columnname='smownerid';
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,Labeltype)
select 'zh','TOPROMOTETHESUCCESS','单据[%s]推进成功！','fixedstr' 
from dual where not exists(select 1 from ld_desk where languagetype = 'zh' and labelbol = 'TOPROMOTETHESUCCESS' and Labeltype = 'fixedstr');

insert into ld_desk(languagetype,labelbol,fieldlabel,Labeltype)
select 'en','TOPROMOTETHESUCCESS','Document[%s] To promote the success！','fixedstr' 
from dual where not exists(select 1 from ld_desk where languagetype = 'en' and labelbol = 'TOPROMOTETHESUCCESS' and Labeltype = 'fixedstr');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,Labeltype)
select 'zh','TOPROMOTEFAILURE','单据[%s]推进失败！','fixedstr' 
from dual where not exists(select 1 from ld_desk where languagetype = 'zh' and labelbol = 'TOPROMOTEFAILURE' and Labeltype = 'fixedstr');

insert into ld_desk(languagetype,labelbol,fieldlabel,Labeltype)
select 'en','TOPROMOTEFAILURE','Document[%s] Promote failure!','fixedstr' 
from dual where not exists(select 1 from ld_desk where languagetype = 'en' and labelbol = 'TOPROMOTEFAILURE' and Labeltype = 'fixedstr');
delimiter;

update ld_desk set fieldlabel='Define and set permissions for the roles' where labelbol = 'LBL_ROLE_DESCRIPTION' and languagetype ='en';
delimiter;
select tabid into @tabid from ld_tab where `name` = 'LessionPlan';
insert into LD_profileallpermission(tabid,operation)
select @tabid,3 from dual where not exists
(select 1 from LD_profileallpermission where tabid = @tabid and operation=3) and (select 1 from ld_version where trade='edu');
insert into LD_profileallpermission(tabid,operation)
select @tabid,4 from dual where not exists
(select 1 from LD_profileallpermission where tabid = @tabid and operation=4) and (select 1 from ld_version where trade='edu');
insert into LD_profileallpermission(tabid,operation)
select @tabid,11 from dual where not exists
(select 1 from LD_profileallpermission where tabid = @tabid and operation=11) and (select 1 from ld_version where trade='edu');
insert into LD_profileallpermission(tabid,operation)
select @tabid,1 from dual where not exists
(select 1 from LD_profileallpermission where tabid = @tabid and operation=1) and (select 1 from ld_version where trade='edu');
insert into LD_profileallpermission(tabid,operation)
select @tabid,2 from dual where not exists
(select 1 from LD_profileallpermission where tabid = @tabid and operation=2) and (select 1 from ld_version where trade='edu');
insert into LD_profileallpermission(tabid,operation)
select @tabid,12 from dual where not exists
(select 1 from LD_profileallpermission where tabid = @tabid and operation=12) and (select 1 from ld_version where trade='edu');
insert into LD_profileallpermission(tabid,operation)
select @tabid,13 from dual where not exists
(select 1 from LD_profileallpermission where tabid = @tabid and operation=13) and (select 1 from ld_version where trade='edu');
insert into LD_profileallpermission(tabid,operation)
select @tabid,14 from dual where not exists
(select 1 from LD_profileallpermission where tabid = @tabid and operation=14) and (select 1 from ld_version where trade='edu');
insert into LD_profileallpermission(tabid,operation)
select @tabid,6 from dual where not exists
(select 1 from LD_profileallpermission where tabid = @tabid and operation=6) and (select 1 from ld_version where trade='edu');
delimiter;
CREATE TABLE if not exists `ld_maxservicedate` (
  `inventoryid` int(19) default NULL,
  `productid` int(19) default NULL,
  `accountid` int(19) default NULL,
  `service_enddate` date default NULL,
  KEY `maxservicedate_accountid_idx` USING BTREE (`accountid`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
delimiter;

insert ld_maxservicedate (inventoryid, productid,accountid,service_enddate)select temp2.id,temp2.productid,temp1.accountid,temp1.service_enddate  from (
		SELECT
			LD_account.accountid,
			ld_inventoryproductrel.productid,
			max(
				LD_inventoryproductrel.servicecontracts_end_date
			) AS service_enddate
		FROM
			LD_account
		LEFT JOIN LD_servicecontracts ON LD_servicecontracts.accountid = LD_account.accountid
		LEFT JOIN LD_inventoryproductrel ON ld_inventoryproductrel.id = LD_servicecontracts.servicecontractsid
		GROUP BY
			ld_account.accountid,
			LD_inventoryproductrel.productid
	) AS temp1
LEFT JOIN (
	SELECT
		ld_account.accountid,
		ld_inventoryproductrel.productid,
		LD_inventoryproductrel.servicecontracts_end_date,
		max(LD_inventoryproductrel.id) AS id
	FROM
		LD_account
	LEFT JOIN LD_servicecontracts ON LD_servicecontracts.accountid = LD_account.accountid
	LEFT JOIN LD_inventoryproductrel ON ld_inventoryproductrel.id = LD_servicecontracts.servicecontractsid
	WHERE
		ld_servicecontracts.accountid > 0
	GROUP BY
		ld_account.accountid,
		LD_inventoryproductrel.productid,
		LD_inventoryproductrel.servicecontracts_end_date
) AS temp2 ON temp1.productid = temp2.productid
 and temp1.accountid = temp2.accountid
AND temp1.service_enddate = temp2.servicecontracts_end_date
 where temp2.productid>0 and temp1.accountid not in(select accountid from ld_maxservicedate);
 delimiter;
 
UPDATE ld_desk SET fieldlabel = '新增字段公式' WHERE labelbol = 'LBL_NEW_FIELD_EXPRESSION_BUTTON' AND languagetype = 'zh';
UPDATE ld_desk SET fieldlabel = 'Add field formula' WHERE labelbol = 'LBL_NEW_FIELD_EXPRESSION_BUTTON' AND languagetype = 'en';
delimiter;
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype) SELECT 'zh','LBL_CUSTOMLOGTEMPLATE','定制日志模板','fixedstr' FROM DUAL
WHERE NOT EXISTS(SELECT 1 FROM ld_desk  WHERE languagetype='zh' AND labelbol='LBL_CUSTOMLOGTEMPLATE' AND Labeltype='fixedstr');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype) SELECT 'en','LBL_CUSTOMLOGTEMPLATE','Custom log template','fixedstr' FROM DUAL
WHERE NOT EXISTS(SELECT 1 FROM ld_desk  WHERE languagetype='en' AND labelbol='LBL_CUSTOMLOGTEMPLATE' AND Labeltype='fixedstr');
delimiter;

UPDATE ld_tranlabel SET fieldlabel='Data query of related information' WHERE tabid=(SELECT tabid FROM ld_tab WHERE name='Users') 
AND trantable='LD_blocks' AND languagetype='en' AND fieldlabel='相关信息的数据查询';
delimiter;
UPDATE ld_tranlabel SET fieldlabel='Data query range' WHERE tabid=(SELECT tabid FROM ld_tab WHERE name='Users') 
AND trantable='LD_blocks' AND languagetype='en' AND fieldlabel='Data Access';
delimiter;
UPDATE ld_desk SET fieldlabel='Customize' WHERE labelbol='LBL_SENIOR' AND languagetype='en' AND Labeltype='fixedstr';
delimiter;
UPDATE ld_tranlabel SET  fieldlabel="Allow to view other users' data" WHERE tabid=(SELECT tabid FROM ld_tab WHERE name='Users') 
AND fieldlabel="Allow to view other users data" AND languagetype='en';
delimiter;
UPDATE ld_tranlabel SET  fieldlabel="Allow to edit other users' data" WHERE tabid=(SELECT tabid FROM ld_tab WHERE name='Users') 
AND fieldlabel="Allow to edit other users data" AND languagetype='en';
delimiter;
UPDATE ld_tranlabel SET  fieldlabel="Allow to delete other users' data" WHERE tabid=(SELECT tabid FROM ld_tab WHERE name='Users') 
AND fieldlabel="Allow to delete other users data" AND languagetype='en';
delimiter;
 
UPDATE ld_workreport_field SET tablename = (CASE SUBSTR(NAME,8,1) WHEN '_' THEN 'ld_workreportcf' ELSE 'ld_wordreport' END)
WHERE tablename IS NULL;
delimiter;
call getallprofile('Faq');
call fieldprofile('Faq');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','AccountsReceivableSummary','应收账款汇总表','fixedstr' 
from dual where not exists(select 1 from ld_desk where labelbol = 'AccountsReceivableSummary' and labeltype='fixedstr' and languagetype ='zh');

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','AccountsReceivableSummary','Accounts Receivable Summary','fixedstr' 
from dual where not exists(select 1 from ld_desk where labelbol = 'AccountsReceivableSummary' and labeltype='fixedstr' and languagetype ='en');
delimiter;
select usereportid into @usereportid from ld_usereport where `name` = 'SalesReport';
select max(sequence) into @sequence from ld_usereport where Parent_id = @usereportid;

insert into ld_usereport(name,reportlabel,tabids,basicfilter,advfilter,setcolumns,parent_id,sequence,reporttype,pagewidthpercent)
select 'AccountsReceivableSummary','应收账款汇总表',0,2,1,1,@usereportid,@sequence+1,21,'100' 
from dual where not exists(select 1 from ld_usereport where name = 'AccountsReceivableSummary');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','ACCOUNTINGPROJECTNAME','核算项目名称','fixedstr' 
from dual where not exists(select 1 from ld_desk where labelbol = 'ACCOUNTINGPROJECTNAME' and labeltype='fixedstr' and languagetype ='zh');

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','ACCOUNTINGPROJECTNAME','Accounting project name','fixedstr' 
from dual where not exists(select 1 from ld_desk where labelbol = 'ACCOUNTINGPROJECTNAME' and labeltype='fixedstr' and languagetype ='en');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','THERECEIVABLE','本期应收','fixedstr' 
from dual where not exists(select 1 from ld_desk where labelbol = 'THERECEIVABLE' and labeltype='fixedstr' and languagetype ='zh');

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','THERECEIVABLE','The receivable','fixedstr' 
from dual where not exists(select 1 from ld_desk where labelbol = 'THERECEIVABLE' and labeltype='fixedstr' and languagetype ='en');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','THISPERIODOFPAID','本期实收','fixedstr' 
from dual where not exists(select 1 from ld_desk where labelbol = 'THISPERIODOFPAID' and labeltype='fixedstr' and languagetype ='zh');

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','THISPERIODOFPAID','This period of paid','fixedstr' 
from dual where not exists(select 1 from ld_desk where labelbol = 'THISPERIODOFPAID' and labeltype='fixedstr' and languagetype ='en');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','THEFINALBALANCE','期末余额','fixedstr' 
from dual where not exists(select 1 from ld_desk where labelbol = 'THEFINALBALANCE' and labeltype='fixedstr' and languagetype ='zh');

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','THEFINALBALANCE','The final balance','fixedstr' 
from dual where not exists(select 1 from ld_desk where labelbol = 'THEFINALBALANCE' and labeltype='fixedstr' and languagetype ='en');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','THISYEARTHETOTALRECEIVABLES','本年累计应收','fixedstr' 
from dual where not exists(select 1 from ld_desk where labelbol = 'THISYEARTHETOTALRECEIVABLES' and labeltype='fixedstr' and languagetype ='zh');

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','THISYEARTHETOTALRECEIVABLES','This year the total receivables','fixedstr' 
from dual where not exists(select 1 from ld_desk where labelbol = 'THISYEARTHETOTALRECEIVABLES' and labeltype='fixedstr' and languagetype ='en');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','THEACCUMNLATEDPAID','本年累计实收','fixedstr' 
from dual where not exists(select 1 from ld_desk where labelbol = 'THEACCUMNLATEDPAID' and labeltype='fixedstr' and languagetype ='zh');

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','THEACCUMNLATEDPAID','The accumulated paid','fixedstr' 
from dual where not exists(select 1 from ld_desk where labelbol = 'THEACCUMNLATEDPAID' and labeltype='fixedstr' and languagetype ='en');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','BUSINESSPERSONNEL','业务人员','fixedstr' 
from dual where not exists(select 1 from ld_desk where labelbol = 'BUSINESSPERSONNEL' and labeltype='fixedstr' and languagetype ='zh');

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','BUSINESSPERSONNEL','Business personnel','fixedstr' 
from dual where not exists(select 1 from ld_desk where labelbol = 'BUSINESSPERSONNEL' and labeltype='fixedstr' and languagetype ='en');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','PERIODTIME','期间','fixedstr' 
from dual where not exists(select 1 from ld_desk where labelbol = 'PERIODTIME' and labeltype='fixedstr' and languagetype ='zh');

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','PERIODTIME','Period Time','fixedstr' 
from dual where not exists(select 1 from ld_desk where labelbol = 'PERIODTIME' and labeltype='fixedstr' and languagetype ='en');
delimiter;

UPDATE ld_field SET presence=0 where tabid =(SELECT tabid FROM ld_tab WHERE name='users') AND columnname IN ('hour_format','start_hour');
delimiter;

select usereportid into @id from LD_usereport where name='Eachprojectcontractincomestatisticsreport';

DELETE FROM ld_usereportcolumns WHERE Usereportid=@id AND columns LIKE 'LD_potentialscf:cf_1556:cf_1556:Potentials_%';

insert into LD_UseReportcolumns(id,Usereportid,columns,Sequence,columnshow,realcolumns,realencolumns) 
select '', @id, 'LD_salesordercf:cf_1616:cf_1616:SalesOrder_cf_1616:N', 11, 1, 'LD_salesordercf:cf_1616:cf_1616:SalesOrder_工程进度:V','LD_salesordercf:cf_1616:cf_1616:SalesOrder_Progress:V'   
from dual where not exists(select 1 from LD_UseReportcolumns where Usereportid=@id and realcolumns like 'LD_salesordercf:cf_1616:cf_1616:SalesOrder_%');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) 
select 'zh','ISNULL','为空值','jspop' 
from dual where not EXISTS(select 1 from ld_desk where languagetype='zh' and labelbol='ISNULL' and Labeltype='jspop');

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) 
select 'en','ISNULL','IS NULL','jspop' 
from dual where not EXISTS(select 1 from ld_desk  where languagetype='en' and labelbol='ISNULL' and Labeltype='jspop');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) 
select 'zh','ISNOTNULL','不为空值','jspop' 
from dual where not EXISTS(select 1 from ld_desk where languagetype='zh' and labelbol='ISNOTNULL' and Labeltype='jspop');

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) 
select 'en','ISNOTNULL','IS NOT NULL','jspop' 
from dual where not EXISTS(select 1 from ld_desk  where languagetype='en' and labelbol='ISNOTNULL' and Labeltype='jspop');
delimiter;

SELECT tabid INTO @tabid FROM ld_tab WHERE NAME = 'CashBill';
SELECT COUNT(fieldid) INTO @count FROM ld_field WHERE columnname = 'smownerid' AND tabid = @tabid ORDER BY fieldid DESC;
SELECT MAX(fieldid) INTO @fieldid FROM ld_field WHERE columnname = 'smownerid' AND tabid = @tabid ORDER BY fieldid DESC;
DELETE FROM ld_field WHERE fieldid = @fieldid AND 1 < @count;
delimiter;

call getallprofile('LessionPlan');
delimiter;

select tabid into @tabid from ld_tab where name = 'Events';
insert into ld_quickactions(tabid,related_tabid,sequence,presence)
select @tabid,-1,1,0 from dual 
where not EXISTS(select 1 from ld_quickactions  where tabid=@tabid and related_tabid=-1);
UPDATE ld_quickactions SET sequence=2 where tabid=@tabid AND related_tabid=-5; 
delimiter;

UPDATE ld_field SET presence=1 WHERE columnname='purchaseorder_id' AND tabid=(SELECT tabid FROM ld_tab WHERE name='PurchaseInvoice');
UPDATE ld_field SET displaytype=1 WHERE columnname='terms_conditions' AND tabid=(SELECT tabid FROM ld_tab WHERE name='PurchaseInvoice');

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'zh','DTPGTTPDCFS','日期，时间请去-产品明细自定义字段设置','fixedstr' from dual where not EXISTS(select 1 from ld_desk where languagetype='zh' and labelbol='DTPGTTPDCFS' and Labeltype='fixedstr');

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'en','DTPGTTPDCFS','Date, Time, please go to the product details custom field settings','fixedstr' from dual where not EXISTS(select 1 from ld_desk  where languagetype='en' and labelbol='DTPGTTPDCFS' and Labeltype='fixedstr');
delimiter;

UPDATE ld_field SET displaytype=3 WHERE columnname='purchaseorder_id' AND tabid=(SELECT tabid FROM ld_tab WHERE name='PurchaseInvoice');

UPDATE ld_field SET displaytype=3 WHERE columnname='purchaseorder_id' AND tabid=(SELECT tabid FROM ld_tab WHERE name='SendCashBill');
delimiter;

select tabid into @tabid from ld_tab where `name` = 'LessionPlan';
select actionid into @actionid from ld_actionmapping where actionname = 'Share';
DELETE from ld_profileallpermission where tabid = @tabid and operation = @actionid;
delete from ld_profile2standardpermissions where tabid = @tabid and operation = @actionid;
delimiter;

select tabid into @tabid from ld_tab where `name` = 'InventoryLedger';
select actionid into @actionid from ld_actionmapping where actionname = 'Export';
insert into ld_profileallpermission(tabid,operation)
select @tabid,@actionid from dual where not exists(select 1 from ld_profileallpermission where tabid = @tabid and operation = @actionid);
delimiter;

UPDATE ld_desk SET fieldlabel='Date, Time, please go to the product details custom field settings' where  languagetype='en' and labelbol='DTPGTTPDCFS' and Labeltype='fixedstr';
delimiter;
SELECT tabid INTO @tabid FROM ld_tab WHERE NAME = 'BankAccountSet';
SELECT fieldid INTO @fieldid FROM ld_field WHERE tabid = @tabid AND fieldname = 'currency_id';
DELETE FROM ld_def_org_field WHERE fieldid = @fieldid AND tabid != @tabid;
INSERT INTO LD_def_org_field (tabid,fieldid,visible,readonly)
SELECT @tabid,@fieldid,0,0
FROM DUAL WHERE  NOT EXISTS (SELECT 1 FROM LD_def_org_field WHERE tabid=@tabid AND fieldid=@fieldid);
UPDATE LD_profile2field SET tabid = @tabid WHERE fieldid = @fieldid AND tabid != @tabid;
delimiter;
call getallprofile('bankaccountset');
delimiter;
call fieldprofile('bankaccountset');
delimiter;
select tabid into @tabid from ld_tab where name='documents';
select actionid into @actionid from ld_actionmapping  where actionname='copy';
insert into ld_profileallpermission(tabid,operation)select @tabid,@actionid  from DUAL 
where not exists(select 1 from ld_profileallpermission where tabid=@tabid and operation=@actionid);
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
delimiter;
update ld_version set old_version='V6.0.0' ,current_version='V6.0.0' ,remark='V6.0.0-20150525';
delimiter;