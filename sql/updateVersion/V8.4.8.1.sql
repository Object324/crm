CALl AddColumn('ld_customform15','triggercount','INT','19',0);
CALl AddColumn('ld_customform25','triggercount','INT','19',0);
delimiter;
-- 2022-11-12

ALTER TABLE ld_appuiset MODIFY setname text;
delimiter;

CALL addtableIndex('ld_wechatsession','session_type_idx','session_type');
delimiter;

set @tabid = (select tabid from ld_tab where `name`= 'ServiceContracts');
update ld_field set columnname='vendorid',uitype=81 where uitype=75 and columnname='vendor_id' and tabid=@tabid;
delimiter;

SET @maxtabid=(SELECT MAX(tabid) FROM ld_tab);
SET @maxtseq=(SELECT max(tabsequence) FROM ld_tab);
INSERT INTO ld_tab(tabid,`name`,presence,tabsequence,tablabel,printtab,description)
SELECT @maxtabid+1,'ReportAnalysis',5,@maxtseq+1,'ReportAnalysis',1,'ReportAnalysis' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_tab WHERE `name`='ReportAnalysis');

select max(sequence) into @sequence from ld_parenttabrel where parenttabid=5;
insert into ld_parenttabrel (parenttabid,tabid,sequence,tab_tablename) select 5,@maxtabid+1,@sequence+1,'ld_tab' from dual
where not exists(select 1 from ld_parenttabrel where tabid=@maxtabid+1 and tab_tablename='ld_tab');

SET @tabid=(SELECT tabid FROM ld_tab WHERE `name`='ReportAnalysis');
INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
SELECT 'zh','ld_tab',@tabid,@tabid,'报表分析' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE tabid=@tabid AND relateid=@tabid AND languagetype='zh' AND trantable='ld_tab');
INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
SELECT 'en','ld_tab',@tabid,@tabid,'Report Analysis' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE tabid=@tabid AND relateid=@tabid AND languagetype='en' AND trantable='ld_tab');

INSERT INTO ld_modtracker_tabs(tabid,visible)
SELECT @tabid,1 FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_modtracker_tabs WHERE tabid=@tabid);

SET @i=0;
INSERT INTO ld_profileallpermission(tabid,operation,sequence)
SELECT @tabid,actionid,(@i:=@i+1) FROM ld_actionmapping
WHERE NOT EXISTS (SELECT 1 FROM ld_profileallpermission WHERE tabid=@tabid) AND actionname IN('index','Create','EditView','Delete','Allocate','Print','Export');

update ld_tab set presence=0 where name="ReportAnalysis";
select tabsequence into @tabsequence from ld_tab  where name="ReportAnalysis";
update ld_tab set tabsequence=tabsequence+1 where tabsequence>@tabsequence;
update ld_tab set tabsequence=@tabsequence+1 where name="ReportAnalysis";
SET @i=0;
update ld_tab set tabsequence=(@i:=@i+1) order by tabsequence;
delimiter;

CREATE TABLE IF NOT EXISTS `ld_report_analysis_folder` (
	`analysisfolder_id` int(19) AUTO_INCREMENT COMMENT '文件夹自增id ，主键',
	`name` varchar(100) default '' COMMENT '名称 不允许重复',
	`folderlabel_zh` varchar(255) default '' COMMENT '文件夹中文名',
	`folderlabel_en` varchar(255) default '' COMMENT '文件夹英文名',
	`parent_id` int(19) default 0 COMMENT '父级文件夹id',
	`description` text default '' COMMENT '描述',
	`smcreatorid` int(11) default 1 COMMENT '创建人',
	`createdtime` datetime default NOW() COMMENT '创建时间',
	`sequence` int(11) default 0 COMMENT '排序   升序',
	`visible` varchar(10) default 'no' COMMENT '是否显示  显示:yes  隐藏：no',
	`systemdefault` varchar(10) default 'no' COMMENT '是否系统内置报表  是:yes  否：no',
	`version` varchar(200) default '' COMMENT '版本  客户定制报表，例：综合报表的小白熊',
	`modify_id` int(11) default 1 COMMENT '编辑人',
	`modify_time` datetime default NOW() COMMENT '编辑时间',
	`deleted` int(1) default 0 COMMENT '是否删除  删除：1   未删除：0',
	`allocatetype` int(2) default 0 COMMENT '分配类型  0所有成员  1按部门 2.按成员',
	`depth` int(2) default 1 COMMENT '文件夹深度',
	PRIMARY KEY  (`analysisfolder_id` )
) ENGINE=InnoDB AUTO_INCREMENT=0 DEFAULT CHARSET=utf8;
delimiter;

CREATE TABLE IF NOT EXISTS `ld_report_analysis2user` (
	`report_id` int(11) COMMENT '报表id',
	`modulename` varchar(100) default '' COMMENT '报表所属模块  例如常用报表OftenUseReport 自定义统计表CustomTables',
	`userid` varchar(255) default '' COMMENT '成员id',
	`sequence` int(4) default 0 COMMENT '排序'
) ENGINE=InnoDB AUTO_INCREMENT=0 DEFAULT CHARSET=utf8;
delimiter;

call AddColumn('ld_usereport','analysisfolder_id','INT','19','0');
call AddColumn('ld_customreport_info','analysisfolder_id','INT','19','0');
call AddColumn('ld_customreport_folder','analysisfolder_id','INT','19','0');
call AddColumn('ld_comprehensivereport','analysisfolder_id','INT','19','0');
call AddColumn('ld_comprehensivereport_group','analysisfolder_id','INT','19','0');
call AddColumn('ld_customreport','analysisfolder_id','INT','19','0');
call AddColumn('ld_customtable','analysisfolder_id','INT','19','0');
delimiter;

select tabid into @tabid from ld_tab where name='OftenUseReport';
select ifnull(max(ifnull(sequence,0)),0) into @sequence from ld_report_analysis_folder where parent_id=0;
select fieldlabel into @fieldlabel_zh from ld_tranlabel where tabid =@tabid and trantable='ld_tab' and languagetype='zh';
select fieldlabel into @fieldlabel_en from ld_tranlabel where tabid =@tabid and trantable='ld_tab' and languagetype='en';

insert into ld_report_analysis_folder (`name`,folderlabel_zh,folderlabel_en,parent_id,description,smcreatorid,createdtime,sequence,visible,systemdefault,depth)
select 'OftenUseReport',@fieldlabel_zh,@fieldlabel_en,0,'原【常用报表】',1,NOW(),@sequence:=@sequence+1,'yes','yes',1
FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_report_analysis_folder WHERE `name` = 'OftenUseReport');

select analysisfolder_id into @OftenUseReport_id from ld_report_analysis_folder where name='OftenUseReport';
select ifnull(max(ifnull(sequence,0)),0) into @OftenUseReport_sequence from ld_report_analysis_folder where parent_id=@OftenUseReport_id;
select depth into @OftenUseReport_depth from ld_report_analysis_folder where analysisfolder_id=@OftenUseReport_id;

insert into ld_report_analysis_folder (`name`,folderlabel_zh,folderlabel_en,parent_id,description,smcreatorid,createdtime,sequence,visible,systemdefault,depth)
select usereport.`name`,usereport.fieldlabel_zh,usereport.fieldlabel_en,@OftenUseReport_id,'原【常用报表】',1,NOW(),@OftenUseReport_sequence:=@OftenUseReport_sequence+1,'yes','yes',@OftenUseReport_depth+1
from (
    select ld_usereport.*,
    TRIM(BOTH ',' FROM group_concat(case when ld_desk.languagetype='zh' then ld_desk.fieldlabel else '' end)) as fieldlabel_zh,
    TRIM(BOTH ',' FROM group_concat(case when ld_desk.languagetype='en' then ld_desk.fieldlabel else '' end)) as fieldlabel_en
    from  ld_usereport left join ld_desk  on ld_desk.labelbol=ld_usereport.name where Parent_id=0 group by ld_usereport.`name` order by ld_usereport.sequence asc
    )usereport where ifnull(usereport.analysisfolder_id,0)=0 group by usereport.`name` ;

update ld_usereport a
    left join ld_report_analysis_folder b on a.`name`=b.`name`
    set a.analysisfolder_id=b.analysisfolder_id
where a.Parent_id=0;

update ld_usereport child
    left join ld_usereport parent on child.Parent_id=parent.usereportid
    set child.analysisfolder_id=parent.analysisfolder_id
where child.Parent_id>0;

select tabid into @tabid from ld_tab where name='Customreport';
select ifnull(max(ifnull(sequence,0)),0) into @sequence from ld_report_analysis_folder;
select fieldlabel into @fieldlabel_zh from ld_tranlabel where tabid =@tabid and trantable='ld_tab' and languagetype='zh';
select fieldlabel into @fieldlabel_en from ld_tranlabel where tabid =@tabid and trantable='ld_tab' and languagetype='en';

insert into ld_report_analysis_folder (`name`,folderlabel_zh,folderlabel_en,parent_id,description,smcreatorid,createdtime,sequence,visible,systemdefault,depth)
select 'Customreport',@fieldlabel_zh,@fieldlabel_en,0,'原【报表库】',1,NOW(),@sequence:=@sequence+1,'yes','yes',1
FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_report_analysis_folder WHERE `name` = 'Customreport');

select analysisfolder_id into @Customreport_id from ld_report_analysis_folder where name='Customreport';
select ifnull(max(ifnull(sequence,0)),0) into @Customreport_sequence from ld_report_analysis_folder where parent_id=@Customreport_id;
select depth into @Customreport_depth from ld_report_analysis_folder where analysisfolder_id=@Customreport_id;

insert into ld_report_analysis_folder (`name`,folderlabel_zh,folderlabel_en,parent_id,description,smcreatorid,createdtime,sequence,visible,systemdefault,depth)
select usereport.folder_name,usereport.folder_name,usereport.folder_name,@Customreport_id,'原【报表库】',1,NOW(),@Customreport_sequence:=@Customreport_sequence+1,'yes','yes',@Customreport_depth+1
from (
    select * from ld_customreport_folder order by id asc
    )usereport where ifnull(usereport.analysisfolder_id,0)=0;

update ld_customreport_folder a
    left join ld_report_analysis_folder b on a.`folder_name`=b.`name`
    set a.analysisfolder_id=b.analysisfolder_id;

update ld_customreport_info child
    left join ld_customreport_folder parent on child.folder_id=parent.id
    set child.analysisfolder_id=parent.analysisfolder_id;
delimiter;

select tabid into @tabid from ld_tab where name='Comprehensivereport';
select ifnull(max(ifnull(sequence,0)),0) into @sequence from ld_report_analysis_folder;
select fieldlabel into @fieldlabel_zh from ld_tranlabel where tabid =@tabid and trantable='ld_tab' and languagetype='zh';
select fieldlabel into @fieldlabel_en from ld_tranlabel where tabid =@tabid and trantable='ld_tab' and languagetype='en';

insert into ld_report_analysis_folder (`name`,folderlabel_zh,folderlabel_en,parent_id,description,smcreatorid,createdtime,sequence,visible,systemdefault,depth)
select 'Comprehensivereport',@fieldlabel_zh,@fieldlabel_en,0,'原【综合报表】',1,NOW(),@sequence:=@sequence+1,'yes','yes',1
FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_report_analysis_folder WHERE `name` = 'Comprehensivereport');

select analysisfolder_id into @Comprehensivereport_id from ld_report_analysis_folder where name='Comprehensivereport';
select ifnull(max(ifnull(sequence,0)),0) into @Comprehensivereport_sequence from ld_report_analysis_folder where parent_id=@Comprehensivereport_id;
select depth into @Comprehensivereport_depth from ld_report_analysis_folder where analysisfolder_id=@Comprehensivereport_id;

insert into ld_report_analysis_folder (`name`,folderlabel_zh,folderlabel_en,parent_id,description,smcreatorid,createdtime,sequence,visible,systemdefault,version,depth)
select usereport.typename,usereport.fieldlabel_zh,usereport.fieldlabel_en,@Comprehensivereport_id,'原【综合报表】',1,NOW(),@Comprehensivereport_sequence:=@Comprehensivereport_sequence+1,
(case when ifnull(usereport.version,'')='' then 'yes' else 'no' end ),'yes',usereport.version,@Comprehensivereport_depth+1
from (
    select ld_comprehensivereport_group.*,
    TRIM(BOTH ',' FROM group_concat(case when ld_desk.languagetype='zh' then ld_desk.fieldlabel else '' end)) as fieldlabel_zh,
    TRIM(BOTH ',' FROM group_concat(case when ld_desk.languagetype='en' then ld_desk.fieldlabel else '' end)) as fieldlabel_en
    from  ld_comprehensivereport_group left join ld_desk  on ld_desk.labelbol=ld_comprehensivereport_group.typename group by ld_comprehensivereport_group.`typename` order by ld_comprehensivereport_group.id asc
    )usereport where ifnull(usereport.analysisfolder_id,0)=0;

update ld_comprehensivereport_group a
    left join ld_report_analysis_folder b on a.`typename`=b.`name`
    set a.analysisfolder_id=b.analysisfolder_id;

update ld_comprehensivereport child
    left join ld_comprehensivereport_group parent on child.typename=parent.typename
    set child.analysisfolder_id=parent.analysisfolder_id;
delimiter;

select tabid into @tabid from ld_tab where name='CustomEcharts';
select ifnull(max(ifnull(sequence,0)),0) into @sequence from ld_report_analysis_folder;
select fieldlabel into @fieldlabel_zh from ld_tranlabel where tabid =@tabid and trantable='ld_tab' and languagetype='zh';
select fieldlabel into @fieldlabel_en from ld_tranlabel where tabid =@tabid and trantable='ld_tab' and languagetype='en';

insert into ld_report_analysis_folder (`name`,folderlabel_zh,folderlabel_en,parent_id,description,smcreatorid,createdtime,sequence,visible,systemdefault,depth)
select 'CustomEcharts',@fieldlabel_zh,@fieldlabel_en,0,'原【自定义统计图】',1,NOW(),@sequence:=@sequence+1,'yes','yes',1
FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_report_analysis_folder WHERE `name` = 'CustomEcharts');

select analysisfolder_id into @CustomEcharts_id from ld_report_analysis_folder where name='CustomEcharts';
select ifnull(max(ifnull(sequence,0)),0) into @CustomEcharts_sequence from ld_report_analysis_folder where parent_id=@CustomEcharts_id;
select depth into @CustomEcharts_depth from ld_report_analysis_folder where analysisfolder_id=@CustomEcharts_id;

insert into ld_report_analysis_folder (`name`,folderlabel_zh,folderlabel_en,parent_id,description,smcreatorid,createdtime,sequence,visible,systemdefault,depth )
select usereport.report_name,usereport.report_name,usereport.report_name,@CustomEcharts_id,'原【自定义统计图表】',1,NOW(),@CustomEcharts_sequence:=@CustomEcharts_sequence+1,'yes','yes',@CustomEcharts_depth+1
from (
    select * from ld_customreport where parent_id=0 order by sequence asc
    )usereport where ifnull(usereport.analysisfolder_id,0)=0;

update ld_customreport a
    left join ld_report_analysis_folder b on a.`report_name`=b.`name`
    set a.analysisfolder_id=b.analysisfolder_id
where a.parent_id=0;

update ld_customreport child
    left join ld_customreport parent on child.parent_id=parent.report_id
    set child.analysisfolder_id=parent.analysisfolder_id
where child.parent_id>0;
delimiter;


select tabid into @tabid from ld_tab where name='CustomTables';
select ifnull(max(ifnull(sequence,0)),0) into @sequence from ld_report_analysis_folder;
select fieldlabel into @fieldlabel_zh from ld_tranlabel where tabid =@tabid and trantable='ld_tab' and languagetype='zh';
select fieldlabel into @fieldlabel_en from ld_tranlabel where tabid =@tabid and trantable='ld_tab' and languagetype='en';

insert into ld_report_analysis_folder (`name`,folderlabel_zh,folderlabel_en,parent_id,description,smcreatorid,createdtime,sequence,visible,systemdefault,depth)
select 'CustomTables',@fieldlabel_zh,@fieldlabel_en,0,'原【自定义统计表】',1,NOW(),@sequence:=@sequence+1,'yes','yes',1
FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_report_analysis_folder WHERE `name` = 'CustomTables');

select analysisfolder_id into @CustomTables_id from ld_report_analysis_folder where name='CustomTables';
select ifnull(max(ifnull(sequence,0)),0) into @CustomTables_sequence from ld_report_analysis_folder where parent_id=@CustomTables_id;
select depth into @CustomTables_depth from ld_report_analysis_folder where analysisfolder_id=@CustomTables_id;

insert into ld_report_analysis_folder (`name`,folderlabel_zh,folderlabel_en,parent_id,description,smcreatorid,createdtime,sequence,visible,systemdefault,depth )
select usereport.report_name,usereport.report_name,usereport.report_name,@CustomTables_id,'原【自定义统计表】',1,NOW(),@CustomTables_sequence:=@CustomTables_sequence+1,'yes','yes',@CustomTables_depth+1
from (
    select * from ld_customtable where isfolder='yes' order by sequence asc
    )usereport where ifnull(usereport.analysisfolder_id,0)=0;

update ld_customtable a
    left join ld_report_analysis_folder b on a.`report_name`=b.`name`
    set a.analysisfolder_id=b.analysisfolder_id
where a.isfolder='yes';

update ld_customtable parenttable
    inner join ld_customtable childtable on parenttable.report_id=childtable.parent_id
    left join ld_report_analysis_folder b on childtable.`report_name`=b.`name`
    set b.parent_id=parenttable.analysisfolder_id,b.depth=childtable.`level`+1
where childtable.isfolder='yes';

update ld_customtable child
    left join ld_customtable parent on child.parent_id=parent.report_id
    set child.analysisfolder_id=parent.analysisfolder_id
where child.parent_id>0;
delimiter;

call AddColumn('ld_usereport','deleted','INT','2','0');
call AddColumn('ld_comprehensivereport','deleted','INT','2','0');
call AddColumn('ld_customreport_info','deleted','INT','2','0');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','statisticalGraphics','统计图','jspop' from dual
where not exists(select 1 from ld_desk where labelbol='statisticalGraphics' and Labeltype='jspop' and languagetype='zh');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','statisticalGraphics','statistical graphics','jspop' from dual
where not exists(select 1 from ld_desk where labelbol='statisticalGraphics' and Labeltype='jspop' and languagetype='en');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','MODULE','模块','jspop' from dual
where not exists(select 1 from ld_desk where labelbol='MODULE' and Labeltype='jspop' and languagetype='zh');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','MODULE','Module','jspop' from dual
where not exists(select 1 from ld_desk where labelbol='MODULE' and Labeltype='jspop' and languagetype='en');
delimiter;

call AddColumn('ld_customreport_info','approveallocatetype','INT','11','0');
call AddColumn('ld_usereport','approveallocatetype','INT','11','0');
call AddColumn('ld_comprehensivereport','approveallocatetype','INT','11','0');
call AddColumn('ld_report_analysis_folder','approveallocatetype','INT','11','0');
delimiter;

insert into ld_report_analysis2user (report_id,modulename,userid,sequence)
select a.analysisfolder_id,'ReportAnalysis','',a.sequence
from (
	 select a.* from ld_report_analysis_folder a
	 where a.analysisfolder_id not in (select report_id from ld_report_analysis2user where modulename='ReportAnalysis') and
					 a.deleted=0
	 order by sequence asc
)a ;

insert into ld_report_analysis2user (report_id,modulename,userid,sequence)
select a.usereportid,'OftenUseReport','',a.sequence
from (
	 select a.* from ld_usereport a
	 where a.usereportid not in (select report_id from ld_report_analysis2user where modulename='OftenUseReport') and
					 a.deleted=0
	 order by sequence asc
)a ;

insert into ld_report_analysis2user (report_id,modulename,userid,sequence)
select a.report_id,'Customreport','',a.sequence
from (
	select a.* from ld_customreport_info a
	where a.report_id not in (select report_id from ld_report_analysis2user where modulename='Customreport') and
				 a.deleted=0
	order by a.sequence asc
)a ;

insert into ld_report_analysis2user (report_id,modulename,userid,sequence)
select a.id,'Comprehensivereport','',a.id as sequence
from (
	 select a.* from ld_comprehensivereport a
	 where a.id not in (select report_id from ld_report_analysis2user where modulename='Comprehensivereport') and
					 a.deleted=0
)a ;


insert into ld_report_analysis2user (report_id,modulename,userid,sequence)
select a.report_id,'CustomEcharts','',a.sequence
from (
	 select a.* from ld_customreport a
	 where a.report_id not in (select report_id from ld_report_analysis2user where modulename='CustomEcharts') and
					 a.deleted=0
	 order by sequence asc
)a ;

insert into ld_report_analysis2user (report_id,modulename,userid,sequence)
select a.report_id,'CustomTables','',a.sequence
from (
 select a.* from ld_customtable a
 where a.report_id not in (select report_id from ld_report_analysis2user where modulename='CustomTables') and
				 a.deleted=0
 order by sequence asc
)a ;
delimiter;

update ld_linkmodulecustom
set url=REPLACE(url,'file=DetailView','file=CustomTablesDetailView')
where linkmodule='CustomTables' ;
delimiter;

DROP PROCEDURE IF EXISTS `ldcrm_add_profile_for_reportanalysis`;
delimiter ||
CREATE PROCEDURE `ldcrm_add_profile_for_reportanalysis`(
)
BEGIN

	DECLARE tmp_profileid INT(19) DEFAULT 0;

	DECLARE MYCUSOR CURSOR FOR SELECT profileid FROM ld_profile WHERE profileid>0;

	DECLARE CONTINUE HANDLER FOR SQLSTATE '02000' SET tmp_profileid = NULL;

	SET @tabid=(SELECT tabid FROM ld_tab WHERE `name`='ReportAnalysis');

	IF NOT EXISTS (SELECT 1 FROM ld_profile2standardpermissions WHERE tabid=@tabid) THEN
		OPEN MYCUSOR;
		FETCH MYCUSOR INTO tmp_profileid;
		WHILE(tmp_profileid IS NOT NULL) DO
			SET @profileid=tmp_profileid;
			
			if(select GROUP_CONCAT(b.`name` order by b.tabid asc )from ld_profile2standardpermissions a LEFT JOIN ld_tab b ON b.tabid=a.tabid
                WHERE b.`name` IN ('Customreport','OftenUseReport','CustomEcharts','CustomTables','Comprehensivereport')AND a.profileid=1 AND a.operation=3
                   )='Comprehensivereport,OftenUseReport,Customreport,CustomEcharts,CustomTables' then
                INSERT INTO ld_profile2standardpermissions(profileid,tabid,operation,permissions,sequence)
                SELECT
                    @profileid AS profileid,
                    @tabid AS tabid,
                    3,
                    0,
                    0
                FROM ld_profile2standardpermissions a
                         LEFT JOIN ld_tab b ON b.tabid=a.tabid
                WHERE b.`name` IN ('Customreport','OftenUseReport','CustomEcharts','CustomTables','Comprehensivereport')
                  AND a.profileid=@profileid
                  AND a.operation=3
                    LIMIT 1;
            end if;

			if(select GROUP_CONCAT(b.`name` order by b.tabid asc )from ld_profile2standardpermissions a LEFT JOIN ld_tab b ON b.tabid=a.tabid
               WHERE b.`name` IN ('Customreport','OftenUseReport','CustomEcharts','CustomTables','Comprehensivereport')AND a.profileid=@profileid AND a.operation=11
                   )='Comprehensivereport,OftenUseReport,Customreport,CustomEcharts,CustomTables' then
               INSERT INTO ld_profile2standardpermissions(profileid,tabid,operation,permissions,sequence)
                SELECT
                    @profileid AS profileid,
                    @tabid AS tabid,
                    1,
                    IFNULL(MIN(a.permissions),1),
                    101
                FROM ld_profile2standardpermissions a
                         LEFT JOIN ld_tab b ON b.tabid=a.tabid
                WHERE b.`name` IN ('Customreport','OftenUseReport','CustomEcharts','CustomTables','Comprehensivereport')
                  AND a.profileid=@profileid
                  AND a.operation=11;

                INSERT INTO ld_profile2standardpermissions(profileid,tabid,operation,permissions,sequence)
                SELECT
                    @profileid AS profileid,
                    @tabid AS tabid,
                    11,
                    IFNULL(MIN(a.permissions),1),
                    201
                FROM ld_profile2standardpermissions a
                         LEFT JOIN ld_tab b ON b.tabid=a.tabid
                WHERE b.`name` IN ('Customreport','OftenUseReport','CustomEcharts','CustomTables','Comprehensivereport')
                  AND a.profileid=@profileid
                  AND a.operation=11;
            end if;


			if(select GROUP_CONCAT(b.`name` order by b.tabid asc )from ld_profile2standardpermissions a LEFT JOIN ld_tab b ON b.tabid=a.tabid
               WHERE b.`name` IN ('Customreport','OftenUseReport','CustomEcharts','CustomTables','Comprehensivereport')AND a.profileid=@profileid AND a.operation=2
                   )='Comprehensivereport,OftenUseReport,Customreport,CustomEcharts,CustomTables' then
               INSERT INTO ld_profile2standardpermissions(profileid,tabid,operation,permissions,sequence)
            SELECT
                @profileid AS profileid,
                @tabid AS tabid,
                2,
                IFNULL(MIN(a.permissions),1),
                301
            FROM ld_profile2standardpermissions a
                     LEFT JOIN ld_tab b ON b.tabid=a.tabid
            WHERE b.`name` IN ('Customreport','OftenUseReport','CustomEcharts','CustomTables','Comprehensivereport')
              AND a.profileid=@profileid
              AND a.operation=2;
            end if;

			if(select GROUP_CONCAT(b.`name` order by b.tabid asc )from ld_profile2standardpermissions a LEFT JOIN ld_tab b ON b.tabid=a.tabid
               WHERE b.`name` IN ('Customreport','OftenUseReport','CustomEcharts','CustomTables','Comprehensivereport')AND a.profileid=@profileid AND a.operation=13
                   )='Comprehensivereport,OftenUseReport,Customreport,CustomEcharts,CustomTables' then
               INSERT INTO ld_profile2standardpermissions(profileid,tabid,operation,permissions,sequence)
            SELECT
                @profileid AS profileid,
                @tabid AS tabid,
                13,
                IFNULL(MIN(a.permissions),1),
                401
            FROM ld_profile2standardpermissions a
                     LEFT JOIN ld_tab b ON b.tabid=a.tabid
            WHERE b.`name` IN ('Customreport','OftenUseReport','CustomEcharts','CustomTables','Comprehensivereport')
              AND a.profileid=@profileid
              AND a.operation=13;
            end if;

			if(select GROUP_CONCAT(b.`name` order by b.tabid asc )from ld_profile2standardpermissions a LEFT JOIN ld_tab b ON b.tabid=a.tabid
               WHERE b.`name` IN ('Customreport','OftenUseReport','CustomEcharts','CustomTables','Comprehensivereport')AND a.profileid=@profileid AND a.operation=44
                   )='Comprehensivereport,OftenUseReport,Customreport,CustomEcharts,CustomTables' then
               INSERT INTO ld_profile2standardpermissions(profileid,tabid,operation,permissions,sequence)
            SELECT
                @profileid AS profileid,
                @tabid AS tabid,
                6,
                IFNULL(MIN(a.permissions),1),
                501
            FROM ld_profile2standardpermissions a
                     LEFT JOIN ld_tab b ON b.tabid=a.tabid
            WHERE b.`name` IN ('Customreport','OftenUseReport','CustomEcharts','CustomTables','Comprehensivereport')
              AND a.profileid=@profileid
              AND a.operation=44;
            end if;

			if(select GROUP_CONCAT(b.`name` order by b.tabid asc )from ld_profile2standardpermissions a LEFT JOIN ld_tab b ON b.tabid=a.tabid
               WHERE b.`name` IN ('Customreport','OftenUseReport','CustomEcharts','CustomTables','Comprehensivereport')AND a.profileid=@profileid AND a.operation=45
                   )='Comprehensivereport,OftenUseReport,Customreport,CustomEcharts,CustomTables' then
               INSERT INTO ld_profile2standardpermissions(profileid,tabid,operation,permissions,sequence)
            SELECT
                @profileid AS profileid,
                @tabid AS tabid,
                45,
                IFNULL(MIN(a.permissions),1),
                601
            FROM ld_profile2standardpermissions a
                     LEFT JOIN ld_tab b ON b.tabid=a.tabid
            WHERE b.`name` IN ('Customreport','OftenUseReport','CustomEcharts','CustomTables','Comprehensivereport')
              AND a.profileid=@profileid
              AND a.operation=45;
            end if;

                        SET @i=0;
            UPDATE ld_profile2standardpermissions SET sequence=(@i:=@i+1) WHERE tabid=@tabid AND profileid=@profileid ORDER BY sequence;

			IF NOT EXISTS (SELECT 1 FROM ld_profile2tab WHERE tabid=@tabid AND profileid=@profileid) THEN
                            INSERT INTO ld_profile2tab(profileid,tabid,permissions)
            SELECT profileid,@tabid,IF(MIN(permissions)=0,1,0) FROM ld_profile2standardpermissions WHERE tabid=@tabid AND profileid=@profileid;
            END IF;

			IF NOT EXISTS (SELECT 1 FROM ld_profile2standardpermissions WHERE tabid=@tabid AND profileid=@profileid AND permissions=0) THEN
            UPDATE ld_profile2standardpermissions SET permissions=1 WHERE tabid=@tabid AND profileid=@profileid AND operation=0;
            END IF;

			FETCH MYCUSOR INTO tmp_profileid;
			END WHILE;
		CLOSE MYCUSOR;
	END IF;
END ||
delimiter;

CALL ldcrm_add_profile_for_reportanalysis();
delimiter;



update ld_report_analysis2user a
    left join(
    select GROUP_CONCAT(userid) as userids,report_id from ld_customreport2user GROUP BY report_id
    )b on a.report_id=b.report_id and a.modulename='Customreport'
    set a.userid=b.userids
where a.modulename='Customreport';


update ld_report_analysis2user a
    left join(
    select GROUP_CONCAT(userid) as userids,report_id from ld_customecharts2user
    where userid>0
    GROUP BY report_id
    )b on a.report_id=b.report_id and a.modulename='CustomEcharts'
    set a.userid=b.userids
where a.modulename='CustomEcharts';

update ld_report_analysis2user a
    left join(
    select GROUP_CONCAT(userid) as userids,report_id from ld_customtable2user
    where userid>0
    GROUP BY report_id
    )b on a.report_id=b.report_id and a.modulename='CustomTables'
    set a.userid=b.userids
where a.modulename='CustomTables';
delimiter;

SET @labelbol = 'CONFIGUREBASICINFO';
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'zh',@labelbol,'配置基本信息','fixedstr' FROM DUAL 
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol=@labelbol and Labeltype='fixedstr');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'en',@labelbol,'Configure basic information','fixedstr' FROM DUAL 
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol=@labelbol and Labeltype='fixedstr');
delimiter;

SET @labelbol = 'CONFIGUREPROCESS';
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'zh',@labelbol,'配置流程','fixedstr' FROM DUAL 
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol=@labelbol and Labeltype='fixedstr');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'en',@labelbol,'Configure process','fixedstr' FROM DUAL 
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol=@labelbol and Labeltype='fixedstr');
delimiter;

UPDATE ld_desk SET fieldlabel = '强制驳回审批' where labelbol = 'FORCEDREJECTSUBMITAPPROVAL' AND Labeltype = 'fixedstr' AND languagetype = 'zh';
UPDATE ld_desk SET fieldlabel = 'Forced rejection of approval' where labelbol = 'FORCEDREJECTSUBMITAPPROVAL' AND Labeltype = 'fixedstr' AND languagetype = 'en';
delimiter;


update ld_tabdetailfield set fieldtype='SourceAmount',savedatabase='yes' where 
tabid in(select tabid from ld_tab where name='cashbill' ) and 
(columnname='received_amount' or columnname='source_total');
delimiter;

update ld_field set allowedit='no' where tablename='ld_account' and columnname in ('recharge_amount','balance_amount','order_amount');
delimiter;

update ld_linkmodulecustom
set url=REPLACE(url,'module=CustomEcharts','module=ReportAnalysis')
where linkmodule='CustomEcharts' ;
delimiter;
update ld_linkmodulecustom
set url=REPLACE(url,'action=CustomEchartsAjax','action=ReportAnalysisAjax')
where linkmodule='CustomEcharts' ;
delimiter;

update ld_linkmodulecustom
set url=REPLACE(url,'module=CustomTables','module=ReportAnalysis')
where linkmodule='CustomTables' ;
delimiter;
update ld_linkmodulecustom
set url=REPLACE(url,'action=CustomTablesAjax','action=ReportAnalysisAjax')
where linkmodule='CustomTables' ;
delimiter;

UPDATE ld_tab SET presence=1 WHERE name IN ('OftenUseReport','Customreport','CustomEcharts','CustomTables','Comprehensivereport');
delimiter;

UPDATE ld_report_analysis2user a
LEFT JOIN (
	SELECT
		a.usereportid,
		GROUP_CONCAT(DISTINCT a.id ORDER BY a.id) AS user_range
	FROM (
		SELECT
			u.id,
			b.usereportid
		FROM (
			SELECT
				profileid,
				substring_index(substring_index(a.relatednames,',', b.seq+1 ),',',- 1) AS report_name
			FROM ld_profile2standardpermissions a
			LEFT JOIN sequence b ON b.seq<(length(a.relatednames)-length( REPLACE(a.relatednames,',',''))+1)
			WHERE a.tabid=(SELECT tabid FROM ld_tab WHERE `name`='OftenUseReport')
			AND IFNULL(a.relatednames,'')<>''
		) a
		LEFT JOIN ld_usereport b ON b.name=a.report_name
		LEFT JOIN ld_users u ON u.profileid=a.profileid
		WHERE u.id>0
		GROUP BY b.usereportid,u.id
	UNION
		SELECT
			b.id,
			a.usereportid
		FROM ld_usereport a
		CROSS JOIN (SELECT id FROM ld_users WHERE is_admin='on' AND status='active') b
	) a
	GROUP BY a.usereportid
) b ON b.usereportid=a.report_id
SET a.userid=b.user_range
WHERE a.modulename='OftenUseReport';

SET @sql_old='SELECT CONCAT(ld_account.bill_state,ld_account.bill_city,IFNULL(ld_account.bill_area,""),ld_account.bill_street) AS address
FROM ld_account
WHERE ld_account.deleted = 0 AND accountid = ?
UNION 
SELECT CONCAT(ld_account.bill_state,ld_account.bill_city,IFNULL(ld_account.bill_area,""),ld_account.bill_street) AS address
FROM ld_contactdetails
INNER JOIN ld_account ON ld_account.accountid = ld_contactdetails.accountid
WHERE ld_account.deleted = 0 AND ld_contactdetails.contactid = ?
UNION 
SELECT CONCAT(ld_account.bill_state,ld_account.bill_city,IFNULL(ld_account.bill_area,""),ld_account.bill_street) AS address
FROM ld_contactrecords
INNER JOIN ld_account ON ld_account.accountid = ld_contactrecords.accountid
WHERE ld_account.deleted = 0 AND ld_contactrecords.contactrecordID = ?
UNION 
SELECT CONCAT(ld_account.bill_state,ld_account.bill_city,IFNULL(ld_account.bill_area,""),ld_account.bill_street) AS address
FROM ld_potential
INNER JOIN ld_account ON ld_account.accountid = ld_potential.accountid
WHERE ld_account.deleted = 0 AND ld_potential.potentialid = ?
UNION 
SELECT CONCAT(ld_account.bill_state,ld_account.bill_city,IFNULL(ld_account.bill_area,""),ld_account.bill_street) AS address
FROM ld_troubletickets
INNER JOIN ld_account ON ld_account.accountid = ld_troubletickets.accountid
WHERE ld_account.deleted = 0 AND ld_troubletickets.ticketid = ?
UNION 
SELECT CONCAT(ld_account.bill_state,ld_account.bill_city,IFNULL(ld_account.bill_area,""),ld_account.bill_street) AS address
FROM ld_project
INNER JOIN ld_account ON ld_account.accountid = ld_project.accountid
WHERE ld_account.deleted = 0 AND ld_project.projectid = ?
UNION
SELECT CONCAT(ld_leads.bill_state,ld_leads.bill_city,IFNULL(ld_leads.bill_area,""),ld_leads.bill_street) AS address
FROM ld_leads
WHERE deleted = 0 AND leadsid = ?';

SET @sql1 = 'SELECT CONCAT(
					IF(LOCATE(ld_account.bill_state,ld_account.bill_street)>0 or LOCATE(ld_account.bill_state,ld_account.bill_city)>0 ,"",ld_account.bill_state),
					IF(LOCATE(ld_account.bill_city,ld_account.bill_street)>0,"",ld_account.bill_city),
					IF(LOCATE(ld_account.bill_area,ld_account.bill_street)>0,"",ld_account.bill_area),
					ld_account.bill_street) AS address
FROM ld_account
WHERE ld_account.deleted = 0 AND accountid = ?
UNION 
SELECT CONCAT(
					IF(LOCATE(ld_account.bill_state,ld_account.bill_street)>0 or LOCATE(ld_account.bill_state,ld_account.bill_city)>0 ,"",ld_account.bill_state),
					IF(LOCATE(ld_account.bill_city,ld_account.bill_street)>0,"",ld_account.bill_city),
					IF(LOCATE(ld_account.bill_area,ld_account.bill_street)>0,"",ld_account.bill_area),
					ld_account.bill_street) AS address
FROM ld_contactdetails
INNER JOIN ld_account ON ld_account.accountid = ld_contactdetails.accountid
WHERE ld_account.deleted = 0 AND ld_contactdetails.contactid = ?
UNION 
SELECT CONCAT(
					IF(LOCATE(ld_account.bill_state,ld_account.bill_street)>0 or LOCATE(ld_account.bill_state,ld_account.bill_city)>0 ,"",ld_account.bill_state),
					IF(LOCATE(ld_account.bill_city,ld_account.bill_street)>0,"",ld_account.bill_city),
					IF(LOCATE(ld_account.bill_area,ld_account.bill_street)>0,"",ld_account.bill_area),
					ld_account.bill_street) AS address
FROM ld_contactrecords
INNER JOIN ld_account ON ld_account.accountid = ld_contactrecords.accountid
WHERE ld_account.deleted = 0 AND ld_contactrecords.contactrecordID = ?
UNION 
SELECT CONCAT(
					IF(LOCATE(ld_account.bill_state,ld_account.bill_street)>0 or LOCATE(ld_account.bill_state,ld_account.bill_city)>0 ,"",ld_account.bill_state),
					IF(LOCATE(ld_account.bill_city,ld_account.bill_street)>0,"",ld_account.bill_city),
					IF(LOCATE(ld_account.bill_area,ld_account.bill_street)>0,"",ld_account.bill_area),
					ld_account.bill_street) AS address
FROM ld_potential
INNER JOIN ld_account ON ld_account.accountid = ld_potential.accountid
WHERE ld_account.deleted = 0 AND ld_potential.potentialid = ?
UNION 
SELECT CONCAT(
					IF(LOCATE(ld_account.bill_state,ld_account.bill_street)>0 or LOCATE(ld_account.bill_state,ld_account.bill_city)>0 ,"",ld_account.bill_state),
					IF(LOCATE(ld_account.bill_city,ld_account.bill_street)>0,"",ld_account.bill_city),
					IF(LOCATE(ld_account.bill_area,ld_account.bill_street)>0,"",ld_account.bill_area),
					ld_account.bill_street) AS address
FROM ld_troubletickets
INNER JOIN ld_account ON ld_account.accountid = ld_troubletickets.accountid
WHERE ld_account.deleted = 0 AND ld_troubletickets.ticketid = ?
UNION 
SELECT CONCAT(
					IF(LOCATE(ld_account.bill_state,ld_account.bill_street)>0 or LOCATE(ld_account.bill_state,ld_account.bill_city)>0 ,"",ld_account.bill_state),
					IF(LOCATE(ld_account.bill_city,ld_account.bill_street)>0,"",ld_account.bill_city),
					IF(LOCATE(ld_account.bill_area,ld_account.bill_street)>0,"",ld_account.bill_area),
					ld_account.bill_street) AS address
FROM ld_project
INNER JOIN ld_account ON ld_account.accountid = ld_project.accountid
WHERE ld_account.deleted = 0 AND ld_project.projectid = ?
UNION
SELECT CONCAT(
					IF(LOCATE(ld_leads.bill_state,ld_leads.bill_street)>0 or LOCATE(ld_leads.bill_state,ld_leads.bill_city)>0 ,"",ld_leads.bill_state),
					IF(LOCATE(ld_leads.bill_city,ld_leads.bill_street)>0,"",ld_leads.bill_city),
					IF(LOCATE(ld_leads.bill_area,ld_leads.bill_street)>0,"",ld_leads.bill_area),
					ld_leads.bill_street) AS address
FROM ld_leads
WHERE deleted = 0 AND leadsid = ?';
select tabid into @tabid from ld_tab where name='singin';
select fieldid into @fieldid_rd from ld_field where columnname='record' and tabid=@tabid;
select fieldid into @fieldid_ss from ld_field where columnname='address' and tabid=@tabid;
update ld_related_field set fromvalue_info=@sql1 where effect_fieldid=@fieldid_ss and trigger_fieldid=@fieldid_rd AND fromvalue_info=@sql_old;
delimiter;

call AddColumn('ld_questionnaire_topic','referencemodule','varchar','25',NULL);
delimiter;
call AddColumn('ld_questionnaire_topic','advance_demand','text','',NULL);
delimiter;
call AddColumn('ld_questionnaire_topic','advance_demand_groups','text','',NULL);
delimiter;
call AddColumn('ld_questionnaire_topic','maxrowsshow','int','11',NULL);
delimiter;
call AddColumn('ld_questionnaire_topic','fieldonly','int','11',NULL);
delimiter;
call AddColumn('ld_questionnaire_topic','approve_demand','int','4',NULL);
delimiter;

CREATE TABLE IF NOT EXISTS `ld_questionnaire_chartsave` (
  `chartsaveid` int(11) NOT NULL AUTO_INCREMENT,
  `questionnaireid` int(11) DEFAULT NULL,
  `createdtime` datetime DEFAULT NULL,
  `seqtime` timestamp(6) NULL DEFAULT NULL,
  PRIMARY KEY (`chartsaveid`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
delimiter;

call AddColumn('ld_questionnaire_chart','chartsaveid','int','19',NULL);
delimiter;
-- 2022-11-18


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

UPDATE ld_version SET old_version='V8.4.8.1',current_version='V8.4.8.1',remark='V8.4.8.1-20221118',wx_version='V8.4.8.1';
delimiter;