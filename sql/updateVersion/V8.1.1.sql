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

SELECT CASE WHEN NOT EXISTS (SELECT 1 FROM ld_tab WHERE `name`='CustomForm20') THEN 168 ELSE (SELECT tabid+1 FROM ld_tab order by tabid DESC limit 1) END INTO @tabid;
insert into ld_tab(tabid,name,presence,tabsequence,tablabel,isentitytype,printtab,Proportion,isduplicate)
select @tabid ,'SocialPromotion','0','142' ,'SocialPromotion','1','1',0,'yes' from dual
where not exists(select 1 from ld_tab where name='SocialPromotion');
delimiter;

select tabid into @tabid from ld_tab where name='SocialPromotion';
CALL AddColumn('ld_tab','fristvisit','text','0',null);

set @parenttabid = (select parenttabid from ld_parenttab where parenttab_label= 'Marketing');
INSERT INTO `ld_parenttabrel` (`parenttabid`, `tabid`, `sequence`, `tab_tablename`) select @parenttabid, @tabid, 0, 'ld_tab' from dual where not exists (select 1 from ld_parenttabrel where tabid = @tabid and parenttabid = @parenttabid);

set @appblockid = (select blockid from ld_appparenttab where parenttab_label= 'Sales');
set @temSquence  = (select max(sequence)+1 from ld_appparenttabrel where blockid = @appblockid);
INSERT INTO `ld_appparenttabrel`(`blockid`, `tabid`, `sequence`, `relatename`, `tab_tablename`) SELECT @appblockid, @tabid, @temSquence, NULL, 'ld_tab' FROM DUAL where not exists (select 1 from ld_appparenttabrel where blockid = @appblockid and tabid =@tabid);

SET @modentity_num_seq = (select id+1 from ld_modentity_num_seq);
INSERT INTO  `ld_modentity_num`(`num_id`, `semodule`, `prefix`, `start_id`, `cur_id`, `active`, `datetype`, `UseUserAccount`, `isallow`, `prefixtype`) select @modentity_num_seq, 'SocialPromotion', 'SJTG', '0001', '0001', '1', 'yyyy-mm-dd-', 0, 0, 0  from dual where not exists (select 1 from ld_modentity_num where  semodule ='SocialPromotion');
update ld_modentity_num_seq set id =( select max(num_id) from ld_modentity_num );


INSERT INTO `ld_entityname`(`tabid`, `modulename`, `tablename`, `fieldname`, `entityidfield`, `entityidcolumn`) 
SELECT @tabid, 'SocialPromotion', 'ld_socialpromotion', 'activityname', 'socialpromotionid', 'socialpromotionid' FROM  DUAL  where not exists (select 1 from ld_entityname where  tabid =@tabid);

INSERT INTO ld_tranlabel(languagetype,trantable,tabid,Relateid,fieldlabel)
select 'zh','ld_tab',@tabid,@tabid,'社交推广' from DUAL
where not exists (select 1 from ld_tranlabel where tabid = @tabid and languagetype = 'zh');

INSERT INTO ld_tranlabel(languagetype,trantable,tabid,Relateid,fieldlabel)
select 'en','ld_tab',@tabid,@tabid,'Social Promotion' from DUAL
where not exists (select 1 from ld_tranlabel where tabid = @tabid and languagetype = 'en');
delimiter;

CREATE TABLE IF NOT EXISTS `ld_socialpromotion`
(
    `socialpromotionid`  int(19) NOT NULL DEFAULT '0',
    `socialpromotion_no` varchar(255)     DEFAULT NULL,
    `smownerid`          int(19)          DEFAULT NULL,
    `smcreatorid`        int(19)          DEFAULT NULL,
    `createdtime`        datetime         DEFAULT NULL,
    `modifiedby`         int(19)          DEFAULT NULL,
    `modifiedtime`       datetime         DEFAULT NULL,
    `activityname`  		 varchar(255)     DEFAULT NULL,
    `activitystate`      varchar(50)      DEFAULT NULL,
    `mappingmodule`      varchar(50)       DEFAULT NULL,
    `social_activitytype`       varchar(255)     DEFAULT NULL,
    `activityviews`      int(19)          DEFAULT '0',
    `documentquantity`   int(19)          DEFAULT '0',
    `customfieldsorder`     text DEFAULT NULL,
    `approvestatus`      varchar(50)      DEFAULT '未提交',
    `approvetime`        datetime         DEFAULT NULL,
    `approveby`          int(19)          DEFAULT NULL,
    `currentapprover`    text,
    `deleted`            int(19) NOT NULL DEFAULT '0',
    `advance_stage`      varchar(20)      DEFAULT NULL,
    PRIMARY KEY (`socialpromotionid`)
) ENGINE = InnoDB
DEFAULT CHARSET = utf8;
delimiter;

CREATE TABLE IF NOT EXISTS `ld_socialpromotionscf`
(
    socialpromotionid    int(19) NOT NULL DEFAULT '0',
    h5pageurl            varchar(255)     default null,
    h5pagebutton         varchar(50)      default null,
    h5buttoncolor        varchar(50)      default null,
    activitytitle        varchar(255)     default null,
    activityintroduction varchar(255)     default null,
    buttonname           varchar(50)      default null,
    buttoncolor          varchar(50)      default null,
    sharetitle          varchar(255)     default null,
    shareintroduction    varchar(255)     default null,
    PRIMARY KEY (`socialpromotionid`)
) ENGINE = InnoDB
DEFAULT CHARSET = utf8;
delimiter;

CREATE TABLE IF NOT EXISTS `ld_socialpromotionformfixed` 
(
    `socialpromotionid` int(19) NOT NULL DEFAULT '0',
    PRIMARY KEY (`socialpromotionid`)
) ENGINE = InnoDB
  DEFAULT CHARSET = utf8;
delimiter;

CREATE TABLE IF NOT EXISTS `ld_socialpromotionformcustom` 
(
    `socialpromotionid` int(19) NOT NULL DEFAULT '0',
    PRIMARY KEY (`socialpromotionid`)
) ENGINE = InnoDB
  DEFAULT CHARSET = utf8;
delimiter;

select tabid into @tabid from ld_tab where name='SocialPromotion';
set @blockid = (select id+1 from ld_blocks_seq );
INSERT INTO `ld_blocks` (`blockid`, `tabid`, `blocklabel`, `sequence`, `show_title`, `visible`, `create_view`, `edit_view`, `detail_view`, `display_status`, `iscustom`, `linkid`) 
select @blockid, @tabid, 'LBL_SOCIALPROMOTION_BASICINFORMATION', 1, 0, 0, 0, 0, 0, 1, 0, NULL from dual where not exists (select 1 from ld_blocks where tabid =@tabid and blocklabel ='LBL_SOCIALPROMOTION_BASICINFORMATION');

INSERT INTO `ld_tranlabel`(`languagetype`, `trantable`, `tabid`, `Relateid`, `fieldlabel`) select 'zh', 'ld_blocks', @tabid, @blockid, '基本信息' from dual where not exists (select 1 from ld_tranlabel where  tabid =@tabid and languagetype ='zh' and fieldlabel ='基本信息');
INSERT INTO `ld_tranlabel`( `languagetype`, `trantable`, `tabid`, `Relateid`, `fieldlabel`) select  'en', 'ld_blocks', @tabid, @blockid, 'Basic Information' from dual where not exists (select 1 from ld_tranlabel where  tabid =@tabid and languagetype ='en' and fieldlabel ='Basic Information');

set @fieldid = (select max(fieldid) from ld_field)+1;
INSERT INTO `ld_field` (`tabid`, `fieldid`, `columnname`, `allowhide`, `tablename`, `generatedtype`, `uitype`, `fieldname`, `fieldlabel`, `readonly`, `presence`, `defaultvalue`, `maximumlength`, `sequence`, `block`, `displaytype`, `typeofdata`, `quickcreate`, `quickcreatesequence`, `info_type`, `masseditable`, `helpinfo`, `fieldonly`, `issmownerid`, `searchfieldtype`, `associatedfields`, `associatedsequence`, `callchecked`, `duplicatefield`, `relate_search_parent_columnname`, `approve_demand`, `is_checkimportfield`, `allowedit`, `allowedit_presence`, `allowcreate`, `allowcreate_presence`, `allowdetail_presence`, `fldallow_rewriting`, `take_photo_only`, `savedatabase`, `bigtype`, `datarang`, `maxrowsshow`, `parentbigtype`, `profileeditfield`, `keywords`) 
select @tabid, @fieldid, 'smcreatorid', 'yes', 'ld_socialpromotion', '1', '52', 'smcreatorid', '创建人', '1', '0', NULL, NULL, '3', @blockid, '2', 'V~O', '1', NULL, NULL, '1', NULL, '0', '0', NULL, NULL, '0', '0', NULL, NULL, '2', '0', NULL, NULL, NULL, NULL, NULL, '0', '0', 'yes', NULL, NULL, '0', NULL, 'yes', NULL from dual where not exists( select 1 from ld_field where tabid= @tabid and fieldname='smcreatorid');

INSERT INTO `ld_tranlabel`( `languagetype`, `trantable`, `tabid`, `Relateid`, `fieldlabel`) 
select 'zh', 'ld_field', @tabid, @fieldid, '创建人' from dual 
where not exists( select 1 from ld_tranlabel where tabid =@tabid and fieldlabel ='创建人');
INSERT INTO `ld_tranlabel`( `languagetype`, `trantable`, `tabid`, `Relateid`, `fieldlabel`) 
select 'en', 'ld_field', @tabid, @fieldid, 'Creator' from dual 
where not exists( select 1 from ld_tranlabel where tabid =@tabid and fieldlabel ='Creator');

set @fieldid = (select max(fieldid) from ld_field)+1;
INSERT INTO `ld_field` (`tabid`, `fieldid`, `columnname`, `allowhide`, `tablename`, `generatedtype`, `uitype`, `fieldname`, `fieldlabel`, `readonly`, `presence`, `defaultvalue`, `maximumlength`, `sequence`, `block`, `displaytype`, `typeofdata`, `quickcreate`, `quickcreatesequence`, `info_type`, `masseditable`, `helpinfo`, `fieldonly`, `issmownerid`, `searchfieldtype`, `associatedfields`, `associatedsequence`, `callchecked`, `duplicatefield`, `relate_search_parent_columnname`, `approve_demand`, `is_checkimportfield`, `allowedit`, `allowedit_presence`, `allowcreate`, `allowcreate_presence`, `allowdetail_presence`, `fldallow_rewriting`, `take_photo_only`, `savedatabase`, `bigtype`, `datarang`, `maxrowsshow`, `parentbigtype`, `profileeditfield`, `keywords`) 
select @tabid, @fieldid, 'createdtime', 'yes', 'ld_socialpromotion', '1', '70', 'createdtime', '创建时间', '1', '0', NULL, NULL, '4', @blockid, '2', 'DT~O', '1', NULL, NULL, '1', NULL, '0', '0', NULL, NULL, '0', '0', NULL, NULL, '2', '0', NULL, NULL, NULL, NULL, NULL, '0', '0', 'yes', 'datetime', NULL, '0', NULL, 'yes', NULL from dual 
where not exists( select 1 from ld_field where tabid= @tabid and fieldname='createdtime');

INSERT INTO `ld_tranlabel`( `languagetype`, `trantable`, `tabid`, `Relateid`, `fieldlabel`) select  'zh', 'ld_field',  @tabid, @fieldid, '创建时间' from dual where not exists( select 1 from ld_tranlabel where tabid =@tabid and fieldlabel ='创建时间');
INSERT INTO `ld_tranlabel`(`languagetype`, `trantable`, `tabid`, `Relateid`, `fieldlabel`) select  'en', 'ld_field',  @tabid, @fieldid, 'Created Time' from dual where not exists( select 1 from ld_tranlabel where tabid =@tabid and fieldlabel ='Created Time');

set @fieldid = (select max(fieldid) from ld_field)+1;
INSERT INTO `ld_field` (`tabid`, `fieldid`, `columnname`, `allowhide`, `tablename`, `generatedtype`, `uitype`, `fieldname`, `fieldlabel`, `readonly`, `presence`, `defaultvalue`, `maximumlength`, `sequence`, `block`, `displaytype`, `typeofdata`, `quickcreate`, `quickcreatesequence`, `info_type`, `masseditable`, `helpinfo`, `fieldonly`, `issmownerid`, `searchfieldtype`, `associatedfields`, `associatedsequence`, `callchecked`, `duplicatefield`, `relate_search_parent_columnname`, `approve_demand`, `is_checkimportfield`, `allowedit`, `allowedit_presence`, `allowcreate`, `allowcreate_presence`, `allowdetail_presence`, `fldallow_rewriting`, `take_photo_only`, `savedatabase`, `bigtype`, `datarang`, `maxrowsshow`, `parentbigtype`, `profileeditfield`, `keywords`) select @tabid, @fieldid, 'modifiedby', 'yes', 'ld_socialpromotion', '1', '52', 'modifiedby', '最新更新人', '1', '0', NULL, NULL, '5', @blockid, '2', 'V~O', '1', NULL, NULL, '1', NULL, '0', '0', NULL, NULL, '0', '0', NULL, NULL, '2', '0', NULL, NULL, NULL, NULL, NULL, '0', '0', 'yes', NULL, NULL, '0', NULL, 'yes', NULL from dual where not exists( select 1 from ld_field where tabid= @tabid and fieldname='modifiedby');

INSERT INTO `ld_tranlabel`(`languagetype`, `trantable`, `tabid`, `Relateid`, `fieldlabel`) select 'zh', 'ld_field', @tabid, @fieldid, '最新更新人' from dual where not exists( select 1 from ld_tranlabel where tabid =@tabid and fieldlabel ='最新更新人');
INSERT INTO `ld_tranlabel`(`languagetype`, `trantable`, `tabid`, `Relateid`, `fieldlabel`) select 'en', 'ld_field', @tabid, @fieldid, 'Modified By' from dual where not exists( select 1 from ld_tranlabel where tabid =@tabid and fieldlabel ='Modified By');

set @fieldid = (select max(fieldid) from ld_field)+1;
INSERT INTO `ld_field` (`tabid`, `fieldid`, `columnname`, `allowhide`, `tablename`, `generatedtype`, `uitype`, `fieldname`, `fieldlabel`, `readonly`, `presence`, `defaultvalue`, `maximumlength`, `sequence`, `block`, `displaytype`, `typeofdata`, `quickcreate`, `quickcreatesequence`, `info_type`, `masseditable`, `helpinfo`, `fieldonly`, `issmownerid`, `searchfieldtype`, `associatedfields`, `associatedsequence`, `callchecked`, `duplicatefield`, `relate_search_parent_columnname`, `approve_demand`, `is_checkimportfield`, `allowedit`, `allowedit_presence`, `allowcreate`, `allowcreate_presence`, `allowdetail_presence`, `fldallow_rewriting`, `take_photo_only`, `savedatabase`, `bigtype`, `datarang`, `maxrowsshow`, `parentbigtype`, `profileeditfield`, `keywords`) select @tabid, @fieldid, 'modifiedtime', 'yes', 'ld_socialpromotion', '1', '70', 'modifiedtime', '更新时间', '1', '0', NULL, NULL, '6', @blockid, '2', 'DT~O', '1', NULL, NULL, '1', NULL, '0', '0', NULL, NULL, '0', '0', NULL, NULL, '2', '0', NULL, NULL, NULL, NULL, NULL, '0', '0', 'yes', 'datetime', NULL, '0', NULL, 'yes', NULL from dual where not exists( select 1 from ld_field where tabid= @tabid and fieldname='modifiedtime');
INSERT INTO `ld_tranlabel`(`languagetype`, `trantable`, `tabid`, `Relateid`, `fieldlabel`) SELECT 'zh', 'ld_field', @tabid, @fieldid, '更新时间' from dual where not exists( select 1 from ld_tranlabel where tabid =@tabid and fieldlabel ='更新时间');
INSERT INTO `ld_tranlabel`(`languagetype`, `trantable`, `tabid`, `Relateid`, `fieldlabel`) SELECT 'en', 'ld_field', @tabid, @fieldid, 'Modified Time' from dual where not exists( select 1 from ld_tranlabel where tabid =@tabid and fieldlabel ='Modified Time');

set @fieldid = (select max(fieldid) from ld_field)+1;
INSERT INTO `ld_field` (`tabid`, `fieldid`, `columnname`, `allowhide`, `tablename`, `generatedtype`, `uitype`, `fieldname`, `fieldlabel`, `readonly`, `presence`, `defaultvalue`, `maximumlength`, `sequence`, `block`, `displaytype`, `typeofdata`, `quickcreate`, `quickcreatesequence`, `info_type`, `masseditable`, `helpinfo`, `fieldonly`, `issmownerid`, `searchfieldtype`, `associatedfields`, `associatedsequence`, `callchecked`, `duplicatefield`, `relate_search_parent_columnname`, `approve_demand`, `is_checkimportfield`, `allowedit`, `allowedit_presence`, `allowcreate`, `allowcreate_presence`, `allowdetail_presence`, `fldallow_rewriting`, `take_photo_only`, `savedatabase`, `bigtype`, `datarang`, `maxrowsshow`, `parentbigtype`, `profileeditfield`, `keywords`) select @tabid, @fieldid, 'approvestatus', 'yes', 'ld_socialpromotion', '1', '609', 'approvestatus', '审批状态', '1', '0', NULL, NULL, '7', @blockid, '2', 'V~O', '1', NULL, NULL, '1', NULL, '0', '0', NULL, NULL, '0', '0', NULL, NULL, '2', '0', NULL, NULL, NULL, NULL, NULL, '0', '0', 'yes', NULL, NULL, '0', NULL, 'yes', NULL from dual where not exists( select 1 from ld_field where tabid= @tabid and fieldname='approvestatus');
INSERT INTO `ld_tranlabel`(`languagetype`, `trantable`, `tabid`, `Relateid`, `fieldlabel`) SELECT 'zh', 'ld_field', @tabid, @fieldid, '审批状态' from dual where not exists( select 1 from ld_tranlabel where tabid =@tabid and fieldlabel ='审批状态');
INSERT INTO `ld_tranlabel`(`languagetype`, `trantable`, `tabid`, `Relateid`, `fieldlabel`) SELECT 'en', 'ld_field', @tabid, @fieldid, 'Approve Status' from dual where not exists( select 1 from ld_tranlabel where tabid =@tabid and fieldlabel ='Approve Status');

set @fieldid = (select max(fieldid) from ld_field)+1;
INSERT INTO `ld_field` (`tabid`, `fieldid`, `columnname`, `allowhide`, `tablename`, `generatedtype`, `uitype`, `fieldname`, `fieldlabel`, `readonly`, `presence`, `defaultvalue`, `maximumlength`, `sequence`, `block`, `displaytype`, `typeofdata`, `quickcreate`, `quickcreatesequence`, `info_type`, `masseditable`, `helpinfo`, `fieldonly`, `issmownerid`, `searchfieldtype`, `associatedfields`, `associatedsequence`, `callchecked`, `duplicatefield`, `relate_search_parent_columnname`, `approve_demand`, `is_checkimportfield`, `allowedit`, `allowedit_presence`, `allowcreate`, `allowcreate_presence`, `allowdetail_presence`, `fldallow_rewriting`, `take_photo_only`, `savedatabase`, `bigtype`, `datarang`, `maxrowsshow`, `parentbigtype`, `profileeditfield`, `keywords`) select @tabid, @fieldid, 'approvetime', 'yes', 'ld_socialpromotion', '1', '70', 'approvetime', '最新审批时间', '1', '0', NULL, NULL, '8', @blockid, '2', 'DT~O', '1', NULL, NULL, '1', NULL, '0', '0', NULL, NULL, '0', '0', NULL, NULL, '2', '0', NULL, NULL, NULL, NULL, NULL, '0', '0', 'yes', 'datetime', NULL, '0', NULL, 'yes', NULL from dual where not exists( select 1 from ld_field where tabid= @tabid and fieldname='approvetime');
INSERT INTO `ld_tranlabel`(`languagetype`, `trantable`, `tabid`, `Relateid`, `fieldlabel`) SELECT 'zh', 'ld_field', @tabid, @fieldid, '最新审批时间' from dual where not exists( select 1 from ld_tranlabel where tabid =@tabid and fieldlabel ='最新审批时间');
INSERT INTO `ld_tranlabel`(`languagetype`, `trantable`, `tabid`, `Relateid`, `fieldlabel`) SELECT 'en', 'ld_field', @tabid, @fieldid, 'Last Approval Time' from dual where not exists( select 1 from ld_tranlabel where tabid =@tabid and fieldlabel ='Last Approval Time');

set @fieldid = (select max(fieldid) from ld_field)+1;
INSERT INTO `ld_field` (`tabid`, `fieldid`, `columnname`, `allowhide`, `tablename`, `generatedtype`, `uitype`, `fieldname`, `fieldlabel`, `readonly`, `presence`, `defaultvalue`, `maximumlength`, `sequence`, `block`, `displaytype`, `typeofdata`, `quickcreate`, `quickcreatesequence`, `info_type`, `masseditable`, `helpinfo`, `fieldonly`, `issmownerid`, `searchfieldtype`, `associatedfields`, `associatedsequence`, `callchecked`, `duplicatefield`, `relate_search_parent_columnname`, `approve_demand`, `is_checkimportfield`, `allowedit`, `allowedit_presence`, `allowcreate`, `allowcreate_presence`, `allowdetail_presence`, `fldallow_rewriting`, `take_photo_only`, `savedatabase`, `bigtype`, `datarang`, `maxrowsshow`, `parentbigtype`, `profileeditfield`, `keywords`) select @tabid, @fieldid, 'approveby', 'yes', 'ld_socialpromotion', '1', '131', 'approveby', '上一步审批人', '1', '0', NULL, NULL, '9', @blockid, '2', 'V~O', '1', NULL, NULL, '1', NULL, '0', '0', NULL, NULL, '0', '0', NULL, NULL, '2', '0', NULL, NULL, NULL, NULL, NULL, '0', '0', 'yes', NULL, NULL, '0', NULL, 'yes', NULL from dual where not exists( select 1 from ld_field where tabid= @tabid and fieldname='approveby');
INSERT INTO `ld_tranlabel`(`languagetype`, `trantable`, `tabid`, `Relateid`, `fieldlabel`) SELECT 'zh', 'ld_field', @tabid, @fieldid, '上一步审批人' from dual where not exists( select 1 from ld_tranlabel where tabid =@tabid and fieldlabel ='上一步审批人');
INSERT INTO `ld_tranlabel`(`languagetype`, `trantable`, `tabid`, `Relateid`, `fieldlabel`) SELECT 'en', 'ld_field', @tabid, @fieldid, 'The Last Approver' from dual where not exists( select 1 from ld_tranlabel where tabid =@tabid and fieldlabel ='The Last Approver');

set @fieldid = (select max(fieldid) from ld_field)+1;
INSERT INTO `ld_field` (`tabid`, `fieldid`, `columnname`, `allowhide`, `tablename`, `generatedtype`, `uitype`, `fieldname`, `fieldlabel`, `readonly`, `presence`, `defaultvalue`, `maximumlength`, `sequence`, `block`, `displaytype`, `typeofdata`, `quickcreate`, `quickcreatesequence`, `info_type`, `masseditable`, `helpinfo`, `fieldonly`, `issmownerid`, `searchfieldtype`, `associatedfields`, `associatedsequence`, `callchecked`, `duplicatefield`, `relate_search_parent_columnname`, `approve_demand`, `is_checkimportfield`, `allowedit`, `allowedit_presence`, `allowcreate`, `allowcreate_presence`, `allowdetail_presence`, `fldallow_rewriting`, `take_photo_only`, `savedatabase`, `bigtype`, `datarang`, `maxrowsshow`, `parentbigtype`, `profileeditfield`, `keywords`) select @tabid, @fieldid, 'currentapprover', 'yes', 'ld_socialpromotion', '1', '132', 'currentapprover', '当前审批人', '1', '0', NULL, NULL, '10', @blockid, '2', 'V~O', '1', NULL, NULL, '1', NULL, '0', '0', NULL, NULL, '0', '0', NULL, NULL, '2', '0', NULL, NULL, NULL, NULL, NULL, '0', '0', 'yes', NULL, NULL, '0', NULL, 'yes', NULL from dual where not exists( select 1 from ld_field where tabid= @tabid and fieldname='currentapprover');
INSERT INTO `ld_tranlabel`(`languagetype`, `trantable`, `tabid`, `Relateid`, `fieldlabel`) SELECT 'zh', 'ld_field', @tabid, @fieldid, '当前审批人' from dual where not exists( select 1 from ld_tranlabel where tabid =@tabid and fieldlabel ='当前审批人');
INSERT INTO `ld_tranlabel`(`languagetype`, `trantable`, `tabid`, `Relateid`, `fieldlabel`) SELECT 'en', 'ld_field', @tabid, @fieldid, 'Current Approver' from dual where not exists( select 1 from ld_tranlabel where tabid =@tabid and fieldlabel ='Current Approver');

set @fieldid = (select max(fieldid) from ld_field)+1;
INSERT INTO `ld_field` (`tabid`, `fieldid`, `columnname`, `allowhide`, `tablename`, `generatedtype`, `uitype`, `fieldname`, `fieldlabel`, `readonly`, `presence`, `defaultvalue`, `maximumlength`, `sequence`, `block`, `displaytype`, `typeofdata`, `quickcreate`, `quickcreatesequence`, `info_type`, `masseditable`, `helpinfo`, `fieldonly`, `issmownerid`, `searchfieldtype`, `associatedfields`, `associatedsequence`, `callchecked`, `duplicatefield`, `relate_search_parent_columnname`, `approve_demand`, `is_checkimportfield`, `allowedit`, `allowedit_presence`, `allowcreate`, `allowcreate_presence`, `allowdetail_presence`, `fldallow_rewriting`, `take_photo_only`, `savedatabase`, `bigtype`, `datarang`, `maxrowsshow`, `parentbigtype`, `profileeditfield`, `keywords`) select @tabid, @fieldid, 'advance_stage', 'yes', 'ld_socialpromotion', '1', '1', 'advance_stage', '推进阶段', '1', '1', NULL, '100', '13', @blockid, '3', 'V~O', '1', NULL, NULL, '1', NULL, '0', '0', NULL, NULL, '0', '0', NULL, NULL, '1', '0', NULL, NULL, NULL, NULL, NULL, '0', '0', 'yes', '', NULL, '0', NULL, 'yes', NULL from dual where not exists( select 1 from ld_field where tabid= @tabid and fieldname='advance_stage');
INSERT INTO `ld_tranlabel`(`languagetype`, `trantable`, `tabid`, `Relateid`, `fieldlabel`) SELECT 'zh', 'ld_field', @tabid, @fieldid, '推进阶段' from dual where not exists( select 1 from ld_tranlabel where tabid =@tabid and fieldlabel ='推进阶段');
INSERT INTO `ld_tranlabel`(`languagetype`, `trantable`, `tabid`, `Relateid`, `fieldlabel`) SELECT 'en', 'ld_field', @tabid, @fieldid, 'Advance Stage' from dual where not exists( select 1 from ld_tranlabel where tabid =@tabid and fieldlabel ='Advance Stage');

set @fieldid = (select max(fieldid) from ld_field) +1;
INSERT INTO `ld_field` (`tabid`, `fieldid`, `columnname`, `allowhide`, `tablename`, `generatedtype`, `uitype`, `fieldname`, `fieldlabel`, `readonly`, `presence`, `defaultvalue`, `maximumlength`, `sequence`, `block`, `displaytype`, `typeofdata`, `quickcreate`, `quickcreatesequence`, `info_type`, `masseditable`, `helpinfo`, `fieldonly`, `issmownerid`, `searchfieldtype`, `associatedfields`, `associatedsequence`, `callchecked`, `duplicatefield`, `relate_search_parent_columnname`, `approve_demand`, `is_checkimportfield`, `allowedit`, `allowedit_presence`, `allowcreate`, `allowcreate_presence`, `allowdetail_presence`, `fldallow_rewriting`, `take_photo_only`, `savedatabase`, `bigtype`, `datarang`, `maxrowsshow`, `parentbigtype`, `profileeditfield`, `keywords`) select @tabid, @fieldid, 'activityviews', 'yes', 'ld_socialpromotion', 2, '1', 'activityviews', '浏览量', 1, 2, '', 100, 10, @blockid, 2, 'V~O', 0, 0, 'BAS', 1, NULL, 0, 0, NULL, NULL, 0, 0, NULL, NULL, 0, 0, '', NULL, NULL, NULL, NULL, 0, 0, 'yes', 'text', 'all', 5, NULL, 'yes', NULL from dual where not exists( select 1 from ld_field where tabid= @tabid and fieldname='activityviews');

INSERT INTO `ld_tranlabel`( `languagetype`, `trantable`, `tabid`, `Relateid`, `fieldlabel`) select  'zh', 'ld_field', @tabid, @fieldid, '浏览量' from dual where not exists ( select 1 from ld_tranlabel where tabid =@tabid and fieldlabel ='浏览量');
INSERT INTO `ld_tranlabel`( `languagetype`, `trantable`, `tabid`, `Relateid`, `fieldlabel`) select 'en', 'ld_field', @tabid, @fieldid, 'Activity Views' from dual where not exists ( select 1 from ld_tranlabel where tabid =@tabid and fieldlabel ='Activity Views');

set @fieldid = (select max(fieldid) from ld_field) +1;
INSERT INTO `ld_field` (`tabid`, `fieldid`, `columnname`, `allowhide`, `tablename`, `generatedtype`, `uitype`, `fieldname`, `fieldlabel`, `readonly`, `presence`, `defaultvalue`, `maximumlength`, `sequence`, `block`, `displaytype`, `typeofdata`, `quickcreate`, `quickcreatesequence`, `info_type`, `masseditable`, `helpinfo`, `fieldonly`, `issmownerid`, `searchfieldtype`, `associatedfields`, `associatedsequence`, `callchecked`, `duplicatefield`, `relate_search_parent_columnname`, `approve_demand`, `is_checkimportfield`, `allowedit`, `allowedit_presence`, `allowcreate`, `allowcreate_presence`, `allowdetail_presence`, `fldallow_rewriting`, `take_photo_only`, `savedatabase`, `bigtype`, `datarang`, `maxrowsshow`, `parentbigtype`, `profileeditfield`, `keywords`) select @tabid, @fieldid, 'documentquantity', 'yes', 'ld_socialpromotion', 2, '1', 'documentquantity', '单据数量', 1, 2, '', 100, 11, @blockid, 2, 'V~O', 0, 0, 'BAS', 1, NULL, 0, 0, NULL, NULL, 0, 0, NULL, NULL, 0, 0, '', NULL, NULL, NULL, NULL, 0, 0, 'yes', 'text', 'all', 5, NULL, 'yes', NULL from dual where not exists( select 1 from ld_field where tabid= @tabid and fieldname='documentquantity');

INSERT INTO `ld_tranlabel`( `languagetype`, `trantable`, `tabid`, `Relateid`, `fieldlabel`) select  'zh', 'ld_field', @tabid, @fieldid, '单据数量' from dual where not exists ( select 1 from ld_tranlabel where tabid =@tabid and fieldlabel ='单据数量');
INSERT INTO `ld_tranlabel`( `languagetype`, `trantable`, `tabid`, `Relateid`, `fieldlabel`) select 'en', 'ld_field', @tabid, @fieldid, 'Document Quantity' from dual where not exists ( select 1 from ld_tranlabel where tabid =@tabid and fieldlabel ='Document Quantity');

set @blockid = (SELECT MAX(blockid) FROM ld_blocks)+1;
INSERT INTO `ld_blocks` (`blockid`, `tabid`, `blocklabel`, `sequence`, `show_title`, `visible`, `create_view`, `edit_view`, `detail_view`, `display_status`, `iscustom`, `linkid`) 
select @blockid, @tabid, '第一步', 2, NULL, 0, 0, 0, 0, 1, 1, NULL from dual 
where not exists (select 1 from ld_blocks where tabid =@tabid and blocklabel ='第一步');

INSERT INTO `ld_tranlabel`(`languagetype`, `trantable`, `tabid`, `Relateid`, `fieldlabel`) select 'zh', 'ld_blocks', @tabid, @blockid, '第一步' from dual where not exists (select 1 from ld_tranlabel where  tabid =@tabid and languagetype ='zh' and fieldlabel ='第一步');
INSERT INTO `ld_tranlabel`( `languagetype`, `trantable`, `tabid`, `Relateid`, `fieldlabel`) select  'en', 'ld_blocks', @tabid, @blockid, 'Step1' from dual where not exists (select 1 from ld_tranlabel where  tabid =@tabid and languagetype ='en' and fieldlabel ='Step1');

set @fieldid = (select max(fieldid) from ld_field) +1;
INSERT INTO `ld_field` (`tabid`, `fieldid`, `columnname`, `allowhide`, `tablename`, `generatedtype`, `uitype`, `fieldname`, `fieldlabel`, `readonly`, `presence`, `defaultvalue`, `maximumlength`, `sequence`, `block`, `displaytype`, `typeofdata`, `quickcreate`, `quickcreatesequence`, `info_type`, `masseditable`, `helpinfo`, `fieldonly`, `issmownerid`, `searchfieldtype`, `associatedfields`, `associatedsequence`, `callchecked`, `duplicatefield`, `relate_search_parent_columnname`, `approve_demand`, `is_checkimportfield`, `allowedit`, `allowedit_presence`, `allowcreate`, `allowcreate_presence`, `allowdetail_presence`, `fldallow_rewriting`, `take_photo_only`, `savedatabase`, `bigtype`, `datarang`, `maxrowsshow`, `parentbigtype`, `profileeditfield`, `keywords`) select  @tabid, @fieldid, 'socialpromotion_no', 'no', 'ld_socialpromotion', 1, '4', 'socialpromotion_no', '单据编号', 1, 0, NULL, NULL, 1, @blockid, 1, 'V~M', 1, NULL, NULL, 0, NULL, 0, 0, 0, NULL, 0, 0, NULL, NULL, 2, 0, NULL, NULL, NULL, NULL, NULL, 0, 0, 'yes', NULL, NULL, 0, NULL, 'yes', 'yes' from dual where not exists( select 1 from ld_field where tabid= @tabid and fieldname='socialpromotion_no');

INSERT INTO `ld_tranlabel`( `languagetype`, `trantable`, `tabid`, `Relateid`, `fieldlabel`) select  'zh', 'ld_field', @tabid, @fieldid, '单据编号' from dual where not exists ( select 1 from ld_tranlabel where tabid =@tabid and fieldlabel ='单据编号');
INSERT INTO `ld_tranlabel`( `languagetype`, `trantable`, `tabid`, `Relateid`, `fieldlabel`) select 'en', 'ld_field', @tabid, @fieldid, 'Bill NO.' from dual where not exists ( select 1 from ld_tranlabel where tabid =@tabid and fieldlabel ='Bill NO.');

set @fieldid = (select max(fieldid) from ld_field) +1;
INSERT INTO `ld_field` (`tabid`, `fieldid`, `columnname`, `allowhide`, `tablename`, `generatedtype`, `uitype`, `fieldname`, `fieldlabel`, `readonly`, `presence`, `defaultvalue`, `maximumlength`, `sequence`, `block`, `displaytype`, `typeofdata`, `quickcreate`, `quickcreatesequence`, `info_type`, `masseditable`, `helpinfo`, `fieldonly`, `issmownerid`, `searchfieldtype`, `associatedfields`, `associatedsequence`, `callchecked`, `duplicatefield`, `relate_search_parent_columnname`, `approve_demand`, `is_checkimportfield`, `allowedit`, `allowedit_presence`, `allowcreate`, `allowcreate_presence`, `allowdetail_presence`, `fldallow_rewriting`, `take_photo_only`, `savedatabase`, `bigtype`, `datarang`, `maxrowsshow`, `parentbigtype`, `profileeditfield`, `keywords`) select @tabid, @fieldid, 'smownerid', 'no', 'ld_socialpromotion', 1, '53', 'assigned_user_id', '负责人', 1, 0, NULL, NULL, 4, @blockid, 1, 'V~M', 1, NULL, NULL, 1, NULL, 0, 1, 1, NULL, 0, 0, NULL, NULL, 2, 0, NULL, NULL, NULL, NULL, NULL, 0, 0, 'yes', 'users', NULL, 0, NULL, 'yes', 'yes' from dual where not exists( select 1 from ld_field where tabid= @tabid and fieldname='assigned_user_id');

INSERT INTO `ld_tranlabel`( `languagetype`, `trantable`, `tabid`, `Relateid`, `fieldlabel`) select 'zh', 'ld_field', @tabid, @fieldid, '负责人' from dual where not exists( select 1 from ld_tranlabel where tabid =@tabid and fieldlabel ='负责人');
INSERT INTO `ld_tranlabel`( `languagetype`, `trantable`, `tabid`, `Relateid`, `fieldlabel`) select 'en', 'ld_field', @tabid, @fieldid, 'Assigned To' from dual where not exists( select 1 from ld_tranlabel where tabid =@tabid and fieldlabel ='Assigned To');

set @fieldid = (select max(fieldid) from ld_field) +1;
INSERT INTO `ld_field` (`tabid`, `fieldid`, `columnname`, `allowhide`, `tablename`, `generatedtype`, `uitype`, `fieldname`, `fieldlabel`, `readonly`, `presence`, `defaultvalue`, `maximumlength`, `sequence`, `block`, `displaytype`, `typeofdata`, `quickcreate`, `quickcreatesequence`, `info_type`, `masseditable`, `helpinfo`, `fieldonly`, `issmownerid`, `searchfieldtype`, `associatedfields`, `associatedsequence`, `callchecked`, `duplicatefield`, `relate_search_parent_columnname`, `approve_demand`, `is_checkimportfield`, `allowedit`, `allowedit_presence`, `allowcreate`, `allowcreate_presence`, `allowdetail_presence`, `fldallow_rewriting`, `take_photo_only`, `savedatabase`, `bigtype`, `datarang`, `maxrowsshow`, `parentbigtype`, `profileeditfield`, `keywords`) select @tabid, @fieldid, 'activityname', 'yes', 'ld_socialpromotion', 1, '1', 'activityname', '活动名称', 0, 2, '', 100, 1, @blockid, 1, 'V~M', 0, 0, 'BAS', 1, NULL, 0, 0, NULL, NULL, 0, 0, NULL, NULL, 0, 0, 'yes', NULL, NULL, NULL, NULL, 0, 0, 'yes', 'text', 'all', 5, NULL, 'yes', NULL from dual where not exists( select 1 from ld_field where tabid= @tabid and fieldname='activityname');

INSERT INTO `ld_tranlabel`( `languagetype`, `trantable`, `tabid`, `Relateid`, `fieldlabel`) select  'zh', 'ld_field', @tabid, @fieldid, '活动名称' from dual where not exists ( select 1 from ld_tranlabel where tabid =@tabid and fieldlabel ='活动名称');
INSERT INTO `ld_tranlabel`( `languagetype`, `trantable`, `tabid`, `Relateid`, `fieldlabel`) select 'en', 'ld_field', @tabid, @fieldid, 'Activity Name' from dual where not exists ( select 1 from ld_tranlabel where tabid =@tabid and fieldlabel ='Activity Name');

set @fieldid = (select max(fieldid) from ld_field) +1;
INSERT INTO `ld_field` (`tabid`, `fieldid`, `columnname`, `allowhide`, `tablename`, `generatedtype`, `uitype`, `fieldname`, `fieldlabel`, `readonly`, `presence`, `defaultvalue`, `maximumlength`, `sequence`, `block`, `displaytype`, `typeofdata`, `quickcreate`, `quickcreatesequence`, `info_type`, `masseditable`, `helpinfo`, `fieldonly`, `issmownerid`, `searchfieldtype`, `associatedfields`, `associatedsequence`, `callchecked`, `duplicatefield`, `relate_search_parent_columnname`, `approve_demand`, `is_checkimportfield`, `allowedit`, `allowedit_presence`, `allowcreate`, `allowcreate_presence`, `allowdetail_presence`, `fldallow_rewriting`, `take_photo_only`, `savedatabase`, `bigtype`, `datarang`, `maxrowsshow`, `parentbigtype`, `profileeditfield`, `keywords`) select @tabid, @fieldid, 'activitystate', 'yes', 'ld_socialpromotion', 2, '15', 'activitystate', '活动状态', 0, 2, '执行中', 100, 2, @blockid, 1, 'V~O', 0, 0, 'BAS', 1, NULL, 0, 0, NULL, NULL, 0, 0, NULL, NULL, 0, 0, 'yes', NULL, NULL, NULL, NULL, 0, 0, 'yes', 'picklist', 'all', 5, NULL, 'yes', NULL from dual where not exists( select 1 from ld_field where tabid= @tabid and fieldname='activitystate');

INSERT INTO `ld_tranlabel`( `languagetype`, `trantable`, `tabid`, `Relateid`, `fieldlabel`) select  'zh', 'ld_field', @tabid, @fieldid, '活动状态' from dual where not exists ( select 1 from ld_tranlabel where tabid =@tabid and fieldlabel ='活动状态');
INSERT INTO `ld_tranlabel`( `languagetype`, `trantable`, `tabid`, `Relateid`, `fieldlabel`) select 'en', 'ld_field', @tabid, @fieldid, 'Activity State' from dual where not exists ( select 1 from ld_tranlabel where tabid =@tabid and fieldlabel ='Activity State');

INSERT INTO `ld_picklist_set`(`listname`, `relatetable`, `parent_listname`, `parent_relatetable`) select  'activitystate', 'ld_field', NULL, NULL from dual  where not exists (select 1 from ld_picklist_set where listname ='activitystate');
set @listid = (select listid  from ld_picklist_set where listname ='activitystate');

INSERT INTO `ld_picklist_values`( `listid`, `listvalue`, `sequence` ) select @listid, '执行中', 1 from dual where not exists (select 1 from ld_picklist_values where listvalue='执行中' and listid =@listid);
INSERT INTO `ld_picklist_values`( `listid`, `listvalue`, `sequence`) SELECT  @listid, '已关闭', 2 from dual where not exists (select 1 from ld_picklist_values where listvalue='已关闭' and listid =@listid);


set @fieldid = (select max(fieldid) from ld_field) +1;
INSERT INTO `ld_field` (`tabid`, `fieldid`, `columnname`, `allowhide`, `tablename`, `generatedtype`, `uitype`, `fieldname`, `fieldlabel`, `readonly`, `presence`, `defaultvalue`, `maximumlength`, `sequence`, `block`, `displaytype`, `typeofdata`, `quickcreate`, `quickcreatesequence`, `info_type`, `masseditable`, `helpinfo`, `fieldonly`, `issmownerid`, `searchfieldtype`, `associatedfields`, `associatedsequence`, `callchecked`, `duplicatefield`, `relate_search_parent_columnname`, `approve_demand`, `is_checkimportfield`, `allowedit`, `allowedit_presence`, `allowcreate`, `allowcreate_presence`, `allowdetail_presence`, `fldallow_rewriting`, `take_photo_only`, `savedatabase`, `bigtype`, `datarang`, `maxrowsshow`, `parentbigtype`, `profileeditfield`, `keywords`) select @tabid, @fieldid, 'mappingmodule', 'yes', 'ld_socialpromotion', 2, '15', 'mappingmodule', '映射单据', 0, 2, '客户', 100, 3, @blockid, 1, 'V~O', 0, 0, 'BAS', 1, NULL, 0, 0, NULL, NULL, 0, 0, NULL, NULL, 0, 0, 'yes', NULL, NULL, NULL, NULL, 0, 0, 'yes', 'picklist', 'all', 5, NULL, 'yes', NULL from dual where not exists( select 1 from ld_field where tabid= @tabid and fieldname='mappingmodule');

INSERT INTO `ld_tranlabel`( `languagetype`, `trantable`, `tabid`, `Relateid`, `fieldlabel`) select  'zh', 'ld_field', @tabid, @fieldid, '映射单据' from dual where not exists ( select 1 from ld_tranlabel where tabid =@tabid and fieldlabel ='映射单据');
INSERT INTO `ld_tranlabel`( `languagetype`, `trantable`, `tabid`, `Relateid`, `fieldlabel`) select 'en', 'ld_field', @tabid, @fieldid, 'Mapping Module' from dual where not exists ( select 1 from ld_tranlabel where tabid =@tabid and fieldlabel ='Mapping Module');

INSERT INTO `ld_picklist_set`(`listname`, `relatetable`, `parent_listname`, `parent_relatetable`) select  'mappingmodule', 'ld_field', NULL, NULL from dual  where not exists (select 1 from ld_picklist_set where listname ='mappingmodule');
set @listid = (select listid  from ld_picklist_set where listname ='mappingmodule');

INSERT INTO `ld_picklist_values`( `listid`, `listvalue`, `sequence` ) select @listid, '客户', 1 from dual where not exists (select 1 from ld_picklist_values where listvalue='客户' and listid =@listid);
INSERT INTO `ld_picklist_values`( `listid`, `listvalue`, `sequence`) SELECT  @listid, '销售线索', 2 from dual where not exists (select 1 from ld_picklist_values where listvalue='销售线索' and listid =@listid);

set @fieldid = (select max(fieldid) from ld_field) +1;
INSERT INTO `ld_field` (`tabid`, `fieldid`, `columnname`, `allowhide`, `tablename`, `generatedtype`, `uitype`, `fieldname`, `fieldlabel`, `readonly`, `presence`, `defaultvalue`, `maximumlength`, `sequence`, `block`, `displaytype`, `typeofdata`, `quickcreate`, `quickcreatesequence`, `info_type`, `masseditable`, `helpinfo`, `fieldonly`, `issmownerid`, `searchfieldtype`, `associatedfields`, `associatedsequence`, `callchecked`, `duplicatefield`, `relate_search_parent_columnname`, `approve_demand`, `is_checkimportfield`, `allowedit`, `allowedit_presence`, `allowcreate`, `allowcreate_presence`, `allowdetail_presence`, `fldallow_rewriting`, `take_photo_only`, `savedatabase`, `bigtype`, `datarang`, `maxrowsshow`, `parentbigtype`, `profileeditfield`, `keywords`) select @tabid, @fieldid, 'social_activitytype', 'yes', 'ld_socialpromotion', 2, '15', 'social_activitytype', '活动类型', 0, 2, '仅表单', 100, 5, @blockid, 1, 'V~O', 0, 0, 'BAS', 1, NULL, 0, 0, NULL, NULL, 0, 0, NULL, NULL, 0, 0, 'yes', NULL, NULL, NULL, NULL, 0, 0, 'yes', 'picklist', 'all', 5, NULL, 'yes', NULL from dual where not exists( select 1 from ld_field where tabid= @tabid and fieldname='social_activitytype');

INSERT INTO `ld_tranlabel`( `languagetype`, `trantable`, `tabid`, `Relateid`, `fieldlabel`) select  'zh', 'ld_field', @tabid, @fieldid, '活动类型' from dual where not exists ( select 1 from ld_tranlabel where tabid =@tabid and fieldlabel ='活动类型');
INSERT INTO `ld_tranlabel`( `languagetype`, `trantable`, `tabid`, `Relateid`, `fieldlabel`) select 'en', 'ld_field', @tabid, @fieldid, 'Activity Type' from dual where not exists ( select 1 from ld_tranlabel where tabid =@tabid and fieldlabel ='Activity Type');


INSERT INTO `ld_picklist_set`(`listname`, `relatetable`, `parent_listname`, `parent_relatetable`) select  'social_activitytype', 'ld_field', NULL, NULL from dual  where not exists (select 1 from ld_picklist_set where listname ='social_activitytype');
set @listid = (select listid  from ld_picklist_set where listname ='social_activitytype');
delimiter;

select tabid into @tabid from ld_tab where name='SocialPromotion';
INSERT INTO `ld_picklist_values`( `listid`, `listvalue`, `sequence` ) select @listid, '仅表单', 1 from dual where not exists (select 1 from ld_picklist_values where listvalue='仅表单' and listid =@listid);
INSERT INTO `ld_picklist_values`( `listid`, `listvalue`, `sequence`) SELECT  @listid, 'H5页面链接 + 表单', 2 from dual where not exists (select 1 from ld_picklist_values where listvalue='H5页面链接 + 表单' and listid =@listid);

set @fieldid = (select max(fieldid) from ld_field) +1;
INSERT INTO `ld_field` (`tabid`, `fieldid`, `columnname`, `allowhide`, `tablename`, `generatedtype`, `uitype`, `fieldname`, `fieldlabel`, `readonly`, `presence`, `defaultvalue`, `maximumlength`, `sequence`, `block`, `displaytype`, `typeofdata`, `quickcreate`, `quickcreatesequence`, `info_type`, `masseditable`, `helpinfo`, `fieldonly`, `issmownerid`, `searchfieldtype`, `associatedfields`, `associatedsequence`, `callchecked`, `duplicatefield`, `relate_search_parent_columnname`, `approve_demand`, `is_checkimportfield`, `allowedit`, `allowedit_presence`, `allowcreate`, `allowcreate_presence`, `allowdetail_presence`, `fldallow_rewriting`, `take_photo_only`, `savedatabase`, `bigtype`, `datarang`, `maxrowsshow`, `parentbigtype`, `profileeditfield`, `keywords`) select @tabid, @fieldid, 'h5pageurl', 'yes', 'ld_socialpromotionscf', 2, '1', 'h5pageurl', 'H5页面链接地址', 0, 2, '', 100, 6, 359, 1, 'V~O', 0, 0, 'BAS', 1, NULL, 0, 0, NULL, NULL, 0, 0, NULL, NULL, 0, 0, 'yes', NULL, NULL, NULL, NULL, 0, 0, 'yes', 'url', 'all', 5, NULL, 'yes', NULL from dual where not exists( select 1 from ld_field where tabid= @tabid and fieldname='h5pageurl');

INSERT INTO `ld_tranlabel`( `languagetype`, `trantable`, `tabid`, `Relateid`, `fieldlabel`) select  'zh', 'ld_field', @tabid, @fieldid, 'H5页面链接地址' from dual where not exists ( select 1 from ld_tranlabel where tabid =@tabid and fieldlabel ='H5页面链接地址');
INSERT INTO `ld_tranlabel`( `languagetype`, `trantable`, `tabid`, `Relateid`, `fieldlabel`) select 'en', 'ld_field', @tabid, @fieldid, 'H5 Page URL' from dual where not exists ( select 1 from ld_tranlabel where tabid =@tabid and fieldlabel ='H5 Page URL');

set @fieldid = (select max(fieldid) from ld_field) +1;
INSERT INTO `ld_field` (`tabid`, `fieldid`, `columnname`, `allowhide`, `tablename`, `generatedtype`, `uitype`, `fieldname`, `fieldlabel`, `readonly`, `presence`, `defaultvalue`, `maximumlength`, `sequence`, `block`, `displaytype`, `typeofdata`, `quickcreate`, `quickcreatesequence`, `info_type`, `masseditable`, `helpinfo`, `fieldonly`, `issmownerid`, `searchfieldtype`, `associatedfields`, `associatedsequence`, `callchecked`, `duplicatefield`, `relate_search_parent_columnname`, `approve_demand`, `is_checkimportfield`, `allowedit`, `allowedit_presence`, `allowcreate`, `allowcreate_presence`, `allowdetail_presence`, `fldallow_rewriting`, `take_photo_only`, `savedatabase`, `bigtype`, `datarang`, `maxrowsshow`, `parentbigtype`, `profileeditfield`, `keywords`) select @tabid, @fieldid, 'h5pagebutton', 'yes', 'ld_socialpromotionscf', 2, '1', 'h5pagebutton', 'H5页面按钮名称', 0, 2, '我要报名', 100, 7, 359, 1, 'V~O~LE~50', 0, 0, 'BAS', 1, NULL, 0, 0, NULL, NULL, 0, 0, NULL, NULL, 0, 0, 'yes', NULL, NULL, NULL, NULL, 0, 0, 'yes', 'text', 'all', 5, NULL, 'yes', NULL from dual where not exists( select 1 from ld_field where tabid= @tabid and fieldname='h5pagebutton');

INSERT INTO `ld_tranlabel`( `languagetype`, `trantable`, `tabid`, `Relateid`, `fieldlabel`) select  'zh', 'ld_field', @tabid, @fieldid, 'H5页面按钮名称' from dual where not exists ( select 1 from ld_tranlabel where tabid =@tabid and fieldlabel ='H5页面按钮名称');
INSERT INTO `ld_tranlabel`( `languagetype`, `trantable`, `tabid`, `Relateid`, `fieldlabel`) select 'en', 'ld_field', @tabid, @fieldid, 'H5 Page Button' from dual where not exists ( select 1 from ld_tranlabel where tabid =@tabid and fieldlabel ='H5 Page Button');

set @fieldid = (select max(fieldid) from ld_field) +1;
INSERT INTO `ld_field` (`tabid`, `fieldid`, `columnname`, `allowhide`, `tablename`, `generatedtype`, `uitype`, `fieldname`, `fieldlabel`, `readonly`, `presence`, `defaultvalue`, `maximumlength`, `sequence`, `block`, `displaytype`, `typeofdata`, `quickcreate`, `quickcreatesequence`, `info_type`, `masseditable`, `helpinfo`, `fieldonly`, `issmownerid`, `searchfieldtype`, `associatedfields`, `associatedsequence`, `callchecked`, `duplicatefield`, `relate_search_parent_columnname`, `approve_demand`, `is_checkimportfield`, `allowedit`, `allowedit_presence`, `allowcreate`, `allowcreate_presence`, `allowdetail_presence`, `fldallow_rewriting`, `take_photo_only`, `savedatabase`, `bigtype`, `datarang`, `maxrowsshow`, `parentbigtype`, `profileeditfield`, `keywords`) select @tabid, @fieldid, 'H5buttoncolor', 'yes', 'ld_socialpromotionscf', 2, '1', 'H5buttoncolor', 'H5页面按钮颜色', 0, 2, '#00aaef', 100, 8, @blockid, 1, 'V~O~LE~50', 0, 0, 'BAS', 1, NULL, 0, 0, NULL, NULL, 0, 0, NULL, NULL, 0, 0, 'yes', NULL, NULL, NULL, NULL, 0, 0, 'yes', 'text', 'all', 5, NULL, 'yes', NULL from dual where not exists( select 1 from ld_field where tabid= @tabid and fieldname='H5buttoncolor');

INSERT INTO `ld_tranlabel`( `languagetype`, `trantable`, `tabid`, `Relateid`, `fieldlabel`) select  'zh', 'ld_field', @tabid, @fieldid, 'H5页面按钮颜色' from dual where not exists ( select 1 from ld_tranlabel where tabid =@tabid and fieldlabel ='H5页面按钮颜色');
INSERT INTO `ld_tranlabel`( `languagetype`, `trantable`, `tabid`, `Relateid`, `fieldlabel`) select 'en', 'ld_field', @tabid, @fieldid, 'H5 Button Color' from dual where not exists ( select 1 from ld_tranlabel where tabid =@tabid and fieldlabel ='H5 Button Color');

set @blockid = (SELECT MAX(blockid) FROM ld_blocks)+1;
INSERT INTO `ld_blocks` (`blockid`, `tabid`, `blocklabel`, `sequence`, `show_title`, `visible`, `create_view`, `edit_view`, `detail_view`, `display_status`, `iscustom`, `linkid`) select @blockid, @tabid, '第二步', 3, NULL, 0, 0, 0, 0, 1, 1, NULL from dual where not exists (select 1 from ld_blocks where tabid =@tabid and blocklabel ='第二步');

INSERT INTO `ld_tranlabel`(`languagetype`, `trantable`, `tabid`, `Relateid`, `fieldlabel`) select 'zh', 'ld_blocks', @tabid, @blockid, '第二步' from dual where not exists (select 1 from ld_tranlabel where  tabid =@tabid and languagetype ='zh' and fieldlabel ='第二步');
INSERT INTO `ld_tranlabel`( `languagetype`, `trantable`, `tabid`, `Relateid`, `fieldlabel`) select  'en', 'ld_blocks', @tabid, @blockid, 'Step2' from dual where not exists (select 1 from ld_tranlabel where  tabid =@tabid and languagetype ='en' and fieldlabel ='Step2');

set @fieldid = (select max(fieldid) from ld_field) +1;
INSERT INTO `ld_field` (`tabid`, `fieldid`, `columnname`, `allowhide`, `tablename`, `generatedtype`, `uitype`, `fieldname`, `fieldlabel`, `readonly`, `presence`, `defaultvalue`, `maximumlength`, `sequence`, `block`, `displaytype`, `typeofdata`, `quickcreate`, `quickcreatesequence`, `info_type`, `masseditable`, `helpinfo`, `fieldonly`, `issmownerid`, `searchfieldtype`, `associatedfields`, `associatedsequence`, `callchecked`, `duplicatefield`, `relate_search_parent_columnname`, `approve_demand`, `is_checkimportfield`, `allowedit`, `allowedit_presence`, `allowcreate`, `allowcreate_presence`, `allowdetail_presence`, `fldallow_rewriting`, `take_photo_only`, `savedatabase`, `bigtype`, `datarang`, `maxrowsshow`, `parentbigtype`, `profileeditfield`, `keywords`) select @tabid, @fieldid, 'activitytitle', 'yes', 'ld_socialpromotionscf', 2, '1', 'activitytitle', '活动标题', 0, 2, '', 100, 1, @blockid, 1, 'V~O~LE~255', 0, 0, 'BAS', 1, NULL, 0, 0, NULL, NULL, 0, 0, NULL, NULL, 0, 0, 'yes', NULL, NULL, NULL, NULL, 0, 0, 'yes', 'text', 'all', 5, NULL, 'yes', NULL from dual where not exists( select 1 from ld_field where tabid= @tabid and fieldname='activitytitle');

INSERT INTO `ld_tranlabel`( `languagetype`, `trantable`, `tabid`, `Relateid`, `fieldlabel`) select  'zh', 'ld_field', @tabid, @fieldid, '活动标题' from dual where not exists ( select 1 from ld_tranlabel where tabid =@tabid and fieldlabel ='活动标题');
INSERT INTO `ld_tranlabel`( `languagetype`, `trantable`, `tabid`, `Relateid`, `fieldlabel`) select 'en', 'ld_field', @tabid, @fieldid, 'Activity Title' from dual where not exists ( select 1 from ld_tranlabel where tabid =@tabid and fieldlabel ='Activity Title');

set @fieldid = (select max(fieldid) from ld_field) +1;
INSERT INTO `ld_field` (`tabid`, `fieldid`, `columnname`, `allowhide`, `tablename`, `generatedtype`, `uitype`, `fieldname`, `fieldlabel`, `readonly`, `presence`, `defaultvalue`, `maximumlength`, `sequence`, `block`, `displaytype`, `typeofdata`, `quickcreate`, `quickcreatesequence`, `info_type`, `masseditable`, `helpinfo`, `fieldonly`, `issmownerid`, `searchfieldtype`, `associatedfields`, `associatedsequence`, `callchecked`, `duplicatefield`, `relate_search_parent_columnname`, `approve_demand`, `is_checkimportfield`, `allowedit`, `allowedit_presence`, `allowcreate`, `allowcreate_presence`, `allowdetail_presence`, `fldallow_rewriting`, `take_photo_only`, `savedatabase`, `bigtype`, `datarang`, `maxrowsshow`, `parentbigtype`, `profileeditfield`, `keywords`) select @tabid, @fieldid, 'activityIntroduction', 'yes', 'ld_socialpromotionscf', 2, '21', 'activityintroduction', '活动说明', 0, 2, '', 100, 2, @blockid, 1, 'V~O', 0, 0, 'BAS', 1, NULL, 0, 0, NULL, NULL, 0, 0, NULL, NULL, 0, 0, 'yes', NULL, NULL, NULL, NULL, 0, 0, 'yes', 'textarea', 'all', 5, NULL, 'yes', NULL from dual where not exists( select 1 from ld_field where tabid= @tabid and fieldname='activityintroduction');

INSERT INTO `ld_tranlabel`( `languagetype`, `trantable`, `tabid`, `Relateid`, `fieldlabel`) select  'zh', 'ld_field', @tabid, @fieldid, '活动说明' from dual where not exists ( select 1 from ld_tranlabel where tabid =@tabid and fieldlabel ='活动说明');
INSERT INTO `ld_tranlabel`( `languagetype`, `trantable`, `tabid`, `Relateid`, `fieldlabel`) select 'en', 'ld_field', @tabid, @fieldid, 'Introduction' from dual where not exists ( select 1 from ld_tranlabel where tabid =@tabid and fieldlabel ='Introduction');

set @fieldid = (select max(fieldid) from ld_field) +1;
INSERT INTO `ld_field` (`tabid`, `fieldid`, `columnname`, `allowhide`, `tablename`, `generatedtype`, `uitype`, `fieldname`, `fieldlabel`, `readonly`, `presence`, `defaultvalue`, `maximumlength`, `sequence`, `block`, `displaytype`, `typeofdata`, `quickcreate`, `quickcreatesequence`, `info_type`, `masseditable`, `helpinfo`, `fieldonly`, `issmownerid`, `searchfieldtype`, `associatedfields`, `associatedsequence`, `callchecked`, `duplicatefield`, `relate_search_parent_columnname`, `approve_demand`, `is_checkimportfield`, `allowedit`, `allowedit_presence`, `allowcreate`, `allowcreate_presence`, `allowdetail_presence`, `fldallow_rewriting`, `take_photo_only`, `savedatabase`, `bigtype`, `datarang`, `maxrowsshow`, `parentbigtype`, `profileeditfield`, `keywords`) select @tabid, @fieldid, 'buttonname', 'yes', 'ld_socialpromotionscf', 2, '1', 'buttonname', '按钮名称', 0, 2, '提交', 100, 4, @blockid, 1, 'V~O', 0, 0, 'BAS', 1, NULL, 0, 0, NULL, NULL, 0, 0, NULL, NULL, 0, 0, 'yes', NULL, NULL, NULL, NULL, 0, 0, 'yes', 'text', 'all', 5, NULL, 'yes', NULL from dual where not exists( select 1 from ld_field where tabid= @tabid and fieldname='buttonname');

INSERT INTO `ld_tranlabel`( `languagetype`, `trantable`, `tabid`, `Relateid`, `fieldlabel`) select  'zh', 'ld_field', @tabid, @fieldid, '按钮名称' from dual where not exists ( select 1 from ld_tranlabel where tabid =@tabid and fieldlabel ='按钮名称');
INSERT INTO `ld_tranlabel`( `languagetype`, `trantable`, `tabid`, `Relateid`, `fieldlabel`) select 'en', 'ld_field', @tabid, @fieldid, 'Button Name' from dual where not exists ( select 1 from ld_tranlabel where tabid =@tabid and fieldlabel ='Button Name');

set @fieldid = (select max(fieldid) from ld_field) +1;
INSERT INTO `ld_field` (`tabid`, `fieldid`, `columnname`, `allowhide`, `tablename`, `generatedtype`, `uitype`, `fieldname`, `fieldlabel`, `readonly`, `presence`, `defaultvalue`, `maximumlength`, `sequence`, `block`, `displaytype`, `typeofdata`, `quickcreate`, `quickcreatesequence`, `info_type`, `masseditable`, `helpinfo`, `fieldonly`, `issmownerid`, `searchfieldtype`, `associatedfields`, `associatedsequence`, `callchecked`, `duplicatefield`, `relate_search_parent_columnname`, `approve_demand`, `is_checkimportfield`, `allowedit`, `allowedit_presence`, `allowcreate`, `allowcreate_presence`, `allowdetail_presence`, `fldallow_rewriting`, `take_photo_only`, `savedatabase`, `bigtype`, `datarang`, `maxrowsshow`, `parentbigtype`, `profileeditfield`, `keywords`) select @tabid, @fieldid, 'buttoncolor', 'yes', 'ld_socialpromotionscf', 2, '1', 'buttoncolor', '按钮颜色', 0, 2, '#00aaef', 100, 5, @blockid, 1, 'V~O', 0, 0, 'BAS', 1, NULL, 0, 0, NULL, NULL, 0, 0, NULL, NULL, 0, 0, 'yes', NULL, NULL, NULL, NULL, 0, 0, 'yes', 'text', 'all', 5, NULL, 'yes', NULL from dual where not exists( select 1 from ld_field where tabid= @tabid and fieldname='buttoncolor');

INSERT INTO `ld_tranlabel`( `languagetype`, `trantable`, `tabid`, `Relateid`, `fieldlabel`) select  'zh', 'ld_field', @tabid, @fieldid, '按钮颜色' from dual where not exists ( select 1 from ld_tranlabel where tabid =@tabid and fieldlabel ='按钮颜色');
INSERT INTO `ld_tranlabel`( `languagetype`, `trantable`, `tabid`, `Relateid`, `fieldlabel`) select 'en', 'ld_field', @tabid, @fieldid, 'Button Color' from dual where not exists ( select 1 from ld_tranlabel where tabid =@tabid and fieldlabel ='Button Color');

set @fieldid = (select max(fieldid) from ld_field) +1;
INSERT INTO `ld_field` (`tabid`, `fieldid`, `columnname`, `allowhide`, `tablename`, `generatedtype`, `uitype`, `fieldname`, `fieldlabel`, `readonly`, `presence`, `defaultvalue`, `maximumlength`, `sequence`, `block`, `displaytype`, `typeofdata`, `quickcreate`, `quickcreatesequence`, `info_type`, `masseditable`, `helpinfo`, `fieldonly`, `issmownerid`, `searchfieldtype`, `associatedfields`, `associatedsequence`, `callchecked`, `duplicatefield`, `relate_search_parent_columnname`, `approve_demand`, `is_checkimportfield`, `allowedit`, `allowedit_presence`, `allowcreate`, `allowcreate_presence`, `allowdetail_presence`, `fldallow_rewriting`, `take_photo_only`, `savedatabase`, `bigtype`, `datarang`, `maxrowsshow`, `parentbigtype`, `profileeditfield`, `keywords`) select @tabid, @fieldid, 'customfieldsorder', 'yes', 'ld_socialpromotion', 2, '21', 'customfieldsorder', '自定义字段', 0, 2, '', 100, 3, @blockid, 1, 'V~O', 0, 0, 'BAS', 1, NULL, 0, 0, NULL, NULL, 0, 0, NULL, NULL, 0, 0, 'yes', NULL, NULL, NULL, NULL, 0, 0, 'yes', 'textarea', 'all', 5, NULL, 'yes', NULL from dual where not exists( select 1 from ld_field where tabid= @tabid and fieldname='customfieldsorder');

INSERT INTO `ld_tranlabel`( `languagetype`, `trantable`, `tabid`, `Relateid`, `fieldlabel`) select  'zh', 'ld_field', @tabid, @fieldid, '自定义字段' from dual where not exists ( select 1 from ld_tranlabel where tabid =@tabid and fieldlabel ='自定义字段');
INSERT INTO `ld_tranlabel`( `languagetype`, `trantable`, `tabid`, `Relateid`, `fieldlabel`) select 'en', 'ld_field', @tabid, @fieldid, 'Custom Fields' from dual where not exists ( select 1 from ld_tranlabel where tabid =@tabid and fieldlabel ='Custom Fields');

set @blockid = (SELECT MAX(blockid) FROM ld_blocks)+1;
INSERT INTO `ld_blocks` (`blockid`, `tabid`, `blocklabel`, `sequence`, `show_title`, `visible`, `create_view`, `edit_view`, `detail_view`, `display_status`, `iscustom`, `linkid`) select @blockid, @tabid, '第三步', 4, NULL, 0, 0, 0, 0, 1, 1, NULL from dual where not exists (select 1 from ld_blocks where tabid =@tabid and blocklabel ='第三步');

INSERT INTO `ld_tranlabel`(`languagetype`, `trantable`, `tabid`, `Relateid`, `fieldlabel`) select 'zh', 'ld_blocks', @tabid, @blockid, '第三步' from dual where not exists (select 1 from ld_tranlabel where  tabid =@tabid and languagetype ='zh' and fieldlabel ='第三步');
INSERT INTO `ld_tranlabel`( `languagetype`, `trantable`, `tabid`, `Relateid`, `fieldlabel`) select  'en', 'ld_blocks', @tabid, @blockid, 'Step 3' from dual where not exists (select 1 from ld_tranlabel where  tabid =@tabid and languagetype ='en' and fieldlabel ='Step 3');

set @fieldid = (select max(fieldid) from ld_field) +1;
INSERT INTO `ld_field` (`tabid`, `fieldid`, `columnname`, `allowhide`, `tablename`, `generatedtype`, `uitype`, `fieldname`, `fieldlabel`, `readonly`, `presence`, `defaultvalue`, `maximumlength`, `sequence`, `block`, `displaytype`, `typeofdata`, `quickcreate`, `quickcreatesequence`, `info_type`, `masseditable`, `helpinfo`, `fieldonly`, `issmownerid`, `searchfieldtype`, `associatedfields`, `associatedsequence`, `callchecked`, `duplicatefield`, `relate_search_parent_columnname`, `approve_demand`, `is_checkimportfield`, `allowedit`, `allowedit_presence`, `allowcreate`, `allowcreate_presence`, `allowdetail_presence`, `fldallow_rewriting`, `take_photo_only`, `savedatabase`, `bigtype`, `datarang`, `maxrowsshow`, `parentbigtype`, `profileeditfield`, `keywords`) select @tabid, @fieldid, 'sharetitle', 'yes', 'ld_socialpromotionscf', 2, '1', 'sharetitle', '分享主题', 0, 2, '', 100, 1, @blockid, 1, 'V~O', 0, 0, 'BAS', 1, NULL, 0, 0, NULL, NULL, 0, 0, NULL, NULL, 0, 0, 'yes', NULL, NULL, NULL, NULL, 0, 0, 'yes', 'text', 'all', 5, NULL, 'yes', NULL from dual where not exists( select 1 from ld_field where tabid= @tabid and fieldname='sharetitle');

INSERT INTO `ld_tranlabel`( `languagetype`, `trantable`, `tabid`, `Relateid`, `fieldlabel`) select  'zh', 'ld_field', @tabid, @fieldid, '分享主题' from dual where not exists ( select 1 from ld_tranlabel where tabid =@tabid and fieldlabel ='分享主题');
INSERT INTO `ld_tranlabel`( `languagetype`, `trantable`, `tabid`, `Relateid`, `fieldlabel`) select 'en', 'ld_field', @tabid, @fieldid, 'Share Title' from dual where not exists ( select 1 from ld_tranlabel where tabid =@tabid and fieldlabel ='Share Title');

set @fieldid = (select max(fieldid) from ld_field) +1;
INSERT INTO `ld_field` (`tabid`, `fieldid`, `columnname`, `allowhide`, `tablename`, `generatedtype`, `uitype`, `fieldname`, `fieldlabel`, `readonly`, `presence`, `defaultvalue`, `maximumlength`, `sequence`, `block`, `displaytype`, `typeofdata`, `quickcreate`, `quickcreatesequence`, `info_type`, `masseditable`, `helpinfo`, `fieldonly`, `issmownerid`, `searchfieldtype`, `associatedfields`, `associatedsequence`, `callchecked`, `duplicatefield`, `relate_search_parent_columnname`, `approve_demand`, `is_checkimportfield`, `allowedit`, `allowedit_presence`, `allowcreate`, `allowcreate_presence`, `allowdetail_presence`, `fldallow_rewriting`, `take_photo_only`, `savedatabase`, `bigtype`, `datarang`, `maxrowsshow`, `parentbigtype`, `profileeditfield`, `keywords`) select @tabid, @fieldid, 'shareintroduction', 'yes', 'ld_socialpromotionscf', 2, '1', 'shareintroduction', '分享说明', 0, 2, '', 100, 2, @blockid, 1, 'V~O~LE~255', 0, 0, 'BAS', 1, NULL, 0, 0, NULL, NULL, 0, 0, NULL, NULL, 0, 0, 'yes', NULL, NULL, NULL, NULL, 0, 0, 'yes', 'text', 'all', 5, NULL, 'yes', NULL from dual where not exists( select 1 from ld_field where tabid= @tabid and fieldname='shareintroduction');

INSERT INTO `ld_tranlabel`( `languagetype`, `trantable`, `tabid`, `Relateid`, `fieldlabel`) select  'zh', 'ld_field', @tabid, @fieldid, '分享说明' from dual where not exists ( select 1 from ld_tranlabel where tabid =@tabid and fieldlabel ='分享说明');
INSERT INTO `ld_tranlabel`( `languagetype`, `trantable`, `tabid`, `Relateid`, `fieldlabel`) select 'en', 'ld_field', @tabid, @fieldid, 'Share Introduction' from dual where not exists ( select 1 from ld_tranlabel where tabid =@tabid and fieldlabel ='Share Introduction');

set @fieldid = (select max(fieldid) from ld_field) +1;
INSERT INTO `ld_field` (`tabid`, `fieldid`, `columnname`, `allowhide`, `tablename`, `generatedtype`, `uitype`, `fieldname`, `fieldlabel`, `readonly`, `presence`, `defaultvalue`, `maximumlength`, `sequence`, `block`, `displaytype`, `typeofdata`, `quickcreate`, `quickcreatesequence`, `info_type`, `masseditable`, `helpinfo`, `fieldonly`, `issmownerid`, `searchfieldtype`, `associatedfields`, `associatedsequence`, `callchecked`, `duplicatefield`, `relate_search_parent_columnname`, `approve_demand`, `is_checkimportfield`, `allowedit`, `allowedit_presence`, `allowcreate`, `allowcreate_presence`, `allowdetail_presence`, `fldallow_rewriting`, `take_photo_only`, `savedatabase`, `bigtype`, `datarang`, `maxrowsshow`, `parentbigtype`, `profileeditfield`, `keywords`) select @tabid, @fieldid, 'sharepicture', 'yes', 'ld_attachments', 2, '69', 'sharepicture', '分享图片', 0, 2, '', 100, 3, 361, 1, 'V~O', 1, 0, 'BAS', 1, NULL, 0, 0, NULL, NULL, 0, 0, NULL, NULL, 0, 0, 'yes', NULL, NULL, NULL, NULL, 0, 0, 'yes', 'fileattachment', 'all', 5, NULL, 'yes', NULL from dual where not exists( select 1 from ld_field where tabid= @tabid and fieldname='sharepicture');

INSERT INTO `ld_tranlabel`( `languagetype`, `trantable`, `tabid`, `Relateid`, `fieldlabel`) select  'zh', 'ld_field', @tabid, @fieldid, '分享图片' from dual where not exists ( select 1 from ld_tranlabel where tabid =@tabid and fieldlabel ='分享图片');
INSERT INTO `ld_tranlabel`( `languagetype`, `trantable`, `tabid`, `Relateid`, `fieldlabel`) select 'en', 'ld_field', @tabid, @fieldid, 'Share Picture' from dual where not exists ( select 1 from ld_tranlabel where tabid =@tabid and fieldlabel ='Share Picture');

update ld_field_seq set id = (select max(fieldid) from ld_field );

set @cvid = (select max(cvid) from ld_customview)+1;
INSERT INTO `ld_customview` (`cvid`, `viewname`, `setdefault`, `setmetrics`, `entitytype`, `status`, `userid`, `sequence`, `pagewidthpercent`, `customcategory`, `description`) select @cvid, 'All', 0, 0, 'SocialPromotion', 3, 1, 1, NULL, NULL, NULL from dual where not exists (select 1 from ld_customview where viewname ='All' and entitytype ='SocialPromotion');
SET @tempCvid = (select cvid from ld_customview where viewname ='All' and entitytype ='SocialPromotion');
INSERT INTO `ld_cvcolumnlist`(`cvid`, `columnindex`, `columnname`) select  @tempCvid, 0, 'ld_socialpromotion:activityname:activityname:SocialPromotion_fieldlabel:V' from dual where not exists( select 1 from ld_cvcolumnlist where cvid =@tempCvid and columnname ='ld_socialpromotion:activityname:activityname:SocialPromotion_fieldlabel:V');
INSERT INTO `ld_cvcolumnlist`(`cvid`, `columnindex`, `columnname`) select  @tempCvid, 1, 'ld_socialpromotion:mappingmodule:mappingmodule:SocialPromotion_fieldlabel:V' from dual where not exists( select 1 from ld_cvcolumnlist where cvid =@tempCvid and columnname ='ld_socialpromotion:mappingmodule:mappingmodule:SocialPromotion_fieldlabel:V');
INSERT INTO `ld_cvcolumnlist`(`cvid`, `columnindex`, `columnname`) select  @tempCvid, 2, 'ld_socialpromotion:activityviews:activityviews:SocialPromotion_fieldlabel:V' from dual where not exists( select 1 from ld_cvcolumnlist where cvid =@tempCvid and columnname ='ld_socialpromotion:activityviews:activityviews:SocialPromotion_fieldlabel:V');
INSERT INTO `ld_cvcolumnlist`(`cvid`, `columnindex`, `columnname`) select  @tempCvid, 3, 'ld_socialpromotion:documentquantity:documentquantity:SocialPromotion_fieldlabel:V' from dual where not exists( select 1 from ld_cvcolumnlist where cvid =@tempCvid and columnname ='ld_socialpromotion:documentquantity:documentquantity:SocialPromotion_fieldlabel:V');
INSERT INTO `ld_cvcolumnlist`(`cvid`, `columnindex`, `columnname`) select  @tempCvid, 4, 'ld_socialpromotion:activitystate:activitystate:SocialPromotion_fieldlabel:V' from dual where not exists( select 1 from ld_cvcolumnlist where cvid =@tempCvid and columnname ='ld_socialpromotion:activitystate:activitystate:SocialPromotion_fieldlabel:V');
INSERT INTO `ld_cvcolumnlist`(`cvid`, `columnindex`, `columnname`) select  @tempCvid, 5, 'ld_socialpromotion:smownerid:assigned_user_id:SocialPromotion_fieldlabel:V' from dual where not exists( select 1 from ld_cvcolumnlist where cvid =@tempCvid and columnname ='ld_socialpromotion:smownerid:assigned_user_id:SocialPromotion_fieldlabel:V');
INSERT INTO `ld_cvcolumnlist`(`cvid`, `columnindex`, `columnname`) select  @tempCvid, 6, 'ld_socialpromotion:smcreatorid:smcreatorid:SocialPromotion_fieldlabel:V' from dual where not exists( select 1 from ld_cvcolumnlist where cvid =@tempCvid and columnname ='ld_socialpromotion:smcreatorid:smcreatorid:SocialPromotion_fieldlabel:V');
INSERT INTO `ld_cvcolumnlist`(`cvid`, `columnindex`, `columnname`) select  @tempCvid, 7, 'ld_socialpromotion:createdtime:createdtime:SocialPromotion_fieldlabel:DT' from dual where not exists( select 1 from ld_cvcolumnlist where cvid =@tempCvid and columnname ='ld_socialpromotion:createdtime:createdtime:SocialPromotion_fieldlabel:DT');
INSERT INTO `ld_cvcolumnlist`(`cvid`, `columnindex`, `columnname`) select  @tempCvid, 8, 'ld_socialpromotion:modifiedtime:modifiedtime:SocialPromotion_fieldlabel:DT' from dual where not exists( select 1 from ld_cvcolumnlist where cvid =@tempCvid and columnname ='ld_socialpromotion:modifiedtime:modifiedtime:SocialPromotion_fieldlabel:DT');
delimiter;

set @cvid = (select max(cvid) from ld_customview)+1;
INSERT INTO `ld_customview` (`cvid`, `viewname`, `setdefault`, `setmetrics`, `entitytype`, `status`, `userid`, `sequence`, `pagewidthpercent`, `customcategory`, `description`) select @cvid, '已批准', 0, 0, 'SocialPromotion', 3, 1, 2, NULL, NULL, NULL from dual where not exists (select 1 from ld_customview where  viewname ='已批准' and entitytype ='SocialPromotion');
set @tempCvid = (select cvid from ld_customview where viewname ='已批准' and entitytype ='SocialPromotion');

INSERT INTO `ld_cvcolumnlist`(`cvid`, `columnindex`, `columnname`) select  @tempCvid, 0, 'ld_socialpromotion:activityname:activityname:SocialPromotion_fieldlabel:V' from dual where not exists( select 1 from ld_cvcolumnlist where cvid =@tempCvid and columnname ='ld_socialpromotion:activityname:activityname:SocialPromotion_fieldlabel:V');
INSERT INTO `ld_cvcolumnlist`(`cvid`, `columnindex`, `columnname`) select  @tempCvid, 1, 'ld_socialpromotion:mappingmodule:mappingmodule:SocialPromotion_fieldlabel:V' from dual where not exists( select 1 from ld_cvcolumnlist where cvid =@tempCvid and columnname ='ld_socialpromotion:mappingmodule:mappingmodule:SocialPromotion_fieldlabel:V');
INSERT INTO `ld_cvcolumnlist`(`cvid`, `columnindex`, `columnname`) select  @tempCvid, 2, 'ld_socialpromotion:activityviews:activityviews:SocialPromotion_fieldlabel:V' from dual where not exists( select 1 from ld_cvcolumnlist where cvid =@tempCvid and columnname ='ld_socialpromotion:activityviews:activityviews:SocialPromotion_fieldlabel:V');
INSERT INTO `ld_cvcolumnlist`(`cvid`, `columnindex`, `columnname`) select  @tempCvid, 3, 'ld_socialpromotion:documentquantity:documentquantity:SocialPromotion_fieldlabel:V' from dual where not exists( select 1 from ld_cvcolumnlist where cvid =@tempCvid and columnname ='ld_socialpromotion:documentquantity:documentquantity:SocialPromotion_fieldlabel:V');
INSERT INTO `ld_cvcolumnlist`(`cvid`, `columnindex`, `columnname`) select  @tempCvid, 4, 'ld_socialpromotion:activitystate:activitystate:SocialPromotion_fieldlabel:V' from dual where not exists( select 1 from ld_cvcolumnlist where cvid =@tempCvid and columnname ='ld_socialpromotion:activitystate:activitystate:SocialPromotion_fieldlabel:V');
INSERT INTO `ld_cvcolumnlist`(`cvid`, `columnindex`, `columnname`) select  @tempCvid, 5, 'ld_socialpromotion:smownerid:assigned_user_id:SocialPromotion_fieldlabel:V' from dual where not exists( select 1 from ld_cvcolumnlist where cvid =@tempCvid and columnname ='ld_socialpromotion:smownerid:assigned_user_id:SocialPromotion_fieldlabel:V');
INSERT INTO `ld_cvcolumnlist`(`cvid`, `columnindex`, `columnname`) select  @tempCvid, 6, 'ld_socialpromotion:smcreatorid:smcreatorid:SocialPromotion_fieldlabel:V' from dual where not exists( select 1 from ld_cvcolumnlist where cvid =@tempCvid and columnname ='ld_socialpromotion:smcreatorid:smcreatorid:SocialPromotion_fieldlabel:V');
INSERT INTO `ld_cvcolumnlist`(`cvid`, `columnindex`, `columnname`) select  @tempCvid, 7, 'ld_socialpromotion:createdtime:createdtime:SocialPromotion_fieldlabel:DT' from dual where not exists( select 1 from ld_cvcolumnlist where cvid =@tempCvid and columnname ='ld_socialpromotion:createdtime:createdtime:SocialPromotion_fieldlabel:DT');
INSERT INTO `ld_cvcolumnlist`(`cvid`, `columnindex`, `columnname`) select  @tempCvid, 8, 'ld_socialpromotion:modifiedtime:modifiedtime:SocialPromotion_fieldlabel:DT' from dual where not exists( select 1 from ld_cvcolumnlist where cvid =@tempCvid and columnname ='ld_socialpromotion:modifiedtime:modifiedtime:SocialPromotion_fieldlabel:DT');


set @cvid = (select max(cvid) from ld_customview)+1;
INSERT INTO `ld_customview` (`cvid`, `viewname`, `setdefault`, `setmetrics`, `entitytype`, `status`, `userid`, `sequence`, `pagewidthpercent`, `customcategory`, `description`) select @cvid, '审批中', 0, 0, 'SocialPromotion', 3, 1, 3, NULL, NULL, NULL from dual where not exists (select 1 from ld_customview where  viewname ='审批中' and entitytype ='SocialPromotion');
set @tempCvid = (select cvid from ld_customview where viewname ='审批中' and entitytype ='SocialPromotion');

INSERT INTO `ld_cvcolumnlist`(`cvid`, `columnindex`, `columnname`) select  @tempCvid, 0, 'ld_socialpromotion:activityname:activityname:SocialPromotion_fieldlabel:V' from dual where not exists( select 1 from ld_cvcolumnlist where cvid =@tempCvid and columnname ='ld_socialpromotion:activityname:activityname:SocialPromotion_fieldlabel:V');
INSERT INTO `ld_cvcolumnlist`(`cvid`, `columnindex`, `columnname`) select  @tempCvid, 1, 'ld_socialpromotion:mappingmodule:mappingmodule:SocialPromotion_fieldlabel:V' from dual where not exists( select 1 from ld_cvcolumnlist where cvid =@tempCvid and columnname ='ld_socialpromotion:mappingmodule:mappingmodule:SocialPromotion_fieldlabel:V');
INSERT INTO `ld_cvcolumnlist`(`cvid`, `columnindex`, `columnname`) select  @tempCvid, 2, 'ld_socialpromotion:activityviews:activityviews:SocialPromotion_fieldlabel:V' from dual where not exists( select 1 from ld_cvcolumnlist where cvid =@tempCvid and columnname ='ld_socialpromotion:activityviews:activityviews:SocialPromotion_fieldlabel:V');
INSERT INTO `ld_cvcolumnlist`(`cvid`, `columnindex`, `columnname`) select  @tempCvid, 3, 'ld_socialpromotion:documentquantity:documentquantity:SocialPromotion_fieldlabel:V' from dual where not exists( select 1 from ld_cvcolumnlist where cvid =@tempCvid and columnname ='ld_socialpromotion:documentquantity:documentquantity:SocialPromotion_fieldlabel:V');
INSERT INTO `ld_cvcolumnlist`(`cvid`, `columnindex`, `columnname`) select  @tempCvid, 4, 'ld_socialpromotion:activitystate:activitystate:SocialPromotion_fieldlabel:V' from dual where not exists( select 1 from ld_cvcolumnlist where cvid =@tempCvid and columnname ='ld_socialpromotion:activitystate:activitystate:SocialPromotion_fieldlabel:V');
INSERT INTO `ld_cvcolumnlist`(`cvid`, `columnindex`, `columnname`) select  @tempCvid, 5, 'ld_socialpromotion:smownerid:assigned_user_id:SocialPromotion_fieldlabel:V' from dual where not exists( select 1 from ld_cvcolumnlist where cvid =@tempCvid and columnname ='ld_socialpromotion:smownerid:assigned_user_id:SocialPromotion_fieldlabel:V');
INSERT INTO `ld_cvcolumnlist`(`cvid`, `columnindex`, `columnname`) select  @tempCvid, 6, 'ld_socialpromotion:smcreatorid:smcreatorid:SocialPromotion_fieldlabel:V' from dual where not exists( select 1 from ld_cvcolumnlist where cvid =@tempCvid and columnname ='ld_socialpromotion:smcreatorid:smcreatorid:SocialPromotion_fieldlabel:V');
INSERT INTO `ld_cvcolumnlist`(`cvid`, `columnindex`, `columnname`) select  @tempCvid, 7, 'ld_socialpromotion:createdtime:createdtime:SocialPromotion_fieldlabel:DT' from dual where not exists( select 1 from ld_cvcolumnlist where cvid =@tempCvid and columnname ='ld_socialpromotion:createdtime:createdtime:SocialPromotion_fieldlabel:DT');
INSERT INTO `ld_cvcolumnlist`(`cvid`, `columnindex`, `columnname`) select  @tempCvid, 8, 'ld_socialpromotion:modifiedtime:modifiedtime:SocialPromotion_fieldlabel:DT' from dual where not exists( select 1 from ld_cvcolumnlist where cvid =@tempCvid and columnname ='ld_socialpromotion:modifiedtime:modifiedtime:SocialPromotion_fieldlabel:DT');
delimiter;

set @cvid = (select max(cvid) from ld_customview)+1;
INSERT INTO `ld_customview` (`cvid`, `viewname`, `setdefault`, `setmetrics`, `entitytype`, `status`, `userid`, `sequence`, `pagewidthpercent`, `customcategory`, `description`) select @cvid, '未提交', 0, 0, 'SocialPromotion', 3, 1, 4, NULL, NULL, NULL from dual where not exists (select 1 from ld_customview where  viewname ='未提交' and entitytype ='SocialPromotion');
set @tempCvid = (select cvid from ld_customview where viewname ='未提交' and entitytype ='SocialPromotion');
INSERT INTO `ld_cvcolumnlist`(`cvid`, `columnindex`, `columnname`) select  @tempCvid, 0, 'ld_socialpromotion:activityname:activityname:SocialPromotion_fieldlabel:V' from dual where not exists( select 1 from ld_cvcolumnlist where cvid =@tempCvid and columnname ='ld_socialpromotion:activityname:activityname:SocialPromotion_fieldlabel:V');
INSERT INTO `ld_cvcolumnlist`(`cvid`, `columnindex`, `columnname`) select  @tempCvid, 1, 'ld_socialpromotion:mappingmodule:mappingmodule:SocialPromotion_fieldlabel:V' from dual where not exists( select 1 from ld_cvcolumnlist where cvid =@tempCvid and columnname ='ld_socialpromotion:mappingmodule:mappingmodule:SocialPromotion_fieldlabel:V');
INSERT INTO `ld_cvcolumnlist`(`cvid`, `columnindex`, `columnname`) select  @tempCvid, 2, 'ld_socialpromotion:activityviews:activityviews:SocialPromotion_fieldlabel:V' from dual where not exists( select 1 from ld_cvcolumnlist where cvid =@tempCvid and columnname ='ld_socialpromotion:activityviews:activityviews:SocialPromotion_fieldlabel:V');
INSERT INTO `ld_cvcolumnlist`(`cvid`, `columnindex`, `columnname`) select  @tempCvid, 3, 'ld_socialpromotion:documentquantity:documentquantity:SocialPromotion_fieldlabel:V' from dual where not exists( select 1 from ld_cvcolumnlist where cvid =@tempCvid and columnname ='ld_socialpromotion:documentquantity:documentquantity:SocialPromotion_fieldlabel:V');
INSERT INTO `ld_cvcolumnlist`(`cvid`, `columnindex`, `columnname`) select  @tempCvid, 4, 'ld_socialpromotion:activitystate:activitystate:SocialPromotion_fieldlabel:V' from dual where not exists( select 1 from ld_cvcolumnlist where cvid =@tempCvid and columnname ='ld_socialpromotion:activitystate:activitystate:SocialPromotion_fieldlabel:V');
INSERT INTO `ld_cvcolumnlist`(`cvid`, `columnindex`, `columnname`) select  @tempCvid, 5, 'ld_socialpromotion:smownerid:assigned_user_id:SocialPromotion_fieldlabel:V' from dual where not exists( select 1 from ld_cvcolumnlist where cvid =@tempCvid and columnname ='ld_socialpromotion:smownerid:assigned_user_id:SocialPromotion_fieldlabel:V');
INSERT INTO `ld_cvcolumnlist`(`cvid`, `columnindex`, `columnname`) select  @tempCvid, 6, 'ld_socialpromotion:smcreatorid:smcreatorid:SocialPromotion_fieldlabel:V' from dual where not exists( select 1 from ld_cvcolumnlist where cvid =@tempCvid and columnname ='ld_socialpromotion:smcreatorid:smcreatorid:SocialPromotion_fieldlabel:V');
INSERT INTO `ld_cvcolumnlist`(`cvid`, `columnindex`, `columnname`) select  @tempCvid, 7, 'ld_socialpromotion:createdtime:createdtime:SocialPromotion_fieldlabel:DT' from dual where not exists( select 1 from ld_cvcolumnlist where cvid =@tempCvid and columnname ='ld_socialpromotion:createdtime:createdtime:SocialPromotion_fieldlabel:DT');
INSERT INTO `ld_cvcolumnlist`(`cvid`, `columnindex`, `columnname`) select  @tempCvid, 8, 'ld_socialpromotion:modifiedtime:modifiedtime:SocialPromotion_fieldlabel:DT' from dual where not exists( select 1 from ld_cvcolumnlist where cvid =@tempCvid and columnname ='ld_socialpromotion:modifiedtime:modifiedtime:SocialPromotion_fieldlabel:DT');
delimiter;

set @cvid = (select max(cvid) from ld_customview)+1;
INSERT INTO `ld_customview` (`cvid`, `viewname`, `setdefault`, `setmetrics`, `entitytype`, `status`, `userid`, `sequence`, `pagewidthpercent`, `customcategory`, `description`) select @cvid, '已驳回', 0, 0, 'SocialPromotion', 3, 1, 5, NULL, NULL, NULL from dual where not exists (select 1 from ld_customview where  viewname ='已驳回' and entitytype ='SocialPromotion');
set @tempCvid = (select cvid from ld_customview where viewname ='已驳回' and entitytype ='SocialPromotion');

INSERT INTO `ld_cvcolumnlist`(`cvid`, `columnindex`, `columnname`) select  @tempCvid, 0, 'ld_socialpromotion:activityname:activityname:SocialPromotion_fieldlabel:V' from dual where not exists( select 1 from ld_cvcolumnlist where cvid =@tempCvid and columnname ='ld_socialpromotion:activityname:activityname:SocialPromotion_fieldlabel:V');
INSERT INTO `ld_cvcolumnlist`(`cvid`, `columnindex`, `columnname`) select  @tempCvid, 1, 'ld_socialpromotion:mappingmodule:mappingmodule:SocialPromotion_fieldlabel:V' from dual where not exists( select 1 from ld_cvcolumnlist where cvid =@tempCvid and columnname ='ld_socialpromotion:mappingmodule:mappingmodule:SocialPromotion_fieldlabel:V');
INSERT INTO `ld_cvcolumnlist`(`cvid`, `columnindex`, `columnname`) select  @tempCvid, 2, 'ld_socialpromotion:activityviews:activityviews:SocialPromotion_fieldlabel:V' from dual where not exists( select 1 from ld_cvcolumnlist where cvid =@tempCvid and columnname ='ld_socialpromotion:activityviews:activityviews:SocialPromotion_fieldlabel:V');
INSERT INTO `ld_cvcolumnlist`(`cvid`, `columnindex`, `columnname`) select  @tempCvid, 3, 'ld_socialpromotion:documentquantity:documentquantity:SocialPromotion_fieldlabel:V' from dual where not exists( select 1 from ld_cvcolumnlist where cvid =@tempCvid and columnname ='ld_socialpromotion:documentquantity:documentquantity:SocialPromotion_fieldlabel:V');
INSERT INTO `ld_cvcolumnlist`(`cvid`, `columnindex`, `columnname`) select  @tempCvid, 4, 'ld_socialpromotion:activitystate:activitystate:SocialPromotion_fieldlabel:V' from dual where not exists( select 1 from ld_cvcolumnlist where cvid =@tempCvid and columnname ='ld_socialpromotion:activitystate:activitystate:SocialPromotion_fieldlabel:V');
INSERT INTO `ld_cvcolumnlist`(`cvid`, `columnindex`, `columnname`) select  @tempCvid, 5, 'ld_socialpromotion:smownerid:assigned_user_id:SocialPromotion_fieldlabel:V' from dual where not exists( select 1 from ld_cvcolumnlist where cvid =@tempCvid and columnname ='ld_socialpromotion:smownerid:assigned_user_id:SocialPromotion_fieldlabel:V');
INSERT INTO `ld_cvcolumnlist`(`cvid`, `columnindex`, `columnname`) select  @tempCvid, 6, 'ld_socialpromotion:smcreatorid:smcreatorid:SocialPromotion_fieldlabel:V' from dual where not exists( select 1 from ld_cvcolumnlist where cvid =@tempCvid and columnname ='ld_socialpromotion:smcreatorid:smcreatorid:SocialPromotion_fieldlabel:V');
INSERT INTO `ld_cvcolumnlist`(`cvid`, `columnindex`, `columnname`) select  @tempCvid, 7, 'ld_socialpromotion:createdtime:createdtime:SocialPromotion_fieldlabel:DT' from dual where not exists( select 1 from ld_cvcolumnlist where cvid =@tempCvid and columnname ='ld_socialpromotion:createdtime:createdtime:SocialPromotion_fieldlabel:DT');
INSERT INTO `ld_cvcolumnlist`(`cvid`, `columnindex`, `columnname`) select  @tempCvid, 8, 'ld_socialpromotion:modifiedtime:modifiedtime:SocialPromotion_fieldlabel:DT' from dual where not exists( select 1 from ld_cvcolumnlist where cvid =@tempCvid and columnname ='ld_socialpromotion:modifiedtime:modifiedtime:SocialPromotion_fieldlabel:DT');
delimiter;

set @cvid = (select max(cvid) from ld_customview)+1;
INSERT INTO `ld_customview` (`cvid`, `viewname`, `setdefault`, `setmetrics`, `entitytype`, `status`, `userid`, `sequence`, `pagewidthpercent`, `customcategory`, `description`) select @cvid, '已拒绝', 0, 0, 'SocialPromotion', 3, 1, 6, NULL, NULL, NULL from dual where not exists (select 1 from ld_customview where viewname ='已拒绝' and entitytype ='SocialPromotion');
set @tempCvid = (select cvid from ld_customview where viewname ='已拒绝' and entitytype ='SocialPromotion');

INSERT INTO `ld_cvcolumnlist`(`cvid`, `columnindex`, `columnname`) select  @tempCvid, 0, 'ld_socialpromotion:activityname:activityname:SocialPromotion_fieldlabel:V' from dual where not exists( select 1 from ld_cvcolumnlist where cvid =@tempCvid and columnname ='ld_socialpromotion:activityname:activityname:SocialPromotion_fieldlabel:V');
INSERT INTO `ld_cvcolumnlist`(`cvid`, `columnindex`, `columnname`) select  @tempCvid, 1, 'ld_socialpromotion:mappingmodule:mappingmodule:SocialPromotion_fieldlabel:V' from dual where not exists( select 1 from ld_cvcolumnlist where cvid =@tempCvid and columnname ='ld_socialpromotion:mappingmodule:mappingmodule:SocialPromotion_fieldlabel:V');
INSERT INTO `ld_cvcolumnlist`(`cvid`, `columnindex`, `columnname`) select  @tempCvid, 2, 'ld_socialpromotion:activityviews:activityviews:SocialPromotion_fieldlabel:V' from dual where not exists( select 1 from ld_cvcolumnlist where cvid =@tempCvid and columnname ='ld_socialpromotion:activityviews:activityviews:SocialPromotion_fieldlabel:V');
INSERT INTO `ld_cvcolumnlist`(`cvid`, `columnindex`, `columnname`) select  @tempCvid, 3, 'ld_socialpromotion:documentquantity:documentquantity:SocialPromotion_fieldlabel:V' from dual where not exists( select 1 from ld_cvcolumnlist where cvid =@tempCvid and columnname ='ld_socialpromotion:documentquantity:documentquantity:SocialPromotion_fieldlabel:V');
INSERT INTO `ld_cvcolumnlist`(`cvid`, `columnindex`, `columnname`) select  @tempCvid, 4, 'ld_socialpromotion:activitystate:activitystate:SocialPromotion_fieldlabel:V' from dual where not exists( select 1 from ld_cvcolumnlist where cvid =@tempCvid and columnname ='ld_socialpromotion:activitystate:activitystate:SocialPromotion_fieldlabel:V');
INSERT INTO `ld_cvcolumnlist`(`cvid`, `columnindex`, `columnname`) select  @tempCvid, 5, 'ld_socialpromotion:smownerid:assigned_user_id:SocialPromotion_fieldlabel:V' from dual where not exists( select 1 from ld_cvcolumnlist where cvid =@tempCvid and columnname ='ld_socialpromotion:smownerid:assigned_user_id:SocialPromotion_fieldlabel:V');
INSERT INTO `ld_cvcolumnlist`(`cvid`, `columnindex`, `columnname`) select  @tempCvid, 6, 'ld_socialpromotion:smcreatorid:smcreatorid:SocialPromotion_fieldlabel:V' from dual where not exists( select 1 from ld_cvcolumnlist where cvid =@tempCvid and columnname ='ld_socialpromotion:smcreatorid:smcreatorid:SocialPromotion_fieldlabel:V');
INSERT INTO `ld_cvcolumnlist`(`cvid`, `columnindex`, `columnname`) select  @tempCvid, 7, 'ld_socialpromotion:createdtime:createdtime:SocialPromotion_fieldlabel:DT' from dual where not exists( select 1 from ld_cvcolumnlist where cvid =@tempCvid and columnname ='ld_socialpromotion:createdtime:createdtime:SocialPromotion_fieldlabel:DT');
INSERT INTO `ld_cvcolumnlist`(`cvid`, `columnindex`, `columnname`) select  @tempCvid, 8, 'ld_socialpromotion:modifiedtime:modifiedtime:SocialPromotion_fieldlabel:DT' from dual where not exists( select 1 from ld_cvcolumnlist where cvid =@tempCvid and columnname ='ld_socialpromotion:modifiedtime:modifiedtime:SocialPromotion_fieldlabel:DT');
delimiter;

update ld_customview_seq set id = (select max(cvid) from ld_customview);
delimiter;


INSERT INTO ld_desk(languagetype, labelbol, fieldlabel, labeltype)
select 'zh', 'SOCIALPROMOTIONTIP', '社交推广使用说明', 'fixedstr'
from dual
where not exists(select 1 from ld_desk where languagetype = 'zh' and labelbol = 'SOCIALPROMOTIONTIP');
INSERT INTO ld_desk(languagetype, labelbol, fieldlabel, labeltype)
select 'en', 'SOCIALPROMOTIONTIP', 'Social promotion instructions', 'fixedstr'
from dual
where not exists(select 1 from ld_desk where languagetype = 'en' and labelbol = 'SOCIALPROMOTIONTIP');
delimiter;

INSERT INTO ld_desk(languagetype, labelbol, fieldlabel, labeltype)
select 'zh', 'SOCIALPROMOTIONDESC', '社交推广可自定义活动页面，通过分享到微信、微博、QQ等社交平台，进行营销推广与信息收集。', 'fixedstr'
from dual
where not exists(select 1 from ld_desk where languagetype = 'zh' and labelbol = 'SOCIALPROMOTIONDESC');
INSERT INTO ld_desk(languagetype, labelbol, fieldlabel, labeltype)
select 'en', 'SOCIALPROMOTIONDESC', 'The activity page can be customized and shared to wechat, Weibo, QQ and other social platforms for marketing promotion and information collection.', 'fixedstr'
from dual
where not exists(select 1 from ld_desk where languagetype = 'en' and labelbol = 'SOCIALPROMOTIONDESC');
delimiter;

INSERT INTO ld_desk(languagetype, labelbol, fieldlabel, labeltype)
select 'zh', 'STEP1', '第一步', 'fixedstr'
from dual
where not exists(select 1 from ld_desk where languagetype = 'zh' and labelbol = 'STEP1');
INSERT INTO ld_desk(languagetype, labelbol, fieldlabel, labeltype)
select 'en', 'STEP1', 'Step 1', 'fixedstr'
from dual
where not exists(select 1 from ld_desk where languagetype = 'en' and labelbol = 'STEP1');
delimiter;

INSERT INTO ld_desk(languagetype, labelbol, fieldlabel, labeltype)
select 'zh', 'STEP2', '第二步', 'fixedstr'
from dual
where not exists(select 1 from ld_desk where languagetype = 'zh' and labelbol = 'STEP2');
INSERT INTO ld_desk(languagetype, labelbol, fieldlabel, labeltype)
select 'en', 'STEP2', 'Step 2', 'fixedstr'
from dual
where not exists(select 1 from ld_desk where languagetype = 'en' and labelbol = 'STEP2');
delimiter;

INSERT INTO ld_desk(languagetype, labelbol, fieldlabel, labeltype)
select 'zh', 'STEP3', '第三步', 'fixedstr'
from dual
where not exists(select 1 from ld_desk where languagetype = 'zh' and labelbol = 'STEP3');
INSERT INTO ld_desk(languagetype, labelbol, fieldlabel, labeltype)
select 'en', 'STEP3', 'Step 3', 'fixedstr'
from dual
where not exists(select 1 from ld_desk where languagetype = 'en' and labelbol = 'STEP3');
delimiter;

INSERT INTO ld_desk(languagetype, labelbol, fieldlabel, labeltype)
select 'zh', 'STEP4', '第四步', 'fixedstr'
from dual
where not exists(select 1 from ld_desk where languagetype = 'zh' and labelbol = 'STEP4');
INSERT INTO ld_desk(languagetype, labelbol, fieldlabel, labeltype)
select 'en', 'STEP4', 'Step 4', 'fixedstr'
from dual
where not exists(select 1 from ld_desk where languagetype = 'en' and labelbol = 'STEP4');
delimiter;


INSERT INTO ld_desk(languagetype, labelbol, fieldlabel, labeltype)
select 'zh', 'NEXTSTEP', '下一步', 'fixedstr'
from dual
where not exists(select 1 from ld_desk where languagetype = 'zh' and labelbol = 'NEXTSTEP');
INSERT INTO ld_desk(languagetype, labelbol, fieldlabel, labeltype)
select 'en', 'NEXTSTEP', 'Next Step', 'fixedstr'
from dual
where not exists(select 1 from ld_desk where languagetype = 'en' and labelbol = 'NEXTSTEP');
delimiter;

INSERT INTO ld_desk(languagetype, labelbol, fieldlabel, labeltype)
select 'zh', 'SETACTIVITYTYPE', '设置活动类型', 'fixedstr'
from dual
where not exists(select 1 from ld_desk where languagetype = 'zh' and labelbol = 'SETACTIVITYTYPE');
INSERT INTO ld_desk(languagetype, labelbol, fieldlabel, labeltype)
select 'en', 'SETACTIVITYTYPE', 'Set activity type', 'fixedstr'
from dual
where not exists(select 1 from ld_desk where languagetype = 'en' and labelbol = 'SETACTIVITYTYPE');
delimiter;

INSERT INTO ld_desk(languagetype, labelbol, fieldlabel, labeltype)
select 'zh', 'CUSTOMACTIVITYPAGE', '定制活动页面', 'fixedstr'
from dual
where not exists(select 1 from ld_desk where languagetype = 'zh' and labelbol = 'CUSTOMACTIVITYPAGE');
INSERT INTO ld_desk(languagetype, labelbol, fieldlabel, labeltype)
select 'en', 'CUSTOMACTIVITYPAGE', 'Custom activity page', 'fixedstr'
from dual
where not exists(select 1 from ld_desk where languagetype = 'en' and labelbol = 'CUSTOMACTIVITYPAGE');
delimiter;

INSERT INTO ld_desk(languagetype, labelbol, fieldlabel, labeltype)
select 'zh', 'SHARINGSETTINGS', '分享设置', 'fixedstr'
from dual
where not exists(select 1 from ld_desk where languagetype = 'zh' and labelbol = 'SHARINGSETTINGS');
INSERT INTO ld_desk(languagetype, labelbol, fieldlabel, labeltype)
select 'en', 'SHARINGSETTINGS', 'Sharing settings', 'fixedstr'
from dual
where not exists(select 1 from ld_desk where languagetype = 'en' and labelbol = 'SHARINGSETTINGS');
delimiter;

INSERT INTO ld_desk(languagetype, labelbol, fieldlabel, labeltype)
select 'zh', 'SPCOMPLETED', '完成', 'fixedstr'
from dual
where not exists(select 1 from ld_desk where languagetype = 'zh' and labelbol = 'SPCOMPLETED');
INSERT INTO ld_desk(languagetype, labelbol, fieldlabel, labeltype)
select 'en', 'SPCOMPLETED', 'Completed', 'fixedstr'
from dual
where not exists(select 1 from ld_desk where languagetype = 'en' and labelbol = 'SPCOMPLETED');
delimiter;


INSERT INTO ld_desk(languagetype, labelbol, fieldlabel, labeltype)
select 'zh', 'ACTIVITYDESCFORM', '活动类型说明：仅是一张表单，可在微信等社交平台上进行分享和推广，用户填写后自动生成映射表单', 'fixedstr'
from dual
where not exists(select 1 from ld_desk where languagetype = 'zh' and labelbol = 'ACTIVITYDESCFORM');
INSERT INTO ld_desk(languagetype, labelbol, fieldlabel, labeltype)
select 'en', 'ACTIVITYDESCFORM', 'Description: it is only a form, which can be shared and promoted on social platforms such as wechat. When the user submits it, the mapping form will be created automatically.', 'fixedstr'
from dual
where not exists(select 1 from ld_desk where languagetype = 'en' and labelbol = 'ACTIVITYDESCFORM');
delimiter;

INSERT INTO ld_desk(languagetype, labelbol, fieldlabel, labeltype)
select 'zh', 'ACTIVITYDESCH5ANDFORM', '活动类型说明：由 H5 页面（如微场景，仅支持 https 链接）和表单组成，可在微信等社交平台上进行分享和推广，用户填写后自动生成映射表单。', 'fixedstr'
from dual
where not exists(select 1 from ld_desk where languagetype = 'zh' and labelbol = 'ACTIVITYDESCH5ANDFORM');
INSERT INTO ld_desk(languagetype, labelbol, fieldlabel, labeltype)
select 'en', 'ACTIVITYDESCH5ANDFORM', 'Description: it consists of H5 page (only https link is supported) and form, which can be shared and promoted on social platforms such as wechat. When the user submits it, the mapping form will be created automatically.', 'fixedstr'
from dual
where not exists(select 1 from ld_desk where languagetype = 'en' and labelbol = 'ACTIVITYDESCH5ANDFORM');
delimiter;

INSERT INTO ld_desk(languagetype, labelbol, fieldlabel, labeltype)
select 'zh', 'ACTIVITYH5PAGEHELP', '如何制作 H5 页面并获取链接地址?', 'fixedstr'
from dual
where not exists(select 1 from ld_desk where languagetype = 'zh' and labelbol = 'ACTIVITYH5PAGEHELP');
INSERT INTO ld_desk(languagetype, labelbol, fieldlabel, labeltype)
select 'en', 'ACTIVITYH5PAGEHELP', 'How to make H5 page and get the link URL?', 'fixedstr'
from dual
where not exists(select 1 from ld_desk where languagetype = 'en' and labelbol = 'ACTIVITYH5PAGEHELP');
delimiter;

INSERT INTO ld_desk(languagetype, labelbol, fieldlabel, labeltype)
select 'zh', 'ACTIVITYADDFIELD', '添加字段', 'fixedstr'
from dual
where not exists(select 1 from ld_desk where languagetype = 'zh' and labelbol = 'ACTIVITYADDFIELD');
INSERT INTO ld_desk(languagetype, labelbol, fieldlabel, labeltype)
select 'en', 'ACTIVITYADDFIELD', 'Add Field', 'fixedstr'
from dual
where not exists(select 1 from ld_desk where languagetype = 'en' and labelbol = 'ACTIVITYADDFIELD');
delimiter;

INSERT INTO ld_desk(languagetype, labelbol, fieldlabel, labeltype)
select 'zh', 'ACTIVITYCRMFIELD', '系统字段', 'fixedstr'
from dual
where not exists(select 1 from ld_desk where languagetype = 'zh' and labelbol = 'ACTIVITYCRMFIELD');
INSERT INTO ld_desk(languagetype, labelbol, fieldlabel, labeltype)
select 'en', 'ACTIVITYCRMFIELD', 'CRM Field', 'fixedstr'
from dual
where not exists(select 1 from ld_desk where languagetype = 'en' and labelbol = 'ACTIVITYCRMFIELD');
delimiter;

INSERT INTO ld_desk(languagetype, labelbol, fieldlabel, labeltype)
select 'zh', 'ACTIVITYDISPLAYLABEL', '显示名称', 'fixedstr'
from dual
where not exists(select 1 from ld_desk where languagetype = 'zh' and labelbol = 'ACTIVITYDISPLAYLABEL');
INSERT INTO ld_desk(languagetype, labelbol, fieldlabel, labeltype)
select 'en', 'ACTIVITYDISPLAYLABEL', 'Display label', 'fixedstr'
from dual
where not exists(select 1 from ld_desk where languagetype = 'en' and labelbol = 'ACTIVITYDISPLAYLABEL');
delimiter;

INSERT INTO ld_desk(languagetype, labelbol, fieldlabel, labeltype)
select 'zh', 'ACTIVITYMUSTFILL', '必填', 'fixedstr'
from dual
where not exists(select 1 from ld_desk where languagetype = 'zh' and labelbol = 'ACTIVITYMUSTFILL');
INSERT INTO ld_desk(languagetype, labelbol, fieldlabel, labeltype)
select 'en', 'ACTIVITYMUSTFILL', 'Must Fill', 'fixedstr'
from dual
where not exists(select 1 from ld_desk where languagetype = 'en' and labelbol = 'ACTIVITYMUSTFILL');
delimiter;

INSERT INTO ld_desk(languagetype, labelbol, fieldlabel, labeltype)
select 'zh', 'ACTIVITYONLYFIELD', '唯一', 'fixedstr'
from dual
where not exists(select 1 from ld_desk where languagetype = 'zh' and labelbol = 'ACTIVITYONLYFIELD');
INSERT INTO ld_desk(languagetype, labelbol, fieldlabel, labeltype)
select 'en', 'ACTIVITYONLYFIELD', 'Only', 'fixedstr'
from dual
where not exists(select 1 from ld_desk where languagetype = 'en' and labelbol = 'ACTIVITYONLYFIELD');
delimiter;

INSERT INTO ld_desk(languagetype, labelbol, fieldlabel, labeltype)
select 'zh', 'ACTIVITYOPERATION', '操作', 'fixedstr'
from dual
where not exists(select 1 from ld_desk where languagetype = 'zh' and labelbol = 'ACTIVITYOPERATION');
INSERT INTO ld_desk(languagetype, labelbol, fieldlabel, labeltype)
select 'en', 'ACTIVITYOPERATION', 'Operation', 'fixedstr'
from dual
where not exists(select 1 from ld_desk where languagetype = 'en' and labelbol = 'ACTIVITYOPERATION');
delimiter;

INSERT INTO ld_desk(languagetype, labelbol, fieldlabel, labeltype)
select 'zh', 'ACTIVITYSHAREWITHOTHERS', '共享给其他人', 'fixedstr'
from dual
where not exists(select 1 from ld_desk where languagetype = 'zh' and labelbol = 'ACTIVITYSHARESCOPENOSHARE');
INSERT INTO ld_desk(languagetype, labelbol, fieldlabel, labeltype)
select 'en', 'ACTIVITYSHAREWITHOTHERS', 'Share with others', 'fixedstr'
from dual
where not exists(select 1 from ld_desk where languagetype = 'en' and labelbol = 'ACTIVITYSHARESCOPENOSHARE');
delimiter;

INSERT INTO ld_desk(languagetype, labelbol, fieldlabel, labeltype)
select 'zh', 'ACTIVITYSHARESCOPENOSHARE', '不共享', 'fixedstr'
from dual
where not exists(select 1 from ld_desk where languagetype = 'zh' and labelbol = 'ACTIVITYSHARESCOPENOSHARE');
INSERT INTO ld_desk(languagetype, labelbol, fieldlabel, labeltype)
select 'en', 'ACTIVITYSHARESCOPENOSHARE', 'No Shared', 'fixedstr'
from dual
where not exists(select 1 from ld_desk where languagetype = 'en' and labelbol = 'ACTIVITYSHARESCOPENOSHARE');
delimiter;

INSERT INTO ld_desk(languagetype, labelbol, fieldlabel, labeltype)
select 'zh', 'ACTIVITYCREATEDSUCCESSFULLY', '创建成功', 'fixedstr'
from dual
where not exists(select 1 from ld_desk where languagetype = 'zh' and labelbol = 'ACTIVITYCREATEDSUCCESSFULLY');
INSERT INTO ld_desk(languagetype, labelbol, fieldlabel, labeltype)
select 'en', 'ACTIVITYCREATEDSUCCESSFULLY', 'Created successfully', 'fixedstr'
from dual
where not exists(select 1 from ld_desk where languagetype = 'en' and labelbol = 'ACTIVITYCREATEDSUCCESSFULLY');
delimiter;

INSERT INTO ld_desk(languagetype, labelbol, fieldlabel, labeltype)
select 'zh', 'ACTIVITYMARKETINGPROMOTIONCODE', '推广码', 'fixedstr'
from dual
where not exists(select 1 from ld_desk where languagetype = 'zh' and labelbol = 'ACTIVITYMARKETINGPROMOTIONCODE');
INSERT INTO ld_desk(languagetype, labelbol, fieldlabel, labeltype)
select 'en', 'ACTIVITYMARKETINGPROMOTIONCODE', 'Marketing promotion code', 'fixedstr'
from dual
where not exists(select 1 from ld_desk where languagetype = 'en' and labelbol = 'ACTIVITYMARKETINGPROMOTIONCODE');
delimiter;

INSERT INTO ld_desk(languagetype, labelbol, fieldlabel, labeltype)
select 'zh', 'ACTIVITYMOBILEPHONESCANANDSHARE', '手机扫一扫分享', 'fixedstr'
from dual
where not exists(select 1 from ld_desk where languagetype = 'zh' and labelbol = 'ACTIVITYMOBILEPHONESCANANDSHARE');
INSERT INTO ld_desk(languagetype, labelbol, fieldlabel, labeltype)
select 'en', 'ACTIVITYMOBILEPHONESCANANDSHARE', 'Mobile phone scan and share', 'fixedstr'
from dual
where not exists(select 1 from ld_desk where languagetype = 'en' and labelbol = 'ACTIVITYMOBILEPHONESCANANDSHARE');
delimiter;

INSERT INTO ld_desk(languagetype, labelbol, fieldlabel, labeltype)
select 'zh', 'ACTIVITYDOWNEWM', '下载二维码', 'fixedstr'
from dual
where not exists(select 1 from ld_desk where languagetype = 'zh' and labelbol = 'ACTIVITYDOWNEWM');
INSERT INTO ld_desk(languagetype, labelbol, fieldlabel, labeltype)
select 'en', 'ACTIVITYDOWNEWM', 'Download QR code', 'fixedstr'
from dual
where not exists(select 1 from ld_desk where languagetype = 'en' and labelbol = 'ACTIVITYDOWNEWM');
delimiter;

INSERT INTO ld_desk(languagetype, labelbol, fieldlabel, labeltype)
select 'zh', 'ACTIVITYCOPYURL', '复制链接', 'fixedstr'
from dual
where not exists(select 1 from ld_desk where languagetype = 'zh' and labelbol = 'ACTIVITYCOPYURL');
INSERT INTO ld_desk(languagetype, labelbol, fieldlabel, labeltype)
select 'en', 'ACTIVITYCOPYURL', 'Copy link', 'fixedstr'
from dual
where not exists(select 1 from ld_desk where languagetype = 'en' and labelbol = 'ACTIVITYCOPYURL');
delimiter;

INSERT INTO ld_desk(languagetype, labelbol, fieldlabel, labeltype)
select 'zh', 'CRMSOCIALPROMOTION', 'CRM社交推广', 'fixedstr'
from dual
where not exists(select 1 from ld_desk where languagetype = 'zh' and labelbol = 'CRMSOCIALPROMOTION');
INSERT INTO ld_desk(languagetype, labelbol, fieldlabel, labeltype)
select 'en', 'CRMSOCIALPROMOTION', 'CRM Social Promotion', 'fixedstr'
from dual
where not exists(select 1 from ld_desk where languagetype = 'en' and labelbol = 'CRMSOCIALPROMOTION');
delimiter;

INSERT INTO ld_desk(languagetype, labelbol, fieldlabel, labeltype)
select 'zh', 'ACTIVITYFIELDSETTINGS', '字段设置', 'fixedstr'
from dual
where not exists(select 1 from ld_desk where languagetype = 'zh' and labelbol = 'ACTIVITYFIELDSETTINGS');
INSERT INTO ld_desk(languagetype, labelbol, fieldlabel, labeltype)
select 'en', 'ACTIVITYFIELDSETTINGS', 'Field Settings', 'fixedstr'
from dual
where not exists(select 1 from ld_desk where languagetype = 'en' and labelbol = 'ACTIVITYFIELDSETTINGS');
delimiter;
-- 2020-07-01


update ld_field SET	columnname ='activityintroduction' where tablename ='ld_socialpromotionscf' and columnname='activityIntroduction';
delimiter;

select tabid into @tabid from ld_tab where name='SocialPromotion';
set @blockid = (SELECT blockid FROM ld_blocks where blocklabel ='第三步' and tabid =@tabid);
update ld_field set block = @blockid WHERE tablename='ld_attachments' and fieldname='sharepicture';
delimiter;



UPDATE ld_desk SET fieldlabel='1.	{$HelpDesk.HelpDesk}业绩=({$HelpDesk.productcategory}绩效基数*{$HelpDesk.ticketcategories}绩效权重+{$Accounts.bill_city}绩效基数)*{$HelpDesk.servicetype}绩效权重*AVG({$ServiceReturn.resolutionrate})*AVG({$ServiceReturn.timelyrate})*AVG({$ServiceReturn.satisfaction})'
WHERE labelbol='Performance_scores_1' AND languagetype='zh' AND Labeltype='fixedstr';
UPDATE ld_desk SET fieldlabel='1.	Performance scores of {$HelpDesk.HelpDesk}=scores of ({$HelpDesk.productcategory} * {$HelpDesk.ticketcategories} weight + scores of {$Accounts.bill_city})*{$HelpDesk.servicetype} weight*AVG({$ServiceReturn.resolutionrate})*AVG({$ServiceReturn.timelyrate})*AVG({$ServiceReturn.satisfaction})'
WHERE labelbol='Performance_scores_1' AND languagetype='en' AND Labeltype='fixedstr';
UPDATE ld_desk SET fieldlabel='2.	{$ProjectTask.ProjectTask}业绩=({$HelpDesk.productcategory}绩效基数*{$ProjectTask.projecttasktype}绩效权重+{$Accounts.bill_city}绩效基数)'
WHERE labelbol='Performance_scores_2' AND languagetype='zh' AND Labeltype='fixedstr';
UPDATE ld_desk SET fieldlabel='2.	Performance scores of {$ProjectTask.ProjectTask}=scores of {$HelpDesk.productcategory} * {$ProjectTask.projecttasktype} weight + scores of {$Accounts.bill_city}'
WHERE labelbol='Performance_scores_2' AND languagetype='en' AND Labeltype='fixedstr';
delimiter;


insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','Performance_scores_3','{$HelpDesk.productcategory}绩效基数：{$Products.Products}->{$Products.productcategory}的绩效参数','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype = 'zh' and labelbol = 'Performance_scores_3' and labeltype = 'fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','Performance_scores_3','scores of {$HelpDesk.productcategory}:{$Products.Products}->scores of {$Products.productcategory}','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype = 'en' and labelbol = 'Performance_scores_3' and labeltype = 'fixedstr');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','Performance_scores_4','{$HelpDesk.ticketcategories}绩效权重：{$HelpDesk.HelpDesk}->{$HelpDesk.ticketcategories}的权重','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype = 'zh' and labelbol = 'Performance_scores_4' and labeltype = 'fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','Performance_scores_4','{$HelpDesk.ticketcategories} weight:{$HelpDesk.HelpDesk}->{$HelpDesk.ticketcategories} weight','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype = 'en' and labelbol = 'Performance_scores_4' and labeltype = 'fixedstr');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','Performance_scores_5','{$Accounts.bill_city}绩效基数：{$Accounts.Accounts}->{$Accounts.bill_city}的绩效基数','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype = 'zh' and labelbol = 'Performance_scores_5' and labeltype = 'fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','Performance_scores_5','scores of {$Accounts.bill_city}:{$Accounts.Accounts}->scores of {$Accounts.bill_city}','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype = 'en' and labelbol = 'Performance_scores_5' and labeltype = 'fixedstr');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','Performance_scores_6','{$HelpDesk.servicetype}绩效权重：{$HelpDesk.HelpDesk}->{$HelpDesk.servicetype}的绩效权重','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype = 'zh' and labelbol = 'Performance_scores_6' and labeltype = 'fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','Performance_scores_6','{$HelpDesk.servicetype} weight:{$HelpDesk.HelpDesk}->{$HelpDesk.servicetype} weight','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype = 'en' and labelbol = 'Performance_scores_6' and labeltype = 'fixedstr');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','Performance_scores_7','{$ProjectTask.projecttasktype}绩效权重：{$ProjectTask.ProjectTask}->{$ProjectTask.projecttasktype}的绩效权重','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype = 'zh' and labelbol = 'Performance_scores_7' and labeltype = 'fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','Performance_scores_7','{$ProjectTask.projecttasktype} weight:{$ProjectTask.ProjectTask}->{$ProjectTask.projecttasktype} weight','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype = 'en' and labelbol = 'Performance_scores_7' and labeltype = 'fixedstr');
delimiter;
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','Performance_scores_8','AVG（{$ServiceReturn.resolutionrate}）：{$HelpDesk.HelpDesk}->关联的{$ServiceReturn.ServiceReturn}的{$ServiceReturn.resolutionrate}的平均值','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype = 'zh' and labelbol = 'Performance_scores_8' and labeltype = 'fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','Performance_scores_8','AVG({$ServiceReturn.resolutionrate}):{$HelpDesk.HelpDesk}->Average of {$ServiceReturn.resolutionrate} for associated {$ServiceReturn.ServiceReturn}','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype = 'en' and labelbol = 'Performance_scores_8' and labeltype = 'fixedstr');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','Performance_scores_9','AVG（{$ServiceReturn.timelyrate}）：{$HelpDesk.HelpDesk}->关联的{$ServiceReturn.ServiceReturn}的{$ServiceReturn.timelyrate}的平均值','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype = 'zh' and labelbol = 'Performance_scores_9' and labeltype = 'fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','Performance_scores_9','AVG({$ServiceReturn.timelyrate}):{$HelpDesk.HelpDesk}->Average of {$ServiceReturn.timelyrate} for associated {$ServiceReturn.ServiceReturn}','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype = 'en' and labelbol = 'Performance_scores_9' and labeltype = 'fixedstr');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','Performance_scores_10','AVG（{$ServiceReturn.satisfaction}）：{$HelpDesk.HelpDesk}->关联的{$ServiceReturn.ServiceReturn}的{$ServiceReturn.satisfaction}的平均值','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype = 'zh' and labelbol = 'Performance_scores_10' and labeltype = 'fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','Performance_scores_10','AVG({$ServiceReturn.satisfaction}):{$HelpDesk.HelpDesk}->Average of {$ServiceReturn.satisfaction} for associated {$ServiceReturn.ServiceReturn}','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype = 'en' and labelbol = 'Performance_scores_10' and labeltype = 'fixedstr');
delimiter;

update ld_field set uitype=199,bigtype='Users' where  tabid=6 and columnname='lastdistributer';
delimiter;

SET @disable_triggers=1;
update ld_account 
INNER JOIN ld_users on ld_users.last_name=ld_account.lastdistributer
set lastdistributer=ld_users.id;
SET @disable_triggers=NULL;
delimiter;

set @listid = (select listid from ld_picklist_set where listname ='mappingmodule');
UPDATE `ld_picklist_values` SET `listvalue` = 'Accounts' WHERE `listid` = @listid and listvalue='客户';
UPDATE `ld_picklist_values` SET `listvalue` = 'Leads' WHERE `listid` = @listid and listvalue='销售线索';
delimiter;

UPDATE `ld_field` SET `defaultvalue` = 'Accounts' WHERE `tabid` = (SELECT tabid from ld_tab where name='SocialPromotion') and fieldname='mappingmodule';
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','APPROVEDEFAULTVALUEONNEWMINI','移动端新建默认','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype = 'zh' and labelbol = 'APPROVEDEFAULTVALUEONNEWMINI' and labeltype = 'fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','APPROVEDEFAULTVALUEONNEWMINI','Mobile new default','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype = 'en' and labelbol = 'APPROVEDEFAULTVALUEONNEWMINI' and labeltype = 'fixedstr');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','APPROVEDEFAULTVALUEONSUBMITMINI','提交审批默认','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype = 'zh' and labelbol = 'APPROVEDEFAULTVALUEONSUBMITMINI' and labeltype = 'fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','APPROVEDEFAULTVALUEONSUBMITMINI','Submit approval default','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype = 'en' and labelbol = 'APPROVEDEFAULTVALUEONSUBMITMINI' and labeltype = 'fixedstr');
delimiter;


set @tabid = (select tabid from ld_tab where name ='SocialPromotion');
INSERT INTO ld_profileallpermission(tabid, operation, sequence)
select @tabid, '1', '4'
from dual
where not exists(select 1 from ld_profileallpermission where tabid = @tabid and operation = '1');
set @tabid = (select tabid from ld_tab where name ='SocialPromotion');
INSERT INTO ld_profileallpermission(tabid, operation, sequence)
select @tabid, '2', '5'
from dual
where not exists(select 1 from ld_profileallpermission where tabid = @tabid and operation = '2');
set @tabid = (select tabid from ld_tab where name ='SocialPromotion');
INSERT INTO ld_profileallpermission(tabid, operation, sequence)
select @tabid, '3', '1'
from dual
where not exists(select 1 from ld_profileallpermission where tabid = @tabid and operation = '3');
set @tabid = (select tabid from ld_tab where name ='SocialPromotion');
INSERT INTO ld_profileallpermission(tabid, operation, sequence)
select @tabid, '4', '2'
from dual
where not exists(select 1 from ld_profileallpermission where tabid = @tabid and operation = '4');
INSERT INTO ld_profileallpermission(tabid, operation, sequence)
select @tabid, '11', '3'
from dual
where not exists(select 1 from ld_profileallpermission where tabid = @tabid and operation = '11');
INSERT INTO ld_profileallpermission(tabid, operation, sequence)
select @tabid, '13', '6'
from dual
where not exists(select 1 from ld_profileallpermission where tabid = @tabid and operation = '13');
INSERT INTO ld_profileallpermission(tabid, operation, sequence)
select @tabid, '14', '7'
from dual
where not exists(select 1 from ld_profileallpermission where tabid = @tabid and operation = '14');

INSERT INTO ld_profileallpermission(tabid, operation, sequence)
select @tabid, '25', '8'
from dual
where not exists(select 1 from ld_profileallpermission where tabid = @tabid and operation = '25');

INSERT INTO ld_profileallpermission(tabid, operation, sequence)
select @tabid, '37', '9'
from dual
where not exists(select 1 from ld_profileallpermission where tabid = @tabid and operation = '37');
delimiter;

set @tabid = (select tabid from ld_tab where name ='SocialPromotion');
set @relation_id = (select id from ld_relatedlists_seq)+1;
INSERT INTO `ld_relatedlists`(`relation_id`, `tabid`, `related_tabid`, `name`, `sequence`, `label`, `presence`, `actions`, `mobile_presence`, `mobile_sequence`, `type`, `related_coltable`, `wx_presence`, `wx_sequence`, `trade`, `islistbutton`, `buttonstatus`, `dynamicstatus`) select @relation_id, @tabid, -5, 'get_SharedUsers', 0, 'SharedUsers', 0, 'share', 0, 35, NULL, NULL, 0, 2, NULL, NULL, 'yes', NULL from dual where not exists (SELECT 1 from ld_relatedlists where tabid =@tabid and  name ='get_SharedUsers');

UPDATE ld_relatedlists_seq set id = (SELECT max(relation_id) from ld_relatedlists);
delimiter;

INSERT INTO ld_desk(languagetype, labelbol, fieldlabel, labeltype)
select 'zh', 'ACTIVITYSHAREWITHOTHERS', '共享给其他人', 'fixedstr'
from dual
where not exists(select 1 from ld_desk where languagetype = 'zh' and labelbol = 'ACTIVITYSHAREWITHOTHERS');
INSERT INTO ld_desk(languagetype, labelbol, fieldlabel, labeltype)
select 'en', 'ACTIVITYSHAREWITHOTHERS', 'Share with others', 'fixedstr'
from dual
where not exists(select 1 from ld_desk where languagetype = 'en' and labelbol = 'ACTIVITYSHAREWITHOTHERS');
delimiter;
-- 2020-07-03

UPDATE ld_tab SET presence=1 WHERE `name`='SocialPromotion';

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

UPDATE ld_version SET old_version='V8.1.1',current_version='V8.1.1',remark='V8.1.1-20200703',wx_version='V8.1.1';
delimiter;