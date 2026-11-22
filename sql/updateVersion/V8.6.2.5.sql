CALL AddColumn('ld_users','zhiyuan_userid','varchar','100','');
delimiter;

SET @modulename='Users';
SET @tabid=(SELECT tabid FROM ld_tab WHERE `name`=@modulename);
SET @relateid=(SELECT block FROM ld_field WHERE tabid=@tabid AND columnname='user_name' LIMIT 1);
SET @maxseq=IFNULL((SELECT MAX(sequence) FROM ld_field WHERE tabid=@tabid AND block=@relateid),0);
SET @trantable='ld_field';
SET @tablename=(SELECT tablename FROM ld_field WHERE tabid=@tabid AND columnname='user_name' LIMIT 1);
SET @columnname='zhiyuan_userid';
SET @fieldname='zhiyuan_userid';
SET @zh='致远通讯录账号';
SET @en='zhiyuan userid';
SET @uitype=1;
SET @typeofdata='V~O';
SET @quickcreate=0;
SET @displaytype=1;
SET @bigtype='text';
SET @datarang='all';
SET @maxrowsshow=0;
SET @maxrowsshow=0;
SET @savedatabase = 'yes';
SET @allowedit = 'yes';

SET @maxid=(SELECT MAX(fieldid) FROM ld_field);
INSERT INTO ld_field(tabid,fieldid,columnname,tablename,generatedtype,uitype,fieldname,fieldlabel,readonly,presence,defaultvalue,maximumlength,sequence,block,displaytype,typeofdata,quickcreate,quickcreatesequence,info_type,masseditable,helpinfo,fieldonly,approve_demand,is_checkimportfield,bigtype,datarang,maxrowsshow,savedatabase,allowedit,allowedit_presence,allowcreate,allowcreate_presence,allowdetail_presence)
SELECT @tabid,@maxid+1,@columnname,@tablename,1,@uitype,@fieldname,@zh,1,2,NULL,100,@maxseq+1,@relateid,@displaytype,@typeofdata,@quickcreate,NULL,NULL,0,NULL,1,2,0,@bigtype,@datarang,@maxrowsshow,@savedatabase,@allowedit,'yes','yes','yes','yes' from dual
WHERE NOT EXISTS (SELECT 1 FROM ld_field WHERE tabid=@tabid AND tablename=@tablename AND columnname=@columnname);
UPDATE ld_field_seq SET id=(SELECT max(fieldid) FROM ld_field);
delimiter;

SET @relateid=(SELECT fieldid FROM ld_field WHERE tabid=@tabid AND columnname=@columnname LIMIT 1);
INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
SELECT 'zh',@trantable,@tabid,@relateid,@zh FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE languagetype = 'zh' AND trantable =@trantable AND tabid = @tabid AND relateid=@relateid);
INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
SELECT 'en',@trantable,@tabid,@relateid,@en FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE languagetype = 'en' AND trantable =@trantable AND tabid = @tabid AND relateid=@relateid);
delimiter;

ALTER TABLE ld_users MODIFY COLUMN zhiyuan_userid varchar(100) AFTER fanwei_userid;
delimiter;


CALL AddColumn('ld_reminds','push_to_zy','int','2',0);
delimiter;
CALL AddColumn('ld_reminds_accepted','push_to_zy','int','2',0);
delimiter;
CALL AddColumn('ld_workreport_remind','push_to_zy','int','2',0);
delimiter;
CALL AddColumn('ld_reminds','push_time_zy','datetime',null,null );
delimiter;
CALL AddColumn('ld_reminds_accepted','push_time_zy','datetime',null,null );
delimiter;
CALL AddColumn('ld_workreport_remind','push_time_zy','datetime',null,null );
delimiter;

alter table `ld_reminds` change `push_to_zy` `push_to_zy` int DEFAULT 2 COMMENT '提醒发送标识';
alter table `ld_reminds` change `push_time_zy` `push_time_zy` datetime COMMENT '提醒发送时间';
alter table `ld_reminds_accepted` change `push_to_zy` `push_to_zy` int DEFAULT 2 COMMENT '提醒发送标识';
alter table `ld_reminds_accepted` change `push_time_zy` `push_time_zy` datetime COMMENT '提醒发送时间';
alter table `ld_workreport_remind` change `push_to_zy` `push_to_zy` int DEFAULT 2 COMMENT '提醒发送标识';
alter table `ld_workreport_remind` change `push_time_zy` `push_time_zy` datetime COMMENT '提醒发送时间';
delimiter;

update ld_reminds set push_to_zy = 3 where push_to_zy = 0;
update ld_reminds_accepted set push_to_zy = 3 where push_to_zy = 0;
update ld_workreport_remind set push_to_zy = 3 where push_to_zy = 0;
delimiter;

insert into ld_wx_config (name,description) select 'zhiyuan_setting','致远设置' from dual where not exists(select 1 from ld_wx_config where name='zhiyuan_setting');
delimiter;

INSERT INTO ld_module_setting_byuser(modulename,userid,label,content)
SELECT 'notbymodule',1,'Modifyskinset','yes' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_module_setting_byuser WHERE label = 'Modifyskinset' and userid = 1);
delimiter;
update ld_module_setting_byuser set content='yes' where label = 'Modifyskinset' and content = 'no' and userid = 1;
delimiter;
-- 2024-01-26

SET @labelbol = 'ADVANCEFIELDRULEREMIND';set @labeltype = 'fixedstr';
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'zh',@labelbol,'该推进任务的布局规则中设置了必填字段，需进入“编辑”界面进行保存，是否继续？',@labeltype FROM DUAL 
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol=@labelbol and Labeltype=@labeltype);
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'en',@labelbol,'The layout rules for this push task have set required fields. You need to enter the Edit interface to save. Do you want to continue?',@labeltype FROM DUAL 
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol=@labelbol and Labeltype=@labeltype);
delimiter;

SET @labelbol = 'APPROVEFIELDRULEREMIND';set @labeltype = 'fixedstr';
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'zh',@labelbol,'该审批必填字段的布局规则中设置了必填字段，需进入“编辑”界面进行保存审批，是否继续？',@labeltype FROM DUAL 
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol=@labelbol and Labeltype=@labeltype);
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'en',@labelbol,'The layout rules for required fields in this approval have set required fields. You need to enter the Edit interface to save the approval. Do you want to continue?',@labeltype FROM DUAL 
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol=@labelbol and Labeltype=@labeltype);
delimiter;

UPDATE ld_desk SET fieldlabel = '数据库连接' where labelbol = 'DataBaseLink' AND Labeltype = 'fixedstr' AND languagetype = 'zh';
UPDATE ld_desk SET fieldlabel = 'DataBase Link' where labelbol = 'DataBaseLink' AND Labeltype = 'fixedstr' AND languagetype = 'en';
delimiter;

insert into ld_listview_btn(`name`,btntype,description,iconname)
select 'massrelease','rely','批量释放','massrelease.png' from dual
where not EXISTS(select 1 from ld_listview_btn where `name` = 'massrelease');
delimiter;
update ld_producttoolfield set bigtype='currency' where  columnname='total';
update ld_producttoolfield set bigtype='currency' where  columnname='tax_amount';
delimiter;


INSERT INTO ld_currencies(currency_name,currency_code,currency_symbol,description)
SELECT 'Bangladesh Taka','BDT','৳','孟加拉塔卡' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_currencies WHERE currency_name='Bangladesh Taka');

UPDATE ld_currencies_seq SET id=(SELECT MAX(currencyid) FROM ld_currencies);
delimiter;

CREATE TABLE IF NOT EXISTS `ld_calendar_colorrule` (
    `id` int(11) NOT NULL AUTO_INCREMENT COMMENT '规则id',
    `name` varchar(100) DEFAULT NULL COMMENT '规则名',
    `status` varchar(20) DEFAULT NULL COMMENT '规则状态',
    `sequence` int(11) NOT NULL COMMENT '优先级',
    `backgroundcolor` varchar(20) DEFAULT NULL COMMENT '背景色',
    `textcolor` varchar(20) DEFAULT NULL COMMENT '字体色',
    `rulevalue` text DEFAULT NULL COMMENT '条件内容',
    `createdtime` datetime DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    `modifiedtime` datetime DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '修改时间',
    PRIMARY KEY (`id`)
    ) ENGINE=InnoDB DEFAULT CHARSET=utf8;
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','CustomColor','自定义颜色','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='CustomColor' and Labeltype='fixedstr' and languagetype='zh');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','CustomColor','Custom color','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='CustomColor' and Labeltype='fixedstr' and languagetype='en');
delimiter;
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','EnableCustomColorRules','启用自定义颜色规则','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='EnableCustomColorRules' and Labeltype='fixedstr' and languagetype='zh');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','EnableCustomColorRules','Enable custom color rules','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='EnableCustomColorRules' and Labeltype='fixedstr' and languagetype='en');
delimiter;
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','RuleValidityVondition','规则生效条件','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='RuleValidityVondition' and Labeltype='fixedstr' and languagetype='zh');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','RuleValidityVondition','Rule validity condition','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='RuleValidityVondition' and Labeltype='fixedstr' and languagetype='en');
delimiter;
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','RuleValidityVonditionTooltips','满足条件时规则生效，不满足条件时按系统默认色显示','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='RuleValidityVonditionTooltips' and Labeltype='fixedstr' and languagetype='zh');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','RuleValidityVonditionTooltips','If the conditions are met, the rule takes effect. If the conditions are not met, the rule is displayed in the default color','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='RuleValidityVonditionTooltips' and Labeltype='fixedstr' and languagetype='en');
delimiter;
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','SELECTCOLOR','选择颜色','jspop' from dual
where not exists(select 1 from ld_desk where labelbol='SELECTCOLOR' and Labeltype='jspop' and languagetype='zh');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','SELECTCOLOR','Select Color','jspop' from dual
where not exists(select 1 from ld_desk where labelbol='SELECTCOLOR' and Labeltype='jspop' and languagetype='en');
delimiter;
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','RULENAMECANOTEMPTY','规则名称不能为空！','jspop' from dual
where not exists(select 1 from ld_desk where labelbol='RULENAMECANOTEMPTY' and Labeltype='jspop' and languagetype='zh');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','RULENAMECANOTEMPTY','The rule name can not be empty!','jspop' from dual
where not exists(select 1 from ld_desk where labelbol='RULENAMECANOTEMPTY' and Labeltype='jspop' and languagetype='en');
delimiter;
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','RULECONDITIONSCANOTEMPTY','规则条件不能为空！','jspop' from dual
where not exists(select 1 from ld_desk where labelbol='RULECONDITIONSCANOTEMPTY' and Labeltype='jspop' and languagetype='zh');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','RULECONDITIONSCANOTEMPTY','The rule conditions can not be empty!','jspop' from dual
where not exists(select 1 from ld_desk where labelbol='RULECONDITIONSCANOTEMPTY' and Labeltype='jspop' and languagetype='en');
delimiter;
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','CustomDisplayContent','自定义显示内容','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='CustomDisplayContent' and Labeltype='fixedstr' and languagetype='zh');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','CustomDisplayContent','Custom Display Content','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='CustomDisplayContent' and Labeltype='fixedstr' and languagetype='en');
delimiter;
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','CONTENTTEMPLATECANNOTBEEMPTY','内容模版不能为空！','jspop' from dual
where not exists(select 1 from ld_desk where labelbol='CONTENTTEMPLATECANNOTBEEMPTY' and Labeltype='jspop' and languagetype='zh');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','CONTENTTEMPLATECANNOTBEEMPTY','Content template can not be empty!','jspop' from dual
where not exists(select 1 from ld_desk where labelbol='CONTENTTEMPLATECANNOTBEEMPTY' and Labeltype='jspop' and languagetype='en');
delimiter;

UPDATE ld_desk SET fieldlabel = '当前图谱已锁定，请先点击右侧按钮解锁' where labelbol = 'UNLOCKHINTSBYCLICK' AND Labeltype = 'fixedstr' AND languagetype = 'zh';
UPDATE ld_desk SET fieldlabel = 'The current map is locked,Please click the button on the right to unlock it first' where labelbol = 'UNLOCKHINTSBYCLICK' AND Labeltype = 'fixedstr' AND languagetype = 'en';
UPDATE ld_desk SET fieldlabel = '当前图谱已锁定，请先点击右侧按钮解锁' where labelbol = 'UNLOCKHINTSBYCLICK' AND Labeltype = 'jspop' AND languagetype = 'zh';
UPDATE ld_desk SET fieldlabel = 'The current map is locked,Please click the button on the right to unlock it first' where labelbol = 'UNLOCKHINTSBYCLICK' AND Labeltype = 'jspop' AND languagetype = 'en';
delimiter;

SET @labelbol = 'EditDragonTigerEmptyTip';
SET @labeltype = 'jspop';
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'zh',@labelbol,'单击左侧龙虎榜以添加',@labeltype FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol=@labelbol and Labeltype=@labeltype);
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'en',@labelbol,'Click the Dragon list on the left to add',@labeltype FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol=@labelbol and Labeltype=@labeltype);
delimiter;

SET @labelbol = 'NUMMULTI';
SET @labeltype = 'jspop';
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'zh',@labelbol,'多个',@labeltype FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol=@labelbol and Labeltype=@labeltype);
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'en',@labelbol,'Multiple',@labeltype FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol=@labelbol and Labeltype=@labeltype);
delimiter;

UPDATE ld_desk SET fieldlabel = 'Please drag the left saleskit to here' WHERE labelbol = 'dragmodule' AND languagetype = 'en';
delimiter;

SET @labelbol = 'DragTargetAnalysis';
SET @labeltype = 'fixedstr';
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'zh',@labelbol,'请从左侧拖拽仪表盘至此处',@labeltype FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol=@labelbol and Labeltype=@labeltype);
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'en',@labelbol,'Please drag the left gauge to here',@labeltype FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol=@labelbol and Labeltype=@labeltype);
delimiter;
-- 2024-02-04


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

UPDATE ld_version SET old_version='V8.6.2.5',current_version='V8.6.2.5',remark='V8.6.2.5-20240207',wx_version='V8.6.2.4';
delimiter;