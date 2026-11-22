UPDATE ld_users SET crm_user_type='crm' WHERE crm_user_type IS NULL;
UPDATE ld_groups SET group_type = 'crm' WHERE group_type IS NULL;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','Dimensionfield','维度字段','jspop' from dual
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='Dimensionfield' and labeltype='jspop');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','Dimensionfield',"Dimension field",'jspop' from dual
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='Dimensionfield' and labeltype='jspop');
delimiter;
SET @labelbol = 'EXPORTINGDATA';set @labeltype = 'jspop';
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'zh',@labelbol,'正在导出数据，请不要关闭或刷新浏览器',@labeltype FROM DUAL 
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol=@labelbol and labeltype=@labeltype);
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'en',@labelbol,'Exporting data, please do not close or refresh the browser',@labeltype FROM DUAL 
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol=@labelbol and labeltype=@labeltype);
delimiter;
SET @labelbol = 'EXPORTINGDATA';set @labeltype = 'fixedstr';
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'zh',@labelbol,'正在导出数据，请不要关闭或刷新浏览器',@labeltype FROM DUAL 
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol=@labelbol and labeltype=@labeltype);
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'en',@labelbol,'Exporting data, please do not close or refresh the browser',@labeltype FROM DUAL 
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol=@labelbol and labeltype=@labeltype);
delimiter;

DROP PROCEDURE IF EXISTS addstuff_carousel;
delimiter ||
CREATE PROCEDURE addstuff_carousel()
BEGIN
    IF NOT EXISTS(SELECT 1 FROM ld_stuff WHERE stufftitle='Carousel') THEN
        SET @stufftitle = 'Carousel';
        SET @stuffid = '117';
        INSERT INTO ld_stuff(stuffid,stufftitle,stufftype,relatedmodule,datarangmodule)
        SELECT @stuffid,@stufftitle,'Carousel','','' FROM DUAL
        WHERE NOT EXISTS (SELECT 1 FROM ld_stuff WHERE stuffid=@stuffid AND stufftitle=@stufftitle AND stufftype='Carousel');

        SET @labelbol = 'Carousel';
        INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
        SELECT 'zh',@labelbol,'轮播图','fixedstr' FROM DUAL
        WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol=@labelbol AND Labeltype='fixedstr');
        INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
        SELECT 'en',@labelbol,'Carousel','fixedstr' FROM DUAL
        WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol=@labelbol AND Labeltype='fixedstr');

        SET @labelbol = 'SamplePicture';
        SET @labeltype = 'fixedstr';
        INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
        SELECT 'zh',@labelbol,'示例图片',@labeltype FROM DUAL
        WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol=@labelbol AND Labeltype=@labeltype);
        INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
        SELECT 'en',@labelbol,'Sample Picture',@labeltype FROM DUAL
        WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol=@labelbol AND Labeltype=@labeltype);

        SET @labelbol = 'CarouselSet';
        SET @labeltype = 'jspop';
        INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
        SELECT 'zh',@labelbol,'轮播图设置',@labeltype FROM DUAL
        WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol=@labelbol AND Labeltype=@labeltype);
        INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
        SELECT 'en',@labelbol,'Carousel Settings',@labeltype FROM DUAL
        WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol=@labelbol AND Labeltype=@labeltype);

        SET @labelbol = 'CarouselTimer';
        SET @labeltype = 'jspop';
        INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
        SELECT 'zh',@labelbol,'播放间隔时间',@labeltype FROM DUAL
        WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol=@labelbol AND Labeltype=@labeltype);
        INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
        SELECT 'en',@labelbol,'Carousel interval',@labeltype FROM DUAL
        WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol=@labelbol AND Labeltype=@labeltype);

        SET @labelbol = 'Second';
        SET @labeltype = 'jspop';
        INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
        SELECT 'zh',@labelbol,'秒',@labeltype FROM DUAL
        WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol=@labelbol AND Labeltype=@labeltype);
        INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
        SELECT 'en',@labelbol,'Second',@labeltype FROM DUAL
        WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol=@labelbol AND Labeltype=@labeltype);

        SET @labelbol = 'NewCarousel';
        SET @labeltype = 'jspop';
        INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
        SELECT 'zh',@labelbol,'新增轮播图',@labeltype FROM DUAL
        WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol=@labelbol AND Labeltype=@labeltype);
        INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
        SELECT 'en',@labelbol,'New Carousel',@labeltype FROM DUAL
        WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol=@labelbol AND Labeltype=@labeltype);

        SET @labelbol = 'CarouselTitle';
        SET @labeltype = 'jspop';
        INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
        SELECT 'zh',@labelbol,'轮播图标题',@labeltype FROM DUAL
        WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol=@labelbol AND Labeltype=@labeltype);
        INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
        SELECT 'en',@labelbol,'Carousel Title',@labeltype FROM DUAL
        WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol=@labelbol AND Labeltype=@labeltype);

        SET @labelbol = 'CarouselLink';
        SET @labeltype = 'jspop';
        INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
        SELECT 'zh',@labelbol,'轮播图超链接',@labeltype FROM DUAL
        WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol=@labelbol AND Labeltype=@labeltype);
        INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
        SELECT 'en',@labelbol,'Carousel Link',@labeltype FROM DUAL
        WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol=@labelbol AND Labeltype=@labeltype);

        SET @labelbol = 'AddCarousel';
        SET @labeltype = 'jspop';
        INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
        SELECT 'zh',@labelbol,'+ 新增轮播图',@labeltype FROM DUAL
        WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol=@labelbol AND Labeltype=@labeltype);
        INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
        SELECT 'en',@labelbol,'+ Add Carousel',@labeltype FROM DUAL
        WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol=@labelbol AND Labeltype=@labeltype);
    END IF;
END ||
delimiter;

CALL addstuff_carousel();
delimiter;

call AddColumn('ld_account_normal','active','char','10',NULL);
call AddColumn('ld_account_normal','beforereminddays','varchar','11',NULL);
call AddColumn('ld_account_normal','transfer_users','int','11',NULL);
call AddColumn('ld_account_normal','objtainaccountcontroldays','varchar','10',NULL);
call AddColumn('ld_account_normal','programme_name','text','',NULL);
call AddColumn('ld_account_normal','sequence','int','4',NULL);

UPDATE ld_account_normal set active = 'yes' where IFNULL(active,'') = '';
UPDATE ld_account_normal set programme_name = CONCAT('普通回收方案',id) where IFNULL(programme_name,'') = '';
UPDATE ld_account_normal LEFT JOIN ld_account_public_pool on ld_account_normal.pool_id = ld_account_public_pool.id
set ld_account_normal.beforereminddays = ld_account_public_pool.beforereminddays where IFNULL(ld_account_public_pool.beforereminddays,0) >0;

UPDATE ld_account_normal LEFT JOIN ld_account_public_pool on ld_account_normal.pool_id = ld_account_public_pool.id
set ld_account_normal.transfer_users = ld_account_public_pool.transfer_users where IFNULL(ld_account_public_pool.transfer_users,0) >0;

UPDATE ld_account_normal LEFT JOIN ld_account_public_pool on ld_account_normal.pool_id = ld_account_public_pool.id
set ld_account_normal.objtainaccountcontroldays = ld_account_public_pool.objtainaccountcontroldays where IFNULL(ld_account_normal.objtainaccountcontroldays,0) >0;
delimiter;

CREATE TABLE if not EXISTS `ld_leads_normal` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
	`programme_name` text,
  `description` text,
	`recycleselect` text,
  `pool_id` int(11),
	`advfilter` text,
	`advfilter_grouping` text,
	`active` char(10),
	`beforereminddays` varchar(10),
	`transfer_users` int(11),
	`objtainaccountcontroldays` varchar(10),
	`sequence` int(11),
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=1; 
delimiter;

SELECT CONCAT('[',GROUP_CONCAT(CONCAT('{"groupid":"',groupid,'","columnname":"',columnname,'","comparator":"',comparator,'","value":"',
`value`,'","columncondition":"',`column_condition`,'"}')),']')  into @tmp_advft
from ld_leads_set_advfilter where pool_id = -1 GROUP BY pool_id;

SELECT CONCAT('[null,',GROUP_CONCAT(CONCAT('{','"groupcondition":"',group_condition,'"}')),']')  into @tmp_advft_grouping
from ld_leads_set_advfilter_grouping where pool_id = -1 GROUP BY pool_id;

INSERT INTO ld_leads_normal(programme_name,description,recycleselect,pool_id,advfilter,advfilter_grouping,active,beforereminddays,transfer_users,objtainaccountcontroldays,sequence)
SELECT '普通回收方案','',ld_leads_public.recycleselect,ld_leads_public.account_rule_pool_id,@tmp_advft,@tmp_advft_grouping,ld_leads_public.show_account_rule,
ld_leads_public_pool.beforereminddays,ld_leads_public_pool.transfer_users,ld_leads_public_pool.objtainaccountcontroldays,1
from ld_leads_public LEFT JOIN ld_leads_public_pool on ld_leads_public.account_rule_pool_id = ld_leads_public_pool.id
where NOT EXISTS(SELECT 1 from ld_leads_normal limit 1);
delimiter;

CREATE TABLE if not EXISTS `ld_module_recovery_programme` (
  `programmeid` int(11) NOT NULL AUTO_INCREMENT,
  `programme_name` text,
	`description` text,
	`modulename` varchar(100),
	`recycleselect` text,
	`from_pool_id` int(11),
  `pool_id` int(11),
	`active` char(10),
	`beforereminddays` varchar(10),
	`transfer_users` int(11),
	`sequence` int(11),
	`objtainaccountcontroldays` varchar(10),
  PRIMARY KEY (`programmeid`)
) ENGINE=InnoDB AUTO_INCREMENT=1; 
delimiter;

call AddColumn('ld_account_set_advfilter','programmeid','int','11',NULL);
call AddColumn('ld_account_set_advfilter_grouping','programmeid','int','11',NULL);
call AddColumn('ld_leads_set_advfilter','programmeid','int','11',NULL);
call AddColumn('ld_leads_set_advfilter_grouping','programmeid','int','11',NULL);
call AddColumn('ld_account_set_rule','programmeid','int','11',NULL);
call AddColumn('ld_leads_set_rule','programmeid','int','11',NULL);
delimiter;

INSERT into ld_module_recovery_programme(description,programme_name,modulename,recycleselect,from_pool_id,pool_id,active,beforereminddays,transfer_users,objtainaccountcontroldays)
SELECT '','公海回收方案','Accounts',recycleselect,id,id,'yes',beforereminddays,transfer_users,objtainaccountcontroldays from ld_account_public_pool
where not EXISTS(SELECT 1 from ld_module_recovery_programme where modulename = 'Accounts' limit 1) ;

UPDATE ld_account_set_advfilter INNER JOIN ld_module_recovery_programme on ld_module_recovery_programme.from_pool_id = ld_account_set_advfilter.pool_id
set ld_account_set_advfilter.programmeid = ld_module_recovery_programme.programmeid 
where ld_module_recovery_programme.modulename = 'Accounts' and ld_account_set_advfilter.programmeid = 0;

UPDATE ld_account_set_advfilter_grouping INNER JOIN ld_module_recovery_programme on ld_module_recovery_programme.from_pool_id = ld_account_set_advfilter_grouping.pool_id
set ld_account_set_advfilter_grouping.programmeid = ld_module_recovery_programme.programmeid 
where ld_module_recovery_programme.modulename = 'Accounts' and ld_account_set_advfilter_grouping.programmeid = 0;

UPDATE ld_account_set_rule INNER JOIN ld_module_recovery_programme on ld_module_recovery_programme.from_pool_id = ld_account_set_rule.pool_id
set ld_account_set_rule.programmeid = ld_module_recovery_programme.programmeid 
where ld_module_recovery_programme.modulename = 'Accounts' and ld_account_set_rule.programmeid = 0;
delimiter;

INSERT into ld_module_recovery_programme(description,programme_name,modulename,recycleselect,from_pool_id,pool_id,active,beforereminddays,transfer_users,objtainaccountcontroldays)
SELECT '','公海回收方案','Leads',recycleselect,id,id,'yes',beforereminddays,transfer_users,objtainaccountcontroldays from ld_leads_public_pool
where not EXISTS(SELECT 1 from ld_module_recovery_programme where modulename = 'Leads' limit 1) ;

UPDATE ld_leads_set_advfilter INNER JOIN ld_module_recovery_programme on ld_module_recovery_programme.from_pool_id = ld_leads_set_advfilter.pool_id
set ld_leads_set_advfilter.programmeid = ld_module_recovery_programme.programmeid 
where ld_module_recovery_programme.modulename = 'Leads' and ld_leads_set_advfilter.programmeid = 0;

UPDATE ld_leads_set_advfilter_grouping INNER JOIN ld_module_recovery_programme on ld_module_recovery_programme.from_pool_id = ld_leads_set_advfilter_grouping.pool_id
set ld_leads_set_advfilter_grouping.programmeid = ld_module_recovery_programme.programmeid 
where ld_module_recovery_programme.modulename = 'Leads' and ld_leads_set_advfilter_grouping.programmeid = 0;

UPDATE ld_leads_set_rule INNER JOIN ld_module_recovery_programme on ld_module_recovery_programme.from_pool_id = ld_leads_set_rule.pool_id
set ld_leads_set_rule.programmeid = ld_module_recovery_programme.programmeid 
where ld_module_recovery_programme.modulename = 'Leads' and ld_leads_set_rule.type = 'complete' and ld_leads_set_rule.programmeid = 0;

UPDATE ld_leads_set_rule INNER JOIN ld_leads_normal on ld_leads_set_rule.pool_id = ld_leads_normal.pool_id
set ld_leads_set_rule.programmeid = ld_leads_normal.id where ld_leads_set_rule.type = 'normal' and ld_leads_set_rule.programmeid = 0;
delimiter;

call AddColumn('ld_logpublicaccount','programmeid','int','11',NULL);
call AddColumn('ld_logpublicaccount','old_smownerid','int','11',NULL);
call AddColumn('ld_logpublicleads','programmeid','int','11',NULL);
call AddColumn('ld_logpublicleads','old_smownerid','int','11',NULL);
delimiter;

UPDATE ld_logpublicaccount INNER JOIN ld_module_recovery_programme on ld_module_recovery_programme.from_pool_id = ld_logpublicaccount.pool_id
set ld_logpublicaccount.programmeid = ld_module_recovery_programme.programmeid 
where ld_module_recovery_programme.modulename = 'Accounts' and ld_logpublicaccount.operation = 'LOGPUBLICALLOCATE' and ld_logpublicaccount.programmeid = 0;

UPDATE ld_logpublicaccount INNER JOIN ld_account_normal on ld_account_normal.pool_id = ld_logpublicaccount.pool_id
set ld_logpublicaccount.programmeid = ld_account_normal.id 
where ld_logpublicaccount.operation = 'LOGPUBLICNORMAL' and ld_logpublicaccount.programmeid = 0;
delimiter;

UPDATE ld_logpublicleads INNER JOIN ld_module_recovery_programme on ld_module_recovery_programme.from_pool_id = ld_logpublicleads.pool_id
set ld_logpublicleads.programmeid = ld_module_recovery_programme.programmeid 
where ld_module_recovery_programme.modulename = 'Leads' and ld_logpublicleads.operation = 'LOGPUBLICALLOCATE' and ld_logpublicleads.programmeid = 0;

UPDATE ld_logpublicleads INNER JOIN ld_leads_normal on ld_leads_normal.pool_id = ld_logpublicleads.pool_id
set ld_logpublicleads.programmeid = ld_leads_normal.id 
where ld_logpublicleads.operation = 'LOGPUBLICNORMAL' and ld_logpublicleads.programmeid = 0;
delimiter;


CREATE TABLE if not EXISTS `ld_module_list_tab` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `listtabname` varchar(50),
	`zhlabel` text,
	`enlabel` text,
	`modulename` varchar(50),
  `fromtype` varchar(50),
	`advfilter` text,
	`advfilter_grouping` text,
	`sequence` int(4),
	`description` text,
	`active` char(10),
	`isdefault` char(50),
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=1; 
delimiter;

set @cur_module = 'Accounts';
set @fromtype = 'normal';

SELECT show_publicaccount_tab,show_commonaccount_tab,set_default_tab into @show_publicaccount_tab,@show_commonaccount_tab,@set_default_tab from ld_account_public;

set @listtabname = 'ALLACCOUNT';
INSERT into ld_module_list_tab(listtabname,zhlabel,enlabel,modulename,fromtype,sequence,description,isdefault,active)
SELECT @listtabname,'全部客户','All customers',@cur_module,@fromtype,1,'全部公海客户和普通客户',IF(@set_default_tab = @listtabname,'yes','no'),@show_publicaccount_tab 
from dual where not EXISTS(SELECT 1 from ld_module_list_tab where listtabname = @listtabname and modulename = @cur_module);

set @listtabname = 'DEFAULTALLACCOUNT';
INSERT into ld_module_list_tab(listtabname,zhlabel,enlabel,modulename,fromtype,sequence,description,isdefault,active)
SELECT @listtabname,'全部（含公海）','The default all include unassigned',@cur_module,@fromtype,2,'部分公海客户和普通客户',IF(@set_default_tab = @listtabname,'yes','no'),'yes' 
from dual where not EXISTS(SELECT 1 from ld_module_list_tab where listtabname = @listtabname and modulename = @cur_module);

set @listtabname = 'COMMONACCOUNT';
INSERT into ld_module_list_tab(listtabname,zhlabel,enlabel,modulename,fromtype,sequence,description,isdefault,active)
SELECT @listtabname,'普通客户','Ordinary customers',@cur_module,@fromtype,3,'不在公海的客户',IF(@set_default_tab = @listtabname,'yes','no'),@show_commonaccount_tab 
from dual where not EXISTS(SELECT 1 from ld_module_list_tab where listtabname = @listtabname and modulename = @cur_module);

set @fromtype = 'public';
set @listtabname = 'ALLPUBLICACCOUNT';
INSERT into ld_module_list_tab(listtabname,zhlabel,enlabel,modulename,fromtype,sequence,description,isdefault,active)
SELECT @listtabname,'全部公海客户','All High Seas Customers',@cur_module,@fromtype,4,'全部公海客户',IF(@set_default_tab = @listtabname,'yes','no'),'yes' 
from dual where not EXISTS(SELECT 1 from ld_module_list_tab where listtabname = @listtabname and modulename = @cur_module);

set @listtabname = 'PUBLICALLOCATE';
INSERT into ld_module_list_tab(listtabname,zhlabel,enlabel,modulename,fromtype,sequence,description,isdefault,active)
SELECT @listtabname,'公海已分配','Allocated unassigned accounts',@cur_module,@fromtype,5,'当前公海已有负责人的客户',IF(@set_default_tab = @listtabname,'yes','no'),'yes' 
from dual where not EXISTS(SELECT 1 from ld_module_list_tab where listtabname = @listtabname and modulename = @cur_module);

set @listtabname = 'NOALLOCATE';
INSERT into ld_module_list_tab(listtabname,zhlabel,enlabel,modulename,fromtype,sequence,description,isdefault,active)
SELECT @listtabname,'公海未分配','Unallocated unassigned accounts',@cur_module,@fromtype,6,'当前公海的公共客户',IF(@set_default_tab = @listtabname,'yes','no'),'yes' 
from dual where not EXISTS(SELECT 1 from ld_module_list_tab where listtabname = @listtabname and modulename = @cur_module);
delimiter;


set @cur_module = 'Leads';
set @fromtype = 'normal';

SELECT show_publicaccount_tab,show_commonaccount_tab,set_default_tab into @show_publicaccount_tab,@show_commonaccount_tab,@set_default_tab from ld_leads_public;

set @listtabname = 'ALLACCOUNT';
INSERT into ld_module_list_tab(listtabname,zhlabel,enlabel,modulename,fromtype,sequence,description,isdefault,active)
SELECT @listtabname,'全部线索','All leads',@cur_module,@fromtype,1,'全部公海线索和普通线索',IF(@set_default_tab = @listtabname,'yes','no'),@show_publicaccount_tab 
from dual where not EXISTS(SELECT 1 from ld_module_list_tab where listtabname = @listtabname and modulename = @cur_module);

set @listtabname = 'DEFAULTALLACCOUNT';
INSERT into ld_module_list_tab(listtabname,zhlabel,enlabel,modulename,fromtype,sequence,description,isdefault,active)
SELECT @listtabname,'全部（含公海）','The default all include unassigned',@cur_module,@fromtype,2,'部分公海线索和普通线索',IF(@set_default_tab = @listtabname,'yes','no'),'yes' 
from dual where not EXISTS(SELECT 1 from ld_module_list_tab where listtabname = @listtabname and modulename = @cur_module);

set @listtabname = 'COMMONACCOUNT';
INSERT into ld_module_list_tab(listtabname,zhlabel,enlabel,modulename,fromtype,sequence,description,isdefault,active)
SELECT @listtabname,'普通线索','Ordinary leads',@cur_module,@fromtype,3,'不在公海的线索',IF(@set_default_tab = @listtabname,'yes','no'),@show_commonaccount_tab 
from dual where not EXISTS(SELECT 1 from ld_module_list_tab where listtabname = @listtabname and modulename = @cur_module);

set @fromtype = 'public';
set @listtabname = 'ALLPUBLICACCOUNT';
INSERT into ld_module_list_tab(listtabname,zhlabel,enlabel,modulename,fromtype,sequence,description,isdefault,active)
SELECT @listtabname,'全部公海线索','All High Seas leads',@cur_module,@fromtype,4,'全部公海线索',IF(@set_default_tab = @listtabname,'yes','no'),'yes' 
from dual where not EXISTS(SELECT 1 from ld_module_list_tab where listtabname = @listtabname and modulename = @cur_module);

set @listtabname = 'PUBLICALLOCATE';
INSERT into ld_module_list_tab(listtabname,zhlabel,enlabel,modulename,fromtype,sequence,description,isdefault,active)
SELECT @listtabname,'公海已分配','Allocated unassigned leads',@cur_module,@fromtype,5,'当前公海已有负责人的线索',IF(@set_default_tab = @listtabname,'yes','no'),'yes' 
from dual where not EXISTS(SELECT 1 from ld_module_list_tab where listtabname = @listtabname and modulename = @cur_module);

set @listtabname = 'NOALLOCATE';
INSERT into ld_module_list_tab(listtabname,zhlabel,enlabel,modulename,fromtype,sequence,description,isdefault,active)
SELECT @listtabname,'公海未分配','Unallocated unassigned leads',@cur_module,@fromtype,6,'当前公海的公共线索',IF(@set_default_tab = @listtabname,'yes','no'),'yes' 
from dual where not EXISTS(SELECT 1 from ld_module_list_tab where listtabname = @listtabname and modulename = @cur_module);
delimiter;


call AddColumn('ld_account_public','showpublicmodule','varchar','20',NULL);
call AddColumn('ld_account_public','public_limit_type','varchar','20',NULL);
call AddColumn('ld_account_public','public_limit_count','int','11',NULL);
call AddColumn('ld_leads_public','showpublicmodule','varchar','20',NULL);
call AddColumn('ld_leads_public','public_limit_type','varchar','20',NULL);
call AddColumn('ld_leads_public','public_limit_count','int','11',NULL);
delimiter;

UPDATE ld_account_public set public_limit_type = 'unlimit' where IFNULL(public_limit_type,'') = '';
UPDATE ld_account_public set public_limit_count = '100' where IFNULL(public_limit_count,'') = '';
UPDATE ld_leads_public set public_limit_type = 'unlimit' where IFNULL(public_limit_type,'') = '';
UPDATE ld_leads_public set public_limit_count = '100' where IFNULL(public_limit_count,'') = '';
delimiter;

drop PROCEDURE  if EXISTS ldcrm_upgrade_publicpool_set;
delimiter ||
create PROCEDURE ldcrm_upgrade_publicpool_set
(
)
BEGIN
	IF DATABASE() LIKE 'yanshi_%' OR DATABASE() LIKE 'demo_%' THEN
		UPDATE ld_account_public set showpublicmodule = 'yes' where IFNULL(showpublicmodule,'') = '';
		UPDATE ld_leads_public set showpublicmodule = 'yes' where IFNULL(showpublicmodule,'') = '';
	ELSE
		UPDATE ld_account_public set showpublicmodule = 'no' where IFNULL(showpublicmodule,'') = '';
		UPDATE ld_leads_public set showpublicmodule = 'no' where IFNULL(showpublicmodule,'') = '';
	END if;
end ||
delimiter;

call ldcrm_upgrade_publicpool_set();
drop PROCEDURE  if EXISTS ldcrm_upgrade_publicpool_set;
delimiter;


call AddColumn('ld_account_public_pool','releasetype','varchar','20',NULL);
call AddColumn('ld_account_public_pool','active','varchar','20',NULL);
call AddColumn('ld_leads_public_pool','releasetype','varchar','20',NULL);
call AddColumn('ld_leads_public_pool','active','varchar','20',NULL);
UPDATE ld_account_public_pool set releasetype = 'unlimit' where IFNULL(releasetype,'') = '';
UPDATE ld_leads_public_pool set releasetype = 'unlimit' where IFNULL(releasetype,'') = '';
UPDATE ld_account_public_pool set active = 'yes' where IFNULL(active,'') = '';
UPDATE ld_leads_public_pool set active = 'yes' where IFNULL(active,'') = '';
delimiter;


CREATE TABLE if not EXISTS `ld_publicpool_opreation_permission` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
	`tabid` int(11),
	`userid` int(19),
  `pool_id` int(11),
	`actionid` int(11),
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=1; 
delimiter;


select max(actionid) into @max_actionid from ld_actionmapping;
insert into ld_actionmapping(actionid,actionname,securitycheck,actionlabel)
select  @max_actionid+1,'turnhighseas',0,'TURNHIGHSEAS' from dual where not exists(select 1 from ld_actionmapping where actionname='turnhighseas');

select max(actionid) into @max_actionid from ld_actionmapping;
insert into ld_actionmapping(actionid,actionname,securitycheck,actionlabel)
select  @max_actionid+1,'delay',0,'ACCOUNTDELAY' from dual where not exists(select 1 from ld_actionmapping where actionname='delay');

select max(actionid) into @max_actionid from ld_actionmapping;
insert into ld_actionmapping(actionid,actionname,securitycheck,actionlabel)
select  @max_actionid+1,'release',0,'RELEASE' from dual where not exists(select 1 from ld_actionmapping where actionname='release');
delimiter;

SET @labelbol = 'TRANSFERCUSTOMER';set @labeltype = 'fixedstr';
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'zh',@labelbol,'变更为普通客户',@labeltype FROM DUAL 
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol=@labelbol and labeltype=@labeltype);
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'en',@labelbol,'Change to regular customer',@labeltype FROM DUAL 
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol=@labelbol and labeltype=@labeltype);

select max(actionid) into @max_actionid from ld_actionmapping;
insert into ld_actionmapping(actionid,actionname,securitycheck,actionlabel)
select  @max_actionid+1,'transfercustomer',0,'TRANSFERCUSTOMER' from dual where not exists(select 1 from ld_actionmapping where actionname='transfercustomer');
delimiter;

SET @labelbol = 'DISPLAYEUNALLOCATED';set @labeltype = 'fixedstr';
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'zh',@labelbol,'显示公海未分配页签',@labeltype FROM DUAL 
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol=@labelbol and labeltype=@labeltype);
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'en',@labelbol,'displaye the Unallocated High Seas tab',@labeltype FROM DUAL 
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol=@labelbol and labeltype=@labeltype);

select max(actionid) into @max_actionid from ld_actionmapping;
insert into ld_actionmapping(actionid,actionname,securitycheck,actionlabel)
select  @max_actionid+1,'displayeunallocated',0,'DISPLAYEUNALLOCATED' from dual where not exists(select 1 from ld_actionmapping where actionname='displayeunallocated');
delimiter;


drop PROCEDURE if EXISTS ldcrm_publicaccount_add_permission_admin;
delimiter ||
create PROCEDURE ldcrm_publicaccount_add_permission_admin
(
)
BEGIN
	declare var_userid int(19);
	declare var_poolid int(19);
	declare done  int  default 0;
	
	declare cur1 CURSOR FOR SELECT ld_users.id as tmp_userid,ld_account_public_pool.id as tmp_poolid from ld_users 
		INNER JOIN ld_account_public_pool on FIND_IN_SET(ld_users.id,ld_account_public_pool.administrators)
		where ld_users.`status` = 'Active' ORDER BY tmp_poolid,tmp_userid;
	declare continue handler for not found SET done =1;	
	
	set @tabid = (SELECT tabid from ld_tab where `name` = 'Accounts');
	open cur1;
	Fetch cur1 into var_userid,var_poolid;
	loop1: while  done<>1 DO
		IF not EXISTS(SELECT 1 from ld_publicpool_opreation_permission where userid = var_userid and pool_id = var_poolid and tabid = @tabid) THEN
			INSERT into ld_publicpool_opreation_permission(userid,pool_id,actionid,tabid)
			SELECT var_userid,var_poolid,actionid,@tabid from ld_actionmapping where actionname in ('turnhighseas','transfercustomer','Allocate','delay','release','displayeunallocated');
		end if;
		Fetch cur1 into var_userid,var_poolid;
	end while loop1;
	close cur1;
end ||
delimiter;

call ldcrm_publicaccount_add_permission_admin();
drop PROCEDURE if EXISTS ldcrm_publicaccount_add_permission_admin;
delimiter;


drop PROCEDURE if EXISTS ldcrm_publicaccount_add_permission_allow;
delimiter ||
create PROCEDURE ldcrm_publicaccount_add_permission_allow
(
)
BEGIN
	declare var_userid int(19);
	declare var_poolid int(19);
	declare done  int  default 0;
	
	declare cur1 CURSOR FOR SELECT ld_users.id as tmp_userid,ld_account_public_pool.id as tmp_poolid from ld_users 
		INNER JOIN ld_account_public_pool on FIND_IN_SET(ld_users.id,ld_account_public_pool.allow_users)
		where ld_users.`status` = 'Active' ORDER BY tmp_poolid,tmp_userid;
	declare continue handler for not found SET done =1;	
	
	set @tabid = (SELECT tabid from ld_tab where `name` = 'Accounts');
	open cur1;
	Fetch cur1 into var_userid,var_poolid;
	loop1: while  done<>1 DO
		IF not EXISTS(SELECT 1 from ld_publicpool_opreation_permission where userid = var_userid and pool_id = var_poolid and tabid = @tabid) THEN
			INSERT into ld_publicpool_opreation_permission(userid,pool_id,actionid,tabid)
			SELECT var_userid,var_poolid,actionid,@tabid from ld_actionmapping where actionname in ('Allocate');
		end if;
		Fetch cur1 into var_userid,var_poolid;
	end while loop1;
	close cur1;
end ||
delimiter;

call ldcrm_publicaccount_add_permission_allow();
drop PROCEDURE if EXISTS ldcrm_publicaccount_add_permission_allow;
delimiter;


drop PROCEDURE if EXISTS ldcrm_publiclead_add_permission_admin;
delimiter ||
create PROCEDURE ldcrm_publiclead_add_permission_admin
(
)
BEGIN
	declare var_userid int(19);
	declare var_poolid int(19);
	declare done  int  default 0;
	
	declare cur1 CURSOR FOR SELECT ld_users.id as tmp_userid,ld_leads_public_pool.id as tmp_poolid from ld_users 
		INNER JOIN ld_leads_public_pool on FIND_IN_SET(ld_users.id,ld_leads_public_pool.administrators)
		where ld_users.`status` = 'Active' ORDER BY tmp_poolid,tmp_userid;
	declare continue handler for not found SET done =1;	
	
	set @tabid = (SELECT tabid from ld_tab where `name` = 'Leads');
	open cur1;
	Fetch cur1 into var_userid,var_poolid;
	loop1: while  done<>1 DO
		IF not EXISTS(SELECT 1 from ld_publicpool_opreation_permission where userid = var_userid and pool_id = var_poolid and tabid = @tabid) THEN
			
			INSERT into ld_publicpool_opreation_permission(userid,pool_id,actionid,tabid)
			SELECT var_userid,var_poolid,actionid,@tabid from ld_actionmapping where actionname in ('turnhighseas','transfercustomer','Allocate','delay','release','displayeunallocated');
		end if;
		Fetch cur1 into var_userid,var_poolid;
	end while loop1;
	close cur1;
end ||
delimiter;

call ldcrm_publiclead_add_permission_admin();
drop PROCEDURE if EXISTS ldcrm_publiclead_add_permission_admin;
delimiter;


drop PROCEDURE if EXISTS ldcrm_publiclead_add_permission_allow;
delimiter ||
create PROCEDURE ldcrm_publiclead_add_permission_allow
(
)
BEGIN
	declare var_userid int(19);
	declare var_poolid int(19);
	declare done  int  default 0;
	
	declare cur1 CURSOR FOR SELECT ld_users.id as tmp_userid,ld_leads_public_pool.id as tmp_poolid from ld_users 
		INNER JOIN ld_leads_public_pool on FIND_IN_SET(ld_users.id,ld_leads_public_pool.allow_users)
		where ld_users.`status` = 'Active' ORDER BY tmp_poolid,tmp_userid;
	declare continue handler for not found SET done =1;	
	
	set @tabid = (SELECT tabid from ld_tab where `name` = 'Leads');
	open cur1;
	Fetch cur1 into var_userid,var_poolid;
	loop1: while  done<>1 DO
		IF not EXISTS(SELECT 1 from ld_publicpool_opreation_permission where userid = var_userid and pool_id = var_poolid and tabid = @tabid) THEN
			INSERT into ld_publicpool_opreation_permission(userid,pool_id,actionid,tabid)
			SELECT var_userid,var_poolid,actionid,@tabid from ld_actionmapping where actionname in ('Allocate');
		end if;
		Fetch cur1 into var_userid,var_poolid;
	end while loop1;
	close cur1;
end ||
delimiter;

call ldcrm_publiclead_add_permission_allow();
drop PROCEDURE if EXISTS ldcrm_publiclead_add_permission_allow;
delimiter;

UPDATE ld_account_public_pool INNER JOIN 
(SELECT GROUP_CONCAT(ld_users.id) as new_id,a.id from ld_account_public_pool a
INNER JOIN ld_users on (FIND_IN_SET(ld_users.id,a.administrators)
or FIND_IN_SET(ld_users.id,a.administrators)) GROUP BY a.id) tmpdata on tmpdata.id = ld_account_public_pool.id
set ld_account_public_pool.administrators = tmpdata.new_id;

UPDATE ld_leads_public_pool INNER JOIN 
(SELECT GROUP_CONCAT(ld_users.id) as new_id,a.id from ld_leads_public_pool a
INNER JOIN ld_users on (FIND_IN_SET(ld_users.id,a.administrators)
or FIND_IN_SET(ld_users.id,a.administrators)) GROUP BY a.id) 
tmpdata on tmpdata.id = ld_leads_public_pool.id
set ld_leads_public_pool.administrators = tmpdata.new_id;
delimiter;

set @modulename = 'Accounts';
SELECT MAX(cvid) INTO @maxcvid FROM ld_customview;
INSERT INTO ld_customview (cvid,viewname,setdefault,setmetrics,entitytype,`status`,userid,sequence,pagewidthpercent,customcategory,description,pool_id,groupid) 
SELECT (@maxcvid:=@maxcvid+1),viewname,'no',setmetrics,entitytype,`status`,userid,sequence,pagewidthpercent,'ALLPUBLICACCOUNT','',pool_id,groupid
FROM ld_customview where entitytype = @modulename and customcategory = 'PUBLICALLOCATE' and viewname = 'All' 
AND NOT EXISTS (SELECT 1 FROM ld_customview WHERE entitytype =@modulename AND viewname = 'All' and customcategory = 'ALLPUBLICACCOUNT');
update ld_customview_seq set id = (select max(cvid) from ld_customview);
delimiter;

drop PROCEDURE if EXISTS ldcrm_add_accounts_newpublic_customview;
delimiter ||
create PROCEDURE ldcrm_add_accounts_newpublic_customview
(

)
BEGIN
	declare var_poolid int(19);
	declare done  int  default 0;
	
	declare cur1 CURSOR FOR SELECT id from ld_account_public_pool;
	declare continue handler for not found SET done =1;	
	
	set @modulename = 'Accounts';
	open cur1;
	Fetch cur1 into var_poolid;
	loop1: while  done<>1 DO
		set @new_cvid = (SELECT cvid from ld_customview where pool_id = var_poolid and customcategory = 'ALLPUBLICACCOUNT' AND viewname = 'All' and entitytype = @modulename limit 1);
		set @copy_cvid = (SELECT cvid from ld_customview where pool_id = var_poolid and customcategory = 'PUBLICALLOCATE' AND viewname = 'All' and entitytype = @modulename limit 1);
		INSERT into ld_cvcolumnlist(cvid,columnindex,columnname) 
			SELECT @new_cvid,columnindex,columnname from ld_cvcolumnlist where cvid = @copy_cvid
			and NOT EXISTS(SELECT 1 from ld_cvcolumnlist where cvid = @new_cvid);
		insert into ld_cvcolumnlistsort(cvid,columnname,sorttype)
			select @new_cvid,columnname,sorttype from ld_cvcolumnlistsort 
			where cvid = @copy_cvid and NOT EXISTS(SELECT 1 from ld_cvcolumnlistsort where cvid = @new_cvid);
		
		Fetch cur1 into var_poolid;
	end while loop1;
	close cur1;
end ||
delimiter;

call ldcrm_add_accounts_newpublic_customview();
drop PROCEDURE if EXISTS ldcrm_add_accounts_newpublic_customview;
delimiter;

set @modulename = 'Leads';
SELECT MAX(cvid) INTO @maxcvid FROM ld_customview;
INSERT INTO ld_customview (cvid,viewname,setdefault,setmetrics,entitytype,`status`,userid,sequence,pagewidthpercent,customcategory,description,pool_id,groupid) 
SELECT (@maxcvid:=@maxcvid+1),viewname,'no',setmetrics,entitytype,`status`,userid,sequence,pagewidthpercent,'ALLPUBLICACCOUNT','',pool_id,groupid
FROM ld_customview where entitytype = @modulename and customcategory = 'PUBLICALLOCATE' and viewname = 'All' 
AND NOT EXISTS (SELECT 1 FROM ld_customview WHERE entitytype =@modulename AND viewname = 'All' and customcategory = 'ALLPUBLICACCOUNT');
update ld_customview_seq set id = (select max(cvid) from ld_customview);
delimiter;

drop PROCEDURE if EXISTS ldcrm_add_lead_newpublic_customview;
delimiter ||
create PROCEDURE ldcrm_add_lead_newpublic_customview
(

)
BEGIN
	declare var_poolid int(19);
	declare done  int  default 0;
	
	declare cur1 CURSOR FOR SELECT id from ld_leads_public_pool;
	declare continue handler for not found SET done =1;	
	
	set @modulename = 'Leads';
	open cur1;
	Fetch cur1 into var_poolid;
	loop1: while  done<>1 DO
		set @new_cvid = (SELECT cvid from ld_customview where pool_id = var_poolid and customcategory = 'ALLPUBLICACCOUNT' AND viewname = 'All' and entitytype = @modulename limit 1);
		set @copy_cvid = (SELECT cvid from ld_customview where pool_id = var_poolid and customcategory = 'PUBLICALLOCATE' AND viewname = 'All' and entitytype = @modulename limit 1);
		INSERT into ld_cvcolumnlist(cvid,columnindex,columnname) 
			SELECT @new_cvid,columnindex,columnname from ld_cvcolumnlist where cvid = @copy_cvid
			and NOT EXISTS(SELECT 1 from ld_cvcolumnlist where cvid = @new_cvid);
		insert into ld_cvcolumnlistsort(cvid,columnname,sorttype)
			select @new_cvid,columnname,sorttype from ld_cvcolumnlistsort 
			where cvid = @copy_cvid and NOT EXISTS(SELECT 1 from ld_cvcolumnlistsort where cvid = @new_cvid);
		
		Fetch cur1 into var_poolid;
	end while loop1;
	close cur1;
end ||
delimiter;

call ldcrm_add_lead_newpublic_customview();
drop PROCEDURE if EXISTS ldcrm_add_lead_newpublic_customview;
delimiter;

SET @tabid=(SELECT tabid from ld_tab where `name` = 'Accounts');
SET @relateid=(SELECT block from ld_field where tabid = @tabid and columnname = 'protectdate');
SET @maxseq=IFNULL((SELECT MAX(sequence) FROM ld_field WHERE tabid=@tabid AND block=@relateid),0);
SET @trantable='ld_field';
SET @tablename=(SELECT tablename from ld_field where tabid = @tabid and columnname = 'protectdate');
SET @maxfieldid=(SELECT MAX(fieldid) FROM ld_field);

SET @presence = (SELECT presence from ld_field where tabid = @tabid and columnname = 'protectdate');
SET @trantable='ld_field';
SET @columnname='protectstartdate'; 
SET @fieldname='protectstartdate'; 
SET @zh='保护开始日期'; 
SET @en='Protection start date'; 
SET @uitype=5;
SET @typeofdata='D~O';
SET @quickcreate=1;
SET @displaytype=2;
SET @bigtype='date';
SET @datarang='all';
SET @maxrowsshow=5;
SET @savedatabase = 'yes';
SET @allowedit = 'no';

INSERT INTO ld_field(tabid,fieldid,columnname,tablename,generatedtype,uitype,fieldname,fieldlabel,readonly,presence,defaultvalue,maximumlength,sequence,block,displaytype,typeofdata,quickcreate,quickcreatesequence,info_type,masseditable,helpinfo,fieldonly,approve_demand,is_checkimportfield,bigtype,datarang,maxrowsshow,savedatabase,allowedit)
SELECT @tabid,@maxfieldid+1,@columnname,@tablename,2,@uitype,@fieldname,@zh,0,IFNULL(@presence,1),NULL,100,@maxseq+1,@relateid,@displaytype,@typeofdata,@quickcreate,NULL,NULL,1,NULL,0,2,0,@bigtype,@datarang,@maxrowsshow,@savedatabase,@allowedit from dual 
WHERE NOT EXISTS (SELECT 1 FROM ld_field WHERE tabid=@tabid AND tablename=@tablename AND columnname=@columnname); 
UPDATE ld_field_seq SET id=(SELECT max(fieldid) FROM ld_field);

SET @relateid=(SELECT fieldid FROM ld_field WHERE tabid=@tabid AND columnname=@columnname LIMIT 1);
INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
SELECT 'zh',@trantable,@tabid,@relateid,@zh FROM DUAL 
WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE languagetype = 'zh' AND trantable =@trantable AND tabid = @tabid AND relateid=@relateid);
INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
SELECT 'en',@trantable,@tabid,@relateid,@en FROM DUAL 
WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE languagetype = 'en' AND trantable =@trantable AND tabid = @tabid AND relateid=@relateid);

call AddColumn(@tablename,@columnname,'date','',NULL);
SET @disable_triggers = 'aa';
UPDATE ld_account set protectstartdate = IFNULL(IFNULL(allocatedate,distributiondate),createdtime) where IFNULL(protectstartdate,'') = '' and publicaccount <> 1;
SET @disable_triggers = NULL;
delimiter;

SET @tabid=(SELECT tabid from ld_tab where `name` = 'Leads');
SET @relateid=(SELECT block from ld_field where tabid = @tabid and columnname = 'protectdate');
SET @maxseq=IFNULL((SELECT MAX(sequence) FROM ld_field WHERE tabid=@tabid AND block=@relateid),0);
SET @trantable='ld_field';
SET @tablename=(SELECT tablename from ld_field where tabid = @tabid and columnname = 'protectdate');
SET @maxfieldid=(SELECT MAX(fieldid) FROM ld_field);

SET @presence = (SELECT presence from ld_field where tabid = @tabid and columnname = 'protectdate');
SET @trantable='ld_field';
SET @columnname='protectstartdate'; 
SET @fieldname='protectstartdate'; 
SET @zh='保护开始日期'; 
SET @en='Protection start date'; 
SET @uitype=5;
SET @typeofdata='D~O';
SET @quickcreate=1;
SET @displaytype=2;
SET @bigtype='date';
SET @datarang='all';
SET @maxrowsshow=5;
SET @savedatabase = 'yes';
SET @allowedit = 'no';

INSERT INTO ld_field(tabid,fieldid,columnname,tablename,generatedtype,uitype,fieldname,fieldlabel,readonly,presence,defaultvalue,maximumlength,sequence,block,displaytype,typeofdata,quickcreate,quickcreatesequence,info_type,masseditable,helpinfo,fieldonly,approve_demand,is_checkimportfield,bigtype,datarang,maxrowsshow,savedatabase,allowedit)
SELECT @tabid,@maxfieldid+1,@columnname,@tablename,2,@uitype,@fieldname,@zh,0,IFNULL(@presence,1),NULL,100,@maxseq+1,@relateid,@displaytype,@typeofdata,@quickcreate,NULL,NULL,1,NULL,0,2,0,@bigtype,@datarang,@maxrowsshow,@savedatabase,@allowedit from dual 
WHERE NOT EXISTS (SELECT 1 FROM ld_field WHERE tabid=@tabid AND tablename=@tablename AND columnname=@columnname); 
UPDATE ld_field_seq SET id=(SELECT max(fieldid) FROM ld_field);

SET @relateid=(SELECT fieldid FROM ld_field WHERE tabid=@tabid AND columnname=@columnname LIMIT 1);
INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
SELECT 'zh',@trantable,@tabid,@relateid,@zh FROM DUAL 
WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE languagetype = 'zh' AND trantable =@trantable AND tabid = @tabid AND relateid=@relateid);
INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
SELECT 'en',@trantable,@tabid,@relateid,@en FROM DUAL 
WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE languagetype = 'en' AND trantable =@trantable AND tabid = @tabid AND relateid=@relateid);

call AddColumn(@tablename,@columnname,'date','',NULL);
UPDATE ld_leads set protectstartdate = IFNULL(IFNULL(allocatedate,distributiondate),createdtime) where IFNULL(protectstartdate,'') = '' and publicaccount <> 1;
delimiter;

DROP PROCEDURE IF EXISTS `execute_account_publicoperation`;
delimiter ||
CREATE PROCEDURE `execute_account_publicoperation`()
BEGIN
	declare done  int  default 0;
	DECLARE tmp_pool_id varchar(200);
	declare cur1 CURSOR FOR SELECT id  FROM  ld_account_public_pool where deleted = 0;
	declare continue handler  for not   found  SET done =1;
	if  EXISTS (SELECT 1 FROM ld_account_public WHERE STATUS = 'yes')  THEN
		if NOT EXISTS (SELECT 1 FROM ld_sys_event WHERE eventdate>CURDATE() AND type='publicaccount')  THEN
			UPDATE ld_sys_event SET eventdate=NOW() WHERE type='publicaccount';
			call account_singlerecycle_normal();
			OPEN cur1;
				Fetch cur1 into tmp_pool_id;
					loop1: while  done<>1 DO
						call account_singlerecycle_highsea_program(tmp_pool_id);
				Fetch cur1 into tmp_pool_id;
			end while loop1;
			close cur1;
		end if;
	end if;
end ||
delimiter;

DROP PROCEDURE IF EXISTS `account_singlerecycle_highsea_program`;
delimiter ||
CREATE PROCEDURE `account_singlerecycle_highsea_program`(IN tmp_from_pool_id INT(11))
BEGIN
	declare done  int  default 0;
	DECLARE target_pool_id varchar(200);
	DECLARE tmp_grammeid varchar(200);
	declare cur1 CURSOR FOR SELECT programmeid,pool_id from ld_module_recovery_programme where modulename = 'Accounts' and active = 'yes' and from_pool_id = tmp_from_pool_id ORDER BY sequence;
	declare continue handler  for not   found  SET done =1;
	OPEN cur1;
		Fetch cur1 into tmp_grammeid,target_pool_id;
			loop1: while  done<>1 DO
				call account_singlerecycle_highsea_rule(tmp_from_pool_id,target_pool_id,tmp_grammeid);
				call account_singlerecycle_highsea_rule_beforeremind(tmp_from_pool_id,tmp_grammeid);
		Fetch cur1 into tmp_grammeid,target_pool_id;
	end while loop1;
	close cur1;
end ||
delimiter;


DROP PROCEDURE IF EXISTS `account_singlerecycle_highsea_rule`;
delimiter ||
CREATE   PROCEDURE `account_singlerecycle_highsea_rule`(IN tmp_pool_id INT(11),IN target_pool_id INT(11),IN tmp_grammeid INT(11))
    label_a:BEGIN

	DECLARE var_tabname varchar(100);
	DECLARE var_columnname varchar(100);
	DECLARE var_tablename varchar(100);
	DECLARE var_condition varchar(50);
	DECLARE var_smownercolumn varchar(50);
	DECLARE var_days int(11);
	DECLARE var_otherwhere varchar(200);
	declare var_iscycle varchar(100);
	declare done  int  default 0;

	declare cur1 CURSOR FOR
	select tabname,ld_account_set_rule.columnname,ld_field.tablename ,ld_account_set_rule.iscycle, `condition`,ld_account_set_rule.days,ld_account_set_rule.otherwhere from ld_account_set_rule
		inner join ld_tab on ld_tab.name=ld_account_set_rule.tabname and (presence in(0,2) or ld_account_set_rule.tabname='singin')
		INNER JOIN ld_field on ld_field.tabid=ld_tab.tabid and ld_account_set_rule.columnname=ld_field.columnname and (ld_field.presence in(0,2))
		where ld_account_set_rule.type='complete' and ld_account_set_rule.`status`='active' and programmeid = tmp_grammeid;

	declare continue handler  for not found SET done =1;
	set @tmpint=0;
	set @tmpsql='';

	select max(ld_account_set_rule.days) into @maxdays
		from ld_account_set_rule  inner join ld_tab on ld_tab.name=ld_account_set_rule.tabname and (presence in(0,2) or ld_account_set_rule.tabname='singin')
		INNER JOIN ld_field on ld_field.tabid=ld_tab.tabid and ld_account_set_rule.columnname=ld_field.columnname and ld_field.presence in(0,2)
		where ld_account_set_rule.type='complete' and ld_account_set_rule.`status`='active' and programmeid = tmp_grammeid;

	select IF(ld_users.id>0,transfer_users,0) into @allotaccount from 
		ld_module_recovery_programme LEFT join ld_users on ld_users.id=transfer_users
		where modulename = 'Accounts' and ld_module_recovery_programme.programmeid = tmp_grammeid;

	if  ifnull(@allotaccount,0)=0  then
				set @allotaccount=0;
	end if;
	select recycleselect into @recycleselect from ld_module_recovery_programme where programmeid = tmp_grammeid;

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
						set @tmpsqlone =concat("select ld_account.accountid,ld_account.allocatedate from ld_account ");
						set @tmpsqlone=concat(@tmpsqlone," inner join ",var_tablename,' on ',var_tablename,'.accountid=ld_account.accountid ');
						set @tmpsqlone=concat(@tmpsqlone," and  ",var_tablename,'.',var_smownercolumn,'=ld_account.smownerid' );

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
									and ld_account.smownerid=',var_tablename,'.',var_smownercolumn,'  where ',var_tablename,'.deleted=0' );

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

					set @tmpsql=concat(@tmpsql,' and ' ,var_tablename,'.',var_smownercolumn,'=ld_account.smownerid ' );

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

if @tmpint>0 then
		set @len=CHAR_LENGTH(' union all ');
		set @tmpsql=left(@tmpsql,CHAR_LENGTH(@tmpsql)-@len);

	  if var_condition='or'  then
			set @sql=concat(' select accountid from (',@tmpsql, ') as tmpone group by accountid ') ;
			set @TMPSQL_ONE = concat( ' select "系统1","LOGPUBLICALLOCATE",now(), ld_account.accountid,ld_account.pool_id  from ld_account left join ( ',@sql,' ) as lingdangtmp  on  lingdangtmp.accountid=ld_account.accountid ') ;
			set @TMPSQL_LOG_ONE = concat( ' select "系统2","LOGPUBLICALLOCATE",now(), ld_account.accountid,ld_account.pool_id,ld_account.smownerid,"',tmp_grammeid,'" as log_grammeid  from ld_account left join ( ',@sql,' ) as lingdangtmp  on  lingdangtmp.accountid=ld_account.accountid ') ; 
			if @recycleselect<>'' and @recycleselect is not null THEN
				set @TMPSQL_ONE=concat(@TMPSQL_ONE,' left join ',@recycleselect,' on recyclewheretableset.accountid=ld_account.accountid ');
				set @TMPSQL_LOG_ONE=concat(@TMPSQL_LOG_ONE,' left join ',@recycleselect,' on recyclewheretableset.accountid=ld_account.accountid ');
			end if;
		  set @TMPSQL_TWO=concat(' where ld_account.deleted=0 and( ld_account.publicaccount=2 or ld_account.publicaccount=3) and ld_account.pool_id =  ',tmp_pool_id);
			set @TMPSQL_TWO=concat(@TMPSQL_TWO,' and lingdangtmp.accountid is null  and datediff(curdate(),ld_account.allocatedate)>',@maxdays);
			if @recycleselect<>'' and @recycleselect is not null THEN
				set @TMPSQL_TWO=concat(@TMPSQL_TWO, ' and recyclewheretableset.accountid is not null  ');
			end if;
		else
			if @recycleselect is not null and @recycleselect<>'' then
				set @sql=concat(' select tmpone.accountid from  (',@tmpsql, ' ) as tmpone inner join ',@recycleselect,' on tmpone.accountid=recyclewheretableset.accountid  group by tmpone.accountid ') ;
			ELSE
				set @sql=concat(' select accountid from (',@tmpsql, ') as tmpone group by accountid ') ;
			end if;
			set @TMPSQL_ONE=concat( ' select "系统3","LOGPUBLICALLOCATE",now(), ld_account.accountid,ld_account.pool_id  from ld_account inner join ( ',@sql,' ) as lingdangtmp  on  lingdangtmp.accountid=ld_account.accountid ') ;
			set @TMPSQL_LOG_ONE=concat( ' select "系统4","LOGPUBLICALLOCATE",now(), ld_account.accountid,ld_account.pool_id,ld_account.smownerid,"',tmp_grammeid,'" as log_grammeid  from ld_account inner join ( ',@sql,' ) as lingdangtmp  on  lingdangtmp.accountid=ld_account.accountid ') ;
			set @TMPSQL_TWO=concat(' where ld_account.deleted=0 and( ld_account.publicaccount=2 or ld_account.publicaccount=3) and ld_account.pool_id = ',tmp_pool_id);
		end if;
		set @TMPSQL_LOG_TWO = concat(@TMPSQL_LOG_ONE,@TMPSQL_TWO);
		set @TMPSQL_TWO = concat(@TMPSQL_ONE,@TMPSQL_TWO);
		

		set @TMPSQL_THREE=concat('insert into ld_logpublicaccount(username,operation,opdate,accountid,pool_id,old_smownerid,programmeid) ',@TMPSQL_LOG_TWO);

prepare stmt from @TMPSQL_THREE;
execute stmt;
deallocate prepare stmt;

set @tmp_namelink='\'<a style="display: initial;" doubleclick="yes" onclick="ListReferenceLinkClick(ld(this),event)" referencemodule="Accounts" referencerecord="\',ld_account.accountid,\'">\',ld_account.accountname,\'</a>\'';
if var_condition='or'  then
			set @TMPSQL_ONE=concat( 'select "complete" as type, GROUP_CONCAT(',@tmp_namelink,' separator "<br>")as accountnames,count(ld_account.accountid) as totalaccounts,ld_account.smownerid,GROUP_CONCAT(ld_account.accountid separator "##")as accountid from ld_account left join ( ',@sql,' ) as lingdangtmp  on  lingdangtmp.accountid=ld_account.accountid ') ;
			if @recycleselect<>'' and @recycleselect is not null THEN
				set @TMPSQL_ONE=concat(@TMPSQL_ONE,' left join ',@recycleselect,' on recyclewheretableset.accountid=ld_account.accountid ');
end if;
				set @TMPSQL_TWO=concat(@TMPSQL_ONE,' where ld_account.deleted=0 and( ld_account.publicaccount=2 or ld_account.publicaccount=3)  and ld_account.pool_id = ',tmp_pool_id);
				set @TMPSQL_TWO=concat(@TMPSQL_TWO, ' and lingdangtmp.accountid is null  and datediff(curdate(),ld_account.allocatedate)>',@maxdays);
			if @recycleselect<>'' and @recycleselect is not null THEN
				set @TMPSQL_TWO=concat(@TMPSQL_TWO, ' and recyclewheretableset.accountid is not null ');
end if;
			set @TMPSQL_TWO=concat(@TMPSQL_TWO," group by ld_account.smownerid ");
else
			set @TMPSQL_ONE=concat( ' select "complete" as type, GROUP_CONCAT(',@tmp_namelink,' separator "<br>")as accountnames,count(ld_account.accountid)  as totalaccounts,ld_account.smownerid,GROUP_CONCAT(ld_account.accountid separator "##")as accountid from ld_account  inner join ( ',@sql,' ) as lingdangtmp  on  lingdangtmp.accountid=ld_account.accountid ') ;
			set @TMPSQL_TWO=concat(@TMPSQL_ONE,' where ld_account.deleted=0  and( ld_account.publicaccount=2 or ld_account.publicaccount=3) and ld_account.pool_id = ',tmp_pool_id,'   group by ld_account.smownerid    ');
end if;

delete from ld_publicaccount_remindtableview ;


set @tmpthree=concat(" insert into ld_publicaccount_remindtableview(type,names,totalaccounts,smownerid,ids ) ", @TMPSQL_TWO);
prepare stmt from @tmpthree;
execute stmt;
deallocate prepare stmt;

call crm_publicaccount_recoveryreminds();
if @allotaccount>0 then
select  tmp.tablename into @grouptablename  from (select ld_related_field.trigger_fieldid,ld_field.columnname,ld_field.tablename from ld_field
                                                                                                                                          INNER JOIN ld_related_field on ld_related_field.effect_fieldid=ld_field.fieldid where ld_field.uitype=1600  )  as  tmp
                                                     INNER JOIN ld_field on ld_field.fieldid =tmp.trigger_fieldid
where ld_field.tabid=6 and ld_field.columnname='smownerid'
  and presence in(0,2)  GROUP BY ld_field.fieldid limit 1;

select  tmp.columnname into @groupcolumnname  from (select ld_related_field.trigger_fieldid,ld_field.columnname,ld_field.tablename from ld_field INNER JOIN ld_related_field
                                                                                                                                                            on ld_related_field.effect_fieldid=ld_field.fieldid
                                                    where ld_field.uitype=1600  )  as  tmp
                                                       INNER JOIN ld_field on ld_field.fieldid =tmp.trigger_fieldid
where ld_field.tabid=6 and ld_field.columnname='smownerid'
  and presence in(0,2)  GROUP BY ld_field.fieldid limit 1;
end if;
	if var_condition='or'  then

		 set @TMPSQL_ONE=concat( ' update  ld_account left join ( ',@sql,' ) as lingdangtmp  on  lingdangtmp.accountid=ld_account.accountid ');
		if @recycleselect<>'' and @recycleselect is not null THEN
			set @TMPSQL_ONE=concat(@TMPSQL_ONE,' left join ',@recycleselect,' on recyclewheretableset.accountid=ld_account.accountid ');
end if;
		set @TMPSQL_ONE=concat( @TMPSQL_ONE,' set ld_account.publicaccount=1 ,protectdate=null ,allocatedate=null,protectstartdate=null') ;
		 if @allotaccount>0 THEN
				set @TMPSQL_ONE=concat(@TMPSQL_ONE,",smownerid=",@allotaccount);
end if;
		 set @TMPSQL_TWO=concat(@TMPSQL_ONE,' where ld_account.deleted=0 and( ld_account.publicaccount=2 or ld_account.publicaccount=3) and ld_account.pool_id = ',tmp_pool_id);
		 set @TMPSQL_TWO=concat(@TMPSQL_TWO, ' and lingdangtmp.accountid is null and datediff(curdate(),ld_account.allocatedate)>',@maxdays);
			if @recycleselect<>'' and @recycleselect is not null THEN
					set @TMPSQL_TWO=concat(@TMPSQL_TWO, ' and recyclewheretableset.accountid is not null  ');
end if;
ELSE

	  set @TMPSQL_ONE=concat( ' update  ld_account inner join ( ',@sql,' ) as lingdangtmp  on  lingdangtmp.accountid=ld_account.accountid set ld_account.publicaccount=1 ,protectdate=null ,allocatedate=null,protectstartdate=null') ;
    if target_pool_id >0 then
			set @TMPSQL_ONE=concat(@TMPSQL_ONE,",ld_account.pool_id=",target_pool_id);
		end if;
		if @allotaccount>0 THEN
					set @TMPSQL_ONE=concat(@TMPSQL_ONE,",smownerid=",@allotaccount);
		 
						if   ifnull(@groupcolumnname,'')!='' then

select GROUP_CONCAT(groupid) into @groupid from  ld_users2group where userid =@allotaccount;
set @TMPSQL_GroupEditSql=concat( ' update  ',@grouptablename,' inner join ( ',@sql,' ) as lingdangtmp  on  lingdangtmp.accountid=',@grouptablename,'.accountid ') ;
								if @grouptablename!='ld_account' then
									set @TMPSQL_GroupEditSql=concat(@TMPSQL_GroupEditSql,' inner join ld_account on ld_account.accountid=ld_accountscf.accountid ');
									set @TMPSQL_GroupEditSql=concat(@TMPSQL_GroupEditSql, ' set ',@groupcolumnname,'="', @groupid,'"');

								end if ;
								set @TMPSQL_GroupEditSql=concat(@TMPSQL_GroupEditSql,' where ld_account.deleted=0 and( ld_account.publicaccount=2 or ld_account.publicaccount=3)   ');
prepare stmt1 from @TMPSQL_GroupEditSql;
execute stmt1;
deallocate prepare stmt1;
end if;

end if;
  	set @TMPSQL_TWO=concat(@TMPSQL_ONE,' where ld_account.deleted=0 and( ld_account.publicaccount=2 or ld_account.publicaccount=3) and ld_account.pool_id = ',tmp_pool_id);
end if;

prepare stmt from @TMPSQL_TWO;
execute stmt;
deallocate prepare stmt;

end if;
end ||
delimiter;



DROP PROCEDURE IF EXISTS `account_singlerecycle_highsea_rule_beforeremind`;
delimiter ||
CREATE PROCEDURE `account_singlerecycle_highsea_rule_beforeremind`(IN tmp_pool_id INT(11),IN tmp_grammeid INT(11))
    label_a:BEGIN

	DECLARE var_tabname varchar(100);
	DECLARE var_columnname varchar(100);
	DECLARE var_tablename varchar(100);
	DECLARE var_condition varchar(50);
	DECLARE var_smownercolumn varchar(50);
	DECLARE var_days int(11);
	DECLARE var_otherwhere varchar(200);
	declare var_iscycle varchar(100);

	declare done  int  default 0;

	declare cur1 CURSOR FOR select  tabname,ld_account_set_rule.columnname,ld_field.tablename ,ld_account_set_rule.iscycle, 
		`condition`,ld_account_set_rule.days,ld_account_set_rule.otherwhere from ld_account_set_rule  
		inner join ld_tab on ld_tab.name=ld_account_set_rule.tabname and  (presence in(0,2) or ld_account_set_rule.tabname='singin')                                                                                                                                                                                                                    INNER JOIN ld_field on ld_field.tabid=ld_tab.tabid and ld_account_set_rule.columnname=ld_field.columnname
    and ld_field.presence in(0,2) where ld_account_set_rule.type='complete' and ld_account_set_rule.`status`='active' 
		and programmeid = tmp_grammeid;
	declare continue handler  for not   found  SET done =1;
		set @tmpint=0;
		set @tmpsql='';
	select max(ld_account_set_rule.days) into @maxdays
		from ld_account_set_rule  inner join ld_tab on ld_tab.name=ld_account_set_rule.tabname and (presence in(0,2) or ld_account_set_rule.tabname='singin')
		INNER JOIN ld_field on ld_field.tabid=ld_tab.tabid and ld_account_set_rule.columnname=ld_field.columnname
    and ld_field.presence in(0,2) where ld_account_set_rule.type='complete' and ld_account_set_rule.`status`='active' and programmeid = tmp_grammeid;

	select beforereminddays into @var_beforereminddays  from ld_module_recovery_programme where  programmeid = tmp_grammeid;


	if @var_beforereminddays='' or @var_beforereminddays is null or @var_beforereminddays=0 then
			leave label_a ;
	end if;

	select recycleselect into @recycleselect from ld_module_recovery_programme where  programmeid = tmp_grammeid;


if @recycleselect is not null and @recycleselect<>'' then
			set @recycleselect=concat( '( ', @recycleselect,' ) as recyclewheretableset ');
end if;
OPEN cur1;

Fetch cur1 into  var_tabname,var_columnname,var_tablename,var_iscycle,var_condition,var_days,var_otherwhere;
loop1: while  done<>1 DO
		 set @old_days=var_days;
		 set var_days=var_days-@var_beforereminddays;

			if var_tablename='ld_singin' THEN
					set var_smownercolumn='userid';
else
				set	var_smownercolumn='smownerid' ;
end if;
		  if(var_condition='and' ) then

					set @tmpsqlone =concat("select ld_account.accountid,ld_account.allocatedate,'",var_tabname,"' as remindtabname from ld_account ");
					set @tmpsqlone=concat(@tmpsqlone," inner join ",var_tablename,' on ',var_tablename,'.accountid=ld_account.accountid ');
					set @tmpsqlone=concat(@tmpsqlone," and  ",var_tablename,'.',var_smownercolumn,'=ld_account.smownerid' );

					set @tmpsqlone=concat(@tmpsqlone ,"  where  ",var_tablename,".deleted=0");
					 if var_otherwhere is not null and  var_otherwhere<>'' then
							set @tmpsqlone=concat(@tmpsqlone,var_otherwhere);
end if;

					if var_iscycle='yes' then
							set @tmpsqlone=concat( @tmpsqlone,' group by ld_account.accountid ') ;
							set @tmpsqlone=concat(@tmpsqlone,"   having datediff(curdate(), case when ld_account.allocatedate> max( " ,var_tablename,'.',var_columnname," )  then ld_account.allocatedate else max( " ,var_tablename,'.',var_columnname," ) end  ) >=",var_days);
else
							set @tmpsqlone=concat(@tmpsqlone," and ld_account.allocatedate<=",var_tablename,'.',var_columnname);
							set @tmpsqlone=concat( @tmpsqlone,' group by ld_account.accountid ') ;
							set @tmpsqlone=concat(@tmpsqlone,"  having  datediff(min( ",var_tablename,'.',var_columnname,"),ld_account.allocatedate) BETWEEN ",var_days,' and ' ,@old_days);
end if;
					set @tmpsqltwo=concat("select ld_account.accountid,ld_account.allocatedate,'",var_tabname,"' as remindtabname from  ld_account LEFT JOIN(select ld_account.accountid
							from ld_account inner join ",var_tablename,' on ld_account.accountid=',var_tablename,'.accountid and ld_account.smownerid=',var_tablename,'.',var_smownercolumn,'  where ',var_tablename,'.deleted=0' );

					 if var_otherwhere is not null and  var_otherwhere<>'' then
							set @tmpsqltwo=concat(@tmpsqltwo, var_otherwhere);
end if;
					set @tmpsqltwo=concat(@tmpsqltwo,' ) 	as ttt_',var_tablename,'  on ld_account.accountid=ttt_',var_tablename,'.accountid   where ttt_',var_tablename,'.accountid is null  ' );
					set @tmpsqltwo=concat(@tmpsqltwo," having datediff(curdate(),ld_account.allocatedate ) >=",var_days);
					IF var_iscycle = 'yes' then
						set @tmpthree=concat( @tmpsqlone,' union all ',@tmpsqltwo);
ELSE
						set @tmpthree=@tmpsqltwo;
end if;
					set @tmpsql=concat(@tmpsql," select * from ( ",@tmpthree," ) as  tttt_",var_tabname);
					set @tmpsql=concat(@tmpsql,' union all ' );

			elseif (var_condition='or')  then
				set @tmpsql=concat(@tmpsql ,' select ld_account.accountid,ld_account.allocatedate from ld_account inner join '  ,var_tablename,' on ',var_tablename,'.accountid=ld_account.accountid  ');

			  set @tmpsql=concat(@tmpsql,' and ' ,var_tablename,'.',var_smownercolumn,' =ld_account.smownerid ' );
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
end if;
				set @tmpsql=concat(@tmpsql,' union all ' );

end if;
			set @tmpint=@tmpint+1;
Fetch cur1 into  var_tabname,var_columnname,var_tablename,var_iscycle,var_condition,var_days,var_otherwhere;
end while loop1;
close cur1;

if @tmpint>0 then
		set @len=CHAR_LENGTH(' union all ');
		set @tmpsql=left(@tmpsql,CHAR_LENGTH(@tmpsql)-@len);
		if var_condition='or'  then
			set @TMP_TMPTable=" ( select  concat('(',GROUP_CONCAT(ld_tranlabel.fieldlabel),')')  from ld_account_set_rule
									INNER JOIN ld_tab on ld_tab.name=ld_account_set_rule.tabname
									INNER JOIN ld_tranlabel on ld_tab.tabid=ld_tranlabel.tabid
									and ld_tab.tabid=ld_tranlabel.Relateid and languagetype='zh' and trantable='ld_tab'
										where type='complete' and ld_account_set_rule.`status`='active' ORDER BY ld_account_set_rule.sequence asc ) ";
			set @tmp_namelink=concat('\'<a style="display: initial;" doubleclick="yes" onclick="ListReferenceLinkClick(ld(this),event)" referencemodule="Accounts" referencerecord="\',ld_account.accountid,\'">\',ld_account.accountname,',@TMP_TMPTable,',\'</a>\'');
			set @sql=concat(' select accountid from (',@tmpsql, ') as tmpone group by accountid ') ;
			set @TMPSQL_ONE=concat( ' select "complete",  group_concat(',@tmp_namelink,' separator "<br>" )  as accouontnames ,count(distinct ld_account.accountid)  as totalaccounts,ld_account.smownerid,GROUP_CONCAT(ld_account.accountid separator "##")as accountid from ld_account left join ( ',@sql,' ) as lingdangtmp  on  lingdangtmp.accountid=ld_account.accountid ') ;
			if @recycleselect<>'' and @recycleselect is not null THEN
				set @TMPSQL_ONE=concat(@TMPSQL_ONE,' left join ',@recycleselect,' on recyclewheretableset.accountid=ld_account.accountid ');
end if;
		  set @TMPSQL_TWO=concat(@TMPSQL_ONE,' where ld_account.deleted=0 and( ld_account.publicaccount=2 or ld_account.publicaccount=3) and ld_account.pool_id = ',tmp_pool_id);
		  set @TMPSQL_TWO=concat(@TMPSQL_TWO, ' and lingdangtmp.accountid is null  and datediff(curdate(),ld_account.allocatedate)>',var_days);
			if @recycleselect<>'' and @recycleselect is not null THEN
					set @TMPSQL_TWO=concat(@TMPSQL_TWO, ' and recyclewheretableset.accountid is not null  ');
end if;
			set @TMPSQL_TWO=concat(@TMPSQL_TWO," group by ld_account.smownerid ");
else
			if @recycleselect is not null and @recycleselect<>'' then
					set @sql=concat(' select tmpone.accountid,GROUP_CONCAT(ld_tranlabel.fieldlabel) as fieldlabel from  (',@tmpsql, ' ) as tmpone
												inner join ',@recycleselect,' on tmpone.accountid=recyclewheretableset.accountid
												inner join ld_tab on ld_tab.name=tmpone.remindtabname
										 	INNER JOIN ld_tranlabel on ld_tab.tabid=ld_tranlabel.tabid
										  and ld_tab.tabid=ld_tranlabel.Relateid and languagetype="zh" and trantable="ld_tab"
											 group by accountid ') ;
ELSE
					set @sql=concat(' select accountid,GROUP_CONCAT(ld_tranlabel.fieldlabel) as fieldlabel from (',@tmpsql, ') as tmpone
											inner join ld_tab on ld_tab.name=tmpone.remindtabname
											INNER JOIN ld_tranlabel on ld_tab.tabid=ld_tranlabel.tabid
										  and ld_tab.tabid=ld_tranlabel.Relateid and languagetype="zh" and trantable="ld_tab"
											 group by accountid') ;
end if;
				set @tmp_namelink=concat('\'<a style="display: initial;" doubleclick="yes" onclick="ListReferenceLinkClick(ld(this),event)" referencemodule="Accounts" referencerecord="\',ld_account.accountid,\'">\',ld_account.accountname,lingdangtmp.fieldlabel,\'</a>\'');
			  set @TMPSQL_ONE=concat( ' select "complete",  GROUP_CONCAT(',@tmp_namelink,' separator "<br>")as accountnames,count(distinct ld_account.accountid)
							as totalaccounts,ld_account.smownerid,GROUP_CONCAT(ld_account.accountid separator "##")as accountid  from ld_account  inner join ( ',@sql,' ) as lingdangtmp
							on  lingdangtmp.accountid=ld_account.accountid ') ;
				set @TMPSQL_TWO=concat(@TMPSQL_ONE,' where ld_account.deleted=0 and ( ld_account.publicaccount=2 or ld_account.publicaccount=3) and ld_account.pool_id = ',tmp_pool_id,'  group by ld_account.smownerid ');
end if;
delete from ld_publicaccount_remindtableview ;

set @tmpthree=concat(" insert into ld_publicaccount_remindtableview(type,names,totalaccounts,smownerid,ids )  ", @TMPSQL_TWO);
prepare stmt from @tmpthree;
execute stmt;
deallocate prepare stmt;
call crm_publicaccount_beforereminds();
end if;
end ||
delimiter;


DROP PROCEDURE IF EXISTS `account_singlerecycle_normal`;
delimiter ||
CREATE  PROCEDURE `account_singlerecycle_normal`()
BEGIN

	DECLARE normal_id int(11);
	DECLARE var_pool_id int(11);
	declare done  int  default 0;
	declare cur1 CURSOR FOR select id,pool_id from ld_account_normal where active = 'yes' ORDER BY sequence;
	declare continue handler  for not   found  SET done =1;
		OPEN cur1;
			Fetch cur1 into normal_id,var_pool_id;
			loop1: while  done<>1 DO

				if normal_id > 0 THEN
						call account_singlerecycle_normal_rule(normal_id,var_pool_id);
						call account_singlerecycle_normal_rule_beforeremind(normal_id,var_pool_id);
				end IF;

    	Fetch cur1 into normal_id,var_pool_id;
    	end while loop1;
    close cur1;

end ||
delimiter;

DROP PROCEDURE IF EXISTS `account_singlerecycle_normal_rule`;
delimiter ||
CREATE   PROCEDURE `account_singlerecycle_normal_rule`(new_normal_id 	int(11),
	new_pool_id 	int(11))
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
	declare cur1 CURSOR FOR select tabname,ld_account_set_rule_normal.columnname,ld_field.tablename ,
		ld_account_set_rule_normal.iscycle,`condition`,ld_account_set_rule_normal.days
		,ld_account_set_rule_normal.otherwhere from ld_account_set_rule_normal  inner join ld_tab on ld_tab.name=ld_account_set_rule_normal.tabname and (presence in(0,2) or ld_account_set_rule_normal.tabname='singin')
		INNER JOIN ld_field on ld_field.tabid=ld_tab.tabid and ld_account_set_rule_normal.columnname=ld_field.columnname
		and ld_field.presence in(0,2) where ld_account_set_rule_normal.`status`='active' and normal_id = new_normal_id;

    declare continue handler  for not   found  SET done =1;
    select if(ld_users.id>0,ld_account_normal.transfer_users,0) into @allotaccount from ld_account_normal
    LEFT join ld_users on ld_users.id =ld_account_normal.transfer_users where ld_account_normal.id = new_normal_id;

		if  ifnull(@allotaccount,0)=0  then 
			set @allotaccount=0;
	end if;
    IF EXISTS (SELECT 1 FROM ld_account_public WHERE show_account_rule='yes') THEN
    	set @tmpint=0;
    	set @tmpsql='';
    	select max(ld_account_set_rule_normal.days) into @maxdays
			from ld_account_set_rule_normal  inner join ld_tab on ld_tab.name=ld_account_set_rule_normal.tabname and (presence in(0,2) or ld_account_set_rule_normal.tabname='singin')
			INNER JOIN ld_field on ld_field.tabid=ld_tab.tabid and ld_account_set_rule_normal.columnname=ld_field.columnname
			and ld_field.presence in(0,2) where ld_account_set_rule_normal.`status`='active' and normal_id = new_normal_id;

			select recycleselect into @recycleselect from ld_account_normal where id = new_normal_id;
			set @account_rule_pool_id = new_pool_id;

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

    				set @TMPSQL_ONE=concat( ' select "系统","LOGPUBLICNORMAL",now(), ld_account.accountid,ld_account.pool_id  from ld_account left join ( ',@tmpsql,' ) as lingdangtmp  on  lingdangtmp.accountid=ld_account.accountid ') ;
						set @TMPSQL_LOG_ONE = concat( ' select "系统","LOGPUBLICNORMAL",now(), ld_account.accountid,ld_account.pool_id,ld_account.smownerid,"',new_normal_id,'" as log_grammeid  from ld_account left join ( ',@tmpsql,' ) as lingdangtmp  on  lingdangtmp.accountid=ld_account.accountid ') ;
					if @recycleselect<>'' and @recycleselect is not null THEN
    				set @TMPSQL_ONE=concat(@TMPSQL_ONE,' left join ',@recycleselect,' on recyclewheretableset.accountid=ld_account.accountid ');
						set @TMPSQL_LOG_ONE=concat(@TMPSQL_LOG_ONE,' left join ',@recycleselect,' on recyclewheretableset.accountid=ld_account.accountid ');
    		 	end if;
    			 set @TMPSQL_TWO=concat(' where ld_account.deleted=0 and( ifnull(ld_account.publicaccount,0)<1)'  );
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

    				set @TMPSQL_ONE=concat( ' select "系统","LOGPUBLICNORMAL",now(), ld_account.accountid,ld_account.pool_id  from ld_account inner join ( ',@sql,' ) as lingdangtmp  on  lingdangtmp.accountid=ld_account.accountid ') ;
    				set @TMPSQL_LOG_ONE=concat( ' select "系统","LOGPUBLICNORMAL",now(), ld_account.accountid,ld_account.pool_id,ld_account.smownerid,"',new_normal_id,'" as log_grammeid  from ld_account inner join ( ',@sql,' ) as lingdangtmp  on  lingdangtmp.accountid=ld_account.accountid ') ;
						set @TMPSQL_TWO=concat(' where ld_account.deleted=0 and( ifnull(ld_account.publicaccount,0)<1)'  );
    		 end if;
					
					set @TMPSQL_LOG_TWO = concat(@TMPSQL_LOG_ONE,@TMPSQL_TWO);
					set @TMPSQL_TWO = concat(@TMPSQL_ONE,@TMPSQL_TWO);

    	   set @TMPSQL_THREE=concat('insert into ld_logpublicaccount(username,operation,opdate,accountid,pool_id,old_smownerid,programmeid) ',@TMPSQL_LOG_TWO);
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
    				set @TMPSQL_ONE =concat(@TMPSQL_ONE,' set ld_account.publicaccount=1,ld_account.pool_id=',@account_rule_pool_id,' ,protectdate=null ,allocatedate=null') ;
							if @allotaccount>0 THEN
							set @TMPSQL_ONE=concat(@TMPSQL_ONE,",smownerid=",@allotaccount);
						end if;
    					set @TMPSQL_TWO=concat(@TMPSQL_ONE,' where ld_account.deleted=0 and( ifnull(ld_account.publicaccount,0)<1)');
    		      set @TMPSQL_TWO=concat(@TMPSQL_TWO, " and lingdangtmp.accountid is null and datediff(curdate(),case when ifnull(ld_account.distributiondate,'')='' then ld_account.createdtime else ld_account.distributiondate end)>",@maxdays);
    					if @recycleselect<>'' and @recycleselect is not null THEN
    					   set @TMPSQL_TWO=concat(@TMPSQL_TWO, ' and recyclewheretableset.accountid is not null  ');
    				  end if;

    			ELSE
    				set @TMPSQL_ONE=concat( ' update  ld_account inner join ( ',@sql,' ) as lingdangtmp  on  lingdangtmp.accountid=ld_account.accountid set ld_account.publicaccount=1,ld_account.pool_id=',@account_rule_pool_id,' ,protectdate=null ,allocatedate=null') ;
							if @allotaccount>0 THEN
								set @TMPSQL_ONE=concat(@TMPSQL_ONE,",smownerid=",@allotaccount);
						end if;

						set @TMPSQL_TWO=concat(@TMPSQL_ONE,' where ld_account.deleted=0 and( ifnull(ld_account.publicaccount,0)<1)');

    		 end if;
    		prepare stmt from @TMPSQL_TWO;
    		execute stmt;
    		deallocate prepare stmt;

    	end if;
    END IF;

end ||
delimiter;


DROP PROCEDURE IF EXISTS `account_singlerecycle_normal_rule_beforeremind`;
delimiter ||
CREATE PROCEDURE `account_singlerecycle_normal_rule_beforeremind`(
    new_normal_id 	int(11),
    new_pool_id 	int(11)
        )
    label_a:
BEGIN
	DECLARE var_tabname varchar(100);
	DECLARE var_columnname varchar(100);
	DECLARE var_tablename varchar(100);
	DECLARE var_condition varchar(50);
	DECLARE var_smownercolumn varchar(50);
	declare var_iscycle varchar(50);
	DECLARE var_days int(11);
	DECLARE var_otherwhere varchar(200);
	declare done  int  default 0;

	declare cur1 CURSOR FOR select tabname,ld_account_set_rule_normal.columnname,ld_field.tablename ,
                                   ld_account_set_rule_normal.iscycle,`condition`,ld_account_set_rule_normal.days
                                                                                                                                                ,ld_account_set_rule_normal.otherwhere from ld_account_set_rule_normal  inner join ld_tab on ld_tab.name=ld_account_set_rule_normal.tabname and (presence in(0,2) or ld_account_set_rule_normal.tabname='singin')
                                                                                                                                                                                                                        INNER JOIN ld_field on ld_field.tabid=ld_tab.tabid and ld_account_set_rule_normal.columnname=ld_field.columnname
    and ld_field.presence in(0,2) where ld_account_set_rule_normal.`status`='active' and normal_id = new_normal_id;

declare continue handler  for not   found  SET done =1;

    IF EXISTS (SELECT 1 FROM ld_account_public WHERE show_account_rule='yes') THEN
    	set @tmpint=0;
    	set @tmpsql='';
select max(ld_account_set_rule_normal.days) into @maxdays
from ld_account_set_rule_normal  inner join ld_tab on ld_tab.name=ld_account_set_rule_normal.tabname and (presence in(0,2) or ld_account_set_rule_normal.tabname='singin')
                                 INNER JOIN ld_field on ld_field.tabid=ld_tab.tabid and ld_account_set_rule_normal.columnname=ld_field.columnname
    and ld_field.presence in(0,2) where ld_account_set_rule_normal.`status`='active' and normal_id = new_normal_id;

select recycleselect into @recycleselect from ld_account_normal where id = new_normal_id;

select beforereminddays into @var_beforereminddays from ld_account_normal where id = new_normal_id;
if @var_beforereminddays='' or @var_beforereminddays is null or @var_beforereminddays=0 then
    		leave label_a ;
end if;
       set @maxdays=@maxdays-@var_beforereminddays;

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
    			 set var_days=var_days-@var_beforereminddays;
    			if var_days<=0 THEN
    				leave loop1;
end if;
    		  if(var_condition='and' ) then

    			set @tmpsqlone =concat("select ld_account.accountid,ld_account.distributiondate,ld_account.createdtime, '",var_tabname,"' as remindtabname from ld_account ");
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

               set @tmpsqltwo=concat("select ld_account.accountid,ld_account.distributiondate,ld_account.createdtime , '",var_tabname,"' as remindtabname from ld_account LEFT JOIN (select ld_account.accountid from ld_account inner join ",var_tablename,' on ld_account.accountid=',
                    var_tablename,'.accountid and ld_account.smownerid=',var_tablename,'.',var_smownercolumn,'  where ',var_tablename,'.deleted=0');

    		   if var_otherwhere is not null and  var_otherwhere<>'' then
    					set @tmpsqltwo=concat(@tmpsqltwo, var_otherwhere);
end if;
    			set @tmpsqltwo=concat(@tmpsqltwo,' ) 	as ttt_',var_tablename,'  on ld_account.accountid=ttt_',var_tablename,'.accountid   where ttt_',var_tablename,'.accountid is null  ' );
    			set @tmpsqltwo=concat(@tmpsqltwo," having datediff(curdate(),IF(IFNULL(ld_account.distributiondate,'0000-00-00')<='1600-00-00',ld_account.createdtime,ld_account.distributiondate) ) >",var_days);


    			IF var_iscycle = 'yes' then
						set @tmpthree=concat( @tmpsqlone,' union all ',@tmpsqltwo);
ELSE
						set @tmpthree=@tmpsqltwo;
end if;

    			set @tmpsql=concat(@tmpsql," select * from ( ",@tmpthree," ) as  tttt_",var_tabname);
    			set @tmpsql=concat(@tmpsql,' union all ' );

    			elseif (var_condition='or')  then
    				set @tmpsql=concat(@tmpsql ," select ld_account.accountid,ld_account.distributiondate,ld_account.createdtime, '",var_tabname,"' as remindtabname from ld_account inner join "  ,var_tablename,' on ',var_tablename,'.accountid=ld_account.accountid  ');
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
    				 set @TMP_TMPTable=concat(' ( select  concat("(",GROUP_CONCAT(ld_tranlabel.fieldlabel),")")  from ld_account_set_rule_normal
							INNER JOIN ld_tab on ld_tab.name=ld_account_set_rule_normal.tabname
							INNER JOIN ld_tranlabel on ld_tab.tabid=ld_tranlabel.tabid
							and ld_tab.tabid=ld_tranlabel.Relateid and languagetype="zh" and trantable="ld_tab"
							where ld_account_set_rule_normal.status="active" and normal_id = ',new_normal_id,' ORDER BY ld_account_set_rule_normal.sequence asc ) ');
						set @tmp_namelink=concat('\'<a style="display: initial;" doubleclick="yes" onclick="ListReferenceLinkClick(ld(this),event)" referencemodule="Accounts" referencerecord="\',ld_account.accountid,\'">\',ld_account.accountname,',@TMP_TMPTable,',\'</a>\'');
    				set @sql=concat(' select accountid from (',@tmpsql, ') as tmpone group by accountid ') ;
    				set @TMPSQL_ONE=concat( ' select "normal", group_concat(',@tmp_namelink,' separator "<br>" )  as accouontnames ,count(distinct ld_account.accountid)  as totalaccounts,ld_account.smownerid from ld_account left join ( ',@sql,' ) as lingdangtmp  on  lingdangtmp.accountid=ld_account.accountid ') ;
    				if @recycleselect<>'' and @recycleselect is not null THEN
    					set @TMPSQL_ONE=concat(@TMPSQL_ONE,' left join ',@recycleselect,' on recyclewheretableset.accountid=ld_account.accountid ');
end if;
    				 set @TMPSQL_TWO=concat(@TMPSQL_ONE,' where ld_account.deleted=0 and( ifnull(ld_account.publicaccount,0)<1)');
    					set @TMPSQL_TWO=concat(@TMPSQL_TWO, " and lingdangtmp.accountid is null  and datediff(curdate(),case when ifnull(ld_account.distributiondate,'')='' then ld_account.createdtime else ld_account.distributiondate end)>",@maxdays);
    					if @recycleselect<>'' and @recycleselect is not null THEN
    						set @TMPSQL_TWO=concat(@TMPSQL_TWO, ' and recyclewheretableset.accountid is not null ');
end if;
    				 set @TMPSQL_TWO=concat(@TMPSQL_TWO," group by ld_account.smownerid ");
else
    				if @recycleselect is not null and @recycleselect<>'' then

    					set @sql=concat(' select tmpone.accountid,GROUP_CONCAT(ld_tranlabel.fieldlabel) as fieldlabel from  (',@tmpsql, ' ) as tmpone
    												inner join ',@recycleselect,' on tmpone.accountid=recyclewheretableset.accountid
    												inner join ld_tab on ld_tab.name=tmpone.remindtabname
    										 	INNER JOIN ld_tranlabel on ld_tab.tabid=ld_tranlabel.tabid
    										  and ld_tab.tabid=ld_tranlabel.Relateid and languagetype="zh" and trantable="ld_tab"
    											 group by accountid ') ;
ELSE
    					set @sql=concat(' select accountid,GROUP_CONCAT(ld_tranlabel.fieldlabel) as fieldlabel from (',@tmpsql, ') as tmpone
    											inner join ld_tab on ld_tab.name=tmpone.remindtabname
    											INNER JOIN ld_tranlabel on ld_tab.tabid=ld_tranlabel.tabid
    										  and ld_tab.tabid=ld_tranlabel.Relateid and languagetype="zh" and trantable="ld_tab"
    											 group by accountid') ;
end if;
						set @tmp_namelink=concat('\'<a style="display: initial;" doubleclick="yes" onclick="ListReferenceLinkClick(ld(this),event)" referencemodule="Accounts" referencerecord="\',ld_account.accountid,\'">\',ld_account.accountname,lingdangtmp.fieldlabel,\'</a>\'');
    				set @TMPSQL_ONE=concat( ' select "normal",  GROUP_CONCAT(',@tmp_namelink,'  separator "<br>")as accountnames,count(distinct ld_account.accountid)  as totalaccounts,ld_account.smownerid from    ld_account  inner join ( ',@sql,' ) as lingdangtmp  on  lingdangtmp.accountid=ld_account.accountid ') ;
    				set @TMPSQL_TWO=concat(@TMPSQL_ONE,' where ld_account.deleted=0 and( ifnull(ld_account.publicaccount,0)<1) group by ld_account.smownerid'  );
end if;

delete from ld_publicaccount_remindtableview ;
set @tmpthree=concat(" insert into ld_publicaccount_remindtableview(type,names,totalaccounts,smownerid )  ", @TMPSQL_TWO);
prepare stmt from @tmpthree;
execute stmt;
deallocate prepare stmt;

call crm_publicaccount_beforereminds();
end if;
END IF;

end ||
delimiter;

SET @labelbol = 'DISPLAYSEACUSTOMER';set @labeltype = 'fixedstr';
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'zh',@labelbol,'PC端显示公海客户模块',@labeltype FROM DUAL 
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol=@labelbol and labeltype=@labeltype);
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'en',@labelbol,'PC display of open sea customer module',@labeltype FROM DUAL 
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol=@labelbol and labeltype=@labeltype);
delimiter;

SET @labelbol = 'DISPLAYSEALEADS';set @labeltype = 'fixedstr';
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'zh',@labelbol,'PC端显示公海线索模块',@labeltype FROM DUAL 
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol=@labelbol and labeltype=@labeltype);
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'en',@labelbol,'PC display of open sea leads module',@labeltype FROM DUAL 
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol=@labelbol and labeltype=@labeltype);
delimiter;

SET @labelbol = 'SEACUSTOMERLISTTABSET';set @labeltype = 'fixedstr';
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'zh',@labelbol,'公海客户列表页签设置',@labeltype FROM DUAL 
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol=@labelbol and labeltype=@labeltype);
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'en',@labelbol,'Sea customer list tab settings',@labeltype FROM DUAL 
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol=@labelbol and labeltype=@labeltype);
delimiter;

SET @labelbol = 'SEALEADLISTTABSET';set @labeltype = 'fixedstr';
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'zh',@labelbol,'公海线索列表页签设置',@labeltype FROM DUAL 
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol=@labelbol and labeltype=@labeltype);
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'en',@labelbol,'Sea lead list tab settings',@labeltype FROM DUAL 
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol=@labelbol and labeltype=@labeltype);
delimiter;

SET @labelbol = 'CUSTOMERLISTTABSET';set @labeltype = 'fixedstr';
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'zh',@labelbol,'客户列表页签设置',@labeltype FROM DUAL 
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol=@labelbol and labeltype=@labeltype);
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'en',@labelbol,'Customer list tab settings',@labeltype FROM DUAL 
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol=@labelbol and labeltype=@labeltype);
delimiter;

SET @labelbol = 'LEADLISTTABSET';set @labeltype = 'fixedstr';
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'zh',@labelbol,'线索列表页签设置',@labeltype FROM DUAL 
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol=@labelbol and labeltype=@labeltype);
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'en',@labelbol,'Lead list tab settings',@labeltype FROM DUAL 
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol=@labelbol and labeltype=@labeltype);
delimiter;


SET @labelbol = 'TABDESCRIPTION';set @labeltype = 'fixedstr';
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'zh',@labelbol,'页签描述',@labeltype FROM DUAL 
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol=@labelbol and labeltype=@labeltype);
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'en',@labelbol,'Tab description',@labeltype FROM DUAL 
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol=@labelbol and labeltype=@labeltype);
delimiter;

SET @labelbol = 'DEFAULTTAB';set @labeltype = 'fixedstr';
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'zh',@labelbol,'默认页签',@labeltype FROM DUAL 
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol=@labelbol and labeltype=@labeltype);
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'en',@labelbol,'Default tab',@labeltype FROM DUAL 
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol=@labelbol and labeltype=@labeltype);
delimiter;

SET @labelbol = 'HIGHSEASPOOLMANAGEMENT';set @labeltype = 'fixedstr';
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'zh',@labelbol,'公海池管理',@labeltype FROM DUAL 
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol=@labelbol and labeltype=@labeltype);
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'en',@labelbol,'High Seas Pool Management',@labeltype FROM DUAL 
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol=@labelbol and labeltype=@labeltype);
delimiter;

SET @labelbol = 'MAXIMUMREGULARLEADS';set @labeltype = 'fixedstr';
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'zh',@labelbol,'普通线索数量上限',@labeltype FROM DUAL 
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol=@labelbol and labeltype=@labeltype);
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'en',@labelbol,'Maximum number of regular leads',@labeltype FROM DUAL 
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol=@labelbol and labeltype=@labeltype);
delimiter;

SET @labelbol = 'MAXIMUMREGULARCUSTOMERS';set @labeltype = 'fixedstr';
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'zh',@labelbol,'普通客户数量上限',@labeltype FROM DUAL 
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol=@labelbol and labeltype=@labeltype);
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'en',@labelbol,'Maximum number of regular customers',@labeltype FROM DUAL 
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol=@labelbol and labeltype=@labeltype);
delimiter;

SET @labelbol = 'ACCORDINGTOTHEUSEREACH';set @labeltype = 'fixedstr';
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'zh',@labelbol,'按成员控制，每成员',@labeltype FROM DUAL 
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol=@labelbol and labeltype=@labeltype);
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'en',@labelbol,'According to the user control, for each user',@labeltype FROM DUAL 
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol=@labelbol and labeltype=@labeltype);
delimiter;

SET @labelbol = 'SCHEMEDESCRIPTION';set @labeltype = 'fixedstr';
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'zh',@labelbol,'方案说明',@labeltype FROM DUAL 
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol=@labelbol and labeltype=@labeltype);
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'en',@labelbol,'Scheme Description',@labeltype FROM DUAL 
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol=@labelbol and labeltype=@labeltype);
delimiter;

SET @labelbol = 'REGULARCUSTOMERSRECYCLINGSCHEME';set @labeltype = 'fixedstr';
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'zh',@labelbol,'普通客户回收方案',@labeltype FROM DUAL 
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol=@labelbol and labeltype=@labeltype);
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'en',@labelbol,'Regular customers recycling scheme',@labeltype FROM DUAL 
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol=@labelbol and labeltype=@labeltype);
delimiter;

SET @labelbol = 'REGULARLEADSRECYCLINGSCHEME';set @labeltype = 'fixedstr';
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'zh',@labelbol,'普通线索回收方案',@labeltype FROM DUAL 
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol=@labelbol and labeltype=@labeltype);
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'en',@labelbol,'Regular leads recycling scheme',@labeltype FROM DUAL 
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol=@labelbol and labeltype=@labeltype);
delimiter;

SET @labelbol = 'SEACUSTOMERSRECYCLINGSCHEME';set @labeltype = 'fixedstr';
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'zh',@labelbol,'公海客户回收方案',@labeltype FROM DUAL 
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol=@labelbol and labeltype=@labeltype);
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'en',@labelbol,'Sea customers recycling scheme',@labeltype FROM DUAL 
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol=@labelbol and labeltype=@labeltype);
delimiter;

SET @labelbol = 'SEALEADSRECYCLINGSCHEME';set @labeltype = 'fixedstr';
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'zh',@labelbol,'公海线索回收方案',@labeltype FROM DUAL 
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol=@labelbol and labeltype=@labeltype);
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'en',@labelbol,'Sea leads recycling scheme',@labeltype FROM DUAL 
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol=@labelbol and labeltype=@labeltype);
delimiter;

SET @labelbol = 'CIRCLERULELABEL';set @labeltype = 'fixedstr';
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'zh',@labelbol,'自分配或创建之日起距最近一次{module}的创建时间已超过{var}天',@labeltype FROM DUAL 
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol=@labelbol and labeltype=@labeltype);
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'en',@labelbol,'The duration between the latest creation of {module} and the day of distribution or creation has exceeded for {var} days',@labeltype FROM DUAL 
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol=@labelbol and labeltype=@labeltype);
delimiter;

SET @labelbol = 'SINGLERULELABEL';set @labeltype = 'fixedstr';
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'zh',@labelbol,'自分配或创建之日起{var}天没有创建{module}',@labeltype FROM DUAL 
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol=@labelbol and labeltype=@labeltype);
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'en',@labelbol,'From the date of distribution or creation {var} days without creating {module} ',@labeltype FROM DUAL 
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol=@labelbol and labeltype=@labeltype);
delimiter;



SET @labelbol = 'UPPERLIMITOFALLOCATED';set @labeltype = 'fixedstr';
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'zh',@labelbol,'公海已分配保有量上限（按公海池总数控制）',@labeltype FROM DUAL 
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol=@labelbol and labeltype=@labeltype);
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'en',@labelbol,'Upper limit of allocated reserves in the open sea (controlled by the total number of open sea pools)',@labeltype FROM DUAL 
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol=@labelbol and labeltype=@labeltype);
delimiter;

SET @labelbol = 'ENABLERECYCLINGSCHEME';set @labeltype = 'fixedstr';
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'zh',@labelbol,'启用回收方案',@labeltype FROM DUAL 
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol=@labelbol and labeltype=@labeltype);
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'en',@labelbol,'Enable recycling scheme',@labeltype FROM DUAL 
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol=@labelbol and labeltype=@labeltype);
delimiter;

SET @labelbol = 'SCHEMENAME';set @labeltype = 'fixedstr';
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'zh',@labelbol,'方案名称',@labeltype FROM DUAL 
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol=@labelbol and labeltype=@labeltype);
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'en',@labelbol,'Scheme name',@labeltype FROM DUAL 
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol=@labelbol and labeltype=@labeltype);
delimiter;

SET @labelbol = '-';set @labeltype = 'fixedstr';
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'zh',@labelbol,'新增回收规则',@labeltype FROM DUAL 
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol=@labelbol and labeltype=@labeltype);
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'en',@labelbol,'Add recycling rules',@labeltype FROM DUAL 
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol=@labelbol and labeltype=@labeltype);
delimiter;

SET @labelbol = 'INTERVALDAYS';set @labeltype = 'fixedstr';
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'zh',@labelbol,'间隔天数',@labeltype FROM DUAL 
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol=@labelbol and labeltype=@labeltype);
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'en',@labelbol,'Interval days',@labeltype FROM DUAL 
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol=@labelbol and labeltype=@labeltype);
delimiter;

SET @labelbol = 'LOGICALRELATION';set @labeltype = 'fixedstr';
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'zh',@labelbol,'逻辑关系',@labeltype FROM DUAL 
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol=@labelbol and labeltype=@labeltype);
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'en',@labelbol,'Logical relation',@labeltype FROM DUAL 
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol=@labelbol and labeltype=@labeltype);
delimiter;

SET @labelbol = 'AUTOMATICRECOVERYMODIFYOWNER';set @labeltype = 'fixedstr';
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'zh',@labelbol,'自动回收后更改负责人为（只能选择公海成员，为空表示不更改）',@labeltype FROM DUAL 
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol=@labelbol and labeltype=@labeltype);
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'en',@labelbol,'After automatic recovery, modify the owner as (do nothing if empty)',@labeltype FROM DUAL 
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol=@labelbol and labeltype=@labeltype);
delimiter;

SET @labelbol = 'CYCLENOCREATEDDAYS';set @labeltype = 'fixedstr';
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'zh',@labelbol,'循环：{var}天没有创建{module}',@labeltype FROM DUAL 
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol=@labelbol and labeltype=@labeltype);
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'en',@labelbol,'Cycle: No {module} created for {var} days',@labeltype FROM DUAL 
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol=@labelbol and labeltype=@labeltype);
delimiter;

SET @labelbol = 'SINGLENOCREATEDDAYS';set @labeltype = 'fixedstr';
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'zh',@labelbol,'单次：{var}天没有创建{module}',@labeltype FROM DUAL 
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol=@labelbol and labeltype=@labeltype);
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'en',@labelbol,'Single: No {module} created for {var} days',@labeltype FROM DUAL 
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol=@labelbol and labeltype=@labeltype);
delimiter;

SET @labelbol = 'MEMBERNAME';set @labeltype = 'fixedstr';
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'zh',@labelbol,'成员名称',@labeltype FROM DUAL 
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol=@labelbol and labeltype=@labeltype);
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'en',@labelbol,'Member Name',@labeltype FROM DUAL 
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol=@labelbol and labeltype=@labeltype);
delimiter;

SET @labelbol = 'SUPERADMINISTRATORHASALLPERMISSIONS';set @labeltype = 'fixedstr';
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'zh',@labelbol,'（公海超级管理员默认为所有公海管理员，并拥有所有权限）',@labeltype FROM DUAL 
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol=@labelbol and labeltype=@labeltype);
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'en',@labelbol,'(The High Seas Super Administrator defaults to all High Seas Administrators and has all permissions)',@labeltype FROM DUAL 
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol=@labelbol and labeltype=@labeltype);
delimiter;

SET @labelbol = 'SEASMEMBERSSCOPEOFRELEASE';set @labeltype = 'fixedstr';
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'zh',@labelbol,'公海成员释放权限',@labeltype FROM DUAL 
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol=@labelbol and labeltype=@labeltype);
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'en',@labelbol,'Scope of Release Authority for High Seas Members',@labeltype FROM DUAL 
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol=@labelbol and labeltype=@labeltype);
delimiter;

SET @labelbol = 'RELEASESELF';set @labeltype = 'fixedstr';
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'zh',@labelbol,'仅允许释放自己的（负责人是自己）',@labeltype FROM DUAL 
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol=@labelbol and labeltype=@labeltype);
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'en',@labelbol,'Only allow the release of one`s own (the person in charge is oneself)',@labeltype FROM DUAL 
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol=@labelbol and labeltype=@labeltype);
delimiter;

SET @labelbol = 'NOTALLOWEDRELEASE';set @labeltype = 'fixedstr';
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'zh',@labelbol,'不允许释放',@labeltype FROM DUAL 
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol=@labelbol and labeltype=@labeltype);
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'en',@labelbol,'Not allowed to release',@labeltype FROM DUAL 
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol=@labelbol and labeltype=@labeltype);
delimiter;

SET @labelbol = 'Themaximumnumberofleads';set @labeltype = 'fixedstr';
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'en',@labelbol,'The maximum number of {$Leads.Leads}',@labeltype FROM DUAL 
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol=@labelbol and labeltype=@labeltype);
delimiter;

SET @labelbol = 'THEMAXIMUMNUMBEROFHIGHSEASLEADS';set @labeltype = 'fixedstr';
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'zh',@labelbol,'可拥有公海已分配{$Leads.Leads}数量上限',@labeltype FROM DUAL 
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol=@labelbol and labeltype=@labeltype);
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'en',@labelbol,'The maximum number of unassigned {$Leads.Leads}',@labeltype FROM DUAL 
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol=@labelbol and labeltype=@labeltype);
delimiter;

SET @labelbol = 'OBJTAINLEADCONTROLDAYS';set @labeltype = 'fixedstr';
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'zh',@labelbol,'{$Leads.Leads}被自动回收后__天内不允许被当前{$Leads.assigned_user_id}再次领取（为0或空表示不控制）',@labeltype FROM DUAL 
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol=@labelbol and labeltype=@labeltype);
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'en',@labelbol,'The {$Leads.Leads} is not allowed to be obtained again by the {$Leads.assigned_user_id} within__days after being recycled',@labeltype FROM DUAL 
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol=@labelbol and labeltype=@labeltype);
delimiter;

SET @labelbol = 'AFTERDELETETHELEADSHIGNSEASPOOL';set @labeltype = 'jspop';
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'zh',@labelbol,'删除公海池后，该公海池中的公海线索将全部转移到所选公海池的“公海未分配”中，是否继续？',@labeltype FROM DUAL 
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol=@labelbol and labeltype=@labeltype);
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'en',@labelbol,' After deleting the high seas pool, all the high Seas leads in the pool will be transferred to the "high seas not allocated" of the selected high seas pool. Do you want to continue? ',@labeltype FROM DUAL 
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol=@labelbol and labeltype=@labeltype);
delimiter;

SET @labelbol = 'ATLEASTONETAB';set @labeltype = 'fixedstr';
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'zh',@labelbol,'请至少启用一个页签！',@labeltype FROM DUAL 
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol=@labelbol and labeltype=@labeltype);
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'en',@labelbol,'Please enable at least one tab',@labeltype FROM DUAL 
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol=@labelbol and labeltype=@labeltype);
delimiter;

SET @labelbol = 'ACCOUNTSLIMITCOLLECTIONFAILED';set @labeltype = 'fixedstr';
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'zh',@labelbol,'您拥有的公海{$Accounts.Accounts}数量已超过总保有量上限，领取失败！',@labeltype FROM DUAL 
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol=@labelbol and labeltype=@labeltype);
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'en',@labelbol,'The number of international {$Accounts.Accounts} you have exceeded the limit of ownership, collection failed!',@labeltype FROM DUAL 
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol=@labelbol and labeltype=@labeltype);
delimiter;

SET @labelbol = 'LEADSLIMITCOLLECTIONFAILED';set @labeltype = 'fixedstr';
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'zh',@labelbol,'您拥有的公海{$Leads.Leads}数量已超过总保有量上限，领取失败！',@labeltype FROM DUAL 
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol=@labelbol and labeltype=@labeltype);
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'en',@labelbol,'The number of international {$Leads.Leads} you have exceeded the limit of ownership, collection failed!',@labeltype FROM DUAL 
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol=@labelbol and labeltype=@labeltype);
delimiter;

SET @labelbol = 'ACCOUNTSLIMITALLOCATIONFAILED';set @labeltype = 'fixedstr';
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'zh',@labelbol,'该用户拥有的公海{$Accounts.Accounts}数量已超过总保有量上限，分配失败！',@labeltype FROM DUAL 
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol=@labelbol and labeltype=@labeltype);
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'en',@labelbol,'The number of international {$Accounts.Accounts} you have exceeded the limit of ownership, allocation failed!',@labeltype FROM DUAL 
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol=@labelbol and labeltype=@labeltype);
delimiter;

SET @labelbol = 'LEADSLIMITALLOCATIONFAILED';set @labeltype = 'fixedstr';
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'zh',@labelbol,'该用户拥有的公海{$Leads.Leads}数量已超过总保有量上限，分配失败！',@labeltype FROM DUAL 
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol=@labelbol and labeltype=@labeltype);
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'en',@labelbol,'The number of international {$Leads.Leads} you have exceeded the limit of ownership, allocation failed!',@labeltype FROM DUAL 
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol=@labelbol and labeltype=@labeltype);
delimiter;

SET @labelbol = 'ADDRECYCLINGRULES';set @labeltype = 'fixedstr';
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'zh',@labelbol,'新增回收规则',@labeltype FROM DUAL 
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol=@labelbol and labeltype=@labeltype);
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'en',@labelbol,'Add recycling rules',@labeltype FROM DUAL 
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol=@labelbol and labeltype=@labeltype);
delimiter;

UPDATE ld_field SET fieldvaluecolor = "#333333" WHERE fieldvaluecolor = "#595959";
UPDATE ld_field SET fieldvaluecolor = "#3B7CFF" WHERE fieldvaluecolor = "#286CCC" AND (bigtype = "mobile" OR bigtype = "phone");
delimiter;

SET @tabid=(SELECT tabid FROM ld_tab WHERE `name`='CashBack');
SET @option_tabid=(SELECT tabid FROM ld_tab WHERE `name`='SalesOrder');
INSERT INTO ld_option_module(tabid,option_tabid,presence,`default`,approve_demand,datarang,maxrowsshow,withdetail,withbalanceqtycondition)
SELECT @tabid,@option_tabid,'1','0','0','permit',5,'yes',0 FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_option_module WHERE tabid=@tabid AND option_tabid=@option_tabid);
delimiter;

call AddColumn("ld_field",'label_style','text','',NULL);
delimiter;

SET @labelbol = 'LABELCOLOR';set @labeltype = 'fixedstr';
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'zh',@labelbol,'标签颜色',@labeltype FROM DUAL 
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol=@labelbol and labeltype=@labeltype);
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'en',@labelbol,'label color',@labeltype FROM DUAL 
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol=@labelbol and labeltype=@labeltype);
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','APPROVEAFTERINVALIDATION','审批作废后','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='APPROVEAFTERINVALIDATION' and labeltype='fixedstr' and languagetype='zh');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','APPROVEAFTERINVALIDATION','Approval after invalidation','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='APPROVEAFTERINVALIDATION' and labeltype='fixedstr' and languagetype='en');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','SELECTROLES','选择角色','jspop' from dual
where not exists(select 1 from ld_desk where labelbol='SELECTROLES' and labeltype='jspop' and languagetype='zh');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','SELECTROLES','Select Roles','jspop' from dual
where not exists(select 1 from ld_desk where labelbol='SELECTROLES' and labeltype='jspop' and languagetype='en');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','POSITIONLEVEL','职位级别','jspop' from dual
where not exists(select 1 from ld_desk where labelbol='POSITIONLEVEL' and labeltype='jspop' and languagetype='zh');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','POSITIONLEVEL','Position level','jspop' from dual
where not exists(select 1 from ld_desk where labelbol='POSITIONLEVEL' and labeltype='jspop' and languagetype='en');
delimiter;

call AddColumn('ld_approvestep','approvalauthority','text','','');
delimiter;

UPDATE ld_approvestep SET approvalauthority = '{"showcancelbill":"yes"}' WHERE approvalauthority is NULL;
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','ApprovalAuthority','审批权限','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='ApprovalAuthority' and labeltype='fixedstr' and languagetype='zh');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','ApprovalAuthority','Approval authority','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='ApprovalAuthority' and labeltype='fixedstr' and languagetype='en');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','DisplayRejectDocumentVoidOption','显示“驳回，结束流程（单据作废）”选项','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='DisplayRejectDocumentVoidOption' and labeltype='fixedstr' and languagetype='zh');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','DisplayRejectDocumentVoidOption','Display the "Reject, End Process (Document Void)" option','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='DisplayRejectDocumentVoidOption' and labeltype='fixedstr' and languagetype='en');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','DisplayRejectDocumentVoidOptionTips1','非最后一个审批步骤，可通过开启“允许直接结束审批流程”控制该参数生效','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='DisplayRejectDocumentVoidOptionTips1' and labeltype='fixedstr' and languagetype='zh');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','DisplayRejectDocumentVoidOptionTips1','If it is not the last approval step, you can enable "Allow the approval process to end directly" to control the effect of this parameter','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='DisplayRejectDocumentVoidOptionTips1' and labeltype='fixedstr' and languagetype='en');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','DisplayRejectDocumentVoidOptionTips2','最后一个审批步骤，该参数直接生效','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='DisplayRejectDocumentVoidOptionTips2' and labeltype='fixedstr' and languagetype='zh');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','DisplayRejectDocumentVoidOptionTips2','In the last approval step, this parameter takes effect directly','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='DisplayRejectDocumentVoidOptionTips2' and labeltype='fixedstr' and languagetype='en');
delimiter;

SET @labelbol = 'PRMGROUPRELATEDTISHI';
SET @labeltype = 'fixedstr';
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'zh',@labelbol,'[客户名称]将显示为公司信息资料页显示名称',@labeltype FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol=@labelbol and Labeltype=@labeltype);
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'en',@labelbol,'[Customer Name] will be displayed as the name on the company information page',@labeltype FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol=@labelbol and Labeltype=@labeltype);
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','CurrentlyNoApplicableHighSeasOptionsForChanging','当前无适用公海和选项可用于变更公海','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='CurrentlyNoApplicableHighSeasOptionsForChanging' and labeltype='fixedstr' and languagetype='zh');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','CurrentlyNoApplicableHighSeasOptionsForChanging','Currently, there are no applicable high seas and options available for changing high seas" document!','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='CurrentlyNoApplicableHighSeasOptionsForChanging' and labeltype='fixedstr' and languagetype='en');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','BACKTOHOMEPAGE','返回首页','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='BACKTOHOMEPAGE' and labeltype='fixedstr' and languagetype='zh');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','BACKTOHOMEPAGE','Back to home page','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='BACKTOHOMEPAGE' and labeltype='fixedstr' and languagetype='en');
delimiter;

update ld_field set bigtype='users' where fieldname='approveby' and ifnull(bigtype,'')='';
delimiter;

SET @labelbol = 'FileFormatError';set @labeltype = 'jspop';
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'zh',@labelbol,'文件格式错误！无法保存',@labeltype FROM DUAL 
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol=@labelbol and labeltype=@labeltype);
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'en',@labelbol,'File format error! Unable to save',@labeltype FROM DUAL 
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol=@labelbol and labeltype=@labeltype);
delimiter;

SET @labelbol = 'CHOOSEIMAGECORRECTLY';set @labeltype = 'jspop';
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'zh',@labelbol,'请正确选择图片格式文件！',@labeltype FROM DUAL 
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol=@labelbol and labeltype=@labeltype);
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'en',@labelbol,'Please choose the image format file correctly!',@labeltype FROM DUAL 
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol=@labelbol and labeltype=@labeltype);
delimiter;


UPDATE ld_field_seq SET id=(SELECT max(fieldid) FROM ld_field);
SET @modulename='PaymentPlan';
SET @tabid=(SELECT tabid FROM ld_tab WHERE name=@modulename);
SET @relateid=(select block from ld_field where columnname = 'smownerid' and tabid = @tabid LIMIT 1);
SET @maxseq=IFNULL((SELECT MAX(sequence) FROM ld_field WHERE tabid=@tabid AND block=@relateid),0);
SET @trantable='ld_field';
SET @tablename=(SELECT tablename FROM ld_field WHERE tabid=@tabid AND columnname='smownerid' LIMIT 1);
SET @columnname='projectid';
SET @fieldname='projectid';
SET @zh='项目名称';
SET @en='Project Name';
SET @uitype=82;
SET @typeofdata='V~O';
SET @quickcreate=0;
SET @displaytype=1;
SET @bigtype='reference';
SET @datarang='permit';
SET @maxrowsshow=5;
SET @savedatabase = 'yes';
SET @allowedit = 'yes';
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

CALL AddColumn(@tablename,@columnname,'int','19','');
delimiter;

SET @module='Project';
SET @rel_module='PaymentPlan';
SET @tabid=(SELECT tabid FROM ld_tab WHERE `name`='Project');
SET @rel_tabid=(SELECT tabid FROM ld_tab WHERE `name`='PaymentPlan');
SET @relation_id=(SELECT MAX(relation_id) FROM ld_relatedlists);
SET @seq=(SELECT MAX(sequence) FROM ld_relatedlists WHERE tabid=@tabid);
SET @template=CONCAT('get_',LOWER(@rel_module));
INSERT INTO ld_relatedlists(relation_id,tabid,related_tabid,`name`,sequence,label,presence,actions,type,related_coltable)
SELECT @relation_id+1,@tabid,@rel_tabid,@template,@seq+1,@rel_module,0,'add','datacategory_sql','paymentplan.projectid' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_relatedlists WHERE tabid=@tabid AND `name`=@template AND related_tabid=@rel_tabid);
UPDATE ld_relatedlists_seq SET id=(SELECT MAX(relation_id) FROM ld_relatedlists);
delimiter;
UPDATE ld_desk SET fieldlabel = '搜索左下，按钮右上' where labelbol = 'searchleftbuttonright' AND labeltype = 'fixedstr' AND languagetype = 'zh';
delimiter;
UPDATE ld_desk SET fieldlabel = '搜索右上，按钮左下' where labelbol = 'searchrightbuttonleft' AND labeltype = 'fixedstr' AND languagetype = 'zh';
delimiter;

ALTER TABLE ld_users ALTER COLUMN crm_user_type SET DEFAULT "crm";
update ld_users set crm_user_type="crm" where ISNULL(crm_user_type);
delimiter;

drop PROCEDURE if exists execute_leads_publicoperation;
delimiter ||
create PROCEDURE execute_leads_publicoperation()
BEGIN
	declare done  int  default 0;
	DECLARE tmp_pool_id varchar(200);
	declare cur1 CURSOR FOR SELECT id  FROM  ld_leads_public_pool where deleted = 0 and active = 'yes';
	declare continue handler  for not   found  SET done =1;
	if  EXISTS (SELECT 1 FROM ld_leads_public WHERE STATUS = 'yes')  THEN
		if NOT EXISTS (SELECT 1 FROM ld_sys_event WHERE eventdate>CURDATE() AND type='publicleads')  THEN
			UPDATE ld_sys_event SET eventdate=NOW() WHERE type='publicleads';
			call leads_singlerecycle_normal();
			OPEN cur1;
				Fetch cur1 into tmp_pool_id;
					loop1: while  done<>1 DO
						call leads_singlerecycle_highsea_program(tmp_pool_id);
				Fetch cur1 into tmp_pool_id;
			end while loop1;
			close cur1;
		end if;
	end if;
end ||
delimiter;

DROP PROCEDURE IF EXISTS `leads_singlerecycle_highsea_program`;
delimiter ||
CREATE PROCEDURE `leads_singlerecycle_highsea_program`(IN tmp_from_pool_id INT(11))
BEGIN
	declare done  int  default 0;
	DECLARE target_pool_id varchar(200);
	DECLARE tmp_grammeid varchar(200);
	declare cur1 CURSOR FOR SELECT programmeid,pool_id from ld_module_recovery_programme where modulename = 'Leads' and active = 'yes' and from_pool_id = tmp_from_pool_id ORDER BY sequence;
	declare continue handler  for not   found  SET done =1;
	OPEN cur1;
		Fetch cur1 into tmp_grammeid,target_pool_id;
			loop1: while  done<>1 DO
				call leads_singlerecycle_highsea_rule(tmp_from_pool_id,target_pool_id,tmp_grammeid);
				call leads_singlerecycle_highsea_rule_beforeremind(tmp_from_pool_id,tmp_grammeid);
		Fetch cur1 into tmp_grammeid,target_pool_id;
	end while loop1;
	close cur1;
end ||
delimiter;


DROP PROCEDURE IF EXISTS `leads_singlerecycle_normal`;
delimiter ||
CREATE  PROCEDURE `leads_singlerecycle_normal`()
BEGIN

	DECLARE normal_id int(11);
	DECLARE var_pool_id int(11);
	declare done  int  default 0;
	declare cur1 CURSOR FOR select id,pool_id from ld_leads_normal where active = 'yes' ORDER BY sequence;
	declare continue handler  for not   found  SET done =1;
		OPEN cur1;
			Fetch cur1 into normal_id,var_pool_id;
			loop1: while  done<>1 DO

				if normal_id > 0 THEN
						call leads_singlerecycle_normal_rule(normal_id,var_pool_id);
						call leads_singlerecycle_normal_rule_beforeremind(normal_id,var_pool_id);
				end IF;

    	Fetch cur1 into normal_id,var_pool_id;
    	end while loop1;
    close cur1;

end ||
delimiter;



drop PROCEDURE if EXISTS leads_singlerecycle_normal_rule;
delimiter ||
create PROCEDURE leads_singlerecycle_normal_rule(new_normal_id 	int(11),new_pool_id 	int(11))
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
	declare var_leadsidcolumnname varchar(100);
	declare cur1 CURSOR FOR select tabname,ld_leads_set_rule.columnname,ld_field.tablename ,
     ld_leads_set_rule.iscycle,`condition`,ld_leads_set_rule.days
     ,ld_leads_set_rule.otherwhere from ld_leads_set_rule  inner join ld_tab on ld_tab.name=ld_leads_set_rule.tabname and (presence in(0,2) or ld_leads_set_rule.tabname='singin')
		INNER JOIN ld_field on ld_field.tabid=ld_tab.tabid and ld_leads_set_rule.columnname=ld_field.columnname
    and ld_field.presence in(0,2) where ld_leads_set_rule.type='normal' and ld_leads_set_rule.`status`='active' and programmeid = new_normal_id;

declare continue handler  for not   found  SET done =1;

IF EXISTS (SELECT 1 FROM ld_leads_public WHERE show_account_rule='yes') THEN
		set @tmpint=0;
		set @tmpsql='';
		select max(ld_leads_set_rule.days) into @maxdays
		from ld_leads_set_rule  inner join ld_tab on ld_tab.name=ld_leads_set_rule.tabname and (presence in(0,2) or ld_leads_set_rule.tabname='singin')
                        INNER JOIN ld_field on ld_field.tabid=ld_tab.tabid and ld_leads_set_rule.columnname=ld_field.columnname
    and ld_field.presence in(0,2) where ld_leads_set_rule.type='normal' and ld_leads_set_rule.`status`='active' and programmeid = new_normal_id;
		
		select recycleselect into @recycleselect from ld_leads_normal where id = new_normal_id;
		set @leads_rule_pool_id = new_pool_id;

		if @recycleselect is not null and @recycleselect<>'' then
							set @recycleselect=concat( '( ', @recycleselect,' ) as recyclewheretableset ');
		end if;
OPEN cur1;

Fetch cur1 into var_tabname,var_columnname,var_tablename,var_iscycle,var_condition,var_days,var_otherwhere;
loop1: while  done<>1 DO
    			if var_tablename='ld_singin' THEN
    					set var_smownercolumn='userid';
							set var_leadsidcolumnname='record';
					else
    				set	var_smownercolumn='smownerid' ;
						set var_leadsidcolumnname='leads_id';
					end if;
    		  if(var_condition='and' ) then

    			set @tmpsqlone =concat("select ld_leads.leadsid,ld_leads.distributiondate,ld_leads.createdtime from ld_leads ");
    			set @tmpsqlone=concat(@tmpsqlone," inner join ",var_tablename,' on ',var_tablename,'.',var_leadsidcolumnname,'=ld_leads.leadsid' );
    			set @tmpsqltwo=concat(@tmpsqltwo," and  ",var_tablename,'.',var_smownercolumn,'=ld_leads.smownerid ');

    			 set @tmpsqlone=concat(@tmpsqlone," where   ",var_tablename,".deleted=0  ");
    		   if var_otherwhere is not null and  var_otherwhere<>'' then
    					set @tmpsqlone=concat(@tmpsqlone,var_otherwhere);
					end if;

    		  if var_iscycle ='yes' then
    				 set @tmpsqlone=concat( @tmpsqlone,' group by ld_leads.leadsid ') ;
    				set @tmpsqlone=concat(@tmpsqlone,"   having    datediff(curdate(),case when   IF(IFNULL(ld_leads.distributiondate,'0000-00-00')<='1600-00-00',ld_leads.createdtime,ld_leads.distributiondate)>    max(",var_tablename,'.',var_columnname,") then  IF(IFNULL(ld_leads.distributiondate,'0000-00-00')<='1600-00-00',ld_leads.createdtime,ld_leads.distributiondate)  else max(",var_tablename,'.',var_columnname,") end  ) >",var_days   );
					else
    				set @tmpsqlone=concat(@tmpsqlone," and IF(IFNULL(ld_leads.distributiondate,'0000-00-00')<='1600-00-00',ld_leads.createdtime,ld_leads.distributiondate)<=",var_tablename,'.',var_columnname);
    				 set @tmpsqlone=concat( @tmpsqlone,' group by ld_leads.leadsid ') ;
    				set @tmpsqlone=concat(@tmpsqlone,"  having datediff(min( ",var_tablename,'.',var_columnname,"),IF(IFNULL(ld_leads.distributiondate,'0000-00-00')<='1600-00-00',ld_leads.createdtime,ld_leads.distributiondate))>",var_days);

					end if;
          set @tmpsqltwo=concat('select ld_leads.leadsid,ld_leads.distributiondate,ld_leads.createdtime from  ld_leads LEFT JOIN(select ld_leads.leadsid
    					from ld_leads inner join ',var_tablename,' on ld_leads.leadsid=',var_tablename,'.',var_leadsidcolumnname,'
    						and ld_leads.smownerid=',var_tablename,'.',var_smownercolumn,'  where ',var_tablename,'.deleted=0' );

    		   if var_otherwhere is not null and  var_otherwhere<>'' then
    					set @tmpsqltwo=concat(@tmpsqltwo, var_otherwhere);
					end if;
    			set @tmpsqltwo=concat(@tmpsqltwo,' ) 	as ttt_',var_tablename,'  on ld_leads.leadsid=ttt_',var_tablename,'.leadsid   where ttt_',var_tablename,'.leadsid is null  ' );
    			set @tmpsqltwo=concat(@tmpsqltwo," having datediff(curdate(),IF(IFNULL(ld_leads.distributiondate,'0000-00-00')<='1600-00-00',ld_leads.createdtime,ld_leads.distributiondate) ) >",var_days);


    			set @tmpthree=concat( @tmpsqlone,' union all ',@tmpsqltwo);
    			set @tmpsql=concat(@tmpsql," select * from ( ",@tmpthree," ) as  tttt_",var_tabname);
    			set @tmpsql=concat(@tmpsql,' union all ' );

    			elseif (var_condition='or')  then
    				set @tmpsql=concat(@tmpsql ,' select ld_leads.leadsid,ld_leads.distributiondate,ld_leads.createdtime from ld_leads inner join '  ,var_tablename,' on ',var_tablename,'.',var_leadsidcolumnname,'=ld_leads.leadsid  ');
    			  set @tmpsql=concat(@tmpsql,' and ' ,var_tablename,'.',var_smownercolumn,'=ld_leads.smownerid ' );
    				set @tmpsql=concat(@tmpsql,' where  ' , var_tablename,'.deleted=0 ' );
    				if var_otherwhere is not null and  var_otherwhere<>'' then
    					set @tmpsql=concat(@tmpsql,var_otherwhere);
						end if;

    				if var_iscycle='yes' then
    					set @tmpsql=concat(@tmpsql," group by ld_leads.leadsid ");
    						set @tmpsql=concat(@tmpsql," having datediff(curdate(), case when  IF(IFNULL(ld_leads.distributiondate,'0000-00-00')<='1600-00-00',ld_leads.createdtime,ld_leads.distributiondate)>max( ", var_tablename,'.',var_columnname,") then  IF(IFNULL(ld_leads.distributiondate,'0000-00-00')<='1600-00-00',ld_leads.createdtime,ld_leads.distributiondate)   else  max( ", var_tablename,'.',var_columnname,") end )<= ",var_days);
							else
    						set @tmpsqlone=concat(@tmpsql," and IF(IFNULL(ld_leads.distributiondate,'0000-00-00')<='1600-00-00',ld_leads.createdtime,ld_leads.distributiondate)<=",var_tablename,'.',var_columnname);
    						set @tmpsql=concat(@tmpsql," group by ld_leads.leadsid ");
    						set @tmpsqlone=concat(@tmpsql,"  having datediff(min( ",var_tablename,'.',var_columnname,"),IF(IFNULL(ld_leads.distributiondate,'0000-00-00')<='1600-00-00',ld_leads.createdtime,ld_leads.distributiondate))<=",var_days);
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

    				set @TMPSQL_ONE=concat( ' select "系统","LOGPUBLICNORMAL",now(), ld_leads.leadsid,ld_leads.pool_id  from ld_leads left join ( ',@tmpsql,' ) as lingdangtmp  on  lingdangtmp.leadsid=ld_leads.leadsid ') ;
						set @TMPSQL_LOG_ONE=concat( ' select "系统","LOGPUBLICNORMAL",now(), ld_leads.leadsid,ld_leads.pool_id,ld_leads.smownerid,"',new_normal_id,'" as log_grammeid  from ld_leads left join ( ',@tmpsql,' ) as lingdangtmp  on  lingdangtmp.leadsid=ld_leads.leadsid ') ;
    			if @recycleselect<>'' and @recycleselect is not null THEN
    				set @TMPSQL_ONE=concat(@TMPSQL_ONE,' left join ',@recycleselect,' on recyclewheretableset.leadsid=ld_leads.leadsid ');
						set @TMPSQL_LOG_ONE=concat(@TMPSQL_LOG_ONE,' left join ',@recycleselect,' on recyclewheretableset.leadsid=ld_leads.leadsid ');
					end if;
    			 set @TMPSQL_TWO=concat(' where ld_leads.deleted=0 and( ifnull(ld_leads.publicaccount,0)<1)'  );
    				set @TMPSQL_TWO=concat(@TMPSQL_TWO, " and lingdangtmp.leadsid is null  and datediff(curdate(),case when ifnull(ld_leads.distributiondate,'')='' then ld_leads.createdtime else ld_leads.distributiondate end)>",@maxdays);
    				if @recycleselect<>'' and @recycleselect is not null THEN
    					set @TMPSQL_TWO=concat(@TMPSQL_TWO, ' and recyclewheretableset.leadsid is not null ');
					end if;
	else
    			 if @recycleselect is not null and @recycleselect<>'' then

    					set @sql=concat(' select tmpone.leadsid from  (',@tmpsql, ' ) as tmpone inner join ',@recycleselect,' on tmpone.leadsid=recyclewheretableset.leadsid  group by tmpone.leadsid ') ;
						ELSE
    					set @sql=concat(' select leadsid from (',@tmpsql, ') as tmpone group by leadsid ') ;
					end if;

    				set @TMPSQL_ONE=concat( ' select "系统","LOGPUBLICNORMAL",now(), ld_leads.leadsid,ld_leads.pool_id  from ld_leads inner join ( ',@sql,' ) as lingdangtmp  on  lingdangtmp.leadsid=ld_leads.leadsid ') ;
						set @TMPSQL_LOG_ONE=concat( ' select "系统","LOGPUBLICNORMAL",now(), ld_leads.leadsid,ld_leads.pool_id,ld_leads.smownerid,"',new_normal_id,'" as log_grammeid   from ld_leads inner join ( ',@sql,' ) as lingdangtmp  on  lingdangtmp.leadsid=ld_leads.leadsid ') ;
    				set @TMPSQL_TWO=concat(' where ld_leads.deleted=0 and( ifnull(ld_leads.publicaccount,0)<1)'  );
	end if;
				set @TMPSQL_LOG_TWO = concat(@TMPSQL_LOG_ONE,@TMPSQL_TWO);
				set @TMPSQL_TWO = concat(@TMPSQL_ONE,@TMPSQL_TWO);
    	   set @TMPSQL_THREE=concat('insert into ld_logpublicleads(username,operation,opdate,leadsid,pool_id,old_smownerid,programmeid) ',@TMPSQL_LOG_TWO);
prepare stmt from @TMPSQL_THREE;
execute stmt;
deallocate prepare stmt;


		set @tmp_namelink='\'<a style="display: initial;" doubleclick="yes" onclick="ListReferenceLinkClick(ld(this),event)" referencemodule="Leads" referencerecord="\',ld_leads.leadsid,\'">\',ld_leads.accountname,\'</a>\'';
	if var_condition='or'  then
    			 set @TMPSQL_ONE=concat( ' select "normal" as type, GROUP_CONCAT(',@tmp_namelink,' separator "<br>")as leadsnames,count(ld_leads.leadsid)  as totalleadss,ld_leads.smownerid from    ld_leads left join ( ',@tmpsql,' ) as lingdangtmp  on  lingdangtmp.leadsid=ld_leads.leadsid ') ;
				 if @recycleselect<>'' and @recycleselect is not null THEN
    				set @TMPSQL_ONE=concat(@TMPSQL_ONE,' left join ',@recycleselect,' on recyclewheretableset.leadsid=ld_leads.leadsid ');
				end if;
    			set @TMPSQL_TWO=concat(@TMPSQL_ONE,' where ld_leads.deleted=0 and( ifnull(ld_leads.publicaccount,0)<1)    ');
    		   set @TMPSQL_TWO=concat(@TMPSQL_TWO, " and lingdangtmp.leadsid is null and datediff(curdate(),case when ifnull(ld_leads.distributiondate,'')='' then ld_leads.createdtime else ld_leads.distributiondate end)>",@maxdays);
    			if @recycleselect<>'' and @recycleselect is not null THEN
    					set @TMPSQL_TWO=concat(@TMPSQL_TWO, ' and recyclewheretableset.leadsid is not null  ');
				end if;
    			set @TMPSQL_TWO=concat(@TMPSQL_TWO," group by ld_leads.smownerid ");
		else
    			set @TMPSQL_ONE=concat( ' select "normal" as type, GROUP_CONCAT(',@tmp_namelink,' separator "<br>")as leadsnames,count(ld_leads.leadsid)  as totalleadss,ld_leads.smownerid from    ld_leads  inner join ( ',@sql,' ) as lingdangtmp  on  lingdangtmp.leadsid=ld_leads.leadsid ') ;
    		   set @TMPSQL_TWO=concat(@TMPSQL_ONE,' where ld_leads.deleted=0 and( ifnull(ld_leads.publicaccount,0)<1) group by ld_leads.smownerid    ');
		end if;

delete from ld_publicleads_remindtableview ;

set @tmpthree=concat(" insert into ld_publicleads_remindtableview(type,names,totalleads,smownerid )  ", @TMPSQL_TWO);
prepare stmt from @tmpthree;
execute stmt;
deallocate prepare stmt;

call crm_publicleads_recoveryreminds();


if var_condition='or'  then
    			  	set @TMPSQL_ONE=concat( ' update  ld_leads left join ( ',@tmpsql,' ) as lingdangtmp  on  lingdangtmp.leadsid=ld_leads.leadsid ');

    		      if @recycleselect<>'' and @recycleselect is not null THEN
    						set @TMPSQL_ONE=concat(@TMPSQL_ONE,' left join ',@recycleselect,' on recyclewheretableset.leadsid=ld_leads.leadsid ');
							end if;
    				set @TMPSQL_ONE =concat(@TMPSQL_ONE,' set ld_leads.publicaccount=1,ld_leads.pool_id=',@leads_rule_pool_id,' ,protectdate=null ,allocatedate=null') ;

    					set @TMPSQL_TWO=concat(@TMPSQL_ONE,' where ld_leads.deleted=0 and( ifnull(ld_leads.publicaccount,0)<1)');
    		      set @TMPSQL_TWO=concat(@TMPSQL_TWO, " and lingdangtmp.leadsid is null and datediff(curdate(),case when ifnull(ld_leads.distributiondate,'')='' then ld_leads.createdtime else ld_leads.distributiondate end)>",@maxdays);
    					if @recycleselect<>'' and @recycleselect is not null THEN
    					   set @TMPSQL_TWO=concat(@TMPSQL_TWO, ' and recyclewheretableset.leadsid is not null  ');
							end if;
ELSE
    				set @TMPSQL_ONE=concat( ' update  ld_leads inner join ( ',@sql,' ) as lingdangtmp  on  lingdangtmp.leadsid=ld_leads.leadsid set ld_leads.publicaccount=1,ld_leads.pool_id=',@leads_rule_pool_id,' ,protectdate=null ,allocatedate=null') ;
    		    set @TMPSQL_TWO=concat(@TMPSQL_ONE,' where ld_leads.deleted=0 and( ifnull(ld_leads.publicaccount,0)<1)');

end if;
prepare stmt from @TMPSQL_TWO;
execute stmt;
deallocate prepare stmt;

end if;
END IF;

end ||
delimiter;


drop PROCEDURE if EXISTS leads_singlerecycle_normal_rule_beforeremind;
delimiter ||
create PROCEDURE leads_singlerecycle_normal_rule_beforeremind(new_normal_id 	int(11),new_pool_id 	int(11))
    label_a:BEGIN

	DECLARE var_tabname varchar(100);
	DECLARE var_columnname varchar(100);
	DECLARE var_tablename varchar(100);
	DECLARE var_condition varchar(50);
	DECLARE var_smownercolumn varchar(50);
	declare var_leadsidcolumnname varchar(100);
	declare var_iscycle varchar(50);
	DECLARE var_days int(11);
	DECLARE var_otherwhere varchar(200);
	declare done  int  default 0;

	declare cur1 CURSOR FOR select tabname,ld_leads_set_rule.columnname,ld_field.tablename ,
                                   ld_leads_set_rule.iscycle,`condition`,ld_leads_set_rule.days
                                                                                                                                                                        ,ld_leads_set_rule.otherwhere from ld_leads_set_rule  inner join ld_tab on ld_tab.name=ld_leads_set_rule.tabname and (presence in(0,2) or ld_leads_set_rule.tabname='singin')
                                                                                                                                                                                                                              INNER JOIN ld_field on ld_field.tabid=ld_tab.tabid and ld_leads_set_rule.columnname=ld_field.columnname
    and ld_field.presence in(0,2) where ld_leads_set_rule.type='normal' and ld_leads_set_rule.`status`='active' and programmeid = new_normal_id;

declare continue handler  for not   found  SET done =1;

    IF EXISTS (SELECT 1 FROM ld_leads_public WHERE show_account_rule='yes') THEN
    	set @tmpint=0;
    	set @tmpsql='';
	select max(ld_leads_set_rule.days) into @maxdays
	from ld_leads_set_rule  inner join ld_tab on ld_tab.name=ld_leads_set_rule.tabname and (presence in(0,2) or ld_leads_set_rule.tabname='singin')
                        INNER JOIN ld_field on ld_field.tabid=ld_tab.tabid and ld_leads_set_rule.columnname=ld_field.columnname
    and ld_field.presence in(0,2) where ld_leads_set_rule.type='normal' and ld_leads_set_rule.`status`='active' and programmeid = new_normal_id;
		
		set @leads_rule_pool_id = new_pool_id;
		select recycleselect,beforereminddays into @recycleselect,@var_beforereminddays from ld_leads_normal where id = new_normal_id;

		if @var_beforereminddays='' or @var_beforereminddays is null or @var_beforereminddays=0 then
						leave label_a ;
		end if;
       set @maxdays=@maxdays-@var_beforereminddays;

    	if @recycleselect is not null and @recycleselect<>'' then
    			set @recycleselect=concat( '( ', @recycleselect,' ) as recyclewheretableset ');
end if;
OPEN cur1;

Fetch cur1 into var_tabname,var_columnname,var_tablename,var_iscycle,var_condition,var_days,var_otherwhere;
loop1: while  done<>1 DO

    			if var_tablename='ld_singin' THEN
    					set var_smownercolumn='userid';
						  set	var_leadsidcolumnname='record' ;
else
    				set	var_smownercolumn='smownerid' ;
					   set	var_leadsidcolumnname='leads_id' ;
end if;
    			 set var_days=var_days-@var_beforereminddays;
    			if var_days<=0 THEN
    				leave loop1;
end if;
    		  if(var_condition='and' ) then

    			set @tmpsqlone =concat("select ld_leads.leadsid,ld_leads.distributiondate,ld_leads.createdtime, '",var_tabname,"' as remindtabname from ld_leads ");
    			set @tmpsqlone=concat(@tmpsqlone," inner join ",var_tablename,' on ',var_tablename,'.',var_leadsidcolumnname,'=ld_leads.leadsid' );
    			set @tmpsqltwo=concat(@tmpsqltwo," and  ",var_tablename,'.',var_smownercolumn,'=ld_leads.smownerid ');

    			 set @tmpsqlone=concat(@tmpsqlone," where   ",var_tablename,".deleted=0  ");
    		   if var_otherwhere is not null and  var_otherwhere<>'' then
    					set @tmpsqlone=concat(@tmpsqlone,var_otherwhere);
end if;

    		  if var_iscycle ='yes' then
    				 set @tmpsqlone=concat( @tmpsqlone,' group by ld_leads.leadsid ') ;
    				set @tmpsqlone=concat(@tmpsqlone,"   having    datediff(curdate(),case when   IF(IFNULL(ld_leads.distributiondate,'0000-00-00')<='1600-00-00',ld_leads.createdtime,ld_leads.distributiondate)>    max(",var_tablename,'.',var_columnname,") then  IF(IFNULL(ld_leads.distributiondate,'0000-00-00')<='1600-00-00',ld_leads.createdtime,ld_leads.distributiondate)  else max(",var_tablename,'.',var_columnname,") end  ) >",var_days   );
else
    				set @tmpsqlone=concat(@tmpsqlone," and IF(IFNULL(ld_leads.distributiondate,'0000-00-00')<='1600-00-00',ld_leads.createdtime,ld_leads.distributiondate)<=",var_tablename,'.',var_columnname);
    				 set @tmpsqlone=concat( @tmpsqlone,' group by ld_leads.leadsid ') ;
    				set @tmpsqlone=concat(@tmpsqlone,"  having datediff(min( ",var_tablename,'.',var_columnname,"),IF(IFNULL(ld_leads.distributiondate,'0000-00-00')<='1600-00-00',ld_leads.createdtime,ld_leads.distributiondate))>",var_days);

end if;

               set @tmpsqltwo=concat("select ld_leads.leadsid,ld_leads.distributiondate,ld_leads.createdtime , '",var_tabname,"' as remindtabname from ld_leads LEFT JOIN (select ld_leads.leadsid from ld_leads inner join ",var_tablename,' on ld_leads.leadsid=',
                    var_tablename,'.leadsid and ld_leads.smownerid=',var_tablename,'.',var_smownercolumn,'  where ',var_tablename,'.deleted=0');

    		   if var_otherwhere is not null and  var_otherwhere<>'' then
    					set @tmpsqltwo=concat(@tmpsqltwo, var_otherwhere);
end if;
    			set @tmpsqltwo=concat(@tmpsqltwo,' ) 	as ttt_',var_tablename,'  on ld_leads.leadsid=ttt_',var_tablename,'.leads_id   where ttt_',var_tablename,'.leads_id is null  ' );
    			set @tmpsqltwo=concat(@tmpsqltwo," having datediff(curdate(),IF(IFNULL(ld_leads.distributiondate,'0000-00-00')<='1600-00-00',ld_leads.createdtime,ld_leads.distributiondate) ) >",var_days);


    			set @tmpthree=concat( @tmpsqlone,' union all ',@tmpsqltwo);
    			set @tmpsql=concat(@tmpsql," select * from ( ",@tmpthree," ) as  tttt_",var_tabname);
    			set @tmpsql=concat(@tmpsql,' union all ' );

    			elseif (var_condition='or')  then
    				set @tmpsql=concat(@tmpsql ," select ld_leads.leadsid,ld_leads.distributiondate,ld_leads.createdtime, '",var_tabname,"' as remindtabname from ld_leads inner join "  ,var_tablename,' on ',var_tablename,'.',var_leadsidcolumnname,'=ld_leads.leadsid  ');
    			  set @tmpsql=concat(@tmpsql,' and ' ,var_tablename,'.',var_smownercolumn,'=ld_leads.smownerid ' );
    				set @tmpsql=concat(@tmpsql,' where  ' , var_tablename,'.deleted=0 ' );
    				if var_otherwhere is not null and  var_otherwhere<>'' then
    					set @tmpsql=concat(@tmpsql,var_otherwhere);
end if;

    				if var_iscycle='yes' then
    					set @tmpsql=concat(@tmpsql," group by ld_leads.leadsid ");
    						set @tmpsql=concat(@tmpsql," having datediff(curdate(), case when  IF(IFNULL(ld_leads.distributiondate,'0000-00-00')<='1600-00-00',ld_leads.createdtime,ld_leads.distributiondate)>max( ", var_tablename,'.',var_columnname,") then  IF(IFNULL(ld_leads.distributiondate,'0000-00-00')<='1600-00-00',ld_leads.createdtime,ld_leads.distributiondate)   else  max( ", var_tablename,'.',var_columnname,") end )<= ",var_days);
else
    						set @tmpsqlone=concat(@tmpsql," and IF(IFNULL(ld_leads.distributiondate,'0000-00-00')<='1600-00-00',ld_leads.createdtime,ld_leads.distributiondate)<=",var_tablename,'.',var_columnname);
    						set @tmpsql=concat(@tmpsql," group by ld_leads.leadsid ");
    						set @tmpsqlone=concat(@tmpsql,"  having datediff(min( ",var_tablename,'.',var_columnname,"),IF(IFNULL(ld_leads.distributiondate,'0000-00-00')<='1600-00-00',ld_leads.createdtime,ld_leads.distributiondate))<=",var_days);
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
    				 set @TMP_TMPTable=" ( select  concat('(',GROUP_CONCAT(ld_tranlabel.fieldlabel),')')  from ld_leads_set_rule
    									INNER JOIN ld_tab on ld_tab.name=ld_leads_set_rule.tabname
    									INNER JOIN ld_tranlabel on ld_tab.tabid=ld_tranlabel.tabid
    									and ld_tab.tabid=ld_tranlabel.Relateid and languagetype='zh' and trantable='ld_tab'
    										where type='complete' and ld_leads_set_rule.status='active' and ld_leads_set_rule.status='active' ORDER BY ld_leads_set_rule.sequence asc ) ";
						set @tmp_namelink=concat('\'<a style="display: initial;" doubleclick="yes" onclick="ListReferenceLinkClick(ld(this),event)" referencemodule="Leads" referencerecord="\',ld_leads.leadsid,\'">\',ld_leads.accountname,',@TMP_TMPTable,',\'</a>\'');
    				set @sql=concat(' select leadsid from (',@tmpsql, ') as tmpone group by leadsid ') ;

    				set @TMPSQL_ONE=concat( ' select "normal", group_concat(',@tmp_namelink,' separator "<br>" )  as accouontnames ,count(distinct ld_leads.leadsid)  as totalleadss,ld_leads.smownerid from ld_leads left join ( ',@sql,' ) as lingdangtmp  on  lingdangtmp.leadsid=ld_leads.leadsid ') ;
    				if @recycleselect<>'' and @recycleselect is not null THEN
    					set @TMPSQL_ONE=concat(@TMPSQL_ONE,' left join ',@recycleselect,' on recyclewheretableset.leadsid=ld_leads.leadsid ');
end if;
    				 set @TMPSQL_TWO=concat(@TMPSQL_ONE,' where ld_leads.deleted=0 and( ifnull(ld_leads.publicaccount,0)<1)');
    					set @TMPSQL_TWO=concat(@TMPSQL_TWO, " and lingdangtmp.leadsid is null  and datediff(curdate(),case when ifnull(ld_leads.distributiondate,'')='' then ld_leads.createdtime else ld_leads.distributiondate end)>",@maxdays);
    					if @recycleselect<>'' and @recycleselect is not null THEN
    						set @TMPSQL_TWO=concat(@TMPSQL_TWO, ' and recyclewheretableset.leadsid is not null ');
end if;
    				 set @TMPSQL_TWO=concat(@TMPSQL_TWO," group by ld_leads.smownerid ");

else
    				if @recycleselect is not null and @recycleselect<>'' then

    					set @sql=concat(' select tmpone.leadsid,GROUP_CONCAT(ld_tranlabel.fieldlabel) as fieldlabel from  (',@tmpsql, ' ) as tmpone
    												inner join ',@recycleselect,' on tmpone.leadsid=recyclewheretableset.leadsid
    												inner join ld_tab on ld_tab.name=tmpone.remindtabname
    										 	INNER JOIN ld_tranlabel on ld_tab.tabid=ld_tranlabel.tabid
    										  and ld_tab.tabid=ld_tranlabel.Relateid and languagetype="zh" and trantable="ld_tab"
    											 group by leadsid ') ;
ELSE
    					set @sql=concat(' select leadsid,GROUP_CONCAT(ld_tranlabel.fieldlabel) as fieldlabel from (',@tmpsql, ') as tmpone
    											inner join ld_tab on ld_tab.name=tmpone.remindtabname
    											INNER JOIN ld_tranlabel on ld_tab.tabid=ld_tranlabel.tabid
    										  and ld_tab.tabid=ld_tranlabel.Relateid and languagetype="zh" and trantable="ld_tab"
    											 group by leadsid') ;
end if;
						set @tmp_namelink=concat('\'<a style="display: initial;" doubleclick="yes" onclick="ListReferenceLinkClick(ld(this),event)" referencemodule="Leads" referencerecord="\',ld_leads.leadsid,\'">\',ld_leads.accountname,lingdangtmp.fieldlabel,\'</a>\'');
    				set @TMPSQL_ONE=concat( ' select "normal",  GROUP_CONCAT(',@tmp_namelink,' separator "<br>")as accountname,count(distinct ld_leads.leadsid)  as totalleadss,ld_leads.smownerid from    ld_leads  inner join ( ',@sql,' ) as lingdangtmp  on  lingdangtmp.leadsid=ld_leads.leadsid ') ;
    				set @TMPSQL_TWO=concat(@TMPSQL_ONE,' where ld_leads.deleted=0 and( ifnull(ld_leads.publicaccount,0)<1) group by ld_leads.smownerid'  );
end if;

delete from ld_publicleads_remindtableview ;
set @tmpthree=concat(" insert into ld_publicleads_remindtableview(type,names,totalleads,smownerid )  ", @TMPSQL_TWO);
prepare stmt from @tmpthree;
execute stmt;
deallocate prepare stmt;

call crm_publicleads_beforereminds();
end if;
END IF;

end ||
delimiter;



-- 公海线索回收
drop PROCEDURE if EXISTS leads_singlerecycle_highsea_rule;
delimiter ||
create PROCEDURE leads_singlerecycle_highsea_rule(IN tmp_pool_id INT(11),IN target_pool_id INT(11),IN tmp_grammeid INT(11))
    label_a:BEGIN

	DECLARE var_tabname varchar(100);
	DECLARE var_columnname varchar(100);
	DECLARE var_tablename varchar(100);
	DECLARE var_condition varchar(50);
	DECLARE var_smownercolumn varchar(50);
	declare var_leadsidcolumnname varchar(100);
	DECLARE var_days int(11);
	DECLARE var_otherwhere varchar(200);
	declare var_iscycle varchar(100);
	declare done  int  default 0;

	declare cur1 CURSOR FOR select tabname,ld_leads_set_rule.columnname,ld_field.tablename ,ld_leads_set_rule.iscycle, `condition`,ld_leads_set_rule.days
                                 ,ld_leads_set_rule.otherwhere from ld_leads_set_rule  inner join ld_tab on ld_tab.name=ld_leads_set_rule.tabname and (presence in(0,2) or ld_leads_set_rule.tabname='singin')
                                                                                       INNER JOIN ld_field on ld_field.tabid=ld_tab.tabid and ld_leads_set_rule.columnname=ld_field.columnname
    and (ld_field.presence in(0,2) ) where ld_leads_set_rule.type='complete' and ld_leads_set_rule.`status`='active' and programmeid = tmp_grammeid;
	declare continue handler  for not   found  SET done =1;
	set @tmpint=0;
	set @tmpsql='';
	
	select max(ld_leads_set_rule.days) into @maxdays
	from ld_leads_set_rule  inner join ld_tab on ld_tab.name=ld_leads_set_rule.tabname and (presence in(0,2) or ld_leads_set_rule.tabname='singin')
													INNER JOIN ld_field on ld_field.tabid=ld_tab.tabid and ld_leads_set_rule.columnname=ld_field.columnname and ld_field.presence in(0,2)
	where ld_leads_set_rule.type='complete' and ld_leads_set_rule.`status`='active' and programmeid = tmp_grammeid;

	select IF(ld_users.id>0,transfer_users,0) into @allotaccount from 
		ld_module_recovery_programme LEFT join ld_users on ld_users.id=transfer_users
		where modulename = 'Leads' and ld_module_recovery_programme.programmeid = tmp_grammeid;
	
	if  ifnull(@allotaccount,0)=0  then
				set @allotaccount=0;
	end if;
	select recycleselect into @recycleselect from ld_module_recovery_programme where programmeid = tmp_grammeid;

	if @recycleselect is not null and @recycleselect<>'' then
				set @recycleselect=concat( '( ', @recycleselect,' ) as recyclewheretableset ');
	end if;
	
OPEN cur1;

Fetch cur1 into var_tabname,var_columnname,var_tablename,var_iscycle,var_condition,var_days,var_otherwhere;
loop1: while  done<>1 DO
			if var_tablename='ld_singin' THEN
					set var_smownercolumn='userid';
					set var_leadsidcolumnname='record';
else
				set	var_smownercolumn='smownerid' ;
				set var_leadsidcolumnname='leads_id';
end if;
		  if(var_condition='and' ) then

					set @tmpsqlone =concat("select ld_leads.leadsid,ld_leads.allocatedate from ld_leads ");
					set @tmpsqlone=concat(@tmpsqlone," inner join ",var_tablename,' on ',var_tablename,'.',var_leadsidcolumnname,'=ld_leads.leadsid ');
					set @tmpsqlone=concat(@tmpsqlone," and  ",var_tablename,'.',var_smownercolumn,'=ld_leads.smownerid' );

					set @tmpsqlone=concat(@tmpsqlone ,"  where  ",var_tablename,".deleted=0");
					 if var_otherwhere is not null and  var_otherwhere<>'' then
							set @tmpsqlone=concat(@tmpsqlone,var_otherwhere);
end if;

					if var_iscycle='yes' then
							set @tmpsqlone=concat( @tmpsqlone,' group by ld_leads.leadsid ') ;
							set @tmpsqlone=concat(@tmpsqlone,"   having datediff(curdate(), case when ld_leads.allocatedate> max( " ,var_tablename,'.',var_columnname," )  then ld_leads.allocatedate else max( " ,var_tablename,'.',var_columnname," ) end  ) >",var_days);
else
							set @tmpsqlone=concat(@tmpsqlone," and ld_leads.allocatedate<=",var_tablename,'.',var_columnname);
							set @tmpsqlone=concat( @tmpsqlone,' group by ld_leads.leadsid ') ;
							set @tmpsqlone=concat(@tmpsqlone,"  having  datediff(min( ",var_tablename,'.',var_columnname,"),ld_leads.allocatedate)>",var_days);
end if;
					set @tmpsqltwo=concat('select ld_leads.leadsid,ld_leads.allocatedate from  ld_leads LEFT JOIN(select ld_leads.leadsid
							from ld_leads inner join ',var_tablename,' on ld_leads.leadsid=',var_tablename,'.',var_leadsidcolumnname,'
								and ld_leads.smownerid=',var_tablename,'.',var_smownercolumn,'  where ',var_tablename,'.deleted=0' );

					 if var_otherwhere is not null and  var_otherwhere<>'' then
							set @tmpsqltwo=concat(@tmpsqltwo, var_otherwhere);
end if;
					set @tmpsqltwo=concat(@tmpsqltwo,' ) 	as ttt_',var_tablename,'  on ld_leads.leadsid=ttt_',var_tablename,'.leadsid   where ttt_',var_tablename,'.leadsid is null  ' );
					set @tmpsqltwo=concat(@tmpsqltwo," having datediff(curdate(),ld_leads.allocatedate ) >",var_days);

					set @tmpthree=concat( @tmpsqlone,' union all ',@tmpsqltwo);
					set @tmpsql=concat(@tmpsql," select * from ( ",@tmpthree," ) as  tttt_",var_tabname);
					set @tmpsql=concat(@tmpsql,' union all ' );

			elseif (var_condition='or')  then
				set @tmpsql=concat(@tmpsql ,' select ld_leads.leadsid,ld_leads.allocatedate from ld_leads inner join '  ,var_tablename,' on ',var_tablename,'.',var_leadsidcolumnname,'=ld_leads.leadsid  ');

				set @tmpsql=concat(@tmpsql,' and ' ,var_tablename,'.',var_smownercolumn,'=ld_leads.smownerid ' );

				set @tmpsql=concat(@tmpsql,' where  ' , var_tablename,'.deleted=0 ' );
			  if var_otherwhere is not null and  var_otherwhere<>'' then
					set @tmpsql=concat(@tmpsql,var_otherwhere);
end if;

			  if var_iscycle='yes' then
						set @tmpsql=concat( @tmpsql,' group by ld_leads.leadsid ') ;
						set @tmpsql=concat(@tmpsql," having    datediff ( curdate(), case when ld_leads.allocatedate> max( ",var_tablename,'.',var_columnname," ) then ld_leads.allocatedate else max( ",var_tablename,'.',var_columnname," )  end )<=",var_days );

ELSE
				  set @tmpsql=concat(@tmpsql," and ld_leads.allocatedate<=",var_tablename,'.',var_columnname);
					set @tmpsql=concat( @tmpsql,' group by ld_leads.leadsid ') ;
					set @tmpsql=concat(@tmpsql,"  having datediff(min( ",var_tablename,'.',var_columnname,"),ld_leads.allocatedate)<=",var_days);
end if;
				set @tmpsql=concat(@tmpsql,' union all ' );

end if;
			set @tmpint=@tmpint+1;
Fetch cur1 into var_tabname,var_columnname,var_tablename,var_iscycle,var_condition,var_days,var_otherwhere;
end while loop1;
close cur1;

if @tmpint>0 then
		set @len=CHAR_LENGTH(' union all ');
		set @tmpsql=left(@tmpsql,CHAR_LENGTH(@tmpsql)-@len);

	  if var_condition='or'  then

			set @sql=concat(' select leadsid from (',@tmpsql, ') as tmpone group by leadsid ') ;
			set @TMPSQL_ONE=concat( ' select "系统","LOGPUBLICALLOCATELEADS",now(), ld_leads.leadsid,ld_leads.pool_id  from ld_leads left join ( ',@sql,' ) as lingdangtmp  on  lingdangtmp.leadsid=ld_leads.leadsid ') ;
			set @TMPSQL_LOG_ONE=concat( ' select "系统","LOGPUBLICALLOCATELEADS",now(), ld_leads.leadsid,ld_leads.pool_id,ld_leads.smownerid,"',tmp_grammeid,'" as log_grammeid  from ld_leads left join ( ',@sql,' ) as lingdangtmp  on  lingdangtmp.leadsid=ld_leads.leadsid ') ;
			if @recycleselect<>'' and @recycleselect is not null THEN
				set @TMPSQL_ONE=concat(@TMPSQL_ONE,' left join ',@recycleselect,' on recyclewheretableset.leadsid=ld_leads.leadsid ');
				set @TMPSQL_LOG_ONE=concat(@TMPSQL_ONE,' left join ',@recycleselect,' on recyclewheretableset.leadsid=ld_leads.leadsid ');
			end if;
		  set @TMPSQL_TWO=concat(' where ld_leads.deleted=0 and( ld_leads.publicaccount=2 or ld_leads.publicaccount=3) and ld_leads.pool_id =  ',tmp_pool_id);

			set @TMPSQL_TWO=concat(@TMPSQL_TWO,' and lingdangtmp.leadsid is null  and datediff(curdate(),ld_leads.allocatedate)>',@maxdays);

			if @recycleselect<>'' and @recycleselect is not null THEN
					set @TMPSQL_TWO=concat(@TMPSQL_TWO, ' and recyclewheretableset.leadsid is not null  ');
			end if;
else
				if @recycleselect is not null and @recycleselect<>'' then

					set @sql=concat(' select tmpone.leadsid from  (',@tmpsql, ' ) as tmpone inner join ',@recycleselect,' on tmpone.leadsid=recyclewheretableset.leadsid  group by tmpone.leadsid ') ;
				ELSE
					set @sql=concat(' select leadsid from (',@tmpsql, ') as tmpone group by leadsid ') ;
				end if;

			set @TMPSQL_ONE=concat( ' select "系统","LOGPUBLICALLOCATELEADS",now(), ld_leads.leadsid,ld_leads.pool_id  from ld_leads inner join ( ',@sql,' ) as lingdangtmp  on  lingdangtmp.leadsid=ld_leads.leadsid ') ;
			set @TMPSQL_ONE=concat( ' select "系统","LOGPUBLICALLOCATELEADS",now(), ld_leads.leadsid,ld_leads.pool_id,ld_leads.smownerid,"',tmp_grammeid,'" as log_grammeid  from ld_leads inner join ( ',@sql,' ) as lingdangtmp  on  lingdangtmp.leadsid=ld_leads.leadsid ') ;
			set @TMPSQL_TWO=concat(' where ld_leads.deleted=0 and( ld_leads.publicaccount=2 or ld_leads.publicaccount=3) and ld_leads.pool_id = ',tmp_pool_id);

end if;
			set @TMPSQL_LOG_TWO = concat(@TMPSQL_LOG_ONE,@TMPSQL_TWO);
			set @TMPSQL_TWO = concat(@TMPSQL_ONE,@TMPSQL_TWO);
	   set @TMPSQL_THREE=concat('insert into ld_logpublicleads(username,operation,opdate,leadsid,pool_id,old_smownerid,programmeid) ',@TMPSQL_LOG_TWO);
SELECT @TMPSQL_THREE;
-- prepare stmt from @TMPSQL_THREE;
-- execute stmt;
-- deallocate prepare stmt;

set @tmp_namelink='\'<a style="display: initial;" doubleclick="yes" onclick="ListReferenceLinkClick(ld(this),event)" referencemodule="Leads" referencerecord="\',ld_leads.leadsid,\'">\',ld_leads.accountname,\'</a>\'';
    if var_condition='or'  then
			 set @TMPSQL_ONE=concat( ' select "complete" as type, GROUP_CONCAT(',@tmp_namelink,' separator "<br>")as accountnames,count(ld_leads.leadsid)  as totalaccounts,ld_leads.smownerid from    ld_leads left join ( ',@sql,' ) as lingdangtmp  on  lingdangtmp.leadsid=ld_leads.leadsid ') ;
		  if @recycleselect<>'' and @recycleselect is not null THEN
				set @TMPSQL_ONE=concat(@TMPSQL_ONE,' left join ',@recycleselect,' on recyclewheretableset.leadsid=ld_leads.leadsid ');
end if;
			set @TMPSQL_TWO=concat(@TMPSQL_ONE,' where ld_leads.deleted=0 and( ld_leads.publicaccount=2 or ld_leads.publicaccount=3)  ');
		  set @TMPSQL_TWO=concat(@TMPSQL_TWO, ' and lingdangtmp.leadsid is null  and datediff(curdate(),ld_leads.allocatedate)>',@maxdays);
		   if @recycleselect<>'' and @recycleselect is not null THEN
					set @TMPSQL_TWO=concat(@TMPSQL_TWO, ' and recyclewheretableset.leadsid is not null ');
end if;
		 set @TMPSQL_TWO=concat(@TMPSQL_TWO," group by ld_leads.smownerid ");
else
			set @TMPSQL_ONE=concat( ' select "complete" as type, GROUP_CONCAT(',@tmp_namelink,' separator "<br>")as accountnames,count(ld_leads.leadsid)  as totalaccounts,ld_leads.smownerid from    ld_leads  inner join ( ',@sql,' ) as lingdangtmp  on  lingdangtmp.leadsid=ld_leads.leadsid ') ;
		   set @TMPSQL_TWO=concat(@TMPSQL_ONE,' where ld_leads.deleted=0  and( ld_leads.publicaccount=2 or ld_leads.publicaccount=3)   group by ld_leads.smownerid    ');
end if;
delete from ld_publicleads_remindtableview ;

set @tmpthree=concat(" insert into ld_publicleads_remindtableview(type,names,totalleads,smownerid )  ", @TMPSQL_TWO);
prepare stmt from @tmpthree;
execute stmt;
deallocate prepare stmt;

call crm_publicleads_recoveryreminds();

if var_condition='or'  then

			 set @TMPSQL_ONE=concat( ' update  ld_leads left join ( ',@sql,' ) as lingdangtmp  on  lingdangtmp.leadsid=ld_leads.leadsid ');
		  if @recycleselect<>'' and @recycleselect is not null THEN
				set @TMPSQL_ONE=concat(@TMPSQL_ONE,' left join ',@recycleselect,' on recyclewheretableset.leadsid=ld_leads.leadsid ');
end if;
			set @TMPSQL_ONE=concat( @TMPSQL_ONE,' set ld_leads.publicaccount=1 ,protectdate=null ,allocatedate=null') ;
			 if @allotaccount>0 THEN
					set @TMPSQL_ONE=concat(@TMPSQL_ONE,",smownerid=",@allotaccount);
end if;
		   set @TMPSQL_TWO=concat(@TMPSQL_ONE,' where ld_leads.deleted=0 and( ld_leads.publicaccount=2 or ld_leads.publicaccount=3) and ld_leads.pool_id = ',tmp_pool_id);
		   set @TMPSQL_TWO=concat(@TMPSQL_TWO, ' and lingdangtmp.leadsid is null and datediff(curdate(),ld_leads.allocatedate)>',@maxdays);
				if @recycleselect<>'' and @recycleselect is not null THEN
						set @TMPSQL_TWO=concat(@TMPSQL_TWO, ' and recyclewheretableset.leadsid is not null  ');
end if;
ELSE

			  set @TMPSQL_ONE=concat( ' update  ld_leads inner join ( ',@sql,' ) as lingdangtmp  on  lingdangtmp.leadsid=ld_leads.leadsid set ld_leads.publicaccount=1 ,protectdate=null ,allocatedate=null') ;
		    if @allotaccount>0 THEN
					set @TMPSQL_ONE=concat(@TMPSQL_ONE,",smownerid=",@allotaccount);
				end if;
				if target_pool_id >0 then
					set @TMPSQL_ONE=concat(@TMPSQL_ONE,",ld_leads.pool_id=",target_pool_id);
				end if;
		  	set @TMPSQL_TWO=concat(@TMPSQL_ONE,' where ld_leads.deleted=0 and( ld_leads.publicaccount=2 or ld_leads.publicaccount=3) and ld_leads.pool_id = ',tmp_pool_id);
end if;

prepare stmt from @TMPSQL_TWO;
execute stmt;
deallocate prepare stmt;

end if;



end ||
delimiter;

drop PROCEDURE if EXISTS leads_singlerecycle_highsea_rule_beforeremind;
delimiter ||
create PROCEDURE leads_singlerecycle_highsea_rule_beforeremind(IN tmp_pool_id INT(11),IN tmp_grammeid INT(11))
    label_a:BEGIN

	DECLARE var_tabname varchar(100);
	DECLARE var_columnname varchar(100);
	DECLARE var_tablename varchar(100);
	DECLARE var_condition varchar(50);
	DECLARE var_smownercolumn varchar(50);
	DECLARE var_days int(11);
	DECLARE var_otherwhere varchar(200);
	declare var_iscycle varchar(100);
	declare var_leadsidcolumnname varchar(100);
	declare done  int  default 0;

	declare cur1 CURSOR FOR select  tabname,ld_leads_set_rule.columnname,ld_field.tablename ,ld_leads_set_rule.iscycle, `condition`,ld_leads_set_rule.days
                                 ,ld_leads_set_rule.otherwhere from ld_leads_set_rule  inner join ld_tab on ld_tab.name=ld_leads_set_rule.tabname and  (presence in(0,2) or ld_leads_set_rule.tabname='singin')
                                                                                       INNER JOIN ld_field on ld_field.tabid=ld_tab.tabid and ld_leads_set_rule.columnname=ld_field.columnname
    and ld_field.presence in(0,2) where ld_leads_set_rule.type='complete' and ld_leads_set_rule.`status`='active' and programmeid = tmp_grammeid;
declare continue handler  for not   found  SET done =1;
	set @tmpint=0;
	set @tmpsql='';
select max(ld_leads_set_rule.days) into @maxdays
from ld_leads_set_rule  inner join ld_tab on ld_tab.name=ld_leads_set_rule.tabname and (presence in(0,2) or ld_leads_set_rule.tabname='singin')
                        INNER JOIN ld_field on ld_field.tabid=ld_tab.tabid and ld_leads_set_rule.columnname=ld_field.columnname
    and ld_field.presence in(0,2) where ld_leads_set_rule.type='complete' and ld_leads_set_rule.`status`='active' and programmeid = tmp_grammeid;

select beforereminddays,recycleselect into @var_beforereminddays,@recycleselect  from ld_module_recovery_programme where  programmeid = tmp_grammeid;


if @var_beforereminddays='' or @var_beforereminddays is null or @var_beforereminddays=0 then
		leave label_a ;
end if;

set @maxdays=@maxdays-@var_beforereminddays;

	if @recycleselect is not null and @recycleselect<>'' then
			set @recycleselect=concat( '( ', @recycleselect,' ) as recyclewheretableset ');
end if;
OPEN cur1;

Fetch cur1 into  var_tabname,var_columnname,var_tablename,var_iscycle,var_condition,var_days,var_otherwhere;
loop1: while  done<>1 DO
		 set var_days=var_days-@var_beforereminddays;

			if var_tablename='ld_singin' THEN
					set var_smownercolumn='userid';
						set	var_leadsidcolumnname='record' ;
else
				set	var_smownercolumn='smownerid' ;
				set	var_leadsidcolumnname='leads_id' ;
end if;
		  if(var_condition='and' ) then

					set @tmpsqlone =concat("select ld_leads.leadsid,ld_leads.allocatedate,'",var_tabname,"' as remindtabname from ld_leads ");
					set @tmpsqlone=concat(@tmpsqlone," inner join ",var_tablename,' on ',var_tablename,'.',var_leadsidcolumnname,'=ld_leads.leadsid ');
					set @tmpsqlone=concat(@tmpsqlone," and  ",var_tablename,'.',var_smownercolumn,'=ld_leads.smownerid' );

					set @tmpsqlone=concat(@tmpsqlone ,"  where  ",var_tablename,".deleted=0");
					 if var_otherwhere is not null and  var_otherwhere<>'' then
							set @tmpsqlone=concat(@tmpsqlone,var_otherwhere);
end if;

					if var_iscycle='yes' then
							set @tmpsqlone=concat( @tmpsqlone,' group by ld_leads.leadsid ') ;
							set @tmpsqlone=concat(@tmpsqlone,"   having datediff(curdate(), case when ld_leads.allocatedate> max( " ,var_tablename,'.',var_columnname," )  then ld_leads.allocatedate else max( " ,var_tablename,'.',var_columnname," ) end  ) >=",var_days);
else
							set @tmpsqlone=concat(@tmpsqlone," and ld_leads.allocatedate<=",var_tablename,'.',var_columnname);
							set @tmpsqlone=concat( @tmpsqlone,' group by ld_leads.leadsid ') ;
							set @tmpsqlone=concat(@tmpsqlone,"  having  datediff(min( ",var_tablename,'.',var_columnname,"),ld_leads.allocatedate)>",var_days);
end if;
					set @tmpsqltwo=concat("select ld_leads.leadsid,ld_leads.allocatedate,'",var_tabname,"' as remindtabname from  ld_leads LEFT JOIN(select ld_leads.leadsid
							from ld_leads inner join ",var_tablename,' on ld_leads.leadsid=',var_tablename,'.',var_leadsidcolumnname,' and ld_leads.smownerid=',var_tablename,'.',var_smownercolumn,'  where ',var_tablename,'.deleted=0' );

					 if var_otherwhere is not null and  var_otherwhere<>'' then
							set @tmpsqltwo=concat(@tmpsqltwo, var_otherwhere);
end if;
					set @tmpsqltwo=concat(@tmpsqltwo,' ) 	as ttt_',var_tablename,'  on ld_leads.leadsid=ttt_',var_tablename,'.leadsid   where ttt_',var_tablename,'.leadsid is null  ' );
					set @tmpsqltwo=concat(@tmpsqltwo," having datediff(curdate(),ld_leads.allocatedate ) >=",var_days);

					set @tmpthree=concat( @tmpsqlone,' union all ',@tmpsqltwo);
					set @tmpsql=concat(@tmpsql," select * from ( ",@tmpthree," ) as  tttt_",var_tabname);
					set @tmpsql=concat(@tmpsql,' union all ' );

			elseif (var_condition='or')  then
				set @tmpsql=concat(@tmpsql ,' select ld_leads.leadsid,ld_leads.allocatedate from ld_leads inner join '  ,var_tablename,' on ',var_tablename,'.',var_leadsidcolumnname,'=ld_leads.leadsid  ');

			  set @tmpsql=concat(@tmpsql,' and ' ,var_tablename,'.',var_smownercolumn,' =ld_leads.smownerid ' );
				set @tmpsql=concat(@tmpsql,' where  ' , var_tablename,'.deleted=0 ' );
			  if var_otherwhere is not null and  var_otherwhere<>'' then
					set @tmpsql=concat(@tmpsql,var_otherwhere);
end if;


			  if var_iscycle='yes' then
						set @tmpsql=concat( @tmpsql,' group by ld_leads.leadsid ') ;
						set @tmpsql=concat(@tmpsql," having    datediff ( curdate(), case when ld_leads.allocatedate> max( ",var_tablename,'.',var_columnname," ) then ld_leads.allocatedate else max( ",var_tablename,'.',var_columnname," )  end )<=",var_days );

ELSE
				  set @tmpsql=concat(@tmpsql," and ld_leads.allocatedate<=",var_tablename,'.',var_columnname);
					set @tmpsql=concat( @tmpsql,' group by ld_leads.leadsid ') ;
					set @tmpsql=concat(@tmpsql,"  having datediff(min( ",var_tablename,'.',var_columnname,"),ld_leads.allocatedate)<=",var_days);
end if;
				set @tmpsql=concat(@tmpsql,' union all ' );

end if;
			set @tmpint=@tmpint+1;
Fetch cur1 into  var_tabname,var_columnname,var_tablename,var_iscycle,var_condition,var_days,var_otherwhere;
end while loop1;
close cur1;

if @tmpint>0 then
		set @len=CHAR_LENGTH(' union all ');
		set @tmpsql=left(@tmpsql,CHAR_LENGTH(@tmpsql)-@len);

    if var_condition='or'  then
			set @TMP_TMPTable=" ( select  concat('(',GROUP_CONCAT(ld_tranlabel.fieldlabel),')')  from ld_leads_set_rule
									INNER JOIN ld_tab on ld_tab.name=ld_leads_set_rule.tabname
									INNER JOIN ld_tranlabel on ld_tab.tabid=ld_tranlabel.tabid
									and ld_tab.tabid=ld_tranlabel.Relateid and languagetype='zh' and trantable='ld_tab'
										where type='complete' and ld_leads_set_rule.`status`='active' ORDER BY ld_leads_set_rule.sequence asc ) ";
			set @tmp_namelink=concat('\'<a style="display: initial;" doubleclick="yes" onclick="ListReferenceLinkClick(ld(this),event)" referencemodule="Leads" referencerecord="\',ld_leads.leadsid,\'">\',ld_leads.accountname,',@TMP_TMPTable,',\'</a>\'');
			set @sql=concat(' select leadsid from (',@tmpsql, ') as tmpone group by leadsid ') ;
			set @TMPSQL_ONE=concat( ' select "complete",  group_concat(',@tmp_namelink,' separator "<br>" )  as accouontnames ,count(distinct ld_leads.leadsid)  as totalaccounts,ld_leads.smownerid from ld_leads left join ( ',@sql,' ) as lingdangtmp  on  lingdangtmp.leadsid=ld_leads.leadsid ') ;
			if @recycleselect<>'' and @recycleselect is not null THEN
				set @TMPSQL_ONE=concat(@TMPSQL_ONE,' left join ',@recycleselect,' on recyclewheretableset.leadsid=ld_leads.leadsid ');
end if;
		  set @TMPSQL_TWO=concat(@TMPSQL_ONE,' where ld_leads.deleted=0 and( ld_leads.publicaccount=2 or ld_leads.publicaccount=3) and ld_leads.pool_id = ',tmp_pool_id);
		  set @TMPSQL_TWO=concat(@TMPSQL_TWO, ' and lingdangtmp.leadsid is null  and datediff(curdate(),ld_leads.allocatedate)>',@maxdays);
			if @recycleselect<>'' and @recycleselect is not null THEN
					set @TMPSQL_TWO=concat(@TMPSQL_TWO, ' and recyclewheretableset.leadsid is not null  ');
end if;
			set @TMPSQL_TWO=concat(@TMPSQL_TWO," group by ld_leads.smownerid ");
else
			if @recycleselect is not null and @recycleselect<>'' then
					set @sql=concat(' select tmpone.leadsid,GROUP_CONCAT(ld_tranlabel.fieldlabel) as fieldlabel from  (',@tmpsql, ' ) as tmpone
												inner join ',@recycleselect,' on tmpone.leadsid=recyclewheretableset.leadsid
												inner join ld_tab on ld_tab.name=tmpone.remindtabname
										 	INNER JOIN ld_tranlabel on ld_tab.tabid=ld_tranlabel.tabid
										  and ld_tab.tabid=ld_tranlabel.Relateid and languagetype="zh" and trantable="ld_tab"
											 group by leadsid ') ;
ELSE
					set @sql=concat(' select leadsid,GROUP_CONCAT(ld_tranlabel.fieldlabel) as fieldlabel from (',@tmpsql, ') as tmpone
											inner join ld_tab on ld_tab.name=tmpone.remindtabname
											INNER JOIN ld_tranlabel on ld_tab.tabid=ld_tranlabel.tabid
										  and ld_tab.tabid=ld_tranlabel.Relateid and languagetype="zh" and trantable="ld_tab"
											 group by leadsid') ;
end if;
			set @tmp_namelink=concat('\'<a style="display: initial;" doubleclick="yes" onclick="ListReferenceLinkClick(ld(this),event)" referencemodule="Leads" referencerecord="\',ld_leads.leadsid,\'">\',ld_leads.accountname,lingdangtmp.fieldlabel,\'</a>\'');
			set @TMPSQL_ONE=concat( ' select "complete",  GROUP_CONCAT(',@tmp_namelink,' separator "<br>")as accountnames,count(distinct ld_leads.leadsid)  as totalaccounts,ld_leads.smownerid from    ld_leads  inner join ( ',@sql,' ) as lingdangtmp  on  lingdangtmp.leadsid=ld_leads.leadsid ') ;
			set @TMPSQL_TWO=concat(@TMPSQL_ONE,' where ld_leads.deleted=0  and( ld_leads.publicaccount=2 or ld_leads.publicaccount=3) and ld_leads.pool_id = ',tmp_pool_id,'  group by ld_leads.smownerid    ');
end if;
delete from ld_publicleads_remindtableview ;
set @tmpthree=concat(" insert into ld_publicleads_remindtableview(type,names,totalleads,smownerid )  ", @TMPSQL_TWO);
prepare stmt from @tmpthree;
execute stmt;
deallocate prepare stmt;

call crm_publicleads_beforereminds();
end if;
end ||
delimiter;

call AddColumn("ld_parenttab",'allow_delete','VARCHAR','10',"yes");
delimiter;

update ld_parenttab set allow_delete = "no" where parenttab_label in ("My Home Page","Marketing","Parent Accounts","Sales","Parent Reports","Tools","Settings","Finacial","Project","Purchase","Stock","Service","OAForms","Promotion platform","CustomForms","ShopSettings","LDsoukebao","RenShiGuanLi") and ifnull(allow_delete, '') = '';
delimiter;

SET @labelbol = 'DELETEMENUTIP';set @labeltype = 'jspop';
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'zh',@labelbol,'是否删除该菜单？',@labeltype FROM DUAL 
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol=@labelbol and labeltype=@labeltype);
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'en',@labelbol,'Whether to delete this menu?',@labeltype FROM DUAL 
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol=@labelbol and labeltype=@labeltype);
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','APPROVE_BATCHAPPROVED','批量审批','jspop' from dual
where not exists(select 1 from ld_desk where labelbol = 'APPROVE_BATCHAPPROVED' and languagetype='zh' and labeltype = 'jspop');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','APPROVE_BATCHAPPROVED','Batch Approve','jspop' from dual
where not exists(select 1 from ld_desk where labelbol = 'APPROVE_BATCHAPPROVED' and languagetype='en' and labeltype = 'jspop');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','CONTINUEAPPROVALSTEP','同意，继续下一节点','jspop' from dual
where not exists(select 1 from ld_desk where labelbol = 'CONTINUEAPPROVALSTEP' and languagetype='zh' and labeltype = 'jspop');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','CONTINUEAPPROVALSTEP','Agree, continue to the next node','jspop' from dual
where not exists(select 1 from ld_desk where labelbol = 'CONTINUEAPPROVALSTEP' and languagetype='en' and labeltype = 'jspop');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','NOTPASSRETURNCHARGE','驳回，返回初始状态','jspop' from dual
where not exists(select 1 from ld_desk where labelbol = 'NOTPASSRETURNCHARGE' and languagetype='zh' and labeltype = 'jspop');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','NOTPASSRETURNCHARGE','Reject, return to initial state','jspop' from dual
where not exists(select 1 from ld_desk where labelbol = 'NOTPASSRETURNCHARGE' and languagetype='en' and labeltype = 'jspop');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','APPROVALSUGGESTION','审批意见','jspop' from dual
where not exists(select 1 from ld_desk where labelbol = 'APPROVALSUGGESTION' and languagetype='zh' and labeltype = 'jspop');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','APPROVALSUGGESTION','Approval suggestion','jspop' from dual
where not exists(select 1 from ld_desk where labelbol = 'APPROVALSUGGESTION' and languagetype='en' and labeltype = 'jspop');
delimiter;

SET @labelbol = 'nosalesgoal';set @labeltype = 'fixedstr';
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'zh',@labelbol,'您当前没有可查看的指标',@labeltype FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol=@labelbol and Labeltype=@labeltype);
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'en',@labelbol,'You currently have no indicators to view',@labeltype FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol=@labelbol and Labeltype=@labeltype);
delimiter;


CALL AddColumn('ld_reminds','push_to_td','tinyint','2',0);
CALL AddColumn('ld_reminds_accepted','push_to_td','tinyint','2',0);
CALL AddColumn('ld_reminds','push_time_td','datetime',null,null );
CALL AddColumn('ld_reminds_accepted','push_time_td','datetime',null,null );
delimiter;
update ld_reminds set push_to_td = 3 where push_to_td = 0;
update ld_reminds_accepted set push_to_td = 3 where push_to_td = 0;
delimiter;

insert into ld_wx_config (name,description) select 'tongda_setting','通达设置' from dual where not exists(select 1 from ld_wx_config where name='tongda_setting');
delimiter;

INSERT INTO `ld_cvcolumnlist_wx` (`modulename`, `rownumber`, `listnumber`, `columnname`, `type`, `typedescribe`, `presence`, `systemdefault`, `showtag`, `isforsearch`) 
select 'Productbom', '1', '1', 'ld_productbom:subject:subject:Productbom_套餐名称:V', '0', NULL, '0', 'no', 'yes', 'yes' from dual
where not exists(select 1 from ld_cvcolumnlist_wx where modulename='Productbom' and columnname='ld_productbom:subject:subject:Productbom_套餐名称:V');

INSERT INTO `ld_cvcolumnlist_wx` (`modulename`, `rownumber`, `listnumber`, `columnname`, `type`, `typedescribe`, `presence`, `systemdefault`, `showtag`, `isforsearch`)
select 'Productbom', '2', '1', 'ld_productbom:productbom_no:productbom_no:Productbom_套餐编号:V', '0', NULL, '0', 'no', 'yes', 'yes' from dual
where not exists(select 1 from ld_cvcolumnlist_wx where modulename='Productbom' and columnname='ld_productbom:productbom_no:productbom_no:Productbom_套餐编号:V');

INSERT INTO `ld_cvcolumnlist_wx` (`modulename`, `rownumber`, `listnumber`, `columnname`, `type`, `typedescribe`, `presence`, `systemdefault`, `showtag`, `isforsearch`)
select 'Productbom', '3', '1', 'ld_productbom:total:hdnGrandTotal:Productbom_套餐售价:N', '0', NULL, '0', 'no', 'yes', 'yes' from dual
where not exists(select 1 from ld_cvcolumnlist_wx where modulename='Productbom' and columnname='ld_productbom:total:hdnGrandTotal:Productbom_套餐售价:N');
delimiter;


insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','ProductsBOM','产品套餐','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='ProductsBOM' and labeltype='fixedstr' and languagetype='zh');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','ProductsBOM','Products BOM','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='ProductsBOM' and labeltype='fixedstr' and languagetype='en');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','NumberOfProductsBom','套餐数量','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='NumberOfProductsBom' and labeltype='fixedstr' and languagetype='zh');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','NumberOfProductsBom','Number of products packages','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='NumberOfProductsBom' and labeltype='fixedstr' and languagetype='en');
delimiter;

call addtableIndex('ld_crmlog_viewdetail','crmlog_module_operationtime_userid','module, operationtime, userid');
call addtableIndex('ld_crmlog_entity','crmlog_crmid','crmid');
call addtableIndex('ld_crmlog_entity','crmlog_module_actiontype','module, actiontype');
call addtableIndex('ld_crmlog_entity','crmlog_crmid_userid_operationtime','crmid, userid, operationtime');
delimiter;

insert into ld_listview_btn(`name`,btntype,description,iconname)
select 'Inactivating','rely','禁用','discontinued.png' from dual
where not EXISTS(select 1 from ld_listview_btn where `name` = 'Inactivating');
delimiter;

SET @tabid = (select tabid from ld_tab where `name` = 'BankAccountSet');
SET @sequence = (select MAX(sequence) from ld_btnset where `tabid` = @tabid AND shownum = 0 and btn_type = 'listbasicbtn');
insert into ld_btnset(`tabid`,buttonlabel,sequence,btnkey,shownum,is_active,btn_type)
select @tabid,'禁用',@sequence+1,'Inactivating',0,'yes','listbasicbtn' from dual
where not EXISTS(select 1 from ld_btnset where `tabid` = @tabid and `btnkey` = 'Inactivating');
delimiter;

DROP FUNCTION IF EXISTS `func_changeToCapitalRMB`;
delimiter ||
CREATE FUNCTION func_changeToCapitalRMB (MONEY DECIMAL(14,2)) 
RETURNS VARCHAR(150)
BEGIN
	DECLARE RESULT VARCHAR(100) DEFAULT ''; 	
	DECLARE NUM_ROUND VARCHAR(100); 	
	DECLARE NUM_LEFT VARCHAR(100); 	
	DECLARE NUM_RIGHT VARCHAR(2); 		
	DECLARE STR1 VARCHAR(10); 	
	DECLARE STR2 VARCHAR(16); 	
	DECLARE NUM_PRE INT DEFAULT 1; 					
	DECLARE NUM_CURRENT INT; 					
	DECLARE NUM_COUNT INT DEFAULT 0; 					
	DECLARE NUM1 INT;

	SET NUM_ROUND = CONCAT(MONEY, '');
	SET STR1 = '零壹贰叁肆伍陆柒捌玖'; 
	SET STR2 = '元拾佰仟万拾佰仟亿拾佰仟万拾佰仟';
	SET NUM_LEFT = FLOOR(MONEY);
	SET NUM_RIGHT = SUBSTR(NUM_ROUND, LOCATE('.', NUM_ROUND) + 1);

	IF MONEY IS NULL THEN
		SET RESULT = NULL;
		RETURN RESULT;
	END IF;

	IF LENGTH(NUM_LEFT) >= 8 THEN 
		SET NUM1 = CAST(SUBSTR(NUM_LEFT, -8, 4) AS SIGNED);
	ELSE 
		SET NUM1 = CAST(SUBSTR(NUM_LEFT, -LENGTH(NUM_LEFT), LENGTH(NUM_LEFT) - 4) AS SIGNED);
	END IF;

	IF LENGTH(NUM_LEFT) > 16 THEN 
		SET RESULT = '**********';
		RETURN RESULT;
	END IF;

	IF LENGTH(NUM_RIGHT) = 2 THEN
		IF CAST(SUBSTR(NUM_RIGHT, 1, 1) AS SIGNED) = 0 THEN
			SET RESULT = CONCAT('零', SUBSTR(STR1, CAST(SUBSTR(NUM_RIGHT, 2, 1) AS SIGNED) + 1, 1), '分');
		ELSE
			SET RESULT = CONCAT(SUBSTR(STR1, CAST(SUBSTR(NUM_RIGHT, 1, 1) AS SIGNED) + 1, 1), '角', SUBSTR(STR1, CAST(SUBSTR(NUM_RIGHT, 2, 1) AS SIGNED) + 1, 1), '分');
		END IF;
	ELSE 
		IF LENGTH(NUM_RIGHT) = 1 THEN
			SET RESULT = CONCAT(SUBSTR(STR1, CAST(SUBSTR(NUM_RIGHT, 1, 1) AS SIGNED) + 1, 1), '角整');
		ELSE
			SET RESULT = '整';
		END IF;
	END IF;

	myloop: LOOP
		SET NUM_COUNT = NUM_COUNT + 1; 
		IF LENGTH(NUM_LEFT) - NUM_COUNT + 1 > 0 THEN
			SET NUM_CURRENT = CAST(SUBSTR(NUM_LEFT, LENGTH(NUM_LEFT) - NUM_COUNT + 1, 1) AS SIGNED);
		ELSE
			SET NUM_CURRENT = 0;
		END IF;

		IF NUM_CURRENT > 0 THEN 
			SET RESULT = CONCAT(SUBSTR(STR1, NUM_CURRENT + 1, 1), SUBSTR(STR2, NUM_COUNT, 1), RESULT);
		ELSE
			IF NUM_COUNT = 5 THEN
				IF MOD(NUM_COUNT - 1, 4) = 0 AND NUM1 <> 0 THEN 
					SET RESULT = CONCAT(SUBSTR(STR2, NUM_COUNT, 1), RESULT); 
					SET NUM_PRE = 0;
				END IF;
			ELSE
				IF MOD(NUM_COUNT - 1, 4) = 0 THEN 
					SET RESULT = CONCAT(SUBSTR(STR2, NUM_COUNT, 1), RESULT); 
					SET NUM_PRE = 0; 
				END IF;
			END IF;

			IF NUM_PRE > 0 OR LENGTH(NUM_LEFT) = 1 THEN
				SET RESULT = CONCAT(SUBSTR(STR1, NUM_CURRENT + 1, 1), RESULT);
			END IF;
		END IF;

		SET NUM_PRE = NUM_CURRENT;
		IF NUM_COUNT >= LENGTH(NUM_LEFT) THEN 
			LEAVE myloop;
		END IF;
	END LOOP myloop; 

	IF MONEY < 0 THEN
		SET RESULT = CONCAT('负', RESULT);
	END IF;

	SET RESULT = REPLACE(RESULT, '零零分', '整');
	SET RESULT = REPLACE(RESULT, '零分', '整');
	SET RESULT = REPLACE(RESULT, '元整', '元整');
	RETURN RESULT;
END ||
delimiter;

CALL AddColumn('ld_workreport_rulesettings','report_date','varchar',50,'');
CALL AddColumn('ld_workreport_rulesettings','edit_date','varchar',50,'');

set @deploy_value_198 = (select deploy_value from ld_systems_deploy where deploy_type=198);
update ld_workreport_rulesettings set report_date = if(@deploy_value_198 = '0','all','1_0'), edit_date = 'all' where type='day' and EXISTS (select 1 from ld_systems_deploy where deploy_type=198 and roottype=1);
update ld_workreport_rulesettings set report_date = if(@deploy_value_198 = '0','yes','no') where type='week' or type='month' and EXISTS (select 1 from ld_systems_deploy where deploy_type=198 and roottype=1);
delimiter;

update ld_systems_deploy set roottype = '' where deploy_type=198 ;
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','WorkTemplateRuleReportDate','汇报日期修改时限','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol = 'WorkTemplateRuleReportDate' and languagetype='zh' and labeltype = 'fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','WorkTemplateRuleReportDate','Report date modification time limit','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol = 'WorkTemplateRuleReportDate' and languagetype='en' and labeltype = 'fixedstr');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','WorkTemplateRuleEditDate','工作汇报编辑时限','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol = 'WorkTemplateRuleEditDate' and languagetype='zh' and labeltype = 'fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','WorkTemplateRuleEditDate','Time limit for editing work reports','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol = 'WorkTemplateRuleEditDate' and languagetype='en' and labeltype = 'fixedstr');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','UnlimitedTime','不限时间','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol = 'UnlimitedTime' and languagetype='zh' and labeltype = 'fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','UnlimitedTime','Unlimited time','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol = 'UnlimitedTime' and languagetype='en' and labeltype = 'fixedstr');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','CurrentDayAndThePastSomeDay','当天及过去{Var}天','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol = 'CurrentDayAndThePastSomeDay' and languagetype='zh' and labeltype = 'fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','CurrentDayAndThePastSomeDay','Current day and the past {Var} day','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol = 'CurrentDayAndThePastSomeDay' and languagetype='en' and labeltype = 'fixedstr');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','NotAllowedToEdit','不允许编辑','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol = 'NotAllowedToEdit' and languagetype='zh' and labeltype = 'fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','NotAllowedToEdit','Not allowed to edit','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol = 'NotAllowedToEdit' and languagetype='en' and labeltype = 'fixedstr');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','CannotEditAfterSomeDay','提交{Var}天后不能编辑','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol = 'CannotEditAfterSomeDay' and languagetype='zh' and labeltype = 'fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','CannotEditAfterSomeDay','Cannot edit after {Var} day of submission','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol = 'CannotEditAfterSomeDay' and languagetype='en' and labeltype = 'fixedstr');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','AllowModification','允许修改','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol = 'AllowModification' and languagetype='zh' and labeltype = 'fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','AllowModification','Allow modification','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol = 'AllowModification' and languagetype='en' and labeltype = 'fixedstr');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','NoModificationsAllowed','不允许修改','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol = 'NoModificationsAllowed' and languagetype='zh' and labeltype = 'fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','NoModificationsAllowed','No modifications allowed','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol = 'NoModificationsAllowed' and languagetype='en' and labeltype = 'fixedstr');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','BasedOnReportDate','按汇报日期计算','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol = 'BasedOnReportDate' and languagetype='zh' and labeltype = 'fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','BasedOnReportDate','Based on the reporting date','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol = 'BasedOnReportDate' and languagetype='en' and labeltype = 'fixedstr');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','ReportDateSubmitTip','管理员已设置，日志汇报日期范围为"{Var}"，请重新选择日期！','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol = 'ReportDateSubmitTip' and languagetype='zh' and labeltype = 'fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','ReportDateSubmitTip','The administrator has set the date range for log reporting to "{Var}". Please select a new date!','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol = 'ReportDateSubmitTip' and languagetype='en' and labeltype = 'fixedstr');
delimiter;

select tabid into @tabid from ld_tab where name='Reminds';
update ld_tranlabel set fieldlabel='消息' where trantable='ld_tab' and Relateid=@tabid and languagetype='zh';
delimiter;
-- 2024-08-28

CREATE TABLE IF NOT EXISTS `ld_click_remind_code_log` (
    `id`  int(19) NOT NULL AUTO_INCREMENT ,
    `crm_directurl`  text NULL COMMENT 'crm_directurl' ,
    `wx_userid`  text NULL COMMENT 'wx_userid' ,
    `remindscode`  varchar(100) NULL COMMENT 'code' ,
    `remindsstoragecode`  varchar(50) NULL COMMENT '本地缓存code' ,
    `count`  int(4)  DEFAULT 0 COMMENT  '数量' ,
    `created_time`  datetime DEFAULT CURRENT_TIMESTAMP ,
    PRIMARY KEY (`id`)
    ) ENGINE = INNODB DEFAULT CHARSET = utf8;
delimiter;

UPDATE ld_module_list_tab set zhlabel = '全部（含指定公海）' where zhlabel = '全部（含公海）';
UPDATE ld_module_list_tab set enlabel = 'All (including designated high seas)' where enlabel = 'The default all include unassigned';

delimiter;

UPDATE ld_account_public_pool INNER JOIN 
(SELECT GROUP_CONCAT(ld_users.id) as new_id,a.id from ld_account_public_pool a
INNER JOIN ld_users on (FIND_IN_SET(ld_users.id,a.administrators)
or FIND_IN_SET(ld_users.id,a.administrators)) GROUP BY a.id) tmpdata on tmpdata.id = ld_account_public_pool.id
set ld_account_public_pool.administrators = tmpdata.new_id;

UPDATE ld_leads_public_pool INNER JOIN 
(SELECT GROUP_CONCAT(ld_users.id) as new_id,a.id from ld_leads_public_pool a
INNER JOIN ld_users on (FIND_IN_SET(ld_users.id,a.administrators)
or FIND_IN_SET(ld_users.id,a.allow_users)) GROUP BY a.id) 
tmpdata on tmpdata.id = ld_leads_public_pool.id
set ld_leads_public_pool.administrators = tmpdata.new_id;
delimiter;

UPDATE ld_account set completed = '已完成',protectdate = '' where completed = '达成';
UPDATE ld_leads set completed = '已完成',protectdate = '' where completed = '达成';
delimiter;

SET @stufftitle = 'new_reminds';
set @stuffid=118;
insert into ld_stuff(stuffid,stufftitle,stufftype,relatedmodule,datarangmodule,pc_show,mobile_show,showfields)
select @stuffid,@stufftitle,'customsheet','Reminds','Reminds','yes','no','["ld_reminds:content:content:Reminds_fieldlabel:V","ld_reminds:related_to:related_to:Reminds_fieldlabel:V"]' from dual
where not exists(select 1 from ld_stuff where stuffid=@stuffid and stufftitle=@stufftitle and stufftype='customsheet');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','new_reminds','消息中心','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol = 'new_reminds' and languagetype='zh' and labeltype = 'fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','new_reminds','Message Center','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol = 'new_reminds' and languagetype='en' and labeltype = 'fixedstr');
delimiter;

UPDATE ld_desk set fieldlabel='同时共享以下相关信息' WHERE labelbol='SimultaneouslyShareRelinfo' and languagetype='zh' and labeltype='jspop';
UPDATE ld_desk set fieldlabel='Simultaneously share the following relevant information' WHERE labelbol='SimultaneouslyShareRelinfo' and languagetype='en' and labeltype='jspop';
delimiter;

UPDATE ld_desk set fieldlabel='同时取消共享以下相关信息' WHERE labelbol='SimultaneouslyCancelShareRelinfo' and languagetype='zh' and labeltype='jspop';
UPDATE ld_desk set fieldlabel='Simultaneously cancel the sharing of the following related information' WHERE labelbol='SimultaneouslyCancelShareRelinfo' and languagetype='en' and labeltype='jspop';
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','DonotProcessRelinfo','相关信息不处理','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='DonotProcessRelinfo' and labeltype='fixedstr' and languagetype='zh');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','DonotProcessRelinfo','Do not process relevant information','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='DonotProcessRelinfo' and labeltype='fixedstr' and languagetype='en');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','IncludeCancelRelInfoDocuments','同时取消共享相关信息单据 %d 条，成功 %d 条，失败 %d 条。','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='IncludeCancelRelInfoDocuments' and labeltype='fixedstr' and languagetype='zh');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','IncludeCancelRelInfoDocuments','Simultaneously cancel the sharing of %d relevant information documents,%d successful, %d failed.','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='IncludeCancelRelInfoDocuments' and labeltype='fixedstr' and languagetype='en');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','LICENSEDDEALERUSERS','许可经销商用户','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol = 'LICENSEDDEALERUSERS' and languagetype='zh' and labeltype = 'fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','LICENSEDDEALERUSERS','Licensed dealer users','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol = 'LICENSEDDEALERUSERS' and languagetype='en' and labeltype = 'fixedstr');
delimiter;

CREATE TABLE if not exists `ld_paramlog` (
   `id` bigint(20) NOT NULL AUTO_INCREMENT,
   `req_param` longtext,
   `createdtime` datetime DEFAULT NULL,
   `userid` int(11) DEFAULT NULL,
   PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=1;
delimiter;

DROP EVENT IF EXISTS `ld_delparamlog_event`;
delimiter;

CREATE EVENT `ld_delparamlog_event` ON SCHEDULE EVERY 10 DAY STARTS '2024-08-30 12:57:55' ON COMPLETION NOT PRESERVE ENABLE DO
DELETE FROM ld_paramlog WHERE DATEDIFF(now(), createdtime) > 20;
delimiter;
-- 2024-08-30

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

UPDATE ld_version SET old_version='V8.6.4.3',current_version='V8.6.4.3',remark='V8.6.4.3-20240830',wx_version='V8.6.4.0';
delimiter;