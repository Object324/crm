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

call AddColumn('ld_wx_config','para_one','varchar',255,null );
call AddColumn('ld_wx_config','para_two','varchar',255,null );
call AddColumn('ld_wx_config','para_three','varchar',255,null );
call AddColumn('ld_singin','entityaddress','varchar','255',null);
delimiter;

insert into ld_wx_config ( name, description, switch, para_one,para_two)
  select 'wechat_miniprogram_setting','小程序设置','close','','' from dual
  where not exists(select 1 from ld_wx_config where name='wechat_miniprogram_setting');

INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
  select 'zh','WECHATAPPLETSETTINGS','小程序设置','fixedstr' from DUAL
  where not exists(select 1 from ld_desk where labelbol = 'WECHATAPPLETSETTINGS' and languagetype='zh' and labeltype = 'fixedstr');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
  select 'en','WECHATAPPLETSETTINGS','Mini Program Settings','fixedstr' from DUAL
  where not exists(select 1 from ld_desk where labelbol = 'WECHATAPPLETSETTINGS' and languagetype='en' and labeltype = 'fixedstr');

INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
  select 'zh','WECHATAPPLETSETTINGSWEBURL','设置小程序企业号','fixedstr' from DUAL
  where not exists(select 1 from ld_desk where labelbol = 'WECHATAPPLETSETTINGSWEBURL' and languagetype='zh' and labeltype = 'fixedstr');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
  select 'en','WECHATAPPLETSETTINGSWEBURL','Set the WeChat mini program enterprise number','fixedstr' from DUAL
  where not exists(select 1 from ld_desk where labelbol = 'WECHATAPPLETSETTINGSWEBURL' and languagetype='en' and labeltype = 'fixedstr');

select blockid into @blockid from ld_settings_blocks where label='LBL_INTERFACE_SETTINGS';
select max(sequence) into @sequence from ld_settings_field where blockid=@blockid;
select max(fieldid) into @fieldid from ld_settings_field;
insert into ld_settings_field(fieldid,blockid,name,iconpath,description,linkto,sequence,active)
  select @fieldid+1,@blockid,'WECHATAPPLETSETTINGS','picklistdependency.png',
    'WECHATAPPLETSETTINGSWEBURL','index.php?module=Settings&action=wechat_miniprogram_setting&parenttab=Settings',@sequence+1,0 from DUAL
  where not exists(select 1 from ld_settings_field where blockid = @blockid and `name` = 'WECHATAPPLETSETTINGS');

INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
  select 'zh','WECHATAPPLETSETTINGSTITLE01','企业号','fixedstr' from DUAL
  where not exists(select 1 from ld_desk where labelbol = 'WECHATAPPLETSETTINGSTITLE01' and languagetype='zh' and labeltype = 'fixedstr');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
  select 'en','WECHATAPPLETSETTINGSTITLE01','WeChat mini program enterprise number','fixedstr' from DUAL
  where not exists(select 1 from ld_desk where labelbol = 'WECHATAPPLETSETTINGSTITLE01' and languagetype='en' and labeltype = 'fixedstr');

INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
  select 'zh','WECHATAPPLETSETTINGSTITLE02','CRM外网访问地址','fixedstr' from DUAL
  where not exists(select 1 from ld_desk where labelbol = 'WECHATAPPLETSETTINGSTITLE02' and languagetype='zh' and labeltype = 'fixedstr');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
  select 'en','WECHATAPPLETSETTINGSTITLE02','Server address','fixedstr' from DUAL
  where not exists(select 1 from ld_desk where labelbol = 'WECHATAPPLETSETTINGSTITLE02' and languagetype='en' and labeltype = 'fixedstr');

INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
  select 'zh','WECHATAPPLETSETTINGSREMIND01','企业号只能录入字母、数字和下划线','fixedstr' from DUAL
  where not exists(select 1 from ld_desk where labelbol = 'WECHATAPPLETSETTINGSREMIND01' and languagetype='zh' and labeltype = 'fixedstr');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
  select 'en','WECHATAPPLETSETTINGSREMIND01','Enterprise Numbers can only be entered in letters, Numbers and underscores','fixedstr' from DUAL
  where not exists(select 1 from ld_desk where labelbol = 'WECHATAPPLETSETTINGSREMIND01' and languagetype='en' and labeltype = 'fixedstr');

INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
  select 'zh','WECHATAPPLETSETTINGSREMIND02','CRM地址无法访问或格式不正确，请参考格式','fixedstr' from DUAL
  where not exists(select 1 from ld_desk where labelbol = 'WECHATAPPLETSETTINGSREMIND02' and languagetype='zh' and labeltype = 'fixedstr');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
  select 'en','WECHATAPPLETSETTINGSREMIND02','The CRM address cannot be accessed or the format is incorrect, please refer to the format','fixedstr' from DUAL
  where not exists(select 1 from ld_desk where labelbol = 'WECHATAPPLETSETTINGSREMIND02' and languagetype='en' and labeltype = 'fixedstr');

INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
  select 'zh','WECHATAPPLETSETTINGSREMIND03','此企业号已被绑定，请输入其他企业号','fixedstr' from DUAL
  where not exists(select 1 from ld_desk where labelbol = 'WECHATAPPLETSETTINGSREMIND03' and languagetype='zh' and labeltype = 'fixedstr');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
  select 'en','WECHATAPPLETSETTINGSREMIND03','This enterprise number is bound. Please enter another enterprise number','fixedstr' from DUAL
  where not exists(select 1 from ld_desk where labelbol = 'WECHATAPPLETSETTINGSREMIND03' and languagetype='en' and labeltype = 'fixedstr');


INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
  select 'zh','WECHATAPPLETSETTINGSREMIND04','企业号只能录入字母、数字和下划线，最多50个字符','fixedstr' from DUAL
  where not exists(select 1 from ld_desk where labelbol = 'WECHATAPPLETSETTINGSREMIND04' and languagetype='zh' and labeltype = 'fixedstr');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
  select 'en','WECHATAPPLETSETTINGSREMIND04','Enterprise Numbers can only be entered in letters, Numbers and underscores, up to 50 characters','fixedstr' from DUAL
  where not exists(select 1 from ld_desk where labelbol = 'WECHATAPPLETSETTINGSREMIND04' and languagetype='en' and labeltype = 'fixedstr');

INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
  select 'zh','WECHATAPPLETSETTINGSREMIND05','crm外网访问地址请参照此格式','fixedstr' from DUAL
  where not exists(select 1 from ld_desk where labelbol = 'WECHATAPPLETSETTINGSREMIND05' and languagetype='zh' and labeltype = 'fixedstr');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
  select 'en','WECHATAPPLETSETTINGSREMIND05','Please refer to this format for the external network access address of CRM','fixedstr' from DUAL
  where not exists(select 1 from ld_desk where labelbol = 'WECHATAPPLETSETTINGSREMIND05' and languagetype='en' and labeltype = 'fixedstr');
delimiter;

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

CALL AddPrimaryKey('ld_productbomcf','productbomid');
CALL AddColumn('ld_singin','entityaddress','varchar','255','');
delimiter;

select usereportid into @usereportid from ld_usereport where `name` = 'SIGNINSTATISTICS';
update ld_usereportcolumns set realcolumns = 'ld_accountbillads:bill_street:ship_street:OftenUseReport_拜访地址（CRM系统数据）:V'
where Usereportid = @usereportid and `columns` = 'ld_accountbillads:bill_street:ship_street:OftenUseReport_相关客户地址（CRM系统数据）:V' and realcolumns = 'ld_accountbillads:bill_street:ship_street:OftenUseReport_相关客户地址（CRM系统数据）:V';
delimiter;


insert into ld_desk (languagetype,labelbol,fieldlabel,Labeltype)
select 'zh','nextmonth1',"下个月",'fixedstr' from DUAL
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='nextmonth1' and Labeltype='fixedstr');
insert into ld_desk (languagetype,labelbol,fieldlabel,Labeltype)
select 'en','nextmonth1',"Next month",'fixedstr' from DUAL
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='nextmonth1' and Labeltype='fixedstr');
delimiter;

insert into ld_desk (languagetype,labelbol,fieldlabel,Labeltype)
select 'zh','now',"现在",'fixedstr' from DUAL
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='now' and Labeltype='fixedstr');
insert into ld_desk (languagetype,labelbol,fieldlabel,Labeltype)
select 'en','now',"Now",'fixedstr' from DUAL
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='now' and Labeltype='fixedstr');
delimiter;

SET @report_name='客户服务次数统计表';
SET @report_type='template';
SET @report_template='default_tickets_times.mrt';
SET @setype='HelpDesk';
SET @report_describe='';
SET @report_url='';
SELECT id into @id from ld_customreport_folder where description='Statistical Charts';
SELECT max(sequence) into @sequence FROM ld_customreport_info WHERE folder_id=@id;
insert into ld_customreport_info(folder_id,report_name,report_type,report_template,report_url,sequence,allocatetype,systemdefault,presence,setype,report_describe)
SELECT @id,@report_name,@report_type,@report_template,@report_url,@sequence+1,0,1,0,@setype,@report_describe from DUAL
where not exists (select 1 from ld_customreport_info where report_template=@report_template and systemdefault=1);
delimiter;

SET @report_name='服务人员服务次数统计表';
SET @report_type='template';
SET @report_template='default_serviers_times.mrt';
SET @setype='HelpDesk';
SET @report_describe='';
SET @report_url='';
SELECT id into @id from ld_customreport_folder where description='Statistical Charts';
SELECT max(sequence) into @sequence FROM ld_customreport_info WHERE folder_id=@id;
insert into ld_customreport_info(folder_id,report_name,report_type,report_template,report_url,sequence,allocatetype,systemdefault,presence,setype,report_describe)
SELECT @id,@report_name,@report_type,@report_template,@report_url,@sequence+1,0,1,0,@setype,@report_describe from DUAL
where not exists (select 1 from ld_customreport_info where report_template=@report_template and systemdefault=1);
delimiter;

CALL Del_TableIndex('ld_potential','potential_relatedto_idx');
CALL Del_TableIndex('ld_potential','potentail_sales_stage_idx');
CALL Del_TableIndex('ld_potential','potentail_sales_stage_amount_idx');
CALL Del_TableIndex('ld_potential','relatedto_idx');
CALL Del_TableIndex('ld_potential','campaignid_idx');
CALL Del_TableIndex('ld_potential','productid_idx');
CALL Del_TableIndex('ld_potential','potential_multi_idx');
CALL Del_TableIndex('ld_potential','potential_amount_idx');

DROP PROCEDURE IF EXISTS `ldcrm_ticket_projectid_20181011`;
delimiter ||
CREATE PROCEDURE `ldcrm_ticket_projectid_20181011`(
)
begin

	SET @modulename='HelpDesk';
	SET @tabid=(SELECT tabid FROM ld_tab WHERE `name`=@modulename);
	SET @relateid=(SELECT block FROM ld_field WHERE tabid=@tabid AND columnname='smownerid' LIMIT 1);
	SET @maxseq=IFNULL((SELECT MAX(sequence) FROM ld_field WHERE tabid=@tabid AND block=@relateid),0);
	SET @trantable='ld_field';
	SET @tablename=(SELECT tablename FROM ld_field WHERE tabid=@tabid AND columnname='smownerid' LIMIT 1);
	SET @columnname='projectid';
	SET @fieldname='projectid';
	SET @zh='项目';
	SET @en='项目';
	SET @uitype=82;
	SET @typeofdata='V~O';
	SET @quickcreate=0;

	IF NOT EXISTS (SELECT 1 FROM ld_troubletickets) AND EXISTS (SELECT 1 FROM ld_tab WHERE presence=0 AND `name`='Project') THEN
		SET @presence=2;
	ELSE
		SET @presence=1;
	END IF;

	SET @maxid=(SELECT MAX(fieldid) FROM ld_field);

	INSERT INTO ld_field(tabid,fieldid,columnname,tablename,generatedtype,uitype,fieldname,fieldlabel,readonly,presence,defaultvalue,maximumlength,sequence,block,displaytype,typeofdata,quickcreate,quickcreatesequence,info_type,masseditable,helpinfo,fieldonly,approve_demand,is_checkimportfield)
	SELECT @tabid,@maxid+1,@columnname,@tablename,1,@uitype,@fieldname,@zh,1,@presence,NULL,100,@maxseq+1,@relateid,1,@typeofdata,@quickcreate,NULL,NULL,1,NULL,0,0,0 from dual
	WHERE NOT EXISTS (SELECT 1 FROM ld_field WHERE tabid=@tabid AND tablename=@tablename AND columnname=@columnname);

	UPDATE ld_field_seq SET id=(SELECT max(fieldid) FROM ld_field);

	SELECT fieldid INTO @relateid FROM ld_field WHERE tabid=@tabid AND columnname=@columnname LIMIT 1;

	INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
	SELECT 'zh',@trantable,@tabid,@relateid,@zh FROM DUAL
	WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE languagetype = 'zh' AND trantable =@trantable AND tabid = @tabid AND relateid=@fieldid);

	INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
	SELECT 'en',@trantable,@tabid,@relateid,@en FROM DUAL
	WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE languagetype = 'en' AND trantable =@trantable AND tabid = @tabid AND relateid=@fieldid);

	CALl AddColumn(@tablename,@columnname,'INT','19',NULL);
	CALL getallprofile(@modulename);
	CALL fieldprofile(@modulename);

	SET @tri_fieldid=(SELECT fieldid FROM ld_field WHERE tabid=13 AND columnname='projectid');
	SET @eff_fieldid=(SELECT fieldid FROM ld_field WHERE tabid=13 AND columnname='accountid');
	INSERT INTO ld_related_field(fieldtype,trigger_fieldid,effect_fieldid,fromvalue_type,fromvalue_info)
	SELECT 'main',@tri_fieldid,@eff_fieldid,'column','accountid' FROM DUAL
	WHERE NOT EXISTS (SELECT 1 FROM ld_related_field WHERE trigger_fieldid=@tri_fieldid AND effect_fieldid=@eff_fieldid);

	IF NOT EXISTS (SELECT 1 FROM ld_crmentityrel WHERE module='Project' AND relmodule='HelpDesk') THEN
		UPDATE ld_relatedlists SET actions='ADD',type='datacategory_sql',related_coltable='troubletickets.projectid' WHERE tabid=48 AND related_tabid=13;
	END IF;

end ||
delimiter;

CALL ldcrm_ticket_projectid_20181011();
DROP PROCEDURE IF EXISTS `ldcrm_ticket_projectid_20181011`;
delimiter;


select sequence,roottype into @sequence,@roottype from ld_systems_deploy where deploy_type = 159;
update ld_systems_deploy set sequence = sequence + 1000 where inputtype = @roottype and sequence > @sequence;
insert into ld_systems_deploy(deploy_value,deploy_type,description,setype,sequence,roottype,inputtype,presence,inputvalue)
select '1',166,'客户最晚服务到期日到期后是否允许创建{$HelpDesk.HelpDesk}','',@sequence,@roottype,'select',0,'[{"value":"1","text":"YES"},{"value":"0","text":"NO"},{"sql":""}]'
from dual where not exists(select 1 from ld_systems_deploy where roottype=@roottype and deploy_type=166);
set @i=0;
update ld_systems_deploy set sequence=(@i:=@i+1) where roottype = @roottype order by sequence;
delimiter;

insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'zh','ld_systems_deploy',166,166,'{$Accounts.Accounts}最晚服务到期日到期后是否允许创建{$HelpDesk.HelpDesk}' from DUAL
where not exists(select 1 from ld_tranlabel where languagetype='zh' and trantable='ld_systems_deploy' and relateid=166 and tabid = 166);
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'en','ld_systems_deploy',166,166,'Is the {$HelpDesk.HelpDesk} allowed to be created after the {$Accounts.Accounts} latest service expiry date' from DUAL
where not exists(select 1 from ld_tranlabel where languagetype='en' and trantable='ld_systems_deploy' and relateid=166 and tabid = 166);
delimiter;

insert into ld_desk (languagetype,labelbol,fieldlabel,Labeltype)
select 'zh','thecurstomerserviceordersarenotallowedtobe',"客户最晚服务到期日到期后不允许创建客户服务单",'jspop' from DUAL
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='thecurstomerserviceordersarenotallowedtobe' and Labeltype='jspop');
insert into ld_desk (languagetype,labelbol,fieldlabel,Labeltype)
select 'en','thecurstomerserviceordersarenotallowedtobe',"The customer service orders are not allowed to be created after the latest service expiry date",'jspop' from DUAL
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='thecurstomerserviceordersarenotallowedtobe' and Labeltype='jspop');
delimiter;

insert into ld_desk (languagetype,labelbol,fieldlabel,Labeltype)
select 'zh','thecurstomerserviceordersarenotallowedtobe',"客户最晚服务到期日到期后不允许创建客户服务单",'fixedstr' from DUAL
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='thecurstomerserviceordersarenotallowedtobe' and Labeltype='fixedstr');
insert into ld_desk (languagetype,labelbol,fieldlabel,Labeltype)
select 'en','thecurstomerserviceordersarenotallowedtobe',"The customer service orders are not allowed to be created after the latest service expiry date",'fixedstr' from DUAL
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='thecurstomerserviceordersarenotallowedtobe' and Labeltype='fixedstr');
delimiter;
-- 2018-10-11

SET @report_name='客户服务单故障类别统计表';
SET @report_type='template';
SET @report_template='default_tickets_category.mrt';
SET @setype='HelpDesk';
SET @report_describe='';
SET @report_url='';
SELECT id into @id from ld_customreport_folder where description='Statistical Charts';
SELECT max(sequence) into @sequence FROM ld_customreport_info WHERE folder_id=@id;
insert into ld_customreport_info(folder_id,report_name,report_type,report_template,report_url,sequence,allocatetype,systemdefault,presence,setype,report_describe)
SELECT @id,@report_name,@report_type,@report_template,@report_url,@sequence+1,0,1,0,@setype,@report_describe from DUAL
where not exists (select 1 from ld_customreport_info where report_template=@report_template and systemdefault=1);
delimiter;


call AddColumn('ld_reminds','wxremindstype','varchar',100,null );
call AddColumn("ld_reminds",'parentid','int',19,0);
delimiter;

CREATE TABLE IF NOT EXISTS `ld_tmp_wx_reminds` (
  `createdtime` datetime NOT NULL,
  `id` int(11) NOT NULL AUTO_INCREMENT,
  PRIMARY KEY (`id`),
  UNIQUE KEY `dd` (`createdtime`) USING BTREE
) ENGINE=InnoDB AUTO_INCREMENT=7 DEFAULT CHARSET=utf8;
delimiter;

select tabid into @tabid from ld_tab where `name` = 'PaymentPlan';
select max(fieldid) into @max_fieldid from ld_field;
select fieldid,sequence,block into @fieldid,@sequence,@block from ld_field where tabid = @tabid and columnname = 'accountid';
update ld_field set sequence = sequence + 1000 where tabid = @tabid and block = @block and sequence > @sequence;
insert into ld_field(tabid,fieldid,columnname,allowhide,tablename,generatedtype,uitype,fieldname,fieldlabel,readonly,presence,defaultvalue,maximumlength,
sequence,block,displaytype,typeofdata,quickcreate,quickcreatesequence,info_type,masseditable,helpinfo,fieldonly,issmownerid,searchfieldtype,associatedfields,
associatedsequence,callchecked,duplicatefield,relate_search_parent_columnname,approve_demand,is_checkimportfield)
select @tabid,@max_fieldid+1,'paymenttype','yes','ld_paymentplan',1,15,'paymenttype','计划回款日期',1,2,NULL,NULL,1,@block,1,'V~M',0,NULL,NULL,0,NULL,0,0,0,0,0,0,NULL,NULL,0,0 
from DUAL where not exists(select 1 from ld_field where tabid = @tabid and columnname = 'paymenttype');
set @i=0;
update ld_field set Sequence=(@i:=@i+1) where tabid = @tabid and block = @block ORDER BY sequence;
delimiter;

select tabid into @tabid from ld_tab where `name` = 'PaymentPlan';
select fieldid into @relateid from ld_field where tabid = @tabid and columnname = 'paymenttype';
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'zh','ld_field',@tabid,@relateid,'回款计划类型' from DUAL
where not exists(select 1 from ld_tranlabel where tabid = @tabid and relateid = @relateid and languagetype = 'zh' and trantable = 'ld_field');
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'en','ld_field',@tabid,@relateid,'PaymentPlan type' from DUAL
where not exists(select 1 from ld_tranlabel where tabid = @tabid and relateid = @relateid and languagetype = 'en' and trantable = 'ld_field');
delimiter;

call AddColumn('ld_paymentplan','paymenttype','varchar','100',NULL);
delimiter;

insert into ld_picklist_set(listname,relatetable)
select 'paymenttype','ld_field' from DUAL
where not exists(select 1 from ld_picklist_set where listname = 'paymenttype' and relatetable = 'ld_field');
delimiter;

select listid into @listid from ld_picklist_set where listname = 'paymenttype' and relatetable = 'ld_field';
insert into ld_picklist_values(listid,listvalue,sequence)
select @listid,'计划回款日期',1 from DUAL
where not exists(select 1 from ld_picklist_values where listid = @listid and listvalue = '计划回款日期');
insert into ld_picklist_values(listid,listvalue,sequence)
select @listid,'项目状态',2 from DUAL
where not exists(select 1 from ld_picklist_values where listid = @listid and listvalue = '项目状态');
delimiter;

select deploy_value into @deploy_value from ld_systems_deploy where deploy_type = 53;
select tabid into @tabid from ld_tab where `name` = 'PaymentPlan';
update ld_field set defaultvalue = '项目状态' where tabid = @tabid and columnname = 'paymenttype' and @deploy_value = 1;
delimiter;

select tabid into @tabid from ld_tab where `name` = 'PaymentPlan';
update ld_field set typeofdata = 'D~O' where tabid = @tabid and columnname = 'plandate';
delimiter;

delete from ld_systems_deploy where deploy_type = 53;
delimiter;

call AddColumn('ld_users','helpdesk_log','varchar','10',NULL);
update ld_users set helpdesk_log = 1 where helpdesk_log is NULL or helpdesk_log = '';
select tabid into @tabid from ld_tab where `name` = 'Users';
select max(fieldid) into @max_fieldid from ld_field;
select fieldid,sequence,block into @fieldid,@sequence,@block from ld_field where tabid = @tabid and columnname = 'select_due_date';
update ld_field set sequence = sequence + 1000 where tabid = @tabid and block = @block and sequence > @sequence;
insert into ld_field(tabid,fieldid,columnname,allowhide,tablename,generatedtype,uitype,fieldname,fieldlabel,readonly,presence,defaultvalue,maximumlength,
sequence,block,displaytype,typeofdata,quickcreate,quickcreatesequence,info_type,masseditable,helpinfo,fieldonly,issmownerid,searchfieldtype,associatedfields,
associatedsequence,callchecked,duplicatefield,relate_search_parent_columnname,approve_demand,is_checkimportfield)
select @tabid,@max_fieldid+1,'helpdesk_log','yes','ld_users',1,56,'helpdesk_log','显示客户服务单历史记录',1,2,NULL,NULL,@sequence+1,@block,1,'C~O',1,NULL,NULL,2,NULL,0,0,0,0,0,0,NULL,NULL,0,0 
from DUAL where not exists(select 1 from ld_field where tabid = @tabid and columnname = 'helpdesk_log');
set @i=0;
update ld_field set Sequence=(@i:=@i+1) where tabid = @tabid and block = @block ORDER BY sequence;
delimiter;

select tabid into @tabid from ld_tab where `name` = 'Users';
select fieldid into @relateid from ld_field where tabid = @tabid and columnname = 'helpdesk_log';
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'zh','ld_field',@tabid,@relateid,'显示客户服务单历史记录' from DUAL
where not exists(select 1 from ld_tranlabel where tabid = @tabid and relateid = @relateid and languagetype = 'zh' and trantable = 'ld_field');
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'en','ld_field',@tabid,@relateid,'View the account trouble tickets history' from DUAL
where not exists(select 1 from ld_tranlabel where tabid = @tabid and relateid = @relateid and languagetype = 'en' and trantable = 'ld_field');
delimiter;

insert into ld_desk (languagetype,labelbol,fieldlabel,Labeltype)
select 'zh','helpdesk_log',"客户服务单界面是否显示客户服务单历史记录",'fixedstr' from DUAL
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='helpdesk_log' and Labeltype='fixedstr');
insert into ld_desk (languagetype,labelbol,fieldlabel,Labeltype)
select 'en','helpdesk_log',"Does the account trouble tickets interface display account trouble tickets history?",'fixedstr' from DUAL
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='helpdesk_log' and Labeltype='fixedstr');
delimiter;

update ld_desk set fieldlabel='审批成功，结束流程' where labelbol='SUCCESSENDPROCESS' and languagetype='zh' and labeltype='fixedstr';
update ld_desk set fieldlabel='审批失败，结束流程' where labelbol='FAILENDPROCESS' and languagetype='zh' and labeltype='fixedstr';
delimiter;

select fieldid into @fieldid from ld_field where tabid = 14 and columnname = 'unit_price';
update ld_tranlabel set fieldlabel = '产品报价(RMB)' where tabid = 14 and Relateid = @fieldid and languagetype = 'zh' and fieldlabel = '参考价(RMB)';
delimiter;

call AddColumn('ld_users','wx_openid','varchar',255,null );
insert into ld_desk (languagetype, labelbol, fieldlabel, Labeltype)
  SELECT 'zh','WECHATAPPLETHEADER','微信小程序','fixedstr' from dual
  where not exists(select 1 from ld_desk
  where labelbol='WECHATAPPLETHEADER' and Labeltype='fixedstr' and languagetype='zh');
insert into ld_desk (languagetype, labelbol, fieldlabel, Labeltype)
  SELECT 'en','WECHATAPPLETHEADER','Applet of WeChat','fixedstr' from dual
  where not exists(select 1 from ld_desk
  where labelbol='WECHATAPPLETHEADER' and Labeltype='fixedstr' and languagetype='en');
delimiter;
-- 2018-10-17

UPDATE ld_field SET allowhide='yes' WHERE tabid=22 AND columnname='totalquantity';

DROP PROCEDURE IF EXISTS `ldcrm_ticket_questionid_20181017`;
delimiter ||
CREATE PROCEDURE `ldcrm_ticket_questionid_20181017`(
)
begin

	SET @modulename='HelpDesk';
	SET @tabid=(SELECT tabid FROM ld_tab WHERE `name`=@modulename);
	SET @relateid=(SELECT block FROM ld_field WHERE tabid=@tabid AND columnname='description' LIMIT 1);
	SET @maxseq=IFNULL((SELECT MAX(sequence) FROM ld_field WHERE tabid=@tabid AND block=@relateid),0);
	SET @trantable='ld_field';
	SET @tablename=(SELECT tablename FROM ld_field WHERE tabid=@tabid AND columnname='smownerid' LIMIT 1);
	SET @columnname='questionid'; 
	SET @fieldname='questionid'; 
	SET @zh='常见问题'; 
	SET @en='questionid'; 
	SET @uitype=79; 
	SET @typeofdata='V~O';
	SET @quickcreate=0;

	IF NOT EXISTS (SELECT 1 FROM ld_troubletickets) AND EXISTS (SELECT 1 FROM ld_tab WHERE presence=0 AND `name`='Faq') THEN
		SET @presence=2;
	ELSE
		SET @presence=1;
	END IF;


	SET @maxid=(SELECT MAX(fieldid) FROM ld_field);
	INSERT INTO ld_field(tabid,fieldid,columnname,tablename,generatedtype,uitype,fieldname,fieldlabel,readonly,presence,defaultvalue,maximumlength,sequence,block,displaytype,typeofdata,quickcreate,quickcreatesequence,info_type,masseditable,helpinfo,fieldonly,approve_demand,is_checkimportfield)
	SELECT @tabid,@maxid+1,@columnname,@tablename,1,@uitype,@fieldname,@zh,1,@presence,NULL,100,@maxseq+1,@relateid,1,@typeofdata,@quickcreate,NULL,NULL,1,NULL,0,0,0 from dual
	WHERE NOT EXISTS (SELECT 1 FROM ld_field WHERE tabid=@tabid AND tablename=@tablename AND columnname=@columnname);

	UPDATE ld_field_seq SET id=(SELECT max(fieldid) FROM ld_field);

	SELECT fieldid INTO @relateid FROM ld_field WHERE tabid=@tabid AND columnname=@columnname LIMIT 1;
	DELETE FROM ld_tranlabel WHERE tabid=@tabid AND relateid=@relateid AND trantable='ld_field';

	INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
	SELECT 'zh',@trantable,@tabid,@relateid,@zh FROM DUAL 
	WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE languagetype = 'zh' AND trantable =@trantable AND tabid = @tabid AND relateid=@fieldid);

	INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
	SELECT 'en',@trantable,@tabid,@relateid,@en FROM DUAL 
	WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE languagetype = 'en' AND trantable =@trantable AND tabid = @tabid AND relateid=@fieldid);

	CALl AddColumn(@tablename,@columnname,'INT','19',NULL);


	CALL getallprofile(@modulename);
	CALL fieldprofile(@modulename);

	UPDATE ld_field SET presence=@presence WHERE tabid=@tabid AND columnname='questionid';

end ||
delimiter;

CALL ldcrm_ticket_questionid_20181017();
DROP PROCEDURE IF EXISTS `ldcrm_ticket_questionid_20181017`;
delimiter;

call AddColumn('ld_account_set_rule','iscycle','varchar',100,null );
call AddColumn('ld_account_set_rule','singlelabelbol','varchar',100,null );
update ld_account_set_rule set `status`='inactive' where type='nocomplete';
update ld_account_set_rule set `status`='inactive' where type='singlenormal';
delimiter;
insert into ld_desk (languagetype,labelbol,fieldlabel,labeltype)
select 'zh','LOGPUBLICALLOCATE','公海已分配客户参与回收，设置的回收条件未达成，释放到公海未分配','fixedstr' from dual 
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='LOGPUBLICALLOCATE' and Labeltype='fixedstr');

insert into ld_desk (languagetype,labelbol,fieldlabel,labeltype)
select 'en','LOGPUBLICALLOCATE','公海已分配客户参与回收，设置的回收条件未达成，释放到公海未分配','fixedstr' from dual 
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='LOGPUBLICALLOCATE' and Labeltype='fixedstr');
delimiter;
update ld_desk  set fieldlabel='公海客户参与回收，回收规则条件逻辑关系为' where labelbol='COMPLETEAUTOMATICRECOVERYRULE'
and labeltype='fixedstr';
update ld_desk set fieldlabel='普通客户参与回收，回收规则条件逻辑关系为' where labelbol='NORMALCUSTOMRECYCLE' and labeltype='fixedstr';
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','RECYCLERULE','循环回收规则','fixedstr' from dual 
where not exists(select 1 from ld_desk where languagetype='zh' and  labelbol='RECYCLERULE' and labeltype='fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','RECYCLERULE','循环回收规则','fixedstr' from dual 
where not exists(select 1 from ld_desk where languagetype='en' and  labelbol='RECYCLERULE' and labeltype='fixedstr');

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','SINGLERULE','单次回收规则','fixedstr' from dual 
where not exists(select 1 from ld_desk where languagetype='zh' and  labelbol='SINGLERULE' and labeltype='fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','SINGLERULE','单次回收规则','fixedstr' from dual 
where not exists(select 1 from ld_desk where languagetype='en' and  labelbol='SINGLERULE' and labeltype='fixedstr');
delimiter;

update ld_account_set_rule set singlelabelbol='ALLOCATEORGETSTART/NOTCREATECONTACTRECORDS' where type='complete' and tabname='contactrecords';
update ld_account_set_rule set singlelabelbol='ALLOCATEORGETSTART/NOTCREATEPOTENTIALS' where type='complete' and tabname='Potentials';
update ld_account_set_rule set singlelabelbol='ALLOCATEORGETSTART/NOTCREATESALESORDER' where type='complete' and tabname='SalesOrder';
update ld_account_set_rule set singlelabelbol='ALLOCATEORGETSTART/NOTCREATESERVICECONTRACTS' where type='complete' and tabname='ServiceContracts';
update ld_account_set_rule set singlelabelbol='ALLOCATEORGETSTART/NOTCREATECASHBILL' where type='complete' and tabname='CashBill';
delimiter;

update ld_account_set_rule set singlelabelbol='ALLOCATEORCREATETIMESTART/NOTCREATECONTACTRECORDS' where type='normal' and tabname='contactrecords';
update ld_account_set_rule set singlelabelbol='ALLOCATEORCREATETIMESTART/NOTCREATEPOTENTIALS' where type='normal' and tabname='Potentials';
update ld_account_set_rule set singlelabelbol='ALLOCATEORCREATETIMESTART/NOTCREATESALESORDER' where type='normal' and tabname='SalesOrder';
update ld_account_set_rule set singlelabelbol='ALLOCATEORCREATETIMESTART/NOTCREATESERVICECONTRACTS' where type='normal' and tabname='ServiceContracts';
update ld_account_set_rule set singlelabelbol='ALLOCATEORCREATETIMESTART/NOTCREATECASHBILL' where type='normal' and tabname='CashBill';
delimiter;
update ld_account_set_rule set iscycle='yes' where iscycle is null or iscycle='';
delimiter;





drop PROCEDURE if EXISTS `account_singlerecycle_normal_rule`;
delimiter ||
CREATE PROCEDURE account_singlerecycle_normal_rule()
BEGIN

	DECLARE var_tabname varchar(100);
	DECLARE var_columnname varchar(100);
	DECLARE var_tablename varchar(100);
	DECLARE var_condition varchar(50);
	declare var_iscycle varchar(50);
	DECLARE var_days int(11);
	DECLARE var_otherwhere varchar(200);
	declare done  int  default 0;

	declare cur1 CURSOR FOR select tabname,ld_account_set_rule.columnname,ld_field.tablename ,
	ld_account_set_rule.iscycle,`condition`,ld_account_set_rule.days
 ,ld_account_set_rule.otherwhere from ld_account_set_rule  inner join ld_tab on ld_tab.name=ld_account_set_rule.tabname and presence in(0,2)
	INNER JOIN ld_field on ld_field.tabid=ld_tab.tabid and ld_account_set_rule.columnname=ld_field.columnname
	and ld_field.presence in(0,2) where ld_account_set_rule.type='normal' and ld_account_set_rule.`status`='active';
	declare continue handler  for not   found  SET done =1;
	set @tmpint=0;
	set @tmpsql='';
	select max(ld_account_set_rule.days) into @maxdays
  from ld_account_set_rule  inner join ld_tab on ld_tab.name=ld_account_set_rule.tabname and presence in(0,2)
	INNER JOIN ld_field on ld_field.tabid=ld_tab.tabid and ld_account_set_rule.columnname=ld_field.columnname
	and ld_field.presence in(0,2) where ld_account_set_rule.type='normal' and ld_account_set_rule.`status`='active';

	OPEN cur1;

	Fetch cur1 into var_tabname,var_columnname,var_tablename,var_iscycle,var_condition,var_days,var_otherwhere;
	loop1: while  done<>1 DO

		  if(var_condition='and' ) then

			set @tmpsqlone =concat("select ld_account.accountid,ld_account.distributiondate,ld_account.createdtime from ld_account ");
			set @tmpsqlone=concat(@tmpsqlone," inner join ",var_tablename,' on ',var_tablename,'.accountid=ld_account.accountid' );
			set @tmpsqltwo=concat(@tmpsqltwo," and  ",var_tablename,'.smownerid=ld_account.smownerid ');

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
						and ld_account.smownerid=',var_tablename,'.smownerid  where ',var_tablename,'.deleted=0' );

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
			  set @tmpsql=concat(@tmpsql,' and ' ,var_tablename,'.smownerid=ld_account.smownerid ' );
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
		

		set @sql=concat(' select accountid from (',@tmpsql, ') as tmpone group by accountid ') ;


	  if var_condition='or'  then
			set @TMPSQL_ONE=concat( ' select "系统","LOGPUBLICNORMAL",now(), ld_account.accountid  from ld_account left join ( ',@sql,' ) as lingdangtmp  on  lingdangtmp.accountid=ld_account.accountid ') ;
		  set @TMPSQL_TWO=concat(@TMPSQL_ONE,' where ld_account.deleted=0 and( ifnull(ld_account.publicaccount,0)<1)'  );
		  set @TMPSQL_TWO=concat(@TMPSQL_TWO, " and lingdangtmp.accountid is null  and datediff(curdate(),case when ifnull(ld_account.distributiondate,'')='' then ld_account.createdtime else ld_account.distributiondate end)>",@maxdays);
		else
			set @TMPSQL_ONE=concat( ' select "系统","LOGPUBLICNORMAL",now(), ld_account.accountid  from ld_account inner join ( ',@sql,' ) as lingdangtmp  on  lingdangtmp.accountid=ld_account.accountid ') ;
		  set @TMPSQL_TWO=concat(@TMPSQL_ONE,' where ld_account.deleted=0 and( ifnull(ld_account.publicaccount,0)<1)'  );
		 end if;
	   set @TMPSQL_THREE=concat('insert into ld_logpublicaccount(username,operation,opdate,accountid) ',@TMPSQL_TWO);
		 prepare stmt from @TMPSQL_THREE;
		 execute stmt;
		 deallocate prepare stmt;



		if var_condition='or'  then
			 set @TMPSQL_ONE=concat( ' select "normal" as type, GROUP_CONCAT(accountname separator "<br>")as accountnames,count(ld_account.accountid)  as totalaccounts,ld_account.smownerid from    ld_account left join ( ',@sql,' ) as lingdangtmp  on  lingdangtmp.accountid=ld_account.accountid ') ;
		   set @TMPSQL_TWO=concat(@TMPSQL_ONE,' where ld_account.deleted=0 and( ifnull(ld_account.publicaccount,0)<1)    ');
		   set @TMPSQL_TWO=concat(@TMPSQL_TWO, " and lingdangtmp.accountid is null and datediff(curdate(),case when ifnull(ld_account.distributiondate,'')='' then ld_account.createdtime else ld_account.distributiondate end)>",@maxdays);
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
			  	set @TMPSQL_ONE=concat( ' update  ld_account left join ( ',@sql,' ) as lingdangtmp  on  lingdangtmp.accountid=ld_account.accountid set ld_account.publicaccount=1 ,protectdate=null ,allocatedate=null') ;
		      set @TMPSQL_TWO=concat(@TMPSQL_ONE,' where ld_account.deleted=0 and( ifnull(ld_account.publicaccount,0)<1)    ');
		      set @TMPSQL_TWO=concat(@TMPSQL_TWO, " and lingdangtmp.accountid is null and datediff(curdate(),case when ifnull(ld_account.distributiondate,'')='' then ld_account.createdtime else ld_account.distributiondate end)>",@maxdays);
			ELSE
				set @TMPSQL_ONE=concat( ' update  ld_account inner join ( ',@sql,' ) as lingdangtmp  on  lingdangtmp.accountid=ld_account.accountid set ld_account.publicaccount=1 ,protectdate=null ,allocatedate=null') ;
		    set @TMPSQL_TWO=concat(@TMPSQL_ONE,' where ld_account.deleted=0 and( ifnull(ld_account.publicaccount,0)<1)    ');
					select @TMPSQL_TWO;
		end if;
		prepare stmt from @TMPSQL_TWO;
		execute stmt;
		deallocate prepare stmt;

	end if;


end ||
delimiter;


drop PROCEDURE if EXISTS `account_singlerecycle_highsea_rule`;
delimiter ||
create PROCEDURE  account_singlerecycle_highsea_rule()
BEGIN

	DECLARE var_tabname varchar(100);
	DECLARE var_columnname varchar(100);
	DECLARE var_tablename varchar(100);
	DECLARE var_condition varchar(50);
	DECLARE var_days int(11);
	DECLARE var_otherwhere varchar(200);
	declare var_iscycle varchar(100);
	declare done  int  default 0;

	declare cur1 CURSOR FOR select tabname,ld_account_set_rule.columnname,ld_field.tablename ,ld_account_set_rule.iscycle, `condition`,ld_account_set_rule.days
 ,ld_account_set_rule.otherwhere from ld_account_set_rule  inner join ld_tab on ld_tab.name=ld_account_set_rule.tabname and presence in(0,2)
	INNER JOIN ld_field on ld_field.tabid=ld_tab.tabid and ld_account_set_rule.columnname=ld_field.columnname
	and ld_field.presence in(0,2) where ld_account_set_rule.type='complete' and ld_account_set_rule.`status`='active';
	declare continue handler  for not   found  SET done =1;
	set @tmpint=0;
	set @tmpsql='';
 select max(ld_account_set_rule.days) into @maxdays
  from ld_account_set_rule  inner join ld_tab on ld_tab.name=ld_account_set_rule.tabname and presence in(0,2)
	INNER JOIN ld_field on ld_field.tabid=ld_tab.tabid and ld_account_set_rule.columnname=ld_field.columnname
	and ld_field.presence in(0,2) where ld_account_set_rule.type='complete' and ld_account_set_rule.`status`='active';

  select allotaccount into @allotaccount from ld_account_set;
	OPEN cur1;

	Fetch cur1 into var_tabname,var_columnname,var_tablename,var_iscycle,var_condition,var_days,var_otherwhere;
	loop1: while  done<>1 DO

		  if(var_condition='and' ) then

					set @tmpsqlone =concat("select ld_account.accountid,ld_account.allocatedate from ld_account ");
					set @tmpsqlone=concat(@tmpsqlone," inner join ",var_tablename,' on ',var_tablename,'.accountid=ld_account.accountid ');
					set @tmpsqlone=concat(@tmpsqlone," and  ",var_tablename,'.smownerid=ld_account.smownerid' );

					set @tmpsqlone=concat(@tmpsqlone ,"  where  ",var_tablename,".deleted=0");
					 if var_otherwhere is not null and  var_otherwhere<>'' then
							set @tmpsqlone=concat(@tmpsqlone,var_otherwhere);
						end if;
					
					if var_iscycle='yes' then 
							set @tmpsqlone=concat( @tmpsqlone,' group by ld_account.accountid ') ;
							set @tmpsqlone=concat(@tmpsqlone,"   having datediff(curdate(), case when ld_account.allocatedate> max( " ,var_tablename,'.',var_columnname," )  then ld_account.allocatedate else max( " ,var_tablename,'.',var_columnname," ) end  ) >",var_days);
					else
							set @tmpsqlone=concat(@tmpsqlone," and ld_account.allocatedate<=",var_tablename,'.',var_columnname); 
							set @tmpsqlone=concat( @tmpsqlone,' group by ld_account.accountid ') ;
							set @tmpsqlone=concat(@tmpsqlone,"  having  datediff(min( ",var_tablename,'.',var_columnname,"),ld_account.allocatedate)>",var_days);
					end if;
					set @tmpsqltwo=concat('select ld_account.accountid,ld_account.allocatedate from  ld_account LEFT JOIN(select ld_account.accountid
							from ld_account inner join ',var_tablename,' on ld_account.accountid=',var_tablename,'.accountid
								and ld_account.smownerid=',var_tablename,'.smownerid  where ',var_tablename,'.deleted=0' );

					 if var_otherwhere is not null and  var_otherwhere<>'' then
							set @tmpsqltwo=concat(@tmpsqltwo, var_otherwhere);
						end if;
					set @tmpsqltwo=concat(@tmpsqltwo,' ) 	as ttt_',var_tablename,'  on ld_account.accountid=ttt_',var_tablename,'.accountid   where ttt_',var_tablename,'.accountid is null  ' );
					set @tmpsqltwo=concat(@tmpsqltwo," having datediff(curdate(),ld_account.allocatedate ) >",var_days);

					set @tmpthree=concat( @tmpsqlone,' union all ',@tmpsqltwo);
					set @tmpsql=concat(@tmpsql," select * from ( ",@tmpthree," ) as  tttt_",var_tabname);
					set @tmpsql=concat(@tmpsql,' union all ' );

			elseif (var_condition='or')  then
				set @tmpsql=concat(@tmpsql ,' select ld_account.accountid,ld_account.allocatedate from ld_account inner join '  ,var_tablename,' on ',var_tablename,'.accountid=ld_account.accountid  ');

			  set @tmpsql=concat(@tmpsql,' and ' ,var_tablename,'.smownerid=ld_account.smownerid ' );
				set @tmpsql=concat(@tmpsql,' where  ' , var_tablename,'.deleted=0 ' );
			  if var_otherwhere is not null and  var_otherwhere<>'' then
					set @tmpsql=concat(@tmpsql,var_otherwhere);
				end if;

			  
			  if var_iscycle='yes' then 
						set @tmpsql=concat( @tmpsql,' group by ld_account.accountid ') ;
						set @tmpsql=concat(@tmpsql," having    datediff ( curdate(), case when ld_account.allocatedate> max( ",var_tablename,'.',var_columnname," ) then ld_account.allocatedate else max( ",var_tablename,'.',var_columnname," )  end )<=",var_days );

				ELSE	
				  set @tmpsql=concat(@tmpsql," and ld_account.allocatedate<=",var_tablename,'.',var_columnname); 
					set @tmpsql=concat( @tmpsql,' group by ld_account.accountid ') ;
					set @tmpsql=concat(@tmpsql,"  having datediff(min( ",var_tablename,'.',var_columnname,"),ld_account.allocatedate)<=",var_days);
				end if;
				set @tmpsql=concat(@tmpsql,' union all ' );

			end if;
			set @tmpint=@tmpint+1;
			Fetch cur1 into var_tabname,var_columnname,var_tablename,var_iscycle,var_condition,var_days,var_otherwhere;
		end while loop1;
		close cur1;
		select @tmpsql;
	if @tmpint>0 then
		set @len=CHAR_LENGTH(' union all ');
		set @tmpsql=left(@tmpsql,CHAR_LENGTH(@tmpsql)-@len);
		set @sql=concat(' select accountid from (',@tmpsql, ') as tmpone group by accountid ') ;


	  if var_condition='or'  then
			set @TMPSQL_ONE=concat( ' select "系统","LOGPUBLICALLOCATE",now(), ld_account.accountid  from ld_account left join ( ',@sql,' ) as lingdangtmp  on  lingdangtmp.accountid=ld_account.accountid ') ;
			set @TMPSQL_TWO=concat(@TMPSQL_ONE,' where ld_account.deleted=0 and( ld_account.publicaccount=2 or ld_account.publicaccount=3)  ');
		  set @TMPSQL_TWO=concat(@TMPSQL_TWO, ' and lingdangtmp.accountid is null  and datediff(curdate(),ld_account.allocatedate)>',@maxdays);
		else
			set @TMPSQL_ONE=concat( ' select "系统","LOGPUBLICALLOCATE",now(), ld_account.accountid  from ld_account inner join ( ',@sql,' ) as lingdangtmp  on  lingdangtmp.accountid=ld_account.accountid ') ;
			set @TMPSQL_TWO=concat(@TMPSQL_ONE,' where ld_account.deleted=0 and( ld_account.publicaccount=2 or ld_account.publicaccount=3)  ');

		end if;
	   set @TMPSQL_THREE=concat('insert into ld_logpublicaccount(username,operation,opdate,accountid) ',@TMPSQL_TWO);
		 prepare stmt from @TMPSQL_THREE;
		 execute stmt;
		 deallocate prepare stmt;
		

    if var_condition='or'  then
			 set @TMPSQL_ONE=concat( ' select "complete" as type, GROUP_CONCAT(accountname separator "<br>")as accountnames,count(ld_account.accountid)  as totalaccounts,ld_account.smownerid from    ld_account left join ( ',@sql,' ) as lingdangtmp  on  lingdangtmp.accountid=ld_account.accountid ') ;
		   set @TMPSQL_TWO=concat(@TMPSQL_ONE,' where ld_account.deleted=0 and( ld_account.publicaccount=2 or ld_account.publicaccount=3)  ');
		  set @TMPSQL_TWO=concat(@TMPSQL_TWO, ' and lingdangtmp.accountid is null  and datediff(curdate(),ld_account.allocatedate)>',@maxdays);
			set @TMPSQL_TWO=concat(@TMPSQL_TWO," group by ld_account.smownerid ");
		else
			set @TMPSQL_ONE=concat( ' select "complete" as type, GROUP_CONCAT(ld_account.accountname separator "<br>")as accountnames,count(ld_account.accountid)  as totalaccounts,ld_account.smownerid from    ld_account  inner join ( ',@sql,' ) as lingdangtmp  on  lingdangtmp.accountid=ld_account.accountid ') ;
		   set @TMPSQL_TWO=concat(@TMPSQL_ONE,' where ld_account.deleted=0  and( ld_account.publicaccount=2 or ld_account.publicaccount=3)   group by ld_account.smownerid    ');
		end if;
     delete from ld_publicaccount_remindtableview ;

     set @tmpthree=concat(" insert into ld_publicaccount_remindtableview(type,names,totalaccounts,smownerid )  ", @TMPSQL_TWO);
		prepare stmt from @tmpthree;
		execute stmt;
		deallocate prepare stmt;

   call crm_publicaccount_recoveryreminds();

			if var_condition='or'  then
			 set @TMPSQL_ONE=concat( ' update  ld_account left join ( ',@sql,' ) as lingdangtmp  on  lingdangtmp.accountid=ld_account.accountid set ld_account.publicaccount=1 ,protectdate=null ,allocatedate=null') ;
			 if @allotaccount>0 THEN
					set @TMPSQL_ONE=concat(@TMPSQL_ONE,",smownerid=",@allotaccount);
				end if;
		   set @TMPSQL_TWO=concat(@TMPSQL_ONE,' where ld_account.deleted=0 and( ld_account.publicaccount=2 or ld_account.publicaccount=3)    ');
		   set @TMPSQL_TWO=concat(@TMPSQL_TWO, ' and lingdangtmp.accountid is null and datediff(curdate(),ld_account.allocatedate)>',@maxdays);
			ELSE
			  set @TMPSQL_ONE=concat( ' update  ld_account inner join ( ',@sql,' ) as lingdangtmp  on  lingdangtmp.accountid=ld_account.accountid set ld_account.publicaccount=1 ,protectdate=null ,allocatedate=null') ;
		    if @allotaccount>0 THEN
					set @TMPSQL_ONE=concat(@TMPSQL_ONE,",smownerid=",@allotaccount);
				end if;
		  	set @TMPSQL_TWO=concat(@TMPSQL_ONE,' where ld_account.deleted=0 and( ld_account.publicaccount=2 or ld_account.publicaccount=3)   ');
		 end if;
		prepare stmt from @TMPSQL_TWO;
		execute stmt;
		deallocate prepare stmt;

	end if;

		

end||
delimiter;

drop PROCEDURE if EXISTS execute_account_publicoperation;
delimiter ||
create PROCEDURE execute_account_publicoperation()
BEGIN
	select `status` into @status  from ld_account_set;


	if @status=0   then
		select eventdate into @eventdate from ld_sys_event where type='publicaccount' ORDER BY eventdate DESC LIMIT 1;
		if @eventdate!=CURDATE() then
			 update  ld_sys_event set eventdate=now() where type='publicaccount';
			call account_singlerecycle_normal_rule();
			call account_singlerecycle_highsea_rule();
		end if;

	end if;
end||
delimiter;
-- 2018-10-17

select tabid into @tabid from ld_tab where `name` = 'Expense';
update ld_tabdetailfield set fieldtype = 'Amount' where tabid = @tabid and columnname = 'total';
delimiter;

select sequence,roottype into @sequence,@roottype from ld_systems_deploy where deploy_type = 95;
update ld_systems_deploy set sequence = sequence + 1000 where inputtype = @roottype and sequence > @sequence;
insert into ld_systems_deploy(deploy_value,deploy_type,description,setype,sequence,roottype,inputtype,presence,inputvalue)
select '0',167,'客户服务单分配时是否发送短信或邮件通知客户首要联系人','',@sequence+1,@roottype,'select',0,'[{"value":"0","text":"NONE"},{"value":"1","text":"SMS"},{"value":"2","text":"EMAIL"},{"sql":""}]'
from dual where not exists(select 1 from ld_systems_deploy where roottype=@roottype and deploy_type=167);
set @i=0;
update ld_systems_deploy set sequence=(@i:=@i+1) where roottype = @roottype order by sequence;
delimiter;

insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'zh','ld_systems_deploy',167,167,'{$HelpDesk.HelpDesk}分配时是否发送短信或邮件通知{$Accounts.Accounts}首要联系人' from DUAL
where not exists(select 1 from ld_tranlabel where languagetype='zh' and trantable='ld_systems_deploy' and relateid=167 and tabid = 167);
insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
select 'en','ld_systems_deploy',167,167,'Do you send SMS or email to the {$Accounts.Accounts} primary contact when the customer service list is allocated?' from DUAL
where not exists(select 1 from ld_tranlabel where languagetype='en' and trantable='ld_systems_deploy' and relateid=167 and tabid = 167);
delimiter;

select actionid into @actionid from ld_actionmapping where actionname = 'Checkout';
select actionid into @actionid2 from ld_actionmapping where actionname = 'ACheckout';
select tabid into @OutboundOrder_tabid from ld_tab where `name` = 'OutboundOrder';
select tabid into @Stock_tabid from ld_tab where `name` = 'Stock';
select tabid into @CashBill_tabid from ld_tab where `name` = 'CashBill';
select tabid into @SendCashBill_tabid from ld_tab where `name` = 'SendCashBill';
delete from ld_profileallpermission where tabid in( @OutboundOrder_tabid,@Stock_tabid,@CashBill_tabid,@SendCashBill_tabid) and operation in (@actionid,@actionid2);
delete from ld_profile2standardpermissions where tabid in( @OutboundOrder_tabid,@Stock_tabid,@CashBill_tabid,@SendCashBill_tabid) and operation in (@actionid,@actionid2);
delimiter;
-- 2018-10-18


insert into ld_desk (languagetype,labelbol,fieldlabel,Labeltype)
select 'zh','allexcludinghignseas',"全部（不含公海）",'fixedstr' from DUAL
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='allexcludinghignseas' and Labeltype='fixedstr');
insert into ld_desk (languagetype,labelbol,fieldlabel,Labeltype)
select 'en','allexcludinghignseas',"All(excluding public account)",'fixedstr' from DUAL
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='allexcludinghignseas' and Labeltype='fixedstr');
delimiter;

insert into ld_desk (languagetype,labelbol,fieldlabel,Labeltype)
select 'zh','allubcludingallpublicaccount',"全部（含所有公海）",'fixedstr' from DUAL
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='allubcludingallpublicaccount' and Labeltype='fixedstr');
insert into ld_desk (languagetype,labelbol,fieldlabel,Labeltype)
select 'en','allubcludingallpublicaccount',"All (including all public account)",'fixedstr' from DUAL
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='allubcludingallpublicaccount' and Labeltype='fixedstr');
delimiter;

insert into ld_desk (languagetype,labelbol,fieldlabel,Labeltype)
select 'zh','allincludingthepublicaccount',"全部（含公海已分配）",'fixedstr' from DUAL
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='allincludingthepublicaccount' and Labeltype='fixedstr');
insert into ld_desk (languagetype,labelbol,fieldlabel,Labeltype)
select 'en','allincludingthepublicaccount',"All (including the public account)",'fixedstr' from DUAL
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='allincludingthepublicaccount' and Labeltype='fixedstr');
delimiter;

insert into ld_desk (languagetype,labelbol,fieldlabel,Labeltype)
select 'zh','allexcludinghignseas1',"全部（含公海未分配）",'fixedstr' from DUAL
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='allexcludinghignseas1' and Labeltype='fixedstr');
insert into ld_desk (languagetype,labelbol,fieldlabel,Labeltype)
select 'en','allexcludinghignseas1',"All (excluding high seas)",'fixedstr' from DUAL
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='allexcludinghignseas1' and Labeltype='fixedstr');
delimiter;

update ld_desk set fieldlabel = '公海成员{$Accounts.Accounts}序时簿页签显示为' where labelbol = 'WEHERTODISPLAYTHEPUBLICCUSTOMERES' and languagetype = 'zh' and Labeltype = 'fixedstr';
update ld_desk set fieldlabel = 'Open seas member {$Accounts.Accounts} book page is shown as' where labelbol = 'WEHERTODISPLAYTHEPUBLICCUSTOMERES' and languagetype = 'en' and Labeltype = 'fixedstr';
delimiter;

insert into ld_desk (languagetype,labelbol,fieldlabel,Labeltype)
select 'zh','alltherulesmustbedone',"（必须完成所有设定的规则才不会被回收）",'fixedstr' from DUAL
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='alltherulesmustbedone' and Labeltype='fixedstr');
insert into ld_desk (languagetype,labelbol,fieldlabel,Labeltype)
select 'en','alltherulesmustbedone',"(All the rules must be done)",'fixedstr' from DUAL
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='alltherulesmustbedone' and Labeltype='fixedstr');
delimiter;

insert into ld_desk (languagetype,labelbol,fieldlabel,Labeltype)
select 'zh','oneoftherulesmustbedone',"（只要完成一个设定的规则就不会被回收）",'fixedstr' from DUAL
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='oneoftherulesmustbedone' and Labeltype='fixedstr');
insert into ld_desk (languagetype,labelbol,fieldlabel,Labeltype)
select 'en','oneoftherulesmustbedone',"(One of the rules must be done)",'fixedstr' from DUAL
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='oneoftherulesmustbedone' and Labeltype='fixedstr');
delimiter;

UPDATE ld_desk SET fieldlabel='您启用了公海客户，需要设置回收条件' WHERE labelbol='ATLEASTONECONDITIONSENABLED' AND languagetype='zh'; 
UPDATE ld_field SET approve_demand=2 WHERE columnname='paymenttype' AND tabid=(SELECT tabid FROM ld_tab WHERE NAME='PaymentPlan');

SET @maxrelation_id=(SELECT MAX(relation_id) FROM ld_relatedlists);
SET @tabid=48;
SET @related_tabid=4;
SET @related_name='get_contacts';
SET @label='Contacts';
SET @sequence=(SELECT MAX(sequence) FROM ld_relatedlists WHERE tabid = @tabid);
SET @presence=1;
SET @actions='add,select,Import';
SET @type='crmentityrel_datacategory_sql';
SET @related_coltable='crmentityrel.crmid';

INSERT INTO ld_relatedlists(relation_id,tabid,related_tabid,`name`,sequence,label,presence,actions,related_coltable,type)
SELECT @maxrelation_id+1,@tabid,@related_tabid,@related_name,@sequence+1,@label,@presence,@actions,@related_coltable,@type FROM DUAL
WHERE NOT EXISTS(SELECT 1 FROM ld_relatedlists WHERE tabid=@tabid AND related_tabid=@related_tabid AND `name`=@related_name);

UPDATE ld_relatedlists_seq SET id=(SELECT MAX(relation_id) FROM ld_relatedlists);
delimiter;

select blockid into @blockid from ld_settings_blocks where label='LBL_OTHER_SETTINGS';
select max(sequence) into @maxsequence from ld_settings_field where blockid=@blockid;
select max(fieldid)into @maxfieldid  from ld_settings_field ;
insert into ld_settings_field(fieldid,blockid,name,iconpath,description,linkto,sequence,active)
select @maxfieldid+1,@blockid,'LBL_AUTHENINFO','','LBL_AUTHENINFO','index.php?action=isReg',@maxsequence+1,0 from dual 
where not EXISTS(select 1 from ld_settings_field where blockid=@blockid and  name='LBL_AUTHENINFO');
delimiter;

insert into ld_desk (languagetype,labelbol,fieldlabel,labeltype)
select 'en','LBL_AUTHENINFO','Authorization Information','fixedstr' from dual 
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='lbl_autheninfo' and labeltype='fixedstr');
insert into ld_desk (languagetype,labelbol,fieldlabel,labeltype)
select 'zh','LBL_AUTHENINFO','授权信息','fixedstr' from dual 
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='lbl_autheninfo' and labeltype='fixedstr');
delimiter;

select blockid into @blockid from ld_settings_blocks where label='LBI_UI_SETTINGS';
select max(sequence) into @maxsequence from ld_settings_field where blockid=@blockid;
select max(fieldid)into @maxfieldid  from ld_settings_field ;
insert into ld_settings_field(fieldid, blockid,name,iconpath,description,linkto,sequence,active)
select @maxfieldid+1, @blockid,'LBL_LOGIN_SETTINGS','','登录界面设置','index.php?module=Settings&action=LoginSettings&parenttab=Settings',@maxsequence+1,0 from dual 
where not EXISTS(select 1 from ld_settings_field where blockid=@blockid and name='LBL_LOGIN_SETTINGS');
delimiter;

insert into ld_desk (languagetype,labelbol,fieldlabel,labeltype)
select 'en','LBL_LOGIN_SETTINGS','Login setting','fixedstr' from dual 
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='LBL_LOGIN_SETTINGS' and labeltype='fixedstr');
insert into ld_desk (languagetype,labelbol,fieldlabel,labeltype)
select 'zh','LBL_LOGIN_SETTINGS','登录界面设置','fixedstr' from dual 
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='LBL_LOGIN_SETTINGS' and labeltype='fixedstr');
delimiter;

insert into ld_desk (languagetype,labelbol,fieldlabel,labeltype)
select 'zh','EDITCONTENT','修改内容','fixedstr' from dual 
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='EDITCONTENT' and labeltype='fixedstr');

insert into ld_desk (languagetype,labelbol,fieldlabel,labeltype)
select 'en','EDITCONTENT','Edit content','fixedstr' from dual 
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='EDITCONTENT' and labeltype='fixedstr');
delimiter;

insert into ld_desk (languagetype,labelbol,fieldlabel,labeltype)
select 'zh','CORRESPONDINGCONTENT','对应内容','fixedstr' from dual 
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='CORRESPONDINGCONTENT' and labeltype='fixedstr');

insert into ld_desk (languagetype,labelbol,fieldlabel,labeltype)
select 'en','CORRESPONDINGCONTENT','Corresponding content','fixedstr' from dual 
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='CORRESPONDINGCONTENT' and labeltype='fixedstr');
delimiter;

call AddColumn('ld_salesorder','imagename','varchar',200,null);
delimiter;

CALL AddColumn('ld_users','wx_openid','varchar',255,null );
insert into ld_desk (languagetype, labelbol, fieldlabel, Labeltype)
  SELECT 'zh','WECHATAPPLETHEADER','微信小程序','fixedstr' from dual
  where not exists(select 1 from ld_desk
  where labelbol='WECHATAPPLETHEADER' and Labeltype='fixedstr' and languagetype='zh');
insert into ld_desk (languagetype, labelbol, fieldlabel, Labeltype)
  SELECT 'en','WECHATAPPLETHEADER','Applet of WeChat','fixedstr' from dual
  where not exists(select 1 from ld_desk
  where labelbol='WECHATAPPLETHEADER' and Labeltype='fixedstr' and languagetype='en');

insert into ld_desk (languagetype, labelbol, fieldlabel, Labeltype)
	SELECT 'zh','WECHATAPPLETHEADERTITLE01','在微信中通过小程序使用灵当CRM，安卓手机可以将小程序添加到桌面，使用更便捷','fixedstr' from dual
	where not exists(select 1 from ld_desk
	where labelbol='WECHATAPPLETHEADERTITLE01' and Labeltype='fixedstr' and languagetype='zh');
insert into ld_desk (languagetype, labelbol, fieldlabel, Labeltype)
	SELECT 'en','WECHATAPPLETHEADERTITLE01','Using lingdang CRM via applet in WeChat, android phones can add applets to the desktop for easier use','fixedstr' from dual
	where not exists(select 1 from ld_desk
	where labelbol='WECHATAPPLETHEADERTITLE01' and Labeltype='fixedstr' and languagetype='en');

insert into ld_desk (languagetype, labelbol, fieldlabel, Labeltype)
	SELECT 'zh','WECHATAPPLETHEADERTITLE02','第一步：打开灵当CRM小程序','fixedstr' from dual
	where not exists(select 1 from ld_desk
	where labelbol='WECHATAPPLETHEADERTITLE02' and Labeltype='fixedstr' and languagetype='zh');
insert into ld_desk (languagetype, labelbol, fieldlabel, Labeltype)
	SELECT 'en','WECHATAPPLETHEADERTITLE02','Step 1: open the lingdang CRM via applet in WeChat','fixedstr' from dual
	where not exists(select 1 from ld_desk
	where labelbol='WECHATAPPLETHEADERTITLE02' and Labeltype='fixedstr' and languagetype='en');

insert into ld_desk (languagetype, labelbol, fieldlabel, Labeltype)
	SELECT 'zh','WECHATAPPLETHEADERTITLE03','第二步：绑定账号','fixedstr' from dual
	where not exists(select 1 from ld_desk
	where labelbol='WECHATAPPLETHEADERTITLE03' and Labeltype='fixedstr' and languagetype='zh');
insert into ld_desk (languagetype, labelbol, fieldlabel, Labeltype)
	SELECT 'en','WECHATAPPLETHEADERTITLE03','Step 2: bind the account','fixedstr' from dual
	where not exists(select 1 from ld_desk
	where labelbol='WECHATAPPLETHEADERTITLE03' and Labeltype='fixedstr' and languagetype='en');

insert into ld_desk (languagetype, labelbol, fieldlabel, Labeltype)
	SELECT 'zh','WECHATAPPLETHEADERTITLE04','使用微信扫一扫，打开小程序','fixedstr' from dual
	where not exists(select 1 from ld_desk
	where labelbol='WECHATAPPLETHEADERTITLE04' and Labeltype='fixedstr' and languagetype='zh');
insert into ld_desk (languagetype, labelbol, fieldlabel, Labeltype)
	SELECT 'en','WECHATAPPLETHEADERTITLE04','Using WeChat scan, open the applet','fixedstr' from dual
	where not exists(select 1 from ld_desk
	where labelbol='WECHATAPPLETHEADERTITLE04' and Labeltype='fixedstr' and languagetype='en');

insert into ld_desk (languagetype, labelbol, fieldlabel, Labeltype)
	SELECT 'zh','WECHATAPPLETHEADERTITLE05','使用灵当CRM小程序扫码绑定','fixedstr' from dual
	where not exists(select 1 from ld_desk
	where labelbol='WECHATAPPLETHEADERTITLE05' and Labeltype='fixedstr' and languagetype='zh');
insert into ld_desk (languagetype, labelbol, fieldlabel, Labeltype)
	SELECT 'en','WECHATAPPLETHEADERTITLE05','Scan the binding using the lingdang CRM applet','fixedstr' from dual
	where not exists(select 1 from ld_desk
	where labelbol='WECHATAPPLETHEADERTITLE05' and Labeltype='fixedstr' and languagetype='en');

insert into ld_desk (languagetype, labelbol, fieldlabel, Labeltype)
	SELECT 'zh','WECHATAPPLETHEADERTITLE06','您填的服务器地址不支持绑定小程序','fixedstr' from dual
	where not exists(select 1 from ld_desk
	where labelbol='WECHATAPPLETHEADERTITLE06' and Labeltype='fixedstr' and languagetype='zh');
insert into ld_desk (languagetype, labelbol, fieldlabel, Labeltype)
	SELECT 'en','WECHATAPPLETHEADERTITLE06','The server address you fill does not support binding applets','fixedstr' from dual
	where not exists(select 1 from ld_desk
	where labelbol='WECHATAPPLETHEADERTITLE06' and Labeltype='fixedstr' and languagetype='en');
-- 2018-10-19

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
update ld_producttoolfield_seq set id=(select MAX(producttoolfieldid) from ld_producttoolfield);
UPDATE ld_settings_field_seq SET id=(SELECT max(fieldid) FROM ld_settings_field);
delimiter;

update ld_version set old_version='V7.5.4',current_version='V7.5.4',remark='V7.5.4-20181018',wx_version='V7.5.4';
delimiter;