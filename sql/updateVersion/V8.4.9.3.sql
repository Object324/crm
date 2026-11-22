DROP FUNCTION IF EXISTS `func_is_accountexists`;
delimiter ||
CREATE FUNCTION `func_is_accountexists`(in_accountname TEXT,in_accountid INT(19)) RETURNS VARCHAR(10)
BEGIN  

	SET @thishalf_accountname=func_changeToHalfAngle(in_accountname);

	SET @this_existsinfo=(
		SELECT
			CASE
				WHEN EXISTS (SELECT 1 FROM ld_account WHERE deleted=0 AND accountname_halfangle=@thishalf_accountname
								AND (CASE WHEN in_accountid+0>0 THEN accountid<>in_accountid+0 ELSE 1=1 END)) THEN 'yes'
				ELSE 'no'
			END
	);

	RETURN(@this_existsinfo);

END || 
delimiter;

SET @id=(SELECT id FROm ld_validatasavemain WHERE rulename='客户名称去重(忽略全角和半角)' AND module='Accounts');
UPDATE ld_validatasave SET fieldname="SELECT func_is_accountexists('{ld_account.accountname}','{Record.ID}') AS tmp_value" WHERE validatasavemainid=@id;
delimiter;

SET @id=(SELECT id FROm ld_validatasavemain WHERE rulename='客户名称去重(忽略全角和半角)' AND module='ServiceCharge');
UPDATE ld_validatasave SET fieldname="SELECT func_is_accountexists('{ld_account.accountname}','{Record.ID}') AS tmp_value" WHERE validatasavemainid=@id;
delimiter;

SET @labelbol = 'DINGTALKINTERFACEREMIND';
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'zh',@labelbol,'请将“PC端首页地址”参数输入到钉钉开发者平台->H5微应用->PC端首页地址中','fixedstr' FROM DUAL 
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol=@labelbol and Labeltype='fixedstr');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'en',@labelbol,'Please enter the parameters of "PC home address" according to DingTalkDeveloper Platform ->H5 Micro Application->PC home address','fixedstr' FROM DUAL 
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol=@labelbol and Labeltype='fixedstr');
delimiter;

UPDATE ld_desk SET fieldlabel='更新已完成！' where labelbol='thelogdatecannotbegreater' and languagetype='zh' ;
UPDATE ld_desk SET fieldlabel='Update is finished!' where labelbol='thelogdatecannotbegreater' and languagetype='en' ;
delimiter;

UPDATE ld_desk SET fieldlabel='您没有权限查看其他成员的单据！' where labelbol='YOUARENOTALLOWEDTOVIEWOTHERUSERSDATE' and languagetype='zh' ;
UPDATE ld_desk SET fieldlabel='You are not allowed to view other users data!' where labelbol='YOUARENOTALLOWEDTOVIEWOTHERUSERSDATE' and languagetype='en' ;
delimiter;

UPDATE ld_desk SET fieldlabel='客户最晚服务到期日到期后不允许创建客户服务单！' where labelbol='thecurstomerserviceordersarenotallowedtobe' and languagetype='zh' ;
UPDATE ld_desk SET fieldlabel='The customer service orders are not allowed to be created after the latest service expiry date!' where labelbol='thecurstomerserviceordersarenotallowedtobe' and languagetype='en' ;
delimiter;

UPDATE ld_desk SET fieldlabel='日志日期不能大于当前日期！' where labelbol='thelogdatecannotbegreater' and languagetype='zh' ;
UPDATE ld_desk SET fieldlabel='The log date cannot be greater than the current date!' where labelbol='thelogdatecannotbegreater' and languagetype='en' ;
delimiter;

UPDATE ld_desk SET fieldlabel='您选择了{Var}条记录，批量操作只对前{Var}条记录生效，是否继续？' where labelbol='YOUSELECTMAXMASSOPERATIONLIMIT' and languagetype='zh' ;
UPDATE ld_desk SET fieldlabel='You select {Var} records, the mass operation only effect on the first {Var} records, continue or not?' where labelbol='YOUSELECTMAXMASSOPERATIONLIMIT' and languagetype='en' ;
delimiter;

DROP PROCEDURE IF EXISTS `ldcrm_addtable_fieldwxdetailinfo`;
delimiter ||
CREATE PROCEDURE `ldcrm_addtable_fieldwxdetailinfo`(
)
BEGIN

DECLARE tableExists INT DEFAULT 0;

IF NOT EXISTS (SELECT 1 FROM INFORMATION_SCHEMA.TABLES WHERE table_name = 'ld_fieldwxdetailinfo' AND TABLE_SCHEMA=DATABASE()) THEN
	CALL AddColumn('ld_tab','mobiledetailinfoshowtype','char','10','tile');

	CREATE TABLE if not EXISTS `ld_fieldwxdetailinfo` (
		`id` int(11) NOT NULL AUTO_INCREMENT,
		`tabid` int(11) DEFAULT 0 COMMENT '模块表ld_tab表id',
		`relatedtable` varchar(100) DEFAULT '' COMMENT '关联表ld_producttoolfield/ld_tabdetailfield',
		`columnname` varchar(100) DEFAULT NULL COMMENT '字段名对应ld_producttoolfield/ld_tabdetailfield的columnname',
		`sequence` int(4) DEFAULT 1 COMMENT '排序',
		`mobiledetailinfoshowtype` char(10) DEFAULT '' COMMENT '字段显示类型 fold折叠，table表格',
		PRIMARY KEY (`id`)
	) ENGINE=InnoDB DEFAULT CHARSET=utf8;

	insert into ld_fieldwxdetailinfo (tabid,relatedtable,columnname,sequence,mobiledetailinfoshowtype)select tabid,'ld_producttoolfield',columnname,sequence,'fold' from ld_producttoolfield where mobiledetailshow='yes';
	update ld_producttoolfield set mobiledetailshow='no' where mobiledetailshow='yes';
	insert into ld_fieldwxdetailinfo (tabid,relatedtable,columnname,sequence,mobiledetailinfoshowtype)select tabid,'ld_tabdetailfield',columnname,sequence,'fold' from ld_tabdetailfield where mobiledetailshow='yes';
	update ld_tabdetailfield set mobiledetailshow='no' where mobiledetailshow='yes';

    update ld_tab set ld_tab.mobiledetailinfoshowtype='tile';
END IF;

END ||
delimiter;

call ldcrm_addtable_fieldwxdetailinfo();
delimiter;

set @labelbol='Entrydetailsdisplaystyle';
set @labelzh='分录明细显示样式';
set @labelen='Entry details display style';
set @labeltype='fixedstr';
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh',@labelbol,@labelzh,@labeltype from dual
where not exists(select 1 from ld_desk where labelbol=@labelbol and Labeltype=@labeltype and languagetype='zh');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en',@labelbol,@labelen,@labeltype from dual
where not exists(select 1 from ld_desk where labelbol=@labelbol and Labeltype=@labeltype and languagetype='en');
delimiter;

set @labelbol='Tilefields';
set @labelzh='平铺字段';
set @labelen='Tile fields';
set @labeltype='fixedstr';
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh',@labelbol,@labelzh,@labeltype from dual
where not exists(select 1 from ld_desk where labelbol=@labelbol and Labeltype=@labeltype and languagetype='zh');

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en',@labelbol,@labelen,@labeltype from dual
where not exists(select 1 from ld_desk where labelbol=@labelbol and Labeltype=@labeltype and languagetype='en');
delimiter;

set @labelbol='Collapsefield';
set @labelzh='折叠字段';
set @labelen='Collapse field';
set @labeltype='fixedstr';
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh',@labelbol,@labelzh,@labeltype from dual
where not exists(select 1 from ld_desk where labelbol=@labelbol and Labeltype=@labeltype and languagetype='zh');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en',@labelbol,@labelen,@labeltype from dual
where not exists(select 1 from ld_desk where labelbol=@labelbol and Labeltype=@labeltype and languagetype='en');
delimiter;

set @labelbol='Tabledisplay';
set @labelzh='表格显示';
set @labelen='Table display';
set @labeltype='fixedstr';
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh',@labelbol,@labelzh,@labeltype from dual
where not exists(select 1 from ld_desk where labelbol=@labelbol and Labeltype=@labeltype and languagetype='zh');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en',@labelbol,@labelen,@labeltype from dual
where not exists(select 1 from ld_desk where labelbol=@labelbol and Labeltype=@labeltype and languagetype='en');
delimiter;

set @labelbol='uptovarcolumns';
set @labelzh='最多{Var}列';
set @labelen='up to {Var} columns';
set @labeltype='fixedstr';
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh',@labelbol,@labelzh,@labeltype from dual
where not exists(select 1 from ld_desk where labelbol=@labelbol and Labeltype=@labeltype and languagetype='zh');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en',@labelbol,@labelen,@labeltype from dual
where not exists(select 1 from ld_desk where labelbol=@labelbol and Labeltype=@labeltype and languagetype='en');
delimiter;

set @labelbol='uptovarcolumnstips';
set @labelzh='显示列最多只能选择{Var}列！';
set @labelen='Only {Var} columns can be selected at most!';
set @labeltype='fixedstr';
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh',@labelbol,@labelzh,@labeltype from dual
where not exists(select 1 from ld_desk where labelbol=@labelbol and Labeltype=@labeltype and languagetype='zh');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en',@labelbol,@labelen,@labeltype from dual
where not exists(select 1 from ld_desk where labelbol=@labelbol and Labeltype=@labeltype and languagetype='en');
delimiter;

set @labelbol='bellowtovarcolumnstips';
set @labelzh='显示列至少选择{Var}列！';
set @labelen='Select at least {Var} columns for display!';
set @labeltype='fixedstr';
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh',@labelbol,@labelzh,@labeltype from dual
where not exists(select 1 from ld_desk where labelbol=@labelbol and Labeltype=@labeltype and languagetype='zh');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en',@labelbol,@labelen,@labeltype from dual
where not exists(select 1 from ld_desk where labelbol=@labelbol and Labeltype=@labeltype and languagetype='en');
delimiter;
-- 2023-03-20

SET @i=IFNULL((SELECT MAX(blockid) FROM ld_blocks),0);
INSERT INTO ld_blocks(blockid,tabid,blocklabel,visible,display_status)
SELECT 
	(@i:=@i+1),
	tabid,
	'LBL_KEYWORDS',
	1,
	1
FROM ld_tab WHERE REPLACE(`name`,'CustomForm','')+0>0
	AND tabid NOT IN (SELECT tabid FROM ld_blocks WHERE blocklabel='LBL_KEYWORDS');
UPDATE ld_blocks_seq SET id=(SELECT MAX(blockid) FROM ld_blocks);
delimiter;

UPDATE ld_desk SET fieldlabel='您还没有添加题目！' where labelbol='AddTopicReminder' and languagetype='zh' ;
UPDATE ld_desk SET fieldlabel='You have not added a topic!' where labelbol='AddTopicReminder' and languagetype='en' ;
delimiter;
-- 2023-03-21


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

UPDATE ld_version SET old_version='V8.4.9.3',current_version='V8.4.9.3',remark='V8.4.9.3-20230321',wx_version='V8.4.9.2';
delimiter;