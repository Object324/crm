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

select cvid into @cvid from ld_customview where entitytype = 'Accounts' and viewname = '今日待联系' and customcategory = 'ALLACCOUNT';
update ld_cvadvfilter set columnname = 'ld_account:lastcontactdate:lastcontactdate:Accounts_fieldlabel:DT' where cvid =@cvid and columnname = 'ld_account:lastcontactdate:lastcontactdate:Accounts_fieldlabel:D';
delimiter;

call Del_ForeignKey('ld_parenttabrel', 'ld_parenttabrel_ibfk_1');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','Allownewordinarycustomers','允许新建“普通客户”','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='Allownewordinarycustomers' and Labeltype='fixedstr' and languagetype='zh');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','Allownewordinarycustomers','Allow new ordinary customers','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='Allownewordinarycustomers' and Labeltype='fixedstr' and languagetype='en');
delimiter;

call AddColumn('ld_account_public','is_commonaccount_create','varchar','50',NULL);
delimiter;

alter table ld_account_public alter is_commonaccount_create set default 'yes';
update ld_account_public set is_commonaccount_create = 'yes' where is_commonaccount_create is NULL;
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','Allownewordinarycustomers','允许新建“普通客户”','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='Allownewordinarycustomers' and Labeltype='fixedstr' and languagetype='zh');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','Allownewordinarycustomers','Allow new ordinary customers','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='Allownewordinarycustomers' and Labeltype='fixedstr' and languagetype='en');
delimiter;

call AddColumn('ld_account_public','is_commonaccount_create','varchar','50',NULL);
alter table ld_account_public alter is_commonaccount_create set default 'yes';
update ld_account_public set is_commonaccount_create = 'yes' where is_commonaccount_create is NULL;
delimiter;
select blockid into @blockid from ld_settings_field where `name`='LBL_BACKUP_SET';
select sequence into @sequence from ld_settings_field where `name`='LBL_BACKUP_SET';

select fieldid into @fieldid  from ld_settings_field where blockid=@blockid and `name`='LBL_RESTOREDATABASE';

update ld_settings_field set sequence=sequence+2 where sequence >@sequence and ifnull(@fieldid,0)<=0 ;

update ld_settings_field_seq set id=@maxfieldid+1 where not exists(select 1 from ld_settings_field where  blockid=@blockid and `name`='LBL_RESTOREDATABASE');
select max(fieldid) into @maxfieldid from ld_settings_field ;
insert into ld_settings_field(fieldid,blockid,`name`,description,linkto,sequence,active)
select @maxfieldid+1,@blockid,'LBL_RESTOREDATABASE','LBL_RESTOREDATABASE','index.php?module=Settings&action=RestoreDataBase&parenttab=Settings',@sequence+1,0
from dual where not exists(select 1 from ld_settings_field where  blockid=@blockid and `name`='LBL_RESTOREDATABASE');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','RestoreDataBaseDemo','恢复行业账套','fixedstr' from dual 
where not exists(select  1 from ld_desk where languagetype='zh' and labelbol='RestoreDataBaseDemo' and labeltype='fixedstr');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','RestoreDataBaseDemo','Restore industry demo','fixedstr' from dual 
where not exists(select  1 from ld_desk where languagetype='en' and labelbol='RestoreDataBaseDemo' and labeltype='fixedstr');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','LBL_RESTOREDATABASE','行业账套恢复','fixedstr' from dual 
where not exists(select  1 from ld_desk where languagetype='zh' and labelbol='LBL_RESTOREDATABASE' and labeltype='fixedstr');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','LBL_RESTOREDATABASE','Restore industry demo','fixedstr' from dual 
where not exists(select  1 from ld_desk where languagetype='en' and labelbol='LBL_RESTOREDATABASE' and labeltype='fixedstr');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','BackUpBeforeResotreDemo','恢复行业演示账套，使用前请做好备份','fixedstr' from dual 
where not exists(select  1 from ld_desk where languagetype='zh' and labelbol='BackUpBeforeResotreDemo' and labeltype='fixedstr');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','BackUpBeforeResotreDemo','Please back up the current database first','fixedstr' from dual 
where not exists(select  1 from ld_desk where languagetype='en' and labelbol='BackUpBeforeResotreDemo' and labeltype='fixedstr');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','Industry','所属行业','fixedstr' from dual 
where not exists(select  1 from ld_desk where languagetype='zh' and labelbol='Industry' and labeltype='fixedstr');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','Industry','industry','fixedstr' from dual 
where not exists(select  1 from ld_desk where languagetype='en' and labelbol='Industry' and labeltype='fixedstr');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','IncludeDemoData','含演示数据','fixedstr' from dual 
where not exists(select  1 from ld_desk where languagetype='zh' and labelbol='IncludeDemoData' and labeltype='fixedstr');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','IncludeDemoData','Include demo data','fixedstr' from dual 
where not exists(select  1 from ld_desk where languagetype='en' and labelbol='IncludeDemoData' and labeltype='fixedstr');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','WithoutDemoData','无演示数据','fixedstr' from dual 
where not exists(select  1 from ld_desk where languagetype='zh' and labelbol='WithoutDemoData' and labeltype='fixedstr');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','WithoutDemoData','Without demo data','fixedstr' from dual 
where not exists(select  1 from ld_desk where languagetype='en' and labelbol='WithoutDemoData' and labeltype='fixedstr');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','MakeSureBackUp','恢复行业账套将重置账套模板，<span style="color:red">现有数据会全部丢失</span>。请确认是否已经做好备份？','fixedstr' from dual 
where not exists(select  1 from ld_desk where languagetype='zh' and labelbol='MakeSureBackUp' and labeltype='fixedstr');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','MakeSureBackUp','After restoring the industry demo, all existing data will be lost. Make sure the backup is done！','fixedstr' from dual 
where not exists(select  1 from ld_desk where languagetype='en' and labelbol='MakeSureBackUp' and labeltype='fixedstr');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','HadBackUp','已备份，立即恢复','fixedstr' from dual 
where not exists(select  1 from ld_desk where languagetype='zh' and labelbol='HadBackUp' and labeltype='fixedstr');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','HadBackUp','Backed up','fixedstr' from dual 
where not exists(select  1 from ld_desk where languagetype='en' and labelbol='HadBackUp' and labeltype='fixedstr');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','NoneBackUp','未备份，立即备份','fixedstr' from dual 
where not exists(select  1 from ld_desk where languagetype='zh' and labelbol='NoneBackUp' and labeltype='fixedstr');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','NoneBackUp','No backup','fixedstr' from dual 
where not exists(select  1 from ld_desk where languagetype='en' and labelbol='NoneBackUp' and labeltype='fixedstr');
delimiter;

CREATE TABLE if not exists `ld_industrydemo` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `industry_zh` varchar(100) DEFAULT NULL,
  `industry_en` varchar(100) DEFAULT NULL,
  `datasql_path` varchar(255) DEFAULT NULL,
  `templatefile_path` varchar(255) DEFAULT NULL,
  `suit_crmversion` varchar(50) DEFAULT NULL,
  `sequence` smallint(6) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
delimiter;

CREATE TABLE if not exists `ld_industryhistory` (
  `id` int(19) NOT NULL AUTO_INCREMENT,
  `user_name` varchar(50) DEFAULT NULL,
  `createdtime` datetime DEFAULT NULL,
  `datasql_path` varchar(100) DEFAULT NULL,
  `demodata` varchar(20) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','RestoreDataBase','恢复账套','fixedstr' from dual 
where not exists(select  1 from ld_desk where languagetype='zh' and labelbol='RestoreDataBase' and labeltype='fixedstr');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','RestoreDataBase','Restore','fixedstr' from dual 
where not exists(select  1 from ld_desk where languagetype='en' and labelbol='RestoreDataBase' and labeltype='fixedstr');
delimiter;
-- 2021-03-10

DELETE FROM ld_industrydemo WHERE id BETWEEN 1 AND 15;
INSERT INTO `ld_industrydemo` (`id`, `industry_zh`, `industry_en`, `datasql_path`, `templatefile_path`, `suit_crmversion`, `sequence`) VALUES ('1', '出厂设置', 'Factory settings', 'IndustryDemo/001_factory.sql', NULL, 'all', '1');
INSERT INTO `ld_industrydemo` (`id`, `industry_zh`, `industry_en`, `datasql_path`, `templatefile_path`, `suit_crmversion`, `sequence`) VALUES ('2', 'IT行业', 'IT', 'IndustryDemo/002_it.sql', NULL, 'all', '2');
INSERT INTO `ld_industrydemo` (`id`, `industry_zh`, `industry_en`, `datasql_path`, `templatefile_path`, `suit_crmversion`, `sequence`) VALUES ('3', '工程项目行业', 'Project', 'IndustryDemo/003_gongchengxiangmu.sql', 'IndustryDemo/templatefile/003_gongchengxiangmu', 'all', '3');
INSERT INTO `ld_industrydemo` (`id`, `industry_zh`, `industry_en`, `datasql_path`, `templatefile_path`, `suit_crmversion`, `sequence`) VALUES ('4', '物流运输行业', 'Logistics transportation', 'IndustryDemo/004_wuliuyunshu.sql', NULL, 'all', '4');
INSERT INTO `ld_industrydemo` (`id`, `industry_zh`, `industry_en`, `datasql_path`, `templatefile_path`, `suit_crmversion`, `sequence`) VALUES ('5', '教育培训行业', 'Education and training', 'IndustryDemo/005_jiaoyupeixun.sql', NULL, 'all', '5');
INSERT INTO `ld_industrydemo` (`id`, `industry_zh`, `industry_en`, `datasql_path`, `templatefile_path`, `suit_crmversion`, `sequence`) VALUES ('6', '装饰家装行业', 'Home decoration', 'IndustryDemo/006_jiazhuang.sql', NULL, 'all', '6');
INSERT INTO `ld_industrydemo` (`id`, `industry_zh`, `industry_en`, `datasql_path`, `templatefile_path`, `suit_crmversion`, `sequence`) VALUES ('7', '律师律所行业', 'Law firm', 'IndustryDemo/007_lvsuo.sql', NULL, 'all', '7');
INSERT INTO `ld_industrydemo` (`id`, `industry_zh`, `industry_en`, `datasql_path`, `templatefile_path`, `suit_crmversion`, `sequence`) VALUES ('8', '电子制造行业', 'Electronic manufacturing', 'IndustryDemo/008_dianzizhizao.sql', NULL, 'all', '8');
INSERT INTO `ld_industrydemo` (`id`, `industry_zh`, `industry_en`, `datasql_path`, `templatefile_path`, `suit_crmversion`, `sequence`) VALUES ('9', '机械制造行业', 'Machinery manufacturing', 'IndustryDemo/009_jixiezhizao.sql', NULL, 'all', '9');
INSERT INTO `ld_industrydemo` (`id`, `industry_zh`, `industry_en`, `datasql_path`, `templatefile_path`, `suit_crmversion`, `sequence`) VALUES ('10', '五金行业', 'Hardware', 'IndustryDemo/010_wujin.sql', NULL, 'all', '10');
INSERT INTO `ld_industrydemo` (`id`, `industry_zh`, `industry_en`, `datasql_path`, `templatefile_path`, `suit_crmversion`, `sequence`) VALUES ('11', '医疗器械行业', 'Medical apparatus and instruments', 'IndustryDemo/011_yiliaoqixie.sql', NULL, 'all', '11');
INSERT INTO `ld_industrydemo` (`id`, `industry_zh`, `industry_en`, `datasql_path`, `templatefile_path`, `suit_crmversion`, `sequence`) VALUES ('12', '房产租赁行业', '\r\nReal estate leasing', 'IndustryDemo/012_fangchanzulin.sql', NULL, 'all', '12');
INSERT INTO `ld_industrydemo` (`id`, `industry_zh`, `industry_en`, `datasql_path`, `templatefile_path`, `suit_crmversion`, `sequence`) VALUES ('13', '咨询认证行业', 'Consulting certification', 'IndustryDemo/013_zixunrenzheng.sql', NULL, 'all', '13');
INSERT INTO `ld_industrydemo` (`id`, `industry_zh`, `industry_en`, `datasql_path`, `templatefile_path`, `suit_crmversion`, `sequence`) VALUES ('14', '设备维修行业', 'Equipment maintenance', 'IndustryDemo/014_shebeiweixiu.sql', NULL, 'all', '14');
INSERT INTO `ld_industrydemo` (`id`, `industry_zh`, `industry_en`, `datasql_path`, `templatefile_path`, `suit_crmversion`, `sequence`) VALUES ('15', '环境检测行业', 'Environmental monitoring', 'IndustryDemo/015_huanjingjiance.sql', NULL, 'all', '15');

DROP PROCEDURE if EXISTS `AddDownloadPrivewProfileByTabid`;
delimiter ||
create PROCEDURE AddDownloadPrivewProfileByTabid(ttabid int(19))
begin
	
	declare done  int  default 0;
	declare pprofileid  int ;
	declare cur1 CURSOR FOR SELECT profileid  FROM  ld_profile;
	declare continue handler  for not   found  SET done =1;
	set @tabid=ttabid;
set @sql =concat('select tabid into @attachmenttabid from ld_tab where name="Attachment"');
	prepare stmt from @sql;
	execute stmt;
	deallocate  prepare stmt;

	OPEN cur1;
	Fetch cur1 into pprofileid;
	 loop1: while  done<>1 DO
				 select actionid into @downloadoperation from ld_actionmapping where actionname='download';
		   		select actionid into @previewoperation from ld_actionmapping where actionname='preview';
					select  permissions into @permissions from ld_profile2standardpermissions where profileid=pprofileid and tabid=@attachmenttabid and operation=@downloadoperation ;
				SET @permissions=IFNULL(@permissions,'-1');					
				if @permissions='-1' THEN
								set 	done=1;
									
					end if;
			set @sql=CONCAT('insert into ld_profile2standardpermissions(profileid,tabid,operation,permissions) select  ' ,pprofileid,',',@tabid,',',@downloadoperation,',',@permissions,'  from dual  where not exists (select 1 from ld_profile2standardpermissions where profileid=',pprofileid, ' and  tabid=',@tabid,' and operation=',@downloadoperation,')' );
				  prepare stmt from @sql;
			  	execute stmt;

			   deallocate prepare stmt;
				select  permissions into @permissions from ld_profile2standardpermissions where profileid=pprofileid and  tabid=@attachmenttabid and operation=@previewoperation ;

				 set @sql=CONCAT('insert into ld_profile2standardpermissions(profileid,tabid,operation,permissions) select  ' ,pprofileid,',',@tabid,',',@previewoperation,',',@permissions,'  from dual  where not exists (select 1 from ld_profile2standardpermissions where profileid=',pprofileid, ' and  tabid=',@tabid,' and operation=',@previewoperation,')' );
				  prepare stmt from @sql;
			  	execute stmt;
			   deallocate prepare stmt;
	Fetch cur1 into pprofileid;
	end while loop1;
	close cur1;
end ||
delimiter;

DROP PROCEDURE if EXISTS `AddDownloadPrivewButtonForAllModules`;
delimiter ||
create PROCEDURE AddDownloadPrivewButtonForAllModules()
begin
	
	declare done  int  default 0;
	declare ttabid  int ;
	declare cur2 CURSOR FOR select ld_tab.tabid  from ld_tab inner join ld_field 
	on ld_field.tabid=ld_tab.tabid 
inner join ld_profileallpermission on ld_profileallpermission.tabid=ld_tab.tabid
and ld_profileallpermission.operation=1
where ld_tab.name!="Attachment" and ld_tab.name!="Reminds" and ld_tab.name!="Emails" and ld_tab.tabid!=16 group by ld_tab.tabid;
	declare continue handler  for not   found  SET done =1;


	OPEN cur2;
	Fetch cur2 into ttabid;
   select actionid into @downloadoperation from ld_actionmapping where actionname='download';
		select actionid into @previewoperation from ld_actionmapping where actionname='preview';

	 loop1: while  done<>1 DO
				select max(sequence) into @sequence from ld_profileallpermission where tabid=ttabid ;
			  set @sequence=IFNULL(@sequence,'-1');
				if @sequence<>'-1' then 
						set @sql=CONCAT('insert into ld_profileallpermission(tabid,operation,sequence) select  ' ,ttabid,',',@downloadoperation,',',@sequence+1,'  from dual  where not exists (select 1 from ld_profileallpermission where tabid=',ttabid ,' and operation=',@downloadoperation,' )' );
				
							prepare stmt from @sql;
							execute stmt;

						 deallocate prepare stmt;
					
					
							set @sql=CONCAT('insert into ld_profileallpermission(tabid,operation,sequence) select  ' ,ttabid,',',@previewoperation,',',@sequence+2,'  from dual  where not exists (select 1 from ld_profileallpermission where tabid=',ttabid ,' and operation=',@previewoperation,' )' );
							prepare stmt from @sql;
							execute stmt;

						 deallocate prepare stmt;
						call AddDownloadPrivewProfileByTabid(ttabid);
				 end if ;
				Fetch cur2 into ttabid;
	end while loop1;
	close cur2;
end ||
delimiter;

CALL AddDownloadPrivewButtonForAllModules();
DROP PROCEDURE if EXISTS `AddDownloadPrivewProfileByTabid`;
DROP PROCEDURE if EXISTS `AddDownloadPrivewButtonForAllModules`;
delimiter;

CREATE TABLE IF NOT EXISTS `ld_publicannouncementscf` (
  `publicannouncementid` int(11) NOT NULL AUTO_INCREMENT,
  PRIMARY KEY (`publicannouncementid`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
delimiter;

select count(1) into @cnt from ld_publicannouncementscf;
insert into ld_publicannouncementscf(publicannouncementid)
select publicannouncementid from ld_publicannouncement where @cnt = 0;
delimiter;

create table if not exists `ld_customreport` (
  `report_id` int(11) unsigned NOT NULL AUTO_INCREMENT,
  `report_name` varchar(255) DEFAULT NULL,
  `report_desc` text,
  `report_type` varchar(255) DEFAULT NULL,
  `parent_id` int(11) DEFAULT NULL,
  `sequence` tinyint(4) DEFAULT NULL,
  `mainmodule` varchar(255) DEFAULT NULL,
  `createdtime` datetime DEFAULT NULL,
  `modify_time` datetime DEFAULT NULL,
  `deleted` tinyint(4) DEFAULT NULL,
  `modify_id` int(11) DEFAULT NULL,
  `limit` int(11) DEFAULT NULL,
  `orderby` varchar(255) DEFAULT NULL,
  `orderby_type` varchar(255) DEFAULT NULL,
   `smcreatorid` int(11) DEFAULT '1',
  PRIMARY KEY (`report_id`)
) ENGINE=InnoDB AUTO_INCREMENT=127 DEFAULT CHARSET=utf8mb4;
delimiter;

create table if not exists `ld_customreport_chartset` (
  `report_id` int(11) NOT NULL,
  `title` text,
  `chart_type` varchar(255) DEFAULT NULL,
  `xAxis` text,
  `yAxis` text,
  `legend` text,
  `tooltip` text,
  `toolbox` text,
  PRIMARY KEY (`report_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
delimiter;

create table if not exists `ld_customreport_cvadvfilter` (
  `report_id` int(11) NOT NULL,
  `columnindex` int(11) DEFAULT NULL,
  `groupid` int(11) DEFAULT NULL,
  `columns` varchar(255) DEFAULT NULL,
  `comparator` varchar(255) DEFAULT NULL,
  `value` varchar(255) DEFAULT NULL,
  `columncondition` varchar(255) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
delimiter;

create table if not exists `ld_customreport_cvadvfilter_grouping` (
  `report_id` int(11) NOT NULL,
  `groupid` int(11) DEFAULT NULL,
  `group_condition` varchar(255) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
delimiter;

create table if not exists `ld_customreport_group` (
  `group_id` int(11) NOT NULL AUTO_INCREMENT,
  `report_id` int(11) DEFAULT NULL,
  `groupbytype` varchar(255) DEFAULT NULL,
  `columns` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`group_id`)
) ENGINE=InnoDB AUTO_INCREMENT=259 DEFAULT CHARSET=utf8mb4;
delimiter;

create table if not exists `ld_customreport_total_column` (
  `report_id` int(11) NOT NULL,
  `column_id` int(11) NOT NULL AUTO_INCREMENT,
  `total_type` varchar(255) DEFAULT NULL,
  `columns` varchar(255) DEFAULT NULL,
  `sequence` int(11) DEFAULT NULL,
  `chart_column_type` varchar(255) DEFAULT NULL,
  `color` varchar(255) DEFAULT NULL,
  `chart_column_name` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`column_id`)
) ENGINE=InnoDB AUTO_INCREMENT=364 DEFAULT CHARSET=utf8mb4;
delimiter;

call AddColumn('ld_customreport_total_column','yaxisindex','int','11','0');
call AddColumn('ld_customreport','smcreatorid','int','11','0');
call AddColumn('ld_customreport','stat_approach','varchar','255','0');
call AddColumn('ld_customreport_group','sequence','int','11','0');
call AddColumn('ld_customreport_group','bigtype','varchar','255','0');
delimiter;

insert into ld_desk (languagetype,labelbol,fieldlabel,labeltype)
select 'zh','ContactTimesRanking','跟进频次排行榜','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='ContactTimesRanking' and Labeltype='fixedstr');
delimiter;

insert into ld_desk (languagetype,labelbol,fieldlabel,labeltype)
select 'en','ContactTimesRanking','Contact Times Ranking','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='ContactTimesRanking' and Labeltype='fixedstr');
delimiter;

update ld_field set bigtype='fileattachment' where uitype=1109;
delimiter;

select wx_sequence into @wx_sequence from ld_dashboard_app where name='Returnamount';
update ld_dashboard_app set wx_sequence=wx_sequence+2 where wx_sequence>@wx_sequence;
update ld_dashboard_app set home_sequence=home_sequence+1 where home_sequence>0;
select home_sequence into @home_sequence from ld_dashboard_app where name='Returnamount';
insert into ld_dashboard_app(name,labelbol,modulenames,wx_sequence,image,presence,wx_presence,home_presence,home_sequence)
select 'ContactTimesRanking','ContactTimesRanking','',@wx_sequence+1,'dashboard_6',0,1,'',@home_sequence+1 from dual  
where not exists(select 1 from ld_dashboard_app where name='ContactTimesRanking');
delimiter;

select block_id into @block_id from ld_mobile_report_parent_tab where parenttab_label='rank';
select id into @tabid from ld_dashboard_app where name='ContactTimesRanking';
insert into ld_mobile_report_tab_rel(block_id,tabid,sequence,tab_tablename)
select @block_id,@tabid,6,'ld_tab' from dual
where not EXISTS(select 1 from ld_mobile_report_tab_rel where @block_id=@block_id and tabid=@tabid and tab_tablename='ld_tab');
delimiter;
-- 2021-03-12

update ld_homestuffdetailcondition set columns='ld_troubletickets:createdtime:createdtime:HelpDesk_fieldlabel:DT' where columns='ld_troubletickets:createdtime:createdtime:HelpDesk_fieldlabel:D';
delimiter;

update ld_homestuffdetailcondition set columns='ld_troubletickets:approvestatus:approvestatus:HelpDesk_fieldlabel:V' where columns='ld_troubletickets:approvestatus:approvestatus:Leads_fieldlabel:V';
delimiter;

select tabid into @tabid from ld_tab where name='leads';
update ld_field set allowedit='no' where tabid=@tabid and columnname='status';
delimiter;

update ld_desk set fieldlabel = '全局查找' where languagetype = 'zh' and labelbol = 'QUICKFIND' and Labeltype = 'fixedstr';
update ld_desk set fieldlabel = 'Global search' where languagetype = 'en' and labelbol = 'QUICKFIND' and Labeltype = 'fixedstr';
delimiter;

select cvid into @cvid from ld_customview where entitytype = 'Accounts' and viewname = '今日待联系' and customcategory = 'ALLACCOUNT';
update ld_cvadvfilter set columnname = 'ld_account:lastcontactdate:lastcontactdate:Accounts_fieldlabel:DT' where cvid =@cvid and columnname = 'ld_account:lastcontactdate:lastcontactdate:Accounts_fieldlabel:D';
delimiter;

CALL Del_ForeignKey('ld_parenttabrel', 'ld_parenttabrel_ibfk_1');
delimiter;
-- 2021-03-15

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

UPDATE ld_version SET old_version='V8.4.1',current_version='V8.4.1',remark='V8.4.1-20210315',wx_version='V8.4.1';
delimiter;