DROP PROCEDURE IF EXISTS `AddColumn`;
delimiter ||
CREATE  PROCEDURE `AddColumn`(
	tmp_tablename VARCHAR(50),
	tmp_columnname VARCHAR(100),
	tmp_columntype VARCHAR(50),
	tmp_columnlen INT(5),
	tmp_defaultvalue VARCHAR(255)
)
BEGIN
	
	IF NOT EXISTS (SELECT 1 FROM information_schema.COLUMNS WHERE TABLE_SCHEMA=DATABASE() AND TABLE_NAME=tmp_tablename AND COLUMN_NAME=tmp_columnname) THEN
		IF tmp_columntype='date' OR tmp_columntype='datetime' THEN
			SET @exec_sql=CONCAT('alter table ',tmp_tablename, ' add column ',tmp_columnname, ' ',tmp_columntype, ' default null');
		ELSEIF tmp_columntype='text' THEN
			IF IFNULL(tmp_defaultvalue,'')='' THEN
				SET @exec_sql=CONCAT('alter table ',tmp_tablename, ' add column ',tmp_columnname, ' ',tmp_columntype, ' default null');
			ELSE
				SET @exec_sql=CONCAT('alter table ',tmp_tablename, ' add column ',tmp_columnname, ' ',tmp_columntype, ' default \'',tmp_defaultvalue,'\'');
			END IF;
		ELSEIF tmp_columntype='decimal' THEN
			SET @exec_sql=CONCAT('alter table ',tmp_tablename, ' add column ',tmp_columnname, ' decimal(25,2) default ',tmp_defaultvalue+0);
		ELSEIF tmp_columntype='int' THEN
			IF IFNULL(tmp_columnlen,0)<=1 THEN 
				SET @this_addcolumnlen=1;
			ELSEIF tmp_columnlen>=19 THEN
				SET @this_addcolumnlen=19;
			ELSE
				SET @this_addcolumnlen=tmp_columnlen;
			END IF;

			SET @exec_sql=CONCAT('alter table ',tmp_tablename, ' add column ',tmp_columnname, ' ',tmp_columntype,'(',@this_addcolumnlen,')',' default ',ROUND(IFNULL(tmp_defaultvalue,0)+0,0));
		ELSE
			IF IFNULL(tmp_columnlen,0)<=1 THEN 
				SET @this_addcolumnlen=1;
			ELSEIF tmp_columnlen>=255 THEN
				SET @this_addcolumnlen=255;
			ELSE
				SET @this_addcolumnlen=tmp_columnlen;
			END IF;
            
			IF IFNULL(tmp_defaultvalue,'')='' THEN
					SET @exec_sql=CONCAT('alter table ',tmp_tablename, ' add column ',tmp_columnname, ' ',tmp_columntype,'(',@this_addcolumnlen,')', ' default null');
			ELSE
					SET @exec_sql=CONCAT('alter table ',tmp_tablename, ' add column ',tmp_columnname, ' ',tmp_columntype,'(',@this_addcolumnlen,')', ' default \'',IF(tmp_defaultvalue='',NULL,tmp_defaultvalue),'\'');
			END IF;

		END IF;

		PREPARE mystmt FROM @exec_sql;
		EXECUTE mystmt;
		DEALLOCATE PREPARE mystmt;
	END IF;

end ||
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
	declare cur1 CURSOR FOR SELECT fieldid,tabid   FROM  ld_field where tabid in(select tabid from ld_tab where name=tabname);
	declare continue handler  for not   found  SET done =1;

	OPEN cur1;
	Fetch cur1 into ffieldid,ttabid;

 	loop1: while  done<>1 DO
		set @sql=Concat('insert into ld_def_org_field(tabid,fieldid,visible,readonly) select ',ttabid,',',ffieldid,',',0,',',1 ,' from dual where not exists(select 1 from ld_def_org_field where fieldid=',ffieldid,')');

		prepare stmt from @sql;
	      execute stmt;
	      deallocate  prepare  stmt;
		Fetch cur1 into ffieldid,ttabid;
	end while loop1;
	close cur1;
end ||
delimiter;


DROP PROCEDURE IF EXISTS `fieldintoprofile`;
delimiter ||
CREATE  PROCEDURE `fieldintoprofile`(
	profileid int(19),
	tabname varchar(50)
)
begin
    declare done  int  default 0;
	declare ttabid  int ;
	declare ffieldid int ;
	declare cur2 CURSOR FOR SELECT fieldid,tabid   FROM  ld_field where tabid in(select tabid from ld_tab where name=tabname);
	declare continue handler  for not   found  SET done =1;

	OPEN cur2;
	Fetch cur2 into ffieldid,ttabid;

 	loop1: while  done<>1 DO
		set @sql=Concat('insert into ld_profile2field(profileid,tabid,fieldid,visible,readonly) select ',profileid,',',ttabid,',',ffieldid,',',0,',',0 ,' from dual where not exists(select 1 from ld_profile2field where fieldid=',ffieldid,' and profileid=',profileid,')');

		prepare stmt from @sql;
	      execute stmt;
	      deallocate  prepare  stmt;
		Fetch cur2 into ffieldid,ttabid;
	end while loop1;
	close cur2;

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

	declare cur2 CURSOR FOR SELECT profileid   FROM  ld_profile;
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



SET @labelbol ='CFCREATEOPERATOR';
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'zh',@labelbol,'创建操作人','fixedstr' FROM DUAL 
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol=@labelbol and Labeltype='fixedstr');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'en',@labelbol,'Create operator','fixedstr' FROM DUAL 
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol=@labelbol and Labeltype='fixedstr');
delimiter;

SET @labelbol ='CFDELTETIME';
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'zh',@labelbol,'删除时间','fixedstr' FROM DUAL 
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol=@labelbol and Labeltype='fixedstr');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'en',@labelbol,'Delete time','fixedstr' FROM DUAL 
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol=@labelbol and Labeltype='fixedstr');
delimiter;

SET @labelbol = 'CFDELTEOPERATOR';
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'zh',@labelbol,'删除操作人','fixedstr' FROM DUAL 
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol=@labelbol and Labeltype='fixedstr');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'en',@labelbol,'Delete operator','fixedstr' FROM DUAL 
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol=@labelbol and Labeltype='fixedstr');
delimiter;

SET @labelbol = 'CFOPERATIONLOG';
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'zh',@labelbol,'自定义字段操作日志','fixedstr' FROM DUAL 
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol=@labelbol and Labeltype='fixedstr');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'en',@labelbol,'Custom field operation log','fixedstr' FROM DUAL 
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol=@labelbol and Labeltype='fixedstr');
delimiter;

CREATE TABLE IF NOT EXISTS`ld_cfoperationlog` (
    `id` int(19) NOT NULL AUTO_INCREMENT,
    `tabid` int(19)  DEFAULT NULL ,
    `fieldid` int(19) DEFAULT NULL ,
	`uitype` varchar(30) DEFAULT NULL ,
	`bigtype` varchar(50) DEFAULT NULL ,
    `fieldlabel_zh` Text DEFAULT NULL ,
    `fieldlabel_en` Text DEFAULT NULL ,
    `create_operator` int(19) DEFAULT NULL,
	`delete_operator` int(19) DEFAULT NULL,
    `createdtime` datetime DEFAULT  NULL,
    `deletedtime` datetime DEFAULT NULL,
    `modifiedtime` datetime DEFAULT  NULL,
    PRIMARY KEY (`id`) USING BTREE
) ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=utf8;
delimiter;

insert into ld_cfoperationlog(`tabid`,`fieldid`,`uitype`,`bigtype`,`fieldlabel_zh`,`createdtime`,`modifiedtime`) 
select `tabid`,`fieldid`,`uitype`,`bigtype`,`fieldlabel`,`createdtime`,`modifiedtime`
from ld_field
where `columnname` like '%cf_%' 
AND not  EXISTS (SELECT 1 FROM ld_cfoperationlog WHERE ld_cfoperationlog.tabid = ld_field.tabid
and ld_cfoperationlog.fieldid=ld_field.fieldid) ;
delimiter;

update ld_cfoperationlog inner join ld_tranlabel
on ld_tranlabel.Relateid = ld_cfoperationlog.fieldid and ld_tranlabel.tabid = ld_cfoperationlog.tabid
set ld_cfoperationlog.fieldlabel_en = ld_tranlabel.fieldlabel
where ld_tranlabel.languagetype ='en' and ld_tranlabel.trantable ='ld_field';
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','MODULECANCELSHAREREMIND','【%s】取消共享提醒','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='zh' and labelbol='MODULECANCELSHAREREMIND' and labeltype='fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','MODULECANCELSHAREREMIND',"【%s】Cancel Share Remind",'fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype='en' and labelbol='MODULECANCELSHAREREMIND' and labeltype='fixedstr');
delimiter;

update ld_desk set fieldlabel='强制驳回提醒' where languagetype='zh' and labelbol='FORCEDREJECTSUBMITAPPROVAL' and labeltype='fixedstr';
update ld_desk set fieldlabel='Forced rejection reminder' where languagetype='en' and labelbol='FORCEDREJECTSUBMITAPPROVAL' and labeltype='fixedstr';
delimiter;

update ld_field set allowedit = 'no' where bigtype='memberdepartment' and displaytype = 1 and allowedit = 'yes';
delimiter;

CALL AddColumn('ld_templateprint','approvedallowprint','varchar',20,'no');
delimiter;

SET @tabid = (SELECT tabid from ld_tab where `name` = 'Quotes');
UPDATE ld_templateprint SET approvedallowprint = (SELECT CASE WHEN deploy_value=1 THEN 'no' ELSE 'yes' END FROM ld_systems_deploy WHERE deploy_type = 153) WHERE tabid = @tabid
AND EXISTS (SELECT 1 FROM ld_systems_deploy WHERE deploy_type=153);
delimiter;
SET @tabid = (SELECT tabid from ld_tab where `name` = 'SalesOrder');
UPDATE ld_templateprint SET approvedallowprint = (SELECT CASE WHEN deploy_value=1 THEN 'no' ELSE 'yes' END FROM ld_systems_deploy WHERE deploy_type = 154) WHERE tabid = @tabid
AND EXISTS (SELECT 1 FROM ld_systems_deploy WHERE deploy_type=154);
delimiter;

SET @tabid = (SELECT tabid from ld_tab where `name` = 'ServiceContracts');
UPDATE ld_templateprint SET approvedallowprint = (SELECT CASE WHEN deploy_value=1 THEN 'no' ELSE 'yes' END FROM ld_systems_deploy WHERE deploy_type = 155) WHERE tabid = @tabid
AND EXISTS (SELECT 1 FROM ld_systems_deploy WHERE deploy_type=155);
delimiter;

SET @tabid = (SELECT tabid from ld_tab where `name` = 'PurchaseOrder');
UPDATE ld_templateprint SET approvedallowprint = (SELECT CASE WHEN deploy_value=1 THEN 'no' ELSE 'yes' END FROM ld_systems_deploy WHERE deploy_type = 156) WHERE tabid = @tabid
AND EXISTS (SELECT 1 FROM ld_systems_deploy WHERE deploy_type=156);
delimiter;

SET @tabid = (SELECT tabid from ld_tab where `name` = 'OutboundOrder');
UPDATE ld_templateprint SET approvedallowprint = (SELECT CASE WHEN deploy_value=1 THEN 'no' ELSE 'yes' END FROM ld_systems_deploy WHERE deploy_type = 157) WHERE tabid = @tabid
AND EXISTS (SELECT 1 FROM ld_systems_deploy WHERE deploy_type=157);
delimiter;

DELETE FROM ld_systems_deploy WHERE deploy_type IN(153,154,155,156,157);
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','ApprovedAllowPrint','是否审批通过后才允许打印','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='ApprovedAllowPrint' and labeltype='fixedstr' and languagetype='zh');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','ApprovedAllowPrint','Allow printing after approval','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='ApprovedAllowPrint' and labeltype='fixedstr' and languagetype='en');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'zh','ApprovedAllowPrintRemind','您当前所选打印模板设置的是单据审批通过后才允许打印，请先审批单据！','jspop' from dual
where not EXISTS(select 1 from ld_desk  where languagetype='zh' and labelbol='ApprovedAllowPrintRemind' and Labeltype='jspop');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype) select 'en','ApprovedAllowPrintRemind','The currently selected print template is set to print after the document is approved. Please approve the document first!','jspop' from dual
where not EXISTS(select 1 from ld_desk  where languagetype='en' and labelbol='ApprovedAllowPrintRemind' and Labeltype='jspop');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','ApprovedAllowPrintRemindApp','您当前所选打印模板设置的是单据审批通过后才允许打印，请先审批单据！','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='ApprovedAllowPrintRemindApp' and labeltype='fixedstr' and languagetype='zh');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','ApprovedAllowPrintRemindApp','The currently selected print template is set to print after the document is approved. Please approve the document first!','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='ApprovedAllowPrintRemindApp' and labeltype='fixedstr' and languagetype='en');
delimiter;


CALL AddColumn('ld_customtable','report_type','varchar','50','selectfield');
CALL AddColumn('ld_customtable','sqlstr','text','','');
CALL AddColumn('ld_customtable_columns','visibile','varchar','10','yes');
CALL AddColumn('ld_customtable_columns','fieldtype','varchar','10','');
CALL AddColumn('ld_customtable_columns','linkurl','text','','');
delimiter;

CREATE TABLE IF NOT EXISTS `ld_customtablesql_filter` (
    `id` int(19) NOT NULL AUTO_INCREMENT,
    `report_id` int(19) NOT NULL ,
    `var_name` varchar(100) DEFAULT NULL COMMENT '变量名称',
    `display_name` varchar(100) DEFAULT NULL COMMENT '别名',
    `var_type` varchar(100) DEFAULT NULL COMMENT 'date日期  datetime日期时间  number数字区间  select单选  multiselect多选   string模糊查找  checkbox复选框 单选用户selectuser,多选用户multiuser',
    `default_value` varchar(255) COMMENT '默认值 比如日期2022-01-01' ,
    `select_source` varchar(100) DEFAULT NULL COMMENT '选项自定义selfdefine 下拉框字段 picklist',
    `modulename` varchar(100)	 DEFAULT NULL COMMENT '下拉框值来源模块',
    `fieldname` varchar(100) DEFAULT NULL COMMENT '下拉框值来源字段',
    `selectvalues` text DEFAULT '' COMMENT '下拉框值列表 以逗号隔开',
    PRIMARY KEY  (`id`)
    ) ENGINE=InnoDB AUTO_INCREMENT=0 DEFAULT CHARSET=utf8;
delimiter;

CALL AddColumn('ld_customtablesql_filter','sequence','int','4','');
delimiter;

UPDATE ld_field SET bigtype = 'number' where bigtype = 'num';
delimiter;
-- 2022-08-12

UPDATE ld_picklist_dependency 
SET targetvalues='["市辖区","上城区","拱墅区","西湖区","滨江区","萧山区","余杭区","富阳区","临安区","临平区","钱塘区","建德市","桐庐县","淳安县"]'
WHERE sourcefield='bill_city'
	AND targetfield='bill_area'
	AND sourcevalue='杭州市'
	AND targetvalues='["市辖区","上城区","下城区","江干区","拱墅区","西湖区","滨江区","萧山区","余杭区","富阳区","桐庐县","淳安县","建德市","临安市"]';

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','Penetration','是否穿透','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='Penetration' and labeltype='fixedstr' and languagetype='zh');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','Penetration','Penetration','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='Penetration' and labeltype='fixedstr' and languagetype='en');
delimiter;


insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','PenetrationType','穿透类型','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='PenetrationType' and labeltype='fixedstr' and languagetype='zh');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','PenetrationType','Penetration type','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='PenetrationType' and labeltype='fixedstr' and languagetype='en');
delimiter;


insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','Primarykey','主键','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='Primarykey' and labeltype='fixedstr' and languagetype='zh');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','Primarykey','Primary key','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='Primarykey' and labeltype='fixedstr' and languagetype='en');
delimiter;


insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','VAR','变量','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='VAR' and labeltype='fixedstr' and languagetype='zh');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','VAR','variable','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='VAR' and labeltype='fixedstr' and languagetype='en');
delimiter;



insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','Inputbox','输入框','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='Inputbox' and labeltype='fixedstr' and languagetype='zh');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','Inputbox','Input box','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='Inputbox' and labeltype='fixedstr' and languagetype='en');
delimiter;



insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','Usercomponent','用户组件','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='Usercomponent' and labeltype='fixedstr' and languagetype='zh');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','Usercomponent','User component','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='Usercomponent' and labeltype='fixedstr' and languagetype='en');
delimiter;


insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','Dropdownboxsource','下拉框值来源模块','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='Dropdownboxsource' and labeltype='fixedstr' and languagetype='zh');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','Dropdownboxsource','Drop down box value source module','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='Dropdownboxsource' and labeltype='fixedstr' and languagetype='en');
delimiter;
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','Customoptions','自定义选项','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='Customoptions' and labeltype='fixedstr' and languagetype='zh');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','Customoptions','Custom options','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='Customoptions' and labeltype='fixedstr' and languagetype='en');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','Dropdownboxsource1','下拉框值来源字段','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='Dropdownboxsource1' and labeltype='fixedstr' and languagetype='zh');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','Dropdownboxsource1','Drop down box value source field','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='Dropdownboxsource1' and labeltype='fixedstr' and languagetype='en');
delimiter;


insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','source','来源','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='source' and labeltype='fixedstr' and languagetype='zh');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','source','source','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='source' and labeltype='fixedstr' and languagetype='en');
delimiter;

select report_id into @report_id from ld_customtable where report_name='销售排行榜（按出库金额）';
delete from ld_customtable_module where  report_id=@report_id and modulename='Invoice';
delimiter;
-- 2022-08-12

select report_id into @report_id from ld_customtable where report_name='销售排行榜（按出库金额）';
delete from ld_customtable_module where  report_id=@report_id and modulename='Invoice';
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','YOUDONOTHAVETHECONTRACTPORDER','您没有编辑权限','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype = 'zh' and labelbol = 'YOUDONOTHAVETHECONTRACTPORDER' and labeltype = 'fixedstr');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','YOUDONOTHAVETHECONTRACTPORDER','You do not have the permissions to edit the current payment plan','fixedstr' from dual
where not exists(select 1 from ld_desk where languagetype = 'en' and labelbol = 'YOUDONOTHAVETHECONTRACTPORDER' and labeltype = 'fixedstr');
delimiter;

CALL AddColumn('ld_vendor','longtitude','varchar','50','');
CALL AddColumn('ld_vendor','latitude','varchar','50','');
CALL AddColumn('ld_vendor','location_address','varchar','200','');
delimiter;

CALL AddColumn('ld_contactdetails','longtitude','varchar','50','');
CALL AddColumn('ld_contactdetails','latitude','varchar','50','');
CALL AddColumn('ld_contactdetails','location_address','varchar','200','');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','Table','统计表','jspop' from dual
where not exists(select 1 from ld_desk where labelbol='Table' and labeltype='jspop' and languagetype='zh');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','Table','Table','jspop' from dual
where not exists(select 1 from ld_desk where labelbol='Table' and labeltype='jspop' and languagetype='en');
delimiter;

UPDATE ld_desk SET fieldlabel='设置单据详情界面顶部相关信息栏显示的模块' WHERE labelbol= 'SetDetailRelatedModules' AND Labeltype='fixedstr' AND languagetype='zh';
UPDATE ld_desk SET fieldlabel='Set the module displayed in the relevant information column at the top of the document details interface' WHERE labelbol= 'SetDetailRelatedModules' AND Labeltype='fixedstr' AND languagetype='en';
UPDATE ld_desk SET fieldlabel='可选模块' WHERE labelbol= 'AllRelatedModules' AND Labeltype='fixedstr' AND languagetype='zh';
UPDATE ld_desk SET fieldlabel='已选模块' WHERE labelbol= 'SelectedRelateModules' AND Labeltype='fixedstr' AND languagetype='zh';
delimiter;

update ld_field set allowedit='no' where columnname = 'expensebudget_type' and tabid = 249 and allowedit='yes';
delimiter;

select tabid into @tabid from ld_tab where name='ServiceContracts';
select report_id into @report_id from ld_customtable where report_name='销售排行榜（按服务合同金额）';
delete from ld_customtable_module where  report_id=@report_id and modulename='ServiceContracts';
delimiter;

insert into ld_customtable_module(report_id,tabid,modulename,parent_id) select @report_id,@tabid,'ServiceContracts','0' from dual
where not exists(select 1 from ld_customtable_module where report_id =@report_id and modulename = 'ServiceContracts');
delimiter;

call AddColumn('ld_workreport_showset','belongtype','varchar','50','');
delimiter;

update ld_workreport_showset set belongtype ='blog' 
where type= 'weibo' or type ='dayreport' or type ='weekreport' or type ='monthreport' or type ='cocmd';
delimiter;

insert into ld_workreport_showset(`type`,`sequence`,`presence`,`belongtype`)
select 'Leads',1,'yes','component' from dual
WHERE NOT EXISTS (SELECT 1 FROM ld_workreport_showset WHERE belongtype = 'component' and type ='Leads' );
delimiter;

insert into ld_workreport_showset(`type`,`sequence`,`presence`,`belongtype`)
select 'Accounts',2,'yes','component' from dual
WHERE NOT EXISTS (SELECT 1 FROM ld_workreport_showset WHERE belongtype = 'component' and type ='Accounts');
delimiter;

insert into ld_workreport_showset(`type`,`sequence`,`presence`,`belongtype`)
select 'Contacts',3,'yes','component' from dual
WHERE NOT EXISTS (SELECT 1 FROM ld_workreport_showset WHERE belongtype = 'component' and type = 'Contacts');
delimiter;

insert into ld_workreport_showset(`type`,`sequence`,`presence`,`belongtype` )
select 'Potentials',4,'yes','component' from dual
WHERE NOT EXISTS (SELECT 1 FROM ld_workreport_showset WHERE belongtype = 'component'  and type ='Potentials');
delimiter;

insert into ld_workreport_showset(`type`,`sequence`,`presence`,`belongtype` )
select 'ContactRecords',5,'yes','component' from dual
WHERE NOT EXISTS (SELECT 1 FROM ld_workreport_showset WHERE belongtype = 'component' and type ='ContactRecords');
delimiter;

insert into ld_workreport_showset(`type`,`sequence`,`presence`,`belongtype`)
select 'SalesOrder',6,'yes','component' from dual
WHERE NOT EXISTS (SELECT 1 FROM ld_workreport_showset WHERE belongtype = 'component' and type ='SalesOrder');
delimiter;
insert into ld_workreport_showset(`type`,`sequence`,`presence`,`belongtype`)
select 'ServiceContracts',7,'yes','component' from dual
WHERE NOT EXISTS (SELECT 1 FROM ld_workreport_showset WHERE belongtype = 'component' and type ='ServiceContracts');
delimiter;

insert into ld_workreport_showset(`type`,`sequence`,`presence`,`belongtype`)
select 'HelpDesk',8,'yes','component' from dual
WHERE NOT EXISTS (SELECT 1 FROM ld_workreport_showset WHERE belongtype = 'component' and type ='HelpDesk');
delimiter;

insert into ld_workreport_showset(`type`,`sequence`,`presence`,`belongtype`)
select 'Project',9,'yes','component' from dual
WHERE NOT EXISTS (SELECT 1 FROM ld_workreport_showset WHERE belongtype = 'component' and type ='Project');
delimiter;

insert into ld_workreport_showset(`type`,`sequence`,`presence`,`belongtype`)
select 'ProjectTask',10,'yes','component' from dual
WHERE NOT EXISTS (SELECT 1 FROM ld_workreport_showset WHERE belongtype = 'component' and type ='ProjectTask');
delimiter;

insert into ld_workreport_showset(`type`,`sequence`,`presence`,`belongtype`)
select 'ProjectProgress',11,'yes','component' from dual
WHERE NOT EXISTS (SELECT 1 FROM ld_workreport_showset WHERE belongtype = 'component' and type = 'ProjectProgress');
delimiter;

insert into ld_workreport_showset(`type`,`sequence`,`presence`,`belongtype`)
select 'Calendar',12,'yes','component' from dual
WHERE NOT EXISTS (SELECT 1 FROM ld_workreport_showset WHERE belongtype = 'component' and type ='Calendar');
delimiter;

insert into ld_workreport_showset(`type`,`sequence`,`presence`,`belongtype`)
select 'CashBill',13,'yes','component' from dual
WHERE NOT EXISTS (SELECT 1 FROM ld_workreport_showset WHERE belongtype = 'component' and type ='CashBill');
delimiter;

insert into ld_workreport_showset(`type`,`sequence`,`presence`,`belongtype`)
select 'Singin',14,'yes','component' from dual
WHERE NOT EXISTS (SELECT 1 FROM ld_workreport_showset WHERE belongtype = 'component' and type ='Singin');
delimiter;

SET @labelbol = 'LEASTONECOLUMN';
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'zh',@labelbol,'请至少保留一个栏目','jspop' FROM DUAL 
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol=@labelbol and Labeltype='jspop');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'en',@labelbol,'Please keep at least one column','jspop' FROM DUAL 
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol=@labelbol and Labeltype='jspop');
delimiter;

update ld_organizationdetails_product set image_link="https://weixin-1255564871.cos.ap-shanghai.myqcloud.com/web_51mis/mob92/images/p_jichu.png" where image_link='http://71mis.cn/web_51mis/mob92/images/p_jichu.png';
update ld_organizationdetails_product set image_link="https://weixin-1255564871.cos.ap-shanghai.myqcloud.com/web_51mis/mob92/images/p_biaozhun.png" where image_link='http://71mis.cn/web_51mis/mob92/images/p_biaozhun.png';
update ld_organizationdetails_product set image_link="https://weixin-1255564871.cos.ap-shanghai.myqcloud.com/web_51mis/mob92/images/p_qiye.png" where image_link='http://71mis.cn/web_51mis/mob92/images/p_qiye.png';
update ld_organizationdetails_product set image_link="https://weixin-1255564871.cos.ap-shanghai.myqcloud.com/web_51mis/mob92/images/p_jinxiaocun.png" where image_link='http://71mis.cn/web_51mis/mob92/images/p_jinxiaocun.png';
delimiter;

DROP PROCEDURE IF EXISTS `ldcrm_add_teamownerid`;
delimiter ||
CREATE PROCEDURE `ldcrm_add_teamownerid`(
)
BEGIN

	DECLARE tmp_moudule VARCHAR(100) DEFAULT '';
	DECLARE tmp_id INT(19) DEFAULT 0;
	DECLARE tmp_block INT(19) DEFAULT 0;
	DECLARE tmp_seq INT(19) DEFAULT 0;
	DECLARE tmp_table VARCHAR(100) DEFAULT '';
	DECLARE tmp_tablekey VARCHAR(100) DEFAULT '';

	DECLARE MYCUSOR CURSOR FOR
					SELECT
						a.tabid,
						b.`name` AS moudule,
						a.block,
						a.sequence,
						a.tablename,
						(SELECT entityidfield FROM ld_entityname WHERE tabid=a.tabid LIMIT 1) AS tablekey
					FROM ld_field a
					INNER JOIN ld_tab b ON b.tabid=a.tabid
					WHERE a.columnname='smownerid'
						AND a.tabid<>16
						AND IFNULL((SELECT entityidfield FROM ld_entityname WHERE tabid=a.tabid LIMIT 1),'')<>''
					ORDER BY a.tabid;
	DECLARE CONTINUE HANDLER FOR SQLSTATE '02000' SET tmp_id = NULL;

	OPEN MYCUSOR;
	FETCH MYCUSOR INTO tmp_id,tmp_moudule,tmp_block,tmp_seq,tmp_table,tmp_tablekey;
	WHILE(tmp_id IS NOT NULL) DO
		IF NOT EXISTS (SELECT 1 FROM ld_field WHERE tabid=tmp_id AND columnname='team_memberid') THEN
			SET @modulename=tmp_moudule;
			SET @tabid=IF(tmp_id=9,16,tmp_id);
			SET @relateid=tmp_block;
			SET @maxseq=tmp_seq;
			SET @trantable='ld_field';
			SET @tablename=tmp_table;
			SET @columnname='team_memberid';
			SET @fieldname='team_memberid';
			SET @zh='团队成员';
			SET @en='Team Members';
			SET @uitype=154;
			SET @typeofdata='V~O';
			SET @quickcreate=1;
			SET @displaytype=1;
			SET @bigtype='text';
			SET @datarang=NULL;
			SET @maxrowsshow=0;

			UPDATE ld_field SET sequence=sequence+1 WHERE tabid=@tabid AND block=@relateid AND sequence>@maxseq;

			SET @maxid=(SELECT MAX(fieldid) FROM ld_field);
			INSERT INTO ld_field(tabid,fieldid,columnname,tablename,allowhide,generatedtype,uitype,fieldname,fieldlabel,readonly,presence,defaultvalue,maximumlength,sequence,block,displaytype,typeofdata,quickcreate,quickcreatesequence,info_type,masseditable,helpinfo,fieldonly,approve_demand,is_checkimportfield,bigtype,datarang,maxrowsshow)
			SELECT @tabid,@maxid+1,@columnname,@tablename,'yes',1,@uitype,@fieldname,@zh,1,1,NULL,100,@maxseq+1,@relateid,@displaytype,@typeofdata,@quickcreate,NULL,NULL,1,NULL,0,2,0,@bigtype,@datarang,@maxrowsshow FROM DUAL
			WHERE NOT EXISTS (SELECT 1 FROM ld_field WHERE tabid=@tabid AND tablename=@tablename AND columnname=@columnname);

			UPDATE ld_field_seq SET id=(SELECT max(fieldid) FROM ld_field);

			SET @relateid=(SELECT fieldid FROM ld_field WHERE tabid=@tabid AND columnname=@columnname LIMIT 1);

			INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
			SELECT 'zh',@trantable,@tabid,@relateid,@zh FROM DUAL
			WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE languagetype = 'zh' AND trantable =@trantable AND tabid = @tabid AND relateid=@relateid);

			INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
			SELECT 'en',@trantable,@tabid,@relateid,@en FROM DUAL
			WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE languagetype = 'en' AND trantable =@trantable AND tabid = @tabid AND relateid=@relateid);

			CALl AddColumn(@tablename,@columnname,'TEXT',NULL,NULL);

			CALL getallprofile(@modulename);
			CALL fieldprofile(@modulename);

			-- 更新团队成员数据
			SET @this_sql="UPDATE  (
					SELECT
						crmid,
						GROUP_CONCAT(viewuserid) AS teamownerid
					FROM ld_tabshare
					WHERE crmid IN (SELECT crmid FROM ld_crmentity WHERE setype='THIS_MODULE')
					GROUP BY crmid
				) a
				INNER JOIN THIS_TABLE b ON b.THIS_TABKEY=a.crmid
				SET b.team_memberid=a.teamownerid";

			SET @this_sql=REPLACE(@this_sql,'THIS_MODULE',@modulename);
			SET @this_sql=REPLACE(@this_sql,'THIS_TABLE',@tablename);
			SET @this_sql=REPLACE(@this_sql,'THIS_TABKEY',tmp_tablekey);

			SET @disable_triggers=1;
			PREPARE exec_smt FROM @this_sql;
			EXECUTE exec_smt;
			DROP PREPARE exec_smt;
			SET @disable_triggers=NULL;
		END IF;

		FETCH MYCUSOR INTO tmp_id,tmp_moudule,tmp_block,tmp_seq,tmp_table,tmp_tablekey;
	END WHILE;
	CLOSE MYCUSOR;

END ||
delimiter;

CALL ldcrm_add_teamownerid();
DROP PROCEDURE IF EXISTS `ldcrm_add_teamownerid`;
delimiter;

SET @labelbol = 'AREYOUSURE_CHANGEMODULE';
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'zh',@labelbol,'您确定要更改统计来源吗','jspop' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol=@labelbol and Labeltype='jspop');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'en',@labelbol,'Are you sure you want to change the statistics source','jspop' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol=@labelbol and Labeltype='jspop');
delimiter;

SET @labelbol = 'CHANGEMODULE_WILLDO';
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'zh',@labelbol,'更改统计来源会清空已有的字段配置和高级设置等相关信息，且无法还原','jspop' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol=@labelbol and Labeltype='jspop');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'en',@labelbol,'Changing the statistics source will clear the existing field configuration, advanced settings and other related information, and cannot be restored','jspop' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol=@labelbol and Labeltype='jspop');
delimiter;
-- 2022-08-19

UPDATE ld_picklist_dependency 
SET targetvalues='["市辖区","武侯区","锦江区","青羊区","金牛区","成华区","龙泉驿区","青白江区","新都区","温江区","双流区","郫都区","新津区","都江堰市","彭州市","邛崃市","崇州市","简阳市","金堂县","大邑县","蒲江县"]'
WHERE sourcefield='bill_city'
	AND targetfield='bill_area'
	AND sourcevalue='成都市'
	AND targetvalues='["市辖区","锦江区","青羊区","金牛区","武侯区","成华区","龙泉驿区","青白江区","新都区","温江区","双流区","金堂县","郫县","大邑县","蒲江县","新津县","都江堰市","彭州市","邛崃市","崇州市","简阳市"]';


update ld_relatedlists set actions = 'add' where `name` = 'get_budgetchange' and actions = 'approvedadd';
delimiter;

CALL AddColumn('ld_reminds','push_to_offiaccount','int','2',2);
CALL AddColumn('ld_reminds','push_time_offiaccount','datetime',null ,null );
CALL AddColumn('ld_reminds_accepted','push_to_offiaccount','int','2',2);
CALL AddColumn('ld_reminds_accepted','push_time_offiaccount','datetime',null ,null );
delimiter;

DROP PROCEDURE IF EXISTS `crm_publicaccount_recoveryreminds`;
delimiter ||
CREATE  PROCEDURE `crm_publicaccount_recoveryreminds`()
BEGIN
	declare var_type varchar(100);
	DECLARE var_accountnames text;
	DECLARE var_totalaccounts int(19);
	declare var_smownerid int(19);
	declare done  int  default 0;

   declare cur1 CURSOR FOR select * from ld_publicaccount_remindtableview;
declare continue handler  for not   found  SET done =1;
OPEN cur1;

Fetch cur1 into var_type, var_accountnames,var_totalaccounts,var_smownerid;
loop1: while  done<>1 DO
		if var_totalaccounts>0 then
			if var_type='normal' or var_type='singlenormal' THEN
			 set @tmpcontent=concat("您有",var_totalaccounts,"条普通客户未达成目标，回收到公海池。客户名称如下：<br>",var_accountnames);
call ldcrm_add_reminder_havetype(@tmpcontent,var_smownerid,'Accounts',0,'AccountsRECYCLEREMIND');
elseif var_type='complete' THEN
				 set @tmpcontent=concat("您有",var_totalaccounts,"条公海客户未达成目标，回收到公海池。客户名称如下：<br>",var_accountnames);
call ldcrm_add_reminder_havetype(@tmpcontent,var_smownerid,'Accounts',0,'AccountsRECYCLEREMIND');
else
				 set @tmpcontent=concat("您有",var_totalaccounts,"条公海客户未达成公海目标，回收到公海池。客户名称如下：<br>",var_accountnames);
call ldcrm_add_reminder_havetype(@tmpcontent,var_smownerid,'Accounts',0,'AccountsRECYCLEREMIND');
end if;
end if;
Fetch cur1 into var_type, var_accountnames,var_totalaccounts,var_smownerid;
end while loop1;
close cur1;

end ||
delimiter;

drop PROCEDURE if exists crm_publicaccount_beforereminds;
delimiter ||
create PROCEDURE crm_publicaccount_beforereminds()
BEGIN
	declare var_type varchar(100);
	DECLARE var_accountnames text;
	DECLARE var_totalaccounts int(19);
	declare var_smownerid int(19);
	declare done  int  default 0;

   declare cur1 CURSOR FOR select * from ld_publicaccount_remindtableview;
declare continue handler  for not   found  SET done =1;
OPEN cur1;

Fetch cur1 into var_type, var_accountnames,var_totalaccounts,var_smownerid;
loop1: while  done<>1 DO
		if var_totalaccounts>0 then
			if var_type='normal' or var_type='singlenormal' THEN
			 set @tmpcontent=concat("您有",var_totalaccounts,"条普通客户未达成目标，即将要回收到公海池。客户名称如下：<br>",var_accountnames);
call ldcrm_add_reminder(@tmpcontent,var_smownerid,'Accounts',0);
elseif var_type='complete' THEN
				 set @tmpcontent=concat("您有",var_totalaccounts,"条公海客户达成条件后未达成目标，即将要回收到公海。客户名称如下：<br>",var_accountnames);
call ldcrm_add_reminder(@tmpcontent,var_smownerid,'Accounts',0);

end if;
end if;
Fetch cur1 into var_type, var_accountnames,var_totalaccounts,var_smownerid;
end while loop1;
close cur1;

end||
delimiter;

DROP PROCEDURE IF EXISTS `crm_publicleads_beforereminds`;
delimiter ||
CREATE  PROCEDURE `crm_publicleads_beforereminds`()
BEGIN
	declare var_type varchar(100);
	DECLARE var_accountnames text;
	DECLARE var_totalaccounts int(19);
	declare var_smownerid int(19);
	declare done  int  default 0;

   declare cur1 CURSOR FOR select * from ld_publicleads_remindtableview;
declare continue handler  for not   found  SET done =1;
OPEN cur1;

Fetch cur1 into var_type, var_accountnames,var_totalaccounts,var_smownerid;
loop1: while  done<>1 DO
		if var_totalaccounts>0 then
			if var_type='normal' or var_type='singlenormal' THEN
			 set @tmpcontent=concat("您有",var_totalaccounts,"条普通线索未达成目标，即将要回收到公海。客户名称如下：<br>",var_accountnames);
call ldcrm_add_reminder_havetype(@tmpcontent,var_smownerid,'Leads',0,'LeadsRECYCLEREMIND');
elseif var_type='complete' THEN
				 set @tmpcontent=concat("您有",var_totalaccounts,"条公海线索达成条件后未达成目标，即将要回收到公海。客户名称如下：<br>",var_accountnames);
call ldcrm_add_reminder_havetype(@tmpcontent,var_smownerid,'Leads',0,'LeadsRECYCLEREMIND');

end if;
end if;
Fetch cur1 into var_type, var_accountnames,var_totalaccounts,var_smownerid;
end while loop1;
close cur1;

end ||
delimiter;

DROP PROCEDURE IF EXISTS `crm_publicleads_recoveryreminds`;
delimiter ||
CREATE  PROCEDURE `crm_publicleads_recoveryreminds`()
BEGIN
	declare var_type varchar(100);
	DECLARE var_accountnames text;
	DECLARE var_totalaccounts int(19);
	declare var_smownerid int(19);
	declare done  int  default 0;

   declare cur1 CURSOR FOR select * from ld_publicleads_remindtableview;
declare continue handler  for not   found  SET done =1;
OPEN cur1;

Fetch cur1 into var_type, var_accountnames,var_totalaccounts,var_smownerid;
loop1: while  done<>1 DO
		if var_totalaccounts>0 then
			if var_type='normal' or var_type='singlenormal' THEN
			 set @tmpcontent=concat("您有",var_totalaccounts,"条普通线索未达成目标，回收到公海池。客户名称如下：<br>",var_accountnames);
call ldcrm_add_reminder_havetype(@tmpcontent,var_smownerid,'Leads',0,'LeadsRECYCLEREMIND');
elseif var_type='complete' THEN
				 set @tmpcontent=concat("您有",var_totalaccounts,"条公海线索未达成目标，回收到公海池。客户名称如下：<br>",var_accountnames);
call ldcrm_add_reminder_havetype(@tmpcontent,var_smownerid,'Leads',0,'LeadsRECYCLEREMIND');
else
				 set @tmpcontent=concat("您有",var_totalaccounts,"条公海线索未达成公海目标，回收到公海池。客户名称如下：<br>",var_accountnames);
call ldcrm_add_reminder_havetype(@tmpcontent,var_smownerid,'Leads',0,'LeadsRECYCLEREMIND');
end if;
end if;
Fetch cur1 into var_type, var_accountnames,var_totalaccounts,var_smownerid;
end while loop1;
close cur1;

end ||
delimiter;



ALTER TABLE ld_customtable MODIFY COLUMN sqlstr LONGTEXT;
delimiter;

UPDATE ld_desk SET fieldlabel = '推进操作显示样式' where labelbol = 'PUSHOPERAATIONSTYLE' and languagetype = 'zh';
UPDATE ld_desk SET fieldlabel = '推进日志显示样式' where labelbol = 'PUSHLOGSTYLE' and languagetype = 'zh';
delimiter;


CREATE TABLE IF NOT EXISTS `ld_customreport_sorting` (
    `report_id` int(19) NOT NULL COMMENT'报表ID',
    `sorttype` Varchar(20) COMMENT'排序方式',
    `columnmodule` Varchar(50) COMMENT'排序字段来自模块',
    `columns` Varchar(255) COMMENT'排序字段',
    `sortmethod` Varchar(20) COMMENT'排序方式 desc asc ',
    `total_type` Varchar(20) COMMENT'统计方式 sum count avg等 ',
    `sequence` int(10) COMMENT'排序 '
    )ENGINE=InnoDB DEFAULT CHARSET=utf8;
delimiter;


SET @labelbol = 'Groupfieldsby';
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'zh',@labelbol,'按分组字段','jspop' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol=@labelbol and Labeltype='jspop');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'en',@labelbol,'Group fields by','jspop' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol=@labelbol and Labeltype='jspop');
delimiter;

SET @labelbol = 'Bystatisticalresult';
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'zh',@labelbol,'按统计结果','jspop' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol=@labelbol and Labeltype='jspop');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'en',@labelbol,'By statistical result','jspop' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol=@labelbol and Labeltype='jspop');
delimiter;

SET @labelbol = 'NEW';
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'zh',@labelbol,'新增','jspop' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'zh' AND labelbol=@labelbol and Labeltype='jspop');
INSERT INTO ld_desk(languagetype,labelbol,fieldlabel,labeltype)
SELECT 'en',@labelbol,'New','jspop' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ld_desk WHERE languagetype = 'en' AND labelbol=@labelbol and Labeltype='jspop');
delimiter;


update ld_field set typeofdata = 'N~O~2,2',bigtype='percent' where tabid = 22 and columnname = 'fixed_rate' and typeofdata = 'N~O~2~2';
update ld_field set typeofdata = 'N~M~2,2',bigtype='percent' where tabid = 22 and columnname = 'fixed_rate' and typeofdata = 'N~M~2~2';
delimiter;



insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','Docmodulefields','单据模块字段','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='Docmodulefields' and labeltype='fixedstr' and languagetype='zh');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','Docmodulefields','Doc module fields','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='Docmodulefields' and labeltype='fixedstr' and languagetype='en');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','Parametename','参数名','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='Parametename' and labeltype='fixedstr' and languagetype='zh');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','Parametename','Parameter name','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='Parametename' and labeltype='fixedstr' and languagetype='en');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','Parametevalue','参数值','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='Parametevalue' and labeltype='fixedstr' and languagetype='zh');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','Parametevalue','Paramete value','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='Parametevalue' and labeltype='fixedstr' and languagetype='en');
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','Paramete','参数','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='Paramete' and labeltype='fixedstr' and languagetype='zh');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','Paramete','Paramete','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='Paramete' and labeltype='fixedstr' and languagetype='en');
delimiter;

call AddColumn('ld_workflow_actions','body_query_type','varchar','50',NULL);
update ld_workflow_actions set body_query_type = 'json' where body_query_type is NULL;
delimiter;

CREATE TABLE IF NOT EXISTS `ld_workflow_api_parameter` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `workflow_id` int(11) DEFAULT NULL,
  `parameter_name` varchar(100) DEFAULT NULL,
  `parameter_type` varchar(100) DEFAULT NULL,
  `parameter_value` text,
  `sequence` int(11) DEFAULT NULL,
  `workflow_api_type` varchar(50) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=utf8;
delimiter;

insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'zh','Currentmodule','当前模块','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='Currentmodule' and labeltype='fixedstr' and languagetype='zh');
insert into ld_desk(languagetype,labelbol,fieldlabel,labeltype)
select 'en','Currentmodule','Current Module','fixedstr' from dual
where not exists(select 1 from ld_desk where labelbol='Currentmodule' and labeltype='fixedstr' and languagetype='en');
delimiter;

update ld_cashbill set entitytype='' where cashtype='debuction';
delimiter;

call AddColumn('ld_producttoolfield','sourcemodule','varchar','50','');
call AddColumn('ld_tabdetailfield','sourcemodule','varchar','50','');
delimiter;
call AddColumn('ld_cashbill2paymentplan','lineitem_id','int','11','');
call AddColumn('ld_cashbill2paymentplanscf','lineitem_id','int','11','');
call AddColumn('ld_cashbill2paymentplan','parent_lineitem_id','int','11','');
delimiter;
call AddColumn('ld_cashbill','discount_type','int','1','');
call AddColumn('ld_cashbill','discount_percent','decimal','25','');
call AddColumn('ld_cashbill','discount_amount','decimal','25','');
call AddColumn('ld_cashbill','adjustment','decimal','25','');
delimiter;

call AddColumn('ld_cashbill2paymentplan','sequence_no','int','4','');
call AddColumn('ld_cashbill2paymentplanscf','sequence','int','4','');
call AddColumn('ld_cashbill2paymentplan','havepurchasecount','decimal','25','');
call AddColumn('ld_cashbill2paymentplan','balancepurchasecount','decimal','25','');
call AddColumn('ld_cashbill2paymentplan','haveoutproductcount','decimal','25','');
call AddColumn('ld_cashbill2paymentplan','balanceoutproductcount','decimal','25','');
call AddColumn('ld_cashbill2paymentplan','contractid','int','11','');
call AddColumn('ld_cashbill2paymentplan','productbomid','int','11','');
call AddColumn('ld_cashbill2paymentplan','productbomquantity','int','11','');
delimiter;

call AddColumn('ld_sendcashbill','discount_type','int','1','');
call AddColumn('ld_sendcashbill','discount_percent','decimal','25','');
call AddColumn('ld_sendcashbill','discount_amount','decimal','25','');
call AddColumn('ld_sendcashbill','adjustment','decimal','25','');
delimiter;

call AddColumn('ld_sendcashbill2payment','lineitem_id','int','11','');
call AddColumn('ld_sendcashbill2paymentscf','lineitem_id','int','11','');
call AddColumn('ld_sendcashbill2payment','parent_lineitem_id','int','11','');
delimiter;

call AddColumn('ld_sendcashbill2payment','sequence_no','int','4','');
call AddColumn('ld_sendcashbill2payment','sequence','int','4','');
call AddColumn('ld_sendcashbill2payment','havepurchasecount','decimal','25','');
call AddColumn('ld_sendcashbill2payment','balancepurchasecount','decimal','25','');
call AddColumn('ld_sendcashbill2payment','haveoutproductcount','decimal','25','');
call AddColumn('ld_sendcashbill2payment','balanceoutproductcount','decimal','25','');
call AddColumn('ld_sendcashbill2payment','contractid','int','11','');
call AddColumn('ld_sendcashbill2payment','productbomid','int','11','');
call AddColumn('ld_sendcashbill2payment','productbomquantity','int','11','');
delimiter;

set @tabid = (select tabid from ld_tab where `name`='CashBill');
DELETE from ld_tabdetailfield where tabid=@tabid and (sourcemodule = '' or sourcemodule is null) and columnname <> 'total';
set @tabid = (select tabid from ld_tab where `name`='SendCashBill');
DELETE from ld_tabdetailfield where tabid=@tabid and (sourcemodule = '' or sourcemodule is null) and columnname <> 'total';
delimiter;

SET @tabdetailfieldid=(SELECT MAX(tabdetailfieldid)+1 FROM ld_tabdetailfield);
set @tabid = (select tabid from ld_tab where `name` = 'CashBill');
SET @columnname = 'entitytype';
SET @trantable='ld_tabdetailfield';
SET @allowhide = 'no';
SET @fieldlabel = '源单类型';
SET @zh='源单类型';
SET @en='Link To';
SET @uitype = 'entitytype';
SET @typeofdata='V~O';
SET @bigtype='';
SET @parentbigtype='';
SET @sequence = (SELECT IFNULL(MAX(sequence),1) FROM ld_tabdetailfield where tabid=@tabid);
SET @tablename = 'ld_cashbill2paymentplan';
SET @sourcemodule = 'SalesOrder';
INSERT INTO ld_tabdetailfield(tabdetailfieldid,columnname,allowhide,fieldlabel,defaultvalue,presence,fieldtype,typeofdata,sequence,tabid,tablename,width,edit_permission,input_type,
fieldid,newline,defaultcolumn,is_checkimportfield,nullfield,referencemodule,datarange,approve_demand,maxrowsshow,bigtype,savedatabase,parentbigtype,sourcemodule)
SELECT @tabdetailfieldid,@columnname,@allowhide,@fieldlabel,NULL,0,@uitype,@typeofdata,@sequence+1,@tabid,@tablename,22,1,0,0,0,1,0,1,'','','',0,@bigtype,'yes',@parentbigtype,@sourcemodule from dual
WHERE NOT EXISTS (SELECT 1 FROM ld_tabdetailfield WHERE tabid=@tabid AND columnname=@columnname and tablename=@tablename and sourcemodule=@sourcemodule);

SET @relatedid = (SELECT tabdetailfieldid FROM ld_tabdetailfield WHERE tabid=@tabid AND columnname=@columnname  and sourcemodule=@sourcemodule LIMIT 1);
INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
SELECT 'zh',@trantable,@tabid,@relatedid,@zh  from dual
WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE languagetype = 'zh' and tabid=@tabid and relateid=@relatedid AND trantable=@trantable);
INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
SELECT 'en',@trantable,@tabid,@relatedid,@en  from dual
WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE languagetype = 'en' and tabid=@tabid and relateid=@relatedid AND trantable=@trantable);
CALL AddColumn(@tablename,@columnname,'varchar',25,'');
update ld_tabdetailfield_seq set id = (select max(tabdetailfieldid) from ld_tabdetailfield);
delimiter;

SET @tabdetailfieldid=(SELECT MAX(tabdetailfieldid)+1 FROM ld_tabdetailfield);
set @tabid = (select tabid from ld_tab where `name` = 'CashBill');
SET @columnname = 'entitytypeid';
SET @trantable='ld_tabdetailfield';
SET @allowhide = 'no';
SET @fieldlabel = '源单';
SET @zh='源单';
SET @en='Orignal Bill';
SET @uitype = 'SelectSource';
SET @typeofdata='V~O~100';
SET @bigtype='selectsource';
SET @parentbigtype='';
SET @sequence = (SELECT IFNULL(MAX(sequence),1) FROM ld_tabdetailfield where tabid=@tabid);
SET @tablename = 'ld_cashbill2paymentplan';
SET @sourcemodule = 'SalesOrder';
INSERT INTO ld_tabdetailfield(tabdetailfieldid,columnname,allowhide,fieldlabel,defaultvalue,presence,fieldtype,typeofdata,sequence,tabid,tablename,width,edit_permission,input_type,
fieldid,newline,defaultcolumn,is_checkimportfield,nullfield,referencemodule,datarange,approve_demand,maxrowsshow,bigtype,savedatabase,parentbigtype,sourcemodule)
SELECT @tabdetailfieldid,@columnname,@allowhide,@fieldlabel,NULL,0,@uitype,@typeofdata,@sequence+1,@tabid,@tablename,22,1,0,0,0,1,0,1,NULL,NULL,NULL,0,@bigtype,'yes',@parentbigtype,@sourcemodule from dual
WHERE NOT EXISTS (SELECT 1 FROM ld_tabdetailfield WHERE tabid=@tabid AND columnname=@columnname and tablename=@tablename and sourcemodule=@sourcemodule);

SET @relatedid = (SELECT tabdetailfieldid FROM ld_tabdetailfield WHERE tabid=@tabid AND columnname=@columnname and sourcemodule=@sourcemodule LIMIT 1);
INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
SELECT 'zh',@trantable,@tabid,@relatedid,@zh  from dual
WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE languagetype = 'zh' and tabid=@tabid and relateid=@relatedid AND trantable=@trantable);
INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
SELECT 'en',@trantable,@tabid,@relatedid,@en  from dual
WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE languagetype = 'en' and tabid=@tabid and relateid=@relatedid AND trantable=@trantable);
CALL AddColumn(@tablename,@columnname,'int',11,'');
update ld_tabdetailfield_seq set id = (select max(tabdetailfieldid) from ld_tabdetailfield);
delimiter;

SET @tabdetailfieldid=(SELECT MAX(tabdetailfieldid)+1 FROM ld_tabdetailfield);
set @tabid = (select tabid from ld_tab where `name` = 'CashBill');
SET @columnname = 'billdate';
SET @trantable='ld_tabdetailfield';
SET @allowhide = 'yes';
SET @fieldlabel = '合同签约日期';
SET @zh='合同签约日期';
SET @en='Orignal Bill';
SET @uitype = 'Date_Ymd';
SET @typeofdata='D~O';
SET @bigtype='relatedmodulefield';
SET @parentbigtype='date';
SET @sequence = (SELECT IFNULL(MAX(sequence),1) FROM ld_tabdetailfield where tabid=@tabid);
SET @tablename = 'ld_cashbill2paymentplan';
SET @sourcemodule = 'SalesOrder';
INSERT INTO ld_tabdetailfield(tabdetailfieldid,columnname,allowhide,fieldlabel,defaultvalue,presence,fieldtype,typeofdata,sequence,tabid,tablename,width,edit_permission,input_type,
fieldid,newline,defaultcolumn,is_checkimportfield,nullfield,referencemodule,datarange,approve_demand,maxrowsshow,bigtype,savedatabase,parentbigtype,sourcemodule)
SELECT @tabdetailfieldid,@columnname,@allowhide,@fieldlabel,NULL,0,@uitype,@typeofdata,@sequence+1,@tabid,@tablename,30,1,0,0,0,1,0,1,NULL,NULL,NULL,0,@bigtype,'no',@parentbigtype,@sourcemodule from dual
WHERE NOT EXISTS (SELECT 1 FROM ld_tabdetailfield WHERE tabid=@tabid AND columnname=@columnname and tablename=@tablename and sourcemodule=@sourcemodule);

SET @relatedid = (SELECT tabdetailfieldid FROM ld_tabdetailfield WHERE tabid=@tabid AND columnname=@columnname and sourcemodule=@sourcemodule LIMIT 1);
INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
SELECT 'zh',@trantable,@tabid,@relatedid,@zh  from dual
WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE languagetype = 'zh' and tabid=@tabid and relateid=@relatedid AND trantable=@trantable);
INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
SELECT 'en',@trantable,@tabid,@relatedid,@en  from dual
WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE languagetype = 'en' and tabid=@tabid and relateid=@relatedid AND trantable=@trantable);
CALL AddColumn(@tablename,@columnname,'date','','');
update ld_tabdetailfield_seq set id = (select max(tabdetailfieldid) from ld_tabdetailfield);
delimiter;


SET @tabdetailfieldid=(SELECT MAX(tabdetailfieldid)+1 FROM ld_tabdetailfield);
set @tabid = (select tabid from ld_tab where `name` = 'CashBill');
SET @columnname = 'source_total';
SET @trantable='ld_tabdetailfield';
SET @allowhide = 'yes';
SET @fieldlabel = '合同金额';
SET @zh='合同金额';
SET @en='Contract Amount';
SET @uitype = 'Amount';
SET @typeofdata='N~O~25,6';
SET @bigtype='relatedmodulefield';
SET @parentbigtype='amount';
SET @sequence = (SELECT IFNULL(MAX(sequence),1) FROM ld_tabdetailfield where tabid=@tabid);
SET @tablename = 'ld_cashbill2paymentplan';
SET @sourcemodule = 'SalesOrder';
INSERT INTO ld_tabdetailfield(tabdetailfieldid,columnname,allowhide,fieldlabel,defaultvalue,presence,fieldtype,typeofdata,sequence,tabid,tablename,width,edit_permission,input_type,
fieldid,newline,defaultcolumn,is_checkimportfield,nullfield,referencemodule,datarange,approve_demand,maxrowsshow,bigtype,savedatabase,parentbigtype,sourcemodule)
SELECT @tabdetailfieldid,@columnname,@allowhide,@fieldlabel,NULL,0,@uitype,@typeofdata,@sequence+1,@tabid,@tablename,30,1,0,0,0,1,0,1,NULL,NULL,NULL,0,@bigtype,'no',@parentbigtype,@sourcemodule from dual
WHERE NOT EXISTS (SELECT 1 FROM ld_tabdetailfield WHERE tabid=@tabid AND columnname=@columnname and tablename=@tablename and sourcemodule=@sourcemodule);

SET @relatedid = (SELECT tabdetailfieldid FROM ld_tabdetailfield WHERE tabid=@tabid AND columnname=@columnname and sourcemodule=@sourcemodule LIMIT 1);
INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
SELECT 'zh',@trantable,@tabid,@relatedid,@zh  from dual
WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE languagetype = 'zh' and tabid=@tabid and relateid=@relatedid AND trantable=@trantable);
INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
SELECT 'en',@trantable,@tabid,@relatedid,@en  from dual
WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE languagetype = 'en' and tabid=@tabid and relateid=@relatedid AND trantable=@trantable);
CALL AddColumn(@tablename,@columnname,'decimal','25','0.000000');
update ld_tabdetailfield_seq set id = (select max(tabdetailfieldid) from ld_tabdetailfield);
delimiter;


SET @tabdetailfieldid=(SELECT MAX(tabdetailfieldid)+1 FROM ld_tabdetailfield);
set @tabid = (select tabid from ld_tab where `name` = 'CashBill');
SET @columnname = 'lastinvoicedate';
SET @trantable='ld_tabdetailfield';
SET @allowhide = 'yes';
SET @fieldlabel = '最新开票日期';
SET @zh='最新开票日期';
SET @en='Latest Invoice Date';
SET @uitype = 'Date_Ymd';
SET @typeofdata='D~O';
SET @bigtype='relatedmodulefield';
SET @parentbigtype='date';
SET @sequence = (SELECT IFNULL(MAX(sequence),1) FROM ld_tabdetailfield where tabid=@tabid);
SET @tablename = 'ld_cashbill2paymentplan';
SET @sourcemodule = 'SalesOrder';
INSERT INTO ld_tabdetailfield(tabdetailfieldid,columnname,allowhide,fieldlabel,defaultvalue,presence,fieldtype,typeofdata,sequence,tabid,tablename,width,edit_permission,input_type,
fieldid,newline,defaultcolumn,is_checkimportfield,nullfield,referencemodule,datarange,approve_demand,maxrowsshow,bigtype,savedatabase,parentbigtype,sourcemodule)
SELECT @tabdetailfieldid,@columnname,@allowhide,@fieldlabel,NULL,0,@uitype,@typeofdata,@sequence+1,@tabid,@tablename,30,1,0,0,0,1,0,1,NULL,NULL,NULL,0,@bigtype,'no',@parentbigtype,@sourcemodule from dual
WHERE NOT EXISTS (SELECT 1 FROM ld_tabdetailfield WHERE tabid=@tabid AND columnname=@columnname and tablename=@tablename and sourcemodule=@sourcemodule);

SET @relatedid = (SELECT tabdetailfieldid FROM ld_tabdetailfield WHERE tabid=@tabid AND columnname=@columnname and sourcemodule=@sourcemodule LIMIT 1);
INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
SELECT 'zh',@trantable,@tabid,@relatedid,@zh  from dual
WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE languagetype = 'zh' and tabid=@tabid and relateid=@relatedid AND trantable=@trantable);
INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
SELECT 'en',@trantable,@tabid,@relatedid,@en  from dual
WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE languagetype = 'en' and tabid=@tabid and relateid=@relatedid AND trantable=@trantable);
CALL AddColumn(@tablename,@columnname,'date','','');
update ld_tabdetailfield_seq set id = (select max(tabdetailfieldid) from ld_tabdetailfield);
delimiter;

SET @tabdetailfieldid=(SELECT MAX(tabdetailfieldid)+1 FROM ld_tabdetailfield);
set @tabid = (select tabid from ld_tab where `name` = 'CashBill');
SET @columnname = 'have_invoicetotal';
SET @trantable='ld_tabdetailfield';
SET @allowhide = 'yes';
SET @fieldlabel = '已开票总额';
SET @zh='已开票总额';
SET @en='Invoice Totalt';
SET @uitype = 'Amount';
SET @typeofdata='N~O~25,6';
SET @bigtype='relatedmodulefield';
SET @parentbigtype='currency';
SET @sequence = (SELECT IFNULL(MAX(sequence),1) FROM ld_tabdetailfield where tabid=@tabid);
SET @tablename = 'ld_cashbill2paymentplan';
SET @sourcemodule = 'SalesOrder';
INSERT INTO ld_tabdetailfield(tabdetailfieldid,columnname,allowhide,fieldlabel,defaultvalue,presence,fieldtype,typeofdata,sequence,tabid,tablename,width,edit_permission,input_type,
fieldid,newline,defaultcolumn,is_checkimportfield,nullfield,referencemodule,datarange,approve_demand,maxrowsshow,bigtype,savedatabase,parentbigtype,sourcemodule)
SELECT @tabdetailfieldid,@columnname,@allowhide,@fieldlabel,NULL,0,@uitype,@typeofdata,@sequence+1,@tabid,@tablename,30,1,0,0,0,1,0,1,NULL,NULL,NULL,0,@bigtype,'yes',@parentbigtype,@sourcemodule from dual
WHERE NOT EXISTS (SELECT 1 FROM ld_tabdetailfield WHERE tabid=@tabid AND columnname=@columnname and tablename=@tablename and sourcemodule=@sourcemodule);

SET @relatedid = (SELECT tabdetailfieldid FROM ld_tabdetailfield WHERE tabid=@tabid AND columnname=@columnname and sourcemodule=@sourcemodule LIMIT 1);
INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
SELECT 'zh',@trantable,@tabid,@relatedid,@zh  from dual
WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE languagetype = 'zh' and tabid=@tabid and relateid=@relatedid AND trantable=@trantable);
INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
SELECT 'en',@trantable,@tabid,@relatedid,@en  from dual
WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE languagetype = 'en' and tabid=@tabid and relateid=@relatedid AND trantable=@trantable);
CALL AddColumn(@tablename,@columnname,'decimal','25','');
update ld_tabdetailfield_seq set id = (select max(tabdetailfieldid) from ld_tabdetailfield);
delimiter;

SET @tabdetailfieldid=(SELECT MAX(tabdetailfieldid)+1 FROM ld_tabdetailfield);
set @tabid = (select tabid from ld_tab where `name` = 'CashBill');
SET @columnname = 'lastcashbilldate';
SET @trantable='ld_tabdetailfield';
SET @allowhide = 'yes';
SET @fieldlabel = '最近收款日期';
SET @zh='最近收款日期';
SET @en='Latest Collection Date';
SET @uitype = 'Date_Ymd';
SET @typeofdata='D~O';
SET @bigtype='relatedmodulefield';
SET @parentbigtype='date';
SET @sequence = (SELECT IFNULL(MAX(sequence),1) FROM ld_tabdetailfield where tabid=@tabid);
SET @tablename = 'ld_cashbill2paymentplan';
SET @sourcemodule = 'SalesOrder';
INSERT INTO ld_tabdetailfield(tabdetailfieldid,columnname,allowhide,fieldlabel,defaultvalue,presence,fieldtype,typeofdata,sequence,tabid,tablename,width,edit_permission,input_type,
fieldid,newline,defaultcolumn,is_checkimportfield,nullfield,referencemodule,datarange,approve_demand,maxrowsshow,bigtype,savedatabase,parentbigtype,sourcemodule)
SELECT @tabdetailfieldid,@columnname,@allowhide,@fieldlabel,NULL,0,@uitype,@typeofdata,@sequence+1,@tabid,@tablename,30,1,0,0,0,1,0,1,NULL,NULL,NULL,0,@bigtype,'yes',@parentbigtype,@sourcemodule from dual
WHERE NOT EXISTS (SELECT 1 FROM ld_tabdetailfield WHERE tabid=@tabid AND columnname=@columnname and tablename=@tablename and sourcemodule=@sourcemodule);

SET @relatedid = (SELECT tabdetailfieldid FROM ld_tabdetailfield WHERE tabid=@tabid AND columnname=@columnname and sourcemodule=@sourcemodule LIMIT 1);
INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
SELECT 'zh',@trantable,@tabid,@relatedid,@zh  from dual
WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE languagetype = 'zh' and tabid=@tabid and relateid=@relatedid AND trantable=@trantable);
INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
SELECT 'en',@trantable,@tabid,@relatedid,@en  from dual
WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE languagetype = 'en' and tabid=@tabid and relateid=@relatedid AND trantable=@trantable);
CALL AddColumn(@tablename,@columnname,'date','','');
update ld_tabdetailfield_seq set id = (select max(tabdetailfieldid) from ld_tabdetailfield);
delimiter;

SET @tabdetailfieldid=(SELECT MAX(tabdetailfieldid)+1 FROM ld_tabdetailfield);
set @tabid = (select tabid from ld_tab where `name` = 'CashBill');
SET @columnname = 'received_amount';
SET @trantable='ld_tabdetailfield';
SET @allowhide = 'yes';
SET @fieldlabel = '合同已收总额';
SET @zh='合同已收总额';
SET @en='Received Amount';
SET @uitype = 'Amount';
SET @typeofdata='N~O~25,6';
SET @bigtype='relatedmodulefield';
SET @parentbigtype='amount';
SET @sequence = (SELECT IFNULL(MAX(sequence),1) FROM ld_tabdetailfield where tabid=@tabid);
SET @tablename = 'ld_cashbill2paymentplan';
SET @sourcemodule = 'SalesOrder';
INSERT INTO ld_tabdetailfield(tabdetailfieldid,columnname,allowhide,fieldlabel,defaultvalue,presence,fieldtype,typeofdata,sequence,tabid,tablename,width,edit_permission,input_type,
fieldid,newline,defaultcolumn,is_checkimportfield,nullfield,referencemodule,datarange,approve_demand,maxrowsshow,bigtype,savedatabase,parentbigtype,sourcemodule)
SELECT @tabdetailfieldid,@columnname,@allowhide,@fieldlabel,NULL,0,@uitype,@typeofdata,@sequence+1,@tabid,@tablename,30,1,0,0,0,1,0,1,NULL,NULL,NULL,0,@bigtype,'no',@parentbigtype,@sourcemodule from dual
WHERE NOT EXISTS (SELECT 1 FROM ld_tabdetailfield WHERE tabid=@tabid AND columnname=@columnname and tablename=@tablename and sourcemodule=@sourcemodule);

SET @relatedid = (SELECT tabdetailfieldid FROM ld_tabdetailfield WHERE tabid=@tabid AND columnname=@columnname and sourcemodule=@sourcemodule LIMIT 1);
INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
SELECT 'zh',@trantable,@tabid,@relatedid,@zh  from dual
WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE languagetype = 'zh' and tabid=@tabid and relateid=@relatedid AND trantable=@trantable);
INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
SELECT 'en',@trantable,@tabid,@relatedid,@en  from dual
WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE languagetype = 'en' and tabid=@tabid and relateid=@relatedid AND trantable=@trantable);
CALL AddColumn(@tablename,@columnname,'decimal','25','');
update ld_tabdetailfield_seq set id = (select max(tabdetailfieldid) from ld_tabdetailfield);
delimiter;

SET @tabdetailfieldid=(SELECT MAX(tabdetailfieldid)+1 FROM ld_tabdetailfield);
set @tabid = (select tabid from ld_tab where `name` = 'CashBill');
SET @columnname = 'amount';
SET @trantable='ld_tabdetailfield';
SET @allowhide = 'no';
SET @fieldlabel = '本次收款金额';
SET @zh='本次收款金额';
SET @en='The amount collected';
SET @uitype = 'Amount';
SET @typeofdata='N~O~25,6';
SET @bigtype='amount';
SET @parentbigtype='';
SET @sequence = (SELECT IFNULL(MAX(sequence),1) FROM ld_tabdetailfield where tabid=@tabid);
SET @tablename = 'ld_cashbill2paymentplan';
SET @sourcemodule = 'SalesOrder';
INSERT INTO ld_tabdetailfield(tabdetailfieldid,columnname,allowhide,fieldlabel,defaultvalue,presence,fieldtype,typeofdata,sequence,tabid,tablename,width,edit_permission,input_type,
fieldid,newline,defaultcolumn,is_checkimportfield,nullfield,referencemodule,datarange,approve_demand,maxrowsshow,bigtype,savedatabase,parentbigtype,sourcemodule)
SELECT @tabdetailfieldid,@columnname,@allowhide,@fieldlabel,NULL,0,@uitype,@typeofdata,@sequence+1,@tabid,@tablename,30,0,0,0,0,1,0,1,NULL,NULL,NULL,0,@bigtype,'yes',@parentbigtype,@sourcemodule from dual
WHERE NOT EXISTS (SELECT 1 FROM ld_tabdetailfield WHERE tabid=@tabid AND columnname=@columnname and tablename=@tablename and sourcemodule=@sourcemodule);

SET @relatedid = (SELECT tabdetailfieldid FROM ld_tabdetailfield WHERE tabid=@tabid AND columnname=@columnname and sourcemodule=@sourcemodule LIMIT 1);
INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
SELECT 'zh',@trantable,@tabid,@relatedid,@zh  from dual
WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE languagetype = 'zh' and tabid=@tabid and relateid=@relatedid AND trantable=@trantable);
INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
SELECT 'en',@trantable,@tabid,@relatedid,@en  from dual
WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE languagetype = 'en' and tabid=@tabid and relateid=@relatedid AND trantable=@trantable);
CALL AddColumn(@tablename,@columnname,'decimal','25','');
update ld_tabdetailfield_seq set id = (select max(tabdetailfieldid) from ld_tabdetailfield);
delimiter;

SET @tabdetailfieldid=(SELECT MAX(tabdetailfieldid)+1 FROM ld_tabdetailfield);
set @tabid = (select tabid from ld_tab where `name` = 'CashBill');
SET @columnname = 'total';
SET @trantable='ld_tabdetailfield';
SET @allowhide = 'no';
SET @fieldlabel = '实际收款金额';
SET @zh='实际收款金额';
SET @en='Actual Receipts';
SET @uitype = 'Amount';
SET @typeofdata='N~O~25,6';
SET @bigtype='';
SET @parentbigtype='';
SET @sequence = (SELECT IFNULL(MAX(sequence),1) FROM ld_tabdetailfield where tabid=@tabid);
SET @tablename = 'ld_cashbill2paymentplan';
SET @sourcemodule = 'SalesOrder';
INSERT INTO ld_tabdetailfield(tabdetailfieldid,columnname,allowhide,fieldlabel,defaultvalue,presence,fieldtype,typeofdata,sequence,tabid,tablename,width,edit_permission,input_type,
fieldid,newline,defaultcolumn,is_checkimportfield,nullfield,referencemodule,datarange,approve_demand,maxrowsshow,bigtype,savedatabase,parentbigtype,sourcemodule)
SELECT @tabdetailfieldid,@columnname,@allowhide,@fieldlabel,NULL,0,@uitype,@typeofdata,@sequence+1,@tabid,@tablename,30,1,0,0,1,1,0,1,NULL,NULL,NULL,0,@bigtype,'yes',@parentbigtype,@sourcemodule from dual
WHERE NOT EXISTS (SELECT 1 FROM ld_tabdetailfield WHERE tabid=@tabid AND columnname=@columnname and tablename=@tablename and sourcemodule=@sourcemodule);

SET @relatedid = (SELECT tabdetailfieldid FROM ld_tabdetailfield WHERE tabid=@tabid AND columnname=@columnname and sourcemodule=@sourcemodule LIMIT 1);
INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
SELECT 'zh',@trantable,@tabid,@relatedid,@zh  from dual
WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE languagetype = 'zh' and tabid=@tabid and relateid=@relatedid AND trantable=@trantable);
INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
SELECT 'en',@trantable,@tabid,@relatedid,@en  from dual
WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE languagetype = 'en' and tabid=@tabid and relateid=@relatedid AND trantable=@trantable);
CALL AddColumn(@tablename,@columnname,'decimal','25','');
update ld_tabdetailfield_seq set id = (select max(tabdetailfieldid) from ld_tabdetailfield);
delimiter;

SET @producttoolfieldid=(SELECT MAX(producttoolfieldid)+1 FROM ld_producttoolfield);
set @tabid = (select tabid from ld_tab where `name` = 'CashBill');
SET @columnname = 'entitytype';
SET @trantable='ld_producttoolfield';
SET @allowhide = 'no';
SET @fieldlabel = '源单类型';
SET @zh='源单类型';
SET @en='Link To';
SET @uitype = 204;
SET @typeofdata='V~O~100';
SET @bigtype='';
SET @parentbigtype='';
SET @sequence = (SELECT IFNULL(MAX(sequence),1) FROM ld_producttoolfield where tabid=@tabid);
SET @tablename = 'ld_cashbill2paymentplan';
SET @sourcemodule = 'SalesOrder';
INSERT INTO ld_producttoolfield(producttoolfieldid,columnname,allowhide,fieldlabel,defaultvalue,presence,uitype,typeofdata,sequence,tabid,tablename,width,edit_permission,input_type,
fieldid,newline,defaultcolumn,is_checkimportfield,nullfield,referencemodule,datarange,approve_demand,maxrowsshow,bigtype,savedatabase,parentbigtype,sourcemodule)
SELECT @producttoolfieldid,@columnname,@allowhide,@fieldlabel,NULL,0,@uitype,@typeofdata,@sequence+1,@tabid,@tablename,30,1,0,0,0,1,0,1,'','','',0,@bigtype,'yes',@parentbigtype,@sourcemodule from dual
WHERE NOT EXISTS (SELECT 1 FROM ld_producttoolfield WHERE tabid=@tabid AND columnname=@columnname and tablename=@tablename and sourcemodule=@sourcemodule);

SET @relatedid = (SELECT producttoolfieldid FROM ld_producttoolfield WHERE tabid=@tabid AND columnname=@columnname and sourcemodule=@sourcemodule LIMIT 1);
INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
SELECT 'zh',@trantable,@tabid,@relatedid,@zh  from dual
WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE languagetype = 'zh' and tabid=@tabid and relateid=@relatedid AND trantable=@trantable);
INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
SELECT 'en',@trantable,@tabid,@relatedid,@en  from dual
WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE languagetype = 'en' and tabid=@tabid and relateid=@relatedid AND trantable=@trantable);
CALL AddColumn(@tablename,@columnname,'varchar',25,'');
update ld_producttoolfield_seq set id = (select max(producttoolfieldid) from ld_producttoolfield);
delimiter;

SET @producttoolfieldid=(SELECT MAX(producttoolfieldid)+1 FROM ld_producttoolfield);
set @tabid = (select tabid from ld_tab where `name` = 'CashBill');
SET @columnname = 'entitytypeid';
SET @trantable='ld_producttoolfield';
SET @allowhide = 'no';
SET @fieldlabel = '源单';
SET @zh='源单';
SET @en='Orignal Bill';
SET @uitype = 202;
SET @typeofdata='V~O~100';
SET @bigtype='selectsource';
SET @parentbigtype='';
SET @sequence = (SELECT IFNULL(MAX(sequence),1) FROM ld_producttoolfield where tabid=@tabid);
SET @tablename = 'ld_cashbill2paymentplan';
SET @sourcemodule = 'SalesOrder';
INSERT INTO ld_producttoolfield(producttoolfieldid,columnname,allowhide,fieldlabel,defaultvalue,presence,uitype,typeofdata,sequence,tabid,tablename,width,edit_permission,input_type,
fieldid,newline,defaultcolumn,is_checkimportfield,nullfield,referencemodule,datarange,approve_demand,maxrowsshow,bigtype,savedatabase,parentbigtype,sourcemodule)
SELECT @producttoolfieldid,@columnname,@allowhide,@fieldlabel,NULL,0,@uitype,@typeofdata,@sequence+1,@tabid,@tablename,22,1,0,0,0,1,0,1,'','','',0,@bigtype,'yes',@parentbigtype,@sourcemodule from dual
WHERE NOT EXISTS (SELECT 1 FROM ld_producttoolfield WHERE tabid=@tabid AND columnname=@columnname and tablename=@tablename and sourcemodule=@sourcemodule);

SET @relatedid = (SELECT producttoolfieldid FROM ld_producttoolfield WHERE tabid=@tabid AND columnname=@columnname and sourcemodule=@sourcemodule LIMIT 1);
INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
SELECT 'zh',@trantable,@tabid,@relatedid,@zh  from dual
WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE languagetype = 'zh' and tabid=@tabid and relateid=@relatedid AND trantable=@trantable);
INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
SELECT 'en',@trantable,@tabid,@relatedid,@en  from dual
WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE languagetype = 'en' and tabid=@tabid and relateid=@relatedid AND trantable=@trantable);
CALL AddColumn(@tablename,@columnname,'int',11,'');
update ld_producttoolfield_seq set id = (select max(producttoolfieldid) from ld_producttoolfield);
delimiter;

SET @producttoolfieldid=(SELECT MAX(producttoolfieldid)+1 FROM ld_producttoolfield);
set @tabid = (select tabid from ld_tab where `name` = 'CashBill');
SET @columnname = 'productname';
SET @trantable='ld_producttoolfield';
SET @allowhide = 'no';
SET @fieldlabel = '产品名称';
SET @zh='产品名称';
SET @en='Product Name';
SET @uitype = 70;
SET @typeofdata='V~M~100';
SET @bigtype='selectsource';
SET @parentbigtype='';
SET @sequence = (SELECT IFNULL(MAX(sequence),1) FROM ld_producttoolfield where tabid=@tabid);
SET @tablename = 'ld_products';
SET @sourcemodule = 'SalesOrder';
SET @producttabid = (select tabid from ld_tab where `name`='Products');
set @fieldid=(select fieldid from ld_field where tabid = @producttabid and fieldname = 'productname');
INSERT INTO ld_producttoolfield(producttoolfieldid,columnname,allowhide,fieldlabel,defaultvalue,presence,uitype,typeofdata,sequence,tabid,tablename,width,edit_permission,input_type,
fieldid,newline,defaultcolumn,is_checkimportfield,nullfield,referencemodule,datarange,approve_demand,maxrowsshow,bigtype,savedatabase,parentbigtype,sourcemodule)
SELECT @producttoolfieldid,@columnname,@allowhide,@fieldlabel,NULL,0,@uitype,@typeofdata,@sequence+1,@tabid,@tablename,45,0,0,@fieldid,0,2,0,0,'','','',0,@bigtype,'yes',@parentbigtype,@sourcemodule from dual
WHERE NOT EXISTS (SELECT 1 FROM ld_producttoolfield WHERE tabid=@tabid AND columnname=@columnname and tablename=@tablename and sourcemodule=@sourcemodule);

SET @relatedid = (SELECT producttoolfieldid FROM ld_producttoolfield WHERE tabid=@tabid AND columnname=@columnname and sourcemodule=@sourcemodule LIMIT 1);
INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
SELECT 'zh',@trantable,@tabid,@relatedid,@zh  from dual
WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE languagetype = 'zh' and tabid=@tabid and relateid=@relatedid AND trantable=@trantable);
INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
SELECT 'en',@trantable,@tabid,@relatedid,@en  from dual
WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE languagetype = 'en' and tabid=@tabid and relateid=@relatedid AND trantable=@trantable);
CALL AddColumn('ld_cashbill2paymentplan','productid','int',11,'');
update ld_producttoolfield_seq set id = (select max(producttoolfieldid) from ld_producttoolfield);
delimiter;

SET @producttoolfieldid=(SELECT MAX(producttoolfieldid)+1 FROM ld_producttoolfield);
set @tabid = (select tabid from ld_tab where `name` = 'CashBill');
SET @columnname = 'product_no';
SET @trantable='ld_producttoolfield';
SET @allowhide = 'yes';
SET @fieldlabel = '产品编号';
SET @zh='产品编号';
SET @en='Product No';
SET @uitype = 4;
SET @typeofdata='V~O';
SET @bigtype='';
SET @parentbigtype='';
SET @sequence = (SELECT IFNULL(MAX(sequence),1) FROM ld_producttoolfield where tabid=@tabid);
SET @tablename = 'ld_products';
SET @sourcemodule = 'SalesOrder';
SET @producttabid = (select tabid from ld_tab where `name`='Products');
SET @fieldid = (SELECT fieldid FROM ld_field where tabid=@producttabid and columnname = 'product_no');
INSERT INTO ld_producttoolfield(producttoolfieldid,columnname,allowhide,fieldlabel,defaultvalue,presence,uitype,typeofdata,sequence,tabid,tablename,width,edit_permission,input_type,
fieldid,newline,defaultcolumn,is_checkimportfield,nullfield,referencemodule,datarange,approve_demand,maxrowsshow,bigtype,savedatabase,parentbigtype,sourcemodule)
SELECT @producttoolfieldid,@columnname,@allowhide,@fieldlabel,NULL,0,@uitype,@typeofdata,@sequence+1,@tabid,@tablename,22,1,1,@fieldid,0,1,0,1,'','','',0,@bigtype,'yes',@parentbigtype,@sourcemodule from dual
WHERE NOT EXISTS (SELECT 1 FROM ld_producttoolfield WHERE tabid=@tabid AND columnname=@columnname and tablename=@tablename and sourcemodule=@sourcemodule);

SET @relatedid = (SELECT producttoolfieldid FROM ld_producttoolfield WHERE tabid=@tabid AND columnname=@columnname and sourcemodule=@sourcemodule LIMIT 1);
INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
SELECT 'zh',@trantable,@tabid,@relatedid,@zh  from dual
WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE languagetype = 'zh' and tabid=@tabid and relateid=@relatedid AND trantable=@trantable);
INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
SELECT 'en',@trantable,@tabid,@relatedid,@en  from dual
WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE languagetype = 'en' and tabid=@tabid and relateid=@relatedid AND trantable=@trantable);

update ld_producttoolfield_seq set id = (select max(producttoolfieldid) from ld_producttoolfield);
delimiter;

SET @producttoolfieldid=(SELECT MAX(producttoolfieldid)+1 FROM ld_producttoolfield);
set @tabid = (select tabid from ld_tab where `name` = 'CashBill');
SET @columnname = 'productsheet';
SET @trantable='ld_producttoolfield';
SET @allowhide = 'yes';
SET @fieldlabel = '规格型号';
SET @zh='规格型号';
SET @en='Specification';
SET @uitype = 1;
SET @typeofdata='V~O';
SET @bigtype='';
SET @parentbigtype='';
SET @sequence = (SELECT IFNULL(MAX(sequence),1) FROM ld_producttoolfield where tabid=@tabid);
SET @tablename = 'ld_products';
SET @sourcemodule = 'SalesOrder';
SET @producttabid = (select tabid from ld_tab where `name`='Products');
SET @fieldid = (SELECT fieldid FROM ld_field where tabid=@producttabid and columnname = 'productsheet');
INSERT INTO ld_producttoolfield(producttoolfieldid,columnname,allowhide,fieldlabel,defaultvalue,presence,uitype,typeofdata,sequence,tabid,tablename,width,edit_permission,input_type,
fieldid,newline,defaultcolumn,is_checkimportfield,nullfield,referencemodule,datarange,approve_demand,maxrowsshow,bigtype,savedatabase,parentbigtype,sourcemodule)
SELECT @producttoolfieldid,@columnname,@allowhide,@fieldlabel,NULL,0,@uitype,@typeofdata,@sequence+1,@tabid,@tablename,22,1,1,@fieldid,0,1,0,1,'','','',0,@bigtype,'yes',@parentbigtype,@sourcemodule from dual
WHERE NOT EXISTS (SELECT 1 FROM ld_producttoolfield WHERE tabid=@tabid AND columnname=@columnname and tablename=@tablename and sourcemodule=@sourcemodule);

SET @relatedid = (SELECT producttoolfieldid FROM ld_producttoolfield WHERE tabid=@tabid AND columnname=@columnname and sourcemodule=@sourcemodule LIMIT 1);
INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
SELECT 'zh',@trantable,@tabid,@relatedid,@zh  from dual
WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE languagetype = 'zh' and tabid=@tabid and relateid=@relatedid AND trantable=@trantable);
INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
SELECT 'en',@trantable,@tabid,@relatedid,@en  from dual
WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE languagetype = 'en' and tabid=@tabid and relateid=@relatedid AND trantable=@trantable);

update ld_producttoolfield_seq set id = (select max(producttoolfieldid) from ld_producttoolfield);
delimiter;


SET @producttoolfieldid=(SELECT MAX(producttoolfieldid)+1 FROM ld_producttoolfield);
set @tabid = (select tabid from ld_tab where `name` = 'CashBill');
SET @columnname = 'productsourcetype';
SET @trantable='ld_producttoolfield';
SET @allowhide = 'yes';
SET @fieldlabel = '产品源单类型';
SET @zh='产品源单类型';
SET @en='Source Type';
SET @uitype = 221;
SET @typeofdata='V~O';
SET @bigtype='relatedmodulefield';
SET @parentbigtype='entitytype';
SET @sequence = (SELECT IFNULL(MAX(sequence),1) FROM ld_producttoolfield where tabid=@tabid);
SET @tablename = 'ld_cashbill2paymentplan';
SET @sourcemodule = 'SalesOrder';
INSERT INTO ld_producttoolfield(producttoolfieldid,columnname,allowhide,fieldlabel,defaultvalue,presence,uitype,typeofdata,sequence,tabid,tablename,width,edit_permission,input_type,
fieldid,newline,defaultcolumn,is_checkimportfield,nullfield,referencemodule,datarange,approve_demand,maxrowsshow,bigtype,savedatabase,parentbigtype,sourcemodule)
SELECT @producttoolfieldid,@columnname,@allowhide,@fieldlabel,NULL,0,@uitype,@typeofdata,@sequence+1,@tabid,@tablename,22,1,0,0,0,1,0,1,'','','',0,@bigtype,'no',@parentbigtype,@sourcemodule from dual
WHERE NOT EXISTS (SELECT 1 FROM ld_producttoolfield WHERE tabid=@tabid AND columnname=@columnname and tablename=@tablename and sourcemodule=@sourcemodule);

SET @relatedid = (SELECT producttoolfieldid FROM ld_producttoolfield WHERE tabid=@tabid AND columnname=@columnname and sourcemodule=@sourcemodule LIMIT 1);
INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
SELECT 'zh',@trantable,@tabid,@relatedid,@zh  from dual
WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE languagetype = 'zh' and tabid=@tabid and relateid=@relatedid AND trantable=@trantable);
INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
SELECT 'en',@trantable,@tabid,@relatedid,@en  from dual
WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE languagetype = 'en' and tabid=@tabid and relateid=@relatedid AND trantable=@trantable);
CALL AddColumn('ld_cashbill2paymentplan','productsourcetype','varchar',25,'');
update ld_producttoolfield_seq set id = (select max(producttoolfieldid) from ld_producttoolfield);
delimiter;


SET @producttoolfieldid=(SELECT MAX(producttoolfieldid)+1 FROM ld_producttoolfield);
set @tabid = (select tabid from ld_tab where `name` = 'CashBill');
SET @columnname = 'productsourceid';
SET @trantable='ld_producttoolfield';
SET @allowhide = 'yes';
SET @fieldlabel = '产品源单';
SET @zh='产品源单';
SET @en='Source Bill';
SET @uitype = 220;
SET @typeofdata='V~O';
SET @bigtype='relatedmodulefield';
SET @parentbigtype='selectsource';
SET @sequence = (SELECT IFNULL(MAX(sequence),1) FROM ld_producttoolfield where tabid=@tabid);
SET @tablename = 'ld_cashbill2paymentplan';
SET @sourcemodule = 'SalesOrder';
INSERT INTO ld_producttoolfield(producttoolfieldid,columnname,allowhide,fieldlabel,defaultvalue,presence,uitype,typeofdata,sequence,tabid,tablename,width,edit_permission,input_type,
fieldid,newline,defaultcolumn,is_checkimportfield,nullfield,referencemodule,datarange,approve_demand,maxrowsshow,bigtype,savedatabase,parentbigtype,sourcemodule)
SELECT @producttoolfieldid,@columnname,@allowhide,@fieldlabel,NULL,0,@uitype,@typeofdata,@sequence+1,@tabid,@tablename,30,1,0,0,0,1,0,1,'','','',0,@bigtype,'no',@parentbigtype,@sourcemodule from dual
WHERE NOT EXISTS (SELECT 1 FROM ld_producttoolfield WHERE tabid=@tabid AND columnname=@columnname and tablename=@tablename and sourcemodule=@sourcemodule);

SET @relatedid = (SELECT producttoolfieldid FROM ld_producttoolfield WHERE tabid=@tabid AND columnname=@columnname and sourcemodule=@sourcemodule LIMIT 1);
INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
SELECT 'zh',@trantable,@tabid,@relatedid,@zh  from dual
WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE languagetype = 'zh' and tabid=@tabid and relateid=@relatedid AND trantable=@trantable);
INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
SELECT 'en',@trantable,@tabid,@relatedid,@en  from dual
WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE languagetype = 'en' and tabid=@tabid and relateid=@relatedid AND trantable=@trantable);
CALL AddColumn('ld_cashbill2paymentplan','productsourceid','int',11,'');
update ld_producttoolfield_seq set id = (select max(producttoolfieldid) from ld_producttoolfield);
delimiter;


SET @producttoolfieldid=(SELECT MAX(producttoolfieldid)+1 FROM ld_producttoolfield);
set @tabid = (select tabid from ld_tab where `name` = 'CashBill');
SET @columnname = 'tax_amount';
SET @trantable='ld_producttoolfield';
SET @allowhide = 'yes';
SET @fieldlabel = '价税合计';
SET @zh='价税合计';
SET @en='Tax-inclusive Amount';
SET @uitype = 28;
SET @typeofdata='N~O~25,6';
SET @bigtype='';
SET @parentbigtype='';
SET @sequence = (SELECT IFNULL(MAX(sequence),1) FROM ld_producttoolfield where tabid=@tabid);
SET @tablename = 'ld_cashbill2paymentplan';
SET @sourcemodule = 'SalesOrder';
INSERT INTO ld_producttoolfield(producttoolfieldid,columnname,allowhide,fieldlabel,defaultvalue,presence,uitype,typeofdata,sequence,tabid,tablename,width,edit_permission,input_type,
fieldid,newline,defaultcolumn,is_checkimportfield,nullfield,referencemodule,datarange,approve_demand,maxrowsshow,bigtype,savedatabase,parentbigtype,sourcemodule)
SELECT @producttoolfieldid,@columnname,@allowhide,@fieldlabel,NULL,0,@uitype,@typeofdata,@sequence+1,@tabid,@tablename,22,1,0,0,0,1,0,1,'','','',0,@bigtype,'yes',@parentbigtype,@sourcemodule from dual
WHERE NOT EXISTS (SELECT 1 FROM ld_producttoolfield WHERE tabid=@tabid AND columnname=@columnname and tablename=@tablename and sourcemodule=@sourcemodule);

SET @relatedid = (SELECT producttoolfieldid FROM ld_producttoolfield WHERE tabid=@tabid AND columnname=@columnname and sourcemodule=@sourcemodule LIMIT 1);
INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
SELECT 'zh',@trantable,@tabid,@relatedid,@zh  from dual
WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE languagetype = 'zh' and tabid=@tabid and relateid=@relatedid AND trantable=@trantable);
INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
SELECT 'en',@trantable,@tabid,@relatedid,@en  from dual
WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE languagetype = 'en' and tabid=@tabid and relateid=@relatedid AND trantable=@trantable);
CALL AddColumn('ld_cashbill2paymentplan','tax_amount','decimal',25,'');
update ld_producttoolfield_seq set id = (select max(producttoolfieldid) from ld_producttoolfield);
delimiter;


SET @producttoolfieldid=(SELECT MAX(producttoolfieldid)+1 FROM ld_producttoolfield);
set @tabid = (select tabid from ld_tab where `name` = 'CashBill');
SET @columnname = 'product_received_amount';
SET @trantable='ld_producttoolfield';
SET @allowhide = 'yes';
SET @fieldlabel = '产品已收总额';
SET @zh='产品已收总额';
SET @en='Received Amount';
SET @uitype = 50;
SET @typeofdata='NN~O~25,3';
SET @bigtype='';
SET @parentbigtype='';
SET @sequence = (SELECT IFNULL(MAX(sequence),1) FROM ld_producttoolfield where tabid=@tabid);
SET @tablename = 'ld_cashbill2paymentplan';
SET @sourcemodule = 'SalesOrder';
INSERT INTO ld_producttoolfield(producttoolfieldid,columnname,allowhide,fieldlabel,defaultvalue,presence,uitype,typeofdata,sequence,tabid,tablename,width,edit_permission,input_type,
fieldid,newline,defaultcolumn,is_checkimportfield,nullfield,referencemodule,datarange,approve_demand,maxrowsshow,bigtype,savedatabase,parentbigtype,sourcemodule)
SELECT @producttoolfieldid,@columnname,@allowhide,@fieldlabel,NULL,0,@uitype,@typeofdata,@sequence+1,@tabid,@tablename,22,1,0,0,1,1,0,1,'','','',0,@bigtype,'no',@parentbigtype,@sourcemodule from dual
WHERE NOT EXISTS (SELECT 1 FROM ld_producttoolfield WHERE tabid=@tabid AND columnname=@columnname and tablename=@tablename  and sourcemodule=@sourcemodule);

SET @relatedid = (SELECT producttoolfieldid FROM ld_producttoolfield WHERE tabid=@tabid AND columnname=@columnname  and sourcemodule=@sourcemodule LIMIT 1);
INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
SELECT 'zh',@trantable,@tabid,@relatedid,@zh  from dual
WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE languagetype = 'zh' and tabid=@tabid and relateid=@relatedid AND trantable=@trantable);
INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
SELECT 'en',@trantable,@tabid,@relatedid,@en  from dual
WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE languagetype = 'en' and tabid=@tabid and relateid=@relatedid AND trantable=@trantable);
CALL AddColumn('ld_cashbill2paymentplan','product_received_amount','decimal',25,'');
update ld_producttoolfield_seq set id = (select max(producttoolfieldid) from ld_producttoolfield);
delimiter;


SET @producttoolfieldid=(SELECT MAX(producttoolfieldid)+1 FROM ld_producttoolfield);
set @tabid = (select tabid from ld_tab where `name` = 'CashBill');
SET @columnname = 'amount';
SET @trantable='ld_producttoolfield';
SET @allowhide = 'no';
SET @fieldlabel = '本次收款金额';
SET @zh='本次收款金额';
SET @en='The amount collected';
SET @uitype = 50;
SET @typeofdata='NN~O~25,3';
SET @bigtype='';
SET @parentbigtype='';
SET @sequence = (SELECT IFNULL(MAX(sequence),1) FROM ld_producttoolfield where tabid=@tabid);
SET @tablename = 'ld_cashbill2paymentplan';
SET @sourcemodule = 'SalesOrder';
INSERT INTO ld_producttoolfield(producttoolfieldid,columnname,allowhide,fieldlabel,defaultvalue,presence,uitype,typeofdata,sequence,tabid,tablename,width,edit_permission,input_type,
fieldid,newline,defaultcolumn,is_checkimportfield,nullfield,referencemodule,datarange,approve_demand,maxrowsshow,bigtype,savedatabase,parentbigtype,sourcemodule)
SELECT @producttoolfieldid,@columnname,@allowhide,@fieldlabel,NULL,0,@uitype,@typeofdata,@sequence+1,@tabid,@tablename,35,0,0,0,0,1,0,1,'','','',0,@bigtype,'yes',@parentbigtype,@sourcemodule from dual
WHERE NOT EXISTS (SELECT 1 FROM ld_producttoolfield WHERE tabid=@tabid AND columnname=@columnname and tablename=@tablename  and sourcemodule=@sourcemodule);

SET @relatedid = (SELECT producttoolfieldid FROM ld_producttoolfield WHERE tabid=@tabid AND columnname=@columnname  and sourcemodule=@sourcemodule LIMIT 1);
INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
SELECT 'zh',@trantable,@tabid,@relatedid,@zh  from dual
WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE languagetype = 'zh' and tabid=@tabid and relateid=@relatedid AND trantable=@trantable);
INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
SELECT 'en',@trantable,@tabid,@relatedid,@en  from dual
WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE languagetype = 'en' and tabid=@tabid and relateid=@relatedid AND trantable=@trantable);

update ld_producttoolfield_seq set id = (select max(producttoolfieldid) from ld_producttoolfield);
delimiter;



SET @producttoolfieldid=(SELECT MAX(producttoolfieldid)+1 FROM ld_producttoolfield);
set @tabid = (select tabid from ld_tab where `name` = 'CashBill');
SET @columnname = 'total';
SET @trantable='ld_producttoolfield';
SET @allowhide = 'no';
SET @fieldlabel = '实际收款金额';
SET @zh='实际收款金额';
SET @en='Actual Receipts';
SET @uitype = 50;
SET @typeofdata='NN~O~25,3';
SET @bigtype='';
SET @parentbigtype='';
SET @sequence = (SELECT IFNULL(MAX(sequence),1) FROM ld_producttoolfield where tabid=@tabid);
SET @tablename = 'ld_cashbill2paymentplan';
SET @sourcemodule = 'SalesOrder';
INSERT INTO ld_producttoolfield(producttoolfieldid,columnname,allowhide,fieldlabel,defaultvalue,presence,uitype,typeofdata,sequence,tabid,tablename,width,edit_permission,input_type,
fieldid,newline,defaultcolumn,is_checkimportfield,nullfield,referencemodule,datarange,approve_demand,maxrowsshow,bigtype,savedatabase,parentbigtype,sourcemodule)
SELECT @producttoolfieldid,@columnname,@allowhide,@fieldlabel,NULL,0,@uitype,@typeofdata,@sequence+1,@tabid,@tablename,35,1,0,0,1,1,0,1,'','','',0,@bigtype,'yes',@parentbigtype,@sourcemodule from dual
WHERE NOT EXISTS (SELECT 1 FROM ld_producttoolfield WHERE tabid=@tabid AND columnname=@columnname and tablename=@tablename  and sourcemodule=@sourcemodule);

SET @relatedid = (SELECT producttoolfieldid FROM ld_producttoolfield WHERE tabid=@tabid AND columnname=@columnname  and sourcemodule=@sourcemodule LIMIT 1);
INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
SELECT 'zh',@trantable,@tabid,@relatedid,@zh  from dual
WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE languagetype = 'zh' and tabid=@tabid and relateid=@relatedid AND trantable=@trantable);
INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
SELECT 'en',@trantable,@tabid,@relatedid,@en  from dual
WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE languagetype = 'en' and tabid=@tabid and relateid=@relatedid AND trantable=@trantable);

update ld_producttoolfield_seq set id = (select max(producttoolfieldid) from ld_producttoolfield);
delimiter;


SET @tabdetailfieldid=(SELECT MAX(tabdetailfieldid)+1 FROM ld_tabdetailfield);
set @tabid = (select tabid from ld_tab where `name` = 'CashBill');
SET @columnname = 'entitytype';
SET @trantable='ld_tabdetailfield';
SET @allowhide = 'no';
SET @fieldlabel = '源单类型';
SET @zh='源单类型';
SET @en='Link To';
SET @uitype = 'entitytype';
SET @typeofdata='V~O';
SET @bigtype='';
SET @parentbigtype='';
SET @sequence = (SELECT IFNULL(MAX(sequence),1) FROM ld_tabdetailfield where tabid=@tabid);
SET @tablename = 'ld_cashbill2paymentplan';
SET @sourcemodule = 'ServiceContracts';
INSERT INTO ld_tabdetailfield(tabdetailfieldid,columnname,allowhide,fieldlabel,defaultvalue,presence,fieldtype,typeofdata,sequence,tabid,tablename,width,edit_permission,input_type,
fieldid,newline,defaultcolumn,is_checkimportfield,nullfield,referencemodule,datarange,approve_demand,maxrowsshow,bigtype,savedatabase,parentbigtype,sourcemodule)
SELECT @tabdetailfieldid,@columnname,@allowhide,@fieldlabel,NULL,0,@uitype,@typeofdata,@sequence+1,@tabid,@tablename,22,1,0,0,0,1,0,1,'','','',0,@bigtype,'yes',@parentbigtype,@sourcemodule from dual
WHERE NOT EXISTS (SELECT 1 FROM ld_tabdetailfield WHERE tabid=@tabid AND columnname=@columnname and tablename=@tablename and sourcemodule=@sourcemodule);

SET @relatedid = (SELECT tabdetailfieldid FROM ld_tabdetailfield WHERE tabid=@tabid AND columnname=@columnname  and sourcemodule=@sourcemodule LIMIT 1);
INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
SELECT 'zh',@trantable,@tabid,@relatedid,@zh  from dual
WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE languagetype = 'zh' and tabid=@tabid and relateid=@relatedid AND trantable=@trantable);
INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
SELECT 'en',@trantable,@tabid,@relatedid,@en  from dual
WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE languagetype = 'en' and tabid=@tabid and relateid=@relatedid AND trantable=@trantable);
CALL AddColumn(@tablename,@columnname,'varchar',25,'');
update ld_tabdetailfield_seq set id = (select max(tabdetailfieldid) from ld_tabdetailfield);
delimiter;

SET @tabdetailfieldid=(SELECT MAX(tabdetailfieldid)+1 FROM ld_tabdetailfield);
set @tabid = (select tabid from ld_tab where `name` = 'CashBill');
SET @columnname = 'entitytypeid';
SET @trantable='ld_tabdetailfield';
SET @allowhide = 'no';
SET @fieldlabel = '源单';
SET @zh='源单';
SET @en='Orignal Bill';
SET @uitype = 'SelectSource';
SET @typeofdata='V~O~100';
SET @bigtype='selectsource';
SET @parentbigtype='';
SET @sequence = (SELECT IFNULL(MAX(sequence),1) FROM ld_tabdetailfield where tabid=@tabid);
SET @tablename = 'ld_cashbill2paymentplan';
SET @sourcemodule = 'ServiceContracts';
INSERT INTO ld_tabdetailfield(tabdetailfieldid,columnname,allowhide,fieldlabel,defaultvalue,presence,fieldtype,typeofdata,sequence,tabid,tablename,width,edit_permission,input_type,
fieldid,newline,defaultcolumn,is_checkimportfield,nullfield,referencemodule,datarange,approve_demand,maxrowsshow,bigtype,savedatabase,parentbigtype,sourcemodule)
SELECT @tabdetailfieldid,@columnname,@allowhide,@fieldlabel,NULL,0,@uitype,@typeofdata,@sequence+1,@tabid,@tablename,22,1,0,0,0,1,0,1,NULL,NULL,NULL,0,@bigtype,'yes',@parentbigtype,@sourcemodule from dual
WHERE NOT EXISTS (SELECT 1 FROM ld_tabdetailfield WHERE tabid=@tabid AND columnname=@columnname and tablename=@tablename and sourcemodule=@sourcemodule);

SET @relatedid = (SELECT tabdetailfieldid FROM ld_tabdetailfield WHERE tabid=@tabid AND columnname=@columnname and sourcemodule=@sourcemodule LIMIT 1);
INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
SELECT 'zh',@trantable,@tabid,@relatedid,@zh  from dual
WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE languagetype = 'zh' and tabid=@tabid and relateid=@relatedid AND trantable=@trantable);
INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
SELECT 'en',@trantable,@tabid,@relatedid,@en  from dual
WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE languagetype = 'en' and tabid=@tabid and relateid=@relatedid AND trantable=@trantable);
CALL AddColumn(@tablename,@columnname,'int',11,'');
update ld_tabdetailfield_seq set id = (select max(tabdetailfieldid) from ld_tabdetailfield);
delimiter;

SET @tabdetailfieldid=(SELECT MAX(tabdetailfieldid)+1 FROM ld_tabdetailfield);
set @tabid = (select tabid from ld_tab where `name` = 'CashBill');
SET @columnname = 'billdate';
SET @trantable='ld_tabdetailfield';
SET @allowhide = 'yes';
SET @fieldlabel = '合同签约日期';
SET @zh='合同签约日期';
SET @en='Orignal Bill';
SET @uitype = 'Date_Ymd';
SET @typeofdata='D~O';
SET @bigtype='relatedmodulefield';
SET @parentbigtype='date';
SET @sequence = (SELECT IFNULL(MAX(sequence),1) FROM ld_tabdetailfield where tabid=@tabid);
SET @tablename = 'ld_cashbill2paymentplan';
SET @sourcemodule = 'ServiceContracts';
INSERT INTO ld_tabdetailfield(tabdetailfieldid,columnname,allowhide,fieldlabel,defaultvalue,presence,fieldtype,typeofdata,sequence,tabid,tablename,width,edit_permission,input_type,
fieldid,newline,defaultcolumn,is_checkimportfield,nullfield,referencemodule,datarange,approve_demand,maxrowsshow,bigtype,savedatabase,parentbigtype,sourcemodule)
SELECT @tabdetailfieldid,@columnname,@allowhide,@fieldlabel,NULL,0,@uitype,@typeofdata,@sequence+1,@tabid,@tablename,30,1,0,0,0,1,0,1,NULL,NULL,NULL,0,@bigtype,'no',@parentbigtype,@sourcemodule from dual
WHERE NOT EXISTS (SELECT 1 FROM ld_tabdetailfield WHERE tabid=@tabid AND columnname=@columnname and tablename=@tablename and sourcemodule=@sourcemodule);

SET @relatedid = (SELECT tabdetailfieldid FROM ld_tabdetailfield WHERE tabid=@tabid AND columnname=@columnname and sourcemodule=@sourcemodule LIMIT 1);
INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
SELECT 'zh',@trantable,@tabid,@relatedid,@zh  from dual
WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE languagetype = 'zh' and tabid=@tabid and relateid=@relatedid AND trantable=@trantable);
INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
SELECT 'en',@trantable,@tabid,@relatedid,@en  from dual
WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE languagetype = 'en' and tabid=@tabid and relateid=@relatedid AND trantable=@trantable);
CALL AddColumn(@tablename,@columnname,'date','','');
update ld_tabdetailfield_seq set id = (select max(tabdetailfieldid) from ld_tabdetailfield);
delimiter;


SET @tabdetailfieldid=(SELECT MAX(tabdetailfieldid)+1 FROM ld_tabdetailfield);
set @tabid = (select tabid from ld_tab where `name` = 'CashBill');
SET @columnname = 'source_total';
SET @trantable='ld_tabdetailfield';
SET @allowhide = 'yes';
SET @fieldlabel = '合同金额';
SET @zh='合同金额';
SET @en='Contract Amount';
SET @uitype = 'Amount';
SET @typeofdata='N~O~25,6';
SET @bigtype='relatedmodulefield';
SET @parentbigtype='amount';
SET @sequence = (SELECT IFNULL(MAX(sequence),1) FROM ld_tabdetailfield where tabid=@tabid);
SET @tablename = 'ld_cashbill2paymentplan';
SET @sourcemodule = 'ServiceContracts';
INSERT INTO ld_tabdetailfield(tabdetailfieldid,columnname,allowhide,fieldlabel,defaultvalue,presence,fieldtype,typeofdata,sequence,tabid,tablename,width,edit_permission,input_type,
fieldid,newline,defaultcolumn,is_checkimportfield,nullfield,referencemodule,datarange,approve_demand,maxrowsshow,bigtype,savedatabase,parentbigtype,sourcemodule)
SELECT @tabdetailfieldid,@columnname,@allowhide,@fieldlabel,NULL,0,@uitype,@typeofdata,@sequence+1,@tabid,@tablename,30,1,0,0,0,1,0,1,NULL,NULL,NULL,0,@bigtype,'no',@parentbigtype,@sourcemodule from dual
WHERE NOT EXISTS (SELECT 1 FROM ld_tabdetailfield WHERE tabid=@tabid AND columnname=@columnname and tablename=@tablename and sourcemodule=@sourcemodule);

SET @relatedid = (SELECT tabdetailfieldid FROM ld_tabdetailfield WHERE tabid=@tabid AND columnname=@columnname and sourcemodule=@sourcemodule LIMIT 1);
INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
SELECT 'zh',@trantable,@tabid,@relatedid,@zh  from dual
WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE languagetype = 'zh' and tabid=@tabid and relateid=@relatedid AND trantable=@trantable);
INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
SELECT 'en',@trantable,@tabid,@relatedid,@en  from dual
WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE languagetype = 'en' and tabid=@tabid and relateid=@relatedid AND trantable=@trantable);
CALL AddColumn(@tablename,@columnname,'decimal','25','');
update ld_tabdetailfield_seq set id = (select max(tabdetailfieldid) from ld_tabdetailfield);
delimiter;


SET @tabdetailfieldid=(SELECT MAX(tabdetailfieldid)+1 FROM ld_tabdetailfield);
set @tabid = (select tabid from ld_tab where `name` = 'CashBill');
SET @columnname = 'lastinvoicedate';
SET @trantable='ld_tabdetailfield';
SET @allowhide = 'yes';
SET @fieldlabel = '最新开票日期';
SET @zh='最新开票日期';
SET @en='Latest Invoice Date';
SET @uitype = 'Date_Ymd';
SET @typeofdata='D~O';
SET @bigtype='relatedmodulefield';
SET @parentbigtype='date';
SET @sequence = (SELECT IFNULL(MAX(sequence),1) FROM ld_tabdetailfield where tabid=@tabid);
SET @tablename = 'ld_cashbill2paymentplan';
SET @sourcemodule = 'ServiceContracts';
INSERT INTO ld_tabdetailfield(tabdetailfieldid,columnname,allowhide,fieldlabel,defaultvalue,presence,fieldtype,typeofdata,sequence,tabid,tablename,width,edit_permission,input_type,
fieldid,newline,defaultcolumn,is_checkimportfield,nullfield,referencemodule,datarange,approve_demand,maxrowsshow,bigtype,savedatabase,parentbigtype,sourcemodule)
SELECT @tabdetailfieldid,@columnname,@allowhide,@fieldlabel,NULL,0,@uitype,@typeofdata,@sequence+1,@tabid,@tablename,30,1,0,0,0,1,0,1,NULL,NULL,NULL,0,@bigtype,'no',@parentbigtype,@sourcemodule from dual
WHERE NOT EXISTS (SELECT 1 FROM ld_tabdetailfield WHERE tabid=@tabid AND columnname=@columnname and tablename=@tablename and sourcemodule=@sourcemodule);

SET @relatedid = (SELECT tabdetailfieldid FROM ld_tabdetailfield WHERE tabid=@tabid AND columnname=@columnname and sourcemodule=@sourcemodule LIMIT 1);
INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
SELECT 'zh',@trantable,@tabid,@relatedid,@zh  from dual
WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE languagetype = 'zh' and tabid=@tabid and relateid=@relatedid AND trantable=@trantable);
INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
SELECT 'en',@trantable,@tabid,@relatedid,@en  from dual
WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE languagetype = 'en' and tabid=@tabid and relateid=@relatedid AND trantable=@trantable);
CALL AddColumn(@tablename,@columnname,'date','','');
update ld_tabdetailfield_seq set id = (select max(tabdetailfieldid) from ld_tabdetailfield);
delimiter;

SET @tabdetailfieldid=(SELECT MAX(tabdetailfieldid)+1 FROM ld_tabdetailfield);
set @tabid = (select tabid from ld_tab where `name` = 'CashBill');
SET @columnname = 'have_invoicetotal';
SET @trantable='ld_tabdetailfield';
SET @allowhide = 'yes';
SET @fieldlabel = '已开票总额';
SET @zh='已开票总额';
SET @en='Invoice Totalt';
SET @uitype = 'Amount';
SET @typeofdata='N~O~25,6';
SET @bigtype='relatedmodulefield';
SET @parentbigtype='currency';
SET @sequence = (SELECT IFNULL(MAX(sequence),1) FROM ld_tabdetailfield where tabid=@tabid);
SET @tablename = 'ld_cashbill2paymentplan';
SET @sourcemodule = 'ServiceContracts';
INSERT INTO ld_tabdetailfield(tabdetailfieldid,columnname,allowhide,fieldlabel,defaultvalue,presence,fieldtype,typeofdata,sequence,tabid,tablename,width,edit_permission,input_type,
fieldid,newline,defaultcolumn,is_checkimportfield,nullfield,referencemodule,datarange,approve_demand,maxrowsshow,bigtype,savedatabase,parentbigtype,sourcemodule)
SELECT @tabdetailfieldid,@columnname,@allowhide,@fieldlabel,NULL,0,@uitype,@typeofdata,@sequence+1,@tabid,@tablename,30,1,0,0,0,1,0,1,NULL,NULL,NULL,0,@bigtype,'yes',@parentbigtype,@sourcemodule from dual
WHERE NOT EXISTS (SELECT 1 FROM ld_tabdetailfield WHERE tabid=@tabid AND columnname=@columnname and tablename=@tablename and sourcemodule=@sourcemodule);

SET @relatedid = (SELECT tabdetailfieldid FROM ld_tabdetailfield WHERE tabid=@tabid AND columnname=@columnname and sourcemodule=@sourcemodule LIMIT 1);
INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
SELECT 'zh',@trantable,@tabid,@relatedid,@zh  from dual
WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE languagetype = 'zh' and tabid=@tabid and relateid=@relatedid AND trantable=@trantable);
INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
SELECT 'en',@trantable,@tabid,@relatedid,@en  from dual
WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE languagetype = 'en' and tabid=@tabid and relateid=@relatedid AND trantable=@trantable);
CALL AddColumn(@tablename,@columnname,'decimal','25','');
update ld_tabdetailfield_seq set id = (select max(tabdetailfieldid) from ld_tabdetailfield);
delimiter;

SET @tabdetailfieldid=(SELECT MAX(tabdetailfieldid)+1 FROM ld_tabdetailfield);
set @tabid = (select tabid from ld_tab where `name` = 'CashBill');
SET @columnname = 'lastcashbilldate';
SET @trantable='ld_tabdetailfield';
SET @allowhide = 'yes';
SET @fieldlabel = '最近收款日期';
SET @zh='最近收款日期';
SET @en='Latest Collection Date';
SET @uitype = 'Date_Ymd';
SET @typeofdata='D~O';
SET @bigtype='relatedmodulefield';
SET @parentbigtype='date';
SET @sequence = (SELECT IFNULL(MAX(sequence),1) FROM ld_tabdetailfield where tabid=@tabid);
SET @tablename = 'ld_cashbill2paymentplan';
SET @sourcemodule = 'ServiceContracts';
INSERT INTO ld_tabdetailfield(tabdetailfieldid,columnname,allowhide,fieldlabel,defaultvalue,presence,fieldtype,typeofdata,sequence,tabid,tablename,width,edit_permission,input_type,
fieldid,newline,defaultcolumn,is_checkimportfield,nullfield,referencemodule,datarange,approve_demand,maxrowsshow,bigtype,savedatabase,parentbigtype,sourcemodule)
SELECT @tabdetailfieldid,@columnname,@allowhide,@fieldlabel,NULL,0,@uitype,@typeofdata,@sequence+1,@tabid,@tablename,30,1,0,0,0,1,0,1,NULL,NULL,NULL,0,@bigtype,'yes',@parentbigtype,@sourcemodule from dual
WHERE NOT EXISTS (SELECT 1 FROM ld_tabdetailfield WHERE tabid=@tabid AND columnname=@columnname and tablename=@tablename and sourcemodule=@sourcemodule);

SET @relatedid = (SELECT tabdetailfieldid FROM ld_tabdetailfield WHERE tabid=@tabid AND columnname=@columnname and sourcemodule=@sourcemodule LIMIT 1);
INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
SELECT 'zh',@trantable,@tabid,@relatedid,@zh  from dual
WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE languagetype = 'zh' and tabid=@tabid and relateid=@relatedid AND trantable=@trantable);
INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
SELECT 'en',@trantable,@tabid,@relatedid,@en  from dual
WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE languagetype = 'en' and tabid=@tabid and relateid=@relatedid AND trantable=@trantable);
CALL AddColumn(@tablename,@columnname,'date','','');
update ld_tabdetailfield_seq set id = (select max(tabdetailfieldid) from ld_tabdetailfield);
delimiter;

SET @tabdetailfieldid=(SELECT MAX(tabdetailfieldid)+1 FROM ld_tabdetailfield);
set @tabid = (select tabid from ld_tab where `name` = 'CashBill');
SET @columnname = 'received_amount';
SET @trantable='ld_tabdetailfield';
SET @allowhide = 'yes';
SET @fieldlabel = '合同已收总额';
SET @zh='合同已收总额';
SET @en='Received Amount';
SET @uitype = 'Amount';
SET @typeofdata='N~O~25,6';
SET @bigtype='relatedmodulefield';
SET @parentbigtype='amount';
SET @sequence = (SELECT IFNULL(MAX(sequence),1) FROM ld_tabdetailfield where tabid=@tabid);
SET @tablename = 'ld_cashbill2paymentplan';
SET @sourcemodule = 'ServiceContracts';
INSERT INTO ld_tabdetailfield(tabdetailfieldid,columnname,allowhide,fieldlabel,defaultvalue,presence,fieldtype,typeofdata,sequence,tabid,tablename,width,edit_permission,input_type,
fieldid,newline,defaultcolumn,is_checkimportfield,nullfield,referencemodule,datarange,approve_demand,maxrowsshow,bigtype,savedatabase,parentbigtype,sourcemodule)
SELECT @tabdetailfieldid,@columnname,@allowhide,@fieldlabel,NULL,0,@uitype,@typeofdata,@sequence+1,@tabid,@tablename,30,1,0,0,0,1,0,1,NULL,NULL,NULL,0,@bigtype,'no',@parentbigtype,@sourcemodule from dual
WHERE NOT EXISTS (SELECT 1 FROM ld_tabdetailfield WHERE tabid=@tabid AND columnname=@columnname and tablename=@tablename and sourcemodule=@sourcemodule);

SET @relatedid = (SELECT tabdetailfieldid FROM ld_tabdetailfield WHERE tabid=@tabid AND columnname=@columnname and sourcemodule=@sourcemodule LIMIT 1);
INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
SELECT 'zh',@trantable,@tabid,@relatedid,@zh  from dual
WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE languagetype = 'zh' and tabid=@tabid and relateid=@relatedid AND trantable=@trantable);
INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
SELECT 'en',@trantable,@tabid,@relatedid,@en  from dual
WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE languagetype = 'en' and tabid=@tabid and relateid=@relatedid AND trantable=@trantable);
CALL AddColumn(@tablename,@columnname,'decimal','25','');
update ld_tabdetailfield_seq set id = (select max(tabdetailfieldid) from ld_tabdetailfield);
delimiter;

SET @tabdetailfieldid=(SELECT MAX(tabdetailfieldid)+1 FROM ld_tabdetailfield);
set @tabid = (select tabid from ld_tab where `name` = 'CashBill');
SET @columnname = 'amount';
SET @trantable='ld_tabdetailfield';
SET @allowhide = 'no';
SET @fieldlabel = '本次收款金额';
SET @zh='本次收款金额';
SET @en='Received Amount';
SET @uitype = 'Amount';
SET @typeofdata='N~O~25,6';
SET @bigtype='amount';
SET @parentbigtype='';
SET @sequence = (SELECT IFNULL(MAX(sequence),1) FROM ld_tabdetailfield where tabid=@tabid);
SET @tablename = 'ld_cashbill2paymentplan';
SET @sourcemodule = 'ServiceContracts';
INSERT INTO ld_tabdetailfield(tabdetailfieldid,columnname,allowhide,fieldlabel,defaultvalue,presence,fieldtype,typeofdata,sequence,tabid,tablename,width,edit_permission,input_type,
fieldid,newline,defaultcolumn,is_checkimportfield,nullfield,referencemodule,datarange,approve_demand,maxrowsshow,bigtype,savedatabase,parentbigtype,sourcemodule)
SELECT @tabdetailfieldid,@columnname,@allowhide,@fieldlabel,NULL,0,@uitype,@typeofdata,@sequence+1,@tabid,@tablename,30,0,0,0,0,1,0,1,NULL,NULL,NULL,0,@bigtype,'yes',@parentbigtype,@sourcemodule from dual
WHERE NOT EXISTS (SELECT 1 FROM ld_tabdetailfield WHERE tabid=@tabid AND columnname=@columnname and tablename=@tablename and sourcemodule=@sourcemodule);

SET @relatedid = (SELECT tabdetailfieldid FROM ld_tabdetailfield WHERE tabid=@tabid AND columnname=@columnname and sourcemodule=@sourcemodule LIMIT 1);
INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
SELECT 'zh',@trantable,@tabid,@relatedid,@zh  from dual
WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE languagetype = 'zh' and tabid=@tabid and relateid=@relatedid AND trantable=@trantable);
INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
SELECT 'en',@trantable,@tabid,@relatedid,@en  from dual
WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE languagetype = 'en' and tabid=@tabid and relateid=@relatedid AND trantable=@trantable);
CALL AddColumn(@tablename,@columnname,'decimal','25','');
update ld_tabdetailfield_seq set id = (select max(tabdetailfieldid) from ld_tabdetailfield);
delimiter;

SET @tabdetailfieldid=(SELECT MAX(tabdetailfieldid)+1 FROM ld_tabdetailfield);
set @tabid = (select tabid from ld_tab where `name` = 'CashBill');
SET @columnname = 'total';
SET @trantable='ld_tabdetailfield';
SET @allowhide = 'no';
SET @fieldlabel = '实际收款金额';
SET @zh='实际收款金额';
SET @en='Actual Receipts';
SET @uitype = 'Amount';
SET @typeofdata='N~O~25,6';
SET @bigtype='';
SET @parentbigtype='';
SET @sequence = (SELECT IFNULL(MAX(sequence),1) FROM ld_tabdetailfield where tabid=@tabid);
SET @tablename = 'ld_cashbill2paymentplan';
SET @sourcemodule = 'ServiceContracts';
INSERT INTO ld_tabdetailfield(tabdetailfieldid,columnname,allowhide,fieldlabel,defaultvalue,presence,fieldtype,typeofdata,sequence,tabid,tablename,width,edit_permission,input_type,
fieldid,newline,defaultcolumn,is_checkimportfield,nullfield,referencemodule,datarange,approve_demand,maxrowsshow,bigtype,savedatabase,parentbigtype,sourcemodule)
SELECT @tabdetailfieldid,@columnname,@allowhide,@fieldlabel,NULL,0,@uitype,@typeofdata,@sequence+1,@tabid,@tablename,30,1,0,0,1,1,0,1,NULL,NULL,NULL,0,@bigtype,'yes',@parentbigtype,@sourcemodule from dual
WHERE NOT EXISTS (SELECT 1 FROM ld_tabdetailfield WHERE tabid=@tabid AND columnname=@columnname and tablename=@tablename and sourcemodule=@sourcemodule);

SET @relatedid = (SELECT tabdetailfieldid FROM ld_tabdetailfield WHERE tabid=@tabid AND columnname=@columnname and sourcemodule=@sourcemodule LIMIT 1);
INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
SELECT 'zh',@trantable,@tabid,@relatedid,@zh  from dual
WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE languagetype = 'zh' and tabid=@tabid and relateid=@relatedid AND trantable=@trantable);
INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
SELECT 'en',@trantable,@tabid,@relatedid,@en  from dual
WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE languagetype = 'en' and tabid=@tabid and relateid=@relatedid AND trantable=@trantable);
CALL AddColumn(@tablename,@columnname,'decimal','25','0.000000');
update ld_tabdetailfield_seq set id = (select max(tabdetailfieldid) from ld_tabdetailfield);
delimiter;


SET @producttoolfieldid=(SELECT MAX(producttoolfieldid)+1 FROM ld_producttoolfield);
set @tabid = (select tabid from ld_tab where `name` = 'CashBill');
SET @columnname = 'entitytype';
SET @trantable='ld_producttoolfield';
SET @allowhide = 'no';
SET @fieldlabel = '源单类型';
SET @zh='源单类型';
SET @en='Link To';
SET @uitype = 204;
SET @typeofdata='V~O~100';
SET @bigtype='';
SET @parentbigtype='';
SET @sequence = (SELECT IFNULL(MAX(sequence),1) FROM ld_producttoolfield where tabid=@tabid);
SET @tablename = 'ld_cashbill2paymentplan';
SET @sourcemodule = 'ServiceContracts';
INSERT INTO ld_producttoolfield(producttoolfieldid,columnname,allowhide,fieldlabel,defaultvalue,presence,uitype,typeofdata,sequence,tabid,tablename,width,edit_permission,input_type,
fieldid,newline,defaultcolumn,is_checkimportfield,nullfield,referencemodule,datarange,approve_demand,maxrowsshow,bigtype,savedatabase,parentbigtype,sourcemodule)
SELECT @producttoolfieldid,@columnname,@allowhide,@fieldlabel,NULL,0,@uitype,@typeofdata,@sequence+1,@tabid,@tablename,30,1,0,0,0,1,0,1,'','','',0,@bigtype,'yes',@parentbigtype,@sourcemodule from dual
WHERE NOT EXISTS (SELECT 1 FROM ld_producttoolfield WHERE tabid=@tabid AND columnname=@columnname and tablename=@tablename and sourcemodule=@sourcemodule);

SET @relatedid = (SELECT producttoolfieldid FROM ld_producttoolfield WHERE tabid=@tabid AND columnname=@columnname and sourcemodule=@sourcemodule LIMIT 1);
INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
SELECT 'zh',@trantable,@tabid,@relatedid,@zh  from dual
WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE languagetype = 'zh' and tabid=@tabid and relateid=@relatedid AND trantable=@trantable);
INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
SELECT 'en',@trantable,@tabid,@relatedid,@en  from dual
WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE languagetype = 'en' and tabid=@tabid and relateid=@relatedid AND trantable=@trantable);
CALL AddColumn(@tablename,@columnname,'varchar',25,'');
update ld_producttoolfield_seq set id = (select max(producttoolfieldid) from ld_producttoolfield);
delimiter;



SET @producttoolfieldid=(SELECT MAX(producttoolfieldid)+1 FROM ld_producttoolfield);
set @tabid = (select tabid from ld_tab where `name` = 'CashBill');
SET @columnname = 'entitytypeid';
SET @trantable='ld_producttoolfield';
SET @allowhide = 'no';
SET @fieldlabel = '源单';
SET @zh='源单';
SET @en='Orignal Bill';
SET @uitype = 202;
SET @typeofdata='V~O~100';
SET @bigtype='selectsource';
SET @parentbigtype='';
SET @sequence = (SELECT IFNULL(MAX(sequence),1) FROM ld_producttoolfield where tabid=@tabid);
SET @tablename = 'ld_cashbill2paymentplan';
SET @sourcemodule = 'ServiceContracts';
INSERT INTO ld_producttoolfield(producttoolfieldid,columnname,allowhide,fieldlabel,defaultvalue,presence,uitype,typeofdata,sequence,tabid,tablename,width,edit_permission,input_type,
fieldid,newline,defaultcolumn,is_checkimportfield,nullfield,referencemodule,datarange,approve_demand,maxrowsshow,bigtype,savedatabase,parentbigtype,sourcemodule)
SELECT @producttoolfieldid,@columnname,@allowhide,@fieldlabel,NULL,0,@uitype,@typeofdata,@sequence+1,@tabid,@tablename,22,1,0,0,0,1,0,1,'','','',0,@bigtype,'yes',@parentbigtype,@sourcemodule from dual
WHERE NOT EXISTS (SELECT 1 FROM ld_producttoolfield WHERE tabid=@tabid AND columnname=@columnname and tablename=@tablename and sourcemodule=@sourcemodule);

SET @relatedid = (SELECT producttoolfieldid FROM ld_producttoolfield WHERE tabid=@tabid AND columnname=@columnname and sourcemodule=@sourcemodule LIMIT 1);
INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
SELECT 'zh',@trantable,@tabid,@relatedid,@zh  from dual
WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE languagetype = 'zh' and tabid=@tabid and relateid=@relatedid AND trantable=@trantable);
INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
SELECT 'en',@trantable,@tabid,@relatedid,@en  from dual
WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE languagetype = 'en' and tabid=@tabid and relateid=@relatedid AND trantable=@trantable);
CALL AddColumn(@tablename,@columnname,'int',11,'');
update ld_producttoolfield_seq set id = (select max(producttoolfieldid) from ld_producttoolfield);
delimiter;


SET @producttoolfieldid=(SELECT MAX(producttoolfieldid)+1 FROM ld_producttoolfield);
set @tabid = (select tabid from ld_tab where `name` = 'CashBill');
SET @columnname = 'productname';
SET @trantable='ld_producttoolfield';
SET @allowhide = 'no';
SET @fieldlabel = '产品名称';
SET @zh='产品名称';
SET @en='Product Name';
SET @uitype = 70;
SET @typeofdata='V~M~100';
SET @bigtype='selectsource';
SET @parentbigtype='';
SET @sequence = (SELECT IFNULL(MAX(sequence),1) FROM ld_producttoolfield where tabid=@tabid);
SET @tablename = 'ld_products';
SET @sourcemodule = 'ServiceContracts';
SET @producttabid = (select tabid from ld_tab where `name`='Products');
set @fieldid=(select fieldid from ld_field where tabid = @producttabid and fieldname = 'productname');
INSERT INTO ld_producttoolfield(producttoolfieldid,columnname,allowhide,fieldlabel,defaultvalue,presence,uitype,typeofdata,sequence,tabid,tablename,width,edit_permission,input_type,
fieldid,newline,defaultcolumn,is_checkimportfield,nullfield,referencemodule,datarange,approve_demand,maxrowsshow,bigtype,savedatabase,parentbigtype,sourcemodule)
SELECT @producttoolfieldid,@columnname,@allowhide,@fieldlabel,NULL,0,@uitype,@typeofdata,@sequence+1,@tabid,@tablename,45,0,0,@fieldid,0,2,0,0,'','','',0,@bigtype,'yes',@parentbigtype,@sourcemodule from dual
WHERE NOT EXISTS (SELECT 1 FROM ld_producttoolfield WHERE tabid=@tabid AND columnname=@columnname and tablename=@tablename and sourcemodule=@sourcemodule);

SET @relatedid = (SELECT producttoolfieldid FROM ld_producttoolfield WHERE tabid=@tabid AND columnname=@columnname and sourcemodule=@sourcemodule LIMIT 1);
INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
SELECT 'zh',@trantable,@tabid,@relatedid,@zh  from dual
WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE languagetype = 'zh' and tabid=@tabid and relateid=@relatedid AND trantable=@trantable);
INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
SELECT 'en',@trantable,@tabid,@relatedid,@en  from dual
WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE languagetype = 'en' and tabid=@tabid and relateid=@relatedid AND trantable=@trantable);
CALL AddColumn('ld_cashbill2paymentplan','productid','int',11,'');
update ld_producttoolfield_seq set id = (select max(producttoolfieldid) from ld_producttoolfield);
delimiter;

SET @producttoolfieldid=(SELECT MAX(producttoolfieldid)+1 FROM ld_producttoolfield);
set @tabid = (select tabid from ld_tab where `name` = 'CashBill');
SET @columnname = 'product_no';
SET @trantable='ld_producttoolfield';
SET @allowhide = 'yes';
SET @fieldlabel = '产品编号';
SET @zh='产品编号';
SET @en='Product No';
SET @uitype = 4;
SET @typeofdata='V~O';
SET @bigtype='';
SET @parentbigtype='';
SET @sequence = (SELECT IFNULL(MAX(sequence),1) FROM ld_producttoolfield where tabid=@tabid);
SET @tablename = 'ld_products';
SET @sourcemodule = 'ServiceContracts';
SET @producttabid = (select tabid from ld_tab where `name`='Products');
SET @fieldid = (SELECT fieldid FROM ld_field where tabid=@producttabid and columnname = 'product_no');
INSERT INTO ld_producttoolfield(producttoolfieldid,columnname,allowhide,fieldlabel,defaultvalue,presence,uitype,typeofdata,sequence,tabid,tablename,width,edit_permission,input_type,
fieldid,newline,defaultcolumn,is_checkimportfield,nullfield,referencemodule,datarange,approve_demand,maxrowsshow,bigtype,savedatabase,parentbigtype,sourcemodule)
SELECT @producttoolfieldid,@columnname,@allowhide,@fieldlabel,NULL,0,@uitype,@typeofdata,@sequence+1,@tabid,@tablename,22,1,1,@fieldid,0,1,0,1,'','','',0,@bigtype,'yes',@parentbigtype,@sourcemodule from dual
WHERE NOT EXISTS (SELECT 1 FROM ld_producttoolfield WHERE tabid=@tabid AND columnname=@columnname and tablename=@tablename and sourcemodule=@sourcemodule);

SET @relatedid = (SELECT producttoolfieldid FROM ld_producttoolfield WHERE tabid=@tabid AND columnname=@columnname and sourcemodule=@sourcemodule LIMIT 1);
INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
SELECT 'zh',@trantable,@tabid,@relatedid,@zh  from dual
WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE languagetype = 'zh' and tabid=@tabid and relateid=@relatedid AND trantable=@trantable);
INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
SELECT 'en',@trantable,@tabid,@relatedid,@en  from dual
WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE languagetype = 'en' and tabid=@tabid and relateid=@relatedid AND trantable=@trantable);

update ld_producttoolfield_seq set id = (select max(producttoolfieldid) from ld_producttoolfield);
delimiter;

SET @producttoolfieldid=(SELECT MAX(producttoolfieldid)+1 FROM ld_producttoolfield);
set @tabid = (select tabid from ld_tab where `name` = 'CashBill');
SET @columnname = 'productsheet';
SET @trantable='ld_producttoolfield';
SET @allowhide = 'yes';
SET @fieldlabel = '规格型号';
SET @zh='规格型号';
SET @en='Specification';
SET @uitype = 1;
SET @typeofdata='V~O';
SET @bigtype='';
SET @parentbigtype='';
SET @sequence = (SELECT IFNULL(MAX(sequence),1) FROM ld_producttoolfield where tabid=@tabid);
SET @tablename = 'ld_products';
SET @sourcemodule = 'ServiceContracts';
SET @producttabid = (select tabid from ld_tab where `name`='Products');
SET @fieldid = (SELECT fieldid FROM ld_field where tabid=@producttabid and columnname = 'productsheet');
INSERT INTO ld_producttoolfield(producttoolfieldid,columnname,allowhide,fieldlabel,defaultvalue,presence,uitype,typeofdata,sequence,tabid,tablename,width,edit_permission,input_type,
fieldid,newline,defaultcolumn,is_checkimportfield,nullfield,referencemodule,datarange,approve_demand,maxrowsshow,bigtype,savedatabase,parentbigtype,sourcemodule)
SELECT @producttoolfieldid,@columnname,@allowhide,@fieldlabel,NULL,0,@uitype,@typeofdata,@sequence+1,@tabid,@tablename,22,1,1,@fieldid,0,1,0,1,'','','',0,@bigtype,'yes',@parentbigtype,@sourcemodule from dual
WHERE NOT EXISTS (SELECT 1 FROM ld_producttoolfield WHERE tabid=@tabid AND columnname=@columnname and tablename=@tablename and sourcemodule=@sourcemodule);

SET @relatedid = (SELECT producttoolfieldid FROM ld_producttoolfield WHERE tabid=@tabid AND columnname=@columnname and sourcemodule=@sourcemodule LIMIT 1);
INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
SELECT 'zh',@trantable,@tabid,@relatedid,@zh  from dual
WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE languagetype = 'zh' and tabid=@tabid and relateid=@relatedid AND trantable=@trantable);
INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
SELECT 'en',@trantable,@tabid,@relatedid,@en  from dual
WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE languagetype = 'en' and tabid=@tabid and relateid=@relatedid AND trantable=@trantable);

update ld_producttoolfield_seq set id = (select max(producttoolfieldid) from ld_producttoolfield);
delimiter;



SET @producttoolfieldid=(SELECT MAX(producttoolfieldid)+1 FROM ld_producttoolfield);
set @tabid = (select tabid from ld_tab where `name` = 'CashBill');
SET @columnname = 'productsourcetype';
SET @trantable='ld_producttoolfield';
SET @allowhide = 'yes';
SET @fieldlabel = '产品源单类型';
SET @zh='产品源单类型';
SET @en='Source Type';
SET @uitype = 221;
SET @typeofdata='V~O';
SET @bigtype='relatedmodulefield';
SET @parentbigtype='entitytype';
SET @sequence = (SELECT IFNULL(MAX(sequence),1) FROM ld_producttoolfield where tabid=@tabid);
SET @tablename = 'ld_cashbill2paymentplan';
SET @sourcemodule = 'ServiceContracts';
INSERT INTO ld_producttoolfield(producttoolfieldid,columnname,allowhide,fieldlabel,defaultvalue,presence,uitype,typeofdata,sequence,tabid,tablename,width,edit_permission,input_type,
fieldid,newline,defaultcolumn,is_checkimportfield,nullfield,referencemodule,datarange,approve_demand,maxrowsshow,bigtype,savedatabase,parentbigtype,sourcemodule)
SELECT @producttoolfieldid,@columnname,@allowhide,@fieldlabel,NULL,0,@uitype,@typeofdata,@sequence+1,@tabid,@tablename,22,1,0,0,0,1,0,1,'','','',0,@bigtype,'no',@parentbigtype,@sourcemodule from dual
WHERE NOT EXISTS (SELECT 1 FROM ld_producttoolfield WHERE tabid=@tabid AND columnname=@columnname and tablename=@tablename and sourcemodule=@sourcemodule);

SET @relatedid = (SELECT producttoolfieldid FROM ld_producttoolfield WHERE tabid=@tabid AND columnname=@columnname and sourcemodule=@sourcemodule LIMIT 1);
INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
SELECT 'zh',@trantable,@tabid,@relatedid,@zh  from dual
WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE languagetype = 'zh' and tabid=@tabid and relateid=@relatedid AND trantable=@trantable);
INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
SELECT 'en',@trantable,@tabid,@relatedid,@en  from dual
WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE languagetype = 'en' and tabid=@tabid and relateid=@relatedid AND trantable=@trantable);
CALL AddColumn('ld_cashbill2paymentplan','productsourcetype','varchar',25,'');
update ld_producttoolfield_seq set id = (select max(producttoolfieldid) from ld_producttoolfield);
delimiter;


SET @producttoolfieldid=(SELECT MAX(producttoolfieldid)+1 FROM ld_producttoolfield);
set @tabid = (select tabid from ld_tab where `name` = 'CashBill');
SET @columnname = 'productsourceid';
SET @trantable='ld_producttoolfield';
SET @allowhide = 'yes';
SET @fieldlabel = '产品源单';
SET @zh='产品源单';
SET @en='Source Bill';
SET @uitype = 220;
SET @typeofdata='V~O';
SET @bigtype='relatedmodulefield';
SET @parentbigtype='selectsource';
SET @sequence = (SELECT IFNULL(MAX(sequence),1) FROM ld_producttoolfield where tabid=@tabid);
SET @tablename = 'ld_cashbill2paymentplan';
SET @sourcemodule = 'ServiceContracts';
INSERT INTO ld_producttoolfield(producttoolfieldid,columnname,allowhide,fieldlabel,defaultvalue,presence,uitype,typeofdata,sequence,tabid,tablename,width,edit_permission,input_type,
fieldid,newline,defaultcolumn,is_checkimportfield,nullfield,referencemodule,datarange,approve_demand,maxrowsshow,bigtype,savedatabase,parentbigtype,sourcemodule)
SELECT @producttoolfieldid,@columnname,@allowhide,@fieldlabel,NULL,0,@uitype,@typeofdata,@sequence+1,@tabid,@tablename,30,1,0,0,0,1,0,1,'','','',0,@bigtype,'no',@parentbigtype,@sourcemodule from dual
WHERE NOT EXISTS (SELECT 1 FROM ld_producttoolfield WHERE tabid=@tabid AND columnname=@columnname and tablename=@tablename and sourcemodule=@sourcemodule);

SET @relatedid = (SELECT producttoolfieldid FROM ld_producttoolfield WHERE tabid=@tabid AND columnname=@columnname and sourcemodule=@sourcemodule LIMIT 1);
INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
SELECT 'zh',@trantable,@tabid,@relatedid,@zh  from dual
WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE languagetype = 'zh' and tabid=@tabid and relateid=@relatedid AND trantable=@trantable);
INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
SELECT 'en',@trantable,@tabid,@relatedid,@en  from dual
WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE languagetype = 'en' and tabid=@tabid and relateid=@relatedid AND trantable=@trantable);
CALL AddColumn('ld_cashbill2paymentplan','productsourceid','int',11,'');
update ld_producttoolfield_seq set id = (select max(producttoolfieldid) from ld_producttoolfield);
delimiter;


SET @producttoolfieldid=(SELECT MAX(producttoolfieldid)+1 FROM ld_producttoolfield);
set @tabid = (select tabid from ld_tab where `name` = 'CashBill');
SET @columnname = 'tax_amount';
SET @trantable='ld_producttoolfield';
SET @allowhide = 'yes';
SET @fieldlabel = '价税合计';
SET @zh='价税合计';
SET @en='Tax-inclusive Amount';
SET @uitype = 28;
SET @typeofdata='N~O~25,6';
SET @bigtype='';
SET @parentbigtype='';
SET @sequence = (SELECT IFNULL(MAX(sequence),1) FROM ld_producttoolfield where tabid=@tabid);
SET @tablename = 'ld_cashbill2paymentplan';
SET @sourcemodule = 'ServiceContracts';
INSERT INTO ld_producttoolfield(producttoolfieldid,columnname,allowhide,fieldlabel,defaultvalue,presence,uitype,typeofdata,sequence,tabid,tablename,width,edit_permission,input_type,
fieldid,newline,defaultcolumn,is_checkimportfield,nullfield,referencemodule,datarange,approve_demand,maxrowsshow,bigtype,savedatabase,parentbigtype,sourcemodule)
SELECT @producttoolfieldid,@columnname,@allowhide,@fieldlabel,NULL,0,@uitype,@typeofdata,@sequence+1,@tabid,@tablename,22,1,0,0,0,1,0,1,'','','',0,@bigtype,'yes',@parentbigtype,@sourcemodule from dual
WHERE NOT EXISTS (SELECT 1 FROM ld_producttoolfield WHERE tabid=@tabid AND columnname=@columnname and tablename=@tablename and sourcemodule=@sourcemodule);

SET @relatedid = (SELECT producttoolfieldid FROM ld_producttoolfield WHERE tabid=@tabid AND columnname=@columnname and sourcemodule=@sourcemodule LIMIT 1);
INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
SELECT 'zh',@trantable,@tabid,@relatedid,@zh  from dual
WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE languagetype = 'zh' and tabid=@tabid and relateid=@relatedid AND trantable=@trantable);
INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
SELECT 'en',@trantable,@tabid,@relatedid,@en  from dual
WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE languagetype = 'en' and tabid=@tabid and relateid=@relatedid AND trantable=@trantable);
CALL AddColumn('ld_cashbill2paymentplan','tax_amount','decimal',25,'');
update ld_producttoolfield_seq set id = (select max(producttoolfieldid) from ld_producttoolfield);
delimiter;


SET @producttoolfieldid=(SELECT MAX(producttoolfieldid)+1 FROM ld_producttoolfield);
set @tabid = (select tabid from ld_tab where `name` = 'CashBill');
SET @columnname = 'product_received_amount';
SET @trantable='ld_producttoolfield';
SET @allowhide = 'yes';
SET @fieldlabel = '产品已收总额';
SET @zh='产品已收总额';
SET @en='Received Amount';
SET @uitype = 50;
SET @typeofdata='NN~O~25,3';
SET @bigtype='';
SET @parentbigtype='';
SET @sequence = (SELECT IFNULL(MAX(sequence),1) FROM ld_producttoolfield where tabid=@tabid);
SET @tablename = 'ld_cashbill2paymentplan';
SET @sourcemodule = 'ServiceContracts';
INSERT INTO ld_producttoolfield(producttoolfieldid,columnname,allowhide,fieldlabel,defaultvalue,presence,uitype,typeofdata,sequence,tabid,tablename,width,edit_permission,input_type,
fieldid,newline,defaultcolumn,is_checkimportfield,nullfield,referencemodule,datarange,approve_demand,maxrowsshow,bigtype,savedatabase,parentbigtype,sourcemodule)
SELECT @producttoolfieldid,@columnname,@allowhide,@fieldlabel,NULL,0,@uitype,@typeofdata,@sequence+1,@tabid,@tablename,22,1,0,0,1,1,0,1,'','','',0,@bigtype,'no',@parentbigtype,@sourcemodule from dual
WHERE NOT EXISTS (SELECT 1 FROM ld_producttoolfield WHERE tabid=@tabid AND columnname=@columnname and tablename=@tablename  and sourcemodule=@sourcemodule);

SET @relatedid = (SELECT producttoolfieldid FROM ld_producttoolfield WHERE tabid=@tabid AND columnname=@columnname  and sourcemodule=@sourcemodule LIMIT 1);
INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
SELECT 'zh',@trantable,@tabid,@relatedid,@zh  from dual
WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE languagetype = 'zh' and tabid=@tabid and relateid=@relatedid AND trantable=@trantable);
INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
SELECT 'en',@trantable,@tabid,@relatedid,@en  from dual
WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE languagetype = 'en' and tabid=@tabid and relateid=@relatedid AND trantable=@trantable);
CALL AddColumn('ld_cashbill2paymentplan','product_received_amount','decimal',25,'');
update ld_producttoolfield_seq set id = (select max(producttoolfieldid) from ld_producttoolfield);
delimiter;


SET @producttoolfieldid=(SELECT MAX(producttoolfieldid)+1 FROM ld_producttoolfield);
set @tabid = (select tabid from ld_tab where `name` = 'CashBill');
SET @columnname = 'amount';
SET @trantable='ld_producttoolfield';
SET @allowhide = 'no';
SET @fieldlabel = '本次收款金额';
SET @zh='本次收款金额';
SET @en='The amount collected';
SET @uitype = 50;
SET @typeofdata='NN~O~25,3';
SET @bigtype='';
SET @parentbigtype='';
SET @sequence = (SELECT IFNULL(MAX(sequence),1) FROM ld_producttoolfield where tabid=@tabid);
SET @tablename = 'ld_cashbill2paymentplan';
SET @sourcemodule = 'ServiceContracts';
INSERT INTO ld_producttoolfield(producttoolfieldid,columnname,allowhide,fieldlabel,defaultvalue,presence,uitype,typeofdata,sequence,tabid,tablename,width,edit_permission,input_type,
fieldid,newline,defaultcolumn,is_checkimportfield,nullfield,referencemodule,datarange,approve_demand,maxrowsshow,bigtype,savedatabase,parentbigtype,sourcemodule)
SELECT @producttoolfieldid,@columnname,@allowhide,@fieldlabel,NULL,0,@uitype,@typeofdata,@sequence+1,@tabid,@tablename,35,0,0,0,0,1,0,1,'','','',0,@bigtype,'yes',@parentbigtype,@sourcemodule from dual
WHERE NOT EXISTS (SELECT 1 FROM ld_producttoolfield WHERE tabid=@tabid AND columnname=@columnname and tablename=@tablename  and sourcemodule=@sourcemodule);

SET @relatedid = (SELECT producttoolfieldid FROM ld_producttoolfield WHERE tabid=@tabid AND columnname=@columnname  and sourcemodule=@sourcemodule LIMIT 1);
INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
SELECT 'zh',@trantable,@tabid,@relatedid,@zh  from dual
WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE languagetype = 'zh' and tabid=@tabid and relateid=@relatedid AND trantable=@trantable);
INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
SELECT 'en',@trantable,@tabid,@relatedid,@en  from dual
WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE languagetype = 'en' and tabid=@tabid and relateid=@relatedid AND trantable=@trantable);

update ld_producttoolfield_seq set id = (select max(producttoolfieldid) from ld_producttoolfield);
delimiter;



SET @producttoolfieldid=(SELECT MAX(producttoolfieldid)+1 FROM ld_producttoolfield);
set @tabid = (select tabid from ld_tab where `name` = 'CashBill');
SET @columnname = 'total';
SET @trantable='ld_producttoolfield';
SET @allowhide = 'no';
SET @fieldlabel = '实际收款金额';
SET @zh='实际收款金额';
SET @en='Actual Receipts';
SET @uitype = 50;
SET @typeofdata='NN~O~25,3';
SET @bigtype='';
SET @parentbigtype='';
SET @sequence = (SELECT IFNULL(MAX(sequence),1) FROM ld_producttoolfield where tabid=@tabid);
SET @tablename = 'ld_cashbill2paymentplan';
SET @sourcemodule = 'ServiceContracts';
INSERT INTO ld_producttoolfield(producttoolfieldid,columnname,allowhide,fieldlabel,defaultvalue,presence,uitype,typeofdata,sequence,tabid,tablename,width,edit_permission,input_type,
fieldid,newline,defaultcolumn,is_checkimportfield,nullfield,referencemodule,datarange,approve_demand,maxrowsshow,bigtype,savedatabase,parentbigtype,sourcemodule)
SELECT @producttoolfieldid,@columnname,@allowhide,@fieldlabel,NULL,0,@uitype,@typeofdata,@sequence+1,@tabid,@tablename,35,1,0,0,1,1,0,1,'','','',0,@bigtype,'yes',@parentbigtype,@sourcemodule from dual
WHERE NOT EXISTS (SELECT 1 FROM ld_producttoolfield WHERE tabid=@tabid AND columnname=@columnname and tablename=@tablename  and sourcemodule=@sourcemodule);

SET @relatedid = (SELECT producttoolfieldid FROM ld_producttoolfield WHERE tabid=@tabid AND columnname=@columnname  and sourcemodule=@sourcemodule LIMIT 1);
INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
SELECT 'zh',@trantable,@tabid,@relatedid,@zh  from dual
WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE languagetype = 'zh' and tabid=@tabid and relateid=@relatedid AND trantable=@trantable);
INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
SELECT 'en',@trantable,@tabid,@relatedid,@en  from dual
WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE languagetype = 'en' and tabid=@tabid and relateid=@relatedid AND trantable=@trantable);

update ld_producttoolfield_seq set id = (select max(producttoolfieldid) from ld_producttoolfield);
delimiter;


set @tabid = (select tabid from ld_tab where `name` = 'CashBill');
update ld_tabdetailfield set columnname='total' where columnname='detail_received_amount' and tabid=@tabid;
update ld_producttoolfield set columnname='total' where columnname='detail_received_amount' and tabid=@tabid;
delimiter;


SET @tabdetailfieldid=(SELECT MAX(tabdetailfieldid)+1 FROM ld_tabdetailfield);
set @tabid = (select tabid from ld_tab where `name` = 'CashBill');
SET @columnname = 'entitytype';
SET @trantable='ld_tabdetailfield';
SET @allowhide = 'no';
SET @fieldlabel = '源单类型';
SET @zh='源单类型';
SET @en='Link To';
SET @uitype = 'entitytype';
SET @typeofdata='V~O';
SET @bigtype='';
SET @parentbigtype='';
SET @sequence = (SELECT IFNULL(MAX(sequence),1) FROM ld_tabdetailfield where tabid=@tabid);
SET @tablename = 'ld_cashbill2paymentplan';
SET @sourcemodule = 'OutboundOrder';
INSERT INTO ld_tabdetailfield(tabdetailfieldid,columnname,allowhide,fieldlabel,defaultvalue,presence,fieldtype,typeofdata,sequence,tabid,tablename,width,edit_permission,input_type,
fieldid,newline,defaultcolumn,is_checkimportfield,nullfield,referencemodule,datarange,approve_demand,maxrowsshow,bigtype,savedatabase,parentbigtype,sourcemodule)
SELECT @tabdetailfieldid,@columnname,@allowhide,@fieldlabel,NULL,0,@uitype,@typeofdata,@sequence+1,@tabid,@tablename,22,1,0,0,0,1,0,1,'','','',0,@bigtype,'yes',@parentbigtype,@sourcemodule from dual
WHERE NOT EXISTS (SELECT 1 FROM ld_tabdetailfield WHERE tabid=@tabid AND columnname=@columnname and tablename=@tablename and sourcemodule=@sourcemodule);

SET @relatedid = (SELECT tabdetailfieldid FROM ld_tabdetailfield WHERE tabid=@tabid AND columnname=@columnname  and sourcemodule=@sourcemodule LIMIT 1);
INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
SELECT 'zh',@trantable,@tabid,@relatedid,@zh  from dual
WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE languagetype = 'zh' and tabid=@tabid and relateid=@relatedid AND trantable=@trantable);
INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
SELECT 'en',@trantable,@tabid,@relatedid,@en  from dual
WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE languagetype = 'en' and tabid=@tabid and relateid=@relatedid AND trantable=@trantable);
CALL AddColumn(@tablename,@columnname,'varchar',25,'');
update ld_tabdetailfield_seq set id = (select max(tabdetailfieldid) from ld_tabdetailfield);
delimiter;

SET @tabdetailfieldid=(SELECT MAX(tabdetailfieldid)+1 FROM ld_tabdetailfield);
set @tabid = (select tabid from ld_tab where `name` = 'CashBill');
SET @columnname = 'entitytypeid';
SET @trantable='ld_tabdetailfield';
SET @allowhide = 'no';
SET @fieldlabel = '源单';
SET @zh='源单';
SET @en='Orignal Bill';
SET @uitype = 'SelectSource';
SET @typeofdata='V~O~100';
SET @bigtype='selectsource';
SET @parentbigtype='';
SET @sequence = (SELECT IFNULL(MAX(sequence),1) FROM ld_tabdetailfield where tabid=@tabid);
SET @tablename = 'ld_cashbill2paymentplan';
SET @sourcemodule = 'OutboundOrder';
INSERT INTO ld_tabdetailfield(tabdetailfieldid,columnname,allowhide,fieldlabel,defaultvalue,presence,fieldtype,typeofdata,sequence,tabid,tablename,width,edit_permission,input_type,
fieldid,newline,defaultcolumn,is_checkimportfield,nullfield,referencemodule,datarange,approve_demand,maxrowsshow,bigtype,savedatabase,parentbigtype,sourcemodule)
SELECT @tabdetailfieldid,@columnname,@allowhide,@fieldlabel,NULL,0,@uitype,@typeofdata,@sequence+1,@tabid,@tablename,22,1,0,0,0,1,0,1,NULL,NULL,NULL,0,@bigtype,'yes',@parentbigtype,@sourcemodule from dual
WHERE NOT EXISTS (SELECT 1 FROM ld_tabdetailfield WHERE tabid=@tabid AND columnname=@columnname and tablename=@tablename and sourcemodule=@sourcemodule);

SET @relatedid = (SELECT tabdetailfieldid FROM ld_tabdetailfield WHERE tabid=@tabid AND columnname=@columnname and sourcemodule=@sourcemodule LIMIT 1);
INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
SELECT 'zh',@trantable,@tabid,@relatedid,@zh  from dual
WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE languagetype = 'zh' and tabid=@tabid and relateid=@relatedid AND trantable=@trantable);
INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
SELECT 'en',@trantable,@tabid,@relatedid,@en  from dual
WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE languagetype = 'en' and tabid=@tabid and relateid=@relatedid AND trantable=@trantable);
CALL AddColumn(@tablename,@columnname,'int',11,'');
update ld_tabdetailfield_seq set id = (select max(tabdetailfieldid) from ld_tabdetailfield);
delimiter;

SET @tabdetailfieldid=(SELECT MAX(tabdetailfieldid)+1 FROM ld_tabdetailfield);
set @tabid = (select tabid from ld_tab where `name` = 'CashBill');
SET @columnname = 'tablesourcetype';
SET @trantable='ld_tabdetailfield';
SET @allowhide = 'yes';
SET @fieldlabel = '源单源单类型';
SET @zh='源单源单类型';
SET @en='Source Type';
SET @uitype = 'entitytype';
SET @typeofdata='V~O';
SET @bigtype='relatedmodulefield';
SET @parentbigtype='entitytype';
SET @sequence = (SELECT IFNULL(MAX(sequence),1) FROM ld_tabdetailfield where tabid=@tabid);
SET @tablename = 'ld_cashbill2paymentplan';
SET @sourcemodule = 'OutboundOrder';
INSERT INTO ld_tabdetailfield(tabdetailfieldid,columnname,allowhide,fieldlabel,defaultvalue,presence,fieldtype,typeofdata,sequence,tabid,tablename,width,edit_permission,input_type,
fieldid,newline,defaultcolumn,is_checkimportfield,nullfield,referencemodule,datarange,approve_demand,maxrowsshow,bigtype,savedatabase,parentbigtype,sourcemodule)
SELECT @tabdetailfieldid,@columnname,@allowhide,@fieldlabel,NULL,0,@uitype,@typeofdata,@sequence+1,@tabid,@tablename,22,1,0,0,0,1,0,1,NULL,NULL,NULL,0,@bigtype,'no',@parentbigtype,@sourcemodule from dual
WHERE NOT EXISTS (SELECT 1 FROM ld_tabdetailfield WHERE tabid=@tabid AND columnname=@columnname and tablename=@tablename and sourcemodule=@sourcemodule);

SET @relatedid = (SELECT tabdetailfieldid FROM ld_tabdetailfield WHERE tabid=@tabid AND columnname=@columnname and sourcemodule=@sourcemodule LIMIT 1);
INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
SELECT 'zh',@trantable,@tabid,@relatedid,@zh  from dual
WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE languagetype = 'zh' and tabid=@tabid and relateid=@relatedid AND trantable=@trantable);
INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
SELECT 'en',@trantable,@tabid,@relatedid,@en  from dual
WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE languagetype = 'en' and tabid=@tabid and relateid=@relatedid AND trantable=@trantable);
CALL AddColumn(@tablename,@columnname,'varchar',25,'');
update ld_tabdetailfield_seq set id = (select max(tabdetailfieldid) from ld_tabdetailfield);
delimiter;

SET @tabdetailfieldid=(SELECT MAX(tabdetailfieldid)+1 FROM ld_tabdetailfield);
set @tabid = (select tabid from ld_tab where `name` = 'CashBill');
SET @columnname = 'tablesourceid';
SET @trantable='ld_tabdetailfield';
SET @allowhide = 'yes';
SET @fieldlabel = '源单源单';
SET @zh='源单源单';
SET @en='Source Bill';
SET @uitype = 'SelectSource';
SET @typeofdata='V~O';
SET @bigtype='relatedmodulefield';
SET @parentbigtype='selectsource';
SET @sequence = (SELECT IFNULL(MAX(sequence),1) FROM ld_tabdetailfield where tabid=@tabid);
SET @tablename = 'ld_cashbill2paymentplan';
SET @sourcemodule = 'OutboundOrder';
INSERT INTO ld_tabdetailfield(tabdetailfieldid,columnname,allowhide,fieldlabel,defaultvalue,presence,fieldtype,typeofdata,sequence,tabid,tablename,width,edit_permission,input_type,
fieldid,newline,defaultcolumn,is_checkimportfield,nullfield,referencemodule,datarange,approve_demand,maxrowsshow,bigtype,savedatabase,parentbigtype,sourcemodule)
SELECT @tabdetailfieldid,@columnname,@allowhide,@fieldlabel,NULL,0,@uitype,@typeofdata,@sequence+1,@tabid,@tablename,22,1,0,0,0,1,0,1,NULL,NULL,NULL,0,@bigtype,'no',@parentbigtype,@sourcemodule from dual
WHERE NOT EXISTS (SELECT 1 FROM ld_tabdetailfield WHERE tabid=@tabid AND columnname=@columnname and tablename=@tablename and sourcemodule=@sourcemodule);

SET @relatedid = (SELECT tabdetailfieldid FROM ld_tabdetailfield WHERE tabid=@tabid AND columnname=@columnname and sourcemodule=@sourcemodule LIMIT 1);
INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
SELECT 'zh',@trantable,@tabid,@relatedid,@zh  from dual
WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE languagetype = 'zh' and tabid=@tabid and relateid=@relatedid AND trantable=@trantable);
INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
SELECT 'en',@trantable,@tabid,@relatedid,@en  from dual
WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE languagetype = 'en' and tabid=@tabid and relateid=@relatedid AND trantable=@trantable);
CALL AddColumn(@tablename,@columnname,'varchar',25,'');
update ld_tabdetailfield_seq set id = (select max(tabdetailfieldid) from ld_tabdetailfield);
delimiter;

SET @tabdetailfieldid=(SELECT MAX(tabdetailfieldid)+1 FROM ld_tabdetailfield);
set @tabid = (select tabid from ld_tab where `name` = 'CashBill');
SET @columnname = 'billdate';
SET @trantable='ld_tabdetailfield';
SET @allowhide = 'yes';
SET @fieldlabel = '源单日期';
SET @zh='源单日期';
SET @en='Source Date';
SET @uitype = 'Date_Ymd';
SET @typeofdata='D~O';
SET @bigtype='relatedmodulefield';
SET @parentbigtype='date';
SET @sequence = (SELECT IFNULL(MAX(sequence),1) FROM ld_tabdetailfield where tabid=@tabid);
SET @tablename = 'ld_cashbill2paymentplan';
SET @sourcemodule = 'OutboundOrder';
INSERT INTO ld_tabdetailfield(tabdetailfieldid,columnname,allowhide,fieldlabel,defaultvalue,presence,fieldtype,typeofdata,sequence,tabid,tablename,width,edit_permission,input_type,
fieldid,newline,defaultcolumn,is_checkimportfield,nullfield,referencemodule,datarange,approve_demand,maxrowsshow,bigtype,savedatabase,parentbigtype,sourcemodule)
SELECT @tabdetailfieldid,@columnname,@allowhide,@fieldlabel,NULL,0,@uitype,@typeofdata,@sequence+1,@tabid,@tablename,30,1,0,0,0,1,0,1,NULL,NULL,NULL,0,@bigtype,'no',@parentbigtype,@sourcemodule from dual
WHERE NOT EXISTS (SELECT 1 FROM ld_tabdetailfield WHERE tabid=@tabid AND columnname=@columnname and tablename=@tablename and sourcemodule=@sourcemodule);

SET @relatedid = (SELECT tabdetailfieldid FROM ld_tabdetailfield WHERE tabid=@tabid AND columnname=@columnname and sourcemodule=@sourcemodule LIMIT 1);
INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
SELECT 'zh',@trantable,@tabid,@relatedid,@zh  from dual
WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE languagetype = 'zh' and tabid=@tabid and relateid=@relatedid AND trantable=@trantable);
INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
SELECT 'en',@trantable,@tabid,@relatedid,@en  from dual
WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE languagetype = 'en' and tabid=@tabid and relateid=@relatedid AND trantable=@trantable);
CALL AddColumn(@tablename,@columnname,'date','','');
update ld_tabdetailfield_seq set id = (select max(tabdetailfieldid) from ld_tabdetailfield);
delimiter;


SET @tabdetailfieldid=(SELECT MAX(tabdetailfieldid)+1 FROM ld_tabdetailfield);
set @tabid = (select tabid from ld_tab where `name` = 'CashBill');
SET @columnname = 'source_total';
SET @trantable='ld_tabdetailfield';
SET @allowhide = 'yes';
SET @fieldlabel = '源单金额';
SET @zh='源单金额';
SET @en='Source Amount';
SET @uitype = 'Amount';
SET @typeofdata='N~O~25,6';
SET @bigtype='relatedmodulefield';
SET @parentbigtype='amount';
SET @sequence = (SELECT IFNULL(MAX(sequence),1) FROM ld_tabdetailfield where tabid=@tabid);
SET @tablename = 'ld_cashbill2paymentplan';
SET @sourcemodule = 'OutboundOrder';
INSERT INTO ld_tabdetailfield(tabdetailfieldid,columnname,allowhide,fieldlabel,defaultvalue,presence,fieldtype,typeofdata,sequence,tabid,tablename,width,edit_permission,input_type,
fieldid,newline,defaultcolumn,is_checkimportfield,nullfield,referencemodule,datarange,approve_demand,maxrowsshow,bigtype,savedatabase,parentbigtype,sourcemodule)
SELECT @tabdetailfieldid,@columnname,@allowhide,@fieldlabel,NULL,0,@uitype,@typeofdata,@sequence+1,@tabid,@tablename,30,1,0,0,0,1,0,1,NULL,NULL,NULL,0,@bigtype,'no',@parentbigtype,@sourcemodule from dual
WHERE NOT EXISTS (SELECT 1 FROM ld_tabdetailfield WHERE tabid=@tabid AND columnname=@columnname and tablename=@tablename and sourcemodule=@sourcemodule);

SET @relatedid = (SELECT tabdetailfieldid FROM ld_tabdetailfield WHERE tabid=@tabid AND columnname=@columnname and sourcemodule=@sourcemodule LIMIT 1);
INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
SELECT 'zh',@trantable,@tabid,@relatedid,@zh  from dual
WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE languagetype = 'zh' and tabid=@tabid and relateid=@relatedid AND trantable=@trantable);
INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
SELECT 'en',@trantable,@tabid,@relatedid,@en  from dual
WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE languagetype = 'en' and tabid=@tabid and relateid=@relatedid AND trantable=@trantable);
CALL AddColumn(@tablename,@columnname,'decimal','25','0.000000');
update ld_tabdetailfield_seq set id = (select max(tabdetailfieldid) from ld_tabdetailfield);
delimiter;


SET @tabdetailfieldid=(SELECT MAX(tabdetailfieldid)+1 FROM ld_tabdetailfield);
set @tabid = (select tabid from ld_tab where `name` = 'CashBill');
SET @columnname = 'received_amount';
SET @trantable='ld_tabdetailfield';
SET @allowhide = 'yes';
SET @fieldlabel = '源单已收总额';
SET @zh='源单已收总额';
SET @en='Received Amount';
SET @uitype = 'Amount';
SET @typeofdata='N~O~25,6';
SET @bigtype='relatedmodulefield';
SET @parentbigtype='amount';
SET @sequence = (SELECT IFNULL(MAX(sequence),1) FROM ld_tabdetailfield where tabid=@tabid);
SET @tablename = 'ld_cashbill2paymentplan';
SET @sourcemodule = 'OutboundOrder';
INSERT INTO ld_tabdetailfield(tabdetailfieldid,columnname,allowhide,fieldlabel,defaultvalue,presence,fieldtype,typeofdata,sequence,tabid,tablename,width,edit_permission,input_type,
fieldid,newline,defaultcolumn,is_checkimportfield,nullfield,referencemodule,datarange,approve_demand,maxrowsshow,bigtype,savedatabase,parentbigtype,sourcemodule)
SELECT @tabdetailfieldid,@columnname,@allowhide,@fieldlabel,NULL,0,@uitype,@typeofdata,@sequence+1,@tabid,@tablename,30,1,0,0,0,1,0,1,NULL,NULL,NULL,0,@bigtype,'no',@parentbigtype,@sourcemodule from dual
WHERE NOT EXISTS (SELECT 1 FROM ld_tabdetailfield WHERE tabid=@tabid AND columnname=@columnname and tablename=@tablename and sourcemodule=@sourcemodule);

SET @relatedid = (SELECT tabdetailfieldid FROM ld_tabdetailfield WHERE tabid=@tabid AND columnname=@columnname and sourcemodule=@sourcemodule LIMIT 1);
INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
SELECT 'zh',@trantable,@tabid,@relatedid,@zh  from dual
WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE languagetype = 'zh' and tabid=@tabid and relateid=@relatedid AND trantable=@trantable);
INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
SELECT 'en',@trantable,@tabid,@relatedid,@en  from dual
WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE languagetype = 'en' and tabid=@tabid and relateid=@relatedid AND trantable=@trantable);
CALL AddColumn(@tablename,@columnname,'decimal','25','0.000000');
update ld_tabdetailfield_seq set id = (select max(tabdetailfieldid) from ld_tabdetailfield);
delimiter;

SET @tabdetailfieldid=(SELECT MAX(tabdetailfieldid)+1 FROM ld_tabdetailfield);
set @tabid = (select tabid from ld_tab where `name` = 'CashBill');
SET @columnname = 'amount';
SET @trantable='ld_tabdetailfield';
SET @allowhide = 'no';
SET @fieldlabel = '本次收款金额';
SET @zh='本次收款金额';
SET @en='Received Amount';
SET @uitype = 'Amount';
SET @typeofdata='N~O~25,6';
SET @bigtype='amount';
SET @parentbigtype='';
SET @sequence = (SELECT IFNULL(MAX(sequence),1) FROM ld_tabdetailfield where tabid=@tabid);
SET @tablename = 'ld_cashbill2paymentplan';
SET @sourcemodule = 'OutboundOrder';
INSERT INTO ld_tabdetailfield(tabdetailfieldid,columnname,allowhide,fieldlabel,defaultvalue,presence,fieldtype,typeofdata,sequence,tabid,tablename,width,edit_permission,input_type,
fieldid,newline,defaultcolumn,is_checkimportfield,nullfield,referencemodule,datarange,approve_demand,maxrowsshow,bigtype,savedatabase,parentbigtype,sourcemodule)
SELECT @tabdetailfieldid,@columnname,@allowhide,@fieldlabel,NULL,0,@uitype,@typeofdata,@sequence+1,@tabid,@tablename,30,0,0,0,0,1,0,1,NULL,NULL,NULL,0,@bigtype,'yes',@parentbigtype,@sourcemodule from dual
WHERE NOT EXISTS (SELECT 1 FROM ld_tabdetailfield WHERE tabid=@tabid AND columnname=@columnname and tablename=@tablename and sourcemodule=@sourcemodule);

SET @relatedid = (SELECT tabdetailfieldid FROM ld_tabdetailfield WHERE tabid=@tabid AND columnname=@columnname and sourcemodule=@sourcemodule LIMIT 1);
INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
SELECT 'zh',@trantable,@tabid,@relatedid,@zh  from dual
WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE languagetype = 'zh' and tabid=@tabid and relateid=@relatedid AND trantable=@trantable);
INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
SELECT 'en',@trantable,@tabid,@relatedid,@en  from dual
WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE languagetype = 'en' and tabid=@tabid and relateid=@relatedid AND trantable=@trantable);
CALL AddColumn(@tablename,@columnname,'decimal','25','0.00');
update ld_tabdetailfield_seq set id = (select max(tabdetailfieldid) from ld_tabdetailfield);
delimiter;

SET @tabdetailfieldid=(SELECT MAX(tabdetailfieldid)+1 FROM ld_tabdetailfield);
set @tabid = (select tabid from ld_tab where `name` = 'CashBill');
SET @columnname = 'total';
SET @trantable='ld_tabdetailfield';
SET @allowhide = 'no';
SET @fieldlabel = '实际收款金额';
SET @zh='实际收款金额';
SET @en='Actual Receipts';
SET @uitype = 'Amount';
SET @typeofdata='N~O~25,6';
SET @bigtype='';
SET @parentbigtype='';
SET @sequence = (SELECT IFNULL(MAX(sequence),1) FROM ld_tabdetailfield where tabid=@tabid);
SET @tablename = 'ld_cashbill2paymentplan';
SET @sourcemodule = 'OutboundOrder';
INSERT INTO ld_tabdetailfield(tabdetailfieldid,columnname,allowhide,fieldlabel,defaultvalue,presence,fieldtype,typeofdata,sequence,tabid,tablename,width,edit_permission,input_type,
fieldid,newline,defaultcolumn,is_checkimportfield,nullfield,referencemodule,datarange,approve_demand,maxrowsshow,bigtype,savedatabase,parentbigtype,sourcemodule)
SELECT @tabdetailfieldid,@columnname,@allowhide,@fieldlabel,NULL,0,@uitype,@typeofdata,@sequence+1,@tabid,@tablename,30,1,0,0,1,1,0,1,NULL,NULL,NULL,0,@bigtype,'yes',@parentbigtype,@sourcemodule from dual
WHERE NOT EXISTS (SELECT 1 FROM ld_tabdetailfield WHERE tabid=@tabid AND columnname=@columnname and tablename=@tablename and sourcemodule=@sourcemodule);

SET @relatedid = (SELECT tabdetailfieldid FROM ld_tabdetailfield WHERE tabid=@tabid AND columnname=@columnname and sourcemodule=@sourcemodule LIMIT 1);
INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
SELECT 'zh',@trantable,@tabid,@relatedid,@zh  from dual
WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE languagetype = 'zh' and tabid=@tabid and relateid=@relatedid AND trantable=@trantable);
INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
SELECT 'en',@trantable,@tabid,@relatedid,@en  from dual
WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE languagetype = 'en' and tabid=@tabid and relateid=@relatedid AND trantable=@trantable);
CALL AddColumn(@tablename,@columnname,'decimal','25','0.000000');
update ld_tabdetailfield_seq set id = (select max(tabdetailfieldid) from ld_tabdetailfield);
delimiter;


SET @producttoolfieldid=(SELECT MAX(producttoolfieldid)+1 FROM ld_producttoolfield);
set @tabid = (select tabid from ld_tab where `name` = 'CashBill');
SET @columnname = 'entitytype';
SET @trantable='ld_producttoolfield';
SET @allowhide = 'no';
SET @fieldlabel = '源单类型';
SET @zh='源单类型';
SET @en='Link To';
SET @uitype = 204;
SET @typeofdata='V~O~100';
SET @bigtype='';
SET @parentbigtype='';
SET @sequence = (SELECT IFNULL(MAX(sequence),1) FROM ld_producttoolfield where tabid=@tabid);
SET @tablename = 'ld_cashbill2paymentplan';
SET @sourcemodule = 'OutboundOrder';
INSERT INTO ld_producttoolfield(producttoolfieldid,columnname,allowhide,fieldlabel,defaultvalue,presence,uitype,typeofdata,sequence,tabid,tablename,width,edit_permission,input_type,
fieldid,newline,defaultcolumn,is_checkimportfield,nullfield,referencemodule,datarange,approve_demand,maxrowsshow,bigtype,savedatabase,parentbigtype,sourcemodule)
SELECT @producttoolfieldid,@columnname,@allowhide,@fieldlabel,NULL,0,@uitype,@typeofdata,@sequence+1,@tabid,@tablename,30,1,0,0,0,1,0,1,'','','',0,@bigtype,'yes',@parentbigtype,@sourcemodule from dual
WHERE NOT EXISTS (SELECT 1 FROM ld_producttoolfield WHERE tabid=@tabid AND columnname=@columnname and tablename=@tablename and sourcemodule=@sourcemodule);

SET @relatedid = (SELECT producttoolfieldid FROM ld_producttoolfield WHERE tabid=@tabid AND columnname=@columnname and sourcemodule=@sourcemodule LIMIT 1);
INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
SELECT 'zh',@trantable,@tabid,@relatedid,@zh  from dual
WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE languagetype = 'zh' and tabid=@tabid and relateid=@relatedid AND trantable=@trantable);
INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
SELECT 'en',@trantable,@tabid,@relatedid,@en  from dual
WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE languagetype = 'en' and tabid=@tabid and relateid=@relatedid AND trantable=@trantable);
CALL AddColumn(@tablename,@columnname,'varchar',25,'');
update ld_producttoolfield_seq set id = (select max(producttoolfieldid) from ld_producttoolfield);
delimiter;



SET @producttoolfieldid=(SELECT MAX(producttoolfieldid)+1 FROM ld_producttoolfield);
set @tabid = (select tabid from ld_tab where `name` = 'CashBill');
SET @columnname = 'entitytypeid';
SET @trantable='ld_producttoolfield';
SET @allowhide = 'no';
SET @fieldlabel = '源单';
SET @zh='源单';
SET @en='Orignal Bill';
SET @uitype = 202;
SET @typeofdata='V~O~100';
SET @bigtype='selectsource';
SET @parentbigtype='';
SET @sequence = (SELECT IFNULL(MAX(sequence),1) FROM ld_producttoolfield where tabid=@tabid);
SET @tablename = 'ld_cashbill2paymentplan';
SET @sourcemodule = 'OutboundOrder';
INSERT INTO ld_producttoolfield(producttoolfieldid,columnname,allowhide,fieldlabel,defaultvalue,presence,uitype,typeofdata,sequence,tabid,tablename,width,edit_permission,input_type,
fieldid,newline,defaultcolumn,is_checkimportfield,nullfield,referencemodule,datarange,approve_demand,maxrowsshow,bigtype,savedatabase,parentbigtype,sourcemodule)
SELECT @producttoolfieldid,@columnname,@allowhide,@fieldlabel,NULL,0,@uitype,@typeofdata,@sequence+1,@tabid,@tablename,22,1,0,0,0,1,0,1,'','','',0,@bigtype,'yes',@parentbigtype,@sourcemodule from dual
WHERE NOT EXISTS (SELECT 1 FROM ld_producttoolfield WHERE tabid=@tabid AND columnname=@columnname and tablename=@tablename and sourcemodule=@sourcemodule);

SET @relatedid = (SELECT producttoolfieldid FROM ld_producttoolfield WHERE tabid=@tabid AND columnname=@columnname and sourcemodule=@sourcemodule LIMIT 1);
INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
SELECT 'zh',@trantable,@tabid,@relatedid,@zh  from dual
WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE languagetype = 'zh' and tabid=@tabid and relateid=@relatedid AND trantable=@trantable);
INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
SELECT 'en',@trantable,@tabid,@relatedid,@en  from dual
WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE languagetype = 'en' and tabid=@tabid and relateid=@relatedid AND trantable=@trantable);
CALL AddColumn(@tablename,@columnname,'int',11,'');
update ld_producttoolfield_seq set id = (select max(producttoolfieldid) from ld_producttoolfield);
delimiter;


SET @producttoolfieldid=(SELECT MAX(producttoolfieldid)+1 FROM ld_producttoolfield);
set @tabid = (select tabid from ld_tab where `name` = 'CashBill');
SET @columnname = 'productname';
SET @trantable='ld_producttoolfield';
SET @allowhide = 'no';
SET @fieldlabel = '产品名称';
SET @zh='产品名称';
SET @en='Product Name';
SET @uitype = 70;
SET @typeofdata='V~M~100';
SET @bigtype='selectsource';
SET @parentbigtype='';
SET @sequence = (SELECT IFNULL(MAX(sequence),1) FROM ld_producttoolfield where tabid=@tabid);
SET @tablename = 'ld_products';
SET @sourcemodule = 'OutboundOrder';
SET @producttabid = (select tabid from ld_tab where `name`='Products');
set @fieldid=(select fieldid from ld_field where tabid = @producttabid and fieldname = 'productname');
INSERT INTO ld_producttoolfield(producttoolfieldid,columnname,allowhide,fieldlabel,defaultvalue,presence,uitype,typeofdata,sequence,tabid,tablename,width,edit_permission,input_type,
fieldid,newline,defaultcolumn,is_checkimportfield,nullfield,referencemodule,datarange,approve_demand,maxrowsshow,bigtype,savedatabase,parentbigtype,sourcemodule)
SELECT @producttoolfieldid,@columnname,@allowhide,@fieldlabel,NULL,0,@uitype,@typeofdata,@sequence+1,@tabid,@tablename,45,0,0,@fieldid,0,2,0,0,'','','',0,@bigtype,'yes',@parentbigtype,@sourcemodule from dual
WHERE NOT EXISTS (SELECT 1 FROM ld_producttoolfield WHERE tabid=@tabid AND columnname=@columnname and tablename=@tablename and sourcemodule=@sourcemodule);

SET @relatedid = (SELECT producttoolfieldid FROM ld_producttoolfield WHERE tabid=@tabid AND columnname=@columnname and sourcemodule=@sourcemodule LIMIT 1);
INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
SELECT 'zh',@trantable,@tabid,@relatedid,@zh  from dual
WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE languagetype = 'zh' and tabid=@tabid and relateid=@relatedid AND trantable=@trantable);
INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
SELECT 'en',@trantable,@tabid,@relatedid,@en  from dual
WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE languagetype = 'en' and tabid=@tabid and relateid=@relatedid AND trantable=@trantable);
CALL AddColumn('ld_cashbill2paymentplan','productid','int',11,'');
update ld_producttoolfield_seq set id = (select max(producttoolfieldid) from ld_producttoolfield);
delimiter;

SET @producttoolfieldid=(SELECT MAX(producttoolfieldid)+1 FROM ld_producttoolfield);
set @tabid = (select tabid from ld_tab where `name` = 'CashBill');
SET @columnname = 'product_no';
SET @trantable='ld_producttoolfield';
SET @allowhide = 'yes';
SET @fieldlabel = '产品编号';
SET @zh='产品编号';
SET @en='Product No';
SET @uitype = 4;
SET @typeofdata='V~O';
SET @bigtype='';
SET @parentbigtype='';
SET @sequence = (SELECT IFNULL(MAX(sequence),1) FROM ld_producttoolfield where tabid=@tabid);
SET @tablename = 'ld_products';
SET @sourcemodule = 'OutboundOrder';
SET @producttabid = (select tabid from ld_tab where `name`='Products');
SET @fieldid = (SELECT fieldid FROM ld_field where tabid=@producttabid and columnname = 'product_no');
INSERT INTO ld_producttoolfield(producttoolfieldid,columnname,allowhide,fieldlabel,defaultvalue,presence,uitype,typeofdata,sequence,tabid,tablename,width,edit_permission,input_type,
fieldid,newline,defaultcolumn,is_checkimportfield,nullfield,referencemodule,datarange,approve_demand,maxrowsshow,bigtype,savedatabase,parentbigtype,sourcemodule)
SELECT @producttoolfieldid,@columnname,@allowhide,@fieldlabel,NULL,0,@uitype,@typeofdata,@sequence+1,@tabid,@tablename,22,1,1,@fieldid,0,1,0,1,'','','',0,@bigtype,'yes',@parentbigtype,@sourcemodule from dual
WHERE NOT EXISTS (SELECT 1 FROM ld_producttoolfield WHERE tabid=@tabid AND columnname=@columnname and tablename=@tablename and sourcemodule=@sourcemodule);

SET @relatedid = (SELECT producttoolfieldid FROM ld_producttoolfield WHERE tabid=@tabid AND columnname=@columnname and sourcemodule=@sourcemodule LIMIT 1);
INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
SELECT 'zh',@trantable,@tabid,@relatedid,@zh  from dual
WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE languagetype = 'zh' and tabid=@tabid and relateid=@relatedid AND trantable=@trantable);
INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
SELECT 'en',@trantable,@tabid,@relatedid,@en  from dual
WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE languagetype = 'en' and tabid=@tabid and relateid=@relatedid AND trantable=@trantable);

update ld_producttoolfield_seq set id = (select max(producttoolfieldid) from ld_producttoolfield);
delimiter;

SET @producttoolfieldid=(SELECT MAX(producttoolfieldid)+1 FROM ld_producttoolfield);
set @tabid = (select tabid from ld_tab where `name` = 'CashBill');
SET @columnname = 'productsheet';
SET @trantable='ld_producttoolfield';
SET @allowhide = 'yes';
SET @fieldlabel = '规格型号';
SET @zh='规格型号';
SET @en='Specification';
SET @uitype = 1;
SET @typeofdata='V~O';
SET @bigtype='';
SET @parentbigtype='';
SET @sequence = (SELECT IFNULL(MAX(sequence),1) FROM ld_producttoolfield where tabid=@tabid);
SET @tablename = 'ld_products';
SET @sourcemodule = 'OutboundOrder';
SET @producttabid = (select tabid from ld_tab where `name`='Products');
SET @fieldid = (SELECT fieldid FROM ld_field where tabid=@producttabid and columnname = 'productsheet');
INSERT INTO ld_producttoolfield(producttoolfieldid,columnname,allowhide,fieldlabel,defaultvalue,presence,uitype,typeofdata,sequence,tabid,tablename,width,edit_permission,input_type,
fieldid,newline,defaultcolumn,is_checkimportfield,nullfield,referencemodule,datarange,approve_demand,maxrowsshow,bigtype,savedatabase,parentbigtype,sourcemodule)
SELECT @producttoolfieldid,@columnname,@allowhide,@fieldlabel,NULL,0,@uitype,@typeofdata,@sequence+1,@tabid,@tablename,22,1,1,@fieldid,0,1,0,1,'','','',0,@bigtype,'yes',@parentbigtype,@sourcemodule from dual
WHERE NOT EXISTS (SELECT 1 FROM ld_producttoolfield WHERE tabid=@tabid AND columnname=@columnname and tablename=@tablename and sourcemodule=@sourcemodule);

SET @relatedid = (SELECT producttoolfieldid FROM ld_producttoolfield WHERE tabid=@tabid AND columnname=@columnname and sourcemodule=@sourcemodule LIMIT 1);
INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
SELECT 'zh',@trantable,@tabid,@relatedid,@zh  from dual
WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE languagetype = 'zh' and tabid=@tabid and relateid=@relatedid AND trantable=@trantable);
INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
SELECT 'en',@trantable,@tabid,@relatedid,@en  from dual
WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE languagetype = 'en' and tabid=@tabid and relateid=@relatedid AND trantable=@trantable);

update ld_producttoolfield_seq set id = (select max(producttoolfieldid) from ld_producttoolfield);
delimiter;



SET @producttoolfieldid=(SELECT MAX(producttoolfieldid)+1 FROM ld_producttoolfield);
set @tabid = (select tabid from ld_tab where `name` = 'CashBill');
SET @columnname = 'productsourcetype';
SET @trantable='ld_producttoolfield';
SET @allowhide = 'yes';
SET @fieldlabel = '产品源单类型';
SET @zh='产品源单类型';
SET @en='Source Type';
SET @uitype = 221;
SET @typeofdata='V~O';
SET @bigtype='relatedmodulefield';
SET @parentbigtype='entitytype';
SET @sequence = (SELECT IFNULL(MAX(sequence),1) FROM ld_producttoolfield where tabid=@tabid);
SET @tablename = 'ld_cashbill2paymentplan';
SET @sourcemodule = 'OutboundOrder';
INSERT INTO ld_producttoolfield(producttoolfieldid,columnname,allowhide,fieldlabel,defaultvalue,presence,uitype,typeofdata,sequence,tabid,tablename,width,edit_permission,input_type,
fieldid,newline,defaultcolumn,is_checkimportfield,nullfield,referencemodule,datarange,approve_demand,maxrowsshow,bigtype,savedatabase,parentbigtype,sourcemodule)
SELECT @producttoolfieldid,@columnname,@allowhide,@fieldlabel,NULL,0,@uitype,@typeofdata,@sequence+1,@tabid,@tablename,22,1,0,0,0,1,0,1,'','','',0,@bigtype,'no',@parentbigtype,@sourcemodule from dual
WHERE NOT EXISTS (SELECT 1 FROM ld_producttoolfield WHERE tabid=@tabid AND columnname=@columnname and tablename=@tablename and sourcemodule=@sourcemodule);

SET @relatedid = (SELECT producttoolfieldid FROM ld_producttoolfield WHERE tabid=@tabid AND columnname=@columnname and sourcemodule=@sourcemodule LIMIT 1);
INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
SELECT 'zh',@trantable,@tabid,@relatedid,@zh  from dual
WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE languagetype = 'zh' and tabid=@tabid and relateid=@relatedid AND trantable=@trantable);
INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
SELECT 'en',@trantable,@tabid,@relatedid,@en  from dual
WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE languagetype = 'en' and tabid=@tabid and relateid=@relatedid AND trantable=@trantable);
CALL AddColumn('ld_cashbill2paymentplan','productsourcetype','varchar',25,'');
update ld_producttoolfield_seq set id = (select max(producttoolfieldid) from ld_producttoolfield);
delimiter;


SET @producttoolfieldid=(SELECT MAX(producttoolfieldid)+1 FROM ld_producttoolfield);
set @tabid = (select tabid from ld_tab where `name` = 'CashBill');
SET @columnname = 'productsourceid';
SET @trantable='ld_producttoolfield';
SET @allowhide = 'yes';
SET @fieldlabel = '产品源单';
SET @zh='产品源单';
SET @en='Source Bill';
SET @uitype = 220;
SET @typeofdata='V~O';
SET @bigtype='relatedmodulefield';
SET @parentbigtype='selectsource';
SET @sequence = (SELECT IFNULL(MAX(sequence),1) FROM ld_producttoolfield where tabid=@tabid);
SET @tablename = 'ld_cashbill2paymentplan';
SET @sourcemodule = 'OutboundOrder';
INSERT INTO ld_producttoolfield(producttoolfieldid,columnname,allowhide,fieldlabel,defaultvalue,presence,uitype,typeofdata,sequence,tabid,tablename,width,edit_permission,input_type,
fieldid,newline,defaultcolumn,is_checkimportfield,nullfield,referencemodule,datarange,approve_demand,maxrowsshow,bigtype,savedatabase,parentbigtype,sourcemodule)
SELECT @producttoolfieldid,@columnname,@allowhide,@fieldlabel,NULL,0,@uitype,@typeofdata,@sequence+1,@tabid,@tablename,30,1,0,0,0,1,0,1,'','','',0,@bigtype,'no',@parentbigtype,@sourcemodule from dual
WHERE NOT EXISTS (SELECT 1 FROM ld_producttoolfield WHERE tabid=@tabid AND columnname=@columnname and tablename=@tablename and sourcemodule=@sourcemodule);

SET @relatedid = (SELECT producttoolfieldid FROM ld_producttoolfield WHERE tabid=@tabid AND columnname=@columnname and sourcemodule=@sourcemodule LIMIT 1);
INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
SELECT 'zh',@trantable,@tabid,@relatedid,@zh  from dual
WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE languagetype = 'zh' and tabid=@tabid and relateid=@relatedid AND trantable=@trantable);
INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
SELECT 'en',@trantable,@tabid,@relatedid,@en  from dual
WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE languagetype = 'en' and tabid=@tabid and relateid=@relatedid AND trantable=@trantable);
CALL AddColumn('ld_cashbill2paymentplan','productsourceid','int',11,'');
update ld_producttoolfield_seq set id = (select max(producttoolfieldid) from ld_producttoolfield);
delimiter;


SET @producttoolfieldid=(SELECT MAX(producttoolfieldid)+1 FROM ld_producttoolfield);
set @tabid = (select tabid from ld_tab where `name` = 'CashBill');
SET @columnname = 'tax_amount';
SET @trantable='ld_producttoolfield';
SET @allowhide = 'yes';
SET @fieldlabel = '价税合计';
SET @zh='价税合计';
SET @en='Tax-inclusive Amount';
SET @uitype = 28;
SET @typeofdata='N~O~25,6';
SET @bigtype='';
SET @parentbigtype='';
SET @sequence = (SELECT IFNULL(MAX(sequence),1) FROM ld_producttoolfield where tabid=@tabid);
SET @tablename = 'ld_cashbill2paymentplan';
SET @sourcemodule = 'OutboundOrder';
INSERT INTO ld_producttoolfield(producttoolfieldid,columnname,allowhide,fieldlabel,defaultvalue,presence,uitype,typeofdata,sequence,tabid,tablename,width,edit_permission,input_type,
fieldid,newline,defaultcolumn,is_checkimportfield,nullfield,referencemodule,datarange,approve_demand,maxrowsshow,bigtype,savedatabase,parentbigtype,sourcemodule)
SELECT @producttoolfieldid,@columnname,@allowhide,@fieldlabel,NULL,0,@uitype,@typeofdata,@sequence+1,@tabid,@tablename,22,1,0,0,0,1,0,1,'','','',0,@bigtype,'yes',@parentbigtype,@sourcemodule from dual
WHERE NOT EXISTS (SELECT 1 FROM ld_producttoolfield WHERE tabid=@tabid AND columnname=@columnname and tablename=@tablename and sourcemodule=@sourcemodule);

SET @relatedid = (SELECT producttoolfieldid FROM ld_producttoolfield WHERE tabid=@tabid AND columnname=@columnname and sourcemodule=@sourcemodule LIMIT 1);
INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
SELECT 'zh',@trantable,@tabid,@relatedid,@zh  from dual
WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE languagetype = 'zh' and tabid=@tabid and relateid=@relatedid AND trantable=@trantable);
INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
SELECT 'en',@trantable,@tabid,@relatedid,@en  from dual
WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE languagetype = 'en' and tabid=@tabid and relateid=@relatedid AND trantable=@trantable);
CALL AddColumn('ld_cashbill2paymentplan','tax_amount','decimal',25,'');
update ld_producttoolfield_seq set id = (select max(producttoolfieldid) from ld_producttoolfield);
delimiter;




SET @producttoolfieldid=(SELECT MAX(producttoolfieldid)+1 FROM ld_producttoolfield);
set @tabid = (select tabid from ld_tab where `name` = 'CashBill');
SET @columnname = 'product_received_amount';
SET @trantable='ld_producttoolfield';
SET @allowhide = 'yes';
SET @fieldlabel = '产品已收总额';
SET @zh='产品已收总额';
SET @en='Received Amount';
SET @uitype = 50;
SET @typeofdata='NN~O~25,3';
SET @bigtype='';
SET @parentbigtype='';
SET @sequence = (SELECT IFNULL(MAX(sequence),1) FROM ld_producttoolfield where tabid=@tabid);
SET @tablename = 'ld_cashbill2paymentplan';
SET @sourcemodule = 'OutboundOrder';
INSERT INTO ld_producttoolfield(producttoolfieldid,columnname,allowhide,fieldlabel,defaultvalue,presence,uitype,typeofdata,sequence,tabid,tablename,width,edit_permission,input_type,
fieldid,newline,defaultcolumn,is_checkimportfield,nullfield,referencemodule,datarange,approve_demand,maxrowsshow,bigtype,savedatabase,parentbigtype,sourcemodule)
SELECT @producttoolfieldid,@columnname,@allowhide,@fieldlabel,NULL,0,@uitype,@typeofdata,@sequence+1,@tabid,@tablename,22,1,0,0,1,1,0,1,'','','',0,@bigtype,'no',@parentbigtype,@sourcemodule from dual
WHERE NOT EXISTS (SELECT 1 FROM ld_producttoolfield WHERE tabid=@tabid AND columnname=@columnname and tablename=@tablename  and sourcemodule=@sourcemodule);

SET @relatedid = (SELECT producttoolfieldid FROM ld_producttoolfield WHERE tabid=@tabid AND columnname=@columnname  and sourcemodule=@sourcemodule LIMIT 1);
INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
SELECT 'zh',@trantable,@tabid,@relatedid,@zh  from dual
WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE languagetype = 'zh' and tabid=@tabid and relateid=@relatedid AND trantable=@trantable);
INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
SELECT 'en',@trantable,@tabid,@relatedid,@en  from dual
WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE languagetype = 'en' and tabid=@tabid and relateid=@relatedid AND trantable=@trantable);
CALL AddColumn('ld_cashbill2paymentplan','product_received_amount','decimal',25,'');
update ld_producttoolfield_seq set id = (select max(producttoolfieldid) from ld_producttoolfield);
delimiter;


SET @producttoolfieldid=(SELECT MAX(producttoolfieldid)+1 FROM ld_producttoolfield);
set @tabid = (select tabid from ld_tab where `name` = 'CashBill');
SET @columnname = 'amount';
SET @trantable='ld_producttoolfield';
SET @allowhide = 'no';
SET @fieldlabel = '本次收款金额';
SET @zh='本次收款金额';
SET @en='The amount collected';
SET @uitype = 50;
SET @typeofdata='NN~O~25,3';
SET @bigtype='';
SET @parentbigtype='';
SET @sequence = (SELECT IFNULL(MAX(sequence),1) FROM ld_producttoolfield where tabid=@tabid);
SET @tablename = 'ld_cashbill2paymentplan';
SET @sourcemodule = 'OutboundOrder';
INSERT INTO ld_producttoolfield(producttoolfieldid,columnname,allowhide,fieldlabel,defaultvalue,presence,uitype,typeofdata,sequence,tabid,tablename,width,edit_permission,input_type,
fieldid,newline,defaultcolumn,is_checkimportfield,nullfield,referencemodule,datarange,approve_demand,maxrowsshow,bigtype,savedatabase,parentbigtype,sourcemodule)
SELECT @producttoolfieldid,@columnname,@allowhide,@fieldlabel,NULL,0,@uitype,@typeofdata,@sequence+1,@tabid,@tablename,35,0,0,0,0,1,0,1,'','','',0,@bigtype,'yes',@parentbigtype,@sourcemodule from dual
WHERE NOT EXISTS (SELECT 1 FROM ld_producttoolfield WHERE tabid=@tabid AND columnname=@columnname and tablename=@tablename  and sourcemodule=@sourcemodule);

SET @relatedid = (SELECT producttoolfieldid FROM ld_producttoolfield WHERE tabid=@tabid AND columnname=@columnname  and sourcemodule=@sourcemodule LIMIT 1);
INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
SELECT 'zh',@trantable,@tabid,@relatedid,@zh  from dual
WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE languagetype = 'zh' and tabid=@tabid and relateid=@relatedid AND trantable=@trantable);
INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
SELECT 'en',@trantable,@tabid,@relatedid,@en  from dual
WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE languagetype = 'en' and tabid=@tabid and relateid=@relatedid AND trantable=@trantable);

update ld_producttoolfield_seq set id = (select max(producttoolfieldid) from ld_producttoolfield);
delimiter;



SET @producttoolfieldid=(SELECT MAX(producttoolfieldid)+1 FROM ld_producttoolfield);
set @tabid = (select tabid from ld_tab where `name` = 'CashBill');
SET @columnname = 'total';
SET @trantable='ld_producttoolfield';
SET @allowhide = 'no';
SET @fieldlabel = '实际收款金额';
SET @zh='实际收款金额';
SET @en='Actual Receipts';
SET @uitype = 50;
SET @typeofdata='NN~O~25,3';
SET @bigtype='';
SET @parentbigtype='';
SET @sequence = (SELECT IFNULL(MAX(sequence),1) FROM ld_producttoolfield where tabid=@tabid);
SET @tablename = 'ld_cashbill2paymentplan';
SET @sourcemodule = 'OutboundOrder';
INSERT INTO ld_producttoolfield(producttoolfieldid,columnname,allowhide,fieldlabel,defaultvalue,presence,uitype,typeofdata,sequence,tabid,tablename,width,edit_permission,input_type,
fieldid,newline,defaultcolumn,is_checkimportfield,nullfield,referencemodule,datarange,approve_demand,maxrowsshow,bigtype,savedatabase,parentbigtype,sourcemodule)
SELECT @producttoolfieldid,@columnname,@allowhide,@fieldlabel,NULL,0,@uitype,@typeofdata,@sequence+1,@tabid,@tablename,35,1,0,0,1,1,0,1,'','','',0,@bigtype,'yes',@parentbigtype,@sourcemodule from dual
WHERE NOT EXISTS (SELECT 1 FROM ld_producttoolfield WHERE tabid=@tabid AND columnname=@columnname and tablename=@tablename  and sourcemodule=@sourcemodule);

SET @relatedid = (SELECT producttoolfieldid FROM ld_producttoolfield WHERE tabid=@tabid AND columnname=@columnname  and sourcemodule=@sourcemodule LIMIT 1);
INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
SELECT 'zh',@trantable,@tabid,@relatedid,@zh  from dual
WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE languagetype = 'zh' and tabid=@tabid and relateid=@relatedid AND trantable=@trantable);
INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
SELECT 'en',@trantable,@tabid,@relatedid,@en  from dual
WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE languagetype = 'en' and tabid=@tabid and relateid=@relatedid AND trantable=@trantable);

update ld_producttoolfield_seq set id = (select max(producttoolfieldid) from ld_producttoolfield);
delimiter;


SET @tabdetailfieldid=(SELECT MAX(tabdetailfieldid)+1 FROM ld_tabdetailfield);
set @tabid = (select tabid from ld_tab where `name` = 'CashBill');
SET @columnname = 'entitytype';
SET @trantable='ld_tabdetailfield';
SET @allowhide = 'no';
SET @fieldlabel = '源单类型';
SET @zh='源单类型';
SET @en='Link To';
SET @uitype = 'entitytype';
SET @typeofdata='V~O';
SET @bigtype='';
SET @parentbigtype='';
SET @sequence = (SELECT IFNULL(MAX(sequence),1) FROM ld_tabdetailfield where tabid=@tabid);
SET @tablename = 'ld_cashbill2paymentplan';
SET @sourcemodule = 'Invoice';
INSERT INTO ld_tabdetailfield(tabdetailfieldid,columnname,allowhide,fieldlabel,defaultvalue,presence,fieldtype,typeofdata,sequence,tabid,tablename,width,edit_permission,input_type,
fieldid,newline,defaultcolumn,is_checkimportfield,nullfield,referencemodule,datarange,approve_demand,maxrowsshow,bigtype,savedatabase,parentbigtype,sourcemodule)
SELECT @tabdetailfieldid,@columnname,@allowhide,@fieldlabel,NULL,0,@uitype,@typeofdata,@sequence+1,@tabid,@tablename,22,1,0,0,0,1,0,1,'','','',0,@bigtype,'yes',@parentbigtype,@sourcemodule from dual
WHERE NOT EXISTS (SELECT 1 FROM ld_tabdetailfield WHERE tabid=@tabid AND columnname=@columnname and tablename=@tablename and sourcemodule=@sourcemodule);

SET @relatedid = (SELECT tabdetailfieldid FROM ld_tabdetailfield WHERE tabid=@tabid AND columnname=@columnname  and sourcemodule=@sourcemodule LIMIT 1);
INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
SELECT 'zh',@trantable,@tabid,@relatedid,@zh  from dual
WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE languagetype = 'zh' and tabid=@tabid and relateid=@relatedid AND trantable=@trantable);
INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
SELECT 'en',@trantable,@tabid,@relatedid,@en  from dual
WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE languagetype = 'en' and tabid=@tabid and relateid=@relatedid AND trantable=@trantable);
CALL AddColumn(@tablename,@columnname,'varchar',25,'');
update ld_tabdetailfield_seq set id = (select max(tabdetailfieldid) from ld_tabdetailfield);
delimiter;

SET @tabdetailfieldid=(SELECT MAX(tabdetailfieldid)+1 FROM ld_tabdetailfield);
set @tabid = (select tabid from ld_tab where `name` = 'CashBill');
SET @columnname = 'entitytypeid';
SET @trantable='ld_tabdetailfield';
SET @allowhide = 'no';
SET @fieldlabel = '源单';
SET @zh='源单';
SET @en='Orignal Bill';
SET @uitype = 'SelectSource';
SET @typeofdata='V~O~100';
SET @bigtype='selectsource';
SET @parentbigtype='';
SET @sequence = (SELECT IFNULL(MAX(sequence),1) FROM ld_tabdetailfield where tabid=@tabid);
SET @tablename = 'ld_cashbill2paymentplan';
SET @sourcemodule = 'Invoice';
INSERT INTO ld_tabdetailfield(tabdetailfieldid,columnname,allowhide,fieldlabel,defaultvalue,presence,fieldtype,typeofdata,sequence,tabid,tablename,width,edit_permission,input_type,
fieldid,newline,defaultcolumn,is_checkimportfield,nullfield,referencemodule,datarange,approve_demand,maxrowsshow,bigtype,savedatabase,parentbigtype,sourcemodule)
SELECT @tabdetailfieldid,@columnname,@allowhide,@fieldlabel,NULL,0,@uitype,@typeofdata,@sequence+1,@tabid,@tablename,22,1,0,0,0,1,0,1,NULL,NULL,NULL,0,@bigtype,'yes',@parentbigtype,@sourcemodule from dual
WHERE NOT EXISTS (SELECT 1 FROM ld_tabdetailfield WHERE tabid=@tabid AND columnname=@columnname and tablename=@tablename and sourcemodule=@sourcemodule);

SET @relatedid = (SELECT tabdetailfieldid FROM ld_tabdetailfield WHERE tabid=@tabid AND columnname=@columnname and sourcemodule=@sourcemodule LIMIT 1);
INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
SELECT 'zh',@trantable,@tabid,@relatedid,@zh  from dual
WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE languagetype = 'zh' and tabid=@tabid and relateid=@relatedid AND trantable=@trantable);
INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
SELECT 'en',@trantable,@tabid,@relatedid,@en  from dual
WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE languagetype = 'en' and tabid=@tabid and relateid=@relatedid AND trantable=@trantable);
CALL AddColumn(@tablename,@columnname,'int',11,'');
update ld_tabdetailfield_seq set id = (select max(tabdetailfieldid) from ld_tabdetailfield);
delimiter;

SET @tabdetailfieldid=(SELECT MAX(tabdetailfieldid)+1 FROM ld_tabdetailfield);
set @tabid = (select tabid from ld_tab where `name` = 'CashBill');
SET @columnname = 'tablesourcetype';
SET @trantable='ld_tabdetailfield';
SET @allowhide = 'yes';
SET @fieldlabel = '源单源单类型';
SET @zh='源单源单类型';
SET @en='Source Type';
SET @uitype = 'entitytype';
SET @typeofdata='V~O';
SET @bigtype='relatedmodulefield';
SET @parentbigtype='entitytype';
SET @sequence = (SELECT IFNULL(MAX(sequence),1) FROM ld_tabdetailfield where tabid=@tabid);
SET @tablename = 'ld_cashbill2paymentplan';
SET @sourcemodule = 'Invoice';
INSERT INTO ld_tabdetailfield(tabdetailfieldid,columnname,allowhide,fieldlabel,defaultvalue,presence,fieldtype,typeofdata,sequence,tabid,tablename,width,edit_permission,input_type,
fieldid,newline,defaultcolumn,is_checkimportfield,nullfield,referencemodule,datarange,approve_demand,maxrowsshow,bigtype,savedatabase,parentbigtype,sourcemodule)
SELECT @tabdetailfieldid,@columnname,@allowhide,@fieldlabel,NULL,0,@uitype,@typeofdata,@sequence+1,@tabid,@tablename,22,1,0,0,0,1,0,1,NULL,NULL,NULL,0,@bigtype,'no',@parentbigtype,@sourcemodule from dual
WHERE NOT EXISTS (SELECT 1 FROM ld_tabdetailfield WHERE tabid=@tabid AND columnname=@columnname and tablename=@tablename and sourcemodule=@sourcemodule);

SET @relatedid = (SELECT tabdetailfieldid FROM ld_tabdetailfield WHERE tabid=@tabid AND columnname=@columnname and sourcemodule=@sourcemodule LIMIT 1);
INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
SELECT 'zh',@trantable,@tabid,@relatedid,@zh  from dual
WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE languagetype = 'zh' and tabid=@tabid and relateid=@relatedid AND trantable=@trantable);
INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
SELECT 'en',@trantable,@tabid,@relatedid,@en  from dual
WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE languagetype = 'en' and tabid=@tabid and relateid=@relatedid AND trantable=@trantable);
CALL AddColumn(@tablename,@columnname,'varchar',25,'');
update ld_tabdetailfield_seq set id = (select max(tabdetailfieldid) from ld_tabdetailfield);
delimiter;

SET @tabdetailfieldid=(SELECT MAX(tabdetailfieldid)+1 FROM ld_tabdetailfield);
set @tabid = (select tabid from ld_tab where `name` = 'CashBill');
SET @columnname = 'tablesourceid';
SET @trantable='ld_tabdetailfield';
SET @allowhide = 'yes';
SET @fieldlabel = '源单源单';
SET @zh='源单源单';
SET @en='Source Bill';
SET @uitype = 'SelectSource';
SET @typeofdata='V~O';
SET @bigtype='relatedmodulefield';
SET @parentbigtype='selectsource';
SET @sequence = (SELECT IFNULL(MAX(sequence),1) FROM ld_tabdetailfield where tabid=@tabid);
SET @tablename = 'ld_cashbill2paymentplan';
SET @sourcemodule = 'Invoice';
INSERT INTO ld_tabdetailfield(tabdetailfieldid,columnname,allowhide,fieldlabel,defaultvalue,presence,fieldtype,typeofdata,sequence,tabid,tablename,width,edit_permission,input_type,
fieldid,newline,defaultcolumn,is_checkimportfield,nullfield,referencemodule,datarange,approve_demand,maxrowsshow,bigtype,savedatabase,parentbigtype,sourcemodule)
SELECT @tabdetailfieldid,@columnname,@allowhide,@fieldlabel,NULL,0,@uitype,@typeofdata,@sequence+1,@tabid,@tablename,22,1,0,0,0,1,0,1,NULL,NULL,NULL,0,@bigtype,'no',@parentbigtype,@sourcemodule from dual
WHERE NOT EXISTS (SELECT 1 FROM ld_tabdetailfield WHERE tabid=@tabid AND columnname=@columnname and tablename=@tablename and sourcemodule=@sourcemodule);

SET @relatedid = (SELECT tabdetailfieldid FROM ld_tabdetailfield WHERE tabid=@tabid AND columnname=@columnname and sourcemodule=@sourcemodule LIMIT 1);
INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
SELECT 'zh',@trantable,@tabid,@relatedid,@zh  from dual
WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE languagetype = 'zh' and tabid=@tabid and relateid=@relatedid AND trantable=@trantable);
INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
SELECT 'en',@trantable,@tabid,@relatedid,@en  from dual
WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE languagetype = 'en' and tabid=@tabid and relateid=@relatedid AND trantable=@trantable);
CALL AddColumn(@tablename,@columnname,'varchar',25,'');
update ld_tabdetailfield_seq set id = (select max(tabdetailfieldid) from ld_tabdetailfield);
delimiter;

SET @tabdetailfieldid=(SELECT MAX(tabdetailfieldid)+1 FROM ld_tabdetailfield);
set @tabid = (select tabid from ld_tab where `name` = 'CashBill');
SET @columnname = 'billdate';
SET @trantable='ld_tabdetailfield';
SET @allowhide = 'yes';
SET @fieldlabel = '源单日期';
SET @zh='源单日期';
SET @en='Source Date';
SET @uitype = 'Date_Ymd';
SET @typeofdata='D~O';
SET @bigtype='relatedmodulefield';
SET @parentbigtype='date';
SET @sequence = (SELECT IFNULL(MAX(sequence),1) FROM ld_tabdetailfield where tabid=@tabid);
SET @tablename = 'ld_cashbill2paymentplan';
SET @sourcemodule = 'Invoice';
INSERT INTO ld_tabdetailfield(tabdetailfieldid,columnname,allowhide,fieldlabel,defaultvalue,presence,fieldtype,typeofdata,sequence,tabid,tablename,width,edit_permission,input_type,
fieldid,newline,defaultcolumn,is_checkimportfield,nullfield,referencemodule,datarange,approve_demand,maxrowsshow,bigtype,savedatabase,parentbigtype,sourcemodule)
SELECT @tabdetailfieldid,@columnname,@allowhide,@fieldlabel,NULL,0,@uitype,@typeofdata,@sequence+1,@tabid,@tablename,30,1,0,0,0,1,0,1,NULL,NULL,NULL,0,@bigtype,'no',@parentbigtype,@sourcemodule from dual
WHERE NOT EXISTS (SELECT 1 FROM ld_tabdetailfield WHERE tabid=@tabid AND columnname=@columnname and tablename=@tablename and sourcemodule=@sourcemodule);

SET @relatedid = (SELECT tabdetailfieldid FROM ld_tabdetailfield WHERE tabid=@tabid AND columnname=@columnname and sourcemodule=@sourcemodule LIMIT 1);
INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
SELECT 'zh',@trantable,@tabid,@relatedid,@zh  from dual
WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE languagetype = 'zh' and tabid=@tabid and relateid=@relatedid AND trantable=@trantable);
INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
SELECT 'en',@trantable,@tabid,@relatedid,@en  from dual
WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE languagetype = 'en' and tabid=@tabid and relateid=@relatedid AND trantable=@trantable);
CALL AddColumn(@tablename,@columnname,'date','','');
update ld_tabdetailfield_seq set id = (select max(tabdetailfieldid) from ld_tabdetailfield);
delimiter;


SET @tabdetailfieldid=(SELECT MAX(tabdetailfieldid)+1 FROM ld_tabdetailfield);
set @tabid = (select tabid from ld_tab where `name` = 'CashBill');
SET @columnname = 'source_total';
SET @trantable='ld_tabdetailfield';
SET @allowhide = 'yes';
SET @fieldlabel = '源单金额';
SET @zh='源单金额';
SET @en='Source Amount';
SET @uitype = 'Amount';
SET @typeofdata='N~O~25,6';
SET @bigtype='relatedmodulefield';
SET @parentbigtype='amount';
SET @sequence = (SELECT IFNULL(MAX(sequence),1) FROM ld_tabdetailfield where tabid=@tabid);
SET @tablename = 'ld_cashbill2paymentplan';
SET @sourcemodule = 'Invoice';
INSERT INTO ld_tabdetailfield(tabdetailfieldid,columnname,allowhide,fieldlabel,defaultvalue,presence,fieldtype,typeofdata,sequence,tabid,tablename,width,edit_permission,input_type,
fieldid,newline,defaultcolumn,is_checkimportfield,nullfield,referencemodule,datarange,approve_demand,maxrowsshow,bigtype,savedatabase,parentbigtype,sourcemodule)
SELECT @tabdetailfieldid,@columnname,@allowhide,@fieldlabel,NULL,0,@uitype,@typeofdata,@sequence+1,@tabid,@tablename,30,1,0,0,0,1,0,1,NULL,NULL,NULL,0,@bigtype,'no',@parentbigtype,@sourcemodule from dual
WHERE NOT EXISTS (SELECT 1 FROM ld_tabdetailfield WHERE tabid=@tabid AND columnname=@columnname and tablename=@tablename and sourcemodule=@sourcemodule);

SET @relatedid = (SELECT tabdetailfieldid FROM ld_tabdetailfield WHERE tabid=@tabid AND columnname=@columnname and sourcemodule=@sourcemodule LIMIT 1);
INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
SELECT 'zh',@trantable,@tabid,@relatedid,@zh  from dual
WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE languagetype = 'zh' and tabid=@tabid and relateid=@relatedid AND trantable=@trantable);
INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
SELECT 'en',@trantable,@tabid,@relatedid,@en  from dual
WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE languagetype = 'en' and tabid=@tabid and relateid=@relatedid AND trantable=@trantable);
CALL AddColumn(@tablename,@columnname,'decimal','25','0.000000');
update ld_tabdetailfield_seq set id = (select max(tabdetailfieldid) from ld_tabdetailfield);
delimiter;


SET @tabdetailfieldid=(SELECT MAX(tabdetailfieldid)+1 FROM ld_tabdetailfield);
set @tabid = (select tabid from ld_tab where `name` = 'CashBill');
SET @columnname = 'received_amount';
SET @trantable='ld_tabdetailfield';
SET @allowhide = 'yes';
SET @fieldlabel = '源单已收总额';
SET @zh='源单已收总额';
SET @en='Received Amount';
SET @uitype = 'Amount';
SET @typeofdata='N~O~25,6';
SET @bigtype='relatedmodulefield';
SET @parentbigtype='amount';
SET @sequence = (SELECT IFNULL(MAX(sequence),1) FROM ld_tabdetailfield where tabid=@tabid);
SET @tablename = 'ld_cashbill2paymentplan';
SET @sourcemodule = 'Invoice';
INSERT INTO ld_tabdetailfield(tabdetailfieldid,columnname,allowhide,fieldlabel,defaultvalue,presence,fieldtype,typeofdata,sequence,tabid,tablename,width,edit_permission,input_type,
fieldid,newline,defaultcolumn,is_checkimportfield,nullfield,referencemodule,datarange,approve_demand,maxrowsshow,bigtype,savedatabase,parentbigtype,sourcemodule)
SELECT @tabdetailfieldid,@columnname,@allowhide,@fieldlabel,NULL,0,@uitype,@typeofdata,@sequence+1,@tabid,@tablename,30,1,0,0,0,1,0,1,NULL,NULL,NULL,0,@bigtype,'no',@parentbigtype,@sourcemodule from dual
WHERE NOT EXISTS (SELECT 1 FROM ld_tabdetailfield WHERE tabid=@tabid AND columnname=@columnname and tablename=@tablename and sourcemodule=@sourcemodule);

SET @relatedid = (SELECT tabdetailfieldid FROM ld_tabdetailfield WHERE tabid=@tabid AND columnname=@columnname and sourcemodule=@sourcemodule LIMIT 1);
INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
SELECT 'zh',@trantable,@tabid,@relatedid,@zh  from dual
WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE languagetype = 'zh' and tabid=@tabid and relateid=@relatedid AND trantable=@trantable);
INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
SELECT 'en',@trantable,@tabid,@relatedid,@en  from dual
WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE languagetype = 'en' and tabid=@tabid and relateid=@relatedid AND trantable=@trantable);
CALL AddColumn(@tablename,@columnname,'decimal','25','0.000000');
update ld_tabdetailfield_seq set id = (select max(tabdetailfieldid) from ld_tabdetailfield);
delimiter;

SET @tabdetailfieldid=(SELECT MAX(tabdetailfieldid)+1 FROM ld_tabdetailfield);
set @tabid = (select tabid from ld_tab where `name` = 'CashBill');
SET @columnname = 'amount';
SET @trantable='ld_tabdetailfield';
SET @allowhide = 'no';
SET @fieldlabel = '本次收款金额';
SET @zh='本次收款金额';
SET @en='Received Amount';
SET @uitype = 'Amount';
SET @typeofdata='N~O~25,6';
SET @bigtype='amount';
SET @parentbigtype='';
SET @sequence = (SELECT IFNULL(MAX(sequence),1) FROM ld_tabdetailfield where tabid=@tabid);
SET @tablename = 'ld_cashbill2paymentplan';
SET @sourcemodule = 'Invoice';
INSERT INTO ld_tabdetailfield(tabdetailfieldid,columnname,allowhide,fieldlabel,defaultvalue,presence,fieldtype,typeofdata,sequence,tabid,tablename,width,edit_permission,input_type,
fieldid,newline,defaultcolumn,is_checkimportfield,nullfield,referencemodule,datarange,approve_demand,maxrowsshow,bigtype,savedatabase,parentbigtype,sourcemodule)
SELECT @tabdetailfieldid,@columnname,@allowhide,@fieldlabel,NULL,0,@uitype,@typeofdata,@sequence+1,@tabid,@tablename,30,0,0,0,0,1,0,1,NULL,NULL,NULL,0,@bigtype,'yes',@parentbigtype,@sourcemodule from dual
WHERE NOT EXISTS (SELECT 1 FROM ld_tabdetailfield WHERE tabid=@tabid AND columnname=@columnname and tablename=@tablename and sourcemodule=@sourcemodule);

SET @relatedid = (SELECT tabdetailfieldid FROM ld_tabdetailfield WHERE tabid=@tabid AND columnname=@columnname and sourcemodule=@sourcemodule LIMIT 1);
INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
SELECT 'zh',@trantable,@tabid,@relatedid,@zh  from dual
WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE languagetype = 'zh' and tabid=@tabid and relateid=@relatedid AND trantable=@trantable);
INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
SELECT 'en',@trantable,@tabid,@relatedid,@en  from dual
WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE languagetype = 'en' and tabid=@tabid and relateid=@relatedid AND trantable=@trantable);
CALL AddColumn(@tablename,@columnname,'decimal','25','0.00');
update ld_tabdetailfield_seq set id = (select max(tabdetailfieldid) from ld_tabdetailfield);
delimiter;

SET @tabdetailfieldid=(SELECT MAX(tabdetailfieldid)+1 FROM ld_tabdetailfield);
set @tabid = (select tabid from ld_tab where `name` = 'CashBill');
SET @columnname = 'total';
SET @trantable='ld_tabdetailfield';
SET @allowhide = 'no';
SET @fieldlabel = '实际收款金额';
SET @zh='实际收款金额';
SET @en='Actual Receipts';
SET @uitype = 'Amount';
SET @typeofdata='N~O~25,6';
SET @bigtype='';
SET @parentbigtype='';
SET @sequence = (SELECT IFNULL(MAX(sequence),1) FROM ld_tabdetailfield where tabid=@tabid);
SET @tablename = 'ld_cashbill2paymentplan';
SET @sourcemodule = 'Invoice';
INSERT INTO ld_tabdetailfield(tabdetailfieldid,columnname,allowhide,fieldlabel,defaultvalue,presence,fieldtype,typeofdata,sequence,tabid,tablename,width,edit_permission,input_type,
fieldid,newline,defaultcolumn,is_checkimportfield,nullfield,referencemodule,datarange,approve_demand,maxrowsshow,bigtype,savedatabase,parentbigtype,sourcemodule)
SELECT @tabdetailfieldid,@columnname,@allowhide,@fieldlabel,NULL,0,@uitype,@typeofdata,@sequence+1,@tabid,@tablename,30,1,0,0,1,1,0,1,NULL,NULL,NULL,0,@bigtype,'yes',@parentbigtype,@sourcemodule from dual
WHERE NOT EXISTS (SELECT 1 FROM ld_tabdetailfield WHERE tabid=@tabid AND columnname=@columnname and tablename=@tablename and sourcemodule=@sourcemodule);

SET @relatedid = (SELECT tabdetailfieldid FROM ld_tabdetailfield WHERE tabid=@tabid AND columnname=@columnname and sourcemodule=@sourcemodule LIMIT 1);
INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
SELECT 'zh',@trantable,@tabid,@relatedid,@zh  from dual
WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE languagetype = 'zh' and tabid=@tabid and relateid=@relatedid AND trantable=@trantable);
INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
SELECT 'en',@trantable,@tabid,@relatedid,@en  from dual
WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE languagetype = 'en' and tabid=@tabid and relateid=@relatedid AND trantable=@trantable);
CALL AddColumn(@tablename,@columnname,'decimal','25','0.000000');
update ld_tabdetailfield_seq set id = (select max(tabdetailfieldid) from ld_tabdetailfield);
delimiter;


SET @producttoolfieldid=(SELECT MAX(producttoolfieldid)+1 FROM ld_producttoolfield);
set @tabid = (select tabid from ld_tab where `name` = 'CashBill');
SET @columnname = 'entitytype';
SET @trantable='ld_producttoolfield';
SET @allowhide = 'no';
SET @fieldlabel = '源单类型';
SET @zh='源单类型';
SET @en='Link To';
SET @uitype = 204;
SET @typeofdata='V~O~100';
SET @bigtype='';
SET @parentbigtype='';
SET @sequence = (SELECT IFNULL(MAX(sequence),1) FROM ld_producttoolfield where tabid=@tabid);
SET @tablename = 'ld_cashbill2paymentplan';
SET @sourcemodule = 'Invoice';
INSERT INTO ld_producttoolfield(producttoolfieldid,columnname,allowhide,fieldlabel,defaultvalue,presence,uitype,typeofdata,sequence,tabid,tablename,width,edit_permission,input_type,
fieldid,newline,defaultcolumn,is_checkimportfield,nullfield,referencemodule,datarange,approve_demand,maxrowsshow,bigtype,savedatabase,parentbigtype,sourcemodule)
SELECT @producttoolfieldid,@columnname,@allowhide,@fieldlabel,NULL,0,@uitype,@typeofdata,@sequence+1,@tabid,@tablename,30,1,0,0,0,1,0,1,'','','',0,@bigtype,'yes',@parentbigtype,@sourcemodule from dual
WHERE NOT EXISTS (SELECT 1 FROM ld_producttoolfield WHERE tabid=@tabid AND columnname=@columnname and tablename=@tablename and sourcemodule=@sourcemodule);

SET @relatedid = (SELECT producttoolfieldid FROM ld_producttoolfield WHERE tabid=@tabid AND columnname=@columnname and sourcemodule=@sourcemodule LIMIT 1);
INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
SELECT 'zh',@trantable,@tabid,@relatedid,@zh  from dual
WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE languagetype = 'zh' and tabid=@tabid and relateid=@relatedid AND trantable=@trantable);
INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
SELECT 'en',@trantable,@tabid,@relatedid,@en  from dual
WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE languagetype = 'en' and tabid=@tabid and relateid=@relatedid AND trantable=@trantable);
CALL AddColumn(@tablename,@columnname,'varchar',25,'');
update ld_producttoolfield_seq set id = (select max(producttoolfieldid) from ld_producttoolfield);
delimiter;



SET @producttoolfieldid=(SELECT MAX(producttoolfieldid)+1 FROM ld_producttoolfield);
set @tabid = (select tabid from ld_tab where `name` = 'CashBill');
SET @columnname = 'entitytypeid';
SET @trantable='ld_producttoolfield';
SET @allowhide = 'no';
SET @fieldlabel = '源单';
SET @zh='源单';
SET @en='Orignal Bill';
SET @uitype = 202;
SET @typeofdata='V~O~100';
SET @bigtype='selectsource';
SET @parentbigtype='';
SET @sequence = (SELECT IFNULL(MAX(sequence),1) FROM ld_producttoolfield where tabid=@tabid);
SET @tablename = 'ld_cashbill2paymentplan';
SET @sourcemodule = 'Invoice';
INSERT INTO ld_producttoolfield(producttoolfieldid,columnname,allowhide,fieldlabel,defaultvalue,presence,uitype,typeofdata,sequence,tabid,tablename,width,edit_permission,input_type,
fieldid,newline,defaultcolumn,is_checkimportfield,nullfield,referencemodule,datarange,approve_demand,maxrowsshow,bigtype,savedatabase,parentbigtype,sourcemodule)
SELECT @producttoolfieldid,@columnname,@allowhide,@fieldlabel,NULL,0,@uitype,@typeofdata,@sequence+1,@tabid,@tablename,22,1,0,0,0,1,0,1,'','','',0,@bigtype,'yes',@parentbigtype,@sourcemodule from dual
WHERE NOT EXISTS (SELECT 1 FROM ld_producttoolfield WHERE tabid=@tabid AND columnname=@columnname and tablename=@tablename and sourcemodule=@sourcemodule);

SET @relatedid = (SELECT producttoolfieldid FROM ld_producttoolfield WHERE tabid=@tabid AND columnname=@columnname and sourcemodule=@sourcemodule LIMIT 1);
INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
SELECT 'zh',@trantable,@tabid,@relatedid,@zh  from dual
WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE languagetype = 'zh' and tabid=@tabid and relateid=@relatedid AND trantable=@trantable);
INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
SELECT 'en',@trantable,@tabid,@relatedid,@en  from dual
WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE languagetype = 'en' and tabid=@tabid and relateid=@relatedid AND trantable=@trantable);
CALL AddColumn(@tablename,@columnname,'int',11,'');
update ld_producttoolfield_seq set id = (select max(producttoolfieldid) from ld_producttoolfield);
delimiter;


SET @producttoolfieldid=(SELECT MAX(producttoolfieldid)+1 FROM ld_producttoolfield);
set @tabid = (select tabid from ld_tab where `name` = 'CashBill');
SET @columnname = 'productname';
SET @trantable='ld_producttoolfield';
SET @allowhide = 'no';
SET @fieldlabel = '产品名称';
SET @zh='产品名称';
SET @en='Product Name';
SET @uitype = 70;
SET @typeofdata='V~M~100';
SET @bigtype='selectsource';
SET @parentbigtype='';
SET @sequence = (SELECT IFNULL(MAX(sequence),1) FROM ld_producttoolfield where tabid=@tabid);
SET @tablename = 'ld_products';
SET @sourcemodule = 'Invoice';
SET @producttabid = (select tabid from ld_tab where `name`='Products');
set @fieldid=(select fieldid from ld_field where tabid = @producttabid and fieldname = 'productname');
INSERT INTO ld_producttoolfield(producttoolfieldid,columnname,allowhide,fieldlabel,defaultvalue,presence,uitype,typeofdata,sequence,tabid,tablename,width,edit_permission,input_type,
fieldid,newline,defaultcolumn,is_checkimportfield,nullfield,referencemodule,datarange,approve_demand,maxrowsshow,bigtype,savedatabase,parentbigtype,sourcemodule)
SELECT @producttoolfieldid,@columnname,@allowhide,@fieldlabel,NULL,0,@uitype,@typeofdata,@sequence+1,@tabid,@tablename,45,0,0,@fieldid,0,2,0,0,'','','',0,@bigtype,'yes',@parentbigtype,@sourcemodule from dual
WHERE NOT EXISTS (SELECT 1 FROM ld_producttoolfield WHERE tabid=@tabid AND columnname=@columnname and tablename=@tablename and sourcemodule=@sourcemodule);

SET @relatedid = (SELECT producttoolfieldid FROM ld_producttoolfield WHERE tabid=@tabid AND columnname=@columnname and sourcemodule=@sourcemodule LIMIT 1);
INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
SELECT 'zh',@trantable,@tabid,@relatedid,@zh  from dual
WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE languagetype = 'zh' and tabid=@tabid and relateid=@relatedid AND trantable=@trantable);
INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
SELECT 'en',@trantable,@tabid,@relatedid,@en  from dual
WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE languagetype = 'en' and tabid=@tabid and relateid=@relatedid AND trantable=@trantable);
CALL AddColumn('ld_cashbill2paymentplan','productid','int',11,'');
update ld_producttoolfield_seq set id = (select max(producttoolfieldid) from ld_producttoolfield);
delimiter;

SET @producttoolfieldid=(SELECT MAX(producttoolfieldid)+1 FROM ld_producttoolfield);
set @tabid = (select tabid from ld_tab where `name` = 'CashBill');
SET @columnname = 'product_no';
SET @trantable='ld_producttoolfield';
SET @allowhide = 'yes';
SET @fieldlabel = '产品编号';
SET @zh='产品编号';
SET @en='Product No';
SET @uitype = 4;
SET @typeofdata='V~O';
SET @bigtype='';
SET @parentbigtype='';
SET @sequence = (SELECT IFNULL(MAX(sequence),1) FROM ld_producttoolfield where tabid=@tabid);
SET @tablename = 'ld_products';
SET @sourcemodule = 'Invoice';
SET @producttabid = (select tabid from ld_tab where `name`='Products');
SET @fieldid = (SELECT fieldid FROM ld_field where tabid=@producttabid and columnname = 'product_no');
INSERT INTO ld_producttoolfield(producttoolfieldid,columnname,allowhide,fieldlabel,defaultvalue,presence,uitype,typeofdata,sequence,tabid,tablename,width,edit_permission,input_type,
fieldid,newline,defaultcolumn,is_checkimportfield,nullfield,referencemodule,datarange,approve_demand,maxrowsshow,bigtype,savedatabase,parentbigtype,sourcemodule)
SELECT @producttoolfieldid,@columnname,@allowhide,@fieldlabel,NULL,0,@uitype,@typeofdata,@sequence+1,@tabid,@tablename,22,1,1,@fieldid,0,1,0,1,'','','',0,@bigtype,'yes',@parentbigtype,@sourcemodule from dual
WHERE NOT EXISTS (SELECT 1 FROM ld_producttoolfield WHERE tabid=@tabid AND columnname=@columnname and tablename=@tablename and sourcemodule=@sourcemodule);

SET @relatedid = (SELECT producttoolfieldid FROM ld_producttoolfield WHERE tabid=@tabid AND columnname=@columnname and sourcemodule=@sourcemodule LIMIT 1);
INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
SELECT 'zh',@trantable,@tabid,@relatedid,@zh  from dual
WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE languagetype = 'zh' and tabid=@tabid and relateid=@relatedid AND trantable=@trantable);
INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
SELECT 'en',@trantable,@tabid,@relatedid,@en  from dual
WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE languagetype = 'en' and tabid=@tabid and relateid=@relatedid AND trantable=@trantable);

update ld_producttoolfield_seq set id = (select max(producttoolfieldid) from ld_producttoolfield);
delimiter;

SET @producttoolfieldid=(SELECT MAX(producttoolfieldid)+1 FROM ld_producttoolfield);
set @tabid = (select tabid from ld_tab where `name` = 'CashBill');
SET @columnname = 'productsheet';
SET @trantable='ld_producttoolfield';
SET @allowhide = 'yes';
SET @fieldlabel = '规格型号';
SET @zh='规格型号';
SET @en='Specification';
SET @uitype = 1;
SET @typeofdata='V~O';
SET @bigtype='';
SET @parentbigtype='';
SET @sequence = (SELECT IFNULL(MAX(sequence),1) FROM ld_producttoolfield where tabid=@tabid);
SET @tablename = 'ld_products';
SET @sourcemodule = 'Invoice';
SET @producttabid = (select tabid from ld_tab where `name`='Products');
SET @fieldid = (SELECT fieldid FROM ld_field where tabid=@producttabid and columnname = 'productsheet');
INSERT INTO ld_producttoolfield(producttoolfieldid,columnname,allowhide,fieldlabel,defaultvalue,presence,uitype,typeofdata,sequence,tabid,tablename,width,edit_permission,input_type,
fieldid,newline,defaultcolumn,is_checkimportfield,nullfield,referencemodule,datarange,approve_demand,maxrowsshow,bigtype,savedatabase,parentbigtype,sourcemodule)
SELECT @producttoolfieldid,@columnname,@allowhide,@fieldlabel,NULL,0,@uitype,@typeofdata,@sequence+1,@tabid,@tablename,22,1,1,@fieldid,0,1,0,1,'','','',0,@bigtype,'yes',@parentbigtype,@sourcemodule from dual
WHERE NOT EXISTS (SELECT 1 FROM ld_producttoolfield WHERE tabid=@tabid AND columnname=@columnname and tablename=@tablename and sourcemodule=@sourcemodule);

SET @relatedid = (SELECT producttoolfieldid FROM ld_producttoolfield WHERE tabid=@tabid AND columnname=@columnname and sourcemodule=@sourcemodule LIMIT 1);
INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
SELECT 'zh',@trantable,@tabid,@relatedid,@zh  from dual
WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE languagetype = 'zh' and tabid=@tabid and relateid=@relatedid AND trantable=@trantable);
INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
SELECT 'en',@trantable,@tabid,@relatedid,@en  from dual
WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE languagetype = 'en' and tabid=@tabid and relateid=@relatedid AND trantable=@trantable);

update ld_producttoolfield_seq set id = (select max(producttoolfieldid) from ld_producttoolfield);
delimiter;



SET @producttoolfieldid=(SELECT MAX(producttoolfieldid)+1 FROM ld_producttoolfield);
set @tabid = (select tabid from ld_tab where `name` = 'CashBill');
SET @columnname = 'productsourcetype';
SET @trantable='ld_producttoolfield';
SET @allowhide = 'yes';
SET @fieldlabel = '产品源单类型';
SET @zh='产品源单类型';
SET @en='Source Type';
SET @uitype = 221;
SET @typeofdata='V~O';
SET @bigtype='relatedmodulefield';
SET @parentbigtype='entitytype';
SET @sequence = (SELECT IFNULL(MAX(sequence),1) FROM ld_producttoolfield where tabid=@tabid);
SET @tablename = 'ld_cashbill2paymentplan';
SET @sourcemodule = 'Invoice';
INSERT INTO ld_producttoolfield(producttoolfieldid,columnname,allowhide,fieldlabel,defaultvalue,presence,uitype,typeofdata,sequence,tabid,tablename,width,edit_permission,input_type,
fieldid,newline,defaultcolumn,is_checkimportfield,nullfield,referencemodule,datarange,approve_demand,maxrowsshow,bigtype,savedatabase,parentbigtype,sourcemodule)
SELECT @producttoolfieldid,@columnname,@allowhide,@fieldlabel,NULL,0,@uitype,@typeofdata,@sequence+1,@tabid,@tablename,22,1,0,0,0,1,0,1,'','','',0,@bigtype,'no',@parentbigtype,@sourcemodule from dual
WHERE NOT EXISTS (SELECT 1 FROM ld_producttoolfield WHERE tabid=@tabid AND columnname=@columnname and tablename=@tablename and sourcemodule=@sourcemodule);

SET @relatedid = (SELECT producttoolfieldid FROM ld_producttoolfield WHERE tabid=@tabid AND columnname=@columnname and sourcemodule=@sourcemodule LIMIT 1);
INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
SELECT 'zh',@trantable,@tabid,@relatedid,@zh  from dual
WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE languagetype = 'zh' and tabid=@tabid and relateid=@relatedid AND trantable=@trantable);
INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
SELECT 'en',@trantable,@tabid,@relatedid,@en  from dual
WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE languagetype = 'en' and tabid=@tabid and relateid=@relatedid AND trantable=@trantable);
CALL AddColumn('ld_cashbill2paymentplan','productsourcetype','varchar',25,'');
update ld_producttoolfield_seq set id = (select max(producttoolfieldid) from ld_producttoolfield);
delimiter;


SET @producttoolfieldid=(SELECT MAX(producttoolfieldid)+1 FROM ld_producttoolfield);
set @tabid = (select tabid from ld_tab where `name` = 'CashBill');
SET @columnname = 'productsourceid';
SET @trantable='ld_producttoolfield';
SET @allowhide = 'yes';
SET @fieldlabel = '产品源单';
SET @zh='产品源单';
SET @en='Source Bill';
SET @uitype = 220;
SET @typeofdata='V~O';
SET @bigtype='relatedmodulefield';
SET @parentbigtype='selectsource';
SET @sequence = (SELECT IFNULL(MAX(sequence),1) FROM ld_producttoolfield where tabid=@tabid);
SET @tablename = 'ld_cashbill2paymentplan';
SET @sourcemodule = 'Invoice';
INSERT INTO ld_producttoolfield(producttoolfieldid,columnname,allowhide,fieldlabel,defaultvalue,presence,uitype,typeofdata,sequence,tabid,tablename,width,edit_permission,input_type,
fieldid,newline,defaultcolumn,is_checkimportfield,nullfield,referencemodule,datarange,approve_demand,maxrowsshow,bigtype,savedatabase,parentbigtype,sourcemodule)
SELECT @producttoolfieldid,@columnname,@allowhide,@fieldlabel,NULL,0,@uitype,@typeofdata,@sequence+1,@tabid,@tablename,30,1,0,0,0,1,0,1,'','','',0,@bigtype,'no',@parentbigtype,@sourcemodule from dual
WHERE NOT EXISTS (SELECT 1 FROM ld_producttoolfield WHERE tabid=@tabid AND columnname=@columnname and tablename=@tablename and sourcemodule=@sourcemodule);

SET @relatedid = (SELECT producttoolfieldid FROM ld_producttoolfield WHERE tabid=@tabid AND columnname=@columnname and sourcemodule=@sourcemodule LIMIT 1);
INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
SELECT 'zh',@trantable,@tabid,@relatedid,@zh  from dual
WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE languagetype = 'zh' and tabid=@tabid and relateid=@relatedid AND trantable=@trantable);
INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
SELECT 'en',@trantable,@tabid,@relatedid,@en  from dual
WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE languagetype = 'en' and tabid=@tabid and relateid=@relatedid AND trantable=@trantable);
CALL AddColumn('ld_cashbill2paymentplan','productsourceid','int',11,'');
update ld_producttoolfield_seq set id = (select max(producttoolfieldid) from ld_producttoolfield);
delimiter;


SET @producttoolfieldid=(SELECT MAX(producttoolfieldid)+1 FROM ld_producttoolfield);
set @tabid = (select tabid from ld_tab where `name` = 'CashBill');
SET @columnname = 'tax_amount';
SET @trantable='ld_producttoolfield';
SET @allowhide = 'yes';
SET @fieldlabel = '价税合计';
SET @zh='价税合计';
SET @en='Tax-inclusive Amount';
SET @uitype = 28;
SET @typeofdata='N~O~25,6';
SET @bigtype='';
SET @parentbigtype='';
SET @sequence = (SELECT IFNULL(MAX(sequence),1) FROM ld_producttoolfield where tabid=@tabid);
SET @tablename = 'ld_cashbill2paymentplan';
SET @sourcemodule = 'Invoice';
INSERT INTO ld_producttoolfield(producttoolfieldid,columnname,allowhide,fieldlabel,defaultvalue,presence,uitype,typeofdata,sequence,tabid,tablename,width,edit_permission,input_type,
fieldid,newline,defaultcolumn,is_checkimportfield,nullfield,referencemodule,datarange,approve_demand,maxrowsshow,bigtype,savedatabase,parentbigtype,sourcemodule)
SELECT @producttoolfieldid,@columnname,@allowhide,@fieldlabel,NULL,0,@uitype,@typeofdata,@sequence+1,@tabid,@tablename,22,1,0,0,0,1,0,1,'','','',0,@bigtype,'yes',@parentbigtype,@sourcemodule from dual
WHERE NOT EXISTS (SELECT 1 FROM ld_producttoolfield WHERE tabid=@tabid AND columnname=@columnname and tablename=@tablename and sourcemodule=@sourcemodule);

SET @relatedid = (SELECT producttoolfieldid FROM ld_producttoolfield WHERE tabid=@tabid AND columnname=@columnname and sourcemodule=@sourcemodule LIMIT 1);
INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
SELECT 'zh',@trantable,@tabid,@relatedid,@zh  from dual
WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE languagetype = 'zh' and tabid=@tabid and relateid=@relatedid AND trantable=@trantable);
INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
SELECT 'en',@trantable,@tabid,@relatedid,@en  from dual
WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE languagetype = 'en' and tabid=@tabid and relateid=@relatedid AND trantable=@trantable);
CALL AddColumn('ld_cashbill2paymentplan','tax_amount','decimal',25,'');
update ld_producttoolfield_seq set id = (select max(producttoolfieldid) from ld_producttoolfield);
delimiter;




SET @producttoolfieldid=(SELECT MAX(producttoolfieldid)+1 FROM ld_producttoolfield);
set @tabid = (select tabid from ld_tab where `name` = 'CashBill');
SET @columnname = 'product_received_amount';
SET @trantable='ld_producttoolfield';
SET @allowhide = 'yes';
SET @fieldlabel = '产品已收总额';
SET @zh='产品已收总额';
SET @en='Received Amount';
SET @uitype = 50;
SET @typeofdata='NN~O~25,3';
SET @bigtype='';
SET @parentbigtype='';
SET @sequence = (SELECT IFNULL(MAX(sequence),1) FROM ld_producttoolfield where tabid=@tabid);
SET @tablename = 'ld_cashbill2paymentplan';
SET @sourcemodule = 'Invoice';
INSERT INTO ld_producttoolfield(producttoolfieldid,columnname,allowhide,fieldlabel,defaultvalue,presence,uitype,typeofdata,sequence,tabid,tablename,width,edit_permission,input_type,
fieldid,newline,defaultcolumn,is_checkimportfield,nullfield,referencemodule,datarange,approve_demand,maxrowsshow,bigtype,savedatabase,parentbigtype,sourcemodule)
SELECT @producttoolfieldid,@columnname,@allowhide,@fieldlabel,NULL,0,@uitype,@typeofdata,@sequence+1,@tabid,@tablename,22,1,0,0,1,1,0,1,'','','',0,@bigtype,'no',@parentbigtype,@sourcemodule from dual
WHERE NOT EXISTS (SELECT 1 FROM ld_producttoolfield WHERE tabid=@tabid AND columnname=@columnname and tablename=@tablename  and sourcemodule=@sourcemodule);

SET @relatedid = (SELECT producttoolfieldid FROM ld_producttoolfield WHERE tabid=@tabid AND columnname=@columnname  and sourcemodule=@sourcemodule LIMIT 1);
INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
SELECT 'zh',@trantable,@tabid,@relatedid,@zh  from dual
WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE languagetype = 'zh' and tabid=@tabid and relateid=@relatedid AND trantable=@trantable);
INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
SELECT 'en',@trantable,@tabid,@relatedid,@en  from dual
WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE languagetype = 'en' and tabid=@tabid and relateid=@relatedid AND trantable=@trantable);
CALL AddColumn('ld_cashbill2paymentplan','product_received_amount','decimal',25,'');
update ld_producttoolfield_seq set id = (select max(producttoolfieldid) from ld_producttoolfield);
delimiter;


SET @producttoolfieldid=(SELECT MAX(producttoolfieldid)+1 FROM ld_producttoolfield);
set @tabid = (select tabid from ld_tab where `name` = 'CashBill');
SET @columnname = 'amount';
SET @trantable='ld_producttoolfield';
SET @allowhide = 'no';
SET @fieldlabel = '本次收款金额';
SET @zh='本次收款金额';
SET @en='The amount collected';
SET @uitype = 50;
SET @typeofdata='NN~O~25,3';
SET @bigtype='';
SET @parentbigtype='';
SET @sequence = (SELECT IFNULL(MAX(sequence),1) FROM ld_producttoolfield where tabid=@tabid);
SET @tablename = 'ld_cashbill2paymentplan';
SET @sourcemodule = 'Invoice';
INSERT INTO ld_producttoolfield(producttoolfieldid,columnname,allowhide,fieldlabel,defaultvalue,presence,uitype,typeofdata,sequence,tabid,tablename,width,edit_permission,input_type,
fieldid,newline,defaultcolumn,is_checkimportfield,nullfield,referencemodule,datarange,approve_demand,maxrowsshow,bigtype,savedatabase,parentbigtype,sourcemodule)
SELECT @producttoolfieldid,@columnname,@allowhide,@fieldlabel,NULL,0,@uitype,@typeofdata,@sequence+1,@tabid,@tablename,35,0,0,0,0,1,0,1,'','','',0,@bigtype,'yes',@parentbigtype,@sourcemodule from dual
WHERE NOT EXISTS (SELECT 1 FROM ld_producttoolfield WHERE tabid=@tabid AND columnname=@columnname and tablename=@tablename  and sourcemodule=@sourcemodule);

SET @relatedid = (SELECT producttoolfieldid FROM ld_producttoolfield WHERE tabid=@tabid AND columnname=@columnname  and sourcemodule=@sourcemodule LIMIT 1);
INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
SELECT 'zh',@trantable,@tabid,@relatedid,@zh  from dual
WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE languagetype = 'zh' and tabid=@tabid and relateid=@relatedid AND trantable=@trantable);
INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
SELECT 'en',@trantable,@tabid,@relatedid,@en  from dual
WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE languagetype = 'en' and tabid=@tabid and relateid=@relatedid AND trantable=@trantable);

update ld_producttoolfield_seq set id = (select max(producttoolfieldid) from ld_producttoolfield);
delimiter;



SET @producttoolfieldid=(SELECT MAX(producttoolfieldid)+1 FROM ld_producttoolfield);
set @tabid = (select tabid from ld_tab where `name` = 'CashBill');
SET @columnname = 'total';
SET @trantable='ld_producttoolfield';
SET @allowhide = 'no';
SET @fieldlabel = '实际收款金额';
SET @zh='实际收款金额';
SET @en='Actual Receipts';
SET @uitype = 50;
SET @typeofdata='NN~O~25,3';
SET @bigtype='';
SET @parentbigtype='';
SET @sequence = (SELECT IFNULL(MAX(sequence),1) FROM ld_producttoolfield where tabid=@tabid);
SET @tablename = 'ld_cashbill2paymentplan';
SET @sourcemodule = 'Invoice';
INSERT INTO ld_producttoolfield(producttoolfieldid,columnname,allowhide,fieldlabel,defaultvalue,presence,uitype,typeofdata,sequence,tabid,tablename,width,edit_permission,input_type,
fieldid,newline,defaultcolumn,is_checkimportfield,nullfield,referencemodule,datarange,approve_demand,maxrowsshow,bigtype,savedatabase,parentbigtype,sourcemodule)
SELECT @producttoolfieldid,@columnname,@allowhide,@fieldlabel,NULL,0,@uitype,@typeofdata,@sequence+1,@tabid,@tablename,35,1,0,0,1,1,0,1,'','','',0,@bigtype,'yes',@parentbigtype,@sourcemodule from dual
WHERE NOT EXISTS (SELECT 1 FROM ld_producttoolfield WHERE tabid=@tabid AND columnname=@columnname and tablename=@tablename  and sourcemodule=@sourcemodule);

SET @relatedid = (SELECT producttoolfieldid FROM ld_producttoolfield WHERE tabid=@tabid AND columnname=@columnname  and sourcemodule=@sourcemodule LIMIT 1);
INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
SELECT 'zh',@trantable,@tabid,@relatedid,@zh  from dual
WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE languagetype = 'zh' and tabid=@tabid and relateid=@relatedid AND trantable=@trantable);
INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
SELECT 'en',@trantable,@tabid,@relatedid,@en  from dual
WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE languagetype = 'en' and tabid=@tabid and relateid=@relatedid AND trantable=@trantable);

update ld_producttoolfield_seq set id = (select max(producttoolfieldid) from ld_producttoolfield);
delimiter;

SET @tabdetailfieldid=(SELECT MAX(tabdetailfieldid)+1 FROM ld_tabdetailfield);
set @tabid = (select tabid from ld_tab where `name` = 'CashBill');
SET @columnname = 'entitytype';
SET @trantable='ld_tabdetailfield';
SET @allowhide = 'no';
SET @fieldlabel = '源单类型';
SET @zh='源单类型';
SET @en='Link To';
SET @uitype = 'entitytype';
SET @typeofdata='V~O';
SET @bigtype='';
SET @parentbigtype='';
SET @sequence = (SELECT IFNULL(MAX(sequence),1) FROM ld_tabdetailfield where tabid=@tabid);
SET @tablename = 'ld_cashbill2paymentplan';
SET @sourcemodule = 'PaymentPlan';
INSERT INTO ld_tabdetailfield(tabdetailfieldid,columnname,allowhide,fieldlabel,defaultvalue,presence,fieldtype,typeofdata,sequence,tabid,tablename,width,edit_permission,input_type,
fieldid,newline,defaultcolumn,is_checkimportfield,nullfield,referencemodule,datarange,approve_demand,maxrowsshow,bigtype,savedatabase,parentbigtype,sourcemodule)
SELECT @tabdetailfieldid,@columnname,@allowhide,@fieldlabel,NULL,0,@uitype,@typeofdata,@sequence+1,@tabid,@tablename,22,1,0,0,0,1,0,1,'','','',0,@bigtype,'yes',@parentbigtype,@sourcemodule from dual
WHERE NOT EXISTS (SELECT 1 FROM ld_tabdetailfield WHERE tabid=@tabid AND columnname=@columnname and tablename=@tablename and sourcemodule=@sourcemodule);

SET @relatedid = (SELECT tabdetailfieldid FROM ld_tabdetailfield WHERE tabid=@tabid AND columnname=@columnname  and sourcemodule=@sourcemodule LIMIT 1);
INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
SELECT 'zh',@trantable,@tabid,@relatedid,@zh  from dual
WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE languagetype = 'zh' and tabid=@tabid and relateid=@relatedid AND trantable=@trantable);
INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
SELECT 'en',@trantable,@tabid,@relatedid,@en  from dual
WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE languagetype = 'en' and tabid=@tabid and relateid=@relatedid AND trantable=@trantable);
CALL AddColumn(@tablename,@columnname,'varchar',25,'');
update ld_tabdetailfield_seq set id = (select max(tabdetailfieldid) from ld_tabdetailfield);
delimiter;

SET @tabdetailfieldid=(SELECT MAX(tabdetailfieldid)+1 FROM ld_tabdetailfield);
set @tabid = (select tabid from ld_tab where `name` = 'CashBill');
SET @columnname = 'entitytypeid';
SET @trantable='ld_tabdetailfield';
SET @allowhide = 'no';
SET @fieldlabel = '源单';
SET @zh='源单';
SET @en='Orignal Bill';
SET @uitype = 'SelectSource';
SET @typeofdata='V~O~100';
SET @bigtype='selectsource';
SET @parentbigtype='';
SET @sequence = (SELECT IFNULL(MAX(sequence),1) FROM ld_tabdetailfield where tabid=@tabid);
SET @tablename = 'ld_cashbill2paymentplan';
SET @sourcemodule = 'PaymentPlan';
INSERT INTO ld_tabdetailfield(tabdetailfieldid,columnname,allowhide,fieldlabel,defaultvalue,presence,fieldtype,typeofdata,sequence,tabid,tablename,width,edit_permission,input_type,
fieldid,newline,defaultcolumn,is_checkimportfield,nullfield,referencemodule,datarange,approve_demand,maxrowsshow,bigtype,savedatabase,parentbigtype,sourcemodule)
SELECT @tabdetailfieldid,@columnname,@allowhide,@fieldlabel,NULL,0,@uitype,@typeofdata,@sequence+1,@tabid,@tablename,33,1,0,0,0,1,0,1,NULL,NULL,NULL,0,@bigtype,'yes',@parentbigtype,@sourcemodule from dual
WHERE NOT EXISTS (SELECT 1 FROM ld_tabdetailfield WHERE tabid=@tabid AND columnname=@columnname and tablename=@tablename and sourcemodule=@sourcemodule);

SET @relatedid = (SELECT tabdetailfieldid FROM ld_tabdetailfield WHERE tabid=@tabid AND columnname=@columnname and sourcemodule=@sourcemodule LIMIT 1);
INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
SELECT 'zh',@trantable,@tabid,@relatedid,@zh  from dual
WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE languagetype = 'zh' and tabid=@tabid and relateid=@relatedid AND trantable=@trantable);
INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
SELECT 'en',@trantable,@tabid,@relatedid,@en  from dual
WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE languagetype = 'en' and tabid=@tabid and relateid=@relatedid AND trantable=@trantable);
CALL AddColumn(@tablename,@columnname,'int',11,'');
update ld_tabdetailfield_seq set id = (select max(tabdetailfieldid) from ld_tabdetailfield);
delimiter;

SET @tabdetailfieldid=(SELECT MAX(tabdetailfieldid)+1 FROM ld_tabdetailfield);
set @tabid = (select tabid from ld_tab where `name` = 'CashBill');
SET @columnname = 'periodtime';
SET @trantable='ld_tabdetailfield';
SET @allowhide = 'yes';
SET @fieldlabel = '期次';
SET @zh='期次';
SET @en='Stages';
SET @uitype = 'Text';
SET @typeofdata='V~O';
SET @bigtype='relatedmodulefield';
SET @parentbigtype='picklist';
SET @sequence = (SELECT IFNULL(MAX(sequence),1) FROM ld_tabdetailfield where tabid=@tabid);
SET @tablename = 'ld_cashbill2paymentplan';
SET @sourcemodule = 'PaymentPlan';
INSERT INTO ld_tabdetailfield(tabdetailfieldid,columnname,allowhide,fieldlabel,defaultvalue,presence,fieldtype,typeofdata,sequence,tabid,tablename,width,edit_permission,input_type,
fieldid,newline,defaultcolumn,is_checkimportfield,nullfield,referencemodule,datarange,approve_demand,maxrowsshow,bigtype,savedatabase,parentbigtype,sourcemodule)
SELECT @tabdetailfieldid,@columnname,@allowhide,@fieldlabel,NULL,0,@uitype,@typeofdata,@sequence+1,@tabid,@tablename,30,1,0,0,0,1,0,1,NULL,NULL,NULL,0,@bigtype,'no',@parentbigtype,@sourcemodule from dual
WHERE NOT EXISTS (SELECT 1 FROM ld_tabdetailfield WHERE tabid=@tabid AND columnname=@columnname and tablename=@tablename and sourcemodule=@sourcemodule);

SET @relatedid = (SELECT tabdetailfieldid FROM ld_tabdetailfield WHERE tabid=@tabid AND columnname=@columnname and sourcemodule=@sourcemodule LIMIT 1);
INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
SELECT 'zh',@trantable,@tabid,@relatedid,@zh  from dual
WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE languagetype = 'zh' and tabid=@tabid and relateid=@relatedid AND trantable=@trantable);
INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
SELECT 'en',@trantable,@tabid,@relatedid,@en  from dual
WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE languagetype = 'en' and tabid=@tabid and relateid=@relatedid AND trantable=@trantable);
CALL AddColumn(@tablename,@columnname,'varchar','20','');
update ld_tabdetailfield_seq set id = (select max(tabdetailfieldid) from ld_tabdetailfield);
delimiter;

SET @tabdetailfieldid=(SELECT MAX(tabdetailfieldid)+1 FROM ld_tabdetailfield);
set @tabid = (select tabid from ld_tab where `name` = 'CashBill');
SET @columnname = 'plandate';
SET @trantable='ld_tabdetailfield';
SET @allowhide = 'yes';
SET @fieldlabel = '计划收款日期';
SET @zh='计划收款日期';
SET @en='Plan Date';
SET @uitype = 'Date_Ymd';
SET @typeofdata='D~O';
SET @bigtype='relatedmodulefield';
SET @parentbigtype='date';
SET @sequence = (SELECT IFNULL(MAX(sequence),1) FROM ld_tabdetailfield where tabid=@tabid);
SET @tablename = 'ld_cashbill2paymentplan';
SET @sourcemodule = 'PaymentPlan';
INSERT INTO ld_tabdetailfield(tabdetailfieldid,columnname,allowhide,fieldlabel,defaultvalue,presence,fieldtype,typeofdata,sequence,tabid,tablename,width,edit_permission,input_type,
fieldid,newline,defaultcolumn,is_checkimportfield,nullfield,referencemodule,datarange,approve_demand,maxrowsshow,bigtype,savedatabase,parentbigtype,sourcemodule)
SELECT @tabdetailfieldid,@columnname,@allowhide,@fieldlabel,NULL,0,@uitype,@typeofdata,@sequence+1,@tabid,@tablename,30,1,0,0,0,1,0,1,NULL,NULL,NULL,0,@bigtype,'no',@parentbigtype,@sourcemodule from dual
WHERE NOT EXISTS (SELECT 1 FROM ld_tabdetailfield WHERE tabid=@tabid AND columnname=@columnname and tablename=@tablename and sourcemodule=@sourcemodule);

SET @relatedid = (SELECT tabdetailfieldid FROM ld_tabdetailfield WHERE tabid=@tabid AND columnname=@columnname and sourcemodule=@sourcemodule LIMIT 1);
INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
SELECT 'zh',@trantable,@tabid,@relatedid,@zh  from dual
WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE languagetype = 'zh' and tabid=@tabid and relateid=@relatedid AND trantable=@trantable);
INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
SELECT 'en',@trantable,@tabid,@relatedid,@en  from dual
WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE languagetype = 'en' and tabid=@tabid and relateid=@relatedid AND trantable=@trantable);
CALL AddColumn(@tablename,@columnname,'date','','');
update ld_tabdetailfield_seq set id = (select max(tabdetailfieldid) from ld_tabdetailfield);
delimiter;

SET @tabdetailfieldid=(SELECT MAX(tabdetailfieldid)+1 FROM ld_tabdetailfield);
set @tabid = (select tabid from ld_tab where `name` = 'CashBill');
SET @columnname = 'plan_amount';
SET @trantable='ld_tabdetailfield';
SET @allowhide = 'yes';
SET @fieldlabel = '计划收款金额';
SET @zh='计划收款金额';
SET @en='Plan Amount';
SET @uitype = 'Amount';
SET @typeofdata='NN~O';
SET @bigtype='relatedmodulefield';
SET @parentbigtype='currency';
SET @sequence = (SELECT IFNULL(MAX(sequence),1) FROM ld_tabdetailfield where tabid=@tabid);
SET @tablename = 'ld_cashbill2paymentplan';
SET @sourcemodule = 'PaymentPlan';
INSERT INTO ld_tabdetailfield(tabdetailfieldid,columnname,allowhide,fieldlabel,defaultvalue,presence,fieldtype,typeofdata,sequence,tabid,tablename,width,edit_permission,input_type,
fieldid,newline,defaultcolumn,is_checkimportfield,nullfield,referencemodule,datarange,approve_demand,maxrowsshow,bigtype,savedatabase,parentbigtype,sourcemodule)
SELECT @tabdetailfieldid,@columnname,@allowhide,@fieldlabel,NULL,0,@uitype,@typeofdata,@sequence+1,@tabid,@tablename,22,1,0,0,0,1,0,1,NULL,NULL,NULL,0,@bigtype,'no',@parentbigtype,@sourcemodule from dual
WHERE NOT EXISTS (SELECT 1 FROM ld_tabdetailfield WHERE tabid=@tabid AND columnname=@columnname and tablename=@tablename and sourcemodule=@sourcemodule);

SET @relatedid = (SELECT tabdetailfieldid FROM ld_tabdetailfield WHERE tabid=@tabid AND columnname=@columnname and sourcemodule=@sourcemodule LIMIT 1);
INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
SELECT 'zh',@trantable,@tabid,@relatedid,@zh  from dual
WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE languagetype = 'zh' and tabid=@tabid and relateid=@relatedid AND trantable=@trantable);
INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
SELECT 'en',@trantable,@tabid,@relatedid,@en  from dual
WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE languagetype = 'en' and tabid=@tabid and relateid=@relatedid AND trantable=@trantable);
CALL AddColumn(@tablename,@columnname,'decimal','25','0.00');
update ld_tabdetailfield_seq set id = (select max(tabdetailfieldid) from ld_tabdetailfield);
delimiter;


SET @tabdetailfieldid=(SELECT MAX(tabdetailfieldid)+1 FROM ld_tabdetailfield);
set @tabid = (select tabid from ld_tab where `name` = 'CashBill');
SET @columnname = 'received_amount';
SET @trantable='ld_tabdetailfield';
SET @allowhide = 'yes';
SET @fieldlabel = '已收总额';
SET @zh='已收总额';
SET @en='Received Amount';
SET @uitype = 'Amount';
SET @typeofdata='NN~O';
SET @bigtype='relatedmodulefield';
SET @parentbigtype='currency';
SET @sequence = (SELECT IFNULL(MAX(sequence),1) FROM ld_tabdetailfield where tabid=@tabid);
SET @tablename = 'ld_cashbill2paymentplan';
SET @sourcemodule = 'PaymentPlan';
INSERT INTO ld_tabdetailfield(tabdetailfieldid,columnname,allowhide,fieldlabel,defaultvalue,presence,fieldtype,typeofdata,sequence,tabid,tablename,width,edit_permission,input_type,
fieldid,newline,defaultcolumn,is_checkimportfield,nullfield,referencemodule,datarange,approve_demand,maxrowsshow,bigtype,savedatabase,parentbigtype,sourcemodule)
SELECT @tabdetailfieldid,@columnname,@allowhide,@fieldlabel,NULL,0,@uitype,@typeofdata,@sequence+1,@tabid,@tablename,22,1,0,0,0,1,0,1,NULL,NULL,NULL,0,@bigtype,'no',@parentbigtype,@sourcemodule from dual
WHERE NOT EXISTS (SELECT 1 FROM ld_tabdetailfield WHERE tabid=@tabid AND columnname=@columnname and tablename=@tablename and sourcemodule=@sourcemodule);

SET @relatedid = (SELECT tabdetailfieldid FROM ld_tabdetailfield WHERE tabid=@tabid AND columnname=@columnname and sourcemodule=@sourcemodule LIMIT 1);
INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
SELECT 'zh',@trantable,@tabid,@relatedid,@zh  from dual
WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE languagetype = 'zh' and tabid=@tabid and relateid=@relatedid AND trantable=@trantable);
INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
SELECT 'en',@trantable,@tabid,@relatedid,@en  from dual
WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE languagetype = 'en' and tabid=@tabid and relateid=@relatedid AND trantable=@trantable);
CALL AddColumn(@tablename,@columnname,'decimal','25','0.00');
update ld_tabdetailfield_seq set id = (select max(tabdetailfieldid) from ld_tabdetailfield);
delimiter;

SET @tabdetailfieldid=(SELECT MAX(tabdetailfieldid)+1 FROM ld_tabdetailfield);
set @tabid = (select tabid from ld_tab where `name` = 'CashBill');
SET @columnname = 'plan_contract';
SET @trantable='ld_tabdetailfield';
SET @allowhide = 'yes';
SET @fieldlabel = '合同信息';
SET @zh='合同信息';
SET @en='Contract Info';
SET @uitype = 'Reference';
SET @typeofdata='V~O';
SET @bigtype='relatedmodulefield';
SET @parentbigtype='selectsource';
SET @sequence = (SELECT IFNULL(MAX(sequence),1) FROM ld_tabdetailfield where tabid=@tabid);
SET @tablename = 'ld_cashbill2paymentplan';
SET @sourcemodule = 'PaymentPlan';
INSERT INTO ld_tabdetailfield(tabdetailfieldid,columnname,allowhide,fieldlabel,defaultvalue,presence,fieldtype,typeofdata,sequence,tabid,tablename,width,edit_permission,input_type,
fieldid,newline,defaultcolumn,is_checkimportfield,nullfield,referencemodule,datarange,approve_demand,maxrowsshow,bigtype,savedatabase,parentbigtype,sourcemodule)
SELECT @tabdetailfieldid,@columnname,@allowhide,@fieldlabel,NULL,0,@uitype,@typeofdata,@sequence+1,@tabid,@tablename,30,1,0,0,0,1,0,1,NULL,NULL,NULL,0,@bigtype,'no',@parentbigtype,@sourcemodule from dual
WHERE NOT EXISTS (SELECT 1 FROM ld_tabdetailfield WHERE tabid=@tabid AND columnname=@columnname and tablename=@tablename and sourcemodule=@sourcemodule);

SET @relatedid = (SELECT tabdetailfieldid FROM ld_tabdetailfield WHERE tabid=@tabid AND columnname=@columnname and sourcemodule=@sourcemodule LIMIT 1);
INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
SELECT 'zh',@trantable,@tabid,@relatedid,@zh  from dual
WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE languagetype = 'zh' and tabid=@tabid and relateid=@relatedid AND trantable=@trantable);
INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
SELECT 'en',@trantable,@tabid,@relatedid,@en  from dual
WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE languagetype = 'en' and tabid=@tabid and relateid=@relatedid AND trantable=@trantable);
CALL AddColumn(@tablename,@columnname,'int','11','');
update ld_tabdetailfield_seq set id = (select max(tabdetailfieldid) from ld_tabdetailfield);
delimiter;


SET @tabdetailfieldid=(SELECT MAX(tabdetailfieldid)+1 FROM ld_tabdetailfield);
set @tabid = (select tabid from ld_tab where `name` = 'CashBill');
SET @columnname = 'plan_contract_amount';
SET @trantable='ld_tabdetailfield';
SET @allowhide = 'yes';
SET @fieldlabel = '合同金额';
SET @zh='合同金额';
SET @en='Contract Amount';
SET @uitype = 'Amount';
SET @typeofdata='V~O';
SET @bigtype='Amount';
SET @parentbigtype='';
SET @sequence = (SELECT IFNULL(MAX(sequence),1) FROM ld_tabdetailfield where tabid=@tabid);
SET @tablename = 'ld_cashbill2paymentplan';
SET @sourcemodule = 'PaymentPlan';
INSERT INTO ld_tabdetailfield(tabdetailfieldid,columnname,allowhide,fieldlabel,defaultvalue,presence,fieldtype,typeofdata,sequence,tabid,tablename,width,edit_permission,input_type,
fieldid,newline,defaultcolumn,is_checkimportfield,nullfield,referencemodule,datarange,approve_demand,maxrowsshow,bigtype,savedatabase,parentbigtype,sourcemodule)
SELECT @tabdetailfieldid,@columnname,@allowhide,@fieldlabel,NULL,0,@uitype,@typeofdata,@sequence+1,@tabid,@tablename,22,1,0,0,0,1,0,1,NULL,NULL,NULL,0,@bigtype,'no',@parentbigtype,@sourcemodule from dual
WHERE NOT EXISTS (SELECT 1 FROM ld_tabdetailfield WHERE tabid=@tabid AND columnname=@columnname and tablename=@tablename and sourcemodule=@sourcemodule);

SET @relatedid = (SELECT tabdetailfieldid FROM ld_tabdetailfield WHERE tabid=@tabid AND columnname=@columnname and sourcemodule=@sourcemodule LIMIT 1);
INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
SELECT 'zh',@trantable,@tabid,@relatedid,@zh  from dual
WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE languagetype = 'zh' and tabid=@tabid and relateid=@relatedid AND trantable=@trantable);
INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
SELECT 'en',@trantable,@tabid,@relatedid,@en  from dual
WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE languagetype = 'en' and tabid=@tabid and relateid=@relatedid AND trantable=@trantable);
CALL AddColumn(@tablename,@columnname,'decimal','25','0.00');
update ld_tabdetailfield_seq set id = (select max(tabdetailfieldid) from ld_tabdetailfield);
delimiter;

SET @tabdetailfieldid=(SELECT MAX(tabdetailfieldid)+1 FROM ld_tabdetailfield);
set @tabid = (select tabid from ld_tab where `name` = 'CashBill');
SET @columnname = 'plan_latestinvoicedate';
SET @trantable='ld_tabdetailfield';
SET @allowhide = 'yes';
SET @fieldlabel = '最新开票日期';
SET @zh='最新开票日期';
SET @en='Latest Invoice Date';
SET @uitype = 'Date_Ymd';
SET @typeofdata='D~O';
SET @bigtype='Date';
SET @parentbigtype='';
SET @sequence = (SELECT IFNULL(MAX(sequence),1) FROM ld_tabdetailfield where tabid=@tabid);
SET @tablename = 'ld_cashbill2paymentplan';
SET @sourcemodule = 'PaymentPlan';
INSERT INTO ld_tabdetailfield(tabdetailfieldid,columnname,allowhide,fieldlabel,defaultvalue,presence,fieldtype,typeofdata,sequence,tabid,tablename,width,edit_permission,input_type,
fieldid,newline,defaultcolumn,is_checkimportfield,nullfield,referencemodule,datarange,approve_demand,maxrowsshow,bigtype,savedatabase,parentbigtype,sourcemodule)
SELECT @tabdetailfieldid,@columnname,@allowhide,@fieldlabel,NULL,0,@uitype,@typeofdata,@sequence+1,@tabid,@tablename,30,1,0,0,0,1,0,1,NULL,NULL,NULL,0,@bigtype,'no',@parentbigtype,@sourcemodule from dual
WHERE NOT EXISTS (SELECT 1 FROM ld_tabdetailfield WHERE tabid=@tabid AND columnname=@columnname and tablename=@tablename and sourcemodule=@sourcemodule);

SET @relatedid = (SELECT tabdetailfieldid FROM ld_tabdetailfield WHERE tabid=@tabid AND columnname=@columnname and sourcemodule=@sourcemodule LIMIT 1);
INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
SELECT 'zh',@trantable,@tabid,@relatedid,@zh  from dual
WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE languagetype = 'zh' and tabid=@tabid and relateid=@relatedid AND trantable=@trantable);
INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
SELECT 'en',@trantable,@tabid,@relatedid,@en  from dual
WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE languagetype = 'en' and tabid=@tabid and relateid=@relatedid AND trantable=@trantable);
CALL AddColumn(@tablename,@columnname,'date','','');
update ld_tabdetailfield_seq set id = (select max(tabdetailfieldid) from ld_tabdetailfield);
delimiter;

SET @tabdetailfieldid=(SELECT MAX(tabdetailfieldid)+1 FROM ld_tabdetailfield);
set @tabid = (select tabid from ld_tab where `name` = 'CashBill');
SET @columnname = 'plan_invoicetotal';
SET @trantable='ld_tabdetailfield';
SET @allowhide = 'yes';
SET @fieldlabel = '已开票总额';
SET @zh='已开票总额';
SET @en='Invoice Total';
SET @uitype = 'Amount';
SET @typeofdata='V~O';
SET @bigtype='amount';
SET @parentbigtype='';
SET @sequence = (SELECT IFNULL(MAX(sequence),1) FROM ld_tabdetailfield where tabid=@tabid);
SET @tablename = 'ld_cashbill2paymentplan';
SET @sourcemodule = 'PaymentPlan';
INSERT INTO ld_tabdetailfield(tabdetailfieldid,columnname,allowhide,fieldlabel,defaultvalue,presence,fieldtype,typeofdata,sequence,tabid,tablename,width,edit_permission,input_type,
fieldid,newline,defaultcolumn,is_checkimportfield,nullfield,referencemodule,datarange,approve_demand,maxrowsshow,bigtype,savedatabase,parentbigtype,sourcemodule)
SELECT @tabdetailfieldid,@columnname,@allowhide,@fieldlabel,NULL,0,@uitype,@typeofdata,@sequence+1,@tabid,@tablename,22,1,0,0,0,1,0,1,NULL,NULL,NULL,0,@bigtype,'no',@parentbigtype,@sourcemodule from dual
WHERE NOT EXISTS (SELECT 1 FROM ld_tabdetailfield WHERE tabid=@tabid AND columnname=@columnname and tablename=@tablename and sourcemodule=@sourcemodule);

SET @relatedid = (SELECT tabdetailfieldid FROM ld_tabdetailfield WHERE tabid=@tabid AND columnname=@columnname and sourcemodule=@sourcemodule LIMIT 1);
INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
SELECT 'zh',@trantable,@tabid,@relatedid,@zh  from dual
WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE languagetype = 'zh' and tabid=@tabid and relateid=@relatedid AND trantable=@trantable);
INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
SELECT 'en',@trantable,@tabid,@relatedid,@en  from dual
WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE languagetype = 'en' and tabid=@tabid and relateid=@relatedid AND trantable=@trantable);
CALL AddColumn(@tablename,@columnname,'decimal','25','0.00');
update ld_tabdetailfield_seq set id = (select max(tabdetailfieldid) from ld_tabdetailfield);
delimiter;

SET @tabdetailfieldid=(SELECT MAX(tabdetailfieldid)+1 FROM ld_tabdetailfield);
set @tabid = (select tabid from ld_tab where `name` = 'CashBill');
SET @columnname = 'plan_latestcollectiondate';
SET @trantable='ld_tabdetailfield';
SET @allowhide = 'yes';
SET @fieldlabel = '最近收款日期';
SET @zh='最近收款日期';
SET @en='Latest Collection Date';
SET @uitype = 'Date_Ymd';
SET @typeofdata='D~O';
SET @bigtype='Date';
SET @parentbigtype='';
SET @sequence = (SELECT IFNULL(MAX(sequence),1) FROM ld_tabdetailfield where tabid=@tabid);
SET @tablename = 'ld_cashbill2paymentplan';
SET @sourcemodule = 'PaymentPlan';
INSERT INTO ld_tabdetailfield(tabdetailfieldid,columnname,allowhide,fieldlabel,defaultvalue,presence,fieldtype,typeofdata,sequence,tabid,tablename,width,edit_permission,input_type,
fieldid,newline,defaultcolumn,is_checkimportfield,nullfield,referencemodule,datarange,approve_demand,maxrowsshow,bigtype,savedatabase,parentbigtype,sourcemodule)
SELECT @tabdetailfieldid,@columnname,@allowhide,@fieldlabel,NULL,0,@uitype,@typeofdata,@sequence+1,@tabid,@tablename,30,1,0,0,0,1,0,1,NULL,NULL,NULL,0,@bigtype,'no',@parentbigtype,@sourcemodule from dual
WHERE NOT EXISTS (SELECT 1 FROM ld_tabdetailfield WHERE tabid=@tabid AND columnname=@columnname and tablename=@tablename and sourcemodule=@sourcemodule);

SET @relatedid = (SELECT tabdetailfieldid FROM ld_tabdetailfield WHERE tabid=@tabid AND columnname=@columnname and sourcemodule=@sourcemodule LIMIT 1);
INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
SELECT 'zh',@trantable,@tabid,@relatedid,@zh  from dual
WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE languagetype = 'zh' and tabid=@tabid and relateid=@relatedid AND trantable=@trantable);
INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
SELECT 'en',@trantable,@tabid,@relatedid,@en  from dual
WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE languagetype = 'en' and tabid=@tabid and relateid=@relatedid AND trantable=@trantable);
CALL AddColumn(@tablename,@columnname,'date','','');
update ld_tabdetailfield_seq set id = (select max(tabdetailfieldid) from ld_tabdetailfield);
delimiter;

SET @tabdetailfieldid=(SELECT MAX(tabdetailfieldid)+1 FROM ld_tabdetailfield);
set @tabid = (select tabid from ld_tab where `name` = 'CashBill');
SET @columnname = 'plan_orderreceivedamount';
SET @trantable='ld_tabdetailfield';
SET @allowhide = 'yes';
SET @fieldlabel = '合同已收总额';
SET @zh='合同已收总额';
SET @en='Received Amount';
SET @uitype = 'Amount';
SET @typeofdata='V~O';
SET @bigtype='amount';
SET @parentbigtype='';
SET @sequence = (SELECT IFNULL(MAX(sequence),1) FROM ld_tabdetailfield where tabid=@tabid);
SET @tablename = 'ld_cashbill2paymentplan';
SET @sourcemodule = 'PaymentPlan';
INSERT INTO ld_tabdetailfield(tabdetailfieldid,columnname,allowhide,fieldlabel,defaultvalue,presence,fieldtype,typeofdata,sequence,tabid,tablename,width,edit_permission,input_type,
fieldid,newline,defaultcolumn,is_checkimportfield,nullfield,referencemodule,datarange,approve_demand,maxrowsshow,bigtype,savedatabase,parentbigtype,sourcemodule)
SELECT @tabdetailfieldid,@columnname,@allowhide,@fieldlabel,NULL,0,@uitype,@typeofdata,@sequence+1,@tabid,@tablename,22,1,0,0,0,1,0,1,NULL,NULL,NULL,0,@bigtype,'no',@parentbigtype,@sourcemodule from dual
WHERE NOT EXISTS (SELECT 1 FROM ld_tabdetailfield WHERE tabid=@tabid AND columnname=@columnname and tablename=@tablename and sourcemodule=@sourcemodule);

SET @relatedid = (SELECT tabdetailfieldid FROM ld_tabdetailfield WHERE tabid=@tabid AND columnname=@columnname and sourcemodule=@sourcemodule LIMIT 1);
INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
SELECT 'zh',@trantable,@tabid,@relatedid,@zh  from dual
WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE languagetype = 'zh' and tabid=@tabid and relateid=@relatedid AND trantable=@trantable);
INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
SELECT 'en',@trantable,@tabid,@relatedid,@en  from dual
WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE languagetype = 'en' and tabid=@tabid and relateid=@relatedid AND trantable=@trantable);
CALL AddColumn(@tablename,@columnname,'decimal','25','0.00');
update ld_tabdetailfield_seq set id = (select max(tabdetailfieldid) from ld_tabdetailfield);
delimiter;

SET @tabdetailfieldid=(SELECT MAX(tabdetailfieldid)+1 FROM ld_tabdetailfield);
set @tabid = (select tabid from ld_tab where `name` = 'CashBill');
SET @columnname = 'amount';
SET @trantable='ld_tabdetailfield';
SET @allowhide = 'no';
SET @fieldlabel = '本次收款金额';
SET @zh='本次收款金额';
SET @en='The amount collected';
SET @uitype = 'Amount';
SET @typeofdata='N~O~25,6';
SET @bigtype='amount';
SET @parentbigtype='';
SET @sequence = (SELECT IFNULL(MAX(sequence),1) FROM ld_tabdetailfield where tabid=@tabid);
SET @tablename = 'ld_cashbill2paymentplan';
SET @sourcemodule = 'PaymentPlan';
INSERT INTO ld_tabdetailfield(tabdetailfieldid,columnname,allowhide,fieldlabel,defaultvalue,presence,fieldtype,typeofdata,sequence,tabid,tablename,width,edit_permission,input_type,
fieldid,newline,defaultcolumn,is_checkimportfield,nullfield,referencemodule,datarange,approve_demand,maxrowsshow,bigtype,savedatabase,parentbigtype,sourcemodule)
SELECT @tabdetailfieldid,@columnname,@allowhide,@fieldlabel,NULL,0,@uitype,@typeofdata,@sequence+1,@tabid,@tablename,35,0,0,0,0,1,0,1,NULL,NULL,NULL,0,@bigtype,'yes',@parentbigtype,@sourcemodule from dual
WHERE NOT EXISTS (SELECT 1 FROM ld_tabdetailfield WHERE tabid=@tabid AND columnname=@columnname and tablename=@tablename and sourcemodule=@sourcemodule);

SET @relatedid = (SELECT tabdetailfieldid FROM ld_tabdetailfield WHERE tabid=@tabid AND columnname=@columnname and sourcemodule=@sourcemodule LIMIT 1);
INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
SELECT 'zh',@trantable,@tabid,@relatedid,@zh  from dual
WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE languagetype = 'zh' and tabid=@tabid and relateid=@relatedid AND trantable=@trantable);
INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
SELECT 'en',@trantable,@tabid,@relatedid,@en  from dual
WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE languagetype = 'en' and tabid=@tabid and relateid=@relatedid AND trantable=@trantable);
CALL AddColumn(@tablename,@columnname,'decimal','25','0.00');
update ld_tabdetailfield_seq set id = (select max(tabdetailfieldid) from ld_tabdetailfield);
delimiter;

SET @tabdetailfieldid=(SELECT MAX(tabdetailfieldid)+1 FROM ld_tabdetailfield);
set @tabid = (select tabid from ld_tab where `name` = 'CashBill');
SET @columnname = 'total';
SET @trantable='ld_tabdetailfield';
SET @allowhide = 'no';
SET @fieldlabel = '实际收款金额';
SET @zh='实际收款金额';
SET @en='Actual Receipts';
SET @uitype = 'Amount';
SET @typeofdata='N~O~25,6';
SET @bigtype='';
SET @parentbigtype='';
SET @sequence = (SELECT IFNULL(MAX(sequence),1) FROM ld_tabdetailfield where tabid=@tabid);
SET @tablename = 'ld_cashbill2paymentplan';
SET @sourcemodule = 'PaymentPlan';
INSERT INTO ld_tabdetailfield(tabdetailfieldid,columnname,allowhide,fieldlabel,defaultvalue,presence,fieldtype,typeofdata,sequence,tabid,tablename,width,edit_permission,input_type,
fieldid,newline,defaultcolumn,is_checkimportfield,nullfield,referencemodule,datarange,approve_demand,maxrowsshow,bigtype,savedatabase,parentbigtype,sourcemodule)
SELECT @tabdetailfieldid,@columnname,@allowhide,@fieldlabel,NULL,0,@uitype,@typeofdata,@sequence+1,@tabid,@tablename,22,1,0,0,1,1,0,1,NULL,NULL,NULL,0,@bigtype,'yes',@parentbigtype,@sourcemodule from dual
WHERE NOT EXISTS (SELECT 1 FROM ld_tabdetailfield WHERE tabid=@tabid AND columnname=@columnname and tablename=@tablename and sourcemodule=@sourcemodule);

SET @relatedid = (SELECT tabdetailfieldid FROM ld_tabdetailfield WHERE tabid=@tabid AND columnname=@columnname and sourcemodule=@sourcemodule LIMIT 1);
INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
SELECT 'zh',@trantable,@tabid,@relatedid,@zh  from dual
WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE languagetype = 'zh' and tabid=@tabid and relateid=@relatedid AND trantable=@trantable);
INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
SELECT 'en',@trantable,@tabid,@relatedid,@en  from dual
WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE languagetype = 'en' and tabid=@tabid and relateid=@relatedid AND trantable=@trantable);
CALL AddColumn(@tablename,@columnname,'decimal','25','0.00');
update ld_tabdetailfield_seq set id = (select max(tabdetailfieldid) from ld_tabdetailfield);
delimiter;


SET @modulename = 'CashBill';
SET @trigger_columnname = 'entitytypeid';
SET @effect_columnname = 'billdate';
SET @curmodule_columninfo = 'billdate';
SET @fromvalue_type = 'selectsource';
SET @fromvalue_info = '[{"module":"SalesOrder","column":"signed_data","columntype":"main"},{"module":"ServiceContracts","column":"due_date","columntype":"main"},{"module":"OutboundOrder","column":"outdate","columntype":"main"},{"module":"Invoice","column":"invoicedate","columntype":"main"}]';
SET @frommodule = '';
INSERT INTO ld_related_detailfield(modulename,trigger_columnname,effect_columnname,curmodule_columninfo,fromvalue_type,fromvalue_info,frommodule)
SELECT @modulename,@trigger_columnname,@effect_columnname,@curmodule_columninfo,@fromvalue_type,@fromvalue_info,@frommodule  from dual
WHERE NOT EXISTS (SELECT 1 FROM ld_related_detailfield WHERE modulename = @modulename and trigger_columnname=@trigger_columnname and effect_columnname=@effect_columnname AND fromvalue_type=@fromvalue_type);
delimiter;
SET @modulename = 'CashBill';
SET @trigger_columnname = 'entitytypeid';
SET @effect_columnname = 'source_total';
SET @curmodule_columninfo = 'source_total';
SET @fromvalue_type = 'selectsource';
SET @fromvalue_info = '[{"module":"SalesOrder","column":"total","columntype":"main"},{"module":"ServiceContracts","column":"total","columntype":"main"},{"module":"OutboundOrder","column":"total","columntype":"main"},{"module":"Invoice","column":"total","columntype":"main"}]';
SET @frommodule = '';
INSERT INTO ld_related_detailfield(modulename,trigger_columnname,effect_columnname,curmodule_columninfo,fromvalue_type,fromvalue_info,frommodule)
SELECT @modulename,@trigger_columnname,@effect_columnname,@curmodule_columninfo,@fromvalue_type,@fromvalue_info,@frommodule  from dual
WHERE NOT EXISTS (SELECT 1 FROM ld_related_detailfield WHERE modulename = @modulename and trigger_columnname=@trigger_columnname and effect_columnname=@effect_columnname AND fromvalue_type=@fromvalue_type);
delimiter;
SET @modulename = 'CashBill';
SET @trigger_columnname = 'entitytypeid';
SET @effect_columnname = 'lastcashbilldate';
SET @curmodule_columninfo = 'lastcashbilldate';
SET @fromvalue_type = 'selectsource';
SET @fromvalue_info = '[{"module":"SalesOrder","column":"cashbilldate","columntype":"main"},{"module":"ServiceContracts","column":"cashbilldate","columntype":"main"}]';
SET @frommodule = '';
INSERT INTO ld_related_detailfield(modulename,trigger_columnname,effect_columnname,curmodule_columninfo,fromvalue_type,fromvalue_info,frommodule)
SELECT @modulename,@trigger_columnname,@effect_columnname,@curmodule_columninfo,@fromvalue_type,@fromvalue_info,@frommodule  from dual
WHERE NOT EXISTS (SELECT 1 FROM ld_related_detailfield WHERE modulename = @modulename and trigger_columnname=@trigger_columnname and effect_columnname=@effect_columnname AND fromvalue_type=@fromvalue_type);
delimiter;
SET @modulename = 'CashBill';
SET @trigger_columnname = 'entitytypeid';
SET @effect_columnname = 'received_amount';
SET @curmodule_columninfo = 'received_amount';
SET @fromvalue_type = 'selectsource';
SET @fromvalue_info = '[{"module":"SalesOrder","column":"received_amount","columntype":"main"},{"module":"ServiceContracts","column":"received_amount","columntype":"detail"},{"module":"OutboundOrder","column":"received_amount","columntype":"main"},{"module":"Invoice","column":"actualamount","columntype":"main"},{"module":"PaymentPlan","column":"actualamount","columntype":"main"}]';
SET @frommodule = '';
INSERT INTO ld_related_detailfield(modulename,trigger_columnname,effect_columnname,curmodule_columninfo,fromvalue_type,fromvalue_info,frommodule)
SELECT @modulename,@trigger_columnname,@effect_columnname,@curmodule_columninfo,@fromvalue_type,@fromvalue_info,@frommodule  from dual
WHERE NOT EXISTS (SELECT 1 FROM ld_related_detailfield WHERE modulename = @modulename and trigger_columnname=@trigger_columnname and effect_columnname=@effect_columnname AND fromvalue_type=@fromvalue_type);
delimiter;

SET @modulename = 'CashBill';
SET @trigger_columnname = 'entitytypeid';
SET @effect_columnname = 'productsourcetype';
SET @curmodule_columninfo = 'productsourcetype';
SET @fromvalue_type = 'selectsource';
SET @fromvalue_info = '[{"module":"SalesOrder","column":"entitytype","columntype":"detail"},{"module":"OutboundOrder","column":"entitytypeid","columntype":"detail"},{"module":"Invoice","column":"entitytypeid","columntype":"detail"}]';
SET @frommodule = '';
INSERT INTO ld_related_detailfield(modulename,trigger_columnname,effect_columnname,curmodule_columninfo,fromvalue_type,fromvalue_info,frommodule)
SELECT @modulename,@trigger_columnname,@effect_columnname,@curmodule_columninfo,@fromvalue_type,@fromvalue_info,@frommodule  from dual
WHERE NOT EXISTS (SELECT 1 FROM ld_related_detailfield WHERE modulename = @modulename and trigger_columnname=@trigger_columnname and effect_columnname=@effect_columnname AND fromvalue_type=@fromvalue_type);
delimiter;

SET @modulename = 'CashBill';
SET @trigger_columnname = 'entitytypeid';
SET @effect_columnname = 'productsourceid';
SET @curmodule_columninfo = 'productsourceid';
SET @fromvalue_type = 'selectsource';
SET @fromvalue_info = '[{"module":"SalesOrder","column":"entitytypeid","columntype":"detail"},{"module":"OutboundOrder","column":"entitytypeid","columntype":"detail"},{"module":"Invoice","column":"entitytypeid","columntype":"detail"}]';
SET @frommodule = '';
INSERT INTO ld_related_detailfield(modulename,trigger_columnname,effect_columnname,curmodule_columninfo,fromvalue_type,fromvalue_info,frommodule)
SELECT @modulename,@trigger_columnname,@effect_columnname,@curmodule_columninfo,@fromvalue_type,@fromvalue_info,@frommodule  from dual
WHERE NOT EXISTS (SELECT 1 FROM ld_related_detailfield WHERE modulename = @modulename and trigger_columnname=@trigger_columnname and effect_columnname=@effect_columnname AND fromvalue_type=@fromvalue_type);
delimiter;

SET @modulename = 'CashBill';
SET @trigger_columnname = 'entitytypeid';
SET @effect_columnname = 'product_received_amount';
SET @curmodule_columninfo = 'product_received_amount';
SET @fromvalue_type = 'selectsource';
SET @fromvalue_info = '[{"module":"SalesOrder","column":"havereceivedamount","columntype":"detail"},{"module":"ServiceContracts","column":"havereceivedamount","columntype":"detail"},{"module":"OutboundOrder","column":"havereceivedamount","columntype":"detail"},{"module":"Invoice","column":"havereceivedamount","columntype":"detail"}]';
SET @frommodule = '';
INSERT INTO ld_related_detailfield(modulename,trigger_columnname,effect_columnname,curmodule_columninfo,fromvalue_type,fromvalue_info,frommodule)
SELECT @modulename,@trigger_columnname,@effect_columnname,@curmodule_columninfo,@fromvalue_type,@fromvalue_info,@frommodule  from dual
WHERE NOT EXISTS (SELECT 1 FROM ld_related_detailfield WHERE modulename = @modulename and trigger_columnname=@trigger_columnname and effect_columnname=@effect_columnname AND fromvalue_type=@fromvalue_type);
delimiter;

SET @modulename = 'CashBill';
SET @trigger_columnname = 'entitytypeid';
SET @effect_columnname = 'tablesourcetype';
SET @curmodule_columninfo = 'tablesourcetype';
SET @fromvalue_type = 'selectsource';
SET @fromvalue_info = '[{"module":"OutboundOrder","column":"source_list","columntype":"main"},{"module":"Invoice","column":"source_list","columntype":"main"}]';
SET @frommodule = '';
INSERT INTO ld_related_detailfield(modulename,trigger_columnname,effect_columnname,curmodule_columninfo,fromvalue_type,fromvalue_info,frommodule)
SELECT @modulename,@trigger_columnname,@effect_columnname,@curmodule_columninfo,@fromvalue_type,@fromvalue_info,@frommodule  from dual
WHERE NOT EXISTS (SELECT 1 FROM ld_related_detailfield WHERE modulename = @modulename and trigger_columnname=@trigger_columnname and effect_columnname=@effect_columnname AND fromvalue_type=@fromvalue_type);
delimiter;

SET @modulename = 'CashBill';
SET @trigger_columnname = 'entitytypeid';
SET @effect_columnname = 'tablesourceid';
SET @curmodule_columninfo = 'tablesourceid';
SET @fromvalue_type = 'selectsource';
SET @fromvalue_info = '[{"module":"OutboundOrder","column":"source_list","columntype":"main"},{"module":"Invoice","column":"source_list","columntype":"main"}]';
SET @frommodule = '';
INSERT INTO ld_related_detailfield(modulename,trigger_columnname,effect_columnname,curmodule_columninfo,fromvalue_type,fromvalue_info,frommodule)
SELECT @modulename,@trigger_columnname,@effect_columnname,@curmodule_columninfo,@fromvalue_type,@fromvalue_info,@frommodule  from dual
WHERE NOT EXISTS (SELECT 1 FROM ld_related_detailfield WHERE modulename = @modulename and trigger_columnname=@trigger_columnname and effect_columnname=@effect_columnname AND fromvalue_type=@fromvalue_type);
delimiter;

SET @modulename = 'CashBill';
SET @trigger_columnname = 'entitytypeid';
SET @effect_columnname = 'lastinvoicedate';
SET @curmodule_columninfo = 'lastinvoicedate';
SET @fromvalue_type = 'selectsource';
SET @fromvalue_info = '[{"module":"SalesOrder","column":"lastinvoicedate","columntype":"main"},{"module":"ServiceContracts","column":"lastinvoicedate","columntype":"main"}]';
SET @frommodule = '';
INSERT INTO ld_related_detailfield(modulename,trigger_columnname,effect_columnname,curmodule_columninfo,fromvalue_type,fromvalue_info,frommodule)
SELECT @modulename,@trigger_columnname,@effect_columnname,@curmodule_columninfo,@fromvalue_type,@fromvalue_info,@frommodule  from dual
WHERE NOT EXISTS (SELECT 1 FROM ld_related_detailfield WHERE modulename = @modulename and trigger_columnname=@trigger_columnname and effect_columnname=@effect_columnname AND fromvalue_type=@fromvalue_type);
delimiter;

SET @modulename = 'CashBill';
SET @trigger_columnname = 'entitytypeid';
SET @effect_columnname = 'have_invoicetotal';
SET @curmodule_columninfo = 'have_invoicetotal';
SET @fromvalue_type = 'selectsource';
SET @fromvalue_info = '[{"module":"SalesOrder","column":"have_invoicetotal","columntype":"main"},{"module":"ServiceContracts","column":"have_invoicetotal","columntype":"main"}]';
SET @frommodule = '';
INSERT INTO ld_related_detailfield(modulename,trigger_columnname,effect_columnname,curmodule_columninfo,fromvalue_type,fromvalue_info,frommodule)
SELECT @modulename,@trigger_columnname,@effect_columnname,@curmodule_columninfo,@fromvalue_type,@fromvalue_info,@frommodule  from dual
WHERE NOT EXISTS (SELECT 1 FROM ld_related_detailfield WHERE modulename = @modulename and trigger_columnname=@trigger_columnname and effect_columnname=@effect_columnname AND fromvalue_type=@fromvalue_type);
delimiter;


SET @modulename = 'CashBill';
SET @trigger_columnname = 'entitytypeid';
SET @effect_columnname = 'periodtime';
SET @curmodule_columninfo = 'periodtime';
SET @fromvalue_type = 'selectsource';
SET @fromvalue_info = '[{"module":"PaymentPlan","column":"periodtime","columntype":"main"}]';
SET @frommodule = '';
INSERT INTO ld_related_detailfield(modulename,trigger_columnname,effect_columnname,curmodule_columninfo,fromvalue_type,fromvalue_info,frommodule)
SELECT @modulename,@trigger_columnname,@effect_columnname,@curmodule_columninfo,@fromvalue_type,@fromvalue_info,@frommodule  from dual
WHERE NOT EXISTS (SELECT 1 FROM ld_related_detailfield WHERE modulename = @modulename and trigger_columnname=@trigger_columnname and effect_columnname=@effect_columnname AND fromvalue_type=@fromvalue_type);
delimiter;

SET @modulename = 'CashBill';
SET @trigger_columnname = 'entitytypeid';
SET @effect_columnname = 'plandate';
SET @curmodule_columninfo = 'plandate';
SET @fromvalue_type = 'selectsource';
SET @fromvalue_info = '[{"module":"PaymentPlan","column":"plandate","columntype":"main"}]';
SET @frommodule = '';
INSERT INTO ld_related_detailfield(modulename,trigger_columnname,effect_columnname,curmodule_columninfo,fromvalue_type,fromvalue_info,frommodule)
SELECT @modulename,@trigger_columnname,@effect_columnname,@curmodule_columninfo,@fromvalue_type,@fromvalue_info,@frommodule  from dual
WHERE NOT EXISTS (SELECT 1 FROM ld_related_detailfield WHERE modulename = @modulename and trigger_columnname=@trigger_columnname and effect_columnname=@effect_columnname AND fromvalue_type=@fromvalue_type);
delimiter;

SET @modulename = 'CashBill';
SET @trigger_columnname = 'entitytypeid';
SET @effect_columnname = 'plan_amount';
SET @curmodule_columninfo = 'plan_amount';
SET @fromvalue_type = 'selectsource';
SET @fromvalue_info = '[{"module":"PaymentPlan","column":"amount","columntype":"main"}]';
SET @frommodule = '';
INSERT INTO ld_related_detailfield(modulename,trigger_columnname,effect_columnname,curmodule_columninfo,fromvalue_type,fromvalue_info,frommodule)
SELECT @modulename,@trigger_columnname,@effect_columnname,@curmodule_columninfo,@fromvalue_type,@fromvalue_info,@frommodule  from dual
WHERE NOT EXISTS (SELECT 1 FROM ld_related_detailfield WHERE modulename = @modulename and trigger_columnname=@trigger_columnname and effect_columnname=@effect_columnname AND fromvalue_type=@fromvalue_type);
delimiter;

SET @modulename = 'CashBill';
SET @trigger_columnname = 'entitytypeid';
SET @effect_columnname = 'received_amount';
SET @curmodule_columninfo = 'received_amount';
SET @fromvalue_type = 'selectsource';
SET @fromvalue_info = '[{"module":"PaymentPlan","column":"actualamount","columntype":"main"}]';
SET @frommodule = '';
INSERT INTO ld_related_detailfield(modulename,trigger_columnname,effect_columnname,curmodule_columninfo,fromvalue_type,fromvalue_info,frommodule)
SELECT @modulename,@trigger_columnname,@effect_columnname,@curmodule_columninfo,@fromvalue_type,@fromvalue_info,@frommodule  from dual
WHERE NOT EXISTS (SELECT 1 FROM ld_related_detailfield WHERE modulename = @modulename and trigger_columnname=@trigger_columnname and effect_columnname=@effect_columnname AND fromvalue_type=@fromvalue_type);
delimiter;

SET @modulename = 'CashBill';
SET @trigger_columnname = 'entitytypeid';
SET @effect_columnname = 'amount';
SET @curmodule_columninfo = 'amount';
SET @fromvalue_type = 'selectsource';
SET @fromvalue_info = '[{"module":"SalesOrder","column":"receivable_balance","columntype":"main"},{"module":"ServiceContracts","column":"receivable_balance","columntype":"detail"},{"module":"OutboundOrder","column":"receivable_balance","columntype":"main"},{"module":"Invoice","column":"receivable_balance","columntype":"main"},{"module":"PaymentPlan","column":"receivable_balance","columntype":"main"}]';
SET @frommodule = '';
INSERT INTO ld_related_detailfield(modulename,trigger_columnname,effect_columnname,curmodule_columninfo,fromvalue_type,fromvalue_info,frommodule)
SELECT @modulename,@trigger_columnname,@effect_columnname,@curmodule_columninfo,@fromvalue_type,@fromvalue_info,@frommodule  from dual
WHERE NOT EXISTS (SELECT 1 FROM ld_related_detailfield WHERE modulename = @modulename and trigger_columnname=@trigger_columnname and effect_columnname=@effect_columnname AND fromvalue_type=@fromvalue_type);
delimiter;

SET @modulename = 'CashBill';
SET @trigger_columnname = 'entitytypeid';
SET @effect_columnname = 'plan_contract';
SET @curmodule_columninfo = 'plan_contract';
SET @fromvalue_type = 'selectsource';
SET @fromvalue_info = '[{"module":"PaymentPlan","column":"entitytypeid","columntype":"main"}]';
SET @frommodule = '';
INSERT INTO ld_related_detailfield(modulename,trigger_columnname,effect_columnname,curmodule_columninfo,fromvalue_type,fromvalue_info,frommodule)
SELECT @modulename,@trigger_columnname,@effect_columnname,@curmodule_columninfo,@fromvalue_type,@fromvalue_info,@frommodule  from dual
WHERE NOT EXISTS (SELECT 1 FROM ld_related_detailfield WHERE modulename = @modulename and trigger_columnname=@trigger_columnname and effect_columnname=@effect_columnname AND fromvalue_type=@fromvalue_type);
delimiter;

SET @modulename = 'CashBill';
SET @trigger_columnname = 'entitytypeid';
SET @effect_columnname = 'amount';
SET @curmodule_columninfo = 'amount';
SET @fromvalue_type = 'selectsource';
SET @fromvalue_info = '[{"module":"SalesOrder","column":"receivable_balance","columntype":"main"},{"module":"Invoice","column":"receivable_balance","columntype":"main"},{"module":"PaymentPlan","column":"receivable_balance","columntype":"main"},{"module":"ServiceContracts","column":"receivable_balance","columntype":"main"},{"module":"OutboundOrder","column":"receivable_balance","columntype":"main"}]';
SET @frommodule = '';
INSERT INTO ld_related_detailfield(modulename,trigger_columnname,effect_columnname,curmodule_columninfo,fromvalue_type,fromvalue_info,frommodule)
SELECT @modulename,@trigger_columnname,@effect_columnname,@curmodule_columninfo,@fromvalue_type,@fromvalue_info,@frommodule  from dual
WHERE NOT EXISTS (SELECT 1 FROM ld_related_detailfield WHERE modulename = @modulename and trigger_columnname=@trigger_columnname and effect_columnname=@effect_columnname AND fromvalue_type=@fromvalue_type);
delimiter;


SET @tabdetailfieldid=(SELECT MAX(tabdetailfieldid)+1 FROM ld_tabdetailfield);
set @tabid = (select tabid from ld_tab where `name` = 'SendCashBill');
SET @columnname = 'entitytype';
SET @trantable='ld_tabdetailfield';
SET @allowhide = 'no';
SET @fieldlabel = '源单类型';
SET @zh='源单类型';
SET @en='Link To';
SET @uitype = 'entitytype';
SET @typeofdata='V~O';
SET @bigtype='';
SET @parentbigtype='';
SET @sequence = (SELECT IFNULL(MAX(sequence),1) FROM ld_tabdetailfield where tabid=@tabid);
SET @tablename = 'ld_sendcashbill2payment';
SET @sourcemodule = 'PurchaseOrder';
INSERT INTO ld_tabdetailfield(tabdetailfieldid,columnname,allowhide,fieldlabel,defaultvalue,presence,fieldtype,typeofdata,sequence,tabid,tablename,width,edit_permission,input_type,
fieldid,newline,defaultcolumn,is_checkimportfield,nullfield,referencemodule,datarange,approve_demand,maxrowsshow,bigtype,savedatabase,parentbigtype,sourcemodule)
SELECT @tabdetailfieldid,@columnname,@allowhide,@fieldlabel,NULL,0,@uitype,@typeofdata,@sequence+1,@tabid,@tablename,22,1,0,0,0,1,0,1,'','','',0,@bigtype,'yes',@parentbigtype,@sourcemodule from dual
WHERE NOT EXISTS (SELECT 1 FROM ld_tabdetailfield WHERE tabid=@tabid AND columnname=@columnname and tablename=@tablename and sourcemodule=@sourcemodule);

SET @relatedid = (SELECT tabdetailfieldid FROM ld_tabdetailfield WHERE tabid=@tabid AND columnname=@columnname  and sourcemodule=@sourcemodule LIMIT 1);
INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
SELECT 'zh',@trantable,@tabid,@relatedid,@zh  from dual
WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE languagetype = 'zh' and tabid=@tabid and relateid=@relatedid AND trantable=@trantable);
INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
SELECT 'en',@trantable,@tabid,@relatedid,@en  from dual
WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE languagetype = 'en' and tabid=@tabid and relateid=@relatedid AND trantable=@trantable);
CALL AddColumn(@tablename,@columnname,'varchar',25,'');
update ld_tabdetailfield_seq set id = (select max(tabdetailfieldid) from ld_tabdetailfield);
delimiter;

SET @tabdetailfieldid=(SELECT MAX(tabdetailfieldid)+1 FROM ld_tabdetailfield);
set @tabid = (select tabid from ld_tab where `name` = 'SendCashBill');
SET @columnname = 'entitytypeid';
SET @trantable='ld_tabdetailfield';
SET @allowhide = 'no';
SET @fieldlabel = '源单';
SET @zh='源单';
SET @en='Orignal Bill';
SET @uitype = 'SelectSource';
SET @typeofdata='V~O~100';
SET @bigtype='selectsource';
SET @parentbigtype='';
SET @sequence = (SELECT IFNULL(MAX(sequence),1) FROM ld_tabdetailfield where tabid=@tabid);
SET @tablename = 'ld_sendcashbill2payment';
SET @sourcemodule = 'PurchaseOrder';
INSERT INTO ld_tabdetailfield(tabdetailfieldid,columnname,allowhide,fieldlabel,defaultvalue,presence,fieldtype,typeofdata,sequence,tabid,tablename,width,edit_permission,input_type,
fieldid,newline,defaultcolumn,is_checkimportfield,nullfield,referencemodule,datarange,approve_demand,maxrowsshow,bigtype,savedatabase,parentbigtype,sourcemodule)
SELECT @tabdetailfieldid,@columnname,@allowhide,@fieldlabel,NULL,0,@uitype,@typeofdata,@sequence+1,@tabid,@tablename,22,1,0,0,0,1,0,1,NULL,NULL,NULL,0,@bigtype,'yes',@parentbigtype,@sourcemodule from dual
WHERE NOT EXISTS (SELECT 1 FROM ld_tabdetailfield WHERE tabid=@tabid AND columnname=@columnname and tablename=@tablename and sourcemodule=@sourcemodule);

SET @relatedid = (SELECT tabdetailfieldid FROM ld_tabdetailfield WHERE tabid=@tabid AND columnname=@columnname and sourcemodule=@sourcemodule LIMIT 1);
INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
SELECT 'zh',@trantable,@tabid,@relatedid,@zh  from dual
WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE languagetype = 'zh' and tabid=@tabid and relateid=@relatedid AND trantable=@trantable);
INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
SELECT 'en',@trantable,@tabid,@relatedid,@en  from dual
WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE languagetype = 'en' and tabid=@tabid and relateid=@relatedid AND trantable=@trantable);
CALL AddColumn(@tablename,@columnname,'int',11,'');
update ld_tabdetailfield_seq set id = (select max(tabdetailfieldid) from ld_tabdetailfield);
delimiter;

SET @tabdetailfieldid=(SELECT MAX(tabdetailfieldid)+1 FROM ld_tabdetailfield);
set @tabid = (select tabid from ld_tab where `name` = 'SendCashBill');
SET @columnname = 'billdate';
SET @trantable='ld_tabdetailfield';
SET @allowhide = 'yes';
SET @fieldlabel = '合同签约日期';
SET @zh='合同签约日期';
SET @en='Orignal Bill';
SET @uitype = 'Date_Ymd';
SET @typeofdata='D~O';
SET @bigtype='relatedmodulefield';
SET @parentbigtype='date';
SET @sequence = (SELECT IFNULL(MAX(sequence),1) FROM ld_tabdetailfield where tabid=@tabid);
SET @tablename = 'ld_sendcashbill2payment';
SET @sourcemodule = 'PurchaseOrder';
INSERT INTO ld_tabdetailfield(tabdetailfieldid,columnname,allowhide,fieldlabel,defaultvalue,presence,fieldtype,typeofdata,sequence,tabid,tablename,width,edit_permission,input_type,
fieldid,newline,defaultcolumn,is_checkimportfield,nullfield,referencemodule,datarange,approve_demand,maxrowsshow,bigtype,savedatabase,parentbigtype,sourcemodule)
SELECT @tabdetailfieldid,@columnname,@allowhide,@fieldlabel,NULL,0,@uitype,@typeofdata,@sequence+1,@tabid,@tablename,30,1,0,0,0,1,0,1,NULL,NULL,NULL,0,@bigtype,'no',@parentbigtype,@sourcemodule from dual
WHERE NOT EXISTS (SELECT 1 FROM ld_tabdetailfield WHERE tabid=@tabid AND columnname=@columnname and tablename=@tablename and sourcemodule=@sourcemodule);

SET @relatedid = (SELECT tabdetailfieldid FROM ld_tabdetailfield WHERE tabid=@tabid AND columnname=@columnname and sourcemodule=@sourcemodule LIMIT 1);
INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
SELECT 'zh',@trantable,@tabid,@relatedid,@zh  from dual
WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE languagetype = 'zh' and tabid=@tabid and relateid=@relatedid AND trantable=@trantable);
INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
SELECT 'en',@trantable,@tabid,@relatedid,@en  from dual
WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE languagetype = 'en' and tabid=@tabid and relateid=@relatedid AND trantable=@trantable);
CALL AddColumn(@tablename,@columnname,'date','','');
update ld_tabdetailfield_seq set id = (select max(tabdetailfieldid) from ld_tabdetailfield);
delimiter;


SET @tabdetailfieldid=(SELECT MAX(tabdetailfieldid)+1 FROM ld_tabdetailfield);
set @tabid = (select tabid from ld_tab where `name` = 'SendCashBill');
SET @columnname = 'source_total';
SET @trantable='ld_tabdetailfield';
SET @allowhide = 'yes';
SET @fieldlabel = '合同金额';
SET @zh='合同金额';
SET @en='Contract Amount';
SET @uitype = 'Amount';
SET @typeofdata='N~O~25,6';
SET @bigtype='relatedmodulefield';
SET @parentbigtype='amount';
SET @sequence = (SELECT IFNULL(MAX(sequence),1) FROM ld_tabdetailfield where tabid=@tabid);
SET @tablename = 'ld_sendcashbill2payment';
SET @sourcemodule = 'PurchaseOrder';
INSERT INTO ld_tabdetailfield(tabdetailfieldid,columnname,allowhide,fieldlabel,defaultvalue,presence,fieldtype,typeofdata,sequence,tabid,tablename,width,edit_permission,input_type,
fieldid,newline,defaultcolumn,is_checkimportfield,nullfield,referencemodule,datarange,approve_demand,maxrowsshow,bigtype,savedatabase,parentbigtype,sourcemodule)
SELECT @tabdetailfieldid,@columnname,@allowhide,@fieldlabel,NULL,0,@uitype,@typeofdata,@sequence+1,@tabid,@tablename,30,1,0,0,0,1,0,1,NULL,NULL,NULL,0,@bigtype,'no',@parentbigtype,@sourcemodule from dual
WHERE NOT EXISTS (SELECT 1 FROM ld_tabdetailfield WHERE tabid=@tabid AND columnname=@columnname and tablename=@tablename and sourcemodule=@sourcemodule);

SET @relatedid = (SELECT tabdetailfieldid FROM ld_tabdetailfield WHERE tabid=@tabid AND columnname=@columnname and sourcemodule=@sourcemodule LIMIT 1);
INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
SELECT 'zh',@trantable,@tabid,@relatedid,@zh  from dual
WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE languagetype = 'zh' and tabid=@tabid and relateid=@relatedid AND trantable=@trantable);
INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
SELECT 'en',@trantable,@tabid,@relatedid,@en  from dual
WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE languagetype = 'en' and tabid=@tabid and relateid=@relatedid AND trantable=@trantable);
CALL AddColumn(@tablename,@columnname,'decimal','25','6');
update ld_tabdetailfield_seq set id = (select max(tabdetailfieldid) from ld_tabdetailfield);
delimiter;


SET @tabdetailfieldid=(SELECT MAX(tabdetailfieldid)+1 FROM ld_tabdetailfield);
set @tabid = (select tabid from ld_tab where `name` = 'SendCashBill');
SET @columnname = 'lastinvoicedate';
SET @trantable='ld_tabdetailfield';
SET @allowhide = 'yes';
SET @fieldlabel = '最新开票日期';
SET @zh='最新开票日期';
SET @en='Latest Invoice Date';
SET @uitype = 'Date_Ymd';
SET @typeofdata='D~O';
SET @bigtype='relatedmodulefield';
SET @parentbigtype='date';
SET @sequence = (SELECT IFNULL(MAX(sequence),1) FROM ld_tabdetailfield where tabid=@tabid);
SET @tablename = 'ld_sendcashbill2payment';
SET @sourcemodule = 'PurchaseOrder';
INSERT INTO ld_tabdetailfield(tabdetailfieldid,columnname,allowhide,fieldlabel,defaultvalue,presence,fieldtype,typeofdata,sequence,tabid,tablename,width,edit_permission,input_type,
fieldid,newline,defaultcolumn,is_checkimportfield,nullfield,referencemodule,datarange,approve_demand,maxrowsshow,bigtype,savedatabase,parentbigtype,sourcemodule)
SELECT @tabdetailfieldid,@columnname,@allowhide,@fieldlabel,NULL,0,@uitype,@typeofdata,@sequence+1,@tabid,@tablename,30,1,0,0,0,1,0,1,NULL,NULL,NULL,0,@bigtype,'no',@parentbigtype,@sourcemodule from dual
WHERE NOT EXISTS (SELECT 1 FROM ld_tabdetailfield WHERE tabid=@tabid AND columnname=@columnname and tablename=@tablename and sourcemodule=@sourcemodule);

SET @relatedid = (SELECT tabdetailfieldid FROM ld_tabdetailfield WHERE tabid=@tabid AND columnname=@columnname and sourcemodule=@sourcemodule LIMIT 1);
INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
SELECT 'zh',@trantable,@tabid,@relatedid,@zh  from dual
WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE languagetype = 'zh' and tabid=@tabid and relateid=@relatedid AND trantable=@trantable);
INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
SELECT 'en',@trantable,@tabid,@relatedid,@en  from dual
WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE languagetype = 'en' and tabid=@tabid and relateid=@relatedid AND trantable=@trantable);
CALL AddColumn(@tablename,@columnname,'date','','');
update ld_tabdetailfield_seq set id = (select max(tabdetailfieldid) from ld_tabdetailfield);
delimiter;

SET @tabdetailfieldid=(SELECT MAX(tabdetailfieldid)+1 FROM ld_tabdetailfield);
set @tabid = (select tabid from ld_tab where `name` = 'SendCashBill');
SET @columnname = 'have_invoicetotal';
SET @trantable='ld_tabdetailfield';
SET @allowhide = 'yes';
SET @fieldlabel = '已开票总额';
SET @zh='已开票总额';
SET @en='Invoice Totalt';
SET @uitype = 'Amount';
SET @typeofdata='N~O~25,6';
SET @bigtype='relatedmodulefield';
SET @parentbigtype='currency';
SET @sequence = (SELECT IFNULL(MAX(sequence),1) FROM ld_tabdetailfield where tabid=@tabid);
SET @tablename = 'ld_sendcashbill2payment';
SET @sourcemodule = 'PurchaseOrder';
INSERT INTO ld_tabdetailfield(tabdetailfieldid,columnname,allowhide,fieldlabel,defaultvalue,presence,fieldtype,typeofdata,sequence,tabid,tablename,width,edit_permission,input_type,
fieldid,newline,defaultcolumn,is_checkimportfield,nullfield,referencemodule,datarange,approve_demand,maxrowsshow,bigtype,savedatabase,parentbigtype,sourcemodule)
SELECT @tabdetailfieldid,@columnname,@allowhide,@fieldlabel,NULL,0,@uitype,@typeofdata,@sequence+1,@tabid,@tablename,30,1,0,0,0,1,0,1,NULL,NULL,NULL,0,@bigtype,'yes',@parentbigtype,@sourcemodule from dual
WHERE NOT EXISTS (SELECT 1 FROM ld_tabdetailfield WHERE tabid=@tabid AND columnname=@columnname and tablename=@tablename and sourcemodule=@sourcemodule);

SET @relatedid = (SELECT tabdetailfieldid FROM ld_tabdetailfield WHERE tabid=@tabid AND columnname=@columnname and sourcemodule=@sourcemodule LIMIT 1);
INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
SELECT 'zh',@trantable,@tabid,@relatedid,@zh  from dual
WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE languagetype = 'zh' and tabid=@tabid and relateid=@relatedid AND trantable=@trantable);
INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
SELECT 'en',@trantable,@tabid,@relatedid,@en  from dual
WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE languagetype = 'en' and tabid=@tabid and relateid=@relatedid AND trantable=@trantable);
CALL AddColumn(@tablename,@columnname,'decimal','25','0.000000');
update ld_tabdetailfield_seq set id = (select max(tabdetailfieldid) from ld_tabdetailfield);
delimiter;

SET @tabdetailfieldid=(SELECT MAX(tabdetailfieldid)+1 FROM ld_tabdetailfield);
set @tabid = (select tabid from ld_tab where `name` = 'SendCashBill');
SET @columnname = 'lastsendcashbilldate';
SET @trantable='ld_tabdetailfield';
SET @allowhide = 'yes';
SET @fieldlabel = '最近付款日期';
SET @zh='最近付款日期';
SET @en='Latest Collection Date';
SET @uitype = 'Date_Ymd';
SET @typeofdata='D~O';
SET @bigtype='relatedmodulefield';
SET @parentbigtype='date';
SET @sequence = (SELECT IFNULL(MAX(sequence),1) FROM ld_tabdetailfield where tabid=@tabid);
SET @tablename = 'ld_sendcashbill2payment';
SET @sourcemodule = 'PurchaseOrder';
INSERT INTO ld_tabdetailfield(tabdetailfieldid,columnname,allowhide,fieldlabel,defaultvalue,presence,fieldtype,typeofdata,sequence,tabid,tablename,width,edit_permission,input_type,
fieldid,newline,defaultcolumn,is_checkimportfield,nullfield,referencemodule,datarange,approve_demand,maxrowsshow,bigtype,savedatabase,parentbigtype,sourcemodule)
SELECT @tabdetailfieldid,@columnname,@allowhide,@fieldlabel,NULL,0,@uitype,@typeofdata,@sequence+1,@tabid,@tablename,30,1,0,0,0,1,0,1,NULL,NULL,NULL,0,@bigtype,'yes',@parentbigtype,@sourcemodule from dual
WHERE NOT EXISTS (SELECT 1 FROM ld_tabdetailfield WHERE tabid=@tabid AND columnname=@columnname and tablename=@tablename and sourcemodule=@sourcemodule);

SET @relatedid = (SELECT tabdetailfieldid FROM ld_tabdetailfield WHERE tabid=@tabid AND columnname=@columnname and sourcemodule=@sourcemodule LIMIT 1);
INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
SELECT 'zh',@trantable,@tabid,@relatedid,@zh  from dual
WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE languagetype = 'zh' and tabid=@tabid and relateid=@relatedid AND trantable=@trantable);
INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
SELECT 'en',@trantable,@tabid,@relatedid,@en  from dual
WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE languagetype = 'en' and tabid=@tabid and relateid=@relatedid AND trantable=@trantable);
CALL AddColumn(@tablename,@columnname,'date','','');
update ld_tabdetailfield_seq set id = (select max(tabdetailfieldid) from ld_tabdetailfield);
delimiter;

SET @tabdetailfieldid=(SELECT MAX(tabdetailfieldid)+1 FROM ld_tabdetailfield);
set @tabid = (select tabid from ld_tab where `name` = 'SendCashBill');
SET @columnname = 'pay_amount';
SET @trantable='ld_tabdetailfield';
SET @allowhide = 'yes';
SET @fieldlabel = '合同已付总额';
SET @zh='合同已付总额';
SET @en='Pay Amount';
SET @uitype = 'Amount';
SET @typeofdata='N~O~25,6';
SET @bigtype='relatedmodulefield';
SET @parentbigtype='amount';
SET @sequence = (SELECT IFNULL(MAX(sequence),1) FROM ld_tabdetailfield where tabid=@tabid);
SET @tablename = 'ld_sendcashbill2payment';
SET @sourcemodule = 'PurchaseOrder';
INSERT INTO ld_tabdetailfield(tabdetailfieldid,columnname,allowhide,fieldlabel,defaultvalue,presence,fieldtype,typeofdata,sequence,tabid,tablename,width,edit_permission,input_type,
fieldid,newline,defaultcolumn,is_checkimportfield,nullfield,referencemodule,datarange,approve_demand,maxrowsshow,bigtype,savedatabase,parentbigtype,sourcemodule)
SELECT @tabdetailfieldid,@columnname,@allowhide,@fieldlabel,NULL,0,@uitype,@typeofdata,@sequence+1,@tabid,@tablename,30,1,0,0,0,1,0,1,NULL,NULL,NULL,0,@bigtype,'no',@parentbigtype,@sourcemodule from dual
WHERE NOT EXISTS (SELECT 1 FROM ld_tabdetailfield WHERE tabid=@tabid AND columnname=@columnname and tablename=@tablename and sourcemodule=@sourcemodule);

SET @relatedid = (SELECT tabdetailfieldid FROM ld_tabdetailfield WHERE tabid=@tabid AND columnname=@columnname and sourcemodule=@sourcemodule LIMIT 1);
INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
SELECT 'zh',@trantable,@tabid,@relatedid,@zh  from dual
WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE languagetype = 'zh' and tabid=@tabid and relateid=@relatedid AND trantable=@trantable);
INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
SELECT 'en',@trantable,@tabid,@relatedid,@en  from dual
WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE languagetype = 'en' and tabid=@tabid and relateid=@relatedid AND trantable=@trantable);
CALL AddColumn(@tablename,@columnname,'decimal','25','0.000000');
update ld_tabdetailfield_seq set id = (select max(tabdetailfieldid) from ld_tabdetailfield);
delimiter;

SET @tabdetailfieldid=(SELECT MAX(tabdetailfieldid)+1 FROM ld_tabdetailfield);
set @tabid = (select tabid from ld_tab where `name` = 'SendCashBill');
SET @columnname = 'amount';
SET @trantable='ld_tabdetailfield';
SET @allowhide = 'no';
SET @fieldlabel = '本次付款金额';
SET @zh='本次付款金额';
SET @en='The amount payment';
SET @uitype = 'Amount';
SET @typeofdata='N~O~25,6';
SET @bigtype='amount';
SET @parentbigtype='';
SET @sequence = (SELECT IFNULL(MAX(sequence),1) FROM ld_tabdetailfield where tabid=@tabid);
SET @tablename = 'ld_sendcashbill2payment';
SET @sourcemodule = 'PurchaseOrder';
INSERT INTO ld_tabdetailfield(tabdetailfieldid,columnname,allowhide,fieldlabel,defaultvalue,presence,fieldtype,typeofdata,sequence,tabid,tablename,width,edit_permission,input_type,
fieldid,newline,defaultcolumn,is_checkimportfield,nullfield,referencemodule,datarange,approve_demand,maxrowsshow,bigtype,savedatabase,parentbigtype,sourcemodule)
SELECT @tabdetailfieldid,@columnname,@allowhide,@fieldlabel,NULL,0,@uitype,@typeofdata,@sequence+1,@tabid,@tablename,30,0,0,0,0,1,0,1,NULL,NULL,NULL,0,@bigtype,'yes',@parentbigtype,@sourcemodule from dual
WHERE NOT EXISTS (SELECT 1 FROM ld_tabdetailfield WHERE tabid=@tabid AND columnname=@columnname and tablename=@tablename and sourcemodule=@sourcemodule);

SET @relatedid = (SELECT tabdetailfieldid FROM ld_tabdetailfield WHERE tabid=@tabid AND columnname=@columnname and sourcemodule=@sourcemodule LIMIT 1);
INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
SELECT 'zh',@trantable,@tabid,@relatedid,@zh  from dual
WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE languagetype = 'zh' and tabid=@tabid and relateid=@relatedid AND trantable=@trantable);
INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
SELECT 'en',@trantable,@tabid,@relatedid,@en  from dual
WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE languagetype = 'en' and tabid=@tabid and relateid=@relatedid AND trantable=@trantable);
CALL AddColumn(@tablename,@columnname,'decimal','25','0.00');
update ld_tabdetailfield_seq set id = (select max(tabdetailfieldid) from ld_tabdetailfield);
delimiter;

SET @tabdetailfieldid=(SELECT MAX(tabdetailfieldid)+1 FROM ld_tabdetailfield);
set @tabid = (select tabid from ld_tab where `name` = 'SendCashBill');
SET @columnname = 'total';
SET @trantable='ld_tabdetailfield';
SET @allowhide = 'no';
SET @fieldlabel = '实际收款金额';
SET @zh='实际收款金额';
SET @en='Actual Receipts';
SET @uitype = 'Amount';
SET @typeofdata='N~O~25,6';
SET @bigtype='';
SET @parentbigtype='';
SET @sequence = (SELECT IFNULL(MAX(sequence),1) FROM ld_tabdetailfield where tabid=@tabid);
SET @tablename = 'ld_sendcashbill2payment';
SET @sourcemodule = 'PurchaseOrder';
INSERT INTO ld_tabdetailfield(tabdetailfieldid,columnname,allowhide,fieldlabel,defaultvalue,presence,fieldtype,typeofdata,sequence,tabid,tablename,width,edit_permission,input_type,
fieldid,newline,defaultcolumn,is_checkimportfield,nullfield,referencemodule,datarange,approve_demand,maxrowsshow,bigtype,savedatabase,parentbigtype,sourcemodule)
SELECT @tabdetailfieldid,@columnname,@allowhide,@fieldlabel,NULL,0,@uitype,@typeofdata,@sequence+1,@tabid,@tablename,30,1,0,0,1,1,0,1,NULL,NULL,NULL,0,@bigtype,'yes',@parentbigtype,@sourcemodule from dual
WHERE NOT EXISTS (SELECT 1 FROM ld_tabdetailfield WHERE tabid=@tabid AND columnname=@columnname and tablename=@tablename and sourcemodule=@sourcemodule);

SET @relatedid = (SELECT tabdetailfieldid FROM ld_tabdetailfield WHERE tabid=@tabid AND columnname=@columnname and sourcemodule=@sourcemodule LIMIT 1);
INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
SELECT 'zh',@trantable,@tabid,@relatedid,@zh  from dual
WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE languagetype = 'zh' and tabid=@tabid and relateid=@relatedid AND trantable=@trantable);
INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
SELECT 'en',@trantable,@tabid,@relatedid,@en  from dual
WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE languagetype = 'en' and tabid=@tabid and relateid=@relatedid AND trantable=@trantable);
CALL AddColumn(@tablename,@columnname,'decimal','25','0.000000');
update ld_tabdetailfield_seq set id = (select max(tabdetailfieldid) from ld_tabdetailfield);
delimiter;

SET @producttoolfieldid=(SELECT MAX(producttoolfieldid)+1 FROM ld_producttoolfield);
set @tabid = (select tabid from ld_tab where `name` = 'SendCashBill');
SET @columnname = 'entitytype';
SET @trantable='ld_producttoolfield';
SET @allowhide = 'no';
SET @fieldlabel = '源单类型';
SET @zh='源单类型';
SET @en='Link To';
SET @uitype = 204;
SET @typeofdata='V~O~100';
SET @bigtype='';
SET @parentbigtype='';
SET @sequence = (SELECT IFNULL(MAX(sequence),1) FROM ld_producttoolfield where tabid=@tabid);
SET @tablename = 'ld_sendcashbill2payment';
SET @sourcemodule = 'PurchaseOrder';
INSERT INTO ld_producttoolfield(producttoolfieldid,columnname,allowhide,fieldlabel,defaultvalue,presence,uitype,typeofdata,sequence,tabid,tablename,width,edit_permission,input_type,
fieldid,newline,defaultcolumn,is_checkimportfield,nullfield,referencemodule,datarange,approve_demand,maxrowsshow,bigtype,savedatabase,parentbigtype,sourcemodule)
SELECT @producttoolfieldid,@columnname,@allowhide,@fieldlabel,NULL,0,@uitype,@typeofdata,@sequence+1,@tabid,@tablename,30,1,0,0,0,1,0,1,'','','',0,@bigtype,'yes',@parentbigtype,@sourcemodule from dual
WHERE NOT EXISTS (SELECT 1 FROM ld_producttoolfield WHERE tabid=@tabid AND columnname=@columnname and tablename=@tablename and sourcemodule=@sourcemodule);

SET @relatedid = (SELECT producttoolfieldid FROM ld_producttoolfield WHERE tabid=@tabid AND columnname=@columnname and sourcemodule=@sourcemodule LIMIT 1);
INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
SELECT 'zh',@trantable,@tabid,@relatedid,@zh  from dual
WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE languagetype = 'zh' and tabid=@tabid and relateid=@relatedid AND trantable=@trantable);
INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
SELECT 'en',@trantable,@tabid,@relatedid,@en  from dual
WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE languagetype = 'en' and tabid=@tabid and relateid=@relatedid AND trantable=@trantable);
CALL AddColumn(@tablename,@columnname,'varchar',25,'');
update ld_producttoolfield_seq set id = (select max(producttoolfieldid) from ld_producttoolfield);
delimiter;



SET @producttoolfieldid=(SELECT MAX(producttoolfieldid)+1 FROM ld_producttoolfield);
set @tabid = (select tabid from ld_tab where `name` = 'SendCashBill');
SET @columnname = 'entitytypeid';
SET @trantable='ld_producttoolfield';
SET @allowhide = 'no';
SET @fieldlabel = '源单';
SET @zh='源单';
SET @en='Orignal Bill';
SET @uitype = 202;
SET @typeofdata='V~O~100';
SET @bigtype='selectsource';
SET @parentbigtype='';
SET @sequence = (SELECT IFNULL(MAX(sequence),1) FROM ld_producttoolfield where tabid=@tabid);
SET @tablename = 'ld_sendcashbill2payment';
SET @sourcemodule = 'PurchaseOrder';
INSERT INTO ld_producttoolfield(producttoolfieldid,columnname,allowhide,fieldlabel,defaultvalue,presence,uitype,typeofdata,sequence,tabid,tablename,width,edit_permission,input_type,
fieldid,newline,defaultcolumn,is_checkimportfield,nullfield,referencemodule,datarange,approve_demand,maxrowsshow,bigtype,savedatabase,parentbigtype,sourcemodule)
SELECT @producttoolfieldid,@columnname,@allowhide,@fieldlabel,NULL,0,@uitype,@typeofdata,@sequence+1,@tabid,@tablename,22,1,0,0,0,1,0,1,'','','',0,@bigtype,'yes',@parentbigtype,@sourcemodule from dual
WHERE NOT EXISTS (SELECT 1 FROM ld_producttoolfield WHERE tabid=@tabid AND columnname=@columnname and tablename=@tablename and sourcemodule=@sourcemodule);

SET @relatedid = (SELECT producttoolfieldid FROM ld_producttoolfield WHERE tabid=@tabid AND columnname=@columnname and sourcemodule=@sourcemodule LIMIT 1);
INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
SELECT 'zh',@trantable,@tabid,@relatedid,@zh  from dual
WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE languagetype = 'zh' and tabid=@tabid and relateid=@relatedid AND trantable=@trantable);
INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
SELECT 'en',@trantable,@tabid,@relatedid,@en  from dual
WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE languagetype = 'en' and tabid=@tabid and relateid=@relatedid AND trantable=@trantable);
CALL AddColumn(@tablename,@columnname,'int',11,'');
update ld_producttoolfield_seq set id = (select max(producttoolfieldid) from ld_producttoolfield);
delimiter;


SET @producttoolfieldid=(SELECT MAX(producttoolfieldid)+1 FROM ld_producttoolfield);
set @tabid = (select tabid from ld_tab where `name` = 'SendCashBill');
SET @columnname = 'productname';
SET @trantable='ld_producttoolfield';
SET @allowhide = 'no';
SET @fieldlabel = '产品名称';
SET @zh='产品名称';
SET @en='Product Name';
SET @uitype = 70;
SET @typeofdata='V~M~100';
SET @bigtype='selectsource';
SET @parentbigtype='';
SET @sequence = (SELECT IFNULL(MAX(sequence),1) FROM ld_producttoolfield where tabid=@tabid);
SET @tablename = 'ld_products';
SET @sourcemodule = 'PurchaseOrder';
SET @producttabid = (select tabid from ld_tab where `name`='Products');
set @fieldid=(select fieldid from ld_field where tabid = @producttabid and fieldname = 'productname');
INSERT INTO ld_producttoolfield(producttoolfieldid,columnname,allowhide,fieldlabel,defaultvalue,presence,uitype,typeofdata,sequence,tabid,tablename,width,edit_permission,input_type,
fieldid,newline,defaultcolumn,is_checkimportfield,nullfield,referencemodule,datarange,approve_demand,maxrowsshow,bigtype,savedatabase,parentbigtype,sourcemodule)
SELECT @producttoolfieldid,@columnname,@allowhide,@fieldlabel,NULL,0,@uitype,@typeofdata,@sequence+1,@tabid,@tablename,45,0,0,@fieldid,0,2,0,0,'','','',0,@bigtype,'yes',@parentbigtype,@sourcemodule from dual
WHERE NOT EXISTS (SELECT 1 FROM ld_producttoolfield WHERE tabid=@tabid AND columnname=@columnname and tablename=@tablename and sourcemodule=@sourcemodule);

SET @relatedid = (SELECT producttoolfieldid FROM ld_producttoolfield WHERE tabid=@tabid AND columnname=@columnname and sourcemodule=@sourcemodule LIMIT 1);
INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
SELECT 'zh',@trantable,@tabid,@relatedid,@zh  from dual
WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE languagetype = 'zh' and tabid=@tabid and relateid=@relatedid AND trantable=@trantable);
INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
SELECT 'en',@trantable,@tabid,@relatedid,@en  from dual
WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE languagetype = 'en' and tabid=@tabid and relateid=@relatedid AND trantable=@trantable);
CALL AddColumn('ld_sendcashbill2payment','productid','int',11,'');
update ld_producttoolfield_seq set id = (select max(producttoolfieldid) from ld_producttoolfield);
delimiter;

SET @producttoolfieldid=(SELECT MAX(producttoolfieldid)+1 FROM ld_producttoolfield);
set @tabid = (select tabid from ld_tab where `name` = 'SendCashBill');
SET @columnname = 'product_no';
SET @trantable='ld_producttoolfield';
SET @allowhide = 'yes';
SET @fieldlabel = '产品编号';
SET @zh='产品编号';
SET @en='Product No';
SET @uitype = 4;
SET @typeofdata='V~O';
SET @bigtype='';
SET @parentbigtype='';
SET @sequence = (SELECT IFNULL(MAX(sequence),1) FROM ld_producttoolfield where tabid=@tabid);
SET @tablename = 'ld_products';
SET @sourcemodule = 'PurchaseOrder';
SET @producttabid = (select tabid from ld_tab where `name`='Products');
SET @fieldid = (SELECT fieldid FROM ld_field where tabid=@producttabid and columnname = 'product_no');
INSERT INTO ld_producttoolfield(producttoolfieldid,columnname,allowhide,fieldlabel,defaultvalue,presence,uitype,typeofdata,sequence,tabid,tablename,width,edit_permission,input_type,
fieldid,newline,defaultcolumn,is_checkimportfield,nullfield,referencemodule,datarange,approve_demand,maxrowsshow,bigtype,savedatabase,parentbigtype,sourcemodule)
SELECT @producttoolfieldid,@columnname,@allowhide,@fieldlabel,NULL,0,@uitype,@typeofdata,@sequence+1,@tabid,@tablename,22,1,1,@fieldid,0,1,0,1,'','','',0,@bigtype,'yes',@parentbigtype,@sourcemodule from dual
WHERE NOT EXISTS (SELECT 1 FROM ld_producttoolfield WHERE tabid=@tabid AND columnname=@columnname and tablename=@tablename and sourcemodule=@sourcemodule);

SET @relatedid = (SELECT producttoolfieldid FROM ld_producttoolfield WHERE tabid=@tabid AND columnname=@columnname and sourcemodule=@sourcemodule LIMIT 1);
INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
SELECT 'zh',@trantable,@tabid,@relatedid,@zh  from dual
WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE languagetype = 'zh' and tabid=@tabid and relateid=@relatedid AND trantable=@trantable);
INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
SELECT 'en',@trantable,@tabid,@relatedid,@en  from dual
WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE languagetype = 'en' and tabid=@tabid and relateid=@relatedid AND trantable=@trantable);

update ld_producttoolfield_seq set id = (select max(producttoolfieldid) from ld_producttoolfield);
delimiter;

SET @producttoolfieldid=(SELECT MAX(producttoolfieldid)+1 FROM ld_producttoolfield);
set @tabid = (select tabid from ld_tab where `name` = 'SendCashBill');
SET @columnname = 'productsheet';
SET @trantable='ld_producttoolfield';
SET @allowhide = 'yes';
SET @fieldlabel = '规格型号';
SET @zh='规格型号';
SET @en='Specification';
SET @uitype = 1;
SET @typeofdata='V~O';
SET @bigtype='';
SET @parentbigtype='';
SET @sequence = (SELECT IFNULL(MAX(sequence),1) FROM ld_producttoolfield where tabid=@tabid);
SET @tablename = 'ld_products';
SET @sourcemodule = 'PurchaseOrder';
SET @producttabid = (select tabid from ld_tab where `name`='Products');
SET @fieldid = (SELECT fieldid FROM ld_field where tabid=@producttabid and columnname = 'productsheet');
INSERT INTO ld_producttoolfield(producttoolfieldid,columnname,allowhide,fieldlabel,defaultvalue,presence,uitype,typeofdata,sequence,tabid,tablename,width,edit_permission,input_type,
fieldid,newline,defaultcolumn,is_checkimportfield,nullfield,referencemodule,datarange,approve_demand,maxrowsshow,bigtype,savedatabase,parentbigtype,sourcemodule)
SELECT @producttoolfieldid,@columnname,@allowhide,@fieldlabel,NULL,0,@uitype,@typeofdata,@sequence+1,@tabid,@tablename,22,1,1,@fieldid,0,1,0,1,'','','',0,@bigtype,'yes',@parentbigtype,@sourcemodule from dual
WHERE NOT EXISTS (SELECT 1 FROM ld_producttoolfield WHERE tabid=@tabid AND columnname=@columnname and tablename=@tablename and sourcemodule=@sourcemodule);

SET @relatedid = (SELECT producttoolfieldid FROM ld_producttoolfield WHERE tabid=@tabid AND columnname=@columnname and sourcemodule=@sourcemodule LIMIT 1);
INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
SELECT 'zh',@trantable,@tabid,@relatedid,@zh  from dual
WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE languagetype = 'zh' and tabid=@tabid and relateid=@relatedid AND trantable=@trantable);
INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
SELECT 'en',@trantable,@tabid,@relatedid,@en  from dual
WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE languagetype = 'en' and tabid=@tabid and relateid=@relatedid AND trantable=@trantable);

update ld_producttoolfield_seq set id = (select max(producttoolfieldid) from ld_producttoolfield);
delimiter;



SET @producttoolfieldid=(SELECT MAX(producttoolfieldid)+1 FROM ld_producttoolfield);
set @tabid = (select tabid from ld_tab where `name` = 'SendCashBill');
SET @columnname = 'productsourcetype';
SET @trantable='ld_producttoolfield';
SET @allowhide = 'yes';
SET @fieldlabel = '产品源单类型';
SET @zh='产品源单类型';
SET @en='Source Type';
SET @uitype = 221;
SET @typeofdata='V~O';
SET @bigtype='relatedmodulefield';
SET @parentbigtype='entitytype';
SET @sequence = (SELECT IFNULL(MAX(sequence),1) FROM ld_producttoolfield where tabid=@tabid);
SET @tablename = 'ld_sendcashbill2payment';
SET @sourcemodule = 'PurchaseOrder';
INSERT INTO ld_producttoolfield(producttoolfieldid,columnname,allowhide,fieldlabel,defaultvalue,presence,uitype,typeofdata,sequence,tabid,tablename,width,edit_permission,input_type,
fieldid,newline,defaultcolumn,is_checkimportfield,nullfield,referencemodule,datarange,approve_demand,maxrowsshow,bigtype,savedatabase,parentbigtype,sourcemodule)
SELECT @producttoolfieldid,@columnname,@allowhide,@fieldlabel,NULL,0,@uitype,@typeofdata,@sequence+1,@tabid,@tablename,22,1,0,0,0,1,0,1,'','','',0,@bigtype,'no',@parentbigtype,@sourcemodule from dual
WHERE NOT EXISTS (SELECT 1 FROM ld_producttoolfield WHERE tabid=@tabid AND columnname=@columnname and tablename=@tablename and sourcemodule=@sourcemodule);

SET @relatedid = (SELECT producttoolfieldid FROM ld_producttoolfield WHERE tabid=@tabid AND columnname=@columnname and sourcemodule=@sourcemodule LIMIT 1);
INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
SELECT 'zh',@trantable,@tabid,@relatedid,@zh  from dual
WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE languagetype = 'zh' and tabid=@tabid and relateid=@relatedid AND trantable=@trantable);
INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
SELECT 'en',@trantable,@tabid,@relatedid,@en  from dual
WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE languagetype = 'en' and tabid=@tabid and relateid=@relatedid AND trantable=@trantable);
CALL AddColumn('ld_sendcashbill2payment','productsourcetype','varchar',25,'');
update ld_producttoolfield_seq set id = (select max(producttoolfieldid) from ld_producttoolfield);
delimiter;

SET @modulename = 'SendCashBill';
SET @trigger_columnname = 'entitytypeid';
SET @effect_columnname = 'productsourcetype';
SET @curmodule_columninfo = 'productsourcetype';
SET @fromvalue_type = 'selectsource';
SET @fromvalue_info = '[{"module":"PurchaseOrder","column":"entitytype","columntype":"detail"},{"module":"PurchaseInvoice","column":"entitytype","columntype":"detail"}]';
SET @frommodule = '';
INSERT INTO ld_related_detailfield(modulename,trigger_columnname,effect_columnname,curmodule_columninfo,fromvalue_type,fromvalue_info,frommodule)
SELECT @modulename,@trigger_columnname,@effect_columnname,@curmodule_columninfo,@fromvalue_type,@fromvalue_info,@frommodule  from dual
WHERE NOT EXISTS (SELECT 1 FROM ld_related_detailfield WHERE modulename = @modulename and trigger_columnname=@trigger_columnname and effect_columnname=@effect_columnname AND fromvalue_type=@fromvalue_type);
delimiter;
SET @producttoolfieldid=(SELECT MAX(producttoolfieldid)+1 FROM ld_producttoolfield);
set @tabid = (select tabid from ld_tab where `name` = 'SendCashBill');
SET @columnname = 'productsourceid';
SET @trantable='ld_producttoolfield';
SET @allowhide = 'yes';
SET @fieldlabel = '产品源单';
SET @zh='产品源单';
SET @en='Source Bill';
SET @uitype = 220;
SET @typeofdata='V~O';
SET @bigtype='relatedmodulefield';
SET @parentbigtype='selectsource';
SET @sequence = (SELECT IFNULL(MAX(sequence),1) FROM ld_producttoolfield where tabid=@tabid);
SET @tablename = 'ld_sendcashbill2payment';
SET @sourcemodule = 'PurchaseOrder';
INSERT INTO ld_producttoolfield(producttoolfieldid,columnname,allowhide,fieldlabel,defaultvalue,presence,uitype,typeofdata,sequence,tabid,tablename,width,edit_permission,input_type,
fieldid,newline,defaultcolumn,is_checkimportfield,nullfield,referencemodule,datarange,approve_demand,maxrowsshow,bigtype,savedatabase,parentbigtype,sourcemodule)
SELECT @producttoolfieldid,@columnname,@allowhide,@fieldlabel,NULL,0,@uitype,@typeofdata,@sequence+1,@tabid,@tablename,30,1,0,0,0,1,0,1,'','','',0,@bigtype,'no',@parentbigtype,@sourcemodule from dual
WHERE NOT EXISTS (SELECT 1 FROM ld_producttoolfield WHERE tabid=@tabid AND columnname=@columnname and tablename=@tablename and sourcemodule=@sourcemodule);

SET @relatedid = (SELECT producttoolfieldid FROM ld_producttoolfield WHERE tabid=@tabid AND columnname=@columnname and sourcemodule=@sourcemodule LIMIT 1);
INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
SELECT 'zh',@trantable,@tabid,@relatedid,@zh  from dual
WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE languagetype = 'zh' and tabid=@tabid and relateid=@relatedid AND trantable=@trantable);
INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
SELECT 'en',@trantable,@tabid,@relatedid,@en  from dual
WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE languagetype = 'en' and tabid=@tabid and relateid=@relatedid AND trantable=@trantable);
CALL AddColumn('ld_sendcashbill2payment','productsourceid','int',11,'');
update ld_producttoolfield_seq set id = (select max(producttoolfieldid) from ld_producttoolfield);
delimiter;


SET @producttoolfieldid=(SELECT MAX(producttoolfieldid)+1 FROM ld_producttoolfield);
set @tabid = (select tabid from ld_tab where `name` = 'SendCashBill');
SET @columnname = 'tax_amount';
SET @trantable='ld_producttoolfield';
SET @allowhide = 'yes';
SET @fieldlabel = '价税合计';
SET @zh='价税合计';
SET @en='Tax-inclusive Amount';
SET @uitype = 28;
SET @typeofdata='N~O~25,6';
SET @bigtype='';
SET @parentbigtype='';
SET @sequence = (SELECT IFNULL(MAX(sequence),1) FROM ld_producttoolfield where tabid=@tabid);
SET @tablename = 'ld_sendcashbill2payment';
SET @sourcemodule = 'PurchaseOrder';
INSERT INTO ld_producttoolfield(producttoolfieldid,columnname,allowhide,fieldlabel,defaultvalue,presence,uitype,typeofdata,sequence,tabid,tablename,width,edit_permission,input_type,
fieldid,newline,defaultcolumn,is_checkimportfield,nullfield,referencemodule,datarange,approve_demand,maxrowsshow,bigtype,savedatabase,parentbigtype,sourcemodule)
SELECT @producttoolfieldid,@columnname,@allowhide,@fieldlabel,NULL,0,@uitype,@typeofdata,@sequence+1,@tabid,@tablename,22,1,0,0,0,1,0,1,'','','',0,@bigtype,'yes',@parentbigtype,@sourcemodule from dual
WHERE NOT EXISTS (SELECT 1 FROM ld_producttoolfield WHERE tabid=@tabid AND columnname=@columnname and tablename=@tablename and sourcemodule=@sourcemodule);

SET @relatedid = (SELECT producttoolfieldid FROM ld_producttoolfield WHERE tabid=@tabid AND columnname=@columnname and sourcemodule=@sourcemodule LIMIT 1);
INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
SELECT 'zh',@trantable,@tabid,@relatedid,@zh  from dual
WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE languagetype = 'zh' and tabid=@tabid and relateid=@relatedid AND trantable=@trantable);
INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
SELECT 'en',@trantable,@tabid,@relatedid,@en  from dual
WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE languagetype = 'en' and tabid=@tabid and relateid=@relatedid AND trantable=@trantable);
CALL AddColumn('ld_sendcashbill2payment','tax_amount','decimal',25,'');
update ld_producttoolfield_seq set id = (select max(producttoolfieldid) from ld_producttoolfield);
delimiter;




SET @producttoolfieldid=(SELECT MAX(producttoolfieldid)+1 FROM ld_producttoolfield);
set @tabid = (select tabid from ld_tab where `name` = 'SendCashBill');
SET @columnname = 'product_pay_amount';
SET @trantable='ld_producttoolfield';
SET @allowhide = 'yes';
SET @fieldlabel = '产品已付总额';
SET @zh='产品已付总额';
SET @en='Pay Amount';
SET @uitype = 50;
SET @typeofdata='NN~O~25,3';
SET @bigtype='';
SET @parentbigtype='';
SET @sequence = (SELECT IFNULL(MAX(sequence),1) FROM ld_producttoolfield where tabid=@tabid);
SET @tablename = 'ld_sendcashbill2payment';
SET @sourcemodule = 'PurchaseOrder';
INSERT INTO ld_producttoolfield(producttoolfieldid,columnname,allowhide,fieldlabel,defaultvalue,presence,uitype,typeofdata,sequence,tabid,tablename,width,edit_permission,input_type,
fieldid,newline,defaultcolumn,is_checkimportfield,nullfield,referencemodule,datarange,approve_demand,maxrowsshow,bigtype,savedatabase,parentbigtype,sourcemodule)
SELECT @producttoolfieldid,@columnname,@allowhide,@fieldlabel,NULL,0,@uitype,@typeofdata,@sequence+1,@tabid,@tablename,22,1,0,0,1,1,0,1,'','','',0,@bigtype,'no',@parentbigtype,@sourcemodule from dual
WHERE NOT EXISTS (SELECT 1 FROM ld_producttoolfield WHERE tabid=@tabid AND columnname=@columnname and tablename=@tablename  and sourcemodule=@sourcemodule);

SET @relatedid = (SELECT producttoolfieldid FROM ld_producttoolfield WHERE tabid=@tabid AND columnname=@columnname  and sourcemodule=@sourcemodule LIMIT 1);
INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
SELECT 'zh',@trantable,@tabid,@relatedid,@zh  from dual
WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE languagetype = 'zh' and tabid=@tabid and relateid=@relatedid AND trantable=@trantable);
INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
SELECT 'en',@trantable,@tabid,@relatedid,@en  from dual
WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE languagetype = 'en' and tabid=@tabid and relateid=@relatedid AND trantable=@trantable);
CALL AddColumn('ld_sendcashbill2payment','product_pay_amount','decimal',25,'');
update ld_producttoolfield_seq set id = (select max(producttoolfieldid) from ld_producttoolfield);
delimiter;


SET @producttoolfieldid=(SELECT MAX(producttoolfieldid)+1 FROM ld_producttoolfield);
set @tabid = (select tabid from ld_tab where `name` = 'SendCashBill');
SET @columnname = 'amount';
SET @trantable='ld_producttoolfield';
SET @allowhide = 'no';
SET @fieldlabel = '本次付款金额';
SET @zh='本次付款金额';
SET @en='The amount payment';
SET @uitype = 50;
SET @typeofdata='NN~O~25,3';
SET @bigtype='';
SET @parentbigtype='';
SET @sequence = (SELECT IFNULL(MAX(sequence),1) FROM ld_producttoolfield where tabid=@tabid);
SET @tablename = 'ld_sendcashbill2payment';
SET @sourcemodule = 'PurchaseOrder';
INSERT INTO ld_producttoolfield(producttoolfieldid,columnname,allowhide,fieldlabel,defaultvalue,presence,uitype,typeofdata,sequence,tabid,tablename,width,edit_permission,input_type,
fieldid,newline,defaultcolumn,is_checkimportfield,nullfield,referencemodule,datarange,approve_demand,maxrowsshow,bigtype,savedatabase,parentbigtype,sourcemodule)
SELECT @producttoolfieldid,@columnname,@allowhide,@fieldlabel,NULL,0,@uitype,@typeofdata,@sequence+1,@tabid,@tablename,35,0,0,0,0,1,0,1,'','','',0,@bigtype,'yes',@parentbigtype,@sourcemodule from dual
WHERE NOT EXISTS (SELECT 1 FROM ld_producttoolfield WHERE tabid=@tabid AND columnname=@columnname and tablename=@tablename  and sourcemodule=@sourcemodule);

SET @relatedid = (SELECT producttoolfieldid FROM ld_producttoolfield WHERE tabid=@tabid AND columnname=@columnname  and sourcemodule=@sourcemodule LIMIT 1);
INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
SELECT 'zh',@trantable,@tabid,@relatedid,@zh  from dual
WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE languagetype = 'zh' and tabid=@tabid and relateid=@relatedid AND trantable=@trantable);
INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
SELECT 'en',@trantable,@tabid,@relatedid,@en  from dual
WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE languagetype = 'en' and tabid=@tabid and relateid=@relatedid AND trantable=@trantable);

update ld_producttoolfield_seq set id = (select max(producttoolfieldid) from ld_producttoolfield);
delimiter;



SET @producttoolfieldid=(SELECT MAX(producttoolfieldid)+1 FROM ld_producttoolfield);
set @tabid = (select tabid from ld_tab where `name` = 'SendCashBill');
SET @columnname = 'total';
SET @trantable='ld_producttoolfield';
SET @allowhide = 'no';
SET @fieldlabel = '实际付款金额';
SET @zh='实际付款金额';
SET @en='Actual payment amount';
SET @uitype = 50;
SET @typeofdata='NN~O~25,3';
SET @bigtype='';
SET @parentbigtype='';
SET @sequence = (SELECT IFNULL(MAX(sequence),1) FROM ld_producttoolfield where tabid=@tabid);
SET @tablename = 'ld_sendcashbill2payment';
SET @sourcemodule = 'PurchaseOrder';
INSERT INTO ld_producttoolfield(producttoolfieldid,columnname,allowhide,fieldlabel,defaultvalue,presence,uitype,typeofdata,sequence,tabid,tablename,width,edit_permission,input_type,
fieldid,newline,defaultcolumn,is_checkimportfield,nullfield,referencemodule,datarange,approve_demand,maxrowsshow,bigtype,savedatabase,parentbigtype,sourcemodule)
SELECT @producttoolfieldid,@columnname,@allowhide,@fieldlabel,NULL,0,@uitype,@typeofdata,@sequence+1,@tabid,@tablename,35,1,0,0,1,1,0,1,'','','',0,@bigtype,'yes',@parentbigtype,@sourcemodule from dual
WHERE NOT EXISTS (SELECT 1 FROM ld_producttoolfield WHERE tabid=@tabid AND columnname=@columnname and tablename=@tablename  and sourcemodule=@sourcemodule);

SET @relatedid = (SELECT producttoolfieldid FROM ld_producttoolfield WHERE tabid=@tabid AND columnname=@columnname  and sourcemodule=@sourcemodule LIMIT 1);
INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
SELECT 'zh',@trantable,@tabid,@relatedid,@zh  from dual
WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE languagetype = 'zh' and tabid=@tabid and relateid=@relatedid AND trantable=@trantable);
INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
SELECT 'en',@trantable,@tabid,@relatedid,@en  from dual
WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE languagetype = 'en' and tabid=@tabid and relateid=@relatedid AND trantable=@trantable);

update ld_producttoolfield_seq set id = (select max(producttoolfieldid) from ld_producttoolfield);
delimiter;

-- 采购发票-非产品分录
SET @tabdetailfieldid=(SELECT MAX(tabdetailfieldid)+1 FROM ld_tabdetailfield);
set @tabid = (select tabid from ld_tab where `name` = 'SendCashBill');
SET @columnname = 'entitytype';
SET @trantable='ld_tabdetailfield';
SET @allowhide = 'no';
SET @fieldlabel = '源单类型';
SET @zh='源单类型';
SET @en='Link To';
SET @uitype = 'entitytype';
SET @typeofdata='V~O';
SET @bigtype='';
SET @parentbigtype='';
SET @sequence = (SELECT IFNULL(MAX(sequence),1) FROM ld_tabdetailfield where tabid=@tabid);
SET @tablename = 'ld_sendcashbill2payment';
SET @sourcemodule = 'PurchaseInvoice';
INSERT INTO ld_tabdetailfield(tabdetailfieldid,columnname,allowhide,fieldlabel,defaultvalue,presence,fieldtype,typeofdata,sequence,tabid,tablename,width,edit_permission,input_type,
fieldid,newline,defaultcolumn,is_checkimportfield,nullfield,referencemodule,datarange,approve_demand,maxrowsshow,bigtype,savedatabase,parentbigtype,sourcemodule)
SELECT @tabdetailfieldid,@columnname,@allowhide,@fieldlabel,NULL,0,@uitype,@typeofdata,@sequence+1,@tabid,@tablename,22,1,0,0,0,1,0,1,'','','',0,@bigtype,'yes',@parentbigtype,@sourcemodule from dual
WHERE NOT EXISTS (SELECT 1 FROM ld_tabdetailfield WHERE tabid=@tabid AND columnname=@columnname and tablename=@tablename and sourcemodule=@sourcemodule);

SET @relatedid = (SELECT tabdetailfieldid FROM ld_tabdetailfield WHERE tabid=@tabid AND columnname=@columnname  and sourcemodule=@sourcemodule LIMIT 1);
INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
SELECT 'zh',@trantable,@tabid,@relatedid,@zh  from dual
WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE languagetype = 'zh' and tabid=@tabid and relateid=@relatedid AND trantable=@trantable);
INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
SELECT 'en',@trantable,@tabid,@relatedid,@en  from dual
WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE languagetype = 'en' and tabid=@tabid and relateid=@relatedid AND trantable=@trantable);
CALL AddColumn(@tablename,@columnname,'varchar',25,'');
update ld_tabdetailfield_seq set id = (select max(tabdetailfieldid) from ld_tabdetailfield);
delimiter;

SET @tabdetailfieldid=(SELECT MAX(tabdetailfieldid)+1 FROM ld_tabdetailfield);
set @tabid = (select tabid from ld_tab where `name` = 'SendCashBill');
SET @columnname = 'entitytypeid';
SET @trantable='ld_tabdetailfield';
SET @allowhide = 'no';
SET @fieldlabel = '源单';
SET @zh='源单';
SET @en='Orignal Bill';
SET @uitype = 'SelectSource';
SET @typeofdata='V~O~100';
SET @bigtype='selectsource';
SET @parentbigtype='';
SET @sequence = (SELECT IFNULL(MAX(sequence),1) FROM ld_tabdetailfield where tabid=@tabid);
SET @tablename = 'ld_sendcashbill2payment';
SET @sourcemodule = 'PurchaseInvoice';
INSERT INTO ld_tabdetailfield(tabdetailfieldid,columnname,allowhide,fieldlabel,defaultvalue,presence,fieldtype,typeofdata,sequence,tabid,tablename,width,edit_permission,input_type,
fieldid,newline,defaultcolumn,is_checkimportfield,nullfield,referencemodule,datarange,approve_demand,maxrowsshow,bigtype,savedatabase,parentbigtype,sourcemodule)
SELECT @tabdetailfieldid,@columnname,@allowhide,@fieldlabel,NULL,0,@uitype,@typeofdata,@sequence+1,@tabid,@tablename,22,1,0,0,0,1,0,1,NULL,NULL,NULL,0,@bigtype,'yes',@parentbigtype,@sourcemodule from dual
WHERE NOT EXISTS (SELECT 1 FROM ld_tabdetailfield WHERE tabid=@tabid AND columnname=@columnname and tablename=@tablename and sourcemodule=@sourcemodule);

SET @relatedid = (SELECT tabdetailfieldid FROM ld_tabdetailfield WHERE tabid=@tabid AND columnname=@columnname and sourcemodule=@sourcemodule LIMIT 1);
INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
SELECT 'zh',@trantable,@tabid,@relatedid,@zh  from dual
WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE languagetype = 'zh' and tabid=@tabid and relateid=@relatedid AND trantable=@trantable);
INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
SELECT 'en',@trantable,@tabid,@relatedid,@en  from dual
WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE languagetype = 'en' and tabid=@tabid and relateid=@relatedid AND trantable=@trantable);
CALL AddColumn(@tablename,@columnname,'int',11,'');
update ld_tabdetailfield_seq set id = (select max(tabdetailfieldid) from ld_tabdetailfield);
delimiter;

SET @tabdetailfieldid=(SELECT MAX(tabdetailfieldid)+1 FROM ld_tabdetailfield);
set @tabid = (select tabid from ld_tab where `name` = 'SendCashBill');
SET @columnname = 'tablesourcetype';
SET @trantable='ld_tabdetailfield';
SET @allowhide = 'yes';
SET @fieldlabel = '源单源单类型';
SET @zh='源单源单类型';
SET @en='Source Type';
SET @uitype = 'entitytype';
SET @typeofdata='V~O';
SET @bigtype='relatedmodulefield';
SET @parentbigtype='entitytype';
SET @sequence = (SELECT IFNULL(MAX(sequence),1) FROM ld_tabdetailfield where tabid=@tabid);
SET @tablename = 'ld_sendcashbill2payment';
SET @sourcemodule = 'PurchaseInvoice';
INSERT INTO ld_tabdetailfield(tabdetailfieldid,columnname,allowhide,fieldlabel,defaultvalue,presence,fieldtype,typeofdata,sequence,tabid,tablename,width,edit_permission,input_type,
fieldid,newline,defaultcolumn,is_checkimportfield,nullfield,referencemodule,datarange,approve_demand,maxrowsshow,bigtype,savedatabase,parentbigtype,sourcemodule)
SELECT @tabdetailfieldid,@columnname,@allowhide,@fieldlabel,NULL,0,@uitype,@typeofdata,@sequence+1,@tabid,@tablename,22,1,0,0,0,1,0,1,NULL,NULL,NULL,0,@bigtype,'no',@parentbigtype,@sourcemodule from dual
WHERE NOT EXISTS (SELECT 1 FROM ld_tabdetailfield WHERE tabid=@tabid AND columnname=@columnname and tablename=@tablename and sourcemodule=@sourcemodule);

SET @relatedid = (SELECT tabdetailfieldid FROM ld_tabdetailfield WHERE tabid=@tabid AND columnname=@columnname and sourcemodule=@sourcemodule LIMIT 1);
INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
SELECT 'zh',@trantable,@tabid,@relatedid,@zh  from dual
WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE languagetype = 'zh' and tabid=@tabid and relateid=@relatedid AND trantable=@trantable);
INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
SELECT 'en',@trantable,@tabid,@relatedid,@en  from dual
WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE languagetype = 'en' and tabid=@tabid and relateid=@relatedid AND trantable=@trantable);
CALL AddColumn(@tablename,@columnname,'varchar',25,'');
update ld_tabdetailfield_seq set id = (select max(tabdetailfieldid) from ld_tabdetailfield);
delimiter;

SET @tabdetailfieldid=(SELECT MAX(tabdetailfieldid)+1 FROM ld_tabdetailfield);
set @tabid = (select tabid from ld_tab where `name` = 'SendCashBill');
SET @columnname = 'tablesourceid';
SET @trantable='ld_tabdetailfield';
SET @allowhide = 'yes';
SET @fieldlabel = '源单源单';
SET @zh='源单源单';
SET @en='Source Bill';
SET @uitype = 'SelectSource';
SET @typeofdata='V~O';
SET @bigtype='relatedmodulefield';
SET @parentbigtype='selectsource';
SET @sequence = (SELECT IFNULL(MAX(sequence),1) FROM ld_tabdetailfield where tabid=@tabid);
SET @tablename = 'ld_sendcashbill2payment';
SET @sourcemodule = 'PurchaseInvoice';
INSERT INTO ld_tabdetailfield(tabdetailfieldid,columnname,allowhide,fieldlabel,defaultvalue,presence,fieldtype,typeofdata,sequence,tabid,tablename,width,edit_permission,input_type,
fieldid,newline,defaultcolumn,is_checkimportfield,nullfield,referencemodule,datarange,approve_demand,maxrowsshow,bigtype,savedatabase,parentbigtype,sourcemodule)
SELECT @tabdetailfieldid,@columnname,@allowhide,@fieldlabel,NULL,0,@uitype,@typeofdata,@sequence+1,@tabid,@tablename,22,1,0,0,0,1,0,1,NULL,NULL,NULL,0,@bigtype,'no',@parentbigtype,@sourcemodule from dual
WHERE NOT EXISTS (SELECT 1 FROM ld_tabdetailfield WHERE tabid=@tabid AND columnname=@columnname and tablename=@tablename and sourcemodule=@sourcemodule);

SET @relatedid = (SELECT tabdetailfieldid FROM ld_tabdetailfield WHERE tabid=@tabid AND columnname=@columnname and sourcemodule=@sourcemodule LIMIT 1);
INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
SELECT 'zh',@trantable,@tabid,@relatedid,@zh  from dual
WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE languagetype = 'zh' and tabid=@tabid and relateid=@relatedid AND trantable=@trantable);
INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
SELECT 'en',@trantable,@tabid,@relatedid,@en  from dual
WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE languagetype = 'en' and tabid=@tabid and relateid=@relatedid AND trantable=@trantable);
CALL AddColumn(@tablename,@columnname,'varchar',25,'');
update ld_tabdetailfield_seq set id = (select max(tabdetailfieldid) from ld_tabdetailfield);
delimiter;

SET @tabdetailfieldid=(SELECT MAX(tabdetailfieldid)+1 FROM ld_tabdetailfield);
set @tabid = (select tabid from ld_tab where `name` = 'SendCashBill');
SET @columnname = 'billdate';
SET @trantable='ld_tabdetailfield';
SET @allowhide = 'yes';
SET @fieldlabel = '源单日期';
SET @zh='源单日期';
SET @en='Source Date';
SET @uitype = 'Date_Ymd';
SET @typeofdata='D~O';
SET @bigtype='relatedmodulefield';
SET @parentbigtype='date';
SET @sequence = (SELECT IFNULL(MAX(sequence),1) FROM ld_tabdetailfield where tabid=@tabid);
SET @tablename = 'ld_sendcashbill2payment';
SET @sourcemodule = 'PurchaseInvoice';
INSERT INTO ld_tabdetailfield(tabdetailfieldid,columnname,allowhide,fieldlabel,defaultvalue,presence,fieldtype,typeofdata,sequence,tabid,tablename,width,edit_permission,input_type,
fieldid,newline,defaultcolumn,is_checkimportfield,nullfield,referencemodule,datarange,approve_demand,maxrowsshow,bigtype,savedatabase,parentbigtype,sourcemodule)
SELECT @tabdetailfieldid,@columnname,@allowhide,@fieldlabel,NULL,0,@uitype,@typeofdata,@sequence+1,@tabid,@tablename,30,1,0,0,0,1,0,1,NULL,NULL,NULL,0,@bigtype,'no',@parentbigtype,@sourcemodule from dual
WHERE NOT EXISTS (SELECT 1 FROM ld_tabdetailfield WHERE tabid=@tabid AND columnname=@columnname and tablename=@tablename and sourcemodule=@sourcemodule);

SET @relatedid = (SELECT tabdetailfieldid FROM ld_tabdetailfield WHERE tabid=@tabid AND columnname=@columnname and sourcemodule=@sourcemodule LIMIT 1);
INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
SELECT 'zh',@trantable,@tabid,@relatedid,@zh  from dual
WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE languagetype = 'zh' and tabid=@tabid and relateid=@relatedid AND trantable=@trantable);
INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
SELECT 'en',@trantable,@tabid,@relatedid,@en  from dual
WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE languagetype = 'en' and tabid=@tabid and relateid=@relatedid AND trantable=@trantable);
CALL AddColumn(@tablename,@columnname,'date','','');
update ld_tabdetailfield_seq set id = (select max(tabdetailfieldid) from ld_tabdetailfield);
delimiter;


SET @tabdetailfieldid=(SELECT MAX(tabdetailfieldid)+1 FROM ld_tabdetailfield);
set @tabid = (select tabid from ld_tab where `name` = 'SendCashBill');
SET @columnname = 'source_total';
SET @trantable='ld_tabdetailfield';
SET @allowhide = 'yes';
SET @fieldlabel = '源单金额';
SET @zh='源单金额';
SET @en='Source Amount';
SET @uitype = 'Amount';
SET @typeofdata='N~O~25,6';
SET @bigtype='relatedmodulefield';
SET @parentbigtype='amount';
SET @sequence = (SELECT IFNULL(MAX(sequence),1) FROM ld_tabdetailfield where tabid=@tabid);
SET @tablename = 'ld_sendcashbill2payment';
SET @sourcemodule = 'PurchaseInvoice';
INSERT INTO ld_tabdetailfield(tabdetailfieldid,columnname,allowhide,fieldlabel,defaultvalue,presence,fieldtype,typeofdata,sequence,tabid,tablename,width,edit_permission,input_type,
fieldid,newline,defaultcolumn,is_checkimportfield,nullfield,referencemodule,datarange,approve_demand,maxrowsshow,bigtype,savedatabase,parentbigtype,sourcemodule)
SELECT @tabdetailfieldid,@columnname,@allowhide,@fieldlabel,NULL,0,@uitype,@typeofdata,@sequence+1,@tabid,@tablename,30,1,0,0,0,1,0,1,NULL,NULL,NULL,0,@bigtype,'no',@parentbigtype,@sourcemodule from dual
WHERE NOT EXISTS (SELECT 1 FROM ld_tabdetailfield WHERE tabid=@tabid AND columnname=@columnname and tablename=@tablename and sourcemodule=@sourcemodule);

SET @relatedid = (SELECT tabdetailfieldid FROM ld_tabdetailfield WHERE tabid=@tabid AND columnname=@columnname and sourcemodule=@sourcemodule LIMIT 1);
INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
SELECT 'zh',@trantable,@tabid,@relatedid,@zh  from dual
WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE languagetype = 'zh' and tabid=@tabid and relateid=@relatedid AND trantable=@trantable);
INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
SELECT 'en',@trantable,@tabid,@relatedid,@en  from dual
WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE languagetype = 'en' and tabid=@tabid and relateid=@relatedid AND trantable=@trantable);
CALL AddColumn(@tablename,@columnname,'decimal','25','0.000000');
update ld_tabdetailfield_seq set id = (select max(tabdetailfieldid) from ld_tabdetailfield);
delimiter;


SET @tabdetailfieldid=(SELECT MAX(tabdetailfieldid)+1 FROM ld_tabdetailfield);
set @tabid = (select tabid from ld_tab where `name` = 'SendCashBill');
SET @columnname = 'pay_amount';
SET @trantable='ld_tabdetailfield';
SET @allowhide = 'yes';
SET @fieldlabel = '源单已付总额';
SET @zh='源单已付总额';
SET @en='Pay Amount';
SET @uitype = 'Amount';
SET @typeofdata='N~O~25,6';
SET @bigtype='relatedmodulefield';
SET @parentbigtype='amount';
SET @sequence = (SELECT IFNULL(MAX(sequence),1) FROM ld_tabdetailfield where tabid=@tabid);
SET @tablename = 'ld_sendcashbill2payment';
SET @sourcemodule = 'PurchaseInvoice';
INSERT INTO ld_tabdetailfield(tabdetailfieldid,columnname,allowhide,fieldlabel,defaultvalue,presence,fieldtype,typeofdata,sequence,tabid,tablename,width,edit_permission,input_type,
fieldid,newline,defaultcolumn,is_checkimportfield,nullfield,referencemodule,datarange,approve_demand,maxrowsshow,bigtype,savedatabase,parentbigtype,sourcemodule)
SELECT @tabdetailfieldid,@columnname,@allowhide,@fieldlabel,NULL,0,@uitype,@typeofdata,@sequence+1,@tabid,@tablename,30,1,0,0,0,1,0,1,NULL,NULL,NULL,0,@bigtype,'no',@parentbigtype,@sourcemodule from dual
WHERE NOT EXISTS (SELECT 1 FROM ld_tabdetailfield WHERE tabid=@tabid AND columnname=@columnname and tablename=@tablename and sourcemodule=@sourcemodule);

SET @relatedid = (SELECT tabdetailfieldid FROM ld_tabdetailfield WHERE tabid=@tabid AND columnname=@columnname and sourcemodule=@sourcemodule LIMIT 1);
INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
SELECT 'zh',@trantable,@tabid,@relatedid,@zh  from dual
WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE languagetype = 'zh' and tabid=@tabid and relateid=@relatedid AND trantable=@trantable);
INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
SELECT 'en',@trantable,@tabid,@relatedid,@en  from dual
WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE languagetype = 'en' and tabid=@tabid and relateid=@relatedid AND trantable=@trantable);
CALL AddColumn(@tablename,@columnname,'decimal','25','0.000000');
update ld_tabdetailfield_seq set id = (select max(tabdetailfieldid) from ld_tabdetailfield);
delimiter;

SET @tabdetailfieldid=(SELECT MAX(tabdetailfieldid)+1 FROM ld_tabdetailfield);
set @tabid = (select tabid from ld_tab where `name` = 'SendCashBill');
SET @columnname = 'amount';
SET @trantable='ld_tabdetailfield';
SET @allowhide = 'no';
SET @fieldlabel = '本次付款金额';
SET @zh='本次付款金额';
SET @en='The amount payment';
SET @uitype = 'Amount';
SET @typeofdata='N~O~25,6';
SET @bigtype='amount';
SET @parentbigtype='';
SET @sequence = (SELECT IFNULL(MAX(sequence),1) FROM ld_tabdetailfield where tabid=@tabid);
SET @tablename = 'ld_sendcashbill2payment';
SET @sourcemodule = 'PurchaseInvoice';
INSERT INTO ld_tabdetailfield(tabdetailfieldid,columnname,allowhide,fieldlabel,defaultvalue,presence,fieldtype,typeofdata,sequence,tabid,tablename,width,edit_permission,input_type,
fieldid,newline,defaultcolumn,is_checkimportfield,nullfield,referencemodule,datarange,approve_demand,maxrowsshow,bigtype,savedatabase,parentbigtype,sourcemodule)
SELECT @tabdetailfieldid,@columnname,@allowhide,@fieldlabel,NULL,0,@uitype,@typeofdata,@sequence+1,@tabid,@tablename,30,0,0,0,0,1,0,1,NULL,NULL,NULL,0,@bigtype,'yes',@parentbigtype,@sourcemodule from dual
WHERE NOT EXISTS (SELECT 1 FROM ld_tabdetailfield WHERE tabid=@tabid AND columnname=@columnname and tablename=@tablename and sourcemodule=@sourcemodule);

SET @relatedid = (SELECT tabdetailfieldid FROM ld_tabdetailfield WHERE tabid=@tabid AND columnname=@columnname and sourcemodule=@sourcemodule LIMIT 1);
INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
SELECT 'zh',@trantable,@tabid,@relatedid,@zh  from dual
WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE languagetype = 'zh' and tabid=@tabid and relateid=@relatedid AND trantable=@trantable);
INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
SELECT 'en',@trantable,@tabid,@relatedid,@en  from dual
WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE languagetype = 'en' and tabid=@tabid and relateid=@relatedid AND trantable=@trantable);
CALL AddColumn(@tablename,@columnname,'decimal','25','0.00');
update ld_tabdetailfield_seq set id = (select max(tabdetailfieldid) from ld_tabdetailfield);
delimiter;

SET @tabdetailfieldid=(SELECT MAX(tabdetailfieldid)+1 FROM ld_tabdetailfield);
set @tabid = (select tabid from ld_tab where `name` = 'SendCashBill');
SET @columnname = 'total';
SET @trantable='ld_tabdetailfield';
SET @allowhide = 'no';
SET @fieldlabel = '实际付款金额';
SET @zh='实际付款金额';
SET @en='Actual payment amount';
SET @uitype = 'Amount';
SET @typeofdata='N~O~25,6';
SET @bigtype='';
SET @parentbigtype='';
SET @sequence = (SELECT IFNULL(MAX(sequence),1) FROM ld_tabdetailfield where tabid=@tabid);
SET @tablename = 'ld_sendcashbill2payment';
SET @sourcemodule = 'PurchaseInvoice';
INSERT INTO ld_tabdetailfield(tabdetailfieldid,columnname,allowhide,fieldlabel,defaultvalue,presence,fieldtype,typeofdata,sequence,tabid,tablename,width,edit_permission,input_type,
fieldid,newline,defaultcolumn,is_checkimportfield,nullfield,referencemodule,datarange,approve_demand,maxrowsshow,bigtype,savedatabase,parentbigtype,sourcemodule)
SELECT @tabdetailfieldid,@columnname,@allowhide,@fieldlabel,NULL,0,@uitype,@typeofdata,@sequence+1,@tabid,@tablename,30,1,0,0,1,1,0,1,NULL,NULL,NULL,0,@bigtype,'yes',@parentbigtype,@sourcemodule from dual
WHERE NOT EXISTS (SELECT 1 FROM ld_tabdetailfield WHERE tabid=@tabid AND columnname=@columnname and tablename=@tablename and sourcemodule=@sourcemodule);

SET @relatedid = (SELECT tabdetailfieldid FROM ld_tabdetailfield WHERE tabid=@tabid AND columnname=@columnname and sourcemodule=@sourcemodule LIMIT 1);
INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
SELECT 'zh',@trantable,@tabid,@relatedid,@zh  from dual
WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE languagetype = 'zh' and tabid=@tabid and relateid=@relatedid AND trantable=@trantable);
INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
SELECT 'en',@trantable,@tabid,@relatedid,@en  from dual
WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE languagetype = 'en' and tabid=@tabid and relateid=@relatedid AND trantable=@trantable);
CALL AddColumn(@tablename,@columnname,'decimal','25','0.000000');
update ld_tabdetailfield_seq set id = (select max(tabdetailfieldid) from ld_tabdetailfield);
delimiter;
	-- 采购发票-产品分录
SET @producttoolfieldid=(SELECT MAX(producttoolfieldid)+1 FROM ld_producttoolfield);
set @tabid = (select tabid from ld_tab where `name` = 'SendCashBill');
SET @columnname = 'entitytype';
SET @trantable='ld_producttoolfield';
SET @allowhide = 'no';
SET @fieldlabel = '源单类型';
SET @zh='源单类型';
SET @en='Link To';
SET @uitype = 204;
SET @typeofdata='V~O~100';
SET @bigtype='';
SET @parentbigtype='';
SET @sequence = (SELECT IFNULL(MAX(sequence),1) FROM ld_producttoolfield where tabid=@tabid);
SET @tablename = 'ld_sendcashbill2payment';
SET @sourcemodule = 'PurchaseInvoice';
INSERT INTO ld_producttoolfield(producttoolfieldid,columnname,allowhide,fieldlabel,defaultvalue,presence,uitype,typeofdata,sequence,tabid,tablename,width,edit_permission,input_type,
fieldid,newline,defaultcolumn,is_checkimportfield,nullfield,referencemodule,datarange,approve_demand,maxrowsshow,bigtype,savedatabase,parentbigtype,sourcemodule)
SELECT @producttoolfieldid,@columnname,@allowhide,@fieldlabel,NULL,0,@uitype,@typeofdata,@sequence+1,@tabid,@tablename,30,1,0,0,0,1,0,1,'','','',0,@bigtype,'yes',@parentbigtype,@sourcemodule from dual
WHERE NOT EXISTS (SELECT 1 FROM ld_producttoolfield WHERE tabid=@tabid AND columnname=@columnname and tablename=@tablename and sourcemodule=@sourcemodule);

SET @relatedid = (SELECT producttoolfieldid FROM ld_producttoolfield WHERE tabid=@tabid AND columnname=@columnname and sourcemodule=@sourcemodule LIMIT 1);
INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
SELECT 'zh',@trantable,@tabid,@relatedid,@zh  from dual
WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE languagetype = 'zh' and tabid=@tabid and relateid=@relatedid AND trantable=@trantable);
INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
SELECT 'en',@trantable,@tabid,@relatedid,@en  from dual
WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE languagetype = 'en' and tabid=@tabid and relateid=@relatedid AND trantable=@trantable);
CALL AddColumn(@tablename,@columnname,'varchar',25,'');
update ld_producttoolfield_seq set id = (select max(producttoolfieldid) from ld_producttoolfield);
delimiter;



SET @producttoolfieldid=(SELECT MAX(producttoolfieldid)+1 FROM ld_producttoolfield);
set @tabid = (select tabid from ld_tab where `name` = 'SendCashBill');
SET @columnname = 'entitytypeid';
SET @trantable='ld_producttoolfield';
SET @allowhide = 'no';
SET @fieldlabel = '源单';
SET @zh='源单';
SET @en='Orignal Bill';
SET @uitype = 202;
SET @typeofdata='V~O~100';
SET @bigtype='selectsource';
SET @parentbigtype='';
SET @sequence = (SELECT IFNULL(MAX(sequence),1) FROM ld_producttoolfield where tabid=@tabid);
SET @tablename = 'ld_sendcashbill2payment';
SET @sourcemodule = 'PurchaseInvoice';
INSERT INTO ld_producttoolfield(producttoolfieldid,columnname,allowhide,fieldlabel,defaultvalue,presence,uitype,typeofdata,sequence,tabid,tablename,width,edit_permission,input_type,
fieldid,newline,defaultcolumn,is_checkimportfield,nullfield,referencemodule,datarange,approve_demand,maxrowsshow,bigtype,savedatabase,parentbigtype,sourcemodule)
SELECT @producttoolfieldid,@columnname,@allowhide,@fieldlabel,NULL,0,@uitype,@typeofdata,@sequence+1,@tabid,@tablename,22,1,0,0,0,1,0,1,'','','',0,@bigtype,'yes',@parentbigtype,@sourcemodule from dual
WHERE NOT EXISTS (SELECT 1 FROM ld_producttoolfield WHERE tabid=@tabid AND columnname=@columnname and tablename=@tablename and sourcemodule=@sourcemodule);

SET @relatedid = (SELECT producttoolfieldid FROM ld_producttoolfield WHERE tabid=@tabid AND columnname=@columnname and sourcemodule=@sourcemodule LIMIT 1);
INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
SELECT 'zh',@trantable,@tabid,@relatedid,@zh  from dual
WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE languagetype = 'zh' and tabid=@tabid and relateid=@relatedid AND trantable=@trantable);
INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
SELECT 'en',@trantable,@tabid,@relatedid,@en  from dual
WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE languagetype = 'en' and tabid=@tabid and relateid=@relatedid AND trantable=@trantable);
CALL AddColumn(@tablename,@columnname,'int',11,'');
update ld_producttoolfield_seq set id = (select max(producttoolfieldid) from ld_producttoolfield);
delimiter;


SET @producttoolfieldid=(SELECT MAX(producttoolfieldid)+1 FROM ld_producttoolfield);
set @tabid = (select tabid from ld_tab where `name` = 'SendCashBill');
SET @columnname = 'productname';
SET @trantable='ld_producttoolfield';
SET @allowhide = 'no';
SET @fieldlabel = '产品名称';
SET @zh='产品名称';
SET @en='Product Name';
SET @uitype = 70;
SET @typeofdata='V~M~100';
SET @bigtype='selectsource';
SET @parentbigtype='';
SET @sequence = (SELECT IFNULL(MAX(sequence),1) FROM ld_producttoolfield where tabid=@tabid);
SET @tablename = 'ld_products';
SET @sourcemodule = 'PurchaseInvoice';
SET @producttabid = (select tabid from ld_tab where `name`='Products');
set @fieldid=(select fieldid from ld_field where tabid = @producttabid and fieldname = 'productname');
INSERT INTO ld_producttoolfield(producttoolfieldid,columnname,allowhide,fieldlabel,defaultvalue,presence,uitype,typeofdata,sequence,tabid,tablename,width,edit_permission,input_type,
fieldid,newline,defaultcolumn,is_checkimportfield,nullfield,referencemodule,datarange,approve_demand,maxrowsshow,bigtype,savedatabase,parentbigtype,sourcemodule)
SELECT @producttoolfieldid,@columnname,@allowhide,@fieldlabel,NULL,0,@uitype,@typeofdata,@sequence+1,@tabid,@tablename,45,0,0,@fieldid,0,2,0,0,'','','',0,@bigtype,'yes',@parentbigtype,@sourcemodule from dual
WHERE NOT EXISTS (SELECT 1 FROM ld_producttoolfield WHERE tabid=@tabid AND columnname=@columnname and tablename=@tablename and sourcemodule=@sourcemodule);

SET @relatedid = (SELECT producttoolfieldid FROM ld_producttoolfield WHERE tabid=@tabid AND columnname=@columnname and sourcemodule=@sourcemodule LIMIT 1);
INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
SELECT 'zh',@trantable,@tabid,@relatedid,@zh  from dual
WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE languagetype = 'zh' and tabid=@tabid and relateid=@relatedid AND trantable=@trantable);
INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
SELECT 'en',@trantable,@tabid,@relatedid,@en  from dual
WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE languagetype = 'en' and tabid=@tabid and relateid=@relatedid AND trantable=@trantable);
CALL AddColumn('ld_sendcashbill2payment','productid','int',11,'');
update ld_producttoolfield_seq set id = (select max(producttoolfieldid) from ld_producttoolfield);
delimiter;

SET @producttoolfieldid=(SELECT MAX(producttoolfieldid)+1 FROM ld_producttoolfield);
set @tabid = (select tabid from ld_tab where `name` = 'SendCashBill');
SET @columnname = 'product_no';
SET @trantable='ld_producttoolfield';
SET @allowhide = 'yes';
SET @fieldlabel = '产品编号';
SET @zh='产品编号';
SET @en='Product No';
SET @uitype = 4;
SET @typeofdata='V~O';
SET @bigtype='';
SET @parentbigtype='';
SET @sequence = (SELECT IFNULL(MAX(sequence),1) FROM ld_producttoolfield where tabid=@tabid);
SET @tablename = 'ld_products';
SET @sourcemodule = 'PurchaseInvoice';
SET @producttabid = (select tabid from ld_tab where `name`='Products');
SET @fieldid = (SELECT fieldid FROM ld_field where tabid=@producttabid and columnname = 'product_no');
INSERT INTO ld_producttoolfield(producttoolfieldid,columnname,allowhide,fieldlabel,defaultvalue,presence,uitype,typeofdata,sequence,tabid,tablename,width,edit_permission,input_type,
fieldid,newline,defaultcolumn,is_checkimportfield,nullfield,referencemodule,datarange,approve_demand,maxrowsshow,bigtype,savedatabase,parentbigtype,sourcemodule)
SELECT @producttoolfieldid,@columnname,@allowhide,@fieldlabel,NULL,0,@uitype,@typeofdata,@sequence+1,@tabid,@tablename,22,1,1,@fieldid,0,1,0,1,'','','',0,@bigtype,'yes',@parentbigtype,@sourcemodule from dual
WHERE NOT EXISTS (SELECT 1 FROM ld_producttoolfield WHERE tabid=@tabid AND columnname=@columnname and tablename=@tablename and sourcemodule=@sourcemodule);

SET @relatedid = (SELECT producttoolfieldid FROM ld_producttoolfield WHERE tabid=@tabid AND columnname=@columnname and sourcemodule=@sourcemodule LIMIT 1);
INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
SELECT 'zh',@trantable,@tabid,@relatedid,@zh  from dual
WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE languagetype = 'zh' and tabid=@tabid and relateid=@relatedid AND trantable=@trantable);
INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
SELECT 'en',@trantable,@tabid,@relatedid,@en  from dual
WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE languagetype = 'en' and tabid=@tabid and relateid=@relatedid AND trantable=@trantable);

update ld_producttoolfield_seq set id = (select max(producttoolfieldid) from ld_producttoolfield);
delimiter;

SET @producttoolfieldid=(SELECT MAX(producttoolfieldid)+1 FROM ld_producttoolfield);
set @tabid = (select tabid from ld_tab where `name` = 'SendCashBill');
SET @columnname = 'productsheet';
SET @trantable='ld_producttoolfield';
SET @allowhide = 'yes';
SET @fieldlabel = '规格型号';
SET @zh='规格型号';
SET @en='Specification';
SET @uitype = 1;
SET @typeofdata='V~O';
SET @bigtype='';
SET @parentbigtype='';
SET @sequence = (SELECT IFNULL(MAX(sequence),1) FROM ld_producttoolfield where tabid=@tabid);
SET @tablename = 'ld_products';
SET @sourcemodule = 'PurchaseInvoice';
SET @producttabid = (select tabid from ld_tab where `name`='Products');
SET @fieldid = (SELECT fieldid FROM ld_field where tabid=@producttabid and columnname = 'productsheet');
INSERT INTO ld_producttoolfield(producttoolfieldid,columnname,allowhide,fieldlabel,defaultvalue,presence,uitype,typeofdata,sequence,tabid,tablename,width,edit_permission,input_type,
fieldid,newline,defaultcolumn,is_checkimportfield,nullfield,referencemodule,datarange,approve_demand,maxrowsshow,bigtype,savedatabase,parentbigtype,sourcemodule)
SELECT @producttoolfieldid,@columnname,@allowhide,@fieldlabel,NULL,0,@uitype,@typeofdata,@sequence+1,@tabid,@tablename,22,1,1,@fieldid,0,1,0,1,'','','',0,@bigtype,'yes',@parentbigtype,@sourcemodule from dual
WHERE NOT EXISTS (SELECT 1 FROM ld_producttoolfield WHERE tabid=@tabid AND columnname=@columnname and tablename=@tablename and sourcemodule=@sourcemodule);

SET @relatedid = (SELECT producttoolfieldid FROM ld_producttoolfield WHERE tabid=@tabid AND columnname=@columnname and sourcemodule=@sourcemodule LIMIT 1);
INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
SELECT 'zh',@trantable,@tabid,@relatedid,@zh  from dual
WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE languagetype = 'zh' and tabid=@tabid and relateid=@relatedid AND trantable=@trantable);
INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
SELECT 'en',@trantable,@tabid,@relatedid,@en  from dual
WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE languagetype = 'en' and tabid=@tabid and relateid=@relatedid AND trantable=@trantable);

update ld_producttoolfield_seq set id = (select max(producttoolfieldid) from ld_producttoolfield);
delimiter;



SET @producttoolfieldid=(SELECT MAX(producttoolfieldid)+1 FROM ld_producttoolfield);
set @tabid = (select tabid from ld_tab where `name` = 'SendCashBill');
SET @columnname = 'productsourcetype';
SET @trantable='ld_producttoolfield';
SET @allowhide = 'yes';
SET @fieldlabel = '产品源单类型';
SET @zh='产品源单类型';
SET @en='Source Type';
SET @uitype = 221;
SET @typeofdata='V~O';
SET @bigtype='relatedmodulefield';
SET @parentbigtype='entitytype';
SET @sequence = (SELECT IFNULL(MAX(sequence),1) FROM ld_producttoolfield where tabid=@tabid);
SET @tablename = 'ld_sendcashbill2payment';
SET @sourcemodule = 'PurchaseInvoice';
INSERT INTO ld_producttoolfield(producttoolfieldid,columnname,allowhide,fieldlabel,defaultvalue,presence,uitype,typeofdata,sequence,tabid,tablename,width,edit_permission,input_type,
fieldid,newline,defaultcolumn,is_checkimportfield,nullfield,referencemodule,datarange,approve_demand,maxrowsshow,bigtype,savedatabase,parentbigtype,sourcemodule)
SELECT @producttoolfieldid,@columnname,@allowhide,@fieldlabel,NULL,0,@uitype,@typeofdata,@sequence+1,@tabid,@tablename,22,1,0,0,0,1,0,1,'','','',0,@bigtype,'no',@parentbigtype,@sourcemodule from dual
WHERE NOT EXISTS (SELECT 1 FROM ld_producttoolfield WHERE tabid=@tabid AND columnname=@columnname and tablename=@tablename and sourcemodule=@sourcemodule);

SET @relatedid = (SELECT producttoolfieldid FROM ld_producttoolfield WHERE tabid=@tabid AND columnname=@columnname and sourcemodule=@sourcemodule LIMIT 1);
INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
SELECT 'zh',@trantable,@tabid,@relatedid,@zh  from dual
WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE languagetype = 'zh' and tabid=@tabid and relateid=@relatedid AND trantable=@trantable);
INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
SELECT 'en',@trantable,@tabid,@relatedid,@en  from dual
WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE languagetype = 'en' and tabid=@tabid and relateid=@relatedid AND trantable=@trantable);
CALL AddColumn('ld_sendcashbill2payment','productsourcetype','varchar',25,'');
update ld_producttoolfield_seq set id = (select max(producttoolfieldid) from ld_producttoolfield);
delimiter;


SET @producttoolfieldid=(SELECT MAX(producttoolfieldid)+1 FROM ld_producttoolfield);
set @tabid = (select tabid from ld_tab where `name` = 'SendCashBill');
SET @columnname = 'productsourceid';
SET @trantable='ld_producttoolfield';
SET @allowhide = 'yes';
SET @fieldlabel = '产品源单';
SET @zh='产品源单';
SET @en='Source Bill';
SET @uitype = 220;
SET @typeofdata='V~O';
SET @bigtype='relatedmodulefield';
SET @parentbigtype='selectsource';
SET @sequence = (SELECT IFNULL(MAX(sequence),1) FROM ld_producttoolfield where tabid=@tabid);
SET @tablename = 'ld_sendcashbill2payment';
SET @sourcemodule = 'PurchaseInvoice';
INSERT INTO ld_producttoolfield(producttoolfieldid,columnname,allowhide,fieldlabel,defaultvalue,presence,uitype,typeofdata,sequence,tabid,tablename,width,edit_permission,input_type,
fieldid,newline,defaultcolumn,is_checkimportfield,nullfield,referencemodule,datarange,approve_demand,maxrowsshow,bigtype,savedatabase,parentbigtype,sourcemodule)
SELECT @producttoolfieldid,@columnname,@allowhide,@fieldlabel,NULL,0,@uitype,@typeofdata,@sequence+1,@tabid,@tablename,30,1,0,0,0,1,0,1,'','','',0,@bigtype,'no',@parentbigtype,@sourcemodule from dual
WHERE NOT EXISTS (SELECT 1 FROM ld_producttoolfield WHERE tabid=@tabid AND columnname=@columnname and tablename=@tablename and sourcemodule=@sourcemodule);

SET @relatedid = (SELECT producttoolfieldid FROM ld_producttoolfield WHERE tabid=@tabid AND columnname=@columnname and sourcemodule=@sourcemodule LIMIT 1);
INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
SELECT 'zh',@trantable,@tabid,@relatedid,@zh  from dual
WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE languagetype = 'zh' and tabid=@tabid and relateid=@relatedid AND trantable=@trantable);
INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
SELECT 'en',@trantable,@tabid,@relatedid,@en  from dual
WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE languagetype = 'en' and tabid=@tabid and relateid=@relatedid AND trantable=@trantable);
CALL AddColumn('ld_sendcashbill2payment','productsourceid','int',11,'');
update ld_producttoolfield_seq set id = (select max(producttoolfieldid) from ld_producttoolfield);
delimiter;


SET @producttoolfieldid=(SELECT MAX(producttoolfieldid)+1 FROM ld_producttoolfield);
set @tabid = (select tabid from ld_tab where `name` = 'SendCashBill');
SET @columnname = 'tax_amount';
SET @trantable='ld_producttoolfield';
SET @allowhide = 'yes';
SET @fieldlabel = '价税合计';
SET @zh='价税合计';
SET @en='Tax-inclusive Amount';
SET @uitype = 28;
SET @typeofdata='N~O~25,6';
SET @bigtype='';
SET @parentbigtype='';
SET @sequence = (SELECT IFNULL(MAX(sequence),1) FROM ld_producttoolfield where tabid=@tabid);
SET @tablename = 'ld_sendcashbill2payment';
SET @sourcemodule = 'PurchaseInvoice';
INSERT INTO ld_producttoolfield(producttoolfieldid,columnname,allowhide,fieldlabel,defaultvalue,presence,uitype,typeofdata,sequence,tabid,tablename,width,edit_permission,input_type,
fieldid,newline,defaultcolumn,is_checkimportfield,nullfield,referencemodule,datarange,approve_demand,maxrowsshow,bigtype,savedatabase,parentbigtype,sourcemodule)
SELECT @producttoolfieldid,@columnname,@allowhide,@fieldlabel,NULL,0,@uitype,@typeofdata,@sequence+1,@tabid,@tablename,22,1,0,0,0,1,0,1,'','','',0,@bigtype,'yes',@parentbigtype,@sourcemodule from dual
WHERE NOT EXISTS (SELECT 1 FROM ld_producttoolfield WHERE tabid=@tabid AND columnname=@columnname and tablename=@tablename and sourcemodule=@sourcemodule);

SET @relatedid = (SELECT producttoolfieldid FROM ld_producttoolfield WHERE tabid=@tabid AND columnname=@columnname and sourcemodule=@sourcemodule LIMIT 1);
INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
SELECT 'zh',@trantable,@tabid,@relatedid,@zh  from dual
WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE languagetype = 'zh' and tabid=@tabid and relateid=@relatedid AND trantable=@trantable);
INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
SELECT 'en',@trantable,@tabid,@relatedid,@en  from dual
WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE languagetype = 'en' and tabid=@tabid and relateid=@relatedid AND trantable=@trantable);
CALL AddColumn('ld_sendcashbill2payment','tax_amount','decimal',25,'');
update ld_producttoolfield_seq set id = (select max(producttoolfieldid) from ld_producttoolfield);
delimiter;




SET @producttoolfieldid=(SELECT MAX(producttoolfieldid)+1 FROM ld_producttoolfield);
set @tabid = (select tabid from ld_tab where `name` = 'SendCashBill');
SET @columnname = 'product_pay_amount';
SET @trantable='ld_producttoolfield';
SET @allowhide = 'yes';
SET @fieldlabel = '产品已付总额';
SET @zh='产品已付总额';
SET @en='Pay Amount';
SET @uitype = 50;
SET @typeofdata='NN~O~25,3';
SET @bigtype='';
SET @parentbigtype='';
SET @sequence = (SELECT IFNULL(MAX(sequence),1) FROM ld_producttoolfield where tabid=@tabid);
SET @tablename = 'ld_sendcashbill2payment';
SET @sourcemodule = 'PurchaseInvoice';
INSERT INTO ld_producttoolfield(producttoolfieldid,columnname,allowhide,fieldlabel,defaultvalue,presence,uitype,typeofdata,sequence,tabid,tablename,width,edit_permission,input_type,
fieldid,newline,defaultcolumn,is_checkimportfield,nullfield,referencemodule,datarange,approve_demand,maxrowsshow,bigtype,savedatabase,parentbigtype,sourcemodule)
SELECT @producttoolfieldid,@columnname,@allowhide,@fieldlabel,NULL,0,@uitype,@typeofdata,@sequence+1,@tabid,@tablename,22,1,0,0,1,1,0,1,'','','',0,@bigtype,'no',@parentbigtype,@sourcemodule from dual
WHERE NOT EXISTS (SELECT 1 FROM ld_producttoolfield WHERE tabid=@tabid AND columnname=@columnname and tablename=@tablename  and sourcemodule=@sourcemodule);

SET @relatedid = (SELECT producttoolfieldid FROM ld_producttoolfield WHERE tabid=@tabid AND columnname=@columnname  and sourcemodule=@sourcemodule LIMIT 1);
INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
SELECT 'zh',@trantable,@tabid,@relatedid,@zh  from dual
WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE languagetype = 'zh' and tabid=@tabid and relateid=@relatedid AND trantable=@trantable);
INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
SELECT 'en',@trantable,@tabid,@relatedid,@en  from dual
WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE languagetype = 'en' and tabid=@tabid and relateid=@relatedid AND trantable=@trantable);
CALL AddColumn('ld_sendcashbill2payment','product_pay_amount','decimal',25,'');
update ld_producttoolfield_seq set id = (select max(producttoolfieldid) from ld_producttoolfield);
delimiter;


SET @producttoolfieldid=(SELECT MAX(producttoolfieldid)+1 FROM ld_producttoolfield);
set @tabid = (select tabid from ld_tab where `name` = 'SendCashBill');
SET @columnname = 'amount';
SET @trantable='ld_producttoolfield';
SET @allowhide = 'no';
SET @fieldlabel = '本次付款金额';
SET @zh='本次付款金额';
SET @en='The amount payment';
SET @uitype = 50;
SET @typeofdata='NN~O~25,3';
SET @bigtype='';
SET @parentbigtype='';
SET @sequence = (SELECT IFNULL(MAX(sequence),1) FROM ld_producttoolfield where tabid=@tabid);
SET @tablename = 'ld_sendcashbill2payment';
SET @sourcemodule = 'PurchaseInvoice';
INSERT INTO ld_producttoolfield(producttoolfieldid,columnname,allowhide,fieldlabel,defaultvalue,presence,uitype,typeofdata,sequence,tabid,tablename,width,edit_permission,input_type,
fieldid,newline,defaultcolumn,is_checkimportfield,nullfield,referencemodule,datarange,approve_demand,maxrowsshow,bigtype,savedatabase,parentbigtype,sourcemodule)
SELECT @producttoolfieldid,@columnname,@allowhide,@fieldlabel,NULL,0,@uitype,@typeofdata,@sequence+1,@tabid,@tablename,35,0,0,0,0,1,0,1,'','','',0,@bigtype,'yes',@parentbigtype,@sourcemodule from dual
WHERE NOT EXISTS (SELECT 1 FROM ld_producttoolfield WHERE tabid=@tabid AND columnname=@columnname and tablename=@tablename  and sourcemodule=@sourcemodule);

SET @relatedid = (SELECT producttoolfieldid FROM ld_producttoolfield WHERE tabid=@tabid AND columnname=@columnname  and sourcemodule=@sourcemodule LIMIT 1);
INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
SELECT 'zh',@trantable,@tabid,@relatedid,@zh  from dual
WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE languagetype = 'zh' and tabid=@tabid and relateid=@relatedid AND trantable=@trantable);
INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
SELECT 'en',@trantable,@tabid,@relatedid,@en  from dual
WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE languagetype = 'en' and tabid=@tabid and relateid=@relatedid AND trantable=@trantable);

update ld_producttoolfield_seq set id = (select max(producttoolfieldid) from ld_producttoolfield);
delimiter;



SET @producttoolfieldid=(SELECT MAX(producttoolfieldid)+1 FROM ld_producttoolfield);
set @tabid = (select tabid from ld_tab where `name` = 'SendCashBill');
SET @columnname = 'total';
SET @trantable='ld_producttoolfield';
SET @allowhide = 'no';
SET @fieldlabel = '实际付款金额';
SET @zh='实际付款金额';
SET @en='Actual payment amount';
SET @uitype = 50;
SET @typeofdata='NN~O~25,3';
SET @bigtype='';
SET @parentbigtype='';
SET @sequence = (SELECT IFNULL(MAX(sequence),1) FROM ld_producttoolfield where tabid=@tabid);
SET @tablename = 'ld_sendcashbill2payment';
SET @sourcemodule = 'PurchaseInvoice';
INSERT INTO ld_producttoolfield(producttoolfieldid,columnname,allowhide,fieldlabel,defaultvalue,presence,uitype,typeofdata,sequence,tabid,tablename,width,edit_permission,input_type,
fieldid,newline,defaultcolumn,is_checkimportfield,nullfield,referencemodule,datarange,approve_demand,maxrowsshow,bigtype,savedatabase,parentbigtype,sourcemodule)
SELECT @producttoolfieldid,@columnname,@allowhide,@fieldlabel,NULL,0,@uitype,@typeofdata,@sequence+1,@tabid,@tablename,35,1,0,0,1,1,0,1,'','','',0,@bigtype,'yes',@parentbigtype,@sourcemodule from dual
WHERE NOT EXISTS (SELECT 1 FROM ld_producttoolfield WHERE tabid=@tabid AND columnname=@columnname and tablename=@tablename  and sourcemodule=@sourcemodule);

SET @relatedid = (SELECT producttoolfieldid FROM ld_producttoolfield WHERE tabid=@tabid AND columnname=@columnname  and sourcemodule=@sourcemodule LIMIT 1);
INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
SELECT 'zh',@trantable,@tabid,@relatedid,@zh  from dual
WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE languagetype = 'zh' and tabid=@tabid and relateid=@relatedid AND trantable=@trantable);
INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
SELECT 'en',@trantable,@tabid,@relatedid,@en  from dual
WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE languagetype = 'en' and tabid=@tabid and relateid=@relatedid AND trantable=@trantable);

update ld_producttoolfield_seq set id = (select max(producttoolfieldid) from ld_producttoolfield);
delimiter;

	-- 收款计划
SET @tabdetailfieldid=(SELECT MAX(tabdetailfieldid)+1 FROM ld_tabdetailfield);
set @tabid = (select tabid from ld_tab where `name` = 'SendCashBill');
SET @columnname = 'entitytype';
SET @trantable='ld_tabdetailfield';
SET @allowhide = 'no';
SET @fieldlabel = '源单类型';
SET @zh='源单类型';
SET @en='Link To';
SET @uitype = 'entitytype';
SET @typeofdata='V~O';
SET @bigtype='';
SET @parentbigtype='';
SET @sequence = (SELECT IFNULL(MAX(sequence),1) FROM ld_tabdetailfield where tabid=@tabid);
SET @tablename = 'ld_sendcashbill2payment';
SET @sourcemodule = 'SendPayment';
INSERT INTO ld_tabdetailfield(tabdetailfieldid,columnname,allowhide,fieldlabel,defaultvalue,presence,fieldtype,typeofdata,sequence,tabid,tablename,width,edit_permission,input_type,
fieldid,newline,defaultcolumn,is_checkimportfield,nullfield,referencemodule,datarange,approve_demand,maxrowsshow,bigtype,savedatabase,parentbigtype,sourcemodule)
SELECT @tabdetailfieldid,@columnname,@allowhide,@fieldlabel,NULL,0,@uitype,@typeofdata,@sequence+1,@tabid,@tablename,22,1,0,0,0,1,0,1,'','','',0,@bigtype,'yes',@parentbigtype,@sourcemodule from dual
WHERE NOT EXISTS (SELECT 1 FROM ld_tabdetailfield WHERE tabid=@tabid AND columnname=@columnname and tablename=@tablename and sourcemodule=@sourcemodule);

SET @relatedid = (SELECT tabdetailfieldid FROM ld_tabdetailfield WHERE tabid=@tabid AND columnname=@columnname  and sourcemodule=@sourcemodule LIMIT 1);
INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
SELECT 'zh',@trantable,@tabid,@relatedid,@zh  from dual
WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE languagetype = 'zh' and tabid=@tabid and relateid=@relatedid AND trantable=@trantable);
INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
SELECT 'en',@trantable,@tabid,@relatedid,@en  from dual
WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE languagetype = 'en' and tabid=@tabid and relateid=@relatedid AND trantable=@trantable);
CALL AddColumn(@tablename,@columnname,'varchar',25,'');
update ld_tabdetailfield_seq set id = (select max(tabdetailfieldid) from ld_tabdetailfield);
delimiter;

SET @tabdetailfieldid=(SELECT MAX(tabdetailfieldid)+1 FROM ld_tabdetailfield);
set @tabid = (select tabid from ld_tab where `name` = 'SendCashBill');
SET @columnname = 'entitytypeid';
SET @trantable='ld_tabdetailfield';
SET @allowhide = 'no';
SET @fieldlabel = '源单';
SET @zh='源单';
SET @en='Orignal Bill';
SET @uitype = 'SelectSource';
SET @typeofdata='V~O~100';
SET @bigtype='selectsource';
SET @parentbigtype='';
SET @sequence = (SELECT IFNULL(MAX(sequence),1) FROM ld_tabdetailfield where tabid=@tabid);
SET @tablename = 'ld_sendcashbill2payment';
SET @sourcemodule = 'SendPayment';
INSERT INTO ld_tabdetailfield(tabdetailfieldid,columnname,allowhide,fieldlabel,defaultvalue,presence,fieldtype,typeofdata,sequence,tabid,tablename,width,edit_permission,input_type,
fieldid,newline,defaultcolumn,is_checkimportfield,nullfield,referencemodule,datarange,approve_demand,maxrowsshow,bigtype,savedatabase,parentbigtype,sourcemodule)
SELECT @tabdetailfieldid,@columnname,@allowhide,@fieldlabel,NULL,0,@uitype,@typeofdata,@sequence+1,@tabid,@tablename,33,1,0,0,0,1,0,1,NULL,NULL,NULL,0,@bigtype,'yes',@parentbigtype,@sourcemodule from dual
WHERE NOT EXISTS (SELECT 1 FROM ld_tabdetailfield WHERE tabid=@tabid AND columnname=@columnname and tablename=@tablename and sourcemodule=@sourcemodule);

SET @relatedid = (SELECT tabdetailfieldid FROM ld_tabdetailfield WHERE tabid=@tabid AND columnname=@columnname and sourcemodule=@sourcemodule LIMIT 1);
INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
SELECT 'zh',@trantable,@tabid,@relatedid,@zh  from dual
WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE languagetype = 'zh' and tabid=@tabid and relateid=@relatedid AND trantable=@trantable);
INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
SELECT 'en',@trantable,@tabid,@relatedid,@en  from dual
WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE languagetype = 'en' and tabid=@tabid and relateid=@relatedid AND trantable=@trantable);
CALL AddColumn(@tablename,@columnname,'int',11,'');
update ld_tabdetailfield_seq set id = (select max(tabdetailfieldid) from ld_tabdetailfield);
delimiter;

SET @tabdetailfieldid=(SELECT MAX(tabdetailfieldid)+1 FROM ld_tabdetailfield);
set @tabid = (select tabid from ld_tab where `name` = 'SendCashBill');
SET @columnname = 'cpperiodtime';
SET @trantable='ld_tabdetailfield';
SET @allowhide = 'yes';
SET @fieldlabel = '期次';
SET @zh='期次';
SET @en='Stages';
SET @uitype = 'Text';
SET @typeofdata='V~O';
SET @bigtype='relatedmodulefield';
SET @parentbigtype='picklist';
SET @sequence = (SELECT IFNULL(MAX(sequence),1) FROM ld_tabdetailfield where tabid=@tabid);
SET @tablename = 'ld_sendcashbill2payment';
SET @sourcemodule = 'SendPayment';
INSERT INTO ld_tabdetailfield(tabdetailfieldid,columnname,allowhide,fieldlabel,defaultvalue,presence,fieldtype,typeofdata,sequence,tabid,tablename,width,edit_permission,input_type,
fieldid,newline,defaultcolumn,is_checkimportfield,nullfield,referencemodule,datarange,approve_demand,maxrowsshow,bigtype,savedatabase,parentbigtype,sourcemodule)
SELECT @tabdetailfieldid,@columnname,@allowhide,@fieldlabel,NULL,0,@uitype,@typeofdata,@sequence+1,@tabid,@tablename,30,1,0,0,0,1,0,1,NULL,NULL,NULL,0,@bigtype,'no',@parentbigtype,@sourcemodule from dual
WHERE NOT EXISTS (SELECT 1 FROM ld_tabdetailfield WHERE tabid=@tabid AND columnname=@columnname and tablename=@tablename and sourcemodule=@sourcemodule);

SET @relatedid = (SELECT tabdetailfieldid FROM ld_tabdetailfield WHERE tabid=@tabid AND columnname=@columnname and sourcemodule=@sourcemodule LIMIT 1);
INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
SELECT 'zh',@trantable,@tabid,@relatedid,@zh  from dual
WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE languagetype = 'zh' and tabid=@tabid and relateid=@relatedid AND trantable=@trantable);
INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
SELECT 'en',@trantable,@tabid,@relatedid,@en  from dual
WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE languagetype = 'en' and tabid=@tabid and relateid=@relatedid AND trantable=@trantable);
CALL AddColumn(@tablename,@columnname,'varchar','20','');
update ld_tabdetailfield_seq set id = (select max(tabdetailfieldid) from ld_tabdetailfield);
delimiter;

SET @tabdetailfieldid=(SELECT MAX(tabdetailfieldid)+1 FROM ld_tabdetailfield);
set @tabid = (select tabid from ld_tab where `name` = 'SendCashBill');
SET @columnname = 'plandate';
SET @trantable='ld_tabdetailfield';
SET @allowhide = 'yes';
SET @fieldlabel = '计划付款日期';
SET @zh='计划付款日期';
SET @en='Plan Date';
SET @uitype = 'Date_Ymd';
SET @typeofdata='D~O';
SET @bigtype='relatedmodulefield';
SET @parentbigtype='date';
SET @sequence = (SELECT IFNULL(MAX(sequence),1) FROM ld_tabdetailfield where tabid=@tabid);
SET @tablename = 'ld_sendcashbill2payment';
SET @sourcemodule = 'SendPayment';
INSERT INTO ld_tabdetailfield(tabdetailfieldid,columnname,allowhide,fieldlabel,defaultvalue,presence,fieldtype,typeofdata,sequence,tabid,tablename,width,edit_permission,input_type,
fieldid,newline,defaultcolumn,is_checkimportfield,nullfield,referencemodule,datarange,approve_demand,maxrowsshow,bigtype,savedatabase,parentbigtype,sourcemodule)
SELECT @tabdetailfieldid,@columnname,@allowhide,@fieldlabel,NULL,0,@uitype,@typeofdata,@sequence+1,@tabid,@tablename,30,1,0,0,0,1,0,1,NULL,NULL,NULL,0,@bigtype,'no',@parentbigtype,@sourcemodule from dual
WHERE NOT EXISTS (SELECT 1 FROM ld_tabdetailfield WHERE tabid=@tabid AND columnname=@columnname and tablename=@tablename and sourcemodule=@sourcemodule);

SET @relatedid = (SELECT tabdetailfieldid FROM ld_tabdetailfield WHERE tabid=@tabid AND columnname=@columnname and sourcemodule=@sourcemodule LIMIT 1);
INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
SELECT 'zh',@trantable,@tabid,@relatedid,@zh  from dual
WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE languagetype = 'zh' and tabid=@tabid and relateid=@relatedid AND trantable=@trantable);
INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
SELECT 'en',@trantable,@tabid,@relatedid,@en  from dual
WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE languagetype = 'en' and tabid=@tabid and relateid=@relatedid AND trantable=@trantable);
CALL AddColumn(@tablename,@columnname,'date','','');
update ld_tabdetailfield_seq set id = (select max(tabdetailfieldid) from ld_tabdetailfield);
delimiter;

SET @tabdetailfieldid=(SELECT MAX(tabdetailfieldid)+1 FROM ld_tabdetailfield);
set @tabid = (select tabid from ld_tab where `name` = 'SendCashBill');
SET @columnname = 'plan_amount';
SET @trantable='ld_tabdetailfield';
SET @allowhide = 'yes';
SET @fieldlabel = '计划付款金额';
SET @zh='计划付款金额';
SET @en='Plan Amount';
SET @uitype = 'Amount';
SET @typeofdata='NN~O';
SET @bigtype='relatedmodulefield';
SET @parentbigtype='currency';
SET @sequence = (SELECT IFNULL(MAX(sequence),1) FROM ld_tabdetailfield where tabid=@tabid);
SET @tablename = 'ld_sendcashbill2payment';
SET @sourcemodule = 'SendPayment';
INSERT INTO ld_tabdetailfield(tabdetailfieldid,columnname,allowhide,fieldlabel,defaultvalue,presence,fieldtype,typeofdata,sequence,tabid,tablename,width,edit_permission,input_type,
fieldid,newline,defaultcolumn,is_checkimportfield,nullfield,referencemodule,datarange,approve_demand,maxrowsshow,bigtype,savedatabase,parentbigtype,sourcemodule)
SELECT @tabdetailfieldid,@columnname,@allowhide,@fieldlabel,NULL,0,@uitype,@typeofdata,@sequence+1,@tabid,@tablename,22,1,0,0,0,1,0,1,NULL,NULL,NULL,0,@bigtype,'no',@parentbigtype,@sourcemodule from dual
WHERE NOT EXISTS (SELECT 1 FROM ld_tabdetailfield WHERE tabid=@tabid AND columnname=@columnname and tablename=@tablename and sourcemodule=@sourcemodule);

SET @relatedid = (SELECT tabdetailfieldid FROM ld_tabdetailfield WHERE tabid=@tabid AND columnname=@columnname and sourcemodule=@sourcemodule LIMIT 1);
INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
SELECT 'zh',@trantable,@tabid,@relatedid,@zh  from dual
WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE languagetype = 'zh' and tabid=@tabid and relateid=@relatedid AND trantable=@trantable);
INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
SELECT 'en',@trantable,@tabid,@relatedid,@en  from dual
WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE languagetype = 'en' and tabid=@tabid and relateid=@relatedid AND trantable=@trantable);
CALL AddColumn(@tablename,@columnname,'decimal','25','0.00');
update ld_tabdetailfield_seq set id = (select max(tabdetailfieldid) from ld_tabdetailfield);
delimiter;


SET @tabdetailfieldid=(SELECT MAX(tabdetailfieldid)+1 FROM ld_tabdetailfield);
set @tabid = (select tabid from ld_tab where `name` = 'SendCashBill');
SET @columnname = 'pay_amount';
SET @trantable='ld_tabdetailfield';
SET @allowhide = 'yes';
SET @fieldlabel = '已付总额';
SET @zh='已付总额';
SET @en='Received Amount';
SET @uitype = 'Amount';
SET @typeofdata='NN~O';
SET @bigtype='relatedmodulefield';
SET @parentbigtype='currency';
SET @sequence = (SELECT IFNULL(MAX(sequence),1) FROM ld_tabdetailfield where tabid=@tabid);
SET @tablename = 'ld_sendcashbill2payment';
SET @sourcemodule = 'SendPayment';
INSERT INTO ld_tabdetailfield(tabdetailfieldid,columnname,allowhide,fieldlabel,defaultvalue,presence,fieldtype,typeofdata,sequence,tabid,tablename,width,edit_permission,input_type,
fieldid,newline,defaultcolumn,is_checkimportfield,nullfield,referencemodule,datarange,approve_demand,maxrowsshow,bigtype,savedatabase,parentbigtype,sourcemodule)
SELECT @tabdetailfieldid,@columnname,@allowhide,@fieldlabel,NULL,0,@uitype,@typeofdata,@sequence+1,@tabid,@tablename,22,1,0,0,0,1,0,1,NULL,NULL,NULL,0,@bigtype,'no',@parentbigtype,@sourcemodule from dual
WHERE NOT EXISTS (SELECT 1 FROM ld_tabdetailfield WHERE tabid=@tabid AND columnname=@columnname and tablename=@tablename and sourcemodule=@sourcemodule);

SET @relatedid = (SELECT tabdetailfieldid FROM ld_tabdetailfield WHERE tabid=@tabid AND columnname=@columnname and sourcemodule=@sourcemodule LIMIT 1);
INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
SELECT 'zh',@trantable,@tabid,@relatedid,@zh  from dual
WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE languagetype = 'zh' and tabid=@tabid and relateid=@relatedid AND trantable=@trantable);
INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
SELECT 'en',@trantable,@tabid,@relatedid,@en  from dual
WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE languagetype = 'en' and tabid=@tabid and relateid=@relatedid AND trantable=@trantable);
CALL AddColumn(@tablename,@columnname,'decimal','25','0.00');
update ld_tabdetailfield_seq set id = (select max(tabdetailfieldid) from ld_tabdetailfield);
delimiter;

SET @tabdetailfieldid=(SELECT MAX(tabdetailfieldid)+1 FROM ld_tabdetailfield);
set @tabid = (select tabid from ld_tab where `name` = 'SendCashBill');
SET @columnname = 'plan_contract';
SET @trantable='ld_tabdetailfield';
SET @allowhide = 'yes';
SET @fieldlabel = '合同信息';
SET @zh='合同信息';
SET @en='Contract Info';
SET @uitype = 'Reference';
SET @typeofdata='V~O';
SET @bigtype='relatedmodulefield';
SET @parentbigtype='selectsource';
SET @sequence = (SELECT IFNULL(MAX(sequence),1) FROM ld_tabdetailfield where tabid=@tabid);
SET @tablename = 'ld_sendcashbill2payment';
SET @sourcemodule = 'SendPayment';
INSERT INTO ld_tabdetailfield(tabdetailfieldid,columnname,allowhide,fieldlabel,defaultvalue,presence,fieldtype,typeofdata,sequence,tabid,tablename,width,edit_permission,input_type,
fieldid,newline,defaultcolumn,is_checkimportfield,nullfield,referencemodule,datarange,approve_demand,maxrowsshow,bigtype,savedatabase,parentbigtype,sourcemodule)
SELECT @tabdetailfieldid,@columnname,@allowhide,@fieldlabel,NULL,0,@uitype,@typeofdata,@sequence+1,@tabid,@tablename,30,1,0,0,0,1,0,1,NULL,NULL,NULL,0,@bigtype,'no',@parentbigtype,@sourcemodule from dual
WHERE NOT EXISTS (SELECT 1 FROM ld_tabdetailfield WHERE tabid=@tabid AND columnname=@columnname and tablename=@tablename and sourcemodule=@sourcemodule);

SET @relatedid = (SELECT tabdetailfieldid FROM ld_tabdetailfield WHERE tabid=@tabid AND columnname=@columnname and sourcemodule=@sourcemodule LIMIT 1);
INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
SELECT 'zh',@trantable,@tabid,@relatedid,@zh  from dual
WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE languagetype = 'zh' and tabid=@tabid and relateid=@relatedid AND trantable=@trantable);
INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
SELECT 'en',@trantable,@tabid,@relatedid,@en  from dual
WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE languagetype = 'en' and tabid=@tabid and relateid=@relatedid AND trantable=@trantable);
CALL AddColumn(@tablename,@columnname,'int','11','');
update ld_tabdetailfield_seq set id = (select max(tabdetailfieldid) from ld_tabdetailfield);
delimiter;


SET @tabdetailfieldid=(SELECT MAX(tabdetailfieldid)+1 FROM ld_tabdetailfield);
set @tabid = (select tabid from ld_tab where `name` = 'SendCashBill');
SET @columnname = 'plan_contract_amount';
SET @trantable='ld_tabdetailfield';
SET @allowhide = 'yes';
SET @fieldlabel = '合同金额';
SET @zh='合同金额';
SET @en='Contract Amount';
SET @uitype = 'Amount';
SET @typeofdata='V~O';
SET @bigtype='Amount';
SET @parentbigtype='';
SET @sequence = (SELECT IFNULL(MAX(sequence),1) FROM ld_tabdetailfield where tabid=@tabid);
SET @tablename = 'ld_sendcashbill2payment';
SET @sourcemodule = 'SendPayment';
INSERT INTO ld_tabdetailfield(tabdetailfieldid,columnname,allowhide,fieldlabel,defaultvalue,presence,fieldtype,typeofdata,sequence,tabid,tablename,width,edit_permission,input_type,
fieldid,newline,defaultcolumn,is_checkimportfield,nullfield,referencemodule,datarange,approve_demand,maxrowsshow,bigtype,savedatabase,parentbigtype,sourcemodule)
SELECT @tabdetailfieldid,@columnname,@allowhide,@fieldlabel,NULL,0,@uitype,@typeofdata,@sequence+1,@tabid,@tablename,22,1,0,0,0,1,0,1,NULL,NULL,NULL,0,@bigtype,'no',@parentbigtype,@sourcemodule from dual
WHERE NOT EXISTS (SELECT 1 FROM ld_tabdetailfield WHERE tabid=@tabid AND columnname=@columnname and tablename=@tablename and sourcemodule=@sourcemodule);

SET @relatedid = (SELECT tabdetailfieldid FROM ld_tabdetailfield WHERE tabid=@tabid AND columnname=@columnname and sourcemodule=@sourcemodule LIMIT 1);
INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
SELECT 'zh',@trantable,@tabid,@relatedid,@zh  from dual
WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE languagetype = 'zh' and tabid=@tabid and relateid=@relatedid AND trantable=@trantable);
INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
SELECT 'en',@trantable,@tabid,@relatedid,@en  from dual
WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE languagetype = 'en' and tabid=@tabid and relateid=@relatedid AND trantable=@trantable);
CALL AddColumn(@tablename,@columnname,'decimal','25','0.00');
update ld_tabdetailfield_seq set id = (select max(tabdetailfieldid) from ld_tabdetailfield);
delimiter;

SET @tabdetailfieldid=(SELECT MAX(tabdetailfieldid)+1 FROM ld_tabdetailfield);
set @tabid = (select tabid from ld_tab where `name` = 'SendCashBill');
SET @columnname = 'plan_latestinvoicedate';
SET @trantable='ld_tabdetailfield';
SET @allowhide = 'yes';
SET @fieldlabel = '最新开票日期';
SET @zh='最新开票日期';
SET @en='Latest Invoice Date';
SET @uitype = 'Date_Ymd';
SET @typeofdata='D~O';
SET @bigtype='Date';
SET @parentbigtype='';
SET @sequence = (SELECT IFNULL(MAX(sequence),1) FROM ld_tabdetailfield where tabid=@tabid);
SET @tablename = 'ld_sendcashbill2payment';
SET @sourcemodule = 'SendPayment';
INSERT INTO ld_tabdetailfield(tabdetailfieldid,columnname,allowhide,fieldlabel,defaultvalue,presence,fieldtype,typeofdata,sequence,tabid,tablename,width,edit_permission,input_type,
fieldid,newline,defaultcolumn,is_checkimportfield,nullfield,referencemodule,datarange,approve_demand,maxrowsshow,bigtype,savedatabase,parentbigtype,sourcemodule)
SELECT @tabdetailfieldid,@columnname,@allowhide,@fieldlabel,NULL,0,@uitype,@typeofdata,@sequence+1,@tabid,@tablename,30,1,0,0,0,1,0,1,NULL,NULL,NULL,0,@bigtype,'no',@parentbigtype,@sourcemodule from dual
WHERE NOT EXISTS (SELECT 1 FROM ld_tabdetailfield WHERE tabid=@tabid AND columnname=@columnname and tablename=@tablename and sourcemodule=@sourcemodule);

SET @relatedid = (SELECT tabdetailfieldid FROM ld_tabdetailfield WHERE tabid=@tabid AND columnname=@columnname and sourcemodule=@sourcemodule LIMIT 1);
INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
SELECT 'zh',@trantable,@tabid,@relatedid,@zh  from dual
WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE languagetype = 'zh' and tabid=@tabid and relateid=@relatedid AND trantable=@trantable);
INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
SELECT 'en',@trantable,@tabid,@relatedid,@en  from dual
WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE languagetype = 'en' and tabid=@tabid and relateid=@relatedid AND trantable=@trantable);
CALL AddColumn(@tablename,@columnname,'date','','');
update ld_tabdetailfield_seq set id = (select max(tabdetailfieldid) from ld_tabdetailfield);
delimiter;

SET @tabdetailfieldid=(SELECT MAX(tabdetailfieldid)+1 FROM ld_tabdetailfield);
set @tabid = (select tabid from ld_tab where `name` = 'SendCashBill');
SET @columnname = 'plan_invoicetotal';
SET @trantable='ld_tabdetailfield';
SET @allowhide = 'yes';
SET @fieldlabel = '已开票总额';
SET @zh='已开票总额';
SET @en='Invoice Total';
SET @uitype = 'Amount';
SET @typeofdata='V~O';
SET @bigtype='amount';
SET @parentbigtype='';
SET @sequence = (SELECT IFNULL(MAX(sequence),1) FROM ld_tabdetailfield where tabid=@tabid);
SET @tablename = 'ld_sendcashbill2payment';
SET @sourcemodule = 'SendPayment';
INSERT INTO ld_tabdetailfield(tabdetailfieldid,columnname,allowhide,fieldlabel,defaultvalue,presence,fieldtype,typeofdata,sequence,tabid,tablename,width,edit_permission,input_type,
fieldid,newline,defaultcolumn,is_checkimportfield,nullfield,referencemodule,datarange,approve_demand,maxrowsshow,bigtype,savedatabase,parentbigtype,sourcemodule)
SELECT @tabdetailfieldid,@columnname,@allowhide,@fieldlabel,NULL,0,@uitype,@typeofdata,@sequence+1,@tabid,@tablename,22,1,0,0,0,1,0,1,NULL,NULL,NULL,0,@bigtype,'no',@parentbigtype,@sourcemodule from dual
WHERE NOT EXISTS (SELECT 1 FROM ld_tabdetailfield WHERE tabid=@tabid AND columnname=@columnname and tablename=@tablename and sourcemodule=@sourcemodule);

SET @relatedid = (SELECT tabdetailfieldid FROM ld_tabdetailfield WHERE tabid=@tabid AND columnname=@columnname and sourcemodule=@sourcemodule LIMIT 1);
INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
SELECT 'zh',@trantable,@tabid,@relatedid,@zh  from dual
WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE languagetype = 'zh' and tabid=@tabid and relateid=@relatedid AND trantable=@trantable);
INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
SELECT 'en',@trantable,@tabid,@relatedid,@en  from dual
WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE languagetype = 'en' and tabid=@tabid and relateid=@relatedid AND trantable=@trantable);
CALL AddColumn(@tablename,@columnname,'decimal','25','0.00');
update ld_tabdetailfield_seq set id = (select max(tabdetailfieldid) from ld_tabdetailfield);
delimiter;

SET @tabdetailfieldid=(SELECT MAX(tabdetailfieldid)+1 FROM ld_tabdetailfield);
set @tabid = (select tabid from ld_tab where `name` = 'SendCashBill');
SET @columnname = 'plan_latestcollectiondate';
SET @trantable='ld_tabdetailfield';
SET @allowhide = 'yes';
SET @fieldlabel = '最近付款日期';
SET @zh='最近付款日期';
SET @en='Latest Collection Date';
SET @uitype = 'Date_Ymd';
SET @typeofdata='D~O';
SET @bigtype='Date';
SET @parentbigtype='';
SET @sequence = (SELECT IFNULL(MAX(sequence),1) FROM ld_tabdetailfield where tabid=@tabid);
SET @tablename = 'ld_sendcashbill2payment';
SET @sourcemodule = 'SendPayment';
INSERT INTO ld_tabdetailfield(tabdetailfieldid,columnname,allowhide,fieldlabel,defaultvalue,presence,fieldtype,typeofdata,sequence,tabid,tablename,width,edit_permission,input_type,
fieldid,newline,defaultcolumn,is_checkimportfield,nullfield,referencemodule,datarange,approve_demand,maxrowsshow,bigtype,savedatabase,parentbigtype,sourcemodule)
SELECT @tabdetailfieldid,@columnname,@allowhide,@fieldlabel,NULL,0,@uitype,@typeofdata,@sequence+1,@tabid,@tablename,30,1,0,0,0,1,0,1,NULL,NULL,NULL,0,@bigtype,'no',@parentbigtype,@sourcemodule from dual
WHERE NOT EXISTS (SELECT 1 FROM ld_tabdetailfield WHERE tabid=@tabid AND columnname=@columnname and tablename=@tablename and sourcemodule=@sourcemodule);

SET @relatedid = (SELECT tabdetailfieldid FROM ld_tabdetailfield WHERE tabid=@tabid AND columnname=@columnname and sourcemodule=@sourcemodule LIMIT 1);
INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
SELECT 'zh',@trantable,@tabid,@relatedid,@zh  from dual
WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE languagetype = 'zh' and tabid=@tabid and relateid=@relatedid AND trantable=@trantable);
INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
SELECT 'en',@trantable,@tabid,@relatedid,@en  from dual
WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE languagetype = 'en' and tabid=@tabid and relateid=@relatedid AND trantable=@trantable);
CALL AddColumn(@tablename,@columnname,'date','','');
update ld_tabdetailfield_seq set id = (select max(tabdetailfieldid) from ld_tabdetailfield);
delimiter;

SET @tabdetailfieldid=(SELECT MAX(tabdetailfieldid)+1 FROM ld_tabdetailfield);
set @tabid = (select tabid from ld_tab where `name` = 'SendCashBill');
SET @columnname = 'plan_orderpayamount';
SET @trantable='ld_tabdetailfield';
SET @allowhide = 'yes';
SET @fieldlabel = '合同已付总额';
SET @zh='合同已付总额';
SET @en='Received Amount';
SET @uitype = 'Amount';
SET @typeofdata='V~O';
SET @bigtype='amount';
SET @parentbigtype='';
SET @sequence = (SELECT IFNULL(MAX(sequence),1) FROM ld_tabdetailfield where tabid=@tabid);
SET @tablename = 'ld_sendcashbill2payment';
SET @sourcemodule = 'SendPayment';
INSERT INTO ld_tabdetailfield(tabdetailfieldid,columnname,allowhide,fieldlabel,defaultvalue,presence,fieldtype,typeofdata,sequence,tabid,tablename,width,edit_permission,input_type,
fieldid,newline,defaultcolumn,is_checkimportfield,nullfield,referencemodule,datarange,approve_demand,maxrowsshow,bigtype,savedatabase,parentbigtype,sourcemodule)
SELECT @tabdetailfieldid,@columnname,@allowhide,@fieldlabel,NULL,0,@uitype,@typeofdata,@sequence+1,@tabid,@tablename,22,1,0,0,0,1,0,1,NULL,NULL,NULL,0,@bigtype,'no',@parentbigtype,@sourcemodule from dual
WHERE NOT EXISTS (SELECT 1 FROM ld_tabdetailfield WHERE tabid=@tabid AND columnname=@columnname and tablename=@tablename and sourcemodule=@sourcemodule);

SET @relatedid = (SELECT tabdetailfieldid FROM ld_tabdetailfield WHERE tabid=@tabid AND columnname=@columnname and sourcemodule=@sourcemodule LIMIT 1);
INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
SELECT 'zh',@trantable,@tabid,@relatedid,@zh  from dual
WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE languagetype = 'zh' and tabid=@tabid and relateid=@relatedid AND trantable=@trantable);
INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
SELECT 'en',@trantable,@tabid,@relatedid,@en  from dual
WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE languagetype = 'en' and tabid=@tabid and relateid=@relatedid AND trantable=@trantable);
CALL AddColumn(@tablename,@columnname,'decimal','25','0.00');
update ld_tabdetailfield_seq set id = (select max(tabdetailfieldid) from ld_tabdetailfield);
delimiter;

SET @tabdetailfieldid=(SELECT MAX(tabdetailfieldid)+1 FROM ld_tabdetailfield);
set @tabid = (select tabid from ld_tab where `name` = 'SendCashBill');
SET @columnname = 'amount';
SET @trantable='ld_tabdetailfield';
SET @allowhide = 'no';
SET @fieldlabel = '本次付款金额';
SET @zh='本次付款金额';
SET @en='The amount payment';
SET @uitype = 'Amount';
SET @typeofdata='N~O~25,6';
SET @bigtype='amount';
SET @parentbigtype='';
SET @sequence = (SELECT IFNULL(MAX(sequence),1) FROM ld_tabdetailfield where tabid=@tabid);
SET @tablename = 'ld_sendcashbill2payment';
SET @sourcemodule = 'SendPayment';
INSERT INTO ld_tabdetailfield(tabdetailfieldid,columnname,allowhide,fieldlabel,defaultvalue,presence,fieldtype,typeofdata,sequence,tabid,tablename,width,edit_permission,input_type,
fieldid,newline,defaultcolumn,is_checkimportfield,nullfield,referencemodule,datarange,approve_demand,maxrowsshow,bigtype,savedatabase,parentbigtype,sourcemodule)
SELECT @tabdetailfieldid,@columnname,@allowhide,@fieldlabel,NULL,0,@uitype,@typeofdata,@sequence+1,@tabid,@tablename,35,0,0,0,0,1,0,1,NULL,NULL,NULL,0,@bigtype,'yes',@parentbigtype,@sourcemodule from dual
WHERE NOT EXISTS (SELECT 1 FROM ld_tabdetailfield WHERE tabid=@tabid AND columnname=@columnname and tablename=@tablename and sourcemodule=@sourcemodule);

SET @relatedid = (SELECT tabdetailfieldid FROM ld_tabdetailfield WHERE tabid=@tabid AND columnname=@columnname and sourcemodule=@sourcemodule LIMIT 1);
INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
SELECT 'zh',@trantable,@tabid,@relatedid,@zh  from dual
WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE languagetype = 'zh' and tabid=@tabid and relateid=@relatedid AND trantable=@trantable);
INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
SELECT 'en',@trantable,@tabid,@relatedid,@en  from dual
WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE languagetype = 'en' and tabid=@tabid and relateid=@relatedid AND trantable=@trantable);
CALL AddColumn(@tablename,@columnname,'decimal','25','0.00');
update ld_tabdetailfield_seq set id = (select max(tabdetailfieldid) from ld_tabdetailfield);
delimiter;

SET @tabdetailfieldid=(SELECT MAX(tabdetailfieldid)+1 FROM ld_tabdetailfield);
set @tabid = (select tabid from ld_tab where `name` = 'SendCashBill');
SET @columnname = 'total';
SET @trantable='ld_tabdetailfield';
SET @allowhide = 'no';
SET @fieldlabel = '实际付款金额';
SET @zh='实际付款金额';
SET @en='Actual payment amount';
SET @uitype = 'Amount';
SET @typeofdata='N~O~25,6';
SET @bigtype='';
SET @parentbigtype='';
SET @sequence = (SELECT IFNULL(MAX(sequence),1) FROM ld_tabdetailfield where tabid=@tabid);
SET @tablename = 'ld_sendcashbill2payment';
SET @sourcemodule = 'SendPayment';
INSERT INTO ld_tabdetailfield(tabdetailfieldid,columnname,allowhide,fieldlabel,defaultvalue,presence,fieldtype,typeofdata,sequence,tabid,tablename,width,edit_permission,input_type,
fieldid,newline,defaultcolumn,is_checkimportfield,nullfield,referencemodule,datarange,approve_demand,maxrowsshow,bigtype,savedatabase,parentbigtype,sourcemodule)
SELECT @tabdetailfieldid,@columnname,@allowhide,@fieldlabel,NULL,0,@uitype,@typeofdata,@sequence+1,@tabid,@tablename,22,1,0,0,1,1,0,1,NULL,NULL,NULL,0,@bigtype,'yes',@parentbigtype,@sourcemodule from dual
WHERE NOT EXISTS (SELECT 1 FROM ld_tabdetailfield WHERE tabid=@tabid AND columnname=@columnname and tablename=@tablename and sourcemodule=@sourcemodule);

SET @relatedid = (SELECT tabdetailfieldid FROM ld_tabdetailfield WHERE tabid=@tabid AND columnname=@columnname and sourcemodule=@sourcemodule LIMIT 1);
INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
SELECT 'zh',@trantable,@tabid,@relatedid,@zh  from dual
WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE languagetype = 'zh' and tabid=@tabid and relateid=@relatedid AND trantable=@trantable);
INSERT INTO ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
SELECT 'en',@trantable,@tabid,@relatedid,@en  from dual
WHERE NOT EXISTS (SELECT 1 FROM ld_tranlabel WHERE languagetype = 'en' and tabid=@tabid and relateid=@relatedid AND trantable=@trantable);
CALL AddColumn(@tablename,@columnname,'decimal','25','0.00');
update ld_tabdetailfield_seq set id = (select max(tabdetailfieldid) from ld_tabdetailfield);
delimiter;


-- 采购订单、采购发票、付款计划
SET @modulename = 'SendCashBill';
SET @trigger_columnname = 'entitytypeid';
SET @effect_columnname = 'billdate';
SET @curmodule_columninfo = 'billdate';
SET @fromvalue_type = 'selectsource';
SET @fromvalue_info = '[{"module":"PurchaseOrder","column":"signed_data","columntype":"main"},{"module":"PurchaseInvoice","column":"purchaseinvoicedate","columntype":"main"}]';
SET @frommodule = '';
INSERT INTO ld_related_detailfield(modulename,trigger_columnname,effect_columnname,curmodule_columninfo,fromvalue_type,fromvalue_info,frommodule)
SELECT @modulename,@trigger_columnname,@effect_columnname,@curmodule_columninfo,@fromvalue_type,@fromvalue_info,@frommodule  from dual
WHERE NOT EXISTS (SELECT 1 FROM ld_related_detailfield WHERE modulename = @modulename and trigger_columnname=@trigger_columnname and effect_columnname=@effect_columnname AND fromvalue_type=@fromvalue_type);
delimiter;
SET @modulename = 'SendCashBill';
SET @trigger_columnname = 'entitytypeid';
SET @effect_columnname = 'source_total';
SET @curmodule_columninfo = 'source_total';
SET @fromvalue_type = 'selectsource';
SET @fromvalue_info = '[{"module":"PurchaseOrder","column":"total","columntype":"main"},{"module":"PurchaseInvoice","column":"total","columntype":"main"}]';
SET @frommodule = '';
INSERT INTO ld_related_detailfield(modulename,trigger_columnname,effect_columnname,curmodule_columninfo,fromvalue_type,fromvalue_info,frommodule)
SELECT @modulename,@trigger_columnname,@effect_columnname,@curmodule_columninfo,@fromvalue_type,@fromvalue_info,@frommodule  from dual
WHERE NOT EXISTS (SELECT 1 FROM ld_related_detailfield WHERE modulename = @modulename and trigger_columnname=@trigger_columnname and effect_columnname=@effect_columnname AND fromvalue_type=@fromvalue_type);
delimiter;
SET @modulename = 'SendCashBill';
SET @trigger_columnname = 'entitytypeid';
SET @effect_columnname = 'lastsendcashbilldate';
SET @curmodule_columninfo = 'lastsendcashbilldate';
SET @fromvalue_type = 'selectsource';
SET @fromvalue_info = '[{"module":"PurchaseOrder","column":"sendcashbilldate","columntype":"main"}]';
SET @frommodule = '';
INSERT INTO ld_related_detailfield(modulename,trigger_columnname,effect_columnname,curmodule_columninfo,fromvalue_type,fromvalue_info,frommodule)
SELECT @modulename,@trigger_columnname,@effect_columnname,@curmodule_columninfo,@fromvalue_type,@fromvalue_info,@frommodule  from dual
WHERE NOT EXISTS (SELECT 1 FROM ld_related_detailfield WHERE modulename = @modulename and trigger_columnname=@trigger_columnname and effect_columnname=@effect_columnname AND fromvalue_type=@fromvalue_type);
delimiter;
SET @modulename = 'SendCashBill';
SET @trigger_columnname = 'entitytypeid';
SET @effect_columnname = 'pay_amount';
SET @curmodule_columninfo = 'pay_amount';
SET @fromvalue_type = 'selectsource';
SET @fromvalue_info = '[{"module":"PurchaseOrder","column":"pay_amount","columntype":"main"},{"module":"PurchaseInvoice","column":"pay_amount","columntype":"main"},{"module":"SendPayment","column":"actualamount","columntype":"main"}]';
SET @frommodule = '';
INSERT INTO ld_related_detailfield(modulename,trigger_columnname,effect_columnname,curmodule_columninfo,fromvalue_type,fromvalue_info,frommodule)
SELECT @modulename,@trigger_columnname,@effect_columnname,@curmodule_columninfo,@fromvalue_type,@fromvalue_info,@frommodule  from dual
WHERE NOT EXISTS (SELECT 1 FROM ld_related_detailfield WHERE modulename = @modulename and trigger_columnname=@trigger_columnname and effect_columnname=@effect_columnname AND fromvalue_type=@fromvalue_type);
delimiter;

SET @modulename = 'SendCashBill';
SET @trigger_columnname = 'entitytypeid';
SET @effect_columnname = 'amount';
SET @curmodule_columninfo = 'amount';
SET @fromvalue_type = 'selectsource';
SET @fromvalue_info = '[{"module":"PurchaseOrder","column":"pay_balance","columntype":"main"},{"module":"PurchaseInvoice","column":"pay_balance","columntype":"main"},{"module":"SendPayment","column":"pay_balance","columntype":"main"}]';
SET @frommodule = '';
INSERT INTO ld_related_detailfield(modulename,trigger_columnname,effect_columnname,curmodule_columninfo,fromvalue_type,fromvalue_info,frommodule)
SELECT @modulename,@trigger_columnname,@effect_columnname,@curmodule_columninfo,@fromvalue_type,@fromvalue_info,@frommodule  from dual
WHERE NOT EXISTS (SELECT 1 FROM ld_related_detailfield WHERE modulename = @modulename and trigger_columnname=@trigger_columnname and effect_columnname=@effect_columnname AND fromvalue_type=@fromvalue_type);
delimiter;

SET @modulename = 'SendCashBill';
SET @trigger_columnname = 'entitytypeid';
SET @effect_columnname = 'productsourceid';
SET @curmodule_columninfo = 'productsourceid';
SET @fromvalue_type = 'selectsource';
SET @fromvalue_info = '[{"module":"PurchaseOrder","column":"entitytypeid","columntype":"detail"},{"module":"PurchaseInvoice","column":"entitytypeid","columntype":"detail"}]';
SET @frommodule = '';
INSERT INTO ld_related_detailfield(modulename,trigger_columnname,effect_columnname,curmodule_columninfo,fromvalue_type,fromvalue_info,frommodule)
SELECT @modulename,@trigger_columnname,@effect_columnname,@curmodule_columninfo,@fromvalue_type,@fromvalue_info,@frommodule  from dual
WHERE NOT EXISTS (SELECT 1 FROM ld_related_detailfield WHERE modulename = @modulename and trigger_columnname=@trigger_columnname and effect_columnname=@effect_columnname AND fromvalue_type=@fromvalue_type);
delimiter;

SET @modulename = 'SendCashBill';
SET @trigger_columnname = 'entitytypeid';
SET @effect_columnname = 'product_pay_amount';
SET @curmodule_columninfo = 'product_pay_amount';
SET @fromvalue_type = 'selectsource';
SET @fromvalue_info = '[{"module":"PurchaseOrder","column":"havepayamount","columntype":"detail"},{"module":"PurchaseInvoice","column":"havepayamount","columntype":"detail"}]';
SET @frommodule = '';
INSERT INTO ld_related_detailfield(modulename,trigger_columnname,effect_columnname,curmodule_columninfo,fromvalue_type,fromvalue_info,frommodule)
SELECT @modulename,@trigger_columnname,@effect_columnname,@curmodule_columninfo,@fromvalue_type,@fromvalue_info,@frommodule  from dual
WHERE NOT EXISTS (SELECT 1 FROM ld_related_detailfield WHERE modulename = @modulename and trigger_columnname=@trigger_columnname and effect_columnname=@effect_columnname AND fromvalue_type=@fromvalue_type);
delimiter;

SET @modulename = 'SendCashBill';
SET @trigger_columnname = 'entitytypeid';
SET @effect_columnname = 'tablesourcetype';
SET @curmodule_columninfo = 'tablesourcetype';
SET @fromvalue_type = 'selectsource';
SET @fromvalue_info = '[{"module":"PurchaseInvoice","column":"source_list","columntype":"main"}]';
SET @frommodule = '';
INSERT INTO ld_related_detailfield(modulename,trigger_columnname,effect_columnname,curmodule_columninfo,fromvalue_type,fromvalue_info,frommodule)
SELECT @modulename,@trigger_columnname,@effect_columnname,@curmodule_columninfo,@fromvalue_type,@fromvalue_info,@frommodule  from dual
WHERE NOT EXISTS (SELECT 1 FROM ld_related_detailfield WHERE modulename = @modulename and trigger_columnname=@trigger_columnname and effect_columnname=@effect_columnname AND fromvalue_type=@fromvalue_type);
delimiter;

SET @modulename = 'SendCashBill';
SET @trigger_columnname = 'entitytypeid';
SET @effect_columnname = 'tablesourceid';
SET @curmodule_columninfo = 'tablesourceid';
SET @fromvalue_type = 'selectsource';
SET @fromvalue_info = '[{"module":"PurchaseInvoice","column":"source_list","columntype":"main"}]';
SET @frommodule = '';
INSERT INTO ld_related_detailfield(modulename,trigger_columnname,effect_columnname,curmodule_columninfo,fromvalue_type,fromvalue_info,frommodule)
SELECT @modulename,@trigger_columnname,@effect_columnname,@curmodule_columninfo,@fromvalue_type,@fromvalue_info,@frommodule  from dual
WHERE NOT EXISTS (SELECT 1 FROM ld_related_detailfield WHERE modulename = @modulename and trigger_columnname=@trigger_columnname and effect_columnname=@effect_columnname AND fromvalue_type=@fromvalue_type);
delimiter;

SET @modulename = 'SendCashBill';
SET @trigger_columnname = 'entitytypeid';
SET @effect_columnname = 'lastinvoicedate';
SET @curmodule_columninfo = 'lastinvoicedate';
SET @fromvalue_type = 'selectsource';
SET @fromvalue_info = '[{"module":"PurchaseOrder","column":"lastinvoicedate","columntype":"main"},{"module":"PurchaseInvoice","column":"purchaseinvoicedate","columntype":"main"}]';
SET @frommodule = '';
INSERT INTO ld_related_detailfield(modulename,trigger_columnname,effect_columnname,curmodule_columninfo,fromvalue_type,fromvalue_info,frommodule)
SELECT @modulename,@trigger_columnname,@effect_columnname,@curmodule_columninfo,@fromvalue_type,@fromvalue_info,@frommodule  from dual
WHERE NOT EXISTS (SELECT 1 FROM ld_related_detailfield WHERE modulename = @modulename and trigger_columnname=@trigger_columnname and effect_columnname=@effect_columnname AND fromvalue_type=@fromvalue_type);
delimiter;

SET @modulename = 'SendCashBill';
SET @trigger_columnname = 'entitytypeid';
SET @effect_columnname = 'have_invoicetotal';
SET @curmodule_columninfo = 'have_invoicetotal';
SET @fromvalue_type = 'selectsource';
SET @fromvalue_info = '[{"module":"PurchaseOrder","column":"have_invoicetotal","columntype":"main"}]';
SET @frommodule = '';
INSERT INTO ld_related_detailfield(modulename,trigger_columnname,effect_columnname,curmodule_columninfo,fromvalue_type,fromvalue_info,frommodule)
SELECT @modulename,@trigger_columnname,@effect_columnname,@curmodule_columninfo,@fromvalue_type,@fromvalue_info,@frommodule  from dual
WHERE NOT EXISTS (SELECT 1 FROM ld_related_detailfield WHERE modulename = @modulename and trigger_columnname=@trigger_columnname and effect_columnname=@effect_columnname AND fromvalue_type=@fromvalue_type);
delimiter;


SET @modulename = 'SendCashBill';
SET @trigger_columnname = 'entitytypeid';
SET @effect_columnname = 'cpperiodtime';
SET @curmodule_columninfo = 'cpperiodtime';
SET @fromvalue_type = 'selectsource';
SET @fromvalue_info = '[{"module":"SendPayment","column":"cpperiodtime","columntype":"main"}]';
SET @frommodule = '';
INSERT INTO ld_related_detailfield(modulename,trigger_columnname,effect_columnname,curmodule_columninfo,fromvalue_type,fromvalue_info,frommodule)
SELECT @modulename,@trigger_columnname,@effect_columnname,@curmodule_columninfo,@fromvalue_type,@fromvalue_info,@frommodule  from dual
WHERE NOT EXISTS (SELECT 1 FROM ld_related_detailfield WHERE modulename = @modulename and trigger_columnname=@trigger_columnname and effect_columnname=@effect_columnname AND fromvalue_type=@fromvalue_type);
delimiter;

SET @modulename = 'SendCashBill';
SET @trigger_columnname = 'entitytypeid';
SET @effect_columnname = 'plandate';
SET @curmodule_columninfo = 'plandate';
SET @fromvalue_type = 'selectsource';
SET @fromvalue_info = '[{"module":"SendPayment","column":"plandate","columntype":"main"}]';
SET @frommodule = '';
INSERT INTO ld_related_detailfield(modulename,trigger_columnname,effect_columnname,curmodule_columninfo,fromvalue_type,fromvalue_info,frommodule)
SELECT @modulename,@trigger_columnname,@effect_columnname,@curmodule_columninfo,@fromvalue_type,@fromvalue_info,@frommodule  from dual
WHERE NOT EXISTS (SELECT 1 FROM ld_related_detailfield WHERE modulename = @modulename and trigger_columnname=@trigger_columnname and effect_columnname=@effect_columnname AND fromvalue_type=@fromvalue_type);
delimiter;

SET @modulename = 'SendCashBill';
SET @trigger_columnname = 'entitytypeid';
SET @effect_columnname = 'plan_amount';
SET @curmodule_columninfo = 'plan_amount';
SET @fromvalue_type = 'selectsource';
SET @fromvalue_info = '[{"module":"SendPayment","column":"amount","columntype":"main"}]';
SET @frommodule = '';
INSERT INTO ld_related_detailfield(modulename,trigger_columnname,effect_columnname,curmodule_columninfo,fromvalue_type,fromvalue_info,frommodule)
SELECT @modulename,@trigger_columnname,@effect_columnname,@curmodule_columninfo,@fromvalue_type,@fromvalue_info,@frommodule  from dual
WHERE NOT EXISTS (SELECT 1 FROM ld_related_detailfield WHERE modulename = @modulename and trigger_columnname=@trigger_columnname and effect_columnname=@effect_columnname AND fromvalue_type=@fromvalue_type);
delimiter;

SET @modulename = 'SendCashBill';
SET @trigger_columnname = 'entitytypeid';
SET @effect_columnname = 'pay_amount';
SET @curmodule_columninfo = 'pay_amount';
SET @fromvalue_type = 'selectsource';
SET @fromvalue_info = '[{"module":"SendPayment","column":"actualamount","columntype":"main"}]';
SET @frommodule = '';
INSERT INTO ld_related_detailfield(modulename,trigger_columnname,effect_columnname,curmodule_columninfo,fromvalue_type,fromvalue_info,frommodule)
SELECT @modulename,@trigger_columnname,@effect_columnname,@curmodule_columninfo,@fromvalue_type,@fromvalue_info,@frommodule  from dual
WHERE NOT EXISTS (SELECT 1 FROM ld_related_detailfield WHERE modulename = @modulename and trigger_columnname=@trigger_columnname and effect_columnname=@effect_columnname AND fromvalue_type=@fromvalue_type);
delimiter;

SET @modulename = 'SendCashBill';
SET @trigger_columnname = 'entitytypeid';
SET @effect_columnname = 'plan_contract';
SET @curmodule_columninfo = 'plan_contract';
SET @fromvalue_type = 'selectsource';
SET @fromvalue_info = '[{"module":"SendPayment","column":"purchaseorder_id","columntype":"main"}]';
SET @frommodule = '';
INSERT INTO ld_related_detailfield(modulename,trigger_columnname,effect_columnname,curmodule_columninfo,fromvalue_type,fromvalue_info,frommodule)
SELECT @modulename,@trigger_columnname,@effect_columnname,@curmodule_columninfo,@fromvalue_type,@fromvalue_info,@frommodule  from dual
WHERE NOT EXISTS (SELECT 1 FROM ld_related_detailfield WHERE modulename = @modulename and trigger_columnname=@trigger_columnname and effect_columnname=@effect_columnname AND fromvalue_type=@fromvalue_type);
delimiter;

SET @modulename = 'SendCashBill';
SET @trigger_columnname = 'entitytypeid';
SET @effect_columnname = 'amount';
SET @curmodule_columninfo = 'amount';
SET @fromvalue_type = 'selectsource';
SET @fromvalue_info = '[{"module":"PurchaseOrder","column":"pay_balance","columntype":"main"},{"module":"PurchaseInvoice","column":"pay_balance","columntype":"main"},{"module":"SendPayment","column":"pay_balance","columntype":"main"}]';
SET @frommodule = '';
INSERT INTO ld_related_detailfield(modulename,trigger_columnname,effect_columnname,curmodule_columninfo,fromvalue_type,fromvalue_info,frommodule)
SELECT @modulename,@trigger_columnname,@effect_columnname,@curmodule_columninfo,@fromvalue_type,@fromvalue_info,@frommodule  from dual
WHERE NOT EXISTS (SELECT 1 FROM ld_related_detailfield WHERE modulename = @modulename and trigger_columnname=@trigger_columnname and effect_columnname=@effect_columnname AND fromvalue_type=@fromvalue_type);
delimiter;

drop PROCEDURE if EXISTS receivedamountfordetailtable;
delimiter ||
create PROCEDURE receivedamountfordetailtable()
begin 
 declare ttablename varchar(50);
 declare ttabid int(11);
 declare done  int  default 0;
	declare cur2 CURSOR FOR select  tablename,tabid  from ld_producttoolfield where  columnname='quantity' and 
					(sourcemodule is null or sourcemodule='');
	declare continue handler  for not   found  SET done =1;
	open cur2;
	fetch cur2 into ttablename,ttabid;
	loop2: while  done<>1 DO
		call AddColumn(ttablename,'havereceivedamount','decimal','20','0');
		call AddColumn(ttablename,'balancereceivedamount','decimal','20','0');
    if(ttablename!='ld_salesorderdetail' and ttablename!='ld_servicecontractsdetail' and 
			ttablename!='ld_outboundorderdetail' and ttablename!='ld_invoicedetail')then
			set @sql=concat('update ',ttablename,' set balancereceivedamount=tax_amount 
				where not exists(select 1 from ld_producttoolfield where tablename="',ttablename,'" and columnname="balancereceivedamount")');
				prepare updatestmt from @sql;
		   execute updatestmt;
	    	deallocate  prepare  updatestmt;
    end if;
		set @sql=Concat('alter table ', ttablename,' modify havereceivedamount decimal(20,6)');
		prepare stmt from @sql;
		execute stmt;
		deallocate  prepare  stmt;
			set @sql=Concat('alter table ', ttablename,' modify balancereceivedamount decimal(20,6)');
		prepare stmt4 from @sql;
		execute stmt4;
		deallocate  prepare  stmt4;

		select max(producttoolfieldid)+1 into @maxproducttoolfieldid from ld_producttoolfield;
	
	 set @sql=Concat('insert into ld_producttoolfield(producttoolfieldid,columnname,allowhide,fieldlabel,defaultvalue,presence,uitype
		,typeofdata,sequence,tabid,tablename,edit_permission,input_type,bigtype)

		select ', @maxproducttoolfieldid,",'havereceivedamount','yes','已收总额','',1,28,'N~O~25,2',1,",ttabid,",'",ttablename,"',1,1,'' from DUAL
		where not exists(select 1 from ld_producttoolfield where  tabid=",ttabid," and columnname='havereceivedamount')");
		prepare stmt2 from @sql;
		execute stmt2;
		deallocate  prepare  stmt2;
	
	 set @sql=Concat('insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
								select "zh","ld_producttoolfield",',ttabid,",",@maxproducttoolfieldid,",'已收总额' from dual 		
							   where not exists(select 1 from ld_tranlabel where languagetype='zh' and tabid=",ttabid, " and relateid=",@maxproducttoolfieldid
								," and trantable='ld_producttoolfield')");
	  prepare stmt3 from @sql;
		execute stmt3;
		deallocate  prepare  stmt3;
	  set @sql=Concat('insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
								select "en","ld_producttoolfield",',ttabid,",",@maxproducttoolfieldid,",'已收总额' from dual 		
							   where not exists(select 1 from ld_tranlabel where languagetype='en' and tabid=",ttabid, " and relateid=",@maxproducttoolfieldid
								," and trantable='ld_producttoolfield')");
	  prepare stmt3 from @sql;
		execute stmt3;
		deallocate  prepare  stmt3;
	

		select max(producttoolfieldid)+1 into @maxproducttoolfieldid from ld_producttoolfield;
	
	 set @sql=Concat('insert into ld_producttoolfield(producttoolfieldid,columnname,allowhide,fieldlabel,defaultvalue,presence,uitype
		,typeofdata,sequence,tabid,tablename,edit_permission,input_type,bigtype)

		select ', @maxproducttoolfieldid,",'balancereceivedamount','yes','应收总额','',1,28,'N~O~25,2',1,",ttabid,",'",ttablename,"',1,1,'' from DUAL
		where not exists(select 1 from ld_producttoolfield where  tabid=",ttabid," and columnname='balancereceivedamount')");
		prepare stmt2 from @sql;
		execute stmt2;
		deallocate  prepare  stmt2;
	
	 set @sql=Concat('insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
								select "zh","ld_producttoolfield",',ttabid,",",@maxproducttoolfieldid,",'应收总额' from dual 		
							   where not exists(select 1 from ld_tranlabel where languagetype='zh' and tabid=",ttabid, " and relateid=",@maxproducttoolfieldid
								," and trantable='ld_producttoolfield')");
	  prepare stmt3 from @sql;
		execute stmt3;
		deallocate  prepare  stmt3;
	  set @sql=Concat('insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
								select "en","ld_producttoolfield",',ttabid,",",@maxproducttoolfieldid,",'应收总额' from dual 		
							   where not exists(select 1 from ld_tranlabel where languagetype='en' and tabid=",ttabid, " and relateid=",@maxproducttoolfieldid
								," and trantable='ld_producttoolfield')");
	  prepare stmt3 from @sql;
		execute stmt3;
		deallocate  prepare  stmt3;
	
   

		call AddColumn(ttablename,'havepayamount','decimal','20','0');
		call AddColumn(ttablename,'balancepayamount','decimal','20','0');
		if(ttablename!='ld_purchaseorderdetail' and ttablename!='ld_purchaseinvoicedetail') then
			set @sql=concat ('update ',ttablename,' set balancepayamount=tax_amount 
				where not exists(select 1 from ld_producttoolfield where tablename="',ttablename,'" and columnname="balancepayamount")');
				prepare updatestmt1 from @sql;
		   execute updatestmt1;
	    	deallocate  prepare  updatestmt1;
    end if;
		set @sql=Concat('alter table ', ttablename,' modify havepayamount decimal(20,6)');
		prepare stmt5 from @sql;
		execute stmt5;
		deallocate  prepare  stmt5;

		set @sql=Concat('alter table ', ttablename,' modify balancepayamount decimal(20,6)');
		prepare stmt6 from @sql;
		execute stmt6;
		deallocate  prepare  stmt6;
		
		select max(producttoolfieldid)+1 into @maxproducttoolfieldid from ld_producttoolfield;
	
	 set @sql=Concat('insert into ld_producttoolfield(producttoolfieldid,columnname,allowhide,fieldlabel,defaultvalue,presence,uitype
		,typeofdata,sequence,tabid,tablename,edit_permission,input_type,bigtype)

		select ', @maxproducttoolfieldid,",'havepayamount','yes','已付总额','',1,28,'N~O~25,2',1,",ttabid,",'",ttablename,"',1,1,'' from DUAL
		where not exists(select 1 from ld_producttoolfield where  tabid=",ttabid," and columnname='havepayamount')");
		prepare stmt2 from @sql;
		execute stmt2;
		deallocate  prepare  stmt2;
	
	 set @sql=Concat('insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
								select "zh","ld_producttoolfield",',ttabid,",",@maxproducttoolfieldid,",'已付总额' from dual 		
							   where not exists(select 1 from ld_tranlabel where languagetype='zh' and tabid=",ttabid, " and relateid=",@maxproducttoolfieldid
								," and trantable='ld_producttoolfield')");
	  prepare stmt3 from @sql;
		execute stmt3;
		deallocate  prepare  stmt3;
	  set @sql=Concat('insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
								select "en","ld_producttoolfield",',ttabid,",",@maxproducttoolfieldid,",'已付总额' from dual 		
							   where not exists(select 1 from ld_tranlabel where languagetype='en' and tabid=",ttabid, " and relateid=",@maxproducttoolfieldid
								," and trantable='ld_producttoolfield')");
	  prepare stmt3 from @sql;
		execute stmt3;
		deallocate  prepare  stmt3;

		
	select max(producttoolfieldid)+1 into @maxproducttoolfieldid from ld_producttoolfield;
	
	 set @sql=Concat('insert into ld_producttoolfield(producttoolfieldid,columnname,allowhide,fieldlabel,defaultvalue,presence,uitype
		,typeofdata,sequence,tabid,tablename,edit_permission,input_type,bigtype)

		select ', @maxproducttoolfieldid,",'balancepayamount','yes','应付总额','',1,28,'N~O~25,2',1,",ttabid,",'",ttablename,"',1,1,'' from DUAL
		where not exists(select 1 from ld_producttoolfield where  tabid=",ttabid," and columnname='balancepayamount')");
		prepare stmt2 from @sql;
		execute stmt2;
		deallocate  prepare  stmt2;
	
	 set @sql=Concat('insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
								select "zh","ld_producttoolfield",',ttabid,",",@maxproducttoolfieldid,",'应付总额' from dual 		
							   where not exists(select 1 from ld_tranlabel where languagetype='zh' and tabid=",ttabid, " and relateid=",@maxproducttoolfieldid
								," and trantable='ld_producttoolfield')");
	  prepare stmt3 from @sql;
		execute stmt3;
		deallocate  prepare  stmt3;
	  set @sql=Concat('insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
								select "en","ld_producttoolfield",',ttabid,",",@maxproducttoolfieldid,",'应付总额' from dual 		
							   where not exists(select 1 from ld_tranlabel where languagetype='en' and tabid=",ttabid, " and relateid=",@maxproducttoolfieldid
								," and trantable='ld_producttoolfield')");
	  prepare stmt3 from @sql;
		execute stmt3;
		deallocate  prepare  stmt3;
	fetch cur2 into ttablename,ttabid;
	end while loop2;
	close cur2;



end ||
delimiter;

call receivedamountfordetailtable(); 
drop PROCEDURE if EXISTS receivedamountfordetailtable;
delimiter;

drop PROCEDURE if EXISTS receivedamountformaintable;
delimiter ||
create PROCEDURE receivedamountformaintable()
begin 
 declare ttablename varchar(50);
 declare ttabid int(11);
declare bblock int(11);
	declare tmp_columnname varchar(50);
 declare done  int  default 0;
	declare cur3 CURSOR FOR select  ld_field.tablename,ld_field.tabid,ld_field.block  from
			ld_field inner join ld_producttoolfield on ld_field.tabid=ld_producttoolfield.tabid 
			where  ld_producttoolfield.columnname='quantity' and 
					(sourcemodule is null or sourcemodule='') and ld_field.columnname='smownerid';
	declare continue handler  for not   found  SET done =1;
	open cur3;
	fetch cur3 into ttablename,ttabid,bblock;
   set @disable_triggers ='a';

	loop2: while  done<>1 DO
		set tmp_columnname='received_amount';
		IF NOT EXISTS (SELECT 1 FROM information_schema.COLUMNS WHERE TABLE_SCHEMA=DATABASE() AND TABLE_NAME=ttablename AND COLUMN_NAME=tmp_columnname) THEN
			call AddColumn(ttablename,'received_amount','decimal','20','0');
			call AddColumn(ttablename,'receivable_balance','decimal','20','0');
			set @sql=Concat('alter table ', ttablename,' modify received_amount decimal(20,6)');
			prepare stmt from @sql;
			execute stmt;
			set @sql=Concat('alter table ', ttablename,' modify receivable_balance decimal(20,6)');
			prepare stmt1 from @sql;
			execute stmt1;
			
			set @sql=concat('update ',ttablename,' set receivable_balance=total 
				where not exists(select 1 from ld_field where tablename="',ttablename,'" and columnname="receivable_balance")');
				prepare updatestmt from @sql;
		   execute updatestmt;
	    	deallocate  prepare  updatestmt;
			
			set @sql=Concat("insert into ld_field(tabid,columnname,tablename,generatedtype,uitype,fieldname,fieldlabel,readonly,presence,defaultvalue,sequence,block,displaytype,typeofdata,quickcreate,quickcreatesequence,info_type,masseditable,helpinfo,fieldonly,approve_demand,is_checkimportfield,bigtype,datarang,maxrowsshow,allowedit,allowedit_presence,allowcreate,allowcreate_presence,allowdetail_presence)
							select ",ttabid,",'received_amount','",ttablename,"',1,71,'received_amount','已收总额',0,1,NULL,1,",bblock,",2,'N~O~25,2',0,NULL,NULL,1,NULL,0,2,0,'currency',NULL,0,'no','no','no','no','no' from dual
							where not exists (select 1 from ld_field where tabid=",ttabid," and tablename='",ttablename,"' and columnname='received_amount')");
			prepare stmt2 from @sql;
			execute stmt2;
			select fieldid into @fieldid from ld_field where tabid=ttabid and columnname='received_amount';
			set @sql=Concat('insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
								select "zh","ld_field",',ttabid,",",@fieldid,",'已收总额' from dual 		
							   where not exists(select 1 from ld_tranlabel where languagetype='zh' and tabid=",ttabid, " and relateid=",@fieldid
								," and trantable='ld_field')");
			prepare stmt3 from @sql;
			execute stmt3;
			deallocate  prepare  stmt3;
			set @sql=Concat('insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
									select "en","ld_field",',ttabid,",",@fieldid,",'已收总额' from dual 		
									 where not exists(select 1 from ld_tranlabel where languagetype='en' and tabid=",ttabid, " and relateid=",@fieldid
									," and trantable='ld_field')");
			prepare stmt4 from @sql;
			execute stmt4;
			deallocate  prepare  stmt4;

			set @sql=Concat("insert into ld_field(tabid,columnname,tablename,generatedtype,uitype,fieldname,fieldlabel,readonly,presence,defaultvalue,sequence,block,displaytype,typeofdata,quickcreate,quickcreatesequence,info_type,masseditable,helpinfo,fieldonly,approve_demand,is_checkimportfield,bigtype,datarang,maxrowsshow,allowedit,allowedit_presence,allowcreate,allowcreate_presence,allowdetail_presence)
							select ",ttabid,",'receivable_balance','",ttablename,"',1,71,'receivable_balance','应收余额',0,1,NULL,1,",bblock,",2,'N~O~25,2',0,NULL,NULL,1,NULL,0,2,0,'currency',NULL,0,'no','no','no','no','no' from dual
							where not exists (select 1 from ld_field where tabid=",ttabid," and tablename='",ttablename,"' and columnname='receivable_balance')");
			prepare stmt5 from @sql;
			execute stmt5;

			select fieldid into @fieldid from ld_field where tabid=ttabid and columnname='receivable_balance';
			set @sql=Concat('insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
								select "zh","ld_field",',ttabid,",",@fieldid,",'应收余额' from dual 		
							   where not exists(select 1 from ld_tranlabel where languagetype='zh' and tabid=",ttabid,
											" and relateid=",@fieldid
								," and trantable='ld_field')");
			prepare stmt6 from @sql;
			execute stmt6;
			deallocate  prepare  stmt6;
			set @sql=Concat('insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
									select "en","ld_field",',ttabid,",",@fieldid,",'应收余额' from dual 		
									 where not exists(select 1 from ld_tranlabel where languagetype='en' and tabid=",ttabid, " and relateid=",@fieldid
									," and trantable='ld_field')");
			prepare stmt7 from @sql;
			execute stmt7;
			deallocate  prepare  stmt7;
		end if ;
		
		set tmp_columnname='pay_amount';
		IF NOT EXISTS (SELECT 1 FROM information_schema.COLUMNS WHERE TABLE_SCHEMA=DATABASE() AND TABLE_NAME=ttablename AND COLUMN_NAME=tmp_columnname) THEN
			call AddColumn(ttablename,'pay_amount','decimal','20','0');
			call AddColumn(ttablename,'pay_balance','decimal','20','0');
			set @sql=Concat('alter table ', ttablename,' modify pay_amount decimal(20,6)');
			prepare stmt20 from @sql;
			execute stmt20;
			set @sql=Concat('alter table ', ttablename,' modify pay_balance decimal(20,6)');
			prepare stmt21 from @sql;
			execute stmt21;
			
			set @sql=concat('update ',ttablename,' set pay_balance=total 
				where not exists(select 1 from ld_field where tablename="',ttablename,'" and columnname="pay_balance")');
				prepare updatestmt2 from @sql;
		   execute updatestmt2;
	    	deallocate  prepare  updatestmt2;
			
			set @sql=Concat("insert into ld_field(tabid,columnname,tablename,generatedtype,uitype,fieldname,fieldlabel,readonly,presence,defaultvalue,sequence,block,displaytype,typeofdata,quickcreate,quickcreatesequence,info_type,masseditable,helpinfo,fieldonly,approve_demand,is_checkimportfield,bigtype,datarang,maxrowsshow,allowedit,allowedit_presence,allowcreate,allowcreate_presence,allowdetail_presence)
							select ",ttabid,",'pay_amount','",ttablename,"',1,71,'pay_amount','已收总额',0,1,NULL,1,",bblock,",2,'N~O~25,2',0,NULL,NULL,1,NULL,0,2,0,'currency',NULL,0,'no','no','no','no','no' from dual
							where not exists (select 1 from ld_field where tabid=",ttabid," and tablename='",ttablename,"' and columnname='pay_amount')");
			prepare stmt22 from @sql;
			execute stmt22;
			select fieldid into @fieldid from ld_field where tabid=ttabid and columnname='pay_amount';
			set @sql=Concat('insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
								select "zh","ld_field",',ttabid,",",@fieldid,",'已付总额' from dual 		
							   where not exists(select 1 from ld_tranlabel where languagetype='zh' and tabid=",ttabid, " and relateid=",@fieldid
								," and trantable='ld_field')");
			prepare stmt23 from @sql;
			execute stmt23;
			deallocate  prepare  stmt23;
			set @sql=Concat('insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
									select "en","ld_field",',ttabid,",",@fieldid,",'已付总额' from dual 		
									 where not exists(select 1 from ld_tranlabel where languagetype='en' and tabid=",ttabid, " and relateid=",@fieldid
									," and trantable='ld_field')");
			prepare stmt24 from @sql;
			execute stmt24;
			deallocate  prepare  stmt24;

			set @sql=Concat("insert into ld_field(tabid,columnname,tablename,generatedtype,uitype,fieldname,fieldlabel,readonly,presence,defaultvalue,sequence,block,displaytype,typeofdata,quickcreate,quickcreatesequence,info_type,masseditable,helpinfo,fieldonly,approve_demand,is_checkimportfield,bigtype,datarang,maxrowsshow,allowedit,allowedit_presence,allowcreate,allowcreate_presence,allowdetail_presence)
							select ",ttabid,",'pay_balance','",ttablename,"',1,71,'pay_balance','应付余额',0,1,NULL,1,",bblock,",2,'N~O~25,2',0,NULL,NULL,1,NULL,0,2,0,'currency',NULL,0,'no','no','no','no','no' from dual
							where not exists (select 1 from ld_field where tabid=",ttabid," and tablename='",ttablename,"' and columnname='pay_balance')");
			prepare stmt25 from @sql;
			execute stmt25;
			select fieldid into @fieldid from ld_field where tabid=ttabid and columnname='pay_balance';
			set @sql=Concat('insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
								select "zh","ld_field",',ttabid,",",@fieldid,",'应付余额' from dual 		
							   where not exists(select 1 from ld_tranlabel where languagetype='zh' and tabid=",ttabid, " and relateid=",@fieldid
								," and trantable='ld_field')");
			prepare stmt26 from @sql;
			execute stmt26;
			deallocate  prepare  stmt26;
			set @sql=Concat('insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
									select "en","ld_field",',ttabid,",",@fieldid,",'应付余额' from dual 		
									 where not exists(select 1 from ld_tranlabel where languagetype='en' and tabid=",ttabid, " and relateid=",@fieldid
									," and trantable='ld_field')");
			prepare stmt27 from @sql;
			execute stmt27;
			deallocate  prepare  stmt27;
		end if ;


	fetch cur3 into ttablename,ttabid,bblock;
	end while loop2;
	close cur3;

end ||
delimiter;
call receivedamountformaintable(); 
delimiter;

UPDATE ld_field  SET editpage='' WHERE uitype =230 AND displaytype=1 AND allowedit='yes' AND savedatabase='yes' and editpage='listview';
delimiter;
-- 2022-08-26


ALTER TABLE ld_cfoperationlog MODIFY createdtime DATETIME; 
ALTER TABLE ld_cfoperationlog MODIFY deletedtime DATETIME; 
ALTER TABLE ld_cfoperationlog MODIFY modifiedtime DATETIME; 

DELETE ld_tranlabel from ld_tranlabel 
LEFT JOIN ld_producttoolfield on ld_producttoolfield.producttoolfieldid=Relateid
where ld_tranlabel.trantable='ld_producttoolfield' and ld_tranlabel.fieldlabel='已收总额' and 
(ld_producttoolfield.producttoolfieldid is null or (ld_producttoolfield.fieldlabel <> ld_tranlabel.fieldlabel));
delimiter;
-- 2022-08-29

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

UPDATE ld_version SET old_version='V8.4.7.2',current_version='V8.4.7.2',remark='V8.4.7.2-20220829',wx_version='V8.4.7.2';
delimiter;