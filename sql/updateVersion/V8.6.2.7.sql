update ld_desk set fieldlabel='使用灵当工商接口' where labelbol='uselingdangbusinessinterfacekey' and languagetype='zh';
delimiter;

SET @labelbol = 'KEYWORDEXISTREENTIER';set @labeltype = 'fixedstr';
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'zh',@labelbol,'该关键字已存在，请重新输入！',@labeltype FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol=@labelbol and Labeltype=@labeltype);
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'en',@labelbol,'The keyword already exists, please re-enter!',@labeltype FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol=@labelbol and Labeltype=@labeltype);
delimiter;

ALTER TABLE ld_emailtemplates MODIFY COLUMN body longtext;
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','Relatedquerycondition','相关查询条件设置','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='Relatedquerycondition' and Labeltype='fixedstr' and languagetype='zh');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','Relatedquerycondition','Related query condition settings','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='Relatedquerycondition' and Labeltype='fixedstr' and languagetype='en');
delimiter;

set @blockid = (select blockid from ld_settings_blocks where label = 'LBI_UI_SETTINGS');
select max(fieldid) into @maxfieldid from ld_settings_field ;
select sequence into @sequence from ld_settings_field where `name` = 'LBL_LOGIN_SETTINGS';
update ld_settings_field_seq set id=@maxfieldid+1 where not exists(select 1 from ld_settings_field where  blockid=@blockid and `name`='ld_listviewview_topui_setting');
set @have = 0;
select count(fieldid) into @have from ld_settings_field where blockid=@blockid and `name`='ld_listviewview_topui_setting';
update ld_settings_field set sequence = sequence+1 where @have <= 0 and sequence >= @sequence;
insert into ld_settings_field(fieldid,blockid,`name`,description,linkto,sequence,active)
select @maxfieldid+1,@blockid,'ld_listviewview_topui_setting','ld_listviewview_topui_setting','index.php?module=Settings&action=listviewtopuisetting&mode=listview&parenttab=Settings',@sequence,0
from dual where not exists(select 1 from ld_settings_field where  blockid=@blockid and `name`='ld_listviewview_topui_setting');
delimiter;


set @blockid = (select blockid from ld_settings_blocks where label = 'LBI_UI_SETTINGS');
select max(fieldid) into @maxfieldid from ld_settings_field ;
select sequence into @sequence from ld_settings_field where `name` = 'LBL_LOGIN_SETTINGS';
update ld_settings_field_seq set id=@maxfieldid+1 where not exists(select 1 from ld_settings_field where  blockid=@blockid and `name`='ld_detailview_ui_setting');
set @have = 0;
select count(fieldid) into @have from ld_settings_field where blockid=@blockid and `name`='ld_detailview_ui_setting';
update ld_settings_field set sequence = sequence+1 where @have <= 0 and sequence >= @sequence;
insert into ld_settings_field(fieldid,blockid,`name`,description,linkto,sequence,active)
select @maxfieldid+1,@blockid,'ld_detailview_ui_setting','ld_detailview_ui_setting','index.php?module=Settings&action=detailviewuisetting&mode=listview&parenttab=Settings',@sequence,0
from dual where not exists(select 1 from ld_settings_field where  blockid=@blockid and `name`='ld_detailview_ui_setting');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','ld_listviewview_topui_setting','列表界面定制','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='ld_listviewview_topui_setting' and Labeltype='fixedstr' and languagetype='zh');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','ld_listviewview_topui_setting','List page customization','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='ld_listviewview_topui_setting' and Labeltype='fixedstr' and languagetype='en');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','ld_detailview_ui_setting','详情页界面定制','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='ld_detailview_ui_setting' and Labeltype='fixedstr' and languagetype='zh');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','ld_detailview_ui_setting','Customization of detail page interface','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='ld_detailview_ui_setting' and Labeltype='fixedstr' and languagetype='en');
delimiter;

set @deploy_type = 473;
INSERT INTO ld_systems_deploy(deploy_value,deploy_type,description,setype,sequence,roottype,inputtype,presence,inputvalue)
SELECT 1,@deploy_type,'列表界面定制','',0,'','text',0,'' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_systems_deploy WHERE deploy_type=@deploy_type);
delimiter;

set @deploy_type = 474;
INSERT INTO ld_systems_deploy(deploy_value,deploy_type,description,setype,sequence,roottype,inputtype,presence,inputvalue)
SELECT 2,@deploy_type,'详情页界面定制','',0,'','text',0,'' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_systems_deploy WHERE deploy_type=@deploy_type);
delimiter;
select tabid into @tabid from ld_tab where name='BusinessApply';

update ld_field  set bigtype='users' where fieldname='peer_persons' and tabid=@tabid;
delimiter;


insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','Areyousuretodeleteit','确定删除吗','jspop' from dual
where not exists(select 1 from ld_desk where labelbol='Areyousuretodeleteit' and Labeltype='jspop' and languagetype='zh');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','Areyousuretodeleteit','Are you sure to delete it','jspop' from dual
where not exists(select 1 from ld_desk where labelbol='Areyousuretodeleteit' and Labeltype='jspop' and languagetype='en');
delimiter;

UPDATE ld_desk set fieldlabel='登录日志' WHERE labelbol='LBL_LOGIN_HISTORY_DETAILS' and Labeltype='fixedstr' and languagetype='zh';
delimiter;
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'zh','PLEASESELECTFIELD','请选择字段','jspop' from dual
where not EXISTS(select 1 from ld_desk  where languagetype='zh' and labelbol='PLEASESELECTFIELD' and Labeltype='jspop');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'en','PLEASESELECTFIELD','Please select the field','jspop' from dual
where not EXISTS(select 1 from ld_desk  where languagetype='en' and labelbol='PLEASESELECTFIELD' and Labeltype='jspop');
delimiter;

SET @labelbol = 'AxisLabelPosition';
SET @labeltype = 'jspop';
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'zh',@labelbol,'刻度标签的位置',@labeltype FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol=@labelbol and Labeltype=@labeltype);
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'en',@labelbol,'Position of axis labels',@labeltype FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol=@labelbol and Labeltype=@labeltype);
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','POPUPPRODUCTTOTALTIP','已选 {Var} 条单据 ，共有 {Var} 条分录明细','jspop' from dual
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='POPUPPRODUCTTOTALTIP' and labeltype='jspop');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','POPUPPRODUCTTOTALTIP','{Var} documents have been selected, with a total of {Var} entry details','jspop' from dual
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='POPUPPRODUCTTOTALTIP' and labeltype='jspop');
delimiter;
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','POPUPTOTALTIP','已选 {Var} 条单据','jspop' from dual
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='POPUPTOTALTIP' and labeltype='jspop');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','POPUPTOTALTIP','{Var} documents have been selected','jspop' from dual
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='POPUPTOTALTIP' and labeltype='jspop');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','SEARCHALLRELEVANTDATA','相关信息查询所有数据','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='SEARCHALLRELEVANTDATA' and labeltype='fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','SEARCHALLRELEVANTDATA','Search all relevant data through the relevant information of','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='SEARCHALLRELEVANTDATA' and labeltype='fixedstr');
delimiter;

CALL AddColumn('ld_field','businessquery','varchar','10','no');

CALL AddColumn('ld_business_settings','fieldid','varchar','50','');

SET @tabid = (select tabid from ld_tab where `name`='Accounts');
UPDATE ld_field set businessquery = 'yes' WHERE tabid = @tabid and columnname = 'accountname';
SET @fieldid = (select fieldid from ld_field where tabid = @tabid and columnname = 'accountname');
UPDATE ld_business_settings set fieldid = @fieldid WHERE tabid = @tabid;
delimiter;

SET @tabid = (select tabid from ld_tab where `name`='ServiceCharge');
UPDATE ld_field set businessquery = 'yes' WHERE tabid = @tabid and columnname = 'accountname';
SET @fieldid = (select fieldid from ld_field where tabid = @tabid and columnname = 'accountname');
UPDATE ld_business_settings set fieldid = @fieldid WHERE tabid = @tabid;
delimiter;

SET @tabid = (select tabid from ld_tab where `name`='Vendors');
UPDATE ld_field set businessquery = 'yes' WHERE tabid = @tabid and columnname = 'vendorname';
SET @fieldid = (select fieldid from ld_field where tabid = @tabid and columnname = 'vendorname');
UPDATE ld_business_settings set fieldid = @fieldid WHERE tabid = @tabid;
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','BusinessQueryField','工商查询字段','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='BusinessQueryField' and Labeltype='fixedstr' and languagetype='zh');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','BusinessQueryField','Business query field','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='BusinessQueryField' and Labeltype='fixedstr' and languagetype='en');
delimiter;

UPDATE ld_desk set fieldlabel='启用工商查询' WHERE labelbol='ENABLEBUSINESSQUERY' and languagetype='zh';
UPDATE ld_desk set fieldlabel='Enable business inquiry' WHERE labelbol='ENABLEBUSINESSQUERY' and languagetype='en';
delimiter;

UPDATE ld_desk set fieldlabel='没有工商不允许保存' WHERE labelbol='NOBUSINESSINFOLNOTALLOWSAVE' and languagetype='zh';
UPDATE ld_desk set fieldlabel='No business is not allowed to save' WHERE labelbol='NOBUSINESSINFOLNOTALLOWSAVE' and languagetype='en';
delimiter;

UPDATE ld_desk set fieldlabel='没有工商不允许导入' WHERE labelbol='NOBUSINESSINFOLNOTALLOWIMPORT' and languagetype='zh';
UPDATE ld_desk set fieldlabel='No business is not allowed to import' WHERE labelbol='NOBUSINESSINFOLNOTALLOWIMPORT' and languagetype='en';
delimiter;

UPDATE ld_desk set fieldlabel='启用模糊查询' WHERE labelbol='ENABLEBUSINESSFUZZYQUERY' and languagetype='zh';
UPDATE ld_desk set fieldlabel='Enable Fuzzy Query' WHERE labelbol='ENABLEBUSINESSFUZZYQUERY' and languagetype='en';
delimiter;

UPDATE ld_desk set fieldlabel='启用批量回填' WHERE labelbol='ENABLEBUSINESSBATCHBACKFILLING' and languagetype='zh';
UPDATE ld_desk set fieldlabel='Enable batch backfilling' WHERE labelbol='ENABLEBUSINESSBATCHBACKFILLING' and languagetype='en';
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','SETEXCEPTION','设置例外规则','jspop' from dual
where not exists(select 1 from ld_desk where labelbol='SETEXCEPTION' and Labeltype='jspop' and languagetype='zh');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','SETEXCEPTION','Set exception rule','jspop' from dual
where not exists(select 1 from ld_desk where labelbol='SETEXCEPTION' and Labeltype='jspop' and languagetype='en');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','ConfirmToDelBusinessModule','确定要删除当前模块的工商查询功能吗？','jspop' from dual
where not exists(select 1 from ld_desk where labelbol='ConfirmToDelBusinessModule' and Labeltype='jspop' and languagetype='zh');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','ConfirmToDelBusinessModule','Are you sure you want to delete the business query function of the current module?','jspop' from dual
where not exists(select 1 from ld_desk where labelbol='ConfirmToDelBusinessModule' and Labeltype='jspop' and languagetype='en');
delimiter;

CREATE TABLE IF NOT EXISTS `ld_business_mappingfields` (
  `id` int(5) NOT NULL AUTO_INCREMENT,
  `mappingfieldlabel` varchar(50) NOT NULL,
	`mappingfieldname` varchar(50) NOT NULL,
	`sequence` tinyint(4) DEFAULT 0,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
delimiter;

INSERT INTO ld_business_mappingfields(mappingfieldlabel,mappingfieldname,sequence)
SELECT tianyanchalabel,tianyanchaname,sequence FROM ld_business_backfillfield WHERE tabid = 6
and NOT EXISTS(select 1 from ld_business_mappingfields where mappingfieldlabel='creditCode' and mappingfieldname='creditCode');
delimiter;

SET @tabid = (select tabid from ld_tab where `name`='Leads');
SET @fieldid = (select fieldid from ld_field where tabid = @tabid and columnname = 'accountname');
INSERT INTO ld_business_settings(tabid,enablebusiness,nobusinessnosave,nobusinessnoimport,enablefuzzyquery,enablebatchbackfill,nosave_exception_column,nosave_exception_group,fieldid)
SELECT @tabid,'yes','no','no','no','no','[]','[]',@fieldid FROM DUAL
where not exists(select 1 from ld_business_settings where tabid=@tabid) and EXISTS (select 1 from ld_tab where tabid=@tabid and presence = 0);
delimiter;

INSERT into ld_business_backfillfield(`tabid`,`tianyanchalabel`,`tianyanchaname`,`trancolumnname`,`defaultvalue`,`trancoltype`,`sequence`) 
SELECT @tabid,mappingfieldlabel,mappingfieldname,'',null,'',sequence FROM ld_business_mappingfields
WHERE NOT EXISTS(select 1 from ld_business_backfillfield where tabid= @tabid);
delimiter;

DROP PROCEDURE IF EXISTS `ldcrm_add_profile_for_BatchBackFilling`;
delimiter ||
CREATE PROCEDURE `ldcrm_add_profile_for_BatchBackFilling`()
BEGIN

	DECLARE done INT DEFAULT FALSE;
	DECLARE tmp_tabid int(11);
	DECLARE tmp_sequence int(19);
	
	DECLARE MYCUSOR CURSOR FOR SELECT DISTINCT ld_profileallpermission.tabid from ld_profileallpermission LEFT JOIN ld_tab ON ld_profileallpermission.tabid = ld_tab.tabid 
                                WHERE ld_tab.isentitytype = 1 and ld_profileallpermission.operation = 1 and ld_profileallpermission.tabid not IN 
                                    (SELECT tabid from ld_tab where name in ('Reminds','ChinaMap','CooperativeWork','WorkReportList','Webmails','Emails','ReportAnalysis','VisualAnalysis','ChannelCode',
                                        'Questionnaire','SocialPromotion')) ;
	DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = TRUE;
  OPEN MYCUSOR;
	SET @operation = (SELECT actionid FROM ld_actionmapping WHERE actionname='BatchBackFilling');
	read_loop: LOOP
        FETCH MYCUSOR INTO tmp_tabid;
        IF done THEN
            LEAVE read_loop;
        END IF;

        SELECT MAX(sequence) INTO tmp_sequence FROM ld_profileallpermission WHERE tabid = tmp_tabid LIMIT 1;

        IF NOT EXISTS (select 1 from ld_profileallpermission WHERE tabid = tmp_tabid and operation = @operation) THEN
            INSERT INTO ld_profileallpermission (tabid,operation,sequence) VALUES (tmp_tabid,@operation,tmp_sequence+1);
        END IF;
    END LOOP;

CLOSE MYCUSOR;
END ||
delimiter;

CALL ldcrm_add_profile_for_BatchBackFilling();
DROP PROCEDURE IF EXISTS `ldcrm_add_profile_for_BatchBackFilling`;
delimiter;

DROP PROCEDURE IF EXISTS `ldcrm_add_profile_for_default_BatchBackFilling`;
delimiter ||
CREATE PROCEDURE `ldcrm_add_profile_for_default_BatchBackFilling`(in `tmp_tabname` varchar(50) , in `tmp_actionname` varchar(200))
BEGIN

	DECLARE tmp_profileid INT(19) DEFAULT 0;

	DECLARE MYCUSOR CURSOR FOR SELECT profileid FROM ld_profile WHERE profileid>0;

DECLARE CONTINUE HANDLER FOR SQLSTATE '02000' SET tmp_profileid = NULL;

	SET @tabid=(select tabid from ld_tab  where name=`tmp_tabname`);

	set @operation = (SELECT actionid from ld_actionmapping where actionname = `tmp_actionname`);

	IF NOT EXISTS (SELECT 1 FROM ld_profile2standardpermissions WHERE tabid=@tabid and operation = @operation) AND @tabid>0 THEN
		OPEN MYCUSOR;
FETCH MYCUSOR INTO tmp_profileid;
WHILE(tmp_profileid IS NOT NULL) DO
			SET @profileid=tmp_profileid;
INSERT INTO ld_profile2standardpermissions(profileid,tabid,operation,permissions,sequence)
SELECT
    @profileid AS profileid,
    @tabid AS tabid,
    @operation,
    0,
    0
 FROM dual 
WHERE not exists(select 1 from ld_profile2standardpermissions where tabid=@tabid and operation=@operation and profileid=@profileid)
	AND @tabid>0
 LIMIT 1;

FETCH MYCUSOR INTO tmp_profileid;
END WHILE;
CLOSE MYCUSOR;
END IF;
END ||
delimiter;

CALL ldcrm_add_profile_for_default_BatchBackFilling('Leads','BatchBackFilling');
DROP PROCEDURE IF EXISTS `ldcrm_add_profile_for_default_BatchBackFilling`;
delimiter;

CREATE TABLE IF NOT EXISTS `ld_collectionslip` (
    `collectionslip_id` int(11) NOT NULL,
    `collectionslip_no` varchar(20) DEFAULT NULL,
    `accountid` Int(11) ,
    `bankaccountsetid` Int(11) ,
    `trade_time` datetime ,
    `total` decimal(25,8) ,
    `currency_id` Int(1) DEFAULT 1,
    `conversion_rate` decimal(25,6) DEFAULT 1.000000,
    `currency_symbol` Varchar(30) DEFAULT '¥',
    `remit_account_name` varchar(50) ,
    `remit_bank_account` varchar(50) ,
    `remit_bank` varchar(50) ,
    `remit_date` date ,
    `summary` Varchar(50) ,
    `description` text ,
    `createdtime` datetime ,
    `smcreatorid` Int(4),
    `smownerid` Int(4) NOT NULL,
    `trade_flow_number` varchar(20) ,
    `modifiedby` Int(4),
    `modifiedtime` datetime,
    `collectionslip_status` varchar(20),
    `collectionslip_time` datetime ,
    `sourcefrom` Varchar(20) ,
    `approvestatus` Varchar(50) DEFAULT '未提交',
    `approvetime` Datetime,
    `approveby` Int(4),
    `currentapprover` text,
    `latestpushtime` Datetime,
    `advance_stage` Varchar(100),
    `exchtime` Datetime,
    `exchmsg` text,
    `team_memberid` text,
    `tag` text,
    `print_times` int(4),
    `approvesubmitter` int(4),
    `approveurgent` Varchar(100),
    `approveexpediting` Varchar(100) ,
    `Kis_id` Int(4) ,
    `Kis_no` Varchar(50) ,
    PRIMARY KEY (`collectionslip_id`)
    ) ENGINE = INNODB DEFAULT CHARSET = utf8;
delimiter;

call AddColumn('ld_collectionslip','deleted','int',4,0);
delimiter;

CREATE TABLE IF NOT EXISTS `ld_collectionslipscf` (
    `collectionslip_id` int(11) NOT NULL,
    PRIMARY KEY (`collectionslip_id`)
    ) ENGINE = INNODB DEFAULT CHARSET = utf8;
delimiter;

CREATE TABLE IF NOT EXISTS `ld_collectionslipdetail` (
    `lineitem_id` INT(11) NOT NULL AUTO_INCREMENT ,
    `id` Int(11) DEFAULT 0,
    `entitytype` Varchar(20),
    `entitytypeid` Int(11) DEFAULT 0,
    `entitytype_value` Varchar(20) ,
    `line_project_id` Int(11) ,
    `amount` decimal(25,2) DEFAULT 0.00,
    `remark` text,
    `sequence` Int(11),
    PRIMARY KEY (`lineitem_id`)
    ) ENGINE = INNODB DEFAULT CHARSET = utf8;
delimiter;

CREATE TABLE IF NOT EXISTS `ld_collectionslipdetailscf` (
    `lineitem_id` int(11) NOT NULL DEFAULT 0,
    PRIMARY KEY (`lineitem_id`)
    ) ENGINE = INNODB DEFAULT CHARSET = utf8;
delimiter;


set @modulename='CollectionSlip';
set @tablename='ld_collectionslip';
set @detailtablename='ld_collectionslipdetail';
SELECT max(tabid) INTO @maxtabid FROM	ld_tab;
SELECT max(tabsequence) INTO @maxtabsequence FROM ld_tab ;
INSERT INTO ld_tab (
    tabid,NAME,presence,tabsequence,tablabel,parent,printtab,isduplicate
)
SELECT
        @maxtabid + 1,@modulename,0 ,@maxtabsequence + 1,@modulename,null,1,'yes'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM ld_tab WHERE NAME = @modulename);

SELECT tabid INTO @tabid FROM ld_tab WHERE NAME = @modulename;
set @blockid=(SELECT max(blockid) FROM ld_blocks) + 1;
INSERT INTO ld_blocks ( blockid,tabid,blocklabel,sequence )
SELECT @blockid,@tabid,'LBL_LABEL', 1
FROM DUAL WHERE NOT EXISTS  ( SELECT * FROM ld_blocks WHERE tabid = @tabid AND blocklabel = 'LBL_LABEL' );

set @blockid=(SELECT max(blockid) FROM ld_blocks) + 1;
INSERT INTO ld_blocks ( blockid,tabid,blocklabel,sequence )
SELECT @blockid,@tabid,'LBL_COLLECTIONSLIP_INFO', 2
FROM DUAL WHERE NOT EXISTS ( SELECT * FROM ld_blocks WHERE tabid = @tabid AND blocklabel = 'LBL_COLLECTIONSLIP_INFO');

set @blockid=(SELECT max(blockid) FROM ld_blocks) + 1;
INSERT INTO ld_blocks ( blockid,tabid,blocklabel,sequence )
SELECT  @blockid,@tabid,'LBL_COLLECTIONSLIPTRENDS_INFO', 3
FROM DUAL WHERE NOT EXISTS ( SELECT * FROM ld_blocks WHERE tabid = @tabid AND blocklabel = 'LBL_COLLECTIONSLIPTRENDS_INFO' );

update ld_blocks_seq set id=@blockid;


select deploy_value INTO @decimalplace from ld_systems_deploy where deploy_type=351;
select blockid into @blockid from ld_blocks where tabid=@tabid and blocklabel='LBL_COLLECTIONSLIP_INFO';

set @columnname='collectionslip_no';
set @fieldname='collectionslip_no';
set @zh='单据编号';
set @uitype=4;
set @bigtype='moduleno';
set @readonly=1;
set @presence=2;
set @defaultvalue=NULL;
set @displaytype=1;
set @typeofdata='V~O';
set @quickcreate=1;
set @quickcreatesequence=NULL;
set @info_type='BAS';
set @masseditable=1;
set @allowhide='yes';
select id into @seq from ld_field_seq;
select max(fieldid) into @fieldid from ld_field;
insert into ld_field(tabid,fieldid,columnname,tablename,generatedtype,uitype,bigtype,fieldname,fieldlabel,readonly,presence,defaultvalue,maximumlength,sequence,block,displaytype,typeofdata,quickcreate,quickcreatesequence,info_type,masseditable,helpinfo,fieldonly,allowhide)
select @tabid,@fieldid+1,@columnname,@tablename,1,@uitype,@bigtype,@fieldname,@zh,@readonly,@presence,@defaultvalue,100,@seq+1,@blockid,@displaytype,@typeofdata,@quickcreate,@quickcreatesequence,@info_type,@masseditable,NULL,0,@allowhide from dual
where not exists (select 1 from ld_field where tabid=@tabid and tablename=@tablename and columnname=@columnname);

set @columnname='accountid';
set @fieldname='account_id';
set @zh='客户名称';
set @uitype=73;
set @bigtype='reference';
set @readonly=0;
set @presence=2;
set @defaultvalue=NULL;
set @displaytype=1;
set @typeofdata='V~O';
set @quickcreate=1;
set @quickcreatesequence=NULL;
set @info_type='BAS';
set @masseditable=1;
set @allowhide='yes';
set @input_type='';
set @allowedit='yes';
select max(sequence) into @seq from ld_field where tabid=@tabid and block=@blockid;
select max(fieldid) into @fieldid from ld_field;
insert into ld_field(tabid,fieldid,columnname,tablename,generatedtype,uitype,bigtype,fieldname,fieldlabel,readonly,presence,defaultvalue,maximumlength,sequence,block,displaytype,typeofdata,quickcreate,quickcreatesequence,info_type,masseditable,helpinfo,fieldonly,allowhide,allowedit,input_type)
select @tabid,@fieldid+1,@columnname,@tablename,1,@uitype,@bigtype,@fieldname,@zh,@readonly,@presence,@defaultvalue,100,@seq+1,@blockid,@displaytype,@typeofdata,@quickcreate,@quickcreatesequence,@info_type,@masseditable,NULL,0,@allowhide,@allowedit,@input_type from dual
where not exists (select 1 from ld_field where tabid=@tabid and tablename=@tablename and columnname=@columnname);

set @columnname='bankaccountsetid';
set @fieldname='bankaccountsetid';
set @zh='账号';
set @uitype=251;
set @bigtype='picklistid';
set @readonly=1;
set @presence=2;
set @defaultvalue=NULL;
set @displaytype=1;
set @typeofdata='V~O';
set @quickcreate=1;
set @quickcreatesequence=NULL;
set @info_type='';
set @masseditable=1;
set @allowhide='yes';
set @fieldonly=0;
set @input_type='';
set @allowedit='yes';
select max(sequence) into @seq from ld_field where tabid=@tabid and block=@blockid;
select max(fieldid) into @fieldid from ld_field;
insert into ld_field(tabid,fieldid,columnname,tablename,generatedtype,uitype,bigtype,fieldname,fieldlabel,readonly,presence,defaultvalue,maximumlength,sequence,block,displaytype,typeofdata,quickcreate,quickcreatesequence,info_type,masseditable,helpinfo,fieldonly,allowhide,allowedit,input_type)
select @tabid,@fieldid+1,@columnname,@tablename,1,@uitype,@bigtype,@fieldname,@zh,@readonly,@presence,@defaultvalue,100,@seq+1,@blockid,@displaytype,@typeofdata,@quickcreate,@quickcreatesequence,@info_type,@masseditable,NULL,@fieldonly,@allowhide,@allowedit,@input_type from dual
where not exists (select 1 from ld_field where tabid=@tabid and tablename=@tablename and columnname=@columnname);

set @columnname='currency_id';
set @fieldname='currency_id';
set @zh='币种';
set @uitype=117;
set @bigtype='currency';
set @readonly=0;
set @presence=2;
set @defaultvalue=NULL;
set @displaytype=1;
set @typeofdata='V~O';
set @quickcreate=1;
set @quickcreatesequence=NULL;
set @info_type='BAS';
set @masseditable=1;
set @allowhide='yes';
set @fieldonly=0;
set @input_type='';
set @allowedit='yes';
select max(sequence) into @seq from ld_field where tabid=@tabid and block=@blockid;
select max(fieldid) into @fieldid from ld_field;
insert into ld_field(tabid,fieldid,columnname,tablename,generatedtype,uitype,bigtype,fieldname,fieldlabel,readonly,presence,defaultvalue,maximumlength,sequence,block,displaytype,typeofdata,quickcreate,quickcreatesequence,info_type,masseditable,helpinfo,fieldonly,allowhide,allowedit,input_type)
select @tabid,@fieldid+1,@columnname,@tablename,1,@uitype,@bigtype,@fieldname,@zh,@readonly,@presence,@defaultvalue,100,@seq+1,@blockid,@displaytype,@typeofdata,@quickcreate,@quickcreatesequence,@info_type,@masseditable,NULL,@fieldonly,@allowhide,@allowedit,@input_type from dual
where not exists (select 1 from ld_field where tabid=@tabid and tablename=@tablename and columnname=@columnname);

set @columnname='trade_flow_number';
set @fieldname='trade_flow_number';
set @zh='交易流水号';
set @uitype=1;
set @bigtype='text';
set @readonly=1;
set @presence=2;
set @defaultvalue=NULL;
set @displaytype=1;
set @typeofdata='V~M';
set @quickcreate=1;
set @quickcreatesequence=NULL;
set @info_type='BAS';
set @masseditable=1;
set @allowhide='yes';
select max(sequence) into @seq from ld_field where tabid=@tabid and block=@blockid;
select max(fieldid) into @fieldid from ld_field;
insert into ld_field(tabid,fieldid,columnname,tablename,generatedtype,uitype,bigtype,fieldname,fieldlabel,readonly,presence,defaultvalue,maximumlength,sequence,block,displaytype,typeofdata,quickcreate,quickcreatesequence,info_type,masseditable,helpinfo,fieldonly,allowhide)
select @tabid,@fieldid+1,@columnname,@tablename,1,@uitype,@bigtype,@fieldname,@zh,@readonly,@presence,@defaultvalue,100,@seq+1,@blockid,@displaytype,@typeofdata,@quickcreate,@quickcreatesequence,@info_type,@masseditable,NULL,0,@allowhide from dual
where not exists (select 1 from ld_field where tabid=@tabid and tablename=@tablename and columnname=@columnname);

set @columnname='trade_time';
set @fieldname='trade_time';
set @zh='交易时间';
set @uitype=86;
set @bigtype='datetime';
set @readonly=0;
set @presence=2;
set @defaultvalue=NULL;
set @displaytype=1;
set @typeofdata='DT~O';
set @quickcreate=1;
set @quickcreatesequence=NULL;
set @info_type='BAS';
set @masseditable=1;
set @allowhide='yes';
set @fieldonly=0;
set @input_type='';
set @allowedit='yes';
select max(sequence) into @seq from ld_field where tabid=@tabid and block=@blockid;
select max(fieldid) into @fieldid from ld_field;
insert into ld_field(tabid,fieldid,columnname,tablename,generatedtype,uitype,bigtype,fieldname,fieldlabel,readonly,presence,defaultvalue,maximumlength,sequence,block,displaytype,typeofdata,quickcreate,quickcreatesequence,info_type,masseditable,helpinfo,fieldonly,allowhide,allowedit,input_type)
select @tabid,@fieldid+1,@columnname,@tablename,1,@uitype,@bigtype,@fieldname,@zh,@readonly,@presence,@defaultvalue,100,@seq+1,@blockid,@displaytype,@typeofdata,@quickcreate,@quickcreatesequence,@info_type,@masseditable,NULL,@fieldonly,@allowhide,@allowedit,@input_type from dual
where not exists (select 1 from ld_field where tabid=@tabid and tablename=@tablename and columnname=@columnname);

set @columnname='total';
set @fieldname='total';
set @zh='收款金额';
set @uitype=71;
set @bigtype='currency';
set @readonly=0;
set @presence=2;
set @defaultvalue=NULL;
set @displaytype=1;
SET @typeofdata=concat('N~M~25,',@decimalplace);
set @quickcreate=1;
set @quickcreatesequence=NULL;
set @info_type='BAS';
set @masseditable=1;
set @allowhide='yes';
set @fieldonly=0;
set @input_type='';
set @allowedit='yes';
select max(sequence) into @seq from ld_field where tabid=@tabid and block=@blockid;
select max(fieldid) into @fieldid from ld_field;
insert into ld_field(tabid,fieldid,columnname,tablename,generatedtype,uitype,bigtype,fieldname,fieldlabel,readonly,presence,defaultvalue,maximumlength,sequence,block,displaytype,typeofdata,quickcreate,quickcreatesequence,info_type,masseditable,helpinfo,fieldonly,allowhide,allowedit,input_type)
select @tabid,@fieldid+1,@columnname,@tablename,1,@uitype,@bigtype,@fieldname,@zh,@readonly,@presence,@defaultvalue,100,@seq+1,@blockid,@displaytype,@typeofdata,@quickcreate,@quickcreatesequence,@info_type,@masseditable,NULL,@fieldonly,@allowhide,@allowedit,@input_type from dual
where not exists (select 1 from ld_field where tabid=@tabid and tablename=@tablename and columnname=@columnname);

set @columnname='remit_account_name';
set @fieldname='remit_account_name';
set @zh='汇款户名';
set @uitype=1;
set @bigtype='text';
set @readonly=0;
set @presence=2;
set @defaultvalue=NULL;
set @displaytype=1;
set @typeofdata='V~M';
set @quickcreate=1;
set @quickcreatesequence=NULL;
set @info_type='BAS';
set @masseditable=1;
set @allowhide='yes';
set @fieldonly=0;
set @input_type='';
set @allowedit='yes';
select max(sequence) into @seq from ld_field where tabid=@tabid and block=@blockid;
select max(fieldid) into @fieldid from ld_field;
insert into ld_field(tabid,fieldid,columnname,tablename,generatedtype,uitype,bigtype,fieldname,fieldlabel,readonly,presence,defaultvalue,maximumlength,sequence,block,displaytype,typeofdata,quickcreate,quickcreatesequence,info_type,masseditable,helpinfo,fieldonly,allowhide,allowedit,input_type)
select @tabid,@fieldid+1,@columnname,@tablename,1,@uitype,@bigtype,@fieldname,@zh,@readonly,@presence,@defaultvalue,100,@seq+1,@blockid,@displaytype,@typeofdata,@quickcreate,@quickcreatesequence,@info_type,@masseditable,NULL,@fieldonly,@allowhide,@allowedit,@input_type from dual
where not exists (select 1 from ld_field where tabid=@tabid and tablename=@tablename and columnname=@columnname);

set @columnname='remit_bank_account';
set @fieldname='remit_bank_account';
set @zh='汇款账号';
set @uitype=1;
set @bigtype='text';
set @readonly=0;
set @presence=2;
set @defaultvalue=NULL;
set @displaytype=1;
set @typeofdata='V~M';
set @quickcreate=1;
set @quickcreatesequence=NULL;
set @info_type='BAS';
set @masseditable=1;
set @allowhide='yes';
set @fieldonly=0;
set @input_type='';
set @allowedit='yes';
select max(sequence) into @seq from ld_field where tabid=@tabid and block=@blockid;
select max(fieldid) into @fieldid from ld_field;
insert into ld_field(tabid,fieldid,columnname,tablename,generatedtype,uitype,bigtype,fieldname,fieldlabel,readonly,presence,defaultvalue,maximumlength,sequence,block,displaytype,typeofdata,quickcreate,quickcreatesequence,info_type,masseditable,helpinfo,fieldonly,allowhide,allowedit,input_type)
select @tabid,@fieldid+1,@columnname,@tablename,1,@uitype,@bigtype,@fieldname,@zh,@readonly,@presence,@defaultvalue,100,@seq+1,@blockid,@displaytype,@typeofdata,@quickcreate,@quickcreatesequence,@info_type,@masseditable,NULL,@fieldonly,@allowhide,@allowedit,@input_type from dual
where not exists (select 1 from ld_field where tabid=@tabid and tablename=@tablename and columnname=@columnname);

set @columnname='remit_bank';
set @fieldname='remit_bank';
set @zh='汇款方开户机构';
set @uitype=1;
set @bigtype='text';
set @readonly=0;
set @presence=2;
set @defaultvalue=NULL;
set @displaytype=1;
set @typeofdata='V~M';
set @quickcreate=1;
set @quickcreatesequence=NULL;
set @info_type='BAS';
set @masseditable=1;
set @allowhide='yes';
set @fieldonly=0;
set @input_type='';
set @allowedit='yes';
select max(sequence) into @seq from ld_field where tabid=@tabid and block=@blockid;
select max(fieldid) into @fieldid from ld_field;
insert into ld_field(tabid,fieldid,columnname,tablename,generatedtype,uitype,bigtype,fieldname,fieldlabel,readonly,presence,defaultvalue,maximumlength,sequence,block,displaytype,typeofdata,quickcreate,quickcreatesequence,info_type,masseditable,helpinfo,fieldonly,allowhide,allowedit,input_type)
select @tabid,@fieldid+1,@columnname,@tablename,1,@uitype,@bigtype,@fieldname,@zh,@readonly,@presence,@defaultvalue,100,@seq+1,@blockid,@displaytype,@typeofdata,@quickcreate,@quickcreatesequence,@info_type,@masseditable,NULL,@fieldonly,@allowhide,@allowedit,@input_type from dual
where not exists (select 1 from ld_field where tabid=@tabid and tablename=@tablename and columnname=@columnname);

set @columnname='remit_date';
set @fieldname='remit_date';
set @zh='记账日期';
set @uitype=5;
set @bigtype='date';
set @readonly=0;
set @presence=2;
set @defaultvalue=NULL;
set @displaytype=1;
set @typeofdata='D~M';
set @quickcreate=1;
set @quickcreatesequence=NULL;
set @info_type='BAS';
set @masseditable=1;
set @allowhide='yes';
set @fieldonly=0;
set @input_type='';
set @allowedit='yes';
select max(sequence) into @seq from ld_field where tabid=@tabid and block=@blockid;
select max(fieldid) into @fieldid from ld_field;
insert into ld_field(tabid,fieldid,columnname,tablename,generatedtype,uitype,bigtype,fieldname,fieldlabel,readonly,presence,defaultvalue,maximumlength,sequence,block,displaytype,typeofdata,quickcreate,quickcreatesequence,info_type,masseditable,helpinfo,fieldonly,allowhide,allowedit,input_type)
select @tabid,@fieldid+1,@columnname,@tablename,1,@uitype,@bigtype,@fieldname,@zh,@readonly,@presence,@defaultvalue,100,@seq+1,@blockid,@displaytype,@typeofdata,@quickcreate,@quickcreatesequence,@info_type,@masseditable,NULL,@fieldonly,@allowhide,@allowedit,@input_type from dual
where not exists (select 1 from ld_field where tabid=@tabid and tablename=@tablename and columnname=@columnname);

set @columnname='summary';
set @fieldname='summary';
set @zh='摘要';
set @uitype=1;
set @bigtype='text';
set @readonly=0;
set @presence=2;
set @defaultvalue=NULL;
set @displaytype=1;
set @typeofdata='V~O';
set @quickcreate=1;
set @quickcreatesequence=NULL;
set @info_type='BAS';
set @masseditable=1;
set @allowhide='yes';
set @fieldonly=0;
set @input_type='';
set @allowedit='yes';
select max(sequence) into @seq from ld_field where tabid=@tabid and block=@blockid;
select max(fieldid) into @fieldid from ld_field;
insert into ld_field(tabid,fieldid,columnname,tablename,generatedtype,uitype,bigtype,fieldname,fieldlabel,readonly,presence,defaultvalue,maximumlength,sequence,block,displaytype,typeofdata,quickcreate,quickcreatesequence,info_type,masseditable,helpinfo,fieldonly,allowhide,allowedit,input_type)
select @tabid,@fieldid+1,@columnname,@tablename,1,@uitype,@bigtype,@fieldname,@zh,@readonly,@presence,@defaultvalue,100,@seq+1,@blockid,@displaytype,@typeofdata,@quickcreate,@quickcreatesequence,@info_type,@masseditable,NULL,@fieldonly,@allowhide,@allowedit,@input_type from dual
where not exists (select 1 from ld_field where tabid=@tabid and tablename=@tablename and columnname=@columnname);

set @columnname='description';
set @fieldname='description';
set @zh='备注';
set @uitype=19;
set @bigtype='textarea';
set @readonly=0;
set @presence=2;
set @defaultvalue=NULL;
set @displaytype=1;
set @typeofdata='V~O';
set @quickcreate=1;
set @quickcreatesequence=NULL;
set @info_type='BAS';
set @masseditable=1;
set @allowhide='yes';
set @fieldonly=0;
set @input_type='';
set @allowedit='yes';
select max(sequence) into @seq from ld_field where tabid=@tabid and block=@blockid;
select max(fieldid) into @fieldid from ld_field;
insert into ld_field(tabid,fieldid,columnname,tablename,generatedtype,uitype,bigtype,fieldname,fieldlabel,readonly,presence,defaultvalue,maximumlength,sequence,block,displaytype,typeofdata,quickcreate,quickcreatesequence,info_type,masseditable,helpinfo,fieldonly,allowhide,allowedit,input_type)
select @tabid,@fieldid+1,@columnname,@tablename,1,@uitype,@bigtype,@fieldname,@zh,@readonly,@presence,@defaultvalue,100,@seq+1,@blockid,@displaytype,@typeofdata,@quickcreate,@quickcreatesequence,@info_type,@masseditable,NULL,@fieldonly,@allowhide,@allowedit,@input_type from dual
where not exists (select 1 from ld_field where tabid=@tabid and tablename=@tablename and columnname=@columnname);

select blockid into @blockid from ld_blocks where tabid=@tabid and blocklabel='LBL_COLLECTIONSLIPTRENDS_INFO';

set @columnname='createdtime';
set @fieldname='createdtime';
set @zh='创建时间';
set @uitype=70;
set @bigtype='datetime';
set @readonly=1;
set @presence=2;
set @defaultvalue=NULL;
set @displaytype=2;
set @typeofdata='DT~O';
set @quickcreate=1;
set @quickcreatesequence=NULL;
set @info_type='BAS';
set @masseditable=1;
select max(sequence) into @seq from ld_field where tabid=@tabid and block=@blockid;
select max(fieldid) into @fieldid from ld_field;
insert into ld_field(tabid,fieldid,columnname,tablename,generatedtype,uitype,bigtype,fieldname,fieldlabel,readonly,presence,defaultvalue,maximumlength,sequence,block,displaytype,typeofdata,quickcreate,quickcreatesequence,info_type,masseditable,helpinfo,fieldonly)
select @tabid,@fieldid+1,@columnname,@tablename,1,@uitype,@bigtype,@fieldname,@zh,@readonly,@presence,@defaultvalue,100,@seq+1,@blockid,@displaytype,@typeofdata,@quickcreate,@quickcreatesequence,@info_type,@masseditable,NULL,0 from dual
where not exists (select 1 from ld_field where tabid=@tabid and tablename=@tablename and columnname=@columnname);

set @columnname='smcreatorid';
set @fieldname='smcreatorid';
set @zh='创建人';
set @uitype=52;
set @bigtype='users';
set @readonly=1;
set @presence=2;
set @defaultvalue=NULL;
set @displaytype=2;
set @typeofdata='V~O';
set @quickcreate=1;
set @quickcreatesequence=NULL;
set @info_type='BAS';
set @masseditable=1;
set @allowhide='yes';
select max(sequence) into @seq from ld_field where tabid=@tabid and block=@blockid;
select max(fieldid) into @fieldid from ld_field;
insert into ld_field(tabid,fieldid,columnname,tablename,generatedtype,uitype,bigtype,fieldname,fieldlabel,readonly,presence,defaultvalue,maximumlength,sequence,block,displaytype,typeofdata,quickcreate,quickcreatesequence,info_type,masseditable,helpinfo,fieldonly,allowhide)
select @tabid,@fieldid+1,@columnname,@tablename,1,@uitype,@bigtype,@fieldname,@zh,@readonly,@presence,@defaultvalue,100,@seq+1,@blockid,@displaytype,@typeofdata,@quickcreate,@quickcreatesequence,@info_type,@masseditable,NULL,0,@allowhide from dual
where not exists (select 1 from ld_field where tabid=@tabid and tablename=@tablename and columnname=@columnname);

set @columnname='smownerid';
set @fieldname='assigned_user_id';
set @zh='负责人';
set @uitype=53;
set @bigtype='users';
set @readonly=1;
set @presence=2;
set @defaultvalue=NULL;
set @displaytype=1;
set @typeofdata='V~M';
set @quickcreate=1;
set @quickcreatesequence=NULL;
set @info_type='BAS';
set @masseditable=1;
set @allowhide='no';
select max(sequence) into @seq from ld_field where tabid=@tabid and block=@blockid;
select max(fieldid) into @fieldid from ld_field;
insert into ld_field(tabid,fieldid,columnname,tablename,generatedtype,uitype,bigtype,fieldname,fieldlabel,readonly,presence,defaultvalue,maximumlength,sequence,block,displaytype,typeofdata,quickcreate,quickcreatesequence,info_type,masseditable,helpinfo,fieldonly,allowhide)
select @tabid,@fieldid+1,@columnname,@tablename,1,@uitype,@bigtype,@fieldname,@zh,@readonly,@presence,@defaultvalue,100,@seq+1,@blockid,@displaytype,@typeofdata,@quickcreate,@quickcreatesequence,@info_type,@masseditable,NULL,0,@allowhide from dual
where not exists (select 1 from ld_field where tabid=@tabid and tablename=@tablename and columnname=@columnname);

set @columnname='modifiedby';
set @fieldname='modifiedby';
set @zh='更新人';
set @uitype=52;
set @bigtype='users';
set @readonly=1;
set @presence=2;
set @defaultvalue=NULL;
set @displaytype=2;
set @typeofdata='V~O';
set @quickcreate=1;
set @quickcreatesequence=NULL;
set @info_type='BAS';
set @masseditable=1;
set @allowhide='yes';
select max(sequence) into @seq from ld_field where tabid=@tabid and block=@blockid;
select max(fieldid) into @fieldid from ld_field;
insert into ld_field(tabid,fieldid,columnname,tablename,generatedtype,uitype,bigtype,fieldname,fieldlabel,readonly,presence,defaultvalue,maximumlength,sequence,block,displaytype,typeofdata,quickcreate,quickcreatesequence,info_type,masseditable,helpinfo,fieldonly,allowhide)
select @tabid,@fieldid+1,@columnname,@tablename,1,@uitype,@bigtype,@fieldname,@zh,@readonly,@presence,@defaultvalue,100,@seq+1,@blockid,@displaytype,@typeofdata,@quickcreate,@quickcreatesequence,@info_type,@masseditable,NULL,0,@allowhide from dual
where not exists (select 1 from ld_field where tabid=@tabid and tablename=@tablename and columnname=@columnname);

set @columnname='modifiedtime';
set @fieldname='modifiedtime';
set @zh='更新时间';
set @uitype=70;
set @bigtype='datetime';
set @readonly=1;
set @presence=2;
set @defaultvalue=NULL;
set @displaytype=2;
set @typeofdata='DT~O';
set @quickcreate=1;
set @quickcreatesequence=NULL;
set @info_type='BAS';
set @masseditable=1;
select max(sequence) into @seq from ld_field where tabid=@tabid and block=@blockid;
select max(fieldid) into @fieldid from ld_field;
insert into ld_field(tabid,fieldid,columnname,tablename,generatedtype,uitype,bigtype,fieldname,fieldlabel,readonly,presence,defaultvalue,maximumlength,sequence,block,displaytype,typeofdata,quickcreate,quickcreatesequence,info_type,masseditable,helpinfo,fieldonly)
select @tabid,@fieldid+1,@columnname,@tablename,1,@uitype,@bigtype,@fieldname,@zh,@readonly,@presence,@defaultvalue,100,@seq+1,@blockid,@displaytype,@typeofdata,@quickcreate,@quickcreatesequence,@info_type,@masseditable,NULL,0 from dual
where not exists (select 1 from ld_field where tabid=@tabid and tablename=@tablename and columnname=@columnname);

set @columnname='collectionslip_status';
set @fieldname='collectionslip_status';
set @zh='收款认领单状态';
set @uitype=1;
set @bigtype='translatefield';
set @readonly=1;
set @presence=2;
set @defaultvalue=NULL;
set @displaytype=2;
set @typeofdata='V~O';
set @quickcreate=1;
set @quickcreatesequence=NULL;
set @info_type='BAS';
set @masseditable=1;
set @allowhide='yes';
set @allowedit='yes';
select max(sequence) into @seq from ld_field where tabid=@tabid and block=@blockid;
select max(fieldid) into @fieldid from ld_field;
insert into ld_field(tabid,fieldid,columnname,tablename,generatedtype,uitype,bigtype,fieldname,fieldlabel,readonly,presence,defaultvalue,maximumlength,sequence,block,displaytype,typeofdata,quickcreate,quickcreatesequence,info_type,masseditable,helpinfo,fieldonly,allowhide,allowedit)
select @tabid,@fieldid+1,@columnname,@tablename,1,@uitype,@bigtype,@fieldname,@zh,@readonly,@presence,@defaultvalue,100,@seq+1,@blockid,@displaytype,@typeofdata,@quickcreate,@quickcreatesequence,@info_type,@masseditable,NULL,0,@allowhide,@allowedit from dual
where not exists (select 1 from ld_field where tabid=@tabid and tablename=@tablename and columnname=@columnname);

set @columnname='collectionslip_time';
set @fieldname='collectionslip_time';
set @zh='领取时间';
set @uitype=70;
set @bigtype='datetime';
set @readonly=1;
set @presence=2;
set @defaultvalue=NULL;
set @displaytype=2;
set @typeofdata='DT~O';
set @quickcreate=1;
set @quickcreatesequence=NULL;
set @info_type='BAS';
set @masseditable=1;
set @allowhide='yes';
select max(sequence) into @seq from ld_field where tabid=@tabid and block=@blockid;
select max(fieldid) into @fieldid from ld_field;
insert into ld_field(tabid,fieldid,columnname,tablename,generatedtype,uitype,bigtype,fieldname,fieldlabel,readonly,presence,defaultvalue,maximumlength,sequence,block,displaytype,typeofdata,quickcreate,quickcreatesequence,info_type,masseditable,helpinfo,fieldonly,allowhide)
select @tabid,@fieldid+1,@columnname,@tablename,1,@uitype,@bigtype,@fieldname,@zh,@readonly,@presence,@defaultvalue,100,@seq+1,@blockid,@displaytype,@typeofdata,@quickcreate,@quickcreatesequence,@info_type,@masseditable,NULL,0,@allowhide from dual
where not exists (select 1 from ld_field where tabid=@tabid and tablename=@tablename and columnname=@columnname);

set @columnname='sourcefrom';
set @fieldname='sourcefrom';
set @zh='单据来源';
set @uitype=118;
set @bigtype='';
set @readonly=1;
set @presence=2;
set @defaultvalue=NULL;
set @displaytype=1;
set @typeofdata='V~O';
set @quickcreate=1;
set @quickcreatesequence=NULL;
set @info_type='BAS';
set @masseditable=1;
set @allowhide='yes';
select max(sequence) into @seq from ld_field where tabid=@tabid and block=@blockid;
select max(fieldid) into @fieldid from ld_field;
insert into ld_field(tabid,fieldid,columnname,tablename,generatedtype,uitype,bigtype,fieldname,fieldlabel,readonly,presence,defaultvalue,maximumlength,sequence,block,displaytype,typeofdata,quickcreate,quickcreatesequence,info_type,masseditable,helpinfo,fieldonly,allowhide)
select @tabid,@fieldid+1,@columnname,@tablename,1,@uitype,@bigtype,@fieldname,@zh,@readonly,@presence,@defaultvalue,100,@seq+1,@blockid,@displaytype,@typeofdata,@quickcreate,@quickcreatesequence,@info_type,@masseditable,NULL,0,@allowhide from dual
where not exists (select 1 from ld_field where tabid=@tabid and tablename=@tablename and columnname=@columnname);

set @columnname='approvestatus';
set @fieldname='approvestatus';
set @zh='审批状态';
set @uitype=609;
set @bigtype='text';
set @readonly=1;
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
insert into ld_field(tabid,fieldid,columnname,tablename,generatedtype,uitype,bigtype,fieldname,fieldlabel,readonly,presence,defaultvalue,maximumlength,sequence,block,displaytype,typeofdata,quickcreate,quickcreatesequence,info_type,masseditable,helpinfo,fieldonly)
select @tabid,@fieldid+1,@columnname,@tablename,1,@uitype,@bigtype,@fieldname,@zh,@readonly,@presence,@defaultvalue,100,@seq+1,@blockid,@displaytype,@typeofdata,@quickcreate,@quickcreatesequence,@info_type,@masseditable,NULL,0 from dual
where not exists (select 1 from ld_field where tabid=@tabid and tablename=@tablename and columnname=@columnname);

set @columnname='approvetime';
set @fieldname='approvetime';
set @zh='最新审批时间';
set @uitype=70;
set @bigtype='datetime';
set @readonly=1;
set @presence=2;
set @defaultvalue=NULL;
set @displaytype=2;
set @typeofdata='DT~O';
set @quickcreate=1;
set @quickcreatesequence=NULL;
set @info_type='BAS';
set @masseditable=1;
select max(sequence) into @seq from ld_field where tabid=@tabid and block=@blockid;
select max(fieldid) into @fieldid from ld_field;
insert into ld_field(tabid,fieldid,columnname,tablename,generatedtype,uitype,bigtype,fieldname,fieldlabel,readonly,presence,defaultvalue,maximumlength,sequence,block,displaytype,typeofdata,quickcreate,quickcreatesequence,info_type,masseditable,helpinfo,fieldonly)
select @tabid,@fieldid+1,@columnname,@tablename,1,@uitype,@bigtype,@fieldname,@zh,@readonly,@presence,@defaultvalue,100,@seq+1,@blockid,@displaytype,@typeofdata,@quickcreate,@quickcreatesequence,@info_type,@masseditable,NULL,0 from dual
where not exists (select 1 from ld_field where tabid=@tabid and tablename=@tablename and columnname=@columnname);

set @columnname='approveby';
set @fieldname='approveby';
set @zh='上一步审批人';
set @uitype=131;
set @bigtype='text';
set @readonly=1;
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
insert into ld_field(tabid,fieldid,columnname,tablename,generatedtype,uitype,bigtype,fieldname,fieldlabel,readonly,presence,defaultvalue,maximumlength,sequence,block,displaytype,typeofdata,quickcreate,quickcreatesequence,info_type,masseditable,helpinfo,fieldonly)
select @tabid,@fieldid+1,@columnname,@tablename,1,@uitype,@bigtype,@fieldname,@zh,@readonly,@presence,@defaultvalue,100,@seq+1,@blockid,@displaytype,@typeofdata,@quickcreate,@quickcreatesequence,@info_type,@masseditable,NULL,0 from dual
where not exists (select 1 from ld_field where tabid=@tabid and tablename=@tablename and columnname=@columnname);

set @columnname='currentapprover';
set @fieldname='currentapprover';
set @zh='当前审批人';
set @uitype=132;
set @bigtype='users';
set @readonly=1;
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
insert into ld_field(tabid,fieldid,columnname,tablename,generatedtype,uitype,bigtype,fieldname,fieldlabel,readonly,presence,defaultvalue,maximumlength,sequence,block,displaytype,typeofdata,quickcreate,quickcreatesequence,info_type,masseditable,helpinfo,fieldonly)
select @tabid,@fieldid+1,@columnname,@tablename,1,@uitype,@bigtype,@fieldname,@zh,@readonly,@presence,@defaultvalue,100,@seq+1,@blockid,@displaytype,@typeofdata,@quickcreate,@quickcreatesequence,@info_type,@masseditable,NULL,0 from dual
where not exists (select 1 from ld_field where tabid=@tabid and tablename=@tablename and columnname=@columnname);

set @columnname='latestpushtime';
set @fieldname='latestpushtime';
set @zh='最新推进时间';
set @uitype=86;
set @bigtype='datetime';
set @readonly=1;
set @presence=2;
set @defaultvalue=NULL;
set @displaytype=2;
set @typeofdata='DT~O';
set @quickcreate=1;
set @quickcreatesequence=NULL;
set @info_type='BAS';
set @masseditable=1;
select max(sequence) into @seq from ld_field where tabid=@tabid and block=@blockid;
select max(fieldid) into @fieldid from ld_field;
insert into ld_field(tabid,fieldid,columnname,tablename,generatedtype,uitype,bigtype,fieldname,fieldlabel,readonly,presence,defaultvalue,maximumlength,sequence,block,displaytype,typeofdata,quickcreate,quickcreatesequence,info_type,masseditable,helpinfo,fieldonly)
select @tabid,@fieldid+1,@columnname,@tablename,1,@uitype,@bigtype,@fieldname,@zh,@readonly,@presence,@defaultvalue,100,@seq+1,@blockid,@displaytype,@typeofdata,@quickcreate,@quickcreatesequence,@info_type,@masseditable,NULL,0 from dual
where not exists (select 1 from ld_field where tabid=@tabid and tablename=@tablename and columnname=@columnname);

set @columnname='advance_stage';
set @fieldname='advance_stage';
set @zh='推进阶段';
set @uitype=1;
set @bigtype='text';
set @readonly=1;
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
insert into ld_field(tabid,fieldid,columnname,tablename,generatedtype,uitype,bigtype,fieldname,fieldlabel,readonly,presence,defaultvalue,maximumlength,sequence,block,displaytype,typeofdata,quickcreate,quickcreatesequence,info_type,masseditable,helpinfo,fieldonly)
select @tabid,@fieldid+1,@columnname,@tablename,1,@uitype,@bigtype,@fieldname,@zh,@readonly,@presence,@defaultvalue,100,@seq+1,@blockid,@displaytype,@typeofdata,@quickcreate,@quickcreatesequence,@info_type,@masseditable,NULL,0 from dual
where not exists (select 1 from ld_field where tabid=@tabid and tablename=@tablename and columnname=@columnname);

set @columnname='exchtime';
set @fieldname='exchtime';
set @zh='最新同步时间';
set @uitype=86;
set @bigtype='datetime';
set @readonly=1;
set @presence=2;
set @defaultvalue=NULL;
set @displaytype=2;
set @typeofdata='DT~O';
set @quickcreate=1;
set @quickcreatesequence=NULL;
set @info_type='BAS';
set @masseditable=1;
select max(sequence) into @seq from ld_field where tabid=@tabid and block=@blockid;
select max(fieldid) into @fieldid from ld_field;
insert into ld_field(tabid,fieldid,columnname,tablename,generatedtype,uitype,bigtype,fieldname,fieldlabel,readonly,presence,defaultvalue,maximumlength,sequence,block,displaytype,typeofdata,quickcreate,quickcreatesequence,info_type,masseditable,helpinfo,fieldonly)
select @tabid,@fieldid+1,@columnname,@tablename,1,@uitype,@bigtype,@fieldname,@zh,@readonly,@presence,@defaultvalue,100,@seq+1,@blockid,@displaytype,@typeofdata,@quickcreate,@quickcreatesequence,@info_type,@masseditable,NULL,0 from dual
where not exists (select 1 from ld_field where tabid=@tabid and tablename=@tablename and columnname=@columnname);

set @columnname='exchmsg';
set @fieldname='exchmsg';
set @zh='最新同步结果';
set @uitype=86;
set @bigtype='datetime';
set @readonly=1;
set @presence=2;
set @defaultvalue=NULL;
set @displaytype=2;
set @typeofdata='DT~O';
set @quickcreate=1;
set @quickcreatesequence=NULL;
set @info_type='BAS';
set @masseditable=1;
select max(sequence) into @seq from ld_field where tabid=@tabid and block=@blockid;
select max(fieldid) into @fieldid from ld_field;
insert into ld_field(tabid,fieldid,columnname,tablename,generatedtype,uitype,bigtype,fieldname,fieldlabel,readonly,presence,defaultvalue,maximumlength,sequence,block,displaytype,typeofdata,quickcreate,quickcreatesequence,info_type,masseditable,helpinfo,fieldonly)
select @tabid,@fieldid+1,@columnname,@tablename,1,@uitype,@bigtype,@fieldname,@zh,@readonly,@presence,@defaultvalue,100,@seq+1,@blockid,@displaytype,@typeofdata,@quickcreate,@quickcreatesequence,@info_type,@masseditable,NULL,0 from dual
where not exists (select 1 from ld_field where tabid=@tabid and tablename=@tablename and columnname=@columnname);

set @columnname='team_memberid';
set @fieldname='team_memberid';
set @zh='团队成员';
set @uitype=154;
set @bigtype='text';
set @readonly=1;
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
insert into ld_field(tabid,fieldid,columnname,tablename,generatedtype,uitype,bigtype,fieldname,fieldlabel,readonly,presence,defaultvalue,maximumlength,sequence,block,displaytype,typeofdata,quickcreate,quickcreatesequence,info_type,masseditable,helpinfo,fieldonly)
select @tabid,@fieldid+1,@columnname,@tablename,1,@uitype,@bigtype,@fieldname,@zh,@readonly,@presence,@defaultvalue,100,@seq+1,@blockid,@displaytype,@typeofdata,@quickcreate,@quickcreatesequence,@info_type,@masseditable,NULL,0 from dual
where not exists (select 1 from ld_field where tabid=@tabid and tablename=@tablename and columnname=@columnname);

set @columnname='tag';
set @fieldname='tag';
set @zh='标签';
set @uitype=301;
set @bigtype='text';
set @readonly=1;
set @presence=2;
set @defaultvalue=NULL;
set @displaytype=1;
set @typeofdata='V~O';
set @quickcreate=1;
set @quickcreatesequence=NULL;
set @info_type='BAS';
set @masseditable=1;
select max(sequence) into @seq from ld_field where tabid=@tabid and block=@blockid;
select max(fieldid) into @fieldid from ld_field;
insert into ld_field(tabid,fieldid,columnname,tablename,generatedtype,uitype,bigtype,fieldname,fieldlabel,readonly,presence,defaultvalue,maximumlength,sequence,block,displaytype,typeofdata,quickcreate,quickcreatesequence,info_type,masseditable,helpinfo,fieldonly)
select @tabid,@fieldid+1,@columnname,@tablename,1,@uitype,@bigtype,@fieldname,@zh,@readonly,@presence,@defaultvalue,100,@seq+1,@blockid,@displaytype,@typeofdata,@quickcreate,@quickcreatesequence,@info_type,@masseditable,NULL,0 from dual
where not exists (select 1 from ld_field where tabid=@tabid and tablename=@tablename and columnname=@columnname);

set @columnname='print_times';
set @fieldname='print_times';
set @zh='打印次数';
set @uitype=1;
set @bigtype='text';
set @readonly=1;
set @presence=2;
set @defaultvalue=NULL;
set @displaytype=2;
set @typeofdata='N~O';
set @quickcreate=1;
set @quickcreatesequence=NULL;
set @info_type='BAS';
set @masseditable=1;
select max(sequence) into @seq from ld_field where tabid=@tabid and block=@blockid;
select max(fieldid) into @fieldid from ld_field;
insert into ld_field(tabid,fieldid,columnname,tablename,generatedtype,uitype,bigtype,fieldname,fieldlabel,readonly,presence,defaultvalue,maximumlength,sequence,block,displaytype,typeofdata,quickcreate,quickcreatesequence,info_type,masseditable,helpinfo,fieldonly)
select @tabid,@fieldid+1,@columnname,@tablename,1,@uitype,@bigtype,@fieldname,@zh,@readonly,@presence,@defaultvalue,100,@seq+1,@blockid,@displaytype,@typeofdata,@quickcreate,@quickcreatesequence,@info_type,@masseditable,NULL,0 from dual
where not exists (select 1 from ld_field where tabid=@tabid and tablename=@tablename and columnname=@columnname);

set @columnname='approveby';
set @fieldname='approveby';
set @zh='上一步审批人';
set @uitype=52;
set @bigtype='users';
set @readonly=1;
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
insert into ld_field(tabid,fieldid,columnname,tablename,generatedtype,uitype,bigtype,fieldname,fieldlabel,readonly,presence,defaultvalue,maximumlength,sequence,block,displaytype,typeofdata,quickcreate,quickcreatesequence,info_type,masseditable,helpinfo,fieldonly)
select @tabid,@fieldid+1,@columnname,@tablename,1,@uitype,@bigtype,@fieldname,@zh,@readonly,@presence,@defaultvalue,100,@seq+1,@blockid,@displaytype,@typeofdata,@quickcreate,@quickcreatesequence,@info_type,@masseditable,NULL,0 from dual
where not exists (select 1 from ld_field where tabid=@tabid and tablename=@tablename and columnname=@columnname);

update ld_field_seq set id=@seq;

-- 分录表字段
SET @tabdetailfieldid=(SELECT MAX(tabdetailfieldid)+1 FROM ld_tabdetailfield);
SET @columnname = 'entitytype';
SET @allowhide = 'no';
SET @fieldlabel = '合同类型';
SET @fieldtype = 'entitytype';
SET @typeofdata='V~O';
SET @bigtype='';
SET @parentbigtype='';
SET @sequence = (SELECT IFNULL(MAX(sequence),1) FROM ld_tabdetailfield where tabid=@tabid);
SET @sourcemodule = 'SalesOrder';
INSERT INTO ld_tabdetailfield(tabdetailfieldid,columnname,allowhide,fieldlabel,defaultvalue,presence,fieldtype,typeofdata,sequence,tabid,tablename,width,edit_permission,input_type,fieldid,newline,defaultcolumn,is_checkimportfield,nullfield,referencemodule,datarange,approve_demand,maxrowsshow,bigtype,savedatabase,parentbigtype,sourcemodule)
SELECT @tabdetailfieldid,@columnname,@allowhide,@fieldlabel,NULL,0,@fieldtype,@typeofdata,@sequence+1,@tabid,@detailtablename,22,0,0,0,0,1,0,1,'','','',0,@bigtype,'yes',@parentbigtype,@sourcemodule from dual
WHERE NOT EXISTS (SELECT 1 FROM ld_tabdetailfield WHERE tabid=@tabid AND columnname=@columnname and tablename=@detailtablename and sourcemodule=@sourcemodule);

SET @tabdetailfieldid=(SELECT MAX(tabdetailfieldid)+1 FROM ld_tabdetailfield);
SET @columnname = 'entitytypeid';
SET @allowhide = 'no';
SET @fieldlabel = '合同';
SET @zh='合同';
SET @en='Orignal Bill';
SET @fieldtype = 'SelectSource';
SET @typeofdata='V~O';
SET @bigtype='selectsource';
SET @parentbigtype='';
SET @sequence = (SELECT IFNULL(MAX(sequence),1) FROM ld_tabdetailfield where tabid=@tabid);
SET @sourcemodule = 'SalesOrder';
INSERT INTO ld_tabdetailfield(tabdetailfieldid,columnname,allowhide,fieldlabel,defaultvalue,presence,fieldtype,typeofdata,sequence,tabid,tablename,width,edit_permission,input_type,fieldid,newline,defaultcolumn,is_checkimportfield,nullfield,referencemodule,datarange,approve_demand,maxrowsshow,bigtype,savedatabase,parentbigtype,sourcemodule)
SELECT @tabdetailfieldid,@columnname,@allowhide,@fieldlabel,NULL,0,@fieldtype,@typeofdata,@sequence+1,@tabid,@detailtablename,22,0,0,0,0,1,0,1,'','','',0,@bigtype,'yes',@parentbigtype,@sourcemodule from dual
WHERE NOT EXISTS (SELECT 1 FROM ld_tabdetailfield WHERE tabid=@tabid AND columnname=@columnname and tablename=@detailtablename and sourcemodule=@sourcemodule);

SET @tabdetailfieldid=(SELECT MAX(tabdetailfieldid)+1 FROM ld_tabdetailfield);
SET @columnname = 'line_project_id';
SET @allowhide = 'yes';
SET @fieldlabel = '项目';
SET @fieldtype = 'Reference';
SET @typeofdata='V~O';
SET @bigtype='reference';
SET @parentbigtype='';
SET @sequence = (SELECT IFNULL(MAX(sequence),1) FROM ld_tabdetailfield where tabid=@tabid);
SET @referencemodule = 'Project';
INSERT INTO ld_tabdetailfield(tabdetailfieldid,columnname,allowhide,fieldlabel,defaultvalue,presence,fieldtype,typeofdata,sequence,tabid,tablename,width,edit_permission,input_type,fieldid,newline,defaultcolumn,is_checkimportfield,nullfield,referencemodule,datarange,approve_demand,maxrowsshow,bigtype,savedatabase,parentbigtype,sourcemodule)
SELECT @tabdetailfieldid,@columnname,@allowhide,@fieldlabel,NULL,0,@fieldtype,@typeofdata,@sequence+1,@tabid,@detailtablename,22,0,0,0,0,1,0,1,@referencemodule,'','',0,@bigtype,'yes',@parentbigtype,@sourcemodule from dual
WHERE NOT EXISTS (SELECT 1 FROM ld_tabdetailfield WHERE tabid=@tabid AND columnname=@columnname and tablename=@detailtablename and sourcemodule=@sourcemodule);

SET @tabdetailfieldid=(SELECT MAX(tabdetailfieldid)+1 FROM ld_tabdetailfield);
SET @columnname = 'amount';
SET @allowhide = 'no';
SET @fieldlabel = '金额';
SET @fieldtype = 'Amount';
SET @typeofdata=concat('N~O~25,',@decimalplace);
SET @bigtype='';
SET @parentbigtype='';
SET @sequence = (SELECT IFNULL(MAX(sequence),1) FROM ld_tabdetailfield where tabid=@tabid);
SET @referencemodule = '';
INSERT INTO ld_tabdetailfield(tabdetailfieldid,columnname,allowhide,fieldlabel,defaultvalue,presence,fieldtype,typeofdata,sequence,tabid,tablename,width,edit_permission,input_type,fieldid,newline,defaultcolumn,is_checkimportfield,nullfield,referencemodule,datarange,approve_demand,maxrowsshow,bigtype,savedatabase,parentbigtype,sourcemodule,subtotal_attr)
SELECT @tabdetailfieldid,@columnname,@allowhide,@fieldlabel,NULL,0,@fieldtype,@typeofdata,@sequence+1,@tabid,@detailtablename,22,0,0,0,0,1,0,1,@referencemodule,'','',0,@bigtype,'yes',@parentbigtype,@sourcemodule,'yes' from dual
WHERE NOT EXISTS (SELECT 1 FROM ld_tabdetailfield WHERE tabid=@tabid AND columnname=@columnname and tablename=@detailtablename and sourcemodule=@sourcemodule);

SET @tabdetailfieldid=(SELECT MAX(tabdetailfieldid)+1 FROM ld_tabdetailfield);
SET @columnname = 'remark';
SET @allowhide = 'no';
SET @fieldlabel = '备注';
SET @fieldtype = 'TextArea';
SET @typeofdata='V~O';
SET @bigtype='';
SET @parentbigtype='';
SET @sequence = (SELECT IFNULL(MAX(sequence),1) FROM ld_tabdetailfield where tabid=@tabid);
SET @referencemodule = '';
INSERT INTO ld_tabdetailfield(tabdetailfieldid,columnname,allowhide,fieldlabel,defaultvalue,presence,fieldtype,typeofdata,sequence,tabid,tablename,width,edit_permission,input_type,fieldid,newline,defaultcolumn,is_checkimportfield,nullfield,referencemodule,datarange,approve_demand,maxrowsshow,bigtype,savedatabase,parentbigtype,sourcemodule)
SELECT @tabdetailfieldid,@columnname,@allowhide,@fieldlabel,NULL,0,@fieldtype,@typeofdata,@sequence+1,@tabid,@detailtablename,22,0,0,0,0,1,0,1,@referencemodule,'','',0,@bigtype,'yes',@parentbigtype,@sourcemodule from dual
WHERE NOT EXISTS (SELECT 1 FROM ld_tabdetailfield WHERE tabid=@tabid AND columnname=@columnname and tablename=@detailtablename and sourcemodule=@sourcemodule);

UPDATE ld_tabdetailfield_seq SET id=(SELECT MAX(tabdetailfieldid) FROM ld_tabdetailfield);

insert into ld_translatefield(columnname,module,column_Dbvalue,labelbol)
select 'collectionslip_status','CollectionSlip','uncollected','UNCOLLECTED' from dual
where not exists(select 1 from ld_translatefield where module='CollectionSlip' and columnname='collectionslip_status' and column_Dbvalue='uncollected');
delimiter;
insert into ld_translatefield(columnname,module,column_Dbvalue,labelbol)
select 'collectionslip_status','CollectionSlip','automatch','AUTOMATCH' from dual
where not exists(select 1 from ld_translatefield where module='CollectionSlip' and columnname='collectionslip_status' and column_Dbvalue='automatch');
delimiter;
insert into ld_translatefield(columnname,module,column_Dbvalue,labelbol)
select 'collectionslip_status','CollectionSlip','collected','COLLECTED' from dual
where not exists(select 1 from ld_translatefield where module='CollectionSlip' and columnname='collectionslip_status' and column_Dbvalue='collected');
delimiter;
insert into ld_translatefield(columnname,module,column_Dbvalue,labelbol)
select 'collectionslip_status','CollectionSlip','havecashbill','GENERATEDCASHBILL' from dual
where not exists(select 1 from ld_translatefield where module='CollectionSlip' and columnname='collectionslip_status' and column_Dbvalue='havecashbill');
delimiter;


SET @option_tabid=22;
SET @presence=0;
SET @isdefault=1;
SET @approve_demand=0;
INSERT INTO ld_option_module(tabid,option_tabid,presence,`default`,approve_demand,datarang,maxrowsshow,withdetail,withbalanceqtycondition)
SELECT @tabid,@option_tabid,@presence,@isdefault,@approve_demand,'permit',20,'yes',0 FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_option_module WHERE tabid=@tabid AND option_tabid=@option_tabid);

SET @option_tabid=37;
SET @presence=0;
SET @isdefault=0;
SET @approve_demand=0;
INSERT INTO ld_option_module(tabid,option_tabid,presence,`default`,approve_demand,datarang,maxrowsshow,withdetail,withbalanceqtycondition)
SELECT @tabid,@option_tabid,@presence,@isdefault,@approve_demand,'permit',20,'yes',0 FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_option_module WHERE tabid=@tabid AND option_tabid=@option_tabid);

INSERT INTO ld_tranlabel (
    languagetype,trantable,tabid,relateid,fieldlabel)
SELECT
    'zh','ld_tab' ,@tabid ,@tabid,'收款认领单'
FROM DUAL WHERE NOT EXISTS (
        SELECT 1 FROM ld_tranlabel WHERE tabid =@tabid
                                     AND relateid =@tabid
                                     AND languagetype = 'zh'
                                     AND trantable = 'ld_tab'
    );

INSERT INTO ld_tranlabel (
    languagetype,trantable,tabid,relateid,fieldlabel)
SELECT
    'en','ld_tab' ,@tabid ,@tabid,'Collection Slip'
FROM DUAL WHERE NOT EXISTS (
        SELECT 1 FROM ld_tranlabel WHERE tabid =@tabid
                                     AND relateid =@tabid
                                     AND languagetype = 'en'
                                     AND trantable = 'ld_tab'
    );

set @blockid = (SELECT  blockid from ld_blocks where tabid = @tabid and blocklabel='LBL_LABEL');
INSERT INTO `ld_tranlabel`(`languagetype`, `trantable`, `tabid`, `Relateid`, `fieldlabel`)
select 'zh', 'ld_blocks', @tabid, @blockid, '标签' from dual where not exists
    (select 1 from ld_tranlabel where  tabid =@tabid and languagetype ='zh' and Relateid=@blockid);
INSERT INTO `ld_tranlabel`( `languagetype`, `trantable`, `tabid`, `Relateid`, `fieldlabel`)
select  'en', 'ld_blocks', @tabid, @blockid, 'Tag' from dual where not exists
    (select 1 from ld_tranlabel where  tabid =@tabid and languagetype ='en' and Relateid=@blockid);

set @blockid = (SELECT  blockid from ld_blocks where tabid = @tabid and blocklabel='LBL_COLLECTIONSLIP_INFO');
INSERT INTO `ld_tranlabel`(`languagetype`, `trantable`, `tabid`, `Relateid`, `fieldlabel`)
select 'zh', 'ld_blocks', @tabid, @blockid, '基本信息' from dual where not exists
    (select 1 from ld_tranlabel where  tabid =@tabid and languagetype ='zh' and Relateid=@blockid);
INSERT INTO `ld_tranlabel`( `languagetype`, `trantable`, `tabid`, `Relateid`, `fieldlabel`)
select  'en', 'ld_blocks', @tabid, @blockid, 'Basic Information' from dual where not exists
    (select 1 from ld_tranlabel where  tabid =@tabid and languagetype ='en' and Relateid=@blockid);

set @blockid = (SELECT  blockid from ld_blocks where tabid = @tabid and blocklabel='LBL_COLLECTIONSLIPTRENDS_INFO');
INSERT INTO `ld_tranlabel`(`languagetype`, `trantable`, `tabid`, `Relateid`, `fieldlabel`)
select 'zh', 'ld_blocks', @tabid, @blockid, '动态信息' from dual where not exists
    (select 1 from ld_tranlabel where  tabid =@tabid and languagetype ='zh' and Relateid=@blockid);
INSERT INTO `ld_tranlabel`( `languagetype`, `trantable`, `tabid`, `Relateid`, `fieldlabel`)
select  'en', 'ld_blocks', @tabid, @blockid, 'Dynamic Information' from dual where not exists
    (select 1 from ld_tranlabel where  tabid =@tabid and languagetype ='en' and Relateid=@blockid);

SET @relateid=(SELECT fieldid FROM ld_field WHERE tabid=@tabid AND columnname='collectionslip_no' LIMIT 1);
SET @trantable='ld_field';
SET @zh='单据编号';
SET @en='Collection Slip No';
INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
SELECT 'zh',@trantable,@tabid,@relateid,@zh FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE languagetype = 'zh' AND trantable =@trantable AND tabid = @tabid AND relateid=@relateid);
INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
SELECT 'en',@trantable,@tabid,@relateid,@en FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE languagetype = 'en' AND trantable =@trantable AND tabid = @tabid AND relateid=@relateid);

SET @relateid=(SELECT fieldid FROM ld_field WHERE tabid=@tabid AND columnname='accountid' LIMIT 1);
SET @trantable='ld_field';
SET @zh='客户名称';
SET @en='Customer name';
INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
SELECT 'zh',@trantable,@tabid,@relateid,@zh FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE languagetype = 'zh' AND trantable =@trantable AND tabid = @tabid AND relateid=@relateid);
INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
SELECT 'en',@trantable,@tabid,@relateid,@en FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE languagetype = 'en' AND trantable =@trantable AND tabid = @tabid AND relateid=@relateid);

SET @relateid=(SELECT fieldid FROM ld_field WHERE tabid=@tabid AND columnname='bankaccountsetid' LIMIT 1);
SET @trantable='ld_field';
SET @zh='账户';
SET @en='Bank account';
INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
SELECT 'zh',@trantable,@tabid,@relateid,@zh FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE languagetype = 'zh' AND trantable =@trantable AND tabid = @tabid AND relateid=@relateid);
INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
SELECT 'en',@trantable,@tabid,@relateid,@en FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE languagetype = 'en' AND trantable =@trantable AND tabid = @tabid AND relateid=@relateid);

SET @relateid=(SELECT fieldid FROM ld_field WHERE tabid=@tabid AND columnname='trade_time' LIMIT 1);
SET @trantable='ld_field';
SET @zh='交易时间';
SET @en='Trading time';
INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
SELECT 'zh',@trantable,@tabid,@relateid,@zh FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE languagetype = 'zh' AND trantable =@trantable AND tabid = @tabid AND relateid=@relateid);
INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
SELECT 'en',@trantable,@tabid,@relateid,@en FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE languagetype = 'en' AND trantable =@trantable AND tabid = @tabid AND relateid=@relateid);

SET @relateid=(SELECT fieldid FROM ld_field WHERE tabid=@tabid AND columnname='total' LIMIT 1);
SET @trantable='ld_field';
SET @zh='收款金额';
SET @en='Amount';
INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
SELECT 'zh',@trantable,@tabid,@relateid,@zh FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE languagetype = 'zh' AND trantable =@trantable AND tabid = @tabid AND relateid=@relateid);
INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
SELECT 'en',@trantable,@tabid,@relateid,@en FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE languagetype = 'en' AND trantable =@trantable AND tabid = @tabid AND relateid=@relateid);

SET @relateid=(SELECT fieldid FROM ld_field WHERE tabid=@tabid AND columnname='currency_id' LIMIT 1);
SET @trantable='ld_field';
SET @zh='币种';
SET @en='Currency';
INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
SELECT 'zh',@trantable,@tabid,@relateid,@zh FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE languagetype = 'zh' AND trantable =@trantable AND tabid = @tabid AND relateid=@relateid);
INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
SELECT 'en',@trantable,@tabid,@relateid,@en FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE languagetype = 'en' AND trantable =@trantable AND tabid = @tabid AND relateid=@relateid);

SET @relateid=(SELECT fieldid FROM ld_field WHERE tabid=@tabid AND columnname='remit_account_name' LIMIT 1);
SET @trantable='ld_field';
SET @zh='汇款户名';
SET @en='Remittance account name';
INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
SELECT 'zh',@trantable,@tabid,@relateid,@zh FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE languagetype = 'zh' AND trantable =@trantable AND tabid = @tabid AND relateid=@relateid);
INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
SELECT 'en',@trantable,@tabid,@relateid,@en FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE languagetype = 'en' AND trantable =@trantable AND tabid = @tabid AND relateid=@relateid);

SET @relateid=(SELECT fieldid FROM ld_field WHERE tabid=@tabid AND columnname='remit_bank_account' LIMIT 1);
SET @trantable='ld_field';
SET @zh='汇款账号';
SET @en='Remittance bank account';
INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
SELECT 'zh',@trantable,@tabid,@relateid,@zh FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE languagetype = 'zh' AND trantable =@trantable AND tabid = @tabid AND relateid=@relateid);
INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
SELECT 'en',@trantable,@tabid,@relateid,@en FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE languagetype = 'en' AND trantable =@trantable AND tabid = @tabid AND relateid=@relateid);

SET @relateid=(SELECT fieldid FROM ld_field WHERE tabid=@tabid AND columnname='remit_bank' LIMIT 1);
SET @trantable='ld_field';
SET @zh='汇款方开户机构';
SET @en='The bank that remits money';
INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
SELECT 'zh',@trantable,@tabid,@relateid,@zh FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE languagetype = 'zh' AND trantable =@trantable AND tabid = @tabid AND relateid=@relateid);
INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
SELECT 'en',@trantable,@tabid,@relateid,@en FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE languagetype = 'en' AND trantable =@trantable AND tabid = @tabid AND relateid=@relateid);

SET @relateid=(SELECT fieldid FROM ld_field WHERE tabid=@tabid AND columnname='remit_date' LIMIT 1);
SET @trantable='ld_field';
SET @zh='记账日期';
SET @en='Accounting date';
INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
SELECT 'zh',@trantable,@tabid,@relateid,@zh FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE languagetype = 'zh' AND trantable =@trantable AND tabid = @tabid AND relateid=@relateid);
INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
SELECT 'en',@trantable,@tabid,@relateid,@en FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE languagetype = 'en' AND trantable =@trantable AND tabid = @tabid AND relateid=@relateid);

SET @relateid=(SELECT fieldid FROM ld_field WHERE tabid=@tabid AND columnname='summary' LIMIT 1);
SET @trantable='ld_field';
SET @zh='摘要';
SET @en='Summary';
INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
SELECT 'zh',@trantable,@tabid,@relateid,@zh FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE languagetype = 'zh' AND trantable =@trantable AND tabid = @tabid AND relateid=@relateid);
INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
SELECT 'en',@trantable,@tabid,@relateid,@en FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE languagetype = 'en' AND trantable =@trantable AND tabid = @tabid AND relateid=@relateid);

SET @relateid=(SELECT fieldid FROM ld_field WHERE tabid=@tabid AND columnname='description' LIMIT 1);
SET @trantable='ld_field';
SET @zh='备注';
SET @en='Description';
INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
SELECT 'zh',@trantable,@tabid,@relateid,@zh FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE languagetype = 'zh' AND trantable =@trantable AND tabid = @tabid AND relateid=@relateid);
INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
SELECT 'en',@trantable,@tabid,@relateid,@en FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE languagetype = 'en' AND trantable =@trantable AND tabid = @tabid AND relateid=@relateid);

SET @relateid=(SELECT fieldid FROM ld_field WHERE tabid=@tabid AND columnname='trade_flow_number' LIMIT 1);
SET @trantable='ld_field';
SET @zh='交易流水号';
SET @en='Transaction flow number';
INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
SELECT 'zh',@trantable,@tabid,@relateid,@zh FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE languagetype = 'zh' AND trantable =@trantable AND tabid = @tabid AND relateid=@relateid);
INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
SELECT 'en',@trantable,@tabid,@relateid,@en FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE languagetype = 'en' AND trantable =@trantable AND tabid = @tabid AND relateid=@relateid);

SET @relateid=(SELECT fieldid FROM ld_field WHERE tabid=@tabid AND columnname='collectionslip_status' LIMIT 1);
SET @trantable='ld_field';
SET @zh='收款认领单状态';
SET @en='Collect status';
INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
SELECT 'zh',@trantable,@tabid,@relateid,@zh FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE languagetype = 'zh' AND trantable =@trantable AND tabid = @tabid AND relateid=@relateid);
INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
SELECT 'en',@trantable,@tabid,@relateid,@en FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE languagetype = 'en' AND trantable =@trantable AND tabid = @tabid AND relateid=@relateid);

SET @relateid=(SELECT fieldid FROM ld_field WHERE tabid=@tabid AND columnname='collectionslip_time' LIMIT 1);
SET @trantable='ld_field';
SET @zh='领取事件';
SET @en='Collect time';
INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
SELECT 'zh',@trantable,@tabid,@relateid,@zh FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE languagetype = 'zh' AND trantable =@trantable AND tabid = @tabid AND relateid=@relateid);
INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
SELECT 'en',@trantable,@tabid,@relateid,@en FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE languagetype = 'en' AND trantable =@trantable AND tabid = @tabid AND relateid=@relateid);

SET @relateid=(SELECT fieldid FROM ld_field WHERE tabid=@tabid AND columnname='sourcefrom' LIMIT 1);
SET @trantable='ld_field';
SET @zh='单据来源';
SET @en='Source';
INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
SELECT 'zh',@trantable,@tabid,@relateid,@zh FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE languagetype = 'zh' AND trantable =@trantable AND tabid = @tabid AND relateid=@relateid);
INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
SELECT 'en',@trantable,@tabid,@relateid,@en FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE languagetype = 'en' AND trantable =@trantable AND tabid = @tabid AND relateid=@relateid);

SET @relateid=(SELECT fieldid FROM ld_field WHERE tabid=@tabid AND columnname='smownerid' LIMIT 1);
SET @trantable='ld_field';
SET @zh='负责人';
SET @en='Owner';
INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
SELECT 'zh',@trantable,@tabid,@relateid,@zh FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE languagetype = 'zh' AND trantable =@trantable AND tabid = @tabid AND relateid=@relateid);
INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
SELECT 'en',@trantable,@tabid,@relateid,@en FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE languagetype = 'en' AND trantable =@trantable AND tabid = @tabid AND relateid=@relateid);

SET @relateid=(SELECT fieldid FROM ld_field WHERE tabid=@tabid AND columnname='smcreatorid' LIMIT 1);
SET @trantable='ld_field';
SET @zh='创建人';
SET @en='Creator';
INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
SELECT 'zh',@trantable,@tabid,@relateid,@zh FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE languagetype = 'zh' AND trantable =@trantable AND tabid = @tabid AND relateid=@relateid);
INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
SELECT 'en',@trantable,@tabid,@relateid,@en FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE languagetype = 'en' AND trantable =@trantable AND tabid = @tabid AND relateid=@relateid);

SET @relateid=(SELECT fieldid FROM ld_field WHERE tabid=@tabid AND columnname='createdtime' LIMIT 1);
SET @trantable='ld_field';
SET @zh='创建时间';
SET @en='Created Time';
INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
SELECT 'zh',@trantable,@tabid,@relateid,@zh FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE languagetype = 'zh' AND trantable =@trantable AND tabid = @tabid AND relateid=@relateid);
INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
SELECT 'en',@trantable,@tabid,@relateid,@en FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE languagetype = 'en' AND trantable =@trantable AND tabid = @tabid AND relateid=@relateid);

SET @relateid=(SELECT fieldid FROM ld_field WHERE tabid=@tabid AND columnname='modifiedby' LIMIT 1);
SET @trantable='ld_field';
SET @zh='最新更新人';
SET @en='Modified By';
INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
SELECT 'zh',@trantable,@tabid,@relateid,@zh FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE languagetype = 'zh' AND trantable =@trantable AND tabid = @tabid AND relateid=@relateid);
INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
SELECT 'en',@trantable,@tabid,@relateid,@en FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE languagetype = 'en' AND trantable =@trantable AND tabid = @tabid AND relateid=@relateid);

SET @relateid=(SELECT fieldid FROM ld_field WHERE tabid=@tabid AND columnname='modifiedtime' LIMIT 1);
SET @trantable='ld_field';
SET @zh='更新时间';
SET @en='Modified Time';
INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
SELECT 'zh',@trantable,@tabid,@relateid,@zh FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE languagetype = 'zh' AND trantable =@trantable AND tabid = @tabid AND relateid=@relateid);
INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
SELECT 'en',@trantable,@tabid,@relateid,@en FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE languagetype = 'en' AND trantable =@trantable AND tabid = @tabid AND relateid=@relateid);

SET @relateid=(SELECT fieldid FROM ld_field WHERE tabid=@tabid AND columnname='approvestatus' LIMIT 1);
SET @trantable='ld_field';
SET @zh='审批状态';
SET @en='Approve Status';
INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
SELECT 'zh',@trantable,@tabid,@relateid,@zh FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE languagetype = 'zh' AND trantable =@trantable AND tabid = @tabid AND relateid=@relateid);
INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
SELECT 'en',@trantable,@tabid,@relateid,@en FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE languagetype = 'en' AND trantable =@trantable AND tabid = @tabid AND relateid=@relateid);

SET @relateid=(SELECT fieldid FROM ld_field WHERE tabid=@tabid AND columnname='approvetime' LIMIT 1);
SET @trantable='ld_field';
SET @zh='最新审批时间';
SET @en='Last Approval Time';
INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
SELECT 'zh',@trantable,@tabid,@relateid,@zh FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE languagetype = 'zh' AND trantable =@trantable AND tabid = @tabid AND relateid=@relateid);
INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
SELECT 'en',@trantable,@tabid,@relateid,@en FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE languagetype = 'en' AND trantable =@trantable AND tabid = @tabid AND relateid=@relateid);

SET @relateid=(SELECT fieldid FROM ld_field WHERE tabid=@tabid AND columnname='approveby' LIMIT 1);
SET @trantable='ld_field';
SET @zh='上一步审批人';
SET @en='The Last Approver';
INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
SELECT 'zh',@trantable,@tabid,@relateid,@zh FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE languagetype = 'zh' AND trantable =@trantable AND tabid = @tabid AND relateid=@relateid);
INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
SELECT 'en',@trantable,@tabid,@relateid,@en FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE languagetype = 'en' AND trantable =@trantable AND tabid = @tabid AND relateid=@relateid);

SET @relateid=(SELECT fieldid FROM ld_field WHERE tabid=@tabid AND columnname='currentapprover' LIMIT 1);
SET @trantable='ld_field';
SET @zh='当前审批人';
SET @en='Current Approver';
INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
SELECT 'zh',@trantable,@tabid,@relateid,@zh FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE languagetype = 'zh' AND trantable =@trantable AND tabid = @tabid AND relateid=@relateid);
INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
SELECT 'en',@trantable,@tabid,@relateid,@en FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE languagetype = 'en' AND trantable =@trantable AND tabid = @tabid AND relateid=@relateid);

SET @relateid=(SELECT fieldid FROM ld_field WHERE tabid=@tabid AND columnname='advance_stage' LIMIT 1);
SET @trantable='ld_field';
SET @zh='推进阶段';
SET @en='Advance Stage';
INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
SELECT 'zh',@trantable,@tabid,@relateid,@zh FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE languagetype = 'zh' AND trantable =@trantable AND tabid = @tabid AND relateid=@relateid);
INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
SELECT 'en',@trantable,@tabid,@relateid,@en FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE languagetype = 'en' AND trantable =@trantable AND tabid = @tabid AND relateid=@relateid);

SET @relateid=(SELECT tabdetailfieldid FROM ld_tabdetailfield WHERE tabid=@tabid AND columnname='entitytype' LIMIT 1);
SET @trantable='ld_tabdetailfield';
SET @zh='合同类型';
SET @en='Link To';
INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
SELECT 'zh',@trantable,@tabid,@relateid,@zh FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE languagetype = 'zh' AND trantable =@trantable AND tabid = @tabid AND relateid=@relateid);
INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
SELECT 'en',@trantable,@tabid,@relateid,@en FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE languagetype = 'en' AND trantable =@trantable AND tabid = @tabid AND relateid=@relateid);

SET @relateid=(SELECT tabdetailfieldid FROM ld_tabdetailfield WHERE tabid=@tabid AND columnname='entitytypeid' LIMIT 1);
SET @trantable='ld_tabdetailfield';
SET @zh='合同';
SET @en='Orignal Bill';
INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
SELECT 'zh',@trantable,@tabid,@relateid,@zh FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE languagetype = 'zh' AND trantable =@trantable AND tabid = @tabid AND relateid=@relateid);
INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
SELECT 'en',@trantable,@tabid,@relateid,@en FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE languagetype = 'en' AND trantable =@trantable AND tabid = @tabid AND relateid=@relateid);

SET @relateid=(SELECT tabdetailfieldid FROM ld_tabdetailfield WHERE tabid=@tabid AND columnname='line_project_id' LIMIT 1);
SET @trantable='ld_tabdetailfield';
SET @zh='项目';
SET @en='Project';
INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
SELECT 'zh',@trantable,@tabid,@relateid,@zh FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE languagetype = 'zh' AND trantable =@trantable AND tabid = @tabid AND relateid=@relateid);
INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
SELECT 'en',@trantable,@tabid,@relateid,@en FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE languagetype = 'en' AND trantable =@trantable AND tabid = @tabid AND relateid=@relateid);

SET @relateid=(SELECT tabdetailfieldid FROM ld_tabdetailfield WHERE tabid=@tabid AND columnname='amount' LIMIT 1);
SET @trantable='ld_tabdetailfield';
SET @zh='金额';
SET @en='Amount';
INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
SELECT 'zh',@trantable,@tabid,@relateid,@zh FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE languagetype = 'zh' AND trantable =@trantable AND tabid = @tabid AND relateid=@relateid);
INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
SELECT 'en',@trantable,@tabid,@relateid,@en FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE languagetype = 'en' AND trantable =@trantable AND tabid = @tabid AND relateid=@relateid);

SET @relateid=(SELECT tabdetailfieldid FROM ld_tabdetailfield WHERE tabid=@tabid AND columnname='remark' LIMIT 1);
SET @trantable='ld_tabdetailfield';
SET @zh='备注';
SET @en='Remark';
INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
SELECT 'zh',@trantable,@tabid,@relateid,@zh FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE languagetype = 'zh' AND trantable =@trantable AND tabid = @tabid AND relateid=@relateid);
INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
SELECT 'en',@trantable,@tabid,@relateid,@en FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE languagetype = 'en' AND trantable =@trantable AND tabid = @tabid AND relateid=@relateid);

set @parenttabid = (select parenttabid from ld_parenttab where parenttab_label='Finacial');
set @sequence = (select max(sequence) from ld_parenttabrel where parenttabid=@parenttabid);
INSERT INTO ld_parenttabrel
(parenttabid,tabid,sequence,tab_tablename)
SELECT
    @parenttabid,@tabid,@sequence+1,'ld_tab'
FROM DUAL WHERE NOT EXISTS (
        SELECT 1 FROM ld_parenttabrel WHERE parenttabid = @parenttabid
                                        AND tabid =@tabid
                                        AND tab_tablename = 'ld_tab'
    );

SELECT MAX(cvid) INTO @maxcvid FROM ld_customview;
INSERT INTO ld_customview (
    cvid,viewname,setdefault,setmetrics,entitytype,STATUS,userid,sequence
) SELECT
          @maxcvid + 1,'All',1,0,@modulename,3,1,1
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM ld_customview WHERE entitytype =@modulename AND viewname = 'All');

SET @cvid = (SELECT cvid FROM ld_customview WHERE entitytype = @modulename AND viewname = 'All' );
INSERT INTO ld_tabwithproductview (
    cvid,tabid,sequence,columns
) SELECT
      @cvid,364,0,CONCAT('ld_',LOWER(@modulename),':','collectionslip_no',':','collectionslip_no',':',@modulename,'_fieldlabel:V')
from dual where not exists (select 1 from ld_tabwithproductview where cvid=@cvid and sequence=0);

INSERT INTO ld_tabwithproductview (
    cvid,tabid,sequence,columns
) SELECT
      @cvid,@tabid,1,CONCAT('ld_',LOWER(@modulename),':','account_id',':','account_id',':',@modulename,'_fieldlabel:V')
from dual where not exists (select 1 from ld_tabwithproductview where cvid=@cvid and sequence=1);

INSERT INTO ld_tabwithproductview (
    cvid,tabid,sequence,columns
) SELECT
      @cvid,@tabid,2,CONCAT('ld_',LOWER(@modulename),':','remit_account_name',':','remit_account_name',':',@modulename,'_fieldlabel:V')
from dual where not exists (select 1 from ld_tabwithproductview where cvid=@cvid and sequence=2);

INSERT INTO ld_tabwithproductview (
    cvid,tabid,sequence,columns
) SELECT
      @cvid,@tabid,3,CONCAT('ld_',LOWER(@modulename),':','remit_bank_account',':','remit_bank_account',':',@modulename,'_fieldlabel:V')
from dual where not exists (select 1 from ld_tabwithproductview where cvid=@cvid and sequence=3);

INSERT INTO ld_tabwithproductview (
    cvid,tabid,sequence,columns
) SELECT
      @cvid,@tabid,4,CONCAT('ld_',LOWER(@modulename),':','remit_bank',':','remit_bank',':',@modulename,'_fieldlabel:V')
from dual where not exists (select 1 from ld_tabwithproductview where cvid=@cvid and sequence=4);

INSERT INTO ld_tabwithproductview (
    cvid,tabid,sequence,columns
) SELECT
      @cvid,@tabid,5,CONCAT('ld_',LOWER(@modulename),':','remit_date',':','remit_date',':',@modulename,'_fieldlabel:D')
from dual where not exists (select 1 from ld_tabwithproductview where cvid=@cvid and sequence=5);

INSERT INTO ld_tabwithproductview (
    cvid,tabid,sequence,columns
) SELECT
      @cvid,@tabid,6,CONCAT('ld_',LOWER(@modulename),':','total',':','total',':',@modulename,'_fieldlabel:V')
from dual where not exists (select 1 from ld_tabwithproductview where cvid=@cvid and sequence=6);

INSERT INTO ld_tabwithproductview (
    cvid,tabid,sequence,columns
) SELECT
      @cvid,@tabid,7,CONCAT('ld_',LOWER(@modulename),':','smownerid',':','assigned_user_id',':',@modulename,'_fieldlabel:V')
from dual where not exists (select 1 from ld_tabwithproductview where cvid=@cvid and sequence=7);

INSERT INTO ld_tabwithproductview (
    cvid,tabid,sequence,columns
) SELECT
      @cvid,@tabid,8,CONCAT('ld_',LOWER(@modulename),':','bankaccountsetid',':','bankaccountsetid',':',@modulename,'_fieldlabel:V')
from dual where not exists (select 1 from ld_tabwithproductview where cvid=@cvid and sequence=8);

INSERT INTO ld_tabwithproductview (
    cvid,tabid,sequence,columns
) SELECT
      @cvid,@tabid,9,CONCAT('ld_',LOWER(@modulename),':','trade_time',':','trade_time',':',@modulename,'_fieldlabel:DT')
from dual where not exists (select 1 from ld_tabwithproductview where cvid=@cvid and sequence=9);

UPDATE ld_customview_seq SET id = (SELECT MAX(cvid) FROM ld_customview);

SET @modentity_num_seq = (select id from ld_modentity_num_seq);
INSERT INTO `ld_modentity_num`(`num_id`, `semodule`, `prefix`, `start_id`, `cur_id`, `active`, `datetype`, `UseUserAccount`, `isallow`, `prefixtype`)
select @modentity_num_seq+1, @modulename, 'CS-', '1', '1', '1', 'yyyy-mm-dd-', 0, 0, 0  from dual where not exists (select 1 from ld_modentity_num where  semodule =@modulename);
update ld_modentity_num_seq set id =( select max(num_id) from ld_modentity_num );

SELECT tabid INTO @tabid FROM ld_tab WHERE NAME = @modulename;
INSERT INTO `ld_entityname`(`tabid`, `modulename`, `tablename`, `fieldname`, `entityidfield`, `entityidcolumn`)
SELECT @tabid, @modulename, @tablename, 'collectionslip_no', 'collectionslip_id', 'collectionslip_id' FROM  DUAL  where not exists (select 1 from ld_entityname where  tabid =@tabid);

CALL getallprofile(@modulename);
CALL fieldprofile(@modulename);
CALL addtabintoprofile(@modulename,1);
INSERT INTO ld_profileallpermission(tabid, `operation`, `sequence`) SELECT  @tabid, 1, 1 from dual where NOT exists(SELECT 1 FROM  ld_profileallpermission where tabid =@tabid and operation=1);
INSERT INTO ld_profileallpermission(tabid, `operation`, `sequence`) SELECT  @tabid, 2, 2 from dual where NOT exists(SELECT 1 FROM  ld_profileallpermission where tabid =@tabid and operation=2 );
INSERT INTO ld_profileallpermission(tabid, `operation`, `sequence`) select  @tabid, 3, 3  from dual where NOT exists(SELECT 1 FROM  ld_profileallpermission where tabid =@tabid and operation=3);
INSERT INTO ld_profileallpermission(tabid, `operation`, `sequence`) select  @tabid, 4, 4  from dual where NOT exists(SELECT 1 FROM  ld_profileallpermission where tabid =@tabid and operation=4);
INSERT INTO ld_profileallpermission(tabid, `operation`, `sequence`) select  @tabid, 5, 5  from dual where NOT exists(SELECT 1 FROM  ld_profileallpermission where tabid =@tabid and operation=5);
INSERT INTO ld_profileallpermission(tabid, `operation`, `sequence`) select  @tabid, 6, 6  from dual where NOT exists(SELECT 1 FROM  ld_profileallpermission where tabid =@tabid and operation=6);
INSERT INTO ld_profileallpermission(tabid, `operation`, `sequence`) select  @tabid, 11, 7  from dual where NOT exists(SELECT 1 FROM  ld_profileallpermission where tabid =@tabid and operation=11);
INSERT INTO ld_profileallpermission(tabid, `operation`, `sequence`) select  @tabid, 12, 8  from dual where NOT exists(SELECT 1 FROM  ld_profileallpermission where tabid =@tabid and operation=12);
INSERT INTO ld_profileallpermission(tabid, `operation`, `sequence`) select  @tabid, 13, 9  from dual where NOT exists(SELECT 1 FROM  ld_profileallpermission where tabid =@tabid and operation=13);
INSERT INTO ld_profileallpermission(tabid, `operation`, `sequence`) select  @tabid, 14, 10  from dual where NOT exists(SELECT 1 FROM  ld_profileallpermission where tabid =@tabid and operation=14);
INSERT INTO ld_profileallpermission(tabid, `operation`, `sequence`) select  @tabid, 22, 13  from dual where NOT exists(SELECT 1 FROM  ld_profileallpermission where tabid =@tabid and operation=22);
INSERT INTO ld_profileallpermission(tabid, `operation`, `sequence`) select  @tabid, 25, 11  from dual where NOT exists(SELECT 1 FROM  ld_profileallpermission where tabid =@tabid and operation=25);
INSERT INTO ld_profileallpermission(tabid, `operation`, `sequence`) select  @tabid, 37, 12  from dual where NOT exists(SELECT 1 FROM  ld_profileallpermission where tabid =@tabid and operation=37);

DROP PROCEDURE IF EXISTS `ldcrm_add_approveforbill`;
delimiter ||
CREATE  PROCEDURE `ldcrm_add_approveforbill`(
    tmp_moudlename VARCHAR(100),
    tmp_deploytype INT(19)
)
BEGIN
	SET @modulename=tmp_moudlename;
	SET @new_deploytype=tmp_deploytype;
	IF NOT EXISTS (SELECT 1 FROM ld_systems_deploy WHERE deploy_type=@new_deploytype) THEN
		SET @tabid=(SELECT tabid FROM ld_tab WHERE `name`=@modulename);
		SET @roottype=(SELECT roottype FROM ld_systems_deploy WHERE deploy_type=3 LIMIT 1);
		SET @seq=(SELECT MAX(sequence) FROM ld_systems_deploy WHERE roottype=@roottype);
		SET @name_zh=(SELECT fieldlabel FROM ld_tranlabel WHERE Relateid=@tabid AND trantable='ld_tab' AND languagetype='zh' LIMIT 1);
INSERT INTO ld_systems_deploy(deploy_value,deploy_type,description,setype,sequence,roottype,inputtype,presence,inputvalue)
SELECT 0,@new_deploytype,CONCAT(IFNULL(@name_zh,''),'是否启用审批流程 1:否，0:是'),@modulename,@seq+1,@roottype,'select',0,'[{"value":"0","text":"YES"},{"value":"1","text":"NO"},{"sql":""}]' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_systems_deploy WHERE deploy_type=@new_deploytype);

SET @approvename=CONCAT(@name_zh,'审批流程');
		SET @approveid=(SELECT MAX(id) FROM ld_approve);
INSERT INTO ld_approve(id,tabid,`name`,`status`,smcreatorid,modifiedby,createdtime,modifiedtime,approveallocatetype,allowediting,allowantiapproval,finishedallowedit,isnewapprove,description)
SELECT @approveid+1,@tabid,CONCAT(@name_zh,'审批流程'),0,1,1,now(),now(),0,0,0,'no','yes','' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_approve WHERE tabid=@tabid AND `name`=@approvename);

SET @approveid=(SELECT id FROM ld_approve WHERE tabid=@tabid AND `name`=@approvename);
		SET @maxsetpid=(SELECT MAX(id) FROM ld_approvestep);
		SET @hadinsert=(SELECT COUNT(1) FROM ld_approvestep WHERE approveid=@approveid);
INSERT INTO ld_approvestep(id,approveid,`name`,ended,step,sequence,createdtime,modifiedtime,approvetype,approvevalue,steptype,isnewstep,childids,specifyapproverid,branchflowstepid,flowstepid)
SELECT @maxsetpid+1,@approveid,'开始',NULL,1,1,now(),now(),6,'','start','yes',1,NULL,-1,-1 FROM DUAL WHERE @hadinsert=0;

INSERT INTO ld_approvestep(id,approveid,`name`,ended,step,sequence,createdtime,modifiedtime,approvetype,approvevalue,steptype,isnewstep,childids,specifyapproverid,branchflowstepid,flowstepid)
SELECT @maxsetpid+2,@approveid,'一级审批',1,1,2,now(),now(),6,'','approver','yes',2,1,-1,1 FROM DUAL WHERE @hadinsert=0;

INSERT INTO ld_approvestep(id,approveid,`name`,ended,step,sequence,createdtime,modifiedtime,approvetype,approvevalue,steptype,isnewstep,childids,specifyapproverid,branchflowstepid,flowstepid)
SELECT @maxsetpid+3,@approveid,'二级审批',1,1,3,now(),now(),6,'','approver','yes',3,1,-1,2 FROM DUAL WHERE @hadinsert=0;

INSERT INTO ld_approvestep(id,approveid,`name`,ended,step,sequence,createdtime,modifiedtime,approvetype,approvevalue,steptype,isnewstep,childids,specifyapproverid,branchflowstepid,flowstepid)
SELECT @maxsetpid+4,@approveid,'三级审批',1,1,4,now(),now(),6,'','approver','yes','',1,-1,3 FROM DUAL WHERE @hadinsert=0;

UPDATE ld_approvestep_seq SET id=(SELECT MAX(id) FROM ld_approvestep);

SET @stepid=(SELECT id FROM ld_approvestep WHERE approveid=@approveid AND `name`='一级审批' LIMIT 1);
INSERT INTO ld_approvereminds(stepid,type,remindmethod,reminduser,remindcontent)
SELECT @stepid,0,'dialog','approver','有新的单据需要审批，请及时处理！' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_approvereminds WHERE stepid=@stepid AND type=0);

SET @stepid=(SELECT id FROM ld_approvestep WHERE approveid=@approveid AND `name`='一级审批' LIMIT 1);
INSERT INTO ld_approvereminds(stepid,type,remindmethod,reminduser,remindcontent)
SELECT @stepid,1,'dialog','smowner','您提交的单据已通过审批步骤{step}' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_approvereminds WHERE stepid=@stepid AND type=1);

SET @stepid=(SELECT id FROM ld_approvestep WHERE approveid=@approveid AND `name`='一级审批' LIMIT 1);
INSERT INTO ld_approvereminds(stepid,type,remindmethod,reminduser,remindcontent)
SELECT @stepid,2,'dialog','smowner','您提交的单据未通过审批步骤{step}，原因：{description}' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_approvereminds WHERE stepid=@stepid AND type=2);

SET @stepid=(SELECT id FROM ld_approvestep WHERE approveid=@approveid AND `name`='二级审批' LIMIT 1);
INSERT INTO ld_approvereminds(stepid,type,remindmethod,reminduser,remindcontent)
SELECT @stepid,0,'dialog','approver','有新的单据需要审批，请及时处理！' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_approvereminds WHERE stepid=@stepid AND type=0);

SET @stepid=(SELECT id FROM ld_approvestep WHERE approveid=@approveid AND `name`='二级审批' LIMIT 1);
INSERT INTO ld_approvereminds(stepid,type,remindmethod,reminduser,remindcontent)
SELECT @stepid,1,'dialog','smowner','您提交的单据已通过审批步骤{step}' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_approvereminds WHERE stepid=@stepid AND type=1);

SET @stepid=(SELECT id FROM ld_approvestep WHERE approveid=@approveid AND `name`='二级审批' LIMIT 1);
INSERT INTO ld_approvereminds(stepid,type,remindmethod,reminduser,remindcontent)
SELECT @stepid,2,'dialog','smowner','您提交的单据未通过审批步骤{step}，原因：{description}' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_approvereminds WHERE stepid=@stepid AND type=2);

SET @stepid=(SELECT id FROM ld_approvestep WHERE approveid=@approveid AND `name`='三级审批' LIMIT 1);
INSERT INTO ld_approvereminds(stepid,type,remindmethod,reminduser,remindcontent)
SELECT @stepid,0,'dialog','approver','有新的单据需要审批，请及时处理！' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_approvereminds WHERE stepid=@stepid AND type=0);

SET @stepid=(SELECT id FROM ld_approvestep WHERE approveid=@approveid AND `name`='三级审批' LIMIT 1);
INSERT INTO ld_approvereminds(stepid,type,remindmethod,reminduser,remindcontent)
SELECT @stepid,1,'dialog','smowner','您提交的单据已通过审批步骤{step}' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_approvereminds WHERE stepid=@stepid AND type=1);

SET @stepid=(SELECT id FROM ld_approvestep WHERE approveid=@approveid AND `name`='三级审批' LIMIT 1);
INSERT INTO ld_approvereminds(stepid,type,remindmethod,reminduser,remindcontent)
SELECT @stepid,2,'dialog','smowner','您提交的单据未通过审批步骤{step}，原因：{description}' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_approvereminds WHERE stepid=@stepid AND type=2);

END IF;

end ||
delimiter;
CALL ldcrm_add_approveforbill(@modulename,473);

drop PROCEDURE  if EXISTS update_validatarule;
delimiter ||
create PROCEDURE update_validatarule
(
)
BEGIN
	declare var_validataid int(19);
	declare done  int  default 0;
	declare cur1 CURSOR FOR SELECT id from ld_validatasave where validatasavetype = 'php' and isshowlist = 'no' AND IFNULL(validatasavemainid,0) = 0;

declare continue handler  for not   found  SET done =1;

open cur1;
Fetch cur1 into var_validataid;
loop1: while  done<>1 DO
				INSERT into ld_validatasavemain(rulename,module,`status`,actionprevent,tipzh,tipen,conditiongroup,validataapplication,relatedtable,sequence,isshowlist)
SELECT rulename,module,`status`,case when allowsave = 'no' then 'yes' ELSE 'no' END,tipzh,tipen,'',validatacheckbutton,relatedtable,sequence,'no' from ld_validatasave where id = var_validataid;
SELECT MAX(id) into @max_mainid from ld_validatasavemain;

UPDATE ld_validatasave SET conditiongroupid = 1,validatasavemainid = @max_mainid where id = var_validataid;
Fetch cur1 into var_validataid;
end while loop1;
close cur1;
end ||
delimiter;
call update_validatarule();
drop PROCEDURE if EXISTS update_validatarule;

DELETE FROM ld_cvcolumnlist_wx WHERE modulename=@modulename;
DROP PROCEDURE IF EXISTS `ldcrm_add_cvcolumnlist_wx`;
delimiter ||
CREATE PROCEDURE `ldcrm_add_cvcolumnlist_wx`(
    tmp_module VARCHAR(100),
    tmp_column VARCHAR(100),
    tmp_rownum INT(1),
    tmp_colnum INT(1),
    tmp_showtag VARCHAR(20),
    tmp_sysdefault VARCHAR(20)
        )
BEGIN

  SET @columnname=(
    SELECT
      CONCAT(b.tablename,':',b.columnname,':',b.fieldname,':',a.`name`,'_',b.fieldlabel,':',LEFT(b.typeofdata,1))
    FROM ld_tab a
    LEFT JOIN ld_field b ON a.tabid=b.tabid
    WHERE a.`name`=tmp_module
      AND b.columnname=tmp_column
    LIMIT 1);

DELETE FROM ld_cvcolumnlist_wx WHERE modulename=tmp_module AND LOCATE(CONCAT(':',tmp_column,':'),columnname)>0;
INSERT INTO ld_cvcolumnlist_wx(modulename,rownumber,listnumber,columnname,systemdefault,showtag)
SELECT tmp_module,tmp_rownum,tmp_colnum,@columnname,tmp_sysdefault,tmp_showtag;

end ||
delimiter;
CALL ldcrm_add_cvcolumnlist_wx(@modulename,'collectionslip_no','1','1','yes','yes');
CALL ldcrm_add_cvcolumnlist_wx(@modulename,'createdtime','2','1','yes','yes');
CALL ldcrm_add_cvcolumnlist_wx(@modulename,'smownerid','3','1','yes','yes');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','UNCOLLECTED','待认领','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='UNCOLLECTED' and labeltype='fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','UNCOLLECTED',"To be collected",'fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='UNCOLLECTED' and labeltype='fixedstr');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','COLLECTED','已认领','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='COLLECTED' and labeltype='fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','COLLECTED',"Collected",'fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='COLLECTED' and labeltype='fixedstr');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','AUTOMATCH','自动匹配','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='AUTOMATCH' and labeltype='fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','AUTOMATCH',"Automatic match",'fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='AUTOMATCH' and labeltype='fixedstr');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','GENERATED','已生成','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='GENERATED' and labeltype='fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','GENERATED',"Generated ",'fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='GENERATED' and labeltype='fixedstr');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','GENERATEDCASHBILL','已生成收款单','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='GENERATEDCASHBILL' and labeltype='fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','GENERATEDCASHBILL',"Generated cashbill",'fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='GENERATEDCASHBILL' and labeltype='fixedstr');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','SKIPTOEDIT','是否立即填写对应单据信息？','jspop' from dual
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='SKIPTOEDIT' and labeltype='jspop');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','SKIPTOEDIT',"Is the corresponding document information filled out immediately",'jspop' from dual
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='SKIPTOEDIT' and labeltype='jspop');
delimiter;


drop PROCEDURE if exists `addReferenceUitypmodule`;
delimiter ||
create PROCEDURE `addReferenceUitypmodule`(
    referenceuitype varchar(100)
)
begin
 set @sql=concat('select max(ld_ws_fieldtype.uitype) into @uitype from ld_ws_fieldtype LEFT JOIN ld_ws_referencetype on ld_ws_referencetype.fieldtypeid=ld_ws_fieldtype.fieldtypeid
				where type="',referenceuitype,'"' );
prepare stmt from @sql;
execute stmt;
deallocate prepare stmt;
if ifnull(@uitype,'')='' then
select max(uitype+0) into @maxuitype from ld_ws_fieldtype;
if @maxuitype<2000  then
					set @maxuitype=2000;
else
					set @maxuitype=@maxuitype+1;
end if;

		 set @sql=concat('insert into ld_ws_fieldtype(uitype,fieldtype)value("',@maxuitype,'","reference")');
prepare stmta from @sql;
execute stmta;
deallocate prepare stmta;
set @sql=concat('select fieldtypeid  into @lastid from ld_ws_fieldtype where uitype ="',@maxuitype,'"');
prepare stmt1 from @sql;
execute stmt1;
deallocate prepare stmt1;

set @sql=concat('insert into ld_ws_referencetype(fieldtypeid,type)value("',@lastid,'","',referenceuitype,'")');
prepare stmt2 from @sql;
execute stmt2;
deallocate prepare stmt2;
end if;
end ||
delimiter;

call addReferenceUitypmodule('CollectionSlip');
DROP PROCEDURE IF EXISTS `addReferenceUitypmodule`;

DROP PROCEDURE IF EXISTS `ldcrm_reset_yueshu_20240603`;
delimiter ||
CREATE  PROCEDURE `ldcrm_reset_yueshu_20240603`(
)
BEGIN
	
	IF NOT EXISTS (SELECT 1 FROM ld_tab WHERE name='CashBill') THEN
		IF EXISTS (SELECT 1 FROM information_schema.table_constraints WHERE TABLE_NAME='ld_field' AND TABLE_SCHEMA=DATABASE() AND CONSTRAINT_NAME='ld_field_ibfk_1') THEN
			ALTER TABLE `ld_field` DROP FOREIGN KEY `ld_field_ibfk_1`;
		END IF;
	END IF;

end ||
delimiter;

CALL ldcrm_reset_yueshu_20240603();
DROP PROCEDURE IF EXISTS `ldcrm_reset_yueshu_20240603`;
delimiter;

SET @modulename='CashBill';
SET @rel_module='CollectionSlip';
SET @tabid=(SELECT tabid FROM ld_tab WHERE name=@modulename);
SET @relateid=(select block from ld_field where columnname = 'smownerid' and tabid = @tabid);
SET @maxseq=IFNULL((SELECT MAX(sequence) FROM ld_field WHERE tabid=@tabid AND block=@relateid),0);
SET @trantable='ld_field';
SET @tablename=(SELECT tablename FROM ld_field WHERE tabid=@tabid AND columnname='smownerid' LIMIT 1);
SET @columnname='collectionslip_id';
SET @fieldname='collectionslip_id';
SET @zh='收款认领单';
SET @en='Collection Slip';
SET @uitype=(SELECT max(uitype) FROM ld_ws_fieldtype LEFT JOIN ld_ws_referencetype on ld_ws_referencetype.fieldtypeid=ld_ws_fieldtype.fieldtypeid where type=@rel_module);
SET @typeofdata='V~O';
SET @quickcreate=0;
SET @displaytype=1;
SET @bigtype='reference';
SET @datarang='permit';
SET @maxrowsshow=5;
SET @savedatabase = 'yes';
SET @allowedit = 'no';
SET @maxid=(SELECT MAX(fieldid) FROM ld_field);
INSERT INTO ld_field(tabid,fieldid,columnname,tablename,generatedtype,uitype,fieldname,fieldlabel,readonly,presence,defaultvalue,maximumlength,sequence,block,displaytype,typeofdata,quickcreate,quickcreatesequence,info_type,masseditable,helpinfo,fieldonly,approve_demand,is_checkimportfield,bigtype,datarang,maxrowsshow,savedatabase,allowedit)
SELECT @tabid,@maxid+1,@columnname,@tablename,2,@uitype,@fieldname,@zh,0,2,NULL,100,@maxseq+1,@relateid,@displaytype,@typeofdata,@quickcreate,7,'BAS',2,NULL,0,0,0,@bigtype,@datarang,@maxrowsshow,@savedatabase,@allowedit from dual
WHERE NOT EXISTS (SELECT 1 FROM ld_field WHERE tabid=@tabid AND tablename=@tablename AND columnname=@columnname);
UPDATE ld_field_seq SET id=(SELECT max(fieldid) FROM ld_field);

SET @relateid=(SELECT fieldid FROM ld_field WHERE tabid=@tabid AND columnname=@columnname LIMIT 1);
INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
SELECT 'zh',@trantable,@tabid,@relateid,@zh FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE languagetype = 'zh' AND trantable =@trantable AND tabid = @tabid AND relateid=@relateid AND fieldlabel=@zh);
INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
SELECT 'en',@trantable,@tabid,@relateid,@en FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE languagetype = 'en' AND trantable =@trantable AND tabid = @tabid AND relateid=@relateid AND fieldlabel=@en);

CALL AddColumn('ld_cashbill',@columnname,'int','19','');
delimiter;

SET @module='CollectionSlip';
SET @rel_module='CashBill';
SET @tabid=(SELECT tabid FROM ld_tab WHERE `name`=@module);
SET @rel_tabid=(SELECT tabid FROM ld_tab WHERE `name`=@rel_module);
SET @relation_id=(SELECT MAX(relation_id) FROM ld_relatedlists);
SET @seq=(SELECT MAX(sequence) FROM ld_relatedlists WHERE tabid=@tabid);
SET @template=CONCAT('get_',LOWER(@rel_module));
DELETE FROM ld_relatedlists
WHERE tabid=@tabid  AND related_tabid=@rel_tabid AND `name`=@template AND type='datacategory_sql' AND related_coltable='cashbill.collectionslip';
INSERT INTO ld_relatedlists(relation_id,tabid,related_tabid,`name`,sequence,label,presence,actions,type,related_coltable,related_advanceset)
SELECT @relation_id+1,@tabid,@rel_tabid,@template,@seq+1,@rel_module,0,'add','datacategory_sql','paymentplan.projectid','[{"columnname":"cashbill.collectionslip_id","comparator":"e","columncondition":""}]' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_relatedlists WHERE tabid=@tabid AND `name`=@template AND related_tabid=@rel_tabid);
UPDATE ld_relatedlists_seq SET id=(SELECT MAX(relation_id) FROM ld_relatedlists);
delimiter;

UPDATE ld_desk set fieldlabel='工商定制' WHERE labelbol='LBI_FUNCTION_SETTINGS' and languagetype='zh';
UPDATE ld_desk set fieldlabel='Business Settings' WHERE labelbol='LBI_FUNCTION_SETTINGS' and languagetype='en';
delimiter;

update ld_field set bigtype='selectmultiuser' where columnname='budget_person' and tablename='ld_expensebudget' and bigtype = 'text';
delimiter;

SET @fieldid=(SELECT fieldid FROM ld_field WHERE tablename='ld_holiday' AND columnname='wheatherholidays' LIMIT 1);
UPDATE ld_tranlabel SET fieldlabel='是否放假' WHERE trantable='ld_field' AND Relateid=@fieldid AND languagetype='zh';
delimiter;
-- 2024-03-15

UPDATE ld_tabwithproductview
SET `columns`='ld_collectionslip:accountid:account_id:CollectionSlip_fieldlabel:V'
WHERE cvid IN (SELECT cvid FROM ld_customview WHERE entitytype='CollectionSlip')
	AND `columns` LIKE 'ld_collectionslip:account_id%';
delimiter;

SET @disable_triggers=NULL;
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

UPDATE ld_version SET old_version='V8.6.2.7',current_version='V8.6.2.7',remark='V8.6.2.6-20240315',wx_version='V8.6.2.6';
delimiter;