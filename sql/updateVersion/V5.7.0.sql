CALL addfldcrmentityinfo('LessionPlan');
delimiter;

update ld_field set defaultvalue=NULL where tabid=48 and columnname in ('targetenddate','actualenddate');

UPDATE ld_usereport SET reporttype=4 WHERE name='Performancestatisticscollection';
delimiter;

UPDATE ld_desk SET Fieldlabel='允许指定下一步审批人' WHERE labelbol='specifytheapproval' AND languagetype='zh' AND Labeltype='fixedstr';
delimiter;

UPDATE ld_desk SET Fieldlabel='是否允许指定审批步骤' WHERE labelbol='WHETHERAPPROVALSTEP' AND languagetype='zh' AND Labeltype='fixedstr';
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'zh','editingprocess','编辑步骤','fixedstr' 
from dual where not EXISTS(select 1 from ld_desk where languagetype='zh' and labelbol='editingprocess' and Labeltype='fixedstr');

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'en','editingprocess','editing process','fixedstr' 
from dual where not EXISTS(select 1 from ld_desk  where languagetype='en' and labelbol='editingprocess' and Labeltype='fixedstr');

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'zh','editingprocessd','指定审批步骤','fixedstr' 
from dual where not EXISTS(select 1 from ld_desk where languagetype='zh' and labelbol='editingprocessd' and Labeltype='fixedstr');

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'en','editingprocessd','editing process','fixedstr' 
from dual where not EXISTS(select 1 from ld_desk  where languagetype='en' and labelbol='editingprocessd' and Labeltype='fixedstr');
delimiter;

DELETE FROM ld_usereportcolumns WHERE Usereportid=22 AND columns LIKE '%LD_commission2payment:CommissionTotal:CommissionTotal:OftenUseReport_%';

select usereportid into @id from LD_usereport where name='Performancestatisticscollection';
insert into LD_UseReportcolumns(id,Usereportid,columns,Sequence,columnshow,realcolumns,realencolumns) 
select '', @id, 'LD_commission2payment:CommissionTotal:CommissionTotal:OftenUseReport_CommissionTotal:NN', 12, 1, 
'LD_commission2payment:CommissionTotal:CommissionTotal:OftenUseReport_佣金合计:NN',
'LD_commission2payment:CommissionTotal:CommissionTotal:OftenUseReport_Commission Total:NN'   
from dual where not exists(select 1 from LD_UseReportcolumns where Usereportid=@id and 
realcolumns='LD_commission2payment:CommissionTotal:CommissionTotal:OftenUseReport_佣金合计:NN');
delimiter;


select tabid into @tabid from ld_tab where `name` = 'PublicAnnouncement';
select fieldid into @fieldid from ld_field where tabid = @tabid and columnname = 'enddate';
update ld_field set typeofdata = 'D~O~OTH~GE~startdate~startdate' where tabid = @tabid and fieldid = @fieldid;
delimiter;
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'zh','CHARACTERLENGTH','字符长度应该为大于0的整数！','jspop' 
from dual where not EXISTS(select 1 from ld_desk where languagetype='zh' and labelbol='CHARACTERLENGTH' and Labeltype='jspop');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'en','CHARACTERLENGTH','Character length should be an integer greater than 0!','jspop' 
from dual where not EXISTS(select 1 from ld_desk  where languagetype='en' and labelbol='CHARACTERLENGTH' and Labeltype='jspop');
delimiter;

SELECT tabid into @tabid  from ld_tab where name='HelpDesk';
SELECT blockid into @blockid  from ld_blocks where tabid=@tabid and blocklabel='LBL_DESCRIPTION_INFORMATION';
UPDATE ld_tranlabel set fieldlabel='问题描述信息' where tabid=@tabid and trantable='LD_blocks' and languagetype='zh' and Relateid=@blockid;
UPDATE ld_tranlabel set fieldlabel='Problem description information' where tabid=@tabid and trantable='LD_blocks' and languagetype='en' and Relateid=@blockid;
SELECT fieldid into @fieldid from ld_field where tabid=@tabid and columnname='description';
UPDATE ld_tranlabel set fieldlabel='问题描述' where tabid=@tabid and trantable='LD_field' and languagetype='zh' and Relateid=@fieldid;
UPDATE ld_tranlabel set fieldlabel='Problem description' where tabid=@tabid and trantable='LD_field' and languagetype='en' and Relateid=@fieldid;
delimiter;

update ld_tranlabel set fieldlabel = '客户服务单' where languagetype = 'zh' and tabid in (select tabid from ld_tab where name = 'HelpDesk') 
and Relateid in (select tabid from ld_tab where name = 'HelpDesk') and trantable = 'LD_tab';
delimiter;
update ld_tranlabel set fieldlabel = 'Account Trouble Tickets' where languagetype = 'en' and tabid in (select tabid from ld_tab where name = 'HelpDesk') 
and Relateid in (select tabid from ld_tab where name = 'HelpDesk') and trantable = 'LD_tab';
delimiter;
update ld_desk set Fieldlabel='（只允许使用 jpg、gif、bmp 与 png 格式图片，建议图片大小不超过3M）' where labelbol='ONLYJPGGIFIMG' and languagetype='zh' and Labeltype = 'fixedstr';
delimiter;
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'zh','PROCESSINFO','流程信息','fixedstr' from dual 
where not EXISTS(select 1 from ld_desk  where languagetype='zh' and labelbol='PROCESSINFO' and Labeltype='fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'en','PROCESSINFO','Process Information','fixedstr' from dual 
where not EXISTS(select 1 from ld_desk  where languagetype='en' and labelbol='PROCESSINFO' and Labeltype='fixedstr');
delimiter;
-- end 2014-08-18 

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'zh','STATISTICALDISTRIBUTION','分布统计','fixedstr' from dual 
where not EXISTS(select 1 from ld_desk  where languagetype='zh' and labelbol='STATISTICALDISTRIBUTION' and Labeltype='fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'en','STATISTICALDISTRIBUTION','Statistical distribution','fixedstr' from dual 
where not EXISTS(select 1 from ld_desk  where languagetype='en' and labelbol='STATISTICALDISTRIBUTION' and Labeltype='fixedstr');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'zh','OPENMODULE','开启','fixedstr' from dual 
where not EXISTS(select 1 from ld_desk  where languagetype='zh' and labelbol='OPENMODULE' and Labeltype='fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'en','OPENMODULE','Open','fixedstr' from dual 
where not EXISTS(select 1 from ld_desk  where languagetype='en' and labelbol='OPENMODULE' and Labeltype='fixedstr');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'zh','REMOVECOMBINATION','删除组合','fixedstr' from dual 
where not EXISTS(select 1 from ld_desk  where languagetype='zh' and labelbol='REMOVECOMBINATION' and Labeltype='fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'en','REMOVECOMBINATION','Remove combination','fixedstr' from dual 
where not EXISTS(select 1 from ld_desk  where languagetype='en' and labelbol='REMOVECOMBINATION' and Labeltype='fixedstr');
delimiter;

update ld_tranlabel set fieldlabel = '优先级别' where languagetype = 'zh' and tabid in (select tabid from ld_tab where name = 'HelpDesk') 
and Relateid in (select fieldid from ld_field where columnname= 'priority' and tabid in (select tabid from ld_tab where name = 'HelpDesk') );
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'zh','MODULENAMECANNOTBEEMPTY','模块中英文名称不能为空!','jspop' from dual 
where not EXISTS(select 1 from ld_desk  where languagetype='zh' and labelbol='MODULENAMECANNOTBEEMPTY' and Labeltype='jspop');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'en','MODULENAMECANNOTBEEMPTY','Module English name and Chinese name cannot be empty!','jspop' from dual 
where not EXISTS(select 1 from ld_desk  where languagetype='en' and labelbol='MODULENAMECANNOTBEEMPTY' and Labeltype='jspop');
delimiter;
-- end 2014-08-19

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'zh','CHINESE','（中文）','fixedstr' from dual 
where not EXISTS(select 1 from ld_desk  where languagetype='zh' and labelbol='CHINESE' and Labeltype='fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'en','CHINESE','(Chinese)','fixedstr' from dual 
where not EXISTS(select 1 from ld_desk  where languagetype='en' and labelbol='CHINESE' and Labeltype='fixedstr');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'zh','ENGLISH','（英文）','fixedstr' from dual 
where not EXISTS(select 1 from ld_desk  where languagetype='zh' and labelbol='ENGLISH' and Labeltype='fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'en','ENGLISH','(English)','fixedstr' from dual 
where not EXISTS(select 1 from ld_desk  where languagetype='en' and labelbol='ENGLISH' and Labeltype='fixedstr');
delimiter;

UPDATE ld_desk set fieldlabel='应收款负责人分布统计' where labelbol='RECEIVECHARGE' and languagetype='zh';
UPDATE ld_desk set fieldlabel='Receivables  charge distribution statistics' where labelbol='RECEIVECHARGE' and languagetype='en';

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'zh','CNTAG','中文标签','fixedstr' from dual 
where not EXISTS(select 1 from ld_desk  where languagetype='zh' and labelbol='CNTAG' and Labeltype='fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'en','CNTAG','CN Tag:','fixedstr' from dual 
where not EXISTS(select 1 from ld_desk  where languagetype='en' and labelbol='CNTAG' and Labeltype='fixedstr');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'zh','ENTAG','英文标签','fixedstr' from dual 
where not EXISTS(select 1 from ld_desk  where languagetype='zh' and labelbol='ENTAG' and Labeltype='fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'en','ENTAG','EN Tag:','fixedstr' from dual 
where not EXISTS(select 1 from ld_desk  where languagetype='en' and labelbol='ENTAG' and Labeltype='fixedstr');
delimiter;

select tabid into @tabid from ld_tab where `name` = 'Documents';
select fieldid into @fieldid from ld_field where tabid = @tabid and columnname = 'filetype';
update ld_field set presence = 1 where tabid = @tabid and fieldid = @fieldid;
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'zh','Servicestartdate','服务开始日期','fixedstr' 
from dual where not EXISTS(select 1 from ld_desk where languagetype='zh' and labelbol='Servicestartdate' and Labeltype='fixedstr');

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'en','Servicestartdate','Service start date','fixedstr' 
from dual where not EXISTS(select 1 from ld_desk  where languagetype='en' and labelbol='Servicestartdate' and Labeltype='fixedstr');

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'zh','Serviceenddate','服务截止日期','fixedstr' 
from dual where not EXISTS(select 1 from ld_desk where languagetype='zh' and labelbol='Serviceenddate' and Labeltype='fixedstr');

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'en','Serviceenddate','Service end date','fixedstr' 
from dual where not EXISTS(select 1 from ld_desk  where languagetype='en' and labelbol='Serviceenddate' and Labeltype='fixedstr');
delimiter;
SELECT tabid INTO @id FROM ld_tab WHERE name='ServiceContracts';
UPDATE ld_field SET typeofdata="D~M" WHERE tabid=@id AND columnname='due_date';
delimiter;

INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype) SELECT 'zh','PICKLISTSTRINGISSAVE','当前设置已改变，是否保存？','jspop' FROM DUAL
WHERE NOT EXISTS(SELECT 1 FROM ld_desk WHERE languagetype='zh' AND labelbol='PICKLISTSTRINGISSAVE' AND Labeltype='jspop');

INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype) SELECT 'en','PICKLISTSTRINGISSAVE','The current setting has been changed. Do you want to save it?','jspop' FROM DUAL
WHERE NOT EXISTS(SELECT 1 FROM ld_desk  WHERE languagetype='en' AND labelbol='PICKLISTSTRINGISSAVE' AND Labeltype='jspop');
DELIMITER;

UPDATE ld_desk set Fieldlabel='EN Tag' where labelbol='ENTAG' and languagetype='en';
UPDATE ld_desk set Fieldlabel='CN Tag' where labelbol='CNTAG' and languagetype='en';
delimiter;
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'zh','MODULECHINESENAMEALREADYEXISTS','模块中文名称已存在','jspop' from dual 
where not EXISTS(select 1 from ld_desk  where languagetype='zh' and labelbol='MODULECHINESENAMEALREADYEXISTS' and Labeltype='jspop');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'en','MODULECHINESENAMEALREADYEXISTS','Module Chinese name already exists','jspop' from dual 
where not EXISTS(select 1 from ld_desk  where languagetype='en' and labelbol='MODULECHINESENAMEALREADYEXISTS' and Labeltype='jspop');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'zh','MODULEENGLISHNAMEALREADYEXISTS','模块英文名称已存在','jspop' from dual 
where not EXISTS(select 1 from ld_desk  where languagetype='zh' and labelbol='MODULEENGLISHNAMEALREADYEXISTS' and Labeltype='jspop');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'en','MODULEENGLISHNAMEALREADYEXISTS','Module English name already exists','jspop' from dual 
where not EXISTS(select 1 from ld_desk  where languagetype='en' and labelbol='MODULEENGLISHNAMEALREADYEXISTS' and Labeltype='jspop');
delimiter;

insert into ld_systems_deploy(deploy_value,deploy_type,description,setype)
select 0,42,'关联产品明细信息时否显示小计和调整','' from dual where not exists
(select 1 from ld_systems_deploy where deploy_type=42);
delimiter;
insert into ld_systems_deploy(deploy_value,deploy_type,description,setype)
select 0,43,'关联产品明细信息时否显示折扣和税','' from dual where not exists
(select 1 from ld_systems_deploy where deploy_type=43);
delimiter;

UPDATE ld_desk set Fieldlabel="关联产品明细信息时是否显示'成本价'和'GP(毛利率 %)'" where labelbol='PRODUCTSETLABEL' and languagetype='zh';
UPDATE ld_desk set Fieldlabel="Whether to display 'Cost Price' and 'GP(Cost Profit %)' when relate to products details" where labelbol='PRODUCTSETLABEL' and languagetype='en';
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'zh','WHETHERTODISPLAYDISOUNTANDTAX',"关联产品明细信息时否显示'折扣'和'税'",'fixedstr' from dual 
where not EXISTS(select 1 from ld_desk  where languagetype='zh' and labelbol='WHETHERTODISPLAYDISOUNTANDTAX' and Labeltype='fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'en','WHETHERTODISPLAYDISOUNTANDTAX',"Whether to display 'Discount' and 'Tax' when relate to products details",'fixedstr' from dual 
where not EXISTS(select 1 from ld_desk  where languagetype='en' and labelbol='WHETHERTODISPLAYDISOUNTANDTAX' and Labeltype='fixedstr');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'zh','WHETHERTODISPLAYSUBTOTALANDADJUSTMENT',"关联产品明细信息时否显示'小计'和'调整'",'fixedstr' from dual 
where not EXISTS(select 1 from ld_desk  where languagetype='zh' and labelbol='WHETHERTODISPLAYSUBTOTALANDADJUSTMENT' and Labeltype='fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'en','WHETHERTODISPLAYSUBTOTALANDADJUSTMENT',"Whether to display ‘Subtotal’ and ‘Adjustment’ when relate to products details",'fixedstr' from dual 
where not EXISTS(select 1 from ld_desk  where languagetype='en' and labelbol='WHETHERTODISPLAYSUBTOTALANDADJUSTMENT' and Labeltype='fixedstr');
delimiter;


select cvid into @cvid from ld_customview where entitytype='VendorContact' and viewname='ALl';
delete from ld_cvcolumnlist where cvid=@cvid;
insert into ld_cvcolumnlist(cvid,columnindex,columnname)
select @cvid,0,'LD_vendorcontacts:lastname:lastname:VendorContact_fieldlabel:V';
insert into ld_cvcolumnlist(cvid,columnindex,columnname)
select @cvid,1,'LD_vendorcontacts:vendorid:vendor_id:VendorContact_fieldlabel:V';
insert into ld_cvcolumnlist(cvid,columnindex,columnname)
select @cvid,2,'LD_vendorcontacts:title:title:VendorContact_fieldlabel:V';
insert into ld_cvcolumnlist(cvid,columnindex,columnname)
select @cvid,3,'LD_vendorcontacts:mobile:mobile:VendorContact_fieldlabel:V';
insert into ld_cvcolumnlist(cvid,columnindex,columnname)
select @cvid,4,'LD_vendorcontacts:officephone:officephone:VendorContact_fieldlabel:V';
insert into ld_cvcolumnlist(cvid,columnindex,columnname)
select @cvid,5,'LD_vendorcontacts:email:email:VendorContact_fieldlabel:E';
insert into ld_cvcolumnlist(cvid,columnindex,columnname)
select @cvid,6,'LD_vendorcontacts:qq:qq:VendorContact_fieldlabel:V';
insert into ld_cvcolumnlist(cvid,columnindex,columnname)
select @cvid,7,'LD_vendorcontacts:smownerid:assigned_user_id:VendorContact_fieldlabel:V';
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','STARTDATECANNOTBEGERATERTHANTHE','开始日期不能大于截止日期','jspop' 
from dual where not EXISTS(select 1 from ld_desk  where languagetype = 'zh' 
and labeltype ='jspop' and labelbol = 'STARTDATECANNOTBEGERATERTHANTHE');

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','STARTDATECANNOTBEGERATERTHANTHE','Start date cannot be greater than the cutoff date','jspop' 
from dual where not EXISTS(select 1 from ld_desk  where languagetype = 'en' 
and labeltype ='jspop' and labelbol = 'STARTDATECANNOTBEGERATERTHANTHE');
-- end 2014-08-21

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'zh','LINK','链接','fixedstr' 
from dual where not EXISTS(select 1 from ld_desk where languagetype='zh' and labelbol='LINK' and Labeltype='fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'en','LINK','Link','fixedstr' 
from dual where not EXISTS(select 1 from ld_desk  where languagetype='en' and labelbol='LINK' and Labeltype='fixedstr');
delimiter;

select tabid into @tabid from ld_tab where `name` = 'Documents';
select fieldid into @fieldid from ld_field where tabid = @tabid and columnname = 'fileversion';
update ld_field set presence = 1 where tabid = @tabid and fieldid = @fieldid;
delimiter;

select tabid into @tabid from ld_tab where `name` = 'Reminds';
select fieldid into @fieldid from ld_field where tabid = @tabid and columnname = 'reltab';
update ld_field set displaytype = 3 where tabid = @tabid and fieldid = @fieldid;
delimiter;

INSERT INTO ld_eventhandlers(event_name,handler_path,handler_class,cond,is_active)
SELECT 'vtiger.entity.beforesave.modifiable','modules/FieldFormulas/VTFieldFormulasEventHandler.inc','VTFieldFormulasEventHandler','',1 FROM DUAL
WHERE NOT EXISTS(SELECT 1 FROM ld_eventhandlers WHERE event_name='vtiger.entity.beforesave.modifiable' AND handler_class='VTFieldFormulasEventHandler');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'zh','ONLINEHELP','在线帮助','fixedstr' from dual 
where not EXISTS(select 1 from ld_desk  where languagetype='zh' and labelbol='ONLINEHELP' and Labeltype='fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'en','ONLINEHELP','Online Help','fixedstr' from dual 
where not EXISTS(select 1 from ld_desk  where languagetype='en' and labelbol='ONLINEHELP' and Labeltype='fixedstr');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'zh','MESSAGENOTMORETHAN64CHARACTERS','短信内容加短信签名不能多于64个字','fixedstr' from dual 
where not EXISTS(select 1 from ld_desk  where languagetype='zh' and labelbol='MESSAGENOTMORETHAN64CHARACTERS' and Labeltype='fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'en','MESSAGENOTMORETHAN64CHARACTERS','The content of the message and the message signature cannot be more than 64 characters','fixedstr' from dual 
where not EXISTS(select 1 from ld_desk  where languagetype='en' and labelbol='MESSAGENOTMORETHAN64CHARACTERS' and Labeltype='fixedstr');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'zh','SELECTGROUNPADDCUSTOMERSPHONE','选择分组，可添加该分组客户至接收人手机','fixedstr' from dual 
where not EXISTS(select 1 from ld_desk  where languagetype='zh' and labelbol='SELECTGROUNPADDCUSTOMERSPHONE' and Labeltype='fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'en','SELECTGROUNPADDCUSTOMERSPHONE','Selection of a packet, the packet can be added to the recipient mobile phone customers','fixedstr' from dual 
where not EXISTS(select 1 from ld_desk  where languagetype='en' and labelbol='SELECTGROUNPADDCUSTOMERSPHONE' and Labeltype='fixedstr');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'zh','IFNOTCREATEGROUP','如果没有你需要的分组，可自行创建新分组','fixedstr' from dual 
where not EXISTS(select 1 from ld_desk  where languagetype='zh' and labelbol='IFNOTCREATEGROUP' and Labeltype='fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'en','IFNOTCREATEGROUP','If not you need to create a new packet, the packet','fixedstr' from dual 
where not EXISTS(select 1 from ld_desk  where languagetype='en' and labelbol='IFNOTCREATEGROUP' and Labeltype='fixedstr');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'zh','NEXTLETTER','下一封','fixedstr' from dual 
where not EXISTS(select 1 from ld_desk  where languagetype='zh' and labelbol='NEXTLETTER' and Labeltype='fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'en','NEXTLETTER','The next letter','fixedstr' from dual 
where not EXISTS(select 1 from ld_desk  where languagetype='en' and labelbol='NEXTLETTER' and Labeltype='fixedstr');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'zh','ALETTEROF','上一封','fixedstr' from dual 
where not EXISTS(select 1 from ld_desk  where languagetype='zh' and labelbol='ALETTEROF' and Labeltype='fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'en','ALETTEROF','A letter of','fixedstr' from dual 
where not EXISTS(select 1 from ld_desk  where languagetype='en' and labelbol='ALETTEROF' and Labeltype='fixedstr');
delimiter;
-- end 2014-08-25


DROP PROCEDURE IF EXISTS `AddColumn`;
delimiter ||
CREATE  PROCEDURE `AddColumn`(
	tablename VARCHAR(50),
	columnname VARCHAR(50),
	columntype VARCHAR(50),
	columnlen INT(5),
	isdefault INT(2)
)
BEGIN
	SELECT DATABASE() INTO @tableschema;
	SET tablename=LOWER(tablename);
	SET @tsql=CONCAT('select  IFNULL(column_name, '''') into @colName  from information_schema.columns where  TABLE_SCHEMA =','''',@tableschema,'''','  and
	table_name= ','''',tablename,'''',' and COLUMN_NAME=','''',columnname,'''');
	PREPARE stmt FROM @tsql;
	EXECUTE stmt;
	SET @coladd=IFNULL(@colName,'-1');
	IF @coladd = '-1'  OR @coladd<>columnname THEN
		IF columntype='date'  OR columntype='datetime' OR columntype='text' THEN
			SET @alterColumn=CONCAT(' alter table ',tablename, ' add column ',columnname, ' ',columntype, ' default null');
		ELSEIF isdefault=0 THEN
			SET @alterColumn=CONCAT(' alter table ',tablename, ' add column ',columnname, ' ',columntype, ' default 0 ');
		ELSE
			 SET @alterColumn=CONCAT(' alter table ',tablename, ' add column ',columnname, ' ',columntype,'(',columnlen,')');
		END IF;
	PREPARE stalter FROM @altercolumn;
		EXECUTE stalter;
	END IF;
END ||
delimiter;

call addcolumn('ld_account_set','astricttype','int',4,1);
UPDATE ld_account_set SET astricttype =1 WHERE astricttype IS NULL;
delimiter;

CREATE TABLE IF NOT EXISTS `ld_role_astrictcount` (
  `roleid` varchar(255) DEFAULT NULL,
  `astrictcount` int(11) DEFAULT NULL
) ENGINE=MyISAM DEFAULT CHARSET=utf8;
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'zh','Themaximumnumberofhighseascustomers','可拥有公海客户数量上限','fixedstr' 
from dual where not EXISTS(select 1 from ld_desk where languagetype='zh' and labelbol='Themaximumnumberofhighseascustomers' and Labeltype='fixedstr');

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'en','Themaximumnumberofhighseascustomers','The maximum number of high seas customersThe maximum number of high seas customers','fixedstr' 
from dual where not EXISTS(select 1 from ld_desk  where languagetype='en' and labelbol='Themaximumnumberofhighseascustomers' and Labeltype='fixedstr');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'zh','maximumnumberofhighseascustomers','公海客户数量上限','fixedstr' 
from dual where not EXISTS(select 1 from ld_desk where languagetype='zh' and labelbol='maximumnumberofhighseascustomers' and Labeltype='fixedstr');

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'en','maximumnumberofhighseascustomers','The maximum number of high seas customersThe maximum number of high seas customers','fixedstr' 
from dual where not EXISTS(select 1 from ld_desk  where languagetype='en' and labelbol='maximumnumberofhighseascustomers' and Labeltype='fixedstr');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'zh','Accordingtotheusercontrol','按用户控制','fixedstr' 
from dual where not EXISTS(select 1 from ld_desk where languagetype='zh' and labelbol='Accordingtotheusercontrol' and Labeltype='fixedstr');

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'en','Accordingtotheusercontrol','According to the user control','fixedstr' 
from dual where not EXISTS(select 1 from ld_desk  where languagetype='en' and labelbol='Accordingtotheusercontrol' and Labeltype='fixedstr');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'zh','Eachuser','每用户','fixedstr' 
from dual where not EXISTS(select 1 from ld_desk where languagetype='zh' and labelbol='Eachuser' and Labeltype='fixedstr');

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'en','Eachuser','Each user','fixedstr' 
from dual where not EXISTS(select 1 from ld_desk  where languagetype='en' and labelbol='Eachuser' and Labeltype='fixedstr');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'zh','Accordingtotherolcontrol','按角色控制','fixedstr' 
from dual where not EXISTS(select 1 from ld_desk where languagetype='zh' and labelbol='Accordingtotherolcontrol' and Labeltype='fixedstr');

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'en','Accordingtotherolcontrol','According to the role control','fixedstr' 
from dual where not EXISTS(select 1 from ld_desk  where languagetype='en' and labelbol='Accordingtotherolcontrol' and Labeltype='fixedstr');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'zh','Limitthenumbermustbeapositiveinteger','限制数量必须是正整数！','jspop' 
from dual where not EXISTS(select 1 from ld_desk where languagetype='zh' and labelbol='Limitthenumbermustbeapositiveinteger' and Labeltype='jspop');

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'en','Limitthenumbermustbeapositiveinteger','Limit the number must be a positive integer!','jspop' 
from dual where not EXISTS(select 1 from ld_desk  where languagetype='en' and labelbol='Limitthenumbermustbeapositiveinteger' and Labeltype='jspop');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'zh','Savefailed','保存失败','jspop' 
from dual where not EXISTS(select 1 from ld_desk where languagetype='zh' and labelbol='Savefailed' and Labeltype='jspop');

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'en','Savefailed','Save failed','jspop' 
from dual where not EXISTS(select 1 from ld_desk  where languagetype='en' and labelbol='Savefailed' and Labeltype='jspop');
delimiter;

UPDATE ld_desk SET Fieldlabel='公海参数设置' WHERE labelbol='LBL_ACCOUNT_SET' AND languagetype='zh' AND Labeltype='fixedstr';

UPDATE ld_desk SET Fieldlabel='The high seas parameters' WHERE labelbol='LBL_ACCOUNT_SET' AND languagetype='en' AND Labeltype='fixedstr';
delimiter;

DELETE FROM ld_desk WHERE labelbol='THEINITIALQUERYCANNOTBEEMPTY' AND labeltype='fixedstr';
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'zh','THEINITIALQUERYCANNOTBEEMPTY','查询期初不能为空!','jspop' 
from dual where not EXISTS(select 1 from ld_desk where languagetype='zh' and labelbol='THEINITIALQUERYCANNOTBEEMPTY' and Labeltype='jspop');

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'en','THEINITIALQUERYCANNOTBEEMPTY','Opening a query cannot be empty!','jspop' 
from dual where not EXISTS(select 1 from ld_desk  where languagetype='en' and labelbol='THEINITIALQUERYCANNOTBEEMPTY' and Labeltype='jspop');
delimiter;

UPDATE ld_desk SET Fieldlabel='条记录进行审核吗？' WHERE labelbol='Recordscheckoutits' AND languagetype='zh' AND Labeltype='jspop';
delimiter;

SELECT tabid INTO @tabid FROM ld_tab WHERE NAME = 'Products';
UPDATE ld_field SET typeofdata = 'NN~O~25,8' WHERE tabid = @tabid AND columnname = 'qtyearly' AND typeofdata = 'NN~O~8,2';

alter table ld_products alter   discontinued  set  default 1;

UPDATE ld_desk set Fieldlabel='{$Accounts.leadsource}分布统计' where labelbol='CUSTOMERSOURCEDISSTATIST' and Labeltype='fixedstr' and languagetype='zh';
UPDATE ld_desk set Fieldlabel='{$Accounts.leadsource} distribution statistics' where labelbol='CUSTOMERSOURCEDISSTATIST' and Labeltype='fixedstr' and languagetype='en';

UPDATE ld_desk set Fieldlabel='{$Accounts.accounttype}分布统计' where labelbol='CUSTOMERTYPEDISSTATIS' and Labeltype='fixedstr' and languagetype='zh';
UPDATE ld_desk set Fieldlabel='{$Accounts.accounttype} distribution statistics' where labelbol='CUSTOMERTYPEDISSTATIS' and Labeltype='fixedstr' and languagetype='en';

UPDATE ld_desk set Fieldlabel='{$Accounts.rating}分布统计' where labelbol='CUSTOMERSTATE' and Labeltype='fixedstr' and languagetype='zh';
UPDATE ld_desk set Fieldlabel='{$Accounts.rating} distribution statistics' where labelbol='CUSTOMERSTATE' and Labeltype='fixedstr' and languagetype='en';

UPDATE ld_desk set Fieldlabel='{$Accounts.accounttype}{$Accounts.rating}分布统计' where labelbol='CUSTOMERTYPESTATE' and Labeltype='fixedstr' and languagetype='zh';
UPDATE ld_desk set Fieldlabel='{$Accounts.accounttype}{$Accounts.rating} distribution statistics' where labelbol='CUSTOMERTYPESTATE' and Labeltype='fixedstr' and languagetype='en';

UPDATE ld_desk set Fieldlabel='{$Accounts.industry}分布统计' where labelbol='CUSTOMERINDUSTRY' and Labeltype='fixedstr' and languagetype='zh';
UPDATE ld_desk set Fieldlabel='{$Accounts.industry} distribution statistics' where labelbol='CUSTOMERINDUSTRY' and Labeltype='fixedstr' and languagetype='en';

UPDATE ld_desk set Fieldlabel='{$Accounts.accountsize}分布统计' where labelbol='CUSTOMERSIZESTAFF' and Labeltype='fixedstr' and languagetype='zh';
UPDATE ld_desk set Fieldlabel='{$Accounts.accountsize} distribution statistics' where labelbol='CUSTOMERSIZESTAFF' and Labeltype='fixedstr' and languagetype='en';

UPDATE ld_desk set Fieldlabel='{$Accounts.accountproperty}分布统计' where labelbol='CUSTOMERNATURE' and Labeltype='fixedstr' and languagetype='zh';
UPDATE ld_desk set Fieldlabel='{$Accounts.accountproperty} distribution statistics' where labelbol='CUSTOMERNATURE' and Labeltype='fixedstr' and languagetype='en';

UPDATE ld_desk set Fieldlabel='{$Accounts.important_level}分布统计' where labelbol='CUSTOMERIMPORTANT' and Labeltype='fixedstr' and languagetype='zh';
UPDATE ld_desk set Fieldlabel='{$Accounts.important_level} distribution statistics' where labelbol='CUSTOMERIMPORTANT' and Labeltype='fixedstr' and languagetype='en';

UPDATE ld_desk set Fieldlabel='{$Accounts.accountrelationship}分布统计' where labelbol='CUSTOMERRELATEION' and Labeltype='fixedstr' and languagetype='zh';
UPDATE ld_desk set Fieldlabel='{$Accounts.accountrelationship} distribution statistics' where labelbol='CUSTOMERRELATEION' and Labeltype='fixedstr' and languagetype='en';

UPDATE ld_desk set Fieldlabel='{$Accounts.registeredcapital}分布统计' where labelbol='CUSTOMERREGISTERRMB' and Labeltype='fixedstr' and languagetype='zh';
UPDATE ld_desk set Fieldlabel='{$Accounts.registeredcapital} distribution statistics' where labelbol='CUSTOMERREGISTERRMB' and Labeltype='fixedstr' and languagetype='en';

UPDATE ld_desk set Fieldlabel='{$Accounts.annualincome}分布统计' where labelbol='CUSTOMERTURNOVER' and Labeltype='fixedstr' and languagetype='zh';
UPDATE ld_desk set Fieldlabel='{$Accounts.annualincome} distribution statistics' where labelbol='CUSTOMERTURNOVER' and Labeltype='fixedstr' and languagetype='en';

UPDATE ld_desk set Fieldlabel='{$Accounts.hotaccount}分布统计' where labelbol='HOTCUSTOMER' and Labeltype='fixedstr' and languagetype='zh';
UPDATE ld_desk set Fieldlabel='{$Accounts.hotaccount} distribution statistics' where labelbol='HOTCUSTOMER' and Labeltype='fixedstr' and languagetype='en';

UPDATE ld_desk set Fieldlabel='{$Accounts.hotdegree}分布统计' where labelbol='HEATDISTRIBUTION' and Labeltype='fixedstr' and languagetype='zh';
UPDATE ld_desk set Fieldlabel='{$Accounts.hotdegree} distribution statistics' where labelbol='HEATDISTRIBUTION' and Labeltype='fixedstr' and languagetype='en';

UPDATE ld_desk set Fieldlabel='{$Accounts.accounttype}{$Accounts.hotdegree}分布统计' where labelbol='CLASSIFICATIONHEAT' and Labeltype='fixedstr' and languagetype='zh';
UPDATE ld_desk set Fieldlabel='{$Accounts.accounttype}{$Accounts.hotdegree} distribution statistics' where labelbol='CLASSIFICATIONHEAT' and Labeltype='fixedstr' and languagetype='en';

UPDATE ld_desk set Fieldlabel='{$Accounts.assigned_user_id}分布统计' where labelbol='CUSTOMERCHARGE' and Labeltype='fixedstr' and languagetype='zh';
UPDATE ld_desk set Fieldlabel='{$Accounts.assigned_user_id} distribution statistics' where labelbol='CUSTOMERCHARGE' and Labeltype='fixedstr' and languagetype='en';

UPDATE ld_desk set Fieldlabel='{$Potentials.opportunity_type}分布统计' where labelbol='BUSINESSTYPE' and Labeltype='fixedstr' and languagetype='zh';
UPDATE ld_desk set Fieldlabel='{$Potentials.opportunity_type} distribution statistics' where labelbol='BUSINESSTYPE' and Labeltype='fixedstr' and languagetype='en';

UPDATE ld_desk set Fieldlabel='{$Potentials.leadsource}分布统计' where labelbol='BUSINESSSOURCE' and Labeltype='fixedstr' and languagetype='zh';
UPDATE ld_desk set Fieldlabel='{$Potentials.leadsource} distribution statistics' where labelbol='BUSINESSSOURCE' and Labeltype='fixedstr' and languagetype='en';

UPDATE ld_desk set Fieldlabel='{$Potentials.possibility}分布统计' where labelbol='LIKELIHOODPERCENT' and Labeltype='fixedstr' and languagetype='zh';
UPDATE ld_desk set Fieldlabel='{$Potentials.possibility} distribution statistics' where labelbol='LIKELIHOODPERCENT' and Labeltype='fixedstr' and languagetype='en';

UPDATE ld_desk set Fieldlabel='{$Potentials.sales_stage}分布统计' where labelbol='SALESSTATE' and Labeltype='fixedstr' and languagetype='zh';
UPDATE ld_desk set Fieldlabel='{$Potentials.sales_stage} distribution statistics' where labelbol='SALESSTATE' and Labeltype='fixedstr' and languagetype='en';

UPDATE ld_desk set Fieldlabel='{$Potentials.assigned_user_id}分布统计' where labelbol='CHARGEDISTRIBUTION' and Labeltype='fixedstr' and languagetype='zh';
UPDATE ld_desk set Fieldlabel='{$Potentials.assigned_user_id} distribution statistics' where labelbol='CHARGEDISTRIBUTION' and Labeltype='fixedstr' and languagetype='en';

UPDATE ld_desk set Fieldlabel='{$Potentials.createdtime}分布统计' where labelbol='OPPORTUNITYCREATETIME' and Labeltype='fixedstr' and languagetype='zh';
UPDATE ld_desk set Fieldlabel='{$Potentials.createdtime} distribution statistics' where labelbol='OPPORTUNITYCREATETIME' and Labeltype='fixedstr' and languagetype='en';

UPDATE ld_desk set Fieldlabel='{$Potentials.closingdate}分布统计' where labelbol='OPPORTUNITYEXPECTEDBILL' and Labeltype='fixedstr' and languagetype='zh';
UPDATE ld_desk set Fieldlabel='{$Potentials.closingdate} distribution statistics' where labelbol='OPPORTUNITYEXPECTEDBILL' and Labeltype='fixedstr' and languagetype='en';

UPDATE ld_desk set Fieldlabel='{$Potentials.assigned_user_id}{$Potentials.createdtime}分布统计' where labelbol='REPONSIBLEPERSONOPPORTUNITY' and Labeltype='fixedstr' and languagetype='zh';
UPDATE ld_desk set Fieldlabel='{$Potentials.assigned_user_id}{$Potentials.createdtime} distribution statistics' where labelbol='REPONSIBLEPERSONOPPORTUNITY' and Labeltype='fixedstr' and languagetype='en';

UPDATE ld_desk set Fieldlabel='{$ContactRecords.contactrecordtype}分布统计' where labelbol='CONTACTRECORDSTYPE' and Labeltype='fixedstr' and languagetype='zh';
UPDATE ld_desk set Fieldlabel='{$ContactRecords.contactrecordtype} distribution statistics' where labelbol='CONTACTRECORDSTYPE' and Labeltype='fixedstr' and languagetype='en';

UPDATE ld_desk set Fieldlabel='{$Campaigns.campaignstatus}分布统计' where labelbol='MARKETSTATE' and Labeltype='fixedstr' and languagetype='zh';
UPDATE ld_desk set Fieldlabel='{$Campaigns.campaignstatus} distribution statistics' where labelbol='MARKETSTATE' and Labeltype='fixedstr' and languagetype='en';

UPDATE ld_desk set Fieldlabel='{$Campaigns.campaigntype}分布统计' where labelbol='MARKETTYPE' and Labeltype='fixedstr' and languagetype='zh';
UPDATE ld_desk set Fieldlabel='{$Campaigns.campaigntype} distribution statistics' where labelbol='MARKETTYPE' and Labeltype='fixedstr' and languagetype='en';

UPDATE ld_desk set Fieldlabel='{$Campaigns.expectedresponse}分布统计' where labelbol='EXPECTEDRESPONSE' and Labeltype='fixedstr' and languagetype='zh';
UPDATE ld_desk set Fieldlabel='{$Campaigns.expectedresponse} distribution statistics' where labelbol='EXPECTEDRESPONSE' and Labeltype='fixedstr' and languagetype='en';

UPDATE ld_desk set Fieldlabel='{$Campaigns.assigned_user_id}分布统计' where labelbol='MARKETCHARTDIS' and Labeltype='fixedstr' and languagetype='zh';
UPDATE ld_desk set Fieldlabel='{$Campaigns.assigned_user_id} distribution statistics' where labelbol='MARKETCHARTDIS' and Labeltype='fixedstr' and languagetype='en';

UPDATE ld_desk set Fieldlabel='{$Calendar.activitytype}分布统计' where labelbol='CALENDARTYPE' and Labeltype='fixedstr' and languagetype='zh';
UPDATE ld_desk set Fieldlabel='{$Calendar.activitytype} distribution statistics' where labelbol='CALENDARTYPE' and Labeltype='fixedstr' and languagetype='en';

UPDATE ld_desk set Fieldlabel='{$Calendar.eventstatus}分布统计' where labelbol='CALENDARSTATUS' and Labeltype='fixedstr' and languagetype='zh';
UPDATE ld_desk set Fieldlabel='{$Calendar.eventstatus} distribution statistics' where labelbol='CALENDARSTATUS' and Labeltype='fixedstr' and languagetype='en';

UPDATE ld_desk set Fieldlabel='{$Calendar.assigned_user_id}分布统计' where labelbol='CALENDARCHARGE' and Labeltype='fixedstr' and languagetype='zh';
UPDATE ld_desk set Fieldlabel='{$Calendar.assigned_user_id} distribution statistics' where labelbol='CALENDARCHARGE' and Labeltype='fixedstr' and languagetype='en';


update ld_field set defaultvalue=1 where tabid=8 and columnname='folderid';

update ld_desk set Fieldlabel='定制单据打印和DOC导出模板' where labelbol='LBL_PRINT_TEMPLATE_DESCRIPTION' and languagetype='zh' and Labeltype = 'fixedstr';
update ld_desk set Fieldlabel='Custom printed documents and DOC export templates' where labelbol='LBL_PRINT_TEMPLATE_DESCRIPTION' and languagetype='en' and Labeltype = 'fixedstr';
delimiter;
update ld_desk set Fieldlabel='定制主菜单及其子模块显示次序' where labelbol='LBL_TABLIST_DESCRIPTION' and languagetype='zh' and Labeltype = 'fixedstr';
update ld_desk set Fieldlabel='Name customize the main menu and the display order' where labelbol='LBL_TABLIST_DESCRIPTION' and languagetype='en' and Labeltype = 'fixedstr';
delimiter;
delete  from ld_desk where labelbol = 'CUSTOMPARENTMENU' and labeltype = 'fixedstr';
delimiter;
update ld_desk set Fieldlabel='帮助' where labelbol='ONLINEHELP' and languagetype='zh' and Labeltype = 'fixedstr';
update ld_desk set Fieldlabel='Help' where labelbol='ONLINEHELP' and languagetype='en' and Labeltype = 'fixedstr';
delimiter;

select max(tabid)+1 into @tabid from ld_tab;
select id into @id from ld_version;
insert into ld_tab(tabid,name,presence,tabsequence,tablabel,isentitytype,parent,printtab)
select @tabid,'ServiceCharge',0,6,'ServiceCharge',1,'Parent Accounts',0 
from dual where not EXISTS(select 1 from ld_tab  where tablabel ='ServiceCharge');
delimiter;

select parenttabid into @parenttabid from ld_parenttab where parenttab_label = 'Parent Accounts';
select max(sequence) into @sequence from ld_parenttabrel where parenttabid = @parenttabid;
select tabid into @tabid from ld_tab where `name` = 'ServiceCharge';
insert into ld_parenttabrel(parenttabid,tabid,sequence)
select @parenttabid,@tabid,@sequence+1 
from dual where not EXISTS(select 1 from ld_parenttabrel  where parenttabid = @parenttabid and tabid =@tabid);
delimiter;

select tabid into @tabid from ld_tab where `name` = 'ServiceCharge';
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'zh','LD_tab',@tabid,@tabid,'服务收费' 
from dual where not EXISTS(select 1 from ld_tranlabel  where languagetype = 'zh' 
and trantable ='LD_tab' and tabid = @tabid and relateid=@tabid);
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'en','LD_tab',@tabid,@tabid,'Service Charge' 
from dual where not EXISTS(select 1 from ld_tranlabel  where languagetype = 'en' 
and trantable ='LD_tab' and tabid = @tabid and relateid=@tabid);

insert into ld_ws_entity(name,handler_path,handler_class,ismodule)
select 'ServiceCharge','include/Webservices/VtigerModuleOperation.php','VtigerModuleOperation',1 
from dual where not EXISTS(select 1 from ld_ws_entity  where name = 'ServiceCharge' );
delimiter;


select tabid into @tabid from ld_tab where `name` = 'ServiceCharge';
update ld_profile2standardpermissions set permissions = 1 where tabid = @tabid and profileid not in (
select ld_role2profile.profileid from ld_users 
inner join ld_user2role on ld_users.id = ld_user2role.userid
inner join ld_role2profile on ld_role2profile.roleid = ld_user2role.roleid  where is_admin = 'on');


select tabid into @tabid from ld_tab where `name` = 'ServiceCharge';
insert into LD_org_share_action2tab(share_action_id,tabid) select 0,@tabid from dual 
where not exists(select 1 from LD_org_share_action2tab where share_action_id=0 and tabid=@tabid);

insert into LD_org_share_action2tab(share_action_id,tabid) select 1,@tabid from dual 
where not exists(select 1 from LD_org_share_action2tab where share_action_id=1 and tabid=@tabid);

insert into LD_org_share_action2tab(share_action_id,tabid) select 2,@tabid from dual 
where not exists(select 1 from LD_org_share_action2tab where share_action_id=2 and tabid=@tabid);

insert into LD_org_share_action2tab(share_action_id,tabid) select 3,@tabid from dual 
where not exists(select 1 from LD_org_share_action2tab where share_action_id=3 and tabid=@tabid);
select max(ruleid) into @ruleid from LD_def_org_share;
update LD_def_org_share_seq set id=@ruleid+1 where  not exists(select 1 from LD_Def_org_share where tabid=@tabid);
insert into LD_def_org_share(ruleid,tabid,permission,editstatus)
select @ruleid+1,@tabid,3,0  from dual where  not exists(select 1 from LD_Def_org_share where tabid=@tabid);


call AddColumn('LD_field','issmownerid','int','2',0);
update ld_field set issmownerid = 1 where fieldname = 'assigned_user_id' and tabid != (select tabid from ld_tab where name = 'ServiceCharge');
delimiter;


DROP PROCEDURE IF EXISTS CopyModuleField;
delimiter ||
CREATE PROCEDURE CopyModuleField(
	IN copymodule VARCHAR(100),
	IN tomodule VARCHAR(100)
)
BEGIN
	#Routine body goes here...
declare done  int  default 0;
declare is_columnname  varchar (30);
declare is_tablename varchar (50) ;
declare is_generatedtype int ;
declare is_uitype varchar (19);
declare is_fieldname varchar (50);
declare is_fieldlabel varchar (50) ;
declare is_readonly int;
declare is_presence int ;
declare is_defaultvalue text ;
declare is_maximumlength int;
declare is_sequence int;
declare is_block int;
declare is_displaytype int;
declare is_typeofdata varchar(100);
declare is_quickcreate int;
declare is_quickcreatesequence int;
declare is_info_type varchar (20);
declare is_masseditable int;
declare is_fieldonly int;
declare is_issmownerid int;
declare cur1 CURSOR FOR SELECT  columnname,tablename,generatedtype,uitype,fieldname,fieldlabel,readonly,presence,defaultvalue,maximumlength,sequence,block,
displaytype,typeofdata,quickcreate,quickcreatesequence,info_type,masseditable,fieldonly,issmownerid from ld_field where tabid = (select tabid from ld_tab where name = copymodule) and presence in (0,2);
declare continue handler  for not   found  SET done =1;

select tabid into @tabid from ld_tab where `name` = tomodule;
select tabid into @accountid from ld_tab where `name` = copymodule;
select max(fieldid) into @fieldid from ld_field;

OPEN cur1;
Fetch cur1 into is_columnname,is_tablename,is_generatedtype,is_uitype,is_fieldname,is_fieldlabel,is_readonly,is_presence,is_defaultvalue,is_maximumlength,is_sequence,is_block,
is_displaytype,is_typeofdata,is_quickcreate,is_quickcreatesequence,is_info_type,is_masseditable,is_fieldonly,is_issmownerid;
 loop1: while  done<>1 DO
	set @fieldid = @fieldid +1;
	-- 插入LD_field
	select blockid into @newblockid from ld_blocks where blocklabel = (select blocklabel from ld_blocks where blockid = is_block) and tabid = @tabid;
	insert into ld_field(tabid,fieldid,columnname,tablename,generatedtype,uitype,fieldname,fieldlabel,readonly,presence,defaultvalue,maximumlength,sequence,block,
	displaytype,typeofdata,quickcreate,quickcreatesequence,info_type,masseditable,fieldonly,issmownerid)
	select @tabid,@fieldid,is_columnname,is_tablename,is_generatedtype,is_uitype,is_fieldname,is_fieldlabel,is_readonly,is_presence,is_defaultvalue,is_maximumlength,is_sequence,@newblockid,
	is_displaytype,is_typeofdata,is_quickcreate,is_quickcreatesequence,is_info_type,is_masseditable,is_fieldonly,is_issmownerid from dual  where not exists(select 1 from LD_field where tabid=@tabid and columnname = is_columnname);
	-- 获取field
	select fieldid into @isfieldid from ld_field where tabid = @accountid and columnname = is_columnname;
	
	-- 中文插入
	select ld_tranlabel.fieldlabel into @fieldlabel from LD_tranlabel where tabid = @accountid and Relateid = @isfieldid and trantable = 'LD_field' and languagetype = 'zh';
	insert into ld_tranlabel(languagetype,trantable,tabid,Relateid,fieldlabel)
	select 'zh','LD_field',@tabid,@fieldid,@fieldlabel from dual where not exists(select 1 from ld_tranlabel where tabid = @tabid and fieldlabel = @fieldlabel and languagetype = 'zh');

	-- 英文插入
	select ld_tranlabel.fieldlabel into @fieldlabel from LD_tranlabel where tabid = @accountid and Relateid = @isfieldid and LD_tranlabel.trantable = 'LD_field' and languagetype = 'en';
	insert into ld_tranlabel(languagetype,trantable,tabid,Relateid,fieldlabel)
	select 'en','LD_field',@tabid,@fieldid,@fieldlabel from dual where not exists(select 1 from ld_tranlabel where tabid = @tabid and fieldlabel = @fieldlabel and languagetype = 'en');
 
Fetch cur1 into is_columnname,is_tablename,is_generatedtype,is_uitype,is_fieldname,is_fieldlabel,is_readonly,is_presence,is_defaultvalue,is_maximumlength,is_sequence,is_block,
is_displaytype,is_typeofdata,is_quickcreate,is_quickcreatesequence,is_info_type,is_masseditable,is_fieldonly,is_issmownerid;
end while loop1;
close cur1;

update ld_field_seq set id = (select max(fieldid) from ld_field);

END ||
delimiter;

DROP PROCEDURE IF EXISTS CopyModuleBlocks;
delimiter ||
CREATE PROCEDURE CopyModuleBlocks(
	IN copymodule VARCHAR(100),
	IN tomodule VARCHAR(100)
)
BEGIN
	#Routine body goes here...
declare done  int  default 0;
DECLARE bl_blocklabel varchar (100);
DECLARE bl_sequence int;
DECLARE bl_visible int; 
DECLARE bl_create_view int;
DECLARE bl_edit_view int;
DECLARE bl_detail_view int;
DECLARE bl_display_status int;
DECLARE bl_iscustom int;

declare cur1 CURSOR FOR SELECT  blocklabel,sequence,visible,create_view,edit_view,detail_view,display_status,iscustom from ld_blocks where tabid = (select tabid from ld_tab where name = copymodule);
declare continue handler  for not   found  SET done =1;

select tabid into @tabid from ld_tab where `name` = tomodule;
select tabid into @accountid from ld_tab where `name` = copymodule;
select max(blockid) into @blockid from ld_blocks;

OPEN cur1;
Fetch cur1 into bl_blocklabel,bl_sequence,bl_visible,bl_create_view,bl_edit_view,bl_detail_view,bl_display_status,bl_iscustom;
 loop1: while  done<>1 DO
	set @blockid = @blockid +1;
	-- 插入LD_field
	insert into ld_blocks(blockid,tabid,blocklabel,sequence,visible,create_view,edit_view,detail_view,display_status,iscustom)
	select @blockid,@tabid,bl_blocklabel,bl_sequence,bl_visible,bl_create_view,bl_edit_view,bl_detail_view,bl_display_status,bl_iscustom 
	from dual  where not exists(select 1 from ld_blocks where tabid=@tabid and blocklabel = bl_blocklabel);

	-- 获取blockid
	select blockid into @isblockid from ld_blocks where tabid = @accountid and blocklabel = bl_blocklabel;
	
	-- 中文插入
	select ld_tranlabel.fieldlabel into @fieldlabel from LD_tranlabel where tabid = @accountid and Relateid = @isblockid and trantable = 'LD_blocks' and languagetype = 'zh';
	insert into ld_tranlabel(languagetype,trantable,tabid,Relateid,fieldlabel)
	select 'zh','LD_blocks',@tabid,@blockid,@fieldlabel from dual where not exists(select 1 from ld_tranlabel where tabid = @tabid and Relateid = @blockid and languagetype = 'zh');

	-- 英文插入
	select ld_tranlabel.fieldlabel into @fieldlabel from LD_tranlabel where tabid = @accountid and Relateid = @isblockid and trantable = 'LD_blocks' and languagetype = 'en';
	insert into ld_tranlabel(languagetype,trantable,tabid,Relateid,fieldlabel)
	select 'en','LD_blocks',@tabid,@blockid,@fieldlabel from dual where not exists(select 1 from ld_tranlabel where tabid = @tabid and Relateid = @blockid and languagetype = 'en');
	
Fetch cur1 into bl_blocklabel,bl_sequence,bl_visible,bl_create_view,bl_edit_view,bl_detail_view,bl_display_status,bl_iscustom;
end while loop1;
close cur1;

update ld_blocks_seq set id = (select max(blockid) from ld_blocks);

END ||
delimiter;

call AddColumn('LD_account','servicecasher','int','19',0);
call AddColumn('LD_account','servicegroup','int','19',0);
delimiter;

insert into ld_customview(cvid,viewname,setdefault,entitytype,status,userid,pagewidthpercent)
select (select max(id)+1 from ld_customview_seq),'All',1,'ServiceCharge',0,1,100 
from dual where not EXISTS(select 1 from ld_customview  where viewname = 'All' 
and entitytype ='ServiceCharge');
update ld_customview_seq set id = (select max(cvid)+1 from ld_customview);
delimiter;

select cvid into @cvid from ld_customview where viewname='All' and entitytype='ServiceCharge';
select tabid into @tabid from ld_tab where `name`='ServiceCharge';
insert into ld_tabwithproductview(tabid,`columns`,sequence,cvid)
select @tabid,'LD_account:accountname:accountname:Accounts_fieldlabel:V',0,@cvid 
from dual where not EXISTS(select 1 from ld_tabwithproductview where tabid = @tabid and cvid = @cvid and `columns`='LD_account:accountname:accountname:Accounts_fieldlabel:V');

insert into ld_tabwithproductview(tabid,`columns`,sequence,cvid)
select @tabid,'LD_account:account_no:account_no:Accounts_fieldlabel:V',1,@cvid 
from dual where not EXISTS(select 1 from ld_tabwithproductview where tabid = @tabid and cvid = @cvid and `columns`='LD_account:account_no:account_no:Accounts_fieldlabel:V');

insert into ld_tabwithproductview(tabid,`columns`,sequence,cvid)
select @tabid,'LD_account:bill_city:bill_city:Accounts_fieldlabel:V',2,@cvid 
from dual where not EXISTS(select 1 from ld_tabwithproductview where tabid = @tabid and cvid = @cvid and `columns`='LD_account:bill_city:bill_city:Accounts_fieldlabel:V');

insert into ld_tabwithproductview(tabid,`columns`,sequence,cvid)
select @tabid,'LD_account:account_type:accounttype:Accounts_fieldlabel:V',3,@cvid 
from dual where not EXISTS(select 1 from ld_tabwithproductview where tabid = @tabid and cvid = @cvid and `columns`='LD_account:account_type:accounttype:Accounts_fieldlabel:V');

insert into ld_tabwithproductview(tabid,`columns`,sequence,cvid)
select @tabid,'LD_account:servicecasher:servicecasher:Accounts_fieldlabel:V',4,@cvid 
from dual where not EXISTS(select 1 from ld_tabwithproductview where tabid = @tabid and cvid = @cvid and `columns`='LD_account:servicecasher:servicecasher:Accounts_fieldlabel:V');

insert into ld_tabwithproductview(tabid,`columns`,sequence,cvid)
select @tabid,'LD_account:servicegroup:servicegroup:Accounts_fieldlabel:V',5,@cvid 
from dual where not EXISTS(select 1 from ld_tabwithproductview where tabid = @tabid and cvid = @cvid and `columns`='LD_account:servicegroup:servicegroup:Accounts_fieldlabel:V');

insert into ld_tabwithproductview(tabid,`columns`,sequence,cvid)
select @tabid,'LD_products:productname:productname:Products_fieldlabel:V',6,@cvid 
from dual where not EXISTS(select 1 from ld_tabwithproductview where tabid = @tabid and cvid = @cvid and `columns`='LD_products:productname:productname:Products_fieldlabel:V');

insert into ld_tabwithproductview(tabid,`columns`,sequence,cvid)
select @tabid,'LD_products:product_no:product_no:Products_fieldlabel:V',7,@cvid 
from dual where not EXISTS(select 1 from ld_tabwithproductview where tabid = @tabid and cvid = @cvid and `columns`='LD_products:product_no:product_no:Products_fieldlabel:V');

insert into ld_tabwithproductview(tabid,`columns`,sequence,cvid)
select @tabid,'LD_inventoryproductrel:servicecontracts_end_date:servicecontracts_end_date:Products_fieldlabel:D',8,@cvid 
from dual where not EXISTS(select 1 from ld_tabwithproductview where tabid = @tabid and cvid = @cvid and `columns`='LD_inventoryproductrel:servicecontracts_end_date:servicecontracts_end_date:Products_fieldlabel:D');

select tabid into @tabid from ld_tab where `name`='ServiceCharge';
select cvid into @cvid  from ld_customview where entitytype = 'ServiceCharge' and viewname ='All';

delete from ld_cvstdfilter where cvid in (select cvid from ld_customview where entitytype = 'ServiceCharge' and viewname !='All');
delete from ld_cvadvfilter where cvid in (select cvid from ld_customview where entitytype = 'ServiceCharge' and viewname !='All');
delete from ld_cvadvfilter_grouping where cvid in (select cvid from ld_customview where entitytype = 'ServiceCharge' and viewname !='All');
delete from ld_customview where entitytype = 'ServiceCharge' and viewname !='All';
delete from ld_tabwithproductview where tabid = @tabid and cvid != @cvid;

insert into ld_customview(cvid,viewname,setdefault,entitytype,status,userid,sequence,pagewidthpercent)
select (select max(cvid)+1 from ld_customview),'无服务',0,'ServiceCharge',1,1,1,100;

select cvid into @cvid from ld_customview where viewname='无服务' and entitytype='ServiceCharge';
select tabid into @tabid from ld_tab where `name`='ServiceCharge';
insert into ld_tabwithproductview(tabid,`columns`,sequence,cvid)
select @tabid,'LD_account:accountname:accountname:Accounts_fieldlabel:V',0,@cvid;

insert into ld_tabwithproductview(tabid,`columns`,sequence,cvid)
select @tabid,'LD_account:account_no:account_no:Accounts_fieldlabel:V',1,@cvid;

insert into ld_tabwithproductview(tabid,`columns`,sequence,cvid)
select @tabid,'LD_account:bill_city:bill_city:Accounts_fieldlabel:V',2,@cvid;

insert into ld_tabwithproductview(tabid,`columns`,sequence,cvid)
select @tabid,'LD_account:account_type:accounttype:Accounts_fieldlabel:V',3,@cvid;

insert into ld_tabwithproductview(tabid,`columns`,sequence,cvid)
select @tabid,'LD_account:servicecasher:servicecasher:Accounts_fieldlabel:V',4,@cvid;

insert into ld_tabwithproductview(tabid,`columns`,sequence,cvid)
select @tabid,'LD_account:servicegroup:servicegroup:Accounts_fieldlabel:V',5,@cvid;

insert into ld_tabwithproductview(tabid,`columns`,sequence,cvid)
select @tabid,'LD_products:productname:productname:Products_fieldlabel:V',6,@cvid;

insert into ld_tabwithproductview(tabid,`columns`,sequence,cvid)
select @tabid,'LD_products:product_no:product_no:Products_fieldlabel:V',7,@cvid;

insert into ld_tabwithproductview(tabid,`columns`,sequence,cvid)
select @tabid,'LD_inventoryproductrel:servicecontracts_end_date:servicecontracts_end_date:Products_fieldlabel:D',8,@cvid;

insert into ld_cvadvfilter(cvid,columnindex,columnname,comparator,groupid,column_condition)
select @cvid,0,'LD_inventoryproductrel:servicecontracts_end_date:servicecontracts_end_date:Products_fieldlabel','e',1,'';

insert into ld_cvadvfilter_grouping(groupid,cvid,group_condition,condition_expression)
select 1,@cvid,'',0;

insert into ld_customview(cvid,viewname,setdefault,entitytype,status,userid,sequence,pagewidthpercent)
select (select max(cvid)+1 from ld_customview),'已过期',0,'ServiceCharge',1,1,2,100;

select cvid into @cvid from ld_customview where viewname='已过期' and entitytype='ServiceCharge';
select tabid into @tabid from ld_tab where `name`='ServiceCharge';
insert into ld_tabwithproductview(tabid,`columns`,sequence,cvid)
select @tabid,'LD_account:accountname:accountname:Accounts_fieldlabel:V',0,@cvid;

insert into ld_tabwithproductview(tabid,`columns`,sequence,cvid)
select @tabid,'LD_account:account_no:account_no:Accounts_fieldlabel:V',1,@cvid;

insert into ld_tabwithproductview(tabid,`columns`,sequence,cvid)
select @tabid,'LD_account:bill_city:bill_city:Accounts_fieldlabel:V',2,@cvid;

insert into ld_tabwithproductview(tabid,`columns`,sequence,cvid)
select @tabid,'LD_account:account_type:accounttype:Accounts_fieldlabel:V',3,@cvid;

insert into ld_tabwithproductview(tabid,`columns`,sequence,cvid)
select @tabid,'LD_account:servicecasher:servicecasher:Accounts_fieldlabel:V',4,@cvid;

insert into ld_tabwithproductview(tabid,`columns`,sequence,cvid)
select @tabid,'LD_account:servicegroup:servicegroup:Accounts_fieldlabel:V',5,@cvid;

insert into ld_tabwithproductview(tabid,`columns`,sequence,cvid)
select @tabid,'LD_products:productname:productname:Products_fieldlabel:V',6,@cvid;

insert into ld_tabwithproductview(tabid,`columns`,sequence,cvid)
select @tabid,'LD_products:product_no:product_no:Products_fieldlabel:V',7,@cvid;

insert into ld_tabwithproductview(tabid,`columns`,sequence,cvid)
select @tabid,'LD_inventoryproductrel:servicecontracts_end_date:servicecontracts_end_date:Products_fieldlabel:D',8,@cvid;

insert into ld_cvstdfilter(cvid,columnname,stdfilter)
select @cvid,'LD_inventoryproductrel:servicecontracts_end_date:servicecontracts_end_date:Products_fieldlabel','before2days';

insert into ld_customview(cvid,viewname,setdefault,entitytype,status,userid,sequence,pagewidthpercent)
select (select max(cvid)+1 from ld_customview),'过期未超60天',0,'ServiceCharge',1,1,3,100;

select cvid into @cvid from ld_customview where viewname='过期未超60天' and entitytype='ServiceCharge';
select tabid into @tabid from ld_tab where `name`='ServiceCharge';
insert into ld_tabwithproductview(tabid,`columns`,sequence,cvid)
select @tabid,'LD_account:accountname:accountname:Accounts_fieldlabel:V',0,@cvid;

insert into ld_tabwithproductview(tabid,`columns`,sequence,cvid)
select @tabid,'LD_account:account_no:account_no:Accounts_fieldlabel:V',1,@cvid;

insert into ld_tabwithproductview(tabid,`columns`,sequence,cvid)
select @tabid,'LD_account:bill_city:bill_city:Accounts_fieldlabel:V',2,@cvid;

insert into ld_tabwithproductview(tabid,`columns`,sequence,cvid)
select @tabid,'LD_account:account_type:accounttype:Accounts_fieldlabel:V',3,@cvid;

insert into ld_tabwithproductview(tabid,`columns`,sequence,cvid)
select @tabid,'LD_account:servicecasher:servicecasher:Accounts_fieldlabel:V',4,@cvid;

insert into ld_tabwithproductview(tabid,`columns`,sequence,cvid)
select @tabid,'LD_account:servicegroup:servicegroup:Accounts_fieldlabel:V',5,@cvid;

insert into ld_tabwithproductview(tabid,`columns`,sequence,cvid)
select @tabid,'LD_products:productname:productname:Products_fieldlabel:V',6,@cvid;

insert into ld_tabwithproductview(tabid,`columns`,sequence,cvid)
select @tabid,'LD_products:product_no:product_no:Products_fieldlabel:V',7,@cvid;

insert into ld_tabwithproductview(tabid,`columns`,sequence,cvid)
select @tabid,'LD_inventoryproductrel:servicecontracts_end_date:servicecontracts_end_date:Products_fieldlabel:D',8,@cvid;

insert into ld_cvstdfilter(cvid,columnname,stdfilter)
select @cvid,'LD_inventoryproductrel:servicecontracts_end_date:servicecontracts_end_date:Products_fieldlabel','last60days';

insert into ld_customview(cvid,viewname,setdefault,entitytype,status,userid,sequence,pagewidthpercent)
select (select max(cvid)+1 from ld_customview),'过期未超30天',0,'ServiceCharge',1,1,4,100;

select cvid into @cvid from ld_customview where viewname='过期未超30天' and entitytype='ServiceCharge';
select tabid into @tabid from ld_tab where `name`='ServiceCharge';
insert into ld_tabwithproductview(tabid,`columns`,sequence,cvid)
select @tabid,'LD_account:accountname:accountname:Accounts_fieldlabel:V',0,@cvid;

insert into ld_tabwithproductview(tabid,`columns`,sequence,cvid)
select @tabid,'LD_account:account_no:account_no:Accounts_fieldlabel:V',1,@cvid;

insert into ld_tabwithproductview(tabid,`columns`,sequence,cvid)
select @tabid,'LD_account:bill_city:bill_city:Accounts_fieldlabel:V',2,@cvid;

insert into ld_tabwithproductview(tabid,`columns`,sequence,cvid)
select @tabid,'LD_account:account_type:accounttype:Accounts_fieldlabel:V',3,@cvid;

insert into ld_tabwithproductview(tabid,`columns`,sequence,cvid)
select @tabid,'LD_account:servicecasher:servicecasher:Accounts_fieldlabel:V',4,@cvid;

insert into ld_tabwithproductview(tabid,`columns`,sequence,cvid)
select @tabid,'LD_account:servicegroup:servicegroup:Accounts_fieldlabel:V',5,@cvid;

insert into ld_tabwithproductview(tabid,`columns`,sequence,cvid)
select @tabid,'LD_products:productname:productname:Products_fieldlabel:V',6,@cvid;

insert into ld_tabwithproductview(tabid,`columns`,sequence,cvid)
select @tabid,'LD_products:product_no:product_no:Products_fieldlabel:V',7,@cvid;

insert into ld_tabwithproductview(tabid,`columns`,sequence,cvid)
select @tabid,'LD_inventoryproductrel:servicecontracts_end_date:servicecontracts_end_date:Products_fieldlabel:D',8,@cvid;

insert into ld_cvstdfilter(cvid,columnname,stdfilter)
select @cvid,'LD_inventoryproductrel:servicecontracts_end_date:servicecontracts_end_date:Products_fieldlabel','last30days';

insert into ld_customview(cvid,viewname,setdefault,entitytype,status,userid,sequence,pagewidthpercent)
select (select max(cvid)+1 from ld_customview),'即将到期60天',0,'ServiceCharge',1,1,5,100;

select cvid into @cvid from ld_customview where viewname='即将到期60天' and entitytype='ServiceCharge';
select tabid into @tabid from ld_tab where `name`='ServiceCharge';
insert into ld_tabwithproductview(tabid,`columns`,sequence,cvid)
select @tabid,'LD_account:accountname:accountname:Accounts_fieldlabel:V',0,@cvid;

insert into ld_tabwithproductview(tabid,`columns`,sequence,cvid)
select @tabid,'LD_account:account_no:account_no:Accounts_fieldlabel:V',1,@cvid;

insert into ld_tabwithproductview(tabid,`columns`,sequence,cvid)
select @tabid,'LD_account:bill_city:bill_city:Accounts_fieldlabel:V',2,@cvid;

insert into ld_tabwithproductview(tabid,`columns`,sequence,cvid)
select @tabid,'LD_account:account_type:accounttype:Accounts_fieldlabel:V',3,@cvid;

insert into ld_tabwithproductview(tabid,`columns`,sequence,cvid)
select @tabid,'LD_account:servicecasher:servicecasher:Accounts_fieldlabel:V',4,@cvid;

insert into ld_tabwithproductview(tabid,`columns`,sequence,cvid)
select @tabid,'LD_account:servicegroup:servicegroup:Accounts_fieldlabel:V',5,@cvid;

insert into ld_tabwithproductview(tabid,`columns`,sequence,cvid)
select @tabid,'LD_products:productname:productname:Products_fieldlabel:V',6,@cvid;

insert into ld_tabwithproductview(tabid,`columns`,sequence,cvid)
select @tabid,'LD_products:product_no:product_no:Products_fieldlabel:V',7,@cvid;

insert into ld_tabwithproductview(tabid,`columns`,sequence,cvid)
select @tabid,'LD_inventoryproductrel:servicecontracts_end_date:servicecontracts_end_date:Products_fieldlabel:D',8,@cvid;

insert into ld_cvstdfilter(cvid,columnname,stdfilter)
select @cvid,'LD_inventoryproductrel:servicecontracts_end_date:servicecontracts_end_date:Products_fieldlabel','next60days';

insert into ld_customview(cvid,viewname,setdefault,entitytype,status,userid,sequence,pagewidthpercent)
select (select max(cvid)+1 from ld_customview),'即将到期30天',0,'ServiceCharge',1,1,6,100;

select cvid into @cvid from ld_customview where viewname='即将到期30天' and entitytype='ServiceCharge';
select tabid into @tabid from ld_tab where `name`='ServiceCharge';
insert into ld_tabwithproductview(tabid,`columns`,sequence,cvid)
select @tabid,'LD_account:accountname:accountname:Accounts_fieldlabel:V',0,@cvid;

insert into ld_tabwithproductview(tabid,`columns`,sequence,cvid)
select @tabid,'LD_account:account_no:account_no:Accounts_fieldlabel:V',1,@cvid;

insert into ld_tabwithproductview(tabid,`columns`,sequence,cvid)
select @tabid,'LD_account:bill_city:bill_city:Accounts_fieldlabel:V',2,@cvid;

insert into ld_tabwithproductview(tabid,`columns`,sequence,cvid)
select @tabid,'LD_account:account_type:accounttype:Accounts_fieldlabel:V',3,@cvid;

insert into ld_tabwithproductview(tabid,`columns`,sequence,cvid)
select @tabid,'LD_account:servicecasher:servicecasher:Accounts_fieldlabel:V',4,@cvid;

insert into ld_tabwithproductview(tabid,`columns`,sequence,cvid)
select @tabid,'LD_account:servicegroup:servicegroup:Accounts_fieldlabel:V',5,@cvid;

insert into ld_tabwithproductview(tabid,`columns`,sequence,cvid)
select @tabid,'LD_products:productname:productname:Products_fieldlabel:V',6,@cvid;

insert into ld_tabwithproductview(tabid,`columns`,sequence,cvid)
select @tabid,'LD_products:product_no:product_no:Products_fieldlabel:V',7,@cvid;

insert into ld_tabwithproductview(tabid,`columns`,sequence,cvid)
select @tabid,'LD_inventoryproductrel:servicecontracts_end_date:servicecontracts_end_date:Products_fieldlabel:D',8,@cvid;

insert into ld_cvstdfilter(cvid,columnname,stdfilter)
select @cvid,'LD_inventoryproductrel:servicecontracts_end_date:servicecontracts_end_date:Products_fieldlabel','next30days';

update ld_customview_seq set id = (select max(cvid)+1 from ld_customview);
delimiter;

select tabid into @tabid from ld_tab where `name`= 'ServiceCharge';
update ld_field set issmownerid = 1 where fieldname = 'servicecasher' and tabid = @tabid;
update ld_field set issmownerid = 0 where fieldname = 'assigned_user_id' and tabid = @tabid;
delimiter;

select tabid into @tabid from ld_tab where `name` = 'ServiceCharge';
select fieldid into @fieldid from ld_field where tabid = @tabid and columnname = 'servicecasher' and fieldname = 'assigned_user_id';
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'zh','LD_field',@tabid,@fieldid,'服务收费人' 
from dual where not EXISTS(select 1 from ld_tranlabel  where languagetype = 'zh' 
and trantable ='LD_field' and tabid = @tabid and relateid=@fieldid);

insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'en','LD_field',@tabid,@fieldid,'ServiceCasher' 
from dual where not EXISTS(select 1 from ld_tranlabel  where languagetype = 'en' 
and trantable ='LD_field' and tabid = @tabid and relateid=@fieldid);


select tabid into @tabid from ld_tab where `name` = 'Accounts';
insert into ld_field(tabid,fieldid,columnname,tablename,uitype,fieldname,fieldlabel,block,displaytype,presence,typeofdata,issmownerid)
select @tabid,(select max(fieldid) from ld_field)+1,'servicecasher','LD_account',52,'servicecasher','服务收费人',(select blockid from ld_blocks where blocklabel = 'LBL_ACCOUNT_INFORMATION'),2,0,'V~O',0 from dual where not exists 
(select * from ld_field where tabid = @tabid and columnname = 'servicecasher');

insert into ld_field(tabid,fieldid,columnname,tablename,uitype,fieldname,fieldlabel,block,displaytype,presence,typeofdata)
select @tabid,(select max(fieldid) from ld_field)+1,'servicegroup','LD_account',170,'servicegroup','分组ID',(select blockid from ld_blocks where blocklabel = 'LBL_ACCOUNT_INFORMATION'),2,0,'V~O' from dual where not exists 
(select * from ld_field where tabid = @tabid and columnname = 'servicegroup');
update ld_field_seq set id = (select max(fieldid)+1 from ld_field);

select tabid into @tabid from ld_tab where `name` = 'Accounts';
select fieldid into @fieldid from ld_field where tabid = @tabid and columnname = 'servicecasher';
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'zh','LD_field',@tabid,@fieldid,'服务收费人' 
from dual where not EXISTS(select 1 from ld_tranlabel  where languagetype = 'zh' 
and trantable ='LD_field' and tabid = @tabid and relateid=@fieldid);
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'en','LD_field',@tabid,@fieldid,'Service Casher' 
from dual where not EXISTS(select 1 from ld_tranlabel  where languagetype = 'en' 
and trantable ='LD_field' and tabid = @tabid and relateid=@fieldid);

select fieldid into @fieldid from ld_field where tabid = @tabid and columnname = 'servicegroup';
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'zh','LD_field',@tabid,@fieldid,'分组' 
from dual where not EXISTS(select 1 from ld_tranlabel  where languagetype = 'zh' 
and trantable ='LD_field' and tabid = @tabid and relateid=@fieldid);
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'en','LD_field',@tabid,@fieldid,'Group' 
from dual where not EXISTS(select 1 from ld_tranlabel  where languagetype = 'en' 
and trantable ='LD_field' and tabid = @tabid and relateid=@fieldid);

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','Group_name','分组中文名称','jspop' 
from dual where not EXISTS(select 1 from ld_desk  where languagetype = 'zh' 
and labeltype ='jspop' and labelbol = 'Group_name');

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','Group_name','Group Chinaese Name','jspop' 
from dual where not EXISTS(select 1 from ld_desk  where languagetype = 'en' 
and labeltype ='jspop' and labelbol = 'Group_name');

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','GroupEnname','分组英文名称','jspop' 
from dual where not EXISTS(select 1 from ld_desk  where languagetype = 'zh' 
and labeltype ='jspop' and labelbol = 'GroupEnname');

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','GroupEnname','Group English Name','jspop' 
from dual where not EXISTS(select 1 from ld_desk  where languagetype = 'en' 
and labeltype ='jspop' and labelbol = 'GroupEnname');

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','Group_name','分组中文名称','fixedstr' 
from dual where not EXISTS(select 1 from ld_desk  where languagetype = 'zh' 
and labeltype ='fixedstr' and labelbol = 'Group_name');

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','Group_name','Group Chinaese Name','fixedstr' 
from dual where not EXISTS(select 1 from ld_desk  where languagetype = 'en' 
and labeltype ='fixedstr' and labelbol = 'Group_name');

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','GroupEnname','分组英文名称','fixedstr' 
from dual where not EXISTS(select 1 from ld_desk  where languagetype = 'zh' 
and labeltype ='fixedstr' and labelbol = 'GroupEnname');

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','GroupEnname','Group English Name','fixedstr' 
from dual where not EXISTS(select 1 from ld_desk  where languagetype = 'en' 
and labeltype ='fixedstr' and labelbol = 'GroupEnname');

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','GROUPLENGTH','字数不能超过20','jspop' 
from dual where not EXISTS(select 1 from ld_desk  where languagetype = 'zh' 
and labeltype ='jspop' and labelbol = 'GROUPLENGTH');

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','GROUPLENGTH','should not more than 20','jspop' 
from dual where not EXISTS(select 1 from ld_desk  where languagetype = 'en' 
and labeltype ='jspop' and labelbol = 'GROUPLENGTH');

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','before2days','2天前','fixedstr' 
from dual where not EXISTS(select 1 from ld_desk  where languagetype = 'zh' 
and labeltype ='fixedstr' and labelbol = 'before2days');

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','2 days ago','2天前','fixedstr' 
from dual where not EXISTS(select 1 from ld_desk  where languagetype = 'en' 
and labeltype ='fixedstr' and labelbol = '2 days ago');

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','Chinaese','中文','fixedstr' 
from dual where not EXISTS(select 1 from ld_desk  where languagetype = 'zh' 
and labeltype ='fixedstr' and labelbol = 'Chinaese');

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','Chinaese','Chinaese','fixedstr' 
from dual where not EXISTS(select 1 from ld_desk  where languagetype = 'en' 
and labeltype ='fixedstr' and labelbol = 'Chinaese');

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','groupEnglish','英文','fixedstr' 
from dual where not EXISTS(select 1 from ld_desk  where languagetype = 'zh' 
and labeltype ='fixedstr' and labelbol = 'groupEnglish');

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','groupEnglish','English','fixedstr' 
from dual where not EXISTS(select 1 from ld_desk  where languagetype = 'en' 
and labeltype ='fixedstr' and labelbol = 'groupEnglish');

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','REPLACEWITHTHEFOLLOWINGGROUPS','用下列分组替换','fixedstr' 
from dual where not EXISTS(select 1 from ld_desk  where languagetype = 'zh' 
and labeltype ='fixedstr' and labelbol = 'REPLACEWITHTHEFOLLOWINGGROUPS');

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','REPLACEWITHTHEFOLLOWINGGROUPS','Replace with the following groups','fixedstr' 
from dual where not EXISTS(select 1 from ld_desk  where languagetype = 'en' 
and labeltype ='fixedstr' and labelbol = 'REPLACEWITHTHEFOLLOWINGGROUPS');

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','MODIFYTHESERVICECHARGEFOR','修改服务收费人为','fixedstr' 
from dual where not EXISTS(select 1 from ld_desk  where languagetype = 'zh' 
and labeltype ='fixedstr' and labelbol = 'MODIFYTHESERVICECHARGEFOR');

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','MODIFYTHESERVICECHARGEFOR','Modify the service charge for','fixedstr' 
from dual where not EXISTS(select 1 from ld_desk  where languagetype = 'en' 
and labeltype ='fixedstr' and labelbol = 'MODIFYTHESERVICECHARGEFOR');

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','MOVEGROUP','移动分组','fixedstr' 
from dual where not EXISTS(select 1 from ld_desk  where languagetype = 'zh' 
and labeltype ='fixedstr' and labelbol = 'MOVEGROUP');

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','MOVEGROUP','Move Group','fixedstr' 
from dual where not EXISTS(select 1 from ld_desk  where languagetype = 'en' 
and labeltype ='fixedstr' and labelbol = 'MOVEGROUP');

select tabid into @tabid from ld_tab where `name` = 'ServiceContracts';
update ld_field set fieldname = 'ServiceContractsassigned_user_id' where tabid = @tabid and fieldname = 'assigned_user_id';
update ld_field set fieldname = 'ServiceContractscreatedtime' where tabid = @tabid and fieldname = 'createdtime';
update ld_field set fieldname = 'ServiceContractsmodifiedtime' where tabid = @tabid and fieldname = 'modifiedtime';
update ld_field set fieldname = 'ServiceContractsmodifiedby' where tabid = @tabid and fieldname = 'modifiedby';
update ld_field set fieldname = 'ServiceContractscreator' where tabid = @tabid and fieldname = 'creator';

select tabid into @tabid from ld_tab where `name` = 'ServiceContracts'; 
update ld_tabwithproductview set `columns` = 'LD_servicecontracts:smownerid:ServiceContractsassigned_user_id:ServiceContracts_fieldlabel:V'
where tabid = @tabid and `columns` = 'LD_servicecontracts:smownerid:assigned_user_id:ServiceContracts_fieldlabel:V';

update ld_tabwithproductview set `columns` = 'LD_servicecontracts:createdtime:ServiceContractscreatedtime:ServiceContracts_fieldlabel:V'
where tabid = @tabid and `columns` = 'LD_servicecontracts:createdtime:createdtime:ServiceContracts_fieldlabel:V';

update ld_tabwithproductview set `columns` = 'LD_servicecontracts:modifiedtime:ServiceContractsmodifiedtime:ServiceContracts_fieldlabel:V'
where tabid = @tabid and `columns` = 'LD_servicecontracts:modifiedtime:modifiedtime:ServiceContracts_fieldlabel:V';

update ld_tabwithproductview set `columns` = 'LD_servicecontracts:modifiedby:ServiceContractsmodifiedby:ServiceContracts_fieldlabel:V'
where tabid = @tabid and `columns` = 'LD_servicecontracts:modifiedby:modifiedby:ServiceContracts_fieldlabel:V';

update ld_tabwithproductview set `columns` = 'LD_servicecontracts:smcreatorid:ServiceContractscreator:ServiceContracts_fieldlabel:V'
where tabid = @tabid and `columns` = 'LD_servicecontracts:smcreatorid:creator:ServiceContracts_fieldlabel:V';


CREATE TABLE IF NOT EXISTS `ld_servicegroup` (
  `servicegroupid` int(19) NOT NULL AUTO_INCREMENT,
  `servicegroupname_zh` varchar(25) DEFAULT NULL,
  `servicegroupname_en` varchar(25) DEFAULT NULL,
  `sequence` int(19) DEFAULT NULL,
  `is_edit` tinyint(1) DEFAULT '1',
  PRIMARY KEY (`servicegroupid`)
) ENGINE=MyISAM AUTO_INCREMENT=1 DEFAULT CHARSET=utf8;
delimiter;

insert into ld_servicegroup(servicegroupname_zh,servicegroupname_en,sequence,is_edit)
select '全部','All',1,0 from dual where not EXISTS(select 1 from ld_servicegroup  where servicegroupname_zh = '全部'); 
insert into ld_servicegroup(servicegroupname_zh,servicegroupname_en,sequence,is_edit)
select '未分组','No Group',2,0 from dual where not EXISTS(select 1 from ld_servicegroup  where servicegroupname_zh = '未分组'); 
insert into ld_servicegroup(servicegroupname_zh,servicegroupname_en,sequence,is_edit)
select '已分组','Grouped',3,0 from dual where not EXISTS(select 1 from ld_servicegroup  where servicegroupname_zh = '已分组'); 
insert into ld_servicegroup(servicegroupname_zh,servicegroupname_en,sequence,is_edit)
select '已发通知函','Has ade letter',4,1 from dual where not EXISTS(select 1 from ld_servicegroup  where servicegroupname_zh = '已发通知函'); 
insert into ld_servicegroup(servicegroupname_zh,servicegroupname_en,sequence,is_edit)
select '已电话联系','Has the phone',5,1 from dual where not EXISTS(select 1 from ld_servicegroup  where servicegroupname_zh = '已电话联系');
insert into ld_servicegroup(servicegroupname_zh,servicegroupname_en,sequence,is_edit)
select '有遗留问题解决后交费','From the problem solving',6,1 from dual where not EXISTS(select 1 from ld_servicegroup  where servicegroupname_zh = '有遗留问题解决后交费');
delimiter;

call CopyModuleBlocks('Accounts','ServiceCharge');
delimiter;

select tabid into @tabid from ld_tab where `name` = 'ServiceCharge';
insert into ld_entityname(tabid,modulename,tablename,fieldname,entityidfield,entityidcolumn)
select @tabid,'ServiceCharge','LD_account','accountname','accountid','account_id' 
from dual where not EXISTS(select 1 from ld_entityname where tabid = @tabid);

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','PLEASESELECTYOUGROUPNAME','请先选择你要编辑、删除的分组名称','jspop' 
from dual where not EXISTS(select 1 from ld_desk  where languagetype = 'zh' 
and labeltype ='jspop' and labelbol = 'PLEASESELECTYOUGROUPNAME');

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','PLEASESELECTYOUGROUPNAME','Please select you want to edit, delete group name','jspop' 
from dual where not EXISTS(select 1 from ld_desk  where languagetype = 'en' 
and labeltype ='jspop' and labelbol = 'PLEASESELECTYOUGROUPNAME');
delimiter;

call CopyModuleField('Accounts','ServiceCharge');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','SORRYYOUARENOTTHEADMINISTRATOR','对不起，您不是管理员，无权操作该功能','jspop' 
from dual where not EXISTS(select 1 from ld_desk  where languagetype = 'zh' 
and labeltype ='jspop' and labelbol = 'SORRYYOUARENOTTHEADMINISTRATOR');

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','SORRYYOUARENOTTHEADMINISTRATOR','Sorry, you are not the administrator, has no right to operate this function','jspop' 
from dual where not EXISTS(select 1 from ld_desk  where languagetype = 'en' 
and labeltype ='jspop' and labelbol = 'SORRYYOUARENOTTHEADMINISTRATOR');
delimiter;

select tabid into @tabid from ld_tab where `name` = 'ServiceCharge';
select fieldid into @fieldid from ld_field where tabid = @tabid and columnname = 'servicecasher';
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'zh','LD_field',@tabid,@fieldid,'服务收费人' 
from dual where not EXISTS(select 1 from ld_tranlabel  where languagetype = 'zh' 
and trantable ='LD_field' and tabid = @tabid and relateid=@fieldid);
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'en','LD_field',@tabid,@fieldid,'Service Casher' 
from dual where not EXISTS(select 1 from ld_tranlabel  where languagetype = 'en' 
and trantable ='LD_field' and tabid = @tabid and relateid=@fieldid);
delimiter;
-- end 2014-08-26

UPDATE ld_desk set Fieldlabel='国家' where labelbol='COMPANYCOUNTRY' and languagetype='zh' and Labeltype='fixedstr';
UPDATE ld_desk set Fieldlabel='Country' where labelbol='COMPANYCOUNTRY' and languagetype='en' and Labeltype='fixedstr';
delimiter;
UPDATE ld_desk set Fieldlabel='省份' where labelbol='COMPANYPROVINCE' and languagetype='zh' and Labeltype='fixedstr';
UPDATE ld_desk set Fieldlabel='Province' where labelbol='COMPANYPROVINCE' and languagetype='en' and Labeltype='fixedstr';
delimiter;
UPDATE ld_desk set Fieldlabel='城市' where labelbol='COMPANYCITY' and languagetype='zh' and Labeltype='fixedstr';
UPDATE ld_desk set Fieldlabel='City' where labelbol='COMPANYCITY' and languagetype='en' and Labeltype='fixedstr';
delimiter;
UPDATE ld_desk set Fieldlabel='邮编' where labelbol='COMPANYZIPCODE' and languagetype='zh' and Labeltype='fixedstr';
UPDATE ld_desk set Fieldlabel='Zip Code' where labelbol='COMPANYZIPCODE' and languagetype='en' and Labeltype='fixedstr';
delimiter;
UPDATE ld_desk set Fieldlabel='地址' where labelbol='COMPANYADDRESS' and languagetype='zh' and Labeltype='fixedstr';
UPDATE ld_desk set Fieldlabel='Address' where labelbol='COMPANYADDRESS' and languagetype='en' and Labeltype='fixedstr';
delimiter;
UPDATE ld_desk set Fieldlabel='电话' where labelbol='COMPANYPHONE' and languagetype='zh' and Labeltype='fixedstr';
UPDATE ld_desk set Fieldlabel='Phone' where labelbol='COMPANYPHONE' and languagetype='en' and Labeltype='fixedstr';
delimiter;
UPDATE ld_desk set Fieldlabel='传真' where labelbol='COMPANYFAX' and languagetype='zh' and Labeltype='fixedstr';
UPDATE ld_desk set Fieldlabel='Fax' where labelbol='COMPANYFAX' and languagetype='en' and Labeltype='fixedstr';
delimiter;
UPDATE ld_desk set Fieldlabel='网址' where labelbol='COMPANYWEBSITE' and languagetype='zh' and Labeltype='fixedstr';
UPDATE ld_desk set Fieldlabel='Website' where labelbol='COMPANYWEBSITE' and languagetype='en' and Labeltype='fixedstr';
delimiter;

ALTER TABLE ld_products MODIFY qtyearly DECIMAL(25,8);
ALTER TABLE ld_products MODIFY qtyinstock DECIMAL(25,8);
delimiter;
UPDATE ld_field SET uitype = 5 WHERE uitype = 23 AND tabid IN (SELECT tabid FROM ld_tab WHERE NAME IN ('OutboundOrder','Stock'));
delimiter;

select max(parenttabid) into @parenttabid from ld_parenttab;
select max(sequence) into @seq from ld_parenttab;
insert into ld_parenttab(parenttabid,parenttab_label,sequence,visible)
select @parenttabid+1,'Service',@seq+1,0 from dual 
where not exists (select 1 from ld_parenttab where parenttab_label='Service');
delimiter;

select parenttabid into @parenttabid from ld_parenttab where parenttab_label='Service';
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'zh','LD_parenttab',@parenttabid,@parenttabid,'服务' 
from dual where not EXISTS(select 1 from ld_tranlabel  where languagetype = 'zh' 
and trantable ='LD_parenttab' and tabid = @parenttabid and relateid=@parenttabid);

insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'en','LD_parenttab',@parenttabid,@parenttabid,'Service' 
from dual where not EXISTS(select 1 from ld_tranlabel  where languagetype = 'en' 
and trantable ='LD_parenttab' and tabid = @parenttabid and relateid=@parenttabid);
delimiter;

select parenttabid into @parenttabid from ld_parenttab where parenttab_label='Service';
select tabid into @tabid from ld_tab where name='ServiceCharge';
insert into ld_parenttabrel(parenttabid,tabid,sequence)
select @parenttabid,37,1 from dual 
where not exists (select 1 from ld_parenttabrel where parenttabid=@parenttabid and tabid=37);

insert into ld_parenttabrel(parenttabid,tabid,sequence)
select @parenttabid,13,2 from dual 
where not exists (select 1 from ld_parenttabrel where parenttabid=@parenttabid and tabid=13);

insert into ld_parenttabrel(parenttabid,tabid,sequence)
select @parenttabid,@tabid,3 from dual 
where not exists (select 1 from ld_parenttabrel where parenttabid=@parenttabid and tabid=@tabid);

update ld_parenttabrel set sequence=1 where parenttabid=@parenttabid and tabid=37;
update ld_parenttabrel set sequence=2 where parenttabid=@parenttabid and tabid=@tabid;
update ld_parenttabrel set sequence=3 where parenttabid=@parenttabid and tabid=13;

delete from ld_parenttabrel where parenttabid= @parenttabid and tabid in (13,37)
and exists (select 1 from ld_version where trade='edu');

select parenttabid into @parenttabid1 from ld_parenttab where parenttab_label='Parent Accounts';
delete from ld_parenttabrel where parenttabid= @parenttabid1 and tabid=@tabid;
delete from ld_parenttabrel where parenttabid= @parenttabid1 and tabid in (13,37)
and not exists (select 1 from ld_version where trade='edu');
delimiter;

select sequence into @seq1 from ld_parenttab where parenttab_label='Sales';
update ld_parenttab set sequence=sequence+1 where sequence>@seq1;
update ld_parenttab set sequence=@seq1+1 where parenttab_label='Service';

select sequence into @seq2 from ld_parenttab where parenttab_label='Stock';
update ld_parenttab set sequence=sequence+1 where sequence>@seq2;
update ld_parenttab set sequence=@seq2+1 where parenttab_label='Purchase';
delimiter;

select 0 into @i;
update ld_parenttab set sequence=(@i:=@i+1) order by sequence;
delimiter;
-- end 2014-08-27

update ld_tab set presence=1 where `name`='ServiceCharge' and not exists (select 1 from ld_version where versiontype=1) ;
delete from ld_tabwithproductview where tabid=(select tabid from ld_tab where name='ServiceCharge') 
and `columns` like '%LD_account:account_type:accounttype%'
and not exists (select 1 from ld_field where tabid=6 and columnname='account_type' and presence<>1);
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
	declare cur1 CURSOR FOR SELECT fieldid,tabid   FROM  LD_field where tabid in(select tabid from lD_tab where name=tabname);
	declare continue handler  for not   found  SET done =1;

	OPEN cur1;
	Fetch cur1 into ffieldid,ttabid;

 	loop1: while  done<>1 DO
		set @sql=Concat('insert into LD_def_org_field(tabid,fieldid,visible,readonly) select ',ttabid,',',ffieldid,',',0,',',1 ,' from dual where not exists(select 1 from LD_def_org_field where fieldid=',ffieldid,')');
	
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


declare cur2 CURSOR FOR SELECT profileid   FROM  LD_profile;

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

call fieldprofile('ServiceCharge');
delimiter;
call getallprofile('ServiceCharge');
delimiter;
-- end 2014-08-28


select sequence into @seq from ld_field where tabid=13 and columnname='product_id';
select block into @block from ld_field where tabid=13 and columnname='product_id';
update ld_field set sequence=sequence+1 where tabid=13 and block=@block and sequence>=@seq;
update ld_field set presence=1 where tabid=13 and columnname='product_id';

select tabid into @tabid from ld_tab where name='HelpDesk';
select 'LD_troubletickets' into @tablename;
select 'productcategory' into @columnname;
select 'productcategory' into @fieldname;
select '产品类别' into @zh;
select 'Product Category' into @en;
select 15 into @uitype;
select 1 into @displaytype;
-- select sequence into @seq from ld_field where tabid=13 and columnname='product_id';
-- select block into @block from ld_field where tabid=13 and columnname='product_id'
select 'V~M' into @typeofdata;

select max(fieldid) into @fieldid from ld_field;
insert into ld_field(tabid,fieldid,columnname,tablename,generatedtype,uitype,fieldname,fieldlabel,readonly,presence,maximumlength,sequence,block,displaytype,typeofdata,quickcreate,info_type)
select @tabid,@fieldid+1,@columnname,@tablename,1,@uitype,@fieldname,@zh,1,2,100,@seq,@block,@displaytype,@typeofdata,3,'BAS' from dual 
where not exists (select 1 from ld_field where tabid = @tabid and columnname = @columnname);
update ld_field_seq set id = (select max(fieldid) from ld_field);

select fieldid into @fieldid from ld_field where tabid = @tabid and columnname = @columnname;
delete from ld_tranlabel where trantable ='LD_field' and tabid=@tabid and relateid=@fieldid;
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'zh','LD_field',@tabid,@fieldid,@zh;

insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'en','LD_field',@tabid,@fieldid,@en;

call AddColumn(@tablename,@columnname,'varchar','200',NULL);
delimiter;


select sequence into @seq from ld_field where tabid=13 and columnname='fees';
select block into @block from ld_field where tabid=13 and columnname='fees';
update ld_field set sequence=sequence+1 where tabid=13 and block=@block and sequence>@seq;

select tabid into @tabid from ld_tab where name='HelpDesk';
select 'LD_troubletickets' into @tablename;
select 'traficfee' into @columnname;
select 'traficfee' into @fieldname;
select '交通费' into @zh;
select 'Trafic Fee' into @en;
select 71 into @uitype;
select 1 into @displaytype;
-- select sequence into @seq from ld_field where tabid=13 and columnname='fees';
-- select block into @block from ld_field where tabid=13 and columnname='fees'
select 'N~O' into @typeofdata;

select max(fieldid) into @fieldid from ld_field;
insert into ld_field(tabid,fieldid,columnname,tablename,generatedtype,uitype,fieldname,fieldlabel,readonly,presence,maximumlength,sequence,block,displaytype,typeofdata,quickcreate,info_type)
select @tabid,@fieldid+1,@columnname,@tablename,1,@uitype,@fieldname,@zh,1,2,100,@seq+1,@block,@displaytype,@typeofdata,3,'BAS' from dual 
where not exists (select 1 from ld_field where tabid = @tabid and columnname = @columnname);
update ld_field_seq set id = (select max(fieldid) from ld_field);

select fieldid into @fieldid from ld_field where tabid = @tabid and columnname = @columnname;
delete from ld_tranlabel where trantable ='LD_field' and tabid=@tabid and relateid=@fieldid;
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'zh','LD_field',@tabid,@fieldid,@zh;

insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'en','LD_field',@tabid,@fieldid,@en;

select 1 into @i;
update ld_field set sequence=(@i:=@i+1) where tabid=@tabid and block=@block order by sequence;

call AddColumn(@tablename,@columnname,'int','19',0);
alter table LD_troubletickets modify traficfee decimal(25,2);
delimiter;

call fieldprofile('HelpDesk');
delimiter;
call getallprofile('HelpDesk');
delimiter;

update ld_field set typeofdata='V~M' where tabid=13 and columnname='category';

select tabid into @tabid from ld_tab where name='ProjectTask';
select sequence into @seq from ld_field where tabid=@tabid and columnname='projecttasktype';
select block into @block from ld_field where tabid=@tabid and columnname='projecttasktype';
update ld_field set sequence=sequence+1 where tabid=@tabid and block=@block and sequence>=@seq;

select 'LD_projecttask' into @tablename;
select 'productcategory' into @columnname;
select 'productcategory' into @fieldname;
select '产品类别' into @zh;
select 'Product Category' into @en;
select 15 into @uitype;
select 1 into @displaytype;
-- select sequence into @seq from ld_field where tabid=13 and columnname='product_id';
-- select block into @block from ld_field where tabid=13 and columnname='product_id'
select 'V~M' into @typeofdata;

select max(fieldid) into @fieldid from ld_field;
insert into ld_field(tabid,fieldid,columnname,tablename,generatedtype,uitype,fieldname,fieldlabel,readonly,presence,maximumlength,sequence,block,displaytype,typeofdata,quickcreate,info_type)
select @tabid,@fieldid+1,@columnname,@tablename,1,@uitype,@fieldname,@zh,1,2,100,@seq,@block,@displaytype,@typeofdata,3,'BAS' from dual 
where not exists (select 1 from ld_field where tabid = @tabid and columnname = @columnname);
update ld_field_seq set id = (select max(fieldid) from ld_field);

select fieldid into @fieldid from ld_field where tabid = @tabid and columnname = @columnname;
delete from ld_tranlabel where trantable ='LD_field' and tabid=@tabid and relateid=@fieldid;
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'zh','LD_field',@tabid,@fieldid,@zh;

insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'en','LD_field',@tabid,@fieldid,@en;

update ld_field set typeofdata='V~M' where tabid=@tabid and columnname='projecttasktype';

call AddColumn(@tablename,@columnname,'varchar','200',NULL);
delimiter;



select tabid into @tabid from ld_tab where name='ProjectTask';
select sequence into @seq from ld_field where tabid=@tabid and columnname='smownerid';
select block into @block from ld_field where tabid=@tabid and columnname='smownerid';
update ld_field set sequence=sequence+1 where tabid=@tabid and block=@block and sequence>@seq;

select tabid into @tabid from ld_tab where name='ProjectTask';
select 'LD_projecttask' into @tablename;
select 'traficfee' into @columnname;
select 'traficfee' into @fieldname;
select '交通费' into @zh;
select 'Trafic Fee' into @en;
select 71 into @uitype;
select 1 into @displaytype;
-- select sequence into @seq from ld_field where tabid=13 and columnname='fees';
-- select block into @block from ld_field where tabid=13 and columnname='fees'
select 'N~O' into @typeofdata;

select max(fieldid) into @fieldid from ld_field;
insert into ld_field(tabid,fieldid,columnname,tablename,generatedtype,uitype,fieldname,fieldlabel,readonly,presence,maximumlength,sequence,block,displaytype,typeofdata,quickcreate,info_type)
select @tabid,@fieldid+1,@columnname,@tablename,1,@uitype,@fieldname,@zh,1,2,100,@seq+1,@block,@displaytype,@typeofdata,3,'BAS' from dual 
where not exists (select 1 from ld_field where tabid = @tabid and columnname = @columnname);
update ld_field_seq set id = (select max(fieldid) from ld_field);

select fieldid into @fieldid from ld_field where tabid = @tabid and columnname = @columnname;
delete from ld_tranlabel where trantable ='LD_field' and tabid=@tabid and relateid=@fieldid;
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'zh','LD_field',@tabid,@fieldid,@zh;

insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'en','LD_field',@tabid,@fieldid,@en;

select 1 into @i;
update ld_field set sequence=(@i:=@i+1) where tabid=@tabid and block=@block order by sequence;

call AddColumn(@tablename,@columnname,'int','19',0);
alter table LD_projecttask modify traficfee decimal(25,2);
delimiter;

call fieldprofile('ProjectTask');
delimiter;
call getallprofile('ProjectTask');
delimiter;

delete from ld_tranlabel where tabid=16 and Relateid=39 and trantable='Basic Information';

select tabid into @tabid from ld_tab where name='Commission';
select fieldid into @fieldid from ld_field where tabid=@tabid and columnname='modifiedtime';
delete from ld_tranlabel where trantable ='LD_field' and relateid=@fieldid;
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'zh','LD_field',@tabid,@fieldid,'修改时间';

insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'en','LD_field',@tabid,@fieldid,'Modified Time';
delimiter;

select tabid into @tabid from ld_tab where name='ServiceCharge';
select fieldid into @fieldid from ld_field where tabid=@tabid and columnname='faxx';
delete from ld_tranlabel where trantable ='LD_field' and relateid=@fieldid;
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'zh','LD_field',@tabid,@fieldid,'传真';

insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'en','LD_field',@tabid,@fieldid,'Fax';
delimiter;

select tabid into @tabid from ld_tab where name='ServiceCharge';
select fieldid into @fieldid from ld_field where tabid=@tabid and columnname='mailingstreet';
delete from ld_tranlabel where trantable ='LD_field' and relateid=@fieldid;
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'zh','LD_field',@tabid,@fieldid,'住址';

insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'en','LD_field',@tabid,@fieldid,'Address';
delimiter;

select tabid into @tabid from ld_tab where name='ServiceCharge';
select fieldid into @fieldid from ld_field where tabid=@tabid and columnname='pphone';
delete from ld_tranlabel where trantable ='LD_field' and relateid=@fieldid;
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'zh','LD_field',@tabid,@fieldid,'电话';

insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'en','LD_field',@tabid,@fieldid,'Phone';
delimiter;


select tabid into @tabid from ld_tab where name='Services';
delete from ld_tranlabel where trantable ='LD_tab' and relateid=@tabid;
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'zh','LD_tab',@tabid,@tabid,'服务';

insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'en','LD_tab',@tabid,@tabid,'Services';
delimiter;

select tabid into @tabid from ld_tab where name='MassVoices';
delete from ld_tranlabel where trantable ='LD_tab' and relateid=@tabid;
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'zh','LD_tab',@tabid,@tabid,'群发语音';

insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'en','LD_tab',@tabid,@tabid,'Mass Voices';
delimiter;

select tabid into @tabid from ld_tab where name='Commission';
select fieldid into @fieldid from ld_field where tabid=@tabid and columnname='expensedate';
delete from ld_tranlabel where trantable ='LD_field' and relateid=@fieldid;
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'zh','LD_field',@tabid,@fieldid,'报销日期';

insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'en','LD_field',@tabid,@fieldid,'Commission Date';
delimiter;

select tabid into @tabid from ld_tab where name='Commission';
select fieldid into @fieldid from ld_field where tabid=@tabid and columnname='bankaccountsetid';
delete from ld_tranlabel where trantable ='LD_field' and relateid=@fieldid;
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'zh','LD_field',@tabid,@fieldid,'账户';

insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'en','LD_field',@tabid,@fieldid,'Bank Account';
delimiter;

delete from ld_tranlabel where trantable='LD_parenttab' and Relateid not in (select parenttabid from ld_parenttab);
update ld_tranlabel set fieldlabel='任务类别' where trantable='LD_field' and Relateid=604 and fieldlabel='类型';

select cvid into @cvid from ld_customview where entitytype='Contacts' and viewname='All';
delete from ld_cvcolumnlist where cvid=@cvid and columnname like 'LD_contactsubdetails:birthday:birthday%';
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'zh','FINDRELATIONNOW','现在查找有关','fixedstr' from dual 
where not EXISTS(select 1 from ld_desk  where languagetype='zh' and labelbol='FINDRELATIONNOW' and Labeltype='fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'en','FINDRELATIONNOW','Find relation now','fixedstr' from dual 
where not EXISTS(select 1 from ld_desk  where languagetype='en' and labelbol='FINDRELATIONNOW' and Labeltype='fixedstr');
delimiter;
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'zh','MAILBOX','邮箱','fixedstr' from dual 
where not EXISTS(select 1 from ld_desk  where languagetype='zh' and labelbol='MAILBOX' and Labeltype='fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'en','MAILBOX','Mailbox','fixedstr' from dual 
where not EXISTS(select 1 from ld_desk  where languagetype='en' and labelbol='MAILBOX' and Labeltype='fixedstr');
delimiter;
delete from ld_desk where labelbol = 'ALETTEROF' and Labeltype = 'fixedstr';
delete from ld_desk where labelbol = 'NEXTLETTER' and Labeltype = 'fixedstr';
delimiter;

UPDATE ld_desk SET Fieldlabel='The maximum number of high seas customers' WHERE labelbol='maximumnumberofhighseascustomers' 
AND Labeltype='fixedstr' AND languagetype='en';

UPDATE ld_desk SET Fieldlabel='The maximum number of high seas customers' WHERE labelbol='Themaximumnumberofhighseascustomers' 
AND Labeltype='fixedstr' AND languagetype='en';

UPDATE ld_desk set Fieldlabel='（客户和客户服务单明细界面）' where labelbol='ACCOUNTALLVIEWREMIND' and languagetype='zh' and Labeltype='fixedstr';
UPDATE ld_desk set Fieldlabel='(Customers and customer service detail interface)' where labelbol='ACCOUNTALLVIEWREMIND' and languagetype='en' and Labeltype='fixedstr';


call AddColumn('LD_stock','contactid','int',19,0);

select tabid into @tabid from ld_tab where name='stock';
select blockid into @blockid from ld_blocks where tabid=@tabid and blocklabel='LBL_WARE_INFO';
select  max(fieldid) into @maxfieldid from ld_field;

update ld_field_seq set id=@maxfieldid+1 where not EXISTS(select 1 from ld_field where tabid=@tabid and columnname='contactid');

insert into ld_field(tabid,fieldid,columnname,tablename,generatedtype,uitype,fieldname,fieldlabel,readonly,presence,defaultvalue,maximumlength,sequence,
block,displaytype,typeofdata,quickcreate,masseditable)
select @tabid,@maxfieldid+1,'contactid','LD_stock',1,96,'contact_id','联系人姓名',1,0,'',100,10,@blockid,1,'I~O',3,'1' from dual 
where not EXISTS(select 1 from ld_field where tabid=@tabid and columnname='contactid');
select fieldid into @fieldid from ld_field  where  tabid=@tabid and columnname='contactid';
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'zh','LD_field',@tabid ,@fieldid,'联系人姓名' from dual 
where not EXISTS(select 1 from ld_tranlabel where languagetype='zh' and relateid=@fieldid and trantable='ld_field');

insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'en','LD_field',@tabid ,@fieldid,'Contact name' from dual 
where not EXISTS(select 1 from ld_tranlabel where languagetype='en' and relateid=@fieldid and trantable='ld_field');

call getallprofile('stock');
call fieldprofile('stock');
delimiter;

update ld_desk set Fieldlabel='Please select at least one record!' where labelbol='PLEASESELECTONEENTITY' and languagetype='en' and Labeltype = 'jspop';
update ld_desk set Fieldlabel='Can not be restored after the deletion, are you sure you want to delete the selected content' where labelbol='CANOTRESTOREDAFTERDELETION' and languagetype='en' and Labeltype = 'jspop';
update ld_desk set Fieldlabel='Can not be restored after deleted,are you sure you want to delete this record?' where labelbol='CANOTRESTOREDAFTERDELETIONDELETEOK' and languagetype='en' and Labeltype = 'jspop';
update ld_desk set Fieldlabel='Are you sure you want to delete the selected content' where labelbol='SUREWANTDELETETHEDELECTED' and languagetype='en' and Labeltype='jspop';
update ld_desk set Fieldlabel='Are you sure you want to transform the selected content' where labelbol='SUREWANTCONVERTSELECTED' and languagetype='en' and Labeltype='jspop';
update ld_desk set Fieldlabel='Records are the high seas clients?' where labelbol='RECORDSTHEHIGHSEASCLIENTS' and languagetype='en' and Labeltype='jspop';
update ld_desk set Fieldlabel='The customers you choose have been ordinary customers!' where labelbol='CUSTOMERSHAVEORDINARY' and languagetype='en' and Labeltype='jspop';
update ld_desk set Fieldlabel='Please choose the e-mail what you want to send to e-mails' where labelbol='CHOOSEWANTSENDEMAIL' and languagetype='en' and Labeltype='jspop';
update ld_desk set Fieldlabel='Please choose text messages what you want to send to mobile phones' where labelbol='CHOOSEWANTSENDPHONES' and languagetype='en' and Labeltype='jspop';
update ld_desk set Fieldlabel='Please enter the correct time range!' where labelbol='PLEASEENTERCORRECTTIME' and languagetype='en' and Labeltype='jspop';
update ld_desk set Fieldlabel="Please input customers' name for checking" where labelbol='REENTERCUSTOMERNAMESCHECKED' and languagetype='en' and Labeltype='jspop';
update ld_desk set Fieldlabel='Confirm that you want to delete the report?' where labelbol='CONFIRMWANTDELETEREPORTS' and languagetype='en' and Labeltype='jspop';
update ld_desk set Fieldlabel='After execution, the storehouse will be restored to "not out of the library" state, and restore inventory quantity before the library. are you sure you want to revoke the Secretary?' where labelbol='SUREWANTREVOKESECRETARY' and languagetype='en' and Labeltype='jspop';
update ld_desk set Fieldlabel="This record(s) will be deleted directly(don't move to the recycle bin), are you sure you want to delete the record(s)?" where labelbol='NOTRECYCLEBINCONFIRMDELETE' and languagetype='en' and Labeltype='jspop';
update ld_desk set Fieldlabel='After execution, the inventory list will be restored to the state of "inventorying", and restore inventory quantity before inventory. are you sure you want to cancel inventory?' where labelbol='READYCANCELINVENTORY' and languagetype='en' and Labeltype='jspop';
update ld_desk set Fieldlabel='Not found the change log' where labelbol='NOTFOUNDMODIFYLOG' and languagetype='en' and Labeltype='jspop';
update ld_desk set Fieldlabel='The records of your choice are approved or being approved, batch editing is not allowed!' where labelbol='APPROVEDNOTALLOWEDBATCHEDITING' and languagetype='en' and Labeltype='jspop';
update ld_desk set Fieldlabel='The records of your choice have been paid or part payment of documents, batch editing is not allowed!' where labelbol='RECORDNOTALLOWEDBATCHEDITING' and languagetype='en' and Labeltype='jspop';
update ld_desk set Fieldlabel='The total payment plan has been equal to the amount of non payment plan' where labelbol='PAYMENTPLANEQUALNONPAYMENTPLAN' and languagetype='en' and Labeltype='jspop';
update ld_desk set Fieldlabel='The amount of payment planned and unplanned amount is not consistent!' where labelbol='PAYMENTSPLANINCONSISTENCY' and languagetype='en' and Labeltype='jspop';
update ld_desk set Fieldlabel='The proportion of the total payment must be equal to ' where labelbol='PAYMENTMUSTEQUALPROPORTION' and languagetype='en' and Labeltype='jspop';
update ld_desk set Fieldlabel='The amount can not be empty or zero!' where labelbol='AMOUNTCANOTZERO' and languagetype='en' and Labeltype='jspop';
update ld_desk set Fieldlabel='Removing these customers will delete their associated sales opportunities, quotations. are you sure you want to delete the selected content' where labelbol='REMOVEWILLDELETEOTHER' and languagetype='en' and Labeltype='jspop';
update ld_desk set Fieldlabel='Are you sure you want to receive the selected content' where labelbol='SUREWANTRECEIVESELECTED' and languagetype='en' and Labeltype='jspop';
update ld_desk set Fieldlabel='The template is the default template, can not be deleted' where labelbol='DEFAULTTEMPLATECANOTDELETED' and languagetype='en' and Labeltype='jspop';
update ld_desk set Fieldlabel='Please enter at least 1 characters above data search again' where labelbol='ONECHARTHENFINDMOREDATA' and languagetype='en' and Labeltype='jspop';
update ld_desk set Fieldlabel='The proportion of the total received payment must be equal to 100' where labelbol='PROPORTIONPAYMENTMUSTEQUAL' and languagetype='en' and Labeltype='jspop';
update ld_desk set Fieldlabel='The proportion of the total received payment must be a positive integer!' where labelbol='PROPORTIONBACKMUSTPOSITIVEINT' and languagetype='en' and Labeltype='jspop';
update ld_desk set Fieldlabel='The proportion of ireceived payment is illegal!' where labelbol='PROPORTIONILLEGALMONEYBACK' and languagetype='en' and Labeltype='jspop';
update ld_desk set Fieldlabel='The total received payment planned has been greater than the amount of unplanned, whether to continue?' where labelbol='REIMBURSEMENTGREATERUNPLANNED' and languagetype='en' and Labeltype='jspop';
update ld_desk set Fieldlabel='The total received payment planned has been equal to the amount of unplanned, whether to continue?' where labelbol='REIMBURSEMENTEQUALUNPLANNED' and languagetype='en' and Labeltype='jspop';
update ld_desk set Fieldlabel='The total received payment planned has been less than the amount of unplanned, whether to continue?' where labelbol='REIMBURSEMENTLESSUNPLANNED' and languagetype='en' and Labeltype='jspop';
update ld_desk set Fieldlabel='The amount of received payment planned and unplanned amount is not consistent!' where labelbol='PLANNEDINCONSISTENTUNPLANNED' and languagetype='en' and Labeltype='jspop';
update ld_desk set Fieldlabel='Amount of money is illegal!' where labelbol='AMOUNTILLEGAL' and languagetype='en' and Labeltype='jspop';
update ld_desk set Fieldlabel='The amount of money can not be empty or zero!' where labelbol='AMOUNTCANOTNULL' and languagetype='en' and Labeltype='jspop';
update ld_desk set Fieldlabel='Periods of time can not be empty!' where labelbol='OFTIMECANOTEMPTY' and languagetype='en' and Labeltype='jspop';
update ld_desk set Fieldlabel='The total received payment has been equal to the amount of unplanned' where labelbol='PLANAMOUNTEQUALUNPLANAMOUNT' and languagetype='en' and Labeltype='jspop';
update ld_desk set Fieldlabel='Delayed days can not be empty!' where labelbol='POSTPONEDFEWDAYSCANOTEMPTY' and languagetype='en' and Labeltype='jspop';
update ld_desk set Fieldlabel='Illegal delayed days' where labelbol='ILLEGALPOSTPONEDFEWDAYS' and languagetype='en' and Labeltype='jspop';
update ld_desk set Fieldlabel='Delayed days can only input positive integer!' where labelbol='POSTPONEDFEWDAYPOSITIVEINT' and languagetype='en' and Labeltype='jspop';
update ld_desk set Fieldlabel='The customers you choose have been ordinary customers!' where labelbol='CUSTOMERSISHIGHSEAS' and languagetype='en' and Labeltype='jspop';
update ld_desk set Fieldlabel='Records are the ordinary clients?' where labelbol='RECORDSTHEORDINARYCLIENTS' and languagetype='en' and Labeltype='jspop';
update ld_desk set Fieldlabel='The number of customers of the high seas you have have reached the limit, receive failed' where labelbol='HIGHSEASREACHEDTHELIMITCOLLECT' and languagetype='en' and Labeltype='jspop';
update ld_desk set Fieldlabel='The number of customers of the high seas have reached the limit,allocate failed' where labelbol='HIGHSEASREACHEDTHELIMITALLOCATION' and languagetype='en' and Labeltype='jspop';
update ld_desk set Fieldlabel='Are you sure you want to receive the high seas customers:' where labelbol='SUREWANTRECEIVEHIGHSEAS' and languagetype='en' and Labeltype='jspop';
update ld_desk set Fieldlabel='Are you sure you want to release the selected content' where labelbol='SUREWANTRELEASESELECTED' and languagetype='en' and Labeltype='jspop';
update ld_desk set Fieldlabel='Do records not assign to the high seas?' where labelbol='TOHIGHSEAS' and languagetype='en' and Labeltype='jspop';
update ld_desk set Fieldlabel='Only redistribute' where labelbol='MAXREDISTRIBUTION' and languagetype='en' and Labeltype='jspop';
update ld_desk set Fieldlabel='Are you sure you want to distribute the selected content' where labelbol='DISTRIBUTIONSELECTED' and languagetype='en' and Labeltype='jspop';
update ld_desk set Fieldlabel='Communications account is not set, use the administrator user to control panel to set!' where labelbol='COMMUNICATIONSACCOUNTNOTSET' and languagetype='en' and Labeltype='jspop';
update ld_desk set Fieldlabel='The phone of person in charge is empty, you can not send text messages!' where labelbol='PHONEEMPTYCANOTSEND' and languagetype='en' and Labeltype='jspop';
update ld_desk set Fieldlabel='The phone of person in charge is illegal, you can not send text messages!' where labelbol='PHONENOTLEGALLYCANOTSEND' and languagetype='en' and Labeltype='jspop';
update ld_desk set Fieldlabel='After this operation, all documents using of the process approval will automatically return to the person in charge, whether to continue?' where labelbol='PERSONCHARGEWHETHERCONTINUE' and languagetype='en' and Labeltype='jspop';
update ld_desk set Fieldlabel='The amount of other payments is illegal!' where labelbol='OTHERPAYMENTSILLEGAL' and languagetype='en' and Labeltype='jspop';
update ld_desk set Fieldlabel='This payment is invalid!' where labelbol='INVALIDPAYMENT' and languagetype='en' and Labeltype='jspop';
update ld_desk set Fieldlabel='No amount of payment plan is illegal!' where labelbol='INVALIDAMOUNTPLANAMOUNT' and languagetype='en' and Labeltype='jspop';
update ld_desk set Fieldlabel='This collection can not exceed "Amount - the amount received", please re-entry!' where labelbol='COLLECTIONCANOTEXCEEDRECEIVED' and languagetype='en' and Labeltype='jspop';
update ld_desk set Fieldlabel='This collection is invalid!' where labelbol='INVALIDCOLLECTION' and languagetype='en' and Labeltype='jspop';
update ld_desk set Fieldlabel='Are you sure to inventory?' where labelbol='DETERMINEINVENTORY' and languagetype='en' and Labeltype='jspop';
update ld_desk set Fieldlabel='After execution, the inventory list will be restored to the state of "inventorying", and restore inventory quantity before inventory. are you sure you want to cancel inventory?' where labelbol='PREVIOUSINVENTORYSTOCKQUANTITY' and languagetype='en' and Labeltype='jspop';
update ld_desk set Fieldlabel="You don't have sufficient permission,you are unauthorized to operate the warehouse!" where labelbol='LACKAUTHORITYCANOTOPERATEWAREHOUSE' and languagetype='en' and Labeltype='jspop';
update ld_desk set Fieldlabel='Page width percentage is only for digital!' where labelbol='PERCENTAGEONLYDIGITAL' and languagetype='en' and Labeltype='jspop';
update ld_desk set Fieldlabel='Mail account is not detected, please set the account information first!' where labelbol='MAILACCOUNTNOTDETECTEDPLESEESET' and languagetype='en' and Labeltype='jspop';
update ld_desk set Fieldlabel='Reimbursement for the amount of is illegal!' where labelbol='REIMBURSEMENTILLEGALCONTENT' and languagetype='en' and Labeltype='jspop';
update ld_desk set Fieldlabel='Page width percentage can only input positive integer!' where labelbol='PERCENTAGEONLYPOSITIVEINGEGER' and languagetype='en' and Labeltype='jspop';
update ld_desk set Fieldlabel='The records you choose has receivable or part of documents,delete failed!' where labelbol='SELECTHASRECEIVINGDELETINGFAILED' and languagetype='en' and Labeltype='jspop';
update ld_desk set Fieldlabel='Number of initialization product can not be empty!' where labelbol='QUANTITYINITIALIZATIONCANOTEMPTY' and languagetype='en' and Labeltype='jspop';
update ld_desk set Fieldlabel='Number of initialization product is invalid!' where labelbol='INVALIDINITIALIZATIONPRODUCTNUM' and languagetype='en' and Labeltype='jspop';
update ld_desk set Fieldlabel='Number of initialization product is not allowed to be changed after being confirmed,are you sure to complete the inventory initialize it?' where labelbol='CONFIRMNOTALLOWEDCHANGEPRODUCT' and languagetype='en' and Labeltype='jspop';
update ld_desk set Fieldlabel='File format is not correct, please import xls or xlsx file!' where labelbol='FILEFORMATCORRECT' and languagetype='en' and Labeltype='jspop';
update ld_desk set Fieldlabel='The total  payment planned has been equal to the amount of unplanned, whether to continue?' where labelbol='PAYMENTPLANEQUALUNPLANNED' and languagetype='en' and Labeltype='jspop';
update ld_desk set Fieldlabel='The total payment planned has been greater than the amount of unplanned, whether to continue?' where labelbol='PAYMENTPLANGREATERUNPLANNED' and languagetype='en' and Labeltype='jspop';
update ld_desk set Fieldlabel='The total payment planned has been less than the amount of unplanned, whether to continue?' where labelbol='PAYMENTPLANLESSUNPLANNED' and languagetype='en' and Labeltype='jspop';
update ld_desk set Fieldlabel='The total  payment planned has been equal to the amount of unplanned' where labelbol='PAYMENTPLANEQUALAMOUNTNOTPLAN' and languagetype='en' and Labeltype='jspop';
update ld_desk set Fieldlabel='Payment ratio is illegal!' where labelbol='PAYMENTRATIOILLEGAL' and languagetype='en' and Labeltype='jspop';
update ld_desk set Fieldlabel='The records you choose has receivable or part of documents,delete failed!' where labelbol='PAYMENTRECORDPARITIALLYDELETEFAILED' and languagetype='en' and Labeltype='jspop';
update ld_desk set Fieldlabel='Are you sure you want to delete this print templates?' where labelbol='CONFIRMWANTDELETEPRINTTEMPLATE' and languagetype='en' and Labeltype='jspop';
update ld_desk set Fieldlabel='The template is the system preferences, you can not delete!' where labelbol='SYSTEMTEMPLATECANOTDELETE' and languagetype='en' and Labeltype='jspop';
update ld_desk set Fieldlabel='The role exists subordinate role, can not be deleted!' where labelbol='EXISTSSUBORDINATEROLE' and languagetype='en' and Labeltype='jspop';
update ld_desk set Fieldlabel='After execution, the storage note will be restored to "not out of the library" state, and restore inventory quantity before the library. are you sure you want to revoke the Secretary?' where labelbol='INVENTORYQUANTITIESRESTORED' and languagetype='en' and Labeltype='jspop';
update ld_desk set Fieldlabel='New Password and Confirm Password are inconsistent, please re-enter!' where labelbol='PASSWORDINCONSISTENT' and languagetype='en' and Labeltype='jspop';
update ld_desk set Fieldlabel='Do you confirm that you want to modify the day, week, monthlysubmission deadline?' where labelbol='WANTMODIFYSUBMISSIONDEADLINE' and languagetype='en' and Labeltype='jspop';
update ld_desk set Fieldlabel='The backup file path can not be empty' where labelbol='BACKUPFILEPATHCANOTEMPTY' and languagetype='en' and Labeltype='jspop';
update ld_desk set Fieldlabel='Quantity cannot surpass reference document number!' where labelbol='CANOTEXCEEDORIGINALCONTRACTNUM' and languagetype='en' and Labeltype='jspop';
update ld_desk set Fieldlabel='Invalid authorization documents, registration failure!' where labelbol='INVALIDLICENSE' and languagetype='en' and Labeltype='jspop';
update ld_desk set Fieldlabel='While enabling the approval commission, client approval can not be empty!' where labelbol='APPROVINGCLIENTCANOTEMPTY' and languagetype='en' and Labeltype='jspop';
update ld_desk set Fieldlabel='Invalid the list with the numbers!' where labelbol='INVALIDLISTNUMBER' and languagetype='en' and Labeltype='jspop';
update ld_desk set Fieldlabel='Whether to delete the template?' where labelbol='DELETETHETEMPLATE' and languagetype='en' and Labeltype='jspop';
update ld_desk set Fieldlabel='Only positive integer number of days entry!' where labelbol='DAYSNUMONLYINT' and languagetype='en' and Labeltype='jspop';
update ld_desk set Fieldlabel='Only positive integer number entry!' where labelbol='NUMONLYINT' and languagetype='en' and Labeltype='jspop';
update ld_desk set Fieldlabel='Please entry receives the name correctly!' where labelbol='PLEASECORRECTRECEIVESNAME' and languagetype='en' and Labeltype='jspop';
update ld_desk set Fieldlabel='Please entry received numbere correctly!' where labelbol='PLEASECORRECTRECEIVEDNUMBER' and languagetype='en' and Labeltype='jspop';
update ld_desk set Fieldlabel='Please entry content correctly!' where labelbol='PLEASECORRECTCONTENT' and languagetype='en' and Labeltype='jspop';
update ld_desk set Fieldlabel='Please entry staff correctly!' where labelbol='PLEASECORRECTSTAFF' and languagetype='en' and Labeltype='jspop';
update ld_desk set Fieldlabel='Please entry themes correctly!' where labelbol='PLEASECORRECTTHEMES' and languagetype='en' and Labeltype='jspop';
update ld_desk set Fieldlabel='Please entry state correctly!' where labelbol='PLEASECORRECTSTATE' and languagetype='en' and Labeltype='jspop';
update ld_desk set Fieldlabel='Please entry the filter correctly!' where labelbol='PLEASECORRECTCATEGORY' and languagetype='en' and Labeltype='jspop';
update ld_desk set Fieldlabel='Please enter the time range correctly!' where labelbol='PLEASECORRECTTIME' and languagetype='en' and Labeltype='jspop';
update ld_desk set Fieldlabel='Please entry sender correctly' where labelbol='PLEASECORRECTSENDER' and languagetype='en' and Labeltype='jspop';
update ld_desk set Fieldlabel='Please input the recipient information correctly!' where labelbol='PLEASECORRECTRECIPIENTINFO' and languagetype='en' and Labeltype='jspop';
update ld_desk set Fieldlabel='Send time is less than the current system time, please re-select the time to send!' where labelbol='SENDTIMELESSSYSTEMTIME' and languagetype='en' and Labeltype='jspop';
update ld_desk set Fieldlabel='Communications account is disabled,send failed!' where labelbol='COMMACOUNTDISABLED' and languagetype='en' and Labeltype='jspop';
update ld_desk set Fieldlabel='Account balance is insufficient,send failed!' where labelbol='ACCOUNTBALANCEINSUFFICIENTFAILED' and languagetype='en' and Labeltype='jspop';
update ld_desk set Fieldlabel="Didn't choosr the txt files need to import!" where labelbol='TXTFILENOTCHOOSEIMPORT' and languagetype='en' and Labeltype='jspop';
update ld_desk set Fieldlabel='Can only read the txt file name suffix!' where labelbol='TXTFILENAMESUFFIXCANONLYREAD' and languagetype='en' and Labeltype='jspop';
update ld_desk set Fieldlabel='The document count ends, can not be deleted!' where labelbol='INVENTORYDOCUMENTSCANOTDELETED' and languagetype='en' and Labeltype='jspop';
update ld_desk set Fieldlabel='The records of your choice have been paid or part payment of documents, batch editing is not allowed!' where labelbol='SELECTECOLLECTIONDOCUMENTSNOTEDIT' and languagetype='en' and Labeltype='jspop';
update ld_desk set Fieldlabel='The records of your choice have been paid or part payment of documents, batch editing is not allowed!' where labelbol='SELECTEPAYMENTDOCUMENTSNOTEDIT' and languagetype='en' and Labeltype='jspop';
update ld_desk set Fieldlabel='The plan of next month can not be empty!' where labelbol='MONTHPLANCANOTEMPTY' and languagetype='en' and Labeltype='jspop';
update ld_desk set Fieldlabel='The hign seas customers parameter settings saved successfully!' where labelbol='CUSTPARAMETERSAVEDSUCCESS' and languagetype='en' and Labeltype='jspop';
update ld_desk set Fieldlabel='Please at least to select a character for role information!' where labelbol='PLEASESELECTROLEINFO' and languagetype='en' and Labeltype='jspop';
update ld_desk set Fieldlabel='Please specify the higher role after moving!' where labelbol='SPECIFYROLEAFTERMOVING' and languagetype='en' and Labeltype='jspop';
update ld_desk set Fieldlabel='Sorry, currently only single file uploading are supported' where labelbol='ONLYSINGLEFILEUPLOAD' and languagetype='en' and Labeltype='jspop';
update ld_desk set Fieldlabel='Already uploaded successfully!' where labelbol='HASUPLOADSUCCESS' and languagetype='en' and Labeltype='jspop';
update ld_desk set Fieldlabel='The document has continued being flowed and approved, you have no right to retracement!' where labelbol='DOCUMENTAPPROVINGCANTRETRACEMENT' and languagetype='en' and Labeltype='jspop';
update ld_desk set Fieldlabel='It will return to the previous state after approval retracement, you need to re-approval.Are you ture to retracement it?' where labelbol='RETRACEMENTAPPROVALNEWDDREAPPROVAL' and languagetype='en' and Labeltype='jspop';
update ld_desk set Fieldlabel='Refund amount does not exceed the amount of the return of refund list!' where labelbol='REFUNDAMOUNTNOTEXCEEDAMOUNT' and languagetype='en' and Labeltype='jspop';
update ld_desk set Fieldlabel='The single storage has been in storage, can not be deleted!' where labelbol='SINGLESTORAGEHASINSTORAGECANOTDELETE' and languagetype='en' and Labeltype='fixedstr';
update ld_desk set Fieldlabel='The returns single has been in storage, can not be deleted!' where labelbol='RETURNSSINGLEHASINSTORAGECANOTDELETE' and languagetype='en' and Labeltype='fixedstr';
update ld_desk set Fieldlabel='The return has been processed a single end, can not be deleted!' where labelbol='RETURNPROCESSEDCANOTDELETE' and languagetype='en' and Labeltype='fixedstr';
update ld_desk set Fieldlabel='Page' where labelbol='PAGE' and languagetype='en' and Labeltype='fixedstr';
update ld_desk set Fieldlabel='Remind' where labelbol='REMINDS' and languagetype='en' and Labeltype='fixedstr';
update ld_desk set Fieldlabel='Whether to default' where labelbol='WHETHERDEFAULT' and languagetype='en' and Labeltype='fixedstr';
update ld_desk set Fieldlabel='Manage system templates and define new field for the template' where labelbol='MANAGEMENTSYSTEMTEMPLATES' and languagetype='en' and Labeltype='fixedstr';
update ld_desk set Fieldlabel='If you need to adjust the information variables, you can use the below option of viewing,you can put print variable directly insert or manually copy into the template to print,it will automatically replace the corresponding value when print' where labelbol='TEMPLATEDESCRIPTIONINFORMATION' and languagetype='en' and Labeltype='fixedstr';
update ld_desk set Fieldlabel='The variable when it is empty replace to ' where labelbol='REPLACEVARIABLEEMPTY' and languagetype='en' and Labeltype='fixedstr';
update ld_desk set Fieldlabel='owner’s name' where labelbol='PERSONCHARGENAME' and languagetype='en' and Labeltype='fixedstr';
update ld_desk set Fieldlabel='Rename item' where labelbol='EDITITEM' and languagetype='en' and Labeltype='fixedstr';
update ld_desk set Fieldlabel='User Mangement' where labelbol='LBL_USERS' and languagetype='en' and Labeltype='fixedstr';
update ld_desk set Fieldlabel='Roles access' where labelbol='LBL_ROLES' and languagetype='en' and Labeltype='fixedstr';
update ld_desk set Fieldlabel='access' where labelbol='LBL_PROFILES' and languagetype='en' and Labeltype='fixedstr';
update ld_desk set Fieldlabel='Department installing' where labelbol='USERGROUPLIST' and languagetype='en' and Labeltype='fixedstr';
update ld_desk set Fieldlabel='Sharing rule' where labelbol='LBL_SHARING_ACCESS' and languagetype='en' and Labeltype='fixedstr';
update ld_desk set Fieldlabel='Operation log' where labelbol='LBL_AUDIT_TRAIL' and languagetype='en' and Labeltype='fixedstr';
update ld_desk set Fieldlabel='Login Log' where labelbol='LBL_LOGIN_HISTORY_DETAILS' and languagetype='en' and Labeltype='fixedstr';
update ld_desk set Fieldlabel='' where labelbol='NOTIFICATIONSCHEDULERS' and languagetype='en' and Labeltype='fixedstr';
update ld_desk set Fieldlabel='Currency Setting' where labelbol='LBL_CURRENCY_SETTINGS' and languagetype='en' and Labeltype='fixedstr';
update ld_desk set Fieldlabel='Proxy server' where labelbol='LBL_PROXY_SETTINGS' and languagetype='en' and Labeltype='fixedstr';
update ld_desk set Fieldlabel='Mode of page layout' where labelbol='LBL_DEFAULT_MODULE_VIEW' and languagetype='en' and Labeltype='fixedstr';
update ld_desk set Fieldlabel='Terms & Conditions' where labelbol='INVENTORYTERMSANDCONDITIONS' and languagetype='en' and Labeltype='fixedstr';
update ld_desk set Fieldlabel='System number customizing' where labelbol='LBL_CUSTOMIZE_MODENT_NUMBER' and languagetype='en' and Labeltype='fixedstr';
update ld_desk set Fieldlabel='Automatic operation' where labelbol='LBL_LIST_WORKFLOWS' and languagetype='en' and Labeltype='fixedstr';
update ld_desk set Fieldlabel='The component template' where labelbol='LBL_TEMPLATES' and languagetype='en' and Labeltype='fixedstr';
update ld_desk set Fieldlabel='Reminder setting of work report' where labelbol='LBL_REMIND_SET' and languagetype='en' and Labeltype='fixedstr';
update ld_desk set Fieldlabel='The login verification code' where labelbol='LBL_SECURITYCODE_SET' and languagetype='en' and Labeltype='fixedstr';
update ld_desk set Fieldlabel='The high seas customers setting' where labelbol='LBL_ACCOUNT_SET' and languagetype='en' and Labeltype='fixedstr';
update ld_desk set Fieldlabel='Print template customize' where labelbol='LBL_PRINT_TEMPLATE' and languagetype='en' and Labeltype='fixedstr';
update ld_desk set Fieldlabel='The approval process management' where labelbol='LBL_APPROVE' and languagetype='en' and Labeltype='fixedstr';
update ld_desk set Fieldlabel='More information field' where labelbol='LBL_RELATED_RELATEDLIST' and languagetype='en' and Labeltype='fixedstr';
update ld_desk set Fieldlabel='Page setup' where labelbol='LBL_PAGE_SET' and languagetype='en' and Labeltype='fixedstr';
update ld_desk set Fieldlabel='Data backup' where labelbol='LBL_BACKUP_SET' and languagetype='en' and Labeltype='fixedstr';
update ld_desk set Fieldlabel='Product list custom field' where labelbol='LBL_ProductTool_field' and languagetype='en' and Labeltype='fixedstr';
update ld_desk set Fieldlabel='Manage users who can access system' where labelbol='LBL_USER_DESCRIPTION' and languagetype='en' and Labeltype='fixedstr';
update ld_desk set Fieldlabel='Define the role hierarchy and set permissions for the role' where labelbol='LBL_ROLE_DESCRIPTION' and languagetype='en' and Labeltype='fixedstr';
update ld_desk set Fieldlabel='Manage different departments of company ' where labelbol='LBL_GROUP_DESCRIPTION' and languagetype='en' and Labeltype='fixedstr';
update ld_desk set Fieldlabel='Setting system module being open or closed' where labelbol='VTLIB_LBL_MODULE_MANAGER_DESCRIPTION' and languagetype='en' and Labeltype='fixedstr';
update ld_desk set Fieldlabel='Setting the dependence between field type drop-down select in each module.' where labelbol='LBL_PICKLIST_DEPENDENCY_DESCRIPTION' and languagetype='en' and Labeltype='fixedstr';
update ld_desk set Fieldlabel='Manage module of email template' where labelbol='LBL_EMAIL_TEMPLATE_DESCRIPTION' and languagetype='en' and Labeltype='fixedstr';
update ld_desk set Fieldlabel='Manage the template using by mail merge' where labelbol='LBL_MAIL_MERGE_DESCRIPTION' and languagetype='en' and Labeltype='fixedstr';
update ld_desk set Fieldlabel='Warning information of important operations management' where labelbol='LBL_NOTIF_SCHED_DESCRIPTION' and languagetype='en' and Labeltype='fixedstr';
update ld_desk set Fieldlabel='Configure the mail server information' where labelbol='LBL_MAIL_SERVER_DESCRIPTION' and languagetype='en' and Labeltype='fixedstr';
update ld_desk set Fieldlabel='Manage different types of taxes and tax rates' where labelbol='LBL_TAX_DESCRIPTION' and languagetype='en' and Labeltype='fixedstr';
update ld_desk set Fieldlabel='Manage the rolling notice displaying in all top of the page ' where labelbol='LBL_ANNOUNCEMENT_DESCRIPTION' and languagetype='en' and Labeltype='fixedstr';
update ld_desk set Fieldlabel='Setting the related module display style' where labelbol='LBL_DEFAULT_MODULE_VIEW_DESC' and languagetype='en' and Labeltype='fixedstr';
update ld_desk set Fieldlabel='Specify the terms and conditions of quotations, invoices and orders' where labelbol='LBL_INV_TANDC_DESCRIPTION' and languagetype='en' and Labeltype='fixedstr';
update ld_desk set Fieldlabel='Customize the record item number of each module' where labelbol='LBL_CUSTOMIZE_MODENT_NUMBER_DESCRIPTION' and languagetype='en' and Labeltype='fixedstr';
update ld_desk set Fieldlabel='Allow you to configure customer Portal plug-in' where labelbol='PORTAL_EXTENSION_DESCRIPTION' and languagetype='en' and Labeltype='fixedstr';
update ld_desk set Fieldlabel='Add formula for the custom field' where labelbol='LBL_FIELDFORMULAS_DESCRIPTION' and languagetype='en' and Labeltype='fixedstr';
update ld_desk set Fieldlabel='Manage the component template of home page, set the template associated roles' where labelbol='LBL_TEMPLATES_DESCRIPTION' and languagetype='en' and Labeltype='fixedstr';
update ld_desk set Fieldlabel='Set the account information of data interface' where labelbol='LBL_SETTING_DATAINTERFACE_DEMOINFO' and languagetype='en' and Labeltype='fixedstr';
update ld_desk set Fieldlabel='Set daily/weekly/monthly submission time' where labelbol='LBL_REMIND_SET_DESCRIPTION' and languagetype='en' and Labeltype='fixedstr';
update ld_desk set Fieldlabel='Config the message account' where labelbol='LBL_SMS_DESCRIPTION' and languagetype='en' and Labeltype='fixedstr';
update ld_desk set Fieldlabel='Customise product related field in orders, invoices and other module products list' where labelbol='LBL_RELATED_PARAMETERS_DESCRIPTION' and languagetype='en' and Labeltype='fixedstr';
update ld_desk set Fieldlabel='Customise fields displaying in more information while the modules are associated' where labelbol='LBL_RELATED_RELATEDLIST_DESCRIPTION' and languagetype='en' and Labeltype='fixedstr';
update ld_desk set Fieldlabel='Manage the page layout of modules, definite formula for custom field ' where labelbol='LBL_PAGE_SET_DESCRIPTION' and languagetype='en' and Labeltype='fixedstr';
update ld_desk set Fieldlabel='Customise the name and the display order of main menu and its sub-modules' where labelbol='LBL_TABLIST_DESCRIPTION' and languagetype='en' and Labeltype='fixedstr';
update ld_desk set Fieldlabel='Backup account manually' where labelbol='LBL_BACKUP_SET_DESCRIPTION' and languagetype='en' and Labeltype='fixedstr';
update ld_desk set Fieldlabel='Customise custom fields in orders, invoices and other module products list' where labelbol='LBL_ProductTool_Description' and languagetype='en' and Labeltype='fixedstr';
update ld_desk set Fieldlabel='View the upper and lower customer' where labelbol='LBL_SHOW_ACCOUNT_HIERARCHY' and languagetype='en' and Labeltype='fixedstr';
update ld_desk set Fieldlabel='Note: The date of today will vary with the editor, only as a reference when writing summary' where labelbol='EDITORISREFERENCE' and languagetype='en' and Labeltype='fixedstr';
update ld_desk set Fieldlabel="View today's program, write summary of today" where labelbol='VIEWTODAYPROGRAMWRITESUMMARY' and languagetype='en' and Labeltype='fixedstr';
update ld_desk set Fieldlabel='Have paid' where labelbol='HAVETOPAY' and languagetype='en' and Labeltype='fixedstr';
update ld_desk set Fieldlabel='Creater' where labelbol='Person_in_charge' and languagetype='en' and Labeltype='fixedstr';
update ld_desk set Fieldlabel='Next week plan' where labelbol='Plan_next_week' and languagetype='en' and Labeltype='fixedstr';
update ld_desk set Fieldlabel='Planing' where labelbol='Plan' and languagetype='en' and Labeltype='fixedstr';
update ld_desk set Fieldlabel='Quickly browse all day daily' where labelbol='QUICKVIEW' and languagetype='en' and Labeltype='fixedstr';
update ld_desk set Fieldlabel='Next month plan' where labelbol='Plan_next_month' and languagetype='en' and Labeltype='fixedstr';
update ld_desk set Fieldlabel="This week's action and daily reference" where labelbol='ACTIONandDAILY' and languagetype='en' and Labeltype='fixedstr';
update ld_desk set Fieldlabel="This month's action and daily reference" where labelbol='A_D_REFERENCXEMONTH' and languagetype='en' and Labeltype='fixedstr';
update ld_desk set Fieldlabel='The recipient Email standard format' where labelbol='Email_standard_format_recipient' and languagetype='en' and Labeltype='fixedstr';
update ld_desk set Fieldlabel='Mass mail,using newline to interval,such as' where labelbol='Bulk_mail_newline_interval_such_as' and languagetype='en' and Labeltype='fixedstr';
update ld_desk set Fieldlabel='Before massing, please set the SMTP server in the control panel' where labelbol='Before_sending_please_go_to_SMTP' and languagetype='en' and Labeltype='fixedstr';
update ld_desk set Fieldlabel='Before massing, please send it to yourself to test' where labelbol='send_yourself_test' and languagetype='en' and Labeltype='fixedstr';
update ld_desk set Fieldlabel='Max number of files is 6' where labelbol='Up_to_six_the_number_of_files' and languagetype='en' and Labeltype='fixedstr';
update ld_desk set Fieldlabel='Usage prompt' where labelbol='Usage_Tips' and languagetype='en' and Labeltype='fixedstr';
update ld_desk set Fieldlabel='When group sending text messages, change line spacing for each customer, such as' where labelbol='GroupsWhensendingtextmessages' and languagetype='en' and Labeltype='fixedstr';
update ld_desk set Fieldlabel='Select the group, you can add the customers of packet to the recipient mobile phone' where labelbol='Selectthegroup' and languagetype='en' and Labeltype='fixedstr';
update ld_desk set Fieldlabel='If no packet you need, you can create a new gpacket by yourself' where labelbol='createanewgrouping' and languagetype='en' and Labeltype='fixedstr';
update ld_desk set Fieldlabel='Before massing, please set the communications account in the control panel' where labelbol='settingscommunicationsaccountthemselves' and languagetype='en' and Labeltype='fixedstr';
update ld_desk set Fieldlabel='The space, alphanumeric and Chinese characters are all a word' where labelbol='Acaswaw' and languagetype='en' and Labeltype='fixedstr';
update ld_desk set Fieldlabel='One cell phone number per line' where labelbol='EACH_LINE_A_NUMBER' and languagetype='en' and Labeltype='fixedstr';
update ld_desk set Fieldlabel='To view a user daily summary' where labelbol='Users_view_daily_summary' and languagetype='en' and Labeltype='fixedstr';
update ld_desk set Fieldlabel='Note: The date of not writing Daily do not Show below' where labelbol='DATE_NOT_WRITE_DAILY_SHOW' and languagetype='en' and Labeltype='fixedstr';
update ld_desk set Fieldlabel='After a year' where labelbol='year_later' and languagetype='en' and Labeltype='fixedstr';
update ld_desk set Fieldlabel='Display in the home key view' where labelbol='DISPLAYINHOME' and languagetype='en' and Labeltype='fixedstr';
update ld_desk set Fieldlabel='Advanced query' where labelbol='Advanced_Search' and languagetype='en' and Labeltype='fixedstr';
update ld_desk set Fieldlabel='Lookup field' where labelbol='Find_field' and languagetype='en' and Labeltype='fixedstr';
update ld_desk set Fieldlabel='Search keyword ' where labelbol='Find_Keyword' and languagetype='en' and Labeltype='fixedstr';
update ld_desk set Fieldlabel='This fiscal year' where labelbol='thisfy' and languagetype='en' and Labeltype='fixedstr';
update ld_desk set Fieldlabel='This quarter' where labelbol='thisfq' and languagetype='en' and Labeltype='fixedstr';
update ld_desk set Fieldlabel='Next quarter' where labelbol='nextfq' and languagetype='en' and Labeltype='fixedstr';
-- update ld_desk set Fieldlabel='' where labelbol='TIPS_SHARED' and languagetype='en' and Labeltype='fixedstr';
update ld_desk set Fieldlabel='Data for all people' where labelbol='DATAFORALL' and languagetype='en' and Labeltype='fixedstr';
update ld_desk set Fieldlabel='The modifier' where labelbol='LBL_CHANGED_BY' and languagetype='en' and Labeltype='fixedstr';
update ld_desk set Fieldlabel='Turn to ordinary' where labelbol='TURNORDINARY' and languagetype='en' and Labeltype='fixedstr';
update ld_desk set Fieldlabel='Turn to the high seas ' where labelbol='TURNHIGHSEAS' and languagetype='en' and Labeltype='fixedstr';
update ld_desk set Fieldlabel='Top 5' where labelbol='LASTFINE' and languagetype='en' and Labeltype='fixedstr';
update ld_desk set Fieldlabel='I added' where labelbol='MINEADD' and languagetype='en' and Labeltype='fixedstr';
update ld_desk set Fieldlabel='End returning goods' where labelbol='ENDRETURNGOODS' and languagetype='en' and Labeltype='fixedstr';
update ld_desk set Fieldlabel='Batch modify' where labelbol='MASSEDIT' and languagetype='en' and Labeltype='fixedstr';
update ld_desk set Fieldlabel='Modify the head' where labelbol='MODFIEDASSIGNEDTO' and languagetype='en' and Labeltype='fixedstr';
update ld_desk set Fieldlabel='the high seas ' where labelbol='PUBLICCUSTOMER' and languagetype='en' and Labeltype='fixedstr';
update ld_desk set Fieldlabel='User management' where labelbol='PERSONALSETTINGS' and languagetype='en' and Labeltype='fixedstr';
update ld_desk set Fieldlabel='Head distribution statistics' where labelbol='CUSTOMERCHARGE' and languagetype='en' and Labeltype='fixedstr';
update ld_desk set Fieldlabel='Receivables/person in charge distribution statistics' where labelbol='RECEIVECHARGE' and languagetype='en' and Labeltype='fixedstr';
update ld_desk set Fieldlabel='person in charge of number/ monthly statistics' where labelbol='CONTACTRECORDSQUANTITY' and languagetype='en' and Labeltype='fixedstr';
update ld_desk set Fieldlabel='Head distribution statistics' where labelbol='CHARGEDISTRIBUTION' and languagetype='en' and Labeltype='fixedstr';
update ld_desk set Fieldlabel='Each warehouse inventory initialization operations allowed only to execute one time' where labelbol='EACHWAREHOUSEINVENTORYINIT' and languagetype='en' and Labeltype='fixedstr';
update ld_desk set Fieldlabel='This Year' where labelbol='CURYEAR' and languagetype='en' and Labeltype='fixedstr';
update ld_desk set Fieldlabel='Daily/monthly/yearly' where labelbol='DAILYWEEKMONTH' and languagetype='en' and Labeltype='fixedstr';
update ld_desk set Fieldlabel='Payable / receivable summary' where labelbol='RECEIVESUMMARY' and languagetype='en' and Labeltype='fixedstr';
update ld_desk set Fieldlabel='Over the past 7 Days schedule' where labelbol='OVERSERVENDAYSSCHEDULE' and languagetype='en' and Labeltype='fixedstr';
update ld_desk set Fieldlabel='The next 7 days schedule' where labelbol='FUTURESEVENDAYSSCHEDULE' and languagetype='en' and Labeltype='fixedstr';
update ld_desk set Fieldlabel='Submission case' where labelbol='SUBMITSSION' and languagetype='en' and Labeltype='fixedstr';
update ld_desk set Fieldlabel='Head distribution statistics' where labelbol='MARKETCHARTDIS' and languagetype='en' and Labeltype='fixedstr';
update ld_desk set Fieldlabel='Head distribution statistics+D205:D237' where labelbol='PAYMENTCHARGE' and languagetype='en' and Labeltype='fixedstr';
update ld_desk set Fieldlabel='Head distribution statistics' where labelbol='SENDPAYMENTCHARGE' and languagetype='en' and Labeltype='fixedstr';
update ld_desk set Fieldlabel='Head distribution statistics' where labelbol='CALENDARCHARGE' and languagetype='en' and Labeltype='fixedstr';
update ld_desk set Fieldlabel="User can read only other users' data" where labelbol='LBL_DESCRIPTION_Public: Read Only' and languagetype='en' and Labeltype='fixedstr';
update ld_desk set Fieldlabel="User can read, create/edit other users' data" where labelbol='LBL_DESCRIPTION_Public: Read, Create/Edit' and languagetype='en' and Labeltype='fixedstr';
update ld_desk set Fieldlabel="User can read, create/edit, delete other user' data" where labelbol='LBL_DESCRIPTION_Public: Read, Create/Edit, Delete' and languagetype='en' and Labeltype='fixedstr';
update ld_desk set Fieldlabel='Does not contain a disabled user' where labelbol='NOTCONTAINUSER' and languagetype='en' and Labeltype='fixedstr';
update ld_desk set Fieldlabel="Don't limit the number of users" where labelbol='NOTLIMITUSERS' and languagetype='en' and Labeltype='fixedstr';
update ld_desk set Fieldlabel='Organization structure - the list of roles' where labelbol='ROLESHIERARCHY' and languagetype='en' and Labeltype='fixedstr';
update ld_desk set Fieldlabel="Roles are used to define modules which can have the operating authority in the system,role hierarchy relationship can be regarded as the company's organizational structure." where labelbol='ROLEUSEDDEFINEMODULE' and languagetype='en' and Labeltype='fixedstr';
update ld_desk set Fieldlabel='Modules permissions can be controlled through role , you can add, edit, view and delete records module.' where labelbol='ROLESCONTROLLEDMODULESBUTTON' and languagetype='en' and Labeltype='fixedstr';
update ld_desk set Fieldlabel='Fields permissions can be controlled by role , you can be read only and edit values of module field. ' where labelbol='ROLESCONTROLLEDMODULESFIELDS' and languagetype='en' and Labeltype='fixedstr';
update ld_desk set Fieldlabel="Subordinate superiors can view and edit Subordinate records, subordinates can not view and edit  superior's records, between siblings can not see each other." where labelbol='SUPERCANVIEWSUBORDINATEDATA' and languagetype='en' and Labeltype='fixedstr';
update ld_desk set Fieldlabel='Use help' where labelbol='HELP' and languagetype='en' and Labeltype='fixedstr';
update ld_desk set Fieldlabel='Control panel' where labelbol='CONTROLPANEL' and languagetype='en' and Labeltype='fixedstr';
update ld_desk set Fieldlabel='Edit rules' where labelbol='EDITPERMISSION' and languagetype='en' and Labeltype='fixedstr';
update ld_desk set Fieldlabel='The field in the global field permissions settings are disabled.' where labelbol='FIELDISABLEDGLOBAL' and languagetype='en' and Labeltype='fixedstr';
update ld_desk set Fieldlabel='The role of needing to be moved' where labelbol='NEEDMOVEROLE' and languagetype='en' and Labeltype='fixedstr';
update ld_desk set Fieldlabel='The role of after being mobiled designatly' where labelbol='MOVEDSUPERROLE' and languagetype='en' and Labeltype='fixedstr';
update ld_desk set Fieldlabel='If not passed, then return head' where labelbol='NOTPASSRETURNCHARGE' and languagetype='en' and Labeltype='fixedstr';
update ld_desk set Fieldlabel='Pass and continue to the next step' where labelbol='CONTINUEAPPROVALSTEP' and languagetype='en' and Labeltype='fixedstr';
update ld_desk set Fieldlabel='Allow to end the approval process' where labelbol='APPROVALENDPROCESS' and languagetype='en' and Labeltype='fixedstr';
update ld_desk set Fieldlabel='Whether to allow to end the approval process' where labelbol='WHETHERAPPROVALPROCESS' and languagetype='en' and Labeltype='fixedstr';
update ld_desk set Fieldlabel='Whether to allow to specify the approval procedure' where labelbol='WHETHERAPPROVALSTEP' and languagetype='en' and Labeltype='fixedstr';
update ld_desk set Fieldlabel='The hign seas customer can see the high seas in the customer order book and receive high seas customer' where labelbol='USERSPUBLICCUSTOMER' and languagetype='en' and Labeltype='fixedstr';
update ld_desk set Fieldlabel='The hign seas customers settings' where labelbol='PUBLICUSERSET' and languagetype='en' and Labeltype='fixedstr';
update ld_desk set Fieldlabel='The hign seas customers administrator has the authority to assign the high seas customers, convert the high seas customersSeas customers,extend the high Seas customers period' where labelbol='EXTENDPUBLICCUSTOMER' and languagetype='en' and Labeltype='fixedstr';
update ld_desk set Fieldlabel='The hign seas customers administrator setting' where labelbol='SETPUBLICCUSTOMERADMIN' and languagetype='en' and Labeltype='fixedstr';
update ld_desk set Fieldlabel='Limit the number of the hign seas customers each user can use or be assigned' where labelbol='LIMITUSERPUBLICCUST' and languagetype='en' and Labeltype='fixedstr';
update ld_desk set Fieldlabel='Since the hign seas customers is assigned or used' where labelbol='DATEPUBLICCUSTOMER' and languagetype='en' and Labeltype='fixedstr';
update ld_desk set Fieldlabel='Put the hign seas customers use or assign to some sales,each sales can only have a number of the high seas customers, and limit must reach the setting conditions within the time, otherwise the client will automatically return to the high seas and be reallocated to other sales.' where labelbol='CUSTOMERSALESFULFILLED' and languagetype='en' and Labeltype='fixedstr';
update ld_desk set Fieldlabel='The high seas permissions:including the high seas administrator,the hign seas customers' where labelbol='PUBLICCUSTOMERPRIVILEGEINCLUDE' and languagetype='en' and Labeltype='fixedstr';
update ld_desk set Fieldlabel='Daily submission time' where labelbol='DAILYDEADLINE' and languagetype='en' and Labeltype='fixedstr';
update ld_desk set Fieldlabel='begins 1 hour earlier till 23:59 of this day,remind in the workbench' where labelbol='ONEAHREAREMIND' and languagetype='en' and Labeltype='fixedstr';
update ld_desk set Fieldlabel='Weekly submission time' where labelbol='WEEKLYDEADLINE' and languagetype='en' and Labeltype='fixedstr';
update ld_desk set Fieldlabel='begins 1 day earlier till last day of this week,remind in the workbench' where labelbol='ONEAHEADWEEK' and languagetype='en' and Labeltype='fixedstr';
update ld_desk set Fieldlabel='Monthly submission time' where labelbol='MONTHLYDEADLINE' and languagetype='en' and Labeltype='fixedstr';
update ld_desk set Fieldlabel='begins 3 day earlier,remind in the workbench' where labelbol='THREEDAYSREMIND' and languagetype='en' and Labeltype='fixedstr';
update ld_desk set Fieldlabel='The selected user can initialize the library inventory,warehousing,storage,inventory,allocation between libraries and other operations,the system administrator or global,users automatically have this permission' where labelbol='SELECTUSERWAREHOUSE' and languagetype='en' and Labeltype='fixedstr';
update ld_desk set Fieldlabel='The login verification code' where labelbol='ENABLELOGINVERIFYCODE' and languagetype='en' and Labeltype='fixedstr';
update ld_desk set Fieldlabel='Existing the drop-down option' where labelbol='EXISTINGPICKLISTVALUE' and languagetype='en' and Labeltype='fixedstr';
update ld_desk set Fieldlabel='Enter the new entries,one per line' where labelbol='ONEBYONEBELOW' and languagetype='en' and Labeltype='fixedstr';
update ld_desk set Fieldlabel='Non Editable drop-down option' where labelbol='NONPICKLISTVALUE' and languagetype='en' and Labeltype='fixedstr';
update ld_desk set Fieldlabel='Select the roles which still need to add the role of the project' where labelbol='SELECTPICKLISTROLESENTRIES' and languagetype='en' and Labeltype='fixedstr';
update ld_desk set Fieldlabel='Add the drop-down option' where labelbol='ADDPICKLISTVALUE' and languagetype='en' and Labeltype='fixedstr';
update ld_desk set Fieldlabel='Assign the drop-down option' where labelbol='ASSINGPICKLISTVALUE' and languagetype='en' and Labeltype='fixedstr';
update ld_desk set Fieldlabel='The available drop-down option' where labelbol='AVAILPICKLISTVALUE' and languagetype='en' and Labeltype='fixedstr';
update ld_desk set Fieldlabel='Assign picklist values for role' where labelbol='ASSIGNROLEPICKLIST' and languagetype='en' and Labeltype='fixedstr';
update ld_desk set Fieldlabel='Assign the drop-down option for other role' where labelbol='ADDOTHERROLEPICK' and languagetype='en' and Labeltype='fixedstr';
update ld_desk set Fieldlabel='Delete the drop-down option' where labelbol='DELETEPICKLISTVALUE' and languagetype='en' and Labeltype='fixedstr';
update ld_desk set Fieldlabel='Replace with the following drop-down option' where labelbol='REPLACEWITHPICKLIST' and languagetype='en' and Labeltype='fixedstr';
update ld_desk set Fieldlabel='Non-editable drop-down option' where labelbol='NONEDITABLEVALUES' and languagetype='en' and Labeltype='fixedstr';
update ld_desk set Fieldlabel='Edit the drop-down option' where labelbol='EDITPICKLISTVALUE' and languagetype='en' and Labeltype='fixedstr';
update ld_desk set Fieldlabel='Select the drop-down option' where labelbol='SELECTPICKLIST' and languagetype='en' and Labeltype='fixedstr';
update ld_desk set Fieldlabel='The drop-down box' where labelbol='PICKLISTAVAIL' and languagetype='en' and Labeltype='fixedstr';
update ld_desk set Fieldlabel='All assigned the drop-down option for the role are shown below' where labelbol='ALLROLEBELOWPICK' and languagetype='en' and Labeltype='fixedstr';
update ld_desk set Fieldlabel='Assign the drop-down option' where labelbol='ASSIGNPICKLIST' and languagetype='en' and Labeltype='fixedstr';
update ld_desk set Fieldlabel='The higner field' where labelbol='SOURCEFIELD' and languagetype='en' and Labeltype='fixedstr';
update ld_desk set Fieldlabel='The lower field' where labelbol='TARGETFIELD' and languagetype='en' and Labeltype='fixedstr';
update ld_desk set Fieldlabel='Only the source field mapping selection list value will be shown below (except for the first time)' where labelbol='ONLYMAPPEDPICKLIST' and languagetype='en' and Labeltype='fixedstr';
update ld_desk set Fieldlabel="If you want to view or change  the mapping of other options list value of the source field,you can choose to click through the value <b>'select the source value'</b> on the right side of the button" where labelbol='WANTSEEMAPPICKLIST' and languagetype='en' and Labeltype='fixedstr';
update ld_desk set Fieldlabel='Main menu' where labelbol='PARENTMENU' and languagetype='en' and Labeltype='fixedstr';
update ld_desk set Fieldlabel="Customize the main menu and its sub-module's name displayed order" where labelbol='CUSTOMPARENTMENU' and languagetype='en' and Labeltype='fixedstr';
update ld_desk set Fieldlabel='Main menu name' where labelbol='PARENTMENUNAME' and languagetype='en' and Labeltype='fixedstr';
update ld_desk set Fieldlabel='Update the missing number immediately' where labelbol='UPDATEMISSINGRECORD' and languagetype='en' and Labeltype='fixedstr';
update ld_desk set Fieldlabel='Start number' where labelbol='STARTSEQ' and languagetype='en' and Labeltype='fixedstr';
update ld_desk set Fieldlabel='Login record' where labelbol='LOGINHISTORY' and languagetype='en' and Labeltype='fixedstr';
update ld_desk set Fieldlabel='Currency symbol' where labelbol='CURRENCYSYMBOL' and languagetype='en' and Labeltype='fixedstr';
update ld_desk set Fieldlabel='Manage currencies and exchange conversion rate' where labelbol='LBL_CURRENCY_DESCRIPTION' and languagetype='en' and Labeltype='fixedstr';
update ld_desk set Fieldlabel="Transfer user's currency to" where labelbol='TRANCURRENCYTO' and languagetype='en' and Labeltype='fixedstr';
update ld_desk set Fieldlabel='Basic Currency -' where labelbol='BASECURRENCY' and languagetype='en' and Labeltype='fixedstr';
update ld_desk set Fieldlabel='Freight and logistics surcharge tax' where labelbol='SHIPTAX' and languagetype='en' and Labeltype='fixedstr';
update ld_desk set Fieldlabel='Are you sure that you want to change the server details of defaulted server values' where labelbol='SUREMAILSERVERDEFAULT' and languagetype='en' and Labeltype='fixedstr';
update ld_desk set Fieldlabel='The server details have already been setted to the default values' where labelbol='HAVEMAILSEVERDEFAULT' and languagetype='en' and Labeltype='fixedstr';
update ld_desk set Fieldlabel='SMTP server' where labelbol='MAILSERVERNAME' and languagetype='en' and Labeltype='fixedstr';
update ld_desk set Fieldlabel='Email address' where labelbol='FROMEMAIL' and languagetype='en' and Labeltype='fixedstr';
update ld_desk set Fieldlabel='Unit price' where labelbol='LISTPRICE' and languagetype='en' and Labeltype='fixedstr';
update ld_desk set Fieldlabel='Tax amount' where labelbol='NETPRICE' and languagetype='en' and Labeltype='fixedstr';
update ld_desk set Fieldlabel='Discount amount' where labelbol='TOALAFTERDIS' and languagetype='en' and Labeltype='fixedstr';
update ld_desk set Fieldlabel='Subtotal' where labelbol='NETTOTAL' and languagetype='en' and Labeltype='fixedstr';
update ld_desk set Fieldlabel='Tax type' where labelbol='TAXMODE' and languagetype='en' and Labeltype='fixedstr';
update ld_desk set Fieldlabel='The definition x discount:' where labelbol='SETDISCOUNTX' and languagetype='en' and Labeltype='fixedstr';
update ld_desk set Fieldlabel='Direct Reduction' where labelbol='DIRECTPRICE' and languagetype='en' and Labeltype='fixedstr';
update ld_desk set Fieldlabel='Sharing ways can select from the selected user the list and click the Add button' where labelbol='ADDSHARESCHEDULESELECTEDUSERS' and languagetype='en' and Labeltype='fixedstr';
update ld_desk set Fieldlabel='Export to DOC format' where labelbol='ExporttoPDF' and languagetype='en' and Labeltype='fixedstr';
update ld_desk set Fieldlabel='Send Email Adding attachments' where labelbol='Send_Email_Add_PDF' and languagetype='en' and Labeltype='fixedstr';
update ld_desk set Fieldlabel='Please choose mobile phones what you want to send text messages to ' where labelbol='PCWYWTSTMTMP' and languagetype='en' and Labeltype='fixedstr';
update ld_desk set Fieldlabel='Please choose Email what you want to send e-mail to ' where labelbol='PCWYWTSETE' and languagetype='en' and Labeltype='fixedstr';
update ld_desk set Fieldlabel='Pending approval' where labelbol='Pending_approval' and languagetype='en' and Labeltype='fixedstr';
update ld_desk set Fieldlabel='Approved' where labelbol='Approved' and languagetype='en' and Labeltype='fixedstr';
update ld_desk set Fieldlabel='Document Number' where labelbol='DocumentNumber' and languagetype='en' and Labeltype='fixedstr';
update ld_desk set Fieldlabel='Not allowed to repeat' where labelbol='Allowed_to_repeat' and languagetype='en' and Labeltype='fixedstr';
update ld_desk set Fieldlabel='The drop-down box' where labelbol='PickList' and languagetype='en' and Labeltype='fixedstr';
update ld_desk set Fieldlabel='Checkbox' where labelbol='SELECT_COMBO' and languagetype='en' and Labeltype='fixedstr';
update ld_desk set Fieldlabel='User defined fields' where labelbol='Add_custom_fields' and languagetype='en' and Labeltype='fixedstr';
update ld_desk set Fieldlabel='find the order need to return in the book orders firstly,view the operator interface and click the right button handle "return" in the order' where labelbol='wsfftntroboiotstroictbhrt' and languagetype='en' and Labeltype='fixedstr';
update ld_desk set Fieldlabel='Only orders have out of the library are allowed to handle returns' where labelbol='oohbaootlhr' and languagetype='en' and Labeltype='fixedstr';
update ld_desk set Fieldlabel='After the return,to edit and delete returns are not allowed ' where labelbol='ATRINATRASEAD' and languagetype='en' and Labeltype='fixedstr';
update ld_desk set Fieldlabel='After the execution,the return of single state is set to"end"' where labelbol='ATERASSISTE' and languagetype='en' and Labeltype='fixedstr';
update ld_desk set Fieldlabel='You can click on the link below,add a record' where labelbol='CLICKLINKBELOW' and languagetype='en' and Labeltype='fixedstr';
update ld_desk set Fieldlabel='You have insufficient privileges,not any warehouse operation' where labelbol='INSUFFICIENTWAREHOUSE' and languagetype='en' and Labeltype='fixedstr';
update ld_desk set Fieldlabel='The first:entrying manually the initial number of the product' where labelbol='INITPRODUCTMANUAL' and languagetype='en' and Labeltype='fixedstr';
update ld_desk set Fieldlabel='The second: Exporting initial inventory form, import after editing inventory' where labelbol='EXPORTINITPRODUCT' and languagetype='en' and Labeltype='fixedstr';
update ld_desk set Fieldlabel='Should initialize the warehouse product inventory first, and then to storage, a library, library room allocation, inventory and other business operations.' where labelbol='SHOULDINITWAREINVENTORY' and languagetype='en' and Labeltype='fixedstr';
update ld_desk set Fieldlabel='Ledger contains the inventory records' where labelbol='LEDGERCONTAININVEN' and languagetype='en' and Labeltype='fixedstr';
update ld_desk set Fieldlabel='Related objects' where labelbol='RELATEDTO' and languagetype='en' and Labeltype='fixedstr';
update ld_desk set Fieldlabel='Automatic generation of No.' where labelbol='MSG_AUTO_GEN_ON_SAVE' and languagetype='en' and Labeltype='fixedstr';
update ld_desk set Fieldlabel='Select all' where labelbol='ALLSELECT' and languagetype='en' and Labeltype='fixedstr';
update ld_desk set Fieldlabel='Clear all' where labelbol='SELECTCANCEL' and languagetype='en' and Labeltype='fixedstr';
update ld_desk set Fieldlabel='Save Email field is empty can prohibit portal access!' where labelbol='SAVEEMPTYEMAILCANPROHIBITACCESS' and languagetype='en' and Labeltype='fixedstr';
update ld_desk set Fieldlabel='Query conditions' where labelbol='QUERY' and languagetype='en' and Labeltype='fixedstr';
update ld_desk set Fieldlabel='find duplicate records' where labelbol='FINDDUPLICATERECORDS' and languagetype='en' and Labeltype='fixedstr';
update ld_desk set Fieldlabel='Invitation of the way can select from the list of users and click the Add button' where labelbol='INVITEMENTHODUSER' and languagetype='en' and Labeltype='fixedstr';
update ld_desk set Fieldlabel='deletion of the way can select from the list of users and click the delete button' where labelbol='REMOVEINVITEUSER' and languagetype='en' and Labeltype='fixedstr';
update ld_desk set Fieldlabel="The selected file don't have data or be valid file" where labelbol='DOCNOINVALID' and languagetype='en' and Labeltype='fixedstr';
update ld_desk set Fieldlabel='Maximum number of filesb is 6,' where labelbol='MAXFILESSIX' and languagetype='en' and Labeltype='fixedstr';
update ld_desk set Fieldlabel='There is no available modules' where labelbol='NOMODULEAVAIL' and languagetype='en' and Labeltype='fixedstr';
update ld_desk set Fieldlabel='Not found' where labelbol='NORECORDSRESTORE' and languagetype='en' and Labeltype='fixedstr';
update ld_desk set Fieldlabel='Planned collection start date' where labelbol='PLANDSTARTDATE' and languagetype='en' and Labeltype='fixedstr';
update ld_desk set Fieldlabel='Set the {$PaymentPlan.PaymentPlan} default time and payment proportion' where labelbol='SETPAYPERCENT' and languagetype='en' and Labeltype='fixedstr';
update ld_desk set Fieldlabel='Open a new' where labelbol='CREATEOPEN' and languagetype='en' and Labeltype='fixedstr';
update ld_desk set Fieldlabel='After the confirmation,periodnumber will automatically be created to 1{Var},the amount is the amount of orders' where labelbol='ONCEAUTOPERIODONEPAY' and languagetype='en' and Labeltype='fixedstr';
update ld_desk set Fieldlabel='Invalid Profile Id. Please specify a limited Profile Id' where labelbol='INVALIDPROFILEID' and languagetype='en' and Labeltype='fixedstr';
update ld_desk set Fieldlabel='Add Custom sharing Rule' where labelbol='ADDCUSTOMRULE' and languagetype='en' and Labeltype='fixedstr';
update ld_desk set Fieldlabel='staff range ' where labelbol='RANGESTAFF' and languagetype='en' and Labeltype='fixedstr';
update ld_desk set Fieldlabel='The signing amount of billboard' where labelbol='Contractamount' and languagetype='en' and Labeltype='fixedstr';
update ld_desk set Fieldlabel='The uploaded file is not the format of (.Gif/.jpg/.png)' where labelbol='GIVENFILEJPG' and languagetype='en' and Labeltype='fixedstr';
update ld_desk set Fieldlabel='Select the matching field to find duplicate records' where labelbol='STFTFTMDR' and languagetype='en' and Labeltype='fixedstr';
update ld_desk set Fieldlabel='Select this option to enable and set Merger guidelines of duplicate items' where labelbol='STOTEASTCFDM' and languagetype='en' and Labeltype='fixedstr';
update ld_desk set Fieldlabel='Put the column mapp to the module field' where labelbol='TCMFTMF' and languagetype='en' and Labeltype='fixedstr';
update ld_desk set Fieldlabel='List' where labelbol='Row' and languagetype='en' and Labeltype='fixedstr';
update ld_desk set Fieldlabel='Save as custom mapping table' where labelbol='AACMT' and languagetype='en' and Labeltype='fixedstr';
update ld_desk set Fieldlabel='Operating' where labelbol='Operation' and languagetype='en' and Labeltype='fixedstr';
update ld_desk set Fieldlabel='Total number of imported records' where labelbol='LBL_TOTAL_RECORDS_IMPORTED' and languagetype='en' and Labeltype='fixedstr';
update ld_desk set Fieldlabel='Create the record number' where labelbol='LBL_NUMBER_OF_RECORDS_CREATED' and languagetype='en' and Labeltype='fixedstr';
update ld_desk set Fieldlabel='Skip the record number' where labelbol='LBL_NUMBER_OF_RECORDS_SKIPPED' and languagetype='en' and Labeltype='fixedstr';
update ld_desk set Fieldlabel='Cover the record number' where labelbol='LBL_NUMBER_OF_RECORDS_UPDATED' and languagetype='en' and Labeltype='fixedstr';
update ld_desk set Fieldlabel='Total number of failure records' where labelbol='LBL_TOTAL_RECORDS_FAILED' and languagetype='en' and Labeltype='fixedstr';
update ld_desk set Fieldlabel='Last import record' where labelbol='LBL_VIEW_LAST_IMPORTED_RECORDS' and languagetype='en' and Labeltype='fixedstr';
update ld_desk set Fieldlabel='Select the server type' where labelbol='JSLBL_Choose_Server_Type' and languagetype='en' and Labeltype='fixedstr';
update ld_desk set Fieldlabel='Select the account type' where labelbol='LBL_SELECT_ACCOUNT_TYPE' and languagetype='en' and Labeltype='fixedstr';
update ld_desk set Fieldlabel="Don't verify certificate" where labelbol='LBL_Do_Not_Validate_Cert' and languagetype='en' and Labeltype='fixedstr';
update ld_desk set Fieldlabel='Your incoming mail server is not set' where labelbol='LBL_CONFIGURE_MAIL_SETTINGS' and languagetype='en' and Labeltype='fixedstr';
update ld_desk set Fieldlabel='The mail folder' where labelbol='LBL_EMAIL_FOLDERS' and languagetype='en' and Labeltype='fixedstr';
update ld_desk set Fieldlabel='Other e-mail account settings' where labelbol='LBL_SETTINGS' and languagetype='en' and Labeltype='fixedstr';
update ld_desk set Fieldlabel='Draft box' where labelbol='LBL_DRAFTS' and languagetype='en' and Labeltype='fixedstr';
update ld_desk set Fieldlabel='Other mailbox' where labelbol='LBL_INBOX' and languagetype='en' and Labeltype='fixedstr';
update ld_desk set Fieldlabel='Has been sent' where labelbol='LBL_SENT_MAILS' and languagetype='en' and Labeltype='fixedstr';
update ld_desk set Fieldlabel='The character to be deleted' where labelbol='TDAC' and languagetype='en' and Labeltype='fixedstr';
update ld_desk set Fieldlabel='Add formula for custom fields' where labelbol='Addingcustomfieldformula' and languagetype='en' and Labeltype='fixedstr';
update ld_desk set Fieldlabel='Convert head to the user' where labelbol='Conversion_charge_to_the_user' and languagetype='en' and Labeltype='fixedstr';
update ld_desk set Fieldlabel='Data number' where labelbol='LBL_RECORD_ID' and languagetype='en' and Labeltype='fixedstr';
update ld_desk set Fieldlabel='Extend the customer expiration time ' where labelbol='Extend_expiration_time_customers' and languagetype='en' and Labeltype='fixedstr';
update ld_desk set Fieldlabel='Distribute customer and related contacts' where labelbol='DARCC' and languagetype='en' and Labeltype='fixedstr';
update ld_desk set Fieldlabel='Tips:shared user has the query access of sales opportunities and related information' where labelbol='TQTUHTBSPSOARI' and languagetype='en' and Labeltype='fixedstr';
update ld_desk set Fieldlabel='should be equal to' where labelbol='SHOULDBEEQUAL' and languagetype='en' and Labeltype='fixedstr';
update ld_desk set Fieldlabel='You searched, but you did not choose the options of "Export-free search results" and "Export all data".' where labelbol='YOUWERESEARCHNOTCHOOSE' and languagetype='en' and Labeltype='jspop';
update ld_desk set Fieldlabel='You do not have to search, but you choose the option of "Export Search Results" and "Export this page Data" , so the current page data will be derived from' where labelbol='NOHAVESEARCHBUTCHOOSE' and languagetype='en' and Labeltype='jspop';
update ld_desk set Fieldlabel="Don't allow to edit the field!" where labelbol='FIELDDOSENOTALLOWEDIT' and languagetype='en' and Labeltype='jspop';
update ld_desk set Fieldlabel='Remind content can not be empty!' where labelbol='REMINDERSCANOTEMPTY' and languagetype='en' and Labeltype='jspop';
update ld_desk set Fieldlabel="Don't allow to edit these field!" where labelbol='ALLOWEDEDITTHESEFIELDS' and languagetype='en' and Labeltype='jspop';
update ld_desk set Fieldlabel='In order to perform successfully the backup path must be exist on the server,it needs to operate manually, the database backup results is scrip file' where labelbol='MANUALBACKUPMESSAGE' and languagetype='en' and Labeltype='fixedstr';
update ld_desk set Fieldlabel='Mode of page layout' where labelbol='PAGELAYOUTMODE' and languagetype='en' and Labeltype='fixedstr';
update ld_desk set Fieldlabel='The related module (more information) display style' where labelbol='RELATEDMODULESDISPLAYSTYLE' and languagetype='en' and Labeltype='fixedstr';
update ld_desk set Fieldlabel='Account is made of the letters, underscores and numbers' where labelbol='ACCOUNTBYTO' and languagetype='en' and Labeltype='jspop';
update ld_desk set Fieldlabel='Warm reminder' where labelbol='REMINDER' and languagetype='en' and Labeltype='fixedstr';
update ld_desk set Fieldlabel='Forced to return to submitted for approval' where labelbol='FORCEDRETURNSSUBMITAPPROVAL' and languagetype='en' and Labeltype='fixedstr';
update ld_desk set Fieldlabel='When "whether to allow to end approval process" is setted to "Yes", said: allowing the approver of the step end the whole approval process,the documents no longer continue to flow after the approval' where labelbol='ADDAPPROVALSTEPTIP1' and languagetype='en' and Labeltype='fixedstr';
update ld_desk set Fieldlabel='when "whether to allow to specify approval steps" is setted to "yes":said: allowing the approver of the step adjust the next steps' where labelbol='ADDAPPROVALSTEPTIP2' and languagetype='en' and Labeltype='fixedstr';
update ld_desk set Fieldlabel='When the "approver type" is setted to "specified user", you can select user as approver, allowing to specify multiple users by multipling choice;' where labelbol='ADDAPPROVALSTEPTIP3' and languagetype='en' and Labeltype='fixedstr';
update ld_desk set Fieldlabel='When the "approval type" is setted to "designated sponsor department user\'s level", and circulate automatically by the sponsor department and user\'s level while approvalling' where labelbol='ADDAPPROVALSTEPTIP5' and languagetype='en' and Labeltype='fixedstr';
update ld_desk set Fieldlabel='If there are multiple approval in accordance with the conditions,it says these approval all can execute approval operation,as long as one of them executive approval operation means that completed the approval procedures.' where labelbol='ADDAPPROVALSTEPTIP6' and languagetype='en' and Labeltype='fixedstr';
update ld_desk set Fieldlabel='Mail management' where labelbol='Webmails' and languagetype='en' and Labeltype='fixedstr';
update ld_desk set Fieldlabel='lower contacts' where labelbol='SUBCONTRACT' and languagetype='en' and Labeltype='fixedstr';
update ld_desk set Fieldlabel='uniform according to the adjustment factor (%) adjusted' where labelbol='ATTUAFA' and languagetype='en' and Labeltype='fixedstr';
update ld_desk set Fieldlabel='You can define complex authority mechanism by sector.A department maycontain user,role,permission etc..' where labelbol='GROUPINFO1' and languagetype='en' and Labeltype='fixedstr';
update ld_desk set Fieldlabel='Account name' where labelbol='ZHANGTAONAME' and languagetype='en' and Labeltype='fixedstr';
update ld_desk set Fieldlabel='The order interface:after the system contract order are preserved (including add and edit),it will be saved automatically to the interface set of books at the same time.' where labelbol='DATAINTERFACESTEP1' and languagetype='en' and Labeltype='fixedstr';
update ld_desk set Fieldlabel='Not found any records' where labelbol='NOTFOUNDANYRECORD' and languagetype='en' and Labeltype='fixedstr';
update ld_desk set Fieldlabel='Please change the value of the replacement, because it is about to be deleted' where labelbol='PLEASECHANGEVALUEREPLACEMENT' and languagetype='en' and Labeltype='jspop';
update ld_desk set Fieldlabel='You can not replace to null value,please using the "delete" functionthe to delete the option value' where labelbol='CANOTREPLACENULLVALUE' and languagetype='en' and Labeltype='jspop';
update ld_desk set Fieldlabel='Contracted number Billboard' where labelbol='Contractnumber' and languagetype='en' and Labeltype='fixedstr';
update ld_desk set Fieldlabel='Enable the login verification code' where labelbol='ENABLELOGINAUTHENTICATIONCODE' and languagetype='en' and Labeltype='jspop';
update ld_desk set Fieldlabel='Disable login verification code' where labelbol='DISABLELOGINAUTHENTICATIONCODE' and languagetype='en' and Labeltype='jspop';
update ld_desk set Fieldlabel='The target value set by artificial, complete value statistics automatically by the system' where labelbol='SALESGOALINSTRUCTION1' and languagetype='en' and Labeltype='fixedstr';
update ld_desk set Fieldlabel='The amount of back said receipet amount, calculated according to the date of payment. Sales amount said not invalid Sales contract amount, calculated according to the date of contract.' where labelbol='SALESGOALINSTRUCTION3' and languagetype='en' and Labeltype='fixedstr';
update ld_desk set Fieldlabel='After deleted it cannot be restored, are you sure you want to delete this record?' where labelbol='CANNOTBERESULSE' and languagetype='en' and Labeltype='jspop';
update ld_desk set Fieldlabel='The target value is setted by the artificial,the completed value is statisticed automatically by the system' where labelbol='SALESGOALINSTRUCTION4' and languagetype='en' and Labeltype='fixedstr';
update ld_desk set Fieldlabel='You can view the sales target setting and completion in the page sign of the target view,in Goal Setting tab set the sales target;monetary unit:yuan,customer number:a)' where labelbol='SALESGOALINSTRUCTION5' and languagetype='en' and Labeltype='fixedstr';
update ld_desk set Fieldlabel='Multiple recipients' where labelbol='MULTIPLEEMAIL' and languagetype='en' and Labeltype='fixedstr';
update ld_desk set Fieldlabel='The number of partial products is more than the actual number of documents, including:' where labelbol='NUMMORETHANPRODCUTS' and languagetype='en' and Labeltype='jspop';
update ld_desk set Fieldlabel='Please enter the correct adjustment' where labelbol='ENTERCORRECTADJUSTMENT' and languagetype='en' and Labeltype='jspop';
update ld_desk set Fieldlabel='Cannot choose  the product outside of source single' where labelbol='SELECTPRODUCTLINEITEM' and languagetype='en' and Labeltype='jspop';
update ld_desk set Fieldlabel='The current document is collected, do not allow to edit!' where labelbol='PLAYMENTPLANEDITLISTERROR' and languagetype='en' and Labeltype='fixedstr';
update ld_desk set Fieldlabel='The records of your choice are approved or being approved, batch deleting is not allowed!' where labelbol='EXPENCEDELETEERROR' and languagetype='en' and Labeltype='fixedstr';
update ld_desk set Fieldlabel='postpone' where labelbol='INTRODUCTIONTO' and languagetype='en' and Labeltype='fixedstr';
update ld_desk set Fieldlabel='Upper and lower levels' where labelbol='ONTHELOWERLEVEL' and languagetype='en' and Labeltype='fixedstr';
update ld_desk set Fieldlabel='Last step' where labelbol='ASTEP' and languagetype='en' and Labeltype='fixedstr';
update ld_desk set Fieldlabel='Update the responsible person' where labelbol='PERONRESPONSIBLEFORUPDATE' and languagetype='en' and Labeltype='fixedstr';
update ld_desk set Fieldlabel='Using' where labelbol='WAREHOUSEUSEING' and languagetype='en' and Labeltype='fixedstr';
update ld_desk set Fieldlabel="transfer User's money to " where labelbol='USERSTOTRANSFERMONEY' and languagetype='en' and Labeltype='fixedstr';
update ld_desk set Fieldlabel='Warm reminder' where labelbol='REMINDER' and languagetype='en' and Labeltype='jspop';
update ld_desk set Fieldlabel='Please enter the customer name to check' where labelbol='PLEASEENTERCUSTOMERNAMECHECK' and languagetype='en' and Labeltype='jspop';
update ld_desk set Fieldlabel='manage SMS templates' where labelbol='SMSTEMPLATESMANAGE' and languagetype='en' and Labeltype='fixedstr';
update ld_desk set Fieldlabel='manage email templates' where labelbol='EMAILTEMPLATESMANAGE' and languagetype='en' and Labeltype='fixedstr';
update ld_desk set Fieldlabel='The annex is the external type, can not be detected' where labelbol='ANNEXEXTERNALTYPE' and languagetype='en' and Labeltype='jspop';
update ld_desk set Fieldlabel='The modified field not allowed to view' where labelbol='MODIFIEDFIELDNOTALLOWED' and languagetype='en' and Labeltype='fixedstr';
update ld_desk set Fieldlabel='Please select at least two records' where labelbol='SELECTLEASTTWO' and languagetype='en' and Labeltype='jspop';
update ld_desk set Fieldlabel='You have to merge the records in the same groups' where labelbol='GROUPFROSAMEMERGE' and languagetype='en' and Labeltype='jspop';
update ld_desk set Fieldlabel='You are allowed to merge a maximum of three records' where labelbol='MASSELECTTHREE' and languagetype='en' and Labeltype='jspop';
update ld_desk set Fieldlabel='The record is being processed, are not allowed to be edited' where labelbol='THERECORDPROCESSEDING' and languagetype='en' and Labeltype='fixedstr';
update ld_desk set Fieldlabel='This record has been rejected for approval, are not allowed to be edited!' where labelbol='THERECORDEDITING' and languagetype='en' and Labeltype='fixedstr';
update ld_desk set Fieldlabel='The daily Summary' where labelbol='THESUMMARY' and languagetype='en' and Labeltype='fixedstr';
update ld_desk set Fieldlabel='Select at least one field' where labelbol='SELECTLEASTONEFIELD' and languagetype='en' and Labeltype='fixedstr';
update ld_desk set Fieldlabel='The record has been deleted.' where labelbol='RECORDDELETED' and languagetype='en' and Labeltype='fixedstr';
update ld_desk set Fieldlabel='Sales privilege of user' where labelbol='SALESOFUSER' and languagetype='en' and Labeltype='fixedstr';
update ld_desk set Fieldlabel='The second step: set product information by product managers' where labelbol='THESECONDSTEPFROMPRODUCT' and languagetype='en' and Labeltype='fixedstr';
update ld_desk set Fieldlabel='Select the account' where labelbol='SELECTZHAOTAO' and languagetype='en' and Labeltype='jspop';
update ld_desk set Fieldlabel='Edit custom groups' where labelbol='EDITCUSTOMPACKET' and languagetype='en' and Labeltype='fixedstr';
update ld_desk set Fieldlabel='The end of the initialization' where labelbol='Save_and_confirm' and languagetype='en' and Labeltype='fixedstr';
update ld_desk set Fieldlabel='Account permissions' where labelbol='Account_Permissions' and languagetype='en' and Labeltype='fixedstr';
update ld_desk set Fieldlabel='1 After setting personnel, the user can transfer in a single collection, payment orders, expense reimbursement, monotonous with the bank teller, and query other relevant information in the cash bank account' where labelbol='Corporate_Account_Setup_Instructions_1' and languagetype='en' and Labeltype='fixedstr';
update ld_desk set Fieldlabel='2 By default, all users have operating authority.' where labelbol='Corporate_Account_Setup_Instructions_2' and languagetype='en' and Labeltype='fixedstr';
update ld_desk set Fieldlabel='Personal sales data monthly' where labelbol='THISMONTHSALESDATA' and languagetype='en' and Labeltype='fixedstr';
update ld_desk set Fieldlabel='collection amount' where labelbol='AMOUNTTO' and languagetype='en' and Labeltype='fixedstr';
update ld_desk set Fieldlabel='Setting the page list of chronological book displaying the number of records per page' where labelbol='LISTBOOKNUM' and languagetype='en' and Labeltype='fixedstr';
update ld_desk set Fieldlabel='When the {$Accounts.Accounts} head is changing,whether to send text messages to inform the new person in charge' where labelbol='NOTIFYACCOUNTASSIGNED' and languagetype='en' and Labeltype='fixedstr';
update ld_desk set Fieldlabel='While Confirming whether to send text messages to inform the customer {$OutboundOrder.OutboundOrder}' where labelbol='CONFIRMINFORMOUTBOUND' and languagetype='en' and Labeltype='fixedstr';
update ld_desk set Fieldlabel='Set more page list of info displaying the number of records per page' where labelbol='PAGEMORELISTNUM' and languagetype='en' and Labeltype='fixedstr';
update ld_desk set Fieldlabel='Reminder in N days before the delivery date' where labelbol='REMINDSALESORDERDUEDATE' and languagetype='en' and Labeltype='fixedstr';
update ld_desk set Fieldlabel='There is no modified record' where labelbol='NOHISOTRYRECORD' and languagetype='en' and Labeltype='fixedstr';
update ld_desk set Fieldlabel='Upper and lower levels' where labelbol='ACCOUNTHIERARCHY' and languagetype='en' and Labeltype='fixedstr';
update ld_desk set Fieldlabel='Buyout' where labelbol='BUYOUT' and languagetype='en' and Labeltype='fixedstr';
update ld_desk set Fieldlabel='Select Mail template' where labelbol='SELECTMAILTEMPLATE' and languagetype='en' and Labeltype='fixedstr';
update ld_desk set Fieldlabel='transfer customer to be the high Seas customers' where labelbol='TOBETHEHIGHSEASCUSTOMTERS' and languagetype='en' and Labeltype='fixedstr';
update ld_desk set Fieldlabel='Records of the high Seas operation' where labelbol='RECORDSOFOPERATION' and languagetype='en' and Labeltype='fixedstr';
update ld_desk set Fieldlabel='Please choose the mail to send' where labelbol='PLEASECHOOSESENDEMAIL' and languagetype='en' and Labeltype='fixedstr';
update ld_desk set Fieldlabel='The following message is associated with the selected records' where labelbol='FOLLOWINGMESSAGEWITHSELECT' and languagetype='en' and Labeltype='fixedstr';
update ld_desk set Fieldlabel='Choose the Email to receive ' where labelbol='CHOOSERECEIVEeMAIL' and languagetype='en' and Labeltype='fixedstr';
update ld_desk set Fieldlabel='The number of days difference' where labelbol='TIMEDIFFDAYS' and languagetype='en' and Labeltype='fixedstr';
update ld_desk set Fieldlabel='The time of difference' where labelbol='TIMEDIFF' and languagetype='en' and Labeltype='fixedstr';
update ld_desk set Fieldlabel='The customer number statistics the number of Responsible customer number,query according to the creation date .' where labelbol='SALESGOALINSTRUCTION8' and languagetype='en' and Labeltype='fixedstr';
update ld_desk set Fieldlabel='library date' where labelbol='OUTOFDATE' and languagetype='en' and Labeltype='fixedstr';
update ld_desk set Fieldlabel='the number to be storaged' where labelbol='WHENTHENUMBEROFSTORAGE' and languagetype='en' and Labeltype='fixedstr';
update ld_desk set Fieldlabel='Whether to display Primary Contact at the block of viewing the details' where labelbol='CUSTOMERDATAILPRIMARY' and languagetype='en' and Labeltype='fixedstr';
update ld_desk set Fieldlabel='Anti audit' where labelbol='ACheckout' and languagetype='en' and Labeltype='fixedstr';
update ld_desk set Fieldlabel='Are you sure you want to check' where labelbol='stcoy' and languagetype='en' and Labeltype='jspop';
update ld_desk set Fieldlabel='Are you sure you want to anti audit' where labelbol='stacoy' and languagetype='en' and Labeltype='jspop';
update ld_desk set Fieldlabel='The records  you choose have checked document,cannot be masschecked' where labelbol='Recordscheckoutit' and languagetype='en' and Labeltype='jspop';
update ld_desk set Fieldlabel='The records  you choose have checked document,cannot be masschecked' where labelbol='yhbsrcdnbb' and languagetype='en' and Labeltype='jspop';
update ld_desk set Fieldlabel='Out of account and transferred into account can not be the same account!' where labelbol='taaacnbtttsa' and languagetype='en' and Labeltype='jspop';
update ld_desk set Fieldlabel='Related person' where labelbol='RELATEDPERSONNEL' and languagetype='en' and Labeltype='fixedstr';
update ld_desk set Fieldlabel='The data has been checkout, you can not assign!' where labelbol='TDHBCYCNE' and languagetype='en' and Labeltype='jspop';
update ld_desk set Fieldlabel='You have insufficient privileges, no access to operate any bank account' where labelbol='INSUFFICIENTPRIVILEGES' and languagetype='en' and Labeltype='fixedstr';
update ld_desk set Fieldlabel='invoice amount' where labelbol='HASBILLINGAMOUNT' and languagetype='en' and Labeltype='fixedstr';
update ld_desk set Fieldlabel='Subtotal' where labelbol='PAYMENT' and languagetype='en' and Labeltype='fixedstr';
update ld_desk set Fieldlabel='Student service table' where labelbol='Studentsparticipatinginthetrainingschedule' and languagetype='en' and Labeltype='fixedstr';
update ld_desk set Fieldlabel='Students participating in the course of KPC schedule' where labelbol='CourseparticipantsKPClist' and languagetype='en' and Labeltype='fixedstr';
update ld_desk set Fieldlabel='The number of periods should enter a positive integer' where labelbol='SHOULDPOSITIVEINTEGER' and languagetype='en' and Labeltype='jspop';
update ld_desk set Fieldlabel='My subordinates' where labelbol='Myteam' and languagetype='en' and Labeltype='fixedstr';
update ld_desk set Fieldlabel='Approval is successful,the process ends' where labelbol='AISTEOTP' and languagetype='en' and Labeltype='fixedstr';
update ld_desk set Fieldlabel='Not passed,return to the head' where labelbol='INPTRC' and languagetype='en' and Labeltype='fixedstr';
update ld_desk set Fieldlabel='Unsubmitted' where labelbol='Unapproved' and languagetype='en' and Labeltype='fixedstr';
update ld_desk set Fieldlabel='Approvaling' where labelbol='Approvalof' and languagetype='en' and Labeltype='fixedstr';
update ld_desk set Fieldlabel='this month sales data of subordinate' where labelbol='SUBORDINATEMOTHSALESDATA' and languagetype='en' and Labeltype='fixedstr';
update ld_desk set Fieldlabel='Personal monthly sales data' where labelbol='Penson Month Sales' and languagetype='en' and Labeltype='fixedstr';
update ld_desk set Fieldlabel='The billboard of signing amount' where labelbol='THESINGNINGAMOUNTOFBILLBOARD' and languagetype='en' and Labeltype='fixedstr';
update ld_desk set Fieldlabel='Receivable statistics List' where labelbol='SHOULDTHESTATISTICSCOLLECTION' and languagetype='en' and Labeltype='fixedstr';
update ld_desk set Fieldlabel='Total the annual sales status of enterprise' where labelbol='ANNUALSALESENTERPRISE' and languagetype='en' and Labeltype='fixedstr';
update ld_desk set Fieldlabel='"orders amount" of the table customer statistic the contract orders of "created time" in the range of the query time,and total according to the customers.' where labelbol='CUSTOMERSTATISTICALCONTRACTORDERS' and languagetype='en' and Labeltype='fixedstr';
update ld_desk set Fieldlabel='"collectin amount" of the table customer statistic the receipts of "collectin time" in the range of the query time,and total according to the customers.' where labelbol='CUSTOMERSTATISTICALRECEIPTS' and languagetype='en' and Labeltype='fixedstr';
update ld_desk set Fieldlabel='"invoice amount" of the table customer statistic the invoice of "invoice time" in the range of the query time,and total according to the customers.' where labelbol='CUSTOMERSTATISTICALINVOICE' and languagetype='en' and Labeltype='fixedstr';
update ld_desk set Fieldlabel='Not statistics contract orders, receipts, invoices that have been removed to the recycle bin' where labelbol='NOSTATISTICSREMOVEDRECYCLE' and languagetype='en' and Labeltype='fixedstr';
update ld_desk set Fieldlabel='The period of statistics is setted based on date of receipt of receipts' where labelbol='STATISTICSBASERECEIPTS' and languagetype='en' and Labeltype='fixedstr';
update ld_desk set Fieldlabel='Not statistics receipts that have been removed to the recycle bin' where labelbol='STATISTICSBASERECEIPTSBILL' and languagetype='en' and Labeltype='fixedstr';
update ld_desk set Fieldlabel='contact Order No.' where labelbol='SALESORDERNO' and languagetype='en' and Labeltype='fixedstr';
update ld_desk set Fieldlabel='contact Order' where labelbol='SALESORDER' and languagetype='en' and (Labeltype='fixedstr' or Labeltype='jspop');
update ld_desk set Fieldlabel='The records of your choice have been approved or part approved of records, batch assigning is not allowed!' where labelbol='APPROVALORISUNDEREXAMINATION' and languagetype='en' and Labeltype='fixedstr';
update ld_desk set Fieldlabel='The actual payment amount' where labelbol='THEACTUALAMOUNT' and languagetype='en' and Labeltype='fixedstr';
update ld_desk set Fieldlabel='Inbox' where labelbol='INBOX' and languagetype='en' and Labeltype='fixedstr';
update ld_desk set Fieldlabel='receiving mail, please wait' where labelbol='RECEIVEMAILPLEASEWAIT' and languagetype='en' and Labeltype='fixedstr';
update ld_desk set Fieldlabel='Not found matching record' where labelbol='LBL_ACTIONS' and languagetype='en' and Labeltype='fixedstr';
update ld_desk set Fieldlabel='Please input the correct format to query the early time' where labelbol='PLEASEINPUTTHECORRECTFORMATEARLY' and languagetype='en' and Labeltype='jspop';
update ld_desk set Fieldlabel='Specifies the repeat number' where labelbol='REPEATTIMES' and languagetype='en' and Labeltype='fixedstr';
update ld_desk set Fieldlabel='remind the repetition method' where labelbol='REPEATMODE' and languagetype='en' and Labeltype='fixedstr';
update ld_desk set Fieldlabel="whether to intercept The contact record 'remarks' field list when displayed" where labelbol='CONTACTRECORDINTERCEPTION' and languagetype='en' and Labeltype='fixedstr';
update ld_desk set Fieldlabel='The specified period day to remind cannot be empty!' where labelbol='THESPECIFIEDMINDDAYSCANNOTBEEMPTYERROR' and languagetype='en' and Labeltype='jspop';
update ld_desk set Fieldlabel='this page' where labelbol='TOTALTHIS' and languagetype='en' and Labeltype='fixedstr';
update ld_desk set Fieldlabel='Ledger selection' where labelbol='ZHANGTAOCHOOSE' and languagetype='en' and Labeltype='fixedstr';
update ld_desk set Fieldlabel='inventory amount interface:acquisite automaticly the inventory quantity of ledger interface ,and update the total inventory number of the corresponding products in this system.' where labelbol='DATAINTERFACESTEP6' and languagetype='en' and Labeltype='fixedstr';
update ld_desk set Fieldlabel='Note:access the number of product inventory account of ledger interface, and put "the product number" as the sole criterion,update to the system.' where labelbol='SYNCHRONOUSINVENTORYNOTE' and languagetype='en' and Labeltype='fixedstr';
update ld_desk set Fieldlabel='Collection method' where labelbol='SPAYMENT' and languagetype='en' and Labeltype='fixedstr';
update ld_desk set Fieldlabel='The statistics range of Expense and Commission' where labelbol='EXCOMMTOTAL' and languagetype='en' and Labeltype='fixedstr';
update ld_desk set Fieldlabel='Account name' where labelbol='ZHANGTAONAME' and languagetype='en' and (Labeltype='fixedstr' or Labeltype='jspop');
update ld_desk set Fieldlabel='Associated project settings' where labelbol='PROJECTSETTINGS' and languagetype='en' and Labeltype='fixedstr';
update ld_desk set Fieldlabel='Service maturity' where labelbol='PERIODOFSERVICEEND' and languagetype='en' and Labeltype='fixedstr';
update ld_desk set Fieldlabel='Modify' where labelbol='UPDATES' and languagetype='en' and Labeltype='fixedstr';
update ld_desk set Fieldlabel='The current document status is "have a library"' where labelbol='PURCHASEENDRETURN1' and languagetype='en' and Labeltype='fixedstr';
update ld_desk set Fieldlabel='The current document status is "not a library"' where labelbol='PURCHASEENDRETURN2' and languagetype='en' and Labeltype='fixedstr';
update ld_desk set Fieldlabel="The field‘$fieldname$’ matches more times,please re-set" where labelbol='FIELDMATCHESTIMES' and languagetype='en' and Labeltype='jspop';
update ld_desk set Fieldlabel='0 said to remind on this day,empty not remind' where labelbol='ZEROSAMEDAYREMIND' and languagetype='en' and Labeltype='fixedstr';
update ld_desk set Fieldlabel="After converting common customers to the hign seas customers ,modify the head as（not modify if it's empty）" where labelbol='AFTERCONVERTINGMODIFYTHEOWNER' and languagetype='en' and Labeltype='fixedstr';
update ld_desk set Fieldlabel='Wether to display the public customers on the “All” tab of order book' where labelbol='WEHERTODISPLAYTHEPUBLICCUSTOMERES' and languagetype='en' and Labeltype='fixedstr';
update ld_desk set Fieldlabel='The following fields mapped more than once, please check mapping' where labelbol='FIELDSMAPPEDMORETHANONCE' and languagetype='en' and Labeltype='jspop';
update ld_desk set Fieldlabel='The product model' where labelbol='Model' and languagetype='en' and Labeltype='fixedstr';
update ld_desk set Fieldlabel='Head' where labelbol='ASSIGNEDTO' and languagetype='en' and Labeltype='fixedstr';
update ld_desk set Fieldlabel='The number of returns does not allow to be greater than the return quantity after being returned' where labelbol='THENUMBEROFRETURNS1' and languagetype='en' and Labeltype='jspop';
update ld_desk set Fieldlabel='The amount of returns does not allow to be greater than the return amount after being returned ' where labelbol='THENUMBEROFRETURNS3' and languagetype='en' and Labeltype='jspop';
update ld_desk set Fieldlabel='Common customer' where labelbol='COMMONACCOUNT' and languagetype='en' and Labeltype='fixedstr';
update ld_desk set Fieldlabel='The hign seas customer' where labelbol='PUBLICACCOUNT' and languagetype='en' and Labeltype='fixedstr';
update ld_desk set Fieldlabel='Outbound order or warehousing single update the trigger point of inventory record' where labelbol='UPDATEINVENTORYLEDGER' and languagetype='en' and Labeltype='fixedstr';
update ld_desk set Fieldlabel='Allows manual code' where labelbol='ALLOWTOMODIFY' and languagetype='en' and Labeltype='fixedstr';
delimiter;

call AddColumn('ld_singin','uuid','varchar',200,null);
delimiter;
select usereportid into @usereportid from ld_usereport where name='SIGNINSTATISTICS';
insert into  ld_usereportcolumns(usereportid,columns,sequence,columnshow,realcolumns,realencolumns)
select @usereportid,'LD_singin:uuid:uuid:OftenUseReport_手机id:V',6,1,'LD_singin:uuid:uuid:OftenUseReport_手机id:V','LD_singin:uuid:uuid:OftenUseReport_mobile id:V'
from dual where not EXISTS(select 1 from ld_usereportcolumns  where Usereportid=@usereportid and columns like '%LD_singin:uuid:uuid:OftenUseReport%');
delimiter;

update ld_quickactions set presence=1 where tabid=6 and related_tabid=9;
delimiter;

select tabid into @tabid from ld_tab where `name` = 'ServiceCharge';
update ld_field set quickcreate = 1 where tabid = @tabid;
delimiter;

DROP PROCEDURE IF EXISTS CopyModuleQuickActions;
delimiter ||
CREATE PROCEDURE CopyModuleQuickActions(
	IN copymodule VARCHAR(100),
	IN tomodule VARCHAR(100)
)
BEGIN
	#Routine body goes here...
declare done  int  default 0;
DECLARE qa_related_tabid int;
DECLARE qa_sequence int;
DECLARE qa_presence int; 
DECLARE qa_label varchar(100);
declare cur1 CURSOR FOR SELECT  related_tabid,sequence,presence,label from ld_quickactions where tabid = (select tabid from ld_tab where name = copymodule);
declare continue handler  for not   found  SET done =1;

select tabid into @tabid from ld_tab where `name` = tomodule;

OPEN cur1;
Fetch cur1 into qa_related_tabid,qa_sequence,qa_presence,qa_label;
 loop1: while  done<>1 DO
	-- 操作信息插入
	insert into ld_quickactions(tabid,related_tabid,sequence,presence,label)
	select @tabid,qa_related_tabid,qa_sequence,qa_presence,qa_label 
	from dual  where not exists(select 1 from ld_quickactions where tabid=@tabid and related_tabid = qa_related_tabid);

Fetch cur1 into qa_related_tabid,qa_sequence,qa_presence,qa_label;
end while loop1;
close cur1;

END ||
delimiter;


DROP PROCEDURE IF EXISTS CopyModuleRelatedLists;
delimiter ||
CREATE PROCEDURE CopyModuleRelatedLists(
	IN copymodule VARCHAR(100),
	IN tomodule VARCHAR(100)
)
BEGIN
	#Routine body goes here...
declare done  int  default 0;
DECLARE rl_related_tabid int;
DECLARE rl_name varchar(100);
DECLARE rl_sequence int; 
DECLARE rl_label varchar(100);
DECLARE rl_presence int; 
DECLARE rl_actions varchar(100); 
declare cur1 CURSOR FOR SELECT  related_tabid,name,sequence,label,presence,actions from LD_relatedlists where tabid = (select tabid from ld_tab where name = copymodule);
declare continue handler  for not   found  SET done =1;

select tabid into @tabid from ld_tab where `name` = tomodule;
select max(relation_id) into @relation_id from LD_relatedlists;
OPEN cur1;
Fetch cur1 into rl_related_tabid,rl_name,rl_sequence,rl_label,rl_presence,rl_actions;
 loop1: while  done<>1 DO
	-- 相关信息插入
	set @relation_id = @relation_id +1;

	insert into LD_relatedlists(relation_id,tabid,related_tabid,name,sequence,label,presence,actions)
	select @relation_id+1,@tabid,rl_related_tabid,rl_name,rl_sequence,rl_label,rl_presence,rl_actions 
	from dual  where not exists(select 1 from LD_relatedlists where tabid=@tabid and related_tabid = rl_related_tabid);

Fetch cur1 into rl_related_tabid,rl_name,rl_sequence,rl_label,rl_presence,rl_actions;
end while loop1;
close cur1;

update ld_relatedlists_seq set id = (select max(relation_id) from LD_relatedlists);

END ||
delimiter;


call CopyModuleQuickActions('Accounts','ServiceCharge');
call CopyModuleRelatedLists('Accounts','ServiceCharge');


UPDATE ld_eventhandlers SET is_active = 1 WHERE event_name='vtiger.entity.beforesave.modifiable' AND handler_class='VTFieldFormulasEventHandler' AND is_active = 0;
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'zh','PLEASEENTERKEYWORDTOSEARCH','请输如查找关键字！','jspop' from dual 
where not EXISTS(select 1 from ld_desk  where languagetype='zh' and labelbol='PLEASEENTERKEYWORDTOSEARCH' and Labeltype='jspop');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'en','PLEASEENTERKEYWORDTOSEARCH','Please enter a keyword to search by！','jspop' from dual 
where not EXISTS(select 1 from ld_desk  where languagetype='en' and labelbol='PLEASEENTERKEYWORDTOSEARCH' and Labeltype='jspop');
delimiter;

select 6 into @tabid;
select sequence into @seq from ld_field where tabid=@tabid and columnname='smownerid';
select block into @block from ld_field where tabid=@tabid and columnname='smownerid';
update ld_field set sequence=sequence+2 where tabid=@tabid and block=@block and sequence>@seq;
update ld_field set sequence=@seq+1,block=@block,displaytype=3 where tabid=@tabid and columnname='servicecasher';
update ld_field set sequence=@seq+2,block=@block,displaytype=3 where tabid=@tabid and columnname='servicegroup';

select 1 into @i;
update ld_field set sequence=(@i:=@i+1) where tabid=@tabid and block=@block order by sequence;
delimiter;

select tabid into @tabid from ld_tab where name='ServiceCharge';
select sequence into @seq from ld_field where tabid=@tabid and columnname='smownerid';
select block into @block from ld_field where tabid=@tabid and columnname='smownerid';
update ld_field set sequence=sequence+2 where tabid=@tabid and block=@block and sequence>@seq;
update ld_field set sequence=@seq+1,block=@block where tabid=@tabid and columnname='servicecasher';
update ld_field set sequence=@seq+2,block=@block where tabid=@tabid and columnname='servicegroup';

select 1 into @i;
update ld_field set sequence=(@i:=@i+1) where tabid=@tabid and block=@block order by sequence;
delimiter;
-- end 2014-08-29

update ld_desk set Fieldlabel='Head distribution statistics' where labelbol='PAYMENTCHARGE' and languagetype='en' and Labeltype='fixedstr';
update ld_desk set Fieldlabel='Put the hign seas customers use or assign to some sales,each sales can only have a number of the high seas customers, and limit must reach the setting conditions within the time, otherwise the client will automatically return to the high seas and be reallocated to other sales.' where labelbol='CUSTOMERSALESFULFILLED' and languagetype='en' and Labeltype='fixedstr';
update ld_desk set Fieldlabel="Customize the main menu and its sub-module's name displayed order" where labelbol='LBL_TABLIST_DESCRIPTION' and languagetype='en' and Labeltype='fixedstr';
update ld_desk set Fieldlabel='should be equal to' where labelbol='SHOULDBEEQUAL' and languagetype='en' and Labeltype='jspop';
update ld_desk set Fieldlabel='写信' where labelbol='LBL_Compose' and languagetype='zh' and Labeltype='fixedstr';
update ld_desk set Fieldlabel='收信' where labelbol='LBL_GETBOX' and languagetype='zh' and Labeltype='fixedstr';
delimiter;
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'en','thisfy','This fiscal year','fixedstr' from dual 
where not EXISTS(select 1 from ld_desk  where languagetype='en' and labelbol='thisfy' and Labeltype='fixedstr');
delimiter;
update ld_tranlabel set fieldlabel = '预计合同金额' where languagetype = 'zh' and tabid in (select tabid from ld_tab where name = 'Potentials') 
and Relateid in (select fieldid from ld_field where columnname= 'amount' and tabid in (select tabid from ld_tab where name = 'Potentials') );
delimiter;
update ld_desk set Fieldlabel='账户设置' where labelbol='LBL_SETTINGS' and languagetype='zh' and Labeltype='fixedstr';
update ld_desk set Fieldlabel='Account setup' where labelbol='LBL_SETTINGS' and languagetype='en' and Labeltype='fixedstr';
delimiter;
-- end 2014-09-01
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'zh','Thenumberofproduct','产品数量应该为大于0的整数!','jspop' 
from dual where not EXISTS(select 1 from ld_desk where languagetype='zh' and labelbol='Thenumberofproduct' and Labeltype='jspop');

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'en','Thenumberofproduct','The number of products should be an integer greater than 0!','jspop' 
from dual where not EXISTS(select 1 from ld_desk  where languagetype='en' and labelbol='Thenumberofproduct' and Labeltype='jspop');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'zh','CHOOSEHIDDENFIELD','选择要取消隐藏的字段','fixedstr' from dual 
where not EXISTS(select 1 from ld_desk  where languagetype='zh' and labelbol='CHOOSEHIDDENFIELD' and Labeltype='fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'en','CHOOSEHIDDENFIELD','Choose to cancel the hidden field','fixedstr' from dual 
where not EXISTS(select 1 from ld_desk  where languagetype='en' and labelbol='CHOOSEHIDDENFIELD' and Labeltype='fixedstr');
delimiter;
delete from ld_desk where labelbol = 'BLOCKNAMECANOTEMPTY' and Labeltype = 'jspop';
delimiter;
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'zh','CHINESEBLOCKNAMENOTEMPTY','中文标签不能为空！','jspop' from dual 
where not EXISTS(select 1 from ld_desk  where languagetype='zh' and labelbol='CHINESEBLOCKNAMENOTEMPTY' and Labeltype='jspop');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'en','CHINESEBLOCKNAMENOTEMPTY','Chinese label cannot be empty!','jspop' from dual 
where not EXISTS(select 1 from ld_desk  where languagetype='en' and labelbol='CHINESEBLOCKNAMENOTEMPTY' and Labeltype='jspop');
delimiter;
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'zh','ENGLISHBLOCKNAMENOTEMPTY','英文标签不能为空！','jspop' from dual 
where not EXISTS(select 1 from ld_desk  where languagetype='zh' and labelbol='ENGLISHBLOCKNAMENOTEMPTY' and Labeltype='jspop');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'en','ENGLISHBLOCKNAMENOTEMPTY','English label cannot be empty!','jspop' from dual 
where not EXISTS(select 1 from ld_desk  where languagetype='en' and labelbol='ENGLISHBLOCKNAMENOTEMPTY' and Labeltype='jspop');
delimiter;

select tabid into @tabid from ld_tab where `name`='ServiceCharge';
delete from ld_tabwithproductview where `columns`='LD_account:account_no:account_no:Accounts_fieldlabel:V' and tabid = @tabid;
delimiter;
delete from ld_tabwithproductview where `columns`='LD_products:product_no:product_no:Products_fieldlabel:V' and tabid = @tabid;
delimiter;

select tabid into @tabid from ld_tab where `name`='ServiceContracts';
update ld_tranlabel set fieldlabel = '服务到日期' where fieldlabel='服务截止日期' and tabid = @tabid;
delimiter;

update ld_field set uitype=71 where tabid=14 and columnname='costprice';
delimiter;
-- end 2014-09-02

update ld_desk set Fieldlabel='上级字段和下级字段不能是同一字段！' where labelbol='SOURCETARGETFIELDSSHOULDNOTSAME' and languagetype='zh' and Labeltype = 'jspop';
update ld_desk set Fieldlabel='The field and the lower field cannot be the same field!' where labelbol='SOURCETARGETFIELDSSHOULDNOTSAME' and languagetype='en' and Labeltype = 'jspop';
delimiter;
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'zh','LABELNAMENOTEMPTY','标签不能为空！','jspop' from dual 
where not EXISTS(select 1 from ld_desk  where languagetype='zh' and labelbol='LABELNAMENOTEMPTY' and Labeltype='jspop');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'en','LABELNAMENOTEMPTY','The label can not be empty!','jspop' from dual 
where not EXISTS(select 1 from ld_desk  where languagetype='en' and labelbol='LABELNAMENOTEMPTY' and Labeltype='jspop');
delimiter;

alter table ld_desk modify column fieldlabel varchar(500) ;

update ld_desk set Fieldlabel='Put the hign seas customers use or assign to some sales,each sales can only have a number of the high seas customers, and limit must reach the setting conditions within the time, otherwise the client will automatically return to the high seas and be reallocated to other sales.' where labelbol='CUSTOMERSALESFULFILLED' and languagetype='en' and Labeltype='fixedstr';
delimiter;

UPDATE ld_field SET uitype = 9 WHERE columnname = 'discount_percent' AND uitype = 72;
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'zh','Thisrecordisdeleted','此记录已删除!','fixedstr' from dual 
where not EXISTS(select 1 from ld_desk  where languagetype='zh' and labelbol='Thisrecordisdeleted' and Labeltype='fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'en','Thisrecordisdeleted','This record is deleted!','fixedstr' from dual 
where not EXISTS(select 1 from ld_desk  where languagetype='en' and labelbol='Thisrecordisdeleted' and Labeltype='fixedstr');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'zh','Thisrecordisdeleted','此记录已删除!','jspop' from dual 
where not EXISTS(select 1 from ld_desk  where languagetype='zh' and labelbol='Thisrecordisdeleted' and Labeltype='jspop');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'en','Thisrecordisdeleted','This record is deleted!','jspop' from dual 
where not EXISTS(select 1 from ld_desk  where languagetype='en' and labelbol='Thisrecordisdeleted' and Labeltype='jspop');
delimiter;

select tabid into @tabid from ld_tab where `name`='ServiceContracts';
update ld_tranlabel set fieldlabel = '服务到期日' where fieldlabel='服务截止日期' and tabid = @tabid;
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'zh','Supportcosts','支持费用
','fixedstr' from dual 
where not EXISTS(select 1 from ld_desk  where languagetype='zh' and labelbol='Supportcosts' and Labeltype='fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'en','Supportcosts','Support costs','fixedstr' from dual 
where not EXISTS(select 1 from ld_desk  where languagetype='en' and labelbol='Supportcosts' and Labeltype='fixedstr');
delimiter;

select tabid into @tabid from ld_tab where name = 'ServiceContracts';
select fieldid into @fieldid from ld_field where tabid = 37 and columnname = 'end_date';
update ld_tranlabel set fieldlabel = '服务到期日' where tabid = @tabid and Relateid = @fieldid and languagetype = 'zh' and trantable='LD_field';
delimiter;

call AddColumn('LD_field','searchfieldtype','int','2',1);
update LD_field set searchfieldtype = 1 where searchfieldtype is null;
delimiter;
select tabid into @tabid from ld_tab where name = 'Products';
update LD_field set searchfieldtype = 0 where tabid = @tabid and columnname in ('productname','product_no');
delimiter;
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','INPUTAKEYWORDSQUERY','输入关键字查询','jspop' 
from dual where not EXISTS(select 1 from ld_desk  where languagetype = 'zh' 
and labeltype ='jspop' and labelbol = 'INPUTAKEYWORDSQUERY');

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','INPUTAKEYWORDSQUERY','Input a keyword query','jspop' 
from dual where not EXISTS(select 1 from ld_desk  where languagetype = 'en' 
and labeltype ='jspop' and labelbol = 'INPUTAKEYWORDSQUERY');

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','INPUTAKEYWORDSQUERY','输入关键字查询','fixedstr' 
from dual where not EXISTS(select 1 from ld_desk  where languagetype = 'zh' 
and labeltype ='fixedstr' and labelbol = 'INPUTAKEYWORDSQUERY');

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','INPUTAKEYWORDSQUERY','Input a keyword query','fixedstr' 
from dual where not EXISTS(select 1 from ld_desk  where languagetype = 'en' 
and labeltype ='fixedstr' and labelbol = 'INPUTAKEYWORDSQUERY');

update ld_desk set Fieldlabel='操作设置' where labelbol='SHORTCUTSETTINGS' and languagetype='zh' and Labeltype = 'fixedstr';
update ld_desk set Fieldlabel='Operation Settings' where labelbol='SHORTCUTSETTINGS' and languagetype='en' and Labeltype = 'fixedstr';
update ld_desk set Fieldlabel='相关信息设置' where labelbol='PROJECTSETTINGS' and languagetype='zh' and Labeltype = 'fixedstr';
update ld_desk set Fieldlabel='Relevant Information Settings' where labelbol='PROJECTSETTINGS' and languagetype='en' and Labeltype = 'fixedstr';
delimiter;
-- end 2014-09-04

insert into ld_desk (languagetype,labelbol,fieldlabel,labeltype)
select 'zh','VIEWNAMECANNOTEMPTY','视图名称不能为空!','fixedstr'
from dual where not EXISTS(select 1 from ld_desk where languagetype='zh' and labelbol='VIEWNAMECANNOTEMPTY' and Labeltype='fixedstr');

insert into ld_desk (languagetype,labelbol,fieldlabel,labeltype)
select 'en','VIEWNAMECANNOTEMPTY','View name can''t empty!','fixedstr' 
from dual where not EXISTS(select 1 from ld_desk where languagetype='en' and labelbol='VIEWNAMECANNOTEMPTY' and Labeltype='fixedstr');
delimiter;
insert into ld_desk (languagetype,labelbol,fieldlabel,labeltype)
select 'zh','NUNMBERALREADYEXIST','已存在，系统将自动生成一个新的编号，请重新保存！','fixedstr'
from dual where not EXISTS(select 1 from ld_desk where languagetype='zh' and labelbol='NUNMBERALREADYEXIST' and Labeltype='fixedstr');

insert into ld_desk (languagetype,labelbol,fieldlabel,labeltype)
select 'en','NUNMBERALREADYEXIST',' already exists,the system will automatically generates a new number.please save it again!','fixedstr' 
from dual where not EXISTS(select 1 from ld_desk where languagetype='en' and labelbol='NUNMBERALREADYEXIST' and Labeltype='fixedstr');
delimiter;
-- end 2014-09-05

select tabid into @tabid from ld_tab where `name`='Potentials';
select sequence into @seq from ld_field where tabid=@tabid and columnname='possibility';
select block into @block from ld_field where tabid=@tabid and columnname='possibility';
update ld_field set sequence=sequence+1 where tabid=@tabid and block=@block and sequence>@seq;
 
select 'LD_potentialscf' into @tablename;
select '预算绝对值' into @zh;
select 'Absolute Amount' into @en;
select 1 into @generatedtype;
select 7 into @uitype;
select 1 into @displaytype;
-- select sequence into @seq from ld_field where tabid=13 and columnname='fees';
-- lect block into @block from ld_field where tabid=13 and columnname='fees'
select 'NN~O~25,2' into @typeofdata;

select max(fieldid) into @fieldid from ld_field;
insert into ld_field(tabid,fieldid,columnname,tablename,generatedtype,uitype,fieldname,fieldlabel,readonly,presence,maximumlength,sequence,block,displaytype,typeofdata,quickcreate,info_type,helpinfo)
select @tabid,@fieldid+1,concat('cf_',@fieldid+1),@tablename,@generatedtype,@uitype,concat('cf_',@fieldid+1),concat('cf_',@fieldid+1),1,2,100,@seq+1,@block,@displaytype,@typeofdata,3,'BAS','absamount(预算绝对值)' from dual 
where not exists (select 1 from ld_field where tabid = @tabid and helpinfo='absamount(预算绝对值)');
update ld_field_seq set id = (select max(fieldid) from ld_field);

select fieldname into @fieldname from ld_field where tabid=@tabid and helpinfo='absamount(预算绝对值)';
delete from  ld_fieldformulas;
select max(expressionid) into @expressionid from ld_fieldformulas;
insert into ld_fieldformulas(expressionid,modulename,expression_engine)
select @expressionid+1,'Potentials',concat('O:18:"VTExpressionEngine":6:{s:4:"data";a:0:{}s:11:"expressions";a:1:{s:7:"',@fieldname,'";O:10:"VTTreeNode":1:{s:3:"arr";a:3:{i:0;O:6:"Symbol":1:{s:5:"value";s:1:"*";}i:1;O:6:"Symbol":1:{s:5:"value";s:6:"amount";}i:2;O:10:"VTTreeNode":1:{s:3:"arr";a:3:{i:0;O:6:"Symbol":1:{s:5:"value";s:1:"/";}i:1;O:6:"Symbol":1:{s:5:"value";s:11:"possibility";}i:2;i:100;}}}}}s:19:"unparsedExpressions";a:1:{s:7:"',@fieldname,'";s:22:"amount*possibility/100";}s:4:"vars";a:1:{i:0;s:7:"',@fieldname,'";}s:12:"independents";a:0:{}s:10:"dependents";a:0:{}}');
update ld_fieldformulas_seq set id=@expressionid+1;

select fieldid into @fieldid from ld_field where tabid=@tabid and helpinfo='absamount(预算绝对值)';
delete from ld_tranlabel where trantable ='LD_field' and tabid=@tabid and relateid=@fieldid;
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'zh','LD_field',@tabid,@fieldid,@zh;

insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'en','LD_field',@tabid,@fieldid,@en;

select 1 into @i;
update ld_field set sequence=(@i:=@i+1) where tabid=@tabid and block=@block order by sequence;

select columnname into @columnname from ld_field where tabid=@tabid and helpinfo='absamount(预算绝对值)';
call AddColumn(@tablename,@columnname,'int','19',0);
delimiter;


select columnname into @columnname from ld_field where tabid=2 and helpinfo='absamount(预算绝对值)';
select concat('alter table LD_potentialscf modify ',@columnname,' decimal(25,2)') into @sql0;
PREPARE stmt1 from @sql0;
EXECUTE stmt1; 
delimiter;
 
call fieldprofile('Potentials');
delimiter;
call getallprofile('Potentials');
delimiter;

select cvid into @cvid from ld_customview where entitytype='Potentials' and viewname='All';
select fieldname into @fieldname from ld_field where tabid=2 and helpinfo='absamount(预算绝对值)';
delete from ld_cvcolumnlist where cvid=@cvid;
insert into ld_cvcolumnlist(cvid,columnindex,columnname)
select @cvid,0,'LD_potential:potentialname:potentialname:Potentials_fieldlabel:V';

insert into ld_cvcolumnlist(cvid,columnindex,columnname)
select @cvid,1,'LD_potential:accountid:account_id:Potentials_fieldlabel:V';

insert into ld_cvcolumnlist(cvid,columnindex,columnname)
select @cvid,2,'LD_potential:contactid:contact_id:Potentials_fieldlabel:V';

insert into ld_cvcolumnlist(cvid,columnindex,columnname)
select @cvid,3,'LD_potential:sales_stage:sales_stage:Potentials_fieldlabel:V';

insert into ld_cvcolumnlist(cvid,columnindex,columnname)
select @cvid,4,'LD_potential:closingdate:closingdate:Potentials_fieldlabel:D';

insert into ld_cvcolumnlist(cvid,columnindex,columnname)
select @cvid,5,'LD_potential:amount:amount:Potentials_fieldlabel:N';

insert into ld_cvcolumnlist(cvid,columnindex,columnname)
select @cvid,6,'LD_potentialscf:possibility:possibility:Potentials_fieldlabel:V';

insert into ld_cvcolumnlist(cvid,columnindex,columnname)
select @cvid,7,concat('LD_potentialscf:absamount:',@fieldname,':Potentials_fieldlabel:NN');

insert into ld_cvcolumnlist(cvid,columnindex,columnname)
select @cvid,8,'LD_potential:smownerid:assigned_user_id:Potentials_fieldlabel:V';
delimiter;

update ld_desk set fieldlabel='Related fields of products ' where labelbol='LBL_RELATED_PARAMETERS' and languagetype='en';
update ld_desk set fieldlabel='定制订单、发票等模块产品明细中关联的产品字段' where labelbol='LBL_RELATED_PARAMETERS_DESCRIPTION' and languagetype='zh';
update ld_desk set fieldlabel='Customise the related fields of products for the products list of orders,invoices and etc' where labelbol='LBL_RELATED_PARAMETERS_DESCRIPTION' and languagetype='zh';


select tabid into @purchasetabid from ld_tab where name='purchaseorder';
delete from LD_relatedlists where tabid=4 and related_tabid=@purchasetabid;
delimiter;

UPDATE ld_desk SET fieldlabel = '请输入查找关键字！' 
WHERE labelbol='PLEASEENTERKEYWORDTOSEARCH' AND Labeltype='jspop' AND languagetype='zh';
delimiter;
select tabid INTO@tabid from ld_tab where name = 'InventoryQuery';

UPDATE ld_field SET columnname = 'productsheet' , fieldname = 'productsheet' 
WHERE tabid=@tabid AND columnname='productcode' AND fieldname='productcode';

select cvid INTO@cvid from ld_customview where entitytype = 'InventoryQuery' and viewname='All';

UPDATE ld_cvcolumnlist SET columnname='LD_products:productsheet:productsheet:products_产品型号:' 
where cvid = @cvid 
AND columnname='LD_products:productcode:productcode:products_产品型号:';

select cvid INTO@cvid2 from ld_customview where entitytype = 'InventoryQuery' and viewname='库存预警';

UPDATE ld_cvcolumnlist SET columnname='LD_products:productsheet:productsheet:products_产品型号:' 
where cvid = @cvid2
AND columnname='LD_products:productcode:productcode:products_产品型号:';
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'zh','POTENTIALSSTATUS','机会状态','fixedstr' from dual 
where not EXISTS(select 1 from ld_desk  where languagetype='zh' and labelbol='POTENTIALSSTATUS' and Labeltype='fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'en','POTENTIALSSTATUS','The opportunity to state','fixedstr' from dual 
where not EXISTS(select 1 from ld_desk  where languagetype='en' and labelbol='POTENTIALSSTATUS' and Labeltype='fixedstr');
delimiter;

UPDATE ld_desk set fieldlabel='新密码不能为空！' where labelbol='ENTERNEWPASSWORD' and languagetype='zh' and Labeltype='jspop';
UPDATE ld_desk set fieldlabel='The new password cannot be blank!' where labelbol='ENTERNEWPASSWORD' and languagetype='en' and Labeltype='jspop';

UPDATE ld_desk set fieldlabel='确认密码不能为空！' where labelbol='ENTERNEWPASSWORDAGAIN' and languagetype='zh' and Labeltype='jspop';
UPDATE ld_desk set fieldlabel='Confirm the password can not be empty!' where labelbol='ENTERNEWPASSWORDAGAIN' and languagetype='en' and Labeltype='jspop';
delimiter;

SELECT tabid into @tabid from ld_tab where name='Accounts';
DELETE from ld_quickactions where tabid=@tabid and related_tabid=-5;
delimiter;
SELECT tabid into @tabid from ld_tab where name='Contacts';
DELETE from ld_quickactions where tabid=@tabid and related_tabid=-5;

SELECT tabid INTO @tabid FROM ld_tab WHERE NAME = 'Invoice';
UPDATE ld_field SET masseditable = 2 WHERE tabid = @tabid AND uitype = 202 AND fieldlabel = '选择源单';
delimiter;

call AddColumn('LD_commission2payment','sequence','int','10',0);
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'zh','USINGFUNCTIONS','使用函数','fixedstr' from dual 
where not EXISTS(select 1 from ld_desk  where languagetype='zh' and labelbol='USINGFUNCTIONS' and Labeltype='fixedstr');
delimiter;

update ld_desk  set fieldlabel='{$Potentials.sales_stage}' where labelbol='POTENTIALSSTATUS' and  Labeltype='fixedstr' and languagetype='zh';
update ld_desk  set fieldlabel='{$Invoice.invoicestatus}' where labelbol='STATUS' and  Labeltype='fixedstr' and languagetype='zh';
update ld_desk  set fieldlabel='{$Quotes.quotestage}' where labelbol='QUOTATIONSTATUS' and  Labeltype='fixedstr' and languagetype='zh';
update ld_desk  set fieldlabel='{$SalesOrder.sostatus}' where labelbol='ORDERSTATUS' and  Labeltype='fixedstr' and languagetype='zh';
delimiter;


update ld_desk set Fieldlabel='数据分类名称不能为空！' where labelbol='VIEWNAMECANNOTEMPTY' and languagetype='zh' and Labeltype = 'fixedstr';
update ld_desk set Fieldlabel='Data classification name cannot be empty!' where labelbol='VIEWNAMECANNOTEMPTY' and languagetype='en' and Labeltype = 'fixedstr';
delimiter;
-- end 2014-09-10

CREATE TABLE IF NOT EXISTS `ld_purchaseinvoice` (
  `purchaseinvoiceid` int(11) NOT NULL default '0',
  `subject` varchar(100) default NULL,
  `purchaseorder_id` int(11) default NULL,
  `purchaseinvoice_no` varchar(100) default NULL,
  `vendorid` int(11) default NULL,
  `contactid` int(11) default NULL,
  `purchaseinvoicedate` date default NULL,
  `purchaseinvoicetype` varchar(100) default NULL,
  `purchaseinvoicestatus` varchar(200) default NULL,
  `purchaseinvoicenum` varchar(100) default NULL,
  `adjustment` decimal(25,2) default NULL,
  `subtotal` decimal(25,2) default NULL,
  `total` decimal(25,2) default NULL,
  `taxtype` varchar(25) default NULL,
  `discount_percent` decimal(25,2) default NULL,
  `discount_amount` decimal(25,2) default NULL,
  `s_h_amount` decimal(25,2) default NULL,
  `terms_conditions` text,
  `currency_id` int(11) NOT NULL default '1',
  `conversion_rate` decimal(25,3) default NULL,
  `approvestatus` varchar(200) default '未提交',
  `approveby` int(11) default '0',
  `smownerid` int(11) default '0',
  `smcreatorid` int(11) default '0',
  `modifiedby` int(11) default '0',
  `createdtime` datetime default NULL,
  `modifiedtime` datetime default NULL,
  `deleted` int(1) default '0',
  `description` text,
  PRIMARY KEY  (`purchaseinvoiceid`),
  KEY `fk_2_vtiger_purchaseinvoice` USING BTREE (`purchaseorder_id`),
  KEY `purchaseinvoice_contactid_idx` USING BTREE (`contactid`),
  KEY `purchaseinvoice_accountid_idx` USING BTREE (`vendorid`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
delimiter;

CREATE TABLE IF NOT EXISTS `ld_purchaseinvoicecf` (
  `purchaseinvoiceid` int(11) default NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
delimiter;

CREATE TABLE IF NOT EXISTS `ld_purchaseinvoicetype` (
  `purchaseinvoicetypeid` int(11) default NULL,
  `purchaseinvoicetype` varchar(100) default NULL,
  `presence` int(1) NOT NULL default '1',
  `picklist_valueid` int(19) default NULL,
  PRIMARY KEY  (`purchaseinvoicetypeid`),
  KEY `fk_2_vtiger_purchaseinvoicetype` USING BTREE (`purchaseinvoicetype`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
delimiter;

CREATE TABLE IF NOT EXISTS `ld_purchaseinvoicestatus` (
  `purchaseinvoicestatusid` int(11) default NULL,
  `purchaseinvoicestatus` varchar(100) default NULL,
  `presence` int(1) NOT NULL default '1',
  `picklist_valueid` int(19) default NULL,
  PRIMARY KEY  (`purchaseinvoicestatusid`),
  KEY `fk_2_vtiger_purchaseinvoicetype` USING BTREE (`purchaseinvoicestatus`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
delimiter;

SELECT id into @pickvalue FROM ld_picklistvalues_seq;
insert into `ld_purchaseinvoicetype`(`purchaseinvoicetypeid`,`purchaseinvoicetype`,`presence`,`picklist_valueid`)
select 1,'--无--',1,@pickvalue+1
from dual where not EXISTS(select 1 from ld_purchaseinvoicetype where purchaseinvoicetypeid = 1);

insert into `ld_purchaseinvoicetype`(`purchaseinvoicetypeid`,`purchaseinvoicetype`,`presence`,`picklist_valueid`)
select 2,'赠票',1,@pickvalue+2
from dual where not EXISTS(select 1 from ld_purchaseinvoicetype where purchaseinvoicetypeid = 2);

insert into `ld_purchaseinvoicetype`(`purchaseinvoicetypeid`,`purchaseinvoicetype`,`presence`,`picklist_valueid`)
select 3,'普票',1,@pickvalue+3
from dual where not EXISTS(select 1 from ld_purchaseinvoicetype where purchaseinvoicetypeid = 3);

insert into `ld_purchaseinvoicetype`(`purchaseinvoicetypeid`,`purchaseinvoicetype`,`presence`,`picklist_valueid`)
select 4,'收据',1,@pickvalue+4
from dual where not EXISTS(select 1 from ld_purchaseinvoicetype where purchaseinvoicetypeid = 4);

insert into `ld_purchaseinvoicestatus`(`purchaseinvoicestatusid`,`purchaseinvoicestatus`,`presence`,`picklist_valueid`)
select 1,'已创建',1,@pickvalue+5
from dual where not EXISTS(select 1 from ld_purchaseinvoicestatus where purchaseinvoicestatusid = 1);

insert into `ld_purchaseinvoicestatus`(`purchaseinvoicestatusid`,`purchaseinvoicestatus`,`presence`,`picklist_valueid`)
select 2,'已审批',1,@pickvalue+6
from dual where not EXISTS(select 1 from ld_purchaseinvoicestatus where purchaseinvoicestatusid = 2);

insert into `ld_purchaseinvoicestatus`(`purchaseinvoicestatusid`,`purchaseinvoicestatus`,`presence`,`picklist_valueid`)
select 3,'已寄送',1,@pickvalue+7
from dual where not EXISTS(select 1 from ld_purchaseinvoicestatus where purchaseinvoicestatusid = 3);

insert into `ld_purchaseinvoicestatus`(`purchaseinvoicestatusid`,`purchaseinvoicestatus`,`presence`,`picklist_valueid`)
select 4,'已付款',1,@pickvalue+8
from dual where not EXISTS(select 1 from ld_purchaseinvoicestatus where purchaseinvoicestatusid = 4);

update ld_picklistvalues_seq set id = @pickvalue+8;

CREATE TABLE IF NOT EXISTS `ld_purchaseinvoicetype_seq` (
  `id` int(11) default 0
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
delimiter;

CREATE TABLE IF NOT EXISTS `ld_purchaseinvoicestatus_seq` (
  `id` int(11) default 0
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
delimiter;

insert into `ld_purchaseinvoicetype_seq`(id) select 4
from dual where not EXISTS(select 1 from ld_purchaseinvoicetype_seq where id > 0);
insert into `ld_purchaseinvoicestatus_seq`(id) select 4
from dual where not EXISTS(select 1 from ld_purchaseinvoicetype_seq where id > 0);
delimiter;

SELECT id INTO @picklistid FROM LD_picklist_seq LIMIT 1;
UPDATE LD_picklist_seq SET id = @picklistid+1 WHERE NOT EXISTS (SELECT 1 FROM LD_picklist WHERE NAME='purchaseinvoicetype');
INSERT INTO LD_picklist(picklistid,NAME)
SELECT @picklistid+1,'purchaseinvoicetype'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM LD_picklist WHERE NAME='purchaseinvoicetype');
delimiter;
SELECT id INTO @picklistid FROM LD_picklist_seq LIMIT 1;
UPDATE LD_picklist_seq SET id = @picklistid+1 WHERE NOT EXISTS (SELECT 1 FROM LD_picklist WHERE NAME='purchaseinvoicestatus');
INSERT INTO LD_picklist(picklistid,NAME)
SELECT @picklistid+1,'purchaseinvoicestatus'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM LD_picklist WHERE NAME='purchaseinvoicestatus');
delimiter;

select max(tabid)+1 into @tabid from ld_tab;
select max(tabsequence) into @tabsequence from ld_tab;
-- 只有企业版才默认启用(versiontype : 1)
SELECT COUNT(id) INTO @versionid FROM ld_version WHERE versiontype = 1;
SELECT CASE WHEN @versionid > 0 THEN 0 ELSE 1 END INTO @presence;

insert into ld_tab(tabid,name,presence,tabsequence,tablabel,ownedby,isentitytype,parent,printtab)
select @tabid,'PurchaseInvoice',@presence,@tabsequence+1,'PurchaseInvoice',0,1,'Tools',0
from dual where not EXISTS(select 1 from ld_tab where tablabel ='PurchaseInvoice');
delimiter;

select parenttabid into @parenttabid from ld_parenttab where parenttab_label = 'Finacial';
SELECT tabid INTO @invoicetabid FROM ld_tab WHERE NAME = 'Invoice';

SELECT sequence INTO @seq FROM ld_parenttabrel WHERE parenttabid = @parenttabid AND tabid = @invoicetabid;
SELECT @seq+1 INTO @seq1;
UPDATE ld_parenttabrel SET sequence = (@seq1:=@seq1+1) WHERE parenttabid = @parenttabid AND sequence > @seq ORDER BY sequence;
UPDATE ld_parenttabrel SET sequence = @seq+2 WHERE parenttabid = @parenttabid AND sequence = @seq and tabid != @invoicetabid ORDER BY sequence;

select tabid into @tabid from ld_tab where `name` = 'PurchaseInvoice';
insert into ld_parenttabrel(parenttabid,tabid,sequence)
select @parenttabid,@tabid,@seq+1
from dual where not EXISTS(select 1 from ld_parenttabrel  where parenttabid = @parenttabid and tabid =@tabid);
delimiter;

select tabid into @tabid from ld_tab where `name` = 'PurchaseInvoice';
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'zh','LD_tab',@tabid,@tabid,'采购发票'
from dual where not EXISTS(select 1 from ld_tranlabel  where languagetype = 'zh'
and trantable ='LD_tab' and tabid = @tabid and fieldlabel='采购发票');
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'en','LD_tab',@tabid,@tabid,'Purchase Invoice'
from dual where not EXISTS(select 1 from ld_tranlabel  where languagetype = 'en'
and trantable ='LD_tab' and tabid = @tabid and fieldlabel='Purchase Invoice');

insert into ld_ws_entity(name,handler_path,handler_class,ismodule)
select 'PurchaseInvoice','include/Webservices/VtigerModuleOperation.php','VtigerModuleOperation',1
from dual where not EXISTS(select 1 from ld_ws_entity  where name = 'PurchaseInvoice' );
delimiter;

select tabid into @tabid from ld_tab where `name` = 'PurchaseInvoice';
insert into LD_org_share_action2tab(share_action_id,tabid) select 0,@tabid from dual
where not exists(select 1 from LD_org_share_action2tab where share_action_id=0 and tabid=@tabid);

insert into LD_org_share_action2tab(share_action_id,tabid) select 1,@tabid from dual
where not exists(select 1 from LD_org_share_action2tab where share_action_id=1 and tabid=@tabid);

insert into LD_org_share_action2tab(share_action_id,tabid) select 2,@tabid from dual
where not exists(select 1 from LD_org_share_action2tab where share_action_id=2 and tabid=@tabid);

insert into LD_org_share_action2tab(share_action_id,tabid) select 3,@tabid from dual
where not exists(select 1 from LD_org_share_action2tab where share_action_id=3 and tabid=@tabid);
select max(ruleid) into @ruleid from LD_def_org_share;
update LD_def_org_share_seq set id=@ruleid+1 where  not exists(select 1 from LD_Def_org_share where tabid=@tabid);
insert into LD_def_org_share(ruleid,tabid,permission,editstatus)
select @ruleid+1,@tabid,3,0  from dual where  not exists(select 1 from LD_Def_org_share where tabid=@tabid);


insert into ld_customview(cvid,viewname,setdefault,entitytype,status,userid,pagewidthpercent)
select (select max(id)+1 from ld_customview_seq),'All',1,'PurchaseInvoice',0,1,100
from dual where not EXISTS(select 1 from ld_customview  where viewname = 'All'
and entitytype ='PurchaseInvoice');
update ld_customview_seq set id = (select max(cvid)+1 from ld_customview);
delimiter;

select cvid into @cvid from ld_customview where entitytype = 'PurchaseInvoice' and viewname = 'All';
select tabid into @tabid from ld_tab where `name`='PurchaseInvoice';
delete from ld_tabwithproductview where cvid = @cvid;

insert into ld_tabwithproductview(tabid,columns,sequence,cvid)
select @tabid,'LD_purchaseinvoice:subject:subject:PurchaseInvoice_fieldlabel:V',0,@cvid
from dual where not EXISTS(select 1 from ld_tabwithproductview  where cvid = @cvid
and columns = 'LD_purchaseinvoice:subject:subject:PurchaseInvoice_fieldlabel:V');

insert into ld_tabwithproductview(tabid,columns,sequence,cvid)
select @tabid,'LD_purchaseinvoice:purchaseinvoice_no:purchaseinvoice_no:PurchaseInvoice_fieldlabel:V',1,@cvid
from dual where not EXISTS(select 1 from ld_tabwithproductview  where cvid = @cvid
and columns = 'LD_purchaseinvoice:purchaseinvoice_no:purchaseinvoice_no:PurchaseInvoice_fieldlabel:V');


insert into ld_tabwithproductview(tabid,columns,sequence,cvid)
select @tabid,'LD_purchaseinvoice:vendorid:vendor_id:PurchaseInvoice_fieldlabel:I',2,@cvid
from dual where not EXISTS(select 1 from ld_tabwithproductview  where cvid = @cvid
and columns = 'LD_purchaseinvoice:vendorid:vendor_id:PurchaseInvoice_fieldlabel:I');


insert into ld_tabwithproductview(tabid,columns,sequence,cvid)
select @tabid,'LD_purchaseinvoice:purchaseinvoicestatus:purchaseinvoicestatus:PurchaseInvoice_fieldlabel:V',3,@cvid
from dual where not EXISTS(select 1 from ld_tabwithproductview  where cvid = @cvid
and columns = 'LD_purchaseinvoice:purchaseinvoicestatus:purchaseinvoicestatus:PurchaseInvoice_fieldlabel:V');


insert into ld_tabwithproductview(tabid,columns,sequence,cvid)
select @tabid,'LD_purchaseinvoice:total:hdnGrandTotal:PurchaseInvoice_fieldlabel:N',4,@cvid
from dual where not EXISTS(select 1 from ld_tabwithproductview  where cvid = @cvid
and columns = 'LD_purchaseinvoice:total:hdnGrandTotal:PurchaseInvoice_fieldlabel:N');


insert into ld_tabwithproductview(tabid,columns,sequence,cvid)
select @tabid,'LD_purchaseinvoice:purchaseinvoicedate:purchaseinvoicedate:PurchaseInvoice_fieldlabel:D',5,@cvid
from dual where not EXISTS(select 1 from ld_tabwithproductview  where cvid = @cvid
and columns = 'LD_purchaseinvoice:purchaseinvoicedate:purchaseinvoicedate:PurchaseInvoice_fieldlabel:D');


insert into ld_tabwithproductview(tabid,columns,sequence,cvid)
select @tabid,'LD_purchaseinvoice:purchaseinvoicetype:purchaseinvoicetype:PurchaseInvoice_fieldlabel:V',6,@cvid
from dual where not EXISTS(select 1 from ld_tabwithproductview  where cvid = @cvid
and columns = 'LD_purchaseinvoice:purchaseinvoicetype:purchaseinvoicetype:PurchaseInvoice_fieldlabel:V');


insert into ld_tabwithproductview(tabid,columns,sequence,cvid)
select @tabid,'LD_purchaseinvoice:purchaseinvoicenum:purchaseinvoicenum:PurchaseInvoice_fieldlabel:V',7,@cvid
from dual where not EXISTS(select 1 from ld_tabwithproductview  where cvid = @cvid
and columns = 'LD_purchaseinvoice:purchaseinvoicenum:purchaseinvoicenum:PurchaseInvoice_fieldlabel:V');


insert into ld_tabwithproductview(tabid,columns,sequence,cvid)
select @tabid,'LD_purchaseinvoice:smownerid:smownerid:PurchaseInvoice_fieldlabel:V',8,@cvid
from dual where not EXISTS(select 1 from ld_tabwithproductview  where cvid = @cvid
and columns = 'LD_purchaseinvoice:smownerid:smownerid:PurchaseInvoice_fieldlabel:V');


insert into ld_customview(cvid,viewname,setdefault,entitytype,status,userid,pagewidthpercent)
select (select max(id)+1 from ld_customview_seq),'本周创建',1,'PurchaseInvoice',1,1,100
from dual where not EXISTS(select 1 from ld_customview  where viewname = '本周创建'
and entitytype ='PurchaseInvoice');
update ld_customview_seq set id = (select max(cvid)+1 from ld_customview);
delimiter;

select cvid into @cvid from ld_customview where entitytype = 'PurchaseInvoice' and viewname = '本周创建';
select tabid into @tabid from ld_tab where `name`='PurchaseInvoice';
delete from ld_tabwithproductview where cvid =  @cvid;

insert into ld_tabwithproductview(tabid,columns,sequence,cvid)
select @tabid,'LD_purchaseinvoice:subject:subject:PurchaseInvoice_fieldlabel:V',0,@cvid
from dual where not EXISTS(select 1 from ld_tabwithproductview  where cvid = @cvid
and columns = 'LD_purchaseinvoice:subject:subject:PurchaseInvoice_fieldlabel:V');


insert into ld_tabwithproductview(tabid,columns,sequence,cvid)
select @tabid,'LD_purchaseinvoice:purchaseinvoice_no:purchaseinvoice_no:PurchaseInvoice_fieldlabel:V',1,@cvid
from dual where not EXISTS(select 1 from ld_tabwithproductview  where cvid = @cvid
and columns = 'LD_purchaseinvoice:purchaseinvoice_no:purchaseinvoice_no:PurchaseInvoice_fieldlabel:V');


insert into ld_tabwithproductview(tabid,columns,sequence,cvid)
select @tabid,'LD_purchaseinvoice:vendorid:vendor_id:PurchaseInvoice_fieldlabel:I',2,@cvid
from dual where not EXISTS(select 1 from ld_tabwithproductview  where cvid = @cvid
and columns = 'LD_purchaseinvoice:vendorid:vendor_id:PurchaseInvoice_fieldlabel:I');

insert into ld_tabwithproductview(tabid,columns,sequence,cvid)
select @tabid,'LD_purchaseinvoice:purchaseinvoicestatus:purchaseinvoicestatus:PurchaseInvoice_fieldlabel:V',3,@cvid
from dual where not EXISTS(select 1 from ld_tabwithproductview  where cvid = @cvid
and columns = 'LD_purchaseinvoice:purchaseinvoicestatus:purchaseinvoicestatus:PurchaseInvoice_fieldlabel:V');

insert into ld_tabwithproductview(tabid,columns,sequence,cvid)
select @tabid,'LD_purchaseinvoice:total:hdnGrandTotal:PurchaseInvoice_fieldlabel:N',4,@cvid
from dual where not EXISTS(select 1 from ld_tabwithproductview  where cvid = @cvid
and columns = 'LD_purchaseinvoice:total:hdnGrandTotal:PurchaseInvoice_fieldlabel:N');

insert into ld_tabwithproductview(tabid,columns,sequence,cvid)
select @tabid,'LD_purchaseinvoice:purchaseinvoicedate:purchaseinvoicedate:PurchaseInvoice_fieldlabel:D',5,@cvid
from dual where not EXISTS(select 1 from ld_tabwithproductview  where cvid = @cvid
and columns = 'LD_purchaseinvoice:purchaseinvoicedate:purchaseinvoicedate:PurchaseInvoice_fieldlabel:D');


insert into ld_tabwithproductview(tabid,columns,sequence,cvid)
select @tabid,'LD_purchaseinvoice:purchaseinvoicetype:purchaseinvoicetype:PurchaseInvoice_fieldlabel:V',6,@cvid
from dual where not EXISTS(select 1 from ld_tabwithproductview  where cvid = @cvid
and columns = 'LD_purchaseinvoice:purchaseinvoicetype:purchaseinvoicetype:PurchaseInvoice_fieldlabel:V');


insert into ld_tabwithproductview(tabid,columns,sequence,cvid)
select @tabid,'LD_purchaseinvoice:purchaseinvoicenum:purchaseinvoicenum:PurchaseInvoice_fieldlabel:V',7,@cvid
from dual where not EXISTS(select 1 from ld_tabwithproductview  where cvid = @cvid
and columns = 'LD_purchaseinvoice:purchaseinvoicenum:purchaseinvoicenum:PurchaseInvoice_fieldlabel:V');


insert into ld_tabwithproductview(tabid,columns,sequence,cvid)
select @tabid,'LD_purchaseinvoice:smownerid:smownerid:PurchaseInvoice_fieldlabel:V',8,@cvid
from dual where not EXISTS(select 1 from ld_tabwithproductview  where cvid = @cvid
and columns = 'LD_purchaseinvoice:smownerid:smownerid:PurchaseInvoice_fieldlabel:V');

insert into ld_cvstdfilter(cvid,columnname,stdfilter)
select @cvid,'LD_purchaseinvoice:purchaseinvoicedate:purchaseinvoicedate:Leads_Modified_Time','thisweek'
from dual where not EXISTS(select 1 from ld_cvstdfilter  where cvid = @cvid
and columnname = 'LD_purchaseinvoice:purchaseinvoicedate:purchaseinvoicedate:Leads_Modified_Time');


insert into ld_customview(cvid,viewname,setdefault,entitytype,status,userid,pagewidthpercent)
select (select max(id)+1 from ld_customview_seq),'本月创建',1,'PurchaseInvoice',1,1,100
from dual where not EXISTS(select 1 from ld_customview  where viewname = '本月创建'
and entitytype ='PurchaseInvoice');
update ld_customview_seq set id = (select max(cvid)+1 from ld_customview);
delimiter;
select cvid into @cvid from ld_customview where entitytype = 'PurchaseInvoice' and viewname = '本月创建';
select tabid into @tabid from ld_tab where `name`='PurchaseInvoice';
delete from ld_tabwithproductview where cvid =  @cvid;-- 删除关联字段，以后可以去掉

insert into ld_tabwithproductview(tabid,columns,sequence,cvid)
select @tabid,'LD_purchaseinvoice:subject:subject:PurchaseInvoice_fieldlabel:V',0,@cvid
from dual where not EXISTS(select 1 from ld_tabwithproductview  where cvid = @cvid
and columns = 'LD_purchaseinvoice:subject:subject:PurchaseInvoice_fieldlabel:V');


insert into ld_tabwithproductview(tabid,columns,sequence,cvid)
select @tabid,'LD_purchaseinvoice:purchaseinvoice_no:purchaseinvoice_no:PurchaseInvoice_fieldlabel:V',1,@cvid
from dual where not EXISTS(select 1 from ld_tabwithproductview  where cvid = @cvid
and columns = 'LD_purchaseinvoice:purchaseinvoice_no:purchaseinvoice_no:PurchaseInvoice_fieldlabel:V');


insert into ld_tabwithproductview(tabid,columns,sequence,cvid)
select @tabid,'LD_purchaseinvoice:vendorid:vendor_id:PurchaseInvoice_fieldlabel:I',2,@cvid
from dual where not EXISTS(select 1 from ld_tabwithproductview  where cvid = @cvid
and columns = 'LD_purchaseinvoice:vendorid:vendor_id:PurchaseInvoice_fieldlabel:I');


insert into ld_tabwithproductview(tabid,columns,sequence,cvid)
select @tabid,'LD_purchaseinvoice:purchaseinvoicestatus:purchaseinvoicestatus:PurchaseInvoice_fieldlabel:V',3,@cvid
from dual where not EXISTS(select 1 from ld_tabwithproductview  where cvid = @cvid
and columns = 'LD_purchaseinvoice:purchaseinvoicestatus:purchaseinvoicestatus:PurchaseInvoice_fieldlabel:V');


insert into ld_tabwithproductview(tabid,columns,sequence,cvid)
select @tabid,'LD_purchaseinvoice:total:hdnGrandTotal:PurchaseInvoice_fieldlabel:N',4,@cvid
from dual where not EXISTS(select 1 from ld_tabwithproductview  where cvid = @cvid
and columns = 'LD_purchaseinvoice:total:hdnGrandTotal:PurchaseInvoice_fieldlabel:N');

insert into ld_tabwithproductview(tabid,columns,sequence,cvid)
select @tabid,'LD_purchaseinvoice:purchaseinvoicedate:purchaseinvoicedate:PurchaseInvoice_fieldlabel:D',5,@cvid
from dual where not EXISTS(select 1 from ld_tabwithproductview  where cvid = @cvid
and columns = 'LD_purchaseinvoice:purchaseinvoicedate:purchaseinvoicedate:PurchaseInvoice_fieldlabel:D');


insert into ld_tabwithproductview(tabid,columns,sequence,cvid)
select @tabid,'LD_purchaseinvoice:purchaseinvoicetype:purchaseinvoicetype:PurchaseInvoice_fieldlabel:V',6,@cvid
from dual where not EXISTS(select 1 from ld_tabwithproductview  where cvid = @cvid
and columns = 'LD_purchaseinvoice:purchaseinvoicetype:purchaseinvoicetype:PurchaseInvoice_fieldlabel:V');

/*--发票号码--*/
insert into ld_tabwithproductview(tabid,columns,sequence,cvid)
select @tabid,'LD_purchaseinvoice:purchaseinvoicenum:purchaseinvoicenum:PurchaseInvoice_fieldlabel:V',7,@cvid
from dual where not EXISTS(select 1 from ld_tabwithproductview  where cvid = @cvid
and columns = 'LD_purchaseinvoice:purchaseinvoicenum:purchaseinvoicenum:PurchaseInvoice_fieldlabel:V');

/*--负责人--*/
insert into ld_tabwithproductview(tabid,columns,sequence,cvid)
select @tabid,'LD_purchaseinvoice:smownerid:smownerid:PurchaseInvoice_fieldlabel:V',8,@cvid
from dual where not EXISTS(select 1 from ld_tabwithproductview  where cvid = @cvid
and columns = 'LD_purchaseinvoice:smownerid:smownerid:PurchaseInvoice_fieldlabel:V');

insert into ld_cvstdfilter(cvid,columnname,stdfilter)
select @cvid,'LD_purchaseinvoice:purchaseinvoicedate:purchaseinvoicedate:Leads_Modified_Time','thismonth'
from dual where not EXISTS(select 1 from ld_cvstdfilter  where cvid = @cvid
and columnname = 'LD_purchaseinvoice:purchaseinvoicedate:purchaseinvoicedate:Leads_Modified_Time');

select tabid into @tabid from ld_tab where `name` = 'PurchaseInvoice';
insert into ld_blocks(blockid,tabid,blocklabel,sequence)
select (select max(blockid) from ld_blocks)+1,@tabid,'LBL_PURCHASEINVOICE_INFO',1 from dual where not exists (select * from ld_blocks where
tabid = @tabid and blocklabel = 'LBL_PURCHASEINVOICE_INFO');
update ld_blocks_seq set id = (select max(blockid)+1 from ld_blocks);

select blockid into @blockid from ld_blocks where tabid = @tabid and blocklabel = 'LBL_PURCHASEINVOICE_INFO';
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'zh','LD_blocks',@tabid,@blockid,'基本信息'
from dual where not EXISTS(select 1 from ld_tranlabel  where languagetype = 'zh'
and trantable ='LD_blocks' and tabid = @tabid and relateid=@blockid);

insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'en','LD_blocks',@tabid,@blockid,'Basic Information'
from dual where not EXISTS(select 1 from ld_tranlabel  where languagetype = 'en'
and trantable ='LD_blocks' and tabid = @tabid and relateid=@blockid);

DELETE from ld_field where tabid = @tabid;
select max(fieldid) into @fieldid from ld_field;
insert into ld_field(tabid,fieldid,columnname,tablename,uitype,fieldname,fieldlabel,block,displaytype,presence,typeofdata)
select @tabid,@fieldid+1,'subject','LD_purchaseinvoice',2,'subject','主题',@blockid,1,0,'V~M' from dual where not exists
(select * from ld_field where tabid = @tabid and columnname = 'subject');

insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'zh','LD_field',@tabid,@fieldid+1,'主题'
from dual where not EXISTS(select 1 from ld_tranlabel  where languagetype = 'zh'
and trantable ='LD_field' and tabid = @tabid and relateid=@fieldid+1);
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'en','LD_field',@tabid,@fieldid+1,'Subject'
from dual where not EXISTS(select 1 from ld_tranlabel  where languagetype = 'en'
and trantable ='LD_field' and tabid = @tabid and relateid=@fieldid+1);

insert into ld_field(tabid,fieldid,columnname,tablename,uitype,fieldname,fieldlabel,block,displaytype,presence,typeofdata,masseditable)
select @tabid,@fieldid+2,'purchaseinvoice_no','LD_purchaseinvoice',4,'purchaseinvoice_no','Purchase Invoice No',@blockid,1,0,'V~O',2 from dual where not exists
(select * from ld_field where tabid = @tabid and columnname = 'purchaseinvoice_no');

insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'zh','LD_field',@tabid,@fieldid+2,'发票编号'
from dual where not EXISTS(select 1 from ld_tranlabel  where languagetype = 'zh'
and trantable ='LD_field' and tabid = @tabid and relateid=@fieldid+2);
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'en','LD_field',@tabid,@fieldid+2,'Purchase Invoice No'
from dual where not EXISTS(select 1 from ld_tranlabel  where languagetype = 'en'
and trantable ='LD_field' and tabid = @tabid and relateid=@fieldid+2);

insert into ld_field(tabid,fieldid,columnname,tablename,uitype,fieldname,fieldlabel,block,displaytype,presence,typeofdata)
select @tabid,@fieldid+3,'vendorid','LD_purchaseinvoice',81,'vendor_id','Vendor Name',@blockid,1,0,'I~M' from dual where not exists
(select * from ld_field where tabid = @tabid and columnname = 'vendorid');

insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'zh','LD_field',@tabid,@fieldid+3,'供应商'
from dual where not EXISTS(select 1 from ld_tranlabel  where languagetype = 'zh'
and trantable ='LD_field' and tabid = @tabid and relateid=@fieldid+3);
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'en','LD_field',@tabid,@fieldid+3,'Vendor Name'
from dual where not EXISTS(select 1 from ld_tranlabel  where languagetype = 'en'
and trantable ='LD_field' and tabid = @tabid and relateid=@fieldid+3);

insert into ld_field(tabid,fieldid,columnname,tablename,uitype,fieldname,fieldlabel,block,displaytype,presence,typeofdata,masseditable)
select @tabid,@fieldid+4,'contactid','LD_purchaseinvoice',96,'contactid','Contact Name',@blockid,2,1,'I~O',2 from dual where not exists
(select * from ld_field where tabid = @tabid and columnname = 'contactid');

insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'zh','LD_field',@tabid,@fieldid+4,'供应商联系人'
from dual where not EXISTS(select 1 from ld_tranlabel  where languagetype = 'zh'
and trantable ='LD_field' and tabid = @tabid and relateid=@fieldid+4);
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'en','LD_field',@tabid,@fieldid+4,'Contact Name'
from dual where not EXISTS(select 1 from ld_tranlabel  where languagetype = 'en'
and trantable ='LD_field' and tabid = @tabid and relateid=@fieldid+4);

insert into ld_field(tabid,fieldid,columnname,tablename,uitype,fieldname,fieldlabel,block,displaytype,presence,typeofdata)
select @tabid,@fieldid+5,'purchaseinvoicetype','LD_purchaseinvoice',15,'purchaseinvoicetype','票据类型',@blockid,1,0,'V~O' from dual where not exists
(select * from ld_field where tabid = @tabid and columnname = 'purchaseinvoicetype');

insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'zh','LD_field',@tabid,@fieldid+5,'票据类型'
from dual where not EXISTS(select 1 from ld_tranlabel  where languagetype = 'zh'
and trantable ='LD_field' and tabid = @tabid and relateid=@fieldid+5);
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'en','LD_field',@tabid,@fieldid+5,'Type'
from dual where not EXISTS(select 1 from ld_tranlabel  where languagetype = 'en'
and trantable ='LD_field' and tabid = @tabid and relateid=@fieldid+5);

insert into ld_field(tabid,fieldid,columnname,tablename,uitype,fieldname,fieldlabel,block,displaytype,presence,typeofdata)
select @tabid,@fieldid+6,'purchaseinvoicestatus','LD_purchaseinvoice',15,'purchaseinvoicestatus','状态',@blockid,1,0,'V~O' from dual where not exists
(select * from ld_field where tabid = @tabid and columnname = 'purchaseinvoicestatus');

insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'zh','LD_field',@tabid,@fieldid+6,'状态'
from dual where not EXISTS(select 1 from ld_tranlabel  where languagetype = 'zh'
and trantable ='LD_field' and tabid = @tabid and relateid=@fieldid+6);
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'en','LD_field',@tabid,@fieldid+6,'Status'
from dual where not EXISTS(select 1 from ld_tranlabel  where languagetype = 'en'
and trantable ='LD_field' and tabid = @tabid and relateid=@fieldid+6);

insert into ld_field(tabid,fieldid,columnname,tablename,uitype,fieldname,fieldlabel,block,displaytype,presence,typeofdata)
select @tabid,@fieldid+7,'purchaseinvoicenum','LD_purchaseinvoice',1,'purchaseinvoicenum','发票号码',@blockid,1,0,'V~O' from dual where not exists
(select * from ld_field where tabid = @tabid and columnname = 'purchaseinvoicenum');

insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'zh','LD_field',@tabid,@fieldid+7,'发票号码'
from dual where not EXISTS(select 1 from ld_tranlabel  where languagetype = 'zh'
and trantable ='LD_field' and tabid = @tabid and relateid=@fieldid+7);
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'en','LD_field',@tabid,@fieldid+7,'Invoice Number'
from dual where not EXISTS(select 1 from ld_tranlabel  where languagetype = 'en'
and trantable ='LD_field' and tabid = @tabid and relateid=@fieldid+7);

insert into ld_field(tabid,fieldid,columnname,tablename,uitype,fieldname,fieldlabel,block,displaytype,presence,typeofdata)
select @tabid,@fieldid+8,'purchaseinvoicedate','LD_purchaseinvoice',5,'purchaseinvoicedate','开票日期',@blockid,1,0,'D~O' from dual where not exists
(select * from ld_field where tabid = @tabid and columnname = 'purchaseinvoicedate');

insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'zh','LD_field',@tabid,@fieldid+8,'开票日期'
from dual where not EXISTS(select 1 from ld_tranlabel  where languagetype = 'zh'
and trantable ='LD_field' and tabid = @tabid and relateid=@fieldid+8);
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'en','LD_field',@tabid,@fieldid+8,'Invoice Date'
from dual where not EXISTS(select 1 from ld_tranlabel  where languagetype = 'en'
and trantable ='LD_field' and tabid = @tabid and relateid=@fieldid+8);


insert into ld_field(tabid,fieldid,columnname,tablename,uitype,fieldname,fieldlabel,block,displaytype,presence,typeofdata,masseditable)
select @tabid,@fieldid+9,'','',201,'','选择源单',@blockid,1,0,'V~O',2 from dual where not exists
(select * from ld_field where tabid = @tabid and uitype = 201);
update ld_field_seq set id = (select max(fieldid)+1 from ld_field);

insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'zh','LD_field',@tabid,@fieldid+9,'选择源单'
from dual where not EXISTS(select 1 from ld_tranlabel  where languagetype = 'zh'
and trantable ='LD_field' and tabid = @tabid and relateid=@fieldid+9);
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'en','LD_field',@tabid,@fieldid+9,'Data sources'
from dual where not EXISTS(select 1 from ld_tranlabel  where languagetype = 'en'
and trantable ='LD_field' and tabid = @tabid and relateid=@fieldid+9);

insert into ld_field(tabid,fieldid,columnname,tablename,uitype,fieldname,fieldlabel,block,displaytype,presence,typeofdata,masseditable)
select @tabid,@fieldid+10,'purchaseorder_id','LD_purchaseinvoice',150,'purchaseorder_id','采购订单',@blockid,1,1,'I~O',2 from dual where not exists
(select * from ld_field where tabid = @tabid and columnname = 'purchaseorder_id');

insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'zh','LD_field',@tabid,@fieldid+10,'采购订单'
from dual where not EXISTS(select 1 from ld_tranlabel  where languagetype = 'zh'
and trantable ='LD_field' and tabid = @tabid and relateid=@fieldid+10);
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'en','LD_field',@tabid,@fieldid+10,'Purchase Order'
from dual where not EXISTS(select 1 from ld_tranlabel  where languagetype = 'en'
and trantable ='LD_field' and tabid = @tabid and relateid=@fieldid+10);

insert into ld_field(tabid,fieldid,columnname,tablename,uitype,fieldname,fieldlabel,block,displaytype,presence,typeofdata)
select @tabid,@fieldid+11,'adjustment','LD_purchaseinvoice',72,'txtAdjustment','Adjustment',@blockid,3,0,'NN~O' from dual where not exists
(select * from ld_field where tabid = @tabid and columnname = 'adjustment');

insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'zh','LD_field',@tabid,@fieldid+11,'调整'
from dual where not EXISTS(select 1 from ld_tranlabel  where languagetype = 'zh'
and trantable ='LD_field' and tabid = @tabid and relateid=@fieldid+11);
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'en','LD_field',@tabid,@fieldid+11,'Adjustment'
from dual where not EXISTS(select 1 from ld_tranlabel  where languagetype = 'en'
and trantable ='LD_field' and tabid = @tabid and relateid=@fieldid+11);


insert into ld_field(tabid,fieldid,columnname,tablename,uitype,fieldname,fieldlabel,block,displaytype,presence,typeofdata)
select @tabid,@fieldid+12,'subtotal','LD_purchaseinvoice',72,'hdnSubTotal','Sub Total',@blockid,3,0,'N~O' from dual where not exists
(select * from ld_field where tabid = @tabid and columnname = 'subtotal');

insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'zh','LD_field',@tabid,@fieldid+12,'小计'
from dual where not EXISTS(select 1 from ld_tranlabel  where languagetype = 'zh'
and trantable ='LD_field' and tabid = @tabid and relateid=@fieldid+12);
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'en','LD_field',@tabid,@fieldid+12,'Sub Total'
from dual where not EXISTS(select 1 from ld_tranlabel  where languagetype = 'en'
and trantable ='LD_field' and tabid = @tabid and relateid=@fieldid+12);


insert into ld_field(tabid,fieldid,columnname,tablename,uitype,fieldname,fieldlabel,block,displaytype,presence,typeofdata)
select @tabid,@fieldid+13,'total','LD_purchaseinvoice',72,'hdnGrandTotal','Total',@blockid,3,0,'N~O' from dual where not exists
(select * from ld_field where tabid = @tabid and columnname = 'total');

insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'zh','LD_field',@tabid,@fieldid+13,'合计'
from dual where not EXISTS(select 1 from ld_tranlabel  where languagetype = 'zh'
and trantable ='LD_field' and tabid = @tabid and relateid=@fieldid+13);
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'en','LD_field',@tabid,@fieldid+13,'Total'
from dual where not EXISTS(select 1 from ld_tranlabel  where languagetype = 'en'
and trantable ='LD_field' and tabid = @tabid and relateid=@fieldid+13);


insert into ld_field(tabid,fieldid,columnname,tablename,uitype,fieldname,fieldlabel,block,displaytype,presence,typeofdata)
select @tabid,@fieldid+14,'taxtype','LD_purchaseinvoice',16,'hdnTaxType','Tax Type',@blockid,3,0,'V~0' from dual where not exists
(select * from ld_field where tabid = @tabid and columnname = 'taxtype');

insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'zh','LD_field',@tabid,@fieldid+14,'税种'
from dual where not EXISTS(select 1 from ld_tranlabel  where languagetype = 'zh'
and trantable ='LD_field' and tabid = @tabid and relateid=@fieldid+14);
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'en','LD_field',@tabid,@fieldid+14,'Tax'
from dual where not EXISTS(select 1 from ld_tranlabel  where languagetype = 'en'
and trantable ='LD_field' and tabid = @tabid and relateid=@fieldid+14);


insert into ld_field(tabid,fieldid,columnname,tablename,uitype,fieldname,fieldlabel,block,displaytype,presence,typeofdata)
select @tabid,@fieldid+15,'discount_percent','LD_purchaseinvoice',72,'hdnDiscountPercent','Discount Percent',@blockid,3,0,'N~O' from dual where not exists
(select * from ld_field where tabid = @tabid and columnname = 'discount_percent');

insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'zh','LD_field',@tabid,@fieldid+15,'折扣百分比'
from dual where not EXISTS(select 1 from ld_tranlabel  where languagetype = 'zh'
and trantable ='LD_field' and tabid = @tabid and relateid=@fieldid+15);
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'en','LD_field',@tabid,@fieldid+15,'Discount Percent'
from dual where not EXISTS(select 1 from ld_tranlabel  where languagetype = 'en'
and trantable ='LD_field' and tabid = @tabid and relateid=@fieldid+15);

insert into ld_field(tabid,fieldid,columnname,tablename,uitype,fieldname,fieldlabel,block,displaytype,presence,typeofdata)
select @tabid,@fieldid+16,'discount_amount','LD_purchaseinvoice',72,'hdnDiscountAmount','Discount Amount',@blockid,1,3,'N~O' from dual where not exists
(select * from ld_field where tabid = @tabid and columnname = 'discount_amount');

insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'zh','LD_field',@tabid,@fieldid+16,'折扣直接降价'
from dual where not EXISTS(select 1 from ld_tranlabel  where languagetype = 'zh'
and trantable ='LD_field' and tabid = @tabid and relateid=@fieldid+16);
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'en','LD_field',@tabid,@fieldid+16,'Discount Amount'
from dual where not EXISTS(select 1 from ld_tranlabel  where languagetype = 'en'
and trantable ='LD_field' and tabid = @tabid and relateid=@fieldid+16);


insert into ld_field(tabid,fieldid,columnname,tablename,uitype,fieldname,fieldlabel,block,displaytype,presence,typeofdata)
select @tabid,@fieldid+17,'s_h_amount','LD_purchaseinvoice',72,'hdnS_H_Amount','运费和物流附加费',@blockid,3,0,'N~O' from dual where not exists
(select * from ld_field where tabid = @tabid and columnname = 's_h_amount');

insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'zh','LD_field',@tabid,@fieldid+17,'运费和物流附加费'
from dual where not EXISTS(select 1 from ld_tranlabel  where languagetype = 'zh'
and trantable ='LD_field' and tabid = @tabid and relateid=@fieldid+17);
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'en','LD_field',@tabid,@fieldid+17,'S&H Amount'
from dual where not EXISTS(select 1 from ld_tranlabel  where languagetype = 'en'
and trantable ='LD_field' and tabid = @tabid and relateid=@fieldid+17);


insert into ld_field(tabid,fieldid,columnname,tablename,uitype,fieldname,fieldlabel,block,displaytype,presence,typeofdata,issmownerid)
select @tabid,@fieldid+18,'smownerid','LD_purchaseinvoice',53,'smownerid','采购负责人',@blockid,1,0,'V~M',1 from dual where not exists
(select * from ld_field where tabid = @tabid and columnname = 'smownerid');

insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'zh','LD_field',@tabid,@fieldid+18,'采购负责人'
from dual where not EXISTS(select 1 from ld_tranlabel  where languagetype = 'zh'
and trantable ='LD_field' and tabid = @tabid and relateid=@fieldid+18);
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'en','LD_field',@tabid,@fieldid+18,'Assigned To'
from dual where not EXISTS(select 1 from ld_tranlabel  where languagetype = 'en'
and trantable ='LD_field' and tabid = @tabid and relateid=@fieldid+18);

insert into ld_field(tabid,fieldid,columnname,tablename,uitype,fieldname,fieldlabel,block,displaytype,presence,typeofdata)
select @tabid,@fieldid+19,'createdtime','LD_purchaseinvoice',70,'createdtime','创建时间',@blockid,2,0,'DT~O' from dual where not exists
(select * from ld_field where tabid = @tabid and columnname = 'createdtime');

insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'zh','LD_field',@tabid,@fieldid+19,'创建时间'
from dual where not EXISTS(select 1 from ld_tranlabel  where languagetype = 'zh'
and trantable ='LD_field' and tabid = @tabid and relateid=@fieldid+19);
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'en','LD_field',@tabid,@fieldid+19,'Created Time'
from dual where not EXISTS(select 1 from ld_tranlabel  where languagetype = 'en'
and trantable ='LD_field' and tabid = @tabid and relateid=@fieldid+19);

insert into ld_field(tabid,fieldid,columnname,tablename,uitype,fieldname,fieldlabel,block,displaytype,presence,typeofdata)
select @tabid,@fieldid+20,'modifiedtime','LD_purchaseinvoice',70,'modifiedtime','修改时间',@blockid,2,0,'DT~O' from dual where not exists
(select * from ld_field where tabid = @tabid and columnname = 'modifiedtime');

insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'zh','LD_field',@tabid,@fieldid+20,'修改时间'
from dual where not EXISTS(select 1 from ld_tranlabel  where languagetype = 'zh'
and trantable ='LD_field' and tabid = @tabid and relateid=@fieldid+20);
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'en','LD_field',@tabid,@fieldid+20,'Modified Time'
from dual where not EXISTS(select 1 from ld_tranlabel  where languagetype = 'en'
and trantable ='LD_field' and tabid = @tabid and relateid=@fieldid+20);

insert into ld_field(tabid,fieldid,columnname,tablename,uitype,fieldname,fieldlabel,block,displaytype,presence,typeofdata)
select @tabid,@fieldid+21,'modifiedby','LD_purchaseinvoice',52,'modifiedby','最新更新人',@blockid,3,0,'V~O' from dual where not exists
(select * from ld_field where tabid = @tabid and columnname = 'modifiedby');

insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'zh','LD_field',@tabid,@fieldid+21,'最新更新人'
from dual where not EXISTS(select 1 from ld_tranlabel  where languagetype = 'zh'
and trantable ='LD_field' and tabid = @tabid and relateid=@fieldid+21);
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'en','LD_field',@tabid,@fieldid+21,'Modified By'
from dual where not EXISTS(select 1 from ld_tranlabel  where languagetype = 'en'
and trantable ='LD_field' and tabid = @tabid and relateid=@fieldid+21);

insert into ld_field(tabid,fieldid,columnname,tablename,uitype,fieldname,fieldlabel,block,displaytype,presence,typeofdata)
select @tabid,@fieldid+22,'currency_id','LD_purchaseinvoice',117,'currency_id','货币',@blockid,3,0,'I~O' from dual where not exists
(select * from ld_field where tabid = @tabid and columnname = 'currency_id');

insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'zh','LD_field',@tabid,@fieldid+22,'货币'
from dual where not EXISTS(select 1 from ld_tranlabel  where languagetype = 'zh'
and trantable ='LD_field' and tabid = @tabid and relateid=@fieldid+22);
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'en','LD_field',@tabid,@fieldid+22,'Currency'
from dual where not EXISTS(select 1 from ld_tranlabel  where languagetype = 'en'
and trantable ='LD_field' and tabid = @tabid and relateid=@fieldid+22);

insert into ld_field(tabid,fieldid,columnname,tablename,uitype,fieldname,fieldlabel,block,displaytype,presence,typeofdata)
select @tabid,@fieldid+23,'conversion_rate','LD_purchaseinvoice',1,'conversion_rate','汇率',@blockid,3,0,'I~O' from dual where not exists
(select * from ld_field where tabid = @tabid and columnname = 'conversion_rate');

insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'zh','LD_field',@tabid,@fieldid+23,'汇率'
from dual where not EXISTS(select 1 from ld_tranlabel  where languagetype = 'zh'
and trantable ='LD_field' and tabid = @tabid and relateid=@fieldid+23);
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'en','LD_field',@tabid,@fieldid+23,'Exchange Rate'
from dual where not EXISTS(select 1 from ld_tranlabel  where languagetype = 'en'
and trantable ='LD_field' and tabid = @tabid and relateid=@fieldid+23);

insert into ld_field(tabid,fieldid,columnname,tablename,uitype,fieldname,fieldlabel,block,displaytype,presence,typeofdata)
select @tabid,@fieldid+24,'smcreatorid','LD_purchaseinvoice',52,'smcreatorid','创建人',@blockid,2,0,'V~O' from dual where not exists
(select * from ld_field where tabid = @tabid and columnname = 'smcreatorid');
update ld_field_seq set id = (select max(fieldid)+1 from ld_field);

insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'zh','LD_field',@tabid,@fieldid+24,'创建人'
from dual where not EXISTS(select 1 from ld_tranlabel  where languagetype = 'zh'
and trantable ='LD_field' and tabid = @tabid and relateid=@fieldid+24);
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'en','LD_field',@tabid,@fieldid+24,'Creator'
from dual where not EXISTS(select 1 from ld_tranlabel  where languagetype = 'en'
and trantable ='LD_field' and tabid = @tabid and relateid=@fieldid+24);

insert into ld_field(tabid,fieldid,columnname,tablename,uitype,fieldname,fieldlabel,block,displaytype,presence,typeofdata)
select @tabid,@fieldid+25,'approvestatus','LD_purchaseinvoice',130,'approvestatus','审批状态',@blockid,3,0,'V~O' from dual where not exists
(select * from ld_field where tabid = @tabid and columnname = 'approvestatus');

insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'zh','LD_field',@tabid,@fieldid+25,'审批状态'
from dual where not EXISTS(select 1 from ld_tranlabel  where languagetype = 'zh'
and trantable ='LD_field' and tabid = @tabid and relateid=@fieldid+25);
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'en','LD_field',@tabid,@fieldid+25,'Approval status'
from dual where not EXISTS(select 1 from ld_tranlabel  where languagetype = 'en'
and trantable ='LD_field' and tabid = @tabid and relateid=@fieldid+25);

insert into ld_field(tabid,fieldid,columnname,tablename,uitype,fieldname,fieldlabel,block,displaytype,presence,typeofdata)
select @tabid,@fieldid+26,'approveby','LD_purchaseinvoice',131,'approveby','审批人',@blockid,2,0,'V~O' from dual where not exists
(select * from ld_field where tabid = @tabid and columnname = 'approveby');

insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'zh','LD_field',@tabid,@fieldid+26,'审批人'
from dual where not EXISTS(select 1 from ld_tranlabel  where languagetype = 'zh'
and trantable ='LD_field' and tabid = @tabid and relateid=@fieldid+26);
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'en','LD_field',@tabid,@fieldid+26,'Approver'
from dual where not EXISTS(select 1 from ld_tranlabel  where languagetype = 'en'
and trantable ='LD_field' and tabid = @tabid and relateid=@fieldid+26);

insert into ld_blocks(blockid,tabid,blocklabel,sequence)
select (select max(blockid) from ld_blocks)+1,@tabid,'LBL_TERMS_INFORMATION',2 from dual where not exists (select * from ld_blocks where
tabid = @tabid and blocklabel = 'LBL_TERMS_INFORMATION');
update ld_blocks_seq set id = (select max(blockid)+1 from ld_blocks);

select blockid into @blockid from ld_blocks where tabid = @tabid and blocklabel = 'LBL_TERMS_INFORMATION';
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'zh','LD_blocks',@tabid,@blockid,'条款与条件'
from dual where not EXISTS(select 1 from ld_tranlabel  where languagetype = 'zh'
and trantable ='LD_blocks' and tabid = @tabid and relateid=@blockid);

insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'en','LD_blocks',@tabid,@blockid,'Terms & Conditions'
from dual where not EXISTS(select 1 from ld_tranlabel  where languagetype = 'en'
and trantable ='LD_blocks' and tabid = @tabid and relateid=@blockid);

insert into ld_field(tabid,fieldid,columnname,tablename,uitype,fieldname,fieldlabel,block,displaytype,presence,typeofdata)
select @tabid,@fieldid+27,'terms_conditions','LD_purchaseinvoice',19,'terms_conditions','条款与条件',@blockid,2,1,'V~O' from dual where not exists
(select * from ld_field where tabid = @tabid and columnname = 'terms_conditions');

insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'zh','LD_field',@tabid,@fieldid+27,'条款与条件'
from dual where not EXISTS(select 1 from ld_tranlabel  where languagetype = 'zh'
and trantable ='LD_field' and tabid = @tabid and relateid=@fieldid+27);
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'en','LD_field',@tabid,@fieldid+27,'Terms & Conditions'
from dual where not EXISTS(select 1 from ld_tranlabel  where languagetype = 'en'
and trantable ='LD_field' and tabid = @tabid and relateid=@fieldid+27);

insert into ld_blocks(blockid,tabid,blocklabel,sequence)
select (select max(blockid) from ld_blocks)+1,@tabid,'Description',3 from dual where not exists (select * from ld_blocks where
tabid = @tabid and blocklabel = 'Description');
update ld_blocks_seq set id = (select max(blockid)+1 from ld_blocks);

select blockid into @blockid from ld_blocks where tabid = @tabid and blocklabel = 'Description';
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'zh','LD_blocks',@tabid,@blockid,'备注信息'
from dual where not EXISTS(select 1 from ld_tranlabel  where languagetype = 'zh'
and trantable ='LD_blocks' and tabid = @tabid and relateid=@blockid);

insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'en','LD_blocks',@tabid,@blockid,'Description'
from dual where not EXISTS(select 1 from ld_tranlabel  where languagetype = 'en'
and trantable ='LD_blocks' and tabid = @tabid and relateid=@blockid);

insert into ld_field(tabid,fieldid,columnname,tablename,uitype,fieldname,fieldlabel,block,displaytype,presence,typeofdata)
select @tabid,@fieldid+28,'description','LD_purchaseinvoice',19,'description','备注',@blockid,1,0,'V~O' from dual where not exists
(select * from ld_field where tabid = @tabid and columnname = 'description');

insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'zh','LD_field',@tabid,@fieldid+28,'备注'
from dual where not EXISTS(select 1 from ld_tranlabel  where languagetype = 'zh'
and trantable ='LD_field' and tabid = @tabid and relateid=@fieldid+28);
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'en','LD_field',@tabid,@fieldid+28,'Description'
from dual where not EXISTS(select 1 from ld_tranlabel  where languagetype = 'en'
and trantable ='LD_field' and tabid = @tabid and relateid=@fieldid+28);

update ld_field_seq set id = (select max(fieldid) from ld_field);


select tabid into @tabid from ld_tab where `name` = 'PurchaseInvoice';
select id into @id from ld_links_seq;
insert into ld_links(linkid,tabid,linktype,linklabel,linkurl,linkicon,handler_path,handler_class,handler,sequence)
select @id+1,@tabid,'DETAILVIEWBASIC','View History',"javascript:ModTrackerCommon.showhistory('$RECORD$')",
'themes/images/pointer.gif','modules/ModTracker/ModTracker.php','ModTracker','isViewPermitted',0
from dual where not EXISTS(select 1 from ld_links  where tabid = @tabid
and linktype ='DETAILVIEWBASIC');
update ld_links_seq set id = (select max(linkid) from ld_links);
delimiter;

update ld_tab set printtab = 1 where `name` = 'PurchaseInvoice';
delimiter;

select tabid into @tabid from ld_tab where `name` = 'PurchaseInvoice';
insert into ld_modtracker_tabs(tabid,visible)
select @tabid,1 from dual where not EXISTS(select 1 from ld_modtracker_tabs  where tabid = @tabid);

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'zh','ADDPURCHASEINVOICE','新增','fixedstr' from dual
where not EXISTS(select 1 from ld_desk  where languagetype='zh' and labelbol='ADDPURCHASEINVOICE' and Labeltype='fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'en','ADDPURCHASEINVOICE','Add','fixedstr' from dual
where not EXISTS(select 1 from ld_desk  where languagetype='en' and labelbol='ADDPURCHASEINVOICE' and Labeltype='fixedstr');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'zh','PURCHASEINVOICEDETAILS','采购发票明细','fixedstr' from dual
where not EXISTS(select 1 from ld_desk  where languagetype='zh' and labelbol='PURCHASEINVOICEDETAILS' and Labeltype='fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'en','PURCHASEINVOICEDETAILS','Purchase Invoice Details','fixedstr' from dual
where not EXISTS(select 1 from ld_desk  where languagetype='en' and labelbol='PURCHASEINVOICEDETAILS' and Labeltype='fixedstr');
delimiter;

select tabid into @tabid from ld_tab where `name` = 'Vendors';
select tabid into @related_tabid from ld_tab where `name` = 'PurchaseInvoice';
select id into @id from ld_relatedlists_seq;
select max(sequence) into @sequence from ld_relatedlists where tabid = @tabid;
insert into ld_relatedlists(relation_id,tabid,related_tabid,name,sequence,label,actions)
select @id+1,@tabid,@related_tabid,'get_purchaseinvoice',@sequence+1,'PurchaseInvoice','add'
from dual where not EXISTS(select 1 from ld_relatedlists  where tabid =@tabid and related_tabid = @related_tabid);
update ld_relatedlists_seq set id = (select max(relation_id) from ld_relatedlists);
delimiter;

select tabid into @tabid from ld_tab where `name` = 'PurchaseOrder';
select tabid into @related_tabid from ld_tab where `name` = 'PurchaseInvoice';
select id into @id from ld_relatedlists_seq;
select max(sequence) into @sequence from ld_relatedlists where tabid = @tabid;
insert into ld_relatedlists(relation_id,tabid,related_tabid,name,sequence,label,actions)
select @id+1,@tabid,@related_tabid,'get_purchaseinvoice',@sequence+1,'PurchaseInvoice','add,select'
from dual where not EXISTS(select 1 from ld_relatedlists  where tabid =@tabid and related_tabid = @related_tabid);
update ld_relatedlists_seq set id = (select max(relation_id) from ld_relatedlists);
delimiter;


select tabid into @tabid from ld_tab where `name` = 'PurchaseInvoice';
insert into ld_entityname(tabid,modulename,tablename,fieldname,entityidfield,entityidcolumn)
select @tabid,'PurchaseInvoice','LD_purchaseinvoice','subject','purchaseinvoiceid','purchaseinvoiceid'
from dual where not EXISTS(select 1 from ld_entityname  where tabid = @tabid
and modulename ='PurchaseInvoice');
delimiter;

CALL fieldprofile('PurchaseInvoice');
CALL getallprofile('PurchaseInvoice');
CALL addtabintoprofile('PurchaseInvoice',0);
CALL addModuleActivity('PurchaseInvoice',6);-- 给销售发票添加导出权限
select tabid into @tabid from ld_tab where `name` = 'PurchaseInvoice';
update ld_profile2standardpermissions set permissions = 1 where tabid = @tabid and profileid not in (
select ld_role2profile.profileid from ld_users
inner join ld_user2role on ld_users.id = ld_user2role.userid
inner join ld_role2profile on ld_role2profile.roleid = ld_user2role.roleid  where is_admin = 'on'
);
delimiter;

SELECT MAX(relation_id) INTO @relationid FROM ld_relatedlists;
SELECT tabid INTO @tabid FROM ld_tab WHERE NAME='PurchaseInvoice';

SELECT tabid INTO @relatedtabid FROM ld_tab WHERE NAME='Attachment';
INSERT INTO LD_relatedlists(relation_id,tabid,related_tabid,NAME,sequence,label,presence,actions)
SELECT @relationid+1,@tabid,@relatedtabid,'get_attachment',1,'Attachment',0,'add' FROM DUAL
WHERE NOT EXISTS(SELECT 1 FROM ld_relatedlists WHERE NAME='get_attachment' AND tabid=@tabid);

UPDATE lD_relatedLists_seq SET id = (@relationid+1);
delimiter;


SELECT tabid INTO @tabid FROM ld_tab WHERE NAME = 'PurchaseInvoice';
SELECT tabid INTO @tabid2 FROM ld_tab WHERE NAME = 'Attachment';
INSERT INTO ld_quickactions(tabid,related_tabid,sequence,presence)
SELECT @tabid,@tabid2,0,0 FROM DUAL
WHERE NOT EXISTS(SELECT 1 FROM ld_quickactions  WHERE tabid=@tabid AND related_tabid=@tabid2);

insert into ld_quickactions(tabid,related_tabid,sequence,presence)
select @tabid,-1,0,0 from dual
where not EXISTS(select 1 from ld_quickactions  where tabid=@tabid and related_tabid=-1);

insert into ld_quickactions(tabid,related_tabid,sequence,presence)
select @tabid,-5,0,0 from dual
where not EXISTS(select 1 from ld_quickactions  where tabid=@tabid and related_tabid=-5);
delimiter;

insert into ld_modentity_num(num_id,semodule,prefix,start_id,cur_id,active,datetype)
select (select max(num_id)+1 from ld_modentity_num),'PurchaseInvoice','PINV',1,1,1,'none'
from dual where not EXISTS(select 1 from ld_modentity_num  where semodule = 'PurchaseInvoice'
and prefix ='PINV');
update ld_modentity_num_seq set id = (select max(num_id)+1 from ld_modentity_num);
delimiter;

insert into ld_systems_deploy(deploy_value,deploy_type,description,setype)
select 0,50,'采购发票是否启用审批流程。1:否，0:是','PurchaseInvoice' from dual where not exists
(select 1 from ld_systems_deploy where deploy_type=50);
delimiter;

SELECT roleid INTO @roleid FROM ld_user2role
INNER JOIN ld_users ON ld_users.`id` = ld_user2role.`userid`
WHERE user_name = 'admin' limit 1;-- 获取admin的角色

SELECT max(id) into @id from ld_approve;
SELECT tabid into @tabid FROM ld_tab where name='PurchaseInvoice';
insert into ld_approve(id,tabid,name,description,status,smcreatorid,modifiedby,createdtime,modifiedtime)
SELECT @id+1,@tabid,'采购发票二级审批流程','采购发票预置二级审批流程',0,1,1,NOW(),NOW() from dual where not exists
(select 1 from ld_approve where name='采购发票二级审批流程');
delimiter;
SELECT tabid into @tabid FROM ld_tab where name='PurchaseInvoice';
SELECT id into @id from ld_approve WHERE name='采购发票二级审批流程' and tabid =@tabid ;
insert into ld_approve2role(approveid,roleid) SELECT @id,@roleid from dual where not exists (select 1 from ld_approve2role where approveid=@id);
delimiter;

SELECT max(id) into @id from ld_approvestep;
SELECT tabid into @tabid FROM ld_tab where name='PurchaseInvoice';
SELECT id into @approveid from ld_approve WHERE name='采购发票二级审批流程' and tabid =@tabid ;
insert into ld_approvestep(id,approveid,name,description,ended,step,sequence,createdtime,modifiedtime,approvetype,approvevalue,specifyapproverid)
SELECT @id+1,@approveid,'采购发票第一步审批','采购发票第一步审批步骤',1,0,1,NOW(),NOW(),0,1,1 from dual where not exists
(select 1 from ld_approvestep where approveid=@approveid and sequence=1);
delimiter;

SELECT max(id) into @id from ld_approvestep;
SELECT tabid into @tabid FROM ld_tab where name='PurchaseInvoice';
SELECT id into @approveid from ld_approve WHERE name='采购发票二级审批流程' and tabid =@tabid ;
insert into ld_approvestep(id,approveid,name,description,ended,step,sequence,createdtime,modifiedtime,approvetype,approvevalue,specifyapproverid)
SELECT @id+1,@approveid,'采购发票第二步审批','采购发票第二步审批步骤',1,0,2,NOW(),NOW(),0,1,1 from dual where not exists
(select 1 from ld_approvestep where approveid=@approveid and sequence=2);
delimiter;
update ld_approve_seq set id = (select max(id) from ld_approve);
delimiter;
update ld_approvestep_seq set id = (select max(id) from ld_approvestep);
delimiter;


SELECT MAX(relation_id) INTO @relationid FROM ld_relatedlists;
SELECT tabid INTO @relatedtabid FROM ld_tab WHERE NAME='PurchaseInvoice';

SELECT tabid INTO @tabid FROM ld_tab WHERE NAME='Vendors';

SELECT sequence INTO @seq FROM LD_relatedlists WHERE tabid = @tabid AND label = 'PurchaseOrder';
SELECT @seq+1 INTO @seq1;
UPDATE LD_relatedlists SET sequence = (@seq1:=@seq1+1) WHERE tabid = @tabid AND sequence > @seq ORDER BY sequence;
UPDATE LD_relatedlists SET sequence = @seq+2 WHERE tabid = @tabid AND sequence = @seq and label != 'PurchaseOrder' ORDER BY sequence;-- 递增排序等于采购订单位置的值

INSERT INTO LD_relatedlists(relation_id,tabid,related_tabid,NAME,sequence,label,presence,actions)
SELECT @relationid+1,@tabid,@relatedtabid,'get_purchaseinvoice',@seq+1,'PurchaseInvoice',0,'add' FROM DUAL
WHERE NOT EXISTS(SELECT 1 FROM ld_relatedlists WHERE NAME='get_purchaseinvoice' AND tabid=@tabid);

SELECT tabid INTO @tabid FROM ld_tab WHERE NAME='PurchaseOrder';

SELECT sequence INTO @seq FROM LD_relatedlists WHERE tabid = @tabid AND label = 'SendCashBill';
SELECT @seq+1 INTO @seq1;
UPDATE LD_relatedlists SET sequence = (@seq1:=@seq1+1) WHERE tabid = @tabid AND sequence > @seq ORDER BY sequence;
UPDATE LD_relatedlists SET sequence = @seq+2 WHERE tabid = @tabid AND sequence = @seq and label != 'SendCashBill' ORDER BY sequence;-- 递增排序等于付款单位置的值

INSERT INTO LD_relatedlists(relation_id,tabid,related_tabid,NAME,sequence,label,presence,actions)
SELECT @relationid+2,@tabid,@relatedtabid,'get_purchaseinvoice',@seq+1,'PurchaseInvoice',0,'add' FROM DUAL
WHERE NOT EXISTS(SELECT 1 FROM ld_relatedlists WHERE NAME='get_purchaseinvoice' AND tabid=@tabid);

UPDATE lD_relatedLists_seq SET id = (@relationid+2);
delimiter;


SELECT tabid INTO @vtabid FROM ld_tab WHERE NAME='Vendors';
SELECT tabid INTO @potabid FROM ld_tab WHERE NAME='PurchaseOrder';
SELECT tabid INTO @tabid FROM ld_tab WHERE NAME = 'PurchaseInvoice';
SELECT tabid INTO @scbtabid FROM ld_tab WHERE NAME = 'SendCashBill';

select sequence into @seq from ld_quickactions where tabid = @vtabid and related_tabid = @potabid;
SELECT @seq+1 INTO @seq1;
UPDATE ld_quickactions SET sequence = (@seq1:=@seq1+1) WHERE tabid = @vtabid AND sequence > @seq ORDER BY sequence;
UPDATE ld_quickactions SET sequence = @seq+2 WHERE tabid = @vtabid AND sequence = @seq and related_tabid != @potabid ORDER BY sequence;

INSERT INTO ld_quickactions(tabid,related_tabid,sequence,presence)
SELECT @vtabid,@tabid,@seq+1,0 FROM DUAL
WHERE NOT EXISTS(SELECT 1 FROM ld_quickactions  WHERE tabid=@vtabid AND related_tabid=@tabid);

select sequence into @seq from ld_quickactions where tabid = @potabid and related_tabid = @scbtabid;
SELECT @seq+1 INTO @seq1;
UPDATE ld_quickactions SET sequence = (@seq1:=@seq1+1) WHERE tabid = @potabid AND sequence > @seq ORDER BY sequence;
UPDATE ld_quickactions SET sequence = @seq+2 WHERE tabid = @potabid AND sequence = @seq and related_tabid != @scbtabid ORDER BY sequence;

INSERT INTO ld_quickactions(tabid,related_tabid,sequence,presence)
SELECT @potabid,@tabid,@seq+1,0 FROM DUAL
WHERE NOT EXISTS(SELECT 1 FROM ld_quickactions  WHERE tabid=@potabid AND related_tabid=@tabid);
delimiter;


insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'zh','LATESTDATEOFPAYMENT','最近付款日期','fixedstr' from dual
where not EXISTS(select 1 from ld_desk  where languagetype='zh' and labelbol='LATESTDATEOFPAYMENT' and Labeltype='fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'en','LATESTDATEOFPAYMENT','Latest Date Of Payment','fixedstr' from dual
where not EXISTS(select 1 from ld_desk  where languagetype='en' and labelbol='LATESTDATEOFPAYMENT' and Labeltype='fixedstr');

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'zh','ISPAYMENT','应付','fixedstr' from dual
where not EXISTS(select 1 from ld_desk  where languagetype='zh' and labelbol='ISPAYMENT' and Labeltype='fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'en','ISPAYMENT','Is Payment','fixedstr' from dual
where not EXISTS(select 1 from ld_desk  where languagetype='en' and labelbol='ISPAYMENT' and Labeltype='fixedstr');
delimiter;



select tabid into @tabid from ld_tab where `name` = 'PurchaseInvoice';
SELECT roleid INTO @roleid FROM ld_user2role INNER JOIN ld_users ON ld_users.`id` = ld_user2role.`userid` WHERE user_name = 'admin';
SELECT profileid INTO @profileid FROM ld_role2profile WHERE roleid = @roleid;
UPDATE LD_profile2tab SET permissions = 0 WHERE tabid = @tabid AND profileid = @profileid;
delimiter;
select tabid into @tabid from ld_tab where `name` = 'PurchaseInvoice';
SELECT roleid INTO @roleid FROM ld_user2role INNER JOIN ld_users ON ld_users.`id` = ld_user2role.`userid` WHERE user_name = 'admin';
SELECT profileid INTO @profileid FROM ld_role2profile WHERE roleid = @roleid;
UPDATE LD_profile2utility SET permission = 0 WHERE profileid = @profileid AND tabid = @tabid AND activityid = 6;
delimiter;


select tabid into @tabid from ld_tab where name = 'PurchaseInvoice';
update ld_field set defaultvalue = 'thistoday' where tabid = @tabid and fieldname = 'purchaseinvoicedate';

update ld_customview set setdefault = 0 where entitytype = 'PurchaseInvoice' and viewname != 'All' and setdefault = 1;


call AddColumn('LD_account','traffic','varchar',100,NULL);
delimiter;

select blockid into @blockid from ld_blocks where tabid = 6 and blocklabel = 'LBL_ADDRESS_INFORMATION';
select max(sequence)+1 into @sequence from ld_field where tabid = 6 and block = @blockid;
insert into ld_field(tabid,fieldid,columnname,tablename,generatedtype,uitype,fieldname,fieldlabel,readonly,block,displaytype,presence,maximumlength,typeofdata,sequence,quickcreatesequence,info_type,searchfieldtype)
select 6,(select max(fieldid) from ld_field)+1,'traffic','LD_account',1,21,'traffic','交通路线',1,@blockid,1,0,100,'V~O',@sequence,1,'BAS',1
from dual where not exists (select * from ld_field where tabid = 6 and columnname = 'traffic');
delimiter;

select fieldid into @fieldid from ld_field where tabid = 6 and columnname = 'traffic';
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'zh','LD_field',6,@fieldid,'交通路线' from dual 
where not EXISTS(select 1 from ld_tranlabel  where languagetype = 'zh' and trantable ='LD_field' and tabid = 6 and relateid=@fieldid);

insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'en','LD_field',6,@fieldid,'Traffic Routes' from dual where not EXISTS(select 1 from ld_tranlabel  where languagetype = 'en' and trantable ='LD_field' and tabid = 6 and relateid=@fieldid );
delimiter;


delete from ld_report where  state='DEFAULT' and customizable=60;
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'zh','THETOTALAMOUNTOFTHEPURCHASEORDERAMOUNT','采购订单金额不能大于付款计划的总额','jspop' from dual
where not EXISTS(select 1 from ld_desk  where languagetype='zh' and labelbol='THETOTALAMOUNTOFTHEPURCHASEORDERAMOUNT' and Labeltype='jspop');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'en','THETOTALAMOUNTOFTHEPURCHASEORDERAMOUNT','The total amount of the purchase order amount cannot be larger than the payment plan','jspop' from dual
where not EXISTS(select 1 from ld_desk  where languagetype='en' and labelbol='THETOTALAMOUNTOFTHEPURCHASEORDERAMOUNT' and Labeltype='jspop');


select tabid into @tabid from ld_tab where `name` = 'SalesOrder';
update ld_relatedlists set presence = 0 where tabid = @tabid and label in ('ServiceContracts','Project');

select tabid into @tabid from ld_tab where name = 'ServiceCharge';
select blockid into @blockid from ld_blocks where tabid = @tabid and blocklabel = 'LBL_ADDRESS_INFORMATION';
select max(sequence)+1 into @sequence from ld_field where tabid = @tabid and block = @blockid;
insert into ld_field(tabid,fieldid,columnname,tablename,generatedtype,uitype,fieldname,fieldlabel,readonly,block,displaytype,presence,maximumlength,typeofdata,sequence,quickcreatesequence,info_type,searchfieldtype)
select @tabid,(select max(fieldid) from ld_field)+1,'traffic','LD_account',1,21,'traffic','交通路线',1,@blockid,1,0,100,'V~O',@sequence,1,'BAS',1 from dual 
where not exists (select * from ld_field where tabid = @tabid and columnname = 'traffic');
delimiter;

select tabid into @tabid from ld_tab where name = 'ServiceCharge';
select fieldid into @fieldid from ld_field where tabid = @tabid and columnname = 'traffic';
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'zh','LD_field',@tabid,@fieldid,'交通路线' from dual 
where not EXISTS(select 1 from ld_tranlabel  where languagetype = 'zh' and trantable ='LD_field' and tabid = @tabid and relateid=@fieldid);

insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'en','LD_field',@tabid,@fieldid,'Traffic Routes' from dual
where not EXISTS(select 1 from ld_tranlabel  where languagetype = 'en' and trantable ='LD_field' and tabid = @tabid and relateid=@fieldid );
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'zh','FIELDFORMULASFIELDCRESTOR','所有字段都已经创建过字段公式。','jspop' from dual 
where not EXISTS(select 1 from ld_desk  where languagetype='zh' and labelbol='FIELDFORMULASFIELDCRESTOR' and Labeltype='jspop');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'en','FIELDFORMULASFIELDCRESTOR','All fields have already created field formula.!','jspop' from dual 
where not EXISTS(select 1 from ld_desk  where languagetype='en' and labelbol='FIELDFORMULASFIELDCRESTOR' and Labeltype='jspop');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'zh','FIELDFORMULASTHISFIELDCRESTOR','该字段都已经创建过字段公式，不可以选择。','jspop' from dual 
where not EXISTS(select 1 from ld_desk  where languagetype='zh' and labelbol='FIELDFORMULASTHISFIELDCRESTOR' and Labeltype='jspop');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'en','FIELDFORMULASTHISFIELDCRESTOR','this fields have already created field formula.','jspop' from dual 
where not EXISTS(select 1 from ld_desk  where languagetype='en' and labelbol='FIELDFORMULASTHISFIELDCRESTOR' and Labeltype='jspop');
delimiter;

SELECT usereportid INTO @id FROM ld_usereport WHERE name='SalesOrderTrack';

DELETE FROM ld_usereportcolumns WHERE usereportid=@id;

insert into LD_UseReportcolumns(id,Usereportid,columns,Sequence,columnshow,realcolumns,realencolumns) 
select '', @id, 'LD_crmentity:smownerid:assigned_user_id:SalesOrder_assigned_user_id:V', 1, 1, 'LD_crmentity:smownerid:assigned_user_id:SalesOrder_销售负责人:V','LD_crmentity:smownerid:assigned_user_id:SalesOrder_Assigned To:V'   
from dual where not exists(select 1 from LD_UseReportcolumns where Usereportid=@id and realcolumns='LD_crmentity:smownerid:assigned_user_id:SalesOrder_销售负责人:V');

insert into LD_UseReportcolumns(id,Usereportid,columns,Sequence,columnshow,realcolumns,realencolumns) 
select '', @id, 'LD_salesorder:signed_data:signed_data:SalesOrder_signed_data:D', 2, 1, 'LD_salesorder:signed_data:signed_data:SalesOrder_签约日期:D','LD_salesorder:signed_data:signed_data:SalesOrder_Date of Contract:D'   
from dual where not exists(select 1 from LD_UseReportcolumns where Usereportid=@id and realcolumns='LD_salesorder:signed_data:signed_data:SalesOrder_签约日期:D');

insert into LD_UseReportcolumns(id,Usereportid,columns,Sequence,columnshow,realcolumns,realencolumns) 
select '', @id, 'LD_salesorder:salesorder_no:salesorder_no:SalesOrder_salesorder_no:V', 3, 1, 'LD_salesorder:salesorder_no:salesorder_no:SalesOrder_订单编号:V','LD_salesorder:salesorder_no:salesorder_no:SalesOrder_sales order no:V'   
from dual where not exists(select 1 from LD_UseReportcolumns where Usereportid=@id and realcolumns='LD_salesorder:salesorder_no:salesorder_no:SalesOrder_订单编号:V');

insert into LD_UseReportcolumns(id,Usereportid,columns,Sequence,columnshow,realcolumns,realencolumns) 
select '', @id, 'LD_crmentity:createdtime:createdtime:SalesOrder_CreatedTime:DT', 4, 1, 'LD_crmentity:createdtime:createdtime:SalesOrder_创建时间:DT','LD_crmentity:createdtime:createdtime:SalesOrder_Created Time:DT'   
from dual where not exists(select 1 from LD_UseReportcolumns where Usereportid=@id and realcolumns='LD_crmentity:createdtime:createdtime:SalesOrder_创建时间:DT');

insert into LD_UseReportcolumns(id,Usereportid,columns,Sequence,columnshow,realcolumns,realencolumns) 
select '', @id, 'LD_salesorder:subject:subject:SalesOrder_Subject:V', 5, 1, 'LD_salesorder:subject:subject:SalesOrder_主题:V','LD_salesorder:subject:subject:SalesOrder_Order Subject:V'   
from dual where not exists(select 1 from LD_UseReportcolumns where Usereportid=@id and realcolumns='LD_salesorder:subject:subject:SalesOrder_主题:V');

insert into LD_UseReportcolumns(id,Usereportid,columns,Sequence,columnshow,realcolumns,realencolumns) 
select '', @id, 'LD_accountSalesOrder:accountid:account_id:SalesOrder_Account_Name:I', 6, 1, 'LD_accountSalesOrder:accountid:account_id:SalesOrder_客户:I','LD_accountSalesOrder:accountid:account_id:SalesOrder_Account Name:I'   
from dual where not exists(select 1 from LD_UseReportcolumns where Usereportid=@id and realcolumns='LD_accountSalesOrder:accountid:account_id:SalesOrder_客户:I');

insert into LD_UseReportcolumns(id,Usereportid,columns,Sequence,columnshow,realcolumns,realencolumns) 
select '', @id, 'LD_salesorder:sostatus:sostatus:SalesOrder_sostatus:V', 7, 1, 'LD_salesorder:sostatus:sostatus:SalesOrder_状态:V','LD_salesorder:sostatus:sostatus:SalesOrder_order status:V'   
from dual where not exists(select 1 from LD_UseReportcolumns where Usereportid=@id and realcolumns='LD_salesorder:sostatus:sostatus:SalesOrder_状态:V');

insert into LD_UseReportcolumns(id,Usereportid,columns,Sequence,columnshow,realcolumns,realencolumns) 
select '', @id, 'LD_salesorder:duedate:duedate:SalesOrder_duedate:D', 8, 1, 'LD_salesorder:duedate:duedate:SalesOrder_交付日期:D','LD_salesorder:duedate:duedate:SalesOrder_due date:D'   
from dual where not exists(select 1 from LD_UseReportcolumns where Usereportid=@id and realcolumns='LD_salesorder:duedate:duedate:SalesOrder_交付日期:D');

insert into LD_UseReportcolumns(id,Usereportid,columns,Sequence,columnshow,realcolumns,realencolumns) 
select '', @id, 'LD_salesorder:total:hdnGrandTotal:SalesOrder_Total:N', 9, 1, 'LD_salesorder:total:hdnGrandTotal:SalesOrder_合同订单合计:N','LD_salesorder:total:hdnGrandTotal:SalesOrder_Order Total:N'   
from dual where not exists(select 1 from LD_UseReportcolumns where Usereportid=@id and realcolumns='LD_salesorder:total:hdnGrandTotal:SalesOrder_合同订单合计:N');

insert into LD_UseReportcolumns(id,Usereportid,columns,Sequence,columnshow,realcolumns,realencolumns) 
select '', @id, 'LD_salesorder:TotalCost:成本合计:OftenUseReport_TotalCost:N', 10, 1, 'LD_salesorder:TotalCost:成本合计:OftenUseReport_成本合计:N','LD_salesorder:TotalCost:成本合计:OftenUseReport_Total Cost:N'   
from dual where not exists(select 1 from LD_UseReportcolumns where Usereportid=@id and realcolumns='LD_salesorder:TotalCost:成本合计:OftenUseReport_成本合计:N');

insert into LD_UseReportcolumns(id,Usereportid,columns,Sequence,columnshow,realcolumns,realencolumns) 
select '', @id, 'LD_invoice:total:hdnGrandTotal:Invoice_Total:N', 11, 1, 'LD_invoice:total:hdnGrandTotal:Invoice_销售发票合计:N','LD_invoice:total:hdnGrandTotal:Invoice_Invoice Total:N'   
from dual where not exists(select 1 from LD_UseReportcolumns where Usereportid=@id and realcolumns='LD_invoice:total:hdnGrandTotal:Invoice_销售发票合计:N');

insert into LD_UseReportcolumns(id,Usereportid,columns,Sequence,columnshow,realcolumns,realencolumns) 
select '', @id, 'LD_reporttable:InvoiceBalance:开票余额:OftenUseReport_InvoiceBalance:N', 12, 1, 'LD_reporttable:InvoiceBalance:开票余额:OftenUseReport_开票余额:N','LD_reporttable:InvoiceBalance:开票余额:OftenUseReport_Invoice Balance:N'   
from dual where not exists(select 1 from LD_UseReportcolumns where Usereportid=@id and realcolumns='LD_reporttable:InvoiceBalance:开票余额:OftenUseReport_开票余额:N');

insert into LD_UseReportcolumns(id,Usereportid,columns,Sequence,columnshow,realcolumns,realencolumns) 
select '', @id, 'LD_reporttable:Expenseamount:费用金额:OftenUseReport_Expenseamount:N', 13, 1, 'LD_reporttable:Expenseamount:费用金额:OftenUseReport_费用金额:N','LD_reporttable:Expenseamount:费用金额:OftenUseReport_Expense amount:N'   
from dual where not exists(select 1 from LD_UseReportcolumns where Usereportid=@id and realcolumns='LD_reporttable:Expenseamount:费用金额:OftenUseReport_费用金额:N');

insert into LD_UseReportcolumns(id,Usereportid,columns,Sequence,columnshow,realcolumns,realencolumns) 
select '', @id, 'LD_commission2payment:amount:amount:OftenUseReport_Amount:NN', 14, 1, 'LD_commission2payment:amount:amount:OftenUseReport_佣金金额:NN','LD_commission2payment:amount:amount:OftenUseReport_Commission total:NN'   
from dual where not exists(select 1 from LD_UseReportcolumns where Usereportid=@id and realcolumns='LD_commission2payment:amount:amount:OftenUseReport_佣金金额:NN');

insert into LD_UseReportcolumns(id,Usereportid,columns,Sequence,columnshow,realcolumns,realencolumns) 
select '', @id, 'LD_reporttable:CashBillamount:已收款金额:OftenUseReport_CashBillamount:N', 15, 1, 'LD_reporttable:CashBillamount:已收款金额:OftenUseReport_已收款金额:N','LD_reporttable:CashBillamount:已收款金额:OftenUseReport_CashBill amount:N'   
from dual where not exists(select 1 from LD_UseReportcolumns where Usereportid=@id and realcolumns='LD_reporttable:CashBillamount:已收款金额:OftenUseReport_已收款金额:N');

insert into LD_UseReportcolumns(id,Usereportid,columns,Sequence,columnshow,realcolumns,realencolumns) 
select '', @id, 'LD_reporttable:PaymentPlanBalance:应收款余额:OftenUseReport_PaymentBalance:N', 16, 1, 'LD_reporttable:PaymentPlanBalance:应收款余额:OftenUseReport_应收款余额:N','LD_reporttable:PaymentPlanBalance:应收款余额:OftenUseReport_Payment Balance:N'   
from dual where not exists(select 1 from LD_UseReportcolumns where Usereportid=@id and realcolumns='LD_reporttable:PaymentPlanBalance:应收款余额:OftenUseReport_应收款余额:N');

insert into LD_UseReportcolumns(id,Usereportid,columns,Sequence,columnshow,realcolumns,realencolumns) 
select '', @id, 'LD_salesorder:GrossProfit:毛利:OftenUseReport_GrossProfit:N', 17, 1, 'LD_salesorder:GrossProfit:毛利:OftenUseReport_毛利:N','LD_salesorder:GrossProfit:毛利:OftenUseReport_Gross Profit:N'   
from dual where not exists(select 1 from LD_UseReportcolumns where Usereportid=@id and realcolumns='LD_salesorder:GrossProfit:毛利:OftenUseReport_毛利:N');

insert into LD_UseReportcolumns(id,Usereportid,columns,Sequence,columnshow,realcolumns,realencolumns) 
select '', @id, 'LD_salesorder:GrossProfitl:毛利率:OftenUseReport_GrossProfitl:N', 18, 1, 'LD_salesorder:GrossProfitl:毛利率:OftenUseReport_毛利率:N','LD_salesorder:GrossProfitl:毛利率:OftenUseReport_Gross Profit(%):N'   
from dual where not exists(select 1 from LD_UseReportcolumns where Usereportid=@id and realcolumns='LD_salesorder:GrossProfitl:毛利率:OftenUseReport_毛利率:N');
delimiter;
-- end 2014-09-12

DROP PROCEDURE IF EXISTS CopyPicklistDependency;
delimiter ||
CREATE PROCEDURE CopyPicklistDependency(
	copymodule VARCHAR(100),
	tomodule VARCHAR(100)
)
BEGIN

	declare tmp_sourcefield  varchar(100) default '';
	declare tmp_targetfield  varchar(100) default '';
	declare tmp_sourcevalue  varchar(100) default '';
	declare tmp_targetvalues text;
		
	declare mycursor cursor for select sourcefield,targetfield,sourcevalue,targetvalues from ld_picklist_dependency where tabid=(select tabid from ld_tab where `name`=copymodule); 
	DECLARE CONTINUE HANDLER FOR SQLSTATE '02000' set tmp_sourcefield = NULL;
	
	select tabid into @tabid from ld_tab where `name`=tomodule;

	open mycursor;
	fetch mycursor into tmp_sourcefield,tmp_targetfield,tmp_sourcevalue,tmp_targetvalues;
	while(tmp_sourcefield is not null) DO
			select max(id) into @id from ld_picklist_dependency;
			delete from ld_picklist_dependency where tabid=@tabid and sourcefield=tmp_sourcefield and targetfield=tmp_targetfield and sourcevalue=tmp_sourcevalue;

			insert into ld_picklist_dependency(id,tabid,sourcefield,targetfield,sourcevalue,targetvalues)
			select @id+1,@tabid,tmp_sourcefield,tmp_targetfield,tmp_sourcevalue,tmp_targetvalues;

			fetch mycursor into tmp_sourcefield,tmp_targetfield,tmp_sourcevalue,tmp_targetvalues;
	end while;
	close mycursor;

	update ld_picklist_dependency_seq set id=(select max(id) from ld_picklist_dependency);

END ||
delimiter;

call CopyPicklistDependency('Accounts','ServiceCharge');
delimiter;


select sequence into @sequence from ld_field where tabid = 13 and block = 25 and columnname = 'servicecontractsid';
update ld_field set sequence = sequence+1 where tabid = 13 and block = 25 and sequence > @sequence;
update ld_field set sequence = @sequence+1 where tabid = 13 and block = 25 and columnname = 'servicetype';
delimiter;
update ld_desk set Fieldlabel='定制订单、发票等模块产品明细中的产品关联字段' 
where labelbol='LBL_RELATED_PARAMETERS_DESCRIPTION' and languagetype='zh' and Labeltype='fixedstr';
delimiter;

SELECT tabid INTO @id FROM ld_tab WHERE name='Contacts';

UPDATE ld_field SET fieldlabel='编号' where tabid=@id and columnname='contact_no';

UPDATE ld_field SET fieldlabel='部门' where tabid=@id and columnname='department';

UPDATE ld_field SET fieldlabel='办公电话' where tabid=@id and columnname='pphone';

UPDATE ld_field SET fieldlabel='生日' where tabid=@id and columnname='birthday';
delimiter;

delete  from ld_desk where labelbol = 'PERONRESPONSIBLEFORUPDATE' and Labeltype = 'fixedstr';
delimiter;

update ld_desk set Fieldlabel='分类名称不能为空！' where labelbol='VIEWNAMECANNOTEMPTY' and languagetype='zh' and Labeltype = 'fixedstr';
update ld_desk set Fieldlabel='Filter Name can not be empty!' where labelbol='VIEWNAMECANNOTEMPTY' and languagetype='en' and Labeltype = 'fixedstr';
delimiter;
-- end 2014-09-15

UPDATE ld_desk SET fieldlabel='修改服务人员为' WHERE labelbol = 'Transfer_clients_and_contacts' AND Labeltype='fixedstr' AND languagetype='zh';
UPDATE ld_desk SET fieldlabel='Modify the service person in charge' WHERE labelbol = 'Transfer_clients_and_contacts' AND Labeltype='fixedstr' AND languagetype='en';
delimiter;

SELECT tabid INTO @tabid FROM ld_tab WHERE NAME = 'Contacts';
SELECT fieldid INTO @fieldid FROM ld_field WHERE tabid = @tabid AND columnname = 'accountid';
SELECT MAX(id) INTO @id FROM ld_relatedlists_lable;
INSERT INTO ld_relatedlists_lable(id,tabid,fieldid,width,sequence,presence,edit) 
SELECT @id+1,@tabid,@fieldid,0,0,1,0 FROM DUAL
WHERE NOT EXISTS(SELECT 1 FROM ld_relatedlists_lable WHERE tabid=@tabid AND fieldid=@fieldid);
delimiter;

SELECT tabid INTO @tabid FROM ld_tab WHERE NAME = 'PurchaseInvoice';
SELECT fieldid INTO @fieldid FROM ld_field WHERE tabid = @tabid AND uitype = 201 AND fieldlabel = '选择源单';
UPDATE ld_tranlabel SET fieldlabel = '采购订单' WHERE tabid = @tabid AND relateid = @fieldid AND languagetype = 'zh';
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'zh','editingsteps','编辑步骤','fixedstr' from dual 
where not EXISTS(select 1 from ld_desk  where languagetype='zh' and labelbol='editingsteps' and Labeltype='fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'en','editingsteps','editing steps','fixedstr' from dual 
where not EXISTS(select 1 from ld_desk  where languagetype='en' and labelbol='editingsteps' and Labeltype='fixedstr');
delimiter;
update ld_desk set Fieldlabel='批量编辑' where labelbol='MASSEDIT' and languagetype='zh' and Labeltype = 'fixedstr';
update ld_desk set Fieldlabel='Batch Edit' where labelbol='MASSEDIT' and languagetype='en' and Labeltype = 'fixedstr';
delimiter;
delete from ld_desk where labelbol = 'Batch_Edit' and Labeltype = 'fixedstr';
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'zh','THEHIGHSEASHASBEENRECEIVINGCUSTOMERSFAILURE','部分公海客户已经被领取，领取失败','jspop' from dual
where not EXISTS(select 1 from ld_desk  where languagetype='zh' and labelbol='THEHIGHSEASHASBEENRECEIVINGCUSTOMERSFAILURE' and Labeltype='jspop');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'en','THEHIGHSEASHASBEENRECEIVINGCUSTOMERSFAILURE','The high seas has been receiving customers, receive failure','jspop' from dual
where not EXISTS(select 1 from ld_desk  where languagetype='en' and labelbol='THEHIGHSEASHASBEENRECEIVINGCUSTOMERSFAILURE' and Labeltype='jspop');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'zh','THEHIGHSEASHASBEENRECEIVINGCUSTOMERSALLOCATION','部分公海客户已经被分配，分配失败','jspop' from dual
where not EXISTS(select 1 from ld_desk  where languagetype='zh' and labelbol='THEHIGHSEASHASBEENRECEIVINGCUSTOMERSALLOCATION' and Labeltype='jspop');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'en','THEHIGHSEASHASBEENRECEIVINGCUSTOMERSALLOCATION','The high seas, the customer has been assigned, allocation failure','jspop' from dual
where not EXISTS(select 1 from ld_desk  where languagetype='en' and labelbol='THEHIGHSEASHASBEENRECEIVINGCUSTOMERSALLOCATION' and Labeltype='jspop');
delimiter;

update ld_ws_entity  set handler_path='include/Webservices/lingdangModuleOperation.php'  where  handler_path='include/Webservices/VtigerModuleOperation.php';
update ld_ws_entity set  handler_class='lingdangModuleOperation' where handler_class='VtigerModuleOperation';
update ld_ws_entity set handler_path='include/Webservices/lingdangActorOperation.php' 
where handler_path='include/Webservices/VtigerActorOperation.php';
update ld_ws_entity set handler_class='lingdangActorOperation' where handler_class='VtigerActorOperation';
update ld_ws_entity set handler_path='include/Webservices/lingdangCompanyDetails.php' 
where handler_path='include/Webservices/VtigerCompanyDetails.php';
update ld_ws_entity set handler_class='lingdangCompanyDetails' where handler_class='VtigerCompanyDetails';
 
update ld_tab set name='lingdangBackup' where name='VtigerBackup';
delimiter;
update ld_eventhandlers set event_name='lingdang.entity.aftersave' where event_name='vtiger.entity.aftersave';
update ld_eventhandlers set event_name='lingdang.entity.beforesave' where event_name='vtiger.entity.beforesave';
update ld_eventhandlers set event_name='lingdang.entity.afterrestore' where event_name='vtiger.entity.afterrestore';
update ld_eventhandlers set event_name='lingdang.entity.aftersave.final' where event_name='vtiger.entity.aftersave.final';
update ld_eventhandlers set event_name='lingdang.entity.beforedelete' where event_name='vtiger.entity.beforedelete';
update ld_eventhandlers set event_name='lingdang.entity.beforesave.modifiable' where event_name='vtiger.entity.beforesave.modifiable';
update ld_eventhandlers set handler_path='modules/com_lingdang_workflow/VTEventHandler.inc' where handler_path='modules/com_vtiger_workflow/VTEventHandler.inc';
delimiter;

select cvid into @cvid from ld_customview where entitytype='ContactRecords' and viewname='All';
delete from ld_cvcolumnlist where cvid=@cvid;
insert into ld_cvcolumnlist(cvid,columnindex,columnname)
select @cvid,0,'LD_contactrecords:subject:subject:ContactRecords_fieldlabel:V';

insert into ld_cvcolumnlist(cvid,columnindex,columnname)
select @cvid,1,'LD_contactrecords:accountid:account_id:ContactRecords_fieldlabel:V';

insert into ld_cvcolumnlist(cvid,columnindex,columnname)
select @cvid,2,'LD_contactrecords:contactid:contact_id:ContactRecords_fieldlabel:V';

insert into ld_cvcolumnlist(cvid,columnindex,columnname)
select @cvid,3,'LD_contactrecords:potentialid:potential_id:ContactRecords_fieldlabel:V';

insert into ld_cvcolumnlist(cvid,columnindex,columnname)
select @cvid,4,'LD_contactrecords:contactrecordtype:contactrecordtype:ContactRecords_fieldlabel:V';

insert into ld_cvcolumnlist(cvid,columnindex,columnname)
select @cvid,5,'LD_contactrecords:contactdate:contactdate:ContactRecords_fieldlabel:D';

insert into ld_cvcolumnlist(cvid,columnindex,columnname)
select @cvid,6,'LD_contactrecords:nextcontactdate:nextcontactdate:ContactRecords_fieldlabel:D';

insert into ld_cvcolumnlist(cvid,columnindex,columnname)
select @cvid,7,'LD_contactrecords:content:content:ContactRecords_fieldlabel:V';

insert into ld_cvcolumnlist(cvid,columnindex,columnname)
select @cvid,8,'LD_contactrecords:smownerid:assigned_user_id:ContactRecords_fieldlabel:V';
delimiter;
-- end 2014-09-16

UPDATE ld_desk SET fieldlabel='修改负责人为' WHERE labelbol = 'Transfer_clients_and_contacts' AND Labeltype='fixedstr' AND languagetype='zh';

UPDATE ld_desk SET fieldlabel='Modify the person in charge' WHERE labelbol = 'Transfer_clients_and_contacts' AND Labeltype='fixedstr' AND languagetype='en';
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'zh','Transfer_clients_and_contacts_server','修改{$HelpDesk.assigned_user_id}为','fixedstr' from dual 
where not EXISTS(select 1 from ld_desk where languagetype='zh' and labelbol='Transfer_clients_and_contacts_server' and Labeltype='fixedstr');

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'en','Transfer_clients_and_contacts_server','Modify the service person in charge','fixedstr' from dual 
where not EXISTS(select 1 from ld_desk  where languagetype='en' and labelbol='Transfer_clients_and_contacts_server' and Labeltype='fixedstr');
delimiter;

select tabid into @tabid from ld_tab where name = 'OutboundOrder';
SELECT MAX(sequence) into @sequence from ld_quickactions where tabid=@tabid;
insert into ld_quickactions(tabid,related_tabid,sequence,presence,label)
select @tabid,-9,@sequence+1,0,'发送短信' from dual 
where not EXISTS(select 1 from ld_quickactions  where tabid=@tabid and related_tabid=-9);
delimiter;

update ld_usereportcolumns set realencolumns='LD_contactrecords:contactrecordscount:contactrecordscount:OftenUseReport_new contact record:N'
where usereportid in(select usereportid from ld_usereport where name='SalesSumSequence' and  columns like '%LD_contactrecords:contactrecordscount:contactrecordscount:OftenUseReport%');
delimiter;

SELECT tabid INTO @tabid FROM ld_tab WHERE NAME = 'SalesOrder';
SELECT fieldid INTO @fieldid FROM ld_field WHERE tabid = @tabid AND columnname = 'accountid';
SELECT MAX(id) INTO @id FROM ld_relatedlists_lable;
INSERT INTO ld_relatedlists_lable(id,tabid,fieldid,width,sequence,presence,edit) 
SELECT @id+1,@tabid,@fieldid,0,0,1,0 FROM DUAL
WHERE NOT EXISTS(SELECT 1 FROM ld_relatedlists_lable WHERE tabid=@tabid AND fieldid=@fieldid);
delimiter;
-- end 2014-09-17

update ld_usereportcolumns set realencolumns='LD_contactrecords:contactrecordscount:contactrecordscount:OftenUseReport_new contact record:N'
where usereportid in(select usereportid from ld_usereport where name='SalesSumSequence' and  columns like '%LD_contactrecords:contactrecordscount:contactrecordscount:OftenUseReport%');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'zh','SUCCESS','成功','jspop' from dual 
where not EXISTS(select 1 from ld_desk  where languagetype='zh' and labelbol='SUCCESS' and Labeltype='jspop');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'en','SUCCESS',"Success",'jspop' from dual 
where not EXISTS(select 1 from ld_desk  where languagetype='en' and labelbol='SUCCESS' and Labeltype='jspop');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'zh','LOSE','失败','jspop' from dual 
where not EXISTS(select 1 from ld_desk  where languagetype='zh' and labelbol='LOSE' and Labeltype='jspop');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'en','LOSE',"Lose",'jspop' from dual 
where not EXISTS(select 1 from ld_desk  where languagetype='en' and labelbol='LOSE' and Labeltype='jspop');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'zh','BATCHRECEIVE','批量领取','jspop' from dual 
where not EXISTS(select 1 from ld_desk  where languagetype='zh' and labelbol='BATCHRECEIVE' and Labeltype='jspop');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'en','BATCHRECEIVE',"Batch to receive",'jspop' from dual 
where not EXISTS(select 1 from ld_desk  where languagetype='en' and labelbol='BATCHRECEIVE' and Labeltype='jspop');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'zh','BATCHALLOCATION','批量分配','jspop' from dual 
where not EXISTS(select 1 from ld_desk  where languagetype='zh' and labelbol='BATCHALLOCATION' and Labeltype='jspop');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'en','BATCHALLOCATION',"Batch Allocation",'jspop' from dual 
where not EXISTS(select 1 from ld_desk  where languagetype='en' and labelbol='BATCHALLOCATION' and Labeltype='jspop');
delimiter;

SELECT tabid INTO @tabid FROM ld_tab WHERE NAME = 'SalesOrder';
SELECT fieldid INTO @fieldid FROM ld_field WHERE tabid = @tabid AND columnname = 'accountid';
SELECT MAX(id) INTO @id FROM ld_relatedlists_lable;
INSERT INTO ld_relatedlists_lable(id,tabid,fieldid,width,sequence,presence,edit) 
SELECT @id+1,@tabid,@fieldid,0,0,1,0 FROM DUAL
WHERE NOT EXISTS(SELECT 1 FROM ld_relatedlists_lable WHERE tabid=@tabid AND fieldid=@fieldid);
delimiter;

SELECT tabid into @tabid from ld_tab where name='PurchaseOrder';
SELECT fieldid into @fieldid  from ld_field where tabid=@tabid and fieldname='contact_id';
UPDATE ld_tranlabel set fieldlabel='Supplier Contact Name' where tabid=@tabid and Relateid=@fieldid and trantable='LD_field' and languagetype='en';
UPDATE ld_tranlabel set fieldlabel='供应商联系人姓名' where tabid=@tabid and Relateid=@fieldid and trantable='LD_field' and languagetype='zh';
delimiter;
UPDATE ld_desk set fieldlabel='输入新的条目，每行一个（请点击Enter换行，因为字数超过限制导致的换行系统无法识别）' where labelbol='ONEBYONEBELOW' and languagetype='zh';
UPDATE ld_desk set fieldlabel='Enter the new entries, one per line (please click on the Enter line, because the line break system lead to the recognition of words over the limit)' where labelbol='ONEBYONEBELOW' and languagetype='en';

UPDATE ld_desk set fieldlabel='Statistics of mobile phone check-in' where labelbol ='SIGNINSTATISTICS' and languagetype='en';
delimiter;
UPDATE ld_desk set fieldlabel='Statistics of the tracks about sales order' where labelbol ='SalesOrderTrack' and languagetype='en';
delimiter;
UPDATE ld_desk set fieldlabel='Statistics of receivables acc to payment plan' where labelbol ='CashBillSum_Paymentplan' and languagetype='en';
delimiter;
UPDATE ld_desk set fieldlabel='Statistics of receivables acc to sales order' where labelbol ='CashBillSum_SalesOrder' and languagetype='en';
delimiter;
UPDATE ld_desk set fieldlabel='Statistics of collection cash performance' where labelbol ='Performancestatisticscollection' and languagetype='en';
delimiter;
UPDATE ld_desk set fieldlabel='Statistics of the tracks about purchase order' where labelbol ='PurchaseOrderTrack' and languagetype='en';
delimiter;
UPDATE ld_desk set fieldlabel='Statistics of payables acc to repayment plan' where labelbol ='SendCashBillSum_PurchaseOrder' and languagetype='en';
delimiter;
UPDATE ld_desk set fieldlabel='Statistics of payables acc to purchase order' where labelbol ='SendCashBillSum_SendPayment' and languagetype='en';
delimiter;
UPDATE ld_desk set fieldlabel='Ranking list of signing money' where labelbol ='Contractnumber' and languagetype='en';
delimiter;
UPDATE ld_desk set fieldlabel='Sales and performance appraisal' where labelbol ='SalesSumSequence' and languagetype='en';
delimiter;
UPDATE ld_desk set fieldlabel=' Advanced Search' where labelbol ='Advanced_Search2' and languagetype='en';
delimiter;
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'zh','ITSERREPLACEABLE','自身不可替代自身！','jspop' from dual 
where not EXISTS(select 1 from ld_desk  where languagetype='zh' and labelbol='ITSERREPLACEABLE' and Labeltype='jspop');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'en','ITSERREPLACEABLE',"Its irreplaceable itself!",'jspop' from dual 
where not EXISTS(select 1 from ld_desk  where languagetype='en' and labelbol='ITSERREPLACEABLE' and Labeltype='jspop');
delimiter;
UPDATE ld_desk set fieldlabel="关联产品明细信息时是否显示'折扣'和'税'" where labelbol='WHETHERTODISPLAYDISOUNTANDTAX' and languagetype='zh';
UPDATE ld_desk set fieldlabel="Whether to display the 'discount' and 'tax' Association product detail information" where labelbol='WHETHERTODISPLAYDISOUNTANDTAX' and languagetype='en';
UPDATE ld_desk set fieldlabel="关联产品明细信息时是否显示'小计'和'调整'" where labelbol='WHETHERTODISPLAYSUBTOTALANDADJUSTMENT' and languagetype='zh';
UPDATE ld_desk set fieldlabel="Whether to display the 'subtotal' and ` adjustment 'Association product detail information" where labelbol='WHETHERTODISPLAYSUBTOTALANDADJUSTMENT' and languagetype='en';
delimiter;
-- end 2014-09-18

select tabid into @tabid from ld_tab where name='OutboundOrder';
select block into @block from ld_field where tabid=@tabid and columnname='accountid';

update ld_field set sequence=sequence+100 where tabid=@tabid and block=@block;
update ld_field set sequence=1 where tabid=@tabid and block=@block and columnname='outdate';
update ld_field set sequence=2 where tabid=@tabid and block=@block and columnname='out_no';
update ld_field set sequence=3 where tabid=@tabid and block=@block and columnname='accountid';
update ld_field set sequence=5 where tabid=@tabid and block=@block and uitype=200;
update ld_field set sequence=6 where tabid=@tabid and block=@block and columnname='wareid';
update ld_field set sequence=7 where tabid=@tabid and block=@block and columnname='smownerid';

select tabid into @tabid from ld_tab where name='OutboundOrder';
select 'LD_outboundorder' into @tablename;
select 'contactid' into @columnname;
select 'contact_id' into @fieldname;
select '联系人姓名' into @zh;
select 'Contact Name' into @en;
select 57 into @uitype;
select 1 into @displaytype;
select 'I~O' into @typeofdata;
select 4 into @seq;

select max(fieldid) into @fieldid from ld_field;
insert into ld_field(tabid,fieldid,columnname,tablename,generatedtype,uitype,fieldname,fieldlabel,readonly,presence,maximumlength,sequence,block,displaytype,typeofdata,quickcreate,info_type)
select @tabid,@fieldid+1,@columnname,@tablename,1,@uitype,@fieldname,@zh,1,2,100,@seq,@block,@displaytype,@typeofdata,3,'BAS' from dual 
where not exists (select 1 from ld_field where tabid = @tabid and columnname = @columnname);
update ld_field_seq set id = (select max(fieldid) from ld_field);
update ld_field set sequence=4,presence=2 where tabid=@tabid and block=@block and columnname='contactid';

select fieldid into @fieldid from ld_field where tabid = @tabid and columnname = @columnname;
delete from ld_tranlabel where trantable ='LD_field' and relateid=@fieldid;
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'zh','LD_field',@tabid,@fieldid,@zh;

insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'en','LD_field',@tabid,@fieldid,@en;

select 0 into @i;
update ld_field set sequence=(@i:=@i+1) where tabid=@tabid and block=@block order by sequence;

call AddColumn(@tablename,@columnname,'int','19',0);
delimiter;

call fieldprofile('OutboundOrder');
delimiter;
call getallprofile('OutboundOrder');
delimiter;

select tabid into @tabid from ld_tab where name='Stock';
select block into @block from ld_field where tabid=@tabid and columnname='vendor_id';

update ld_field set sequence=sequence+100 where tabid=@tabid and block=@block;
update ld_field set sequence=1 where tabid=@tabid and block=@block and columnname='createdate';
update ld_field set sequence=2 where tabid=@tabid and block=@block and columnname='ware_stock_no';
update ld_field set sequence=3 where tabid=@tabid and block=@block and columnname='vendor_id';
update ld_field set sequence=5 where tabid=@tabid and block=@block and uitype=201;
update ld_field set sequence=6 where tabid=@tabid and block=@block and columnname='wareid';
update ld_field set sequence=7 where tabid=@tabid and block=@block and columnname='smownerid';

select tabid into @tabid from ld_tab where name='Stock';
select 'LD_stock' into @tablename;
select 'contactid' into @columnname;
select 'contact_id' into @fieldname;
select '联系人姓名' into @zh;
select 'Contact Name' into @en;
select 57 into @uitype;
select 1 into @displaytype;
select 'I~O' into @typeofdata;
select 4 into @seq;

select max(fieldid) into @fieldid from ld_field;
insert into ld_field(tabid,fieldid,columnname,tablename,generatedtype,uitype,fieldname,fieldlabel,readonly,presence,maximumlength,sequence,block,displaytype,typeofdata,quickcreate,info_type)
select @tabid,@fieldid+1,@columnname,@tablename,1,@uitype,@fieldname,@zh,1,2,100,@seq,@block,@displaytype,@typeofdata,3,'BAS' from dual 
where not exists (select 1 from ld_field where tabid = @tabid and columnname = @columnname);
update ld_field_seq set id = (select max(fieldid) from ld_field);
update ld_field set sequence=4,presence=2 where tabid=@tabid and block=@block and columnname='contactid';

select fieldid into @fieldid from ld_field where tabid = @tabid and columnname = @columnname;
delete from ld_tranlabel where trantable ='LD_field' and relateid=@fieldid;
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'zh','LD_field',@tabid,@fieldid,@zh;

insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'en','LD_field',@tabid,@fieldid,@en;

select 0 into @i;
update ld_field set sequence=(@i:=@i+1) where tabid=@tabid and block=@block order by sequence;

call AddColumn(@tablename,@columnname,'int','19',0);
delimiter;

call fieldprofile('Stock');
delimiter;
call getallprofile('Stock');
delimiter;

DROP PROCEDURE IF EXISTS setServiceGroupSequence;
delimiter ||
CREATE PROCEDURE setServiceGroupSequence(

)
begin

	declare done  int  default 0;
	declare sequence  int default 1;
	declare pservicegroupid int ;


	declare cur2 CURSOR FOR SELECT servicegroupid FROM LD_servicegroup order by sequence;
	declare continue handler  for not   found  SET done =1;
	open cur2;
	fetch cur2 into pservicegroupid;
	loop2: while  done<>1 DO

		update LD_servicegroup set sequence = sequence where servicegroupid = pservicegroupid;
	  set sequence = sequence + 1;
		
	fetch cur2 into pservicegroupid;
	end while loop2;
	close cur2;
END ||
delimiter;

call setServiceGroupSequence();
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'zh','NOMATCHINGITEMS','没有匹配项目','fixedstr' from dual 
where not EXISTS(select 1 from ld_desk  where languagetype='zh' and labelbol='NOMATCHINGITEMS' and Labeltype='fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'en','NOMATCHINGITEMS','No matching items','fixedstr' from dual 
where not EXISTS(select 1 from ld_desk  where languagetype='en' and labelbol='NOMATCHINGITEMS' and Labeltype='fixedstr');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'zh','NOMATCHINGITEMS','没有匹配项目','jspop' from dual 
where not EXISTS(select 1 from ld_desk  where languagetype='zh' and labelbol='NOMATCHINGITEMS' and Labeltype='jspop');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'en','NOMATCHINGITEMS','No matching items','jspop' from dual 
where not EXISTS(select 1 from ld_desk  where languagetype='en' and labelbol='NOMATCHINGITEMS' and Labeltype='jspop');
delimiter;

UPDATE ld_activity SET visibility='私有' WHERE visibility='Private';
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'zh','TICMfilm','TICM(片)','fixedstr' from dual 
where not EXISTS(select 1 from ld_desk  where languagetype='zh' and labelbol='TICMfilm' and Labeltype='fixedstr');

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'en','TICMfilm','TICM(film)','fixedstr' from dual 
where not EXISTS(select 1 from ld_desk  where languagetype='en' and labelbol='TICMfilm' and Labeltype='fixedstr');
delimiter;
-- 2014-09-19

update ld_def_org_field set visible=0 where tabid in (
select tabid from ld_tab where name='servicecharge');
delimiter;

update ld_desk set Fieldlabel='Statistics of the tracks about sales order' where labelbol='CONTRACTORDERTRACKING' and languagetype='en' and Labeltype='fixedstr';
delimiter;
update ld_desk set Fieldlabel='Statistics of payables acc to repayment plan' where labelbol='SendCashBillSum_SendPayment' and languagetype='en' and Labeltype='fixedstr';
delimiter;
update ld_desk set Fieldlabel='Statistics of payables acc to purchase order' where labelbol='SendCashBillSum_PurchaseOrder' and languagetype='en' and Labeltype='fixedstr';
delimiter;
update ld_desk set Fieldlabel='Ranking list of signing money' where labelbol='Contractnumber' and languagetype='en' and Labeltype='fixedstr';
delimiter;
update ld_desk set Fieldlabel='Sales and performance appraisal' where labelbol='SalesSumSequence' and languagetype='en' and Labeltype='fixedstr';
delimiter;
update ld_desk set Fieldlabel='转到高级查询' where labelbol='Advanced_Search2' and languagetype='zh' and Labeltype='fixedstr';
update ld_desk set Fieldlabel='Go to advanced search' where labelbol='Advanced_Search2' and languagetype='en' and Labeltype='fixedstr';
delimiter;
-- 2014-09-22

update ld_desk set fieldlabel='30天内及过期{$PaymentPlan.PaymentPlan}' where labelbol='WITHINPAYMENTPLAN' and languagetype='zh';


update ld_relatedlists set presence=0,sequence=100,label='Products',actions='add,select' where tabid=14 and `name`='get_products';
update ld_relatedlists set sequence=101 where tabid=14 and `name`='get_attachments';
update ld_relatedlists set sequence=102 where tabid=14 and `name`='get_attachment';

select max(relation_id) into @relation_id from ld_relatedlists;
insert into ld_relatedlists(relation_id,tabid,related_tabid,`name`,sequence,label,presence,actions)
select @relation_id+1,14,14,'get_parent_products',100,'Parent Product',1,'' from dual 
where not exists (select 1 from ld_relatedlists where tabid=14 and `name`='get_parent_products');

update ld_relatedlists_seq set id =(select max(relation_id) from ld_relatedlists);

select 0 into @i;
update ld_relatedlists set sequence=(@i:=@i+1) where tabid=14 order by sequence;
delimiter;
-- 2014-09-23

select tabid into @tabid from ld_tab where `name`='Potentials';
select max(blockid) into @blockid from ld_blocks;
select 'LBI_5W2P' into @blocklabel;
select '5W2P' into @en;
select '商机七要素(5W2P)' into @zh;
select ifnull(max(sequence),0)+1 into @seq from ld_blocks where tabid=@tabid;

insert into ld_blocks(blockid,tabid,blocklabel,sequence,show_title,visible,create_view,edit_view,detail_view,display_status,iscustom)
select @blockid+1,@tabid,@blocklabel,@seq,0,0,0,0,0,1,0 from dual 
where not exists (select 1 from ld_blocks where tabid=@tabid and blocklabel=@blocklabel);

update ld_blocks_seq set id=(select max(blockid) from ld_blocks);

select blockid into @blockid from ld_blocks where tabid=@tabid and blocklabel=@blocklabel;
update ld_blocks set sequence=@seq,show_title=0,visible=0,create_view=0,edit_view=0,detail_view=0,display_status=1,iscustom=0 where blockid=@blockid;
delete from ld_tranlabel where trantable='LD_blocks' and Relateid=@blockid;
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'en','LD_blocks',@tabid,@blockid,@en;

insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'zh','LD_blocks',@tabid,@blockid,@zh;
delimiter;

select tabid into @tabid from ld_tab where `name`='Potentials';
select max(blockid) into @blockid from ld_blocks;
select 'LBI_SWOT' into @blocklabel;
select 'SWOT' into @en;
select 'SWOT分析' into @zh;
select ifnull(max(sequence),0)+1 into @seq from ld_blocks where tabid=@tabid;

insert into ld_blocks(blockid,tabid,blocklabel,sequence,show_title,visible,create_view,edit_view,detail_view,display_status,iscustom)
select @blockid+1,@tabid,@blocklabel,@seq,0,0,0,0,0,1,0 from dual 
where not exists (select 1 from ld_blocks where tabid=@tabid and blocklabel=@blocklabel);
update ld_blocks_seq set id=(select max(blockid) from ld_blocks);

select blockid into @blockid from ld_blocks where tabid=@tabid and blocklabel=@blocklabel;
update ld_blocks set sequence=@seq,show_title=0,visible=0,create_view=0,edit_view=0,detail_view=0,display_status=1,iscustom=0 where blockid=@blockid;
delete from ld_tranlabel where trantable='LD_blocks' and Relateid=@blockid;
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'en','LD_blocks',@tabid,@blockid,@en;

insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'zh','LD_blocks',@tabid,@blockid,@zh;
delimiter;

select tabid into @tabid from ld_tab where `name`='Potentials';
select ifnull(max(sequence),0)+1 into @seq from ld_blocks where tabid=@tabid;
select 0 into @i;
update ld_blocks set sequence=@seq where tabid=@tabid and blocklabel='LBL_DESCRIPTION_INFORMATION';
update ld_blocks set sequence=(@i:=@i+1) where tabid=@tabid order by sequence;
delimiter;

select tabid into @tabid from ld_tab where name='Potentials';
select blockid into @block from ld_blocks where tabid=@tabid and blocklabel='LBI_5W2P';
select 'LD_potential' into @tablename;
select '5w2p_why1' into @columnname;
select '5w2p_why1' into @fieldname;
select '为什么会有这样的需求（why）' into @zh;
select 'Why is there such a demand(why)' into @en;
select 19 into @uitype;
select 1 into @displaytype;
select 'V~O' into @typeofdata;
select ifnull(max(sequence),0)+1 into @seq from ld_field where tabid=@tabid and block=@block;

select max(fieldid) into @fieldid from ld_field;
insert into ld_field(tabid,fieldid,columnname,tablename,generatedtype,uitype,fieldname,fieldlabel,readonly,presence,maximumlength,sequence,block,displaytype,typeofdata,quickcreate,info_type,searchfieldtype)
select @tabid,@fieldid+1,@columnname,@tablename,1,@uitype,@fieldname,@zh,1,2,100,@seq,@block,@displaytype,@typeofdata,3,'BAS',1 from dual 
where not exists (select 1 from ld_field where tabid = @tabid and columnname = @columnname);
update ld_field_seq set id = (select max(fieldid) from ld_field);
update ld_field set sequence=4,presence=2 where tabid=@tabid and block=@block and columnname='contactid';

select fieldid into @fieldid from ld_field where tabid = @tabid and columnname = @columnname;
delete from ld_tranlabel where trantable ='LD_field' and relateid=@fieldid;
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'zh','LD_field',@tabid,@fieldid,@zh;

insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'en','LD_field',@tabid,@fieldid,@en;

select 0 into @i;
update ld_field set sequence=(@i:=@i+1) where tabid=@tabid and block=@block order by sequence;

call AddColumn(@tablename,@columnname,'varchar','200',NULL);
alter table LD_potential modify column 5w2p_why1 text;
delimiter;


select tabid into @tabid from ld_tab where name='Potentials';
select blockid into @block from ld_blocks where tabid=@tabid and blocklabel='LBI_5W2P';
select 'LD_potential' into @tablename;
select '5w2p_plan1' into @columnname;
select '5w2p_plan1' into @fieldname;
select '是否已经立项（plan）' into @zh;
select 'Whether project has been established(plan)' into @en;
select 19 into @uitype;
select 1 into @displaytype;
select 'V~O' into @typeofdata;
select ifnull(max(sequence),0)+1 into @seq from ld_field where tabid=@tabid and block=@block;

select max(fieldid) into @fieldid from ld_field;
insert into ld_field(tabid,fieldid,columnname,tablename,generatedtype,uitype,fieldname,fieldlabel,readonly,presence,maximumlength,sequence,block,displaytype,typeofdata,quickcreate,info_type,searchfieldtype)
select @tabid,@fieldid+1,@columnname,@tablename,1,@uitype,@fieldname,@zh,1,2,100,@seq,@block,@displaytype,@typeofdata,3,'BAS',1 from dual 
where not exists (select 1 from ld_field where tabid = @tabid and columnname = @columnname);
update ld_field_seq set id = (select max(fieldid) from ld_field);
update ld_field set sequence=4,presence=2 where tabid=@tabid and block=@block and columnname='contactid';

select fieldid into @fieldid from ld_field where tabid = @tabid and columnname = @columnname;
delete from ld_tranlabel where trantable ='LD_field' and relateid=@fieldid;
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'zh','LD_field',@tabid,@fieldid,@zh;

insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'en','LD_field',@tabid,@fieldid,@en;

select 0 into @i;
update ld_field set sequence=(@i:=@i+1) where tabid=@tabid and block=@block order by sequence;

call AddColumn(@tablename,@columnname,'varchar','200',NULL);
alter table LD_potential modify column 5w2p_plan1 text;
delimiter;


select tabid into @tabid from ld_tab where name='Potentials';
select blockid into @block from ld_blocks where tabid=@tabid and blocklabel='LBI_5W2P';
select 'LD_potential' into @tablename;
select '5w2p_plan2' into @columnname;
select '5w2p_plan2' into @fieldname;
select '资金预算是多少（plan）' into @zh;
select 'How much the fund plan(plan)' into @en;
select 19 into @uitype;
select 1 into @displaytype;
select 'V~O' into @typeofdata;
select ifnull(max(sequence),0)+1 into @seq from ld_field where tabid=@tabid and block=@block;

select max(fieldid) into @fieldid from ld_field;
insert into ld_field(tabid,fieldid,columnname,tablename,generatedtype,uitype,fieldname,fieldlabel,readonly,presence,maximumlength,sequence,block,displaytype,typeofdata,quickcreate,info_type,searchfieldtype)
select @tabid,@fieldid+1,@columnname,@tablename,1,@uitype,@fieldname,@zh,1,2,100,@seq,@block,@displaytype,@typeofdata,3,'BAS',1 from dual 
where not exists (select 1 from ld_field where tabid = @tabid and columnname = @columnname);
update ld_field_seq set id = (select max(fieldid) from ld_field);
update ld_field set sequence=4,presence=2 where tabid=@tabid and block=@block and columnname='contactid';

select fieldid into @fieldid from ld_field where tabid = @tabid and columnname = @columnname;
delete from ld_tranlabel where trantable ='LD_field' and relateid=@fieldid;
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'zh','LD_field',@tabid,@fieldid,@zh;

insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'en','LD_field',@tabid,@fieldid,@en;

select 0 into @i;
update ld_field set sequence=(@i:=@i+1) where tabid=@tabid and block=@block order by sequence;

call AddColumn(@tablename,@columnname,'varchar','200',NULL);
alter table LD_potential modify column 5w2p_plan2 text;
delimiter;

select tabid into @tabid from ld_tab where name='Potentials';
select blockid into @block from ld_blocks where tabid=@tabid and blocklabel='LBI_5W2P';
select 'LD_potential' into @tablename;
select '5w2p_why2' into @columnname;
select '5w2p_why2' into @fieldname;
select '主要负责人是谁（who）' into @zh;
select 'Who is mainly responsible for(who)' into @en;
select 19 into @uitype;
select 1 into @displaytype;
select 'V~O' into @typeofdata;
select ifnull(max(sequence),0)+1 into @seq from ld_field where tabid=@tabid and block=@block;

select max(fieldid) into @fieldid from ld_field;
insert into ld_field(tabid,fieldid,columnname,tablename,generatedtype,uitype,fieldname,fieldlabel,readonly,presence,maximumlength,sequence,block,displaytype,typeofdata,quickcreate,info_type,searchfieldtype)
select @tabid,@fieldid+1,@columnname,@tablename,1,@uitype,@fieldname,@zh,1,2,100,@seq,@block,@displaytype,@typeofdata,3,'BAS',1 from dual 
where not exists (select 1 from ld_field where tabid = @tabid and columnname = @columnname);
update ld_field_seq set id = (select max(fieldid) from ld_field);
update ld_field set sequence=4,presence=2 where tabid=@tabid and block=@block and columnname='contactid';

select fieldid into @fieldid from ld_field where tabid = @tabid and columnname = @columnname;
delete from ld_tranlabel where trantable ='LD_field' and relateid=@fieldid;
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'zh','LD_field',@tabid,@fieldid,@zh;

insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'en','LD_field',@tabid,@fieldid,@en;

select 0 into @i;
update ld_field set sequence=(@i:=@i+1) where tabid=@tabid and block=@block order by sequence;

call AddColumn(@tablename,@columnname,'varchar','200',NULL);
alter table LD_potential modify column 5w2p_why2 text;
delimiter;

select tabid into @tabid from ld_tab where name='Potentials';
select blockid into @block from ld_blocks where tabid=@tabid and blocklabel='LBI_5W2P';
select 'LD_potential' into @tablename;
select '5w2p_why3' into @columnname;
select '5w2p_why3' into @fieldname;
select '决策因素有哪些（what）' into @zh;
select 'What are the factors of decision(what)' into @en;
select 19 into @uitype;
select 1 into @displaytype;
select 'V~O' into @typeofdata;
select ifnull(max(sequence),0)+1 into @seq from ld_field where tabid=@tabid and block=@block;

select max(fieldid) into @fieldid from ld_field;
insert into ld_field(tabid,fieldid,columnname,tablename,generatedtype,uitype,fieldname,fieldlabel,readonly,presence,maximumlength,sequence,block,displaytype,typeofdata,quickcreate,info_type,searchfieldtype)
select @tabid,@fieldid+1,@columnname,@tablename,1,@uitype,@fieldname,@zh,1,2,100,@seq,@block,@displaytype,@typeofdata,3,'BAS',1 from dual 
where not exists (select 1 from ld_field where tabid = @tabid and columnname = @columnname);
update ld_field_seq set id = (select max(fieldid) from ld_field);
update ld_field set sequence=4,presence=2 where tabid=@tabid and block=@block and columnname='contactid';

select fieldid into @fieldid from ld_field where tabid = @tabid and columnname = @columnname;
delete from ld_tranlabel where trantable ='LD_field' and relateid=@fieldid;
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'zh','LD_field',@tabid,@fieldid,@zh;

insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'en','LD_field',@tabid,@fieldid,@en;

select 0 into @i;
update ld_field set sequence=(@i:=@i+1) where tabid=@tabid and block=@block order by sequence;

call AddColumn(@tablename,@columnname,'varchar','200',NULL);
alter table LD_potential modify column 5w2p_why3 text;
delimiter;

select tabid into @tabid from ld_tab where name='Potentials';
select blockid into @block from ld_blocks where tabid=@tabid and blocklabel='LBI_5W2P';
select 'LD_potential' into @tablename;
select '5w2p_why4' into @columnname;
select '5w2p_why4' into @fieldname;
select '决策流程是怎样的（what）' into @zh;
select 'What is the decision-making process(what)' into @en;
select 19 into @uitype;
select 1 into @displaytype;
select 'V~O' into @typeofdata;
select ifnull(max(sequence),0)+1 into @seq from ld_field where tabid=@tabid and block=@block;

select max(fieldid) into @fieldid from ld_field;
insert into ld_field(tabid,fieldid,columnname,tablename,generatedtype,uitype,fieldname,fieldlabel,readonly,presence,maximumlength,sequence,block,displaytype,typeofdata,quickcreate,info_type,searchfieldtype)
select @tabid,@fieldid+1,@columnname,@tablename,1,@uitype,@fieldname,@zh,1,2,100,@seq,@block,@displaytype,@typeofdata,3,'BAS',1 from dual 
where not exists (select 1 from ld_field where tabid = @tabid and columnname = @columnname);
update ld_field_seq set id = (select max(fieldid) from ld_field);
update ld_field set sequence=4,presence=2 where tabid=@tabid and block=@block and columnname='contactid';

select fieldid into @fieldid from ld_field where tabid = @tabid and columnname = @columnname;
delete from ld_tranlabel where trantable ='LD_field' and relateid=@fieldid;
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'zh','LD_field',@tabid,@fieldid,@zh;

insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'en','LD_field',@tabid,@fieldid,@en;

select 0 into @i;
update ld_field set sequence=(@i:=@i+1) where tabid=@tabid and block=@block order by sequence;

call AddColumn(@tablename,@columnname,'varchar','200',NULL);
alter table LD_potential modify column 5w2p_why4 text;
delimiter;

select tabid into @tabid from ld_tab where name='Potentials';
select blockid into @block from ld_blocks where tabid=@tabid and blocklabel='LBI_5W2P';
select 'LD_potential' into @tablename;
select '5w2p_why5' into @columnname;
select '5w2p_why5' into @fieldname;
select '竞争对手提供的方案（what）' into @zh;
select 'What are the solutions provide by competitors(what)' into @en;
select 19 into @uitype;
select 1 into @displaytype;
select 'V~O' into @typeofdata;
select ifnull(max(sequence),0)+1 into @seq from ld_field where tabid=@tabid and block=@block;

select max(fieldid) into @fieldid from ld_field;
insert into ld_field(tabid,fieldid,columnname,tablename,generatedtype,uitype,fieldname,fieldlabel,readonly,presence,maximumlength,sequence,block,displaytype,typeofdata,quickcreate,info_type,searchfieldtype)
select @tabid,@fieldid+1,@columnname,@tablename,1,@uitype,@fieldname,@zh,1,2,100,@seq,@block,@displaytype,@typeofdata,3,'BAS',1 from dual 
where not exists (select 1 from ld_field where tabid = @tabid and columnname = @columnname);
update ld_field_seq set id = (select max(fieldid) from ld_field);
update ld_field set sequence=4,presence=2 where tabid=@tabid and block=@block and columnname='contactid';

select fieldid into @fieldid from ld_field where tabid = @tabid and columnname = @columnname;
delete from ld_tranlabel where trantable ='LD_field' and relateid=@fieldid;
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'zh','LD_field',@tabid,@fieldid,@zh;

insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'en','LD_field',@tabid,@fieldid,@en;

select 0 into @i;
update ld_field set sequence=(@i:=@i+1) where tabid=@tabid and block=@block order by sequence;

call AddColumn(@tablename,@columnname,'varchar','200',NULL);
alter table LD_potential modify column 5w2p_why5 text;
delimiter;

select tabid into @tabid from ld_tab where name='Potentials';
select blockid into @block from ld_blocks where tabid=@tabid and blocklabel='LBI_SWOT';
select 'LD_potential' into @tablename;
select 'swort_s' into @columnname;
select 'swort_s' into @fieldname;
select '优势(S)' into @zh;
select 'Strengths' into @en;
select 21 into @uitype;
select 1 into @displaytype;
select 'V~O' into @typeofdata;
select ifnull(max(sequence),0)+1 into @seq from ld_field where tabid=@tabid and block=@block;

select max(fieldid) into @fieldid from ld_field;
insert into ld_field(tabid,fieldid,columnname,tablename,generatedtype,uitype,fieldname,fieldlabel,readonly,presence,maximumlength,sequence,block,displaytype,typeofdata,quickcreate,info_type,searchfieldtype)
select @tabid,@fieldid+1,@columnname,@tablename,1,@uitype,@fieldname,@zh,1,2,100,@seq,@block,@displaytype,@typeofdata,3,'BAS',1 from dual 
where not exists (select 1 from ld_field where tabid = @tabid and columnname = @columnname);
update ld_field_seq set id = (select max(fieldid) from ld_field);
update ld_field set sequence=4,presence=2 where tabid=@tabid and block=@block and columnname='contactid';

select fieldid into @fieldid from ld_field where tabid = @tabid and columnname = @columnname;
delete from ld_tranlabel where trantable ='LD_field' and relateid=@fieldid;
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'zh','LD_field',@tabid,@fieldid,@zh;

insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'en','LD_field',@tabid,@fieldid,@en;

select 0 into @i;
update ld_field set sequence=(@i:=@i+1) where tabid=@tabid and block=@block order by sequence;

call AddColumn(@tablename,@columnname,'varchar','200',NULL);
alter table LD_potential modify column swort_s text;
delimiter;

select tabid into @tabid from ld_tab where name='Potentials';
select blockid into @block from ld_blocks where tabid=@tabid and blocklabel='LBI_SWOT';
select 'LD_potential' into @tablename;
select 'swort_w' into @columnname;
select 'swort_w' into @fieldname;
select '劣势(W)' into @zh;
select 'Weaknesses' into @en;
select 21 into @uitype;
select 1 into @displaytype;
select 'V~O' into @typeofdata;
select ifnull(max(sequence),0)+1 into @seq from ld_field where tabid=@tabid and block=@block;

select max(fieldid) into @fieldid from ld_field;
insert into ld_field(tabid,fieldid,columnname,tablename,generatedtype,uitype,fieldname,fieldlabel,readonly,presence,maximumlength,sequence,block,displaytype,typeofdata,quickcreate,info_type,searchfieldtype)
select @tabid,@fieldid+1,@columnname,@tablename,1,@uitype,@fieldname,@zh,1,2,100,@seq,@block,@displaytype,@typeofdata,3,'BAS',1 from dual 
where not exists (select 1 from ld_field where tabid = @tabid and columnname = @columnname);
update ld_field_seq set id = (select max(fieldid) from ld_field);
update ld_field set sequence=4,presence=2 where tabid=@tabid and block=@block and columnname='contactid';

select fieldid into @fieldid from ld_field where tabid = @tabid and columnname = @columnname;
delete from ld_tranlabel where trantable ='LD_field' and relateid=@fieldid;
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'zh','LD_field',@tabid,@fieldid,@zh;

insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'en','LD_field',@tabid,@fieldid,@en;

select 0 into @i;
update ld_field set sequence=(@i:=@i+1) where tabid=@tabid and block=@block order by sequence;

call AddColumn(@tablename,@columnname,'varchar','200',NULL);
alter table LD_potential modify column swort_w text;
delimiter;


select tabid into @tabid from ld_tab where name='Potentials';
select blockid into @block from ld_blocks where tabid=@tabid and blocklabel='LBI_SWOT';
select 'LD_potential' into @tablename;
select 'swort_o' into @columnname;
select 'swort_o' into @fieldname;
select '机会(O)' into @zh;
select 'Opportunities' into @en;
select 21 into @uitype;
select 1 into @displaytype;
select 'V~O' into @typeofdata;
select ifnull(max(sequence),0)+1 into @seq from ld_field where tabid=@tabid and block=@block;

select max(fieldid) into @fieldid from ld_field;
insert into ld_field(tabid,fieldid,columnname,tablename,generatedtype,uitype,fieldname,fieldlabel,readonly,presence,maximumlength,sequence,block,displaytype,typeofdata,quickcreate,info_type,searchfieldtype)
select @tabid,@fieldid+1,@columnname,@tablename,1,@uitype,@fieldname,@zh,1,2,100,@seq,@block,@displaytype,@typeofdata,3,'BAS',1 from dual 
where not exists (select 1 from ld_field where tabid = @tabid and columnname = @columnname);
update ld_field_seq set id = (select max(fieldid) from ld_field);
update ld_field set sequence=4,presence=2 where tabid=@tabid and block=@block and columnname='contactid';

select fieldid into @fieldid from ld_field where tabid = @tabid and columnname = @columnname;
delete from ld_tranlabel where trantable ='LD_field' and relateid=@fieldid;
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'zh','LD_field',@tabid,@fieldid,@zh;

insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'en','LD_field',@tabid,@fieldid,@en;

select 0 into @i;
update ld_field set sequence=(@i:=@i+1) where tabid=@tabid and block=@block order by sequence;

call AddColumn(@tablename,@columnname,'varchar','200',NULL);
alter table LD_potential modify column swort_o text;
delimiter;


select tabid into @tabid from ld_tab where name='Potentials';
select blockid into @block from ld_blocks where tabid=@tabid and blocklabel='LBI_SWOT';
select 'LD_potential' into @tablename;
select 'swort_t' into @columnname;
select 'swort_t' into @fieldname;
select '威胁(T)' into @zh;
select 'Threats' into @en;
select 21 into @uitype;
select 1 into @displaytype;
select 'V~O' into @typeofdata;
select ifnull(max(sequence),0)+1 into @seq from ld_field where tabid=@tabid and block=@block;

select max(fieldid) into @fieldid from ld_field;
insert into ld_field(tabid,fieldid,columnname,tablename,generatedtype,uitype,fieldname,fieldlabel,readonly,presence,maximumlength,sequence,block,displaytype,typeofdata,quickcreate,info_type,searchfieldtype)
select @tabid,@fieldid+1,@columnname,@tablename,1,@uitype,@fieldname,@zh,1,2,100,@seq,@block,@displaytype,@typeofdata,3,'BAS',1 from dual 
where not exists (select 1 from ld_field where tabid = @tabid and columnname = @columnname);
update ld_field_seq set id = (select max(fieldid) from ld_field);
update ld_field set sequence=4,presence=2 where tabid=@tabid and block=@block and columnname='contactid';

select fieldid into @fieldid from ld_field where tabid = @tabid and columnname = @columnname;
delete from ld_tranlabel where trantable ='LD_field' and relateid=@fieldid;
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'zh','LD_field',@tabid,@fieldid,@zh;

insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'en','LD_field',@tabid,@fieldid,@en;

select 0 into @i;
update ld_field set sequence=(@i:=@i+1) where tabid=@tabid and block=@block order by sequence;

call AddColumn(@tablename,@columnname,'varchar','200',NULL);
alter table LD_potential modify column swort_t text;
delimiter;


call getallprofile('Potentials');
call fieldprofile('Potentials');
delimiter;

SELECT tabid into @tabid from LD_tab where name ='Attachment';
UPDATE LD_tab set ownedby=0,isentitytype=1 where tabid=@tabid;
delimiter;
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'zh','ACHINESEACCOUNTFORCHARACTERS','一个中文占2个字符，一个英文占1个字符','fixedstr' from dual 
where not EXISTS(select 1 from ld_desk  where languagetype='zh' and labelbol='ACHINESEACCOUNTFORCHARACTERS' and Labeltype='fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'en','ACHINESEACCOUNTFORCHARACTERS','A Chinese accounted for 2 characters, a English accounted for 1 characters','fixedstr' from dual 
where not EXISTS(select 1 from ld_desk  where languagetype='en' and labelbol='ACHINESEACCOUNTFORCHARACTERS' and Labeltype='fixedstr');
delimiter;

update ld_desk set Fieldlabel='Try to search' where labelbol='INPUTAKEYWORDSQUERY' and languagetype='en' and Labeltype = 'fixedstr';
update ld_desk set Fieldlabel='Try to search' where labelbol='INPUTAKEYWORDSQUERY' and languagetype='en' and Labeltype = 'jspop';
delimiter;
update ld_desk set Fieldlabel='状态' where labelbol='STATUS' and languagetype='zh' and Labeltype = 'fixedstr';
update ld_desk set Fieldlabel='Status' where labelbol='STATUS' and languagetype='en' and Labeltype = 'fixedstr';
delimiter;

UPDATE ld_activity SET visibility='私有' WHERE visibility='Private';
delimiter;

SELECT tabid INTO @tabid FROM ld_tab WHERE NAME = 'PurchaseInvoice';
SELECT MAX(id) INTO @id FROM ld_relatedlists_lable;

SELECT fieldid INTO @fieldid FROM ld_field WHERE tabid = @tabid AND columnname = 'subject';
INSERT INTO ld_relatedlists_lable(id,tabid,fieldid,width,sequence,presence,edit)
SELECT @id+1,@tabid,@fieldid,0,0,1,0 FROM DUAL
WHERE NOT EXISTS(SELECT 1 FROM ld_relatedlists_lable WHERE tabid=@tabid AND fieldid=@fieldid);

SELECT fieldid INTO @fieldid FROM ld_field WHERE tabid = @tabid AND columnname = 'purchaseinvoice_no';
INSERT INTO ld_relatedlists_lable(id,tabid,fieldid,width,sequence,presence,edit)
SELECT @id+2,@tabid,@fieldid,0,1,1,0 FROM DUAL
WHERE NOT EXISTS(SELECT 1 FROM ld_relatedlists_lable WHERE tabid=@tabid AND fieldid=@fieldid);

SELECT fieldid INTO @fieldid FROM ld_field WHERE tabid = @tabid AND columnname = 'vendorid';
INSERT INTO ld_relatedlists_lable(id,tabid,fieldid,width,sequence,presence,edit)
SELECT @id+3,@tabid,@fieldid,0,2,1,0 FROM DUAL
WHERE NOT EXISTS(SELECT 1 FROM ld_relatedlists_lable WHERE tabid=@tabid AND fieldid=@fieldid);

SELECT fieldid INTO @fieldid FROM ld_field WHERE tabid = @tabid AND columnname = 'purchaseinvoicestatus';
INSERT INTO ld_relatedlists_lable(id,tabid,fieldid,width,sequence,presence,edit)
SELECT @id+4,@tabid,@fieldid,0,3,1,0 FROM DUAL
WHERE NOT EXISTS(SELECT 1 FROM ld_relatedlists_lable WHERE tabid=@tabid AND fieldid=@fieldid);

SELECT fieldid INTO @fieldid FROM ld_field WHERE tabid = @tabid AND columnname = 'total';
INSERT INTO ld_relatedlists_lable(id,tabid,fieldid,width,sequence,presence,edit)
SELECT @id+5,@tabid,@fieldid,0,4,1,0 FROM DUAL
WHERE NOT EXISTS(SELECT 1 FROM ld_relatedlists_lable WHERE tabid=@tabid AND fieldid=@fieldid);

SELECT fieldid INTO @fieldid FROM ld_field WHERE tabid = @tabid AND columnname = 'purchaseinvoicedate';
INSERT INTO ld_relatedlists_lable(id,tabid,fieldid,width,sequence,presence,edit)
SELECT @id+6,@tabid,@fieldid,0,5,1,0 FROM DUAL
WHERE NOT EXISTS(SELECT 1 FROM ld_relatedlists_lable WHERE tabid=@tabid AND fieldid=@fieldid);

SELECT fieldid INTO @fieldid FROM ld_field WHERE tabid = @tabid AND columnname = 'purchaseinvoicetype';
INSERT INTO ld_relatedlists_lable(id,tabid,fieldid,width,sequence,presence,edit)
SELECT @id+7,@tabid,@fieldid,0,6,1,0 FROM DUAL
WHERE NOT EXISTS(SELECT 1 FROM ld_relatedlists_lable WHERE tabid=@tabid AND fieldid=@fieldid);

SELECT fieldid INTO @fieldid FROM ld_field WHERE tabid = @tabid AND columnname = 'purchaseinvoicenum';
INSERT INTO ld_relatedlists_lable(id,tabid,fieldid,width,sequence,presence,edit)
SELECT @id+8,@tabid,@fieldid,0,7,1,0 FROM DUAL
WHERE NOT EXISTS(SELECT 1 FROM ld_relatedlists_lable WHERE tabid=@tabid AND fieldid=@fieldid);

SELECT fieldid INTO @fieldid FROM ld_field WHERE tabid = @tabid AND columnname = 'smownerid';
INSERT INTO ld_relatedlists_lable(id,tabid,fieldid,width,sequence,presence,edit)
SELECT @id+9,@tabid,@fieldid,0,8,1,0 FROM DUAL
WHERE NOT EXISTS(SELECT 1 FROM ld_relatedlists_lable WHERE tabid=@tabid AND fieldid=@fieldid);
delimiter;


SELECT tabid INTO @tabid FROM ld_tab WHERE NAME = 'ContactRecords';
SELECT fieldid INTO @fieldid FROM ld_field WHERE tabid = @tabid AND columnname = 'accountid';
SELECT MAX(id) INTO @id FROM ld_relatedlists_lable;
INSERT INTO ld_relatedlists_lable(id,tabid,fieldid,width,sequence,presence,edit)
SELECT @id+1,@tabid,@fieldid,0,0,1,0 FROM DUAL
WHERE NOT EXISTS(SELECT 1 FROM ld_relatedlists_lable WHERE tabid=@tabid AND fieldid=@fieldid);
delimiter;


SELECT tabid INTO @tabid FROM ld_tab WHERE NAME = 'ProjectTask';
SELECT fieldid INTO @fieldid FROM ld_field WHERE tabid = @tabid AND columnname = 'accountid';
SELECT MAX(id) INTO @id FROM ld_relatedlists_lable;
INSERT INTO ld_relatedlists_lable(id,tabid,fieldid,width,sequence,presence,edit)
SELECT @id+1,@tabid,@fieldid,0,0,1,0 FROM DUAL
WHERE NOT EXISTS(SELECT 1 FROM ld_relatedlists_lable WHERE tabid=@tabid AND fieldid=@fieldid);
delimiter;

SELECT tabid INTO @tabid FROM ld_tab WHERE NAME = 'Project';
SELECT fieldid INTO @fieldid FROM ld_field WHERE tabid = @tabid AND columnname = 'accountid';
SELECT MAX(id) INTO @id FROM ld_relatedlists_lable;
INSERT INTO ld_relatedlists_lable(id,tabid,fieldid,width,sequence,presence,edit)
SELECT @id+1,@tabid,@fieldid,0,0,1,0 FROM DUAL
WHERE NOT EXISTS(SELECT 1 FROM ld_relatedlists_lable WHERE tabid=@tabid AND fieldid=@fieldid);
delimiter;

SELECT tabid INTO @tabid FROM ld_tab WHERE NAME = 'Quotes';
SELECT fieldid INTO @fieldid FROM ld_field WHERE tabid = @tabid AND columnname = 'accountid';
SELECT MAX(id) INTO @id FROM ld_relatedlists_lable;
INSERT INTO ld_relatedlists_lable(id,tabid,fieldid,width,sequence,presence,edit)
SELECT @id+1,@tabid,@fieldid,0,0,1,0 FROM DUAL
WHERE NOT EXISTS(SELECT 1 FROM ld_relatedlists_lable WHERE tabid=@tabid AND fieldid=@fieldid);
delimiter;

SELECT tabid INTO @tabid FROM ld_tab WHERE NAME = 'SalesBack';
SELECT fieldid INTO @fieldid FROM ld_field WHERE tabid = @tabid AND columnname = 'accountid';
SELECT MAX(id) INTO @id FROM ld_relatedlists_lable;
INSERT INTO ld_relatedlists_lable(id,tabid,fieldid,width,sequence,presence,edit)
SELECT @id+1,@tabid,@fieldid,0,0,1,0 FROM DUAL
WHERE NOT EXISTS(SELECT 1 FROM ld_relatedlists_lable WHERE tabid=@tabid AND fieldid=@fieldid);
delimiter;

SELECT tabid INTO @tabid FROM ld_tab WHERE NAME = 'Invoice';
SELECT fieldid INTO @fieldid FROM ld_field WHERE tabid = @tabid AND columnname = 'accountid';
SELECT MAX(id) INTO @id FROM ld_relatedlists_lable;
INSERT INTO ld_relatedlists_lable(id,tabid,fieldid,width,sequence,presence,edit)
SELECT @id+1,@tabid,@fieldid,0,0,1,0 FROM DUAL
WHERE NOT EXISTS(SELECT 1 FROM ld_relatedlists_lable WHERE tabid=@tabid AND fieldid=@fieldid);
delimiter;

SELECT tabid INTO @tabid FROM ld_tab WHERE NAME = 'CashBill';
SELECT fieldid INTO @fieldid FROM ld_field WHERE tabid = @tabid AND columnname = 'accountid';
SELECT MAX(id) INTO @id FROM ld_relatedlists_lable;
INSERT INTO ld_relatedlists_lable(id,tabid,fieldid,width,sequence,presence,edit)
SELECT @id+1,@tabid,@fieldid,0,0,1,0 FROM DUAL
WHERE NOT EXISTS(SELECT 1 FROM ld_relatedlists_lable WHERE tabid=@tabid AND fieldid=@fieldid);
delimiter;

SELECT tabid INTO @tabid FROM ld_tab WHERE NAME = 'PaymentPlan';
SELECT fieldid INTO @fieldid FROM ld_field WHERE tabid = @tabid AND columnname = 'accountid';
SELECT MAX(id) INTO @id FROM ld_relatedlists_lable;
INSERT INTO ld_relatedlists_lable(id,tabid,fieldid,width,sequence,presence,edit)
SELECT @id+1,@tabid,@fieldid,0,0,1,0 FROM DUAL
WHERE NOT EXISTS(SELECT 1 FROM ld_relatedlists_lable WHERE tabid=@tabid AND fieldid=@fieldid);
delimiter;

SELECT tabid INTO @tabid FROM ld_tab WHERE NAME = 'Stock';
SELECT fieldid INTO @fieldid FROM ld_field WHERE tabid = @tabid AND columnname = 'vendor_id';
SELECT MAX(id) INTO @id FROM ld_relatedlists_lable;
INSERT INTO ld_relatedlists_lable(id,tabid,fieldid,width,sequence,presence,edit)
SELECT @id+1,@tabid,@fieldid,0,0,1,0 FROM DUAL
WHERE NOT EXISTS(SELECT 1 FROM ld_relatedlists_lable WHERE tabid=@tabid AND fieldid=@fieldid);
delimiter;

update ld_relatedlists set label = 'Products Package' where tabid = 14 and related_tabid = 14;
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'zh','PRODUCTPACKAGE','产品套餐','fixedstr' from dual 
where not EXISTS(select 1 from ld_desk  where languagetype='zh' and labelbol='PRODUCTPACKAGE' and Labeltype='fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'en','PRODUCTPACKAGE','Product Package','fixedstr' from dual 
where not EXISTS(select 1 from ld_desk  where languagetype='en' and labelbol='PRODUCTPACKAGE' and Labeltype='fixedstr');
delimiter;

update ld_settings_field_seq set id=(select max(fieldid) from ld_settings_field);
select id into @id from ld_settings_field_seq;
select sequence into @sequence from LD_settings_field where name = 'LBL_RELATED_PARAMETERS';
update LD_settings_field set sequence = sequence+1 where blockid = 3 and sequence > @sequence;

insert into LD_settings_field(fieldid,blockid,name,iconpath,description,linkto,sequence,active)
select @id+1,3,'LBL_ACCOUNTS_CONTACTS_FIELDS','productfield.png','LBL_ACCOUNTS_CONTACTS_DESCRIPTION','index.php?module=Settings&action=AccountsContactsField&parenttab=Settings',@sequence+1,0
from dual where not EXISTS(select 1 from LD_settings_field  where name ='LBL_ACCOUNTS_CONTACTS_FIELDS');
update ld_settings_field_seq set id = (select max(fieldid) from LD_settings_field);
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'zh','LBL_ACCOUNTS_CONTACTS_FIELDS','客户和联系人关联字段','fixedstr' from dual 
where not EXISTS(select 1 from ld_desk  where languagetype='zh' and labelbol='LBL_ACCOUNTS_CONTACTS_FIELDS' and Labeltype='fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'en','LBL_ACCOUNTS_CONTACTS_FIELDS','Related fields of accounts and contacts','fixedstr' from dual 
where not EXISTS(select 1 from ld_desk  where languagetype='en' and labelbol='LBL_ACCOUNTS_CONTACTS_FIELDS' and Labeltype='fixedstr');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'zh','LBL_ACCOUNTS_CONTACTS_DESCRIPTION','定制{$HelpDesk.HelpDesk}、{$ProjectTask.ProjectTask}模块关联的客户和联系人字段','fixedstr' from dual 
where not EXISTS(select 1 from ld_desk  where languagetype='zh' and labelbol='LBL_ACCOUNTS_CONTACTS_DESCRIPTION' and Labeltype='fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'en','LBL_ACCOUNTS_CONTACTS_DESCRIPTION','Customise the related fields of accounts and contacts for trouble tickets and project tasks','fixedstr' from dual 
where not EXISTS(select 1 from ld_desk  where languagetype='en' and labelbol='LBL_ACCOUNTS_CONTACTS_DESCRIPTION' and Labeltype='fixedstr');
delimiter;

call addcolumn('LD_field','associatedfields','int','1',1);
update LD_field set associatedfields = 1 where associatedfields is null;
call addcolumn('LD_field','associatedsequence','int','1',0);

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'zh','Selected_Fields','已选字段','jspop' from dual 
where not EXISTS(select 1 from ld_desk  where languagetype='zh' and labelbol='Selected_Fields' and Labeltype='jspop');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'en','Selected_Fields','Selected Fields','jspop' from dual 
where not EXISTS(select 1 from ld_desk  where languagetype='en' and labelbol='Selected_Fields' and Labeltype='jspop');
delimiter;

update ld_systems_deploy set deploy_value = 1 where deploy_type = 32;
delimiter;

update ld_systems_deploy set deploy_value = 1 where deploy_type = 25;
delimiter;

select tabid into @tabid from ld_tab where `name` = 'Accounts';
update ld_field set associatedfields = 0 where tabid = @tabid and columnname in ('bill_street','traffic','smownerid');
delimiter;

select tabid into @tabid from ld_tab where `name` = 'Contacts';
update ld_field set associatedfields = 0 where tabid = @tabid and columnname in ('pphone','mobile','email');
delimiter;

UPDATE ld_activity SET smownerid = smcreatorid WHERE smownerid = 0 AND smcreatorid > 0 AND activitytype = 'Emails';
delimiter;
SELECT tabid INTO @tabid FROM ld_tab WHERE NAME = 'CashBack';
SELECT MAX(id) INTO @id FROM ld_relatedlists_lable;

SELECT fieldid INTO @fieldid FROM ld_field WHERE tabid = @tabid AND columnname = 'cashback_no';
INSERT INTO ld_relatedlists_lable(id,tabid,fieldid,width,sequence,presence,edit)
SELECT @id+1,@tabid,@fieldid,0,0,1,0 FROM DUAL
WHERE NOT EXISTS(SELECT 1 FROM ld_relatedlists_lable WHERE tabid=@tabid AND fieldid=@fieldid);

SELECT fieldid INTO @fieldid FROM ld_field WHERE tabid = @tabid AND columnname = 'accountid';
INSERT INTO ld_relatedlists_lable(id,tabid,fieldid,width,sequence,presence,edit)
SELECT @id+2,@tabid,@fieldid,0,1,1,0 FROM DUAL
WHERE NOT EXISTS(SELECT 1 FROM ld_relatedlists_lable WHERE tabid=@tabid AND fieldid=@fieldid);

SELECT fieldid INTO @fieldid FROM ld_field WHERE tabid = @tabid AND columnname = 'total';
INSERT INTO ld_relatedlists_lable(id,tabid,fieldid,width,sequence,presence,edit)
SELECT @id+3,@tabid,@fieldid,0,2,1,0 FROM DUAL
WHERE NOT EXISTS(SELECT 1 FROM ld_relatedlists_lable WHERE tabid=@tabid AND fieldid=@fieldid);

SELECT fieldid INTO @fieldid FROM ld_field WHERE tabid = @tabid AND columnname = 'cashbackdate';
INSERT INTO ld_relatedlists_lable(id,tabid,fieldid,width,sequence,presence,edit)
SELECT @id+4,@tabid,@fieldid,0,3,1,0 FROM DUAL
WHERE NOT EXISTS(SELECT 1 FROM ld_relatedlists_lable WHERE tabid=@tabid AND fieldid=@fieldid);

SELECT fieldid INTO @fieldid FROM ld_field WHERE tabid = @tabid AND columnname = 'salesbackid';
INSERT INTO ld_relatedlists_lable(id,tabid,fieldid,width,sequence,presence,edit)
SELECT @id+5,@tabid,@fieldid,0,4,1,0 FROM DUAL
WHERE NOT EXISTS(SELECT 1 FROM ld_relatedlists_lable WHERE tabid=@tabid AND fieldid=@fieldid);

SELECT fieldid INTO @fieldid FROM ld_field WHERE tabid = @tabid AND columnname = 'bankaccountsetid';
INSERT INTO ld_relatedlists_lable(id,tabid,fieldid,width,sequence,presence,edit)
SELECT @id+6,@tabid,@fieldid,0,5,1,0 FROM DUAL
WHERE NOT EXISTS(SELECT 1 FROM ld_relatedlists_lable WHERE tabid=@tabid AND fieldid=@fieldid);

SELECT fieldid INTO @fieldid FROM ld_field WHERE tabid = @tabid AND columnname = 'criscashbill';
INSERT INTO ld_relatedlists_lable(id,tabid,fieldid,width,sequence,presence,edit)
SELECT @id+7,@tabid,@fieldid,0,6,1,0 FROM DUAL
WHERE NOT EXISTS(SELECT 1 FROM ld_relatedlists_lable WHERE tabid=@tabid AND fieldid=@fieldid);

SELECT fieldid INTO @fieldid FROM ld_field WHERE tabid = @tabid AND columnname = 'crpaymentmethod';
INSERT INTO ld_relatedlists_lable(id,tabid,fieldid,width,sequence,presence,edit)
SELECT @id+8,@tabid,@fieldid,0,7,1,0 FROM DUAL
WHERE NOT EXISTS(SELECT 1 FROM ld_relatedlists_lable WHERE tabid=@tabid AND fieldid=@fieldid);

SELECT fieldid INTO @fieldid FROM ld_field WHERE tabid = @tabid AND columnname = 'smownerid';
INSERT INTO ld_relatedlists_lable(id,tabid,fieldid,width,sequence,presence,edit)
SELECT @id+9,@tabid,@fieldid,0,8,1,0 FROM DUAL
WHERE NOT EXISTS(SELECT 1 FROM ld_relatedlists_lable WHERE tabid=@tabid AND fieldid=@fieldid);
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'zh','ADMIN','管理员','fixedstr' from dual
where not EXISTS(select 1 from ld_desk  where languagetype='zh' and labelbol='ADMIN' and Labeltype='fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'en','ADMIN','Administrator','fixedstr' from dual
where not EXISTS(select 1 from ld_desk  where languagetype='en' and labelbol='ADMIN' and Labeltype='fixedstr');
delimiter;

update ld_tranlabel set fieldlabel = '合同订单' where languagetype = 'zh' and tabid in 
(select tabid from ld_tab where name = 'Invoice') 
and trantable = 'LD_field' and Relateid in 
(select fieldid from ld_field where columnname= 'salesorderid' and tabid in 
(select tabid from ld_tab where name = 'Invoice') );

update ld_tranlabel set fieldlabel = 'Sales Order' where languagetype = 'en' and tabid in 
(select tabid from ld_tab where name = 'Invoice') 
and trantable = 'LD_field' and Relateid in 
(select fieldid from ld_field where columnname= 'salesorderid' and tabid in 
(select tabid from ld_tab where name = 'Invoice') );
delimiter;

UPDATE ld_field SET masseditable = 2 WHERE uitype IN (200,201,202) AND masseditable != 2;
delimiter;
-- 2014-09-24

select fieldid into @fieldid from ld_field where tabid=2 and columnname='5w2p_why1';
update ld_tranlabel set fieldlabel='客户需求或痛点（why）' where tabid=2 and trantable='LD_field' and Relateid=@fieldid and languagetype='zh';

select fieldid into @fieldid from ld_field where tabid=2 and columnname='5w2p_why3';
update ld_tranlabel set fieldlabel='关键决策因素有哪些（what）' where tabid=2 and trantable='LD_field' and Relateid=@fieldid and languagetype='zh';
delimiter;

select tabid into @tabid from ld_tab where name = 'SalesOrder';
select tabid into @tabid2 from ld_tab where name = 'Documents';
SELECT max(sequence) into @sequence from ld_quickactions where tabid=@tabid; 
insert into ld_quickactions(tabid,related_tabid,sequence,presence)
select @tabid,@tabid2,@sequence+1,0 from dual 
where not EXISTS(select 1 from ld_quickactions  where tabid=@tabid and related_tabid=@tabid2);
delimiter;

select tabid into @tabid from ld_tab where name = 'SalesOrder';
SELECT tabid into @related_tabid from ld_tab where name='CashBill';
UPDATE ld_quickactions set sequence=0 where tabid=@tabid and related_tabid=@related_tabid;
delimiter;
select tabid into @tabid from ld_tab where name = 'SalesOrder';
SELECT tabid into @related_tabid from ld_tab where name='OutboundOrder';
UPDATE ld_quickactions set sequence=1 where tabid=@tabid and related_tabid=@related_tabid;
delimiter;
select tabid into @tabid from ld_tab where name = 'SalesOrder';
SELECT tabid into @related_tabid from ld_tab where name='PaymentPlan';
UPDATE ld_quickactions set sequence=2 where tabid=@tabid and related_tabid=@related_tabid;
delimiter;
select tabid into @tabid from ld_tab where name = 'SalesOrder';
SELECT tabid into @related_tabid from ld_tab where name='Invoice';
UPDATE ld_quickactions set sequence=3 where tabid=@tabid and related_tabid=@related_tabid;
delimiter;
select tabid into @tabid from ld_tab where name = 'SalesOrder';
SELECT tabid into @related_tabid from ld_tab where name='ServiceContracts';
UPDATE ld_quickactions set sequence=4 where tabid=@tabid and related_tabid=@related_tabid;
delimiter;
select tabid into @tabid from ld_tab where name = 'SalesOrder';
SELECT tabid into @related_tabid from ld_tab where name='HelpDesk';
UPDATE ld_quickactions set sequence=5 where tabid=@tabid and related_tabid=@related_tabid;
delimiter;
select tabid into @tabid from ld_tab where name = 'SalesOrder';
SELECT tabid into @related_tabid from ld_tab where name='Expense';
UPDATE ld_quickactions set sequence=6 where tabid=@tabid and related_tabid=@related_tabid;
delimiter;
select tabid into @tabid from ld_tab where name = 'SalesOrder';
SELECT tabid into @related_tabid from ld_tab where name='Commission';
UPDATE ld_quickactions set sequence=7 where tabid=@tabid and related_tabid=@related_tabid;
delimiter;
select tabid into @tabid from ld_tab where name = 'SalesOrder';
SELECT tabid into @related_tabid from ld_tab where name='ContactRecords';
UPDATE ld_quickactions set sequence=8 where tabid=@tabid and related_tabid=@related_tabid;
delimiter;
select tabid into @tabid from ld_tab where name = 'SalesOrder';
SELECT tabid into @related_tabid from ld_tab where name='Reminds';
UPDATE ld_quickactions set sequence=9 where tabid=@tabid and related_tabid=@related_tabid;
delimiter;
select tabid into @tabid from ld_tab where name = 'SalesOrder';
SELECT tabid into @related_tabid from ld_tab where name='Project';
UPDATE ld_quickactions set sequence=10 where tabid=@tabid and related_tabid=@related_tabid;
delimiter;
select tabid into @tabid from ld_tab where name = 'SalesOrder';
SELECT tabid into @related_tabid from ld_tab where name='Attachment';
UPDATE ld_quickactions set sequence=11 where tabid=@tabid and related_tabid=@related_tabid;
delimiter;
select tabid into @tabid from ld_tab where name = 'SalesOrder';
SELECT tabid into @related_tabid from ld_tab where name='SalesBack';
UPDATE ld_quickactions set sequence=12 where tabid=@tabid and related_tabid=@related_tabid;
delimiter;
select tabid into @tabid from ld_tab where name = 'SalesOrder';
SELECT tabid into @related_tabid from ld_tab where name='Documents';
UPDATE ld_quickactions set sequence=13 where tabid=@tabid and related_tabid=@related_tabid;
delimiter;
select tabid into @tabid from ld_tab where name = 'SalesOrder';
UPDATE ld_quickactions set sequence=14 where tabid=@tabid and related_tabid=-5;
delimiter;
select tabid into @tabid from ld_tab where name = 'SalesOrder';
UPDATE ld_quickactions set sequence=15 where tabid=@tabid and related_tabid=-1;
delimiter;

select tabid into @tabid from ld_tab where name = 'Accounts';
select tabid into @tabid2 from ld_tab where name = 'PaymentPlan';
SELECT max(sequence) into @sequence from ld_quickactions where tabid=@tabid; 
insert into ld_quickactions(tabid,related_tabid,sequence,presence)
select @tabid,@tabid2,@sequence+1,0 from dual 
where not EXISTS(select 1 from ld_quickactions  where tabid=@tabid and related_tabid=@tabid2);
delimiter;

select tabid into @tabid from ld_tab where name = 'Accounts';
select tabid into @tabid2 from ld_tab where name = 'Expense';
SELECT max(sequence) into @sequence from ld_quickactions where tabid=@tabid; 
insert into ld_quickactions(tabid,related_tabid,sequence,presence)
select @tabid,@tabid2,@sequence+1,0 from dual 
where not EXISTS(select 1 from ld_quickactions  where tabid=@tabid and related_tabid=@tabid2);
delimiter;

select tabid into @tabid from ld_tab where name = 'Accounts';
select tabid into @tabid2 from ld_tab where name = 'Commission';
SELECT max(sequence) into @sequence from ld_quickactions where tabid=@tabid; 
insert into ld_quickactions(tabid,related_tabid,sequence,presence)
select @tabid,@tabid2,@sequence+1,0 from dual 
where not EXISTS(select 1 from ld_quickactions  where tabid=@tabid and related_tabid=@tabid2);
delimiter;

select tabid into @tabid from ld_tab where name = 'Accounts';
select tabid into @tabid2 from ld_tab where name = 'HelpDesk';
SELECT max(sequence) into @sequence from ld_quickactions where tabid=@tabid; 
insert into ld_quickactions(tabid,related_tabid,sequence,presence)
select @tabid,@tabid2,@sequence+1,0 from dual 
where not EXISTS(select 1 from ld_quickactions  where tabid=@tabid and related_tabid=@tabid2);
delimiter;

select tabid into @tabid from ld_tab where name = 'Accounts';
select tabid into @tabid2 from ld_tab where name = 'Project';
SELECT max(sequence) into @sequence from ld_quickactions where tabid=@tabid; 
insert into ld_quickactions(tabid,related_tabid,sequence,presence)
select @tabid,@tabid2,@sequence+1,0 from dual 
where not EXISTS(select 1 from ld_quickactions  where tabid=@tabid and related_tabid=@tabid2);
delimiter;

select tabid into @tabid from ld_tab where name = 'Accounts';
SELECT tabid into @related_tabid from ld_tab where name='Contacts';
UPDATE ld_quickactions set sequence=0 where tabid=@tabid and related_tabid=@related_tabid;
delimiter;
select tabid into @tabid from ld_tab where name = 'Accounts';
SELECT tabid into @related_tabid from ld_tab where name='ContactRecords';
UPDATE ld_quickactions set sequence=1 where tabid=@tabid and related_tabid=@related_tabid;
delimiter;
select tabid into @tabid from ld_tab where name = 'Accounts';
SELECT tabid into @related_tabid from ld_tab where name='Calendar';
UPDATE ld_quickactions set sequence=2 where tabid=@tabid and related_tabid=@related_tabid;
delimiter;
select tabid into @tabid from ld_tab where name = 'Accounts';
SELECT tabid into @related_tabid from ld_tab where name='Potentials';
UPDATE ld_quickactions set sequence=3 where tabid=@tabid and related_tabid=@related_tabid;
delimiter;
select tabid into @tabid from ld_tab where name = 'Accounts';
SELECT tabid into @related_tabid from ld_tab where name='Quotes';
UPDATE ld_quickactions set sequence=4 where tabid=@tabid and related_tabid=@related_tabid;
delimiter;
select tabid into @tabid from ld_tab where name = 'Accounts';
SELECT tabid into @related_tabid from ld_tab where name='SalesOrder';
UPDATE ld_quickactions set sequence=5 where tabid=@tabid and related_tabid=@related_tabid;
delimiter;
select tabid into @tabid from ld_tab where name = 'Accounts';
SELECT tabid into @related_tabid from ld_tab where name='ServiceContracts';
UPDATE ld_quickactions set sequence=6 where tabid=@tabid and related_tabid=@related_tabid;
delimiter;
select tabid into @tabid from ld_tab where name = 'Accounts';
SELECT tabid into @related_tabid from ld_tab where name='Reminds';
UPDATE ld_quickactions set sequence=7 where tabid=@tabid and related_tabid=@related_tabid;
delimiter;
select tabid into @tabid from ld_tab where name = 'Accounts';
SELECT tabid into @related_tabid from ld_tab where name='Attachment';
UPDATE ld_quickactions set sequence=8 where tabid=@tabid and related_tabid=@related_tabid;
delimiter;
select tabid into @tabid from ld_tab where name = 'Accounts';
SELECT tabid into @related_tabid from ld_tab where name='MassSMS';
UPDATE ld_quickactions set sequence=9 where tabid=@tabid and related_tabid=@related_tabid;
delimiter;
select tabid into @tabid from ld_tab where name = 'Accounts';
SELECT tabid into @related_tabid from ld_tab where name='Emails';
UPDATE ld_quickactions set sequence=10 where tabid=@tabid and related_tabid=@related_tabid;
delimiter;
select tabid into @tabid from ld_tab where name = 'Accounts';
SELECT tabid into @related_tabid from ld_tab where name='Invoice';
UPDATE ld_quickactions set sequence=11 where tabid=@tabid and related_tabid=@related_tabid;
delimiter;
select tabid into @tabid from ld_tab where name = 'Accounts';
SELECT tabid into @related_tabid from ld_tab where name='PaymentPlan';
UPDATE ld_quickactions set sequence=12 where tabid=@tabid and related_tabid=@related_tabid;
delimiter;
select tabid into @tabid from ld_tab where name = 'Accounts';
SELECT tabid into @related_tabid from ld_tab where name='Expense';
UPDATE ld_quickactions set sequence=13 where tabid=@tabid and related_tabid=@related_tabid;
delimiter;
select tabid into @tabid from ld_tab where name = 'Accounts';
SELECT tabid into @related_tabid from ld_tab where name='Commission';
UPDATE ld_quickactions set sequence=14 where tabid=@tabid and related_tabid=@related_tabid;
delimiter;
select tabid into @tabid from ld_tab where name = 'Accounts';
SELECT tabid into @related_tabid from ld_tab where name='HelpDesk';
UPDATE ld_quickactions set sequence=15 where tabid=@tabid and related_tabid=@related_tabid;
delimiter;
select tabid into @tabid from ld_tab where name = 'Accounts';
SELECT tabid into @related_tabid from ld_tab where name='Project';
UPDATE ld_quickactions set sequence=16 where tabid=@tabid and related_tabid=@related_tabid;
delimiter;
select tabid into @tabid from ld_tab where name = 'Accounts';
SELECT tabid into @related_tabid from ld_tab where name='OutboundOrder';
UPDATE ld_quickactions set sequence=17 where tabid=@tabid and related_tabid=@related_tabid;
delimiter;
select tabid into @tabid from ld_tab where name = 'Accounts';
SELECT tabid into @related_tabid from ld_tab where name='CashBill';
UPDATE ld_quickactions set sequence=18 where tabid=@tabid and related_tabid=@related_tabid;
delimiter;
select tabid into @tabid from ld_tab where name = 'Accounts';
UPDATE ld_quickactions set sequence=19 where tabid=@tabid and related_tabid=-4;
delimiter;
select tabid into @tabid from ld_tab where name = 'Accounts';
UPDATE ld_quickactions set sequence=20 where tabid=@tabid and related_tabid=-1;
delimiter;

select tabid into @tabid from ld_tab where name = 'Contacts';
select tabid into @tabid2 from ld_tab where name = 'Potentials';
SELECT max(sequence) into @sequence from ld_quickactions where tabid=@tabid; 
insert into ld_quickactions(tabid,related_tabid,sequence,presence)
select @tabid,@tabid2,@sequence+1,0 from dual 
where not EXISTS(select 1 from ld_quickactions  where tabid=@tabid and related_tabid=@tabid2);
delimiter;

select tabid into @tabid from ld_tab where name = 'Contacts';
select tabid into @tabid2 from ld_tab where name = 'Quotes';
SELECT max(sequence) into @sequence from ld_quickactions where tabid=@tabid; 
insert into ld_quickactions(tabid,related_tabid,sequence,presence)
select @tabid,@tabid2,@sequence+1,0 from dual 
where not EXISTS(select 1 from ld_quickactions  where tabid=@tabid and related_tabid=@tabid2);
delimiter;

select tabid into @tabid from ld_tab where name = 'Contacts';
select tabid into @tabid2 from ld_tab where name = 'SalesOrder';
SELECT max(sequence) into @sequence from ld_quickactions where tabid=@tabid; 
insert into ld_quickactions(tabid,related_tabid,sequence,presence)
select @tabid,@tabid2,@sequence+1,0 from dual 
where not EXISTS(select 1 from ld_quickactions  where tabid=@tabid and related_tabid=@tabid2);
delimiter;

select tabid into @tabid from ld_tab where name = 'Contacts';
select tabid into @tabid2 from ld_tab where name = 'ServiceContracts';
SELECT max(sequence) into @sequence from ld_quickactions where tabid=@tabid; 
insert into ld_quickactions(tabid,related_tabid,sequence,presence)
select @tabid,@tabid2,@sequence+1,0 from dual 
where not EXISTS(select 1 from ld_quickactions  where tabid=@tabid and related_tabid=@tabid2);
delimiter;

select tabid into @tabid from ld_tab where name = 'Contacts';
select tabid into @tabid2 from ld_tab where name = 'HelpDesk';
SELECT max(sequence) into @sequence from ld_quickactions where tabid=@tabid; 
insert into ld_quickactions(tabid,related_tabid,sequence,presence)
select @tabid,@tabid2,@sequence+1,0 from dual 
where not EXISTS(select 1 from ld_quickactions  where tabid=@tabid and related_tabid=@tabid2);
delimiter;

select tabid into @tabid from ld_tab where name = 'Contacts';
select tabid into @tabid2 from ld_tab where name = 'Project';
SELECT max(sequence) into @sequence from ld_quickactions where tabid=@tabid; 
insert into ld_quickactions(tabid,related_tabid,sequence,presence)
select @tabid,@tabid2,@sequence+1,0 from dual 
where not EXISTS(select 1 from ld_quickactions  where tabid=@tabid and related_tabid=@tabid2);
delimiter;

select tabid into @tabid from ld_tab where name = 'Contacts';
select tabid into @tabid2 from ld_tab where name = 'Documents';
SELECT max(sequence) into @sequence from ld_quickactions where tabid=@tabid; 
insert into ld_quickactions(tabid,related_tabid,sequence,presence)
select @tabid,@tabid2,@sequence+1,0 from dual 
where not EXISTS(select 1 from ld_quickactions  where tabid=@tabid and related_tabid=@tabid2);
delimiter;


select tabid into @tabid from ld_tab where name = 'Contacts';
SELECT tabid into @related_tabid from ld_tab where name='ContactRecords';
UPDATE ld_quickactions set sequence=0 where tabid=@tabid and related_tabid=@related_tabid;
delimiter;
select tabid into @tabid from ld_tab where name = 'Contacts';
SELECT tabid into @related_tabid from ld_tab where name='Potentials';
UPDATE ld_quickactions set sequence=1 where tabid=@tabid and related_tabid=@related_tabid;
delimiter;
select tabid into @tabid from ld_tab where name = 'Contacts';
SELECT tabid into @related_tabid from ld_tab where name='Quotes';
UPDATE ld_quickactions set sequence=2 where tabid=@tabid and related_tabid=@related_tabid;
delimiter;
select tabid into @tabid from ld_tab where name = 'Contacts';
SELECT tabid into @related_tabid from ld_tab where name='SalesOrder';
UPDATE ld_quickactions set sequence=3 where tabid=@tabid and related_tabid=@related_tabid;
delimiter;
select tabid into @tabid from ld_tab where name = 'Contacts';
SELECT tabid into @related_tabid from ld_tab where name='ServiceContracts';
UPDATE ld_quickactions set sequence=4 where tabid=@tabid and related_tabid=@related_tabid;
delimiter;
select tabid into @tabid from ld_tab where name = 'Contacts';
SELECT tabid into @related_tabid from ld_tab where name='Calendar';
UPDATE ld_quickactions set sequence=5 where tabid=@tabid and related_tabid=@related_tabid;
delimiter;
select tabid into @tabid from ld_tab where name = 'Contacts';
SELECT tabid into @related_tabid from ld_tab where name='Reminds';
UPDATE ld_quickactions set sequence=6 where tabid=@tabid and related_tabid=@related_tabid;
delimiter;
select tabid into @tabid from ld_tab where name = 'Contacts';
SELECT tabid into @related_tabid from ld_tab where name='Attachment';
UPDATE ld_quickactions set sequence=7 where tabid=@tabid and related_tabid=@related_tabid;
delimiter;
select tabid into @tabid from ld_tab where name = 'Contacts';
SELECT tabid into @related_tabid from ld_tab where name='MassSMS';
UPDATE ld_quickactions set sequence=8 where tabid=@tabid and related_tabid=@related_tabid;
delimiter;
select tabid into @tabid from ld_tab where name = 'Contacts';
SELECT tabid into @related_tabid from ld_tab where name='Emails';
UPDATE ld_quickactions set sequence=9 where tabid=@tabid and related_tabid=@related_tabid;
delimiter;
select tabid into @tabid from ld_tab where name = 'Contacts';
SELECT tabid into @related_tabid from ld_tab where name='HelpDesk';
UPDATE ld_quickactions set sequence=10 where tabid=@tabid and related_tabid=@related_tabid;
delimiter;
select tabid into @tabid from ld_tab where name = 'Contacts';
SELECT tabid into @related_tabid from ld_tab where name='Project';
UPDATE ld_quickactions set sequence=11 where tabid=@tabid and related_tabid=@related_tabid;
delimiter;
select tabid into @tabid from ld_tab where name = 'Contacts';
SELECT tabid into @related_tabid from ld_tab where name='Documents';
UPDATE ld_quickactions set sequence=12 where tabid=@tabid and related_tabid=@related_tabid;
delimiter;
select tabid into @tabid from ld_tab where name = 'Contacts';
UPDATE ld_quickactions set sequence=13 where tabid=@tabid and related_tabid=-2;
delimiter;
select tabid into @tabid from ld_tab where name = 'Contacts';
UPDATE ld_quickactions set sequence=14 where tabid=@tabid and related_tabid=-3;
delimiter;
select tabid into @tabid from ld_tab where name = 'Contacts';
UPDATE ld_quickactions set sequence=15 where tabid=@tabid and related_tabid=-1;
delimiter;

select tabid into @tabid from ld_tab where name = 'ContactRecords';
SELECT tabid into @related_tabid from ld_tab where name='Reminds';
UPDATE ld_quickactions set sequence=0 where tabid=@tabid and related_tabid=@related_tabid;
delimiter;
select tabid into @tabid from ld_tab where name = 'ContactRecords';
SELECT tabid into @related_tabid from ld_tab where name='Attachment';
UPDATE ld_quickactions set sequence=1 where tabid=@tabid and related_tabid=@related_tabid;
delimiter;
select tabid into @tabid from ld_tab where name = 'ContactRecords';
UPDATE ld_quickactions set sequence=2 where tabid=@tabid and related_tabid=-1;
delimiter;
select tabid into @tabid from ld_tab where name = 'ContactRecords';
UPDATE ld_quickactions set sequence=3 where tabid=@tabid and related_tabid=-5;
delimiter;

select tabid into @tabid from ld_tab where name = 'Potentials';
select tabid into @tabid2 from ld_tab where name = 'Documents';
SELECT max(sequence) into @sequence from ld_quickactions where tabid=@tabid; 
insert into ld_quickactions(tabid,related_tabid,sequence,presence)
select @tabid,@tabid2,@sequence+1,0 from dual 
where not EXISTS(select 1 from ld_quickactions  where tabid=@tabid and related_tabid=@tabid2);
delimiter;
/*联系人*/
select tabid into @tabid from ld_tab where name = 'Potentials';
select tabid into @tabid2 from ld_tab where name = 'Contacts';
SELECT max(sequence) into @sequence from ld_quickactions where tabid=@tabid; 
insert into ld_quickactions(tabid,related_tabid,sequence,presence)
select @tabid,@tabid2,@sequence+1,0 from dual 
where not EXISTS(select 1 from ld_quickactions  where tabid=@tabid and related_tabid=@tabid2);
delimiter;

select tabid into @tabid from ld_tab where name = 'Potentials';
select tabid into @tabid2 from ld_tab where name = 'Project';
SELECT max(sequence) into @sequence from ld_quickactions where tabid=@tabid; 
insert into ld_quickactions(tabid,related_tabid,sequence,presence)
select @tabid,@tabid2,@sequence+1,0 from dual 
where not EXISTS(select 1 from ld_quickactions  where tabid=@tabid and related_tabid=@tabid2);
delimiter;

select tabid into @tabid from ld_tab where name = 'Potentials';
SELECT tabid into @related_tabid from ld_tab where name='ContactRecords';
UPDATE ld_quickactions set sequence=0 where tabid=@tabid and related_tabid=@related_tabid;
delimiter;
select tabid into @tabid from ld_tab where name = 'Potentials';
SELECT tabid into @related_tabid from ld_tab where name='Events';
UPDATE ld_quickactions set sequence=1 where tabid=@tabid and related_tabid=@related_tabid;
delimiter;
select tabid into @tabid from ld_tab where name = 'Potentials';
SELECT tabid into @related_tabid from ld_tab where name='Quotes';
UPDATE ld_quickactions set sequence=2 where tabid=@tabid and related_tabid=@related_tabid;
delimiter;
select tabid into @tabid from ld_tab where name = 'Potentials';
SELECT tabid into @related_tabid from ld_tab where name='SalesOrder';
UPDATE ld_quickactions set sequence=3 where tabid=@tabid and related_tabid=@related_tabid;
delimiter;
select tabid into @tabid from ld_tab where name = 'Potentials';
SELECT tabid into @related_tabid from ld_tab where name='Reminds';
UPDATE ld_quickactions set sequence=4 where tabid=@tabid and related_tabid=@related_tabid;
delimiter;
select tabid into @tabid from ld_tab where name = 'Potentials';
SELECT tabid into @related_tabid from ld_tab where name='Attachment';
UPDATE ld_quickactions set sequence=5 where tabid=@tabid and related_tabid=@related_tabid;
delimiter;
select tabid into @tabid from ld_tab where name = 'Potentials';
SELECT tabid into @related_tabid from ld_tab where name='Documents';
UPDATE ld_quickactions set sequence=6 where tabid=@tabid and related_tabid=@related_tabid;
delimiter;
select tabid into @tabid from ld_tab where name = 'Potentials';
SELECT tabid into @related_tabid from ld_tab where name='Contacts';
UPDATE ld_quickactions set sequence=7 where tabid=@tabid and related_tabid=@related_tabid;
delimiter;
select tabid into @tabid from ld_tab where name = 'Potentials';
SELECT tabid into @related_tabid from ld_tab where name='Project';
UPDATE ld_quickactions set sequence=8 where tabid=@tabid and related_tabid=@related_tabid;
delimiter;
select tabid into @tabid from ld_tab where name = 'Potentials';
SELECT tabid into @related_tabid from ld_tab where name='Invoice';
UPDATE ld_quickactions set sequence=9 where tabid=@tabid and related_tabid=@related_tabid;
delimiter;
select tabid into @tabid from ld_tab where name = 'Potentials';
UPDATE ld_quickactions set sequence=10 where tabid=@tabid and related_tabid=-1;
delimiter;
select tabid into @tabid from ld_tab where name = 'Potentials';
UPDATE ld_quickactions set sequence=11 where tabid=@tabid and related_tabid=-5;
delimiter;

select tabid into @tabid from ld_tab where name = 'Quotes';
select tabid into @tabid2 from ld_tab where name = 'Documents';
SELECT max(sequence) into @sequence from ld_quickactions where tabid=@tabid; 
insert into ld_quickactions(tabid,related_tabid,sequence,presence)
select @tabid,@tabid2,@sequence+1,0 from dual 
where not EXISTS(select 1 from ld_quickactions  where tabid=@tabid and related_tabid=@tabid2);
delimiter;

select tabid into @tabid from ld_tab where name = 'Quotes';
SELECT tabid into @related_tabid from ld_tab where name='SalesOrder';
UPDATE ld_quickactions set sequence=0 where tabid=@tabid and related_tabid=@related_tabid;
delimiter;
select tabid into @tabid from ld_tab where name = 'Quotes';
SELECT tabid into @related_tabid from ld_tab where name='Invoice';
UPDATE ld_quickactions set sequence=1 where tabid=@tabid and related_tabid=@related_tabid;
delimiter;
select tabid into @tabid from ld_tab where name = 'Quotes';
SELECT tabid into @related_tabid from ld_tab where name='Attachment';
UPDATE ld_quickactions set sequence=2 where tabid=@tabid and related_tabid=@related_tabid;
delimiter;
select tabid into @tabid from ld_tab where name = 'Quotes';
UPDATE ld_quickactions set sequence=3 where tabid=@tabid and related_tabid=-1;
delimiter;
select tabid into @tabid from ld_tab where name = 'Quotes';
UPDATE ld_quickactions set sequence=4 where tabid=@tabid and related_tabid=-5;
delimiter;

select tabid into @tabid from ld_tab where name = 'PurchaseOrder';
select tabid into @tabid2 from ld_tab where name = 'Documents';
SELECT max(sequence) into @sequence from ld_quickactions where tabid=@tabid; 
insert into ld_quickactions(tabid,related_tabid,sequence,presence)
select @tabid,@tabid2,@sequence+1,0 from dual 
where not EXISTS(select 1 from ld_quickactions  where tabid=@tabid and related_tabid=@tabid2);
delimiter;

select tabid into @tabid from ld_tab where name = 'PurchaseOrder';
select tabid into @tabid2 from ld_tab where name = 'SendPayment';
SELECT max(sequence) into @sequence from ld_quickactions where tabid=@tabid; 
insert into ld_quickactions(tabid,related_tabid,sequence,presence)
select @tabid,@tabid2,@sequence+1,0 from dual 
where not EXISTS(select 1 from ld_quickactions  where tabid=@tabid and related_tabid=@tabid2);
delimiter;

select tabid into @tabid from ld_tab where name = 'PurchaseOrder';
select tabid into @tabid2 from ld_tab where name = 'VendorContactRecords';
SELECT max(sequence) into @sequence from ld_quickactions where tabid=@tabid; 
insert into ld_quickactions(tabid,related_tabid,sequence,presence)
select @tabid,@tabid2,@sequence+1,0 from dual 
where not EXISTS(select 1 from ld_quickactions  where tabid=@tabid and related_tabid=@tabid2);
delimiter;

select tabid into @tabid from ld_tab where name = 'PurchaseOrder';
SELECT tabid into @related_tabid from ld_tab where name='Stock';
UPDATE ld_quickactions set sequence=0 where tabid=@tabid and related_tabid=@related_tabid;
delimiter;
select tabid into @tabid from ld_tab where name = 'PurchaseOrder';
SELECT tabid into @related_tabid from ld_tab where name='SendCashBill';
UPDATE ld_quickactions set sequence=1 where tabid=@tabid and related_tabid=@related_tabid;
delimiter;
select tabid into @tabid from ld_tab where name = 'PurchaseOrder';
SELECT tabid into @related_tabid from ld_tab where name='Attachment';
UPDATE ld_quickactions set sequence=2 where tabid=@tabid and related_tabid=@related_tabid;
delimiter;
select tabid into @tabid from ld_tab where name = 'PurchaseOrder';
SELECT tabid into @related_tabid from ld_tab where name='PurchaseBack';
UPDATE ld_quickactions set sequence=3 where tabid=@tabid and related_tabid=@related_tabid;
delimiter;
select tabid into @tabid from ld_tab where name = 'PurchaseOrder';
SELECT tabid into @related_tabid from ld_tab where name='Documents';
UPDATE ld_quickactions set sequence=4 where tabid=@tabid and related_tabid=@related_tabid;
delimiter;
select tabid into @tabid from ld_tab where name = 'PurchaseOrder';
SELECT tabid into @related_tabid from ld_tab where name='SendPayment';
UPDATE ld_quickactions set sequence=5 where tabid=@tabid and related_tabid=@related_tabid;
delimiter;
select tabid into @tabid from ld_tab where name = 'PurchaseOrder';
SELECT tabid into @related_tabid from ld_tab where name='VendorContactRecords';
UPDATE ld_quickactions set sequence=6 where tabid=@tabid and related_tabid=@related_tabid;
delimiter;
select tabid into @tabid from ld_tab where name = 'PurchaseOrder';
SELECT tabid into @related_tabid from ld_tab where name='PurchaseInvoice';
UPDATE ld_quickactions set sequence=7 where tabid=@tabid and related_tabid=@related_tabid;
delimiter;
select tabid into @tabid from ld_tab where name = 'PurchaseOrder';
UPDATE ld_quickactions set sequence=8 where tabid=@tabid and related_tabid=-1;
delimiter;
select tabid into @tabid from ld_tab where name = 'PurchaseOrder';
UPDATE ld_quickactions set sequence=9 where tabid=@tabid and related_tabid=-5;
delimiter;

select tabid into @tabid from ld_tab where name = 'Vendors';
select tabid into @tabid2 from ld_tab where name = 'SendPayment';
SELECT max(sequence) into @sequence from ld_quickactions where tabid=@tabid; 
insert into ld_quickactions(tabid,related_tabid,sequence,presence)
select @tabid,@tabid2,@sequence+1,0 from dual 
where not EXISTS(select 1 from ld_quickactions  where tabid=@tabid and related_tabid=@tabid2);
delimiter;

select tabid into @tabid from ld_tab where name = 'Vendors';
select tabid into @tabid2 from ld_tab where name = 'SendCashBill';
SELECT max(sequence) into @sequence from ld_quickactions where tabid=@tabid; 
insert into ld_quickactions(tabid,related_tabid,sequence,presence)
select @tabid,@tabid2,@sequence+1,0 from dual 
where not EXISTS(select 1 from ld_quickactions  where tabid=@tabid and related_tabid=@tabid2);
delimiter;

select tabid into @tabid from ld_tab where name = 'Vendors';
select tabid into @tabid2 from ld_tab where name = 'Stock';
SELECT max(sequence) into @sequence from ld_quickactions where tabid=@tabid; 
insert into ld_quickactions(tabid,related_tabid,sequence,presence)
select @tabid,@tabid2,@sequence+1,0 from dual 
where not EXISTS(select 1 from ld_quickactions  where tabid=@tabid and related_tabid=@tabid2);
delimiter;

select tabid into @tabid from ld_tab where name = 'Vendors';
select tabid into @tabid2 from ld_tab where name = 'Emails';
SELECT max(sequence) into @sequence from ld_quickactions where tabid=@tabid; 
insert into ld_quickactions(tabid,related_tabid,sequence,presence)
select @tabid,@tabid2,@sequence+1,0 from dual 
where not EXISTS(select 1 from ld_quickactions  where tabid=@tabid and related_tabid=@tabid2);
delimiter;

select tabid into @tabid from ld_tab where name = 'Vendors';
select tabid into @tabid2 from ld_tab where name = 'Expense';
SELECT max(sequence) into @sequence from ld_quickactions where tabid=@tabid; 
insert into ld_quickactions(tabid,related_tabid,sequence,presence)
select @tabid,@tabid2,@sequence+1,0 from dual 
where not EXISTS(select 1 from ld_quickactions  where tabid=@tabid and related_tabid=@tabid2);
delimiter;

select tabid into @tabid from ld_tab where name = 'Vendors';
SELECT tabid into @related_tabid from ld_tab where name='VendorContact';
UPDATE ld_quickactions set sequence=0 where tabid=@tabid and related_tabid=@related_tabid;
delimiter;
select tabid into @tabid from ld_tab where name = 'Vendors';
SELECT tabid into @related_tabid from ld_tab where name='PurchaseOrder';
UPDATE ld_quickactions set sequence=1 where tabid=@tabid and related_tabid=@related_tabid;
delimiter;
select tabid into @tabid from ld_tab where name = 'Vendors';
SELECT tabid into @related_tabid from ld_tab where name='VendorContactRecords';
UPDATE ld_quickactions set sequence=2 where tabid=@tabid and related_tabid=@related_tabid;
delimiter;
select tabid into @tabid from ld_tab where name = 'Vendors';
SELECT tabid into @related_tabid from ld_tab where name='Reminds';
UPDATE ld_quickactions set sequence=3 where tabid=@tabid and related_tabid=@related_tabid;
delimiter;
select tabid into @tabid from ld_tab where name = 'Vendors';
SELECT tabid into @related_tabid from ld_tab where name='Attachment';
UPDATE ld_quickactions set sequence=4 where tabid=@tabid and related_tabid=@related_tabid;
delimiter;
select tabid into @tabid from ld_tab where name = 'Vendors';
SELECT tabid into @related_tabid from ld_tab where name='SendPayment';
UPDATE ld_quickactions set sequence=5 where tabid=@tabid and related_tabid=@related_tabid;
delimiter;
select tabid into @tabid from ld_tab where name = 'Vendors';
SELECT tabid into @related_tabid from ld_tab where name='SendCashBill';
UPDATE ld_quickactions set sequence=6 where tabid=@tabid and related_tabid=@related_tabid;
delimiter;
select tabid into @tabid from ld_tab where name = 'Vendors';
SELECT tabid into @related_tabid from ld_tab where name='Stock';
UPDATE ld_quickactions set sequence=7 where tabid=@tabid and related_tabid=@related_tabid;
delimiter;
select tabid into @tabid from ld_tab where name = 'Vendors';
SELECT tabid into @related_tabid from ld_tab where name='Emails';
UPDATE ld_quickactions set sequence=8 where tabid=@tabid and related_tabid=@related_tabid;
delimiter;
select tabid into @tabid from ld_tab where name = 'Vendors';
SELECT tabid into @related_tabid from ld_tab where name='Expense';
UPDATE ld_quickactions set sequence=9 where tabid=@tabid and related_tabid=@related_tabid;
delimiter;
select tabid into @tabid from ld_tab where name = 'Vendors';
SELECT tabid into @related_tabid from ld_tab where name='PurchaseInvoice';
UPDATE ld_quickactions set sequence=10 where tabid=@tabid and related_tabid=@related_tabid;
delimiter;
select tabid into @tabid from ld_tab where name = 'Vendors';
UPDATE ld_quickactions set sequence=11 where tabid=@tabid and related_tabid=-1;
delimiter;
select tabid into @tabid from ld_tab where name = 'Vendors';
UPDATE ld_quickactions set sequence=12 where tabid=@tabid and related_tabid=-5;
delimiter;

select tabid into @tabid from ld_tab where name = 'ServiceContracts';
select tabid into @tabid2 from ld_tab where name = 'Documents';
SELECT max(sequence) into @sequence from ld_quickactions where tabid=@tabid; 
insert into ld_quickactions(tabid,related_tabid,sequence,presence)
select @tabid,@tabid2,@sequence+1,0 from dual 
where not EXISTS(select 1 from ld_quickactions  where tabid=@tabid and related_tabid=@tabid2);
delimiter;

select tabid into @tabid from ld_tab where name = 'ServiceContracts';
SELECT tabid into @related_tabid from ld_tab where name='CashBill';
UPDATE ld_quickactions set sequence=0 where tabid=@tabid and related_tabid=@related_tabid;
delimiter;
select tabid into @tabid from ld_tab where name = 'ServiceContracts';
SELECT tabid into @related_tabid from ld_tab where name='HelpDesk';
UPDATE ld_quickactions set sequence=1 where tabid=@tabid and related_tabid=@related_tabid;
delimiter;
select tabid into @tabid from ld_tab where name = 'ServiceContracts';
SELECT tabid into @related_tabid from ld_tab where name='Invoice';
UPDATE ld_quickactions set sequence=2 where tabid=@tabid and related_tabid=@related_tabid;
delimiter;
select tabid into @tabid from ld_tab where name = 'ServiceContracts';
SELECT tabid into @related_tabid from ld_tab where name='Expense';
UPDATE ld_quickactions set sequence=3 where tabid=@tabid and related_tabid=@related_tabid;
delimiter;
select tabid into @tabid from ld_tab where name = 'ServiceContracts';
SELECT tabid into @related_tabid from ld_tab where name='Attachment';
UPDATE ld_quickactions set sequence=4 where tabid=@tabid and related_tabid=@related_tabid;
delimiter;
select tabid into @tabid from ld_tab where name = 'ServiceContracts';
UPDATE ld_quickactions set sequence=5 where tabid=@tabid and related_tabid=-1;
delimiter;
select tabid into @tabid from ld_tab where name = 'ServiceContracts';
UPDATE ld_quickactions set sequence=6 where tabid=@tabid and related_tabid=-5;
delimiter;

select tabid into @tabid from ld_tab where name = 'HelpDesk';
select tabid into @tabid2 from ld_tab where name = 'Documents';
SELECT max(sequence) into @sequence from ld_quickactions where tabid=@tabid; 
insert into ld_quickactions(tabid,related_tabid,sequence,presence)
select @tabid,@tabid2,@sequence+1,0 from dual 
where not EXISTS(select 1 from ld_quickactions  where tabid=@tabid and related_tabid=@tabid2);
delimiter;

select tabid into @tabid from ld_tab where name = 'HelpDesk';
SELECT tabid into @related_tabid from ld_tab where name='ContactRecords';
UPDATE ld_quickactions set sequence=0 where tabid=@tabid and related_tabid=@related_tabid;
delimiter;
select tabid into @tabid from ld_tab where name = 'HelpDesk';
SELECT tabid into @related_tabid from ld_tab where name='Reminds';
UPDATE ld_quickactions set sequence=1 where tabid=@tabid and related_tabid=@related_tabid;
delimiter
select tabid into @tabid from ld_tab where name = 'HelpDesk';
SELECT tabid into @related_tabid from ld_tab where name='Attachment';
UPDATE ld_quickactions set sequence=2 where tabid=@tabid and related_tabid=@related_tabid;
delimiter;
select tabid into @tabid from ld_tab where name = 'HelpDesk';
SELECT tabid into @related_tabid from ld_tab where name='Documents';
UPDATE ld_quickactions set sequence=3 where tabid=@tabid and related_tabid=@related_tabid;
delimiter;
select tabid into @tabid from ld_tab where name = 'HelpDesk';
UPDATE ld_quickactions set sequence=4 where tabid=@tabid and related_tabid=-1;
delimiter;
select tabid into @tabid from ld_tab where name = 'HelpDesk';
UPDATE ld_quickactions set sequence=5 where tabid=@tabid and related_tabid=-5;
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'zh','YOUAREMODIFYINGSYSTETBESURE','您正在修改系统配置参数，请在保存之前再检查确认一次','fixedstr' from dual 
where not EXISTS(select 1 from ld_desk  where languagetype='zh' and labelbol='YOUAREMODIFYINGSYSTETBESURE' and Labeltype='fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'en','YOUAREMODIFYINGSYSTETBESURE','You are modifying system configuration parameters, please confirm once again check before saving','fixedstr' from dual 
where not EXISTS(select 1 from ld_desk  where languagetype='en' and labelbol='YOUAREMODIFYINGSYSTETBESURE' and Labeltype='fixedstr');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'zh','SMS_templatesList','短信模板列表','fixedstr' from dual 
where not EXISTS(select 1 from ld_desk  where languagetype='zh' and labelbol='SMS_templatesList' and Labeltype='fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'en','SMS_templatesList','SMS template list','fixedstr' from dual 
where not EXISTS(select 1 from ld_desk  where languagetype='en' and labelbol='SMS_templatesList' and Labeltype='fixedstr');
delimiter;
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'zh','Email_templatesList','Email模板列表','fixedstr' from dual 
where not EXISTS(select 1 from ld_desk  where languagetype='zh' and labelbol='Email_templatesList' and Labeltype='fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'en','Email_templatesList','Email template list','fixedstr' from dual 
where not EXISTS(select 1 from ld_desk  where languagetype='en' and labelbol='Email_templatesList' and Labeltype='fixedstr');
delimiter;
delete from ld_desk where labelbol = 'SMS_templatesList' and labeltype = 'fixedstr';
delete from ld_desk where labelbol = 'Email_templatesList' and labeltype = 'fixedstr';
delimiter;

UPDATE ld_desk set fieldlabel='在目标查看页签可查看销售目标设定结果及完成情况，在目标设置页签可设定销售目标；（金额单位：元，客户数：个）' WHERE labelbol='SALESGOALINSTRUCTION5' and languagetype='zh';
delimiter;
-- 2014-09-25

DELETE FROM ld_eventhandlers WHERE event_name='vtiger.entity.beforesave.modifiable' AND handler_class='VTFieldFormulasEventHandler';
DELETE FROM ld_eventhandlers WHERE event_name='lingdang.entity.beforesave.modifiable' AND handler_class='VTFieldFormulasEventHandler';
INSERT INTO ld_eventhandlers(event_name,handler_path,handler_class,cond,is_active)
SELECT 'lingdang.entity.beforesave.modifiable','modules/FieldFormulas/VTFieldFormulasEventHandler.inc','VTFieldFormulasEventHandler','',1 FROM DUAL
WHERE NOT EXISTS(SELECT 1 FROM ld_eventhandlers WHERE event_name='lingdang.entity.beforesave.modifiable' AND handler_class='VTFieldFormulasEventHandler');
delimiter;
-- 2014-09-26

call fieldprofile('ServiceCharge'); 
call getallprofile('ServiceCharge'); 
call addtabintoprofile('ServiceCharge',0); 
select tabid into @tabid from ld_tab where `name` = 'ServiceCharge'; 
update ld_profile2standardpermissions set permissions = 1 where tabid = @tabid and profileid not in ( 
select ld_role2profile.profileid from ld_users 
inner join ld_user2role on ld_users.id = ld_user2role.userid 
inner join ld_role2profile on ld_role2profile.roleid = ld_user2role.roleid where is_admin = 'on');

DELETE FROM ld_eventhandlers WHERE event_name='vtiger.entity.beforesave.modifiable' AND handler_class='VTFieldFormulasEventHandler';
DELETE FROM ld_eventhandlers WHERE event_name='lingdang.entity.beforesave.modifiable' AND handler_class='VTFieldFormulasEventHandler';
INSERT INTO ld_eventhandlers(event_name,handler_path,handler_class,cond,is_active)
SELECT 'lingdang.entity.beforesave.modifiable','modules/FieldFormulas/VTFieldFormulasEventHandler.inc','VTFieldFormulasEventHandler','',1 FROM DUAL
WHERE NOT EXISTS(SELECT 1 FROM ld_eventhandlers WHERE event_name='lingdang.entity.beforesave.modifiable' AND handler_class='VTFieldFormulasEventHandler');
delimiter;

update ld_customview set `status` = 3 where viewname = '无服务' and entitytype = 'ServiceCharge';
update ld_customview set `status` = 3 where viewname = '已过期' and entitytype = 'ServiceCharge';
update ld_customview set `status` = 3 where viewname = '过期未超60天' and entitytype = 'ServiceCharge';
update ld_customview set `status` = 3 where viewname = '过期未超30天' and entitytype = 'ServiceCharge';
update ld_customview set `status` = 3 where viewname = '即将到期60天' and entitytype = 'ServiceCharge';
update ld_customview set `status` = 3 where viewname = '即将到期30天' and entitytype = 'ServiceCharge';
delimiter;

UPDATE ld_desk set fieldlabel='下属' WHERE labelbol='Myteam' and languagetype='zh' and Labeltype='fixedstr';
UPDATE ld_desk set fieldlabel='Subordinates' WHERE labelbol='Myteam' and languagetype='en' and Labeltype='fixedstr';
-- 2014-09-28

update ld_customview set viewname='本月预计成交' where entitytype='Potentials' and viewname='盘点';

set @cvid=0;
select cvid into @cvid from ld_customview where entitytype='Potentials' and viewname='本周创建';
delete from ld_cvstdfilter where cvid=@cvid;
insert into ld_cvstdfilter(cvid,columnname,stdfilter,startdate,enddate)
select @cvid,'LD_potential:createdtime:createdtime:Potentials_fieldlabel','thisweek','2014-09-28','2014-10-04' from dual 
where exists (select 1 from ld_customview where cvid=@cvid);
delimiter;

set @cvid=0;
select cvid into @cvid from ld_customview where entitytype='Potentials' and viewname='本月创建';
delete from ld_cvstdfilter where cvid=@cvid;
insert into ld_cvstdfilter(cvid,columnname,stdfilter,startdate,enddate)
select @cvid,'LD_potential:createdtime:createdtime:Potentials_fieldlabel','thismonth','2014-09-01','2014-09-30' from dual 
where exists (select 1 from ld_customview where cvid=@cvid);
delimiter;


set @cvid=0;
select cvid into @cvid from ld_customview where entitytype='Quotes' and viewname='今日创建';
delete from ld_cvstdfilter where cvid=@cvid;
insert into ld_cvstdfilter(cvid,columnname,stdfilter,startdate,enddate)
select @cvid,'LD_quotes:createdtime:createdtime:Quotes_fieldlabel','today','2014-09-29','2014-09-29' from dual 
where exists (select 1 from ld_customview where cvid=@cvid);
delimiter;

set @cvid=0;
select cvid into @cvid from ld_customview where entitytype='Quotes' and viewname='本周创建';
delete from ld_cvstdfilter where cvid=@cvid;
insert into ld_cvstdfilter(cvid,columnname,stdfilter,startdate,enddate)
select @cvid,'LD_quotes:createdtime:createdtime:Quotes_fieldlabel','thisweek','2014-09-28','2014-10-04' from dual
where exists (select 1 from ld_customview where cvid=@cvid);
delimiter;

set @cvid=0;
select cvid into @cvid from ld_customview where entitytype='Quotes' and viewname='本月创建';
delete from ld_cvstdfilter where cvid=@cvid;
insert into ld_cvstdfilter(cvid,columnname,stdfilter,startdate,enddate)
select @cvid,'LD_quotes:createdtime:createdtime:Quotes_fieldlabel','thismonth','2014-09-01','2014-09-30' from dual 
where exists (select 1 from ld_customview where cvid=@cvid);
delimiter;

set @cvid=0;
select cvid into @cvid from ld_customview where entitytype='SalesOrder' and viewname='本月交付';
delete from ld_cvstdfilter where cvid=@cvid;
insert into ld_cvstdfilter(cvid,columnname,stdfilter,startdate,enddate)
select @cvid,'LD_salesorder:duedate:duedate:SalesOrder_fieldlabel','thismonth','2014-09-01','2014-09-30' from dual 
where exists (select 1 from ld_customview where cvid=@cvid);
delimiter;

set @cvid=0;
select cvid into @cvid from ld_customview where entitytype='SalesOrder' and viewname='本月创建';
delete from ld_cvstdfilter where cvid=@cvid;
insert into ld_cvstdfilter(cvid,columnname,stdfilter,startdate,enddate)
select @cvid,'LD_salesorder:duedate:duedate:SalesOrder_fieldlabel','thismonth','2014-09-01','2014-09-30' from dual 
where exists (select 1 from ld_customview where cvid=@cvid);
delimiter;

set @cvid=0;
select cvid into @cvid from ld_customview where entitytype='SalesOrder' and viewname='待采购';
delete from ld_cvstdfilter where cvid=@cvid;
delete from ld_cvadvfilter_grouping where cvid=@cvid;
delete from ld_cvadvfilter where cvid=@cvid;

insert into ld_cvadvfilter(cvid,columnindex,columnname,comparator,`value`,groupid,column_condition)
select @cvid,0,'LD_inventoryproductrel:balancepurchasecount:balancepurchasecount:Products_fieldlabel:N','g','0',1,'or' from dual 
where exists (select 1 from ld_customview where cvid=@cvid);

insert into ld_cvadvfilter(cvid,columnindex,columnname,comparator,`value`,groupid,column_condition)
select @cvid,1,'LD_salesorder:sostatus:sostatus:SalesOrder_fieldlabel:V','n','已作废',1,NULL from dual 
where exists (select 1 from ld_customview where cvid=@cvid);

insert into ld_cvadvfilter_grouping(groupid,cvid,group_condition,condition_expression)
select 1,@cvid,NULL,'0 or 1' from dual 
where exists (select 1 from ld_customview where cvid=@cvid);


select tabid into @tabid from ld_tab where name='SalesOrder';
delete from ld_tabwithproductview where cvid=@cvid and tabid=22;
insert into ld_tabwithproductview(tabid,`columns`,sequence,cvid)
select @tabid,'LD_salesorder:salesorder_no:salesorder_no:SalesOrder_fieldlabel:V',0,@cvid from dual 
where exists (select 1 from ld_customview where cvid=@cvid);

insert into ld_tabwithproductview(tabid,`columns`,sequence,cvid)
select @tabid,'LD_salesorder:subject:subject:SalesOrder_fieldlabel:V',1,@cvid from dual 
where exists (select 1 from ld_customview where cvid=@cvid);

insert into ld_tabwithproductview(tabid,`columns`,sequence,cvid)
select @tabid,'LD_salesorder:accountid:account_id:SalesOrder_fieldlabel:I',2,@cvid from dual 
where exists (select 1 from ld_customview where cvid=@cvid);

insert into ld_tabwithproductview(tabid,`columns`,sequence,cvid)
select @tabid,'LD_salesorder:contactid:contact_id:SalesOrder_fieldlabel:I',3,@cvid from dual 
where exists (select 1 from ld_customview where cvid=@cvid);

insert into ld_tabwithproductview(tabid,`columns`,sequence,cvid)
select @tabid,'LD_salesorder:signed_data:signed_data:SalesOrder_fieldlabel:D',4,@cvid from dual 
where exists (select 1 from ld_customview where cvid=@cvid);

insert into ld_tabwithproductview(tabid,`columns`,sequence,cvid)
select @tabid,'LD_salesorder:total:hdnGrandTotal:SalesOrder_fieldlabel:N',5,@cvid from dual 
where exists (select 1 from ld_customview where cvid=@cvid);

insert into ld_tabwithproductview(tabid,`columns`,sequence,cvid)
select @tabid,'LD_salesorder:sostatus:sostatus:SalesOrder_fieldlabel:V',6,@cvid from dual 
where exists (select 1 from ld_customview where cvid=@cvid);

insert into ld_tabwithproductview(tabid,`columns`,sequence,cvid)
select @tabid,'LD_salesorder:smownerid:assigned_user_id:SalesOrder_fieldlabel:V',7,@cvid from dual 
where exists (select 1 from ld_customview where cvid=@cvid);

insert into ld_tabwithproductview(tabid,`columns`,sequence,cvid)
select @tabid,'LD_products:productname:productname:Products_fieldlabel:V',8,@cvid from dual 
where exists (select 1 from ld_customview where cvid=@cvid);

insert into ld_tabwithproductview(tabid,`columns`,sequence,cvid)
select @tabid,'LD_inventoryproductrel:quantity:quantity:Products_fieldlabel:N',9,@cvid from dual 
where exists (select 1 from ld_customview where cvid=@cvid);

insert into ld_tabwithproductview(tabid,`columns`,sequence,cvid)
select @tabid,'LD_inventoryproductrel:balancepurchasecount:balancepurchasecount:Products_fieldlabel:N',10,@cvid from dual 
where exists (select 1 from ld_customview where cvid=@cvid);

insert into ld_tabwithproductview(tabid,`columns`,sequence,cvid)
select @tabid,'LD_inventoryproductrel:havepurchasecount:havepurchasecount:Products_fieldlabel:N',11,@cvid from dual 
where exists (select 1 from ld_customview where cvid=@cvid);
delimiter;

set @cvid=0;
select cvid into @cvid from ld_customview where entitytype='SalesOrder' and viewname='已采购';
delete from ld_cvstdfilter where cvid=@cvid;
delete from ld_cvadvfilter_grouping where cvid=@cvid;
delete from ld_cvadvfilter where cvid=@cvid;

insert into ld_cvadvfilter(cvid,columnindex,columnname,comparator,`value`,groupid,column_condition)
select @cvid,0,'LD_inventoryproductrel:balancepurchasecount:balancepurchasecount:Products_fieldlabel:N','m','0',1,'and' from dual 
where exists (select 1 from ld_customview where cvid=@cvid);

insert into ld_cvadvfilter(cvid,columnindex,columnname,comparator,`value`,groupid,column_condition)
select @cvid,1,'LD_salesorder:sostatus:sostatus:SalesOrder_fieldlabel:V','n','已作废',1,NULL from dual 
where exists (select 1 from ld_customview where cvid=@cvid);

insert into ld_cvadvfilter_grouping(groupid,cvid,group_condition,condition_expression)
select 1,@cvid,NULL,'0 or 1' from dual 
where exists (select 1 from ld_customview where cvid=@cvid);


select tabid into @tabid from ld_tab where name='SalesOrder';
delete from ld_tabwithproductview where cvid=@cvid and tabid=22;
insert into ld_tabwithproductview(tabid,`columns`,sequence,cvid)
select @tabid,'LD_salesorder:salesorder_no:salesorder_no:SalesOrder_fieldlabel:V',0,@cvid from dual 
where exists (select 1 from ld_customview where cvid=@cvid);

insert into ld_tabwithproductview(tabid,`columns`,sequence,cvid)
select @tabid,'LD_salesorder:subject:subject:SalesOrder_fieldlabel:V',1,@cvid from dual 
where exists (select 1 from ld_customview where cvid=@cvid);

insert into ld_tabwithproductview(tabid,`columns`,sequence,cvid)
select @tabid,'LD_salesorder:accountid:account_id:SalesOrder_fieldlabel:I',2,@cvid from dual 
where exists (select 1 from ld_customview where cvid=@cvid);

insert into ld_tabwithproductview(tabid,`columns`,sequence,cvid)
select @tabid,'LD_salesorder:contactid:contact_id:SalesOrder_fieldlabel:I',3,@cvid from dual 
where exists (select 1 from ld_customview where cvid=@cvid);

insert into ld_tabwithproductview(tabid,`columns`,sequence,cvid)
select @tabid,'LD_salesorder:signed_data:signed_data:SalesOrder_fieldlabel:D',4,@cvid from dual 
where exists (select 1 from ld_customview where cvid=@cvid);

insert into ld_tabwithproductview(tabid,`columns`,sequence,cvid)
select @tabid,'LD_salesorder:total:hdnGrandTotal:SalesOrder_fieldlabel:N',5,@cvid from dual 
where exists (select 1 from ld_customview where cvid=@cvid);

insert into ld_tabwithproductview(tabid,`columns`,sequence,cvid)
select @tabid,'LD_salesorder:sostatus:sostatus:SalesOrder_fieldlabel:V',6,@cvid from dual 
where exists (select 1 from ld_customview where cvid=@cvid);

insert into ld_tabwithproductview(tabid,`columns`,sequence,cvid)
select @tabid,'LD_salesorder:smownerid:assigned_user_id:SalesOrder_fieldlabel:V',7,@cvid from dual 
where exists (select 1 from ld_customview where cvid=@cvid);

insert into ld_tabwithproductview(tabid,`columns`,sequence,cvid)
select @tabid,'LD_products:productname:productname:Products_fieldlabel:V',8,@cvid from dual 
where exists (select 1 from ld_customview where cvid=@cvid);

insert into ld_tabwithproductview(tabid,`columns`,sequence,cvid)
select @tabid,'LD_inventoryproductrel:quantity:quantity:Products_fieldlabel:N',9,@cvid from dual 
where exists (select 1 from ld_customview where cvid=@cvid);

insert into ld_tabwithproductview(tabid,`columns`,sequence,cvid)
select @tabid,'LD_inventoryproductrel:balancepurchasecount:balancepurchasecount:Products_fieldlabel:N',10,@cvid from dual 
where exists (select 1 from ld_customview where cvid=@cvid);

insert into ld_tabwithproductview(tabid,`columns`,sequence,cvid)
select @tabid,'LD_inventoryproductrel:havepurchasecount:havepurchasecount:Products_fieldlabel:N',11,@cvid from dual 
where exists (select 1 from ld_customview where cvid=@cvid);
delimiter;

set @cvid=0;
select cvid into @cvid from ld_customview where entitytype='PurchaseInvoice' and viewname='本周创建';
delete from ld_cvstdfilter where cvid=@cvid;
insert into ld_cvstdfilter(cvid,columnname,stdfilter,startdate,enddate)
select @cvid,'LD_purchaseinvoice:createdtime:createdtime:PurchaseInvoice_fieldlabel','thisweek','2014-09-28','2014-10-04' from dual 
where exists (select 1 from ld_customview where cvid=@cvid);
delimiter;


set @cvid=0;
select cvid into @cvid from ld_customview where entitytype='PurchaseInvoice' and viewname='本月创建';
delete from ld_cvstdfilter where cvid=@cvid;
insert into ld_cvstdfilter(cvid,columnname,stdfilter,startdate,enddate)
select @cvid,'LD_purchaseinvoice:createdtime:createdtime:PurchaseInvoice_fieldlabel','thismonth','2014-09-01','2014-09-30' from dual
where exists (select 1 from ld_customview where cvid=@cvid);
delimiter;

set @cvid=0;
select cvid into @cvid from ld_customview where entitytype='CashBill' and viewname='无需发票';
delete from ld_cvstdfilter where cvid=@cvid;
delete from ld_cvadvfilter_grouping where cvid=@cvid;
delete from ld_cvadvfilter where cvid=@cvid;
delete from ld_cvadvfilter_grouping where cvid=@cvid;
delete from ld_customview where cvid=@cvid;

set @cvid=0;
select cvid into @cvid from ld_customview where entitytype='InventoryAccount' and viewname='出库';
delete from ld_cvstdfilter where cvid=@cvid;
delete from ld_cvadvfilter_grouping where cvid=@cvid;
delete from ld_cvadvfilter where cvid=@cvid;

insert into ld_cvadvfilter(cvid,columnindex,columnname,comparator,`value`,groupid,column_condition)
select @cvid,0,'LD_warehousecondtions:type:type:InventoryAccount_fieldlabel:V','e','出库',1,NULL from dual 
where exists (select 1 from ld_customview where cvid=@cvid);

insert into ld_cvadvfilter_grouping(groupid,cvid,group_condition,condition_expression)
select 1,@cvid,NULL,'0' from dual 
where exists (select 1 from ld_customview where cvid=@cvid);
delimiter;

set @cvid=0;
select cvid into @cvid from ld_customview where entitytype='InventoryAccount' and viewname='调拨';
delete from ld_cvstdfilter where cvid=@cvid;
delete from ld_cvadvfilter_grouping where cvid=@cvid;
delete from ld_cvadvfilter where cvid=@cvid;

insert into ld_cvadvfilter(cvid,columnindex,columnname,comparator,`value`,groupid,column_condition)
select @cvid,0,'LD_warehousecondtions:type:type:InventoryAccount_fieldlabel:V','e','调拨',1,NULL from dual 
where exists (select 1 from ld_customview where cvid=@cvid);

insert into ld_cvadvfilter_grouping(groupid,cvid,group_condition,condition_expression)
select 1,@cvid,NULL,'0' from dual 
where exists (select 1 from ld_customview where cvid=@cvid);
delimiter;

set @cvid=0;
select cvid into @cvid from ld_customview where entitytype='InventoryAccount' and viewname='盘点';
delete from ld_cvstdfilter where cvid=@cvid;
delete from ld_cvadvfilter_grouping where cvid=@cvid;
delete from ld_cvadvfilter where cvid=@cvid;

insert into ld_cvadvfilter(cvid,columnindex,columnname,comparator,`value`,groupid,column_condition)
select @cvid,0,'LD_warehousecondtions:type:type:InventoryAccount_fieldlabel:V','e','盘点',1,NULL from dual 
where exists (select 1 from ld_customview where cvid=@cvid);

insert into ld_cvadvfilter_grouping(groupid,cvid,group_condition,condition_expression)
select 1,@cvid,NULL,'0' from dual 
where exists (select 1 from ld_customview where cvid=@cvid);
delimiter;


update ld_desk set fieldlabel='重算其他币种价格'  where labelbol='RPrice' and Labeltype='fixedstr' and languagetype='zh';
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','RePrice','重算价格','fixedstr' from dual 
where not EXISTS(select 1 from ld_desk where languagetype='zh' and labelbol='RePrice' and Labeltype='fixedstr');

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','RePriceRePrice','Recalculate','fixedstr' from dual 
where not EXISTS(select 1 from ld_desk where languagetype='en' and labelbol='RePrice' and Labeltype='fixedstr');
delimiter;

SELECT usereportid INTO @repid FROM ld_usereport WHERE name='Performancestatisticscollection';
UPDATE ld_usereportcolumns SET realcolumns='LD_salesordercost:productgp:productgp:OftenUseReport_收款毛利:N' WHERE Usereportid=@repid AND columns LIKE '%LD_salesordercost:productgp:productgp:OftenUseReport%' 
AND realcolumns LIKE '%LD_salesordercost:productgp:productgp:OftenUseReport_%';
delimiter;

UPDATE ld_desk set fieldlabel='我下属的' WHERE labelbol='Myteam' and languagetype='zh' and Labeltype='fixedstr';
UPDATE ld_desk set fieldlabel='My subordinates' WHERE labelbol='Myteam' and languagetype='en' and Labeltype='fixedstr';
delimiter;
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'zh','SUBORDINATES','下属','fixedstr' from dual 
where not EXISTS(select 1 from ld_desk  where languagetype='zh' and labelbol='SUBORDINATES' and Labeltype='fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'en','SUBORDINATES','Subordinates','fixedstr' from dual 
where not EXISTS(select 1 from ld_desk  where languagetype='en' and labelbol='SUBORDINATES' and Labeltype='fixedstr');
delimiter;
UPDATE ld_desk set fieldlabel='群发前，请先到控制面板中设置邮件服务器' WHERE labelbol='Before_sending_please_go_to_SMTP' and languagetype='zh' and Labeltype='fixedstr';
UPDATE ld_desk set fieldlabel='Mass before, please go to the control panel to set the mail server' WHERE labelbol='Before_sending_please_go_to_SMTP' and languagetype='en' and Labeltype='fixedstr';
delimiter;
UPDATE ld_desk set fieldlabel='群发邮件，以换行符间隔' WHERE labelbol='Bulk_mail_newline_interval_such_as' and languagetype='zh' and Labeltype='fixedstr';
UPDATE ld_desk set fieldlabel='Mass mail,using newline to interval' WHERE labelbol='Bulk_mail_newline_interval_such_as' and languagetype='en' and Labeltype='fixedstr';
delimiter;
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'zh','FOREXAMPLE','例如：','fixedstr' from dual 
where not EXISTS(select 1 from ld_desk  where languagetype='zh' and labelbol='FOREXAMPLE' and Labeltype='fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'en','FOREXAMPLE','For example:','fixedstr' from dual 
where not EXISTS(select 1 from ld_desk  where languagetype='en' and labelbol='FOREXAMPLE' and Labeltype='fixedstr');
delimiter;
-- 2014-09-29

update ld_usereportcolumns set `columns`='LD_contactdetails:pphone:pphone:contactdetails_pphone:V' where `columns` like 'LD_contactdetails:pphone:pphone:contactdetails_pphone%';
update ld_usereportcolumns set `columns`='LD_contactdetails:mobile:mobile:contactdetails_mobile:V' where `columns` like 'LD_contactdetails:mobile:mobile:contactdetails_mobile%';
update ld_usereportcolumns set `realcolumns`='LD_contactdetails:pphone:pphone:contactdetails_办公电话:V' where `columns` like 'LD_contactdetails:pphone:pphone:contactdetails_pphone%';
update ld_usereportcolumns set `realcolumns`='LD_contactdetails:mobile:mobile:contactdetails_手机:V' where `columns` like 'LD_contactdetails:mobile:mobile:contactdetails_mobile%';
update ld_usereportcolumns set `realencolumns`='LD_contactdetails:pphone:pphone:contactdetails_办公电话:V' where `columns` like 'LD_contactdetails:pphone:pphone:contactdetails_pphone%';
update ld_usereportcolumns set `realencolumns`='LD_contactdetails:mobile:mobile:contactdetails_手机:V' where `columns` like 'LD_contactdetails:mobile:mobile:contactdetails_mobile%';

UPDATE ld_desk set fieldlabel='群组发送短信时，换行间隔每个客户' WHERE labelbol='GroupsWhensendingtextmessages' and languagetype='zh' and Labeltype='fixedstr';
UPDATE ld_desk set fieldlabel='The group sent a message, wrap interval of each customer' WHERE labelbol='GroupsWhensendingtextmessages' and languagetype='en' and Labeltype='fixedstr';
delimiter;
select tabid into @tabid from ld_tab where name = 'PurchaseBack';
SELECT max(sequence) into @sequence from ld_quickactions where tabid=@tabid; 
insert into ld_quickactions(tabid,related_tabid,sequence,presence)
select @tabid,-5,@sequence+1,0 from dual 
where not EXISTS(select 1 from ld_quickactions  where tabid=@tabid and related_tabid=-5);
delimiter;
-- 2014-09-30


update ld_field_seq set id=(select max(fieldid) from ld_field);
update ld_blocks_seq set id=(select max(blockid) from ld_blocks);
update ld_relatedlists_seq set id=(select max(relation_id) from ld_relatedlists);
update ld_customview_seq set id = (select max(cvid) from ld_customview);
update ld_links_seq set id=(select max(linkid) from ld_links);
update ld_picklist_dependency_seq set id=(select max(id) from ld_picklist_dependency);
update ld_crmentity_seq set id=(select max(crmid) from ld_crmentity);
update ld_approve_seq set id=(select max(id) from ld_approve);
update ld_approvestep_seq set id=(select max(id) from ld_approvestep);
update lD_version set old_version='V5.7.0' ,current_version='V5.7.0' ,remark='V5.7.0-20140930';
delimiter;