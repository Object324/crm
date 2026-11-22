insert into ld_desk (languagetype,fieldlabel,labelbol,labeltype)
select 'zh','上上季度','PrevPrevfq','fixedstr' from dual 
where not exists(select 1 from ld_desk where labelbol='PrevPrevfq' and labeltype='fixedstr' and languagetype='zh');
delimiter;

insert into ld_desk (languagetype,fieldlabel,labelbol,labeltype)
select 'en','Before last quarter','PrevPrevfq','fixedstr' from dual 
where not exists(select 1 from ld_desk where labelbol='PrevPrevfq' and labeltype='fixedstr' and languagetype='en');
delimiter;

call AddColumn('ld_homestuffdetail','icon','varchar',50,'no');
delimiter;

update ld_homestuffdetail set icon='crm_Accounts.png' where stufflabel = 'NewAccounts';
update ld_homestuffdetail set icon='crm_Contacts.png' where stufflabel = 'NewContacts';
update ld_homestuffdetail set icon='crm_ContactRecords.png' where stufflabel = 'NewContactRecords';
update ld_homestuffdetail set icon='crm_SalesOrder.png' where stufflabel in ('SignContractCount','SignContractAmount','NewSalesOrderCount','NewSalesOrderAmount');
update ld_homestuffdetail set icon='crm_ServiceContracts.png' where stufflabel in ('NewServiceContractsCount','NewServiceContractsAmount');
update ld_homestuffdetail set icon='crm_Invoice.png' where stufflabel in ('NewInvoiceCount','NewInvoiceAmount');
update ld_homestuffdetail set icon='crm_OutboundOrder.png' where stufflabel in ('NewOutboundOrderAmount','NewOutboundOrderCount');
update ld_homestuffdetail set icon='crm_CashBill.png' where stufflabel in ('NewCashBillAmount','NewCashBillCount');
update ld_homestuffdetail set icon='crm_Potentials.png' where stufflabel in ('NewPotentialsCount','NewPotentialsAmount','AdvancePotentialsAmount','ChangePotentialStageCount');
update ld_homestuffdetail set icon='crm_Signin.png' where stufflabel = 'NewSignCount';
update ld_homestuffdetail set icon='crm_Leads.png' where stufflabel = 'NewLeadsCount';
update ld_homestuffdetail set icon='crm_HelpDesk.png' where stufflabel = 'NewHelpDeskCount';
update ld_homestuffdetail set icon='crm_PurchaseOrder.png' where stufflabel in ('NewPurchaseOrderCount','NewPurchaseOrderAmount');
delimiter;
-- 2020-05-07

insert into ld_desk(languagetype,labelbol,labeltype,fieldlabel)
select 'zh', 'EditCreateMe','fixedstr','编辑自己创建的单据' from dual 
where not exists(select 1 from ld_desk where  languagetype='zh' and labelbol='EditCreateMe' and labeltype='fixedstr');
delimiter;
insert into ld_desk(languagetype,labelbol,labeltype,fieldlabel)
select 'en', 'EditCreateMe','fixedstr','Edit Self-added' from dual 
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='EditCreateMe' and labeltype='fixedstr');
delimiter;

insert into ld_desk(languagetype,labelbol,labeltype,fieldlabel)
select 'zh', 'EditCreateMeTip','fixedstr','编辑自己创建的单据（角色权限必须有编辑权限）' from dual 
where not exists(select 1 from ld_desk where  languagetype='zh' and labelbol='EditCreateMeTip' and labeltype='fixedstr');
delimiter;
insert into ld_desk(languagetype,labelbol,labeltype,fieldlabel)
select 'en', 'EditCreateMeTip','fixedstr','Edit Self-added' from dual 
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='EditCreateMeTip' and labeltype='fixedstr');
delimiter;


insert into ld_desk(languagetype,labelbol,labeltype,fieldlabel)
select 'zh', 'ViewCreateMe','fixedstr','查看自己创建的单据' from dual 
where not exists(select 1 from ld_desk where  languagetype='zh' and labelbol='ViewCreateMe' and labeltype='fixedstr');
delimiter;
insert into ld_desk(languagetype,labelbol,labeltype,fieldlabel)
select 'en', 'ViewCreateMe','fixedstr','View Self-added' from dual 
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='ViewCreateMe' and labeltype='fixedstr');
delimiter;
insert into ld_desk(languagetype,labelbol,labeltype,fieldlabel)
select 'zh', 'ViewCreateMeTip','fixedstr','查看自己创建的单据(优先于角色权限)' from dual 
where not exists(select 1 from ld_desk where  languagetype='zh' and labelbol='ViewCreateMeTip' and labeltype='fixedstr');
delimiter;
insert into ld_desk(languagetype,labelbol,labeltype,fieldlabel)
select 'en', 'ViewCreateMeTip','fixedstr','View Self-added' from dual 
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='ViewCreateMeTip' and labeltype='fixedstr');
delimiter;


CALL AddColumn('ld_setscoperhigher','editcreateme','int',4,null);
delimiter;
update ld_setscoperhigher set editcreateme=editothers;
delimiter;

CALL AddColumn('ld_setscoperhigher','viewcreateme','int',4,null);
delimiter;
update ld_setscoperhigher set viewcreateme=viewothers;
delimiter;
update ld_desk set fieldlabel='标签名称' where languagetype='zh' and labelbol='MPFIELDLABEL' and Labeltype='fixedstr';
update ld_desk set fieldlabel='Label name' where languagetype='en' and labelbol='MPFIELDLABEL' and Labeltype='fixedstr';
update ld_desk set fieldlabel='模块列表字段设置' where languagetype='zh' and labelbol='THESETTINGOFSELFSERVICELISTFIELDS' and Labeltype='fixedstr';
update ld_desk set fieldlabel='Module list field settings' where languagetype='en' and labelbol='THESETTINGOFSELFSERVICELISTFIELDS' and Labeltype='fixedstr';
update ld_desk set fieldlabel='详情界面字段设置' where languagetype='zh' and labelbol='THESETTINGOFSELFSERVICEFIELDS' and Labeltype='fixedstr';
update ld_desk set fieldlabel='Details interface field settings' where languagetype='en' and labelbol='THESETTINGOFSELFSERVICEFIELDS' and Labeltype='fixedstr';
delimiter;

select fieldid into @fieldid  from ld_field where tabid=14 and columnname='productname';

update ld_producttoolfield set fieldid=@fieldid where columnname='productname';
delimiter;

update ld_desk set fieldlabel='群发前，请先到系统设置中设置邮件服务器' where languagetype='zh' and labelbol='Before_sending_please_go_to_SMTP' and Labeltype='fixedstr';
update ld_desk set fieldlabel='Before mass sending, please set up mail server in system settings' where languagetype='en' and labelbol='Before_sending_please_go_to_SMTP' and Labeltype='fixedstr';
delimiter;


update ld_desk set fieldlabel='是否允许结束审批流程' where labelbol='WHETHERAPPROVALPROCESS' and labeltype='fixedstr' and languagetype='zh';
delimiter;
update ld_desk set fieldlabel='是否允许修改本步骤审批人' where labelbol='specifytheapproval' and labeltype='fixedstr' and languagetype='zh';
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','ProgressTrackingSetting','进度跟踪设置','fixedstr' from dual 
where not EXISTS(select 1 from ld_desk where languagetype='zh' and labelbol='ProgressTrackingSetting' and Labeltype='fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','ProgressTrackingSetting','Progress Tracking Setting','fixedstr' from dual 
where not EXISTS(select 1 from ld_desk where languagetype='en' and labelbol='ProgressTrackingSetting' and Labeltype='fixedstr');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','Enableprogresstracking','启用进度跟踪','fixedstr' from dual 
where not EXISTS(select 1 from ld_desk where languagetype='zh' and labelbol='Enableprogresstracking' and Labeltype='fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','Enableprogresstracking','Enable progress tracking','fixedstr' from dual 
where not EXISTS(select 1 from ld_desk where languagetype='en' and labelbol='Enableprogresstracking' and Labeltype='fixedstr');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','Progresstrackingmethod','进度跟踪方式','fixedstr' from dual 
where not EXISTS(select 1 from ld_desk where languagetype='zh' and labelbol='Progresstrackingmethod' and Labeltype='fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','Progresstrackingmethod','Progress tracking method','fixedstr' from dual 
where not EXISTS(select 1 from ld_desk where languagetype='en' and labelbol='Progresstrackingmethod' and Labeltype='fixedstr');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','Byspecifiedfield','按指定字段','fixedstr' from dual 
where not EXISTS(select 1 from ld_desk where languagetype='zh' and labelbol='Byspecifiedfield' and Labeltype='fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','Byspecifiedfield','By specified field','fixedstr' from dual 
where not EXISTS(select 1 from ld_desk where languagetype='en' and labelbol='Byspecifiedfield' and Labeltype='fixedstr');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','Byspecifiedperiod','按指定期间','fixedstr' from dual 
where not EXISTS(select 1 from ld_desk where languagetype='zh' and labelbol='Byspecifiedperiod' and Labeltype='fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','Byspecifiedperiod','By specified period','fixedstr' from dual 
where not EXISTS(select 1 from ld_desk where languagetype='en' and labelbol='Byspecifiedperiod' and Labeltype='fixedstr');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','Selecttrackingfield','选择跟踪字段','fixedstr' from dual 
where not EXISTS(select 1 from ld_desk where languagetype='zh' and labelbol='Selecttrackingfield' and Labeltype='fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','Selecttrackingfield','Select tracking field','fixedstr' from dual 
where not EXISTS(select 1 from ld_desk where languagetype='en' and labelbol='Selecttrackingfield' and Labeltype='fixedstr');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','Selectstartdatefield','选择起始日期字段','fixedstr' from dual 
where not EXISTS(select 1 from ld_desk where languagetype='zh' and labelbol='Selectstartdatefield' and Labeltype='fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','Selectstartdatefield','Select start date field','fixedstr' from dual 
where not EXISTS(select 1 from ld_desk where languagetype='en' and labelbol='Selectstartdatefield' and Labeltype='fixedstr');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','Selectenddatefield','选择截止日期字段','fixedstr' from dual 
where not EXISTS(select 1 from ld_desk where languagetype='zh' and labelbol='Selectenddatefield' and Labeltype='fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','Selectenddatefield','Select end date field','fixedstr' from dual 
where not EXISTS(select 1 from ld_desk where languagetype='en' and labelbol='Selectenddatefield' and Labeltype='fixedstr');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','Showadvancelog','显示推进人和时间','fixedstr' from dual 
where not EXISTS(select 1 from ld_desk where languagetype='zh' and labelbol='Showadvancelog' and Labeltype='fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','Showadvancelog','Show advance log','fixedstr' from dual 
where not EXISTS(select 1 from ld_desk where languagetype='en' and labelbol='Showadvancelog' and Labeltype='fixedstr');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','Enableprogresstrackingonmobile','移动端启用进度跟踪','fixedstr' from dual 
where not EXISTS(select 1 from ld_desk where languagetype='zh' and labelbol='Enableprogresstrackingonmobile' and Labeltype='fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','Enableprogresstrackingonmobile','Enable progress tracking on mobile','fixedstr' from dual 
where not EXISTS(select 1 from ld_desk where languagetype='en' and labelbol='Enableprogresstrackingonmobile' and Labeltype='fixedstr');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','AND','和','jspop' from dual 
where not EXISTS(select 1 from ld_desk where languagetype='zh' and labelbol='AND' and Labeltype='jspop');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','AND',' And ','jspop' from dual 
where not EXISTS(select 1 from ld_desk where languagetype='en' and labelbol='AND' and Labeltype='jspop');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','Cannotbesettothesamefield','不可设置为同一字段','jspop' from dual 
where not EXISTS(select 1 from ld_desk where languagetype='zh' and labelbol='Cannotbesettothesamefield' and Labeltype='jspop');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','Cannotbesettothesamefield',' can not be set to thesame field ','jspop' from dual 
where not EXISTS(select 1 from ld_desk where languagetype='en' and labelbol='Cannotbesettothesamefield' and Labeltype='jspop');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','Advancetothenextstage','推进到下一阶段','fixedstr' from dual 
where not EXISTS(select 1 from ld_desk where languagetype='zh' and labelbol='Advancetothenextstage' and Labeltype='fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','Advancetothenextstage','Advance to the next stage','fixedstr' from dual 
where not EXISTS(select 1 from ld_desk where languagetype='en' and labelbol='Advancetothenextstage' and Labeltype='fixedstr');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','Advancetospecifiedstage','推进到指定阶段','fixedstr' from dual 
where not EXISTS(select 1 from ld_desk where languagetype='zh' and labelbol='Advancetospecifiedstage' and Labeltype='fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','Advancetospecifiedstage','Advance to specified stage','fixedstr' from dual 
where not EXISTS(select 1 from ld_desk where languagetype='en' and labelbol='Advancetospecifiedstage' and Labeltype='fixedstr');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','Dataerrorprogresscannotbedisplayed','数据错误，进度无法显示','fixedstr' from dual 
where not EXISTS(select 1 from ld_desk where languagetype='zh' and labelbol='Dataerrorprogresscannotbedisplayed' and Labeltype='fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','Dataerrorprogresscannotbedisplayed','Data error, progress cannot be displayed!','fixedstr' from dual 
where not EXISTS(select 1 from ld_desk where languagetype='en' and labelbol='Dataerrorprogresscannotbedisplayed' and Labeltype='fixedstr');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','PropelledFunnel','推进漏斗','fixedstr' from dual 
where not EXISTS(select 1 from ld_desk where languagetype='zh' and labelbol='PropelledFunnel' and Labeltype='fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','PropelledFunnel','Propelled Funnel','fixedstr' from dual 
where not EXISTS(select 1 from ld_desk where languagetype='en' and labelbol='PropelledFunnel' and Labeltype='fixedstr');
delimiter;

DROP PROCEDURE IF EXISTS `insert_profileallpermission`;
delimiter ||
CREATE  PROCEDURE `insert_profileallpermission`(
	operationid VARCHAR(50)
)
BEGIN

	declare done  int  default 0;
	declare ttabid  int ;
	declare cur1 CURSOR FOR select tabid from ld_profileallpermission where operation = 1 GROUP BY tabid;
	declare continue handler  for not   found  SET done =1;

	OPEN cur1;
	Fetch cur1 into ttabid;
 	loop1: while  done<>1 DO 
			set @sql=Concat('insert into ld_profileallpermission(tabid,operation,sequence) select ',ttabid,',',operationid,',',1000,' from dual where not exists(select 1 from ld_profileallpermission where tabid=',ttabid,' and operation=',operationid,')');
			prepare stmt from @sql;
			execute stmt; 
			deallocate  prepare  stmt;
			set @i = 0;
			update ld_profileallpermission set sequence=(@i:=@i+1) where tabid=ttabid order by  Sequence asc ;
		Fetch cur1 into ttabid;
	end while loop1;
	close cur1;
end ||
delimiter;

call insert_profileallpermission(22);
delimiter;

DROP PROCEDURE IF EXISTS `insert_profileallpermission`;

select tabid into @tabid from ld_tab where `name` = 'SalesGoal';
delete from ld_profileallpermission where tabid = @tabid and operation = 22;
delimiter;

DROP PROCEDURE IF EXISTS `AddModuleField`;
delimiter ||
CREATE  PROCEDURE `AddModuleField`(
	field_uitype INT(5),
	field_columnname VARCHAR(100),
	field_columntype VARCHAR(50),
	field_columnlen INT(5),
	field_isdefault INT(2),
	field_zh_tranlabel VARCHAR(20),
	field_en_tranlabel VARCHAR(20),
	field_typeofdata VARCHAR(20),
	field_quickcreate INT(5),
	field_displaytype INT(5),
	field_presence INT(5)
)
begin

	declare done  int  default 0;
	declare ttabid  int ;
	declare cur1 CURSOR FOR select tabid from ld_profileallpermission where operation = 1 GROUP BY tabid;
	declare continue handler  for not   found  SET done =1;

	OPEN cur1;
	Fetch cur1 into ttabid;
 	loop1: while  done<>1 DO 
			select `name` into @modulename from ld_tab where tabid = ttabid; 
			SET @tabid=ttabid;
			SET @relateid=(SELECT block FROM ld_field WHERE tabid=@tabid AND columnname='createdtime' LIMIT 1);
			SET @maxseq=IFNULL((SELECT MAX(sequence) FROM ld_field WHERE tabid=@tabid AND block=@relateid),0);
			SET @trantable='ld_field';
			SET @tablename=(SELECT tablename FROM ld_field WHERE tabid=@tabid AND columnname='createdtime' LIMIT 1);
			SET @columnname=field_columnname;
			SET @fieldname=field_columnname;
			SET @zh=field_zh_tranlabel;
			SET @en=field_en_tranlabel;
			SET @uitype=field_uitype;
			SET @typeofdata=field_typeofdata;
			SET @quickcreate=field_quickcreate;
			SET @displaytype=field_displaytype;
			SET @bigtype='';
			SET @datarang=NULL;
			SET @maxrowsshow=0;
			SET @presence=field_presence;
			SET @cnt = 0;
			select count(1) into @cnt from ld_field where tabid = ttabid and columnname = field_columnname;
			if @cnt = 0 and @tablename != '' then
				SET @maxid=(SELECT MAX(fieldid) FROM ld_field);

				INSERT INTO ld_field(tabid,fieldid,columnname,tablename,generatedtype,uitype,fieldname,fieldlabel,readonly,presence,defaultvalue,maximumlength,sequence,block,displaytype,typeofdata,quickcreate,quickcreatesequence,info_type,masseditable,helpinfo,fieldonly,approve_demand,is_checkimportfield,bigtype,datarang,maxrowsshow)
				SELECT @tabid,@maxid+1,@columnname,@tablename,1,@uitype,@fieldname,@zh,1,@presence,NULL,100,@maxseq+1,@relateid,@displaytype,@typeofdata,@quickcreate,NULL,NULL,1,NULL,0,1,0,@bigtype,@datarang,@maxrowsshow from dual
				WHERE NOT EXISTS (SELECT 1 FROM ld_field WHERE tabid=@tabid AND tablename=@tablename AND columnname=@columnname);

				UPDATE ld_field_seq SET id=(SELECT max(fieldid) FROM ld_field);

				SET @relateid=(SELECT fieldid FROM ld_field WHERE tabid=@tabid AND columnname=@columnname LIMIT 1);

				INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
				SELECT 'zh',@trantable,@tabid,@relateid,@zh FROM DUAL
				WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE languagetype = 'zh' AND trantable =@trantable AND tabid = @tabid AND relateid=@relateid);

				INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
				SELECT 'en',@trantable,@tabid,@relateid,@en FROM DUAL
				WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE languagetype = 'en' AND trantable =@trantable AND tabid = @tabid AND relateid=@relateid);
				
				call fieldprofile(@modulename);

				CALl AddColumn(@tablename,field_columnname,field_columntype,field_columnlen,field_isdefault);
			end if;
		Fetch cur1 into ttabid;
	end while loop1;
	close cur1;
end ||
delimiter;

SET @disable_triggers = 1;
call AddModuleField(1,'advance_stage','varchar','20','NULL','推进阶段','Advance Stage','V~O',1,3,1);

DROP PROCEDURE IF EXISTS `AddModuleField`;
SET @disable_triggers = NULL;

select tabid into @tabid from ld_tab where `name` = 'Leads';
update ld_field set displaytype = 1,uitype = 15,defaultvalue = '新建' where tabid = @tabid and columnname = 'status';
delimiter;

insert into ld_picklist_set(listname,relatetable) 
select 'status','ld_field' from dual 
where not exists(select 1 from ld_picklist_set where listname = 'status' and relatetable = 'ld_field'); 
delimiter;

select listid into @listid from ld_picklist_set where listname = 'status' and relatetable = 'ld_field';
INSERT INTO ld_picklist_values(listid,listvalue,sequence)
select @listid,'新建',1 from dual 
where not exists(select 1 from ld_picklist_values where listid = @listid and listvalue = '新建');
INSERT INTO ld_picklist_values(listid,listvalue,sequence)
select @listid,'跟进中',2 from dual 
where not exists(select 1 from ld_picklist_values where listid = @listid and listvalue = '跟进中');
INSERT INTO ld_picklist_values(listid,listvalue,sequence)
select @listid,'失败关闭',3 from dual 
where not exists(select 1 from ld_picklist_values where listid = @listid and listvalue = '失败关闭');
INSERT INTO ld_picklist_values(listid,listvalue,sequence)
select @listid,'升级',4 from dual 
where not exists(select 1 from ld_picklist_values where listid = @listid and listvalue = '升级');
delimiter;


DROP TABLE IF EXISTS `ld_settings_advance`;
CREATE TABLE IF NOT EXISTS `ld_settings_advance` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `tabid` int(11) DEFAULT NULL,
  `module` varchar(50) DEFAULT NULL,
  `enable` varchar(20) DEFAULT NULL,
  `method` varchar(20) DEFAULT NULL,
  `module_field` varchar(20) DEFAULT NULL,
  `module_period_start_field` varchar(20) DEFAULT NULL,
  `module_period_end_field` varchar(20) DEFAULT NULL,
  `showadvancelog` varchar(20) DEFAULT NULL,
  `showadvancemobile` varchar(20) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=utf8;
delimiter;

insert into ld_settings_advance(tabid,module,`enable`,method,module_field,module_period_start_field,module_period_end_field,showadvancelog,showadvancemobile)
select 2,'Potentials','yes','field','sales_stage',null,NULL,'yes','yes' from DUAL
where not exists(select 1 from ld_settings_advance where tabid = 2);
delimiter;

select tabid into @tabid from ld_tab where `name` = 'Leads';
insert into ld_settings_advance(tabid,module,`enable`,method,module_field,module_period_start_field,module_period_end_field,showadvancelog,showadvancemobile)
select @tabid,'Leads','yes','field','status',null,NULL,'yes','yes' from DUAL
where not exists(select 1 from ld_settings_advance where tabid = @tabid);
delimiter;

select tabid into @tabid from ld_tab where `name` = 'SalesOrder';
insert into ld_settings_advance(tabid,module,`enable`,method,module_field,module_period_start_field,module_period_end_field,showadvancelog,showadvancemobile)
select @tabid,'SalesOrder','yes','field','sostatus',null,NULL,'yes','yes' from DUAL
where not exists(select 1 from ld_settings_advance where tabid = @tabid) and not exists(select 1 from ld_crmentity where crmid>2);
delimiter;

select tabid into @tabid from ld_tab where `name` = 'Project';
insert into ld_settings_advance(tabid,module,`enable`,method,module_field,module_period_start_field,module_period_end_field,showadvancelog,showadvancemobile)
select @tabid,'Project','yes','field','projectstatus',null,NULL,'yes','yes' from DUAL
where not exists(select 1 from ld_settings_advance where tabid = @tabid) and not exists(select 1 from ld_crmentity where crmid>2);
delimiter;

CREATE TABLE if not exists  `ld_approvestep_old` (
  `id` int(19) NOT NULL,
  `specifyapproverid` int(4) DEFAULT NULL,
  `name` varchar(20) DEFAULT NULL,
  `approveid` int(19) DEFAULT NULL,
  `row_number` int(11) DEFAULT NULL,
	`nextid` int(19) NOT NULL,
  `bol` varchar(50) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
delimiter;

insert into ld_approvestep_old
select a.*,b.id as nextid,'a' as bol from 
(select id ,specifyapproverid,name,approveid , @num := @num + 1 as row_number from ld_approvestep,(SELECT @num:=0) r order by approveid, sequence) a, 
(select id ,specifyapproverid,name,approveid, @num2 := @num2 + 1 as row_number from ld_approvestep, (SELECT @num2:=0) r2 order by approveid, sequence) b 
where a.row_number + 1 = b.row_number  and not exists (select 1 from ld_approvestep_old)
order  by a.row_number asc;
update ld_approvestep 
INNER JOIN ld_approvestep_old on ld_approvestep.id=ld_approvestep_old.nextid
set ld_approvestep.specifyapproverid=ld_approvestep_old.specifyapproverid
where ld_approvestep_old.bol='a';
delimiter;

update ld_approvestep 
set ld_approvestep.specifyapproverid=0
where 
 ld_approvestep.id not in(select nextid from ld_approvestep_old)
and exists(select 1 from ld_approvestep_old where bol='a')  ;
delimiter;

update ld_approvestep_old set bol='b';
delimiter;

update ld_homestuffdetailcondition set `columns`=replace(`columns`,'ld_potentials','ld_potential');
delimiter;
-- 2020-05-12

UPDATE ld_systems_deploy SET deploy_value=0 WHERE deploy_type=206;
update ld_dashboard_app set home_presence='no' WHERE  NAME='Contractkit' AND NOT EXISTS (SELECT 1 FROM ld_version_firstlogin);
UPDATE ld_weixinmp_fields SET typeofdata='m' WHERE modulename='Accounts' AND fieldname='mobile';
UPDATE ld_weixinmp_fields SET typeofdata='o',displaytype='createno' WHERE modulename='Accounts' AND fieldname IN ('phone','filename');


DROP PROCEDURE IF EXISTS `ldcrm_reset_demodata_20200514`;
delimiter ||
CREATE  PROCEDURE `ldcrm_reset_demodata_20200514`(
)
BEGIN

	SET @tabid=2;
	SET @filed_cnt=(SELECT COUNT(1) FROM ld_field WHERE tabid=@tabid AND searchfieldtype=0 AND presence<>1);
	IF @filed_cnt<=2 OR @filed_cnt>=10 THEN
		UPDATE ld_field SET searchfieldtype=1 WHERE tabid=@tabid;
		UPDATE ld_field SET searchfieldtype=0 WHERE tabid=@tabid AND columnname IN ('potential_no','closingdate','sales_stage','account_id');
	END IF;

	SET @tabid=(SELECT tabid FROM ld_tab WHERE `name`='Leads');
	SET @filed_cnt=(SELECT COUNT(1) FROM ld_field WHERE tabid=@tabid AND searchfieldtype=0 AND presence<>1);
	IF @filed_cnt<=2 OR @filed_cnt>=10 THEN
		UPDATE ld_field SET searchfieldtype=1 WHERE tabid=@tabid;
		UPDATE ld_field SET searchfieldtype=0 WHERE tabid=@tabid AND columnname IN ('accountname','leadsource','status','productcategory');
	END IF;


end ||
delimiter;

CALL ldcrm_reset_demodata_20200514();
DROP PROCEDURE IF EXISTS `ldcrm_reset_demodata_20200514`;

ALTER TABLE ld_stock MODIFY COLUMN remark TEXT;
ALTER TABLE ld_outboundorder MODIFY COLUMN remark TEXT;
ALTER TABLE ld_checks MODIFY COLUMN remark TEXT;
-- 2020-05-14

insert into ld_desk (languagetype,labelbol,fieldlabel,labeltype)
select 'zh','SaleDragonTiger','销售龙虎榜','fixedstr' from dual 
where not exists(select 1 from ld_desk where labelbol='SaleDragonTiger' and labeltype='fixedstr' and languagetype='zh');
delimiter;

insert into ld_desk (languagetype,labelbol,fieldlabel,labeltype)
select 'en','SaleDragonTiger','Ranking List of Sales','fixedstr' from dual 
where not exists(select 1 from ld_desk where labelbol='SaleDragonTiger' and labeltype='fixedstr' and languagetype='en');
delimiter;

select wx_sequence into @wx_sequence from ld_dashboard_app where name='cashbillamount' ;
update ld_dashboard_app set wx_sequence=wx_sequence+2 where wx_sequence>@wx_sequence;
update ld_dashboard_app set home_sequence=home_sequence+1;
insert into ld_dashboard_app(name,labelbol,graphtype,modulenames,wx_sequence,image,presence,wx_presence,home_presence,home_sequence)
select 'salesdragontiger','SaleDragonTiger',3,'Accounts,Contacts,Potentials,Calendar,ContactRecords,HelpDesk,Sign',@wx_sequence+1,'dashboard_10',0,1,'yes',1 from 
dual  where not exists(select 1 from ld_dashboard_app where name='salesdragontiger');
delimiter;

update ld_dashboard_app  INNER JOIN   (
select (@rownum:=@rownum+1) as rownum,id from  ld_dashboard_app ,(select @rownum:=0) as r
ORDER BY wx_sequence asc 
)
as r1  on r1.id=ld_dashboard_app.id
set wx_sequence=rownum;
delimiter;

update ld_dashboard_app  INNER JOIN   (
select (@rownum:=@rownum+1) as rownum,id from  ld_dashboard_app ,(select @rownum:=0) as r
ORDER  by home_presence desc,home_sequence asc
)
as r1  on r1.id=ld_dashboard_app.id
set home_sequence=rownum
where home_presence='yes' ;
delimiter;
update ld_dashboard_app set home_sequence=0 where home_presence is null or  home_presence='';
delimiter;
select block_id into @block_id from ld_mobile_report_parent_tab where parenttab_label='rank';

select id into @tabid from ld_dashboard_app where name='salesdragontiger';
insert into ld_mobile_report_tab_rel(block_id,tabid,sequence,tab_tablename)
select @block_id,@tabid,4,'ld_tab' from dual 
where not EXISTS(select 1 from ld_mobile_report_tab_rel where @block_id=@block_id and tabid=@tabid
and tab_tablename='ld_tab');
delimiter;

update ld_profile2standardpermissions set relatednames=CONCAT(relatednames,'salesdragontiger')
where relatednames is not null and tabid=-2 and relatednames<>''
and exists(select 1 from ld_approvestep_old where bol='b');
update ld_approvestep_old set bol='c';
delimiter;

insert into ld_desk (languagetype,labelbol,fieldlabel,labeltype)
select 'zh','IsDeleteBlockTip','该区块下还有隐藏字段，删除区块后隐藏字段无法再使用。请确认是否删除？','fixedstr' from dual 
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='IsDeleteBlockTip' and labeltype='fixedstr');

insert into ld_desk (languagetype,labelbol,fieldlabel,labeltype)
select 'en','IsDeleteBlockTip','该区块下还有隐藏字段，删除区块后隐藏字段无法再使用。请确认是否删除？','fixedstr' from dual 
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='IsDeleteBlockTip' and labeltype='fixedstr');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','TREEDIAGRAM','树状图表','fixedstr' from dual 
where not EXISTS(select 1 from ld_desk where languagetype='zh' and labelbol='TREEDIAGRAM' and Labeltype='fixedstr');

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','TREEDIAGRAM','Tree Diagram','fixedstr' from dual 
where not EXISTS(select 1 from ld_desk where languagetype='en' and labelbol='TREEDIAGRAM' and Labeltype='fixedstr');
delimiter;
-- 2020-05-15

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

UPDATE ld_version SET old_version='V8.0.0.11',current_version='V8.0.0.11',remark='V8.0.0.11-20200515',wx_version='V8.0.1.2';
delimiter;