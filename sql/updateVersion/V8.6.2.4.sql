insert into ld_module_setting_byuser(modulename,userid,label,content) values('notbymodule',1,'Modifyskinset','yes');

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','ISSHOWUNALLOCATEDHIGHSEAS','是否显示"公海未分配"页签','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='ISSHOWUNALLOCATEDHIGHSEAS' and Labeltype='fixedstr' and languagetype='zh');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','ISSHOWUNALLOCATEDHIGHSEAS','Is the "Unallocated High Seas" tab displayed','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='ISSHOWUNALLOCATEDHIGHSEAS' and Labeltype='fixedstr' and languagetype='en');
delimiter;

SET @labelbol = 'ReportName';
SET @labeltype = 'jspop';
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'zh',@labelbol,'报表名称',@labeltype FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol=@labelbol and Labeltype=@labeltype);
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'en',@labelbol,'Report Name',@labeltype FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol=@labelbol and Labeltype=@labeltype);
delimiter;
-- 2024-01-25

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

UPDATE ld_version SET old_version='V8.6.2.4',current_version='V8.6.2.4',remark='V8.6.2.4-20240125',wx_version='V8.6.2.4';
delimiter;